"""Inventory literal .NET build declarations from bounded, retained source bytes.

No MSBuild expression, import, SDK, wildcard, project path, or dependency is
evaluated. Relationships describe declared text with unresolved target bindings.
The adapter is pure; registration and workspace publication belong to callers.
"""

from __future__ import annotations

from pathlib import PurePosixPath
from typing import TYPE_CHECKING

from drm_copilot_discovery.analyzer.findings import (
    diagnostic,
    pinned_matches,
    row,
    source_reference,
    stable_id,
    tool,
)
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.analyzer.solution_input import (
    SolutionInputError,
    parse_solution,
)
from drm_copilot_discovery.analyzer.xml_input import XmlInputError, XmlNode, parse_xml
from drm_copilot_discovery.models import JsonObject

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput

_XML_SUFFIXES = frozenset(
    ".slnx .csproj .fsproj .vbproj .vcxproj .proj .props .targets".split()
)
_BUILD_NAMESPACE = "http://schemas.microsoft.com/developer/msbuild/2003"
_KINDS = {
    "ProjectReference": "project-reference",
    "PackageReference": "package-reference",
    "Reference": "assembly-reference",
    "COMReference": "com-reference",
    "COMFileReference": "com-file-reference",
    "Import": "import",
    "Sdk": "sdk",
    "TargetFramework": "target-framework",
    "TargetFrameworks": "target-frameworks",
    "TargetFrameworkVersion": "target-framework-version",
    "TargetFrameworkProfile": "target-framework-profile",
}
_ATTRIBUTES = frozenset(
    (
        "Name Path Include Update Remove Exclude Version VersionOverride "
        "Sdk Project ToolsVersion"
    ).split()
)
_METADATA = frozenset(
    (
        "Version VersionOverride Guid VersionMajor VersionMinor Lcid WrapperTool "
        "EmbedInteropTypes Aliases Private HintPath"
    ).split()
)


def _local(tag: str) -> str:
    """Return local name for a supported tag (str); reject foreign namespaces.

    Raises XmlInputError instead of silently discarding foreign declarations.
    Returns str; performs no I/O or input mutation.
    """
    # Foreign namespaces must not silently inherit MSBuild declaration semantics.
    if tag.startswith("{"):
        namespace, name = tag[1:].split("}", 1)
        if namespace != _BUILD_NAMESPACE:
            raise XmlInputError("xml-namespace", "XML namespace is not supported.")
        return name
    return tag


def _context(nodes: tuple[XmlNode, ...], index: int) -> tuple[JsonObject, ...]:
    """Retain enclosing declaration contexts in root-to-leaf order without evaluation.

    nodes (tuple[XmlNode, ...]) and index (int) come from parse_xml. Returns immutable
    context rows containing literal conditions and target/branch placement. Raises
    IndexError for invalid internal indexes; no I/O or input mutation occurs.
    """
    result: list[JsonObject] = []
    current: int | None = index
    # Ancestors establish syntactic scope, never truth or active build membership.
    while current is not None:
        node = nodes[current]
        result.append(
            row(
                element=_local(node.tag),
                line=node.line,
                condition=node.attribute("Condition"),
                name=node.attribute("Name"),
            )
        )
        current = node.parent
    return tuple(reversed(result))


def _declaration(
    kind: str,
    line: int,
    ordinal: int,
    properties: tuple[JsonObject, ...],
    context: tuple[JsonObject, ...],
    target: str | None = None,
) -> JsonObject:
    """Freeze a literal declaration for later provenance projection; pure.

    kind (str), line/ordinal (int), properties/context (tuple[JsonObject, ...]),
    target (str | None) are parser-derived fields. Returns JsonObject. Invalid JSON
    raises ValueError; no source or target path is opened or evaluated.
    """
    return row(
        kind=kind,
        line=line,
        ordinal=ordinal,
        properties=properties,
        context=context,
        target=target,
    )


