# 2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow (Spec)

- **Issue:** #501
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-21
- **Status:** Ready for planning
- **Version:** 1.0

## Context

Every `PreToolUse` hook in `.claude/hooks/` is inert: on every tool call it emits `permissionDecision: allow` regardless of checkpoint state, so the entire deterministic enforcement surface fails open. The Pester suites encode the same wrong payload assumptions the hooks do, so CI is green and the defect is invisible.

The issue (`issue.md`) frames this as a single shape defect: hooks read `$toolInput.<property>` where Claude Code nests tool arguments as `$toolInput.tool_input.<property>`. The completed research (`research/2026-08-21T17-45-pretooluse-hook-payload-envelope-501-research.md`) confirms the shape defect and finds a second, prior defect underneath it. **Where the research and the issue disagree, the research is authoritative for this spec.** The corrections are:

1. **Transport defect (not in the issue).** Official Claude Code documentation states that command-hook input arrives on **stdin as JSON**. The documented hook environment contains neither `CLAUDE_TOOL_INPUT` nor `CLAUDE_HOOK_INPUT`. Every PreToolUse hook reads one or both of those variables and never reads stdin, so at runtime each hook receives an empty payload and takes its empty-input early return. **Correcting only the shape leaves every gate exactly as inert as it is today.** The fix therefore has two mandatory legs — transport and shape — and neither is optional.
2. **Corrected inventory (the issue undercounts).** The issue says 20 of 36 hook files are affected. The verified enumeration is **24 PreToolUse hook files: 24 of 24 carry the transport defect; 23 of 24 also carry the shape defect** (only `enforce-epic-invocation-origin.ps1` reads the nested shape, but over the wrong transport). All 24 are mirrored under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. The full per-file table with property names and line numbers is in research section Q3.
3. **A third fail-open (not in the issue).** The hooks' malformed-JSON path does `throw` then exit 1. Per the documented contract, only exit code 2 — or exit 0 with an emitted deny JSON — blocks a tool call; **exit 1 is non-blocking**. A hook that "fails" on a malformed envelope still lets the tool call proceed. Envelope anomalies must become an emitted deny decision (fail closed).

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a - hooks are PowerShell; PowerShell 7.6.5
- Command/flags used: `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1` with the payload supplied per shape/transport variant
- Data source or fixture: observed in the destination repository `drmoisan/TaskMaster` at `b9a9b92c`; the same code is present in this repository at `.claude/hooks/enforce-epic-merge-gate.ps1:363`; envelope contract confirmed against https://code.claude.com/docs/en/hooks (fetched 2026-08-21)

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Blocker. Every deterministic safety gate in the runtime is inert, including the merge gate, the PR-authoring receipt gate, the promotion-path gate, the batch-budget gates, the cohort barrier, the drift gate, and the worktree-removal gates. The failure is silent and fails open, and the test suite reports green. Any workflow whose safety argument rests on a `PreToolUse` hook currently has no enforcement at all.

## Repro & Evidence

Steps to Reproduce (issue steps, extended by research Q8 with the true-transport case):

1. Ensure no checkpoint satisfies the gate — for example `artifacts/orchestration/orchestrator-state.json` with `epic_mode: false` and `step9_status` not `"verified"`, and no epic or parallel checkpoint present.
2. True harness transport: with `CLAUDE_TOOL_INPUT` and `CLAUDE_HOOK_INPUT` unset, pipe `{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}` to `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1` via stdin.
3. Env transport, nested shape: set `CLAUDE_TOOL_INPUT` to the same nested payload and run the hook.
4. Env transport, flat shape: set `CLAUDE_TOOL_INPUT` to `{"command":"gh pr merge 999 --merge"}` and run the hook.
5. Compare the three decisions.

Expected: steps 2 and 3 must deny with a reason beginning `EPIC_MERGE_GATE_BLOCKED:`, because no checkpoint satisfies the gate.

