# Policy Audit: parallel-skills-invoke-unbundled-python-clis (#763)

- Branch: `bug/parallel-skills-invoke-unbundled-python-clis-exec-763`
- Base: `origin/epic/push-down-payload-correctness-integration`, merge-base `12db46245ba7683b5d6ccb676312a4b22a39b0ce`
- Head reviewed: `416327768ff7cefe83c7f22bdfbad84971ddc90b`
- Work mode: `full-bug` (AC source: `spec.md` `## Acceptance Criteria`, 18 items)
- Reviewer: feature-review agent
- Timestamp: 2026-09-29T19-52

## Executive Summary

The branch ports the two unbundled Python CLIs invoked by pushed-down skills to destination-runtime entry points: radius drift detection to PowerShell (`.claude/lib/parallel-drift/`, three files) and the abandon disposition to bash (`.claude/lib/bash/abandon-parallel-item.sh`). Both SKILL invocations, the `parallel-orchestrator` agent allowlist, the pack manifest, bundle mirrors, and both Pester coverage allow-lists are updated, and the `#763` entries are removed from `KNOWN_UNBUNDLED_REFERENCES`.

Policy compliance is satisfied for every changed language on the changed-file criteria. No blocking finding was identified. Non-blocking findings are recorded in section 8, including one repo-wide PowerShell coverage figure (70.21% line) that is below the 85% threshold; that figure is produced by a three-folder subset Pester run, is pre-existing at baseline, and increased on this branch.

Blocking findings: 0. Non-blocking findings: 8.

Verdict: PASS (ready to merge).

## Scope Source and Assumptions

