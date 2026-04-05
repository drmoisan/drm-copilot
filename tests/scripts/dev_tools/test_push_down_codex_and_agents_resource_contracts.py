"""Contract tests for bundled `.codex` / `.agents` customization resources."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
SOURCE_ROOT = REPO_ROOT
BUNDLED_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)
SCOPED_ROOTS: tuple[Path, ...] = (Path(".codex"), Path(".agents"))


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


def test_bundled_codex_and_agents_payload_matches_repo_root_sources() -> None:
    """Require the bundled payload tree to match repo-root `.codex` and `.agents`."""

    source_files = list_scoped_files(SOURCE_ROOT)
    bundled_files = list_scoped_files(BUNDLED_ROOT)

    assert bundled_files == source_files

    for relative_path in source_files:
        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
            SOURCE_ROOT,
            relative_path,
        )
