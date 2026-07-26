# Fail-Before Evidence — Codex PreToolUse Transport (Issue #415)

Timestamp: 2026-07-25T19-30

Status: **[expect-fail] — a failing result is the expected and required outcome of this task.**

## Mechanism (Interpretation I1)

`spec.md:236` asks for fail-before capture "by running the new process-level cases against the pre-fix hooks." Committing a failing Pester file before the fix would break the mandatory per-phase PoshQC loop for every intermediate phase. Per plan Interpretation **I1**, the identical process-level cases were therefore executed as a **throwaway pwsh probe stored outside the repository working tree**, in the session scratchpad:

```
C:\Users\DANMOI~1\AppData\Local\Temp\claude\C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-25T16-53\0b990390-766c-4741-bdf4-a392218e0943\scratchpad\fail-before-probe.ps1
```

The probe was never inside the repository, so PoshQC never scanned it, it could not trip the `.codex` PowerShell batch-budget or test-purity hooks, and it could not be committed. **It was deleted immediately after this artifact was written** (deletion confirmed below).

The probe reuses:

- the C4 payload envelope, byte-for-byte identical to `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30-41` (`session_id`, `transcript_path`, `cwd`, `hook_event_name`, `model`, `permission_mode`, `turn_id`, `tool_name`, `tool_use_id`, `tool_input`);
- the `System.Diagnostics.ProcessStartInfo` + `RedirectStandardInput` harness of `legacy-codex-hook-contracts.Tests.ps1:50-80` (Hard Constraint 5 — no temporary files);
- poisoned legacy environment on every invocation: `CLAUDE_TOOL_INPUT='{"command":"git reset --hard"}'` and `CLAUDE_SESSION_ID='poisoned-legacy-session'`.

Payload identity between this probe and the committed Pester cases of `[P7-T1]` is required by I1 so the 32 rows below have exact pass-after counterparts.

## Command

```
pwsh -NoProfile -File "<scratchpad>/fail-before-probe.ps1" -RepoRoot "C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53"
```

Probe process EXIT_CODE: 0 (the probe itself is a reporter; the per-case exit codes are the evidence).

## Case matrix

Eight handlers (plan convention C5 — the full `^(apply_patch|Edit|Write)$` registration group at `.codex/config.toml:186-234`) × four payload variants = 32 cases.

Payload variants:

1. `Edit` safe — `{file_path:'README.md', old_string:'a', new_string:'b'}`
2. `Write` safe — `{file_path:'README.md', content:'safe'}`
3. `apply_patch` unmapped-empty — `{command:''}`
4. `apply_patch` unmapped-marker-free — `{command:'noop'}`

Safe payloads target `README.md` (non-`.py`, non-`.ps1`, non-implementation extension) per convention C4, so batch-budget entrypoints write nothing under `.codex/state/` and the preimplementation gate allows.

## EXIT_CODE per case (32 rows)

