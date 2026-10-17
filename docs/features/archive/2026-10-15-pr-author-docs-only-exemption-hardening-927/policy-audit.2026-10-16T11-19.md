# Policy Audit: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T11-19
- Reviewer: feature-review agent (R4 re-audit after remediation cycle 2)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `d7b4da0759cff1d47c302019122f3cac33cb3457`
- Base: `main` (resolved `origin/main`); merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`.
- Diff command: `git diff --stat 5bdf22d0f..HEAD` (176 files, +13698/-290). Outside `docs/`: 35 files (7 canonical hook files, 7 byte-identical bundle mirrors, 2 pack manifests, 19 Pester suites of which 6 are new). Inside `docs/`: the #927 feature folder and 14 modified files of the #901 folder.
- Last code commit on the branch: `bf3c5e310` (2026-10-16T06:20:41-04:00, CR-R1 dispose fix). Later branch commits `7b43fddd5` and `48d5de942` change only files under the #927 feature folder. The merge commit `d7b4da075` brings in `origin/main`; `git diff --name-only bf3c5e310 HEAD` restricted to the seven changed hook files, `tests/scripts/codex-hooks`, and `config/poshqc-coverage.json` lists nothing, and the files it lists under `tests/scripts/claude-hooks` are SubagentStop validator suites that are not in the branch diff.
- Work mode: `full-bug` (`issue.md` line 9). AC source: `spec.md` version 1.3, `## Acceptance Criteria` only (47 items: AC-M1 to AC-M25, AC-1 to AC-22).
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`.
- PR context: `artifacts/pr_context.summary.txt` (generated 2026-10-16 11:14:48 UTC) records head `d7b4da075` and merge base `5bdf22d0f`, matching this audit; not regenerated. No pull request exists for the branch (`gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state all` returned `[]`).
- Prior review: `policy-audit.2026-10-16T09-23.md` (1 blocking finding, PA-1R). Remediation plan executed: `remediation-plan.2026-10-16T11-20.md` (cycle 2).

## Executive Summary

Remediation cycle 2 closed the one blocking finding of the prior review and the Low observation CR-R1:

- PA-1R (closed): the local PowerShell coverage artifact `artifacts/pester/powershell-coverage.xml` is now a full-population output of the repository PoshQC module (route B, `evidence/qa-gates/r2-pa1r-route-b.2026-10-16T10-53.md`). The reviewer parsed it directly: report-level LINE 16644/18426 (90.33%), with a `sourcefile` entry at or above 85% for each of the seven changed hook files, including both helper copies (97.54% each) and `enforce-pr-author-skill.docs-only.ps1` (100.00%). Its companion `artifacts/pester/pester-junit.xml` reports tests=10606, failures=0, errors=0, which equals the CI total of run `38890377723`. The XML mtime (2026-10-16 06:50:30 -04:00) is after the last code commit `bf3c5e310` (06:20:41 -04:00).
- CR-R1 (closed): `Invoke-DocsOnlyBoundedNative` now disposes the process object in a `finally` block (`.claude/hooks/hook-docs-only-diff.ps1:201-228`), applied byte-identically at the four helper paths, with `Disposed` assertions on every started-process row of both runner suites.

CI run `38890377723` (`workflow_dispatch`, head `7b43fddd5`, whose code equals HEAD for every file of this item) completed with conclusion success on 17 of 17 jobs. The reviewer downloaded and parsed its coverage artifact; per-file figures match the local artifact.

No blocking finding remains. Six criteria (AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24) are CI-dependent and are pending the PR-head CI run, which cannot run until a pull request exists; this is the expected pre-PR state, not a finding.

Overall verdict: **PASS** (0 Blocking findings). Non-blocking observations: 8 (section 8 and the code review).

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the base branch, merge base, head, feature folder, PR context paths, AC source, plans, and the location of the local coverage artifacts; none of these limits the audit to a plan, phase, file subset, or language. The audit covers the full branch diff `5bdf22d0f..d7b4da075`. Python, TypeScript, and C# have zero changed files (`git diff --name-only 5bdf22d0f..HEAD` filtered on `.py`, `.ts`, `.tsx`, `.cs`, `.js`, `.mjs`, `.cjs`, `.sh` returns no path).

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (run in the item worktree) exited 0 with no reported path.
- Branch-diff scan: `git diff --name-only 5bdf22d0f..HEAD -- artifacts/` returned zero paths, so no file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All #927 evidence, including the cycle 2 evidence with the `r2-` prefix, is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | `$global:LASTEXITCODE` and fake-process state are reset per test in the runner suites; the R2 change adds a `Disposed = $false` field to each fresh fake (`hook-docs-only-diff.BoundedNative.Tests.ps1:26`, `codex-hooks/hook-docs-only-diff.Tests.ps1:45`). |
| Isolation | PASS | Each bounded-runner row targets `Invoke-DocsOnlyBoundedNative` or one seam; the process is replaced through the `-ProcessStarter` scriptblock. |
| Fast execution | PASS | No row starts a real process; the fake `Dispose` member is a field assignment (`BoundedNative.Tests.ps1:37`). |
| Determinism | PASS | Timeouts are simulated by fake wait return values; `evidence/qa-gates/r2-qc-test-purity.2026-10-16T10-22.md` records 0 forbidden-construct matches in both edited suites. |
| Readability | PASS | Each new `Disposed` assertion carries a `-Because` text (`BoundedNative.Tests.ps1:85, 104, 118, 137, 165`; `codex-hooks/hook-docs-only-diff.Tests.ps1:215`). |

### 1.2 Coverage requirements

Governing thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults govern (line 85% for new files, modified files, and repo-wide; branch 75% for branch-capable languages). Pester measures no branch coverage, so for PowerShell only the line threshold and the no-regression rule are evaluated.

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- Python baseline coverage artifact: N/A - no Python file changed on the branch.
- Python post-change coverage artifact: N/A - no Python file changed on the branch.
- PowerShell baseline coverage artifact: CI run `38852748136` (artifact `poshqc-test-results`), as parsed in the prior review: repo-wide LINE 16381/18116 (90.42%). The five modified hook files and `config/poshqc-coverage.json` are identical at that run's base `4776ccd93` and at the current merge base `5bdf22d0f` (reviewer `git diff --stat 4776ccd93 5bdf22d0f -- <files>` printed nothing), so the per-file baseline remains valid.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, mtime 2026-10-16 06:50:30 -04:00, after the last code commit `bf3c5e310`. Reviewer parse (JaCoCo `LINE` counters): repo-wide 16644/18426 (90.33%), PASS against the 85% floor. JUnit root: tests=10606, failures=0, errors=0.
- PowerShell corroborating coverage artifact: CI run `38890377723` (head `7b43fddd5`), artifact `poshqc-test-results`, downloaded and parsed by the reviewer: repo-wide LINE 16618/18426 (90.19%); JUnit tests=10606, failures=0, errors=0.
- Per-language comparison summary: PowerShell repo-wide line coverage 90.42% (baseline) to 90.33% (post-change local artifact), both above the floor; the 0.09-point difference is attributable to the newer merge base and to files outside this item, since every changed hook file is at or above its baseline. Python, TypeScript, and C# have zero changed files.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 7 canonical production (2 new helper copies; 5 modified), 7 byte-identical mirrors, 19 Pester suites (6 new, 13 modified) | Local full-population `Invoke-PoshQCTest` (route B); CI `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` on `7b43fddd5` | Local tests=10606, failures=0, errors=0 (reviewer read of the JUnit root); CI tests=10606, failures=0, errors=0; 17 of 17 CI jobs success | 90.42% repo-wide line (16381/18116, CI run 38852748136) | PASS: 90.33% repo-wide line (16644/18426, local artifact); 90.19% in CI run 38890377723 | Helper copies 97.54% line each (119/122); R2 changed executable lines on the canonical helper 14/14 covered |
| Python | 0 | 0 | none | N/A | N/A | N/A |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% repo-wide line (16381/18116, CI run `38852748136`); `enforce-pr-author-skill.docs-only.ps1` 93.44% (57/61), `enforce-pr-author-skill.ps1` 92.98% (53/57), `enforce-epic-merge-gate.ps1` 99.25% (132/133), `enforce-epic-merge-gate-resolution.ps1` 95.24% (40/42), `.codex/hooks/enforce-epic-merge-gate.ps1` 87.90% (138/157); the helper is a new file. Post-change: 90.33% repo-wide line (16644/18426, local artifact, reviewer parse); `.claude/hooks/hook-docs-only-diff.ps1` 97.54% (119/122; missed 188, 305, 349), `.codex/hooks/hook-docs-only-diff.ps1` 97.54% (119/122; missed 188, 217, 305), `enforce-pr-author-skill.docs-only.ps1` 100.00% (54/54), `enforce-pr-author-skill.ps1` 92.98% (53/57), `enforce-epic-merge-gate.ps1` 99.29% (139/140), `enforce-epic-merge-gate-resolution.ps1` 95.65% (44/46), `.codex/hooks/enforce-epic-merge-gate.ps1` 88.41% (145/164). Change: every modified file is at or above its baseline; both new files are above the 85% new-file floor. New/changed-code coverage: 97.54% for each new helper copy and 100.00% (14/14) of the R2 changed executable lines on the canonical helper; in the CI artifact of run `38890377723`, every added executable line of the merge gates has `ci` > 0 except `.codex/hooks/enforce-epic-merge-gate.ps1:403`, the entry-point statement, which was also uncovered at baseline (line 377) and is the exception AC-M24 names; R2 changed executable lines on the canonical helper are 14/14 covered, including `$process.Dispose()` at line 227 (`ci=1`). Disposition: PASS. Evidence: reviewer parse of `artifacts/pester/powershell-coverage.xml` and of the CI artifact of run `38890377723`; `evidence/qa-gates/r2-pa1r-route-b.2026-10-16T10-53.md`; `evidence/qa-gates/r2-coverage-delta.2026-10-16T10-53.md`.

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell | PASS | Coverage PASS: `artifacts/pester/powershell-coverage.xml` reports repo-wide line coverage 90.33% (floor 85%); each new helper copy 97.54% and each modified hook file at or above 88.41% and at or above its baseline; no changed-line regression. |
| Python | N/A | Zero changed files. |
| TypeScript | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

### 1.3 Scenario completeness

| Area | Verdict | Evidence |
|---|---|---|
| Process disposal (CR-R1) | PASS | `Disposed` is asserted on the start-description row, the output-shape rows, the non-zero exit row, the three expiry rows, and the expiry-through-seam row (`BoundedNative.Tests.ps1:85, 104, 118, 137, 165`), and on the Codex-copy runner rows (`codex-hooks/hook-docs-only-diff.Tests.ps1:215`). The start-failure row correctly carries no `Disposed` assertion, because no process object exists. Expect-fail confirmed 14 failing rows before the edit (`evidence/regression-testing/r2-expect-fail.2026-10-16T10-18.md`). |
| Bounded runner, exit-124 propagation, M1 to M9, create side | PASS | Unchanged in R2 apart from the assertions above; all suites pass in the full-population run (tests=10606, failures=0). |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | The R2 change wraps the existing body in `try { ... } finally { $process.Dispose() }`; no new function or parameter. |
| Reusability | PASS | Unchanged: one bounded runner serves both default invokers. |
| File size (500 lines) | PASS | Reviewer `wc -l` at HEAD: helper 484 at both canonical paths; `enforce-epic-merge-gate.ps1` 491; Codex gate 411; largest edited suite `enforce-epic-merge-gate.Tests.ps1` 467; `BoundedNative.Tests.ps1` 194; Codex helper suite 241. |
| Error handling | PASS | Disposal runs on every return path after a successful start, including the expiry path; a start failure still throws to the calling seam before the `try`, so no null dispose occurs. |
| Dependencies | PASS | No new module or package. |
| Public API compatibility | PASS | No parameter or output change in R2. |
| Policy files unchanged | PASS | `git diff --name-only 5bdf22d0f..HEAD -- .claude/rules .github/instructions .claude/settings.json .codex/config.toml .github/workflows config/poshqc-coverage.json` printed nothing. |
| Mirror parity | PASS | Reviewer `git hash-object`: helper `64d472beb` at all four paths; Claude gate `28cfd3bb2`; resolution `e83cd0af5`; docs-only `f3e3300e9`; pr-author `c7c8af60b`; Codex gate `b9ef9c3f8`; each canonical file equals its mirror. |
| Tier classification | PASS | `quality-tiers.yml` exists on the base (`git cat-file -e 5bdf22d0f:quality-tiers.yml`); `.claude/hooks` and `.codex/hooks` are T3, with no property-test or mutation obligation. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Format (PoshQC) | PASS | `evidence/qa-gates/r2-qc-format.2026-10-16T10-21.md`: porcelain status empty before and after; CI `poshqc / PowerShell QC` job success on `7b43fddd5`. |
| PowerShell | Analyzer (PoshQC) | PASS | Local MCP analyze returned with an empty porcelain status (`r2-qc-analyze.2026-10-16T10-22.md`); the MCP result carries no finding count, and the CI `poshqc / PowerShell QC` job, which runs the analyzer, completed with success on `7b43fddd5` (reviewer `gh run view 38890377723`). |
| PowerShell | Advanced functions and comment-based help | PASS | `.DESCRIPTION` of `Invoke-DocsOnlyBoundedNative` adds the disposal statement (`hook-docs-only-diff.ps1:169`). |
| PowerShell | `&`-invoked variables are `[scriptblock]` parameters | PASS | Unchanged (`hook-docs-only-diff.ps1:188`). |
| PowerShell | Enforcement hooks without Python | PASS | Zero Python files in the diff. |
| Python | All requirements | N/A | Zero changed files. |
| TypeScript | All requirements | N/A | Zero changed files. |
| C# | All requirements | N/A | Zero changed files. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Location mirrors source | PASS | Unchanged; R2 edits only existing suites under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`. |
| PowerShell | Mock the wrapper, not the tool | PASS | No `Mock git`, `Mock gh`, or `Start-Process` (`r2-qc-test-purity.2026-10-16T10-22.md`). |
| PowerShell | No temporary files, no sleep or clock APIs | PASS | Same evidence; 0 matches. |
| PowerShell | Epic-state isolation pattern | PASS | Unchanged from the prior review; isolation and guard rows pass in the full-population run. |

