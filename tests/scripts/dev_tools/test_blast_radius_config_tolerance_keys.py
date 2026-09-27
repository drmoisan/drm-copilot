"""Committed values of the issue #722 truth-table keys in both config copies.

Part A pins the ``conflict_tolerance`` key: both committed copies of the
blast-radius truth table carry the committed values of the spec, and the strict
reader of ``scripts/dev_tools/_blast_radius_scheduling.py`` accepts each copy.
Part B pins ``write_intent_extraction`` (true in both copies), the mandate-read
amendment (the Copilot instructions file under ``.github``), and ``path_roots``
(the P0-derived top-level directory list self-hosted, an empty list bundled).
Byte-equality between the copies is asserted by the config-parity module
through the byte-equal key tuple; this module pins the values themselves and
consumes the separate ``path_roots`` Class 2 registry.

Both copies are committed files read through the existing config-test loader.
No temporary file is created and no external process is started.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools._blast_radius_scheduling import (
    CONFIG_CONFLICT_TOLERANCE,
    config_conflict_tolerance,
)
from scripts.dev_tools._blast_radius_write_intent import (
    config_path_roots,
    config_write_intent_extraction,
)
from tests.scripts.dev_tools.blast_radius_parity_test_support import (
    BUNDLED_CONFIG,
    CLASS_TWO_TOLERANCE_KEY_ASSERTIONS,
    DECLARED_TOP_LEVEL_KEYS,
    unconsumed_class_keys,
)
from tests.scripts.dev_tools.test_blast_radius_config import (
    BUNDLED_CONFIG_PATH,
    CONFIG_PATH,
    load_config_file,
)

if TYPE_CHECKING:
    from pathlib import Path

# The two committed copies, labelled so each parametrized case names its file.
COPIES: tuple[tuple[str, Path], ...] = (
    ("self-hosted", CONFIG_PATH),
    ("bundled", BUNDLED_CONFIG_PATH),
)
COPY_IDS = [label for label, _ in COPIES]

# The pack-manifest registry is an append-only file that items extend with one
# entry each, so the committed tolerance scores it as append-only.
PACK_MANIFEST_REGISTRY = (
    "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json"
)

# The Copilot instructions file under .github, added to mandate_reads by Part B.
COPILOT_INSTRUCTIONS = ".github/copilot-instructions.md"

# The self-hosted path_roots value: the ordinally sorted tracked top-level
# directory list recorded at P0-T28 of the issue #722 plan.
PINNED_SELF_HOSTED_PATH_ROOTS: tuple[str, ...] = tuple(
    (
        ".agents .cache .claude .codex .devcontainer .github .vscode config docs "
        "examples extensions packages schemas scripts src tests virtual"
    ).split()
)

# The committed conflict_tolerance value (spec: required configuration keys).
COMMITTED_CONFLICT_TOLERANCE: dict[str, object] = {
    "tolerance_percent": 100,
    "weights": {"same_file": 8, "possible_overlap": 2, "append_only": 1, "module": 2},
    "band_durations": {"C1": 1, "C2": 2, "C3": 4, "C4": 8},
    "default_band": "C1",
    "append_only_paths": ["**/CHANGELOG.md", PACK_MANIFEST_REGISTRY],
}


@pytest.mark.parametrize(("label", "path"), COPIES, ids=COPY_IDS)
def test_committed_conflict_tolerance_values(label: str, path: Path) -> None:
    """Each committed copy carries the committed conflict_tolerance value."""
    config = load_config_file(path)

    member = config.get(CONFIG_CONFLICT_TOLERANCE)

    assert member == COMMITTED_CONFLICT_TOLERANCE, f"{label}: {member!r}"


@pytest.mark.parametrize(("label", "path"), COPIES, ids=COPY_IDS)
def test_committed_conflict_tolerance_reads_cleanly(label: str, path: Path) -> None:
    """The strict reader accepts each committed copy and reads the values."""
    config = load_config_file(path)

    tolerance = config_conflict_tolerance(config)

    assert tolerance.tolerance_percent == 100, label
    assert dict(tolerance.weights) == COMMITTED_CONFLICT_TOLERANCE["weights"], label
    assert dict(tolerance.band_durations) == {"C1": 1, "C2": 2, "C3": 4, "C4": 8}
    assert tolerance.default_band == "C1", label
    assert tolerance.append_only_paths == (
        "**/CHANGELOG.md",
        PACK_MANIFEST_REGISTRY,
    ), label


@pytest.mark.parametrize(("label", "path"), COPIES, ids=COPY_IDS)
def test_committed_write_intent_extraction_is_true(label: str, path: Path) -> None:
    """Each committed copy enables write-intent extraction with a real boolean."""
    config = load_config_file(path)

    enabled = config_write_intent_extraction(config)

    assert config.get("write_intent_extraction") is True, label
    assert enabled is True, label


@pytest.mark.parametrize(("label", "path"), COPIES, ids=COPY_IDS)
def test_mandate_reads_include_copilot_instructions(label: str, path: Path) -> None:
    """Each committed copy lists the Copilot instructions file as a mandate read."""
    config = load_config_file(path)

    mandate_reads = config.get("mandate_reads")

    assert isinstance(mandate_reads, list), label
    assert COPILOT_INSTRUCTIONS in mandate_reads, label


def test_self_hosted_path_roots_match_pinned_directory_list() -> None:
    """The self-hosted path_roots equals the pinned P0-T28 directory list."""
    config = load_config_file(CONFIG_PATH)

    roots = config_path_roots(config)

    assert config.get("path_roots") == list(PINNED_SELF_HOSTED_PATH_ROOTS)
    assert roots == PINNED_SELF_HOSTED_PATH_ROOTS, "list must be ordinally sorted"


def test_class_two_bundled_path_roots_are_empty() -> None:
    """The bundled copy carries path_roots as an empty list (Class 2)."""
    value = BUNDLED_CONFIG.get("path_roots")

    assert value == [], f"bundled path_roots must be an empty list, got {value!r}"
    assert config_path_roots(BUNDLED_CONFIG) == ()


def test_tolerance_registry_keys_are_consumed() -> None:
    """Every key of the path_roots Class 2 registry is consumed in this module."""
    unresolved = unconsumed_class_keys(CLASS_TWO_TOLERANCE_KEY_ASSERTIONS, globals())

    assert unresolved == (), f"unconsumed registry entries: {unresolved}"
    assert set(CLASS_TWO_TOLERANCE_KEY_ASSERTIONS) <= DECLARED_TOP_LEVEL_KEYS
