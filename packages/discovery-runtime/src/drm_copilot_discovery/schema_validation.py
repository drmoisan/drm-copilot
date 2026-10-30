"""Validate strict documents against caller-selected offline schemas and formats.

Structural acceptance supplies no completion or approval authority. A successful
v1 read is explicitly compatibility-only and cannot satisfy a v2 completion gate.
"""

from __future__ import annotations

import calendar
import re
from dataclasses import dataclass
from datetime import date, timedelta
from ipaddress import IPv6Address
from typing import TYPE_CHECKING, Literal, Protocol, cast

from drm_copilot_discovery.catalog import (
    CatalogError,
    SchemaCatalog,
    load_catalog,
    schema_aliases,
)
from drm_copilot_discovery.findings import Finding, FindingCollector, child_pointer
from drm_copilot_discovery.models import JsonObject, ParseLimits, to_plain_value
from drm_copilot_discovery.parsing import parse_document

if TYPE_CHECKING:
    from collections.abc import Iterator

    from jsonschema import FormatChecker
    from jsonschema.exceptions import ValidationError

_TIMESTAMP = re.compile(
    r"([0-9]{4})-([0-9]{2})-([0-9]{2})[Tt]"
    r"([0-9]{2}):([0-9]{2}):([0-9]{2})(?:\.[0-9]+)?"
    r"([Zz]|[+-][0-9]{2}:[0-9]{2})"
)
_URI_ATOM = r"(?:[A-Za-z0-9._~!$&'()*+,;=-]|%[0-9A-Fa-f]{2})"
_HTTP_REFERENCE = re.compile(r"(?i:https?)://([^/?#]*)([^?#]*)(?:\?([^#]*))?(?:#(.*))?")
# Source: https://data.iana.org/time-zones/data/leap-seconds.list (public domain).
# Known positive insertions end at 2016-12-31; future insertions require an update.
_LEAP_SECOND_DATES = frozenset(
    "1972-06-30 1972-12-31 1973-12-31 1974-12-31 1975-12-31 "
    "1976-12-31 1977-12-31 1978-12-31 1979-12-31 1981-06-30 "
    "1982-06-30 1983-06-30 1985-06-30 1987-12-31 1989-12-31 "
    "1990-12-31 1992-06-30 1993-06-30 1994-06-30 1995-12-31 "
    "1997-06-30 1998-12-31 2005-12-31 2008-12-31 2012-06-30 "
    "2015-06-30 2016-12-31".split()
)


def is_rfc3339_timestamp(value: object) -> bool:
    """Check RFC 3339 syntax, Gregorian dates, offsets and known leap seconds."""
    if not isinstance(value, str):
        return True
    match = _TIMESTAMP.fullmatch(value)
    if match is None:
        return False
    # Parse only grammar-constrained ASCII digits before applying calendar rules.
    year, month, day, hour, minute, second = (int(part) for part in match.groups()[:6])
    zone = match.group(7)
    if not 1 <= month <= 12 or not 1 <= day <= calendar.monthrange(year, month)[1]:
        return False
    if hour > 23 or minute > 59 or second > 60:
        return False
    offset = 0
    # Numeric offsets are signed minutes; Z contributes no displacement.
    if zone not in ("Z", "z"):
        zone_hour, zone_minute = int(zone[1:3]), int(zone[4:6])
        if zone_hour > 23 or zone_minute > 59:
            return False
        offset = (zone_hour * 60 + zone_minute) * (1 if zone[0] == "+" else -1)
    if second < 60:
        return True
    # UTC placement is checked independently of datetime's second<=59 restriction.
    if not 1972 <= year <= 2017:
        return False
    day_shift, utc_minute = divmod(hour * 60 + minute - offset, 1440)
    utc_date = date(year, month, day) + timedelta(days=day_shift)
    return utc_minute == 1439 and utc_date.isoformat() in _LEAP_SECOND_DATES


