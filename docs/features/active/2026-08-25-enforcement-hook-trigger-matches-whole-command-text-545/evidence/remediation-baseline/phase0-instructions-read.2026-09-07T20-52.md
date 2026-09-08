# Phase 0 — Policy Instructions Read (remediation cycle 2)

Timestamp: 2026-09-07T20-52
Task: [P0-T1]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)
Work Mode: full-bug
Plan: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T20-45.md

## Policy Order

The seven policy files were read in the order defined by `.claude/skills/policy-compliance-order/SKILL.md`:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/tonality.md`
6. `.claude/rules/powershell.md`
7. `.claude/rules/python.md`

## Files Read (explicit list)

- `CLAUDE.md` — 56 lines. Standing repository instructions: tone policy, policy compliance reading
  order, four-layer runtime architecture, orchestration checkpoint path.
- `.claude/rules/general-code-change.md` — 80 lines. Design principles, module rigor tiers reference,
  mandatory seven-stage toolchain loop, 500-line file size limit, error handling, naming, public API
  compatibility, dependency policy, I/O boundaries.
- `.claude/rules/general-unit-test.md` — 105 lines. Five core unit-test properties, coverage
  requirements (>= 85% line, >= 75% branch where measurable), Coverage Exclusion Policy, scenario
  completeness, Arrange-Act-Assert, external dependency prohibition, test file location, test
  categories, determinism infrastructure.
- `.claude/rules/quality-tiers.md` — 51 lines. T1-T4 tier definitions, source of truth
  (`quality-tiers.yml`), uniform-versus-tier-dependent gate matrix, rationale for uniform coverage
  thresholds and the PowerShell/bash branch-coverage exemption.
- `.claude/rules/tonality.md` — 80 lines. Required professional tone; humor, hyperbole prohibited;
  metaphor tightly restricted; evidence-first wording; difficult-message guidance.
- `.claude/rules/powershell.md` — 97 lines. PowerShell toolchain (PoshQC format, PoshQC analyze,
  no type-check stage, Pester), PowerShell 7+ compatibility, coding standards including the
  500-line cohesion limit, change budget (per-batch cap of 3 production and 3 test files), design
  seams, testing standards, deterministic test requirements, mocking rules, prohibited behaviors.
- `.claude/rules/python.md` — 100 lines. Python toolchain (Black, Ruff, Pyright, Pytest), coding
  standards, design rules, dependency seams, Pytest rules, prohibited behaviors.

## Command

Command: cat <each of the seven policy paths, in the order listed above>
EXIT_CODE: 0

## Output Summary

All seven policy files were located and read in the prescribed order. No policy file is missing.
No policy file was modified; `.claude/rules/**` and `.github/instructions/**` remain untouched, as
standing constraint "No policy edits" in the plan Scope section requires.

Constraints carried forward into this cycle's execution from the policy read:

- Toolchain order for PowerShell is format -> analyze -> test, with no type-check stage; restart from
  format if any stage fails or rewrites a file.
- Every touched PowerShell file stays at or under 500 lines.
- Per-batch PowerShell change cap is 3 production and 3 test files; this plan's four batches are each
  within the cap.
- Assertions must not be weakened, deleted, or reversed to make tests pass.
- Coverage regression on changed lines is a blocking finding; PowerShell line coverage threshold is
  >= 85% and no PowerShell branch-coverage gate applies.
- Tone in all authored prose and comments is professional, factual, and neutral.
