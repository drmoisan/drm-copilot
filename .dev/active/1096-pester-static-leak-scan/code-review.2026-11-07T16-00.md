# Code Review: pester-static-leak-scan (#1096)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-pester-static-leak-scan-1096`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `278bb7047db986bbb0a8652ca323656ce85f8a08`)
**Head Branch:** `feature/pester-static-leak-scan-1096` (`c8e2152088bb5c27cbeb8718b5e04c8f1ff9df9c`)
**Review Type:** First full review

---

## Executive Summary

Outside the feature folder the branch changes 52 paths. It adds the static Pester leak scan as two PoshQC sub-modules (`PoshQC.LeakScan.psm1`, the AST detectors and pairing rules R1 to R5; `PoshQC.LeakAllowlist.psm1`, allowlist validation, comparison, and the public `Invoke-PoshQCLeakScan`), their bundle copies, a committed allowlist, a CI step in `poshqc-static`, a VS Code task, and a `fix_all` step. It fixes the leaks the first scan reported, removes the process-directory dependency of the three named tests through a `-GetLocationPath` seam, moves the full-suite pytest commands and the `fix_all` Pester step to the parallel gates, and updates the brief and ledger entry 0001.

The core is a pure function over script text, which made it straightforward to verify. This review ran 28 in-memory probes against `Get-PoshQCLeakFinding` covering every row of the spec's detected-kinds table and each restore rule; every outcome matched the spec. The real scan at head reports 0 failures over 548 files. Static tools are clean, and coverage of the new modules is 98.22% and 95.40% of lines.

The only blocking item is procedural: `.github/workflows/_poshqc.yml` changed and no CI run exists for the branch head (PA-1 in the policy audit, `awaiting_ci`).

**Top 3 risks:**
1. The scan is file-local and static, so a leak through a helper in another file or through production code under test is not detected, as the spec records.
2. `QCRunner.FULL_TEST` now passes `--cov-report=xml` and `--cov-report=term-missing` with no `--cov` source, so that command collects no coverage. The spec records this and states that no reader depends on the XML report.
3. `test_qc_runner.py` crossed the 700-line advisory tier on this branch.

**PR readiness recommendation:** **Wait for CI** — no code change is required; PA-1 resolves with a green run of the modified workflow against the head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` | whole file | 711 logical lines, at or above the 700-line advisory tier. The file had 665 lines at the merge base. | Consider splitting the `-n auto` command cases into a sibling module in a later change. | `.claude/rules/general-code-change.md` `## File Size Limit` advisory tier. Non-blocking. | Logical line count by splitlines at head and at `278bb7047`. |
| Minor | `scripts/dev_tools/atomic_executor/qc_runner.py` | `QCRunner.FULL_TEST` | With `--cov=src/lexile_corpus_tuner` removed, the command keeps `--cov-report=xml` and `--cov-report=term-missing` with no `--cov` source, so it produces no coverage report. | No action in this item; the spec (`## Constraints & Risks`) records the effect and reports it to the orchestrator. A later change can add `--cov=scripts/dev_tools` or drop the two report flags. | Decision 4 states a removal only. A reader expecting `coverage.xml` from this command would find none, but no file under `scripts/dev_tools` reads it. | Diff of `qc_runner.py` lines 82 to 90; spec `## Constraints & Risks`. |
| Minor | `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1` | `Invoke-PoshQCLeakScan`, per-file `try`/`catch` | Any exception from `-ReadText` (for example a locked or unreadable file) is recorded with the kind `parse-error`, although no parse occurred. | Label read failures separately, for example `read-error`, or let the reader's exception propagate. | The scan still fails closed, so no finding is lost; only the diagnostic is misleading. | Lines 197 to 203 of the module. |
| Info | `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1` | `Get-PoshQCLeakPairing`, rule R3 | A restore inside a nested block of the same statement list (for example inside `if`) does not pair under R3, and the restore itself is reported as a write. | None required; the spec defines R3 as the same block, and such a case goes to the allowlist with a reason. | Conservative behavior; probe `$env:A = "x"; if ($true) { $env:A = $old }` reports both lines. | Reviewer probe P22. |
| Info | `config/poshqc-leak-allowlist.json` | `entries` | The two entries key the same restore helper on the expression texts `[string]$key` and `$key`. A rename of that variable changes the key; stale detection then fails the scan, which forces the update. | None required. | The spec anticipates this file as an expected entry, and stale detection covers the rename case. | Allowlist text; scan log `2 allowlisted`. |
| Info | `tests/scripts/powershell/Support/TestHelpers.ps1` | `Import-ScriptFunction` | The helper is no longer global. All four callers load it in a scope that reaches their calls: `tree.Tests.ps1` and `new-potential-entry.Tests.ps1` in a top-level `BeforeAll`, `run-actionlint.Tests.ps1` in its `Describe` `BeforeAll`; `new-claude-worktree-session.Tests.ps1` names it only in a comment. | None. | The full parallel gate passed with no global definition anywhere, so no file relies on the removed leak. | Grep of callers at head; `pester-parallel.2026-11-07T15-43.md`. |
| Info | branch | merge with `origin/main` | `origin/main` has advanced to `bad886e30`. The only overlapping path is the ledger entry, where both sides make the same `Merge commit:` change. | Bring the branch up to date with `main` before the PR, per the repository's PR practice. | `git merge-tree --write-tree` of head and `origin/main` completes without conflict. | `git log 278bb7047..origin/main`; merge-tree output. |

