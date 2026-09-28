# Code Review (Reaudit) — Issue #506 (ci-coverage-targets-nonexistent-package)

- **Timestamp:** 2026-08-25T23-20
- **Cycle:** exit reaudit of remediation cycle 1. The entry record is `code-review.2026-08-25T22-57.md`, which is not superseded and not overwritten.
- **Branch:** `bug/ci-coverage-targets-nonexistent-package-506-r3`
- **Branch head at reaudit:** `e825b5e62f7b816859eee8fae2c7e23ddb40679b`
- **Base:** `origin/main` at `8ca66c1d`; merge base equals `origin/main`
- **Work Mode:** `full-bug`

---

## Summary

**No production code, test code, or workflow file changed during remediation cycle 1.** `git diff --name-only 890e2ac9 HEAD` — where `890e2ac9` is the head the entry code review examined — returns five paths, all Markdown documents under the feature folder:

```
docs/features/active/.../code-review.2026-08-25T22-57.md
docs/features/active/.../evidence/qa-gates/post-merge-toolchain-verification.md
docs/features/active/.../feature-audit.2026-08-25T22-57.md
docs/features/active/.../policy-audit.2026-08-25T22-57.md
docs/features/active/.../remediation-inputs.2026-08-25T22-57.md
```

The remediation was a sequencing obligation — push, dispatch, poll, record — plus documentation check-offs. The entry audit predicted this ("It requires no change to source code, tests, or the workflow file") and the prediction held exactly.

This review therefore re-examines the same four files against the same standards rather than reviewing a delta, so that the exit verdict rests on fresh reading rather than on a reference to the entry record. It also reviews the two artifacts the remediation authored, since those are new work product even though they are not code.

### Change set under review

| Path | Status | Lines | Language |
| --- | --- | --- | --- |
| `.github/workflows/_quality-checks.yml` | modified (+18, −2 in the change hunks) | 96 | GitHub Actions YAML |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | new | 324 | Python |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | new | 188 | Python |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | new | 157 | Python |

### Verdict at a glance

| Dimension | Verdict |
| --- | --- |
| Blocking findings | **0** |
| Non-blocking findings | 4 (2 carried, 2 new this cycle, all Informational or Minor) |
| Toolchain | Black, Ruff, Pyright, Pytest clean at this head; all four CI matrix legs green |
| Recommendation | **Merge-ready** |

---

## 1. What Is Done Well

### 1.1 The remedy removes a drift surface rather than adding one

The defective value was `--cov=src/lexile_corpus_tuner`: a foreign package name in filesystem-path form. Two independent defects in one token. The obvious repair is to substitute the correct dotted name, for example `--cov=scripts.dev_tools`. The change does something better — it drops the target entirely and uses bare `--cov`:

```yaml
poetry run pytest --cov --cov-branch \
  --cov-report=xml \
  --cov-report=json:artifacts/python/coverage.json \
  --cov-report=term-missing
```

Bare `--cov` measures whatever `pyproject.toml` configures as the source. That is the correct design choice, and the reasoning is worth stating: a hard-coded package list in a workflow is a second place where the measured scope is declared, and a second place drifts. This defect *is* a drift instance — a copied workflow retained a package name from the project it was copied from, and nothing detected it for the lifetime of the file. Naming the scope once, in the project manifest, removes the surface on which the same failure can recur.

The choice also keeps `pyproject.toml` out of the diff, which is what makes AC-14 satisfiable as stated.

### 1.2 The pure/impure split is real, not decorative

`.claude/rules/general-code-change.md` requires pure logic to be separable from I/O. Many modules claim this and then read a file inside the function that computes. This one does not:

| Function | Role | I/O |
| --- | --- | --- |
| `_evaluate_metric` | compares one metric against one floor | none |
| `find_threshold_breaches` | applies both comparisons, returns the message list | none |
| `load_totals` | reads and parses the report | the module's only filesystem interaction |
| `main` | argument parsing, orchestration, stderr, exit code | delegates |

The consequence is visible in the tests: `find_threshold_breaches` can be exercised with a plain dict, and it is. The split is load-bearing, not documentation.

`_evaluate_metric` deserves specific credit. Both metrics obey the same two rules — a missing value is a failure, and the floor is inclusive. Expressing those rules once, parameterised by key, floor, message, and label, means the two metrics cannot diverge. A copy-paste implementation would eventually acquire a `<=` on one branch and a `<` on the other.

