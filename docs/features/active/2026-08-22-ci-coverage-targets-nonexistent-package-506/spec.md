# 2026-08-22-ci-coverage-targets-nonexistent-package (Spec)

- **Issue:** #506
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23T23-59
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug (this document is the sole acceptance-criteria source; `user-story.md` is intentionally absent because the defect is internal to the CI pipeline and has no user-facing narrative)

## Context
The CI test step measures coverage against `src/lexile_corpus_tuner`, a package that does not exist in this repository. The name belongs to a different project and appears to be template residue. The run therefore collects no coverage data at all, and the workflow uploads an empty report to Codecov. The repository's CI coverage signal cannot fail on a regression because it measures nothing.

Environment:
- OS/version: GitHub Actions runner, and reproduced locally on Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: `poetry run pytest --cov=src/lexile_corpus_tuner --cov-report=xml --cov-report=term-missing`
- Data source or fixture: `.github/workflows/_quality-checks.yml` line 76, reached from `.github/workflows/ci.yml` line 12

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. Every pull request has been merging against a coverage check that cannot fail. The repository's own policy in `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` requires line coverage at or above 85 percent and branch coverage at or above 75 percent, uniformly across tiers T1 through T4. The pipeline has been unable to enforce either figure.

Correction to the severity paragraph as originally filed: the issue report asserted that `.claude/rules/plan-acceptance-gates.md` classifies a coverage value of this shape as a **Blocking** defect. That assertion is not supported by the implementation. Tracing `evaluate_cov_value` in `scripts/dev_tools/plan_gate_coverage.py` against the literal value `src/lexile_corpus_tuner` yields **G3 — Warning** (research section 2.3): G4 does not apply because the equals form is used, the placeholder guard does not fire, G1 does not apply because the value does not end in `.py`, G2 does not apply because `src/lexile_corpus_tuner.py` is not tracked, and the value is not a tracked directory. The repository's own plan gate would have reported a Warning, not blocked the value. The severity of the CI defect is unchanged by this correction; only the cited classification was wrong.

### Headline finding — measured correctly, the repository already passes both thresholds

This is the most consequential result of the investigation and it is favourable. Committed evidence from an unrelated feature branch, produced by `poetry run pytest --cov --cov-branch` with exit code 0, records:

| Metric | Measured (2026-08-23) | Policy floor | Margin | Verdict |
| --- | --- | --- | --- | --- |
| Python line coverage | 92.61 percent (13841/14946) | 85 percent | +7.61 points | PASS |
| Python branch coverage | 85.19 percent (4677/5490) | 75 percent | +10.19 points | PASS |

Sources: `docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-test-coverage.md` and `docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/policy-audit.2026-08-23T11-12.md`.

Consequence: the gate can be turned on immediately, without any remediation work on test coverage and without a staged or advisory posture. Two caveats are recorded and are not dismissed:

1. The measurement was taken on Windows with Python 3.13. CI runs `ubuntu-latest` across Python 3.10, 3.11, 3.12, and 3.13. Version-gated and platform-gated branches can shift the figure. The margins make a breach unlikely but not impossible, which is why the pre-authorized fallback in the matrix-scope decision below exists.
2. `.claude/rules/general-unit-test.md` also requires no coverage regression on changed lines. A threshold gate does not enforce that requirement; it remains policy-enforced through review.

## Repro & Evidence
Steps to Reproduce:
1. Confirm the target is absent: `ls -d src/lexile_corpus_tuner` reports no such file or directory.
2. Run the workflow's command verbatim from the repository root.
3. Read the `tests coverage` section of the output.

Expected:
The coverage target names a scope that exists in this repository, so the reported percentage reflects the code actually under test and a regression can fail the gate. Correction to the expected-behavior statement as originally filed: the issue required the target to be "expressed as a dotted module path". That requirement is incorrect. `coverage.py` accepts either a directory path or an importable module or package name; the repository's own `[tool.coverage.run] source = ["src", "scripts/dev_tools"]` entries are directory paths and they measure 14,939 statements successfully. The correct expectation is that the target exists, not that it is dotted.

Actual:
The suite runs and passes, and the coverage table is printed with no rows and no `TOTAL` line. No data is collected. The subsequent `Upload coverage to Codecov` step then publishes that empty `coverage.xml`.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet, measured locally on 2026-08-22:

  ```text
  =============================== tests coverage ================================
  ______________ coverage: platform win32, python 3.13.12-final-0 _______________

  4078 passed, 5 skipped in 13.20s
  ```

  The coverage block is empty between its header and the test summary.

Evidence produced by this fix is written to `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/` under the canonical `baseline/`, `qa-gates/`, and `coverage/` kinds defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No evidence is written to `artifacts/`.

Reproduction trap the executor must handle: no `.venv` exists in this worktree. The only virtual environment on the machine belongs to the main checkout, so `poetry run` from this worktree executes against an editable install pointing at `C:\Users\DanMoisan\repos\drm-copilot`. Any live measurement task must first print `poetry env info --path` and record which checkout was measured before the resulting numbers are trusted.

