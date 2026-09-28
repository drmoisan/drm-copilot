# Policy Audit — parallel-schema-validators (Issue #444) — Reaudit, remediation cycle 1 exit gate

- **Component:** `parallel` orchestration schema and validators (epic child feature F3, wave 1)
- **Date:** 2026-08-07T21-13
- **Review type:** REAUDIT (remediation cycle 1 exit gate). Supersedes nothing; the cycle-0
  artifacts dated `2026-08-07T20-36` remain the entry record and were not modified.
- **Branch under review:** `feature/parallel-schema-validators-444`
- **Base branch:** `epic/parallel-orchestration-integration`
- **Merge base:** `ae6331f7693fb7c05e2c5c7f8416c46c469929fa`
- **Commits under review:** `3eb6b348` (feature) and `dac03eb3` (remediation cycle 1)
- **HEAD at review time:** `dac03eb3bf47b03befe23645d7c9ba24f5745ac6`
- **Full-feature diff command:** `git diff ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD`
- **Cycle-1 delta command:** `git diff 3eb6b348..dac03eb3`
- **Work mode:** `full-feature` (marker read from `issue.md` line 12: `- Work Mode: full-feature`)
- **Working tree state:** clean (`git status --short` produced no output)

## Executive Summary

This is a full reaudit of the whole feature branch against the resolved base branch, not a review
of the cycle-1 delta alone. Every scope-boundary verification from cycle 0 was re-executed rather
than carried forward on trust, and the cycle-1 delta was independently classified before its
contents were read.

**Verdict: PASS. Blocking findings: 0. Advisory findings: 6. Informational findings: 5.**

The cycle-1 delta is documentation-only, verified independently rather than accepted from the
executor's claim. `git diff --name-only 3eb6b348..dac03eb3` returns 32 paths; filtering that list
through `grep -vE '\.md$'` returns nothing, and an explicit extension scan for
`\.(py|ts|tsx|cjs|mjs|js|json|ps1|psm1|cs|ya?ml)$` returns nothing (grep exit 1). No executable
file changed in cycle 1.

The two rule-file copies are byte-identical. `cmp` exits 0, both files hash to
`6d1e82c572ea5fa2a5c86f1221becfa468dc3192394ab3adf0aec3abe60f2d8e`, and `git rev-parse` reports the
same blob `7063d2dabf0126bae3eb837e7ba0a6faa34e11ce` for both paths at HEAD.

The R1 rewrite retains the parity statement rather than deleting it, and each of its three named
divergence classes was independently reproduced by executing both runtimes against the same
documents. The two source line references it cites are exact: `pythonRepr` occupies precisely
`parallel-state-shared.ts:112-132`, and `parallel-state-structures.ts:228` is precisely the
`entry["generation"] === recolorGeneration` comparison. The corrected claim is accurate. One
Advisory records that its enumeration of divergence classes is incomplete — the invalid-JSON parser
detail text is a fourth class that cycle-0's own R7 finding named but that the cycle-1 remediation
inputs dropped when restating the scope.

The R2 plan edit added exactly one line and altered no task checkbox. Both revisions of the plan
carry 78 checked and 0 unchecked boxes, and the checkbox-line sets are identical.

The full toolchain was re-run independently and the green state held on both surfaces: Black, Ruff,
Pyright, Pytest (2835 passed), Prettier, ESLint, `tsc --noEmit`, and Jest with coverage (177 suites
/ 2363 tests). Repo-wide coverage is unchanged from cycle 0 to the second decimal on the Python
surface, which is the expected consequence of a documentation-only delta.

Every scope boundary supplied for verification holds. The MCP surface grows by exactly two
`artifact_type` values. `parallel_kickoff_contract.py` and the `parallel-kickoff` artifact type are
absent, which is correct for F3. The ready gate checks the kickoff path only. `mutations[]`,
`drift_events[]`, and `conflict_edges[]` are fully shaped. `depends_on`, `integration_branch`, and
`epic_merge_pr` are actively rejected at any nesting level, demonstrated by execution. Recoloring
recomputation is deliberately absent. No JSON Schema file was authored or imported. The epic
validators are byte-unchanged. All 32 acceptance criteria are checked off and independently
verified.

## Rejected Scope Narrowing

None. The caller directive scoped this reaudit to the full branch diff against the resolved base
branch and explicitly instructed re-verification across the whole feature rather than the cycle-1
delta alone. No instruction narrowed scope to a plan, task, or phase; no instruction limited the
review to a subset of changed files; no instruction marked any language's coverage as informational
or asked that a toolchain check be skipped.

Three items were designated out of scope by the caller and are recorded here rather than rejected,
because none of them narrows the audit of this branch's diff:

