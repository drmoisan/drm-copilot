# Code Review — issue #519, plan acceptance gates G7/G8/G8b/G9

- Timestamp: 2026-08-26T10-50
- Branch: `bug/plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519-r3`
- Branch head: `2aa37434`; base `1e991b86`
- Scope: full branch diff, 71 files (+8161 / −18). Source and test changes are 3 Python modules,
  5 Python test modules, 3 TypeScript modules, 5 TypeScript test modules, 1 Jest config,
  4 policy documents (2 originals + 2 mirrors), and 47 evidence artifacts.

## Summary

The implementation is well-designed and unusually well-evidenced. Design principles are followed
in priority order: the rule group is expressed as data (`WriteModeEntry` / `WriteModeShape`)
rather than as per-tool callables, which is what makes the six register entries transcribable
across two runtimes without porting behaviour; I/O is confined to one seam call per evaluation;
and the new module decides commands only and never constructs a report or a context, keeping the
runtime import graph to a single new acyclic edge.

Two Major issues are worth acting on, both about what the tests do *not* pin rather than about
what the code does. Neither blocks merge.

**Blocking findings: 0. Major: 2. Minor: 5. Commendations: 4.**

## Verdicts by area

| Area | Verdict |
|---|---|
| Design — simplicity, reusability, extensibility, separation of concerns | PASS |
| Error handling and graceful degradation | PASS |
| Naming | PASS |
| Public API and backward compatibility | PASS (one TypeScript nuance, MINOR-3) |
| Dependencies | PASS — none added |
| I/O boundaries | PASS |
| Cross-runtime parity — message strings | PASS |
| Cross-runtime parity — register data | PARTIAL (MAJOR-2) |
| Test quality — structure, isolation, determinism | PASS |
| Test quality — scenario completeness | PARTIAL (MAJOR-1) |
| Whether the tests can fail | PASS, with one qualification |
| File-size limit | PASS |
| Documentation and comments | PASS |

## Cross-runtime parity — the point scrutinised hardest

### Message strings: PASS

The two implementations produce byte-identical finding strings for the fixtures under test, and
the parity mechanism is the same one the pre-existing G1–G6 rules use.

Sixteen parity fixtures are duplicated verbatim across
`tests/scripts/dev_tools/test_plan_gate_parity.py` and
`extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts`, eight of them new
(`PARITY_G7`, `PARITY_G8`, `PARITY_G8B`, `PARITY_G9`, plus an apostrophe-bearing twin of each).
Each row carries its rule's severity constant, so the assertion follows the channel rather than
hard-coding it — meaning a future severity change relocates the assertion instead of breaking the
row. Both files assert exact list equality on both channels, so an extra or missing finding fails.

**Apostrophe fixtures are present for all four new rules**, which was the specific case the
prohibition exists for:

```
PARITY_G7_APOSTROPHE = _parity_plan('poetry run black "dan\'s_tools"')
PARITY_G8_APOSTROPHE = _parity_plan('git diff -- "dan\'s_tools"')
PARITY_G8B_APOSTROPHE = _parity_plan('git diff --name-only main -- "dan\'s_tools"')
PARITY_G9_APOSTROPHE = _parity_plan('poetry run pytest "--cov=dan\'s_tools.foo"')
```

with the identical set in the TypeScript file (lines 63-70) and identical expected strings built
by `_expected_g7`/`expectedG7` and siblings. Each apostrophe sits inside double quotes so the
shell-word split succeeds and the rendered span keeps its quotes verbatim — a detail that is
commented in both files.

**Message-formatting prohibitions hold, verified directly:**

```
grep -c "repr("      scripts/dev_tools/plan_gate_observability.py                      -> 0
grep -c "!r"         scripts/dev_tools/plan_gate_observability.py                      -> 0
grep -c "pythonRepr(" extensions/.../src/lib/validate/plan-gate-observability.ts       -> 0
```

Both new modules are registered in their runtime's prohibition list —
`_PYTHON_GATE_MODULES` gains `plan_gate_observability.py`
(`test_plan_gate_parity.py:45-49`) and `GATE_MODULE_PATHS` gains
`plan-gate-observability.ts` (`plan-gate-parity.test.ts:314-319`) — so the check covers the new
files rather than only the old ones. Both prohibition tests pass.

