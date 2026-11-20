# Task Check [P3-T1]

Timestamp: 2026-11-19T11-33
Command: node JSON parse of general-unit-test.json and the copilot target section list; grep -c of TaskMaster, No-COM, not used in this repository and npm run in the source (0)
EXIT_CODE: 0
Output Summary: Changed files: scripts/harness-generation/sources/rules/general-unit-test.md (section coverage-exclusion-policy only); scripts/harness-generation/sources/rules/general-unit-test.json (copilot sections). Result: the JSON parses; COPILOT_SECTIONS after the edit: head-2,1-core-principles,2-coverage-and-scenarios,coverage-exclusion-policy,3-test-structure-and-diagnostics,4-external-dependencies-and-environment,5-policy-audit. The source contains none of the forbidden tokens. Selection rule: the contract checks that read the rule source are the generator -Surface rules -Check and the rule-copy tests; they compare the source with outputs that [P3-T4] renders, so they run in the [P3-T4] and [P3-T5] task checks and the [P3-T6] gate. No formatter, linter or type checker applies to Markdown and JSON data here.
