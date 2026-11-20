# Research — CI coverage target names a nonexistent package (Issue #506)

- Timestamp: 2026-08-23T23-45
- Feature: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/`
- Branch: `bug/ci-coverage-targets-nonexistent-package-506`
- Worktree: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a4010bd622c357d4d`
- Author: task-researcher

## 0. Method and evidence-quality statement — READ FIRST

This session was delegated with a **read-only tool set** (Read, Grep, Glob, Write, Edit,
WebFetch). **No command-execution tool was available.** I therefore could not run `pytest`,
`poetry env info --path`, or any other command.

Consequences for the delegation prompt's instructions:

- **Question 2 (run the workflow command verbatim, then a corrected form) could not be
  executed.** It is answered instead from (a) the installed `coverage.py` and `pytest-cov`
  source in `C:\Users\DanMoisan\repos\drm-copilot\.venv\Lib\site-packages\`, read line by
  line, and (b) committed evidence artifacts already in the repository. Both are stronger
  than an assumption but are not a fresh run. **The plan must still include a live
  reproduction task.**
- **The venv-provenance instruction is partly answered.** `.venv` does **not** exist in this
  worktree (`Glob .venv/Lib/site-packages/...` in the worktree returned no files;
  the same glob against `C:\Users\DanMoisan\repos\drm-copilot` returned
  `.venv\Lib\site-packages\coverage\jsonreport.py`). The only virtual environment on this
  machine belongs to the **main checkout**, so any measurement run from this worktree via
  `poetry run` will execute against an editable install pointing at
  `C:\Users\DanMoisan\repos\drm-copilot`, not at this worktree. **The executor must print
  `poetry env info --path` and confirm the active checkout before trusting any number.**
  This is the trap named in the delegation prompt, and it is live here.
- Every claim below is labelled **VERIFIED** (read directly from a file in this repository
  or from installed library source), **DERIVED** (arithmetic from a VERIFIED value), or
  **UNVERIFIED**.

## 1. Current state — what the workflow does

**VERIFIED**, `.github/workflows/_quality-checks.yml`:

- Line 8: job `quality-checks7`, `runs-on: ubuntu-latest`, matrix Python `3.10 3.11 3.12 3.13`.
- Line 74-77, the test step:
  ```
  poetry run pytest --cov=src/lexile_corpus_tuner --cov-report=xml --cov-report=term-missing
  ```
- Line 79-86, the upload step: `codecov/codecov-action@v7` with `file: ./coverage.xml`,
  `flags: unittests`, `name: codecov-umbrella`, `fail_ci_if_error: false`, gated on
  `matrix.python-version == '3.13'`.
- The workflow sets no `defaults.run.shell`. On `ubuntu-latest` the default shell is `bash`,
  **not `pwsh`**. This matters for §8.
- Line 71 already runs a Python module as a workflow gate:
  `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`. This is
  the in-repo precedent for the enforcement step recommended in §5.

**VERIFIED**, `.github/workflows/ci.yml` line 11-12: `ci.yml` calls `_quality-checks.yml`
on push and pull_request to `main` and `development`, plus `workflow_dispatch`.

**VERIFIED**, `Glob src/**` returns exactly one file: `src\hello-typescript.ts`. There is no
`src/lexile_corpus_tuner` directory and no importable `lexile_corpus_tuner` module.

## 2. Root cause — mechanism verified from installed library source

### 2.1 An explicit `--cov=VALUE` **replaces** the configured source list

**VERIFIED**, `pyproject.toml` lines 119-127:

```toml
[tool.coverage.run]
source = ["src", "scripts/dev_tools"]
data_file = "artifacts/.coverage"
omit = ["tests/*", "*/tests/*", "*/__pycache__/*", "*/site-packages/*"]
```

**VERIFIED**, `.venv/Lib/site-packages/pytest_cov/plugin.py` lines 93-103 and 177-184:

```python
group.addoption('--cov', action='append', default=[], metavar='SOURCE',
                nargs='?', const=True, dest='cov_source', ...)

def _prepare_cov_source(cov_source):
    """
     --cov --cov=foobar is equivalent to --cov (cov_source=None)
     --cov=foo --cov=bar is equivalent to cov_source=['foo', 'bar']
    """
    return None if True in cov_source else [path for path in cov_source if path is not True]
```

**VERIFIED**, `.venv/Lib/site-packages/pytest_cov/engine.py` line 259-261: the resolved
`cov_source` is passed as `coverage.Coverage(source=self.cov_source, ...)`.

**VERIFIED**, `.venv/Lib/site-packages/coverage/config.py` lines 288-294:

```python
def from_args(self, **kwargs):
    for k, v in kwargs.items():
        if v is not None:
            ...
            setattr(self, k, v)
```

Therefore:

- **Bare `--cov`** (no `=`) resolves `cov_source` to `None`, `from_args` skips it, and the
  configured `source = ["src", "scripts/dev_tools"]` from `pyproject.toml` applies.
- **`--cov=src/lexile_corpus_tuner`** resolves `cov_source` to
  `["src/lexile_corpus_tuner"]`, which is not `None`, so it **overwrites** the configured
  `source`. The good configuration is discarded and replaced with a target that matches
  nothing. Zero files are measured, so the table has no rows and no `TOTAL` line, and
  `coverage.xml` is written empty.

This is the mechanism. The issue's observed symptom is fully explained by it.

### 2.2 The issue's "two independent faults" framing is **half wrong** — correct this in the spec

The issue (`issue.md` line 65) states: *"the value uses the filesystem-path form rather than
an importable dotted module, which is the form `coverage.py` requires."*

**That is incorrect.** `coverage.py` accepts a `source` entry that is **either** a directory
path **or** an importable module/package name. The repository's own configuration proves it:
`source = ["src", "scripts/dev_tools"]` are both directory paths, and they measure 14,939
statements successfully (§3).

The repository's own plan-gate implementation agrees. **VERIFIED**,
`scripts/dev_tools/plan_gate_coverage.py` lines 232-234:

```python
    # A tracked directory is an accepted coverage target.
    if context.git.is_tracked_directory(truncated):
        return
```

There is **one** fault, not two: **the target does not exist**. The path form is not itself
defective. Restating this correctly matters because it changes the remedy: the fix is not
"convert to dotted form", it is "name a target that exists".

### 2.3 The issue's severity claim about `plan-acceptance-gates.md` is also wrong

The issue (`issue.md` line 61) states that `.claude/rules/plan-acceptance-gates.md`
*"classifies a `--cov=<path>` value of exactly this shape as a Blocking defect."*

**VERIFIED** by tracing `scripts/dev_tools/plan_gate_coverage.py::evaluate_cov_value`
against the literal value `src/lexile_corpus_tuner`:

| Step | Line | Outcome |
| --- | --- | --- |
| G4 (space-separated) | 158 | No — the `=` form is used |
| placeholder guard | 165 | No marker present |
| G1 (`.py` suffix) | 171 | No — value does not end in `.py` |
| separator present | 180 | Yes — contains `/`, so continue |
| G2 (`value + ".py"` tracked) | 224 | No — `src/lexile_corpus_tuner.py` is not tracked |
| tracked directory | 233 | No |
| **G3** | 238 | **Warning** |

The shape classifies as **G3 — Warning**, not Blocking. This is materially relevant: the
repository's own plan gate would **not** have blocked this value. Do not cite a Blocking
classification in the spec; it is not supported by the code.

## 3. Coverage measured under the correct scope — repository **PASSES** both thresholds

This is the most consequential finding, and the answer is favourable.

### 3.1 Committed evidence, not assumption

**VERIFIED**,
`docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-test-coverage.md`
(timestamp 2026-08-23T00-12), command `poetry run pytest --cov --cov-branch --cov-report=term-missing`,
`EXIT_CODE: 0`:

```text
TOTAL                                                               14939   1105   5488    559    91%
```

with `4062 passed, 5 skipped, 0 failed`.

**VERIFIED**,
`docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/policy-audit.2026-08-23T11-12.md`
lines 638-655 records the post-change run and its parsed lcov aggregate:

```text
poetry run pytest --cov --cov-branch -q      # 4112 passed, 5 skipped, exit 0
# REPO LINES:  13841/14946 = 92.61%
# REPO BRANCH:  4677/5490 = 85.19%
```

The `14939` statement count named in the delegation prompt therefore came from the
**bare `--cov` scope**, i.e. `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`.
That answers the prompt's question about which denominator was in play.

### 3.2 Confirming the prior findings from library source

**VERIFIED**, `.venv/Lib/site-packages/coverage/results.py`:

- Line 100: `n_partial_branches = sum(len(v) for k, v in mba.items() if k not in self.missing)`
- Line 101: `n_missing_branches = sum(len(v) for k, v in mba.items())`
- Line 322-324: `n_executed_branches = n_branches - n_missing_branches`
- Line 332-334: `ratio_branches = (n_executed_branches, n_branches)`
- Line 353-355: `pc_branches = _percent(*ratio_branches)`
- Line 379-383: `ratio_covered = (n_executed + n_executed_branches, n_statements + n_branches)`
- Line 343-345: `pc_covered = _percent(*ratio_covered)`

**VERIFIED**, `.venv/Lib/site-packages/coverage/report.py` line 262-263: the `TOTAL` row's
`BrPart` cell is `self.total.n_partial_branches` and its `Cover` cell is
`self.total.pc_covered_str`.

**VERIFIED**, `.venv/Lib/site-packages/coverage/jsonreport.py` line 65:
`"percent_branches_covered": nums.pc_branches`.

Each of the delegation prompt's four claims is therefore **CONFIRMED**:

| Prior claim | Status | Basis |
| --- | --- | --- |
| `BrPart` is `num_partial_branches`, not `missing_branches` | **CONFIRMED** | `report.py:262`, `results.py:100-101` |
| `(Branch - BrPart)/Branch = 89.81%` is a wrong derivation | **CONFIRMED** | `n_partial_branches` is a strict subset of `n_missing_branches`, so the ratio over-reports |
| The `Cover` cell is the combined statements-plus-branches ratio | **CONFIRMED** | `results.py:379-383`, `report.py:263` |
| Branch coverage is readable only from `totals.percent_branches_covered` (JSON) or the lcov `BRF`/`BRH` aggregate | **CONFIRMED** | `jsonreport.py:65`; the terminal reporter never prints `pc_branches` |

### 3.3 An arithmetic proof that 89.81% is wrong, using only the committed `TOTAL` row

**VERIFIED**, `.venv/Lib/site-packages/coverage/results.py` lines 403-418, `display_covered`
rounds to the configured precision (0 here). So a printed `91` requires
`90.5 <= pc_covered < 91.5`.

**DERIVED.** Let `M = n_missing_branches` at baseline. From `Stmts=14939, Miss=1105,
Branch=5488`:

```
pc_covered = 100 * ((14939 - 1105) + (5488 - M)) / (14939 + 5488)
           = 100 * (19322 - M) / 20427
```

Requiring `90.5 <= pc_covered < 91.5` gives **`631 < M <= 836`**, hence

```
branch coverage = 100 * (5488 - M) / 5488  in  [84.77%, 88.50%)
```

**The printed `91` is arithmetically incompatible with a branch coverage of 89.81%.**
Independently, the naive derivation's own "combined" figure of 91.85% would have printed as
`92`, not `91` (`round(91.85, 0) == 92`), so that derivation is self-inconsistent with the
very row it was read from.

The `#502` post-change lcov aggregate gives `M = 5490 - 4677 = 813`, which lies inside the
derived interval `(631, 836]`. Substituting `M = 813` at baseline yields
`(5488 - 813)/5488 = 85.19%`, matching the committed lcov figure to two decimal places.

**Conclusion: the delegation prompt's stated true branch figure of 85.19% is CONFIRMED, and
the 89.81% figure is refuted by two independent arguments.**

### 3.4 Policy verdict

`.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md` require, uniformly
across T1-T4 and for every coverage language whose tooling measures the metric:

- line coverage **>= 85%**
- branch coverage **>= 75%**

| Metric | Measured (committed evidence, 2026-08-23) | Threshold | Margin | Verdict |
| --- | --- | --- | --- | --- |
| Python line | **92.61%** (13841/14946) | >= 85% | +7.61 pp | **PASS** |
| Python branch | **85.19%** (4677/5490) | >= 75% | +10.19 pp | **PASS** |

**The repository PASSES both thresholds when measured correctly.** The fix can therefore
turn the gate on **without** remediation work and **without** a staged posture. The spec
should state this explicitly, and should state the two caveats:

1. The measurement was taken on **Windows / Python 3.13**. CI runs **ubuntu-latest** across
   **four** Python versions. Version-gated and platform-gated branches can shift the figure.
   The margins (7.6 pp and 10.2 pp) make a threshold breach unlikely but not impossible.
2. `.claude/rules/general-unit-test.md` also requires "no regression on changed lines". A
   `--cov-fail-under`-style gate does not enforce that; it remains policy-enforced.

## 4. Coverage-exclusion-policy compliance

**VERIFIED**, `pyproject.toml` lines 122-127. The `omit` list is:

```toml
omit = ["tests/*", "*/tests/*", "*/__pycache__/*", "*/site-packages/*"]
```

Every entry is a non-production path expressly permitted by the "Permitted `exclude`
entries" list in `.claude/rules/general-unit-test.md`. **No prohibited entry is present. No
Blocking finding on this axis.**

**VERIFIED**, `[tool.coverage.report] exclude_lines` (lines 129-140) contains only standard
line-level pragmas (`pragma: no cover`, `def __repr__`, `raise NotImplementedError`,
`if TYPE_CHECKING:`, `@abstractmethod`, bare `...`). None excludes a file. Compliant.

**Two observations, neither Blocking:**

1. **`scripts/__init__.py` is outside the coverage denominator.** `Glob scripts/*.py`
   returns only `scripts\__init__.py`; the configured source list names
   `scripts/dev_tools`, not `scripts`. The file is production (a package marker) but is
   **empty** — a `Grep '^'` returns a single blank line — so it contributes zero statements.
   Its omission is numerically inert. Recording it for completeness only.
2. **`"src"` in the source list is a dead entry.** `src/` contains one TypeScript file and
   no Python. It is inert (coverage only considers `.py` files under a source directory) and
   emits no warning, because `src` exists. Removing it is optional tidying and is **not**
   recommended inside this bug's scope: `src/` may legitimately gain Python later, and
   removing it widens the diff to `pyproject.toml` for no behavioural gain.

**VERIFIED** production Python surface: `scripts/__init__.py` plus 181 files under
`scripts/dev_tools/**`. `Glob extensions/**/*.py` and `Glob .claude/**/*.py` each returned
no files. The configured source list therefore covers the entire production Python surface
except the empty package marker.

## 5. Is the gate actually enforced? **No** — and a correct `--cov` value alone does not fix that

**VERIFIED** by repository-wide `Grep 'fail_under|fail-under|cov-fail-under'`: every match is
in `docs/features/**` prose. **There is no `--cov-fail-under` anywhere in the workflow, and
no `fail_under` key in `[tool.coverage.report]`.**

**VERIFIED** by `Glob {codecov.yml,.codecov.yml,.github/codecov.yml}`: **no Codecov
configuration file exists.** Codecov's default `project` status would apply server-side, but
it is not a required check in this repository's CI DAG (`ci.yml` lists nine jobs, none of
which is a Codecov status).

**VERIFIED** by `Grep '85|threshold|[Cc]overage'` across `.github/workflows/_poshqc.yml` and
by reading `.github/workflows/_shell-coverage.yml` in full: **no workflow in this repository
enforces a coverage threshold in any language.** The Python gap is one instance of a
repository-wide absence. Closing the non-Python instances is **out of scope** for #506.

**Conclusion: fixing only the `--cov` value produces a real number that still cannot fail
the build.** That is a half-fix, exactly as the delegation prompt anticipated.

### 5.1 Critical trap — `--cov-fail-under` does NOT mean line coverage when `--cov-branch` is on

**VERIFIED**, `.venv/Lib/site-packages/pytest_cov/plugin.py` lines 359 and 366-370:

```python
self.cov_total = self.cov_controller.summary(self.cov_report)
...
cov_fail_under = self.options.cov_fail_under
if should_fail_under(self.cov_total, cov_fail_under, cov_precision):
```

**VERIFIED**, `.venv/Lib/site-packages/pytest_cov/engine.py` lines 204-252: `summary()`
returns the value produced by the last file reporter it ran; every path returns either
`self.cov.report(...)` or `self.cov.<fmt>_report(...)`, all of which return
`self.total.pc_covered` — the **combined** ratio.

Therefore:

| Command form | What `--cov-fail-under=85` actually gates |
| --- | --- |
| `--cov` **with** `--cov-branch` | combined statements-plus-branches ratio (**~90.6%** today) — neither policy metric |
| `--cov` **without** `--cov-branch` | `n_branches == 0`, so `ratio_covered == ratio_statements`; the value **is** line coverage exactly |

A naive `--cov-branch --cov-fail-under=85` would gate a metric the policy does not define,
would be **weaker** than the line requirement, and would enforce **nothing** on branches.
This trap must be recorded in the spec.

## 6. Every occurrence in the repository — blast radius

`Grep 'lexile_corpus_tuner'` across the worktree returns **188 files**. The overwhelming
majority are immutable historical records. The full classification:

### 6.1 Live, non-documentation occurrences (the actionable set)

| # | File | Line(s) | Form | Effect today |
| --- | --- | --- | --- | --- |
| 1 | `.github/workflows/_quality-checks.yml` | 76 | `--cov=src/lexile_corpus_tuner` **alone** | **Vacuous.** Overrides the configured source with nothing. This is issue #506. |
| 2 | `scripts/dev_tools/atomic_executor/qc_toolchain.py` | 52 | paired with `--cov=scripts/dev_tools` | Degraded: emits a `CoverageWarning: module-not-imported`, still measures `scripts/dev_tools`. Not vacuous. |
| 3 | `scripts/dev_tools/atomic_executor/qc_runner.py` | 86 | `--cov=src/lexile_corpus_tuner` **alone** (`FULL_TEST`) | **Vacuous** in that code path. |
| 4 | `scripts/dev_tools/atomic_executor/qc_runner.py` | 373 | paired with `--cov=scripts/dev_tools` | Degraded (warning only). |
| 5 | `scripts/dev_tools/atomic_executor/cli_preflight.py` | 128 | paired | Degraded (warning only). |
| 6 | `scripts/dev_tools/atomic_executor/cli_preflight.py` | 378 | prompt text emitted to Copilot | Propagates the defective command to agents. |
| 7 | `scripts/dev_tools/atomic_executor/prompt_builder.py` | 303 | prompt text emitted to Copilot | Propagates the defective command to agents. |
| 8 | `scripts/dev_tools/fix_all_branches_extra.py` | 158 | paired | Degraded (warning only). |
| 9 | `.vscode/tasks.json` | 414 | paired | Degraded (warning only). |
| 10 | `pyproject.toml` | 108 | `[tool.ruff.lint.per-file-ignores] "src/lexile_corpus_tuner/cli.py" = ["B008"]` | Inert; the file does not exist. |
| 11 | `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` | 438 | **asserts** the defective `FULL_TEST` value | Locks item 3 in place. Must change if item 3 changes. |

**Item 3 deserves emphasis: `QCRunner.FULL_TEST` carries the target alone, with no paired
`--cov=scripts/dev_tools`.** It is therefore vacuous in exactly the same way the workflow
is, and item 11 is a test that asserts the vacuous value verbatim.

### 6.2 Copilot-surface documents and their bundled mirrors

| File | Line | Notes |
| --- | --- | --- |
| `.github/instructions/python-unit-test.instructions.md` | 62 | "Approved command" is the defective command. **CLAUDE.md forbids modifying `.github/instructions/**`.** |
| `.github/instructions/python-suppressions.instructions.md` | 389 | An example `from lexile_corpus_tuner...` import. Same prohibition. |
| `.github/agents/python-atomic-executor.agent.md` | 262 | Defective command in the toolchain step. Not covered by the CLAUDE.md prohibition. |
| `.github/prompts/remediate-comments.prompt.md` | 13 | An illustrative scope glob only. Cosmetic. |
| `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md` | 62 | Bundled mirror of the immutable file. |
| `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md` | 389 | Bundled mirror of the immutable file. |
| `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md` | 262 | Bundled mirror. |
| `extensions/drm-copilot/resources/customizations/.github/prompts/remediate-comments.prompt.md` | 13 | Bundled mirror. |

**Policy conflict, must be surfaced.** `CLAUDE.md` states of `.github/instructions/`: *"These
files are the canonical policy source. **Do not modify them.**"* Yet
`.github/instructions/python-unit-test.instructions.md:62` publishes the defective command
as the *approved* Python test command. `.github/instructions/general-code-change.instructions.md`
line 11 instructs: *"If you encounter any conflicting instructions, halt and notify the
user."* **The correct handling is to exclude those two files from this change's write set
and record a `human_interaction` requirement / follow-up issue.** Do not edit them silently.

### 6.3 Immutable historical records — DO NOT EDIT

The remaining ~170 matches are under `docs/features/archive/**`,
`docs/features/completed/**`, and `docs/features/potential/promoted/**`. They are plans,
policy audits, and evidence artifacts recording commands that were actually run at the time.
Rewriting them would falsify the historical record. **They are not in the write set.**

`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/issue.md` and
`.../spec.md` legitimately quote the defective command as the bug report; they are updated
as part of normal feature-document authoring, not as residue cleanup.

### 6.4 The `.claude` runtime already prescribes the correct form

**VERIFIED**, `.claude/rules/python.md` line 16:

```
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
```

**VERIFIED**, `.claude/skills/python-qa-gate/SKILL.md` line 33:

```
4. `poetry run pytest --cov --cov-report=term-missing`
```

`Grep '--cov'` across `.claude/**` returns **no** occurrence of `lexile_corpus_tuner`. The
Claude runtime surface is already clean and already uses the bare `--cov` form. **The
recommended workflow command in §7 aligns the workflow with these two existing
authorities rather than inventing a third form.**

## 7. Recommended approach

### 7.1 Coverage scope — recommended value

**Use the bare `--cov` form and let `[tool.coverage.run] source` remain the single source of
truth.** No `--cov=` value, one or several, is needed.

Recommended replacement for `.github/workflows/_quality-checks.yml` line 74-77:

```yaml
      - name: Run tests with Pytest
        run: |
          poetry run pytest --cov --cov-branch \
            --cov-report=xml \
            --cov-report=json:artifacts/python/coverage.json \
            --cov-report=term-missing
        continue-on-error: false
```

Justification:

- **Single source of truth.** `pyproject.toml` already names the correct scope. Restating it
  on the command line would create a drift surface between two files.
- **Alignment with existing authorities.** It is byte-compatible with the command in
  `.claude/rules/python.md:16`, so local and CI runs measure the identical denominator, and
  the local/CI comparison a reviewer performs is meaningful.
- **`--cov-branch` is required** by `.claude/rules/python.md:16` and is the only way to
  populate the branch metric the policy gates on.
- **`--cov-report=json:...` is supported.** VERIFIED at
  `.venv/Lib/site-packages/pytest_cov/plugin.py:24` (`file_choices` includes `'json'`) and
  line 120 (`":DEST"` suffix accepted), and at `engine.py:217-222`
  (`self.cov.json_report(ignore_errors=True, outfile=output)`).
- `/artifacts` is gitignored (**VERIFIED**, `.gitignore:6`), so the JSON report is not
  committed. `addopts` already writes `artifacts/python/lcov.info` there.
- `--cov-report=xml` with no destination writes `coverage.xml` at the run directory, which
  matches the upload step's `./coverage.xml`.

**Known consequence, record it so the planner is not surprised.** An atomic plan that quotes
this command verbatim will receive a **G4 Warning** from the repository's own plan gate.
**VERIFIED** at `scripts/dev_tools/plan_gate_coverage.py:113-117`: `cov_values` treats a bare
`--cov` word as the space-separated form and takes the *following* word — here
`--cov-branch` — as its value, emitting the G4 message. G4 is a **Warning**, not Blocking
(`.claude/rules/plan-acceptance-gates.md` rule table), so it does not fail plan validation.
The alternative `--cov=scripts/dev_tools --cov=src` avoids the warning but duplicates
configuration; the drift risk is judged the larger cost.

### 7.2 Threshold enforcement — recommended mechanism

**Add a second workflow step that invokes a new, unit-testable Python module reading the
JSON report.** Do not use `--cov-fail-under` with `--cov-branch` (see §5.1).

```yaml
      - name: Enforce Python coverage thresholds
        run: |
          poetry run python -m scripts.dev_tools.check_python_coverage_thresholds \
            --report artifacts/python/coverage.json \
            --min-line 85 --min-branch 75
        continue-on-error: false
```

The module reads `totals.percent_statements_covered` and `totals.percent_branches_covered`
and exits non-zero when either falls below its floor.

**VERIFIED**, `.venv/Lib/site-packages/coverage/jsonreport.py` lines 45-67: the JSON
`totals` object carries **both** figures directly —

```python
"percent_statements_covered": nums.pc_statements,   # line 54  -> true line coverage
"percent_branches_covered":  nums.pc_branches,      # line 65  -> true branch coverage
```

so no derivation and no error-prone column arithmetic is needed. This is the only form that
gates the two metrics the policy actually names.

Justification for a module rather than inline shell:

- **Precedent in this very workflow.** Line 71 already runs
  `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` as a gate.
- **Testability.** `.claude/rules/ci-workflows.md` exists precisely because a workflow
  `run:` block is invisible to local review. A module under `scripts/dev_tools/` is covered
  by the ordinary pytest suite, so the "a deliberate coverage regression must fail the
  check" scenario from `issue.md:74` becomes a **deterministic unit test** instead of an
  un-runnable manual step.
- **Self-consistency.** The module enters the coverage denominator itself and must meet the
  same 85/75 thresholds, which its own tests will supply.

**Threshold-scope decision the spec must make (flagged, not decided here):** run the
enforcement step on all four matrix legs, or only on `3.13` (matching the Codecov gate's
`if:` condition)? All four is stricter and catches version-gated regressions; `3.13`-only
removes the risk of a version-specific breach blocking merges. I recommend **all four**,
given the 7.6 pp and 10.2 pp margins, with a fallback to `3.13`-only if the first green-run
attempt reveals a version-specific shortfall.

### 7.3 Rejected alternatives

- **`--cov=scripts.dev_tools` (dotted).** Rejected. It silently drops `src` from the
  denominator, hard-codes a scope that `pyproject.toml` already owns, and gains nothing —
  §2.2 establishes that the path form was never the fault.
- **`--cov --cov-fail-under=85` without `--cov-branch`.** Rejected as the primary. It does
  gate line coverage exactly (§5.1) with a one-line diff and no new module, but it discards
  branch data entirely, leaving the >= 75% branch requirement unenforced and unmeasured, and
  it contradicts `.claude/rules/python.md:16`. **Retain it as the documented fallback** if
  the spec elects a strictly minimal diff.
- **`--cov-branch --cov-fail-under=85`.** Rejected. §5.1 proves it gates the combined ratio,
  a metric no policy defines, and enforces nothing on branches. Actively misleading.
- **Inline `bash`/`pwsh` threshold arithmetic in the `run:` block.** Rejected. Untestable
  locally, and it is the exact class of defect `.claude/rules/ci-workflows.md` was written
  for.
- **Adding a `codecov.yml` with a project status.** Rejected as out of scope. It moves the
  gate server-side into a check that is not in this repository's CI DAG, and it does not fix
  the empty-report defect.

### 7.4 Codecov upload step

**VERIFIED** by `WebFetch https://raw.githubusercontent.com/codecov/codecov-action/v7/action.yml`:
the v7 input set is `base_sha, binary, codecov_yml_path, commit_parent, directory,
disable_file_fixes, disable_search, disable_safe_directory, disable_telem, dry_run, env_vars,
exclude, fail_ci_if_error, files, flags, force, git_service, gcov_args, gcov_executable,
gcov_ignore, gcov_include, handle_no_reports_found, job_code, name, network_filter,
network_prefix, os, override_branch, override_build, override_build_url, override_commit,
override_pr, plugins, recurse_submodules, report_code, report_type, root_dir, run_command,
skip_validation, slug, swift_project, token, url, use_legacy_upload_endpoint, use_oidc,
use_pypi, verbose, version, working-directory`.

- **There is no `file` input in v7.** Only `files`. The workflow's `file: ./coverage.xml` is
  an **undeclared input**.
- **VERIFIED** by `WebFetch https://github.com/codecov/codecov-action/tags`: `v7.0.0` and the
  `v7` moving tag exist (dated Jun 7, 2026). The pin is valid.
- **VERIFIED**: `fail_ci_if_error` defaults to `'false'`, so the explicit `false` is a no-op
  but harmless and self-documenting.

**Recommended change:** `file: ./coverage.xml` -> `files: ./coverage.xml`.

**UNVERIFIED** (stated as such): GitHub Actions treats an undeclared `with:` key as a
warning, not an error, so today the step does not fail; with `disable_search` unset the
action's own file discovery would locate `coverage.xml` regardless. I could not run a
workflow to confirm this, so treat it as likely-but-unconfirmed. Either way, `files:` is the
declared input and is the correct spelling.

**Recommended: leave `fail_ci_if_error: false` unchanged.** No `token` input is configured
and no `CODECOV_TOKEN` reference appears in the workflow, so uploads are tokenless and
subject to rate limiting; flipping to `true` would convert an external-service flake into a
merge blocker. Changing it is a separable decision and is not required to fix #506.

## 8. Workflow policy obligations

**`.claude/rules/ci-workflows.md`** — **VERIFIED not triggered.** The rule's own Scope
section binds it to *"any workflow step whose `run:` block uses `shell: pwsh` (or the repo
default `pwsh`) and intentionally invokes a failing nested command."* `_quality-checks.yml`
sets no `defaults.run.shell` and runs on `ubuntu-latest`, whose default shell is `bash`;
neither the recommended pytest step nor the recommended enforcement step invokes a
deliberately-failing nested command. **No `$LASTEXITCODE` reset or explicit `exit 0` is
required.** Record this determination in the spec so a reviewer does not raise it.

**`modified-workflow-needs-green-run`** — **TRIGGERED.** **VERIFIED**,
`.claude/skills/feature-review-workflow/SKILL.md` lines 68-75:

> If the branch diff modifies any path matching `.github/workflows/**`,
> `scripts/benchmarks/**`, or `.github/actions/**`, the policy audit emits a Blocking finding
> unless evidence of a green workflow run against the branch head is present in the
> remediation inputs.
>
> - "Green workflow run against the branch head" means a workflow run whose head SHA matches
>   the current branch head and whose conclusion is success for the affected workflow.
> - A green `workflow_dispatch` run against the branch head also satisfies the rule, not only
>   a PR-context run.
> - The supporting validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1`
>   implements the trigger-path and evidence-presence logic.

Operational consequence for the plan:

1. Push the branch.
2. `gh workflow run _quality-checks.yml --ref bug/ci-coverage-targets-nonexistent-package-506`
   (the workflow declares `workflow_dispatch`, **VERIFIED** at line 5).
3. Wait for a `success` conclusion whose head SHA equals the branch head.
4. Record the run URL in the remediation inputs **before** feature review.
5. Any subsequent commit invalidates the evidence — the head SHA must match. **Sequence the
   dispatch as the final task, after all other edits are committed.**

**`.github/instructions/github-actions.instructions.md`** — requires that all workflows pass
`actionlint`, naming `scripts/dev-tools/run-actionlint.ps1` locally and *"job `actionlint` in
`.github/workflows/ci.yml`"*. **VERIFIED**: `scripts/dev-tools/run-actionlint.ps1` exists,
but **`ci.yml` contains no `actionlint` job** (its nine jobs are `quality-checks7`,
`security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`,
`drm-copilot-extension-tests`, `root-typescript-tests`, `npm-audit-gate`). The instruction
document names a CI job that does not exist. **Run the local script; do not rely on a CI
actionlint job.** Not in scope to fix.

## 9. Regression-test seam

### 9.1 There is no existing seam

**VERIFIED** by `Grep '\.github/workflows|WORKFLOWS_DIR|workflow_dir'` across `tests/`: the
only match is `tests/scripts/dev_tools/codex_native_converter/test_rewrites.py:221`, where
the string `".github/workflows/*.yml"` is *fixture prose inside a rendered skill body*, not
an assertion about a workflow file.

**VERIFIED** by `Grep '_quality-checks|quality-checks'` excluding `docs/**`: matches occur
only in `.github/workflows/README.md`, `ci.yml`, and the workflow itself. **No test in this
repository parses, reads, or asserts anything about any file under `.github/workflows/**`.**

**Stated plainly: the seam does not exist and must be created by this change.**

### 9.2 Recommended seam — a committed-file contract test

The repository already has a well-established pattern for asserting on committed
non-Python text files. **VERIFIED**,
`tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py` lines 7, 22-24:

```python
REPO_ROOT = Path(__file__).resolve().parents[3]

def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 content for a checked-in repository text file."""
    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")
```

That module asserts on files under `.github/agents/` from a test located at
`tests/scripts/dev_tools/`. Reading a committed file is permitted: it is not a temporary
file, not mutable global state, and not an external service, so it satisfies
`.claude/rules/general-unit-test.md`. PyYAML is already a project dependency
(**VERIFIED**, `pyproject.toml:19`), so structural assertions are available.

**Recommended new test file:**

```
tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
```

**Test-layout note the planner must resolve.** `.claude/rules/general-unit-test.md` requires
that `tests/` mirror the production source structure, which would put this at
`tests/github/workflows/test_quality_checks.py`. But no `tests/github/` tree exists
(**VERIFIED**, `Glob tests/*` returns only `tests/conftest.py` and
`tests/test_pytest_collection.py`; `Glob tests/*/` matched nothing), and the repository's own
`.github/`-asserting contract tests all live under `tests/scripts/dev_tools/`. I recommend
**following the existing precedent** and note the alternative so the decision is explicit
rather than accidental.

**Recommended assertions.** Each is deterministic, fails before the fix, passes after:

| Assertion | Before fix | After fix |
| --- | --- | --- |
| `"--cov=src/lexile_corpus_tuner" not in text` | **FAIL** (present at line 76) | PASS |
| `"lexile" not in text.lower()` | **FAIL** | PASS |
| pytest step's `run:` contains `--cov --cov-branch` | **FAIL** | PASS |
| pytest step's `run:` contains `--cov-report=json:artifacts/python/coverage.json` | **FAIL** | PASS |
| a step exists whose `run:` names `check_python_coverage_thresholds` with `--min-line 85` and `--min-branch 75` | **FAIL** | PASS |
| the Codecov step's `with:` mapping has key `files` and **not** key `file` (parse with `yaml.safe_load`) | **FAIL** | PASS |

The first assertion alone satisfies the delegation prompt's "FAIL before / PASS after"
requirement. The rest guard the remedy against silent regression.

### 9.3 Recommended unit tests for the new module

```
tests/scripts/dev_tools/test_check_python_coverage_thresholds.py
```

Arrange-Act-Assert, deterministic, no temp files (inject the parsed mapping, or use the
`mem_fs_path` fixture from `tests/conftest.py:146` when file I/O must be exercised):

- Both metrics above their floors -> exit 0.
- `percent_statements_covered` at exactly 85.0 -> exit 0 (boundary, inclusive).
- `percent_statements_covered` at 84.9 -> non-zero exit; message names line coverage and the
  floor. **This is the "deliberate coverage regression must fail the check" scenario from
  `issue.md:74`, converted into a runnable test.**
- `percent_branches_covered` at exactly 75.0 -> exit 0; at 74.9 -> non-zero exit.
- Both below floor -> non-zero exit; message names **both** metrics, not just the first.
- Report file missing -> non-zero exit with a specific, actionable error (fail fast per
  `.claude/rules/general-code-change.md`); never a silent success.
- Report present but `totals` lacks `percent_branches_covered` (the shape produced when
  `--cov-branch` was omitted, **VERIFIED** at `jsonreport.py:99-100` where the branch summary
  is added only `if coverage_data.has_arcs()`) -> non-zero exit with a message that says
  branch data was not collected. **This case is important: it prevents a future edit that
  drops `--cov-branch` from silently disabling the branch gate.**

### 9.4 Existing test that must be updated

`tests/scripts/dev_tools/atomic_executor/test_qc_runner.py:433-441` asserts the exact
defective `FULL_TEST` argv. If `QCRunner.FULL_TEST` (item 3 in §6.1) is corrected, this
assertion must be updated in the same commit or the suite breaks. If item 3 is deferred to a
follow-up (see §10), this file is **not** in the write set.

## 10. Recommended write set

Repo-relative paths a fix would **write**. Neither padded nor understated.

### 10.1 Primary write set — fixes #506 as reported and makes the gate able to fail

| # | Path | Change | New? |
| --- | --- | --- | --- |
| 1 | `.github/workflows/_quality-checks.yml` | Replace line 76 with the bare-`--cov` command plus JSON reporter; add the threshold-enforcement step; change `file:` to `files:` on the Codecov step | no |
| 2 | `scripts/dev_tools/check_python_coverage_thresholds.py` | New module: read the JSON `totals`, compare against `--min-line` / `--min-branch`, exit non-zero on breach | **yes** |
| 3 | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | Unit tests per §9.3 | **yes** |
| 4 | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | Workflow-YAML contract test per §9.2 | **yes** |
| 5 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md` | Fill the template sections; record the §2.2 and §2.3 corrections and the §3.4 pass verdict | no |
| 6 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.<ts>.md` | Atomic plan | varies |
| 7 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/**` | Baseline and QA-gate artifacts, canonical location per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | **yes** |

