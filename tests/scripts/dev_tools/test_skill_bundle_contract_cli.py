"""Unit tests for the skill bundle guard CLI entry point.

Covers ``main`` in ``scripts/dev_tools/skill_bundle_contract_cli.py`` with an
injected loader that returns an inline snapshot, so no test touches the
filesystem. Every path is fictitious.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools.skill_bundle_contract import SkillBundleInputs
from scripts.dev_tools.skill_bundle_contract_cli import main

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    import pytest

_SCRIPT = ".claude/lib/example/example.sh"
_UNBUNDLED = "scripts/tools/example.sh"
_DRIFT_CLI = "scripts/dev_tools/parallel_drift_detection_cli.py"
_ABANDON_CLI = "scripts/dev_tools/parallel_mutation_abandon_cli.py"


def _loader(inputs: SkillBundleInputs) -> Callable[[Path], SkillBundleInputs]:
    """Return a loader that ignores the root and yields the given snapshot.

    Args:
        inputs (SkillBundleInputs): Snapshot to return.

    Returns:
        Callable[[Path], SkillBundleInputs]: The injected loader.
    """

    def load(_root: Path) -> SkillBundleInputs:
        """Return the captured snapshot for any repository root.

        Args:
            _root (Path): Ignored repository root.

        Returns:
            SkillBundleInputs: The captured snapshot.
        """

        return inputs

    return load


def _clean_inputs(*, extra_skill_text: str = "") -> SkillBundleInputs:
    """Build a snapshot whose only findings are the two registered exceptions.

    Args:
        extra_skill_text (str): Text appended to the demo skill body.

    Returns:
        SkillBundleInputs: Snapshot in which both #763 exceptions match a
        violation and the demo skill's bundled script is carried by core.
    """

    return SkillBundleInputs(
        skill_texts={
            "demo-skill": f"Run `bash {_SCRIPT}`.{extra_skill_text}",
            "parallel-orchestrate": f"Run `python {_DRIFT_CLI}`.",
            "parallel-remove": f"Run `python {_ABANDON_CLI}`.",
        },
        skill_folder_files={},
        repository_files=frozenset({_SCRIPT, _UNBUNDLED, _DRIFT_CLI, _ABANDON_CLI}),
        bundle_files=frozenset({_SCRIPT}),
        pack_paths={"core": frozenset({_SCRIPT})},
    )


def test_main_returns_zero_when_clean() -> None:
    """A snapshot with no unregistered finding exits 0."""

    # Arrange
    loader = _loader(_clean_inputs())

    # Act
    exit_code = main([], loader=loader)

    # Assert
    assert exit_code == 0, f"Expected 0, got {exit_code}"


def test_main_returns_one_and_prints_violation_lines(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """An unbundled reference exits 1 and prints one violation line."""

    # Arrange
    loader = _loader(_clean_inputs(extra_skill_text=f" Then `bash {_UNBUNDLED}`."))

    # Act
    exit_code = main([], loader=loader)

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 1, f"Expected 1, got {exit_code}"
    assert captured.err.splitlines() == [
        f"skill-bundle violation: demo-skill | {_UNBUNDLED} | not-in-bundle"
    ], captured.err


def test_main_returns_one_for_stale_exception(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """An exception whose violation disappeared exits 1 and is reported."""

    # Arrange
    clean = _clean_inputs()
    # Drop the parallel-remove skill so its registered exception matches nothing.
    stale_inputs = SkillBundleInputs(
        skill_texts={
            name: text
            for name, text in clean.skill_texts.items()
            if name != "parallel-remove"
        },
        skill_folder_files=clean.skill_folder_files,
        repository_files=clean.repository_files,
        bundle_files=clean.bundle_files,
        pack_paths=clean.pack_paths,
    )

    # Act
    exit_code = main([], loader=_loader(stale_inputs))

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 1, f"Expected 1, got {exit_code}"
    assert captured.err.splitlines() == [
        f"skill-bundle stale exception: parallel-remove | {_ABANDON_CLI} | #763"
    ], captured.err


def test_main_prints_nothing_to_stderr_when_clean(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A clean snapshot writes nothing to stderr."""

    # Arrange
    loader = _loader(_clean_inputs())

    # Act
    main([], loader=loader)

    # Assert
    captured = capsys.readouterr()
    assert captured.err == "", f"Expected empty stderr, got {captured.err!r}"
