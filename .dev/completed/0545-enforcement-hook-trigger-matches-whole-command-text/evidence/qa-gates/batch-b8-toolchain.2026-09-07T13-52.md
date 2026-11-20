# Batch B8 — batch toolchain gate (Claude promotion hook, canonical + bundle + new suite)

Timestamp: 2026-09-07T13-52

Task: [P6-T4]

Batch B8 contents: production `.claude/hooks/enforce-promotion-mcp-only.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1`;
test `tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (13 paths, MD5 `8676ae4beb885c448d41fc76f0d5a890`):

```
 M .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
 M .claude/hooks/enforce-promotion-mcp-only.ps1
 M .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b6-toolchain.2026-09-07T13-24.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b7-toolchain.2026-09-07T13-36.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-at6-deny-preservation.2026-09-07T13-41.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-claude-preimplementation.2026-09-07T13-17.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-codex-preimplementation.2026-09-07T13-31.md
?? tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1
```

Porcelain capture AFTER the formatter: byte-identical to the capture above. `diff before after`
exited 0.

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observation beyond the exit code: the edited hook's SHA-256 is
`924ad2efa174972acd7749066eb4fc07885e9ccdac4286a537419d8ec997406d` and the new suite's is
`114e42e5249718f04822535696e7796491f9d20956caadb852e675f13628bc08`, both unchanged across the
formatter run, so the formatter changed no byte in either file.

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

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 5 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` (owned by this batch) | 8 | **0** | 0 | 0 |
| `enforce-promotion-mcp-only.Tests.ps1` (pre-existing, exercises the edited hook) | 29 | **0** | 0 | 0 |

The pre-existing suite is recorded because it holds the 29 assertions the edit must not weaken,
including `blocks gh api repos/owner/repo/issues -X POST -f title=foo`,
`allows gh api repos/owner/repo/issues with no method (defaults to GET)`, `allows gh issue list`, and
`allows gh issue view 10`. All 29 pass unmodified.

### Reconciliation of the folder-wide failure count

`tests/scripts/claude-hooks`: 1473 tests, **5** failures, 0 errors — down from **7** at the batch B6
gate. The test total rose by 8, the size of the new suite.

- 4 from `hook-command-parser.AcceptanceCases.Tests.ps1` — known-red inventory rows 1, 2, 4, and 6
  (AT-1, AT-2, AT-4, AT-7), closed by Phases 8 and 9.
- 1 from `enforce-pr-author-skill.Tests.ps1` — pre-existing at baseline, recorded in the known-red
  inventory appendix, out of inventory and out of scope.

4 + 1 = 5. Rows 3 and 5 (AT-3 and AT-5) are the two rows batch B8 closes; both now pass.

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | `924ad2efa174972acd7749066eb4fc07885e9ccdac4286a537419d8ec997406d` | 303 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | `924ad2efa174972acd7749066eb4fc07885e9ccdac4286a537419d8ec997406d` | 303 |

Equal, and both at or under the 500-line cap. The new test suite measures 197 lines.

## Batch budget reset (closes B8, opens B9)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.claude/hooks/enforce-promotion-mcp-only.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. Batch B8's real file count is 2 production and 1 test file, under the
3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files.

Output Summary: batch B8 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; before and after porcelain captures share MD5
`8676ae4beb885c448d41fc76f0d5a890` and both edited files' SHA-256 values are unchanged across the
formatter run. Stage 2 analyze returned `ok: true`, equal to **0** repository-wide diagnostics and
equal to the [P0-T6] baseline of 0. Stage 3 reports **8 tests / 0 failures** for the suite this batch
owns and **29 tests / 0 failures** for the pre-existing promotion suite; the folder-wide count fell
from 7 to 5, the two-row drop being inventory rows 3 and 5 (AT-3 and AT-5). No stage failed and no
stage rewrote a file, so no restart from stage 1 was required. The closing batch-budget reset
exited 0.
