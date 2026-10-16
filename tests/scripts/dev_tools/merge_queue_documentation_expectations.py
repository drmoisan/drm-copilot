"""Fragment pins for the issue #952 queue-aware merge procedures.

Consumed by ``test_completion_gate_documentation_contracts.py``. Each pin names a
surface, the exact ``##`` heading that opens the section, and the fragments the
section must contain after whitespace collapsing. The module holds data only: it
reads no file, spawns no process, and performs no network access.
"""

from __future__ import annotations

from pathlib import Path

CONFIRMED = "only after the merge is confirmed by polling and ancestry check"

_CLAUDE_BUNDLE = Path("extensions/drm-copilot/resources/claude-customizations")
_CODEX_BUNDLE = Path("extensions/drm-copilot/resources/codex-and-agents-customizations")

PARALLEL_ORCHESTRATE = Path(".claude/skills/parallel-orchestrate/SKILL.md")
PARALLEL_ORCHESTRATOR_AGENT = Path(".claude/agents/parallel-orchestrator.md")
CLAUDE_ORCHESTRATE = Path(".claude/skills/orchestrate/SKILL.md")
EPIC_ORCHESTRATE = Path(".claude/skills/epic-orchestrate/SKILL.md")
EPIC_ORCHESTRATOR_AGENT = Path(".claude/agents/epic-orchestrator.md")
AGENTS_EPIC_ORCHESTRATE = Path(".agents/skills/epic-orchestrate/SKILL.md")
CODEX_EPIC_ORCHESTRATOR_AGENT = Path(".codex/agents/epic-orchestrator.toml")
CLEANUP_MERGED_WORKTREES = Path(".claude/skills/cleanup-merged-worktrees/SKILL.md")

MERGE_QUEUE_FRAGMENT_PINS: tuple[tuple[str, Path, str, tuple[str, ...]], ...] = (
    (
        "claude-parallel-orchestrate-merge",
        PARALLEL_ORCHESTRATE,
        "## Per-Item Merge to Main (Merge-on-Green)",
        (
            "Execute `gh pr merge --merge <PR>`",
            "Do not pass `--delete-branch` or `--auto`.",
            "A zero exit status does not prove a merge",
            ".claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson"
            " <snapshot-json> -AsJson",
            "report the item as `awaiting_merge_queue`, leave its `merge_status` at"
            " `ci_green`, and do not record `merged`",
            "the merge is confirmed only when that command exits 0",
            "Never re-issue `gh pr merge` in a loop after a `not_queued` outcome",
            "`merge_status: merged` " + CONFIRMED,
            "the queue replaces that `gh pr update-branch` cycle",
        ),
    ),
    (
        "claude-parallel-orchestrate-conflict",
        PARALLEL_ORCHESTRATE,
        "## Per-Item Merge-Conflict Handling",
        (
            "or a `not_queued` merge confirmation whose `mergeable` value is"
            " `CONFLICTING`",
        ),
    ),
    (
        "claude-parallel-orchestrator-agent",
        PARALLEL_ORCHESTRATOR_AGENT,
        "## Completion Requirements",
        ("A `merged` value is recorded " + CONFIRMED,),
    ),
    (
        "claude-orchestrate-s9",
        CLAUDE_ORCHESTRATE,
        "## Step S9 — CI Green Gate",
        (
            "`epic_merge.merge_commit_sha` is recorded " + CONFIRMED,
            "record a finding naming `awaiting_merge_queue` with"
            " `Remediability: awaiting_ci`",
            "`gh pr merge` is never re-issued in a loop after `not_queued`",
        ),
    ),
    (
        "claude-orchestrate-pr-gate",
        CLAUDE_ORCHESTRATE,
        "## PR Creation Gate",
        ("`epic_merge.merge_commit_sha` is recorded " + CONFIRMED + " (S9 step 6)",),
    ),
    (
        "claude-epic-orchestrate-lifecycle",
        EPIC_ORCHESTRATE,
        "## Epic Integration Branch Lifecycle",
        ("`epic_merge_pr.merge_commit_sha` is recorded " + CONFIRMED,),
    ),
    (
        "claude-epic-orchestrate-kickoff",
        EPIC_ORCHESTRATE,
        "## Merge-on-Green Kickoff Parameter",
        ("The child records `epic_merge` " + CONFIRMED,),
    ),
    (
        "claude-epic-orchestrate-completion",
        EPIC_ORCHESTRATE,
        "## Completion Requirements",
        ("and it is recorded " + CONFIRMED,),
    ),
    (
        "claude-epic-orchestrator-agent",
        EPIC_ORCHESTRATOR_AGENT,
        "## Completion Requirements",
        ("`epic_merge_pr.merge_commit_sha` is recorded " + CONFIRMED,),
    ),
    (
        "agents-epic-orchestrate",
        AGENTS_EPIC_ORCHESTRATE,
        "## Final Integration PR",
        ("The final merge SHA is recorded " + CONFIRMED,),
    ),
    (
        "codex-epic-orchestrator-agent",
        CODEX_EPIC_ORCHESTRATOR_AGENT,
        "## Completion",
        ("The final merge SHA is recorded " + CONFIRMED,),
    ),
    (
        "claude-cleanup-merged-worktrees",
        CLEANUP_MERGED_WORKTREES,
        "## End-to-End Workflow",
        (
            "When `main` uses a merge queue (issue #952), the queue tests the merged"
            " result of the pull request",
            "so the branch need not be up to date with `main`",
            "Without a merge queue, the ruleset on `main` sets"
            " `strict_required_status_checks_policy`, so the branch must be up to"
            " date with `main`",
        ),
    ),
)

MERGE_QUEUE_MIRROR_PAIRS: tuple[tuple[str, tuple[Path, Path]], ...] = (
    ("claude-epic-orchestrate", (EPIC_ORCHESTRATE, _CLAUDE_BUNDLE / EPIC_ORCHESTRATE)),
    (
        "claude-epic-orchestrator-agent",
        (EPIC_ORCHESTRATOR_AGENT, _CLAUDE_BUNDLE / EPIC_ORCHESTRATOR_AGENT),
    ),
    (
        "agents-epic-orchestrate",
        (AGENTS_EPIC_ORCHESTRATE, _CODEX_BUNDLE / AGENTS_EPIC_ORCHESTRATE),
    ),
    (
        "codex-epic-orchestrator-agent",
        (CODEX_EPIC_ORCHESTRATOR_AGENT, _CODEX_BUNDLE / CODEX_EPIC_ORCHESTRATOR_AGENT),
    ),
    (
        "claude-cleanup-merged-worktrees",
        (CLEANUP_MERGED_WORKTREES, _CLAUDE_BUNDLE / CLEANUP_MERGED_WORKTREES),
    ),
)
