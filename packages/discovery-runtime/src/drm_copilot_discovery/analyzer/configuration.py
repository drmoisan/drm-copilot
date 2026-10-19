"""Project key-only configuration observations from captured immutable inputs.

Supported JSON names are appsettings.json/appsettings.<qualifier>.json,
settings.json and config.json. XML selects .config/.settings or settings.xml/
configuration.xml; INI selects .ini. TOML is explicitly unsupported. Other names
are ignored. Findings describe declared presence, never evaluated values.
"""

from __future__ import annotations

from pathlib import PurePosixPath
from typing import TYPE_CHECKING, Literal

from drm_copilot_discovery.analyzer.configuration_input import (
    ConfigurationInputError,
    parse_configuration,
)
from drm_copilot_discovery.analyzer.findings import (
    diagnostic,
    pinned_matches,
    row,
    source_reference,
    stable_id,
    tool,
)
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.models import JsonObject

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.configuration_input import (
        ConfigurationFormat,
        ConfigurationKey,
    )
    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput


def _format(path: str) -> ConfigurationFormat | Literal["unsupported"] | None:
    """Select a fixed filename family from workspace-relative str path; no I/O.

    Return json/xml/ini, unsupported for TOML, or None for unrelated files. This
    lexical classification neither opens paths nor guesses from source values.
    """
    name = PurePosixPath(path).name.lower()
    # Specific JSON names avoid interpreting ordinary source/data fixtures as config.
    if name in {"appsettings.json", "settings.json", "config.json"} or (
        name.startswith("appsettings.") and name.endswith(".json") and len(name) > 17
    ):
        return "json"
    if name.endswith((".config", ".settings")) or name in {
        "settings.xml",
        "configuration.xml",
    }:
        return "xml"
    if name.endswith(".ini"):
        return "ini"
    if name.endswith(".toml"):
        return "unsupported"
    return None


def _project(
    capture: InventoryCapture,
    item: InventoryInput,
    format: ConfigurationFormat,
    keys: tuple[ConfigurationKey, ...],
) -> Analysis:
    """Attach captured-byte provenance to already sanitized declaration records.

    capture/item provide immutable source and pins; format is fixed; keys contain
    identifiers only. Return Analysis, with low confidence for unmatched pins.
    ValueError rejects unavailable source; no I/O, values or input mutation occur.
    """
    source = source_reference(capture, item)
    confidence = "high" if pinned_matches(capture, item) else "low"
    component_id = stable_id(
        "component",
        row(repository=source["repository"], path=item.path, analyzer="configuration"),
    )
    component = row(
        component_id=component_id,
        component_type="configuration-file",
        source=source,
        analyzer=tool("configuration"),
        classification="detected",
        confidence=confidence,
        properties=(row(name="format", value=format),),
        extensions=row(),
    )
    findings: list[JsonObject] = []
    # Identity excludes checksums, values, raw conditions and physical line changes.
    for key in keys:
        anchor = (
            source
            if key.line is None
            else JsonObject(
                source.members + (("line_range", row(start=key.line, end=key.line)),)
            )
        )
        identity = row(
            component=component_id, name=key.name, pointer=key.pointer, kind=key.kind
        )
        findings.append(
            row(
                finding_id=stable_id("finding", identity),
                component_id=component_id,
                kind=key.kind,
                source=anchor,
                analyzer=tool("configuration"),
                classification="detected",
                confidence=confidence,
                properties=(
                    row(name="key", value=key.name),
                    row(name="structural_path", value=key.pointer),
                ),
                extensions=row(
                    **{
                        "drm.configuration": row(
                            presence="unresolved",
                            conditional=key.conditional,
                            origin_pointer=key.origin_pointer,
                            anchor=(
                                "rfc6901"
                                if format == "json"
                                else (
                                    "element-line"
                                    if format == "xml"
                                    else "declaration-line"
                                )
                            ),
                        )
                    }
                ),
            )
        )
    diagnostics = [
        diagnostic(
            "configuration-presence-unresolved",
            item.path,
            "Values, conditions and effective configuration presence "
            "are not evaluated.",
            analyzer="configuration",
            blocking=False,
        )
    ]
    if confidence == "low":
        diagnostics.append(
            diagnostic(
                "source-revision-unverified",
                item.path,
                "Capture matching immutable source bytes before publishing "
                "configuration keys.",
                analyzer="configuration",
            )
        )
    return Analysis(
        components=(component,),
        findings=tuple(findings),
        diagnostics=tuple(diagnostics),
    )


