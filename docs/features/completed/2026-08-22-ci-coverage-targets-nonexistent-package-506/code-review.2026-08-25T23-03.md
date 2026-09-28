# Code Review — Issue #506, CI coverage targets a nonexistent package

- Timestamp: 2026-08-25T23-03
- Reviewer: feature-review agent
- Branch: `bug/ci-coverage-targets-nonexistent-package-506-r2` @ `15db75d5`
- Base: `origin/main` @ `8ca66c1d`, merge base `183ed0ad`
- Files reviewed: 4 substantive (1 workflow, 1 Python production, 2 Python test)

## Summary

The change is small, well-targeted, and correctly diagnosed. The 14-line workflow diff plus a
324-line module fixes a defect that had silently disabled the repository's Python coverage signal.
The implementation quality is high: the pure/impure split is clean, error handling is specific and
fails closed on every path, the type surface is complete, and the tests drive the real entry point
rather than a stand-in.

Two observations are worth acting on. One is a two-test coverage gap on the module's least-exercised
error paths (NB-2 in the policy audit). The other is a sequencing obligation around the green-run
binding (NB-1). Neither indicates a defect in the code as written.

The most notable strength of this change is the quality of its root-cause analysis. The original
issue asserted two independent faults; the spec demonstrates from installed library source that
there was exactly one, and that the second claimed fault was false. That correction changed the
remedy — from "convert the value to dotted form" to "name no target and let the configuration own
the scope" — and the resulting fix is smaller and lower-drift than the one originally proposed.
Similarly, decision D2 identifies a trap that would have defeated the obvious implementation:
`--cov-fail-under` with `--cov-branch` active gates a combined statements-plus-branches ratio that
no repository policy defines, which is weaker than the line requirement and enforces nothing on
branches. Rejecting the one-flag solution in favor of a testable module was the correct call and the
reasoning is recorded where a future maintainer will find it.

## `.github/workflows/_quality-checks.yml`

### The pytest step

```yaml
      - name: Run tests with Pytest
        run: |
          poetry run pytest --cov --cov-branch \
            --cov-report=xml \
            --cov-report=json:artifacts/python/coverage.json \
            --cov-report=term-missing
        continue-on-error: false
```

**Assessment: sound.** The bare `--cov` form is the correct fix. Per the spec's traced mechanism,
`pytest_cov`'s `_prepare_cov_source` returns `None` for the bare form, so
`coverage/config.py::from_args` skips the assignment and the configured
`[tool.coverage.run] source = ["src", "scripts/dev_tools"]` survives. An explicit `--cov=VALUE`
*overwrites* that list, which is why naming a nonexistent target discarded a correct configuration
and measured zero files.

The choice not to restate the scope on the command line is the right one on maintainability grounds:
restating it would create a drift surface between `pyproject.toml` and the workflow that must then
be kept in agreement, and the bare form is byte-compatible with the command already prescribed by
`.claude/rules/python.md` and `.claude/skills/python-qa-gate/SKILL.md`. Local and CI runs now measure
an identical denominator, which makes a developer's local-versus-CI comparison meaningful for the
first time.

`--cov-branch` is required, not optional: without it `percent_branches_covered` is absent from the
JSON report entirely, and the branch half of the policy would be unmeasurable. The module treats that
absence as a hard failure rather than a pass, which closes the loop — see the `find_threshold_breaches`
discussion below.

One implementation detail that could have failed and did not: `--cov-report=json:artifacts/python/coverage.json`
names a directory that does not exist in a fresh runner checkout. Whether `coverage.py` creates the
parent directory is not something local review can establish from the YAML. It is settled empirically
by the green run — the step concluded `success` on all four matrix legs, and the subsequent enforcement
step read the file successfully on all four — so no `mkdir -p` step is needed. Worth noting because it
is exactly the class of workflow behavior `.claude/rules/ci-workflows.md` exists to flag as
locally-unverifiable.

### The enforcement step

```yaml
      - name: Enforce Python coverage thresholds
        run: |
          poetry run python -m scripts.dev_tools.check_python_coverage_thresholds \
            --report artifacts/python/coverage.json \
            --min-line 85 --min-branch 75
        continue-on-error: false
```

**Assessment: sound.** Placement immediately after the pytest step is correct — it reads that step's
output and must not run before it. `continue-on-error: false` is explicit and matches the surrounding
steps, though it is also the default.

The floors are passed at the call site rather than embedded, so the two numbers the gate enforces are
visible in the workflow to anyone reading it, and they match `.claude/rules/quality-tiers.md` exactly.
The module nonetheless defaults them to the same values, so an edit that dropped either flag would not
weaken the gate. That belt-and-braces arrangement is good design for a gate whose failure mode is
silent permissiveness.

