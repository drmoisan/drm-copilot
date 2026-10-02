# Policy Audit (#609)

- Timestamp: 2026-10-01T23-21
- Branch: `bug/bash-lane-assertion-newline-edges-divergence-609`
- Head: `4a45810410fcc5df12d68dee5f3a718d9b2f49d6`
- Base: `origin/main` at merge-base `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9` (origin/main equals the merge-base, so the branch is up to date)
- Work mode: `full-bug` (AC source: `spec.md`)
- Scope: full branch diff `git diff origin/main...HEAD` (41 files: 4 code/test files, 37 documentation and evidence files)

## Rejected Scope Narrowing

- Caller text (verbatim): "those gates (AC-1, 3, 4, 5, 6, 8, 11, 12, 13, 14, 17) are evidenced by the CI job `shell-coverage` on the pushed head, which has not been read yet; mark them PARTIAL/UNVERIFIED pending CI, not FAIL".
- Disposition: partially rejected. AC-level verdicts in `feature-audit` use PARTIAL where CI evidence is the only missing input, as requested. The coverage-gate verdict for bash (a language with changed files) is recorded as an explicit FAIL because the audit rules do not permit UNVERIFIED or PARTIAL for a language with changed files and require FAIL when the coverage artifact is absent. The FAIL is labeled pending-CI and is reversible to PASS once the CI coverage values are read.
- Justification: language coverage verdicts must be explicit PASS or FAIL when the branch has changed files in that language.

## Evidence Location Rejections

- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none required. The plan names only `<FEATURE>/evidence/<kind>/` paths.

## Policy Reading Order Applied

`CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, then the shell rule `.claude/rules/shell.md` (referenced by the plan; not re-read for this audit beyond the plan's quotation of its no-branch-gate statement).

## Verdict Summary

| # | Policy area | Verdict |
|---|---|---|
| 1 | Evidence location compliance | PASS |
| 2 | File size limit (500 lines) | PASS |
| 3 | Write-set and untouched-file limits | PASS |
| 4 | Mirror byte-identity | PASS |
| 5 | Test file location and layout | PASS |
| 6 | Unit-test principles (determinism, no temp files, isolation) | PASS |
| 7 | Coverage exclusion policy (no production exclusions added) | PASS |
| 8 | Bash coverage verification (line >= 85%, no regression on changed lines) | FAIL (pending CI; artifact absent locally) |
| 9 | Python coverage | PASS (not applicable: zero `.py` files changed) |
| 10 | Mandatory toolchain loop, shell stages | PARTIAL (pending CI) |
| 11 | Error handling and fail-fast | PASS |
| 12 | Dependencies | PASS |
| 13 | Tone policy (agent-authored documents) | PASS |
| 14 | Acceptance-criteria tracking protocol | PASS |

## Findings and Evidence

### 1. Evidence Location Compliance - PASS

- `git diff --name-only origin/main...HEAD -- artifacts coverage` returned no paths. No file exists under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` on the branch.
- All 33 evidence files sit under `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/{baseline,regression-testing,qa-gates,other}/`, the canonical kinds.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` produced no output (no reported violation).
- Observation (non-blocking): `evidence/baseline/phase0-instructions-read.md` has no timestamp suffix in its file name; the plan P0-T1 specifies that exact name, so it follows the plan.

### 2. File Size Limit - PASS

- `.claude/lib/bash/parallel-lane-assertion.sh`: 497 lines (reviewer ran `wc -l`; 495 before, +2 net). Limit 500.
- `tests/shell/parallel_lane_assertion.bats`: 495 lines (reviewer ran `wc -l`; 458 before). Limit 500.
- The new fixture is 10 lines. Margin in the library is 3 lines and in the bats file is 5 lines; any later edit to either file must be planned against the limit.

### 3. Write Set and Untouched Files - PASS

Non-documentation changes on the branch are exactly:
- `.claude/lib/bash/parallel-lane-assertion.sh`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh`
- `tests/shell/parallel_lane_assertion.bats`
- `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json`

The remaining 37 paths are all under the feature folder (`issue.md`, `spec.md`, `plan.2026-09-29T18-29.md`, `research/`, `evidence/`). No change to `report-lane-assertion.sh`, `parallel-cohorts.sh`, `compute-cohorts.sh`, the two parity test files, `pack-manifests/core.json`, the Python authority, or `docs/features/completed/`. No `edges_crlf_separated.json` was added (the spec allows this; the CRLF bats case is the CRLF coverage).

### 4. Mirror Byte-Identity - PASS

- `cmp` of the canonical library and the bundled mirror returned exit 0 with no output (reviewer ran it).
- The two hunks in `git diff` are identical, and both blobs share the index hash `fe1ff687`.
- Line endings: both files are `i/lf w/lf`.

### 5. Test File Location and Layout - PASS

The new cases live in the existing `tests/shell/parallel_lane_assertion.bats`; the fixture lives in the existing `tests/fixtures/parallel_lane_assertion/` corpus directory. No test file was colocated with production source.

### 6. Unit-Test Principles - PASS

- No temporary file creation, no `sleep`, no wall-clock dependency in the six new cases. Escapes are ANSI-C literals; the bats file contains 0 non-ASCII bytes per the P1-T1 artifact.
- Each case asserts both exit status and the header line in one comparison (`"$status:${lines[0]}"`), so a failure message names both.
- Scenario coverage: newline, tab, CR, CRLF-terminated final token, undeclared-vertices boundary, mixed separators with trailing newline, and a single-line control per case.
- Two cases (tab, undeclared-vertices) pass before the fix by design and are recorded as boundary guards.

