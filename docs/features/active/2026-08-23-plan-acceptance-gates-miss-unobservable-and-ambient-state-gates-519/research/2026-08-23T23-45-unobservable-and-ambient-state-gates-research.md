# Research — Plan acceptance gates miss unobservable and ambient-state gates (Issue #519)

- **Issue:** #519
- **Work mode:** `full-bug`
- **Timestamp:** 2026-08-23T23-45
- **Branch:** `bug/plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519`
- **Worktree:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f7ed06b7f1bfec9`

All paths below are repository-relative unless stated otherwise.

---

## Q1 — Current implementation surface

### Python runtime

| File | Lines | Role | Extension seam |
| --- | --- | --- | --- |
| `scripts/dev_tools/plan_gate_commands.py` | 307 | Extractor. Walks plan text in source order, maintains the attribution window, emits `PlanCommand` records. | `_classify_kind` (`:124`) returns `KIND_GREP` / `KIND_PYTEST_COV` / `KIND_OTHER` (`:34-36`). `PlanCommand` frozen dataclass at `:41-62`. |
| `scripts/dev_tools/plan_gate_coverage.py` | 244 | G1–G4 cascade over `--cov` values. | `evaluate_cov_value` (`:123`), `_evaluate_tracked_cov_value` (`:195`). |
| `scripts/dev_tools/plan_gate_discrimination.py` | 388 | Shared report/context types, G5/G6 literal rules, public entry point. | **`evaluate_plan_gates` (`:350-387`) is the single rule-invocation seam.** The coverage loop is `:374-382`; the literal group is invoked at `:384-385`. A new rule group is one call appended here. |

Supporting types in `plan_gate_discrimination.py`:
- `PlanGateReport` (`:61-76`) — two channels, `blocking` and `warnings`.
- `PlanGateGitRepository` Protocol (`:79-88`) — `files_containing`, `is_tracked_file`, `is_tracked_directory`, `read_tracked_text`.
- `GitPlanGateRepository` (`:91-153`) — `git grep -F -l`, `git ls-files`, `git show HEAD:`; every call uses `allow_error=True`.
- `PlanGateContext` (`:156-172`) — `workspace_root`, `file_system` (`ReadinessFileSystem`), `git`.
- `build_plan_gate_context` (`:175-200`).
- `G5_SEVERITY` (`:58`).

### CLI dispatch (Python)

`scripts/dev_tools/validate_orchestration_artifacts.py`:
- imports at `:18-22`;
- `PLAN_GATE_WARNING_PREFIX = "PLAN GATE WARNING: "` at `:49`;
- `validate_plan_text` (`:75-97`) — single-channel, returns element 0 only;
- `validate_plan_text_with_warnings` (`:100-128`) — calls `evaluate_plan_gates` at `:127`, concatenates `_plan_structure_errors(text) + report.blocking`;
- `_plan_channels` (`:366-371`) builds the context from `args.workspace_root`;
- `_validate_from_args` (`:358-359`) and `_validate_from_args_with_warnings` (`:395-397`) both special-case `artifact_type == "plan"` ahead of the type switch.

### TypeScript runtime

| File | Lines | Role | Extension seam |
| --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` | 373 | Extractor port. `PlanCommandKind` union at `:69`; `PLAN_GATE_TASK_PATTERN` `:53`; `PLAN_GATE_HEADING_PATTERN` `:57`. | Same as Python. |
| `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` | 438 | Shared-predicate module: report shape, seam interfaces, placeholder/literal predicates, G1–G4 cascade, `windowJoin`, `hasCrossLinePresence`. | `evaluateCovValue` `:193`; `evaluateTrackedCovValue` `:254`. **Only 62 lines of headroom against the 500-line limit.** |
| `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` | 269 | Git adapter `CommandRunnerPlanGateRepository` (`:88-150`), G5/G6, `evaluatePlanGates` (`:249-269`), re-exports the whole public surface. | **`evaluatePlanGates` is the mirror of the Python entry seam.** 231 lines of headroom. |

### TypeScript dispatch

`extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`:
- imports `evaluatePlanGates` at `:20-22`;
- `buildPlanGateContext` (`:196-212`) — returns `undefined` unless `fs`, `root`, `artifactPath` and `runner` are all present;
- `validateArtifactWithWarnings` (`:227-242`) — the `plan` branch at `:234-240`.

### Existing tests

**Python** (`tests/scripts/dev_tools/`):
- `test_plan_gate_commands.py` — extractor (10 tests; note `test_extract_plan_commands_skips_command_without_operand` at `:147`).
- `test_plan_gate_discrimination_cov.py` — G1–G4.
- `test_plan_gate_discrimination_literals.py` — G5/G6.
- `test_plan_gate_discrimination_context.py` — context construction and graceful degradation.
- `test_plan_gate_parity.py` — parity fixtures, `G5_SEVERITY` cross-runtime check, `repr` prohibition, task-pattern identity.
- `test_validate_orchestration_artifacts_plan_gates.py` — CLI routing and the `PLAN GATE WARNING: ` prefix.

**TypeScript** (`extensions/drm-copilot/test/`):
- `lib/validate/plan-gate-commands.test.ts`
- `lib/validate/plan-gate-discrimination-cov.test.ts`
- `lib/validate/plan-gate-discrimination-literals.test.ts`
- `lib/validate/plan-gate-repository.test.ts`
- `lib/validate/plan-gate-parity.test.ts`
- `lib/validate/orchestration-artifacts-plan-gates.test.ts`
- `lib/validate/validate-orchestration-service-call-plan-gates.test.ts`
- `mcp-plan-gate-warning-projection.test.ts`

### Extractor observation that constrains every candidate rule

