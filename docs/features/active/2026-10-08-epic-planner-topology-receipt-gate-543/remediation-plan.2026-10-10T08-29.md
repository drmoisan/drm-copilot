# epic-planner-topology-receipt-gate (Remediation Plan, cycle 1)

- **Issue:** #543 (residual scope)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-10T08-29
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Branch:** `bug/epic-planner-topology-receipt-gate-543`
- **Languages in scope:** TypeScript (evidence only; no TypeScript file is edited by this plan). No Python, PowerShell, or C# work.
- **Requirements source:** `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/remediation-inputs.2026-10-10T08-29.md`, finding PA-1 (the only blocking finding, evidence-only), and `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/policy-audit.2026-10-10T08-29.md`. The 14 acceptance criteria of `spec.md` are evaluated PASS and are not touched.

**Scope statement:** This plan resolves PA-1 only. It makes no production, test, Jest-config, `.claude/`, `.github/`, or `spec.md` change. The write set is evidence artifacts under the feature folder plus this plan's checkbox state. Non-blocking findings PA-2 through PA-5 and CR-1 through CR-3 are out of scope for this cycle.

**Fail-closed evidence rule:** If `extensions/drm-copilot/coverage/lcov.info` is absent after the coverage run, if the `SF:` record for `epic-planner-state-core.ts` is absent from it, or if any numeric value required below is missing from the recorded artifact, the remediation is not complete and the re-review verdict cannot be PASS.

## Files Written

- `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/remediation-baseline/` (Phase 0 artifacts)
- `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/` (Phase 1 and Phase 2 artifacts)
- `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/remediation-plan.2026-10-10T08-29.md` (task checkbox state only)

Tool output that is not a repository file: `extensions/drm-copilot/coverage/lcov.info`. Its directory is gitignored (`.gitignore` line 62, entry `extensions/drm-copilot/coverage`). The file is the PA-1 deliverable and must remain on disk after this plan ends. It is cited from the `qa-gates` artifact and is never committed.

## Terms used in every task

- FEATURE means `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543`. Evidence is written only under FEATURE/evidence/remediation-baseline/ and FEATURE/evidence/qa-gates/. No `artifacts/` path is an evidence location. The caller supplied no non-canonical evidence path, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record applies.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form, read from the host clock when the task runs, never composed from an earlier value.
- CORE-FILE means `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`. In `lcov.info` its `SF:` line ends in `src/lib/validate/epic-planner-state-core.ts` (the separators may be backslashes on Windows).
- LCOV-FILE means `extensions/drm-copilot/coverage/lcov.info`. Its location follows from `extensions/drm-copilot/jest.config.cjs` line 19, `coverageDirectory: "<rootDir>/coverage"`, where `rootDir` is the directory holding the config, `extensions/drm-copilot`. P0-T3 re-verifies this line.
- COVERAGE-RUN means `cd extensions/drm-copilot && node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text --coverageReporters=text-summary`. The three explicit reporters replace the config list `["lcov", "text-summary"]` (`jest.config.cjs` line 18) with a list that still contains `lcov`; the earlier executor runs omitted `lcov`, which is the cause of PA-1.
- BASE-SHA means `e7612e93a4e88f68eadae6ee9e34ead251c82872`, the review head named in `remediation-inputs.2026-10-10T08-29.md`.

## Execution constraints

- Every shell command runs from the worktree root and records no host path. Where an `lcov.info` `SF:` line carries an absolute path, record only the repository-relative tail beginning at `extensions/drm-copilot/`.
- Do not pipe any command, and do not combine a `cd` segment with a pipeline. The hooks deny those forms. COVERAGE-RUN uses a `cd` followed by `&&` and no pipe, the form the earlier executor ran successfully.
- Read file contents with the Read and Grep tools, not with a shell `cat`, `head`, `tail`, or `grep`.
- Do not pass `--passWithNoTests`, `--onlyChanged`, or `--lastCommit` to `run-jest.cjs`; the script rejects them (`extensions/drm-copilot/run-jest.cjs` line 9).
- Do not pass `--verbose`. In the agent environment `--verbose` prints only the summary; the per-test lines are not needed here.
- The full Jest run covers about 265 suites and may take several minutes. It may run in the background; the executor waits for the completion notification before reading output.
- The executor never force-pushes and never rebases. If any hook or permission rule denies a command, stop and report the denial text. Do not bypass it.
- No source, test, or configuration file is edited. If a step reports a failing test or a threshold failure, stop and report; do not edit code in this plan.