`pyproject.toml` is **not** in the primary write set. No change to `[tool.coverage.run]`,
`[tool.coverage.report]`, or `addopts` is required: the configured `source` is already
correct, the `omit` list is already policy-compliant, and adding a `fail_under` there would
duplicate the enforcement step and would gate the wrong (combined) metric.

### 10.2 Deferred — same root cause, different failure mode, separate issue recommended

Items 2 and 4-11 of §6.1. They are **degraded-but-functional** (a `CoverageWarning`, not a
vacuous measurement) with the sole exception of `QCRunner.FULL_TEST` (item 3), which is
vacuous but is not on the CI path. Folding them in would touch five production modules under
`scripts/dev_tools/atomic_executor/**` plus `.vscode/tasks.json`, `pyproject.toml`, and a
test file — a substantially larger blast radius than the reported CI defect, and contrary to
`.github/instructions/general-code-change.instructions.md` lines 35-37 (*"Change only what is
needed... If you uncover deeper design problems, open a new issue instead of widening
scope"*).

**Recommendation: file one follow-up issue covering §6.1 items 2-11 plus the §6.2
Copilot-surface documents.** If the spec instead elects to fold them in, the write set grows
by exactly: `scripts/dev_tools/atomic_executor/qc_toolchain.py`,
`scripts/dev_tools/atomic_executor/qc_runner.py`,
`scripts/dev_tools/atomic_executor/cli_preflight.py`,
`scripts/dev_tools/atomic_executor/prompt_builder.py`,
`scripts/dev_tools/fix_all_branches_extra.py`,
`tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`, `.vscode/tasks.json`,
`pyproject.toml`.

### 10.3 Blocked pending explicit authorization — do not write

- `.github/instructions/python-unit-test.instructions.md`
- `.github/instructions/python-suppressions.instructions.md`
- `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md`
- `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md`

`CLAUDE.md` forbids modifying `.github/instructions/**`; the two bundled mirrors must track
their sources. Editing any of the four requires an explicit user decision. Record as a
`human_interaction` requirement with `response: scope_change` or `exception`.

### 10.4 Explicitly NOT written

All ~170 matches under `docs/features/archive/**`, `docs/features/completed/**`, and
`docs/features/potential/promoted/**`. They are historical records of commands that were
actually executed; rewriting them would falsify the record.

## 11. Open items for the spec author

1. **Threshold-step matrix scope** — all four Python legs, or `3.13` only (§7.2).
2. **Deferral decision** — file a follow-up for §6.1 items 2-11, or fold them in (§10.2).
3. **Policy-file conflict** — how to handle the four blocked files in §10.3.
4. **Test-layout convention** — `tests/scripts/dev_tools/` (existing precedent) or a new
   `tests/github/workflows/` mirror (§9.2).
5. **`fail_ci_if_error`** — recommendation is to leave it `false`; confirm (§7.4).
6. **Live reproduction** — the plan must include a task that actually runs both the defective
   and the corrected commands and records exit codes and the `TOTAL` row as baseline
   evidence, since this session could not (§0). That task must first print
   `poetry env info --path` and assert the active checkout, because **no `.venv` exists in
   this worktree** and `poetry run` will otherwise measure the main checkout.
