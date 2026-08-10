# Policy Audit — parallel-planner-surface (Issue #443)

- Timestamp: 2026-08-08T16-21
- Cycle: remediation cycle 1 exit reaudit (full feature-vs-base reaudit, not a delta review)
- Branch: `feature/parallel-planner-surface-443`
- Base / merge base: `b086cf6958ee4b628f60309cda80aac772304bc8`
- Diff command: `git diff b086cf6958ee4b628f60309cda80aac772304bc8...HEAD`
- Head commit: `15656e4c` (`fix(parallel-planner): bind kickoff template to its validator and correct the seam`)
- Work Mode: `full-feature` (marker at `issue.md:10`) — AC sources are `spec.md` and `user-story.md`
- Working tree: clean at audit time (`git status --porcelain` empty)

## Scope Statement

The audited scope is the full branch diff against the resolved base branch: 106 changed files
(83 Markdown, 13 TypeScript, 9 Python, 1 JSON), 11267 insertions, 143 deletions. Every item that
passed at cycle entry was re-checked, not assumed.

### Rejected Scope Narrowing

None. The caller directive explicitly instructed a full feature reaudit and did not attempt to
narrow scope to the remediated lines, to a plan phase, or to a file subset. The directive's
"Settled decisions" section adjudicates the F4 kickoff-contract ownership boundary; that is a
legitimate epic-manifest adjudication recorded in
`docs/features/epics/parallel-orchestration/epic.md` and in
`.claude/rules/parallel-orchestration.md`, not a scope narrowing, and it is honored.

### PR Context Artifacts

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent at audit
start and were regenerated before proceeding.

- Command: `poetry run python -m scripts.dev_tools.pr_context.collector --base b086cf6958ee4b628f60309cda80aac772304bc8 --head HEAD --repo-root .`
- EXIT_CODE: 0

## Verdict Summary

| Dimension | Verdict |
|---|---|
| Policy reading order and canonical-policy non-modification | PASS |
| Scope and ownership boundary | PASS |
| Protected-surface non-modification | PASS |
| Mirror byte identity | PASS |
| Pack-manifest registration | PASS |
| Additive wiring, no reflow | PASS |
| 500-line file-size limit | PASS |
| Python toolchain (Black, Ruff, Pyright, pytest) | PASS |
| TypeScript toolchain (Prettier, ESLint, tsc, Jest) | PASS |
| Architecture-boundary stage | NOT CONFIGURED (pre-existing, repo-level) |
| Python coverage | PASS |
| TypeScript coverage | PASS |
| PowerShell coverage | N/A (zero changed files) |
| C# coverage | N/A (zero changed files) |
| Coverage exclusion policy | PASS |
| Unit-test policy (temp files, external processes, location) | PASS |
| Suppression policy (Python and TypeScript) | PASS |
| Commenting and docstring policy | PASS |
| Evidence location compliance | PASS |
| Tonality policy | PASS |

**Finding counts: Blocking 0, Non-blocking 0, Advisory 5.**

## Remediated-Finding Verification

Each cycle-entry claim was verified independently rather than accepted from the executor's report.

### B1 — `RESUME_RE` widening — RESOLVED

Cross-runtime parity was checked by extracting both pattern strings and comparing them
programmatically, not by visual inspection.

- Python: `scripts/dev_tools/parallel_kickoff_contract.py:78-83`
- TypeScript: `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts:27-28`
- Compiled pattern (both runtimes, byte-identical):
  `(?:Every item|Each item|items)\s+resumes?\s+at atomic execution\s+from\s+(?:its|their)\s+committed plan-path\s+on\s+(?:its|their)\s+own\s+(?:pushed\s+)?feature branch`
- `RESUME_RE.pattern == <TS literal>` evaluated `True`.
- Case-insensitivity present in both (`re.IGNORECASE` / `/i`).

Decision-logic comment citing the governing spec wording is present at
`scripts/dev_tools/parallel_kickoff_contract.py:68-77`.

**Non-vacuity of the widening.** `RESUME_RE` is applied with `search` and carries no word
boundary, so the bare `items` alternant could in principle make the matcher vacuous. Verified it
does not: the negative-case guard subject `Each entry` contains none of `Every item`, `Each item`,
or `items` as a substring (all three membership tests evaluated `False`), and end-to-end the
negative rendering still yields exactly one error:

```
NEGATIVE GUARD errors: ['Parallel kickoff invocation must structurally name the manifest,
plan-home branch, and atomic-execution resume boundary.']
```

The negative-case rationale is documented in both test modules
(`tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py:339-345`,
`extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts:278-283`),
including why `Some items` would not be a valid negative.

### B2 — `## Integrity` field name — RESOLVED

- `.claude/skills/parallel-plan/SKILL.md:381` now emits `planning_commit: <hex>`.
- `INTEGRITY_COMMIT_RE` was NOT widened. Confirmed by reading the live pattern:
  `^(?:-\s*)?planning_commit:\s*`?(?P<commit>[0-9a-fA-F]{7,64})`?\s*$`
  at `scripts/dev_tools/_parallel_kickoff_tables.py:28-30`. The TypeScript analogue at
  `parallel-kickoff-artifact.ts:29-30` is identical after the language-inherent named-group
  syntax normalization (`(?P<commit>` vs `(?<commit>`); the normalized comparison evaluated `True`.
- Bundled mirror re-synced byte-identically (see Mirror Byte Identity below).

### B3 — Acceptance criteria evidence — RESOLVED

**Preserve-text rule honored.** `git diff cd57985d..HEAD -- spec.md user-story.md` filtered to
checkbox lines (`^[-+]- \[`) returned zero lines. No acceptance-criterion line — text or checkbox
state — was altered by the remediation commit. The Phase 0 revert and Phase 7 re-check therefore
netted out within a single commit, which is the expected shape.

The only line changed in either AC source file is `user-story.md:135`, in the `## Non-Goals`
prose section, not an acceptance criterion (this is the N3 correction). Editing it is permitted:
the preserve-text rule scopes to criterion text.

**Evidence support.** All 30 criteria were re-evaluated independently in
`feature-audit.2026-08-08T16-21.md`. The two criteria that were FAIL/PARTIAL at cycle entry
(spec criteria 11 and 20) are now supported by the seam tests and by an independently reproduced
CLI run, not by heading presence. Three criterion clauses are superseded by landed upstream
contracts; the supersession is recorded in prose at `spec.md:582-603` with criterion text left
byte-identical, which is the correct handling under the preserve-text rule.

### B4 — Seam tests — RESOLVED, and verified discriminating

The claim that the seam tests would fail if B1 or B2 regressed was tested rather than assumed.
Both regressions were simulated in memory, with no source file modified, by rebinding the module
attribute and by rewriting the rendered document.

| Condition | Contract module result |
|---|---|
| Baseline, with `## Integrity` | `[]` |
| Baseline, without `## Integrity` | `[]` |
| B1 regressed (alternation narrowed to `Every item`) | `['Parallel kickoff invocation must structurally name the manifest, plan-home branch, and atomic-execution resume boundary.']` |
| B2 regressed (template emits `commit:`) | `['Parallel kickoff integrity line is invalid: commit: 4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d']` |

Both simulated regressions produce a non-empty error list against the rendered template, so
`test_rendered_template_with_integrity_validates_clean` and its TypeScript twin would fail. The
tests are genuinely discriminating.

**No external process, no temporary file.** A targeted scan of all new and modified test modules
for `tmp_path`, `tempfile`, `NamedTemporary`, `mkdtemp`, `subprocess`, `child_process`,
`writeFileSync`, and `write_text` returned exactly one hit, and it is a docstring string literal
(`test_parallel_planner_surface_contracts_landed.py:75`), not an invocation. Neither seam module
spawns a process; both read committed repository files only, which follows the precedent named in
each module's own header (`test_parallel_planner_surface_contracts.py` and
`test/lib/push-down/claude-pack-manifest-completeness.test.ts`).

**Cross-runtime substitution parity.** All five substitution constants (`SLUG`, `ISO8601`,
`PLANNING_COMMIT_HEX`, `PLAN_PATH`, `PLAN_HASH_HEX`) were confirmed present byte-identically in
the TypeScript module, so a rendering divergence cannot mask a contract divergence.

### N1, N2, N3 — RESOLVED

- N1: `evidence/other/kickoff-module-size.2026-08-08T14-17.md` now carries `Command:` (line 116),
  `EXIT_CODE: 0` (line 118), and `Output Summary:` (line 120), with a correction note at lines
  108-112 explaining the retained original timestamp.