def _valid_http_authority(authority: str) -> bool:
    """Validate RFC 3986 authority with the HTTP nonempty-host requirement."""
    # User information has distinct syntax and cannot hide an extra authority marker.
    if "@" in authority:
        userinfo, _, authority = authority.rpartition("@")
        if re.fullmatch(rf"(?:{_URI_ATOM}|:)*", userinfo) is None:
            return False
    # Bracketed literals use IPv6/IPvFuture syntax instead of a registered name.
    if authority.startswith("["):
        literal = re.fullmatch(r"\[([^\]]+)\](?::[0-9]*)?", authority)
        if literal is None:
            return False
        address = literal.group(1)
        if re.fullmatch(r"[vV][0-9A-Fa-f]+\.[A-Za-z0-9._~!$&'()*+,;=:-]+", address):
            return True
        if "%" in address:
            return False
        try:
            IPv6Address(address)
        except ValueError:
            return False
        return True
    host, colon, port = authority.partition(":")
    return re.fullmatch(rf"{_URI_ATOM}+", host) is not None and (
        not colon or re.fullmatch(r"[0-9]*", port) is not None
    )


def is_http_evidence_uri(value: object) -> bool:
    """Check descriptive HTTP(S) references under RFC 3986 and RFC 9110.

    This is the discovery evidence contract, not a generic URI scheme checker.
    No name resolution, fetching, decoding or connectivity claim is performed.
    """
    if not isinstance(value, str):
        return True
    if any(ord(character) <= 32 or ord(character) >= 127 for character in value):
        return False
    match = _HTTP_REFERENCE.fullmatch(value)
    if match is None:
        return False
    authority, path, query, fragment = match.groups()
    if not _valid_http_authority(authority) or (path and not path.startswith("/")):
        return False
    if re.fullmatch(rf"(?:{_URI_ATOM}|[:@/])*", path) is None:
        return False
    # Query and fragment permit literal question marks but retain strict escapes.
    return all(
        component is None
        or re.fullmatch(rf"(?:{_URI_ATOM}|[:@/?])*", component) is not None
        for component in (query, fragment)
    )


def discovery_format_checker() -> FormatChecker:
    """Install both required checkers locally without optional dependency extras."""
    try:
        from jsonschema import FormatChecker
    except ImportError as error:
        raise CatalogError(
            f"Required schema dependency unavailable: {error}"
        ) from error
    checker = FormatChecker(formats=())
    checker.checks("date-time")(is_rfc3339_timestamp)
    checker.checks("uri")(is_http_evidence_uri)
    return checker


class _Validator(Protocol):
    """Keep jsonschema's partly typed iterator behind a narrow structural seam."""

    def iter_errors(self, instance: object) -> Iterator[ValidationError]:
        """Yield complete schema errors without coercing the input document."""
        ...


@dataclass(frozen=True, kw_only=True)
class SchemaValidationResult:
    """Carry parsed input and immutable diagnostics for one trusted schema identity.

    Returned by validate_document; ok reports structural validity only. The v1
    compatibility flag is independent of success. No completion, approval, I/O or
    authority side effect is implied by constructing or inspecting this value.
    """

    document: JsonObject | None
    findings: tuple[Finding, ...]
    expected_kind: str
    expected_version: str

    @property
    def ok(self) -> bool:
        """Require a parsed document and no blocking findings for structural success."""
        # Any retained blocker, including truncation, prevents structural success.
        return self.document is not None and not any(
            finding.severity == "error" for finding in self.findings
        )

    @property
    def compatibility_only(self) -> bool:
        """Identify the frozen legacy reader independently of structural success."""
        return self.expected_version == "1.0.0"


def _validator(schema: dict[str, object], catalog: SchemaCatalog) -> _Validator:
    """Require real dependencies and explicit format support before validation."""
    try:
        from jsonschema import Draft202012Validator
    except ImportError as error:
        raise CatalogError(
            f"Required schema dependency unavailable: {error}"
        ) from error
    checker = discovery_format_checker()
    if not {"date-time", "uri"} <= set(checker.checkers):
        raise CatalogError(
            "Required date-time or HTTP evidence URI checker unavailable"
        )
    return cast(
        "_Validator",
        Draft202012Validator(
            schema,
            registry=catalog.registry(),
            format_checker=checker,
        ),
    )


