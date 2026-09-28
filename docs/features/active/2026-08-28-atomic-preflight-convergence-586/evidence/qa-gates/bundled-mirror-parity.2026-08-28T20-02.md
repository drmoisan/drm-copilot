# QA Gate — Bundled-Mirror Parity by Blob Hash (Issue #586)

Timestamp: 2026-08-28T22-10

Task: [P2-T10]
Feature: docs/features/active/2026-08-28-atomic-preflight-convergence-586
Baseline reference: `docs/features/active/2026-08-28-atomic-preflight-convergence-586/evidence/baseline/baseline-bundled-mirror-hashes.2026-08-28T20-02.md` ([P0-T5])

## Command 1 — `atomic-plan-contract` pair

Command: git hash-object .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md

EXIT_CODE: 0

Output Summary:

The command printed exactly two 40-character hexadecimal SHAs:

```
243fc8629eb4d168d385e583c805dc2c104437eb
243fc8629eb4d168d385e583c805dc2c104437eb
```

The two SHAs are identical to each other, so `.claude/skills/atomic-plan-contract/SKILL.md` and its bundled mirror are byte-identical after Phase 1. The [P1-T1] through [P1-T9] edits were applied identically to both copies.

The printed SHA `243fc8629eb4d168d385e583c805dc2c104437eb` differs from the baseline SHA `e3b2198e4dac4c82d6c883bd370f04367a79e96e` that the [P0-T5] artifact transcribes for both of these paths. Both copies were therefore in fact edited, rather than both left untouched.

## Command 2 — `remediation-handoff-atomic-planner` pair

Command: git hash-object .claude/skills/remediation-handoff-atomic-planner/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md

EXIT_CODE: 0

Output Summary:

The command printed exactly two 40-character hexadecimal SHAs:

```
1e944becfd8a31128fb1b7546b3c055e76a4d5a2
1e944becfd8a31128fb1b7546b3c055e76a4d5a2
```

The two SHAs are identical to each other, so `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` and its bundled mirror are byte-identical after Phase 1. The [P1-T10] through [P1-T13] edits were applied identically to both copies.

The printed SHA `1e944becfd8a31128fb1b7546b3c055e76a4d5a2` differs from the baseline SHA `698f563ca0e8f5e651b422841f0e462349bd6ade` that the [P0-T5] artifact transcribes for both of these paths. Both copies were therefore in fact edited.

## Baseline-to-End-State Comparison

| # | Path | Baseline SHA ([P0-T5]) | Post-Phase-1 SHA | Differs from baseline |
| --- | --- | --- | --- | --- |
| 1 | `.claude/skills/atomic-plan-contract/SKILL.md` | `e3b2198e4dac4c82d6c883bd370f04367a79e96e` | `243fc8629eb4d168d385e583c805dc2c104437eb` | yes |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | `e3b2198e4dac4c82d6c883bd370f04367a79e96e` | `243fc8629eb4d168d385e583c805dc2c104437eb` | yes |
| 3 | `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | `698f563ca0e8f5e651b422841f0e462349bd6ade` | `1e944becfd8a31128fb1b7546b3c055e76a4d5a2` | yes |
| 4 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md` | `698f563ca0e8f5e651b422841f0e462349bd6ade` | `1e944becfd8a31128fb1b7546b3c055e76a4d5a2` | yes |

Byte-identity within each pair holds at baseline and after Phase 1. Per the plan's `## Scope and Toolchain Applicability` section, that carries every content verdict recorded against a target file — the additive-only verdict of [P2-T1] and [P2-T2], the consistency verdicts of [P2-T3] and [P2-T4], the tonality verdict of [P2-T5], and the cross-reference verdict of [P2-T6] — over to its bundled mirror without a separate review of the mirror.

## Verdict

Both commands exited 0. Each printed two identical SHAs, and each printed SHA differs from its [P0-T5] baseline value. Neither failure condition — two differing SHAs from a command, or a printed SHA equal to its baseline — occurred. Gate passes.