## 5. Test Coverage Detail

| Hook file | Status | Baseline line (CI 38852748136) | Local artifact (route B) | CI 38890377723 | Result |
|---|---|---|---|---|---|
| `.claude/hooks/hook-docs-only-diff.ps1` | New | new file | 97.54% (119/122) | 97.54% (119/122) | PASS |
| `.codex/hooks/hook-docs-only-diff.ps1` | New | new file | 97.54% (119/122) | 97.54% (119/122) | PASS |
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | Modified | 93.44% (57/61) | 100.00% (54/54) | 100.00% (54/54) | PASS |
| `.claude/hooks/enforce-pr-author-skill.ps1` | Modified (header only) | 92.98% (53/57) | 92.98% (53/57) | 92.98% (53/57) | PASS |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | Modified | 99.25% (132/133) | 99.29% (139/140) | 99.29% (139/140) | PASS |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | Modified | 95.24% (40/42) | 95.65% (44/46) | 95.65% (44/46) | PASS |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | Modified | 87.90% (138/157) | 88.41% (145/164) | 88.41% (145/164) | PASS (line 403 uncovered, also uncovered at baseline) |
| Bundled mirrors (7 files) | Mirror | byte-identical | byte-identical | byte-identical | PASS |
| Repo-wide PowerShell | - | 90.42% (16381/18116) | 90.33% (16644/18426) | 90.19% (16618/18426) | PASS |

