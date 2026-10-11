# Epic Kickoff: enforcement-hook-precision

Planned by epic-planner on 2026-10-08T21:45Z. All child features are prepared: issues promoted, active
folders created, research complete, spec/user-story written, atomic plans approved, preflight
ALL CLEAR. Planning state: artifacts/orchestration/epic-planner-state.json (branch:
epic/enforcement-hook-precision-integration). Epic issue: #852.

## Invocation Prompt

Run `/epic-run enforcement-hook-precision` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at
docs/features/epics/enforcement-hook-precision/epic.md. The integration branch
epic/enforcement-hook-precision-integration already contains every prepared feature folder and approved atomic
plan; child features resume at atomic execution from their committed plan-path rather than
re-planning. Execute per the epic-orchestrate skill: wave-scheduled child orchestrator runs in
isolated worktrees, merge-on-green fan-in to the integration branch, and the final
integration-to-main PR. The epic issue is #852 (epic_issue_num). Read the Execution Notes section
of docs/features/epics/enforcement-hook-precision/epic-kickoff.md before the first wave.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 565 | docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565 | 0 | C3 | docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/plan.2026-10-08T13-52.md |
| 736 | docs/features/active/2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736 | 0 | C2 | docs/features/active/2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736/plan.2026-10-08T13-52.md |
| 824 | docs/features/active/promotion-hook-raw-containment-false-positive-deny-824 | 0 | C3 | docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/plan.2026-10-08T13-53.md |
| 732 | docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732 | 1 | C4 | docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/plan.2026-10-08T13-53.md |
| 787 | docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787 | 1 | C3 | docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/plan.2026-10-08T13-54.md |
| 850 | docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850 | 1 | C3 | docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/plan.2026-10-08T13-54.md |
| 737 | docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737 | 2 | C2 | docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md |
| 786 | docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786 | 2 | C3 | docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/plan.2026-10-08T13-54.md |

## Execution Notes

- Child feature branches (prepared, pushed, already merged into the integration branch):
  - 824: `bug/promotion-hook-raw-containment-false-positive-deny-824-r2` (the `-r2` suffix is
    deliberate; a different local branch without the suffix holds an earlier run and must not be
    used).
  - 565: `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565`
  - 736: `bug/completion-consistency-codex-copy-and-fail-open-divergence-736`
  - 732: `bug/exempt-operand-bypass-brace-and-dot-segments-732`
  - 850: `bug/pr-author-and-merge-gates-read-session-root-files-850`
  - 787: `bug/validate-orchestrator-output-session-relative-read-787`
  - 786: `bug/hook-preexisting-imports-fail-open-786`
  - 737: `bug/hook-test-isolation-remaining-gaps-737`
- Every child execution delegation must begin with the canonical issue-number line
  (`Canonical issue number for this feature is <N>.`) and a lowercase `branch:` label; otherwise
  gated delegations deny with `TARGET_WORKTREE_NOT_DERIVABLE`. A prompt that cites only an
  upstream folder still resolves to the upstream (open gap recorded by #565).
- Each child checkpoint was prepared under `route_id: preparation`. The executing orchestrator
  must switch it to `large` before Phase 0 (C1b stops with `ROUTE_REQUIRED: large`; C3 and C4
  change many PowerShell files and need a batch-budget-exempt, non-terminal route).
- Several plans begin with an upstream-merge check and stop when an upstream child is missing:
  C1b (#732) requires #824 and #565; C3 (#850) requires #824 and stops with
  `C1A-REGION-UNANTICIPATED` if #824 rewrote a region it edits; C6 (#787) requires #565; C4 (#786)
  requires #732, #850 and #787; C5b (#737) requires #736, #732 and #850.
- Wave 0 merges change enforcement hooks that later waves and the orchestrator itself run under.
  After each wave merges, confirm the merged hooks load before launching the next wave.
- After #850 merges, `gh pr merge <N>` is denied unless a checkpoint records N in
  `pr_gate.pr_number` or in `standalone_merge_authorizations` (#788 now fails closed).
- #787 research: `validate-orchestrator-output.ps1` reads `CLAUDE_HOOK_INPUT` and blocks with
  exit 1, whereas SubagentStop delivers input on stdin and only exit 2 blocks. The Layer 2 port is
  therefore proven by tests only until the unpromoted potential entry
  `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md` is
  delivered.
- Scope exclusions: #824 addendum 2 (delivered by a concurrent parallel run), #335 (closed as
  obsolete), and any behavior change for #851 (diagnostics only).