The step carries no `if:` key, so it runs on every matrix leg. This is the point most worth scrutiny,
because the local baseline was measured on Python 3.13 only and version-gated branches can shift the
branch figure. The decision to run everywhere is correct on principle — `.claude/rules/quality-tiers.md`
states the floors unconditionally and not per interpreter version, so the floor must hold on the worst
leg, and a regression that appears only on 3.10 is precisely the class of defect a 3.13-pinned gate
would miss. It is also now correct in fact: run `32924210756` records
`Enforce Python coverage thresholds => success` on 3.10, 3.11, 3.12, and 3.13 individually. The gate
has been observed passing on the oldest interpreter, not merely assumed to. The D3 narrowing fallback
is correctly left unexercised and `test_threshold_step_is_narrowed_to_the_pinned_leg` was correctly
not authored.

### The Codecov step

`file: ./coverage.xml` becomes `files: ./coverage.xml`. `file` is not a declared input of
`codecov/codecov-action@v7`; `files` is. This is a one-token correctness fix in the same step group,
appropriately bundled. The spec is careful to describe it as a correctness fix rather than a repair of
an observed failure, since the action's own discovery may have located the file regardless — an honest
framing.

`fail_ci_if_error: false` is retained. D7 justifies this: no `token` input is configured and no
`CODECOV_TOKEN` reference exists, so uploads are tokenless and rate-limited, and flipping the flag
would convert an external-service flake into a merge blocker. Correct to leave alone and correct to
say why.

## `scripts/dev_tools/check_python_coverage_thresholds.py`

324 lines, of which 61 are executable statements. The remainder is docstring and comment, which is a
high ratio but appropriate for a module whose entire purpose is to encode a policy rule that a future
maintainer must not accidentally weaken.

### Structure

The three-way split is the design the spec called for and it is executed cleanly:

- `find_threshold_breaches(totals, *, min_line, min_branch) -> list[str]` — pure. Takes a parsed
  mapping, touches no filesystem, mutates nothing, returns one message per failure.
- `load_totals(report_path) -> Mapping[str, object]` — the module's sole I/O.
- `main(argv) -> int` — argument parsing and exit-code translation.

Six of the nine unit tests could in principle run with no file at all, because the comparison logic is
reachable without the loader. That is the practical payoff of the split.

`_evaluate_metric` is a good factoring: it expresses the absent-value rule and the inclusive-floor rule
exactly once, so the two metrics cannot drift apart. Passing `absent_message` and `breach_label` as
keyword arguments keeps the metric-specific wording at the call site where it reads naturally.

### Error handling

Five distinct failure conditions, each producing a specific message and a non-zero return:

| Condition | Line | Message names |
| --- | --- | --- |
| File missing or unreadable | 217-220 | report path, underlying OS error |
| Content not valid JSON | 224-227 | report path, decode error |
| Root not a JSON object | 229-232 | report path |
| `totals` absent or not a mapping | 235-238 | report path |
| Metric absent or non-numeric | 117-118 | the metric and, for branches, the likely cause |

The two handlers are `except OSError` and `except json.JSONDecodeError` — both narrow, both re-raised
as `CoverageReportError` with added context via `from error`. There is no bare `except:` and no
`except Exception:` anywhere in the module. `main` catches only `CoverageReportError`.

The critical property for a gate of this kind is that **no path returns 0 on an unread metric**. I
traced every `return` in `main`: line 310 returns 1 on load failure, line 320 returns
`1 if breaches else 0`, and `find_threshold_breaches` appends a message for an absent metric rather
than skipping it. The property holds. The inline comment at lines 302-305 states the invariant
explicitly, which is worth having — it tells a future editor what must not be broken, not merely what
the code does.

The absent-branch-data message deserves specific credit:

```
branch data was not collected: the report totals carry no numeric
`percent_branches_covered` value, which is the shape produced when the
branch measurement flag was omitted.
```

It names the condition, the key, and the likely cause. An operator reading a red CI job learns from
that message what to do. This is the defense against a future edit that drops `--cov-branch` and
silently disables half the gate, and it is tested (`test_absent_branch_data_exits_non_zero`).

### The `Path.read_text` constraint

Line 216 uses `report_path.read_text(encoding="utf-8")`. The builtin `open` does not appear in the
module. This is a hard requirement rather than a style choice, and the module docstring (lines 38-43)
explains why at the top of the file where it will be read before an edit: the `mem_fs_path` fixture
patches `pathlib.Path` methods and *not* the builtin `open`, so a loader written with `open` would
bypass the in-memory store and either touch the real filesystem — which the unit-test policy prohibits
outright — or silently stop exercising the negative paths. Restating the constraint in the
`load_totals` docstring at the point of use is the right redundancy.

### Typing

