# Research: completion-consistency Edit path reads the relative checkpoint (Issue #708)

- **Issue:** #708 (bug, work mode full-bug)
- **Branch:** bug/completion-consistency-edit-reads-relative-checkpoint-708
- **Research timestamp:** 2026-09-27T03-00
- **Tree inspected:** agent worktree based on origin/main `218b518e`
- **Inputs:** `issue.md` (issue body and Acceptance Criteria). `spec.md` and `plan.2026-09-26T22-56.md` in the feature folder are unfilled templates.

All file:line citations below were verified by reading the files in this tree. No numeric acceptance criterion is proposed in this document, so no `## Numeric Derivation Evidence` section is required.

---

## 1. Current State: `.claude/hooks/enforce-completion-consistency.ps1` (415 lines)

### 1.1 Load and entrypoint

| Lines | Behavior |
|---|---|
| 45 | Imports `../lib/hook-payload/HookPayload.psm1` (shared envelope reader). |
| 48-49 | Dot-sources `enforce-completion-helpers.ps1` (`Test-IsValidIssueNum`, `Test-IsValidFeatureFolder`, `Test-RouteRequiresPrGate`; 163 lines, no path logic relevant to this bug). |
| 407-409 | Dot-source guard: when dot-sourced (tests), returns before the entrypoint. |
| 411 | Entrypoint: `Invoke-CompletionConsistencyDecision -ToolInputRaw (Read-ClaudeHookRawPayload)` with **no seams overridden**, so the default `CheckpointReader` is used. |
| 413-415 | Emits the decision as compressed JSON and `exit 0`. There is no `try/catch` around the entrypoint. |

The hook is registered in `.claude/settings.json:164` as `pwsh -NoProfile -File .claude/hooks/enforce-completion-consistency.ps1` (relative script path, so the process cwd is the directory in which Claude Code runs the hook).

### 1.2 Decision flow (`Invoke-CompletionConsistencyDecision`, lines 316-404)

1. **Seams (lines 327-334):** `FolderExistsCheck` (default `Test-Path -PathType Container`), `CheckpointReader` (default `{ param($Path) Get-CheckpointFileContent -Path $Path }`, line 331), optional `RoutingMatrixReader`.
2. **Envelope parse (lines 337-348):** `Resolve-ClaudeHookToolInput`. An invalid envelope (empty, unparseable, missing/null/non-object `tool_input`) returns **deny** with `COMPLETION_CONSISTENCY_BLOCKED: payload anomaly - ...` (fail closed).
3. **file_path (lines 350-354):** `Get-ClaudeHookToolInputString -Name 'file_path'`; empty returns allow.
4. **Path match (lines 356-359):** backslashes normalized to `/`; `Test-IsCheckpointPath` (lines 88-97) matches `(^|/)artifacts/orchestration/orchestrator-state\.json$`, so both relative and absolute spellings match. Non-matching path returns allow.
5. **Content source (lines 364-372):**
   - Write: `content` from `tool_input` is used directly.
   - Edit (no `content`): `Resolve-EditedCheckpointContent -ToolInput $toolInput -CheckpointReader $CheckpointReader` (line 366). A `$null`/empty result returns **allow** (lines 367-371, comment "defer and allow").
6. **JSON parse (lines 374-381):** `ConvertFrom-CheckpointJson`; parse failure returns allow.
7. **Completion assertion (lines 383-385):** `Test-CompletionAsserted` (lines 131-170); not asserted returns allow.
8. **Evidence (lines 387-403):** `Get-MissingCompletionEvidence` (lines 172-260); none missing returns allow, otherwise deny with the `COMPLETION_CONSISTENCY_BLOCKED` reason (line 396).

### 1.3 The defect

- `Resolve-EditedCheckpointContent` (lines 262-314) reads `old_string` (287-293) and `new_string` (295-298), then calls the reader with a **hard-coded relative literal** at line 300:

  ```powershell
  $onDisk = & $CheckpointReader 'artifacts/orchestration/orchestrator-state.json'
  ```

  The function never consults `$ToolInput.file_path`, even though the caller has already verified (line 357) that `file_path` names a checkpoint.
