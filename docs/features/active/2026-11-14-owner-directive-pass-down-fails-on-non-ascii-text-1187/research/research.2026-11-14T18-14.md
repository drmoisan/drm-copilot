# Research: owner-directive pass-down fails on non-ASCII directive text (#1187)

- Issue: #1187
- Branch: `bug/owner-directive-pass-down-non-ascii`
- Timestamp: 2026-11-14T18-14 (UTC, supplied by the orchestrator; the researcher has no clock tool)
- Method: code reading only (Read and Grep over the item worktree). No command was run. Facts that need a run are marked "unconfirmed" with the verification step named.

## Summary

Every file read, every JSON parse, and the SHA-256 computation in the owner-directive paths already handle UTF-8 correctly on PowerShell 7. The defect is at the two process boundaries of the single Claude PreToolUse registration, `.claude/hooks/invoke-pretooluse-dispatch.ps1`:

1. Input: the dispatcher reads the hook payload once with `[Console]::In.ReadToEnd()` (the default `ReadStandardInput` seam of `Read-ClaudeHookRawPayload` in `.claude/lib/hook-payload/HookPayload.psm1`). `[Console]::In` decodes stdin with `[Console]::InputEncoding`, which on Windows follows the console input code page (OEM, for example 437, or the ANSI code page) unless the code page is 65001. UTF-8 bytes `E2 80 94` (U+2014) then decode to three unrelated characters, so the delegation prompt string that reaches `Test-OwnerDirectivePromptCoverage` no longer contains the quoted line built from the correctly decoded checkpoint or ledger text, and the hook denies with `OWNER_DIRECTIVE_RELAY_REQUIRED`.
2. Output: the dispatcher writes the combined decision with `ConvertTo-Json -Compress -Depth 5` to stdout. `ConvertTo-Json` does not escape non-ASCII characters by default, and stdout is encoded with `[Console]::OutputEncoding` (same code-page dependence). The deny reason carries the rendered block that the coordinator is told to paste; a code page without U+2014, U+201C, or U+201D replaces them, so a block copied from the deny reason cannot match even after the input is fixed.

The recommended fix decodes the dispatcher's stdin bytes explicitly as UTF-8 and emits the decision JSON with `-EscapeHandling EscapeNonAscii`, in the Claude dispatcher and its Codex twin, with byte-level Pester tests that need no temporary files and no console-encoding dependence.

## 1. Read, hash, and compare paths (current state)

### 1.1 Hook invocation and payload transport

| Step | File and function | Bytes to string |
|---|---|---|
| Registration | `.claude/settings.json` registers one PreToolUse command, `pwsh -NoProfile -File .claude/hooks/invoke-pretooluse-dispatch.ps1`. No encoding argument or `chcp` is present. | n/a |
| Dispatcher stdin read | `invoke-pretooluse-dispatch.ps1`, `Invoke-PreToolUseDispatchEntryPoint`, seam `ReadPayload = { Read-ClaudeHookRawPayload }` | `Read-ClaudeHookRawPayload` (`HookPayload.psm1`) probes `[Console]::IsInputRedirected`, then calls its `ReadStandardInput` seam, default `{ [Console]::In.ReadToEnd() }`: decoded with `[Console]::InputEncoding`. Fallbacks: `$env:CLAUDE_HOOK_INPUT`, `$env:CLAUDE_TOOL_INPUT` (already strings). |
| Registry | `pretooluse-dispatch.json` sets `"isolation": "in-process"`; the pass-down hook is registered as `pwsh -NoProfile -File .claude/hooks/enforce-owner-directive-pass-down.ps1`. | `Get-Content -Raw` (PS7 default UTF-8) on ASCII JSON. |
| In-process replay | `.claude/lib/hook-dispatch/HookDispatchRunner.psm1`, `Invoke-HookDispatchRunner`, seam `ReplayInput = { [Console]::SetIn([System.IO.StringReader]::new($Text)) }` | The already-decoded string is replayed; no second decode. Whatever the dispatcher decoded is what every hook sees. |
| Hook stdin read | `enforce-owner-directive-pass-down.ps1` entry: `Get-OwnerDirectivePassDownDecision -HookInputRaw ([string] (Read-ClaudeHookRawPayload))` | Reads the replayed `StringReader` through `[Console]::In`; string to string. |
| Per-process mode (not shipped) | `Invoke-HookDispatchChildProcess` starts `pwsh -NoProfile -File <hook>` and writes `$process.StandardInput.Write($PayloadText)` with no `StandardInputEncoding`; the child decodes with its own `[Console]::InputEncoding`. | Encoded and decoded with console code pages; lossy for characters outside them. Used only when the registry has no `isolation` field. |
| Payload parse | `Get-OwnerDirectivePassDownDecision`: `$HookInputRaw \| ConvertFrom-Json` | String to objects; `\uXXXX` escapes (if any) decode correctly. |
| Hook output (in-process) | The hook's `ConvertTo-Json \| Write-Output` goes to the runner's per-hook `StringWriter` and the success stream. | String only; no encoding. |
| Dispatcher output | `Invoke-PreToolUseDispatchEntryPoint`: `$decision \| ConvertTo-Json -Compress -Depth 5`, emitted by the script tail through `Write-Output` | Encoded with `[Console]::OutputEncoding`; non-ASCII characters are not escaped by `ConvertTo-Json` (default `EscapeHandling`). |