Complete annotations throughout; Pyright reports 0 errors, 0 warnings on the file. The `Any` token does
not appear. The untyped `json.loads` boundary is narrowed with `cast("dict[str, object]", ...)` after an
`isinstance` check rather than by suppression, so the cast is always preceded by a runtime guarantee.
No `# type: ignore` and no `# noqa` anywhere, so no suppression pre-authorization is needed.

`if TYPE_CHECKING: from collections.abc import Mapping, Sequence` keeps the runtime import surface
minimal, consistent with the module's stated no-new-dependency constraint.

### Observations

**AD-1 — `bool` accepted as numeric (Advisory).** Line 117's `isinstance(value, int | float)` accepts
`bool`, since `bool` subclasses `int`. A `totals` value of `true` would be coerced to `1.0` at line 120
and reported as a floor breach rather than as "not measured". The gate fails closed either way, so no
build passes that should fail; the only cost is a misleading message in a shape `coverage.py` does not
emit. Not worth changing on its own, but if the file is edited for another reason, `isinstance(value, bool)`
as an early rejection would tighten it.

**AD-2 — comment wording (Advisory).** Line 122 reads "The comparison is strict, so a value exactly
equal to the floor passes." Accurate — "strict" describes the `<` operator on the next line — but
"strict" reads more naturally as describing the gate, in which case the clause looks self-contradictory.
Since the inclusive boundary is an acceptance criterion in its own right (AC-7), the comment is guarding
a behavior a future editor might invert. Suggest: "The comparison uses strict less-than, so a value
exactly equal to the floor passes."

**NB-2 — two untested error paths (Non-blocking).** Lines 230 and 236 are the module's only uncovered
statements, and arcs `(229, 230)` and `(235, 236)` its only uncovered branches. They are the raise
bodies for "root is not a JSON object" and "carries no `totals` mapping". The second is named in
`spec.md` line 197 among the validations that "must fail loudly rather than pass silently", and it is
the shape a truncated or partially-written report takes — a plausible runner failure. The implementation
is correct; the gap is that nothing would catch a future edit that broke it. Two tests in the existing
file's pattern would close it and take the module to 100% on both metrics. Detail and suggested test
bodies are in the policy audit.

## `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py`

188 lines, nine tests, all passing (verified: 15 passed in 0.08s across both new files).

**Strengths.**

Every test drives `checker.main([...])` — the real entry point the workflow invokes — and asserts on
the exit code the workflow step actually observes. This is materially better than testing
`find_threshold_breaches` directly, because it exercises argument parsing, the loader, the comparison,
and the exit-code translation as one unit, which is the behavior that matters. The file docstring states
this intent.

Boundary coverage is complete and deliberate: 85.0 and 75.0 exactly (must pass), 84.9 and 74.9 (must
fail). The at-floor tests pair the boundary metric with a comfortably-above value for the other metric,
so a failure isolates which floor was misapplied.

`test_both_metrics_below_floor_are_both_reported` asserts both metric names appear in the same stderr
capture. This tests a real design property — that the module reports the full picture in one CI run
rather than surfacing one breach, then the next on the following run — and it is the kind of property
that is easy to regress by an early `return`.

Assertions on message content (`"line coverage" in captured.err`,
`"branch data was not collected" in captured.err`) mean a message that degraded to a bare stack trace
would fail the test, not merely a wrong exit code. That is the right level of assertion for a
diagnostic-quality requirement.

The `_write_report` helper keeps each test's Arrange section to one call and one dict literal, so the
scenario under test is visible at a glance.

**Determinism and hygiene.** No `time`, `sleep`, `random`, `datetime`, `tmp_path`, `tmpdir`, or
`tempfile` token appears in the file — verified by grep, not by reading alone. No banned API from the
determinism infrastructure list is present. Every test builds its own report in a fresh `mem_fs_path`
root, so order independence holds.

**No temporary files.** The two file-backed negative paths use the in-memory `mem_fs_path` fixture
(`tests/conftest.py` line 146), which backs `pathlib.Path` operations with an in-process dict and set
via `monkeypatch`. `test_missing_report_file_exits_non_zero` names a path never written to that store,
producing a `FileNotFoundError` that the module's `except OSError` catches;
`test_unparseable_report_exits_non_zero` writes non-JSON bytes into it. Both paths are genuinely
exercised, and both were confirmed passing by an actual run rather than by inspection. The prohibition
on temporary files in tests is satisfied in substance, not merely in letter.

**Gap.** NB-2, above.

## `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`

157 lines, six tests, all passing.

**Strengths.**

The helper layer is the best part of this file. `step_named`, `step_running`, and `step_using` each
assert `len(matches) == 1` with a message naming the count found. That converts two silent failure
modes into loud ones: a step that was renamed produces "expected one step named X, found 0" rather than
a `KeyError` or a vacuous pass, and a duplicated step produces "found 2" rather than an assertion
against an arbitrary match. For a contract test whose whole value is catching drift in a file it does
not own, this matters — a contract test that silently matches nothing is exactly the class of
unfalsifiable gate `.claude/rules/plan-acceptance-gates.md` was written about.

