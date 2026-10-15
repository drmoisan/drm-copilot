# Policy Audit: Blast-Radius Config Has No Merge Decorator (#508)

- Branch: `bug/blast-radius-config-has-no-merge-decorator-exec-508`
- Head commit: `4c105aa40c55ad1756709ebb40df0fe89f6dc12a`
- Review base: `origin/epic/push-down-payload-correctness-integration` @ `fc96a14498473039f75d49746c11295858137723` (merge base identical; three-dot diff `origin/epic/push-down-payload-correctness-integration...HEAD`, 81 files, +3431/-182, 12 commits)
- Work mode: `full-bug` (marker in `issue.md`; AC source: `spec.md` only)
- Audit timestamp: 2026-09-29T19-32
- Auditor: feature-review agent
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent at review start and were regenerated with `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/push-down-payload-correctness-integration --head HEAD`. Both files carry `Head SHA: 4c105aa40c55ad1756709ebb40df0fe89f6dc12a` and the identical generation timestamp 2026-09-29 23:28:25 UTC, so the pair is fresh and bound to the reviewed head.

## Executive Summary

The branch adds a destination-owned overlay, `config/blast-radius.local.json`, that is composed at push time onto the regenerated `config/blast-radius.json` in both push-down implementations. TypeScript gains `claude-blast-radius-overlay.ts` (pure `composeBlastRadiusOverlay` plus `BlastRadiusOverlayFileSystem`) and replaces its hand-built decorator chain with the `DESTINATION_WRITE_DECORATORS` registry and a literal `MERGED_RELATIVE_PATHS` export. Python gains `push_down_claude_blast_radius_overlay.py` and extends the #507 registry in `push_down_claude_destination_writes.py` with a blast-radius entry, `INPUT_RELATIVE_PATHS`, and a `DestinationMerge`/`MERGED_PATHS` view. Both implementations exclude the overlay from publication. A six-case shared JSON corpus pins cross-language composition output, and the parallel-orchestration rule and its bundled mirror document the overlay.

Reviewer check-only reruns passed: Prettier, ESLint, and `tsc --noEmit` (exit 0 each); Black (7 files unchanged), Ruff (all checks passed), Pyright (0 errors); targeted Jest (5 suites, 92 tests passed) and targeted pytest (90 passed). Executor full-suite evidence records 3221 Jest tests and 5526 pytest tests passing with 0 failures. Every new and changed production file meets 85% line and 75% branch coverage; repo-wide TypeScript is 96.99% line / 91.05% branch and repo-wide Python is 93.27% line / 86.19% branch, each at or above baseline.

No Blocking findings. Non-blocking findings are recorded in Section 8 and in `code-review.2026-09-29T19-32.md`.

Overall verdict: PASS (0 blocking findings).

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the review base `origin/epic/push-down-payload-correctness-integration` (the legitimate integration target for this epic child) and requested the full `git diff origin/epic/push-down-payload-correctness-integration...HEAD`. No language, toolchain stage, or coverage check was exempted. The audit covers all 81 files in the branch diff.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 55 executor evidence files live under `docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/evidence/{baseline,other,qa-gates,regression-testing}/`.
- `artifacts/python/coverage-508-{baseline,final}.json` and `artifacts/pr_context.*` are untracked tool outputs outside the prohibited directories and are not part of the branch diff.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence and isolation | PASS | Each Jest case builds its own tree via `seedTree`; each pytest case builds its own `RecordingFileSystem`. No shared mutable module state is modified. |
| Determinism | PASS | No clock, randomness, timers, or sleeps in the new tests. Property tests use exhaustive enumeration over a fixed 24-pair domain. |
| No temporary files | PASS | Reviewer scan of added lines in `*.ts`, `*.py`, `*.cjs` for `tmp_path`, `tmpdir`, `mkdtemp`, `NamedTemporaryFile`, `TemporaryDirectory`, `os.tmpdir`, `mkdtempSync`: zero matches. Parity tests read committed fixtures read-only. |
| No external dependencies | PASS | Only committed repository files are read (TypeScript sources for static parity, the JSON corpus). No network or subprocess calls. |
| Scenario completeness | PASS | Positive (union, add, replace, nested merge), negative (unparseable overlay and base, non-object root, non-list value, non-string member, version mismatch including `true` versus `1`), boundary (absent overlay, `{}` overlay, absent version), guard (all three forbidden globs), and two-push idempotence and stale-clearing cases are present. |
| Arrange-Act-Assert and naming | PASS | Jest cases carry `// Arrange`, `// Act`, `// Assert` comments and descriptive `issue #508 ACnn` titles; pytest cases carry docstrings. |
| Test file location | PASS | Jest files under `extensions/drm-copilot/test/lib/push-down/` mirror `src/lib/push-down/`; pytest files under `tests/scripts/dev_tools/` mirror `scripts/dev_tools/`; fixtures under `tests/fixtures/blast_radius_overlay/`. |
| Coverage exclusion policy | PASS | `jest.config.cjs` diff adds only a `coverageThreshold` entry; `pyproject.toml` is not in the branch diff. No production path was added to any exclude list. One line-level `# pragma: no cover` is recorded in Section 8 (G1). |