### 1.2 Pass-down hook (`enforce-owner-directive-pass-down.ps1`) and its dependencies

Imports and dot-sources (all guarded): `HookPayload.psm1`, `HookTargetWorktree.psm1`, `WorktreeItemResolution.psm1`, `WorktreeRunResolution.psm1`, `OrchestratorStateOwnerDirectives.psm1`, `OrchestratorStateOwnerDirectiveSelection.psm1`, `OrchestratorStateOwnerDirectiveDecision.psm1`, `subagentstop-target-worktree.ps1`, `owner-directive-pass-down-target.ps1`.

| Read or compare | Function | Mechanism | Verdict |
|---|---|---|---|
| Item checkpoint, item ledger, parent checkpoint, parent ledger | `Read-OwnerDirectiveFileText` (`owner-directive-pass-down-target.ps1`), the default `ReadText` seam | `[System.IO.File]::ReadAllText($Path)`: UTF-8 default with BOM detection (a UTF-8 BOM is stripped). | Correct for UTF-8 files. A file saved in a legacy code page would decode bytes `0x97` etc. to U+FFFD; that makes the entry fail B5 and be skipped, not cause this deny. |
| Checkpoint `owner_directives` block | `Get-OwnerDirectiveCheckpointBlockText` (`OrchestratorStateOwnerDirectiveSelection.psm1`) | `System.Text.Json.JsonDocument.Parse` on the string; `GetRawText()` of the array. | Correct. |
| Entry validity (B2-B8) and B5 hash | `Get-OrchestratorStateOwnerDirectiveValidEntry`, `Get-OwnerDirectiveEntryError`, `Get-OwnerDirectiveTextDigest` (`OrchestratorStateOwnerDirectives.psm1`) | `[System.Text.UTF8Encoding]::new($false).GetBytes($Text)` then `SHA256.HashData`, lowercase hex, ordinal compare. | Correct. A surrogate pair (U+1F600) encodes to the 4-byte sequence `F0 9F 98 80`. A lone surrogate is replaced by `EF BF BD` (no throw), so such text never matches a hash computed elsewhere over strict UTF-8; this is acceptable (fail closed). |
| Entry text | `ConvertTo-OwnerDirectiveValidEntry` | `JsonElement.GetString()` (escapes decoded); `Json` is `GetRawText()` with line breaks collapsed. | Correct. |
| Rendered block | `Format-OwnerDirectiveBlock`, `Get-OwnerDirectiveHeaderLine`, `Get-OwnerDirectiveQuotedLine` | String formatting; text wrapped in ASCII `"`; CRLF to LF. | Correct. |
| Prompt coverage (relay) | `Test-OwnerDirectivePromptCoverage` | `prompt.Contains(headerLine, Ordinal)` and `prompt.Contains(quotedLine, Ordinal)` after CRLF normalization. No Unicode normalization. | Correct as a comparison; it fails only because the prompt string was mis-decoded upstream. |
| Checkpoint gap | `Get-OwnerDirectiveCheckpointGap` | Ordinal compare of `Id` and `TextSha256` of file-decoded entries. | Correct (both sides come from files). |
| Coordinator relay | `Resolve-OwnerDirectivePassDownCoordinator` | Same coverage test on the prompt. | Same exposure as relay. |
| Ledger write guard | `Get-OwnerDirectivePassDownLedgerDecision` then `Test-OwnerDirectiveLedgerAppend` (`OrchestratorStateOwnerDirectiveDecision.psm1`) | Existing text from `ReadAllText`; new text is `tool_input.content` from the payload; `Get-OwnerDirectiveLedgerLine` splits on LF after CRLF normalization; ordinal prefix compare; appended lines checked by B2-B8 (including B5). | Exposed: with a mis-decoded payload, an existing non-ASCII line reads as "changed" (`the write changes existing ledger line #N`) and an appended non-ASCII line fails B5 (`text_sha256 does not match text`). Both are denied as `OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`. |
| Decision-file write | `Get-OwnerDirectivePassDownDecisionWrite` then `ConvertFrom-OwnerDirectiveDecisionLine`, `Test-OwnerDirectiveDecision` | Line from `tool_input.content`. Decision files are only tested for existence (`Test-OwnerDirectiveFileExist`), never read. | Low exposure: no hash; a non-ASCII reason is lengthened, not shortened, by mis-decoding. Fixed by the same input fix. |
| Transcript head | `Read-TranscriptHead` (`subagentstop-target-worktree.ps1`) | `Get-Content -LiteralPath -TotalCount 50` without `-Encoding`: PS7 default UTF-8. | Correct. Used only for the `branch:` label and canonical issue line. |
| Worktree listing | `git worktree list --porcelain` through the `WorktreeListInvoker` seam | Native output decoded with `[Console]::OutputEncoding`. | Not on the directive path (paths and branch names). |