Actual (pre-fix): step 2 allows (empty payload — transport defect); step 3 allows (root read misses the nested property — shape defect); step 4 denies with the correct reason. The decision logic is sound; the transport and the shape it reads are both wrong.

Evidence on record:

- **Static trace** (research Q8): `Invoke-EpicMergeGateDecision` at `.claude/hooks/enforce-epic-merge-gate.ps1:363` assigns `$toolInput.command` off the parsed root; against the nested payload the guard at line 364 returns the allow decision and the checkpoint logic at lines 376-388 is unreachable. Under the true stdin transport, `$ToolInputRaw` is empty and line 353 returns allow one guard earlier still.
- **In-session baseline probe** (`evidence/baseline/2026-08-21T21-58-merge-gate-inert-in-session-probe.md`): with no allow-branch satisfiable, `gh pr merge 999999 --merge` reached the `gh` CLI with no hook decision emitted and no `EPIC_MERGE_GATE_BLOCKED` reason. This probe is the acceptance check for the fix's end-to-end effect (AC-10).
- **Field observation** (issue Logs section): in one TaskMaster session on 2026-08-21, four `gh pr merge --merge` invocations, PR-creation/body-edit paths, and issue-creation paths all completed with no hook objection.
- **Why the tests did not catch it**: the hook suites construct the flat shape and pass it directly to the decision functions (`enforce-epic-merge-gate.Tests.ps1:43` uses `{"command":"gh pr merge --merge"}`), validating a payload the harness never sends. Exactly one suite (`enforce-epic-invocation-origin.Tests.ps1`) mentions `tool_input`.

## Scope & Non-Goals

- In scope:
  - The 24 PreToolUse hook files under `.claude/hooks/` enumerated in research Q3 (transport fix in all 24; shape fix in the 23 root-readers; transport fix only in `enforce-epic-invocation-origin.ps1`).
  - A new shared payload-reader module under `.claude/lib/` (see Proposed Fix).
  - The mirrored copies of every changed file, plus the new module, under `extensions/drm-copilot/resources/claude-customizations/.claude/`.
  - Migration of every affected PreToolUse hook Pester suite in `tests/scripts/claude-hooks/` to the nested envelope, a new module suite under `tests/scripts/claude-lib/hook-payload/`, and a new source-scanning contract suite.
  - Fail-closed handling of envelope anomalies (empty payload, unparseable JSON, missing `tool_input`).
- Out of scope / non-goals:
  - **SubagentStop validators.** The eight `validate-*.ps1` hooks read `$env:CLAUDE_HOOK_INPUT` root `output` and are very likely inert for the same transport reason, but on a different envelope (docs indicate `last_assistant_message`, not `output`) with different exit-code semantics. Their parsing must be left byte-unchanged by this fix; the defect will be filed as its own potential-bug entry (see Rollout & Follow-up). The planner must not widen #501 to absorb them.
  - **`.codex/hooks/`** — unaffected; every Codex hook already reads stdin (`[Console]::In.ReadToEnd()`) for its own envelope, fixed under the 2026-07-25 codex-pretooluse-hook-transport item. Must not be touched.
  - A bash rewrite of the hooks; a single wrapper/dispatcher registration in `.claude/settings.json`; any performance refactor. All considered and rejected in research Q5 / Rejected alternatives.
- Explicitly excluded systems, integrations, or datasets: `PostToolUse` (no hooks registered), `SessionStart` (`persist-session-id.ps1` is already stdin-first and reads the documented root-level `session_id`; unaffected).

## Root Cause Analysis

