# P17-T5 Widening Write Set and Hard Exclusions Against WIDEN_BASE

Timestamp: 2026-10-10T10-10
Command: git diff --name-only 2a045b8ae3793c3a3531554354f6fda130520242 -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824'; git status --porcelain --untracked-files=all -- . ':!docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824'; git diff --name-only 2a045b8ae3793c3a3531554354f6fda130520242 -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824; git status --porcelain --untracked-files=all -- docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824; git diff --name-only 2a045b8ae3793c3a3531554354f6fda130520242 -- .github .claude/hooks .codex/hooks .codex/agents scripts/dev-tools tests/scripts; git branch --show-current
EXIT_CODE: 0
Output Summary:
- Command 1 (diff outside FEATURE): exit 0; 18 paths, exactly the W-SET:
  - .claude/rules/shell.md
  - .codex/codex-web-setup.sh
  - extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md
  - extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh
  - scripts/bash/shell_qc_lib.sh
  - tests/fixtures/codex_web_setup/bashrc-with-ci.txt
  - tests/fixtures/codex_web_setup/dotnet-repo/coverage.config
  - tests/fixtures/codex_web_setup/dotnet-repo/dotnet-tools.json
  - tests/fixtures/codex_web_setup/dotnet-repo/global.json
  - tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/dotnet/placeholder.txt
  - tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/sdk/8.0.100/placeholder.txt
  - tests/fixtures/codex_web_setup/dotnet-sdk-installed/global.json
  - tests/fixtures/shell_qc/.codex/codex_entry.sh
  - tests/shell/test_codex_web_setup_codex_dotnet.bats
  - tests/shell/test_codex_web_setup_codex_installers.bats
  - tests/shell/test_codex_web_setup_codex_verify.bats
  - tests/shell/test_shell_qc_commands.bats
  - tests/shell/test_shell_qc_discovery.bats
- Command 2 (porcelain outside FEATURE): exit 0; printed nothing. Union of commands 1 and 2 = the 18 W-SET paths.
- Command 3 (diff inside FEATURE): exit 0; 38 paths: `spec.md`, `plan.2026-10-08T22-16.md`, and 36 paths under `evidence/` (baseline, other, qa-gates).
- Command 4 (porcelain inside FEATURE): exit 0; ` M plan.2026-10-08T22-16.md` and five `??` paths under `evidence/` (commit-p16, parity-set-widening, widening-line-counts, widening-mirror-identity, widening-pytest-full).
- Union of commands 3 and 4 contains only `spec.md`, `plan.2026-10-08T22-16.md`, and paths under FEATURE `evidence/`.
- Command 5 (hard-exclusion roots .github, .claude/hooks, .codex/hooks, .codex/agents, scripts/dev-tools, tests/scripts): exit 0; printed nothing.
- Command 6: printed `bug/issue-823-tier-rule-adoption-follow-ups-824`.

Result: PASS
