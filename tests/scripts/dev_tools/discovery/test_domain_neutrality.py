"""Domain-neutrality regression tests for discovery templates and rendered output."""

from __future__ import annotations

import re
from pathlib import Path

from scripts.dev_tools.discovery.init_flow import create_discovery_workspace
from scripts.dev_tools.discovery.init_models import (
    EXPECTED_TEMPLATE_RELATIVE_PATHS,
    OUTPUT_RELATIVE_PATHS,
)

DISALLOWED_TOKEN_PATTERN = re.compile(r"TaskMaster|TMW|Outlook|VSTO", re.IGNORECASE)

_REPO_ROOT = Path(__file__).resolve().parents[4]
_TEMPLATE_ROOT = _REPO_ROOT / "docs" / "discovery" / "templates"


class _FakeFileSystem:
    """In-memory `FileSystem` test double with no real disk I/O."""

    def __init__(self) -> None:
        self.files: dict[Path, str] = {}
        self.dirs: set[Path] = set()

    def exists(self, path: Path) -> bool:
        return path in self.files or path in self.dirs

    def is_dir(self, path: Path) -> bool:
        return path in self.dirs

    def list_dir(self, path: Path) -> list[Path]:
        return [
            candidate
            for candidate in {*self.files, *self.dirs}
            if candidate != path and candidate.parent == path
        ]

    def ensure_dir(self, path: Path) -> None:
        self.dirs.add(path)

    def read_text(self, path: Path) -> str:
        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        self.files[path] = content


def test_domain_neutrality_templates_contain_no_disallowed_tokens() -> None:
    """Every discovery template file contains none of the disallowed tokens."""
    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
        text = (_TEMPLATE_ROOT / relative_path).read_text(encoding="utf-8")
        assert not DISALLOWED_TOKEN_PATTERN.search(
            text
        ), f"Disallowed token found in template {relative_path}"


def test_domain_neutrality_rendered_output_contains_no_disallowed_tokens() -> None:
    """Every file `create_discovery_workspace` writes contains no disallowed tokens."""
    fs = _FakeFileSystem()
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)
    fs.dirs.add(_TEMPLATE_ROOT)
    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
        fs.files[_TEMPLATE_ROOT / relative_path] = (
            _TEMPLATE_ROOT / relative_path
        ).read_text(encoding="utf-8")

    create_discovery_workspace(target_dir, _TEMPLATE_ROOT, fs)

    for output_relative in OUTPUT_RELATIVE_PATHS:
        rendered = fs.files[target_dir / output_relative]
        assert not DISALLOWED_TOKEN_PATTERN.search(
            rendered
        ), f"Disallowed token found in rendered output {output_relative}"
