# Policy Compliance Audit: parallel-skill CLI port follow-ups (#791)

**Audit Date:** 2026-10-10
**Branch:** `bug/issue-763-parallel-skill-cli-port-follow-ups-791` @ `a00195532`
**Base:** `origin/main` @ `7bbd0b9b9` (merge-base `7bbd0b9b9`; range `7bbd0b9b9..a00195532`, 14 commits)
**Code Under Test:** `scripts/dev_tools/skill_bundle_contract.py`, `.claude/lib/bash/parallel-mutation.sh` (new), `.claude/lib/bash/remove-parallel-item.sh` (new), `.claude/skills/parallel-remove/SKILL.md`, `.claude/settings.json`, `.claude/agents/parallel-orchestrator.md`, their bundled copies under `extensions/drm-copilot/resources/claude-customizations/`, and `pack-manifests/core.json` (96 changed files in total, of which 56 are feature-folder documents and evidence)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 2 new production, 2 new + 2 modified bats suites | bats 592 (baseline 544) | PASS, 0 not ok (CI run 38053315951) | repo 94.2% lines (CI run 38019731256 at merge-base) | repo 94.5% lines | remove-parallel-item.sh 99.1% lines; parallel-mutation.sh 95.7% lines |
| Python | 1 modified production, 1 new + 2 modified tests | 6769 passed, 6 skipped (CI 3.12); 135 targeted passed locally | PASS, 0 failed | repo 93.61% lines (17571 stmts, 1122 miss); skill_bundle_contract.py 96.45% lines, 95.00% branches | repo 93.61% lines; skill_bundle_contract.py 96.45% lines, 95.00% branches | skill_bundle_contract.py 96.45% lines, 95.00% branches (2 changed lines, both covered) |
| PowerShell | 0 production, 1 modified test | Pester 6744 passed (baseline 6743); Linux hook suites 3416 passed | PASS, 0 failed | repo 87.31% commands (CI run 38019731256) | repo 87.31% commands | N/A - 0 production PowerShell lines changed |
| TypeScript | 0 files | N/A | N/A | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - 0 changed TypeScript files on the branch
- TypeScript post-change coverage artifact: N/A - 0 changed TypeScript files on the branch
- PowerShell baseline coverage artifact: CI run 38019731256 (merge-base 7bbd0b9b9), PowerShell QC job log line `Covered 87.31% / 0%. 22,010 analyzed Commands in 178 Files.`
- PowerShell post-change coverage artifact: `evidence/qa-gates/ci-deferred-gates.2026-10-10T13-20.md` (CI run 38053315951, job 114216674984, `Covered 87.31%`)
- Per-language comparison summary: section 1.2.1 below
- Bash post-change coverage artifact: `evidence/qa-gates/ci-deferred-gates.2026-10-10T13-20.md`; per-file rates re-read by this review from the downloaded `shell-coverage` artifact `cov.xml` (remove-parallel-item.sh line-rate 0.991, parallel-mutation.sh line-rate 0.957, totals 0.945)
- Python coverage artifacts: `evidence/baseline/python-pytest-coverage.2026-10-10T08-05.md`, `evidence/qa-gates/python-pytest-coverage.2026-10-10T08-39.md`, `evidence/qa-gates/python-coverage-comparison.2026-10-10T08-39.md`; `artifacts/python/lcov.info` re-parsed by this review (LF 141, LH 136, BRF 60, BRH 57)

---

## Executive Summary

The branch resolves four #763 follow-ups. FU-763-5: the skill-bundle guard's `bash|sh|source` and `python <path>` patterns now require horizontal whitespace (`[ \t]+`) between verb and path, so a fence info string no longer consumes the next line's interpreter word (zero net line change; 486 lines). FU-763-3: `parallel-remove` steps 2, 3 and 6 now invoke a new bundled bash entry point `remove-parallel-item.sh` (subcommands `decide`, `recolor`, `entry`) backed by a new library `parallel-mutation.sh`, with a 15-fixture parity corpus asserted by both a bats lane and a Python lane. FU-763-2: two narrow allow entries were added to both `settings.json` copies. FU-763-1: the unused `Bash(poetry run python -m *)` grant was removed from both agent copies and a remove-script grant added.

All mirror files are byte-identical (verified with `cmp`). All changed files are at or below 500 lines. No test creates a temporary file or waits on the clock. CI run 38053315951 at `c81ffad7e` concluded success on all 17 jobs (confirmed by this review through `gh run view`); the only commit after it adds one evidence document. Coverage meets the uniform thresholds for every language with changed files, with no regression relative to the merge-base CI run. No blocking finding was identified.

