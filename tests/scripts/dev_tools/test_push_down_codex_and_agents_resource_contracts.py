"""Contract tests for bundled `.codex` / `.agents` customization resources."""

from __future__ import annotations

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


def test_bundled_codex_and_agents_payload_contains_required_runtime_files() -> None:
    """Require the bundled payload to include the expected runtime support files."""

    bundled_files = list_scoped_files(BUNDLED_ROOT)

    assert bundled_files
    for relative_path in REQUIRED_BUNDLED_FILES:
        assert relative_path in bundled_files


def test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts() -> None:
    """Require the bundled payload to include all repo `.agents` and `.codex` files."""

    bundled_files = list_scoped_files(BUNDLED_ROOT)
    repo_runtime_files = list_scoped_files(REPO_ROOT)

    for relative_path in repo_runtime_files:
        assert relative_path in bundled_files
        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
            REPO_ROOT,
            relative_path,
        )
