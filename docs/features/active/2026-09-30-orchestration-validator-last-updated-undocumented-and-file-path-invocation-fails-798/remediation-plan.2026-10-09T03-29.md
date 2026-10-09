# orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails (Remediation Plan, cycle 1)

- **Issue:** #798
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-09T03-29
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- **Branch:** `bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`
- **Languages in scope:** Python (verification only; no Python file is edited by this plan). No TypeScript, PowerShell, or C# work.
- **Requirements source:** `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/remediation-inputs.2026-10-09T03-29.md`, finding PA-1 (the only blocking finding, remediability `autonomous`, evidence-only). The 21 acceptance criteria of `spec.md` are all PASS and are not touched.

**Scope statement:** This plan resolves PA-1 only. It makes no production, test, `.claude/` document, bundled mirror, `pyproject.toml`, or `spec.md` change. It does not address the non-blocking items CR-2, CR-3, or CR-4. It contains no commit, push, or rebase task; the orchestrator commits.

**Fail-closed evidence rule:** If `artifacts/python/lcov.info` is absent after the coverage run, or any numeric coverage value is missing from the recorded artifact, the remediation is not complete and the reaudit verdict cannot be PASS.

## Files Written

- `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/evidence/remediation-baseline/` (Phase 0 artifacts)
- `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/evidence/qa-gates/` (Phase 1 and Phase 2 artifacts)
- `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/remediation-plan.2026-10-09T03-29.md` (task checkbox state only)

Tool outputs that are not repository files (gitignored by `/artifacts` in `.gitignore`): `artifacts/python/lcov.info` (the PA-1 deliverable, which must remain on disk after this plan ends), `artifacts/python/coverage-798-r1.json`, and `artifacts/.coverage`.

## Terms used in every task

- FEATURE means `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`. Evidence is written only under FEATURE/evidence/remediation-baseline/ and FEATURE/evidence/qa-gates/. No `artifacts/` path is an evidence location. The caller supplied no non-canonical evidence path, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record applies.
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form, read from the host clock, never composed.
- DISPATCHER means `scripts/dev_tools/validate_orchestration_artifacts.py`.
- INVOCATION-MODULE means `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`. DOCS-MODULE means `tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`. Together with DISPATCHER they are the three changed Python files.
- COVERAGE-RUN means `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-798-r1.json`. The dotted `--cov=scripts.dev_tools` form collects data for every module under `scripts/dev_tools/` (the filesystem-path spellings collect none). `--cov-report=term-missing` prints the terminal table. The explicit LCOV report repeats the destination that `pyproject.toml` `addopts` already names, so the artifact is requested on the command line as well. The JSON report supplies separate line and branch values, because the terminal table prints one combined `Cover` column.

## Execution constraints

- Every Bash command runs with the #798 worktree root as its working directory. Artifacts never record a host path.
- File-content checks use `git grep --no-index`, never a bare `grep`, `cat`, `head`, or `tail`, because the Bash hook denies a command line in which a `cd` segment precedes one of those read commands.
- Shared-environment hazard: the shared Poetry virtual environment carries a `.pth` entry that can name another checkout, so `scripts` can resolve to a foreign checkout. The prior execution used plain `poetry run pytest` for the coverage and final-QC runs (artifact `evidence/qa-gates/pytest-full-coverage.2026-10-09T03-10.md`) and `poetry run python -S` for direct interpreter invocations (artifact `evidence/qa-gates/python-coverage-values.2026-10-09T03-12.md`). This plan uses the same two forms. P1-T3 additionally proves that the measured DISPATCHER file is this worktree's own file.
- The executor does not commit, stage, push, or rebase. No source file is edited. If a black, ruff, or pyright step reports a finding, stop and report it; do not edit source in this plan.
- The full pytest run takes about two minutes; it may run in the background, and the executor waits for the completion notification before reading output.
- If any hook or permission rule denies a command, stop and report the denial text. Do not bypass it.

## Planner decisions (recorded for audit)

