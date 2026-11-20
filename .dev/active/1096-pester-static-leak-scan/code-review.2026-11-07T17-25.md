# Code Review: pester-static-leak-scan (#1096)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-pester-static-leak-scan-1096`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `a2e338950e64f21f23a7f5ab7a15cdeae7169de2`, equal to `origin/main`)
**Head Branch:** `feature/pester-static-leak-scan-1096` (`36372b6c69c6b75f486da0253c54d17279246634`)
**Review Type:** Re-audit after remediation cycle 1

---

## Executive Summary

The review scope is the full branch diff against the merge base. The feature content (two PoshQC sub-modules for the static Pester leak scan, the allowlist, CI step, VS Code task, `fix_all` step, leak fixes, parallel-gate command edits, brief edits, and ledger entry 0001) was reviewed in `code-review.2026-11-07T16-00.md`; this re-audit re-checked it at head and reviewed the cycle 1 changes in detail.

Cycle 1 merged `origin/main` twice. The first merge resolved conflicts with PR #1108 in `cli_preflight.py`, `prompt_builder.py`, `qc_runner.py`, and `test_qc_runner.py`; each resolved command keeps the branch's `-n`, `auto` and main's `--cov=scripts/dev_tools`, and no `src/lexile_corpus_tuner` remains in production code. The second merge brought only release version files. The cycle removed 22 duplicate test cases with named main counterparts, moved two test classes to keep files under 700 lines, gave `FULL_TEST` a coverage source through the merge, and split the read and parse `try` blocks in `Invoke-PoshQCLeakScan` so a read failure is labelled `read-error`.

Verification by this review: static tools clean over 18 Python and 22 PowerShell changed files; leak scan 0 failures over 558 files; 26 of 26 ledger fences replay; coverage artifacts parsed and matching the gate records; a real-process probe of the default reader on a non-existent path produced `read-error`, and a parse-error control produced `parse-error`.

The only blocking item is procedural: `.github/workflows/_poshqc.yml` changed and no CI run exists for the head (PA-1 in the policy audit, `awaiting_ci`).

**Top 3 risks:**
1. The scan is file-local and static; a leak through a helper in another file or through production code is not detected, as the spec records.
2. `test_prompt_builder.py` is at 769 logical lines (768 on `main` before this branch); the next additions there will approach the 800-line hard limit.
3. The two allowlist entries key on variable expression text; a rename forces an allowlist update through stale detection.

**PR readiness recommendation:** **Wait for CI** — no code change is required; PA-1 resolves with a green run of the modified workflow against the head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` | whole file | 769 logical lines, at or above the 700-line advisory tier. The file had 768 lines at the merge base; this branch adds one assertion. | Split by a logical seam in a later change to that file. | `.claude/rules/general-code-change.md` `## File Size Limit` advisory tier. Non-blocking; the tier was crossed on `main`. | Logical line count by splitlines at head and at `a2e338950`. |
| Info | `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1` | `Get-PoshQCLeakPairing`, rule R3 | A restore inside a nested block of the same statement list does not pair under R3 and is itself reported. | None required; the spec defines R3 as the same block, and such a case goes to the allowlist with a reason. | Conservative behavior, carried from the first review. | Reviewer probe P22 of the first review. |
| Info | `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1` | `Invoke-PoshQCLeakScan`, per-file loop | NB-3 closed. The read and the parse now have separate `try` blocks; a read failure adds a failure row of kind `read-error` at line 0 with the reader's message, and skips the parse. | None. | `LI-14` injects a throwing reader and asserts `read-error` and the absence of `parse-error`; the pre-fix single `try` would fail its first assertion. | Reviewer probe through the default reader on `tests/scripts/does-not-exist.Tests.ps1` logged kind `read-error` with the `Cannot find path` message; the parse control logged `parse-error`. Blob ids of module and README equal their bundle copies. |
| Info | `scripts/dev_tools/atomic_executor/qc_runner.py` | `QCRunner.FULL_TEST` | NB-2 closed. The merge gives `FULL_TEST` the source `--cov=scripts/dev_tools`, so `--cov-report=xml` and `--cov-report=term-missing` have a source. | None. | `test_run_full_runs_all_tools_on_entire_codebase` pins the full list; spec `## Constraints & Risks` records it. | Diff of `qc_runner.py`; test list lines 438 to 444. |
| Info | `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` | whole file | NB-1 closed. 669 logical lines; `TestQCRunnerFilterHelpers` moved unchanged to `test_unicode_integration.py`, which gained no `import subprocess`. | None. | Each of the four moved test names occurs in exactly one file under `tests/`. | Reviewer grep; `file-size.2026-11-07T16-46.md`. |
| Info | branch | merges with `origin/main` | MC-1 closed. Both merge commits have two parents and carry no reduction token; `origin/main` is an ancestor of head. | None. | `merge-conflicts.2026-11-07T16-23.md` records both sides of each conflicted hunk. | `git merge-base --is-ancestor origin/main HEAD` exit 0; `git log` parents. |

---

## Detailed Review

### Merge resolution (MC-1)

- `cli_preflight.py`: the pytest step reads `poetry run pytest -n auto --color=no --cov=scripts/dev_tools --cov-report=term-missing`, and the fix-prompt text names the same command.
- `prompt_builder.py`: the toolchain text reads `python -m poetry run pytest -n auto` followed by `--cov=scripts/dev_tools` and `--cov-report=term-missing`.
- `qc_runner.py`: `FULL_TEST` and `full_test` each carry `-n`, `auto` and `--cov=scripts/dev_tools`.
- `qc_toolchain.py` and `fix_all_branches_extra.py` auto-merged and keep `-n auto`.
- `test_cli_part3.py`: `_PYTEST_STEP` gains `-n`, `auto`, so main's three step-keyed cases reach their failing step.

### Duplicate removal (P1-T2)

The branch class `TestPreflightBranches` is gone and each removed case names a main counterpart in `duplicate-test-review.2026-11-07T16-30.md`. `test_real_file_system_glob_sorts_matches` stays because no main case asserts its ordering. Coverage of `cli_preflight.py` (153/153, 77/78) and `prompt_builder.py` (124/124, 44/44) did not drop after the removal.

### Ledger entry 0001

All 26 Revert Blocks replay at head; the four remaining `src/lexile_corpus_tuner` strings in the entry are `not in` assertions inside test-block fences, so a revert restores main's coverage source and never the stale path.

### Typed-Python review

The Python edits change list literals, string constants, and test placement only. Annotations are unchanged and Pyright reports 0 errors over the 18 changed files.

### Workflow

The `pwsh` step calls a PowerShell function and no native command, so no `$LASTEXITCODE` can leak (`.claude/rules/ci-workflows.md`). `WF06-LEAK-SCAN-STEP` pins the step order and the absence of `continue-on-error` and `if`.

---

## Positive Observations

- The conflict record keeps both sides of every hunk, which made the resolution checkable line by line.
- The duplicate review applied a stated rule and kept the one case with unique coverage.
- `LI-14` uses the injected seam, so the read-failure path is tested without a file system.
