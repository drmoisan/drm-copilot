from __future__ import annotations

import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
SETTINGS_PATH = REPO_ROOT / ".vscode" / "settings.json"
WORKSPACE_POWERSHELL_LABEL = "PowerShell 7 (Workspace)"
WORKSPACE_POWERSHELL_PATH = "C:/Program Files/PowerShell/7/pwsh.exe"


def test_workspace_settings_pin_vscode_to_powershell_7() -> None:
    """Tracked workspace settings should pin VS Code to PowerShell 7."""
    settings = json.loads(SETTINGS_PATH.read_text(encoding="utf-8"))

    assert settings["powershell.powerShellAdditionalExePaths"] == {
        WORKSPACE_POWERSHELL_LABEL: WORKSPACE_POWERSHELL_PATH
    }
    assert settings["powershell.powerShellDefaultVersion"] == WORKSPACE_POWERSHELL_LABEL


def test_workspace_settings_contain_no_host_specific_paths() -> None:
    """Tracked workspace settings must not embed user-specific absolute paths."""
    text = SETTINGS_PATH.read_text(encoding="utf-8")

    for marker in ("DanMoisan", "OneDrive", "file:///", "vscode-remote://"):
        assert (
            marker not in text
        ), f"host-specific marker {marker!r} found in settings.json"