### 1.1 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/evidence/baseline/ts-jest-coverage.2026-09-29T18-41.md` (96.96% lines, 90.97% branches repo-wide)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (mtime 19:16, after the last code commit `6c9278cc` at 19:13) and `docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/evidence/qa-gates/ts-jest-coverage.2026-09-29T19-16.md` (96.99% lines, 91.05% branches from the reviewer lcov parse)
- Python baseline coverage artifact: `docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/evidence/baseline/py-pytest-coverage.2026-09-29T18-41.md` (93.22% lines, 86.07% branches repo-wide)
- Python post-change coverage artifact: `artifacts/python/lcov.info` (mtime 19:20, after the last code commit) and `docs/features/active/2026-08-22-blast-radius-config-has-no-merge-decorator-508/evidence/qa-gates/py-pytest-coverage.2026-09-29T19-19.md` (93.27% lines, 86.19% branches)
- PowerShell baseline coverage artifact: N/A - zero PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A - zero PowerShell files changed on the branch
- Per-language comparison summary: TypeScript and Python repo-wide coverage rose slightly from baseline; every new file is at or above 99.55% line and 95.88% branch; no changed line is uncovered; PowerShell and C# have zero changed files.

### 1.2 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 3 production (1 new), 5 test (2 new), 1 config | 3221 total | 3221 passed, 0 failed | 96.96% line, 90.97% branch (repo-wide) | 96.99% line, 91.05% branch (repo-wide) | 99.55% line, 95.88% branch (`claude-blast-radius-overlay.ts`); 100.00% line, 95.74% branch (`claude-customizations.ts`) |
| Python | 3 production (1 new), 4 test (2 new) | 5532 total | 5526 passed, 6 skipped, 0 failed | 93.22% line, 86.07% branch (repo-wide) | 93.27% line, 86.19% branch (repo-wide) | 100.00% line, 100.00% branch (`push_down_claude_blast_radius_overlay.py`); 100.00% of changed executable lines in modified modules |
| PowerShell | 0 | 0 | N/A | N/A | N/A | N/A |
| C# | 0 | 0 | N/A | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.96% line / 90.97% branch repo-wide; Post-change: 96.99% line / 91.05% branch repo-wide (LF 50520, LH 48998, BRF 7774, BRH 7078); Change: +0.03 percentage points line and +0.08 percentage points branch; `claude-customizations.ts` branch rose from 94.59% to 95.74% with line coverage unchanged at 100.00%; New/changed-code coverage: 99.55% line / 95.88% branch for the new `claude-blast-radius-overlay.ts`, 100.00% line / 95.74% branch for the changed `claude-customizations.ts`, 99.36% line / 96.36% branch for the comment-only `claude-routing-merge.ts`; Disposition: PASS; Evidence: `evidence/baseline/ts-jest-coverage.2026-09-29T18-41.md`, `evidence/qa-gates/ts-jest-coverage.2026-09-29T19-16.md`, `evidence/qa-gates/coverage-delta.2026-09-29T19-22.md`, reviewer parse of `extensions/drm-copilot/coverage/lcov.info`.
- Python: Baseline: 93.22% line / 86.07% branch repo-wide; Post-change: 93.27% line / 86.19% branch repo-wide (LF 16717, LH 15592, BRF 6048, BRH 5213); Change: +0.05 percentage points line and +0.12 percentage points branch; `push_down_claude_destination_writes.py` rose from 98.84% / 91.67% to 99.01% / 92.86%; `push_down_claude_customizations.py` unchanged at 92.75% / 75.00%; New/changed-code coverage: 100.00% line / 100.00% branch for the new `push_down_claude_blast_radius_overlay.py`, 17 of 17 changed executable lines and 4 of 4 changed branches in `push_down_claude_destination_writes.py`, and the single changed executable line (116) in `push_down_claude_customizations.py` executed; Disposition: PASS; Evidence: `evidence/baseline/py-pytest-coverage.2026-09-29T18-41.md`, `evidence/qa-gates/py-pytest-coverage.2026-09-29T19-19.md`, `evidence/qa-gates/coverage-delta.2026-09-29T19-22.md`, reviewer parse of `artifacts/python/lcov.info`.

