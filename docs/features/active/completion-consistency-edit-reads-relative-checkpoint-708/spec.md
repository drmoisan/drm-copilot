# completion-consistency-edit-reads-relative-checkpoint (Spec)

- **Issue:** #708
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T03-15
- **Status:** Approved (autonomous mode; operator instruction of 2026-09-26 waives further approvals)
- **Version:** 1.0
- **Work Mode:** full-bug (acceptance criteria source: this file only)
- **Research:** `research/research.2026-09-27T03-00.md`

## Context

- **Summary.** For an Edit tool call on the orchestrator checkpoint, `.claude/hooks/enforce-completion-consistency.ps1` reconstructs the post-edit checkpoint by applying `old_string` -> `new_string` to the on-disk file. `Resolve-EditedCheckpointContent` reads that file through a hard-coded relative literal, `'artifacts/orchestration/orchestrator-state.json'` (line 300), instead of the path the Edit call targets (`tool_input.file_path`). The relative literal resolves against the hook process working directory.
- **Observed environment.** Any host. The defect is visible when the hook process working directory is not the worktree that contains the targeted checkpoint, for example an isolated-worktree subagent editing its own checkpoint while the session root is the main checkout.
- **Impact.** When the working directory differs from the target worktree, the patch is applied to a different file or to no file. A missing file or an absent `old_string` returns `$null`, which the caller converts to allow (lines 367-371). A completion-asserting Edit against another worktree's checkpoint is therefore allowed without evidence validation, or is validated against unrelated content. Severity: Medium (issue #708).
- **First observed.** Recorded as out-of-scope follow-up item 2 of #663 (`docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/follow-ups.md`).

## Repro & Evidence

- **Steps.** Start a session rooted at the main checkout. From a subagent in an isolated worktree, Edit that worktree's `artifacts/orchestration/orchestrator-state.json`. The hook's on-disk read resolves against the process working directory, not the target worktree.
- **Expected.** The Edit-patch branch reads the checkpoint at the path the Edit call targets.
- **Actual.** The Edit-patch branch reads the relative literal (line 300) through `Get-CheckpointFileContent` (lines 65-86), which uses `Test-Path -LiteralPath` and `Get-Content -LiteralPath` against the process working directory.
- **Frequency.** Deterministic whenever the working directory and the targeted worktree differ.
- **Why the current suite passes.** Every Edit-path test in `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` injects a `CheckpointReader` that ignores its `$Path` argument (research section 3.2).

## Root Cause Analysis

