# Phase 0 — Instructions Read (Remediation Cycle, Issue #191)

Timestamp: 2026-06-17T00-18

Policy Order: Per `.claude/skills/policy-compliance-order/SKILL.md`, the required reading order is CLAUDE.md (standing), general-code-change, general-unit-test, then language- and domain-specific rules for files in scope (PowerShell, CI workflows), then the tier system.

Files read in order:
1. `CLAUDE.md` — repository tone, policy-compliance reading order, four-layer architecture, orchestration checkpoint path.
2. `.claude/rules/general-code-change.md` — cross-language code change policy, design principles, mandatory toolchain loop, file size limit, error handling.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy, coverage requirements (line >= 85%, branch >= 75%), coverage exclusion policy, determinism requirements.
4. `.claude/rules/powershell.md` — PowerShell toolchain (PoshQC format -> analyze -> test), wrapper-seam design, mocking rules, coverage thresholds.
5. `.claude/rules/ci-workflows.md` — CI workflow authoring; deliberately-failing nested command pattern (exit-code reset / explicit exit 0) for `pwsh` steps.
6. `.claude/rules/quality-tiers.md` — T1–T4 tier system, uniform coverage thresholds (line >= 85%, branch >= 75%) across all tiers.

Supporting skills consulted for this remediation cycle:
- `.claude/skills/atomic-plan-contract/SKILL.md` — plan format, Phase 0 evidence, final QA loop, coverage evidence contract.
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — canonical evidence path `<FEATURE>/evidence/<kind>/`, ISO-8601 timestamps, artifact schema fields.
- `.claude/skills/acceptance-criteria-tracking/SKILL.md` — AC source resolution (minor-audit -> issue.md only) and check-off protocol.

Notes:
- Files in scope: `.github/workflows/publish-mcp-npm.yml` (GitHub Actions YAML, validated by actionlint) and evidence documentation only. No PowerShell production or test code is changed in this remediation.
- No policy document under `.claude/rules/` or `.github/instructions/` is modified.
