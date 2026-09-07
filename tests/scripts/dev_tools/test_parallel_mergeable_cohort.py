"""Cohort-level consequence of the ``mergeable_paths`` exclusion (issue #643).

Four items whose only shared path is one ``.csproj`` acquire no conflict edge
under the committed truth table, so the greedy coloring places every item key
in a single cohort. The three tests below establish that chain in order: no
edge for any pair, one cohort for the resulting empty edge list, and the same
verdict recorded in the shared fixture corpus that the bash lane replays.

Every input is an in-memory literal or a committed repository file; no
temporary file is created and no external process is started.
"""

from __future__ import annotations

import json
from itertools import combinations
from pathlib import Path

from scripts.dev_tools.compute_blast_radius import BlastRadius, conflicts
from scripts.dev_tools.parallel_cohort_computation import compute_cohorts

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_parallel_mergeable_cohort.py, so the repository
# root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CONFIG_PATH = REPO_ROOT / "config" / "blast-radius.json"
FIXTURE_PATH = (
    REPO_ROOT
    / "tests"
    / "fixtures"
    / "parallel_cohorts"
    / "cohorts_mergeable_only_overlaps.json"
)

# Constant rather than a clock read, so the contention verdicts are
# deterministic across runs.
COMPUTED_AT = "2026-09-07T15-00"

# The one path every item declares. It is a genuine write claim for all four
# items and stays in each declared radius; only the pairwise overlap set
# narrows.
SHARED_PROJECT_FILE = "TaskMaster.Test/TaskMaster.Test.csproj"

# One distinct private source per item, so the radii differ outside the
# mergeable path and the pair is not trivially disjoint.
ITEM_KEYS = (796, 797, 798, 799)
PRIVATE_SOURCES = {
    796: "TaskMaster.Test/AllocatorTests.cs",
    797: "TaskMaster.Test/HierarchyTests.cs",
    798: "TaskMaster.Test/TriageTests.cs",
    799: "TaskMaster.Test/GraphAdapterTests.cs",
}


def load_config() -> dict[str, object]:
    """Load the committed repository truth table.

    Returns:
        dict[str, object]: The parsed ``config/blast-radius.json`` mapping,
        which carries the published five-entry ``mergeable_paths`` default.
    """
    return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))


def radius_for(item_key: int) -> BlastRadius:
    """Build the declared radius of one item.

    Args:
        item_key (int): Item key whose private source is looked up.

    Returns:
        BlastRadius: A radius listing the shared project file and that item's
        private source, with empty modules, surfaces, and contracts so the
        verdict is decided at the path level alone.
    """
    return BlastRadius(
        paths=(SHARED_PROJECT_FILE, PRIVATE_SOURCES[item_key]),
        modules=(),
        shared_surfaces=(),
        contracts=(),
        source="declared",
        computed_at=COMPUTED_AT,
    )


def test_csproj_only_overlaps_yield_no_edge_for_any_pair() -> None:
    """All six unordered pairs are non-conflicting under the committed table."""
    config = load_config()
    pairs = list(combinations(ITEM_KEYS, 2))
    assert len(pairs) == 6

    for left, right in pairs:
        result = conflicts(radius_for(left), radius_for(right), config)
        assert result.conflict is False, (
            f"pair ({left}, {right}) conflicted on a .csproj-only overlap: "
            f"{result.reasons}"
        )
        assert SHARED_PROJECT_FILE in radius_for(left).paths
        assert SHARED_PROJECT_FILE in radius_for(right).paths


def test_csproj_only_overlaps_place_every_item_in_a_single_cohort() -> None:
    """The empty edge list the first test justifies colors into one cohort."""
    cohorts = compute_cohorts(list(ITEM_KEYS), [])

    assert cohorts == [[796, 797, 798, 799]]


def test_cohort_fixture_for_mergeable_only_overlaps_exists_in_the_shared_corpus() -> (
    None
):
    """The shared corpus records the same verdict for the bash lane to replay."""
    document = json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))

    assert document["name"] == "cohorts_mergeable_only_overlaps"
    assert document["input"]["item_keys"] == list(ITEM_KEYS)
    assert document["input"]["conflict_edges"] == []
    assert document["expected_cohorts"] == compute_cohorts(list(ITEM_KEYS), [])
