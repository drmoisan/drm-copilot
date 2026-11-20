# Remediation reaudit (cycle 1 exit)

Timestamp: 2026-11-18T12-40
Command: review of the cycle-1 evidence artifacts listed below against `remediation-inputs.2026-11-18T11-45.md` (finding F-1 and the non-blocking Jest entry-count note)
EXIT_CODE: 0
Output Summary: 2 rows: F-1 PASS, Jest note CLOSED. Every cited artifact exists. No FAIL row.

| Item | Result | Evidence |
|---|---|---|
| F-1: generator source drift (`.claude/rules/orchestrator-state.md` and its bundle copy carry `## Release-Commit Allowance Scope`, which the source did not produce) | PASS | Fail-before: `evidence/regression-testing/fail-before.generator-check.2026-11-18T12-08.md` (check exit 1, DRIFT on `GEN` and `GENB` only) and `evidence/regression-testing/fail-before.repo-gate.2026-11-18T12-16.md` (drift case failed, other two cases passed). Fix: `SRC.md` gained the `release-commit-allowance-scope` section and `SRC.json` lists the key in the Claude target. Regeneration: `evidence/other/regeneration.2026-11-18T12-21.md` (generator exit 0, `git diff --exit-code HEAD` over `GEN`, `GENB`, `CDX` exit 0, so all three are byte-identical). Static: `evidence/qa-gates/final-qc-static.2026-11-18T12-22.md` (`-Surface all -Check` exit 0, no drift). Gate: `evidence/qa-gates/final-pester.2026-11-18T12-40.md` (ExitCode 0; 29032 tests, 0 failures, 0 errors; drift case Passed; line coverage 96.76%). |
| F-1 target decision (D1) | PASS | The section is added to the Claude target only. The Codex target of the same source already omits every neighbouring Claude-runtime scope section, and the Release-Commit Allowance leg is a preimplementation-gate hook rule of the same kind. Copilot consumes `GEN` directly (`config/harness-parity-matrix.json` entry `claude:path-scoped-rule:orchestrator-state`), so no Copilot target is needed. `CDX` is unchanged, as confirmed by the regeneration artifact. |
| Jest entry-count note (non-blocking) | CLOSED | `evidence/other/correction.final-jest-entry-count.2026-11-18T12-22.md` (observed count 13; original `final-jest.2026-11-18T11-19.md` unchanged since REM_BASE). The same figure in `self-review.2026-11-18T11-36.md` is recorded in `evidence/other/correction.cycle1-evidence-stamps.2026-11-18T12-39.md`. |

Process note: four cycle-1 evidence files carry a stamp one minute ahead of their write time. The bound and impact (none on results) are recorded in `evidence/other/correction.cycle1-evidence-stamps.2026-11-18T12-39.md`.
