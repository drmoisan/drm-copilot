# Baseline file line counts (remediation cycle 1)

Timestamp: 2026-08-30T00-48

Task: [P0-T5]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command (plan command text, quoted verbatim):

```
pwsh -NoProfile -Command "foreach ($p in @('tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1','tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1','extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts','.claude/hooks/enforce-powershell-batch-budget.ps1','.claude/hooks/enforce-python-batch-budget.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1','extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts')) { '{0} {1}' -f $p, (Get-Content -LiteralPath $p).Count }"
```

Executed with the working directory set to the absolute worktree path `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan states the eight paths worktree-relative; the working directory above is what resolves them.

EXIT_CODE: 0

## Observed output, verbatim

```
tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 473
tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 463
extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts 145
.claude/hooks/enforce-powershell-batch-budget.ps1 457
.claude/hooks/enforce-python-batch-budget.ps1 454
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1 457
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1 454
extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts 164
```

## Comparison against the plan's expected counts

The acceptance condition is that the eight printed counts are, in the order listed, `473`, `463`, `145`, `457`, `454`, `457`, `454`, and `164`.

| # | File | Expected | Observed | Match |
| --- | --- | --- | --- | --- |
| 1 | `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` | 473 | 473 | yes |
| 2 | `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` | 463 | 463 | yes |
| 3 | `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` | 145 | 145 | yes |
| 4 | `.claude/hooks/enforce-powershell-batch-budget.ps1` | 457 | 457 | yes |
| 5 | `.claude/hooks/enforce-python-batch-budget.ps1` | 454 | 454 | yes |
| 6 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` | 457 | 457 | yes |
| 7 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` | 454 | 454 | yes |
| 8 | `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` | 164 | 164 | yes |

All eight match. No divergence, so the `BLOCKED: baseline line counts differ from the plan` branch is not taken.

Two downstream artifacts are derived from these counts and remain valid:

- The file-size budget table in the plan, whose projected post-edit counts are 495 for the PowerShell suite and 485 for the Python suite, both under the binding 500-line cap.
- The Form D absolute line numbers 154 and 155 in `.claude/hooks/enforce-powershell-batch-budget.ps1` and 151 and 152 in `.claude/hooks/enforce-python-batch-budget.ps1`. Decision D-1 holds each hook file at its current line count precisely so these four numbers do not move between this baseline capture and the final capture.

Rows 4 and 6 carry the same count, as do rows 5 and 7. That is expected: each pair is a hook and its byte-identical bundle mirror. [P0-T6] verifies the byte-identity directly by object id rather than inferring it from equal line counts.

## Output Summary

All eight baseline line counts match the plan exactly: 473, 463, 145, 457, 454, 457, 454, 164. The tree has not moved since the plan was authored. The file-size budget table and the Form D line numbers 154, 155, 151, and 152 remain valid. `EXIT_CODE: 0`. No BLOCKED branch taken.
