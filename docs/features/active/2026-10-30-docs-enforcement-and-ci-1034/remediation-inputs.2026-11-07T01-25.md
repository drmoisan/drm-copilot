# Remediation Inputs - Issue #1034 (feature review 2026-11-07T01-25)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Orchestrator scope note: notes N1 to N5 below are included in this cycle, because they are related to this item and are fixed before merge. Acceptance criterion text in `spec.md` and `user-story.md` is not changed by N5; if a reconciliation requires changing a criterion, stop and report it.

- Feature folder: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
- Branch: `feature/docs-enforcement-and-ci-1034-r2` at `48892dc051bf9ad257f8e7a3dd2ed0e0c9c073da`
- Base: `origin/epic/documentation-estate-tooling-integration`; merge base `e3e4aa551808a25c436337bf0dbcf298421a34d6`
- Source artifacts:
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/policy-audit.2026-11-07T01-25.md`
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/code-review.2026-11-07T01-25.md`
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/feature-audit.2026-11-07T01-25.md`
- Target plan path: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T01-25.md` (authored by `atomic-planner` in R1)
- Findings requiring remediation: 2, both autonomous.

## Remediation-Required Findings

### F1 - The merge gate does not bind its lookup to the pull request the command merges

- Severity: Blocking
- Status: FAIL
- Source: `code-review.2026-11-07T01-25.md` Findings Table row 1 and `### F1 probe results`; `feature-audit.2026-11-07T01-25.md` spec:516, story:65 and story:73.
- File: `.claude/hooks/enforce-docs-complete-gate.ps1`, `Get-DocsCompleteGatePullRequest` (lines 162-167), and its bundle copy.
- Finding: with the gate enabled and no receipt, these commands are allowed from a checkout whose branch has a different open pull request: `gh pr merge epic/x-integration --merge`, `gh api graphql` with `mergePullRequest` and a node identifier, and `gh pr merge 99 --merge; gh pr merge 12 --merge`. `gh pr merge 12 -R other/repo` looks up number 12 in the local repository.
- Remediability: autonomous
- Remediability-Evidence: The defect is in code on this branch, the fix uses the existing bounded gh seam and an existing reason code, and no owner decision or external party is needed.
- Required action:
  1. Pass the selector token (number, URL or branch name) to `gh pr view` unchanged, and forward a `-R` or `--repo` value. Keep `Get-EpicMergeGateSelectorPrNumber` unchanged, because the epic gate and the Codex hook share that file; add a reader for the raw selector in this hook or its own helper.
  2. Deny `PR_UNRESOLVED` when an in-scope command names a target the hook cannot resolve: a GraphQL mutation with no pull request number, or an Indeterminate match with no Structural match. A bare `gh pr merge` keeps its current-branch lookup.
  3. Evaluate every merge invocation in the command, or deny a command holding more than one.
  4. List any accepted remainder in the hook header's residual limits and in `spec.md`.
- Expected result: each probe command in the code review table ends in deny, or looks up the named repository; existing numeric, URL and bare cases are unchanged.
- Verification: new rows in `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` with a stand-in that answers differently per selector, each failing against the current code; the hook and bundle copy stay byte-identical; `enforce-epic-merge-gate-command.ps1` stays byte-identical in `.claude/hooks` and `.codex/hooks`.
- On completion: re-evaluate spec:516, story:65 and story:73.

### F2 - An unreadable profile disables an enabled gate

- Severity: Blocking
- Status: FAIL
- Source: `code-review.2026-11-07T01-25.md` Findings Table row 2; `policy-audit.2026-11-07T01-25.md` sections 2.6 and 3B.2; `feature-audit.2026-11-07T01-25.md` story:74.
- File: `.claude/hooks/enforce-docs-complete-gate.ps1`, `Get-DocsCompleteGateFileText` (line 136) and the decision lines 222-225, and its bundle copy.
- Finding: a real hook process with the gate enabled and the profile exclusively locked printed the read exception and returned `allow` with exit 0. The exception does not stop the decision, so the empty result is treated as an absent profile. The same read failure on the receipt denies, but reports `RECEIPT_ABSENT`.
- Remediability: autonomous
- Remediability-Evidence: The fix is a local change to one file seam and its callers, and `PROFILE_UNREADABLE` already exists as a reason code.
- Required action: make a read failure on an existing file distinct from an absent file. Deny `PROFILE_UNREADABLE` for the profile, and deny the receipt read with a reason that does not claim the file is absent. Preserve allow for a truly absent profile.
- Expected result: a throwing read denies, for both the profile and the receipt.
- Verification: rows in `enforce-docs-complete-gate.Tests.ps1` that make the read fail, plus one real-process run with the file locked, recorded under `evidence/regression-testing/`. Keep hook coverage at or above 85%.
- On completion: re-evaluate story:74.

## Non-Blocking Notes

These do not affect the verdict. They are related to this item, so the orchestrator may add them to the same cycle. Details are in the code review Findings Table.

- N1: the BOM assertion at line 114 of `Invoke-DocsCommand.RevisionContext.Tests.ps1` cannot fail; assert ordinally.
- N2: add a removed-element case with no ledger entry.
- N3: give `EXIT_CODE: 2` and `3` a verdict in `## Documentation Surface Check` across the mirror set.
- N4: correct the `base-ref` description in the template, and note the fixed upload path.
- N5: reconcile `spec.md` and `user-story.md` with the plan `## Notes`.

## Pending, Not a Finding

spec:544 is CI-dependent and is owned by the S9 CI green gate after the pull request exists.