- The default reader `Get-CheckpointFileContent` (lines 65-86) does `Test-Path -LiteralPath $Path -PathType Leaf` (82) then `Get-Content -LiteralPath $Path -Raw -ErrorAction Stop` (85). A relative `-LiteralPath` resolves against the PowerShell current location, which is the hook process cwd.
- Consequence: when the hook process cwd is not the worktree that contains the targeted checkpoint, the patch is applied to a different file (or to none). A missing file or an absent `old_string` yields `$null`, which the caller turns into **allow** (line 370). A completion-asserting Edit made against another worktree's checkpoint is therefore allowed without evidence validation, or is validated against unrelated content.
- Patch application (line 313) uses `String.Replace`, which replaces every occurrence of `old_string`. The Edit tool replaces a single unique occurrence unless `replace_all` is set. This is a separate semantic divergence and is out of scope for #708; it is recorded here only so it is not mistaken for part of this fix.

### 1.4 Stale documentation in the same file

The `.DESCRIPTION` block at lines 32-36 still states that Edit calls "are allowed by this hook". Lines 262-275 and 361-363 describe the read-then-validate Edit path that replaced that behavior. The fix should correct lines 32-36 so the header matches the implementation.

### 1.5 Existing fail semantics relevant to AC-3

| Condition on the Edit path | Current Claude behavior |
|---|---|
| Envelope anomaly | deny (fail closed), lines 337-348 |
| No `old_string` | allow, lines 291-293 then 367-371 |
| Targeted file missing or empty | allow, lines 301-304 then 367-371 |
| `old_string` absent from on-disk text | allow, lines 307-310 then 367-371 |
| File exists but `Get-Content` throws | terminating error propagates out of the decision function; no `try/catch` at lines 411-415, so `pwsh` exits non-zero without JSON output |

AC-3 says the hook "still fails closed as before when the targeted file cannot be read". The Claude copy does **not** fail closed on a missing file today; it allows. The only fail-closed branch is the envelope-anomaly deny. "As before" is therefore satisfied by preserving the current behavior unchanged; see Recommendation D4.

---

## 2. Codex Mirror

### 2.1 Same defect is present

`.codex/hooks/enforce-completion-consistency.ps1` (438 lines) carries an identical `Resolve-EditedCheckpointContent` (lines 270-322) with the same literal read at **line 308**, and an identical `Get-CheckpointFileContent` (lines 73-94).

Differences from the Claude copy:

- Transport: raw stdin to `ConvertFrom-CodexPreToolUsePayload`, then `ConvertTo-CodexFileEditInput -ResolveUpdateContent -GovernedPath` (lines 418-438). Errors exit 2.
- Unresolved Edit is **denied** (lines 370-377, "cannot be deleted, emptied, or replaced through an unresolved patch"); invalid JSON is **denied** (lines 380-388). The Claude copy allows both.
- Edit-shaped input (`tool_input` with `file_path`) is copied property-for-property by `ConvertTo-CodexFileEditInput` (`.codex/hooks/codex-pretooluse-file-mapping.ps1:240-258`). Such input reaches `Resolve-EditedCheckpointContent` and hits the defect at line 308.
- `apply_patch` Update records are reconstructed separately by `Resolve-CodexUpdatedFileContent` (`codex-pretooluse-file-mapping.ps1:393-474`), which reads the patch's own `SourcePath` (line 426/431). That path does not go through line 308 and is not affected by this bug.

Codex exposure is therefore limited to Edit-shaped payloads. `apply_patch` is Codex's native file tool.

### 2.2 Parity requirements (verified)

| Pair | Enforcement | Test |
|---|---|---|
| `.claude/hooks/*` vs `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/*` | Text equality for every repo `.claude` file | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) |
| `.codex/hooks/enforce-completion-consistency.ps1` vs bundled Codex copy | SHA-256 byte identity | `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1:61-68` |
| `.codex/hooks/enforce-completion-helpers.ps1` vs bundled copy | SHA-256 byte identity | same file, lines 70-78 |
| Claude hook vs Codex hook | **None.** The two copies already differ in transport and fail semantics (section 2.1). | n/a |

