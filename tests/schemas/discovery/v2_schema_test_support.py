"""Share offline v2 fixture loading and typed schema validation across tests."""

from __future__ import annotations

import calendar
import json
import re
from datetime import date, timedelta
from ipaddress import IPv6Address
from pathlib import Path
from typing import TYPE_CHECKING, Protocol, cast

import yaml
from jsonschema import Draft202012Validator, FormatChecker
from referencing import Registry, Resource
from referencing.jsonschema import DRAFT202012, Schema

if TYPE_CHECKING:
    from collections.abc import Iterator

    from jsonschema.exceptions import ValidationError

ROOT = Path(__file__).resolve().parents[3]
SCHEMAS = ROOT / "schemas/discovery/v2"
URN = "urn:drm-copilot:discovery:2.0.0:"
KINDS = ("common", "domain-profile", "scope")
PIN = "a" * 40
HASH = "c" * 64
_TIMESTAMP = re.compile(
    r"([0-9]{4})-([0-9]{2})-([0-9]{2})[Tt]"
    r"([0-9]{2}):([0-9]{2}):([0-9]{2})(?:\.[0-9]+)?"
    r"([Zz]|[+-][0-9]{2}:[0-9]{2})"
)
_URI_ATOM = r"(?:[A-Za-z0-9._~!$&'()*+,;=-]|%[0-9A-Fa-f]{2})"
_HTTP_REFERENCE = re.compile(r"(?i:https?)://([^/?#]*)([^?#]*)(?:\?([^#]*))?(?:#(.*))?")
# Positive insertion dates from the public-domain IANA leap-seconds.list.
# This fixed offline set must be updated when IERS announces another insertion.
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
    year, month, day, hour, minute, second = (int(part) for part in match.groups()[:6])
    zone = match.group(7)
    if not 1 <= month <= 12 or not 1 <= day <= calendar.monthrange(year, month)[1]:
        return False
    if hour > 23 or minute > 59 or second > 60:
        return False
    offset = 0
    if zone not in ("Z", "z"):
        zone_hour, zone_minute = int(zone[1:3]), int(zone[4:6])
        if zone_hour > 23 or zone_minute > 59:
            return False
        offset = (zone_hour * 60 + zone_minute) * (1 if zone[0] == "+" else -1)
    if second < 60:
        return True
    # UTC minute placement is checked separately from Python's second<=59 API.
    if not 1972 <= year <= 2017:
        return False
    day_shift, utc_minute = divmod(hour * 60 + minute - offset, 1440)
    utc_date = date(year, month, day) + timedelta(days=day_shift)
    return utc_minute == 1439 and utc_date.isoformat() in _LEAP_SECOND_DATES


def _valid_http_authority(authority: str) -> bool:
    """Validate RFC 3986 authority with the HTTP nonempty-host requirement."""
    if "@" in authority:
        userinfo, _, authority = authority.rpartition("@")
        if re.fullmatch(rf"(?:{_URI_ATOM}|:)*", userinfo) is None:
            return False
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
    """Check descriptive HTTP(S) references, not generic URI scheme semantics.

    RFC 3986 sections 2/3 and RFC 9110 section 4.2 define this local contract.
    No DNS resolution, fetching, decoding or connectivity claim is performed.
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
    return all(
        component is None
        or re.fullmatch(rf"(?:{_URI_ATOM}|[:@/?])*", component) is not None
        for component in (query, fragment)
    )


def observation_format_checker() -> FormatChecker:
    """Register both required checkers on an isolated schema-test instance.

    The v2 uri keyword is currently used only for HTTP(S) evidence references.
    This test-only wiring must not be reused as a generic URI format library.
    """
    checker = FormatChecker(formats=())
    checker.checks("date-time")(is_rfc3339_timestamp)
    checker.checks("uri")(is_http_evidence_uri)
    return checker


class SchemaValidator(Protocol):
    """Type the library's error iterator without exposing its unknown overload."""

    def iter_errors(self, instance: object) -> Iterator[ValidationError]:
        """Validate test input, including intentionally invalid JSON value types."""
        ...


def as_object(value: object) -> dict[str, object]:
    """Narrow parsed fixture objects without leaking untyped library values."""
    assert isinstance(value, dict)
    return cast("dict[str, object]", value)


def load_schema(kind: str) -> dict[str, object]:
    """Read one canonical schema independently of the process working directory."""
    return as_object(json.loads((SCHEMAS / f"{kind}.schema.json").read_text("utf-8")))


def load_fixture(kind: str, *, invalid: bool = False) -> dict[str, object]:
    """Load immutable YAML fixture bytes into a fresh test-local object."""
    folder = (
        "tests/fixtures/discovery_schemas/v2" if invalid else "examples/discovery/v2"
    )
    suffix = "invalid" if invalid else "example"
    return as_object(
        yaml.safe_load((ROOT / folder / f"{kind}.{suffix}.yaml").read_text("utf-8"))
    )


def schema_validator(kind: str, definition: str | None = None) -> SchemaValidator:
    """Resolve committed schema resources offline with explicit format validation."""
    registry = Registry[Schema]().with_resources(
        (
            URN + path.name.removesuffix(".schema.json"),
            Resource[Schema].from_contents(
                load_schema(path.name.removesuffix(".schema.json")),
                default_specification=DRAFT202012,
            ),
        )
        for path in sorted(SCHEMAS.glob("*.schema.json"))
    )
    schema = (
        load_schema(kind)
        if definition is None
        else {"$ref": f"{URN}common#/$defs/{definition}"}
    )
    return cast(
        "SchemaValidator",
        Draft202012Validator(
            schema, registry=registry, format_checker=observation_format_checker()
        ),
    )


def schema_errors(
    kind: str, value: object, definition: str | None = None
) -> list[ValidationError]:
    """Return actionable schema diagnostics while keeping assertions local."""
    return list(schema_validator(kind, definition).iter_errors(value))


def profile_client(profile: dict[str, object], index: int = 0) -> dict[str, object]:
    """Select a client from a freshly loaded profile for one test mutation."""
    return as_object(cast("list[object]", profile["clients"])[index])
