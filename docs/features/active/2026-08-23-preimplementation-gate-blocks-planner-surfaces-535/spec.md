# 2026-08-23-preimplementation-gate-blocks-planner-surfaces (Spec)

- **Issue:** #535
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23T21-05
- **Status:** Ready for planning
- **Version:** 1.0

## Context
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` denies every multi-item planning surface before any implementation work is attempted. The planner agents (`parallel-planner`, `epic-planner`) cannot write their own checkpoints and cannot launch preparation-mode `Agent(orchestrator)` delegations, so `/parallel-plan` and `/epic-plan` are blocked at their first mandatory operation.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: `/parallel-plan` (forked skill session, 2026-08-23); hook reproduced directly with constructed PreToolUse payloads
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` at `main`

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Authoritative research: `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/research/2026-08-23T20-24-preimplementation-gate-blocks-planner-surfaces-research.md`. This spec follows its recommendations (Approach A).

## Repro & Evidence
Steps to Reproduce:
1. Invoke the hook with a Write payload whose `file_path` is `artifacts/orchestration/parallel-planner-state.json` and no ready `orchestrator-state.json` present. The decision is `deny`. The same payload with `file_path` `artifacts/orchestration/orchestrator-state.json` is allowed, because `Test-ImplementationPath` exempts exactly that one literal (line 49) before applying the `\.(...|json|...)$` implementation-path match.
2. Invoke the hook with an `Agent` delegation payload carrying the preparation-mode kickoff text pinned verbatim by `.claude/skills/parallel-plan/SKILL.md`. The payload necessarily contains the substrings `atomic-executor` and `execute`, so `Test-ImplementationDelegation` (line 91) classifies it as an implementation delegation and denies it.
3. Observe that `Test-OrchestrationReady` requires a single `issue-num`, a single `feature-folder` under `docs/features/active/`, `route_id`, and `lifecycle_ready`. A multi-item planner run has no such tuple, so the gate can never be satisfied for the planner surfaces.

Expected:
- The orchestration checkpoints under `artifacts/orchestration/` are all writable by their owning agents without a single-feature ready checkpoint, since checkpoint authoring is orchestration bookkeeping, not implementation.
- A preparation-mode delegation (payload carrying `Preparation mode: true.` / `route_id: preparation.`) is not classified as an implementation delegation, because preparation performs promotion, research, planning, and preflight only — no atomic execution.

Actual:
- `Write`/`Edit` of `artifacts/orchestration/parallel-planner-state.json` and `artifacts/orchestration/epic-planner-state.json` is denied with `PREIMPLEMENTATION_GATE_BLOCKED` unless a single-feature-ready `orchestrator-state.json` exists. By inspection the same applies to `parallel-orchestrator-state.json`, `epic-orchestrator-state.json`, `powershell-orchestrator-state.json`, and `csharp-orchestrator-state.json`.
- Every preparation-mode `Agent(orchestrator)` delegation is denied because the delegation matcher regex-matches the whole payload against `...|atomic-executor|implementation|execute`.
- Consequence: `/parallel-plan` and `/epic-plan` cannot start in this repository. A `/parallel-plan` run on 2026-08-23 was blocked before fan-out after completing triage only.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:

  ```text
  PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require
  artifacts/orchestration/orchestrator-state.json to contain issue number,
  feature folder, route metadata, lifecycle readiness, and checkpoint state
  before implementation begins.
  ```

## Scope & Non-Goals
- In scope:
  - Widen the exempt checkpoint set in `Test-ImplementationPath` from one repo-relative literal to a membership check over seven repo-relative literals (design below).
  - Add a preparation-mode delegation exemption to the delegation classifier, using the field-scoped three-conjunct predicate pattern already used by `enforce-epic-wave-barrier.ps1`.
  - Land the identical behavioral fix in all four copies of the hook (canonical `.claude`, Claude push-down bundle, canonical `.codex`, Codex bundle), keeping the `.codex` pair byte-identical so its hash-binding contract test passes.
  - Extend the existing Pester suite with the thirteen case groups enumerated in research section 4.2 (restated under Test Strategy).
