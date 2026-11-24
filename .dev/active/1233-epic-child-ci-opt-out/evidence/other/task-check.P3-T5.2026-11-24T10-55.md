# Task check: P3-T5

Timestamp: 2026-11-24T10-55
Command: see the command list below (each run from the item worktree root)
EXIT_CODE: 0
Output Summary: the new contract suite passed through the launcher with 65 tests and 0 failures: 58 unit rows (O-S9, O-FIELDS, O-PR, E-MAN, E-CP, E-KICK, E-MERGE, E-FINAL, and R-RUN in four copies each; P-PLAN in the four epic-plan copies; X-ENF in both rule copies; B-HOOK, B-CI, B-MCP, and B-TEST in the four brief copies), two rule-section rows, two template rows, the distinct-case-label row, and two helper rows. Invoke-Formatter reports no drift and PSScriptAnalyzer 0 findings.

Changed files:
- tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1 (created): each unit row extracts the named level-two section (a fenced block never ends a section), selects the labeled units (paragraph or list item that begins with `Child CI opt-out (issue #1233):`, or `Child-CI opt-out (#1233):` in the brief, up to the next blank line, list item, or heading, line breaks joined by single spaces), and requires every token in one unit (ordinal String.Contains). The rule rows read only the `## Epic-child CI opt-out (issue #1233)` section; the template rows read only the manifest frontmatter. No row reads a whole file where a section is named.
- .dev/engineering/process-reductions/0014-epic-child-ci-opt-out.md: Files Changed, Revert Steps step 1 (delete the created suite), and step 6 extended.

Selection and rule: the new suite (the task's acceptance names its launcher run).

Commands and exit codes:
- sh SCRATCH/issue-1233-ps-files.sh write|check tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1 -> 0 (format drift=0 pssa findings=0)
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1 -> 1, then 1, then 0. The first run failed every unit row with ParameterBindingValidationException (`Line` rejected an empty string); `[AllowEmptyString()]` was added. The second run failed the two Claude E-MAN rows because the section extraction stopped at a `# ` comment line inside the YAML fence of `## Epic Dependency Manifest`; the extraction now skips fenced lines. The third run passed: 65 passed, 0 failed.
- sh SCRATCH/issue-1233-ledger-verify.sh -> 0 (blocks=65 files=28 problems=0)
