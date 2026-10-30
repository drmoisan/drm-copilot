"""Extract bounded .NET dependency declarations without evaluating build semantics.

Only retained bytes enter secure XML/JSON parsers. Shared collectors sanitize
selected values before exposing candidates; no paths, imports or restores run.
"""

from __future__ import annotations

from typing import Literal, cast

from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyAnchor,
    DependencyBudget,
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
)
from drm_copilot_discovery.analyzer.xml_input import XmlInputError, XmlNode, parse_xml
from drm_copilot_discovery.models import JsonObject, JsonValue, ParseLimits
from drm_copilot_discovery.parsing import parse_document

DotnetDependencyFormat = Literal["project", "packages-config", "packages-lock"]
_NAMESPACE = "{http://schemas.microsoft.com/developer/msbuild/2003}"
_PROJECT_CONTEXTS = frozenset(
    {"Project", "Target", "Choose", "When", "Otherwise", "ItemGroup"}
)
_PACKAGE_ELEMENTS = frozenset({"PackageReference", "PackageVersion"})
_VERSION_ELEMENTS = frozenset({"Version", "VersionOverride"})


def _name(tag: str, *, project: bool) -> str:
    """Return the supported XML local name, rejecting foreign namespace semantics.

    tag (str) is a Clark name; project (bool) permits the MSBuild namespace.
    Returns str; raises fixed DependencyInputError for foreign names. No effects.
    """
    if tag.startswith("{"):
        if not project or not tag.startswith(_NAMESPACE):
            raise DependencyInputError("dependency-unsupported")
        return tag[len(_NAMESPACE) :]
    return tag


def _xml_candidate(
    budget: DependencyBudget,
    node: XmlNode,
    index: int,
    *,
    name: str,
    role: str,
    version: str | None,
    operation: str,
    conditional: bool,
) -> None:
    """Append one literal declaration using a closed tag anchor and shared sanitizer.

    budget (DependencyBudget) receives the row; node (XmlNode), index (int), name,
    role, operation (str), version (str | None), conditional (bool) describe syntax.
    Returns None; fixed DependencyInputError rejects limits. Mutates budget only.
    """
    budget.add(
        kind="declaration",
        ecosystem="dotnet",
        name=name,
        version=version,
        role=role,
        operation=operation,
        condition_present=conditional,
        anchor=DependencyAnchor("xml", role, index + 1, node.line),
    )


def _project_names(nodes: tuple[XmlNode, ...]) -> tuple[str, ...]:
    """Mask opaque ancestor subtrees before interpreting package-shaped payloads.

    nodes (tuple[XmlNode, ...]) has document-ordered parents and caller-reserved
    capacity. Returns one str name per node, with empty names for opaque content.
    DependencyInputError rejects foreign namespaces in supported contexts. Uses
    bounded local storage only; payload namespaces/values are never interpreted.
    """
    names: list[str] = []
    # Parent masks prevent nested Project/ItemGroup names from reactivating data.
    for node in nodes:
        parent = names[node.parent] if node.parent is not None else None
        if parent is not None and parent not in _PROJECT_CONTEXTS | _PACKAGE_ELEMENTS:
            names.append("")
            continue
        name = _name(node.tag, project=True)
        # Packages allow only direct version metadata; arbitrary task/data trees stop.
        if parent in _PACKAGE_ELEMENTS:
            names.append(name if name in _VERSION_ELEMENTS else "")
        else:
            names.append(name if name in _PROJECT_CONTEXTS | _PACKAGE_ELEMENTS else "")
    return tuple(names)


