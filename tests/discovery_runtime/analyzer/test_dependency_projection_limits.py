"""Enforce aggregate dependency projection limits without filesystem or process use."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, Protocol, cast

import pytest
from drm_copilot_discovery.analyzer import dependencies
from drm_copilot_discovery.analyzer.dependencies import DependencyAnalyzer
from drm_copilot_discovery.analyzer.dependency_inputs import (
    DependencyAnchor,
    DependencyInputError,
    DependencyLimits,
    DependencyResult,
)
from drm_copilot_discovery.analyzer.findings import pinned_matches
from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
from drm_copilot_discovery.models import canonical_json

from tests.discovery_runtime.analyzer.test_dependencies import (
    codes,
    configured,
    item,
    stub,
)
from tests.discovery_runtime.analyzer.test_dotnet_projects import capture
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.catalog import SchemaCatalog


def test_all_diagnostics_and_error_fallbacks_share_output_limits(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Use catalog/monkeypatch fixtures to check full output accounting; return None.

    SchemaCatalog supplies limits; pytest.MonkeyPatch restores the parser patch.
    Fixed result errors are asserted; no I/O or external mutation occurs.
    """
    parsed = DependencyResult((), ("dependency-ambiguous", "dependency-ambiguous"))
    stub(monkeypatch, parsed)
    enough = DependencyAnalyzer().analyze(
        configured(catalog, limits={"artifact_records": 4})
    )
    assert len(enough.components) == 1 and len(enough.diagnostics) == 2
    assert len(set(codes(enough))) == 2
    tight = DependencyAnalyzer().analyze(
        configured(catalog, limits={"artifact_records": 3})
    )
    assert not tight.components and codes(tight) == ("dependency-limit",)
    assert len(canonical_json(tight.diagnostics)) < 1024


@pytest.mark.parametrize("capacity", [1, 1023])
def test_impossible_error_envelope_raises_instead_of_emitting_over_budget(
    catalog: SchemaCatalog, capacity: int
) -> None:
    """Use catalog (SchemaCatalog) and capacity (int) to reject errors; return None.

    Assert fixed DependencyInputError before oversized output; no I/O occurs.
    """
    with pytest.raises(DependencyInputError) as error:
        DependencyAnalyzer().analyze(
            configured(catalog, limits={"document_bytes": capacity})
        )
    assert error.value.code == "dependency-limit"


@pytest.mark.parametrize(
    ("limit", "value"),
    [("artifact_records", 1), ("document_bytes", 1024), ("document_bytes", 4096)],
)
def test_complete_output_budget_precedes_projection(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, limit: str, value: int
) -> None:
    """Check limit (str)/value (int) using catalog/monkeypatch; return None.

    SchemaCatalog and pytest.MonkeyPatch isolate profile/parser state. Assert a
    fixed blocker without I/O or any retained partial facts.
    """
    stub(monkeypatch, DependencyResult((item(edge=True),)))
    result = DependencyAnalyzer().analyze(configured(catalog, limits={limit: value}))
    assert not result.findings and not result.components and not result.relationships
    assert codes(result) == ("dependency-limit",)


@pytest.mark.parametrize(
    "case", ["pin-count", "pin-bytes", "input-bytes", "scan-work", "path-work"]
)
def test_independent_aggregate_resource_limits(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, case: str
) -> None:
    """Check case (str) via catalog/monkeypatch fixtures; return None.

    SchemaCatalog supplies limits; pytest.MonkeyPatch observes parser calls.
    Fixed exhaustion is asserted before allocation; no I/O occurs.
    """
    captured = configured(catalog, limits={"document_bytes": 16384, "source_files": 1})
    source = captured.repository_files[0]
    # Build one specific exhausted resource while leaving other capacities valid.
    if case == "pin-count":
        captured = replace(captured, repository_files=(source, source))
    elif case == "pin-bytes":
        captured = replace(
            captured, repository_files=(replace(source, content=b"x" * 16385),)
        )
    elif case == "input-bytes":
        captured = configured(
            catalog,
            limits={"document_bytes": 16384},
            payloads=(("src/package.json", b"x" * 16385),),
        )
        captured = replace(captured, repository_files=())
    elif case == "scan-work":
        captured = configured(
            catalog,
            limits={"document_bytes": 3_000_000},
            payloads=(("src/package.json", b"x" * 2_000_001),),
        )
    else:
        captured = configured(
            catalog,
            limits={"document_bytes": 1024},
            payloads=(("src/" + "a" * 1100 + ".txt", b""),),
        )
    calls = stub(monkeypatch, DependencyResult())
    result = DependencyAnalyzer().analyze(captured)
    assert not calls and not result.components
    assert codes(result) == ("dependency-limit",)


