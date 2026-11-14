"""Default scheduling tolerance delivered by an overlay-free push (issue #1013).

Spec D-1 and AC-01: a destination with no ``config/blast-radius.local.json``
receives the published ``conflict_tolerance`` defaults, ``tolerance_percent``
100 and ``combination_threshold_percent`` 400. The test reproduces the
push-down's in-memory steps over the committed bundled truth table: derive the
destination document from an empty destination scan, then compose it with no
overlay (the path ``compose_blast_radius_overlay`` takes when the overlay file
is absent). No file is written and no process is started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

from scripts.dev_tools.push_down_claude_blast_radius_derive_core import (
    derive_destination_module_map,
)
from scripts.dev_tools.push_down_claude_blast_radius_overlay import (
    BLAST_RADIUS_OVERLAY_RELATIVE_PATH,
    compose_blast_radius_overlay,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_TABLE = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "claude-customizations"
    / "config"
    / "blast-radius.json"
)


def destination_conflict_tolerance() -> dict[str, object]:
    """Return the destination conflict_tolerance after an overlay-free push."""
    source_text = BUNDLED_TABLE.read_text(encoding="utf-8")
    derived = derive_destination_module_map([], source_text)

    composed = compose_blast_radius_overlay(
        derived, None, BLAST_RADIUS_OVERLAY_RELATIVE_PATH
    )

    document = cast("dict[str, object]", json.loads(composed))
    return cast("dict[str, object]", document["conflict_tolerance"])


def test_overlay_free_push_delivers_tolerance_percent_100() -> None:
    """The destination receives the published nonzero tolerance_percent."""
    member = destination_conflict_tolerance()

    assert member["tolerance_percent"] == 100


def test_overlay_free_push_delivers_combination_threshold_400() -> None:
    """The destination receives the published combination threshold."""
    member = destination_conflict_tolerance()

    assert member["combination_threshold_percent"] == 400
