# Policy Compliance Audit — 2026-08-07-parallel-mutation-protocol-442

- **Timestamp:** 2026-08-09T00-19
- **Feature:** `docs/features/active/2026-08-07-parallel-mutation-protocol-442`
- **Issue:** #442 (epic `parallel-orchestration`, child F6, wave 4)
- **Branch:** `feature/parallel-mutation-protocol-442`
- **Diff base (pinned):** `c939b5b8`
- **Work mode:** `full-feature` (AC sources: `spec.md` S1-S15 and `user-story.md` U1-U9)
- **Reviewer:** feature-review agent

## Scope

The audit scope is the full branch diff against `c939b5b8`, comprising 13 modified tracked
files and 23 untracked additions. No caller narrowing was attempted; see
`## Rejected Scope Narrowing`.

**Working-tree state note.** `HEAD` resolves to `c939b5b8` exactly. The branch carries
**zero commits**; every deliverable is present only as an uncommitted working-tree
modification or an untracked file. All diffs below were therefore taken against
`c939b5b8` with untracked files enumerated from `git status --porcelain`.

## Rejected Scope Narrowing

None. The caller directive supplied the full-branch scope, the pinned base `c939b5b8`,
and both AC sources, and explicitly instructed that reported state be verified rather
than trusted. No instruction attempted to limit scope to a plan, task, phase, file
subset, or to mark any language's coverage as informational.

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exited **0** with no output.

Branch diff scanned for files under `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, `artifacts/coverage/`: **none found**. All feature evidence is
written to the canonical `<FEATURE>/evidence/<kind>/` tree:

```
docs/features/active/2026-08-07-parallel-mutation-protocol-442/evidence/
  baseline/  other/  qa-gates/  regression-testing/
```

`artifacts/python/lcov.info` and `artifacts/pester/{pester-junit.xml,powershell-coverage.xml}`
are pre-existing toolchain output locations, not evidence paths.

**Verdict: PASS.**

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
6. `.claude/rules/powershell.md`
7. `.claude/rules/self-explanatory-code-commenting.md`
8. `.claude/rules/parallel-orchestration.md` (F3-owned schema and enum-ownership prose)
9. `.claude/rules/tonality.md`

No policy document was modified. `git diff --stat c939b5b8 -- .claude/rules/` is empty.

## Language Coverage Verdicts (mandatory, explicit)

| Language | Changed files on branch | Coverage artifact | Repo-wide line | Repo-wide branch | Verdict |
|---|---|---|---|---|---|
| Python | 7 production, 7 test, 2 modified test-support | `artifacts/python/lcov.info` (present) | **92.05%** | **84.19%** | **PASS** |
| PowerShell | 1 production hook, 1 test, 2 runsettings | `artifacts/pester/powershell-coverage.xml` (present) | **94.81%** (measured set) | n/a (Pester line only) | **PASS** |
| TypeScript | **0** | n/a | n/a | n/a | N/A — zero changed files |
| C# | **0** | n/a | n/a | n/a | N/A — zero changed files |

### Python coverage detail

Command: `poetry run pytest --cov --cov-branch --cov-report=term`
Result: `3386 passed in 12.06s`, exit 0.

Separate line/branch figures extracted via `poetry run coverage json`:

```
num_statements 13922   percent_statements_covered 92.04855624191926
num_branches   5122    percent_branches_covered   84.18586489652479
```

Thresholds (`.claude/rules/quality-tiers.md`, uniform T1-T4): line >= 85%, branch >= 75%.
Both satisfied. Reported baseline was line 91.82% / branch 83.80%, so both improved; no
regression.

Per-file coverage of every new production module (from `term` report):

| File | Stmts | Miss | Branch | BrPart | Cover |
|---|---|---|---|---|---|
| `scripts/dev_tools/_parallel_mutation_entries.py` | 13 | 0 | 0 | 0 | 100% |
| `scripts/dev_tools/_parallel_mutation_errors.py` | 34 | 0 | 0 | 0 | 100% |
| `scripts/dev_tools/_parallel_mutation_models.py` | 95 | 0 | 30 | 0 | 100% |
| `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` | 66 | 0 | 32 | 0 | 100% |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` | 67 | 0 | 28 | 0 | 100% |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` | 62 | 0 | 10 | 0 | 100% |
| `scripts/dev_tools/parallel_mutation_protocol.py` | 44 | 0 | 22 | 0 | 100% |

All seven new files: 100% line, 100% branch. New-code tier thresholds (>= 85% line,
>= 75% branch) satisfied with margin. Modified file
`scripts/dev_tools/validate_parallel_orchestrator_state.py` gained two lines, both on the
covered path (module import + call line inside the validated entry point); no regression.

### PowerShell coverage detail

Command: `Invoke-PoshQCTest` (PoshQC module, repo `pester.runsettings.psd1`).
Result from `artifacts/pester/pester-junit.xml`:

```
<testsuites name="Pester" tests="2053" errors="0" failures="1" disabled="9" time="100.218">
```

2043 passed / 1 failed / 9 skipped, matching the reported state exactly. The single failure
is pre-existing and out of scope (see `## Pre-Existing Failure`).

