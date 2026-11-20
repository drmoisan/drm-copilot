# Policy Audit — Issue #506, CI coverage targets a nonexistent package

- Timestamp: 2026-08-25T23-03
- Reviewer: feature-review agent
- Branch: `bug/ci-coverage-targets-nonexistent-package-506-r2`
- Branch head at audit: `15db75d5b030fe4be2fe4edab9b9f1add0b8bf7a`
- Base branch (resolved): `origin/main` @ `8ca66c1db827cbfb59261ca0b85bb5b7a766908e`
- Merge base: `183ed0ada42ba437fb5cb49dac9057a6ace540b5`
- Diff form used: `git diff origin/main...HEAD` (three-dot)
- Work mode: `full-bug` (from `issue.md` line 13) — AC source of record is `spec.md` `## Acceptance Criteria`

## Scope of This Audit

The audited scope is the full branch diff against `origin/main`, plus the five uncommitted
working-tree paths named by the delegating prompt. No narrowing of scope was requested by the
caller and none was applied.

### Rejected Scope Narrowing

None. The delegating prompt supplied the full-branch scope, named the correct three-dot diff form,
and explicitly directed independent verification rather than acceptance of asserted evidence. No
instruction to skip a toolchain check, exclude a language, or limit the file set was present.

### Changed-file inventory

Forty-three files. Four are substantive; thirty-nine are feature documentation and evidence
confined to the feature folder.

| Path | Kind | Status |
| --- | --- | --- |
| `.github/workflows/_quality-checks.yml` | CI workflow | modified |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | Python production | added |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | Python test | added |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | Python test | added |
| `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/**` | documentation and evidence | 39 files |

Uncommitted working-tree paths audited alongside the committed diff:

- `.../spec.md` (modified — AC check-offs)
- `.../plan.2026-08-23T23-21.md` (modified — task ticks)
- `.../evidence/other/ac-evidence-index.md` (modified)
- `.../evidence/qa-gates/green-workflow-run.md` (untracked)
- `.../evidence/qa-gates/d3-fallback-disposition.md` (untracked)

### Language coverage applicability

| Language | Changed files on branch | Verdict required |
| --- | --- | --- |
| Python | 3 (1 production, 2 test) | explicit PASS/FAIL — see Coverage Verification |
| TypeScript | 0 | not applicable (zero changed files) |
| PowerShell | 0 | not applicable (zero changed files) |
| C# | 0 | not applicable (zero changed files) |

Verified by inspecting the changed-file inventory above. No `.ts`, `.ps1`, or `.cs` file appears in
the branch diff.

## Verdict Summary

| Policy | Verdict |
| --- | --- |
| `CLAUDE.md` — policy documents unmodified | PASS |
| `.claude/rules/general-code-change.md` | PASS |
| `.claude/rules/general-unit-test.md` | PARTIAL |
| `.claude/rules/general-unit-test.md` — Coverage Exclusion Policy | PASS |
| `.claude/rules/quality-tiers.md` — uniform coverage thresholds | PASS |
| `.claude/rules/python.md` | PASS |
| `.claude/rules/ci-workflows.md` | NOT APPLICABLE (trigger conditions not met) |
| `.claude/rules/benchmark-baselines.md` | NOT APPLICABLE (no `scripts/benchmarks/**` diff) |
| `modified-workflow-needs-green-run` | PASS at audited head, with a pre-merge action |
| `.claude/rules/tonality.md` | PASS |
| Evidence Location Invariant | PASS |
| File-size limit (500 lines) | PASS |
| Determinism infrastructure | PASS |
| Test file location | PASS |

Findings: **0 Blocking, 2 Non-blocking, 5 Advisory.**

## Evidence Location Compliance

`scripts/dev_tools/validate_evidence_locations.py --root .` exits **0**. No violations reported.

