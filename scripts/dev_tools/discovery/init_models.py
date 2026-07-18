"""Core models and filesystem contract for discovery-workspace initialization."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Protocol


class FileSystem(Protocol):
    """Filesystem contract for discovery-workspace initialization."""

    def exists(self, path: Path) -> bool: ...

    def is_dir(self, path: Path) -> bool: ...

    def list_dir(self, path: Path) -> list[Path]: ...

    def ensure_dir(self, path: Path) -> None: ...

    def read_text(self, path: Path) -> str: ...

    def write_text(self, path: Path, content: str) -> None: ...


@dataclass
class RealFileSystem(FileSystem):
    """Disk-backed `FileSystem` implementation."""

    def exists(self, path: Path) -> bool:
        return path.exists()

    def is_dir(self, path: Path) -> bool:
        return path.is_dir()

    def list_dir(self, path: Path) -> list[Path]:
        return list(path.iterdir())

    def ensure_dir(self, path: Path) -> None:
        path.mkdir(parents=True, exist_ok=True)

    def read_text(self, path: Path) -> str:
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
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


def resolve_default_template_root() -> Path:
    """Return the bundled default discovery-templates root."""
    return Path(__file__).resolve().parents[3] / "docs" / "discovery" / "templates"
