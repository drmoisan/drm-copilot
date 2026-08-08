"""Pinned expectation data for the parallel-orchestrator surface contract tests.

Purpose:
    Hold the heading sequences, required text fragments, and pinned content
    digests that ``test_parallel_orchestrator_surface_contracts.py`` asserts
    against. Splitting the data out of the test module keeps every file this
    feature adds inside the repository 500-line limit while leaving all
    assertions in the single test module the plan names.

Usage:
    Imported as
    ``tests.scripts.dev_tools.parallel_orchestrator_surface_expectations``.
    Every member is inert data; the module performs no I/O and defines no
    behavior.

Invariants and constraints:
    A fragment tuple pins one acceptance criterion per member, so a failure
    names the specific obligation that is missing. Fragments are matched against
    whitespace-collapsed section text, so a fragment may be written here as
    adjacent string literals without regard for the delivered file's wrapping.
    The prescribed ``parallel-status.md`` names are deliberately NOT pinned here:
    the seam tests parse them from the producer skill at run time so that a
    producer/consumer divergence cannot pass.
"""

from __future__ import annotations

from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    BOUNDARIES_HEADING,
    KICKOFF_HEADING,
)

# Section headings the tests extract by boundary before matching content.
COHORT_BARRIER_HEADING = "## Cohort Barrier and Max-Concurrency Slot Filling"
MERGE_ON_GREEN_HEADING = "## Per-Item Merge to Main (Merge-on-Green)"
MERGE_CONFLICT_HEADING = "## Per-Item Merge-Conflict Handling"
CHECKPOINT_HEADING = "## Parallel-Level Checkpoint"
COMPLETION_HEADING = "## Completion Requirements"
PROCEDURE_HEADING = "## Procedure"

# The nine agent-body sections required by spec R1.
AGENT_HEADINGS: tuple[str, ...] = (
    "## Skill",
    "## Startup Protocol",
    "## Invocation Origin",
    "## Prepared-Run Execution",
    "## Delegation Model",
    "## Cohort Scheduling",
    "## Checkpoint Persistence",
    "## Documentation Maintenance",
    COMPLETION_HEADING,
)

# The thirteen F5-authored skill sections required by spec R2.1 items 3-15.
SKILL_HEADINGS: tuple[str, ...] = (
    "## Prerequisites",
    "## Parallel Manifest Consumption",
    "## Cohort Consumption and Ordering",
    COHORT_BARRIER_HEADING,
    "## Per-Item Branch and Worktree Lifecycle",
    KICKOFF_HEADING,
    "## Model Selection",
    MERGE_ON_GREEN_HEADING,
    MERGE_CONFLICT_HEADING,
    "## Worktree Cleanup",
    BOUNDARIES_HEADING,
    CHECKPOINT_HEADING,
    COMPLETION_HEADING,
)

# The three wave-4 placeholders that must remain the file's final headings.
RESERVED_HEADINGS: tuple[str, ...] = (
    "## Mutation Protocol (F6)",
    "## Enforcement Hooks (F7)",
    "## Radius Drift Detection (F8)",
)

# Baseline SHA-256 digests of the frozen epic surface, captured before any Phase
# 1 edit. This feature must modify neither file, so the digests are pinned as
# constants and compared without any git dependency in-test.
PINNED_FROZEN_SURFACE_HASHES: tuple[tuple[str, str], ...] = (
    (
        ".claude/agents/epic-orchestrator.md",
        "f4e3589ab53e6a61791f2d31e7506e7e6003ec63fe651f3cec323023d923f250",
    ),
    (
        ".claude/skills/epic-orchestrate/SKILL.md",
        "3c2e38bd5bdc5e2b7312437d47dc27aa282f2ff24fbaf01590b51e853e788d68",
    ),
)

HOOK_COMMAND_FRAGMENTS: tuple[str, ...] = (
    ".claude/hooks/validate-orchestrator-output.ps1",
    "-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json",
    "-ArtifactType parallel-orchestrator-state",
)

