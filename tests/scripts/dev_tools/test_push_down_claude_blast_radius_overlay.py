"""Destination blast-radius overlay through the Python Claude push-down (issue #508).

Mirrors ``claude-blast-radius-overlay.test.ts`` and the #508 carriage case in
``claude-config-carriage.test.ts`` (``extensions/drm-copilot/test/lib/push-down/``): the
destination-owned ``config/blast-radius.local.json`` is composed onto the
regenerated ``config/blast-radius.json`` on every push, is never published
from the source, and is never written by a push. Every filesystem is in
memory; the destination layout is described by an injected lister.
"""

from __future__ import annotations

import importlib
import itertools
import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools.push_down_claude_blast_radius_overlay import (
    BLAST_RADIUS_OVERLAY_RELATIVE_PATH,
    FORBIDDEN_GLOBS,
    BlastRadiusGuardError,
    BlastRadiusOverlayError,
    compose_blast_radius_overlay,
)
from scripts.dev_tools.push_down_claude_destination_writes import (
    MERGED_PATHS,
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
    from scripts.dev_tools.push_down_copilot_customizations import PushDownSummary

JsonObject = dict[str, object]

SOURCE = Path("/repo")
DEST = Path("/dest")
# CONFIG_PUBLISH_ROOT recorded by P0-T9: the bundle root inside the source.
BUNDLE = SOURCE / "extensions/drm-copilot/resources/claude-customizations"
TARGET = DEST / "config" / "blast-radius.json"
OVERLAY = DEST / "config" / "blast-radius.local.json"
OVERLAY_REL = BLAST_RADIUS_OVERLAY_RELATIVE_PATH
PRIOR = "prior bytes\n"
STRING_LIST_KEYS = (
    "shared_surfaces",
    "shared_surface_globs",
    "mandate_reads",
    "mergeable_paths",
    "path_roots",
)


def _doc(value: JsonObject) -> str:
    """Serialize a document the way the push-down writes it."""
    return json.dumps(value, indent=2) + "\n"


BASE_TEXT = _doc(
    {
        "version": 1,
        "shared_surfaces": ["config/blast-radius.json"],
        "mandate_reads": [],
        "modules": {"config": ["config/**"]},
    }
)
OVERLAY_TEXT = _doc(
    {
        "shared_surfaces": ["Directory.Build.props"],
        "modules": {"destination-app": ["app/**"]},
    }
)
ROUTING_TEXT = _doc({"version": 2, "routes": {}})


class WriteRecordingFileSystem(RecordingFileSystem):
    """Record every ``write_text`` path in call order."""

    def __init__(self, *, files: dict[Path, MemoryFile] | None = None) -> None:
        """Initialise the store and an empty write log."""
        super().__init__(files=files)
        self.written_paths: list[Path] = []

    def write_text(self, path: Path, content: str) -> None:
        """Record the path, then persist the content."""
        self.written_paths.append(path)
        super().write_text(path, content)


def _empty_lister(path: Path) -> Sequence[DirectoryEntry]:
    """Describe a destination layout with no entries at any path."""
    del path
    return []


def _seed(extra: dict[Path, str] | None = None) -> WriteRecordingFileSystem:
    """Seed one `.claude` file and the bundle `config/` tree."""
    files: dict[Path, MemoryFile] = {
        SOURCE / ".claude" / "settings.json": MemoryFile('{"shared": true}\n'),
        BUNDLE / "config" / "blast-radius.json": MemoryFile(BASE_TEXT),
        BUNDLE / "config" / "orchestration-routing.json": MemoryFile(ROUTING_TEXT),
    }
    for path, content in (extra or {}).items():
        files[path] = MemoryFile(content)
    fs = WriteRecordingFileSystem(files=files)
    fs.directories.update({SOURCE, DEST})
    # Only writes made by a push are recorded.
    fs.written_paths.clear()
    return fs


def _push(fs: WriteRecordingFileSystem) -> PushDownSummary:
    """Run the push-down with the same keyword arguments as CONFIG_SEED_TEST."""
    module = importlib.import_module(
        "scripts.dev_tools.push_down_claude_customizations"
    )
    return module.push_down_customizations(
        repo_root=SOURCE,
        destination_root=DEST,
        fs=fs,
        source_root=SOURCE,
        artifact_root=DEST,
        packs=None,
        list_entries=_empty_lister,
    )


def _compose(base: JsonObject, overlay: JsonObject) -> JsonObject:
    """Compose two documents and parse the result."""
    parsed: JsonObject = json.loads(
        compose_blast_radius_overlay(_doc(base), _doc(overlay), OVERLAY_REL)
    )
    return parsed


def _keys(value: object) -> list[str]:
    """Return the keys of a parsed JSON object in order, or an empty list."""
    return list(cast("JsonObject", value)) if isinstance(value, dict) else []


def _decorate(
    seed: dict[Path, str],
) -> tuple[WriteRecordingFileSystem, DestinationMergeFileSystem]:
    """Build the merge decorator over an in-memory destination."""
    inner = WriteRecordingFileSystem(
        files={path: MemoryFile(text) for path, text in seed.items()}
    )
    inner.directories.add(DEST)
    return inner, DestinationMergeFileSystem(inner, destination_root=DEST)


def _rejected_write(overlay_text: str, error: type[Exception]) -> str:
    """Run a target write that must fail and keep the prior destination bytes."""
    inner, fs = _decorate({TARGET: PRIOR, OVERLAY: overlay_text})
    base = _doc({"version": 1, "conflict_tolerance": {"append_only_paths": ["a"]}})
    with pytest.raises(error) as caught:
        fs.write_text(TARGET, base)
    assert inner.read_text(TARGET) == PRIOR
    assert TARGET not in inner.written_paths
    return str(caught.value)


def test_ac08_push_carries_destination_overlay_entries_across_two_pushes() -> None:
    """Two pushes write identical text carrying the destination overlay entries."""
    fs = _seed({OVERLAY: OVERLAY_TEXT})

    _push(fs)
    first = fs.read_text(TARGET)
    _push(fs)
    second = fs.read_text(TARGET)

    assert second == first
    for text in (first, second):
        assert '"Directory.Build.props"' in text, text
        assert '"destination-app"' in text, text


def test_ac11_source_side_overlay_is_not_published() -> None:
    """A source-side overlay file is never delivered to the destination."""
    fs = _seed({BUNDLE / "config" / "blast-radius.local.json": OVERLAY_TEXT})

    _push(fs)

    assert not fs.is_file(OVERLAY), sorted(str(path) for path in fs.files)


def test_ac01_null_overlay_returns_base_unchanged() -> None:
    """A null overlay returns the base text byte for byte."""
    assert compose_blast_radius_overlay(BASE_TEXT, None, OVERLAY_REL) == BASE_TEXT


def test_ac01_decorator_without_overlay_writes_base_bytes() -> None:
    """Without a destination overlay the base bytes are written unchanged."""
    inner, fs = _decorate({})
    base = '{ "version": 1,   "modules": {} }\n'

    fs.write_text(TARGET, base)

    assert inner.read_text(TARGET) == base


@pytest.mark.parametrize("key", STRING_LIST_KEYS)
def test_ac02_string_list_union_keeps_base_order(key: str) -> None:
    """Overlay-only entries follow the base entries; duplicates are removed."""
    composed = _compose({"version": 1, key: ["a", "b"]}, {key: ["c", "a", "c", "d"]})

    assert composed[key] == ["a", "b", "c", "d"]


@pytest.mark.parametrize("key", STRING_LIST_KEYS)
def test_ac02_string_list_absent_from_base_is_appended(key: str) -> None:
    """A string-list key the base lacks is appended, deduplicated."""
    composed = _compose({"version": 1}, {key: ["x", "y", "x"]})

    assert composed[key] == ["x", "y"]
    assert list(composed) == ["version", key]


MODULE_BASE: JsonObject = {"version": 1, "modules": {"b": ["b/**"], "c": ["c/**"]}}


def test_ac03_overlay_module_is_added() -> None:
    """An overlay module the base lacks is added in ordinal order."""
    composed = _compose(MODULE_BASE, {"modules": {"a": ["a/**"]}})

    assert composed["modules"] == {"a": ["a/**"], "b": ["b/**"], "c": ["c/**"]}


def test_ac03_modules_absent_from_base_are_appended() -> None:
    """An overlay ``modules`` map the base lacks is appended and sorted."""
    composed = _compose({"version": 1}, {"modules": {"z": ["z/**"], "a": ["a/**"]}})

    assert list(composed) == ["version", "modules"]
    assert _keys(composed["modules"]) == ["a", "z"]


@pytest.mark.parametrize("globs", [["c/src/**", "c/lib/**"], ["c/**"]])
def test_ac03_same_name_module_is_replaced(globs: list[str]) -> None:
    """A same-name overlay module replaces the base glob list."""
    composed = _compose(MODULE_BASE, {"modules": {"c": globs}})

    assert composed["modules"] == {"b": ["b/**"], "c": globs}


def test_ac03_module_names_are_emitted_in_ordinal_order() -> None:
    """Module names are emitted in code-point order."""
    composed = _compose(
        {"version": 1, "modules": {"alpha": ["alpha/**"]}},
        {"modules": {"Zeta": ["z/**"], "Beta": ["b/**"]}},
    )

    assert _keys(composed["modules"]) == ["Beta", "Zeta", "alpha"]


def test_ac04_conflict_tolerance_merges_recursively() -> None:
    """Nested objects merge per member and nested lists union."""
    composed = _compose(
        {
            "version": 1,
            "conflict_tolerance": {
                "tolerance_percent": 100,
                "weights": {"same_file": 8, "module": 2},
                "band_durations": {"C1": 1},
                "default_band": "C1",
                "append_only_paths": ["a.md"],
            },
        },
        {
            "conflict_tolerance": {
                "weights": {"module": 3, "extra": 1},
                "band_durations": {"C2": 2},
                "default_band": "C2",
                "append_only_paths": ["b.md", "a.md"],
            }
        },
    )

    assert composed["conflict_tolerance"] == {
        "tolerance_percent": 100,
        "weights": {"same_file": 8, "module": 3, "extra": 1},
        "band_durations": {"C1": 1, "C2": 2},
        "default_band": "C2",
        "append_only_paths": ["a.md", "b.md"],
    }


def test_ac04_overlay_scalars_win() -> None:
    """``over_breadth_fraction`` and ``write_intent_extraction`` take the overlay."""
    composed = _compose(
        {"version": 1, "over_breadth_fraction": 0.25, "write_intent_extraction": True},
        {"over_breadth_fraction": 0.5, "write_intent_extraction": False},
    )

    assert composed["over_breadth_fraction"] == 0.5
    assert composed["write_intent_extraction"] is False


def test_ac04_overlay_only_key_is_appended_last() -> None:
    """A key only the overlay carries follows every base key."""
    composed = _compose({"version": 1, "modules": {}}, {"custom_key": {"k": "v"}})

    assert list(composed) == ["version", "modules", "custom_key"]
    assert composed["custom_key"] == {"k": "v"}


@pytest.mark.parametrize("glob", FORBIDDEN_GLOBS)
def test_ac05_forbidden_overlay_glob_is_rejected(glob: str) -> None:
    """A forbidden overlay glob raises and the destination keeps its bytes."""
    overlay_text = _doc({"modules": {"bad": [glob]}})

    with pytest.raises(BlastRadiusGuardError):
        compose_blast_radius_overlay(_doc({"version": 1}), overlay_text, OVERLAY_REL)
    _rejected_write(overlay_text, BlastRadiusGuardError)


@pytest.mark.parametrize("version", [2, True, "1", {"major": 1}])
def test_ac06_mismatched_version_is_rejected(version: object) -> None:
    """A version differing from the base (type-strict) raises before writing."""
    message = _rejected_write(_doc({"version": version}), BlastRadiusOverlayError)

    assert '"version"' in message


@pytest.mark.parametrize("overlay", [{"version": 1}, {}])
def test_ac06_equal_or_absent_version_emits_base_version(overlay: JsonObject) -> None:
    """An equal or absent overlay version composes to the base version."""
    assert _compose({"version": 1, "modules": {}}, overlay)["version"] == 1


@pytest.mark.parametrize(
    ("text", "key"),
    [
        ("{ not json\n", None),
        ("[]\n", None),
        ("7\n", None),
        ('{"over_breadth_fraction": NaN}\n', None),
        ('{"shared_surfaces": "x"}\n', "shared_surfaces"),
        ('{"mandate_reads": [1]}\n', "mandate_reads"),
        ('{"modules": ["a/**"]}\n', "modules"),
        ('{"modules": {"a": "a/**"}}\n', "modules"),
        (
            '{"conflict_tolerance": {"append_only_paths": [2]}}\n',
            "conflict_tolerance.append_only_paths",
        ),
    ],
)
def test_ac07_malformed_overlay_is_rejected(text: str, key: str | None) -> None:
    """A malformed overlay raises naming the overlay and keeps the prior bytes."""
    message = _rejected_write(text, BlastRadiusOverlayError)

    assert "config/blast-radius.local.json" in message
    if key is not None:
        assert f'"{key}"' in message


def test_ac07_unparseable_base_names_the_main_file() -> None:
    """An unparseable base document raises naming ``config/blast-radius.json``."""
    with pytest.raises(BlastRadiusOverlayError) as caught:
        compose_blast_radius_overlay("{ bad", "{}\n", OVERLAY_REL)

    assert caught.value.path == "config/blast-radius.json"


PROPERTY_BASES = (
    _doc(
        {
            "version": 1,
            "shared_surfaces": [".claude/settings.json", "poetry.lock"],
            "shared_surface_globs": [],
            "mandate_reads": [".claude/rules/**"],
            "mergeable_paths": ["**/*.props"],
            "conflict_tolerance": {"weights": {"module": 2}, "default_band": "C1"},
            "write_intent_extraction": True,
            "path_roots": [],
            "modules": {"config": ["config/**"]},
            "over_breadth_fraction": 0.25,
        }
    ),
    _doc({"version": 1, "shared_surfaces": [], "mandate_reads": [], "modules": {}}),
    _doc(
        {
            "version": 1,
            "shared_surfaces": ["x.json"],
            "modules": {"a": ["a/**"], "b": ["b/**"]},
        }
    ),
)
PROPERTY_OVERLAYS: tuple[JsonObject, ...] = (
    {},
    {"shared_surfaces": ["s1.json"], "mandate_reads": ["m1/**"]},
    {"modules": {"added": ["added/**"]}},
    {"modules": {"a": ["a2/**"]}},
    {"conflict_tolerance": {"append_only_paths": ["x.md"], "weights": {"module": 5}}},
    {"over_breadth_fraction": 0.5},
    {"custom_key": {"k": "v"}},
    {"version": 1},
)
PROPERTY_PAIRS = tuple(itertools.product(PROPERTY_BASES, PROPERTY_OVERLAYS))


def _compose_pair(base: str, overlay: JsonObject) -> str:
    """Compose one property pair and return the text."""
    return compose_blast_radius_overlay(base, _doc(overlay), OVERLAY_REL)


def _list(document: JsonObject, key: str) -> list[object]:
    """Return a list-valued key of a parsed document, or an empty list."""
    value = document.get(key, [])
    return list(cast("list[object]", value)) if isinstance(value, list) else []


def test_ac18_enumerates_all_24_pairs() -> None:
    """The fixed domain is 3 bases by 8 overlays."""
    assert len(PROPERTY_PAIRS) == 24


def test_ac18_identity_empty_overlay_yields_base_text() -> None:
    """An empty overlay composes to the base text."""
    for base in PROPERTY_BASES:
        assert _compose_pair(base, {}) == base


def test_ac18_idempotence_composing_twice_equals_once() -> None:
    """Composing the result again with the same overlay changes nothing."""
    for base, overlay in PROPERTY_PAIRS:
        once = _compose_pair(base, overlay)
        assert _compose_pair(once, overlay) == once, (base, overlay)


def test_ac18_superset_every_base_list_entry_survives() -> None:
    """Every base string-list entry appears in the composed document."""
    for base, overlay in PROPERTY_PAIRS:
        before: JsonObject = json.loads(base)
        after: JsonObject = json.loads(_compose_pair(base, overlay))
        for key in STRING_LIST_KEYS:
            assert set(map(str, _list(before, key))) <= set(map(str, _list(after, key)))


def test_ac18_overlay_inclusion_every_overlay_entry_appears() -> None:
    """Every overlay list entry and module appears in the composed document."""
    for base, overlay in PROPERTY_PAIRS:
        after: JsonObject = json.loads(_compose_pair(base, overlay))
        for key in STRING_LIST_KEYS:
            assert set(map(str, _list(overlay, key))) <= set(
                map(str, _list(after, key))
            )
        for name, globs in cast("JsonObject", overlay.get("modules", {})).items():
            assert cast("JsonObject", after["modules"])[name] == globs, overlay


def test_ac18_determinism_two_calls_are_equal() -> None:
    """Two calls with the same inputs return equal text."""
    for base, overlay in PROPERTY_PAIRS:
        assert _compose_pair(base, overlay) == _compose_pair(base, overlay)


def test_ac18_version_is_preserved() -> None:
    """The composed version is the base version."""
    for base, overlay in PROPERTY_PAIRS:
        before: JsonObject = json.loads(base)
        after: JsonObject = json.loads(_compose_pair(base, overlay))
        assert after["version"] == before["version"]


def test_ac12_push_never_writes_destination_overlay() -> None:
    """A push reads the destination overlay but never writes it."""
    fs = _seed({OVERLAY: OVERLAY_TEXT})

    _push(fs)

    assert fs.read_text(OVERLAY) == OVERLAY_TEXT
    assert OVERLAY not in fs.written_paths
    assert TARGET in fs.written_paths


def test_ac14_merged_paths_registry_shape() -> None:
    """``MERGED_PATHS`` names both merged paths and the overlay input path."""
    by_path = {entry.relative_path: entry for entry in MERGED_PATHS}

    assert set(by_path) == {
        "config/orchestration-routing.json",
        "config/blast-radius.json",
    }
    assert by_path["config/blast-radius.json"].input_relative_path == (
        "config/blast-radius.local.json"
    )
    for entry in MERGED_PATHS:
        assert entry.relative_path
        assert entry.input_relative_path
        assert callable(entry.merge)
