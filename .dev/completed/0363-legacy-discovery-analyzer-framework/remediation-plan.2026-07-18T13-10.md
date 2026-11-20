# legacy-discovery-analyzer-framework — Remediation Plan (Cycle 1)

- **Issue:** #363
- **PR:** https://github.com/drmoisan/drm-copilot/pull/378
- **Owner:** drmoisan
- **Last Updated:** 2026-07-18T13-10
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Remediation cycle:** 1
- **Feature branch:** feature/legacy-discovery-analyzer-framework-363
- **Integration branch:** epic/legacy-discovery-and-parity-integration

## Requirements Source

Sole requirements source for this remediation cycle:
`docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/remediation-inputs.2026-07-18T13-10.md`

Finding: Blocking merge-conflict. PR #378 mergeable state is CONFLICTING because the epic
integration branch advanced after this feature branched. The only conflict is in
`pyproject.toml` `[tool.poetry.scripts]`: both sides added a console-script line at the same
location. Required resolution is the union — keep BOTH entries:

- `"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"` (this feature, #363)
- `"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"` (#364)

and confirm `"dev.discovery.profile"` (#360) remains present. No other file conflicts; the
`[tool.coverage.report] exclude_lines` change merges cleanly.

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

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline and Policy Compliance

- [x] [P0-T1] Read the policy files in the required precedence order (`CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/python.md`; then `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`) and record the read by appending a `## Remediation Cycle 1 (2026-07-18T13-10)` section to `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/phase0-instructions-read.md`.
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` contains a Remediation Cycle 1 section with `Timestamp:`, `Policy Order:`, and an explicit list of every file read in the order above; prior cycle content is preserved.
- [x] [P0-T2] Capture the pre-remediation Black formatting baseline by running `poetry run black --check .` on the feature branch before the merge.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation1-baseline-black.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and file count).
- [x] [P0-T3] Capture the pre-remediation Ruff lint baseline by running `poetry run ruff check .` on the feature branch before the merge.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation1-baseline-ruff.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T4] Capture the pre-remediation Pyright type-check baseline by running `poetry run pyright` on the feature branch before the merge.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation1-baseline-pyright.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T5] Capture the pre-remediation Pytest coverage baseline by running `poetry run pytest --cov --cov-branch --cov-report=term-missing` on the feature branch before the merge.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/baseline/remediation1-baseline-pytest-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including numeric baseline line-coverage and branch-coverage percentages and the passed/failed test count.

### Phase 1 — Merge Resolution

- [x] [P1-T1] With the feature branch `feature/legacy-discovery-analyzer-framework-363` checked out and a clean working tree, run `git merge origin/epic/legacy-discovery-and-parity-integration` and record the resulting conflict state, confirming via `git diff --name-only --diff-filter=U` that `pyproject.toml` is the only unmerged path.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/remediation1-merge-conflict-state.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` showing the unmerged-path list contains exactly `pyproject.toml`.
- [x] [P1-T2] Resolve the `pyproject.toml` conflict in `[tool.poetry.scripts]` by keeping BOTH console-script entries (union) — `"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"` and `"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"` — preserving the existing ordering of surrounding entries and removing all conflict markers.
  - Acceptance: `pyproject.toml` contains no conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`); `[tool.poetry.scripts]` contains `dev.discovery.inventory`, `dev.discovery.generate-acceptance-scenarios`, and `dev.discovery.profile` entries; no pre-existing script entry was dropped.
- [x] [P1-T3] Stage the resolved file with `git add pyproject.toml`, verify `git diff --name-only --diff-filter=U` returns empty output, and complete the merge commit (`git commit --no-edit` or equivalent merge-completion commit).
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/remediation1-merge-commit.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the empty unmerged-path check, the merge commit SHA, and confirmation that `pyproject.toml` contains both new script entries plus `dev.discovery.profile`.

### Phase 2 — Final QC Loop and Verification

Loop rule: run the four QC steps in order (Black -> Ruff -> Pyright -> Pytest with coverage).
If any step fails or changes files, remediate and restart the loop from P2-T1 until all four
steps pass in a single clean pass. `EXIT_CODE: SKIPPED` is not a valid outcome for any task in
this phase.

- [x] [P2-T1] Run the final-QC formatting gate `poetry run black --check .` on the post-merge tree; if it reports changes needed, apply `poetry run black .` and restart the loop from this task.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation1-finalqc-black.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` from the final clean pass.
- [x] [P2-T2] Run the final-QC lint gate `poetry run ruff check .` on the post-merge tree; if it fails or auto-fixes files, remediate and restart the loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation1-finalqc-ruff.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` from the final clean pass.
- [x] [P2-T3] Run the final-QC type-check gate `poetry run pyright` on the post-merge tree; if it fails, remediate and restart the loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation1-finalqc-pyright.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` reporting 0 errors from the final clean pass.
- [ ] [P2-T4] Run the final-QC test-and-coverage gate `poetry run pytest --cov --cov-branch --cov-report=term-missing` on the post-merge tree; if any test fails, remediate and restart the loop from P2-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation1-finalqc-pytest-coverage.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` including numeric post-merge line-coverage and branch-coverage percentages and the passed test count.
- [ ] [P2-T5] Produce the coverage delta and threshold verification artifact comparing the Phase 0 pre-remediation baseline (P0-T5 artifact) against the post-merge coverage (P2-T4 artifact), confirming line coverage >= 85%, branch coverage >= 75%, and no coverage regression attributable to the merge.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation1-coverage-delta.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:` and records baseline numeric line/branch percentages, post-merge numeric line/branch percentages, the delta, and an explicit PASS/FAIL verdict against both thresholds and the no-regression requirement; verdict is PASS.
- [ ] [P2-T6] Push the merged feature branch to the remote with `git push origin feature/legacy-discovery-analyzer-framework-363`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/other/remediation1-push.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` recording the pushed commit SHA matching the local branch head.
- [ ] [P2-T7] Verify PR #378 is no longer conflicting by running `gh pr view 378 --json mergeable` (re-polling if GitHub reports `UNKNOWN` while recomputing) and confirming the mergeable state is `MERGEABLE`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/evidence/qa-gates/remediation1-pr-mergeable.<yyyy-MM-ddTHH-mm>.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` showing `"mergeable": "MERGEABLE"` for PR #378.

## Exit Condition (from remediation inputs)

- PR #378 mergeable state is MERGEABLE against the integration branch head (P2-T7).
- Full Python QC loop passes with coverage thresholds intact: line >= 85%, branch >= 75%, no
  regression (P2-T1 through P2-T5).
- Reaudit (code-review, feature-audit, policy-audit) is orchestrated by the caller after this
  plan completes; it is outside this plan's task scope.