New hook coverage, computed from `artifacts/pester/powershell-coverage.xml`:

```
.claude/hooks/enforce-parallel-abandon-gate.ps1
  LINE missed=12 covered=80  ->  86.96%
```

Matches the reported 86.96%, above the 85% line threshold. The 12 uncovered lines are the
post-dot-source-guard entry-point block and `Get-ParallelAbandonGateToolInput`'s single
`$env:` read — the thinnest-possible host-bound wiring, which is the shape
`.claude/rules/general-unit-test.md` § Coverage Exclusion Policy prescribes. The hook was
**measured, not excluded**.

The new hook's own suite contributes 22 cases, 0 failures:

```
<testsuite name="...\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1"
           tests="22" errors="0" failures="0" ...>
```

### Coverage exclusion policy

`.claude/rules/general-unit-test.md` prohibits any `exclude` entry matching a production
source path. Verified:

- `pyproject.toml` `[tool.coverage.run] omit` is unchanged by this branch
  (`git diff c939b5b8 -- pyproject.toml poetry.lock` is empty).
- `pester.runsettings.psd1` uses an **inclusion allowlist** (`CodeCoverage.Path`), not an
  exclude list. The branch's edit is `+5/-0` in each of the two copies: one appended
  production path plus a four-line rationale comment. Nothing was removed, so no
  previously measured file lost measurement.

**Verdict: PASS** — no prohibited exclusion added; the edit is coverage-increasing.

## Toolchain Gate Results (independently re-run)

| Stage | Command | Result | Verdict |
|---|---|---|---|
| Python format | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` | `382 files would be left unchanged` | PASS |
| Python lint | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` | `All checks passed!` | PASS |
| Python type-check | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` | PASS |
| Python tests | `poetry run pytest --cov --cov-branch --cov-report=term` | `3386 passed`, exit 0 | PASS |
| PowerShell format | `Invoke-Formatter` per PoshQC's own procedure (LF-normalize, `settings/pssa.settings.psd1`) against both new PS files | `ALREADY FORMATTED` for both | PASS |
| PowerShell lint | `Invoke-PoshQCAnalyze` | `PSScriptAnalyzer passed: no findings` | PASS |
| PowerShell tests | `Invoke-PoshQCTest` | 2043 passed / 1 pre-existing failure / 9 skipped | PASS (see below) |
| Architecture boundary | n/a — no TypeScript or C# changed files; no dependency-cruiser or NetArchTest surface touched | — | N/A |
| Contract / schema | `.claude/rules/parallel-orchestration.md` unmodified; no schema file authored or read | verified empty diff | PASS |

Formatting note: an initial format check using a guessed settings path
(`PSScriptAnalyzerSettings.psd1`, which does not exist) reported a spurious difference. Re-run
using PoshQC's actual procedure — CRLF-to-LF normalization then
`scripts/powershell/PoshQC/settings/pssa.settings.psd1`, per
`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:56-62` — reported `ALREADY FORMATTED` for the
new hook, its test, and the pre-existing `enforce-epic-worktree-removal-gate.ps1` control.

## Pre-Existing Failure (recorded, out of scope)

- File: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Case: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Site: `enforce-pr-author-skill.Tests.ps1:142`
- Message: `Expected: 'allow' But was: 'deny'`

Confirmed by parsing the `<failure>` element's nearest enclosing `<testcase>` in
`artifacts/pester/pester-junit.xml`. The enclosing `<testsuite>` reports `tests="46"
failures="1"`, and it is the only failure in the entire 2053-case run.

`.claude/hooks/enforce-pr-author-skill.ps1` and its test are **not in the branch diff**
(absent from `git status --porcelain`). The hook reads the real gitignored
`artifacts/orchestration/orchestrator-state.json` instead of a mocked seam, so its verdict
depends on live orchestration state. This is environment-driven, fails identically at
baseline (recorded in `evidence/baseline/baseline-ps-test-coverage.md`), and is **not a
regression from this feature**. It was correctly left unedited rather than weakened to force
a green gate — that restraint is the right call and is recorded here as such.

**Verdict: out of scope, no finding against #442.**

## File Size Limit (`.claude/rules/general-code-change.md`, 500 lines)

`wc -l` over every new and modified non-Markdown file:

| File | Lines |
|---|---|
| `scripts/dev_tools/_parallel_mutation_models.py` | 450 |
| `scripts/dev_tools/parallel_mutation_protocol.py` | 393 |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` | 361 |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` | 313 |
| `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` | 289 |
| `scripts/dev_tools/_parallel_mutation_entries.py` | 249 |
| `scripts/dev_tools/_parallel_mutation_errors.py` | 229 |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 259 |
| `tests/.../test_parallel_mutation_protocol_ops.py` | **500** |
| `tests/.../test_parallel_mutation_protocol_properties.py` | 499 |
| `tests/.../test_parallel_mutation_protocol.py` | 498 |
| `tests/.../test_validate_parallel_orchestrator_state_mutations.py` | 398 |
| `tests/.../test_parallel_mutation_abandon_cli.py` | 370 |
| `tests/.../test_parallel_abandon_token_seam.py` | 330 |
| `tests/.../test_validate_parallel_orchestrator_state_mutation_modes.py` | 175 |
| `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` | 164 |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` (modified) | 338 |

