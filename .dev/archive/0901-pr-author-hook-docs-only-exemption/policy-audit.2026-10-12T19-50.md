# Policy Audit: pr-author hook docs-only exemption (Issue #901)

- Timestamp: 2026-10-12T19-50
- Reviewer: feature-review agent (minor-audit re-audit, remediation cycle 1 exit)
- Branch: `bug/pr-author-hook-docs-only-exemption-901`, HEAD `24cd5c6b54decb51be75bb207f9982d8d0884d9e`
- Base: `origin/main` @ `12b2454256cfa11ff809d5d2333ddaf988574e21` (merge-base `12b2454256cfa11ff809d5d2333ddaf988574e21`)
- Diff command: `git diff origin/main...HEAD` (55 files, +3436/-26; outside the feature folder: 13 files, +1400/-26). HEAD `24cd5c6b5` merges `origin/main` (`12b245425`, PR #923 for #899) and contributes nothing to the three-dot diff.
- Work mode: `minor-audit` (AC source: `issue.md` `## Acceptance Criteria` only; `spec.md` and `user-story.md` are absent, verified by directory listing).
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`.
- Prior review: `policy-audit.2026-10-12T19-05.md` (FAIL, P20). Remediation cycle: `remediation-inputs.2026-10-12T19-05.md` (R1 blocking) and `remediation-plan.2026-10-12T19-05.md` (11 of 11 tasks checked).
- Scope source: the file list was derived from `git diff --name-status origin/main...HEAD`, the authoritative base diff. The `artifacts/pr_context.*` files were not used for the file list.

## Executive Summary

This re-audit evaluates the branch after remediation cycle 1 and a merge of `origin/main`.

- P20 (PowerShell coverage evidence for the changed hook files) is closed. The CI artifact `poshqc-test-results` from PR #924 run `38321045586` (head `c9123db7f`) measures all four changed hook files: `docs-only.ps1` 93.44%, `helpers.ps1` 97.37%, `enforce-pr-author-skill.ps1` 92.98%, `artifact-root.ps1` 96.97%, and repo-wide PowerShell 90.35% (main baseline 90.33%). The reviewer downloaded the PR and main artifacts to the session scratchpad and reproduced each counter.
- Changed-line coverage, computed by the reviewer from the line-level data in the same artifact: 74 of 78 new or changed executable lines covered (94.87%). The four uncovered lines are the `git` call in the I/O seam of `docs-only.ps1` (lines 64, 65, 68, 70), which the tests mock by design.
- No hook, mirror, manifest, or test file changed between the CI-tested head `c9123db7f` and HEAD (`git diff --stat c9123db7f HEAD` on those paths is empty). The commits after `c9123db7f` are feature-folder Markdown and the `origin/main` merge.
- Remediation cycle 1 changed only the feature folder (`issue.md` AC-9 checkbox, plan checkboxes, new evidence files).
- PA-1 (new, Blocking, evidence only): the reviewer contract names `artifacts/pester/powershell-coverage.xml` as the PowerShell coverage artifact, and the `validate-feature-review-coverage` stop hook reads that path. The local file was not regenerated in cycle 1. It is still the scoped PoshQC MCP run written 2026-10-12 18:59 (LINE covered 7308, missed 4977, 59.49% repo-wide), and it has no entry for `enforce-pr-author-skill.docs-only.ps1` or `enforce-pr-author-skill.artifact-root.ps1`. Measured against the designated artifact, the PowerShell repo-wide figure is below the 85% floor, so the PowerShell coverage verdict is FAIL. This is a gap in local evidence. The CI figures above show no code or test defect, and no code change is indicated.

Overall verdict: **FAIL**. Blocking findings: 1 (PA-1). Non-blocking observations: 2 (PA-N1, PA-N2). P20 is closed on CI evidence; PA-1 is the same evidence gap measured at the contract-designated local path.

## Rejected Scope Narrowing

No scope narrowing was detected. The caller statement "main's changes do not touch this item's files" was verified: `git diff --stat c9123db7f HEAD` restricted to `.claude/hooks`, the bundled hook mirror, `pack-manifests`, and `tests/scripts/claude-hooks` is empty. The caller instruction to state N/A for Python and TypeScript is consistent with the diff, which contains zero Python, TypeScript, or C# files. The caller-supplied coverage figures were not accepted without verification; the reviewer re-read both CI artifacts and obtained identical counters.

The PR context artifacts (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`) were stale at head `c9123db7f` with base `7d9a5c33`. The reviewer regenerated them with `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main`; the regenerated summary records head `24cd5c6b5` and merge base `12b245425`, matching this audit.