I also read the two implementations against each other line by line for semantic divergence in
the constructs that most often differ. All four checked out:

- `taskText.replace(rawSpan, " ")` in TypeScript replaces only the first occurrence when the
  pattern is a string, matching Python's `.replace(..., 1)`. The replacement is a literal space,
  so no `$`-pattern expansion applies.
- `gitDiffIndex` omits Python's explicit `index + 1 < len(argv)` bound; an out-of-range index
  yields `undefined`, which is not `"diff"`, so the behaviour matches.
- `shapeMatches` renders Python's truthiness test `if shape.suffix:` as
  `shape.suffix !== undefined && shape.suffix !== ""`, which is exactly the same partition.
- `ADDOPTS_PATTERNS` carries no `g` flag, so `RegExp.exec` has no `lastIndex` statefulness, and
  `[^"]*` matches newlines in both dialects (no `s`/`DOTALL` divergence). The constructs are
  restricted to literal text, character classes, and `*`, as the module comments claim.

The one behavioural divergence I could construct is in `projectAddopts`: Python tests
`if not text` (which also catches `None`), TypeScript tests `if (text === "")`. If the seam ever
returned `null`/`undefined` the two would differ. The seam's declared return type is `string`, so
this is not reachable today; recorded as MINOR-4.

### Register data: PARTIAL — MAJOR-2

`spec.md:207` states the write-mode register is "duplicated across the two runtimes and pinned
equal by a parity assertion". What ships is weaker.

What *is* pinned:

- Each entry's argv *shape*, indirectly. The six-element fixture lists in
  `test_plan_gate_observability.py:28-35` and `plan-gate-observability.test.ts:41-48` are
  mirrored, and each runtime's register-completeness test asserts set equality between the
  fixture names and `WRITE_MODE_REGISTER` names plus a per-entry firing assertion. A shape
  divergence breaks one side.
- `black-write`'s markers, via `PARITY_G7` and each runtime's single exoneration test (which
  uses the marker `left unchanged`).

What is **not** pinned:

- The `markers` tuples of `ruff-fix`, `prettier-write`, `poshqc-format`,
  `poshqc-analyze-autofix`, and `poshqc-suite`. No test in either runtime supplies any of those
  markers, and no cross-runtime comparison of the tuples exists.
- Every entry's `excludes` tuple, in both runtimes (see MAJOR-1).

A marker string edited in one runtime and not the other would ship silently. The fix is small and
follows an existing pattern: a register-content parity assertion in the same shape as the four
`test_g*_severity_constant_matches_typescript` assertions, reading the TypeScript literal and
comparing it against the Python tuple.

## MAJOR-1 — Three negative flows in the new rule module are unreachable by any test

This is evidenced by the coverage tooling's own missing-line lists, not inferred:

```
scripts\dev_tools\plan_gate_observability.py  139  4  62  5  96%  250, 397->395, 399, 414, 422
plan-gate-observability.ts                    98.38  91.91  100  98.38  253-254,413-414,430-431,441-442
```

**(a) The `excludes` mechanism is never exercised** — `plan_gate_observability.py:249-250`,
`plan-gate-observability.ts:252-254`:

```python
for entry in WRITE_MODE_REGISTER:
    if any(excluded in argv for excluded in entry.excludes):
        continue          # <- line 250, uncovered
```

This is what stops G7 reporting `black --check`, `black --diff`, and `ruff check --no-fix` — the
read-only forms this repository's own authoring guidance instructs plans to use, and the forms
this feature's own plan uses in [P0-T4] and [P0-T5]. A change that emptied every `excludes` tuple
would pass the entire suite in both runtimes.

Verification: `grep -n "no-fix\|--check" tests/scripts/dev_tools/test_plan_gate_observability*.py extensions/drm-copilot/test/lib/validate/plan-gate-observability*.test.ts`
returns nothing (exit 1).

**(b) The single-quoted `addopts` pattern is dead in test** — `plan_gate_observability.py:395-399`.
The uncovered branch `397->395` is the loop continuing past the first pattern, so
`_ADDOPTS_PATTERNS[1]` is never reached, and line 399 (`return ""`, the read-but-no-assignment
case) is never reached either. TypeScript mirrors this at 413-414.

