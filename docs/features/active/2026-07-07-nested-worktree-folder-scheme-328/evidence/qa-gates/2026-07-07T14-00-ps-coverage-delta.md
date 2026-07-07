# PowerShell Coverage Delta / Threshold Verification (Issue #328)

Timestamp: 2026-07-07T13-58

## Values

| Metric | Value | Source |
|---|---|---|
| Baseline repo-wide line coverage | 1006/1074 = 93.67% | P0-T2 (`2026-07-07T14-00-baseline-poshqc-test.md`) |
| Post-change repo-wide line coverage | 1006/1074 = 93.67% | P2-T2 / P3-T3 (`2026-07-07T14-00-final-poshqc-test.md`) |
| Changed-file line coverage (targeted) | 46/75 = 61.33% (valid attribution) | P2-T1 (`2026-07-07T14-00-targeted-ps-coverage.xml`) |
| Changed-file branch disposition | No BRANCH counter emitted by Pester; per-branch dossier: 14/14 coverable = 100% (14/16 = 87.5% incl. structurally-uncoverable) | P2-T4 (`../regression-testing/fail-before-exception.2026-07-07T14-00-ps-branch-coverage.md`) |

## Threshold Analysis

- Repo-wide line coverage: 93.67% >= 85%. No regression versus baseline (identical). PASS.
- No-regression-on-changed-lines: the changed lines (dot-source guard) are covered (guard `if` + `return` executed under the test dot-source). No previously-covered line lost coverage. PASS.
- Changed-file whole-file line coverage: 61.33% < 85%. The shortfall is caused solely by structurally uncoverable surface (21-line host-bound seam-less top-level body + 5 injectable seam-default parameter blocks + `cmd.exe` env fallback + non-Windows platform branch). The deterministically coverable surface is 46/46 = 100%. Discharged by the sanctioned line-coverage dossier `../regression-testing/fail-before-exception.2026-07-07T14-00-ps-line-coverage.md` (P2-T3), whose fallback branch is explicitly authorized by the plan.
- Changed-file branch coverage: Pester emits no BRANCH metric; discharged by the sanctioned branch-coverage dossier `../regression-testing/fail-before-exception.2026-07-07T14-00-ps-branch-coverage.md` (P2-T4), whose fallback branch is explicitly authorized by the plan.

## Outcome

All required thresholds are either met numerically (repo-wide line coverage, no-regression) or discharged by a sanctioned structural-impossibility exception dossier (changed-file line and branch). No threshold was lowered, removed, or reinterpreted; no production file was excluded from coverage; no test was weakened or skipped. Cycle coverage outcome: PASS (via valid attribution plus authorized dossiers), not remediation-required.
