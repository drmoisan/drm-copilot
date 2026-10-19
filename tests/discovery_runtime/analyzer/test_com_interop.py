"""Verify generic COM provenance, redaction and aggregate resource budgets."""

from __future__ import annotations

import codecs
import hashlib
from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.com_interop import ComInteropAnalyzer
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import pinned_matches, row
from drm_copilot_discovery.analyzer.models import InventoryInput
from drm_copilot_discovery.models import canonical_json
from drm_copilot_discovery.repository_reader import RepositoryFile

from tests.discovery_runtime.analyzer.test_dotnet_projects import capture
from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
from tests.discovery_runtime.analyzer.test_repository import inventory_profile

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import Analysis, InventoryCapture
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject


def serialized(analysis: Analysis) -> str:
    """Return all Analysis families as canonical str for leak assertions; pure."""
    return canonical_json(
        row(
            components=analysis.components,
            findings=analysis.findings,
            relationships=analysis.relationships,
            diagnostics=analysis.diagnostics,
        )
    ).decode()


def test_direct_com_selection_is_schema_valid_and_never_claims_execution(
    catalog: SchemaCatalog,
) -> None:
    """Use SchemaCatalog and memory bytes to verify standalone COM projection.

    Returns None; no dotnet/optional selection, runtime evidence or approved coverage
    is required or manufactured. Complete inventory validation proves schema shape.
    """
    inputs = capture(
        catalog,
        (
            ("src/a.cs", b"Marshal.ReleaseComObject(value);"),
            (
                "src/b.csproj",
                b"<Project><ItemGroup><COMReference/></ItemGroup></Project>",
            ),
        ),
    )
    inputs = replace(
        inputs,
        profile=inventory_profile(
            catalog,
            analyzers={
                "enabled": ["com-interop"],
                "options": {},
                "ignored_paths": [],
                "extension_result_manifests": [],
            },
        ),
    )
    result = ComInteropAnalyzer().analyze(inputs)
    # Source syntax and literal project declarations carry different proof levels.
    assert [item["classification"] for item in result.findings] == [
        "inferred",
        "detected",
    ]
    assert [item["confidence"] for item in result.findings] == ["medium", "high"]
    assert all(not item["blocking"] for item in result.diagnostics)
    output = inventory_result(
        inputs,
        (result,),
        analyzer_ids=("com-interop",),
        timestamp="2026-10-19T07:00:00Z",
        author_or_agent=row(kind="tool", id="fixture"),
        catalog=catalog,
    )
    # Inventory proposals never claim that discovery inspection has been completed.
    assert all(
        item["inspection_status"] == "uninspected" for item in output.ledger_components
    )
    assert "unverified" in serialized(result) and result.relationships == ()


@pytest.mark.parametrize(
    "encoding,bom",
    (
        ("utf-8", b""),
        ("utf-8", codecs.BOM_UTF8),
        ("utf-16-le", codecs.BOM_UTF16_LE),
        ("utf-32-be", codecs.BOM_UTF32_BE),
    ),
)
def test_original_encoding_and_physical_anchor_are_preserved(
    catalog: SchemaCatalog, encoding: str, bom: bytes
) -> None:
    """For SchemaCatalog/str encoding/bytes BOM, bind inspected bytes; return None."""
    payload = bom + (
        "\r\nSystem.Runtime.InteropServices.Marshal." 'IsComObject("VALUE_SENTINEL");'
    ).encode(encoding)
    inputs = capture(catalog, (("src/a.cs", payload),))
    result = ComInteropAnalyzer().analyze(inputs)
    source = cast("JsonObject", result.findings[0]["source"])
    assert source["sha256"] == hashlib.sha256(payload).hexdigest()
    assert source["revision"] == inputs.profile.repository.revision
    assert source["line_range"] == row(start=2, end=2)
    assert "VALUE_SENTINEL" not in serialized(result)


