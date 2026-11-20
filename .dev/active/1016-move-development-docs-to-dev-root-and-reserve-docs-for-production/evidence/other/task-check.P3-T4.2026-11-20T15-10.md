# Task Check [P3-T4]

Timestamp: 2026-11-20T15-10
Command: sh SCRATCH/issue-1016-tc-p3t4.sh (launcher pytest -n auto, launcher pester -TestPath, launcher jest-extension --testPathPatterns over the selection)
EXIT_CODE: 1
Output Summary: pytest selection 65 passed, 1 failed (test_contract_requires_final_phase_self_review, a REHEARSAL run A FIX row fixed by [P3-T9]); Pester selection 354 tests, 3 failed (parallel-gate-wording.Tests.ps1 PGW-AUDIT-TEMPLATE, PGW-AUDIT-AGENTS, PGW-SWEEP-SURFACES, REHEARSAL run A FIX rows fixed by [P3-T9]); Jest selection 9 suites, 94 tests passed. Every failure is a pre-existing post-apply FIX row attributed to [P3-T9] by the [P2-T4] gate; no failure is caused by this task. The task's acceptance tests pass: test_plan_templates_carry_premortem_skeleton, CES-TEMPLATES-BYTE-IDENTICAL, PRC-LEDGER-CHAIN-HOLDS.

## Changed files

- `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`: bytes copied from `.dev/templates/feature/plan.yyyy-MM-ddTHH-mm.md` (two link lines change from four-level to three-level depth).

Markdown: no format, lint or type stage applies.

## Selection and rule

Contract tests that read the changed bundle path: every test file under `tests/` and `extensions/drm-copilot/test/` that names `feature-templates` (fixtures excluded), plus `ProcessReductionChain.Ledger.Tests.ps1` (named by the task acceptance) and `test_push_down_claude_resource_contracts.py`. Python: `test_single_pass_preflight_contracts.py`, `test_new_potential_bug_entry.py`, `test_new_active_feature_folder_part2.py`, `test_push_down_claude_resource_contracts.py`. Pester: `test-cadence-wording.Tests.ps1`, `cross-epic-skill-contract.Tests.ps1`, `DocumentationEstateEpicTemplate.Tests.ps1`, `DocumentationEstateOnboarding.Tests.ps1`, `ProcessReductionChain.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1`, `new-potential-entry.TemplateRoot.Tests.ps1`, `parallel-gate-wording.Tests.ps1`. Jest: the six suites naming `feature-templates` (`repo-automation-service.new-potential-entry-root`, `new-potential-bug-entry`, `new-potential-bug-entry-service-call`, `extension.workflow-commands`, `repo-automation-dispatch`, the two in-process suites); `extension.integration.test.ts` is an integration suite and runs in CI only.
