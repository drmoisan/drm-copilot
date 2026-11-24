# Task Check P3-T1 (Issue #1218)

Timestamp: 2026-11-23T10-47
Changed files: tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1 (168 lines), .agents/skills/docs-init/SKILL.md, .agents/skills/docs-init/references/standard.md
Selection rule: the edited test file plus the contract tests that read the edited Markdown paths, as named by P3-T1: docs-authoring-roles.Skills.Tests.ps1 and tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1. The mirror and generator contracts are outside this selection and are asserted in P3-T2.
Command: sh SCRATCH/issue-1218-qc.sh format-check / analyze over the test file; sh SCRATCH/issue-1218-check.sh check-p3t1 <three files>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Format: 0 changes. PSScriptAnalyzer: 0 findings.
- 145 tests: 142 passed, 3 failed; the 3 failures are exactly the expected `Claude`, `ClaudeBundle`, and `CodexBundle` rows recorded in .dev/active/1218-docs-family-profile-model/evidence/regression-testing/docs-init-families-expect-fail.2026-11-23T10-47.md. The `Codex` row passes.
- `.agents/skills/docs-init/SKILL.md`: `## Documentation Families` added between `## Steps` and `## Linter Configuration`; the Steps, Linter Configuration, and Result text and the substitution `find` lines are unchanged; the file contains no `.claude/` text.
- `.agents/skills/docs-init/references/standard.md`: `**OB-5** Documentation Families:` and `**AC-5** (OB-5)` added; the final check renumbered to `**AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5)`.
