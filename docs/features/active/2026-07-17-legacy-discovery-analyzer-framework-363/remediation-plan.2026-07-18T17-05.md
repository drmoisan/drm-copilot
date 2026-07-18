# legacy-discovery-analyzer-framework — Remediation Plan (Cycle 3)

- **Issue:** #363
- **PR:** https://github.com/drmoisan/drm-copilot/pull/378
- **Owner:** drmoisan
- **Last Updated:** 2026-07-18T17-05
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Remediation cycle:** 3 (final pass of the shared cap of 3)
- **Feature branch:** feature/legacy-discovery-analyzer-framework-363 (head 64a94ad2)
- **Integration branch:** epic/legacy-discovery-and-parity-integration

## Requirements Source

Sole requirements source for this remediation cycle:
`docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/remediation-inputs.2026-07-18T17-05.md`

Finding: Blocking failed required CI check. `Extension Tests (ubuntu-latest)` and
`Extension Tests (windows-latest)` fail (run 29652993218) on
`extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
(assertion `expect(missing).toEqual([])` at line 137; CI result 1 failed, 1885 passed).
The four #365 agent files mirrored into the bundle in cycle 2 exist on disk under
`extensions/drm-copilot/resources/claude-customizations/.claude/agents/` but are listed in
no `pack-manifests/*.json` `paths` array:

- `.claude/agents/legacy-parity-analyst.md`
- `.claude/agents/migration-coverage-reviewer.md`
- `.claude/agents/requirements-reconciler.md`
- `.claude/agents/runtime-characterization-analyst.md`

Required resolution: register the four paths in
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`,
preserving the existing alphabetical ordering in the agents section. Constraints
(non-negotiable):

- Do NOT modify the repo `.claude/agents/*.md` source files.
- Do NOT modify the mirrored bundle files under
  `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- Keep `core.json` valid JSON with the file's existing formatting conventions.

## CI Test Command (Repo-Defined)

The required check is defined by `.github/workflows/_drm-copilot-extension-tests.yml`
(job `drm-copilot Extension Tests (${{ matrix.os }})`). Its steps are
`npm --prefix extensions/drm-copilot ci` followed by
`npm --prefix extensions/drm-copilot run test` (step "Run extension unit/integration tests").
The `test` script in `extensions/drm-copilot/package.json` is `node run-jest.cjs`, which
runs Jest with `jest.config.cjs` and forwards extra arguments. Phase 0 re-verifies and
records this before baseline capture; the repo-defined command is preferred for all
extension test tasks in this plan.

## Evidence Location Invariant (Non-Overridable)

All evidence artifacts produced by this plan MUST resolve under
`docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/<kind>/`
(`evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/other/`).
No `artifacts/` evidence path is permitted. Timestamp format is `yyyy-MM-ddTHH-mm`. Each
command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
Coverage artifacts record numeric line and branch percentages in `Output Summary:`.

## Language and Coverage Scope

- Languages in scope: TypeScript (extension fix and verification) and Python (regression QC).
- Coverage is mandatory for both languages: line coverage >= 85%, branch coverage >= 75%,
  and no regression (`.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`,
  `.claude/rules/typescript.md`, `.claude/rules/python.md`).
- TypeScript toolchain order per `.claude/rules/typescript.md`: format -> lint -> type-check
  -> test. Coverage command: `npm run test:coverage`.
- Python toolchain order per `.claude/rules/python.md`: Black -> Ruff -> Pyright -> Pytest
  with `--cov --cov-branch`.
- The fix edits one JSON resource file; no TypeScript or Python production code changes are
  expected. Coverage for both languages must therefore be non-regressing relative to the
  Phase 0 baselines.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline and Policy Compliance

- [x] [P0-T1] Read the policy files in the required precedence order (`CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/typescript.md`; `.claude/rules/typescript-suppressions.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; then `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`) and record the read by appending a `## Remediation Cycle 3 (2026-07-18T17-05)` section to `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/phase0-instructions-read.md`.
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` contains a Remediation Cycle 3 section with `Timestamp:`, `Policy Order:`, and an explicit list of every file read in the order above; prior cycle content (initial run, Cycle 1, Cycle 2) is preserved unchanged.
- [x] [P0-T2] Determine and record the exact extension test command CI runs by reading the `scripts` block of `extensions/drm-copilot/package.json` and the "Run extension unit/integration tests" step of `.github/workflows/_drm-copilot-extension-tests.yml`, confirming the CI command is `npm --prefix extensions/drm-copilot run test` (script `test` = `node run-jest.cjs`).
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-ci-test-command.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:` (the file reads performed), `EXIT_CODE: 0`, and `Output Summary:` quoting the workflow step `run:` line and the `test` script value, and stating the resolved command used by every extension test task in this plan.
- [x] [P0-T3] Install extension dependencies exactly as CI does by running `npm --prefix extensions/drm-copilot ci` from the worktree root.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-baseline-npm-ci.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` (package count / install result).
- [x] [P0-T4] Capture the pre-fix TypeScript formatting baseline by running `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` from `extensions/drm-copilot` (the non-mutating equivalent of the repo `format` script) before any manifest change.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-baseline-prettier.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and any files needing formatting).
- [x] [P0-T5] Capture the pre-fix TypeScript lint baseline by running `npm --prefix extensions/drm-copilot run lint` before any manifest change.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-baseline-eslint.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T6] Capture the pre-fix TypeScript type-check baseline by running `npm --prefix extensions/drm-copilot run typecheck` before any manifest change.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-baseline-typecheck.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error count).
- [x] [P0-T7] [expect-fail] Capture the fail-before evidence for the blocking finding by running the targeted failing suite `npm --prefix extensions/drm-copilot run test -- claude-pack-manifest-completeness` before any manifest change; the test "lists every bundled .claude agent, skill, and hook file in some pack manifest" is expected to FAIL, naming the four missing manifest entries.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/regression-testing/remediation3-fail-before-manifest-completeness.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (non-zero), and `Output Summary:` recording the failed test name and the four `.claude/agents/` paths reported in the `missing` array.
- [x] [P0-T8] [expect-fail] Capture the pre-fix TypeScript test-and-coverage baseline by running the full extension suite in coverage mode `npm --prefix extensions/drm-copilot run test:coverage` before any manifest change; exactly one failure is expected (the test named in P0-T7).
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-baseline-ts-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (non-zero), and `Output Summary:` including numeric baseline line-coverage and branch-coverage percentages from the coverage text summary, the passed/failed test counts, and confirmation that the sole failure is the claude-pack-manifest-completeness test.
- [x] [P0-T9] Capture the pre-fix Black formatting baseline by running `poetry run black --check .` from the worktree root before any manifest change.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-baseline-black.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and file count).
- [x] [P0-T10] Capture the pre-fix Ruff lint baseline by running `poetry run ruff check .` from the worktree root before any manifest change.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-baseline-ruff.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T11] Capture the pre-fix Pyright type-check baseline by running `poetry run pyright` from the worktree root before any manifest change.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-baseline-pyright.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T12] Capture the pre-fix Pytest coverage baseline by running `poetry run pytest --cov --cov-branch --cov-report=term-missing` from the worktree root before any manifest change; the Python suite is expected to pass (the failing test is TypeScript-only).
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation3-baseline-pytest-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` including numeric baseline line-coverage and branch-coverage percentages and the passed test count.

### Phase 1 — Manifest Registration

Scope guard for all Phase 1 tasks: edit pack-manifest JSON files only. Do not modify any
repo `.claude/agents/*.md` source file and do not modify any mirrored bundle file under
`extensions/drm-copilot/resources/claude-customizations/.claude/**` or
`extensions/drm-copilot/resources/codex-and-agents-customizations/**` payload trees.

- [x] [P1-T1] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` to add the four agent paths to the `paths` array preserving alphabetical order in the agents section: insert `.claude/agents/legacy-parity-analyst.md` and `.claude/agents/migration-coverage-reviewer.md` between `.claude/agents/human-exception-runbook.md` and `.claude/agents/orchestrator.md`; insert `.claude/agents/requirements-reconciler.md` and `.claude/agents/runtime-characterization-analyst.md` between `.claude/agents/prd-feature.md` and `.claude/agents/staged-review.md`. Preserve the file's existing two-space indentation and comma style.
  - Acceptance: `git diff -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` shows exactly four added lines (the four paths at the positions above) and no removed lines; the file parses as valid JSON (for example `node -e "JSON.parse(require('fs').readFileSync('extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json','utf8'))"` exits 0); the agents block of the `paths` array remains in strict alphabetical order.
- [x] [P1-T2] Run a scope-boundary manifest-completeness scan: (a) enumerate every bundled agent (`.claude/agents/*.md`), hook (`.claude/hooks/*.ps1`), and skill (`.claude/skills/*/SKILL.md`) file under `extensions/drm-copilot/resources/claude-customizations/.claude/` and compare against the union of `paths` across `extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json`, excluding only the three documented pre-existing exceptions in `claude-pack-manifest-completeness.test.ts` (`.claude/agents/pr-author.md`, `.claude/hooks/enforce-completion-helpers.ps1`, `.claude/hooks/validate-pr-author-output.ps1`); (b) run the parallel manifest-completeness contract by executing `npm --prefix extensions/drm-copilot run test -- codex-agents-customizations` against `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/*.json`. Register any additional missing file in the appropriate manifest and record each registration (or record `none`). If any blocking issue OUTSIDE manifest registration and the bundle contract is discovered, STOP execution of this plan and report it as a further new finding — do not extend this plan.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/remediation3-manifest-completeness-scan.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:` (the enumeration comparison and the codex contract test command), `EXIT_CODE:`, and `Output Summary:` listing every additional file registered (path plus target manifest) or explicitly stating `Additional missing files: none`, plus the codex-and-agents contract test result; any out-of-scope blocking issue is recorded as STOP-reported rather than remediated.

### Phase 2 — Verification and Finish

Loop rules: run the TypeScript QC steps in order (format -> lint -> type-check -> test);
run the Python QC steps in order (Black -> Ruff -> Pyright -> Pytest with coverage). If any
step in a language's loop fails or changes files, remediate and restart that language's loop
from its first step (P2-T1 for TypeScript, P2-T7 for Python) until all steps pass in a single
clean pass. No-SKIPPED rule: every command-bearing task in this phase must execute its stated
command and record the result; `EXIT_CODE: SKIPPED` is not a valid outcome for any task in
this plan.

- [x] [P2-T1] Run the final-QC TypeScript formatting gate `npm --prefix extensions/drm-copilot run format` on the post-fix tree; if it rewrites any file, keep the rewrites and restart the TypeScript loop from this task.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-finalqc-prettier.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming the final clean pass produced no file modifications (`git status --porcelain` unchanged before/after the final run).
- [x] [P2-T2] Run the final-QC TypeScript lint gate `npm --prefix extensions/drm-copilot run lint` on the post-fix tree; if it fails, remediate and restart the TypeScript loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-finalqc-eslint.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` from the final clean pass.
- [x] [P2-T3] Run the final-QC TypeScript type-check gate `npm --prefix extensions/drm-copilot run typecheck` on the post-fix tree; if it fails, remediate and restart the TypeScript loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-finalqc-typecheck.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` reporting 0 errors from the final clean pass.
- [x] [P2-T4] Run the full extension test suite with the exact CI command `npm --prefix extensions/drm-copilot run test` on the post-fix tree; if any test fails, remediate and restart the TypeScript loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-finalqc-extension-tests.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording the passed test count and zero failures.
- [x] [P2-T5] Run the final-QC TypeScript coverage gate `npm --prefix extensions/drm-copilot run test:coverage` on the post-fix tree and record the numeric post-fix coverage values; if any test fails, remediate and restart the TypeScript loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-finalqc-ts-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` including numeric post-fix line-coverage and branch-coverage percentages and zero failures.
- [x] [P2-T6] Capture pass-after evidence for the blocking finding by running the targeted suite `npm --prefix extensions/drm-copilot run test -- claude-pack-manifest-completeness` on the post-fix tree and confirming every test in the file passes, including "lists every bundled .claude agent, skill, and hook file in some pack manifest".
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/regression-testing/remediation3-pass-after-manifest-completeness.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording all tests in the target file passed with zero failures.
- [x] [P2-T7] Run the final-QC Python formatting gate `poetry run black --check .` on the post-fix tree; if it reports changes needed, apply `poetry run black .` and restart the Python loop from this task.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-finalqc-black.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` from the final clean pass.
- [x] [P2-T8] Run the final-QC Python lint gate `poetry run ruff check .` on the post-fix tree; if it fails or auto-fixes files, remediate and restart the Python loop from P2-T7.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-finalqc-ruff.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` from the final clean pass.
- [x] [P2-T9] Run the final-QC Python type-check gate `poetry run pyright` on the post-fix tree; if it fails, remediate and restart the Python loop from P2-T7.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-finalqc-pyright.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` reporting 0 errors from the final clean pass.
- [x] [P2-T10] Run the final-QC Python test-and-coverage gate `poetry run pytest --cov --cov-branch --cov-report=term-missing` on the post-fix tree; if any test fails, remediate and restart the Python loop from P2-T7.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-finalqc-pytest-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` including numeric post-fix line-coverage and branch-coverage percentages, the passed test count, and zero failures.
- [x] [P2-T11] Produce the coverage delta and threshold verification artifact comparing the Phase 0 baselines (P0-T8 TypeScript, P0-T12 Python) against the post-fix coverage (P2-T5 TypeScript, P2-T10 Python), confirming for Python line coverage >= 85% and branch coverage >= 75%, and for both languages no coverage regression attributable to this remediation.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-coverage-delta.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:` and records, per language, baseline numeric line/branch percentages, post-fix numeric line/branch percentages, the delta, and an explicit PASS/FAIL verdict against the thresholds and the no-regression requirement; verdict is PASS.
- [x] [P2-T12] Commit the change set (the edited `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, any additional manifest edits from P1-T2, and the evidence artifacts under `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/`) on `feature/legacy-discovery-analyzer-framework-363` with a professional, factual commit message.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/remediation3-commit.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording the commit SHA and confirming `git status --porcelain` is empty after the commit and that no `.claude/agents/*.md` source file and no bundle payload file under `extensions/drm-copilot/resources/claude-customizations/.claude/` appears in the commit diff.
- [x] [P2-T13] Push the feature branch to the remote with `git push origin feature/legacy-discovery-analyzer-framework-363`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/remediation3-push.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording the pushed commit SHA matching the local branch head.
- [x] [P2-T14] Verify PR #378 is mergeable by running `gh pr view 378 --json mergeable` (re-polling if GitHub reports `UNKNOWN` while recomputing) and confirming the mergeable state is `MERGEABLE`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation3-pr-mergeable.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` showing `"mergeable": "MERGEABLE"` for PR #378.

## Exit Condition (from remediation inputs)

- `claude-pack-manifest-completeness.test.ts` passes on the post-fix tree and the full
  extension test suite passes locally under the exact CI command (P2-T4, P2-T6).
- Full Python QC loop passes with coverage thresholds intact: line >= 85%, branch >= 75%,
  no regression (P2-T7 through P2-T11).
- Branch pushed; PR #378 mergeable state is MERGEABLE (P2-T13, P2-T14). Required CI checks
  (Extension Tests ubuntu-latest and windows-latest) concluding success against the live
  head SHA, and the reaudit (code-review, feature-audit, policy-audit), are orchestrated by
  the caller after this plan completes; they are outside this plan's task scope.
