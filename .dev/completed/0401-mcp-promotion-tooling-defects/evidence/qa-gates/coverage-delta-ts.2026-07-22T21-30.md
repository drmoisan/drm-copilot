# Coverage Delta — TypeScript (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

Compared commands:
- Pre-remediation (P0-T6 baseline and evidence/qa-gates/coverage-delta-ts.2026-07-22T20-17.md): npm run test:coverage
- Post-remediation (P3-T4): npm run test:coverage -- --testMatch '<forward-slashed absolute test glob>'

EXIT_CODE: 0

Output Summary:
- Baseline: line 96.34% / branch 89.21% (per pre-remediation artifact); P0-T6 measured line 96.33% (37622/39053) / branch 89.21% (5201/5830).
- Post-change: line 96.33% (37643/39074) / branch 89.21% (5201/5830).
- Line coverage 96.33% >= 85% floor. Branch coverage 89.21% >= 75% floor. Both thresholds met.
- No regression: branch percentage unchanged (89.21%); line percentage unchanged at 96.33%. The statement/line denominator rose by 21 (39053 -> 39074) because the pure module split relocated 105 definition lines into a new 123-line sibling with a docblock; both R1 files are fully covered so the ratio is preserved.
- Per-file coverage of the two R1 files (from coverage/lcov.info):
  - src/mcp-repo-automation-tool-definitions.ts: lines 402/402 = 100.00%; no branch constructs (BRF 0).
  - src/mcp-repo-automation-tool-definitions-poshqc.ts: lines 123/123 = 100.00%; no branch constructs (BRF 0).
- Verdict: line >= 85%, branch >= 75%, no regression versus 96.34%/89.21% beyond the reporting-denominator shift attributable to the pure module split. PASS.