Maximum is exactly 500 (`test_parallel_mutation_protocol_ops.py`), at the cap and therefore
permitted. **Verdict: PASS**, with the advisory that three test files sit at 498-500 lines
and leave no headroom for a future case without a further split.

## Test Policy Compliance (`.claude/rules/general-unit-test.md`)

| Requirement | Evidence | Verdict |
|---|---|---|
| Test file location mirrors production tree; no colocation | All Python tests under `tests/scripts/dev_tools/`; hook test under `tests/scripts/claude-hooks/`. `ls scripts/dev_tools/ \| grep -i test` returns nothing | PASS |
| No temporary files | `grep -rn "tmp_path\|tempfile\|TemporaryDirectory\|NamedTemporary\|New-TemporaryFile\|TestDrive"` over all 8 new test files: **no matches** (rc=1) | PASS |
| No external services / live executables | Only `subprocess` reference is in `test_parallel_mutation_abandon_cli.py:342`, which `monkeypatch.setattr(cli.subprocess, "run", fake_run)` and `monkeypatch.setattr(cli.shutil, "which", fake_which)`; no process is started. No test invokes live `gh` or `git`. Pester test mocks `Get-ParallelAbandonGateToolInput` | PASS |
| Controllable clock; production under test never reads wall clock | `grep -rn "datetime.now\|datetime.utcnow\|time.time\|Get-Date"` over all 7 new production modules and the hook: **no matches** (rc=1). `clock: Callable[[], datetime]` is a **required** keyword parameter on all four entry constructors (`_parallel_mutation_entries.py:85,136,180,230`) | PASS |
| Seeded RNG prints seed on failure | `random.Random(seed)` at `test_parallel_mutation_protocol_properties.py:125,308`; `GeneratedRun.__str__` (lines 174-185) emits `seed=...`, interpolated into every assertion message; pytest case ids are `seed{N}` (line 188) | PASS |
| Banned timing APIs | No `sleep`, `Start-Sleep`, `Task.Delay`, or retry loop in any new test | PASS |
| AAA structure, descriptive names, docstrings | Verified across all eight new suites; `# Arrange` / `# Act` / `# Assert` comments present, every test carries a docstring | PASS |
| Property test density (T1/T2: >= 1 per pure function) | `test_parallel_mutation_protocol_properties.py` `TestPerFunctionProperties` covers `decide_admission`, `recolor_unstarted`, `decide_removal`, `decide_close`, `is_closed_mode_complete`, and all four entry constructors; P1/P2/P3 classes cover the pinning invariant | PASS |

`hypothesis` was correctly not added: `git diff c939b5b8 -- pyproject.toml poetry.lock` is
empty. Seeded-RNG substitution is the branch the spec's Constraints & Risks item 2 authorizes.

## Enum Ownership — "F6/F7/F8 consume, never extend"

`.claude/rules/parallel-orchestration.md` § Enum Ownership fixes all nine parallel enums as
F3-owned.

**Schema fields:** no field added to `mutations[]`, `drift_events[]`, or `conflict_edges[]`.
`_parallel_orchestrator_state_mutations.py:146-158` actively *rejects* an eighth field
(`carries unexpected field: ...`), which is the opposite of extension.
`git diff --stat c939b5b8 -- scripts/dev_tools/_parallel_state_common.py
_parallel_state_structures.py _parallel_state_records.py` is empty.

**Enum members:** all nine member sets are **imported** from F3's
`scripts/dev_tools/_parallel_state_common.py`, not restated:

```python
# scripts/dev_tools/_parallel_mutation_models.py:65-71
from scripts.dev_tools._parallel_state_common import (
    MERGED_MERGE_STATUSES, VALID_DISPOSITIONS, VALID_ITEM_STATES,
    VALID_MERGE_STATUS, VALID_MUTATION_OPS,
)
```

`parallel_mutation_abandon_cli.py:52` imports `VALID_DISPOSITIONS` and uses it directly as the
argparse `choices` (line 237). `_parallel_orchestrator_state_mode_completion.py:64-68` imports
`MERGED_MERGE_STATUSES` and `VALID_MODES`.

