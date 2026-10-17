# subagentstop-envelope-feature-review-coverage (Remediation Plan, cycle 1)

- **Issue:** #896
- **Owner:** drmoisan
- **Last Updated:** 2026-10-12T11-25
- **Status:** Draft
- **Work Mode:** full-bug
- **Local branch:** `exec-896-ac7`, pushed to remote branch `bug/subagentstop-envelope-feature-review-coverage-exec-896`
- **Base:** `origin/epic/subagentstop-envelope-integration`
- **Languages in scope:** Python (verification only; no Python file is edited). No PowerShell, TypeScript, or C# work.
- **Requirements source:** `docs/features/active/subagentstop-envelope-feature-review-coverage-896/remediation-inputs.2026-10-12T11-25.md` finding R-1, which is `policy-audit.2026-10-12T11-25.md` finding PA-1 (the only Blocking finding, remediability `autonomous`, evidence-only). The acceptance criteria of `spec.md` are not changed; AC-29 is not checked off by this plan.

**Scope statement:** This plan resolves PA-1 only. It makes no production, test, `.claude/`, `.codex/`, `.github/`, mirror, `pyproject.toml`, or `spec.md` change. It does not address the non-blocking code-review items (Minor 2, Nit 2, Info 4).

**Fail-closed evidence rule:** If `artifacts/python/lcov.info` or `artifacts/python/coverage-896.json` is absent after the coverage run, or any numeric value required by P1-T3 is missing, PA-1 is not remediated and the reaudit verdict cannot be PASS.

## Terms used in every task

- FEATURE means `docs/features/active/subagentstop-envelope-feature-review-coverage-896`. Evidence is written only under FEATURE/evidence/remediation-baseline/ and FEATURE/evidence/qa-gates/ and FEATURE/evidence/other/. No `artifacts/` path is an evidence location. The caller supplied no non-canonical evidence path, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record applies.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form, read from the host clock.
- CHANGED-TEST means `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`, the only Python file changed on the branch (policy-audit line 17).
- COVERAGE-RUN means `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-896.json`.
- KL-510 means the known local-only failure of node `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` whose assertion message reads `Repo file missing from bundle: .claude\state\...` (or with `/` separators). It is caused by gitignored `.claude/state/` files (`.gitignore` line 70) and is tracked as issue #510.

## Coverage configuration read at planning time

- `pyproject.toml` line 116: `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`. The addopts value supplies only an LCOV reporter, so COVERAGE-RUN passes `--cov-report=term-missing` to print the terminal table.
- `pyproject.toml` lines 119-127: `[tool.coverage.run]` `source = ["src", "scripts/dev_tools"]`, `data_file = "artifacts/.coverage"`, `omit` excludes `tests/*`. No `branch = true` key exists, so COVERAGE-RUN passes `--cov-branch`.
- `src/` contains no Python file (its only entry is `src/hello-typescript.ts`), so the dotted `--cov=scripts.dev_tools` argument measures the same Python production population as the configured source.
- Success-case terminal output (observed in recorded runs): with `--cov-branch` the table header has the columns `Stmts Miss Branch BrPart Cover Missing`, and the last table row begins with the literal `TOTAL` followed by five values, for example `TOTAL  17557  1110  6338  566  92%` (`docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/evidence/qa-gates/python-coverage-artifact.2026-10-09T03-58.md` line 8). The `Cover` column is one combined line-plus-branch figure, so separate line and branch percentages are read from the JSON report keys `totals.percent_statements_covered` and `totals.percent_branches_covered` (observed printed values `TOTAL_LINE 93.68 TOTAL_BRANCH 87.09` in `.../798/evidence/qa-gates/python-coverage-values-r1.2026-10-09T03-58.md` line 6) and corroborated from the LCOV `LF`/`LH`/`BRF`/`BRH` records.
- The pytest summary line on success has the form `<N> passed, <M> skipped in <S>s`; with KL-510 present it has the form `1 failed, <N> passed, <M> skipped in <S>s` (`docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/qa-gates/python-coverage-run.2026-09-30T02-07.md` lines 9-11).

## Execution constraints

- Every command runs with the worktree root as its working directory. Artifacts record repository-relative paths only, never a host path.
- Direct interpreter probes use `poetry run python -S -c "<single line>"`; a multi-line `-c` argument is not used.
- The full pytest run takes several minutes. It may run in the background; wait for the completion notification before reading output.
- If any hook or permission rule denies a command, stop and report the denial text. Do not bypass it. Never force-push.

## Planner decisions (recorded for audit)