`_append_command` (`plan_gate_commands.py:236-237`) drops any span whose argv splits into fewer than two words. `test_extract_plan_commands_skips_command_without_operand` pins this behaviour and it is load-bearing: it prevents a backticked file path from being treated as a command. **Consequence: an MCP tool invoked as a bare single-token span — for example `` `mcp__drm-copilot__run_poshqc_format` `` — is never extracted.** Any write-mode register therefore cannot see the PoshQC formatter in the form plans actually write it, unless the minimum-argv rule is relaxed. Relaxing it would newly admit single-word spans into the `--cov` scan (a lone `` `--cov=scripts/x.py` `` span would begin producing a G1 Blocking finding), which changes existing G1–G6 output and is therefore out of bounds under the stated constraint.

Every other candidate command **is** extracted today: `git diff --exit-code main -- path`, `poetry run black .`, `poetry run ruff check .`, `npm run format`, `git add -A`, and `git status --porcelain -- extensions/drm-copilot` all split into two or more words and are classified `KIND_OTHER`. No extractor change is required to reach them.

---

## Q2 — Decidability of the four candidates

| Candidate | Decidable from | Seams reused | Verdict |
| --- | --- | --- | --- |
| **A. Write-mode command register** | Command text alone, plus the owning task's attributed plan text | Attribution window; a per-entry *observation-marker* exoneration modelled directly on G5's `_plan_quotes_literal` | **Ship**, as rule **G7**, Warning on first release |
| **B. Bare-`git diff` rule** | Command text alone (context-free) | Attribution window only | **Ship**, as rule **G8**. Blocking-eligible pending measurement |
| **C. Coverage-reporter rule** | Command text plus one cheap repository lookup (`pyproject.toml`) | `PlanGateGitRepository.read_tracked_text`; graceful-degradation contract | **Ship**, as rule **G9**, Warning |
| **D. Executor-choice heuristic** | Not decidable — a keyword scan over prose | — | **Reject as a validator rule.** Address in `atomic-plan-contract/SKILL.md` |

### A — write-mode register (proposed G7)

The write-mode fact is decidable. What is *not* decidable from the command text alone is the second half of the issue's proposal — "carries an observation beyond the exit code" — because that is a property of the surrounding prose.

The tractable formulation, which reuses an existing seam rather than inventing one: give each register entry a set of **observation markers**, and fire only when the write-mode command appears in a task whose attributed text contains none of that entry's markers. This is structurally the same exoneration G5 already performs — `_plan_quotes_literal` (`plan_gate_discrimination.py:234-248`) exonerates a literal the plan quotes elsewhere in its own text. Both are plan-text-only predicates, so G7 is context-free and can run on every invocation alongside G1 and G4.

Required input the extractor does not currently supply: the owning task's attributed text. Two options were considered.

- **Recommended:** add a trailing field with a default to `PlanCommand` — `task_text: str = ""` in Python, a matching `readonly taskText: string` in the TypeScript interface — populated by `extract_plan_commands` from the attribution window it already maintains. Additive; no existing rule reads it; the only test affected is `test_extract_plan_commands_returns_exact_record_fields` (`tests/scripts/dev_tools/test_plan_gate_commands.py:21`) and its TypeScript twin.
- **Rejected:** re-walking the plan text inside the rule module using the exported `PLAN_GATE_TASK_RE` and `PLAN_GATE_HEADING_RE`. It avoids touching the record, but it duplicates the attribution-window loop, and the rule file states the attribution window as a single invariant. Two implementations of one invariant will diverge.

### B — bare-`git diff` rule (proposed G8)

Fully context-free. The predicate is a positional scan of the argv, identical in shape to `cov_values` (`plan_gate_coverage.py:90-120`):

- locate `git` followed by `diff` within the leading wrapper window (reuse the `_EXECUTABLE_SCAN_LIMIT = 4` convention from `grep_executable_index`);
- collect the words between `diff` and the `--` pathspec separator;
- if none of those words is a non-flag operand, and neither `--cached` nor `--staged` is present, the invocation compares worktree against index and is therefore commit-state dependent.

A second, weaker sub-rule (**G8b**) covers the mirror-image blindness the issue documents: an *anchored* `git diff --name-only` or `--name-status` in a task whose attributed text contains neither a `git add` span nor a `git status --porcelain` span cannot see a file the plan creates. This needs the same task-text input G7 needs, and nothing more.

### C — coverage-reporter rule (proposed G9)

Decidable with one repository read. **Do not add a TOML parser.** `tomllib` is Python 3.11+ and `pyproject.toml:17` declares `python = ">=3.10,<4.0"`; the TypeScript runtime has no TOML parser and `.claude/rules/general-code-change.md` forbids adding a dependency without justification. Extract the `addopts` assignment with a regular expression over the file text obtained from the existing `read_tracked_text` seam. The same expression is trivially portable to TypeScript, which is what byte-identity requires.

Predicate: a command carrying a `--cov` argument and no `--cov-report=term…` argument, where the extracted `addopts` string also carries no `--cov-report=term…`, prints no coverage table. Failure of the repository seam skips the rule under the existing graceful-degradation contract (`plan_gate_discrimination.py:341-344`, `plan_gate_coverage.py:187-192`).

### D — executor-choice heuristic

Rejected. `.claude/rules/plan-acceptance-gates.md:13` instructs that a new rule be weighed on its false-positive rate at authoring time. The proposed vocabulary — "any", "a suitable", "the known", "choose" — occurs throughout ordinary plan prose in roles that carry no selection semantics. A worked example from the corpus: the #502 plan writes "Do not relax **any** of these to the bare form" (`plan.2026-08-22T22-57.md:127`) and "an acceptance demanding a count could never be satisfied" — the first would trip the heuristic while stating a prohibition, not a selection. The remedy belongs in the authoring skill.

---

## Q3 — Write-mode inventory, verified against this repository

