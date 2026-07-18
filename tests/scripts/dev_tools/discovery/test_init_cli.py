"""Tests for `scripts.dev_tools.discovery.init_cli`."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import pytest

from scripts.dev_tools.discovery import init_cli as mod


def test_parse_args_requires_target_dir() -> None:
    """Missing the required positional `target_dir` argument exits via argparse."""
    with pytest.raises(SystemExit):
        mod.parse_args([])


def test_parse_args_defaults_template_root_and_force() -> None:
    """With only `target_dir` supplied, `template_root` and `force` use defaults."""
    namespace = mod.parse_args(["x"])
    assert namespace.target_dir == Path("x")
    assert namespace.template_root is None
    assert namespace.force is False


def test_parse_args_parses_template_root_and_force() -> None:
    """`--template-root` and `--force` are parsed into the namespace."""
    namespace = mod.parse_args(["x", "--template-root", "y", "--force"])
    assert namespace.target_dir == Path("x")
    assert namespace.template_root == Path("y")
    assert namespace.force is True


def test_main_success_path_invokes_create_discovery_workspace(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """On success, `main()` resolves the default template root and delegates."""
    calls: list[dict[str, Any]] = []

    def fake_create_discovery_workspace(
        target_dir: Path,
        template_root: Path,
        fs: object,
        *,
        force: bool,
    ) -> None:
        calls.append(
            {
                "target_dir": target_dir,
                "template_root": template_root,
                "fs": fs,
                "force": force,
            }
        )

    monkeypatch.setattr(
        mod.init_flow, "create_discovery_workspace", fake_create_discovery_workspace
    )

    mod.main(["/consumer/discovery"])

    assert len(calls) == 1
    assert calls[0]["target_dir"] == Path("/consumer/discovery")
    assert calls[0]["template_root"] == mod.init_models.resolve_default_template_root()
    assert calls[0]["force"] is False


def test_main_honors_template_root_override(monkeypatch: pytest.MonkeyPatch) -> None:
    """When `--template-root` is supplied, it overrides the default root."""
    calls: list[Path] = []

    def fake_create_discovery_workspace(
        target_dir: Path,
        template_root: Path,
        fs: object,
        *,
        force: bool,
    ) -> None:  # noqa: ARG001
        calls.append(template_root)

    monkeypatch.setattr(
        mod.init_flow, "create_discovery_workspace", fake_create_discovery_workspace
    )

    mod.main(["/consumer/discovery", "--template-root", "/alternate-templates"])

    assert calls == [Path("/alternate-templates")]


@pytest.mark.parametrize(
    "raised_exception",
    [
        FileExistsError("exists"),
        FileNotFoundError("missing"),
        NotADirectoryError("nd"),
        ValueError("bad"),
    ],
)
def test_main_exits_1_on_fail_fast_exception(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    raised_exception: Exception,
) -> None:
    """Each fail-fast exception type causes `main()` to raise `SystemExit(1)`."""

    def fake_create_discovery_workspace(*_args: object, **_kwargs: object) -> None:
        raise raised_exception

    monkeypatch.setattr(
        mod.init_flow, "create_discovery_workspace", fake_create_discovery_workspace
    )

    with pytest.raises(SystemExit) as excinfo:
        mod.main(["/consumer/discovery"])

    assert excinfo.value.code == 1
    captured = capsys.readouterr()
    assert str(raised_exception) in captured.err


def test_console_script_registered_in_pyproject() -> None:
    """The `dev.discovery.init` console script is registered in `pyproject.toml`."""
    workspace_root = Path(__file__).resolve().parents[4]
    pyproject_text = (workspace_root / "pyproject.toml").read_text(encoding="utf-8")
    assert (
        '"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"'
        in pyproject_text
    )