- The F1 blast-radius under-reporting gaps, recorded at
  `docs/features/potential/2026-08-07-blast-radius-under-reporting-gaps.md` and scheduled against
  F4 (#443). No file of that library is in this branch's diff.
- The repo-wide `pythonRepr` quote-selection defect, now recorded as its own potential entry at
  `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`. Fixing it would
  require modifying epic validators, which this branch is required not to touch.
- Spec-internal contradictions between S2 and the V-O invariant list, and between S5 and invariant
  17. These are spec-review items; the code correctly follows the numbered invariants in both
  cases. Both remain recorded as Advisory in the code review for continuity.

Each of these is a defect located outside this branch's diff or a document-consistency item for a
later review gate. Excluding them removes no changed file, no language, and no coverage obligation
from this audit.

## Evidence Location Compliance

Zero violations.

- `git diff --name-only ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"` returns nothing (grep exit 1). No file in the branch diff is written under a non-canonical evidence path.
- `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` exits 0 with no output.
- All 30 evidence files added by this branch sit under
  `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/<kind>/`, using the
  canonical kinds `baseline/`, `remediation-baseline/`, `qa-gates/`, and `other/`.
- No delegation prompt supplied a non-canonical evidence path, so no
  `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record is required for this cycle.

## 1. General Unit Test Policy Compliance

Reference: `.claude/rules/general-unit-test.md`.

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Independence | PASS | Every Python test constructs its document from a builder that returns a freshly built dict; every Jest test does the same through `parallel-state-test-support.ts`. No module-level mutable fixture is shared. Both suites pass under their default collection order. |
| Isolation | PASS | Each test applies exactly one mutation to a valid document and asserts on the resulting error list, so a failure names the invariant. |
| Fast execution | PASS | Python `2835 passed in 4.73s`; Jest `Time: 7.575 s` for 177 suites. |
| Determinism | PASS | No clock, RNG, timer, or network access anywhere in the new code or tests. Both suites were run twice during this reaudit with identical results. |
| Readability | PASS | Every test carries a docstring or an `it(...)` description naming the scenario and expected outcome. |
| Test file location | PASS | Python tests under `tests/scripts/dev_tools/` mirroring `scripts/dev_tools/`; TypeScript tests under `extensions/drm-copilot/test/lib/validate/` mirroring `src/lib/validate/`. No test file was placed in a production source tree. |
| No temporary files | PASS | Documents are built as dictionaries and serialized with `json.dumps` / template literals. `grep -rn "tmp_path\|tempfile\|mkdtemp\|os.tmpdir"` over the fifteen new test files returns no match. |
| Scenario completeness | PASS | Each invariant carries a valid case, one malformed case per rejection branch, and an absent-optional-key backward-compatibility case. Detail in section 5. |

### 1.1 Coverage Exclusion Policy

`.claude/rules/general-unit-test.md` makes any `exclude` entry matching a production source path a
Blocking finding. Re-verified at HEAD.

- TypeScript: `extensions/drm-copilot/jest.config.cjs:17` reads
  `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`. The single negation targets TypeScript
  declaration files, which carry no executable behavior and are explicitly permitted.
  `grep -n "coveragePathIgnorePatterns" extensions/drm-copilot/jest.config.cjs` returns no match.
  The branch's edit to this file is additive only: it appends five per-file `coverageThreshold`
  entries, all at `lines: 85, branches: 75`, and introduces no exclusion of any kind. The five
  entries cover every new production module, including `parallel-state-records.ts`.
- Python: `pyproject.toml` `[tool.coverage.run] omit` lists `tests/*`, `*/tests/*`,
  `*/__pycache__/*`, and `*/site-packages/*`. No production path appears. `pyproject.toml` is
  byte-unchanged on this branch; it does not appear in `git diff --name-only`.

**Verdict: PASS.** Zero prohibited exclusion entries across both languages.

### 1.2 Coverage Evidence

Coverage was verified by inspecting the artifacts produced during execution. The reviewer
additionally re-ran both suites during this reaudit to confirm the artifacts are current at HEAD
`dac03eb3` rather than stale at `3eb6b348`.

- TypeScript baseline coverage artifact: recorded at
  `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-test-coverage-baseline.2026-08-07T18-08.md`
  with line 96.34% and branch 89.27%.
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info`, regenerated
  by the reviewer at HEAD with `npm run test:coverage`; line 96.49% and branch 89.75%.
- PowerShell baseline coverage artifact: N/A — no PowerShell files in the branch diff. The diff
  contains zero `.ps1`, `.psm1`, and `.psd1` files, so no PowerShell coverage obligation attaches.
- PowerShell post-change coverage artifact: N/A — no PowerShell files in the branch diff, so there
  is no post-change PowerShell figure to record.
- Per-language comparison summary: recorded in section 1.2.1 below, with one bullet for each
  language whose changed-file count on this branch is above zero.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 91.32% line / 82.54% branch. Post-change: 91.71% line / 83.58% branch. Change: +0.39 pp line and +1.04 pp branch, an improvement on both axes. New/changed-code coverage: 100.0% on six of the seven new production modules and 97% on the seventh, with all 38 lines added to `validate_orchestration_artifacts.py` covered. Both figures clear the 85% line and 75% branch thresholds. The post-change figures are identical to the cycle-0 figures to two decimal places, which independently corroborates that the cycle-1 delta changed no executable code. Disposition: PASS. Evidence: `artifacts/python/lcov.info` regenerated at HEAD and parsed by the reviewer, yielding lines 12247/13354 and branches 4122/4932.
- TypeScript: Baseline: 96.34% line / 89.27% branch. Post-change: 96.49% line / 89.75% branch. Change: +0.15 pp line and +0.48 pp branch, an improvement on both axes. New/changed-code coverage: 96.91% to 100.0% line across the five new modules, and 100.0% line on both pre-existing definition surfaces. Every new module clears the 85% line and 75% branch thresholds, enforced automatically by the five per-file `coverageThreshold` entries added in `jest.config.cjs`, which the passing run confirms. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` regenerated at HEAD by the reviewer with `npm run test:coverage` and parsed per file.

Per-file figures for every module the branch created or changed appear in section 5.

## 2. General Code Change Policy Compliance

Reference: `.claude/rules/general-code-change.md`.

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Simplicity first | PASS | Validators are flat pure functions returning `list[str]` / `string[]`. No class hierarchy; indirection is one helper call per invariant group. |
| Reusability | PASS | `_parallel_state_common.py` holds the nine S4 enums, the blast-radius validator, the item-record validator, and the prohibited-key scanner. The manifest, planner, and orchestrator surfaces all call the same implementation instead of restating it. |
| Extensibility | PASS | Both entry points use keyword-only opt-in flags defaulting to `False` (`require_complete`, `require_ready_for_execution`), so existing callers are byte-unaffected. `validate_item_record(..., require_kind=...)` parameterizes the one surface difference instead of forking the function. |
| Separation of concerns | PASS | All seven Python modules and all five TypeScript modules are pure. `grep -n "open(\|Path(\|subprocess\|read_text\|readFile\|fs\."` over the planner validator and its TypeScript core returns no match (grep exit 1). The only I/O in the dispatch path is the pre-existing `_read_text`. |
| Mandatory toolchain loop | PASS with one pre-existing gap | Stages 1, 2, 3, and 5 executed clean on both surfaces in a single pass (section 7). Stage 4 has no configured tool in this repository; `.dependency-cruiser.cjs` is absent at both the repo root and under `extensions/drm-copilot/`. That is a pre-existing repository condition, not a defect of this branch, recorded as Informational I1. Stage 6 is satisfied by the definitions-alignment test asserting both MCP surfaces advertise the same enum. Stage 7 is covered by the in-memory MCP round-trip test. |
| File size limit (500 lines) | PASS | Every non-Markdown file in the diff was measured with `wc -l`. The maximum is 499 (`tests/scripts/dev_tools/test_validate_parallel_planner_state.py`). Full table in section 9. |
| Error handling, fail fast | PASS | Each validator returns one error per violated condition rather than raising. A non-object root and unparseable text each short-circuit to a single-element list, which is the documented contract. `json.JSONDecodeError` is the only exception caught, and it is caught narrowly. |
| Naming | PASS | `snake_case` Python functions, `CONSTANT_CASE` module constants, `camelCase` TypeScript functions, `PascalCase` TypeScript interfaces, kebab-case TypeScript filenames. |
| Public API compatibility | PASS | Every change to a pre-existing file is purely additive. The `config/orchestration-routing.json` diff is a single hunk of added lines; no pre-existing route entry is altered. The `jest.config.cjs` diff appends five threshold entries and removes nothing. |
| Dependencies | PASS | Neither `pyproject.toml` nor `extensions/drm-copilot/package.json` appears in the diff. No runtime dependency was added. |
| I/O boundaries | PASS | No new I/O is introduced anywhere in the diff. |
| Documentation-only delta discipline (cycle 1) | PASS | The cycle-1 delta touches only Markdown. The rewritten rule text is prose in a `.claude/rules/` file whose byte-identical extension mirror was updated in the same commit, preserving the mirror invariant. |

## 3. Language-Specific Code Change Policy Compliance

### 3.1 Python — `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Black formatting | PASS | `poetry run black --check .` — `360 files would be left unchanged.` Exit 0. |
| Ruff lint | PASS | `poetry run ruff check .` — `All checks passed!` Exit 0. |
| Pyright type check | PASS | `poetry run pyright` — `0 errors, 0 warnings, 0 informations`. Exit 0. |
| Full type annotation | PASS | Every public and private function in the seven new modules carries complete parameter and return annotations. `object` plus `cast` is used at the deserialization boundary; `Any` appears nowhere. |
| Suppression policy | PASS | `grep -rn "noqa\|type: ignore"` over the seven new Python modules returns no match (grep exit 1). Zero suppressions to authorize. |
| Absolute imports | PASS | All imports use the `from scripts.dev_tools... import ...` form. |
| No print / logging misuse | PASS | Validators are pure; the pre-existing dispatcher owns all stderr output. |
| Docstring and comment policy | PASS | Every module, function, and private helper carries a Google-style docstring. Every loop and non-trivial branch carries an intent comment. |

### 3.2 TypeScript — `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Prettier formatting | PASS | `npm run format` — every file reported `(unchanged)`. Exit 0. |
| ESLint | PASS | `npm run lint` — no diagnostics emitted. Exit 0. |
| `tsc --noEmit` | PASS | `npm run typecheck` — no diagnostics emitted. Exit 0. |
| No `any` | PASS | `grep -rn ": any\| as any"` over the five new modules returns no match (grep exit 1). `unknown` plus narrowing is used throughout, with `isObject` as the single type guard. |
| Suppression policy | PASS | `grep -rn "eslint-disable\|@ts-expect-error\|@ts-ignore\|@ts-nocheck"` over the five new modules returns no match (grep exit 1). |
| ES modules | PASS | All five modules use `import` / `export`. |
| Kebab-case filenames | PASS | `parallel-state-shared.ts`, `parallel-state-structures.ts`, `parallel-state-records.ts`, `parallel-orchestrator-state-core.ts`, `parallel-planner-state-core.ts`. |
| Architecture boundaries | PASS by inspection | The new modules import only from each other. No Office.js, Graph SDK, VSTO, COM, or Outlook reference appears. The automated `dependency-cruiser` stage cannot run because the repository has no `.dependency-cruiser.cjs`; recorded as Informational I1. |

### 3.3 PowerShell and C#

N/A. The branch diff contains zero `.ps1`, `.psm1`, and `.psd1` files, and zero `.cs` and `.csproj`
files. `git diff --name-only ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD | grep -E '\.(ps1|psm1|psd1|cs|csproj)$'` returns nothing (grep exit 1). No coverage obligation attaches to
either language on this branch.

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Pytest as runner, `test_...` names | PASS | All six new Python test files use plain `def test_*` functions under `tests/scripts/dev_tools/`. |
| `pytest.mark.parametrize` for boundary matrices | PASS | Used for every enum-membership matrix, for example `@pytest.mark.parametrize("state_value", VALID_ITEM_STATES)` in `test_validate_parallel_orchestrator_state.py`. |
| One behavior per test, AAA structure | PASS | Each test builds a valid document, applies one mutation, and asserts on the resulting error list. |
| Patch at the import location used by the unit | PASS | The dispatch test monkeypatches `_read_text` on `scripts.dev_tools.validate_orchestration_artifacts`, which is where the unit under test resolves it. |
| Jest as framework, `*.test.ts` naming | PASS | All eight new Jest suites end in `.test.ts`. The shared builder lives in the non-suite support module `parallel-state-test-support.ts`, which Jest does not collect. |
| `it.each` for matrices | PASS | Used for the required-key matrix and for both new artifact types on both MCP definition surfaces. |
| No snapshot tests | PASS | `Snapshots: 0 total` in the Jest run. |
| Determinism infrastructure | PASS | No fake-timer facility is needed: no new code path reads a clock, and no async scheduling is introduced. |
| Runtime-sensitive assertions scoped correctly | PASS | The invalid-JSON assertions deliberately match the message prefix only (`startswith` in Python, `toMatch(/^.../)` in Jest), because the parser's own detail text is runtime-specific. This is the correct treatment and is the basis of Advisory A6 below, which concerns rule-file documentation rather than test design. |
| Property-based tests | N/A with recorded exemption | `.claude/rules/quality-tiers.md` makes property-test density tier-dependent (T1/T2 only). `quality-tiers.yml` is absent at the repo root, so no tier attaches. The decision is recorded at `evidence/other/property-test-decision.2026-08-07T19-58.md`. Recorded as Informational I2. |

## 5. Test Coverage Detail

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
| ---------- | ---------- | ---------- | ---------- | ---------- | ---------- | ---------- |
| Python | 13 | 2835 | 2835 passed, 0 failed | 91.32% line / 82.54% branch | 91.71% line / 83.58% branch | 97.00%-100.00% line on the seven new modules; 100.00% on all 38 added lines |
| TypeScript | 19 | 2363 | 2363 passed, 0 failed | 96.34% line / 89.27% branch | 96.49% line / 89.75% branch | 96.91%-100.00% line on the five new modules; 100.00% on both changed definition surfaces |
| PowerShell | 0 | 0 | N/A — no PowerShell files in the branch diff | N/A — no PowerShell files in the branch diff | N/A — no PowerShell files in the branch diff | N/A — no PowerShell files in the branch diff |
| C# | 0 | 0 | N/A — no C# files in the branch diff | N/A — no C# files in the branch diff | N/A — no C# files in the branch diff | N/A — no C# files in the branch diff |

Per-file figures parsed by the reviewer from `artifacts/python/lcov.info` and
`extensions/drm-copilot/coverage/lcov.info`, both regenerated at HEAD `dac03eb3`:

| Module | Line | Branch | Threshold check |
| --- | --- | --- | --- |
| `scripts/dev_tools/_parallel_state_common.py` | 122/122 = 100.00% | 62/62 = 100.00% | PASS |
| `scripts/dev_tools/_parallel_state_records.py` | 88/88 = 100.00% | 50/50 = 100.00% | PASS |
| `scripts/dev_tools/_parallel_state_structures.py` | 149/149 = 100.00% | 86/86 = 100.00% | PASS |
| `scripts/dev_tools/parallel_manifest_contract.py` | 65/65 = 100.00% | 22/22 = 100.00% | PASS |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 80/82 = 97.56% | 32/34 = 94.12% | PASS |
| `scripts/dev_tools/validate_parallel_planner_state.py` | 112/112 = 100.00% | 46/46 = 100.00% | PASS |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | all 38 added lines covered | all added branches covered | PASS |
| `src/lib/validate/parallel-state-shared.ts` | 471/486 = 96.91% | 97/101 = 96.04% | PASS |
| `src/lib/validate/parallel-state-structures.ts` | 496/496 = 100.00% | 110/112 = 98.21% | PASS |
| `src/lib/validate/parallel-state-records.ts` | 347/347 = 100.00% | 66/66 = 100.00% | PASS |
| `src/lib/validate/parallel-orchestrator-state-core.ts` | 318/320 = 99.38% | 35/38 = 92.11% | PASS |
| `src/lib/validate/parallel-planner-state-core.ts` | 453/453 = 100.00% | 48/49 = 97.96% | PASS |
| `src/lib/validate/orchestration-artifacts.ts` | 281/281 = 100.00% | 65/66 = 98.48% | PASS |
| `src/mcp-tool-inputs.ts` | 453/479 = 94.57% | 64/69 = 92.75% | PASS |
| `src/mcp-tool-definitions.ts` | 453/453 = 100.00% | no branches; 100.00% by convention | PASS |
| `src/mcp-repo-automation-tool-definitions.ts` | 404/404 = 100.00% | no branches; 100.00% by convention | PASS |

Every module the branch created or changed clears both the 85% line and the 75% branch threshold.
No coverage artifact is absent for any language that has changed files in the branch diff.

## 6. Test Execution Metrics

| Surface | Command | Result |
| --- | --- | --- |
| Python format | `poetry run black --check .` | `360 files would be left unchanged.` Exit 0. |
| Python lint | `poetry run ruff check .` | `All checks passed!` Exit 0. |
| Python type check | `poetry run pyright` | `0 errors, 0 warnings, 0 informations`. Exit 0. |
| Python unit tests | `poetry run pytest -q` | `2835 passed in 4.73s`. Exit 0. |
| Python coverage | `poetry run pytest -q --cov=scripts --cov-branch --cov-report=term` | `2835 passed in 11.36s`; lcov written to `artifacts/python/lcov.info`. |
| Targeted regression | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | `7 passed in 0.10s`. Exit 0. |
| Routing parity | `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py -q` | `1 passed in 0.05s`. Exit 0. |
| TypeScript format | `npm run format` | Every file reported `(unchanged)`. Exit 0. |
| TypeScript lint | `npm run lint` | No diagnostics. Exit 0. |
| TypeScript type check | `npm run typecheck` | No diagnostics. Exit 0. |
| TypeScript tests + coverage | `npm run test:coverage` | `Test Suites: 177 passed, 177 total`; `Tests: 2363 passed, 2363 total`; `Snapshots: 0 total`; `Time: 7.575 s`. Exit 0. |

Both expected counts from the caller directive were met exactly: Python 2835 passed, TypeScript 177
suites / 2363 tests.

## 7. Code Quality Checks

All seven toolchain stages were re-run in order during this reaudit, and no stage auto-fixed a file,
so no restart of the loop was required. Stages 1, 2, 3, and 5 completed clean in a single pass on
both language surfaces. Stage 4 has no configured tool in this repository (Informational I1). Stage
6 is satisfied by the MCP definitions-alignment test. Stage 7 is satisfied by the in-memory MCP
round-trip test in `mcp-server-parallel-validation.test.ts`.

### 7.1 `modified-workflow-needs-green-run`

**Not applicable, and correctly so.** The rule fires only when the diff touches
`.github/workflows/**` or `scripts/benchmarks/**`.
`git diff --name-only ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD | grep -E "^\.github/workflows/|^scripts/benchmarks/"`
returns nothing (grep exit 1). No workflow file and no benchmark script is in the diff, so no green
workflow run against the branch head is required for this branch. The related rules
`.claude/rules/ci-workflows.md` and `.claude/rules/benchmark-baselines.md` likewise have no
applicable surface here: no `pwsh` workflow step was added or modified, and no benchmark baseline
JSON was committed.

### 7.2 Scope-Boundary Verification

Every boundary was re-executed at HEAD `dac03eb3` rather than carried forward from cycle 0.

| # | Boundary | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | MCP surface grows by exactly `parallel-orchestrator-state` and `parallel-planner-state` | PASS | The diff of `mcp-tool-definitions.ts`, `mcp-repo-automation-tool-definitions.ts`, and `mcp-tool-inputs.ts` adds exactly two enum members per surface and two entries to `VALID_ARTIFACT_TYPES`. The only other changed lines are two flag-description strings that name the new types. No third artifact type is added anywhere. |
| 2 | No `parallel-kickoff` artifact_type | PASS | `ls scripts/dev_tools/parallel_kickoff_contract.py` reports no such file. The literal `parallel-kickoff` appears in exactly three roles: the P9 path template at `parallel-planner-state-core.ts:147` and its Python counterpart, negative tests asserting `Unsupported artifact type: parallel-kickoff`, and rejection tests on the MCP input surface. It is registered nowhere. Absence is correct: the kickoff contract is F4's scope. |
| 3 | `require_ready_for_execution` is structural only | PASS | `grep -n "open(\|Path(\|subprocess\|read_text\|os\.\|readFile\|fs\."` over `validate_parallel_planner_state.py` and `parallel-planner-state-core.ts` returns no match (grep exit 1). The kickoff-PATH invariant is enforced at line 396 by string comparison against `KICKOFF_PATH_TEMPLATE.format(slug=...)`. No file is read, no repository command is issued, and no kickoff CONTENT is parsed anywhere. |
| 4 | `mutations[]` fully shaped per S5 | PASS | Verified by execution. Out-of-enum `op`, a non-null `item_key` on a `close`, an in-flight removal with no disposition, and a stray disposition on an `add` each produce exactly the specified single error. |
| 5 | `drift_events[]` fully shaped per S6 | PASS | Verified by execution. An empty `escaped_paths` yields `drift_events[0] escaped_paths must be a non-empty list of non-empty strings.`; an out-of-enum action yields the A8 two-member enum error. |
| 6 | `conflict_edges[]` fully shaped per S7 | PASS | Verified by execution. A self-edge, an unnormalized pair, a duplicate pair, and an out-of-enum reason each produce exactly the specified single error. |
| 7 | `depends_on`, `integration_branch`, `epic_merge_pr` actively rejected at any nesting level | PASS | Verified by execution on both surfaces. Top-level and `items[0]`-nested placements of `depends_on` and `epic_merge_pr` each yield `carries prohibited key '<key>' at <root>.` and `... at items[0].` respectively. The planner surface rejects a nested `depends_on` identically. Rejection is explicit, not mere absence. |
| 8 | Recoloring recomputation (spec P5) deliberately absent | PASS | `grep -n "recompute\|compute_cohort"` over the planner validator and the structures helper returns only prose comments recording the deliberate omission, at `validate_parallel_planner_state.py:20` and `:254` and `_parallel_state_structures.py:13`. No recomputation call exists. Absence is correct: it is F4's scope. |
| 9 | No JSON Schema file authored or imported; disqualified foreign schema not copied | PASS | `git diff --name-only` filtered for `schema.*\.json` or `\.schema` returns nothing (grep exit 1). A `grep -rn` alternation over the four tokens `jsonschema`, `json_schema`, `$schema`, and `ajv` across all twelve new validator modules returns no match (grep exit 1). The string `mix-calculator` appears exactly once in the branch, at `.claude/rules/parallel-orchestration.md:9`, inside the prohibition prose that restates the ban. That is a citation of the disqualified artifact, not a copy of it. |
| 10 | Epic validators unmodified | PASS | `git diff --name-only ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD | grep -Ei "epic"` returns exactly one path, and it is the evidence Markdown file `evidence/qa-gates/epic-unchanged.2026-08-07T19-58.md`. No file matching `validate_epic_*`, `_epic_*`, `src/lib/validate/epic-*`, or their tests appears in the diff. |
| 11 | Coverage-exclusion policy | PASS | Section 1.1. Zero `exclude` entries matching a production source path on either surface. |
| 12 | All 32 AC items checked off and genuinely satisfied | PASS | 19 checked boxes under `## Acceptance Criteria` in `spec.md` and 13 in `user-story.md`, zero unchecked in either section. Each was independently re-verified; detail in `feature-audit.2026-08-07T21-13.md`. |
| 13 | No file created or modified by this feature exceeds 500 lines | PASS | Maximum is 499. `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` is 508 lines but is PRE-EXISTING and absent from the branch diff, so it is not attributable to this feature; it is recorded as Informational I5 for continuity only. |
| 14 | Cycle-1 delta is documentation-only | PASS | Filtering the 32 changed paths for any non-`.md` extension returns nothing. An explicit scan for `.py`, `.ts`, `.cjs`, and `.json` returns nothing (grep exit 1). |
| 15 | Rule-file mirror parity holds after the cycle-1 rewrite | PASS | `cmp` exits 0; both copies hash to `6d1e82c572ea5fa2a5c86f1221becfa468dc3192394ab3adf0aec3abe60f2d8e`; `git rev-parse` reports blob `7063d2dabf0126bae3eb837e7ba0a6faa34e11ce` for both paths. |
| 16 | R2 plan edit altered no task checkbox | PASS | Both revisions carry 78 `- [x]` and 0 `- [ ]`. The file diff is `+1` line, and that line is a prose bullet under `## Open Questions / Notes`, not a checkbox. |
| 17 | Routing-config mirror parity | PASS | `cmp config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json` exits 0, and `test_orchestration_routing_config_parity.py` passes. |

## 8. Gaps and Exceptions

Six Advisory and five Informational findings. Zero Blocking. Full detail with recommendations sits
in `code-review.2026-08-07T21-13.md`; this section records the policy disposition.

| ID | Severity | Location | Summary | Disposition |
| --- | --- | --- | --- | --- |
| A1 | Advisory | `.claude/rules/parallel-orchestration.md`, Enforcement section, TypeScript parity bullet | The corrected parity text names three divergence classes. A fourth exists and is easier to reach than any of the three: the invalid-JSON parser detail message. Cycle-0's own R7 finding named it; the cycle-1 remediation inputs dropped it when restating the scope, and the delivered text inherited that omission. | Does not block. The delivered text is accurate in everything it asserts, and the sentence says three classes "are known" rather than claiming an exhaustive list. Add a fourth clause at the next touch of this file. |
| A2 | Advisory | `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts:112-132` | `pythonRepr` always single-quotes; CPython `repr` switches to double quotes when the value contains an apostrophe. | Carried forward from cycle 0 unchanged. Now correctly documented in the rule file and recorded repo-wide at `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`. Fixing it here would desynchronize the parallel port from the epic surface it mirrors. |
| A3 | Advisory | `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts`, `isIntegral` | `JSON.parse` cannot distinguish `10.0` from `10`, so integral floats are rejected by Python and accepted by TypeScript. | Carried forward. Not correctable within the JavaScript runtime. Now documented in the rule file, which was the cycle-0 recommendation and is satisfied by R1. |
| A4 | Advisory | `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts:228` | `===` does not reproduce Python's `True == 1` selection, so a boolean `generation` yields differing error counts. | Carried forward. Now documented in the rule file, which was the cycle-0 recommendation and is satisfied by R1. |
| A5 | Advisory | `scripts/dev_tools/validate_parallel_orchestrator_state.py`, `_validate_identity` | Spec table S2 marks three identity fields non-empty, but no V-O invariant enforces the non-empty part; the planner surface does enforce it under P2. | Carried forward. The implementation matches the numbered invariant list exactly, so the acceptance criterion is met. Resolve at spec review. |
| A6 | Advisory | `docs/features/active/.../spec.md`, S5 table versus invariant 17 | The S5 `disposition` row is looser than invariant 17. The implementation follows invariant 17 and says so. | Carried forward; caller-designated spec-review item. Recorded for continuity, not raised as a new defect. |
| I1 | Informational | repo root and `extensions/drm-copilot/` | `.dependency-cruiser.cjs` is absent, so toolchain stage 4 has no configured tool. | Pre-existing repository gap. Boundary compliance confirmed by inspection. |
| I2 | Informational | repo root | `quality-tiers.yml` is absent, so no tier attaches and the tier-dependent property-test gate does not fire. | Pre-existing; recorded at `docs/features/potential/promoted/2026-07-09-quality-tiers-yml-missing-at-repo-root.md`. |
| I3 | Informational | worktree environment | `poetry run pyright` prints `venv .venv subdirectory not found in venv path <worktree>` before reporting zero diagnostics. | The type check ran and was clean. The notice reflects the venv living at the main checkout. |
| I4 | Informational | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py` | The dispatch test imports builders from three sibling test modules. | Planned in the spec and matching the existing epic dispatch tests. Independence and isolation both hold. |
| I5 | Informational | `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` | The file is 508 lines. | PRE-EXISTING and absent from the branch diff. Not attributable to this feature. The branch added a separate dispatch test file specifically to avoid growing it, which is the correct response. |

## 9. Summary of Changes

The full-feature diff spans 93 files, +12737 / -114 lines, across two commits. The cycle-1 commit
contributes 32 files and +1201 / -2 lines, all Markdown.

Line counts for every non-Markdown file created or modified by this feature:

| Lines | File |
| --- | --- |
| 499 | `tests/scripts/dev_tools/test_validate_parallel_planner_state.py` |
| 497 | `tests/scripts/dev_tools/test_parallel_manifest_contract.py` |
| 496 | `scripts/dev_tools/_parallel_state_structures.py` |
| 496 | `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts` |
| 495 | `scripts/dev_tools/_parallel_state_common.py` |
| 494 | `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-structures.test.ts` |
| 486 | `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py` |
| 486 | `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts` |
| 479 | `extensions/drm-copilot/src/mcp-tool-inputs.ts` |
| 469 | `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_completion.py` |
| 453 | `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts` |
| 453 | `extensions/drm-copilot/src/mcp-tool-definitions.ts` |
| 449 | `scripts/dev_tools/validate_parallel_planner_state.py` |
| 430 | `extensions/drm-copilot/test/lib/validate/parallel-planner-state-core.test.ts` |
| 417 | `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts` |
| 404 | `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` |
| 394 | `scripts/dev_tools/validate_orchestration_artifacts.py` |
| 359 | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py` |
| 348 | `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_structures.py` |
| 347 | `extensions/drm-copilot/src/lib/validate/parallel-state-records.ts` |
| 336 | `scripts/dev_tools/validate_parallel_orchestrator_state.py` |
| 324 | `scripts/dev_tools/_parallel_state_records.py` |
| 320 | `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` |
| 312 | `scripts/dev_tools/parallel_manifest_contract.py` |
| 281 | `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` |
| 188 | `extensions/drm-copilot/jest.config.cjs` |
| 179 | `extensions/drm-copilot/test/mcp-server-parallel-validation.test.ts` |
| 158 | `extensions/drm-copilot/test/lib/validate/parallel-state-test-support.ts` |
| 144 | `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts` |
| 138 | `extensions/drm-copilot/test/mcp-tool-inputs-parallel-validation.test.ts` |
| 126 | `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-completion.test.ts` |
| 113 | `extensions/drm-copilot/test/mcp-parallel-validation-definitions.test.ts` |

Maximum is 499. The 500-line limit holds for every file this feature created or modified.

Cycle-1 documentation changes:

| Change | File | Effect |
| --- | --- | --- |
| R1 | `.claude/rules/parallel-orchestration.md` | The TypeScript parity bullet in the Enforcement section is rewritten in place. The parity statement is retained and qualified with the verified scope and three named divergence classes. Net `+1 / -1` line. |
| R1 mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` | Identical rewrite; byte-identity with the source copy preserved. |
| R2 | `docs/features/active/.../plan.2026-08-07T11-11.md` | One prose bullet appended under `## Open Questions / Notes` recording the records-module split and its 500-line-cap cause. No checkbox altered. |
| New potential entry | `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md` | 67 lines recording the repo-wide `pythonRepr` defect for separate scheduling. |
| Cycle-0 audits and cycle-1 evidence | 28 Markdown files under the feature folder | Review record and remediation evidence, all under canonical `evidence/<kind>/` paths. |

## 10. Compliance Verdict

**PASS. Blocking findings: 0.**

The exit condition for remediation cycle 1 is met. The total count of FAIL verdicts and
blocking-PARTIAL findings across all three reaudit artifacts is zero.

The cycle-1 remediation delivered exactly its stated scope: R1 corrected and qualified the parity
claim in both copies of the rule file without deleting it, and R2 recorded the records-module split
in the approved plan without disturbing a single task checkbox. Both changes are documentation-only,
verified independently. The green toolchain state established at cycle 0 held under an independent
re-run, and coverage is unchanged on both surfaces to two decimal places, which is the expected
signature of a documentation-only delta.

Six Advisory and five Informational findings remain. Four of the six Advisories are carried forward
unchanged from cycle 0 and are either caller-designated out of scope, correctable only outside this
branch, or spec-review items. One Advisory (A5) is a spec-versus-invariant gap that the
implementation handles correctly. One Advisory (A1) is new to this cycle and concerns the
completeness of the corrected rule text, not its accuracy. None requires a further remediation
cycle, and no remediation-inputs artifact is produced.

The branch is ready for pull-request authoring against `epic/parallel-orchestration-integration`.

## Appendix A: Test Inventory

| Suite | Tests | Coverage focus |
| --- | --- | --- |
| `tests/.../test_validate_parallel_orchestrator_state.py` (486 lines) | invariants 1-11, 19 | Required keys, route identity, mode and concurrency enums, item uniqueness and shape, state and merge-status enums and their consistency rule, blast-radius shape, prohibited-key rejections, receipt arrays, invalid JSON, non-object root |
| `tests/.../test_validate_parallel_orchestrator_state_structures.py` (348 lines) | invariants 12-17 | Cohort shape and generation bound, current-generation uniqueness and coverage, current-cohort bound, conflict-edge shape and normalization, mutation table, in-flight-removal disposition |
| `tests/.../test_validate_parallel_orchestrator_state_completion.py` (469 lines) | invariants 18, 20, 21 | Drift-event shape, closed-mode completion gate, open-mode run-close record, gate-off byte-identity |
| `tests/.../test_validate_parallel_planner_state.py` (499 lines) | P1-P4, P6-P9 | Required keys, route-consistent identity, item shape, cohort and edge delegation, ready-gate cardinality, preparation, sentinel, kickoff path; P5 asserted as an absence |
| `tests/.../test_parallel_manifest_contract.py` (497 lines) | M1-M7 | Frontmatter extraction under LF, CRLF, and CR; slug; mode and concurrency defaults through the accessors; created-at; items; prohibited keys |
| `tests/.../test_validate_orchestration_artifacts_parallel_dispatch.py` (359 lines) | CLI dispatch | Both new subparsers, both flags, unknown-artifact-type rejection |
| `test/lib/validate/parallel-orchestrator-state-core.test.ts` (417 lines) | invariants 1-11, 14, 19 | Mirrors the Python orchestrator suite; asserts byte-identical literals |
| `test/lib/validate/parallel-orchestrator-state-structures.test.ts` (494 lines) | invariants 12-17 | Mirrors the Python structures suite |
| `test/lib/validate/parallel-orchestrator-state-completion.test.ts` (126 lines) | invariants 18, 20, 21 | Mirrors the Python completion suite |
| `test/lib/validate/parallel-planner-state-core.test.ts` (430 lines) | P1-P4, P6-P9 | Mirrors the Python planner suite |
| `test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts` (144 lines) | dispatch wiring | Both new artifact types route to the correct core; unknown type still fails |
| `test/mcp-parallel-validation-definitions.test.ts` (113 lines) | definition alignment | Both MCP definition surfaces advertise the same enum, including rejection of `parallel-kickoff` |
| `test/mcp-tool-inputs-parallel-validation.test.ts` (138 lines) | input validation | `VALID_ARTIFACT_TYPES` accepts both new types and rejects unregistered ones |
| `test/mcp-server-parallel-validation.test.ts` (179 lines) | in-memory round trip | End-to-end MCP call for both new artifact types |
| `test/lib/validate/parallel-state-test-support.ts` (158 lines) | shared builder | Non-suite support module; not collected by Jest |

## Appendix B: Toolchain Commands Reference

```bash
# Scope resolution
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
git log --oneline ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD
git diff --name-status ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD
git diff --stat ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD

# Cycle-1 documentation-only verification
git diff --name-only 3eb6b348..dac03eb3 | grep -v -E '\.md$'
git diff --name-only 3eb6b348..dac03eb3 | grep -E '\.(py|ts|tsx|cjs|mjs|js|json|ps1|psm1|cs|ya?ml)$'

# Rule-file mirror parity
cmp .claude/rules/parallel-orchestration.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
sha256sum .claude/rules/parallel-orchestration.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
git rev-parse HEAD:.claude/rules/parallel-orchestration.md \
  HEAD:extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md

# Plan checkbox integrity
git show 3eb6b348:docs/features/active/.../plan.2026-08-07T11-11.md > <scratchpad>/plan_before.md
grep -c -- "- \[x\]" <scratchpad>/plan_before.md   # 78
grep -c -- "- \[ \]" <scratchpad>/plan_before.md   # 0
grep -c -- "- \[x\]" docs/features/active/.../plan.2026-08-07T11-11.md   # 78
grep -c -- "- \[ \]" docs/features/active/.../plan.2026-08-07T11-11.md   # 0

# Python toolchain
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest -q
poetry run pytest -q --cov=scripts --cov-branch --cov-report=term
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py -q

# TypeScript toolchain (cwd: extensions/drm-copilot)
npm run format
npm run lint
npm run typecheck
npm run test:coverage

# Policy gates
poetry run python -m scripts.dev_tools.validate_evidence_locations --root .
git diff --name-only <merge-base>..HEAD | grep -E "^\.github/workflows/|^scripts/benchmarks/"

# Cross-runtime byte-parity harness (reviewer-built, scratchpad only)
./node_modules/.bin/esbuild src/lib/validate/parallel-orchestrator-state-core.ts \
  --bundle --platform=node --format=cjs --outfile=<scratchpad>/orch.cjs
./node_modules/.bin/esbuild src/lib/validate/parallel-planner-state-core.ts \
  --bundle --platform=node --format=cjs --outfile=<scratchpad>/plan.cjs
poetry run python <scratchpad>/build_corpus.py     # 74 corpus documents + 5 probe documents
node <scratchpad>/run_ts.cjs                       # element-wise diff of both result arrays
```
