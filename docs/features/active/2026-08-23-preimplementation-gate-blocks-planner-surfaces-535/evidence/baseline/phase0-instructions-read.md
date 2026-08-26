# Phase 0 Policy-Read Evidence — issue #535

Timestamp: 2026-08-23T21-24

Policy Order: P0-T1 -> P0-T2 -> P0-T3 -> P0-T4, matching the required order in
`.claude/skills/policy-compliance-order/SKILL.md` and `CLAUDE.md`.

## Files Read (in order)

1. [P0-T1] `CLAUDE.md` (repository root) — read in full (59 lines).
2. [P0-T2] `.claude/rules/general-code-change.md` — read in full (81 lines).
3. [P0-T3] `.claude/rules/general-unit-test.md` — read in full (106 lines).
4. [P0-T4] `.claude/rules/powershell.md` — read in full (98 lines).

## Constraints Recorded for This Feature

- PowerShell toolchain order: format (`mcp__drm-copilot__run_poshqc_format`) ->
  analyze (`mcp__drm-copilot__run_poshqc_analyze`) -> test
  (`mcp__drm-copilot__run_poshqc_test`). Type checking is not applicable to PowerShell.
  Restart from format whenever a stage fails or changes files.
- File size limit: no production, test, or reusable script file may exceed 500 lines.
- Coverage: line coverage >= 85% uniformly (T1-T4). Pester does not measure branch
  coverage, so no branch-coverage gate applies to PowerShell. No production file may be
  excluded from coverage measurement.
- Change budget: per-batch cap of at most 3 production files and 3 test files. Four
  production hook copies are in scope, so implementation is split into two batches.
- Determinism: tests must not depend on network, machine PATH, implicit working
  directory, external services, or temporary files.
- Tone policy: professional, factual, neutral; no humor, hyperbole, or decorative
  metaphor in any authored content.
- Policy documents under `.claude/rules/` and `.github/instructions/` must not be
  modified.

EXIT_CODE: 0

Output Summary: All four policy files read in the required order. No policy conflict
with the plan of record was identified. PowerShell is the primary language in scope,
with a targeted pytest leg for the two push-down bundle-parity contract suites.
