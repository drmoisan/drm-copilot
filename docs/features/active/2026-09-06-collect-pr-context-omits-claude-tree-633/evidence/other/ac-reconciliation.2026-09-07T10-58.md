Timestamp: 2026-09-07T10-58

# Acceptance Criteria Reconciliation

## AC1: every non-renamed changed path routes into exactly one bucket, no silent drop

Satisfied by the P2-T1 production fix (terminal `else` branch added to the
bucket-partition loop in `collector-core.ts`) and the P2-T2 pass-after result
(`evidence/regression-testing/pass-after-bucket-partition.2026-09-07T10-58.md`,
EXIT_CODE 0), together with the P3-T2 no-double-bucketing result (EXIT_CODE 0, scoped
run of `classifies pull/invalid refs and partitions core/rename buckets`). No path
matching none of the three existing predicates is dropped; it now lands in `bucketDocs`.

## AC2: collector-core.test.ts regression test demonstrates the previously-dropped path lands in bucketDocs, and fails pre-fix

Satisfied by the P1-T1 test addition (`routes previously-dropped paths into bucketDocs
(fail-before: current code drops them)` in
`extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts`), the P1-T2
fail-before artifact
(`evidence/regression-testing/fail-before-bucket-partition.2026-09-07T10-58.md`,
EXIT_CODE 1), and the P2-T2 pass-after artifact
(`evidence/regression-testing/pass-after-bucket-partition.2026-09-07T10-58.md`,
EXIT_CODE 0).

## AC3: collector-output.test.ts confirms the previously-dropped path appears in the rendered overview

Satisfied by the P3-T3 test result (EXIT_CODE 0, scoped run of `renders a
previously-dropped non-core/non-docs-prefixed path in the Changed files overview
section` in `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts`),
asserting `.claude/skills/example/SKILL.md` and `src/example.ts` render strictly between
the "Changed files overview" and "Issue digests" section headings.

## AC4: the existing empty-bucket fixture in collector-output-freshness.test.ts continues to pass unmodified

Satisfied by the P3-T4 result
(`evidence/regression-testing/freshness-fixture-unchanged.2026-09-07T10-58.md`,
EXIT_CODE 0, all 3 tests passed). `git status --porcelain` confirmed the file itself was
not modified by this plan.

## AC5: rename precedence, .py/.ps1 core routing, and docs/.github/AGENTS docs routing unchanged, no double-bucketing

Satisfied by the P3-T2 result (EXIT_CODE 0): the three added negative assertions
(`bucketDocs` does not contain `new.py`; `bucketRenames` does not contain `src/app.py`;
`bucketCore` does not contain the docs fixture path) pass, confirming the new terminal
`else` branch does not double-bucket a rename, a `.py` file, or a `docs/`-prefixed file.

## AC6: scripts/dev_tools/pr_context/collector.py explicitly left unmodified; Known Limitation section documents the identical defect

- `git diff main -- scripts/dev_tools/pr_context/collector.py` produced no output
  (verified in this session; DIFF_EXIT 0, zero-byte diff), confirming the Python parity
  module is byte-unmodified relative to `main`.
- `grep -F "## Known Limitation (Python Parity Module)"
  docs/features/active/2026-09-06-collect-pr-context-omits-claude-tree-633/spec.md`
  returned exactly one match, confirming the spec's "Known Limitation" section
  documents the identical defect and the recommendation to file a follow-up bug.

## AC7: full TypeScript toolchain pass completed (Prettier -> ESLint -> tsc -> Jest with coverage) with npm ci run first

Satisfied by the P0-T6 `npm ci` result
(`evidence/baseline/npm-ci.2026-09-07T10-58.md`, EXIT_CODE 0) and the Phase 4 results,
all recorded with EXIT_CODE 0 in the same pass with no file changes from P4-T1:
- `evidence/qa-gates/format.2026-09-07T10-58.md` (Prettier, EXIT_CODE 0, before/after
  porcelain snapshots identical)
- `evidence/qa-gates/lint.2026-09-07T10-58.md` (ESLint, EXIT_CODE 0)
- `evidence/qa-gates/typecheck.2026-09-07T10-58.md` (tsc, EXIT_CODE 0)
- `evidence/qa-gates/test-coverage.2026-09-07T10-58.md` (Jest with coverage, EXIT_CODE 0,
  2737 passed)

No restart of the QA loop was required; all four steps passed in a single pass.

## AC8: line coverage >= 85% and branch coverage >= 75% maintained on changed files, no production file excluded from coverage measurement

Satisfied by the P5-T2 coverage-delta artifact
(`evidence/qa-gates/coverage-delta.2026-09-07T10-58.md`):
- `collector-core.ts`: post-change Lines 97.89% (>= 85), Branches 89.71% (>= 75). PASS.
- `collector-output.ts`: no regression (Lines 97.73%, Branches 82.28%, unchanged vs
  baseline). PASS.
- `summary-helpers.ts`: no regression (Lines 93.56%, Branches 87.84%, unchanged vs
  baseline). PASS.

`extensions/drm-copilot/jest.config.cjs`'s `collectCoverageFrom` array still reads
exactly `["src/**/*.ts", "!src/**/*.d.ts"]` (line 17, confirmed by direct read) — no new
production-path exclusion was added by this plan.

This is the final task of the plan; all 8 acceptance criteria in spec.md are reconciled
against recorded evidence.
