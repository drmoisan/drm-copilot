"""Unit tests for the quality-tiers CLI and its I/O boundary.

The manifest reader, the tracked-file lister, the git runner, and the git
executable resolver are all injected, so no test reads the real manifest, starts
a process, or creates a file. Fake git results are ``FakeRunResult`` instances.
"""

from __future__ import annotations

import functools
import re
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.check_quality_tiers import (
    list_tracked_files,
    main,
    read_manifest_text,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence

_QT_LINE = re.compile(r"^QT\d{3}: ")

SMALL_MANIFEST_TEXT = """\
version: 1
projects:
  - path: "."
    tier: "T4"
    rationale: "Root scaffold."
  - path: "scripts/bash"
    tier: "T4"
    rationale: "Shell QC scripts."
"""

SMALL_TRACKED_FILES = ["package.json", "scripts/bash/run-coverage.sh"]

COMMITTED_STYLE_TEXT_WITHOUT_SCRIPTS_BASH = """\
# tier-classification in the quality-checks workflow validates this file.
version: 1
projects:
  - path: "."
    tier: "T4"
    rationale: "Root TypeScript scaffold and tool configuration only"
  - path: "extensions/drm-copilot"
    tier: "T3"
    rationale: "VS Code extension and MCP server"
  - path: "scripts/dev_tools"
    tier: "T4"
    rationale: "Repository-internal Python dev tooling"
"""

COMMITTED_STYLE_TRACKED_FILES = [
    "package.json",
    "extensions/drm-copilot/package.json",
    "scripts/dev_tools/check_quality_tiers.py",
    "scripts/bash/run-coverage.sh",
]


@dataclass(frozen=True)
class FakeRunResult:
    """Test-local stand-in for a completed git process."""

    returncode: int
    stdout: bytes


def _reader(text: str) -> Callable[[Path], str]:
    """Return a manifest reader that ignores its path and returns ``text``."""

    def read(path: Path) -> str:
        del path
        return text

    return read


def _tracked(paths: Sequence[str]) -> Callable[[Path], list[str]]:
    """Return a tracked-file lister that returns ``paths``."""

    def list_files(repo_root: Path) -> list[str]:
        del repo_root
        return list(paths)

    return list_files


def _assert_failure_output(captured: pytest.CaptureResult[str]) -> list[str]:
    """Assert stdout is empty and every stderr line carries a QT prefix."""
    assert captured.out == "", f"stdout must be empty on failure: {captured.out!r}"
    lines = captured.err.splitlines()
    assert lines, "a failure must write at least one stderr line"
    for line in lines:
        assert _QT_LINE.match(line), f"stderr line lacks a QT prefix: {line!r}"
    return lines


def test_main_returns_zero_and_prints_summary_for_valid_manifest(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A manifest matching the tracked tree exits 0 with one summary line."""
    # Act
    exit_code = main(
        [],
        read_manifest_text=_reader(SMALL_MANIFEST_TEXT),
        list_tracked_files=_tracked(SMALL_TRACKED_FILES),
    )

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 0
    assert captured.err == ""
    lines = captured.out.splitlines()
    assert len(lines) == 1
    assert lines[0].startswith("quality-tiers: OK")
    assert lines[0] == "quality-tiers: OK (2 entries, 2 discovered projects)"


def test_main_returns_one_with_qt001_when_manifest_missing(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A reader raising ``FileNotFoundError`` yields QT001 and exit 1."""

    # Arrange
    def missing(path: Path) -> str:
        raise FileNotFoundError(2, "No such file or directory", str(path))

    # Act
    exit_code = main(
        [], read_manifest_text=missing, list_tracked_files=_tracked(SMALL_TRACKED_FILES)
    )

    # Assert
    lines = _assert_failure_output(capsys.readouterr())
    assert exit_code == 1
    assert [line[:5] for line in lines] == ["QT001"]


def test_main_returns_one_with_qt002_and_skips_git_for_invalid_yaml(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Invalid YAML yields QT002 and the tracked-file lister is never called."""
    # Arrange
    calls: list[Path] = []

    def recording_lister(repo_root: Path) -> list[str]:
        calls.append(repo_root)
        return []

    # Act
    exit_code = main(
        [],
        read_manifest_text=_reader("projects: [unclosed\n"),
        list_tracked_files=recording_lister,
    )

    # Assert
    lines = _assert_failure_output(capsys.readouterr())
    assert exit_code == 1
    assert [line[:5] for line in lines] == ["QT002"]
    assert calls == []


def test_main_returns_one_with_qt009_when_runner_raises_oserror(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """An ``OSError`` from the tracked-file lister yields QT009 and exit 1."""

    # Arrange
    def failing_lister(repo_root: Path) -> list[str]:
        raise OSError(f"cannot list {repo_root}")

    # Act
    exit_code = main(
        [],
        read_manifest_text=_reader(SMALL_MANIFEST_TEXT),
        list_tracked_files=failing_lister,
    )

    # Assert
    lines = _assert_failure_output(capsys.readouterr())
    assert exit_code == 1
    assert [line[:5] for line in lines] == ["QT009"]


def test_main_returns_one_with_qt009_when_git_exits_nonzero(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A non-zero git exit code fails closed with QT009."""

    # Arrange
    def fake_run(argv: Sequence[str], **kwargs: object) -> FakeRunResult:
        del argv, kwargs
        return FakeRunResult(returncode=128, stdout=b"")

    lister = functools.partial(
        list_tracked_files, which=lambda name: "git", run=fake_run
    )

    # Act
    exit_code = main(
        [], read_manifest_text=_reader(SMALL_MANIFEST_TEXT), list_tracked_files=lister
    )

    # Assert
    lines = _assert_failure_output(capsys.readouterr())
    assert exit_code == 1
    assert [line[:5] for line in lines] == ["QT009"]


def test_main_returns_one_with_qt009_when_git_not_found(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A git executable missing from PATH fails closed with QT009."""

    # Arrange
    def forbidden_run(argv: Sequence[str], **kwargs: object) -> FakeRunResult:
        del kwargs
        pytest.fail(f"runner must not be called when git is absent: {argv}")

    lister = functools.partial(
        list_tracked_files, which=lambda name: None, run=forbidden_run
    )

    # Act
    exit_code = main(
        [], read_manifest_text=_reader(SMALL_MANIFEST_TEXT), list_tracked_files=lister
    )

    # Assert
    lines = _assert_failure_output(capsys.readouterr())
    assert exit_code == 1
    assert [line[:5] for line in lines] == ["QT009"]


def test_main_reports_entry_errors_alongside_qt009(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Entry-level errors are still reported when git listing fails."""

    # Arrange
    def failing_lister(repo_root: Path) -> list[str]:
        raise OSError(f"cannot list {repo_root}")

    text = 'version: 1\nprojects:\n  - path: "."\n    tier: "T5"\n    rationale: "r"\n'

    # Act
    exit_code = main(
        [], read_manifest_text=_reader(text), list_tracked_files=failing_lister
    )

    # Assert
    lines = _assert_failure_output(capsys.readouterr())
    assert exit_code == 1
    assert sorted(line[:5] for line in lines) == ["QT004", "QT009"]


def test_main_returns_one_with_qt008_when_entry_removed(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Removing the scripts/bash entry while the folder is tracked yields QT008."""
    # Act
    exit_code = main(
        [],
        read_manifest_text=_reader(COMMITTED_STYLE_TEXT_WITHOUT_SCRIPTS_BASH),
        list_tracked_files=_tracked(COMMITTED_STYLE_TRACKED_FILES),
    )

    # Assert
    lines = _assert_failure_output(capsys.readouterr())
    assert exit_code == 1
    qt008_lines = [line for line in lines if line.startswith("QT008:")]
    assert len(qt008_lines) == 1, f"expected one QT008 line: {lines}"
    assert "scripts/bash" in qt008_lines[0]


def test_main_reports_qt004_and_qt008_in_one_run(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """An invalid tier and an unclassified project are reported together."""
    # Arrange
    text = 'version: 1\nprojects:\n  - path: "."\n    tier: "T9"\n    rationale: "r"\n'

    # Act
    exit_code = main(
        [],
        read_manifest_text=_reader(text),
        list_tracked_files=_tracked(SMALL_TRACKED_FILES),
    )

    # Assert
    lines = _assert_failure_output(capsys.readouterr())
    assert exit_code == 1
    assert sorted(line[:5] for line in lines) == ["QT004", "QT008"]


def test_main_raises_system_exit_two_for_unknown_argument() -> None:
    """An unknown command-line option is an argparse usage error (exit 2)."""
    # Act
    with pytest.raises(SystemExit) as raised:
        main(
            ["--no-such-option"],
            read_manifest_text=_reader(SMALL_MANIFEST_TEXT),
            list_tracked_files=_tracked(SMALL_TRACKED_FILES),
        )

    # Assert
    assert raised.value.code == 2


def test_main_resolves_relative_file_against_repo_root() -> None:
    """A relative ``--file`` is resolved against ``--repo-root``."""
    # Arrange
    read_paths: list[Path] = []
    listed_roots: list[Path] = []

    def recording_reader(path: Path) -> str:
        read_paths.append(path)
        return SMALL_MANIFEST_TEXT

    def recording_lister(repo_root: Path) -> list[str]:
        listed_roots.append(repo_root)
        return list(SMALL_TRACKED_FILES)

    # Act
    exit_code = main(
        ["--repo-root", "checkout", "--file", "custom-tiers.yml"],
        read_manifest_text=recording_reader,
        list_tracked_files=recording_lister,
    )

    # Assert
    assert exit_code == 0
    assert read_paths == [Path("checkout") / "custom-tiers.yml"]
    assert listed_roots == [Path("checkout")]


def test_list_tracked_files_invokes_git_ls_files_z() -> None:
    """The lister runs ``git ls-files -z`` in the repository root."""
    # Arrange
    recorded: list[list[str]] = []
    recorded_kwargs: list[dict[str, object]] = []

    def fake_run(argv: Sequence[str], **kwargs: object) -> FakeRunResult:
        recorded.append(list(argv))
        recorded_kwargs.append(dict(kwargs))
        return FakeRunResult(returncode=0, stdout=b"")

    # Act
    list_tracked_files(Path("checkout"), which=lambda name: "git", run=fake_run)

    # Assert
    assert recorded == [["git", "ls-files", "-z"]]
    assert recorded_kwargs[0]["cwd"] == Path("checkout")


def test_list_tracked_files_splits_nul_separated_output() -> None:
    """NUL-separated git output becomes a list of paths with no empty items."""

    # Arrange
    def fake_run(argv: Sequence[str], **kwargs: object) -> FakeRunResult:
        del argv, kwargs
        return FakeRunResult(returncode=0, stdout=b"package.json\0scripts/bash/a.sh\0")

    # Act
    paths = list_tracked_files(Path("."), which=lambda name: "git", run=fake_run)

    # Assert
    assert paths == ["package.json", "scripts/bash/a.sh"]


def test_default_manifest_reader_reads_file_text(mem_fs_path: Path) -> None:
    """The default reader returns the UTF-8 text of the manifest file."""
    # Arrange
    manifest_path = mem_fs_path / "quality-tiers.yml"
    manifest_path.write_text(SMALL_MANIFEST_TEXT, encoding="utf-8")

    # Act
    text = read_manifest_text(manifest_path)

    # Assert
    assert text == SMALL_MANIFEST_TEXT