## Planner decisions (recorded for audit)

- PD1 - The command named in the finding is reused unchanged as COVERAGE-RUN. It runs the full suite with no test selection and no new threshold.
- PD2 - Baseline values (98.3 percent lines, 93.57 percent branches for CORE-FILE) are taken from the committed artifact `FEATURE/evidence/baseline/baseline-typescript-test-coverage.2026-10-10T08-06.md`, because this plan changes no code. The earlier post-change text figures (98.31 percent lines, 93.8 percent branches) are recorded for comparison only; the lcov-derived values are the ones judged.
- PD3 - The comparison against the baseline uses values rounded to two decimals, because the baseline was recorded in that precision.
- PD4 - The Definition of Done requires the lines "whichever are present" among `DA:444`, `DA:445`, and `DA:446` to have non-zero hit counts. This plan fixes the evidence further: at least one of the three must be present, otherwise the check would pass vacuously.

## AC Traceability

| ID | Short form | Implementation | Tests / verification | Check-off |
|---|---|---|---|---|
| PA-1 | lcov file exists and per-file lcov values, thresholds, no-decrease, and added-line hits are recorded | P1-T1 | P1-T2, P1-T3, P1-T4, P1-T5 | P2-T3, P3-T4 |
| PA-1-SCOPE | write set is evidence and plan state only; no code, config, or spec change | P2-T1 | P2-T1, P2-T2, P3-T5 | P3-T6 |

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read the policy files in the required order and record FEATURE/evidence/remediation-baseline/phase0-instructions-read.TS.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `CLAUDE.md`, `.claude/rules/tonality.md`; (2) `.claude/rules/general-code-change.md`; (3) `.claude/rules/general-unit-test.md`; (4) `.claude/rules/typescript.md`; (5) `.claude/rules/quality-tiers.md`; (6) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
      Acceptance: the artifact has the three required headers and lists all 7 files in that order.
- [x] [P0-T2] Record the branch, ancestry, and clean starting state, and record FEATURE/evidence/remediation-baseline/branch-and-status.TS.md.
      Commands: `git branch --show-current`; `git merge-base --is-ancestor e7612e93a4e88f68eadae6ee9e34ead251c82872 HEAD`; `git status --porcelain --untracked-files=all -- extensions scripts tests .claude .github pyproject.toml`.
      Acceptance: the branch command prints exactly `bug/epic-planner-topology-receipt-gate-543`; any other value stops the plan. The ancestry command exits 0 (it prints nothing); a non-zero exit stops the plan. The status command prints nothing; any output stops the plan, because this plan assumes no code or configuration change is pending. The artifact records the branch value, both exit codes, and the status output (empty) in `Output Summary:`, and its top-level `EXIT_CODE:` is the status command's exit code, 0.
- [x] [P0-T3] Verify the lcov output location from the Jest config and record FEATURE/evidence/remediation-baseline/jest-config-lcov-location.TS.md.
      Procedure: Read `extensions/drm-copilot/jest.config.cjs` lines 10-20 and copy the `coverageReporters` line and the `coverageDirectory` line verbatim.
      Acceptance: the artifact records the verbatim lines `coverageReporters: ["lcov", "text-summary"],` and `coverageDirectory: "<rootDir>/coverage",` with their line numbers 18 and 19, and states the resolved path `extensions/drm-copilot/coverage/lcov.info`. A different line text or number stops the plan, because the cited path would then be unverified. The artifact records `Command:` as `Read extensions/drm-copilot/jest.config.cjs lines 10-20` and `EXIT_CODE: 0`.
