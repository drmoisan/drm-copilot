"""Unit tests for copy_research_to_issue dev tool.

These tests avoid filesystem writes by using an in-memory filesystem adapter,
matching repo policy (no temp files / no runtime file creation).
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from types import SimpleNamespace
from typing import TYPE_CHECKING, Protocol, cast
from unittest.mock import MagicMock

import pytest

from scripts.dev_tools import copy_research_to_issue as mod
from scripts.dev_tools import tk_dialog_helpers as tk

if TYPE_CHECKING:
    from collections.abc import Callable


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


class PromptYesNo(Protocol):
    """Callable type for the internal yes/no prompt helper."""

    def __call__(self, prompt: str) -> bool: ...


class PromptPathFallback(Protocol):
    """Callable type for the internal path prompt fallback helper."""

    def __call__(self, *, label: str, fs: mod.FileSystem) -> Path: ...


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


def test_resolve_issue_parent_dir_rejects_whitespace_only() -> None:
    """resolve_issue_parent_dir should reject empty/whitespace selections."""

    with pytest.raises(ValueError, match="issue_path is empty"):
        mod.resolve_issue_parent_dir(Path(" "))


def test_resolve_issue_parent_dir_dir_returns_dir(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """resolve_issue_parent_dir should return the dir when a dir is selected."""

    issue_dir = Path("/repo/docs/features/active/issue-1")

    def is_dir(self: Path) -> bool:
        return self == issue_dir

    monkeypatch.setattr(Path, "is_dir", is_dir, raising=False)
    assert mod.resolve_issue_parent_dir(issue_dir) == issue_dir


def test_prompt_yes_no_reprompts_until_valid(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """_prompt_yes_no should loop until it can interpret a yes/no answer."""

    answers = iter(["maybe", "Y"])

    def fake_input(_: str) -> str:
        return next(answers)

    monkeypatch.setattr("builtins.input", fake_input)

    helper_name = "_prompt_yes_no"
    prompt_yes_no = cast(PromptYesNo, getattr(mod, helper_name))
    assert prompt_yes_no("Overwrite?") is True

    captured = capsys.readouterr()
    assert "Please answer" in captured.out


def test_prompt_yes_no_default_no_on_empty(monkeypatch: pytest.MonkeyPatch) -> None:
    """_prompt_yes_no should treat empty input as no."""

    def fake_input(_: str) -> str:
        return ""

    monkeypatch.setattr("builtins.input", fake_input)

    helper_name = "_prompt_yes_no"
    prompt_yes_no = cast(PromptYesNo, getattr(mod, helper_name))
    assert prompt_yes_no("Overwrite?") is False


def test_prompt_path_fallback_rejects_empty(monkeypatch: pytest.MonkeyPatch) -> None:
    """_prompt_path_fallback should reject empty input deterministically."""

    fs = FakeFileSystem(existing=set(), copies=[])

    def fake_input(_: str) -> str:
        return ""

    monkeypatch.setattr("builtins.input", fake_input)

    helper_name = "_prompt_path_fallback"
    prompt_path_fallback = cast(PromptPathFallback, getattr(mod, helper_name))
    with pytest.raises(ValueError, match="No path provided"):
        prompt_path_fallback(label="research document", fs=fs)


def test_prompt_path_fallback_returns_expanded_path(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """_prompt_path_fallback should return a Path for valid input."""

    fs = FakeFileSystem(existing=set(), copies=[])

    def fake_input(_: str) -> str:
        return "relative.txt"

    monkeypatch.setattr("builtins.input", fake_input)

    helper_name = "_prompt_path_fallback"
    prompt_path_fallback = cast(PromptPathFallback, getattr(mod, helper_name))
    assert prompt_path_fallback(label="research document", fs=fs) == Path(
        "relative.txt"
    )


def test_select_file_returns_gui_pick(monkeypatch: pytest.MonkeyPatch) -> None:
    """select_file should prefer GUI selection when available."""

    def fake_resolve_workspace_root() -> Path:
        return Path("/repo")

    def fake_resolve_initial_dir(
        *,
        workspace_root: Path,
        relative_start_dir: Path,
        exists: Callable[[Path], bool],
    ) -> Path | None:
        return Path("/repo/start")

    def fake_pick_file_with_tkinter(
        *, title: str, initial_dir: Path | None
    ) -> Path | None:
        return Path("/picked.txt")

    monkeypatch.setattr(mod, "resolve_workspace_root", fake_resolve_workspace_root)
    monkeypatch.setattr(mod, "resolve_initial_dir", fake_resolve_initial_dir)
    monkeypatch.setattr(mod, "pick_file_with_tkinter", fake_pick_file_with_tkinter)

    selected = mod.select_file(
        title="Pick",
        label="research",
        fs=FakeFileSystem(existing=set(), copies=[]),
        initial_relative_dir=Path("artifacts") / "research",
    )
    assert selected == Path("/picked.txt")


def test_select_file_falls_back_to_prompt(monkeypatch: pytest.MonkeyPatch) -> None:
    """select_file should fall back to stdin prompting if GUI isn't available."""

    def fake_resolve_workspace_root() -> Path:
        return Path("/repo")

    def fake_resolve_initial_dir(
        *,
        workspace_root: Path,
        relative_start_dir: Path,
        exists: Callable[[Path], bool],
    ) -> Path | None:
        return None

    def fake_pick_file_with_tkinter(
        *, title: str, initial_dir: Path | None
    ) -> Path | None:
        return None

    def fake_prompt_path_fallback(*, label: str, fs: mod.FileSystem) -> Path:
        return Path("/typed.txt")

    monkeypatch.setattr(mod, "resolve_workspace_root", fake_resolve_workspace_root)
    monkeypatch.setattr(mod, "resolve_initial_dir", fake_resolve_initial_dir)
    monkeypatch.setattr(mod, "pick_file_with_tkinter", fake_pick_file_with_tkinter)
    monkeypatch.setattr(mod, "_prompt_path_fallback", fake_prompt_path_fallback)

    selected = mod.select_file(
        title="Pick",
        label="research",
        fs=FakeFileSystem(existing=set(), copies=[]),
        initial_relative_dir=Path("artifacts") / "research",
    )
    assert selected == Path("/typed.txt")


