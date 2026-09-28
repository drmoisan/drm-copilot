# Policy Audit — Issue #559 (epic-orchestrator always-on context footprint)

- Timestamp: 2026-08-26T02-30
- Reviewer: `feature-review`
- Review type: **REAUDIT — remediation cycle 1 exit gate**
- Branch: `bug/epic-orchestrator-always-on-context-footprint-559`
- HEAD: `684592a8`
- Merge base with `main`: `b36179b2`
- Work mode: `full-bug` — `spec.md` is the sole acceptance-criteria source
- Prior review: `policy-audit.2026-08-26T01-11.md` (1 Blocking, 10 non-blocking)

## Blocking Count

**Total Blocking findings: 0**

The single Blocking finding of cycle 0 (B1) is **resolved**. No new Blocking finding was identified.

## Scope Resolution

The audit scope is the full branch diff against the resolved merge base. It is not the scope of the
remediation plan, of any phase, or of any caller-supplied subset.

The PR context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`
were **stale** at review start (they recorded head `aeac89a7`, one commit behind the current HEAD
`684592a8`) and were regenerated before proceeding:

```
poetry run python -m scripts.dev_tools.pr_context.collector --base b36179b2 --head 684592a8 --repo-root .
EXIT_CODE: 0
```

Branch diff, measured:

```
git diff --stat b36179b2..684592a8
86 files changed, 10162 insertions(+), 49 deletions(-)
```

```
git diff --name-only b36179b2..684592a8 | sed 's/.*\.//' | sort | uniq -c
     83 md
      3 py
