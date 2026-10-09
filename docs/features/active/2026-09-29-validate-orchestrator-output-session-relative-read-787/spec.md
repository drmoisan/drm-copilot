# 2026-09-29-validate-orchestrator-output-session-relative-read (Spec)

- **Issue:** #787
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-20
- **Status:** Ready for planning
- **Version:** 0.1

## Context

This feature is child C6 of epic #852 (enforcement-hook-precision), wave 1 (0-indexed). The primary issue is #787. The same pull request delivers and closes #840. Work mode is `full-bug`, so this spec is the only acceptance-criteria source; `user-story.md` is intentionally absent.

- **#787.** `.claude/hooks/validate-orchestrator-output.ps1` runs at SubagentStop and reads `-CheckpointPath` relative to the process location (the session root). #690 moved the PreToolUse gates onto `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, but this hook was out of #690 scope. In the two-worktree topology, where the run checkpoint lives in a different worktree from the session root, the hook can read a missing or stale checkpoint and block the orchestrator when it terminates.
- **#840.** Three documents state that the epic wave-barrier Layer 2 ordering check runs at `epic-orchestrator` SubagentStop. It does not. The `epic-orchestrator-state` leg of the hook runs only a structural check. Operator decision (fixed, not re-opened): port the Layer 2 check to PowerShell, invoke it from `validate-orchestrator-output.ps1` for `epic-orchestrator-state`, and keep Python out of the hook entirely.

