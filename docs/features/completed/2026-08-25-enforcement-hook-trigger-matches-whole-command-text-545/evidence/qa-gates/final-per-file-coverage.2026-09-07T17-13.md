# [P13-T4] Final per-file line-coverage gate

Timestamp: 2026-09-07T17-13

Command:

```
gh workflow run .github/workflows/_poshqc.yml    # dispatched by the orchestrator
gh run watch 34145103168
# per-file percentages read by package-qualified selection from the artifacts/pester/powershell-coverage.xml
# emitted by that run; the figures are the ones recorded in [P13-T3] and [P12-T9]
```

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `pwsh` is not invocable anywhere in this session, so the self-hosted PoshQC
command the plan names could not be run locally. The `mcp__drm-copilot__run_poshqc_test` runner was
deliberately **not** substituted for the coverage figure, because it resolves its runsettings from
the installed VS Code extension rather than from this checkout and would therefore omit the eight
`CodeCoverage.Path` entries this change added. The measuring route was a CI dispatch of
`.github/workflows/_poshqc.yml`, which imports the same self-hosted
`scripts/powershell/PoshQC/PoshQC.psm1` and resolves the same
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` from the checked-out branch. This is a
route substitution, not a measurement substitution.

## Source run

| Field | Value |
|---|---|
| Route | CI dispatch of `.github/workflows/_poshqc.yml` |
| Run id | `34145103168` |
| Run outcome | watched to completion with a zero exit status; full Pester suite green |
| Measured at commit | `5903d0c7` |
| Source artifact | `artifacts/pester/powershell-coverage.xml` emitted by that run |
| Reading method | package-qualified selection |

This is the same run [P13-T3] read its aggregate figure from, so the per-file gate and the aggregate
describe one measurement of one commit.

## Selection method

Each percentage is the `counter` element whose `type` is `LINE`, on the `sourcefile` element whose
`name` equals the bare filename, selected within the enclosing `package` element whose `name` ends
with that file's directory. Percentage = `covered / (covered + missed)`.

Bare-filename selection alone would be ambiguous, because ten of the filenames below exist under
both `.claude/hooks` and `.codex/hooks` in this report. The package qualification resolves it, and
the same qualification was used for the [P0-T9] baseline and the [P12-T8] post-change measurement,
so the three are directly comparable.

## Gate result: every changed or added canonical production PowerShell file

Threshold: line coverage at or above 85.

| # | Canonical production file | Covered | Missed | Percent | Gate |
|---|---|---|---|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` | 176 | 4 | 97.7778 | **PASS** |
| 2 | `.claude/hooks/hook-command-invocation.ps1` | 122 | 2 | 98.3871 | **PASS** |
| 3 | `.codex/hooks/hook-command-scanner.ps1` | 180 | 0 | 100.0000 | **PASS** |
| 4 | `.codex/hooks/hook-command-invocation.ps1` | 120 | 4 | 96.7742 | **PASS** |
| 5 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 136 | 18 | 88.3117 | **PASS** |
| 6 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 164 | 2 | 98.7952 | **PASS** |
| 7 | `.claude/hooks/enforce-promotion-mcp-only.ps1` | 56 | 4 | 93.3333 | **PASS** |
| 8 | `.codex/hooks/enforce-promotion-mcp-only.ps1` | 65 | 0 | 100.0000 | **PASS** |
| 9 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 64 | 3 | 95.5224 | **PASS** |
| 10 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 24 | 2 | 92.3077 | **PASS** |
| 11 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94 | 5 | 94.9495 | **PASS** |
| 12 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 67 | 1 | 98.5294 | **PASS** |
| 13 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 69 | 5 | 93.2432 | **PASS** |
| 14 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 114 | 4 | 96.6102 | **PASS** |
| 15 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 66 | 1 | 98.5075 | **PASS** |
| 16 | `.claude/hooks/validate-bash.ps1` | 83 | 5 | 94.3182 | **PASS** |
| 17 | `.codex/hooks/validate-bash.ps1` | 73 | 0 | 100.0000 | **PASS** |
| 18 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 64 | 5 | 92.7536 | **PASS** |

**18 of 18 PASS. Zero rows below 85. Zero rows missing.**

The lowest figure in the table is `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
at 88.3117 percent, which is 3.3117 points above the threshold.

Rows 1 through 4, 8, 12, 15, and 17 were absent from `CodeCoverage.Path` at baseline and now report,
which confirms the [P4-T10] registration landed and is honoured by the measuring run. Rows 6, 8, 12,
15, and 17 are the five files [P12-T9] remediated; their pre-remediation figures and the case names
added are recorded in `evidence/qa-gates/coverage-remediation.2026-09-07T16-46.md`. The remaining
thirteen rows carry covered and missed counts byte-identical to those measured in run `34139262327`
at commit `cc83c0c8`, so the remediation changed only the intended files' measurements.

## Bundle mirrors: outside the coverage denominator

`CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` holds **zero**
entries under `extensions/drm-copilot/resources/`. Every bundle mirror of a file in the table above
therefore carries the outside-the-denominator entry.

| # | Bundle mirror | Coverage entry |
|---|---|---|
| 1 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 3 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 6 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 7 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 8 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 9 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 10 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 11 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 12 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 13 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 14 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 15 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 16 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 17 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| 18 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |

Parity for the Claude mirrors is enforced by content comparison in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; parity for the Codex mirrors
is enforced by SHA-256 comparison in
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Both mechanisms are recorded
green in `evidence/qa-gates/parity-mechanisms.2026-09-07T15-57.md`, and the recomputed hash pairs
are in `evidence/other/pair-hash-parity.2026-09-07T15-52.md`, which [P13-T1] confirmed still
describes the final tree.

## No aggregate threshold

No threshold is asserted against the repository-wide aggregate. The aggregate for this run is
95.4618 percent, recorded in [P13-T3] for information only; this gate is evaluated per file against
the 18 rows above and is not conditioned on the aggregate.

## Branch coverage: exempt, with the reason recorded

`.claude/rules/quality-tiers.md` sets a uniform branch-coverage threshold of 75 percent for every
language whose coverage tooling measures branch coverage, and exempts PowerShell explicitly.
**Pester does not measure branch coverage in any output format.** The JaCoCo-shaped report it emits
carries `counter` elements whose `type` is `INSTRUCTION`, `LINE`, `METHOD`, or `CLASS`, enumerated
directly from the emitted report; no `BRANCH` counter is produced at any level,
so a branch percentage has no source to be read from. The exemption is a capability limit on an
unevaluable threshold, not a licence to exclude files from measurement: all 18 canonical production
files above remain in the line-coverage denominator, and no `CodeCoverage.Path` entry was removed or
altered by this change.

## Output Summary

Per-file line-coverage gate over the 18 changed or added canonical production PowerShell files:
**18 of 18 at or above 85 percent, zero failures, zero rows missing**. Lowest figure 88.3117
percent on `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`. All 18 bundle mirrors
carry the outside-the-denominator literal. No threshold is asserted against the repository-wide
aggregate. Branch coverage is not gated, because Pester emits no `BRANCH` counter; the reason is
recorded above. Figures read by package-qualified selection from CI run `34145103168` at commit
`5903d0c7`.