- PD1 - The finding names the command `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`. COVERAGE-RUN adds two report options (`lcov` and `json`) to that command. The additions change no test selection and no threshold; they make the artifact request explicit and supply the separate line and branch percentages that PA-1 requires.
- PD2 - The final-QC pytest step (P2-T4) repeats COVERAGE-RUN in full rather than running a subset. A subset run with `--cov` would overwrite `artifacts/python/lcov.info` with partial data. Running the identical full command last leaves the PA-1 artifact complete and current.
- PD3 - Baseline coverage values are taken from the committed prior-execution artifact because this plan changes no code; the post-change values must equal or exceed them.

## AC Traceability

| ID | Short form | Implementation | Tests / verification | Check-off |
|---|---|---|---|---|
| PA-1 | coverage artifact present and recorded with numeric values | P1-T1, P1-T2 | P1-T3, P2-T4, P2-T5 | P1-T4 |

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read the policy files in the required order and record FEATURE/evidence/remediation-baseline/phase0-instructions-read.md with `Timestamp:`, `Policy Order:`, and the list of files read, in this order: (1) `CLAUDE.md`, `.claude/rules/tonality.md`; (2) `.claude/rules/general-code-change.md`; (3) `.claude/rules/general-unit-test.md`; (4) `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`; (5) `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`; (6) `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
      Acceptance: the artifact has the three required headers and lists all 9 files in that order.
- [x] [P0-T2] Record the branch and the clean starting state, and record FEATURE/evidence/remediation-baseline/branch-and-status.TS.md.
      Commands: `git branch --show-current`; `git status --porcelain --untracked-files=all -- scripts tests .claude extensions pyproject.toml`.
      Acceptance: the branch command prints exactly `bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798`; any other value stops the plan. The status command prints nothing; any output stops the plan, because this plan assumes no production, test, or configuration change is pending. The artifact's top-level `EXIT_CODE:` is the status command's exit code, 0; the branch command's printed value is recorded in `Output Summary:`.
- [x] [P0-T3] Record the baseline numeric coverage values from the prior-execution artifact `FEATURE/evidence/qa-gates/python-coverage-values.2026-10-09T03-12.md`, and record FEATURE/evidence/remediation-baseline/prior-coverage-values.TS.md.
      Command: `git grep --no-index -n -F "FILE_LINE 97.99" -- docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/evidence/qa-gates/python-coverage-values.2026-10-09T03-12.md`.
      Acceptance: exit 0 and one matching line. The artifact records BASELINE_FILE_LINE 97.99, BASELINE_FILE_BRANCH 92.86, BASELINE_TOTAL_LINE 93.68, and BASELINE_TOTAL_BRANCH 87.09 in `Output Summary:`, copied from the matching line `FILE_LINE 97.99 FILE_BRANCH 92.86 TOTAL_LINE 93.68 TOTAL_BRANCH 87.09`. A non-zero exit stops the plan.

### Phase 1 — PA-1 Coverage Artifact Generation and Recording

- [x] [P1-T1] Run COVERAGE-RUN over `tests/` from the worktree root without passing any `.py` path to `--cov`, and record FEATURE/evidence/qa-gates/pytest-coverage-run.TS.md.
      Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-798-r1.json`.
      Acceptance: exit 0; the summary line contains the token `passed` and no failure count; the output contains the verbatim dispatcher row (the table row naming `validate_orchestration_artifacts.py`) and the verbatim `TOTAL` row. Both rows and the summary line are recorded verbatim in `Output Summary:`. The prior execution's summary line was `6659 passed, 6 skipped`; a different count is recorded without failing the task, provided there is no failed test. The dispatcher row's `Cover` column must read 97% or higher and the `TOTAL` row's `Cover` column must read 92% or higher (planning-time values 97% and 92%).
- [x] [P1-T2] Confirm that `artifacts/python/lcov.info` exists after P1-T1 and record its size, and record FEATURE/evidence/qa-gates/lcov-artifact-presence.TS.md.
      Command: `poetry run python -S -c "import os, pathlib; p = pathlib.Path('artifacts/python/lcov.info'); print('LCOV_EXISTS', p.is_file(), 'LCOV_BYTES', os.stat(p).st_size)"`.
      Acceptance: exit 0 and one printed line of the form `LCOV_EXISTS True LCOV_BYTES <integer>` whose integer is greater than 0. The artifact records the repository-relative path `artifacts/python/lcov.info` and the byte count. `LCOV_EXISTS False`, a missing-file traceback, or a byte count of 0 stops the plan.
