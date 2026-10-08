# Remediation Inputs (#609)

- Timestamp: 2026-10-01T23-21
- Head: `4a45810410fcc5df12d68dee5f3a718d9b2f49d6`
- Source audits:
  - `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/policy-audit.2026-10-01T23-21.md`
  - `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/code-review.2026-10-01T23-21.md`
  - `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/feature-audit.2026-10-01T23-21.md`

There is no code defect. The items below are evidence gaps that block check-off of 11 acceptance criteria and block a PASS coverage verdict. No source change is requested.

## Remediation-Required Findings

### RR-1 (blocking for merge): CI job `shell-coverage` not yet read on head `4a458104`

- Affects: AC-1, 3, 4, 5, 8, 11, 12, 13, 14, 17; policy-audit section 8 (bash coverage FAIL, pending CI) and section 10.
- Location: gate is `.github/workflows/_shell-coverage.yml` (called at `.github/workflows/ci.yml` lines 26-27), job `Shell Coverage (Bats + kcov)`.
- Action: after the push, read the job for the exact head SHA and record, under `evidence/qa-gates/`, a CI evidence artifact (with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`) that contains:
  1. Job conclusion for head `4a45810410fcc5df12d68dee5f3a718d9b2f49d6`.
  2. The bats results for `tests/shell/parallel_lane_assertion.bats` (22 cases, six `edges-parity:` cases `ok`), `tests/shell/parallel_lane_assertion_parity.bats`, and `tests/shell/parallel_bash_manifest_membership.bats`.
  3. The `shell-qc.sh check` step result (no shfmt or shellcheck finding).
  4. `Bash coverage (lines): NN.N%` (>= 85.0) and, from `artifacts/pester/kcov/cov.xml` in the uploaded `shell-coverage` artifact, the `parallel-lane-assertion.sh` `line-rate` (>= 0.85) and `hits` at `number="88"` (>= 1).
  5. The pre-change per-file `line-rate` from a CI run on `main`, for the no-regression comparison.
- Then: update `evidence/qa-gates/coverage-comparison`, and check off AC-1, 3, 4, 5, 8, 11, 12, 13, 14, 17 individually in `spec.md` as each is satisfied, following `acceptance-criteria-tracking`.

### RR-2 (blocking for AC-6 only): fail-before evidence absent

- Affects: AC-6. Location: `evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md` (dossier only).
- Gap: AC-6 requires the new tests to fail on the unmodified library. The plan states a dossier alone does not satisfy it, and CI on the head supplies only pass-after.
- Action (either):
  - An operator runs `bats --tap tests/shell/parallel_lane_assertion.bats` against commit `1524e2d2` (cases present, fix absent) and the result is recorded under `evidence/regression-testing/bats-unit-before.2026-09-29T18-45.md`; the expected result is `1..22` with exactly four `not ok` (newline, CR, CRLF-terminated, mixed separators); or
  - the spec owner records an explicit decision to accept the Python-lane pin plus the dossier, with the criterion amended by the owner (reviewers and executors do not edit criterion text).
- Until one of these happens, AC-6 stays unchecked.

## Non-Blocking Observations (no action required for merge)

- Residual Python-only whitespace (`\x1c`-`\x1f`, `\x85`, `\xa0`, Unicode spaces) and `pcoh_split_words` newline truncation remain follow-ups, recorded in `evidence/other/follow-ups.2026-09-29T18-45.md`. Filing them as issues is a project decision.
- The tab and undeclared-vertices bats cases pass before the fix by design.
- If CI shows a failure at line 88 only, the plan's fallback (a local variable holding `$'\n\r\v\f'` in a two-statement form) is the documented alternative; the library has 3 lines of headroom.
