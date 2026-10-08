# Code Review: CI gaps - Linux Pester hook-suite job and kcov set -u trace simulation (#743)

---

**Review Date:** 2026-10-01
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743`
**Feature Folder Selection Rule:** The only active feature folder whose suffix matches issue #743 in the branch name; also named by the caller.
**Base Branch:** `main` (`origin/main` @ `41217012d31d35c2ee33a50be50684affd2f5f43`, equal to the merge base)
**Head Branch:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743` @ `630237f4bf081ed117253e44a7f3d3780bb19368`
**Review Type:** Initial review
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`

---

## Executive Summary

The branch closes three CI gaps from issue #743 with a small code footprint: 13 non-documentation files, +256/-25 lines. It adds a separate `ubuntu-latest` Pester job for the Claude and Codex hook suites. It makes `shell-qc.sh test` reproduce kcov's xtrace environment, so the `bash -c` + sourced `set -u` failure shows up locally. It makes three Codex hook test files portable to Linux, and it adds two planner-guidance bullets. The reviewed evidence was the full diff against the merge base, the PR context summary and appendix, the executor's evidence tree, the local `artifacts/pester/powershell-coverage.xml`, and CI run 36901896617 as recorded in evidence. That run's head `ecba8829` differs from the branch head only in feature-folder documents.

**What changed:**
`.github/workflows/_poshqc.yml` gains job `poshqc-linux-hooks` (`contents: read`, `Invoke-Pester` over two folders, coverage off, artifact `poshqc-linux-hook-test-results`), with no edit to the existing `poshqc` job. `scripts/bash/kcov_trace_env.sh` sets kcov v43's PS4 and `set -x`. `run_test` in `scripts/bash/shell_qc_lib.sh` runs each bats invocation with `BASH_ENV` set to that file and `BASH_XTRACEFD` on a `/dev/null` descriptor. New tests: `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (7 It blocks) and 3 bats tests with 3 fixtures. The Codex hook tests now derive synthetic rooted paths from `$IsWindows` and assert the elevated sandbox argument as `-contains ... | Should -Be $IsWindows`.

**Top 3 risks:**
1. The new Linux check is red on the branch head: 12 failures in 5 hook-suite files, all `DriveNotFoundException` on drive `C`. The spec requires those failures to be fixed in this feature before merge.
2. Because the check is not required in branch protection (by design, orchestrator decision 2), a red Linux job would not mechanically block a merge. Merging in this state would place a permanently failing check on `main`.
3. After the 12 known failures are fixed, further Linux-only failures may surface in the same files. A failing `BeforeAll` or an early throw can hide later cases. The re-run must be read in full.