## Scope & Non-Goals
- In scope:
  - `.github/workflows/_quality-checks.yml` — replace the defective pytest command, add a coverage-threshold enforcement step, and correct the Codecov input key.
  - `scripts/dev_tools/check_python_coverage_thresholds.py` — new module that reads the JSON coverage report and exits non-zero when either policy floor is breached.
  - `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` — new unit tests for that module.
  - `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` — new contract test asserting the committed workflow file.
  - This spec, the atomic plan, and the evidence tree inside the feature folder.
- Out of scope / non-goals:
  - `pyproject.toml`. The configured `[tool.coverage.run] source` is already correct and the `omit` list is already compliant with the Coverage Exclusion Policy. Adding `fail_under` there would duplicate the enforcement step and would gate the wrong metric.
  - The nine remaining live occurrences of the foreign package name catalogued in research section 6.1 (items 2 and 4 through 11) and the Copilot-surface documents in research section 6.2. Rationale: those occurrences pair the foreign target with a valid `--cov=scripts/dev_tools` target, so they are degraded but functional — they emit a `CoverageWarning: module-not-imported` and still measure the correct scope. The sole exception is `QCRunner.FULL_TEST`, which is vacuous but is not on the CI path and therefore does not cause the reported defect. Folding them in would touch five production modules under `scripts/dev_tools/atomic_executor/`, plus `.vscode/tasks.json`, `pyproject.toml`, and an existing test file, which is a materially larger blast radius than the reported CI defect and is contrary to `.github/instructions/general-code-change.instructions.md` ("Change only what is needed to make the failing test pass... If you uncover deeper design problems, open a new issue instead of widening scope"). A follow-up issue is recommended in Rollout & Follow-up. No tracking file is created outside this feature folder.
  - Coverage threshold gates for other languages. Research section 5 established that no workflow in this repository enforces a coverage threshold in any language. The Python gap is one instance of a repository-wide absence; closing the non-Python instances is a separate concern.
  - Adding a `codecov.yml` project status. It moves the gate server-side into a check that is not in this repository's CI DAG and does not fix the empty-report defect.
  - `fail_ci_if_error`. See the decision record below; it stays `false`.
  - Removing the inert `"src"` entry from the configured source list. It is harmless, `src/` may legitimately gain Python later, and removing it would widen the diff to `pyproject.toml` for no behavioural gain.
  - The absence of an `actionlint` job in `ci.yml`, which `.github/instructions/github-actions.instructions.md` names but which does not exist. The local script `scripts/dev-tools/run-actionlint.ps1` is run instead; fixing the CI job gap is not in scope.
- Explicitly excluded systems, integrations, or datasets:
  - `.github/instructions/python-unit-test.instructions.md` and `.github/instructions/python-suppressions.instructions.md`, plus their two bundled mirrors under `extensions/drm-copilot/resources/customizations/.github/instructions/`. These four files publish the defective command as the approved Python test command, but `CLAUDE.md` states that files under `.github/instructions/` are the canonical policy source and must not be modified. They are not in the write set. See the human-interaction requirement below.
  - Approximately 170 matches under `docs/features/archive/`, `docs/features/completed/`, and `docs/features/potential/promoted/`. These are plans, policy audits, and evidence artifacts recording commands that were actually executed at the time. Rewriting them would falsify the historical record.

## Root Cause Analysis
There is exactly **one** fault, not two. The issue report's "two independent problems in one value" framing is corrected here.

The single fault is that **the coverage target does not exist**. `Glob src/**` returns exactly one file, `src/hello-typescript.ts`; there is no `src/lexile_corpus_tuner` directory and no importable `lexile_corpus_tuner` module.

The mechanism, verified from installed library source:

1. `pytest_cov/plugin.py` declares `--cov` with `nargs='?'` and `const=True`, and `_prepare_cov_source` returns `None` when the bare form is used and a list of values otherwise.
2. `pytest_cov/engine.py` passes the resolved value to `coverage.Coverage(source=...)`.
3. `coverage/config.py::from_args` assigns each keyword whose value is not `None`, overwriting the configured setting.

Therefore an explicit `--cov=VALUE` **overwrites** the `[tool.coverage.run] source` list configured in `pyproject.toml`. Naming a target that matches nothing discards a correct configuration and measures zero files, which is why the table has no rows, no `TOTAL` line is printed, and `coverage.xml` is written empty. Using the bare `--cov` form leaves `cov_source` as `None`, so `from_args` skips it and the configured source list applies.

The second claimed fault — that the filesystem-path form is invalid and `coverage.py` requires a dotted module — is **false**. `coverage.py` accepts a directory path or an importable name. The repository's own configured `source = ["src", "scripts/dev_tools"]` entries are directory paths and they measure 14,939 statements successfully. The repository's own plan-gate implementation agrees: `scripts/dev_tools/plan_gate_coverage.py` accepts a tracked directory as a valid coverage target. This correction changes the remedy. The fix is not "convert the value to dotted form"; it is "name a scope that exists", and the least-drift way to do that is to name none on the command line and let the configuration own it.