- N2: `evidence/baseline/phase0-instructions-read.md` renamed to
  `evidence/baseline/phase0-instructions-read.2026-08-08T13-49.md`. All five files in
  `evidence/baseline/` now carry an ISO timestamp component.
- N3: `user-story.md:135` now reads `conflicts(a, b, config)`. Verified against the landed
  signature at `scripts/dev_tools/_blast_radius_conflicts.py:137-139`:
  `def conflicts(a: BlastRadius, b: BlastRadius, config: Mapping[str, object]) -> ConflictResult`.

### A1, A3 — DEFERRED (correctly)

Both recommend edits to `.claude/rules/parallel-orchestration.md` and
`.claude/skills/epic-plan/SKILL.md` respectively, which are protected surfaces under this
feature's non-modification guarantee. Deferral is the correct disposition. They remain open
Advisory findings; see the Advisory Findings section.

### A2 — RESOLVED (comment-only)

`extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts:12-19` now carries a header
note directing readers to the Python modules as the documented reference for the shared algorithm,
with the stated rationale that duplicating rationale would let the two ports drift into
inconsistent explanations.

## End-to-End CLI Proof (independently reproduced)

The rendered template was validated through the real CLI subcommand, not through a library call.

```
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-kickoff <rendered-with-integrity>
parallel-kickoff validation passed: ...kickoff-with.md
EXIT_CODE: 0

poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-kickoff <rendered-without-integrity>
parallel-kickoff validation passed: ...kickoff-without.md
EXIT_CODE: 0
```

Both renderings were produced by calling the seam module's own extraction and rendering helpers
against the live `.claude/skills/parallel-plan/SKILL.md`, so the documents validated are exactly
the documents a planner following the skill would emit. Rendered files were written to the
session scratchpad, outside the repository.

## Protected-Surface Non-Modification

Diff filtered against every protected path returned `NONE TOUCHED`:

- `.claude/skills/atomic-plan-contract/**`
- `.claude/agents/epic-planner.md`
- `.claude/skills/epic-plan/**`
- `.claude/skills/orchestrate/**`
- `config/orchestration-routing.json`
- `.claude/rules/**`
- `scripts/dev_tools/epic_kickoff_contract.py`
- `extensions/drm-copilot/src/lib/validate/epic-kickoff-artifact.ts`
- `scripts/dev_tools/validate_parallel_planner_state.py`
- `scripts/dev_tools/validate_parallel_orchestrator_state.py`
- `scripts/dev_tools/parallel_manifest_contract.py`

**Verdict: PASS.**

## Mirror Byte Identity

| Canonical | Mirror | `cmp` |
|---|---|---|
| `.claude/agents/parallel-planner.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md` | identical |
| `.claude/skills/parallel-plan/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | identical |

**Verdict: PASS.**

## Pack-Manifest Registration

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` gains exactly
two entries, each inserted in existing sort order with no reflow:

- `.claude/agents/parallel-planner.md` (agents block)
- `.claude/skills/parallel-plan/SKILL.md` (skills block)

**Verdict: PASS.**

## Additive Wiring — No Reflow

The `parallel-kickoff` artifact type is registered on exactly five surfaces, each as a single
added line with no reordering or reformatting of neighbouring entries:

| Surface | Change |
|---|---|
| `scripts/dev_tools/validate_orchestration_artifacts.py:183` | one subparser tuple member |
| `scripts/dev_tools/validate_orchestration_artifacts.py:360-361` | one dispatch branch |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:279-280` | one `case` arm |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts:414` | one enum member |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts:347` | one enum member |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts:438` | one `VALID_ARTIFACT_TYPES` member |

**Verdict: PASS.**

## Scope and Ownership Boundary

`scripts/dev_tools/parallel_kickoff_contract.py`,
`scripts/dev_tools/_parallel_kickoff_tables.py`,
`extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts`, and the third
`artifact_type` are F4-owned by the epic adjudication in
`docs/features/epics/parallel-orchestration/epic.md` section "Planner Adjudication: the
kickoff-contract boundary (F3 / F4)" and by `.claude/rules/parallel-orchestration.md` section
"F3 Scope Boundary — kickoff contract deferred to F4". The deviation is recorded in
`spec.md:556-579`. Not reported as a scope violation.

**F3 enum consumption without extension — PASS.** The delivered skill and agent reference
`depends_on`, `integration_branch`, `epic_worthiness`, and `wave` only in negative-constraint
statements (`SKILL.md:274`, `SKILL.md:300`, `parallel-planner.md:111`). No parallel enum gains a
member; no schema is redefined. The F3 ownership boundary is restated explicitly at
`SKILL.md:326-338`.