**Policy documents evaluated:**
- Reviewed: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`
- Language-specific: `.claude/rules/shell.md`, `.claude/rules/python.md`, `.claude/rules/powershell.md` (test file only)

**Temporary artifacts cleanup:**
- No temporary scripts are in the branch diff. Local `artifacts/python/*.json` and `artifacts/pr_context.*` are untracked tool outputs, not branch content. The worktree was clean before this review; the only edit made by this review is the AC check-off in `spec.md` plus these review artifacts.

## Rejected Scope Narrowing

None. The caller prompt specified the full branch diff against `main` and did not limit files, languages, or toolchain checks. Two caller statements were evaluated and are not scope narrowing: (1) the operator constraint that local PowerShell and bats verification used the PoshQC MCP tools plus CI job logs is a statement about evidence source, and this review evaluated PowerShell and bash coverage with explicit PASS/FAIL verdicts from CI logs; (2) the instruction to record two operator-accepted residual risks as non-blocking is a severity disposition already recorded in `spec.md` (Risks & Mitigations), not an exclusion of any file or check.

## Evidence Location Compliance

- Scan: `git diff --merge-base origin/main HEAD --name-only` filtered for `^artifacts/(baselines|qa|evidence|coverage)/` returned no paths (grep exit 1).
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- All execution evidence lives under `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/evidence/{baseline,other,qa-gates,regression-testing}/`. Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | bats cases each invoke the script in a fresh process; the library-level cases re-set `PM_RESULT`/`PM_ERROR` on every call. Python parity cases are parametrized per fixture with no shared mutable state. |
| Isolation | PASS | One subcommand row per bats case; one fixture per parametrized Python case; one scenario per guard test. |
| Fast execution | PASS | 135 targeted Python tests passed in 0.75 s locally. |
| Determinism | PASS | Default `--at` case asserts format only; Python lane uses a fixed clock seam `_fixed_clock`. No wall-clock comparisons. |
| Readability | PASS | Descriptive test names; Arrange/Act/Assert comments in all new Python tests; bats helpers `assert_single_line` and `assert_usage_error`. |

### 1.2 Coverage Requirements

| Requirement | Verdict | Evidence |
|---|---|---|
| Line >= 85% (all languages with changed files) | PASS | Bash new files 99.1% and 95.7%; Python changed module 96.45%; PowerShell repo 87.31%. |
| Branch >= 75% (branch-capable languages) | PASS | Python `skill_bundle_contract.py` 95.00%. Bash and PowerShell have no branch gate (`.claude/rules/shell.md`, `.claude/rules/powershell.md`). |
| No regression on changed lines | PASS | Python missing lines identical before and after (`109, 216, 245-246, 254`); changed lines 52 and 64 are executed on import and exercised by the regression tests. Bash files are new. |
| Coverage exclusion policy | PASS | No `exclude` entry added in the diff. |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 94.2% repo lines (CI run 38019731256 at merge-base). Post-change: 94.5% repo lines (CI run 38053315951). Change: +0.3 points; two new files added. New/changed-code coverage: 99.1% remove-parallel-item.sh, 95.7% parallel-mutation.sh. Disposition: PASS. Evidence: `evidence/qa-gates/ci-deferred-gates.2026-10-10T13-20.md` and the `shell-coverage` artifact `cov.xml` re-read by this review.
- Python: Baseline: 96.45% lines and 95.00% branches for skill_bundle_contract.py; repo 93.61% lines. Post-change: 96.45% lines and 95.00% branches for skill_bundle_contract.py; repo 93.61% lines. Change: none (0.00 points; the same five lines are uncovered before and after). New/changed-code coverage: 96.45% lines, 95.00% branches (both changed lines covered). Disposition: PASS. Evidence: `evidence/qa-gates/python-coverage-comparison.2026-10-10T08-39.md`; CI 3.12 `TOTAL 17571 1122 6342 511 92%` in both runs 38019731256 and 38053315951.
- PowerShell: Baseline: 87.31% repo commands (6743 passed). Post-change: 87.31% repo commands (6744 passed). Change: none; one test case added, no production PowerShell file changed. New/changed-code coverage: N/A, 0 production lines changed. Disposition: PASS. Evidence: `evidence/qa-gates/ci-deferred-gates.2026-10-10T13-20.md` and the CI run 38019731256 PowerShell QC log.

### 1.3 Scenario Completeness

| Area | Verdict | Evidence |
|---|---|---|
| Positive flows | PASS | Every unstarted state, both in-flight dispositions, both recolor offset rules, recompute true/false. |
| Negative flows | PASS | in_flight without disposition, withdrawn, blocked, merged, unknown item, overlap, negative cohort, duplicate key, entry contract rejections. |
| Edge cases | PASS | Empty unstarted set, empty `--pinned`, disposition on unstarted decide, `--at` with a space. |
| Error handling | PASS | Missing/unknown subcommand, unknown option, abbreviation, missing value, missing required option. |
| Guard regression | PASS | Six fence/verb combinations, python fence, split-line negative; fail-before evidence `evidence/regression-testing/fail-before.2026-10-10T08-16.md` shows 10 failed before the fix. |

### 1.4 Test Hygiene

| Rule | Verdict | Evidence |
|---|---|---|
| No temporary files | PASS | This review's Grep over the eight changed test files for `mktemp|tmp_path|tempfile|TMPDIR|TestDrive|sleep|/tmp` returned no matches; `evidence/qa-gates/test-hygiene.2026-10-10T08-45.md`. |
| No real wall-clock waits | PASS | Same scan. |
| No external services | PASS | No network access; the payload suite uses checked-in shims under `tests/fixtures/parallel_payload_path`. |
| Test location | PASS | Tests under `tests/shell/`, `tests/scripts/dev_tools/`, `tests/scripts/claude-hooks/`, `tests/fixtures/`; none colocated with production. |

---

## 2. General Code Change Policy Compliance

| Rule | Verdict | Evidence |
|---|---|---|
| Simplicity / separation of concerns | PASS | Pure library (`parallel-mutation.sh`, no I/O, no clock) separated from the CLI entry point that owns argument parsing, the single clock read, and exit codes. |
| Reusability | PASS | Reuses `pcoh_compute_cohorts`, `pc_enum_members_contains`, `pc_repr`, `pcoh_split_words` from existing libraries. |
| File size <= 500 lines | PASS | Largest changed code file 486 (`skill_bundle_contract.py`); new bash 318 and 251; largest test 367. Re-measured with `wc -l` by this review. |
| Fail fast / explicit errors | PASS | Usage errors exit 2 with a fixed prefix; rule rejections exit 1 with the reference message. |
| Dependencies | PASS | No new dependency. |
| Public API compatibility | PASS | Python engine unchanged; guard extracts a superset for same-line invocations. Agent `-m` grant removal is documented with no caller (spec D4). |
| Bundle mirror byte identity | PASS | `cmp` reports identical for `parallel-mutation.sh`, `remove-parallel-item.sh`, `settings.json`, `parallel-orchestrator.md`, `parallel-remove/SKILL.md`. `core.json` registers both new library files. |

---

## 3. Language-Specific Code Change Policy Compliance

| Language | Rule | Verdict | Evidence |
|---|---|---|---|
| Bash | `set -euo pipefail` in executable script | PASS | `remove-parallel-item.sh:40`; the library is sourceable and does not set options, matching existing library precedent. |
| Bash | shfmt / shellcheck clean | PASS | CI `shell-qc.sh check` step success (shfmt 3.8.0); local `evidence/qa-gates/bash-shell-qc-check.2026-10-10T08-40.md` exit 0. |
| Bash | Suppressions justified inline | PASS | `SC2034` file-wide with a stated reason; `SC1091` paired with `# shellcheck source=` directives, matching `parallel-cohorts.sh` precedent. See code-review CR-5 (Info). |
| Bash | No Python invocation in `.claude/lib` | PASS | Grep of both new files for `python|poetry` outside comments returned nothing; payload cases run with a PATH that exposes no Python. |
| Python | black / ruff / pyright | PASS | Re-run check-only by this review on the four changed Python files: black `4 files would be left unchanged`, ruff `All checks passed!`, pyright `0 errors, 0 warnings`. |
| Python | Suppressions | PASS | No new suppression comment in the diff. |
| PowerShell | Test-only change | PASS | CI PowerShell QC job success (format and analyzer stages included). |
| JSON | Settings allow entries narrow | PASS | Two exact-script entries; no `Bash(bash .claude/lib/bash/*)` wildcard. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Verdict | Evidence |
|---|---|---|
| Bash (bats) | PASS | 592/592 ok in CI; new suites live in `tests/shell/` following the existing `parallel_*.bats` convention for `.claude/lib/bash`. |
| Python (pytest) | PASS | AAA structure, docstrings, actionable assertion messages; parity lane enforces a floor of 15 and an exact required-case set. |
| PowerShell (Pester) | PASS | R791-O1 drives the pure decision and scope functions with a literal command; reported `status="Passed"` in `pester-junit.xml` (CI). |

## 5. Test Coverage Detail

| File | Status | Line | Branch | Threshold result |
|---|---|---|---|---|
| `.claude/lib/bash/remove-parallel-item.sh` | New | 99.1% | N/A (kcov) | PASS |
| `.claude/lib/bash/parallel-mutation.sh` | New | 95.7% | N/A (kcov) | PASS |
| `scripts/dev_tools/skill_bundle_contract.py` | Modified | 96.45% | 95.00% | PASS, no regression |
| Bash repo-wide | — | 94.5% | N/A | PASS |
| Python repo-wide | — | 93.61% | combined cover 92% (511 partial of 6342 branches) | PASS |
| PowerShell repo-wide | — | 87.31% | N/A (Pester) | PASS |

## 6. Test Execution Metrics

| Suite | Result | Source |
|---|---|---|
| bats (all suites, kcov) | 1..592, 592 ok | CI run 38053315951 job 114216674796 |
| Pester PowerShell QC | 6744 passed, 0 failed, 10 skipped | CI job 114216674984 |
| Pester Linux hook suites | 3416 passed, 0 failed | CI job 114216674923 |
| pytest (3.10-3.13) | success; 3.12: 6769 passed, 6 skipped | CI quality-checks jobs |
| pytest targeted (this review) | 135 passed | local, check-only |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| black --check | PASS |
| ruff check | PASS |
| pyright | PASS (0 errors) |
| shfmt -d / shellcheck | PASS (CI) |
| PSScriptAnalyzer / Invoke-Formatter | PASS (CI PowerShell QC job success) |
| Evidence locations validator | PASS (exit 0) |

## 8. Gaps and Exceptions

- Operator constraint (non-blocking, not a defect): local bats and Pester runs were replaced by PoshQC MCP calls and CI job logs (`evidence/other/execution-deviations.2026-10-10T08-02.md`). This review confirmed the CI figures directly from run logs and the kcov artifact.
- Operator-accepted residual risks (non-blocking, accepted in `spec.md` Risks & Mitigations): (a) a timed-out PreToolUse hook does not block, so the new `abandon-parallel-item.sh` allow entry could skip a prompt in that case; (b) an installed plugin that handles tool checks can approve a hook-blocked call regardless of allow entries.
- PR context artifacts were generated at `c81ffad7e`; HEAD `a00195532` differs only by `evidence/qa-gates/ci-deferred-gates.2026-10-10T13-20.md`. Not regenerated because no code changed.
- `artifacts/python/lcov.info` is a module-scoped run (only `skill_bundle_contract.py`); repo-wide Python figures were taken from the CI 3.12 `TOTAL` line instead.
- Evidence timestamp accuracy: `hook-precedence-verification.2026-10-10T08-36.md` was committed at 08:35:50 local, so its name is slightly later than its write time; the deviation log records the same class of issue for four other artifacts. The commit ordering satisfies AC-21 (artifact committed in `3e6a2545f` before the permission edits in `e0e8dee1a`). Informational.

## 9. Summary of Changes

- Guard: `[ \t]+` separator in two patterns; comment updated.
- New bash library and entry point plus bundled copies and manifest registration.
- `parallel-remove/SKILL.md` steps 2, 3, 6 invoke the entry point; Python module retained as a parity citation.
- Settings: two allow entries. Agent: `-m` grant removed, remove-script grant added, prose updated.
- Tests: 3 guard unit tests (8 cases), 2 repo tests, 1 Pester case, 3 bats suites changed/added, 1 Python parity lane, 15 fixtures.

## 10. Compliance Verdict

**PASS.** No blocking findings. Coverage verdicts: Bash PASS, Python PASS, PowerShell PASS; TypeScript and C# have zero changed files. Non-blocking observations are recorded in the code review.

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_skill_bundle_contract.py`: `test_extract_reads_invocation_on_first_line_of_shell_fence` (6 cases), `test_extract_reads_python_invocation_on_first_line_of_python_fence`, `test_extract_ignores_verb_and_path_split_across_lines`.
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`: `test_parallel_plan_extracts_compute_cohorts_under_bash_fence`, `test_parallel_remove_invokes_bundled_remove_script`.
- `tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py`: floor, required-case set, success/rejection per subcommand, 15 parametrized fixture cases.
- `tests/shell/parallel_mutation_remove.bats`: 43 cases (decide, recolor, entry, CLI usage, library functions).
- `tests/shell/parallel_mutation_remove_parity.bats`: floor, interpreter availability, corpus replay.
- `tests/shell/parallel_payload_only.bats`: 2 new remove-entry-point payload cases.
- `tests/shell/parallel_bash_manifest_membership.bats`: entry-point list extended to six.
- `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`: R791-O1.

## Appendix B: Toolchain Commands Reference

- `git diff --merge-base origin/main HEAD --name-status`
- `cmp -s <repo file> extensions/drm-copilot/resources/claude-customizations/<repo file>`
- `wc -l <changed files>`
- `poetry run black --check`, `poetry run ruff check`, `poetry run pyright` (four changed Python files)
- `poetry run pytest <8 targeted suites> -q -p no:cacheprovider`
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
- `gh run view 38053315951 --json conclusion,headSha,jobs`; `gh run view 38053315951 --job <id> --log`; `gh run download 38053315951 -n shell-coverage`
- `gh run view 38019731256 --log` (merge-base baseline)
