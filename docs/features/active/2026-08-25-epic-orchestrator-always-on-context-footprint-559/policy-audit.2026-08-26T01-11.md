# Policy Audit — Issue #559 (epic-orchestrator always-on context footprint)

- Timestamp: 2026-08-26T01-11
- Reviewer: `feature-review`
- Branch: `bug/epic-orchestrator-always-on-context-footprint-559`
- HEAD: `aeac89a7`
- Base branch: `main`
- Merge base: `b36179b2`
- Audit scope: the full branch diff `b36179b2..aeac89a7` (55 files, +8207 / -49)
- Work mode: `full-bug` (`spec.md` is the sole acceptance-criteria source)

## Scope Resolution

The audit scope is the full branch diff against the resolved merge base. The PR context artifacts
`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent at review
start and were regenerated before proceeding:

```
poetry run python -m scripts.dev_tools.pr_context.collector --base b36179b2 --head aeac89a7 --repo-root .
EXIT_CODE: 0
```

## Rejected Scope Narrowing

None. The caller prompt directed a full-branch audit against the resolved merge base and attempted
no narrowing to a plan, task, phase, or file subset.

The caller stated "Languages in scope: Python ... and Markdown/YAML frontmatter. No PowerShell,
TypeScript, or C# file changes." That is a factual description of the branch diff, not a narrowing
instruction, and it was verified independently rather than accepted:

```
git diff --name-only b36179b2..aeac89a7
```

The 55 changed paths are 3 Python files (all under `tests/`), 43 Markdown files, and 9
Markdown files with YAML frontmatter. Zero `.ps1`, `.psm1`, `.ts`, `.tsx`, or `.cs` files are
changed. The language coverage verdicts below are therefore issued on measured evidence.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
5. `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`,
   `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/orchestrator-state.md`,
   `.claude/rules/self-explanatory-code-commenting.md`
6. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`,
   `.claude/skills/acceptance-criteria-tracking/SKILL.md`

## Verdict Summary

| Policy area | Verdict |
|---|---|
| Evidence location compliance | PASS |
| Suppression policy (`python-suppressions.md`) | PASS |
| Toolchain — format (`black --check`) | PASS |
| Toolchain — lint (`ruff check`) | PASS |
| Toolchain — type check (`pyright`) | PASS |
| Toolchain — unit tests (`pytest`) | PARTIAL |
| Coverage — Python | PASS |
| Coverage — PowerShell / TypeScript / C# | N/A (zero changed files) |
| File size limit (500 lines) | PASS |
| Test policy (`general-unit-test.md`) | **FAIL** |
| Plan acceptance gates (G1–G6) | PASS |
| Orchestrator-state contract | PASS |
| Tonality | PASS |
| Scope containment (declared non-writes) | PASS |

## Evidence Location Compliance — PASS

No file in the branch diff is written under `artifacts/baselines/`, `artifacts/baseline/`,
`artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`,
`artifacts/regression-testing/`, or `artifacts/post-change/`.

```
git diff --name-only b36179b2..aeac89a7 | grep -E "^artifacts/(baselines|baseline|qa|qa-gates|evidence|coverage|regression-testing|post-change)/"
EXIT_CODE: 1 (no matches)
```

```
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT_CODE: 0
```

All 29 evidence artifacts are written to canonical `<FEATURE>/evidence/<kind>/` paths using the
approved kinds `baseline/`, `regression-testing/`, `qa-gates/`, and `other/`.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

## Suppression Policy — PASS

`.claude/rules/python-suppressions.md` authorizes a suppression only via a pre-authorized pattern or
explicit user approval. The branch diff adds no suppression of any kind:

```
git diff b36179b2..aeac89a7 -- tests/ scripts/ | grep -nE "^\+.*(noqa|type: ignore|pyright: ignore|pylint:|# nosec|ruff: noqa|eslint-disable|PSScriptAnalyzer|SuppressMessage)"
EXIT_CODE: 1 (no matches)
```