```

## Rejected Scope Narrowing

None. The caller prompt directed a full-branch audit against the resolved merge base and attempted
no narrowing to a plan, task, phase, or file subset.

Three caller statements were examined and found not to be narrowing instructions:

1. "Python and Markdown/YAML only; no PowerShell, TypeScript, or C# changes." — This is a factual
   description of the branch diff, not an instruction to skip a toolchain or coverage check. It was
   verified independently rather than accepted: the 86 changed paths are 83 `.md` files and 3 `.py`
   files, all three Python files under `tests/`. Zero `.ps1`, `.psm1`, `.ts`, `.tsx`, or `.cs` files
   are changed. The language coverage verdicts below are issued on that measured evidence.
2. "Do not raise the unchecked criterion [`spec.md` line 644] or the untouched `AGENTS.md` as
   findings." — This is not a scope narrowing. `spec.md:644` is prefixed
   `**BLOCKED — DO NOT CHECK.**` in the requirement document itself and mandates that the criterion
   remain unchecked at delivery; `AGENTS.md` is asserted unmodified by `spec.md:637-638`, and that
   assertion was verified independently (`git diff --stat b36179b2..684592a8 -- AGENTS.md` produced
   no output). The caller instruction agrees with the requirement document; it does not override it.
3. "`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` is owned by concurrently
   active feature 441." — Ownership does not remove the file from this branch's diff. The file was
   audited in full as part of this branch's changes; see Scope Containment below.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
5. `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`,
   `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/orchestrator-state.md`
6. `.claude/skills/policy-compliance-order/SKILL.md`,
   `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`,
   `.claude/skills/acceptance-criteria-tracking/SKILL.md`

## Verdict Summary

| Policy area | Cycle 0 verdict | Cycle 1 verdict |
|---|---|---|
| Evidence location compliance | PASS | **PASS** |
| Suppression policy (`python-suppressions.md`) | PASS | **PASS** |
| Toolchain — format (`black --check`) | PASS | **PASS** |
| Toolchain — lint (`ruff check --no-fix`) | PASS | **PASS** |
| Toolchain — type check (`pyright`) | PASS | **PASS** |
| Toolchain — unit tests (`pytest`) | PARTIAL | **PARTIAL** (one tolerated pre-existing failure) |
| Coverage — Python | PASS | **PASS** |
| Coverage — PowerShell | N/A (zero changed files) | **N/A (zero changed files)** |
| Coverage — TypeScript | N/A (zero changed files) | **N/A (zero changed files)** |
| Coverage — C# | N/A (zero changed files) | **N/A (zero changed files)** |
| File size limit (500 lines) | PASS | **PASS** |
| Test policy (`general-unit-test.md`) | **FAIL** | **PASS** (B1 resolved) |
| Plan acceptance gates (G1–G6) | PASS | **PASS** |
| Orchestrator-state contract | PASS | **PASS** |
| Tonality | PASS | **PASS** |
| Scope containment (declared non-writes) | PASS | **PASS** |

`N/A` is recorded for PowerShell, TypeScript, and C# only because each has **zero changed files**
in the branch diff, which is the sole condition under which `N/A` is an acceptable coverage verdict.

## B1 Remediation Verification — RESOLVED

### The change

`tests/scripts/dev_tools/test_claude_rules_frontmatter.py:35-37`, single hunk in commit `684592a8`:

```python
# `.claude/agent-memory/`, `.claude/worktrees/`, and `.claude/state/` are gitignored,
# machine-local subtrees excluded here for determinism.
EXCLUDED_CLAUDE_SUBDIRS = frozenset({"agent-memory", "worktrees", "state"})
```

`claude_markdown_files()` (lines 307-327) filters on
`candidate.relative_to(CLAUDE_ROOT).parts[0]`, so the three names are matched as immediate children
of `.claude/`, which is exactly where the three gitignored subtrees live.

### Verification 1 — the exclusion set is complete against `.gitignore`

Every `.gitignore` entry scoped under `.claude/` is now excluded, and there are exactly three:

```
grep -n "claude" .gitignore
21:.claude/worktrees
67:.claude/agent-memory
68:.claude/state/
```

`ls -1 .claude` on the primary checkout returns `agent-memory/ agents/ hooks/ lib/ rules/
settings.json settings.local.json skills/ worktrees/`; on this worktree it returns the same set
with `state/` in place of `worktrees/`. Both machine-varying subtrees are covered.

```
git status --porcelain --ignored -- .claude | grep -v "worktrees|agent-memory|state"
(no output)
```

No other untracked or ignored content exists under `.claude/`, so the scan set is exactly the
committed `.claude/` Markdown on this machine.

### Verification 2 — no excluded-subtree path can enter the scan, proven against a root that has them

The decisive test is to run the fixed function against a `.claude/` root that actually contains
nested worktrees. This worktree's own `.claude/` has none, so a probe run from here is vacuous on
the `worktrees` dimension. The scan was therefore repointed (read-only) at the primary checkout
`C:/Users/DanMoisan/repos/drm-copilot`, whose `.claude/worktrees/` holds sixteen nested repository
copies:

```
TOTAL_FROM_PRIMARY_CHECKOUT= 108
BAD_ANY_EXCLUDED_SEGMENT= 0
OFFENDERS= 2 ['.claude\agents\epic-orchestrator.md', '.claude\skills\epic-orchestrate\SKILL.md']
```

Reading of that result:

- `BAD_ANY_EXCLUDED_SEGMENT= 0` — zero returned paths carry `worktrees`, `state`, or `agent-memory`
  at **any** `CLAUDE_ROOT`-relative segment, from a root with sixteen live nested worktrees. The
  determinism defect is closed against the exact condition that produced it.
- `TOTAL= 108` is non-zero, so the function still returns real files; the fix did not empty the set.
- `OFFENDERS= 2` names the primary checkout's `epic-orchestrator.md` and `epic-orchestrate/SKILL.md`.
  The primary checkout is on `main`, which still carries the unqualified `spec.md §` citations this
  branch removes. This is a positive control: the assertion still fires on pre-fix content, so it
  was **not weakened**.

### Verification 3 — no assertion weakened, no test added, removed, or renamed

- The commit's only source hunk is the three-line comment-and-frozenset replacement shown above.
  No assertion, no test function, and no helper was touched.
- Test count: the module defines exactly eight `test_` functions
  (`test_every_claude_rule_carries_parseable_paths_and_description`,
  `test_unconditional_rule_set_is_exactly_the_four_deliberate_files`,
  `test_orchestrator_state_rule_paths_reach_every_checkpoint_writer`,
  `test_plan_acceptance_gates_rule_paths_cover_both_dispatchers`,
  `test_parallel_orchestration_rule_paths_cover_blast_radius_config`,
  `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file`,
  `test_epic_orchestrator_preloads_exactly_three_skills`,
  `test_no_unqualified_spec_section_citation_under_claude`) — unchanged from cycle 0.
- The exclusion removes no committed file from the scan:
  `git ls-files -- .claude/agent-memory .claude/state .claude/worktrees` returns **zero** tracked
  paths, so nothing the criterion is about was excluded.

### Verification 4 — file size and toolchain

```
wc -l tests/scripts/dev_tools/test_claude_rules_frontmatter.py
499
```

At 499 lines, within the 500-line ceiling of `.claude/rules/general-code-change.md`. The fix was
line-neutral (three lines replaced by three lines).

```
poetry run black --check <3 changed py files>        EXIT=0  (3 files would be left unchanged)
poetry run ruff check --no-fix tests/scripts/dev_tools/   EXIT=0  (All checks passed!)
poetry run pyright <3 changed py files>              0 errors, 0 warnings, 0 informations
poetry run pytest <4 contract modules> -q            55 passed in 0.20s
```

**Verdict: B1 is resolved.** The `general-unit-test.md` determinism principle and the
external-configuration clause are both satisfied: the scan's input no longer varies with machine
state.

## Adjudication — the rejected `git ls-files` remedy

Cycle 0 named `git ls-files -- .claude` as the *preferred* remedy. Preflight rejected it on three
grounds. **This review accepts the rejection.** The adopted exclusion-set fix is the correct remedy
for this repository.

**Ground 1 — dispositive, and it holds.** `.claude/rules/general-unit-test.md:71` reads:

> Unit tests must not depend on external services (databases, networks, remote APIs, **external
> processes**).

`git ls-files` is an external process. The prohibition names the category explicitly and is not
qualified by whether the process is local, fast, or read-only. It is also not merely formal here:
a subprocess remedy would substitute one environmental dependency (filesystem contents) for another
(a `git` executable on `PATH`, plus index state), so it would not straightforwardly dominate the
adopted fix on the determinism axis that B1 was raised on. Cycle 0's recommendation was made
without weighing that rule text; that was an error in the cycle 0 review, and the preflight
correction stands.

**Ground 2 — consistent with observation.** No test module in this repository was observed making
an unmocked `git` subprocess call. Seventeen test modules reference `subprocess`; the ones named by
the executor (`tests/scripts/dev_tools/test_git.py`,
`tests/scripts/dev_tools/test_plan_gate_discrimination_context.py`) use it as a monkeypatch target.
Recorded as consistent rather than exhaustively proven; a full audit of all seventeen modules was
not performed and is not needed, because Ground 1 alone settles the question.

**Ground 3 — overstated as written, and it does not carry the decision.** The commit message for
`684592a8` states that "`tests/conftest.py` ships an autouse guard against unmocked subprocess
calls." The guard at `tests/conftest.py:64-139` is narrower than that. It returns immediately
unless the test's node ID contains `tests/scripts/dev_tools/test_new_active_feature_folder`, and
within that scope it raises only for the executable tokens `code`, `code.cmd`, and `code.exe`. It
would **not** have blocked a `git ls-files` call issued from
`test_claude_rules_frontmatter.py`. This is recorded as non-blocking finding C1-N2 below; it is an
inaccuracy in the stated rationale, not in the decision.

**Ground 4 (line ceiling) — accepted.** The module sits at 499 of 500 lines. A subprocess-based
enumeration with the error handling it would require does not fit without splitting the module.

## Adjudication — the residual in the adopted fix

The adopted fix enumerates three directory names, so a future gitignored subtree added under
`.claude/` would reintroduce the defect. The remediation plan records this residual explicitly
(`remediation-plan.2026-08-26T01-11.md:24`), and the commit message states it in the same terms.

**Recording it is necessary but not quite sufficient**, because a remediation plan is a
point-in-time artifact that no future change is obliged to read, whereas the failure mode is silent:
the test would begin passing or failing according to machine state again, with no signal. This is
recorded as non-blocking finding **C1-N1** with a concrete, policy-compliant remedy — a guard test
asserting that `EXCLUDED_CLAUDE_SUBDIRS` equals the set of `.claude/`-scoped entries parsed from
`.gitignore`. That check is a pure text read of two committed files: it needs no subprocess, so it
does not reopen the Ground 1 problem, and it converts the residual from a silent regression into a
loud one.

It is **not Blocking** because the exclusion set is complete against the current `.gitignore`
(verified above, three entries, three exclusions), so the defect is closed today, and because the
residual is a hypothetical future condition rather than a present defect.

## Adjudication — the unchecked `[P1-T3]` probe

`remediation-plan.2026-08-26T01-11.md:155-161` states the probe:

```
bad = [f for f in files if 'worktrees' in f.parts or 'state' in f.parts or 'agent-memory' in f.parts]
```

with acceptance `BAD_COUNT=0`. It reported `BAD_COUNT=108 / TOTAL=108`.

**The probe is defective; the fix is not.** Two independent defects in the probe:

1. **Wrong operand.** It tests `f.parts` — the parts of the **absolute** path — while the
   implementation filters on `candidate.relative_to(CLAUDE_ROOT).parts`. Execution happens inside
   `...\.claude\worktrees\agent-a48e43815591206c3\...`, so `worktrees` is an ancestor segment of
   every returned path and the probe cannot report anything but `BAD_COUNT == TOTAL`. The probe was
   never capable of passing in this environment, whatever the implementation did.
2. **Vacuous on its own target even if corrected.** Run from inside this worktree, `CLAUDE_ROOT`
   is the worktree's `.claude/`, which contains **no** `worktrees/` subtree at all. A corrected
   relative-parts probe run here would exercise only the `state` exclusion and would report
   `BAD_COUNT=0` even against the pre-fix code for the `worktrees` dimension. The probe as designed
   could not have verified the specific defect B1 named.

**Classification: Non-blocking (C1-N3).** Reasons:

- It is a defect in a verification instrument, not in delivered behaviour.
- The behaviour it was meant to verify is verified three other ways, one of which is strictly
  stronger than the probe could have been: the module's own eight tests pass; the executor's
  `CLAUDE_ROOT`-relative recomputation reports `BAD_COUNT_RELATIVE=0 / TOTAL=108`; and this review's
  independent probe against the **primary checkout with sixteen live nested worktrees** reports
  `BAD_ANY_EXCLUDED_SEGMENT=0 / TOTAL=108` together with a positive control showing the assertion
  still fires (Verification 2 above).
- The executor's handling was correct on every axis: it left the box `[ ]` rather than checking it
  on a technicality, disclosed the reason and the substitute verification in the commit message, and
  — per the remediation scope-change rule — carried the new finding to the next cycle instead of
  patching the active plan.

**B1 is resolved despite `[P1-T3]` being unchecked.** An unchecked verification task whose stated
assertion is provably unsatisfiable in the execution environment does not withhold a verdict when
the underlying behaviour is independently confirmed. Requiring the checkbox would require checking
off a false statement.

The corrected form, for any future re-run, must do both of the following: compare
`CLAUDE_ROOT`-relative parts, and run against a root that actually contains a `worktrees/` subtree.

## Evidence Location Compliance — PASS

```
python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT_CODE: 0
```

Every evidence artifact in the branch diff sits under
`docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/<kind>/`,
with `<kind>` in `{baseline, remediation-baseline, qa-gates, regression-testing, other}`. Zero files
were written to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or
`artifacts/evidence/`. Confirmed by inspection of all 83 changed Markdown paths in the diffstat.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose: no caller instruction specified a
non-canonical evidence path.

## Suppression Policy — PASS

```
grep -n "noqa|pragma: no cover|type: ignore|pyright: ignore|# nosec" <3 changed py files>
EXIT_CODE: 1  (no matches)
```

Zero suppressions of any kind in the three changed Python files. The unauthorized `E501` noqa that
existed earlier in this run was removed in commit `1e2d5301` and has not returned.
`pyproject.toml` is not in the branch diff, so no `per-file-ignores` entry was added.

## Toolchain Loop

Applicable stages for a change containing only Markdown and Python test files:

| Stage | Command | Result |
|---|---|---|
| 1. Formatting | `poetry run black --check` (3 changed files) | **PASS** — 3 files unchanged |
| 2. Linting | `poetry run ruff check --no-fix tests/scripts/dev_tools/` | **PASS** — All checks passed |
| 3. Type checking | `poetry run pyright` (3 changed files) | **PASS** — 0 errors, 0 warnings |
| 4. Architecture boundary | not configured for Python in this repository | not applicable |
| 5. Unit tests | `poetry run pytest tests -q` | **PARTIAL** — 1 failed, 4150 passed, 5 skipped |
| 6. Contract / schema | `validate_orchestration_artifacts.py orchestrator-state` | **PASS** — EXIT 0 |
| 7. Integration tests | no integration suite touched by this change | not applicable |

### Stage 5 detail — the single failure, re-verified

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
E   AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
1 failed, 4150 passed, 5 skipped in 4.99s
```

