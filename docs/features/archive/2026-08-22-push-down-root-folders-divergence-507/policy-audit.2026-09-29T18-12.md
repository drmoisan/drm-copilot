# Policy Audit: Push-Down Root Folders Divergence (#507)

- Branch: `bug/push-down-root-folders-divergence-exec-507`
- Head commit: `977a1011`
- Review base: `origin/epic/push-down-payload-correctness-integration` (epic child; three-dot diff `origin/epic/push-down-payload-correctness-integration...HEAD`)
- Work mode: `full-bug` (AC source: `spec.md` only)
- Audit timestamp: 2026-09-29T18-12
- Auditor: feature-review agent

## Executive Summary

The branch aligns the Python Claude push-down with the TypeScript implementation: `ROOT_FOLDERS` now declares `(Path(".claude"), Path("config"))`, `config/` is read from the extension bundle, `config/orchestration-routing.json` is merged, and `config/blast-radius.json` is derived from the destination layout. Five new Python production modules, nine new Python test modules, one changed Python test, one new Jest test file, one shared JSON fixture, and a one-line `README.md` change make up the code delta.

Toolchain checks re-run by the reviewer on the changed files all passed: Black (15 files unchanged), Ruff (all checks passed), Pyright (0 errors, 0 warnings), the scoped pytest selection (194 passed), the full pytest suite (5472 passed, 6 skipped), Prettier, ESLint, and Jest on the new test file (9 passed). Coverage meets the uniform thresholds for every new and changed Python module (minimum 98.84% line and 91.67% branch across new modules; the changed module is 92.75% line and 75.00% branch, with no changed line uncovered). Repo-wide Python coverage is 93.22% line and 86.07% branch; repo-wide TypeScript coverage is 96.96% line and 90.97% branch.

No FAIL findings and no blocking PARTIAL findings were identified. Two non-blocking PARTIAL findings are recorded: a broad `except Exception` in `_list_tolerantly` (spec-pinned parity behavior, documented in the docstring), and plan task P10-T3 left unchecked because its acceptance demanded a `Claude-Session:` trailer that the session attribution guidance omits.

Overall verdict: PASS (0 blocking findings).

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the review base `origin/epic/push-down-payload-correctness-integration`, which is the legitimate integration target for this epic child, and a scope summary that matches the full branch diff. The caller instruction to record AC25 as pending-PR rather than FAIL concerns the status of a criterion that is only evaluable when the PR description exists; it does not narrow the audit scope. The audit covers every file in `git diff --name-status origin/epic/push-down-payload-correctness-integration...HEAD` (63 files).

## Evidence Location Compliance

- `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` exited 0 with no reported paths.
- `git diff --name-only origin/epic/push-down-payload-correctness-integration...HEAD -- artifacts/` returned no paths. No branch file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All executor evidence lives under `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence and isolation | PASS | Each test builds its own `RecordingFileSystem` or injected `DirectoryLister`; module state is patched only through `pytest.MonkeyPatch`, which restores it. |
| Determinism | PASS | No clock, randomness, or sleep APIs in the new tests; the destination scan uses an injected lister; `real_directory_lister` is tested by replacing `os.scandir` in the module namespace. |
| No temporary files | PASS | `rg "tmp_path|tempfile|TemporaryDirectory|mkdtemp"` over `tests/scripts/dev_tools/test_push_down_claude_*.py` returned no matches; the Jest file contains no `tmpdir`, `mkdtemp`, or write calls. |
| No external dependencies | PASS | The only real-file reads are committed repository sources (TypeScript and Python modules, `README.md`, the shared fixture) read for static parity; no network or process calls. |
| Scenario completeness | PASS | Positive, negative (invalid JSON, `NaN`/`Infinity`, non-object roots), edge (backslash and case-mismatched paths, absent bundle `config/`, empty scan), and error-propagation (destination bytes unchanged) cases are present. |
| Arrange-Act-Assert and naming | PASS | Test names describe the scenario; each test carries a docstring. |
| Test file location | PASS | Python tests under `tests/scripts/dev_tools/` mirror `scripts/dev_tools/`; the Jest file lives under `extensions/drm-copilot/test/lib/push-down/`, mirroring `src/lib/push-down/`. |
| Coverage exclusion policy | PASS | `pyproject.toml` and the Jest configuration are not in the branch diff; no production path was added to any exclude list. |

### 1.1 Coverage Evidence Checklist

- Python baseline coverage artifact: `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-coverage-baseline.2026-09-29T17-28.md` (changed module 92.42% line, 75.00% branch)
- Python post-change coverage artifact: `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/python-coverage.pass-1.2026-09-29T17-59.md` and `artifacts/python/lcov.info` (repo-wide, regenerated by the reviewer at 2026-09-29T18-10)
- TypeScript baseline coverage artifact: `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-jest-coverage.2026-09-29T17-28.md` (96.95% lines, 90.91% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` and `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/qa-gates/ts-jest-coverage.pass-1.2026-09-29T18-02.md` (96.96% lines, 90.97% branches)
- PowerShell baseline coverage artifact: N/A - zero PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A - zero PowerShell files changed on the branch
- Per-language comparison summary: Python and TypeScript coverage rose slightly from baseline; no changed line is uncovered; PowerShell and C# have zero changed files.

