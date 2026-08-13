# Remediation Inputs: Codex-Native Parallel Orchestration (#467)

**Timestamp:** 2026-08-12T01-42  
**Review Status:** REMEDIATION_REQUIRED  
**Authoritative requirements source for remediation:** This file  
**Feature requirements sources:** `spec.md`, `user-story.md`  
**Base:** `main` at merge-base `fe0413d4aca1e76b2d02d05701fba79a887d5405`  
**Reviewed head:** `35323f412f752467f3d787326399218d9564c8b2`

## Required Context Package

- `artifacts/pr_context.summary.txt`
- `artifacts/pr_context.appendix.txt`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/policy-audit.2026-08-12T01-42.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/code-review.2026-08-12T01-42.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/feature-audit.2026-08-12T01-42.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/plan.2026-08-10T20-25.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/spec.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/user-story.md`

## Enumerated Fix List

### R1 — Python new/modified file coverage

**Files:** Added production modules `_parallel_orchestrator_state_completion_receipts.py`, `_parallel_orchestrator_state_mutation_receipts.py`, `parallel_codex_readiness_filesystem.py`, `push_down_codex_routing_merge.py`, and `validate_parallel_codex_readiness.py`; modified `parallel_kickoff_contract.py`, `resolve_codex_deployment.py`, and `resolve_codex_topology.py`; directly related tests.

**Required behavior:** Add deterministic tests so every added module reaches at least 90% line coverage and each modified production file is at least its baseline line coverage. Preserve current public behavior, deterministic diagnostics, typing, and cross-runtime parity.

**Current evidence:** Added files are 87.66%, 89.00%, 81.97%, 79.43%, and 82.58%. Modified files regress 100% to 97.18%, 100% to 98.21%, and 100% to 98.65%.

**Verification:** Run Black, Ruff, Pyright, then full Pytest branch coverage in one clean loop. Persist numeric baseline, post-change, new-file, and modified-file comparison artifacts under this feature's `evidence/baseline/` and `evidence/qa-gates/` subtrees.

### R2 — PowerShell source-attributable coverage

**Files:** All 25 changed/new authoritative production files under root `.codex/hooks/*.ps1` and `.codex/scripts/*.ps1`, their byte-identical bundle mirrors, Pester coverage configuration/seams, and related tests.

**Required behavior:** Produce numeric source-attributable coverage for every changed/new authoritative PowerShell runtime file. Every new file must meet the repository's 90% target, every modified file must meet the applicable threshold without regression, and aggregate line coverage must remain above policy floors. External-process green tests alone are insufficient.

**Current evidence:** `artifacts/pester/powershell-coverage.xml` attributes only 27 changed lines, all in `.codex/hooks/enforce-completion-consistency.ps1`; the other 24 changed runtime files are absent from source nodes.

**Verification:** Run the repository PoshQC format, analyze, and coverage-enabled Pester loop. Parse the resulting XML and emit an exact 25-file coverage inventory with no omitted authoritative source path. Preserve root/bundle byte parity.

### R3 — TypeScript modified-file coverage regression

**Files:** `claude-routing-merge.ts`, `codex-topology-resolver.ts`, `orchestration-artifacts.ts`, `orchestrator-state-codex-model-routing.ts`, `parallel-kickoff-artifact.ts`, and focused tests.

**Required behavior:** Add focused tests until each modified file is non-regressing relative to baseline. Preserve all nine added production files at or above 90% and repository aggregate coverage above policy thresholds.

**Current evidence:** Line coverage regresses 98.05% to 94.91%, 97.39% to 96.25%, 100% to 98.33%, 95.66% to 93.75%, and 100% to 98.08% respectively.

**Verification:** Run Prettier, ESLint, `tsc`, and full Jest LCOV coverage in one clean loop. Persist numeric per-file comparison evidence under `evidence/qa-gates/`.

### R4 — Dedicated parallel authority contract

**Files:** `.codex/agents/parallel-planner.toml`, `.codex/agents/parallel-orchestrator.toml`, the two byte-identical bundled copies, and `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1` or a more focused existing contract suite.

**Required behavior:** The planner persona prompt must name `parallel-planner-workspace`; the orchestrator persona prompt must name `parallel-orchestrator-workspace`. The prompt, `default_permissions`, and associated entry skills must agree exactly. Add a regression assertion that reads the actual prompt bodies and fails on an ordinary `orchestrator-workspace` authority.

**Verification:** Run PoshQC/Pester contracts and root/bundle byte-parity checks. Confirm both dedicated authority strings across skill, profile default, prompt, and bundle.

### R5 — Python documentation and intent comments

**Files:** All seven added Python production modules and affected added Python test helpers.

**Required behavior:** Apply `.agents/skills/self-explanatory-code-commenting/SKILL.md` completely: every callable has a purpose and complete parameters/returns/raises/side-effects contract; every loop/comprehension has an immediate intent comment; non-trivial branches and multi-step blocks have intent comments. Comments must explain intent rather than restate syntax.

**Current evidence:** Ten added production callables have no docstring; the other reviewed docstrings omit required contract sections; 67 added production loop/comprehension nodes lack immediate intent comments.

**Verification:** Perform an explicit policy checklist/AST audit, then run Black, Ruff, Pyright, and the relevant/full Pytest suite. Do not suppress documentation checks.

### R6 — Acceptance/evidence reconciliation and final QA

**Files:** `spec.md`, `user-story.md`, the issue-update mapping receipt, coverage comparison receipts, and new remediation evidence only after the implementation evidence supports PASS.

**Required behavior:** Keep S-D02, S-D13, S-D14, U01, U19, and U20 unchecked until remediated evidence passes. Preserve S-D15, U21, and the issue-level exact-current-head CI criterion unchecked/deferred until hosted CI exists. Regenerate fresh PR context at the remediated head and perform a full post-remediation feature review.

**Verification:** All four language toolchain loops pass in required order, coverage reconciles numerically for every changed language, all review artifacts validate through MCP, and only locally proven criteria are checked.

## Do Not Do

- Do not narrow the feature diff or omit a changed language from coverage reconciliation.
- Do not weaken coverage thresholds, exclude production source, fabricate per-file coverage, or use behavioral test counts as numeric source coverage.
- Do not add lint/type/coverage suppressions or approved-exception text to bypass findings.
- Do not change public orchestration semantics beyond the dedicated authority correction and testability seams strictly required for source coverage.
- Do not modify `.claude/`; retain the verified 150-file byte-invariance contract.
- Do not break root/bundle byte parity or publisher pack membership.
- Do not silently skip a toolchain step, coverage command, plan preflight, or artifact validator.
- Do not mark any hosted exact-current-head criterion complete before hosted CI exists for that exact head.
- Do not introduce manual QA steps; remediation must remain fully automated or fail closed.

## Planner Routing Receipt

The canonical resolver returned the following exact standalone C4 deployment before delegation:

```json
{
  "phase": "S6_remediation_planning",
  "c3_overlay_applied": false,
  "c3_overlay_reason": null,
  "complexity_band": "C4",
  "deployment_agent": "atomic-planner-c4",
  "execution_context": "standalone",
  "logical_agent": "atomic-planner",
  "model": "gpt-5.6-sol",
  "model_reasoning_effort": "max",
  "orchestration_complexity_ceiling": "C4"
}
```

Delegation must use `agent_type="atomic-planner-c4"`, `fork_turns="none"`, and omit model/reasoning overrides.

## Required Planner Output

Update exactly `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-plan.2026-08-12T01-42.md` in place. Produce atomic sequential `[P#-T#]` tasks, Phase 0 policy/baseline evidence, test-first correction tasks, four-language final QA/coverage loops, acceptance reconciliation, post-remediation full review, canonical evidence paths, and no placeholders. Do not implement the plan.
