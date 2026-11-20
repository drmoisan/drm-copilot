# Policy Audit — issue #519, plan acceptance gates G7/G8/G8b/G9

- Timestamp: 2026-08-26T10-50
- Branch: `bug/plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519-r3`
- Branch head: `2aa37434`
- Base / merge base: `main` at `1e991b86` (confirmed: `git merge-base HEAD 1e991b86` returns `1e991b86`)
- Work mode: `full-bug` (`issue.md` line 12) — `spec.md` is the sole acceptance-criteria source
- Scope audited: the full branch diff `1e991b86...HEAD`, 71 files, +8161 / -18

## Rejected Scope Narrowing

None. The delegating prompt directed a full-branch audit against the resolved base and supplied
no instruction to restrict the file set, skip a toolchain stage, or mark any language out of
scope. No narrowing was detected and none was applied.

## Verdict Summary

| Area | Verdict |
|---|---|
| Tone policy (`.claude/rules/tonality.md`) | PASS |
| Policy-document immutability (`.github/**`, unauthorised `.claude/rules/**`) | PASS |
| General code change (`.claude/rules/general-code-change.md`) | PASS |
| General unit test (`.claude/rules/general-unit-test.md`) | PARTIAL |
| Coverage exclusion policy | PASS |
| Quality tiers / uniform thresholds | PASS |
| File-size limit (500 lines) | PASS |
| Python rules (`.claude/rules/python.md`) | PASS |
| TypeScript rules (`.claude/rules/typescript.md`) | PASS |
| PowerShell rules | N/A — zero changed files |
| C# rules | N/A — zero changed files |
| Evidence location invariant | PASS |
| Mandatory toolchain loop (7 stages) | PASS |
| Coverage — Python | PASS |
| Coverage — TypeScript | PASS |
| Severity discipline (measured, not chosen) | PASS |

**Blocking findings: 0.**

## Coverage Verification

Coverage was verified from pre-existing artifacts and recorded evidence. No coverage run was
re-executed for the purpose of generating a metric; the test suites were re-run only to confirm
the recorded pass/fail state.

### Languages with changed files in the branch diff

| Language | Changed files | Coverage artifact | Repo-wide | New file | Modified files | Verdict |
|---|---|---|---|---|---|---|
| Python | 3 source, 5 test | `artifacts/python/lcov.info` (present) | line 92.69%, branch 89.80% | `plan_gate_observability.py` 97.12 line / 91.94 branch | `plan_gate_commands.py` 98.99 / 94.44; `plan_gate_discrimination.py` 97.71 / 86.54 | **PASS** |
| TypeScript | 3 source, 5 test, 1 config | `coverage/lcov.info` **absent**; substitute evidence recorded | line 96.71%, branch 90.14% | `plan-gate-observability.ts` 98.38 line / 91.91 branch | `plan-gate-commands.ts` 95.93 / 84.88; `plan-gate-discrimination.ts` 100 / 98.14 | **PASS** |
| PowerShell | 0 | n/a | n/a | n/a | n/a | N/A (zero changed files) |
| C# | 0 | n/a | n/a | n/a | n/a | N/A (zero changed files) |

Thresholds applied: line >= 85%, branch >= 75% (uniform tier rule,
`.claude/rules/quality-tiers.md`). Every figure above clears both.

