"""Reader tests for ``conflict_tolerance.combination_threshold_percent``.

Issue #1013, spec D-6: the member is optional; when present it must be a
non-boolean integer of at least 0, read under the label
``config["conflict_tolerance"]["combination_threshold_percent"]``; when absent
inside a present key it defaults to ``COMBINATION_THRESHOLD_DEFAULT`` (400); and
any other unknown member name is still rejected. Both committed truth tables
carry the value 400.

``COMBINATION_THRESHOLD_DEFAULT`` is imported inside each test that uses it,
so the module collects before the implementation exists. Configs are built in
memory and carry the five weight names. No test creates a file or starts a
process.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools._blast_radius_scheduling import config_conflict_tolerance

REPO_ROOT = Path(__file__).resolve().parents[3]
COMMITTED_COPIES: tuple[Path, ...] = (
    REPO_ROOT / "config" / "blast-radius.json",
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "claude-customizations"
    / "config"
    / "blast-radius.json",
)
COPY_IDS = ("repository", "bundled")
KEY_NAME = "combination_threshold_percent"


def tolerance_member(**extra: object) -> dict[str, object]:
    """Return a valid conflict_tolerance member with the five weight names."""
    member: dict[str, object] = {
        "tolerance_percent": 100,
        "weights": {
            "same_file": 8,
            "possible_overlap": 2,
            "append_only": 1,
            "module": 2,
            "contract": 8,
        },
        "band_durations": {"C1": 1, "C2": 2, "C3": 4, "C4": 8},
        "default_band": "C1",
        "append_only_paths": ["**/CHANGELOG.md"],
    }
    member.update(extra)
    return member


def make_config(member: dict[str, object]) -> dict[str, object]:
    """Wrap a conflict_tolerance member in a minimal truth table."""
    return {"version": 1, "mergeable_paths": [], "conflict_tolerance": member}


@pytest.mark.parametrize("value", [0, 250], ids=["zero", "two-fifty"])
def test_reader_accepts_a_non_negative_integer(value: int) -> None:
    """0 and 250 are read verbatim."""
    config = make_config(tolerance_member(combination_threshold_percent=value))

    tolerance = config_conflict_tolerance(config)

    assert tolerance.combination_threshold_percent == value


def test_reader_defaults_an_absent_member_to_the_constant() -> None:
    """An absent member inside a present key reads as the default, 400."""
    from scripts.dev_tools._blast_radius_scheduling import (
        COMBINATION_THRESHOLD_DEFAULT,
    )

    tolerance = config_conflict_tolerance(make_config(tolerance_member()))

    assert COMBINATION_THRESHOLD_DEFAULT == 400
    assert tolerance.combination_threshold_percent == COMBINATION_THRESHOLD_DEFAULT


def test_strict_reading_carries_the_default() -> None:
    """The absent-key reading also carries the default threshold."""
    from scripts.dev_tools._blast_radius_scheduling import (
        COMBINATION_THRESHOLD_DEFAULT,
        STRICT_CONFLICT_TOLERANCE,
    )

    tolerance = config_conflict_tolerance({"version": 1})

    assert tolerance is STRICT_CONFLICT_TOLERANCE
    assert tolerance.combination_threshold_percent == COMBINATION_THRESHOLD_DEFAULT


@pytest.mark.parametrize(
    "value",
    [-1, 2.5, "400", True, False],
    ids=["negative", "float", "string", "true", "false"],
)
def test_reader_rejects_an_invalid_value(value: object) -> None:
    """A negative, float, string, or boolean value fails fast naming the key."""
    config = make_config(tolerance_member(combination_threshold_percent=value))

    with pytest.raises((TypeError, ValueError), match=KEY_NAME):
        config_conflict_tolerance(config)


def test_reader_rejects_a_negative_value_with_the_full_label() -> None:
    """The ValueError for a negative value carries the full member label."""
    config = make_config(tolerance_member(combination_threshold_percent=-1))

    with pytest.raises(ValueError, match=r'\["combination_threshold_percent"\]'):
        config_conflict_tolerance(config)


@pytest.mark.parametrize(
    "value", [2.5, "400", True], ids=["float", "string", "boolean"]
)
def test_reader_rejects_a_non_integer_with_a_type_error(value: object) -> None:
    """A non-integer or boolean value raises TypeError carrying the label."""
    config = make_config(tolerance_member(combination_threshold_percent=value))

    with pytest.raises(TypeError, match=r'\["combination_threshold_percent"\]'):
        config_conflict_tolerance(config)


def test_reader_still_rejects_an_unknown_sibling_name() -> None:
    """Accepting the optional member does not admit any other unknown name."""
    config = make_config(
        tolerance_member(combination_threshold_percent=400, combination_cap=1)
    )

    with pytest.raises(ValueError, match="combination_cap"):
        config_conflict_tolerance(config)


@pytest.mark.parametrize("path", COMMITTED_COPIES, ids=COPY_IDS)
def test_committed_tables_carry_the_threshold_400(path: Path) -> None:
    """Both committed truth tables carry combination_threshold_percent 400."""
    config = cast("dict[str, object]", json.loads(path.read_text(encoding="utf-8")))
    member = cast("dict[str, object]", config["conflict_tolerance"])

    tolerance = config_conflict_tolerance(config)

    assert member.get(KEY_NAME) == 400, path.name
    assert list(member)[-1] == KEY_NAME, path.name
    assert tolerance.combination_threshold_percent == 400, path.name
