# Policy Audit — parallel-schema-validators (Issue #444)

- **Component:** `parallel` orchestration schema and validators (epic child feature F3, wave 1)
- **Date:** 2026-08-07T20-36
- **Branch under review:** `feature/parallel-schema-validators-444`
- **Base branch:** `epic/parallel-orchestration-integration`
- **Merge base:** `ae6331f7693fb7c05e2c5c7f8416c46c469929fa`
- **Feature commit:** `3eb6b348`
- **Diff command:** `git diff ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD`
- **Work mode:** `full-feature` (marker read from `issue.md` line 12: `- Work Mode: full-feature`)
- **Artifact structure source:** the canonical section list defined in
  `.claude/skills/policy-audit-template-usage/SKILL.md`. This agent's tool allowlist does not
  include the MCP server, so the bundled asset could not be read directly; the section set,
  checklist labels, and coverage-table shape were taken from the authoritative validator
  `scripts/dev_tools/validate_policy_audit_artifact.py` and verified by running that validator
  against this file.

## Executive Summary

The branch adds the complete `parallel` orchestration manifest and checkpoint schemas, three
Python validators with two shared helper modules and one record module, a full-parity TypeScript
port across five modules, additive CLI and MCP `artifact_type` wiring, the `parallel` route entry
in both routing-config copies, and the prose rule file `.claude/rules/parallel-orchestration.md`.
The diff spans 64 files, +11538 / -114 lines, in a single commit.

**Verdict: PASS with advisory findings. Blocking findings: 0.**

Every mandatory gate that this repository can execute was run independently by the reviewer and
passed: Black, Ruff, Pyright, Pytest (2835 passed), Prettier, ESLint, `tsc --noEmit`, and Jest with
coverage (177 suites / 2363 tests). Aggregate coverage rose on both surfaces and every new module
clears line >= 85% and branch >= 75%. All 72 lines added to pre-existing source files are covered.