### 1.3 The gate cannot pass vacuously

This is the property that matters most, because the bug being fixed *is* a gate that passed vacuously for the lifetime of the workflow. Four design decisions close that class of failure, and each was verified by reading the code, not inferred:

1. **A missing metric is a failure.** `_evaluate_metric` line 117: `if not isinstance(value, int | float): return absent_message`. A report produced without `--cov-branch` carries no `percent_branches_covered` key. Under a naive `totals.get(key, 100)` that would pass silently; here it fails with a message that names the likely cause ("the shape produced when the branch measurement flag was omitted").

2. **The floors default to the policy values.** `DEFAULT_MIN_LINE = 85.0` and `DEFAULT_MIN_BRANCH = 75.0` are the argparse defaults, so an invocation that omits either option enforces policy rather than disabling that check. The failure mode where someone drops an argument and silently turns off a gate is not reachable.

3. **Both metrics are always evaluated.** `find_threshold_breaches` builds a list rather than returning on the first breach, so a report failing both floors reports both. A short-circuit would hide the second problem until the first was fixed.

4. **No broad exception handler exists anywhere in `main`.** The comment at lines 302-305 states the invariant directly: "an unread metric can never produce a success exit code." The only handler is `except CoverageReportError`, which returns 1. There is no `except Exception` that could convert an unexpected failure into a pass.

Together these mean the new gate does not reproduce, in a different form, the defect it was written to fix. That is the central design question for this change and it is answered correctly.

### 1.4 The workflow-contract test binds the fix in place

`tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` parses the workflow with `yaml.safe_load` and asserts structural properties: that the foreign token is absent, that the pytest step carries `--cov-branch` and no `--cov=` token, that the JSON report path is emitted, that the enforcement step invokes the checker with both floors, that the enforcement step carries no `if` key, and that the Codecov step uses `files` rather than `file`.

Two things are right about this. First, structural parsing rather than substring matching over raw YAML — the assertions are about the parsed document, so reformatting the file does not produce a false failure and a commented-out line does not produce a false pass. Second, `evidence/regression-testing/workflow-contract-tests-fail-before.md` records these tests failing against the pre-fix workflow. A test that was never observed to fail is not evidence that it can. This one was.

The regression this prevents is concrete: the defect is exactly the kind that a future copy-paste reintroduces. `test_workflow_names_no_foreign_coverage_target` makes reintroduction a test failure rather than a silent regression that nobody notices for another year.

### 1.5 The Codecov `file` → `files` correction

`codecov/codecov-action@v7` declares `files`, not `file`. The old key was silently ignored, so the action fell back to auto-discovery. With `fail_ci_if_error: false` alongside it, an upload failure would also have been silent. This is a second latent defect in the same neighbourhood, found and fixed while the file was open, and covered by `test_codecov_step_uses_the_declared_files_input`. Fixing it here is proportionate — it is two characters in a line already being edited, in the same failure family as the primary bug.

### 1.6 Documentation quality

Every public symbol carries a docstring with Purpose, Args, Returns, Raises, and Side Effects. The module docstring goes further and records *why* `pathlib.Path.read_text` is used instead of the builtin `open` (lines 38-43): the repository forbids temporary files in unit tests, and the in-memory filesystem fixture patches `Path` methods rather than `open`. That is a non-obvious constraint whose violation would surface as a confusing test failure much later. Writing down the reason, not just the rule, is the right call.

Inline comments are used sparingly and each one explains a decision rather than restating the code — lines 114-116 (why a missing key is a failure), line 122 (why the comparison is inclusive), lines 302-305 (why there is no broad handler).

### 1.7 Boundary coverage in tests

`test_line_coverage_at_floor_is_accepted` supplies exactly 85.0 and `test_branch_coverage_at_floor_is_accepted` supplies exactly 75.0. The breach tests supply 84.9 and 74.9. Testing the boundary from both sides is what makes the inclusive-floor rule an asserted contract rather than an implementation accident; an off-by-one flip from `<` to `<=` is caught.

`test_both_metrics_below_floor_are_both_reported` asserts that both metric names appear in the same run, which is the assertion that pins design decision 3 above.

### 1.8 Test hygiene

