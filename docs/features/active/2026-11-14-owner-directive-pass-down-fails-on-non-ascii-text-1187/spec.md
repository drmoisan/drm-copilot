# 2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text (Spec)

- **Issue:** #1187
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Final (decisions taken autonomously under OD-1)
- **Version:** 1.0
- **Work Mode:** full-bug (acceptance criteria source: this file only)
- **Research:** `research/research.2026-11-14T18-14.md`

## Context
On Windows the owner-directive pass-down PreToolUse hook (`.claude/hooks/enforce-owner-directive-pass-down.ps1`, issue #1157) cannot match a recorded directive whose `text` contains a non-ASCII character such as an em dash. It therefore denies every worker or orchestrator delegation for that item with `OWNER_DIRECTIVE_RELAY_REQUIRED`, even when the brief relays the directive verbatim. The #1158 run could proceed only by re-recording the directive with an ASCII hyphen and a recomputed hash, which changes the owner's words.

Environment:
- OS/version: Windows 11, Claude Code runtime, PowerShell 7
- Python version: not applicable
- Command/flags used: `Agent(<worker>)` delegation whose prompt carries a fenced `Owner directives:` block relaying a directive that contains U+2014
- Data source or fixture: reported by the #1158 run (PR #1184 body, ORCH-D5)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence
Steps to Reproduce:
1. Record an owner directive whose text contains an em dash (U+2014) in an item checkpoint, with `text_sha256` over the UTF-8 bytes.
2. Delegate a worker from that item with the directive relayed verbatim in the `Owner directives:` block.
3. Observe the delegation denied as if the directive were not relayed.

Expected:
A directive relayed byte-for-byte is recognised whatever characters it contains; the hook compares text and hashes over UTF-8 consistently on every platform.

Actual:
The delegation is denied on Windows. Recording only ASCII text works around it, but owner directives are recorded verbatim, so the workaround alters the record.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: see PR #1184, `## Decisions` (ORCH-D5) and `## Follow-ups`.

Deterministic reproduction (no console dependence): the UTF-8 bytes of a relay payload decoded with `[System.Text.Encoding]::Latin1` and passed to `Get-OwnerDirectivePassDownDecision -HookInputRaw` produce `OWNER_DIRECTIVE_RELAY_REQUIRED`; the same bytes decoded as UTF-8 do not. This contrast is the fail-before proof required by the acceptance criteria.

## Scope & Non-Goals
- In scope:
  - UTF-8 decoding of the PreToolUse payload at the stdin boundary of `.claude/hooks/invoke-pretooluse-dispatch.ps1` and its Codex twin `.codex/hooks/invoke-pretooluse-dispatch.ps1`.
  - ASCII-escaped (encoding-independent) JSON output of both dispatchers: the decision write, the dependency-guard tail emit, and the per-hook trace line.
  - Byte-identical bundle copies of both dispatchers under `extensions/drm-copilot/resources/`.
  - Regression tests that pin every owner-directive read, hash, and compare path for non-ASCII text, including paths that are already correct and are not changed.
- Out of scope / non-goals:
  - Changing `.claude/lib/hook-payload/HookPayload.psm1`, `.claude/lib/hook-dispatch/HookDispatchRunner.psm1`, the pass-down hook, its target helper, the `OrchestratorStateOwnerDirective*.psm1` modules, or the stop-hook files (see D-1, D-4).
  - Unicode normalization of directive text (see D-3).
  - The stdin decode of `Read-SubagentStopEnvelope` in `subagentstop-envelope.ps1` (see D-7).
  - The `per-process` isolation mode of the dispatch runner, which the shipped registry does not use (see D-6).
  - Python and TypeScript orchestrator-state validators, which ignore owner-directive keys (existing known limitation).
- Explicitly excluded systems, integrations, or datasets: Claude Code's own payload serialization; console code-page configuration of the host.

## Root Cause Analysis
Confirmed by code reading (research section 1 and 2):

1. Input. The single Claude PreToolUse registration runs `.claude/hooks/invoke-pretooluse-dispatch.ps1`. Its `Invoke-PreToolUseDispatchEntryPoint` reads the payload once through the `ReadPayload` seam, whose default `{ Read-ClaudeHookRawPayload }` uses the `ReadStandardInput` default `{ [Console]::In.ReadToEnd() }`. `[Console]::In` decodes with `[Console]::InputEncoding`, which on Windows is the console code page unless it is 65001. The UTF-8 bytes `E2 80 94` (U+2014) then decode to three unrelated characters. The in-process runner (`Invoke-HookDispatchRunner`) replays that already-decoded string to every hook, so the prompt that reaches `Test-OwnerDirectivePromptCoverage` no longer contains the quoted line built from the correctly decoded checkpoint or ledger text, and the hook denies with `OWNER_DIRECTIVE_RELAY_REQUIRED`. The same mis-decoded payload makes `Test-OwnerDirectiveLedgerAppend` report an existing non-ASCII ledger line as changed and an appended non-ASCII line as failing B5, both denied as `OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`.
2. Output. The dispatcher writes the combined decision with `ConvertTo-Json -Compress -Depth 5`, which leaves non-ASCII characters unescaped, to stdout encoded with `[Console]::OutputEncoding`. A code page without U+2014, U+201C, or U+201D substitutes them, so a block copied from the deny reason cannot match even after the input is fixed.

Not causes (verified by code reading): file reads (`[System.IO.File]::ReadAllText` in `Read-OwnerDirectiveFileText`, `Get-Content -Raw` in `Get-CheckpointFileContent`) use the PowerShell 7 UTF-8 default with BOM detection; the single hash helper `Get-OwnerDirectiveTextDigest` already hashes `[System.Text.UTF8Encoding]::new($false).GetBytes($Text)`; JSON parsing uses `System.Text.Json.JsonDocument`; prompt and ledger comparisons are ordinal after LF normalization; decision files are only existence-checked (`Test-OwnerDirectiveFileExist`), never read.

The `.codex/hooks/invoke-pretooluse-dispatch.ps1` dispatcher carries the same defect class: its `ReadPayload` default is `{ [Console]::In.ReadToEnd() }` and its writes use the same `ConvertTo-Json` call.

## Proposed Fix

### Design summary (what changes where):
Decode stdin bytes explicitly as UTF-8 in each dispatcher's own `ReadPayload` default, and emit every dispatcher JSON write with `-EscapeHandling EscapeNonAscii` so the emitted bytes are ASCII and independent of `[Console]::OutputEncoding`. Because the in-process runner replays the dispatcher's decoded string, one decode fixes every in-process PreToolUse hook, including the pass-down hook.

### Boundaries and invariants to preserve:
- `Read-ClaudeHookRawPayload` keeps its `ReadStandardInput` default (`[Console]::In.ReadToEnd()`), its redirect probe, and its environment fallbacks; in-process hooks depend on reading the replayed `[Console]::In`.
- Rule S1 of `HookGuardShape.Helpers.ps1`: the three statements directly after the dot-source early return stay the bootstrap flag check, the `$dependencyDecision` assignment, and an emit containing `ConvertTo-Json` and `exit 0`. No statement is inserted there.
- The dispatcher text keeps the `Read-ClaudeHookRawPayload` call required by `PreToolUsePayload.Contract.Tests.ps1`.
- Ordinal comparison of directive text and lowercase-hex ordinal comparison of `text_sha256` stay the contract.
- No hook gains an allow path; deny codes and reasons are unchanged apart from encoding.
- No hook invokes Python.

### Dependencies or blocked work:
- The change touches four production PowerShell files (two canonical dispatchers, two bundle copies), so execution needs the `large` or `remediation` route recorded in a non-terminal `orchestrator-state.json` of the item worktree to pass the PowerShell batch-budget hook.
- Isolated subagents run the default branch's hook scripts, so the fix takes effect for isolated workers only after merge.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
| Canonical | Bundle copy |
|---|---|
| `.claude/hooks/invoke-pretooluse-dispatch.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/invoke-pretooluse-dispatch.ps1` |
| `.codex/hooks/invoke-pretooluse-dispatch.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/invoke-pretooluse-dispatch.ps1` |

Test files to change or add:
- `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1`
- `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1` (new; see D-8)
- `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1` (or `OrchestratorStateOwnerDirectives.Entry.Tests.ps1` if the planner finds the B5 rows belong there)
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.Tests.ps1`
- `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` (reader parity row; see D-2)

#### Functions/classes/CLI commands impacted:
- New `Read-PreToolUseDispatchStandardInput` (Claude dispatcher) with parameter `[scriptblock] $OpenStream = { [Console]::OpenStandardInput() }`. It wraps the stream in `[System.IO.StreamReader]::new($stream, [System.Text.UTF8Encoding]::new($false, $false), $true)`, returns `ReadToEnd()`, and disposes the reader in `finally`. Carries comment-based help, `CmdletBinding`, and `OutputType([string])`.
- `Invoke-PreToolUseDispatchEntryPoint`: `ReadPayload` default becomes `{ Read-ClaudeHookRawPayload -ReadStandardInput { Read-PreToolUseDispatchStandardInput } }`; decision and trace writes gain `-EscapeHandling EscapeNonAscii`.
- New `Read-CodexPreToolUseDispatchStandardInput` (Codex dispatcher), same body as the Claude reader apart from its name.
- `Invoke-CodexPreToolUseDispatchEntryPoint`: `ReadPayload` default becomes `{ Read-CodexPreToolUseDispatchStandardInput }` (no redirect probe or fallback, as today); decision and trace writes gain `-EscapeHandling EscapeNonAscii`.
- Script-tail dependency emit in both dispatchers gains `-EscapeHandling EscapeNonAscii`.

#### Data flow and validation changes:
stdin bytes -> UTF-8 `StreamReader` (BOM stripped, invalid bytes to U+FFFD) -> payload string -> unchanged in-process replay -> hooks. Hook decisions -> dispatcher -> `ConvertTo-Json -EscapeHandling EscapeNonAscii` -> ASCII stdout. No validation rule changes.

#### Error handling and logging updates:
The decoder is non-throwing: invalid UTF-8 becomes U+FFFD, which fails B5 for any affected entry (fail closed) rather than throwing in the hook. Stream disposal in `finally`. No new log output.

#### Rollback/feature-flag considerations (if applicable):
No flag. Rollback is a revert of the two dispatchers and their bundle copies; no data or schema migration is involved.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: PreToolUse payload as UTF-8 bytes on stdin, optionally BOM-prefixed.
- Output: one compressed JSON object per decision, every character below U+0080; non-ASCII characters appear as `\uXXXX` escapes (non-BMP as a surrogate-pair escape), which a JSON parser restores.

#### Required configuration keys and defaults:
None. `.claude/settings.json`, `.codex/config.toml`, and both `pretooluse-dispatch.json` registries are unchanged.

#### Backward-compatibility expectations:
ASCII payloads produce byte-identical decisions. Non-ASCII decisions change only from raw characters to `\uXXXX` escapes, which are equivalent JSON.

#### Performance constraints (latency/throughput/memory):
No new process start; one `StreamReader` per dispatcher invocation. No measurable latency change is expected; no performance gate is added.

## Decisions (taken under OD-1, autonomous mode)

- **D-1 Fix point is the dispatcher boundary.** Adopts research R-D1. Rationale: the in-process runner replays the dispatcher's decoded string, so a single decode fixes every hook; changing the `Read-ClaudeHookRawPayload` default to `OpenStandardInput()` would bypass the replay and leave in-process hooks with an empty payload, and a fix inside the pass-down hook cannot reliably recover bytes from an unknown code page.
- **D-2 Codex dispatcher is in scope.** Adopts research R-D2. Rationale: the expected behavior is "on every platform" and the Codex twin carries identical stdin and output code. Codex hooks may not dot-source `.claude` files, so the reader is duplicated, and a parity row in `PreToolUseDispatch.Parity.Tests.ps1` pins the two function bodies equal apart from the function name.
- **D-3 No Unicode normalization.** Adopts research R-D3. Rationale: the contract is a verbatim relay; ordinal comparison over code units is that contract, and a text in a different normalization form is a different text.
- **D-4 Already-correct paths are pinned, not changed.** Rationale: `ReadAllText`, `Get-Content -Raw`, `JsonDocument.Parse`, and `Get-OwnerDirectiveTextDigest` are correct on PowerShell 7; adding explicit `-Encoding` arguments would add production files without changing behavior. Regression tests pin each path so a future regression is detected.
- **D-5 Output is ASCII-escaped, not console-encoded.** Rationale: `-EscapeHandling EscapeNonAscii` makes the emitted bytes independent of `[Console]::OutputEncoding`. Setting `[Console]::InputEncoding` or `[Console]::OutputEncoding` was rejected because it is a process-wide side effect on a possibly shared console and would insert a statement that risks rule S1.
- **D-6 Per-process isolation mode is not changed.** Rationale: the shipped registry sets `"isolation": "in-process"`, and setting `StandardInputEncoding` on the parent does not control how the child decodes. The limitation is stated in the Claude dispatcher's comment-based help.
- **D-7 SubagentStop envelope decode is out of scope.** Rationale: `Read-SubagentStopEnvelope` shares the defect class, but no owner-directive hash or comparison consumes its text (the stop-hook relay check compares `Id` and `TextSha256` from file-decoded sources). It is unrelated to this defect's observable behavior, so no remediation cycle applies; a separate issue is warranted only if a SubagentStop check is found to compare non-ASCII text.
- **D-8 Pass-down non-ASCII rows go in a new test file.** Rationale: `enforce-owner-directive-pass-down.Tests.ps1` holds 394 logical lines; the new rows would bring it near or past the 500-line guidance tier. A new file `enforce-owner-directive-pass-down.NonAscii.Tests.ps1` keeps both files below 500.
- **D-9 Test source stays ASCII.** Rationale: characters are built with `[char]0x2014`, `[char]0x201C`, `[char]0x201D`, and `[char]::ConvertFromUtf32(0x1F600)`, so `.gitattributes` normalization and editor encodings cannot alter the fixtures.
- **D-10 Execution-environment brief is not changed.** Rationale: the brief states no fact about payload encoding, console code pages, or dispatcher output encoding (verified by search of `.claude/skills/execution-environment/SKILL.md`); the facts it states about the dispatcher (registration groups, batch-budget visibility) are unchanged. If the plan nevertheless adds an encoding sentence, every copy of the brief must change together.
- **D-11 Comment-based help is the documentation surface.** Rationale: the behavior change is internal to the dispatchers; their `.DESCRIPTION` and `ReadPayload` help are updated. The owner-directives skill text is unchanged because its contract (UTF-8 hash, verbatim relay) is unchanged.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): Claude Code writes non-ASCII prompt text as raw UTF-8 in the payload (plausible, unconfirmed; the fix is correct whether or not the payload uses `\u` escapes). The hook process code page on the owner's host is unknown and is irrelevant after the fix.
- Constraints (budget, performance, compatibility): PowerShell 7 only; no new dependency; no Python; tests run parallel only through the test-execution launcher, one suite at a time; no temporary files; no mutation of `[Console]` encodings or `[Console]::SetIn` in tests.
- External dependencies (services, libraries, releases): .NET `System.Text.UTF8Encoding`, `System.Text.Encoding.Latin1` (built into .NET 5 and later).

## Data / API / Config Impact
- User-facing or API changes: deny reasons containing non-ASCII text are emitted as JSON escapes; Claude Code displays the restored characters.
- Data or migration considerations: none; existing checkpoints and ledgers with ASCII-substituted text remain valid as recorded.
- Logging/telemetry updates (if any): the per-hook trace line is ASCII-escaped.
- Compatibility notes (CLI flags, config schemas, versioning): none.

## Test Strategy
Seeded from issue (each item is covered by acceptance criteria below):

- [ ] Read stdin and files as UTF-8 explicitly and hash UTF-8 bytes in every owner-directive path
- [ ] Pester rows with em dash, curly quotes and a non-BMP character in directive text (relay accepted; altered text still denied)
- [ ] Verify the stop-hook pass-down check and the ledger validator on the same inputs

- Regression tests to add or update: byte-level reader rows and ASCII-output rows in both dispatcher test files; string-level relay, ledger, and decision-write rows in the new pass-down file; B5 and digest rows in `OrchestratorStateOwnerDirectives.Tests.ps1`; stop-hook coverage rows in `validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1`; decision-line rows in `OrchestratorStateOwnerDirectiveDecision.Tests.ps1`; reader parity row in `PreToolUseDispatch.Parity.Tests.ps1`.
- Unit tests: Pester only; seams are `OpenStream` with `[System.IO.MemoryStream]`, `ReadPayload`, `ReadRegistry`, `WriteTrace`, `HookInputRaw`, and the in-memory `ReadText`, `Clock`, `TestFile`, and resolver seams.
- Edge cases and negative scenarios: UTF-8 BOM; invalid UTF-8 byte; hyphen substituted for U+2014; straight quotes substituted for U+201C/U+201D; U+1F600 removed or replaced; Latin1 mis-decode of valid UTF-8 bytes; edit of an existing non-ASCII ledger line.
- Error handling verification: invalid bytes yield U+FFFD with no exception; affected entry fails B5.
- Coverage impact: per-file PowerShell line coverage at least 85% for each changed production file, read from `artifacts/pester/powershell-coverage.xml` of the gate run. The default `OpenStream` script block is one expression and is the only expected uncovered line.
- Toolchain: Invoke-Formatter, PSScriptAnalyzer, Pester (parallel, through the test-execution launcher), Python contract tests through the launcher's pytest suite.
- Manual validation steps: none required for gates. A live post-merge delegation with an em-dash directive is optional confirmation.

## Acceptance Criteria
- [ ] AC-1: `.claude/hooks/invoke-pretooluse-dispatch.ps1` defines `Read-PreToolUseDispatchStandardInput` with an `OpenStream` seam; Pester rows feeding `[System.IO.MemoryStream]` UTF-8 bytes prove it returns U+2014, U+201C with U+201D, and U+1F600 exactly, strips a leading UTF-8 BOM, and maps an invalid byte to U+FFFD without throwing.
- [ ] AC-2: The `ReadPayload` default of `Invoke-PreToolUseDispatchEntryPoint` is `Read-ClaudeHookRawPayload -ReadStandardInput { Read-PreToolUseDispatchStandardInput }`; the redirect probe and environment fallbacks of `Read-ClaudeHookRawPayload` are unchanged, and `.claude/lib/hook-payload/HookPayload.psm1` is not modified.
- [ ] AC-3: `.codex/hooks/invoke-pretooluse-dispatch.ps1` defines `Read-CodexPreToolUseDispatchStandardInput` with the same behavior, proven by the same byte-level rows in `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1`, and the `ReadPayload` default of `Invoke-CodexPreToolUseDispatchEntryPoint` uses it.
- [ ] AC-4: A parity row in `tests/scripts/claude-hooks/PreToolUseDispatch.Parity.Tests.ps1` asserts the Claude and Codex reader function bodies are equal apart from the function name.
- [ ] AC-5: In both dispatchers the decision write, the dependency-guard tail emit, and the per-hook trace write use `ConvertTo-Json -EscapeHandling EscapeNonAscii`; Pester rows prove that a deny reason containing U+2014, U+201C/U+201D, and U+1F600 is emitted with every character below U+0080 and that `ConvertFrom-Json` of the emitted text restores the original reason exactly.
- [ ] AC-6: Pass-down hook relay match (`Test-OwnerDirectivePromptCoverage` through `Get-OwnerDirectivePassDownDecision`): for each of U+2014, U+201C/U+201D, and U+1F600, a prompt relaying the rendered block verbatim is allowed, and the entry's `text_sha256` computed in the test over UTF-8 bytes matches the value the hook validates; the same prompt with the character replaced (hyphen, straight quotes, or the non-BMP character removed) is denied with `OWNER_DIRECTIVE_RELAY_REQUIRED`. Rows live in `tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1`.
- [ ] AC-7: Pass-down ledger-append check (`Get-OwnerDirectivePassDownLedgerDecision`, `Test-OwnerDirectiveLedgerAppend`): an append of a valid entry containing each listed character to a ledger whose existing lines contain such characters is allowed; an edit of an existing non-ASCII line is denied with `OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`; an appended non-ASCII line whose hash was computed over altered text is denied.
- [ ] AC-8: Decision-file path (`Get-OwnerDirectivePassDownDecisionWrite`, `ConvertFrom-OwnerDirectiveDecisionLine`, `Test-OwnerDirectiveDecision`): a decision line whose reason contains each listed character is accepted, with the reason preserved exactly; no production code is changed to read decision-file content, which remains existence-checked only.
- [ ] AC-9: Stop-hook coverage check (`.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1` over `Get-CheckpointFileContent`): with checkpoint and ledger entries containing each listed character, a covered item reports no `OWNER_DIRECTIVE_RELAY_MISSING` and a missing entry is still reported; no production change is made to the stop-hook files.
- [ ] AC-10: Ledger validation in the stop hook (rules B2-B8 applied to ledger lines through `Get-OrchestratorStateOwnerDirectiveError`): ledger lines containing each listed character with matching hashes validate, and a line with a mismatched hash is rejected.
- [ ] AC-11: `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` rule B5: rows prove `Get-OwnerDirectiveTextDigest` of U+1F600 equals the SHA-256 of bytes `F0 9F 98 80`, an entry with each listed character and a matching hash passes B5, and an entry whose hash was computed over the hyphen-substituted text fails B5; the module is not modified.
- [ ] AC-12: Fail-before proof: a Pester row decodes the UTF-8 bytes of a relay payload with `[System.Text.Encoding]::Latin1`, passes the result as `HookInputRaw`, and asserts `OWNER_DIRECTIVE_RELAY_REQUIRED`, while the output of the UTF-8 reader for the same bytes is allowed; a run of the AC-1, AC-3, and AC-5 rows against the unchanged dispatchers is recorded failing under `evidence/regression-testing/` (or a `fail-before-exception.<timestamp>.md` dossier if the run is structurally a discovery failure) before the production change, with clock timestamps, append-only, and no absolute paths.
- [ ] AC-13: All new and changed tests use in-memory seams only: no temporary files, no assignment to `[Console]::InputEncoding` or `[Console]::OutputEncoding`, no `[Console]::SetIn`, every stream disposed, and test source files contain only ASCII characters.
- [ ] AC-14: Both bundle copies under `extensions/drm-copilot/resources/` are byte-identical to their canonical dispatchers, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_push_down_pack_manifest_dependency_closure.py` pass.
- [ ] AC-15: Existing suites pass unchanged in assertion: `PreToolUsePayload.Contract.Tests.ps1`, `HookPayload.Tests.ps1`, `HookDispatchRunner.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1` (rule S1), `PreToolUseDispatch.Parity.Tests.ps1`, both dispatcher test files, `codex-pretooluse-integration.Tests.ps1`, `codex-bundle-hook-probe.Tests.ps1`, `claude-settings.Tests.ps1`, `HookProcessCost.Tests.ps1`, `enforce-owner-directive-pass-down.Tests.ps1`, `owner-directive-pass-down-target.Tests.ps1`, `validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1`, `validate-orchestrator-output.OwnerDirectives.Tests.ps1`, every `OrchestratorStateOwnerDirective*.Tests.ps1` file under `tests/scripts/claude-lib/orchestrator-state/`, `owner-directive-pass-down.Registration.Tests.ps1`, `owner-directives-skill-contract.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1`.
- [ ] AC-16: Per-file PowerShell line coverage is at least 85% for each changed production file, read from `artifacts/pester/powershell-coverage.xml` of the gate run.
- [ ] AC-17: No changed or new file exceeds 800 logical lines, and each changed or new test and production file in this item stays below 500 logical lines.
- [ ] AC-18: No copy of the execution-environment brief is modified, because no fact it states changes (D-10); the branch diff against `main` shows no change to any brief copy.
- [ ] AC-19: The comment-based help of both dispatchers states the UTF-8 stdin decode, the ASCII-escaped output, and (Claude dispatcher) that the `per-process` isolation mode is not covered by the decode fix.
- [ ] AC-20: The full PowerShell toolchain loop (Invoke-Formatter, PSScriptAnalyzer, Pester through the test-execution launcher in parallel, and the Python contract tests) passes in a single pass, and CI on the PR head is green.

## Risks & Mitigations
- Technical or operational risks:
  - The duplicated reader in the two dispatchers can drift. Mitigation: AC-4 parity row.
  - The default `OpenStream` script block never runs in unit tests. Mitigation: kept to one expression; all other reader lines covered by in-memory streams (AC-16).
  - Linux CI reports UTF-8 console encodings, so an end-to-end process test would pass without the fix. Mitigation: fail-before and regression rows decode bytes explicitly (UTF-8 versus Latin1) and never depend on the console code page (AC-12, AC-13).
  - Inserting a statement after the dot-source early return would break rule S1. Mitigation: only the existing emit gains a parameter (AC-15).
  - Bundle copies drift from canonical files. Mitigation: copy in the same task and run both contract tests (AC-14).
- Mitigations and rollbacks: revert the two dispatchers and their bundle copies; no data migration.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; isolated subagents pick up the fixed dispatcher only after merge because they run the default branch's hook scripts. Installed-extension push-down targets receive the fix after the extension bundle is rebuilt and reinstalled.
- Post-fix monitoring or clean-up tasks: optional live delegation with an em-dash directive after merge. Directives previously re-recorded with ASCII substitutes (the #1158 run, ORCH-D5) remain as recorded; they are not rewritten, because recorded entries are never edited.
- Links: issue #1187; PR #1184 (ORCH-D5); issue #1157 (pass-down hook); research `research/research.2026-11-14T18-14.md`.