Byte-parity between the Python validators and the TypeScript port was verified by direct execution
rather than by reading: 43 constructed documents were passed through both implementations and
produced 96 error strings that matched exactly, in identical order, with zero mismatched cases.
Three narrow divergences were then found by deliberate probing (Python `repr` quote selection for
strings containing an apostrophe; integral floats, which `JSON.parse` cannot distinguish from
integers; and Python's `True == 1` equality). All three are recorded as Advisory in
`code-review.2026-08-07T20-36.md`. None changes a verdict for a well-formed document, one is
inherent to the JavaScript runtime and is already documented in the module header, and the
`pythonRepr` behavior is byte-identical to every pre-existing epic and codex TypeScript validator
in this repository.

Every scope boundary supplied for verification holds. The MCP surface grew by exactly two
`artifact_type` values. `scripts/dev_tools/parallel_kickoff_contract.py` and the `parallel-kickoff`
artifact type are absent, which is correct. The ready gate checks the kickoff PATH only. All of
`mutations[]`, `drift_events[]`, and `conflict_edges[]` are fully shaped. `depends_on`,
`integration_branch`, and `epic_merge_pr` are actively rejected at any nesting level, demonstrated
by execution. No JSON Schema file was authored or imported. The existing epic validators are
byte-unchanged.

## Rejected Scope Narrowing

None. The caller directive scoped the review to the full branch diff against the resolved base
branch and supplied no instruction to narrow scope, skip a language, or mark any language's
coverage as informational. Two items were designated out of scope by the caller and are recorded
here rather than rejected, because neither narrows the audit of this branch's diff:

- The absence of `quality-tiers.yml` at the repository root, documented at
  `docs/features/potential/promoted/2026-07-09-quality-tiers-yml-missing-at-repo-root.md`
  (file confirmed present). This is a repository-wide pre-existing condition and not a defect of
  this branch.
- Two spec-conformant under-reporting gaps in the F1 blast-radius library, documented at
  `docs/features/potential/2026-08-07-blast-radius-under-reporting-gaps.md` (file confirmed
  present) and scheduled against F4 (#443). No file of that library is in this branch's diff.

## Evidence Location Compliance

`git diff --name-only ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD` was filtered for
`^artifacts/(baselines|baseline|qa|qa-gates|evidence|coverage|regression-testing|post-change)/`.

- Filter result: no match (grep exit 1). Zero files written to a forbidden `artifacts/` evidence
  sub-path.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — `EXIT_CODE=0`,
  no output.
- All 21 evidence artifacts in the diff live under
  `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/{baseline,other,qa-gates}/`,
  which is the canonical `<FEATURE>/evidence/<kind>/` scheme.

**Verdict: PASS.**

## 1. General Unit Test Policy Compliance

Reference: `.claude/rules/general-unit-test.md`.

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Independence and isolation | PASS | Every new test builds its document in memory from a builder function and asserts on a returned list. No shared mutable module state. `poetry run pytest -q` and Jest both pass in default (non-alphabetical-dependent) order. |
| Fast execution | PASS | 370 new Python tests in 0.51 s; 302 new Jest tests across 8 suites in 1.477 s. |
| Determinism | PASS | No clock, RNG, network, or process dependency in any new test. `grep -rn "setTimeout\|Date.now()\|Math.random\|Thread.Sleep"` over the five behavioral Jest suites returned no match (grep exit 1). |
| Readability | PASS | Every test carries a docstring (Python) or a descriptive `it(...)` name (Jest); files are grouped by invariant number. |
| No temporary files | PASS | `grep -rn "tmp_path\|tempfile\|NamedTemporary\|mkdtemp\|os.tmpdir\|fs.writeFile"` over all six new Python test files returned no match (grep exit 1). The CLI dispatch test injects text through a monkeypatched `_read_text`. |
| No external services | PASS | The MCP round-trip test uses `InMemoryTransport.createLinkedPair()` with a mocked `RepoAutomationService`. |
| Test file location (no colocation) | PASS | All Python tests under `tests/scripts/dev_tools/`; all Jest tests under `extensions/drm-copilot/test/`. No `*.test.ts` and no `test_*.py` file was added under `src/` or `scripts/`. |
| Scenario completeness | PASS | Each invariant has a valid case, one malformed case per condition, and — where a key is optional — an absent-key case. See Appendix A. |
| Coverage exclusion policy | PASS | See section 1.1. |

### 1.1 Coverage Exclusion Policy

`.claude/rules/general-unit-test.md` makes any `exclude` entry matching a production source path a
Blocking finding.

- TypeScript: `extensions/drm-copilot/jest.config.cjs:17` reads
  `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`. The single negation targets declaration
  files, which are type-only and explicitly permitted. `grep -n "coveragePathIgnorePatterns"`
  returned no match. The branch's edit to this file adds only five per-file `coverageThreshold`
  entries (all `lines: 85, branches: 75`) and adds no exclusion.
- Python: `pyproject.toml:118-123` `[tool.coverage.run] omit` lists `tests/*`, `*/tests/*`,
  `*/__pycache__/*`, `*/site-packages/*`. No production path. `pyproject.toml` is byte-unchanged on
  this branch (`git diff --stat ... -- pyproject.toml` produced no output).

**Verdict: PASS.** Zero prohibited exclusion entries.

### 1.2 Coverage Evidence

Coverage was verified by inspecting the artifacts produced during execution, not by regenerating
them, except that the reviewer re-ran both suites to confirm the artifacts are current.

- TypeScript baseline coverage artifact: recorded at
  `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/ts-test-coverage-baseline.2026-08-07T18-08.md`
  with line 96.34% and branch 89.27%.
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info`,
  regenerated by the reviewer with `npm run test:coverage`; line 96.50%, branch 89.76%.
- PowerShell baseline coverage artifact: N/A — the branch diff contains zero `.ps1` or `.psm1`
  files, so no PowerShell coverage obligation attaches.
- PowerShell post-change coverage artifact: N/A — the branch diff contains zero PowerShell files.
- Per-language comparison summary: recorded in section 1.2.1 below, one bullet per language with a
  changed-file count above zero.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 91.32% line / 82.54% branch. Post-change: 91.71% line / 83.58% branch. Change: +0.39 pp line and +1.04 pp branch, an improvement on both axes. New/changed-code coverage: 100.0% — all 38 lines added to `validate_orchestration_artifacts.py` and every line of the six new modules are covered, with zero uncovered added lines. Disposition: PASS. Evidence: `artifacts/python/lcov.info` parsed by the reviewer, cross-checked against evidence/qa-gates/coverage-delta.2026-08-07T20-30.md.
- TypeScript: Baseline: 96.34% line / 89.27% branch. Post-change: 96.50% line / 89.76% branch. Change: +0.16 pp line and +0.49 pp branch, an improvement on both axes. New/changed-code coverage: 100.0% — all 34 lines added across the four pre-existing TypeScript files are covered, and each of the five new modules exceeds both thresholds. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` parsed by the reviewer after `npm run test:coverage`.

Per-file figures for every module the branch created or changed are in section 5.

## 2. General Code Change Policy Compliance

Reference: `.claude/rules/general-code-change.md`.

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Simplicity first | PASS | Validators are flat pure functions returning `list[str]` / `string[]`. No class hierarchy, no indirection beyond one helper call per invariant group. |
| Reusability | PASS | `_parallel_state_common.py` holds the nine S4 enums, the blast-radius block validator, the item-record validator, and the prohibited-key scanner; the manifest, planner, and orchestrator surfaces all call the same implementation rather than restating it. |
| Extensibility | PASS | Both entry points use keyword-only opt-in flags with `False` defaults (`require_complete`, `require_ready_for_execution`), so existing callers are unaffected. `validate_item_record(..., require_kind=...)` parameterizes the one surface difference instead of forking the function. |
| Separation of concerns | PASS | All six Python modules and all five TypeScript modules are pure: no disk, network, or subprocess access. The only I/O is the pre-existing dispatcher's `_read_text`. |
| Mandatory toolchain loop | PASS with one pre-existing gap | Stages 1, 2, 3, 5 executed and clean on both surfaces (section 7). Stage 4 (architecture-boundary) has no configured tool in this repository (`.dependency-cruiser.cjs` is absent at the repo root and under `extensions/drm-copilot/`); this is a pre-existing repository condition, not a defect of this branch. Stage 6 (contract/schema compatibility) is satisfied by the definitions-alignment test asserting both MCP surfaces advertise the same enum. Stage 7 (integration) is covered by the in-memory MCP round-trip test. |
| File size limit (500 lines) | PASS | Every one of the 34 non-Markdown files in the diff was measured with `wc -l`. The maximum is 499 (`tests/scripts/dev_tools/test_validate_parallel_planner_state.py`). Full table in section 9. |
| Error handling, fail fast | PASS | Each validator returns one error per violated condition rather than raising; a non-object root and unparseable text each short-circuit to a single-element list, which is the documented contract. `json.JSONDecodeError` is the only exception caught, and it is caught narrowly. |
| Naming | PASS | `snake_case` Python functions, `CONSTANT_CASE` module constants, `camelCase` TypeScript functions, `PascalCase` TypeScript interfaces, kebab-case TypeScript filenames. |
| Public API compatibility | PASS | Every change to a pre-existing file is purely additive. The `config/orchestration-routing.json` diff is a single hunk of added lines; no pre-existing route entry is altered. |
| Dependencies | PASS | Neither `pyproject.toml` nor `extensions/drm-copilot/package.json` is in the diff. PyYAML was already declared. |
| I/O boundaries | PASS | No new I/O is introduced anywhere in the diff. |

## 3. Language-Specific Code Change Policy Compliance

### 3.1 Python — `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Black formatting | PASS | `poetry run black --check .` — `360 files would be left unchanged.` |
| Ruff lint | PASS | `poetry run ruff check .` — `All checks passed!` |
| Pyright strict type check | PASS | `poetry run pyright` — `0 errors, 0 warnings, 0 informations`. |
| Full type annotation | PASS | Every public and private function in the six new modules carries complete parameter and return annotations. `object` plus `cast` is used at the deserialization boundary; `Any` appears nowhere. |
| Suppression policy | PASS | `grep -rn "noqa\|type: ignore"` over the six new Python modules returned no match (grep exit 1). Zero suppressions to authorize. |
| Absolute imports | PASS | All imports are `from scripts.dev_tools... import ...`. |
| No print / logging misuse | PASS | Validators are pure; the pre-existing dispatcher owns all stderr output. |
| Docstring and comment policy (`.claude/rules/self-explanatory-code-commenting.md`) | PASS | Every module, function, and private helper carries a Google-style docstring. Every loop and every non-trivial branch carries an intent comment. No numbered `NOTE n:` tags. |

### 3.2 TypeScript — `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Prettier formatting | PASS | `npx prettier --check "src/**/*.ts" "test/**/*.ts"` — `All matched files use Prettier code style!` |
| ESLint | PASS | `npm run lint` — no diagnostics emitted, exit 0. |
| `tsc --noEmit` | PASS | `npm run typecheck` — no diagnostics emitted, exit 0. |
| No `any` | PASS | `grep -rn ": any\| as any"` over the five new modules returned no match (grep exit 1). `unknown` plus narrowing is used throughout, with `isObject` as the single type guard. |
| Suppression policy | PASS | `grep -rn "eslint-disable\|@ts-expect-error\|@ts-ignore\|@ts-nocheck"` over the five new modules returned no match (grep exit 1). |
| ES modules | PASS | All five modules use `import` / `export`. |
| Kebab-case filenames | PASS | `parallel-state-shared.ts`, `parallel-state-structures.ts`, `parallel-state-records.ts`, `parallel-orchestrator-state-core.ts`, `parallel-planner-state-core.ts`. |
| Architecture boundaries (`.claude/rules/architecture-boundaries.md`) | PASS by inspection | The new modules import only from each other. No Office.js, Graph SDK, VSTO, COM, or Outlook reference. The automated `dependency-cruiser` stage cannot run because the repository has no `.dependency-cruiser.cjs`; this pre-existing gap is recorded as Informational I1 in the code review. |

### 3.3 PowerShell and C#

N/A. The branch diff contains zero `.ps1`, `.psm1`, `.psd1`, and zero `.cs` or `.csproj` files.

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Pytest as runner, `test_...` names | PASS | All six new Python test files use plain `def test_*` functions under `tests/scripts/dev_tools/`. |
| `pytest.mark.parametrize` for boundary matrices | PASS | Used for every enum-membership matrix, for example `@pytest.mark.parametrize("state_value", VALID_ITEM_STATES)` at `test_validate_parallel_orchestrator_state.py:271`. |
| One behavior per test, AAA structure | PASS | Each test builds a valid document, applies exactly one mutation, and asserts on the resulting error list. |
| Patch at the import location used by the unit | PASS | The dispatch test monkeypatches `_read_text` on `scripts.dev_tools.validate_orchestration_artifacts`, which is where the unit under test resolves it. |
| Jest as framework, `*.test.ts` naming | PASS | All eight new Jest files end in `.test.ts`. The shared builder lives in the non-suite support module `parallel-state-test-support.ts`, which Jest does not collect as a suite. |
| `it.each` for matrices | PASS | Used for the required-key matrix and for both new artifact types on both MCP definition surfaces. |
| No snapshot tests | PASS | `Snapshots: 0 total` in the Jest run. |
| Determinism infrastructure | PASS | No fake-timer facility is needed: no new code path reads a clock, and no async scheduling is introduced. |
| Property-based tests | N/A with recorded exemption | `.claude/rules/quality-tiers.md` makes property-test density tier-dependent (T1/T2 only). `quality-tiers.yml` is absent at the repo root, so no tier attaches. The decision is recorded at `evidence/other/property-test-decision.2026-08-07T19-58.md` with the branch taken and the modules covered. Recorded as Informational I2. |

## 5. Test Coverage Detail

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
| ---------- | ---------- | ---------- | ---------- | ---------- | ---------- | ---------- |
| Python | 9 | 2835 | 2835 passed, 0 failed | 91.32% line / 82.54% branch | 91.71% line / 83.58% branch | 100.0% line on all six new modules and on all 38 added lines |
| TypeScript | 21 | 2363 | 2363 passed, 0 failed | 96.34% line / 89.27% branch | 96.50% line / 89.76% branch | 96.91%-100.0% line on the five new modules; 100.0% on all 34 added lines |
| PowerShell | 0 | 0 | N/A | N/A | N/A | N/A |
| C# | 0 | 0 | N/A | N/A | N/A | N/A |

Per-file figures parsed by the reviewer from `artifacts/python/lcov.info` and
`extensions/drm-copilot/coverage/lcov.info`:

| Module | Line | Branch | Threshold check |
| --- | --- | --- | --- |
| `scripts/dev_tools/_parallel_state_common.py` | 122/122 = 100.00% | 62/62 = 100.00% | PASS |
| `scripts/dev_tools/_parallel_state_records.py` | 88/88 = 100.00% | 50/50 = 100.00% | PASS |
| `scripts/dev_tools/_parallel_state_structures.py` | 149/149 = 100.00% | 86/86 = 100.00% | PASS |
| `scripts/dev_tools/parallel_manifest_contract.py` | 65/65 = 100.00% | 22/22 = 100.00% | PASS |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 80/82 = 97.56% | 32/34 = 94.12% | PASS |
| `scripts/dev_tools/validate_parallel_planner_state.py` | 112/112 = 100.00% | 46/46 = 100.00% | PASS |
| `scripts/dev_tools/validate_orchestration_artifacts.py` (modified) | 116/124 = 93.55% | 42/50 = 84.00% | PASS, 0 uncovered added lines |
| `src/lib/validate/parallel-state-shared.ts` | 471/486 = 96.91% | 97/101 = 96.04% | PASS |
| `src/lib/validate/parallel-state-structures.ts` | 496/496 = 100.00% | 110/112 = 98.21% | PASS |
| `src/lib/validate/parallel-state-records.ts` | 347/347 = 100.00% | 66/66 = 100.00% | PASS |
| `src/lib/validate/parallel-orchestrator-state-core.ts` | 318/320 = 99.38% | 35/38 = 92.11% | PASS |
| `src/lib/validate/parallel-planner-state-core.ts` | 453/453 = 100.00% | 48/49 = 97.96% | PASS |
| `src/lib/validate/orchestration-artifacts.ts` (modified) | 281/281 = 100.00% | 65/66 = 98.48% | PASS, 0 uncovered added lines |
| `src/mcp-tool-inputs.ts` (modified) | 453/479 = 94.57% | 64/69 = 92.75% | PASS, 0 uncovered added lines |
| `src/mcp-tool-definitions.ts` (modified) | 453/453 = 100.00% | n/a (data module) | PASS, 0 uncovered added lines |
| `src/mcp-repo-automation-tool-definitions.ts` (modified) | 404/404 = 100.00% | n/a (data module) | PASS, 0 uncovered added lines |

Changed-line coverage was computed by intersecting the `-U0` diff hunk line numbers for each
pre-existing source file with the zero-hit `DA:` records in the corresponding lcov file:

```
scripts/dev_tools/validate_orchestration_artifacts.py: added=38 measured=12 uncovered_added=0 []
extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts: added=24 measured=24 uncovered_added=0 []
extensions/drm-copilot/src/mcp-tool-inputs.ts: added=2 measured=2 uncovered_added=0 []
extensions/drm-copilot/src/mcp-tool-definitions.ts: added=4 measured=4 uncovered_added=0 []
extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts: added=4 measured=4 uncovered_added=0 []
TOTAL added=72 uncovered_added=0
```

This independently confirms the executor's claim of 72 changed lines with zero uncovered.

The five per-file Jest `coverageThreshold` entries added at `extensions/drm-copilot/jest.config.cjs`
lines 162-186 cover all five new TypeScript modules, including `parallel-state-records.ts` at line
175. The reviewer confirms the entry is present, contradicting the Phase 7 report claim that it was
absent.

## 6. Test Execution Metrics

| Suite | Command | Result |
| --- | --- | --- |
| Python, full | `poetry run pytest -q` | 2835 passed in 4.54 s, exit 0 |
| Python, new files only | `poetry run pytest tests/scripts/dev_tools/test_parallel_*.py tests/scripts/dev_tools/test_validate_parallel_*.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py -q` | 370 passed in 0.51 s, exit 0 |
| TypeScript, full with coverage | `npm run test:coverage` | Test Suites: 177 passed, 177 total; Tests: 2363 passed, 2363 total; exit 0 |
| TypeScript, new files only | `node run-jest.cjs <eight new test paths>` | Test Suites: 8 passed; Tests: 302 passed; 1.477 s |
| Cross-runtime parity harness | esbuild bundle of both TypeScript cores run under Node against 43 documents, compared to the Python validators over the same 43 documents | `MISMATCHED_CASES=0`, `TOTAL_STRINGS py=96 ts=96` |

The executor's reported counts (2835 Python, 177 suites / 2363 TypeScript) are confirmed exactly.

## 7. Code Quality Checks

| Check | Command | Result |
| --- | --- | --- |
| Python format | `poetry run black --check .` | `All done!` — 360 files unchanged, exit 0 |
| Python lint | `poetry run ruff check .` | `All checks passed!`, exit 0 |
| Python type check | `poetry run pyright` | `0 errors, 0 warnings, 0 informations`, exit 0 |
| Python tests | `poetry run pytest -q` | 2835 passed, exit 0 |
| TypeScript format | `npx prettier --check "src/**/*.ts" "test/**/*.ts"` | `All matched files use Prettier code style!`, exit 0 |
| TypeScript lint | `npm run lint` | no diagnostics, exit 0 |
| TypeScript type check | `npm run typecheck` | no diagnostics, exit 0 |
| TypeScript tests and coverage | `npm run test:coverage` | 177 suites / 2363 tests passed, per-file thresholds satisfied, exit 0 |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0, no output |
| Routing-config parity | `diff config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json` | identical, exit 0; `sha256sum` of both files: `d9c6657cbdbe15413e0fb9bc1be700ce1a8f892d0db413c3bbc253ea24ea7bda` |
| Rule-file mirror parity | `diff .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` | identical, exit 0 |
| Epic validators unchanged | `git diff --name-only <base>..HEAD \| grep -iE "epic"` | one match only, an evidence Markdown file; zero hunks under `validate_epic_*`, `_epic_*`, `epic-*` |
| Foreign JSON Schema absence | `grep -rln "\$schema\|additionalProperties"` over the eleven new validator modules | no match, exit 1 |

### 7.1 `modified-workflow-needs-green-run`

`git diff --name-only ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD | grep -E "^\.github/workflows/|^scripts/benchmarks/|^\.github/actions/"` returned no match (grep exit 1). The rule's
trigger paths are not touched, so the rule does not fire and no green-run evidence is required.
`.claude/rules/ci-workflows.md` and `.claude/rules/benchmark-baselines.md` likewise do not apply.

### 7.2 Scope-Boundary Verification

Each boundary was verified by execution or by diff inspection, not by reading the plan.

| # | Boundary | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | MCP surface grows by exactly two `artifact_type` values | PASS | The diffs of `mcp-tool-inputs.ts`, `mcp-tool-definitions.ts`, and `mcp-repo-automation-tool-definitions.ts` each add exactly `parallel-orchestrator-state` and `parallel-planner-state`. `grep -rn "parallel_kickoff\|parallel-kickoff" scripts/ extensions/drm-copilot/src/` finds only the P9 path template and its TypeScript twin. `scripts/dev_tools/parallel_kickoff_contract.py` does not exist. Correct absence, not a gap. |
| 2 | Ready gate is structural only, kickoff PATH not CONTENT | PASS | `validate_parallel_planner_state.py:396` computes the expected path with `KICKOFF_PATH_TEMPLATE.format(...)` and compares strings. No file read, no repository call, no parse of kickoff text anywhere in the module. |
| 3 | `mutations[]`, `drift_events[]`, `conflict_edges[]` complete | PASS | S5 is enforced by `_validate_mutation_item_key`, `_validate_mutation_state_field` (both null-rule variants), `_validate_mutation_disposition`, and `_validate_mutation_generation`. S6 is enforced by `validate_drift_events` across all six fields. S7 is enforced by `_validate_edge_endpoints` plus the reason enum and the duplicate-pair pass. Nothing is deferred. |
| 4 | No `depends_on`, `integration_branch`, `epic_merge_pr`; actively rejected at any level | PASS | `PROHIBITED_ANY_LEVEL_KEYS` is scanned depth-first over the whole document. Executed evidence: a `depends_on` nested at `items[0]` yields `Parallel checkpoint carries prohibited key 'depends_on' at items[0].`; top-level `integration_branch` and `epic_merge_pr` each yield their own rejection. `issue_num` is the primary key throughout (`collect_issue_numbers`). |
| 5 | Recoloring recomputation deliberately absent (P5) | PASS | Neither validator imports `parallel_cohort_computation`. The omission is stated in the planner module docstring and as P5 in the rule file. |
| 6 | No JSON Schema authored or imported; disqualified foreign schema not copied | PASS | No `.json` schema file is added. `grep -rn "drmoisan.github.io"` over the eleven validator modules returns no match; the only occurrence in the branch is the prose Foreign Schema Warning at `.claude/rules/parallel-orchestration.md:9`, which restates the prohibition as required. |
| 7 | Existing epic validators unmodified | PASS | The name-only diff contains no path matching `validate_epic_*`, `_epic_*`, `epic-*`, or their tests. |

## 8. Gaps and Exceptions

Seven Advisory and five Informational findings are recorded in full, with file, location, violated
rule, and reproduction command, in `code-review.2026-08-07T20-36.md`. Summary:

- **A1** — `pythonRepr` uses single quotes with a backslash escape where CPython `repr` switches to
  double quotes, so a rejected string containing an apostrophe diverges from the Python source. Same
  behavior exists in every pre-existing epic and codex TypeScript copy.
- **A2** — Integral floats (`10.0`) are rejected by Python and accepted by TypeScript because
  `JSON.parse` cannot distinguish them from integers. Inherent to the runtime; already documented in
  the module header.
- **A3** — Python's `True == 1` equality selects a boolean-generation cohort as current-generation
  where TypeScript's `===` does not, producing a different error count for that malformed input.
- **A4** — Spec table S2 marks `parallel_slug`, `parallel_manifest_path`, and
  `parallel_status_doc_path` non-empty, but no V-O invariant enforces it and the orchestrator
  validator checks presence only. The planner P2 does enforce non-empty for the first two.
- **A5** — Spec S5's `disposition` row and invariant 17 disagree; the implementation follows the
  stricter invariant 17 and records the resolution in the module docstring.
- **A6** — The split-out modules `_parallel_state_records.py` and `parallel-state-records.ts` are
  not named in `plan.2026-08-07T11-11.md` and are not listed in its Notes divergence section,
  unlike the SA16 divergence which is.
- **A7** — The rule file's Enforcement bullet asserts unqualified byte-identity for the TypeScript
  port; A1 through A3 are unqualified exceptions to that claim.
- **I1** — The architecture-boundary toolchain stage has no configured tool (`.dependency-cruiser.cjs`
  absent). Pre-existing.
- **I2** — `quality-tiers.yml` absent at the repo root. Pre-existing and separately documented.
- **I3** — Pyright reported `venv .venv subdirectory not found in venv path` for this worktree
  before reporting zero diagnostics. Environment note only.
- **I4** — The Python dispatch test imports builders from three sibling test modules. Planned and
  precedented by the epic dispatch tests.
- **I5** — `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` is 508 lines,
  over the cap. Pre-existing and untouched by this branch (confirmed: the file does not appear in
  the name-only diff). Not attributable to this feature.

No finding is Blocking. Remediation is not triggered, so no `remediation-inputs` artifact is
produced.

## 9. Summary of Changes

64 files changed, +11538 / -114, in commit `3eb6b348`.

New production modules (Python, all under `scripts/dev_tools/`):

| File | Lines | Role |
| --- | --- | --- |
| `_parallel_state_common.py` | 495 | Nine S4 enums, blast-radius block, item record, prohibited-key scanner |
| `_parallel_state_structures.py` | 496 | Cohorts, conflict edges, receipt arrays; re-exports the record validators |
| `_parallel_state_records.py` | 324 | `mutations[]` (S5) and `drift_events[]` (S6) |
| `parallel_manifest_contract.py` | 312 | M1-M7 plus the two default-resolving accessors |
| `validate_parallel_orchestrator_state.py` | 336 | Invariants 1-19, gate 20-21, F7 seam |
| `validate_parallel_planner_state.py` | 449 | P1-P4, ready gate P6-P9 |

New production modules (TypeScript, all under `extensions/drm-copilot/src/lib/validate/`):
`parallel-state-shared.ts` (486), `parallel-state-structures.ts` (496),
`parallel-state-records.ts` (347), `parallel-orchestrator-state-core.ts` (320),
`parallel-planner-state-core.ts` (453).

Modified files, all additively: `scripts/dev_tools/validate_orchestration_artifacts.py` (+38),
`extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` (+24),
`extensions/drm-copilot/src/mcp-tool-inputs.ts` (+2),
`extensions/drm-copilot/src/mcp-tool-definitions.ts` (+4, of which 2 are description rewordings),
`extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (+4),
`extensions/drm-copilot/jest.config.cjs` (+25), `config/orchestration-routing.json` (+22) and its
byte-identical mirror.

New documentation: `.claude/rules/parallel-orchestration.md` (184 lines) and its byte-identical
bundled mirror.

File-size verification, every non-Markdown file in the diff, largest first (cap 500):

```
499 tests/scripts/dev_tools/test_validate_parallel_planner_state.py
497 tests/scripts/dev_tools/test_parallel_manifest_contract.py
496 scripts/dev_tools/_parallel_state_structures.py
496 extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts
495 scripts/dev_tools/_parallel_state_common.py
494 extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-structures.test.ts
486 tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py
486 extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts
479 extensions/drm-copilot/src/mcp-tool-inputs.ts
469 tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_completion.py
453 extensions/drm-copilot/src/mcp-tool-definitions.ts
453 extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts
449 scripts/dev_tools/validate_parallel_planner_state.py
... (remaining 21 files all below 449)
```

Maximum 499. Zero files over the cap.

## 10. Compliance Verdict

**PASS.**

- Blocking findings: 0.
- Advisory findings: 7.
- Informational findings: 5.
- Coverage verdict, Python (30 changed files include 9 Python files): **PASS**.
- Coverage verdict, TypeScript (21 changed files): **PASS**.
- Coverage verdict, PowerShell: N/A, zero changed files.
- Coverage verdict, C#: N/A, zero changed files.
- Acceptance criteria: 32 of 32 PASS (19 in `spec.md`, 13 in `user-story.md`). See
  `feature-audit.2026-08-07T20-36.md`.
- Remediation: not triggered.

The branch is ready for a pull request against `epic/parallel-orchestration-integration`. The seven
Advisory findings should be dispositioned at epic fan-in or logged as potential-feature entries;
none of them blocks this pull request.

## Appendix A: Test Inventory

Python, `tests/scripts/dev_tools/` — 370 tests across six files:

| File | Test functions | Covers |
| --- | --- | --- |
| `test_validate_parallel_orchestrator_state.py` (486 lines) | 34 | Builder `build_valid_parallel_state()`; invariants 1-11, 14, 19; invalid JSON; non-object root; absent-optional-receipt case |
| `test_validate_parallel_orchestrator_state_structures.py` (348 lines) | 26 | Invariants 12-13, 15-18: cohorts, edges, mutations including the disposition rule, drift events |
| `test_validate_parallel_orchestrator_state_completion.py` (469 lines) | 36 | Invariants 20-21: closed and open completion, close-mutation requirement, withdrawn-item exemption |
| `test_validate_parallel_planner_state.py` (499 lines) | 31 | P1-P4 and P6-P9, ready-gate positive and per-field negative cases |
| `test_parallel_manifest_contract.py` (497 lines) | 28 | M1-M7, LF/CRLF/CR tolerance, both default accessors, `depends_on` rejection |
| `test_validate_orchestration_artifacts_parallel_dispatch.py` (359 lines) | 15 | Both new subparsers, both dispatch branches, exit codes, unknown-artifact-type fallback |

TypeScript, `extensions/drm-copilot/test/` — 302 tests across eight suites:

| File | `it` blocks | Covers |
| --- | --- | --- |
| `lib/validate/parallel-orchestrator-state-core.test.ts` (417 lines) | 38 | Invariants 1-11, 14, 19; root handling; byte-identical literals |
| `lib/validate/parallel-orchestrator-state-structures.test.ts` (494 lines) | 49 | Invariants 12-13, 15-18 |
| `lib/validate/parallel-orchestrator-state-completion.test.ts` (126 lines) | 9 | Invariants 20-21 |
| `lib/validate/parallel-planner-state-core.test.ts` (430 lines) | 32 | P1-P4, P6-P9 |
| `lib/validate/orchestration-artifacts-parallel-dispatch.test.ts` (144 lines) | 9 | `validateArtifact` dispatch for both new types plus the unknown-type fallback |
| `mcp-tool-inputs-parallel-validation.test.ts` (138 lines) | 7 | `VALID_ARTIFACT_TYPES` membership and flag forwarding |
| `mcp-parallel-validation-definitions.test.ts` (113 lines) | 5 | Both definition surfaces advertise both new enum values and stay aligned |
| `mcp-server-parallel-validation.test.ts` (179 lines) | 3 | In-memory MCP round trip with a mocked `RepoAutomationService` |
| `lib/validate/parallel-state-test-support.ts` (158 lines) | n/a | Shared builder; not a suite |

The delivered eight TypeScript files are a superset of the five named in spec AC 16. The divergence
is recorded in the plan's Notes section.

## Appendix B: Toolchain Commands Reference

```bash
# Scope
git diff --stat ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD
git diff --name-only ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD

# PR context refresh (artifacts were absent; regenerated against the resolved base)
poetry run python -m scripts.dev_tools.pr_context.collector \
  --base ae6331f7693fb7c05e2c5c7f8416c46c469929fa --head HEAD --repo-root .

# Python toolchain
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest -q

# TypeScript toolchain (cwd: extensions/drm-copilot)
npx prettier --check "src/**/*.ts" "test/**/*.ts"
npm run lint
npm run typecheck
npm run test:coverage

# Policy gates
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
diff config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json
diff .claude/rules/parallel-orchestration.md \
  extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md

# Cross-runtime byte-parity harness (reviewer-built, scratchpad only)
./node_modules/.bin/esbuild <scratchpad>/parity_entry.ts --bundle --platform=node \
  --format=cjs --outfile=<scratchpad>/parity_entry.cjs
node <scratchpad>/parity_entry.cjs <scratchpad>/cases.json

# Artifact self-validation
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py policy-audit \
  docs/features/active/2026-08-07-parallel-schema-validators-444/policy-audit.2026-08-07T20-36.md
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py code-review \
  docs/features/active/2026-08-07-parallel-schema-validators-444/code-review.2026-08-07T20-36.md
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py feature-audit \
  docs/features/active/2026-08-07-parallel-schema-validators-444/feature-audit.2026-08-07T20-36.md
```