### 1.3 Per-File Coverage (new and changed production files)

| File | Status | Line | Branch | Verdict |
|---|---|---|---|---|
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` | new | 99.55% (445/447) | 95.88% (93/97) | PASS |
| `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` | modified | 100.00% (419/419) | 95.74% (45/47) | PASS (baseline 100.00% / 94.59%) |
| `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` | modified (comment only) | 99.36% (310/312) | 96.36% (53/55) | PASS |
| `scripts/dev_tools/push_down_claude_blast_radius_overlay.py` | new | 100.00% (109/109) | 100.00% (52/52) | PASS |
| `scripts/dev_tools/push_down_claude_customizations.py` | modified | 92.75% (64/69) | 75.00% (6/8) | PASS (equal to baseline; uncovered lines 100-103 and 109 are the pre-existing import-fallback block outside every hunk) |
| `scripts/dev_tools/push_down_claude_destination_writes.py` | modified | 99.01% (100/101) | 92.86% (13/14) | PASS (baseline 98.84% / 91.67%; uncovered line 180 is outside every hunk) |

Measurement note: the TypeScript coverage artifact is `extensions/drm-copilot/coverage/lcov.info`, the Jest output location in this repository; the root-level `coverage/lcov.info` path does not exist. The Python run measured `--cov=scripts.dev_tools` with branch coverage.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | Composition is pure and I/O-free in both languages; the decorators only read the overlay and delegate the write. |
| Reusability and extensibility | PASS | TypeScript `DESTINATION_WRITE_DECORATORS` and Python `MERGED_RELATIVE_PATHS`/`MERGED_PATHS` expose the merged-path set as data for #621. See code review NB-4 for a coupling note on `INPUT_RELATIVE_PATHS`. |
| File size limit (500 lines) | PASS | Reviewer `wc -l` on all 22 non-Markdown changed files: maximum 500 (`tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py`, at the cap). Largest production file 447 (`claude-blast-radius-overlay.ts`). |
| Error handling | PASS | `BlastRadiusOverlayError` and `BlastRadiusGuardError` are raised in the pure function before any inner write; tests assert the destination main file keeps its prior bytes. No broad exception handler was added. |
| Public API compatibility | PASS | `RoutingMergeFileSystem`, `BlastRadiusDeriveFileSystem`, `ROUTING_MERGE_RELATIVE_PATH`, and their error types remain exported (AC17 Jest case). `claude-blast-radius-derive.ts` and `claude-blast-radius-derive-core.ts` are absent from the diff. |
| Dependencies | PASS | `package.json`, `package-lock.json`, `pyproject.toml`, `poetry.lock` are absent from the diff. |
| I/O boundaries | PASS | The pure functions are tested with no file system access. |
| Scope boundaries | PASS | No file under `.claude/hooks`, the bundled hooks tree, or `tests/scripts/claude-hooks` is in the diff; no Copilot or Codex push-down file changed; the at-cap files listed in the spec are absent from the diff. |

## 3. Language-Specific Code Change Policy Compliance

### TypeScript (`.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`)

| Requirement | Verdict | Evidence |
|---|---|---|
| Prettier | PASS | Reviewer `npx prettier --check` on 9 changed TypeScript/CJS files: exit 0. |
| ESLint | PASS | Reviewer `npx eslint` on 8 changed TypeScript files: exit 0. |
| Type check | PASS | Reviewer `npx tsc --noEmit -p .`: exit 0. Executor evidence `ts-tsc.2026-09-29T19-16.md`. |
| No `any` escape hatches | PASS | Zero `as any` or `: any` on added lines. `JsonValue`/`JsonObject` types model parsed JSON. |
| Suppressions | PASS | Zero `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck`, `istanbul ignore`, or `c8 ignore` on added lines. |

### Python (`.claude/rules/python.md`, `.claude/rules/python-suppressions.md`)

| Requirement | Verdict | Evidence |
|---|---|---|
| Black formatting | PASS | Reviewer `poetry run black --check` on 7 changed Python files: "7 files would be left unchanged". |
| Ruff lint | PASS | Reviewer `poetry run ruff check` on the same files: "All checks passed!". |
| Pyright | PASS | Reviewer `poetry run pyright` on the new modules and tests: "0 errors, 0 warnings, 0 informations". |
| Full type annotation, no `Any` in production | PASS | `push_down_claude_blast_radius_overlay.py` uses `object` and `dict[str, object]` with `cast`; no `Any`. |
| Suppressions | PASS | No new `# noqa` or `# type: ignore`. One `# pragma: no cover - bundled import fallback` at `push_down_claude_blast_radius_overlay.py:40` follows the existing module pattern (Section 8, G1). |
| Naming and docstrings | PASS | PEP 8 naming; module docstring with Purpose and Invariants; public functions carry Args, Returns, Raises. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Jest tests use in-memory trees, no real timers, no temp files | PASS | `seedTree` and `layoutLister` helpers; read-only corpus access in the parity test. |
| pytest tests use `RecordingFileSystem`, no temp files | PASS | `push_down_customizations_test_support.RecordingFileSystem`; parametrized cases for keys, globs, and versions. |
| Property-based tests | PASS | Six properties (identity, idempotence, superset, overlay inclusion, determinism, version preservation) in each language by exhaustive enumeration over 24 base/overlay pairs; `fast-check` and `hypothesis` are not approved dependencies, per the spec decision. |
| Cross-language parity | PASS | `test_push_down_claude_overlay_parity.py` (merged-path sets, overlay constants, exclusion in both lists, corpus composition) and `claude-blast-radius-overlay-parity.test.ts` (same corpus). Code review NB-1 records an input class outside the corpus. |
| Regression fail-before/pass-after | PASS | `evidence/regression-testing/ts-fail-before.2026-09-29T18-41.md` (2 failed) and `py-fail-before.2026-09-29T18-41.md` (2 failed) precede the matching pass-after records. |