**Python artifact.** `artifacts/python/lcov.info` exists (4263 bytes, mtime 2026-08-26 10:23). It
carries a single `SF:` record for `scripts\dev_tools\plan_gate_observability.py` with
`LF:139 LH:135 BRF:62 BRH:57`, giving 97.12% line and 91.94% branch for the new module. That
corroborates the recorded terminal figure of 96% (pytest-cov's combined `Cover` column) exactly.
The artifact is scoped to the new module because the last run that wrote it was the scoped
new-module coverage command; the repo-wide figures are taken from the recorded `TOTAL` row in
`evidence/qa-gates/python-test-final.2026-08-24T00-00.md`
(`TOTAL 15180 1109 5576 567 91%`), from which line = (15180−1109)/15180 = 92.69% and
branch = (5576−567)/5576 = 89.80%.

Verification command: `grep -E "^(LF|LH|BRF|BRH):" artifacts/python/lcov.info`

**TypeScript artifact — advisory, not a FAIL.** `coverage/lcov.info` is not present in the
worktree. The cause is visible and benign: `extensions/drm-copilot/jest.config.cjs` declares
`coverageReporters: ["lcov", "text-summary"]`, and the final coverage command recorded by
[P8-T9] was `npm test -- --coverage --coverageReporters=text`, which overrides the configured
reporter set and therefore writes no LCOV file. Coverage for TypeScript is nonetheless
established by two independent observations, both stronger than an LCOV totals line:

1. The verbatim per-file `text` table recorded in
   `evidence/qa-gates/typescript-test-final.2026-08-24T00-00.md`, giving line and branch
   percentages per changed file and for all files.
2. Jest's own per-file `coverageThreshold` gate. `jest.config.cjs` now declares
   `"./src/lib/validate/plan-gate-observability.ts": { lines: 85, branches: 75 }`, and Jest
   exits non-zero when a declared per-file threshold is unmet. The recorded exit code of 0 is a
   mechanical, second observation that both thresholds were met.

I re-ran the full Jest suite for confirmation: `199 passed, 199 total; 2710 passed, 2710 total`,
byte-consistent with the recorded evidence. The verdict is therefore **PASS**, with the absence
of `coverage/lcov.info` recorded as advisory finding **A-7** below rather than as a FAIL — the
threshold claim is verified from present evidence, not asserted.

Verification commands:
- `ls -la coverage/lcov.info extensions/drm-copilot/coverage/lcov.info` (both absent)
- `cd extensions/drm-copilot && npm test --silent`

## Evidence Location Compliance

**PASS.** No file in the branch diff is written under `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, or `artifacts/coverage/`. Every one of the 47 evidence artifacts sits
under `docs/features/active/<feature>/evidence/<kind>/` with `<kind>` in
`{baseline, qa-gates, regression-testing}`, which is the canonical scheme.

Verification commands:
- `git diff --name-only 1e991b86...HEAD | grep -E "^artifacts/"` — no matches (exit 1)
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — `EXIT=0`

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred; no delegation instruction specified a
non-canonical path.

## Policy-Document Immutability

**PASS.**

`.github/**` diff is empty:

```
git diff --stat 1e991b86...HEAD -- .github
(no output)
```

Four policy files were modified. All four are inside the authorisation the feature scope records
(`spec.md` lines 76-80, 144-149), and no fifth policy file was touched:

| File | Change | Additive? |
|---|---|---|
| `.claude/rules/plan-acceptance-gates.md` | +131 / −2 | Yes — see below |
| `.claude/skills/atomic-plan-contract/SKILL.md` | +9 / −0 | Yes, purely additive |
| `extensions/.../claude-customizations/.claude/rules/plan-acceptance-gates.md` | +131 / −2 | Mirror |
| `extensions/.../claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | +9 / −0 | Mirror |

**Additivity verified line by line.** The rule file's only two removed lines are:

1. The G5 measurement-artifact citation, replaced by the same sentence with the path corrected
   from `docs/features/active/2026-08-17-...` to `docs/features/completed/2026-08-17-...`. The
   corrected path resolves on disk (`ls` returns `EXIT=0`); the stale spelling now appears zero
   times. This is the one authorised correction.
2. The sentence beginning "G1 and G4 are context-free…", replaced by the same sentence with
   three clauses appended describing where G7/G8/G8b/G9 sit in the same split. No clause of the
   original sentence was removed or weakened.

**No existing rule was deleted or weakened.** G1 through G6 keep their rule-table rows verbatim,
their cascade paragraph verbatim, their severity-decision sections verbatim, and their shipped
severities. **G5 and G6 both still ship as Warning** — confirmed in the unchanged rule-table rows
and in `G5_SEVERITY`, whose parity test still passes.

**Mirrors byte-identical.** Verified by git blob hash, which is content-addressed:

```
git hash-object .claude/rules/plan-acceptance-gates.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md
ea905f5ec6080a4513c3a3fd18c03cbd8458cb08
ea905f5ec6080a4513c3a3fd18c03cbd8458cb08

git hash-object .claude/skills/atomic-plan-contract/SKILL.md \
  extensions/.../claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
e3b2198e4dac4c82d6c883bd370f04367a79e96e
e3b2198e4dac4c82d6c883bd370f04367a79e96e
```

Both pairs are equal. The push-down contract test passes in my full-suite run modulo the known
issue-#510 noise (see below).

## Coverage Exclusion Policy

**PASS.** The only non-Markdown, non-source file in the diff is
`extensions/drm-copilot/jest.config.cjs`, whose nine added lines are a per-file
`coverageThreshold` entry:

```js
"./src/lib/validate/plan-gate-observability.ts": {
  lines: 85,
  branches: 75,
},
```

This is a **threshold, not an exclusion**. It adds a gate to a new production file under `src/`;
`collectCoverageFrom` is unchanged (`["src/**/*.ts", "!src/**/*.d.ts"]`) and no `coveragePathIgnorePatterns`
entry, `exclude` entry, or `/* istanbul ignore */` pragma was added anywhere in the diff. The
prohibited case — an `exclude` entry matching a production source path — does not occur.

Verification command: `git diff 1e991b86...HEAD -- extensions/drm-copilot/jest.config.cjs`

## Severity Discipline — measured, not chosen

**PASS, independently reproduced.** This was the point I scrutinised hardest, because a severity
chosen to make something pass is the failure mode the feature exists to prevent.

**Ordering is verifiable from git, not only asserted.** Commit `7a339fac`
("docs(519): pre-declare the severity decision rule before any corpus count", 2026-08-26 09:24)
contains exactly one file — the decision-rule artifact, 67 insertions — and nothing else. The
measuring driver and its counts arrive fifteen minutes later in `5216a51d` (09:39). The
pre-declared artifact contains no measured integer; the only numeral in it is the threshold zero
that the rule itself names.

Verification command: `git show --stat --format='%H%n%ad%n%s' 7a339fac`

**Counts independently reproduced.** I re-ran the measurement with my own driver, calling the
shipped `evaluate_plan_gates` with a real `build_plan_gate_context`, over every `plan*.md` under
`docs/features`:

```
corpus_files=195
{'G7': 466, 'G8': 82, 'G8b': 19, 'G9': 8}
```

Every one of the four finding counts matches the recorded measurement exactly (G7 466, G8 82,
G8b 19, G9 8). The corpus file count differs by one (195 against the recorded 194) because the
branch's own plan is now in the tree; that file contributes zero findings, so no count moves.
The measurement is reproducible and non-vacuous.

**The pre-declared rule applied to the recorded counts yields exactly the shipped constants.**

| Rule | Findings > 0 | False positives = 0 | Rule yields | Shipped `*_SEVERITY` (both runtimes) |
|---|---|---|---|---|
| G7 | Yes (466) | No (22) | warning | `warning` |
| G8 | Yes (82) | No (7) | warning | `warning` |
| G8b | exempt | exempt | warning (unconditional clause) | `warning` |
| G9 | Yes (8) | No (4) | warning | `warning` |

**No rule ships Blocking.** Confirmed in `scripts/dev_tools/plan_gate_observability.py:63-66`
(all four assigned `WARNING_CHANNEL`) and
`extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts:51-60` (all four `"warning"`).
The two runtimes' constants are pinned equal by four parity assertions in
`tests/scripts/dev_tools/test_plan_gate_parity.py:445-470`, all passing.

**No severity appears chosen to make something pass.** I checked the incentive in both
directions. Classifying *more* false positives is what forces a rule down to Warning, so an
executor wishing to weaken the gate could inflate the false-positive count. I read all four
false-positive classes and each is substantively correct rather than padding:

- G7 class 1 (`npm run format -- --check`, 2 findings) — genuinely read-only; the register entry
  declares no check-flag exclusion, so the match is a real defect in the predicate.
- G7 class 2 (20 findings) — the task carries a `git status --porcelain` span, which is a real
  observation the marker set does not model.
- G8 class 1 (`git diff --no-index`, 6 findings) — the finding's own stated claim is false for
  this form.
- G9 (4 findings) — three are prose quotations rather than stated commands; one is a truncated
  restatement of a command that does supply a reporter.

Each classification is named by plan path, task identifier, and offending span in
`evidence/qa-gates/corpus-measurement.2026-08-24T00-00.md`, so the classification is auditable
rather than asserted. G8b, the only rule whose measured false-positive count is zero, is held at
Warning by a clause declared before the counts existed, on a stated reason (its false-positive
*surface* is not bounded by one corpus). That is the opposite of a severity chosen for
convenience.

**Recorded for the record, not as a finding.** The delivered enforcement strength is advisory.
All four rules ship in the Warning channel, and the rule file's own Scope-of-Invocation clause
states that nothing sweeps the committed plan corpus. The practical effect is that these rules
surface information to a plan author and cannot fail a gate. That outcome is licensed by the
pre-declared rule and follows the G5 precedent; it is stated here so a reader does not overread
the change as adding four blocking gates.

## Mandatory Toolchain Loop

All seven applicable stages independently re-run by this review, check-only where a check-only
form exists.

| Stage | Command | Result |
|---|---|---|
| Format (Python) | `poetry run black --check .` | `455 files would be left unchanged.` — PASS |
| Lint (Python) | `poetry run ruff check --no-fix .` | `All checks passed!` — PASS |
| Type check (Python) | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` — PASS |
| Format (TS) | recorded [P8-T6]: 408 processed lines, 408 `(unchanged)`; `git status --porcelain` empty | PASS |
| Lint (TS) | `npm run lint` | no diagnostic output — PASS |
| Type check (TS) | `npm run typecheck` (`tsc -p ./ --noEmit`) | no diagnostic output — PASS |
| Unit tests (Python) | `poetry run pytest -q --no-cov` | `1 failed, 4194 passed, 5 skipped` — see below |
| Unit tests (TS) | `npm test` | `199 suites passed, 2710 tests passed` — PASS |
| Architecture boundary | dependency-cruiser config unchanged; no new cross-layer edge (the new Python module's only runtime import is `plan_gate_commands`, and `plan_gate_discrimination` importing it is the single new edge, acyclic) | PASS |
| Contract / schema | no schema file added, read, or changed; MCP input-schema key set unchanged | PASS |

Note on the check-only substitutions: `black --check` and `ruff check --no-fix` were used
deliberately in place of the write-mode forms, per this repository's own G7/G8 guidance. The
observation that discriminates a clean run is recorded in each case (`would be left unchanged`,
`All checks passed!`) rather than the exit code alone.

**The single Python test failure is the known issue-#510 noise, not a defect of this branch.**
The failing test is
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
and its assertion names exactly one missing path:

```
AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
```

That path carries the `.claude/state/` prefix, which is the issue-#510 signature: a gitignored,
machine-local counter that regenerates whenever the Python toolchain runs. I confirmed the file
exists on disk with an mtime inside this session and that `.gitignore` carries `.claude/state/`.
**No other missing path was reported and no other test failed**, so no genuine bundle-parity
shortfall is masked. CI, whose checkout never contains the file, is unaffected.

## General Unit Test Policy — PARTIAL

Independence, isolation, determinism, speed, and readability all hold. Test files live under
`tests/` (Python) and `extensions/drm-copilot/test/` (TypeScript), mirroring the production
tree; no test file was colocated into `src/` or `scripts/`. No temporary file is created by any
new test; every seam is an in-memory stub. Arrange–Act–Assert structure is used consistently and
each test carries a docstring or `it(...)` description naming its scenario.

The verdict is PARTIAL, not PASS, on **Scenario Completeness**. Three negative flows in the new
module are unreachable by any test in either runtime. The evidence is the coverage tooling's own
missing-line list, not an inference:

```
scripts\dev_tools\plan_gate_observability.py  139  4  62  5  96%  250, 397->395, 399, 414, 422
extensions/.../plan-gate-observability.ts     98.38  91.91  100  98.38  253-254,413-414,430-431,441-442
```

- **Line 250 (Python) / 253-254 (TypeScript) — the `excludes` mechanism is never exercised.**
  That statement is the `continue` that fires when a register entry's exclusion word is present
  in the argv. It is what stops G7 reporting `black --check`, `black --diff`, and
  `ruff check --no-fix` — the read-only forms this repository's own guidance instructs plans to
  use. A grep confirms no test in either runtime supplies any of those three flags:
  `grep -n "no-fix\|--check" <the four observability test files>` returns nothing (exit 1).
  A regression that emptied every `excludes` tuple would pass the entire suite.
- **Line 397->395 / 399 (Python), 413-414 (TypeScript) — the single-quoted `addopts` pattern is
  never reached, and neither is the no-assignment return.** `_ADDOPTS_PATTERNS` has two elements;
  the loop's continue-branch is uncovered, so the second (single-quoted) pattern is dead in test.
  `spec.md` lines 366 and 375 record cross-runtime regex-dialect divergence as a named risk and
  state the mitigation as "add a parity fixture whose configuration value exercises quoting and
  whitespace variation". Both runtimes' parity fixtures use only the double-quoted form
  (`_PARITY_PROJECT_TEXT` / `PARITY_PROJECT_TEXT`), so that mitigation was not delivered.
- **Line 422 (Python) / 441-442 (TypeScript) — G9's project-supplies-a-reporter exoneration is
  never exercised.** No test supplies an `addopts` value containing `--cov-report=term`, so the
  branch that the whole `addopts` read exists to serve is untested.

None of these is required by any acceptance criterion, so none is an unearned check-off, and the
module's aggregate figures (97.12 line / 91.94 branch Python; 98.38 / 91.91 TypeScript) are well
above policy. They are recorded as **Major finding M-1** below because they are negative flows
on load-bearing predicates, and the policy's Scenario Completeness clause names negative flows
and error-handling behaviour as required coverage.

## File-Size Limit

**PASS.** Every file created or modified by this change is at or under 500 lines. Independently
measured with `wc -l`:

| File | Lines |
|---|---|
| `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` | 494 |
| `tests/scripts/dev_tools/test_plan_gate_parity.py` | 493 |
| `scripts/dev_tools/plan_gate_observability.py` | 477 |
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py` | 449 |
| `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` | 443 |
| `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` | 437 (unmodified) |
| `tests/scripts/dev_tools/test_plan_gate_observability.py` | 427 |
| `extensions/drm-copilot/test/lib/validate/plan-gate-observability.test.ts` | 394 |
| `scripts/dev_tools/plan_gate_discrimination.py` | 392 |
| `extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts` | 389 |
| `scripts/dev_tools/plan_gate_commands.py` | 365 |
| all remaining changed source/test/config files | < 350 |

The tightest margin is six lines on `plan-gate-observability.ts`. The spec's justification for
splitting the rule group into a new module per runtime (rather than extending
`plan-gate-rules.ts` at 437 lines) is borne out: extending it was not viable.

## Tone Policy

**PASS.** I read all four amended policy sections, both new module docstrings, and a sample of
twelve evidence artifacts. No jokes, hyperbole, metaphor, emoji, celebratory phrasing, or
motivational language. Claims are matched to evidence throughout, and the evidence artifacts
consistently report unfavourable facts without softening — for example
`no-suppression-surface.2026-08-24T00-00.md` reports non-zero raw match counts before stating its
`none` classification, and `corrected-forms-no-fire.2026-08-24T00-00.md` opens with a
supersession notice stating that its own earlier run was vacuous and is not carried forward.

## Findings

### Blocking: 0

### Major (non-blocking, recommended follow-up)

**M-1 — Three negative flows in the new rule module are unreachable by any test in either
runtime.** Detailed above under General Unit Test Policy. Highest-value of the three is the
`excludes` mechanism (`plan_gate_observability.py:249-250`,
`plan-gate-observability.ts:252-254`), which guards the exact false-positive class the rule file
names for `prettier-write`. Recommended: one positive-exclusion test per runtime
(`poetry run black --check .` and `poetry run ruff check --no-fix .` each producing zero G7
findings), one parity fixture with a single-quoted `addopts` value, and one G9 test whose project
value supplies `--cov-report=term`. Verification command for the gap:
`grep -n "no-fix\|--check" tests/scripts/dev_tools/test_plan_gate_observability*.py extensions/drm-copilot/test/lib/validate/plan-gate-observability*.test.ts`

**M-2 — The write-mode register's marker and exclusion data are not pinned equal across the two
runtimes.** `spec.md` line 207 states the register is "duplicated across the two runtimes and
pinned equal by a parity assertion". The shipped mechanism is weaker: the six-entry *fixture*
lists are mirrored in `test_plan_gate_observability.py:28-35` and
`plan-gate-observability.test.ts:41-48`, which pins each entry's argv *shape*, and one
cross-runtime parity row (`PARITY_G7`, `black-write`) plus one exoneration test per runtime pins
`black-write`'s markers. The `markers` and `excludes` tuples of the other five entries
(`ruff-fix`, `prettier-write`, `poshqc-format`, `poshqc-analyze-autofix`, `poshqc-suite`) are
asserted in neither runtime and compared across neither. A marker divergence between the two
copies would ship silently. Recommended: a register-content parity assertion in the same shape as
the existing severity-constant assertions, reading the TypeScript literal and comparing it to the
Python tuple.

### Advisory

**A-1 — Five new rule-file citations name the active feature tree and will go stale on
completion.** `.claude/rules/plan-acceptance-gates.md` cites
`docs/features/active/2026-08-23-plan-acceptance-gates-.../evidence/qa-gates/corpus-measurement.2026-08-24T00-00.md`
five times, and both new rule modules cite the same active path in their header comments
(`plan_gate_observability.py:59-62`, `plan-gate-observability.ts:46-49`). When this feature's
folder moves to `docs/features/completed/`, all seven citations break — which is precisely the
defect this change repairs for the G5 citation in the same file. Verification command:
`grep -c -F "corpus-measurement.2026-08-24T00-00.md" .claude/rules/plan-acceptance-gates.md` → 5.

**A-2 — One register entry is named incorrectly in the rule file.** The rule file states "The six
entries are `black-write`, `ruff-fix`, `prettier-write`, `poshqc-format`,
`run_poshqc_analyze_autofix`, and `poshqc-suite`." The fifth entry's `name` field is
`poshqc-analyze-autofix`; `run_poshqc_analyze_autofix` is the MCP tool the entry's argv suffix
matches, which the very next sentence states correctly. Documentation inaccuracy only; no code
or test depends on it.

**A-3 — A pre-existing TypeScript assertion was weakened.** In
`extensions/drm-copilot/test/lib/validate/orchestration-artifacts-plan-gates.test.ts:197-203`,
`expect(runner.calls[0]).toEqual([...])` became `expect(runner.calls).toContainEqual([...])`.
The change is necessary (G9 now issues a `git show HEAD:pyproject.toml` call ahead of the literal
query) and is commented in place, but the guarantee that the grep query is the *first* git call
is gone rather than re-expressed at the new position. Low risk; recorded so the reduction is on
the record.

**A-4 — A pre-existing test fixture was edited because a new rule fired on it.**
`tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py::_G1_PLAN` gained
`--cov-report=term-missing` so that G9 stops reporting it and the file's stderr assertion holds.
This is disclosed and analysed in `evidence/regression-testing/g1-fixture-isolation.2026-08-24T00-00.md`,
which shows the repair was applied to the fixture rather than to any assertion, and confirms
G1's finding count (1) and finding string are unchanged for that fixture. The invariant as
written — G1 through G6 *output* is unchanged for any given input — holds. Recorded because it is
the one place where an existing test had to move.

**A-5 — Evidence `Timestamp:` fields are not on one consistent clock, and several postdate the
commit that introduced them.** Examples:
`evidence/regression-testing/g1-fixture-isolation.2026-08-24T00-00.md` records `2026-08-26T14-55`
but was introduced by commit `c6275d57` at 09:00:21 −0400;
`evidence/qa-gates/file-line-counts.2026-08-24T00-00.md` records `2026-08-26T14-48` in the same
commit; `evidence/qa-gates/ac-reconciliation.2026-08-24T00-00.md` records `2026-08-26T10-52` but
was introduced by `2aa37434` at 10:36:57 −0400. The set spans at least two offsets. This does not
undermine any substantive claim — every substantive claim I could check, I checked directly — and
critically, **the one load-bearing chronology claim (decision rule declared before measurement)
rests on git history, which I verified independently, not on these fields.** Recorded so the
fields are not later relied on to establish ordering. Verification command:
`git log --format='%h %cd' --date=iso-local -1 -- <artifact path>`

**A-6 — The vacuity guard on [P5-T5] does not bound the size of the derived corrected-form
list.** The guard tests that each commit's non-empty-acceptance-text count exceeds half its task
count, which correctly closes the failure mode that made the first run vacuous. It does not test
`corrected_count > 0`. A derivation yielding an empty corrected-form list would pass the guard
and satisfy the criterion vacuously. In this run `corrected_count=7` with all seven entries
reproduced in full, so the recorded result is non-vacuous in fact; the guard simply does not
guarantee that property. See the feature audit, AC29.

**A-7 — `coverage/lcov.info` is absent for TypeScript.** Cause and substitute evidence are set
out under Coverage Verification above. Regenerating it is a one-command operation
(`npm test -- --coverage`, without the reporter override) and would let a downstream consumer
verify the figures mechanically rather than from a recorded table.

**A-8 — The attribution window remains an author-reachable blind spot, and this feature's own
plan uses it.** `plan.2026-08-23T23-22.md:52` quotes the two frozen defective spans in the
document preamble, stating explicitly that "a span in the document preamble belongs to no
attribution window and is dropped by the extractor". The use is legitimate and disclosed — the
spans define fixture text and are not acceptance conditions of any task — but it illustrates that
an author can place a genuinely defective span outside every window and no rule can report it.
This follows from the pre-existing attribution-window design documented in the rule file, not
from anything this change introduces. Recorded because a reader should not credit the new rules
with coverage they do not have.

## Local Environment Note (not a branch finding)

While probing the CLI I found that `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan <path>`
resolves `scripts.dev_tools` to the **main checkout** at `C:\Users\DanMoisan\repos\drm-copilot\scripts\dev_tools`
rather than to this worktree, so it silently evaluates the pre-change rule set and prints no
new-rule warnings:

```
import scripts.dev_tools.plan_gate_discrimination as d; print(d.__file__)
C:\Users\DanMoisan\repos\drm-copilot\scripts\dev_tools\plan_gate_discrimination.py
import scripts.dev_tools.plan_gate_observability  ->  No module named ...
```

This is a worktree/editable-install path artifact of the local environment, **not a defect of
this branch**. With the worktree placed on `sys.path` first, the CLI-equivalent library call
produces all four new-rule findings on a probe fixture and produces the recorded six findings on
`docs/features/active/2026-08-07-parallel-schema-validators-444/plan.2026-08-07T11-11.md`,
matching the corpus measurement exactly. `pytest` is unaffected (it resolves the worktree copy,
which is why all 92 plan-gate tests pass). Flagged only so that a future reviewer using the CLI
in a worktree is not misled into reading a clean CLI run as evidence.

## Overall Verdict

**PASS with 0 blocking findings.** The branch is policy-compliant. Two Major findings (M-1, M-2)
identify real test-coverage gaps on negative flows and a weaker-than-specified parity mechanism
for the write-mode register; neither prevents merge and both are well-formed follow-up work.
Eight advisory items are recorded.

**Remediation is NOT required.** No remediation-inputs artifact is produced, because producing
one with zero remediation-required findings would be a false trigger for a remediation cycle.
M-1 and M-2 are carried in this audit and in `code-review.2026-08-26T10-50.md` (MAJOR-1,
MAJOR-2) as follow-up work, and are suitable for a separate issue rather than a fix on this
branch: both are additive test work, neither changes shipped behaviour, and neither can be
addressed without re-opening the corpus measurement question for the `excludes` predicate.
