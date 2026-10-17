# R1 Gate Header Residual Limits (Issue #927, CR-2, AC-M21 continuity)

Timestamp: 2026-10-16T08-07
Command: grep -c -F -e 'GH_REPO or GH_HOST' .claude/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE: 0
Output Summary: The three headers each keep one GH_REPO or GH_HOST residual-limit sentence (now including the working-directory limit); both gate headers still name DOCS_ONLY_EXEMPTION_PR_UNRESOLVED and --match-head-commit.

COUNT: .claude/hooks/hook-docs-only-diff.ps1:1
COUNT: .claude/hooks/enforce-epic-merge-gate.ps1:1
COUNT: .codex/hooks/enforce-epic-merge-gate.ps1:1

Command 2: grep -c -F -e 'DOCS_ONLY_EXEMPTION_PR_UNRESOLVED' .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE_2: 0
COUNT_2: .claude/hooks/enforce-epic-merge-gate.ps1:1
COUNT_2: .codex/hooks/enforce-epic-merge-gate.ps1:1

Command 3: grep -c -F -e '--match-head-commit' .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE_3: 0
COUNT_3: .claude/hooks/enforce-epic-merge-gate.ps1:2
COUNT_3: .codex/hooks/enforce-epic-merge-gate.ps1:2