This is the single tolerated pre-existing failure, unchanged in identity and count from cycle 0.
Its cause is the same defect class as B1 — `list_scoped_files` enumerates the filesystem rather than
consulting git, so the gitignored, untracked, machine-local `.claude/state/` file enters the
repo-side set — but in a module (`test_push_down_claude_resource_contracts.py`) that is outside this
change's declared blast radius. Cycle 0 adjudicated the deferral as sound and instructed the
remediation not to fix it; that instruction was followed.

**No second failure appeared.** The counts (1 / 4150 / 5) match the recorded evidence exactly. No
regression.

### Stage 6 detail

```
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state artifacts/orchestration/orchestrator-state.json
orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json
EXIT_CODE: 0
```

## Coverage Verification

### Python — PASS

- Coverage artifact: `artifacts/python/lcov.info` — **present**, 181 `SF:` records.
  Not regenerated by this review (byte size and mtime unchanged across the full pytest run:
  251029 bytes, `Aug 26 01:59`, before and after).
- Repo-wide line coverage: **92.65%** (13910 / 15014 statements), recorded in
  `evidence/qa-gates/remediation-coverage-delta.2026-08-26T01-11.md` and
  `evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`.
- Threshold: >= 85% (uniform, `.claude/rules/quality-tiers.md`). **92.65% >= 85% — PASS.**
- Delta: **+0.00 pp**, baseline to post-change. Structurally zero: the branch changes **zero
  production Python files**. All three changed `.py` files are under `tests/`, which
  `[tool.coverage.run] omit` excludes from measurement.