Both test files use the in-memory `mem_fs_path` fixture. No test creates a temporary file on disk, which `.claude/rules/general-unit-test.md` prohibits outright. Every test drives the module through `main` and asserts on the exit code the workflow step actually observes, rather than on an internal return value — the assertion is on the observable contract. Arrange-Act-Assert is marked explicitly with comments in each test. Test names state the scenario and the expected outcome. Both files sit under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`, satisfying the test-location rule.

### 1.9 The remediation's own artifacts

Not code, but new work product this cycle, and reviewed on the same terms.

`evidence/qa-gates/green-workflow-run.md` records each command with its timestamp, exit code, and output summary, and consolidates the P6-T3 push record and P6-T4 dispatch record with an explicit note that the plan's carve-out authorises the consolidation. Two details are notably careful:

- It explains why `git rev-parse "@{u}"` is quoted — an unquoted `@{u}` is parsed by PowerShell as the opening of a hash literal and raises a parser error before `git` is invoked. That is a real trap, recorded where the next reader will hit it.
- It explains why the upstream-ref comparison strips only the leading `origin/` prefix rather than taking the last slash-separated segment — this branch name itself contains slashes, so segment-splitting would yield the wrong answer and fail a correct push.

The artifact also records `git status --porcelain --untracked-files=all` returning empty at the moment the conclusion was read. That is the step that turns "the SHAs happen to match" into "the SHAs match and nothing could have changed in between." Recording it was not required and it materially strengthens the evidence.

`evidence/qa-gates/d3-fallback-disposition.md` records `Disposition: SKIPPED` with the condition that was not met, the five consequences of the skip branch, and — unusually — a section explaining why the value is a dedicated `Disposition:` field rather than an `EXIT_CODE: SKIPPED` row. The reasoning is correct and worth preserving: the repository's evidence collector parses `EXIT_CODE:` as an integer, so a non-integer value makes the whole artifact unparseable and the collector drops it rather than degrading it. Writing `EXIT_CODE: SKIPPED` into the green-run artifact would have removed the sole AC-17 evidence from verification entirely. The executor identified a failure mode that would have been invisible until the verification step and designed around it.

---

## 2. Non-Blocking Findings

None is required for merge. Two are carried from the entry review and were deliberately not remediated; two are new this cycle.

### NB-1 — Two documented validation conditions carry no unit test (Minor, carried)

- **Location:** `scripts/dev_tools/check_python_coverage_thresholds.py` lines 229-238.
- **Detail:** the `load_totals` docstring (lines 204-208) names four raise conditions. Two are tested:

  | Condition | Test |
  | --- | --- |
  | file missing or unreadable | `test_missing_report_file_exits_non_zero` |
  | content is not valid JSON | `test_unparseable_report_exits_non_zero` |
  | root is not a JSON object | **none** |
  | `totals` absent or not a mapping | **none** |

  Coverage confirms it: lines 230 and 236 are uncovered, and branches `229→230` and `235→236` are uncovered. Those are the only four uncovered items in the module.

- **Why non-blocking, re-verified this cycle by recomputing from `artifacts/python/lcov.info`:** module line coverage is 96.7213 % (59/61) against an 85 % floor; module branch coverage is 85.7143 % (12/14) against a 75 % floor. Both clear comfortably. No acceptance criterion names either condition — AC-10 states "a missing or unparseable report fails loudly" and names exactly the two tests that exist. No remediation trigger fires.

- **The guards are correct and should stay.** `evidence/qa-gates/checker-module-coverage.md` lines 47-52 records the decision: the behavioural contract requires `load_totals` to raise `CoverageReportError` on both conditions, so deleting the guards to raise the percentage would be the wrong fix. The finding is about the missing test, never about the code.

- **Suggested action (optional, this change or a follow-up):** two tests in the existing `_write_report` / `mem_fs_path` pattern — one writing a JSON array or scalar as the document root, one writing `{"totals": 5}` — each asserting a non-zero exit and the report path in stderr. Roughly twenty lines; would take the module to 100 % line and 100 % branch.

### NB-2 — CLI writes to stderr via `print` rather than `logging` (Informational, carried; no action recommended)

- **Location:** lines 309 and 318.
- **Detail:** `.claude/rules/python.md` line 31 prefers the standard `logging` module over ad-hoc `print` for permanent behavior.
- **Why no action:** the rule targets permanent library behavior. These are the two output calls in `main`, the CLI entry point, whose output contract `spec.md` lines 203 and 214 state as "human-readable messages on standard error." Twenty-three modules under `scripts/dev_tools/` already use this form, including the sibling gate the same workflow invokes. An unconfigured `logging` call inside a GitHub Actions `run:` block emits through the root handler at a `WARNING` default with a different format — a worse CI output contract, not a better one. Changing it would degrade output to satisfy the letter of a rule aimed at a different situation.
- Recorded so the deviation stands on the record with its reasoning, rather than being re-raised in a later cycle as though newly discovered.

### NB-3 — Stale present-tense heading in the evidence index (Informational, NEW this cycle)

- **Location:** `evidence/other/ac-evidence-index.md` line 24.
- **Detail:** the heading reads `## Why exactly four rows are marked \`PENDING PHASE 6\`` in the present tense, and its body says "All four are finalized by [P6-T7], which replaces the four rows below." After P6-T7 executed, zero rows carry that marker — which the same document states forty lines later ("Rows marked `PENDING PHASE 6`: **0**"). A reader arriving at line 24 meets a present-tense claim the table no longer supports.
- **Why non-blocking:** the section is a rationale record for the [P5-T1] state and reads correctly as history. The document is internally consistent on substance: the table is finalized, the count line says 0, and the appended P6-T7 block states the finalization with its date and its seven-condition acceptance table. No acceptance criterion, policy rule, or gate depends on the heading's tense. P6-T7 condition (c) requires nineteen rows and zero pending rows; both hold.
- **Suggested action (optional):** reword to past tense if the document is touched again. Not worth a commit on its own.