## 6. Test Execution Metrics

| Suite | Runner | Result | Source |
|---|---|---|---|
| Full PowerShell population (R2 route B) | Repository PoshQC module, `Invoke-PoshQCTest` (CI form) | tests=10606, failures=0, errors=0 | `evidence/qa-gates/r2-pa1r-route-b.2026-10-16T10-53.md`; reviewer read of the `artifacts/pester/pester-junit.xml` root |
| Push-down contract pytest | `poetry run pytest ... -q` | passed | `evidence/qa-gates/r2-qc-pytest-contracts.2026-10-16T10-23.md` |
| CI on the last code state | GitHub Actions run `38890377723` (`workflow_dispatch`, head `7b43fddd5`) | 17 of 17 jobs success, including `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` | reviewer `gh run view 38890377723 --json headSha,conclusion,event,status,jobs` |
| PR-head CI | GitHub Actions | not yet run: no pull request exists | `gh pr list --head <branch> --state all` returned `[]` |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Scope (AC-22, AC-M21, AC-M25, AC-16) | `git diff --name-status 5bdf22d0f..HEAD`: no `hook-command-invocation*.ps1`, no `enforce-pr-author-skill-helpers.ps1`, no file under `.claude/rules/`, no archive path; the only `.codex/` files are the gate and the helper; #901 folder entries are all `M`. |
| CR-3 pin (AC-10) | `enforce-pr-author-skill.docs-only.ps1` hash `f3e3300e9`, unchanged since the review that verified the diff argument list. |
| Workflow files | No `.github/workflows/**` path changed. |
| R2 change set | `git show --stat bf3c5e310`: four helper copies (+25/-19 each, identical), two runner suites, and #927 evidence; no other production file. |

