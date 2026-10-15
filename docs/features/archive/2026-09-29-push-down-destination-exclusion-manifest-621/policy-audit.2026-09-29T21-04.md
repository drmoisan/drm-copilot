# Policy Audit — Push-down destination exclusion manifest (#621)

- Feature folder: `docs/features/active/2026-09-29-push-down-destination-exclusion-manifest-621/`
- Branch: `feature/push-down-destination-exclusion-manifest-exec-621` @ `5fa4a4dd`
- Base: `origin/epic/push-down-payload-correctness-integration` @ `57fe96c2` (merge base `57fe96c2`)
- Work mode: `full-feature` (AC sources `spec.md`, `user-story.md`)
- Audit timestamp: 2026-09-29T21-04
- Reviewer: feature-review agent
- PR context: regenerated for this review (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, head `5fa4a4dd`, range `57fe96c2..5fa4a4dd`); the artifacts were absent at review start.

## Executive Summary

The branch adds a destination-owned exclusion manifest (`.push-down-exclusions`) to the Python and TypeScript Claude push-down implementations: two new production modules per language, edits to both entry points, the TypeScript service call and VS Code command, a shared JSON corpus, and tests. The review scope is the full three-dot diff against the PR base (75 files, 5464 insertions, 133 deletions; 25 non-documentation files).

All uniform gates pass on the reviewer's re-run: Black, Ruff, Pyright, Prettier, ESLint, and TSC are clean for every changed file; the feature test suites pass (Python 457 selected push-down tests passed with one known environmental failure, TypeScript 112 of 112). Coverage for every new and changed file is at or above 85% line and 75% branch in both languages, with no regression against the Phase 0 baseline. No changed file exceeds 500 lines. No test creates a temporary file. No non-goal path is modified.

Verdict: **PASS with Non-blocking findings.** No Blocking finding was identified. Thirteen Non-blocking findings (G-1 to G-13) are recorded in section 8 and in the code review.

## Rejected Scope Narrowing

None detected. The caller supplied the PR base branch (`origin/epic/push-down-payload-correctness-integration`), which is the authoritative base for this feature; the review scope was not narrowed to a plan, phase, or file subset. The caller's list of seven executor-reported deviations was treated as additional review focus, not as a scope limit.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 38 evidence files are under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Result: PASS.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence, isolation, determinism | PASS | Every test builds its own in-memory filesystem (`ObservingFileSystem`, `buildInMemoryFileSystem`, `seedTree`); no shared mutable state observed. |
| No temporary files | PASS | Grep over the seven new or changed test files for `tempfile`, `mkdtemp`, `tmp_path`, `tmpdir`, `os.tmpdir`, `NamedTemporary`, `mkdtempSync`, `writeFileSync`, `open(` returned zero matches. Corpus files are committed fixtures read with `read_text` / `readFileSync`. |
| Arrange-Act-Assert structure | PASS | TypeScript tests carry explicit `// Arrange`, `// Act`, `// Assert` markers; Python tests follow the same layout with docstrings. |
| Scenario completeness (positive, negative, edge, error) | PASS | Malformed-manifest set (8 conditions), write guard, absent manifest, empty manifest, CRLF/BOM, shadowed entries, pack-excluded paths. |
| Seeded RNG with seed printed on failure | PASS | Python `SEEDS = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]` with `seed=` in every assertion message and case id; TypeScript `SeededRandom` with `seed` in every compared object. |
| Test location mirrors source tree | PASS | `tests/scripts/dev_tools/...` and `extensions/drm-copilot/test/lib/push-down/...`; no colocated tests. |
| Coverage exclusion policy | PASS | `jest.config.cjs` diff adds per-file `coverageThreshold` entries only; no `exclude` entry for a production path. |

### 1.1 Coverage Evidence Checklist

