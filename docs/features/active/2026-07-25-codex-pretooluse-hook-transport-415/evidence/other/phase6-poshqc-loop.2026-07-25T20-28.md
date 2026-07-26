# Phase 6 — PoshQC Loop (Issue #415)

Timestamp: 2026-07-25T20-28

Convention C3 loop, `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`. **All three stages passed in one uninterrupted pass**; no stage failed and no stage changed a file.

## Command / EXIT_CODE per stage

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 | `mcp__drm-copilot__run_poshqc_format` | 0 | zero files changed |
| 2 | `mcp__drm-copilot__run_poshqc_analyze` | 0 | 0 errors, 0 warnings, 0 information |
| 3 | `mcp__drm-copilot__run_poshqc_test` | 0 | 1358 tests, 0 failures |

## Output Summary

**Test counts:** `tests="1358"`, `failures="0"`, `errors="0"`, `disabled="9"`, `time="44.906"`.

**Line-coverage headline:** `LINE missed="235" covered="2151"` → total 2386 → **90.15%**, above the 85% threshold. Branch coverage is not separately measurable in this toolchain (`spec.md:248`).

Coverage moved from 90.22% to 90.15% in this phase. The cause is isolated and expected: the `.codex/hooks` package went from `missed=77 covered=99` to `missed=79 covered=100` because `enforce-completion-consistency.ps1` is one of only two `.codex/hooks` files in the coverage allow-list and its entrypoint gained lines. Per-file detail after this phase:

| File | missed | covered | total | line % |
|---|---|---|---|---|
| `enforce-completion-consistency.ps1` | 69 | 67 | 136 | 49.26 |
| `enforce-completion-helpers.ps1` | 10 | 33 | 43 | 76.74 |

The added entrypoint lines are process-level code guarded out by `if ($MyInvocation.InvocationName -eq '.') { return }`, so in-process Pester coverage cannot reach them; they are exercised instead by process-level spawns whose coverage Pester does not attribute. This is carried to `[P8-T8]` for explicit changed-line treatment.

## Work delivered in this phase

### `[P6-T1]` — `enforce-checkpoint-monotonic.ps1`

Dot-sources the shared module and adds one script-scoped constant, `$script:GovernedCheckpointPath = 'artifacts/orchestration/orchestrator-state.json'`. The entrypoint now calls `ConvertFrom-CodexPreToolUsePayload -HookName 'enforce-checkpoint-monotonic'` and maps with `ConvertTo-CodexFileEditInput -ResolveUpdateContent -GovernedPath $script:GovernedCheckpointPath`.

Removed: `ConvertFrom-CodexCheckpointHookPayload` (with its `tool_name -ne 'apply_patch'` assertion at the former lines 318-319) and `ConvertTo-CodexApplyPatchCheckpointInput` (with both unmapped-input throws at the former 333-334 and 341-342, and the two latent-defect throw sites at the former 364-367 and 391-392) — 99 lines removed in total.

**Latent defect fixed (`spec.md:98`).** Reconstruction now runs for the governed checkpoint path only:

- An `apply_patch` **Update touching only ungoverned files** produces no record, so the hook allows (exit 0, no stdout) instead of exiting 2 when a source file is missing or a hunk does not apply. This was verified directly against the module in Phase 2 (`Ungoverned missing-source update: count=0`).
- A **governed-path reconstruction failure** produces one record with empty content, which routes into the hook's pre-existing fail-closed deny rather than exit 2 (Interpretation I2). Verified in Phase 2 (`Governed non-applying hunk: count=1 contentLen=0`).

**Fail-closed deny sites preserved byte-for-byte.** Each of the three governed-path deny reasons is still present exactly once and untouched:

- `CHECKPOINT_ORDER_BLOCKED: the canonical checkpoint cannot be deleted or replaced with empty content.` — 1 occurrence
- `CHECKPOINT_ORDER_BLOCKED: the canonical checkpoint must remain valid JSON.` — 1 occurrence
- `COMPLETION_CONSISTENCY_BLOCKED: the canonical checkpoint cannot be deleted, emptied, or replaced through an unresolved patch.` — 1 occurrence

### `[P6-T2]` — `enforce-completion-consistency.ps1`

**No rename** (Interpretation I3). It still dot-sources `enforce-checkpoint-monotonic.ps1` for shared checkpoint policy logic; the comment above that dot-source now records that the sharing is by design. It additionally dot-sources the shared transport module explicitly rather than relying on the transitive load, so its transport does not depend on its neighbour's internals. Its entrypoint calls `ConvertFrom-CodexPreToolUsePayload -HookName 'enforce-completion-consistency'`.

`Resolve-EditedCheckpointContent` and every policy function are untouched.

### Acceptance verification

