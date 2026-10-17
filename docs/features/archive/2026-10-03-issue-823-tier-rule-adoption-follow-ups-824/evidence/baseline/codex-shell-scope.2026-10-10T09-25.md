# P12-T2 `.codex/` Shell-Script Scope and Pre-Widening Sizes

Timestamp: 2026-10-10T09-25
Command: reader R1 of Appendix P (poetry run python -c, is_shell_script rule over `git ls-files -- .codex`); git diff --no-index --exit-code .claude/rules/shell.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md; git diff --no-index --exit-code .codex/codex-web-setup.sh extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh; grep -c "^  " .codex/codex-web-setup.sh; grep -c "^ " scripts/bash/shell_qc_lib.sh; wc -l .codex/codex-web-setup.sh scripts/bash/shell_qc_lib.sh tests/shell/test_shell_qc_discovery.bats tests/shell/test_shell_qc_commands.bats tests/shell/test_codex_web_setup_codex_copy.bats
EXIT_CODE: 0
Output Summary:
- R1: exit 0; printed `TRACKED 155` then `SHELL ['.codex/codex-web-setup.sh']`.
- git diff --no-index (shell.md pair): exit 0, no output (byte-identical).
- git diff --no-index (codex-web-setup.sh pair): exit 0, no output (byte-identical).
- grep -c "^  " .codex/codex-web-setup.sh: exit 0; printed 254.
- grep -c "^ " scripts/bash/shell_qc_lib.sh: exit 1; printed 0 (grep exits 1 on a zero count; expected value 0).
- wc -l: exit 0; printed 413 (.codex/codex-web-setup.sh), 394 (scripts/bash/shell_qc_lib.sh), 99 (tests/shell/test_shell_qc_discovery.bats), 203 (tests/shell/test_shell_qc_commands.bats), 187 (tests/shell/test_codex_web_setup_codex_copy.bats); total 1296.

TRACKED: 155
SHELL: ['.codex/codex-web-setup.sh']
