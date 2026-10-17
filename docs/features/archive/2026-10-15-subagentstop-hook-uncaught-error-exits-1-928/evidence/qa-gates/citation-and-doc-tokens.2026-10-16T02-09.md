# Citation and Documentation Tokens (issue #928)

Timestamp: 2026-10-16T02-09
Command: grep -c -F "docs/features/archive/subagentstop-envelope-core-897/spec.md" .claude/hooks/subagentstop-envelope.ps1 tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1
EXIT_CODE: 0

Further commands:
- `grep -c -F "docs/features/active/subagentstop-envelope-core-897/spec.md" .claude/hooks/subagentstop-envelope.ps1 tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` (EXIT_CODE 1: no match)
- `grep -c -F "undocumented-envelope.md" .claude/skills/epic-orchestrate/SKILL.md .claude/agents/epic-orchestrator.md .claude/hooks/enforce-epic-wave-barrier.ps1` (EXIT_CODE 1: no match)

Output Summary: PASS. Active-path spec.md count 0 and archive-path count 1 in both citation files; `undocumented-envelope.md` count 0 in all three documentation files.

| File | active-path spec.md | archive-path spec.md | undocumented-envelope.md |
| --- | --- | --- | --- |
| .claude/hooks/subagentstop-envelope.ps1 | 0 | 1 | n/a |
| tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1 | 0 | 1 | n/a |
| .claude/skills/epic-orchestrate/SKILL.md | n/a | n/a | 0 |
| .claude/agents/epic-orchestrator.md | n/a | n/a | 0 |
| .claude/hooks/enforce-epic-wave-barrier.ps1 | n/a | n/a | 0 |

Related P4 checks (same pass): `git diff --numstat MERGE_BASE` shows 1/1 for subagentstop-envelope.ps1 (hunk `@@ -12 +12 @@`) and for subagentstop-envelope.Tests.ps1, and 2/2 for enforce-epic-wave-barrier.ps1 (hunk `@@ -34,2 +34,2 @@`); architecture doc counts 0/1/1; translate-claude-to-codex SKILL.md `SubagentStop, exit 1` 0 and `SubagentStop, exit 2` 1; `resolved by epic #904` 1 in each of the skill and agent files.
