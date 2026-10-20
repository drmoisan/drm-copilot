"""Verify bounded fixed selection and independently reconstructed publication."""

from __future__ import annotations

import builtins
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
from drm_copilot_discovery.analyzer.inventory import RepositoryAnalyzer
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.analyzer.pipeline import plan_inventory, run_inventory
from drm_copilot_discovery.analyzer.registry import (
    InstalledInventoryRegistry,
    InventoryAdapter,
    normalized_analyzer_ids,
    select_analyzers,
)
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.path_models import WriteGrant

from tests.discovery_runtime.analyzer.test_pipeline import publication_case
from tests.discovery_runtime.analyzer.test_registry_dispatch import selection
from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import (
    inventory_capture,
    inventory_profile,
)

if TYPE_CHECKING:
    from types import ModuleType

    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryResult
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject
    from drm_copilot_discovery.profile_v2 import ProfileV2


class ObservedAdapter:
    """Count identity reads and analysis without I/O or publication authority.

    Test-local counters expose repeated work. The wrapped repository implementation
    supplies accepted rows unless divergence is explicitly requested.
    """

    def __init__(
        self, identifier: str = "repository", *, divergent: bool = False
    ) -> None:
        """Store str identifier/bool divergence and reset counters; return None.

        No I/O or expected exceptions; mutation is confined to this test instance.
        """
        self.value = identifier
        self.divergent = divergent
        self.identity_reads = 0
        self.calls = 0

    @property
    def identifier(self) -> str:
        """Count one identity read and return str; no arguments, errors or I/O."""
        self.identity_reads += 1
        return self.value

    def analyze(self, capture: InventoryCapture) -> Analysis:
        """Count captured InventoryCapture analysis and return Analysis.

        Bool divergence chooses an empty but valid candidate. Wrapped validation
        errors propagate. Only local counters change; no external I/O occurs.
        """
        self.calls += 1
        return Analysis() if self.divergent else RepositoryAnalyzer().analyze(capture)


class ObservedRegistry:
    """Return explicitly injected adapters while retaining bounded call observations.

    Used once per run; it never imports or executes adapters itself. Mutable
    counters and received immutable parameters remain isolated to one test.
    """

    def __init__(self, adapters: tuple[InventoryAdapter, ...]) -> None:
        """Store tuple[InventoryAdapter, ...]; initialize counters; return None.

        No expected exception, source access or shared-state mutation occurs.
        """
        self.adapters = adapters
        self.calls = 0
        self.received: tuple[str, ...] | None = None

    def select(
        self, profile: ProfileV2, *, analyzer_ids: tuple[str, ...] | None = None
    ) -> tuple[InventoryAdapter, ...]:
        """Record ProfileV2 selection and tuple[str, ...] IDs; return adapters.

        No validation or imports are hidden here. Only test-local counters change;
        no expected exceptions or I/O occur.
        """
        del profile
        self.calls += 1
        self.received = analyzer_ids
        return self.adapters


def execute(
    capture: InventoryCapture,
    catalog: SchemaCatalog,
    *,
    ids: tuple[str, ...] | None = None,
    registry: ObservedRegistry | None = None,
) -> InventoryResult:
    """Run InventoryCapture/SchemaCatalog with optional IDs and test registry.

    Returns InventoryResult using fixed attribution. Runtime validation failures
    propagate; no source mutation, files, subprocesses or network are used.
    """
    return run_inventory(
        capture,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=catalog,
        analyzer_ids=ids,
        analyzer_registry=registry,
    )


@pytest.mark.parametrize(
    "ids",
    [
        (),
        ("repository", "repository"),
        ("unknown",),
        ("dotnet",),
        ("office-vsto",),
        ("module.path",),
        ("x" * 20,),
        (1,),
        (True,),
        "repository",
        ["repository"],
        tuple(["repository"] * 13),
    ],
)
def test_invalid_selection_precedes_injected_callbacks(
    analyzer_catalog: SchemaCatalog, ids: object
) -> None:
    """Reject object ids before registry or analysis callbacks; return None.

    SchemaCatalog builds a valid repository-only capture. AssertionError exposes
    missing rejection or work before validation; all collaborators are in memory.
    """
    capture = inventory_capture(analyzer_catalog)
    adapter = ObservedAdapter()
    registry = ObservedRegistry((adapter,))
    with pytest.raises(ValueError, match="Unavailable analyzer selection"):
        execute(
            capture,
            analyzer_catalog,
            ids=cast("tuple[str, ...]", ids),
            registry=registry,
        )
    assert registry.calls == adapter.calls == adapter.identity_reads == 0


