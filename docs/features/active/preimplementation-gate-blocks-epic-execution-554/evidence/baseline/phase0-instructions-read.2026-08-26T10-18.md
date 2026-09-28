# Phase 0 — Policy Compliance Reads (issue #554)

Timestamp: 2026-08-26T10-18

Policy Order: the order defined by `.claude/skills/policy-compliance-order/SKILL.md`, extended with
the two additional rule files named by task [P0-T1] of
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/plan.2026-08-26T08-40.md`.

## Files Read, In Order

1. `CLAUDE.md` — standing instructions: tone policy, policy-compliance reading order, four-layer
   Claude Code runtime architecture, orchestration checkpoint path.
2. `.claude/rules/general-code-change.md` — design principles, module rigor tiers, mandatory
   seven-stage toolchain loop, 500-line file size limit, error handling, naming, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — five core unit-test properties, coverage requirements
   (line >= 85%, branch >= 75% where measurable), Coverage Exclusion Policy, scenario completeness,
   Arrange–Act–Assert, prohibition on temporary files in tests, test file location rule.
4. `.claude/rules/powershell.md` — PowerShell toolchain (format → analyze → test; type checking not
   applicable), PowerShell 7+ compatibility, coding standards, change budget (2 production files in
   direct mode; per-batch cap of 3 production and 3 test files), design seams, Pester testing
   standards, mocking rules, prohibited behaviors.
5. `.claude/rules/quality-tiers.md` — T1–T4 module rigor tiers, `quality-tiers.yml` as source of
   truth, uniform-versus-tier-dependent gate matrix, rationale for uniform coverage thresholds.
6. `.claude/rules/plan-acceptance-gates.md` — atomic-plan acceptance gates G1 through G6, scope of
   invocation, checkable-literal definition and placeholder guard, message formatting prohibitions,
   authoring guidance for plan authors.

## Additional Policy Context Loaded

The following are auto-loaded standing instructions and were also in effect during this read:
`.claude/rules/tonality.md`, `.claude/rules/orchestrator-state.md`,
`.claude/rules/parallel-orchestration.md`, `.claude/rules/benchmark-baselines.md`, and
`.claude/rules/ci-workflows.md`.

## Binding Constraints Carried Into Execution

- No file under `.claude/rules/`, `.claude/skills/`, `.github/instructions/`, and not
  `.github/copilot-instructions.md`, is written by this feature.
- Every production `.ps1` file written stays at or under 500 lines.
- PowerShell toolchain order is format, then analyze, then test. Type checking is not applicable.
- Per-batch PowerShell budget: at most 3 production files and 3 test files.
- Line coverage must remain at or above 85%. Pester measures no branch coverage, so no
  branch-coverage gate applies.
- Temporary files in tests are prohibited.
- All evidence artifacts resolve to
  `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/<kind>/`.
