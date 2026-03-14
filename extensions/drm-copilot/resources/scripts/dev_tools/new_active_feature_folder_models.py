"""Core models and basic utilities for active feature folder creation."""

from __future__ import annotations

import re
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING, Protocol
from zoneinfo import ZoneInfo

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable

NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:[-_][a-z0-9]+)*$")
EXCLUDED_POTENTIAL_NAMES = {"template.md", "README.md"}
PLACEHOLDERS = [
    "<feature-name>",
    "<refactor-name>",
    "<epic-name>",
    "<name>",
    "<bug-name>",
]

PLAN_TIMESTAMP_TEMPLATE_NAME = "plan.yyyy-MM-ddTHH-mm.md"


@dataclass
class IssueMeta:
    """Issue metadata container."""

    number: str
    author: str
    updated_date: str


@dataclass
class ActiveFolderResult:
    """Result payload for active-folder creation."""

    target: Path
    potential_issue_path: Path | None


class FileSystem(Protocol):
    """Filesystem contract for folder creation workflows."""

    def exists(self, path: Path) -> bool: ...

    def ensure_dir(self, path: Path) -> None: ...

    def copy_file(self, src: Path, dest: Path) -> None: ...

    def copy_tree(self, src: Path, dest: Path) -> None: ...

    def list_files(self, path: Path) -> Iterable[Path]: ...

    def read_text(self, path: Path) -> str: ...

    def write_text(self, path: Path, content: str) -> None: ...

    def move(self, src: Path, dest: Path) -> None: ...


@dataclass
class RealFileSystem(FileSystem):
    """Disk-backed FileSystem implementation."""

    def exists(self, path: Path) -> bool:
        return path.exists()

    def ensure_dir(self, path: Path) -> None:
        path.mkdir(parents=True, exist_ok=True)

    def copy_file(self, src: Path, dest: Path) -> None:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, dest)

    def copy_tree(self, src: Path, dest: Path) -> None:
        for file_path in src.rglob("*"):
            if file_path.is_dir():
                continue
            relative = file_path.relative_to(src)
            target_path = dest / relative
            self.copy_file(file_path, target_path)

    def list_files(self, path: Path) -> Iterable[Path]:
        if not path.exists():
            return []
        return [p for p in path.iterdir() if p.is_file()]

    def read_text(self, path: Path) -> str:
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def move(self, src: Path, dest: Path) -> None:
        dest.parent.mkdir(parents=True, exist_ok=True)
        if dest.exists() and dest.is_file():
            dest.unlink()
        src.replace(dest)


def resolve_workspace() -> Path:
    """Resolve repository workspace root."""
    return Path.cwd()


def get_est_timestamp(now_provider: Callable[[], datetime] | None = None) -> str:
    """Return a Windows-safe timestamp string for America/New_York."""
    now = (
        now_provider()
        if now_provider
        else datetime.now(tz=ZoneInfo("America/New_York"))
    )
    if now.tzinfo is None:
        raise ValueError("now_provider must return a timezone-aware datetime")
    localized = now.astimezone(ZoneInfo("America/New_York"))
    return localized.strftime("%Y-%m-%dT%H-%M")


def extract_date_from_timestamp(timestamp: str) -> str:
    """Extract YYYY-MM-DD date component from a timestamp string."""
    return timestamp.split("T", 1)[0]


def validate_feature_name(feature_name: str) -> None:
    """Validate feature-name slug format."""
    if not feature_name or not NAME_PATTERN.fullmatch(feature_name):
        raise ValueError(
            f"Aborted: '{feature_name}' is invalid. Use kebab/underscore-case "
            "letters/numbers (e.g., notes-feature or notes_feature)."
        )
