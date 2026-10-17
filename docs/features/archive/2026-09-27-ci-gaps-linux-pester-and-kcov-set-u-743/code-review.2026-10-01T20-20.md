# Code Review: CI gaps - Linux Pester hook-suite job and kcov set -u trace simulation (#743)

---

**Review Date:** 2026-10-01
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743`
**Feature Folder Selection Rule:** The only active feature folder whose suffix matches issue #743 in the branch name; also named by the caller.
**Base Branch:** `main` (`origin/main` @ `41217012d31d35c2ee33a50be50684affd2f5f43`, equal to the merge base)
**Head Branch:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743` @ `acb17443e5c7bf3c8a51ffb328fd1780190d612c`
**Review Type:** Re-review after remediation cycle 1 (prior review `code-review.2026-10-01T18-07.md`)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`

---

## Executive Summary

The full branch diff against `main` is 18 non-documentation files, +272/-35. This re-review covers that whole diff, and it gives the remediation delta (`630237f4..acb17443`) a line-by-line read. The delta is five hook-suite test files with +16/-10 lines. Each now chooses its synthetic root from `$IsWindows` instead of hard-coding `C:/...`. Evidence reviewed: the PR context summary and appendix (generated for head `acb17443`), the executor's remediation evidence, and CI run 36918378249. This review queried that run directly with `gh`. It is the latest run on the branch, and its head `42db4491` differs from the branch head only in feature-folder documents.

**What changed (remediation cycle 1):**
- `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` defines `$script:SyntheticWorktree` in `BeforeAll` and uses it in the checkpoint JSON builder and at four `Test-ParallelDriftFindingPresent` call sites. The `-ForEach` row "a blank feature folder" computes the same value inline, because Pester evaluates `-ForEach` data during discovery, before `BeforeAll` runs.
- The four batch-budget routing suites (`enforce-powershell-…`, `enforce-python-…`, `codex-powershell-…`, `codex-python-…`) compute `$absentRoot` inside the "checkpoint file is absent" test and pass it as `-Root`.

**Top 3 risks:**
1. The actionlint wrapper `scripts/dev-tools/run-actionlint.ps1`, named by AC-5 and AC-21, is still unrun. The risk is procedural. Direct `actionlint` is clean, and no workflow file changed in this cycle.
2. Many hook-suite tests still hold `C:/` or `C:\` literals that never reach a drive lookup. A future change that passes one of them to `Join-Path`, `Resolve-Path`, or `Test-Path` without a mock would fail only on Linux. The new Linux job would now catch that.
3. `poshqc / PowerShell hook suites (Linux)` is not a required check (orchestrator decision 2), so a future red Linux run would not block a merge mechanically. A follow-up is recorded in `spec.md` Rollout & Follow-up.

**PR readiness recommendation:** **Approve after operator action**. The code is correct and CI is green. Merge waits only on the operator-run actionlint wrapper record for AC-5 and AC-21.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.github/workflows/_poshqc.yml` | AC-5 / AC-21 | `scripts/dev-tools/run-actionlint.ps1`, named by AC-5 and AC-21, has not been run. The executor recorded it as an operator-run item. Direct `actionlint` reports no findings in four recorded runs, the latest at `qc-actionlint-direct.2026-10-01T19-58.md`. | The operator runs `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`, and the command, exit code, and output are recorded under `evidence/qa-gates/`. | The AC names the wrapper explicitly. Under the 2026-10-01 operator decision, agents cannot run it. Carried from the prior review (R4). | `evidence/other/operator-run-items.2026-10-01T20-27.md` |
| Info | `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | line 340 (`-ForEach` row) | The OS-derived expression is duplicated inline instead of reusing `$script:SyntheticWorktree`. The duplication is required. `-ForEach` data is evaluated during Pester discovery, when `BeforeAll` has not yet run and `$script:SyntheticWorktree` is `$null`. | None required. To remove the duplication, define the value once in a `BeforeDiscovery` block and pass it into `BeforeAll`. | Pester 5 discovery/run separation. | File inspection; Linux suite `tests=48 failures=0` |
| Info | four routing suites | `enforce-powershell-batch-budget-routing.Tests.ps1:297`, `enforce-python-batch-budget-routing.Tests.ps1:298`, `codex-powershell-batch-budget-routing.Tests.ps1:298`, `codex-python-batch-budget-routing.Tests.ps1:295` | Each file has the same one-line `$absentRoot` expression. | None. The repetition is one line per file, and each suite stays self-contained. | Matches the pattern at `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1:47-51`. | Diff `630237f4..HEAD` |
| Info | `tests/scripts/claude-hooks/`, `tests/scripts/codex-hooks/` | 67 lines | 67 lines hold a quoted `C:/` or `C:\` literal without `IsWindows` on the same line. They are inert today: the Linux job passes 3412 of 3412 tests. | No action in this feature. Consider including them in the recorded `tests/scripts/claude-lib/**` Linux follow-up. | Prevents a future Linux-only regression when such a literal starts reaching a filesystem cmdlet. | `grep -rn -E "['\"]C:[\\/]" tests/scripts/claude-hooks tests/scripts/codex-hooks \| grep -v -c IsWindows` |
| Info | `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` | whole file | 495 lines, 5 below the 500-line limit. Unchanged in this cycle. | Pair any later edit that adds lines with a split. | The file-size policy applies to test files. | `wc -l` |
| Info | `artifacts/pester/powershell-coverage.xml` | report-level `LINE` counter | The local MCP run reports covered 10688 of 11104 lines (96.25%), and CI reports 11236 of 11666 (96.31%). | No action in this feature (open issue #527). | Both values are above 85%. | `grep -o '<counter type="LINE"[^>]*>' artifacts/pester/powershell-coverage.xml \| tail -1` |

One Major finding (operator-run item; no code change required) and five Info findings. The three Blockers and one Minor from the prior review are resolved:

- Prior Blocker, `enforce-parallel-drift-gate.Tests.ps1` 8 Linux failures: resolved. Linux suite `tests=48 failures=0`.
- Prior Blocker, four routing suites: resolved. Suites `tests=47`, `32`, `49`, `34`, all `failures=0` on Linux.
- Prior Blocker, `modified-workflow-needs-green-run`: resolved. Run 36918378249 `success`.
- Prior Minor, AC-15 command reproducibility: resolved. `qc-shell-qc-test-full.2026-10-01T19-57.md` records `SHELL_QC_BATS_BIN=<npm-cache>/.../bats sh scripts/bash/shell-qc.sh test`.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fix is at the cause. Before it, the routing tests threw `DriveNotFoundException` on Linux before reaching the absent-checkpoint path, so the behavior under test never ran there. With a `/`-rooted absent path, the default reader now takes the "file absent" branch on both hosts. Both hosts assert the same outcome (`deny`, `*_LARGE_PATH_REQUIRED:*`).
- No production hook script was edited, and no assertion was weakened or skipped. This review counted added `-Skip` and `Set-ItResult` lines in the hook-suite diff: 0.
- The drift-gate change keeps the JSON built by concatenation, so no format-string brace escaping is needed. A `/`-rooted value needs no JSON escaping.
- Commit hygiene: two focused `test(743)` commits (`19bb587a`, `463d8791`), each limited to the files its subject names.

#### API and safety notes

- No production PowerShell file, function, or parameter changed. CI `Analyze PowerShell`: `PSScriptAnalyzer passed: no findings`.

#### Error handling and logging

- Unchanged. `Run.Exit = $true` in the Linux job still fails the job on any failed test.

### Bash implementation audit

#### What changed well

- No Bash file changed in this cycle. The prior review's assessment stands. `kcov_trace_env.sh` mirrors kcov v43's PS4. `run_test` resolves the file absolutely and discards trace output on a `/dev/null` descriptor. `run_test_coverage` is untouched.

#### Error handling and logging

- Max-exit semantics and skip markers are unchanged.

### GitHub Actions implementation audit

- No workflow file changed in this cycle. The new `poshqc-linux-hooks` job is least-privilege (`contents: read`), and its upload step uses `if: always()`. Its first fully green run is 36918378249 (job 110557965901, `Tests Passed: 3412, Failed: 0`).

---

## Test Quality Audit

The remediation has fail-before evidence (`regression-testing/linux-baseline-junit.2026-10-01T19-01.md`, 12 failures) and pass-after evidence (`qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md`, `tests=3412 failures=0 errors=0`). Each changed file also has per-phase local evidence: absence checks (`p1-t2-json-root-absent…`, `p2-t*-…-absent…`), MCP format and analyze, and MCP test.

### Reviewed test and QA artifacts

- `evidence/qa-gates/ci-remediation-conclusions.2026-10-01T20-21.md`: all 17 jobs `success`. This review re-queried the run and confirmed the result.
- `evidence/qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md`: 135 suites, 0 failures. Per-suite counts for the five remediated files and the three cycle-0 Codex files.
- `evidence/qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md`: `tests=6101 failures=0`; PowerShell line coverage 96.31%.
- `evidence/qa-gates/linux-first-run-failures.2026-10-01T20-26.md`: 21 inventory rows, each with a fix and status PASSING.
- `evidence/qa-gates/ci-remediation-further-failures.2026-10-01T20-24.md`: `FURTHER-FAILURES: NONE`, so the contingency was not needed.
- `evidence/qa-gates/qc-loop-pass.2026-10-01T20-00.md`: one clean pass, with file hashes unchanged across the pass.

### Quality assessment prompts

- **Determinism:** Inputs derive from `$IsWindows`, so there is one value per host.
- **Isolation:** Filesystem access in the presence tests is mocked. The absent-root test relies on a path that does not exist on either host.
- **Speed:** No change.
- **Diagnostics:** The existing assertion messages are unchanged.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no tokens, keys, or credentials. |
| No unsafe subprocess or command construction | ✅ PASS | No new process invocation in this cycle. |
| Input validation at boundaries | N/A | No new external input surface. |
| Error handling remains explicit | ✅ PASS | Assertions unchanged; no skip added. |
| Configuration / path handling is safe | ✅ PASS | Synthetic paths are never created. `/synthetic-absent-root` and `/worktrees/alpha` do not exist on GitHub-hosted Ubuntu runners, as the test premise requires. |

---

## Research Log

No external research was performed. The Pester discovery-time evaluation of `-ForEach` data is standard Pester 5 behavior. It is consistent with the CI result: the "a blank feature folder" row passes on Linux.

---

## Verdict

The remediation is correct, minimal, and consistent with the pattern already on the branch. Every Linux-only failure is fixed at its cause, with no skips and no production edits. Both `poshqc` jobs and the shell-coverage job are green on a SHA that differs from the head only in documents. Coverage is unchanged at 96.31% (PowerShell) and 93.7% (Bash).

One Major item remains, and it is not a code defect. The operator must run and record `scripts/dev-tools/run-actionlint.ps1` for `.github/workflows/_poshqc.yml` to close AC-5 and AC-21. No further code change is expected.