def _failure(code: str, path: str | None) -> JsonObject:
    """Return a fixed diagnostic from constant code and captured path; no I/O.

    code (str) is selected by this adapter/parser; path (str | None) is provenance.
    Source values, read-error rationales and parser exceptions are never formatted.
    """
    return diagnostic(
        code,
        path,
        "Check the selected configuration against supported formats, syntax and "
        "limits; values and parser details are withheld.",
        analyzer="configuration",
    )


def _output_cost(
    capture: InventoryCapture,
    item: InventoryInput,
    keys: tuple[ConfigurationKey, ...] = (),
) -> int:
    """Return a conservative encoded-byte bound before constructing output rows.

    capture/item provide source identifiers; keys contain retained declarations.
    Twelve bytes per Unicode character cover compact UTF-8 JSON with either
    ensure_ascii setting, including surrogate-pair escapes. Each row reserves
    1024 additional bytes for fixed fields, IDs and numeric anchors; three base rows
    cover the component and both possible diagnostics. No I/O/allocation of rows.
    """
    source = (
        len(capture.profile.repository.id)
        + len(capture.profile.repository.revision or "")
        + len(item.path)
    )
    cost = 3 * (1024 + 12 * source)
    # Charge repeated provenance and every variable declaration field per finding.
    for key in keys:
        cost += 1024 + 12 * (
            source
            + len(key.name)
            + len(key.pointer)
            + len(key.kind)
            + len(key.origin_pointer or "")
        )
    return cost


class ConfigurationAnalyzer:
    """Inventory declared configuration keys without leaking or evaluating values.

    Each stateless call uses retained input bytes and fixed parsers. Individual
    failures preserve only constant diagnostic codes; aggregate overflow discards
    all partial output. This adapter performs no I/O, writes or optional imports.
    """

    identifier = "configuration"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return bounded Analysis from InventoryCapture; no source or state writes.

        Profile document_bytes bounds aggregate projected encoded text through a
        conservative reservation before each row batch. Parser text is separately
        bounded by the smaller file/remaining budget. Input failures become fixed
        diagnostics; aggregate overflow discards all rows. No values are returned.
        """
        components: list[JsonObject] = []
        findings: list[JsonObject] = []
        diagnostics: list[JsonObject] = []
        limit = min(capture.profile.limits.artifact_records, 100000)
        remaining_text = capture.profile.limits.document_bytes
        overflow = "analysis-limit"
        max_bytes = min(
            capture.profile.limits.document_bytes,
            capture.profile.analyzers.max_file_bytes,
            67108864,
        )
        # Selection is independent of payload contents; excluded input stays absent.
        for item in capture.inputs:
            format = _format(item.path)
            if format is None or item.status == "excluded":
                continue
            used = len(components) + len(findings) + len(diagnostics)
            if used >= limit:
                break
            base_cost = _output_cost(capture, item)
            if base_cost > remaining_text:
                overflow = "analysis-text-limit"
                break
            remaining_text -= base_cost
            if item.file is None:
                diagnostics.append(_failure("input-unreadable", item.path))
                continue
            if format == "unsupported":
                diagnostics.append(
                    _failure("configuration-unsupported-format", item.path)
                )
                continue
            try:
                keys = parse_configuration(
                    item.file.content,
                    format=format,
                    max_bytes=max_bytes,
                    max_keys=limit - used,
                    max_depth=capture.profile.limits.nesting_depth,
                    max_text_bytes=min(max_bytes, max(1, remaining_text)),
                )
            except ConfigurationInputError as error:
                # Text exhaustion invalidates the whole aggregate, not one file.
                if error.code == "configuration-text-limit":
                    overflow = "analysis-text-limit"
                    break
                diagnostics.append(_failure(error.code, item.path))
                continue
            if used + len(keys) + 2 + int(not pinned_matches(capture, item)) > limit:
                break
            extra_cost = _output_cost(capture, item, keys) - base_cost
            if extra_cost > remaining_text:
                overflow = "analysis-text-limit"
                break
            remaining_text -= extra_cost
            result = _project(capture, item, format, keys)
            components.extend(result.components)
            findings.extend(result.findings)
            diagnostics.extend(result.diagnostics)
        else:
            return Analysis(
                components=tuple(components),
                findings=tuple(findings),
                diagnostics=tuple(diagnostics),
            )
        return Analysis(diagnostics=(_failure(overflow, None),))