- [x] [P1-T3] Derive the DISPATCHER line and branch percentages and prove the measured file is this worktree's own file, and record FEATURE/evidence/qa-gates/python-coverage-values-r1.TS.md.
      Command: `poetry run python -S -c "import json, os, pathlib; d = json.loads(pathlib.Path('artifacts/python/coverage-798-r1.json').read_text(encoding='utf-8')); f = next(v for k, v in d['files'].items() if k.replace(chr(92), '/').endswith('scripts/dev_tools/validate_orchestration_artifacts.py')); s = f['summary']; t = d['totals']; own = os.path.realpath('scripts/dev_tools/validate_orchestration_artifacts.py'); sf = [l[3:] for l in pathlib.Path('artifacts/python/lcov.info').read_text(encoding='utf-8').splitlines() if l.startswith('SF:')]; print('FILE_LINE', round(100 * s['covered_lines'] / s['num_statements'], 2), 'FILE_BRANCH', round(100 * s['covered_branches'] / s['num_branches'], 2), 'TOTAL_LINE', round(t['percent_statements_covered'], 2), 'TOTAL_BRANCH', round(t['percent_branches_covered'], 2), 'MISSING_16_TO_19', [n for n in f['missing_lines'] if 16 <= n <= 19], 'EXECUTED_17', 17 in f['executed_lines'], 'LCOV_SF_OWN', sum(1 for x in sf if os.path.realpath(x) == own))"`.
      Acceptance: exit 0 and one printed line. The numbers printed after the tokens `FILE_LINE`, `FILE_BRANCH`, `TOTAL_LINE` and `TOTAL_BRANCH` are recorded, in that order, as FINAL_FILE_LINE, FINAL_FILE_BRANCH, FINAL_TOTAL_LINE and FINAL_TOTAL_BRANCH. The printed line is also recorded verbatim in `Output Summary:`. FINAL_FILE_LINE >= 85; FINAL_FILE_BRANCH >= 75; FINAL_FILE_LINE >= BASELINE_FILE_LINE (97.99); FINAL_FILE_BRANCH >= BASELINE_FILE_BRANCH (92.86); the line contains `MISSING_16_TO_19 []` and `EXECUTED_17 True`; and the line ends with `LCOV_SF_OWN 1`, which proves the lcov file lists exactly one record for this worktree's own DISPATCHER. Any other value stops the plan.
- [x] [P1-T4] Write the PA-1 artifact FEATURE/evidence/qa-gates/python-coverage-artifact.TS.md. Its filename starts with the literal `python-coverage-artifact.` and ends with `.md`.
      Required content: `Timestamp:` (the task execution time), `Command:` (the COVERAGE-RUN command, exactly as written in Terms), `EXIT_CODE:` (the P1-T1 exit code), and `Output Summary:` containing: (a) the verbatim dispatcher row from P1-T1; (b) the verbatim `TOTAL` row from P1-T1; (c) the artifact path `artifacts/python/lcov.info` and its byte count from P1-T2; (d) the DISPATCHER line percentage and branch percentage from P1-T3 (FINAL_FILE_LINE and FINAL_FILE_BRANCH); (e) the `MISSING_16_TO_19 []` result; (f) a pointer to the P1-T1, P1-T2, and P1-T3 artifacts.
      Acceptance: the artifact exists in FEATURE/evidence/qa-gates/ and carries all four headers and all six content items, with numeric percentages and no placeholder text. A missing header or a non-numeric value leaves the task unchecked.

### Phase 2 — Final QC Loop

