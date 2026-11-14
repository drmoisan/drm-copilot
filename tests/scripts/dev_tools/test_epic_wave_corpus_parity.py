"""Python reference lane over the shared epic wave-computation corpus.

Purpose:
    `tests/fixtures/epic_wave/wave-computation-cases.json` is read by this lane
    and by the Pester lane `EpicWave.Parity.Tests.ps1` under
    `tests/scripts/claude-lib/epic-wave/`,
    so the Python reference and the shipped PowerShell implementation agree.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import pytest

from scripts.dev_tools.epic_wave_computation import (
    EpicWaveCycleError,
    EpicWaveUnresolvedReferenceError,
    compute_wave_numbers,
)

CORPUS_PATH = (
    Path(__file__).resolve().parents[2]
    / "fixtures/epic_wave/wave-computation-cases.json"
)
CASES: list[dict[str, Any]] = json.loads(CORPUS_PATH.read_text(encoding="utf-8"))[
    "cases"
]
EXPECTED_ERRORS: dict[str, type[ValueError]] = {
    "cycle": EpicWaveCycleError,
    "self_loop": EpicWaveCycleError,
    "unresolved": EpicWaveUnresolvedReferenceError,
}


def test_corpus_holds_every_required_case() -> None:
    """Guard against an emptied corpus that would make the lane vacuous."""

    assert {case["name"] for case in CASES} >= {
        "empty",
        "single",
        "chain",
        "diamond",
        "case-variant-keys",
        "multiple-roots",
        "two-node-cycle",
        "self-loop",
        "unresolved-reference",
    }


@pytest.mark.parametrize("case", CASES, ids=[case["name"] for case in CASES])
def test_corpus_case_matches_reference(case: dict[str, Any]) -> None:
    """Match each corpus case against the Python reference implementation."""

    manifest = case["manifest"]

    if "expected_error" in case:
        with pytest.raises(EXPECTED_ERRORS[case["expected_error"]]):
            compute_wave_numbers(manifest)
        return

    assert compute_wave_numbers(manifest) == case["expected_waves"]


def test_unresolved_reference_error_names_feature_and_dependency() -> None:
    """Expose the feature folder and missing dependency on the new exception."""

    with pytest.raises(EpicWaveUnresolvedReferenceError) as excinfo:
        compute_wave_numbers({"a": ["missing"]})

    assert excinfo.value.feature_folder == "a"
    assert excinfo.value.dependency == "missing"
    assert "'missing'" in str(excinfo.value)
    assert str(excinfo.value).startswith(
        "Epic dependency manifest references unresolved feature folder"
    )
