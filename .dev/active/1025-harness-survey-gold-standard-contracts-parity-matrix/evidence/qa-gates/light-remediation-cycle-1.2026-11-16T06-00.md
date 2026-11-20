# QA Gate — Light Remediation Cycle 1 (Issue 1025)

Timestamp: 2026-11-16T06-00
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/remediation-inputs.2026-11-16T05-19.md (`## Light Fix Tasks`, Remediation-Mode: light)
Findings: R1 (code review CR-1), R2 (code review CR-2), plus same-class sweep

## Summary

- Named fixes: R1 26 Observable Behavior items in 21 contracts (the R1 location list names 26 items; its summary sentence states 25); R2 7 objectives in 7 contracts. Union: 24 contracts.
- Same-class sweep: 18 further items in 16 contracts, 8 of which no named fix touched.
- Total: 32 contracts changed, each in `.agents/skills/<name>/references/standard.md` and its byte-identical bundle copy (64 files).
- Task-check records: `evidence/other/task-check.P0-T1.2026-11-16T05-44.md`, `evidence/other/task-check.P0-T2.2026-11-16T06-00.md`.

## Gate 1 — Contract lint

Timestamp: 2026-11-16T05-46
Command: `sh SCRATCH/issue-1025-lint-contracts.sh <the 32 changed contract names>` (imports `scripts/harness/HarnessSkillContract.psm1`, calls `Get-HarnessSkillContractViolation` on the base and bundle copy of each changed contract)
EXIT_CODE: 0
Output Summary: CONTRACTS_CHECKED: 32 (x2 copies); VIOLATIONS: 0

## Gate 2 — Parallel Pester gate

Timestamp: 2026-11-16T05-46
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, wall-clock 639.27s, exit code 0. Merged `artifacts/pester/pester-junit.xml`: tests=27490, failures=0, errors=0, disabled=22 (skipped total 18 across testsuite elements). `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`: tests=7, failures=0, errors=0, skipped=0 (all passed). The changed files are Markdown contracts, so no PowerShell production file changed and per-file coverage is unaffected.

## Gate 3 — Python bundle-parity contract set (plan A `## Gate Shape`)

Timestamp: 2026-11-16T05-58
Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`
EXIT_CODE: 75
Output Summary: queue timeout, not a failure: `TEST_EXECUTION_QUEUE_TIMEOUT:` the machine test-suite lock was held by a `pester` suite of another worktree; re-run after the holder finished.

Timestamp: 2026-11-16T05-59
Command: the same command, re-run (`sh SCRATCH/issue-1025-pytest-retry.sh`, which repeats only on exit 75)
EXIT_CODE: 0
Output Summary: attempt 1 of the re-run; 24 workers, 92 items; 92 passed in 2.99s.

## Greps (both trees, after all fixes)

Each grep was run over `.agents/skills/*/references/standard.md` and over `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/*/references/standard.md`; each returned exit 1 (no match) with empty output.

1. Command: `grep -n ";\.$\|,\.$\|:\.$\|listed above" <tree>/*/references/standard.md`
   Output: (empty)
2. Command: `grep -l "Produce the outcome that the" <tree>/*/references/standard.md`
   Output: (empty)
3. Sweep grep. Command: `grep -n "^- \*\*OB-" <tree>/*/references/standard.md | grep -E "these |this (exact )?order|this closed set|the following|below|above|\(issue\.$|skills//|or \`\.agents/skills/\`\.|The skill defines its"`
   Output: (empty)
4. Forbidden tokens. Command: `grep -n -i -F -e TaskMaster -e No-COM -e "targeted tests" -e "targeted Pester" -e "targeted Pytest" -e "Targeted runs are allowed" -e "smallest relevant subset" -e "smallest applicable subset" -e run_poshqc_test -e "poetry run pytest --cov" -e "repeat until clean" -e "Each task's toolchain loop" -e "relevant tests pass" -e "run tests after each" -e xUnit -e "Pester v5" <tree>/*/references/standard.md`
   Output: (empty)
5. Short objectives. Command: word count of the first `## Objective` sentence of each of the 65 contracts, reporting any under 8 words
   Output: (empty)
6. Mirror identity. Command: `cmp -s` of each base contract against its bundle copy
   Output: (empty; no differing pair)