def _xml_declarations(
    content: bytes,
    suffix: str,
    *,
    max_bytes: int,
    limit: int,
) -> tuple[JsonObject, ...]:
    """Extract bounded literal build/solution declarations and enclosing conditions.

    content (bytes) and suffix (str) select the grammar; max_bytes/limit (int) bound
    XML and output allocations. Returns tuple[JsonObject, ...]. XmlInputError rejects
    malformed, unsafe, unsupported, or over-budget input without partial output.
    No imports, SDKs, expressions, or project references are followed.
    """
    nodes = parse_xml(content, max_bytes=max_bytes, max_elements=limit)
    expected = "Solution" if suffix == ".slnx" else "Project"
    # File suffix selects the root grammar; names alone do not establish a project.
    if _local(nodes[0].tag) != expected:
        raise XmlInputError("xml-root", f"Expected a {expected} XML root.")
    results: list[JsonObject] = []
    # Index direct children once; metadata extraction stays linear in input size.
    children: dict[int, list[XmlNode]] = {}
    for node in nodes:
        _local(node.tag)
        if node.parent is not None:
            children.setdefault(node.parent, []).append(node)
    # Preserve duplicate declarations and their source order instead of merging them.
    for index, node in enumerate(nodes):
        name = _local(node.tag)
        kind = _KINDS.get(name) if expected == "Project" else None
        # Preserve syntax family while leaving all activation conditions unresolved.
        if index == 0:
            kind = "solution" if expected == "Solution" else "project"
        elif expected == "Solution" and name in {"Project", "Folder"}:
            kind = "solution-project" if name == "Project" else "solution-folder"
        if kind is None:
            continue
        # Retain only declaration metadata, excluding arbitrary executable task data.
        properties = tuple(
            row(name=key.lower(), value=value)
            for key, value in node.attributes
            if key in _ATTRIBUTES
        )
        if name.startswith("TargetFramework"):
            properties += (row(name="value", value=node.text.strip()),)
        # Repeated metadata remains ordered and receives its own context/line anchor.
        metadata = tuple(
            row(
                element=_local(child.tag),
                text=child.text,
                line=child.line,
                condition=child.attribute("Condition"),
            )
            for child in children.get(index, ())
            if _local(child.tag) in _METADATA
        )
        context = _context(nodes, index)
        context += (row(metadata=metadata),)
        # Select literal operation text only; parent/foreign paths remain inert.
        target = next(
            (
                node.attribute(key)
                for key in ("Include", "Update", "Remove", "Project", "Path", "Name")
                if node.attribute(key)
            ),
            None,
        )
        if kind in {"project", "solution", "solution-folder"} or name.startswith(
            "TargetFramework"
        ):
            target = None
        # Blank target metadata cannot satisfy the nonblank relationship contract.
        if target is not None and not target.strip():
            raise XmlInputError("build-declaration", "Declared target text is blank.")
        if (
            index == 0
            and node.attribute("Sdk") is not None
            and not (node.attribute("Sdk") or "").strip()
        ):
            raise XmlInputError("build-declaration", "Declared SDK text is blank.")
        required = 1 + int(index == 0 and bool(node.attribute("Sdk")))
        if len(results) + required > limit:
            raise XmlInputError(
                "declaration-limit", "Build declarations exceed their limit."
            )
        results.append(
            _declaration(kind, node.line, index, properties, context, target)
        )
        if index == 0 and node.attribute("Sdk"):
            results.append(
                _declaration(
                    "implicit-sdk",
                    node.line,
                    -1,
                    (row(name="sdk", value=node.attribute("Sdk")),),
                    context,
                    node.attribute("Sdk"),
                )
            )
    return tuple(results)


def _solution_declarations(
    content: bytes, *, max_bytes: int, limit: int
) -> tuple[JsonObject, ...]:
    """Read bounded .sln declarations with literal paths/GUIDs and line anchors.

    content (bytes) is retained source; max_bytes/limit (int) bound bytes/rows.
    Returns tuple[JsonObject, ...]. SolutionInputError rejects malformed or bounded
    input. Does not resolve solution folders or paths; no I/O or mutation.
    """
    # The parser retains literal GUIDs; projection never binds their meaning.
    return tuple(
        _declaration(
            "solution-entry",
            entry.line,
            entry.line,
            (
                row(name="type", value=entry.project_type),
                row(name="name", value=entry.name),
                row(name="path", value=entry.path),
                row(name="id", value=entry.project_id),
            ),
            (),
            entry.path,
        )
        for entry in parse_solution(content, max_bytes=max_bytes, max_entries=limit)
    )