Secondary defect, in the same step group: the Codecov upload step passes `file: ./coverage.xml`. `file` is not a declared input of `codecov/codecov-action@v7`; the declared input is `files`. This is an undeclared-input spelling error rather than a collection failure, and it is corrected in the same change because it sits in the same step group and is one token wide.

Note that the test selection is not restricted, so the suite result reported by CI is real. Only the coverage figure is vacuous.

## Proposed Fix

### Design summary (what changes where):
Three coordinated changes, plus their tests.

1. **`.github/workflows/_quality-checks.yml`, the pytest step.** Replace the explicit, nonexistent target with the bare `--cov` form, add `--cov-branch`, and add a JSON reporter so the two policy metrics can be read directly:

   ```yaml
         - name: Run tests with Pytest
           run: |
             poetry run pytest --cov --cov-branch \
               --cov-report=xml \
               --cov-report=json:artifacts/python/coverage.json \
               --cov-report=term-missing
           continue-on-error: false
   ```

2. **`.github/workflows/_quality-checks.yml`, a new enforcement step** immediately after the pytest step:

   ```yaml
         - name: Enforce Python coverage thresholds
           run: |
             poetry run python -m scripts.dev_tools.check_python_coverage_thresholds \
               --report artifacts/python/coverage.json \
               --min-line 85 --min-branch 75
           continue-on-error: false
   ```

3. **`.github/workflows/_quality-checks.yml`, the Codecov step.** Change the key `file` to the declared key `files`, leaving its value `./coverage.xml` unchanged.

4. **`scripts/dev_tools/check_python_coverage_thresholds.py`, new.** Reads the JSON report, extracts `totals.percent_statements_covered` and `totals.percent_branches_covered`, compares each against its floor, and exits non-zero on any breach or on any of the defined error conditions.

### Decision record (six open items closed)

The research artifact left six items open. All six are decided here so that a later reviewer sees a decision with its rationale rather than an omission.

**D1 — Coverage command form: bare `--cov` with `--cov-branch`.** No `--cov=` value is supplied, so `[tool.coverage.run] source` in `pyproject.toml` remains the single source of truth. `--cov-report=json:artifacts/python/coverage.json` is added. `pyproject.toml` is not modified. Rationale: restating the scope on the command line creates a drift surface between two files that must then be kept in agreement; the bare form is byte-compatible with the command already prescribed by `.claude/rules/python.md` and `.claude/skills/python-qa-gate/SKILL.md`, so local and CI runs measure an identical denominator and a reviewer's local-versus-CI comparison is meaningful. `/artifacts` is gitignored, so the JSON report is not committed. Known consequence, recorded so the planner is not surprised: an atomic plan that quotes this command verbatim receives a **G4 Warning** from the repository's own plan gate, because `cov_values` treats a bare `--cov` word as the space-separated form and reads the following word, `--cov-branch`, as its value. G4 is a Warning, not Blocking, so it does not fail plan validation. The alternative `--cov=scripts/dev_tools --cov=src` avoids the warning but duplicates configuration; the drift risk is judged the larger cost.

**D2 — Threshold enforcement: a separate step invoking a unit-testable module, not `--cov-fail-under`.** Rationale, and the trap this avoids: with `--cov-branch` active, `--cov-fail-under` does **not** gate line coverage. `pytest_cov/plugin.py` compares `self.cov_total`, which `engine.py::summary()` sources from the reporter's return value, and every reporter returns `total.pc_covered`. `coverage/results.py` computes `pc_covered` from `ratio_covered = (n_executed + n_executed_branches, n_statements + n_branches)` — the **combined** statements-plus-branches ratio, approximately 90.6 percent today. That is a metric no policy in this repository defines; it is weaker than the line requirement and enforces nothing at all on branches. Without `--cov-branch` the combined ratio degenerates to line coverage exactly, but then branch data is not collected and the branch floor is unmeasurable. Reading `totals.percent_statements_covered` and `totals.percent_branches_covered` from the JSON report is the only form that gates the two metrics the policy actually names, and `coverage/jsonreport.py` emits both figures directly, so no column arithmetic is required. A module rather than inline shell was chosen because the workflow at line 71 already runs `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` as a gate (in-repo precedent), because a workflow `run:` block is never executed by local review — the reason `.claude/rules/ci-workflows.md` exists — so a module converts the "a deliberate coverage regression must fail the check" scenario into a deterministic unit test, and because the module enters the coverage denominator itself and must meet the same floors.

