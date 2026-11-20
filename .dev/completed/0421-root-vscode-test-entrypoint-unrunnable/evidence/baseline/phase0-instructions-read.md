# Phase 0 — Policy Instructions Read (#421)

Timestamp: 2026-07-26T05-03

Task: [P0-T1]

Policy Order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/typescript.md`
5. `.claude/rules/typescript-suppressions.md`
6. `.claude/rules/quality-tiers.md`
7. `.claude/rules/tonality.md`
8. `.claude/rules/ci-workflows.md`

Files Read (explicit list, all eight, in the order above):

- [x] `CLAUDE.md` — standing instructions: tone policy, policy compliance reading order, four-layer runtime architecture, orchestration checkpoint path.
- [x] `.claude/rules/general-code-change.md` — design principles, mandatory seven-stage toolchain loop (format → lint → type-check → architecture → unit tests → contract → integration), 500-line file limit, error handling, naming, I/O boundaries.
- [x] `.claude/rules/general-unit-test.md` — five core unit-test properties, uniform coverage thresholds (line >= 85%, branch >= 75%), coverage exclusion policy, Arrange–Act–Assert, prohibition on temporary files in tests, test file location under `tests/`.
- [x] `.claude/rules/typescript.md` — TypeScript toolchain (`npm run format`, `npm run lint`, `npm run typecheck`, tests), coding standards, ESLint stack, testing standards, coverage thresholds.
- [x] `.claude/rules/typescript-suppressions.md` — authorization requirement for ESLint/TS suppressions, pre-authorized single-line patterns, prohibited file-level patterns.
- [x] `.claude/rules/quality-tiers.md` — T1–T4 tier system, uniform-vs-tier-dependent gate matrix, uniform coverage thresholds rationale.
- [x] `.claude/rules/tonality.md` — required professional tone, prohibitions on humor/hyperbole, restricted metaphors, evidence-first wording.
- [x] `.claude/rules/ci-workflows.md` — deliberately-failing nested-command `$LASTEXITCODE` pattern for `pwsh` workflow steps; enforcement via `modified-workflow-needs-green-run`.

Applicability notes for this change set:

- Languages in scope: TypeScript (one new test file) and GitHub Actions YAML. No Python, PowerShell, or C# files are touched.
- `.claude/rules/ci-workflows.md`: the new workflow `_root-typescript-tests.yml` contains no deliberately-failing nested command, so the `$LASTEXITCODE` reset pattern is not triggered. Plain steps with default failure propagation apply. The `modified-workflow-needs-green-run` obligation is satisfied by the Phase 5 green run against the branch head.
- `.claude/rules/general-unit-test.md`: the new guard test reads a versioned repository file (`package.json`) — no temporary files, no mocks, no wall-clock or RNG use, deterministic and order-independent. Location `tests/unit/vscode-test-removal.test.ts` complies with the `tests/` tree requirement.

Output Summary: All eight policy files were read in the specified order prior to any code or test change. No policy file was modified.
