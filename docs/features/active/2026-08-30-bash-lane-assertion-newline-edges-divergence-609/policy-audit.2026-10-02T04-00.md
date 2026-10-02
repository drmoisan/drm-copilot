# Policy Audit (#609, review pass 1, R5 reaudit)

- Timestamp: 2026-10-02T04-00
- Branch: `bug/bash-lane-assertion-newline-edges-divergence-609` (PR #815)
- Head: `6a7f5eb565485f151d56269e25282082f5b951f0` (local HEAD of the review worktree)
- Base: `origin/main` at merge-base `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9` (origin/main equals the merge-base; the branch is up to date). The local `main` ref is stale (`dcb605ef`) and was not used; a diff against it pulls in unrelated paths.
- Work mode: `full-bug` (AC source: `spec.md`)
- Scope: full branch diff `git diff origin/main...HEAD`: 4 code/test files, remainder documentation and evidence under the feature folder.
- Supersedes: `policy-audit.2026-10-01T23-21.md`

## Rejected Scope Narrowing

None in this request. The caller asked for a full reaudit and named no narrowing. (The prior pass's partial rejection of a "PARTIAL/UNVERIFIED pending CI" instruction is closed by the CI evidence below.)

## Evidence Location Compliance

- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none required.
- `git diff --name-only origin/main...HEAD -- artifacts coverage` returned no paths. No file on the branch sits under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported violation (reviewer ran it).
- All evidence files are under `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/{baseline,regression-testing,qa-gates,other}/`.
- Result: PASS.

## Policy Reading Order Applied

`CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md` (all supplied in context), and the shell rule referenced by the plan.

## Verdict Summary

| # | Policy area | Verdict |
|---|---|---|
| 1 | Evidence location compliance | PASS |
| 2 | File size limit (500 lines) | PASS |
| 3 | Write-set and untouched-file limits | PASS |
| 4 | Mirror byte-identity | PASS |
| 5 | Test file location and layout | PASS |
| 6 | Unit-test principles | PASS |
| 7 | Coverage exclusion policy | PASS |
| 8 | Bash coverage verification (line >= 85%, no regression on changed lines) | PASS |
| 9 | Python coverage | PASS (zero `.py` files changed) |
| 10 | Mandatory toolchain loop, shell stages | PASS (CI authority) |
| 11 | Error handling and fail-fast | PASS |
| 12 | Dependencies | PASS |
| 13 | Tone policy | PASS |
| 14 | Acceptance-criteria tracking | PASS |
| 15 | CI-evidence artifact format | PASS |
| 16 | Evidence currency (stale pre-CI artifacts) | PASS with non-blocking observation |

Blocking findings: 0.

## Findings and Evidence

### 2. File size limit - PASS
`wc -l` (reviewer): `.claude/lib/bash/parallel-lane-assertion.sh` 497; `tests/shell/parallel_lane_assertion.bats` 495. Both at or under 500. Margins are 3 and 5 lines.

### 3. Write set - PASS
Non-documentation changes (`git diff --name-status origin/main...HEAD`): the library (M), the bundled mirror (M), `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json` (A), `tests/shell/parallel_lane_assertion.bats` (M). No change to `report-lane-assertion.sh`, `parallel-cohorts.sh`, `compute-cohorts.sh`, the two parity test files, the Python authority, `pack-manifests/core.json`, or `docs/features/completed/`.

### 4. Mirror byte-identity - PASS
`cmp` canonical versus mirror returned exit 0 (reviewer ran it). The library `git diff` shows a single hunk at lines 82-88.

### 5, 6. Test layout and principles - PASS
New cases are in the existing `tests/shell/` file and the existing fixture corpus directory. No temp files, sleeps, or clock use. Each of the six `edges-parity:` cases asserts `"$status:${lines[0]}"` against the expected header and a single-line control. Scenarios: newline, tab, CR, CRLF-terminated final token, undeclared-only vertices, mixed separators.

### 7. Coverage exclusion policy - PASS
No coverage configuration or `exclude` entry changed in the diff.

### 8. Bash coverage verification - PASS (was FAIL pending CI in the prior pass)
- Language with changed files: bash (`parallel-lane-assertion.sh`).
- The local artifact `artifacts/pester/kcov/cov.xml` is absent by design (bats and kcov cannot run locally). The CI artifact is the evidence route, recorded in two files:
  - `evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md`: job success, bats plan `1..507`, no `not ok`, `Bash coverage (lines): 93.7%` (>= 85.0).
  - `evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md`: per-file `line-rate` 0.989 at PR head `5e854239` and 0.989 on main (`1b1e349f`); changed line 88 `hits="1"`.
- Reviewer spot-check with `gh run view`: run 36960736942 is `pull_request`, head `5e85423931fe483c4fad5daa338b9dbb3a14edb6`, conclusion `success`; run 36960130609 is head `54ccddd5`, `success`. Job steps in run 36960736942 all `success` (including `Run shell-qc check (shfmt diff + shellcheck)` and `Run shell-qc test with coverage`).
- Currency: `git diff --name-only 757d99f1..HEAD` (the fix commit to local HEAD) lists documentation paths only. The library, mirror, bats file, and fixture are byte-unchanged between the CI-tested heads and the review head.
- Thresholds: repo-wide 93.7% >= 85%; per-file 0.989 >= 0.85; no regression (0.989 versus 0.989); changed line executed. No branch gate applies to bash.

### 10. Mandatory toolchain loop (shell stages) - PASS
Format and lint: the CI step `shell-qc check` (shfmt diff plus shellcheck) succeeded. Unit tests: bats `1..507` with no `not ok`. Parity and membership suites run in the same job. Python: reviewer-run pytest in the prior pass (83 passed) is unaffected because no Python or test-source change followed. Type check, architecture, contract and integration stages: no change in scope.

### 11-13. Error handling, dependencies, tone - PASS
The change adds one parameter expansion and no command; no dependency added; authored documents are factual and mark unobserved values explicitly.

### 14. Acceptance-criteria tracking - PASS
`spec.md` has 17 criteria, 17 checked. Each is traced to evidence in `feature-audit.2026-10-02T04-00.md`. No criterion is checked without evidence.

### 15. CI-evidence artifact format - PASS
All three new artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`: `ci-shell-coverage.2026-10-02T03-40.md`, `ci-per-file-coverage.2026-10-02T03-44.md`, `bats-unit-before.2026-10-02T03-53.md`. The last records `ExpectedExitCode: 0` and explains that `EXIT_CODE: 0` is the evidence-collection exit and the gated job failure is the expected fail-first outcome.

### 16. Stale pre-CI evidence - non-blocking observation
| File | Stale statement | Contradicts current state | Blocking |
|---|---|---|---|
| `evidence/other/ac-gaps.2026-09-29T18-45.md` | AC-6 and AC-14 open (11 gaps) | Yes (spec is 17/17) | No |
| `evidence/other/ac-status-summary.2026-09-29T18-45.md` | 6/17 checked, `REMEDIATION-REQUIRED` | Yes | No |
| `evidence/qa-gates/coverage-comparison.2026-09-29T18-45.md` | coverage values `PENDING-CI` | Superseded by `ci-per-file-coverage` | No |
| `evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md` | AC-6 unmet, dossier only | Superseded by `bats-unit-before` | No |
| `evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md` ("Gaps left unchecked") | AC-6 and AC-14 not yet read | Closed by the two later artifacts | No |

Rationale for non-blocking: the files are timestamped point-in-time records; no gate, validator, or AC checkbox reads them; the authoritative state is `spec.md` plus the three CI artifacts, which agree with each other. Optional hygiene: add a superseding `ac-status-summary` with a new timestamp; do not edit the old files.

## Process Observations (non-blocking)
- CI on the current head `6a7f5eb5` was still pending at review time (`gh pr checks 815`: `shell-coverage`, `quality-checks7`, and `poshqc` pending; the completed checks pass). The head delta from the last CI-green head `5e854239` is documentation only, so the shell verdicts carry over. Re-read the final CI state before merge.
- Plan tasks left unchecked for local runs remain consistent with the Option A rule (no local bats or kcov).
