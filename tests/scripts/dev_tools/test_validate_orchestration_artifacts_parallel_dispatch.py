"""CLI-dispatch tests for the two parallel orchestration artifact types.

Covers the `parallel-orchestrator-state` and `parallel-planner-state`
subparsers added to `scripts/dev_tools/validate_orchestration_artifacts.py`:
flag parsing, the `_validate_from_args` routing branches, and the `main`
exit-code contract with each gating flag off and on. The unknown-artifact-type
fallback is asserted here as well, confirming the additive wiring left the
`Unsupported artifact type: {type}` branch reachable and unchanged.

This is a new file rather than an addition to
`test_validate_orchestration_artifacts_dispatch.py` so that the existing epic
dispatch suite stays untouched and both files remain under the repository's
500-line limit. Checkpoint payloads come from the Phase 1 and Phase 2 builders
via sibling-module imports, following the convention already used by the epic
dispatch tests; every payload is serialized in memory with `json.dumps` and
injected through a monkeypatched `_read_text`, so no temporary file is created.
"""

from __future__ import annotations

import argparse
import json
from typing import TYPE_CHECKING, cast

import scripts.dev_tools.validate_orchestration_artifacts as validator

# The completion builder is reached through a module alias rather than a direct
# `from ... import` because the fully qualified module path exceeds the 88-column
# lint limit on a single import line.
from tests.scripts.dev_tools import (
    test_validate_parallel_orchestrator_state_completion as completion_tests,
)
from tests.scripts.dev_tools.test_validate_orchestration_artifacts import (
    build_read_text_stub,
)
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_valid_parallel_state,
)
from tests.scripts.dev_tools.test_validate_parallel_planner_state import (
    build_valid_planner_state,
)

if TYPE_CHECKING:
    from collections.abc import Callable

    from pytest import MonkeyPatch

ORCHESTRATOR_TYPE = "parallel-orchestrator-state"
PLANNER_TYPE = "parallel-planner-state"


def install_state(monkeypatch: MonkeyPatch, state: dict[str, object]) -> None:
    """Serialize a checkpoint and inject it through the validator's reader.

    Purpose:
        Replace the module-level `_read_text` seam so CLI dispatch can be
        exercised end to end without touching the filesystem.

    Args:
        monkeypatch (MonkeyPatch): Pytest fixture used to patch the reader.
        state (dict[str, object]): Checkpoint payload to serialize as the
            artifact text returned for any requested path.

    Returns:
        None.

    Raises:
        None.

    Side Effects:
        Rebinds `validator._read_text` for the duration of the test.
    """

    monkeypatch.setattr(
        validator, "_read_text", build_read_text_stub(json.dumps(state))
    )


def dispatch(namespace: argparse.Namespace) -> list[str]:
    """Invoke the private dispatch function with a prebuilt namespace.

    Purpose:
        Exercise `_validate_from_args` routing directly, bypassing argparse, so
        a routing regression is distinguishable from a parser regression.

    Args:
        namespace (argparse.Namespace): Parsed-argument stand-in naming the
            artifact type, path, and any gating flag.

    Returns:
        list[str]: Validation errors produced by the routed validator.

    Raises:
        None.

    Side Effects:
        Reads the artifact through the (monkeypatched) reader seam.
    """

    # Access the private dispatch function via vars() to avoid Pyright
    # reportPrivateUsage and Ruff B009 (getattr with constant) conflicts,
    # matching the approach in the epic dispatch test module.
    validate_from_args = cast(
        "Callable[[argparse.Namespace], list[str]]",
        vars(validator)["_validate_from_args"],
    )
    return validate_from_args(namespace)


def test_build_parser_accepts_parallel_orchestrator_state_require_complete() -> None:
    """The orchestrator subparser exposes `--require-complete` as a flag."""

    parser = validator.build_parser()

    args = parser.parse_args([ORCHESTRATOR_TYPE, "ignored.json", "--require-complete"])

    assert args.artifact_type == ORCHESTRATOR_TYPE
    assert args.path == "ignored.json"
    assert args.require_complete is True


def test_build_parser_defaults_parallel_orchestrator_require_complete_false() -> None:
    """Omitting the completion flag leaves the gate off, matching the default."""

    parser = validator.build_parser()

    args = parser.parse_args([ORCHESTRATOR_TYPE, "ignored.json"])

    assert args.require_complete is False


def test_build_parser_accepts_parallel_planner_state_require_ready() -> None:
    """The planner subparser exposes `--require-ready-for-execution` as a flag."""

    parser = validator.build_parser()

    args = parser.parse_args(
        [PLANNER_TYPE, "ignored.json", "--require-ready-for-execution"]
    )

    assert args.artifact_type == PLANNER_TYPE
    assert args.path == "ignored.json"
    assert args.require_ready_for_execution is True


def test_build_parser_defaults_parallel_planner_require_ready_false() -> None:
    """Omitting the readiness flag leaves the gate off, matching the default."""

    parser = validator.build_parser()

    args = parser.parse_args([PLANNER_TYPE, "ignored.json"])

    assert args.require_ready_for_execution is False


def test_validate_from_args_dispatches_parallel_orchestrator_state(
    monkeypatch: MonkeyPatch,
) -> None:
    """The orchestrator branch routes to the parallel orchestrator validator."""

    install_state(monkeypatch, build_valid_parallel_state())

    errors = dispatch(
        argparse.Namespace(
            path="ignored.json",
            artifact_type=ORCHESTRATOR_TYPE,
            require_complete=False,
        )
    )

    assert errors == []


