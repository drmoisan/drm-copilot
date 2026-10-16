# Remediation Inputs (Issue #952)

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-16T12-51
**Feature folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
**Base branch:** `main` (merge base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`)
**Head audited:** `bug/ci-merge-queue-for-main-952` @ `cc79f6382947e5eca97f9102490a8bbabf2fc61d`
**Work mode:** `full-bug`; AC source is `spec.md` only
**Review pass:** initial review
**Blocking finding count:** 2 (R1 class autonomous; R2 class awaiting_ci)

## Audit Artifacts

- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-audit.2026-10-16T12-51.md` (Section 8: PA-1 FAIL, PA-2 UNVERIFIED; PA-N1 to PA-N7 non-blocking)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/code-review.2026-10-16T12-51.md` (Findings Table: CR-1 Blocker, the same finding as PA-1; CR-2 to CR-11 non-blocking)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/feature-audit.2026-10-16T12-51.md` (13 PASS, 0 PARTIAL, 14 UNVERIFIED, 1 FAIL (AC-27))

## Trigger Justification

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8, clause "coverage below the governing thresholds ... new files": the new PowerShell file `.codex/hooks/enforce-epic-merge-gate-command.ps1` is at 75.47% line coverage on R_final 38899600487, below 85%. Every other check (format, lint, type check, tests on Windows and Linux, mirrors, line counts, scope boundary, evidence locations, Python coverage) passed.

## Workflow Green-Run Evidence (`modified-workflow-needs-green-run`)

- Workflow: `.github/workflows/ci.yml` (modified by this branch).
- Run: R_final 38899600487, event `workflow_dispatch`, head `d039138bad7010475997c09aea1b55b64e0ca9b5`, conclusion `success`, 17/17 jobs success (`evidence/qa-gates/ci-rows-windows.2026-10-16T12-40.md`).
- Predecessor-head condition (b): `git merge-base --is-ancestor d039138ba HEAD` exits 0; the latest commit changing any path outside the feature folder is `d039138ba`; `git log d039138ba..HEAD -- . ":!docs/features/active/2026-10-16-ci-merge-queue-for-main-952"` returns no commits. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.
- Any remediation commit outside the feature folder invalidates this evidence; the repeat dispatch in R1 step 5 replaces it.

## Findings

### R1 - New-file PowerShell coverage below 85% for the Codex helper (PA-1, CR-1)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is test additions and, if needed, a test-setup correction inside this repository, followed by a CI dispatch the orchestrator already performs; no external system, policy change, or human decision is involved.

**Problem.** ORCH-6 (`evidence/qa-gates/coverage-comparison.2026-10-16T12-40.md`) reports `.codex/hooks/enforce-epic-merge-gate-command.ps1` (new) at 75.47% line and changed-line coverage (40/53), uncovered lines 63, 64, 68, 160, 161, 166, 173, 176-180, 183. The Claude copy, byte-identical (hash `d7dfe732d`), is at 94.34%. ORCH-6 attributes the gap to Codex suites that do not drive the URL selector form, the `--` terminator, the `--merge=<n>` form, or the REST `pulls/<n>/merge` reader path. That attribution is only partly correct: `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` already drives the URL selector (lines 134 and 149) and the REST reader (lines 135 and 151), and those cases pass on R_final, yet lines 63-64 and 176-180 are reported uncovered for the Codex file. Either the executions are attributed to a different file during the coverage run, or the cases resolve the helper functions from another source. Adding duplicate URL or REST cases may therefore not change the figure.

**Required change.**

1. Diagnose the attribution before adding tests. In a scratch copy or a temporary local edit that is not committed, run the Codex merge-queue suite alone with Pester code coverage scoped to `.codex/hooks/enforce-epic-merge-gate-command.ps1` (PoshQC test tool with the suite path, or `Invoke-Pester` with `CodeCoverage.Path` set to that file), and record whether lines 63-64 and 176-180 are hit. Also record `(Get-Command Get-EpicMergeGateSelectorPrNumber).ScriptBlock.File` from inside the suite's `BeforeAll` after dot-sourcing the Codex hook. Write the result to `evidence/regression-testing/codex-helper-coverage-diagnosis.<timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`.
2. If the scoped run shows those lines hit, the full-run figure is an attribution effect. Identify which earlier suite in the same Pester run defines the same function names (for example a suite that dot-sources the Claude helper at script scope) and correct the test setup so the Codex suites resolve the Codex copy. Do not rename functions in only one copy; the two helper files must stay byte-identical (spec Design summary item 2).
3. Add Codex cases to `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` (C-4 group, `Get-CodexMergeCommandPrNumber`) for the paths that no Codex case exercises: `gh pr merge -- 5` (expect 5), `gh pr merge --merge --` (expect `$null`), `gh pr merge --merge=5` (expect 5), `gh pr merge feature-branch --merge` (expect `$null`), `gh pr merge --merge` (expect `$null`), and `gh api graphql -f query='mutation { mergePullRequest(input: {pullRequestId: "PR_kwDO"}) { clientMutationId } }'` (expect `$null`). Keep the suite under 500 lines.
4. Do not add coverage exclusions, lower thresholds, or edit `pester.runsettings.psd1` or `config/poshqc-coverage.json` to remove the file.
5. Run the PowerShell toolchain loop (format, analyze, test) on the touched suites, then dispatch `ci.yml` on the branch head and repeat ORCH-4, ORCH-5, and ORCH-6 on the new run. ORCH-6 must report the Codex helper at >= 85% line and changed-line coverage, record the repository-wide PowerShell line figure, and correct the cause statement.

**Verification commands.**

```bash
# from the worktree root (PowerShell steps through the PoshQC MCP tools or the PowerShell tool)
# 1. scoped coverage run of the Codex suite (diagnosis)
# 2. full PoshQC test run of tests/scripts/codex-hooks and tests/scripts/claude-hooks
gh workflow run ci.yml --ref bug/ci-merge-queue-for-main-952
gh run watch <run-id> --exit-status
gh run download <run-id> -n poshqc-test-results -D <scratch>/issue-952-ci-<run-id>/win
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# Expect: run conclusion success; Codex helper >= 85.00 line and changed-line in ORCH-6
```

### R2 - AC-28 pending the `pull_request` CI run on the final PR head (PA-2)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: AC-28 is verified only by the `pull_request` run of `ci.yml` on the final PR head, which cannot exist before the PR is opened; it is resolved at S9 and needs no code change.

**Problem.** No PR exists for the branch, so the `pull_request` run required by AC-28 has not occurred.

**Required change.** None in code. After R1 completes and the PR is opened, the item's own orchestrator run checks off AC-28 at S9 once `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head, per `.claude/skills/acceptance-criteria-tracking/SKILL.md` "CI-Dependent Criteria".

## In-Item Non-blocking Findings (fix in the same cycle)

These do not change the verdict. They are in the same files or the same feature and are to be fixed in the R1 cycle.

| ID | Severity | File | Required change |
|---|---|---|---|
| CR-2 (PA-N1) | Minor | `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` | Add the R1 step 3 `--` terminator and branch-name selector cases to the B-4 group so Claude helper lines 68, 160, 161 are exercised. |
| CR-3 (PA-N2) | Minor | `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` | Add: `MERGED` with `"mergedAt":null` (expect `MergedAt` `''`); `-PrJson ''` (expect the `Invoke-MergeConfirmationParser: the pull-request snapshot is null or empty.` throw); direct `ConvertTo-MergeConfirmationTimeText` calls with a `[datetimeoffset]` value and a non-date string. Parser lines 98, 101, 108, 128. |
| CR-4 (PA-N3) | Minor | `.claude/hooks/enforce-epic-merge-gate-command.ps1`, `.codex/hooks/enforce-epic-merge-gate-command.ps1`, both bundle mirrors | In `Get-EpicMergeGateSelectorPrNumber`, return from the `--merge=<value>` branch only when the value converts to a number; otherwise advance one token and continue. Add `gh pr merge --merge=true 5` (expect 5) on both runtimes. Keep all four copies byte-identical. |
| CR-5 (PA-N4) | Minor | Helper header (all four copies); `spec.md` Rollout follow-ups or `policy-followups.md` | Document that a GraphQL mutation supplied from a file (`-F query=@file`, `--input file`) is not visible to the text-based scope. If fail-closed handling is chosen instead, add tests on both runtimes. |
| CR-6 | Info | Next ORCH-6 artifact | Correct the cause statement for the Codex helper gap to match the R1 diagnosis. |
| CR-7 (PA-N5) | Info | `evidence/other/scope-deviation-d10.<timestamp>.md` (new) | Record that D10(a) delivered the cleanup-skill edit in-item although `spec.md` lines 71 and 334 list it as out of scope and as a follow-up; reference the coordinator decision. Do not edit `spec.md` acceptance criteria. |
| CR-8 (PA-N6) | Nit | `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` | Direct the capture in `## Capture and Diff Before Applying` step 1 to a scratch path, or state that `protect-main.live.json` is not committed. Re-run the runbook section check (AC-24 tokens) afterwards. |
| CR-9 (PA-N7) | Info | Next ORCH-6 artifact | Record the repository-wide PowerShell line figure from the R_final `powershell-coverage.xml`. |

## Do Not Do

- Do not edit policy documents under `.claude/rules/` or `.github/instructions/`; `policy-followups.md` remains the record for those changes.
- Do not apply, PUT, or otherwise change ruleset 15241672.
- Do not edit `.github/workflows/_poshqc.yml` or `.claude/hooks/hook-command-invocation.ps1`.
- Do not add coverage exclusions or lower thresholds.
- Do not check off AC-1, AC-2, AC-5 to AC-15, AC-27, or AC-28 from the executor; the orchestrator checks off the first group after ORCH-4 to ORCH-6 pass on one run, and AC-28 at S9.
- Do not let the two helper files, or any `.claude/`, `.codex/`, `.agents/` file and its bundle mirror, diverge.

## Exit Gate

Re-audit (policy-audit, code-review, feature-audit) with zero autonomous blocking findings: a new dispatched `ci.yml` run on the branch head concludes `success`; ORCH-4 and ORCH-5 pass on it; ORCH-6 reports every new and modified PowerShell production file at >= 85% line and changed-line coverage, including `.codex/hooks/enforce-epic-merge-gate-command.ps1`, with the repository-wide PowerShell figure recorded. AC-28 remains pending CI until S9.
