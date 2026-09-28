# Phase 0 — Policy Reading Record (Remediation Cycle 2026-08-26T02-36)

Timestamp: 2026-08-26T03-19

Stamp substitution: the plan fixes the evidence filename stamp at `2026-08-26T02-36` and asserts exact
filenames in its acceptance conditions, so the filename retains the plan-fixed stamp. The `Timestamp:`
field above records the actual execution stamp for this artifact.

Policy Order: `CLAUDE.md`, then the cross-language code-change and unit-test rules, then the tier map,
then the language-specific rules for the files in scope (PowerShell and Python), then the CI-workflow
rule, then the plan acceptance-gate rule.

Files read, one per line, in the order read:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.claude/rules/python.md`
7. `.claude/rules/ci-workflows.md`
8. `.claude/rules/plan-acceptance-gates.md`

Command: (read-only; no command executed for this task)

EXIT_CODE: 0

Output Summary: All eight policy files were read in the order listed above. The constraints that bind
this remediation cycle are: the 500-line file cap and the seven-stage toolchain loop from
`general-code-change.md`; the Coverage Exclusion Policy and test-purity requirements from
`general-unit-test.md`; the uniform 85 percent line-coverage floor from `quality-tiers.md`, with the
branch-coverage threshold not applicable to Pester; the wrapper-seam mocking rules, the per-batch
file cap, and the PoshQC format/analyze/test ordering from `powershell.md`; the Black/Ruff/Pyright/
Pytest ordering from `python.md`; the explicit-exit-code rule for deliberately-failing `pwsh` steps
from `ci-workflows.md`; and the G1 through G6 acceptance-gate authoring rules from
`plan-acceptance-gates.md`.
