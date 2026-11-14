# Self-Review — [P6-T8]

Timestamp: 2026-11-14T04-14
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against git diff <merge base of origin/main and HEAD> HEAD (117 files changed, 11850 insertions, 49 deletions)
EXIT_CODE: 0
Output Summary: every row PASS or N/A; no FAIL row. One earlier walk found the policy-audit row "New Code Coverage ≥90%" failing per file (Invoke-RegenerationPath.ps1 89.37%, the Claude merge-gate regeneration helper 88.64%); tests were added (evidence/other/task-check.P6-T8.2026-11-14T03-53.md), origin/main (#1174) was merged, and the QA loop was re-run from [P6-T1] (powershell-final-qc.2026-11-14T03-55.md, pester-final.2026-11-14T04-07.md, pytest-final.2026-11-14T04-11.md, typescript-final-qc.2026-11-14T04-12.md, jest-final.2026-11-14T04-12.md, coverage-comparison.2026-11-14T04-13.md). All 41 AC IDs PASS. One non-blocking Warning: Invoke-RegenerationPath.ps1 and its bundle copy are 711 logical lines (700-line advisory tier).

## Policy audit template

### Coverage evidence checklist and summary table

| Item | Status | Evidence |
|---|---|---|
| PowerShell baseline coverage artifact | PASS | evidence/baseline/pester-parallel.2026-11-10T04-00.md (95.80%, four edited entry files) |
| PowerShell post-change coverage artifact | PASS | evidence/qa-gates/pester-final.2026-11-14T04-07.md (95.90%, twelve files) |
| Python baseline / post-change coverage | PASS | pytest-parallel.2026-11-10T03-53.md (97.11% line, 94.37% branch) / pytest-final.2026-11-14T04-11.md (97.13%, 94.42%); test-only Python edits |
| TypeScript baseline / post-change coverage | PASS | jest.2026-11-10T03-53.md / jest-final.2026-11-14T04-12.md, no metric lower; test-only TypeScript edit |
| Per-language comparison summary | PASS | evidence/qa-gates/coverage-comparison.2026-11-14T04-13.md |
| Bash and JSON rows of the summary table | N/A | No bash file changed. JSON: two fixtures and two pack manifests; manifests parse, fixtures pass the three parity suites |

### 1. General unit test policy

| Requirement | Status | Evidence |
|---|---|---|
| Independence | PASS | Suites pass inside the eight-shard parallel gate; each regeneration suite imports in BeforeAll and removes in AfterAll; closure suites carry baseline null mocks and interception probes (EpicStateIsolation discovery guard, 567 passed) |
| Isolation | PASS | One behavior per It; row cases one per result-table row (R01-R74) |
| Fast execution | PASS | Regeneration folder plus selection ran 861 tests in one task check; no wait or sleep in any added test |
| Determinism | PASS | Injected -UtcNow, in-memory config text, mocked git and process wrappers; no clock read, no process start, no temporary file |
| Readability and maintainability | PASS | Descriptive It names, Arrange/Act/Assert comments, help blocks on each suite |
| Baseline coverage documented | PASS | Phase 0 artifacts above |
| No coverage regression | PASS | All repo-wide figures at or above baseline; edited entry files not below baseline |
| Changed files meet thresholds | PASS | Every new PowerShell file at or above 85% (lowest 91.03%) |
| New code coverage ≥90% | PASS | Per new file: lowest 91.03% (Invoke-RegenerationPath.ps1); the 27 uncovered lines are seam defaults and the guarded script body. Calculation: per-file line coverage from powershell-coverage.xml |
| Comprehensive coverage | PASS | Every exported and script function has direct cases; builders have distinct-value field-mapping cases |
| Positive flows | PASS | R73/R72 prepared rows, Tip applied rows, Validate valid row, allowance admit cases |
| Negative flows | PASS | Config-invalid, usage-error (exit 2), unmatched-path, deny cases of both gates |
| Edge cases | PASS | Empty argv, empty -ConfigPath, NUL-terminated listings, multiple merge bases, case variants |
| Error handling | PASS | Git and process start failures (exit 1 rows), throwing invoker propagation, Invoke-RegenerationGitStep catch path |
| Concurrency | N/A | The entry point is single-invocation; no shared state |
| State transitions | PASS | Merge-mode stage sequence and abort-on-failure rows; Tip restore rows |
| Clear failure messages | PASS | -Because on loop assertions; reason substrings asserted |
| Arrange-Act-Assert | PASS | Added cases carry Arrange/Act/Assert sections |
| Document intent | PASS | Help blocks name the issue and the seams |
| Avoid external dependencies | PASS | No git, gh, network, process, or file write in tests; the process default is pinned by AST only |
| Use mocks/stubs | PASS | Wrapper mocks only (Invoke-RegenerationGitExe, Invoke-RegenerationProcess, Read-RegenerationConfigText) |
| Environment stability | PASS | No temporary file, no global state, no PATH dependence |
| Pre-submission review | PASS | This self-review; feature-review follows in the lifecycle |

### 2. General code change policy

| Requirement | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | Issue #1156, spec.md D1-D18 |
| Read existing change plans | PASS | Plan plan.2026-11-09T16-31.md and research |
| Document the plan | PASS | Plan file, task-check and gate evidence, commit messages |
| Simplicity first | PASS | Pure modules plus one thin adapter; one data file transcribes the result table |
| Reusability | PASS | Shared fan-in helpers reused; process default follows Invoke-DocsProcess |
| Extensibility | PASS | Versioned config (version 1); trigger and mode enumerations |
| Separation of concerns | PASS | Config, classifier, delta modules have no I/O; all I/O in Invoke-RegenerationPath.ps1 seams |
| Cohesive modules | PASS | One concern per module |
| At or below the 800-line hard limit | PASS | Largest covered file 711; 0 files above 800 |
| Public vs internal | PASS | Module exports are the documented functions |
| No circular dependencies | PASS | Classifier and delta import config only; adapter imports all three |
| Descriptive names | PASS | Approved-verb Regeneration* names |
| Docs/docstrings | PASS | Comment-based help on every new function; docstrings on added Python tests |
| Comment why, not what | PASS | Comments state rationale (for example the AD-1 shape and seam ownership) |
| Formatting | PASS | powershell-final-qc.2026-11-14T03-55.md (0 drift), python-final-qc.2026-11-14T03-38.md, typescript-final-qc.2026-11-14T04-12.md |
| Linting | PASS | PSSA 0, Ruff 0, ESLint 0 |
| Type checking | PASS | Pyright 0, tsc 0; N/A for PowerShell |
| Testing | PASS | Pester 24326/0 failed, pytest 16729/0, Jest 5559/0 |
| Full toolchain loop | PASS | Re-run from [P6-T1] in one clean pass after the fix and the main merge |
| Explicit reporting | PASS | Commands and exit codes in each artifact |
| Summarize changes / design choices / supporting documents / next steps | PASS | Commit messages; spec decisions; skills, agents, rules file, brief, and bundle mirrors updated; next step is feature-review and PR |

### 3. Language-specific code change policy

| Requirement | Status | Evidence |
|---|---|---|
| 3A Black / Ruff / Pyright / Pytest | PASS | python-final-qc and pytest-final artifacts |
| 3A Strong typing, dataclasses, protocols, utility classes, exceptions, logging, invariants | N/A | Python edits are tests only; added tests are typed and use no broad catch |
| 3B Invoke-Formatter / PSScriptAnalyzer / fix all findings | PASS | 39 files, 0 drift, 0 findings |
| 3B PowerShell 5.1 and 7.6+ compatible | PASS | Repository rule requires PowerShell 7+; ProcessStartInfo.ArgumentList needs .NET Core, as in the Invoke-DocsProcess precedent |
| 3B Advanced functions / parameter validation | PASS | CmdletBinding, Mandatory, AllowNull/AllowEmptyCollection on every new function |
| 3B Avoid global state | PASS | No global or script-scope mutable state in production files |
| 3B Error handling | PASS | Explicit throw on invariant violations; step wrappers convert failures to exit codes with a stderr message |
| 3B Cohesive and at or below 800 lines | PASS | See size table |
| 3B Approved verbs | PASS | Get, New, Invoke, ConvertTo, ConvertFrom, Test, Read (PSSA UseApprovedVerbs clean) |
| 3B Comment why | PASS | As above |
| 3B Toolchain steps and rerun loop | PASS | Three P6-T1 passes recorded (two fixes in the first run, one clean re-run) |
| 3C Bash | N/A | No bash file changed |
| 3D JSON formatting / schema / $schema / strict / key order | N/A | Fixtures follow the corpus format pinned by the parity suites; manifests follow the existing core.json shape (unsorted by design) |

### 4. Language-specific unit test policy

| Requirement | Status | Evidence |
|---|---|---|
| 4A Use Pytest / coverage expectation / focused / mocking / organization / naming / docstrings / runner | PASS | Two appended pytest tests and one pin file, all under tests/scripts/dev_tools; pytest -n auto only |
| 4B Use Pester 6 / PoshQC configuration / compatibility | PASS | Pester 6 via Invoke-PoshQCParallelTest |
| 4B Focused unit tests / behavior over implementation | PASS | Behavior cases plus AST pins only for seam defaults and entry wiring that no test may execute |
| 4B Mocking used sparingly | PASS | Wrapper functions and closure seams only |
| 4B Organization (mirrors code) | PASS | tests/scripts/claude-lib/regeneration mirrors .claude/lib/regeneration; hook suites in claude-hooks and codex-hooks |
| 4B File naming, Describe/Context/It structure, grouping, comments | PASS | *.Tests.ps1, grouped by function |
| 4B PoshQC test command / no alternative runner | PASS | Invoke-PoshQCParallelTest for gates; task checks are debugging-only Invoke-Pester runs |

### Sections 5-10

| Item | Status | Evidence |
|---|---|---|
| Test coverage detail and execution metrics | PASS | pester-final.2026-11-14T04-07.md named-suite table |
| Code quality checks / CI cross-check | PASS | Static artifacts above; CI runs on the PR |
| Gaps and exceptions | PASS | No skipped or removed test; the one assertion change (check (h), AD-1) is recorded in task-check.P6-T2.2026-11-14T03-25.md |
| Compliance verdict | PASS | Fully compliant; one non-blocking 700-line Warning |

## Code review template

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credential or token literal in the diff |
| No unsafe subprocess or command construction | PASS | Process default uses ProcessStartInfo with UseShellExecute false and one ArgumentList entry per argument; no shell, no Invoke-Expression, no call operator on a variable (no-Python scan, 35 passed); git calls splat an argv array with -- before paths |
| Input validation at boundaries | PASS | Config validated (rules 1-9) before any git call; usage errors exit 2; allowance rejects backslash, glob, dot segments, leading slash |
| Error handling remains explicit | PASS | Start failures throw; git failures exit 1 with merge abort |
| Configuration / path handling is safe | PASS | Relative -ConfigPath only; absolute and .. rejected |
| Determinism / isolation / speed / diagnostics prompts | PASS | As in section 1 |
| Findings table | PASS | Warning (non-blocking): Invoke-RegenerationPath.ps1 is 711 logical lines, at the 700-line advisory tier; a later split of the Merge and Tip flows into a module would bring it under 700 |

## Feature audit template: AC rows

| AC | Status | Evidence |
|---|---|---|
| AC1.1 | PASS | RegenerationConfig.Tests.ps1, 44 passed |
| AC1.2 | PASS | Result rows (no_config) in Invoke-RegenerationPath.Tests.ps1, 74 rows passed |
| AC1.3 | PASS | Result rows (config_invalid), same suite |
| AC1.4 | PASS | regeneration-path-skill-contract.Tests.ps1, 52 passed |
| AC1.5 | PASS | Same skill-contract suite (D11 absence case) |
| AC1.6 | PASS | Tip config-stage rows |
| AC1.7 | PASS | Validate rows and usage rows |
| AC2.1-AC2.4 | PASS | RegenerationClassifier.Tests.ps1, 21 passed, no I/O mock |
| AC3.1 | PASS | Merge call-order rows (R47-R74) |
| AC3.2 | PASS | Merge failure-branch rows with abort counts |
| AC3.3 | PASS | RegenerationDelta.Tests.ps1, 38 passed |
| AC3.4 | PASS | Tip rows (R28-R42) and Invoke-RegenerationPath.Tip.Tests.ps1, 24 passed |
| AC3.5 | PASS | Builder field-mapping cases in RegenerationDelta.Tests.ps1 |
| AC3.6 | PASS | Skill-contract suite |
| AC3.7 | PASS | Result rows plus script-layer AST checks (a)-(h) |
| AC3.8 | PASS | 74 row cases R01-R74 and 4 structure checks |
| AC4.1 | PASS | Skill-contract suite (skill and agent) |
| AC4.2 | PASS | Two fixtures pass in pytest, Jest, and Pester parity suites |
| AC4.3 | PASS | light-remediation-skill-contract and test_orchestrator_state_remediation_docs.py pass unmodified |
| AC5.1, AC5.2, AC5.5, AC5.6 | PASS | Skill-contract suite |
| AC5.3 | PASS | hook-epic-regeneration.Tests.ps1 and the epic-scope suites |
| AC5.4 | PASS | Skill-contract suite and test_epic_orchestrator_permission_contracts.py |
| AC6.1 | PASS | Skill-contract and concurrent-review suites |
| AC6.2 | PASS | Skill-contract suite |
| AC6.3 | PASS | Skill-contract suite and test_orchestrator_state_remediation_docs.py |
| AC6.4 | PASS | enforce-epic-merge-gate.Regeneration.Tests.ps1 (22) and enforce-epic-merge-gate-regeneration.Tests.ps1 (38) |
| AC6.5 | PASS | Bundle byte copies; push-down contract, manifest completeness, and dependency-closure tests pass |
| AC6.6 | PASS | test_parallel_orchestrator_surface_contracts.py, 38 passed |
| AC6.7 | PASS | Six brief copies hash identically after the main merge; test_execution_environment_brief_contracts.py passes |
| AC6.8 | PASS | test_destination_projection_omits_regeneration_keys and the rules-file disclosure pin |
| AC6.9 | PASS | Skill-contract Codex-scope case |
| AC7.1 | PASS | Existing merge-gate, review-guard, child-CI, green-CI, fan-in suites pass in the gate |
| AC7.2 | PASS | Appended ReviewGuard regression cases pass |
| AC7.3 | PASS | Appended EpicFanIn regression cases pass |
| AC7.4 | PASS | Remediation-loop corpus and parity suites pass unmodified |

No AC is CI-dependent by its text; the Linux hook-suite CI job additionally runs the claude-hooks and codex-hooks suites.