**D3 — Matrix scope: run the enforcement step on all four Python legs.** Rationale: `.claude/rules/quality-tiers.md` states the 85 percent line floor and 75 percent branch floor unconditionally, uniformly across tiers, and not per interpreter version. The floor must therefore hold on the worst leg, and a version-gated regression that only appears on 3.10 is exactly the class of defect a per-version gate would miss. **Pre-authorized fallback:** if the green run against the branch head reveals a version-specific shortfall on a leg other than 3.13, the enforcement step may be narrowed to `if: matrix.python-version == '3.13'`, matching the condition already used by the Codecov step, and the shortfall filed as a follow-up issue. This fallback is authorized in advance, so an atomic plan may carry an explicit narrowing branch for it and does not need to return for a decision.

**D4 — Deferral: research section 6.1 items 2 and 4 through 11, and all of section 6.2, are out of scope.** Rationale is recorded in Scope & Non-Goals above. A follow-up issue is recommended in Rollout & Follow-up. No tracking file is created outside this feature folder.

**D5 — Blocked policy files: not in the write set; escalated as a human-interaction requirement.** The four files are named in Scope & Non-Goals. `.github/instructions/general-code-change.instructions.md` instructs that conflicting instructions be surfaced rather than resolved unilaterally, and `CLAUDE.md` forbids modifying `.github/instructions/`. The conflict is real: those files publish the defective command as the approved Python test command, so agents that follow them will continue to reproduce it. This is recorded as a `human_interaction` requirement with `response: scope_change`, requiring a user decision before any of the four is touched.

**D6 — Test layout: both new test files go under `tests/scripts/dev_tools/`.** Rationale: `.claude/rules/general-unit-test.md` requires the test tree to mirror the production source structure, which read literally would place the workflow-contract test at `tests/github/workflows/`. No `tests/github/` tree exists, and the repository's existing contract tests that assert on files under `.github/` already live under `tests/scripts/dev_tools/` — `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py` asserts on files under `.github/agents/` from exactly that location, using a `REPO_ROOT` computed from `Path(__file__).resolve().parents[3]`. Following the established precedent keeps one convention rather than two. The alternative was considered and is recorded here so the decision is explicit rather than accidental.

**D7 — `fail_ci_if_error` stays `false`.** Rationale: no `token` input is configured and no `CODECOV_TOKEN` reference appears in the workflow, so uploads are tokenless and subject to rate limiting. Flipping the flag to `true` would convert an external-service flake into a merge blocker. The change is separable and is not required to fix this defect.

**D8 — Codecov input key: `file` becomes `files`.** `file` is not a declared input of `codecov/codecov-action@v7`; the declared input set includes `files` and not `file`. Whether GitHub Actions currently treats the undeclared key as a warning rather than an error is unconfirmed, and the action's own file discovery may locate `coverage.xml` regardless, so this is a correctness fix rather than a repair of an observed failure. `files` is the declared spelling and is used.

### Boundaries and invariants to preserve:
- `pyproject.toml` is not modified. `[tool.coverage.run] source`, `omit`, `[tool.coverage.report] exclude_lines`, and `addopts` are unchanged.
- The Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` is not weakened. The existing `omit` entries are all non-production paths expressly permitted by that policy, and no new exclusion is added.
- Test selection is unchanged. The suite that runs is the suite that ran before; only the measurement scope and the added gate change.
- `--cov-report=xml` continues to write `coverage.xml` at the run directory, matching the upload step's `./coverage.xml` value.
- The four blocked policy files and all historical records under `docs/features/archive/`, `docs/features/completed/`, and `docs/features/potential/promoted/` are not modified.
- `.claude/rules/ci-workflows.md` is **not** triggered by this change. Its scope binds it to a step whose `run:` block uses `pwsh` and intentionally invokes a failing nested command. `_quality-checks.yml` sets no `defaults.run.shell` and runs on `ubuntu-latest`, whose default shell is `bash`, and neither the revised pytest step nor the new enforcement step invokes a deliberately-failing nested command. No `$LASTEXITCODE` reset and no explicit `exit 0` is required. This determination is recorded so that a reviewer does not raise it as a finding.

### Dependencies or blocked work:
- No new third-party dependency. `pytest-cov` and `coverage` are already installed, the JSON reporter is already supported, and PyYAML is already a project dependency and is available for the workflow-contract test's structural assertions.
- Blocked: the four policy files under D5, pending the user decision recorded as the human-interaction requirement.
- Sequencing dependency: the `modified-workflow-needs-green-run` rule is triggered by this change, so the branch-head workflow dispatch must be the final action after all other commits. Any later commit invalidates the evidence because the head SHA must match.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
| # | Path | Change | New? |
| --- | --- | --- | --- |
| 1 | `.github/workflows/_quality-checks.yml` | Replace the pytest command with the bare-`--cov` form plus `--cov-branch` and the JSON reporter; add the threshold-enforcement step; change `file` to `files` on the Codecov step | no |
| 2 | `scripts/dev_tools/check_python_coverage_thresholds.py` | New module: read the JSON `totals`, compare against the two floors, exit non-zero on breach | yes |
| 3 | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | Unit tests for the new module | yes |
| 4 | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | Contract test asserting the committed workflow file | yes |
| 5 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md` | This document | no |
| 6 | The timestamped atomic plan inside the feature folder | Atomic plan | varies |
| 7 | `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/` | Baseline, QA-gate, and coverage artifacts in the canonical location | yes |

