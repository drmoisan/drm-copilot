# Code Review: run-actionlint Test Process-State Leak (#1066)

---

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066`
**Feature Folder Selection Rule:** the single active folder whose name carries the canonical issue number 1066; no version subfolder exists.
**Base Branch:** `main` (merge base `a7c91431b0cdbedf60a80748e03934fdbc7a676e`)
**Head Branch:** `bug/test-path-leak-run-actionlint` at `c97a2ed99d8a6b872320f2ee584a17f1fc6ca1e1`
**Review Type:** First full review (execution-time cycle 1 inputs `remediation-inputs.2026-11-04T01-03.md` were raised by the executor)

---

## Executive Summary

The branch removes a test-order dependence from `tests/scripts/dev-tools/run-actionlint.Tests.ps1` and adds a regression guard. The full diff is 64 files (+6113/-13); 2 are PowerShell test files and the rest are feature-folder Markdown.

- `run-actionlint.Tests.ps1`: a Describe-level `BeforeEach`/`AfterEach` saves and restores `$env:PATH` and `$global:LASTEXITCODE`, each with its existence, so every Context is covered and the `$env:PATH = ''` case (which removes the variable on PowerShell 7) is restored correctly. The `AfterEach` uses only assignments, `[System.Environment]::SetEnvironmentVariable`, and `Remove-Variable`, because the `Install-Actionlint` Context mocks `Test-Path`, `Join-Path`, `Remove-Item`, `New-Item`, and `Write-Information`. The TestHelpers dot-source moved from file scope into `BeforeAll`, so the existence check for `Import-ScriptFunction` runs before the dot-source rather than after discovery. `AfterAll` removes `Import-ScriptFunction` and `Microsoft.PowerShell.Archive` only when they were absent at `BeforeAll`.
- `run-actionlint.EnvironmentIsolation.Tests.ps1` (new): runs the target through a nested in-process `Invoke-Pester` (verbosity None, no result file, no coverage) and asserts that the full environment (case-insensitive keys, ordinal values), `$global:LASTEXITCODE` (via a sentinel container and a probe container, with a control precondition), and the function and module sets are unchanged. Each assertion has fail-before evidence.

Evidence reviewed: the full branch diff, the PR context summary (generated 2026-11-04 02:25:08 UTC at the head SHA), the feature evidence, and the coverage artifacts under `artifacts/pester/`. This review re-ran Invoke-Formatter and PSScriptAnalyzer (0 changes, 0 findings), `Invoke-Pester` over both suites in one process (39/39; afterwards PATH byte-identical, `Import-ScriptFunction` absent, Archive module not loaded), the logical line counts, the JaCoCo parses, and the evidence-location validator (exit 0).

**Top 3 risks:**
1. The guard runs the 35-test target three times in nested form, which adds runtime to every shard that contains it. Measured impact was not recorded; the concurrent-shard run completed in 408.76 s against a comparable baseline.
2. The guard's `AfterEach` removes every module and function absent from its snapshot. If a future test in the same file loads a module that a later file expects to remain loaded, that file would see it removed. Exposure is low because the snapshot is taken per test and the outer Pester module is loaded before it.
3. The environment comparison has been run only on Linux in this branch; `windows-latest` CI is the first run on Windows, where nested Pester could touch an environment variable that Linux does not. The control testcase isolates that case and would fail with the differing key named.

**PR readiness recommendation:** **Go** - no Blocker, Major, or Minor finding; the Info and Nit items below are non-blocking.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev-tools/run-actionlint.ps1` | whole file (not in the branch diff) | Line coverage is 4 of 50 (8.00%) in both baseline and post-change artifacts; the suite loads functions through the AST helper `Import-ScriptFunction`, and JaCoCo does not attribute those executions to the script file. Related to issue #1066 (same suite) but outside its declared scope. | Consider a separate item to measure the suite's coverage of this file; no change in this branch, because the spec excludes production files. | Not a modified file, so the per-file threshold does not apply; repo-wide coverage is 91.83%. | `artifacts/pester/issue-1066/final-scripts-coverage.xml` parsed in this review; `evidence/qa-gates/pester-scripts-coverage.2026-11-04T02-10.md`. |
| Info | `tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1` | tests 2 to 4 | Each of three tests runs the full target suite nested, so the target executes three extra times per run. Related to issue #1066. | Accept as is; a single nested run feeding three assertions would couple the tests. | Independence of each `It` outweighs the runtime cost. | Code reading; `evidence/qa-gates/pester-parallel.2026-11-04T02-17.md`. |
| Info | `docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/issue.md` | line 5, `Status` | The status line names `docs/features/active/run-actionlint-test-path-env-leak/`, which differs from the actual folder `2026-11-03-run-actionlint-test-path-env-leak-1066`. Related to issue #1066. | Optional correction of the path text. | Documentation accuracy only; no tool reads this line. | `ls docs/features/active/`. |
| Nit | `tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1` | `restoreGlobalState`, lines 124-134 | `Remove-Module` and `Remove-Item` use `-ErrorAction SilentlyContinue`, so a failed teardown removal is not reported at the point of failure. Related to issue #1066. | Accept as is. | A residual entry would appear in the next test's snapshot delta, so the failure is still observable. | Code reading. |
| Nit | `docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/spec.md` | header | `Status: Draft` remains although AC1 to AC10 are checked. Related to issue #1066. | Optional update when the item closes. | Metadata only. | `spec.md` lines 7-8. |

