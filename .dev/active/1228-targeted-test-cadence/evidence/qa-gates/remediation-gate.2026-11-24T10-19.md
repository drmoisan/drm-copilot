# Remediation Gate - Issue #1228, remediation cycle 1 ([P1-T6])

Timestamp: 2026-11-24T10-19
Plan: remediation-plan.2026-11-24T07-15.md
Command: `sh <item worktree>/artifacts/issue-1228/c1gate.sh c1g1`, which runs in order: `sh SCRATCH/issue-1228-pstatic.sh c1g1` (pwsh 7 at the item worktree root: `Invoke-PoshQCFormat -Root <worktree root>` with `git status --porcelain` captured before and after, `Invoke-PoshQCAnalyze -Root <worktree root>` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, `Invoke-PoshQCLeakScan -Root <worktree root>`, `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`, and `-Surface instructions -Check`); `sh SCRATCH/issue-1228-pystatic.sh c1g1` (with VIRTUAL_ENV unset at the item worktree root: `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`); `sh <item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the 14 union Pester files>`; `sh <item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <the 10 union pytest files>`; `sh <item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --testPathPatterns "push-down-harness\.real-bundle|extension\.resolve-policy-audit-template"` (launcher calls through the exit-75 retry wrapper)
EXIT_CODE: 0
Output Summary:
- One pass; every stage exited 0 with zero failing tests; no restart was needed. Run window 2026-11-24T09-58-52 to 10-18-45 (UTC).
- Stage 1, format: `Invoke-PoshQCFormat` EXIT_CODE 0, 1879 files visited, 0 reformatted (finding count 0); `git status --porcelain` identical before and after the format step (True). `black --check` EXIT_CODE 0, "1071 files would be left unchanged." (finding count 0).
- Stage 2, lint: `Invoke-PoshQCAnalyze` EXIT_CODE 0 (throws on any finding; none), finding count 0. `Invoke-PoshQCLeakScan` EXIT_CODE 0, "Leak scan: 907 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures." `ruff check .` EXIT_CODE 0, "All checks passed!" (finding count 0).
- Stage 3, type check: `pyright` EXIT_CODE 0, "0 errors, 0 warnings, 0 informations". PowerShell has no type checker. TypeScript: recorded with no changed file (the cycle changes no `.ts`, `.tsx`, `.js`, `.cjs`, `.mjs`, or `.py` file).
- Comparison with [P0-T1] and [P0-T2] (`evidence/remediation-baseline/powershell-static.2026-11-24T07-58.md`, `python-static.2026-11-24T07-58.md`): every finding count is 0 in both; leak-scan failures 0 in both; no count is higher.
- Stage 4, architecture-boundary tests: not applicable; the repository defines no architecture-boundary check.
- Stage 5, unit stage over the union of the [P1-T1] to [P1-T5] task-check selections:
  - Pester, coverage mode: one launcher `pester -TestPath` run over 14 files (`Invoke-PoshQCParallelTest`, workers=8, wall-clock 166.13 s, exit code 0); JUnit 721 tests in 14 suites, 0 failed, 0 errors, 0 skipped; first attempt.
  - pytest: one launcher `pytest` run over 10 files (`pytest -n auto`); EXIT_CODE 0; 279 passed. Five attempts exited 75 (queue timeout; the lock was held by suites of other worktrees) before the pass.
  - Jest: one launcher `jest-extension` run selected with `--testPathPatterns`; EXIT_CODE 0; Test Suites 2 passed of 2; Tests 22 passed of 22; first attempt.
- Stage 6, contract checks: `Invoke-HarnessGeneration.ps1 -Check` EXIT_CODE 0 and `-Surface instructions -Check` EXIT_CODE 0, both "harness-generation: no drift"; Codex generator `--check` EXIT_CODE 0.

## Union and rule

The union is the de-duplicated concatenation of the task-check selection lists of [P1-T1] to [P1-T5] (`artifacts/issue-1228/c1-p1t<M>-pester.txt` and `c1-p1t<M>-pytest.txt` for M = 1 to 5, gitignored working files of the item worktree), with integration and golden suites removed (none present), plus the two Jest files of the [P1-T3] selection. Each list was produced by its task's selection rule: the suites the task text names plus every test file found by searching `tests/` (and `extensions/drm-copilot/test/` for [P1-T3]) for the changed path or file name, as recorded in each task-check artifact. The ledger window is closed since [P1-T5], so `ProcessReductionChain.Ledger.Tests.ps1` is in the union.

Pester (14 files):
- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`
- `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1`
- `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1`
- `tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1`
- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`
- `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`
- `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`
- `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`
- `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`
- `tests/scripts/dev-tools/ProcessReductionLedger.Replay.Tests.ps1`
- `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`
- `tests/scripts/harness-generation/HarnessAgentGeneration.Tests.ps1`
- `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`
- `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1`

pytest (10 files):
- `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`
- `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`
- `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`
- `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- `tests/scripts/dev_tools/test_push_down_codex_pack_selection.py`
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`
- `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`

Jest (2 files, `jest-extension`):
- `extensions/drm-copilot/test/lib/push-down/push-down-harness.real-bundle.test.ts`
- `extensions/drm-copilot/test/extension.resolve-policy-audit-template.test.ts`

## Coverage

- The cycle changed no production file: its changed paths are Markdown and TOML surfaces (skills, the feature-review agent source, its generated targets, bundles, the policy-audit template), one Pester test file, and the ledger entry `0014` with its patch. No per-file production comparison with the `Phase 0 baseline` applies (RD2).
- PowerShell selection run in coverage mode (from `artifacts/pester/powershell-coverage.xml` of this run): LINE 1002 covered, 47974 missed = 2.05%; INSTRUCTION 1673 covered, 85313 missed. These figures cover the 14-file selection only and are not a repository-wide figure.
- Repository-wide figures remain those of the main plan's final-QC artifacts (`evidence/qa-gates/pester.2026-11-24T06-30.md`, `pytest.2026-11-24T06-43.md`, `jest.2026-11-24T06-58.md`) compared with the `Phase 0 baseline` (`evidence/baseline/pester.2026-11-23T13-26.md`, `pytest.2026-11-23T13-32.md`, `jest.2026-11-23T13-33.md`), and CI on the pushed head is the merge gate.
- pytest and Jest selections ran without coverage, because their contract tests read changed Markdown, TOML, and bundle paths (RD2).
