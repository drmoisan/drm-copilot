"""Unit tests for the parallel abandon CLI, exercised through the runner seam.

Covers the spec Test Strategy scenarios for the abandon path: the CLI refuses
without the confirmation marker, invokes exactly the ``gh pr close`` and
``git worktree remove`` argument vectors once each when confirmed, and propagates
a failed side effect as a non-zero exit with a specific error.

Determinism: every test injects its own runner, so no test invokes live ``gh`` or
``git`` and no subprocess is ever started. The one test that covers the
production subprocess runner substitutes both ``shutil.which`` and
``subprocess.run`` via ``monkeypatch``, so it too starts no process. No test
creates a temporary file or reads the wall clock.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import parallel_mutation_abandon_cli as cli
from scripts.dev_tools._parallel_state_common import VALID_DISPOSITIONS

if TYPE_CHECKING:
    from collections.abc import Sequence

# The pull request and worktree every test acts on.
PR_NUMBER = 77
WORKTREE_PATH = ".claude/worktrees/item-442"

# The item key every test names, an ``int`` per F3's ``items[].issue_num``.
ITEM_KEY = 442

# The argument vectors the CLI must produce, in execution order.
EXPECTED_CLOSE_ARGV = ["gh", "pr", "close", str(PR_NUMBER)]
EXPECTED_REMOVE_ARGV = ["git", "worktree", "remove", WORKTREE_PATH]


class RecordingRunner:
    """A command runner that records its calls instead of running them.

    Purpose and responsibilities:
        Stand in for the production subprocess runner so a test can assert the
        exact argument vectors the CLI produced, and can force a failure at a
        chosen call, without any process ever starting.

    Usage and invariants:
        Constructed with the exit code to report and, optionally, the 1-based
        call index that should fail. Passed to ``cli.main`` as the ``runner``
        argument. ``calls`` preserves invocation order.

    Attributes:
        calls (list[list[str]]): Every argument vector received, in order.
        failing_call (int | None): The 1-based call index to fail, or None to
            report success for every call.
        failure_code (int): The exit code reported for the failing call.
    """

    def __init__(self, failing_call: int | None = None, failure_code: int = 3) -> None:
        """Configure the runner's recording and failure behavior.

        Args:
            failing_call (int | None): The 1-based call index to fail. None
                makes every call succeed.
            failure_code (int): The non-zero code the failing call reports.

        Returns:
            None.

        Side Effects:
            None.
        """

        self.calls: list[list[str]] = []
        self.failing_call = failing_call
        self.failure_code = failure_code

    def __call__(self, argv: Sequence[str]) -> int:
        """Record one invocation and report its exit code.

        Args:
            argv (Sequence[str]): The command vector the CLI built.

        Returns:
            int: ``failure_code`` when this call is the configured failing one,
            otherwise 0.

        Side Effects:
            Appends to ``calls``.
        """

        self.calls.append(list(argv))
        if self.failing_call is not None and len(self.calls) == self.failing_call:
            return self.failure_code
        return 0


def abandon_argv(*, confirm: bool, disposition: str = "abandon") -> list[str]:
    """Build the CLI argument vector for one abandon invocation.

    Args:
        confirm (bool): Whether to include the confirmation marker.
        disposition (str): The disposition to request.

    Returns:
        list[str]: The argument vector, excluding the program name.

    Raises:
        None.

    Side Effects:
        None.
    """

    argv = [
        "--item",
        str(ITEM_KEY),
        "--disposition",
        disposition,
        "--pr",
        str(PR_NUMBER),
        "--worktree",
        WORKTREE_PATH,
    ]
    if confirm:
        argv.append(cli.CONFIRM_ABANDON_TOKEN)
    return argv


class TestTokenWiring:
    """The parser is built from the exported tokens, not from loose literals."""

    def test_confirmation_flag_is_wired_into_the_parser(self) -> None:
        """The confirmation token appears in some action's option strings."""

        parser = cli.build_parser()

        wired = any(
            cli.CONFIRM_ABANDON_TOKEN in action.option_strings
            for action in parser._actions  # pyright: ignore[reportPrivateUsage]
        )
        assert wired

    def test_disposition_token_is_composed_from_the_parser_surface(self) -> None:
        """The option string plus the ``abandon`` choice compose the token."""

        # Arrange
        parser = cli.build_parser()
        action = next(
            candidate
            for candidate in parser._actions  # pyright: ignore[reportPrivateUsage]
            if cli.DISPOSITION_OPTION in candidate.option_strings
        )

        # Act
        composed = f"{cli.DISPOSITION_OPTION} {cli.ABANDON_DISPOSITION}"

        # Assert
        assert composed == cli.ABANDON_DISPOSITION_TOKEN
        assert cli.ABANDON_DISPOSITION in (action.choices or ())

    def test_disposition_choices_come_from_the_f3_enum(self) -> None:
        """The CLI consumes F3's disposition enum rather than restating it."""

        parser = cli.build_parser()
        action = next(
            candidate
            for candidate in parser._actions  # pyright: ignore[reportPrivateUsage]
            if cli.DISPOSITION_OPTION in candidate.option_strings
        )

        assert tuple(action.choices or ()) == VALID_DISPOSITIONS

    def test_item_key_is_parsed_as_an_integer(self) -> None:
        """F3's ``items[].issue_num`` is an ``int``, so the CLI parses one."""

        namespace = cli.build_parser().parse_args(abandon_argv(confirm=True))

        assert namespace.item == ITEM_KEY
        assert isinstance(namespace.item, int)


