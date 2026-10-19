"""Project bounded local dependency syntax without install, restore or evaluation."""

from __future__ import annotations

from pathlib import PurePosixPath
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.dependency_dotnet import parse_dotnet_dependencies
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyCandidate,
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
)
from drm_copilot_discovery.analyzer.dependency_node import parse_node_dependencies
from drm_copilot_discovery.analyzer.dependency_python import parse_python_dependencies
from drm_copilot_discovery.analyzer.findings import (
    diagnostic,
    pinned_matches,
    row,
    source_reference,
    stable_id,
    tool,
)
from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture
from drm_copilot_discovery.models import JsonObject

if TYPE_CHECKING:
    from typing import Literal

    from drm_copilot_discovery.analyzer.models import InventoryInput
    from drm_copilot_discovery.repository_reader import RepositoryFile


def _format(path: str) -> str | None:
    """Select a finite format from path (captured relative str).

    Return str or None for irrelevant files; no errors, I/O or mutation expected.
    Exact known names precede requirements/project suffix rules.
    """
    name = PurePosixPath(path).name.lower()
    known = {
        "package.json": "package-json",
        "package-lock.json": "package-lock",
        "npm-shrinkwrap.json": "package-lock",
        "setup.cfg": "setup-cfg",
        "packages.config": "packages-config",
        "packages.lock.json": "packages-lock",
        "setup.py": "unsupported",
        "pyproject.toml": "unsupported",
        "poetry.lock": "unsupported",
        "yarn.lock": "unsupported",
        "pnpm-lock.yaml": "unsupported",
    }
    if name in known:
        return known[name]
    if name == "requirements.txt" or (
        name.startswith("requirements-") and name.endswith(".txt")
    ):
        return "requirements"
    if PurePosixPath(name).suffix in {
        ".csproj",
        ".vbproj",
        ".fsproj",
        ".proj",
        ".props",
        ".targets",
    }:
        return "project"
    return None


def _parse(content: bytes, format: str, limits: DependencyLimits) -> DependencyResult:
    """Dispatch content (bytes), format (str) and limits (DependencyLimits).

    Return DependencyResult; propagate fixed DependencyInputError for invalid or
    exhausted input. This thin pure wrapper never creates rows or performs I/O.
    """
    # Finite format groups select one public parser; no dynamic plugin lookup occurs.
    if format in {"package-json", "package-lock"}:
        return parse_node_dependencies(
            content,
            format=cast("Literal['package-json', 'package-lock']", format),
            limits=limits,
        )
    if format in {"requirements", "setup-cfg"}:
        return parse_python_dependencies(
            content,
            format=cast("Literal['requirements', 'setup-cfg']", format),
            limits=limits,
        )
    if format in {"project", "packages-config", "packages-lock"}:
        return parse_dotnet_dependencies(
            content,
            format=cast(
                "Literal['project', 'packages-config', 'packages-lock']", format
            ),
            limits=limits,
        )
    raise DependencyInputError("dependency-unsupported")


def _failure(code: str, path: str | None, *, blocking: bool = True) -> JsonObject:
    """Return a fixed diagnostic for code (str), path (str | None), blocking (bool).

    Produces JsonObject without raw parser messages, I/O or mutation; no expected
    exception occurs for adapter-selected codes and validated captured paths.
    """
    return diagnostic(
        code,
        path,
        "Inspect supported dependency declarations, captured provenance and limits; "
        "binding, applicability, installed state and execution remain unresolved.",
        analyzer="dependencies",
        blocking=blocking,
    )


