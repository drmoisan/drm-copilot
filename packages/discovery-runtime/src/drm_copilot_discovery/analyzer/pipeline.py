"""Analyzer pipeline abstraction, filesystem seam, and the thin runner.

Purpose:
    Define the host-neutral framework contract that concrete analyzers plug into:
    the ``Analyzer`` protocol (four ordered stages), the ``AnalyzerFileSystem``
    seam that isolates disk access, a read-only compatibility implementation, and the
    ``run_analyzer`` runner that drives the stages deterministically.

Invariants / Constraints:
    - ``Analyzer`` is a ``typing.Protocol`` (multiple implementations expected):
      this feature's inventory analyzer plus future stack-specific analyzers.
    - Protocol stage bodies are ``...`` (type-only; excluded from coverage).
    - ``run_analyzer`` invokes ``parse -> classify -> map`` in that fixed order.
      Legacy emission is disabled; v2 publication requires a guarded mutation.
    - Enumeration/classification logic depends on the seam or plain data so it is
      testable without temporary files.

Side Effects:
    ``RealAnalyzerFileSystem`` reads the filesystem and rejects legacy writes.
    V2 adapters consume retained bytes; mutation planning itself never writes.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol, cast, runtime_checkable

from drm_copilot_discovery.analyzer.models import AnalyzerRunResult

if TYPE_CHECKING:
    from pathlib import Path

    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.analyzer.models import (
        AnalyzerContext,
        ClassifyResult,
        EvidenceRecord,
        InventoryCapture,
        InventoryResult,
        ParseResult,
    )
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
    from drm_copilot_discovery.path_models import WriteGrant


@runtime_checkable
class AnalyzerFileSystem(Protocol):
    """Disk-operation seam required by analyzers.

    Existence/type checks, recursive walking and byte reads retain legacy call
    compatibility. write_text remains in the protocol but the real adapter rejects
    it; guarded v2 mutation owns publication. Tests use isolated memory stores.
    """

    def exists(self, path: Path) -> bool:
        """Return whether ``path`` exists."""
        ...

    def is_dir(self, path: Path) -> bool:
        """Return whether ``path`` is a directory."""
        ...

    def walk_files(self, root: Path) -> tuple[Path, ...]:
        """Return every file path beneath ``root`` (directories excluded)."""
        ...

    def read_bytes(self, path: Path) -> bytes:
        """Return the byte content of the file at ``path``."""
        ...

    def write_text(self, path: Path, content: str) -> None:
        """Write ``content`` to ``path`` as UTF-8, creating parent directories."""
        ...


class Analyzer(Protocol):
    """Legacy analyzer contract retained for existing stack adapters.

    A concrete analyzer plugs into ``run_analyzer`` by implementing ``name`` and
    its stage methods. The runner invokes only the three read stages; emit remains
    a compatibility method and does not participate in automatic publication.
    """

    name: str

    def parse(self, ctx: AnalyzerContext) -> ParseResult:
        """Read inputs described by ``ctx`` and return the parse result."""
        ...

    def classify(self, parsed: ParseResult) -> ClassifyResult:
        """Filter and tag the parsed units."""
        ...

    def map(self, classified: ClassifyResult) -> tuple[EvidenceRecord, ...]:
        """Build one evidence record per classified unit."""
        ...

    def emit(
        self, records: tuple[EvidenceRecord, ...], fs: AnalyzerFileSystem
    ) -> tuple[Path, ...]:
        """Write one artifact per record via the seam and return their paths."""
        ...


class RealAnalyzerFileSystem:
    """Filesystem seam backed by ``pathlib.Path`` operations."""

    def exists(self, path: Path) -> bool:
        """Return whether ``path`` exists on disk."""
        return path.exists()

    def is_dir(self, path: Path) -> bool:
        """Return whether ``path`` is a directory on disk."""
        return path.is_dir()

    def walk_files(self, root: Path) -> tuple[Path, ...]:
        """Return every file beneath ``root`` via an iterative directory walk."""
        collected: list[Path] = []
        stack: list[Path] = [root]
        # Preserve the legacy read seam while returning files from every visited tree.
        while stack:
            current = stack.pop()
            # Recurse into directories and retain ordinary file entries separately.
            for child in current.iterdir():
                if child.is_dir():
                    stack.append(child)
                else:
                    collected.append(child)
        return tuple(collected)

    def read_bytes(self, path: Path) -> bytes:
        """Return the byte content of the file at ``path``."""
        return path.read_bytes()

    def write_text(self, path: Path, content: str) -> None:
        """Reject unguarded legacy writes before creating any file or directory.

        path (Path) and content (str) are retained compatibility parameters. Always
        raises ValueError, returning no result; performs no filesystem operations.
        """
        raise ValueError(
            "Legacy writes are disabled; use guarded v2 inventory publication"
        )


def run_analyzer(
    analyzer: Analyzer,
    ctx: AnalyzerContext,
    fs: AnalyzerFileSystem,
    *,
    dry_run: bool = False,
) -> AnalyzerRunResult:
    """Run legacy classification without emission, including explicit dry runs.

    Args:
        analyzer: The concrete analyzer to run.
        ctx: The resolved run context.
        fs: Retained compatibility parameter; never used for publication.
        dry_run: Explicit read-only intent; the default is also read-only.

    Returns:
        Retained evidence records and an empty written_paths tuple.

    Parameters analyzer (Analyzer), ctx (AnalyzerContext) and fs
    (AnalyzerFileSystem) retain legacy call compatibility; dry_run (bool) cannot
    enable writes. Returns AnalyzerRunResult. Adapter read/classification failures
    propagate; only adapter-owned reads may occur.
    """
    parsed = analyzer.parse(ctx)
    classified = analyzer.classify(parsed)
    records = analyzer.map(classified)
    return AnalyzerRunResult(records=records, written_paths=())


def run_inventory(
    capture: InventoryCapture,
    *,
    timestamp: str,
    author_or_agent: JsonObject,
    catalog: SchemaCatalog,
    dry_run: bool = False,
) -> InventoryResult:
    """Run configured adapters over frozen bytes; default and dry-run never write.

    Capture timestamp and author are explicit inputs. Neither invocation performs
    repository reads or grants publication; failures propagate before any output.

    capture (InventoryCapture) supplies immutable bytes; timestamp (str),
    author_or_agent (JsonObject) and catalog (SchemaCatalog) provide validated
    provenance/schema inputs. dry_run (bool) expresses read-only intent. Returns
    InventoryResult; configuration or validation failures raise ValueError. Performs
    no I/O or mutation.
    """
    from drm_copilot_discovery.analyzer.emitter import inventory_result
    from drm_copilot_discovery.analyzer.registry import select_analyzers

    adapters = select_analyzers(capture.profile)
    # Execute only fixed selected adapters over the same immutable input bytes.
    return inventory_result(
        capture,
        tuple(adapter.analyze(capture) for adapter in adapters),
        analyzer_ids=tuple(adapter.identifier for adapter in adapters),
        timestamp=timestamp,
        author_or_agent=author_or_agent,
        catalog=catalog,
    )


def plan_inventory(
    baseline: CapturedWorkspace,
    result: InventoryResult,
    *,
    grants: tuple[WriteGrant, ...],
    invocation: InvocationContext | None = None,
) -> MutationPlan:
    """Plan one inventory publication using exact caller-authenticated grants.

    Reconstruct results from the captured baseline before trusting their bytes.
    Ledger seed rows remain proposals: analysts receive no scope-writing grant.
    The returned plan is committed only via the existing commit_mutation boundary.

    baseline (CapturedWorkspace) supplies the exact complete input state; result
    (InventoryResult) is rederived from it. grants (tuple[WriteGrant, ...]) and
    invocation (InvocationContext | None) must be authenticated by the caller.
    Returns MutationPlan; raises MutationError or ValueError for changed inputs,
    diagnostics, schema failures or unauthorized paths. Performs no I/O, publication
    or authority changes.
    """
    from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
    from drm_copilot_discovery.models import canonical_json
    from drm_copilot_discovery.mutation_plan import (
        MutationChange,
        MutationError,
        plan_mutation,
    )

    metadata = cast("JsonObject", result.document["capture"])
    # Reconstruct accepted inputs before treating returned data as a request.
    expected = run_inventory(
        capture_snapshot(baseline.snapshot),
        timestamp=cast("str", metadata["timestamp"]),
        author_or_agent=cast("JsonObject", metadata["author_or_agent"]),
        catalog=baseline.snapshot.catalog,
    )
    if result != expected:
        raise MutationError(
            "INVENTORY_INPUTS", "Inventory differs from the exact captured baseline"
        )
    if any(
        diagnostic["blocking"]
        for diagnostic in cast("tuple[JsonObject, ...]", result.document["diagnostics"])
    ):
        raise MutationError(
            "INVENTORY_BLOCKED", "Resolve inventory diagnostics before publication"
        )
    identifier = cast("str", result.document["id"])
    path = baseline.snapshot.profile.artifacts["inventory"] + "/" + identifier + ".json"
    # Existing identical inventory content still carries its exact CAS precondition.
    previous = next(
        (file for file in baseline.snapshot.manifest.files if file.path == path), None
    )
    change = MutationChange(
        artifact_kind="inventory-snapshot",
        artifact_id=identifier,
        path=path,
        content=canonical_json(result.document),
        expected_sha256=previous.sha256 if previous else None,
    )
    return plan_mutation(baseline, (change,), grants=grants, invocation=invocation)
