# Research: validate-orchestrator-output resolves the run checkpoint (#787) and runs the Layer 2 wave-barrier port (#840)

- Feature folder: `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787`
- Epic: #852 (enforcement-hook-precision), child C6, wave 1 (0-indexed), depends on C2 (#565)
- Branch: `bug/validate-orchestrator-output-session-relative-read-787` (from `origin/epic/enforcement-hook-precision-integration`)
- Mode: preparation research only. No production, test, or documentation file was changed.
- Evidence basis: every file:line citation below was read with the Read or Grep tool against this worktree on 2026-10-08. Two external facts were read from vendor documentation with WebFetch and are labelled as such.

## Key findings

1. The hook invokes no Python today. The `orchestrator-state` leg calls the PowerShell `Test-OrchestratorStateCompletionReadiness` (`.claude/hooks/validate-orchestrator-output.ps1:254-266`); the interpreter leg was removed by #475 (`:204-209`), and an AST test pins its absence (`tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1:468-488`). The #787 change has no Python path to preserve.
2. The checkpoint path is used as a process-relative literal at five sites, and each one flows from `-CheckpointPath` (`:32`, `:319`, `:344`, `:390`, `:415`). It reaches two further reads through the dispatch: `OrchestratorState.psm1:156,164` (structural leg) and the completion module (orchestrator-state leg). The `runbook_path` existence check in `Test-HumanInteractionShape` (`:101,143`) is also process-relative.
3. The hook is at 421 lines (Grep `^` count). The resolution glue and the Layer 2 port cannot both go inline without coming close to the 500-line cap. `WorktreeRunResolution.psm1` is at 497 lines, so it cannot grow, and C6 has no reason to edit it.
4. **Runtime caveat (verified from code and vendor documentation; not observed in a live run).** The hook reads `$env:CLAUDE_HOOK_INPUT` (`:415`) and the `output` field (`:336-339`), and blocks with `exit 1` (`:416-419`). The Claude Code hooks reference (code.claude.com/docs/en/hooks, fetched 2026-10-08) states three things: SubagentStop input arrives on stdin; the payload carries `last_assistant_message`; and only exit 2 blocks a SubagentStop. It documents no `CLAUDE_HOOK_INPUT` variable, and any exit code other than 0 or 2 is non-blocking. The same defect class is recorded, unpromoted, in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md:12,39`. As a result, the hook's #787 and #840 decisions will probably have no runtime effect until that entry is delivered. This research recommends keeping transport and exit code out of C6 scope (they are not in the epic Scope for C6, `epic.md:116-120`) and recording the dependency explicitly.
5. The Python Layer 2 check is `validate_wave_barrier_ordering` in `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py:78-163`. Its start guard is `feature_has_started` (`:37-75`), and it resolves references through the union index in `_epic_orchestrator_state_resolution.py:47-149`. A shared fixture already exists, `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` (14 cases). The Python lane (`tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py`) and the TypeScript lane (`extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts:38-40,159`) both consume it. A Pester lane over the same directory is the natural parity proof.
6. Exact parity requires parsing with `System.Text.Json`, not `ConvertFrom-Json`. `ConvertFrom-Json` coerces ISO-8601 strings to `DateTime` (`OrchestratorState.psm1:138-145`), which breaks the `isinstance(..., str)` timestamp checks and the string comparison. It also gives case-insensitive property access, where Python lookups are case-sensitive. The repository already has a production precedent: `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1:23-26,103-146`. `JsonElement.TryGetProperty` is ordinal, case-sensitive, and last-definition-wins (Microsoft Learn, fetched 2026-10-08), which matches Python `json` semantics for duplicate keys.
7. Layer 1 (`enforce-epic-wave-barrier.ps1:185-237`) compares `feature_folder` only and does not consult `issue_num`. Its rules differ from Layer 2 (no start guard, no timing check, fail-closed on a missing dependency record). Sharing code between the layers is not recommended in C6; see section 3.6.

## 1. `validate-orchestrator-output.ps1`: current state

### 1.1 Structure (421 lines)

| Lines | Element | Role |
|---|---|---|
| 1-27 | Comment help | States the hook reads `artifacts/orchestration/orchestrator-state.json` and the payload from `CLAUDE_HOOK_INPUT`. |
| 29-36 | `param` | `-CheckpointPath` (default `'artifacts/orchestration/orchestrator-state.json'`), `-ArtifactType` (default `'orchestrator-state'`). |
| 38-41 | Script prologue | `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, and an unguarded `Import-Module ../lib/orchestrator-state/OrchestratorState.psm1 -Force`. Import guarding belongs to C4 (#786), `epic.md:121-125`. |
| 43-66 | `Get-CheckpointFileContent -Path` | Filesystem read seam (`Test-Path` then `Get-Content -Raw`). Tests mock it. |
| 68-150 | `Test-HumanInteractionShape` | Validates `human_interaction`. `FileExistsCheck` seam defaults to a process-relative `Test-Path` (`:101`), used at `:143`. |
| 152-196 | `Test-OrchestratorCheckpointStructure -CheckpointPath` | PD-3 structural leg for epic and parallel types. Calls `Get-OrchestratorStateCheckpoint` (`:190`). |
| 198-304 | `Invoke-RoutingContractValidation -CheckpointPath -ArtifactType -Invoker` | Dispatch on `ArtifactType` (`:253-284`). The exit code is the sole discriminator (`:298-303`). |
| 306-408 | `Invoke-OrchestratorOutputValidation -RawPayload -CheckpointPath -ArtifactType -RoutingInvoker` | Payload parse (`:326-342`), checkpoint read (`:344-357`), required fields `objective, completed_steps, next_step, last_updated` (`:359-375`), human interaction (`:377-384`), routing dispatch (`:390-405`). Block tokens are `MODEL_ROUTING_BLOCKED:` (`:401-402`) and `ROUTING_CONTRACT_BLOCKED:` (`:404`). |
| 410-413 | Dot-source guard | Lets tests dot-source the file. |
| 415-421 | Entry point | Reads `$env:CLAUDE_HOOK_INPUT`, then `Write-Error` + `exit 1` on block, `exit 0` on pass. |

### 1.2 Every checkpoint-path composition or read

| Site | Use |
|---|---|
| `:32` | Script parameter default (relative literal). |
| `:319` | Function parameter default (same literal). |
| `:344` | `Get-CheckpointFileContent -Path $CheckpointPath`: process-relative `Test-Path` and `Get-Content` (`:60,64`). |
| `:346,350,356,370,374` | The path is echoed into block messages. |
| `:390` → `:288` → `:261` | Path passed to `Test-OrchestratorStateCompletionReadiness -CheckpointPath $Path` (orchestrator-state leg). |
| `:390` → `:288` → `:270` → `:190` | Path passed to `Get-OrchestratorStateCheckpoint`, which reads with `Test-Path`/`Get-Content` at `OrchestratorState.psm1:156,164`. |
| `:415` | Entry point passes the script parameter. |
| `:101,143` (related) | `runbook_path` existence via a process-relative `Test-Path`. Not a checkpoint read, but it is the same session-relative class. |

The orchestrator-state lib contains no other filesystem read: Grep for `Test-Path|Get-Content|ReadAllText` over `.claude/lib/orchestrator-state` matched only `OrchestratorState.psm1:156,164`.

### 1.3 ArtifactType branches

- `orchestrator-state`: imports `OrchestratorStateCompletion.psm1` only when `Test-OrchestratorStateCompletionReadiness` is not already loaded (`:255-260`), and returns its `ExitCode`/`Output` (`:261-265`).
- `epic-orchestrator-state`, `parallel-orchestrator-state`: `Test-OrchestratorCheckpointStructure` only, covering exists, parses, and object root (`:267-275`). This is where #840 says the Layer 2 check is missing.
- Any other value fails closed and names the type (`:276-283`).

The required-fields block (`:359-375`) applies to every type. The epic checkpoint carries those four keys (`scripts/dev_tools/validate_epic_orchestrator_state.py:39-44`, `.claude/agents/epic-orchestrator.md:131-139`).

### 1.4 Python usage

None. `:204-209` documents removal of the interpreter subprocess (#475), and `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1:468-488` asserts that no `python`, `python3`, `py`, or `poetry` command appears in the invoker AST. `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:40-41` scans `.claude/hooks` and `.claude/lib`, so any new module is covered by that guard automatically.

### 1.5 Registrations (SubagentStop)

| Registration | Arguments |
|---|---|
| `.claude/settings.json:260-268` matcher `orchestrator` | none (defaults) |
| `.claude/settings.json:269-277` matcher `epic-orchestrator` | `-CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state` |
| `.claude/settings.json:278-286` matcher `parallel-orchestrator` | `-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state` |
| `.claude/agents/orchestrator.md:42` (frontmatter) | none |
| `.claude/agents/epic-orchestrator.md:24-29` (frontmatter) | epic arguments as above |
| `.claude/agents/parallel-orchestrator.md:42` (frontmatter) | parallel arguments as above |
| Bundled mirrors | Same lines under `extensions/drm-copilot/resources/claude-customizations/.claude/{settings.json,agents/*.md}` |
| `.codex/` | No registration and no copy of this hook. The Codex SubagentStop entries are `validate-codex-subagent-routing.ps1` and `validate-feature-review-coverage.ps1` (`.codex/config.toml:236-252`). |

Matcher semantics (vendor documentation, fetched 2026-10-08): a matcher made only of letters, digits, `_`, `-`, spaces, `,`, and `|` is an exact match. So `orchestrator` does not fire for `epic-orchestrator` or `parallel-orchestrator`. Whether the settings registration and the frontmatter registration both run for one stop, or are deduplicated, was not verified.

### 1.6 Payload and identity available at SubagentStop

- Documented payload fields (vendor documentation): `session_id`, `prompt_id`, `transcript_path`, `cwd`, `hook_event_name`, `permission_mode`, `agent_type`, `agent_id`, `last_assistant_message`, `stop_reason`. Input is on stdin. Hooks run in the session `cwd`, falling back to the session start directory or project root when that directory is gone.
- What the hook actually reads: `$env:CLAUDE_HOOK_INPUT` and `.output` (`:336-339,415`). Under the documented contract the variable is unset, so the hook returns `CLAUDE_HOOK_INPUT is empty` and exits 1, which is non-blocking. This is inference from code plus documentation; the potential entry records it as "expected, not yet measured" (`2026-08-21-subagentstop-validators-read-undocumented-envelope.md:37`).
- Process location: `/epic-run` is `context: fork` with `agent: epic-orchestrator` (`.claude/skills/epic-run/SKILL.md:5-6`), so the epic orchestrator runs in the invoking session's process, and the hook's location is the session root. For `isolation: "worktree"` children, hooks run inside the child worktree with that checkout's scripts (#690 research section 5, `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/research/2026-09-29T21-55-agent-payload-gates-session-root-research.md:138`).
- No payload field carries the integration branch or parallel slug. The settled #690 design forbids the payload `cwd` as a target selector (`...-690.../research...md:10`; `enforce-epic-wave-barrier.ps1:80-81`).

## 2. `WorktreeRunResolution.psm1` contract and identity at SubagentStop

### 2.1 Exports (`WorktreeRunResolution.psm1:490-497`)

| Function | Signature | Returns / failure modes |
|---|---|---|
| `Find-WorktreeRunIdentitySignal` (`:75-97`) | `-Text` | Pure. Returns `{IntegrationBranch, EpicSlug, ParallelSlug}`, each the single distinct value of `integration_branch:`, `epic_feature_folder:`, or `parallel_slug:` (case-sensitive, `:47-49`). It returns `$null` for none and for more than one distinct value (`:71-72`). |
| `Get-WorktreeRunCheckpointText` (`:99-119`) | `-Path` | The module's only filesystem read and the mocked seam. Returns `$null` when the file is absent or unreadable; an unreadable file also writes `WORKTREE_RUN_CHECKPOINT_UNREADABLE` to stderr. |
| `Get-WorktreeRunCheckpointPath` (`:121-143`) | `-Kind epic\|parallel\|item -WorktreeRoot` | Absolute path beneath the root. `item` delegates to `Get-WorktreeItemCheckpointPath`. Throws on a relative root. |
| `Resolve-WorktreeEpicTarget` (`:236-308`) | `-IntegrationBranch [-EpicSlug] -SessionRoot` | A blank branch gives `NoTarget`. Otherwise it keeps live roots whose epic checkpoint has `route_id -ceq 'epic'` and a matching `integration_branch`. A disagreeing slug gives `Ambiguous`. 0 matches gives `NoTarget`, 1 resolves, and several are narrowed by branch checkout; anything other than one survivor is `Ambiguous`. |
| `Resolve-WorktreeParallelTarget` (`:310-340`) | `-ParallelSlug -SessionRoot` | Blank gives `NoTarget`. 0, 1, or many matches give `NoTarget`, resolved, or `Ambiguous` (no tie-break). |
| `Resolve-WorktreeRunTargetByRecord` (`:405-448`) | `-Kind -RecordField pr_number\|worktree_path -Value -SessionRoot` | Record match, with the same 0/1/many rule. |
| `Resolve-WorktreeOperandTarget` (`:450-488`) | `-Path -SessionRoot` | A blank operand resolves to the session worktree (`:472-475`). Always returns a resolved result. |

Result shape (single constructor `New-WorktreeResolutionTargetResult`, `WorktreeTargetResolution.psm1:66-135`): `Status` (`SessionRoot | OtherWorktree | NoTarget | Ambiguous`), `WorktreeRoot` (resolved states only), `SessionRoot`, `Signal`, `SignalValue`, `Candidates`, `ReasonCode`, and `Detail`. `ReasonCode` is `TARGET_WORKTREE_AMBIGUOUS` for Ambiguous and `TARGET_WORKTREE_NOT_DERIVABLE` for NoTarget (`WorktreeResolution.psm1:55,59`), exposed through `Get-WorktreeResolutionAmbiguityReasonCode` and `Get-WorktreeResolutionNoTargetReasonCode` (`:463-487`). The resolved/unresolved label comes from `ConvertTo-WorktreeItemResolvedResult` (`WorktreeItemResolution.psm1:216-256`).

Injectable seams used by tests: `Get-WorktreeItemLiveRoot` (`WorktreeItemResolution.psm1:179-214`) and `Get-WorktreeRunCheckpointText`, both mocked with `-ModuleName WorktreeRunResolution`. See `tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1:47-64`, which uses synthetic `/synthetic-worktrees/<name>` roots and closures. `New-WorktreeResolutionFixtureTarget` in `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1` (114 lines) builds seam-level targets (`...WorktreeResolution.Tests.ps1:67-72`).

### 2.2 Consumers (#690 era)

| Consumer | Call | Test |
|---|---|---|
| `enforce-epic-wave-barrier.ps1:75-93,309-313` | `Resolve-WorktreeEpicTarget` from the prompt signal. Denies `NoTarget`/`Ambiguous` as `EPIC_WAVE_BARRIER_BLOCKED: <ReasonCode>: <Detail>`. | `enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1` W1-W9 (`:75-205`), including the two-worktree row W1 and the stale-copy tie-break W6 |
| `enforce-parallel-cohort-barrier.ps1:110`, `enforce-parallel-drift-gate.ps1:133` | `Resolve-WorktreeParallelTarget` | Their `*.Tests.ps1` suites (#690 research section 7) |
| `enforce-epic-merge-gate-resolution.ps1:117-129,149` | `Resolve-WorktreeOperandTarget -Path ''` for the session worktree (the bare-command case); `Resolve-WorktreeRunTargetByRecord` for an explicit PR | `enforce-epic-merge-gate*.Tests.ps1` |
| `EpicScopeResolution.psm1:353` | `Resolve-WorktreeEpicTarget` from a branch candidate | `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1` |

### 2.3 C3 overlap

C3 owns the #789 corrections: the UNC case comparison in the private `Test-WorktreeRunPathEqual` (`:344-358`) and the doubled deny token (`epic.md:109-115,172-173`). C6 should consume only `Find-WorktreeRunIdentitySignal`, `Get-WorktreeRunCheckpointText`, `Get-WorktreeRunCheckpointPath`, `Resolve-WorktreeEpicTarget`, `Resolve-WorktreeParallelTarget`, and `Resolve-WorktreeOperandTarget`, plus `Get-WorktreeItemLiveRoot` from `WorktreeItemResolution.psm1`. None of these reaches `Test-WorktreeRunPathEqual`, which is called only from `Test-WorktreeRunCheckpointRecord` (`:400`), the `RunTargetByRecord` path. C6 needs no edit to the module, and the module has 3 lines of headroom in any case.

### 2.4 Recommended identity and resolution per artifact type

| ArtifactType | Kind | Resolution |
|---|---|---|
| `orchestrator-state` | item | `Resolve-WorktreeOperandTarget -Path '' -SessionRoot (Get-Location).Path`, then `Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot <root>`. This follows the merge-gate bare-form precedent (`enforce-epic-merge-gate-resolution.ps1:117-129`). The orchestrator's SubagentStop runs in the orchestrator's own process location, which is its own worktree for isolated children and the session root for forked runs. The change replaces a process-relative literal with an absolute path under the enclosing worktree root, and the decision is unchanged for the plain case. |
| `epic-orchestrator-state` | epic | Identity precedence: (1) `Find-WorktreeRunIdentitySignal` over the agent output text the hook already extracts; when `IntegrationBranch` is non-null, call `Resolve-WorktreeEpicTarget -IntegrationBranch -EpicSlug -SessionRoot`. (2) Otherwise, discovery: enumerate `Get-WorktreeItemLiveRoot`, read each root's epic checkpoint through `Get-WorktreeRunCheckpointText` and `Get-WorktreeRunCheckpointPath -Kind epic`, and collect distinct `integration_branch` values from checkpoints with `route_id -ceq 'epic'`. Exactly one distinct value goes to `Resolve-WorktreeEpicTarget` with that value, which applies the branch-checkout tie-break for stale copies. Zero gives `NoTarget`, and more than one gives `Ambiguous`. |
| `parallel-orchestrator-state` | parallel | Same precedence with `ParallelSlug` and `Resolve-WorktreeParallelTarget`; discovery collects distinct `parallel_slug` from `route_id -ceq 'parallel'` checkpoints. |

- An unresolved or ambiguous target produces a named block that leads with a new token (for example `ORCHESTRATOR_OUTPUT_TARGET_UNRESOLVED: <ReasonCode>: <Detail>`) and never reads the session-root copy.
- Resolution runs after the payload checks (`:326-342`) and before `Get-CheckpointFileContent`, following the #690 placement rule "after the scope filter and before the read" (`...-690.../research...md:17`).
- `-CheckpointPath` stays as a parameter for compatibility with the six registrations. Recommended: treat a bound value as a cross-check that must equal the canonical relative path for the kind, and fail closed on a mismatch. This mirrors the prompt-declared `epic_checkpoint_path` cross-check (`enforce-orchestration-preimplementation-gate-modes.ps1:9-16,282`).
- Resolve a relative `runbook_path` against the resolved root through the existing `FileExistsCheck` seam (`:101`), so the same hook does not keep one session-relative read. Planner decision; it is small and uses an existing seam.
- Self-selection note: under (1) the agent's own output names the branch. Resolution still requires a live checkpoint that records that branch, and `EpicSlug` is cross-checked, so the agent can select only an existing epic run. The discovery path (2) has no agent input at all.

## 3. Python Layer 2 check and the PowerShell port

### 3.1 Location and call order

`validate_epic_orchestrator_state_text` (`scripts/dev_tools/validate_epic_orchestrator_state.py:341-428`) does the following in order:
1. Parse; a JSON error or non-object root returns early (`:372-378`).
2. `_extract_features` keeps only `dict` entries of a list-valued `features`; it returns `[]` when `features` is not a list (`:129-152,385`).
3. Feeds those features to `validate_wave_barrier_ordering` (`:391`), imported from `_epic_orchestrator_state_wave_barrier.py:29-32`.

Layer 2 reads no `waves[]` field. `_validate_waves_consistency` (`:246-295`) is a separate check, not part of the port.

### 3.2 Exact algorithm (`_epic_orchestrator_state_wave_barrier.py`)

Inputs per feature: `feature_folder`, `depends_on`, `merge_status`, `worktree_created_at`, `merge_confirmed_at`, `issue_num`.

1. `by_folder`: map of `feature_folder` to feature, over features whose `feature_folder` is a `str` (empty string included). A later duplicate overwrites an earlier one (`:108-112`).
2. Union index (`_epic_orchestrator_state_resolution.py:74-109`), built over non-empty `str` folders only:
   - `by_folder_hint[normalize(folder)] = folder`.
   - `by_issue_num[issue_num] = folder` when `issue_num is not None`.
   - Normalization strips the first matching prefix of `docs/features/active/`, `docs/features/completed/`, `active/`, `completed/`, in that order (`:37-42,47-71`). A later duplicate overwrites.
3. For each feature, in order:
   - Skip unless `feature_folder` is a `str` and `depends_on` is a `list` (`:119-122`).
   - Start guard `feature_has_started` (`:73-75`): started when `worktree_created_at` is a `str` (including `""`), or when `merge_status != "not_started"` (an absent key, `None`, an int, or any other value counts as started). Skip when not started.
4. For each dependency, in `depends_on` order, resolve (`_epic_orchestrator_state_resolution.py:141-149`):
   - A non-`str` dependency is looked up in `by_issue_num` using Python dict equality: `1 == 1.0 == True` share a hash. An unhashable dependency (list or dict) gives `None`.
   - A `str` dependency is looked up in `by_folder_hint[normalize(dep)]` and never consults `issue_num`.
   - An unresolved dependency, or a resolved key missing from `by_folder`, is skipped silently (`:132-139`).
5. Status violation: the dependency's `merge_status` is not a `str`, or is not in `{"merged", "worktree_removed"}`. The comparison is case-sensitive (`:34,144-147`).
6. Timing violation: both `merge_confirmed_at` (dependency) and `worktree_created_at` (dependent) are `str`, and `merge_confirmed_at > worktree_created_at` under Python string ordering, which is code-point ordinal (`:148-152`).
7. At most one error per edge. The status error takes precedence (`:153-162`):
   - `EPIC_WAVE_BARRIER_VIOLATION: {folder} is treated as started while dependency {dependency} is not merged`
   - `EPIC_WAVE_BARRIER_VIOLATION: {folder} worktree_created_at precedes dependency {dependency} merge_confirmed_at`

   `{dependency}` is Python `str()` of the raw reference, not the resolved folder: `901` for an int, `True` for a bool, `901.0` for a float, and the raw text for a string.

Python crash path (outside parity): an unhashable `issue_num` (list or object) raises `TypeError` at `by_issue_num[issue_num] = folder` (`_epic_orchestrator_state_resolution.py:108`). The exception is not caught by `validate_epic_orchestrator_state_text`.

### 3.3 Existing tests

- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py`:
  - The 14 fixture cases through the public entry point, filtered by the `EPIC_WAVE_BARRIER_VIOLATION: ` prefix (`:63-103`). `EXPECTED_CASE_COUNT = 14` is asserted for that file only (`:40,77-87`).
  - The `feature_has_started` matrix (8 params, `:106-142`).
  - The unhashable dependency status (`:145-170`).
  - Malformed or unresolved entries skipped (`:173-196`).
- `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` also asserts barrier strings (Grep count 3).
- TypeScript lane: `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts` reads the same fixture and asserts length 14 (`:159`). The TypeScript implementation is `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts:248-325`.
- Fixture schema (`start-guard-matrix.json:1-14`): `schema_version`, an `envelope` (the checkpoint minus `features`), and `cases[]`, each with `name`, `acceptance_criteria`, `notes`, `features`, and `expected_barrier_errors`.

### 3.4 Parity traps for a PowerShell port

| Trap | Python behavior | Required port behavior |
|---|---|---|
| Date coercion | Timestamps stay `str` | Parse with `System.Text.Json` (`JsonDocument.Parse`) and test `ValueKind -eq String`. Do not use `ConvertFrom-Json` (`OrchestratorState.psm1:138-145`). |
| Key case | `merge_status` lookup is case-sensitive | `JsonElement.TryGetProperty` (ordinal; last duplicate wins). PSCustomObject property access is case-insensitive. |
| String order | Code-point ordinal `>` | `[string]::CompareOrdinal(a, b) -gt 0`. PowerShell `-gt` on strings is culture-aware and case-insensitive. Astral characters differ between UTF-16 ordinal and code-point order; the TypeScript port already shares the UTF-16 behavior (`epic-orchestrator-state-core.ts:316`). Declare this as a divergence. |
| Numeric and bool reference equality | `True == 1`, `901 == 901.0`; `"901" != 901` | Canonical key: bool maps to 0/1; an integral number maps to its integer value (`BigInteger` parse of the raw token); a string `issue_num` is never matched by a non-string reference. |
| Reference rendering | `str(dep)` | String: raw text. Bool: `True`/`False` (PowerShell `[string]$true` gives `True`). Integer token: `BigInteger.Parse(raw).ToString()` (normalizes `-0` to `0`, as Python does). Non-integer tokens (`901.0`, `9.01e2`): declare as a divergence; Python renders `901.0`. |
| Empty folder | `""` dependent is iterated; `""` dependency never resolves | Same. |
| Duplicate folders | Last wins in both maps | Same, through ordinal hashtables. |
| Non-dict feature entries | Filtered before indexing | Same. |
| `features` not a list or absent | `[]` | Same. |
| Unhashable `issue_num` | `TypeError` (crash) | Out of parity scope. Fail closed with a distinct non-barrier message; declare as a divergence. |
| `NaN`/`Infinity` literals, nesting depth over 64 | `json.loads` accepts them | `JsonDocument.Parse` throws. Fail closed; declare as a divergence. |

### 3.5 Candidate parity fixture set

Add one new committed file in the existing directory, for example `tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json`, with the same schema as `start-guard-matrix.json`. Keep `start-guard-matrix.json` unchanged so the Python (`:40`) and TypeScript (`:159`) count assertions stay valid.

The Pester lane iterates every `*.json` in the directory. A new Python lane asserts the new file through `validate_epic_orchestrator_state_text`, using the same prefix filter. The expected strings in the new file are verified by the Python lane itself: a wrong expectation fails that lane, so the file cannot drift from the authority.

Candidate cases (positive, negative, and edge). Expected outputs follow from section 3.2 and must be confirmed by the Python lane:

- issue_num reference, merged and confirmed before start: no error. issue_num reference confirmed after start: timing error rendering `901`.
- `docs/features/active/<folder>` and `completed/<folder>` dependency hints, unmerged: status error rendering the raw hint text.
- Unresolved string, unresolved int, string `"901"` against int `issue_num`, `null`, list, and object references: no error.
- Bool `true` reference with no `issue_num` 1: no error. Bool `true` reference with a feature whose `issue_num` is `1`: status error rendering `True`.
- `depends_on` as a string, or absent; a non-string dependent `feature_folder`; non-object entries mixed into `features`; `features` as an object; `features` absent: no error from the skipped entries.
- Dependency `merge_status` as a list, an int, or `"Merged"` (case variant): status error.
- Dependency carrying only `"Merge_Status": "merged"` (case-variant key): status error (key absent to Python).
- Equal timestamps: no error.
- Lowercase `t` confirmation (`2026-09-29t09-00`) against `2026-09-29T10-00`: timing error under ordinal comparison.
- ISO timestamps with an offset, where string order and chronological order disagree (dependency `2026-09-29T09:00:00-05:00`, dependent `2026-09-29T10:00:00Z`): no error, because the comparison is on strings.
- Plain ISO `Z` timestamps, confirmation later: timing error. This pins the DateTime-coercion trap.
- Non-string `merge_confirmed_at` (number or `null`): no timing error.
- Dependent with `worktree_created_at: ""` and `merge_status: "not_started"`: started. A merged dependency with a string confirmation then gives a timing error, because any non-empty string is greater than `""`.
- Self-dependency of a started feature: status error naming itself (the separate cycle error is filtered out by prefix).
- Duplicate `feature_folder` records where the later one is merged: no status error.
- Dependent `feature_folder: ""`, started, with an unmerged dependency: error text containing two spaces after the prefix.

Not expressible through the fixture: duplicate JSON keys within one object. The Python lane re-serializes with `json.dumps` (`test_validate_epic_orchestrator_state_wave_barrier.py:72-73`), which collapses them. Cover this in the PowerShell unit suite only.

Declared divergence classes, following the precedent in `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1:19-30`:
- non-integer numeric reference tokens;
- astral-plane string ordering;
- unhashable `issue_num`;
- non-standard JSON literals and nesting depth.

No numeric acceptance criterion is proposed here (case counts included), so no `## Numeric Derivation Evidence` section is provided. If the plan adds a fixture-count floor as an AC, it must derive that number under that section first.

### 3.6 Relation to Layer 1, and the home of the port

- Layer 1 (`enforce-epic-wave-barrier.ps1:144-237`) resolves dependencies by `[string]` folder equality using case-insensitive `-eq` (`:178,224`), has no start guard and no timing check, and denies a missing record (`:225-227`). With issue_num-keyed `depends_on` (the epic.md schema, `.claude/skills/epic-orchestrate/SKILL.md:47-64`), `Find-EpicWaveBarrierFeatureRecord -FeatureFolder '901'` finds no record and Layer 1 denies. This observation comes from reading the code and was not run. It belongs to C2's feature-lookup rewrite or a follow-up, not to C6.
- Recommendation: do not share code between the layers in C6. Their semantics differ by design (SKILL.md:238-254), and C2 is rewriting Layer 1 concurrently. C6 edits only the Layer 1 header comment.
- Home for the port: `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` (proposed name). It sits in an existing library folder of checkpoint validators, already classified T3 (`quality-tiers.yml:61-63`), so no new `quality-tiers.yml` entry is needed. A new `.claude/lib/<name>` folder would need one, because rule R4 and QT008 require it (`scripts/dev_tools/quality_tiers_contract.py:16,22,387`). The folder's manifest test enumerates every on-disk `*.psm1` (`tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1:80-90`), so its `ExpectedPaths` list (`:28-42`) must gain the module.
- Proposed public surface:
  - `Get-OrchestratorStateEpicWaveBarrierError -CheckpointText <string>` returns `string[]`. It parses with `System.Text.Json`, returns `@()` for a non-object root (the structural leg already blocks that), and throws or returns a distinct error for the declared fail-closed inputs.
  - Private helpers for normalization, index, resolution, start guard, and canonical numeric key.
  - Estimated size: 200-300 lines.

## 4. Upstream C2 (#565): current state of `enforce-epic-wave-barrier.ps1` (381 lines)

- Header lines 1-36. The resolution procedure is at `:10-24`, the Layer 2 claim to correct is at `:26-29` ("retrospective backstop (Layer 2) is the wave-barrier ordering invariant inside validate_epic_orchestrator_state_text, enforced separately at epic-orchestrator SubagentStop time"), and the #690 import-guard note is at `:31-35`.
- Prologue: `HookPayload.psm1` import (`:41`), guarded `WorktreeRunResolution.psm1` import (`:43-50`), constants (`:52-53`).
- Feature lookup that C2 rewrites: `Find-EpicWaveBarrierFeatureFolderFromPrompt` (`:95-142`, longest match at `:134-135`); `Find-EpicWaveBarrierFeatureRecord` (`:144-183`); call site `:315-318,330`. The #565 entry cites "line 99" (`docs/features/potential/promoted/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder.md:21,35`); #690 has since moved that code to `:134`.
- Plan task: after C2 merges into the integration branch, re-read lines 1-40 and the header of the merged file before the C6 header edit, re-locate the Layer 2 sentence by its text (not by line number), and re-confirm the mirror byte identity. C6 should not touch any function in this file.

## 5. Codex copies, bundled mirrors, and parity gates

| File in scope | Codex copy | Bundled mirror |
|---|---|---|
| `.claude/hooks/validate-orchestrator-output.ps1` | none | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` |
| New `.claude/hooks/validate-orchestrator-output-resolution.ps1` (if the glue goes in a dot-sourced sibling) | none | same path under the bundle; also add to `pack-manifests/core.json` (hooks are enumerated by `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:139-159`) |
| New `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` | none (no `.codex` hook imports `.claude/lib/orchestrator-state`) | same path under the bundle; add to `core.json` `paths` (current lib entries `core.json:135-147`) and to `OrchestratorState.Manifest.Tests.ps1:28-42` |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` (header only) | `.codex/hooks/enforce-epic-wave-barrier.ps1` is a separate implementation whose header (`:1-10`) makes no Layer 2 claim; no change | bundle mirror of the hook |
| `.claude/skills/epic-orchestrate/SKILL.md` (Layer 2 bullet `:244-254`) | `.agents/skills/epic-orchestrate/SKILL.md:104-109` ("the epic-state validator is the retrospective, authoritative backstop") is Codex surface and not in the #840 list; no change recommended | bundle mirror |
| `.claude/agents/epic-orchestrator.md` (`:122-127`) | `.codex/agents/epic-orchestrator.toml` has no SubagentStop or wave-barrier text (Grep); no change | bundle mirror |

Parity gates that must stay green:
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`: every distributable `.claude` file exists in the bundle with identical text.
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:139-159`.
- `OrchestratorState.Manifest.Tests.ps1:45-107`: membership plus SHA-256 mirror identity.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`: used by the #690 plan's CMD-PY-PARITY (`plan.2026-09-29T22-17.md:147`).

Other documents that describe this hook, not in the #840 list, to re-check for accuracy:
- `.claude/skills/parallel-orchestrate/SKILL.md:826`.
- `.claude/skills/orchestrate/SKILL.md:222`, which still says the hook "runs the validator with `--require-model-routing` alongside `--require-complete`", Python CLI wording that predates #475.

## 6. Test layout

| Suite | Lines | Seams |
|---|---|---|
| `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` | 490 | Dot-sources the hook (`:10-15`) and mocks `Get-CheckpointFileContent`. Rows `:361-414` assert the relative literal reaching the routing seam (`:385,412`); #787 changes that contract, so these rows must be rewritten. 10 lines of headroom, so move them to a new sibling instead of growing the file. |
| `...validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` | 316 | Mocks `Get-OrchestratorStateCheckpoint` and `Test-OrchestratorStateCompletionReadiness`. Uses read-only repository files as the missing and non-JSON fixtures (`:72-76`). Calls `Invoke-OrchestratorOutputValidation` with the parallel type (`:246-249`); needs a default resolution-seam mock. |
| `...validate-orchestrator-output.model-routing.Tests.ps1` | 146 | Same dot-source pattern. |
| `...validate-orchestrator-output.human-interaction.Tests.ps1` | 126 | Same. |
| `...enforce-epic-wave-barrier.Tests.ps1` | 261 | Mocks `Get-EpicWaveBarrierCheckpointContent`. |
| `...enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1` | 206 | Two-worktree reference pattern (section 2.1). |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | 107 | File-read only. |
| Python: `tests/scripts/dev_tools/test_validate_epic_orchestrator_state*.py` | n/a | Committed fixtures, no temporary files. |

Proposed new suites:
- `validate-orchestrator-output.WorktreeResolution.Tests.ps1`: two-worktree rows through `Get-WorktreeItemLiveRoot` and `Get-WorktreeRunCheckpointText` mocked in module scope `WorktreeRunResolution`, with `/synthetic-worktrees/` roots. Covers: epic resolved to `OtherWorktree` with the read at the other root; `NoTarget` and `Ambiguous` named blocks with the read seam invoked 0 times; stale session-root copy losing to the branch owner; payload-signal precedence over discovery; two distinct epics giving `Ambiguous`; parallel 0/1/many; item kind composing an absolute path under the session worktree; `-CheckpointPath` cross-check mismatch; and an import-failure row if the import is guarded.
- `OrchestratorStateEpicWaveBarrier.Tests.ps1`: unit rows for every branch, including the duplicate-key case.
- `OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1`: corpus lane over `tests/fixtures/epic_wave_barrier/*.json`. It builds each document as envelope plus case `features` with `System.Text.Json.Nodes.JsonNode`, so the lane itself introduces no DateTime coercion.
- A hook row proving the epic leg emits `EPIC_WAVE_BARRIER_VIOLATION` and that the parallel and orchestrator-state legs do not run Layer 2.
- `tests/scripts/dev_tools/test_epic_wave_barrier_parity_corpus.py` (proposed name): Python lane for the new fixture file.

Coverage population: `config/poshqc-coverage.json` lists `.claude/hooks` and `.claude/lib` as roots (`:3-9`), and the runsettings carry no path list (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27`, #527). New files therefore enter the population with no configuration edit. `config/poshqc-scan.json` scans `tests/scripts` (`:4`), so the new suites are discovered.

## 7. Toolchain

- PowerShell:
  - Format, analyze, and test through `mcp__drm-copilot__run_poshqc_format`, `..._analyze`, and `..._test`.
  - Those MCP results carry no counts or findings. Per memory, the MCP test runner also reads installed-extension settings.
  - The #690 plan therefore reads every count from self-hosted scratch scripts run with `sh SCRATCH/run-ps.sh` (`plan.2026-09-29T22-17.md:149-160`). Examples are `pester-counts.ps1` (`:850-864`) and `pester-coverage.ps1` with `CodeCoverage.Path` per file (`:866-904`). Reuse that catalogue.
  - CI runs `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCTest -Root` (`.github/workflows/_poshqc.yml:26,36,42`), plus a Linux Pester leg without coverage (`:73-82`).
- Python (test-only change): `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest --cov --cov-branch --cov-report=term-missing` (`.claude/rules/python.md:13-16`). The parity commands are listed in `plan.2026-09-29T22-17.md:146-147`.
- Change budget: four production PowerShell files plus four mirrors, which exceeds the direct-mode cap of three (`.claude/rules/powershell.md:39-41`). The orchestrated path is required, and this child is already on it.

## 8. Risks

| Risk | Mitigation |
|---|---|
| Blocking every orchestrator at SubagentStop | The item kind keeps today's decision; only the path becomes absolute. Epic and parallel resolution fail closed only on `NoTarget`/`Ambiguous`. Discovery makes the common single-run case resolve with no agent cooperation. |
| Retrospective violations are unrecoverable | A Layer 2 violation records history that the agent cannot undo. Once the transport and exit-code defect is fixed (exit 2), the block would keep the epic orchestrator running against a condition it cannot clear. The block text should instruct the agent to report and halt, and must not suggest editing timestamps. Planner decision. |
| Runtime inertness | The finding 4 caveat. The PR description should state that the decision logic is verified by tests and that its runtime effect depends on the SubagentStop transport fix. Recommend that the operator promote `2026-08-21-subagentstop-validators-read-undocumented-envelope.md`. No human action is needed for C6 itself. |
| Deny-token stability | Keep `ROUTING_CONTRACT_BLOCKED:` and `MODEL_ROUTING_BLOCKED:` unchanged (`:401-404`). Surface Layer 2 errors unwrapped, with their own `EPIC_WAVE_BARRIER_VIOLATION:` lead, identical to the Python and TypeScript strings. Add one new token for unresolved targets that carries the accessor reason codes. `ROUTING_CONTRACT_BLOCKED` is matched only by the three hook suites and the hook (Grep). |
| 500-line cap | Hook at 421, `validate-orchestrator-output.Tests.ps1` at 490, `WorktreeRunResolution.psm1` at 497, `WorktreeResolution.psm1` at 500. Put the Layer 2 port in a lib module, the resolution glue in a dot-sourced hook sibling (precedent `enforce-epic-merge-gate-resolution.ps1`), and new rows in new suites. |
| Parity drift with the TypeScript port | The TypeScript lane keeps consuming `start-guard-matrix.json` unchanged. Extending the TypeScript lane to the new file is optional and outside #840. |
| Concurrent C2/C3 edits | C6 touches only the Layer 1 header comment (C2 file) and consumes, without editing, the C3-owned module. Re-verify both after wave 0 and C3 merge. |
| Existing suites resolving against the developer machine | Add a default `BeforeAll` mock of the new resolution seam in each existing suite that reaches `Invoke-OrchestratorOutputValidation` (#690 research section 7, `:193`). |

## Recommended approach

1. Add a resolution seam (for example `Resolve-OrchestratorOutputCheckpointPath -ArtifactType -CheckpointPath -AgentOutput`) in a dot-sourced sibling `.claude/hooks/validate-orchestrator-output-resolution.ps1`. It implements section 2.4 using only exported resolver functions.
   - The hook imports `WorktreeRunResolution.psm1` inside a guard that records a failure and blocks with a message naming the module, following the Layer 1 pattern (`enforce-epic-wave-barrier.ps1:43-50,284-289`).
   - `Invoke-OrchestratorOutputValidation` calls the seam after the payload checks. It blocks `NoTarget`/`Ambiguous` with the new token, and otherwise passes the absolute path to every downstream read.
2. Add `OrchestratorStateEpicWaveBarrier.psm1` (section 3.6).
   - For `epic-orchestrator-state` only, after the routing dispatch passes, `Invoke-OrchestratorOutputValidation` calls `Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $file.Content`. That reuses the text already read at `:344` and leaves the `Invoker` signature `param($Path, $Type)` unchanged for existing stubs.
   - When there are errors, it blocks with the errors joined.
3. Add the parity corpus file, the Pester parity lane, and the Python lane (section 3.5).
4. Correct the three #840 documents and their mirrors so they state the following:
   - Layer 2 runs at `epic-orchestrator` SubagentStop as a PowerShell port of `validate_wave_barrier_ordering`, located in the new module and invoked by `validate-orchestrator-output.ps1`.
   - Parity with `validate_epic_orchestrator_state_text` is pinned by `tests/fixtures/epic_wave_barrier/`.
   - The Python validator remains the authority used through the MCP validation call (`SKILL.md:313-317`).

   Whether to mention the transport caveat in these documents is a planner decision. Evidence-first wording favors a short reference to it.
5. Register the new files in `core.json`, extend `OrchestratorState.Manifest.Tests.ps1`, and mirror every changed or new `.claude` file.

Rejected alternatives (brief):
- Python subprocess or leg in the hook: prohibited by the operator decision and by the no-Python guard.
- `ConvertFrom-Json`-based port: date coercion and case-insensitive keys break parity (section 3.4).
- Payload-identity-only resolution: blocks every run whose final message omits the literal, and couples resolution to a payload field the hook currently reads from an undocumented transport.
- Discovery-only resolution: cannot disambiguate two concurrent live epics without the payload signal.
- Inline glue in the hook: exceeds the 500-line budget.
- New `.claude/lib/epic-wave-barrier/` folder: requires a new `quality-tiers.yml` entry and a new manifest suite for no design benefit.
- Sharing code with Layer 1: semantics differ and C2 owns that file.

## Requirements mapping

| Acceptance criterion (issue.md) | Design element |
|---|---|
| Resolve the run checkpoint through `WorktreeRunResolution.psm1` | Resolution seam (section 2.4) composing every read path with `Get-WorktreeRunCheckpointPath` beneath a resolved root. |
| Unresolved or ambiguous target gives a named failure, with no session-root read | New lead token plus `ReasonCode`, read seam invoked 0 times (test rows). |
| Two-worktree test through resolver seams without files | `/synthetic-worktrees/` rows with module-scope mocks (section 6). |
| #840: Layer 2 runs at epic SubagentStop with no Python | `Get-OrchestratorStateEpicWaveBarrierError` invoked on the epic leg. |
| #840: same cases as the Python authority | Shared corpus in `tests/fixtures/epic_wave_barrier/` with Pester and pytest lanes; declared divergence classes listed. |
| #840: three documents plus mirrors corrected | `SKILL.md:244-254`, `epic-orchestrator.md:122-127`, `enforce-epic-wave-barrier.ps1:26-29` (re-located after C2). |

## Testing implications

- Pester is the primary lane. Every row is in-memory: mocked read seams, synthetic roots, committed fixtures read only. Temporary files and `TestDrive:` are excluded by policy.
- Line coverage of at least 85% applies to the hook, the resolution sibling, and the new module. Pester measures no branch coverage, so only the line threshold applies (`.claude/rules/general-unit-test.md`).
- T3 tier (`quality-tiers.yml:28-30,61-63`): no property-test or mutation obligation.
- The Python lane adds no production Python. It runs under the existing pytest configuration.

## Open decisions for the planner

1. The exact name of the new unresolved-target lead token.
2. Whether to apply the `-CheckpointPath` cross-check (recommended) or ignore the bound value.
3. Whether to move the `runbook_path` check onto the resolved root (recommended; small).
4. The block text for a Layer 2 violation (report and halt).
5. Whether the corrected documents mention the SubagentStop transport caveat.

## Automation Feasibility

No human interaction is required to implement, test, or merge this child:
- Every change is to repository files.
- Every verification runs locally or in CI: Pester through scratch scripts or PoshQC MCP, pytest through poetry, and parity tests.
- The two-worktree topology is modeled through mocked seams, so no real secondary worktree is needed.

One optional operator decision sits outside C6's acceptance criteria: whether to promote the SubagentStop transport and exit-code potential entry (`docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`), which determines when C6's decisions take effect at runtime.
