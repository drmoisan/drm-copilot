# Coverage Delta Verification (Issue #489)

Timestamp: 2026-08-18T15-05

Compares the Phase 0 baseline figures (P0-T8, P0-T10, P0-T13) against the
Phase 8 post-change figures (P8-T4, P8-T8, P8-T13) and the changed-code figures
(P8-T5, P8-T8 per-file, P8-T13 per-file). Every value below is a measured
number; no placeholder is recorded.

## Aggregate coverage by language

| Language | Metric | Baseline | Post-change | Delta | Threshold | Met |
| --- | --- | --- | --- | --- | --- | --- |
| Python | line | 92.40% (13479/14587) | 92.43% (13527/14635) | +0.03 pp | >= 85% | yes |
| Python | branch | 89.60% (4801/5358) | 89.63% (4815/5372) | +0.03 pp | >= 75% | yes |
| PowerShell | line | 95.58% (7,486 commands, 65 files) | 95.83% (7,555 commands, 65 files) | +0.25 pp | >= 85% | yes |
| PowerShell | branch | not measured by Pester | not measured by Pester | n/a | exempt | n/a |
| TypeScript | line | 96.61% | 96.61% (41750/43212) | 0.00 pp | >= 85% | yes |
| TypeScript | branch | 89.96% | 89.96% (5902/6560) | 0.00 pp | >= 75% | yes |

Python branch figures use the same formula the Phase 0 baseline artifact used,
`(num_branches - num_partial_branches) / num_branches`, so the two sides of the
delta are comparable. Coverage.py's stricter `covered_branches / num_branches`
variant reads 84.90% post-change; the baseline did not record that variant, so
it is noted for information only and is still above the 75% threshold.

PowerShell branch coverage is exempt from the threshold per
`.claude/rules/quality-tiers.md`: Pester does not measure branch coverage in any
output format. This is a threshold exemption only — every PowerShell production
file, including the new `BlastRadiusNormalization.psm1`, remains in the line
coverage denominator.

## Changed-code coverage

### Python (P8-T5, dotted-module form)

| Module | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 100% | 100% |
| `scripts/dev_tools/_blast_radius_guards.py` | 100% | 100% |
| `scripts/dev_tools/_blast_radius_normalization.py` | 100% | 100% |
| `scripts/dev_tools/_blast_radius_validation.py` | 100% | 100% |
| `scripts/dev_tools/compute_blast_radius.py` | 100% | 100% |

312 statements, 0 missed; 106 branches, 0 partial.

### PowerShell (P8-T8 supplementary worktree-resolved run)

| Module | Line |
| --- | --- |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 100.00% (109/109) |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 100.00% (80/80) |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 100.00% (93/93) |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 100.00% (69/69) |
| `.claude/lib/blast-radius/BlastRadiusNormalization.psm1` | 100.00% (50/50) |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 96.97% (96/99) |

### TypeScript (P8-T13, read from lcov)

| File | Line | Branch |
| --- | --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | 100.00% (452/452) | 95.92% (47/49) |

## Conclusion

- No regression on changed lines: every changed production module measures at or
  above its pre-change coverage, and eleven of the twelve changed modules
  measure 100% line coverage.
- All applicable thresholds are met: Python line 92.43% / branch 89.63%,
  PowerShell line 95.83%, TypeScript line 96.61% / branch 89.96%; per-file
  changed-code figures are 100% (Python), 100% (the new PowerShell module), and
  100% line / 95.92% branch (TypeScript).
- Every required numeric value is available, so this plan's coverage outcome is
  PASS rather than remediation-required.

## Coverage-surface registration (Family 2 obligations)

Both surfaces this plan relies on are registered and measurable as written:

- `extensions/drm-copilot/jest.config.cjs` now carries the exact-path key
  `"./src/lib/push-down/claude-blast-radius-derive-core.ts"` with
  `{ lines: 85, branches: 75 }`. The map has 37 exact-path entries (36 before)
  and declares no `global` key, so an unregistered file would be structurally
  unenforced.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled
  mirror both list `.claude/lib/blast-radius/BlastRadiusNormalization.psm1`; each
  file now carries 6 blast-radius entries (5 before), and the worktree
  runsettings declares 66 total paths, all of which resolve to an existing file.
