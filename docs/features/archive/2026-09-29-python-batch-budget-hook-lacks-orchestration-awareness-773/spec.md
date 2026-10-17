# python-batch-budget-hook-lacks-orchestration-awareness (Spec)

- **Issue:** #773
- **Parent (optional):** none
- **Related:** #769 (PowerShell precedent, merged in PR #772, merge commit `91805f15`)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T18-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Research:** `docs/features/active/2026-09-29-python-batch-budget-hook-lacks-orchestration-awareness-773/research/2026-09-29T18-00-python-batch-budget-routing-research.md`
- **Structural precedent:** `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/spec.md`

## Context

The Python batch-budget hooks (`.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`) follow the session-keyed per-batch pattern that #769 replaced for PowerShell. They count production and test files per session, deny when a fixed cap is reached, and tell the caller to split the work, raise the cap, or delete the state file. They do not read the orchestrator checkpoint, so an orchestrated large-path Python change is capped the same way a direct-mode change is.

Owner direction (from #769, restated in `issue.md`, authoritative): the batch-budget hooks signal that a change touching more than 3 production files belongs on the large-path orchestrator (`/orchestrate`). The large path has no cap on the number of files it may touch. Batching instructions are removed. The Python threshold is already consistent on every surface (1-3 production files small, more than 3 large); no threshold number changes.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: any `Write`/`Edit` of a `.py` file inside an orchestrated run
- Data source or fixture: `.claude/state/python-batch-budget.<session_id>.json`, `.codex/state/python-batch-budget.<session_id>.json`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Any orchestrated Python change exceeding three production files, or three test files, is denied mid-execution. That is the class of change the large path exists to handle. The deny message offers batching, cap-raising, and state-deletion remedies that the owner has ruled out for PowerShell under #769.

## Repro & Evidence

Steps to Reproduce:
1. Start a full orchestration (`/orchestrate`) for work that requires more than three production Python files, or more than three test Python files.
2. Let the orchestrator reach execution with `route_id: large` in `artifacts/orchestration/orchestrator-state.json`.
3. Observe the Python hook deny the 4th distinct production path (or the 4th distinct test path) regardless of the checkpoint route.

Expected:
The threshold is a routing gate. Outside the large path, the 4th distinct production Python file is denied with an instruction to route the change through the orchestrator. Test files are never counted. On the large path, no Python write is denied for file count.

Actual (Claude, `.claude/hooks/enforce-python-batch-budget.ps1:293`):

```
Python per-batch budget exceeded: $kind file cap is $cap and is already full ($currentFiles). Requested new file: $normalized. Split the work into a new batch, raise the cap via CLAUDE_PYTHON_BUDGET_$kindUpper environment variable with approved scope, or reset the batch by deleting $StateFile.
```

Actual (Codex, `.codex/hooks/enforce-python-batch-budget.ps1:137`):

```
Python per-batch budget exceeded: $kind file cap is $cap and is already full ($currentFiles). Requested new file: $normalized. Split the work into a new batch, record an approved cap in $StateFile, or reset the batch by deleting that state file.
```

Frequency: deterministic. Every Python write past the cap in any session is denied; the hooks contain no reference to orchestration, routes, or checkpoints.

## Scope & Non-Goals

### In scope

1. **Claude Python hook** `.claude/hooks/enforce-python-batch-budget.ps1`: checkpoint seam, large-path allow, routing deny message, production-only counting, removal of the test cap, the `CLAUDE_PYTHON_BUDGET_*` override, and the persisted cap overlay; docstring rewrite.
2. **Codex Python hook** `.codex/hooks/enforce-python-batch-budget.ps1`: the same semantics with the Codex routing clause; the persisted cap overlay removed; a new testable entry-point function `Invoke-PythonBatchBudgetCodexEntryPoint`; docstring rewrite.
3. **Shared language-neutral route helper**, one copy per runtime, byte-identical:
   - `.claude/hooks/enforce-batch-budget-route.ps1` (replaces `.claude/hooks/enforce-powershell-batch-budget-route.ps1`, which is deleted along with its bundle copy).
   - `.codex/hooks/enforce-batch-budget-route.ps1` (new; replaces the inline route helpers in `.codex/hooks/enforce-powershell-batch-budget.ps1`).
   - Loaded by dot-source from `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`, and `.codex/hooks/enforce-python-batch-budget.ps1`.
   - A parity test binds the two copies.
4. **PowerShell hook rewiring** (no behavior change): `.claude/hooks/enforce-powershell-batch-budget.ps1` changes its dot-source path and its two helper call names; `.codex/hooks/enforce-powershell-batch-budget.ps1` removes its inline helpers and dot-sources the Codex helper.
5. **Registration surfaces**:
   - `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json`: remove the old helper entry.
   - `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: add `.claude/hooks/enforce-batch-budget-route.ps1`.
   - `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`: add `.codex/hooks/enforce-batch-budget-route.ps1`.
   - `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`: replace the old helper path; add both new helper paths.
   - `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`: add `'enforce-batch-budget-route.ps1'` to `$script:SharedModuleNames` (the only edit to that file).
6. **Extension-bundled mirrors** of every changed or new hook and helper, byte-identical to the repository copies.
7. **Python text surfaces** (research Section 5.1 and Section 6), replacing per-batch, batching, budget-override, and approval-based scope-expansion text with the routing rule:
   - `.claude/skills/python-change-budget-router/SKILL.md` and `.agents/skills/python-change-budget-router/SKILL.md`
   - `.claude/skills/invoke-python-engineer/SKILL.md` and `.agents/skills/invoke-python-engineer/SKILL.md`
   - `.claude/agents/python-typed-engineer.md`
   - `.codex/agents/python-typed-engineer.toml`, followed by regeneration of every generated variant with `scripts/dev_tools/generate_codex_agent_variants.py`
   - `.github/agents/python-typed-engineer.agent.md`
8. **Test-file routing clause removal** (orchestrator decision 1; research Section 5.2). The routing trigger is production files only:
   - `.github/agents/python-orchestrator.agent.md`
   - `.github/prompts/orchestrate-python-work.prompt.md`
   - `.codex/agents/python-orchestrator.toml`
9. **#769 residual** (orchestrator decision 2): remove the `budget: prod=<N>, test=<M>` override input at `.agents/skills/invoke-powershell-engineer/SKILL.md:26` and its bundle mirror. No other change to that file.
10. **Bundle mirrors** of every changed text file:
    - `.claude/**` -> `extensions/drm-copilot/resources/claude-customizations/.claude/**`
    - `.codex/**`, `.agents/**` -> `extensions/drm-copilot/resources/codex-and-agents-customizations/**`
    - `.github/**` -> `extensions/drm-copilot/resources/customizations/.github/**`
11. **Tests**: new routing suites for both Python hooks, a helper parity suite, and updates to existing suites that assert removed behavior (see Test Strategy).
12. **Follow-up records**: the entries listed under "Follow-ups" are recorded by the plan as potential entries under `docs/features/potential/`.

### Out of scope / non-goals

- `python-execution-only-typed` (orchestrator decision 3): `.github/agents/python-execution-only-typed.agent.md` and its bundle copy carry a separate 30/30 per-batch cap and a `budget:` override. No routing surface delegates to it. Not changed; recorded as a follow-up.
- Language-generic orchestrator surfaces (`.claude/agents/orchestrator.md`, `.github/agents/orchestrator.agent.md`, `.github/prompts/orchestrate-work.prompt.md`, `.codex/agents/orchestrator*.toml`, `.claude/skills/translate-copilot-to-claude/SKILL.md`). The `>3 test files` clause in `.github/agents/orchestrator.agent.md` and `.github/prompts/orchestrate-work.prompt.md` is recorded as a follow-up.
- Codex topology resolver (`scripts/dev_tools/resolve_codex_topology.py`, `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts`, `config/orchestration-routing.json`): the Python budget is already `max_production_files: 3` and routing already uses production count only. No change.
- Test classification rule D2 (`(^|/)tests/.*\.py$` or `(^|/)test_[^/]+\.py$`). Whether `*_test.py` or root-level `conftest.py` should classify as test is not addressed.
- C# budget hooks and text: covered by `docs/features/potential/2026-09-29-csharp-budget-text-per-batch-cap.md`.
- The #769 review Nit on triple checkpoint parsing in the helper: helper signatures are unchanged.
- A runtime `Test-Path` guard for a missing helper sibling: not added (research Section 2.2).
- "Implement in batches" and "small batches" plan-work-unit text in `python-typed-engineer` surfaces: not the cap; unchanged.

### Explicitly excluded systems, integrations, or files

- `.github/copilot-instructions.md` and `.github/instructions/*` are not modified. They carry no per-batch or production-file-count text.
- `.claude/rules/python.md` and `.agents/skills/python/SKILL.md`: no change-budget section; unchanged.
- `atomic-plan-contract`, `atomic-executor`, `atomic-planner`, `python-atomic-*`, `python-qa-gate`: no cap text; unchanged.
- `.claude/settings.json`, `.codex/config.toml`, `scripts/powershell/Publish-DrmCopilotExtension.ps1`: hook registration and state-file names are unchanged.
- No `.py` file is modified.

### Follow-ups (recorded by the plan under `docs/features/potential/`)

1. `python-execution-only-typed` 30/30 per-batch cap and `budget:` override (owner decision required).
2. Language-generic orchestrator test-file routing clause in `.github/agents/orchestrator.agent.md` and `.github/prompts/orchestrate-work.prompt.md` (and their bundle mirrors).

## Root Cause Analysis

The Python hooks implement the numeric half of the change-budget contract without the routing half. `python-change-budget-router` frames the threshold as a decision with two outcomes (direct mode, or escalation to the orchestrator), but the hooks implement only "deny past N" with a session-scoped counter. Subagents inherit the parent session id, so the count accumulates across an entire orchestration and never resets. The deny messages, the router's "Per-Batch Change Budget (Hard Gate)" and "Scope Expansion Protocol" sections, the `budget: prod=<N>, test=<M>` override input, and the typed-engineer "per-batch cap" text all direct agents toward a chunking and override model the owner has ruled out.

A second defect is the test-file dimension. The hooks cap test files independently, and three Python orchestration surfaces route to the large path on `>3` test files, while the #769 PowerShell surfaces and the Codex resolver route on production files only.

Signals: research Section 1 establishes that the Python hooks are structurally the pre-#769 PowerShell hooks with the language-specific values D1-D9; the deny messages and override blocks are cited at `.claude/hooks/enforce-python-batch-budget.ps1:211-212`, `:293`, `:423-430` and `.codex/hooks/enforce-python-batch-budget.ps1:75-76`, `:137`.

Affected components: the files listed under In scope.

## Proposed Fix

### Design summary (what changes where)

The approach follows research Sections 2, 3, 6, and 8 without deviation, plus the three orchestrator decisions recorded in In scope items 8 and 9 and Out of scope.

- Both Python hooks read `<Root>/artifacts/orchestration/orchestrator-state.json` through an injectable `[scriptblock] $ReadCheckpoint` seam and evaluate it with the shared route helper.
- **Large path:** every Python path is allowed without counting, without reading or writing state, and without creating the state directory.
- **Direct mode:** only distinct production Python paths are counted; the 4th is denied with a routing instruction. Test paths are allowed and never recorded.
- Cap overrides are removed. The threshold is a routing constant.
- The route predicate becomes one language-neutral helper per runtime, loaded by all batch-budget hooks, with a parity test holding the two runtime copies identical.
- Policy text drops the per-batch model and states the routing rule.

### Large-path detection signal

Identical to #769 `spec.md` "Large-path detection signal"; restated for completeness.

Signal: `<Root>/artifacts/orchestration/orchestrator-state.json`, where `<Root>` is the hook's existing root (`Split-Path (Split-Path $PSScriptRoot -Parent) -Parent` in the Claude hook; `$repositoryRoot` in the Codex wiring).

The session is on the large path only when all of the following hold:

1. The file exists and parses as a JSON object.
2. The selected route is one of `large`, `remediation`, `preparation`.
3. The checkpoint is not terminal: `next_step` is not `complete`, and `completed_steps` does not contain `S12_complete`.

Route precedence:

- When the `route_id` key is present, its value is the selected route, usable only when it is a non-blank string. A present-but-null, non-string, or blank `route_id` yields no route; `path_selected` is not consulted.
- When the `route_id` key is absent, `path_selected` is used under the same non-blank-string rule.

Fail-safe behavior: a missing file, an unreadable file, a throwing reader, malformed or non-object JSON, route `small`, a blank or unknown route, and a terminal checkpoint each yield direct-mode enforcement. The hook fails toward the deny behavior, never toward an unlimited allow, and no checkpoint condition causes a non-zero exit.

Execution context and rejected signals: as recorded in #769 `spec.md` (research Section 2.3 of #769). Isolated worktrees load `origin/main` hooks, so this change is not exercised by isolated subagents until merge.

### Known limitations

- **Stale non-terminal large-path checkpoint** at a root exempts a later direct-mode session at that root. Mitigation: orchestrator checkpoint hygiene (#673). Documented in both hook docstrings.
- **Agent-edited route**: a policy guard, not a security control; a falsified route fails the completion validator.

### Direct-mode behavior

- The first three distinct production Python paths are allowed and recorded; a repeated path is allowed without a state write; the 4th distinct production path is denied.
- Test paths (D2 rule) are allowed in every mode and never recorded.
- Deny message (Claude):

  ```
  PYTHON_LARGE_PATH_REQUIRED: this change touches more than 3 production Python files (already counted: <a>, <b>, <c>; requested: <d>). A change of this size belongs on the orchestrated large path, which has no production-file cap. Route the change through /orchestrate. Checkpoint route observed: <route or 'none'>.
  ```

- Deny message (Codex): identical except `Route the change through .codex/prompts/orchestrate-work.md.`
- Neither message contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_PYTHON_BUDGET`, `record an approved cap`, `deleting`, `python-batch-budget.`, or the state-file path or state directory.
- Removed: the `CLAUDE_PYTHON_BUDGET_PROD`/`CLAUDE_PYTHON_BUDGET_TEST` block in the Claude entry point and its docstring text; the persisted `prodCap`/`testCap` overlay in both hooks.
- Legacy state files carrying `prodCap`, `testCap`, and `testFiles` load without error; only `prodFiles` is carried over (Claude containment filter retained). Fresh state is `[ordered]@{ prodCap; prodFiles }`, where `prodCap` is the internal default 3.

### Shared route helper design

- File name: `enforce-batch-budget-route.ps1` under `.claude/hooks/` and `.codex/hooks/`. No entry point; dot-sourced. Reads no file and no environment variable. The two copies are byte-identical.
- Functions (behavior unchanged from the #769 helper; names neutralized):

  | New name | Replaces |
  |---|---|
  | `ConvertFrom-BatchBudgetCheckpoint -CheckpointText` | `ConvertFrom-PowerShellBatchBudgetCheckpoint` |
  | `Get-BatchBudgetSelectedRoute -CheckpointText` | `Get-PowerShellBatchBudgetSelectedRoute` |
  | `Test-BatchBudgetLargePathRoute -CheckpointText` | `Test-PowerShellBatchBudgetLargePathRoute` |

- The Claude helper ships in the Claude core pack, so every consumer that receives either Claude batch-budget hook also receives the helper (addresses #769 review Minor (b)). The Codex helper ships in the Codex core pack beside both Codex batch-budget hooks.
- Parity test (new, `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1`): asserts the Claude and Codex helper copies are byte-identical, and runs the route predicate table (route set, precedence, terminal markers, malformed/non-object/empty text) once against each copy (addresses #769 review Minor (a)).
- Rename ordering (research Section 8): the live Claude PowerShell hook must load a route helper at every step. The plan creates the new Claude helper, adds its dot-source beside the old one, switches the call sites, removes the old dot-source, and only then deletes the old helper and its bundle copy with a named shell command (`git rm`), because the file tools cannot delete.

### Large-path behavior

Identical to #769: non-terminal `large`, `remediation`, or `preparation` routes allow every Python path at any count with no state read, no state write, and no state-directory creation; `route_id` precedence over `path_selected`; fail-safe to direct mode on missing, invalid, terminal, or `small`.

### Boundaries and invariants to preserve

- Fail-closed deny on an unreadable envelope (Claude) and on malformed JSON (Codex); the envelope anomaly still denies under a large route.
- Allow when no `file_path` is present or the extension is not `.py`, before the checkpoint is read.
- Out-of-root candidates allowed without consuming a slot or writing state (Claude); containment filter on rehydrate unchanged.
- Test classification rule D2 unchanged.
- Session-id resolution order unchanged; Codex `-RequireSessionId` unchanged; both rename sides evaluated.
- Entry-point output is deny-only and strips `state`.
- `Get-PythonBatchBudgetBlockDecision` keeps its name, parameters, and deny shape.
- `-TestCap` remains an optional, ignored parameter on the state functions and the decision function (existing callers pass it), with the `PSReviewUnusedParameter` suppression #769 used; `-StateFile` becomes optional (default `''`).
- Codex hooks read no `$env:CLAUDE_*` variable.
- PowerShell hook behavior is unchanged; only its helper loading changes.
- Repository and bundle copies remain byte-identical.
- Hooks remain PowerShell only; no Python leg is introduced.
- No production or test file exceeds 500 lines.

### Dependencies or blocked work

- The preimplementation gate requires `lifecycle_ready: true` in the checkpoint before any `.ps1` write.
- This run writes no `.py` file, so the live Python hook is not exercised by its own execution. The live PowerShell hook (post-#769) reads this item's `route_id: large` and allows the `.ps1` writes; the helper rename ordering above keeps it loadable.
- End-to-end validation runs in the session worktree, not in an isolated subagent.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

- Hooks, helpers, and bundle copies: In scope items 1-4 and 6.
- Manifests, runsettings, `SharedModuleNames`: In scope item 5.
- Text surfaces and mirrors: In scope items 7-10.
- Tests: Test Strategy.

#### Functions/classes/CLI commands impacted

- `Invoke-PythonBatchBudgetHook` (Claude): new `[scriptblock] $ReadCheckpoint` seam; default reads `Join-Path $Root 'artifacts/orchestration/orchestrator-state.json'` when it exists and returns `''` otherwise. The env override block is removed.
- `Invoke-PythonBatchBudgetCodexEntryPoint -PayloadRaw -RepositoryRoot -HookSeams` (Codex, new): mirrors `Invoke-PowerShellBatchBudgetCodexEntryPoint`; top-level wiring calls it.
- `Invoke-PythonBatchBudgetDecision` (both): new `[switch] $LargePathRoute`; production-only counting; `-StateFile` optional; `-TestCap` optional and ignored; internal `-ProdCap` default 3 for testability only.
- `Get-PythonBatchBudgetState` / `ConvertTo-PythonBatchBudgetState` (both): persisted cap overlay removed; `-TestCap` optional and ignored; legacy keys ignored.
- `Invoke-PowerShellBatchBudgetHook` (Claude) and the Codex PowerShell entry point: call the neutral helper names.
- Helper functions: renamed as in "Shared route helper design".
- `scripts/dev_tools/generate_codex_agent_variants.py`: invoked, not modified.

#### Data flow and validation changes

- Entry point resolves the envelope, filters by extension, reads checkpoint text via the seam, evaluates `Test-BatchBudgetLargePathRoute`, and passes the result to the decision function.
- State written after the change carries only production paths.

#### Error handling and logging updates

- Checkpoint read or parse failures, including a throwing reader, are not errors; they yield direct-mode enforcement.
- Deny reasons as in "Direct-mode behavior". No other logging changes.

#### Rollback/feature-flag considerations

No feature flag. Rollback is a revert of the hooks, helpers, manifests, runsettings, text surfaces, and bundle copies. No data migration.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Input: PreToolUse envelope (unchanged) plus checkpoint JSON text (new, read-only).
- Output: deny JSON only on deny (unchanged shape); reason text as above.

#### Required configuration keys and defaults

- Checkpoint keys read: `route_id`, `path_selected`, `next_step`, `completed_steps`.
- Direct-mode production threshold: 3 (the 4th distinct production path is denied). Not configurable at runtime.
- Removed configuration: `CLAUDE_PYTHON_BUDGET_PROD`, `CLAUDE_PYTHON_BUDGET_TEST`, persisted `prodCap`/`testCap` overlay.

#### Backward-compatibility expectations

- Existing state files load without error.
- `Get-PythonBatchBudgetBlockDecision` contract (`PreToolUseSchema.Contract.Tests.ps1:77-81`) unchanged.
- Existing callers passing `-TestCap` continue to bind.
- Hook registration and state-file names unchanged.
- The `budget: prod=<N>, test=<M>` input is removed from both `invoke-python-engineer` copies and from `.agents/skills/invoke-powershell-engineer/SKILL.md`.
- The PowerShell-named helper functions are removed; the only in-repo callers (the PowerShell hooks and the #769 routing suites) are updated.

#### Performance constraints

One additional small file read per Python `Write`/`Edit`. No latency requirement beyond the existing hook timeout.

## Assumptions, Constraints, Dependencies

- Assumptions: the orchestrator writes `route_id` (or `path_selected`) before any implementation write; hook processes run with the session worktree as the directory containing `.claude/`/`.codex/`.
- Constraints:
  - No temporary files in tests; the checkpoint is supplied via the `ReadCheckpoint` seam as in-memory text, and state via the existing in-memory seams.
  - No test depends on the live checkpoint.
  - New suites go in new files where existing files are near 500 lines (`enforce-python-batch-budget.Tests.ps1` at 485 lines receives no new cases; `legacy-codex-hook-contracts.Tests.ps1` at 497 lines receives only the `SharedModuleNames` edit).
  - No production or test file exceeds 500 lines.
  - Line coverage >= 85% per changed hook and per helper copy; no regression on changed lines. PowerShell is exempt from the branch threshold.
  - Codex hooks must not read `$env:CLAUDE_*`.
  - `.github/copilot-instructions.md` and `.github/instructions/*` are unchanged.
- External dependencies: none.

## Data / API / Config Impact

- User-facing changes: Python deny message text and prefix; removal of the Python env and persisted cap overrides; removal of the Python test-file cap; removal of the `budget:` input from `invoke-python-engineer` (both copies) and `.agents/skills/invoke-powershell-engineer/SKILL.md`; Python orchestration surfaces route on production files only.
- Data or migration: none; legacy state keys are ignored.
- Logging/telemetry: none beyond the deny reason.
- Compatibility notes: helper file renamed and moved to the core pack on both runtimes; hook registration, state-file names, and `Get-PythonBatchBudgetBlockDecision` unchanged.

## Test Strategy

Framework: Pester v5 through PoshQC; Pytest for bundle-parity, manifest, and variant suites.

- Regression tests to add (new files):
  - `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`
  - `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`
  - `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1`
- Tests to update:
  - `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`: invert the test-path-recorded case; delete the test-cap deny case; change the production deny assertion to `PYTHON_LARGE_PATH_REQUIRED:*`; drop the loaded `testFiles` assertion; set a default empty `ReadCheckpoint` in `BeforeAll` via `$PSDefaultParameterValues`. No new cases.
  - `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`: set the Python row's `ExtraSeams` to the empty `ReadCheckpoint` seam (required; otherwise the row reads the live checkpoint); delete the Python-only cap Context and move surviving intent to the new Codex Python routing suite; update the header comment.
  - `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`: `SharedModuleNames` only.
  - `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` and `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`: rename the helper calls to the neutral names only; no assertion is removed or weakened.
- Cases required in both new Python routing suites (Python paths `src/a.py`, `scripts/b.py`; test paths `tests/unit/test_a.py` and root-level `test_a.py`):
  - Direct mode: first three distinct production paths allowed; 4th denied with the required prefix, routing target, and none of the prohibited substrings; repeated path allowed without a state write.
  - Large routes (`large`, `remediation`, `preparation`): six distinct production paths allowed with zero state writes and zero directory ensures; `path_selected`-only `large` treated as large.
  - Terminal large (`next_step: "complete"`; `S12_complete`) denies the 4th; `route_id` null or blank with `path_selected: large` denies the 4th.
  - Throwing reader, malformed, non-object, and empty checkpoint text yield direct mode with no non-zero exit.
  - Unreadable envelope (Claude) or malformed JSON (Codex) still denies under a large route.
  - Default checkpoint path is `<root>/artifacts/orchestration/orchestrator-state.json`; non-`.py` paths do not invoke the reader.
  - Test paths allowed and not recorded in both modes, for both D2 rules.
  - Legacy state with `prodCap`, `testCap`, `testFiles` loads and does not change the threshold.
  - Claude: `CLAUDE_PYTHON_BUDGET_PROD`/`_TEST` set in scope does not change the threshold, with the prior value restored in `AfterEach`.
  - Codex: `Invoke-PythonBatchBudgetCodexEntryPoint` allow, deny, and exit-2 cases through `HookSeams`.
- Parity suite: byte identity of the two helper copies; route predicate table run once per copy.
- Re-run unchanged: `PreToolUseSchema.Contract.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_orchestrator_direct_command_contracts.py`, `test_generate_codex_agent_variants.py`, and the TypeScript twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- Coverage: line coverage >= 85% for each changed hook and each helper copy; no regression on changed lines. The MCP PoshQC runner reads the installed extension's runsettings, so per-file coverage for the new helper files is obtained from a direct Pester run and recorded under `<FEATURE>/evidence/qa-gates/`.
- Toolchain: PoshQC format -> analyze -> test; Pytest for the parity suites.
- Manual validation: none required beyond running the suites in the session worktree.

## Acceptance Criteria

- [x] AC-1: In direct mode (no checkpoint, or a checkpoint whose selected route is `small`), the Claude Python hook allows the first three distinct production Python paths and denies the 4th; the deny reason begins `PYTHON_LARGE_PATH_REQUIRED` and names `/orchestrate`.
- [x] AC-2: In direct mode, the Codex Python hook allows the first three distinct production Python paths and denies the 4th; the deny reason begins `PYTHON_LARGE_PATH_REQUIRED` and names `.codex/prompts/orchestrate-work.md`.
- [x] AC-3: Neither Python hook's deny reason contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_PYTHON_BUDGET`, `record an approved cap`, `deleting`, `python-batch-budget.`, or the state-file path; asserted by unit tests for both hooks.
- [x] AC-4: With a non-terminal checkpoint whose selected route is `large`, `remediation`, or `preparation`, neither Python hook denies any Python path for file count at any number of distinct production files, and neither hook reads state, writes state, or creates the state directory for those paths.
- [x] AC-5: Route precedence is `route_id` when the key is present and `path_selected` only when `route_id` is absent; a present-but-null or blank `route_id` with `path_selected: large` yields direct-mode enforcement in both Python hooks.
- [x] AC-6: A missing checkpoint, a throwing reader, a malformed or non-object checkpoint, a blank or unknown route, a checkpoint with `next_step: "complete"`, and a checkpoint with `S12_complete` in `completed_steps` each yield direct-mode enforcement in both Python hooks, and no checkpoint condition causes a non-zero hook exit.
- [x] AC-7: Test Python paths matching the unchanged classification rule (`tests/**/*.py` and `test_*.py`) are never denied for count and are not recorded in state, in either mode, in both Python hooks.
- [x] AC-8: `CLAUDE_PYTHON_BUDGET_PROD`/`_TEST` and persisted `prodCap`/`testCap` no longer change the threshold; a legacy state file containing `prodCap`, `testCap`, and `testFiles` loads without error in both Python hooks; a search for `CLAUDE_PYTHON_BUDGET` in both Python hooks and their bundle copies returns no match.
- [x] AC-9: Existing behaviors hold in both Python hooks: fail-closed deny on an unreadable envelope (Claude) or malformed JSON (Codex), including under a large route; allow on missing `file_path` or non-`.py` path without invoking the checkpoint reader; out-of-root discard without a state write (Claude); repeated-path allow without a state write; deny-only output with `state` stripped; and the `Get-PythonBatchBudgetBlockDecision` deny shape (`PreToolUseSchema.Contract.Tests.ps1` passes).
- [x] AC-10: The Codex Python hook contains no `$env:CLAUDE_` read, exposes `Invoke-PythonBatchBudgetCodexEntryPoint` exercised in-process through seams, and still requires `session_id` (`legacy-codex-hook-contracts.Tests.ps1` and `codex-pretooluse-transport.Tests.ps1` pass).
- [x] AC-11: The checkpoint is supplied to both Python hooks through an injectable `ReadCheckpoint` seam; no new or modified test creates a temporary file; and no new or modified Python-hook test depends on the live `artifacts/orchestration/orchestrator-state.json` (the Python row of the shared Codex Context injects an empty checkpoint).
- [x] AC-12: `.claude/hooks/enforce-batch-budget-route.ps1` and `.codex/hooks/enforce-batch-budget-route.ps1` exist, define `ConvertFrom-BatchBudgetCheckpoint`, `Get-BatchBudgetSelectedRoute`, and `Test-BatchBudgetLargePathRoute`, and are byte-identical; `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`, and `.codex/hooks/enforce-python-batch-budget.ps1` each dot-source their runtime's helper.
- [x] AC-13: A search for `PowerShellBatchBudgetCheckpoint`, `PowerShellBatchBudgetSelectedRoute`, and `PowerShellBatchBudgetLargePathRoute` returns no match under `.claude/hooks/`, `.codex/hooks/`, `tests/scripts/`, or their bundle mirrors under `extensions/drm-copilot/resources/` (no inline or PowerShell-named copy of the route helper remains).
- [x] AC-14: `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1` exists, asserts the Claude and Codex helper copies are byte-identical, runs the route predicate table against each copy, and passes.
- [x] AC-15: `.claude/hooks/enforce-powershell-batch-budget-route.ps1` and its bundle copy no longer exist; the Claude helper is listed in `claude-customizations/pack-manifests/core.json` and a search for `enforce-powershell-batch-budget-route` in `claude-customizations/pack-manifests/powershell.json` returns no match; the Codex helper is listed in `codex-and-agents-customizations/pack-manifests/core.json` and in `$script:SharedModuleNames`; both `pester.runsettings.psd1` copies list both new helper paths and do not list the old path.
- [x] AC-16: No PowerShell regression: `enforce-powershell-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget-routing.Tests.ps1`, `codex-powershell-batch-budget-routing.Tests.ps1`, and the PowerShell row of `codex-batch-budget-hooks.Tests.ps1` pass after the switch to the shared helper, and the diff of the two #769 routing suites relative to `main` consists only of the helper function-name renames.
- [x] AC-17: New suites `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` and `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` exist and pass, and the updated `enforce-python-batch-budget.Tests.ps1`, `codex-batch-budget-hooks.Tests.ps1`, and `legacy-codex-hook-contracts.Tests.ps1` pass.
- [x] AC-18: A case-insensitive search for `per-batch`, `per batch`, `batch cap`, `smaller batches`, `split the work`, `new batch`, `three-test`, `in-flight batch`, `budget: prod=`, `budget override`, and `seek an override` returns no match in files whose path contains `python` under `.claude/`, `.agents/`, `.codex/`, `.github/agents/`, `.github/skills/`, or `.github/prompts/`, or in their bundle mirrors under `extensions/drm-copilot/resources/`, excluding `.github/agents/python-execution-only-typed.agent.md` and its mirror.
- [x] AC-19: Python routing text in `python-change-budget-router` (both copies), `invoke-python-engineer` (both copies), `.claude/agents/python-typed-engineer.md`, `.codex/agents/python-typed-engineer.toml`, and `.github/agents/python-typed-engineer.agent.md` states `1-3` production files for the small/direct path and more than 3 for the large path, states that the large path has no production-file cap, and states that test files are not counted toward the routing threshold.
- [x] AC-20: A case-insensitive regex search for ``>\s*`?3`?\s*test`` and for `1-3 test Python files` returns no match in `.github/agents/python-orchestrator.agent.md`, `.github/prompts/orchestrate-python-work.prompt.md`, `.codex/agents/python-orchestrator.toml`, or their bundle mirrors, and the path-selection rules in those files route on production-file count only.
- [x] AC-21: Routing instructions in `.claude/skills/python-change-budget-router/SKILL.md`, `.claude/skills/invoke-python-engineer/SKILL.md`, and `.claude/agents/python-typed-engineer.md` name `/orchestrate` and do not name `python-orchestrator`; the `.agents` router and invoke-skill copies and `.codex/agents/python-typed-engineer.toml` name `.codex/prompts/orchestrate-work.md`; `.github/agents/python-typed-engineer.agent.md` names `python-orchestrator`.
- [x] AC-22: Neither `invoke-python-engineer` copy nor `.agents/skills/invoke-powershell-engineer/SKILL.md` (nor their bundle mirrors) offers the `budget: prod=<N>, test=<M>` input, and neither `python-change-budget-router` copy contains a `Per-Batch Change Budget` or `Scope Expansion Protocol` section.
- [x] AC-23: Every generated variant of `.codex/agents/python-typed-engineer.toml` is regenerated with `scripts/dev_tools/generate_codex_agent_variants.py`, and `test_generate_codex_agent_variants.py` passes.
- [x] AC-24: Bundle parity and manifest completeness pass: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, `test_orchestrator_direct_command_contracts.py`, and the byte-identity and core-manifest checks in `legacy-codex-hook-contracts.Tests.ps1`; every changed `.github` file is identical to its copy under `extensions/drm-copilot/resources/customizations/.github/`.
- [x] AC-25: `.github/copilot-instructions.md`, `.github/instructions/*`, `.github/agents/python-execution-only-typed.agent.md`, `scripts/dev_tools/resolve_codex_topology.py`, and `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` are unchanged on the branch relative to `main`, and no `.py` file is modified.
- [x] AC-26: No production or test file created or modified by this item exceeds 500 lines, and the 500-line checks in `legacy-codex-hook-contracts.Tests.ps1` and `codex-epic-runtime-contracts.Tests.ps1` pass.
- [x] AC-27: PoshQC format -> analyze -> test passes with zero analyzer findings; line coverage is >= 85% for each changed hook and each helper copy (helper figures from a direct Pester run recorded under `<FEATURE>/evidence/qa-gates/`); and there is no coverage regression on changed lines.
- [x] AC-28: Both Python hook docstrings describe the routing model and document the stale-checkpoint limitation with the #673 hygiene mitigation, and contain no per-batch, cap-override, or state-file-deletion guidance.
- [x] AC-29: Potential entries under `docs/features/potential/` are recorded for the `python-execution-only-typed` 30/30 cap (owner decision) and for the language-generic orchestrator test-file routing clause in `.github/agents/orchestrator.agent.md` and `.github/prompts/orchestrate-work.prompt.md`.

## Risks & Mitigations

- Technical or operational risks:
  - Stale large-path checkpoint exempts a later direct-mode session (accepted; documented).
  - The helper rename could leave the live Claude PowerShell hook without a loadable helper mid-execution.
  - The Codex Python row of the shared Context reads the live checkpoint if the empty seam is omitted, producing a false failure.
  - New helper files are absent from the MCP runner's coverage artifact until the extension is rebuilt.
  - Codex Python hook grows toward 500 lines with the entry-point function.
- Mitigations and rollbacks:
  - Checkpoint hygiene (#673); terminal-checkpoint exclusion; fail-safe to direct mode.
  - Stepwise rename ordering (research Section 8).
  - Empty `ReadCheckpoint` seam on the Python row (AC-11).
  - Direct Pester run for helper coverage (AC-27).
  - Inline helpers are removed from the Codex hook (they live in the shared helper); line counts measured by the executor (AC-26).
  - Rollback by revert.

## Rollout & Follow-up

- Release/rollout steps: merge to `main`; isolated subagents pick up the change only after merge; extension consumers receive it with the next extension release.
- Post-fix monitoring or clean-up tasks: the follow-up entries in AC-29; owner decision on `python-execution-only-typed`.
- Links: Issue #773 (https://github.com/drmoisan/drm-copilot/issues/773); #769 and PR #772; #673 (checkpoint hygiene); research record in the header.