| Criterion | `enforce-checkpoint-monotonic.ps1` | `enforce-completion-consistency.ps1` |
|---|---|---|
| file ≤ 500 lines | **339** (was 420) | **438** (was 425) |
| no `tool_name -ne 'apply_patch'` assertion remains | **0** | **0** |
| no unmapped-input or reconstruction throw remains | **0** | **0** |
| policy functions byte-unchanged | **yes** | **yes** |

`git diff -U0` hunk map:

```
.codex/hooks/enforce-checkpoint-monotonic.ps1
  @@ -46,0 +47,9 @@ param()                                     <- dot-source + governed-path constant
  @@ -303,99 +311,0 @@ function Invoke-CheckpointMonotonicDecision  <- transport functions removed
  @@ -407,2 +317,11 @@ try {                                 <- entrypoint rewrite

.codex/hooks/enforce-completion-consistency.ps1
  @@ -44 +44,2 @@ param()                                     <- dot-source comment
  @@ -46,0 +48,6 @@ param()                                   <- shared-module dot-source
  @@ -412,2 +419,8 @@ try {                                 <- entrypoint rewrite
```

No hunk touches `Test-IsCheckpointPath`, `Invoke-CheckpointMonotonicDecision`, `ConvertFrom-CheckpointJson`, `Resolve-EditedCheckpointContent`, `Test-CompletionAsserted`, `Get-MissingCompletionEvidence`, or `Invoke-CompletionConsistencyDecision`.

### `[P6-T3]` — bundle mirrors

| File | Root == Bundle | SHA256 (first 16) |
|---|---|---|
| `enforce-checkpoint-monotonic.ps1` | True | `A79030D121578ACD` |
| `enforce-completion-consistency.ps1` | True | `CF301A28CA7F159D` |

### `[P6-T4]` — mapping-unit test update

The `ConvertTo-CodexApplyPatchCheckpointInput` assertions inside `It 'reconstructs update patches in memory and includes move destinations'` now dot-source `codex-pretooluse-file-mapping.ps1` and call `ConvertTo-CodexFileEditInput -ResolveUpdateContent -GovernedPath 'config/orchestration-routing.json'`. The expectations are unchanged: `file_path` equals `config/orchestration-routing.json` and `content` matches the LF-normalized on-disk file exactly (`Should -BeExactly`). The governed path is now supplied explicitly because reconstruction is scoped, which is the point of the latent-defect fix.

Per the preflight R4 coupling note the assertions were located by `It` title, not line number, and the block that `[P5-T4]` already edited was not restructured. No deny-path or fail-closed assertion changed.

## Acceptance clause — fail-closed cases pass without assertion changes (AC7)

The pre-existing `It 'fails closed when the canonical checkpoint is deleted or becomes invalid JSON'` block (formerly `legacy-codex-hook-contracts.Tests.ps1:175-191`) was **not** modified. All four of its cases pass: `Delete File` and invalid-JSON `Add File` patches against `artifacts/orchestration/orchestrator-state.json`, for both `enforce-checkpoint-monotonic` (reason matching `CHECKPOINT_ORDER_BLOCKED`) and `enforce-completion-consistency` (reason matching `COMPLETION_CONSISTENCY_BLOCKED`). Checkpoint fail-closed denies remain denies.

## Transport probes (progress checks, not plan tasks)

Two throwaway probes held outside the repository working tree confirmed the phase's intent before the loop was run. Both were deleted after use.

**Probe 1 — the `[P1-T1]` 32-row matrix re-run against the fixed tree: `PASS_ROWS=32 / 32`.** Every one of the eight handlers now exits 0 with empty stdout for the safe `Edit`, safe `Write`, `apply_patch {command:''}`, and `apply_patch {command:'noop'}` payloads. That is the complete pass-after counterpart to the 30 exit-2 fail-before rows. No `.codex/state/` directory was created.

**Probe 2 — the malformed-input contract across the eight group handlers × four malformed inputs (empty, `{not-json`, null `tool_input`, missing `tool_input`): 32 / 32 conforming**, where conforming means exit 2 with empty stdout and nonempty stderr.

The `enforce-completion-consistency` self-naming defect is fixed. For all four malformed inputs its stderr now names itself and never names its neighbour:

```
empty               exit=2 stdoutEmpty=True namesSelf=True namesNeighbour=False err=[enforce-completion-consistency hook input is empty.]
invalid-json        exit=2 stdoutEmpty=True namesSelf=True namesNeighbour=False err=[enforce-completion-consistency hook input is malformed JSON: ...]
null-tool_input     exit=2 stdoutEmpty=True namesSelf=True namesNeighbour=False err=[enforce-completion-consistency hook input is missing tool_input.]
missing-tool_input  exit=2 stdoutEmpty=True namesSelf=True namesNeighbour=False err=[enforce-completion-consistency hook input is missing tool_input.]
```

Compare the fail-before rows 29-32, where the same hook reported `enforce-checkpoint-monotonic ...`.

## Batch accounting (convention C2)

2 production units (each a root hook plus its bundle mirror), 1 test file. Within C2 limits.
