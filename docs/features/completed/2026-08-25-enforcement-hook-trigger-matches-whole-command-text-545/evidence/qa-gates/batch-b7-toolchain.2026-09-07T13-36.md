# Batch B7 — batch toolchain gate (Codex preimplementation gate, canonical + bundle)

Timestamp: 2026-09-07T13-36

Task: [P5-T8]

Batch B7 contents: production `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.
No test file: this batch owns none, so stage 3 runs over the two suites that exercise the edited file,
named by [P5-T7].

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (8 paths, MD5 `e79710ead813cfa4eb84f3318360f967`):

```
 M .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
 M .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b6-toolchain.2026-09-07T13-24.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-claude-preimplementation.2026-09-07T13-17.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-codex-preimplementation.2026-09-07T13-31.md
```

Porcelain capture AFTER the formatter: byte-identical to the capture above. `diff before after`
exited 0.

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observation beyond the exit code: the edited Codex file's SHA-256 is
`427ca3034a7268ea37ee176dcc990f3dbb113a143d15b3d2e0af0236d091a9bb` both before and after the
formatter ran, and its line count is 500 both before and after, so the formatter changed no byte and
did not push the file past its cap.

## Stage 2 — linting

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Result: `ok: true`, equivalent to a repository-wide total of **0** diagnostics.

| Measure | Value |
| --- | --- |
| Error-severity diagnostics on the files this batch touched | 0 |
| Repository-wide total | 0 |
| [P0-T6] baseline repository-wide total | 0 |
| At or below baseline? | yes (equal) |

## Stage 3 — targeted Pester

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-suite
results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after stages 1
and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 23 | **0** | 0 | 0 |
| `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 59 | **0** | 0 | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | 43 | **0** | 0 | 0 |

### Reconciliation of the folder-wide failure count

`tests/scripts/codex-hooks`: 731 tests, **1** failure, 0 errors — down from **15** at the batch B5
gate.

- 1 from `codex-pretooluse-integration.Tests.ps1`, case `allows every registered handler for every
  tool name its own matcher admits` — the out-of-inventory, out-of-scope environment-dependent
  failure the batch B1 artifact identified by name and traced to `enforce-epic-wave-barrier.ps1`
  reading the live epic checkpoint.

Every other failing name is gone. The drop of fourteen is exactly the Codex-side inventory rows this
batch closes: rows 20 through 32 and row 34.

`legacy-codex-hook-contracts.Tests.ps1` is recorded above because it is the mechanism that enforces
the 500-line cap and the root-versus-bundle SHA-256 byte-identity for every Codex hook, and it drives
each hook as a child process. Its zero failures independently confirm both the cap and the [P5-T6]
mirror, and confirm that the two new dot-source lines resolve at run time.

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `427ca3034a7268ea37ee176dcc990f3dbb113a143d15b3d2e0af0236d091a9bb` | 500 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `427ca3034a7268ea37ee176dcc990f3dbb113a143d15b3d2e0af0236d091a9bb` | 500 |

Equal, and both at the 500-line cap, which satisfies the at-or-under-500 constraint. The file entered
this batch at 495 lines and the edit added exactly five: two dot-source lines, one comment line, and
two assignment statements. No helper body was added to this file; the helper logic it calls lives in
the two parser siblings, as [P5-T5] requires.

## Batch budget reset (closes B7, opens B8)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.codex/hooks/enforce-orchestration-preimplementation-gate.ps1"
  ],
  "testFiles": []
}
```

Only one production entry is recorded because the bundle mirror was written with `cp`, which does not
pass through the PreToolUse hook. Batch B7's real file count is 2 production and 0 test files, under
the 3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files.

Output Summary: batch B7 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; before and after porcelain captures share MD5
`e79710ead813cfa4eb84f3318360f967` and the edited file's SHA-256 and 500-line count are unchanged
across the formatter run. Stage 2 analyze returned `ok: true`, equal to **0** repository-wide
diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports **0 failures** for both named
Codex preimplementation-gate suites (23 and 59 tests) and for `legacy-codex-hook-contracts.Tests.ps1`
(43 tests); the folder-wide count fell from 15 to 1, the fourteen-row drop being exactly the inventory
rows this batch closes, and the single remaining failure is the documented ambient-state-dependent
case. No stage failed and no stage rewrote a file, so no restart from stage 1 was required. The
closing batch-budget reset exited 0.
