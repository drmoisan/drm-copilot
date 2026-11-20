# Code Review: Development-Docs Root Resolver and Feature-Folder Name Parser (#1035)

---

**Review Date:** 2026-11-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035`
**Feature Folder Selection Rule:** the folder whose name carries the canonical issue number 1035, named by the delegation prompt.
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `7ebf1347dd8fb86613d40e66461fa5ad64a07cfb`, equal to the fetched tip)
**Head Branch:** `feature/dev-docs-root-resolver-phase1-1035` (head `8ef56f9c7082bfdc79e2bb1c69e2f1bf10aabdef`)
**Review Type:** S7 re-audit after remediation cycle 1

---

## Executive Summary

The review covered the full two-dot diff `7ebf1347d..8ef56f9c7` (496 files) with particular attention to the cycle diff `e3a7b7de2..8ef56f9c7` (two production files, their two bundle copies, nine test files, evidence and the plan). The implementation findings of the prior review stand unchanged: the three resolvers follow R-1 to R-8 in the same branch order, the write-scope checker discriminates, OD-P4 is implemented as decided, and no closing keyword for #1016 exists.

The cycle closed F1 and F2. Seven of the nine F1 files were raised with tests only. Two Codex runtime files gained testability seams:

- `.codex/hooks/authorize-root-epic-invocation.ps1`: `Write-RootEpicInvocationReceipt` takes optional `-EnsureDirectory` and `-OpenFile` scriptblocks whose defaults are the former `CreateDirectory` and `CreateNew` calls; the entry block moved into `Invoke-RootEpicInvocationHook` (returns `ExitCode`, `Output`, `ErrorText`) and `Write-RootEpicInvocationHookResult`; git is reached through `Invoke-RootEpicGitExe`. `[string]` conversion of the git output and the regex check keep the former semantics.
- `.codex/scripts/epic-child-launch-runtime.ps1`: `Restore-CodexChildIsolatedAuth` takes optional `-OpenSource`, `-OpenDestination` and `-DeleteFile` scriptblocks; defaults equal the former calls; `Flush($true)` is kept for a real `FileStream`.

Both bundle copies are byte-identical to their sources (`cmp`). A real-process probe of the shipped hook confirmed the two non-writing outcomes: a non-epic payload exits 0 with no output, and a malformed payload exits 2 with the `EPIC_INVOCATION_ORIGIN_BLOCKED` text on stderr.

**Top 3 risks:**
1. CR-7: the refactored hook evaluates `[Console]::In.ReadToEnd()` outside the new try/catch, so a stdin read failure would end the script with a PowerShell error (exit 1) rather than the fail-closed exit 2 of the former code. The read failing in practice is unlikely.
2. Six covered files remain at or above the 700-line advisory tier, including `EpicCrossDependency.psm1` at 780 lines in three copies.
3. The integration lane and full suites on the pull request head remain CI-only.

**PR readiness recommendation:** **Ready** - no blocking finding; CI rows pending at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `.claude/lib/epic-wave/EpicCrossDependency.psm1` and its two bundle copies | whole file | 780 logical lines (merge base 769); at or above the 700-line advisory tier. | Split before further growth. | File-size policy advisory tier. | Reviewer `awk 'END { print NR }'` count at the head |
| Warning | `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` | whole file | 756 logical lines (merge base 695). | Consider a sibling suite for the development-docs cases. | File-size policy advisory tier. | Reviewer count at the head |
| Warning | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` and its bundle copy | whole file | 711 logical lines (merge base 687). | Split when next edited. | File-size policy advisory tier. | Reviewer count at the head |
| Minor | `.codex/hooks/authorize-root-epic-invocation.ps1` (and bundle copy) | final `exit (...)` line | CR-7: `[Console]::In.ReadToEnd()` and the repository-root `Split-Path` are evaluated as arguments outside the try/catch of `Invoke-RootEpicInvocationHook`. In the former code the stdin read was inside the try, so any failure exited 2 (fail closed). A .NET exception at that point now terminates the statement and the script ends with exit 1. | Read stdin inside `Invoke-RootEpicInvocationHook` (pass a reader scriptblock) or wrap the entry line in a try/catch that exits 2. | Keeps the hook's fail-closed contract for every failure path; the trigger (a failing console read) is unlikely, so this does not block. | Diff `e3a7b7de2..HEAD`; code inspection |
| Minor | `.claude/lib/development-docs/DevelopmentDocsRoot.psm1`, `scripts/dev_tools/json_config.py`, `extensions/drm-copilot/src/lib/development-docs/root.ts` | resolver read and parse | CR-2 (carried): BOM handling of the routing file differs between PowerShell and Python/TypeScript. | Record for epic child 4 or strip a leading BOM in the Python and TypeScript readers. | Cross-runtime disagreement on a BOM-prefixed file. | Prior review |
| Minor | `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` | `ConvertFrom-Json ... -DateKind String` | CR-3 (carried): `-DateKind` requires PowerShell 7.5. | Accept as an existing 7.5 dependency or drop the parameter. | Error reason would misstate the cause on 7.0 to 7.4. | Prior review |
| Info | `.codex/scripts/epic-child-launch-runtime.ps1` | `Restore-CodexChildIsolatedAuth` | CR-8: the `if ($destination -is [System.IO.FileStream]) { Flush($true) } else { Flush() }` branch exists to let a `MemoryStream` seam run; the default path keeps `Flush($true)`. The new suites for `.codex/scripts` files live under `tests/scripts/codex-hooks/`, next to the existing suites for the same files, rather than `tests/scripts/codex-scripts/`. | None required; consider moving the `.codex/scripts` suites together in a later change. | Follows existing precedent. | Diff; `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` |
| Info | `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` | `_stream_copilot_output` | CR-9: the executor recorded a timing-dependent branch arc (70.45% to 69.32% branch) in this module, which is not in the branch diff and was not changed. | Track separately as a determinism observation. | Out of the item's diff; no threshold applies to an unchanged file. | `evidence/qa-gates/python-tests.2026-11-17T15-57.md`; `git diff --name-only 7ebf1347d..HEAD` |
| Info | `.codex/hooks/authorize-root-epic-invocation.ps1` | `Invoke-RootEpicGitExe` body; entry line | CR-10: two changed lines uncovered (process boundary). File line coverage 98.23%. | None required. | Above thresholds; exercised by the reviewer's real-process probe. | `artifacts/pester/powershell-coverage.xml` |

