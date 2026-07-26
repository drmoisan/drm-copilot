# Phase 5 — PoshQC Loop (Issue #415)

Timestamp: 2026-07-25T20-16

Convention C3 loop, `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`. **All three stages passed in one uninterrupted pass**; no stage failed and no stage changed a file.

## Command / EXIT_CODE per stage

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 | `mcp__drm-copilot__run_poshqc_format` | 0 | zero files changed |
| 2 | `mcp__drm-copilot__run_poshqc_analyze` | 0 | 0 errors, 0 warnings, 0 information |
| 3 | `mcp__drm-copilot__run_poshqc_test` | 0 | 1358 tests, 0 failures |

## Output Summary

**Test counts:** `tests="1358"`, `failures="0"`, `errors="0"`, `disabled="9"`, `time="41.993"`.

**Line-coverage headline:** `LINE missed="233" covered="2150"` → total 2383 → **90.22%**, unchanged and above the 85% threshold. Branch coverage is not separately measurable in this toolchain (`spec.md:248`).

## Work delivered in this phase

### `[P5-T1]` — `enforce-evidence-locations.ps1`

Dot-sources the shared module; `Invoke-EvidenceLocationEntryPoint` now calls `ConvertFrom-CodexPreToolUsePayload -HookName 'enforce-evidence-locations'` and derives its path set from `ConvertTo-CodexFileEditInput`. Removed: the local `ConvertFrom-CodexEvidenceLocationPayload` validator (with its `tool_name -ne 'apply_patch'` assertion) and the local `Get-CodexEvidenceLocationPath` adapter (with both unmapped-input throws). An empty mapping yields no paths, so the hook allows silently.

Rename handling preserved: the pre-fix scan matched `Add|Update|Delete File` targets and `Move to:` destinations in one alternation and de-duplicated; the replacement collects `source_path` then `file_path` per record and applies `Select-Object -Unique`, producing the same set in the same order.

**Docstring correction (required by `[P5-T1]`).** The `.DESCRIPTION` previously claimed "For allowed paths, a PreToolUse response with permissionDecision = 'allow' is written to stdout and the script exits 0." That was never the implemented behaviour. It now reads: "Allowed paths produce NO stdout at all: the script allows silently and exits 0. On hard failure (empty, malformed, or tool_input-less stdin) the script writes the reason to stderr and exits 2."

**Latent defect found and fixed in the same file.** Before this phase, `Invoke-EvidenceLocationEntryPoint` declared `[Parameter(Mandatory)][string] $PayloadRaw` with no `[AllowEmptyString()]`. Empty stdin therefore raised a parameter-binding error at the call site `exit (Invoke-EvidenceLocationEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))`, which sits **outside** any `try`. The `exit` never executed and the script fell off the end. Measured pre-change behaviour:

```
enforce-evidence-locations.ps1        emptyStdin exit=0  stdout=[]  stderr=[Invoke-EvidenceLocationEntryPoint: ...enforce-evidence-locations.ps1:218:53]
enforce-checkpoint-monotonic.ps1      emptyStdin exit=2  stdout=[]  stderr=[Cannot bind argument to parameter 'PayloadRaw' because it is an empty string.]
enforce-orchestration-preimplementation-gate.ps1  emptyStdin exit=2  stdout=[]  stderr=[Cannot bind argument to parameter 'PayloadRaw' because it is an empty string.]
```

**`enforce-evidence-locations` exited 0 on empty stdin — a silent allow on malformed input**, contradicting AC4 and the general fail-closed contract. Adding `[AllowEmptyString()]` routes empty input into the shared parser, which throws `enforce-evidence-locations hook input is empty.` and returns 2. This is a correction toward the required contract, not a policy change: no allow/deny decision function was touched, and the previous behaviour was an unhandled error, not a designed allow.

The same `[AllowEmptyString()]` treatment on the shared parser also replaces the other hooks' generic binding-error message with a hook-named one, satisfying the AC4 requirement that stderr identify the reporting hook.

### `[P5-T2]` — `enforce-orchestration-preimplementation-gate.ps1` (eighth production unit)

