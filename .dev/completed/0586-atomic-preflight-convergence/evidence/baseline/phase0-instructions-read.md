# Phase 0 — Policy Instructions Read (Issue #586)

Timestamp: 2026-08-28T22-02

Task: [P0-T1]
Feature: docs/features/active/2026-08-28-atomic-preflight-convergence-586
Work Mode: minor-audit
Plan: docs/features/active/2026-08-28-atomic-preflight-convergence-586/plan.2026-08-28T20-02.md

Policy Order: The baseline order defined by `.claude/skills/policy-compliance-order/SKILL.md` — (1) `CLAUDE.md`, (2) `.claude/rules/general-code-change.md`, (3) `.claude/rules/general-unit-test.md`, (4) domain-specific rules for the files in scope — extended in that same reading order with the four domain-specific policy files this change depends on. No language-specific rule file (`python.md`, `powershell.md`, `typescript.md`, `csharp.md`) applies, because the change touches Markdown only.

## Files Read (in reading order)

1. `CLAUDE.md` — repository standing instructions: tone policy, policy-compliance reading order, four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design principles, module rigor tiers, mandatory seven-stage toolchain loop, 500-line file size limit, error handling, naming, dependencies, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: five core principles, coverage requirements and exclusion policy, scenario completeness, Arrange–Act–Assert, external dependencies, test file location, test categories, determinism infrastructure.
4. `.claude/rules/tonality.md` — required professional tone; humor prohibited; hyperbole prohibited; metaphor tightly restricted; evidence-first wording. This is the policy that the P2-T5 tonality review measures the Phase 1 added lines against.
5. `.claude/rules/quality-tiers.md` — T1–T4 module rigor tiers and the uniform-versus-tier-dependent gate matrix, including the uniform line and branch coverage thresholds.
6. `.claude/rules/plan-acceptance-gates.md` — acceptance gates G1 through G9 applied to the shell commands an atomic plan states as acceptance conditions, the write-mode register, the checkable-literal definition and placeholder guard, and the deliberately uncovered sub-classes.
7. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — the non-overridable canonical evidence path scheme `<FEATURE>/evidence/<kind>/`, the forbidden `artifacts/` evidence sub-paths, the `yyyy-MM-ddTHH-mm` timestamp format, the machine-checkable evidence artifact schema, and the required `Output Summary:` field for baseline artifacts. Read because it governs the location and the required fields of every evidence artifact this plan creates.

All seven files above were read in full during this task. No file is listed that was not read.

## Evidence Location Compliance

Every artifact this plan creates resolves under `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/<kind>/`, per the non-overridable evidence path clause. No `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, or `artifacts/evidence/` path is used. No non-canonical evidence path was supplied by the delegation prompt, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record applies to this run.

## Toolchain Applicability Noted at Read Time

The four production files in scope are Markdown. No formatter, linter, or type checker in this repository takes them as input, so the mandatory toolchain loop in `.claude/rules/general-code-change.md` yields no format, lint, or type-check baseline command for this change. The single applicable automated gate is the existing test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, captured as a baseline by [P0-T6]. No language with a mandatory coverage policy is in scope, so the Coverage Evidence Contract produces no obligations for this plan.

This artifact records a policy read and no command; it therefore carries no `Command:` or `EXIT_CODE:` field, per the field conventions in the plan's `## Evidence Locations (Canonical, Non-Overridable)` section.