- Out of scope / non-goals:
  - Issue #516 absolute-path normalization (workspace-root stripping of `Write`-tool absolute paths). The exempt entries stay repo-relative literals behind one membership check so the #516 fix composes later; no per-path normalization logic is added here.
  - The `git add|commit` housekeeping gap in `Test-ImplementationCommand` (standing finding; unchanged by this fix).
  - `enforce-promotion-mcp-only.ps1` overbreadth (separate hook, separate defect).
  - Any change to `Test-OrchestrationReady`: the readiness tuple, its fields, and its semantics are untouched.
- Explicitly excluded systems, integrations, or datasets:
  - `enforce-checkpoint-monotonic.ps1` and every other checkpoint-reading hook (research section 6 verified no conflicts; none classifies checkpoint writes).
  - Kickoff artifacts (`parallel-kickoff-<slug>.md`, `epic-kickoff-<epic-slug>.md`): `.md` never matched the extension pattern; no change needed or made.
  - `.claude/settings.json` hook registration (matchers `Bash`, `Write|Edit`, `Agent` remain as-is in both settings copies).

## Root Cause Analysis
- The gate is keyed to the single-feature `orchestrator` route only. It predates the epic and parallel surfaces and has no concept of a planning (non-implementation) phase.
- `Test-ImplementationPath` exempts one literal checkpoint path (`$script:CheckpointPath`, hook line 10, compared at line 49); the other orchestration checkpoints end in `.json` and match the implementation-path extension pattern at line 52.
- `Test-ImplementationDelegation` (lines 81–92) serializes the entire tool payload with `ConvertTo-Json -Depth 20 -Compress` and substring-matches `execute`/`implementation`/`atomic-executor`, which fire on the pinned preparation kickoff prose that merely mentions the later execution phase.
- This is distinct from issue #516, which concerns absolute-path normalization of the exempt literal; the denials above reproduce with the repo-relative spelling.
- Related standing finding: the gate also pattern-matches every `git add|commit`, leaving housekeeping changes with no legitimate staging route. This fix keeps the gate fail-closed for genuine implementation operations and does not touch the command classifier.

## Proposed Fix

### Design summary (what changes where):
1. **Widened exempt checkpoint set** (`Test-ImplementationPath`). Replace the single-literal equality at line 49 with a membership check over a script-scoped array of exactly seven repo-relative literals:
   - `artifacts/orchestration/orchestrator-state.json`
   - `artifacts/orchestration/parallel-planner-state.json`
   - `artifacts/orchestration/parallel-orchestrator-state.json`
   - `artifacts/orchestration/epic-planner-state.json`
   - `artifacts/orchestration/epic-orchestrator-state.json`
   - `artifacts/orchestration/powershell-orchestrator-state.json`
   - `artifacts/orchestration/csharp-orchestrator-state.json`

   The entries are literals behind one membership check (e.g., `$script:CheckpointPaths -contains $NormalizedPath`) evaluated after the existing `-replace '\\', '/'` normalization performed by the caller. This is deliberately a literal set, not a directory-prefix or glob exemption, and it is the shape the future #516 root-stripping normalization slots into upstream. A distinct scalar remains pointed at `artifacts/orchestration/orchestrator-state.json` for the readiness read (`Get-CheckpointContent`) and the block-message text, because readiness is defined only for the standard checkpoint.
2. **Preparation-mode delegation exemption** (`Test-ImplementationDelegation`). Add a helper `Test-PreparationModeDelegation` evaluated before the existing whole-payload regex. It returns `$true` (exempt; not an implementation delegation) if and only if all three conjuncts hold:
   - `Get-ClaudeHookToolInputString -ToolInput $ToolInput -Name 'subagent_type'` equals exactly `orchestrator`;
   - the `prompt` field string (field-scoped, never the serialized whole payload) contains the literal `Preparation mode: true.` (trailing period included);
   - the `prompt` field string contains the literal `route_id: preparation.` (trailing period included).

   This is the same predicate pattern `enforce-epic-wave-barrier.ps1` uses (its lines 257–263), and `HookPayload.psm1` is already imported. On any extraction failure (missing/empty `prompt`, non-string `subagent_type`), the exemption does not apply and the existing regex path runs unchanged. Every other delegation classification is unchanged.
