# Code Review: Completion-Consistency Edit Reads Relative Checkpoint (#708)

**Review Date:** 2026-09-27
**Branch:** `bug/completion-consistency-edit-reads-relative-checkpoint-708` @ `d21195cd1da4917c6ce965cc1f032606c72da12c`
**Base:** `origin/main` @ `74b2ca0a2bdf8a0bf9a032433fef20831707b574`
**Scope:** full branch diff (`git diff 74b2ca0a2bdf8a0bf9a032433fef20831707b574...HEAD`), 12 files: 2 production PowerShell copies, 1 new Pester file, 9 Markdown feature documents.

## Executive Summary

The fix is minimal and matches the approved design (D1, D2, D10). `Resolve-EditedCheckpointContent` gains a mandatory `[string] $CheckpointPath` parameter and calls `& $CheckpointReader $CheckpointPath`; its single caller passes the raw `tool_input.file_path` (`$filePath`), not the separator-normalized value. The script `.DESCRIPTION` and the function help were rewritten to describe the targeted-path read. The bundled copy is byte-identical.

Review focus results:

1. **Enforcement-hook bypass.** None introduced. See "Bypass Analysis" below.
2. **Behavior preservation (D6).** The Write branch is untouched by the diff. Every row of the D6 fail-semantics table is preserved; only the file the Edit branch reads changes.
3. **Test determinism and portability.** The new tests use only an injected in-memory reader, no temporary files, no `Set-Location`, no gitignored state, no `origin/main`, and no drive-letter paths. They are suitable for the `poshqc` job on windows-latest and would behave the same on Linux.

Reviewer verification: new file plus the three existing suites passed 81 of 81 at HEAD; the new file against the base-commit hook produced 8 assertion failures and 4 passes (0 failed blocks or containers), matching the recorded fail-before evidence; PSScriptAnalyzer 0 findings and formatter no-change on both PowerShell files.

Findings: 0 Blocking, 0 Major, 3 Minor. Out-of-scope observations are listed as non-blocking follow-ups.

## Bypass Analysis

Question 1: can a caller make the hook read a file other than the one the Edit writes?

- The reader is reached only after `Test-IsCheckpointPath` matches the backslash-normalized `file_path` against `(^|/)artifacts/orchestration/orchestrator-state\.json$` (hook lines 364-367). This precondition is unchanged, so the set of files the hook can read is not widened beyond files named `orchestrator-state.json` under an `artifacts/orchestration/` directory.
- The raw `file_path` string is passed to the reader (line 374), and the default reader uses `Test-Path -LiteralPath` and `Get-Content -LiteralPath` (lines 86-89), so wildcard characters are not expanded. The hook reads the same path string that the Edit tool writes.
- Relative `file_path` values resolve against the hook process working directory, exactly as the pre-fix literal did; this is unchanged behavior, and the Claude Code Edit tool declares `file_path` as absolute.
- Path spellings with `..` segments, UNC prefixes, or mixed case resolve to the same file for the reader and for the Edit tool, because both receive the identical string.

Question 2: can a completion-asserting Edit now be allowed that was denied before?

The pre-fix hook applied the patch to the checkpoint at the hook's working directory (C); the fixed hook applies it to the targeted file (T). When C and T are the same file, decisions are identical. When they differ, the fixed hook newly allows only in these cases:

| Condition at T | Fixed-hook decision | Effect of the actual Edit |
|---|---|---|
| T missing or empty | allow (D6) | The Edit tool cannot apply `old_string` to a missing or empty file; no completion assertion is written. |
| `old_string` absent from T | allow (D6) | The Edit tool fails with an unmatched `old_string`; nothing is written. |
| Patched T does not assert completion, or carries full evidence | allow | The written file carries no unevidenced completion assertion. |

In every newly allowed case, the file the Edit writes does not end up asserting completion without evidence. Conversely, the fix closes the pre-fix gap in which an Edit on another worktree's checkpoint was allowed because C lacked the file or the anchor. No new bypass was found.

