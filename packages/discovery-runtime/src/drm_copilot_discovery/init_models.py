"""Core models and filesystem contract for discovery-workspace initialization."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Protocol


class FileSystem(Protocol):
    """Filesystem contract for discovery-workspace initialization."""

    def exists(self, path: Path) -> bool:
        """Return whether the supplied path exists in the backing store."""
        ...

    def is_dir(self, path: Path) -> bool:
        """Return whether the supplied path represents a directory."""
        ...

    def list_dir(self, path: Path) -> list[Path]:
        """Return direct children of a supplied directory or raise its I/O error."""
        ...

    def ensure_dir(self, path: Path) -> None:
        """Create a supplied directory and missing ancestors or raise an I/O error."""
        ...

    def read_text(self, path: Path) -> str:
        """Read UTF-8 content from the supplied path or raise its I/O error."""
        ...

    def write_text(self, path: Path, content: str) -> None:
        """Write supplied UTF-8 content and create parents or raise an I/O error."""
        ...


@dataclass
class RealFileSystem(FileSystem):
    """Disk-backed `FileSystem` implementation."""

    def exists(self, path: Path) -> bool:
        """Query the supplied disk path without changing it."""
        return path.exists()

    def is_dir(self, path: Path) -> bool:
        """Query whether the supplied disk path is a directory."""
        return path.is_dir()

    def list_dir(self, path: Path) -> list[Path]:
        """Read direct directory children, propagating filesystem errors."""
        return list(path.iterdir())

    def ensure_dir(self, path: Path) -> None:
        """Create the supplied directory and parents, propagating I/O errors."""
        path.mkdir(parents=True, exist_ok=True)

    def read_text(self, path: Path) -> str:
        """Return UTF-8 disk content, propagating missing or unreadable-file errors."""
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
        """Preserve legacy UTF-8 writes and parent creation, propagating I/O errors."""
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")


DOMAIN_PROFILE_RELATIVE_PATH = Path("domain-profile/domain-profile.yaml")

ARTIFACT_RELATIVE_PATHS: tuple[Path, ...] = (
    Path("artifacts/feature-contract.template.json"),
    Path("artifacts/coverage-ledger.template.json"),
    Path("artifacts/runtime-characterization-scenario.template.json"),
    Path("artifacts/parity-matrix.template.json"),
    Path("artifacts/unspecified-behavior-record.template.json"),
    Path("artifacts/product-decision-record.template.json"),
    Path("artifacts/evidence-reference.template.json"),
)

EXPECTED_TEMPLATE_RELATIVE_PATHS: tuple[Path, ...] = (
    DOMAIN_PROFILE_RELATIVE_PATH,
    *ARTIFACT_RELATIVE_PATHS,
)

OUTPUT_RELATIVE_PATHS: tuple[Path, ...] = (
    Path("domain-profile.yaml"),
    Path("artifacts/feature-contract.json"),
    Path("artifacts/coverage-ledger.json"),
    Path("artifacts/runtime-characterization-scenario.json"),
    Path("artifacts/parity-matrix.json"),
    Path("artifacts/unspecified-behavior-record.json"),
    Path("artifacts/product-decision-record.json"),
    Path("artifacts/evidence-reference.json"),
)