### 1.3 Stop hook (`validate-orchestrator-output.ps1` and `validate-orchestrator-output-owner-pass-down.ps1`)

| Read | Function | Mechanism | Verdict |
|---|---|---|---|
| Checkpoint, ledgers, parent and child checkpoints | `Get-CheckpointFileContent` (`validate-orchestrator-output.ps1`), called by `Get-OrchestratorOutputOwnerPassDownSourceText` | `Get-Content -LiteralPath -Raw` without `-Encoding`: PS7 default UTF-8 with BOM detection. | Correct. |
| B1-B8, R1-R10 | `Get-OrchestratorStateOwnerDirectiveError` | `JsonDocument.Parse` plus `Get-OwnerDirectiveTextDigest`. | Correct. |
| Relay coverage of an item or running child | `Get-OrchestratorOutputOwnerPassDownItemDecision`, `Get-OrchestratorOutputOwnerPassDownParentDecision`, `Get-OwnerDirectiveRunningChildGap` | Compare `Id` and `TextSha256` across file-decoded sources. No prompt text is involved. | Correct; not affected by this defect. |
| SubagentStop envelope | `Read-SubagentStopEnvelope` (`subagentstop-envelope.ps1`) | `[Console]::In.ReadToEnd()`, BOM stripped. | Same code-page exposure, but `last_assistant_message` is not used for any owner-directive hash or comparison. Out of scope; noted under Rejected alternatives. |

Conclusion for item 1: no `Get-Content` without `-Encoding` and no `ReadAllText` call on the directive path is defective on PowerShell 7, and the single hash helper `Get-OwnerDirectiveTextDigest` already uses `UTF8Encoding($false)`; the test helper `Get-PassDownTestEntry` in `enforce-owner-directive-pass-down.Tests.ps1` computes hashes the same way. A second hashing helper is not needed.

