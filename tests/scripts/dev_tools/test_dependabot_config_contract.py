"""Contract regression tests for the Dependabot configuration.

These tests assert against the committed ``.github/dependabot.yml`` document.
The repository root is computed from this file's own resolved path and the
configuration is read as UTF-8 text, then parsed with ``yaml.safe_load``. The
tests assert configuration shape only; they cannot simulate Dependabot.
"""

from __future__ import annotations

import functools
from pathlib import Path
from typing import cast

import pytest
import yaml

REPO_ROOT = Path(__file__).resolve().parents[3]
DEPENDABOT_CONFIG_PATH = ".github/dependabot.yml"
ROOT_DIRECTORY = "/"
EXTENSION_DIRECTORY = "/extensions/drm-copilot"
TARGET_DIRECTORIES = (ROOT_DIRECTORY, EXTENSION_DIRECTORY)
NPM_ECOSYSTEM = "npm"
TYPES_VSCODE_NAME = "@types/vscode"
TYPESCRIPT_NAME = "typescript"
SEMVER_MAJOR_UPDATE_TYPE = "version-update:semver-major"


@functools.cache
def load_target_npm_entries() -> tuple[dict[str, object], ...]:
    """Return the npm update entries for the two directories under test.

    Isolates the untyped ``yaml.safe_load`` boundary so callers work against
    narrowed mappings. The result is cached for the session and must not be
    mutated.
    """
    text = (REPO_ROOT / DEPENDABOT_CONFIG_PATH).read_text(encoding="utf-8")
    parsed = yaml.safe_load(text)
    document = cast("dict[str, object]", parsed)
    updates = cast("list[object]", document["updates"])
    entries: list[dict[str, object]] = []
    for update in updates:
        entry = cast("dict[str, object]", update)
        if entry.get("package-ecosystem") != NPM_ECOSYSTEM:
            continue
        if entry.get("directory") in TARGET_DIRECTORIES:
            entries.append(entry)
    return tuple(entries)


def npm_entry_for(directory: str) -> dict[str, object]:
    """Return the single npm update entry whose ``directory`` equals ``directory``."""
    matches = [
        entry for entry in load_target_npm_entries() if entry["directory"] == directory
    ]
    assert (
        len(matches) == 1
    ), f"expected one npm entry for directory {directory}, found {len(matches)}"
    return matches[0]


def ignore_items_named(
    entry: dict[str, object], dependency_name: str
) -> list[dict[str, object]]:
    """Return the ``ignore`` items of ``entry`` that name ``dependency_name``."""
    ignore = cast("list[object]", entry.get("ignore", []))
    items = [cast("dict[str, object]", item) for item in ignore]
    return [item for item in items if item.get("dependency-name") == dependency_name]


@pytest.mark.parametrize(
    "directory", [ROOT_DIRECTORY, EXTENSION_DIRECTORY], ids=["root", "extension"]
)
def test_npm_entry_ignores_types_vscode_for_all_update_types(directory: str) -> None:
    """The npm entry ignores ``@types/vscode`` with no update-type restriction."""
    entry = npm_entry_for(directory)

    items = ignore_items_named(entry, TYPES_VSCODE_NAME)

    assert items, (
        f"npm entry for directory {directory} lacks an ignore item for "
        f"{TYPES_VSCODE_NAME}"
    )
    unrestricted = any(
        "update-types" not in item and "versions" not in item for item in items
    )
    assert unrestricted, f"no unrestricted ignore item for {TYPES_VSCODE_NAME}"


@pytest.mark.parametrize(
    "directory", [ROOT_DIRECTORY, EXTENSION_DIRECTORY], ids=["root", "extension"]
)
def test_npm_entry_retains_typescript_major_ignore(directory: str) -> None:
    """The npm entry keeps its ``typescript`` major-version ignore item."""
    entry = npm_entry_for(directory)

    items = ignore_items_named(entry, TYPESCRIPT_NAME)

    assert items, f"npm entry for directory {directory} lacks a typescript ignore"
    restricted = any(
        item.get("update-types") == [SEMVER_MAJOR_UPDATE_TYPE] for item in items
    )
    assert restricted, (
        f"no typescript ignore item restricted to {SEMVER_MAJOR_UPDATE_TYPE} "
        f"for directory {directory}"
    )


def test_exactly_two_target_npm_entries_are_checked() -> None:
    """Exactly two npm entries are selected, so the other tests are not vacuous."""
    entries = load_target_npm_entries()

    assert len(entries) == 2, f"expected 2 target npm entries, found {len(entries)}"
