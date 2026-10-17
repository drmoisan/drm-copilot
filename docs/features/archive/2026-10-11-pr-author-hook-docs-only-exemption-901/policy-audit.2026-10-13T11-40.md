# Policy Audit: pr-author hook docs-only exemption (Issue #901)

- Timestamp: 2026-10-13T11-40
- Reviewer: feature-review agent (minor-audit re-audit, remediation cycle 2 exit)
- Branch: `bug/pr-author-hook-docs-only-exemption-901`, HEAD `70e58ca8401ce229a761c45d9cc49c04fb73997f`
- Base: `origin/main`; merge-base `12b2454256cfa11ff809d5d2333ddaf988574e21`. `origin/main` has since advanced to `fd81a43b45de65078236da6c1cbfd077c3eb010c` (PR #925, issue #902); `git diff --name-only 12b245425 fd81a43b4` contains no pr-author hook, mirror, manifest, or hook-test path.
- Diff command: `git diff origin/main...HEAD` (78 files, +4014/-26; outside `docs/`: 13 files, +1400/-26).
- Work mode: `minor-audit` (AC source: `issue.md` `## Acceptance Criteria` only; `spec.md` and `user-story.md` are absent).
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`.
- Prior review: `policy-audit.2026-10-12T19-50.md` (FAIL, PA-1). Remediation cycle 2: `remediation-inputs.2026-10-12T19-50.md` (PA-1 blocking) and `remediation-plan.2026-10-12T19-50.md` (16 task checkboxes checked, 0 unchecked; the only `- [ ]` match in the file is quoted command text inside checked task P2-T1).
- Scope source: `git diff --name-status origin/main...HEAD`. The PR context artifacts were stale (head `24cd5c6b5`) and were regenerated with `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD --repo-root .` (exit 0); the regenerated summary records head `70e58ca84` and merge base `12b245425`, matching this audit.

## Executive Summary

This re-audit evaluates the whole branch after remediation cycle 2.

- PA-1 is closed. The reviewer read `artifacts/pester/powershell-coverage.xml` directly (report name `Pester (10/13/2026 07:28:21)`, file mtime epoch 1791890931, equal to `XML_MTIME_AFTER_EPOCH` in the rerun evidence). JaCoCo LINE counters: repo-wide covered 16309, missed 1732 (90.40%); `enforce-pr-author-skill.docs-only.ps1` 57/61 (93.44%), `enforce-pr-author-skill-helpers.ps1` 111/114 (97.37%), `enforce-pr-author-skill.ps1` 53/57 (92.98%), `enforce-pr-author-skill.artifact-root.ps1` 64/66 (96.97%). Every value matches `evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md`. The companion `artifacts/pester/pester-junit.xml` root reports tests=10322, failures=0, errors=0.
- The local per-file figures equal the PR #924 CI figures from cycle 1 (run `38321045586`) for all four changed hook files.
- Cycle 2 changed only the feature folder: `git diff --name-only 24cd5c6b5 HEAD` lists 23 paths, all under `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/`. Hook, mirror, manifest, and test files are unchanged since the CI-tested head `c9123db7f`.
- PA-N3 (new, non-blocking): several cycle 2 evidence `Timestamp:` rows were not read from the host clock at command time. Details in section 8. The counters those files record were reproduced independently by the reviewer, so no verdict depends on the affected timestamps.

Overall verdict: **PASS**. Blocking findings: 0. Non-blocking observations: 4 (PA-N1, PA-N2, PA-N3, PA-N4).

## Rejected Scope Narrowing

No scope narrowing was detected. The caller prompt sets the workspace, the base (`origin/main`), and asks for evaluation of the whole branch; this matches the contract. The caller statement that CR-1, CR-2, and PA-N1 "may be carried as non-blocking follow-ups" was evaluated on the evidence rather than accepted as a scope limit: CR-1 and CR-2 concern evasion shapes outside the AC-2 list, and PA-N1 concerns CI completion on the head commit. The caller-supplied coverage figures were not accepted without verification; the reviewer parsed the XML and obtained identical counters. Python, TypeScript, and C# have zero changed files on the branch (`git diff --name-only origin/main...HEAD` filtered on `.py`, `.ts`, `.tsx`, `.cs` returns 0 paths), so N/A is used only for those languages.

## Evidence Location Compliance

- Command: `python -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no reported paths.
- Branch-diff scan: `git diff --name-only origin/main...HEAD` filtered on `^artifacts/(baselines|qa|evidence|coverage)/` returned zero paths. All evidence is under `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.
- `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` are gitignored tool outputs, not branch files.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Each of the four new suites copies the repository baseline mock block; no shared mutable state between `It` blocks. Test files unchanged since the prior audit. |
| Isolation | PASS | One behavior per `It`; all `git` access is mocked at `Invoke-PrAuthorDocsOnlyGitExe` with `-ParameterFilter` on `$GitArgs`. |
| Fast execution | PASS | No process start, no network, no sleep in the new suites. |
| Determinism | PASS | No clock, sleep, or temporary-file API (`evidence/qa-gates/p2-test-purity.2026-10-11T10-38.md`); full local run tests=10322 failures=0 errors=0. |
| Readability | PASS | `# Arrange` / `# Act` / `# Assert` sections and descriptive `-ForEach` row titles. |

### 1.2 Coverage requirements

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- PowerShell baseline coverage artifact: main CI run `38315946747`, artifact `poshqc-test-results` / `powershell-coverage.xml` (LINE 16232/17969, 90.33%), recorded in `evidence/baseline/p0-ci-baseline.2026-10-11T10-38.md` and re-read in the prior audit.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (local, regenerated by a direct `Invoke-PoshQCTest -Root <worktree>` run in cycle 2; reviewer parse: LINE 16309/18041, 90.40%). Corroborated by PR #924 CI run `38321045586` (LINE 16300/18041, 90.35%) on hook-identical head `c9123db7f`.
- Python baseline coverage artifact: N/A - no Python file changed on the branch.
- Python post-change coverage artifact: N/A - no Python file changed on the branch.
- Per-language comparison summary: PowerShell repo-wide line 90.33% (baseline) to 90.40% (local post-change), no regression; each of the four changed hook files at or above 92.98%; 74 of 78 changed executable lines covered (94.87%, computed in the prior audit from CI line data; no hook line changed since). Python, TypeScript, and C# have zero changed files.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 4 production (1 new, 3 modified), 4 byte-identical mirrors, 4 new test files | full repository Pester run (10322 tests) including the pr-author hook family | local direct run: failures=0, errors=0, exit 0 (rerun); CI run 38323590007 on `24cd5c6b5`: all jobs success | 90.33% repo-wide line (16232/17969) | 90.40% repo-wide line (16309/18041) | 94.87% of changed executable lines (74/78) |
| Python | 0 | 0 | none | N/A | N/A | N/A |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.33% repo-wide line (16232/17969); per file `helpers.ps1` 97.30% (108/111), `enforce-pr-author-skill.ps1` 92.98% (53/57), `artifact-root.ps1` 96.55% (56/58), `docs-only.ps1` absent (new file). Post-change: 90.40% repo-wide line (16309/18041), from local `artifacts/pester/powershell-coverage.xml` (reviewer parse); per file `docs-only.ps1` 93.44% (57/61), `helpers.ps1` 97.37% (111/114), `enforce-pr-author-skill.ps1` 92.98% (53/57), `artifact-root.ps1` 96.97% (64/66). Change: repo-wide +0.07 points; `helpers.ps1` +0.07, `artifact-root.ps1` +0.42, `enforce-pr-author-skill.ps1` 0.00; no regression. New/changed-code coverage: 94.87% (74/78): `docs-only.ps1` 57/61 (all lines new; uncovered 64, 65, 68, 70 are the `git` call inside the mocked seam), `helpers.ps1` 4/4, `artifact-root.ps1` 13/13, `enforce-pr-author-skill.ps1` 0 changed executable lines. Disposition: PASS. Evidence: `evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md`, `evidence/qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md`, `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md`, and the reviewer's direct parse of the local XML.

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell | PASS | Contract-designated artifact `artifacts/pester/powershell-coverage.xml` now measures all four changed hook files, each at or above 85% line (lowest 92.98%); repo-wide 90.40% at or above 85% and not regressed from 90.33%; changed lines 94.87% covered. Pester measures no branch figure; the branch threshold is not evaluated for PowerShell. PA-1 closed. |
| Python | N/A | Zero changed files. |
| TypeScript | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

Threshold note: the agent contract's Verification Procedure still cites 90% new-file and 80% repo-wide, while its threshold section and `.claude/rules/quality-tiers.md` set a uniform 85% line floor. The new file `docs-only.ps1` (93.44%) and the repo-wide figure (90.40%) meet both readings.

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
| Simplicity and separation of concerns | PASS | Exemption isolated in a sibling file with pure helpers and one I/O seam; call site adds 4 lines in `Get-PrAuthorBypassReason`. |
| File size (500 lines) | PASS | Reviewer `wc -l` at HEAD: helpers 438, main hook 354, docs-only 265, artifact-root 233; tests 218, 209, 149, 141. |
| Error handling | PASS | Every `catch` converts a throw into an explicit deny result; the seam returns `ExitCode -1` instead of throwing. |
| Dependencies | PASS | No new external dependency; `.NOTES` lists in-repo dependencies and the runtime `git` use. |
| Public API compatibility | PASS | `Get-PrAuthorBypassReason` signature unchanged; deny text keeps the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED:` prefix. |
| Policy files unchanged | PASS | `git diff --name-only origin/main...HEAD -- .claude/rules .github/instructions .claude/settings.json` returned zero paths. |
| Mirror parity | PASS | Reviewer `cmp -s` at HEAD: all four canonical/mirror hook pairs byte-identical; `core.json` line 52 registers `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. |
| Cycle 2 scope | PASS | Commits `ff1b7cbd4`, `395a94432`, `70e58ca84` touch only the feature folder. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Format (PoshQC) | PASS | `evidence/qa-gates/p2-poshqc-format.2026-10-11T10-38.md`; CI `poshqc / PowerShell QC` success on runs `38321045586` and `38323590007`. Hook files unchanged since. |
| PowerShell | Analyzer (PoshQC) | PASS | `evidence/qa-gates/p2-poshqc-analyze.2026-10-11T10-38.md`; same CI jobs success. |
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
| PowerShell | No temporary files, no sleep or clock APIs | PASS | `evidence/qa-gates/p2-test-purity.2026-10-11T10-38.md`; test files unchanged since. |

## 5. Test Coverage Detail

| Hook file | Status | Baseline line | Post-change line (local XML) | Changed executable lines covered |
|---|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | New | none (new file) | 93.44% (57/61) | 57/61 (93.44%) |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | Modified | 97.30% (108/111) | 97.37% (111/114) | 4/4 (100.00%) |
| `.claude/hooks/enforce-pr-author-skill.ps1` | Modified (help text only) | 92.98% (53/57) | 92.98% (53/57) | 0/0 |
| `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` | Modified | 96.55% (56/58) | 96.97% (64/66) | 13/13 (100.00%) |
| Bundled mirrors (4 files) | Mirror | byte-identical to source | byte-identical to source | n/a |
| Repo-wide PowerShell | - | 90.33% (16232/17969) | 90.40% (16309/18041) | - |

## 6. Test Execution Metrics

| Suite | Runner | Result | Source |
|---|---|---|---|
| Full repository Pester with coverage (direct, CI form) | `Invoke-PoshQCTest -Root <worktree>` | tests=10322, failures=0, errors=0, disabled=10; rerun exit code 0 observed | reviewer read of `artifacts/pester/pester-junit.xml`; `evidence/qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md` |
| PR #924 CI on `24cd5c6b5` | GitHub Actions run `38323590007` | completed, conclusion success, 17 of 17 jobs success | `gh run view 38323590007` |
| PR #924 CI on HEAD `70e58ca84` | GitHub Actions runs `38391222365` and `38391222486` | in progress at review time: 13 pass, 8 pending, 0 fail | `gh pr checks 924`; see PA-N1 |
| PR #924 CI on `c9123db7f` | GitHub Actions run `38321045586` | 20 of 20 success; coverage artifact source for cycle 1 | `evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md` |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Hook-family change between CI-tested head `c9123db7f` and HEAD | None on branch-owned paths; the only differences under `extensions/drm-copilot/resources/claude-customizations` come from the `origin/main` merge `24cd5c6b5` (agents, skills, ci-gate parser) and are absent from the three-dot diff |
| Uncovered lines in `docs-only.ps1` | 64, 65, 68, 70: the `git` invocation inside `Invoke-PrAuthorDocsOnlyGitExe`, mocked by design |
| Overlap of `origin/main` advance (`12b245425..fd81a43b4`) with branch files | None (`grep` for `enforce-pr-author`, `pack-manifests`, `tests/scripts/claude-hooks` returned no path) |
| Recommended follow-ups CR-1 and CR-2 | Carried as non-blocking; listed in the PR #924 body per the prior audit |

## 8. Gaps and Exceptions

- PA-1 (prior, Blocking): Closed. The contract-designated artifact `artifacts/pester/powershell-coverage.xml` was regenerated by a direct full run; repo-wide LINE 90.40% and all four changed hook files at or above 92.98%, verified by the reviewer's own parse (section 1.2.1).
- PA-N1 (carried, Non-blocking): CI on HEAD `70e58ca84` was in progress at review time (8 jobs pending, including `poshqc / PowerShell QC`). The prior head `24cd5c6b5` run `38323590007` completed with all jobs success, and the commits after it are feature-folder Markdown only. Recommended action: the merge gate confirms every check on HEAD is success before merge.
- PA-N2 (carried, Non-blocking): the `## Evidence Checklist` in `issue.md` remains unchecked. It is not an acceptance-criteria section under `minor-audit`.
- PA-N3 (new, Non-blocking): cycle 2 evidence `Timestamp:` rows do not match the times the recorded commands ran, contrary to `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (the value is read from the host clock, never composed or estimated). Observed: (a) `p1-pester-junit`, `p1-poshqc-test-invocation`, and `p1-xml-regenerated` (suffix `2026-10-12T19-50`) record `2026-10-13T00-00`, while `p1-xml-regenerated` records an XML mtime of 10:51 UTC; (b) commit `ff1b7cbd4` (committed 07:17 local, -04:00) introduces rows stamped `2026-10-13T11-30` to `2026-10-13T11-39`, which are later than the commit under either local or UTC reading; (c) commit `70e58ca84` (07:34 local) introduces rows stamped `11-32` to `11-37`. Impact: the run chronology in these files cannot be read from their timestamps. The substantive values (coverage counters, JUnit totals, XML mtimes) were reproduced by the reviewer from the artifacts on disk, so no verdict depends on the affected rows. Recommended action: correct the rows from the recorded epoch values and commit times in a follow-up docs commit, or annotate them as reconstructed.
- PA-N4 (new, Non-blocking): `origin/main` advanced to `fd81a43b4` (PR #925) after the branch's last merge. No path overlaps the branch's files, and GitHub reports PR #924 as `MERGEABLE`. Recommended action: merge or rebase on `origin/main` before merge if branch protection requires an up-to-date branch.

## 9. Summary of Changes

- Original change: docs-only exemption from the orchestrator-state preflight in a new sibling `enforce-pr-author-skill.docs-only.ps1`, wired into `Get-PrAuthorBypassReason`; strict body-number parse `ConvertTo-PrAuthorBodyNumber` (#850 L19); `.NOTES` corrections (#850 L25); header documentation of the exemption; bundled mirrors and `core.json` registration; four new Pester suites; #850 L20 to L23 recorded in evidence.
- Cycle 1: CI coverage evidence recorded; AC-9 checked. No code or test change.
- Cycle 2: local PowerShell coverage XML regenerated by a direct full `Invoke-PoshQCTest` run (after a scoped MCP attempt that again omitted two files, recorded in `local-powershell-coverage.2026-10-12T19-50.md` as FAIL and kept as history); one rerun recorded with an observed exit code 0. No code, test, or `issue.md` change.

## 10. Compliance Verdict

**PASS** - 0 Blocking findings. PA-1 is closed. 4 non-blocking observations (PA-N1, PA-N2, PA-N3, PA-N4).

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` (218 lines): pure helpers, path classification, base-name parsing, seam argument shape.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` (209 lines): `Get-PrAuthorDocsOnlyExemption` conditions E1 to E7.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` (149 lines): end-to-end decisions through `Invoke-PrAuthorSkillDecision`, including AC-1 allow and AC-3 unchanged checkpoint path.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.BodyNumber.Tests.ps1` (141 lines): #850 L19 body-number parsing.
- Existing pr-author hook suites: unedited (`evidence/qa-gates/p2-scope.2026-10-11T10-38.md`).

## Appendix B: Toolchain Commands Reference

- `git diff --shortstat origin/main...HEAD`; `git diff --name-status origin/main...HEAD`; `git merge-base origin/main HEAD`
- `git diff --name-only 24cd5c6b5 HEAD`; `git diff --stat c9123db7f HEAD -- .claude/hooks extensions/drm-copilot/resources/claude-customizations tests/scripts/claude-hooks`
- `git diff --name-only 12b245425 fd81a43b4` (overlap check against the `origin/main` advance)
- `git show -s --format=%cI <sha>` and `git show <sha>:<file>` for the timestamp-row comparison (PA-N3)
- `awk` over `artifacts/pester/powershell-coverage.xml` (per-`sourcefile` and report-level `LINE` counters); `grep -o '<testsuites [^>]*>' artifacts/pester/pester-junit.xml`; `ls -l --time-style=+%s` on both files
- `cmp -s` on four canonical/mirror hook pairs; `wc -l` on hook and test files
- `gh pr view 924 --json state,headRefOid,baseRefName,mergeable`; `gh pr checks 924`; `gh run view 38323590007 --json conclusion,status,headSha,jobs`
- `python -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>`
- `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD --repo-root .`