#### Functions/classes/CLI commands impacted:
- New module surface: a pure comparison function that takes the parsed `totals` mapping and the two floors and returns the list of breach descriptions, plus a thin `main` that parses arguments, loads the report, calls the pure function, prints any breaches, and returns the exit code. Pure logic is kept separate from file I/O and from argument parsing so the comparison is testable without touching the filesystem.
- No existing function, class, or CLI command changes behaviour. `QCRunner.FULL_TEST` and the other occurrences catalogued in research section 6.1 are deliberately untouched, so `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` is **not** in the write set and its existing assertion on the current `FULL_TEST` argv remains valid.

#### Data flow and validation changes:
- pytest writes `coverage.xml` and `artifacts/python/coverage.json`. The enforcement step reads only the JSON report. It reads `totals.percent_statements_covered` and `totals.percent_branches_covered` and does not recompute either from column arithmetic.
- Validation performed by the module, each of which must fail loudly rather than pass silently: report file missing or unreadable; report not valid JSON; `totals` absent or not a mapping; `percent_statements_covered` absent; `percent_branches_covered` absent, which is the shape `coverage.py` produces when `--cov-branch` was omitted, because the branch summary is emitted only when arc data was collected.
- Comparison is inclusive at the floor: a value exactly equal to its floor passes.

#### Error handling and logging updates:
- Fail fast and explicitly, per `.claude/rules/general-code-change.md`. Every error condition above produces a non-zero exit and a specific, actionable message that names the condition and the report path. No broad catch-all, and no path that returns success when a metric could not be read.
- A breach message names the metric, the measured value, and the floor. When both metrics breach, both are reported in the same run rather than only the first, so one CI run surfaces the full picture.
- Output goes to standard error for failures; there is no logging framework in this module's dependency set and none is introduced.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. The change is a workflow edit plus a new module; rollback is a revert of the commit.
- The pre-authorized narrowing in D3 is the only in-flight adjustment path and is a one-line `if:` addition, not a flag.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Module input: `--report` (path to the JSON coverage report), `--min-line` (float, percent), `--min-branch` (float, percent).
- Report format consumed: the `coverage.py` JSON report, whose `totals` object carries `percent_statements_covered` and `percent_branches_covered` as numbers in percent units.
- Output: exit code 0 when both metrics are at or above their floors; non-zero otherwise or on any error condition. Human-readable breach or error messages on standard error.

#### Required configuration keys and defaults:
- No new configuration file and no new key in `pyproject.toml`. The floors are supplied as command-line arguments in the workflow so that the value the gate enforces is visible at the call site, matching the two figures stated in `.claude/rules/quality-tiers.md`.
- Defaults for `--min-line` and `--min-branch`, if the module defines any, must equal 85 and 75 respectively so that an omitted argument cannot weaken the gate.

#### Backward-compatibility expectations:
- No public API changes. The new module is additive.
- The workflow's job name, matrix, and step ordering are otherwise unchanged, so no branch-protection required-check name changes.

#### Performance constraints (latency/throughput/memory):
- The enforcement step reads one JSON file and performs two comparisons. Its runtime is negligible relative to the test suite.
- Adding `--cov-branch` and a second reporter increases pytest runtime modestly. The committed evidence run with `--cov --cov-branch` completed the suite normally, so no constraint is expected to bind.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - `ubuntu-latest` runners provide `bash` as the default shell, so no shell declaration is required.
  - The `artifacts/python/` directory is writable in the runner working directory and `/artifacts` remains gitignored, so the JSON report is produced but not committed.
  - The committed coverage figures from the 502 feature branch are representative of the branch under change. This is an assumption, not a measurement of this branch, which is why a live baseline task is required.
  - `workflow_dispatch` is declared on `_quality-checks.yml`, so a green run can be produced against the branch head without opening a pull request first.
- Constraints (budget, performance, compatibility):
  - `.github/instructions/` files must not be modified. Four files that publish the defective command therefore stay defective in this change.
  - Historical feature records must not be rewritten.
  - No new third-party dependency may be introduced.
  - No temporary files may be created in tests. The new module's tests inject a parsed mapping directly, or use the in-memory filesystem fixture already available in `tests/conftest.py` when file I/O must be exercised.
  - Every new file stays under the 500-line limit.
- External dependencies (services, libraries, releases):
  - `codecov/codecov-action@v7`. The `v7.0.0` and moving `v7` tags exist and the pin is valid. Uploads are tokenless.
  - `coverage` and `pytest-cov` as already pinned by the project.