def test_missing_pin_read_failures_exclusions_and_unrelated_inputs_are_honest(
    catalog: SchemaCatalog,
) -> None:
    """Model SchemaCatalog source failures independently from COM candidates; pure.

    Returns None; exact read-error rationale and excluded bytes are not projected.
    """
    inputs = capture(
        catalog,
        (
            ("src/a.cs", b"Marshal.IsComObject(x);"),
            ("src/ignore.txt", b"Marshal.IsComObject(x);"),
        ),
        pinned=False,
    )
    inputs = replace(
        inputs,
        inputs=inputs.inputs
        + (
            InventoryInput(
                path="src/b.cs", status="unreadable", rationale="VALUE_SENTINEL"
            ),
            InventoryInput(
                path="src/c.csproj", status="excluded", rationale="VALUE_SENTINEL"
            ),
        ),
    )
    result = ComInteropAnalyzer().analyze(inputs)
    assert len(result.findings) == 1 and result.findings[0]["confidence"] == "low"
    # Read and provenance failures remain distinct from the binding limitation.
    assert {item["code"] for item in result.diagnostics} == {
        "source-revision-unverified",
        "com-binding-unresolved",
        "input-unreadable",
    }
    assert "VALUE_SENTINEL" not in serialized(result) and len(result.components) == 1


@pytest.mark.parametrize(
    "path,payload,maximum,code",
    (
        ("src/a.cs", b"\xff", 1000, "source-encoding"),
        ("src/a.cs", b"Marshal.IsComObject(x);", 10, "source-limit"),
        ("src/a.csproj", b"<Project/>", 2, "xml-limit"),
        ("src/a.csproj", b"<Project", 1000, "xml-malformed"),
    ),
)
def test_adapter_sanitizes_encoding_size_and_parser_failures(
    catalog: SchemaCatalog, path: str, payload: bytes, maximum: int, code: str
) -> None:
    """For typed capture inputs, expose only stable failure code; return None."""
    result = ComInteropAnalyzer().analyze(
        capture(catalog, ((path, payload),), max_bytes=maximum)
    )
    assert result.components == () and result.findings == ()
    assert [item["code"] for item in result.diagnostics] == [code]


@pytest.mark.parametrize(
    "records,budget,payload,code",
    (
        (1, 16777216, b"", "analysis-limit"),
        (2, 16777216, b"Marshal.IsComObject(x);", "analysis-limit"),
        (100, 1000, b"", "analysis-text-limit"),
        (100, 10000, b"", "analysis-text-limit"),
        (100, 16000, b"Marshal.IsComObject(x);", "analysis-text-limit"),
        (100, 65536, b"//" + b"x" * 40000, "analysis-work-limit"),
    ),
    ids=(
        "base-rows",
        "candidate-rows",
        "diagnostic-bytes",
        "base-bytes",
        "candidate-bytes",
        "input-bytes",
    ),
)
def test_aggregate_budgets_discard_partial_output(
    catalog: SchemaCatalog, records: int, budget: int, payload: bytes, code: str
) -> None:
    """Use SchemaCatalog/int budgets/bytes payload to bound work and output; pure.

    Returns None; the aggregate never publishes partial prior components/findings.
    """
    inputs = capture(
        catalog,
        (("src/a.cs", payload), ("src/b.cs", payload)),
        pinned=code != "analysis-work-limit",
    )
    inputs = replace(
        inputs,
        profile=inventory_profile(
            catalog, limits={"artifact_records": records, "document_bytes": budget}
        ),
    )
    result = ComInteropAnalyzer().analyze(inputs)
    assert result.components == () and result.findings == ()
    assert len(result.diagnostics) == 1 and result.diagnostics[0]["code"] == code


def test_failed_reads_still_consume_the_aggregate_record_budget(
    catalog: SchemaCatalog,
) -> None:
    """Bound two unavailable inputs by one diagnostic row; return None, without I/O."""
    inputs = replace(
        capture(catalog, (), records=1),
        # Read failures count toward the same output budget as successful records.
        inputs=tuple(
            InventoryInput(path=path, status="unreadable", rationale="missing")
            for path in ("src/a.cs", "src/b.cs")
        ),
    )
    result = ComInteropAnalyzer().analyze(inputs)
    assert result.components == () and result.findings == ()
    assert [item["code"] for item in result.diagnostics] == ["analysis-limit"]


