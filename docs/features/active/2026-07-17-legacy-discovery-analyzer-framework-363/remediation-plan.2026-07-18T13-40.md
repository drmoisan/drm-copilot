# legacy-discovery-analyzer-framework — Remediation Plan (Cycle 2)

- **Issue:** #363
- **PR:** https://github.com/drmoisan/drm-copilot/pull/378
- **Owner:** drmoisan
- **Last Updated:** 2026-07-18T13-40
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Remediation cycle:** 2
- **Feature branch:** feature/legacy-discovery-analyzer-framework-363 (merged with integration head; commit 1d31dcd0)
- **Integration branch:** epic/legacy-discovery-and-parity-integration

## Requirements Source

Sole requirements source for this remediation cycle:
`docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/remediation-inputs.2026-07-18T13-40.md`

Finding: Blocking bundled-payload-drift. The test
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
fails because four repo `.claude/agents/` files added by sibling #365 are missing from the
bundled payload `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`:

- `.claude/agents/legacy-parity-analyst.md`
- `.claude/agents/migration-coverage-reviewer.md`
- `.claude/agents/requirements-reconciler.md`
- `.claude/agents/runtime-characterization-analyst.md`

Required resolution: byte-identical mirror copy of each file INTO the bundle directory.
Constraints (non-negotiable):

- Do NOT run `python -m scripts.dev_tools.push_down_claude_customizations` — it copies
  bundle->consumer, the wrong direction for this repair.
- Do NOT modify the repo `.claude/agents/*.md` source files.
- Do NOT touch `.claude/agent-memory/**` or `.claude/settings.local.json` (exempt from the
  mirror assertion).

## Evidence Location Invariant (Non-Overridable)

All evidence artifacts produced by this plan MUST resolve under
`docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/<kind>/`
(`evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/other/`).
No `artifacts/` evidence path is permitted. Timestamp format is `yyyy-MM-ddTHH-mm`. Each
command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
Coverage artifacts record numeric line and branch percentages in `Output Summary:`.

## Language and Coverage Scope

- Language in scope: Python only. Coverage is mandatory: line coverage >= 85%, branch coverage
  >= 75%, and no regression on changed lines (`.claude/rules/general-unit-test.md`,
  `.claude/rules/quality-tiers.md`, `.claude/rules/python.md`).
- Toolchain order per `.claude/rules/python.md`: Black -> Ruff -> Pyright -> Pytest with coverage.
- The mirrored files are Markdown resources; no production Python code changes are expected.
  Coverage must therefore be non-regressing relative to the Phase 0 baseline.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline and Policy Compliance

- [x] [P0-T1] Read the policy files in the required precedence order (`CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/python.md`; then `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`) and record the read by appending a `## Remediation Cycle 2 (2026-07-18T13-40)` section to `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/phase0-instructions-read.md`.
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` contains a Remediation Cycle 2 section with `Timestamp:`, `Policy Order:`, and an explicit list of every file read in the order above; prior cycle content (initial run and Cycle 1) is preserved unchanged.
- [x] [P0-T2] Capture the pre-fix Black formatting baseline by running `poetry run black --check .` on the feature branch before any bundle change.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation2-baseline-black.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and file count).
- [x] [P0-T3] Capture the pre-fix Ruff lint baseline by running `poetry run ruff check .` on the feature branch before any bundle change.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation2-baseline-ruff.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T4] Capture the pre-fix Pyright type-check baseline by running `poetry run pyright` on the feature branch before any bundle change.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation2-baseline-pyright.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T5] [expect-fail] Capture the fail-before evidence for the blocking finding by running the targeted failing test `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` before any bundle change; the test is expected to FAIL, naming the four missing bundle files.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/regression-testing/remediation2-fail-before-bundled-payload.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (non-zero), and `Output Summary:` recording the failed test id and the missing-file assertion detail (the four `.claude/agents/` paths).
- [x] [P0-T6] [expect-fail] Capture the pre-fix Pytest coverage baseline by running `poetry run pytest --cov --cov-branch --cov-report=term-missing` on the feature branch before any bundle change; exactly one failure is expected (the test named in P0-T5).
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation2-baseline-pytest-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:` (non-zero), and `Output Summary:` including numeric baseline line-coverage and branch-coverage percentages, the passed/failed test counts, and confirmation that the sole failure is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.

### Phase 1 — Bundle Mirror

Scope guard for all Phase 1 tasks: repair direction is repo -> bundle only. Do not run
`python -m scripts.dev_tools.push_down_claude_customizations`; do not modify any
`.claude/agents/*.md` source file; do not touch `.claude/agent-memory/**` or
`.claude/settings.local.json`.

- [x] [P1-T1] Copy `.claude/agents/legacy-parity-analyst.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/legacy-parity-analyst.md`.
  - Acceptance: a byte-identical comparison passes for the pair — `git hash-object .claude/agents/legacy-parity-analyst.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/legacy-parity-analyst.md` prints two identical hashes; the source file is unmodified per `git status --porcelain -- .claude/agents/legacy-parity-analyst.md` (empty output).
- [x] [P1-T2] Copy `.claude/agents/migration-coverage-reviewer.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/migration-coverage-reviewer.md`.
  - Acceptance: a byte-identical comparison passes for the pair — `git hash-object .claude/agents/migration-coverage-reviewer.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/migration-coverage-reviewer.md` prints two identical hashes; the source file is unmodified per `git status --porcelain -- .claude/agents/migration-coverage-reviewer.md` (empty output).