- Python baseline coverage artifact: `evidence/baseline/phase0-python-pytest-coverage.2026-09-29T20-00.md` (coverage.json totals 15592/16717 lines = 93.27%, 5213/6048 branches = 86.19%)
- Python post-change coverage artifact: `artifacts/python/coverage.json` and `artifacts/python/lcov.info` (written 2026-09-29 20:51; 15810/16936 lines = 93.35%, 5270/6106 branches = 86.31%), summarized in `evidence/qa-gates/python-coverage-delta.2026-09-29T20-52.md`
- TypeScript baseline coverage artifact: `evidence/baseline/phase0-ts-jest-coverage.2026-09-29T20-00.md` (per-file LF/LH/BRF/BRH for the four pre-existing changed files; aggregate 98.51% line, 90.06% branch)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (written 2026-09-29 20:53; repo-wide 49780/51304 lines = 97.03%, 7211/7909 branches = 91.17%), summarized in `evidence/qa-gates/typescript-coverage-delta.2026-09-29T20-54.md`
- PowerShell baseline coverage artifact: N/A — the branch diff contains zero PowerShell files.
- PowerShell post-change coverage artifact: N/A — the branch diff contains zero PowerShell files.
- Per-language comparison summary: Python and TypeScript both PASS; see section 1.2.1. PowerShell and C# have zero changed files.

### 1.2 Coverage Metrics Table

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 3 production, 3 test, 3 fixtures | 3 new modules | PASS | 93.27% line / 86.19% branch | 93.35% line / 86.31% branch | 97.92% line / 95.45% branch |
| TypeScript | 6 production, 7 test, 1 config | 3 new suites, 3 extended | PASS | 98.51% line / 90.06% branch | 98.61% line / 91.30% branch | 98.94% line / 93.69% branch |
| PowerShell | 0 | 0 | N/A | N/A | N/A | N/A |

The TypeScript baseline and post-change columns are the aggregate of the four pre-existing changed files, because the Phase 0 evidence records per-file values rather than a repo-wide TypeScript baseline. The post-change repo-wide TypeScript value is 97.03% line / 91.17% branch.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.27% line / 86.19% branch (repo-wide, coverage.json). Post-change: 93.35% line / 86.31% branch. Change: +0.08 line points, +0.12 branch points. New/changed-code coverage: 97.92% line / 95.45% branch across the three changed modules (manifest 100.00%/100.00%, filter 99.00%/93.75%, entry point 94.05%/87.50%, entry point up from 92.75%/75.00%; zero changed entry-point lines uncovered). Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/python-coverage-delta.2026-09-29T20-52.md`, reviewer lcov parse 2026-09-29T21-04.
- TypeScript: Baseline: 98.51% line / 90.06% branch (four pre-existing changed files). Post-change: 98.61% line / 91.30% branch (same four files); repo-wide 97.03% line / 91.17% branch. Change: +0.10 line points, +1.24 branch points; no file below its baseline. New/changed-code coverage: 98.94% line / 93.69% branch across the six new or changed files (manifest 100.00%/100.00%, filter 99.41%/95.74%, entry 100.00%/96.83%, service call 100.00%/96.43%, engine 97.99%/84.31%, command 96.90%/89.23%). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/qa-gates/typescript-coverage-delta.2026-09-29T20-54.md`, reviewer lcov parse 2026-09-29T21-04.