## Evidence Location Compliance

- Command: `python -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no reported paths.
- Branch-diff scan: `git diff --name-only origin/main...HEAD -- artifacts` returned zero paths. All evidence files are under `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.
- The reviewer's downloaded CI artifacts and parse scripts are in the session scratchpad, not in any repository path.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Each of the four new suites copies the repository baseline mock block and runs `Invoke-EpicStateInterceptionProbe`; no shared mutable state between `It` blocks. Unchanged since the prior audit. |
| Isolation | PASS | One behavior per `It`; all `git` access is mocked at `Invoke-PrAuthorDocsOnlyGitExe` with `-ParameterFilter` on `$GitArgs`. |
| Fast execution | PASS | No process start, no network, no sleep. CI job `poshqc / PowerShell hook suites (Linux)` SUCCESS on run `38321045586`. |
| Determinism | PASS | No clock, sleep, or temporary-file API in the four suites (reviewer grep in the prior audit; files unchanged since). |
| Readability | PASS | Explicit `# Arrange` / `# Act` / `# Assert` sections and descriptive `-ForEach` row titles. |

### 1.2 Coverage requirements

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- PowerShell baseline coverage artifact: main CI run `38315946747` (head `7d9a5c33`), artifact `poshqc-test-results` / `powershell-coverage.xml`, recorded in `evidence/baseline/p0-ci-baseline.2026-10-11T10-38.md`; reviewer re-download gives LINE covered 16232, missed 1737 (90.33%).
- PowerShell post-change coverage artifact: PR #924 CI run `38321045586` (head `c9123db7f`), artifact `poshqc-test-results` / `powershell-coverage.xml`, recorded in `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md`; reviewer re-download gives LINE covered 16300, missed 1741 (90.35%). Contract-designated local artifact `artifacts/pester/powershell-coverage.xml` (written 2026-10-12 18:59, scoped MCP run): LINE covered 7308, missed 4977 (59.49%); no entry for `docs-only.ps1` or `artifact-root.ps1` (PA-1, FAIL).
- Python baseline coverage artifact: N/A - no Python file changed on the branch.
- Python post-change coverage artifact: N/A - no Python file changed on the branch.
- Per-language comparison summary: PowerShell repo-wide line 90.33% to 90.35% (+0.02 points, no regression); each of the four changed hook files at or above 92.98%; 74 of 78 changed executable lines covered (94.87%), all from CI. The contract-designated local PowerShell artifact reads 59.49% repo-wide and does not measure two changed files, so the PowerShell coverage verdict is FAIL (PA-1). Python, TypeScript, and C# have zero changed files.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 4 production (1 new, 3 modified), 4 byte-identical mirrors, 4 new test files | pr-author hook family (170 baseline + 60 new) | CI run 38321045586: poshqc jobs SUCCESS; local family run 230 passed, 0 failed | 90.33% repo-wide line (16232/17969) | 90.35% repo-wide line (16300/18041) | 94.87% of changed executable lines (74/78) |
| Python | 0 | 0 | none | N/A | N/A | N/A |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.33% repo-wide line (16232/17969); per file `helpers.ps1` 97.30% (108/111), `enforce-pr-author-skill.ps1` 92.98% (53/57), `artifact-root.ps1` 96.55% (56/58), `docs-only.ps1` not present (new file, 0 lines). Post-change: 90.35% repo-wide line (16300/18041); per file `docs-only.ps1` 93.44% (57/61), `helpers.ps1` 97.37% (111/114), `enforce-pr-author-skill.ps1` 92.98% (53/57), `artifact-root.ps1` 96.97% (64/66). Change: repo-wide +0.02 points; `helpers.ps1` +0.07, `artifact-root.ps1` +0.42, `enforce-pr-author-skill.ps1` 0.00; no regression. New/changed-code coverage: 94.87% (74/78 changed executable lines): `docs-only.ps1` 93.44% (57/61, every line is new), `helpers.ps1` 100.00% (4/4: lines 58, 424, 425, 426), `artifact-root.ps1` 100.00% (13/13: lines 162-167, 208-210, 223-227), `enforce-pr-author-skill.ps1` 0 changed executable lines (help text only). Disposition: PASS. Evidence: `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md`, `evidence/baseline/p0-ci-baseline.2026-10-11T10-38.md`, reviewer parse of both CI `powershell-coverage.xml` files (line-level `ci` attributes inside the `git diff -U0 origin/main...HEAD` hunks). Disposition: FAIL against the contract-designated local artifact `artifacts/pester/powershell-coverage.xml` (59.49% repo-wide line, 7308/12285; `docs-only.ps1` and `artifact-root.ps1` not measured); see PA-1. The CI-based disposition above is PASS.

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell (local coverage artifact `artifacts/pester/powershell-coverage.xml`) | FAIL | PA-1: repo-wide line coverage 59.49% (7308/12285) is below the 85% floor; the scoped run has no entry for `docs-only.ps1` or `artifact-root.ps1`. Blocking until the local artifact is regenerated from a run over the full coverage population (`config/poshqc-coverage.json`). |
| PowerShell (CI coverage artifact, run 38321045586) | PASS | Every changed hook file at or above 85% line coverage (lowest 92.98%); repo-wide 90.35% at or above 85% and not regressed from 90.33%; changed lines 94.87% covered. Uncovered lines in the modified files are the same statements as on main, shifted by inserted lines (`helpers.ps1` 244/260/283 to 249/265/288; `artifact-root.ps1` 49/82 to 50/83; main hook 329-334 to 350-355), so no changed line regressed. Pester measures no branch figure; the branch threshold is not evaluated. |
| Python | N/A | Zero changed files. |
| TypeScript | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