- **Confirmed root cause.** `Resolve-EditedCheckpointContent` (lines 262-314) never consults `tool_input.file_path`; line 300 passes a fixed relative string to the reader. The caller has already validated `file_path` against the checkpoint regex at line 357 but does not pass it on.
- **Contributing documentation drift.** The script `.DESCRIPTION` (lines 32-36) still states that Edit calls "are allowed by this hook", which contradicts the read-then-validate implementation (lines 262-275, 361-363).
- **Affected components.** `.claude/hooks/enforce-completion-consistency.ps1` and its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`. The Codex copy `.codex/hooks/enforce-completion-consistency.ps1` carries the same defect at line 308; it is deferred (D5).

## Design Decisions

### D1. Source of the Edit-path checkpoint read

- **Options.** (A) Read the payload `tool_input.file_path` directly. (B) Resolve a relative `file_path` against the payload `cwd`. (C) Resolve the item's worktree through portable identity (issue number or branch, as in `enforce-model-routing-receipt.ps1`) and read that worktree's checkpoint.
- **Adopted.** (A).
- **Rationale.** The Claude Code Edit tool declares `file_path` as an absolute path, so reading it targets the exact file the Edit will change, independent of the process working directory. A relative `file_path` resolves exactly as today. Option B adds an envelope dependency with no benefit, because payload `cwd` has been observed to equal the hook process working directory and does not identify the target item. Option C is indirect and could validate a file other than the one being edited. The path is runtime payload data used in memory only; no path is persisted into any artifact.

### D2. How the path reaches the reader

- **Options.** (a) Add a mandatory `-CheckpointPath` parameter to `Resolve-EditedCheckpointContent`, supplied by the caller from `$filePath`. (b) Have the function read `$ToolInput.file_path` internally.
- **Adopted.** (a). Line 300 becomes `& $CheckpointReader $CheckpointPath`, and the call at line 366 passes `-CheckpointPath $filePath`.
- **Rationale.** The input contract is explicit and testable, the value is already validated by the caller, and there is no silent fallback to the relative literal. The raw `file_path` string is passed, not the backslash-normalized `$normalized` value, so the reader receives exactly what the Edit targets. The only in-repo caller of the Claude function is line 366 (verified by search); the Codex copy defines its own function and is unaffected.

### D3. Regression-test location

- **Options.** (a) Extend `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` (491 lines). (b) Extend `enforce-completion-consistency.Payload.Tests.ps1` (different aspect). (c) Add a new sibling `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1`.
- **Adopted.** (c).
- **Rationale.** The main file has no headroom under the 500-line limit, and the `<hook>.<Aspect>.Tests.ps1` naming follows existing precedent (`.Payload.Tests.ps1`, `*.EpicScope.Tests.ps1`). `config/poshqc-scan.json` already scans `tests/scripts`, so no configuration change is needed.

### D4. Test seam and portability

- **Options.** (a) Injected path-keyed fake `CheckpointReader`. (b) Real files at a non-working-directory path. (c) `Set-Location` into a fixture directory.
- **Adopted.** (a). The fake reader returns checkpoint text only when `$Path` equals the targeted `file_path` and returns `$null` or different text for any other argument, including the relative literal. Targeted paths use a POSIX-style string that is never touched on disk (for example `/work/item-worktree/artifacts/orchestration/orchestrator-state.json`).
- **Rationale.** Temporary files are prohibited, the real checkpoint is gitignored, and implicit working-directory assumptions are prohibited by the PowerShell test policy. A fake reader performs no filesystem call, so the same string behaves identically on Windows and Linux CI. The tests do not depend on gitignored state, `origin/main`, network access, or Windows-only paths (no drive letters).

### D5. Test entry point (fail-before as an assertion failure)

- **Options.** (a) Drive the new tests through `Invoke-CompletionConsistencyDecision` with a full envelope and `-CheckpointReader`. (b) Call `Resolve-EditedCheckpointContent` directly with `-CheckpointPath`.
- **Adopted.** (a) for all fail-before-relevant cases.
- **Rationale.** Against the pre-fix hook, option (b) fails with a parameter-binding error rather than a behavioral assertion, which does not demonstrate the defect. Option (a) runs unchanged against both versions, so the pre-fix failure is the decision or captured-path assertion itself.

### D6. Fail semantics when the targeted file cannot be read

- **Options.** (a) Preserve the current Claude behavior. (b) Change missing or unreadable to deny, matching the Codex copy.
- **Adopted.** (a).
- **Rationale and precise meaning of "fails closed as before".** The Claude hook does not fail closed on a missing file today. Behavior "as before" is defined as the following unchanged table, now evaluated against the targeted `file_path`:

  | Condition on the Edit path | Behavior (before and after) |
  |---|---|
  | Envelope anomaly (empty, unparseable, missing/null/non-object `tool_input`) | deny with `COMPLETION_CONSISTENCY_BLOCKED: payload anomaly - ...` (the only fail-closed branch) |
  | No `old_string` | allow |
  | Targeted file missing or empty | allow |
  | `old_string` absent from the targeted file's text | allow |
  | Patched content is not valid JSON | allow |
  | Targeted file exists but `Get-Content` throws | terminating error propagates; `pwsh` exits non-zero without JSON output (unchanged) |

  Changing these semantics is a separate policy decision, would invert the existing test at `enforce-completion-consistency.Tests.ps1:374-386`, and exceeds a minimal bug fix.

### D7. Codex mirror scope

- **Options.** (a) Claude hook only; record the identical Codex Edit-branch defect (`.codex/hooks/enforce-completion-consistency.ps1:308`) as a follow-up. (b) Include the Codex hook, its bundled copy, and a rewrite of `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1:363-403`.
- **Adopted.** (a).
- **Rationale.** The issue and every acceptance criterion name the Claude hook. No test couples the Claude and Codex hooks. Sibling #707 rewrites `.codex/hooks/enforce-completion-consistency.ps1`, so including Codex creates the only textual merge overlap in this run. Option (b) also needs four production PowerShell files, which exceeds the per-session cap of three.

### D8. Bundled mirror

- **Adopted.** Copy the modified `.claude/hooks/enforce-completion-consistency.ps1` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`. Required, not optional.
- **Rationale.** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` enforces equality between every repository `.claude` file and its bundled copy. No sync script exists, so the mirror is a second file write.

### D9. Bundle-parity local false failure (issue #510)

- **Options.** (a) Remove gitignored `.claude/state/*-batch-budget.*.json` files before running the bundle-parity test locally. (b) Rely on CI for that one test.
- **Adopted.** Either is acceptable; the executor records which was used in the QA-gate evidence. Byte identity of the two hook files is additionally verified directly by hash comparison.
- **Rationale.** The batch-budget hook writes those gitignored files during implementation, and the parity test walks the filesystem, producing a local failure unrelated to this change.

### D10. Documentation correction in the same file

- **Adopted.** Rewrite the `.DESCRIPTION` text at lines 32-36 and the `Resolve-EditedCheckpointContent` help at lines 267-274 so they state that Edit calls are validated by reading the Edit's targeted `file_path` and applying the patch in memory, and that unresolved patches are allowed.
- **Rationale.** The file is already in scope; the stale header contradicts the implementation.

### D11. Out-of-scope observations recorded, not fixed

- **Adopted.** Record the following as follow-up candidates in `evidence/other/follow-ups.md` and do not expand scope:
  1. Patch application uses `String.Replace`, which replaces every occurrence of `old_string` (line 313); the Edit tool replaces a single unique occurrence unless `replace_all` is set.
  2. The test at `enforce-completion-consistency.Tests.ps1:47-51` uses the default reader with a relative `file_path`, so its outcome depends on the test process working directory.
  3. The Codex Edit-branch instance of this defect (D7), including the pinned assertion in `codex-pretooluse-transport.Tests.ps1:392-403`.
- **Rationale.** Each is a distinct behavior change with its own test impact; bundling them would widen the diff and the merge surface.

## Scope & Non-Goals

- **In scope.** The Edit-path read source in the Claude completion-consistency hook, its bundled copy, the stale header text, and a new regression test file.
- **Out of scope.** The Codex hook and its bundled copy; `String.Replace` semantics; fail-semantics changes on a missing or unreadable file; `.claude/hooks/enforce-completion-helpers.ps1`; `.claude/lib/hook-payload/HookPayload.psm1`; `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`; the Write-path branch; coverage configuration.
- **Not required.** A live end-to-end confirmation with an isolated subagent. Isolated subagents load `main`'s hook scripts, so live confirmation is possible only after merge; no acceptance criterion depends on it.

## Proposed Fix

### Design summary

- `Resolve-EditedCheckpointContent` gains `[Parameter(Mandatory)] [string] $CheckpointPath` and calls `& $CheckpointReader $CheckpointPath` in place of the literal.
- `Invoke-CompletionConsistencyDecision` passes `-CheckpointPath $filePath` (the raw `tool_input.file_path`) at line 366.
- Header and function help corrected per D10.
- Bundled copy updated byte-for-byte per D8.

### Boundaries and invariants to preserve

- Decision ordering is unchanged: envelope, `file_path`, checkpoint-path match, content (Write) or patch (Edit), JSON parse, completion assertion, evidence.
- The reader can only be called with a path that already matched `(^|/)artifacts/orchestration/orchestrator-state\.json$`; the change does not widen what the hook reads.
- Write-path behavior and the default `CheckpointReader` are unchanged.
- All fail semantics in the D6 table are unchanged.
- No absolute host path is persisted in code, tests, fixtures, or evidence.

### Interfaces and contracts

- **Input.** Claude PreToolUse envelope `{tool_name, tool_input: {file_path, old_string, new_string, ...}}`, unchanged.
- **Output.** PreToolUse JSON `hookSpecificOutput.permissionDecision` of `allow` or `deny`, unchanged in shape.
- **Internal contract change.** `Resolve-EditedCheckpointContent` now requires `-CheckpointPath`. The only in-repo caller is updated in the same change.
- **Configuration.** None. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` already lists the Claude hook in `CodeCoverage.Path`.
- **Performance.** One file read per Edit, as today.

### Rollback

Revert the commit; the change is confined to one production file, its byte-identical copy, and one new test file.

## Files Written by This Change

Repository-relative paths. Files that are only read (for example `.codex/hooks/enforce-completion-consistency.ps1`, `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `issue.md`, and the plan file) are not listed.

Production:

1. `.claude/hooks/enforce-completion-consistency.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`

Tests:

3. `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1` (new)

Feature documents and evidence (feature folder `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/`):

4. `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/spec.md` (this file; acceptance-criteria check-off)
5. `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/baseline/baseline.md`
6. `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/regression-testing/edit-target-fail-before.md`
7. `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/regression-testing/edit-target-pass-after.md`
8. `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/qa-gates/qa-gates.md`
9. `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/other/follow-ups.md`

PowerShell batch budget: two production files and one test file, within the per-session cap of three each.

## Merge-Order Independence

The change must be correct whether or not sibling items #707, #709, #710, and #713 of run `followups-2026-09-27` merge first. Overlap analysis (research section 5):

| Sibling | Files named | Overlap with #708 |
|---|---|---|
| #707 codex-gates-4-5-lack-epic-scope | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`, and their bundled copies | None, because #708 does not write any `.codex` file (D7). It would be high if #708 included the Codex hook. |
| #709 gate-suites-read-unmocked-local-epic-state | `enforce-pr-author-skill*`, `enforce-model-routing-receipt*`, `enforce-orchestration-preimplementation-gate*` suites under `tests/scripts/claude-hooks/` | None (gates 1, 3, 4; not gate 5). |
| #710 preimplementation-helpers-backslash-chain-operator | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its byte-identical copies | None. |
| #713 preimplementation-gate-blocks-attribution-trailers | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | None. |

Measures that keep the change order-independent:

1. The write set is limited to the files listed above. No sibling names any of them.
2. `.claude/hooks/enforce-completion-helpers.ps1`, `.claude/lib/hook-payload/HookPayload.psm1`, and `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` are not edited.
3. The bundle-parity test compares each `.claude` file independently, so a sibling that updates a different `.claude` file with its own bundled copy cannot break this change's parity, and this change cannot break the sibling's.
4. Immediately before PR creation, rebase onto `origin/main` and re-run the verification set (new test file, existing `enforce-completion-consistency*.Tests.ps1` suites, `PreToolUseSchema.Contract.Tests.ps1`, bundle parity, PoshQC gates) so any sibling that merged first is included in the verified tree.

## Test Strategy

New file `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1`: dot-sources the hook, uses Arrange-Act-Assert, drives `Invoke-CompletionConsistencyDecision` with a full envelope (D5), and injects only `-CheckpointReader` (plus `-FolderExistsCheck` where an allow outcome requires it).

- **Working-directory mismatch, deny (fail-before).** Absolute POSIX-style `file_path`; path-keyed reader returns a non-completion checkpoint only for that path; the patch asserts completion without evidence. Expect deny. Pre-fix result: allow.
- **Wrong-file content ignored.** The reader returns different text for the targeted path and for the relative literal; the decision follows the targeted path's content.
- **Reader receives the exact path.** Path-capturing reader for an absolute POSIX spelling, the relative spelling `artifacts/orchestration/orchestrator-state.json`, and a backslash spelling passed as a pure string. The captured value equals the supplied `file_path` unchanged. The absolute and backslash cases fail pre-fix; the relative case passes before and after.
- **Preservation, missing targeted file.** The reader returns `$null` for the targeted path. Expect allow.
- **Preservation, envelope anomaly.** Already covered by `enforce-completion-consistency.Payload.Tests.ps1:21-51`; run as a regression.

Evidence: run the new file against the unmodified hook and record the failures, then run it after the fix and record the passes. Run the targeted Pester files directly for these runs, because PoshQC MCP summaries do not carry per-test output. Run the PowerShell toolchain (format, analyze, test) and the bundle-parity pytest.

## Acceptance Criteria

- [x] For an Edit call whose `tool_input.file_path` matches the checkpoint pattern, `Invoke-CompletionConsistencyDecision` passes the raw `tool_input.file_path` string, unchanged, to the `CheckpointReader`; the literal `'artifacts/orchestration/orchestrator-state.json'` is no longer passed to the reader by `Resolve-EditedCheckpointContent`.
- [x] `Resolve-EditedCheckpointContent` declares a mandatory `-CheckpointPath` parameter, and its only caller in `.claude/hooks/enforce-completion-consistency.ps1` supplies it from `tool_input.file_path`.
- [x] With an absolute POSIX-style `file_path` and an injected reader that returns checkpoint content only for that path, an Edit whose patch asserts completion without the required evidence returns `deny` with a `COMPLETION_CONSISTENCY_BLOCKED` reason; the same test returns `allow` against the pre-fix hook.
- [x] When the injected reader returns different content for the targeted `file_path` and for the relative literal, the allow/deny decision is derived from the targeted `file_path`'s content.
- [x] A relative `file_path` (`artifacts/orchestration/orchestrator-state.json`) reaches the reader unchanged and yields the same decisions as before the fix; an absolute `file_path` and a backslash-spelled `file_path` reach the reader unchanged.
- [x] The Edit-path fail semantics in D6 are unchanged: an envelope anomaly returns `deny` with the payload-anomaly reason; a missing or empty targeted file, a missing `old_string`, or an `old_string` absent from the targeted file's text returns `allow`; and the existing tests covering these branches pass without modification.
- [x] Write-path behavior is unchanged: the existing `enforce-completion-consistency.Tests.ps1`, `enforce-completion-consistency.Payload.Tests.ps1`, and `PreToolUseSchema.Contract.Tests.ps1` suites pass without modification.
- [x] The script `.DESCRIPTION` and the `Resolve-EditedCheckpointContent` help describe reading the Edit's targeted `file_path` and no longer state that Edit calls are allowed without validation.
- [ ] `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` is byte-identical to `.claude/hooks/enforce-completion-consistency.ps1` (matching SHA-256 recorded in evidence), and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes in CI (and locally, with the #510 handling recorded per D9).
- [x] Regression tests in `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1` fail against the pre-fix hook and pass after the fix, with both runs recorded under `evidence/regression-testing/`.
- [x] The new tests use an injected reader only, and do not create temporary files, call `Set-Location`, read gitignored state, depend on `origin/main`, or use Windows-only paths.
- [x] PoshQC format and analyze report no findings on the changed PowerShell files, PoshQC test passes, and line coverage for `.claude/hooks/enforce-completion-consistency.ps1` is at least 85% with no regression on changed lines.
- [x] No production or test file written by this change exceeds 500 lines.
- [x] No `.codex` file is modified, and the out-of-scope observations in D11 are recorded in `evidence/other/follow-ups.md`.

## Risks & Mitigations

- **Risk.** A caller outside the repository invokes `Resolve-EditedCheckpointContent` without `-CheckpointPath`. **Mitigation.** The function is internal to the hook script; search confirms a single caller. A mandatory parameter fails explicitly rather than falling back to the relative literal.
- **Risk.** The bundle-parity test fails locally for reasons unrelated to this change (#510). **Mitigation.** D9, plus direct hash comparison.
- **Risk.** A sibling merges first and shifts line numbers. **Mitigation.** Rebase and re-verify before PR creation (Merge-Order Independence, measure 4).

## Out of Scope and Follow-ups

1. Codex Edit-branch defect at `.codex/hooks/enforce-completion-consistency.ps1:308` and its bundled copy, including the pinned test at `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1:392-403`. Sequence after #707 merges.
2. `String.Replace` replaces every occurrence of `old_string`; the Edit tool replaces a single unique occurrence unless `replace_all` is set.
3. The test at `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1:47-51` depends on the test process working directory through the default reader.
4. Whether the Claude hook should deny, rather than allow, when the targeted checkpoint is missing or unreadable (policy decision; Codex already denies).
5. Post-merge live confirmation with an isolated-worktree subagent (optional; not an acceptance criterion).

## Rollout & Follow-up

- **Rollout.** Merge to `main`; the hook takes effect for sessions that load `main`'s hook scripts. The extension payload reflects the change after the next extension build and reinstall.
- **Links.** Issue #708; research `research/research.2026-09-27T03-00.md`; origin `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/follow-ups.md` item 2.