## 2. Mismatch mechanisms

| Mechanism | Status |
|---|---|
| Dispatcher stdin decoded with `[Console]::InputEncoding`, which is a console code page on Windows unless the code page is 65001 | Confirmed by code reading (the only decode of the payload is `[Console]::In.ReadToEnd()`; nothing sets an encoding). The value of the code page in a Claude Code hook process is unconfirmed: it depends on the console that Claude Code gives the child. Any value other than 65001 reproduces the defect. |
| Claude Code writes non-ASCII characters as raw UTF-8 in the payload rather than `\uXXXX` escapes | Plausible (a Node `JSON.stringify` payload does not escape non-ASCII), unconfirmed. If the payload used escapes, the defect could not occur on input; the reported deny indicates raw bytes. |
| Dispatcher stdout encoded with `[Console]::OutputEncoding`; `ConvertTo-Json` leaves non-ASCII unescaped | Confirmed by code reading. Effect on the coordinator's paste (a deny block with `?` or other substitutes) is plausible and consistent with the report. |
| Per-process isolation double code-page round trip | Confirmed by code reading, inactive (registry ships `in-process`). |
| BOM handling | Not a cause: `ReadAllText` and `Get-Content` strip a UTF-8 BOM; `ConvertFrom-ClaudeHookEnvelope` and `Read-SubagentStopEnvelope` strip U+FEFF; the dispatcher payload has no BOM in practice. |
| CRLF | Not a cause: prompt and quoted lines are LF-normalized; ledger lines are CRLF-normalized. |
| Unicode normalization (NFC/NFD) | Not applied anywhere; comparison is ordinal over code units, which matches the verbatim contract. A relayed text in a different normalization form is a different text and stays denied. Recommendation: keep ordinal, no normalization. |
| Non-BMP characters (U+1F600) | Hash and comparison are correct once decoded. On mis-decode, the 4 UTF-8 bytes become 4 code-page characters. On output, a code page cannot represent the pair; `EscapeNonAscii` emits `😀`, which a JSON parser reassembles. |
| Curly quotes U+201C/U+201D | Same as the em dash: 3 UTF-8 bytes each (`E2 80 9C`, `E2 80 9D`), absent from OEM 437. The block wraps text in ASCII `"`, so curly quotes inside the text do not collide with the delimiters. |

Linux and macOS: .NET reports UTF-8 for `[Console]::InputEncoding` and `[Console]::OutputEncoding` there, so the defect is not expected to reproduce on the Linux hook-suite CI job.

## 3. Dispatcher as the fix point

The in-process runner replays the dispatcher's decoded string to each hook, so one UTF-8 decode in the dispatcher fixes the input for every in-process PreToolUse hook, including the pass-down hook. The fix must not change the default `ReadStandardInput` seam of `Read-ClaudeHookRawPayload` to read `[Console]::OpenStandardInput()`: in-process hooks call `Read-ClaudeHookRawPayload` after `[Console]::SetIn` replaced `[Console]::In`, and `OpenStandardInput()` would bypass the replay and read the already-consumed process handle, leaving every hook with an empty payload. The decode therefore belongs in the dispatcher's own `ReadPayload` seam, passing a UTF-8 reader into `Read-ClaudeHookRawPayload -ReadStandardInput`.

Output: the dispatcher is the only writer to the real stdout in in-process mode, so `-EscapeHandling EscapeNonAscii` on its decision write makes the emitted bytes ASCII and independent of `[Console]::OutputEncoding`.

## 4. Codex twins, bundle mirrors, and pinning tests

- The pass-down hook, its target helper, the stop-hook relay check, and the owner-directive modules have no Codex twin (execution-environment brief and owner-directives skill, Known Limitations). They need no change.
- `.codex/hooks/invoke-pretooluse-dispatch.ps1` has the same defect class: its `ReadPayload` default is `{ [Console]::In.ReadToEnd() }` (no fallback) and it writes `ConvertTo-Json -Compress -Depth 5`. Its runner `.codex/hooks/hook-dispatch.ps1` replays through `[Console]::SetIn` the same way. Recommended in scope (decision R-D2 below).

