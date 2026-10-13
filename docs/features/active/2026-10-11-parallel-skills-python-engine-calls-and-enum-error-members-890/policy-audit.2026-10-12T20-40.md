# Policy Audit: Issue #890 (parallel skills Python engine calls and enum error members)

- Timestamp: 2026-10-12T20-40
- Branch: `bug/parallel-skills-python-engine-calls-and-enum-error-members-890` (head 05d4cc0d5)
- Base: `origin/main` (diff computed with `git diff origin/main...HEAD`; 94 files, 34 outside the feature folder)
- Work mode: `minor-audit` (AC source: `issue.md`, `## Acceptance Criteria`, AC-1..AC-7)
- Review type: reduced (policy audit, code review, feature audit)
- Policies applied: CLAUDE.md, general-code-change.md, general-unit-test.md, python.md, python-suppressions.md, shell.md, quality-tiers.md, tonality.md, parallel-orchestration.md
- Overall verdict: **CONDITIONAL** (0 Blocking; two items pending PR CI: bats execution and kcov coverage)

## Executive Summary

The branch ports six Python engine calls in three skills (parallel-add, parallel-close, parallel-orchestrate) to a new destination-portable bash entry point (`mutate-parallel-run.sh`, with `parallel-mutation-cli.sh` and `parallel-mutation-ops.sh`), splits shared option parsing out of `remove-parallel-item.sh`, removes the `Bash(poetry run python -c *)` persona grant, and makes `UnknownEnumMemberError` list the members of the rejected field (`scripts/dev_tools/_parallel_mutation_errors.py`).

Changed languages: Python (one production module, tests), bash (five scripts, bats suites), Markdown, JSON. No TypeScript, PowerShell, or C# file is changed (`evidence/qa-gates/scope-check-890.md`).

Every check evaluable locally is PASS. The Python toolchain is clean in a single pass, and the changed Python module has 100% line and 100% branch coverage. Bash coverage (kcov) and bats execution are pending PR CI because the operator's Option A constraint forbids local bats/kcov; this is recorded as pending-CI, not as a defect. No blocking finding.

## Rejected Scope Narrowing

None. The caller prompt did not narrow the audit scope. The caller asked that the CI-dependent remainder of AC-2 and AC-6 be classified pending-CI rather than FAIL; that is a classification of unavailable evidence, not a scope exclusion, and the Bash coverage row in section 1.2 still records an explicit status.

## Evidence Location Compliance

- `python -I scripts/dev_tools/validate_evidence_locations.py --root .` exit code 0.
- No branch-diff file sits under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under the feature folder `evidence/{baseline,regression-testing,qa-gates,other}/`.
- Verdict: PASS.
- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none required.

## 1. General Unit Test Policy Compliance

Source: `.claude/rules/general-unit-test.md`.

| # | Requirement | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | Test placement under `tests/` | PASS | Python tests in `tests/scripts/dev_tools/`, bats in `tests/shell/`, corpus in `tests/fixtures/parallel_mutation_run/`. No colocation. |
| 2 | No temporary files in tests | PASS | Grep for `tempfile`, `tmp_path`, `mkdtemp`, `mktemp`, `BATS_*TMPDIR` found none in the new tests; the bats header states no temp file is created. |
| 3 | Determinism (no wall clock, no sleep) | PASS | Python lane uses a fixed clock; entry tests pass `--at`; default-`--at` bats cases assert format only. |
| 4 | No coverage exclusion of production paths | PASS | The diff touches no coverage config (`pyproject.toml`, jest, kcov settings). |
| 5 | Bash parity corpus vs Python reference | PASS | 21 fixtures; stem set asserted equal to the R4 set; Python lane 25 passed with "corrections: none". Reviewer read the bash library against `decide_admission`, `decide_close`, `build_*_entry`: validation order (generation before item key), `g+1` stamping, in-flight list ascending, and message text agree. |
| 6 | FU-791-2 enum member selection tests | PASS | One unit test per field (`state`, `merge_status`, `disposition`), the real raise site, and the unmapped-field case. |
| 7 | Bats suites executed | PENDING-CI | `parallel_mutation_run.bats`, `parallel_mutation_run_parity.bats`, and the three edited bats files have never run; CI is their first execution. |

### 1.1 Coverage Thresholds

Line >= 85% and branch >= 75% apply uniformly (T1-T4) to languages whose tooling measures branch coverage; bash (kcov) has no branch gate. The changed Python production module meets both thresholds. The module is not new on this branch, so the new-file rule applies to none.

