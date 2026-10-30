"""Describe declared project references and bounded, inferred C# test relevance.

Configured test roots alone establish test scope; production/entrypoint ownership
has precedence. Only construction and typeof/default/sizeof type contexts are
matched by literal terminal spelling. Namespace, alias, shadowing, generic,
partial and nested identities remain unresolved. Declarations, variable types,
static calls and target-typed construction are not inferred test references.
No compiler, project evaluation, execution, behavioral coverage or I/O is used.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING

from drm_copilot_discovery.analyzer.csharp_declarations import declaration_candidates
from drm_copilot_discovery.analyzer.csharp_tokens import (
    SourceScanError,
    decode_source,
    tokenize_csharp,
)
from drm_copilot_discovery.analyzer.findings import (
    diagnostic,
    row,
    source_reference,
    stable_id,
    tool,
)
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.analyzer.source_text import strip_comments_and_strings
from drm_copilot_discovery.analyzer.test_reference_syntax import (
    project_reference_sites,
    type_mentions,
)
from drm_copilot_discovery.analyzer.xml_input import XmlInputError
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.snapshot_io import within_roots

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
    from drm_copilot_discovery.profile_v2 import ProfileV2

_IDENTIFIER = "test-references"
_PROJECTS = (".csproj", ".fsproj", ".vbproj")


@dataclass
class _TypeIndex:
    """Bound retained production names independently from output projection.

    Construct per analysis with record/encoded-text budgets. add reserves before
    inserting a literal name; values stores occurrence counts, never bindings.
    Twelve bytes per character and 64 bytes per entry conservatively reserve
    serialized name text/overhead. Only this private index changes; no I/O.
    """

    records: int
    encoded_bytes: int
    values: dict[str, int] = field(default_factory=dict[str, int])

    def add(self, name: str) -> None:
        """Reserve one str name occurrence; return None or raise SourceScanError.

        Existing keys need no additional text allocation. Mutates this index only;
        failures occur before dictionary insertion or counter updates.
        """
        cost = 0 if name in self.values else 64 + 12 * len(name)
        if self.records < 1 or cost > self.encoded_bytes:
            raise SourceScanError("analysis-work-limit", "Type index limit")
        self.records -= 1
        self.encoded_bytes -= cost
        self.values[name] = self.values.get(name, 0) + 1


def _failure(code: str, path: str | None, *, blocking: bool = True) -> JsonObject:
    """Return a fixed diagnostic for str code/optional path and bool blocking.

    Returns immutable JsonObject; raw read/parser messages and conditions are
    withheld. No I/O, caller mutation or source-derived message interpolation.
    """
    return diagnostic(
        code,
        path,
        "Inspect configured scope, retained syntax and exact source pins; "
        "binding and execution remain unresolved.",
        analyzer=_IDENTIFIER,
        blocking=blocking,
    )


@dataclass
class _Output:
    """Reserve complete output before projecting source-rich immutable rows.

    records/encoded_bytes are independent remaining limits. Lists are private to
    one analysis. Each reservation covers compact UTF-8 JSON with either
    ensure_ascii setting: twelve bytes per character include astral escapes;
    4096 bytes per row cover fixed fields, identifiers and numeric anchors.
    Only this builder mutates; no publication or caller mutation occurs.
    """

    records: int
    encoded_bytes: int
    components: list[JsonObject] = field(default_factory=list[JsonObject])
    findings: list[JsonObject] = field(default_factory=list[JsonObject])
    relationships: list[JsonObject] = field(default_factory=list[JsonObject])
    diagnostics: list[JsonObject] = field(default_factory=list[JsonObject])

    def reserve(
        self,
        capture: InventoryCapture,
        item: InventoryInput,
        count: int,
        characters: int = 0,
    ) -> None:
        """Reserve int count rows and extra character copies before allocation.

        capture/item supply repeated source metadata. Returns None; raises
        SourceScanError on aggregate overflow. Changes this budget only.
        """
        source = (
            len(item.path)
            + len(capture.profile.repository.id)
            + len(capture.profile.repository.revision or "")
        )
        cost = 4096 * count + 12 * (count * 2 * source + characters)
        if count > self.records or cost > self.encoded_bytes:
            raise SourceScanError("analysis-work-limit", "Output limit")
        self.records -= count
        self.encoded_bytes -= cost

    def component(self, capture: InventoryCapture, item: InventoryInput) -> str:
        """Add one detected file component; return its private analyzer identity.

        capture/item contain inspected bytes. Raises ValueError for absent bytes
        or SourceScanError before over-budget projection. Mutates this builder.
        """
        self.reserve(capture, item, 1)
        source = source_reference(capture, item)
        identity = stable_id(
            "component",
            row(repository=source["repository"], path=item.path, analyzer=_IDENTIFIER),
        )
        self.components.append(
            row(
                component_id=identity,
                component_type="test-reference-input",
                source=source,
                analyzer=tool(_IDENTIFIER),
                classification="detected",
                confidence="high",
                properties=(),
                extensions=row(),
            )
        )
        return identity

    def site(
        self,
        capture: InventoryCapture,
        item: InventoryInput,
        component: str,
        *,
        name: str,
        line: int,
        ordinal: int,
        kind: str,
        classification: str,
        metadata: JsonObject,
        relationship: bool,
    ) -> None:
        """Project one bounded declaration/mention and optional inferred relation.

        Typed capture/item and str component/name/kind/classification identify the
        source; int anchors, JsonObject metadata and bool relationship describe
        syntax. Returns None; SourceScanError prevents excessive rows/text. Every
        target remains null; this builder alone changes, without I/O.
        """
        self.reserve(capture, item, 1 + int(relationship), 4 * len(name))
        source = source_reference(capture, item)
        anchor = JsonObject(
            source.members
            + (("line_range", row(start=line, end=line)), ("symbol", name))
        )
        identity = row(component=component, kind=kind, ordinal=ordinal)
        extension = row(**{"drm.test-references": metadata})
        self.findings.append(
            row(
                finding_id=stable_id("finding", identity),
                component_id=component,
                kind=kind,
                source=anchor,
                analyzer=tool(_IDENTIFIER),
                classification=classification,
                confidence="high" if classification == "detected" else "medium",
                properties=(row(name="name", value=name),),
                extensions=extension,
            )
        )
        if relationship:
            self.relationships.append(
                row(
                    relationship_id=stable_id("relationship", identity),
                    from_component_id=component,
                    to_component_id=None,
                    target_description=name,
                    kind="test-relevance",
                    source=anchor,
                    analyzer=tool(_IDENTIFIER),
                    classification="inferred",
                    confidence="medium",
                    extensions=extension,
                )
            )


def _role(path: str, profile: ProfileV2) -> str | None:
    """Classify a relative str path using explicit ProfileV2 ownership; pure.

    Returns production/test or None. Production/entrypoint precedence prevents
    overlap from becoming test evidence; unrelated formats are not selected.
    """
    production = (
        within_roots(path, profile.production_roots)
        or path in profile.project_entry_points
    )
    # Project declarations are selected only from explicit, non-production tests.
    if production:
        return "production" if path.lower().endswith(".cs") else None
    if within_roots(path, profile.test_roots) and path.lower().endswith(
        (".cs", *_PROJECTS)
    ):
        return "test"
    return None


def _selected(
    capture: InventoryCapture, limit: int
) -> tuple[tuple[InventoryInput, str], ...]:
    """Classify retained inputs once under a prospective aggregate work bound.

    capture supplies typed roots/paths; int limit bounds selected pairs. Returns
    immutable input/role pairs or raises SourceScanError before excess matching
    or allocation. Scope-work units count selector visits and prospective copied/
    compared characters; document_bytes supplies an independent numeric ceiling,
    not a measured byte count. No source reads or caller mutation occur.
    """
    groups = (
        capture.profile.production_roots,
        capture.profile.test_roots,
        capture.profile.project_entry_points,
    )
    # Bound selector traversal before summing retained root lengths.
    selectors = sum(len(roots) for roots in groups)
    remaining = capture.profile.limits.document_bytes
    if selectors > remaining:
        raise SourceScanError("analysis-work-limit", "Scope selector limit")
    # Repeated prefix construction and comparison must consume aggregate work.
    characters = sum(len(root) for roots in groups for root in roots)
    remaining -= selectors + characters
    if remaining < 0:
        raise SourceScanError("analysis-work-limit", "Scope character limit")
    selected: list[tuple[InventoryInput, str]] = []
    # Reserve matching work before classification; excluded inputs remain opaque.
    for item in capture.inputs:
        if item.status == "excluded":
            continue
        cost = (2 * selectors + 4) * (len(item.path) + 1) + characters
        if cost > remaining:
            raise SourceScanError("analysis-work-limit", "Scope matching limit")
        remaining -= cost
        role = _role(item.path, capture.profile)
        if role is not None:
            if len(selected) >= limit:
                raise SourceScanError("analysis-work-limit", "Selected input limit")
            selected.append((item, role))
    return tuple(selected)


def _pinned(capture: InventoryCapture) -> frozenset[str]:
    """Index exact matching pins once; return immutable verified input paths.

    InventoryCapture supplies typed retained bytes. Independent pin count/byte
    budgets include unused, duplicate and foreign objects. Raises SourceScanError
    before indexing excess input; no hashes, source rereads or caller mutation.
    """
    if len(capture.repository_files) > capture.profile.limits.source_files:
        raise SourceScanError("analysis-work-limit", "Pin count limit")
    # Retain references rather than copying payloads or scanning pins per file.
    inputs = {item.path: item.file for item in capture.inputs if item.file is not None}
    remaining = capture.profile.limits.document_bytes
    matched: set[str] = set()
    # Charge every pin before lookup, preserving later valid duplicate semantics.
    for source in capture.repository_files:
        remaining -= len(source.content)
        if remaining < 0:
            raise SourceScanError("analysis-work-limit", "Pin byte limit")
        if (
            source.repository.id != capture.profile.repository.id
            or source.repository.revision != capture.profile.repository.revision
            or source.path in matched
        ):
            continue
        candidate = inputs.get(source.path)
        if candidate is not None and candidate.content == source.content:
            matched.add(source.path)
    return frozenset(matched)


class TestReferenceAnalyzer:
    """Project captured test relevance without compiler or execution claims.

    Each analyze call builds one bounded production name index before test scans.
    File, pin, scope-work, index, selected-byte and output budgets are independent.
    A global overflow discards all claims; individual syntax/provenance failures
    retain fixed diagnostics. The stateless adapter never publishes or mutates.
    """

    identifier = _IDENTIFIER

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return immutable Analysis from validated InventoryCapture bytes and pins.

        Literal production names and project declarations are detected; matching
        test names and every relation are inferred. Selected unavailable/unpinned
        files produce diagnostics without claims. Global overflow returns only a
        fixed blocker. No source reads, source changes or optional imports occur.
        """
        limit = min(capture.profile.limits.artifact_records, 100000)
        max_bytes = min(capture.profile.analyzers.max_file_bytes, 67108864)
        output = _Output(limit, capture.profile.limits.document_bytes)
        names = _TypeIndex(limit, capture.profile.limits.document_bytes)
        input_bytes = capture.profile.limits.document_bytes
        try:
            selected = _selected(capture, limit)
            verified = _pinned(capture)
            # Production must populate the index before any test-context match.
            for role in ("production", "test"):
                # Sorted capture order fixes identities and diagnostics across hosts.
                for item, selected_role in selected:
                    if selected_role != role:
                        continue
                    if item.file is None or item.path not in verified:
                        output.reserve(capture, item, 1)
                        output.diagnostics.append(
                            _failure(
                                (
                                    "input-unreadable"
                                    if item.file is None
                                    else "source-revision-unverified"
                                ),
                                item.path,
                            )
                        )
                        continue
                    input_bytes -= len(item.file.content)
                    if input_bytes < 0:
                        raise SourceScanError("analysis-work-limit", "Input byte limit")
                    try:
                        self._file(capture, item, role, names, output, max_bytes, limit)
                    except (SourceScanError, XmlInputError) as error:
                        if error.code == "analysis-work-limit":
                            raise
                        output.reserve(capture, item, 1)
                        output.diagnostics.append(_failure(error.code, item.path))
        except SourceScanError:
            return Analysis(diagnostics=(_failure("analysis-work-limit", None),))
        return Analysis(
            components=tuple(output.components),
            findings=tuple(output.findings),
            relationships=tuple(output.relationships),
            diagnostics=tuple(output.diagnostics),
        )

    def _file(
        self,
        capture: InventoryCapture,
        item: InventoryInput,
        role: str,
        names: _TypeIndex,
        output: _Output,
        max_bytes: int,
        limit: int,
    ) -> None:
        """Parse one inspected input and append reserved rows to private output.

        Typed capture/item supply bytes, role selects production/test; names is the
        bounded _TypeIndex, output the builder, max_bytes/limit int bounds.
        Returns None; parser/SourceScanError prevents unsupported claims. No I/O.
        """
        if item.file is None:
            raise ValueError("Inspected source bytes required")
        content = item.file.content
        metadata = row(binding="unresolved", execution="unverified")
        # Parse completely before constructing file rows so syntax errors stay inert.
        if item.path.lower().endswith(".cs"):
            text = decode_source(content, max_bytes=max_bytes)
            declarations = (
                declaration_candidates(
                    item.path, text, include_members=False, max_tokens=limit
                )
                if role == "production"
                else ()
            )
            tokens = (
                tokenize_csharp(strip_comments_and_strings(text), max_tokens=limit)
                if role == "test"
                else ()
            )
            component = output.component(capture, item)
            # Each type spelling is an observed declaration, not a bound type identity.
            for declaration in declarations:
                if declaration.detection_kind != "type":
                    continue
                names.add(declaration.symbol)
                output.site(
                    capture,
                    item,
                    component,
                    name=declaration.symbol,
                    line=declaration.line,
                    ordinal=int(dict(declaration.extra)["offset"]),
                    kind="production-type-declaration",
                    classification="detected",
                    metadata=metadata,
                    relationship=False,
                )
            # One mention produces one unresolved relation, never a Cartesian match set.
            for token in type_mentions(tokens, names.values):
                output.site(
                    capture,
                    item,
                    component,
                    name=token.value,
                    line=token.line,
                    ordinal=token.start,
                    kind="test-type-mention",
                    classification="inferred",
                    metadata=row(
                        binding="unresolved",
                        execution="unverified",
                        candidate_count=names.values[token.value],
                        ambiguity=(
                            "multiple-declarations"
                            if names.values[token.value] > 1
                            else "unique-lexical-name"
                        ),
                        offset=token.start,
                    ),
                    relationship=True,
                )
        else:
            sites = tuple(
                project_reference_sites(content, max_bytes=max_bytes, limit=limit)
            )
            component = output.component(capture, item)
            # Conditions and operation kinds remain declarations, not activated edges.
            for target, line, ordinal, operation, target_kind, conditional in sites:
                output.site(
                    capture,
                    item,
                    component,
                    name=target,
                    line=line,
                    ordinal=ordinal,
                    kind="test-project-reference-declaration",
                    classification="detected",
                    metadata=row(
                        binding="unresolved",
                        execution="unverified",
                        operation=operation,
                        target_kind=target_kind,
                        conditional=conditional,
                        activation="unresolved",
                    ),
                    relationship=True,
                )
        output.reserve(capture, item, 1)
        output.diagnostics.append(
            _failure("test-binding-unresolved", item.path, blocking=False)
        )
