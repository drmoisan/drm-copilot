"""Shared-surface demotion through the Python blast-radius overlay (issue #1006).

Mirrors ``claude-blast-radius-overlay-demote.test.ts``. The overlay directive
``shared_surfaces_demote`` moves named entries from ``shared_surfaces`` to
``conflict_tolerance.append_only_paths`` after every other key is composed, is
consumed rather than emitted, and fails closed before any write. Every
filesystem is in memory; the destination layout is described by an injected
lister, and the committed bundled truth table is read as text only.
"""

from __future__ import annotations

import importlib
import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools.push_down_claude_blast_radius_overlay import (
    BLAST_RADIUS_OVERLAY_RELATIVE_PATH,
    SHARED_SURFACES_DEMOTE_KEY,
    BlastRadiusGuardError,
    BlastRadiusOverlayError,
    compose_blast_radius_overlay,
)
from scripts.dev_tools.push_down_claude_destination_writes import (
    DestinationMergeFileSystem,
)
from tests.scripts.dev_tools.test_push_down_claude_customizations import (
    MemoryFile,
    RecordingFileSystem,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

    from scripts.dev_tools.push_down_claude_blast_radius_derive import (
        DirectoryEntry,
    )

JsonObject = dict[str, object]

REPO_ROOT = Path(__file__).resolve().parents[3]
COMMITTED_BUNDLED_TEXT = (
    REPO_ROOT
    / "extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json"
).read_text(encoding="utf-8")

SOURCE = Path("/repo")
DEST = Path("/dest")
BUNDLE = SOURCE / "extensions/drm-copilot/resources/claude-customizations"
TARGET = DEST / "config" / "blast-radius.json"
OVERLAY = DEST / "config" / "blast-radius.local.json"
OVERLAY_REL = BLAST_RADIUS_OVERLAY_RELATIVE_PATH
PRIOR = "prior bytes\n"
TIER_MAP = "quality-tiers.yml"
MESSAGE_PREFIX = (
    f"Blast-radius overlay {OVERLAY_REL} was not applied; "
    "config/blast-radius.json was not written: "
)


def _doc(value: JsonObject) -> str:
    """Serialize a document the way the push-down writes it.

    Args:
        value (JsonObject): Document to serialize.

    Returns:
        str: 2-space indented JSON with one trailing newline.
    """
    return json.dumps(value, indent=2) + "\n"


# A base with the tier map shared between two other surfaces.
BASE: JsonObject = {
    "version": 1,
    "shared_surfaces": ["a.json", TIER_MAP, "b.json"],
    "conflict_tolerance": {
        "tolerance_percent": 100,
        "append_only_paths": ["**/CHANGELOG.md"],
    },
    "modules": {"config": ["config/**"]},
}
DEMOTE_TIER_MAP: JsonObject = {SHARED_SURFACES_DEMOTE_KEY: [TIER_MAP]}


def _compose(base: JsonObject, overlay: JsonObject) -> JsonObject:
    """Compose two documents and parse the result.

    Args:
        base (JsonObject): Base document.
        overlay (JsonObject): Overlay document.

    Returns:
        JsonObject: The parsed composed document.
    """
    parsed: JsonObject = json.loads(
        compose_blast_radius_overlay(_doc(base), _doc(overlay), OVERLAY_REL)
    )
    return parsed


def _tolerance(document: JsonObject) -> JsonObject:
    """Return the ``conflict_tolerance`` block of a parsed document.

    Args:
        document (JsonObject): Parsed composed document.

    Returns:
        JsonObject: The policy block.
    """
    return cast("JsonObject", document["conflict_tolerance"])


def _rejection(overlay: JsonObject, base: JsonObject | None = None) -> str:
    """Compose an overlay that must fail and return the error message.

    Args:
        overlay (JsonObject): Overlay expected to be rejected.
        base (JsonObject | None): Base document; ``BASE`` when omitted.

    Returns:
        str: The ``BlastRadiusOverlayError`` message.
    """
    with pytest.raises(BlastRadiusOverlayError) as caught:
        compose_blast_radius_overlay(_doc(base or BASE), _doc(overlay), OVERLAY_REL)
    return str(caught.value)


def _empty_lister(path: Path) -> Sequence[DirectoryEntry]:
    """Describe a destination layout with no entries at any path.

    Args:
        path (Path): Ignored directory path.

    Returns:
        Sequence[DirectoryEntry]: An empty listing.
    """
    del path
    return []


def test_demotion_moves_the_entry_and_keeps_the_remaining_order() -> None:
    """The entry leaves ``shared_surfaces`` and is appended last to the paths."""
    composed = _compose(BASE, DEMOTE_TIER_MAP)

    assert composed["shared_surfaces"] == ["a.json", "b.json"]
    assert _tolerance(composed)["append_only_paths"] == ["**/CHANGELOG.md", TIER_MAP]


def test_demotion_consumes_the_directive_key() -> None:
    """The directive key is absent from the composed document."""
    composed = _compose(BASE, DEMOTE_TIER_MAP)

    assert SHARED_SURFACES_DEMOTE_KEY not in composed
    assert list(composed) == list(BASE)


def test_demotion_runs_after_every_other_key() -> None:
    """Entries the same overlay adds are composed first and then demoted."""
    overlay: JsonObject = {
        "shared_surfaces": ["c.json"],
        "conflict_tolerance": {"append_only_paths": ["docs/log.md"]},
        SHARED_SURFACES_DEMOTE_KEY: ["c.json", TIER_MAP],
    }

    composed = _compose(BASE, overlay)

    assert composed["shared_surfaces"] == ["a.json", "b.json"]
    assert _tolerance(composed)["append_only_paths"] == [
        "**/CHANGELOG.md",
        "docs/log.md",
        "c.json",
        TIER_MAP,
    ]


def test_already_append_only_entry_is_a_no_op() -> None:
    """An entry that is append-only and not shared leaves the document as is."""
    base = _compose(BASE, DEMOTE_TIER_MAP)

    composed = compose_blast_radius_overlay(
        _doc(base), _doc(DEMOTE_TIER_MAP), OVERLAY_REL
    )

    assert composed == _doc(base)


def test_composing_a_composed_result_again_is_identical() -> None:
    """Demotion is idempotent across repeated composition."""
    once = compose_blast_radius_overlay(_doc(BASE), _doc(DEMOTE_TIER_MAP), OVERLAY_REL)

    twice = compose_blast_radius_overlay(once, _doc(DEMOTE_TIER_MAP), OVERLAY_REL)

    assert twice == once


@pytest.mark.parametrize(
    ("label", "value"),
    [("a non-list value", TIER_MAP), ("a non-string member", [TIER_MAP, 3])],
)
def test_malformed_directive_is_rejected(label: str, value: object) -> None:
    """A non-list value and a non-string member fail with the shape detail."""
    message = _rejection({SHARED_SURFACES_DEMOTE_KEY: value})

    assert message == (
        MESSAGE_PREFIX + 'key "shared_surfaces_demote" must be a list of strings'
    ), label


@pytest.mark.parametrize(
    "tolerance",
    [None, {"tolerance_percent": 100}],
    ids=["no-conflict-tolerance", "no-append-only-paths"],
)
def test_missing_append_only_paths_is_rejected(tolerance: object) -> None:
    """A composed document without the append-only list fails closed."""
    base: JsonObject = {"version": 1, "shared_surfaces": [TIER_MAP]}
    if tolerance is not None:
        base["conflict_tolerance"] = tolerance

    message = _rejection(DEMOTE_TIER_MAP, base)

    assert message == (
        MESSAGE_PREFIX + 'key "shared_surfaces_demote" requires '
        "conflict_tolerance.append_only_paths in the composed document"
    )


def test_unknown_entry_is_rejected() -> None:
    """An entry that is neither shared nor append-only fails closed."""
    message = _rejection({SHARED_SURFACES_DEMOTE_KEY: ["no-such-surface.json"]})

    assert message == (
        MESSAGE_PREFIX + 'key "shared_surfaces_demote" names "no-such-surface.json", '
        "which is neither a shared surface nor an append-only path"
    )


def test_rejection_keeps_the_prior_destination_bytes() -> None:
    """A rejected demotion never writes the destination truth table."""
    inner = RecordingFileSystem(
        files={
            TARGET: MemoryFile(PRIOR),
            OVERLAY: MemoryFile(_doc({SHARED_SURFACES_DEMOTE_KEY: ["missing.json"]})),
        }
    )
    inner.directories.add(DEST)
    fs = DestinationMergeFileSystem(inner, destination_root=DEST)

    with pytest.raises(BlastRadiusOverlayError):
        fs.write_text(TARGET, _doc(BASE))

    assert inner.read_text(TARGET) == PRIOR


def test_forbidden_glob_guard_still_runs_with_the_directive() -> None:
    """The ``modules`` guard rejects a forbidden glob alongside the directive."""
    overlay: JsonObject = {"modules": {"everything": ["**"]}, **DEMOTE_TIER_MAP}

    with pytest.raises(BlastRadiusGuardError):
        compose_blast_radius_overlay(_doc(BASE), _doc(overlay), OVERLAY_REL)


def test_ac04_push_demotes_quality_tiers_with_tolerance_5000() -> None:
    """A push composes the destination demotion onto the committed bundled table."""
    fs = RecordingFileSystem(
        files={
            SOURCE / ".claude" / "settings.json": MemoryFile('{"shared": true}\n'),
            BUNDLE / "config" / "blast-radius.json": MemoryFile(COMMITTED_BUNDLED_TEXT),
            BUNDLE
            / "config"
            / "orchestration-routing.json": MemoryFile(
                _doc({"version": 2, "routes": {}})
            ),
            OVERLAY: MemoryFile(
                _doc(
                    {
                        SHARED_SURFACES_DEMOTE_KEY: [TIER_MAP],
                        "conflict_tolerance": {"tolerance_percent": 5000},
                    }
                )
            ),
        }
    )
    fs.directories.update({SOURCE, DEST})
    module = importlib.import_module(
        "scripts.dev_tools.push_down_claude_customizations"
    )

    module.push_down_customizations(
        repo_root=SOURCE,
        destination_root=DEST,
        fs=fs,
        source_root=SOURCE,
        artifact_root=DEST,
        packs=None,
        list_entries=_empty_lister,
    )

    composed = cast("JsonObject", json.loads(fs.read_text(TARGET)))
    tolerance = _tolerance(composed)
    assert TIER_MAP in cast("list[str]", tolerance["append_only_paths"])
    assert TIER_MAP not in cast("list[str]", composed["shared_surfaces"])
    assert tolerance["tolerance_percent"] == 5000
    assert SHARED_SURFACES_DEMOTE_KEY not in composed