- [x] [P1-T3] Copy `.claude/agents/requirements-reconciler.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/requirements-reconciler.md`.
  - Acceptance: a byte-identical comparison passes for the pair — `git hash-object .claude/agents/requirements-reconciler.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/requirements-reconciler.md` prints two identical hashes; the source file is unmodified per `git status --porcelain -- .claude/agents/requirements-reconciler.md` (empty output).
- [x] [P1-T4] Copy `.claude/agents/runtime-characterization-analyst.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/runtime-characterization-analyst.md`.
  - Acceptance: a byte-identical comparison passes for the pair — `git hash-object .claude/agents/runtime-characterization-analyst.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/runtime-characterization-analyst.md` prints two identical hashes; the source file is unmodified per `git status --porcelain -- .claude/agents/runtime-characterization-analyst.md` (empty output).
- [x] [P1-T5] Run a scope-boundary drift scan: enumerate every repo `.claude/**` file excluding `.claude/agent-memory/**` and `.claude/settings.local.json`, compare each against its counterpart under `extensions/drm-copilot/resources/claude-customizations/.claude/**` (existence plus content hash), mirror any additional drifted file repo->bundle byte-for-byte, and record each additional file mirrored (or `none`) in the evidence artifact. If any blocking issue OUTSIDE the `.claude/**` mirror scope is discovered, STOP execution of this plan and report it as a further new finding — do not extend this plan.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/remediation2-bundle-drift-scan.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:` (the comparison command(s) used), `EXIT_CODE:`, and `Output Summary:` listing every additional drifted file found and mirrored (path plus matching hash pair) or explicitly stating `Additional drifted files: none`; any out-of-scope blocking issue is recorded as STOP-reported rather than remediated.

### Phase 2 — Final QC Loop and Verification

Loop rule: run the four QC steps in order (Black -> Ruff -> Pyright -> Pytest with coverage).
If any step fails or changes files, remediate and restart the loop from P2-T1 until all four
steps pass in a single clean pass. `EXIT_CODE: SKIPPED` is not a valid outcome for any task in
this phase.

- [x] [P2-T1] Run the final-QC formatting gate `poetry run black --check .` on the post-fix tree; if it reports changes needed, apply `poetry run black .` and restart the loop from this task.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation2-finalqc-black.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` from the final clean pass.
- [x] [P2-T2] Run the final-QC lint gate `poetry run ruff check .` on the post-fix tree; if it fails or auto-fixes files, remediate and restart the loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation2-finalqc-ruff.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` from the final clean pass.
- [x] [P2-T3] Run the final-QC type-check gate `poetry run pyright` on the post-fix tree; if it fails, remediate and restart the loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation2-finalqc-pyright.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` reporting 0 errors from the final clean pass.
- [x] [P2-T4] Run the final-QC test-and-coverage gate `poetry run pytest --cov --cov-branch --cov-report=term-missing` on the post-fix tree; if any test fails, remediate and restart the loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation2-finalqc-pytest-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` including numeric post-fix line-coverage and branch-coverage percentages, the passed test count, and zero failures.
- [x] [P2-T5] Capture pass-after evidence for the blocking finding by running the targeted test `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` on the post-fix tree and confirming it passes.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/regression-testing/remediation2-pass-after-bundled-payload.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording `1 passed` for the target test id.
- [x] [P2-T6] Produce the coverage delta and threshold verification artifact comparing the Phase 0 pre-fix baseline (P0-T6 artifact) against the post-fix coverage (P2-T4 artifact), confirming line coverage >= 85%, branch coverage >= 75%, and no coverage regression attributable to this remediation.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation2-coverage-delta.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:` and records baseline numeric line/branch percentages, post-fix numeric line/branch percentages, the delta, and an explicit PASS/FAIL verdict against both thresholds and the no-regression requirement; verdict is PASS.
- [ ] [P2-T7] Commit the bundle-mirror change set (the four mirrored files under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`, any additional files mirrored by P1-T5, and the evidence artifacts under `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/`) on `feature/legacy-discovery-analyzer-framework-363` with a professional, factual commit message.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/remediation2-commit.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording the commit SHA and confirming `git status --porcelain` is empty after the commit and that no `.claude/agents/*.md` source file appears in the commit diff.
- [ ] [P2-T8] Push the feature branch to the remote with `git push origin feature/legacy-discovery-analyzer-framework-363`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/remediation2-push.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording the pushed commit SHA matching the local branch head.
- [ ] [P2-T9] Verify PR #378 is mergeable by running `gh pr view 378 --json mergeable` (re-polling if GitHub reports `UNKNOWN` while recomputing) and confirming the mergeable state is `MERGEABLE`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation2-pr-mergeable.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` showing `"mergeable": "MERGEABLE"` for PR #378.

## Exit Condition (from remediation inputs)

- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes on the post-fix tree
  (P2-T4, P2-T5).
- Full Python QC loop passes with coverage thresholds intact: line >= 85%, branch >= 75%, no
  regression (P2-T1 through P2-T6).
- PR #378 mergeable state is MERGEABLE against the integration head (P2-T9).
- Reaudit (code-review, feature-audit, policy-audit) is orchestrated by the caller after this
  plan completes; it is outside this plan's task scope.
