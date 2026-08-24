# Coverage Delta and Threshold Verification — issue #535

Timestamp: 2026-08-23T22-14

Command: extraction of per-file `LINE` counters from the runner-generated
CoverageGutters/JaCoCo artifact `artifacts/pester/powershell-coverage.xml`, produced by the
`mcp__drm-copilot__run_poshqc_test` runs recorded in P0-T8, P0-T9, and P4-T3. Per-file
values are read from the JaCoCo per-file counters, never from the aggregate console summary.

Coverage instrumentation is supplied by the standing `CodeCoverage.Path` allow-list in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, which already registers both
canonical hook files (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` at
line 198, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` at line 131). The
MCP test tool exposes no per-invocation coverage parameter.

EXIT_CODE: 0

Applicable threshold: line coverage >= 85%, uniform across T1-T4 per
`.claude/rules/quality-tiers.md`. Pester does not measure branch coverage, so no
branch-coverage gate applies to PowerShell.

## (a) Baseline Coverage

| File | Source | Covered / Total | Line coverage |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | P0-T8 (`evidence/baseline/baseline-pester-claude-hooks.2026-08-23T21-28.md`) | 76 / 86 | 88.37% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | P0-T9 (`evidence/baseline/baseline-pester-codex-hooks.2026-08-23T21-30.md`) | 98 / 98 | 100.00% |

## (b) Post-Change Coverage

Source: P4-T3 (`evidence/qa-gates/final-pester.2026-08-23T22-12.md`), run over
`tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` with 1532 tests and 0 failures.

| File | Covered / Total | Line coverage |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 99 / 110 | 90.00% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 121 / 122 | 99.18% |

## (c) Changed-Code Result

| File | Threshold >= 85% | Covered lines vs baseline | Verdict |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 90.00% -> MET | 76 -> 99 (+23); no previously covered line lost coverage | PASS. Percentage improved from 88.37% to 90.00%. |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 99.18% -> MET | 98 -> 121 (+23); all 98 originally covered lines remain covered | PASS with one residual, stated below. |

Changed-code detail. The fix adds 24 measurable lines to each canonical hook. On the
`.codex` copy, 23 of the 24 new lines are covered and one is not: line 174, the
`Write-Debug` inside the extraction-failure catch of `Test-ImplementationDelegation`.

- No regression in the sense the rule protects: every line covered at baseline is still
  covered. Covered-line count rose from 98 to 121. The 100.00% -> 99.18% percentage change
  is caused entirely by the denominator growing by 24 new lines, not by any previously
  covered line becoming uncovered.
- The residual line is a fail-closed defensive branch. Covering it requires a payload whose
  property getter throws; such a payload also makes the subsequent
  `ConvertTo-Json -Depth 20 -Compress` throw, so the branch is not reachable through the
  pure decision seam without a contrived construct that would itself be a determinism risk.
  Two of the three originally uncovered new lines (140, the null-payload guard, and 151, the
  marker-missing branch) were covered by the P4-T3 iteration-1 remediation.
- The `.claude` copy carries the analogous uncovered `Write-Debug` line (157) and still
  improved overall, because its pre-existing uncovered set is larger.

## (d) Mirror-Inheritance Evidence

Neither bundle copy is executed by any test suite, so each inherits its canonical copy's
measurement through SHA256 byte-identity, not through a hunk comparison.

| Bundle copy | Inherits from | Binding evidence | SHA256 |
| --- | --- | --- | --- |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (90.00%) | P2-T2 (`evidence/other/claude-pair-hash.2026-08-23T21-48.md`) | `F57FAE11FB5E98DC3D06214922A1B1CA4AE200D014873CADF03312042537493C` (equal on both paths) |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (99.18%) | P3-T2 (`evidence/other/codex-pair-hash.2026-08-23T21-58.md`) and re-verified at P3-T4 and both P4-T1 iterations | `E8A2DFC7F7F47219B19F957EBF473489C02B4F0C3CFDB745889B4E08AD1D4F37` (equal on both paths) |

Because each pair is byte-identical, the canonical measurement applies to the bundled copy
without qualification: the two files are the same bytes, so they have the same executable
lines and the same coverage.

Output Summary: Both changed production hook files meet the uniform >= 85% line-coverage
threshold (90.00% and 99.18%). No previously covered line lost coverage in either file; the
covered-line count rose by 23 in each. Both bundle mirrors inherit their canonical
measurement via verified SHA256 equality. One new defensive line in the `.codex` copy
(line 174) remains uncovered and is documented above with the reason it is not reachable
through the pure seam. All four sections are present and every threshold is met.