No test requires the Claude and Codex hooks to be identical to each other. Any change to a canonical hook must be copied to its bundled mirror. There is no sync script (only `bundle:extension` and `bundle:mcp-server` in `extensions/drm-copilot/package.json:205-206`), so the mirror is a second file write.

### 2.3 Existing Codex test that pins the defective literal

`tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1:392-403` ("reads the governed checkpoint path through the injected reader") asserts that the reader receives exactly `'artifacts/orchestration/orchestrator-state.json'`, using a `ToolInput` that has no `file_path`. Lines 363-390 also call `Resolve-EditedCheckpointContent` with `ToolInput` objects that carry no `file_path`. A Codex fix would have to rewrite these rows. That file is 489 lines.

### 2.4 Recommendation on scope

Fix the Claude surface only in #708 and record the Codex Edit-branch instance as a follow-up (see D5). Reasons:

1. The issue and every AC name the Claude hook (`.claude/hooks/enforce-completion-consistency.ps1`, line ranges from that file).
2. Sibling #707 (verified, see section 5) is scoped to rewriting `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1`. Editing the same Codex file in #708 creates the only real merge-overlap risk in this run.
3. No parity test couples the Claude and Codex hooks.
4. Including Codex raises the production-file count to four (two canonical and two bundled). That exceeds the per-session PowerShell cap of three (section 6.3).

Rejected alternative: fix both surfaces in #708. This is technically sound but requires two batches, rewrites the pinned transport-test rows, and conflicts textually with #707. If the operator prefers one-shot parity, the same design (D1) applies unchanged to Codex line 308 and its bundled copy, and #708 should merge after #707 and rebase onto it.

---

## 3. Existing Tests

### 3.1 Inventory

| File | Lines | Target | Payload style | Reader seam | cwd handling | Temp files |
|---|---|---|---|---|---|---|
| `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` | 491 | Claude hook, dot-sourced (line 9-10) | Full envelope JSON `{tool_name, tool_input}` via helper `ConvertTo-CheckpointToolInput` (lines 13-23) | `-CheckpointReader { param($Path) $onDisk }`, which **ignores `$Path`** (lines 336-416, "Gap 3") | none set | none |
| `tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1` | 75 | Claude hook envelope anomalies and entrypoint text | envelope JSON | not used | none set | none |
| `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` | 79 | Codex hook plus bundle byte identity | flat mapped `tool_input` JSON | not used | none | none |
| `tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1` | 168 | Codex evidence branches | flat mapped JSON | available | none | none |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | 489 | Codex transport; spawns `pwsh` with `WorkingDirectory = RepoRoot` (line 65) | Codex envelope | path-capturing reader at 392-403 | process cwd pinned to repo root | none (StringReader for stdin, lines 292-316) |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | n/a | Write-path deny shape only (lines 127-138) | envelope | not used | none | none |

### 3.2 Observations

- No existing test passes a `file_path` that differs from the relative literal while also inspecting the path the reader receives. Every Gap-3 reader ignores `$Path`, which is why the defect passes the current suite.
- The test at `enforce-completion-consistency.Tests.ps1:47-51` uses the **default** reader with a relative `file_path` and `old_string = 'a'`. Its outcome depends on whatever file exists at the relative path under the test process cwd. That is a pre-existing implicit-cwd dependency. The fix does not change its behavior, because a relative `file_path` resolves the same way it does today. It is recorded here as an observation, not a defect this bug must fix.
- Repository precedent for filesystem-free checkpoint tests is the injected `CheckpointReader` scriptblock. The reader's docstring (lines 70-73) states that tests inject it "so no temporary files are required". No suite for this hook uses `TestDrive`, `New-TemporaryFile`, or `Set-Location`.

### 3.3 Where the regression test should live