Epic constraints that apply (`docs/features/epics/enforcement-hook-precision/epic.md:116-120,132-133,154-156,168-175`): `WorktreeRunResolution.psm1` is the single resolver for run checkpoints and is consumed, not edited, by C6 (C3 #850 owns its #789 corrections); existing deny tokens keep their lead text; an unresolvable or ambiguous target fails closed; every changed file updates its bundled mirror.

Research record: `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/research/research.2026-10-08T14-00.md` (cited below as "research").

## Repro & Evidence

All citations below were read against this worktree by the research step on 2026-10-08. No live two-worktree run was executed; the behavior is established from code reading.

- **Steps to reproduce (#787), from code.**
  1. Start an epic run whose integration worktree (holding `artifacts/orchestration/epic-orchestrator-state.json`) differs from the session root.
  2. Let `epic-orchestrator` stop. The SubagentStop registration passes `-CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state` (`.claude/settings.json:269-277`; `.claude/agents/epic-orchestrator.md:24-29`).
  3. The hook reads that relative literal through `Get-CheckpointFileContent -Path $CheckpointPath` (`validate-orchestrator-output.ps1:344`, which uses `Test-Path`/`Get-Content` at `:60,64`), and passes the same literal to `Test-OrchestratorStateCompletionReadiness` (`:261`) and `Get-OrchestratorStateCheckpoint` (`:190`, reading at `OrchestratorState.psm1:156,164`).
- **Expected vs actual.** Expected: the hook evaluates the checkpoint of the run that stopped. Actual: the hook evaluates whatever file exists at the session-relative path; a missing file blocks and a stale copy is evaluated as if current (research section 1.2).
- **Related session-relative read.** The `runbook_path` existence check in `Test-HumanInteractionShape` uses a process-relative `Test-Path` (`:101,143`).
- **Steps to reproduce (#840), from code.** The `epic-orchestrator-state` branch of `Invoke-RoutingContractValidation` calls only `Test-OrchestratorCheckpointStructure` (exists, parses, object root) (`:267-275`). `validate_wave_barrier_ordering` (`scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py:78-163`) is never invoked at SubagentStop. The documents that claim otherwise: `.claude/skills/epic-orchestrate/SKILL.md:244-254`, `.claude/agents/epic-orchestrator.md:122-127`, `.claude/hooks/enforce-epic-wave-barrier.ps1:26-29` (line numbers as of research; the last will move when C2 merges).
- **Frequency.** Deterministic for the code paths cited. Whether a given run hits #787 depends on topology (session root versus run worktree).
- **Runtime caveat (verified from code and vendor documentation, not observed in a live run).** The hook reads `$env:CLAUDE_HOOK_INPUT` (`:415`) and the payload `output` field (`:336-339`), and blocks with `exit 1` (`:416-419`). The Claude Code hooks reference (fetched 2026-10-08) documents SubagentStop input on stdin, a `last_assistant_message` field, and exit 2 as the only blocking code. The same defect class is recorded, unpromoted, in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md:12,39`. The decisions added by this feature are therefore likely to have no runtime effect until that entry is delivered (research finding 4).

## Scope & Non-Goals

- **In scope:**
  - Checkpoint resolution for all three artifact types in `validate-orchestrator-output.ps1`, implemented in a new dot-sourced sibling `.claude/hooks/validate-orchestrator-output-resolution.ps1`.
  - Moving the `runbook_path` existence check onto the resolved root.
  - A new PowerShell module `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` that ports `validate_wave_barrier_ordering`, invoked by the hook for `epic-orchestrator-state`.
  - A new parity fixture file under `tests/fixtures/epic_wave_barrier/`, a Pester parity lane, and a pytest parity lane.
  - Correcting the Layer 2 text in `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, and the header comment of `.claude/hooks/enforce-epic-wave-barrier.ps1`.
  - Bundled mirrors, `pack-manifests/core.json` registration, and the `OrchestratorState.Manifest.Tests.ps1` expected-path list.
- **Non-goals:**
  - The SubagentStop transport and exit-code defect (stdin versus `CLAUDE_HOOK_INPUT`, `last_assistant_message` versus `output`, exit 2 versus exit 1). It is recorded in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md` and is outside C6 (`epic.md:116-120`).
  - Any edit to `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (owned by C3 #850/#789; 497 lines).
  - Any change to Layer 1 logic in `enforce-epic-wave-barrier.ps1` beyond its header comment. C2 (#565) rewrites that file's feature lookup.
  - Extending the TypeScript parity lane (`extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts`) to the new fixture file.
  - Guarding the existing unguarded `OrchestratorState.psm1` import (C4 #786). C6 guards only the import it adds.
  - Porting `_validate_waves_consistency` or any other part of `validate_epic_orchestrator_state_text` beyond Layer 2.
- **Explicitly excluded:** Codex surfaces that make no Layer 2 claim (`.codex/hooks/enforce-epic-wave-barrier.ps1`, `.codex/agents/epic-orchestrator.toml`, `.agents/skills/epic-orchestrate/SKILL.md`), and the Python validator itself, which remains the authority used through the MCP validation call.

## Root Cause Analysis

- **Confirmed root cause (#787), from code.** The hook treats `-CheckpointPath` as a process-relative literal at every use (`:32`, `:319`, `:344`, `:390` → `:288` → `:261` and `:270` → `:190`, `:415`). The #690 resolver migration did not include SubagentStop hooks, so no resolution step exists between payload parsing and the first read.
- **Confirmed root cause (#840), from code.** The epic and parallel legs of `Invoke-RoutingContractValidation` were scoped to a structural check (PD-3). The interpreter leg that could have run the Python validator was removed by #475 (`:204-209`), and the no-Python guard forbids reinstating it (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:40-41`). The documents were not updated when that leg was removed.
- **Affected components:** `.claude/hooks/validate-orchestrator-output.ps1`; `.claude/lib/orchestrator-state/` (new module); the three #840 documents; their bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/`; Pester suites under `tests/scripts/claude-hooks/` and `tests/scripts/claude-lib/orchestrator-state/`; a pytest suite under `tests/scripts/dev_tools/`.

## Proposed Fix

### Design summary (what changes where):

1. **Resolution seam.** A new dot-sourced sibling `.claude/hooks/validate-orchestrator-output-resolution.ps1` exposes `Resolve-OrchestratorOutputCheckpointPath -ArtifactType -CheckpointPath -AgentOutput -SessionRoot`. It uses only exported resolver functions and returns either an absolute checkpoint path with its resolved root, or an unresolved result carrying `Status`, `ReasonCode`, and `Detail`. Per artifact type (research section 2.4):
   - `orchestrator-state` (kind `item`): `Resolve-WorktreeOperandTarget -Path '' -SessionRoot`, then `Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot <root>`.
   - `epic-orchestrator-state` (kind `epic`): first, `Find-WorktreeRunIdentitySignal` over the agent output; a non-null `IntegrationBranch` goes to `Resolve-WorktreeEpicTarget -IntegrationBranch -EpicSlug -SessionRoot`. Otherwise, discovery: enumerate `Get-WorktreeItemLiveRoot`, read each root's epic checkpoint through `Get-WorktreeRunCheckpointText` and `Get-WorktreeRunCheckpointPath -Kind epic`, and collect distinct `integration_branch` values from checkpoints whose `route_id` is `epic` (ordinal). One distinct value goes to `Resolve-WorktreeEpicTarget`; none is `NoTarget`; more than one is `Ambiguous`.
   - `parallel-orchestrator-state` (kind `parallel`): the same precedence with `ParallelSlug`, `Resolve-WorktreeParallelTarget`, and `route_id` `parallel`.
2. **Hook wiring.** The hook dot-sources the sibling and imports `WorktreeRunResolution.psm1` inside a guard. `Invoke-OrchestratorOutputValidation` calls the seam after the payload checks (`:326-342`) and before `Get-CheckpointFileContent`. It blocks unresolved targets with the new lead token and otherwise passes the absolute path to every downstream read, including the `FileExistsCheck` seam used for `runbook_path`.
3. **`-CheckpointPath` cross-check.** The bound value is kept and interpreted as a repository-relative leaf. It is composed beneath the resolved root and must equal the canonical path returned by `Get-WorktreeRunCheckpointPath` for the artifact type's kind. A rooted value, a value that escapes the root, or a value that differs from the canonical path blocks with the new lead token.
4. **Layer 2 port.** `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` exports `Get-OrchestratorStateEpicWaveBarrierError -CheckpointText <string>` returning `string[]`. It parses with `System.Text.Json` (`JsonDocument`), reproduces the algorithm in research section 3.2, and handles the parity traps in research section 3.4. For `epic-orchestrator-state` only, after the routing dispatch passes, the hook calls it with the checkpoint text already read, so the `Invoker` signature `param($Path, $Type)` is unchanged.
5. **Parity corpus.** A new file `tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json` uses the `start-guard-matrix.json` schema. `start-guard-matrix.json` is not changed.
6. **Documentation.** The Layer 2 text in the three #840 documents and their mirrors is corrected (see Acceptance Criteria).

### Boundaries and invariants to preserve:

- The `orchestrator-state` decision is unchanged for the case where the process location is the item's worktree; only the path becomes absolute.
- When resolution does not produce exactly one target, no checkpoint file is read, including the session-root copy.
- The payload `cwd` is never used as a target selector (#690 settled design).
- Existing lead tokens `ROUTING_CONTRACT_BLOCKED:` and `MODEL_ROUTING_BLOCKED:` and their message formats are unchanged.
- `EPIC_WAVE_BARRIER_VIOLATION:` lines are emitted unwrapped and byte-identical to the Python authority for in-parity inputs.
- The hook and its new files invoke no Python and spawn no Python subprocess.
- The existing SubagentStop registrations (`.claude/settings.json:260-286`, the three orchestrator agent frontmatters, and their mirrors) keep working with no argument change.
- Layer 1 and Layer 2 share no code.

### Dependencies or blocked work:

- **C2 (#565), upstream, wave 0.** C2 rewrites `enforce-epic-wave-barrier.ps1`. The header-comment correction in that file is applied only after C2 merges into `epic/enforcement-hook-precision-integration`, and the Layer 2 sentence is re-located by its text, not by line number (research section 4).
- **C3 (#850), same wave.** C3 owns `WorktreeRunResolution.psm1` and its #789 corrections. C6 consumes only `Find-WorktreeRunIdentitySignal`, `Get-WorktreeRunCheckpointText`, `Get-WorktreeRunCheckpointPath`, `Resolve-WorktreeEpicTarget`, `Resolve-WorktreeParallelTarget`, `Resolve-WorktreeOperandTarget`, and `Get-WorktreeItemLiveRoot` (`WorktreeItemResolution.psm1`). None reaches `Test-WorktreeRunPathEqual` (research section 2.3). After C3 merges, the C6 resolver tests are re-run against the merged module.
- **C4 (#786), downstream.** C4 enumerates hook imports after C6 merges; the guarded import added here is one of its inputs.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| File | Change | Bundled mirror |
|---|---|---|
| `.claude/hooks/validate-orchestrator-output.ps1` | Dot-source sibling, guarded resolver import, resolution call, absolute paths downstream, Layer 2 call, comment-help update | yes |
| `.claude/hooks/validate-orchestrator-output-resolution.ps1` (new) | Resolution seam and `-CheckpointPath` cross-check | yes; add to `pack-manifests/core.json` |
| `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` (new) | Layer 2 port | yes; add to `core.json` `paths` and `OrchestratorState.Manifest.Tests.ps1` `ExpectedPaths` |
| `.claude/skills/epic-orchestrate/SKILL.md` | Layer 2 bullet | yes |
| `.claude/agents/epic-orchestrator.md` | SubagentStop sentence | yes |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | Header comment only, after C2 merges | yes |
| `tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json` (new) | Parity corpus | n/a |
| `tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1` (new) | Two-worktree rows | n/a |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Tests.ps1` (new) | Unit rows | n/a |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1` (new) | Corpus lane | n/a |
| `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py` (new) | Python corpus lane | n/a |
| Existing `validate-orchestrator-output*.Tests.ps1` suites | Default resolution-seam mock; rewrite the relative-literal rows (`validate-orchestrator-output.Tests.ps1:361-414`) | n/a |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | `ExpectedPaths` gains the new module | n/a |

No `.codex` copy exists for the hook, the sibling, or the new module (research section 5). No `quality-tiers.yml` edit is needed because `.claude/lib/orchestrator-state` is already classified T3 (`quality-tiers.yml:61-63`).

#### Functions/classes/CLI commands impacted:

- `Invoke-OrchestratorOutputValidation`, `Test-HumanInteractionShape` (`FileExistsCheck` root), `Invoke-RoutingContractValidation` (receives an absolute path), and the hook entry point.
- New: `Resolve-OrchestratorOutputCheckpointPath`, `Get-OrchestratorStateEpicWaveBarrierError`, and private helpers for prefix normalization, the union index, reference resolution, the start guard, canonical numeric keys, and reference rendering.

#### Data flow and validation changes:

Payload parse → resolution (block on unresolved or cross-check failure) → checkpoint read at the absolute path → required fields → human interaction (`runbook_path` under the resolved root) → routing dispatch (absolute path) → Layer 2 (epic only, on the text already read) → pass.

#### Error handling and logging updates:

- **Unresolved target:** `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: <ArtifactType>: <Status> (<ReasonCode>): <Detail>`. `<Status>` is the resolver status (`NoTarget` or `Ambiguous`). `<ReasonCode>` is the resolver reason code (`TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS`). The same lead token, with reason codes `CHECKPOINT_PATH_MISMATCH` and `RESOLVER_IMPORT_FAILED`, covers a failed `-CheckpointPath` cross-check and a failed resolver import. The import-failure message names the module.
- **Layer 2 violation:** the `EPIC_WAVE_BARRIER_VIOLATION:` lines, one per line, followed by a fixed instruction that the condition is a recorded ordering violation which the agent cannot clear, and that the agent must report it to the operator and halt. The text does not suggest editing timestamps, `merge_status`, or checkpoint history.
- **Layer 2 unevaluable input:** `EPIC_WAVE_BARRIER_UNEVALUABLE: <reason>` for the declared fail-closed divergence classes (unhashable `issue_num`, non-standard JSON literals, nesting depth over the `System.Text.Json` default). This token is distinct from the violation token.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. Rollback is a revert of the pull request. Given the runtime caveat, the hook's runtime decisions are unlikely to change until the transport defect is fixed, which limits the operational effect of a defect in this change.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- `Resolve-OrchestratorOutputCheckpointPath` returns an object with `Resolved` (bool), `CheckpointPath` (absolute, when resolved), `WorktreeRoot`, `Status`, `ReasonCode`, and `Detail`.
- `Get-OrchestratorStateEpicWaveBarrierError -CheckpointText` returns `string[]` (empty when there are no violations or the root is not an object), or throws an error whose message starts with `EPIC_WAVE_BARRIER_UNEVALUABLE:`.
- Violation strings (identical to `_epic_orchestrator_state_wave_barrier.py:153-162`):
  - `EPIC_WAVE_BARRIER_VIOLATION: {folder} is treated as started while dependency {dependency} is not merged`
  - `EPIC_WAVE_BARRIER_VIOLATION: {folder} worktree_created_at precedes dependency {dependency} merge_confirmed_at`

  `{dependency}` renders as Python `str()` of the raw reference: raw text for strings, the integer value for integral number tokens, and `True`/`False` for booleans.

#### Required configuration keys and defaults:

The `-CheckpointPath` and `-ArtifactType` parameters keep their current defaults. No new configuration keys.

#### Backward-compatibility expectations:

The existing registrations need no change. Consumers that match `ROUTING_CONTRACT_BLOCKED:` or `MODEL_ROUTING_BLOCKED:` are unaffected. Tests that assert the relative literal reaching the routing seam change by design.

#### Performance constraints (latency/throughput/memory):

Discovery reads at most one epic or parallel checkpoint per live worktree, the same order of work as the #690 PreToolUse gates. No additional constraint.

## Assumptions, Constraints, Dependencies

- **Assumptions:** the run's checkpoint records `route_id` and `integration_branch` (epic) or `parallel_slug` (parallel) as the resolver expects; the epic checkpoint carries the four required fields (`validate_epic_orchestrator_state.py:39-44`).
- **Constraints:** the 500-line cap per file (hook at 421 lines, `validate-orchestrator-output.Tests.ps1` at 490, `WorktreeRunResolution.psm1` at 497); no temporary files and no `TestDrive:` in tests; no Python in hooks; the change exceeds the direct-mode file budget, so the orchestrated path applies (`.claude/rules/powershell.md:39-41`).
- **External dependencies:** none beyond .NET `System.Text.Json`, which is already used in production (`.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1:23-26`).

## Data / API / Config Impact

- **User-facing changes:** new block tokens `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and `EPIC_WAVE_BARRIER_UNEVALUABLE:`; `EPIC_WAVE_BARRIER_VIOLATION:` is newly emitted at SubagentStop.
- **Data or migration:** none.
- **Telemetry:** none.
- **Compatibility:** `pack-manifests/core.json` gains two entries; the bundled extension payload gains two files.

## Test Plan

All Pester rows run in memory: resolver seams mocked in module scope `WorktreeRunResolution` (`Get-WorktreeItemLiveRoot`, `Get-WorktreeRunCheckpointText`), synthetic `/synthetic-worktrees/<name>` roots, the hook's `Get-CheckpointFileContent` and `FileExistsCheck` seams mocked, and committed fixtures opened read-only. The reference pattern is `tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1:47-72` and `WorktreeResolutionFixture.Helpers.ps1`.

- **`validate-orchestrator-output.WorktreeResolution.Tests.ps1` (new):** epic resolved to another worktree, with the read at that root; stale session-root epic copy losing to the branch owner; payload signal taking precedence over discovery; discovery with one run; two distinct live epics giving `Ambiguous`; no live epic giving `NoTarget`; parallel with none, one, or several matches; item kind composing an absolute path under the session worktree; `-CheckpointPath` mismatch, rooted, and parent-escaping values; resolver import failure; `runbook_path` resolved under the resolved root; for every unresolved row, the read seam, routing invoker, and Layer 2 function are not invoked.
- **`OrchestratorStateEpicWaveBarrier.Tests.ps1` (new):** a row per branch of the algorithm, the start-guard matrix, numeric and boolean reference keys, reference rendering, duplicate JSON keys within one object (last wins), each declared divergence class, and the non-object root.
- **`OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1` (new):** iterates every `*.json` file in `tests/fixtures/epic_wave_barrier/`, builds each document from `envelope` plus the case `features` with `System.Text.Json.Nodes.JsonNode`, and compares the port's output with `expected_barrier_errors`.
- **Hook rows:** the epic leg emits the violation block; the parallel and orchestrator-state legs do not invoke Layer 2; the block text contains the report-and-halt instruction.
- **Existing suites:** each suite that reaches `Invoke-OrchestratorOutputValidation` gains a default `BeforeAll` mock of the resolution seam so that it never resolves against the developer machine; the relative-literal rows are rewritten to assert the absolute path.
- **pytest `test_epic_wave_barrier_parity_corpus.py` (new):** runs the new fixture file through `validate_epic_orchestrator_state_text`, filtered by the `EPIC_WAVE_BARRIER_VIOLATION: ` prefix, so a wrong expectation in the corpus fails against the authority.
- **Coverage:** measured per file with Pester `CodeCoverage.Path` through self-hosted scratch scripts, because PoshQC MCP results carry no counts (research section 7).
- **Toolchain:** PowerShell format → analyze → test, run through PoshQC and confirmed by self-hosted counts. Python `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Bundle-parity suites: `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_poshqc_bundled_parity.py`, `OrchestratorState.Manifest.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`.
- **Manual validation:** none required. Live runtime confirmation is blocked by the transport defect and is out of scope.

## Acceptance Criteria

- [ ] `validate-orchestrator-output.ps1` resolves the run checkpoint for `orchestrator-state`, `epic-orchestrator-state`, and `parallel-orchestrator-state` by calling only exported functions of `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (plus `Get-WorktreeItemLiveRoot` from `WorktreeItemResolution.psm1`), following the per-type identity and precedence rules in Proposed Fix; `git diff` against the integration-branch base shows no change to `WorktreeRunResolution.psm1`.
- [ ] Every downstream read uses the resolved absolute root: `Get-CheckpointFileContent`, the `Path` passed to `Test-OrchestratorStateCompletionReadiness` and `Get-OrchestratorStateCheckpoint`, the Layer 2 input, and the `runbook_path` existence check through `FileExistsCheck`; Pester rows assert the absolute path that reaches each seam.
- [ ] When resolution yields `NoTarget` or `Ambiguous`, the hook blocks with a message that starts with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and contains the artifact type, the resolver status, and the resolver reason code; Pester rows assert that `Get-CheckpointFileContent`, the routing invoker, and the Layer 2 function are not invoked, so the session-root copy is never read.
- [ ] A bound `-CheckpointPath` is treated as a repository-relative leaf composed beneath the resolved root and cross-checked against the canonical path for the artifact type's kind; a rooted, root-escaping, or non-canonical value blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` and reason `CHECKPOINT_PATH_MISMATCH`, and the argument values used by the existing SubagentStop registrations in `.claude/settings.json` and the orchestrator agent frontmatters pass the cross-check unchanged.
- [ ] The `WorktreeRunResolution.psm1` import added to the hook is guarded; an import failure blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:`, reason `RESOLVER_IMPORT_FAILED`, and the module name, and no checkpoint is read.
- [ ] The lead tokens and message formats of `ROUTING_CONTRACT_BLOCKED:` and `MODEL_ROUTING_BLOCKED:` are unchanged, verified by the existing assertions in the `validate-orchestrator-output*.Tests.ps1` suites passing without edits to those assertions.
- [ ] A new suite `tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1` models the two-worktree topology (run checkpoint not at the session root) for the epic checkpoint, the parallel checkpoint, and the item checkpoint, including a stale session-root epic copy, payload-signal precedence, discovery, and concurrent-epic ambiguity, using only module-scope mocks of resolver seams and synthetic roots; no row creates a file, uses a temporary path, or uses `TestDrive:`.
- [ ] Every existing suite that reaches `Invoke-OrchestratorOutputValidation` mocks the resolution seam by default, and the rows that previously asserted the relative checkpoint literal assert the resolved absolute path instead.
- [ ] `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` exports `Get-OrchestratorStateEpicWaveBarrierError -CheckpointText`, ports `validate_wave_barrier_ordering` as reached through `validate_epic_orchestrator_state_text` (feature extraction, union index with prefix normalization, start guard, status and timing checks, status-before-timing precedence), and parses with `System.Text.Json` rather than `ConvertFrom-Json`.
- [ ] `validate-orchestrator-output.ps1` invokes the Layer 2 port for `epic-orchestrator-state` only, after the routing dispatch passes, on the checkpoint text already read; Pester rows show the epic leg blocking on a violation and the `parallel-orchestrator-state` and `orchestrator-state` legs not invoking the port.
- [ ] No Python is introduced: the hook, the resolution sibling, and the new module contain no Python leg and spawn no Python subprocess, verified by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and the invoker AST test in `validate-orchestrator-output.Tests.ps1` passing.
- [ ] For in-parity inputs, the port emits `EPIC_WAVE_BARRIER_VIOLATION:` lines whose text is identical to the Python authority, including Python `str()` rendering of string, integral numeric, and boolean dependency references, and the hook surfaces them unwrapped.
- [ ] Inputs in the declared fail-closed divergence classes (unhashable `issue_num`, non-standard JSON literals, nesting depth beyond the parser default) produce a block that starts with `EPIC_WAVE_BARRIER_UNEVALUABLE:` rather than a pass or a violation line, each verified by a Pester row.
- [x] A new fixture file `tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json`, using the `start-guard-matrix.json` schema, covers the candidate case categories in research section 3.5 (issue_num references, folder-hint prefixes, unresolved and non-string references, skipped malformed entries, case-variant status values and keys, timestamp ordering traps, empty-string start guard, self-dependency, duplicate folders, empty dependent folder); `start-guard-matrix.json` is unchanged.
- [ ] `OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1` runs every case in every `*.json` file under `tests/fixtures/epic_wave_barrier/` and asserts, per file, that the number of cases executed equals the length of that file's `cases` array, that the array is non-empty, and that each case's output equals `expected_barrier_errors`.
- [x] `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py` runs every case in `layer2-parity-edge-cases.json` through `validate_epic_orchestrator_state_text` with the `EPIC_WAVE_BARRIER_VIOLATION: ` prefix filter, asserts the executed case count equals the length of the file's `cases` array, and passes; the existing Python and TypeScript count assertions for `start-guard-matrix.json` are unchanged and pass.
- [ ] The declared divergence classes (non-integer numeric reference tokens, astral-plane string ordering, unhashable `issue_num`, non-standard JSON literals and nesting depth) are listed explicitly in the parity suite header, each with a Pester row pinning the port's behavior; duplicate JSON keys within one object are covered in the PowerShell unit suite.
- [ ] The Layer 2 violation block text instructs the agent to report the violation to the operator and halt, and contains no instruction or suggestion to edit timestamps, `merge_status`, or checkpoint history; a Pester row asserts both properties.
- [ ] The Layer 2 bullet in `.claude/skills/epic-orchestrate/SKILL.md` and its bundled mirror state that Layer 2 runs at `epic-orchestrator` SubagentStop as a PowerShell port in `OrchestratorStateEpicWaveBarrier.psm1` invoked by `validate-orchestrator-output.ps1`, that parity with `validate_epic_orchestrator_state_text` is pinned by `tests/fixtures/epic_wave_barrier/`, and that the Python validator remains the authority used through the MCP validation call.
- [ ] The SubagentStop sentence in `.claude/agents/epic-orchestrator.md` and its bundled mirror describe the same enforcement as the corrected SKILL.md bullet.
- [ ] After C2 (#565) merges into the integration branch, the Layer 2 sentence in the header comment of `.claude/hooks/enforce-epic-wave-barrier.ps1` is re-located by its text and corrected to describe the same enforcement, with no change to any function or other non-comment line of that file; the bundled mirror is updated to match.
- [ ] Each of the corrected document passages includes a short evidence-first note that the hook's runtime effect depends on the SubagentStop transport and exit-code defect recorded in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`.
- [ ] Every changed or new `.claude` file has a byte-identical bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`; Codex copies are updated where one exists (the plan records the check for each file); `pack-manifests/core.json` registers the resolution sibling and the new module; `OrchestratorState.Manifest.Tests.ps1` `ExpectedPaths` includes the new module; and `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_poshqc_bundled_parity.py`, and `OrchestratorState.Manifest.Tests.ps1` pass.
- [ ] No new or changed production or test file exceeds 500 lines; the resolution glue lives in the dot-sourced sibling and new test rows live in new test files.
- [ ] Pester line coverage is at least 85% for each of `validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, and `OrchestratorStateEpicWaveBarrier.psm1`, measured per file (no branch-coverage gate applies to Pester).
- [ ] The full PowerShell toolchain loop (format, analyze, test) and the full Python toolchain loop (black, ruff, pyright, pytest with coverage) complete without errors in a single pass. Pester failures recorded in the Phase 0 SET-LIB and SET-FULL baselines as pre-existing (KL-ADOPT, docs/features/potential/2026-10-01-issue-adoption-pester-folder-scoped-command-not-found.md; and local-orchestration-state dependent suites tracked by #737) are reported as residuals and do not block this criterion; any other failure does.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| A resolution defect blocks every orchestrator at SubagentStop. | The item kind keeps today's decision with an absolute path. Epic and parallel legs fail closed only on `NoTarget`, `Ambiguous`, cross-check failure, or import failure. Discovery resolves the common single-run case without agent cooperation. |
| A Layer 2 violation records history the agent cannot undo; once exit 2 blocks, the agent could loop or edit history to clear it. | The block text instructs report-and-halt and does not suggest editing timestamps or history (Acceptance Criteria). |
| The hook's decisions have no runtime effect until the transport defect is fixed. | Recorded in Repro & Evidence and in the corrected documents. The PR description states that decision logic is verified by tests. Recommend that the operator promote the potential entry. |
| Parity drift between the port and the Python authority. | The shared corpus is checked by both lanes; expectations are verified against the authority by the pytest lane; divergence classes are declared. |
| Parity drift with the TypeScript port. | The TypeScript lane continues to consume `start-guard-matrix.json` unchanged; extending it is a non-goal. |
| Concurrent C2 and C3 edits. | C6 edits only the Layer 1 header comment, after C2 merges, and does not edit the C3-owned module. Resolver tests are re-run after C3 merges. |
| 500-line cap. | Port in a lib module, glue in a dot-sourced sibling, new rows in new suites. |
| Existing suites resolve against the developer machine. | Default `BeforeAll` mock of the resolution seam in each affected suite. |
| Self-selection through the agent's own output. | Resolution still requires a live checkpoint recording the named branch, and `EpicSlug` is cross-checked; the discovery path takes no agent input. |

## Rollout & Follow-up

- **Release steps:** merge into `epic/enforcement-hook-precision-integration` after C2 (#565); the epic integration PR carries it to `main`.
- **Follow-up observations (not in C6 scope):**
  - `.claude/skills/orchestrate/SKILL.md:222` still describes a Python `--require-model-routing` invocation that predates #475.
  - `.claude/skills/parallel-orchestrate/SKILL.md:826` should be re-checked against the post-change behavior.
  - Layer 1 likely denies issue_num-keyed `depends_on` entries (from code reading, not run; research section 3.6). This belongs to C2 or a follow-up.
  - Promote `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md` (operator decision).
- **Links:** #787, #840, epic #852, upstream C2 #565, C3 #850, downstream C4 #786, #690, research `research/research.2026-10-08T14-00.md`.