## 8. Gaps and Exceptions

No blocking finding.

Non-blocking observations (each listed with file and line; details in `code-review.2026-10-16T11-19.md`):

- PA-N1 (Low, carried CR-R2): `.claude/hooks/hook-docs-only-diff.ps1:188` - the default `-ProcessStarter` is the one runner line no test executes, so real-process tree termination is verified only through the fake. Recorded NO_ACTION with reason in `evidence/other/r2-decisions.2026-10-16T10-21.md`.
- PA-N2 (Info, new): `.codex/hooks/hook-docs-only-diff.ps1:217` - the trailing-LF trim statement is not reached by the Codex-copy suite (`ci=0`), while the Claude copy covers it; whole-file coverage of the Codex copy is 97.54%.
- PA-N3 (Info, new): `.claude/hooks/hook-docs-only-diff.ps1:204-212` with `:226-228` - on the expiry path the asynchronous stdout and stderr reads may still be pending when `Dispose()` runs.
- PA-N4 (Info, new): the local coverage XML was produced at 06:50:30 -04:00, before the merge `d7b4da075` (07:14:19 -04:00); the merge changed no file of this item, and no CI run exists on `d7b4da075`.
- PA-N5 to PA-N8 (Info, carried CR-R3 to CR-R6): `hook-docs-only-diff.ps1:50-56` with `.codex/config.toml:144`; `.codex/hooks/enforce-epic-merge-gate.ps1:403`; `.claude/hooks/enforce-epic-merge-gate.ps1` (491 lines); `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:21-28`.
- Pending CI (not findings): AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24 require the PR-head CI run; the item's orchestrator checks them off at S9. Run `38890377723` supports each.