### 7. Coverage Exclusion Policy - PASS

No `exclude` entry or coverage configuration changed in the diff.

### 8. Bash Coverage Verification - FAIL (pending CI)

- Language with changed files: bash (`parallel-lane-assertion.sh` modified, one new `read -ra` statement at line 88).
- Coverage artifact `artifacts/pester/kcov/cov.xml` is absent in this worktree. Baseline, post-change, and comparison artifacts record `PENDING-CI` (`baseline-shell-coverage`, `final-shell-coverage`, `coverage-comparison`). No value was invented, which is correct.
- Reason for FAIL under the audit rule: "coverage artifact absent for bash; coverage verification is mandatory for all languages with changed files." This is an evidence gap, not a measured shortfall. The operator rule Option A prevents local kcov, so the CI job `shell-coverage` is the only source.
- What CI must show (all from job `Shell Coverage (Bats + kcov)` on head `4a458104`, workflow `.github/workflows/_shell-coverage.yml` invoked from `.github/workflows/ci.yml` line 26-27):
  1. The job is green on head `4a458104` (not an earlier head).
  2. Log line `Bash coverage (lines): NN.N%` with NN.N >= 85.0 (repository-wide merged total).
  3. In the uploaded `shell-coverage` artifact, `artifacts/pester/kcov/cov.xml`: the `class` entry for `parallel-lane-assertion.sh` has `line-rate` >= 0.85 and >= the pre-change value, and the `line` element at `number="88"` has `hits` >= 1. The pre-change per-file value is not recorded locally; it must be read from the CI run on `origin/main` (or the most recent main run) to evaluate no-regression.
- Bash has no branch-coverage gate (kcov does not measure it).

### 9. Python Coverage - PASS (not applicable)

No `.py` file is in the branch diff, so no Python coverage artifact is required. The reviewer re-ran `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py tests/scripts/dev_tools/test_parallel_lane_assertion.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`: 83 passed. This matches N_b (82) + 1 recorded in `final-pytest.2026-09-29T18-45.md`.

### 10. Mandatory Toolchain Loop (shell stages) - PARTIAL

| Stage | Local reviewer observation | Authority |
|---|---|---|
| Format | `shfmt -d` on the changed `.sh` file printed nothing (exit 0). `shell-qc.sh` only discovers `*.sh` (`shell_qc_lib.sh` line 64), so the `.bats` file is outside this gate; `shfmt -d` run directly on it reports whole-file indentation differences that pre-date this branch (4-space bats convention). | CI `shell-qc.sh check` |
| Lint | `shellcheck` on the changed `.sh` file printed nothing (exit 0). | CI `shell-qc.sh check` |
| Type check | Not applicable for bash. `sh -n` syntax check was not run (Option A). | CI (a parse error would fail every bats case) |
| Architecture-boundary | No change to dependency structure. | - |
| Unit tests | Python 83 passed (reviewer). Bats not run locally. | CI `shell-coverage` |
| Contract/schema | Push-down contract test passed within the 83. | - |
| Integration | Not applicable beyond the above. | - |

The reviewer ran `shfmt` and `shellcheck` directly (not through `shell-qc.sh`, bats, kcov, or an `sh`-wrapped script). The project's own evidence records no post-fix `shell-qc.sh` run (deviation D3), so the stage remains PARTIAL until CI is read.

### 11. Error Handling - PASS

The change adds one parameter expansion and no new command, so no new exit status under `set -euo pipefail`. The diagnostic remains advisory and exits 0; the new bats cases assert `status = 0`. Reviewer reasoning on the mechanism (not executed locally because the worktree guard refuses inline shell demonstrations): `read -ra` without `-d` consumes one newline-terminated record and splits on IFS space/tab/newline only, which is the defect; replacing `\n`, `\r`, `\v`, `\f` with spaces before `read` removes that dependence.

### 12. Dependencies - PASS

No dependency added.

### 13. Tone Policy - PASS

The authored documents (`spec.md`, `plan`, `research`, evidence) are factual and neutral; evidence artifacts state `NOT-RUN` and `PENDING-CI` rather than asserting unobserved results.

### 14. Acceptance-Criteria Tracking - PASS

`spec.md` has 17 checkbox criteria; 6 are checked (AC-2, AC-7, AC-9, AC-10, AC-15, AC-16) and the remaining 11 match `evidence/other/ac-gaps.2026-09-29T18-45.md`. Each checked item was independently re-verified by the reviewer (see `feature-audit`). No criterion is checked without evidence.

## Process Observations (non-blocking)

- D3 probe: `evidence/baseline/baseline-shell-check.2026-09-29T18-45.md` records one local `sh scripts/bash/shell-qc.sh check` run made before Option A was applied. It is disclosed as a probe. It does not change any verdict.
- Plan tasks P0-T5, P0-T6, P1-T5, P3-T1 to P3-T4, and P4-T1 to P4-T6 are left unchecked in the plan, which is consistent with the withheld local runs. Plan tasks P4-T10 to P4-T26 are checked while several ACs stay unchecked; those tasks state "the line state matches the evidence", so the pattern is consistent.
