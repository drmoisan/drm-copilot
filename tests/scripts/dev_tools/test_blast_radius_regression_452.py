"""Regression corpus consumer for the issue #452 under-reporting corrections.

Pins gap 1 (separator-free root surfaces reachable from plan text) and gap 2
(a listed directory contends with a glob beneath it), in both directions,
against the corpus shared with ``BlastRadius.Regression452.Tests.ps1``. Every
verdict is asserted on the ``conflicts`` result only, so the corpus holds
whichever of #452 and #722 merges first. Files are located relative to this
file; no temporary file is created and no external process is started.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._blast_radius_validation import config_root_surfaces
from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    conflicts,
    derive_blast_radius,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_blast_radius_regression_452.py, so the repository
# root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests" / "fixtures" / "blast_radius" / "regression-452"
CORPUS_PATH = CORPUS_DIR / "under-reporting-corpus.json"
SELF_HOSTED_CONFIG_PATH = REPO_ROOT / "config" / "blast-radius.json"
RESOURCES_DIR = REPO_ROOT / "extensions" / "drm-copilot" / "resources"
BUNDLED_CONFIG_DIR = RESOURCES_DIR / "claude-customizations" / "config"
BUNDLED_CONFIG_PATH = BUNDLED_CONFIG_DIR / "blast-radius.json"

# The spec's Case List, in its source order. The corpus must carry exactly these.
EXPECTED_CASE_IDS: tuple[str, ...] = (
    "g1-plan-poetry-lock",
    "g1-plan-package-lock",
    "g1-plan-different-surfaces",
    "g1-plan-unconfigured-root-file",
    "g1-plan-quality-tiers-mandate-read",
    "g1-radius-quality-tiers",
    "g1-radius-quality-tiers-vs-poetry-lock",
    "g2-dir-vs-glob",
    "g2-glob-vs-dir",
    "g2-dir-vs-sibling-glob",
    "g2-sibling-glob-vs-dir",
    "g2-artifacts-dir-vs-glob",
    "g2-artifacts-glob-vs-dir",
    "g2-artifacts-dir-vs-sibling-glob",
    "g2-artifacts-sibling-glob-vs-dir",
    "g2-empty-modules-dir-vs-glob",
    "g2-empty-modules-dir-vs-sibling-glob",
)

MUST_CONFLICT = "must-conflict"
MUST_NOT_CONFLICT = "must-not-conflict"
KIND_RADIUS_PAIR = "radius_pair"
KIND_PLAN_PAIR = "plan_pair"
SELF_HOSTED_REF = "self_hosted"
RADIUS_KEYS = frozenset(
    {"paths", "modules", "shared_surfaces", "contracts", "source", "computed_at"}
)
PLAN_INPUT_KEYS = frozenset(
    {"plan_a", "plan_b", "feature_folder_a", "feature_folder_b", "computed_at"}
)
REQUIRED_CASE_KEYS = frozenset(
    {"id", "gap", "kind", "direction", "paired_case_id", "input", "expected"}
)
OPTIONAL_CASE_KEYS = frozenset({"doctrine_pin", "config_ref", "config"})
KEBAB_CASE_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
COMPUTED_AT_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$")
BACKTICK = chr(96)
TOLERANCE_SKIP_REASON = (
    "Issue #722 tolerance layer absent at execution start (Phase 0 detection "
    "NOT FOUND); detection-level verdicts for every must-conflict case are "
    "recorded as evidence instead."
)


def require_mapping(value: object, label: str) -> Mapping[str, object]:
    """Guard a corpus value that must be a JSON object.

    Args:
        value (object): Value read from the parsed corpus or a truth table.
        label (str): Location label used in the failure message.

    Returns:
        Mapping[str, object]: The validated mapping.

    Raises:
        TypeError: If the value is not a JSON object.
    """
    if not isinstance(value, dict):
        raise TypeError(f"{label} must be a JSON object, got {type(value).__name__}.")
    return cast("Mapping[str, object]", value)


def require_list(value: object, label: str) -> list[object]:
    """Guard a corpus value that must be a JSON array.

    Args:
        value (object): Value read from the parsed corpus.
        label (str): Location label used in the failure message.

    Returns:
        list[object]: The validated list, entries not yet narrowed.

    Raises:
        TypeError: If the value is not a JSON array.
    """
    if not isinstance(value, list):
        raise TypeError(f"{label} must be a JSON array, got {type(value).__name__}.")
    return cast("list[object]", value)


def require_text(value: object, label: str) -> str:
    """Guard a corpus value that must be a JSON string.

    Args:
        value (object): Value read from the parsed corpus.
        label (str): Location label used in the failure message.

    Returns:
        str: The validated string.

    Raises:
        TypeError: If the value is not a string.
    """
    if not isinstance(value, str):
        raise TypeError(f"{label} must be a string, got {type(value).__name__}.")
    return value


def load_json_object(path: Path) -> Mapping[str, object]:
    """Read and parse one committed JSON file that must hold an object.

    Args:
        path (Path): Path of the committed file, resolved from ``REPO_ROOT``.

    Returns:
        Mapping[str, object]: The parsed top-level object.

    Raises:
        TypeError: If the file does not parse to a JSON object.

    Side Effects:
        Reads the committed file; nothing is written.
    """
    parsed = cast("object", json.loads(path.read_text(encoding="utf-8")))
    return require_mapping(parsed, path.name)


CORPUS = load_json_object(CORPUS_PATH)
# Narrow every case once at import so a malformed case fails naming its index.
CASES: tuple[Mapping[str, object], ...] = tuple(
    require_mapping(entry, f"corpus.cases[{index}]")
    for index, entry in enumerate(require_list(CORPUS.get("cases"), "corpus.cases"))
)
CASE_IDS: list[str] = [require_text(case.get("id"), "case.id") for case in CASES]
SELF_HOSTED_CONFIG = load_json_object(SELF_HOSTED_CONFIG_PATH)
BUNDLED_CONFIG = load_json_object(BUNDLED_CONFIG_PATH)


def cases_by_id() -> dict[str, Mapping[str, object]]:
    """Index the corpus cases by id.

    Returns:
        dict[str, Mapping[str, object]]: Each case keyed by its ``id``.
    """
    return {require_text(case.get("id"), "case.id"): case for case in CASES}


def expected_conflict(case: Mapping[str, object]) -> bool:
    """Read the expected verdict of one case.

    Args:
        case (Mapping[str, object]): One corpus case.

    Returns:
        bool: The ``expected.conflict`` value.

    Raises:
        TypeError: If the expected block or its verdict has the wrong type.
    """
    expected = require_mapping(case.get("expected"), "case.expected")
    verdict = expected.get("conflict")
    if not isinstance(verdict, bool):
        raise TypeError("case.expected.conflict must be a boolean.")
    return verdict


def expected_reasons(case: Mapping[str, object]) -> list[tuple[str, str]]:
    """Read the ordered expected reasons of one case as (kind, detail) pairs.

    Args:
        case (Mapping[str, object]): One corpus case.

    Returns:
        list[tuple[str, str]]: The reasons in corpus order.

    Raises:
        TypeError: If a reason entry is not an object of two strings.
    """
    expected = require_mapping(case.get("expected"), "case.expected")
    pairs: list[tuple[str, str]] = []
    # Convert each reason object to a comparable pair, preserving corpus order.
    for entry in require_list(expected.get("reasons"), "case.expected.reasons"):
        reason = require_mapping(entry, "case.expected.reasons[]")
        kind = require_text(reason.get("kind"), "reason.kind")
        pairs.append((kind, require_text(reason.get("detail"), "reason.detail")))
    return pairs


def plan_lines(case: Mapping[str, object]) -> tuple[str, str]:
    """Return the two plan texts of a plan_pair case.

    Args:
        case (Mapping[str, object]): One plan_pair corpus case.

    Returns:
        tuple[str, str]: ``plan_a`` and ``plan_b``.
    """
    data = require_mapping(case.get("input"), "case.input")
    return (
        require_text(data.get("plan_a"), "input.plan_a"),
        require_text(data.get("plan_b"), "input.plan_b"),
    )


def build_radii(case: Mapping[str, object]) -> tuple[BlastRadius, BlastRadius]:
    """Build the two radii a case compares.

    A radius_pair case deserializes both declared radii. A plan_pair case derives
    each radius from its plan text (spec text empty) under the self-hosted truth
    table, exactly as a planner would.

    Args:
        case (Mapping[str, object]): One corpus case.

    Returns:
        tuple[BlastRadius, BlastRadius]: Radius A and radius B.
    """
    data = require_mapping(case.get("input"), "case.input")
    # Route on kind: declared radii are deserialized, plan radii are derived.
    if case.get("kind") == KIND_RADIUS_PAIR:
        return (
            BlastRadius.from_dict(require_mapping(data.get("radius_a"), "radius_a")),
            BlastRadius.from_dict(require_mapping(data.get("radius_b"), "radius_b")),
        )
    stamp = require_text(data.get("computed_at"), "input.computed_at")
    folder_a = require_text(data.get("feature_folder_a"), "input.feature_folder_a")
    folder_b = require_text(data.get("feature_folder_b"), "input.feature_folder_b")
    plan_a, plan_b = plan_lines(case)
    config = SELF_HOSTED_CONFIG
    return (
        derive_blast_radius(plan_a, "", folder_a, config, computed_at=stamp),
        derive_blast_radius(plan_b, "", folder_b, config, computed_at=stamp),
    )


def contention_config(case: Mapping[str, object]) -> Mapping[str, object]:
    """Select the truth table the contention relation receives for one case.

    Args:
        case (Mapping[str, object]): One corpus case.

    Returns:
        Mapping[str, object]: The self-hosted table for a ``config_ref`` case,
        otherwise the case's inline ``config``.
    """
    # A referenced table always names the self-hosted copy; inline tables are
    # passed through unchanged so the case controls every key the relation reads.
    if "config_ref" in case:
        return SELF_HOSTED_CONFIG
    return require_mapping(case.get("config"), "case.config")


def test_corpus_top_level_shape_matches_the_contract() -> None:
    """The corpus declares schema 1, issue 452, a description, and cases."""
    # Arrange / Act: the corpus was parsed at import.
    description = CORPUS.get("description")

    # Assert: each top-level field has the contracted value or shape.
    assert CORPUS.get("schema_version") == 1, "schema_version must be 1."
    assert CORPUS.get("issue") == 452, "issue must be 452."
    assert isinstance(description, str), "description must be a string."
    assert description.strip(), "description must not be empty."
    assert CASES, "cases must be a non-empty list."


def assert_case_shape(case: Mapping[str, object]) -> None:
    """Assert one case against the Case shape table of the corpus contract.

    Args:
        case (Mapping[str, object]): One corpus case.

    Raises:
        AssertionError: If any field is missing, extra, or out of range.
    """
    case_id = require_text(case.get("id"), "case.id")
    keys = set(case)
    assert REQUIRED_CASE_KEYS <= keys, f"{case_id} is missing a required field."
    assert keys <= REQUIRED_CASE_KEYS | OPTIONAL_CASE_KEYS, f"{case_id} has extras."
    assert KEBAB_CASE_RE.fullmatch(case_id), f"{case_id} is not kebab-case."
    gap = case.get("gap")
    assert type(gap) is int and gap in (1, 2), f"{case_id} gap must be 1 or 2."
    kind = case.get("kind")
    assert kind in (KIND_RADIUS_PAIR, KIND_PLAN_PAIR), f"{case_id} kind invalid."
    direction = case.get("direction")
    assert direction in (MUST_CONFLICT, MUST_NOT_CONFLICT), f"{case_id} direction."
    assert isinstance(case.get("paired_case_id"), str), f"{case_id} paired id."
    assert ("config_ref" in case) != ("config" in case), f"{case_id} config choice."
    # Exactly one table source is present; validate whichever one it is.
    if "config_ref" in case:
        assert case.get("config_ref") == SELF_HOSTED_REF, f"{case_id} config_ref."
    else:
        require_mapping(case.get("config"), f"{case_id}.config")
    # A doctrine pin records designed non-conflict, so it cannot be a positive.
    if "doctrine_pin" in case:
        assert isinstance(case.get("doctrine_pin"), bool), f"{case_id} doctrine_pin."
        if case.get("doctrine_pin") is True:
            assert direction == MUST_NOT_CONFLICT, f"{case_id} pin must be negative."
    assert_input_shape(case_id, kind, require_mapping(case.get("input"), case_id))
    expected = require_mapping(case.get("expected"), f"{case_id}.expected")
    assert set(expected) == {"conflict", "reasons"}, f"{case_id} expected keys."
    expected_conflict(case)
    expected_reasons(case)


def assert_input_shape(case_id: str, kind: object, data: Mapping[str, object]) -> None:
    """Assert the input block of one case against its kind.

    Args:
        case_id (str): Case id, used in failure messages.
        kind (object): The case's ``kind`` value.
        data (Mapping[str, object]): The case's ``input`` block.

    Raises:
        AssertionError: If the block does not carry the contracted keys.
    """
    # radius_pair carries two six-key radii; plan_pair carries plan text inputs.
    if kind == KIND_RADIUS_PAIR:
        assert set(data) == {"radius_a", "radius_b"}, f"{case_id} radius inputs."
        # Each radius must carry exactly the six radius keys.
        for side in ("radius_a", "radius_b"):
            radius = require_mapping(data.get(side), f"{case_id}.{side}")
            assert set(radius) == RADIUS_KEYS, f"{case_id} {side} key set."
            stamp = require_text(radius.get("computed_at"), f"{case_id}.{side}")
            assert COMPUTED_AT_RE.fullmatch(stamp), f"{case_id} {side} computed_at."
    else:
        assert set(data) == PLAN_INPUT_KEYS, f"{case_id} plan inputs."
        stamp = require_text(data.get("computed_at"), f"{case_id}.computed_at")
        assert COMPUTED_AT_RE.fullmatch(stamp), f"{case_id} computed_at shape."


def test_every_case_matches_the_case_shape_contract() -> None:
    """Every case carries the contracted fields with valid types and values."""
    # Arrange / Act / Assert: validate each case independently.
    for case in CASES:
        assert_case_shape(case)


def test_corpus_case_ids_are_unique_and_equal_the_spec_case_list() -> None:
    """The corpus carries every Case List id exactly once and no other id."""
    # Arrange / Act: the ids were read at import.
    # Assert: duplicates and set differences are both rejected.
    assert len(CASE_IDS) == len(set(CASE_IDS)), f"Duplicate ids in {CASE_IDS}."
    assert set(CASE_IDS) == set(EXPECTED_CASE_IDS), (
        f"Corpus ids differ from the Case List: "
        f"missing {sorted(set(EXPECTED_CASE_IDS) - set(CASE_IDS))}, "
        f"extra {sorted(set(CASE_IDS) - set(EXPECTED_CASE_IDS))}."
    )


def test_every_expected_verdict_matches_its_direction() -> None:
    """A must-conflict case expects a conflict and a control expects none."""
    # Check each case's expected block against its declared direction.
    for case in CASES:
        case_id = require_text(case.get("id"), "case.id")
        positive = case.get("direction") == MUST_CONFLICT
        assert expected_conflict(case) is positive, f"{case_id} verdict/direction."
        assert bool(expected_reasons(case)) is positive, f"{case_id} reasons."


def test_every_pairing_resolves_to_an_opposite_direction_case_of_the_same_gap() -> None:
    """Pairings resolve, cross directions within a gap, and reciprocate."""
    # Arrange: index the corpus so each paired id can be resolved.
    index = cases_by_id()
    unreciprocated: set[str] = set()

    # Act / Assert: resolve every pairing and record non-reciprocal controls.
    for case_id, case in index.items():
        partner_id = require_text(case.get("paired_case_id"), f"{case_id}.paired")
        assert partner_id in index, f"{case_id} names unknown case {partner_id}."
        partner = index[partner_id]
        assert partner.get("direction") != case.get("direction"), f"{case_id} dir."
        assert partner.get("gap") == case.get("gap"), f"{case_id} gap differs."
        reciprocal = partner.get("paired_case_id") == case_id
        # A positive must always be named back by its control.
        if case.get("direction") == MUST_CONFLICT:
            assert reciprocal, f"{case_id} is not named back by {partner_id}."
        elif not reciprocal:
            unreciprocated.add(case_id)

    # Assert: only doctrine pins may bound a positive without being its control.
    pins = {cid for cid, case in index.items() if case.get("doctrine_pin") is True}
    assert pins, "The corpus declares no doctrine-pin case."
    assert unreciprocated == pins, f"Non-reciprocal controls {unreciprocated}."


def test_each_gap_has_a_must_conflict_and_a_must_not_conflict_case() -> None:
    """Both gaps are pinned in both directions."""
    # Arrange / Act: collect the (gap, direction) combinations present.
    present = {(case.get("gap"), case.get("direction")) for case in CASES}

    # Assert: every combination of the two gaps and two directions appears.
    for gap in (1, 2):
        for direction in (MUST_CONFLICT, MUST_NOT_CONFLICT):
            assert (gap, direction) in present, f"gap {gap} lacks {direction}."


def test_every_plan_line_follows_the_plan_line_intent_rule() -> None:
    """Plan lines use a write verb, except the doctrine pin, which uses Read."""
    # Arrange: build the task-line pattern with the backtick from its code point.
    tick = BACKTICK
    write_line = re.compile(
        rf"^- \[ \] \[P\d+-T\d+\] (?:Edit|Create) {tick}[^{tick}]+{tick}\.$"
    )
    read_line = re.compile(rf"^- \[ \] \[P\d+-T\d+\] Read {tick}[^{tick}]+{tick}\.$")
    plan_cases = [case for case in CASES if case.get("kind") == KIND_PLAN_PAIR]
    assert plan_cases, "The corpus declares no plan_pair case."

    # Act / Assert: each side of each plan case is one line of the right shape.
    for case in plan_cases:
        case_id = require_text(case.get("id"), "case.id")
        pattern = read_line if case.get("doctrine_pin") is True else write_line
        for line in plan_lines(case):
            assert "\n" not in line, f"{case_id} plan text spans lines."
            assert pattern.fullmatch(line), f"{case_id} plan line {line!s} invalid."


@pytest.mark.parametrize("case", CASES, ids=CASE_IDS)
def test_case_verdict_matches_corpus(case: Mapping[str, object]) -> None:
    """The contention relation reproduces the corpus verdict and reasons."""
    # Arrange: the two radii and the truth table the relation receives.
    case_id = require_text(case.get("id"), "case.id")
    radius_a, radius_b = build_radii(case)
    config = contention_config(case)

    # Act: evaluate contention between the two radii.
    result = conflicts(radius_a, radius_b, config)

    # Assert: the verdict first, then the exact ordered reasons.
    assert result.conflict is expected_conflict(case), (
        f"{case_id} produced conflict={result.conflict}, expected "
        f"conflict={expected_conflict(case)}."
    )
    actual = [(reason.kind, reason.detail) for reason in result.reasons]
    assert actual == expected_reasons(case), (
        f"Case {case_id} produced reasons {actual}, expected "
        f"{expected_reasons(case)}."
    )


def test_bundled_separator_free_shared_surfaces_equal_the_self_hosted_subset() -> None:
    """The bundled and self-hosted tables admit the same root surfaces."""
    # Arrange / Act: compute both subsets from the committed tables.
    self_hosted = set(config_root_surfaces(SELF_HOSTED_CONFIG))
    bundled = set(config_root_surfaces(BUNDLED_CONFIG))

    # Assert: the sets are non-empty and equal.
    assert self_hosted, "The self-hosted table declares no root surface."
    assert bundled == self_hosted, f"Bundled {bundled} != self-hosted {self_hosted}."


@pytest.mark.skip(reason=TOLERANCE_SKIP_REASON)
def test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case() -> (
    None
):
    """Reserved for the #722 tolerance layer, absent at execution start."""
