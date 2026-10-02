"""Python/TypeScript parity for the blast-radius overlay (issue #508).

Purpose:
    Extend the #507 parity contract in ``test_push_down_claude_parity.py`` to
    the #508 overlay: the merged-path registries, the overlay path constant,
    and the overlay exclusion agree across the two push-down implementations,
    and the Python composition reproduces the shared committed corpus under
    ``tests/fixtures/blast_radius_overlay/`` byte for byte. The TypeScript
    declarations are read as committed text.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import cast

from scripts.dev_tools.push_down_claude_blast_radius_overlay import (
    BLAST_RADIUS_OVERLAY_RELATIVE_PATH,
    compose_blast_radius_overlay,
)
from scripts.dev_tools.push_down_claude_customizations import EXCLUDED_RELATIVE_PATHS
from scripts.dev_tools.push_down_claude_destination_writes import MERGED_PATHS
from tests.scripts.dev_tools.test_push_down_claude_parity import (
    REPO_ROOT,
    TS_CUSTOMIZATIONS,
)

TS_OVERLAY = "extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts"
CORPUS_DIR = REPO_ROOT / "tests" / "fixtures" / "blast_radius_overlay"
OVERLAY_PATH = "config/blast-radius.local.json"
_STRING = re.compile(r"\"([^\"\\]*)\"")
_OVERLAY_CONSTANT = re.compile(
    r"export\s+const\s+BLAST_RADIUS_OVERLAY_RELATIVE_PATH\s*=\s*\"([^\"\\]*)\""
)


def _ts_array_literals(relative_path: str, name: str) -> set[str]:
    """Return the string literals between ``export const <name>`` and ``];``."""

    text = (REPO_ROOT / relative_path).read_text(encoding="utf-8")
    start = text.find(f"export const {name}")
    assert start != -1, f"{relative_path}: found zero {name} declarations"
    end = text.find("];", start)
    assert end != -1, f"{relative_path}: {name} has no closing bracket"
    return set(_STRING.findall(text[start:end]))


def test_ac16_merged_path_sets_match() -> None:
    """The TypeScript and Python merged-path sets are equal."""

    ts_paths = _ts_array_literals(TS_CUSTOMIZATIONS, "MERGED_RELATIVE_PATHS")
    py_paths = {entry.relative_path for entry in MERGED_PATHS}

    assert ts_paths == py_paths, (ts_paths, py_paths)
    assert ts_paths == {"config/orchestration-routing.json", "config/blast-radius.json"}


def test_ac16_overlay_constants_match() -> None:
    """The TypeScript and Python overlay path constants are equal."""

    text = (REPO_ROOT / TS_OVERLAY).read_text(encoding="utf-8")
    match = _OVERLAY_CONSTANT.search(text)

    assert match is not None, f"{TS_OVERLAY}: overlay constant not found"
    assert match.group(1) == BLAST_RADIUS_OVERLAY_RELATIVE_PATH == OVERLAY_PATH


def test_ac11_overlay_excluded_in_both_implementations() -> None:
    """Both publishers exclude the overlay from publication."""

    ts_excluded = _ts_array_literals(TS_CUSTOMIZATIONS, "EXCLUDED_RELATIVE_PATHS")

    assert OVERLAY_PATH in ts_excluded, ts_excluded
    assert Path(OVERLAY_PATH) in EXCLUDED_RELATIVE_PATHS


def test_ac16_corpus_composition_matches_expected() -> None:
    """The Python composition reproduces every shared corpus case."""

    paths = sorted(CORPUS_DIR.glob("*.json"))

    assert len(paths) >= 6, paths
    for path in paths:
        case = cast("dict[str, str]", json.loads(path.read_text(encoding="utf-8")))
        composed = compose_blast_radius_overlay(
            case["base_text"], case["overlay_text"], OVERLAY_PATH
        )
        assert composed == case["expected_text"], path.name
