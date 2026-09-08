# Batch B9 — batch toolchain gate (Codex promotion hook, canonical + bundle + new suite)

Timestamp: 2026-09-07T14-02

Task: [P6-T8]

Batch B9 contents: production `.codex/hooks/enforce-promotion-mcp-only.ps1` and
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1`;
test `tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (17 paths, MD5 `8c6df65e316cb27fb16ee64a19d71fb8`):

```
 M .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
 M .claude/hooks/enforce-promotion-mcp-only.ps1
 M .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
 M .codex/hooks/enforce-promotion-mcp-only.ps1
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b6-toolchain.2026-09-07T13-24.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b7-toolchain.2026-09-07T13-36.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b8-toolchain.2026-09-07T13-52.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at6-deny-preservation.2026-09-07T13-41.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-claude-preimplementation.2026-09-07T13-17.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-codex-preimplementation.2026-09-07T13-31.md
?? tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
?? tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
```

Porcelain capture AFTER the formatter: byte-identical to the capture above. `diff before after`
exited 0.

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observation beyond the exit code: the edited hook's SHA-256 is
`b768e096d612f894363e09cb7c7d3be1578210dc5d0460135bfe12897e4ba6b8` and the new suite's is
`190b93fedb4477669727324226a6b09fd94ffc6a0f76d596bcbd31c8ecfe4a93`, both unchanged across the
formatter run.

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

## Stage 3 — targeted Pester over the test file this batch owns

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-suite
results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after stages 1
and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` (owned by this batch) | 8 | **0** | 0 | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | 43 | **0** | 0 | 0 |

All eight cases pass, matching the Claude sibling case for case:

| Case | Result |
| --- | --- |
| allows a heredoc whose JSON body names promotion tools as receipt values | PASS |
| denies a genuine promotion-script invocation | PASS |
| denies the adjacent gh issue create spelling | PASS |
| denies the adjacent gh issue new spelling | PASS |
| denies a single-segment gh api issues write with an explicit POST method | PASS |
| denies a relocating gh issue create carrying a repo global option | PASS |
| denies a relocating gh issue new carrying the short repo global option | PASS |
| allows a relocating gh issue list | PASS |

`legacy-codex-hook-contracts.Tests.ps1` is recorded because it enforces the 500-line cap and the
root-versus-bundle SHA-256 byte-identity of every Codex hook and drives each hook as a child process.
Its zero failures independently confirm the [P6-T6] mirror, the 288-line count, and that the two new
dot-source lines resolve at run time. It also carries the case
`emits the current PreToolUse deny envelope for shell and patch violations`, whose
`enforce-promotion-mcp-only.ps1` row drives `gh issue create --title bad` through the real hook
process and asserts the `PROMOTION_MCP_ONLY_BLOCKED` marker; that row still passes.

### Reconciliation of the folder-wide failure count

`tests/scripts/codex-hooks`: 739 tests, **1** failure, 0 errors — unchanged in composition from the
batch B7 gate. The test total rose by 8, the size of the new suite.

- 1 from `codex-pretooluse-integration.Tests.ps1`, case `allows every registered handler for every
  tool name its own matcher admits` — the out-of-inventory, out-of-scope environment-dependent
  failure traced to `enforce-epic-wave-barrier.ps1` reading the live epic checkpoint.

Batch B9 closes no row of the known-red inventory directly; the two rows Phase 6 closes, rows 3 and
5, are Claude-side acceptance cases already closed by batch B8 and re-confirmed by [P6-T9].

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.codex/hooks/enforce-promotion-mcp-only.ps1` | `b768e096d612f894363e09cb7c7d3be1578210dc5d0460135bfe12897e4ba6b8` | 288 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | `b768e096d612f894363e09cb7c7d3be1578210dc5d0460135bfe12897e4ba6b8` | 288 |

Equal, and both at or under the 500-line cap. The new test suite measures 183 lines.

## Batch budget reset (closes B9, opens B10)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.codex/hooks/enforce-promotion-mcp-only.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. Batch B9's real file count is 2 production and 1 test file, under the
3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files.

Output Summary: batch B9 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; before and after porcelain captures share MD5
`8c6df65e316cb27fb16ee64a19d71fb8` and both edited files' SHA-256 values are unchanged across the
formatter run. Stage 2 analyze returned `ok: true`, equal to **0** repository-wide diagnostics and
equal to the [P0-T6] baseline of 0. Stage 3 reports **8 tests / 0 failures** for the suite this batch
owns and **43 tests / 0 failures** for `legacy-codex-hook-contracts.Tests.ps1`; the single remaining
folder-wide failure is the documented ambient-state-dependent case in
`codex-pretooluse-integration.Tests.ps1`. No stage failed and no stage rewrote a file, so no restart
from stage 1 was required. The closing batch-budget reset exited 0.
