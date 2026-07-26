# Pass-After Evidence — Codex PreToolUse Transport (Issue #415)

Timestamp: 2026-07-25T20-46

This is the pass-after counterpart to `fail-before.2026-07-25T19-30.md`. Payload identity between the two is required by Interpretation I1 and is satisfied: the committed Pester cases use the same C4 envelope, the same four payload variants, the same eight handlers, and the same `ProcessStartInfo` + `RedirectStandardInput` harness with the same poisoned `CLAUDE_TOOL_INPUT` / `CLAUDE_SESSION_ID` values.

## Command

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53` and `scan_folders: ["tests/scripts/codex-hooks"]`
EXIT_CODE: 0

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53' with 1 selected scan folder(s)."}
```

Suite totals: `tests="194"`, `failures="0"`, `errors="0"`, `disabled="0"`, `time="72.284"`. **The targeted suite is fully green.**

Per-file breakdown:

| Suite | tests | failures | time (s) |
|---|---|---|---|
| `codex-pretooluse-transport.Tests.ps1` (new) | 27 | 0 | 27.166 |
| `codex-pretooluse-integration.Tests.ps1` (new) | 6 | 0 | 31.719 |
| `legacy-codex-hook-contracts.Tests.ps1` | 12 | 0 | 10.726 |
| `codex-epic-runtime-contracts.Tests.ps1` | 10 | 0 | 1.107 |
| `epic-child-launch-attestation.Tests.ps1` | 12 | 0 | 0.152 |
| `epic-child-launch-hardening.Tests.ps1` | 19 | 0 | 0.377 |
| `epic-child-worktree-launcher.Tests.ps1` | 22 | 0 | 0.289 |
| `epic-execution-gates.Tests.ps1` | 40 | 0 | 0.237 |
| `epic-provenance.Tests.ps1` | 29 | 0 | 0.304 |
| `epic-wave-launch-binding.Tests.ps1` | 10 | 0 | 0.081 |
| `model-profile-attestation.Tests.ps1` | 7 | 0 | 0.124 |

## Output Summary (i) — pass-after counterpart to the 32-row fail-before table

**All 32 rows now exit 0 with empty stdout.** At fail-before, 30 of those rows exited 2 with nonempty stderr and only 2 allowed.

The 32 rows are delivered by these committed cases in `codex-pretooluse-transport.Tests.ps1`:

| Fail-before rows | Committed case | Spawns | Result |
|---|---|---|---|
| `Edit` safe × 8 handlers (rows 1, 5, 9, 13, 17, 21, 25, 29) | `allows a safe Edit payload on every group handler` | 8 | PASS — exit 0, empty stdout, empty stderr |
| `Write` safe × 8 handlers (rows 2, 6, 10, 14, 18, 22, 26, 30) | `allows a safe Write payload on every group handler` | 8 | PASS — exit 0, empty stdout, empty stderr |
| `apply_patch {command:''}` × 8 handlers (rows 3, 7, 11, 15, 19, 23, 27, 31) | `allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'')` | 8 | PASS — exit 0, empty stdout |
| `apply_patch {command:'noop'}` × 8 handlers (rows 4, 8, 12, 16, 20, 24, 28, 32) | `allows a well-formed apply_patch payload whose tool_input maps to no file edit (command:'noop')` | 8 | PASS — exit 0, empty stdout |

A third safe variant not present in the fail-before table, `apply_patch` with a real `README.md` Add-File patch, is also asserted across all eight handlers (`allows a safe apply_patch payload on every group handler`, 8 spawns), covering the previously-reachable path that must not regress.

The two rows that already allowed at fail-before (`enforce-orchestration-preimplementation-gate` × both `apply_patch` variants) still allow, so the gate's pre-existing behaviour is preserved rather than changed (Hard Constraint 3, Interpretation I6).

## Output Summary (ii) — config-driven integration case

The case `allows every registered handler for every tool name its own matcher admits` derives both the registration set and the admitted tool names from `.codex/config.toml` at run time, so a future registration cannot silently escape coverage. Derived matrix, measured directly:

```
matcher ^(apply_patch|Edit|Write)$
    handlers=8  admitted=[apply_patch, Edit, Write]                                                   spawns=24
matcher ^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$
    handlers=5  admitted=[Bash, shell_command, apply_patch, Edit, Write, mcp__drm_copilot__run_poshqc_format]  spawns=30
matcher ^Bash$
    handlers=5  admitted=[Bash]                                                                        spawns=5

TOTAL registrations=18  distinct handlers=17  matrix spawns=59
```

**All 59 invocations exit 0 with empty stdout.** This matches the plan's predicted matrix (group 1 = 5, group 2 = 30, group 3 = 24, ≈ 59 spawns) exactly. The 18 registrations across 17 distinct handlers reflect `enforce-orchestration-preimplementation-gate.ps1` being registered in both the `^Bash$` group and the `^(apply_patch|Edit|Write)$` group.