- **Human-interaction requirement (`response: scope_change`, user decision required).** Four files publish the defective coverage command but are forbidden to modify by `CLAUDE.md`: `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, and their bundled mirrors at `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md` and `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md`. Until the user decides, agents following those documents will continue to reproduce the defective command. The decision required is whether to authorize a scope change that brings the four files into the write set, or to leave them and accept the continued propagation. This work proceeds without them; the requirement is recorded, not resolved.

## Data / API / Config Impact
- User-facing or API changes: none. The change is confined to CI configuration and a new internal developer-tooling module.
- Data or migration considerations: none. `artifacts/python/coverage.json` is a new, ephemeral, gitignored build artifact.
- Logging/telemetry updates (if any): Codecov continues to receive `coverage.xml`. After the fix that report carries real data for the first time, so the Codecov project history will show a discontinuity at this commit — an apparent jump from an empty report to a populated one. This is expected and is not a regression.
- Compatibility notes (CLI flags, config schemas, versioning): a new module CLI is added with three flags. No existing flag, config schema, or version is changed.

## Test Strategy

The five items seeded from the issue are recorded below as dispositions rather than checkboxes, so that the `## Acceptance Criteria` section remains the sole checkbox-tracked list in this document.

- Disposition, "replace the target with a dotted module path": superseded by D1. The path form was never the fault; the remedy is the bare `--cov` form with no explicit target. A non-empty `TOTAL` row is still required and is carried by an acceptance criterion.
- Disposition, "decide whether the branch flag is required": decided by D1 and D2. `--cov-branch` is required, both because `.claude/rules/python.md` prescribes it and because it is the only way to populate the branch metric the policy gates on. The combined-ratio trap the issue noted is confirmed and is the reason `--cov-fail-under` is rejected.
- Disposition, "unit coverage areas: none directly; this is a workflow change": superseded. D2 introduces a new module, so there are direct unit-coverage areas, and the workflow itself gains a contract test.
- Disposition, "a deliberate coverage regression must fail the check": retained and converted into a deterministic unit test of the new module, because no workflow `run:` block executes locally.
- Disposition, "green workflow run required": retained. The `modified-workflow-needs-green-run` rule is triggered because the diff touches `.github/workflows/`.

- Regression tests to add or update:
  - `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, new. Reads the committed workflow file through a `REPO_ROOT`-relative helper, following the pattern in `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py`, and parses it with `yaml.safe_load` for structural assertions. Every assertion fails before the fix and passes after.
  - No existing test is modified. `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` stays valid because `QCRunner.FULL_TEST` is deliberately out of scope.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py`, new. Arrange-Act-Assert, deterministic, no temporary files.
  - Both metrics above their floors, exit 0.
  - Line coverage at exactly 85.0, exit 0 (inclusive boundary). Branch coverage at exactly 75.0, exit 0.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Line coverage at 84.9, non-zero exit, message names line coverage and its floor.
  - Branch coverage at 74.9, non-zero exit, message names branch coverage and its floor.
  - Both metrics below their floors, non-zero exit, both metrics named in the output rather than only the first.
  - Report file missing, non-zero exit with a specific, actionable error and never a silent success.
  - Report present but `totals` carries no `percent_branches_covered`, which is the shape produced when `--cov-branch` was omitted, non-zero exit with a message stating that branch data was not collected. This case prevents a future edit that drops `--cov-branch` from silently disabling the branch gate.
  - Report present but not valid JSON, non-zero exit.
