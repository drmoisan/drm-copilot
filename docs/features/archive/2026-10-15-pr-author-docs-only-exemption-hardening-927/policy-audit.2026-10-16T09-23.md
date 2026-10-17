# Policy Audit: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T09-23
- Reviewer: feature-review agent (R4 re-audit after remediation cycle 1)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `65c068515b561ba8b965e189d870efbd31fcdb37`
- Base: `main` (resolved `origin/main`); merge-base `4776ccd9366d8f580ac9ac0fe164d75306785218`.
- Diff command: `git diff 4776ccd93..HEAD` (146 files, +12067/-290). Outside `docs/`: 33 files (7 canonical hook files, 7 byte-identical bundle mirrors, 2 pack manifests, 17 Pester suites of which 6 are new). Inside `docs/`: the #927 feature folder and 14 modified files of the #901 folder.
- Last code commit on the branch: `3009f6117` (2026-10-16T04:30:51-04:00). Later branch commits change only files under the #927 feature folder; the merge commit `65c068515` brings in `origin/main` and adds no branch-diff path outside the folder (reviewer `git diff 7966e1564 HEAD` over the changed hook and suite paths lists only files that are not in the branch diff).
- Work mode: `full-bug` (`issue.md` line 9). AC source: `spec.md` `## Acceptance Criteria` only (47 items: AC-M1 to AC-M25, AC-1 to AC-22).
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`.
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` record head `65c068515` and merge base `4776ccd93`, matching this audit; they were not regenerated. No pull request exists for the branch (`gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state all` returned `[]`).
- Prior review: `policy-audit.2026-10-16T05-09.md` (1 blocking finding, PA-1). Remediation plan executed: `remediation-plan.2026-10-16T05-25.md`.

## Executive Summary

Remediation cycle 1 addressed the ten non-blocking observations of the prior review: the docs-only gh and git calls are now time-bounded and deny on expiry (CR-1), the working-directory residual limit is documented in the three headers (CR-2), the non-discriminating `-B=main` row was corrected and new rows added (CR-3, CR-4), Arrange markers were added (CR-9), the duplicate research copy is marked superseded (CR-6), and AC-18 and AC-M23 are marked CI-dependent in spec version 1.3 (CR-10). CR-5 was retained with a recorded reason. The reviewer read the new bounded runner and its suites, re-verified mirror parity and file sizes, and independently parsed both CI coverage artifacts.

One blocking finding remains, and it is the prior finding PA-1 in a changed form:

- PA-1R (Blocking, autonomous): the executor closed PA-1 from the CI artifact of run `38876469175` (decision D-R1-10, "artifacts/pester not regenerated") instead of performing the required direct `Invoke-PoshQCTest -Root <worktree>` run. The contract-designated artifact `artifacts/pester/powershell-coverage.xml` is again a scoped PoshQC MCP output: repo-wide LINE 8128/12298 (66.09%), with no `sourcefile` entry for either helper copy or for `enforce-pr-author-skill.docs-only.ps1`. PowerShell coverage is therefore FAIL under the reviewer contract. The CI artifact, parsed independently by the reviewer, shows that the code itself meets every threshold (repo-wide 90.26%, minimum changed hook file 88.41%), so the remediation is an artifact regeneration with no code change.

Six criteria (AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24) are CI-dependent and remain pending the PR-head CI run; the `workflow_dispatch` run on the last code commit supports each of them.

Overall verdict: **FAIL** (1 Blocking finding, classified autonomous). Non-blocking observations: 6 (section 8 and the code review).

## Rejected Scope Narrowing

The caller prompt contains: "PowerShell evidence in this item follows Option A (PoshQC MCP tools plus CI results); remediation evidence is under the feature folder's evidence/ tree with the `r1-` prefix, including the CI coverage evidence from run 38876469175 on the final code commit."

