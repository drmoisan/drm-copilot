# Phase 0 — Policy instruction read record (issue #545)

Timestamp: 2026-08-25T10-19

Task: [P0-T1]

Policy Order: the seven repository policy files were read in the exact mandated order
below, ahead of any code or test change in this plan.

Files read, in order:

1. `CLAUDE.md` (59 lines) — standing instructions: tone policy, policy-compliance reading
   order, path-scoped language rules, four-layer runtime architecture.
2. `.github/copilot-instructions.md` (8 lines) — authoritative repository tone policy.
3. `.claude/rules/general-code-change.md` (80 lines) — cross-language code change policy:
   design principles, module rigor tiers, mandatory seven-stage toolchain loop, 500-line
   file cap, error handling, naming, dependencies, I/O boundaries.
4. `.claude/rules/general-unit-test.md` (105 lines) — cross-language unit test policy: the
   five core properties, coverage requirements (line >= 85% all tiers; branch threshold not
   applied to Pester), the Coverage Exclusion Policy, scenario completeness, AAA structure,
   external-dependency prohibitions, test file location, determinism infrastructure.
5. `.claude/rules/powershell.md` (97 lines) — PowerShell toolchain (format -> analyze ->
   test via the PoshQC MCP functions, restart on failure or auto-fix), PowerShell 7+
   compatibility, coding standards, the change budget (direct-mode ceiling of 2 production
   files; per-batch cap of 3 production and 3 test files), design seams, testing standards,
   deterministic test requirements, mocking rules, prohibited behaviors.
6. `.claude/rules/quality-tiers.md` (51 lines) — T1-T4 module rigor tiers, the
   uniform-versus-tier-dependent gate matrix, and the rationale for uniform coverage
   thresholds.
7. `.claude/rules/tonality.md` (80 lines) — required professional tone, prohibitions on
   humor and hyperbole, restricted metaphor use, evidence-first wording.

Command: `wc -l CLAUDE.md .github/copilot-instructions.md .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/rules/powershell.md .claude/rules/quality-tiers.md .claude/rules/tonality.md`

EXIT_CODE: 0

Output Summary: All seven policy files exist and were read in the mandated order. Line
counts confirm each file was present and non-empty (59, 8, 80, 105, 97, 51, 80; total 480).
Constraints carried forward into this plan: no file under `.claude/rules/` or
`.github/instructions/` may be modified; the PowerShell toolchain runs format -> analyze ->
test and restarts on any failure or auto-fix; the per-batch cap is 3 production and 3 test
files; every production, test, and reusable script file stays at or under 500 lines;
PowerShell line coverage must remain at or above 85% on changed or added production files
and no production file may leave the coverage denominator.