def _project_rows(
    capture: InventoryCapture,
    item: InventoryInput,
    declarations: tuple[JsonObject, ...],
) -> Analysis:
    """Attach exact immutable source provenance to one successfully parsed file.

    capture/item (InventoryCapture/InventoryInput) supply bytes and pin proof;
    declarations (tuple[JsonObject, ...]) supplies literal syntax. Returns Analysis
    with unresolved relationships, never activated dependencies. Missing source
    bytes raise ValueError; performs no I/O or input mutation.
    """
    source = source_reference(capture, item)
    confidence = "high" if pinned_matches(capture, item) else "low"
    component_id = stable_id(
        "component",
        row(repository=source["repository"], path=item.path, analyzer="dotnet"),
    )
    component = row(
        component_id=component_id,
        component_type="dotnet-build-file",
        source=source,
        analyzer=tool("dotnet"),
        classification="detected",
        confidence=confidence,
        properties=(row(name="format", value=PurePosixPath(item.path).suffix.lower()),),
        extensions=row(**{"drm.dotnet": row(evaluation="not-performed")}),
    )
    findings: list[JsonObject] = []
    relationships: list[JsonObject] = []
    # Every declaration retains its parser anchor; no complete span is fabricated.
    for declaration in declarations:
        anchor = JsonObject(
            source.members
            + (("line_range", row(start=declaration["line"], end=declaration["line"])),)
        )
        identity = row(component=component_id, declaration=declaration)
        extension = row(
            **{
                "drm.dotnet": row(
                    evaluation="not-performed",
                    binding="unresolved",
                    context=declaration["context"],
                    declaration=declaration["properties"],
                    ordinal=declaration["ordinal"],
                    anchor="parser-line",
                )
            }
        )
        findings.append(
            row(
                finding_id=stable_id("finding", identity),
                component_id=component_id,
                kind=declaration["kind"],
                source=anchor,
                analyzer=tool("dotnet"),
                classification="detected",
                confidence=confidence,
                properties=declaration["properties"],
                extensions=extension,
            )
        )
        if declaration["target"] is not None:
            relationships.append(
                row(
                    relationship_id=stable_id("relationship", identity),
                    from_component_id=component_id,
                    to_component_id=None,
                    target_description=declaration["target"],
                    kind=declaration["kind"],
                    source=anchor,
                    analyzer=tool("dotnet"),
                    classification="detected",
                    confidence=confidence,
                    extensions=extension,
                )
            )
    diagnostics = [
        diagnostic(
            "build-evaluation-not-performed",
            item.path,
            "Conditions, imports, SDK activation and dependency targets "
            "remain unevaluated.",
            analyzer="dotnet",
            blocking=False,
        )
    ]
    # Syntax can be detected even when immutable repository provenance is missing.
    if confidence == "low":
        diagnostics.append(
            diagnostic(
                "source-revision-unverified",
                item.path,
                "Capture matching immutable repository bytes "
                "before publishing declarations.",
                analyzer="dotnet",
            )
        )
    return Analysis(
        components=(component,),
        findings=tuple(findings),
        relationships=tuple(relationships),
        diagnostics=tuple(diagnostics),
    )


def _overflow() -> Analysis:
    """Return one blocking limit diagnostic, discarding partial analysis results.

    Takes no arguments. Returns Analysis without I/O or mutation.
    """
    return Analysis(
        diagnostics=(
            diagnostic(
                "analysis-limit",
                None,
                "Build analysis exceeds its record limit; increase it or narrow scope.",
                analyzer="dotnet",
            ),
        )
    )


class DotnetProjectAnalyzer:
    """Describe captured .NET declarations while preserving unresolved semantics.

    Stateless calls allocate bounded private results and never read or write paths.
    The fixed identifier is consumed directly until public registration is enabled.
    """

    identifier = "dotnet"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return literal build facts and actionable failures from retained inputs.

        capture (InventoryCapture) supplies validated profile limits, inputs and
        immutable pins. Returns Analysis. Parser errors become diagnostics; result
        overflow returns one blocking diagnostic, discarding partial detections.
        Performs no I/O or input mutation and does not load optional adapters.
        """
        components: list[JsonObject] = []
        findings: list[JsonObject] = []
        relationships: list[JsonObject] = []
        diagnostics: list[JsonObject] = []
        limit = min(capture.profile.limits.artifact_records, 100000)
        max_bytes = min(capture.profile.analyzers.max_file_bytes, 67108864)
        # Unavailable matching inputs remain explicit; capture already sorts files.
        for item in capture.inputs:
            suffix = PurePosixPath(item.path).suffix.lower()
            if (
                suffix not in _XML_SUFFIXES
                and suffix != ".sln"
                or item.status == "excluded"
            ):
                continue
            used = sum(map(len, (components, findings, relationships, diagnostics)))
            if used >= limit:
                return _overflow()
            if item.file is None:
                diagnostics.append(
                    diagnostic(
                        "input-unreadable",
                        item.path,
                        item.rationale or "Build input unavailable.",
                        analyzer="dotnet",
                    )
                )
            else:
                try:
                    if len(item.file.content) > max_bytes:
                        raise XmlInputError(
                            "input-limit", "Build input exceeds its byte limit."
                        )
                    declarations = (
                        _solution_declarations(
                            item.file.content, max_bytes=max_bytes, limit=limit
                        )
                        if suffix == ".sln"
                        else _xml_declarations(
                            item.file.content, suffix, max_bytes=max_bytes, limit=limit
                        )
                    )
                    # Bound projected rows before allocating source-rich values.
                    required = (
                        2 + int(not pinned_matches(capture, item)) + len(declarations)
                    )
                    required += sum(
                        value["target"] is not None for value in declarations
                    )
                    if used + required > limit:
                        return _overflow()
                    parsed = _project_rows(capture, item, declarations)
                except (XmlInputError, SolutionInputError) as exc:
                    diagnostics.append(
                        diagnostic(exc.code, item.path, str(exc), analyzer="dotnet")
                    )
                else:
                    components.extend(parsed.components)
                    findings.extend(parsed.findings)
                    relationships.extend(parsed.relationships)
                    diagnostics.extend(parsed.diagnostics)
        return Analysis(
            components=tuple(components),
            findings=tuple(findings),
            relationships=tuple(relationships),
            diagnostics=tuple(diagnostics),
        )