Each row was checked against the repository's own configuration or source rather than against the issue text.

| Command | issue.md claim | Verified? | Evidence |
| --- | --- | --- | --- |
| `black .` | writes | **Confirmed** | Black's default mode rewrites in place; `[tool.black]` (`pyproject.toml:84-86`) sets only `line-length` and `target-version`, so no check-only default is configured. |
| `ruff check` without `--no-fix` | writes | **Confirmed** | `pyproject.toml:91` — `fix = true`; `:92` — `show-fixes = true`. This is the claim the issue flagged as needing confirmation, and it holds. |
| PoshQC formatter (`run_poshqc_format`) | writes | **Confirmed** | `extensions/drm-copilot/resources/templates/run-poshqc-format.ps1:26` calls `Invoke-PoshQCFormat`, which writes at `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:61` (`& $WriteFile $file.FullName $formatted`). |
| `npm run format` | writes | **Confirmed** | `extensions/drm-copilot/package.json:207` — `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`. The `--write` flag is explicit. |
| `npm ci` | writes | **Confirmed by inspection of the command's contract** | `npm ci` deletes and recreates `node_modules`. Its write target is git-ignored, which is why the #502 plan classifies it write-mode but requires no observation (`plan.2026-08-22T22-57.md:129`). |
| `git add -A` | writes | **Confirmed** | Writes the index by intent. See the false-positive note in Q9. |
| `black --check` | does not write | **Confirmed** | `--check` is check-only by contract; used as the read-only baseline form at `plan.2026-08-22T22-57.md:155`. |
| `ruff check --no-fix` | does not write | **Confirmed** | `--no-fix` overrides the configured `fix = true`; the #502 plan records this at `:156`. |
| `pyright` | does not write | **Confirmed** | `[tool.pyright]` (`pyproject.toml:142-162`) configures analysis only; no fix or write option exists. |
| `pytest` | does not write source | **Confirmed with a qualification** | `addopts` (`pyproject.toml:116`) writes `artifacts/python/lcov.info`; `[tool.coverage.run]` `data_file` (`:121`) writes `artifacts/.coverage`. Neither is a source rewrite and neither decouples the exit code from the test outcome. |
| PoshQC analyzer (`run_poshqc_analyze`) | does not write | **Confirmed** | `Invoke-PoshQCAnalyze` (`PoshQC.Analyzer.psm1:83-186`) reads only; it throws on findings (`:183`) and otherwise logs one line (`:185`). |
| PoshQC tests (`run_poshqc_test`) | does not write source | **Confirmed with a qualification** | `Invoke-PoshQCTest` (`PoshQC.Testing.psm1:151-…`) creates result and coverage output directories (`:197`, `:230`) under `artifacts/`. Not a source rewrite; exit fidelity is preserved. |
| `npm run lint` | does not write | **Confirmed** | `package.json:208` — `eslint --no-error-on-unmatched-pattern src test`. No `--fix` flag. |
| `npm run typecheck` | does not write | **Confirmed** | `package.json:209` — `tsc -p ./ --noEmit`. |

**Corrections and additions to the issue's inventory:**

1. **`run_poshqc_analyze_autofix` is missing from the inventory and is write-mode.** `Invoke-PoshQCAnalyzeAutofix` (`PoshQC.Analyzer.psm1:203-254`) passes `-Fix` to `Invoke-ScriptAnalyzer` at `:219` and then re-runs the read-only analyzer at `:253`. It is exposed as an MCP tool (`extensions/drm-copilot/src/mcp-handlers/poshqc-handlers.ts:31-37`) and as a VS Code command (`package.json:141-143`). Any register that omits it has a hole in exactly the class it exists to close.
2. **`run_poshqc_suite`** (`repo-automation-service.ts:291-297`) is a composite that includes the formatter and must be classified write-mode.
3. **`pytest` and `run_poshqc_test` write artifact files.** They are correctly non-write for the register's purpose — the register exists because a *source rewrite* leaves the exit code unchanged — but the register's prose must say "rewrites tracked source", not "writes", or the two are misclassified.
4. **The register cannot see the PoshQC entries as plans actually write them.** See Q1: a bare `` `mcp__drm-copilot__run_poshqc_format` `` span is one word and is dropped by the extractor.

**Method:** every row was read from the repository file cited, not inferred. `npm ci` is the one row established from the documented contract of a third-party command rather than from repository configuration, and is marked as such.

---

## Q4 — The coverage-reporter question

**`addopts` supplies no terminal reporter.** `pyproject.toml:114-117`:

```toml
[tool.pytest.ini_options]
minversion = "7.0"
addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"
testpaths = ["tests"]
```

`pytest-cov` emits the terminal report only when no `--cov-report` is supplied, or when a `term`-family reporter is supplied explicitly; supplied reporters accumulate and replace the default. Because `addopts` supplies exactly one non-terminal reporter, **a `--cov` invocation that does not itself pass `--cov-report=term` or `--cov-report=term-missing` prints no coverage table.**

This is not only a reading of the tool's contract — it is recorded as an executed observation in the repository. `docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-test-coverage.md:13-19` records the command `poetry run pytest --cov --cov-branch --cov-report=term-missing`, exit code 0, and the note that the run output contains `Coverage LCOV written to file artifacts/python/lcov.info` and that "Without an explicit terminal reporter no coverage table is printed at all".

The same artifact (`:21-36`) confirms the issue's second class-1 claim: the `term-missing` reporter prints one combined `Cover` column (`TOTAL … 91%`), not separate line and branch percentages. A gate demanding two printed percentages reads two numbers that are never printed.

**Consequence for G9:** the rule is decidable, and what it must read is the `addopts` value of `[tool.pytest.ini_options]` in `pyproject.toml`. Read it as text through `read_tracked_text` and extract the assignment with a regular expression; do not add a TOML parser (see Q2C).

