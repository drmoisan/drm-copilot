# Acceptance criteria status (AC-48 closeout after PR #926 CI)

Timestamp: 2026-10-13T16-29
Command: grep -c -E '^- \[x\] AC-[0-9]+:' <FEATURE>/issue.md; grep -c -E '^- \[ \] AC-[0-9]+:' <FEATURE>/issue.md; git -C <worktree> diff --stat HEAD (checkbox-only check on issue.md)
EXIT_CODE: 0
Output Summary: 50 AC items; 50 checked; 0 unchecked. AC-48 was checked in this pass on the PR #926 CI run 38428074609 (headSha 341ff760ffe10a032ba3f8b465cbe9f3e5fe9f06), recorded in `qa/ci-pr926.2026-10-13T16-28.md`. The issue.md diff is one line (`- [ ]` to `- [x]` on AC-48); no AC text changed. Supersedes `ac-status.2026-10-13T14-33.md`.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/issue.md`
- Total AC items: 50
- Checked off (delivered): 50
- Remaining (unchecked): 0
- Items remaining: none

The blocking changed-line finding carried by `ps-coverage.2026-10-13T14-28.md` in the prior summary was resolved by remediation cycle 1: `ps-coverage.2026-10-13T15-55.md` records Codex targets 356 and 370 as covered and every remaining uncovered changed line as exempt, and the PR #926 CI coverage XML reproduces the same per-file and per-line values.

Artifact selection: for each name in the plan's `## Acceptance Criteria Traceability` table, the lexicographically greatest file matching `<name>.*.md` in the named folder. `rt/` = `evidence/regression-testing/`, `qa/` = `evidence/qa-gates/`, `bl/` = `evidence/baseline/`.

## Per-AC evidence