---

## Detailed Review

### Leak-scan core (`PoshQC.LeakScan.psm1`)

- Uses `Parser::ParseInput` only, never `ParseFile`; a parse error throws naming the path.
- Detectors cover every form in the spec table: assignment and compound assignment to `$env:` and `${env:}`; item commands on `Env:` and `Function:` paths; `SetEnvironmentVariable`; `-Scope Global` variable commands; `function global:`; the location commands and aliases; `[Environment]::CurrentDirectory` and `[IO.Directory]::SetCurrentDirectory` with and without `System.`.
- Pairing: R1 walks ancestors and requires the write to be in the `try` body; R2 scans later `try` statements of the same block; R3 requires a qualifying restore (variable, member, index, or removal) later in the same block and consumes it, so a literal reassignment is reported; R4 checks `AfterEach` and `AfterAll` held directly by any ancestor scriptblock; R5 resolves file-local functions called from cleanup regions.
- Writes inside cleanup regions and cleanup helpers are excluded as restores.

Reviewer probes, all through `Get-PoshQCLeakFinding` with in-memory text: no restore reported (P01, P08, P09, P10, P13, P16, P17, P18, P21, P24, P27, P28); variable restore later, `try`/`finally`, `AfterEach`, `Push`/`Pop`, `finally` `Pop`, cleanup helper, two writes with one restore, `BeforeAll` with `AfterAll` not reported (P02, P04, P06, P11, P12, P19, P25, P26); restore of a different name, literal reassignment, `AfterAll` in a sibling `Describe` reported (P05, P03, P07); here-string and `Mock Set-Location` not reported (P14, P15); parse error throws naming the path (P23).

### Allowlist and entry point (`PoshQC.LeakAllowlist.psm1`)

- Validation rejects wrong version, invalid JSON, blank fields, absolute paths, `..` segments, unknown kinds, duplicates, and any exemption other than `LASTEXITCODE`. An absent or blank file is empty.
- Comparison removes exempt `global-variable` findings, matches entries ordinally on path and kind and case-insensitively on name, and reports entries that match no raw finding as stale.
- All I/O goes through four scriptblock seams with production defaults. Failures are logged one per line and end in one throw.

### Process-directory independence

- `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` gain `-GetLocationPath`, defaulting to `{ $PWD.ProviderPath }`, so callers are unaffected.
- The two named `Enter-DrmCopilotShell` tests inject a fixture base and keep their titles; two default-path cases keep the wiring covered.
- The omitted-root test in `PoshQC.TestingInvokeConfigPaths.Tests.ps1` pins the location in `try`/`finally` and reads `(Get-Location).ProviderPath`; every `Set-Variable -Scope 1` capture became a holder hashtable.

### Parallel-gate commands

- `-n auto` is added on the command line of `run_python_branch`, `run_preflight_qc_with_capture`, `QCRunner.FULL_TEST`, `full_test`, and `PYTHON_TOOLCHAIN_COMMANDS["pytest"]`, and in the two prompt texts. `addopts` carries no `-n` flag.
- `fix_all` `PoshQC: test` runs `exit (Invoke-PoshQCParallelTest -Root '.').ExitCode`, and `PoshQC: leak scan` precedes it.

### Typed-Python review

The Python edits change list literals and string constants only. Annotations are unchanged, `pyright` reports 0 errors over the 17 changed files, and the new tests assert exact command lists.

### Workflow

The new `pwsh` step calls a PowerShell function and no native command, so no `$LASTEXITCODE` can leak (`.claude/rules/ci-workflows.md`). `WF06-LEAK-SCAN-STEP` pins the step order, the absence of `continue-on-error` and `if`, and the command line.

---

## Positive Observations

- The pure core and seam-only entry point allowed every rule to be tested with in-memory text and no temporary file.
- Stale-entry detection prevents the allowlist from accumulating suppressions after a fix.
- The reduction commits are separate and the ledger fences replay cleanly.