Justification: this text was not accepted as a substitute for the contract-designated coverage artifact. The reviewer contract names `artifacts/pester/powershell-coverage.xml` as the PowerShell coverage artifact and the `validate-feature-review-coverage` stop hook reads that path, so the PowerShell coverage verdict below is derived from it; the CI artifact is reported as corroborating evidence only. No other narrowing was detected. Python, TypeScript, and C# have zero changed files (`git diff --name-only 4776ccd93..HEAD` filtered on `.py`, `.ts`, `.tsx`, `.cs` returns no path).

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no reported path.
- Branch-diff scan: `git diff --name-only 4776ccd93..HEAD -- artifacts/` returned zero paths, so no file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All #927 evidence, including the remediation evidence with the `r1-` prefix, is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | `$global:LASTEXITCODE` and the fake-process state are reset in `BeforeEach` of the new bounded-runner suite (`hook-docs-only-diff.BoundedNative.Tests.ps1:53-63`); seam mocks remain per test. |
| Isolation | PASS | Each bounded-runner row targets `Invoke-DocsOnlyBoundedNative` or one seam; the default-invoker rows mock `Invoke-DocsOnlyBoundedNative` by name (`BoundedNative.Tests.ps1:162-186`). |
| Fast execution | PASS | No row starts a process: the runner is driven through a test-local `-ProcessStarter` that returns a fake process object (`BoundedNative.Tests.ps1:21-50`). |
| Determinism | PASS | Timeouts are simulated by the fake `WaitForExit` and `Wait` return values; no clock or sleep API is used. `evidence/qa-gates/r1-qc-test-purity.2026-10-16T08-45.md` records 0 forbidden-construct matches over nine suites. |
| Readability | PASS | Arrange markers were added to the rows named in the prior CR-9 (`evidence/regression-testing/r1-arrange-markers.2026-10-16T08-10.md`; reviewer diff confirms). |

### 1.2 Coverage requirements