3. **Four-copy parity.** The same behavioral fix lands in all four copies identified by research section 1.3:
   - `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (canonical Claude)
   - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (Claude bundle)
   - `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (canonical Codex)
   - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (Codex bundle)

   The `.codex` copy is a divergent implementation (different line numbering, Codex transport), so the fix is applied to it in its own idiom, not byte-copied from `.claude`. The `.codex` pair's hash-binding contract test (`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, byte-identity `It` at line 111 via `Get-FileHash` over `$script:PreToolHookNames`) recomputes hashes at run time; its established update mechanism is updating the canonical `.codex` copy and the Codex bundle copy byte-identically in the same commit. Behavior assertions on the `.codex` copy's decision function in the same test file are extended/adjusted only where the two exemptions change a decision.

### Boundaries and invariants to preserve:
- Fail-closed default is preserved by construction: both changes are enumerated exemptions layered over unchanged deny logic. `Test-OrchestrationReady`, `Test-ImplementationCommand`, the payload-anomaly path, and the implementation-extension regex are not modified.
- The exemption releases only the checkpoint write / the delegation itself; the same PreToolUse gate remains registered on `Bash`, `Write|Edit`, and `Agent`, so any implementation write, toolchain command, or `git add|commit` a preparation child attempts is still denied without a ready checkpoint.
- The marker text alone must never exempt a delegation: the `subagent_type -eq 'orchestrator'` conjunct is load-bearing, and the marker check is scoped to the `prompt` field so a crafted `file_path` or other field cannot carry it.
- The block-decision reason keeps the `PREIMPLEMENTATION_GATE_BLOCKED` prefix and the phrases `route metadata` and `lifecycle readiness`, which existing tests assert.
- The `.codex` pair stays byte-identical (hash-binding contract test).

