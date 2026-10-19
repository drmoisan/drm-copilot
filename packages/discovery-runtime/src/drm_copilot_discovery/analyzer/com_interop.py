"""Detect generic COM candidates from retained C# and secure project declarations.

No optional adapter, compiler, registry, activation or runtime path is consulted.
Public candidate functions return the existing Detection carrier for later reuse.
Arguments, GUID values, reference targets and raw conditions are never published.
"""

from __future__ import annotations

from pathlib import PurePosixPath
from typing import TYPE_CHECKING

from drm_copilot_discovery.analyzer.com_syntax import (
    com_source_candidates as com_source_candidates,
)
from drm_copilot_discovery.analyzer.csharp_tokens import (
    SourceScanError,
    decode_source,
)
from drm_copilot_discovery.analyzer.findings import (
    diagnostic,
    pinned_matches,
    row,
    source_reference,
    stable_id,
    tool,
)
from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture
from drm_copilot_discovery.analyzer.source_text import (
    Detection,
)
from drm_copilot_discovery.analyzer.xml_input import XmlInputError, parse_xml
from drm_copilot_discovery.models import JsonObject

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryInput
    from drm_copilot_discovery.repository_reader import RepositoryFile

_PROJECT_SUFFIXES = frozenset(".csproj .fsproj .vbproj .proj .props .targets".split())
_BUILD_NAMESPACE = "http://schemas.microsoft.com/developer/msbuild/2003"


def _local(tag: str) -> str:
    """Return str tag's local build name or raise XmlInputError; no I/O.

    Empty or the fixed MSBuild namespace is supported; foreign semantics fail closed.
    """
    if not tag.startswith("{"):
        return tag
    namespace, name = tag[1:].split("}", 1)
    if namespace != _BUILD_NAMESPACE:
        raise XmlInputError("xml-namespace", "COM build namespace is unsupported.")
    return name


def com_project_candidates(
    path: str,
    content: bytes,
    *,
    max_bytes: int = 67108864,
    max_elements: int = 100000,
    max_depth: int = 64,
    max_candidates: int = 100000,
) -> tuple[Detection, ...]:
    """Return value-free COM item declarations from str path and retained bytes.

    Positive int max_bytes/elements/depth default to 64 MiB/100000/64. The public
    secure XML parser rejects unsafe, malformed or over-budget input with
    XmlInputError; invalid limits raise ValueError. max_candidates (int, default
    100000, zero permitted) bounds results via SourceScanError. Duplicate/nonliteral
    EmbedInteropTypes is unresolved; literal booleans do not establish presence.
    No reference is followed and conditions are never evaluated.
    """
    if type(max_candidates) is not int or not 0 <= max_candidates <= 100000:
        raise ValueError("COM candidate limit must be between 0 and 100000")
    nodes = parse_xml(
        content, max_bytes=max_bytes, max_elements=max_elements, max_depth=max_depth
    )
    # Namespace-check every node before publishing any project declaration.
    names = tuple(_local(node.tag) for node in nodes)
    if names[0] != "Project":
        raise XmlInputError("xml-root", "COM declarations require a Project root.")
    conditional: list[bool] = []
    embedded: dict[int, list[str]] = {}
    metadata_conditions: set[int] = set()
    # Parent indexes precede children, so inherited condition presence is linear.
    for index, node in enumerate(nodes):
        conditional.append(
            node.attribute("Condition") is not None
            or (node.parent is not None and conditional[node.parent])
        )
        if names[index] == "EmbedInteropTypes" and node.parent is not None:
            value = node.text.strip().lower()
            embedded.setdefault(node.parent, []).append(
                value if value in {"true", "false"} else "unresolved"
            )
            if node.attribute("Condition") is not None:
                metadata_conditions.add(node.parent)
    results: list[Detection] = []
    # Keep duplicate item declarations independent, without retaining target text.
    for index, node in enumerate(nodes):
        if (
            names[index] not in {"COMReference", "COMFileReference"}
            or node.parent is None
            or names[node.parent] not in {"ItemGroup", "ItemDefinitionGroup"}
        ):
            continue
        if len(results) >= max_candidates:
            raise SourceScanError(
                "com-candidate-limit", "COM candidates exceed their limit."
            )
        # Multiple operations/metadata values are ambiguous rather than activated.
        operations = tuple(
            key.lower()
            for key in ("Include", "Update", "Remove")
            if node.attribute(key) is not None
        )
        values = embedded.get(index, [])
        results.append(
            Detection(
                path,
                node.line,
                (
                    "com_reference"
                    if names[index] == "COMReference"
                    else "com_file_reference"
                ),
                names[index],
                "project-item",
                (
                    ("ordinal", index),
                    ("end_line", node.line),
                    (
                        "operation",
                        operations[0] if len(operations) == 1 else "unresolved",
                    ),
                    (
                        "conditional",
                        (
                            "true"
                            if conditional[index] or index in metadata_conditions
                            else "false"
                        ),
                    ),
                    (
                        "embed_interop_types",
                        values[0] if len(values) == 1 else "unresolved",
                    ),
                    ("binding", "unresolved"),
                ),
            )
        )
    return tuple(results)