---

## Q5 — Severity determination procedure and the grandfathering argument

### The pre-declared rule, verbatim

From `docs/features/completed/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md:66`:

> `G5_SEVERITY` is `"blocking"` if and only if the total G5 finding count is greater than `0` **and** the recorded false-positive count is `0`; otherwise `"warning"`.

Note that `.claude/rules/plan-acceptance-gates.md:46` cites the artifact under `docs/features/**active**/…`; the feature has since been archived and the artifact now lives under `docs/features/**completed**/…`. The rule file's citation is stale. Correcting it is optional and orthogonal.

### The procedure the measurement followed

1. **Enumerate the corpus** — every file matching `docs/features/**/plan*.md`. Recorded count: 166.
2. **Enumerate candidates** — commands whose extracted `kind` matches the rule's family and whose operand satisfies the rule's checkability predicate. Recorded count: 100.
3. **Apply the shipped predicate in the shipped order**, not a paraphrase of it. The artifact records this as check 4 (`:54`): "the driver applies the tree-absence check, then the plan-quotation check, then the cross-line check, in the same order as `_evaluate_literal`".
4. **Record four counts:** findings, true positives, false positives, and a one-line enumeration of each false positive naming plan path and literal (`:33-39`).
5. **Validate the measurement itself against a vacuity check.** A zero finding count makes the false-positive count uninformative, and the artifact declares this explicitly with the literal marker `MEASUREMENT INVALID: zero G5 findings produced; a zero false-positive count measures nothing` (`:43`).
6. **Re-examine the driver for a defect before accepting a zero.** Four checks are recorded (`:49-54`): non-vacuous enumeration, a working repository seam, a self-hit on every sampled lookup, and predicate-order equivalence with the shipped rule.
7. **Apply the rule and set a single named constant per runtime**, with a source comment naming the artifact. `G5_SEVERITY` is at `scripts/dev_tools/plan_gate_discrimination.py:52-58` and `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts:60-69`.
8. **Delete the throwaway driver and evidence its deletion** (`:73-82`).

### Prediction for the new rules

G5's zero was **structural**: every committed plan is a tracked file, so a fixed-string search for a literal quoted inside a committed plan always self-hits, and tree-absence holds for no committed candidate (`:56-62`). That reasoning does **not** transfer to G7, G8 or G9. Their predicates are over command shape, not over tree presence, so the corpus is expected to yield non-zero findings — the bare `git diff --exit-code` form and the `black .` / `ruff check .` spans are both present in the corpus. The measurement is therefore expected to be non-vacuous and capable of licensing Blocking for at least G8. **This is a prediction to be tested by the measurement, not a claim.**

### Scope of Invocation and grandfathering

`.claude/rules/plan-acceptance-gates.md:7-13` is directly on point and applies unchanged to a newly added rule. No CI job, test, or scheduled task sweeps the committed plan corpus, and this fix must not add one. With no sweep there is nothing to protect, so a grandfathering list, an exemption marker, a per-plan suppression comment, and an allowlist file are all prohibited: their only reachable use would be to silence a finding on the plan currently being authored, which is the case the gate exists to report.

The corpus measurement described above is a **throwaway measurement driver**, not a sweep. It is run once, its result is recorded as an evidence artifact, and the driver is deleted — exactly as the #486 measurement did. It must not be committed as a test or a CI job.

---

## Q6 — Parity obligations

| Obligation | Statement | Enforced by |
| --- | --- | --- |
| **No `repr()` / `!r` in Python gate messages** | Python's `repr` switches quote character on content; the TypeScript helper always single-quotes, so an apostrophe-bearing value would render differently. | `test_no_repr_formatting_in_gate_messages`, `tests/scripts/dev_tools/test_plan_gate_parity.py:271-284`, iterating `_PYTHON_GATE_MODULES` (`:39-42`). **A new Python rule module must be added to that tuple.** |
| **No `pythonRepr(` in TypeScript gate modules** | Same reason, mirrored. | `renders offending values without pythonRepr formatting`, `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts:214-222`, iterating `GATE_MODULE_PATHS` (`:173-177`). **A new TypeScript rule module must be added to that array.** |
| **Backtick delimiting** | Every offending value renders between backticks with no helper-supplied quotes. | Asserted indirectly by the expected-string fixtures; stated at `.claude/rules/plan-acceptance-gates.md:90-101`. |
| **Severity-constant parity** | Each severity constant exists once per runtime and the two agree. | `test_g5_severity_constant_matches_typescript`, `tests/scripts/dev_tools/test_plan_gate_parity.py:257-268`, matching `_G5_SEVERITY_TS_RE = r'G5_SEVERITY\s*:\s*string\s*=\s*"([^"]+)"'` (`:44`). A new rule's severity constant needs its own regex and its own assertion in the same shape. |
| **Task-pattern identity** | The extractor's task pattern is textually identical to the validator's. | `test_extractor_task_pattern_matches_validator_pattern` (`:287-291`) and `declares the same task pattern as the validator` (TS `:208-212`). |
| **Parity fixture duplication** | Each fixture is duplicated verbatim in both parity test files together with its expected finding strings. Fixtures are built by `_parity_plan` / `parityPlan` — a one-task plan with a single acceptance command. | `_PARITY_CASES` (`tests/scripts/dev_tools/test_plan_gate_parity.py:207-226`) and `PARITY_CASES` (TS `:…-165`); severity-dependent rows are held separately (`:230-233` / TS `:168-171`) so the table stays valid under either severity. |
| **Apostrophe fixture** | The set must include an apostrophe-bearing value per message-formatting family. | `PARITY_G1_APOSTROPHE` (`:66-68`), `PARITY_G5_APOSTROPHE` (`:69`). **A new rule that renders a value must add an apostrophe-bearing fixture.** |
| **Graceful degradation** | A repository seam that raises or exits non-zero causes the context-requiring rules to be skipped; no finding is produced and no exception escapes. | `plan_gate_discrimination.py:341-344`; `plan_gate_coverage.py:187-192`; TS `plan-gate-discrimination.ts:229-233`, `plan-gate-rules.ts:236-241`. G9 must sit inside such a guard. |
| **Context-free / context-requiring split** | With no context supplied, the Blocking list must be byte-identical to the context-free output. | `plan_gate_discrimination.py:384`; TS `:264`. G7 and G8 are context-free and run unconditionally; G9 is context-requiring and must be gated on `context is not None`. |