**P9 kickoff-path invariant — PASS.** `SKILL.md:290-291` and `SKILL.md:308-309` both state
`kickoff_prompt_path` exactly as `artifacts/orchestration/parallel-kickoff-<slug>.md`, matching
the P9 wording in `.claude/rules/parallel-orchestration.md`.

**Landed upstream signatures — PASS.** Each was checked against the source of truth, not against
the skill's own claim:

| Signature | Source | Skill citation |
|---|---|---|
| `conflicts(a, b, config) -> ConflictResult` | `_blast_radius_conflicts.py:137-139` | `SKILL.md:168-172` |
| `derive_blast_radius(plan_text, spec_text, feature_folder, config, *, source, computed_at)` | `compute_blast_radius.py:216-224` | `SKILL.md:155-160` |
| `compute_cohorts(item_keys, conflict_edges)` — two parameters, no pinned set | `parallel_cohort_computation.py:350-353` | `SKILL.md:210-216` |

**F1a fail-closed corrections not reintroduced — PASS.** `SKILL.md:174-180` records both
corrections (separator-free repository-root shared-surface reach; listed-directory prefix honoring
in the contention path), states that both move results in the fail-closed direction, and instructs
that neither be worked around nor a radius narrowed to suppress a resulting conflict edge. No
delivered code reimplements derivation, validation, or the contention relation.

## File-Size Limit (500 lines)

Every changed non-Markdown file was measured. Zero violations. Largest changed files:

| Lines | File |
|---|---|
| 480 | `extensions/drm-copilot/src/mcp-tool-inputs.ts` |
| 454 | `extensions/drm-copilot/src/mcp-tool-definitions.ts` |
| 449 | `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` |
| 413 | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py` |
| 410 | `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` |
| 405 | `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` |
| 398 | `scripts/dev_tools/validate_orchestration_artifacts.py` |
| 386 | `scripts/dev_tools/parallel_kickoff_contract.py` |
| 378 | `tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py` |
| 374 | `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` |

Markdown is exempt per `.claude/rules/general-code-change.md`. `.claude/agents/parallel-planner.md`
is 149 lines and `.claude/skills/parallel-plan/SKILL.md` is 420 lines, both satisfying spec
criterion 18 independently of the exemption.

**Verdict: PASS.**

## Toolchain Verification

All stages executed by this reviewer against the branch head, not read from evidence artifacts.

### Python

| Stage | Command | Result |
|---|---|---|
| Format | `poetry run black --check .` | 369 files unchanged, EXIT_CODE 0 |
| Lint | `poetry run ruff check .` | All checks passed, EXIT_CODE 0 |
| Type check | `poetry run pyright` | 0 errors, 0 warnings, 0 informations |
| Unit tests | `poetry run pytest --cov --cov-branch` | 2968 passed |

### TypeScript

| Stage | Command | Result |
|---|---|---|
| Format | `npx prettier --check "src/**/*.ts" "test/**/*.ts"` | All matched files use Prettier code style |
| Lint | `npm run lint` (eslint src test) | clean, no output |
| Type check | `npm run typecheck` (`tsc -p ./ --noEmit`) | clean, no output |
| Unit tests | `npm run test:unit:coverage` (repo root) | 183 suites, 2451 tests passed |

### Feature-scoped Python suites

`poetry run pytest` over the six feature test modules: **97 passed**.

### Architecture-boundary stage

`.claude/rules/architecture-boundaries.md` names `dependency-cruiser` with a
`.dependency-cruiser.cjs` configuration. No such configuration file exists at the repository root
or under `extensions/drm-copilot/`, and no `depcruise` npm script is defined. This is a
pre-existing repository-level gap, not introduced by this feature; the feature adds no
cross-layer import (the new TypeScript module imports nothing outside
`src/lib/validate/`, and the new Python modules import only from `scripts/dev_tools/`).

**Verdict: NOT CONFIGURED (pre-existing, out of scope for this feature).**

## Coverage Verification

Coverage was verified by parsing the pre-existing coverage artifacts and by an independent
regeneration. Both agree.

### Coverage artifacts

| Language | Artifact | Present |
|---|---|---|
| Python | `artifacts/python/lcov.info` | yes |
| TypeScript | `coverage/lcov.info` | yes |
| PowerShell | `artifacts/pester/powershell-coverage.xml` | n/a — zero changed PowerShell files |
| C# | `artifacts/csharp/coverage.xml` | n/a — zero changed C# files |

### Python — PASS

- Repo-wide line: 12432 / 13539 = **91.8236%** (threshold >= 85%)
- Repo-wide branch: 4190 / 5000 = **83.8000%** (threshold >= 75%)
- 158 files measured

Per changed production file:

| File | Status | Line | Branch | Verdict |
|---|---|---|---|---|
| `scripts/dev_tools/parallel_kickoff_contract.py` | new | 91/91 = 100.00% | 26/26 = 100.00% | PASS |
| `scripts/dev_tools/_parallel_kickoff_tables.py` | new | 72/72 = 100.00% | 38/38 = 100.00% | PASS |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | modified | 119/127 = 93.70% | 44/52 = 84.62% | PASS |

### TypeScript — PASS

- Repo-wide line: 42656 / 43900 = **97.1663%** (threshold >= 85%)
- Repo-wide branch: 6011 / 6712 = **89.5560%** (threshold >= 75%)
- 188 files measured

Per changed production file:

| File | Status | Line | Branch | Verdict |
|---|---|---|---|---|
| `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts` | new | 374/374 = 100.00% | 103/116 = 88.79% | PASS |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | modified | 284/284 = 100.00% | 66/67 = 98.51% | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts` | modified | 454/480 = 94.58% | 64/69 = 92.75% | PASS |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` | modified | 454/454 = 100.00% | 0/0 (declarative) | PASS |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | modified | 405/405 = 100.00% | 0/0 (declarative) | PASS |

Note on the two figure sets: running Jest from `extensions/drm-copilot/` yields a narrower scope
(96.52% / 89.74%) than the repo-root run. The policy table names `coverage/lcov.info` as the
TypeScript coverage artifact, which is produced by the repo-root `npm run test:unit:coverage`;
that artifact is the one reported above and it reproduces the executor's claimed figures exactly.

### Scrutiny of the Python branch delta (-0.02 pp)

The executor's explanation is **adequately evidenced**, and this reviewer corroborated it
independently on four points.

1. **The figures reproduce exactly.** An independent full-suite run produced 12432/13539 and
   4190/5000 — identical to the recorded post-change values to four decimal places.
2. **The named arc is the one missing.** `artifacts/python/lcov.info` records
   `BRDA:395,0,jump to line 362,0` for `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py`,
   confirming arc `[395, 362]` is uncovered while the sibling arc
   `BRDA:395,0,jump to line 396,1` is covered.
3. **The arc is structurally timing-dependent.** Reading
   `cli_copilot_runtime.py:362-403` confirms the arc is the loop-continuation edge from the
   `if idle_timeout_seconds is not None and process.poll() is None:` guard at line 395 back to the
   `while True:` header at line 362, inside a subprocess output-streaming loop driven by a reader
   thread, `queue.get(timeout=0.1)`, and `time.monotonic()`. Whether the loop iterates again after
   that guard depends on real subprocess and thread scheduling. The classification as a
   nondeterministic loop edge is corroborated by the source, not merely asserted.
4. **The file is outside the change set.** `cli_copilot_runtime.py` does not appear in the branch
   diff. It therefore has zero changed lines, so the "no regression on changed lines" rule is not
   engaged by this delta.

One qualification is recorded for accuracy: three additional independent full-suite runs by this
reviewer all produced branch 4190/5000, i.e. the arc was missing in all four of this reviewer's
runs. That is consistent with the executor's stability claim for the post-change state, and
consistent with a low-probability flip, but this reviewer did not directly observe the arc in its
covered state. The corroboration above is therefore structural plus reproduction, not a direct
reproduction of the flip.

**Conclusion:** not a genuine regression attributable to this feature. Both axes remain far above
threshold (83.80% against a 75% floor). Recorded as Advisory A-5 for a repo-level follow-up on the
flaky arc, not as a finding against this feature.

## Coverage Exclusion Policy

`git diff` over `pyproject.toml`, `.coveragerc`, `jest.config.cjs`, `run-jest.cjs`,
`extensions/drm-copilot/jest.config.cjs`, `package.json`, and
`extensions/drm-copilot/package.json` is empty. No coverage configuration was changed, so no
`exclude` entry matching a production source path was added.

**Verdict: PASS.**

## Unit-Test Policy

| Requirement | Verdict | Evidence |
|---|---|---|
| No temporary files | PASS | targeted scan over all nine new/modified test modules found zero temp-file APIs |
| No external processes | PASS | no `subprocess` / `child_process` import or invocation in any new test module |
| No network or database | PASS | new tests read committed files and call in-process functions only |
| Test location mirrors source | PASS | `tests/scripts/dev_tools/...` and `extensions/drm-copilot/test/lib/validate/...`; no colocation in a production tree |
| Arrange–Act–Assert | PASS | every new Python test carries explicit `# Arrange` / `# Act` / `# Assert` markers; the TypeScript suite uses the same comment structure |
| Descriptive names and docstrings | PASS | every new Python test has a one-line docstring; every TypeScript `it(...)` has a descriptive title |
| Determinism | PASS | no clock, RNG, sleep, or timer use in any new test |
| Boundary matrices via parametrize | PASS | `@pytest.mark.parametrize` at `test_parallel_kickoff_template_seam.py:311-318`; `it.each` at the TypeScript twin `:254-258` |