An earlier `# noqa: E501` introduced during Phase 1 was removed in commit `1e2d5301` rather than
retained. The commit message records the correct reasoning: E501 is not a pre-authorized pattern,
prior instances elsewhere in the repository are precedent rather than authorization, and dropping
the return annotation was rejected because it would relocate the violation into
`.claude/rules/python.md` (full type annotation) instead of removing it. This is the disposition the
suppression rule requires.

## Toolchain Loop

Re-run by the reviewer against the branch head, not accepted from the executor's artifacts.

| Stage | Command | Result |
|---|---|---|
| 1. Format | `poetry run black --check` over the 3 changed Python files | PASS — "3 files would be left unchanged" |
| 2. Lint | `poetry run ruff check --no-fix` over the same 3 files | PASS — "All checks passed!" |
| 3. Type check | `poetry run pyright` over the same 3 files | PASS — "0 errors, 0 warnings, 0 informations" |
| 4. Architecture boundaries | n/a — no Python architecture-boundary gate applies to test-only changes | N/A |
| 5. Unit tests | `poetry run pytest` (targeted, 5 modules, 65 items) | **PARTIAL — 1 failed, 64 passed** |
| 6. Contract / schema | `validate_orchestration_artifacts plan` and `orchestrator-state` | PASS |
| 7. Integration tests | n/a — no integration suite covers Markdown runtime surfaces | N/A |

### Stage 5 detail — the single failure

```
poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py \
  tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py \
  tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py \
  tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py \
  tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:randomly
```

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
E   AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
1 failed, 64 passed in 0.30s
```

The failure reproduces exactly as the executor recorded it. Its disjointness from this change was
verified rather than accepted; see the Feature Audit for the full adjudication. The stage is marked
PARTIAL because `pytest` did not exit 0, which is what the toolchain rule states.

### Stage 6 detail

```
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan \
  docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/plan.2026-08-25T22-07.md \
  --workspace-root .
-> plan validation passed
```

No `PLAN GATE WARNING:` was emitted, so the plan produces no G1–G6 finding in either severity
channel. Rules G2, G3, G5, and G6 ran with the repository seam supplied via `--workspace-root .`.

```
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state \
  artifacts/orchestration/orchestrator-state.json