def _failure(code: str, path: str | None, *, blocking: bool = True) -> JsonObject:
    """Return a fixed diagnostic for str code/path, with bool blocking; pure.

    Parser/read exception details and source values are deliberately withheld.
    """
    return diagnostic(
        code,
        path,
        "Inspect the captured COM declarations and limits; aliases, preprocessing, "
        "conditions, binding and runtime execution remain unresolved. "
        "Argument values are withheld.",
        analyzer="com-interop",
        blocking=blocking,
    )


def _project(
    capture: InventoryCapture, item: InventoryInput, candidates: tuple[Detection, ...]
) -> Analysis:
    """Attach immutable source provenance to typed candidates; no I/O or mutation.

    capture/item provide retained bytes and pins. Return Analysis with inferred C#
    candidates or detected project declarations, never runtime proof. ValueError
    rejects unavailable sources. Candidate metadata contains no source values.
    """
    source = source_reference(capture, item)
    pinned = pinned_matches(capture, item)
    project = not item.path.lower().endswith(".cs")
    component_id = stable_id(
        "component",
        row(repository=source["repository"], path=item.path, analyzer="com-interop"),
    )
    component = row(
        component_id=component_id,
        component_type="com-source-file",
        source=source,
        analyzer=tool("com-interop"),
        classification="detected",
        confidence="high" if pinned else "low",
        properties=(),
        extensions=row(),
    )
    findings: list[JsonObject] = []
    # Candidate ordinal/offset preserves duplicate sites without including arguments.
    for candidate in candidates:
        metadata = dict(candidate.extra)
        anchor = JsonObject(
            source.members
            + (("line_range", row(start=candidate.line, end=metadata["end_line"])),)
        )
        identity = row(
            component=component_id,
            kind=candidate.detection_kind,
            symbol=candidate.symbol,
            site=metadata.get("offset", metadata.get("ordinal")),
        )
        findings.append(
            row(
                finding_id=stable_id("finding", identity),
                component_id=component_id,
                kind=candidate.detection_kind,
                source=anchor,
                analyzer=tool("com-interop"),
                classification="detected" if project else "inferred",
                confidence=("high" if project else "medium") if pinned else "low",
                properties=(
                    row(name="symbol", value=candidate.symbol),
                    row(name="symbol_kind", value=candidate.symbol_kind),
                ),
                extensions=row(
                    **{
                        "drm.com-interop": row(
                            **metadata, execution="unverified", applicability="windows"
                        )
                    }
                ),
            )
        )
    diagnostics = [_failure("com-binding-unresolved", item.path, blocking=False)]
    if not pinned:
        diagnostics.append(_failure("source-revision-unverified", item.path))
    return Analysis(
        components=(component,),
        findings=tuple(findings),
        diagnostics=tuple(diagnostics),
    )