- [x] [P0-T4] Record the pre-run state of LCOV-FILE and its ignore status, and record FEATURE/evidence/remediation-baseline/lcov-pre-run-state.TS.md.
      Commands: Glob `extensions/drm-copilot/coverage/lcov.info`; `git check-ignore -v extensions/drm-copilot/coverage/lcov.info`.
      Acceptance: the Glob result (expected: no match, per PA-1) is recorded in `Output Summary:`; a pre-existing file is recorded with its size and write time and does not stop the plan, because COVERAGE-RUN overwrites it. The `git check-ignore -v` command exits 0 and prints a line naming `.gitignore:62:extensions/drm-copilot/coverage`; a different rule or a non-zero exit stops the plan, because the lcov file would then be a tracked-tree risk. The artifact's top-level `EXIT_CODE:` is the `git check-ignore` exit code, 0.
- [x] [P0-T5] Record the baseline coverage values for CORE-FILE from the committed baseline artifact, and record FEATURE/evidence/remediation-baseline/prior-coverage-values.TS.md.
      Procedure: Read `FEATURE/evidence/baseline/baseline-typescript-test-coverage.2026-10-10T08-06.md` (the table row is on line 13) and `FEATURE/evidence/qa-gates/final-typescript-test-coverage.2026-10-10T08-20.md` (the table row is on line 14).
      Acceptance: `Output Summary:` records BASELINE_LINES 98.3, BASELINE_BRANCH 93.57, PRIOR_POST_LINES 98.31, and PRIOR_POST_BRANCH 93.8, each copied from the `% Lines` and `% Branch` columns of the `epic-planner-state-core.ts` row in the named artifact. A missing row or value stops the plan. The artifact records `Command:` as the two Read targets and `EXIT_CODE: 0`.

### Phase 1 — PA-1 Coverage Run and lcov Recording

- [x] [P1-T1] Run COVERAGE-RUN from the worktree root and record FEATURE/evidence/qa-gates/typescript-lcov-coverage.TS.md, using the TS read when the command starts. The artifact is the single PA-1 artifact; P1-T2 through P1-T5 append sections to it and do not create sibling files.
      Command: `cd extensions/drm-copilot && node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text --coverageReporters=text-summary`.
      Acceptance: exit 0. Exit 0 also means every configured `coverageThreshold` entry in `jest.config.cjs` is met. The output contains the verbatim lines beginning `Test Suites:` and `Tests:`, the text-summary lines beginning `Lines` and `Branches`, and the verbatim text-table row naming `epic-planner-state-core.ts`; the earlier runs printed exactly these (`Test Suites: 265 passed, 265 total`, `Tests:       3951 passed, 3951 total`, `Lines        : 97.23% ( 51064/52517 )`, `Branches     : 92.01% ( 7516/8168 )`). The artifact header carries `Timestamp:`, `Command:`, and `EXIT_CODE:`, and `Output Summary:` records those five verbatim lines. A different suite or test count is recorded without failing the task, provided the `Tests:` line shows no failed test. The `Lines` and `Branches` values of the repo-wide summary are recorded as printed.
- [x] [P1-T2] Confirm LCOV-FILE exists and was written by P1-T1, and append the section "lcov file" to FEATURE/evidence/qa-gates/typescript-lcov-coverage.TS.md.
      Commands: Glob `extensions/drm-copilot/coverage/lcov.info`; `ls -l --time-style=long-iso extensions/drm-copilot/coverage/lcov.info`.
      Acceptance: the Glob result lists `extensions/drm-copilot/coverage/lcov.info` and the `ls` command exits 0. The section records the repository-relative path, the size in bytes, and the write time exactly as the `ls` line prints them (a long-iso date and a minute). The size is greater than 0, and the write-time minute is not earlier than the P1-T1 `Timestamp:` minute. An absent file, a zero size, or an earlier write time stops the plan.