Parsing with `yaml.safe_load` and asserting on the resulting structure is stronger than text matching
for the structural claims. `test_codecov_step_uses_the_declared_files_input` asserts both `"files" in
with_mapping` and `"file" not in with_mapping`; the negative half is what actually prevents a
regression, since adding `files` while leaving `file` in place would satisfy the positive assertion
alone.

`run_tokens` uses `shlex.split`, which handles the YAML block scalar's backslash continuations
correctly and yields real argv tokens. `test_threshold_step_invokes_the_checker_with_both_floors` then
asserts adjacency — `tokens[tokens.index("--min-line") + 1] == "85"` — rather than mere presence, so a
flag separated from its value, or paired with the wrong value, fails. That is the correct strictness
for a test whose subject is a policy floor.

`test_pytest_step_uses_bare_cov_with_branch` asserts `pinned == []` for tokens starting with `--cov=`
rather than checking for the single known-bad value. This generalizes correctly: any future
reintroduction of an explicit target — not just `src/lexile_corpus_tuner` — fails the test. Pairing it
with `test_workflow_names_no_foreign_coverage_target`, which does a case-insensitive text search for
the specific foreign token, gives one general guard and one specific one.

The `REPO_ROOT = Path(__file__).resolve().parents[3]` computation and the `read_repo_text` helper
follow `test_orchestrator_direct_command_contracts.py` exactly, which is the in-repo precedent for
asserting on files under `.github/` from `tests/scripts/dev_tools/`. Consistency with an existing
convention is preferable to introducing a `tests/github/` tree for one file.

`test_threshold_step_runs_on_every_matrix_leg` asserting `"if" not in step` is the correct encoding of
decision D3: it is a structural fact about the committed YAML, checkable without running anything, and
it will fail loudly if someone later narrows the step without also revisiting the decision.

**Observations.**

The `cast` calls in `load_workflow_steps` are necessary at the `yaml.safe_load` boundary and are
isolated to that one function, with a docstring saying so. That is the right containment for an untyped
boundary.

`step_running` matches on substring containment in the `run` value. A second step that happened to
mention `check_python_coverage_thresholds` in a comment would trip the `len == 1` assertion. That is
the safe direction to fail and needs no change.

## Toolchain Verification

Independently re-run by this reviewer against the three changed Python files rather than read from
the recorded evidence:

| Stage | Command | Result |
| --- | --- | --- |
| Format | `poetry run black --check <3 files>` | exit 0, "3 files would be left unchanged" |
| Lint | `poetry run ruff check <3 files>` | exit 0, "All checks passed!" |
| Type check | `poetry run pyright <3 files>` | 0 errors, 0 warnings, 0 informations |
| Test | `poetry run pytest <2 test files> -q` | 15 passed in 0.08s |

Consistent with the recorded full-suite evidence (`final-python-*.md`, each `EXIT_CODE: 0`;
`toolchain-single-pass-transcript.md`, verdict PASS; 4136 passed, 5 skipped).

`actionlint` on the modified workflow: `EXIT_CODE: 0`, zero findings
(`evidence/qa-gates/final-workflow-actionlint.md`), matching the pre-change baseline, so the workflow
edits introduced no new finding.

## Recommendations

Ordered by value.

1. **Add the two missing error-path tests** (NB-2). Closes the module's only coverage gap and locks in
   a validation the spec names explicitly. Low effort, follows the existing pattern.
2. **Re-establish the green-run binding after the final commit** (NB-1). Required before merge; see the
   policy audit for the exact condition.
3. **Note the Codecov trend discontinuity in the PR body** (AD-5). The first populated report after a
   history of empty ones will show a jump that a reviewer could misread.
4. **Reword the line 122 comment** (AD-2). Cosmetic, but it guards an acceptance criterion.
5. **File the follow-up for `.claude/` enumeration sensitivity to gitignored files** (AD-3). Not this
   change's defect, but it cost a toolchain restart during this work and will cost others.
6. **Schedule the D5 human-interaction decision** (AD-4). CI is protected now, but four policy documents
   still publish the defective command as approved practice.

Items 4 and 6 are optional with respect to this change. Items 1, 3, and 5 are follow-ups. Item 2 is a
merge precondition.

## Verdict

**Approve, subject to the NB-1 pre-merge action.**

The code is correct, well-structured, well-typed, well-tested, and well-documented. The diagnosis
behind it is stronger than the issue report that prompted it, and the two traps that would have
defeated a naive fix — the `--cov=` overwrite semantics and the `--cov-fail-under` combined-ratio
behavior — were both identified and avoided. No Blocking finding was raised.