- **Transport (primary, from research):** the hooks read `CLAUDE_TOOL_INPUT` / `CLAUDE_HOOK_INPUT`, which the documented Claude Code hook environment does not set; command-hook input arrives on stdin as JSON. The wrong belief propagated through two in-repo artifacts that asserted the env-var transport without citing an observed payload (research Q1a, Provenance).
- **Shape (the issue's finding, confirmed):** the `PreToolUse` payload contract was never captured as a single shared reader; each hook re-implements the parse inline, so the wrong flat-root shape propagated by copy. Tool arguments are nested under `tool_input` (documented envelope: `session_id`, `hook_event_name`, `tool_name`, `tool_input`, `tool_use_id`, plus `agent_id`/`agent_type` inside subagents).
- `enforce-epic-invocation-origin.ps1` is the sole hook reading the nested shape, which shows the correct shape was known at least once and did not spread — evidence for a shared reader over per-hook parses.
- **Fail-open error path:** malformed JSON produces `throw` → exit 1, which the harness treats as non-blocking, so even a detected anomaly cannot block.
- The mirrored copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` must change with the originals or the push-down reverts the fix.
- The issue's open question — the exact envelope Claude Code emits — is resolved by research Q1/Q2 against official documentation; no further envelope research is a precondition for planning.

## Proposed Fix

### Design summary (what changes where):

Research Q5 Option A. A shared payload-reader module, e.g. `.claude/lib/hook-payload/HookPayload.psm1`, exporting approximately:

- `Read-ClaudeHookRawPayload` — **stdin-first** (`[Console]::In.ReadToEnd()` behind an injectable scriptblock seam, per the `persist-session-id.ps1` precedent), falling back to `$env:CLAUDE_HOOK_INPUT` then `$env:CLAUDE_TOOL_INPUT`; first non-whitespace source wins. Returns the raw string.
- `ConvertFrom-ClaudeHookEnvelope` — parses the raw JSON and returns the envelope object or a typed failure; never a silent `$null` for malformed input.
- `Get-ClaudeHookToolInput` — returns the envelope's nested `tool_input` object. **Strict: no flat-shape fallback.** A parsed payload with no `tool_input` key is an envelope anomaly, not a legacy shape to accommodate.

Each of the 24 hooks imports the module `$PSScriptRoot`-relative (`Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force`) and keeps its existing pure decision function, now fed the extracted `tool_input` (or the raw envelope where root keys such as `agent_type` are needed) instead of re-parsing a flat root. Envelope anomalies are converted into an emitted deny JSON (exit 0), never exit 1.

**Rejected alternative (recorded per research Q5 Option B):** per-hook inline correction — every hook gains its own stdin read, envelope parse, and nested extraction. Rejected because it duplicates the exact contract whose per-hook re-implementation caused this defect, adds ~600-800 duplicated lines, pushes at least one hook (`enforce-parallel-cohort-barrier.ps1`, entry point at line 491) over the 500-line production-file ceiling, multiplies the coverage surface by 24, and gives the regression guard nothing structural to assert against. Also rejected: a permissive dual-shape reader (keeps wrong-shape tests green and restores silent-allow on the next contract drift), a bash rewrite (scope explosion unrelated to the defect), and a single dispatcher registration (couples an unneeded routing refactor to a Blocker fix).

### Boundaries and invariants to preserve:

- Each hook's decision logic is unchanged; only transport and extraction change.
- Property-level tolerance is preserved: absence of `command` / `file_path` / `subagent_type` *inside* a well-formed `tool_input` remains an allow — that is each hook's scope filter (e.g. a Bash call legitimately carries no `file_path` for a hook also registered on Write|Edit; an Edit call carries `new_string` rather than `content`).
- `enforce-epic-invocation-origin.ps1` continues to read caller `agent_type` off the envelope root (documented location) and target `subagent_type` off `tool_input`.
- `validate-bash.ps1` is the one deliberate exception to fail-closed-on-empty: it is a dangerous-command denylist, not a receipt gate, and may retain allow-on-empty; its documented CLI/manual usage (unparseable raw treated as command text) must keep working.
- SubagentStop hooks' parsing byte-unchanged; `.codex/hooks/` untouched.

### Dependencies or blocked work:

- None. The fix is not scope-constrained by any concurrent work. An earlier instruction prohibiting changes to `.claude/settings.json` was withdrawn by the user; see Data / API / Config Impact for the standing finding.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- New: `.claude/lib/hook-payload/HookPayload.psm1` (and its mirror copy).
- Modified: the 24 PreToolUse hook files listed in research Q3 (and their mirror copies). Non-parsing helper files (`enforce-completion-helpers.ps1`, `enforce-parallel-drift-gate-helpers.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`) change only if call-site signatures move.
- Tests (single-copy, not mirrored): new `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1`; nested-envelope migration of every affected suite in `tests/scripts/claude-hooks/` (list in research Q4); new or extended source-scanning contract suite (`PreToolUseSchema.Contract.Tests.ps1` or sibling `PreToolUsePayload.Contract.Tests.ps1`).

#### Functions/classes/CLI commands impacted:

- New exported functions: `Read-ClaudeHookRawPayload`, `ConvertFrom-ClaudeHookEnvelope`, `Get-ClaudeHookToolInput`.
- Each hook's entry point and payload-acquisition seam; each hook's decision function signature where it currently accepts a raw flat payload.

#### Data flow and validation changes:

- Payload flow becomes: stdin → `CLAUDE_HOOK_INPUT` → `CLAUDE_TOOL_INPUT` (first non-whitespace wins) → envelope parse → strict nested `tool_input` extraction → existing decision logic.
- Three-part strictness policy (research Q6): envelope-level anomalies fail closed (deny); property-level absence inside `tool_input` stays an allow (scope filter); empty input on all transports fails closed for gating hooks (`validate-bash.ps1` excepted).

#### Error handling and logging updates:

- Malformed JSON, empty payload, and missing `tool_input` each produce an emitted deny JSON with a distinct reason, via exit 0 (repository convention) — never exit 1, which the harness treats as non-blocking.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a git revert of the change set plus mirror; the env-var fallback in the reader means the fix cannot be worse than the status quo under any transport theory.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Input: the documented `PreToolUse` JSON envelope on stdin (root keys `session_id`, `hook_event_name`, `tool_name`, `tool_input`, `tool_use_id`, optionally `agent_id`/`agent_type`), with `CLAUDE_HOOK_INPUT`/`CLAUDE_TOOL_INPUT` as fallback transports.
- Output: unchanged `hookSpecificOutput` decision JSON (`permissionDecision` allow/deny, `permissionDecisionReason` on deny), already contract-tested by `PreToolUseSchema.Contract.Tests.ps1`.
- Edge cases the reader must pin: stdin read throwing (fall back), CRLF and BOM in stdin text, `tool_input` present but `$null`, `tool_input` present as a non-object, Edit payloads carrying `new_string`/`old_string` without `content`.

#### Required configuration keys and defaults:

- None. **Finding (not a prohibition):** research concluded no `.claude/settings.json` change is required — the harness pipes stdin to the existing `pwsh -NoProfile -File <path>` command lines, and module resolution is `$PSScriptRoot`-relative. If implementation discovers a settings change is required, that is permitted; it is simply not expected.

#### Backward-compatibility expectations:

- Deliberately none for the flat payload shape: the strict reader rejects it as an envelope anomaly. Every flat-shape test fixture fails against the strict reader by design, forcing visible migration.
- The env-var transports remain accepted as fallbacks, so any undocumented wrapper that sets them keeps working when it supplies the nested envelope.

#### Performance constraints (latency/throughput/memory):

- One additional `Import-Module` of a small `.psm1` per hook invocation, comparable to imports four hooks already perform. No measurable latency budget is at risk; no criterion is set beyond no observed regression in the test run.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - The documented envelope (stdin JSON, nested `tool_input`) is what the installed Claude Code version sends. No artifact in this repository records a captured live payload; the stdin-first-with-env-fallback design is correct under either state of the world (research Q1a, residual uncertainty). The end-to-end live probe (AC-10) is the confirming observation.
- Constraints (budget, performance, compatibility):
  - **No Python in the enforcement hooks.** Bash preferred, PowerShell acceptable; this fix stays PowerShell. A Python leg would create a second implementation that drifts. The regression guard's `.claude/settings.json` parsing happens in test code, not in a hook.
  - **The push-down mirror must change with the originals** — mechanically enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
  - **500-line production-file ceiling** applies to the new module and to each hook after edits. The recommended module approach adds ~3 lines per hook and stays within it; the rejected inline approach would breach it on at least one hook.
  - **PowerShell coverage policy:** line coverage >= 85%; Pester measures no branch coverage, so no branch criterion exists; no production PowerShell file may be excluded from the coverage denominator.
- External dependencies (services, libraries, releases): none beyond the existing PoshQC/Pester toolchain and pytest for mirror parity.

## Data / API / Config Impact

- User-facing or API changes: none. Hook decision output schema is unchanged.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): anomaly deny reasons are new, distinct strings (empty payload / unparseable / missing `tool_input`); no other logging change.
- Compatibility notes (CLI flags, config schemas, versioning): no `.claude/settings.json` change expected (finding, not prohibition — see Technical specifications). `.codex/` config untouched.

## Test Strategy

Seeded from issue (all four items are carried into the Acceptance Criteria below):

- [x] Unit coverage areas: every affected hook's payload-parse path, exercised against the nested shape; a negative test per hook proving the gate denies when it should. (AC-6, AC-7)
- [x] Integration scenario to retest: the differential test in Steps to Reproduce — only the nested form is honoured; the flat form is an envelope anomaly and denies. (AC-2, AC-3, AC-4)
- [x] Manual verification notes: confirm `enforce-epic-merge-gate` denies an unauthorised merge command under the payload Claude Code actually sends. (AC-10)
- [x] Regression guard: a test that fails if any hook reads a payload property directly off the parsed root instead of through the shared reader. (AC-8)

- Regression tests to add or update:
  - Source-scanning contract suite (research Q7 guard 1; precedent: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`): derives the PreToolUse hook list by parsing `.claude/settings.json` (so a newly registered hook is automatically in scope), then asserts per hook file: (a) an `Import-Module` reference to the shared payload module and a call to its reader entry point are present; (b) the literals `$env:CLAUDE_TOOL_INPUT` and `$env:CLAUDE_HOOK_INPUT` are absent (they may appear only inside the shared module's fallback).
  - Mirror-divergence guard: already exists — `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` asserts byte parity for all `.claude/**` files against the bundle. Cited, not reinvented.
- Unit tests for the fixed behavior and boundaries (Pester, not pytest — the fix is PowerShell):
  - New module suite `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1`: transport precedence (stdin wins over both env vars), fallback order, stdin-read-throw fallback, anomaly classification, nested extraction, and the edge cases listed under Technical specifications. Stdin is injected through the scriptblock seam; no temporary files.
  - Every affected hook suite migrates its payload fixtures to the nested envelope and gains one negative deny-under-nested-envelope test.
- Edge cases and negative scenarios: empty payload on all transports; unparseable JSON; parsed JSON missing `tool_input`; `tool_input` `$null` or non-object; CRLF/BOM stdin; flat root shape (must deny as anomaly); Agent envelope with root `agent_type`.
- Error handling and logging verification: anomaly paths assert exit 0 with an emitted deny JSON (or exit 2) and never exit 1.
- Coverage impact and targets for changed lines/modules: PowerShell line coverage >= 85% with the new module and all touched hooks in the denominator; no branch gate (Pester limitation); no new coverage exclusions.
- Toolchain commands to run (format → lint → test): `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`; plus `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` for mirror parity. Type checking is skipped for PowerShell per repository policy.
- Manual validation steps (if required): the in-session probe (AC-10), repeated post-fix and filed as QA-gate evidence.

## Acceptance Criteria

Every criterion is independently verifiable and capable of failing. Pre-fix expected results are stated where they differ, so each check discriminates.

- [x] **AC-1 (transport, unit).** `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1` exists and passes, including named tests asserting: a payload supplied on stdin is used even when both `CLAUDE_HOOK_INPUT` and `CLAUDE_TOOL_INPUT` are set (stdin precedence); with whitespace-only stdin the fallback order is `CLAUDE_HOOK_INPUT` then `CLAUDE_TOOL_INPUT`; a throwing stdin read falls back rather than propagating. Verify: `mcp__drm-copilot__run_poshqc_test` (or `Invoke-Pester -Path tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1`).
- [x] **AC-2 (transport, end-to-end differential).** From the worktree root with `CLAUDE_TOOL_INPUT` and `CLAUDE_HOOK_INPUT` unset and no checkpoint satisfying any allow-branch, piping `{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}` into `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1` emits a deny decision whose `permissionDecisionReason` begins `EPIC_MERGE_GATE_BLOCKED:`. Pre-fix this command emits allow (research Q8), so the check fails against unfixed code.
- [x] **AC-3 (shape, isolated from transport).** Same checkpoint state, `CLAUDE_TOOL_INPUT` set to the nested envelope from AC-2 with empty stdin: the hook emits the same `EPIC_MERGE_GATE_BLOCKED:` deny. Pre-fix this is the issue's Step 2 and emits allow, so the check fails against shape-unfixed code even if transport were fixed via env fallback.
- [x] **AC-4 (fail-closed anomalies).** Named tests demonstrate that, for a gating hook (at minimum `enforce-epic-merge-gate.ps1`), each of the following produces an emitted deny JSON with process exit code 0 (or exit code 2), and in no case exit code 1: (a) empty payload on all three transports; (b) unparseable JSON; (c) JSON that parses but has no `tool_input` key — which includes the legacy flat root shape `{"command":"..."}`. Pre-fix, (a) and (c) allow and (b) exits 1, so each sub-check fails against unfixed code.
- [x] **AC-5 (deliberate exception pinned).** A named test asserts `validate-bash.ps1` retains allow-on-empty and continues treating unparseable raw text as the command text for denylist matching, preserving its documented manual/CLI usage.
- [x] **AC-6 (property-level tolerance preserved).** Named tests assert that a well-formed nested envelope whose `tool_input` lacks the hook's gated property (e.g. a Bash-call envelope with no `file_path`, evaluated by `enforce-orchestration-preimplementation-gate.ps1`) still produces allow — the scope-filter early returns survive the strict reader.
- [x] **AC-7 (per-hook nested deny test).** Each of the 24 PreToolUse hooks has at least one Pester test that feeds a nested envelope and asserts `permissionDecision` is `deny`, and the full `tests/scripts/claude-hooks/` tree passes with all payload fixtures migrated to the nested envelope. Verify via `mcp__drm-copilot__run_poshqc_test`.
- [x] **AC-8 (structural regression guard).** A source-scanning contract suite (extension of `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` or a sibling suite) passes, and by construction fails if reverted: it derives the PreToolUse hook set by parsing `.claude/settings.json` and asserts each hook file (i) imports the shared payload module and calls its reader entry point, and (ii) contains neither `$env:CLAUDE_TOOL_INPUT` nor `$env:CLAUDE_HOOK_INPUT` (permitted only inside the shared module). Falsifiability check: temporarily restoring the env read in any one hook makes the suite fail.
- [x] **AC-9 (mirror parity).** `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes with every changed hook and the new module copied byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/`. This existing test is the enforcement mechanism; no new mirror guard is invented.
- [x] **AC-10 (end-to-end, tied to the baseline probe).** In a live Claude Code session with no checkpoint satisfying any allow-branch (same preconditions as `evidence/baseline/2026-08-21T21-58-merge-gate-inert-in-session-probe.md`), a `gh pr merge 999999 --merge` tool call is DENIED by the hook with a reason beginning `EPIC_MERGE_GATE_BLOCKED:`, and the command does not reach the `gh` CLI. The pre-fix probe recorded the command reaching `gh`; the post-fix result must differ. Record the post-fix probe under `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/evidence/qa-gates/`.
- [x] **AC-11 (coverage).** The PoshQC Pester run reports line coverage >= 85% with `.claude/lib/hook-payload/HookPayload.psm1` and every modified hook in the coverage denominator. No branch-coverage criterion applies (Pester does not measure branch coverage). No coverage exclusion is added for any production PowerShell file; the diff to any coverage configuration contains no new production-path exclude entry.
- [x] **AC-12 (file-size ceiling).** No new or modified production file exceeds 500 lines. Verify: `Get-ChildItem .claude/hooks/*.ps1, .claude/lib/hook-payload/*.psm1 | ForEach-Object { [pscustomobject]@{ Name = $_.Name; Lines = (Get-Content $_.FullName).Count } } | Where-Object Lines -gt 500` returns no rows.
- [x] **AC-13 (scope boundaries held).** `git diff --name-only main...HEAD` contains no path under `.codex/hooks/`, and none of the eight SubagentStop validators (`validate-discovery-artifact-gate.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`, `validate-orchestrator-output.ps1`, `validate-planner-output.ps1`, `validate-pr-author-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`) appears in the diff.
- [x] **AC-14 (toolchain clean pass).** `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` all pass in a single sequential pass with no file modified by the format stage.

## Executed Outcome and Deviations (recorded at execution, issue #501)

Implemented as specified: the shared payload reader `.claude/lib/hook-payload/HookPayload.psm1`
(stdin-first behind two injectable scriptblock seams, then `CLAUDE_HOOK_INPUT`, then
`CLAUDE_TOOL_INPUT`), strict nested `tool_input` extraction with no flat-root fallback, and
fail-closed envelope anomalies emitted as a deny decision at process exit code 0. All 24
PreToolUse hooks were migrated and mirrored. `.claude/settings.json` needed no change, as the
research predicted.

Four deviations are recorded here because the plan did not anticipate them.

### 1. The mandated entry-point tail swallowed the decision JSON, and was corrected

The plan mandated the file tail `exit (Invoke-<Name>EntryPoint)`, citing
`enforce-evidence-locations.ps1` as precedent. That precedent is defective. PowerShell
evaluates the parenthesised expression and uses its value as the exit code, so a function
that writes its decision with `Write-Output` has that output captured INTO the exit
expression and the hook emits nothing at all on stdout.

The defect was verified empirically, both in isolation and against the pre-change
`enforce-evidence-locations.ps1` at `HEAD`, which emits an empty stdout for a forbidden path.
It was previously invisible because that hook was inert for the separate transport reason.

Following the plan literally would have shipped hooks that emit no decision, contradicting
AC-2, AC-3, and AC-4, which all require an EMITTED deny. The mandated
`Invoke-<Name>EntryPoint` seam and its `[int]` return are retained unchanged; only the tail
was corrected to write the decision before exiting:

```powershell
$entryPointResult = @(Invoke-<Name>EntryPoint)
if ($entryPointResult.Count -gt 1) {
    $entryPointResult[0..($entryPointResult.Count - 2)] | Write-Output
}

exit ([int]$entryPointResult[-1])
```

The correction was applied to all eight hooks carrying that tail, including the pre-existing
`enforce-evidence-locations.ps1` defect, which this feature therefore also fixes.

### 2. `enforce-mermaid-validation.ps1`'s allow-on-unparseable note was revised, not preserved

That hook carried a header note prohibiting a fail-closed change on unparseable input. The
note conflated two different conditions. The plan's Phase 2/3 preamble requires envelope
anomalies to fail closed in every migrated hook and names only `validate-bash.ps1` (AC-5) as
a deliberate exception, so the hook now denies on an ENVELOPE-level anomaly (empty payload,
unparseable envelope, missing or malformed `tool_input`) while keeping every CONTENT-level
tolerance the original note defends: an Edit fragment, a Markdown file with no fence, an
absent validation module, and an unclassifiable diagram all still allow. The header note was
rewritten to state that distinction rather than left contradicting the code.

### 3. Two suites outside the plan's list required migration

- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` drives five migrated
  decision functions with flat `-ToolInputRaw` fixtures. It was migrated incrementally in the
  batch that first changed each hook it references.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` dot-sources
  `enforce-pr-author-skill.ps1` and feeds it a flat payload. Under the strict reader its first
  test short-circuited on the anomaly, which also broke the two following tests: they mock a
  command that only becomes resolvable after that first test's call triggers a lazy
  `Import-Module`. Nesting the fixture restored both the assertion and the load order.

### 4. `[P6-T2]` was not executed by the executor

`[P6-T2]` requires the MCP tool `mcp__drm-copilot__new_potential_bug_entry`, which is outside
the executor's tool allowlist. Direct file writes under `docs/features/potential/` are exactly
what `enforce-promotion-mcp-only.ps1` exists to block, and that hook is live from batch B3
onward, so no substitute was attempted. The task maps to no acceptance criterion. It is
reported at handoff for the orchestrator, which holds the tool.

### Note on `.claude/settings.json`

No change was required or made. The contingency the Plan Overview allowed was not exercised.

## Risks & Mitigations

- Technical or operational risks:
  - **Residual transport uncertainty.** No live payload has been captured in this repository; an undocumented wrapper could set the env vars in some configuration. Mitigation: the reader is stdin-first with env fallback, correct under either state of the world; AC-10 confirms against the live harness.
  - **Fail-closed changes manual-invocation behavior.** A developer running a gating hook manually with no piped input now sees a deny instead of an allow. This is the intended posture for an enforcement gate; `validate-bash.ps1` is the one pinned exception (AC-5).
  - **Wholesale test migration.** Every flat-shape fixture fails against the strict reader. This is by design — the migration is forced and visible — but it is a large, mechanical test diff; the per-hook deny tests (AC-7) keep it honest.
  - **Mirror drift.** A fix landing without the mirror copies is reverted in destination repositories on the next push-down. Mitigation: AC-9 fails CI on any divergence.
- Mitigations and rollbacks: git revert of the change set plus mirror restores the status quo; no data or config migration is involved.

## Rollout & Follow-up

- Release/rollout steps: merge to `main`; the push-down carries the fixed hooks and the new module to destination repositories via the existing bundle.
- Post-fix monitoring or clean-up tasks:
  - Repeat the AC-10 live probe as final-QA evidence under `evidence/qa-gates/`.
  - **File the SubagentStop defect separately** as a potential-bug entry: the eight `validate-*.ps1` hooks read `$env:CLAUDE_HOOK_INPUT` root `output`; the documented envelope delivers `last_assistant_message` on stdin, and `exit 2` semantics differ from PreToolUse. The shared reader's stdin transport function is designed for reuse by that fix.
  - Optional confirmation (research, Automation Feasibility): an env-gated debug write inside the shared reader can persist one raw live payload to re-confirm the documented envelope against the installed Claude Code version. Confirmation only, not a dependency.
- Links: issue #501; research `research/2026-08-21T17-45-pretooluse-hook-payload-envelope-501-research.md`; baseline `evidence/baseline/2026-08-21T21-58-merge-gate-inert-in-session-probe.md`; prior art `.claude/hooks/persist-session-id.ps1` (stdin-first reader), `docs/features/potential/promoted/2026-07-25-codex-pretooluse-hook-transport.md` (identical transport fix on the Codex surface).