Coverage artifact currency: both post-change artifacts were written before merge commit `5fa4a4dd` (20:57). `git diff --name-only 9d69a6ec 5fa4a4dd` over the feature's production files, `_blast_radius_glob.py`, `push_down_copilot_customizations.py`, and `jest.config.cjs` returned no paths, so the per-file figures remain representative of HEAD. Repo-wide figures reflect the pre-merge tree.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| File size limit (500 lines) | PASS | Largest files: `push_down_claude_customizations.py` 499, `claude-customizations.ts` 496, `claude-exclusion-manifest.test.ts` 492. See code review CR-01 for headroom. |
| Separation of concerns | PASS | Pure parse/match/plan modules (`push_down_exclusion_manifest.py`, `claude-exclusion-manifest.ts`) perform no I/O; the filter modules hold the adapter-facing decorator and reporting. |
| Fail fast | PASS | `ExclusionManifestError` raised on read, before decorator construction and any write; module-load assertion `assert_manifest_path_is_root_level`. |
| No new dependencies | PASS | No change to `package.json`, `package-lock.json`, or dependency sections of `pyproject.toml`; the only `pyproject.toml` change is a Ruff `S311` per-file ignore for the seeded property test. |
| Reusability | PARTIAL (Non-blocking) | TypeScript repeats the first-match and "claimed entry" logic in three places; see CR-04. |
| Mandatory toolchain loop | PASS | Executor evidence `final-toolchain-single-pass.2026-09-29T20-55.md`; reviewer re-run of format, lint, type check, and targeted tests is clean. |
| Non-goal paths unchanged | PASS | Three-dot diff contains no path under `.claude/`, no `package*.json`, no `push_down_copilot_customizations.py`, `push_down_claude_filesystem.py`, or `claude-filesystem-adapter.ts`. |

## 3. Language-Specific Code Change Policy Compliance

### Python

| Requirement | Verdict | Evidence |
|---|---|---|
| Black | PASS | `black --check` on six changed `.py` files: "6 files would be left unchanged." |
| Ruff | PASS | "All checks passed!" |
| Pyright | PASS | "0 errors, 0 warnings, 0 informations" |
| Type annotations and docstrings | PASS | All public functions typed; frozen slotted dataclasses; docstrings with Args/Returns/Raises on public API. |
| Bundled-import fallback pattern | PASS | Both new modules use `try: from scripts.dev_tools... except ModuleNotFoundError` with the `error.name` guard. |

### TypeScript

| Requirement | Verdict | Evidence |
|---|---|---|
| Prettier | PASS | `prettier --check` on 14 changed files, exit 0. |
| ESLint | PASS | exit 0, no problems. |
| TSC | PASS | `tsc --noEmit -p .` exit 0. |
| No `any` | PASS | No `any` in the new modules; `unknown` with narrowing in `appendExclusionsToArtifact`. |
| Per-file coverage thresholds | PASS | Six `coverageThreshold` entries (85/75) added in `jest.config.cjs`. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Python pytest with in-memory fakes | PASS | `RecordingFileSystem` / `ObservingFileSystem`; no disk I/O except reading committed corpora. |
| Jest with in-memory adapter | PASS | `buildInMemoryFileSystem`, `seedTree`, `jest.spyOn` for read observation; stubbed `showWarningMessage`. |
| Property-style tests without new dependency | PASS | Five seeded properties per language (exact, directory equivalence, star separator, normalization idempotence, plan partition). See CR-02 for the idempotence domain. |
| Parity corpus with count assertions | PASS | Python asserts 18 / 14 / 9 cases; TypeScript `toHaveLength(18/14/9)`. |

## 5. Test Coverage Detail

| File | Status | Line | Branch | Threshold |
|---|---|---|---|---|
| scripts/dev_tools/push_down_exclusion_manifest.py | new | 100.00% | 100.00% | PASS |
| scripts/dev_tools/push_down_claude_exclusion_filter.py | new | 99.00% | 93.75% | PASS |
| scripts/dev_tools/push_down_claude_customizations.py | modified | 94.05% (base 92.75%) | 87.50% (base 75.00%) | PASS |
| src/lib/push-down/claude-exclusion-manifest.ts | new | 100.00% | 100.00% | PASS |
| src/lib/push-down/claude-exclusion-filter.ts | new | 99.41% | 95.74% | PASS |
| src/lib/push-down/claude-customizations.ts | modified | 100.00% (base 100.00%) | 96.83% (base 95.74%) | PASS |
| src/lib/push-down/push-down-service-call.ts | modified | 100.00% (base 100.00%) | 96.43% (base 95.65%) | PASS |
| src/lib/push-down/copilot-customizations-engine.ts | modified | 97.99% (base 97.99%) | 84.31% (base 84.31%) | PASS |
| src/repo-automation-command-registration-admin.ts | modified | 96.90% (base 96.80%) | 89.23% (base 88.33%) | PASS |