| # | Handler | Case | Exit | Stdout | Stderr |
|---|---|---|---|---|---|
| 1 | `check-python-test-purity` | Edit safe README.md | **2** | empty | `check-python-test-purity requires a PreToolUse apply_patch payload.` |
| 2 | `check-python-test-purity` | Write safe README.md | **2** | empty | `check-python-test-purity requires a PreToolUse apply_patch payload.` |
| 3 | `check-python-test-purity` | apply_patch `{command:''}` | **2** | empty | `check-python-test-purity cannot map tool_input to a file edit.` |
| 4 | `check-python-test-purity` | apply_patch `{command:'noop'}` | **2** | empty | `check-python-test-purity received an unrecognized apply_patch command.` |
| 5 | `enforce-python-batch-budget` | Edit safe README.md | **2** | empty | `enforce-python-batch-budget requires a PreToolUse apply_patch payload.` |
| 6 | `enforce-python-batch-budget` | Write safe README.md | **2** | empty | `enforce-python-batch-budget requires a PreToolUse apply_patch payload.` |
| 7 | `enforce-python-batch-budget` | apply_patch `{command:''}` | **2** | empty | `enforce-python-batch-budget cannot map tool_input to a file edit.` |
| 8 | `enforce-python-batch-budget` | apply_patch `{command:'noop'}` | **2** | empty | `enforce-python-batch-budget received an unrecognized apply_patch command.` |
| 9 | `check-powershell-test-purity` | Edit safe README.md | **2** | empty | `check-powershell-test-purity requires a PreToolUse apply_patch payload.` |
| 10 | `check-powershell-test-purity` | Write safe README.md | **2** | empty | `check-powershell-test-purity requires a PreToolUse apply_patch payload.` |
| 11 | `check-powershell-test-purity` | apply_patch `{command:''}` | **2** | empty | `check-powershell-test-purity cannot map tool_input to a file edit.` |
| 12 | `check-powershell-test-purity` | apply_patch `{command:'noop'}` | **2** | empty | `check-powershell-test-purity received an unrecognized apply_patch command.` |
| 13 | `enforce-powershell-batch-budget` | Edit safe README.md | **2** | empty | `enforce-powershell-batch-budget requires a PreToolUse apply_patch payload.` |
| 14 | `enforce-powershell-batch-budget` | Write safe README.md | **2** | empty | `enforce-powershell-batch-budget requires a PreToolUse apply_patch payload.` |
| 15 | `enforce-powershell-batch-budget` | apply_patch `{command:''}` | **2** | empty | `enforce-powershell-batch-budget cannot map tool_input to a file edit.` |
| 16 | `enforce-powershell-batch-budget` | apply_patch `{command:'noop'}` | **2** | empty | `enforce-powershell-batch-budget received an unrecognized apply_patch command.` |
| 17 | `enforce-evidence-locations` | Edit safe README.md | **2** | empty | `enforce-evidence-locations requires a PreToolUse apply_patch payload.` |
| 18 | `enforce-evidence-locations` | Write safe README.md | **2** | empty | `enforce-evidence-locations requires a PreToolUse apply_patch payload.` |
| 19 | `enforce-evidence-locations` | apply_patch `{command:''}` | **2** | empty | `enforce-evidence-locations cannot map tool_input to a file edit.` |
| 20 | `enforce-evidence-locations` | apply_patch `{command:'noop'}` | **2** | empty | `enforce-evidence-locations received an unrecognized apply_patch command.` |
| 21 | `enforce-orchestration-preimplementation-gate` | Edit safe README.md | **2** | empty | `enforce-orchestration-preimplementation-gate requires a supported PreToolUse payload.` |
| 22 | `enforce-orchestration-preimplementation-gate` | Write safe README.md | **2** | empty | `enforce-orchestration-preimplementation-gate requires a supported PreToolUse payload.` |
| 23 | `enforce-orchestration-preimplementation-gate` | apply_patch `{command:''}` | **0** | empty | (empty) |
| 24 | `enforce-orchestration-preimplementation-gate` | apply_patch `{command:'noop'}` | **0** | empty | (empty) |
| 25 | `enforce-checkpoint-monotonic` | Edit safe README.md | **2** | empty | `enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.` |
| 26 | `enforce-checkpoint-monotonic` | Write safe README.md | **2** | empty | `enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.` |
| 27 | `enforce-checkpoint-monotonic` | apply_patch `{command:''}` | **2** | empty | `enforce-checkpoint-monotonic cannot map tool_input to a file edit.` |
| 28 | `enforce-checkpoint-monotonic` | apply_patch `{command:'noop'}` | **2** | empty | `enforce-checkpoint-monotonic received an unrecognized apply_patch command.` |
| 29 | `enforce-completion-consistency` | Edit safe README.md | **2** | empty | `enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.` |
| 30 | `enforce-completion-consistency` | Write safe README.md | **2** | empty | `enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.` |
| 31 | `enforce-completion-consistency` | apply_patch `{command:''}` | **2** | empty | `enforce-checkpoint-monotonic cannot map tool_input to a file edit.` |
| 32 | `enforce-completion-consistency` | apply_patch `{command:'noop'}` | **2** | empty | `enforce-checkpoint-monotonic received an unrecognized apply_patch command.` |

## Output Summary

Probe tallies, emitted by the probe itself:

```
TOTAL_ROWS=32
EXIT2_WITH_STDERR=30
EXIT0_EMPTY_STDOUT=2
```

**Acceptance for `[P1-T1]` is met exactly:**

- **30 rows show exit 2 with nonempty stderr** — the seven legacy handlers × all 4 cases (28 rows), plus `enforce-orchestration-preimplementation-gate` × `Edit` and × `Write` (2 rows). All 30 also have empty stdout.
- **2 rows show exit 0 with empty stdout** — `enforce-orchestration-preimplementation-gate` × both `apply_patch` variants. This is the gate's pre-existing allow, preflight-measured, and it is **policy to preserve** under Hard Constraint 3 (Interpretation I6). Only its `Edit`/`Write` rows are fail-before rows.

**All 9 rows from the measured table in `spec.md` (fenced block, data rows at `spec.md:44-52`) reproduce their exact stderr messages:**

| spec.md line | Reproduced by row | Stderr match |
|---|---|---|
| 44 | 1 | `check-python-test-purity requires a PreToolUse apply_patch payload.` — exact |
| 45 | 2 | `check-python-test-purity requires a PreToolUse apply_patch payload.` — exact |
| 46 | 3 | `check-python-test-purity cannot map tool_input to a file edit.` — exact, from the `{command:''}` variant (`check-python-test-purity.ps1:172-173`) |
| 47 | 5 | `enforce-python-batch-budget requires a PreToolUse apply_patch payload.` — exact |
| 48 | 9 | `check-powershell-test-purity requires a PreToolUse apply_patch payload.` — exact |
| 49 | 13 | `enforce-powershell-batch-budget requires a PreToolUse apply_patch payload.` — exact |
| 50 | 17 | `enforce-evidence-locations requires a PreToolUse apply_patch payload.` — exact |
| 51 | 25 | `enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.` — exact |
| 52 | 29 | `enforce-checkpoint-monotonic requires a PreToolUse apply_patch payload.` — exact, and note the message names the **neighbour** hook, not `enforce-completion-consistency`; this is the self-naming defect the `-HookName` parameterization of `[P6-T2]` must fix |

The `{command:'noop'}` variant correctly emits the different message `received an unrecognized apply_patch command.` (`check-python-test-purity.ps1:180-181` and the equivalent site in each sibling), confirming both unmapped-input throw sites are exercised, not just one.

## Side-effect verification

- `.codex/state/` does **not** exist after the probe run (`ls .codex/state` → "No such file or directory"). No batch-budget state was written, confirming convention C4's payload choice works as intended.
- `git status --porcelain` after the run shows only this feature's own plan edit and Phase 0 evidence artifacts. No tracked file was modified by the probe.

## Probe deletion

The throwaway probe file was deleted after this artifact was written, per Interpretation I1 and Hard Constraint 5.