### 1.2 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 6 production, 10 test | 5478 total (132 new) | 5472 passed, 6 skipped | 92.42% line, 75.00% branch (changed module) | 93.22% line, 86.07% branch (repo-wide) | 98.84% line minimum, 91.67% branch minimum (new modules) |
| TypeScript | 0 production, 1 test | 3163 | 3163 passed | 96.95% line, 90.91% branch (repo-wide) | 96.96% line, 90.97% branch (repo-wide) | N/A - test-only change; test files are excluded from coverage measurement |
| PowerShell | 0 | 0 | N/A | N/A | N/A | N/A |
| C# | 0 | 0 | N/A | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.42% line / 75.00% branch for the changed module `push_down_claude_customizations.py`; Post-change: 92.75% line / 75.00% branch for that module and 93.22% line / 86.07% branch repo-wide; Change: +0.33 percentage points line on the changed module, branch unchanged, and no changed line appears in the uncovered-line set; New/changed-code coverage: 98.84% line / 91.67% branch minimum across the five new modules (four at 100%); Disposition: PASS; Evidence: `evidence/qa-gates/python-coverage.pass-1.2026-09-29T17-59.md`, `evidence/qa-gates/python-coverage-delta.2026-09-29T17-59.md`, reviewer rerun reproducing identical per-module figures.
- TypeScript: Baseline: 96.95% line / 90.91% branch repo-wide; Post-change: 96.96% line / 90.97% branch repo-wide; Change: +0.01 percentage points line and +0.06 percentage points branch, with no production TypeScript file changed; New/changed-code coverage: N/A because the only changed TypeScript file is a test file excluded from measurement; Disposition: PASS; Evidence: `evidence/baseline/ts-jest-coverage.2026-09-29T17-28.md`, `evidence/qa-gates/ts-jest-coverage.pass-1.2026-09-29T18-02.md`, `extensions/drm-copilot/coverage/lcov.info` (LF 50014, LH 48494, BRF 7664, BRH 6972).

### 1.3 Per-File Python Coverage (new and changed production files)

| File | Status | Line | Branch | Verdict |
|---|---|---|---|---|
| `scripts/dev_tools/push_down_claude_routing_merge.py` | new | 100.00% (44/44) | 100.00% (18/18) | PASS |
| `scripts/dev_tools/push_down_claude_blast_radius_derive.py` | new | 100.00% (46/46) | 100.00% (10/10) | PASS |
| `scripts/dev_tools/push_down_claude_blast_radius_derive_core.py` | new | 100.00% (61/61) | 100.00% (16/16) | PASS |
| `scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py` | new | 100.00% (46/46) | 100.00% (14/14) | PASS |
| `scripts/dev_tools/push_down_claude_destination_writes.py` | new | 98.84% (85/86) | 91.67% (11/12) | PASS |
| `scripts/dev_tools/push_down_claude_customizations.py` | modified | 92.75% (64/69) | 75.00% (6/8) | PASS (no regression; uncovered lines 100-103 and 109 are the pre-existing second dual-import fallback block, unchanged by this branch) |