- [x] [P1-T3] Read the `epic-planner-state-core.ts` record from LCOV-FILE and append the section "per-file lcov values" to FEATURE/evidence/qa-gates/typescript-lcov-coverage.TS.md.
      Procedure: use the Grep tool in multiline mode with `output_mode: content`, path `extensions/drm-copilot/coverage/lcov.info`, and a pattern that matches from the `SF:` line whose text ends in `epic-planner-state-core.ts` through the next `end_of_record` line. If the match is unusable, use one Grep call with the line-number option for the `SF:` line, then the Read tool from that line to the next `end_of_record`.
      Acceptance: exactly one record is found. The section records the repository-relative `SF:` tail, then `LF`, `LH`, `BRF`, and `BRH` as integers copied from the record. It then records DERIVED_LINES = LH / LF x 100 and DERIVED_BRANCH = BRH / BRF x 100, each rounded to two decimals, with the arithmetic shown. If `BRF` is 0, the file reports no branches and DERIVED_BRANCH is recorded as 100 by the repository convention for zero-branch modules. Any of the four integers missing, or no `SF:` record, stops the plan. The section also records the text-table `% Lines` and `% Branch` values from P1-T1 and the absolute difference between each derived value and its text-table value; a difference greater than 0.01 stops the plan and is reported.
- [x] [P1-T4] Read the added-line hit counts from the same record and append the section "added-line hits" to FEATURE/evidence/qa-gates/typescript-lcov-coverage.TS.md.
      Procedure: from the record read in P1-T3, copy each present line among `DA:444,<hits>`, `DA:445,<hits>`, and `DA:446,<hits>` verbatim. These are the lines of the added condition `if (!requireLaunchPaths || "topology_receipt" in value) {` (CORE-FILE line 444) and its body (line 445) and closing brace (line 446).
      Acceptance: at least one of the three `DA` lines is present and every present `DA` line has a hit count greater than 0. A `DA` line with a hit count of 0, or none of the three present, stops the plan. The section states which of the three lines were absent from the record.
- [x] [P1-T5] Judge the recorded values and append the section "verdict" to FEATURE/evidence/qa-gates/typescript-lcov-coverage.TS.md.
      Procedure: compare DERIVED_LINES and DERIVED_BRANCH from P1-T3 with the thresholds and with BASELINE_LINES and BASELINE_BRANCH from P0-T5.
      Acceptance: the section records four comparisons, each as a number pair with the result PASS or FAIL: DERIVED_LINES >= 85; DERIVED_BRANCH >= 75; DERIVED_LINES >= 98.3; DERIVED_BRANCH >= 93.57. All four must read PASS (planning-time expectation from the earlier text run: 98.31 and 93.8). The section also records the repo-wide `Lines` and `Branches` values from P1-T1 beside the 85 and 75 floors. Any FAIL stops the plan and is reported without editing code.

### Phase 2 — Scope Verification

- [x] [P2-T1] Verify the write set is limited to the feature folder and record FEATURE/evidence/qa-gates/scope-verification.TS.md.
      Commands: `git diff --name-only e7612e93a4e88f68eadae6ee9e34ead251c82872 -- . ":(exclude)docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543"`; `git status --porcelain --untracked-files=all -- . ":(exclude)docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543"`.
      Acceptance: both commands exit 0 and print nothing, so no tracked change and no untracked file exists outside the feature folder relative to BASE-SHA. The status command is the untracked-file companion to the name-listing diff, which cannot see a newly created file. Any printed path stops the plan. The artifact records both commands, both exit codes, and the empty output in `Output Summary:`.
- [x] [P2-T2] Verify `spec.md` carries no change since BASE-SHA and record FEATURE/evidence/qa-gates/spec-unchanged.TS.md.
      Commands: `git diff --name-only e7612e93a4e88f68eadae6ee9e34ead251c82872 -- docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md`; `git status --porcelain -- docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md`.
      Acceptance: both commands exit 0 and print nothing. Any printed path stops the plan, because remediation-inputs forbids changing any `spec.md` checkbox (AC13 is already checked). The artifact records the commands, exit codes, and empty output.
