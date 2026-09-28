# Phase 0 Policy Read Record — [P0-T1]

Timestamp: 2026-08-24T22-19

Issue: #524
Feature: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524`
Plan: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/plan.2026-08-23T23-24.md`
Task: [P0-T1]
Work Mode: full-bug
Languages in scope: Python, TypeScript

Policy Order: The order defined by `.claude/skills/policy-compliance-order/SKILL.md` and enumerated explicitly in plan task [P0-T1]: standing instructions (`CLAUDE.md`), then cross-language code-change policy, then cross-language unit-test policy, then the language-specific rules for the languages in scope (Python then TypeScript, each followed by its suppression policy), then the tier, tonality, and plan-acceptance-gate rules, then the evidence and timestamp conventions skill.

## Files Read, In Order

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/typescript.md`
7. `.claude/rules/typescript-suppressions.md`
8. `.claude/rules/quality-tiers.md`
9. `.claude/rules/tonality.md`
10. `.claude/rules/plan-acceptance-gates.md`
11. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

All eleven files were read in full from the worktree at
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586`.

## Constraints Carried Forward From These Reads

- Toolchain order per language is format, lint, type-check, test; restart from format if any stage fails or changes files (`.claude/rules/general-code-change.md`, `.claude/rules/python.md`, `.claude/rules/typescript.md`).
- Uniform coverage gates: line coverage at or above 85 percent, branch coverage at or above 75 percent, and no regression on changed lines (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`).
- No production or test file may exceed 500 lines (`.claude/rules/general-code-change.md`).
- Tests must not create or use temporary files and must not depend on the filesystem, network, or wall-clock time (`.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/typescript.md`).
- Suppressions require a pre-authorized pattern or explicit user approval (`.claude/rules/python-suppressions.md`, `.claude/rules/typescript-suppressions.md`).
- All evidence resolves under `<FEATURE>/evidence/<kind>/`; any `artifacts/`-rooted evidence path is forbidden (`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`).
- Timestamps use `yyyy-MM-ddTHH-mm`.
- Professional, factual, neutral tone in all authored content (`.claude/rules/tonality.md`, `CLAUDE.md`).

## Noted Exception Authorized By The Plan

The plan authorizes amending `.claude/rules/orchestrator-state.md` and its push-down copy in Phase 3 (task [P3-T5]), as a deliberate exception to the baseline constraint in `.claude/skills/policy-compliance-order/SKILL.md` against modifying policy documents under `.claude/rules/`. That exception is recorded here for continuity; no policy file is modified in Phase 0, Phase 1, or Phase 2.

## Evidence Location

EVIDENCE_LOCATION_OVERRIDE_REJECTED: not applicable. No non-canonical evidence path was supplied by the delegation prompt or the plan. All artifacts are written under
`docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/<kind>/`.
