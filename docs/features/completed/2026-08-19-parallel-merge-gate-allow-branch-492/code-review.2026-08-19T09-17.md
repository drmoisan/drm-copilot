# Code Review — parallel-merge-gate-allow-branch (Issue #492)

- Timestamp: 2026-08-19T09-17
- Branch: `bug/parallel-merge-gate-allow-branch-492` (commit d6040ace)
- Base: `origin/main`
- Files reviewed: `.claude/hooks/enforce-epic-merge-gate.ps1`,
  `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`,
  `.claude/rules/parallel-orchestration.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, and the
  byte-identical bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/**`.

## Summary

The change adds a third allow-branch to the merge gate for the parallel-orchestrator surface. The
implementation is cohesive with the existing two branches, uses the established read-seam pattern,
and fails closed on every ambiguous or invalid input. Test coverage is thorough (allow, deny, and
per-helper branch cases). No blocking issues were found.

## Correctness of the parallel allow condition vs. `.claude/rules/parallel-orchestration.md`

- `route_id` is compared with exact string equality against `'parallel'`
  (`enforce-epic-merge-gate.ps1:272`), matching orchestrator invariant 2 ("`route_id` must be
  exactly `'parallel'`"). Non-parallel route_id denies. Correct.
- `merge_status == "ci_green"` is a valid member of the merge-status enum
  (`.claude/rules/parallel-orchestration.md`, Enum Ownership table) and is the correct pre-merge,
  CI-passed state for authorizing a per-item merge. Any other value (e.g. `pr_open`) denies
  (`enforce-epic-merge-gate.ps1:302`). Correct.
- Item matching is keyed on `items[].pr_number` (`enforce-epic-merge-gate.ps1:289-296`). The
  parallel schema's primary key is `issue_num`; `pr_number` is a cache field of the item record
  populated from `gh pr view` (Cache Doctrine). Matching a `gh pr merge <N>` command against the
  cached `pr_number` is the correct join, because the command names the PR number, not the issue
  number. Correct.
- Fail-closed posture is complete: `$null` checkpoint denies (`:268`); missing `route_id` or
  non-`parallel` denies (`:272`); `$null` command PR number denies (`:277`); missing/`$null`
  `items` denies (`:280`); a non-numeric or non-matching item `pr_number` is skipped and, if no item
  matches, the function returns `$false` (`:305`); a matched item missing `merge_status` denies
  (`:299-301`). Malformed JSON is converted to `$null` by `ConvertFrom-EpicMergeGateJson` and then
  denied. This satisfies the "missing, unreadable, or invalid checkpoint denies" requirement.

## Additivity — epic/child branches unchanged

- The child-feature path (`Test-ChildCheckpointAllowsEpicMerge`) and epic-integration path
  (`Test-EpicCheckpointAllowsMerge`) function bodies are unchanged in the diff. The parallel branch
  is appended in `Invoke-EpicMergeGateDecision` after both existing checks
  (`enforce-epic-merge-gate.ps1:386-389`), so the parallel path is only reached when neither prior
  branch allowed. This preserves prior allow/deny outcomes for the child and epic paths.

## Observation — PR-number extractor broadening (non-blocking)

`Get-EpicMergeGateCommandPrNumber` gained a second, additive regex branch
(`enforce-epic-merge-gate.ps1:152-154`) to capture the flag-before-number form
`gh pr merge --merge <N>` used by parallel runs. The original number-before-flag regex is evaluated
first and returns verbatim (`:144-146`), so the forms the epic path uses (`gh pr merge <N> --merge`
and bare `gh pr merge --merge`) yield identical results. The broadened branch could, in principle,
extract a PR number from `gh pr merge --merge <N>` under epic mode where the old code returned
`$null`; the effect there would be to require the number to match `epic_merge_pr.pr_number` rather
than treating it as a bare (trusted) merge. That makes the epic path stricter, not more permissive,
and that command form is not part of the epic path's documented usage. No security or correctness
regression results. Recorded as an observation only.

The second regex `(?<![-\w])(\d+)\b` correctly excludes digits embedded in flag tokens (e.g. the
`merge` in `--merge` has no digits, and a token like `--merge` is not preceded by a boundary that
would capture a number). A bare `gh pr merge --merge` still returns `$null`, which is asserted by a
dedicated test.

## Mirror parity (non-blocking observation on `.codex`)

- The three in-scope mirror pairs are byte-identical (`diff -q` and the push-down parity test
  `test_push_down_claude_resource_contracts.py`, 10 passed): the hook, `parallel-orchestration.md`,
  and `parallel-orchestrate/SKILL.md` under `.claude/**` match their
  `extensions/drm-copilot/resources/claude-customizations/.claude/**` copies.
- Separately, `.codex/hooks/enforce-epic-merge-gate.ps1` and
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
  differ from the `.claude` hook. This is a PRE-EXISTING divergence: on `origin/main` the `.codex`
  copy is already a distinct, smaller Codex-runtime variant (`ConvertFrom-CodexMergeJson`, a
  different synopsis) rather than a byte-identical mirror of the `.claude` hook. It is not changed by
  this branch and is outside the issue's scope, which names only the `.claude` hook and
  `.claude/settings.json`. Noted so a later reader does not mistake the pre-existing `.codex`
  variant for mirror drift introduced here. If the Codex runtime is expected to gate parallel merges
  equivalently, that is separate follow-up work, not a defect of this change.

## Design and best-practices review

- Single responsibility per function; decision helpers are pure over their parsed-checkpoint input
  and are independently unit-tested. Read seams isolate I/O.
- Naming is descriptive and uses approved PowerShell verbs.
- Error handling fails fast/closed; no broad catch-all that swallows operational errors.
- File remains 408 lines, well under the 500-line limit.
- Comments are accurate and neutral; the `.SYNOPSIS`/`.DESCRIPTION` were updated to describe the
  third branch and the "one of three" condition count.

## Test adequacy

- Allow: parallel route + ci_green + matching PR (`:132-143`).
- Deny: wrong merge_status (`:146-156`), non-matching PR (`:158-168`), wrong route_id (`:170-180`),
  absent checkpoint (`:182-190`), malformed JSON checkpoint (`:192-200`), bare command with no PR
  number (`:202-212`).
- Extractor: number-before-flag, flag-before-number, and bare forms (`:215-227`).
- Read seam: `Get-ParallelOrchestratorCheckpointContent` file-absent and file-present paths using
  real `Test-Path`/`Get-Content` mocks with `LiteralPath` parameter filters (`:229-240`).
- Helper branch coverage: `Test-ParallelCheckpointAllowsMerge` exercised for null checkpoint, wrong
  route_id, null PR number, absent items, no-match, non-numeric pr_number, missing merge_status,
  non-ci_green, and the true path (`:242-286`).
- No temporary files are created; no external executables are invoked. Existing child/epic and
  end-to-end entrypoint tests are retained.

## Blocking Findings

None.

## Verdict

PASS. No blocking or blocking-PARTIAL findings. Two non-blocking observations recorded (extractor
broadening under epic mode; pre-existing `.codex` variant divergence). Code-review blocking_count = 0.