- Error handling and logging verification: each error condition above is asserted on both its exit code and the presence of the naming token in its message, so a message that degrades to a bare stack trace fails the test.
- Coverage impact and targets for changed lines/modules: the new module enters the coverage denominator and its own tests must carry it. The repository-wide floors of 85 percent line and 75 percent branch continue to apply and, per the headline finding, are already met with margin.
- Toolchain commands to run (format, lint, type-check, test): `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Restart from formatting if any stage fails or changes files. Additionally `scripts/dev-tools/run-actionlint.ps1` for the workflow edit, because `ci.yml` has no `actionlint` job to catch it.
- Manual validation steps (if required):
  - Print `poetry env info --path` and record which checkout is active before trusting any local measurement, because no `.venv` exists in this worktree.
  - Run the defective command and the corrected command, and record both exit codes and both coverage tables as baseline evidence.
  - Push the branch, dispatch `_quality-checks.yml` against the branch head, wait for a `success` conclusion whose head SHA equals the branch head, and record the run URL. Sequence this last; any subsequent commit invalidates it.

## Acceptance Criteria

Each criterion below is checkable by the named test or by the named observable outcome. Prose inspection is not an accepted verification for any of them.

- [ ] AC-1. `.github/workflows/_quality-checks.yml` contains no occurrence of the token `lexile_corpus_tuner`, case-insensitively. Verified by `test_workflow_names_no_foreign_coverage_target` in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, which fails against the current committed workflow and passes after the fix.
- [ ] AC-2. The pytest step's `run` block contains the token `--cov-branch`, and contains no token beginning with `--cov=`. Verified by `test_pytest_step_uses_bare_cov_with_branch` in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, which tokenizes the step's `run` value obtained via `yaml.safe_load`.
- [ ] AC-3. The pytest step's `run` block contains the token `--cov-report=json:artifacts/python/coverage.json`. Verified by `test_pytest_step_emits_json_coverage_report` in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`.
- [ ] AC-4. A live run of the corrected command on this branch measures a non-empty denominator and produces the JSON report. Observable: the run's terminal output contains a `TOTAL` row whose statement count is greater than zero, `artifacts/python/coverage.json` exists after the run, and its `totals.num_statements` is greater than zero. The command's exit code and the `TOTAL` row are recorded in `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/`, together with the output of `poetry env info --path` identifying which checkout was measured.
- [ ] AC-5. A deliberate coverage regression fails the build. Verified by `test_line_coverage_below_floor_exits_non_zero` in `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py`, which supplies `percent_statements_covered` of 84.9 and asserts a non-zero exit code and a message naming line coverage. This criterion is carried by a unit test rather than by a workflow run because no workflow `run` block executes locally.
- [ ] AC-6. The branch floor is enforced independently of the line floor. Verified by `test_branch_coverage_below_floor_exits_non_zero`, which supplies `percent_branches_covered` of 74.9 with `percent_statements_covered` above its floor and asserts a non-zero exit code and a message naming branch coverage.
- [ ] AC-7. Both floors are inclusive at the boundary. Verified by `test_line_coverage_at_floor_is_accepted` and `test_branch_coverage_at_floor_is_accepted`, which supply exactly 85.0 and exactly 75.0 respectively and assert an exit code of 0.
- [ ] AC-8. A run that breaches both floors reports both metrics, not only the first. Verified by `test_both_metrics_below_floor_are_both_reported`, which asserts that the output names line coverage and branch coverage in the same run.
- [ ] AC-9. Absent branch data fails loudly rather than silently disabling the branch gate. Verified by `test_absent_branch_data_exits_non_zero` in `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py`, which supplies a `totals` mapping carrying `percent_statements_covered` above its floor and no `percent_branches_covered` key, and asserts a non-zero exit code and a message stating that branch data was not collected.
- [ ] AC-10. A missing or unparseable report fails loudly. Verified by `test_missing_report_file_exits_non_zero` and `test_unparseable_report_exits_non_zero`, each asserting a non-zero exit code and a message naming the report path.
- [ ] AC-11. The enforcement step is present in the workflow and invokes the new module with both floors. Verified by `test_threshold_step_invokes_the_checker_with_both_floors` in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, which locates the step whose `run` value contains the token `check_python_coverage_thresholds` and asserts that its tokenized `run` value contains `--min-line` followed by `85` and `--min-branch` followed by `75`.
- [ ] AC-12. The enforcement step runs on every Python matrix leg. Verified by `test_threshold_step_runs_on_every_matrix_leg` in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, which asserts that the enforcement step's mapping carries no `if` key. Pre-authorized alternative form under D3: if the branch-head green run reveals a version-specific shortfall on a leg other than 3.13, the step may be narrowed, in which case this criterion is satisfied instead by `test_threshold_step_is_narrowed_to_the_pinned_leg`, asserting that the step's `if` value equals the same condition already used by the Codecov step, **and** a follow-up issue recording the shortfall is linked in Rollout & Follow-up. Exactly one of the two tests is present in the landed change.
- [ ] AC-13. The Codecov step uses the declared input key. Verified by `test_codecov_step_uses_the_declared_files_input` in `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`, which parses the workflow with `yaml.safe_load`, locates the step whose `uses` value names the Codecov action, and asserts that its `with` mapping contains the key `files` and does not contain the key `file`.
- [ ] AC-14. `pyproject.toml` is unmodified by this change. Observable: `git diff --name-only origin/main...HEAD` does not list `pyproject.toml`.
- [ ] AC-15. None of the four blocked policy files is modified. Observable: `git diff --name-only origin/main...HEAD` lists none of `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md`, or `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md`.
- [ ] AC-16. The modified workflow passes actionlint. Observable: `scripts/dev-tools/run-actionlint.ps1` exits 0, with its output recorded in `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/`.
- [ ] AC-17. A green workflow run exists against the branch head, satisfying the `modified-workflow-needs-green-run` rule, which is triggered because the diff touches `.github/workflows/`. Observable: a `_quality-checks.yml` run whose conclusion is `success` and whose head SHA equals the output of `git rev-parse HEAD` on the branch, with the run URL recorded in `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/` before feature review. The dispatch is the final action; any later commit invalidates the evidence.
- [ ] AC-18. The full toolchain passes in a single pass. Observable: `poetry run black .`, `poetry run ruff check`, `poetry run pyright`, and `poetry run pytest --cov --cov-branch --cov-report=term-missing` each exit 0 in one uninterrupted sequence with no file modified by the formatter, with the transcript recorded in `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/`.
- [ ] AC-19. Repository coverage remains at or above both policy floors under the corrected scope. Observable: the JSON report's `totals.percent_statements_covered` is at or above 85 and `totals.percent_branches_covered` is at or above 75, recorded in `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/`.

