# Policy Audit: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T12-56
- Reviewer: feature-review agent (R4 re-audit after remediation cycle 3)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `bcdb4c9e0fdd35e279981b60a716a941e56c5882`
- Base: `main` (resolved `origin/main`); merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`. `git rev-list --count HEAD..origin/main` returned 0, so the branch contains every commit of the local `origin/main` ref.
- Diff command: `git diff --shortstat 5bdf22d0f..HEAD` (204 files, +15407/-290). Outside `docs/`: 33 files (7 canonical hook files, 7 byte-identical bundle mirrors, 2 pack manifests, 17 Pester suites of which 6 are new and 11 modified; `git diff --name-status 5bdf22d0f..HEAD -- . ':!docs'` counts 10 `A` and 23 `M`). The prior review stated 19 suites; the current listing has 17, and no suite was removed in cycle 3. Inside `docs/`: the #927 feature folder and 14 modified files of the #901 folder.
- Last code commit on the branch: `f8adac1c9` (2026-10-16T08:11:23-04:00, CR-N1 and CR-N2). The later commits `8259a11df` and `bcdb4c9e0` change only files under the #927 feature folder.
- Work mode: `full-bug` (`issue.md` line 9). AC source: `spec.md` version 1.3, `## Acceptance Criteria` only (47 items: AC-M1 to AC-M25, AC-1 to AC-22).
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`.
- PR context: `artifacts/pr_context.summary.txt` (generated 2026-10-16 12:53:48 UTC) records head `bcdb4c9e0` and merge base `5bdf22d0f`, matching this audit; not regenerated. No pull request exists for the branch (`gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state all` returned `[]`).
- Prior review: `policy-audit.2026-10-16T11-19.md` (PASS, 0 blocking). Remediation plan executed: `remediation-plan.2026-10-16T14-05.md` (cycle 3, inputs `remediation-inputs.2026-10-16T14-05.md`, scope CR-N1 and CR-N2 under orchestrator decision D-RUN-10).

## Executive Summary

Remediation cycle 3 addressed the two non-blocking observations carried into it:

- CR-N1 (closed with a recorded residual): on the expiry path, `Invoke-DocsOnlyBoundedNative` now keeps a reference to the standard error read and checks each read once with `Wait(0)`, inside its own `try`/`catch`, in the fixed order standard output then standard error, before `Dispose()` (`.claude/hooks/hook-docs-only-diff.ps1:204, 212-219`). The exit code 124, the empty output, the wait limits, and the `-ProcessStarter` seam are unchanged. The four helper copies are byte-identical (`7e429ae6c`). An expect-fail run showed four failing ordering rows before the edit (`evidence/regression-testing/r3-expect-fail.2026-10-16T12-09.md`). A read that is still pending at the `Wait(0)` check is not awaited; decision D-R3-1 records this residual (`evidence/qa-gates/r3-remediation-closure.2026-10-16T12-51.md`).
- CR-N2 (closed): a new Codex-copy row with LF-terminated output executes the trim statement, now at `.codex/hooks/hook-docs-only-diff.ps1:226` (`ci=1` in both the local and CI coverage artifacts).

The local PowerShell coverage artifact is a full-population output produced after the last code commit (coverage XML mtime 2026-10-16 08:25:25 -04:00; commit `f8adac1c9` 08:11:23 -04:00). Reviewer parse: repo-wide LINE 16656/18431 (90.37%); JUnit tests=10647, failures=0, errors=0. CI run `38900960142` (`workflow_dispatch`, head `8259a11df`, whose code equals HEAD) completed with conclusion success; its artifact reports tests=10647, failures=0, errors=0, and repo-wide LINE 16643/18431 (90.30%).

No blocking finding remains. Six criteria (AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24) are CI-dependent and pending the PR-head CI run, which cannot run until a pull request exists; this is the expected pre-PR state, not a finding.

Overall verdict: **PASS** (0 Blocking findings). Non-blocking observations: 10 (section 8 and the code review).

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the base branch, merge base, head, feature folder, PR context paths, AC source, plans, and the location of the local coverage artifacts. None of these limits the audit to a plan, phase, file subset, or language, and the reviewer verified the coverage artifacts independently instead of relying on the caller's description. The audit covers the full branch diff `5bdf22d0f..bcdb4c9e0`. Python, TypeScript, and C# have zero changed files (`git diff --name-only 5bdf22d0f..HEAD` filtered on `.py`, `.ts`, `.tsx`, `.cs`, `.js`, `.mjs`, `.cjs`, `.sh` returned no path).

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (run in the item worktree) exited 0 with no reported path.
- Branch-diff scan: `git diff --name-only 5bdf22d0f..HEAD -- artifacts/` returned zero paths, so no file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All #927 evidence, including the cycle 3 evidence with the `r3-` prefix, is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Each runner row builds a fresh fake through `Get-DocsOnlyFakeProcess`; the new `Events` list is created per call (`hook-docs-only-diff.BoundedNative.Tests.ps1:23`), so no event leaks between rows. |
| Isolation | PASS | Each bounded-runner row targets `Invoke-DocsOnlyBoundedNative`; the process is replaced through the `-ProcessStarter` scriptblock. |
| Fast execution | PASS | No row starts a real process; the fake `Wait` and `Dispose` members append to an in-memory list. |
| Determinism | PASS | The read fault is simulated by a `throw` in the fake (`BoundedNative.Tests.ps1:30-32`); `evidence/qa-gates/r3-qc-test-purity.2026-10-16T12-13.md` records 0 forbidden-construct matches in both edited suites. |
| Readability | PASS | Each new ordering assertion carries a `-Because` text (`BoundedNative.Tests.ps1:95, 149`). |

### 1.2 Coverage requirements

Governing thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults govern (line 85% for new files, modified files, and repo-wide; branch 75% for branch-capable languages). Pester measures no branch coverage, so for PowerShell only the line threshold and the no-regression rule are evaluated.

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- Python baseline coverage artifact: N/A - no Python file changed on the branch.
- Python post-change coverage artifact: N/A - no Python file changed on the branch.
- PowerShell baseline coverage artifact: CI run `38852748136` (artifact `poshqc-test-results`) for the merge base, as parsed in the prior reviews: repo-wide LINE 16381/18116 (90.42%), with per-file figures for the five modified hook files. Cycle 3 baseline: the prior review's local full-population artifact, repo-wide LINE 16644/18426 (90.33%), helper copies 97.54% each (`evidence/remediation-baseline/r3-coverage-baseline.2026-10-16T11-57.md`).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, mtime 2026-10-16 08:25:25 -04:00, after the last code commit `f8adac1c9` (08:11:23 -04:00). Reviewer parse (JaCoCo `LINE` counters): repo-wide 16656/18431 (90.37%), PASS against the 85% floor. JUnit root of `artifacts/pester/pester-junit.xml`: tests=10647, failures=0, errors=0.
- PowerShell corroborating coverage artifact: CI run `38900960142` (head `8259a11df`), artifact `poshqc-test-results`, downloaded and parsed by the reviewer: repo-wide LINE 16643/18431 (90.30%); JUnit tests=10647, failures=0, errors=0. Per-file figures for the seven changed hook files equal the local artifact.
- Per-language comparison summary: PowerShell repo-wide line coverage 90.42% (merge-base CI baseline) and 90.33% (cycle 3 baseline) to 90.37% (post-change local artifact), all above the floor; every changed hook file is at or above its baseline. Python, TypeScript, and C# have zero changed files.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 7 canonical production (2 new helper copies; 5 modified), 7 byte-identical mirrors, 17 Pester suites (6 new, 11 modified) | Local full-population `Invoke-PoshQCTest` (route B); CI `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` on `8259a11df` | Local tests=10647, failures=0, errors=0 (reviewer read of the JUnit root); CI tests=10647, failures=0, errors=0; 17 of 17 CI jobs success | 90.42% repo-wide line (16381/18116, CI run 38852748136); cycle 3 baseline 90.33% | PASS: 90.37% repo-wide line (16656/18431, local artifact); 90.30% in CI run 38900960142 | Helper copies 97.60% line each (122/125); cycle 3 changed executable lines on the canonical helper 4/4 covered |
| Python | 0 | 0 | none | N/A | N/A | N/A |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% repo-wide line (16381/18116, CI run `38852748136`); `enforce-pr-author-skill.docs-only.ps1` 93.44% (57/61), `enforce-pr-author-skill.ps1` 92.98% (53/57), `enforce-epic-merge-gate.ps1` 99.25% (132/133), `enforce-epic-merge-gate-resolution.ps1` 95.24% (40/42), `.codex/hooks/enforce-epic-merge-gate.ps1` 87.90% (138/157); the helper is a new file (cycle 3 baseline 97.54% per copy). Post-change: 90.37% repo-wide line (16656/18431, local artifact, reviewer parse); `.claude/hooks/hook-docs-only-diff.ps1` 97.60% (122/125; missed 189, 314, 358), `.codex/hooks/hook-docs-only-diff.ps1` 97.60% (122/125; missed 189, 217, 314), `enforce-pr-author-skill.docs-only.ps1` 100.00% (54/54), `enforce-pr-author-skill.ps1` 92.98% (53/57), `enforce-epic-merge-gate.ps1` 99.29% (139/140), `enforce-epic-merge-gate-resolution.ps1` 95.65% (44/46), `.codex/hooks/enforce-epic-merge-gate.ps1` 88.41% (145/164). Change: every modified file is at or above its baseline; both new files are above the 85% new-file floor and above their cycle 3 baseline. New/changed-code coverage: 97.60% for each new helper copy and 100.00% (4/4) of the cycle 3 changed executable lines on the canonical helper (line 204 `ci=1`, 212 `ci=2`, 214 `ci=1`, 217 `ci=1`); on the Codex copy the catch body at line 217 is `ci=0` (the Codex-copy suite has no faulting-read row; the byte-identical statement is covered on the Claude copy); the trim statement at Codex line 226 is `ci=1`. In the CI artifact of run `38900960142`, every added executable line of the merge gates has `ci` > 0 except `.codex/hooks/enforce-epic-merge-gate.ps1:403`, the entry-point statement that AC-M24 names as the exception and that was also uncovered at baseline. Disposition: PASS. Evidence: reviewer parse of `artifacts/pester/powershell-coverage.xml` and of the CI artifact of run `38900960142`; `evidence/qa-gates/r3-pester-route-b.2026-10-16T12-28.md`; `evidence/qa-gates/r3-coverage-delta.2026-10-16T12-29.md`.

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell | PASS | Coverage PASS: `artifacts/pester/powershell-coverage.xml` reports repo-wide line coverage 90.37% (floor 85%); each new helper copy 97.60%; each modified hook file at or above 88.41% and at or above its baseline; no changed-line regression. |
| Python | N/A | Zero changed files. |
| TypeScript | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

### 1.3 Scenario completeness

| Area | Verdict | Evidence |
|---|---|---|
| Read checks before disposal (CR-N1) | PASS | Ordering rows for the exit-wait expiry, the output-wait expiry, the throwing `Kill`, and a faulting read check (`BoundedNative.Tests.ps1:131-150`), plus a negative ordering assertion on the normal path showing no `Wait(0)` check occurs when no wait expires (`BoundedNative.Tests.ps1:95`). Expect-fail: rows F7, F8, F9, and F14 failed before the helper edit and pass after. |
| Codex-copy trim (CR-N2) | PASS | Row `the process emits LF-terminated lines` (`codex-hooks/hook-docs-only-diff.Tests.ps1:204`); Codex line 226 `ci=1`. |
| Bounded runner, exit-124 propagation, M1 to M9, create side | PASS | Unchanged in cycle 3; all suites pass in the full-population run (tests=10647, failures=0). |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | Cycle 3 adds one variable and one eight-line loop in the existing expiry branch; no new function or parameter. |
| Reusability | PASS | Unchanged: one bounded runner serves both default invokers. |
| File size (500 lines) | PASS | Reviewer `wc -l` at HEAD: helper 493 at all four paths; `enforce-epic-merge-gate.ps1` 491; Codex gate 411; largest edited suite `enforce-epic-merge-gate.Tests.ps1` 467; `BoundedNative.Tests.ps1` 206; Codex helper suite 243. The helper headroom is recorded as a non-blocking observation. |
| Error handling | PASS | Each read check is wrapped in its own `try`/`catch` whose catch assigns `$null = $_`; the decision on the expiry path is still deny (124, no output). Broad catches are acceptable here because they guard best-effort cleanup on a path that already denies; the residual is recorded in D-R3-1. |
| Dependencies | PASS | No new module or package. |
| Public API compatibility | PASS | No parameter or output change in cycle 3. |
| Policy files unchanged | PASS | `git diff --name-only 5bdf22d0f..HEAD -- .claude/rules .github/instructions .claude/settings.json .codex/config.toml .github/workflows config/poshqc-coverage.json` printed nothing. |
| Mirror parity | PASS | Reviewer `git hash-object`: helper `7e429ae6c` at all four paths; Claude gate `28cfd3bb2`; resolution `e83cd0af5`; docs-only `f3e3300e9`; pr-author `c7c8af60b`; Codex gate `b9ef9c3f8`; each canonical file equals its mirror. |
| Tier classification | PASS | `quality-tiers.yml` exists on the base; `.claude/hooks` and `.codex/hooks` are T3, with no property-test or mutation obligation. CI `tier-classification` steps succeeded in run `38900960142`. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Format (PoshQC) | PASS | `evidence/qa-gates/r3-qc-format.2026-10-16T12-11.md`; CI `poshqc / PowerShell QC` step `Format PowerShell` success on `8259a11df` (`r3-ci-jobs.2026-10-16T12-49.md`). |
| PowerShell | Analyzer (PoshQC) | PASS | `evidence/qa-gates/r3-qc-analyze.2026-10-16T12-12.md`; the MCP result carries no finding count, and the CI `Analyze PowerShell` step completed with success on `8259a11df` (reviewer `gh run view 38900960142`: conclusion success). |
| PowerShell | Advanced functions and comment-based help | PASS | `.DESCRIPTION` of `Invoke-DocsOnlyBoundedNative` adds "After an expired wait, each read is checked once without waiting before disposal." (`hook-docs-only-diff.ps1:170`), which describes the code accurately. |
| PowerShell | `&`-invoked variables are `[scriptblock]` parameters | PASS | Unchanged (`hook-docs-only-diff.ps1:189`). |
| PowerShell | Enforcement hooks without Python | PASS | Zero Python files in the diff. |
| Python | All requirements | N/A | Zero changed files. |
| TypeScript | All requirements | N/A | Zero changed files. |
| C# | All requirements | N/A | Zero changed files. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Location mirrors source | PASS | Cycle 3 edits only existing suites under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`. |
| PowerShell | Mock the wrapper, not the tool | PASS | No `Mock git`, `Mock gh`, or `Start-Process` (`r3-qc-test-purity.2026-10-16T12-13.md`). |
| PowerShell | No temporary files, no sleep or clock APIs | PASS | Same evidence; 0 matches. |
| PowerShell | Epic-state isolation pattern | PASS | Unchanged; isolation and guard rows pass in the full-population run. |