`enforce-completion-consistency.Tests.ps1` is at 491 of 500 lines, and the Payload sibling's header (lines 8-9) records that the main file "has no headroom under the 500-line ceiling". The regression test should go in a new sibling file, following the `<hook>.<Aspect>.Tests.ps1` naming precedent (`.Payload.Tests.ps1`, and `*.EpicScope.Tests.ps1` elsewhere in `tests/scripts/claude-hooks/`):

- **Recommended:** `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1`

`config/poshqc-scan.json:3-4` scans `tests/scripts`, so the new file is discovered without configuration changes.

### 3.4 Seam for a cwd-mismatch test without temp files or Windows-only paths

Use a **path-keyed fake reader** injected through `-CheckpointReader`. The fake returns checkpoint text only when `$Path` equals the targeted `file_path`, and returns `$null` (or different text) for any other argument, including the relative literal. Use a POSIX-style absolute string that is never touched on disk, for example `/work/item-worktree/artifacts/orchestration/orchestrator-state.json`. The fake reader performs no filesystem call, so the string behaves the same on Windows and Linux.

- Pre-fix: the reader receives the relative literal and returns `$null`, so the result is allow. The assertion `deny` fails, which satisfies the fail-before requirement in AC-4.
- Post-fix: the reader receives the targeted path, the patch flips `next_step` to `complete` without evidence, and the result is deny.

Because the fixed decision function no longer consults the process cwd for an absolute `file_path`, the path-keyed reader models the cwd mismatch without `Set-Location` and without gitignored state. An entrypoint-level test with a real file at a non-cwd path would require a temporary file, because `artifacts/orchestration/orchestrator-state.json` is gitignored. That is prohibited, so the seam-level test is the correct level.

---

## 4. Design Options

### Option A: read the payload `file_path` directly (recommended)

Pass the `tool_input.file_path` string, exactly as supplied, to the `CheckpointReader` in place of the literal. Concretely:

- Give `Resolve-EditedCheckpointContent` a mandatory `-CheckpointPath` parameter, and pass `-CheckpointPath $filePath` from the caller at line 366. The caller has already validated the path at line 357. Alternatively, the function can read `$ToolInput.file_path` itself; the explicit parameter is preferred because it keeps the function's input contract visible and testable.
- Replace line 300 with `& $CheckpointReader $CheckpointPath`.
- Update the header (lines 32-36) and the function help (lines 267-274).

Assessment:

- **Absolute spelling:** the Claude Code Edit tool's schema declares `file_path` as "The absolute path to the file to modify". This was verified against the Edit tool definition available in this session. The production Edit path therefore always carries an absolute path, and reading it directly targets the file the Edit will change, independent of process cwd.
- **Relative spelling:** a relative `file_path` resolves against the process cwd exactly as today, so behavior is unchanged when cwd is the target worktree (AC-3).
- **Host independence:** the path is runtime payload data and is used in memory only. Nothing is persisted, and no absolute path is written into any artifact, test fixture, or checkpoint.
- **Linux CI:** `Test-Path -LiteralPath` and `Get-Content -LiteralPath` accept POSIX absolute paths. Tests use a fake reader, so no drive letters or backslashes are required. Pass the raw string rather than the backslash-normalized `$normalized` value, so the reader receives exactly what the Edit targets. Forward-slash normalization would also work on both platforms, but it adds a transformation the fix does not need.
- **Fail-closed behavior:** unchanged. The same `$null`-to-allow branches and the same envelope-anomaly deny apply.
- **Scope bound:** the reader can only be pointed at a path that already matched the checkpoint regex (line 357). The change does not widen what the hook reads.

### Option B: resolve a relative `file_path` against the payload `cwd`

Read `cwd` from the envelope (`$envelope.Envelope`, available through `Get-ClaudeHookEnvelopeValue`, `HookPayload.psm1:306-330, 478-483`) and join it with a relative `file_path`.