-> orchestrator-state validation passed
```

## Coverage Verification

Coverage was verified from the pre-existing artifact. No coverage generation was re-run.

| Language | Changed files on branch | Coverage artifact | Verdict |
|---|---|---|---|
| Python | 3 (all under `tests/`) | `artifacts/python/lcov.info` — PRESENT | **PASS** |
| PowerShell | 0 | not required | N/A |
| TypeScript | 0 | not required | N/A |
| C# | 0 | not required | N/A |

### Python — PASS

Repo-wide line coverage parsed directly from the artifact:

```
awk -F: '/^LF:/{lf+=$2} /^LH:/{lh+=$2} /^BRF:/{brf+=$2} /^BRH:/{brh+=$2} END{...}' artifacts/python/lcov.info
LF=15014 LH=13910 line=92.65%
BRF=0 BRH=0
```

- Repo-wide line coverage: **92.65%** against the uniform 85% floor. Margin +7.65 pp. PASS.
- Signed delta against baseline: **+0.00 pp** (baseline 13910/15014, post-change 13910/15014).
- New production files: **zero**. No new-file tier applies.
- Modified production files: **zero**. No modified-file tier applies.

The zero-delta reasoning was verified structurally rather than accepted:

```
sed -n '117,119p' pyproject.toml
[tool.coverage.run]
source = ["src", "scripts/dev_tools"]
```

```
git diff --name-only b36179b2..aeac89a7 -- src/ scripts/
(no output — zero changed files under either coverage source root)
```

`src/` contains zero `.py` files (`find src -name "*.py" | wc -l` -> `0`; its only member is
`hello-typescript.ts`), so `--cov=scripts.dev_tools` measures the entire Python production surface
and the 92.65% figure is genuinely repo-wide rather than a partial-root figure. The three changed
Python files are all under `tests/`, which the permitted `omit = ["tests/*", "*/tests/*"]` entries
exclude. The denominator is therefore structurally unchanged and the metric cannot regress. The
executor's claim is confirmed on independent evidence.

Coverage exclusion policy: no `exclude`/`omit` entry matching a production source path is added or
modified by this change. `pyproject.toml` is not in the diff.

### Python branch coverage — unevaluated (Non-blocking, pre-existing)

`artifacts/python/lcov.info` records `BRF=0` and `BRH=0`: no branch data was collected, because
neither `pyproject.toml` nor the invoking command passes `--cov-branch`. The uniform 75% branch
floor in `.claude/rules/quality-tiers.md` is therefore unevaluated for Python repo-wide.

This is a pre-existing repository configuration gap, not introduced or worsened here: the change
adds zero production Python, so it cannot regress branch coverage, and `pyproject.toml` is outside
the declared blast radius. Recorded as Non-blocking finding N7.

## File Size Limit — PASS

`.claude/rules/general-code-change.md` caps production, test, and reusable script files at 500
lines. Markdown documentation is exempt.

| File | Lines | Verdict |
|---|---|---|
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | 499 | PASS (1 line of headroom — see N8) |
| `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py` | 437 | PASS |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 339 | PASS |

## Test Policy (`general-unit-test.md`) — FAIL

Five of the six core principles are satisfied by both new modules: isolation, fast execution
(0.30 s for 65 items), readability, and Arrange–Act–Assert structure with actionable failure
messages that name every offender rather than only the first. No test creates or uses a temporary
file. No test touches a network, database, or external process. No test depends on wall-clock time
or unseeded randomness. Both modules read committed repository text only.

Principle 4 (Determinism) and the rule "Tests must not rely on mutable global state or external
configuration that can change between runs" are **violated by one new test**.

`tests/scripts/dev_tools/test_claude_rules_frontmatter.py:307-327` defines
`claude_markdown_files()`, which walks `CLAUDE_ROOT.rglob("*.md")` and skips only the subdirectory
named in `EXCLUDED_CLAUDE_SUBDIRS = frozenset({"agent-memory"})`. It does not skip
`.claude/worktrees/`, which is this repository's standard agent-worktree location
(`.gitignore:21: .claude/worktrees`) and currently holds sixteen full repository copies
(`git worktree list`). Its consumer
`test_no_unqualified_spec_section_citation_under_claude` (lines 479-499) therefore scans every
nested worktree's `docs/features/**` and reports their `spec.md §` occurrences as offenders.

Reproduced empirically against a synthetic tree with the module's own helpers:

```
scanned files: ['.claude\\worktrees\\agent-x\\docs\\spec.md']
offenders:     ['.claude\\worktrees\\agent-x\\docs\\spec.md']
WOULD_FAIL: True
```

The offending content exists in the real tree: `git grep -c -F "spec.md §" -- 'docs/**/*.md'`
returns eight matching files, including this feature's own `spec.md` (4 occurrences) and `issue.md`
(2 occurrences), each of which the criterion at `spec.md:613-615` explicitly places out of scope.

Consequences:

1. The test passes when run from inside a worktree (where `.claude/worktrees/` does not exist) and
   fails when run from the primary checkout at `C:/Users/DanMoisan/repos/drm-copilot`. The result
   depends on machine state that is not part of the test's inputs.
2. The scan cost scales with the number of live worktrees rather than with the repository.

CI is unaffected (a CI checkout has no nested worktrees), which is why the executor's own runs did
not surface it. The verdict is nonetheless FAIL: the primary development checkout is a supported
place to run the suite, and this is the same defect class — filesystem enumeration in place of a git
query — that this change's own evidence correctly identifies as the cause of the tolerated
`list_scoped_files` failure it defers. Introducing a second instance of a defect class while
deferring the first is not a defensible disposition.

Recorded as Blocking finding **B1**.

## Plan Acceptance Gates (G1–G6) — PASS

The plan validator ran with a repository seam and produced neither an error nor a warning. Reviewed
independently for unfalsifiable acceptance conditions:

- No acceptance condition in the 73-task plan uses a `--cov` value with a path separator or a `.py`
  suffix; the only coverage command used is `--cov=scripts.dev_tools`, the importable dotted form
  with `=`.