## 5. Test Coverage Detail

| Hook file | Status | Baseline line (CI 38852748136) | Local artifact (route B) | CI 38900960142 | Result |
|---|---|---|---|---|---|
| `.claude/hooks/hook-docs-only-diff.ps1` | New | new file (cycle 3 baseline 97.54%) | 97.60% (122/125) | 97.60% (122/125) | PASS |
| `.codex/hooks/hook-docs-only-diff.ps1` | New | new file (cycle 3 baseline 97.54%) | 97.60% (122/125) | 97.60% (122/125) | PASS |
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | Modified | 93.44% (57/61) | 100.00% (54/54) | 100.00% (54/54) | PASS |
| `.claude/hooks/enforce-pr-author-skill.ps1` | Modified (header only) | 92.98% (53/57) | 92.98% (53/57) | 92.98% (53/57) | PASS |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | Modified | 99.25% (132/133) | 99.29% (139/140) | 99.29% (139/140) | PASS |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | Modified | 95.24% (40/42) | 95.65% (44/46) | 95.65% (44/46) | PASS |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | Modified | 87.90% (138/157) | 88.41% (145/164) | 88.41% (145/164) | PASS (line 403 uncovered, also uncovered at baseline) |
| Bundled mirrors (7 files) | Mirror | byte-identical | byte-identical | byte-identical | PASS |
| Repo-wide PowerShell | - | 90.42% (16381/18116) | 90.37% (16656/18431) | 90.30% (16643/18431) | PASS |