Governing thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults govern (line 85% for new files, modified files, and repo-wide; branch 75% for branch-capable languages). Pester measures no branch coverage, so only the line threshold and the no-regression rule are evaluated for PowerShell.

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- Python baseline coverage artifact: N/A - no Python file changed on the branch.
- Python post-change coverage artifact: N/A - no Python file changed on the branch.
- PowerShell baseline coverage artifact: merge-base CI run `38852748136` (head `afa951ac0`), artifact `poshqc-test-results`, downloaded by the reviewer to a session scratch directory and parsed: repo-wide LINE 16381/18116 (90.42%). The changed hook files and `config/poshqc-coverage.json` are identical at `afa951ac0` and at the current merge base `4776ccd93` (reviewer `git diff --stat` printed nothing), so this run is a valid baseline for the changed files.
- PowerShell post-change coverage artifact: contract-designated `artifacts/pester/powershell-coverage.xml`, mtime 2026-10-16 04:43:02 -04:00, after the last code commit `3009f6117` (04:30:51 -04:00). Reviewer parse: repo-wide LINE 8128/12298 (66.09%), FAIL against the 85% floor. No `sourcefile` entry exists for `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, or `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. The companion `artifacts/pester/pester-junit.xml` root reports tests=7183 failures=0 errors=0, against 10545 in the full-population CI run, which confirms a scoped population.
- PowerShell corroborating coverage artifact: CI run `38876469175` (`workflow_dispatch`, conclusion success, head `7966e1564`, whose code is identical to `3009f6117`), artifact `poshqc-test-results`, downloaded and parsed by the reviewer: repo-wide LINE 16580/18369 (90.26%).
- Per-language comparison summary: PowerShell repo-wide line 90.42% (baseline CI) to 66.09% in the contract-designated local artifact (FAIL; scoped population) and 90.26% in the corroborating CI artifact. Python, TypeScript, and C# have zero changed files.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 7 canonical production (2 new: the helper at `.claude/hooks` and `.codex/hooks`; 5 modified), 7 byte-identical mirrors, 17 Pester suites (6 new, 11 modified) | Local PoshQC MCP test over the hook suites (loop pass 2); CI `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` on `7966e1564` | Local tests=7183, failures=0, errors=0 (`r1-qc-pester.2026-10-16T08-45.md`; reviewer read of the JUnit root); CI 10545 tests, failures=0, errors=0, all 17 jobs success | 90.42% repo-wide line (16381/18116, CI run 38852748136) | FAIL: 66.09% repo-wide line (8128/12298) in the contract-designated local artifact; corroborating CI artifact 90.26% (16580/18369) | Helper copies 97.52% each (118/121) and changed executable lines 28/29 in the CI artifact; the local artifact does not measure the helper copies or `enforce-pr-author-skill.docs-only.ps1` |
| Python | 0 | 0 | none | N/A | N/A | N/A |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% repo-wide line (16381/18116, CI run `38852748136`); `enforce-pr-author-skill.docs-only.ps1` 93.44% (57/61), `enforce-pr-author-skill.ps1` 92.98% (53/57), `enforce-epic-merge-gate.ps1` 99.25% (132/133), `enforce-epic-merge-gate-resolution.ps1` 95.24% (40/42), `.codex/hooks/enforce-epic-merge-gate.ps1` 87.90% (138/157); the helper is a new file. Post-change: 66.09% repo-wide line (8128/12298, contract-designated local artifact); helper copies and `enforce-pr-author-skill.docs-only.ps1` have no `sourcefile` entry. Corroborating CI artifact (run `38876469175`): 90.26% repo-wide line (16580/18369); `.claude/hooks/hook-docs-only-diff.ps1` 97.52% (118/121; missed lines 187, 299, 343), `.codex/hooks/hook-docs-only-diff.ps1` 97.52% (118/121), `enforce-pr-author-skill.docs-only.ps1` 100.00% (54/54), `enforce-pr-author-skill.ps1` 92.98% (53/57), `enforce-epic-merge-gate.ps1` 99.29% (139/140), `enforce-epic-merge-gate-resolution.ps1` 95.65% (44/46), `.codex/hooks/enforce-epic-merge-gate.ps1` 88.41% (145/164). Change: every pre-existing changed file is at or above its baseline in the CI artifact. New/changed-code coverage: 96.55% (28/29 changed executable lines in the five modified files, CI artifact; changed-line sets from `evidence/qa-gates/r1-ci-coverage.2026-10-16T09-11.md`) plus 97.52% for each new helper copy: docs-only 8/8, Claude gate 8/8, resolution sibling 4/4, Codex gate 8/9, `enforce-pr-author-skill.ps1` header only (0 executable changed lines). The one uncovered changed line, `.codex/hooks/enforce-epic-merge-gate.ps1:403` (entry-point statement, `-RepositoryRoot` argument added), was also uncovered at baseline (same statement at line 377, `ci=0` in run `38852748136`, reviewer parse), so it is not a regression. AC-9 statement lines 78, 79, 82, 84 of `enforce-pr-author-skill.docs-only.ps1` have `ci` 2, 1, 1, 4 in the CI artifact. Disposition: FAIL (PA-1R), because the contract-designated artifact is below the floor and omits two changed files; the CI artifact indicates that a full-population local run would pass. Evidence: reviewer parse of `artifacts/pester/powershell-coverage.xml` and of both CI artifacts; `evidence/qa-gates/r1-ci-coverage.2026-10-16T09-11.md`; `evidence/qa-gates/r1-coverage-delta.2026-10-16T09-11.md`.

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell | FAIL | Coverage FAIL: `artifacts/pester/powershell-coverage.xml` reports repo-wide line 66.09%, below the 85% floor, and has no entry for the new helper (both canonical copies) or for the modified `enforce-pr-author-skill.docs-only.ps1`. The CI artifact of run 38876469175 meets every threshold but is not the contract-designated artifact. PA-1R. |
| Python | N/A | Zero changed files. |
| TypeScript | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

### 1.3 Scenario completeness

