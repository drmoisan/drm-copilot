"""Direct, single-threaded tests of the fix-all JSON cancel and runner paths.

Purpose:
    Assert the cancel invariant of ``fix_all_branches.run_json_branch`` and the
    branch-exception hardening of ``fix_all_runtime.run_fix_all._runner``
    without launching a single thread. The end-to-end tests in
    ``test_fix_all_failure_paths.py`` and ``test_fix_all.py`` establish the same
    invariant through the runtime, where the cancel signal has to be observed
    across lanes; here ``run_json_branch`` is called directly with the cancel
    event supplied as an input, so each outcome is a property of the arguments
    rather than of the operating-system scheduler (issue #505).

Responsibilities:
    Cover the three cancel branches of ``run_json_branch`` (cancel already set
    at the first check, cancel observed during the grace wait, and the
    ``complete_all`` override that runs validate anyway) plus the runtime path
    where a branch function raises.

Key invariants/constraints:
    No test in this module creates a thread, calls ``time.sleep``, waits on a
    real clock, or asserts anything about elapsed time, per the Determinism
    Infrastructure section of ``.claude/rules/general-unit-test.md``. The grace
    wait is exercised through an event stand-in whose ``wait`` returns
    immediately.

    The helper block below is local on purpose. It is deliberately NOT imported
    from ``tests/scripts/dev_tools/test_fix_all_failure_paths.py``: that module
    is at its file-size limit and its helpers are shaped for whole-pipeline
    runs, whereas these tests call one branch function directly.
"""

from __future__ import annotations

import threading
from typing import TYPE_CHECKING, cast

from scripts.dev_tools import fix_all
from scripts.dev_tools import fix_all_branches as branches

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable, Mapping, Sequence


# --- Local helper block ---


def make_command_result(code: int, output: str = "") -> fix_all.CommandResult:
    """Build a ``CommandResult`` carrying ``code`` and ``output``."""
    return fix_all.CommandResult(returncode=code, output=output)


class QueuedCommandRunner:
    """In-memory ``CommandRunner`` popping queued responses per step name.

    Attributes:
        responses: Remaining queued results, keyed by step name.
        calls: Step names in the order the branch requested them.
    """

    def __init__(
        self, responses: Mapping[str, Iterable[fix_all.CommandResult]]
    ) -> None:
        self.responses: dict[str, list[fix_all.CommandResult]] = {
            name: list(values) for name, values in responses.items()
        }
        self.calls: list[str] = []

    def run(self, command: Sequence[str], *, step_name: str) -> fix_all.CommandResult:
        """Record ``step_name`` and pop the next response queued for it."""
        del command
        self.calls.append(step_name)
        queued = self.responses.get(step_name)
        # A step with no queued response is a test-authoring error, not a
        # production path: raise rather than invent a return code.
        if not queued:
            raise AssertionError(f"No response configured for {step_name}")
        return queued.pop(0)


def make_json_runner_factory(
    runner: QueuedCommandRunner,
) -> Callable[[str, fix_all.StepLogger], QueuedCommandRunner]:
    """Return a branch factory handing ``runner`` to the json branch.

    Args:
        runner: The queued runner the json branch must receive.

    Returns:
        A callable matching the ``factory`` parameter of ``run_json_branch``.
    """

    def factory(
        branch_name: str, branch_logger: fix_all.StepLogger
    ) -> QueuedCommandRunner:
        """Return the configured runner, asserting the branch is json."""
        del branch_logger
        assert branch_name == "json"
        return runner

    return factory


class StatusRecorder:
    """Callable recording the status-board transitions it is handed.

    Attributes:
        transitions: ``(branch, status)`` pairs in emission order.
    """

    def __init__(self) -> None:
        self.transitions: list[tuple[str, str]] = []

    def __call__(self, branch: str, status: str) -> None:
        """Record one status-board transition."""
        self.transitions.append((branch, status))


