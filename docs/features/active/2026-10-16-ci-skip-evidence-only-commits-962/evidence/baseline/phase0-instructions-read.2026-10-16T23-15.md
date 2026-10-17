# Phase 0 policy reads (issue #962)

Timestamp: 2026-10-16T23-15
Command: Read tool over the 22 policy files listed below, in order
EXIT_CODE: 0
Output Summary: All 22 policy files were read in the order required by plan task P0-T1. No policy file was edited.

Policy Order: CLAUDE.md, then .claude/rules (general, language, domain), then .github instructions, then the two tracking skills, as listed below.

Files read (in order):

1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/powershell.md
5. .claude/rules/python.md
6. .claude/rules/python-suppressions.md
7. .claude/rules/shell.md
8. .claude/rules/quality-tiers.md
9. .claude/rules/ci-workflows.md
10. .claude/rules/plan-acceptance-gates.md
11. .claude/rules/self-explanatory-code-commenting.md
12. .claude/rules/tonality.md
13. .github/copilot-instructions.md
14. .github/instructions/general-code-change.instructions.md
15. .github/instructions/general-unit-test.instructions.md
16. .github/instructions/powershell-code-change.instructions.md
17. .github/instructions/powershell-unit-test.instructions.md
18. .github/instructions/python-code-change.instructions.md
19. .github/instructions/python-unit-test.instructions.md
20. .github/instructions/github-actions.instructions.md
21. .claude/skills/acceptance-criteria-tracking/SKILL.md
22. .claude/skills/evidence-and-timestamp-conventions/SKILL.md

Notes relevant to this plan:

- PowerShell: Pester 5, PSScriptAnalyzer settings, files 500 lines or fewer, no direct mocks of git or gh.
- Shell: tab indentation, LF endings, bats suites in tests/shell, 500-line limit; CI versions canonical.
- CI workflows: pwsh steps that run a nested failing command end with an explicit exit 0.
- Coverage: the root CLAUDE.md states no threshold, so the 85% line default applies; Pester and kcov have no branch gate.