def test_validate_from_args_dispatches_parallel_planner_state(
    monkeypatch: MonkeyPatch,
) -> None:
    """The planner branch routes to the parallel planner validator."""

    install_state(monkeypatch, build_valid_planner_state())

    errors = dispatch(
        argparse.Namespace(
            path="ignored.json",
            artifact_type=PLANNER_TYPE,
            require_ready_for_execution=False,
        )
    )

    assert errors == []


def test_validate_from_args_returns_unsupported_for_an_unknown_parallel_type(
    monkeypatch: MonkeyPatch,
) -> None:
    """An unknown artifact type still falls through to the unchanged fallback.

    Purpose:
        Confirm the two additive dispatch branches did not shadow or replace
        the terminal `Unsupported artifact type: {type}` message, which callers
        rely on for unrecognized input.

    Args:
        monkeypatch (MonkeyPatch): Pytest fixture used to inject artifact text
            in memory so no real file is required.

    Returns:
        None: Assertions verify the exact fallback error string.

    Raises:
        None.

    Side Effects:
        None.
    """

    monkeypatch.setattr(validator, "_read_text", build_read_text_stub("ignored"))

    errors = dispatch(
        argparse.Namespace(path="ignored.json", artifact_type="parallel-kickoff")
    )

    assert errors == ["Unsupported artifact type: parallel-kickoff"]


def test_main_parallel_orchestrator_state_returns_0_for_valid(
    monkeypatch: MonkeyPatch,
) -> None:
    """A structurally valid parallel checkpoint exits 0 with the gate off."""

    install_state(monkeypatch, build_valid_parallel_state())

    assert validator.main([ORCHESTRATOR_TYPE, "ignored.json"]) == 0


def test_main_parallel_orchestrator_state_returns_1_for_invalid(
    monkeypatch: MonkeyPatch,
) -> None:
    """A checkpoint carrying the wrong route identifier exits 1."""

    state = build_valid_parallel_state()
    state["route_id"] = "large"
    install_state(monkeypatch, state)

    assert validator.main([ORCHESTRATOR_TYPE, "ignored.json"]) == 1


def test_main_parallel_orchestrator_require_complete_returns_0_for_completed(
    monkeypatch: MonkeyPatch,
) -> None:
    """A closed-mode run whose items all merged satisfies the completion gate."""

    install_state(monkeypatch, completion_tests.build_completed_state())

    result = validator.main([ORCHESTRATOR_TYPE, "ignored.json", "--require-complete"])

    assert result == 0


def test_main_parallel_orchestrator_require_complete_returns_1_for_in_progress(
    monkeypatch: MonkeyPatch,
) -> None:
    """An in-progress run passes without the flag and fails the completion gate.

    Purpose:
        Prove the CLI actually threads `--require-complete` through to the
        validator: the same payload must produce different exit codes with the
        flag absent and present.

    Args:
        monkeypatch (MonkeyPatch): Pytest fixture used to inject checkpoint text
            in memory so no real file is required.

    Returns:
        None: Assertions verify exit code 0 without the flag and 1 with it.

    Raises:
        None.

    Side Effects:
        None.
    """

    install_state(monkeypatch, build_valid_parallel_state())

    assert validator.main([ORCHESTRATOR_TYPE, "ignored.json"]) == 0
    assert (
        validator.main([ORCHESTRATOR_TYPE, "ignored.json", "--require-complete"]) == 1
    )


def test_main_parallel_planner_state_returns_0_for_valid(
    monkeypatch: MonkeyPatch,
) -> None:
    """A structurally valid planner checkpoint exits 0 with the gate off."""

    install_state(monkeypatch, build_valid_planner_state())

    assert validator.main([PLANNER_TYPE, "ignored.json"]) == 0


def test_main_parallel_planner_state_returns_1_for_invalid(
    monkeypatch: MonkeyPatch,
) -> None:
    """A planner checkpoint missing its slug exits 1."""

    state = build_valid_planner_state()
    state["parallel_slug"] = ""
    install_state(monkeypatch, state)

    assert validator.main([PLANNER_TYPE, "ignored.json"]) == 1


def test_main_parallel_planner_require_ready_returns_0_for_ready(
    monkeypatch: MonkeyPatch,
) -> None:
    """A fully prepared planner checkpoint satisfies the readiness gate."""

    install_state(monkeypatch, build_valid_planner_state())

    result = validator.main(
        [PLANNER_TYPE, "ignored.json", "--require-ready-for-execution"]
    )

    assert result == 0


def test_main_parallel_planner_require_ready_returns_1_for_unready(
    monkeypatch: MonkeyPatch,
) -> None:
    """A checkpoint without the ready sentinel fails only when the gate is on.

    Purpose:
        Prove the CLI threads `--require-ready-for-execution` through to the
        validator: the same payload must produce different exit codes with the
        flag absent and present.

    Args:
        monkeypatch (MonkeyPatch): Pytest fixture used to inject checkpoint text
            in memory so no real file is required.

    Returns:
        None: Assertions verify exit code 0 without the flag and 1 with it.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_planner_state()
    state["next_step"] = "cohort_0_launch"
    install_state(monkeypatch, state)

    assert validator.main([PLANNER_TYPE, "ignored.json"]) == 0
    assert (
        validator.main([PLANNER_TYPE, "ignored.json", "--require-ready-for-execution"])
        == 1
    )
