# Task Check: P6-T4

Timestamp: 2026-11-14T07-42
Command: Pester `Run.Path` = the selection below, `Run.Exit` = `$true`; `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <selection>`; `cmp` of each source with its bundle copy; `git diff <merge base of origin/main and HEAD> --numstat` over the three sources
EXIT_CODE: 0
Output Summary: Pester selection 326 passed, 0 failed (both ledger test files, `planning-contract-wording.Tests.ps1`, `test-cadence-wording.Tests.ps1`, `parallel-gate-wording.Tests.ps1`); pytest selection 35 passed, 0 failed; each source equals its bundle copy; the diff of each source from the merge base is `2 0` (lines added only).

## Changed Files

- `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`: one paragraph in `## Final QA Loop (Required for Code/Test Changes)`, placed before the `For languages with mandatory coverage policy, step 4` paragraph, stating that a launcher exit 75 means the machine test-suite lock was busy and that the gate is re-run after the holder finishes and recorded as a queue timeout, not a failure. Each source is edited in place.
- The three bundle copies under `extensions/drm-copilot/resources/` (`claude-customizations/.claude`, `codex-and-agents-customizations/.agents`, `customizations/.github`), each copied from its source.

Ledger placement: a first placement before the section's `Test cadence follows` line fell inside the `0009` stored-patch hunk of each source once entry `0011` is reverted (the chain test failed on the hunks at +154, +167, and +153); the paragraph was moved before the hunk. No ledger record changed.

## Selection and Rule

Rule: for a changed Markdown path, the contract tests that read it (`## Test Cadence (Mandatory)`), plus the ledger tests.

- Pester: `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`, `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
- pytest: `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`.

Format, lint, and type check: not applicable (Markdown).
