# Self-review (#1129)

Timestamp: 2026-11-08T14-49
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against git diff --name-status from the merge base of origin/main and HEAD
EXIT_CODE: 0
Output Summary: 0 FAIL rows; all gates green against the Phase 0 baselines (see qa-gates/coverage-delta).

PR note (required by the spec): destinations must refresh the Claude and Codex push-downs after an extension rebuild and reinstall, because a push-down writes the installed extension's bundled payload.

## Policy audit (policy-audit template)

| Item | Result | Evidence |
| --- | --- | --- |
| 1.1 Core principles: independence, isolation, speed, determinism, readability | PASS | New tests read committed files or in-memory content only; Pester files remove the module in AfterAll |
| 1.2 Coverage and scenarios (positive, negative, edge) | PASS | Corpus covers empty, single, chain, diamond, multiple roots, cycle, self-loop, unresolved; exit codes 0, 1, 2 tested |
| 1.2.1 Per-language coverage comparison against Phase 0 baseline | PASS | qa-gates/coverage-delta |
| 1.3 AAA structure and diagnostics | PASS | Arrange/Act/Assert comments and message-bearing assertions in new tests |
| 1.4 No temporary files, no external dependencies | PASS | No temp file creation; Pester CLI test runs in-process against committed fixtures |
| 1.5 Policy audit requirement | PASS | This file |
| 2.1 Before changes: baselines captured | PASS | evidence/baseline (8 static artifacts plus Jest, Pester, pytest) |
| 2.2 Design principles: simple, reusable, separated I/O | PASS | Pure Get-EpicWaveNumber; I/O behind injectable reader; thin CLI |
| 2.3 File structure and size | PASS | Largest edited or new file 452 lines; all below the 500 guidance |
| 2.4 Naming, docs, comments | PASS | Approved verbs, comment-based help, Python docstrings with intent comments |
| 2.5 Toolchain executed in order, single pass | PASS | evidence/qa-gates static artifacts then Jest, Pester, pytest gates |
| 2.6 Summarize and document | PASS | Plan checklist and evidence files |
| 3A Python: Black, Ruff, Pyright, typing, error handling | PASS | py-black, py-ruff, py-pyright artifacts; EpicWaveUnresolvedReferenceError fails fast with attributes |
| 3B PowerShell: format, PSScriptAnalyzer, strict mode, CmdletBinding, no global state | PASS | ps-format, ps-pssa artifacts (0 findings); ClaudeLibModuleConvention passes |
| 3C Bash scripts | N/A | No bash file changed |
| 3D JSON: corpus, manifests | PASS | core.json lists bundled files (manifest contract tests green); corpus parsed by both lanes |
| 4A Python tests: pytest, parametrize, naming | PASS | test_epic_wave_corpus_parity.py, test_epic_skill_script_citations_shipped.py |
| 4B Pester tests: Pester 5+/6 syntax, Describe/It, mock parity | PASS | EpicWave.Tests.ps1, EpicWave.Parity.Tests.ps1, hook cases |
| 5 Coverage detail per changed unit | PASS | 100% line for both new PowerShell files; Python files hold 100% line and branch figures at or above baseline |
| 6 Execution metrics | PASS | Jest 5448 passed; Pester 19623 tests, 0 failures; pytest 16555 passed, 0 failed |
| 7 Code quality checks (leak scan, generator check, prettier, eslint, tsc) | PASS | qa-gates artifacts, all EXIT_CODE 0 |
| 8 Gaps and exceptions | PASS | None; no suppression added, no coverage exclusion |
| 9 Summary of changes and mirror parity | PASS | Every bundled and Codex copy byte-equal by git diff --no-index; mirror contract tests green |
| 10 Verdict | PASS | Fully compliant |

## Code review (code-review template)

| Item | Result | Evidence |
| --- | --- | --- |
| Python implementation: typing, API, error handling | PASS | compute_wave_numbers raises the new error before recursion into an absent key; validator catches it beside the cycle error |
| TypeScript implementation: VIRTUAL_RESOURCE_DIRECTORIES mirrors the Python constant | PASS | codex-agents-customizations.ts and push_down_codex_and_agents_customizations.py both gain the epic-wave pair; Jest and pytest cases cover it |
| PowerShell implementation: API and safety | PASS | Ordinal comparers keep names case-sensitive; unexpected exceptions rethrown, manifest errors mapped to exit 1 |
| C# implementation | N/A | No C# changed |
| Test quality: no vacuous assertions, fail-before proven | PASS | evidence/regression-testing/citation-test-fail-before records ExpectedExitCode 1 and EXIT_CODE 1 |
| Security and correctness: hook allowlist narrowness | PASS | CLI pattern admits only the single script and a path-character-only -ManifestPath; chained or other-script commands rejected by new cases |
| Research log and verdict | PASS | Spec and plan premises re-derived in the plan Premise corrections section |

## Feature audit (feature-audit template)

| Item | Result | Evidence |
| --- | --- | --- |
| AC1 EpicWave files exist, bundled byte-equal, in Claude core.json | PASS | test_push_down_claude_resource_contracts, ..._pack_manifest_completeness, ..._dependency_closure green in the pytest gate |
| AC2 Module wave formula over non-error corpus cases | PASS | EpicWave.Parity.Tests.ps1 (9 tests) green |
| AC3 Three distinct stable error messages | PASS | EpicWave.Tests.ps1 green |
| AC4 CLI exit codes 0, 1, 2 | PASS | EpicWave.Tests.ps1 entry-script cases green |
| AC5 Python raises unresolved error; both corpus lanes pass; existing tests pass | PASS | test_epic_wave_corpus_parity.py, test_epic_wave_computation.py, EpicWave.Parity.Tests.ps1 |
| AC6 Codex push-down publishes .codex/lib/epic-wave | PASS | test_epic_wave_directory_publishes_stored_resources, Jest codex-agents-epic-wave-directory.test.ts, Codex core.json closure |
| AC7 Hook and twin allow the CLI and keep the Python pattern | PASS | codex-planning-only-hook.Tests.ps1 (15 tests) green; twin byte-equal |
| AC8 Agent grants, bundled copies, generated variants | PASS | generate_codex_agent_variants --check exit 0; resource contract tests green |
| AC9 Wave-layering citations only, re-pinned digests with RE-BASELINED note | PASS | git diff -U0 hunks confined to the named sections; test_frozen_epic_surface_matches_pinned_baseline_digest green |
| AC10 Citation-shipping test: passes after, failed before, allowlist reason, stale entry | PASS | fail-before artifact; test_allowlist_reasons_name_the_mcp_route; test_allowlist_has_no_stale_entry |
| AC11 Full toolchain single pass and PR statement | N/A | Toolchain portion PASS locally; the PR statement and CI result depend on the pull request and stay unchecked |
| Scope boundary: #1130 and nesting depth untouched | PASS | Only wave-layering sentences and tool entries edited in shared epic files |
| Main sync | PASS | evidence/other/main-sync; merge-base check exit 0 |
