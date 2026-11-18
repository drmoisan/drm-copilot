# Self-review - issue #1201 release-commit allowance leg

Timestamp: 2026-11-18T01-11
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against `git diff --name-status <merge base of origin/main and HEAD> HEAD` (35 files outside the feature folder) plus the uncommitted Phase 3 evidence files
EXIT_CODE: 0
Output Summary: no FAIL row. Every row is PASS or N/A with the reason stated.

## Policy audit template

| Checklist item | Result | Evidence |
|---|---|---|
| 1.1 Independence | PASS | Each row registers its own mocks in the It (Pester scoping); no shared mutable state beyond per-row `$script:` values written before use; suites ran inside eight parallel shards with zero failures. |
| 1.1 Isolation | PASS | Pure unit table (hook-release-allowance-context.Tests.ps1), seam and entry suite, gate decision suites, and parity suite each target one unit. |
| 1.1 Fast execution | PASS | The two decision suites (204 tests) completed in 117.85 s of shard wall-clock including module loading; no sleep or wait. |
| 1.1 Determinism | PASS | No clock, randomness, network, process, or real file read; synthetic root /synthetic-worktrees/release; the only real-file reads are committed repository files in the parity suite. |
| 1.1 Readability | PASS | Row ids name the acceptance criterion (AC8-..., AC15-...); Arrange/Act/Assert comments in every It. |
| 1.2 Baseline coverage documented | PASS | evidence/baseline/pester.2026-11-17T20-55.md, pytest.2026-11-17T21-03.md, jest-extension.2026-11-17T21-03.md. |
| 1.2 No coverage regression | PASS | evidence/qa-gates/coverage-comparison.2026-11-18T01-05.md and coverage-comparison.2026-11-18T01-10.md: no per-file or repo-wide drop. |
| 1.2 Changed files meet thresholds | PASS | Claude gate 96.61%, Codex gate 100%, claude-customizations.ts 100% lines / 96.82% branches, push_down_claude_customizations.py 93.67% / 87.50%. |
| 1.2 New code coverage >= 90% | PASS | New hook files 171/171 and 32/32 (100%) on both measured surfaces; both new gate lines covered (169/175 -> 171/177, the 6 uncovered lines pre-existing). |
| 1.2 Comprehensive coverage | PASS | Every function of both new files is exercised; per-file 100% line coverage. |
| 1.2 Positive flows | PASS | AC-1 valid document, AC-2 matches, AC-8 to AC-11 allow rows on both surfaces. |
| 1.2 Negative flows | PASS | 41 parser rejections, AC-12 to AC-17 denial rows, segment-shape rejections. |
| 1.2 Edge cases | PASS | Case-variant and trailing-slash `-C` roots, trailing `;`, empty segment `""`, `git add -- -A`, ordinal `Package.json`, missing option values. |
| 1.2 Error handling | PASS | Config read and container probe failures (CONFIG_INVALID), AC-20 throwing branch and staged readers (PREIMPL_RELEASE_LEG_ERROR via Write-Debug). |
| 1.2 Concurrency | N/A | The leg holds no shared state across calls. |
| 1.2 State transitions | N/A | The leg is stateless. |
| 1.3 Clear failure messages | PASS | `-Because "row <Id>"` on every decision assertion; `Should -BeExactly` on full deny text. |
| 1.3 Arrange-Act-Assert | PASS | Comment markers in every It. |
| 1.3 Document intent | PASS | Comment-based help at the top of every suite and the cases file. |
| 1.4 Avoid external dependencies | PASS | No git process, network, or temporary file; staged index, HEAD branch, allowance file, and container probe are mocked seams. |
| 1.4 Use mocks/stubs | PASS | Mocks only the named seams; the AC-18 row reaches the unmocked issue #1188 resolver through a default mock that calls the original function. |
| 1.4 Environment stability | PASS | No environment variable or global state; Invoke-PoshQCLeakScan 0 failures. |
| 1.5 Pre-submission review | PASS | This self-review. |
| 2.1 Objective, plans, documented plan | PASS | spec.md AC-1 to AC-32; plan.2026-11-17T14-05.md executed task by task. |
| 2.2 Simplicity / reusability / extensibility / separation | PASS | Pure predicates in hook-release-allowance-context.ps1, I/O seams and leg entry in the release sibling; reuses the helpers named in spec `### Dependencies or blocked work` without modifying them. |
| 2.3 Cohesive modules, 800-line limit | PASS | 495 / 166 lines (new files), gates 495 and 487, claude-customizations.ts 497; nothing at or above 700. |
| 2.3 Public vs internal, no circular dependencies | PASS | Gate -> release sibling -> context file; one direction. |
| 2.4 Names, docs, comments | PASS | Approved verbs (Get-, Test-, ConvertFrom-); comment-based help on every function. |
| 2.5 Toolchain (format, lint, type check, test, full loop, reporting) | PASS | final-qc-static-powershell/python/typescript.2026-11-18T00-51.md and the final gate artifacts; phase gates P1 (one restart) and P2 (one clean pass). |
| 2.6 Summaries, design choices, docs, next steps | PASS | Commit messages of Phase 0 to 2; brief, orchestrate skill, rule, and CHANGELOG updated; next step: PR and CI (AC-31). |
| 3A Python code change policy | PASS | One tuple entry; Black, Ruff, Pyright repository-wide clean. |
| 3B.1 Invoke-Formatter, PSScriptAnalyzer, fix findings | PASS | 0 drift, 0 findings after fixing one PSReviewUnusedParameter (test) and twelve PSAvoidUsingPositionalParameters (helper calls). |
| 3B.1 PowerShell 5.1 and 7.6+ | PASS | The hooks run under PowerShell 7 like their siblings; no 7-only syntax beyond what the sibling legs use. |
| 3B.2 Advanced functions, validation, global state, errors | PASS | [CmdletBinding()] and typed parameters; only `$script:ReleaseAllowance*` names (parity suite AST check); outer try/catch never throws. |
| 3B.3 800-line limit, approved verbs, comments | PASS | See 2.3 and 2.4. |
| 3B.4 Format, analyze, test, rerun loop | PASS | One P1 restart (no-Python guard), documented in phase-gate.P1.2026-11-17T23-36.md. |
| 3C Bash | N/A | No shell script changed. |
| 3D JSON | PASS | Two pack-manifest entries each; strict JSON; push-down manifest completeness and dependency closure pass. |
| 4A Python unit tests | N/A | No Python test added or changed (owner rule: avoid new Python). |
| 4B Pester v6, PoshQC configuration, organization, naming | PASS | Files named *.Tests.ps1 under tests/scripts/claude-hooks and tests/scripts/codex-hooks beside the gate suites they extend; run only through Invoke-PoshQCParallelTest. |
| 5 Test coverage detail | PASS | See coverage-comparison artifacts. |
| 6 Test execution metrics | PASS | Final Pester 28105 tests 0 failed; pytest 16957 passed 0 failed; Jest 5684 passed 0 failed. |
| 7 Code quality checks / CI cross-check | PASS (local) | CI on the PR head is pending (AC-31, recorded by the orchestrator at S9). |
| 8 Gaps and exceptions | PASS | No skipped or removed test; no exception requested. |
| 10 Compliance verdict | PASS | Fully compliant locally. |