@pytest.mark.parametrize(
    "case", ["candidates", "diagnostics", "nodes", "text", "ordinal", "line"]
)
def test_parser_contract_violations_cannot_escape(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, case: str
) -> None:
    """Check case (str) through catalog/monkeypatch fixtures; return None.

    SchemaCatalog and pytest.MonkeyPatch isolate a parser contract violation.
    Assert a fixed blocker without partial rows or I/O.
    """

    def parse(
        content: bytes, format: str, limits: DependencyLimits
    ) -> DependencyResult:
        """Return invalid DependencyResult for bytes/str/DependencyLimits inputs.

        The isolated monkeypatch injects one contract failure; no I/O occurs.
        """
        # Each branch violates exactly one result capacity or anchor constraint.
        if case == "candidates":
            return DependencyResult((item(),) * (limits.max_candidates + 1))
        if case == "diagnostics":
            return DependencyResult(
                diagnostics=("dependency-ambiguous",) * (limits.max_nodes + 1)
            )
        if case == "nodes":
            return DependencyResult(consumed_nodes=limits.max_nodes + 1)
        if case == "text":
            return DependencyResult(consumed_text_bytes=limits.max_text_bytes + 1)
        anchor = (
            DependencyAnchor("json", "/packages", occurrence=1_000_001)
            if case == "ordinal"
            else DependencyAnchor("text", "requirements", line=100_000_000)
        )
        return DependencyResult((replace(item(), anchor=anchor),))

    monkeypatch.setattr(dependencies, "_parse", parse)
    result = DependencyAnalyzer().analyze(
        configured(catalog, limits={"artifact_records": 4})
    )
    assert not result.components and len(result.diagnostics) == 1
    assert codes(result) == (
        ("dependency-malformed",)
        if case in {"ordinal", "line"}
        else ("dependency-limit",)
    )


class _Projection(Protocol):
    """Typed test seam for the private projection unit's defensive reservations.

    Obtain the internal constructor by name only in its unit test, then assert
    failures through this small contract. No production API or global state changes.
    """

    def reserve(self, rows: int, text: int) -> None:
        """Reserve rows/text (int units); return None or propagate contract errors.

        Mutates only the isolated projection unit; no external I/O occurs.
        """
        ...

    def parse(self, item: InventoryInput, format: str) -> DependencyResult:
        """Parse item (InventoryInput) with format (str); return DependencyResult.

        Propagate fixed errors; mutate only local budgets without I/O.
        """
        ...


def test_invalid_public_capture_and_internal_reservations(
    catalog: SchemaCatalog,
) -> None:
    """Use catalog (SchemaCatalog) to check defensive contracts; return None.

    Assert ValueError/fixed DependencyInputError without I/O or external mutation.
    """
    with pytest.raises(ValueError, match="validated immutable capture"):
        DependencyAnalyzer().analyze(cast("InventoryCapture", None))
    factory = cast(
        "Callable[[InventoryCapture], _Projection]", vars(dependencies)["_Run"]
    )
    run = factory(configured(catalog))
    with pytest.raises(ValueError, match="nonnegative integers"):
        run.reserve(True, 0)
    with pytest.raises(DependencyInputError):
        run.parse(
            InventoryInput(
                path="src/package.json", status="unreadable", rationale="unavailable"
            ),
            "package-json",
        )