Derived subsets are bound back to F3 by assertion:
`test_parallel_mutation_protocol.py:86-101` asserts `UNSTARTED_ITEM_STATES ⊆
VALID_ITEM_STATES`, `PINNED_ITEM_STATE ∈ VALID_ITEM_STATES`, and `ABANDON_DISPOSITION ∈
VALID_DISPOSITIONS`.

**Verdict: PASS on enum-member ownership**, with one restatement gap recorded as Partial
finding **P1** below (F3's *op-classification* tuples, not enum members, are copied without a
binding test).

## Wave-4 Contention Confinement

| Shared file | Required confinement | Observed | Verdict |
|---|---|---|---|
| `.claude/skills/parallel-orchestrate/SKILL.md` (F5) | append inside the reserved section only; no reflow/reorder | `--numstat` = `144 1`; **one hunk** `@@ -434,7 +434,150 @@`; the single removal is the F6 placeholder sentence; F6 heading at 435, added lines end 580, F7 heading at 582, F8 at 586 — original F6→F7→F8 order preserved | PASS |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` (F3) | exactly one additive import + one call line | `+2/-0`: import at line 38, call at line 325, sitting between `_validate_collections` (324) and `# BEGIN F7 EXTENSION SEAM` (327). F7's seam block untouched | PASS |
| `.claude/settings.json` (shared) | one additive `PreToolUse` → `Bash` entry | `+4/-0`; appended after `enforce-epic-worktree-removal-gate.ps1`; six pre-existing entries unchanged and in order | PASS |

Additive-only constraint (`spec.md` constraint 5): `git diff --stat c939b5b8 --` shows no
modification under `.claude/hooks/enforce-epic-*`, no epic skill/agent/validator, and no
`.claude/rules/` file. Verified independently.

## Out-of-Table Edits (four, assessed for necessity and minimality)

### (a) F5 surface-contract test — `POPULATED_RESERVED_HEADINGS`

- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` `+7/-0`
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` `+12/-3`

**Necessary.** The landed F5 test
`test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body` asserted all three
reserved wave-4 sections still hold the one-line placeholder. Populating the F6 section — the
work the plan mandates — necessarily falsifies it. The two obligations are mutually exclusive.

**Minimal, and does not over-weaken.** `RESERVED_HEADINGS` is unchanged, so the three
surviving F5 assertions still bind the populated section:

- `test_orchestrate_skill_first_thirteen_headings_match_required_layout` — still asserts
  exactly 16 `##` headings and the pinned first thirteen.
- `test_orchestrate_skill_reserved_wave_four_sections_close_the_file` — still asserts
  `headings[-3:] == RESERVED_HEADINGS` and per-heading uniqueness.
- Only the placeholder-*body* assertion is scoped down, by a two-line `continue` guard.

**Leaves F7/F8 a one-line append.** Each appends its own heading string to the
`POPULATED_RESERVED_HEADINGS` tuple literal. No restructure is forced.

**Verdict: PASS.**

### (b) Extension bundle mirror and `pack-manifests/core.json`

**Necessary** (landed contract tests require byte mirrors and manifest registration).
**Byte-identity independently verified** — seven `diff` invocations, all rc=0:

```
settings rc=0   orchestrate rc=0   hook rc=0
add rc=0        remove rc=0        close rc=0        pester rc=0
```

`core.json` is `+4/-0`, four path insertions at sorted positions, zero removals or reorders.

**Verdict: PASS.**

### (c) `pester.runsettings.psd1`, both copies

`+5/-0` each. Adds `.claude/hooks/enforce-parallel-abandon-gate.ps1` to the
`CodeCoverage.Path` **inclusion allowlist** plus a four-line rationale comment. No production
file is excluded — an inclusion allowlist cannot exclude, and nothing was removed. The two
copies are byte-identical (`diff` rc=0). The hook is confirmed present in
`artifacts/pester/powershell-coverage.xml` and measured at 86.96%.

**Verdict: PASS.**

### (d) Feature documentation

- `user-story.md` `+9/-9` — **marker flips only**, criterion text byte-identical across all
  nine items (full diff inspected).
- `spec.md` `+61/-?` — includes the 15 AC marker flips with **criterion text unchanged**, and
  additionally amends the normative per-op entry-contents table (`prior_state`
  `prepared` → `null` on both `add` rows), adds an explanatory note, and bumps
  Version 1.0 → 1.1. This is a substantive non-AC amendment, **self-authorized** by the
  original spec's own clause ("if F3 constrains these differently, the landed shape wins and
  this table is updated at plan time") and by `.claude/rules/parallel-orchestration.md`
  invariant 16. Recorded in `evidence/other/upstream-f3-mutations-schema.md`.
- `plan.md` — checkbox and revision updates.

**Verdict: PASS**, with the clarification that (d) is not "marker flips only" for `spec.md`;
it is marker flips **plus** a pre-authorized landed-shape correction, correctly versioned and
evidenced.