def _metadata(candidate: DependencyCandidate) -> JsonObject:
    """Project candidate (DependencyCandidate) after its output reservation.

    Return immutable JsonObject extensions without evaluation, I/O, mutation or
    expected errors; requested/observed versions and unresolved binding stay distinct.
    """
    anchor = candidate.anchor
    return row(
        **{
            "drm.dependencies": row(
                ecosystem=candidate.ecosystem,
                role=candidate.role,
                operation=candidate.operation,
                package=candidate.name,
                version_kind=candidate.version.kind,
                version=candidate.version.value,
                requested_kind=candidate.requested.kind,
                requested=candidate.requested.value,
                owner=candidate.owner,
                condition_present=candidate.condition_present,
                extras=candidate.extras,
                marker_names=candidate.markers,
                anchor_format=anchor.format,
                anchor_container=anchor.location,
                occurrence=anchor.occurrence,
                binding="unresolved",
                activation="unresolved",
                execution="unverified",
                installed_state="unverified",
                graph="not-evaluated",
            )
        }
    )


def _candidate_cost(candidate: DependencyCandidate, source_cost: int) -> int:
    """Bound candidate (DependencyCandidate) plus source_cost (int bytes).

    Return a conservative serialized-row byte count before row construction.
    No I/O, mutation or expected exception; strings are already sanitized.
    """
    values = (
        candidate.kind,
        candidate.ecosystem,
        candidate.name,
        candidate.owner,
        candidate.role,
        candidate.operation,
        candidate.version.kind,
        candidate.version.value,
        candidate.requested.kind,
        candidate.requested.value,
        candidate.anchor.format,
        candidate.anchor.location,
        *candidate.extras,
        *candidate.markers,
    )
    # Twelve bytes per character cover escaped JSON; fixed keys/IDs have 4096 bytes.
    return (
        source_cost
        + 4096
        + 12 * sum(len(value) for value in values if value is not None)
    )