**PR readiness recommendation:** **Needs Revision** - the delivered changes are correct and well tested, but AC-6 and AC-10 fail on the branch head and the modified workflow has no green run.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | lines 46, 338, 345, 351, 357, 365 | 8 tests fail on `ubuntu-latest` with `DriveNotFoundException: ... drive with the name 'C' does not exist`. The suite uses the literal `C:/worktrees/alpha` as a worktree root. | Derive the synthetic root from `$IsWindows` (`C:/worktrees/alpha` on Windows, `/worktrees/alpha` elsewhere) in `BeforeAll`, and build the JSON at line 46 with `-f` or concatenation, as in `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1:47-51,214`. Do not add `-Skip`. | `spec.md` Implementation strategy requires every Linux-only failure the CI run reports to be fixed within this feature before merge (AC-6, AC-10). | `evidence/qa-gates/ci-final-linux.2026-10-01T17-57.md` (`Failed: 12`); `evidence/qa-gates/linux-remediation-required.2026-10-01T16-58.md` rows 1-8 |
| Blocker | `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`, `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` | lines 303, 304, 301, 298 respectively | Test "the default reader yields direct mode when the checkpoint file is absent" fails on Linux in all four files. Each passes `-Root 'C:/synthetic-absent-root'`, which raises `DriveNotFoundException` instead of resolving to an absent file. | Use an OS-derived absent root (`/synthetic-absent-root` on non-Windows). The case under test (checkpoint absent -> direct mode) is OS-independent, so one assertion serves both hosts. | Same spec requirement. The test's intent ("file is absent") is not exercised on Linux, because the exception precedes the absence check. | `evidence/qa-gates/linux-first-run-failures.2026-10-01T17-57.md` rows 9-12 |
| Blocker | `.github/workflows/_poshqc.yml` | job `poshqc-linux-hooks` (lines 54-90) | The `modified-workflow-needs-green-run` rule is not satisfied. Run 36901896617 (head `ecba8829`) concluded `failure` because of this job, and no green run of `_poshqc.yml` exists for the branch head. | After the fixes above, obtain a `_poshqc.yml` or `ci.yml` run whose `headSha` equals the branch head and whose `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` jobs both conclude `success`, and record it under `evidence/qa-gates/`. | The feature-review workflow rule requires a green run of every modified workflow against the branch head. | `evidence/qa-gates/ci-final-conclusions.2026-10-01T17-57.md` |
| Major | `.github/workflows/_poshqc.yml` | AC-5 / AC-21 | `scripts/dev-tools/run-actionlint.ps1`, named by AC-5 and AC-21, has not been run (operator blockers B1-B3). Direct `actionlint` 1.7.11 reports no findings in three runs. The wrapper resolves `actionlint` from PATH first (`run-actionlint.ps1:143`) and passes its arguments through unchanged (`:159`), so a different result is unlikely. | Operator runs `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` and the output is recorded under `evidence/qa-gates/`. | The AC names the wrapper explicitly. Under the 2026-10-01 operator decision, agents cannot run it. | `evidence/qa-gates/qc-actionlint.2026-10-01T17-23.md`; `scripts/dev-tools/run-actionlint.ps1:140-162` |
| Minor | `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/qa-gates/qc-shell-qc-test-full.2026-10-01T17-45.md` | Command line | AC-15 (full `shell-qc.sh test` with the simulation active) is evidenced by `sh <session-scratchpad>/shell-qc-test-local.sh <BATS_DIRECT>`, a script that is not committed. The CI `shell-coverage` job runs `test --coverage` (`run_test_coverage`), which does not apply the simulation, so it does not corroborate AC-15. | In the remediation cycle, record the exact command the scratchpad script ran (expected form: `SHELL_QC_BATS_BIN=<bats> bash scripts/bash/shell-qc.sh test`) in the evidence file. | A third party should be able to reproduce the evidence without the session scratchpad. The result itself (501 ok, TAP plan `1..501`) is credible and is accepted. | Evidence file contents |
| Info | `artifacts/pester/powershell-coverage.xml` | report-level `LINE` counter | The local MCP run reports covered 10688 of 11104 lines (96.25%), and CI reports 11236 of 11666 (96.31%). The denominators differ by 562 lines. | No action in this feature. This matches open issue #527 (the MCP runner uses the installed extension's settings). | Both values are above 85%, so the verdict does not change. | `grep -o '<counter type="LINE"[^>]*>' artifacts/pester/powershell-coverage.xml \| tail -1` |
| Info | `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` | whole file | 495 lines, 5 below the 500-line limit. | Any further Linux fix in this file should be paired with a split, or kept to one-line edits. | The file-size policy applies to test files. | `wc -l` |
| Info | `scripts/bash/shell_qc_lib.sh` | lines 253-267 | `BASH_ENV` applies to the bats process itself and to every non-interactive child bash, so bats internals are also traced to `/dev/null`. No regression was observed across 501 tests, and wall time went from 21.47 to 20.02 minutes. | None. A future regression here would surface as a local-only bats failure that names `BASH_SOURCE`. | The change is a strict subset of kcov's behavior (identical PS4), as the spec intends. | `evidence/qa-gates/qc-shell-qc-test-full.2026-10-01T17-45.md` |
| Info | `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` | lines 50-52 | `declares exactly the poshqc and poshqc-linux-hooks jobs` will fail when anyone adds a third job to `_poshqc.yml`. | None. This is an intentional invariant that forces the suite to be updated with the workflow. | It makes accidental job additions or renames visible. | File inspection |
| Info | Branch history | commit `3f85b23d` | An out-of-band `wip(743)` checkpoint commit is in the branch history (plan deviation D13). Its content is byte-identical to the executor's working tree. | Consider squash-merging, or leave as is. No content issue. | Commit hygiene only. | `git log --oneline 41217012..HEAD` |

Three Blocker findings and one Major finding. All three Blockers share one root cause (drive-letter literals in five hook-suite test files) and one fix set.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The S1 fix replaces `Should -Contain 'windows.sandbox="elevated"'` with `($arguments -contains '...') | Should -Be $IsWindows -Because '...'` at three sites. One assertion now states the production rule (`.codex/scripts/epic-child-sandbox-preflight.ps1:33`) for both hosts: present on Windows, absent elsewhere. This meets the spec requirement that every OS-guarded Windows case has a non-Windows counterpart, without a `-Skip`.
- The decision-surface suite derives `$script:SyntheticRoot`, `$script:SyntheticElsewhere`, and `$script:SyntheticTarget` once in `BeforeAll`. The corrected premise comment explains that `IsPathRooted` treats drive-letter paths as rooted only on Windows. The checkpoint JSON at line 214 is built with `-f` and doubled braces, which is correct format-string escaping.
- `PoshQcWorkflow.Tests.ps1` partitions the workflow by two-space job keys and asserts per-job text, so an assertion cannot pass by matching another job's text. It uses `Set-StrictMode -Version Latest`, makes no external calls, and creates no temporary files.

#### API and safety notes

- No production PowerShell file, function, or parameter changed. PSScriptAnalyzer reports no findings (CI).

#### Error handling and logging

