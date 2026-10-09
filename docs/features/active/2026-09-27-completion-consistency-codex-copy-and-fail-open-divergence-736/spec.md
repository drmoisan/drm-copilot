# 2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence (Spec)

- **Issue:** #736
- **Parent:** epic #852 (enforcement-hook-precision), child C5a
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08
- **Work Mode:** full-bug
- **Status:** Draft
- **Version:** 0.2

## Problem Statement

#708 (PR #726) fixed the Claude completion-consistency hook so that an `Edit` call on an orchestration checkpoint is evaluated against the Edit call's own target file. Four related defects remain across the Claude and Codex copies of `enforce-completion-consistency.ps1`:

1. The Codex copy still reads the checkpoint from a relative literal path.
2. Both copies reconstruct the patched checkpoint with `String.Replace`, which replaces every occurrence of `old_string` and ignores `replace_all`. The Edit tool replaces exactly one occurrence unless `replace_all` is true.
3. The two copies apply different policies to a missing, empty, or unreadable targeted checkpoint. Claude allows the Edit (and an unreadable file escapes as an uncaught throw, which Claude Code treats as a non-blocking error). Codex denies. Fail-closed is the repository norm.
4. The Claude test suite exercises the default checkpoint reader with a relative path, so its result depends on the working directory and on local, gitignored orchestration state. No test drives the default reader against a real committed file.

Impact/Severity: Medium. The affected gate protects the invariant that a completion-asserting checkpoint carries completion evidence.

## Findings Basis

Line citations below were taken from `research/research.2026-10-08T17-55.md` and re-verified against this tree on 2026-10-08. Where the research and the tree differ by a line or two, the tree value is used and noted.

## Current vs Expected Behaviour

### Defect 1: Codex resolves the checkpoint from a relative literal