class TestRefusalWithoutConfirmation:
    """The CLI performs no side effect unless the marker is present."""

    def test_missing_marker_exits_non_zero(self) -> None:
        """A missing confirmation marker is refused."""

        exit_code = cli.main(abandon_argv(confirm=False), RecordingRunner())

        assert exit_code == cli.EXIT_REFUSED
        assert exit_code != 0

    def test_missing_marker_performs_no_side_effect(self) -> None:
        """A refused invocation never reaches the runner."""

        runner = RecordingRunner()

        cli.main(abandon_argv(confirm=False), runner)

        assert runner.calls == []

    def test_missing_marker_reports_a_specific_error(
        self, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """The refusal names the marker the caller omitted."""

        cli.main(abandon_argv(confirm=False), RecordingRunner())

        stderr = capsys.readouterr().err
        assert cli.ERROR_PREFIX in stderr
        assert cli.CONFIRM_ABANDON_TOKEN in stderr

    def test_a_detach_disposition_is_refused(self) -> None:
        """This CLI executes the abandon path only."""

        runner = RecordingRunner()

        exit_code = cli.main(abandon_argv(confirm=True, disposition="detach"), runner)

        assert exit_code == cli.EXIT_REFUSED
        assert runner.calls == []

    def test_a_disposition_outside_the_enum_is_rejected_by_argparse(self) -> None:
        """An unknown disposition never reaches the CLI's own logic."""

        with pytest.raises(SystemExit):
            cli.main(abandon_argv(confirm=True, disposition="delete"))


class TestConfirmedAbandon:
    """With the marker present both side effects run exactly once, in order."""

    def test_confirmed_abandon_exits_zero(self) -> None:
        """A successful abandon reports success."""

        exit_code = cli.main(abandon_argv(confirm=True), RecordingRunner())

        assert exit_code == cli.EXIT_OK

    def test_confirmed_abandon_invokes_both_vectors_once_each(self) -> None:
        """The runner receives exactly the two expected vectors, in order."""

        runner = RecordingRunner()

        cli.main(abandon_argv(confirm=True), runner)

        assert runner.calls == [EXPECTED_CLOSE_ARGV, EXPECTED_REMOVE_ARGV]

    def test_the_pull_request_is_closed_before_the_worktree_is_removed(self) -> None:
        """Removing the worktree first would orphan an open pull request."""

        runner = RecordingRunner()

        cli.main(abandon_argv(confirm=True), runner)

        assert runner.calls[0][:3] == ["gh", "pr", "close"]
        assert runner.calls[1][:3] == ["git", "worktree", "remove"]

    def test_argument_vector_builders_produce_the_documented_vectors(self) -> None:
        """The builders are the single source of each vector's shape."""

        assert cli.close_pull_request_argv(PR_NUMBER) == EXPECTED_CLOSE_ARGV
        assert cli.remove_worktree_argv(WORKTREE_PATH) == EXPECTED_REMOVE_ARGV


class TestFailedSideEffect:
    """A failed side effect exits non-zero with a specific error."""

    def test_a_failed_pull_request_close_exits_non_zero(self) -> None:
        """The first side effect failing stops the sequence."""

        runner = RecordingRunner(failing_call=1)

        exit_code = cli.main(abandon_argv(confirm=True), runner)

        assert exit_code == cli.EXIT_SIDE_EFFECT_FAILED
        assert runner.calls == [EXPECTED_CLOSE_ARGV]

    def test_a_failed_worktree_removal_exits_non_zero(self) -> None:
        """The second side effect failing is reported after the first ran."""

        runner = RecordingRunner(failing_call=2)

        exit_code = cli.main(abandon_argv(confirm=True), runner)

        assert exit_code == cli.EXIT_SIDE_EFFECT_FAILED
        assert runner.calls == [EXPECTED_CLOSE_ARGV, EXPECTED_REMOVE_ARGV]

    def test_a_failed_side_effect_reports_the_command_and_code(
        self, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """The error names which command failed and with what code."""

        cli.main(abandon_argv(confirm=True), RecordingRunner(failing_call=1))

        stderr = capsys.readouterr().err
        assert cli.ERROR_PREFIX in stderr
        assert "gh pr close" in stderr
        assert "3" in stderr

    def test_execute_abandon_raises_on_a_failed_command(self) -> None:
        """The engine-facing helper raises rather than returning a code."""

        with pytest.raises(cli.AbandonSideEffectError) as caught:
            cli.execute_abandon(
                PR_NUMBER, WORKTREE_PATH, RecordingRunner(failing_call=1)
            )

        assert caught.value.argv == tuple(EXPECTED_CLOSE_ARGV)
        assert caught.value.exit_code == 3


class TestSubprocessRunner:
    """The production runner, covered without starting a process."""

    def test_the_runner_resolves_the_executable_and_returns_its_code(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """The runner resolves through PATH and reports the process code."""

        # Arrange: substitute both boundary calls so nothing is executed.
        received: dict[str, object] = {}

        def fake_which(name: str) -> str:
            """Return a resolved path for any executable name."""
            received["which"] = name
            return f"/usr/bin/{name}"

        class FakeCompleted:
            """Minimal stand-in for a completed process."""

            returncode = 5

        def fake_run(command: Sequence[str], *, check: bool) -> FakeCompleted:
            """Record the command and return a fake completed process."""
            received["command"] = list(command)
            received["check"] = check
            return FakeCompleted()

        monkeypatch.setattr(cli.shutil, "which", fake_which)
        monkeypatch.setattr(cli.subprocess, "run", fake_run)

        # Act
        exit_code = cli.run_with_subprocess(EXPECTED_CLOSE_ARGV)

        # Assert
        assert exit_code == 5
        assert received["which"] == "gh"
        assert received["command"] == ["/usr/bin/gh", "pr", "close", str(PR_NUMBER)]
        assert received["check"] is False

    def test_an_unresolvable_executable_raises_without_running_anything(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """A missing executable is reported as exit code -1, since none ran."""

        # Arrange

        def unresolvable_which(name: str) -> str | None:
            """Report that no executable resolves for any name."""
            return None

        monkeypatch.setattr(cli.shutil, "which", unresolvable_which)

        # Act / Assert
        with pytest.raises(cli.AbandonSideEffectError) as caught:
            cli.run_with_subprocess(EXPECTED_CLOSE_ARGV)
        assert caught.value.exit_code == -1
        assert caught.value.argv == tuple(EXPECTED_CLOSE_ARGV)
