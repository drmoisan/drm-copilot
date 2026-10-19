"""Read finite npm declarations without evaluating installation or resolution.

Only the four dependency maps and lock/shrinkwrap v2/v3 packages records are
selected. The v2 compatibility tree is ignored. Closed JSON container anchors
and normalized occurrence order never disclose package-location keys. Links,
aliases, workspaces and unsupported values remain explicitly unresolved.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyAnchor,
    DependencyBudget,
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
    safe_identifier,
)
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.parsing import parse_document

if TYPE_CHECKING:
    from drm_copilot_discovery.models import JsonValue

_GROUPS = (
    "dependencies",
    "devDependencies",
    "optionalDependencies",
    "peerDependencies",
)
_LIMIT_CODES = frozenset(
    {
        "DOCUMENT_BYTES",
        "DOCUMENT_DEPTH",
        "DOCUMENT_RECORDS",
        "DOCUMENT_NODES",
        "FINDINGS_LIMIT",
    }
)


def _fields(value: JsonValue, budget: DependencyBudget) -> dict[str, JsonValue]:
    """Index one immutable object after reserving its member work; return a dict.

    JsonValue value is normalized JSON; DependencyBudget budget tracks private
    extraction work. Returns a str-keyed copy retaining normalized member order.
    Raises DependencyInputError for nonobjects or exhausted limits. Only the
    returned index and budget change; the source remains immutable.
    """
    if not isinstance(value, JsonObject):
        raise DependencyInputError("dependency-malformed")
    budget.reserve(nodes=1 + len(value.members))
    return dict(value.members)


def _text(value: JsonValue, *, nullable: bool = True) -> str | None:
    """Accept a str or permitted null; return unchanged text without allocation.

    JsonValue value and bool nullable determine shape only. Raises a fixed
    DependencyInputError for wrong types; no mutation, logging or I/O.
    """
    if isinstance(value, str) or (nullable and value is None):
        return value
    raise DependencyInputError("dependency-malformed")


def _location_name(location: str, budget: DependencyBudget) -> str | None:
    """Read a bounded node_modules location spelling, never resolve its target.

    Str location is private source text; budget reserves split traversal and four
    UTF-8 bytes per character before allocation. Returns a safe terminal name or
    None. Limit errors propagate; no raw path reaches candidates or diagnostics.
    """
    budget.reserve(nodes=1 + location.count("/"), text_bytes=4 * len(location))
    parts = location.split("/")
    position = 0
    name: str | None = None
    # Every segment must belong to the finite package-location grammar.
    while position < len(parts):
        if parts[position] != "node_modules" or position + 1 >= len(parts):
            return None
        position += 1
        name = parts[position]
        position += 1
        # Scoped names consume exactly two literal components.
        if name.startswith("@"):
            if position >= len(parts):
                return None
            name += "/" + parts[position]
            position += 1
        if safe_identifier(name, ecosystem="node") is None:
            return None
    return name


class _NodeParser:
    """Collect ordered, sanitized syntax using one private shared budget.

    Construct with a validated DependencyBudget; maps reads selected declarations
    and lock reads packages without following links or resolving targets. The
    ordinal counts emitted declarations in normalized member order. Only this
    instance/budget changes; no source reads, rows, IDs or provenance are created.
    """

    def __init__(self, budget: DependencyBudget) -> None:
        """Bind DependencyBudget budget and zero ordinal; return None.

        The caller supplies a validated private budget. No additional errors are
        raised, and only this instance is initialized.
        """
        self.budget = budget
        self.ordinal = 0

    def maps(
        self,
        fields: dict[str, JsonValue],
        *,
        owner: str | None,
        locked: bool,
        within_lock: bool = False,
    ) -> None:
        """Collect fixed dependency groups; return None or raise a fixed input error.

        dict[str, JsonValue] fields is an already reserved index. str | None owner
        is a raw optional name; bool locked selects declared-lock-edge versus
        declaration, and bool within_lock identifies root declarations nested
        under packages. Shared add reserves every retained string/candidate.
        DependencyInputError rejects malformed values or exhausted budgets.
        Mutates only this collector and its budget.
        """
        # Preserve group declarations independently; no effective precedence is chosen.
        for group in _GROUPS:
            if group not in fields:
                continue
            members = _fields(fields[group], self.budget)
            # Normalized object order fixes occurrences without source-line claims.
            for name, value in members.items():
                version = _text(value, nullable=False)
                self.ordinal += 1
                self.budget.add(
                    kind="declared-lock-edge" if locked else "declaration",
                    ecosystem="node",
                    name=name,
                    version=None if locked else version,
                    requested=version if locked else None,
                    owner=owner,
                    role=group,
                    anchor=DependencyAnchor(
                        "json",
                        "/packages" if locked or within_lock else "/" + group,
                        self.ordinal,
                    ),
                )

    def lock(self, fields: dict[str, JsonValue]) -> None:
        """Collect root maps and package records from a reserved lockfile index.

        dict[str, JsonValue] fields contains normalized JSON. Returns None;
        unsupported versions, exhausted budgets and invalid selected structures
        raise fixed DependencyInputError. Only this collector/budget changes;
        compatibility trees and location targets stay inert.
        """
        version = fields.get("lockfileVersion")
        if version is None:
            raise DependencyInputError("dependency-unsupported")
        if type(version) is not int:
            raise DependencyInputError("dependency-malformed")
        if version not in (2, 3):
            raise DependencyInputError("dependency-unsupported")
        packages = _fields(fields.get("packages"), self.budget)
        # Only packages is authoritative here; the v2 compatibility tree is omitted.
        for location, value in packages.items():
            package = _fields(value, self.budget)
            explicit_name = _text(package.get("name"))
            # The empty location describes the root's direct declarations, not itself.
            if location == "":
                self.maps(package, owner=explicit_name, locked=False, within_lock=True)
                continue
            name = _location_name(location, self.budget)
            if name is None:
                self.budget.note("dependency-redacted")
            # Conflicting literal names cannot establish an alias or owner identity.
            if explicit_name is not None:
                selected_name = safe_identifier(explicit_name, ecosystem="node")
                if (
                    name is not None
                    and selected_name is not None
                    and name != selected_name
                ):
                    self.budget.note("dependency-ambiguous")
                    name = None
                else:
                    name = explicit_name
            link = package.get("link", False)
            if type(link) is not bool:
                raise DependencyInputError("dependency-malformed")
            self.ordinal += 1
            self.budget.add(
                kind="locked-package",
                ecosystem="node",
                name=name,
                version=None if link else _text(package.get("version")),
                role="link" if link else "packages",
                anchor=DependencyAnchor("json", "/packages", self.ordinal),
            )
            # A declared link is recorded without reading or evaluating its target.
            if link:
                self.budget.note("dependency-unsupported")
            else:
                self.maps(package, owner=name, locked=True)


def parse_node_dependencies(
    content: bytes,
    *,
    format: Literal["package-json", "package-lock"],
    limits: DependencyLimits,
) -> DependencyResult:
    """Return immutable npm declaration candidates from retained bytes and limits.

    Args:
        content: Captured bytes containing strict UTF-8 JSON, optionally with BOM.
        format: Literal package-json or package-lock grammar, never a path. The
            package-lock selector also accepts npm-shrinkwrap versions 2 and 3.
        limits: DependencyLimits bounding input bytes/physical lines, normalized
            nodes/depth, extraction work, candidate count and retained text.

    Returns:
        DependencyResult containing immutable sanitized candidates, fixed
        diagnostic codes and consumed extraction-node/text-byte counters.

    Raises:
        ValueError: A public argument has the wrong type or unsupported selector.
        DependencyInputError: Encoding, selected shape, version or resource
            validation fails. Messages remain fixed and no partial result escapes.

    Existing JSON hard ceilings are 64MiB/128 levels/1000000 records;
    records=max_nodes//64 conservatively bounds expanded normalization nodes.
    Source-token preflight retains the accepted parser's separate 2x envelope.
    Normalization and extraction reserve independent node budgets. Closed source
    containers and canonical ordinals never assert physical JSON lines. The call
    is pure: it performs no I/O, evaluation, logging or caller mutation.
    """
    if not isinstance(cast("object", format), str) or format not in {
        "package-json",
        "package-lock",
    }:
        raise ValueError("Unsupported Node dependency format selector")
    budget = DependencyBudget(limits)
    if not isinstance(cast("object", content), bytes):
        raise ValueError("Node dependencies require retained bytes")
    if limits.max_nodes < 64 or len(content) > min(limits.max_bytes, 67108864):
        raise DependencyInputError("dependency-limit")
    text = budget.decode(content)
    parsed = parse_document(
        text,
        format="json",
        limits=ParseLimits(
            document_bytes=min(limits.max_bytes, 67108864),
            nesting_depth=min(limits.max_depth, 128),
            artifact_records=min(limits.max_nodes // 64, 1000000),
        ),
    )
    if parsed.value is None:
        # Classify only fixed codes; parser messages and unsafe pointers are withheld.
        codes = {item.code for item in parsed.findings}
        code = (
            "dependency-limit"
            if codes & _LIMIT_CODES
            else (
                "dependency-encoding"
                if "DOCUMENT_ENCODING" in codes
                else "dependency-malformed"
            )
        )
        raise DependencyInputError(code)
    fields = _fields(parsed.value, budget)
    parser = _NodeParser(budget)
    # Select declared syntax by explicit format, never by executing manifest fields.
    if format == "package-lock":
        parser.lock(fields)
    else:
        # Unsupported dependency controls remain visible as one fixed limitation.
        if any(
            key in fields
            for key in (
                "workspaces",
                "overrides",
                "resolutions",
                "bundledDependencies",
                "bundleDependencies",
            )
        ):
            budget.note("dependency-unsupported")
        parser.maps(fields, owner=_text(fields.get("name")), locked=False)
    budget.note("dependency-binding-unresolved")
    return budget.result()
