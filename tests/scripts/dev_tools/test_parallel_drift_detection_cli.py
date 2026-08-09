"""Tests for the parallel radius-drift detection command line.

Covers the argument surface of `scripts/dev_tools/parallel_drift_detection_cli.py`
(valid invocation, missing required argument, unknown argument), the dispatch from
`evaluate_drift` into the pure detection functions, and the reader helpers of
`scripts/dev_tools/_parallel_drift_cli_io.py`. Every checkpoint is in memory and
every file read goes through a stub, so no temporary file and no subprocess is used.

The halt-selection call-site tests live in
`test_parallel_drift_detection_cli_halt.py`, and the checkpoint fixtures both files
share live in `parallel_drift_test_support.py`.
"""

from __future__ import annotations

import copy
import json
import re
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._parallel_drift_cli_io import (
    DriftCliInputError,
    load_mapping,
    read_json_file,
)
from scripts.dev_tools.parallel_drift_detection_cli import (
    DEFAULT_CHECKPOINT_PATH,
    DEFAULT_CONFIG_PATH,
    EXIT_INPUT_ERROR,
    EXIT_OK,
    RESULT_HALT_REQUIRED,
    RESULT_NO_ESCAPE,
    RESULT_NO_NEW_CONFLICT,
    build_parser,
    default_timestamp,
    main,
)
from tests.scripts.dev_tools.parallel_drift_test_support import (
    AT,
    COMPUTED_AT,
    CONFIG,
    checkpoint,
    evaluate,
    in_flight,
    item,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Mapping, Sequence
    from pathlib import Path

# The three module attributes the command line calls. Patching them here, at the
# import locations the unit under test uses, is what keeps every test off the
# filesystem and off the clock.
LOAD_SEAM = "scripts.dev_tools.parallel_drift_detection_cli.load_mapping"
CLOCK_SEAM = "scripts.dev_tools.parallel_drift_detection_cli.default_timestamp"
ESCAPE_SEAM = "scripts.dev_tools.parallel_drift_detection_cli.detect_escaped_paths"

# One well-formed item record, reused by the malformed-collection matrix so each
# case varies exactly the field it is named for.
WELL_FORMED_ITEM: dict[str, object] = {
    "issue_num": 446,
    "blast_radius": {"paths": ["docs/**"]},
}

# The malformed-collection matrix, paired with the message fragment each case must
# produce. Typed explicitly so the parametrized argument is not partially unknown.
MALFORMED_STATES: list[tuple[dict[str, object], str]] = [
    ({"items": {}, "conflict_edges": []}, "items must be a list"),
    ({"items": [None], "conflict_edges": []}, r"items\[\] entries must be objects"),
    ({"items": [WELL_FORMED_ITEM]}, "conflict_edges must be a list"),
    ({"items": [{"issue_num": 446, "blast_radius": 1}]}, "blast_radius must be an"),
    ({"items": [{"issue_num": 446, "blast_radius": {}}]}, "paths must be a list"),
]


class _StubPath:
    """Filesystem stand-in exposing only the one method the reader calls.

    Purpose:
        Let `read_json_file` be exercised for real without touching disk, since
        the repository test policy forbids temporary files. Nothing else of
        `pathlib.Path` is implemented, because the reader uses nothing else, and
        no state changes after construction.

    Side Effects:
        None.

    Attributes:
        _text (str): The document body handed back to the reader.
    """

    def __init__(self, text: str) -> None:
        """Store the document body `read_text` will return.

        Args:
            text (str): The text `read_text` returns.

        Returns:
            None.
        """
        self._text = text

    def read_text(self, encoding: str = "utf-8") -> str:
        """Return the stored document body.

        Args:
            encoding (str): Accepted to match `pathlib.Path.read_text`, unused
                because the body is already a string.

        Returns:
            str: The stored text.
        """
        return self._text


def _load_seam(
    state: Mapping[str, object], config: Mapping[str, object]
) -> Callable[[Path, str], Mapping[str, object]]:
    """Build a replacement for the document-loading seam.

    Args:
        state (Mapping[str, object]): The checkpoint to hand back.
        config (Mapping[str, object]): The truth table to hand back.

    Returns:
        Callable[[Path, str], Mapping[str, object]]: A loader selecting its
        payload from the label the command line passes, so one stub serves both
        reads.
    """

    def _load(path: Path, label: str) -> Mapping[str, object]:
        """Return the payload matching the requested label."""
        return state if label == "Parallel checkpoint" else config

    return _load


def test_parser_accepts_a_valid_invocation() -> None:
    """Parse a full invocation into the documented namespace fields."""

    args = build_parser().parse_args(
        [
            "scripts/dev_tools/a.py",
            "docs/b.md",
            "--item-key=446",
            "--checkpoint=state.json",
            "--config=radius.json",
            f"--at={AT}",
            f"--computed-at={COMPUTED_AT}",
        ]
    )

    assert args.changed_paths == ["scripts/dev_tools/a.py", "docs/b.md"]
    assert args.item_key == 446
    assert args.checkpoint == "state.json"
    assert args.config == "radius.json"
    assert args.at == AT
    assert args.computed_at == COMPUTED_AT


def test_parser_defaults_every_optional_argument() -> None:
    """Default the paths and leave both timestamps unresolved for the boundary."""

    args = build_parser().parse_args(["--item-key", "446"])

    assert args.changed_paths == []
    assert args.checkpoint == DEFAULT_CHECKPOINT_PATH
    assert args.config == DEFAULT_CONFIG_PATH
    assert args.at is None
    assert args.computed_at is None


def test_parser_rejects_a_missing_required_argument() -> None:
    """Exit with argparse's usage status when --item-key is absent."""

    with pytest.raises(SystemExit) as failure:
        build_parser().parse_args(["scripts/dev_tools/a.py"])

    assert failure.value.code == 2


def test_parser_rejects_an_unknown_argument() -> None:
    """Exit with argparse's usage status on an option the parser does not define."""

    with pytest.raises(SystemExit) as failure:
        build_parser().parse_args(["--item-key", "446", "--halt-drifting-item"])

    assert failure.value.code == 2


def test_default_timestamp_uses_the_repository_timestamp_shape() -> None:
    """Derive the boundary default as a colon-free ISO-8601 minute stamp."""

    stamp = default_timestamp()

    assert re.fullmatch(r"\d{4}-\d{2}-\d{2}T\d{2}-\d{2}", stamp) is not None


def test_evaluate_drift_reports_no_escape_for_a_diff_inside_the_radius() -> None:
    """Report `no_escape` and record no event when nothing left the radius."""

    state = checkpoint([in_flight(446, ["docs/**"], "2026-08-08T09-00")])

    result = evaluate(state, ["docs/a.md"])

    assert result["result"] == RESULT_NO_ESCAPE
    assert result["escaped_paths"] == []
    assert result["newly_conflicting_pairs"] == []
    assert result["halted_item_keys"] == []
    assert result["drift_event"] is None


def test_evaluate_drift_reports_no_new_conflict_when_no_peer_contends() -> None:
    """Record the drift event but halt nothing when no peer newly conflicts."""

    peer = item(445, ["packages/mcp-server/**"], state="scheduled")
    state = checkpoint([in_flight(446, ["docs/**"], "2026-08-08T09-00"), peer])

    result = evaluate(state, ["packages/mcp-server/src/index.ts"])
    event = cast("Mapping[str, object]", result["drift_event"])

    assert result["result"] == RESULT_NO_NEW_CONFLICT
    assert result["escaped_paths"] == ["packages/mcp-server/src/index.ts"]
    assert result["newly_conflicting_pairs"] == []
    assert result["halted_item_keys"] == []
    assert event["action"] == "raised_blocking_finding"
    assert event["item_key"] == 446


def test_evaluate_drift_treats_an_unreadable_conflict_edge_as_absent() -> None:
    """Keep reporting the conflict when a recorded edge cannot be read."""

    state = checkpoint(
        [
            in_flight(446, ["docs/**"], "2026-08-08T09-00"),
            in_flight(445, ["packages/mcp-server/**"], "2026-08-08T08-00"),
        ],
        edges=[None, {"a": 445, "b": 447, "reason": "path_overlap"}],
    )

    result = evaluate(state, ["packages/mcp-server/src/index.ts"])

    assert result["newly_conflicting_pairs"] == [[445, 446]]


def test_evaluate_drift_leaves_the_checkpoint_untouched() -> None:
    """Read the checkpoint without mutating any of its collections."""

    state = checkpoint(
        [
            in_flight(446, ["docs/**"], "2026-08-08T09-00"),
            in_flight(445, ["packages/mcp-server/**"], "2026-08-08T08-00"),
        ],
        edges=[{"a": 445, "b": 446, "reason": "path_overlap"}],
    )
    snapshot = copy.deepcopy(state)

    evaluate(state, ["packages/mcp-server/src/index.ts"])

    assert state == snapshot


@pytest.mark.parametrize(("state", "expected"), MALFORMED_STATES)
def test_evaluate_drift_rejects_an_unusable_checkpoint_collection(
    state: Mapping[str, object], expected: str
) -> None:
    """Fail loudly rather than narrow the compared data on a malformed collection."""

    with pytest.raises(DriftCliInputError, match=expected):
        evaluate(state, ["packages/mcp-server/src/index.ts"])


def test_evaluate_drift_rejects_an_item_key_the_checkpoint_does_not_track() -> None:
    """Fail loudly when the requested item is absent from `items[]`."""

    state = checkpoint([in_flight(446, ["docs/**"], None)])

    with pytest.raises(DriftCliInputError, match="no items\\[\\] entry"):
        evaluate(state, ["docs/a.md"], item_key=999)


def test_main_prints_the_detection_result_as_json(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Serialize the halt verdict to stdout and return the success exit code."""

    state = checkpoint(
        [
            in_flight(446, ["docs/**"], "2026-08-08T09-00"),
            in_flight(445, ["packages/mcp-server/**"], "2026-08-08T08-00"),
        ]
    )
    monkeypatch.setattr(LOAD_SEAM, _load_seam(state, CONFIG))

    argv = ["packages/mcp-server/src/index.ts", "--item-key=446", f"--at={AT}"]
    status = main([*argv, f"--computed-at={COMPUTED_AT}"])
    payload = cast("dict[str, object]", json.loads(capsys.readouterr().out))

    assert status == EXIT_OK
    assert payload["result"] == RESULT_HALT_REQUIRED
    # The peer is halted, not the drifting item 446, which the call site excludes
    # from candidacy even though it carries the later `worktree_created_at`.
    assert payload["halted_item_keys"] == [445]
    assert payload["at"] == AT
    assert payload["computed_at"] == COMPUTED_AT


def test_main_defaults_both_timestamps_from_the_clock_boundary(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Derive `at` at the boundary and reuse it for `computed_at` when omitted."""

    state = checkpoint([in_flight(446, ["docs/**"], "2026-08-08T09-00")])
    monkeypatch.setattr(LOAD_SEAM, _load_seam(state, CONFIG))
    monkeypatch.setattr(CLOCK_SEAM, lambda: AT)

    status = main(["docs/a.md", "--item-key", "446"])
    payload = cast("dict[str, object]", json.loads(capsys.readouterr().out))

    assert status == EXIT_OK
    assert payload["at"] == AT
    assert payload["computed_at"] == AT


def test_main_dispatches_the_cli_inputs_into_the_pure_detection_function(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Forward the changed-path argument and the declared radius unchanged."""

    state = checkpoint([in_flight(446, ["docs/**"], "2026-08-08T09-00")])
    monkeypatch.setattr(LOAD_SEAM, _load_seam(state, CONFIG))
    captured: list[tuple[tuple[str, ...], tuple[str, ...]]] = []

    def _record(changed: Sequence[str], declared: Sequence[str]) -> tuple[str, ...]:
        """Record the arguments the command line passed and report no escape."""
        captured.append((tuple(changed), tuple(declared)))
        return ()

    monkeypatch.setattr(ESCAPE_SEAM, _record)

    status = main(["docs/a.md", "docs/b.md", "--item-key", "446", "--at", AT])
    capsys.readouterr()

    assert status == EXIT_OK
    assert captured == [(("docs/a.md", "docs/b.md"), ("docs/**",))]


@pytest.mark.parametrize(
    "failure",
    [
        OSError("checkpoint is unreadable"),
        DriftCliInputError("Parallel checkpoint items must be a list."),
    ],
)
def test_main_reports_an_unusable_input_on_stderr_with_a_nonzero_status(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    failure: Exception,
) -> None:
    """Keep stdout parseable by routing every input defect to stderr."""

    def _raise(path: Path, label: str) -> Mapping[str, object]:
        """Fail the way the real loader fails on an unusable document."""
        raise failure

    monkeypatch.setattr(LOAD_SEAM, _raise)

    status = main(["docs/a.md", "--item-key", "446", "--at", AT])
    captured = capsys.readouterr()

    assert status == EXIT_INPUT_ERROR
    assert captured.out == ""
    assert "parallel drift detection failed" in captured.err


def test_read_json_file_parses_the_document_through_the_path_seam() -> None:
    """Deserialize the document body the path object supplies."""

    document = read_json_file(cast("Path", _StubPath('{"items": []}')))

    assert document == {"items": []}


def test_load_mapping_returns_the_parsed_object() -> None:
    """Accept an object root and hand back the parsed mapping."""

    mapping = load_mapping(
        cast("Path", _StubPath('{"version": 1}')), "Blast-radius config"
    )

    assert mapping == {"version": 1}


def test_load_mapping_rejects_a_non_object_root() -> None:
    """Reject a document whose root is not a JSON object."""

    with pytest.raises(DriftCliInputError, match="must be a JSON object"):
        load_mapping(cast("Path", _StubPath("[]")), "Parallel checkpoint")
