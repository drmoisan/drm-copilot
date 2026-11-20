# Phase 3 — PoshQC Loop (Issue #415)

Timestamp: 2026-07-25T19-58

Convention C3 loop, `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`. **All three stages passed in one uninterrupted pass**; no stage failed and no stage changed a file.

## Command / EXIT_CODE per stage

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 | `mcp__drm-copilot__run_poshqc_format` | 0 | zero files changed |
| 2 | `mcp__drm-copilot__run_poshqc_analyze` | 0 | 0 errors, 0 warnings, 0 information |
| 3 | `mcp__drm-copilot__run_poshqc_test` | 0 | 1358 tests, 0 failures |

## Output Summary

**Test counts:** `tests="1358"`, `failures="0"`, `errors="0"`, `disabled="9"`, `time="38.700"`.

**Line-coverage headline:** `LINE missed="233" covered="2150"` → total 2383 → **90.22%**, unchanged and above the 85% threshold. Branch coverage is not separately measurable in this toolchain (`spec.md:248`).

**No `.codex/state/` writes:** `ls .codex/state` → "No such file or directory".

## Work delivered in this phase

`[P3-T1]` rewired `.codex/hooks/check-python-test-purity.ps1` and `[P3-T2]` rewired `.codex/hooks/check-powershell-test-purity.ps1` identically. Each file now dot-sources the shared module immediately after its `param()` block and routes its entrypoint through `ConvertFrom-CodexPreToolUsePayload -HookName '<its own name>'` plus `ConvertTo-CodexFileEditInput`.

Removed from each file: the local `ConvertFrom-Codex*PurityPayload` validator (including its `tool_name -ne 'apply_patch'` assertion) and the local `ConvertTo-Codex*PurityInput` adapter (including both unmapped-input throws). An empty mapping result now means the `foreach` body never executes and the hook reaches `exit 0` with no stdout — allow-silently.

### Acceptance verification

| Criterion | `check-python-test-purity.ps1` | `check-powershell-test-purity.ps1` |
|---|---|---|
| file ≤ 500 lines | **166** | **166** |
| no `tool_name -ne 'apply_patch'` assertion remains | `grep -c` → **0** | `grep -c` → **0** |
| no unmapped-input throw remains (`cannot map tool_input`, `unrecognized apply_patch`) | `grep -cE` → **0** | `grep -cE` → **0** |
| policy functions byte-unchanged | **yes** | **yes** |

Policy-function integrity was verified structurally, not by inspection alone. `git diff -U0` produces exactly three hunks per file:

```
.codex/hooks/check-python-test-purity.ps1
  @@ -32,0 +33,4 @@ param()                                  <- dot-source insertion
  @@ -141,63 +144,0 @@ function Invoke-PythonTestPurityDecision   <- transport functions removed
  @@ -209,2 +150,5 @@ try {                                <- entrypoint rewrite

.codex/hooks/check-powershell-test-purity.ps1
  @@ -35,0 +36,4 @@ param()
  @@ -141,63 +144,0 @@ function Invoke-PowerShellTestPurityDecision
  @@ -209,2 +150,5 @@ try {
```

No hunk adds or removes any line of `Get-*TestPurityBlockDecision`, `Test-*TestFilePath`, or `Invoke-*TestPurityDecision`; a targeted grep of the diff for policy-function declaration lines returns **0** for both files. Every change is confined to the transport region.

`[P3-T3]` mirrored both rewired files byte-for-byte into the bundle hooks folder. SHA256 parity confirmed for both pairs:

| File | Root == Bundle | SHA256 (first 16) |
|---|---|---|
| `check-python-test-purity.ps1` | True | `C3E9B8601676E4B1` |
| `check-powershell-test-purity.ps1` | True | `AE2A5C475FDEBE26` |

## Acceptance clause — existing `apply_patch` cases pass without assertion changes (AC7)

`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` was **not** modified in this phase. The following pre-existing process-level cases exercise both rewired hooks and all pass unchanged, which is the evidence that the preserved policy produces identical outcomes for previously reachable `apply_patch` payloads:

- `ignores poisoned Claude variables when safe Codex stdin payloads are supplied` — safe `apply_patch` Add-File patch against `README.md` → exit 0, empty stdout, empty stderr.
- `fails closed with exit 2 and stderr for malformed stdin on every hook` — `{not-json` → exit 2, empty stdout, nonempty stderr. The shared module's hook-named message satisfies this without weakening the assertion.
- `emits the current PreToolUse deny envelope for shell and patch violations` — `check-python-test-purity` against an Add-File patch containing `import tempfile` still denies with reason matching `tempfile usage forbidden`; `check-powershell-test-purity` against a patch containing `Start-Sleep -Seconds 1` still denies with reason matching `Start-Sleep forbidden`. Both assert the native envelope shape.

## Batch accounting (convention C2)

2 production units (each a root hook plus its bundle mirror), 0 test files. Within C2 limits.