EVIDENCE_LOCATION_OVERRIDE_REJECTED: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/coverage/` replaced with `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/`. The sub-path `evidence/coverage/` is not one of the canonical evidence kinds enumerated in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

## Risks & Mitigations
- Technical or operational risks:
  - **A version-specific shortfall on a leg other than 3.13 blocks merges.** The baseline was measured on Python 3.13 only. Likelihood is low given margins of 7.61 and 10.19 points, but version-gated branches can shift the branch figure.
  - **The local measurement measures the wrong checkout.** No `.venv` exists in this worktree, so `poetry run` resolves to the main checkout's environment and would report numbers for the wrong tree.
  - **The enforcement step passes vacuously if the JSON report is missing.** A gate that treats an absent report as success would reproduce the very defect being fixed, one layer up.
  - **A future edit drops `--cov-branch`,** which would make `percent_branches_covered` absent and could silently disable the branch half of the gate.
  - **Codecov history discontinuity.** The project's Codecov trend will jump at this commit because the prior reports were empty. A reviewer could misread this as a coverage change.
  - **Agents continue to reproduce the defective command** from the four blocked policy files.
- Mitigations and rollbacks:
  - Pre-authorized narrowing under D3, paired with a follow-up issue, so a version-specific shortfall does not stall the fix.
  - AC-4 requires `poetry env info --path` to be printed and recorded before any local number is trusted.
  - AC-10 requires a non-zero exit and a naming message when the report is missing or unparseable; the module must never return success on an unread metric.
  - AC-9 requires a non-zero exit when branch data is absent, which converts a silently-disabled gate into a hard failure.
  - The Codecov discontinuity is documented in Data / API / Config Impact and in the pull-request description so it is not misread.
  - The four blocked files are escalated as a human-interaction requirement rather than edited silently.
  - Rollback is a single revert; there is no data migration and no feature flag to unwind.

## Rollout & Follow-up
- Release/rollout steps:
  1. Land the module and both test files, and confirm the full toolchain passes locally.
  2. Land the workflow edit and run `scripts/dev-tools/run-actionlint.ps1`.
  3. Commit all edits. No further commits after this point until the green run is captured.
  4. Push the branch and dispatch `_quality-checks.yml` against the branch head using the workflow's declared `workflow_dispatch` trigger.
  5. Confirm a `success` conclusion whose head SHA equals the branch head, and record the run URL in the feature folder's `evidence/qa-gates/` directory before feature review.
  6. If a leg other than 3.13 reports a shortfall, apply the pre-authorized narrowing from D3, file the follow-up issue, link it here, and repeat steps 3 through 5.
- Post-fix monitoring or clean-up tasks:
  - **Recommended follow-up issue, residual foreign-package-name occurrences.** Cover research section 6.1 items 2 and 4 through 11, plus the Copilot-surface documents in section 6.2: `scripts/dev_tools/atomic_executor/qc_toolchain.py`, `scripts/dev_tools/atomic_executor/qc_runner.py` (both the `FULL_TEST` constant and the paired occurrence), `scripts/dev_tools/atomic_executor/cli_preflight.py` (the paired occurrence and the emitted prompt text), `scripts/dev_tools/atomic_executor/prompt_builder.py`, `scripts/dev_tools/fix_all_branches_extra.py`, `.vscode/tasks.json`, the inert `per-file-ignores` entry in `pyproject.toml`, `.github/agents/python-atomic-executor.agent.md`, `.github/prompts/remediate-comments.prompt.md`, their bundled mirrors, and the existing assertion in `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` that locks the vacuous `FULL_TEST` value in place. The paired occurrences are degraded but functional; `QCRunner.FULL_TEST` is vacuous but off the CI path. No tracking file is created outside this feature folder.
  - **Recommended follow-up, blocked policy files.** Once the user decides the human-interaction requirement recorded under D5, apply or formally waive the correction to the two `.github/instructions/` files and their two bundled mirrors.
  - **Recommended follow-up, repository-wide threshold absence.** No workflow in this repository enforces a coverage threshold in any language. This change closes the Python instance only; the PowerShell and shell coverage workflows remain ungated.
  - **Recommended follow-up, missing actionlint CI job.** `.github/instructions/github-actions.instructions.md` names an `actionlint` job in `ci.yml` that does not exist among that workflow's nine jobs.
  - Watch the first several post-merge runs to confirm the enforcement step reports real figures on all four legs and does not flake.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/506
  - Bug report: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/issue.md`
  - Research: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/research/2026-08-23T23-45-ci-coverage-target-remedy-research.md`
  - Policy: `.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/plan-acceptance-gates.md`
  - Review rule triggered: `modified-workflow-needs-green-run` in `.claude/skills/feature-review-workflow/SKILL.md`