- New production Python files: **none**. The new-file tier (>= 85% line) has an empty subject set.
- Modified production Python files: **none**. The modified-file tier and the no-regression-on-changed-
  lines requirement have empty subject sets.

**Python coverage verdict: PASS.**

### Python branch coverage — unevaluated, Non-blocking, pre-existing

`artifacts/python/lcov.info` carries **zero** `BRF:` records, because `pyproject.toml:113-115`
configures `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"` with no `--cov-branch`.
The uniform 75% branch floor is therefore not measurable for Python from the committed artifact.

This is recorded as a verdict qualifier, not a FAIL, on the following grounds, all measured rather
than asserted: the gap is a repository-wide instrumentation configuration that predates this branch
(`pyproject.toml` is not in the branch diff); it is outside the declared blast radius; and the
change adds and modifies **zero** production Python, so it cannot regress a branch-coverage figure
in either direction. Carried forward as non-blocking finding C1-N7 (was N7 in cycle 0). It is a
separate change against `pyproject.toml`.

### PowerShell — N/A (zero changed files)

`git diff --name-only b36179b2..684592a8` yields zero `.ps1` and zero `.psm1` paths. `N/A` is used
only under the zero-changed-files condition. `artifacts/pester/powershell-coverage.xml` was not
required and was not consulted.