- `Resolve-Path` on the workflow path fails fast if the file moves. `Run.Exit = $true` makes the Linux job fail on any failed test, and skipped tests do not fail it, as specified.

### Bash implementation audit

#### What changed well

- `kcov_trace_env.sh` is byte-identical in PS4 to kcov v43 (single-quoted, expanded at trace time). The bats test asserts the exact string `kcov@${BASH_SOURCE}@${LINENO}@`. The file defines nothing else.
- `run_test` resolves `kcov_trace_env.sh` from the library's own directory (`cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd`), so the path is absolute and independent of the caller's working directory. The fd is allocated with `exec {trace_fd}>/dev/null` and closed after the loop. The per-directory loop keeps its `|| rc=$?` max-exit semantics.
- `run_test_coverage` is untouched, so real kcov remains authoritative in CI.
- The regression stubs exercise the exact failing pattern (`bash -c 'source "$1"; true'`) and the documented safe pattern (`load_helper` with `set +u`). The negative control (`trace-discard-negative-control.2026-10-01T16-35.md`) shows that the "no `kcov@` in output" assertion fails when the discard is removed, so that assertion can fail.

#### Error handling and logging

- A test that trips the pattern fails with `BASH_SOURCE: unbound variable` surfaced on stderr, and `run_test` returns non-zero. The skip markers and exit-0-on-skip paths are unchanged (lines 244-251).

### GitHub Actions implementation audit

- The new job follows least privilege (`contents: read`), uses the same action major versions as the existing job (`actions/checkout@v7`, `actions/upload-artifact@v7`), and uploads with `if: always()` and `if-no-files-found: ignore`, so failing runs still publish their JUnit. `${{ github.workspace }}` in a `run:` block is runner-controlled and not attacker-controlled input.

---

## Test Quality Audit

Automated evidence covers fail-before and pass-after for both gaps, local and CI runs, coverage with per-changed-line kcov records, and scope checks. The only unmet verification is the Linux hook-suite job itself.

### Reviewed test and QA artifacts

- `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` - 7 workflow invariants. Fail-before evidence: `evidence/regression-testing/fail-before-poshqc-workflow.2026-10-01T16-45.md`. Pass-after: `pass-after-poshqc-workflow.2026-10-01T16-55.md`. CI Windows `tests=7 failures=0`.
- `tests/shell/test_shell_qc_commands.bats` (3 new tests) - fail-before exit 1 (`fail-before-bats.2026-10-01T16-32.md`), pass-after exit 0, CI under kcov `ok 486`-`ok 488`.
- Three Codex suites - CI Windows and Linux `failures=0` (`ci-final-linux.2026-10-01T17-57.md` SUITE lines: 20, 19, and 22 tests).
- `evidence/qa-gates/ci-final-linux.2026-10-01T17-57.md` - Linux job 3400 passed, 12 failed. This is the blocking evidence.
- `evidence/qa-gates/coverage-comparison.2026-10-01T17-58.md` - PowerShell 96.31% -> 96.31%, Bash 93.4% -> 93.7%, changed instrumented lines 8 of 8 hit.

### Quality assessment prompts

- **Determinism:** No clock, RNG, or network. OS-dependent expectations are derived, not skipped.
- **Isolation:** Each new test targets one behavior. The stubs isolate `run_test` from real bats.
- **Speed:** The workflow suite is text-only. The bats stubs are single-process.
- **Diagnostics:** `-Because` messages on the OS-conditioned assertions; exact-string assertions on the job set and folder list.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no tokens, keys, or credentials. |
| No unsafe subprocess or command construction | ✅ PASS | The stubs pass the library path as `$1` to `bash -c` rather than interpolating it into the command string. |
| Input validation at boundaries | N/A | No new external input surface. |
| Error handling remains explicit | ✅ PASS | Max-exit semantics retained; `Run.Exit = $true`. |
| Configuration / path handling is safe | ✅ PASS | The trace env path is resolved absolutely from the library location. The workflow job uses `contents: read`. |

---

## Research Log

No external research was performed in this review. The kcov v43 PS4 behavior and the runner-image tool versions are taken from the feature's `research/research.2026-09-30T07-20.md` and the spec, and are corroborated by the CI results recorded in evidence.

---

## Verdict

The implemented changes are correct, minimal, and well tested. The Bash simulation and the workflow-invariant suite each have fail-before and pass-after evidence, coverage is above threshold with every changed instrumented line hit, and the existing `poshqc` job is untouched.

The branch is **not ready for merge**. Its own new check, `poshqc / PowerShell hook suites (Linux)`, fails on the branch head with 12 failures from drive-letter literals in five hook-suite test files. The spec puts those failures in scope for this feature, so AC-6 and AC-10 are unmet and the `modified-workflow-needs-green-run` rule blocks. The fix is mechanical and follows a pattern already on the branch. The operator-run `run-actionlint.ps1` step (AC-5, AC-21) must also be recorded. After both items and a green `_poshqc.yml` run on the branch head, re-review is expected to clear.
