# Code Review — Issue #506 (ci-coverage-targets-nonexistent-package)

- **Timestamp:** 2026-08-25T22-57
- **Branch:** `bug/ci-coverage-targets-nonexistent-package-506-r3` @ `890e2ac9`
- **Base:** `origin/main`
- **Work Mode:** `full-bug`
- **Reviewed diff:** `git diff origin/main...HEAD` — four production/test files plus the feature folder

---

## Summary

The change is well-scoped, correctly diagnosed, and cleanly implemented. It replaces a coverage
target that matched nothing with the bare `--cov` form so the `pyproject.toml`-configured source
list governs, adds branch measurement and a JSON reporter, and introduces a small, pure,
well-tested module that fails the build when either policy floor is breached. The root-cause
analysis in `spec.md` is unusually precise: it traces the fault through `pytest_cov/plugin.py`,
`pytest_cov/engine.py`, and `coverage/config.py::from_args` to the specific line where an explicit
`--cov=VALUE` overwrites the configured source list, and it corrects two incorrect claims from the
original issue report rather than inheriting them.

The design decision that carries the most weight is D2 — rejecting `--cov-fail-under` in favour of
a separate module. That rejection is correct on the mechanism and is not merely a stylistic
preference. With `--cov-branch` active, `pytest_cov` compares `total.pc_covered`, which
`coverage/results.py` computes as the combined statements-plus-branches ratio. That combined value
is not a metric any policy in this repository defines; it is weaker than the line floor and gates
nothing at all on branches. The live evidence makes the divergence concrete: the terminal `Cover`
cell reads `91%` while true line coverage is 92.65 % and true branch coverage is 85.22 %. Using
`--cov-fail-under 85` would have produced a gate that looks correct and enforces a number nobody
specified. Reading `totals.percent_statements_covered` and `totals.percent_branches_covered` is the
only form that gates the two metrics the policy actually names.

Two non-blocking observations are recorded below. Neither affects correctness, neither breaches a
threshold, and neither needs to be fixed before merge.

**Blocking findings in this review: 0.** The single Blocking finding on this branch is the
green-run obligation recorded in `policy-audit.2026-08-25T22-57.md` section 3, which is a
sequencing obligation rather than a code defect.

---

## What Is Done Well

### 1. The remedy removes a drift surface instead of adding one

The obvious fix — replacing `src/lexile_corpus_tuner` with `scripts/dev_tools` — would have worked
but would have created two places that must agree about the coverage scope: the workflow command
and `[tool.coverage.run] source` in `pyproject.toml`. D1 instead supplies no value at all, so the
configuration is the single source of truth. The verified mechanism is that
`coverage/config.py::from_args` assigns each keyword whose value is not `None`, and
`_prepare_cov_source` returns `None` for the bare form, so the configured list survives. This also
makes the CI command byte-compatible with the local command prescribed by `.claude/rules/python.md`
and `.claude/skills/python-qa-gate/SKILL.md`, so a local-versus-CI coverage comparison measures an
identical denominator and is therefore meaningful.

### 2. The pure/impure split is real, not decorative

`find_threshold_breaches` takes a parsed mapping and returns a list of strings. It touches no file,
reads no argument, and mutates nothing. `load_totals` is the only function in the module that
touches the filesystem. `main` is a thin composition of the two plus argument parsing. This is
exactly what `.claude/rules/general-code-change.md` asks for under "Separation of concerns" and
"I/O Boundaries", and it is what makes the nine unit tests possible without a temporary file.

`_evaluate_metric` is a good factoring choice: the absent-value rule and the inclusive-floor rule
are each expressed once rather than duplicated per metric, which is the difference between two
metrics that provably behave the same way and two metrics that happen to today.

### 3. The gate cannot pass vacuously

This is the property that matters most, because the defect being fixed *is* a gate that could not
fail. Three separate design choices close that class of failure:

- A missing or non-numeric metric returns a failure message rather than being skipped
  (`_evaluate_metric` lines 117-118). There is no code path through `main` that returns 0 with a
  metric unread.
- The absent-branch case has its own explicit message —
  `"branch data was not collected: ... which is the shape produced when the branch measurement flag
  was omitted."` — and its own test, so a future edit that drops `--cov-branch` produces a hard
  failure rather than a silently disabled branch gate.
- The floors default to the policy values (85.0 / 75.0) rather than to 0, so an invocation that
  omits an option enforces policy rather than disabling a check.

The end-to-end demonstration at `evidence/qa-gates/coverage-threshold-enforcement.md` supplies the
remaining leg: the gate returns 0 against a real, freshly-measured report, so it is shown to
discriminate rather than merely to return zero.

### 4. The workflow-contract test binds the fix in place

Six structural assertions read the committed workflow through `yaml.safe_load` and `shlex.split`
rather than by substring matching, so they assert on the parsed document rather than on its text.
`test_workflow_names_no_foreign_coverage_target` is the direct regression guard for the reported
defect. `test_pytest_step_uses_bare_cov_with_branch` asserts the *absence* of any `--cov=`-prefixed
token, which is the correct negative form: it forbids the whole class of explicit targets, not just
the one foreign name.