Current:
- `.codex/hooks/enforce-completion-consistency.ps1:308` calls `& $CheckpointReader 'artifacts/orchestration/orchestrator-state.json'`.
- `Resolve-EditedCheckpointContent` (Codex, line 270) has no `-CheckpointPath` parameter; its param block ends with `-CheckpointReader` at line 292.
- The call site at line 371 does not pass the Edit's `file_path`.
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` pins the literal: the observed-path assertion at line 405 expects `'artifacts/orchestration/orchestrator-state.json'` and the reader capture block is at roughly lines 395-406. The resolver rows are at lines 366-406 and the suite is 492 lines.
- The Claude copy already has the mandatory `-CheckpointPath` parameter (`.claude/hooks/enforce-completion-consistency.ps1:292`), reads it at line 308, and passes `$filePath` at line 374.

Expected:
- The Codex resolver takes a mandatory `-CheckpointPath` and passes it to the reader unchanged (raw spelling, including backslashes). The decision function passes the parsed `file_path`. The transport suite no longer pins the relative literal.

### Defect 2: Replace semantics

Current:
- Both hooks apply `$onDiskText.Replace($oldString, $newString)` at line 321 (Claude and Codex). `replace_all` is never read.
- Zero occurrences return `$null` (Claude 315-318; Codex equivalent).

Expected:
- Both surfaces reproduce the Edit tool's rule: one occurrence is replaced by default; with `replace_all` true, every occurrence is replaced.
- Zero occurrences, or more than one occurrence without `replace_all`, produce a deny with a specific cause under the existing `COMPLETION_CONSISTENCY_BLOCKED:` token.
- `replace_all` is parsed without a `[bool]` cast (`[bool]'false'` is `$true` in PowerShell). Only the boolean `$true`, or a string equal to `true` (trimmed, case-insensitive), enables replace-all. Absent or any other value means false.
- Matching is ordinal and literal (no regex; `$` in `new_string` stays literal). Line endings are normalized to LF in the checkpoint text, `old_string`, and `new_string` before matching, following the precedent at `.codex/hooks/codex-pretooluse-file-mapping.ps1:431`. Overlapping candidates are counted non-overlapping (for example `aa` in `aaa` is one occurrence).

### Defect 3: Fail-closed on a missing, unreadable, or empty targeted checkpoint

Current:
- Claude `Get-CheckpointFileContent` (69-89) returns `$null` for a missing file (line 87) and throws on an unreadable file (line 89, `-ErrorAction Stop`).
- Claude `Resolve-EditedCheckpointContent` returns `$null` for no/empty `old_string` (299-301), a null/empty reader result (309-312), and an absent `old_string` (315-318).
- Claude `Invoke-CompletionConsistencyDecision` maps a null result to allow (373-379). The test is `if (-not $content)` (line 373), so a Write with `content` of `''` is indistinguishable from an Edit and is allowed.
- The Claude entrypoint (419-423) has no `try/catch`; a reader throw escapes the script (non-blocking exit 1).
- Codex denies a null/empty resolve result (370-378; the reason ends "cannot be deleted, emptied, or replaced through an unresolved patch.") and its entrypoint converts exceptions to `exit 2` (line 437), which is a stderr block rather than a structured deny.

Expected:
- On both surfaces, a missing, empty, or unreadable targeted checkpoint, an unresolvable Edit (no or empty `old_string`, zero occurrences, ambiguous occurrences), and a Write whose `content` property is present but empty all produce a structured deny with exit 0.
- Reader exceptions are caught and converted to a structured deny whose cause names the failure; no uncaught throw reaches the entrypoint on Claude.
- The checkpoint-path gate stays first: a missing `file_path` or a non-checkpoint target is allowed without invoking the reader, so no non-checkpoint target is newly denied.
- Deny reason format: `COMPLETION_CONSISTENCY_BLOCKED: the canonical checkpoint cannot be deleted, emptied, or replaced through an unresolved patch (<cause>).` The leading token and the phrase "replaced through an unresolved patch" are preserved because `codex-pretooluse-transport.Tests.ps1:216` matches that phrase on the subprocess path and line 437 matches `unresolved patch`.
- Cause identifiers: `no-old_string`, `checkpoint-missing`, `checkpoint-empty`, `checkpoint-unreadable`, `old_string-not-found`, `old_string-ambiguous`, and a distinct cause for an empty Write.

### Defect 4: Working-directory-dependent tests

Current:
- `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1:47-51` (the `It` at line 48) omits `-CheckpointReader` and passes a relative path, so the default reader runs against whatever exists at the current directory. In a worktree where `artifacts/orchestration/orchestrator-state.json` exists locally (gitignored), the outcome depends on live orchestration state.
- No Claude test drives the default reader. Rows at lines 374-401 and `...EditTarget.Tests.ps1` lines 142-152 and 167-213 pin allow-on-unresolved.

Expected:
- The relative-path default-reader row is replaced with an injected-reader row.
- Default-reader coverage uses committed fixture files resolved from `$PSScriptRoot`, never the working directory, and no temporary files are created.
- Allow-on-unresolved rows are flipped to deny.

## Functional Requirements

- FR-1. Add to both `enforce-completion-helpers.ps1` copies (identical content): `Get-EditReplaceAllFlag -ToolInput` and `Invoke-SingleOccurrenceEdit -Text -OldString -NewString -ReplaceAll` (returns an object with `Content` and `Failure`), both pure (no I/O).
- FR-2. In both hooks, `Resolve-EditedCheckpointContent` takes `-ToolInput`, `-CheckpointReader`, and a mandatory `-CheckpointPath`; it returns an object with `Content` and `Failure` instead of `$null`/string, and wraps the reader call in `try/catch` to produce `checkpoint-unreadable`.
- FR-3. In both hooks, the decision function passes the parsed `file_path` to the resolver, distinguishes Write (a `content` property is present) from Edit, and denies on any resolver `Failure` and on an empty Write.
- FR-4. Both decision functions keep the gate order: envelope check, empty `file_path` allow, non-checkpoint allow, then Write/Edit handling. The reader is never invoked for non-checkpoint targets.
- FR-5. Invalid-JSON patched or written content keeps its current per-surface behaviour (Claude allow, Codex deny); this is unchanged.
- FR-6. Correct the stale Codex header (lines 32-36) which states Edit calls are allowed.
- FR-7. Update the four bundled mirrors to byte-identical copies of the changed canonical files.
- FR-8. Rewrite the Codex transport rows at 366-406 as new sibling-suite rows (the transport file must shrink) and flip the Claude allow-on-unresolved rows to deny.
- FR-9. Add hermetic default-reader tests using committed fixtures resolved from `$PSScriptRoot`:
  - non-empty: `tests/fixtures/worktree-resolution/pr-author/item-own-not-ready/artifacts/orchestration/orchestrator-state.json` (contains `"next_step": "S8_create_pr"`; `"not_started"` occurs twice);
  - empty: `tests/fixtures/worktree-resolution/shared/item-own-empty/artifacts/orchestration/orchestrator-state.json`;
  - invalid JSON: `tests/fixtures/worktree-resolution/shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json`;
  - missing: a sibling directory that does not exist under the same fixtures root.
  Include a precondition `It` that fails clearly if the fixture no longer contains the expected tokens.

## Non-Functional Requirements

- NFR-1 Fail-closed: every unresolved, unreadable, or ambiguous state on a checkpoint target denies; no branch allows on uncertainty.
- NFR-2 Parity: Claude and Codex give identical allow/deny outcomes and identical cause identifiers for the same Edit/Write input on a checkpoint target (apart from the documented invalid-JSON difference). The Claude and Codex helper files are byte-identical to each other.
- NFR-3 No temporary files in tests (repository policy). Tests do not use `Start-Sleep`, wall-clock waits, the working directory, or the live gitignored checkpoint.
- NFR-4 Hermetic: new and rewritten suites do not depend on cwd or local orchestration state, and their file names contain `completion-consistency` so that the #737 (C5b) discovery guards find them.
- NFR-5 File size: no file exceeds 500 lines. `enforce-completion-consistency.Tests.ps1` (491 lines) must not grow; `codex-pretooluse-transport.Tests.ps1` (492 lines) must shrink. New tests go in new sibling files, split before approaching 450 lines.
- NFR-6 Mirror parity: the four bundled mirrors under `extensions/drm-copilot/resources/` are byte-identical to the canonical files; bundle-parity tests remain green.
- NFR-7 No Python anywhere in the hooks.
- NFR-8 Coverage: line coverage >= 85% for each changed hook and helper file (PowerShell has no branch gate); no regression on changed lines.
- NFR-9 Deny reasons keep the existing leading token `COMPLETION_CONSISTENCY_BLOCKED:`. Production hooks remain within the existing `.claude`/`.codex` runtime-surface separation: no cross-tree dot-sourcing and no new production files.

## Decisions Recorded

- D1. Fail-closed on a missing, empty, unreadable, or unresolvable targeted checkpoint on both surfaces. This supersedes #708 spec D6 for the Claude surface.
- D2. Zero-occurrence and multiple-occurrence-without-`replace_all` edits are denied rather than passed through. The Edit tool rejects these itself, so the deny costs nothing and guards against a stale on-disk read.
- D3. The shared logic lives as pure functions in each tree's own `enforce-completion-helpers.ps1` (approach A in the research); each tree keeps a byte-identical copy.
- D4. An empty `old_string` is denied with cause `no-old_string`; Write remains the supported route for creating a checkpoint.
- D5. Invalid-JSON reconstructed-content divergence is left unchanged (see Out of Scope).
- D6. C5b (#737) is the downstream consumer and adds discovery-based hermeticity guards over these suites.

## Acceptance Criteria

- [x] AC-1: In `.codex/hooks/enforce-completion-consistency.ps1`, `Resolve-EditedCheckpointContent` declares a mandatory `-CheckpointPath` parameter, the literal `'artifacts/orchestration/orchestrator-state.json'` no longer appears as a reader argument, and `Invoke-CompletionConsistencyDecision` passes the Edit's `file_path`. Verified by a new Codex suite `tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1` with rows for absolute, relative, and backslash `file_path` values asserting the reader receives the path unchanged.
- [x] AC-2: `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` no longer pins the relative literal (the resolver rows at 366-406 are removed or rewritten and re-homed), and the file is shorter than its current 492 lines.
- [x] AC-3: Both `enforce-completion-helpers.ps1` copies define `Get-EditReplaceAllFlag` and `Invoke-SingleOccurrenceEdit`, byte-identical to each other. A Pester `Describe` for each surface covers the table {0, 1, 2 occurrences} x {`replace_all` absent, `$false`, `$true`, `'true'`, `'false'`} and asserts: 0 -> `old_string-not-found`; 2 without replace-all -> `old_string-ambiguous`; 1 -> single splice; 2 with replace-all -> all replaced.
- [x] AC-4: The helper tests assert that `replace_all = 'false'` (string) is treated as false (no `[bool]` cast), that overlapping candidates (`aa` in `aaa`) count as one occurrence, that `$` and regex metacharacters in `new_string` stay literal, and that CRLF checkpoint text matches an LF `old_string`.
- [x] AC-5: Decision-level `It` rows on each surface (new Claude file `tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1` and a Codex sibling file) show: an ambiguous patch without `replace_all` denies; the same patch with `replace_all` true is evaluated on the all-replaced content; a single-occurrence patch is evaluated on the spliced content; and at least one case where the allow/deny result differs between replace-all and single-occurrence evaluation.
- [x] AC-6: On both surfaces, each of these yields a `deny` with exit 0 whose reason begins `COMPLETION_CONSISTENCY_BLOCKED:` and contains `replaced through an unresolved patch` and the specific cause: reader returns `$null` (`checkpoint-missing`), reader returns `''` (`checkpoint-empty`), reader throws (`checkpoint-unreadable`), `old_string` absent or empty (`no-old_string`), and a Write with an empty `content` property.
- [x] AC-7: On both surfaces, a non-checkpoint `file_path` with a reader that throws if invoked returns `allow` and the reader is never invoked; a missing `file_path` also allows. This proves no non-checkpoint target is newly denied.
- [x] AC-8: The Claude hook no longer lets a reader exception escape: a Claude test shows an unreadable checkpoint yields a structured deny and exit 0 (driven at the entrypoint if the Claude entrypoint can be run in-process, otherwise at decision level with the `try/catch` conversion asserted).
- [x] AC-9: `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` no longer contains a row that runs the default reader against a relative path (former lines 47-51), still passes, and has no more than 491 lines. Rows formerly at 374-401 and `enforce-completion-consistency.EditTarget.Tests.ps1` lines 142-152 and 167-213 now assert deny, with the `EditTarget` file under 500 lines.
- [x] AC-10: Default-reader tests (Claude and Codex new suites) resolve the four fixtures named in FR-9 from `$PSScriptRoot` and assert: an Edit changing `next_step` to `complete` on the non-empty fixture denies naming `ci_gate` (proving the file was read); an Edit to a non-completion value allows; `"not_started"` to `"pending"` without `replace_all` denies as ambiguous and with `replace_all` allows; the empty fixture denies as empty; the missing path denies as missing. A precondition `It` asserts the fixture tokens.
- [x] AC-11: The new and rewritten suites do not use `New-TemporaryFile`, `$env:TEMP`, `TestDrive`, `Set-Location`/`Push-Location` dependence (other than an optional documented cwd row wrapped in `try/finally`), `Start-Sleep`, or a read of the live `artifacts/orchestration/orchestrator-state.json`; they pass when run from a different working directory and when the local gitignored checkpoint is absent or present. Verified by a grep over the new suites and by running them from two directories.
- [x] AC-12: The deny reason text keeps the substrings `COMPLETION_CONSISTENCY_BLOCKED:` and `replaced through an unresolved patch`; the existing subprocess row at `codex-pretooluse-transport.Tests.ps1:216-220` and the assertion at line 437 pass without a change to their markers.
- [x] AC-13: The stale Codex header (lines 32-36) is corrected so it no longer states Edit calls are allowed.
- [x] AC-14: Each of the four bundled mirrors (`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`, `.../enforce-completion-helpers.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`, `.../enforce-completion-helpers.ps1`) is byte-identical to its canonical file. Verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, and `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` (SHA-256 check) all passing in CI.
- [x] AC-15: No Python is invoked from any changed hook; `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes.
- [x] AC-16: No changed production or test file exceeds 500 lines (`.claude/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, both helper files, and every new or modified test file), verified by line counts.
- [x] AC-17: PowerShell line coverage is >= 85% for each of `.claude/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, and both `enforce-completion-helpers.ps1` files, with no regression on changed lines, from the Pester coverage report (read per file by `package` path because the filename exists under both trees).
- [x] AC-18: The full PowerShell toolchain (format, analyze, test) passes in a single pass, and the existing completion-consistency suites (`enforce-completion-consistency.Tests.ps1`, `.EditTarget.Tests.ps1`, `.Payload.Tests.ps1`, `enforce-completion-consistency-codex.Tests.ps1`, `codex-completion-consistency-hook.Tests.ps1`, `enforce-completion-consistency-epic-scope.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`) pass.
- [x] AC-19: Follow-ups for the out-of-scope items are recorded as issues or in the feature's follow-up artifact: cwd-relative patch-source read in `Resolve-CodexUpdatedFileContent`, invalid-JSON reconstructed-content divergence, and the `enforce-checkpoint-monotonic.ps1` split.

## Out of Scope

- The cwd-relative patch-source read in `Resolve-CodexUpdatedFileContent` (`.codex/hooks/codex-pretooluse-file-mapping.ps1`, relative `Test-Path` near line 426). This file must not gain content (474 lines). Recorded as a follow-up.
- The invalid-JSON reconstructed-content divergence (Claude allows at 385-389; Codex denies). Recorded as a follow-up.
- `enforce-checkpoint-monotonic.ps1` and its similar Claude-allow versus Codex-deny split. Recorded as a follow-up.
- The cwd-relative default `FolderExistsCheck` on both surfaces.
- `MultiEdit` handling (not matched by `.claude/settings.json` `Write|Edit`).
- Discovery-based hermeticity guards and helper-pair byte-parity tests (C5b, #737).
- Changing `.claude/lib/hook-payload/HookPayload.psm1` (497 lines).
- Post-merge live confirmation (#708 follow-up 5) is a manual step outside the automated criteria.

## Risks and Mitigations

- Behaviour change: previously allowed Claude Edits (missing, empty, not found) are now denied. Mitigation: the Edit tool rejects those same cases itself, and Edit requires a prior Read. A false deny is possible only if the hook's view of the file diverges from the tool's (curly-quote normalization, concurrent change); LF normalization covers CRLF. The residual risk is accepted.
- Write with empty `content` is now denied on Claude (previously allowed). This aligns with Codex "emptied" semantics.
- The resolver return type changes from `$null`/string to an object. No in-repo caller other than the decision functions and tests was found; out-of-tree callers would break.
- Mirror drift: the four mirrors are manual copies. Mitigation: byte-equality tests (AC-14); the Python bundle-parity test has a known local false failure on gitignored state (#510), so confirm in CI.
- Test-file headroom (491/500 and 492/500): accidental growth violates the cap. Mitigation: AC-9, AC-2, AC-16 and new sibling files.
- Fixture dependence: the default-reader tests depend on shared worktree-resolution fixtures that other suites own. Mitigation: the precondition `It` fails with a clear message when a fixture changes. Dedicated fixtures were rejected because an empty or checkpoint-named file written by a tool is itself intercepted by the monotonic and completion hooks.
- Unverified Edit tool details (curly-quote normalization, empty `old_string` as file creation) are not modelled; any such divergence fails closed.
- `quality-tiers.yml` classification of the hooks was not read; if the new pure helpers are T1/T2, property-based tests would be required and must be added.

## Rollout and Follow-up

- Release: ships with the next extension bundle; mirrors must be updated in the same change.
- Post-merge: live confirmation of an isolated-worktree subagent completing its checkpoint by Edit on both surfaces (#708 follow-up 5).
- File follow-up issues for the three out-of-scope items.
- Links: issue #736, epic #852, #708 / PR #726, C5b #737.
