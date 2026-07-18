"""Pure orchestration for discovery-workspace initialization.

Contains no `argparse` or `print` calls, so it is directly unit-testable
against the injected `FileSystem` protocol.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools.discovery.init_models import (
    EXPECTED_TEMPLATE_RELATIVE_PATHS,
    OUTPUT_RELATIVE_PATHS,
)

if TYPE_CHECKING:
    from collections.abc import Mapping
    from pathlib import Path

    from scripts.dev_tools.discovery.init_models import FileSystem


def validate_template_set(template_root: Path, fs: FileSystem) -> None:
    """Raise `FileNotFoundError` naming every missing expected template path."""
    missing: list[str] = []
    if not fs.exists(template_root):
        missing.append(str(template_root))
    else:
        for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
            if not fs.exists(template_root / relative_path):
                missing.append(str(relative_path))

    if missing:
        raise FileNotFoundError(
            "Missing required discovery template path(s): " + ", ".join(missing)
        )


def validate_target_path(target_dir: Path, fs: FileSystem, *, force: bool) -> None:
    """Raise fail-fast errors for an invalid discovery-workspace target path."""
    if not fs.exists(target_dir.parent):
        raise FileNotFoundError(
            f"Target directory's parent does not exist: {target_dir.parent}"
        )

    if fs.exists(target_dir):
        if not fs.is_dir(target_dir):
            raise NotADirectoryError(
                f"Target path exists and is not a directory: {target_dir}"
            )
        if fs.list_dir(target_dir) and not force:
            raise FileExistsError(
                f"Target directory is non-empty: {target_dir}. "
                "Pass force=True to proceed anyway."
            )


def substitute_placeholders(text: str, tokens: Mapping[str, str] | None = None) -> str:
    """Replace each token key in `text` with its value via literal `str.replace`."""
    if not tokens:
        return text
    result = text
    for token, value in tokens.items():
        result = result.replace(token, value)
    return result


def create_discovery_workspace(
    target_dir: Path,
    template_root: Path,
    fs: FileSystem,
    *,
    force: bool = False,
) -> None:
    """Scaffold a discovery workspace at `target_dir` from `template_root`.

    Validates the template set and the target path before writing any file, so
    a partial or otherwise invalid input never produces a partial scaffold.
    """
    validate_template_set(template_root, fs)
    validate_target_path(target_dir, fs, force=force)

    fs.ensure_dir(target_dir)
    fs.ensure_dir(target_dir / "artifacts")

    for template_relative, output_relative in zip(
        EXPECTED_TEMPLATE_RELATIVE_PATHS, OUTPUT_RELATIVE_PATHS, strict=True
    ):
        template_text = fs.read_text(template_root / template_relative)
        rendered_text = substitute_placeholders(template_text)
        fs.write_text(target_dir / output_relative, rendered_text)
