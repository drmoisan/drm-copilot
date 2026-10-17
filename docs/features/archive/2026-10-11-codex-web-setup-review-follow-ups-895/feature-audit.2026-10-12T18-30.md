# Feature Audit (issue #895)

Timestamp: 2026-10-12T18-30
Work mode: minor-audit; AC source: `issue.md`, section `## Acceptance Criteria`.
Baseline: origin/main @ 88946d10a47911a426abec906b2b2163814f5950; Head 18566f978bcf04c4411f975b5d4c08c3ff6fe97e.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 (CR-1) | PASS | `log_solution_selection` added and called from `main`; message "Selected solution file X; root *.sln files found: N." Bats C824-62 (two files, asserts `Alpha.sln` and `found: 2.`) and C824-63 (empty). |
| AC-2 (CR-2) | PASS | `tests/fixtures/codex_web_setup/solution-root/Alpha.sln` exists (empty blob e69de29); C824-64 asserts output equals `Alpha.sln`. |
| AC-3 (CR-3) | PASS | Comment "GNU find is required: ..." on the line immediately above the `find -printf` call (script line 29). |
| AC-4 (CR-10) | PASS | Helper `tests/shell/helpers/codex_web_setup_common.bash` defines the shared items once; all three suites `load 'helpers/codex_web_setup_common'`; diff shows removal of the duplicates. Subdirectory placement keeps it out of the bats runner (non-recursive per `find_bats_test_dirs`). |
| AC-5 (CR-11) | PASS | C824-37 Arrange asserts `grep -c -x 'export CI=true' ... = 1` before the act step. |
| AC-6 (CR-12) | PASS | `run_with_stub_path` sets PATH/HOME to `${FIXTURES}/empty-path`; `.gitkeep` committed. |
| AC-7 (CR-14) | PARTIAL | Attribution-limit document exists in the feature folder with constructs, mechanism, covering tests, and rejected alternative. The required "CI kcov evidence cited" is `S9-EVIDENCE: PENDING`; no PR CI run exists. Left unchecked. |
| AC-8 | PARTIAL | Byte identity PASS (both hashes `db6cf823a72a7568ae96304725b530746e8ef748`, verified during review). CI shell-qc, bats, and kcov jobs: no run exists for the head; evidence stubs pending. Left unchecked. |

## Check-off Actions

No checkbox changes were made by this review. AC-1 through AC-6 were already checked in `issue.md` and are confirmed PASS. AC-7 and AC-8 remain unchecked.

## Scope Check

Changed non-doc files are limited to the script, its mirror, the helper, four suites, and two fixtures, matching `Dependencies / Risks`. `.github/codex/codex-web-setup.sh` is unchanged. No out-of-scope source changes.

## Regression Assessment vs Baseline

Behavior change in production code is limited to one additional log line at the start of `main`. No change to `REPO_ROOT` or `SOLUTION_FILE` resolution. Tests were refactored without removing cases (no `@test` deleted in the diff).

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-11-codex-web-setup-review-follow-ups-895/issue.md`
- Total AC items: 8
- Checked off (delivered): 6
- Remaining (unchecked): 2
- Items remaining: AC-7 (CI kcov evidence citation); AC-8 (CI shell-qc, bats, kcov jobs pass against the PR head)