The two seam modules read committed repository files from disk. This is filesystem access but not
a temporary file, and each module documents its precedent in its own header. Reading a committed
runtime surface is required by the nature of a producer/consumer seam test: a fixture copy would
reintroduce exactly the drift the seam exists to prevent.

**Verdict: PASS.**

## Suppression Policy

No `# noqa`, no `# type: ignore`, no `// eslint-disable`, no `// @ts-expect-error`, no
`// @ts-ignore`, and no `// @ts-nocheck` appears in any file added or modified by this branch.
Ruff, Pyright, ESLint, and tsc all pass with zero findings and zero suppressions.

**Verdict: PASS (Python and TypeScript).**

## Commenting and Docstring Policy

`.claude/rules/self-explanatory-code-commenting.md` scopes its mandatory requirements to Python.

- Every class in `parallel_kickoff_contract.py` (`KickoffItem`, `ParsedParallelKickoff`) carries a
  full docstring with Purpose, Responsibilities, Usage, Key invariants, and Attributes.
- Every function and private helper in both Python modules carries a Google-style docstring with
  Args, Returns, Raises, and Side Effects.
- Loop-intent comments precede every `for` loop (`parallel_kickoff_contract.py:202-204`, `:253-256`;
  `_parallel_kickoff_tables.py:118-119`, `:132-133`, `:190-192`, `:239-241`).
- Branching carries decision-logic comments (`parallel_kickoff_contract.py:208-209`, `:315-318`,
  `:339-340`; `_parallel_kickoff_tables.py:173-174`).
- No numbered notes (`NOTE 1:` style) appear anywhere in the new code.
- The B1 decision-logic comment at `parallel_kickoff_contract.py:68-77` explains why the
  alternation is deliberately wider than any single producer's phrasing, which is exactly the kind
  of rationale the rule requires.

**Verdict: PASS.**

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — EXIT_CODE 0.
- Diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or
  `artifacts/coverage/`: **none**.
- All 47 evidence artifacts live under
  `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/<kind>/`, using the kinds
  `baseline`, `remediation-baseline`, `qa-gates`, `test-runs`, and `other`.
- All evidence filenames carry a `yyyy-MM-ddTHH-mm` component (the single N2 exception was
  corrected).

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entry is required: no delegation prompt supplied a
non-canonical evidence path.

**Verdict: PASS.**

## Tonality Policy

A pattern scan for hyperbole, promotional language, and emoji across
`.claude/skills/parallel-plan/SKILL.md`, `.claude/agents/parallel-planner.md`, both Python
modules, the TypeScript module, `spec.md`, and `user-story.md` returned no matches. Spot reading
of the delivered surfaces and the evidence artifacts confirms measured, evidence-proportionate
wording throughout; the coverage-delta artifact in particular states its uncertainty explicitly
rather than overclaiming.

**Verdict: PASS.**

## Known Pre-Existing Local Noise (recorded, not raised)

`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` read the real gitignored
`artifacts/orchestration/orchestrator-state.json` rather than a mocked seam and fail whenever an
orchestrated run is in progress. They fail identically at baseline, were adjudicated out of scope
by two prior epic children, and are not edited by this feature. Recorded as pre-existing; not
raised against this feature.

