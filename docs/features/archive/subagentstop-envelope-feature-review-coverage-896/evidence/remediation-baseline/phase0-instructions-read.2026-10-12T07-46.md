# Phase 0 Policy Reads (Remediation cycle 1, Issue #896)

Timestamp: 2026-10-12T07-46
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> language-specific (Python) -> quality tiers and plan acceptance gates -> evidence conventions

Files read (in order):

1. `CLAUDE.md`
2. `.claude/rules/tonality.md`
3. `.claude/rules/general-code-change.md`
4. `.claude/rules/general-unit-test.md`
5. `.claude/rules/python.md`
6. `.claude/rules/python-suppressions.md`
7. `.claude/rules/quality-tiers.md`
8. `.claude/rules/plan-acceptance-gates.md`
9. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

Notes:
- Root `CLAUDE.md` states no coverage thresholds, so the defaults apply: line >= 85%, branch >= 75% (general-unit-test.md threshold precedence).
- `quality-tiers.yml` exists at the repository root.
- Evidence `Timestamp` values are local host-clock time per the evidence-conventions skill.
