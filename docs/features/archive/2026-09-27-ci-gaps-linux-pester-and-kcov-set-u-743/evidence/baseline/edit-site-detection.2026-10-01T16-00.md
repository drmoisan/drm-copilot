# Edit-Site Detection (P0-T5)

Timestamp: 2026-10-01T16-00

Command: grep -c -F 'run_test() {' scripts/bash/shell_qc_lib.sh
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F 'extract_cobertura_line_rate() {' scripts/bash/shell_qc_lib.sh
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F '@test "an unknown test flag exits 2" {' tests/shell/test_shell_qc_commands.bats
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F 'if-no-files-found: ignore' .github/workflows/_poshqc.yml
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F 'windows.sandbox="elevated"' tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
EXIT_CODE: 0
Output Summary: 2

Command: grep -c -F 'windows.sandbox="elevated"' tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F -e 'C:/repo' -e 'C:/elsewhere' -e 'C:/nonexistent' tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
EXIT_CODE: 0
Output Summary: 15

Command: grep -c -F '**Check that the task-ordering does not make the condition unsatisfiable.**' .claude/skills/atomic-plan-contract/SKILL.md
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F '**Check that the task-ordering does not make the condition unsatisfiable.**' extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
EXIT_CODE: 0
Output Summary: 1

Result: counts in order are 1, 1, 1, 1, 2, 1, 15, 1, 1, matching the plan's expected values. No anchor moved.