| Area | Verdict | Evidence |
|---|---|---|
| Bounded runner (CR-1 remediation) | PASS | `BoundedNative.Tests.ps1`: start description (arguments, working directory, redirection, encoding, both wait limits), output shapes (LF, CRLF, NUL, empty), non-zero exit, three expiry rows (exit wait, output wait, stop failure) asserting exit 124 and no output, start failure through the git seam, expiry through the git seam, and default-invoker routing with 3000 ms and 7000 ms limits. The Codex copy is exercised by `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:197-237`. |
| Exit-124 propagation to the exemption | PASS | `hook-docs-only-diff.MergeExemption.Tests.ps1`: timed-out gh lookup (PR_UNRESOLVED), timed-out base rev-parse (BASE_UNRESOLVED), timed-out diff (DIFF_FAILED). |
| Prior CR-3 and CR-4 gaps | PASS | `enforce-pr-author-skill.DocsOnly.Tests.ps1:71-72` now carry `--base main` with `-B=main` and `-dB=other`; MergeExemption rows added for `--auto=true`, matching and mismatching `--match-head-commit=<oid>`, and a `[]` lookup result. |
| Create side, merge conditions M1 to M9, gate composition | PASS | Unchanged from the prior review except the rows above; suites A 30, B 43, C 14, D 38, E 9, F 13 passed in loop pass 2 (`r1-qc-pester.2026-10-16T08-45.md`). |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | Process start and wait logic is isolated in `Invoke-DocsOnlyBoundedNative` (`hook-docs-only-diff.ps1:155-223`); the seams keep their contract (`ExitCode`, `Output`, never throw). |
| Reusability | PASS | One bounded runner serves both default invokers; the create-side seam stays unbounded by decision D-R1-3 (local git only), consistent with spec Design item 3. |
| File size (500 lines) | PASS | Reviewer `wc -l` at HEAD: largest production file `enforce-epic-merge-gate.ps1` 491; helper 478 at four paths; Codex gate 411; largest test file `enforce-epic-merge-gate.Tests.ps1` 467. |
| Error handling | PASS | Expiry stops the process tree and reports exit 124, which every caller treats as a deny; a failed stop is swallowed with an explicit `$null = $_` and still reports 124; a start failure throws to the seam, which returns its failure object. |
| Dependencies | PASS | Only `System.Diagnostics.Process` from the runtime; no new module or package. |
| Public API compatibility | PASS | `Invoke-DocsOnlyGitExe` and `Invoke-DocsOnlyGhExe` keep their parameters; only the default value of the invoker parameter changed. |
| Policy files unchanged | PASS | `git diff --stat 4776ccd93..HEAD -- .claude/rules .github/instructions .claude/settings.json .codex/config.toml .github/workflows` printed nothing. |
| Mirror parity | PASS | Reviewer `git hash-object`: helper `e04723f27` at four paths; Claude gate `28cfd3bb2`; resolution `e83cd0af5`; docs-only `f3e3300e9`; pr-author `c7c8af60b`; Codex gate `b9ef9c3f8`; each canonical file equals its mirror. |
| Tier classification | PASS | `quality-tiers.yml` exists on the base; `.claude/hooks` and `.codex/hooks` are T3. No property-test or mutation obligation applies to T3. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Format (PoshQC) | PASS | `evidence/qa-gates/r1-qc-format.2026-10-16T08-32.md`: porcelain status empty before and after; CI `Format PowerShell` step success on `7966e1564`. |
| PowerShell | Analyzer (PoshQC) | PASS | Local MCP analyze returned ok=true with an empty porcelain status (`r1-qc-analyze.2026-10-16T08-32.md`); CI `Analyze PowerShell` step success on `7966e1564` (reviewer `gh run view 38876469175`). |
| PowerShell | Advanced functions and comment-based help | PASS | `Invoke-DocsOnlyBoundedNative` carries `[CmdletBinding()]`, `[OutputType([string])]`, and `.SYNOPSIS`/`.DESCRIPTION`/`.PARAMETER`/`.OUTPUTS`. |
| PowerShell | `&`-invoked variables are `[scriptblock]` parameters of the same file | PASS | `$ProcessStarter` is a `[ValidateNotNull()][scriptblock]` parameter (`hook-docs-only-diff.ps1:187`); guard rows J14 pass (`r1-qc-pester.2026-10-16T08-45.md`). |
| PowerShell | Guarded dependency loading | PASS | Unchanged from the prior review (Claude gate line 82, Codex gate line 29). |
| PowerShell | Enforcement hooks without Python | PASS | Zero Python files in the diff. |
| Python | All requirements | N/A | Zero changed files. |
| TypeScript | All requirements | N/A | Zero changed files. |
| C# | All requirements | N/A | Zero changed files. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Location mirrors source | PASS | New suite `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` for `.claude/hooks/hook-docs-only-diff.ps1`. |
| PowerShell | Mock the wrapper, not the tool | PASS | No `Mock git`, `Mock gh`, or `Mock Start-Process`; the process is replaced through the `-ProcessStarter` seam. |
| PowerShell | No temporary files, no sleep or clock APIs | PASS | `r1-qc-test-purity.2026-10-16T08-45.md` (0 matches over nine suites); reviewer read of the new suite. |
| PowerShell | Epic-state isolation pattern | PASS | Isolation rows J15a, J15b, J15c pass; the Codex suite keeps the Claude seam mocks the discovery guard requires (CR-5 retained, D-R1-6). |