### NB-4 — AC-12's index row cites the disposition artifact rather than the test-result artifact (Informational, NEW this cycle)

- **Location:** `evidence/other/ac-evidence-index.md`, the AC-12 row.
- **Detail:** the row's test column correctly names `test_threshold_step_runs_on_every_matrix_leg`; its artifact column names `FEATURE/evidence/qa-gates/d3-fallback-disposition.md`. That artifact establishes *which form* of AC-12 landed. The artifact recording the test *passing* is `FEATURE/evidence/regression-testing/workflow-contract-tests-pass-after.md`, which lists the test at line 40 as item 5 of its passing set. The other twelve test-carried rows point at the test-result artifact.
- **Why non-blocking:** the plan's P6-T7 instruction for AC-12 was to supply "the landed test node ID," and it prescribed an artifact path only for AC-14, AC-15, and AC-17. The executor met the instruction as written, and the choice is defensible — the landed form is precisely the fact P6-T7 existed to determine. The test result is not lost: it is one hop away in an artifact the same index cites for five sibling rows, and it was independently re-confirmed in this review by running the two test files (15 passed) and by all four green CI legs. The cost is one indirection, not a gap.
- **Suggested action (optional):** cite both artifacts in the AC-12 row, as the AC-14 and AC-15 rows already do.

---

## 3. Verification Performed in This Review

Every check below was executed by the reviewer at head `e825b5e6`. None is quoted from an evidence document.