def test_pin_lookup_visits_only_each_inputs_retained_group(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Use catalog/monkeypatch fixtures to count pin work; return None.

    Retain exact comparison through the accepted helper. The fixture restores the
    observer; no file/process access or expected error occurs.
    """
    # Distinct paths expose an accidental full-pin rescan on every selected input.
    payloads = tuple((f"src/p{ordinal}/package.json", b"{}") for ordinal in range(12))
    captured = configured(catalog, payloads=payloads)
    original = pinned_matches
    groups: list[tuple[str, int]] = []

    def observe(local: InventoryCapture, selected: InventoryInput) -> bool:
        """Inspect local (InventoryCapture) and selected (InventoryInput).

        Return bool from the real comparator; record group sizes locally without
        I/O or changes to retained bytes. No expected exception occurs.
        """
        groups.append((selected.path, len(local.repository_files)))
        return original(local, selected)

    monkeypatch.setattr(dependencies, "pinned_matches", observe)
    stub(monkeypatch, DependencyResult())
    result = DependencyAnalyzer().analyze(captured)
    assert len(result.components) == 12
    # Every captured path receives exactly its own one-member pin group.
    assert groups == sorted((path, 1) for path, _ in payloads)
    assert "source-revision-unverified" not in codes(result)


def test_remaining_parser_resources_are_independent(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Use catalog/monkeypatch to observe residual budgets; return None.

    The isolated pure parser consumes declared text/node work. No I/O or expected
    exception occurs; full-row budgets remain separate from retained parser text.
    """
    captured = configured(
        catalog,
        limits={"document_bytes": 100_000},
        payloads=(("src/a/package.json", b"123"), ("src/b/package.json", b"45678")),
    )
    observed: list[tuple[bytes, DependencyLimits]] = []

    def parse(
        content: bytes, format: str, limits: DependencyLimits
    ) -> DependencyResult:
        """Record bytes/str/DependencyLimits arguments; return DependencyResult.

        Charge two nodes and 100 text bytes locally; no I/O or expected errors.
        """
        observed.append((content, limits))
        return DependencyResult(consumed_nodes=2, consumed_text_bytes=100)

    monkeypatch.setattr(dependencies, "_parse", parse)
    result = DependencyAnalyzer().analyze(captured)
    assert len(result.components) == 2 and len(observed) == 2
    first, second = observed[0][1], observed[1][1]
    assert observed[0][0] == b"123" and observed[1][0] == b"45678"
    assert first.max_bytes == 100_000 and second.max_bytes == 99_997
    assert first.max_text_bytes == 100_000 and second.max_text_bytes == 99_900
    assert second.max_candidates == first.max_candidates - 2
    assert second.max_nodes < first.max_nodes


@pytest.mark.parametrize("case", ["maximum-file", "nodes", "retained-text"])
def test_exhausted_parser_budget_stops_before_next_call(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, case: str
) -> None:
    """Use catalog/monkeypatch and case (str) to exhaust one resource; return None.

    Isolated parser calls expose reservation order; no I/O or uncontrolled errors.
    """
    captured = configured(
        catalog, payloads=(("src/a/package.json", b"{}"), ("src/b/package.json", b"{}"))
    )
    calls: list[DependencyLimits] = []

    def parse(
        content: bytes, format: str, limits: DependencyLimits
    ) -> DependencyResult:
        """Accept bytes/str/DependencyLimits; return an exhausting result.

        Append limits locally; fixed resource exhaustion is handled by the adapter.
        No I/O or external mutation occurs.
        """
        calls.append(limits)
        # Select one independently exhausted parser resource without producing rows.
        return DependencyResult(
            consumed_nodes=limits.max_nodes if case == "nodes" else 0,
            consumed_text_bytes=limits.max_text_bytes if case == "retained-text" else 0,
        )

    # A per-file cap must reject even when all aggregate input capacities suffice.
    if case == "maximum-file":
        captured = capture(catalog, (("src/package.json", b"{}"),), max_bytes=1)
    elif case == "nodes":
        captured = configured(
            catalog,
            limits={"document_bytes": 16384},
            payloads=(("src/a/package.json", b"{}"), ("src/b/package.json", b"{}")),
        )
    monkeypatch.setattr(dependencies, "_parse", parse)
    result = DependencyAnalyzer().analyze(captured)
    assert len(calls) == (0 if case == "maximum-file" else 1)
    assert not result.components and codes(result) == ("dependency-limit",)
