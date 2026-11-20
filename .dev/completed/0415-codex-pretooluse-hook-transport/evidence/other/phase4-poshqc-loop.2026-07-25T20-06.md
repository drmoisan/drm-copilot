# Phase 4 — PoshQC Loop (Issue #415)

Timestamp: 2026-07-25T20-06

Convention C3 loop, `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`. **All three stages passed in one uninterrupted pass**; no stage failed and no stage changed a file.

## Command / EXIT_CODE per stage

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 | `mcp__drm-copilot__run_poshqc_format` | 0 | zero files changed |
| 2 | `mcp__drm-copilot__run_poshqc_analyze` | 0 | 0 errors, 0 warnings, 0 information |
| 3 | `mcp__drm-copilot__run_poshqc_test` | 0 | 1358 tests, 0 failures |

## Output Summary

**Test counts:** `tests="1358"`, `failures="0"`, `errors="0"`, `disabled="9"`, `time="37.072"`.

**Line-coverage headline:** `LINE missed="233" covered="2150"` → total 2383 → **90.22%**, unchanged and above the 85% threshold. Branch coverage is not separately measurable in this toolchain (`spec.md:248`).

**No `.codex/state/` writes:** `ls .codex/state` → "No such file or directory", both after the interim probe and after the Pester run.

## Work delivered in this phase

`[P4-T1]` rewired `.codex/hooks/enforce-python-batch-budget.ps1` and `[P4-T2]` rewired `.codex/hooks/enforce-powershell-batch-budget.ps1` identically. Each dot-sources the shared module after `param()` and routes its entrypoint through `ConvertFrom-CodexPreToolUsePayload -HookName '<its own name>' -RequireSessionId` plus `ConvertTo-CodexFileEditInput`.

Removed from each file: the local `ConvertFrom-Codex*BudgetPayload` validator (including its `tool_name -ne 'apply_patch'` assertion) and the local `Get-Codex*BudgetPath` adapter (including both unmapped-input throws). The `session_id` requirement was **retained** and moved onto the shared parser's `-RequireSessionId` switch, so a missing or empty `session_id` still produces exit 2 — the counter is keyed by it.

Rename handling is preserved exactly. The pre-fix path scan matched `Add|Update|Delete File` targets **and** `Move to:` destinations in one alternation and de-duplicated the result, so both sides of a rename consumed budget. The replacement collects `source_path` then `file_path` from each mapped record, filters blanks, and applies `Select-Object -Unique`, which reproduces the same path set in the same document order.

### Acceptance verification

| Criterion | `enforce-python-batch-budget.ps1` | `enforce-powershell-batch-budget.ps1` |
|---|---|---|
| file ≤ 500 lines | **254** | **256** |
| no `tool_name -ne 'apply_patch'` assertion remains | `grep -c` → **0** | `grep -c` → **0** |
| no unmapped-input throw remains | `grep -cE` → **0** | `grep -cE` → **0** |
| `session_id` requirement retained as exit 2 | `-RequireSessionId` present (**1** occurrence) | `-RequireSessionId` present (**1** occurrence) |
| policy and state-keying functions byte-unchanged | **yes** | **yes** |

Policy integrity verified structurally. `git diff -U0` produces four hunks per file, all after the last policy function:

```
.codex/hooks/enforce-python-batch-budget.ps1
  @@ -36,0 +37,4 @@ param()                                  <- dot-source insertion
  @@ -213,47 +216,0 @@ function Invoke-PythonBatchBudgetHook    <- transport functions removed
  @@ -265 +222,3 @@ try {                                <- shared parser call
  @@ -271 +230,12 @@ try {                               <- path collection

.codex/hooks/enforce-powershell-batch-budget.ps1
  @@ -38,0 +39,4 @@ param()
  @@ -215,47 +218,0 @@ function Invoke-PowerShellBatchBudgetHook
  @@ -267 +224,3 @@ try {
  @@ -273 +232,12 @@ try {
```

No hunk touches `Get-*BatchBudgetState`, `ConvertTo-*BatchBudgetState`, `Get-*BatchBudgetBlockDecision`, `Invoke-*BatchBudgetDecision`, or `Invoke-*BatchBudgetHook`. The state file name, the `session_id` sanitisation (`-replace '[^A-Za-z0-9._-]', '_'`), the repository-root derivation, and the `prodCap`/`testCap` values of 3/3 are all carried through unchanged.

`[P4-T3]` mirrored both rewired files byte-for-byte into the bundle hooks folder. SHA256 parity confirmed for both pairs:

| File | Root == Bundle | SHA256 (first 16) |
|---|---|---|
| `enforce-python-batch-budget.ps1` | True | `D241B6F85F1A450C` |
| `enforce-powershell-batch-budget.ps1` | True | `08078B95D01E871D` |

## Acceptance clause — unit-level budget deny tests pass without assertion changes (AC7)

`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` was not modified in this phase. The pre-existing unit-level deny cases at `legacy-codex-hook-contracts.Tests.ps1:193-211` (now shifted by the Phase 2 additions, located by the `It` title `denies preimplementation and batch-budget violations through their pure decisions`) dot-source each budget hook and drive `Invoke-PythonBatchBudgetDecision` / `Invoke-PowerShellBatchBudgetDecision` with injected state. Both still return `permissionDecision = 'deny'` with no assertion changes, because the decision functions are byte-unchanged and the dot-source guard still returns before the entrypoint. Per `spec.md:263`, forbidden batch-budget cases remain unit-level rather than process-level, so no state file is ever written during the suite.

## Interim transport probe (progress check, not a plan task)

A throwaway probe held outside the repository working tree re-ran the `[P1-T1]` 32-row matrix against the current tree. Result: **18 of 32 rows now exit 0 with empty stdout**, up from 2 at fail-before.

- The 16 newly-passing rows are exactly the four hooks rewired so far (`check-python-test-purity`, `check-powershell-test-purity`, `enforce-python-batch-budget`, `enforce-powershell-batch-budget`) × all four payload variants (`Edit` safe, `Write` safe, `apply_patch` `{command:''}`, `apply_patch` `{command:'noop'}`).
- The remaining 14 failing rows belong exclusively to the four hooks not yet rewired: `enforce-evidence-locations` (4), `enforce-orchestration-preimplementation-gate` (2 — its `Edit`/`Write` rows only, its two `apply_patch` rows already allow), `enforce-checkpoint-monotonic` (4), and `enforce-completion-consistency` (4). These are the Phase 5 and Phase 6 targets.
- `enforce-completion-consistency`'s stderr still reads `enforce-checkpoint-monotonic ...`, confirming the self-naming defect is still outstanding and is fixed in `[P6-T2]`.
- No `.codex/state/` directory was created by the probe, confirming the rewired batch-budget hooks write no state for a `README.md` target (a non-`.py`/non-`.ps1` path short-circuits before the state directory is touched).

The probe was deleted after use.

## Batch accounting (convention C2)

2 production units (each a root hook plus its bundle mirror), 0 test files. Within C2 limits.