Separately, an untracked coverage side-file `scripts/dev_tools/pr_context/render.py,cover` exists
in the working tree. It is not tracked, not in the branch diff, and not produced by this feature.
Pre-existing; not raised.

## Advisory Findings

### A-1 (carried forward, Advisory) — cross-runtime divergences outside the verified parity scope

**Location:** `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts:179`, `:186`,
`:215`, `:251`.

**Detail.** Two divergence classes were re-confirmed this cycle:

- Numeric cell parsing uses `Number()` where Python uses `int()`. `Number("")` is `0`,
  `Number("0x10")` is `16`, and `Number("1e3")` is `1000`, all of which pass `Number.isInteger`,
  whereas the corresponding `int()` calls raise and produce an error string. An empty or
  hex-formatted `issue_num` cell is therefore accepted by the TypeScript runtime and rejected by
  Python.
- Duplicate plan-path detection at `:251` uses `planHashes[planPath] !== undefined` against a
  plain object literal, so a plan path spelled `constructor` or `toString` resolves through the
  prototype chain and reports a spurious duplicate.

**Not a regression.** Both patterns are byte-for-byte the design of the landed
`extensions/drm-copilot/src/lib/validate/epic-kickoff-artifact.ts` (`Number(row[0])` at `:149`,
`Number(row[2])` at `:156`, `Record<string, string> = {}` at `:186`, prototype lookup at `:240`).
This feature mirrors an accepted precedent rather than introducing a new divergence.

**Why still open.** The recommended remedy — a verified-parity-scope paragraph in
`.claude/rules/parallel-orchestration.md`, in the form F3 used for the state validators — is a
protected-surface edit and was correctly deferred. The `Object.create(null)` fix at `:215` is not
protected and remains available opportunistically, but changing it unilaterally would diverge
from the epic precedent, so deferral is defensible.

**Rule:** `.claude/rules/typescript.md` (parity expectation), `.claude/rules/parallel-orchestration.md`
(documented-divergence convention). **Classification: Advisory.**

### A-3 (carried forward, Advisory) — Integrity-template precedent

**Location:** `.claude/skills/epic-plan/SKILL.md` (protected; no `## Integrity` template present).

With B2 landed, `.claude/skills/parallel-plan/SKILL.md:379-385` is now the repository's only
worked `## Integrity` template bound to a validator by test. Propagating it to the epic surface
would prevent the same defect class there. The epic skill is a protected surface for this feature,
so the work belongs to a separate authorization. **Classification: Advisory.**

### A-4 (new, Advisory) — defensive-fallback branches uncovered in the TypeScript port

**Location:** `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts`, arcs at
lines 136, 137, 193, 201, 204, 205, 217, 222, 232, 245, 250, 256, 307.

All 13 uncovered branch arcs are `?? ""` / `?? []` fallbacks required by TypeScript's
unchecked-index strictness and made unreachable by the preceding length guards. Branch coverage is
88.79%, comfortably above the 75% floor, and line coverage is 100%. No action required; recorded
so the gap is not mistaken for untested logic. **Classification: Advisory.**

### A-5 (new, Advisory) — flaky coverage arc in an unchanged module

**Location:** `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py:362-403`, arc `[395, 362]`.

The subprocess output-streaming loop's coverage is timing-dependent, which makes repo-wide Python
branch coverage vary by one arc in 5000 between identical runs. This produces spurious ±0.02 pp
coverage deltas in every feature that measures repo-wide coverage. A repo-level follow-up —
injecting a clock seam or a fake `TimeProvider` into the loop, per the determinism-infrastructure
requirement in `.claude/rules/general-unit-test.md` — would remove the noise. Outside this
feature's scope. **Classification: Advisory.**

### A-6 (new, Advisory) — minor line-wrap inconsistency in the N3 correction

**Location:** `docs/features/active/2026-08-07-parallel-planner-surface-443/user-story.md:135`.

The corrected line is 104 characters where surrounding prose in the same section wraps near 98.
The repository defines no enforced Markdown line-length rule and the file already contains lines
of 118 and 102 characters, so this is not a policy violation. Recorded for tidiness only.
**Classification: Advisory.**

## Overall Policy Verdict

**PASS.** Zero Blocking findings. Zero Non-blocking findings. Five open Advisory findings, none
of which requires action in this cycle. All four cycle-entry Blocking findings and all three
Non-blocking findings are verified resolved by independent reproduction rather than by accepting
the executor's report.