### 1.2 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 0 | N/A | N/A | N/A | N/A | N/A |
| Python | 1 production module (`_parallel_mutation_errors.py`) plus tests | 129 passed (surface suite 102 passed) | PASS | 100.0% lines (34/34), branch n/a (0 arcs) | 100.0% lines (37/37), 100.0% branches (2/2) | 100% (changed-line 4/4) |
| PowerShell | 0 | N/A | N/A | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

Bash (kcov, no branch gate): status PENDING-CI. No kcov artifact exists locally; per-file line rates for `mutate-parallel-run.sh`, `parallel-mutation-cli.sh`, `parallel-mutation-ops.sh`, `parallel-mutation.sh`, and `remove-parallel-item.sh` are read from the PR CI job `shell-coverage / Shell Coverage (Bats + kcov)` (plan task P2-T14). This is not a number and not a defect; it is a remediation trigger only in the sense that CI evidence must be read.

Evidence checklist:

- TypeScript baseline coverage artifact: N/A — no changed TypeScript files (evidence/qa-gates/scope-check-890.md)
- TypeScript post-change coverage artifact: N/A — no changed TypeScript files (evidence/qa-gates/scope-check-890.md)
- PowerShell baseline coverage artifact: N/A — no changed PowerShell files (evidence/qa-gates/scope-check-890.md)
- PowerShell post-change coverage artifact: N/A — no changed PowerShell files (evidence/qa-gates/scope-check-890.md)
- Per-language comparison summary: Python module coverage rose from 34/34 (100.0%) to 37/37 lines with 2/2 branches (100.0%); changed-line coverage 4/4; bash coverage pending PR CI; TypeScript, PowerShell, and C# have zero changed files

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 100.0% lines / n/a branches (34/34 lines, 0 arcs). Post-change: 100.0% lines / 100.0% branches (37/37 lines, 2/2 branches). Change: +0.0 points lines, no decrease. New/changed-code coverage: 100% (changed-line 4/4). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-delta-890.md`; `artifacts/python/lcov.info` shows LF 37 / LH 37 for the module.
- Note on bash: baseline and post-change not measured locally. Disposition: PENDING-CI (kcov via `shell-coverage / Shell Coverage (Bats + kcov)`).
- Note on TypeScript, PowerShell, C#: N/A — no changed files (`evidence/qa-gates/scope-check-890.md`).
- Note on Python repo-wide coverage: UNVERIFIED (non-blocking). The only local artifact, `artifacts/python/lcov.info`, is scoped to the one changed module (55 lines). No other Python production file changed, so no regression is possible from this diff. The main `ci.yml` Python jobs are authoritative.

## 2. General Code Change Policy Compliance

Source: `.claude/rules/general-code-change.md`.

| # | Requirement | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | 500-line limit, every new or edited non-Markdown file | PASS | `wc -l`: largest are `tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py` 481, `tests/shell/parallel_mutation_run.bats` 341, `.claude/lib/bash/parallel-mutation.sh` 322, `scripts/dev_tools/_parallel_mutation_errors.py` 253, `.claude/lib/bash/parallel-mutation-ops.sh` 193, `mutate-parallel-run.sh` 191, `parallel-mutation-cli.sh` 152; `core.json` 229; `settings.json` 292. The three SKILL.md edits are Markdown (exempt). |
| 2 | Byte-identical mirrors | PASS | `cmp` over the ten mirrored files (persona, five bash scripts, settings.json, three SKILL.md) reported identical for each. |
| 3 | Pack-manifest membership | PASS | `core.json` diff adds `mutate-parallel-run.sh`, `parallel-mutation-cli.sh`, `parallel-mutation-ops.sh`, in sorted position; `parallel_bash_manifest_membership.bats` updated to seven entry points. |
| 4 | Persona grant change matches R6 | PASS | `Bash(poetry run python -c *)` removed; `Bash(bash .claude/lib/bash/mutate-parallel-run.sh*)` added directly after the `remove-parallel-item.sh` grant; prose rewritten per R6 and does not contain `python -c`. Decision record: `evidence/other/python-c-grant-decision-890.md`. `git grep` for `python -c`/`poetry run python` over `.claude` finds only the prose sentence "No `poetry run python` grant is held". |
| 5 | settings.json allow entry | PASS | Entry added between `compute-concurrency-batches.sh` and `remove-parallel-item.sh` as R6 states; operator approval recorded in `evidence/other/operator-approval-settings-allow-890.md` and issue.md `## Operator Approvals`; mirror identical. |
| 6 | Skill rewrites match R5 | PASS | Add: steps 4, 5, 6 rewritten with `admit`, `recolor`, `add-entry`; steps 1-3 untouched. Close: steps 2, 3, 4 rewritten; step-4 sentence on one line. Orchestrate: three anchored passages rewritten; lines for `is_closed_mode_complete`, `has_unresolved_drift`, `request_requeue_via_recolor` unedited. Zero hits for the seven engine names in the six skill files. |
| 7 | Overlap zones untouched (#885, #899) | PASS | Hunk headers: parallel-add old ranges 108-169 (zone 53-74), parallel-orchestrate 665-831 (zone 371-385). See `evidence/qa-gates/overlap-zones-890.md`. |
| 8 | FU-791-2 enum member selection | PASS | `_ENUM_MEMBERS_BY_FIELD` maps three fields; unmapped field raises exactly `ValueError`; bash `pm_decide_removal` lists `${PM_VALID_DISPOSITIONS// /, }`; the four divergence comments carry R1 wording; no raise site passes a field outside the map (`parallel_mutation_protocol.py:412`, `_parallel_mutation_models.py:183,185,448`). |
| 9 | Policy files unmodified | PASS | Diff contains no path under `.claude/rules/` or `.github/instructions/`. |
| 10 | Tone policy in authored text | PASS | Persona, skill, and comment prose is factual; no hyperbole or humor found. |
| 11 | Operator-accepted residual risks carried unchanged | PASS | `issue.md` lines 34-39 (risks a and b, acceptance status unchanged); carry-forward note `evidence/other/pr-body-carry-forward-890.md`. |
| 12 | Mandatory toolchain loop (Python) | PASS | Single QC pass, zero restarts; see section 7. |

## 3. Language-Specific Code Change Policy Compliance

Sources: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/shell.md`.

| Language | Requirement | Verdict | Evidence |
| --- | --- | --- | --- |
| Python | Black, Ruff, Pyright (strict), no new suppressions | PASS | `evidence/qa-gates/`: Black `5 files left unchanged`, Ruff `All checks passed!`, Pyright `0 errors, 0 warnings, 0 informations`. |
| Bash | New files use only permitted external commands | PASS | `parallel-mutation-ops.sh` uses `sort` only. `parallel-mutation-cli.sh` uses `date`, only when `--at` is omitted. `mutate-parallel-run.sh` uses `dirname` (script dir). All proof cases in `parallel_payload_only.bats` pass `--at` or need no clock, and the shim PATH exposes `sort`, `cut`, `cat`, `dirname`. |
| Bash | Lint (shfmt, shellcheck) | PASS (local pre-check) | `shell-lint-local-890.md`: both exit 0, empty output, on all five bash scripts. Local versions differ from CI pins (shfmt 3.12.0 vs CI 3.8.0); CI `shell-qc.sh check` remains authoritative. |
| PowerShell / C# / TypeScript | Zero changed files | PASS | `evidence/qa-gates/scope-check-890.md`: no `.ps1/.psm1/.psd1`, no TypeScript, no C# in the diff; no deletions; nothing under `.claude/rules/` or `.github/instructions/`. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
| --- | --- | --- | --- |
| Python | Pytest, Arrange-Act-Assert, message-bearing assertions | PASS | Errors test asserts `type(...) is ValueError` to exclude the subclass; corpus lane has a floor and an exact stem-set test so it cannot pass vacuously. |
| Python | Test file location mirrors source | PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |
| Bash | Bats suites placed under `tests/shell/` | PASS | `parallel_mutation_run.bats`, `parallel_mutation_run_parity.bats`, and edited suites. Execution is PENDING-CI. |

## 5. Test Coverage Detail

See sections 1.2 and 1.2.1. Python verdict: PASS (changed module 100% lines, 100% branches, changed-line 4/4). Bash verdict: PENDING-CI (kcov not producible locally under the operator's Option A constraint; plan task P2-T14 reads it from the PR CI run). TypeScript, PowerShell, and C#: N/A (zero changed files).

## 6. Test Execution Metrics

| Run | Tests | Result | Source |
|---|---|---|---|
| Python toolchain pytest | 129 passed | PASS | `evidence/qa-gates/` |
| Surface suite | 102 passed | PASS | `evidence/qa-gates/` |
| Bash parity Python lane (`test_parallel_mutation_run_bash_parity.py`) | 25 passed, "corrections: none" | PASS | `evidence/qa-gates/` |
| Bats suites (`parallel_mutation_run.bats`, `parallel_mutation_run_parity.bats`, three edited bats files) | not run | PENDING-CI | PR CI `shell-coverage` job |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Black | `5 files left unchanged` |
| Ruff | `All checks passed!` |
| Pyright | `0 errors, 0 warnings, 0 informations` |
| Pytest | `129 passed` |
| shfmt / shellcheck (local pre-check) | exit 0 on all five bash scripts (CI pins authoritative) |
| Evidence locations | `validate_evidence_locations.py --root .` exit 0 |

## 8. Gaps and Exceptions

- Bash line coverage (kcov): no local artifact; classified PENDING-CI per caller directive. Not a defect.
- Bats suites: first execution is in CI.
- Local shfmt 3.12.0 differs from the CI pin 3.8.0; `shell-qc.sh check` in CI is authoritative.
- Python repo-wide coverage: UNVERIFIED (non-blocking); module-scoped artifact only.

Non-blocking observations (also in `code-review.2026-10-12T20-40.md`):

1. `tests/shell/parallel_mutation_run_parity.bats:74-103`: the 21-fixture replay is one `@test`; a failing fixture is identified by the stderr line. This mirrors the existing remove-parity suite.
2. `.claude/lib/bash/parallel-mutation-cli.sh:93`: `PMCLI_VALUE=$(($1))` wraps silently for integer tokens beyond 64-bit; outside the corpus and the skills' use.
3. `.claude/agents/parallel-orchestrator.md:105-110` (and mirror): one prose line exceeds the surrounding wrap width. Markdown; cosmetic.

## 9. Summary of Changes

- Python changes: `_parallel_mutation_errors.py` gains `_ENUM_MEMBERS_BY_FIELD`; new tests for each mapped field and the unmapped case; new Python parity lane over the 21-fixture corpus.
- Bash: new `mutate-parallel-run.sh`, `parallel-mutation-cli.sh`, `parallel-mutation-ops.sh`; `parallel-mutation.sh` and `remove-parallel-item.sh` edited; new and edited bats suites; mirrors byte-identical.
- Skills and agents: three SKILL.md files rewritten to call the bash entry point; persona grant swapped; `settings.json` allow entry added; `core.json` manifest updated.
- Feature folder: issue, plan, research, and evidence files.

## 10. Compliance Verdict

**CONDITIONAL.** PASS for every check evaluable locally. Two items depend on PR CI and cannot be evaluated here: bash kcov coverage and bats execution (and the CI re-run of the lint pre-check). Blocking findings: 0. No remediation inputs are required.

## Appendix A: Test Inventory

| Test file | Status | Lane | Notes |
|---|---|---|---|
| `tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py` | New | Python | 25 passed; replays the 21-fixture corpus |
| `tests/scripts/dev_tools/` errors test for `_parallel_mutation_errors.py` | Modified | Python | per-field, real raise site, unmapped-field cases |
| `tests/shell/parallel_mutation_run.bats` | New | Bats | PENDING-CI |
| `tests/shell/parallel_mutation_run_parity.bats` | New | Bats | PENDING-CI; 21 fixtures in one `@test` |
| `tests/shell/parallel_mutation_remove.bats` | Modified | Bats | PENDING-CI; new case for aligned `pm_decide_removal` message |
| `tests/shell/parallel_payload_only.bats` | Modified | Bats | PENDING-CI |
| `tests/shell/parallel_bash_manifest_membership.bats` | Modified | Bats | PENDING-CI; seven entry points |
| `tests/fixtures/parallel_mutation_run/` | New | Corpus | 21 fixtures |

## Appendix B: Toolchain Commands Reference

Run from the repository root:

- `black` / `ruff check` / `pyright` / `pytest` via the repository's Poetry toolchain (results in `evidence/qa-gates/`)
- `shfmt` and `shellcheck` on the five bash scripts (local pre-check); `shell-qc.sh check` in CI
- `bats` suites and kcov run only in PR CI job `shell-coverage / Shell Coverage (Bats + kcov)`
- `git diff origin/main...HEAD`
- `cmp` over the ten mirrored files
- `python -I scripts/dev_tools/validate_evidence_locations.py --root .`
