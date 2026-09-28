"""Validator tolerance for the optional ``mergeable_conflicts_resolved`` field.

Issue #643 declares an additive, tolerated-not-validated item field in
``.claude/rules/parallel-orchestration.md``. No validator reads it, so a
checkpoint carrying it in the documented shape and a checkpoint omitting it
must both validate cleanly. The builder and accessors are shared with
``test_validate_parallel_orchestrator_state.py`` rather than duplicated.
"""

from __future__ import annotations

from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_valid_parallel_state,
    item_at,
    validate,
)

# Forty-character lowercase hex, the shape the checkpoint uses for a commit
# identifier. Literals rather than generated values, so the case is
# deterministic.
MERGED_AGAINST = "a1b2c3d4e5f60718293a4b5c6d7e8f9012345678"
MERGE_COMMIT_SHA = "0fedcba987654321fedcba9876543210fedcba98"

MERGEABLE_CONFLICT_RECORD = {
    "path": "TaskMaster.Test/TaskMaster.Test.csproj",
    "resolved_at": "2026-09-07T10-15",
    "merged_against": MERGED_AGAINST,
    "merge_commit_sha": MERGE_COMMIT_SHA,
    "entries_added_from_ours": ["Compile:Foo.cs"],
    "entries_added_from_theirs": ["Compile:Bar.cs"],
    "version_resolutions": [
        {
            "key": "package:Newtonsoft.Json",
            "ours": "13.0.1",
            "theirs": "13.0.3",
            "chosen": "13.0.3",
        }
    ],
}


def test_item_carrying_mergeable_conflicts_resolved_yields_no_errors() -> None:
    """The documented record shape is tolerated on an item entry."""

    state = build_valid_parallel_state()
    item_at(state, 0)["mergeable_conflicts_resolved"] = [
        dict(MERGEABLE_CONFLICT_RECORD)
    ]

    assert validate(state) == []


def test_item_omitting_mergeable_conflicts_resolved_yields_no_errors() -> None:
    """Omitting the optional field leaves the checkpoint valid."""

    state = build_valid_parallel_state()

    assert "mergeable_conflicts_resolved" not in item_at(state, 0)
    assert validate(state) == []