TEMPLATE_BANNER_FRAGMENTS: tuple[str, ...] = (
    "GENERATED FILE",
    "DO NOT HAND-AUTHOR",
)

KICKOFF_MARKER_FRAGMENTS: tuple[str, ...] = (
    "Parallel mode: true",
    "PR base branch MUST be main",
)

# The epic marker's value is pinned descriptively because a separate criterion
# forbids the epic marker literal from appearing in any delivered runtime file.
KICKOFF_NEVER_CARRIES_FRAGMENTS: tuple[str, ...] = (
    "never carries `Preparation mode: true`",
    "never carries the epic-mode marker line",
    "the marker whose text is `Epic mode` followed by the value `true`",
)

KICKOFF_IDENTITY_FRAGMENTS: tuple[str, ...] = (
    "written literally as `docs/features/active/<basename>`",
    "The canonical issue number line",
)

KICKOFF_RESUME_FRAGMENTS: tuple[str, ...] = (
    "committed `plan-path`",
    "resume at atomic execution from that plan rather than re-running "
    "promotion, research, or planning",
)

COHORT_BARRIER_FRAGMENTS: tuple[str, ...] = (
    "Cohort `N+1` branches from `main` only after every cohort-`N` item "
    "is `merged` or `worktree_removed`",
    "max_concurrency",
    "ascending item-key order",
)

MERGE_ON_GREEN_FRAGMENTS: tuple[str, ...] = (
    "durably confirm pull-request state and check conclusion with "
    "`gh pr view --json state,mergedAt,headRefOid`",
    "merge_status: ci_green",
    "Execute `gh pr merge --merge <PR>`",
    "`.claude/skills/orchestrate/SKILL.md` is **not modified by this feature**",
)

MERGE_CONFLICT_FRAGMENTS: tuple[str, ...] = (
    "with the cap of 3",
    "terminal `merge_status: blocked_ci_loop_limit`",
    "Boundary with F8",
    "leaving drift recording in `drift_events[]`, quiesce of admission, "
    "conflict recomputation against the observed radius, and requeue of "
    "the later-started item to F8",
)

BOUNDARIES_RULE_FRAGMENTS: tuple[str, ...] = (
    "is never hand-authored",
    "never the source of the cohort table",
    "The cohort column takes the place of the epic status document's wave column",
)

BOUNDARIES_REGENERATION_FRAGMENTS: tuple[str, ...] = (
    "Run kickoff",
    "Every item `state` or `merge_status` transition",
    "Every cohort transition, meaning every `current_cohort` increment",
    "Every `recolor_generation` increment",
    "Every append to `mutations[]`",
    "Every append to `drift_events[]`",
    "Run completion in `closed` mode, or run close in `open` mode",
)

MERGE_STATUS_ENUM_FRAGMENTS: tuple[str, ...] = (
    "`merge_status` enum has exactly eight members",
    "`not_started`",
    "`worktree_created`",
    "`pr_open`",
    "`ci_green`",
    "`merged`",
    "`worktree_removed`",
    "`blocked_drift`",
    "`blocked_ci_loop_limit`",
)

NEVER_WRITTEN_FRAGMENTS: tuple[str, ...] = (
    "`blocked_drift`",
    "`conflict_edges[]`",
    "`mutations[]`",
    "`drift_events[]`",
)

COMPLETION_FRAGMENTS: tuple[str, ...] = (
    "Every non-withdrawn item has `merge_status` of `merged` or `worktree_removed`",
    "In `open` mode there is no automatic completion",
    "terminates only via `/parallel-close`",
    "No completion condition involves a run-level pull request",
)

F7_BLOCK_REASON_FRAGMENTS: tuple[str, ...] = (
    "EPIC_MERGE_GATE_BLOCKED",
    "EPIC_WORKTREE_REMOVAL_BLOCKED",
)