- PD1 - Baseline comparison method. The baseline Python figure is established by comparison against `origin/epic/subagentstop-envelope-integration` without a second full-suite run on the base tree: P0-T3 proves CHANGED-TEST is the only `.py` path that differs from the base, so the production denominator under `scripts/dev_tools/` is identical at base and head; P0-T4 proves CHANGED-TEST (at head, and at base when it exists there) imports only `__future__`, `pathlib`, and `pytest`, so it executes no production module and cannot change the production numerator. Therefore the base-tree production coverage equals the head-tree production coverage measured in P1-T1, and P1-T3 records that equality as the baseline comparison (remediation-inputs line 25, second option).
- PD2 - Threshold-failure recording. If P1-T2 reports TOTAL_LINE below 85.00 or TOTAL_BRANCH below 75.00, the executor does not edit code, configuration, or thresholds. P1-T3 records `Disposition: FAIL` with the figures, and records under `Baseline comparison:` that the shortfall is pre-existing on `origin/epic/subagentstop-envelope-integration` by PD1 (identical denominator and numerator), so it is not attributable to this branch. Phase 2 still commits and pushes the evidence, and the executor reports PA-1 as `REMEDIATION-REQUIRED: python repo-wide coverage below threshold (pre-existing on base)` to the orchestrator. The figure is not suppressed or relabelled N/A.
- PD3 - Test-failure recording. A KL-510 failure, when it is the only failed node, is recorded with `ExpectedExitCode: 1` and does not affect the disposition. Any other failed node yields `Disposition: FAIL`, the failed node IDs and assertion messages are recorded verbatim, Phase 2 still commits and pushes the evidence, and the executor reports `REMEDIATION-REQUIRED: python test failure` to the orchestrator.
- PD4 - Final QA loop. Phase 2 re-runs the check-only format, lint, and type-check stages on CHANGED-TEST (P2-T1 to P2-T3) before committing; COVERAGE-RUN (P1-T1) is the test stage of the loop. All three commands are check-only and rewrite nothing. This plan edits no source file, so a finding in any of them is not repaired here: the executor stops and reports it to the orchestrator.

## AC Traceability

| ID | Short form | Implementation | Tests / verification | Evidence |
|---|---|---|---|---|
| PA-1 | Python coverage artifact produced and numeric line and branch figures with baseline comparison recorded | P1-T1 | P1-T2, P1-T4 | P1-T3 (`FEATURE/evidence/qa-gates/python-coverage.TS.md`) |

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read the policy files in the required order and record FEATURE/evidence/remediation-baseline/phase0-instructions-read.TS.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `CLAUDE.md`, `.claude/rules/tonality.md`; (2) `.claude/rules/general-code-change.md`; (3) `.claude/rules/general-unit-test.md`; (4) `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`; (5) `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`; (6) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
      Acceptance: the artifact has the three required headers and lists all 9 files in that order.
- [x] [P0-T2] Record the branch, head commit, and clean code state, and record FEATURE/evidence/remediation-baseline/branch-and-status.TS.md.
      Commands: `git branch --show-current`; `git rev-parse HEAD`; `git status --porcelain --untracked-files=all -- scripts src tests .claude .codex .github .agents pyproject.toml`.
      Acceptance: the branch command prints exactly `exec-896-ac7`; any other value stops the plan. The head SHA is recorded in `Output Summary:`. The status command prints nothing; any output stops the plan. Top-level `EXIT_CODE:` is the status command's exit code (0).
- [x] [P0-T3] Baseline comparison input: prove that CHANGED-TEST is the only Python path that differs from the base, and record FEATURE/evidence/remediation-baseline/python-diff.TS.md.
      Commands: `git diff --name-status origin/epic/subagentstop-envelope-integration...HEAD -- "*.py"`; `git status --porcelain --untracked-files=all -- "*.py"`.
      Acceptance: the diff command exits 0 and prints exactly one line, whose path field is `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` and whose status field is `M` or `A`. The status command prints nothing (no uncommitted or untracked `.py` file). Both outputs are recorded verbatim in `Output Summary:`. Any other output stops the plan and is reported, because PD1 then does not hold.
- [x] [P0-T4] Prove that CHANGED-TEST imports no production module at head or at base, and record FEATURE/evidence/remediation-baseline/changed-test-imports.TS.md.
      Commands: `git grep -n -E "^(import|from) " HEAD -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; `git grep -n -E "^(import|from) " origin/epic/subagentstop-envelope-integration -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: the head command exits 0 and prints exactly three lines, at lines 18, 20, and 22, reading `from __future__ import annotations`, `from pathlib import Path`, and `import pytest`. The base command either exits 0 with every printed line naming only `__future__`, `pathlib`, or `pytest`, or (when P0-T3 reported status `A`) exits 1 with no output. Both outputs and exit codes are recorded verbatim in `Output Summary:`. A printed line naming `scripts`, `src`, or any other module stops the plan and is reported, because PD1 then does not hold.