- [x] [P2-T3] Verify the PA-1 artifact is complete and record FEATURE/evidence/qa-gates/pa1-artifact-completeness.TS.md.
      Procedure: Read FEATURE/evidence/qa-gates/typescript-lcov-coverage.TS.md in full.
      Acceptance: the artifact contains the headers `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, the four sections "lcov file", "per-file lcov values", "added-line hits", and "verdict", and the P1-T1 run lines. Every value required by P1-T1 through P1-T5 is a number or a verbatim line, with no placeholder. The completeness artifact records the section names found and `EXIT_CODE: 0`. A missing header, section, or value stops the plan.

### Phase 3 — Commit and Push

Phase 3 writes no evidence artifact, because an artifact written after a commit would itself be uncommitted. Its outcomes are reported in the executor's return message. Before P3-T1, tick the checkboxes of P0-T1 through P2-T3 in this plan.

- [x] [P3-T1] Stage the feature folder.
      Commands: `git add -- docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543`; `git diff --cached --name-only -- . ":(exclude)docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543"`; `git status --porcelain --untracked-files=all`.
      Acceptance: all three commands exit 0. The second command prints nothing, so no staged path lies outside the feature folder. The third command prints only paths under the feature folder (the new evidence artifacts, this plan, and any review artifacts of the same cycle). A staged path outside the feature folder stops the plan.
- [x] [P3-T2] Commit the staged set with a single commit.
      Command: `git commit -m "docs(543): record TypeScript lcov coverage evidence for PA-1"`, with the commit-message trailers required by the session attribution instruction appended.
      Acceptance: exit 0 and the output names one new commit. The commit is made with no `--amend`, no `--no-verify`, and no history rewrite.
- [x] [P3-T3] Push the branch without force.
      Command: `git push origin bug/epic-planner-topology-receipt-gate-543`.
      Acceptance: exit 0. The command carries no `--force`, no `--force-with-lease`, and no `+` refspec, and no rebase is run at any point. A rejected push (non-fast-forward) stops the plan and is reported to the caller for a decision; the executor does not rebase or force to resolve it.
- [x] [P3-T4] Verify the remote head equals the local head.
      Commands: `git ls-remote origin refs/heads/bug/epic-planner-topology-receipt-gate-543`; `git rev-parse HEAD`.
      Acceptance: both commands exit 0, and the commit id at the start of the `ls-remote` line equals the `rev-parse` value. A mismatch stops the plan.
- [x] [P3-T5] Verify the committed range since BASE-SHA touches only the feature folder.
      Commands: `git diff --name-only e7612e93a4e88f68eadae6ee9e34ead251c82872 HEAD -- . ":(exclude)docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543"`; `git status --porcelain --untracked-files=all`.
      Acceptance: both commands exit 0. The diff command prints nothing, so the committed range touches only the feature folder, which is the re-review condition in `remediation-inputs.2026-10-10T08-29.md`. The status command prints nothing or prints only the modified path of this plan file (the P3 checkbox ticks made after the commit); any other path stops the plan.
- [x] [P3-T6] Tick P3-T1 through P3-T6 in this plan, then commit and push that single file, only if the P3-T5 status command printed the plan path.
      Commands: `git add -- docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/remediation-plan.2026-10-10T08-29.md`; `git commit -m "docs(543): record remediation plan completion state"`, with the same trailers as P3-T2; `git push origin bug/epic-planner-topology-receipt-gate-543`; `git status --porcelain --untracked-files=all`.
      Acceptance: all four commands exit 0 and the final status command prints nothing, with no force and no rebase. If the P3-T5 status command printed nothing, this task is satisfied by ticking its checkbox after confirming that status is empty.