def test_oversized_selector_is_rejected_before_member_work(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Reject thirteen members before hashing/formatting any one of them.

    SchemaCatalog supplies configuration; local sentinels assert forbidden work.
    Returns None; no global state or external resources are changed.
    """

    class Unhashable:
        """Expose premature hashing or stringification through deterministic errors."""

        def __hash__(self) -> int:
            """Reject hashing with AssertionError; no parameters, return or I/O."""
            raise AssertionError("No member hashing before count validation")

        def __str__(self) -> str:
            """Reject formatting with AssertionError; no parameters, return or I/O."""
            raise AssertionError("No member formatting before count validation")

    with pytest.raises(ValueError, match="1 to 12"):
        normalized_analyzer_ids(
            inventory_profile(analyzer_catalog),
            analyzer_ids=cast("tuple[str, ...]", (Unhashable(),) * 13),
        )


@pytest.mark.parametrize("ids", [None, ("repository", "dotnet"), ("dotnet",)])
def test_selection_is_sorted_and_preserves_profile_and_default_bytes(
    analyzer_catalog: SchemaCatalog, ids: tuple[str, ...] | None
) -> None:
    """Compare optional tuple IDs with accepted fixed dispatch over immutable bytes.

    SchemaCatalog validates output. Returns None; assertions expose metadata,
    default byte or profile mutation drift. No I/O occurs.
    """
    capture = replace(
        inventory_capture(analyzer_catalog),
        profile=inventory_profile(
            analyzer_catalog, analyzers=selection(("repository", "dotnet"))
        ),
    )
    before = canonical_json(capture.profile.document)
    expected = tuple(sorted(ids or capture.profile.analyzers.enabled))
    adapters = select_analyzers(capture.profile, analyzer_ids=ids)
    result = execute(capture, analyzer_catalog, ids=ids)
    # Reproduce the accepted configured pipeline without the new injection path.
    legacy = inventory_result(
        capture,
        tuple(adapter.analyze(capture) for adapter in adapters),
        analyzer_ids=expected,
        timestamp="2026-10-19T01:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=analyzer_catalog,
    )
    assert result == legacy
    # Compare bounded identity metadata independently from emitted analysis rows.
    assert (
        tuple(
            item["id"]
            for item in cast("tuple[JsonObject, ...]", result.document["analyzers"])
        )
        == expected
    )
    assert canonical_json(capture.profile.document) == before


def test_optional_subset_imports_only_after_complete_consent(
    analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Use SchemaCatalog/MonkeyPatch to observe the complete optional import gate.

    Returns None; assertions detect imports on invalid requests or omitted optional
    selection. Original import behavior is restored before pytest reporting.
    """
    profile = inventory_profile(
        analyzer_catalog, analyzers=selection(("office-vsto", "repository"))
    )
    seen: list[str] = []
    consented = False
    original = builtins.__import__

    def observe(
        name: str,
        globals: dict[str, object] | None = None,
        locals: dict[str, object] | None = None,
        fromlist: tuple[str, ...] = (),
        level: int = 0,
    ) -> ModuleType:
        """Forward typed import parameters and count the requested adapter import.

        Returns ModuleType; AssertionError rejects any premature optional import.
        Transitive consented imports do not affect the direct request count. Other
        import errors propagate; only local observations change, without source I/O.
        """
        if ".analyzer.optional" in name:
            assert consented
            # Cold and warm module caches must prove the same requested dispatch.
            if name == "drm_copilot_discovery.analyzer.optional.vsto_office":
                seen.append(name)
        return original(name, globals, locals, fromlist, level)

    with monkeypatch.context() as context:
        context.setattr(builtins, "__import__", observe)
        with pytest.raises(ValueError):
            select_analyzers(profile, analyzer_ids=("office-vsto", "unknown"))
        select_analyzers(profile, analyzer_ids=("repository",))
        assert not seen
        consented = True
        selected = InstalledInventoryRegistry().select(
            profile, analyzer_ids=("office-vsto",)
        )
    assert selected[0].identifier == "office-vsto" and len(seen) == 1


@pytest.mark.parametrize("identifiers", [(), ("dotnet",), ("repository", "repository")])
def test_injected_identity_mismatch_never_analyzes(
    analyzer_catalog: SchemaCatalog, identifiers: tuple[str, ...]
) -> None:
    """Reject missing/wrong/extra tuple identifiers before source analysis.

    SchemaCatalog supplies valid capture. Returns None; deterministic counters
    expose unwanted callbacks. No external reads, writes or process execution.
    """
    # Construct isolated counters to observe all returned adapters.
    adapters = tuple(ObservedAdapter(identifier) for identifier in identifiers)
    registry = ObservedRegistry(adapters)
    with pytest.raises(ValueError, match="different adapter selection"):
        execute(
            inventory_capture(analyzer_catalog), analyzer_catalog, registry=registry
        )
    assert registry.calls == 1
    # No member may analyze until the entire injected selection matches.
    assert all(adapter.calls == 0 for adapter in adapters)


def test_valid_injection_reads_identity_and_analyzes_once(
    analyzer_catalog: SchemaCatalog,
) -> None:
    """Prove one selection/identity/analysis operation with immutable SchemaCatalog.

    Returns None; counted assertions detect repeated work without timing checks.
    Only local counters mutate.
    """
    adapter = ObservedAdapter()
    registry = ObservedRegistry((adapter,))
    capture = inventory_capture(analyzer_catalog)
    result = execute(capture, analyzer_catalog, registry=registry)
    assert result == execute(capture, analyzer_catalog)
    assert registry.calls == adapter.calls == adapter.identity_reads == 1
    assert registry.received == ("repository",)


@pytest.mark.parametrize("kind", ["subclass", "non-string", "empty", "oversized"])
def test_returned_identifier_shape_precedes_equality_and_analysis(
    analyzer_catalog: SchemaCatalog, kind: str
) -> None:
    """Reject malformed returned str shapes before equality or analysis callbacks.

    SchemaCatalog supplies immutable schemas; str kind selects one invalid shape.
    Returns None. Counted assertions verify one property read and no collaborator
    comparison/length execution. All state is local; no I/O or timing checks.
    """
    counts = {"equality": 0, "length": 0}

    class Mislabelled(str):
        """Attempt to disguise wrong text through counted equality/length hooks."""

        def __eq__(self, other: object) -> bool:
            """Count object comparison and claim equality; return bool without I/O."""
            del other
            counts["equality"] += 1
            return True

        def __len__(self) -> int:
            """Count length dispatch and return int; no parameters or I/O."""
            counts["length"] += 1
            return 10

    class NonString:
        """Attempt the same equality substitution without any string ancestry."""

        def __eq__(self, other: object) -> bool:
            """Count object comparison and claim equality; return bool without I/O."""
            del other
            counts["equality"] += 1
            return True

        def __len__(self) -> int:
            """Count length dispatch and return int; no parameters or I/O."""
            counts["length"] += 1
            return 10

    value = {
        "subclass": Mislabelled("dotnet"),
        "non-string": NonString(),
        "empty": "",
        "oversized": "x" * 20,
    }[kind]
    adapter = ObservedAdapter(cast("str", value))
    registry = ObservedRegistry((adapter,))
    with pytest.raises(ValueError, match="different adapter selection"):
        execute(
            inventory_capture(analyzer_catalog), analyzer_catalog, registry=registry
        )
    assert registry.calls == adapter.identity_reads == 1
    assert adapter.calls == 0 and counts == {"equality": 0, "length": 0}


@pytest.mark.parametrize("divergent", [False, True])
def test_publication_reconstructs_exact_subset_with_installed_registry(
    analyzer_catalog: SchemaCatalog, divergent: bool
) -> None:
    """Preserve canonical reconstruction despite injected bool divergence.

    SchemaCatalog and accepted memory publication fixtures supply pinned sources.
    Returns None; errors expose wrong selection/analysis trust. No real I/O occurs.
    """
    writer, _, _, _ = publication_case(analyzer_catalog)
    profile = inventory_profile(
        analyzer_catalog, analyzers=selection(("repository", "dotnet"))
    )
    writer.store.put(profile.artifacts["profile"], canonical_json(profile.document))
    baseline = writer.capture()
    adapter = ObservedAdapter(divergent=divergent)
    result = execute(
        capture_snapshot(baseline.snapshot),
        analyzer_catalog,
        ids=("repository",),
        registry=ObservedRegistry((adapter,)),
    )
    identifier = cast("str", result.document["id"])
    grant = WriteGrant(
        artifact_kind="inventory-snapshot",
        artifact_id=identifier,
        path=profile.artifacts["inventory"] + "/" + identifier + ".json",
    )
    before = dict(writer.store.files)
    # Injected contents and omitted/wrong selectors cannot authorize publication.
    if divergent:
        with pytest.raises(MutationError, match="INVENTORY_INPUTS"):
            plan_inventory(
                baseline, result, grants=(grant,), analyzer_ids=("repository",)
            )
    else:
        plan_inventory(baseline, result, grants=(grant,), analyzer_ids=("repository",))
    with pytest.raises(MutationError, match="INVENTORY_INPUTS"):
        plan_inventory(baseline, result, grants=(grant,))
    with pytest.raises(MutationError, match="INVENTORY_INPUTS"):
        plan_inventory(baseline, result, grants=(grant,), analyzer_ids=("dotnet",))
    assert writer.store.files == before and adapter.calls == 1