The single uncovered line in `push_down_claude_destination_writes.py` is line 106 (`return ""` when a path equals the destination root), which the write path cannot reach because the engine never writes to the root itself.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | Pure logic (routing merge, derivation core, manifest classification) is I/O-free; I/O is confined to `real_directory_lister` and the decorator adapters. |
| Reusability and extensibility | PASS | `MERGED_RELATIVE_PATHS` and `build_destination_write_stack()` provide the extension seams specified for #508 and #621; the new `list_entries` keyword is optional and keyword-only. |
| File size limit (500 lines) | PASS | Largest changed file is `scripts/dev_tools/push_down_claude_customizations.py` at 444 lines; largest test is `test_push_down_claude_parity.py` at 438 lines; the Jest file is 164 lines. |
| Error handling | PARTIAL (non-blocking) | `_list_tolerantly` in `push_down_claude_blast_radius_derive.py:106-109` uses `except Exception: return []`. The behavior is pinned by the spec and by the TypeScript tolerance rule (`claude-blast-radius-derive.ts:27-35`, "a `listEntries` failure at any level ... contributes no entries"), and the handler's docstring states the rationale. It does not log. See Section 8. |
| Public API compatibility | PASS | `push_down_customizations` keeps its signature; `list_entries` is additive. The read-only `inner` property on the decorators is additive. |
| Dependencies | PASS | No new dependency; `hypothesis` was not added (spec Assumptions section). |
| I/O boundaries | PASS | Core modules are tested with no filesystem access. |
| Scope boundaries | PASS | `skill_bundle_contract.py`, `push_down_copilot_customizations.py`, `push_down_claude_filesystem.py`, `test_push_down_claude_resource_contracts.py`, `enforce-powershell-batch-budget.ps1`, and every file under `extensions/drm-copilot/src/` are absent from the branch diff. |

## 3. Language-Specific Code Change Policy Compliance

### Python (`.claude/rules/python.md`, `.claude/rules/python-suppressions.md`)

| Requirement | Verdict | Evidence |
|---|---|---|
| Black formatting | PASS | `poetry run black --check` on 15 changed Python files: "15 files would be left unchanged". |
| Ruff lint | PASS | `poetry run ruff check` on the same files: "All checks passed!". |
| Pyright strict | PASS | `poetry run pyright` on the same files: "0 errors, 0 warnings, 0 informations". |
| Full type annotation, no `Any` in production | PASS | No `Any` in the five new production modules; the parity test imports `Any` for `ast` and JSON handling in test code. |
| Suppressions | PASS | No new `# noqa` or `# type: ignore`; the `# pragma: no cover - bundled import fallback` markers follow the existing module pattern. |
| Broad exception handlers | PARTIAL (non-blocking) | Same finding as Section 2 error handling. |
| Naming and docstrings | PASS | PEP 8 naming; module docstrings with Purpose and Invariants sections; function docstrings with Args, Returns, Raises. |
| `ROOT_FOLDERS` single-line declaration | PASS | `scripts/dev_tools/push_down_claude_customizations.py:115` reads exactly `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"), Path("config"))`. |

### TypeScript (`.claude/rules/typescript.md`)

| Requirement | Verdict | Evidence |
|---|---|---|
| Prettier | PASS | `npx prettier --check test/lib/push-down/claude-routing-merge-parity.test.ts`: "All matched files use Prettier code style!". |
| ESLint | PASS | `npx eslint` on the file exited 0 with no output. |
| Type check | PASS | `npm run typecheck` exit 0 (executor evidence `ts-typecheck-src.pass-1.2026-09-29T18-02.md`); `tsc -p tsconfig.jest.json` reports the same 71-file pre-existing error set as baseline and excludes the new test file (`ts-typecheck-tests.pass-1.2026-09-29T18-02.md`). |
| No production change | PASS | No path under `extensions/drm-copilot/src/` is in the branch diff. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Python tests use pytest, no temp files, injected seams | PASS | `RecordingFileSystem` from `push_down_customizations_test_support`, injected `DirectoryLister`, `monkeypatch` for `os.scandir`. |
| Property-based tests | PASS (not required) | `quality-tiers.yml` is absent from the repository (pre-existing gap, not introduced by this branch), so no T1/T2 classification requires property tests for `scripts/dev_tools/`; the spec records that `hypothesis` is not a declared dependency and substitutes deterministic table-driven idempotency and order-preservation cases. |
| Jest test uses no real timers or temp files | PASS | The test reads the committed fixture and asserts `mergeRoutingDocuments` output with `it.each` over nine cases. |
| Parity tests prove divergence detection | PASS | `test_typescript_root_folder_extraction_detects_divergence`, `test_python_root_folder_extraction_detects_divergence`, `test_set_comparison_fails_on_divergent_merged_paths`, and the two zero-declaration tests feed synthetic sources and assert failure. |

## 5. Test Coverage Detail

