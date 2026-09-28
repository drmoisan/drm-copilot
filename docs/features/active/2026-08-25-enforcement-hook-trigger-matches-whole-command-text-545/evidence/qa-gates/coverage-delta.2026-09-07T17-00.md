# [P12-T10] Coverage delta, baseline to post-change

Timestamp: 2026-09-07T17-00

Command:

```
# baseline column, read from the [P0-T9] artifact
cat docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/baseline/baseline-selfhosted-per-file-coverage.2026-09-07T10-57.md

# post-change column, read from the [P12-T8] artifact and, for the five remediated files, from the [P12-T9] second CI measurement
cat docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/post-change-per-file-coverage.2026-09-07T16-25.md
cat docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/coverage-remediation.2026-09-07T16-46.md
```

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: this task performs no measurement of its own. It is an arithmetic
reconciliation of two figures already recorded. Both source measurements were produced by CI
dispatch of `.github/workflows/_poshqc.yml` rather than by a local `pwsh` invocation, because
`pwsh` is not invocable anywhere in this session; that workflow imports the same self-hosted
`scripts/powershell/PoshQC/PoshQC.psm1` and resolves the same
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` from the checked-out branch, so the
measuring code and the settings file are the ones the plan names.

## Sources of the two columns

| Column | Source artifact | Route | Run id | Commit |
|---|---|---|---|---|
| Baseline | `evidence/baseline/baseline-selfhosted-per-file-coverage.2026-09-07T10-57.md` ([P0-T9]) | report from the [P0-T7] run | n/a (local MCP route disclosed in [P0-T7]) | `288ca214` base state |
| Post-change, thirteen unremediated files | `evidence/qa-gates/post-change-per-file-coverage.2026-09-07T16-25.md` ([P12-T8]) | CI dispatch of `_poshqc.yml` | `34139262327` | `cc83c0c8` |
| Post-change, five remediated files | `evidence/qa-gates/coverage-remediation.2026-09-07T16-46.md` ([P12-T9]) | CI dispatch of `_poshqc.yml` | `34145103168` | `5903d0c7` |

The two CI runs agree byte-for-byte on the covered and missed counts of all thirteen files that
[P12-T9] did not target, so the post-change column is a single consistent measurement of the final
commit `5903d0c7` and not a splice of two disagreeing runs.

Both columns use the same package-qualified selection: the `counter` element whose `type` is `LINE`
on the `sourcefile` element whose `name` equals the bare filename, taken inside the enclosing
`package` element whose `name` ends with `.claude/hooks` or `.codex/hooks` respectively.

## Delta table, one row per changed or added canonical production file

Percentages are line coverage. The difference column is `post-change minus baseline`, computed only
where both cells are numeric; where the baseline cell carries the absent literal, the difference is
not defined and is recorded as `n/a (no numeric baseline)`.

| # | Canonical production file | Baseline | Post-change | Difference |
|---|---|---|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` | absent from CodeCoverage.Path at baseline | 97.7778 | n/a (no numeric baseline) |
| 2 | `.claude/hooks/hook-command-invocation.ps1` | absent from CodeCoverage.Path at baseline | 98.3871 | n/a (no numeric baseline) |
| 3 | `.codex/hooks/hook-command-scanner.ps1` | absent from CodeCoverage.Path at baseline | 100.0000 | n/a (no numeric baseline) |
| 4 | `.codex/hooks/hook-command-invocation.ps1` | absent from CodeCoverage.Path at baseline | 96.7742 | n/a (no numeric baseline) |
| 5 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 88.0000 | 88.3117 | +0.3117 |
| 6 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 84.5679 | 98.7952 | +14.2273 |
| 7 | `.claude/hooks/enforce-promotion-mcp-only.ps1` | 92.1569 | 93.3333 | +1.1764 |
| 8 | `.codex/hooks/enforce-promotion-mcp-only.ps1` | absent from CodeCoverage.Path at baseline | 100.0000 | n/a (no numeric baseline) |
| 9 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 95.3125 | 95.5224 | +0.2099 |
| 10 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 91.3043 | 92.3077 | +1.0034 |
| 11 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 95.6989 | 94.9495 | -0.7494 |
| 12 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | absent from CodeCoverage.Path at baseline | 98.5294 | n/a (no numeric baseline) |
| 13 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 94.1176 | 93.2432 | -0.8744 |
| 14 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 96.4286 | 96.6102 | +0.1816 |
| 15 | `.codex/hooks/enforce-epic-merge-gate.ps1` | absent from CodeCoverage.Path at baseline | 98.5075 | n/a (no numeric baseline) |
| 16 | `.claude/hooks/validate-bash.ps1` | 90.3846 | 94.3182 | +3.9336 |
| 17 | `.codex/hooks/validate-bash.ps1` | absent from CodeCoverage.Path at baseline | 100.0000 | n/a (no numeric baseline) |
| 18 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 91.4894 | 92.7536 | +1.2642 |

## Row accounting

- 18 rows, one per changed or added canonical production PowerShell file.
- 10 rows carry a numeric baseline and therefore a numeric difference.
- 8 rows carry the literal `absent from CodeCoverage.Path at baseline`: the four new parser files,
  which did not exist at baseline, and the four Codex canonical hooks that [P0-T9] recorded as not
  declared in `CodeCoverage.Path`. [P4-T10] added the four parser entries; the four Codex hooks
  entered the denominator through the same registration work, which is why they now report.
- Of the 10 numeric differences, 8 are positive and 2 are negative.

## The two negative differences

`.claude/hooks/enforce-epic-worktree-removal-gate.ps1` moves from 95.6989 to 94.9495 and
`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` from 94.1176 to 93.2432. In both cases
the covered count rose and the missed count rose with it: the first went from 89 covered / 4 missed
to 94 covered / 5 missed, the second from 64 covered / 4 missed to 69 covered / 5 missed. Each file
gained executable lines from the command-detection call-site change, and one of the added lines in
each is not reached by the existing suites, so the ratio fell slightly while the absolute covered
count rose. Both files remain well above the 85 percent line threshold. The report records counts,
not line identities, across two separate runs, so this artifact does not claim that no individual
line lost coverage; it records only that the covered count rose in both files.

## No aggregate threshold is asserted

This artifact asserts no threshold against the repository-wide aggregate line coverage. The
repository-wide figures are recorded elsewhere for information only: `94.0209` percent at commit
`cc83c0c8` (run `34139262327`) and `95.4618` percent at commit `5903d0c7` (run `34145103168`). The
gate this feature is measured against is the per-file gate in [P13-T4], applied to the 18 files
above, and nothing in this artifact is conditioned on the aggregate moving in any direction.

## Bundle mirrors

The 18 bundle mirrors under `extensions/drm-copilot/resources/` are not rows in this table, because
the task scopes the table to canonical production files. `CodeCoverage.Path` holds zero entries
under `extensions/drm-copilot/resources/`, so every mirror is outside the coverage denominator in
both the baseline and the post-change measurement, and a difference is not defined for any of them.
Their parity with the canonical copies is enforced by content comparison on the Claude side and by
SHA-256 comparison on the Codex side, recorded in
`evidence/qa-gates/parity-mechanisms.2026-09-07T15-57.md`.

## Output Summary

18 rows recorded, one per changed or added canonical production PowerShell file, each carrying all
three required columns. 10 numeric baseline percentages produce 10 numeric differences, 8 positive
and 2 negative; 8 rows carry the literal `absent from CodeCoverage.Path at baseline` and record no
difference. Every post-change percentage is at or above 85. No threshold is asserted against the
repository-wide aggregate.