This one matters more than its size suggests. `spec.md:366` names cross-runtime regex-dialect
divergence as a risk precisely because this is the first gate predicate to run a pattern over
file content, and `spec.md:375` states the mitigation as "add a parity fixture whose
configuration value exercises quoting and whitespace variation". Both runtimes' parity fixtures
use only the double-quoted form:

```
_PARITY_PROJECT_TEXT = 'addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"'
```

so the stated mitigation was not delivered. The regexes are visually identical and I read them as
equivalent, but the risk the spec identified is unmeasured.

**(c) G9's project-supplies-a-reporter exoneration is never exercised** —
`plan_gate_observability.py:421-422`, `plan-gate-observability.ts:440-442`. No test supplies an
`addopts` value containing `--cov-report=term`, so the branch that the entire `addopts` read
exists to serve is untested. Every G9 test uses the project's real value, which supplies only an
LCOV reporter.

**Recommended remedy**, four small tests per runtime:

1. `poetry run black --check .` in a marker-free task produces zero G7 findings.
2. `poetry run ruff check --no-fix .` in a marker-free task produces zero G7 findings.
3. A parity fixture whose project text is `addopts = '-ra --cov-report=lcov:...'`
   (single-quoted, with whitespace variation) produces the same G9 finding in both runtimes.
4. A project text containing `--cov-report=term-missing` produces zero G9 findings.

Items 1, 2, and 4 additionally close (a) and (c). None requires a new mechanism.

## Whether the new rules can actually fail — and whether this feature's own gates can

This feature exists to catch acceptance conditions that cannot fail, so its own tests and gates
deserve the same test. My assessment is that they can, with one qualification.

**The rules fire, verified end to end against a real repository context.** I constructed a probe
plan in the scratchpad and evaluated it through the shipped entry point with a real
`build_plan_gate_context`:

```
BLOCKING 0
WARNINGS 4
  [P1-T1] write-mode command `poetry run black .` rewrites tracked source and exits 0 ...
  [P1-T1] git diff span `git diff --exit-code -- scripts` carries no ref operand ...
  [P1-T3] name-listing diff `git diff --name-only main -- scripts` never reports ...
  [P1-T2] coverage command `poetry run pytest --cov=scripts.dev_tools.foo` supplies no ...
```

All four rules produced a finding. Against the committed corpus my independent driver reproduced
G7 466 / G8 82 / G8b 19 / G9 8, matching the recorded measurement exactly. These rules are not
inert.

**Positive and negative tests are paired, which is what makes the empty-list assertions
meaningful.** Many boundary tests assert `report.warnings == []`. Alone, such an assertion cannot
distinguish "the rule correctly declined" from "the rule never ran". Each is paired with a
positive test on the same rule in the same file — for example
`test_g9_skipped_when_repository_seam_raises` (asserts empty) sits alongside
`test_g9_reports_coverage_command_without_terminal_reporter` (asserts the exact finding string),
and `test_single_token_tool_name_span_produces_no_findings` sits alongside the six-entry
`_REGISTER_FIXTURES` loop that uses two-word forms. The pairing is deliberate and consistent.

**The prohibition tests can fail.** `test_no_repr_formatting_in_gate_messages` asserts the
absence of `!r` and `repr(` in three tracked module files; introducing either string fails it.
Its TypeScript companion does the same for `pythonRepr(` across four files.

**Qualification: the three untested negative flows in MAJOR-1 are places where the suite would
*not* catch a regression.** Emptying every `excludes` tuple, or breaking the single-quoted
`addopts` pattern, passes the suite. That is the honest answer to "can its own tests fail" — for
those three paths, no.

**This feature's own plan is genuinely self-applying.** Evaluated through the shipped entry point
with a real context, `plan.2026-08-23T23-22.md` produces `BLOCKING 0, WARNINGS 0` — from all
nine rules, not only the four new ones. That is a non-vacuous result: the plan contains 33 lines
matching write-mode, git-diff, or coverage constructs, and it clears them by using
`black --check`, `ruff check --no-fix`, `git diff main`, and explicit `--cov-report=term-missing`
rather than by avoiding the constructs.

