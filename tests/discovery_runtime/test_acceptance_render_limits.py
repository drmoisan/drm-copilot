"""Check renderer-owned byte and prospective allocation boundaries in memory."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import acceptance_render_text, gherkin
from drm_copilot_discovery.acceptance_render_text import (
    AcceptanceTextOutput,
    utf8_path_size,
)
from drm_copilot_discovery.gherkin import (
    AcceptanceRenderBundle,
    AcceptanceRenderedFile,
    render_acceptance,
)
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.report_models import ReportLimitError

from tests.discovery_runtime.test_acceptance_properties import generation, specification
from tests.discovery_runtime.test_gherkin import changed, file_text

if TYPE_CHECKING:
    from collections.abc import Callable


@pytest.mark.parametrize(
    "path", ["abc", "éé", "漢😀"], ids=["ascii", "two-byte", "wide"]
)
def test_file_capacity_counts_raw_utf8_without_phantom_newline(
    monkeypatch: pytest.MonkeyPatch, path: str
) -> None:
    """Check path (str) at exact, spare and short raw capacities; return None.

    monkeypatch (pytest.MonkeyPatch) lowers only the local hard ceiling. Shortage
    raises ReportLimitError; no filesystem or shared fixture mutation occurs.
    """
    size = len(path.encode("utf-8")) + 1
    # Exact byte capacity and spare capacity must both admit the same file value.
    for ceiling in (size, size + 1):
        monkeypatch.setattr(gherkin, "_MAX_BYTES", ceiling)
        assert AcceptanceRenderedFile(path=path, content=b"x").path == path
    monkeypatch.setattr(gherkin, "_MAX_BYTES", size - 1)
    with pytest.raises(ReportLimitError):
        AcceptanceRenderedFile(path=path, content=b"x")
    with pytest.raises(ReportLimitError):
        AcceptanceRenderedFile(path="a", content=b"x" * size)


@pytest.mark.parametrize(
    "path", ["abc", "éé", "漢😀"], ids=["ascii", "two-byte", "wide"]
)
def test_bundle_capacity_sums_raw_utf8_paths_and_content(
    monkeypatch: pytest.MonkeyPatch, path: str
) -> None:
    """Check aggregate path (str) bytes using monkeypatch (pytest.MonkeyPatch).

    Return None; expect ReportLimitError one byte below the actual sum. All
    carriers are local immutable values and no I/O is performed.
    """
    first = AcceptanceRenderedFile(path=path, content=b"x")
    second = AcceptanceRenderedFile(path="z", content=b"yz")
    size = len(path.encode("utf-8")) + 4
    # The bundle counts raw bytes across both files, with no synthetic final LF.
    for ceiling in (size, size + 1):
        monkeypatch.setattr(gherkin, "_MAX_BYTES", ceiling)
        assert len(AcceptanceRenderBundle(files=(first, second)).files) == 2
    monkeypatch.setattr(gherkin, "_MAX_BYTES", size - 1)
    with pytest.raises(ReportLimitError):
        AcceptanceRenderBundle(files=(first, second))


def test_path_measurement_rejects_invalid_scalars_and_capacity_types() -> None:
    """Reject malformed path measurement before encoding; return None.

    No parameters; expect ValueError for invalid scalar/type/capacity and
    ReportLimitError for a too-small budget. Only local values are examined.
    """
    assert utf8_path_size("", limit=0) == 0
    # A bool must not silently become a capacity, and invalid Unicode never encodes.
    for value, limit in (("a", True), ("a", -1), (2, 10), ("\ud800", 10)):
        with pytest.raises(ValueError):
            utf8_path_size(cast("str", value), limit=limit)
    with pytest.raises(ReportLimitError):
        utf8_path_size("ab", limit=1)
    with pytest.raises(ValueError, match="Unicode"):
        AcceptanceRenderedFile(path="\udfff", content=b"")


@pytest.mark.parametrize("kind", ["depth", "nodes", "records", "sequence"])
def test_json_container_limits_reject_before_encoder(
    monkeypatch: pytest.MonkeyPatch, kind: str
) -> None:
    """Reject kind (str) capacity before encoding; return None.

    monkeypatch (pytest.MonkeyPatch) counts only local encoder calls. Direct
    output-budget controls target the renderer's own guards, not model proof.
    Expected ReportLimitError propagates without I/O or partial output.
    """
    output = AcceptanceTextOutput(ParseLimits(nesting_depth=1))
    values: dict[str, object] = {
        "depth": (("x",),),
        "nodes": None,
        "records": {},
        "sequence": (1, 2),
    }
    # Each guard has a distinct capacity and rejects before any detached copy.
    if kind == "nodes":
        output.budget.nodes_left = 0
    elif kind == "records":
        output.budget.records_left = 0
    elif kind == "sequence":
        output.budget.nodes_left = 2
    calls = 0

    def forbidden(value: object, **options: object) -> str:
        """Count value (object)/options (object keyword values); raise AssertionError.

        This local encoder sentinel must remain unused; no I/O occurs.
        """
        nonlocal calls
        calls += 1
        raise AssertionError("encoder called before capacity rejection")

    monkeypatch.setattr(json, "dumps", forbidden)
    with pytest.raises(ReportLimitError):
        output.json(values[kind])
    assert calls == 0


def test_json_unicode_scalar_guard_precedes_encoding() -> None:
    """Reject malformed Unicode with ValueError; return None without I/O.

    No parameters; directly checks the renderer-owned encoder's scalar boundary.
    """
    with pytest.raises(ValueError, match="Unicode"):
        AcceptanceTextOutput(ParseLimits()).json("\ud800")


@pytest.mark.parametrize("shortage", [False, True])
def test_escaped_output_work_is_reserved_before_detachment_and_encoding(
    monkeypatch: pytest.MonkeyPatch, shortage: bool
) -> None:
    """Count escaped work with shortage (bool); return None.

    monkeypatch (pytest.MonkeyPatch) observes local detachment and JSON encoding.
    Exact work succeeds; one-unit shortage raises ReportLimitError before either
    allocation boundary. No timing assertion, I/O or shared mutation occurs.
    """
    value = "😀" * 16
    escaped_bytes = 2 + 12 * len(value)
    required = 4 + 20 * len(value) + 16 * escaped_bytes
    output = AcceptanceTextOutput(ParseLimits())
    output.budget.work_left = required - int(shortage)
    detached = 0
    encoded = 0
    original_plain = cast(
        "Callable[[object], object]", vars(acceptance_render_text)["_plain"]
    )
    original_json = cast("Callable[..., str]", json.dumps)

    def plain(item: object) -> object:
        """Count item (object) detachment; return original data, no I/O.

        Only the local counter changes; original errors propagate.
        """
        nonlocal detached
        detached += 1
        return original_plain(item)

    def encode(item: object, **options: object) -> str:
        """Count item (object)/options (object keyword values); return JSON.

        Only the local counter changes; original errors propagate, no I/O.
        """
        nonlocal encoded
        encoded += 1
        return original_json(item, **options)

    monkeypatch.setattr(acceptance_render_text, "_plain", plain)
    monkeypatch.setattr(json, "dumps", encode)
    # Shortage must be discovered after measurement but before either copy seam.
    if shortage:
        with pytest.raises(ReportLimitError):
            output.json(value)
        assert detached == encoded == 0
    else:
        result = output.json(value)
        assert json.loads(result) == value
        assert len(result) == escaped_bytes
        assert output.budget.work_left == 0
        assert detached == encoded == 1


def test_tag_prefix_and_existing_tag_are_reserved_before_joining(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Observe tag identity using monkeypatch (pytest.MonkeyPatch); return None.

    A full-capacity control retains exact spelling. The short-capacity control
    raises ReportLimitError while receiving the existing tag, before prefix
    concatenation. Only local counters/values change; no I/O occurs.
    """
    item = changed(specification(), tags=("@" + "a" * 128,))
    result = generation((item,), (item,))
    tag = cast("tuple[str, ...]", result.ready[0].document["tags"])[0]
    assert f"\n  {tag}\n  Scenario:" in file_text(render_acceptance(result), ".feature")
    original = AcceptanceTextOutput.fixed
    seen: list[str] = []

    def fixed(output: AcceptanceTextOutput, value: str) -> str:
        """Observe output (AcceptanceTextOutput)/value (str); return original text.

        Exhaust only the local tag byte capacity; propagate ReportLimitError.
        No I/O or caller-owned data mutation occurs.
        """
        seen.append(value)
        if value.endswith(tag):
            output.budget.bytes_left = len(tag) - 1
        return original(output, value)

    monkeypatch.setattr(AcceptanceTextOutput, "fixed", fixed)
    with pytest.raises(ReportLimitError):
        render_acceptance(result)
    assert seen[-2] == "  "
    assert seen[-1] is tag
