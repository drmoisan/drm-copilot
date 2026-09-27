"""Guard the codex-model-routing skill against Python-only instructions (issue #697).

Destinations that receive the Codex bundle may have no Python toolchain, so the
skill must instruct the PowerShell routing wrappers and direct validation to the
MCP tool rather than to `poetry run python`. Both the repository skill and its
bundle copy are checked.
"""

from __future__ import annotations

from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[3]
SKILL_PATHS: tuple[Path, ...] = (
    REPO_ROOT / ".agents" / "skills" / "codex-model-routing" / "SKILL.md",
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
    / ".agents"
    / "skills"
    / "codex-model-routing"
    / "SKILL.md",
)
SKILL_IDS: tuple[str, ...] = ("repository", "bundle")


def _read_skill(path: Path) -> str:
    """Return the skill text.

    Args:
        path: Path of one SKILL.md copy.

    Returns:
        str: The file content decoded as UTF-8.
    """
    return path.read_text(encoding="utf-8")


@pytest.mark.parametrize("skill_path", SKILL_PATHS, ids=SKILL_IDS)
def test_skill_contains_no_python_resolver_invocation(skill_path: Path) -> None:
    """The skill never instructs a Python resolver or validator invocation."""
    # Arrange / Act
    text = _read_skill(skill_path)

    # Assert
    assert "poetry run python -m scripts.dev_tools.resolve_codex_" not in text
    assert "poetry run python" not in text


@pytest.mark.parametrize("skill_path", SKILL_PATHS, ids=SKILL_IDS)
def test_skill_instructs_powershell_wrappers(skill_path: Path) -> None:
    """The skill instructs both PowerShell routing wrappers."""
    # Arrange / Act
    text = _read_skill(skill_path)

    # Assert
    assert ".codex/scripts/Resolve-CodexTopology.ps1" in text
    assert ".codex/scripts/Resolve-CodexDeployment.ps1" in text


@pytest.mark.parametrize("skill_path", SKILL_PATHS, ids=SKILL_IDS)
def test_skill_directs_validation_to_mcp_tool(skill_path: Path) -> None:
    """The skill directs checkpoint validation to the MCP tool with both gates."""
    # Arrange / Act
    text = _read_skill(skill_path)

    # Assert
    assert "validate_orchestration_artifacts" in text
    assert "require_codex_topology" in text
    assert "require_codex_model_routing" in text