One structural caveat, disclosed by the plan itself at line 52: the two frozen defective fixture
spans are quoted in the *document preamble* so the extractor drops them. The use is legitimate —
those spans define fixture text, not acceptance conditions — and it is stated openly. It does
illustrate that an author can place a genuinely defective span outside every attribution window
and no rule can report it. That follows from the pre-existing window design documented in the
rule file, not from this change.

## Design and implementation

### Commendations

**C-1 — The register is data, not code.** `WriteModeEntry` and `WriteModeShape` express each
tool's argv predicate declaratively, so the TypeScript copy is a transcription rather than a
port. This is the single decision that makes cross-runtime parity tractable for six tools, and it
is the right call. The `shapes` / `excludes` / `markers` decomposition also makes the false
positives the corpus measurement found (`npm run format -- --check`) diagnosable as a missing
`excludes` entry rather than as a defect in logic.

**C-2 — The self-exoneration trap is closed.** Both marker matching and companion-span matching
remove the offending span from the window once before searching:

```python
remainder = command.task_text.replace(command.raw_span, " ", 1)
```

Without this, a `git diff` span would always find "a `git diff` span in the task text" — itself —
and G8 could never fire. The reasoning is stated in a comment at each site
(`plan_gate_observability.py:261-268`, `307-315`; `plan-gate-observability.ts:262-272`), and the
TypeScript side factors it into a shared `taskTextWithoutSpan` helper.

**C-3 — The G9 group buffers before reporting.** `_collect_coverage_reporter` appends to a
`pending` list, and the whole group is discarded if the seam fails part-way, so a partial group
is never reported. Combined with the three-way `project_addopts` return (`None` = not read,
`""` = read with no assignment, value = read), the finding's claim that "the project addopts
supplies none either" is only made when the configuration was actually read. That is a careful
distinction and it is documented in the docstring's `Returns:` clause.

**C-4 — The executable-position constraint prevents the rule reporting itself.**
`_executable_positions` restricts a tool-name match to the leading four-word window with a
non-flag predecessor, so a task that greps a policy file for a register member's name is not read
as invoking it. The rule file records the reason explicitly, naming the case of a task searching
that very file.

### Error handling

**PASS.** The graceful-degradation contract is met and is the correct shape. The broad
`except Exception` in `evaluate_observability_gates` is justified in place — "a validation run
must never fail because the repository could not be queried" — which is the documented policy
exception to the no-broad-catch rule rather than a silent swallow. It returns rather than
re-raising by design, and the two required fault injections (a seam that raises, and one that
reports a non-zero exit) are both tested in both runtimes. No new logging surface was added,
consistent with the spec.

### Naming, structure, size

**PASS.** Names are descriptive and follow each language's convention (`snake_case` /
`camelCase`, `PascalCase` types). Module-private helpers carry the leading underscore in Python
and are unexported in TypeScript; the public surface is exactly
`evaluate_observability_gates` / `evaluateObservabilityGates`, `project_addopts` /
`projectAddopts`, the four severity constants, the register, and the two record types.
Functions are small — the largest is `_evaluate_git_diff` at roughly 40 lines including comments.
Every public function carries a full docstring with `Args`/`Returns`/`Raises`; the module
docstrings state purpose, scope boundaries, invariants, and side effects.

### Backward compatibility

**PASS**, with one nuance recorded as MINOR-3. The `task_text` / `taskText` field is the only
contract change. In Python it is trailing with a default (`task_text: str = ""`), so every
existing construction remains valid — asserted directly by
`assert PlanCommand.__dataclass_fields__["task_text"].default == ""`. No CLI flag, subcommand,
artifact type, MCP tool, or MCP parameter was added, removed, or renamed; the dispatch modules in
both runtimes are byte-unchanged (`git diff --stat` returns nothing for both).

### Extractor change — `splitLines`

The TypeScript `splitLines` gained two behaviours: an empty-string early return, and dropping a
trailing empty element. Both are parity corrections toward Python's `str.splitlines()`, and the
comment says so. I checked they cannot change existing output: the dropped element is `""`,
which matches neither the fence pattern, the heading pattern, nor the task pattern, and yields no
inline span and no fenced command. The four pre-existing discrimination test files are unmodified
and pass, which is the empirical confirmation.

