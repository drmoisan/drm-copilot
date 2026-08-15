# QA Gate — Discovery Hooks Verification (P3-T5) — Issue #475

Timestamp: 2026-08-15T20-20

Command:
1. `mcp__drm-copilot__run_poshqc_format` with `scan_folders: [".claude/hooks", "tests/scripts/claude-hooks"]`
2. `mcp__drm-copilot__run_poshqc_analyze` with the same narrowing
3. `Invoke-Pester` over `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` and `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` (the plan permits "the two suites via `Invoke-Pester -Path`")
4. `pwsh -NoProfile -File .claude/hooks/enforce-discovery-artifact-gate.ps1` with a `CLAUDE_TOOL_INPUT` payload
5. `pwsh -NoProfile -File .claude/hooks/validate-discovery-artifact-gate.ps1` with a `CLAUDE_HOOK_INPUT` payload

`scan_folders` is narrowed so the guard's repository-scan `It`s in `tests/scripts/claude-runtime` — legitimately red from Phase 1 until Phase 11 — are not pulled into this gate.

EXIT_CODE: 0

Output Summary:

- **Format**: clean and idempotent.
- **Analyze**: 0 findings.
- **Tests**: **34 passed, 0 failed, 0 skipped** across both suites.
- **Direct invocation**: both hooks executed as standalone processes without a `CommandNotFoundException`.

## Seam Contract Preserved

`Invoke-DiscoveryValidatorExe` keeps its name, its `-ValidatorArgs <string[]>` parameter, and its `@{ ExitCode; Output }` return shape in both hooks. All 26 pre-existing seam references are unmodified:

| File | `Mock` registrations | `Should -Invoke` assertions |
| --- | --- | --- |
| `enforce-discovery-artifact-gate.Tests.ps1` | 9 original (+3 added by P3-T4) = 12 | 7 (unchanged) |
| `validate-discovery-artifact-gate.Tests.ps1` | 6 original (+3 added by P3-T4) = 9 | 4 (unchanged) |
| **Total** | 15 original preserved | 11 preserved |

The fail-open `$ProfileReader = { $null }` default and the deny-on-non-empty-output logic are unchanged in both hooks, as is the `DISCOVERY_ARTIFACT_GATE_BLOCKED:` prefix (verified present in both files after the change).

## Direct-Invocation Results

```
=== enforce-discovery-artifact-gate.ps1 (PreToolUse, CLAUDE_TOOL_INPUT) ===
EXIT_CODE: 0
STDOUT: {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
CommandNotFoundException present: False

=== validate-discovery-artifact-gate.ps1 (SubagentStop, CLAUDE_HOOK_INPUT) ===
EXIT_CODE: 0
STDOUT: (empty)
CommandNotFoundException present: False
```

Both returned the expected allow verdict. The allow is produced by the gate's current fail-open required-artifact-declaration default (no domain-profile declaration is present in this worktree), which is the behavior the plan predicts for this check. The significant result is that neither process failed to resolve a command: before this change, a host without a Python interpreter would have raised `CommandNotFoundException` at `& python`.

## Python Removal at These Two Sites

A targeted search for a `python`/`poetry` command invocation in the two modified hooks returns **no matches**. The two Phase-1 fail-before findings at `enforce-discovery-artifact-gate.ps1:50` and `validate-discovery-artifact-gate.ps1:53` are therefore resolved. The guard's repository-scan `It`s are deliberately NOT re-run here; the plan defers them to Phase 14, after the remaining three sites are removed in Phases 10 and 11.

Remaining known sites, still expected red until then:
- `.claude/hooks/validate-orchestrator-output.ps1:196` (Phase 10)
- `.claude/lib/orchestrator-state/OrchestratorState.psm1:367` and `:451` (Phases 10-11)

## Six Incidental Hooks Byte-Unchanged

`git status --porcelain .claude/hooks/` lists exactly two modified files:

```
 M .claude/hooks/enforce-discovery-artifact-gate.ps1
 M .claude/hooks/validate-discovery-artifact-gate.ps1
```

None of the six out-of-scope incidental-match hooks (`check-python-test-purity.ps1`, `enforce-evidence-locations.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-python-batch-budget.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`) appears.

## Documentation Corrected Alongside the Change

Both hooks' `.NOTES` previously stated "the validator subprocess is the only external process invoked", which became false. Each now records that the gate invokes NO external process and requires PowerShell 7.4+ via the shared module. This is a correctness fix to a statement the change invalidated, in the same files the tasks already modify.