def test_main_existing_dest_user_declines_overwrite(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """main should cancel when destination exists and user declines overwrite."""

    research_path = Path("/repo/artifacts/research/doc.md")
    issue_file = Path("/repo/docs/features/active/issue-1/plan.md")
    dest_path = Path("/repo/docs/features/active/issue-1/research.md")

    fs = FakeFileSystem(existing={research_path, dest_path}, copies=[])

    def fake_select_file(
        *,
        title: str,
        label: str,
        fs: mod.FileSystem,
        initial_relative_dir: Path | None,
    ) -> Path:
        return research_path if "research" in label else issue_file

    def fake_real_filesystem() -> FakeFileSystem:
        return fs

    def fake_prompt_yes_no(prompt: str) -> bool:
        return False

    monkeypatch.setattr(mod, "select_file", fake_select_file)
    monkeypatch.setattr(mod, "RealFileSystem", fake_real_filesystem)
    monkeypatch.setattr(mod, "_prompt_yes_no", fake_prompt_yes_no)

    mod.main([])

    assert fs.copies == []
    captured = capsys.readouterr()
    assert "Cancelled" in captured.out


def test_main_overwrite_flag_copies(monkeypatch: pytest.MonkeyPatch) -> None:
    """main should copy without prompting when --overwrite is provided."""

    research_path = Path("/repo/artifacts/research/doc.md")
    issue_file = Path("/repo/docs/features/active/issue-1/plan.md")
    dest_path = Path("/repo/docs/features/active/issue-1/research.md")

    fs = FakeFileSystem(existing={research_path, dest_path}, copies=[])

    def fake_select_file(
        *,
        title: str,
        label: str,
        fs: mod.FileSystem,
        initial_relative_dir: Path | None,
    ) -> Path:
        return research_path if "research" in label else issue_file

    def fake_real_filesystem() -> FakeFileSystem:
        return fs

    monkeypatch.setattr(mod, "select_file", fake_select_file)
    monkeypatch.setattr(mod, "RealFileSystem", fake_real_filesystem)

    mod.main(["--overwrite"])

    assert fs.copies == [(research_path, dest_path)]


def test_resolve_workspace_root_uses_script_anchor() -> None:
    """resolve_workspace_root should resolve to two parents above the anchor."""

    root = tk.resolve_workspace_root(Path("/repo/scripts/dev_tools/tool.py"))
    assert root == Path("/repo")


def test_resolve_initial_dir_returns_none_when_missing() -> None:
    """resolve_initial_dir should return None when the candidate doesn't exist."""

    def exists(_: Path) -> bool:
        return False

    result = tk.resolve_initial_dir(
        workspace_root=Path("/repo"),
        relative_start_dir=Path("missing"),
        exists=exists,
    )
    assert result is None


def test_resolve_initial_dir_returns_candidate_when_exists() -> None:
    """resolve_initial_dir should return the absolute candidate when it exists."""

    def exists(_: Path) -> bool:
        return True

    result = tk.resolve_initial_dir(
        workspace_root=Path("/repo"),
        relative_start_dir=Path("artifacts") / "research",
        exists=exists,
    )
    assert result == Path("/repo") / "artifacts" / "research"


def test_pick_file_with_tkinter_returns_none_when_tk_missing(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """pick_file_with_tkinter should return None if Tkinter can't be imported."""

    import importlib

    def fake_import(name: str) -> object:
        raise ImportError(name)

    monkeypatch.setattr(importlib, "import_module", fake_import)
    assert tk.pick_file_with_tkinter(title="Pick", initial_dir=None) is None


def test_pick_file_with_tkinter_returns_selected_path_and_destroys_root(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """pick_file_with_tkinter should return a Path and always destroy the root."""

    import importlib

    root = MagicMock()
    root.winfo_fpixels.return_value = 96.0
    root.winfo_screenwidth.return_value = 1920
    root.winfo_screenmmwidth.return_value = 344
    root.tk = MagicMock()

    tk_mod = MagicMock()
    tk_mod.Tk.return_value = root

    filedialog_mod = MagicMock()
    filedialog_mod.askopenfilename.return_value = "/picked.txt"

    def fake_import(name: str) -> object:
        if name == "tkinter":
            return tk_mod
        if name == "tkinter.filedialog":
            return filedialog_mod
        raise ImportError(name)

    monkeypatch.setattr(importlib, "import_module", fake_import)
    picked = tk.pick_file_with_tkinter(title="Pick", initial_dir=Path("/start"))
    assert picked == Path("/picked.txt")
    root.tk.call.assert_called()
    root.destroy.assert_called_once()


def test_pick_file_with_tkinter_returns_none_on_cancel(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """pick_file_with_tkinter should return None when the dialog returns empty."""

    import importlib

    root = MagicMock()
    root.winfo_fpixels.return_value = 96.0
    root.winfo_screenwidth.return_value = 1920
    root.winfo_screenmmwidth.return_value = 344
    root.tk = MagicMock()

    tk_mod = MagicMock()
    tk_mod.Tk.return_value = root

    filedialog_mod = MagicMock()
    filedialog_mod.askopenfilename.return_value = ""

    def fake_import(name: str) -> object:
        if name == "tkinter":
            return tk_mod
        if name == "tkinter.filedialog":
            return filedialog_mod
        raise ImportError(name)

    monkeypatch.setattr(importlib, "import_module", fake_import)
    picked = tk.pick_file_with_tkinter(title="Pick", initial_dir=None)
    assert picked is None
    root.destroy.assert_called_once()


def test_pick_file_with_tkinter_windows_dpi_awareness_shcore_success(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """pick_file_with_tkinter should attempt SetProcessDpiAwareness on Windows."""

    import importlib

    monkeypatch.setattr(tk.sys, "platform", "win32")

    shcore = SimpleNamespace(SetProcessDpiAwareness=MagicMock())
    user32 = SimpleNamespace(SetProcessDPIAware=MagicMock())
    fake_ctypes = SimpleNamespace(windll=SimpleNamespace(shcore=shcore, user32=user32))
    monkeypatch.setitem(tk.sys.modules, "ctypes", fake_ctypes)

    root = MagicMock()
    root.winfo_fpixels.return_value = 96.0
    root.winfo_screenwidth.return_value = 1920
    root.winfo_screenmmwidth.return_value = 344
    root.tk = MagicMock()

    tk_mod = MagicMock()
    tk_mod.Tk.return_value = root

    filedialog_mod = MagicMock()
    filedialog_mod.askopenfilename.return_value = "C:/picked.txt"

    def fake_import(name: str) -> object:
        if name == "tkinter":
            return tk_mod
        if name == "tkinter.filedialog":
            return filedialog_mod
        raise ImportError(name)

    monkeypatch.setattr(importlib, "import_module", fake_import)
    picked = tk.pick_file_with_tkinter(title="Pick", initial_dir=None)

    assert picked == Path("C:/picked.txt")
    shcore.SetProcessDpiAwareness.assert_called_once_with(2)
    user32.SetProcessDPIAware.assert_not_called()


def test_pick_file_with_tkinter_windows_dpi_awareness_falls_back_to_user32(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """If shcore DPI awareness fails, it should fall back to user32."""

    import importlib

    monkeypatch.setattr(tk.sys, "platform", "win32")

    shcore = SimpleNamespace(SetProcessDpiAwareness=MagicMock(side_effect=OSError()))
    user32 = SimpleNamespace(SetProcessDPIAware=MagicMock())
    fake_ctypes = SimpleNamespace(windll=SimpleNamespace(shcore=shcore, user32=user32))
    monkeypatch.setitem(tk.sys.modules, "ctypes", fake_ctypes)

    root = MagicMock()
    root.winfo_fpixels.return_value = 96.0
    root.winfo_screenwidth.return_value = 1920
    root.winfo_screenmmwidth.return_value = 344
    root.tk = MagicMock()

    tk_mod = MagicMock()
    tk_mod.Tk.return_value = root

    filedialog_mod = MagicMock()
    filedialog_mod.askopenfilename.return_value = "C:/picked.txt"

    def fake_import(name: str) -> object:
        if name == "tkinter":
            return tk_mod
        if name == "tkinter.filedialog":
            return filedialog_mod
        raise ImportError(name)

    monkeypatch.setattr(importlib, "import_module", fake_import)
    picked = tk.pick_file_with_tkinter(title="Pick", initial_dir=None)

    assert picked == Path("C:/picked.txt")
    shcore.SetProcessDpiAwareness.assert_called_once_with(2)
    user32.SetProcessDPIAware.assert_called_once_with()


def test_pick_file_with_tkinter_ignores_scaling_errors(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Scaling configuration should be best-effort and never break selection."""

    import importlib

    root = MagicMock()
    root.winfo_fpixels.side_effect = RuntimeError("Tk failure")
    root.winfo_screenwidth.return_value = 1920
    root.winfo_screenmmwidth.return_value = 344
    root.tk = MagicMock()

    tk_mod = MagicMock()
    tk_mod.Tk.return_value = root

    filedialog_mod = MagicMock()
    filedialog_mod.askopenfilename.return_value = "/picked.txt"

    def fake_import(name: str) -> object:
        if name == "tkinter":
            return tk_mod
        if name == "tkinter.filedialog":
            return filedialog_mod
        raise ImportError(name)

    monkeypatch.setattr(importlib, "import_module", fake_import)
    picked = tk.pick_file_with_tkinter(title="Pick", initial_dir=None)

    assert picked == Path("/picked.txt")
    root.tk.call.assert_not_called()
    root.destroy.assert_called_once()


def test_compute_tk_scaling_clamps_to_safe_range() -> None:
    """compute_tk_scaling should clamp to a safe numeric range."""

    assert (
        tk.compute_tk_scaling(
            env={"LEXILE_TK_SCALE": "1000"},
            logical_dpi=96.0,
            screen_px=None,
            screen_mm=None,
        )
        == 10.0
    )
    assert (
        tk.compute_tk_scaling(
            env={"LEXILE_TK_SCALE": "0.0001"},
            logical_dpi=96.0,
            screen_px=None,
            screen_mm=None,
        )
        == 0.5
    )


def test_compute_tk_scaling_ignores_invalid_env_scaling() -> None:
    """Invalid env vars should not crash scaling computation."""

    scaling = tk.compute_tk_scaling(
        env={"GDK_SCALE": "not-a-float"},
        logical_dpi=96.0,
        screen_px=1,
        screen_mm=1,
    )
    assert scaling == 96.0 / 72.0