- The plan contains zero `git grep` acceptance conditions, so the G5/G6 tree-absence class does not
  arise.
- Acceptance conditions that could have degraded into no-ops are explicitly hardened: the four
  `git diff` guards all mandate the `HEAD` operand and state why
  (`[P2-T6]`, `[P6-T9]`, F5 invariance, scope containment), because a bare `git diff` reads as
  falsely clean once a change is staged. The F5 invariance artifact additionally demonstrates
  non-vacuity by resolving its pathspec to 37 tracked files.
- `[P2-T13]`, `[P3-T18]`, and `[P6-T4]` carry a conditional tolerance branch that is narrowly
  constructed: it admits exactly one named failure, requires the `[P0-T11]` verdict to be `PRESENT`,
  and states that any second failure fails the task under either branch. It is not an open escape
  hatch. Its one structural weakness — the branch selector is a value the executing agent authors —
  is recorded as Non-blocking finding N5.

No unfalsifiable acceptance condition was identified.

## Orchestrator-State Contract — PASS

`artifacts/orchestration/orchestrator-state.json` validates. The `human_interaction` block satisfies
all three invariants of `.claude/rules/orchestrator-state.md`: it is an object carrying a
`requirements` list; the single requirement's `response` is `halt` (a member of the enum); and
because the response is not `exception`, no `runbook_path` is required. The requirement text states
both open questions with file-and-line evidence, carries no recommendation, and characterizes
neither option as preferable.

## Tonality — PASS

All authored prose in the branch — runtime surface text, plan, spec, and 29 evidence artifacts — is
professional, factual, and measured. No humor, hyperbole, or decorative metaphor was found. Claims
are matched to evidence: the `ac-reconciliation` artifact reports its own deviation from
`[P6-T12]`'s expected count "plainly" rather than concealing it, and the `baseline-pytest-coverage`
artifact preserves both the superseded and the operative reading with their separate timestamps.

One content observation, not a tonality violation, is recorded as N2: `CLAUDE.md` now names two
different authoritative sources for tone policy in adjacent paragraphs.

## Scope Containment — PASS

Every declared non-write was verified unmodified across the full branch diff, not merely against
the working tree:

```
git diff --stat b36179b2..aeac89a7 -- config/orchestration-routing.json .claude/rules/csharp.md \
  AGENTS.md .github/instructions/ .agents/ .codex/ \
  extensions/drm-copilot/resources/codex-and-agents-customizations/
(no output — all unmodified)
```

```
git diff --stat b36179b2..aeac89a7 -- .claude/rules/general-unit-test.md .claude/rules/quality-tiers.md \
  .claude/rules/general-code-change.md .claude/rules/python.md .claude/rules/typescript.md \
  .claude/rules/powershell.md .claude/rules/shell.md .claude/skills/feature-review-workflow/SKILL.md \
  .claude/skills/python-qa-gate/SKILL.md .claude/skills/powershell-qa-gate/SKILL.md AGENTS.md \
  .github/instructions/
(no output — all unmodified)
```

No coverage threshold value and no toolchain stage count is altered anywhere in the branch. The
F5 reservation held.

The working tree is clean (`git status --porcelain` returns zero entries).

## Blocking Findings

**Total Blocking findings: 1**

### B1 — New test is non-deterministic with respect to machine state (Blocking)