def _project(
    nodes: tuple[XmlNode, ...], budget: DependencyBudget, names: tuple[str, ...]
) -> None:
    """Extract package operations and distinct metadata without choosing precedence.

    nodes (tuple[XmlNode, ...]) and names (tuple[str, ...]) are bounded parsed XML;
    budget (DependencyBudget) receives sanitized candidates. Returns None; raises
    fixed DependencyInputError for invalid declarations or exhaustion. No I/O.
    """
    budget.reserve(nodes=2 * len(nodes))
    children: dict[int, list[int]] = {}
    conditions: list[bool] = []
    # Index parents once; inherited condition presence never evaluates their text.
    for index, node in enumerate(nodes):
        conditions.append(
            node.attribute("Condition") is not None
            or (node.parent is not None and conditions[node.parent])
        )
        if node.parent is not None:
            children.setdefault(node.parent, []).append(index)
    # Package declarations remain individual occurrences, including repeated updates.
    for index, node in enumerate(nodes):
        role = names[index]
        if role not in {"PackageReference", "PackageVersion"}:
            continue
        if node.parent is None or names[node.parent] != "ItemGroup":
            raise DependencyInputError("dependency-unsupported")
        # Exactly one operation avoids inventing precedence between conflicting forms.
        operations = [
            (operation.lower(), value)
            for operation in ("Include", "Update", "Remove")
            if (value := node.attribute(operation)) is not None
        ]
        if len(operations) != 1 or not operations[0][1].strip():
            raise DependencyInputError("dependency-malformed")
        operation, package = operations[0]
        version = node.attribute("Version")
        _xml_candidate(
            budget,
            node,
            index,
            name=package,
            role=role,
            version=version,
            operation=operation,
            conditional=conditions[index],
        )
        versions = int(version is not None)
        # Preserve overrides separately without choosing effective values.
        override = node.attribute("VersionOverride")
        if override is not None:
            versions += 1
            _xml_candidate(
                budget,
                node,
                index,
                name=package,
                role="VersionOverride",
                version=override,
                operation=operation,
                conditional=conditions[index],
            )
        # Direct metadata has its own real tag anchor and inherited condition presence.
        for child_index in children.get(index, ()):
            budget.reserve(nodes=1)
            child = nodes[child_index]
            child_role = names[child_index]
            if child_role not in {"Version", "VersionOverride"}:
                continue
            if children.get(child_index):
                raise DependencyInputError("dependency-unsupported")
            versions += 1
            _xml_candidate(
                budget,
                child,
                child_index,
                name=package,
                role=child_role,
                version=child.text.strip(),
                operation=operation,
                conditional=conditions[child_index],
            )
        if versions > 1:
            budget.note("dependency-ambiguous")


def _xml(content: bytes, *, project: bool, budget: DependencyBudget) -> None:
    """Validate a secure XML tree and route its finite declaration grammar.

    content (bytes), project (bool), budget (DependencyBudget) select retained XML
    and limits. Returns None; fixed DependencyInputError replaces parser errors.
    Mutates budget only; no external access or partial result publication.
    """
    limits = budget.limits
    try:
        nodes = parse_xml(
            content,
            max_bytes=min(limits.max_bytes, 67_108_864),
            max_elements=min(limits.max_nodes, 100_000),
            max_depth=min(limits.max_depth, 128),
        )
    except XmlInputError as error:
        code = (
            "dependency-limit" if error.code == "xml-limit" else "dependency-malformed"
        )
        raise DependencyInputError(code) from None
    budget.reserve(nodes=len(nodes))
    # Opaque project data is masked before its descendants gain declaration semantics.
    names = (
        _project_names(nodes)
        if project
        else tuple(_name(node.tag, project=False) for node in nodes)
    )
    if names[0] != ("Project" if project else "packages"):
        raise DependencyInputError("dependency-malformed")
    if project:
        _project(nodes, budget, names)
        return
    # packages.config has one flat package list; nested pseudo-packages are invalid.
    for index, node in enumerate(nodes[1:], 1):
        if names[index] != "package" or node.parent != 0:
            raise DependencyInputError("dependency-unsupported")
        name = node.attribute("id")
        if name is None or not name.strip():
            raise DependencyInputError("dependency-malformed")
        _xml_candidate(
            budget,
            node,
            index,
            name=name,
            role="package",
            version=node.attribute("version"),
            operation="reference",
            conditional=node.attribute("Condition") is not None,
        )


def _object(value: JsonValue) -> JsonObject:
    """Require a JSON mapping rather than coercing unsupported lock structures.

    value (JsonValue) is parsed data. Returns JsonObject or raises fixed
    DependencyInputError; performs no mutation or I/O.
    """
    if not isinstance(value, JsonObject):
        raise DependencyInputError("dependency-malformed")
    return value


def _text(value: JsonValue) -> str | None:
    """Require optional textual version syntax before the shared sanitizer sees it.

    value (JsonValue) returns str or None; other types raise fixed
    DependencyInputError. No coercion, mutation or I/O occurs.
    """
    if value is not None and not isinstance(value, str):
        raise DependencyInputError("dependency-malformed")
    return value


