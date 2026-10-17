# Acceptance Criteria Verification (round 2, P5-T5)

Timestamp: 2026-10-17T13-11
Command: grep -c -F -e '- [x] Consumer fixture coverage:' spec.md; grep -c -F -e '- [x] Consumer isolation:' spec.md; grep -c -F -e '- [x] Fixture output hygiene:' spec.md; grep -c -F -e '- [x] Order independence:' spec.md; grep -c -F -e '- [ ] Deterministic derivation:' spec.md (each against `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md`)
EXIT_CODE: 0
Output Summary: each of the five searches reports a count of 1. Of the 19 acceptance criteria in `spec.md`, 18 are checked and 1 is pending CI (AC-01, Deterministic derivation). Round 2 checked AC-11, AC-12, AC-13, and AC-19; the other 14 checked criteria were checked in round 1 and were not re-verified in round 2.

Source: `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/spec.md`, section `## Acceptance Criteria`. Evidence paths are relative to the feature folder.

| AC | Criterion | Status | Evidence |
| --- | --- | --- | --- |
| AC-01 | Deterministic derivation | PENDING-CI (unchecked) | Local legs pass: `evidence/qa-gates/determinism-comparison.2026-10-17T13-03.md` (runs A, B, C: 215 files, LINE total 19095, identical KEY_SHA256, zero per-file differences); CI leg named in `evidence/qa-gates/ci-leg-pending.2026-10-17T13-03.md`. The orchestrator checks it off at S9. |
| AC-02 | Route independence | checked (round 1) | `evidence/regression-testing/fail-first-coverage-tests.2026-10-02T08-45.md`, `evidence/regression-testing/pass-after-new-tests.2026-10-02T08-45.md` |
| AC-03 | Derived population contents | checked (round 1) | `evidence/regression-testing/pass-after-new-tests.2026-10-02T08-45.md` |
| AC-04 | Precedence order | checked (round 1) | `evidence/regression-testing/pass-after-new-tests.2026-10-02T08-45.md` |
| AC-05 | Observability | checked (round 1) | `evidence/regression-testing/pass-after-invokesummary.2026-10-02T08-45.md` |
| AC-06 | Config validation | checked (round 1) | `evidence/regression-testing/fail-first-coverageconfig-tests.2026-10-02T08-45.md`, `evidence/regression-testing/pass-after-named-tests.2026-10-02T08-45.md` |
| AC-07 | Absolute root | checked (round 1) | `evidence/regression-testing/pass-after-named-tests.2026-10-02T08-45.md` |
| AC-08 | Allow-list removed | checked (round 1) | `evidence/qa-gates/runsettings-shape.2026-10-02T08-45.md` |
| AC-09 | Parity preserved | checked (round 1) | `evidence/regression-testing/parity-after-mirror.2026-10-02T08-55.md`, `evidence/qa-gates/final-python-pytest-parity.2026-10-02T08-45.md` |
| AC-10 | `config/poshqc-coverage.json` exists and a self-hosted run logs source `config` | checked (round 1); re-observed in round 2 | `evidence/qa-gates/coverage-config.2026-10-02T08-45.md`; round 2 runs log `source=config` (`evidence/qa-gates/denominator-run-a.2026-10-17T13-03.md`) |
| AC-11 | Consumer fixture coverage | checked (round 2) | `evidence/regression-testing/post-fix-fixture-run.2026-10-17T13-04.md` (source `fallback`, 1 file, 0 failures), `evidence/regression-testing/post-fix-fixture-check.2026-10-17T13-04.md` (Sample.psm1 covered LINE count 2), pre-fix failing reference `evidence/qa-gates/fail-first-reference.2026-10-17T13-04.md` |
| AC-12 | Consumer isolation | checked (round 2) | `evidence/regression-testing/post-fix-fixture-check.2026-10-17T13-04.md` (one sourcefile `Sample.psm1`, package `scripts`, stand-in absent, 0 outside packages) |
| AC-13 | Fixture output hygiene | checked (round 2) | `evidence/qa-gates/fixture-output-hygiene.2026-10-17T13-04.md` (porcelain empty before and after; gitignore mechanism) |
| AC-14 | New code coverage | checked (round 1) | `evidence/qa-gates/coverage-new-code.2026-10-02T08-45.md`, `evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md` |
| AC-15 | Existing suite | checked (round 1) | `evidence/qa-gates/final-pwsh-test-run-a.2026-10-02T08-45.md`, `evidence/qa-gates/final-pwsh-format.2026-10-02T08-45.md`, `evidence/qa-gates/final-pwsh-analyze.2026-10-02T08-45.md` |
| AC-16 | Documentation | checked (round 1) | `evidence/qa-gates/readme-documentation.2026-10-02T08-45.md` |
| AC-17 | No temporary files in tests | checked (round 1) | `evidence/qa-gates/test-purity.2026-10-02T08-45.md` |
| AC-18 | File size limits | checked (round 1) | `evidence/qa-gates/line-limits.2026-10-02T08-45.md` |
| AC-19 | Order independence | checked (round 2) | `evidence/regression-testing/order-independence-summary.2026-10-17T13-09.md` and the three seed artifacts (seeds 527, 1017, 20261017): zero failures in each, three distinct file orders, same key set and root LINE total as run A |

Status summary: 19 criteria; 18 checked; 1 pending CI (AC-01).
