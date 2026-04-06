"""Compatibility wrapper for extension-side Codex/agents customization publishing.

Purpose:
    Preserve the bundled-script entry point while delegating all publishing
    behavior to the bundled package implementation.
"""

from __future__ import annotations

import argparse
import importlib
import sys
from pathlib import Path
from typing import Protocol


class _PublisherResult(Protocol):
    """Typed contract for the push-down summary surface accessed by this wrapper."""

    artifact_path: str


class _FileSystemFactory(Protocol):
    """Construction contract for the publisher's filesystem implementation."""

    def __call__(self) -> object: ...


class _PublisherFunction(Protocol):
    """Call contract matching the bundled push_down_customizations signature."""

    def __call__(
        self,
        *,
        repo_root: Path,
        destination_root: Path,
        fs: object,
        source_root: Path,
        artifact_root: Path,
    ) -> _PublisherResult: ...


def _ensure_bundled_scripts_import_path() -> None:
    """Prepend bundled `resources/scripts` directory to ``sys.path``."""

    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)

    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


def main() -> int:
    """Execute the bundled Codex/agents publisher in-process."""

    _ensure_bundled_scripts_import_path()

    parser = argparse.ArgumentParser(
        description="Bundled Codex/agents customization publisher wrapper."
    )
    parser.add_argument(
        "--destination",
        required=True,
        help=(
            "Destination workspace root that will receive the copied .codex "
            "and .agents trees."
        ),
    )
    args = parser.parse_args()

    module = importlib.import_module(
        "dev_tools.push_down_codex_and_agents_customizations"
    )
    publish_fn: _PublisherFunction = module.push_down_customizations
    fs_factory: _FileSystemFactory = module.RealPushDownFileSystem

    customizations_root = (
        Path(__file__).resolve().parent.parent / "codex-and-agents-customizations"
    )
    resolved_destination = Path(args.destination).expanduser().resolve()
    artifact_root = Path.cwd().resolve()

    summary = publish_fn(
        repo_root=customizations_root,
        destination_root=resolved_destination,
        fs=fs_factory(),
        source_root=customizations_root,
        artifact_root=artifact_root,
    )
    print(f"Wrote push-down summary artifact to: {summary.artifact_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
