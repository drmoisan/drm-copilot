# Phase 0 Policy Read — Remediation Cycle 1, F8 Radius Drift Detection (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P0-T1]
Worktree root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`
HEAD at read time: `bcf2de15` (the implementation commit under remediation)

Policy Order: the ten files below were read in the exact order the plan's [P0-T1] states, which
follows the `policy-compliance-order` skill's baseline order (standing instructions, then
cross-language code-change policy, then cross-language unit-test policy, then language-specific
rules for the languages in scope, then domain rules, then tonality).

## Files Read, In Order

1. `CLAUDE.md` — repository tone policy, policy-compliance reading order, four-layer runtime
   architecture, orchestration checkpoint path.
2. `.claude/rules/general-code-change.md` — design priorities, module rigor tier pointer, the
   mandatory seven-stage toolchain loop, the 500-line file-size limit, error-handling, naming,
   public-API compatibility, dependency policy, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — the five core unit-test properties, uniform coverage
   thresholds (line >= 85%, branch >= 75%), the coverage-exclusion policy, scenario completeness,
   Arrange-Act-Assert, the prohibition on temporary files and external dependencies in tests, the
   mirrored `tests/` layout requirement, test categories, determinism infrastructure.
4. `.claude/rules/python.md` — Black, Ruff, Pyright, Pytest command surface and ordering; PEP 8
   naming; strong typing; dataclasses; import policy; pytest rules; prohibited behaviors.
5. `.claude/rules/python-suppressions.md` — authorization requirement for `# noqa` and
   `# type: ignore`; the pre-authorized pattern list; the explicit non-authorization of F401, which
   is directly relevant to [P4-T2]'s `is_non_empty_string` import removal (root-cause fix required,
   suppression prohibited).
6. `.claude/rules/self-explanatory-code-commenting.md` — mandatory class and function docstrings,
   loop and comprehension intent comments, branching decision-logic comments, meta-what comments for
   multi-step blocks, the prohibition on numbered notes.
7. `.claude/rules/powershell.md` — PoshQC format/analyze/test MCP command surface and ordering;
   PowerShell 7+ compatibility; advanced-function standards; the 500-line cohesion limit; the change
   budget; the design-seam ladder; Pester v5 testing standards; deterministic-test requirements
   (no mutable machine PATH dependence); mocking rules.
8. `.claude/rules/parallel-orchestration.md` — the twenty-one orchestrator-checkpoint invariants
   (notably 8, 9, 15, 18, 20), the planner and manifest invariants, Cache Doctrine, the A8
   drift-event recording rule, `## Enum Ownership (F6/F7/F8 consume, never extend)`, and the
   `## F7 Seam` ownership statement. This file is NOT modified by this cycle.
9. `.claude/rules/quality-tiers.md` — the T1-T4 tier system, the uniform-versus-tier-dependent gate
   matrix, and the rationale for uniform coverage thresholds.
10. `.claude/rules/tonality.md` — required professional tone; prohibitions on humor, hyperbole, and
    decorative metaphor; evidence-first wording; the difficult-message and final-restraint rules.

## Constraints Carried Into Execution

- No file under `.claude/rules/**` or `.github/instructions/**` is modified by this cycle.
- Every file this cycle creates or edits must stay under 500 lines.
- Coverage floors are uniform: line >= 85%, branch >= 75%. The six pre-existing new Python drift
  modules are at 100% line and 100% branch and must not regress.
- Ruff F401 is explicitly not suppressible, so an import left unused by an edit must be removed in
  the same task.
- Python toolchain order is `black` -> `ruff` -> `pyright` -> `pytest`; PowerShell toolchain order is
  PoshQC format -> analyze -> test. A failure or a file rewrite restarts the affected loop at step 1.
- No temporary file may be created by any test.
- Wave-4 concurrency confinement (F6 issue #442 and F7 issue #440 execute concurrently) binds every
  shared-file edit, as recorded in the plan's `## Wave-4 Concurrency Constraints` section.

EXIT_CODE: 0
Output Summary: All ten policy files were read in the stated order. No policy document was modified.
No conflict was found between the plan's tasks and the policy set; the two constraints that most
directly shape execution are the 500-line file-size limit (which is why Phase 1 precedes every
behavioural fix) and the F401 non-suppression rule (which is why [P4-T2] removes the import in the
same task).