class ComInteropAnalyzer:
    """Project bounded generic COM observations without optional modules or I/O.

    Each stateless call consumes immutable capture bytes; parsers are public pure
    seams. Input bytes, tokens/elements, aggregate output rows and encoded output
    are bounded independently. Aggregate exhaustion discards all partial output.
    """

    identifier = "com-interop"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return bounded Analysis for InventoryCapture without external effects.

        Per-file failures become sanitized diagnostics. document_bytes bounds both
        aggregate input work and a conservative output reservation before projection;
        artifact_records bounds rows. No profile analyzer-selection dependency exists.
        Retained pins have separate source_files/document_bytes count and byte caps.
        """
        components: list[JsonObject] = []
        findings: list[JsonObject] = []
        diagnostics: list[JsonObject] = []
        limit = min(capture.profile.limits.artifact_records, 100000)
        input_left = output_left = capture.profile.limits.document_bytes
        maximum = min(capture.profile.analyzers.max_file_bytes, 67108864)
        pin_bytes = input_left
        pins: dict[str, list[RepositoryFile]] = {}
        if len(capture.repository_files) > capture.profile.limits.source_files:
            return Analysis(diagnostics=(_failure("analysis-work-limit", None),))
        # Bound and index retained pins once, preserving every duplicate candidate.
        for source in capture.repository_files:
            pin_bytes -= len(source.content)
            if pin_bytes < 0:
                return Analysis(diagnostics=(_failure("analysis-work-limit", None),))
            pins.setdefault(source.path, []).append(source)
        # Capture ordering is authoritative; exclusions are checked before parsing.
        for item in capture.inputs:
            suffix = PurePosixPath(item.path).suffix.lower()
            if (
                suffix != ".cs"
                and suffix not in _PROJECT_SUFFIXES
                or item.status == "excluded"
            ):
                continue
            used = len(components) + len(findings) + len(diagnostics)
            if used >= limit:
                return Analysis(diagnostics=(_failure("analysis-limit", None),))
            # Reserve constant diagnostic rows and every repeated source identifier.
            unit_cost = 4096 + 12 * (
                len(item.path)
                + len(capture.profile.repository.id)
                + len(capture.profile.repository.revision or "")
            )
            if output_left < unit_cost:
                return Analysis(diagnostics=(_failure("analysis-text-limit", None),))
            output_left -= unit_cost
            if item.file is None:
                diagnostics.append(_failure("input-unreadable", item.path))
                continue
            if len(item.file.content) > input_left:
                return Analysis(diagnostics=(_failure("analysis-work-limit", None),))
            input_left -= len(item.file.content)
            # Keep the accepted exact-byte proof while avoiding full-capture rescans.
            local_capture = InventoryCapture(
                profile=capture.profile,
                inputs=(item,),
                repository_files=tuple(pins.get(item.path, ())),
            )
            # Reserve component/diagnostic rows before allocating any result candidates.
            base_rows = 2 + int(not pinned_matches(local_capture, item))
            records_left = limit - used - base_rows
            text_capacity = output_left // unit_cost - base_rows
            capacity = min(records_left, text_capacity)
            exhausted = (
                "analysis-limit"
                if records_left <= text_capacity
                else "analysis-text-limit"
            )
            if capacity < 0:
                return Analysis(diagnostics=(_failure(exhausted, None),))
            try:
                # C# uses masked tokens; project declarations use the secure XML seam.
                candidates = (
                    com_source_candidates(
                        item.path,
                        decode_source(item.file.content, max_bytes=maximum),
                        max_candidates=capacity,
                    )
                    if suffix == ".cs"
                    else com_project_candidates(
                        item.path,
                        item.file.content,
                        max_bytes=maximum,
                        max_elements=limit,
                        max_depth=min(capture.profile.limits.nesting_depth, 128),
                        max_candidates=capacity,
                    )
                )
            except (SourceScanError, XmlInputError) as error:
                if error.code == "com-candidate-limit":
                    return Analysis(diagnostics=(_failure(exhausted, None),))
                diagnostics.append(_failure(error.code, item.path))
                continue
            required = len(candidates) + base_rows
            output_left -= required * unit_cost
            projected = _project(local_capture, item, candidates)
            components.extend(projected.components)
            findings.extend(projected.findings)
            diagnostics.extend(projected.diagnostics)
        return Analysis(
            components=tuple(components),
            findings=tuple(findings),
            diagnostics=tuple(diagnostics),
        )
