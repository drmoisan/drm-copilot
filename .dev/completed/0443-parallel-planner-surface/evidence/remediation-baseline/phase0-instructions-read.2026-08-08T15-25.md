# Phase 0 — Policy Instructions Read (Remediation Cycle 1)

Timestamp: 2026-08-08T15-25

Task: [P0-T1]
Plan: `docs/features/active/2026-08-07-parallel-planner-surface-443/remediation-plan.2026-08-08T15-15.md`
Branch: `feature/parallel-planner-surface-443`

## Policy Order

The reading order defined by `.claude/skills/policy-compliance-order/SKILL.md` was followed:

1. `CLAUDE.md` — standing instructions (tone policy, policy-compliance order, architecture)
2. `.claude/rules/general-code-change.md` — cross-language code change policy
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy
4. Language- and domain-specific rules for the files in scope:
   1. `.claude/rules/python.md`
   2. `.claude/rules/python-suppressions.md`
   3. `.claude/rules/self-explanatory-code-commenting.md`
   4. `.claude/rules/typescript.md`
   5. `.claude/rules/typescript-suppressions.md`

## Files Read

| # | File | Purpose |
|---|---|---|
| 1 | `CLAUDE.md` | Standing instructions: tone policy, policy-compliance reading order, four-layer runtime architecture |
| 2 | `.claude/rules/general-code-change.md` | Design principles, mandatory seven-stage toolchain loop, 500-line file limit, I/O boundaries |
| 3 | `.claude/rules/general-unit-test.md` | Five core unit-test properties, coverage requirements (>= 85% line / >= 75% branch), test file location rule, no-temp-file rule |
| 4 | `.claude/rules/python.md` | Black / Ruff / Pyright / Pytest toolchain, PEP 8 naming, strong typing, Pytest rules |
| 5 | `.claude/rules/python-suppressions.md` | Pre-authorized `# noqa` and `# type: ignore` patterns; escalation path |
| 6 | `.claude/rules/self-explanatory-code-commenting.md` | Mandatory docstrings, loop/branch intent comments, no numbered notes |
| 7 | `.claude/rules/typescript.md` | Prettier / ESLint / TSC / Jest toolchain, ES modules, kebab-case filenames, testing standards |
| 8 | `.claude/rules/typescript-suppressions.md` | Pre-authorized `eslint-disable-next-line` and `@ts-expect-error` patterns |
| 9 | `.claude/rules/tonality.md` | Required professional tone; prohibition on humor, hyperbole, and decorative metaphor |
| 10 | `.claude/rules/quality-tiers.md` | T1–T4 tier system; uniform coverage thresholds across tiers |
| 11 | `.claude/rules/parallel-orchestration.md` | Parallel surface artifact invariants; F3/F4 scope boundary; enum ownership; known parity divergence classes |
| 12 | `.claude/skills/acceptance-criteria-tracking/SKILL.md` | AC source resolution by work mode, check-off protocol, preserve-text rule |
| 13 | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | Canonical evidence locations, `yyyy-MM-ddTHH-mm` timestamp format, artifact schema fields |
| 14 | `.claude/skills/atomic-plan-contract/SKILL.md` | Plan format, Phase 0 requirements, coverage evidence contract, no-SKIPPED rule |
| 15 | `.claude/skills/policy-compliance-order/SKILL.md` | The reading order itself and its baseline hard constraints |

## Constraints Acknowledged for This Cycle

- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Work Mode is `full-feature`; AC sources are `spec.md` (22 criteria) and `user-story.md` (8 criteria).
- Acceptance-criterion text is never modified; only `- [ ]` <-> `- [x]` state changes are permitted.
- 500-line hard limit on every production and test file.
- Evidence resolves under `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/<kind>/` with a `yyyy-MM-ddTHH-mm` filename component.
- Protected surfaces enumerated in the plan's Non-Negotiable Constraints section are not modified.
