"""Compatibility wrapper for extension-side push-down customization publishing.

Purpose:
    Preserve the bundled-script entry point while delegating all publishing
    behavior to the bundled package implementation.

Usage:
    python push_down_copilot_customizations.py --destination <path>

Flow:
    1. Ensure `resources/scripts/` is importable at runtime.
    2. Import `dev_tools.push_down_copilot_customizations` from bundled sources.
    3. Resolve `source_root` to `resources/customizations` payload.
    4. Resolve `artifact_root` to the current working directory.
    5. Invoke publisher in-process with `--destination` from CLI args.

Invariants / Constraints:
    - No publishing logic is implemented in this wrapper.
    - Argument contract is owned by the publisher module and forwarded unchanged.

Side Effects:
    Imports bundled publisher code and executes it in the current Python process.
"""

from __future__ import annotations

import argparse
import importlib
import sys
from pathlib import Path
from typing import Protocol


class _PublisherResult(Protocol):
    """Typed contract for the PushDownSummary surface accessed by this wrapper."""

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
    """Prepend bundled `resources/scripts` directory to ``sys.path``.

    Purpose:
        Make extension-bundled Python packages importable regardless of the
        destination workspace layout.

    Side Effects:
        Mutates ``sys.path`` by inserting the bundled scripts directory at
        index 0 when not already present.
    """
    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)

    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


def main() -> int:
    """Execute bundled push-down customization publisher in-process.

    Purpose:
        Keep the bundled extension script as a thin adapter and avoid duplicated
        publishing logic while resolving source and artifact roots automatically.

    Returns:
        Exit code from bundled publisher main function.

    Side Effects:
        Imports the bundled publisher module and executes its publishing flow.
    """
    _ensure_bundled_scripts_import_path()

    parser = argparse.ArgumentParser(
        description="Bundled push-down customization publisher wrapper."
    )
    parser.add_argument(
        "--destination",
        required=True,
        help="Destination workspace root that will receive the copied .github trees.",
    )
    args = parser.parse_args()

    # Extract typed callables from the dynamically loaded publisher module.
    module = importlib.import_module("dev_tools.push_down_copilot_customizations")
    publish_fn: _PublisherFunction = module.push_down_customizations
    fs_factory: _FileSystemFactory = module.RealPushDownFileSystem

    customizations_root = Path(__file__).resolve().parent.parent / "customizations"
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
