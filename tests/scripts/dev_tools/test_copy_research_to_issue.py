"""Unit tests for copy_research_to_issue dev tool.

These tests avoid filesystem writes by using an in-memory filesystem adapter,
matching repo policy (no temp files / no runtime file creation).
"""

from __future__ import annotations

import builtins
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import copy_research_to_issue as mod
from scripts.dev_tools import tk_dialog_helpers as tk

if TYPE_CHECKING:
    import argparse
    from collections.abc import Callable, Iterator

# Private helpers are read through the module namespace so the tests call the
# real functions without a type-checker suppression.
_prompt_yes_no: Callable[[str], bool] = vars(mod)["_prompt_yes_no"]
_prompt_path_fallback: Callable[..., Path] = vars(mod)["_prompt_path_fallback"]
_build_arg_parser: Callable[[], argparse.ArgumentParser] = vars(mod)[
    "_build_arg_parser"
]


@dataclass
class FakeFileSystem(mod.FileSystem):
    """Minimal in-memory filesystem for deterministic unit tests."""

    existing: set[Path]
    copies: list[tuple[Path, Path]]

    def exists(self, path: Path) -> bool:
        return path in self.existing

    def copy_file(self, src: Path, dest: Path) -> None:
        self.copies.append((src, dest))
        self.existing.add(dest)

    def resolve_path(self, path_str: str) -> Path:
        return Path(path_str)


def test_resolve_issue_parent_dir_file_returns_parent() -> None:
    issue_file = Path("/repo/docs/features/active/issue-1/plan.md")
    assert mod.resolve_issue_parent_dir(issue_file) == Path(
        "/repo/docs/features/active/issue-1"
    )


def test_build_destination_path_always_research_md() -> None:
    issue_dir = Path("/repo/docs/features/active/issue-1")
    assert mod.build_destination_path(issue_dir) == issue_dir / "research.md"


def test_copy_research_document_copies_to_issue_parent_dir() -> None:
    fs = FakeFileSystem(existing=set(), copies=[])
    research = Path("/repo/docs/research/foo.md")
    issue_file = Path("/repo/docs/features/active/issue-1/plan.md")
    fs.existing.add(research)

    dest = mod.copy_research_document(
        fs=fs, research_path=research, issue_path=issue_file, overwrite=False
    )

    assert dest == Path("/repo/docs/features/active/issue-1/research.md")
    assert fs.copies == [(research, dest)]


def test_copy_research_document_missing_source_raises() -> None:
    fs = FakeFileSystem(existing=set(), copies=[])
    research = Path("/repo/docs/research/missing.md")
    issue_file = Path("/repo/docs/features/active/issue-1/plan.md")

    with pytest.raises(FileNotFoundError):
        mod.copy_research_document(
            fs=fs, research_path=research, issue_path=issue_file, overwrite=False
        )


def test_copy_research_document_existing_dest_without_overwrite_raises() -> None:
    fs = FakeFileSystem(existing=set(), copies=[])
    research = Path("/repo/docs/research/foo.md")
    issue_file = Path("/repo/docs/features/active/issue-1/plan.md")
    dest = Path("/repo/docs/features/active/issue-1/research.md")
    fs.existing.update({research, dest})

    with pytest.raises(FileExistsError):
        mod.copy_research_document(
            fs=fs, research_path=research, issue_path=issue_file, overwrite=False
        )

    assert fs.copies == []


def test_copy_research_document_existing_dest_with_overwrite_copies() -> None:
    fs = FakeFileSystem(existing=set(), copies=[])
    research = Path("/repo/docs/research/foo.md")
    issue_file = Path("/repo/docs/features/active/issue-1/plan.md")
    dest = Path("/repo/docs/features/active/issue-1/research.md")
    fs.existing.update({research, dest})

    result = mod.copy_research_document(
        fs=fs, research_path=research, issue_path=issue_file, overwrite=True
    )

    assert result == dest
    assert fs.copies == [(research, dest)]