## Code review template

| Checklist item | Result | Evidence |
|---|---|---|
| Findings table | PASS | No open finding after the fixes recorded in the task checks and phase-gate P1. |
| PowerShell implementation audit | PASS | Leg is allow-side only, runs last, declines without I/O before the file is found; the decision is pure and reads the branch and staged index through injected scriptblock parameters. |
| TypeScript implementation audit | PASS | One array entry in `EXCLUDED_RELATIVE_PATHS`; no type change. |
| Python implementation audit | PASS | One tuple entry. |
| C# implementation audit | N/A | No C# change. |
| Test quality audit | PASS | Fail-before evidence (evidence/regression-testing/fail-before.2026-11-17T22-06.md) shows 95 rows per surface failing without the leg; the AC-26 rows publish the file without the exclusion (the seeded core manifest lists it); the script-scope check has companion rows that report violations. |
| No secrets in code | PASS | None. |
| No unsafe subprocess or command construction | PASS | The new files start no process and invoke only scriptblock parameters; the no-Python guard passes. |
| Input validation at boundaries | PASS | Allowance file validated by every rule of spec `#### Required configuration keys and defaults`; `-C` values must be absolute and equal R. |
| Error handling remains explicit | PASS | Config and probe failures report CONFIG_INVALID; unexpected errors decline with PREIMPL_RELEASE_LEG_ERROR. |
| Configuration / path handling is safe | PASS | allowed_paths reject globs, `.`/`..`, leading or trailing `/`, drive letters, backslashes, duplicates, and directories (container seam). |

## Feature audit template (AC-1 to AC-32)

| AC | Result | Evidence |
|---|---|---|
| AC-1 | PASS | hook-release-allowance-context.Tests.ps1, both surfaces (task-check.P1-T1, phase gates). |
| AC-2 | PASS | Same suite, branch rows. |
| AC-3 | PASS | enforce-orchestration-preimplementation-gate-release.Tests.ps1 seam rows, both surfaces. |
| AC-4 | PASS | Decision rows AC4-add-absent and AC4-commit-absent with zero-call assertions, both surfaces. |
| AC-5 | PASS | Leg-entry decline rows plus decision rows AC5-write-path and AC5-injected-checkpoint. |
| AC-6 | PASS | Decision row AC6-no-git-segment. |
| AC-7 | PASS | coverage-comparison.2026-11-18T01-05.md: only added files under both test folders; porcelain empty; final gate 0 failures. |
| AC-8 to AC-19 | PASS | Decision suites, 101 rows per surface, 204 of 204 passing; fail-before shows each allow and suffix row failing without the leg. |
| AC-20 | PASS | Leg-entry rows with throwing branch and staged readers. |
| AC-21 | PASS | Parity suite wiring rows for the four gate copies; hook-dependency-guard-completeness passes. |
| AC-22 | PASS | Parity suite identity and size rows; Codex gate 487 lines; legacy Codex line-limit suites pass. |
| AC-23 | PASS | task-check.P1-T5 (45 contract tests, generator check no drift). |
| AC-24 | PASS | Parity suite absence row. |
| AC-25 | PASS | Jest AC-25 row and parity suite Python tuple row. |
| AC-26 | PASS | claude-customizations-release-allowance.test.ts, both pack modes. |
| AC-27 | PASS | Parity suite brief rows for all six copies. |
| AC-28 | PASS | Parity suite orchestrate and rule rows. |
| AC-29 | PASS | extensions/drm-copilot/CHANGELOG.md `## [Unreleased]` / `### Added` first entry names `.claude/release-commit-allowance.json`, the push-down refresh after the extension release, and the opt-in by committing the file. |
| AC-30 | PASS | final-qc-pester (new files 100%), final-qc-jest (threshold map met). |
| AC-31 | N/A (pending CI) | Local loop passed in one pass; the CI conclusion on the PR head is recorded by the orchestrator at S9. |
| AC-32 | PASS | Parity suite AC-32 rows (no python or poetry text in eight copies); no-Python guard passes; branch file list holds no added .py file and one modified tuple. |

AC status: 31 of 32 checked off in spec.md; AC-31 stays unchecked as pending CI.