### Known divergence classes already recorded

Recorded repository-wide in `.claude/rules/parallel-orchestration.md` for the parallel validators; two of the three apply to any Python/TypeScript parity port and must be avoided by construction here:

1. **`pythonRepr` quote selection** — avoided by the backtick prohibition above.
2. **Integral floats** — `JSON.parse` erases Python's `int`/`float` distinction. Not reachable for these rules: the plan gate operates on text, never on parsed JSON.
3. **Boolean/integer equality** — `===` versus Python's `True == 1`. Not reachable for the same reason.

A fourth, gate-specific divergence risk that a new rule **does** introduce: **regular-expression dialect**. The G9 `addopts` extraction is the first gate predicate that would use a regex over file content rather than a character-set membership test. Python `re` and JavaScript `RegExp` differ in several constructs. Constrain the expression to the intersection subset — literal text, character classes, `*`, `+`, `?`, and a non-greedy quantifier — and add a parity fixture whose `addopts` value exercises quoting and whitespace variation.

### MCP surface

No change. `.claude/rules/plan-acceptance-gates.md:115` records that the `validate_orchestration_artifacts` input-schema property-key set is unchanged and Warnings surface on an optional `warnings` field. New rules append to the existing two channels, so `extensions/drm-copilot/test/mcp-plan-gate-warning-projection.test.ts` needs no contract change.

---

## Q7 — Regression corpus for validation

### The path in `issue.md` is stale

`issue.md:23` and `spec.md:17` name the plan at
`docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md`.
That path does not exist. The feature was archived and the file is now at
`docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md`.

- **SearchScope:** `docs/features/**` in the worktree.
- **SearchPatterns:** glob `docs/features/**/*502*/**`.
- **SearchResult:** 55 files, all under `docs/features/completed/2026-08-21-…-502/`; zero under `docs/features/active/`.

Any recovery command must therefore use the archived path and `git log --follow`, because the file was moved.

### Recoverability of the six revisions — not verified

**I could not check this.** This agent's tool set is `Read`, `Grep`, `Glob`, `WebFetch`, `Write`, `Edit`. There is no shell tool, so no `git log`, `git rev-list`, or `git show` could be run. I am not asserting either that the revisions are recoverable or that they are not.

- **SearchScope:** the worktree filesystem, and the whole `docs/features/completed/2026-08-21-…-502/` tree.
- **SearchPatterns:** `revision [0-9]`, `revision-[0-9]`, `preflight cycle`, `PREFLIGHT: REVISIONS REQUIRED`; glob for sibling timestamped plan files.
- **SearchResult:** exactly one plan file exists in that folder. Thirty-plus evidence artifacts are labelled "revision-6 re-run", and `plan.2026-08-22T22-57.md:146` states "The count fell from nine to eight in revision 6". No intermediate plan text is present on disk. No orchestrator checkpoint carrying prior plan text was found.

Two facts bear on how likely recovery is, and both cut against it:

1. `.claude/skills/atomic-plan-contract/SKILL.md:175-183` — the Plan-Path Continuity Contract requires the planner to update the same file in place across all preflight revisions and forbids timestamped siblings. So all revisions went through one path; whether each intermediate state was separately committed is the open question.
2. The evidence artifacts number the revisions up to 6, but those are labelled as *re-runs* during remediation, whereas `issue.md:22` describes "six runs across five plan revisions" during **preflight**, before implementation. The two numbering schemes are not the same sequence, so even a successful `git log --follow` may not surface the preflight states the issue measured.

### Recommended falsifiable integration check

Do not make the integration check depend on git-history recoverability. Structure it in two tiers.

**Tier 1 — mandatory, history-independent.** Build a two-file fixture pair committed under the feature's evidence tree:

- a **defective** fixture reconstructed from the pre-correction forms the committed plan itself names in prose, each with a line citation, and
- a **corrected** fixture consisting of the corresponding conditions as they stand in `plan.2026-08-22T22-57.md`.

The committed plan documents its own corrections explicitly, which makes the reconstruction auditable rather than invented:

| Class | Pre-correction form, as the plan names it | Corrected form on disk |
| --- | --- | --- |
| Ambient state | "The bare worktree-against-index form passes vacuously once the executor commits" (`:120`) | `git diff --exit-code main -- …` plus a recorded `git rev-parse main` (`:126`) |
| Ambient state | "An anchored diff … never reports an untracked file" (`:120`) | `git add -A` before the anchored diff, at P8-T5, P8-T9, P8-T12, P8-T13, P8-T14 (`:121`) |
| Ambient state | "A porcelain status … goes empty once they are committed" (`:120`) | union of porcelain and anchored diff, at P5-T12 (`:123`) |
| Write-mode exit code | exit-code-only gate over `poetry run black .` | "no output line begins with the literal `reformatted `" (`:243`) |
| Write-mode exit code | exit-code-only gate over `poetry run ruff check .` | "no output line begins with the literal `Fixed `" (`:244`) |
| Write-mode exit code | exit-code-only gate over the PoshQC formatter and `npm run format` | before-and-after `git status --porcelain` snapshot pair (`:248`, `:252`) |
| Unobservable output | a coverage gate with no explicit terminal reporter | `--cov-report=term-missing` passed explicitly, with the derivation columns named (`:158`, `:246`) |
| Unobservable output | "an acceptance demanding a zero-diagnostic count would name a value the tool never emits" | the ok flag is the gate (`:249`) |

