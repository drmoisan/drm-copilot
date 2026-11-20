# Task Check P4-T4

Timestamp: 2026-11-14T05-39
Command: sh SCRATCH/issue-1162-tc.sh "tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1" "tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1"
EXIT_CODE: 0
Output Summary: format differences 0; analyzer findings 0; Pester passed=19 failed=0 total=19 result=Passed.

## Changed files

- tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1 (new): section extraction between a '## ' heading and the next '## ' heading with whitespace collapsed; case-sensitive tokens; upper-case identifiers matched whole (no capital letter or underscore on either side); a missing heading fails the row. Rows: CES-SECTION-TOKENS for the shared token list in both epic-orchestrate skills and the per-section rows of the plan; CES-FILE-TOKENS for both epic-plan skills, both epic-run skills, epic-planner.md, epic-planner.toml, and epic-orchestrator.toml; CES-TEMPLATES-BYTE-IDENTICAL (SHA-256 of both epic templates); CES-IDENTIFIER-MATCH-IS-WHOLE and CES-MISSING-HEADING-FAILS for the helper rules.

## Discrimination

At the pre-change merge commit (the P0-T1 main sync of this branch), a search for `cross_epic`, `Invoke-EpicCrossReadiness`, or `Upstream context for` counts 0 in epic-orchestrator.md, both epic-plan skills, both epic-run skills, epic-planner.md, epic-planner.toml, epic-orchestrator.toml, and the epic template. The two epic-orchestrate skills count 2 and 1, all from the early-start `Upstream context for` line outside the asserted sections; the `## Cross-Epic Dependencies (cross_epic_depends_on)` heading is absent there, so those rows fail on the missing heading.

## Selection and rule

The new test file itself.
