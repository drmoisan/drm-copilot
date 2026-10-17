# Remediation cycle 2 - Phase 0 instructions read (P0-T1)

Timestamp: 2026-10-16T19-36
Command: Read tool, each path below in the listed order; Grep `Work Mode` in FEATURE/issue.md; Glob docs/features/active/2026-10-16-ci-merge-queue-for-main-952/{spec.md,user-story.md}
EXIT_CODE: 0
Output Summary: twenty-three files read in the required order; Work Mode full-bug; spec.md present; user-story.md absent; no policy file modified.

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
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/remediation-inputs.2026-10-16T17-18.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-audit.2026-10-16T17-18.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/code-review.2026-10-16T17-18.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/feature-audit.2026-10-16T17-18.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/coverage-comparison.2026-10-16T17-08.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/ci-rows-windows.2026-10-16T17-08.md
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/ci-rows-linux.2026-10-16T17-08.md

Work Mode: full-bug (FEATURE/issue.md line 12: `- Work Mode: full-bug`)
spec.md: present
user-story.md: absent

Notes:
- quality-tiers.yml exists; `.claude/hooks` and `.codex/hooks` are T3.
- The root CLAUDE.md states no coverage thresholds, so the defaults govern (line >= 85%; no PowerShell branch gate).
- No policy file under `.claude/rules/` or `.github/instructions/` was modified.
