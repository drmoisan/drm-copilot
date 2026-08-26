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
    The three direct ``run_json_branch`` tests call the branch function
    directly with no thread creation. ``time.sleep`` is never called, no test
    waits on a real clock, and no test asserts anything about elapsed time,
    per the Determinism Infrastructure section of
    ``.claude/rules/general-unit-test.md``. The grace wait is exercised
    through an event stand-in whose ``wait`` returns immediately.
    ``test_runner_records_failing_result_when_branch_raises`` deliberately
    drives the real ``fix_all.run_fix_all``, which spawns one thread per
    lane; determinism there comes from asserting only on recorded results,
    never on timing.

    The helper block below is local on purpose. It is deliberately NOT imported
    from ``tests/scripts/dev_tools/test_fix_all_failure_paths.py``: that module
    is at its file-size limit and its helpers are shaped for whole-pipeline
    runs, whereas these tests call one branch function directly.
"""

from __future__ import annotations

import threading
from io import StringIO
from typing import TYPE_CHECKING, cast

from scripts.dev_tools import fix_all
from scripts.dev_tools import fix_all_branches as branches

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable, Mapping, Sequence

    from pytest import MonkeyPatch


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


def build_logger() -> fix_all.StepLogger:
    """Build a ``StepLogger`` writing to an in-memory stream."""
    return fix_all.StepLogger(stream=StringIO())


def read_log(logger: fix_all.StepLogger) -> str:
    """Return everything written to ``logger``'s stream."""
    return cast("StringIO", logger.stream).getvalue()


def make_passing_branch_responses() -> (
    dict[str, dict[str, list[fix_all.CommandResult]]]
):
    """Return a response map where every step of every lane succeeds.

    The step names match the ``include_coverage=False`` spellings, so callers
    must pass ``include_coverage=False`` to ``run_fix_all``.
    """
    return {
        "json": {
            "JSON: format": [make_command_result(0)],
            "JSON: validate": [make_command_result(0)],
        },
        "shell": {
            "Shell: format": [make_command_result(0)],
            "Shell: check": [make_command_result(0)],
            "Shell: test": [make_command_result(0)],
        },
        "python": {
            "Black: format": [make_command_result(0)],
            "Ruff: lint": [make_command_result(0)],
            "Pyright: type-check": [make_command_result(0)],
            "Pytest: test": [make_command_result(0)],
        },
        "powershell": {
            "PoshQC: format": [make_command_result(0)],
            "PoshQC: analyze": [make_command_result(0)],
            "PoshQC: test": [make_command_result(0)],
        },
        "typescript": {
            "Prettier: format": [make_command_result(0)],
            "ESLint: lint": [make_command_result(0)],
            "TSC: type-check": [make_command_result(0)],
            "Jest: test": [make_command_result(0)],
        },
    }


class MultiBranchRunnerFactory:
    """Runner factory handing each lane its own queued runner.

    Attributes:
        runners: The runner built for each branch, keyed by branch name.
    """

    def __init__(
        self,
        responses_by_branch: Mapping[
            str, Mapping[str, Iterable[fix_all.CommandResult]]
        ],
    ) -> None:
        self.responses_by_branch = responses_by_branch
        self.runners: dict[str, QueuedCommandRunner] = {}

    def __call__(
        self, branch_name: str, branch_logger: fix_all.StepLogger
    ) -> QueuedCommandRunner:
        """Build, remember, and return the runner for ``branch_name``."""
        del branch_logger
        runner = QueuedCommandRunner(self.responses_by_branch[branch_name])
        self.runners[branch_name] = runner
        return runner


class RaisingJsonBranch:
    """Json branch stand-in that captures its cancel event, then raises.

    Purpose:
        Drive the runtime path where a branch function raises. ``run_fix_all``
        creates the cancel event as a local at ``fix_all_runtime.py`` line 30
        and neither accepts it as a parameter nor returns it, so the only seam
        through which a test can observe that object is the ``cancel_event``
        keyword argument the runtime passes to the json branch function at
        lines 89-96. This stand-in records the object before raising, which
        lets the caller assert on the event after the run has returned.

    Attributes:
        message: The distinctive text carried by the raised ``RuntimeError``.
        cancel_event: The event object the runtime supplied, or None if the
            stand-in was never called.
    """

    def __init__(self, message: str) -> None:
        self.message = message
        self.cancel_event: threading.Event | None = None

    def __call__(self, **kwargs: object) -> fix_all.BranchResult:
        """Capture the supplied cancel event and raise ``RuntimeError``."""
        self.cancel_event = cast("threading.Event", kwargs["cancel_event"])
        raise RuntimeError(self.message)


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


# --- Runtime branch-exception hardening (candidate G) ---


def test_runner_records_failing_result_when_branch_raises(
    monkeypatch: MonkeyPatch,
) -> None:
    """A raising branch function is recorded as FAIL, not silently dropped."""
    # Arrange (case 1): the json branch function raises; the other four lanes
    # are given a full set of successful responses, so the only thing that can
    # make the run fail is the raising lane. Without the _runner hardening the
    # thread dies, results["json"] stays unset, and the exit code computed over
    # recorded results only is 0 -- a silent false pass.
    message = "json branch raised: 505-runner-hardening-probe"
    raising_branch = RaisingJsonBranch(message)
    monkeypatch.setattr(branches, "run_json_branch", raising_branch)
    factory = MultiBranchRunnerFactory(make_passing_branch_responses())
    logger = build_logger()

    # Act
    exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=False,
        runner_factory=factory,
        logger=logger,
        complete_all=True,
    )

    # Assert: the run fails, the summary reports the lane as FAIL, and the
    # exception text reaches the operator through the branch log section.
    log = read_log(logger)
    assert exit_code == 1
    assert "Branch json: FAIL" in log
    assert "Branch json did not produce a result." not in log
    assert message in log

    # Arrange (case 2): the same scenario with complete_all off. The cancel
    # rule must still fire, so a lane that crashes stops the pipeline exactly
    # as a lane that returns a failing result does.
    fail_fast_branch = RaisingJsonBranch(message)
    monkeypatch.setattr(branches, "run_json_branch", fail_fast_branch)
    fail_fast_factory = MultiBranchRunnerFactory(make_passing_branch_responses())
    fail_fast_logger = build_logger()

    # Act
    fail_fast_exit_code = fix_all.run_fix_all(
        max_ruff_retries=1,
        include_coverage=False,
        runner_factory=fail_fast_factory,
        logger=fail_fast_logger,
        complete_all=False,
    )

    # Assert: the captured event is the runtime's own cancel event, and the
    # raising lane set it.
    assert fail_fast_exit_code == 1
    captured_event = fail_fast_branch.cancel_event
    assert captured_event is not None
    assert captured_event.is_set() is True