Files that change, with mirrors:

| Canonical | Bundle mirror |
|---|---|
| `.claude/hooks/invoke-pretooluse-dispatch.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/invoke-pretooluse-dispatch.ps1` |
| `.codex/hooks/invoke-pretooluse-dispatch.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/invoke-pretooluse-dispatch.ps1` |

Unchanged by the recommendation: `.claude/lib/hook-payload/HookPayload.psm1` (496 lines), `HookDispatchRunner.psm1`, the pass-down hook and target helper, the three owner-directive modules, and the stop-hook files.

Pinning tests to run after the edit:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` (bundle text equality).
- `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (no new `$PSScriptRoot` dependency is added by the recommendation; it stays green).
- `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`: requires the dispatcher text to contain `Read-ClaudeHookRawPayload`; the recommended seam keeps that call.
- `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1`: the tripwire `defaults the two stdin seams to the console redirect probe and the console reader` asserts the `ReadStandardInput` default text contains `ReadToEnd`; the recommendation leaves `HookPayload.psm1` unchanged, so it stays green.
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` with `HookGuardShape.Helpers.ps1`: rule S1 requires the three statements directly after the dot-source early return to be the bootstrap flag check, the `$dependencyDecision` assignment, and an emit containing `ConvertTo-Json` and `exit 0`. No statement (for example an encoding assignment) may be inserted there; adding `-EscapeHandling` to the tail emit keeps S1 satisfied.
- `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` (spawns both dispatchers with ASCII payloads through `Invoke-ParityProcess`), `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1`, `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1`, `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, `tests/scripts/claude-runtime/claude-settings.Tests.ps1`, `tests/scripts/dev-tools/HookProcessCost.Tests.ps1` (registration command text, unchanged).
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (no Python is introduced).

## 5. Existing tests and seams