| AC | State | Evidence artifacts (selected file) | Result |
|---|---|---|---|
| AC-1 | checked | rt/p7-contracts-fail-before.2026-10-13T11-17.md; rt/p7-contracts-pass-after.2026-10-13T11-20.md | pass |
| AC-2 | checked | rt/p7-contracts-fail-before.2026-10-13T11-17.md; rt/p7-contracts-pass-after.2026-10-13T11-20.md | pass |
| AC-3 | checked | rt/p7-targeted-suite.2026-10-13T11-20.md; qa/py-contract-suites.2026-10-13T13-48.md; qa/mirror-parity.2026-10-13T14-02.md | pass |
| AC-4 | checked | rt/p7-contracts-pass-after.2026-10-13T11-20.md; qa/py-contract-suites.2026-10-13T13-48.md | pass |
| AC-5 | checked | rt/p7-targeted-suite.2026-10-13T11-20.md | pass |
| AC-6 | checked | rt/p7-contracts-fail-before.2026-10-13T11-17.md; rt/p7-contracts-pass-after.2026-10-13T11-20.md | pass |
| AC-7 | checked | qa/p7-scope.2026-10-13T11-21.md; qa/scope.2026-10-13T14-02.md | pass |
| AC-8 | checked | rt/p8-793-after.2026-10-13T11-22.md; rt/fail-before-exception.p8-793.2026-10-13T11-22.md | pass |
| AC-9 | checked | rt/p8-793-after.2026-10-13T11-22.md; rt/fail-before-exception.p8-793.2026-10-13T11-22.md | pass |
| AC-10 | checked | qa/dispositions-present.2026-10-13T14-30.md | pass |
| AC-11 | checked | rt/p8-797-py-fail-before.2026-10-13T11-23.md; rt/p8-797-py-pass-after.2026-10-13T11-24.md; rt/ps-fail-before.2026-10-13T12-04.md; qa/scope.2026-10-13T14-02.md; qa/ps-rows.2026-10-13T14-25.md | pass (ps-fail-before records the per-runtime fail-before outcome, including the dotted-capital-I deviation the AC anticipates as unverified) |
| AC-12 | checked | rt/p8-797-py-pass-after.2026-10-13T11-24.md; rt/fail-before-exception.p8-797-cr4.2026-10-13T11-24.md | pass |
| AC-13 | checked | bl/npm-guard-collect-before.2026-10-13T00-15.md; rt/p8-845-collect-compare.2026-10-13T11-26.md; rt/p8-845-after.2026-10-13T11-26.md; rt/p8-python-toolchain.2026-10-13T11-27.md | pass |
| AC-14 | checked | rt/p8-845-collect-compare.2026-10-13T11-26.md; rt/p8-845-after.2026-10-13T11-26.md; rt/fail-before-exception.p8-845.2026-10-13T11-26.md | pass |
| AC-15 | checked | rt/p8-845-collect-compare.2026-10-13T11-26.md; rt/p8-845-after.2026-10-13T11-26.md; rt/fail-before-exception.p8-845.2026-10-13T11-26.md | pass |
| AC-16 | checked | rt/p8-846-cr1-after.2026-10-13T11-27.md; rt/fail-before-exception.p8-846-cr1.2026-10-13T11-27.md | pass |
| AC-17 | checked | qa/ps-rows.2026-10-13T14-25.md; rt/fail-before-exception.p8-737-846-ps.2026-10-13T12-49.md | pass |
| AC-18 | checked | qa/ps-rows.2026-10-13T14-25.md; rt/fail-before-exception.p8-737-846-ps.2026-10-13T12-49.md | pass |
| AC-19 | checked | qa/ps-rows.2026-10-13T14-25.md; rt/fail-before-exception.p8-737-846-ps.2026-10-13T12-49.md | pass |
| AC-20 | checked | rt/p8-ts-jest.2026-10-13T11-29.md; qa/ts-jest-coverage.2026-10-13T13-49.md; rt/fail-before-exception.p8-846-cr5-cr6.2026-10-13T11-29.md | pass |
| AC-21 | checked | rt/p8-ts-jest.2026-10-13T11-29.md; qa/ts-jest-coverage.2026-10-13T13-49.md; rt/fail-before-exception.p8-846-cr5-cr6.2026-10-13T11-29.md | pass |
| AC-22 | checked | #846 folder `evidence/other/closure-dispositions-correction.2026-10-13T11-29.md`; qa/p8-846-cr7-original-unchanged.2026-10-13T11-29.md; qa/dispositions-present.2026-10-13T14-30.md | pass (original still unchanged: `git diff --stat origin/main...HEAD` on it is empty in this pass) |
| AC-23 | checked | rt/ps-fail-before.2026-10-13T12-04.md; qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-24 | checked | qa/scope.2026-10-13T14-02.md; qa/dispositions-present.2026-10-13T14-30.md | pass |
| AC-25 | checked | rt/ps-fail-before.2026-10-13T12-04.md; qa/mirror-parity.2026-10-13T14-02.md; qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-26 | checked | bl/ps-catch-lines-baseline.2026-10-13T11-14.md; qa/ps-catch-lines.2026-10-13T14-29.md; `issue.md` `#565 CR-6` row (cites run 38410234897) | pass (8 of 9 covered; the uncovered line is listed under Operator Follow-up 7) |
| AC-27 | checked | rt/ps-fail-before.2026-10-13T12-04.md; qa/mirror-parity.2026-10-13T14-02.md; qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-28 | checked | rt/ps-fail-before.2026-10-13T12-04.md; qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-29 | checked | rt/fail-before-exception.p8-732-cr3.2026-10-13T12-29.md; qa/ps-rows.2026-10-13T14-25.md; qa/cr3-decision.2026-10-13T13-43.md | pass (`Decision: CR-3 retained`) |
| AC-30 | checked | rt/p8-732-checks.2026-10-13T12-20.md; qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-31 | checked | rt/p8-732-checks.2026-10-13T12-20.md; qa/ci-final.2026-10-13T14-23.md | pass (`PSScriptAnalyzer passed: no findings`) |
| AC-32 | checked | rt/ps-fail-before.2026-10-13T12-04.md; qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-33 | checked | qa/py-contract-suites.2026-10-13T13-48.md; qa/mirror-parity.2026-10-13T14-02.md; qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-34 | checked | rt/ps-fail-before.2026-10-13T12-04.md; qa/ps-rows.2026-10-13T14-25.md; qa/f1-f2-decision.2026-10-13T13-44.md | pass via the AC's own withhold branch (see note) |
| AC-35 | checked | rt/ps-fail-before.2026-10-13T12-04.md; qa/ps-rows.2026-10-13T14-25.md; qa/f1-f2-decision.2026-10-13T13-44.md | pass via the AC's own withhold branch (see note) |
| AC-36 | checked | qa/dispositions-present.2026-10-13T14-30.md; rt/fail-before-exception.p8-737-846-ps.2026-10-13T12-49.md | pass |
| AC-37 | checked | qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-38 | checked | qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-39 | checked | qa/dispositions-present.2026-10-13T14-30.md | pass |
| AC-40 | checked | rt/fail-before-exception.p8-737-846-ps.2026-10-13T12-49.md | pass |
| AC-41 | checked | qa/i3-files-unchanged.2026-10-13T12-48.md; rt/fail-before-exception.p8-737-846-ps.2026-10-13T12-49.md | pass (re-observed in this pass: `git diff --stat origin/main...HEAD` over the four I-3 files is empty) |
| AC-42 | checked | qa/i3-files-unchanged.2026-10-13T12-48.md; qa/dispositions-present.2026-10-13T14-30.md | pass |
| AC-43 | checked | qa/line-counts.2026-10-13T14-01.md | pass |
| AC-44 | checked | qa/scope.2026-10-13T14-02.md | pass |
| AC-45 | checked | qa/hooks-no-python.2026-10-13T14-03.md; qa/ps-rows.2026-10-13T14-25.md | pass |
| AC-46 | checked | qa/py-black-check.2026-10-13T13-45.md; qa/py-ruff.2026-10-13T13-45.md; qa/py-pyright.2026-10-13T13-45.md; qa/py-pytest-full.2026-10-13T13-47.md; qa/py-coverage-totals.2026-10-13T13-47.md; qa/py-cov-token-shapes.2026-10-13T13-47.md | pass |
| AC-47 | checked | qa/ts-prettier-check.2026-10-13T13-48.md; qa/ts-eslint.2026-10-13T13-48.md; qa/ts-tsc-jest.2026-10-13T13-48.md; qa/ts-jest-coverage.2026-10-13T13-49.md | pass |
| AC-48 | checked (this pass) | qa/ps-format.2026-10-13T13-49.md; qa/ps-analyze.2026-10-13T13-50.md; qa/ps-test.2026-10-13T14-00.md; qa/ci-final.2026-10-13T14-23.md; qa/ps-rows.2026-10-13T14-25.md; qa/ps-coverage.2026-10-13T15-55.md; PR CI: qa/ci-pr926.2026-10-13T16-28.md | pass (PR #926 CI run 38428074609: all jobs success; every named Pester row passes; all ten files at or above 85%; uncovered changed lines all exempt) |
| AC-49 | checked | qa/py-contract-suites.2026-10-13T13-48.md; qa/mirror-parity.2026-10-13T14-02.md | pass |
| AC-50 | checked | qa/scope.2026-10-13T14-02.md | pass |

## Note on AC-34 and AC-35 (F-1/F-2 withheld)

The plan (P13-T3) leaves AC-34/AC-35 unchecked only if F-1/F-2 were withheld for a reason other than the AC's own withhold condition. The withhold matches the AC's own condition: the full-population Discovery run (CI run 38404520141) raised new findings in suites the issue's `## Concurrency Constraints` reserves for the concurrent epic `subagentstop-envelope` (`hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`) and in a suite inferred to be owned by #901 (`session-root-reads-850.Constraints.Tests.ps1`). The withhold branch's obligations are met: none of the flagged suites is edited by the branch (`git diff --stat origin/main...HEAD` over all seven is empty), F-1 and F-2 are withheld (the four F-1/F-2 files have no net diff from `origin/main`), and the withhold is recorded in `## Note Dispositions` (both rows `withheld`) and in `## Operator Follow-ups` item 10 (flagged suites and owners). Limits: epic ownership rests on the reserved file patterns, not a verified epic file list, and three of the seven flagged suites have no evidenced owner; this is recorded in `f1-f2-decision.2026-10-13T13-44.md`. The F-1/F-2 rows are `EXCLUDED-BY-DECISION` in `ps-rows.2026-10-13T14-25.md`.
