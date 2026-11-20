# Coverage Threshold and No-Regression Verification (Issue #227 remediation)

Timestamp: 2026-06-24T13-55

## Coverage values (enforce-evidence-locations.ps1, root file)

| Metric | Value | Source |
|---|---|---|
| Baseline line coverage | 81.48% (22/27) | evidence/baseline/pester.2026-06-24T13-55.md |
| Post-change line coverage | 96.43% (27/28) | evidence/qa-gates/final-pester-coverage.2026-06-24T13-55.md |
| Delta | +14.95 pp | computed |
| Threshold (uniform, all tiers) | >= 85% | .claude/rules/quality-tiers.md |

Branch coverage: not produced by Pester for PowerShell (LINE/INSTRUCTION counters
only). Only line coverage is applicable and is reported above.

## Threshold determination

Post-change line coverage 96.43% >= 85% threshold. PASS.

## No-regression on changed lines

The previously-changed line is the `'artifacts/research/'` forbidden prefix entry
in the `Test-EvidenceLocationForbidden` forbidden-prefix array (root file line 68).

Verification: the Pester command-level CommandsMissed set for the root file
contains only line 176 (`exit (Invoke-EvidenceLocationEntryPoint)`). Line 68 is
not in the missed set. It is exercised by two passing tests:
- pre-existing: "blocks writes to artifacts/research/ (retired research path)"
- new (P2-T3): "returns exit code 0 and emits block JSON for a forbidden path"
  using `{"file_path":"artifacts/research/notes.md"}`.

Both tests require the `artifacts/research/` prefix to match to produce a block
decision; both pass. The changed line remains covered. NO REGRESSION on changed
lines.

## Residual uncovered line

Line 176, `exit (Invoke-EvidenceLocationEntryPoint)`, is the single thin
entry-point wiring statement. It is structurally unreachable from dot-sourced
unit tests (the dot-source guard returns before it) and cannot be executed
in-process under Pester because `exit` terminates the test host. No coverage
exclusion was introduced; the line remains in the denominator (27/28 -> 96.43%),
consistent with the no-exclusion policy in general-unit-test.md.

## Overall determination: PASS

Line coverage 96.43% >= 85% with no regression on changed lines. No return to
Phase 1/2 required.