def test_compute_tk_scaling_defaults_to_96dpi_when_unknown() -> None:
    scaling = tk.compute_tk_scaling(
        env={},
        logical_dpi=None,
        screen_px=None,
        screen_mm=None,
    )
    expected = 96.0 / 72.0
    assert abs(scaling - expected) < 1e-9


def test_compute_tk_scaling_uses_physical_dpi_when_much_higher() -> None:
    # 3840 px wide, 344 mm wide (~283 DPI). This should override a bogus 96 DPI.
    scaling = tk.compute_tk_scaling(
        env={},
        logical_dpi=96.0,
        screen_px=3840,
        screen_mm=344,
    )
    assert scaling > (96.0 / 72.0) * 2


def test_compute_tk_scaling_applies_gdk_scale_when_tk_unscaled() -> None:
    scaling = tk.compute_tk_scaling(
        env={"GDK_SCALE": "2"},
        logical_dpi=96.0,
        screen_px=None,
        screen_mm=None,
    )
    expected = (96.0 / 72.0) * 2
    assert abs(scaling - expected) < 1e-9


def test_compute_tk_scaling_respects_explicit_override_multiplier() -> None:
    scaling = tk.compute_tk_scaling(
        env={"LEXILE_TK_SCALE": "1.5"},
        logical_dpi=96.0,
        screen_px=None,
        screen_mm=None,
    )
    expected = (96.0 / 72.0) * 1.5
    assert abs(scaling - expected) < 1e-9


@pytest.mark.parametrize(
    ("root", "expected"),
    [("docs/features", Path("docs/features/active")), (".dev", Path(".dev/active"))],
)
def test_resolve_active_issue_start_dir_uses_resolved_root(
    root: str, expected: Path
) -> None:
    """The issue picker starts in the active area of the resolved root."""
    workspace = Path("/workspace")
    seen: list[Path] = []

    def resolve_root(path: Path) -> str:
        seen.append(path)
        return root

    result = mod.resolve_active_issue_start_dir(workspace, resolve_root=resolve_root)

    assert result == expected
    assert seen == [workspace]


def _scripted_input(answers: list[str]) -> Callable[[str], str]:
    """Return an ``input`` replacement that yields the scripted answers in order.

    Args:
        answers (list[str]): Answers returned by successive calls.

    Returns:
        Callable[[str], str]: Replacement that ignores the prompt text.
    """
    remaining: Iterator[str] = iter(answers)

    def fake_input(prompt: str = "") -> str:
        """Return the next scripted answer and ignore the prompt."""
        del prompt
        return next(remaining)

    return fake_input


