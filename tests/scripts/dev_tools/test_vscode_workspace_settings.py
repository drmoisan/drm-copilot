from __future__ import annotations

import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
SETTINGS_PATH = REPO_ROOT / ".vscode" / "settings.json"
SETTINGS_REQUIRED_PATH = REPO_ROOT / ".vscode" / "settings_required.json"
WORKSPACE_POWERSHELL_LABEL = "PowerShell 7 (Workspace)"
WORKSPACE_POWERSHELL_PATH = "C:/Program Files/PowerShell/7/pwsh.exe"


def test_workspace_settings_pin_vscode_to_powershell_7() -> None:
    """Workspace settings should mirror the required PowerShell 7 pin when present."""
    if not SETTINGS_PATH.exists():
        return

    settings = json.loads(SETTINGS_PATH.read_text(encoding="utf-8"))

    assert settings["powershell.powerShellAdditionalExePaths"] == {
        WORKSPACE_POWERSHELL_LABEL: WORKSPACE_POWERSHELL_PATH
    }
    assert settings["powershell.powerShellDefaultVersion"] == WORKSPACE_POWERSHELL_LABEL


def test_required_settings_include_the_same_powershell_7_pin() -> None:
    """Required settings should mirror the PowerShell 7 workspace pin."""
    settings = json.loads(SETTINGS_REQUIRED_PATH.read_text(encoding="utf-8"))

    assert settings["powershell.powerShellAdditionalExePaths"] == {
        WORKSPACE_POWERSHELL_LABEL: WORKSPACE_POWERSHELL_PATH
    }
    assert settings["powershell.powerShellDefaultVersion"] == WORKSPACE_POWERSHELL_LABEL