### Phase 1 — PA-1 Python Coverage Generation and Recording

- [x] [P1-T1] Run COVERAGE-RUN over the full `tests/` population from the worktree root, and record FEATURE/evidence/qa-gates/python-coverage-run.TS.md.
      Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-896.json`.
      Acceptance: the output contains the pytest summary line and a table row beginning with the literal `TOTAL` followed by five values (Stmts, Miss, Branch, BrPart, Cover). Both are recorded verbatim in `Output Summary:`, together with the passed, failed, and skipped counts. Exit 0 passes. Exit 1 with KL-510 as the only failed node is recorded with `ExpectedExitCode: 1` and the line `- KL-510: STATE-ONLY` per PD3. Exit 1 with any other failed node is recorded per PD3 (failed node IDs and assertion messages verbatim) and the plan continues to P1-T2 so the coverage figures are still recorded. Any exit code other than 0 or 1, or a missing `TOTAL` row, stops the plan.
- [x] [P1-T2] Derive the repo-wide Python line and branch percentages and prove the LCOV records belong to this worktree, and record FEATURE/evidence/qa-gates/python-coverage-values.TS.md.
      Command: `poetry run python -S -c "import json, os, pathlib; t = json.loads(pathlib.Path('artifacts/python/coverage-896.json').read_text(encoding='utf-8'))['totals']; L = pathlib.Path('artifacts/python/lcov.info').read_text(encoding='utf-8').splitlines(); n = lambda k: sum(int(x[len(k):]) for x in L if x.startswith(k)); root = os.path.realpath('.').lower(); sf = [x[3:] for x in L if x.startswith('SF:')]; print('TOTAL_LINE', round(t['percent_statements_covered'], 2), 'TOTAL_BRANCH', round(t['percent_branches_covered'], 2), 'LF', n('LF:'), 'LH', n('LH:'), 'BRF', n('BRF:'), 'BRH', n('BRH:'), 'SF_TOTAL', len(sf), 'SF_FOREIGN', sum(1 for x in sf if not os.path.realpath(x).lower().startswith(root)))"`.
      Acceptance: exit 0 and one printed line beginning with the token `TOTAL_LINE`, recorded verbatim in `Output Summary:`. The numbers after `TOTAL_LINE` and `TOTAL_BRANCH` are recorded as FINAL_TOTAL_LINE and FINAL_TOTAL_BRANCH. LCOV_LINE = 100 * LH / LF and LCOV_BRANCH = 100 * BRH / BRF are computed by the recorder to two decimals and recorded as corroboration. Required: LF > 0, BRF > 0 (proves branch data was collected), SF_TOTAL > 0, and `SF_FOREIGN 0` (proves no measured file resolves outside this worktree). A failure of any required value stops the plan. The threshold comparison is made in P1-T3, not here.
- [x] [P1-T3] Write the PA-1 artifact FEATURE/evidence/qa-gates/python-coverage.TS.md. Its filename starts with the literal `python-coverage.` and ends with `.md`.
      Required content: `Timestamp:` (task execution time); `Command:` (the COVERAGE-RUN command exactly as written in Terms); `EXIT_CODE:` (the P1-T1 exit code); `ExpectedExitCode: 1` only when P1-T1 recorded KL-510 as the only failure; `Output Summary:` containing (a) the verbatim P1-T1 summary line and `TOTAL` row; (b) `Python line coverage: <FINAL_TOTAL_LINE>% (threshold 85.00%)` and `Python branch coverage: <FINAL_TOTAL_BRANCH>% (threshold 75.00%)` with the numeric values substituted; (c) LF, LH, BRF, BRH and LCOV_LINE, LCOV_BRANCH from P1-T2; (d) the artifact paths `artifacts/python/lcov.info` and `artifacts/python/coverage-896.json`; (e) a `Baseline comparison:` line stating that per P0-T3 and P0-T4 the production denominator and numerator are identical on `origin/epic/subagentstop-envelope-integration`, so baseline line and branch figures equal FINAL_TOTAL_LINE and FINAL_TOTAL_BRANCH and the change is 0.00 points; (f) `New/changed production code coverage: none (no Python production file changed)`; (g) a `Disposition:` line reading `PASS` when FINAL_TOTAL_LINE >= 85.00, FINAL_TOTAL_BRANCH >= 75.00, and no non-KL-510 test failed, and otherwise `FAIL` with the reason recorded per PD2 or PD3; (h) pointers to the P0-T3, P0-T4, P1-T1, and P1-T2 artifacts.
      Acceptance: the artifact exists in FEATURE/evidence/qa-gates/ with all required headers and all eight content items, and every percentage is numeric. A missing header, a placeholder, or a non-numeric percentage leaves the task unchecked.
- [x] [P1-T4] Verify evidence locations and that no source or configuration file changed, and record FEATURE/evidence/qa-gates/evidence-locations-and-scope.TS.md.
      Commands: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`; `git status --porcelain --untracked-files=all -- scripts src tests .claude .codex .github .agents pyproject.toml`.
      Acceptance: the validator exits 0 and prints nothing; `Output Summary:` records `no output, exit 0`. Any line beginning `VIOLATION:` stops the plan. The status command prints nothing. Top-level `EXIT_CODE:` is the validator's exit code; the status command's empty output and exit code are recorded in `Output Summary:`.