- For Claude Edit calls this adds nothing, because `file_path` is already absolute.
- A recorded empirical probe (2026-09-18, user memory `hook-execution-context-isolated-subagents`) observed that the payload `cwd` equals the hook process cwd for both main-session and isolated-subagent calls. Payload `cwd` also does not identify the target item for coordinator-issued calls. Joining against it would reproduce today's resolution for relative paths while adding a code path, an envelope dependency, and a new failure mode for a missing or odd `cwd`.
- Rejected: no behavioral benefit over Option A, and more surface.

### Option C: portable-identity resolution (worktree-resolution library, issue #673 precedent)

Resolve the item's worktree from issue number or branch, as `enforce-model-routing-receipt.ps1:51-55` does, and read that worktree's checkpoint.

- This is appropriate when the hook must find a checkpoint the tool call does not name, such as delegation gates. Here the tool call names the exact file it will edit, so identity resolution is indirect and can disagree with the actual edit target.
- Rejected: it is more complex, needs no identity signal in an Edit payload, and could validate a file other than the one being edited.

### Recommendation

Option A.

---

## 5. Merge-Order Independence (sibling issues in run followups-2026-09-27)

`gh` is not available to this research agent, so issue bodies were read from the public GitHub issue pages via WebFetch on 2026-09-27.

| Issue | Title | Files named | Overlap with #708 (Claude-only scope) |
|---|---|---|---|
| #707 | codex-gates-4-5-lack-epic-scope | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1` (plus, by the byte-identity tests, their bundled copies) | **None** if #708 is Claude-only. **High** if #708 also edits the Codex hook: the same file, and #707 is likely to touch `Invoke-CompletionConsistencyDecision` near the Edit branch. |
| #709 | gate-suites-read-unmocked-local-epic-state | test suites `enforce-pr-author-skill*`, `enforce-model-routing-receipt*`, `enforce-orchestration-preimplementation-gate*` under `tests/scripts/claude-hooks/` | None: gates 1, 3, and 4, not gate 5. |
| #710 | preimplementation-helpers-backslash-chain-operator | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its three byte-identical copies | None. |
| #713 | preimplementation-gate-blocks-attribution-trailers | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | None. |

How the plan stays correct regardless of merge order:

1. Keep #708's write set to exactly `.claude/hooks/enforce-completion-consistency.ps1`, its bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`, and the new test file. No sibling names any of these paths.
2. Do not edit `.claude/hooks/enforce-completion-helpers.ps1`, `HookPayload.psm1` (497 lines), or `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`.
3. The bundle-parity Python test compares each `.claude` file independently. A sibling that changes a different `.claude` file together with its own bundled copy cannot break #708's parity, and #708 cannot break the sibling's.
4. Re-run the verification set after rebasing onto `origin/main` immediately before PR creation, so any sibling that merged first is included in the verified tree.
5. If D5 selects the Codex-inclusive scope, sequence #708 after #707 and rebase onto it. The Codex hook's line numbers and the `Resolve-EditedCheckpointContent` neighborhood may move.

---

## 6. Toolchain and Constraints

### 6.1 PowerShell toolchain (`.claude/rules/powershell.md`)

1. Format: `mcp__drm-copilot__run_poshqc_format`
2. Analyze: `mcp__drm-copilot__run_poshqc_analyze` (autofix: `mcp__drm-copilot__run_poshqc_analyze_autofix`)
3. Type check: not applicable
4. Test: `mcp__drm-copilot__run_poshqc_test`, config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

Recorded caveats from prior runs (user memory, not re-verified in this session): PoshQC MCP results carry no per-test output or counts, and the MCP test runner reads the installed extension's settings. A plan must not assert counts or percentages that it can only read from the MCP summary. It should run the targeted Pester files directly for fail-before and pass-after evidence.

