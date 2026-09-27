# Final QC PowerShell Coverage Delta ([P6-T5], AC-22 coverage part)

Timestamp: 2026-09-27T07-33
Command: sh <SCRATCHPAD>/x707p6-run.sh x707p6-parse (R-COV over artifacts/pester/powershell-coverage.xml from [P6-T4]; changed lines from git diff -U0 daae7f796ebbd87e2170df3c86a9901ce11a4b68 -- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1, each file diffed separately; baseline from evidence/baseline/p0-pester-coverage.md)
EXIT_CODE: 0
Output Summary: Pass 1. Gate: baseline 98.80 (missed=2) to post 100.00 (missed=0); changed-line 6/6 = 100.00. Epic-scope sibling: n/a (new file) to 100.00 (missed=0); changed-line 44/44 = 100.00. Epic-resolution sibling: n/a (new file) to 93.20 (missed=10); changed-line 137/147 = 93.20. Every post percent and every changed-line figure is at least 85; the gate meets the pre-declared no-regression rule on both arms.

EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/coverage/ replaced with docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/

Pass: 1

BASE_SHA: daae7f796ebbd87e2170df3c86a9901ce11a4b68 (REBASED: no)

## Per-file coverage

| File | Baseline percent | Post percent | Baseline `missed` | Post `missed` | Post `covered` | Changed-line coverage |
| --- | --- | --- | --- | --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 98.80 | 100.00 | 2 | 0 | 164 | 100.00 (6 of 6) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | n/a (new file) | 100.00 | n/a | 0 | 44 | 100.00 (44 of 44) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | n/a (new file) | 93.20 | n/a | 10 | 137 | 93.20 (137 of 147) |

## Changed-line derivation (section 5)

The coverage report carries `line` elements for each file (164, 44, and 147 respectively), so the changed-line computation applies. Added line numbers come from the `+start,count` of each `@@` hunk header of `git diff -U0 daae7f796ebbd87e2170df3c86a9901ce11a4b68 -- <file>`. An added line that carries a `line` element is in the denominator and counts as covered when its `ci` attribute is greater than 0; added lines with no `line` element (comments, blank lines, braces, and other non-command lines) are outside the denominator.

| File | Added lines | Added lines with a `line` element | Covered (`ci` > 0) | Uncovered added line numbers |
| --- | --- | --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 14 | 6 | 6 | none |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 189 | 44 | 44 | none |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | 493 | 147 | 137 | 61, 111, 153, 168, 183, 239, 252, 395, 404, 453 |

## No-regression rule (pre-declared, gate file)

- Arm 1: post percent (100.00) is at least baseline percent (98.80): met.
- Arm 2: post `missed` (0) is at most baseline `missed` (2): met.

The rule is met.

## Thresholds

- Post percent at least 85: gate 100.00, epic-scope 100.00, epic-resolution 93.20. Met for all three.
- Changed-line coverage at least 85: 100.00, 100.00, 93.20. Met for all three.
- Pester measures line coverage only; no branch threshold applies to PowerShell.
