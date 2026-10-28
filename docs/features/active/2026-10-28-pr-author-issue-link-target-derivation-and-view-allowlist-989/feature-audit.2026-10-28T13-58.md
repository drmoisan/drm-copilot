# Feature Audit: pr-author issue-link, target derivation, and gh pr view allowlist (#989)

---

**Audit Date:** 2026-10-28
**Feature Folder:** `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989`
**Base Branch:** `main`
**Head Branch:** `bug/pr-author-issue-link-target-derivation-and-view-allowlist-989`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (merge base commit `6c6aa4f0e123c25089f6669761d93d426eb4401c`)
- **Head branch/commit:** `bug/pr-author-issue-link-target-derivation-and-view-allowlist-989` (commit `bda84fbf45da8c0c27c660e62ebb71d2ca3262d3`)
- **Merge base:** `6c6aa4f0e123c25089f6669761d93d426eb4401c`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated in this review for head `bda84fbf4`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/evidence/{baseline,qa-gates,regression-testing,other}/`
  - Additional evidence: reviewer check-only commands (`git diff 6c6aa4f0e..HEAD`, `git hash-object` on eight source/bundle pairs, `validate_evidence_locations.py --root .`)
- **Feature folder used:** `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the only acceptance-criteria source. The `### Acceptance Criteria` list in `issue.md` is not authoritative for this mode and was not modified.
- **Scope note:** The pull request is not open. Criteria whose verification requires CI on the PR head are classified pending-CI per the acceptance-criteria-tracking skill. The `Test Strategy` checkboxes above `### Acceptance Criteria` in `spec.md` (unit coverage areas, integration scenario, manual verification notes) are test-planning items, not acceptance criteria, and are not counted.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md` — only source (`### Acceptance Criteria` AC1 to AC8 and `## Acceptance Criteria` GEN1 to GEN8)

### Acceptance criteria