### TypeScript — N/A (zero changed files)

Zero `.ts` and zero `.tsx` paths in the diff. The eight files under
`extensions/drm-copilot/resources/claude-customizations/.claude/` that the branch changes are
Markdown mirrors, not TypeScript. `coverage/lcov.info` is absent, which is consistent and required
of nothing here.

### C# — N/A (zero changed files)

Zero `.cs` paths in the diff. `artifacts/csharp/coverage.xml` was not required.

## File Size Limit — PASS

| File | Lines | Limit | Verdict |
|---|---|---|---|
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | 499 | 500 | PASS (1 line of headroom) |
| `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py` | 437 | 500 | PASS |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 339 | 500 | PASS |

Markdown documentation files are exempt from the ceiling per `.claude/rules/general-code-change.md`.

The 499-line module has one line of headroom. Carried forward as non-blocking finding C1-N8 (was N8
in cycle 0), now with added weight: the C1-N1 guard test cannot be added to this module without a
split.

## Test Policy (`general-unit-test.md`) — PASS

Cycle 0 verdict was FAIL on the determinism principle. Re-evaluated against the fixed module:

| Principle | Verdict | Evidence |
|---|---|---|
| Independence (any order) | PASS | No module-level mutable state; every test recomputes from disk. |
| Isolation (one unit each) | PASS | Each of the eight tests asserts one structural contract. |
| Fast execution | PASS | 55 tests across four contract modules in 0.20 s. |
| **Determinism** | **PASS** | Scan input no longer varies with machine state — Verifications 1-3 above. |
| Readability | PASS | Descriptive names; each test carries a docstring stating the scenario. |
| No external services or processes | PASS | Reads committed repository text only; no subprocess, no network. |
| No temporary files | PASS | No `tmp_path`, no `tempfile`, no write of any kind in either new module. |
| No mutable global state | PASS | Module constants are `frozenset`/`tuple`; nothing is rebound at runtime. |
| Test file location mirrors source | PASS | `tests/scripts/dev_tools/` for `scripts/dev_tools/`-adjacent contracts; no colocation in a production tree. |
| Coverage exclusions | PASS | No `exclude`/`omit` entry matching a production source path is added; `pyproject.toml` untouched. |