## The `mutations[].prior_state` Correction — Coherence Assessment

The landed F3 rule is `OPS_REQUIRING_NULL_PRIOR_STATE = ("add", "close")`
(`scripts/dev_tools/_parallel_state_records.py:53`), enforced with
`prior_state must be null for op 'add'`.

Implementation matches: `_parallel_mutation_entries.py:121-129` constructs both add rows with
`prior_state=None`, `new_state="scheduled"`. `MutationEntry.__post_init__` makes a non-null
`prior_state` on an `add` **unconstructible**
(`_parallel_mutation_models.py:417-424`), so the rule is enforced at the type boundary rather
than only at validation time.

**Coherent, not validator-appeasing.** The rationale is semantically sound on its own terms:
`add` denotes item *introduction*, so an added item has no prior state within the mutation log.
Two independent sources agree (the F3 constant and rule invariant 16).

**No lifecycle information lost.** The `prepared -> scheduled` transition is recorded as an
`items[]` state update with F3 lifecycle timestamps — the *same* mechanism the spec already
prescribed for `proposed -> admitted -> prepared`. The correction therefore makes the
recording uniform across all four add-path transitions rather than special-casing the last
one. Documented consistently in four places: `spec.md:244-249`,
`_parallel_mutation_entries.py:97-101`, `parallel-add/SKILL.md:95-97`, and
`parallel-orchestrate/SKILL.md:516`.

**Verdict: PASS.**

## Findings

### Blocking

**B1 — Admission into the current cohort does not check independence against not-yet-launched members of that cohort.**

- **Location:** `scripts/dev_tools/parallel_mutation_protocol.py:114-161` (`decide_admission`);
  `.claude/skills/parallel-add/SKILL.md:70-79` (procedure step 4);
  `docs/features/.../spec.md:45-48` (FR1 step 4).
- **Rule / expected behavior violated:** the epic's central safety property — items scheduled
  to run concurrently must be pairwise blast-radius disjoint
  (`docs/features/epics/parallel-orchestration/epic.md` § Shared Design; design §6).
- **Detail.** `decide_admission` returns `ADMIT_CURRENT_COHORT` whenever the candidate shares
  no conflict edge with any **`in_flight`** item, and that branch performs **no recolor**
  (`parallel-add/SKILL.md:70-72`: "Admit it into the current cohort. NO recompute occurs").
  A cohort produced by F2's coloring is an independent set, but a cohort **larger than
  `max_concurrency`** durably contains `scheduled` (not-yet-launched) members alongside
  `in_flight` ones — F5's landed SKILL states this explicitly at
  `.claude/skills/parallel-orchestrate/SKILL.md:120-124`: "`max_concurrency` caps the number
  of simultaneously in-flight items independently of cohort size: a cohort of twelve items
  executes at most `max_concurrency` [at once] ... A cohort larger than `max_concurrency`
  therefore launches in several batches."

  Reachable sequence: item 100 `in_flight`; item 200 `scheduled` in current cohort 0, not yet
  launched; candidate 300 conflicts with 200 but not with 100.
  `decide_admission(300, [(200, 300)], frozenset({100}))` returns `ADMIT_CURRENT_COHORT` with
  `triggers_recompute is False`, so 300 is written into cohort 0 at unchanged generation. When
  the next `max_concurrency` batch launches, 200 and 300 run concurrently on overlapping
  blast radius.

  The engine's own docstring asserts the mitigation does not apply on this branch:
  `parallel_mutation_protocol.py:127-130` says an unstarted conflict "is resolved by
  `recolor_unstarted`" — but `recolor_unstarted` is only called on the `DEFER_AND_RECOLOR`
  branch (`parallel-add/SKILL.md:82`, "Apply the recolor result, **if any**").
- **Nothing detects it.** F3 invariants 12-13 constrain cohort shape and coverage but not
  independence; F6's validator adds no cohort-independence check; F7's
  `PARALLEL_COHORT_BARRIER_VIOLATION` concerns cohort *ordering*. No test covers the case.
  `test_unstarted_conflict_is_placed_by_the_coloring_not_rejected`
  (`test_parallel_mutation_protocol.py:344-351`) asserts only that `recolor_unstarted` separates
  a contending pair — it never exercises the admit-without-recolor path that creates the hazard.
- **Root cause is the requirement, not the code.** Design
  `docs/research/2026-08-07-parallel-orchestration-design-research.md:173` states "No conflict
  with any in-flight item, admit into the current cohort", carried verbatim into `spec.md` FR1
  step 4 and into AC S2 and U1. **F6 implemented its approved spec faithfully.** This is not an
  epic non-goal (`epic.md:86-101` lists five non-goals; none covers it).