Acceptance for Tier 1 is falsifiable in both directions: **non-zero findings on the defective fixture and zero findings on the corrected fixture**, per rule. A rule that fires on the corrected fixture is caught, which is the property the issue asks for.

**Tier 2 — opportunistic, recorded either way.** Attempt
`git log --follow --format=%H -- docs/features/completed/2026-08-21-…-502/plan.2026-08-22T22-57.md`
and, for each returned commit, `git show <sha>:<path>`. If two or more distinct plan texts are returned, run the new rules over each and record the finding count per revision. If fewer than two are returned, record that plainly with the command and its output, and rely on Tier 1. **The plan must not make Tier 2 a gate**, because its precondition is unverified.

---

## Q8 — The rule-file amendment question

**Answer: amending `.claude/rules/plan-acceptance-gates.md` is in scope and is required, and `.claude/skills/atomic-plan-contract/SKILL.md` must be amended alongside it. Both amendments must additionally be mirrored byte-for-byte into the bundled payload.**

### The citation that settles it

`.claude/skills/policy-compliance-order/SKILL.md:32` states the constraint: "Do NOT modify policy documents under `.claude/rules/` or `.github/instructions/`." Taken alone it would forbid the amendment. Three pieces of evidence resolve it:

1. **`CLAUDE.md` names the canonical, unmodifiable surface, and it is `.github/`, not `.claude/rules/`.** CLAUDE.md's Policy Compliance Reading Order section lists `.github/copilot-instructions.md` and the `.github/instructions/*.instructions.md` files and states: "These files are the canonical policy source. Do not modify them. `.claude/` files mirror or reference their content."
2. **`.claude/rules/plan-acceptance-gates.md` is not a mirror of any `.github/instructions/` file, so it is not covered by that clause.**
   - **SearchScope:** `.github/instructions/`.
   - **SearchPatterns:** glob `.github/instructions/*`; repository-wide grep for `plan-acceptance-gates`.
   - **SearchResult:** 17 instruction files, none named `plan-acceptance-gates`; zero occurrences of the string `plan-acceptance-gates` anywhere under `.github/`. The rule file is repo-original prose authored by #486.
3. **The immediately preceding, closely analogous item amended a `.claude/rules/` file as a planned, gated task.** Issue #502's plan task [P6-T1] amended `.claude/rules/parallel-orchestration.md`, and its QA gate is `docs/features/completed/2026-08-21-…-502/evidence/qa-gates/rule-file-amendment.md`. The same item's [P6-T4] gate, `evidence/qa-gates/policy-file-untouched.md:60-64`, draws the boundary explicitly: it protects `.claude/rules/plan-acceptance-gates.md` because that item merely *consumed* the marker set, and separately protects `.github` because "`.github` holds the canonical Copilot policy surface, which `CLAUDE.md` declares must not be modified." The distinction the repository actually draws is consume-versus-author, not path-prefix.

`.claude/rules/plan-acceptance-gates.md:5` states its own enforcement model: "Enforcement is validator logic plus this prose file." A rule added to the validator without a corresponding prose entry would leave the file describing a rule set that no longer matches the code, which is the failure mode the file exists to prevent. The amendment is therefore not merely permitted; it is required for the fix to be complete.

`.claude/rules/plan-acceptance-gates.md:109` further states: "`.claude/skills/atomic-plan-contract/SKILL.md` carries the authoring-side statement of this guidance and cross-references this file." The authoring-side section is the bulleted list under **Wrap-Tolerant Assertion Authoring (Mandatory)** at `SKILL.md:162-173`. Each shipped rule already has a bullet there (G6 at `:169`, the placeholder guard at `:170`, G1–G3 at `:171`, G4 at `:172`). New rules must acquire the same.

### The load-bearing consequence: two bundled mirrors

Both files are published into the extension payload and are held byte-identical by test.

- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`

Both are listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`:62`, `:67`). Byte-identity is enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126`, which asserts `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` for every non-memory `.claude/**` file. **Amending either file without mirroring it fails that test.**

### Resulting file list for the fix

**Policy and documentation (4 files, two mirrored pairs):**
1. `.claude/rules/plan-acceptance-gates.md`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md`
3. `.claude/skills/atomic-plan-contract/SKILL.md`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`

**Python (3 files):**
5. `scripts/dev_tools/plan_gate_observability.py` — **new**; G7, G8, G9.
6. `scripts/dev_tools/plan_gate_discrimination.py` — one import and one call appended in `evaluate_plan_gates`; a severity constant per new rule.
7. `scripts/dev_tools/plan_gate_commands.py` — `PlanCommand.task_text` field, populated from the existing attribution window.

**TypeScript (3 files):**
8. `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` — **new**; port of 5.
9. `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` — mirror of 6, plus re-exports.
10. `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` — mirror of 7.

`scripts/dev_tools/validate_orchestration_artifacts.py` and `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` need **no change**: new findings flow through the existing two channels.

**New modules are required rather than optional on the TypeScript side.** `plan-gate-rules.ts` is 438 lines against the hard 500-line limit in `.claude/rules/general-code-change.md`, leaving 62 lines. Three rules plus their doc comments will not fit.

---

## Q9 — False-positive risk per surviving candidate

### G7 — write-mode command with no observation marker

**Fires on:** a register-listed write-mode command in a task whose attributed text contains none of that entry's observation markers.

**False-positive surface — moderate.** Three authoring forms would trip it incorrectly:

1. **A write-mode command run as a preparatory step, not as the gated observation.** The clearest case is `git add -A`, which appears in #502's plan at P8-T5, P8-T9, P8-T12, P8-T13 and P8-T14 purely to make a subsequent diff complete (`plan.2026-08-22T22-57.md:129`: "`git add -A` — writes the index by intent"). Its acceptance is about the diff, not about the staging. **Mitigation: exclude `git add` from the register entirely and record the exclusion in the rule-file prose.** Also affected: `npm ci`, whose only write target is git-ignored and which the #502 plan classifies "no observation needed". Exclude it too, for the stated reason.
2. **A task that states its observation in a form the marker set does not spell.** The markers are literal strings; a plan that writes "the before and after snapshots are byte-identical" is exonerated only if `byte-identical` or `snapshot` is in the marker set. Every paraphrase outside the set is a false positive.
3. **A write-mode command invoked inside a task whose acceptance concerns something else entirely** — for example a task that runs the formatter as setup and asserts a test count.

**Severity recommendation: Warning on first release.** Cases 2 and 3 are real and cannot be eliminated by the marker mechanism. Revisit against a corpus measurement per Q5.

### G8 — bare `git diff` with no ref operand

**Fires on:** `git diff` with no non-flag operand before the `--` separator and no `--cached` / `--staged`.

**False-positive surface — low.** The predicate is a statement about what the command compares, and the answer does not depend on intent. The only authoring form that would trip it while being correct is a task that runs a bare `git diff` **as one half of a deliberate before-and-after worktree pair**, where the comparison against the index is exactly the intended semantics. #502's P0-T6, P0-T10, P8-T6 and P8-T10 use `git status --porcelain` for this rather than `git diff`, but a plan could legitimately use the diff form.

**Mitigation:** exonerate when the same task's attributed text carries a second `git diff` or `git status` span — the pairing marker — reusing the same task-text input G7 needs.

**Severity recommendation: Blocking-eligible, subject to the corpus measurement.** Unlike G5, this rule's corpus count is expected to be non-zero, so the pre-declared rule can actually decide it. Ship whatever the measurement returns; do not pre-commit to Blocking in the plan.

### G8b — anchored `--name-only` / `--name-status` without a staging or porcelain companion

**Fires on:** an anchored `git diff --name-only` or `--name-status` in a task whose attributed text contains neither a `git add` span nor a `git status --porcelain` span.

**False-positive surface — moderate-to-high.** The rule assumes the assertion concerns created paths. A task that anchors a `--name-status` diff to audit *modifications* to pre-existing tracked files needs no staging and is correctly authored; #502's P5-T7, P6-T1 and P6-T4 are exactly that shape (`plan.2026-08-22T22-57.md:122`: "Anchored alone … Each guards a pre-existing tracked file, so there is no untracked case to cover"). The rule cannot distinguish the two intents from text.

**Severity recommendation: Warning, unconditionally, and flag in the plan that this is the highest-false-positive member of the set.** Consider deferring it to documentation if the corpus measurement shows a false-positive rate above a pre-declared threshold.

### G9 — `--cov` invocation with no terminal reporter anywhere

**Fires on:** a `--cov` command with no `--cov-report=term…`, where the extracted `addopts` also carries none.

**False-positive surface — low but real.** The legitimate form is a task that runs coverage solely to produce the LCOV file for a downstream consumer and asserts nothing about a printed percentage. #502's P8-T5 and P8-T9 compute a coverage delta and read figures recorded by an earlier task, not from a fresh table. A second form is a command run under `--cov-fail-under`, where the exit code carries the assertion and no table is needed.

**Mitigation:** exonerate when the argv carries `--cov-fail-under`. The LCOV-only case has no textual marker and remains a genuine false positive.

**Severity recommendation: Warning.** The finding text should state the remedy (`add --cov-report=term-missing`) rather than assert that the gate is unfalsifiable, because the second half of that claim is prose-dependent.

### Rules explicitly not proposed

- **Executor-choice heuristic** — rejected in Q2D.
- **Class 1 in general (unobservable success-case output)** — not statically decidable, as `issue.md:83` concedes. Covered partially by G7's observation markers and G9; the remainder belongs in `atomic-plan-contract/SKILL.md` as a requirement that a plan author observe a command's success-case output before asserting over it.
- **Class 4 (task-ordering dependencies)** — requires intra-plan dependency reasoning across phases. Not proposed. Record it in the rule file as a deliberately uncovered sub-class, which is what `issue.md:34` asks for as the fallback: "the rule file should record which sub-classes it deliberately does not cover so a reviewer knows what still needs human attention."

---

## Effect on existing G1–G6 output

**No existing finding string or severity changes.** The proposal adds rules only; it does not modify `evaluate_cov_value`, `_evaluate_literal`, `_is_checkable_literal`, `is_placeholder`, or any expected string in the parity fixtures. The context-free / context-requiring split is preserved: with no context supplied, the Blocking list stays byte-identical.

Two changes touch shared code and must be verified as behaviour-preserving:

1. **`PlanCommand` gains a trailing `task_text` field with a default.** No existing rule reads it. `test_extract_plan_commands_returns_exact_record_fields` and its TypeScript twin assert the record's fields and will need updating; that is a test change, not an output change.
2. **The minimum-argv drop is left at 2.** Lowering it would newly admit single-word `--cov=` spans into G1/G4 and would change existing output. Do not touch it. The consequence — that single-token MCP tool names are invisible to G7 — must be recorded in the rule-file prose as a known limitation, in the same style as the existing "Known false-negative class" section at `.claude/rules/plan-acceptance-gates.md:74-78`.

---

## Testing implications

Consistent with `.claude/rules/general-unit-test.md`: tests mirror the production tree, no temporary files, no external services, no wall-clock reads.

