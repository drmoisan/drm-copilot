"""Python side of the push-down exclusion parity corpus.

The committed corpus under ``tests/fixtures/push_down_exclusions/`` is read by
this module and by
``extensions/drm-copilot/test/lib/push-down/claude-exclusion-parity.test.ts``;
both implementations must produce the pinned matcher results, parsed entries,
exclusion plans, and rendered lines.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TypedDict, cast

import pytest

from scripts.dev_tools.push_down_claude_exclusion_filter import (
    build_exclusion_report,
    render_exclusion_lines,
)
from scripts.dev_tools.push_down_exclusion_manifest import (
    EXCLUSION_MANIFEST_RELATIVE_PATH,
    ExclusionManifestError,
    matches_exclusion_entry,
    parse_exclusion_manifest,
    plan_exclusions,
)

_REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = _REPO_ROOT / "tests" / "fixtures" / "push_down_exclusions"
CORPUS_FILES = ("matcher-corpus.json", "manifest-corpus.json", "plan-corpus.json")


class MatcherCase(TypedDict):
    """One matcher-corpus case."""

    id: str
    entry: str
    candidate: str
    expected: bool


class ExpectedEntry(TypedDict):
    """One expected parsed entry in the manifest corpus."""

    normalized: str
    kind: str
    line: int


class ManifestCase(TypedDict, total=False):
    """One manifest-corpus case; exactly one expectation key is present."""

    id: str
    text: str
    expected_entries: list[ExpectedEntry]
    expected_error_line: int


class SkippedRecord(TypedDict):
    """One expected skip record in the plan corpus."""

    relative_path: str
    entry: str
    line: int
    destination_status: str


class PlanCase(TypedDict):
    """One plan-corpus case."""

    id: str
    manifest_text: str
    payload_paths: list[str]
    destination_present: list[str]
    expected_kept: list[str]
    expected_skipped: list[SkippedRecord]
    expected_unmatched_entries: list[str]
    expected_lines: list[str]


def _load(name: str) -> dict[str, object]:
    """Load one corpus file as a JSON object."""

    text = (CORPUS_DIR / name).read_text(encoding="utf-8")
    return cast("dict[str, object]", json.loads(text))


MATCHER_CASES = cast("list[MatcherCase]", _load("matcher-corpus.json")["cases"])
MANIFEST_CASES = cast("list[ManifestCase]", _load("manifest-corpus.json")["cases"])
PLAN_CASES = cast("list[PlanCase]", _load("plan-corpus.json")["cases"])


def test_corpus_files_declare_the_manifest_relative_path() -> None:
    """Every corpus file names the manifest path both implementations declare."""

    for name in CORPUS_FILES:
        assert (
            _load(name)["manifest_relative_path"] == EXCLUSION_MANIFEST_RELATIVE_PATH
        ), name


def test_matcher_corpus_has_18_cases() -> None:
    """The matcher corpus pins exactly 18 cases."""

    assert len(MATCHER_CASES) == 18


@pytest.mark.parametrize("case", MATCHER_CASES, ids=[c["id"] for c in MATCHER_CASES])
def test_matcher_corpus_case(case: MatcherCase) -> None:
    """A one-line manifest of ``entry`` matches ``candidate`` as pinned."""

    manifest = parse_exclusion_manifest(
        case["entry"] + "\n", EXCLUSION_MANIFEST_RELATIVE_PATH
    )

    assert len(manifest.entries) == 1
    assert (
        matches_exclusion_entry(manifest.entries[0], case["candidate"])
        is case["expected"]
    )


def test_manifest_corpus_has_14_cases() -> None:
    """The manifest corpus pins exactly 14 cases."""

    assert len(MANIFEST_CASES) == 14


@pytest.mark.parametrize(
    "case", MANIFEST_CASES, ids=[c.get("id", "") for c in MANIFEST_CASES]
)
def test_manifest_corpus_case(case: ManifestCase) -> None:
    """Parsing yields the pinned entries or fails on the pinned line."""

    text = case.get("text", "")
    if "expected_error_line" in case:
        with pytest.raises(ExclusionManifestError) as captured:
            parse_exclusion_manifest(text, EXCLUSION_MANIFEST_RELATIVE_PATH)
        assert captured.value.line == case.get("expected_error_line")
        return

    manifest = parse_exclusion_manifest(text, EXCLUSION_MANIFEST_RELATIVE_PATH)

    expected = [
        (item["normalized"], item["kind"], item["line"])
        for item in case.get("expected_entries", [])
    ]
    assert [(e.normalized, e.kind, e.line) for e in manifest.entries] == expected


def test_plan_corpus_has_9_cases() -> None:
    """The plan corpus pins exactly 9 cases."""

    assert len(PLAN_CASES) == 9


@pytest.mark.parametrize("case", PLAN_CASES, ids=[c["id"] for c in PLAN_CASES])
def test_plan_corpus_case(case: PlanCase) -> None:
    """The plan, its report, and the rendered lines match the pinned values."""

    manifest = parse_exclusion_manifest(
        case["manifest_text"], EXCLUSION_MANIFEST_RELATIVE_PATH
    )
    present = set(case["destination_present"])

    plan = plan_exclusions(case["payload_paths"], manifest, present.__contains__)

    assert list(plan.kept) == case["expected_kept"]
    assert [
        (s.relative_path, s.entry, s.line, s.destination_status) for s in plan.skipped
    ] == [
        (s["relative_path"], s["entry"], s["line"], s["destination_status"])
        for s in case["expected_skipped"]
    ]
    assert [e.normalized for e in plan.unmatched_entries] == case[
        "expected_unmatched_entries"
    ]
    report = build_exclusion_report(manifest, plan.skipped)
    assert render_exclusion_lines(report) == case["expected_lines"]