---

## Implementation Audit

### Python implementation audit

No production Python change in the cycle. The branch's Python production changes (resolver, parser, consumers) were reviewed in the prior review; the cycle's new tests lift `copy_research_to_issue.py` to 100.00% line and branch, `plan_progress_report.py` to 99.02% line, and `atomic_executor/cli.py` to 82.69% branch. Branch-wide changed-line coverage is 251 of 251 lines and 60 of 60 branches (reviewer recomputation).

#### API and safety notes

- No production signature change in Python during the cycle.
- New tests use `monkeypatch` for file-system and module seams; no temporary file.

### TypeScript implementation audit

No TypeScript or JavaScript file changed in the cycle (`git log -1 -- '*.ts' '*.cjs'` is `6e6f39a86`, before the prior review). Root and extension Jest runs at `e10f76935` give totals identical to the prior review with 0 per-file drops.

#### API and safety notes

- Prior findings on `root.ts`, `feature-folder-name.ts` and `write-scopes.ts` stand (no `any`, no suppression).

### PowerShell implementation audit

The seams add optional parameters only; every existing caller binds by name (`resume-epic-child.ps1` calls `Restore-CodexChildIsolatedAuth` with named parameters). `Invoke-RootEpicGitExe` builds the result hashtable with `Output` before `ExitCode`, so `$LASTEXITCODE` is read after git runs. The `exit (Write-RootEpicInvocationHookResult ...)` line writes through `[Console]::Out` and `[Console]::Error`, which return nothing to the pipeline, so the exit code is the only pipeline value.

#### Error handling and logging

- Hook failures inside `Invoke-RootEpicInvocationHook` keep exit 2 with the error text on stderr (real-process probe for malformed JSON).
- CR-7 describes the one path outside the try/catch.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- Cycle gates: `python-tests.2026-11-17T15-57.md`, `powershell-tests.2026-11-17T15-50.md`, `jest-root-tests.2026-11-17T15-24.md`, `jest-extension-tests.2026-11-17T15-24.md`; static gates `python-static.2026-11-17T15-57.md`, `powershell-static.2026-11-17T15-50.md`; `coverage-delta.2026-11-17T15-51.md`; `self-review.2026-11-17T15-58.md`.
- Cycle baselines under `evidence/remediation-baseline/`; task checks P0-T1 to P3-T6; phase gates P1 and P2.

### Quality assessment prompts

- Discrimination: the default-seam case asserts that `CreateNew` refuses an existing file, which fails if the default open mode is weakened; the stream-seam case asserts the copied bytes; the copy-failure case asserts the delete call. The reviewer did not run mutants (owner rule against ad hoc test runs); discrimination was judged by reading the assertions.
- No test was weakened or removed; three existing test files gained cases only.
- No temporary-file API, sleep or wall-clock read was added (reviewer scan of added lines).

---

## Security / Correctness Checks

| Check | Result | Evidence |
|---|---|---|
| Seam defaults equal the former behavior | PASS | Diff of both files; real-process probe of the hook's non-writing outcomes |
| Bundle parity | PASS | 54 bundle copies and the template copy byte-identical to sources (`cmp`) |
| No secrets in tests | PASS | API-key variables in the runtime suite use synthetic values and are restored |
| No unsafe command construction | PASS | git called through a fixed wrapper with an argument array |
| No Closes/Fixes/Resolves line for #1016 | PASS | Keyword search over commit messages and added lines |
| Evidence append-only | PASS | Cycle evidence files are additions; no evidence file modified or deleted in `e3a7b7de2..HEAD` |

---

## Research Log

- Read the prior review set, remediation inputs and plan, cycle evidence, and the cycle diff.
- Parsed `artifacts/python/lcov.info`, `coverage/lcov.info`, `extensions/drm-copilot/coverage/lcov.info` and `artifacts/pester/powershell-coverage.xml`; swept every changed production file of the branch against them.
- Recomputed branch-wide changed-line coverage for Python and PowerShell from `git diff -U0` and the line records.
- Compared report write times with the last commit per language.
- Ran the shipped hook as a real process with a non-epic and a malformed payload.
- Ran `validate_evidence_locations.py --root <worktree>` (exit 0); counted logical lines of covered changed files.

---

## Verdict

**PASS.** No blocking finding. F1 and F2 are closed. Non-blocking: three Warning rows (six files), Minor CR-2, CR-3 and CR-7, Info CR-8 to CR-10.