| # | Check | Command / method | Result |
| --- | --- | --- | --- |
| 1 | Branch head identity | `git rev-parse HEAD` | `e825b5e62f7b816859eee8fae2c7e23ddb40679b` |
| 2 | Remote ref agreement | `git rev-parse origin/bug/...-r3` | identical to (1) |
| 3 | Base resolution | `git merge-base HEAD origin/main` vs `git rev-parse origin/main` | both `8ca66c1d`; branch up to date with `main` |
| 4 | Full branch diff | `git diff --name-status origin/main...HEAD` | 48 files: 1 YAML, 3 Python, 44 Markdown |
| 5 | Delta since entry review | `git diff --name-only 890e2ac9 HEAD` | 5 Markdown files only; **no code, test, or workflow change** |
| 6 | Format | `poetry run black --check` on the three changed Python files | exit 0, `3 files would be left unchanged` |
| 7 | Lint | `poetry run ruff check` on the three changed Python files | exit 0, `All checks passed!` |
| 8 | Feature tests | `poetry run pytest <both test files> -q` | exit 0, `15 passed in 0.08s` |
| 9 | Workflow diff read | `git diff origin/main...HEAD -- .github/workflows/_quality-checks.yml` | read in full; three hunks as described in section 1 |
| 10 | Repo-wide coverage | direct parse of `artifacts/python/lcov.info`, summing LF/LH and BRF/BRH over 181 files | 92.6469 % line (13910/15014), 85.2161 % branch (4692/5506) |
| 11 | New-file coverage | same parse, per-file | `check_python_coverage_thresholds.py` 96.7213 % line (59/61), 85.7143 % branch (12/14) |
| 12 | Alternative-form test absence | `grep -rn "test_threshold_step_is_narrowed_to_the_pinned_leg" --include=*.py .` | no match anywhere in the repository |
| 13 | Landed-form test presence | `grep -n` in the contract test file | present once, line 134 |
| 14 | Plan acceptance gates | `validate_orchestration_artifacts.py plan <plan> --workspace-root .` against the **modified** plan | `plan validation passed`, exit 0, five Warnings, zero Blocking |
| 15 | Evidence locations | `validate_evidence_locations.py --root .` | exit 0 |
| 16 | Green run | `gh run list --workflow=_quality-checks.yml --branch <branch> --limit 5 --json ...` | run `32925230528`, `success`, `headSha` == (1) |
| 17 | Per-leg results | `gh run view 32925230528 --json jobs` | 3.10, 3.11, 3.12, 3.13 all `success`; `Enforce Python coverage thresholds` `success` on each |

Check 10 is worth a note: the coverage figures were recomputed from the lcov artifact rather than read out of `evidence/qa-gates/workflow-command-coverage-json.md`. They agree with the JSON-report figures recorded there to every printed digit (92.64686292793392 and 85.2161278605158). Two independent parses of two report formats producing identical values means neither the artifact nor the evidence document is being taken on trust.

Check 12 matters for AC-12's "exactly one of the two tests is present" condition. The search was run repository-wide across all Python files, not only the contract test file, so the absence is established rather than assumed.

---

## 4. Best-Practice Assessment by Dimension

| Dimension | Verdict | Basis |
| --- | --- | --- |
| Simplicity | **Good** | Four functions, one class, no indirection beyond the pure/impure split. No framework, no abstraction layer, no configuration file. |
| Reusability | **Good** | `_evaluate_metric` expresses the shared comparison once; the two metrics cannot diverge. |
| Extensibility | **Good** | Keyword-only parameters with defaults on both public functions; a third metric is a fourth `_evaluate_metric` call. |
| Separation of concerns | **Good** | Pure comparison, I/O, and CLI are three distinct functions; the tests exercise the pure layer directly. |
| Error handling | **Good** | Two narrow `except` clauses (`OSError`, `json.JSONDecodeError`), one narrow domain handler, no broad catch. Every message names the report path. |
| Naming | **Good** | `find_threshold_breaches`, `load_totals`, `CoverageReportError`, `LINE_PERCENT_KEY`. `snake_case` functions, `PascalCase` class, `UPPER_SNAKE` constants. |
| File size | **Good** | 324 / 188 / 157 lines, all well under the 500-line limit. |
| Dependencies | **Good** | Standard library only: `argparse`, `json`, `sys`, `pathlib`, `typing`. No new third-party package. |
| I/O boundaries | **Good** | `load_totals` is the sole filesystem interaction and is the only function that cannot be tested without a filesystem seam. |
| Type annotations | **Good** | Fully annotated; `from __future__ import annotations`; `TYPE_CHECKING`-guarded imports for `Mapping`/`Sequence`/`Path`. Pyright reports 0 errors, 0 warnings. |
| Test independence | **Good** | Each test constructs its own report in the in-memory filesystem; no shared mutable state; order-independent. |
| Test determinism | **Good** | No clock, no RNG, no sleep, no network, no real filesystem. Fixed inputs, fixed outputs. |
| Test isolation | **Good** | One behavior per test; a failure names the faulty rule. |
| Scenario completeness | **Adequate** | Positive, negative, boundary, both-metric, and absent-data paths covered. Two documented validation conditions untested — NB-1. |
| Documentation | **Good** | Full docstrings on every public symbol; comments explain decisions rather than restate code; the `open`-prohibition rationale is recorded. |
| Logging convention | **Adequate** | `print` to stderr rather than `logging` — NB-2, judged correct for this CLI context. |

---