def test_resolve_issue_parent_dir_directory_returns_itself(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A selected directory is the destination itself, not its parent."""

    # Arrange: the selected path reports itself as a directory without disk access.
    def fake_is_dir(self: Path) -> bool:
        """Report every path as a directory."""
        del self
        return True

    monkeypatch.setattr(Path, "is_dir", fake_is_dir)
    issue_dir = Path("/repo/docs/features/active/issue-1")

    # Act
    result = mod.resolve_issue_parent_dir(issue_dir)

    # Assert
    assert result == issue_dir


def test_resolve_issue_parent_dir_blank_path_raises() -> None:
    """A whitespace-only selection is rejected before any path inspection."""
    with pytest.raises(ValueError, match="issue_path is empty"):
        mod.resolve_issue_parent_dir(Path(" "))


def test_real_file_system_delegates_exists_copy_and_resolve(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """RealFileSystem forwards to Path.exists, Path.mkdir and shutil.copyfile."""
    # Arrange: record each delegated call instead of touching the disk.
    calls: list[tuple[str, object]] = []

    def fake_exists(self: Path) -> bool:
        """Record the existence check and report the path as present."""
        calls.append(("exists", self))
        return True

    def fake_mkdir(self: Path, parents: bool = False, exist_ok: bool = False) -> None:
        """Record the directory creation request."""
        calls.append(("mkdir", (self, parents, exist_ok)))

    def fake_copyfile(src: Path, dest: Path) -> None:
        """Record the copy request."""
        calls.append(("copyfile", (src, dest)))

    monkeypatch.setattr(Path, "exists", fake_exists)
    monkeypatch.setattr(Path, "mkdir", fake_mkdir)
    monkeypatch.setattr(mod.shutil, "copyfile", fake_copyfile)
    fs = mod.RealFileSystem()
    src = Path("/repo/docs/research/foo.md")
    dest = Path("/repo/docs/features/active/issue-1/research.md")

    # Act
    exists = fs.exists(src)
    fs.copy_file(src, dest)
    resolved = fs.resolve_path("docs/research/foo.md")

    # Assert
    assert exists is True
    assert resolved == Path("docs/research/foo.md")
    assert calls == [
        ("exists", src),
        ("mkdir", (dest.parent, True, True)),
        ("copyfile", (src, dest)),
    ]


def test_prompt_yes_no_reprompts_until_valid_answer(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """An unrecognized answer re-prompts; a later 'Yes' returns True."""
    monkeypatch.setattr(builtins, "input", _scripted_input(["maybe", " Yes "]))

    assert _prompt_yes_no("Overwrite?") is True
    assert "Please answer 'y' or 'n'." in capsys.readouterr().out


def test_prompt_yes_no_blank_answer_is_no(monkeypatch: pytest.MonkeyPatch) -> None:
    """An empty answer takes the default, which is no."""
    monkeypatch.setattr(builtins, "input", _scripted_input([""]))

    assert _prompt_yes_no("Overwrite?") is False


def test_prompt_path_fallback_empty_input_raises(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A blank path entry is rejected with the label in the message."""
    monkeypatch.setattr(builtins, "input", _scripted_input(["   "]))
    fs = FakeFileSystem(existing=set(), copies=[])

    with pytest.raises(ValueError, match="No path provided for research document"):
        _prompt_path_fallback(label="research document", fs=fs)


def test_prompt_path_fallback_returns_entered_path(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The entered path is trimmed and resolved through the filesystem adapter."""
    monkeypatch.setattr(builtins, "input", _scripted_input(["  docs/research/a.md "]))
    fs = FakeFileSystem(existing=set(), copies=[])

    result = _prompt_path_fallback(label="research document", fs=fs)

    assert result == Path("docs/research/a.md")


def test_select_file_returns_picked_path(monkeypatch: pytest.MonkeyPatch) -> None:
    """The GUI pick is returned and opens in the workspace-relative start folder."""
    # Arrange: record the initial-dir resolution and the picker arguments.
    workspace = Path("/workspace")
    picked = Path("/workspace/artifacts/research/r.md")
    seen: dict[str, object] = {}

    def fake_resolve_initial_dir(
        *, workspace_root: Path, relative_start_dir: Path, exists: object
    ) -> Path:
        """Record the start-folder resolution and join it to the workspace."""
        seen["initial"] = (workspace_root, relative_start_dir, exists)
        return workspace / relative_start_dir

    def fake_pick(*, title: str, initial_dir: Path | None) -> Path | None:
        """Record the picker arguments and return the picked file."""
        seen["pick"] = (title, initial_dir)
        return picked

    monkeypatch.setattr(mod, "resolve_workspace_root", lambda: workspace)
    monkeypatch.setattr(mod, "resolve_initial_dir", fake_resolve_initial_dir)
    monkeypatch.setattr(mod, "pick_file_with_tkinter", fake_pick)
    fs = FakeFileSystem(existing=set(), copies=[])

    # Act
    result = mod.select_file(
        title="Pick",
        label="doc",
        fs=fs,
        initial_relative_dir=Path("artifacts/research"),
    )

    # Assert
    assert result == picked
    assert seen["initial"] == (workspace, Path("artifacts/research"), Path.exists)
    assert seen["pick"] == ("Pick", workspace / "artifacts" / "research")


def test_select_file_prompts_when_picker_returns_none(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Without a GUI pick the path is read from stdin, with no initial folder."""
    seen: list[Path | None] = []

    def fake_pick(*, title: str, initial_dir: Path | None) -> Path | None:
        """Record the start folder and simulate a picker that returns nothing."""
        del title
        seen.append(initial_dir)
        return None

    monkeypatch.setattr(mod, "resolve_workspace_root", lambda: Path("/workspace"))
    monkeypatch.setattr(mod, "pick_file_with_tkinter", fake_pick)
    monkeypatch.setattr(builtins, "input", _scripted_input(["docs/x.md"]))
    fs = FakeFileSystem(existing=set(), copies=[])

    result = mod.select_file(
        title="Pick", label="doc", fs=fs, initial_relative_dir=None
    )

    assert result == Path("docs/x.md")
    assert seen == [None]


@pytest.mark.parametrize(("argv", "expected"), [([], False), (["--overwrite"], True)])
def test_build_arg_parser_reads_overwrite_flag(argv: list[str], expected: bool) -> None:
    """The parser exposes --overwrite as a boolean flag that defaults to False."""
    args = _build_arg_parser().parse_args(argv)

    assert args.overwrite is expected


def _arrange_main(
    monkeypatch: pytest.MonkeyPatch, *, destination_exists: bool
) -> tuple[FakeFileSystem, Path, Path]:
    """Wire main() to an in-memory filesystem and fixed selections.

    Args:
        monkeypatch (pytest.MonkeyPatch): Fixture used to replace module seams.
        destination_exists (bool): Whether research.md already exists.

    Returns:
        tuple[FakeFileSystem, Path, Path]: The fake filesystem, the research
        path, and the expected destination path.
    """
    research = Path("/repo/artifacts/research/r.md")
    issue_file = Path("/repo/docs/features/active/issue-1/issue.md")
    dest = Path("/repo/docs/features/active/issue-1/research.md")
    fs = FakeFileSystem(existing={research}, copies=[])
    if destination_exists:
        fs.existing.add(dest)
    selections = iter([research, issue_file])

    def fake_select_file(
        *, title: str, label: str, fs: object, initial_relative_dir: Path | None
    ) -> Path:
        """Return the research file first and the issue file second."""
        del title, label, fs, initial_relative_dir
        return next(selections)

    def fake_is_dir(self: Path) -> bool:
        """Report every path as a file, so the issue parent is its folder."""
        del self
        return False

    def fake_start_dir(workspace_root: Path) -> Path:
        """Return the default active area without reading the routing file."""
        del workspace_root
        return Path("docs/features/active")

    monkeypatch.setattr(mod, "RealFileSystem", lambda: fs)
    monkeypatch.setattr(mod, "select_file", fake_select_file)
    monkeypatch.setattr(mod, "resolve_workspace_root", lambda: Path("/repo"))
    monkeypatch.setattr(mod, "resolve_active_issue_start_dir", fake_start_dir)
    monkeypatch.setattr(Path, "is_dir", fake_is_dir)
    return fs, research, dest


def test_main_copies_when_destination_absent(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """With no existing research.md the copy runs without a prompt."""
    fs, research, dest = _arrange_main(monkeypatch, destination_exists=False)

    mod.main([])

    assert fs.copies == [(research, dest)]
    assert f"Copied research to: {dest}" in capsys.readouterr().out


def test_main_cancels_when_overwrite_declined(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Declining the overwrite prompt leaves the existing research.md untouched."""
    fs, _, _ = _arrange_main(monkeypatch, destination_exists=True)
    monkeypatch.setattr(builtins, "input", _scripted_input(["n"]))

    mod.main([])

    assert fs.copies == []
    assert "Cancelled; existing research.md left unchanged." in capsys.readouterr().out


def test_main_overwrites_after_confirmation(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Confirming the overwrite prompt copies over the existing research.md."""
    fs, research, dest = _arrange_main(monkeypatch, destination_exists=True)
    monkeypatch.setattr(builtins, "input", _scripted_input(["y"]))

    mod.main([])

    assert fs.copies == [(research, dest)]
    assert f"Copied research to: {dest}" in capsys.readouterr().out
