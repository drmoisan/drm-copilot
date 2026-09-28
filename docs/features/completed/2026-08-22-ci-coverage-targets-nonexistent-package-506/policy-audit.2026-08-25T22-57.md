# Policy Audit — Issue #506 (ci-coverage-targets-nonexistent-package)

- **Timestamp:** 2026-08-25T22-57
- **Issue:** #506
- **Work Mode:** `full-bug` (marker read from `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/issue.md` line 13). AC source is `spec.md` only.
- **Branch:** `bug/ci-coverage-targets-nonexistent-package-506-r3`
- **Branch head:** `890e2ac9369e5a67f282bb7bc3ca438589427676`
- **Base:** `origin/main` (merged into the branch at `890e2ac9`)
- **Review worktree:** `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae6ac3aa9ae64fae4`
- **Diff scope:** full branch diff `git diff origin/main...HEAD` — 43 files, 5866 insertions, 2 deletions

---

## Scope Statement

The audited scope is the full branch diff against `origin/main`. No caller narrowing was applied.

Production and test files in the diff (four):

| Path | Status | Lines |
| --- | --- | --- |
| `.github/workflows/_quality-checks.yml` | modified | 96 |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | new | 324 |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | new | 188 |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | new | 157 |

The remaining 39 changed files are the feature-folder documents and the evidence subtree under
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/`.

**Languages with changed files in the branch diff:** Python (three files) and GitHub Actions YAML
(one file). No TypeScript, PowerShell, C#, or bash file is changed on this branch, so those
languages have zero changed files and no coverage verdict is owed for them.

## Rejected Scope Narrowing

None. The caller prompt supplied the full branch diff as the review scope, enumerated all four
production and test files, and instructed that all nineteen acceptance criteria be evaluated. No
instruction attempted to narrow scope to a plan, task, phase, or file subset, and no instruction
attempted to mark a language's coverage as out of scope. Nothing was rejected under the scope
invariant.

---

## Verdict Summary

| # | Policy | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | `.claude/rules/ci-workflows.md` — pwsh exit-code rule | **PASS (not triggered)** | Workflow declares no `shell:` key and no `defaults.run.shell`; runs on `ubuntu-latest` |
| 2 | `.claude/rules/ci-workflows.md` — general workflow authoring | **PASS** | actionlint exit 0 over the modified workflow set |
| 3 | `modified-workflow-needs-green-run` (feature-review-workflow SKILL) | **FAIL (Blocking, pending P6-T5)** | No run exists whose head SHA equals `890e2ac9`; see section 3 |
| 4 | `.claude/rules/quality-tiers.md` — uniform 85% line / 75% branch | **PASS** | Repo-wide 92.65% line, 85.22% branch; new file 96.72% line, 85.71% branch |
| 5 | `.claude/rules/general-unit-test.md` — Coverage Exclusion Policy | **PASS** | No `exclude`/`omit` entry added; `pyproject.toml` not in the diff |
| 6 | `.claude/rules/general-unit-test.md` — no temp files in tests | **PASS** | Both new test files use the in-memory `mem_fs_path` fixture |
| 7 | `.claude/rules/general-unit-test.md` — test file location | **PASS** | Both tests under `tests/scripts/dev_tools/`; D6 records the precedent |
| 8 | `.claude/rules/general-unit-test.md` — scenario completeness | **PARTIAL** | Two named validation conditions carry no unit test; see finding NB-1 |
| 9 | `.claude/rules/general-code-change.md` — 500-line file limit | **PASS** | Largest changed file is 324 lines |
| 10 | `.claude/rules/general-code-change.md` — I/O boundaries | **PASS** | `find_threshold_breaches` is pure; `load_totals` is the sole I/O seam |
| 11 | `.claude/rules/general-code-change.md` — fail fast, no broad catch | **PASS** | Two narrow `except` clauses (`OSError`, `json.JSONDecodeError`), one narrow domain handler |
| 12 | `.claude/rules/general-code-change.md` — seven-stage toolchain loop | **PASS** | Single-pass transcript recorded; independently re-run in this review |
| 13 | `.claude/rules/python.md` — Black | **PASS** | `poetry run black --check` on all three files: unchanged |
| 14 | `.claude/rules/python.md` — Ruff | **PASS** | `poetry run ruff check` on all three files: all checks passed |
| 15 | `.claude/rules/python.md` — Pyright | **PASS** | `poetry run pyright` on all three files: 0 errors, 0 warnings |
| 16 | `.claude/rules/python.md` — Pytest | **PASS** | 15 new tests pass; full suite 4136 passed, 5 skipped, exit 0 |
| 17 | `.claude/rules/python.md` — logging, not `print` | **PARTIAL (informational)** | CLI writes to stderr via `print`; 23 in-repo precedents; see NB-2 |
| 18 | `.claude/rules/plan-acceptance-gates.md` (G1–G6) | **PASS** | Plan validator exits 0; five Warnings, zero Blocking |
| 19 | Evidence Location Invariant | **PASS** | `validate_evidence_locations.py --root .` exits 0 |
| 20 | `.claude/rules/tonality.md` | **PASS** | Feature documents and evidence artifacts read neutral and evidence-first |
| 21 | `.claude/rules/orchestrator-state.md` | **N/A** | No orchestrator-state file in the branch diff |
| 22 | `.claude/rules/benchmark-baselines.md` | **N/A** | No `scripts/benchmarks/**` path in the branch diff |

**Blocking findings: 1** (row 3).

---

## 1. `.claude/rules/ci-workflows.md`

### 1.1 Deliberately-failing nested command pattern — NOT TRIGGERED (PASS)

The rule binds to a workflow step whose `run:` block uses `shell: pwsh` (or a repo default of
`pwsh`) and intentionally invokes a command expected to fail.

Evidence:

- `grep -n "pwsh\|shell:" .github/workflows/_quality-checks.yml` returns no match. The file
  declares no `shell:` key on any step and no `defaults.run.shell` at workflow or job level.
- `runs-on: ubuntu-latest` (line 10), whose GitHub Actions default shell is `bash`.
- Neither step added or modified by this change invokes a deliberately-failing nested command:
  - The pytest step (`Run tests with Pytest`) runs `poetry run pytest ...` and is expected to
    succeed.
  - The new step (`Enforce Python coverage thresholds`) runs the checker module and is expected to
    succeed; its non-zero exit is the intended failure signal, not a residual leaked exit code from
    a nested command whose verification already passed.

No `$LASTEXITCODE = 0` reset and no explicit `exit 0` is required. This determination matches the
one the spec recorded in advance at `spec.md` line 171 ("Boundaries and invariants to preserve"),
and the recorded determination is confirmed rather than merely accepted.

### 1.2 General workflow authoring — PASS

- actionlint over the modified workflow set exits 0 with zero findings. Evidence:
  `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-workflow-actionlint.md`
  (`Command: pwsh -File scripts/dev-tools/run-actionlint.ps1`, `EXIT_CODE: 0`), taken after all
  Phase 1 through Phase 3 edits so that the final committed state is the state that was linted.
  A matching pre-change baseline is at `evidence/baseline/workflow-actionlint.md`, so the edits
  introduced no new finding.
- The `codecov/codecov-action@v7` input key is corrected from the undeclared `file` to the declared
  `files`. The action's declared input set includes `files` and not `file`. This is an undeclared
  input correction, verified structurally by
  `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py::test_codecov_step_uses_the_declared_files_input`.
- Step ordering is coherent: the enforcement step is placed immediately after the pytest step that
  produces the report it reads, and before the Codecov upload. The enforcement step carries no
  `if:` key, so it runs on all four Python matrix legs, consistent with decision D3.
- Verified independently: the `--cov-report=json:artifacts/python/coverage.json` target directory
  does not need to pre-exist. `coverage/report_core.py::render_report` calls
  `ensure_dir_for_file(output_path)` before opening the output file (confirmed against the
  installed `coverage` 7.13.2 source in this environment), so `artifacts/python/` is created by the
  reporter on a clean runner checkout. The enforcement step therefore cannot fail on a missing
  directory.
- Verified independently: `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds`
  resolves, because `scripts/__init__.py` and `scripts/dev_tools/__init__.py` both exist, and
  because the same invocation form is already used at line 71 of the same workflow for
  `scripts.dev_tools.generate_codex_agent_variants --check`.
- Verified independently: the bare `--cov` form immediately followed by `--cov-branch` does not
  bind `--cov-branch` as the coverage target. `pytest_cov/plugin.py` declares `--cov` with
  `nargs='?'`, and `argparse` does not consume a following token that begins with `-` as an
  optional's value. The live run at
  `evidence/qa-gates/workflow-command-coverage-json.md` confirms this empirically: the command
  measured 15014 statements.

---

## 2. Evidence Location Compliance — PASS

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0 with no output.
- Scan of the branch diff for files under `artifacts/baselines/`, `artifacts/qa/`,
  `artifacts/evidence/`, or `artifacts/coverage/`: **zero matches**. Every one of the 39 changed
  documentation files resolves under
  `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/` and, where it is
  an evidence artifact, under one of the canonical kinds `baseline/`, `qa-gates/`,
  `regression-testing/`, or `other/`.
- The spec and the plan each carry an explicit, correctly-formed
  `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record replacing a non-canonical `evidence/coverage/`
  sub-path with `evidence/qa-gates/`. No artifact in the tree uses the rejected path.
- No new file is written to `artifacts/`. The ephemeral coverage artifacts
  (`artifacts/python/coverage.json`, `artifacts/python/lcov.info`, `artifacts/.coverage`) are
  covered by the `/artifacts` entry at `.gitignore` line 6 and appear in no diff.

No occurrence to record. This section is present because the invariant requires it, and it is
clean.

---

## 3. `modified-workflow-needs-green-run` — FAIL (Blocking)

The rule fires: the branch diff modifies `.github/workflows/_quality-checks.yml`, which matches
`.github/workflows/**`.

The caller instructed that the green-run dispatch is plan task **P6-T5**, scheduled to run **after**
this review, and that the status be recorded as of the review rather than silently passed. It is
recorded here as **FAIL (Blocking, pending P6-T5)**.

### Status as of this review

| Fact | Value |
| --- | --- |
| Local branch head | `890e2ac9369e5a67f282bb7bc3ca438589427676` |
| Remote `origin/bug/ci-coverage-targets-nonexistent-package-506-r3` | `15db75d5b030fe4be2fe4edab9b9f1add0b8bf7a` |
| Runs on branch `...-506-r3` (`gh run list --branch`) | **none** |
| `_quality-checks.yml` runs with head SHA `890e2ac9` | **none** |
| Green-run evidence artifact `evidence/qa-gates/green-workflow-run.md` | **absent** |
| Plan task P6-T5 checkbox | `- [ ]` (unchecked) |

Two successful `workflow_dispatch` runs of `_quality-checks.yml` do exist, both on the sibling ref
`bug/ci-coverage-targets-nonexistent-package-506-r2`:

| Run | Head SHA | Conclusion | URL |
| --- | --- | --- | --- |
| 32923970683 | `08c9c14f6b1e93def5177a10910a12c4c12fee87` | success | https://github.com/drmoisan/drm-copilot/actions/runs/32923970683 |
| 32924210756 | `15db75d5b030fe4be2fe4edab9b9f1add0b8bf7a` | success | https://github.com/drmoisan/drm-copilot/actions/runs/32924210756 |

Neither head SHA equals the current branch head `890e2ac9`, so neither satisfies the rule's
definition ("a workflow run whose head SHA matches the current branch head and whose conclusion is
success for the affected workflow"). The rule's `workflow_dispatch` allowance is satisfied in event
type but not in head-SHA equality.

### Mitigation, recorded but not accepted as satisfaction

The gap is one merge commit wide and the merge changed none of the reviewed code:

- `890e2ac9` is `Merge remote-tracking branch 'origin/main' into bug/...-r3`, whose second parent is
  `15db75d5` — the exact SHA of the green run 32924210756.
- `git diff --name-only 15db75d5 HEAD -- <the four production/test paths>` returns **empty**. The
  workflow file, the checker module, and both test files are byte-identical at the green-run SHA
  and at the current head.
- `git diff --name-only 15db75d5...origin/main -- .github/` returns **empty**. Nothing `main`
  contributed to the merge touches any workflow, action, or instruction file.

The green run therefore exercised the identical workflow content. That is a strong mitigation and it
is why this finding is expected to clear on a single re-dispatch rather than requiring rework. It is
nonetheless recorded as **Blocking**, because the rule is stated as head-SHA equality and because
the run also did not exercise the merged `main` content that will be present at merge time.

### Corrective action

1. Push `890e2ac9` to the branch ref: `git push --set-upstream origin HEAD` (P6-T3, re-run).
2. Dispatch: `gh workflow run _quality-checks.yml --ref bug/ci-coverage-targets-nonexistent-package-506-r3` (P6-T4, re-run).
3. Poll to a terminal conclusion and record `evidence/qa-gates/green-workflow-run.md` with the run
   URL and a head SHA equal to `git rev-parse HEAD` (P6-T5).
4. Do not commit anything between step 1 and step 3; a later commit invalidates the head-SHA
   binding.

### Secondary note on plan-state consistency

The plan marks P6-T3 (push) and P6-T4 (dispatch) as `- [x]`, but the remote ref stands at
`15db75d5` and `gh run list --branch bug/...-506-r3` returns no run at all. The recorded completion
of those two tasks refers to the pre-merge state on the `-r2` ref. Both must be re-run against the
current head. This is a bookkeeping observation about the plan checkboxes, not an independent
defect in the change under review; it is folded into corrective action steps 1 and 2 above.

---

## 4. Coverage Verification

The agent inspected pre-existing coverage artifacts. No coverage generation was re-run for the
purpose of this audit.

### 4.1 Artifact presence

| Language | Changed files on branch | Required artifact | Present |
| --- | --- | --- | --- |
| Python | 3 | `artifacts/python/lcov.info` | **yes** (172,274 bytes, written 2026-08-25 22:54) |
| Python (JSON, per-file detail) | — | `artifacts/python/coverage.json` | **yes** (1,599,291 bytes, same run) |
| TypeScript | 0 | `coverage/lcov.info` | not owed — zero changed files |
| PowerShell | 0 | `artifacts/pester/powershell-coverage.xml` | not owed — zero changed files |
| C# | 0 | `artifacts/csharp/coverage.xml` | not owed — zero changed files |

The report's `meta.branch_coverage` is `true`, confirming arc data was collected, so both policy
metrics are evaluable.

### 4.2 Repo-wide Python coverage — PASS

Read from `artifacts/python/coverage.json` `totals`:

| Metric | Measured | Uniform floor (`quality-tiers.md`) | Margin | Verdict |
| --- | --- | --- | --- | --- |
| Line (`percent_statements_covered`) | **92.64686292793392 %** | 85 % | +7.65 | **PASS** |
| Branch (`percent_branches_covered`) | **85.2161278605158 %** | 75 % | +10.22 | **PASS** |
| Statement denominator (`num_statements`) | 15014 | > 0 | — | **PASS** |
| Branch denominator (`num_branches`) | 5506 | > 0 | — | **PASS** |

These figures independently reproduce the values recorded by the executor at
`evidence/qa-gates/workflow-command-coverage-json.md` (`15014 92.64686292793392 85.2161278605158`).
Both are also above the 80 % repo-wide flag threshold of the coverage-verification procedure.

### 4.3 New file — PASS

`scripts/dev_tools/check_python_coverage_thresholds.py` is the only new production file.

| Metric | Measured | New-code floor | Verdict |
| --- | --- | --- | --- |
| Line (`percent_statements_covered`) | **96.72131147540983 %** | 85 % (and the 90 % procedure flag) | **PASS** |
| Branch (`percent_branches_covered`) | **85.71428571428571 %** | 75 % | **PASS** |
| Statements | 61 | — | — |
| Missing lines | 2 (lines 230, 236) | — | see NB-1 |
| Missing branches | 2 (`229→230`, `235→236`) | — | see NB-1 |
| Excluded lines | 4 (59, 60 — the `if TYPE_CHECKING:` block; 323, 324 — the `if __name__ == "__main__":` block) | — | permitted |

The four excluded lines are excluded by the pre-existing `[tool.coverage.report] exclude_lines`
configuration in `pyproject.toml`, which this change does not touch. `TYPE_CHECKING` blocks and
`__main__` guards are non-executable under test and are expressly contemplated by
`.claude/rules/general-unit-test.md`. No new exclusion was introduced.

The two new test files are test code and are excluded from the coverage denominator by the
pre-existing configuration, per the permitted-exclusion list in `general-unit-test.md`.

### 4.4 Modified files — PASS

The only modified file is `.github/workflows/_quality-checks.yml`, which is YAML, not a coverage
language. No Python file that existed before this branch was modified, so there is no changed-line
coverage regression to evaluate on a modified file.

### 4.5 No-regression on changed lines — PASS

`evidence/qa-gates/coverage-delta.md` records the pre/post pair, each read from a JSON report
rather than from a terminal `TOTAL` row:

| Metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| Line | 92.6302414231258 % | 92.64686292793392 % | **+0.0166** |
| Branch | 85.21485797523671 % | 85.2161278605158 % | **+0.0013** |

Both metrics increased. The statement denominator rose from 14953 to 15014, a difference of 61,
which equals the added module's statement count exactly, so the denominator change is fully
accounted for.

### 4.6 Coverage Exclusion Policy — PASS

- `pyproject.toml` is not in the branch diff (verified:
  `git diff --name-only origin/main...HEAD -- pyproject.toml` returns empty), so no `omit` entry was
  added, removed, or widened.
- No `exclude`/`omit` entry matching a production source path appears anywhere in the diff.
- The change does not weaken measurement in any direction; it converts a measurement that collected
  zero files into one that measures 15014 statements, and adds a gate that fails on a shortfall.

---

## 5. `.claude/rules/quality-tiers.md` — PASS

- The enforcement step passes `--min-line 85 --min-branch 75`, which are exactly the uniform
  thresholds stated by the rule. No tier-specific lower threshold is used anywhere in the change.
- The module's argument defaults are `DEFAULT_MIN_LINE = 85.0` and `DEFAULT_MIN_BRANCH = 75.0`
  (`check_python_coverage_thresholds.py` lines 65-66), so an invocation that omits either option
  enforces policy rather than disabling the check. This satisfies the spec requirement at line 218
  that an omitted argument cannot weaken the gate.
- The enforcement step carries no `if:` key, so the floors are enforced on all four Python matrix
  legs (3.10, 3.11, 3.12, 3.13), matching decision D3's reading that the rule states the floors
  unconditionally and not per interpreter version.
- The branch threshold is applied to Python, which is a branch-capable language. The rule's
  PowerShell/bash branch exemption is not engaged, because neither language has a changed file on
  this branch.
- Decision D2's rejection of `--cov-fail-under` is verified as correct on the mechanism: with
  `--cov-branch` active, `coverage/results.py` computes `pc_covered` from the combined
  statements-plus-branches ratio, which is not a metric this repository's policy defines. The live
  terminal `TOTAL` row recorded at `evidence/qa-gates/final-python-test-coverage.md` shows `91%`
  in the `Cover` cell against a true line coverage of 92.65 % and true branch coverage of 85.22 %,
  which demonstrates the divergence concretely. Reading the two named JSON keys is the only form
  that gates the two metrics the policy names.

---

## 6. `.claude/rules/general-code-change.md`

### 6.1 File size limit — PASS

| File | Lines | Limit |
| --- | --- | --- |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | 324 | 500 |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | 188 | 500 |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | 157 | 500 |
| `.github/workflows/_quality-checks.yml` | 96 | (Markdown/YAML config; under limit regardless) |

### 6.2 I/O boundaries — PASS

The module separates pure logic from I/O exactly as `general-code-change.md` requires and as the
spec prescribed at line 192:

- `_evaluate_metric` (lines 78-126) — pure; documented `Side Effects: None. This helper is pure.`
- `find_threshold_breaches` (lines 129-188) — pure; takes a parsed mapping, returns a message list,
  mutates nothing.
- `load_totals` (lines 191-240) — the single filesystem seam, isolated in one function.
- `main` (lines 243-320) — thin: parses arguments, calls `load_totals`, calls
  `find_threshold_breaches`, prints, returns an exit code.

The core comparison is testable without touching the filesystem, which is the stated objective of
the rule's I/O-boundary clause. Six of the nine unit tests exercise the comparison through `main`
against an in-memory report; the pure function is reachable directly.

### 6.3 Error handling and fail-fast — PASS

- Three `raise CoverageReportError` sites cover the four documented failure conditions: unreadable
  file, invalid JSON, non-object root, and absent-or-non-mapping `totals`. Each message names the
  report path, as AC-10 requires.
- Exception handling is narrow: `except OSError` (line 217) and `except json.JSONDecodeError`
  (line 224). There is no bare `except:` and no `except Exception:` anywhere in the module.
- The single `except CoverageReportError` in `main` (line 308) is a domain-specific handler at the
  CLI boundary that converts a typed domain error into an exit code, which is the pattern
  `python.md` line 29 expressly permits at entry points. It re-reports the message rather than
  swallowing it.
- A missing metric returns a failure message rather than being skipped
  (`_evaluate_metric` lines 117-118: `if not isinstance(value, int | float): return absent_message`).
  There is no code path that returns 0 when a metric could not be read. This closes the
  "gate that passes vacuously" risk the spec records at line 313, which is the same class of defect
  the whole work item exists to repair.
- Both metrics are always evaluated before returning, so a double breach reports both messages
  (AC-8), not only the first.

### 6.4 Simplicity, reusability, extensibility, separation of concerns — PASS

- Simplicity: four functions, no class hierarchy, no indirection. `_evaluate_metric` factors the
  shared absent-value rule and inclusive-floor rule so each is expressed exactly once, avoiding the
  copy-paste the rule warns against.
- Extensibility: keyword-only parameters with defaults on the public comparison
  (`*, min_line, min_branch`), matching the rule's "prefer keyword-style parameters with defaults".
- Public API: additive only. No existing function, class, or CLI changed behaviour, so no caller
  update and no breaking-change callout is owed.
- Dependencies: none added. `argparse`, `json`, `sys`, `pathlib`, and `typing` are all standard
  library. The workflow-contract test uses `yaml`, already a project dependency.

### 6.5 Mandatory toolchain loop — PASS

The single-pass transcript is at `evidence/qa-gates/toolchain-single-pass-transcript.md`, with the
four stage artifacts `final-python-format-black.md`, `final-python-lint-ruff.md`,
`final-python-typecheck-pyright.md`, and `final-python-test-coverage.md`. One restart preceded the
recorded pass; its cause is documented at
`evidence/other/batch-budget-clear-before-toolchain-restart.md` and was a gitignored runtime state
file unrelated to this change, not a failure of the change.

Independently re-run in this review worktree at 2026-08-25T22-57:

| Stage | Command | Result |
| --- | --- | --- |
| Format | `poetry run black --check <3 changed py files>` | `3 files would be left unchanged` |
| Lint | `poetry run ruff check <3 changed py files>` | `All checks passed!` |
| Type check | `poetry run pyright <3 changed py files>` | `0 errors, 0 warnings, 0 informations` |
| Unit tests | `poetry run pytest <2 new test files>` | `15 passed in 0.08s` |
| Workflow lint | actionlint (from evidence) | exit 0, 0 findings |

Architecture-boundary, contract/schema, and integration stages have no applicable check for a
change of this shape and no in-repo stage was skipped that would have exercised it.

---

## 7. `.claude/rules/python.md`

| Standard | Verdict | Evidence |
| --- | --- | --- |
| Black formatted | PASS | `black --check`, 3 files unchanged |
| Ruff clean, no new suppression | PASS | `All checks passed!`; no `# noqa` in the diff |
| Pyright clean, fully annotated | PASS | `0 errors, 0 warnings, 0 informations` |
| Pytest, AAA structure, descriptive names | PASS | All nine checker tests carry explicit `# Arrange` / `# Act` / `# Assert` comments |
| PEP 8 naming | PASS | `snake_case` functions, `CONSTANT_CASE` module constants, `PascalCase` exception `CoverageReportError` |
| No `Any` | PASS | No `Any` in either file; `object` is used for untyped JSON values and narrowed with `isinstance` |
| `cast` usage justified | PASS | Two `cast` calls in the module and four in the contract test, each immediately after an `isinstance` narrowing or at the untyped `yaml.safe_load` boundary, which is the "wrap untyped libraries behind small typed adapters" pattern the rule prescribes; `load_workflow_steps` documents this explicitly |
| Absolute imports | PASS | `import scripts.dev_tools.check_python_coverage_thresholds as checker` |
| No broad `except` | PASS | See 6.3 |
| No temp files, no network, no external process in tests | PASS | `mem_fs_path` patches `pathlib.Path` methods against an in-process `dict[str, bytes]`; no `tmp_path`, no `tempfile`, no `subprocess`, no socket |
| Tests mirror code structure | PASS | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` mirrors `scripts/dev_tools/check_python_coverage_thresholds.py` |
| No sleeps, retries, timing hacks | PASS | None present |
| Line >= 85 %, branch >= 75 % | PASS | Section 4 |
| No coverage regression on changed lines | PASS | Section 4.5 |
| Logging via `logging`, not `print` | PARTIAL | See NB-2 |

---

## 8. `.claude/rules/general-unit-test.md`

### 8.1 Core principles — PASS

- **Independence:** no shared mutable state. `mem_fs_path` allocates a fresh counter-keyed root per
  test (`_MEM_TEST_ROOT_COUNTER`), so no two tests can collide. The contract tests are read-only
  against a committed file.
- **Isolation:** one behavior per test across all fifteen.
- **Fast:** 15 tests in 0.08 s.
- **Determinism:** no clock read, no RNG, no wall-clock wait, no `setTimeout`/`sleep` analogue. The
  contract tests read a committed file; the checker tests read an in-memory dict.
- **Readability:** every test carries a one-line docstring stating the scenario and expected
  outcome, and the contract tests additionally carry explicit `Scenario:` / `Expected outcome:`
  prose.

### 8.2 Scenario completeness — PARTIAL (NB-1)

Covered: positive flow (both metrics above floor); both inclusive boundaries (85.0, 75.0); both
individual breaches (84.9, 74.9); the double breach; absent branch data; a missing report file; an
unparseable report. That is a thorough boundary matrix and it covers every scenario the spec's Test
Strategy enumerates.

Not covered: two of the four validation conditions the spec names at line 197 — "report root is not
a JSON object" and "`totals` absent or not a mapping". These correspond to the two uncovered lines
230 and 236 and the two uncovered branches. See NB-1.

### 8.3 Test file location — PASS

Both files live under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`. Neither is
colocated in the production tree. The workflow-contract test's placement is a deliberate,
documented deviation from a literal reading of the mirroring rule (which would suggest
`tests/github/workflows/`), recorded as decision D6 with the in-repo precedent
`tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py`, which asserts on files
under `.github/agents/` from exactly that location using the same `parents[3]` root computation.
Following the single established convention rather than creating a second one is the correct
reading; the decision is explicit rather than accidental, which is what the rule's intent requires.

### 8.4 Determinism infrastructure — PASS

No clock, RNG, timer, or async scheduling is present in either the module or its tests, so the
clock-injection, seeded-RNG, and fake-timer requirements have nothing to bind to. No banned API
appears.

### 8.5 Test categories — PASS

- Unit tests: present for both new surfaces.
- Property-based tests: not required. `quality-tiers.yml` does not classify this dev-tooling module
  at T1 or T2; a build-script/dev-tooling module of this shape is T4 scaffolding under the tier
  definitions in `quality-tiers.md`, for which property-test density is `none`.
- Golden, mutation, contract/schema, integration: not required at this tier and no host-service
  boundary is crossed. The workflow-contract test is nonetheless a contract test in substance,
  binding the committed workflow text to the module's expected invocation, which is a stronger
  position than the tier requires.

---

## 9. `.claude/rules/plan-acceptance-gates.md` (G1–G6) — PASS

`poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md
--workspace-root .`

Result: **`plan validation passed`**, exit 0. Zero Blocking findings.

Five Warnings, every one of which is anticipated and explained in the feature documents:

| Task | Rule | Warning | Disposition |
| --- | --- | --- | --- |
| P0-T6 | G4 | `--cov` value `--cov-branch` supplied space-separated | Anticipated verbatim by spec D1: the gate's `cov_values` reads the token after a bare `--cov`, but `argparse` does not. Warning, not Blocking. Correct-as-authored. |
| P0-T7 | G3 | `src/lexile_corpus_tuner` resolves to neither a tracked file nor a tracked directory | This is the defect being reproduced. P0-T7 is the deliberate defect-reproduction task, so a G3 Warning on it is the gate correctly identifying the bug the plan exists to fix. Also confirms the spec's correction at line 28 that this value is G3-Warning, not Blocking as the issue originally claimed. |
| P0-T8, P4-T4, P4-T5 | G4 | same as P0-T6 | Same disposition. |

No G1, G2, G5, or G6 finding. The plan states no unfalsifiable acceptance condition: every gate in
the plan is phrased so it can fail, and the plan documents at P6-T2 the specific reasoning for why
a committed-diff gate would otherwise have passed vacuously before the first commit — which is the
exact failure mode `plan-acceptance-gates.md` exists to prevent.

---

## 10. Tonality — PASS

The spec, the plan, and the evidence artifacts use neutral, literal, evidence-first language. No
hyperbole, no humor, no decorative metaphor. Strength of wording matches strength of evidence
throughout: the spec explicitly corrects two claims from the original issue report (the "dotted
module path required" claim and the "Blocking classification" claim) and labels each correction as
such rather than quietly restating. Uncertainty is stated as uncertainty — for example, the
Codecov `file`/`files` change is described as "a correctness fix rather than a repair of an
observed failure", and the version-parity caveat on the baseline measurement is recorded rather
than dismissed.

---

## 11. Working-Tree State

`git status --porcelain --untracked-files=all` in the review worktree: **empty**. The tree is clean.

Observation, recorded for completeness: the first `git status` run in this review reported
` M coverage.xml`. `git diff -- coverage.xml` returned empty, and a subsequent `git status`
returned clean. This was a stale index stat entry — the repository-root `coverage.xml` had its
mtime touched by the coverage run at 22:54 without its content changing — and it refreshed on the
next index read. The file's content is byte-identical to the committed Pester JaCoCo report
(both begin `<report name="Pester (07/10/2026 22:16:37)">`). No finding.

Related pre-existing hazard, out of scope and not a finding against this change: the
repository-root `coverage.xml` is a **tracked** file holding a committed Pester JaCoCo report, and
`--cov-report=xml` (present both before and after this change) overwrites it in place on any local
run. The plan handles this correctly by requiring `git checkout -- coverage.xml` after each of the
three tasks that pass `--cov-report=xml`, and the restores are recorded with their exit codes. The
underlying hazard — a tracked build-output file at the repository root — predates this branch and
is not widened by it.

---

## 12. Remediation Triggers

| # | Trigger | Severity |
| --- | --- | --- |
| B-1 | `modified-workflow-needs-green-run`: no green `_quality-checks.yml` run whose head SHA equals `890e2ac9` | **Blocking** |

No coverage remediation trigger fired: every measured figure clears its floor with margin, on both
the repo-wide and the new-file tier.

---

## Verdict

**PARTIAL** — one Blocking finding (B-1), which is a sequencing obligation the plan already
schedules at P6-T5 and which requires no change to the code under review. Every other audited
policy is PASS, with two non-blocking observations recorded in
`code-review.2026-08-25T22-57.md` as NB-1 and NB-2.