### 1.3 Scenario completeness

| Area | Verdict | Evidence |
|---|---|---|
| Docs-only allow path (AC-1) | PASS | `DocsOnly.Decision.Tests.ps1` and `DocsOnly.Exemption.Tests.ps1` allow rows. |
| Fail-closed deny paths (AC-2) | PASS | Non-docs paths, prefix look-alikes, rename, empty diff, base absent or unresolvable, diff failure and throw: one row each. |
| Checkpoint path unchanged (AC-3) | PASS | Decision row asserts zero seam calls when the preflight passes; existing suites unedited. |
| Body-number parse (AC-5) | PASS | `BodyNumber.Tests.ps1`: overflow, leading zero, non-ASCII digits, canonical accept, end-to-end deny. |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | Exemption isolated in a sibling file with pure helpers and one I/O seam; call site adds 4 lines. Unchanged since the prior audit. |
| File size (500 lines) | PASS | Reviewer `wc -l` at HEAD: helpers 438, main hook 354, docs-only 265, artifact-root 233; tests 218, 209, 149, 141. |
| Error handling | PASS | Every `catch` converts a throw into an explicit deny result; no silent discard. |
| Dependencies | PASS | No new external dependency; `.NOTES` states in-repo dependencies and the runtime `git` use. |
| Public API compatibility | PASS | `Get-PrAuthorBypassReason` signature unchanged; deny text keeps the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED:` prefix. |
| Policy files unchanged | PASS | `git diff --name-only origin/main...HEAD -- .claude/rules .github/instructions .claude/settings.json` returned zero paths. |
| Mirror parity | PASS | Reviewer `cmp -s` at HEAD: all four canonical/mirror hook pairs byte-identical; `core.json` line 52 registers `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. |
| Cycle 1 scope | PASS | Cycle 1 commits `4c602aeab` and `08ac595a5` touch only the feature folder (`git diff --name-only bdbf8851e HEAD` outside the feature folder lists only `origin/main` merge paths from PR #923, none in the hook family). |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Format (PoshQC) | PASS | `evidence/qa-gates/p2-poshqc-format.2026-10-11T10-38.md`; CI job `poshqc / PowerShell QC` SUCCESS on run `38321045586`. Hook files unchanged since. |
| PowerShell | Analyzer (PoshQC) | PASS | `evidence/qa-gates/p2-poshqc-analyze.2026-10-11T10-38.md`; CI job `poshqc / PowerShell QC` SUCCESS on run `38321045586`. |
| PowerShell | Advanced functions, wrapper seam | PASS | `[CmdletBinding()]`, `[OutputType()]`, comment-based help on every new function; `Invoke-PrAuthorDocsOnlyGitExe -GitArgs [string[]]`. |
| PowerShell | Change budget (more than 3 production files) | PASS | Four canonical production files; `evidence/baseline/p0-route.2026-10-11T10-38.md` records `route_id: large`. |
| PowerShell | Enforcement hooks without Python | PASS | Zero Python files in the diff. |
| Python | All requirements | N/A | Zero changed files. |
| TypeScript | All requirements | N/A | Zero changed files. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Location mirrors source | PASS | `tests/scripts/claude-hooks/` is the established mirror for `.claude/hooks/`. |
| PowerShell | Mock the wrapper, not the tool | PASS | Mocks target `Invoke-PrAuthorDocsOnlyGitExe` with `-ParameterFilter`; no direct `git` mock. |
| PowerShell | No temporary files, no sleep or clock APIs | PASS | `evidence/qa-gates/p2-test-purity.2026-10-11T10-38.md`; test files unchanged since the prior reviewer grep. |

## 5. Test Coverage Detail

| Hook file | Status | Baseline line | Post-change line | Changed executable lines covered |
|---|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | New | none (new file) | 93.44% (57/61) | 57/61 (93.44%) |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | Modified | 97.30% (108/111) | 97.37% (111/114) | 4/4 (100.00%) |
| `.claude/hooks/enforce-pr-author-skill.ps1` | Modified (help text only) | 92.98% (53/57) | 92.98% (53/57) | 0/0 |
| `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` | Modified | 96.55% (56/58) | 96.97% (64/66) | 13/13 (100.00%) |
| Bundled mirrors (4 files) | Mirror | byte-identical to source | byte-identical to source | n/a |

## 6. Test Execution Metrics

| Suite | Runner | Result | Source |
|---|---|---|---|
| PR #924 CI, all checks | GitHub Actions run `38321045586` | 20 of 20 SUCCESS on head `c9123db7f` | `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md` |
| PowerShell repository suite with coverage | `poshqc / PowerShell QC` (CI) | SUCCESS; JUnit and coverage artifact published | reviewer download of `poshqc-test-results` |
| Hook suites on Linux | `poshqc / PowerShell hook suites (Linux)` (CI) | SUCCESS | `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md` |
| Local repository Pester | PoshQC MCP | tests=6093, failures=0; pr-author family 230 passed, 0 failed | `evidence/qa-gates/p2-pester.2026-10-11T10-38.md` |
| PR #924 CI on HEAD `24cd5c6b5` | GitHub Actions run `38323590007` | in progress at review time (15 pass, 5 pending, 0 fail) | `gh pr checks 924`, see PA-N1 |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Hook-family change between CI head and HEAD | None (`git diff --stat c9123db7f HEAD` on hook, mirror, manifest, and test paths is empty) |
| Uncovered lines in `docs-only.ps1` | 64, 65, 68, 70: the `git` invocation inside `Invoke-PrAuthorDocsOnlyGitExe`, mocked by design (code review CR-5) |
| Uncovered lines in modified files | Same statements as on main, shifted by inserted lines; none inside a changed hunk |
| Recommended follow-ups CR-1 and CR-2 | Carried in the PR #924 body (reviewer `gh pr view 924` body contains both identifiers) |

## 8. Gaps and Exceptions

- P20 (prior, Blocking): Closed. Evidence: `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md` and the reviewer's re-read of the CI artifact (section 1.2.1).
- PA-1 (new, Blocking): the contract-designated local PowerShell coverage artifact `artifacts/pester/powershell-coverage.xml` reads 59.49% repo-wide line coverage (below the 85% floor) and does not measure `enforce-pr-author-skill.docs-only.ps1` or `enforce-pr-author-skill.artifact-root.ps1`. The `validate-feature-review-coverage` stop hook reads this path and blocked a PASS verdict. Cause: the file is a scoped PoshQC MCP run from 2026-10-12 18:59, and remediation cycle 1 recorded CI evidence but did not regenerate it. Impact: local evidence only. The CI artifact for the same hook code shows 90.35% repo-wide, and every changed file is at or above 92.98%. Required action: regenerate `artifacts/pester/powershell-coverage.xml` from a Pester run over the full `config/poshqc-coverage.json` population (equivalent to CI `Invoke-PoshQCTest -Root <workspace>`), then confirm repo-wide line coverage at or above 85% and an entry at or above 85% for each of the four changed hook files. No code or test change is indicated. See `remediation-inputs.2026-10-12T19-50.md`.
- PA-N1 (Non-blocking observation): a new CI run (`38323590007`) on HEAD `24cd5c6b5` was in progress at review time. The coverage evidence comes from head `c9123db7f`, which is hook-identical to HEAD. Recommended action: the merge gate confirms every check on HEAD is SUCCESS before merge.
- PA-N2 (Non-blocking observation): the `## Evidence Checklist` in `issue.md` (baseline, targeted verification, end-state) remains unchecked. It is not an acceptance-criteria section under `minor-audit` and does not affect the verdict. Evidence for all three categories exists under `evidence/`.

## 9. Summary of Changes

- Original change (unchanged since the prior audit): docs-only exemption from the orchestrator-state preflight in a new sibling `enforce-pr-author-skill.docs-only.ps1`, wired into `Get-PrAuthorBypassReason`; strict body-number parse `ConvertTo-PrAuthorBodyNumber` (#850 L19); `.NOTES` corrections (#850 L25); header documentation of the exemption; bundled mirrors and `core.json` registration; four new Pester suites; L20 to L23 recorded in evidence.
- Cycle 1: CI coverage evidence recorded (`evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md`), AC-9 checked in `issue.md`, remediation baseline and QA evidence added. No code or test change.
- Merge of `origin/main` (PR #923): no effect on the three-dot diff and no hook-family path.

## 10. Compliance Verdict

**FAIL** - 1 Blocking finding (PA-1: the contract-designated local PowerShell coverage artifact is below the 85% floor and omits two changed files; evidence regeneration only, no code change indicated). P20 is closed on CI evidence. 2 non-blocking observations (PA-N1, PA-N2).

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` (218 lines): pure helpers, path classification, base-name parsing, seam argument shape.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` (209 lines): `Get-PrAuthorDocsOnlyExemption` conditions E1 to E7.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` (149 lines): end-to-end decisions through `Invoke-PrAuthorSkillDecision`, including AC-1 allow and AC-3 unchanged checkpoint path.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1` (141 lines): #850 L19 body-number parsing.
- Existing pr-author hook suites: unedited (`evidence/qa-gates/p2-scope.2026-10-11T10-38.md`).

## Appendix B: Toolchain Commands Reference

- `git diff --shortstat origin/main...HEAD`, `git diff --stat origin/main...HEAD -- .claude extensions tests`, `git merge-base origin/main HEAD`
- `git diff -U0 origin/main...HEAD -- <three modified hook files>`
- `git diff --stat c9123db7f HEAD -- .claude/hooks <mirror hooks> <pack-manifests> tests/scripts/claude-hooks`
- `git log --oneline bdbf8851e..HEAD`
- `cmp -s .claude/hooks/<file> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<file>` for four files; `wc -l` on hook and test files
- `gh run download 38321045586 -n poshqc-test-results -D <scratchpad>`; `gh run download 38315946747 -n poshqc-test-results -D <scratchpad>`
- `python -I <scratchpad>/issue-901-parse.py` and `issue-901-changed.py` (JaCoCo LINE counters and per-line `ci` values)
- `gh pr view 924 --json state,headRefOid,body,baseRefName`; `gh pr checks 924`
- `python -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>`
- `python -I <scratchpad>/issue-901-parse.py artifacts/pester/powershell-coverage.xml` (local artifact counters for PA-1)
- `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main` (PR context regeneration)
