# Phase 0 — Policy Instruction Reads (Remediation Cycle 1)

Timestamp: 2026-08-09T06-18

Task: [P0-T1]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1
Branch: feature/parallel-mutation-protocol-442
HEAD at read time: a9e2463c

Policy Order: CLAUDE.md, .claude/rules/general-code-change.md, .claude/rules/general-unit-test.md, .claude/rules/python.md, .claude/rules/python-suppressions.md, .claude/rules/powershell.md, .claude/rules/quality-tiers.md, .claude/rules/self-explanatory-code-commenting.md, .claude/rules/orchestrator-state.md, .claude/rules/parallel-orchestration.md, .claude/rules/tonality.md

## Files Read (in the required order)

1. `CLAUDE.md` — repository tone policy, policy-compliance reading order, four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` — design principles, module rigor tiers, seven-stage toolchain loop, 500-line file cap, error handling, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — five core test properties, uniform coverage floors (line >= 85%, branch >= 75%), coverage-exclusion prohibition, scenario completeness, Arrange-Act-Assert, prohibition on temporary files in tests, test file location, determinism infrastructure.
4. `.claude/rules/python.md` — Black / Ruff / Pyright / Pytest toolchain and order, PEP 8 naming, strong typing, dataclasses, dependency seams, Pytest rules, prohibited behaviors.
5. `.claude/rules/python-suppressions.md` — suppression authorization requirement, pre-authorized `# noqa` patterns (including S603 with its verbatim comment format), explicitly unauthorized codes, enforcement checklist.
6. `.claude/rules/powershell.md` — PoshQC MCP toolchain (format -> analyze -> test), PowerShell 7+ compatibility, coding standards, change budget, design seams, mocking rules, coverage floors.
7. `.claude/rules/quality-tiers.md` — T1-T4 tier definitions, uniform-vs-tier-dependent gate matrix, uniform coverage thresholds rationale.
8. `.claude/rules/self-explanatory-code-commenting.md` — mandatory class and function docstrings, loop and comprehension intent comments, branching decision-logic comments, multi-step meta-what comments, prohibition on numbered notes.
9. `.claude/rules/orchestrator-state.md` — orchestrator-state remediation-cycle, human-interaction, complexity-assessment, model-routing-receipt, and require-model-routing invariants; foreign-schema prohibition.
10. `.claude/rules/parallel-orchestration.md` — parallel artifact invariants 1-21, planner P1-P9, manifest M1-M7, cache doctrine, omitted epic fields, concurrency bound, drift-event recording rule, enum ownership (F6/F7/F8 consume and never extend), F7 seam, F3 scope boundary, enforcement.
11. `.claude/rules/tonality.md` — required professional tone, prohibitions on humor, hyperbole, and metaphor, evidence-first wording.

## Binding Constraints Extracted for This Cycle

- 500-line hard cap on every production, test, and reusable script file (`general-code-change.md` § File Size Limit).
- No file under `.claude/rules/**` may be modified (plan Constraint 2; `policy-compliance-order` hard constraints).
- Coverage must hold line >= 85% and branch >= 75% and must not regress below the Phase 0 baseline figures.
- `hypothesis` is absent and stays absent; determinism is supplied by seeded `random.Random(seed)` with the seed printed on failure (`general-unit-test.md` § Determinism Infrastructure).
- No temporary files in tests (`general-unit-test.md` § External Dependencies).
- F6 consumes F3's nine parallel enums and never extends them (`parallel-orchestration.md` § Enum Ownership).
- `# noqa` suppressions require a pre-authorized pattern; S603's authorized comment format is recorded verbatim in `python-suppressions.md`.
- Google-style docstrings with `Args:` / `Returns:` / `Raises:`; intent comments above loops and comprehensions; decision-logic comments on branches.

Command: (documentary task; policy files read with the Read tool, no shell command executed)
EXIT_CODE: 0
Output Summary: All 11 policy files in the required order were read in full before any code or test change. No policy file was modified. Extracted constraints recorded above and binding on every subsequent task in this cycle.
