# Phase 0 — Policy Compliance Reads

- **Task:** [P0-T1] through [P0-T5]
- **Issue:** #505
- **Plan:** `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/plan.2026-08-23T23-23.md`

Timestamp: 2026-08-25T09-17

Policy Order: The reading order given by the `policy-compliance-order` skill was followed exactly:

1. `CLAUDE.md` — standing instructions, always loaded; carries the repository tone policy, the policy-compliance reading order, and the four-layer architecture description.
2. `.claude/rules/general-code-change.md` — cross-language code change policy.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy.
4. Language- and domain-specific rules for the files in scope (Python is the only language in scope for this change):
   - `.claude/rules/python.md`
   - `.claude/rules/python-suppressions.md`
   - `.claude/rules/quality-tiers.md`
   - `.claude/rules/plan-acceptance-gates.md`

## Files Read (explicit list)

| # | Task | File path | Read in full |
| --- | --- | --- | --- |
| 1 | [P0-T1] | `CLAUDE.md` | yes |
| 2 | [P0-T2] | `.claude/rules/general-code-change.md` | yes |
| 3 | [P0-T3] | `.claude/rules/general-unit-test.md` | yes |
| 4 | [P0-T4] | `.claude/rules/python.md` | yes |
| 5 | [P0-T4] | `.claude/rules/python-suppressions.md` | yes |
| 6 | [P0-T4] | `.claude/rules/quality-tiers.md` | yes |
| 7 | [P0-T4] | `.claude/rules/plan-acceptance-gates.md` | yes |

Seven policy files read. All paths resolve relative to the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a75166ce0ad92cc5f`.

## Constraints Recorded from the Reads

- **[P0-T2] — `.claude/rules/general-code-change.md`.** File Size Limit: no production code, test
  code, or reusable script file may exceed **500 lines**. Markdown documentation files are exempt.
  Mandatory Toolchain Loop: seven stages in order — formatting, linting, type checking,
  architecture-boundary tests, unit tests, contract/schema compatibility checks, integration tests —
  restarting from step 1 if any stage fails or auto-fixes a file, until all stages pass in a single
  consecutive pass. For this Python-only change the applicable stages are formatting (Black),
  linting (Ruff), type checking (Pyright), and unit tests (Pytest).
- **[P0-T3] — `.claude/rules/general-unit-test.md`.** Determinism Infrastructure: all test code must
  be deterministic; banned APIs in test code include real wall-clock waits. This is the rule the
  candidate B repair satisfies by substituting an ordered synchronous thread stand-in for the
  wall-clock-dependent race. Coverage Exclusion Policy: no production file may be excluded from
  coverage measurement; permitted `exclude` entries are non-production paths only.
- **[P0-T4] — `.claude/rules/python.md`.** Toolchain commands: `poetry run black .`,
  `poetry run ruff check .`, `poetry run pyright`,
  `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Pytest rules include "No sleeps,
  retries, or timing hacks."
- **[P0-T4] — `.claude/rules/python-suppressions.md`.** All `# noqa` and `# type: ignore`
  suppressions require a pre-authorized pattern or explicit user approval. No suppression is planned
  by this change.
- **[P0-T4] — `.claude/rules/quality-tiers.md`.** Uniform coverage thresholds across T1-T4: line
  coverage >= 85 percent, branch coverage >= 75 percent, no regression on changed lines. The
  repository tier map file named by this rule does not exist at this repository root; that gap is
  recorded as an out-of-scope observation in the plan and is not created by this fix.
- **[P0-T4] — `.claude/rules/plan-acceptance-gates.md`.** Acceptance gates G1 through G6. Coverage
  arguments must name an importable dotted module with the `=` form
  (`--cov=scripts.dev_tools.fix_all_runtime`), never a filesystem path, because the path spelling
  collects no data and the assertion cannot fail. Asserted search literals must be short,
  single-line, and non-interpolated.

EXIT_CODE: 0

Output Summary: All seven policy files were read in full in the order prescribed by the
`policy-compliance-order` skill and extended by [P0-T4]. No policy file was modified. The three
constraints that bind this change were recorded: the 500-line file-size limit (which forces the
two-new-test-file layout in the plan's File-Size Budget section), the Determinism Infrastructure ban
on real wall-clock waits in test code (which is the rule the candidate B repair restores compliance
with), and the uniform coverage thresholds of 85 percent line and 75 percent branch.