An independent scan of the branch diff for files written under `artifacts/baselines/`,
`artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` returned no matches. All evidence
produced by this feature is written under
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/<kind>/`
using the canonical kinds `baseline/`, `qa-gates/`, `regression-testing/`, and `other/`.

`spec.md` line 307 records an override rejection in the required form:

```
EVIDENCE_LOCATION_OVERRIDE_REJECTED: .../evidence/coverage/ replaced with .../evidence/qa-gates/
```

That is correct handling: `coverage/` is not among the canonical evidence kinds, and the executing
agent redirected rather than complying with the non-canonical path.

Verdict: **PASS.**

## Coverage Verification

Coverage artifacts were inspected rather than regenerated, per the evidence-verification model.

| Artifact | Present | Path |
| --- | --- | --- |
| Python coverage (lcov) | yes | `artifacts/python/lcov.info` |
| Python coverage (JSON) | yes | `artifacts/python/coverage.json` |

Both are gitignored (`git check-ignore -v` reports `.gitignore:6:/artifacts` for each), so they are
build artifacts and are correctly not committed.

### Repo-wide Python coverage

Read directly from `artifacts/python/coverage.json` by this reviewer:

| Metric | Measured | Floor | Margin | Verdict |
| --- | --- | --- | --- | --- |
| Line (`totals.percent_statements_covered`) | 92.64686292793392 | 85 | +7.65 | PASS |
| Branch (`totals.percent_branches_covered`) | 85.2161278605158 | 75 | +10.22 | PASS |
| `totals.num_statements` | 15014 | > 0 | — | PASS |

The denominator of 15,014 statements is the direct refutation of the reported defect: under the
pre-change command the denominator was zero and the coverage table printed no `TOTAL` row.

### Per-file coverage, new files

`scripts/dev_tools/check_python_coverage_thresholds.py`, read from the same JSON report:

| Metric | Measured | Floor | Verdict |
| --- | --- | --- | --- |
| Line | 59/61 statements = 96.72131147540983 | 85 (and 90 under the stricter new-file reading) | PASS |
| Branch | 12/14 = 85.71428571428571 | 75 | PASS |

The two uncovered statements are lines 230 and 236, and the two uncovered branch arcs are
`(229, 230)` and `(235, 236)`. These are the `raise CoverageReportError` bodies for the
"root is not a JSON object" and "carries no `totals` mapping" guards. See finding NB-2.

The two new test files are test code and are excluded from the coverage denominator by policy
(`.claude/rules/general-unit-test.md`, permitted `exclude` entries: `tests/**`).

### No regression on changed lines

| Metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| Line | 92.6302414231258 | 92.64686292793392 | +0.0166 |
| Branch | 85.21485797523671 | 85.2161278605158 | +0.0013 |

Baseline sourced from `evidence/baseline/corrected-coverage-command-repro.md`; post-change value
independently re-read by this reviewer from `artifacts/python/coverage.json` and confirmed
byte-identical to the figure recorded in `evidence/qa-gates/coverage-delta.md`. Both metrics rose.
No regression.

Verdict: **PASS** for Python. No other language has changed files on this branch.

## `modified-workflow-needs-green-run`

The branch diff modifies `.github/workflows/_quality-checks.yml`, so this rule fires. The rule
requires "a workflow run whose head SHA matches the current branch head and whose conclusion is
success for the affected workflow."

Verified live by this reviewer via `gh run view 32924210756`:

```json
{"conclusion":"success","databaseId":32924210756,
 "headBranch":"bug/ci-coverage-targets-nonexistent-package-506-r2",
 "headSha":"15db75d5b030fe4be2fe4edab9b9f1add0b8bf7a","status":"completed",
 "workflowName":"Quality Checks (reusable)","url":"https://github.com/drmoisan/drm-copilot/actions/runs/32924210756"}
```

- Affected workflow: `Quality Checks (reusable)` — the workflow the diff modifies. Match.
- Head SHA `15db75d5b030fe4be2fe4edab9b9f1add0b8bf7a` equals `git rev-parse HEAD`. Match.
- Conclusion `success`, status `completed`. Match.

Per-job and per-step conclusions, read from
`GET /repos/drmoisan/drm-copilot/actions/runs/32924210756/jobs`:

| Job | `Run tests with Pytest` | `Enforce Python coverage thresholds` | `Upload coverage to Codecov` |
| --- | --- | --- | --- |
| Code Quality & Tests (3.10) | success | success | skipped |
| Code Quality & Tests (3.11) | success | success | skipped |
| Code Quality & Tests (3.12) | success | success | skipped |
| Code Quality & Tests (3.13) | success | success | success |

This is direct runner evidence, not inference, that the new enforcement step executed and passed on
every Python matrix leg including the oldest (3.10). It settles the D3 matrix-scope question
empirically: the baseline was measured on 3.13 only, but the gate has now been observed passing on
all four interpreters. The pre-authorized narrowing fallback is correctly not exercised.

A second green run, `32923970683` at `08c9c14f6b1e93def5177a10910a12c4c12fee87`, exists against the
prior head. `evidence/qa-gates/green-workflow-run.md` records both runs and states plainly that the
delta between the two SHAs is Markdown only — no production, test, or workflow file — which is why
both runs exercise an identical build.

Verdict at the audited head: **PASS**. See finding NB-1 for the pre-merge action this verdict
depends on remaining true.

## `.claude/rules/ci-workflows.md` — deliberately-failing nested command

The rule's own Scope section binds it to a step that satisfies **both** conditions: the `run:`
block uses `shell: pwsh` (or the repo default `pwsh`), **and** the block intentionally invokes a
failing nested command.

Verified against the changed workflow:

1. **Shell.** `.github/workflows/_quality-checks.yml` declares `runs-on: ubuntu-latest` (line 10)
   and sets no `defaults.run.shell` and no per-step `shell:` key anywhere in the file (`grep` for
   `shell` returns no match). The effective shell is therefore the GitHub Actions default for Linux,
   `bash`, not `pwsh`. First condition not met.
2. **Deliberately-failing nested command.** Neither the revised `Run tests with Pytest` step nor the
   new `Enforce Python coverage thresholds` step invokes a command expected to fail. Each step's
   `run:` block is a single logical command spanning continuation lines. Second condition not met.

Both conditions fail, so the rule does not apply and no `$LASTEXITCODE` reset or explicit `exit 0`
is required. `spec.md` line 171 reached the same determination in advance and recorded it so a
reviewer would not raise it; this audit independently confirms it rather than adopting it.

A related point worth stating because it is the inverse of what the rule guards against: the
enforcement step's exit code **must** propagate, since that propagation is the entire mechanism of
the gate. Under GitHub Actions' default `bash -e` invocation, a single-command `run:` block
terminates with that command's exit status, so a non-zero return from
`check_python_coverage_thresholds` fails the step. This is confirmed indirectly by the module's own
unit tests, which assert the non-zero return for every breach and error condition, and directly by
the four green step conclusions above showing the zero-return path succeeding on the runner.

Verdict: **NOT APPLICABLE** — trigger conditions verified absent.

## `.claude/rules/general-unit-test.md` — Coverage Exclusion Policy

`pyproject.toml` does not appear in `git diff --name-only origin/main...HEAD` and does not appear in
`git status --porcelain`. It is unmodified in both the committed diff and the working tree, so
`[tool.coverage.run] source`, `[tool.coverage.run] omit`, and `[tool.coverage.report] exclude_lines`
are unchanged by this branch.

No new `exclude` or `omit` entry is introduced anywhere in the diff. No production source path is
excluded from measurement. The change moves in the opposite direction: it restores a 15,014-statement
denominator where the pre-change command measured zero.

Verdict: **PASS.**

## `.claude/rules/general-unit-test.md` — remaining requirements

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Independence | PASS | Each test builds its own report in a fresh `mem_fs_path` root; no shared mutable state. Contract tests read the committed workflow read-only. |
| Isolation | PASS | One behavior per test; the two files target distinct units (the checker module, the workflow document). |
| Fast execution | PASS | Both files complete in 0.08 s for 15 tests, measured by this reviewer. |
| Determinism | PASS | No `time`, `sleep`, `random`, `datetime`, or `tmp_path` token appears in either file (`grep` returns no match). No banned API present. |
| Readability | PASS | Descriptive `test_...` names, docstring per test naming scenario and expected outcome, explicit `# Arrange` / `# Act` / `# Assert` comments. |
| Arrange–Act–Assert | PASS | Every test in `test_check_python_coverage_thresholds.py` carries the three labelled sections. |
| No external dependencies | PASS | No network, database, or subprocess. |
| **No temporary files** | PASS | See the dedicated subsection below. |
| Test file location mirrors source | PASS | See the dedicated subsection below. |
| **Scenario completeness** | **PARTIAL** | Two error-handling paths are unexercised. See NB-2. |

### No temporary files — verified, not assumed

The unit-test policy prohibits creation and use of temporary files in tests outright. The tests
exercise file-backed paths (missing report, unparseable report) without violating it, and the
mechanism was verified rather than taken on trust:

- `tests/conftest.py` line 146 defines `mem_fs_path`, whose docstring states it is "a fully
  in-memory filesystem, not an on-disk temporary directory". It allocates a `memory_root` under a
  synthetic `/__pytest_mem__/<counter>` prefix and backs it with `files: dict[str, bytes]` and
  `directories: set[str]`, then `monkeypatch`es selected `pathlib.Path` methods for the duration of
  a single test.
- No test uses `tmp_path`, `tmpdir`, `tempfile`, or `NamedTemporaryFile`.

This is what makes finding NB-2's counterpart constraint load-bearing, and it is the subject of the
next subsection.

### The `Path.read_text` constraint — verified

`scripts/dev_tools/check_python_coverage_thresholds.py` line 216 reads the report with:

```python
report_text = report_path.read_text(encoding="utf-8")
```

The builtin `open` does not appear in the module, nor does `json.load` applied to a file object, nor
any `os`-level read. Verified by reading the full 324-line module.

This is not a stylistic preference; it is a correctness requirement created by the fixture. The
`mem_fs_path` fixture patches `pathlib.Path` methods, **not** the builtin `open`. A `load_totals`
implemented with `open` would bypass the in-memory store entirely, meaning the
`test_missing_report_file_exits_non_zero` and `test_unparseable_report_exits_non_zero` tests would
either touch the real filesystem or silently fail to exercise the intended path. The module docstring
(lines 38-43) records this reasoning explicitly, and the `load_totals` docstring restates it at the
point of use. The constraint holds and is correctly documented.

The two file-backed negative paths are genuinely exercised:

- `test_missing_report_file_exits_non_zero` names a path never written to the in-memory store. The
  fixture raises `FileNotFoundError`, which is a subclass of `OSError`, so the `except OSError` at
  line 217 catches it and the test asserts both a non-zero return and the report path in stderr.
- `test_unparseable_report_exits_non_zero` writes `"this content is not JSON"` into the in-memory
  store, so `json.loads` raises `JSONDecodeError` and the line 224 handler produces the naming
  message.

Both were confirmed passing by an actual run, not by reading alone.

### Test file location

`.claude/rules/general-unit-test.md` requires the test tree to mirror the production source
structure and forbids colocation in the production tree.

| Test file | Mirrors | Verdict |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | `scripts/dev_tools/check_python_coverage_thresholds.py` | PASS — exact mirror |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | `.github/workflows/_quality-checks.yml` | PASS — see below |

Neither file is colocated in a production source tree. The second file asserts on a document under
`.github/`, which a literal reading of the mirror rule would place at `tests/github/workflows/`. No
`tests/github/` tree exists in this repository, and the established in-repo precedent places such
contract tests under `tests/scripts/dev_tools/`:
`tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py` asserts on files under
`.github/agents/` from exactly that directory, computing `REPO_ROOT` from
`Path(__file__).resolve().parents[3]`. The new file follows that pattern precisely — same
`parents[3]` computation, same `read_repo_text` helper shape. `spec.md` D6 records this as a
deliberate decision with its alternative considered. Following one existing convention rather than
creating a second tree is the correct call.

Verdict: **PASS.**

## `.claude/rules/general-code-change.md`

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Simplicity first | PASS | One pure comparison, one loader, one thin `main`. No indirection beyond a single shared `_evaluate_metric` helper. |
| Separation of concerns | PASS | `find_threshold_breaches` is pure; `load_totals` is the sole I/O; `main` handles argument parsing and exit-code translation. The module docstring states this split as a responsibility. |
| Standalone functions over classes | PASS | The operations are pure transformations with no shared state; no class is warranted, and none is created beyond the `CoverageReportError` exception type. |
| Fail fast and explicitly | PASS | Five distinct error conditions each raise `CoverageReportError` with a message naming the report path, or return a specific breach message. |
| No broad catch-all | PASS | The only handlers are `except OSError` (line 217) and `except json.JSONDecodeError` (line 224), each narrow and each re-raised as `CoverageReportError` with added context. `main` catches only `CoverageReportError`. No bare `except:` and no `except Exception:`. |
| No silent error swallowing | PASS | Every failure path returns 1. There is no path on which an unread metric produces exit 0 — verified by reading every `return` in `main`. |
| Descriptive naming | PASS | `find_threshold_breaches`, `load_totals`, `LINE_PERCENT_KEY`, `DEFAULT_MIN_BRANCH`. |
| File size <= 500 lines | PASS | 324 / 188 / 157 lines. See table below. |
| No new dependency | PASS | Imports are `argparse`, `json`, `sys`, `pathlib`, `typing` — all standard library. The test files add `yaml`, already a project dependency. |
| I/O isolated from domain logic | PASS | `find_threshold_breaches` takes a parsed mapping and touches no filesystem; six of the nine checker tests could run with no file at all. |
| Change only what is needed | PASS | The workflow diff is 14 lines. Nine catalogued residual occurrences of the foreign token are deliberately deferred with rationale (`spec.md` D4) rather than folded in. |

### File-size limit

| File | Lines | Limit | Verdict |
| --- | --- | --- | --- |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | 324 | 500 | PASS |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | 188 | 500 | PASS |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | 157 | 500 | PASS |

Verdict: **PASS.**

## `.claude/rules/python.md`

Toolchain, verified independently by this reviewer against the three changed Python files rather
than by reading the recorded evidence alone:

| Stage | Command | Result |
| --- | --- | --- |
| Format | `poetry run black --check <3 files>` | exit 0 — "3 files would be left unchanged" |
| Lint | `poetry run ruff check <3 files>` | exit 0 — "All checks passed!" |
| Type check | `poetry run pyright <3 files>` | "0 errors, 0 warnings, 0 informations" |
| Test | `poetry run pytest <2 test files> -q` | 15 passed in 0.08s |

The recorded full-suite evidence is consistent with this spot check: `final-python-format-black.md`,
`final-python-lint-ruff.md`, `final-python-typecheck-pyright.md`, and `final-python-test-coverage.md`
each record `EXIT_CODE: 0`, and `toolchain-single-pass-transcript.md` records verdict PASS for the
single uninterrupted pass.

Coding standards:

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| PEP 8 naming | PASS | `snake_case` functions, `CONSTANT_CASE` module constants, `PascalCase` exception. |
| Complete type hints | PASS | Every function annotates all parameters and its return. Pyright clean under the project configuration. |
| No `Any` | PASS | The token `Any` does not appear. Untyped boundaries are narrowed with `cast("dict[str, object]", ...)` at the two `json`/`yaml` seams. |
| No suppressions | PASS | No `# noqa`, no `# type: ignore`, no `# pyright: ignore` in any of the three files. No pre-authorization is therefore required. |
| Absolute imports | PASS | `import scripts.dev_tools.check_python_coverage_thresholds as checker`. |
| Specific exceptions | PASS | `CoverageReportError(RuntimeError)` with a docstring stating when it is raised. |
| Internal helpers prefixed | PASS | `_evaluate_metric` is `_`-prefixed; the two public functions are the intended surface. |
| Docstrings | PASS | Module docstring carries Purpose / Responsibilities / Usage / Invariants / Side Effects. Every function carries Purpose / Args / Returns / Raises / Side Effects. |
| Dependency seams | PASS | `main(argv)` accepts an optional argument vector so tests drive the real entry point rather than a stand-in. |

**Considered and cleared — `print` versus `logging`.** The rule states "Use the standard `logging`
module. No ad-hoc `print` statements for permanent behavior." The module writes failure messages via
`print(..., file=sys.stderr)` (lines 309, 318). This is not treated as a violation, for three
reasons. First, the rule's target is library logging, not a CLI entry point's own diagnostic output;
for a command-line gate, stderr is the conventional and correct channel and `logging` would
interpose configuration between the failure and the operator reading the job log. Second, in-repo
precedent is overwhelming and specific: 23 modules under `scripts/dev_tools/` use
`print(..., file=sys.stderr)`, including `generate_codex_agent_variants.py`, which the *same
workflow* already invokes as a gate two steps earlier. Introducing a second convention for the
adjacent step would be the inconsistency. Third, `spec.md` line 203 records the choice with its
rationale. Recorded here so a later reviewer sees the question was asked and answered rather than
overlooked.

Verdict: **PASS.**

## `.claude/rules/quality-tiers.md`

The uniform-tier rule (Authoritative Decision #2) sets line >= 85% and branch >= 75% across T1-T4,
with no tier-specific lower threshold. This change does not alter any threshold; it makes the
existing thresholds enforceable in CI for the first time, and the floors passed on the command line
(`--min-line 85 --min-branch 75`) match the rule's two figures exactly. The module's argument
defaults are `DEFAULT_MIN_LINE = 85.0` and `DEFAULT_MIN_BRANCH = 75.0` (lines 65-66), so an
invocation that omits either option enforces policy rather than disabling that half of the gate —
the behavior `spec.md` line 218 requires.

The branch threshold is applied to Python, which is branch-capable. No PowerShell or bash branch
figure is demanded anywhere in the change.

Verdict: **PASS.**

## `.claude/rules/tonality.md`

The module docstrings, test docstrings, evidence artifacts, and `spec.md` use neutral, factual,
measured language. No humor, hyperbole, or decorative metaphor was observed. Evidence artifacts
state exit codes and measured values rather than characterizing outcomes. Notably,
`green-workflow-run.md` reports a process breach against the executing agents' own interest in plain
terms rather than minimizing it.

Verdict: **PASS.**

## Policy Documents Unmodified

`CLAUDE.md` forbids modifying files under `.github/instructions/`, and this agent additionally must
not modify `.claude/rules/`. Verified against the changed-file inventory: no path under
`.github/instructions/`, `.claude/rules/`, or `.claude/skills/` appears in the branch diff or in
`git status --porcelain`.

The four blocked policy files named in `spec.md` were each checked by exact path against
`git diff --name-only origin/main...HEAD`:

| File | Present in diff |
| --- | --- |
| `.github/instructions/python-unit-test.instructions.md` | absent |
| `.github/instructions/python-suppressions.instructions.md` | absent |
| `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md` | absent |
| `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md` | absent |

Verdict: **PASS.** The conflict these files create is escalated as a `human_interaction`
requirement with `response: scope_change` rather than resolved unilaterally, which is the correct
handling. See Advisory AD-4.

## Findings

### NB-1 — Non-blocking — Green-run binding will be invalidated by the pending commit

- **Rule:** `modified-workflow-needs-green-run` (`.claude/skills/feature-review-workflow/SKILL.md`
  lines 68-75).
- **Location:** branch head binding, not a file.
- **Statement.** At the head this audit was performed against, `15db75d5`, the rule is satisfied by
  run `32924210756`. The delegating prompt states that the orchestrator will commit the five
  uncommitted feature-folder paths together with the three audit artifacts this review produces.
  That commit moves the branch head off `15db75d5`, and the rule's matching condition is SHA-exact:
  "a workflow run whose head SHA matches the current branch head". The existing green run will then
  bind to an ancestor rather than to the head.
- **Impact.** Low in substance, exact in form. The delta introduced by that commit is Markdown only
  — spec check-offs, plan ticks, evidence artifacts, and audit artifacts — with no production, test,
  or workflow file, so it cannot change CI behavior. This is the same argument
  `evidence/qa-gates/green-workflow-run.md` makes for why runs `32923970683` and `32924210756`
  exercise an identical build, and it holds here for the same reason. The rule as written does not
  admit that argument, however, and it exists precisely as a second line of defense that does not
  rely on judgment about which deltas are safe.
- **Required action before merge.** After the final commit, either dispatch `_quality-checks.yml`
  against the new head and record a `success` conclusion whose head SHA equals it, or confirm the
  pull request's own CI run is green against that head, and append the run URL to
  `evidence/qa-gates/green-workflow-run.md`. Note that the same recursion applies to appending that
  evidence if it is committed; the practical resolution is the PR-context CI run against the final
  head, which is what the orchestrator's S9 CI green gate already checks.
- **Why not Blocking.** The rule is evaluated at the audited head and passes there. Nothing in the
  current tree requires rework. This is a sequencing obligation, not a defect, so it is recorded as
  a required pre-merge action rather than routed through the remediation handoff.

### NB-2 — Non-blocking — Two error-handling paths in `load_totals` are unexercised

- **Rule:** `.claude/rules/general-unit-test.md`, Scenario Completeness — "For each unit or
  behavior, tests must cover ... Error-handling behavior."
- **Location:** `scripts/dev_tools/check_python_coverage_thresholds.py` lines 229-232 and 235-238.
- **Statement.** Two of the five error conditions the module implements have no test:
  1. Lines 229-232: report root is valid JSON but is not an object (for example a top-level array or
     a bare string). Raises "Coverage report root is not a JSON object: {path}".
  2. Lines 235-238: report root is an object but `totals` is absent or is not a mapping. Raises
     "Coverage report carries no `totals` mapping: {path}".
- **Evidence.** `artifacts/python/coverage.json` reports `missing_lines: [230, 236]` and
  `missing_branches: [[229, 230], [235, 236]]` for this file. These are the module's *only*
  uncovered statements and its *only* uncovered branch arcs; covering them would take the module to
  100% line and 100% branch.
- **Why it matters beyond the percentage.** The second case is named explicitly in `spec.md` line
  197 as a validation the module must perform, in a list introduced by "each of which must fail
  loudly rather than pass silently". It is also the exact shape a *partially* written or truncated
  coverage report takes — a plausible real-world failure on a runner where pytest is interrupted
  mid-report — and it is the case in which a regression to a silent `return 0` would reproduce the
  original defect one layer up. The implementation is correct today; the gap is that nothing would
  catch a future edit that broke it.
- **Why not Blocking.** No acceptance criterion requires these two tests. AC-10 covers missing and
  unparseable reports, and both of those are tested. Repo-wide and per-file coverage floors are met
  with margin. The behavior is implemented correctly and reads correctly.
- **Suggested remedy.** Two tests in the existing file, following the established pattern, each
  writing a report body into `mem_fs_path` and asserting a non-zero return plus the report path in
  stderr:

  ```python
  # root is not a JSON object
  report_path.write_text(json.dumps([1, 2, 3]), encoding="utf-8")
  # totals is absent
  report_path.write_text(json.dumps({"files": {}}), encoding="utf-8")
  ```

### AD-1 — Advisory — `bool` is accepted as a numeric coverage value

- **Location:** `scripts/dev_tools/check_python_coverage_thresholds.py` line 117.
- **Statement.** `if not isinstance(value, int | float)` treats `bool` as numeric, because `bool`
  subclasses `int` in Python. A `totals` mapping carrying `{"percent_branches_covered": true}` would
  be coerced by line 120 to `1.0` and reported as "branch coverage 1.0 is below the required floor
  75.0" rather than as "branch data was not collected".
- **Impact.** Behaviorally safe: the gate fails closed in both interpretations, so no build passes
  that should fail. The only cost is a misleading diagnostic in a shape that `coverage.py` does not
  produce. Recorded for completeness, not because a fix is needed.

### AD-2 — Advisory — Comment wording invites misreading of the inclusive boundary

- **Location:** `scripts/dev_tools/check_python_coverage_thresholds.py` line 122.
- **Statement.** The comment reads "The comparison is strict, so a value exactly equal to the floor
  passes." The sentence is accurate — "strict" describes the `<` operator on line 123 — but "strict"
  is more commonly read as describing the gate, in which case the clause appears to contradict
  itself. Since the inclusive boundary is itself an acceptance criterion (AC-7), the comment guards
  a behavior a future editor might change.
- **Suggested wording:** "The comparison uses strict less-than, so a value exactly equal to the floor
  passes."

### AD-3 — Advisory — Latent test sensitivity to gitignored local state

- **Location:** `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (pre-existing test,
  not in this diff).
- **Statement.** The delegating prompt reports that one toolchain-loop restart in Phase 4 was caused
  by a gitignored local session file, `.claude/state/python-batch-budget.default.json`, tripping this
  test, which enumerates `.claude/` with `rglob` and consults no ignore file.
- **Impact.** Not caused by this diff and not a defect in this change. It is a real flakiness source
  for any agent working in a live worktree, and it produces a failure whose cause is invisible in the
  diff. Recommend filing a follow-up to have that enumeration respect `.gitignore`, or to scope it to
  tracked files via `git ls-files`.

### AD-4 — Advisory — Four policy files still publish the defective command

- **Location:** the four files listed in the Policy Documents Unmodified section above.
- **Statement.** These files publish
  `pytest --cov=src/lexile_corpus_tuner ...` as the approved Python test command. `CLAUDE.md`
  forbids modifying `.github/instructions/`, so they are correctly out of the write set, and the
  conflict is escalated as a `human_interaction` requirement with `response: scope_change`
  (`spec.md` line 243, `evidence/other/human-interaction-d5.md`).
- **Impact.** Until that decision is made, agents following those documents will continue to
  reproduce the defective command locally. CI is now protected regardless, because the workflow no
  longer reads from those documents. Recommend the user decision be scheduled rather than left open,
  since the defect this change fixes remains documented as approved practice elsewhere.

### AD-5 — Advisory — Codecov trend discontinuity should be called out in the PR body

- **Statement.** Prior Codecov uploads carried an empty `coverage.xml`. After this change the
  uploaded report carries real data for the first time, so the Codecov project history will show a
  discontinuity at this commit. `spec.md` line 248 documents this.
- **Impact.** A reviewer or watcher could misread the jump as a coverage change caused by this
  branch. Recommend the PR body state it explicitly.

## Process Deviations Observed

Recorded for the record. None is a code defect and none affects a verdict above.

1. **Phase-boundary commits.** The orchestration committed after each plan phase for resilience,
   whereas the plan's Phase 4 preamble assumed no commit existed yet. The three Phase 4 working-tree
   scope gates were consequently evaluated against the union of the working-tree list and the
   committed-diff list, with the substantive exclusions required to hold for both. That is a
   strictly stronger condition than either list alone, and the affected artifacts
   (`worktree-scope-pyproject.md`, `worktree-scope-blocked-policy-files.md`,
   `committed-diff-scope.md`) each record the adaptation. This reviewer verified the same exclusions
   independently against both lists and reached the same result.
2. **Commit-boundary breach.** Commit `15db75d5` was created after `[P6-T1]`, in breach of the
   plan's stated Phase 6 commit boundary. `evidence/qa-gates/green-workflow-run.md` lines 98-112
   report the breach plainly, including that a local mixed reset was attempted after the commit had
   already been pushed. The branch head is now `15db75d5` and it carries a valid green-run binding,
   so the breach is contained. The commit's content is Markdown only.
3. **Toolchain restart from external cause.** See AD-3.

## Assumptions

- The delegating prompt's account of the process deviations is taken as accurate; those are
  orchestration facts not fully reconstructible from the repository. Every technical claim in that
  prompt was independently verified and none was accepted on assertion.
- PR-context artifacts were absent at the start of this review and were regenerated by this reviewer
  with `scripts.dev_tools.pr_context.collector --base origin/main`. The regenerated summary confirms
  base `origin/main`, head `15db75d5`, and merge base `183ed0ad`, matching the git-derived scope used
  throughout.