class _Run:
    """One private mutable projection run over an immutable InventoryCapture.

    Initialize a bounded pin index, inspect each selected file and collect inert
    rows. Independent counters limit input/pin bytes, parser work/text, full output
    bytes and row counts. One reserved blocker replaces every partial row on limit
    failure. No I/O, install/evaluation, global state or concurrent mutation occurs.
    """

    def __init__(self, capture: InventoryCapture) -> None:
        """Initialize from capture (InventoryCapture); return None.

        Mutate only new counters/collections. Raise DependencyInputError before
        exceeding pin count, bytes or path/index work; perform no source reads.
        """
        self.capture = capture
        self.rows = min(capture.profile.limits.artifact_records, 100000) - 1
        self.text = capture.profile.limits.document_bytes - 1024
        self.input_bytes = self.parser_text = capture.profile.limits.document_bytes
        self.work = min(capture.profile.limits.document_bytes, 2_000_000)
        self.maximum = min(capture.profile.analyzers.max_file_bytes, 67_108_864)
        self.pins: dict[str, list[RepositoryFile]] = {}
        self.components: list[JsonObject] = []
        self.findings: list[JsonObject] = []
        self.relationships: list[JsonObject] = []
        self.diagnostics: dict[tuple[str, str | None], JsonObject] = {}
        pin_bytes = capture.profile.limits.document_bytes
        if len(capture.repository_files) > capture.profile.limits.source_files:
            raise DependencyInputError("dependency-limit")
        # One retained-pin pass preserves duplicates while avoiding per-input rescans.
        for source in capture.repository_files:
            pin_bytes -= len(source.content)
            self.work -= (
                len(source.path)
                + len(source.repository.id)
                + len(source.repository.revision or "")
                + 1
            )
            if pin_bytes < 0 or self.work < 0:
                raise DependencyInputError("dependency-limit")
            self.pins.setdefault(source.path, []).append(source)

    def reserve(self, rows: int, text: int) -> None:
        """Reserve rows (int records) and text (int encoded bytes); return None.

        Mutate remaining counters only after both checks. Raise ValueError for
        invalid units or DependencyInputError on exhaustion; no I/O occurs.
        """
        if type(rows) is not int or type(text) is not int or rows < 0 or text < 0:
            raise ValueError(
                "Dependency projection reservations must be nonnegative integers"
            )
        if rows > self.rows or text > self.text:
            raise DependencyInputError("dependency-limit")
        self.rows -= rows
        self.text -= text

    def note(self, code: str, path: str | None, cost: int) -> None:
        """Record code (str) for path (str | None) after cost (int bytes) reservation.

        Return None; mutate only local deduplicated diagnostics/counters. Raise
        DependencyInputError on output exhaustion; no external effects occur.
        """
        key = (code, path)
        if key not in self.diagnostics:
            self.reserve(1, cost)
            self.diagnostics[key] = _failure(
                code,
                path,
                blocking=code
                not in {
                    "dependency-binding-unresolved",
                    "dependency-redacted",
                    "dependency-ambiguous",
                },
            )

    def parse(self, item: InventoryInput, format: str) -> DependencyResult:
        """Parse item (InventoryInput) selected by format (str) after reservation.

        Return DependencyResult; reserve input bytes plus four work units per
        allowed node, refund unused successful work and charge retained parser
        text separately. Fixed DependencyInputError rejects failures; no I/O occurs.
        """
        if item.file is None:
            raise DependencyInputError("dependency-malformed")
        size = len(item.file.content)
        if (
            size > min(self.maximum, self.input_bytes)
            or self.work < 1
            or self.parser_text < 1
        ):
            raise DependencyInputError("dependency-limit")
        self.input_bytes -= size
        # Reserve byte-scaled scanning plus the entire permitted node/index envelope.
        nodes = min(100000, (self.work - size) // 4)
        if nodes < 1:
            raise DependencyInputError("dependency-limit")
        work = size + 4 * nodes
        if work > self.work or self.rows < 1:
            raise DependencyInputError("dependency-limit")
        self.work -= work
        limits = DependencyLimits(
            max_bytes=min(self.maximum, self.input_bytes + size),
            max_nodes=nodes,
            max_depth=min(self.capture.profile.limits.nesting_depth, 128),
            max_candidates=min(self.rows, 100000),
            max_text_bytes=self.parser_text,
            max_lines=min(nodes, 100000),
        )
        result = _parse(item.file.content, format, limits)
        # Reject a parser contract violation before interpreting any returned fact.
        if (
            len(result.candidates) > limits.max_candidates
            or len(result.diagnostics) > limits.max_nodes
            or result.consumed_nodes > limits.max_nodes
            or result.consumed_text_bytes > limits.max_text_bytes
        ):
            raise DependencyInputError("dependency-limit")
        self.work += 4 * (nodes - result.consumed_nodes)
        self.parser_text -= result.consumed_text_bytes
        return result

    def inspect(self, item: InventoryInput, format: str) -> None:
        """Inspect item (InventoryInput) with format (str); return None.

        Reserve complete rows/diagnostics before allocating them; mutate only this
        run. Per-file parser errors become fixed diagnostics; aggregate exhaustion
        or invalid anchor contracts propagate DependencyInputError. No I/O occurs.
        """
        source_cost = 12 * (
            len(item.path)
            + len(self.capture.profile.repository.id)
            + len(self.capture.profile.repository.revision or "")
        )
        base_cost = 2048 + source_cost
        if item.file is None:
            self.note("input-unreadable", item.path, base_cost)
            return
        if format == "unsupported":
            self.note("dependency-unsupported", item.path, base_cost)
            return
        try:
            parsed = self.parse(item, format)
        except DependencyInputError as error:
            # Any aggregate limit discards the complete run, including prior files.
            if error.code == "dependency-limit":
                raise
            self.note(error.code, item.path, base_cost)
            return
        self.reserve(1, base_cost)
        local = InventoryCapture(
            profile=self.capture.profile,
            inputs=(item,),
            repository_files=tuple(self.pins.get(item.path, ())),
        )
        source, pinned = source_reference(local, item), pinned_matches(local, item)
        component_id = stable_id(
            "component",
            row(
                repository=source["repository"], path=item.path, analyzer="dependencies"
            ),
        )
        self.components.append(
            row(
                component_id=component_id,
                component_type="dependency-file",
                source=source,
                analyzer=tool("dependencies"),
                classification="detected",
                confidence="high" if pinned else "low",
                properties=(),
                extensions=row(),
            )
        )
        if not pinned:
            self.note("source-revision-unverified", item.path, base_cost)
        self.note("dependency-binding-unresolved", item.path, base_cost)
        # Parser diagnostics contain fixed codes only and share the full output budget.
        for code in parsed.diagnostics:
            self.note(code, item.path, base_cost)
        # Global within-file sequence avoids collisions across nested container anchors.
        for ordinal, candidate in enumerate(parsed.candidates, 1):
            if (
                candidate.anchor.occurrence > 1_000_000
                or (candidate.anchor.line or 0) > self.maximum + 1
            ):
                raise DependencyInputError("dependency-malformed")
            count = 2 if candidate.kind == "declared-lock-edge" else 1
            self.reserve(count, count * _candidate_cost(candidate, source_cost))
            anchor = source
            if candidate.anchor.line is not None:
                anchor = JsonObject(
                    source.members
                    + (
                        (
                            "line_range",
                            row(start=candidate.anchor.line, end=candidate.anchor.line),
                        ),
                    )
                )
            identity = row(
                component=component_id,
                ordinal=ordinal,
                kind=candidate.kind,
                container=candidate.anchor.location,
                occurrence=candidate.anchor.occurrence,
            )
            extension = _metadata(candidate)
            self.findings.append(
                row(
                    finding_id=stable_id("finding", identity),
                    component_id=component_id,
                    kind=candidate.kind,
                    source=anchor,
                    analyzer=tool("dependencies"),
                    classification="detected",
                    confidence="high" if pinned else "low",
                    properties=(),
                    extensions=extension,
                )
            )
            if candidate.kind == "declared-lock-edge":
                self.relationships.append(
                    row(
                        relationship_id=stable_id("relationship", identity),
                        from_component_id=component_id,
                        to_component_id=None,
                        target_description=candidate.name or "redacted-dependency",
                        kind="possible-dependency",
                        source=anchor,
                        analyzer=tool("dependencies"),
                        classification="inferred",
                        confidence="low",
                        extensions=extension,
                    )
                )


class DependencyAnalyzer:
    """Stateless finite dependency adapter identified by the constant dependencies.

    Call analyze with a retained capture to obtain immutable syntax/provenance
    rows. Each call owns independent budgets; detection never proves installed
    state, resolved graph, execution or coverage. No I/O or global mutation occurs.
    """

    identifier = "dependencies"

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Return bounded source-linked Analysis from capture (InventoryCapture).

        One fallback diagnostic slot and 1024 encoded bytes are reserved first.
        If even that envelope is unavailable, raise a fixed DependencyInputError
        rather than emit an over-budget error row. Invalid capture types raise
        ValueError. Only local counters mutate; no source reads or writes occur.
        """
        if not isinstance(cast("object", capture), InventoryCapture):
            raise ValueError(
                "Dependency analysis requires a validated immutable capture"
            )
        if (
            capture.profile.limits.artifact_records < 1
            or capture.profile.limits.document_bytes < 1024
        ):
            raise DependencyInputError("dependency-limit")
        try:
            state = _Run(capture)
            # Captured paths and exclusions select parsers, never payload contents.
            for item in capture.inputs:
                state.work -= len(item.path) + 1
                if state.work < 0:
                    raise DependencyInputError("dependency-limit")
                format = _format(item.path)
                if format is not None and item.status != "excluded":
                    state.inspect(item, format)
        except DependencyInputError as error:
            return Analysis(diagnostics=(_failure(error.code, None),))
        return Analysis(
            components=tuple(state.components),
            findings=tuple(state.findings),
            relationships=tuple(state.relationships),
            diagnostics=tuple(state.diagnostics.values()),
        )