The fence handling was restructured so window lines accumulate. Extraction output is unchanged —
the reordering of `if current_task is None: continue` ahead of the strip is behaviour-preserving.
Two constructs on that path are uncovered (`plan_gate_commands.py` line 325's false branch and
line 332): the case of a fenced block sitting in the document preamble, outside any task window.
Both produce no record, the module is at 98.99% line / 94.44% branch, and both thresholds are
comfortably met — so this is acceptable against policy. It is recorded as MINOR-1 because the
uncovered path is a *changed* construct rather than pre-existing code.

## Minor findings

**MINOR-1 — Two changed constructs uncovered in `plan_gate_commands.py`.** The false branch of
line 325 and line 332, both on the "fenced content outside any task window" path. Acceptable
against thresholds (98.99 / 94.44 against 85 / 75); recorded because they are changed lines. One
fixture with a fenced block before the first task line would close both.

**MINOR-2 — `plan-gate-observability.ts` is 494 of 500 lines.** Six lines of headroom. Any future
rule or documentation addition to that module forces a split. Not a violation; worth knowing
before the next change lands there.

**MINOR-3 — `taskText` is a required field in TypeScript, not an optional one.**
`spec.md:213` states the added field is "trailing and defaulted, so any construction that omits
it continues to work". That holds in Python. In TypeScript `readonly taskText: string;` is
required, so an object literal omitting it fails to typecheck. There is exactly one construction
site in the repository (`appendCommand`, inside the same module), so nothing breaks today — I
grepped and found no external constructor of `PlanCommand` in `src` or `test`. Recorded so the
spec's compatibility claim is not read as holding symmetrically.

**MINOR-4 — `projectAddopts` null-guard asymmetry.** Python's `if not text` catches `None` as
well as `""`; TypeScript's `if (text === "")` catches only `""`. Unreachable today because the
seam's declared return type is `string`. A `?? ""` on the read, or a `!text` test, would make the
two identical without cost.

**MINOR-5 — A pre-existing assertion was weakened rather than re-expressed.** In
`orchestration-artifacts-plan-gates.test.ts:197-203`,
`expect(runner.calls[0]).toEqual([...])` became `expect(runner.calls).toContainEqual([...])`.
The change is necessary and commented (G9 now issues `git show HEAD:pyproject.toml` first), but
the ordering guarantee is dropped rather than restated at the new index. Asserting
`runner.calls[1]` would preserve it, at the cost of coupling to the seam call order.

## Toolchain and test verification performed by this review

| Check | Command | Result |
|---|---|---|
| Python format | `poetry run black --check .` | `455 files would be left unchanged.` |
| Python lint | `poetry run ruff check --no-fix .` | `All checks passed!` |
| Python types | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` |
| TypeScript types | `npm run typecheck` | clean, no diagnostics |
| TypeScript lint | `npm run lint` | clean, no diagnostics |
| Plan-gate tests (Python) | `poetry run pytest <7 plan-gate files> -q --no-cov` | `92 passed` |
| Plan-gate tests (TS) | `npx jest test/lib/validate/plan-gate` | `7 suites, 81 passed` |
| Full Python suite | `poetry run pytest -q --no-cov` | `1 failed, 4194 passed, 5 skipped` |
| Full TypeScript suite | `npm test` | `199 suites, 2710 passed` |
| Evidence locations | `validate_evidence_locations.py --root .` | `EXIT=0` |

The single Python failure is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, naming exactly one missing
path, `.claude\state\python-batch-budget.default.json`. That prefix is the issue-#510 signature:
a gitignored machine-local counter that regenerates whenever the Python toolchain runs. No other
missing path was reported and no other test failed, so no real bundle-parity shortfall is masked.
This is known local noise, not a branch defect.

## Conclusion

**No blocking findings.** The code is clean, the design decisions are sound and justified in
place, and the cross-runtime message parity is properly pinned. The two Major findings are both
about test reach rather than about behaviour: three negative flows in the new module are
unreachable by any test (MAJOR-1), and the register's marker and exclusion data are not pinned
equal across runtimes (MAJOR-2). Both are small, well-bounded follow-ups and neither should hold
the merge.