The three lookup helpers (`step_named`, `step_running`, `step_using`) each assert `len(matches) == 1`
before returning. That is a small detail with real value: a helper that silently returned the first
of several matches, or that returned `None` for zero matches, would let an assertion pass against
the wrong step or fail with an unhelpful `AttributeError`. Here a duplicated or renamed step fails
with a message that names the count.

### 5. Documentation quality

The module docstring records not just what the module does but why two specific choices were made —
why `pathlib.Path.read_text` is used instead of the builtin `open` (because the in-memory test
fixture patches `Path` methods, not `open`), and why a missing metric is a failure. Each function
docstring carries `Purpose`, `Args`, `Returns`, `Raises`, and `Side Effects`, with the pure
functions stating `Side Effects: None. This function is pure.` explicitly. A later maintainer who
reaches for `open()` or who adds an early return will find the reason not to, in the file.

### 6. Boundary coverage in tests

The boundary matrix is complete on the dimensions that matter: exactly-at-floor for both metrics
(the inclusive case, which is the one most often gotten wrong), just-below-floor for both metrics,
and the simultaneous double breach asserted to report *both* messages rather than only the first.
The double-breach test is the one that would catch an early `return` inserted into
`find_threshold_breaches` during a later edit.

---

## Non-Blocking Findings

### NB-1 — Two documented validation conditions carry no unit test (Minor)

**Location:** `scripts/dev_tools/check_python_coverage_thresholds.py` lines 229-238; missing
coverage at lines 230 and 236, missing branches `229→230` and `235→236`.

**Observation.** `spec.md` line 197 enumerates the module's validation conditions as: "report file
missing or unreadable; report not valid JSON; `totals` absent or not a mapping; ...". Two of the
four raise sites are exercised by tests
(`test_missing_report_file_exits_non_zero`, `test_unparseable_report_exits_non_zero`) and two are
not:

```python
    if not isinstance(document, dict):
        raise CoverageReportError(
            f"Coverage report root is not a JSON object: {report_path}"   # line 230 — uncovered
        )

    totals = cast("dict[str, object]", document).get("totals")
    if not isinstance(totals, dict):
        raise CoverageReportError(
            f"Coverage report carries no `totals` mapping: {report_path}"  # line 236 — uncovered
        )
```

`general-unit-test.md` lists "Error-handling behavior" under Scenario Completeness, and the two
uncovered paths are error-handling behavior that the spec named explicitly.

**Why it is not Blocking.** The module's measured coverage is 96.72 % line and 85.71 % branch,
both well clear of the 85 / 75 floors, so no threshold is breached and no remediation trigger
fires. No acceptance criterion names either condition: AC-10 covers only the missing and
unparseable cases, and both of those are tested. The uncovered code is a `raise` on a
straight-line guard with no logic to get wrong, and each message is a single f-string that names
the report path in the same form as the two tested messages.

**Suggested improvement, for a future change rather than for this one.** Two tests of the same
shape as the existing pair would close it:

- a report whose content is a valid JSON array or scalar (`"[]"`), asserting a non-zero exit and
  that the path appears in stderr;
- a report whose root is an object but whose `totals` is absent or is not a mapping
  (`{"totals": 5}`), asserting the same.

Both fit the existing `_write_report` / `mem_fs_path` pattern and add roughly twenty lines.

### NB-2 — CLI writes to stderr via `print` rather than `logging` (Informational)

**Location:** `scripts/dev_tools/check_python_coverage_thresholds.py` lines 309 and 318.

**Observation.** `.claude/rules/python.md` line 31 states "Use the standard `logging` module. No
ad-hoc `print` statements for permanent behavior." The module uses
`print(message, file=sys.stderr)`.

**Why it is not Blocking, and why no change is recommended.**

1. The rule's target is permanent library behavior. This is a CLI entry point whose entire output
   contract is "human-readable breach or error messages on standard error", stated as such in
   `spec.md` line 214 and decided explicitly at line 203: "there is no logging framework in this
   module's dependency set and none is introduced."
2. The convention is repository-wide, not an outlier. Twenty-three modules under
   `scripts/dev_tools/` write to `sys.stderr` via `print`, including the sibling gate the same
   workflow already invokes at line 71 (`generate_codex_agent_variants`). Introducing `logging` in
   this one module would create a second convention rather than follow the established one, which
   `general-code-change.md` discourages under "Reusability".
3. In a GitHub Actions `run:` block, an unconfigured `logging` call would emit through the root
   handler with a default `WARNING` threshold and a different line format, which is a worse CI
   output contract than a plain stderr line, not a better one.

**Disposition.** No action. Recorded so a future reader does not re-raise it, and so the deviation
from the literal rule text is on the record with its reasoning rather than unexplained.

---

## Additional Verification Performed

These checks were run against the current branch head to confirm claims in the evidence rather than
accept them:

