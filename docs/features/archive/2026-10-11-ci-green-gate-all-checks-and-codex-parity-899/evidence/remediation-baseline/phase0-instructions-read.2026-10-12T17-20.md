# Phase 0 Instructions Read (P0-T1, remediation cycle 2)

Timestamp: 2026-10-12T17-57

Policy Order: CLAUDE.md and tonality; general code change; general unit test; Python rules; quality tiers and plan acceptance gates; evidence and timestamp conventions.

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
- The root `CLAUDE.md` states no coverage thresholds, so the default line (85%) and branch (75%) thresholds apply.
- The evidence `Timestamp` is read from the host clock when the recorded command runs.

Spec/User-Story Presence: none

Search: Glob of `docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/{spec.md,user-story.md}` returned no files (minor-audit fail-closed rule satisfied).