## Plan Acceptance Gates (G1–G6) — PASS

The remediation plan `remediation-plan.2026-08-26T01-11.md` was inspected for the unfalsifiable-gate
classes. No `--cov` value appears in any acceptance command (G1-G4 have an empty subject set). The
search literals stated as acceptance conditions (`BAD_COUNT=0`, `EXIT_CODE=0`, `0 errors`) are
short, single-line, non-interpolated, and are quoted verbatim in the plan document (G5, G6 satisfied
by the plan-quotation condition).

Separately noted, and the reason `[P1-T3]` is discussed at length above: G1-G6 do not cover the
class of defect `[P1-T3]` exhibits — an acceptance probe that computes the wrong operand and is
therefore *always* falsified rather than never falsified. That is the mirror image of the
unfalsifiable-gate problem and is outside the current gate set. Recorded as C1-N4, a candidate for a
future gate rule, not a finding against this change.

## Orchestrator-State Contract — PASS

`artifacts/orchestration/orchestrator-state.json` validates (EXIT 0) and carries a
`human_interaction.requirements[]` entry with `response: "halt"`, a `raised_at` timestamp, a
`spec_criterion` naming `spec.md` line 644, and a requirement text that states both open questions
with file-and-line evidence and carries no recommendation. This satisfies invariants 1 and 2 of the
`human_interaction` block in `.claude/rules/orchestrator-state.md`; invariant 3 does not apply
(`response` is `halt`, not `exception`, so no `runbook_path` is required).

## Tonality — PASS

