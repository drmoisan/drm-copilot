# Phase 0 — Policy and remediation-input reads (remediation cycle 1, issue #952)

Timestamp: 2026-10-16T15-17
Task: [P0-T1]
Command: Read tool, files in the order listed below; Grep `Work Mode` in FEATURE/issue.md; Glob `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/{spec.md,user-story.md}`
EXIT_CODE: 0
Output Summary: 21 files read in the required order; Work Mode full-bug; spec.md present; user-story.md absent; no policy file modified.

Policy Order:
CLAUDE.md
.github/copilot-instructions.md
.claude/rules/tonality.md
.github/instructions/tonality.instructions.md
.claude/rules/general-code-change.md
.github/instructions/general-code-change.instructions.md
.claude/rules/general-unit-test.md
.github/instructions/general-unit-test.instructions.md
.claude/rules/quality-tiers.md
quality-tiers.yml
.claude/rules/powershell.md
.github/instructions/powershell-code-change.instructions.md
.github/instructions/powershell-unit-test.instructions.md
.claude/rules/python.md
.github/instructions/python-unit-test.instructions.md
.claude/rules/plan-acceptance-gates.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-inputs.2026-10-16T12-51.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-audit.2026-10-16T12-51.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/code-review.2026-10-16T12-51.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/feature-audit.2026-10-16T12-51.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/coverage-comparison.2026-10-16T12-40.md

Work Mode: full-bug (FEATURE/issue.md line 12: `- Work Mode: full-bug`)
spec.md: present
user-story.md: absent

No policy file under .claude/rules/ or .github/instructions/ was modified.
