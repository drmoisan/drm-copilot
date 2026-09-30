"""Unit tests for the skill bundle guard CLI entry point.

Covers ``main`` in ``scripts/dev_tools/skill_bundle_contract_cli.py`` with an
injected loader that returns an inline snapshot, so no test touches the
filesystem. The default exception registry is empty since issue #763, so the
suppression and staleness branches are exercised through the injected
``exceptions`` registry. Every path is fictitious.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools.skill_bundle_contract import (
    KnownUnbundledReference,
    SkillBundleInputs,
)
from scripts.dev_tools.skill_bundle_contract_cli import main

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    import pytest

_SCRIPT = ".claude/lib/example/example.sh"
_UNBUNDLED = "scripts/tools/example.sh"


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
    """Build a snapshot with no finding.

    Args:
        extra_skill_text (str): Text appended to the demo skill body.

    Returns:
        SkillBundleInputs: Snapshot in which the demo skill's only reference is
        a bundled script carried by the core pack.
    """

    return SkillBundleInputs(
        skill_texts={"demo-skill": f"Run `bash {_SCRIPT}`.{extra_skill_text}"},
        skill_folder_files={},
        repository_files=frozenset({_SCRIPT, _UNBUNDLED}),
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
    """An injected exception that matches no violation exits 1 and is reported."""

    # Arrange
    stale = KnownUnbundledReference("demo-skill", _UNBUNDLED, "#1")

    # Act
    exit_code = main([], loader=_loader(_clean_inputs()), exceptions=(stale,))

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 1, f"Expected 1, got {exit_code}"
    assert captured.err.splitlines() == [
        f"skill-bundle stale exception: demo-skill | {_UNBUNDLED} | #1"
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


def test_main_suppresses_a_registered_exception(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A violation matched by an injected exception exits 0 with empty stderr."""

    # Arrange
    inputs = _clean_inputs(extra_skill_text=f" Then `bash {_UNBUNDLED}`.")
    registered = KnownUnbundledReference("demo-skill", _UNBUNDLED, "#1")

    # Act
    exit_code = main([], loader=_loader(inputs), exceptions=(registered,))

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 0, f"Expected 0, got {exit_code}"
    assert captured.err == "", f"Expected empty stderr, got {captured.err!r}"