## 5. Test Coverage Detail

| Hook file | Status | Baseline line (CI 38852748136) | Contract-designated local XML | Corroborating CI 38876469175 | Changed executable lines covered (CI) |
|---|---|---|---|---|---|
| `.claude/hooks/hook-docs-only-diff.ps1` | New | new file | absent from artifact | 97.52% (118/121) | whole file 97.52% |
| `.codex/hooks/hook-docs-only-diff.ps1` | New | new file | absent from artifact | 97.52% (118/121) | whole file 97.52% |
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | Modified | 93.44% (57/61) | absent from artifact | 100.00% (54/54) | 8/8 |
| `.claude/hooks/enforce-pr-author-skill.ps1` | Modified (header only) | 92.98% (53/57) | 92.98% (53/57) | 92.98% (53/57) | 0 executable changed lines |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | Modified | 99.25% (132/133) | present | 99.29% (139/140) | 8/8 |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | Modified | 95.24% (40/42) | present | 95.65% (44/46) | 4/4 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | Modified | 87.90% (138/157) | 98.78% (162/164) | 88.41% (145/164) | 8/9 (line 403 uncovered, also uncovered at baseline) |
| Bundled mirrors (7 files) | Mirror | byte-identical to source | byte-identical to source | byte-identical to source | mirrors |
| Repo-wide PowerShell | - | 90.42% (16381/18116) | 66.09% (8128/12298), scoped population, FAIL | 90.26% (16580/18369) | - |

## 6. Test Execution Metrics

| Suite | Runner | Result | Source |
|---|---|---|---|
| Hook-family Pester (R1 loop pass 2) | `mcp__drm-copilot__run_poshqc_test` | tests=7183, failures=0, errors=0 | `evidence/qa-gates/r1-qc-pester.2026-10-16T08-45.md`; reviewer read of `artifacts/pester/pester-junit.xml` root |
| Push-down contract pytest | `poetry run pytest ... -q` | 27 passed | `evidence/qa-gates/r1-qc-pytest-contracts.2026-10-16T08-45.md` |
| CI on the last code commit | GitHub Actions run `38876469175` (`workflow_dispatch`, head `7966e1564`) | 17 of 17 jobs success, including `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` | reviewer `gh run view 38876469175 --json headSha,conclusion,event,jobs`; `evidence/qa-gates/r1-ci-jobs.2026-10-16T09-09.md` |
| PR-head CI | GitHub Actions | not run: no pull request exists | `gh pr list --head <branch> --state all` returned `[]` |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Scope (AC-22, AC-M21, AC-M25, AC-16) | `git diff --name-status 4776ccd93..HEAD`: no `hook-command-invocation*.ps1`, no `enforce-pr-author-skill-helpers.ps1`, no file under `.claude/rules/`, no archive path; the only `.codex/` files are the gate and the helper; #901 folder entries are all `M`. |
| CR-3 pin (AC-10) | The create-side diff argument list is unchanged; R1 did not edit `enforce-pr-author-skill.docs-only.ps1` (hash `f3e3300e9`, as in the prior review). |
| Time bound (CR-1) | Worst case one gh call (7000 ms plus 1000 ms) and three git calls (3000 ms plus 1000 ms each) is 20 s, below the Codex registration `timeout = 30`; the Claude registration sets no timeout and uses the runtime default. |
| Workflow files | No `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` path changed. |

## 8. Gaps and Exceptions