Replaced `ConvertFrom-CodexPreimplementationHookPayload` (including its `@('Bash','apply_patch') -notcontains` tool-name rejection at the former lines 242-244) with the shared parser, then routed by tool name:

- **(a) `Bash` and `apply_patch`** take the pre-fix path byte-for-byte: `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ($payload.tool_input | ConvertTo-Json -Compress -Depth 20)`. The serialization expression, the decision call, the deny-emission branch, and the `exit 0` are unchanged, so **every allow/deny outcome these two tool names produce today is preserved exactly** (Hard Constraint 3).
- **(b) `Edit` / `Write`** map through `ConvertTo-CodexFileEditInput`; each mapped record's `file_path` is passed as `@{ file_path = ... }` into the same untouched `Invoke-OrchestrationPreimplementationGateDecision`, which routes it into `Test-ImplementationPath` at `enforce-orchestration-preimplementation-gate.ps1:195-198`.
- **(c) any other well-formed tool name** maps to no records and allows (exit 0, no stdout).

### Acceptance verification

| Criterion | `enforce-evidence-locations.ps1` | `enforce-orchestration-preimplementation-gate.ps1` |
|---|---|---|
| file ≤ 500 lines | **196** | **265** |
| no tool-name rejection remains | `grep -cE` → **0** | `grep -cE` → **0** |
| no unmapped-input throw remains | `grep -cE` → **0** | `grep -cE` → **0** |
| policy functions byte-unchanged | **yes** | **yes** |

`git diff -U0` hunk map:

```
.codex/hooks/enforce-evidence-locations.ps1
  @@ -33,3 +33,3 @@                                        <- authorized docstring correction
  @@ -43,0 +44,4 @@ param()                                <- dot-source insertion
  @@ -145,46 +148,0 @@ function Invoke-EvidenceLocationDecision   <- transport functions removed
  @@ -191,0 +150,8 @@ / @@ -194 +160 @@ / @@ -197,2 +163,14 @@      <- entrypoint rewrite

.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
  @@ -8,0 +9,4 @@ param()                                 <- dot-source insertion
  @@ -227,22 +230,0 @@ function Invoke-OrchestrationPreimplementationGateDecision  <- validator removed
  @@ -254,5 +236,24 @@ try {                             <- entrypoint rewrite
```

No hunk touches `Test-EvidenceLocationForbidden`, `Get-EvidenceLocationBlockDecision`, or `Invoke-EvidenceLocationDecision`; and none touches `Test-ImplementationPath`, `Test-ImplementationCommand`, `Test-ImplementationDelegation`, `Test-OrchestrationReady`, `Get-CheckpointContent`, either decision builder, or `Invoke-OrchestrationPreimplementationGateDecision`. All gate policy functions are byte-unchanged, which is the basis for the AC7 claim about the gate's existing `Bash`/`apply_patch` outcomes.

### `[P5-T3]` — bundle mirrors

| File | Root == Bundle | SHA256 (first 16) |
|---|---|---|
| `enforce-evidence-locations.ps1` | True | `59FE71CE6A96A505` |
| `enforce-orchestration-preimplementation-gate.ps1` | True | `2EC3BC90C078F39E` |

### `[P5-T4]` — mapping-unit test update

The assertions inside `It 'reconstructs update patches in memory and includes move destinations'` that previously called the removed `Get-CodexEvidenceLocationPath` now dot-source `codex-pretooluse-file-mapping.ps1` and exercise `ConvertTo-CodexFileEditInput`, collecting `source_path` and `file_path` per record. The expected paths are unchanged: the assertions still require `README.md` and `artifacts/research/moved.md`.

Per the preflight R4 coupling note, the assertions were located by the `It` title rather than by line number, and the block was **not** restructured: it remains a single `It` block containing both assertion groups, with the `ConvertTo-CodexApplyPatchCheckpointInput` group (which `[P6-T4]` will edit) left intact ahead of the edited group. No deny-path or policy assertion was changed.

## Batch accounting (convention C2)

2 production units (each a root hook plus its bundle mirror), 1 test file. Within C2 limits.