Restart rule: run P2-T1 through P2-T6 in order. If any step fails, or if any step changes a tracked or new file other than its own evidence artifact, stop and report; this plan makes no source edit, so a failure here is a finding for the orchestrator, not a repair task. A clean pass ends the loop. Each artifact records its loop iteration number in `Output Summary:`. Artifacts are written to FEATURE/evidence/qa-gates/ with a fresh TS.

- [x] [P2-T1] Format check of the three changed Python files (DISPATCHER, INVOCATION-MODULE, DOCS-MODULE), and record FEATURE/evidence/qa-gates/black-check-r1.TS.md.
      Command: `poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and the line "3 files would be left unchanged." (and no line containing "would reformat"). The command is check-only and rewrites nothing.
- [x] [P2-T2] Lint of the three changed Python files, and record FEATURE/evidence/qa-gates/ruff-check-r1.TS.md.
      Command: `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and the line "All checks passed!". The command is check-only (no `--fix`) and rewrites nothing.
- [x] [P2-T3] Type check of the three changed Python files, and record FEATURE/evidence/qa-gates/pyright-r1.TS.md.
      Command: `poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py`.
      Acceptance: exit 0 and a summary line beginning "0 errors".
- [x] [P2-T4] Full pytest run in coverage mode (COVERAGE-RUN over `tests/`), and record FEATURE/evidence/qa-gates/pytest-full-coverage-r1.TS.md.
      Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/coverage-798-r1.json`.
      Acceptance: exit 0; the summary line, the verbatim dispatcher row, the verbatim `TOTAL` row, and the passed count are recorded in `Output Summary:`; the passed count equals the P1-T1 passed count; the dispatcher row's `Cover` column reads 97% or higher and the `TOTAL` row's reads 92% or higher. After the Derivation step, FINAL2_FILE_LINE, FINAL2_FILE_BRANCH, FINAL2_TOTAL_LINE and FINAL2_TOTAL_BRANCH are compared with the corresponding FINAL_ values from [P1-T3], and any difference is recorded.
      Derivation: after the run, execute the same probe command given in [P1-T3] (a single line, run unchanged) record the printed line verbatim in `Output Summary:`, and record the numbers printed after the tokens `FILE_LINE`, `FILE_BRANCH`, `TOTAL_LINE` and `TOTAL_BRANCH` as FINAL2_FILE_LINE, FINAL2_FILE_BRANCH, FINAL2_TOTAL_LINE and FINAL2_TOTAL_BRANCH respectively. The probe is not edited, and the labels FINAL_ and FINAL2_ are assigned by the recorder, not printed by the probe. Acceptance additions: exit 0; the line contains `MISSING_16_TO_19 []` and `EXECUTED_17 True` and ends with `LCOV_SF_OWN 1`; FINAL2_FILE_LINE >= 97.99 and FINAL2_FILE_BRANCH >= 92.86.
- [x] [P2-T5] Confirm that `artifacts/python/lcov.info` still exists after P2-T4, and record FEATURE/evidence/qa-gates/lcov-artifact-final.TS.md.
      Command: `poetry run python -S -c "import os, pathlib; p = pathlib.Path('artifacts/python/lcov.info'); print('LCOV_EXISTS', p.is_file(), 'LCOV_BYTES', os.stat(p).st_size)"`.
      Acceptance: exit 0 and one printed line `LCOV_EXISTS True LCOV_BYTES <integer>` with an integer greater than 0. The byte count is recorded. No cleanup of `artifacts/python/` is performed by any task in this plan.
- [x] [P2-T6] Scope and evidence-location verification, and record FEATURE/evidence/qa-gates/scope-and-evidence-check-r1.TS.md.
      Commands: `git status --porcelain --untracked-files=all -- scripts tests .claude extensions pyproject.toml`; `poetry run python -S -m scripts.dev_tools.validate_evidence_locations --root .`.
      Acceptance: the status command prints nothing, which proves that no production, test, `.claude/`, mirror, or configuration file changed. The evidence-location validator exits 0 and prints nothing on success; Output Summary records "no output, exit 0". Any line beginning "VIOLATION:" stops the plan. The artifact's top-level `EXIT_CODE:` is the validator's exit code; the status command's empty output and exit code are recorded in `Output Summary:`.
