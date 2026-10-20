"""Check pure ready-only rendering and exact escaped traceability."""

from __future__ import annotations

import json
import re
from dataclasses import FrozenInstanceError, replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import gherkin
from drm_copilot_discovery.acceptance_generation import generate_acceptance
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.gherkin import (
    AcceptanceRenderBundle,
    AcceptanceRenderedFile,
    render_acceptance,
)
from drm_copilot_discovery.models import ParseLimits, to_plain_value
from drm_copilot_discovery.report_models import ReportLimitError, bounded_object
from drm_copilot_discovery.schema_validation import validate_document

from tests.discovery_runtime.test_acceptance_generation import (
    generation_snapshot,
    imported_snapshot,
)
from tests.discovery_runtime.test_acceptance_generation import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.test_acceptance_properties import (
    generation,
    identity,
    specification,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.acceptance_models import (
        AcceptanceGeneration,
        AcceptanceSpecification,
    )
    from drm_copilot_discovery.catalog import SchemaCatalog


def changed(item: AcceptanceSpecification, **fields: object) -> AcceptanceSpecification:
    """Replace document fields on item; return a bounded structural test value.

    item is AcceptanceSpecification; fields are JSON-shaped replacements.
    Constructor errors propagate. This helper asserts no graph readiness and
    performs no I/O or mutation of shared fixtures.
    """
    document = item.to_dict()
    document.update(fields)
    return replace(item, document=bounded_object(document, limits=item.limits))


def file_text(bundle: AcceptanceRenderBundle, suffix: str) -> str:
    """Return the UTF-8 file in bundle (AcceptanceRenderBundle) matching suffix (str).

    Raises AssertionError for ambiguous fixture selection; no I/O or mutation.
    """
    # Match output identity independently of its stable scenario digest.
    selected = [item for item in bundle.files if item.path.endswith(suffix)]
    assert len(selected) == 1
    return selected[0].content.decode("utf-8")


def blocks(markdown: str) -> list[object]:
    """Decode fixed JSON blocks from markdown (str); return independent values.

    JSON decoding errors identify malformed output. No I/O or caller mutation.
    """
    # Literal blocks must remain parseable even when authored text contains fences.
    return [
        json.loads(value) for value in re.findall(r"```json\n([^\n]*)\n```", markdown)
    ]


@pytest.mark.parametrize("imported", [False, True])
def test_public_captured_generation_renders_exact_trace_and_steps(
    snapshot_catalog: SchemaCatalog,
    imported: bool,
) -> None:
    """Compose snapshot_catalog (SchemaCatalog) and imported (bool); return None.

    Assert schema, raw provenance and stable bytes without graph revalidation in
    the renderer; fixture errors propagate, and no external I/O occurs.
    """
    snapshot = (
        imported_snapshot(snapshot_catalog)
        if imported
        else generation_snapshot(snapshot_catalog)
    )
    kind = "target-acceptance" if imported else "legacy-characterization"
    result = generate_acceptance(snapshot, kind=kind)
    assert len(result.ready) == 1, result.findings
    item = result.ready[0]
    assert validate_document(
        item.to_json(),
        expected_kind="acceptance-specification",
        expected_version="2.0.0",
        catalog=snapshot_catalog,
    ).ok
    before = item.to_json()

    bundle = render_acceptance(result)
    feature = file_text(bundle, ".feature")
    trace = as_object(json.loads(feature.splitlines()[0][2:]))
    assert trace["specification"] == item.to_dict()
    assert trace["repository"] == item.repository.to_dict()
    assert trace["identity"] == to_plain_value(item.identity.key(limits=result.limits))
    assert (
        as_object(trace["identity"])["source_repository_id"]
        == item.identity.source_repository_id
    )
    assert (
        as_object(trace["specification"])["source_content_sha256"]
        == item.document["source_content_sha256"]
    )
    assert render_acceptance(result) == bundle
    assert item.to_json() == before
    assert bundle.files[0].path == "acceptance.md"
    assert f'{kind}/{item.document["scenario_id"]}.feature' == bundle.files[1].path
    if imported:
        assert item.repository.id != item.identity.source_repository_id
        assert "docs/imported/" not in feature


@pytest.mark.parametrize(
    "text",
    [
        "plain",
        '"quoted" \\',
        "line\r\nnext\t\b\f\x00",
        "\x7f\u2028\u2029",
        "café 😀",
        "|cell|",
        '"""\n```\nScenario: injected\n@tag',
        "</script><b>[link](x)",
    ],
    ids=[
        "plain",
        "quote-slash",
        "controls",
        "del-separators",
        "unicode",
        "pipe",
        "syntax",
        "html",
    ],
)
def test_authored_statements_stay_one_reversible_json_literal(text: str) -> None:
    """Render text (str) in every step position; assert exact reversible escaping.

    Uses structural carriers only, not readiness proof. Returns None with no I/O
    or input mutation.
    """
    item = changed(
        specification(text=text), given=(text, text), when=text, then=(text, text)
    )
    bundle = render_acceptance(generation((item,), (item,)))
    feature = file_text(bundle, ".feature")
    # The fixed five steps must be the only physical authored statement lines.
    steps = [line.strip() for line in feature.splitlines() if line.startswith("    ")]
    assert len(steps) == 5
    # Check keyword sequencing independently of JSON literal contents.
    assert [line.split(" ", 1)[0] for line in steps] == [
        "Given",
        "And",
        "When",
        "Then",
        "And",
    ]
    # Every literal must restore the original text, including controls and Unicode.
    assert all(json.loads(line.split(" ", 1)[1]) == text for line in steps)
    assert feature.isascii()
    trace = as_object(blocks(file_text(bundle, ".md"))[2])
    assert as_object(trace["specification"])["then"] == [text, text]
    assert len(blocks(file_text(bundle, ".md"))) == 3


def test_empty_given_has_no_synthetic_step() -> None:
    """Assert empty setup emits only authored When/Then; return None, no I/O."""
    item = changed(specification(), given=())
    feature = file_text(render_acceptance(generation((item,), (item,))), ".feature")
    assert "    Given " not in feature
    assert feature.count("    When ") == feature.count("    Then ") == 1


def test_ready_pending_withheld_and_actions_remain_distinct() -> None:
    """Retain candidate states/diagnostics; return None without readiness promotion.

    No arguments; constructs local values only, with no shared mutation or I/O.
    """
    ready = specification(key=identity(feature_id="alpha"))
    pending = specification(key=identity(feature_id="beta"), readiness="pending")
    withheld = specification(key=identity(feature_id="gamma"))
    finding = Finding(
        code="UNRESOLVED",
        severity="warning",
        message="Review.\n```",
        next_action="Provide original proof.",
        related_ids=("gamma",),
    )
    result = generation((withheld, pending, ready), (ready,), (finding,))
    bundle = render_acceptance(result)
    views = blocks(file_text(bundle, ".md"))
    assert views[0] == {"candidates": 3, "pending": 1, "ready": 1, "withheld": 1}
    assert views[1] == [finding.to_dict()]
    # The section ordering must not silently relabel withheld ready-looking input.
    assert [as_object(value)["status"] for value in views[2:]] == [
        "ready",
        "pending",
        "withheld",
    ]
    assert as_object(as_object(views[4])["specification"])["readiness"] == "ready"
    assert len(bundle.files) == 2
    assert (
        render_acceptance(generation((pending, ready, withheld), (ready,), (finding,)))
        == bundle
    )


def test_empty_and_blocked_generations_emit_markdown_only() -> None:
    """Keep empty/error-blocked results non-executable; return None without I/O."""
    item = specification()
    finding = Finding(
        code="INTEGRITY", message="Missing captured bytes.", next_action="Recapture."
    )
    # Both true emptiness and withheld candidates must remain explicit in Markdown.
    for result in (generation(), generation((item,), findings=(finding,))):
        bundle = render_acceptance(result)
        assert len(bundle.files) == 1
        assert bundle.files[0].path == "acceptance.md"
        assert blocks(file_text(bundle, ".md"))[0]


@pytest.mark.parametrize(
    "fields",
    [
        {"readiness": "unknown"},
        {"given": None},
        {"given": (1,)},
        {"when": None},
        {"then": ()},
        {"then": "invented"},
        {"then": (False,)},
    ],
)
def test_malformed_structural_candidates_are_not_executable(
    fields: dict[str, object],
) -> None:
    """Reject fields (dict[str, object], malformed steps/state) with ValueError.

    Return None without fallback construction, mutation or I/O.
    """
    item = changed(specification(), **fields)
    result = generation(
        (item,), () if fields.get("readiness") == "unknown" else (item,)
    )
    with pytest.raises(ValueError):
        render_acceptance(result)


@pytest.mark.parametrize("value", [None, {}, (), "ready"])
def test_only_exact_generation_carriers_are_accepted(value: object) -> None:
    """Reject value (object, untyped input) with ValueError; return None, no I/O."""
    with pytest.raises(ValueError, match="typed generation"):
        render_acceptance(cast("AcceptanceGeneration", value))


def test_public_carriers_are_immutable_sorted_and_encoding_checked() -> None:
    """Check structural file/bundle invariants; return None without I/O.

    No arguments; only local values change, independently of readiness or grants.
    """
    alpha = AcceptanceRenderedFile(path="a.feature", content=b"alpha\n")
    beta = AcceptanceRenderedFile(path="b.md", content="é\n".encode())
    assert AcceptanceRenderBundle(files=(beta, alpha)).files == (alpha, beta)
    assert AcceptanceRenderBundle(files=()).files == ()
    field = "path"
    with pytest.raises(FrozenInstanceError):
        setattr(alpha, field, "changed")
    with pytest.raises(ValueError, match="UTF-8"):
        AcceptanceRenderedFile(path="a", content=b"\xff")
    with pytest.raises(ValueError, match="string path and bytes"):
        AcceptanceRenderedFile(path=cast("str", 2), content=b"")
    with pytest.raises(ValueError, match="string path and bytes"):
        AcceptanceRenderedFile(path="a", content=cast("bytes", bytearray()))
    with pytest.raises(ValueError, match="immutable file tuple"):
        AcceptanceRenderBundle(files=cast("tuple[AcceptanceRenderedFile, ...]", []))
    with pytest.raises(ValueError, match="typed file"):
        AcceptanceRenderBundle(files=(cast("AcceptanceRenderedFile", "a"),))


@pytest.mark.parametrize(
    "paths",
    [("a", "a"), ("A", "a"), ("é", "e\u0301"), ("a", "a/b"), ("Docs/a", "docs/b")],
)
def test_portable_output_collisions_are_rejected(paths: tuple[str, str]) -> None:
    """Reject alias/ancestor paths (tuple[str, str]); return None without I/O."""
    # Literal files exercise portable collisions without changing any filesystem.
    files = tuple(AcceptanceRenderedFile(path=path, content=b"") for path in paths)
    with pytest.raises(ValueError):
        AcceptanceRenderBundle(files=files)


@pytest.mark.parametrize("path", ["/abs", "../escape", "a\\b", "CON", "a.", "a\x00b"])
def test_unsafe_file_paths_are_rejected(path: str) -> None:
    """Reject path (str, unsafe name) with ValueError; return None without I/O."""
    with pytest.raises(ValueError):
        AcceptanceRenderedFile(path=path, content=b"")


def test_exact_aggregate_bytes_include_paths_and_all_files() -> None:
    """Check exact bundle capacity and one-byte shortage.

    No inputs; return None, expecting ReportLimitError on shortage without I/O.
    """
    item = specification()
    original = generation((item,), (item,))
    expected = render_acceptance(original)
    # All retained paths and contents share one configured byte budget.
    size = sum(len(file.path) + len(file.content) for file in expected.files)
    assert (
        render_acceptance(replace(original, limits=ParseLimits(document_bytes=size)))
        == expected
    )
    with pytest.raises(ReportLimitError):
        render_acceptance(
            replace(original, limits=ParseLimits(document_bytes=size - 1))
        )


@pytest.mark.parametrize("kind", ["bytes", "work"])
def test_escape_and_text_work_are_reserved_before_serialization(
    monkeypatch: pytest.MonkeyPatch,
    kind: str,
) -> None:
    """Count serialization under kind (str, bytes/work) shortage.

    monkeypatch (pytest.MonkeyPatch) replaces the encoder after construction.
    No I/O or elapsed-time assertion is used. Return None; ReportLimitError must
    precede the first text copy.
    """
    item = specification(text="😀" * 2000 if kind == "bytes" else "x" * 2000)
    limits = (
        ParseLimits(document_bytes=22000)
        if kind == "bytes"
        else ParseLimits(artifact_records=500)
    )
    result = generation((item,), (item,), limits=limits)
    calls = 0
    original = cast("Callable[..., str]", json.dumps)

    def counted(value: object, **options: object) -> str:
        """Count value (object)/options (object keyword values); return JSON.

        Only the local counter changes; original encoder errors propagate, no I/O.
        """
        nonlocal calls
        calls += 1
        return original(value, **options)

    monkeypatch.setattr(json, "dumps", counted)
    with pytest.raises(ReportLimitError):
        render_acceptance(result)
    assert calls == 0


def test_public_carrier_hard_limits_reject_before_large_copy(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Lower hard ceilings using monkeypatch (pytest.MonkeyPatch).

    Return None after expected ReportLimitError; only test-local values change.
    """
    item = AcceptanceRenderedFile(path="a", content=b"1234")
    monkeypatch.setattr(gherkin, "_MAX_BYTES", 4)
    with pytest.raises(ReportLimitError):
        AcceptanceRenderedFile(path="a", content=b"1234")
    with pytest.raises(ReportLimitError):
        AcceptanceRenderBundle(files=(item,))
    monkeypatch.setattr(gherkin, "_MAX_FILES", 0)
    with pytest.raises(ReportLimitError):
        AcceptanceRenderBundle(files=(item,))


def test_json_trace_preserves_scalar_types_and_nested_sequences() -> None:
    """Preserve numbers, booleans and nulls; return None without I/O.

    No arguments; constructs local extension data without shared mutation.
    """
    item = changed(
        specification(),
        extensions={"values": [0, -2, 1.25, True, False, None, {"v": "x"}]},
    )
    bundle = render_acceptance(generation((item,), (item,)))
    trace = as_object(blocks(file_text(bundle, ".md"))[2])
    assert (
        as_object(trace["specification"])["extensions"] == item.to_dict()["extensions"]
    )