## 6. Test Execution Metrics

| Suite | Runner | Result | Source |
|---|---|---|---|
| Full PowerShell population (cycle 3 route B) | Repository PoshQC module, `Invoke-PoshQCTest` (CI form) | tests=10647, failures=0, errors=0 | `evidence/qa-gates/r3-pester-route-b.2026-10-16T12-28.md`; reviewer read of the `artifacts/pester/pester-junit.xml` root |
| Expect-fail before the helper edit | PoshQC MCP test over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` | tests=6514, failures=4 (F7, F8, F9, F14), errors=0 | `evidence/regression-testing/r3-expect-fail.2026-10-16T12-09.md` |
| Push-down contract pytest | `poetry run pytest ... -q` | passed | `evidence/qa-gates/r3-qc-pytest-contracts.2026-10-16T12-13.md` |
| CI on the last code state | GitHub Actions run `38900960142` (`workflow_dispatch`, head `8259a11df`) | 17 of 17 jobs success, including `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` | reviewer `gh run view 38900960142 --json headSha,conclusion,event,status,workflowName`; `evidence/qa-gates/r3-ci-jobs.2026-10-16T12-49.md` |
| PR-head CI | GitHub Actions | not yet run: no pull request exists | `gh pr list --head <branch> --state all` returned `[]` |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Scope (AC-22, AC-M21, AC-M25, AC-16) | `git diff --name-status 5bdf22d0f..HEAD`: no `hook-command-invocation*.ps1`, no `enforce-pr-author-skill-helpers.ps1`, no file under `.claude/rules/`, no archive path; the only `.codex/` files are the gate and the helper; #901 folder entries are 14 `M` only. |
| CR-3 pin (AC-10) | `enforce-pr-author-skill.docs-only.ps1` hash `f3e3300e9`, unchanged since the review that verified the diff argument list. |
| Workflow files | No `.github/workflows/**` path changed. |
| Cycle 3 change set | `git diff --stat d7b4da075..HEAD -- . ':!docs'`: four helper copies (+10/-1 each, identical), `BoundedNative.Tests.ps1` (+24/-10), Codex helper suite (+8/-6); no other production file. |

## 8. Gaps and Exceptions

No blocking finding.

Non-blocking observations (each listed with file and line; details in `code-review.2026-10-16T12-56.md`):

- PA-N1 (Low, carried CR-R2): `.claude/hooks/hook-docs-only-diff.ps1:189` - the default `-ProcessStarter` is the one runner line no test executes, so real-process tree termination, disposal, and the new read checks are verified only through the fake.
- PA-N2 (Low, new CR-N4): `.claude/hooks/hook-docs-only-diff.ps1` (493 lines at all four paths) - 7 lines below the 500-line limit; cycle 3 added 9 lines.
- PA-N3 (Info, new CR-N5): `.claude/hooks/hook-docs-only-diff.ps1:212-219` - `Wait(0)` observes a read that has already completed or faulted, but a read still pending at the check is abandoned and a later fault after `Dispose()` is not observed. Recorded by the executor as decision D-R3-1. The commit subject of `f8adac1c9` ("settle output reads before disposal") describes more than the code does; the help text at line 170 is accurate.
- PA-N4 (Info, new CR-N6): `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1:24-33, 135` - only the standard error fake can fault, so no row shows that a fault in the first read check (standard output) still lets the second check and `Dispose()` run.
- PA-N5 (Info, new CR-N7): `.codex/hooks/hook-docs-only-diff.ps1:217` - the catch body of the read check is `ci=0` on the Codex copy (the Codex suite has no faulting-read row); the Claude copy covers the identical statement. This replaces CR-N2's per-path gap at a different statement.
- PA-N6 (Info, new CR-N8): `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-inputs.2026-10-16T14-05.md` and `remediation-plan.2026-10-16T14-05.md` - the filename timestamp 14-05 is later than the commit that added them (`bcdc59909`, 11:52 UTC), so these cycle 3 inputs sort after this review set (12-56). Tooling that selects the newest artifact by filename should not treat them as later than this review.
- PA-N7 to PA-N10 (Info, carried CR-R3 to CR-R6): `.claude/hooks/hook-docs-only-diff.ps1:50-56` with `.codex/config.toml:144`; `.codex/hooks/enforce-epic-merge-gate.ps1:403`; `.claude/hooks/enforce-epic-merge-gate.ps1` (491 lines); `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:21-28`.
- Closed since the prior review: CR-N1 (with residual PA-N3), CR-N2, and CR-N3 (the local coverage XML now postdates the last code commit, and no merge followed it).
- Pending CI (not findings): AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24 require the PR-head CI run; the item's orchestrator checks them off at S9. Run `38900960142` supports each.

## 9. Summary of Changes

- Prior scope (unchanged in cycle 3 except as listed): create-side CR-1 and CR-2 hardening, shared helper `hook-docs-only-diff.ps1` with the bounded runner and process disposal, merge-side docs-only branch in both merge gates, manifest registration, #901 evidence corrections.
- Cycle 3 production change: the standard error read is kept in `$errorRead`; on the expiry path each of `$output` and `$errorRead` is checked once with `Wait(0)` inside `try`/`catch` before `Dispose()`; one help sentence; at four byte-identical paths.
- Cycle 3 test change: the Claude-copy fake records `output-wait`, `error-wait`, and `dispose` events in order and can fault the standard error check; four expiry rows assert the exact order; the normal-path row asserts that no zero-wait check occurs; the Codex-copy fake gains an error-read `Wait` member and an LF-terminated output row.
- Cycle 3 evidence: `r3-` files under `evidence/`, including the expect-fail run, the route B full-population run, the coverage delta, CI run `38900960142`, and the remediation closure.

## 10. Compliance Verdict

**PASS** - 0 Blocking findings. 10 non-blocking observations (PA-N1 to PA-N10). Six CI-dependent criteria are pending the PR-head CI run.

## Appendix A: Test Inventory

- New: `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (328 lines), `hook-docs-only-diff.MergeExemption.Tests.ps1` (245), `hook-docs-only-diff.BoundedNative.Tests.ps1` (206), `enforce-epic-merge-gate.DocsOnly.Tests.ps1` (199), `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (243), `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (159).
- Modified with new rows: `enforce-pr-author-skill.DocsOnly.Tests.ps1` (243), `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` (261), `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` (163).
- Modified with baseline seam mocks only: `enforce-epic-merge-gate.Tests.ps1` (467), `.Authorization.Tests.ps1` (183), `.Coverage.Tests.ps1` (45), `.ItemResolution.Tests.ps1` (311), `.TriggerScoping.Tests.ps1` (189), `.WorktreeResolution.Tests.ps1` (257), `hook-command-consumers.Issue824.Tests.ps1` (130), `hook-command-parser.AcceptanceCases.Tests.ps1` (232).

## Appendix B: Toolchain Commands Reference

- `git diff --shortstat 5bdf22d0f..HEAD`; `git diff --name-status 5bdf22d0f..HEAD -- . ':!docs'`; `git log --format="%h %cI %s" d7b4da075..HEAD`; `git rev-list --count HEAD..origin/main`
- `git diff d7b4da075..HEAD -- . ':!docs'` (cycle 3 code delta)
- `git hash-object` on the seven canonical/mirror pairs and four helper copies; `wc -l` on every changed `.ps1` file
- `gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state all --json number,state,headRefOid`
- `gh run view 38900960142 --json headSha,conclusion,event,status,workflowName`
- `gh run download 38900960142 -n poshqc-test-results -D <scratch>`
- `poetry run python -I <scratch>/cov.py <coverage.xml> <file[:lines]>...` (JaCoCo `LINE` counters per `sourcefile`, report root, and per-line `ci`/`mi`)
- `grep -m1 -o -E '<testsuites [^>]*>' artifacts/pester/pester-junit.xml`; `stat -c '%y %n' artifacts/pester/*.xml`
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