## 5. Test Coverage Detail

See Sections 1.2, 1.2.1, and 1.3. Repo-wide TypeScript figures were computed by the reviewer from `extensions/drm-copilot/coverage/lcov.info` (LF 50520, LH 48998, BRF 7774, BRH 7078). Repo-wide Python figures were computed from `artifacts/python/lcov.info` (LF 16717, LH 15592, BRF 6048, BRH 5213). Both exceed the uniform thresholds of 85% line and 75% branch. The reviewer did not regenerate either artifact; both postdate the final code commit.

## 6. Test Execution Metrics

| Suite | Command | Result |
|---|---|---|
| Jest, full suite with coverage (executor) | `node run-jest.cjs --coverage ...` in `extensions/drm-copilot` | 233 suites, 3221 tests passed |
| Jest, targeted (reviewer) | `node run-jest.cjs claude-blast-radius-overlay claude-config-carriage claude-customizations` | 5 suites, 92 tests passed |
| pytest, full suite with coverage (executor) | `poetry run pytest --cov=scripts.dev_tools --cov-branch ...` | 5526 passed, 6 skipped, 0 failed |
| pytest, targeted (reviewer) | `poetry run pytest` on the overlay, overlay-parity, parity, destination-writes, and customizations test files | 90 passed |
| Rule-doc and mirror tests (executor) | `poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 21 passed, 1 failed (issue #510 environment condition; see G3) |

Pass counts moved from the executor baseline to 3221 Jest tests and 5526 pytest tests with 0 failures in the full runs.

## 7. Code Quality Checks

| Stage | TypeScript | Python |
|---|---|---|
| 1. Formatting | PASS (Prettier) | PASS (Black) |
| 2. Linting | PASS (ESLint) | PASS (Ruff) |
| 3. Type checking | PASS (`tsc --noEmit`) | PASS (Pyright) |
| 4. Architecture boundaries | PASS (no dependency-cruiser configuration, matching baseline; the new module imports only sibling `src/lib/push-down/` modules) | PASS (no import-linter configuration, matching baseline) |
| 5. Unit tests | PASS | PASS |
| 6. Contract / schema checks | PASS (`ts-contract.2026-09-29T19-16.md`, 28 passed) | PASS (`py-contract.2026-09-29T19-19.md`, 6 passed) |
| 7. Integration | PASS (`ts-integration.2026-09-29T19-16.md`, 18 passed) | PASS (`py-integration.2026-09-29T19-19.md`, 58 passed) |

## 8. Gaps and Exceptions

| ID | Finding | Classification | Rationale |
|---|---|---|---|
| G1 | `scripts/dev_tools/push_down_claude_blast_radius_overlay.py:40` adds `except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback`. | Non-blocking | `python-suppressions.md` governs `# noqa` and `# type: ignore`; the Coverage Exclusion Policy prohibits file-level exclusions of production paths. A line-level pragma on the bundled-import fallback is covered by neither, and the same marker appears in eight existing `scripts/dev_tools` modules, including the #507 registry module. Recommended: record a repository-level decision on whether line-level `pragma: no cover` needs authorization. |
| G2 | `quality-tiers.yml` is absent from the repository. | Non-blocking, pre-existing | Not introduced by this branch. Tier-dependent gates were evaluated conservatively: property tests exist for both pure composition functions; mutation testing is a pre-merge or nightly gate and was not run in this review. |
| G3 | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` failed in the executor's rule-doc test run on a gitignored `.claude/state/` file. | Non-blocking, known environment condition (issue #510) | The failure names `.claude\state\python-batch-budget.worktree-...json`, which is not a branch file. The full pytest run at 19-19 completed with 0 failures. Rule-doc parity is proven by equal `git hash-object` values (`8eddadf58694694ccf3bce05ebee172039ddc68e`) for both copies, reconfirmed by the reviewer. |
| G4 | Orchestrator directives: branch `-exec-` suffix, per-phase commits overriding the plan's "No commits" convention, executor performing worker-tagged tasks directly, and recorded tool-routing substitutions. | Accepted, not a finding | Each directive is recorded in the evidence files ("Command actually executed", `D-COMMITS`). Outputs were independently re-verified by the reviewer with the same toolchain. |
| G5 | Operator decision 2026-09-29 (spec decision 3, amended AC23): the first push may overwrite an existing destination `config/blast-radius.json` with no migration step, preservation, warning, or migration documentation. | Accepted, required behavior | Reviewer `grep -n -i "migrat" .claude/rules/parallel-orchestration.md` returns no match. The absence of a migration note conforms to the decision. |
| G6 | Code-level Non-blocking findings NB-1 (TypeScript prototype-key membership), NB-2 (Python base described as "published"), NB-4 (`INPUT_RELATIVE_PATHS` not injectable), NB-5 (test file at the 500-line cap). | Non-blocking | Detailed in `code-review.2026-09-29T19-32.md`. |

## 9. Summary of Changes

- New `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts`: `composeBlastRadiusOverlay`, `BlastRadiusOverlayError`, `BLAST_RADIUS_OVERLAY_RELATIVE_PATH`, `BlastRadiusOverlayFileSystem`.
- `claude-customizations.ts`: `DestinationWriteDecorator` interface, `DESTINATION_WRITE_DECORATORS` registry, literal `MERGED_RELATIVE_PATHS`, overlay added to `EXCLUDED_RELATIVE_PATHS`, overlay re-exports, registry fold in `pushDownCustomizations`.
- `claude-routing-merge.ts`: module header comment only.
- `jest.config.cjs`: `coverageThreshold` entry for the overlay file (lines 85, branches 75).
- New `scripts/dev_tools/push_down_claude_blast_radius_overlay.py`: Python port of the composition.
- `push_down_claude_destination_writes.py`: `merge_blast_radius_overlay`, blast-radius registry entry, `INPUT_RELATIVE_PATHS`, `DestinationMerge`, `MERGED_PATHS`; `DestinationMergeFileSystem.write_text` reads the redirected input path.
- `push_down_claude_customizations.py`: overlay added to `EXCLUDED_RELATIVE_PATHS`.
- Tests: two new Jest files, three modified Jest files, two new pytest files, two modified pytest files, six JSON corpus fixtures.
- `.claude/rules/parallel-orchestration.md` and bundled mirror: overlay paragraph (byte-identical copies).
- Feature folder: `spec.md` (operator decision, AC check-off), `plan.2026-09-29T14-14.md` (task check-off), 55 evidence files.

## 10. Compliance Verdict

| Area | Verdict |
|---|---|
| General unit test policy | PASS |
| General code change policy | PASS |
| TypeScript language policy | PASS |
| Python language policy | PASS (G1 non-blocking) |
| Coverage (TypeScript) | PASS |
| Coverage (Python) | PASS |
| Coverage (PowerShell, C#) | N/A - zero changed files |
| Evidence location compliance | PASS |
| Tier classification | N/A - `quality-tiers.yml` absent repository-wide (G2, pre-existing) |

Overall: PASS. Blocking findings: 0.

## Appendix A: Test Inventory

| Test file | Status | Lines | Scope |
|---|---|---|---|
| `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay.test.ts` | new | 448 | AC01-AC07, AC11, AC12, AC18 |
| `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-parity.test.ts` | new | 69 | AC16 corpus (Jest side) |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | modified | 488 | AC08, AC09, AC10, AC12 |
| `extensions/drm-copilot/test/lib/push-down/claude-customizations.test.ts` | modified | 335 | AC13, AC17 |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | modified | 270 | Shared helpers |
| `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py` | new | 500 | AC01-AC08, AC11, AC12, AC14, AC18 |
| `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py` | new | 90 | AC11, AC16 |
| `tests/scripts/dev_tools/test_push_down_claude_destination_writes.py` | modified | 409 | Registry contents |
| `tests/scripts/dev_tools/test_push_down_claude_parity.py` | modified | 438 | #507 merged-path count updated to two |
| `tests/fixtures/blast_radius_overlay/*.json` | new (6) | 5 each | Shared composition corpus |

## Appendix B: Toolchain Commands Reference

| Purpose | Command |
|---|---|
| TypeScript format | `npx prettier --check <changed .ts/.cjs files>` (in `extensions/drm-copilot`) |
| TypeScript lint | `npx eslint <changed .ts files>` |
| TypeScript types | `npx tsc --noEmit -p .` |
| TypeScript tests | `node run-jest.cjs claude-blast-radius-overlay claude-config-carriage claude-customizations` |
| Python format | `poetry run black --check <changed .py files>` |
| Python lint | `poetry run ruff check <changed .py files>` |
| Python types | `poetry run pyright <changed .py files>` |
| Python tests | `poetry run pytest <overlay, overlay-parity, parity, destination-writes, customizations test files> -q -p no:cacheprovider` |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` |
| PR context refresh | `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/push-down-payload-correctness-integration --head HEAD` |
| Scope diff | `git diff --name-status origin/epic/push-down-payload-correctness-integration...HEAD` |