All artifacts produced by this branch — the remediation plan, the twenty-nine evidence records, and
the commit messages — use neutral, literal, evidence-matched language. Spot-checked the
`684592a8` commit message, which states the residual of its own fix plainly ("bounded rather than
complete") and states the unchecked task without minimizing it. No hyperbole, no humor, no metaphor.

The `CLAUDE.md` R2 edit is itself a tonality-adjacent change and is verified in the code review.

## Scope Containment — PASS

Every declared non-write was verified as a single `git diff --stat` over the merge-base range,
which produced **no output** for all of:

```
config/orchestration-routing.json
.claude/rules/csharp.md
AGENTS.md
.github/instructions/
.agents/
.codex/
extensions/drm-copilot/resources/codex-and-agents-customizations/
```

`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` — owned by concurrently
active feature 441 — was audited in full rather than deferred. Its diff is 25 lines changed: the two
pinned SHA-256 digest constants and their adjacent comment. The consuming test module
`test_parallel_orchestrator_surface_contracts.py` passes, which is the recomputation of both digests
against the committed bytes. No third constant, no test, and no assertion in that file was altered.

## Blocking Findings

**None. Total Blocking findings: 0.**

## Non-blocking Findings

| ID | Cycle 0 ID | Status | Summary | Location |
|---|---|---|---|---|
| C1-N1 | new | open | Exclusion set is name-based; a future gitignored subtree under `.claude/` silently reintroduces the defect. Remedy: guard test comparing `EXCLUDED_CLAUDE_SUBDIRS` to the `.claude/`-scoped entries parsed from `.gitignore` (pure text read, no subprocess). | `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:35-37` |
| C1-N2 | new | open | Commit `684592a8`'s rationale overstates the conftest guard's scope. The guard is node-ID-scoped to `test_new_active_feature_folder` and blocks only `code`/`code.cmd`/`code.exe`. The rejection decision remains correct on Ground 1. | `tests/conftest.py:64-139` |
| C1-N3 | new | open | `[P1-T3]` probe tests absolute-path parts, not `CLAUDE_ROOT`-relative parts, and is vacuous on the `worktrees` dimension when run from inside a worktree. Correctly left unchecked and carried forward. | `remediation-plan.2026-08-26T01-11.md:155-161` |
| C1-N4 | new | open | G1-G6 do not cover an acceptance probe that is *always* falsified by a wrong operand. Candidate future gate rule. | `.claude/rules/plan-acceptance-gates.md` |
| C1-N5 | new | open | `spec.md:631-632` requires `CLAUDE.md` to name `.claude/rules/tonality.md` as the "runtime-loaded **authoritative** source"; the R2 fix deliberately describes it as a **mirror** instead, to remove the contradiction. Amend the criterion; do not revert the fix. | `spec.md:631-632` |
| C1-N6 | N1 | **resolved** | Three evidence artifacts lacked `Command:`/`EXIT_CODE:`. Now carry explicit schema-classification sections; no `Command:` line was fabricated. | `evidence/other/ac-reconciliation.*`, `evidence/qa-gates/coverage-delta.*`, `evidence/qa-gates/not-applicable-gates.*` |
| — | N2 | **resolved** | `CLAUDE.md` two-authority contradiction. | `CLAUDE.md:11,13` |
| C1-N7 | N7 | open | Python branch coverage not collected repo-wide (`BRF` absent; no `--cov-branch`). Separate change against `pyproject.toml`. | `pyproject.toml:113-115` |
| C1-N8 | N8 | open | New test module at 499/500 lines; one line of headroom. Blocks C1-N1 without a module split. | `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` |
| C1-N9 | N3 | open | Digest test's assertion message still reads "pre-feature state" after the #559 re-baseline. Owned by feature 441. | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:482-485` |
| C1-N10 | N4 | open | `spec.md:623` unsatisfiable as written; exclusion clause does not cover gitignored runtime-generated artifact paths. Amend the criterion. | `spec.md:623-625` |
| C1-N11 | N5 | open | Tolerance branch selected by a verdict the executing agent authors. Substance independently verified. | `plan.2026-08-25T22-07.md` |
| C1-N12 | N6 | open | `[P6-T12]` checked while two criteria unchecked; fully disclosed. Resolves once C1-N10 lands. | `plan.2026-08-25T22-07.md:901-916` |
| C1-N13 | N9 | open | Newly scoped `parallel-orchestration.md` no longer auto-injected for the epic surface that cites it. Deliberate. | `.claude/skills/epic-orchestrate/SKILL.md:143-149` |
| C1-N14 | N10 | open | Defaulted test parameter motivated only by line length. Optional cleanup. | `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py:237-254` |
| C1-N15 | new | open | Two narrative artifacts remain under `evidence/qa-gates/` rather than `evidence/other/`. Acceptable: the schema in `evidence-and-timestamp-conventions/SKILL.md:108` is conditional ("When evidence artifacts are used for automated checking..."), and the collector drops non-conforming rows rather than failing. No action required. | `evidence/qa-gates/coverage-delta.*`, `evidence/qa-gates/not-applicable-gates.*` |

## Assumptions Recorded

1. The primary checkout at `C:/Users/DanMoisan/repos/drm-copilot` is on `main` (pre-fix content), so
   the two offenders reported by the cross-checkout probe are expected and are read as a positive
   control on assertion strength, not as a defect. This was inferred from the offenders' identity
   (exactly the two files this branch edits) rather than verified by inspecting that checkout's HEAD,
   because the review is worktree-isolated.
2. Elapsed time for the cross-checkout scan over sixteen nested worktrees was not measured; it
   completed within a single command invocation without timeout. The `rglob` walk still descends
   into `.claude/worktrees/` before filtering, so scan cost still scales with live worktree count.
   Not raised as a separate finding: the cost is borne only on the primary checkout, and CI has no
   nested worktrees.
3. Ground 2 of the `git ls-files` rejection ("no test makes a real unmocked git subprocess call") was
   spot-checked across the seventeen `subprocess`-referencing test modules by name and target, not
   exhaustively proven. Ground 1 is dispositive independently.
