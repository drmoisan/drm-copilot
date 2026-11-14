# Task Check: P6-T5

Timestamp: 2026-11-14T07-46
Command: Pester `Run.Path` = the selection below, `Run.Exit` = `$true`; `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <selection>`
EXIT_CODE: 0
Output Summary: Pester selection 435 passed, 0 failed (both ledger test files, `ProcessReductionLedger.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, `light-remediation-skill-contract.Tests.ps1`, `less-evidence-contract.Tests.ps1`, `test-cadence-wording.Tests.ps1`); a re-run of the three ledger files after the `Rebased over #1158` paragraphs 92 passed, 0 failed; pytest selection 235 passed, 0 failed, including the legacy-variant cases of `test_push_down_codex_and_agents_resource_contracts.py`.

## Changed Files

- QA-gate and invoke skills, each gaining a final `## Test-Execution Launcher` section that names the launcher suite of its language (`pytest`, `pester`, `dotnet-test`) and states the queue re-run rule naming the machine test-suite lock, keeping `poetry run pytest -n auto` and `Invoke-PoshQCParallelTest` and adding no `$script:PowerShellQaGateForbidden` or `$script:PythonQaGateForbidden` token: `.claude/skills/{python,powershell,csharp}-qa-gate/SKILL.md`, `.claude/skills/invoke-{python,powershell,csharp}-engineer/SKILL.md`, their `.agents` copies (naming the `.agents` launcher path), their bundle copies under `claude-customizations/.claude/skills/` and `codex-and-agents-customizations/.agents/skills/`, and the four csharp-legacy variants (`.claude-variants` and `.agents-variants` of `csharp-qa-gate` and `invoke-csharp-engineer`).
- `feature-review-workflow` (spec D22): in `.claude/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review-workflow/SKILL.md`, and their two bundle copies, the coverage step names the launcher `jest` suite (replacing `npm run test:unit:coverage`), the launcher `pytest` suite (replacing the direct pytest command), and the launcher `pester` suite for the `Invoke-PoshQCParallelTest` run, and the `If coverage artifacts already exist` line states the queue re-run rule; every `$script:ReviewRequired` token is kept. The `.github` copy and its bundle copy are unchanged.
- Ledger rule: in `patches/0001-parallel-only-test-gates.patch` (16 lines), `patches/0006-test-suite-baseline-restored.patch` (12 lines), and `patches/0009-less-evidence.patch` (10 lines), every hunk line of the feature-review-workflow sections that carried one of the four replaced lines was regenerated with the new text in both images; `0009`, `0006`, and `0001` each gained a `Rebased over #1158` paragraph. The QA-gate and invoke additions are appended after the last line of each file, outside every recorded region.

## Selection and Rule

Rule: for a changed Markdown path, the contract tests that read it (`## Test Cadence (Mandatory)`), plus the ledger tests.

- Pester: `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`, `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1`, `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1`, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`.
- pytest: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_issue_824_follow_ups.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_orchestrator_state_remediation_docs.py`, `test_ci_gate_epic_child_contracts.py`, `test_skill_bundle_contract_repo.py`, `test_codex_full_migration_inventory.py`, `test_typescript_toolchain_instruction_contracts.py` (all under `tests/scripts/dev_tools/`).

Format, lint, and type check: not applicable (Markdown and patch text).