## Changed Files

Base copies (each also changed at `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md`):

- `.agents/skills/csharp-change-budget-router/references/standard.md` (R1 OB-2, R2)
- `.agents/skills/csharp-qa-gate/references/standard.md` (R1 OB-1, OB-5; sweep OB-2)
- `.agents/skills/docs-author-page/references/standard.md` (R1 OB-1)
- `.agents/skills/docs-init/references/standard.md` (R1 OB-1)
- `.agents/skills/docs-inventory-surface/references/standard.md` (R1 OB-1)
- `.agents/skills/docs-plan-ia/references/standard.md` (R1 OB-1)
- `.agents/skills/docs-reconcile-behavior/references/standard.md` (R1 OB-1)
- `.agents/skills/docs-review-coverage/references/standard.md` (R1 OB-1)
- `.agents/skills/docs-validate/references/standard.md` (R1 OB-1)
- `.agents/skills/documentation-workflow/references/standard.md` (R1 OB-1; sweep OB-2)
- `.agents/skills/epic-orchestrate/references/standard.md` (sweep OB-2)
- `.agents/skills/epic-plan/references/standard.md` (R1 OB-4)
- `.agents/skills/epic-run/references/standard.md` (R1 OB-1)
- `.agents/skills/execute-hard-lock/references/standard.md` (R2; sweep OB-3, OB-4)
- `.agents/skills/feature-promotion-lifecycle/references/standard.md` (R1 OB-2, R2)
- `.agents/skills/human-exception-runbook/references/standard.md` (R1 OB-5)
- `.agents/skills/make-skill-template/references/standard.md` (R2; sweep OB-3, OB-5)
- `.agents/skills/owner-directives/references/standard.md` (sweep OB-3)
- `.agents/skills/policy-compliance-order/references/standard.md` (sweep OB-2)
- `.agents/skills/powershell-change-budget-router/references/standard.md` (R1 OB-2, OB-4, R2)
- `.agents/skills/powershell-qa-gate/references/standard.md` (R1 OB-1, OB-5; sweep OB-2)
- `.agents/skills/pr-base-branch-merge-base/references/standard.md` (R1 OB-5, R2; sweep OB-4)
- `.agents/skills/python-change-budget-router/references/standard.md` (R1 OB-4)
- `.agents/skills/python-qa-gate/references/standard.md` (R1 OB-1, OB-5; sweep OB-2)
- `.agents/skills/remediation-handoff-atomic-planner/references/standard.md` (R1 OB-1)
- `.agents/skills/review-epic/references/standard.md` (sweep OB-3)
- `.agents/skills/review-feature/references/standard.md` (sweep OB-3)
- `.agents/skills/review-staged/references/standard.md` (sweep OB-3)
- `.agents/skills/skill-canonical-location-audit/references/standard.md` (sweep OB-1)
- `.agents/skills/test-execution-policy/references/standard.md` (R1 OB-1, OB-5)
- `.agents/skills/translate-copilot-to-claude/references/standard.md` (R2; sweep OB-3)
- `.agents/skills/update-status/references/standard.md` (sweep OB-3)

No SKILL.md, survey record, matrix, module, test or approval artifact was edited.

## Decisions (autonomous mode)

- D1: Sweep boundary. Items that state one concrete required value as a noun phrase (for example `OB-1 Required Shared Skills: \`policy-compliance-order\`.`) are complete statements of a requirement and are not generator truncations; they were left unchanged. The sweep fixed the classes the review named (fragment endings, dangling "above/below" references, placeholder objectives) and the related generator classes found in the same pass (dangling "these/this order" references, the "The skill defines its ... and applies it on every run" fallback, a mid-parenthesis truncation, and path-substitution defects). Reason: this keeps the fix in the defect class the review identified without rewriting the generated content.
- D2: `policy-compliance-order` OB-2 and `skill-canonical-location-audit` OB-1 copy substitution defects from the source `.agents/skills/*/SKILL.md` text (`.agents/skills/` named twice; `**` stripped from a glob). The contracts now state the tool-neutral intent. The source SKILL.md files are outside this cycle's edit scope and were not changed.
- D3: R1 count. The finding's location list names 26 items and its summary sentence states 25; all 26 listed items were fixed.