# One case per section-scoped acceptance criterion, as
# ``(case_id, heading, fragments)``. The case identifier becomes the pytest test
# id, so each criterion reports as its own named test item while the extraction
# and assertion logic is written once.
SECTION_OBLIGATION_CASES: tuple[tuple[str, str, tuple[str, ...]], ...] = (
    ("kickoff-marker-and-main-base", KICKOFF_HEADING, KICKOFF_MARKER_FRAGMENTS),
    (
        "kickoff-never-carries-foreign-markers",
        KICKOFF_HEADING,
        KICKOFF_NEVER_CARRIES_FRAGMENTS,
    ),
    (
        "kickoff-feature-folder-and-issue-number",
        KICKOFF_HEADING,
        KICKOFF_IDENTITY_FRAGMENTS,
    ),
    ("kickoff-resume-at-plan-path", KICKOFF_HEADING, KICKOFF_RESUME_FRAGMENTS),
    (
        "cohort-barrier-and-slot-filling-order",
        COHORT_BARRIER_HEADING,
        COHORT_BARRIER_FRAGMENTS,
    ),
    (
        "merge-on-green-parent-executes-merge",
        MERGE_ON_GREEN_HEADING,
        MERGE_ON_GREEN_FRAGMENTS,
    ),
    (
        "merge-conflict-exhaustion-and-f8-handoff",
        MERGE_CONFLICT_HEADING,
        MERGE_CONFLICT_FRAGMENTS,
    ),
    (
        "boundaries-generated-projection-rules",
        BOUNDARIES_HEADING,
        BOUNDARIES_RULE_FRAGMENTS,
    ),
    (
        "boundaries-regeneration-list",
        BOUNDARIES_HEADING,
        BOUNDARIES_REGENERATION_FRAGMENTS,
    ),
    (
        "checkpoint-eight-merge-status-values",
        CHECKPOINT_HEADING,
        MERGE_STATUS_ENUM_FRAGMENTS,
    ),
    ("completion-both-run-modes", COMPLETION_HEADING, COMPLETION_FRAGMENTS),
)

RUN_PROCEDURE_FRAGMENTS: tuple[str, ...] = (
    "STOP without delegating anything when that path does not exist",
    "the user must run `/parallel-plan` first",
    "resumes at atomic execution from that item's committed `plan-path` "
    "rather than re-running promotion, research, or planning",
)

# Verbs that mark a sentence of the delivered procedure as prescribing a
# filesystem write. "generate" and "generated" are deliberately excluded: the
# skill uses them for read-from-template sentences ("Generate it from the
# template ...") and for describing the status document as a projection ("is a
# generated projection of ..."), neither of which names a write destination.
WRITE_VERBS: tuple[str, ...] = (
    "write",
    "writes",
    "written",
    "rewrite",
    "rewritten",
    "record",
    "records",
    "recorded",
    "regenerate",
    "regenerates",
    "regenerated",
)

# The closed set of non-parent actors named on this surface, drawn from the
# surface's own actor model. The delivered skill is addressed to
# ``parallel-orchestrator``, so an unattributed write sentence is a parent write;
# a sentence naming one of these actors describes that actor's write instead and
# is therefore not a parent write target.
NON_PARENT_ACTOR_MARKERS: tuple[str, ...] = (
    "child",
    "atomic-executor",
    "parallel-planner",
    "item's own `orchestrator`",
    "hook",
    "F6",
    "F7",
    "F8",
)

# The closed set of prepositions that place a path token in a write-destination
# position on this surface. "from", "of", "as", "at", "in", and "per" are
# deliberately absent: on this surface each of them introduces a read source
# ("populated with ... from `config/orchestration-routing.json`") or a
# textual-appearance description ("written literally as
# `docs/features/active/<basename>`") rather than a write destination.
WRITE_DESTINATION_PREPOSITIONS: tuple[str, ...] = ("to", "into", "under")