## 9. Summary of Changes

- Prior scope (unchanged in R2 except as listed): create-side CR-1 and CR-2 hardening, shared helper `hook-docs-only-diff.ps1` with the bounded runner, merge-side docs-only branch in both merge gates, manifest registration, #901 evidence corrections.
- R2 production change: `try { ... } finally { $process.Dispose() }` in `Invoke-DocsOnlyBoundedNative` and one help sentence, at four byte-identical paths.
- R2 test change: `Disposed` field and `Dispose` script method on both fake processes; `Disposed` assertions in five `It` blocks of `BoundedNative.Tests.ps1` (two of them data-driven) and one `It` block of the Codex helper suite.
- R2 evidence: `r2-` files under `evidence/`, including the route A attempt (MCP runner; three files absent from its coverage population) and the route B full-population run that closed PA-1R.

## 10. Compliance Verdict

**PASS** - 0 Blocking findings. 8 non-blocking observations (PA-N1 to PA-N8; CR-R2 to CR-R6 carried, CR-N1 to CR-N3 new in the code review). Six CI-dependent criteria are pending the PR-head CI run.

## Appendix A: Test Inventory

- New: `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (328 lines), `hook-docs-only-diff.MergeExemption.Tests.ps1` (245), `hook-docs-only-diff.BoundedNative.Tests.ps1` (194), `enforce-epic-merge-gate.DocsOnly.Tests.ps1` (199), `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (241), `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (159).
- Modified with new rows: `enforce-pr-author-skill.DocsOnly.Tests.ps1` (243), `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` (261), `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` (163).
- Modified with baseline seam mocks only (+2 lines each): `enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.Coverage.Tests.ps1`, `.ItemResolution.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `hook-command-consumers.Issue824.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`.

## Appendix B: Toolchain Commands Reference

- `git diff --stat 5bdf22d0f..HEAD`; `git diff --name-status 5bdf22d0f..HEAD`; `git log --format="%h %cI %s" 5bdf22d0f..HEAD`
- `git show --stat bf3c5e310`; `git diff bf3c5e310~1 bf3c5e310 -- <helper and runner suites>`; `git diff --name-only bf3c5e310 HEAD -- <item code paths>`
- `git diff --stat 4776ccd93 5bdf22d0f -- <modified hook files> config/poshqc-coverage.json` (baseline validity)
- `git diff -U0 5bdf22d0f HEAD -- <modified hook files>` (changed-line sets)
- `git hash-object` on the seven canonical/mirror pairs and four helper copies; `wc -l` on every changed `.ps1` file
- `gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state all --json number,state,headRefOid`
- `gh run list --branch bug/pr-author-docs-only-exemption-hardening-927`; `gh run view 38890377723 --json headSha,conclusion,event,status,workflowName,jobs`
- `gh run download 38890377723 -n poshqc-test-results -D <scratch>`
- `poetry run python -I <scratch>/cov.py <coverage.xml> <file[:lines]>...` (JaCoCo `LINE` counters per `sourcefile`, report root, and per-line `ci`/`mi`)
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