class GraceWaitCancelEvent:
    """Cancel-event stand-in that becomes set when ``wait`` is called.

    Purpose:
        Model a sibling lane failing during the json lane's grace observation
        without depending on a real clock. ``wait`` flips the flag and returns
        immediately, so the branch takes the same path it would take if the
        sibling had set the event inside the grace window, with no elapsed-time
        dependency of any kind.

    Attributes:
        wait_timeouts: The timeout argument of each ``wait`` call, in order.
    """

    def __init__(self) -> None:
        self._flag = False
        self.wait_timeouts: list[float | None] = []

    def is_set(self) -> bool:
        """Return whether the stand-in is currently set."""
        return self._flag

    def wait(self, timeout: float | None = None) -> bool:
        """Record the timeout, become set, and return without waiting."""
        self.wait_timeouts.append(timeout)
        self._flag = True
        return True


# --- Direct run_json_branch cancel-branch tests (no threads) ---


def test_run_json_branch_canceled_at_first_check() -> None:
    """A cancel event set on entry stops the json lane after its format step."""
    # Arrange: the event is already set, so the first cancel check at
    # fix_all_branches.py line 102 decides the outcome. Only the format step has
    # a queued response, so a call to validate would raise rather than pass.
    cancel_event = threading.Event()
    cancel_event.set()
    runner = QueuedCommandRunner({"JSON: format": [make_command_result(0)]})
    recorder = StatusRecorder()

    # Act
    result = branches.run_json_branch(
        factory=make_json_runner_factory(runner),
        emit_status_transition=recorder,
        cancel_event=cancel_event,
        complete_all=False,
        api=fix_all,
    )

    # Assert: format ran, validate did not, and the lane reports Canceled.
    assert runner.calls == ["JSON: format"]
    assert result.success is False
    assert result.failed_step == "Canceled"
    assert ("json", "FAIL") in recorder.transitions


def test_run_json_branch_canceled_during_grace_wait() -> None:
    """A sibling failing during the grace observation cancels before validate."""
    # Arrange: the event is clear at the first check, so the branch reaches the
    # grace wait at fix_all_branches.py lines 111-112. The stand-in becomes set
    # inside that wait and returns immediately, so the second check at line 113
    # decides the outcome with no elapsed-time dependency.
    cancel_event = GraceWaitCancelEvent()
    runner = QueuedCommandRunner({"JSON: format": [make_command_result(0)]})
    recorder = StatusRecorder()

    # Act
    result = branches.run_json_branch(
        factory=make_json_runner_factory(runner),
        emit_status_transition=recorder,
        cancel_event=cast("threading.Event", cancel_event),
        complete_all=False,
        api=fix_all,
    )

    # Assert: the grace wait was consulted and validate never ran.
    assert cancel_event.wait_timeouts == [fix_all.CANCEL_CHECK_DELAY_S]
    assert result.success is False
    assert result.failed_step == "Canceled"
    assert "JSON: validate" not in runner.calls


def test_run_json_branch_complete_all_runs_validate() -> None:
    """complete_all overrides a set cancel event and still runs validation."""
    # Arrange: the event is set, so every cancel check would fire were it not
    # for complete_all short-circuiting all three of them (fix_all_branches.py
    # lines 102, 111, and 113). Both steps therefore need a queued response.
    cancel_event = threading.Event()
    cancel_event.set()
    runner = QueuedCommandRunner(
        {
            "JSON: format": [make_command_result(0)],
            "JSON: validate": [make_command_result(0)],
        }
    )
    recorder = StatusRecorder()

    # Act
    result = branches.run_json_branch(
        factory=make_json_runner_factory(runner),
        emit_status_transition=recorder,
        cancel_event=cancel_event,
        complete_all=True,
        api=fix_all,
    )

    # Assert: both steps ran and the lane succeeded despite the set event.
    assert "JSON: format" in runner.calls
    assert "JSON: validate" in runner.calls
    assert result.success is True
    assert result.failed_step is None
    assert ("json", "PASS") in recorder.transitions