| Check | Command | Result |
| --- | --- | --- |
| New tests pass | `poetry run pytest <2 new test files>` | 15 passed in 0.08 s |
| Format | `poetry run black --check <3 changed py files>` | 3 files unchanged |
| Lint | `poetry run ruff check <3 changed py files>` | All checks passed |
| Type check | `poetry run pyright <3 changed py files>` | 0 errors, 0 warnings, 0 informations |
| Plan gates | `validate_orchestration_artifacts plan ... --workspace-root .` | passed; 5 Warnings, 0 Blocking |
| Evidence locations | `validate_evidence_locations.py --root .` | exit 0, no output |
| Write-set exclusions | `git diff --name-only origin/main...HEAD -- pyproject.toml .github/instructions/ extensions/.../.github/instructions/` | empty |
| Working tree | `git status --porcelain --untracked-files=all` | empty |

Three mechanism claims were verified against installed library source rather than taken from the
spec:

1. **JSON report directory creation.** `coverage/report_core.py::render_report` calls
   `ensure_dir_for_file(output_path)` before opening the output file (confirmed against the
   installed `coverage` 7.13.2). `artifacts/python/` therefore does not need to pre-exist on a
   fresh runner checkout, so the enforcement step cannot fail on a missing directory. Neither the
   spec nor the plan asserts this; it was checked because a missing-directory failure would have
   been a real defect visible only in CI.
2. **`--cov --cov-branch` does not mis-bind.** `pytest_cov` declares `--cov` with `nargs='?'`, and
   `argparse` does not consume a following token beginning with `-` as an optional's value. The
   live run measuring 15014 statements confirms this empirically. The G4 plan-gate Warning on this
   command form is a limitation of the gate's tokenizer, not a defect in the command — which is
   what `spec.md` D1 predicted.
3. **Module invocation path.** `scripts/__init__.py` and `scripts/dev_tools/__init__.py` both exist,
   so `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds` resolves under
   `poetry install --no-interaction`, matching the existing precedent at workflow line 71.

---

## Best-Practice Assessment by Dimension

| Dimension | Assessment |
| --- | --- |
| **Correctness** | The fix addresses the actual root cause, verified from library source rather than inferred. The secondary Codecov `file`→`files` correction is in the same step group and one token wide, so bundling it is proportionate rather than scope creep. |
| **Simplicity** | Four functions, no classes beyond one exception type, no indirection, no configuration file. The simplest design that meets the requirement. |
| **Reusability** | `_evaluate_metric` factors the shared rule; `find_threshold_breaches` is importable and pure, so a future caller (for example a different language's gate wrapper) can reuse the comparison without the CLI. |
| **Extensibility** | Keyword-only parameters with defaults on the public comparison. A third metric would be one more `_evaluate_metric` call and one more constant. |
| **Separation of concerns** | Pure comparison, single I/O seam, thin CLI. Clean. |
| **Error handling** | Fail-fast throughout; narrow exception types; every message names the report path; no path returns success on an unread metric. |
| **Naming** | Descriptive and unambiguous. Module constants named for the JSON keys they hold (`LINE_PERCENT_KEY`, `BRANCH_PERCENT_KEY`), which makes the key/metric mapping explicit at the point of use. |
| **Testing** | Fifteen tests, AAA-structured, deterministic, in-memory, one behavior each. Complete boundary matrix. One gap at NB-1. |
| **Documentation** | Above the repository norm. Records rationale for non-obvious choices, not just behavior. |
| **Dependencies** | None added. |
| **Public API compatibility** | Purely additive; no existing caller affected. `QCRunner.FULL_TEST` deliberately untouched, so `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` remains valid and was not modified. |
| **Scope discipline** | Nine further occurrences of the foreign package name were catalogued, assessed as degraded-but-functional (they pair the foreign target with a valid one, emitting a `CoverageWarning` while still measuring the correct scope), and deferred with a documented follow-up recommendation rather than folded in. This is the correct call under `general-code-change.instructions.md`. |

---

## Recommendations

1. **Before merge (Blocking, tracked in the policy audit as B-1):** dispatch `_quality-checks.yml`
   against the current branch head `890e2ac9` and record the green run. See
   `policy-audit.2026-08-25T22-57.md` section 3 for the exact sequence. No code change is required.
2. **Optional, this change or a follow-up:** close NB-1 with two additional tests for the
   non-object-root and non-mapping-`totals` guards.
3. **Follow-up issue, already recommended in `spec.md` Rollout & Follow-up:** the nine remaining
   live occurrences of the foreign package name, and the four blocked policy files pending the D5
   human-interaction decision. Both are correctly deferred; neither should be folded into this
   change.
4. **Follow-up, worth filing separately:** the repository-root `coverage.xml` is a tracked file
   holding a committed Pester JaCoCo report that any local `--cov-report=xml` run overwrites in
   place. This predates the branch and is not widened by it, but it required three explicit
   restore steps in this plan and will require them in every future plan that runs pytest with the
   XML reporter. Gitignoring it, or directing the pytest XML reporter elsewhere via
   `[tool.coverage.xml] output`, would remove a recurring hazard.

---

## Verdict

**APPROVE with 0 Blocking code findings.** Two non-blocking observations (NB-1 Minor, NB-2
Informational). The change is ready to merge once the green-run obligation recorded in the policy
audit is satisfied.
