# Coverage Delta Verification

- Timestamp: 2026-06-21T12-06
- Issue: #221
- Task: [P2-T4]
- Target file: scripts/dev-tools/Invoke-FullRelease.ps1

## Command

```
Invoke-Pester -Configuration (CodeCoverage.Path = scripts/dev-tools/Invoke-FullRelease.ps1; OutputFormat = JaCoCo)
```

- EXIT_CODE: 0
- Baseline artifact: ../baseline/poshqc-test.2026-06-21T12-06.md (artifacts/pester/fullrelease-baseline-coverage.xml)
- Post-change artifact: ./poshqc-test.2026-06-21T12-06.md (artifacts/pester/fullrelease-postchange-coverage.xml)

## Coverage Comparison

| Metric | Baseline | Post-change | Delta | Threshold | Status |
|---|---|---|---|---|---|
| LINE coverage | 91.67% (66/72) | 92.11% (70/76) | +0.44 pp | >= 85% | PASS |
| INSTRUCTION coverage | 88.54% (85/96) | 89.22% (91/102) | +0.68 pp | (branch proxy) | PASS |
| METHOD coverage | 62.50% (5/8) | 62.50% (5/8) | 0.00 pp | n/a | unchanged |

## Branch Coverage Note

The PoshQC Pester toolchain (Pester 5.6.1) does not emit a distinct JaCoCo BRANCH counter; its
coverage model is command/line based. Instruction coverage (89.22% post-change) is the closest
available decision-path-discriminating metric and increased relative to baseline. Line coverage
92.11% exceeds the >= 85% threshold. The >= 75% branch-coverage threshold cannot be measured with a
distinct branch counter under this toolchain; instruction coverage of 89.22% and full coverage of
both decision arms of the inserted push step (success and failure) provide the available evidence
that the decision logic is exercised.

## Changed-Line Coverage

The inserted push step occupies lines 248-252 of `scripts/dev-tools/Invoke-FullRelease.ps1`:
- line 248 (push call), 249 (ExitCode check), 250 (diagnostic), 251 (return 1) — all covered, 0 missed instructions.
- line 252 (closing brace) — no instructions.

Both decision arms are covered:
- success arm: updated "bumps both manifests and opens a PR against main" test (push returns ExitCode 0; gh pr create proceeds).
- failure arm: new "returns 1 and does not open a PR when 'git push -u origin <branch>' fails" test (push returns ExitCode 1; returns 1; gh not invoked).

No coverage regression on changed lines (0 missed instructions on the inserted step).

## Verdict

- Line coverage >= 85%: PASS (92.11%).
- No regression on changed lines: PASS (inserted step fully covered).
- Branch coverage >= 75%: not measurable as a distinct counter under the Pester toolchain; instruction
  coverage 89.22% and full coverage of both decision arms of the change recorded as the available evidence.
- Overall: thresholds met on all measurable metrics; outcome is PASS (no remediation required).
