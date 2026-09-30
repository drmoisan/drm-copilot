"""CLI and gh-adapter tests for potential-to-issue promotion."""

from __future__ import annotations

import sys
from pathlib import Path
from types import SimpleNamespace

import pytest

from scripts.dev_tools import potential_to_issue as mod
from scripts.dev_tools import potential_to_issue_adapters as adapters
from tests.scripts.dev_tools.potential_to_issue_test_support import FakeFileSystem


def test_real_gh_client_invokes_subprocess(monkeypatch: pytest.MonkeyPatch) -> None:
    """Verify RealGhClient uses subprocess calls for auth/create/view operations."""
    calls: list[list[str]] = []

    def fake_which(name: str) -> str:
        """Return deterministic fake gh executable path for monkeypatched lookup."""
        return "/usr/bin/gh"

    class DummyCompleted:
        """Simple completed-process stand-in for subprocess monkeypatching."""

        def __init__(self, code: int, stdout: str = "", stderr: str = "") -> None:
            """Capture return code and output fields used by client logic."""
            self.returncode = code
            self.stdout = stdout
            self.stderr = stderr

    def fake_run(args: list[str], **kwargs: object) -> DummyCompleted:
        """Capture subprocess args and return deterministic completion values."""
        calls.append(list(args))
        if "auth" in args:
            return DummyCompleted(0, "ok", "")
        return DummyCompleted(0, "output", "")

    monkeypatch.setattr(adapters.shutil, "which", fake_which)
    monkeypatch.setattr(adapters.subprocess, "run", fake_run)

    client = mod.RealGhClient()
    assert client.is_authenticated() is True
    create = client.issue_create("Title", "Body", "feature")
    ensure_label = client.ensure_label("feature")
    view = client.issue_view("5")
    assert create.exit_code == 0 and ensure_label.exit_code == 0 and view.exit_code == 0
    assert any("issue" in call for call in calls)
    assert any(call[:3] == ["/usr/bin/gh", "label", "create"] for call in calls)


def test_real_gh_client_raises_when_missing(monkeypatch: pytest.MonkeyPatch) -> None:
    """Verify RealGhClient fails fast when gh executable cannot be resolved."""

    def missing(_: str) -> None:
        """Return None to simulate an unresolved gh executable path."""
        return None

    monkeypatch.setattr(adapters.shutil, "which", missing)
    with pytest.raises(FileNotFoundError):
        mod.RealGhClient()


def test_real_filesystem_round_trip() -> None:
    """Verify fake filesystem round-trip semantics without temp filesystem usage."""
    fs = FakeFileSystem()
    target = Path("/virtual/nested/file.txt")
    fs.ensure_dir(target.parent)
    fs.write_text(target, "content")
    assert fs.read_text(target) == "content"
    dest = target.parent / "moved.txt"
    fs.move(target, dest)
    assert fs.read_text(dest) == "content"


def test_parse_args_and_main_paths(monkeypatch: pytest.MonkeyPatch) -> None:
    """Verify argument parsing and main success-path exit behavior."""
    potential = Path("/virtual/p.md")
    args = [
        "prog",
        "--potential-path",
        str(potential),
        "--promotion-type",
        "epic",
        "--work-mode",
        "minor-audit",
    ]
    monkeypatch.setattr(sys, "argv", args)
    parsed = mod.parse_args()
    assert parsed.potential_path == str(potential)
    assert parsed.promotion_type == "epic"
    assert parsed.work_mode == "minor-audit"

    fake_args = SimpleNamespace(
        potential_path=str(potential), promotion_type="feature", work_mode="full"
    )

    def fake_parse_args() -> SimpleNamespace:
        """Provide deterministic parsed arguments for main-path testing."""
        return fake_args

    def fake_promote(
        potential_path: str, promotion_type: str, work_mode: str
    ) -> mod.PromotionOutcome:
        """Return a successful promotion outcome for main-path testing."""
        assert work_mode in {"full", "minor-audit", "full-feature", "full-bug"}
        return mod.PromotionOutcome(0, [], None)

    monkeypatch.setattr(mod, "parse_args", fake_parse_args)
    monkeypatch.setattr(mod, "promote_potential", fake_promote)
    with pytest.raises(SystemExit) as exc:
        mod.main()
    assert exc.value.code == 0


def test_main_exits_on_promotion_error(monkeypatch: pytest.MonkeyPatch) -> None:
    """Verify main exits with non-zero status on promotion failures."""
    fake_args = SimpleNamespace(
        potential_path=str(Path("/virtual/p.md")),
        promotion_type="feature",
        work_mode="full",
    )

    def fake_parse_args() -> SimpleNamespace:
        """Provide deterministic parsed args for failure-path testing."""
        return fake_args

    monkeypatch.setattr(mod, "parse_args", fake_parse_args)

    def raise_error(**kwargs: object) -> object:
        """Raise PromotionError to exercise main error handling."""
        raise mod.PromotionError("boom")

    monkeypatch.setattr(mod, "promote_potential", raise_error)
    with pytest.raises(SystemExit) as exc:
        mod.main()
    assert exc.value.code == 1