1. AC1: The orchestrate skill and `agents/orchestrator.md` require the pr-author delegation prompt to carry `Author-asserted autoclose issues: #<issue-num>`, omitted only when the checkpoint has no `issue-num` or the run is a child of an epic whose integration PR owns the closing keyword.
2. AC2: `skills/pr-author/SKILL.md` states that an issue named as author-asserted in the delegation prompt is a valid source for `- Closes #NNN` even when the PR context lists no verified autoclose issues, and that `- None` is correct only when neither list has an entry.
3. AC3: A test or validator check fails when an orchestrated run's pr-author delegation omits the author-asserted line while the checkpoint has an `issue-num`.
4. AC4: When a `gh pr create` or `gh pr edit` command carries no branch or issue signal, the PreToolUse hook derives the target from the current worktree's checked-out branch and applies the existing checks to that item; a detached HEAD or unreadable branch keeps the NoTarget deny.
5. AC5: The `TARGET_WORKTREE_NOT_DERIVABLE` message names the exact accepted forms for `gh pr edit` and `gh pr create` and states that `--head` is not valid for edit.
6. AC6: `agents/pr-author.md` allows `Bash(gh pr view *)`; the allowlist hook permits `gh pr view <N> --json closingIssuesReferences,body` and no other `gh pr view` form with write effect; allowlist tests cover the new entry.
7. AC7: `skills/pr-author/SKILL.md` and the agent require running `gh pr view <N> --json closingIssuesReferences,body` after every create or edit and reporting the closing references found.
8. AC8: Every change is mirrored under `extensions/drm-copilot/resources/` and the `.agents`/`.codex` parallel surfaces as the contract tests require, and the seven-stage toolchain passes.
9. GEN1: Repro steps now produce the expected behavior in all documented environments.
10. GEN2: Regression test(s) added and passing (list file path and test name).
11. GEN3: Edge cases and invalid inputs are handled with correct errors or fallbacks.
12. GEN4: No unintended behavior changes outside the defined scope.
13. GEN5: Required logs/telemetry updated and validated (if applicable).
14. GEN6: Performance constraints met or explicitly waived with rationale.
15. GEN7: Full toolchain pass completed (format → lint → type-check → test).
16. GEN8: Docs/config references updated to match the new behavior.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 delegation line required by orchestrate skill and orchestrator agent | PASS | `.claude/skills/orchestrate/SKILL.md` step 3 of `## PR Authoring (pr-author Handoff)` requires the line "on its own line" and names both omission conditions; `.claude/agents/orchestrator.md` `## PR Creation Delegation` states the same and defers to the skill. Pinned by PC-01, PC-02; enforced by AA-01 to AA-12. | `git diff 6c6aa4f0e..HEAD -- .claude/skills/orchestrate/SKILL.md .claude/agents/orchestrator.md`; `evidence/other/prose-contracts.2026-10-28T13-25.md` | The agent phrases the epic condition as `epic_mode` is true; the skill adds "(an epic child whose integration PR owns the closing keyword)". |
| 2 | AC2 delegation-prompt source valid; `- None` only when no source has an entry | PASS | `.claude/skills/pr-author/SKILL.md` `## Issue/PR Reference Rules` lists three sources, states source 3 is valid "even when the PR context lists no verified autoclose issues", and "Emit the fallback `- None` bullet only when no source has an entry"; item 11 of `## PR Body Structure` reconciled. PC-03, PC-04 pass. | `git diff 6c6aa4f0e..HEAD -- .claude/skills/pr-author/SKILL.md` | The GitHub-validation rule is scoped to the two PR-context lists, removing the prior contradiction. |
| 3 | AC3 check fails when the line is omitted while the checkpoint has `issue-num` | PASS | `Get-ModelRoutingAuthorAssertedReason` in `.claude/hooks/enforce-model-routing-receipt.ps1`; AA-02, AA-03, AA-04, AA-05, AA-08, AA-09 failed before implementation and pass after. | `evidence/regression-testing/expect-fail.2026-10-28T13-12.md`; `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (454 passed, 0 failed) | Enforcement is an Agent PreToolUse deny, not prose only. |
| 4 | AC4 current-branch derivation; detached or unreadable keeps NoTarget | PASS | `Resolve-PrAuthorCurrentBranchTarget` and `Get-PrAuthorCurrentBranch` in `.claude/hooks/enforce-pr-author-skill.current-branch.ps1`; CB-07, CB-08 (derived to SessionRoot/OtherWorktree), CB-15 (existing checks applied to the derived item), CB-04, CB-05, CB-06, CB-10 (NoTarget kept). | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md`; diff inspection | Behavior proven by Pester; live subagents run `main`'s hooks (spec residual limit). |
| 5 | AC5 `TARGET_WORKTREE_NOT_DERIVABLE` message names create and edit forms; `--head` not valid for edit | PASS | `Get-PrAuthorTargetGuidanceText` text: "for gh pr create, pass --head <branch> ... For gh pr edit, run the command from the item worktree ... or append the shell comment # branch: <branch> ...; --head is not valid for gh pr edit." CB-14 asserts all three substrings and the reason-code prefix. | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` (CB-14) | Reason code and `--head` substring retained for existing TargetResolution assertions. |
| 6 | AC6 `Bash(gh pr view *)` entry; only the exact view form allowed; tests cover it | PASS | `.claude/agents/pr-author.md` frontmatter gains `"Bash(gh pr view *)"` (PC-07); `Test-PrAuthorAllowlistForm` exact six-token clause; AL-39 allow, AL-40 to AL-48 deny, AL-49 form text. | `evidence/regression-testing/expect-fail.2026-10-28T13-12.md`; `evidence/other/prose-contracts.2026-10-28T13-25.md` | The allowed form is read-only by construction. |
| 7 | AC7 skill and agent require the closing-reference verification after every create or edit | PASS | `## Closing-Reference Verification` sections in `.claude/skills/pr-author/SKILL.md` and `.claude/agents/pr-author.md` require the exact command as a single command after every `gh pr create` or `gh pr edit` and require reporting the closing numbers and any mismatch. PC-05 (skill, agent) and AL-34 pass. | `evidence/other/prose-contracts.2026-10-28T13-25.md` | AL-34 confirms every `gh` code span in the skill and agent is an allowed form. |
| 8 | AC8 mirrors and seven-stage toolchain | UNVERIFIED (pending-CI) | Mirrors: 8/8 source/bundle object IDs identical (reviewer `git hash-object`); `core.json` entry present; bundle-equality and manifest tests pass; Codex generator `--check` exit 0; `.agents`/`.codex` require no change per the contract tests. Toolchain: local loop clean (`evidence/qa-gates/powershell-format.2026-10-28T13-28.md`, `powershell-analyze.2026-10-28T13-28.md`, `architecture-guards.2026-10-28T13-28.md`, `pester-full.2026-10-28T13-48.md`, `contract-final.2026-10-28T13-50.md`). | `git hash-object <source>` and `git hash-object <bundle>` per pair | CI-dependent: the toolchain leg requires CI on the PR head (`poshqc / PowerShell QC` shards, `poshqc / PowerShell hook suites (Linux)`); the PR is not open. Owner: the item's orchestrator run at S9. |
| 9 | GEN1 repro behavior in all documented environments | UNVERIFIED (pending-CI) | Windows evidence passes (CB-07, CB-15, AL-39, AA-02). The documented environments include Linux CI. | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` | CI-dependent: the Linux hook-suite job runs only on the PR head. Owner: the item's orchestrator run at S9. |
| 10 | GEN2 regression tests added and passing | PASS | New: `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` (AA-01 to AA-12), `enforce-pr-author-skill.CurrentBranch.Tests.ps1` (CB-01 to CB-16), `pr-author-issue-link-contract.Tests.ps1` (PC-01 to PC-07); updated: `enforce-pr-author-command-allowlist.Tests.ps1` (AL-39 to AL-49). 32 expected failures before, 0 failures after. | `evidence/regression-testing/expect-fail.2026-10-28T13-12.md`; `evidence/qa-gates/pester-full.2026-10-28T13-48.md` (11438 passed, 0 failed) | — |
| 11 | GEN3 edge cases and invalid inputs | PASS | AA-04, AA-05 (prefix collisions), AA-09 (mid-line), CB-02 (invoker throws), CB-04 to CB-06, CB-09 (ambiguous), CB-12 (signal with no worktree), AL-40 to AL-48. | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` | — |
| 12 | GEN4 no unintended behavior changes outside scope | PASS | Reviewer diff inspection: every non-documentation file in `git diff --name-status 6c6aa4f0e..HEAD` is in the spec's file table or test list; no worktree-resolution library, `.codex`, `.github`, or Python change. Seeded shuffle and full run show no regression. | `git diff --name-status 6c6aa4f0e..HEAD` | — |
| 13 | GEN5 logs/telemetry updated and validated | PASS | New deny reason `AUTHOR_ASSERTED_AUTOCLOSE_MISSING` asserted by AA-02; rewritten guidance asserted by CB-14; no new telemetry channel, consistent with the spec. | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` | — |
| 14 | GEN6 performance constraints | PASS | The git process runs only on the NoTarget no-signal path: CB-11 and CB-13 show the seam is not invoked when a signal is present. The Agent check is one in-memory regex. | `evidence/qa-gates/pester-gss.2026-10-28T13-31.md` | — |
| 15 | GEN7 full toolchain pass (format, lint, type-check, test) | PASS | Format 0 rewrites; lint 0 findings; type check not applicable to PowerShell; tests 11438 passed, 0 failed. | `evidence/qa-gates/powershell-format.2026-10-28T13-28.md`; `evidence/qa-gates/powershell-analyze.2026-10-28T13-28.md`; `evidence/qa-gates/pester-full.2026-10-28T13-48.md` | Local pass; the CI confirmation is tracked under AC8. |
| 16 | GEN8 docs/config references updated | PASS | Orchestrate skill, orchestrator agent, pr-author skill and agent updated and mirrored; `core.json` entry added; search for other pr-author tool lists found none. | `evidence/other/prose-contracts.2026-10-28T13-25.md`; `evidence/qa-gates/contract-final.2026-10-28T13-50.md` | — |

---

## Blocking Findings

### FA-B1 - AC8 CI leg pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the toolchain leg of AC8 requires CI results on the PR head, and no pull request exists for this branch yet; all local legs (mirrors, contract tests, seven-stage loop) pass.
- Criterion: AC8.
- Gap: CI has not run on the PR head.

### FA-B2 - GEN1 Linux environment pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: the documented environments include Linux CI, which runs the hook suites only on the PR head; the Windows leg passes locally.
- Criterion: GEN1.
- Gap: the Linux hook-suite CI job has not run.

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION (no criterion failed; the policy audit's PowerShell repo-wide coverage artifact finding PA-B1 must be resolved, then AC8 and GEN1 await CI)

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (AC8, GEN1; both pending-CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. PA-B1 (policy audit): the canonical PowerShell coverage artifact reports 0% after a subset run overwrote it.
2. AC8: CI confirmation of the seven-stage toolchain on the PR head.
3. GEN1: Linux hook-suite CI job on the PR head.

**Recommended follow-up verification steps:**

1. Rerun the full single-process Pester suite with coverage as the last coverage-producing run, and record the artifact's repo-wide and per-file line figures under `evidence/qa-gates/`.
2. Open the PR through `Agent(pr-author)` with the line `Author-asserted autoclose issues: #989`, then wait for CI on the PR head (`poshqc / PowerShell QC` shards and `poshqc / PowerShell hook suites (Linux)`).
3. When the CI gate records `success`, check off AC8 and GEN1 in `spec.md` from the item's own worktree, push, and re-run the CI gate so `ci_gate.head_sha` equals the final head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, every criterion evaluated PASS in this review (AC1 to AC7, GEN2 to GEN8) was already checked in `spec.md` by the executor, so this review made no source-file change. AC8 and GEN1 remain unchecked as pending-CI.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md`
- Total AC items: 16
- Checked off (delivered): 14
- Remaining (unchecked): 2
- Items remaining: AC8: Every change is mirrored under `extensions/drm-copilot/resources/` and the `.agents`/`.codex` parallel surfaces as the contract tests require, and the seven-stage toolchain passes. GEN1: Repro steps now produce the expected behavior in all documented environments.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md` | 16 | 14 | 2 | Checkbox-backed; both unchecked items are pending-CI (`awaiting_ci`). |