**Python — new file `tests/scripts/dev_tools/test_plan_gate_observability.py`:**
- Per rule: one positive case reconstructed from the catalogued defects, one negative case from the corrected form on disk, and one exoneration case.
- Register completeness: assert every entry of the write-mode register is reachable by at least one fixture, so an entry cannot be added without a test.
- Boundary cases: `git diff --cached`, `git diff -- path` with a pathspec but no ref, `git diff main` with a ref, a `--cov` command carrying `--cov-report=term`, a `--cov` command carrying `--cov-fail-under`.
- Graceful degradation for G9: a `git` seam that raises, and one that returns a non-zero exit, each producing zero findings and no exception.
- Attribution: a write-mode command in the document preamble, in a phase preamble, and after an intervening heading — all producing no finding.

**Python — amendments:**
- `tests/scripts/dev_tools/test_plan_gate_parity.py` — add the new module to `_PYTHON_GATE_MODULES` (`:39-42`); add one severity-constant regex and assertion per new rule; add parity fixtures including an apostrophe-bearing value for each rule that renders one.
- `tests/scripts/dev_tools/test_plan_gate_commands.py` — update the exact-record-fields test for `task_text`; add a test that `task_text` equals the owning task's attributed text and is empty for a span outside any window.

**TypeScript — new file `extensions/drm-copilot/test/lib/validate/plan-gate-observability.test.ts`**, mirroring the Python cases one for one, plus amendments to `plan-gate-parity.test.ts` (`GATE_MODULE_PATHS` at `:173-177`, `PARITY_CASES`, the severity constants) and `plan-gate-commands.test.ts`.

**Property-based tests.** `.claude/rules/quality-tiers.md` makes property-test density a T1/T2 obligation. The tier map it points to could not be located: **SearchScope:** whole worktree; **SearchPatterns:** glob `**/quality-tiers.y*ml`; **SearchResult:** no file found. The plan must not assert a tier lookup it cannot perform; either resolve the tier from an authoritative source at planning time or state the absence explicitly and justify the chosen test set on the general policy alone.

**Corpus measurement (evidence, not a test).** One throwaway driver, run once, output recorded at
`docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/`,
following the eight-step procedure of Q5 including the vacuity check and the driver-deletion evidence. The driver must be deleted and must not be committed.

**Regression fixtures** per Q7 Tier 1, recorded under
`docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/regression-testing/`.

**Toolchain.** The seven-stage loop of `.claude/rules/general-code-change.md`, restarted from stage 1 on any auto-fix. Note for the plan author, from Q3: `poetry run ruff check .` rewrites files and still exits 0, and `npm run format` rewrites files and still exits 0 — the acceptance conditions of this very fix must carry an observation beyond the exit code, or the fix will ship with the defect it repairs.

---

## Automation Feasibility

This work touches no third-party user interface. Every change is to repository source files, tests, prose policy files under `.claude/`, and their bundled mirrors under `extensions/drm-copilot/resources/`. Every verification is a local command: `poetry run black`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest`, `npm run format`, `npm run lint`, `npm run typecheck`, `npm test`, and the `validate_orchestration_artifacts` CLI or MCP tool. No web console, vendor dashboard, portal, or interactive credential flow is involved.

**No human-interaction requirement exists for this feature.** No task requires a human to click, authenticate, approve in an external system, or supply a value the repository does not already contain. The work is fully automatable end to end.

One item requires an explicit non-blocking decision rather than human interaction: the severity assignment for each new rule is fixed by the pre-declared measurement rule of Q5, applied to a measurement the executor performs. If the measurement is vacuous, the rule assigns Warning without any human input.

---

## Recommended approach, summarised

1. Add `PlanCommand.task_text`, populated from the attribution window the extractor already maintains. Additive; no existing rule reads it.
2. Add one new rule module per runtime — `scripts/dev_tools/plan_gate_observability.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` — carrying G7, G8 (with sub-rule G8b) and G9. Invoke each from the existing `evaluate_plan_gates` / `evaluatePlanGates` seam.
3. Keep G7 and G8 context-free; gate G9 on the repository context and place it inside the existing graceful-degradation guard.
4. Read `pyproject.toml` through the existing `read_tracked_text` seam and extract `addopts` with a dialect-portable regular expression. Do not add a TOML parser.
5. Exclude `git add` and `npm ci` from the write-mode register, and record the exclusions with their reasons.
6. Ship all new rules as Warnings pending the corpus measurement; let the pre-declared rule of Q5 decide, and record the result as an evidence artifact.
7. Amend `.claude/rules/plan-acceptance-gates.md` (rule table, severity decisions, uncovered sub-classes, the single-token-MCP-name limitation) and `.claude/skills/atomic-plan-contract/SKILL.md` (authoring bullets), and mirror both byte-for-byte into the bundled payload.
8. Reject the executor-choice heuristic as a validator rule; cover it in the authoring skill.

### Rejected alternatives

- **Relaxing the minimum-argv rule to reach single-token MCP tool names** — changes existing G1/G4 output on a lone `--cov=` span, which the constraints forbid.
- **Re-walking plan text inside the rule module instead of adding `task_text`** — produces a second implementation of the attribution-window invariant.
- **Parsing `pyproject.toml` with a TOML library** — `tomllib` needs Python 3.11 against a declared floor of 3.10, and the TypeScript side would need a new dependency.
- **A grandfathering list, exemption marker, or suppression comment** — prohibited by `.claude/rules/plan-acceptance-gates.md:7-13`; no sweep exists, so there is nothing to protect.
- **Shipping the executor-choice heuristic as a Warning** — its false-positive vocabulary is ordinary plan prose, and the rule file's own guidance is to weigh a rule on its authoring-time false-positive rate.