### 6.2 Coverage configuration

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:52-57` already lists `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`, and both `.codex` equivalents in `CodeCoverage.Path`. No coverage configuration change is needed. The bundled mirror copies are not in the coverage list; they are mirrors verified by parity tests. `config/poshqc-scan.json:3-4` sets test scan folders `scripts`, `tests/powershell`, `tests/scripts`.

### 6.3 Per-session batch budget

`.claude/hooks/enforce-powershell-batch-budget.ps1:9-11, 30-35` caps each session at **3 production** and **3 test** PowerShell files (distinct paths). Files under `tests/**` or named `*.Tests.ps1` count as test files; all other `.ps1`/`.psm1`/`.psd1` files count as production, including the bundled copies under `extensions/`. State is stored in `.claude/state/powershell-batch-budget.<session_id>.json` (lines 13-15).

- Claude-only scope: 2 production (canonical and bundled hook) plus 1 test. Within the cap.
- Codex-inclusive scope: 4 production plus 2 test (the new file and `codex-pretooluse-transport.Tests.ps1`). Exceeds the production cap and requires two batches or an approved override.

### 6.4 Bundle-parity Python check

Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` after mirroring the Claude hook. Known local false failure (issue #510): the test walks the filesystem and fails when gitignored `.claude/state/*-batch-budget.*.json` files exist. The batch-budget hook itself writes those files during implementation. The plan should either remove them before this check or rely on CI for this one test, and should record which approach it used.

---

## 7. File-Size Pressure (500-line limit)

| File | Current lines | Expected change |
|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 415 | about +5 (parameter, call site, help text) |
| `extensions/.../claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` | mirror of the above | identical copy |
| `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` | 491 | **do not edit** (no headroom) |
| `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1` | new | about 100-150 |
| `.codex/hooks/enforce-completion-consistency.ps1` (only if D5 is Codex-inclusive) | 438 | about +5 |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` (only if D5 is Codex-inclusive) | 489 | rewrite rows at 363-403 in place; net growth must stay at or below 11 lines |
| `.claude/lib/hook-payload/HookPayload.psm1` | 497 | not touched |
| `.claude/hooks/enforce-completion-helpers.ps1` | 163 | not touched |

Line counts were taken with a whole-file line-match count in this tree.

---

## 8. Behavior Semantics (target)

- **Success condition:** for an Edit on a path matching `(^|/)artifacts/orchestration/orchestrator-state\.json$`, the on-disk text is read from the exact `tool_input.file_path` string. The allow/deny decision is then the same one the hook makes when run from inside the worktree that contains that file.
- **Ordering:** unchanged. Envelope, then file_path, then path match, then content (Write) or patch (Edit), then JSON, then assertion, then evidence.
- **Edge cases:** relative `file_path` resolves as before; an absolute path inside cwd reads the same file as before; a missing targeted file, empty text, or absent `old_string` gives allow (Claude, unchanged); Write-path behavior is untouched; a non-checkpoint path is still allowed before any read.

---

## 9. Testing Implications (strategy only; no test code)

New file `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1`. It dot-sources the hook, uses Arrange-Act-Assert, and injects only `-CheckpointReader` (plus `-FolderExistsCheck` for allow cases).

1. **cwd mismatch, deny (fail-before):** absolute POSIX-style `file_path` outside any real directory; path-keyed reader returns a non-completion checkpoint only for that path; the patch asserts completion without evidence. Expect deny. Pre-fix this returns allow.
2. **cwd mismatch, wrong-file content ignored:** the reader returns completion-free text for the targeted path and evidence-complete text for the relative literal (or the reverse), proving the decision is derived from the targeted file.
3. **Reader receives the exact path:** a path-capturing reader for (a) an absolute POSIX spelling, (b) a relative spelling `artifacts/orchestration/orchestrator-state.json`, and (c) a backslash spelling as a pure string. Assert the captured path equals the supplied `file_path` unchanged. Cases (a) and (c) fail pre-fix; case (b) passes before and after (AC-3 preservation).
4. **Preservation, allow on missing target:** the reader returns `$null` for the targeted path. Expect allow, matching the existing behavior at lines 367-371.
5. **Preservation, envelope anomaly still denies:** already covered by `enforce-completion-consistency.Payload.Tests.ps1:21-51`; no new test needed.

Evidence: capture the fail-before run of cases 1 and 3a against the unmodified hook, then the pass-after run, under the feature folder's canonical `evidence/<kind>/` paths. Also run the bundle-parity Python test and the existing hook suites (`enforce-completion-consistency*.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`) as regressions.

---

## Automation Feasibility

The fix is fully automatable and needs no human interaction. Every step (code edit, mirror copy, Pester fail-before/pass-after runs, PoshQC format/analyze/test, bundle-parity pytest, commit, PR) can run through existing agent tooling. The regression tests need no live Claude session, no gitignored state, no network, no `origin/main` access, and no Windows-only paths. One item depends on the runtime rather than the repository: an end-to-end confirmation with an isolated subagent. Such subagents load `main`'s hook scripts (user memory, probed 2026-09-18), so live confirmation is only possible after merge. It is not required by any AC.

---

## Recommendations

**D1. Source of the Edit-path checkpoint read.**
Options: (A) read the payload `tool_input.file_path` directly; (B) resolve a relative `file_path` against the payload `cwd`; (C) portable-identity worktree resolution.
**Recommended: A.** The Edit tool always supplies an absolute path. A relative path keeps today's resolution. No artifact persists any path.

**D2. How the path reaches the reader.**
Options: (a) add a mandatory `-CheckpointPath` parameter to `Resolve-EditedCheckpointContent`, supplied from `$filePath` at line 366; (b) have the function read `$ToolInput.file_path` internally.
**Recommended: (a).** The contract is explicit, the input is already validated by the caller, and there is no silent fallback to the relative literal. Pass the raw `file_path` string, not the backslash-normalized form.

**D3. Regression-test location.**
Options: (a) the main `enforce-completion-consistency.Tests.ps1` (491 lines); (b) `enforce-completion-consistency.Payload.Tests.ps1` (different aspect); (c) a new sibling `enforce-completion-consistency.EditTarget.Tests.ps1`.
**Recommended: (c).** The main file has no headroom, and the sibling naming follows existing precedent.

**D4. Fail semantics when the targeted file cannot be read.**
Options: (a) preserve the current Claude behavior (missing or empty file gives allow; envelope anomaly gives deny); (b) change missing or unreadable to deny, matching the Codex copy.
**Recommended: (a).** AC-3 requires behavior "as before". Changing the semantics is a separate policy decision, would invert the existing test at `enforce-completion-consistency.Tests.ps1:374-386`, and exceeds a minimal bug fix. The spec should note that the Claude copy allows on a missing file, so "fails closed" in AC-3 refers to the unchanged envelope-anomaly deny.

**D5. Codex mirror scope.**
Options: (a) Claude-only, and record the identical Codex Edit-branch defect (`.codex/hooks/enforce-completion-consistency.ps1:308`) as a follow-up or hand it to #707; (b) include Codex in #708 (four production files over two batches, rewrite of `codex-pretooluse-transport.Tests.ps1:363-403`, sequenced after #707).
**Recommended: (a).** The ACs name the Claude hook, no Claude-Codex parity test exists, the write set stays disjoint from #707, and the batch budget is respected.

**D6. Bundled mirror.**
Copy the modified `.claude/hooks/enforce-completion-consistency.ps1` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`, and verify with `test_push_down_claude_resource_contracts.py` (handling the #510 local false failure as described in section 6.4).
**Recommended:** required; not optional.

**D7. Documentation cleanup in the same file.**
Correct the stale `.DESCRIPTION` text at lines 32-36 and the function help at lines 267-274 so they describe reading the Edit's targeted `file_path`.
**Recommended:** include; this edits only the file already in scope.

**D8. Out-of-scope observations to record, not fix.**
(i) `String.Replace` replaces all occurrences (line 313), while the Edit tool replaces a single unique occurrence. (ii) The test at `enforce-completion-consistency.Tests.ps1:47-51` uses the default reader and an implicit cwd.
**Recommended:** list both as follow-up candidates in the feature's evidence and do not expand #708's scope.