## 5. Observations Considered and Not Raised as Findings

Recorded so a later reviewer does not spend time re-deriving that they are non-issues.

1. **`isinstance(value, int | float)` also accepts `bool`.** `bool` subclasses `int` in Python, so a `totals` value of `True` would be accepted and coerced to `1.0`. This is safe in the failing direction: `1.0 < 85.0`, so the gate fails loudly rather than passing. A `coverage.py` JSON report never emits a boolean for these keys. Adding a `bool` exclusion would be defensible but would guard a path that produces the correct outcome already.

2. **`--min-line` / `--min-branch` accept values above 100 or below 0.** `argparse` applies `type=float` with no range check. A floor of 200 would fail every run; a floor of −5 would pass every run. Both are operator errors in a workflow file that is itself covered by `test_threshold_step_invokes_the_checker_with_both_floors`, which asserts the literal values 85 and 75. The contract test is the correct place for that constraint and it is already there.

3. **`--cov-report=xml` still overwrites the tracked repository-root `coverage.xml`.** This is a real recurring hazard — it required explicit `git checkout -- coverage.xml` restore steps at three points in this plan — but it predates this branch and is not widened by it. It is recorded as follow-up item 5 in the entry remediation inputs and is correctly out of scope here.

4. **The enforcement step runs on all four matrix legs while Codecov upload runs only on 3.13.** The asymmetry is deliberate and correct: coverage *enforcement* should fail on any leg whose coverage regresses, whereas coverage *upload* should publish one report rather than four duplicates. Decision D3 pre-authorised narrowing the enforcement step if a version-specific shortfall appeared; the green run showed no shortfall on any leg, so the step correctly stayed broad. This is now verified empirically rather than assumed — all four legs passed the step.

5. **The uncommitted working tree.** Five Markdown files under the feature folder are pending by the plan's explicit commit-boundary design. This is assessed in full in section 3.3 of `policy-audit.2026-08-25T23-20.md` and judged acceptable. It is not a code-quality matter.

---

## 6. Recommendations

Ordered by value. None blocks merge.

1. **Optional, this change or a follow-up:** add the two `load_totals` validation tests described in NB-1. Roughly twenty lines; takes the module to 100 % line and 100 % branch and closes the only gap between the documented contract and the tested contract.

2. **Optional, cosmetic:** reword the `ac-evidence-index.md` line 24 heading to past tense (NB-3), and cite both artifacts in the AC-12 row (NB-4). Both are documentation-consistency touches; neither justifies a commit on its own.

3. **Follow-up, out of scope:** the repository-root `coverage.xml` hazard (observation 3). Gitignoring the file, or setting `[tool.coverage.xml] output` to an `artifacts/` path, would remove a restore step from every future plan that runs pytest with the XML reporter.

4. **Follow-up, out of scope, already recorded:** the residual foreign-package-name occurrences catalogued in research section 6.1, and the four blocked policy files escalated under D5 at `evidence/other/human-interaction-d5.md`. Both are correctly deferred and both are already in the entry remediation inputs.

5. **Broader observation, not a recommendation for this branch:** this change closes the Python instance of a repository-wide gap. No workflow in this repository enforces a coverage threshold in any other language. The pattern established here — bare `--cov`, a JSON report, and a small pure-comparison gate module — transfers directly to TypeScript, PowerShell, and C#, and doing so would be a reasonable follow-up epic.

---

## 7. Verdict

**PASS. Zero Blocking findings. Merge-ready.**

The four files under review are unchanged since the entry code review and were re-read in full rather than referenced. The design holds up on a second reading: the pure/impure split is real, the gate cannot pass vacuously, the contract tests were observed to fail before the fix, and the remedy removes the drift surface that produced the original defect instead of substituting a corrected value into it.

Remediation cycle 1 introduced no code change, as predicted. The two artifacts it did author are careful work — the green-run record captures the clean-tree check that turns SHA equality into a real assertion, and the disposition record identifies and designs around a collector failure mode that would have been invisible until verification.

Four non-blocking findings stand: NB-1 (Minor, two untested validation conditions, optional twenty-line fix), NB-2 (Informational, no action recommended), and NB-3 and NB-4 (both Informational documentation-consistency nits introduced this cycle). None affects correctness, none affects merge readiness, and each is recorded with enough reasoning that a later cycle need not re-derive it.