Residual pre-existing behaviors (not introduced by this branch; recorded as follow-ups): `String.Replace` replaces all occurrences (spec D11 item 1); a terminating read error from `Get-Content` exits the hook without JSON output (D6 last row), which the Claude Code runtime treats as a non-blocking hook error. The branch makes the read path caller-supplied, but the Edit tool must read the same file to apply its patch, so an unreadable target also prevents the write.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-completion-consistency.ps1` (and bundled copy) | Lines 32-34, 277-278, 309-310, 369-371, 376-377 | Several in-code comments still say "the on-disk checkpoint" or "on-disk content" without naming the targeted `file_path`, and the `.DESCRIPTION` rewrap at lines 32-34 leaves an irregular short line. The authoritative help text is correct (AC8 passes). | In a later touch of this file, change the inline comments at lines 310, 369-371, and 376-377 to refer to the targeted `file_path`, and rewrap lines 32-34. | Comment drift of this kind produced the original stale header that D10 corrected. | Reviewer read of HEAD file; diff hunk at lines 29-38 and 266-313. |
| Minor | `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/regression-testing/edit-target-fail-before.md` | Sections P1-T2 and P1-T2 hook-unmodified | The PR-context collector parses one Command/EXIT_CODE per evidence file (the last) but the first `ExpectedExitCode` (8, from P1-T2). It therefore pairs the hook-unmodified command (EXIT_CODE 0) with ExpectedExitCode 8 and renders the file as "Normalized result: fail" in `artifacts/pr_context.summary.txt`. The underlying evidence is correct. | Before PR authoring, either place the hook-unmodified section before P1-T2 so the last block is the one declaring ExpectedExitCode 8, or note in the PR body that this "fail" is a parser pairing artifact. | A reader of the PR context, or a readiness check that consumes it, can misread a correct fail-before record as a failed verification. | `artifacts/pr_context.summary.txt` "Verification evidence" section; `scripts/dev_tools/pr_context/verification_evidence.py` lines 122-135. |
| Minor | `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1` | Lines 13-16 (`.DESCRIPTION`) | The help states the file "performs no filesystem access". `BeforeAll` calls `Resolve-Path` and dot-sources the hook, which imports `HookPayload.psm1` and the helpers file. The test bodies perform no filesystem access. | Reword to "the test bodies perform no filesystem access; the only file access is loading the hook under test". | Precision of test documentation; no behavioral effect. | Reviewer read of lines 13-22. |

## Behavior Preservation (D6)

| Condition on the Edit path | Before | After | Verified by |
|---|---|---|---|
| Envelope anomaly | deny, payload-anomaly reason | unchanged (code before the Edit branch not modified) | `enforce-completion-consistency.Payload.Tests.ps1` 7/7, unmodified |
| No `old_string` | allow | allow | T-J; existing suite |
| Targeted file missing or empty | allow | allow (now evaluated at the targeted path) | T-G, T-K; existing test at `enforce-completion-consistency.Tests.ps1:374-386` |
| `old_string` absent from targeted text | allow | allow | T-I; existing test at lines 388-400 |
| Patched content not valid JSON | allow | unchanged (lines 382-389 not modified) | existing suite |
| `Get-Content` throws | terminating error | unchanged (default reader not modified) | code read |
| Write branch (`content` present) | validate content | unchanged (`Resolve-EditedCheckpointContent` is called only when `content` is empty) | existing suite 47/47 and contract suite 15/15, unmodified |

## Test Quality Notes

- Fail-before is demonstrated as assertion failures, not parameter-binding errors, because the tests drive `Invoke-CompletionConsistencyDecision` (D5). The reviewer reproduced this: 0 failed blocks and 0 failed containers against the base hook.
- The path-keyed reader closures use `@{}` hashtables, whose key lookup is case-insensitive. All fixture paths are distinct beyond case, so this does not affect the assertions.
- The capturing-reader tests assert `Count -eq 1`, which also confirms the Edit branch performs a single read.
- The default `CheckpointReader` (`Get-CheckpointFileContent`) with an absolute path is not exercised by any unit test; exercising it would require real files, which the test policy prohibits. The function body is unchanged by this branch. Recorded as follow-up F4.

## Non-Blocking Follow-ups (out of scope)

- F1. Codex copy `.codex/hooks/enforce-completion-consistency.ps1` and its bundled copy carry the same relative-literal defect (spec D7; `evidence/other/follow-ups.md` item 1). Sequence after #707.
- F2. `String.Replace` replaces every occurrence of `old_string` (spec D11 item 1; follow-ups item 2).
- F3. The existing test at `enforce-completion-consistency.Tests.ps1` context "Edit tool calls (no full content)" uses the default reader and depends on the working directory (follow-ups item 3).
- F4. `Get-CheckpointFileContent` line 87 (missing-file return) is uncovered in the scoped run; its behavior with absolute paths is covered only by code reading.
- F5. Missing or unreadable targeted checkpoint allows in the Claude hook but denies in the Codex hook (policy question, follow-ups item 4).
- F6. `scripts/dev_tools/pr_context/verification_evidence.py` pairs the last Command/EXIT_CODE with the first `ExpectedExitCode` in a multi-section evidence file. A per-section parse would remove the class of false "fail" results described in the second Minor finding.
- F7. `quality-tiers.yml` is absent at the repository root (pre-existing).