- `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in this worktree, and the `collect_pr_context` MCP tool is not exposed to this agent session. Scope was derived directly from `git diff --name-only 12db46245ba7683b5d6ccb676312a4b22a39b0ce HEAD` (153 files) and `git log` over the same range (13 commits). This is the same diff the PR-context collector would summarize.
- Commits after `0e41ad84` (`4c87951d`, `41632776`) change only files under the feature folder, so the Pester, pytest, Jest, and CI bats evidence recorded at `0e41ad84`/`4c87951d` applies to HEAD for all code files.

## Rejected Scope Narrowing

No scope narrowing was present in the caller prompt. The caller supplied the base branch and merge-base, which match the resolved merge-base of HEAD with `origin/epic/push-down-payload-correctness-integration`. The audit covers the full branch diff.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 80 evidence files are under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event was required.

## Changed Files by Language

| Language | Production files | Test / fixture files | Change type |
|---|---|---|---|
| PowerShell | `.claude/lib/parallel-drift/ParallelDrift.psm1` (A), `ParallelDriftHalt.psm1` (A), `Invoke-ParallelDriftDetection.ps1` (A), `.claude/hooks/enforce-parallel-abandon-gate.ps1` (M, comment-only), two `pester.runsettings.psd1` (M, data) | 5 new suites under `tests/scripts/claude-lib/parallel-drift/` | new + modified |
| Python | `scripts/dev_tools/skill_bundle_contract.py` (M), `scripts/dev_tools/skill_bundle_contract_cli.py` (M) | 2 new, 3 modified tests under `tests/scripts/dev_tools/` | modified |
| Bash | `.claude/lib/bash/abandon-parallel-item.sh` (A) | 2 new, 2 modified bats suites; 3 shims | new |
| TypeScript | none | none | none |
| Markdown / JSON | 2 SKILL.md, 1 agent, `core.json`, bundle mirrors, fixtures | 34 JSON fixtures | modified / new |

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Pester mocks are declared in `BeforeEach`/`It`; one test mutates `$script:CheckpointText` and restores it in `finally` (NB-4). Parametrized pytest and bats lanes read committed fixtures only. |
| Isolation | PASS | Pure-module suites target single functions; the entry script is dot-sourced behind its guard with the file-read and clock seams mocked. |
| Fast execution | PASS | Targeted pytest set: 228 tests in 1.20 s (reviewer run). Pester suites are in-process. |
| Determinism | PASS | Clock read only through `Get-ParallelDriftUtcNow` (mocked); fixtures supply both timestamps; no sleep or wall-clock API in any changed test (reviewer grep). |
| Readability | PASS | Arrange/Act/Assert comments and descriptive test names throughout. |
| No temporary files | PASS | Reviewer grep for `TestDrive`, `New-TemporaryFile`, `mktemp`, `tmp_path`, `BATS_*TMPDIR`, `Set-Content`, `Out-File`, `write_text` over all changed tests: 0 matches. Shims are checked-in fixtures. |
| Test location | PASS | Tests live under `tests/scripts/claude-lib/parallel-drift/`, `tests/scripts/dev_tools/`, and `tests/shell/`; none is colocated with production code. |

### 1.2 Coverage evidence checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript source or test file is in the branch diff.
- TypeScript post-change coverage artifact: N/A - no TypeScript source or test file is in the branch diff; push-down Jest regression 262 of 262 passed (`evidence/qa-gates/ts-push-down-jest.2026-09-29T19-13.md`).
- PowerShell baseline coverage artifact: `evidence/baseline/powershell-tests.2026-09-29T17-39.md` (JaCoCo from `artifacts/pester/powershell-coverage.xml` at BASE_SHA; hook 93.59% line).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (reviewer-parsed; new files 100.00% / 100.00% / 94.79% line, hook 93.59% line) and `evidence/qa-gates/powershell-test-coverage.2026-09-29T18-44.md`.
- Per-language comparison summary: `evidence/qa-gates/coverage-comparison.2026-09-29T19-13.md` plus reviewer re-parse of `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, and the CI `shell-coverage` artifact of run 36645685724.

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.59% (hook, the only pre-existing changed file). Post-change: 93.59% (hook). Change: 0.00 pp on the hook (comment-only edit); artifact-total line figure 70.21% (7862/11197 lines, 120 files) versus baseline command figure 69.57%, rising on this branch. Disposition: PASS for changed files and no regression; the artifact-total figure is below 85% and is recorded as non-blocking NB-1. New/changed-code coverage: 94.79% minimum (ParallelDriftHalt.psm1 100.00%, ParallelDrift.psm1 100.00%, Invoke-ParallelDriftDetection.ps1 94.79%). Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/powershell-test-coverage.2026-09-29T18-44.md`.
- Python: Baseline: 96.45% line / 95.00% branch (skill_bundle_contract.py), 92.98% line / 77.27% branch (skill_bundle_contract_cli.py). Post-change: 96.45% line / 95.00% branch and 93.10% line / 77.27% branch; lcov total 95.48% line / 90.24% branch. Change: +0.00 pp and +0.12 pp line, 0.00 pp branch. Disposition: PASS. New/changed-code coverage: 100% of changed executable lines covered (2 of 2). Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/python-test-coverage.2026-09-29T19-13.md`.
- Bash: Baseline: 93.3% (CI run 36636142693, kcov lines, repo-wide). Post-change: 93.4% (CI run 36645685724 at `4c87951d`, cov.xml line-rate 0.934, 2512/2690 lines). Change: +0.1 pp. Disposition: PASS. New/changed-code coverage: 94.6% (abandon-parallel-item.sh, reviewer re-read of the downloaded cov.xml). Evidence: CI artifact `shell-coverage` of run 36645685724, `evidence/qa-gates/shell-coverage-files.2026-09-29T19-13.md`.

### 1.3 Coverage metrics table

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 3 new, 1 modified (comment-only), 2 config | 5 new suites (100 tests) plus hook suites | 3914 passed, 1 failed (baseline), 1 skipped | 93.59% line (hook) | 93.59% line (hook); artifact total 70.21% | 100.00% / 100.00% / 94.79% line |
| Python | 2 modified | 2 new, 3 modified modules | 5287 passed, 1 failed (KL-510), 6 skipped | 96.45% / 92.98% line | 96.45% / 93.10% line; 95.00% / 77.27% branch | 100% of changed executable lines |
| Bash | 1 new | 2 new, 2 modified bats suites | 498 ok, 0 not ok (CI) | 93.3% line | 93.4% line | 94.6% line |
| TypeScript | 0 | 0 | N/A | N/A | N/A | N/A |