No Blocker, Major, or Minor finding. No covered file is at or above 700 logical lines, so no file-size Warning row applies (`run-actionlint.Tests.ps1` 554, `run-actionlint.EnvironmentIsolation.Tests.ps1` 210).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The restore now sits at the scope that covers every Context, which removes the root cause rather than adding a second Context-level restore next to the leaking test.
- Existence is restored as well as value for both PATH and LASTEXITCODE, which handles the `$env:PATH = ''` test and the case in which LASTEXITCODE was never set.
- The `AfterEach` avoids every command mocked inside a Context, and the comment records why.
- `AfterAll` removes only what the file added, so a suite that defined `Import-ScriptFunction` during its own discovery keeps it (`evidence/remediation-baseline/victim-search.2026-11-04T01-16.md` lists the four other TestHelpers consumers and their dispositions).
- The guard's LASTEXITCODE test carries a precondition assertion, which addresses cycle 1 finding F2 (a testcase that could not fail); `evidence/regression-testing/fail-before-lastexitcode.2026-11-04T01-19.md` shows it failing with target probe 0 when only the LASTEXITCODE restore is deleted.
- The global-state test compares against a control delta, so state that the nested harness itself adds is not attributed to the target.

#### API and safety notes

- No production or public API change.
- Analyzer hygiene: 0 PSScriptAnalyzer findings; Invoke-Formatter reports no change.

#### Error handling and logging

- Assertions use `-Because` messages that list the differing environment keys or delta entries, so a regression names the leaked item.

---

## Test Quality Audit

The guard can fail for each state class it covers, and each failure mode is shown by recorded evidence.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1` (4 tests, 210 logical lines).
- `tests/scripts/dev-tools/run-actionlint.Tests.ps1` (35 tests, 554 logical lines).
- `evidence/regression-testing/fail-before-guard.2026-11-04T00-53.md` - environment test fails on the pre-fix tree with differing key `PATH`.
- `evidence/regression-testing/fail-before-guard-globals.2026-11-04T01-18.md` - global-state test fails naming `Import-ScriptFunction`, `Expand-Archive`, `Compress-Archive`, and `Microsoft.PowerShell.Archive`.
- `evidence/regression-testing/fail-before-lastexitcode.2026-11-04T01-19.md` - LASTEXITCODE test fails under a targeted mutation; target hash equal before and after.
- `evidence/regression-testing/pass-after-guard.2026-11-04T01-20.md`, `global-state-pass-after.2026-11-04T01-20.md`.
- `evidence/regression-testing/order-*.md` (six orders) - 8 victim suites match their target-excluded profiles; no container outside its baseline.
- `evidence/qa-gates/pester-scripts-coverage.2026-11-04T02-10.md`, `pester-parallel.2026-11-04T02-17.md`, `qa-loop.2026-11-04T02-19.md`, `self-review.2026-11-04T02-19.md`.
- This review: `Invoke-Pester` over both suites in one process, 39 passed, 0 failed.

### Quality assessment prompts

- **Determinism:** constant sentinel; no time or randomness.
- **Isolation:** each guard test restores environment, LASTEXITCODE, functions, and modules in `AfterEach`.
- **Speed:** bounded by three nested target runs (see Info item).
- **Diagnostics:** failure messages name the leaked keys or entries.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or host paths in the diff; evidence uses `SCRATCH`, `RAW`, and `<worktree>` tokens. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess added; nested Pester runs in process. |
| Input validation at boundaries | N/A | Test-only change. |
| Error handling remains explicit | ✅ PASS | Assertions carry explicit messages; see Nit on teardown. |
| Configuration / path handling is safe | ✅ PASS | The guard path is built with `Join-Path` from `$PSScriptRoot`; the TestHelpers path uses `[System.IO.Path]::Combine`, which is separator-neutral. |

---

## Research Log

No external research was required. All conclusions are drawn from the repository diff, the feature-folder evidence, the coverage artifacts in the item worktree, and the read-only re-runs listed above.

---

## Verdict

The change is ready for the normal PR flow. It fixes the PATH leak at its root, restores the other process-global state the file changed, and adds a guard whose four assertions are each shown to fail against the defect they cover. The Info and Nit items do not block merge.