- File: `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
- Lines: `37` (`EXCLUDED_CLAUDE_SUBDIRS`), `307-327` (`claude_markdown_files`),
  `479-499` (`test_no_unqualified_spec_section_citation_under_claude`)
- Violated rule: `.claude/rules/general-unit-test.md` — "Determinism: Given the same inputs and
  environment, tests must produce the same results" and "Tests must not rely on mutable global state
  or external configuration that can change between runs."
- Evidence: see the Test Policy section above. Reproduced empirically.
- Remedy (either is sufficient): add `"worktrees"` and `"state"` to `EXCLUDED_CLAUDE_SUBDIRS`; or
  enumerate the scan set from git (`git ls-files -- .claude`) so untracked and gitignored trees
  cannot enter it. The second option also removes the defect class the change's own evidence
  identifies.

## Non-blocking Findings

| ID | Finding | Location |
|---|---|---|
| N1 | Three evidence artifacts lack `Command:` and `EXIT_CODE:`; one also lacks `Output Summary:`. Two of the three sit under `qa-gates/`. The claim that all 29 carry the four fields is overstated. | `evidence/other/ac-reconciliation.2026-08-26T00-00.md`, `evidence/qa-gates/coverage-delta.2026-08-26T00-00.md`, `evidence/qa-gates/not-applicable-gates.2026-08-26T00-00.md` |
| N2 | `CLAUDE.md` now names two different authoritative tone sources in adjacent paragraphs: `.claude/rules/tonality.md` ("the authoritative source") and the two `.github/` files ("Those files are authoritative"). F5 removed one duplication but left an authority ambiguity. | `CLAUDE.md:11-13` |
| N3 | The consuming digest test was deliberately not modified (it is owned by feature 441), so its assertion message still reads "must be byte-identical to its **pre-feature** state" after the #559 re-baseline. A future maintainer reading the failure message is not pointed at the re-baseline rationale. | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:482-485` |
| N4 | The criterion at `spec.md:623` admits exactly one exclusion (template placeholder) and is therefore unsatisfiable while a gitignored runtime-generated path is cited. Amend to exclude runtime-generated artifact paths, or name the path explicitly. | `spec.md:623-625` |
| N5 | The tolerance branch of `[P2-T13]`, `[P3-T18]`, and `[P6-T4]` is selected by a verdict recorded in an artifact the executing agent authors and amended mid-run (`ABSENT` -> `PRESENT`). The amended verdict was independently verified correct, so there is no delivery defect, but a gate conditioned on a self-authored value is structurally weak. | `plan.2026-08-25T22-07.md` `[P2-T13]`, `[P3-T18]`, `[P6-T4]` |
| N6 | `[P6-T12]` is checked `[x]` while its acceptance condition "exactly one criterion of the 38 is recorded as unchecked and blocked" holds only on the reading that `spec.md:623` is unchecked-but-not-blocked. The deviation is disclosed prominently rather than concealed. | `plan.2026-08-25T22-07.md:901-916` |
| N7 | Python branch coverage is not collected repo-wide (`BRF=0` in `artifacts/python/lcov.info`; no `--cov-branch`). The uniform 75% branch floor is unevaluated for Python. Pre-existing; this change adds zero production Python. | `pyproject.toml:113-126` |
| N8 | The new frontmatter module is 499 lines against the 500-line ceiling. Any future addition forces a split. | `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` |
| N9 | `epic-orchestrate/SKILL.md` cites `.claude/rules/parallel-orchestration.md` for the cache doctrine, but F3 scopes that rule so it is no longer auto-injected for the epic surface. The citation now requires an explicit read. Deliberate and consistent with the change's intent; recorded so a later reader does not mistake it for an oversight. | `.claude/skills/epic-orchestrate/SKILL.md:143-149` |
| N10 | `test_epic_startup_protocol_...` takes a defaulted `agent_path` parameter whose only motivation is keeping the `def` line under 88 characters after the E501 suppression was removed. It works, but a module-level constant with a plain no-arg signature would read more directly. | `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py:237-254` |

## Assumptions Recorded

- The PR context artifacts were regenerated at review start using the supplied merge base
  `b36179b2`. No `PRBaseBranch` ambiguity arose.
- `quality-tiers.yml` does not exist at the repository root, so no tier classification could be read
  for the changed files. This is a pre-existing repository condition outside this change's scope and
  does not affect the verdicts above, because every threshold applied here is uniform across T1–T4.
- Stage 5 was run as a targeted five-module selection rather than the full suite, because the full
  suite's result is already recorded in `evidence/qa-gates/final-pytest-coverage.2026-08-26T00-00.md`
  (1 failed, 4150 passed, 5 skipped) and the targeted selection reproduces the single failure
  exactly. Coverage figures were taken from the artifact, not re-generated.