This case also provides the regression-only coverage for the two non-implicated handler groups required by `spec.md:59` and `spec.md:74`: the five `^Bash$` handlers and the five `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` handlers are all exercised and all still allow.

A companion guard case, `parses at least three matcher groups and every registered handler from config.toml`, asserts the derivation is non-empty, spans at least three matchers, contains known handlers, and that every derived handler exists on disk. Without it a silently empty parse would make the 59-row matrix vacuously green.

## Additional committed regression cases

| Case | Spawns | Purpose |
|---|---|---|
| `fails closed with exit 2 when a batch-budget payload omits session_id` | 2 | `session_id` remains mandatory for the two batch-budget hooks; stderr matches `session_id`. |
| `allows an apply_patch update that touches only ungoverned files with a missing source` | 2 | Latent-defect regression (`spec.md:98`). Both checkpoint hooks exit 0 with empty stdout instead of exiting 2. |
| `emits only the native deny envelope for <hook> on a forbidden <tool> payload` | 15 | AC2. Asserts exit 0, stdout parses, `hookSpecificOutput.hookEventName == 'PreToolUse'`, `permissionDecision == 'deny'`, reason matches the policy marker, and the top-level `decision` key is **absent**. |
| `denies a preimplementation-gate implementation path mapped from <tool>` | 0 (unit) | Gate deny coverage for `Edit`, `Write`, and `apply_patch` via dot-source with an injected `-CheckpointRaw '{}'`, so it never depends on the repository's live checkpoint (Interpretation I4). |
| `fails closed with exit 2 for a missing/null tool_input on every group handler` | 16 | AC4, scoped per Interpretation I5 to the eight group handlers only. |
| `fails closed with exit 2 for empty stdin / invalid JSON on every registered handler` | 34 | AC4, applied to all 17 registered handlers. |
| `reports enforce-completion-consistency in its own stderr rather than its neighbour` | 3 | Regression for the misattribution recorded at `spec.md:52`. |
| `leaves no Codex batch-budget state behind` | 0 | Asserts `.codex/state` does not exist after the suite, enforcing convention C4. |

## Deny-envelope measurements (AC2 detail)

All 15 deny rows produce the native envelope with no legacy `decision` key:

| Handler | Tool | Reason marker |
|---|---|---|
| `check-python-test-purity` | Edit / Write / apply_patch | `tempfile usage forbidden` |
| `check-powershell-test-purity` | Edit / Write / apply_patch | `Start-Sleep forbidden` |
| `enforce-evidence-locations` | Edit / Write / apply_patch | `EVIDENCE_LOCATION_BLOCKED` |
| `enforce-checkpoint-monotonic` | Write / apply_patch | `CHECKPOINT_ORDER_BLOCKED` |
| `enforce-checkpoint-monotonic` | Edit | `cannot be deleted or replaced with empty content` |
| `enforce-completion-consistency` | Write / apply_patch | `COMPLETION_CONSISTENCY_BLOCKED` |
| `enforce-completion-consistency` | Edit | `replaced through an unresolved patch` |

### Recorded deviation from Interpretation I4

Plan Interpretation I4 anticipated that `enforce-checkpoint-monotonic` could not deny on a partial `Edit` and that the test would therefore "assert allow ... with a policy-site comment". Direct measurement against the preserved policy shows the opposite, and the test asserts the measured outcome:

- `enforce-checkpoint-monotonic` on an `Edit` of the checkpoint path **denies**. The mapped record carries `old_string`/`new_string` but no `content`; `Invoke-CheckpointMonotonicDecision` (`enforce-checkpoint-monotonic.ps1:230-239`) documents that "the adapter supplies complete post-patch content for every recognized operation. Empty content therefore represents deletion and must fail closed for the canonical checkpoint", and returns `CHECKPOINT_ORDER_BLOCKED: the canonical checkpoint cannot be deleted or replaced with empty content.`
- `enforce-completion-consistency` on the same input **denies** through `Resolve-EditedCheckpointContent`, which returns `$null` when the `old_string` is absent from the on-disk checkpoint, producing `COMPLETION_CONSISTENCY_BLOCKED: the canonical checkpoint cannot be deleted, emptied, or replaced through an unresolved patch.`

Both are reachable and deterministic. Determinism does not depend on the checkpoint's current contents because both `Edit` rows use the `old_string` sentinel `ZZZ-SENTINEL-NEVER-PRESENT-IN-CHECKPOINT-415`, which cannot occur in the file; a missing, empty, or arbitrary checkpoint all resolve to the same deny.

No policy function was modified to produce these outcomes; they are the untouched policy applied to a tool name that previously could not reach it. The direction is fail-closed, consistent with the standing requirement that checkpoint fail-closed denies remain denies. The test carries an inline comment citing the policy site.

## Side-effect verification

`ls .codex/state` after the run → "No such file or directory". No batch-budget state was written by any of the roughly 130 process spawns in the two new suites, confirming convention C4's payload choice.
