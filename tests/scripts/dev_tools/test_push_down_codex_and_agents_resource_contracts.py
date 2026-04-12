"""Contract tests for bundled `.codex` / `.agents` customization resources."""

from __future__ import annotations

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)
SCOPED_ROOTS: tuple[Path, ...] = (Path(".codex"), Path(".agents"))
REQUIRED_BUNDLED_FILES = (
    Path(".agents/README.md"),
    Path(".agents/skills/README.md"),
    Path(".agents/skills/atomic-executor/SKILL.md"),
    Path(".agents/skills/atomic-planner/SKILL.md"),
    Path(".agents/skills/orchestrator-workflow/SKILL.md"),
    Path(".agents/skills/repo-automation-adapter/agents/openai.yaml"),
    Path(".codex/config.toml"),
    Path(".codex/agents/atomic-executor.toml"),
    Path(".codex/agents/atomic-planner.toml"),
    Path(".codex/agents/orchestrator.toml"),
    Path(".codex/prompts/generate-pr.md"),
    Path(".codex/prompts/orchestrate-work.md"),
)


def list_scoped_files(root: Path) -> list[Path]:
    """Return scoped files in deterministic relative-path order."""

    files: list[Path] = []
    for scoped_root in SCOPED_ROOTS:
        scoped_path = root / scoped_root
        for path in scoped_path.rglob("*"):
            if path.is_file():
                files.append(path.relative_to(root))
    return sorted(files)


def read_text(root: Path, relative_path: Path) -> str:
    """Return UTF-8 text for a bundled or source payload file."""

    return (root / relative_path).read_text(encoding="utf-8")


def normalize_agent_target(file_name: str) -> str:
    """Map a GitHub agent filename to its default bundled Codex wrapper target."""

    stem = file_name.removesuffix(".agent.md")
    return re.sub(r"-{2,}", "-", re.sub(r"[ _]+", "-", stem.lower()))


def test_bundled_codex_and_agents_payload_contains_required_runtime_files() -> None:
    """Require the bundled payload to include the expected runtime support files."""

    bundled_files = list_scoped_files(BUNDLED_ROOT)

    assert bundled_files
    for relative_path in REQUIRED_BUNDLED_FILES:
        assert relative_path in bundled_files


def test_bundled_codex_and_agents_payload_contains_all_migrated_github_contracts() -> (
    None
):
    """Require the bundled payload to include all shared-skill and wrapper targets."""

    bundled_files = list_scoped_files(BUNDLED_ROOT)
    github_skill_files = [
        Path(".agents") / "skills" / path.name / "SKILL.md"
        for path in (REPO_ROOT / ".github" / "skills").iterdir()
        if path.is_dir()
    ]
    github_agent_files = [
        Path(".codex") / "agents" / f"{normalize_agent_target(path.name)}.toml"
        for path in (REPO_ROOT / ".github" / "agents").iterdir()
        if path.is_file() and path.name.endswith(".agent.md")
    ]

    for relative_path in [*github_skill_files, *github_agent_files]:
        assert relative_path in bundled_files

    for relative_path in github_skill_files:
        github_relative = (
            Path(".github") / "skills" / relative_path.parent.name / "SKILL.md"
        )
        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
            REPO_ROOT,
            github_relative,
        )
