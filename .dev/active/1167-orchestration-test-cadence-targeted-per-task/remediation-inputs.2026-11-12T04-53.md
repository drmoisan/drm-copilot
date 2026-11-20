# Remediation Inputs — Issue 1167

Timestamp: 2026-11-12T04-53
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate
Head: `d789aa821f900b36dfc884952ffc45126e15a042`
Base: `main`, merge base `228e6f8c4606e53f36963dc9aa57d71b4882b49e`
Source review artifacts:
- `docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/policy-audit.2026-11-12T04-53.md`
- `docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/code-review.2026-11-12T04-53.md`
- `docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/feature-audit.2026-11-12T04-53.md`
Remediation plan target: `docs/features/active/2026-11-11-orchestration-test-cadence-targeted-per-task-1167/remediation-plan.2026-11-12T04-53.md`

Path note: the single finding is autonomous but changes the canonical rule text in six copies, the planner surfaces, the templates, the contract suite, and ledger entry `0011`, so it is a design-scope fix and takes the full path.

## Findings requiring remediation

### F1 — The phase-gate rule has no provision for a phase that ends with an `[expect-fail]` test, and the bug template contradicts the rule

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is wording in repository skill, agent, and template files plus their contract test rows and ledger blocks; the resolution stays within the owner rule and spec D4, and it needs no external system, CI result, or owner decision.
Finding-Scope: design

- Location: `## Test Cadence (Mandatory)`, bullet `Phase gate (after each phase)`, in `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, and their three bundle copies; `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` (Phases 1 and 2) and its bundle; the `TCW-CANONICAL` and `TCW-TEMPLATE` rows of `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`.
- Observed: the rule requires the last task of every phase between Phase 0 and the final QA phase to be a `[phase-gate]` task that closes only after one clean pass of the full unit suite, with exceptions only for Phase 0 and the final QA phase. The bug template's Phase 2 ends with an `[expect-fail]` regression test that fails until the Phase 3 fix, so a gate there cannot pass. The template shows a gate only in Phase 3, so its Phases 1 and 2 violate the rule it cites, and `TCW-TEMPLATE-BUG` pins exactly one gate line. `## Expect-Fail Test Tasks` holds no gate provision.
- Required change: add one rule to the canonical section in all six copies (byte-identical base and bundle) that states how a phase ending with an `[expect-fail]` task is gated. Either the gate of that phase accepts exactly the expected failures recorded in the `[expect-fail]` task's evidence and fails on any other failure, or that phase carries no gate task and the next phase's gate covers it. Also state whether a phase that changes no file needs a gate task. Bring the bug, feature, and refactor templates (and bundles) and the planner surfaces into agreement with the chosen rule. Keep the D2 vocabulary: no #1094 sweep token, no `Targeted runs are allowed`, and none of the seven per-task sweep tokens.
- Tests: extend `TCW-CANONICAL` with a required token for the new rule; adjust `TCW-TEMPLATE` so it asserts the template's gate layout matches the rule (including the `[expect-fail]` phase of the bug template); confirm the row fails when the new wording is removed from one copy.
- Ledger: refresh the `0011` revert blocks for every edited non-identical source so each `Current` fence occurs exactly once, and fold in CR1 (the `## Summary` sentence about the `Merge commit:` stand-in, which now reads `pending (PR #1168)`). The commit carries `reduction: 0011`.
- Verification required: task checks per the cadence; one `[phase-gate]` pass; the final QA loop with one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run compared with the Phase 0 baseline (Pester 95.80% lines; pytest 97.11% lines, 94.37% branches); `generate_codex_agent_variants --check` exit 0 if any Codex planner base changes; the five ledger suites, `planning-contract-wording.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, and the push-down resource contracts pass. Then re-review.

## Non-blocking items (no remediation required in this PR)

- CR1: ledger `0011` `## Summary` stand-in sentence is stale; fold into the F1 commit.
- CR2: `## Mandatory Toolchain Loop` "all seven stages" sentence reads against the stage-7-in-CI sentence; optional qualification.
- CR3: the sweep roots omit `CLAUDE.md` and `.github/copilot-instructions.md`; optional.
- AC14 is pending CI and is not a finding.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix. No serial, single-process, shuffled, or reversed gate runs.
- Evidence is append-only; no artifact records an absolute path.
- No new Python file; no change to `scripts/dev_tools/atomic_executor/`, the plan validators, `.claude/hooks/validate-planner-output.ps1`, or `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
- No baseline task, baseline evidence, or baseline comparison is reduced.