### Phase 2 — Final QA Loop, Commit, and Push

Restart rule: run P2-T1 through P2-T3 in order. If any of them fails or reports a file it would change, stop and report it; this plan makes no source edit, so the finding goes to the orchestrator rather than becoming a repair task. Each QA artifact records loop iteration `1` in `Output Summary:`.

- [x] [P2-T1] Format check (Black, check-only) of tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py, and record FEATURE/evidence/qa-gates/remediation-python-black.TS.md.
      Command: `poetry run black --check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0 and the output line `1 file would be left unchanged.` with no line containing `would reformat`. The command is check-only and rewrites nothing.
- [x] [P2-T2] Lint check (Ruff, no fix) of tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py, and record FEATURE/evidence/qa-gates/remediation-python-ruff.TS.md.
      Command: `poetry run ruff check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0 and the output line `All checks passed!`. The command has no `--fix` flag and rewrites nothing.
- [x] [P2-T3] Type check (Pyright) of tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py, and record FEATURE/evidence/qa-gates/remediation-python-pyright.TS.md.
      Command: `poetry run pyright tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
      Acceptance: exit 0 and a summary line beginning `0 errors`.
- [x] [P2-T4] Stage and commit the evidence under docs/features/active/subagentstop-envelope-feature-review-coverage-896/ and this plan's checkbox state.
      Commands: `git add -- docs/features/active/subagentstop-envelope-feature-review-coverage-896`; `git commit -m "docs(896): record Python coverage evidence for PA-1"` (the message body ends with the session's required attribution trailers); `git diff --name-only HEAD~1 HEAD`; `git status --porcelain --untracked-files=all -- docs/features/active/subagentstop-envelope-feature-review-coverage-896`.
      Acceptance: the commit exits 0. The `git diff --name-only HEAD~1 HEAD` output lists only paths beginning `docs/features/active/subagentstop-envelope-feature-review-coverage-896/` and includes the P1-T3 artifact path. The status command prints nothing. The new commit SHA is noted for P2-T5.
- [x] [P2-T5] Push the commit without force, and record FEATURE/evidence/other/commit-and-push.TS.md.
      Commands: `git push origin HEAD:bug/subagentstop-envelope-feature-review-coverage-exec-896`; `git ls-remote origin refs/heads/bug/subagentstop-envelope-feature-review-coverage-exec-896`; `git rev-parse HEAD`.
      Acceptance: the push exits 0 and its output contains the literal `HEAD -> bug/subagentstop-envelope-feature-review-coverage-exec-896`; the SHA printed by `git ls-remote` equals the SHA printed by `git rev-parse HEAD`. Both SHAs and the push output line are recorded in `Output Summary:`. A rejected push (non-fast-forward or hook denial) stops the plan; do not force-push, rebase, or retry with a different refspec; report the rejection text to the orchestrator.
- [x] [P2-T6] Commit and push FEATURE/evidence/other/commit-and-push.TS.md and the final checkbox state of docs/features/active/subagentstop-envelope-feature-review-coverage-896/remediation-plan.2026-10-12T11-25.md.
      Commands: mark [P2-T5] and [P2-T6] checked in this plan, then `git add -- docs/features/active/subagentstop-envelope-feature-review-coverage-896`; `git commit -m "docs(896): record PA-1 commit and push evidence"` (with the session's required attribution trailers); `git push origin HEAD:bug/subagentstop-envelope-feature-review-coverage-exec-896`; `git ls-remote origin refs/heads/bug/subagentstop-envelope-feature-review-coverage-exec-896`; `git rev-parse HEAD`; `git status --porcelain --untracked-files=all -- docs/features/active/subagentstop-envelope-feature-review-coverage-896`.
      Acceptance: the commit and push exit 0; the `git ls-remote` SHA equals the `git rev-parse HEAD` SHA; the status command prints nothing. These values are reported in the executor's return message, because a file recording this push cannot be part of the pushed commit. A rejected push stops the plan without force, as in P2-T5.