See Sections 1.2, 1.2.1, and 1.3. Repo-wide Python figures were computed from `artifacts/python/lcov.info` (198 source files; LF 16593, LH 15468, BRF 5994, BRH 5159). Repo-wide TypeScript figures were computed from `extensions/drm-copilot/coverage/lcov.info` (203 source files; LF 50014, LH 48494, BRF 7664, BRH 6972). Both exceed the uniform thresholds of 85% line and 75% branch.

Reviewer deviation recorded: the pre-existing `artifacts/python/lcov.info` reflected a six-module scoped run (the executor's P8-T5 command, reproduced by the reviewer's first scoped run through the `addopts` default report path), so it could not supply a repo-wide Python figure. The reviewer ran `poetry run pytest -q --cov --cov-branch` once, using the configured `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, to regenerate a repo-wide artifact. No tracked file changed (`git status --short` empty afterwards).

## 6. Test Execution Metrics

| Suite | Command | Result |
|---|---|---|
| Python, push-down Claude selection | `poetry run pytest tests/scripts/dev_tools -k push_down_claude --cov-branch ...` | 194 passed, 5196 deselected, 2.47 s |
| Python, full suite with coverage | `poetry run pytest -q --cov --cov-branch` | 5472 passed, 6 skipped, 83.39 s |
| Jest, new parity file | `npx jest test/lib/push-down/claude-routing-merge-parity.test.ts --coverage=false` | 1 suite, 9 tests passed |
| Jest, full suite (executor evidence) | `npm run test:coverage` | 231 suites, 3163 tests passed |

Pass counts moved from baseline 5340 to 5472 for Python (+132) and 3154 to 3163 for Jest (+9).

## 7. Code Quality Checks

| Stage | Python | TypeScript |
|---|---|---|
| 1. Formatting | PASS (Black) | PASS (Prettier) |
| 2. Linting | PASS (Ruff) | PASS (ESLint) |
| 3. Type checking | PASS (Pyright strict) | PASS (`npm run typecheck`; test-config errors equal the baseline set) |
| 4. Architecture boundaries | PASS (no new imports cross from `scripts/dev_tools` into production packages; TypeScript production untouched) | PASS (test-only change) |
| 5. Unit tests | PASS | PASS |
| 6. Contract / schema checks | PASS (static parity test pins `ROOT_FOLDERS`, merged paths, and derived paths against TypeScript; shared fixture pins merge output on both sides) | PASS |
| 7. Integration | PASS (`test_push_down_claude_config_carriage.py` runs `push_down_customizations` end to end on an in-memory filesystem) | N/A for a test-only change |

## 8. Gaps and Exceptions

| ID | Finding | Classification | Rationale |
|---|---|---|---|
| G1 | `_list_tolerantly` catches `Exception` and returns an empty listing without logging (`push_down_claude_blast_radius_derive.py:106-109`). | PARTIAL, non-blocking | `.claude/rules/python.md` says to avoid broad handlers without context. Here the behavior is a spec-pinned port of the TypeScript tolerance rule, the rationale is stated in the docstring, a test pins `RuntimeError` tolerance, and the default lister already narrows to `OSError`. Recommended follow-up: add a debug-level log or narrow the handler once TypeScript narrows its `catch {}`. |
| G2 | Plan task P10-T3 is unchecked because its acceptance demanded a `Claude-Session:` trailer, which the session attribution guidance omits. The commit `977a1011` exists with the specified subject and was pushed. | PARTIAL, non-blocking | The deliverable (a single commit with the specified subject and change set) exists. The attribution guidance in the session governs commit trailers and supersedes the plan text. The "do not push" clause was also overridden by the orchestrator. Neither affects code or AC outcomes. Recommended: annotate P10-T3 in the plan with the reason it remains unchecked. |
| G3 | The executor edited files directly instead of delegating to `python-typed-engineer` and `typescript-engineer` as the plan's delegation line requires. | Non-blocking process deviation | All outputs were independently re-verified by the reviewer against the same toolchain the engineers would run (Black, Ruff, Pyright, pytest, Prettier, ESLint, Jest). The deviation affects provenance, not code quality. |
| G4 | The #621 sentence in the `push_down_claude_destination_writes.py` module docstring wraps across lines 25-26 because of the 88-column limit. | Non-blocking | AC15's `rg -n "#508|#621"` check returns matches on lines 24 and 25; `test_module_docstring_names_downstream_seams` normalizes whitespace before matching the full sentence. |
| G5 | A read-only `inner` property was added to `_DelegatingFileSystem` for test introspection of the layer order. | Non-blocking | Additive, read-only, and documented. It enables the AC13 layer-order assertion without accessing a private attribute and gives #621 a supported way to inspect the stack. |
| G6 | `quality-tiers.yml` does not exist at the repository root. | Non-blocking, pre-existing | Not introduced by this branch; recorded because it prevents a tier-based property-test determination. |
| G7 | AC25 (PR description) cannot be evaluated before the PR exists. | Pending-PR, non-blocking | Deferred per `evidence/other/ac-reconciliation.2026-09-29T18-04.md` and the caller instruction. |

## 9. Summary of Changes

- `scripts/dev_tools/push_down_claude_customizations.py`: `ROOT_FOLDERS` gains `config`; the run composes `ExcludingFileSystem(BundleConfigFileSystem(build_destination_write_stack(fs, ...)))`; new optional `list_entries` keyword; docstrings and CLI help updated.
- New `push_down_claude_routing_merge.py`: pure port of `mergeRoutingDocuments` with `RoutingMergeError`.
- New `push_down_claude_blast_radius_derive_manifests.py`, `_core.py`, and `push_down_claude_blast_radius_derive.py`: ports of the TypeScript derivation (classification, core, destination scan).
- New `push_down_claude_destination_writes.py`: `MERGED_RELATIVE_PATHS`, `DestinationMergeFileSystem`, `BlastRadiusDeriveFileSystem`, `BundleConfigFileSystem`, `build_destination_write_stack()`.
- New tests for each module, an end-to-end carriage test, a static and behavioral parity test, a shared fixture, and a Jest case over the same fixture.
- `README.md`: Claude row lists `config/`.
- Feature-folder evidence, plan checkboxes, and spec AC1-AC24 checkboxes.

## 10. Compliance Verdict

| Area | Verdict |
|---|---|
| General unit test policy | PASS |
| General code change policy | PASS (one non-blocking PARTIAL, G1) |
| Python language policy | PASS (one non-blocking PARTIAL, G1) |
| TypeScript language policy | PASS |
| Coverage (Python) | PASS |
| Coverage (TypeScript) | PASS |
| Coverage (PowerShell, C#) | N/A - zero changed files |
| Evidence location compliance | PASS |
| Plan execution conformance | PARTIAL, non-blocking (G2, G3) |

Overall: PASS. Blocking findings: 0.

## Appendix A: Test Inventory

| Test file | Status | Lines | Scope |
|---|---|---|---|
| `tests/scripts/dev_tools/test_push_down_claude_customizations.py` | modified | 284 | AC1 assertion update |
| `tests/scripts/dev_tools/test_push_down_claude_routing_merge.py` | new | 259 | AC7, AC8, merge semantics |
| `tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_manifests.py` | new | 211 | Manifest vocabulary and classification |
| `tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core.py` | new | 282 | AC11 core cases |
| `tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core_guard.py` | new | 103 | Guard and derive errors |
| `tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive.py` | new | 193 | Destination scan and `real_directory_lister` |
| `tests/scripts/dev_tools/test_push_down_claude_destination_writes.py` | new | 407 | AC9, AC12-AC15 |
| `tests/scripts/dev_tools/test_push_down_claude_config_carriage.py` | new | 258 | AC5, AC6, AC9, AC10, AC23 |
| `tests/scripts/dev_tools/test_push_down_claude_parity.py` | new | 438 | AC2-AC4, AC16 |
| `tests/fixtures/push_down/routing-merge-parity.json` | new | 59 | Shared fixture, nine cases |
| `extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts` | new | 164 | AC16 Jest side |

## Appendix B: Toolchain Commands Reference

| Purpose | Command |
|---|---|
| Python format | `poetry run black --check <changed .py files>` |
| Python lint | `poetry run ruff check <changed .py files>` |
| Python types | `poetry run pyright <changed .py files>` |
| Python scoped coverage | `poetry run pytest tests/scripts/dev_tools -k push_down_claude --cov=scripts.dev_tools.<module> ... --cov-branch --cov-report=term-missing` |
| Python repo-wide coverage | `poetry run pytest -q --cov --cov-branch` |
| TypeScript format | `npx prettier --check test/lib/push-down/claude-routing-merge-parity.test.ts` (in `extensions/drm-copilot`) |
| TypeScript lint | `npx eslint test/lib/push-down/claude-routing-merge-parity.test.ts` |
| TypeScript test | `npx jest test/lib/push-down/claude-routing-merge-parity.test.ts --coverage=false` |
| Evidence locations | `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` |
| Scope diff | `git diff --name-status origin/epic/push-down-payload-correctness-integration...HEAD` |