- **Verification command:** reasoning over `decide_admission`'s signature (it receives only
  `in_flight`, never the current cohort's membership) plus
  `.claude/skills/parallel-orchestrate/SKILL.md:120-124`. No executable command can demonstrate
  it because no test or validator exercises the path — that absence is part of the finding.
- **Remediation requires a spec amendment**, not a code-only fix: the corrected rule ("admit
  into the current cohort only when the candidate conflicts with no member of the current
  cohort, `in_flight` or unstarted; otherwise defer and recolor") changes `decide_admission`'s
  signature and contradicts the current text of AC S2 and U1. Acceptable alternative: the
  maintainer accepts it as a known limitation, in which case it must be recorded explicitly in
  `spec.md` § Constraints & Risks and tracked as a follow-up issue rather than left implicit.
  It must not ship undocumented.

### Partial

**P1 — F6 copies F3's op-classification tuples without a binding assertion.**

- **Location:** `scripts/dev_tools/_parallel_mutation_models.py:109-113`;
  `scripts/dev_tools/_parallel_orchestrator_state_mutations.py:92-99`.
- **Rule:** `.claude/rules/parallel-orchestration.md` § Enum Ownership (consume, never
  restate what can drift); `.claude/rules/general-code-change.md` § Reusability (avoid
  copy-paste).
- **Detail.** F3 exports importable module-level constants at
  `scripts/dev_tools/_parallel_state_records.py:49-56`:

  ```python
  OPS_REQUIRING_ITEM_KEY        = tuple("add remove requeue".split())
  OPS_REQUIRING_NULL_PRIOR_STATE = tuple("add close".split())
  OPS_REQUIRING_NULL_NEW_STATE   = ("close",)
  ```

  F6 re-declares all three as local copies (`ITEM_SCOPED_OPS`,
  `OPS_WITH_NULL_PRIOR_STATE`, `OPS_WITH_NULL_NEW_STATE`) in **two** modules, with no import
  and **no test binding them to F3's values**. Verified:
  `grep -rn "OPS_REQUIRING_NULL\|OPS_WITH_NULL\|ITEM_SCOPED_OPS" tests/.../test_parallel_mutation_protocol*.py tests/.../test_validate_parallel_orchestrator_state_mutations.py`
  returns no binding assertion (only `MUTATION_ENTRY_FIELDS` and the item-state subset checks
  appear). Contrast `test_parallel_mutation_protocol.py:86-101`, which *does* bind
  `UNSTARTED_ITEM_STATES` and `PINNED_ITEM_STATE` to F3's enum.
- **Why it matters here specifically.** This is the exact divergence class the directive flags:
  each side can hold 100% coverage while silently disagreeing. If F3 amended
  `OPS_REQUIRING_NULL_PRIOR_STATE`, F6's two copies would diverge and
  `_validate_entry_completeness` would emit a "must not be null" error for a field F3 now
  requires null — a contradictory error pair with no failing test anywhere.
- **Verification:** `poetry run pytest tests/scripts/dev_tools -q` → 3298 passed; the suite
  passes today because the copies happen to match. That is precisely the vacuous-pass shape.
- **Remediation:** import F3's three constants, or add three one-line equality assertions
  binding each local copy to its F3 counterpart. Either is a few lines.

**P2 — FR9 invariant 3 is delivered in an attenuated form relative to the spec text.**

- **Location:** `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py:247-289`.
- **Rule:** `spec.md` FR9 invariant 3 / AC S9 — "the mode-dependent completion invariant per
  FR7", where FR7 states "a `closed`-mode checkpoint recording completion must satisfy the
  predicate".
- **My independent assessment, as requested.** The delivered formalization is **defensible,
  and I would not block on it**, but it is materially narrower than the spec sentence and the
  spec should be amended to say what was built.

  *What is genuinely sound.* F3's schema has no completion field and none may be added, so the
  helper must infer completion from available signals. The two it uses — a `mutations[]`
  `op == 'close'` record and an empty current-generation cohort set — are the only two the
  schema carries. The conjunction is load-bearing, not defensive padding: I verified that
  requiring the close record **alone** in closed mode would break the landed F3 test at
  `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_completion.py:110`
  (`assert validate(state_with_mutation(dict(CLOSE_MUTATION))) == []`), because
  `build_valid_parallel_state` is `mode: "closed"` with a non-empty current-generation cohort
  and two `scheduled` items. So the executor's stated constraint is real, not an excuse.

  The open-mode rule ("nothing may follow the close record") is a genuine, non-vacuous, and
  *additive* invariant: F3 invariant 21 already requires a close record for a complete
  open-mode run, so F6 correctly did not restate it and instead enforced that the close is
  terminal. The deliberate decision not to fire on an idle `open` run whose items have all
  merged is **correct**, not a weakening — firing there would block the next
  `/parallel-add`, which is exactly what `open` mode exists to permit. It is explicitly
  test-pinned at `test_validate_parallel_orchestrator_state_mutation_modes.py:51-56`.

  *Where it is genuinely weaker.* The closed-mode rule fires only on a checkpoint that
  contains a `close` record. But per spec FR3 and `parallel-close/SKILL.md:25-27`, a
  `closed`-mode run **never records a close** — it completes by predicate. So on a
  spec-conformant `closed`-mode run this rule is unreachable. Its real (narrow) value is
  catching an operator who improperly closed a `closed`-mode run whose work is finished but
  whose items are `blocked` or non-terminal. The invariant that actually guards closed-mode
  completion is F3's own invariant 20 under `require_complete`, which F6 correctly does not
  duplicate.
- **Net:** all three invariants exist, are wired by exactly one import and one call line, are
  key-gated, and are at 100% branch coverage. Invariant 3's closed-mode arm is close to
  inert on conformant data. **AC S9 is PARTIAL rather than PASS** on fidelity of scope, not on
  delivery.
- **Remediation:** amend `spec.md` FR9 invariant 3 and AC S9 to describe the two-signal
  formalization actually implemented (the module docstring at lines 16-43 already documents it
  well), so the spec and the code agree. No code change required.

**P3 — Python/TypeScript parity gap for the three new FR9 invariants.**

- **Location:** `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`
  (unmodified; dispatch at lines 198-200, F7 seam at 307-314).
- **Rule:** `.claude/rules/parallel-orchestration.md` § Enforcement — "The TypeScript parity
  port ... reproduces the same invariants ... Verified scope: 96 of 96 error strings matched
  across 43 constructed documents."
- **My view, as requested.** There is now a **real** divergence: the Python validator emits
  three families of errors (missing seven-field member, non-null-completeness violation,
  generation non-monotonicity, mode-dependent completion) that the TypeScript core does not.
  A checkpoint whose `add` entry omits `new_state` yields a Python error and zero TypeScript
  errors. No automated parity test exists — `grep -rln "parity"
  extensions/drm-copilot/src --include=*.test.ts` returns nothing — so nothing detects it.

  **Correctly deferred, not Blocking for this PR.** Three reasons: (1) no AC and no plan task
  required an F6 TypeScript port — `spec.md` S9 names only the Python helper and the single
  Python call site; (2) F6 had **no designated TypeScript seam** — the only comment-delimited
  seam in that file is explicitly F7's, and F3's prose plus the plan's Check C forbid F6 from
  writing inside it, so a port would have required either contending for F7's seam or creating
  an unsanctioned one during a concurrent wave; (3) the rule file's parity claim is scoped to
  the F3 invariants it enumerates (1-21), and F6 cannot amend that rule file.
- **What is nonetheless missing:** the gap is undocumented. Adding it to scope at review time
  would need a spec amendment, so the correct minimal action is a recorded follow-up.
- **Remediation:** open a follow-up issue (or a `docs/features/potential/` entry) recording
  that `parallel-orchestrator-state-core.ts` lacks the F6 mutation-protocol invariants, and
  note in it that the rule file's parity statement is now scoped to invariants 1-21.

**P4 — Unauthorized `# noqa: S311` suppression.**

- **Location:** `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py:125` and
  `:308`.
- **Rule:** `.claude/rules/python-suppressions.md` § Authorization Requirement — every
  `# noqa` must match a pre-authorized pattern **or** have explicit user approval.
- **Detail.** S311 is **not** among the pre-authorized codes (S603, ARG002, B008, TCH002/003,
  S310, S314, BLE001, S301, S108/S105). There is no repo precedent —
  `grep -rn "noqa: S311" --include=*.py .` returns nothing outside this file — and no
  per-file-ignore covers it (`pyproject.toml:106-108` lists only
  `"tests/**/*" = ["S101"]`). No approval record appears in the feature evidence.
- **Mitigating.** The underlying choice is mandated elsewhere: `spec.md` Constraints & Risks
  item 2 and `.claude/rules/general-unit-test.md` § Determinism Infrastructure both require a
  seeded RNG. The *substance* is authorized; only the suppression mechanism is not.
- **Verification:** `poetry run ruff check` passes because the `noqa` suppresses the finding.
- **Remediation:** either add `S311` to the `tests/**/*` per-file-ignores, or amend
  `python-suppressions.md` to pre-authorize S311 for seeded test-data generation, or record
  explicit approval. All three are policy/config actions, not code fixes.

**P5 — `# noqa: S603` rationale is not on the suppressing line.**

- **Location:** `scripts/dev_tools/parallel_mutation_abandon_cli.py:152-153`.
- **Rule:** `.claude/rules/python-suppressions.md` § S603 — required comment format is
  `# noqa: S603 - static analysis can't verify runtime validation`, and the enforcement
  checklist requires "Required comment format is used verbatim."
- **Detail.** Line 152 is a standalone comment carrying the full required text, but Ruff only
  honours a `noqa` on the line of the violation, so line 152 is inert. The **effective**
  suppression on line 153 is a bare `# noqa: S603` with no rationale. The inert line 152 also
  reads as a suppression while suppressing nothing, which is mildly misleading.
- **Substance is fully satisfied:** it is a pre-authorized pattern, the executable is validated
  by `shutil.which` at line 148, and the scope is one line.
- **Remediation:** move the rationale onto line 153 and delete line 152 — a one-line change.

### Advisory

- **A1 — Branch carries zero commits.** `HEAD == c939b5b8`; all 37 changes are uncommitted or
  untracked. No PR can be created from this state, and the work is not yet durable. Not a
  policy violation, but it must be committed before PR authoring.
- **A2 — Abandon-gate literal match is evadable by `--disposition=abandon`.** The hook matches
  the whitespace-normalized literal `'--disposition abandon'`
  (`enforce-parallel-abandon-gate.ps1:38,105-107`). argparse also accepts
  `--disposition=abandon`, which the gate would not match. **Mitigated**, and this is worth
  stating positively: the CLI independently refuses without the marker
  (`parallel_mutation_abandon_cli.py:342-349`, `return EXIT_REFUSED` before any side effect),
  so no destructive effect can occur through an evaded gate. Defence in depth holds; the gate
  is a deterrent, the CLI is the enforcement. Consider also matching the `=` form.
- **A3 — One seam assertion is tautological.**
  `test_parallel_abandon_token_seam.py:258-264` compares `cli_token_pair()[0]` against
  `disposition_action_composition()`, and both derive from the same two constants. The genuine
  content of that helper is its two `assert` statements (lines 141-144) proving the parser
  registers `DISPOSITION_OPTION` and that `abandon` is in its `choices`. The comparison itself
  proves nothing extra.
- **A4 — P3's mutation sequence omits in-flight removals.**
  `test_parallel_mutation_protocol_properties.py:319-343` draws removal targets only from
  `unstarted`, so no `detach`/`abandon` op appears in the "arbitrary sequence of add/remove
  ops". The complementary property — that removing one in-flight item leaves *other* in-flight
  items untouched — is not covered.
- **A5 — No dedicated integration-scenario suite.** `spec.md` § Test Strategy lists
  fixture-driven integration scenarios. These are substantively covered by equivalent unit
  scenarios (`TestAdmissionOverAllItems`, `TestRemovalBehaviorTable`, `TestCloseGating`, and
  the FR9 open-mode tests), and the engine is pure with no external boundary, so the
  unit/integration distinction is thin. A single multi-op walk over one checkpoint-shaped
  fixture is absent except inside the P3 property test. `spec.md` § Seeded Test Conditions
  bullet 4 is honestly left unchecked.
- **A6 — `spec.md` Definition of Done and Seeded Test Conditions are entirely unchecked**
  (lines 553-566) while all 15 AC are checked. Neither section is an AC source under the
  `acceptance-criteria-tracking` heading rules, so this is not a check-off violation, but the
  inconsistency should be resolved before PR.
- **A7 — Three test files at 498-500 lines** leave no headroom under the 500-line cap.
- **A8 — Pre-existing PowerShell coverage model.** `CodeCoverage.Path` is an inclusion
  allowlist, so most production PowerShell outside it is unmeasured. Pre-existing repo
  condition, not introduced here; recorded for context only.
- **A9 — `evidence/qa-gates/wave4-confinement-verification.md` diff stats are stale**
  (records `plan.md` 276 / `spec.md` 55; current values are 284 / 61) because feature docs were
  edited after that artifact was written. Conclusions are unaffected.

## Summary

| Classification | Count |
|---|---|
| **Blocking** | **1** |
| Partial | 5 |
| Advisory | 9 |

**Overall policy verdict: PARTIAL.**

Every automated gate this repository defines is green and was independently re-run: Black,
Ruff, Pyright (0 errors), 3386 pytest passing, PoshQC format, PSScriptAnalyzer (0 findings),
2043 Pester passing with one pre-existing out-of-scope failure, Python coverage 92.05% line /
84.19% branch with all seven new modules at 100%/100%, and the new hook at 86.96%. Wave-4
confinement, bundle byte-identity, evidence locations, file-size cap, test-location, temp-file,
wall-clock, and seeded-RNG obligations all verified PASS by direct inspection rather than
accepted from the report. The reported state was accurate in every figure I checked.

The single Blocking finding (B1) is a requirement-level correctness hole inherited from design
§8.3 and encoded verbatim in AC S2 and U1, so it cannot be closed by code alone.

**CI context.** `.github/workflows/ci.yml` declares `pull_request: branches: [main, development]`,
so a PR based on `epic/parallel-orchestration-integration` schedules no `ci.yml` run. Local
gates are the only automated signal. That raises the weight of B1 and P1 in particular: both
are conditions no gate in this repository would catch.