@pytest.mark.parametrize("limit_kind", ("count", "bytes"))
def test_retained_pin_budgets_fail_before_projection(
    catalog: SchemaCatalog,
    limit_kind: str,
) -> None:
    """Bound captured provenance independently by count/bytes; return None, pure."""
    inputs = capture(catalog, (("src/a.cs", b"Marshal.IsComObject(x);"),))
    # Count exhaustion needs duplicate pins; byte exhaustion needs oversized pins.
    limits = {"source_files": 1} if limit_kind == "count" else {"document_bytes": 1000}
    content = b"x" if limit_kind == "count" else b"x" * 501
    pin = replace(inputs.repository_files[0], content=content)
    inputs = replace(
        inputs,
        repository_files=(pin, pin),
        profile=inventory_profile(catalog, limits=limits),
    )
    result = ComInteropAnalyzer().analyze(inputs)
    assert result.components == () and result.findings == ()
    assert [item["code"] for item in result.diagnostics] == ["analysis-work-limit"]


@pytest.mark.parametrize("matching", (True, False))
def test_indexed_pin_candidates_preserve_exact_identity_and_duplicate_semantics(
    catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    matching: bool,
) -> None:
    """Observe bounded proof calls with synthetic pins and a forwarding spy; pure.

    Returns None. MonkeyPatch isolates the spy; exact repository/revision/path/bytes
    comparison stays in the accepted helper. A later valid duplicate remains usable.
    """
    inputs = capture(
        catalog,
        (
            ("src/a.cs", b'Marshal.IsComObject("VALUE_SENTINEL");'),
            ("src/b.cs", b"Type.GetTypeFromProgID(x);"),
        ),
    )
    pin = inputs.repository_files[0]
    selected = (
        pin
        if matching
        else replace(pin, repository=replace(pin.repository, revision="b" * 40))
    )
    # Unrelated retained paths must never enter a per-input verification scan.
    unrelated = tuple(
        RepositoryFile(
            repository=pin.repository, path=f"src/other-{index}.cs", content=b""
        )
        for index in range(20)
    )
    inputs = replace(
        inputs,
        repository_files=(replace(pin, content=b"wrong"),)
        + unrelated
        + (selected, inputs.repository_files[1]),
    )
    observed: list[int] = []

    def observe(captured: InventoryCapture, item: InventoryInput) -> bool:
        """Forward typed capture/item proof and return bool without external I/O.

        Append only this invocation's candidate count to the isolated observed list.
        """
        observed.append(len(captured.repository_files))
        return pinned_matches(captured, item)

    monkeypatch.setattr(
        "drm_copilot_discovery.analyzer.com_interop.pinned_matches", observe
    )
    result = ComInteropAnalyzer().analyze(inputs)
    assert observed == [2, 2, 1, 1]
    assert result.findings[0]["confidence"] == ("medium" if matching else "low")
    assert result.findings[1]["confidence"] == "medium"
    assert "VALUE_SENTINEL" not in serialized(result)
    # A matching later duplicate clears only the revision diagnostic, never binding.
    assert any(
        item["code"] == "source-revision-unverified" for item in result.diagnostics
    ) is (not matching)


def test_projection_determinism_redaction_and_no_file_io(
    catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """For SchemaCatalog/MonkeyPatch, verify retained input order and I/O isolation.

    Returns None; isolated patched path methods raise if the pure analyzer accesses
    files. Inputs and schemas are constructed before patches and remain unchanged.
    """
    payloads = (
        ("src/b.cs", b"Marshal.IsComObject(x);"),
        ("src/a.csproj", b"<Project/>"),
    )
    inputs = capture(catalog, payloads)
    reordered = capture(catalog, tuple(reversed(payloads)))

    def forbidden(*args: object, **kwargs: object) -> bytes:
        """Reject any object arguments as unexpected file I/O; raise AssertionError."""
        raise AssertionError("Analyzer attempted external file I/O")

    monkeypatch.setattr(Path, "read_bytes", forbidden)
    monkeypatch.setattr(Path, "write_bytes", forbidden)
    assert ComInteropAnalyzer().analyze(inputs) == ComInteropAnalyzer().analyze(
        reordered
    )
