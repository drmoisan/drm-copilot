"""Regression tests for required VS Code tasks.json inputs."""

from __future__ import annotations

from pathlib import Path


def _read_tasks_json() -> str:
    """Return the raw tasks.json text for input ID assertions.

    Purpose:
        Read the JSONC file as plain text because it contains comments.

    Returns:
        str: File contents of .vscode/tasks.json.
    """

    repo_root = Path(__file__).resolve().parents[3]
    tasks_json = repo_root / ".vscode" / "tasks.json"
    return tasks_json.read_text(encoding="utf-8")


def test_tasks_json_defines_required_work_mode_inputs() -> None:
    """Ensure tasks.json defines work-mode inputs used by dev tasks."""
    content = _read_tasks_json()

    assert '"id": "PotentialWorkMode"' in content
    assert '"id": "ActiveWorkMode"' in content