### 1.4 Coverage exclusion policy

- The three new PowerShell production files are added to `CodeCoverage.Path` in both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundle copy (byte-identical; verified with `cmp`). No `exclude` entry was added in any language. Verdict: PASS.

### 1.5 Scenario completeness

- Drift corpus: 18 fixtures covering every case listed under Test Strategy (verified by file names and by the `RequiredCase`/`REQUIRED_CASES` assertions in both lanes).
- Abandon corpus: 9 fixtures covering success, both refusals, gh failure, git failure, executable absent, unknown option, abbreviation, joined form.
- Negative, boundary, and error-handling cases are present in unit suites (for example non-integer `-ItemKey`, unrecognized parameter, non-object root, unserializable value, case-sensitive keys).
- Verdict: PASS.

## 2. General Code Change Policy Compliance

| Rule | Verdict | Evidence |
|---|---|---|
| Simplicity / separation of concerns | PASS | Pure logic in two `.psm1` modules; I/O (file read, clock, stdout/stderr, exit) confined to `Invoke-ParallelDriftDetection.ps1`; bash script is argument parsing plus two ordered side effects. |
| Reuse over re-implementation | PASS | `ParallelDrift.psm1` imports `.claude/lib/blast-radius/` and calls `Test-PathSubsumed`, `Get-BlastRadiusFromObservedPaths`, `Get-BlastRadiusPairDecision`, `Test-BlastRadiusConflict`, `ConvertTo-NormalizedBlastRadius`; `ParallelDrift.Tests.ps1` asserts none is redefined. |
| File size <= 500 lines | PASS | Largest changed code file: `ParallelDrift.psm1` 467 lines; `skill_bundle_contract.py` 486; `test_parallel_abandon_token_seam.py` 414 (reviewer `wc -l`). |
| Fail fast / explicit errors | PASS | Shape guards throw with field names; entry script maps data errors to exit 1 with a fixed prefix and usage errors to exit 2; bash refusals precede side effects. |
| No broad silent catch | PASS | The one `catch` in `Test-ParallelDriftObservedPairEdge` returns `$true` (fail closed), mirroring the Python `TypeError`/`ValueError` handler, with a comment. The entry-script catch converts to exit 1 with the message. |
| Naming | PASS | Approved-verb PowerShell names; snake_case Python; `abandon_*` bash functions. |
| Public API compatibility | PASS | `skill_bundle_contract_cli.main` gains a keyword-only `exceptions` parameter with a default (spec D5); no caller breaks. |
| Dependencies | PASS | No new package; `System.Text.Json` ships with PowerShell 7. |
| Constrained files untouched | PASS | Branch diff lists none of `.claude/hooks/enforce-powershell-batch-budget.ps1` or its tests, `scripts/dev_tools/push_down_claude_customizations.py`, `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, `.claude/settings.json`, `.github/**`, `.codex/**`, `.agents/**`. |
| Enforcement hooks gain no Python leg | PASS | Hook edit is comment-only (lines 27-31); `enforcement-hooks-no-python-invocation.Tests.ps1` 27/27 passed with the new `.claude/lib` files in scope. |

## 3. Language-Specific Code Change Policy Compliance

### PowerShell (`.claude/rules/powershell.md`)

- `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` in all three files: PASS.
- Comment-based help on every function; `[CmdletBinding()]` and `[OutputType()]` declared: PASS.
- Rule suppressions: two localized `PSUseLiteralInitializerForHashtable` suppressions, one in `Invoke-ParallelDriftDetection.ps1` (`ConvertFrom-ParallelDriftJsonElement`) and one in `ParallelDrift.Tests.ps1`, each with a justification. The rule flags every ordinal-comparer hashtable construction, and case-sensitive JSON keys are a spec requirement (D1). Verdict: PASS (strictly necessary and localized, as the rule requires). Executor deviation 3 accepted.
- `Mandatory` attribute: omitted on the entry script by design (spec D1: a Mandatory parameter prompts under `pwsh -File`); used on internal module functions. PASS.
- PSScriptAnalyzer: 0 diagnostics after loop pass 3 (`evidence/qa-gates/powershell-analyze.2026-09-29T18-44.md`).

### Python (`.claude/rules/python.md`)

- Black `--check`: 7 files unchanged; Ruff: all checks passed; Pyright: 0 errors, 0 warnings (reviewer re-run over the 7 changed Python files). PASS.
- No new `# type: ignore`, `# noqa`, or `pyright: ignore` introduced; the two `pyright: ignore[reportPrivateUsage]` lines in `test_parallel_abandon_token_seam.py` pre-date the branch. PASS.

### Bash (`.claude/rules/shell.md`)

- `set -euo pipefail`; functions documented with argument comments; shfmt diff exit 0 and shellcheck exit 0 (`evidence/qa-gates/shell-lint.2026-09-29T18-44.md`). PASS.

### TypeScript

- N/A - no TypeScript file changed.

## 4. Language-Specific Unit Test Policy Compliance

| Language | Verdict | Evidence |
|---|---|---|
| PowerShell (Pester) | PASS | 100 new tests across 5 suites, all passing; mocks of the read and clock seams; `Should -Invoke` asserts the clock read count; AST-based assertion that no parameter is `Mandatory`. |
| Python (pytest) | PASS | Parity lanes parametrized over committed corpora with floor and required-name assertions (fail on an empty corpus); injected runner for the abandon reference; `monkeypatch` of the read seam for the drift CLI. |
| Bash (bats) | PASS | Shim-only `PATH`; argv recorded on stderr; ordering, exit codes, and exact messages asserted; payload-only case runs the bundle copy under `env -i` with no interpreter on `PATH`. |

## 5. Test Coverage Detail

| File | Tool | Covered / total | Line % | Threshold | Verdict |
|---|---|---|---|---|---|
| `.claude/lib/parallel-drift/ParallelDriftHalt.psm1` | Pester JaCoCo | 67 / 67 | 100.00% | >= 85% | PASS |
| `.claude/lib/parallel-drift/ParallelDrift.psm1` | Pester JaCoCo | 123 / 123 | 100.00% | >= 85% | PASS |
| `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` | Pester JaCoCo | 91 / 96 | 94.79% | >= 85% | PASS |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | Pester JaCoCo | 73 / 78 | 93.59% | no regression | PASS |
| `scripts/dev_tools/skill_bundle_contract.py` | coverage.py lcov | 136 / 141 (branch 57/60) | 96.45% (branch 95.00%) | >= 85% / >= 75% | PASS |
| `scripts/dev_tools/skill_bundle_contract_cli.py` | coverage.py lcov | 54 / 58 (branch 17/22) | 93.10% (branch 77.27%) | >= 85% / >= 75% | PASS |
| `.claude/lib/bash/abandon-parallel-item.sh` | kcov (CI) | line-rate 0.946 | 94.6% | >= 85% | PASS |

Pester and kcov measure no branch coverage; no branch threshold applies to PowerShell or bash. The five uncovered lines in `Invoke-ParallelDriftDetection.ps1` are the guarded process entry block (lines 330-336), which dot-sourced tests do not execute; its process behavior is recorded in `evidence/regression-testing/drift-process-smoke.2026-09-29T18-00.md`.

## 6. Test Execution Metrics

| Suite set | Total | Passed | Failed | Skipped | Source |
|---|---|---|---|---|---|
| Pester (claude-lib, claude-hooks, claude-runtime) | 3916 | 3914 | 1 (baseline: `enforce-pr-author-skill.Tests.ps1`) | 1 | `artifacts/pester/pester-junit.xml` (reviewer-parsed) |
| New drift Pester suites | 100 | 100 | 0 | 0 | same |
| pytest full `tests/scripts/dev_tools` | 5294 | 5287 | 1 (KL-510 state-only) | 6 | `evidence/qa-gates/python-regression.2026-09-29T19-13.md` |
| pytest targeted AC set (reviewer run) | 228 | 227 | 1 (KL-510 state-only) | 0 | reviewer run at HEAD |
| bats (CI, all suites) | 498 | 498 | 0 | 0 | CI run 36645685724 |
| Jest push-down | 262 | 262 | 0 | 0 | `evidence/qa-gates/ts-push-down-jest.2026-09-29T19-13.md` |

Both failures are members of the pre-existing baseline failure set declared by the caller and recorded at P0.

## 7. Code Quality Checks

| Stage | PowerShell | Python | Bash | TypeScript |
|---|---|---|---|---|
| Format | PASS (PoshQC, 0 changed) | PASS (Black, reviewer) | PASS (shfmt) | N/A |
| Lint | PASS (PSSA 0) | PASS (Ruff, reviewer) | PASS (shellcheck) | N/A |
| Type check | N/A (PowerShell) | PASS (Pyright 0, reviewer) | N/A (bash) | N/A |
| Architecture boundaries | PASS (module imports only sibling and blast-radius modules) | N/A | N/A | N/A |
| Unit tests | PASS (baseline failure only) | PASS (KL-510 only) | PASS | PASS (Jest regression) |
| Contract checks | PASS (manifest byte identity, surface contracts, token seam) | PASS | PASS | PASS |

Tier: per spec D8 the new modules are treated as T3; `quality-tiers.yml` does not exist in this tree. T3 imposes no property-test or mutation obligation. The PowerShell `[object]` parameters are deliberate shape-guard inputs that mirror the Python reference's runtime validation and are not an `any`/`dynamic` escape hatch as defined for TypeScript and C#.

## 8. Gaps and Exceptions

All items below are Non-blocking.

- NB-1 (coverage, pre-existing): The Pester artifact total is 70.21% line (7862 of 11197 lines across 120 registered files) because the executor ran three test folders (`claude-lib`, `claude-hooks`, `claude-runtime`). 26 registered files, all outside this diff (`.codex/hooks/*`, `scripts/dev-tools/Invoke-*Release*.ps1`, `scripts/powershell/PoshQC/*`), report 0% in that run because their suites were not selected. The baseline run of the same folders reported 69.57%. The figure is not attributable to this branch and rose on it. A full-suite Pester coverage run is required to measure the true repo-wide PowerShell figure; recorded as a follow-up.
- NB-2 (evidence scope): The Python lcov artifact covers the two changed modules only (95.48% line, 90.24% branch). A repo-wide Python coverage figure was not produced on this branch; the full `tests/scripts/dev_tools` run was executed without coverage.
- NB-3 (spec divergence, declared DV7): a trailing `-ItemKey` with no value is rejected by the PowerShell binder and exits 1 rather than 2; a changed path beginning with `-` is rejected as a usage error.
- NB-4 (test hygiene): one Pester test mutates script-scoped `$script:CheckpointText` and restores it in `finally`.
- NB-5 (guard defect, DV9 / FU-763-5): the skill-bundle guard's invocation regex consumes a fence info-string word; the `parallel-remove` fence was changed from `bash` to `shell` as a workaround. The regex itself is unchanged.
- NB-6 (residual portability, spec D7): `parallel-remove` steps 2, 3, and 6 still reference `scripts/dev_tools/parallel_mutation_protocol.py`; consumers still require Python for those steps.
- NB-7 (spec D4/D6 follow-ups): the `Bash(poetry run python -m *)` and `-c *` grants remain without a named consumer, and `.claude/settings.json` has no allow entry for the abandon script.
- NB-8 (process-level contract): the drift entry script's process behavior under `pwsh -NoProfile -NonInteractive -File` is recorded by a one-time smoke run rather than an automated test.

Executor-reported deviations, evaluated:

1. One `Co-Authored-By` trailer on commits after `b9fc1594`: consistent with the current harness attribution instruction. Accepted.
2. Stderr prefix in double quotes in `parallel-orchestrate/SKILL.md`: required because `test_parallel_orchestrator_permission_contracts.py` treats a multi-word lowercase code span as a command. Meaning and line count unchanged. Accepted.
3. Two justified `PSUseLiteralInitializerForHashtable` suppressions: accepted (section 3).
4. Glob pathspec spellings (`parallel_ba?h_parity.py`, `.../gi?`) in evidence command text: used to avoid a text-match false positive in the worktree isolation guard; each glob matched exactly one file per the evidence. Read-only use; accepted.
5. Extra batch-budget reset in P8: reset evidence exists; `.claude/hooks/enforce-powershell-batch-budget.ps1` and its tests are not in the diff. Accepted.

Pre-existing failures (not attributable to this branch): `enforce-pr-author-skill.Tests.ps1` "allows gh pr create --body-file ..." case; KL-510 `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (gitignored `.claude/state/*` file). Both reproduced with identical messages.

## 9. Summary of Changes

- Added `.claude/lib/parallel-drift/{ParallelDrift.psm1, ParallelDriftHalt.psm1, Invoke-ParallelDriftDetection.ps1}` and `.claude/lib/bash/abandon-parallel-item.sh`, each with a byte-identical bundle copy.
- Updated `parallel-orchestrate` and `parallel-remove` SKILL invocations and prose; `parallel-orchestrator` agent allowlist gains two entries; hook docstring names the new producer.
- `core.json` lists the four new files; both `pester.runsettings.psd1` allow-lists register the three PowerShell files.
- `KNOWN_UNBUNDLED_REFERENCES` is empty; `skill_bundle_contract_cli.main` accepts an injectable `exceptions` registry.
- Added two shared corpora (18 drift, 9 abandon fixtures), two-lane parity suites, unit suites, shims, and payload-only coverage.

## 10. Compliance Verdict

| Area | Verdict |
|---|---|
| General unit test policy | PASS |
| General code change policy | PASS |
| PowerShell | PASS (repo-wide artifact figure recorded as NB-1) |
| Python | PASS |
| Bash | PASS |
| TypeScript | N/A (no changed files) |
| Evidence locations | PASS |
| Constrained files | PASS |

Blocking findings: 0. Overall: PASS - ready to merge.

## Appendix A: Test Inventory

| Test file | Framework | Status | Tests |
|---|---|---|---|
| `tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1` | Pester | new | 28 |
| `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1` | Pester | new | 26 |
| `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1` | Pester | new | 5 |
| `tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1` | Pester | new | 21 |
| `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1` | Pester | new | 20 |
| `tests/scripts/dev_tools/test_parallel_drift_parity.py` | pytest | new | parametrized over 18 fixtures |
| `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py` | pytest | new | parametrized over 9 fixtures |
| `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` | pytest | modified | four-way extraction plus guard extraction |
| `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py` | pytest | modified | stale and suppression branches via injected registry |
| `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py` | pytest | modified | empty-registry assertion |
| `tests/shell/parallel_abandon.bats` | bats | new | 14 |
| `tests/shell/parallel_abandon_parity.bats` | bats | new | 3 |
| `tests/shell/parallel_payload_only.bats` | bats | modified | +3 |
| `tests/shell/parallel_bash_manifest_membership.bats` | bats | modified | entry-point list +1 |

## Appendix B: Toolchain Commands Reference

Reviewer-executed (check-only):

- `poetry run pytest -q -p no:cacheprovider <15 AC-related test modules>` -> 227 passed, 1 failed (KL-510).
- `poetry run black --check`, `poetry run ruff check --no-cache`, `poetry run pyright` over the 7 changed Python files -> clean.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` -> exit 0.
- `rg -n "python3?\s+(-m\s+)?scripts[./]dev_tools[./]parallel_(drift_detection|mutation_abandon)_cli" .claude extensions/drm-copilot/resources/claude-customizations/.claude` -> no match (exit 1).
- `cmp` of every new or edited `.claude/**` file against its bundle copy -> 8 of 8 identical; runsettings pair identical.
- JaCoCo parse of `artifacts/pester/powershell-coverage.xml`; JUnit parse of `artifacts/pester/pester-junit.xml`; `gh run download 36645685724 -n shell-coverage` and parse of `cov.xml`.

Executor-recorded (evidence folder): PoshQC format/analyze/test, `shfmt`/`shellcheck`, local bats via `npx bats`, CI `_shell-coverage.yml`, Jest push-down suite.