Uncovered lines in the entry point (`push_down_claude_customizations.py` 130-133, 139) are the pre-existing bundled-import fallback. Uncovered lines 330-331 of `claude-exclusion-filter.ts` and line 330 of `push_down_claude_exclusion_filter.py` are the non-object artifact error branch.

## 6. Test Execution Metrics

| Suite | Command | Result |
|---|---|---|
| Python push-down tests (reviewer) | `poetry run pytest -q tests/scripts/dev_tools/ -k push_down` | 457 passed, 1 failed (issue #510 environmental, see G-4) |
| Python full suite (executor) | `evidence/qa-gates/final-python-pytest-coverage.2026-09-29T20-51.md` | 5661 passed, 6 skipped, 0 failed |
| TypeScript feature suites (reviewer) | `npx jest --coverage=false` over the 6 changed suites | 6 suites, 112 tests passed |
| TypeScript full suite (executor) | `evidence/qa-gates/final-ts-jest-coverage.2026-09-29T20-53.md` | 3315 passed, no threshold failure |

## 7. Code Quality Checks

| Check | Python | TypeScript |
|---|---|---|
| Format | PASS | PASS |
| Lint | PASS | PASS |
| Type check | PASS | PASS |
| Architecture boundary | PASS (no new cross-layer import; filter imports engine summary type only) | PASS (dependency direction manifest <- filter <- entry <- service <- command) |
| Contract / schema | PASS (artifact schema extended by one optional key; MCP schema unchanged) | PASS |

## 8. Gaps and Exceptions

All items below are Non-blocking.

- G-1 (process) Python entry-point edit applied through a Python script rather than the Edit tool, so `enforce-python-batch-budget.ps1` did not record it. The plan's three-production / three-test Python budget was respected (production: `push_down_claude_customizations.py`, `push_down_claude_exclusion_filter.py`, `push_down_exclusion_manifest.py`; tests: three new test modules). Writing a governed file through an unobserved route defeats the hook's accounting even when the budget holds; future runs should use the governed tool path or record the route in evidence before use.
- G-2 (process) Plan rule 4 ("no commits") superseded by the caller's per-phase commit instruction. Substitute evidence for [P9-T5] (`git diff <anchor> --name-status --diff-filter=A`) is sound: the reviewer's three-dot re-run against the current base lists exactly the 14 planned added files. Substitute evidence for [P9-T1] (pinned-anchor and three-dot diffs after the base moved with #763) is sound: the reviewer's three-dot changed-file list contains no guarded path.
- G-3 (process) Tasks marked for `typescript-engineer` handoff were performed by the executor, and PowerShell-named plan commands were replaced by POSIX / Python equivalents. The reviewer's re-run of the TypeScript toolchain is clean; no quality gap attributable to either substitution was found.
- G-4 (environment) `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails locally on the gitignored `.claude/state/python-batch-budget.<session>.json` (issue #510). Reproduced by the reviewer with the same assertion; `git check-ignore` confirms the path is ignored (`.gitignore:68`). The executor's move-aside with identical SHA-256 before and after is a sound handling. The failure does not originate in this branch.
- G-5 (evidence) Evidence file-name timestamps mix UTC (`2026-09-30T00-xx`) and local time (`2026-09-29T20-xx`); the executor documented this in `final-toolchain-single-pass.2026-09-29T20-55.md`. Ordering is recoverable from commits.
- G-6 (evidence) The AC-12 and AC-13 regression tests compare the absent-manifest artifact with the engine's own rendering (TypeScript) or its key set (Python), not with a captured pre-change artifact. The claim holds structurally (no decorator constructed, engine code unchanged, single artifact write asserted), but the tests would not detect a change in the engine itself.
- G-7 through G-13: code-level Non-blocking findings CR-01 to CR-07 in `code-review.2026-09-29T21-04.md` (line-count headroom, normalization idempotence domain, inaccurate Python comment, TypeScript duplication, write-guard path normalization, notification derived from rendered text, U+FFFD parity asymmetry).
- The untracked `.claude/agent-memory/atomic-executor/` directory is gitignored (`.gitignore:67`) and does not appear in the branch diff.

## 9. Summary of Changes

- New Python: `scripts/dev_tools/push_down_exclusion_manifest.py` (343), `scripts/dev_tools/push_down_claude_exclusion_filter.py` (346).
- New TypeScript: `src/lib/push-down/claude-exclusion-manifest.ts` (343), `src/lib/push-down/claude-exclusion-filter.ts` (337).
- Modified: `push_down_claude_customizations.py` (+56/-4), `claude-customizations.ts` (+82/-5), `copilot-customizations-engine.ts` (`export` on `stringifySorted`), `push-down-service-call.ts` (+13), `repo-automation-command-registration-admin.ts` (+15/-1), `jest.config.cjs` (+26), `pyproject.toml` (+1), `README.md` (+26).
- Fixtures: `tests/fixtures/push_down_exclusions/{matcher,manifest,plan}-corpus.json`.
- Tests: three new Python modules, three new TypeScript suites plus a seeded-RNG helper, three extended TypeScript suites.

## 10. Compliance Verdict

**PASS.** Uniform gates (format, lint, type, tests, coverage >= 85% line / >= 75% branch on new and changed files, no regression, 500-line cap, no temp files, no new dependency, evidence locations) pass for both in-scope languages. No Blocking finding. Non-blocking findings G-1 to G-13 are recommended follow-ups and do not gate merge.

## Appendix A: Test Inventory

| Test file | Language | Scope |
|---|---|---|
| tests/scripts/dev_tools/test_push_down_exclusion_manifest.py | Python | parser, normalizer, matcher, plan, malformed set, 5 seeded properties |
| tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py | Python | read, skip, conflict, unmatched, write guard, routing exclusion, artifact, CLI lines, outermost composition |
| tests/scripts/dev_tools/test_push_down_claude_exclusion_parity.py | Python | matcher, manifest, and plan corpora with count assertions |
| extensions/drm-copilot/test/lib/push-down/claude-exclusion-manifest.test.ts | TypeScript | parser, normalizer, matcher, plan, 5 seeded properties |
| extensions/drm-copilot/test/lib/push-down/claude-exclusion-filter.test.ts | TypeScript | filter, gitignore, routing and blast-radius isolation, artifact identity, composition |
| extensions/drm-copilot/test/lib/push-down/claude-exclusion-parity.test.ts | TypeScript | shared corpora with count assertions |
| extensions/drm-copilot/test/lib/push-down/push-down-service-call.test.ts | TypeScript | warnings and log sink |
| extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts | TypeScript | MCP warnings pass-through |
| extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts | TypeScript | conflict notification |

## Appendix B: Toolchain Commands Reference

| Stage | Command |
|---|---|
| Python format | `poetry run black --check <six changed .py files>` |
| Python lint | `poetry run ruff check <six changed .py files>` |
| Python types | `poetry run pyright <six changed .py files>` |
| Python tests | `poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/ -k push_down` |
| TS format | `npx prettier --check <14 changed files>` (from `extensions/drm-copilot`) |
| TS lint | `npx eslint <13 changed .ts files>` |
| TS types | `npx tsc --noEmit -p .` |
| TS tests | `npx jest --coverage=false test/lib/push-down/claude-exclusion test/lib/push-down/push-down-service-call.test.ts test/mcp-tools.push-down-claude.test.ts test/repo-automation-command-registration-admin.test.ts` |
| Coverage parse | reviewer lcov parser over `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` (no regeneration) |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` |
| PR context | `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/push-down-payload-correctness-integration` |