def _header_errors(
    document: JsonObject,
    *,
    kind: str,
    version: str,
) -> tuple[tuple[str, str], ...]:
    """Bind normal artifacts and explicitly exceptional control envelopes exactly."""
    version_key = "result_version" if kind == "service-result" else "schema_version"
    problems: list[tuple[str, str]] = []
    if document.get(version_key) != version:
        problems.append((version_key, f"Expected exact {version_key} {version}"))
    # These two closed wire envelopes intentionally omit ordinary artifact headers.
    if version == "2.0.0" and kind in {"activation", "service-result"}:
        return tuple(problems)
    if document.get("$schema") not in schema_aliases(kind, version):
        problems.append(
            ("$schema", "Schema identifier does not match the trusted kind/version")
        )
    if version == "2.0.0" and document.get("artifact_kind") != kind:
        problems.append(("artifact_kind", f"Expected artifact_kind {kind}"))
    return tuple(problems)


def _add_schema_errors(
    value: object,
    schema: dict[str, object],
    catalog: SchemaCatalog,
    collector: FindingCollector,
    artifact_path: str | None,
    *,
    prefix: str = "",
) -> None:
    """Project library errors into bounded stable pointers and actionable findings."""
    try:
        # Stream findings into the finite collector rather than accumulating errors.
        for error in _validator(schema, catalog).iter_errors(value):
            pointer = prefix
            # Library paths contain unescaped keys; the wire requires RFC 6901.
            for part in error.absolute_path:
                pointer = child_pointer(pointer, part)
            collector.add(
                Finding(
                    code="SCHEMA_INVALID",
                    artifact_path=artifact_path,
                    pointer=pointer,
                    message=error.message,
                    next_action="Correct the field against the expected schema.",
                )
            )
    except RecursionError as error:
        raise CatalogError(
            "Schema evaluation exceeded the recursive evaluation limit; "
            "correct non-consuming references."
        ) from error


def validate_document(
    content: bytes | str,
    *,
    expected_kind: str,
    expected_version: str,
    format: Literal["json", "yaml"] = "json",
    artifact_path: str | None = None,
    catalog: SchemaCatalog | None = None,
    limits: ParseLimits | None = None,
) -> SchemaValidationResult:
    """Validate one expected document without allowing schema selection or retrieval.

    The trusted caller supplies kind/version and optional pinned extension bytes.
    Catalog/dependency failures remain blocking findings; there is no reduced mode.
    format selects JSON/YAML, artifact_path is diagnostic-only and limits bound
    parsing/findings. Invalid caller path/format raises ValueError. Default catalog
    loading reads installed resources; injected catalogs avoid that I/O. No writes
    occur. The immutable result never authorizes a later completion gate.
    """
    limits = limits or ParseLimits()
    parsed = parse_document(
        content, format=format, artifact_path=artifact_path, limits=limits
    )
    collector = FindingCollector(limit=limits.findings)
    # Preserve parser errors exactly; malformed input cannot reach schema evaluation.
    for finding in parsed.findings:
        collector.add(finding)
    if parsed.value is not None:
        try:
            catalog = catalog if catalog is not None else load_catalog()
            schema = catalog.schema(
                expected_kind=expected_kind, expected_version=expected_version
            )
            headers = _header_errors(
                parsed.value, kind=expected_kind, version=expected_version
            )
            # Identity errors name caller expectations before inspecting payload rules.
            for field, message in headers:
                collector.add(
                    Finding(
                        code="SCHEMA_IDENTITY",
                        artifact_path=artifact_path,
                        pointer=child_pointer("", field),
                        message=message,
                        next_action="Use the expected kind and supported version.",
                    )
                )
            # A mismatch must not select, probe or fall back to another schema.
            if not headers:
                _add_schema_errors(
                    to_plain_value(parsed.value),
                    schema,
                    catalog,
                    collector,
                    artifact_path,
                )
        except CatalogError as error:
            collector.add(
                Finding(
                    code="SCHEMA_UNAVAILABLE",
                    artifact_path=artifact_path,
                    message=str(error),
                    next_action="Restore the runtime and pinned local schema catalog.",
                )
            )
    return SchemaValidationResult(
        document=parsed.value,
        findings=collector.findings,
        expected_kind=expected_kind,
        expected_version=expected_version,
    )