def _charge(value: JsonValue, budget: DependencyBudget) -> None:
    """Charge normalized JSON traversal before extracting candidates or indexes.

    value (JsonValue) passed the bounded parser; budget (DependencyBudget) counts
    values and mapping keys. Returns None; fixed limit error propagates. Mutates
    budget only, recursing within the accepted parser's depth ceiling.
    """
    budget.reserve(nodes=1)
    if isinstance(value, JsonObject):
        budget.reserve(nodes=len(value))
        # Account even ignored metadata so large unused structures cannot evade bounds.
        for child in value.values():
            _charge(child, budget)
    elif isinstance(value, tuple):
        # Charge ignored array contents as part of the input work budget.
        for child in value:
            _charge(child, budget)


def _lock(content: bytes, budget: DependencyBudget) -> None:
    """Extract NuGet v1 locked records and declared edges without resolving targets.

    content (bytes) and budget (DependencyBudget) supply immutable JSON and finite
    limits. Returns None; fixed DependencyInputError rejects malformed, unsupported
    or excessive input. Mutates budget only; raw parser findings never escape.
    """
    limits = budget.limits
    # The accepted parser expands at most64 nodes per structural record; round down.
    if limits.max_nodes < 64:
        raise DependencyInputError("dependency-limit")
    parsed = parse_document(
        content,
        format="json",
        limits=ParseLimits(
            document_bytes=min(limits.max_bytes, 67_108_864),
            nesting_depth=min(limits.max_depth, 128),
            artifact_records=min(limits.max_nodes // 64, 1_000_000),
        ),
    )
    if parsed.value is None:
        # Translate fixed categories without copying messages or source text.
        codes = {finding.code for finding in parsed.findings}
        code = (
            "dependency-limit"
            if codes
            & {"DOCUMENT_BYTES", "DOCUMENT_DEPTH", "DOCUMENT_RECORDS", "DOCUMENT_NODES"}
            else "dependency-malformed"
        )
        raise DependencyInputError(code)
    root = parsed.value
    _charge(root, budget)
    if type(root.get("version")) is not int or root.get("version") != 1:
        raise DependencyInputError("dependency-unsupported")
    frameworks = _object(root.get("dependencies"))
    occurrence = 0
    # Canonical member order is deterministic, without claiming physical locations.
    for packages in frameworks.values():
        # Each framework retains its own declarations without target activation.
        for name, value in _object(packages).items():
            record = _object(value)
            role = record.get("type")
            if role not in ("Direct", "Transitive", "Project"):
                raise DependencyInputError("dependency-unsupported")
            occurrence += 1
            budget.add(
                kind="locked-package",
                ecosystem="dotnet",
                name=name,
                version=_text(record.get("resolved")),
                requested=_text(record.get("requested")),
                role=cast("str", role),
                anchor=DependencyAnchor("json", "/dependencies", occurrence),
            )
            # Retain declared owner spellings without resolving package records.
            for target, version in _object(
                record.get("dependencies", JsonObject(()))
            ).items():
                occurrence += 1
                budget.add(
                    kind="declared-lock-edge",
                    ecosystem="dotnet",
                    name=target,
                    version=_text(version),
                    role="dependency",
                    owner=name,
                    anchor=DependencyAnchor("json", "/dependencies", occurrence),
                )


def parse_dotnet_dependencies(
    content: bytes, *, format: DotnetDependencyFormat, limits: DependencyLimits
) -> DependencyResult:
    """Parse explicit .NET formats into sanitized immutable declaration candidates.

    content (bytes) is retained UTF-8; format (DotnetDependencyFormat) selects
    project, packages-config or packages-lock. limits (DependencyLimits) bounds
    bytes, lines, tree work and output. Returns DependencyResult. Fixed
    DependencyInputError rejects input/bounds; ValueError rejects caller misuse.
    Performs no I/O, evaluation, import following, or mutation of supplied data.
    """
    if format not in {"project", "packages-config", "packages-lock"}:
        raise ValueError("Unsupported .NET dependency format")
    budget = DependencyBudget(limits)
    budget.decode(content)
    # Explicit selection determines the grammar without executing input values.
    if format == "packages-lock":
        _lock(content, budget)
    else:
        _xml(content, project=format == "project", budget=budget)
    return budget.result()