- PA-1R (Blocking, autonomous): PowerShell coverage FAIL. `artifacts/pester/powershell-coverage.xml` is a scoped PoshQC MCP output (repo-wide LINE 66.09%; no `sourcefile` for `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, or `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`). The remediation plan's decision D-R1-10 (`evidence/other/r1-decisions.2026-10-16T07-41.md:14`) closed PA-1 from the CI artifact and did not regenerate the local file, which the prior remediation inputs required. Required action: run `Import-Module <worktree>/scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <worktree>` (the CI form at `.github/workflows/_poshqc.yml`) so that the local artifact covers the population of `config/poshqc-coverage.json`, then record the counters in a new `evidence/qa-gates/` file. No code change is indicated: the CI artifact meets every threshold.
- PA-N1 (Non-blocking, Low): `Invoke-DocsOnlyBoundedNative` does not dispose the `Process` object (`hook-docs-only-diff.ps1:199-222`). The hook process exits shortly after, so the handle is released at exit. See code review CR-R1.
- PA-N2 (Non-blocking, Low): the default `-ProcessStarter` (`hook-docs-only-diff.ps1:187`) is the one line no test executes, so the real-process expiry path (tree kill, asynchronous read after kill) is verified only through the fake process object. See code review CR-R2.
- PA-N3 to PA-N6 (Non-blocking, Info): listed with file and line in `code-review.2026-10-16T09-23.md` (CR-R3 to CR-R6).
- Pending CI (not findings): AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24 require the PR-head CI run; the item's orchestrator checks them off at S9. Run `38876469175` on the last code commit supports each.

## 9. Summary of Changes

- Prior scope (unchanged in R1 except as listed): create-side CR-1 and CR-2 hardening, shared helper `hook-docs-only-diff.ps1`, merge-side docs-only branch in both merge gates, manifest registration, #901 evidence corrections.
- R1 production changes: `Invoke-DocsOnlyBoundedNative` added to the helper (+81 lines at four paths); default `-GitInvoker` and `-GhInvoker` route through it with 3000 ms and 7000 ms limits; header residual-limit and time-limit paragraphs in the helper and both merge gates.
- R1 test changes: new suite `hook-docs-only-diff.BoundedNative.Tests.ps1` (188 lines); rows added to `hook-docs-only-diff.MergeExemption.Tests.ps1`, `hook-docs-only-diff.Tests.ps1` (Arrange markers), `codex-hooks/hook-docs-only-diff.Tests.ps1` (Codex-copy runner rows), and `enforce-pr-author-skill.DocsOnly.Tests.ps1` (CR-3).
- R1 documentation: spec version 1.3 (CI-dependent markers on AC-18 and AC-M23; bounded-runner design), superseded-duplicate note in one research copy, R1 evidence under `evidence/`.

## 10. Compliance Verdict

**FAIL** - 1 Blocking finding (PA-1R, autonomous: the contract-designated PowerShell coverage artifact is still scoped and incomplete). 6 non-blocking observations (PA-N1 to PA-N6; CR-R1 to CR-R6 in the code review). Six criteria are pending the PR-head CI run.

## Appendix A: Test Inventory

- New: `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (328 lines), `hook-docs-only-diff.MergeExemption.Tests.ps1` (245), `hook-docs-only-diff.BoundedNative.Tests.ps1` (188), `enforce-epic-merge-gate.DocsOnly.Tests.ps1` (199), `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (239), `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (159).
- Modified with new rows: `enforce-pr-author-skill.DocsOnly.Tests.ps1` (243), `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` (261), `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` (163).
- Modified with baseline seam mocks only (+2 lines each): `enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.Coverage.Tests.ps1`, `.ItemResolution.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `hook-command-consumers.Issue824.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`.

## Appendix B: Toolchain Commands Reference

- `git diff --stat 4776ccd93..HEAD`; `git diff --name-status 4776ccd93..HEAD`; `git log --format="%h %cI %s" 4776ccd93..HEAD`
- `git diff e4521e5a8 7966e1564 -- <hook files and suites>` (R1 changes); `git diff --name-only 3009f6117 7966e1564`
- `git diff --stat afa951ac0 4776ccd93 -- <changed hook files> config/poshqc-coverage.json` (baseline validity)
- `git hash-object` on the seven canonical/mirror pairs and four helper copies; `wc -l` on every changed `.ps1` and `.json` file
- `gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state all --json number,state,headRefOid`
- `gh run view 38876469175 --json headSha,conclusion,event,headBranch,workflowName,jobs`
- `gh run download 38876469175 -n poshqc-test-results -D <scratch>`; `gh run download 38852748136 -n poshqc-test-results -D <scratch>`
- `poetry run python -I <scratch>/cov.py <coverage.xml> <file[:lines]>...` (JaCoCo `LINE` counters per `sourcefile`, report root, and per-line `ci`); `poetry run python -I <scratch>/missed.py <coverage.xml> <file>`
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`