### Dependencies or blocked work:
- None blocking. Composes with (does not implement) issue #516 absolute-path normalization.
- Change budget: four production PowerShell files exceeds the direct-mode cap of 2 (`.claude/rules/powershell.md`), so execution routes through `powershell-orchestrator` or uses explicit approved batching. The plan must settle this routing up front.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (production)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (production mirror)
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (production)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (production mirror, byte-identical to canonical `.codex`)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (extend in place; no new test file)
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (only where the `.codex` copy's decision assertions are affected; the byte-identity `It` needs no edit)

#### Functions/classes/CLI commands impacted:
- `Test-ImplementationPath` — single-literal equality replaced with membership check over `$script:CheckpointPaths` (seven literals). `[OutputType([bool])]` and mandatory-parameter attributes retained.
- `Test-ImplementationDelegation` — calls new helper first; regex path unchanged as the fall-through.
- New: `Test-PreparationModeDelegation` (`[CmdletBinding()]`, `[OutputType([bool])]`, mandatory `$ToolInput` with `[AllowNull()]`) — the three-conjunct predicate.
- `Get-CheckpointContent` and the block-message text — continue to reference the standard-checkpoint scalar only; behavior unchanged.
- Equivalent function-level changes in the `.codex` copy, in its own idiom.

#### Data flow and validation changes:
- File-path branch: normalized path → feature-docs prefix check (unchanged) → checkpoint-set membership (widened) → extension regex (unchanged).
- Delegation branch: preparation-mode predicate first (new, field-scoped reads of `subagent_type` and `prompt` via `Get-ClaudeHookToolInputString`), whole-payload regex second (unchanged). Any extraction failure falls through to the regex.
- No change to payload acquisition, anomaly handling, checkpoint parsing, readiness evaluation, or decision-JSON shape.

#### Error handling and logging updates:
- None. Payload-anomaly deny reasons, malformed-checkpoint handling, and the entrypoint exit-code seam are unchanged. The deny reason text at hook line 216 is left as-is (it remains accurate post-fix: it is emitted only for genuine implementation operations).

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is reverting the hook edits; the pre-fix behavior (deny) is strictly more restrictive, so rollback cannot open an enforcement gap.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Hook contract unchanged: PreToolUse envelope JSON in (stdin or `-ToolInputRaw` seam), compact decision JSON out (`hookSpecificOutput.hookEventName`, `permissionDecision`, optional `permissionDecisionReason`), exit code 0 from the entrypoint (`.claude` copy) / established `.codex` exit-code contract for the Codex copy.
- Pure test seam unchanged: `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw <envelope JSON> -CheckpointRaw <checkpoint JSON>`.
- Post-fix decision table (no ready checkpoint present):

  | Operation | Decision |
  | --- | --- |
  | Write/Edit of any of the seven exempt checkpoint literals (relative spelling, either separator) | allow |
  | Write/Edit of any other `.json`/`.py`/`.ps1`/... path outside `docs/features/active/` | deny (unchanged) |
  | Write of `artifacts/orchestration/parallel-kickoff-<slug>.md` or `epic-kickoff-<epic-slug>.md` | allow (unchanged — `.md` never matched) |
  | `git add`/`git commit`, toolchain commands | deny (unchanged) |
  | `Agent(orchestrator)` with both verbatim preparation markers in `prompt` | allow |
  | `Agent(orchestrator)` without both markers, matching the implementation regex | deny |
  | `Agent(<any other subagent>)`, markers present anywhere | deny |
  | Empty/unparseable/flat payload | deny with payload-anomaly reason (unchanged) |
  | Malformed checkpoint for a genuinely implementation operation | deny (unchanged) |

#### Required configuration keys and defaults:
- None. The exempt set is a script-scoped constant array of seven repo-relative literals; no configuration file, environment variable, or settings key is added or read.

#### Backward-compatibility expectations:
- Every currently allowed operation remains allowed (the standard-checkpoint exemption is a member of the new set; feature-docs prefix and non-matching extensions unchanged).
- Every currently denied operation remains denied except the enumerated exemptions above.
- Hook registration matchers and the decision-JSON schema are unchanged; `PreToolUseSchema.Contract.Tests.ps1` continues to pass without modification.

#### Performance constraints (latency/throughput/memory):
- Negligible. One array-membership test over seven strings and, on the delegation branch, two field-scoped substring checks executed before (and typically instead of) the whole-payload JSON serialization. No new I/O.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The pinned kickoff markers `Preparation mode: true.` and `route_id: preparation.` remain verbatim in `.claude/skills/parallel-plan/SKILL.md` (line 105) and `.claude/skills/epic-plan/SKILL.md` (line 99); tests use the verbatim kickoff lines so drift breaks a test.
  - `HookPayload.psm1` (`Get-ClaudeHookToolInputString`, `Resolve-ClaudeHookToolInput`) is available to the hook as today; no module change required.
  - Repo-relative `file_path` spellings are what the reproductions and existing suite use; absolute-path twins are #516's test scope.
- Constraints (budget, performance, compatibility):
  - PowerShell only; enforcement hooks must not gain a Python leg (standing repository guidance).
  - Four production PowerShell files exceeds the direct-mode change budget of 2: route through `powershell-orchestrator` or batch with explicit approval; per-batch cap is 3 production files.
  - Each hook copy stays under 500 lines (canonical `.claude` copy is 270 lines; estimated +25 to +40 lines). The Claude test file (305 lines) plus ~100 lines of additions stays under 500.
  - Pester v5, advanced functions with `CmdletBinding()`, approved verbs, `[OutputType([bool])]` on predicates.
- External dependencies (services, libraries, releases): none. Verification is entirely local.

## Data / API / Config Impact
- User-facing or API changes: none. Hook decision schema, matchers, and registration unchanged. Behavioral change is limited to the two enumerated exemptions.
- Data or migration considerations: none. No checkpoint schema or artifact format changes.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI or config surface changes. The `.codex` canonical/bundle byte-identity contract is maintained; the Claude bundle copy is updated in the same change so push-down destinations receive the fix.

## Test Strategy
Extend `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` in place, driven entirely through the pure seam `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ... -CheckpointRaw ...` — no disk, no child processes, no temporary files, deterministic. Cover the thirteen case groups from research section 4.2:

1. Allow: `Write` of each of the seven exempt checkpoint literals with no checkpoint supplied (bootstrap case), as a `-ForEach` table or individual `It` blocks.
2. Deny: `Write` of a non-checkpoint `.json` under `artifacts/orchestration/` (e.g., `artifacts/orchestration/some-other-file.json`) — proves the exemption is a literal set, not a directory prefix.
3. Deny: `Write` of a checkpoint-named file outside `artifacts/orchestration/` (e.g., `scripts/parallel-planner-state.json`) — proves full-path equality.
4. Allow: backslash spelling of an exempt checkpoint — proves the existing `-replace '\\','/'` normalization applies to the widened set.
5. Allow: `Agent` payload with `subagent_type: 'orchestrator'` and a prompt that is the verbatim parallel-plan kickoff line (contains `atomic-executor` and `execute`), no checkpoint.
6. Allow: same with the verbatim epic-plan kickoff line.
7. Deny: `Agent` payload with `subagent_type: 'atomic-executor'` whose prompt contains both preparation markers (spoof case — the agent conjunct must control).
8. Deny: `Agent` payload with `subagent_type: 'orchestrator'` and an execution-mode prompt without the markers that matches the regex (e.g., mentions `atomic-executor`).
9. Deny: marker with a missing trailing period, or only one of the two markers present, when the payload otherwise matches the implementation regex (literal-match strictness).
10. Deny: markers present in a field other than `prompt` while `prompt` is regex-matching text (field-scoping proof).
11. Fail-closed regression: existing anomaly cases re-run green — empty payload, unparseable JSON, flat root shape, malformed `-CheckpointRaw` — all deny.
12. Regression: existing implementation write/command/delegation denials and ready-checkpoint allows unchanged.
13. Parity: the `.codex` byte-identity test in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes with the canonical `.codex` and Codex-bundle copies updated in the same commit; affected `.codex` decision assertions in that file updated for the two exemptions.

Additional strategy points:
- Use the verbatim kickoff lines from the two SKILL.md files as the allow-case prompts so the tests break if the pinned contract and the discriminator drift apart.
- Fail-before evidence: run the new allow cases against the unfixed hook to produce the failing baseline; record it under `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/regression-testing/`.
- Regression tests to add or update: all of groups 1–10 are new; groups 11–12 are re-runs of the existing contexts; group 13 touches the codex contract suite only where decisions changed.
- Edge cases and negative scenarios: covered by groups 2, 3, 7, 8, 9, 10, 11 (invalid inputs, near-miss literals, spoofed markers, malformed payloads/checkpoints).
- Error handling and logging verification: deny reasons keep the `PREIMPLEMENTATION_GATE_BLOCKED` prefix and the `route metadata`/`lifecycle readiness` phrases; anomaly reasons unchanged (asserted by existing tests re-run in group 11).
- Coverage impact and targets: line coverage >= 85% on each changed production hook file (uniform threshold; no PowerShell branch gate). All new branches (membership check, three-conjunct predicate, fall-throughs) are reachable through the seam.
- Toolchain commands to run: PoshQC format → analyze → Pester via the MCP commands (`mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`), restarting from format on any failure until a clean single pass.
- Manual validation steps: invoke the hook directly with the constructed payloads from Steps to Reproduce and confirm the decision flips for the checkpoint and preparation cases while remaining deny for implementation paths and execution delegations. Integration retest: `/parallel-plan` reaches its preparation fan-out and writes `artifacts/orchestration/parallel-planner-state.json` without a fabricated single-feature checkpoint.

## Acceptance Criteria
- [x] `Test-ImplementationPath` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` exempts exactly the seven repo-relative literals `artifacts/orchestration/orchestrator-state.json`, `parallel-planner-state.json`, `parallel-orchestrator-state.json`, `epic-planner-state.json`, `epic-orchestrator-state.json`, `powershell-orchestrator-state.json`, and `csharp-orchestrator-state.json`, expressed as literals behind a single membership check over the normalized path (no directory-prefix or glob exemption, no absolute-path entries, no per-path normalization logic).
- [x] A `Write`/`Edit` payload for each of the seven exempt checkpoint literals is allowed with no ready checkpoint present, in both forward-slash and backslash spellings (verified through the pure decision seam).
- [x] A `Write` payload for a non-checkpoint `.json` under `artifacts/orchestration/` (e.g., `artifacts/orchestration/some-other-file.json`) is still denied, proving the exemption is a literal set rather than a directory prefix.
- [x] A `Write` payload for a checkpoint-named file outside `artifacts/orchestration/` (e.g., `scripts/parallel-planner-state.json`) is still denied, proving full-path equality.
- [x] The delegation classifier exempts a delegation if and only if `tool_input.subagent_type` equals exactly `orchestrator` AND the `prompt` field (field-scoped, not the serialized payload) contains both literals `Preparation mode: true.` and `route_id: preparation.`; the verbatim parallel-plan and epic-plan kickoff lines are both allowed with no checkpoint present.
- [x] Spoofed-marker delegations remain denied: (a) both markers present but `subagent_type` is not `orchestrator`; (b) marker text present only in a non-`prompt` field while `prompt` matches the implementation regex; (c) only one marker, or a marker missing its trailing period, with an otherwise regex-matching payload.
- [x] All other delegation classification is unchanged: an `Agent(orchestrator)` payload without both markers that matches the implementation regex is denied, and engineer/atomic-executor delegations are denied pre-readiness exactly as before.
- [x] Fail-closed semantics are preserved and demonstrated by re-running the existing suite unmodified in intent: empty payload, unparseable JSON, and flat root shape deny with payload-anomaly reasons; malformed checkpoint content for a genuine implementation operation denies; implementation writes, toolchain commands, and `git add|commit` remain denied without a ready checkpoint; ready-checkpoint allows unchanged; `Test-OrchestrationReady`, `Test-ImplementationCommand`, and the decision-JSON schema are unmodified.
- [x] The identical behavioral fix is present in all four hook copies: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.
- [x] The `.codex` canonical and Codex-bundle copies are byte-identical in the same commit, and the hash-binding contract test in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes; any `.codex` decision assertions affected by the two exemptions are updated in that file per its established mechanism.
- [x] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` is extended in place with passing tests covering all thirteen case groups listed under Test Strategy, driven through `Invoke-OrchestrationPreimplementationGateDecision` with no disk I/O, child processes, or temporary files; the allow-case prompts are the verbatim SKILL.md kickoff lines.
- [x] Fail-before evidence exists: the new allow cases run against the unfixed hook produce a failing baseline recorded under `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/evidence/regression-testing/`.
- [x] PoshQC toolchain passes clean in a single pass (format → analyze → Pester via the MCP commands), with line coverage >= 85% on every changed production hook file.
- [x] No out-of-scope changes: issue #516 absolute-path normalization is not implemented, the `git add|commit` housekeeping gap and `enforce-promotion-mcp-only.ps1` are untouched, `Test-OrchestrationReady` is unchanged, and each hook copy and the extended Claude test file remain under 500 lines.

## Risks & Mitigations
- Technical or operational risks:
  - The exemption could be over-broad if implemented as a prefix or glob, allowing arbitrary future `.json` writes under `artifacts/orchestration/`. Mitigation: the literal set is mandated by design and proven by the deny tests in groups 2–3; a future checkpoint costs one literal plus one test.
  - The delegation exemption could be spoofed if the marker check ran over the serialized payload or omitted the agent conjunct. Mitigation: field-scoped `prompt` check plus the `subagent_type -eq 'orchestrator'` conjunct, proven by the spoof deny tests (groups 7–10); defense in depth remains because the same gate still denies any implementation write/command the exempted child attempts.
  - Marker drift between the SKILL.md kickoff contracts and the discriminator. Mitigation: allow-case tests use the verbatim kickoff lines, so drift fails the suite.
  - Copy divergence: fixing only the `.claude` copies leaves the defect live in the Codex runtime and push-down destinations; touching the `.codex` canonical without the bundle fails the hash test. Mitigation: four-copy parity is an acceptance criterion; the codex byte-identity test enforces its pair automatically.
  - Change-budget violation (4 production PowerShell files > direct-mode cap of 2). Mitigation: route through `powershell-orchestrator` or explicit batching, decided at planning time.
- Mitigations and rollbacks: revert the hook edits restores the strictly more restrictive pre-fix behavior; no enforcement gap can result from rollback.

## Rollout & Follow-up
- Release/rollout steps: land all four hook copies plus test updates in one feature branch/PR; the Claude bundle and Codex bundle copies ship the fix to push-down destinations through the existing publish path. No configuration or registration change is required.
- Post-fix monitoring or clean-up tasks:
  - Integration retest after merge: `/parallel-plan` reaches preparation fan-out and writes `artifacts/orchestration/parallel-planner-state.json` without a fabricated single-feature checkpoint.
  - Known deferrals recorded, not fixed here: issue #516 (absolute-path normalization — the membership-check shape composes with it), the `git add|commit` housekeeping gap, and the absence of monotonicity checks for the non-standard checkpoints (`enforce-checkpoint-monotonic.ps1` gap noted in research section 6).
- Links: issue #535 (https://github.com/drmoisan/drm-copilot/issues/535); research `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535/research/2026-08-23T20-24-preimplementation-gate-blocks-planner-surfaces-research.md`; related record for #516 `docs/features/potential/promoted/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path.md`; precedent hook `.claude/hooks/enforce-epic-wave-barrier.ps1`.
