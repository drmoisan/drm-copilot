"""Committed values of the issue #722 truth-table keys in both config copies.

Part A pins the ``conflict_tolerance`` key: both committed copies of the
blast-radius truth table carry the committed values of the spec, and the strict
reader of ``scripts/dev_tools/_blast_radius_scheduling.py`` accepts each copy.
Byte-equality between the copies is asserted by the config-parity module
through the byte-equal key tuple; this module pins the values themselves.

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