| Test file (logical lines) | Seam |
|---|---|
| `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1` (148) | Dot-sources the dispatcher; `Invoke-PreToolUseDispatchEntryPoint -ReadPayload { ... } -ReadRegistry { ... } -WriteTrace { ... }`. |
| `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1` (137) | `Invoke-CodexPreToolUseDispatchEntryPoint -ReadPayload -ReadRegistry -WriteTrace`. |
| `tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1` (394) | Dot-sources the hook; `Get-OwnerDirectivePassDownDecision -HookInputRaw <string>` with in-memory `ReadText`, `WorktreeListInvoker`, `Clock`, `EpicResolver`, `ParallelResolver`, `TestFile`; helpers `Get-PassDownTestEntry` (UTF-8 hash), `Get-PassDownTestCheckpoint`, `Get-PassDownTestBlock`, `Invoke-PassDownTest`. |
| `tests/scripts/claude-hooks/owner-directive-pass-down-target.Tests.ps1` | Target helper seams. |
| `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1` (312) | Mocks `Get-CheckpointFileContent`, the clock, and resolvers. |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1` (387) | Pure; already has a non-ASCII hash row (U+00FC, U+00E4). |
| `OrchestratorStateOwnerDirectiveSelection.Tests.ps1` (300), `OrchestratorStateOwnerDirectiveDecision.Tests.ps1` (179) | Pure functions. |
| `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1` (487) | `ReadStandardInput`, `TestStandardInputRedirected`, env fallbacks. |
| `tests/scripts/claude-lib/hook-dispatch/HookDispatchRunner.Tests.ps1` | `InvokeScript`, `ReplayInput`, `StartProcess`. |

Byte-level tests without temporary files: the new reader takes an `OpenStream` script-block seam; tests pass `[System.IO.MemoryStream]::new([System.Text.UTF8Encoding]::new($false).GetBytes($payload))`. The mechanism contrast uses `[System.Text.Encoding]::Latin1` (built into .NET 5 and later, no code-page provider needed) to decode the same bytes, which reproduces the mis-decode deterministically on every OS. Characters to cover: U+2014, U+201C with U+201D, U+1F600 (built as `[char]::ConvertFromUtf32(0x1F600)`), written in test source as `[char]0x2014` etc. so the test files stay ASCII.

## 6. Recommended design

### Selected approach: UTF-8 at the dispatcher boundary (input bytes and ASCII-escaped output)

Claude dispatcher (`invoke-pretooluse-dispatch.ps1`):

- Add `Read-PreToolUseDispatchStandardInput` with parameter `[scriptblock] $OpenStream = { [Console]::OpenStandardInput() }`. It wraps the stream in `[System.IO.StreamReader]::new($stream, [System.Text.UTF8Encoding]::new($false, $false), $true)` (non-throwing decoder, BOM detection on, so a UTF-8 BOM is stripped and invalid bytes become U+FFFD) and returns `ReadToEnd()`, disposing the reader in `finally`.
- Change the `ReadPayload` default of `Invoke-PreToolUseDispatchEntryPoint` to `{ Read-ClaudeHookRawPayload -ReadStandardInput { Read-PreToolUseDispatchStandardInput } }`. The redirect probe and the environment fallbacks of `Read-ClaudeHookRawPayload` are unchanged, so a non-redirected manual run still cannot block.
- Change the decision write in `Invoke-PreToolUseDispatchEntryPoint` to `ConvertTo-Json -Compress -Depth 5 -EscapeHandling EscapeNonAscii`, and the dependency-tail emit likewise (keeps S1). The `-PerHookTrace` stderr line may take the same switch.
- Update the comment-based help (`.DESCRIPTION`, `ReadPayload`) to state the UTF-8 decode and the ASCII-escaped output.

Codex dispatcher (`.codex/hooks/invoke-pretooluse-dispatch.ps1`): the same reader under a Codex name (for example `Read-CodexPreToolUseDispatchStandardInput`) as the `ReadPayload` default (it has no redirect probe or fallback today; keep that behavior), and `-EscapeHandling EscapeNonAscii` on its writes. Codex hooks may not dot-source `.claude` files, so the function text is duplicated; a parity row can pin the two function bodies equal apart from the name.

Hashing: keep the single helper `Get-OwnerDirectiveTextDigest`; no change. File reads: keep `ReadAllText` and `Get-Content` (PS7 UTF-8 defaults); adding `-Encoding utf8` or `UTF8Encoding($false)` is optional hardening, not part of the fix, and would add four more production files to the change.

Behavior after the fix: a relayed block byte-identical to the recorded text is accepted for any Unicode text; altered text (one changed character, a hyphen in place of an em dash, a different normalization form) is still denied; a decision reason is shown to the coordinator with `—` escapes that Claude Code's JSON parser turns back into U+2014.

### Rejected alternatives

- Change the default `ReadStandardInput` seam of `Read-ClaudeHookRawPayload` to read raw UTF-8 bytes: breaks in-process replay (hooks would read the consumed process handle) and trips the `HookPayload.Tests.ps1` tripwire; `HookPayload.psm1` is also at 496 lines.
- Set `[Console]::InputEncoding` and `[Console]::OutputEncoding` to UTF-8 at dispatcher start: changes the code page of a console the process may share with its parent (a process-wide side effect), behavior with no attached console is not documented for this host, and an extra top-level statement risks the S1 shape rule.
- Fix inside the pass-down hook only (re-decode the prompt): the hook receives a string already mis-decoded; recovering bytes from an unknown code page is not reliable, and the output side stays broken.
- Fix the per-process runner (`Invoke-HookDispatchChildProcess`): setting `StandardInputEncoding` does not change how the child decodes; the shipped registry is in-process. Recorded as a known limitation of the `per-process` mode.
- `Read-SubagentStopEnvelope` stdin decode: same defect class for SubagentStop hooks, but no owner-directive comparison uses that text. Not in scope; candidate for a separate issue only if a SubagentStop check is found to compare non-ASCII text.

### Decisions taken under OD-1 (autonomous mode)

- R-D1: fix at the dispatcher boundary, not in `HookPayload.psm1` or the owner-directive modules.
- R-D2: include the Codex dispatcher and its bundle copy, because the spec's expected behavior is "on every platform" and the twin carries the identical stdin and output code. The planner may drop R-D2 only with a recorded reason.
- R-D3: no Unicode normalization; ordinal comparison stays the contract.

### File-size headroom (logical lines, from a line count of the current files)

| File | Lines | Tier status | Expected after change |
|---|---|---|---|
| `.claude/hooks/invoke-pretooluse-dispatch.ps1` | 120 | below 500 | about 150 |
| `.codex/hooks/invoke-pretooluse-dispatch.ps1` | 110 | below 500 | about 140 |
| `.claude/lib/hook-payload/HookPayload.psm1` (not changed) | 496 | at the 500 guidance line | unchanged |
| `.claude/hooks/enforce-owner-directive-pass-down.ps1` (not changed) | 450 | below 500 | unchanged |
| `.claude/hooks/owner-directive-pass-down-target.ps1` (not changed) | 481 | below 500 | unchanged |
| `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` (not changed) | 490 | below 500 | unchanged |
| `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1` (not changed) | 410 | below 500 | unchanged |
| `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1` | 148 | below 500 | about 230 |
| `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1` | 137 | below 500 | about 200 |
| `tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1` | 394 | below 500 | about 450; place further rows in a new file if it would pass 500 |

Counts are Grep line counts of the files as checked out; a trailing terminator adds no line.

## 7. Behavior semantics and test strategy

Success: a delegation prompt whose fenced block holds the header line and the quoted text line of every selected entry, delivered as UTF-8 bytes, is allowed for text containing U+2014, U+201C/U+201D, or U+1F600. A ledger append whose existing lines are unchanged and whose new line has a matching UTF-8 hash is allowed for the same texts.

Failure (unchanged): a prompt that changes any character of the text is denied with `OWNER_DIRECTIVE_RELAY_REQUIRED`; a ledger write that changes an existing line is denied with `OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`.

Proposed Pester rows (no temporary files, no console-encoding mutation):

1. `Read-PreToolUseDispatchStandardInput` decodes in-memory UTF-8 bytes of each of the three characters exactly; strips a UTF-8 BOM; maps an invalid byte to U+FFFD without throwing (Claude and Codex dispatcher test files).
2. `Invoke-PreToolUseDispatchEntryPoint` with a `ReadRegistry` stub and a `ReadPayload` seam built from the byte reader: the emitted decision JSON is pure ASCII (every char below 0x80) and `ConvertFrom-Json` restores U+2014, the curly quotes, and the surrogate pair in the reason.
3. Pass-down hook, string level (`enforce-owner-directive-pass-down.Tests.ps1`): for each character, a verbatim relay is allowed; the same prompt with the character replaced (for example `-` for U+2014) is denied; a ledger append of such an entry is allowed and an edit of an existing such line is denied.
4. Mechanism contrast (fail-before proof): the same UTF-8 payload bytes decoded with `[System.Text.Encoding]::Latin1` and passed as `HookInputRaw` produce `OWNER_DIRECTIVE_RELAY_REQUIRED`, while the UTF-8 reader's output is allowed. Rows 1 and 2 fail before the change because the reader does not exist and the output is unescaped.
5. Stop hook (`validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1`) and `OrchestratorStateOwnerDirectives.Tests.ps1`: rows with the three characters confirming B5 and the relay-coverage check accept matching hashes (guard rows; expected to pass before and after).

Optional characterization evidence before the change (orchestrator-owned, written to `evidence/baseline/`): a `sh`-launched PowerShell 7 script that starts the dispatcher with `ProcessStartInfo.StandardInputEncoding = UTF8Encoding($false)` and an em-dash relay payload against a fixture worktree, recording the deny; it is Windows-specific and is not a gate.

Gates: Pester through the test-execution launcher (`run-test-suite.sh pester`, parallel); task checks with `-TestPath` on the touched test files; Python contract tests through the launcher's pytest suite.

## Pre-Mortem

- Review checklists: a reviewer can flag the duplicated reader in the two dispatchers as copy-paste; mitigation: the plan states that Codex hooks may not dot-source `.claude` files and adds a parity row pinning the two function bodies, and each new function carries comment-based help, `CmdletBinding`, and `OutputType`.
- Coverage: the default `OpenStream` script block (`[Console]::OpenStandardInput()`) never runs in unit tests and stays uncovered; mitigation: keep the default to one expression so the uncovered cost is one line, cover every other line of the reader with in-memory streams, and confirm per-file line coverage of both dispatchers is at least 85% from `artifacts/pester/powershell-coverage.xml` of the gate run.
- Mirror parity: the two bundle copies must be byte-identical to their canonical files or `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` fail; mitigation: copy both files in the same task and run both contract tests. No fact in the execution-environment brief changes (it does not describe the payload encoding), so no brief task is required; if the plan adds an encoding sentence to the brief's PreToolUse dispatcher item, all six byte-identical copies must change together.
- File size: both dispatchers stay below 200 lines; `enforce-owner-directive-pass-down.Tests.ps1` (394) could pass 500 if all rows go there; mitigation: put byte-level rows in the dispatcher test files and, if needed, new pass-down rows in a new file such as `enforce-owner-directive-pass-down.NonAscii.Tests.ps1`.
- Test isolation: setting `[Console]::InputEncoding`, `[Console]::OutputEncoding`, or `[Console]::SetIn` in a test changes process-wide state shared within a shard and is caught by `Invoke-PoshQCLeakScan` only for some forms; mitigation: tests use only the `OpenStream` and `ReadPayload` seams and `MemoryStream` objects, create no files, and dispose every stream.
- CI-only behavior: on the Linux hook-suite job .NET reports UTF-8 console encodings, so an end-to-end process test would pass without the fix there, and Windows runner code pages are not pinned; mitigation: the fail-before and regression rows decode bytes explicitly (UTF-8 versus `Latin1`) and never depend on the console code page; test files hold only ASCII source with `[char]` constructors, so `.gitattributes` normalization and file encodings cannot change them.
- Evidence: a run that only shows string-level rows passing does not prove the byte-level fix; mitigation: record the fail-before run of the byte-reader and ASCII-output rows (or a `fail-before-exception.<timestamp>.md` dossier if the reader's absence makes the run structurally a discovery failure) under `evidence/regression-testing/`, timestamps from the clock, append-only, no absolute paths.

## Automation Feasibility

Fully automatable. Every change is a PowerShell edit to two dispatcher scripts and their bundle copies plus Pester rows driven through existing seams (`ReadPayload`, the new `OpenStream`, `HookInputRaw`, and the in-memory file and clock seams). No human step, console configuration, or live Claude Code session is required for the gates. The only non-automatable confirmation is the real code page of a Claude Code hook process on the owner's host, which the fix makes irrelevant; a live post-merge check applies to isolated workers only after the change reaches the default branch, because isolated subagents run the default branch's hook scripts.

## Batch-budget note

The recommendation touches four production PowerShell files (two canonical dispatchers and two bundle copies). In direct mode the fourth distinct file is denied with `POWERSHELL_LARGE_PATH_REQUIRED`; the executor needs the `large` or `remediation` route recorded in a non-terminal `orchestrator-state.json` of the item worktree, or the bundle copies must be produced by a script the batch-budget hook does not see.

## Items for the orchestrator to confirm

- Whether Claude Code's PreToolUse payload carries raw UTF-8 for non-ASCII prompt text (expected) rather than `\u` escapes.
- The console input and output code pages of a hook process on the owner's host (optional; informs the issue record only).
