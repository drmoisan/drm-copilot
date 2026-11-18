# Self-review (P3-T5)

Timestamp: 2026-11-18T05-44
Command: walk of docs/features/templates/policy_audit/policy-audit, code-review, and feature-audit templates against the branch diff from the merge base of `origin/main` and `HEAD` (`git diff --name-only origin/main...HEAD`, see scope-and-size.2026-11-18T05-44.md)
EXIT_CODE: 0
Output Summary: every checklist row below is PASS or N/A; no FAIL row. Two items were fixed during the run before this rewrite (coverage of the entry script, duplicated failure code in the summary text); the QA loop was re-run after each fix and the final artifacts are final-qc-static-powershell.2026-11-18T05-29.md and final-qc-pester.2026-11-18T05-43.md. The CI-dependent criterion (`NPM Audit Gate` jobs green on the PR head) is left unchecked in spec.md for S9 and is not claimed here.

## Policy audit template

| Item | Result | Evidence |
|---|---|---|
| 1.1 Independence: tests run in any order | PASS | Each case builds in-memory JSON; module state is read-only constants; the parallel gate ran 27605 tests with 0 failures |
| 1.1 Isolation | PASS | one behavior per `It`; suites split by unit (module, entry script, workflow text) |
| 1.1 Fast execution | PASS | new suites run in about 90 s in a single-shard launcher run, dominated by shard start-up |
| 1.1 Determinism | PASS | no clock read in the module; the clock is a seam; tests pass fixed dates |
| 1.1 Readability | PASS | `NAG-`, `INA-`, `NAW-` case ids with descriptive names |
| 1.2 Baseline coverage documented | PASS | baseline/pester-gate.2026-11-18T03-56.md |
| 1.2 No coverage regression | PASS | final-qc-pester: 0 of 461 baseline files dropped; repo-wide 96.0460% to 96.0534% |
| 1.2 Changed files meet thresholds | PASS | NpmAuditGate.psm1 100%, Invoke-NpmAuditGate.ps1 90.91% against the 85% line threshold |
| 1.2 New code coverage 90% or more | PASS | 161/161 and 50/55 lines (90.91%) |
| 1.2 Positive, negative, edge, error flows | PASS | valid file and passing decisions; ten invalid-file classes; date boundary (equal date passes); unreadable file and clock failure |
| 1.2 Concurrency, state transitions | N/A | pure stateless functions |
| 1.3 Clear failure messages, AAA, intent | PASS | `-Because` on non-obvious assertions; one behavior per case |
| 1.4 External dependencies | PASS | no npm process, network, temp file, or disk write; the committed config file is read once by NAG-EXC-COMMITTED-FILE and workflow text by NAW cases, both read-only repository files |
| 1.4 Mocks | PASS | `Invoke-NpmAuditExe` mocked with the production parameter name `NpmArgs`; file and writer seams injected |
| 1.5 Pre-submission review | PASS | this artifact |
| 2.1 Objective, plan | PASS | issue 1204, spec.md, plan.2026-11-17T22-23.md |
| 2.2 Simplicity, reuse, extensibility, separation | PASS | pure module vs I/O entry script, copying the CiRequiredGate pattern; exception list is data |
| 2.3 Cohesion, 800-line limit, no cycles | PASS | largest file 408 lines; module has no imports; entry script imports the module |
| 2.4 Names, docs, why-comments | PASS | comment-based help on every function; comments state rationale (fail-closed, single code print) |
| 2.5 Toolchain loop | PASS | final-qc-static-powershell (format 0 rewritten, analyze 0) then the Pester gate exit 0 |
| 2.6 Summary, design choices, docs, next steps | PASS | ledger entry 0013; spec Rollout section; revert and expiry signals |
| 3A Python, 3C Bash, 4A Python tests | N/A | no Python or Bash file changed; no new Python |
| 3B Formatting and analyzer | PASS | 0 formatted, 0 findings; one `PSUseSingularNouns` suppression with justification (name fixed by spec), the repository precedent in `CiChangeScope.psm1` |
| 3B PowerShell versions | N/A | repository rule is PowerShell 7+ (`.claude/rules/powershell.md`); the 5.1 wording in the template predates it |
| 3B Advanced functions, validation | PASS | `CmdletBinding`, `ValidateSet` on the level, `ValidatePattern` on the date |
| 3B Global state, error handling | PASS | script-scope constants only; fail-closed envelope in `Invoke-NpmAuditGate`; no silent catch (the read failure is logged) |
| 3B Approved verbs | PASS | ConvertFrom, ConvertTo, Get, Invoke, Split, Test, Write |
| 3D JSON | PASS | strict JSON, Prettier check passes; the schema-validation tool governs files with a `$schema` property and this file defines the contract in the spec instead (unknown keys are rejected by the module) |
| 4B Pester v6, PoshQC config | PASS | `Invoke-PoshQCParallelTest` through the launcher |
| 4B Test file location and naming | PASS | tests/scripts/ci/NpmAuditGate.Tests.ps1, tests/scripts/ci/Invoke-NpmAuditGate.Tests.ps1, tests/scripts/workflows/NpmAuditGateWorkflow.Tests.ps1 mirror the source paths and use `.Tests.ps1` |
| 6 Test execution metrics | PASS | 27605 run, 0 failed, 18 skipped (pre-existing), file sizes below 500 |
| CI cross-check | PASS | local claims: `poshqc / PowerShell QC` pass (Pester gate), `poshqc / PowerShell QC static` pass (format, analyze, leak scan); CI results pending and read by the orchestrator at the PR head |
| 8 Gaps and exceptions | PASS | none: `Merge commit: pending (PR #1204)` uses the issue number as the stand-in for the PR number until back-fill (recorded in task-check.P2-T4) |

## Code review template

| Item | Result | Evidence |
|---|---|---|
| Findings table: Blocker or Major | PASS | none found |
| PowerShell implementation audit | PASS | fail-closed on blank, unparseable, unknown-severity, and missing-exit-code inputs; the code is printed once per failure |
| No secrets | PASS | none in code, config, or evidence |
| No unsafe command construction | PASS | npm arguments are built as an array from a ValidateSet level and constants; no string evaluation |
| Input validation at boundaries | PASS | exception file contract validated before use; date and level validated by parameter attributes |
| Error handling explicit | PASS | each failure has its own code; unexpected errors give exit 1 |
| Configuration and path handling | PASS | `Get-Content -LiteralPath`; paths come from the workflow with `github.workspace` |
| Test quality | PASS | see policy audit rows 1.1 to 1.4 |
| Weakened gate | PASS | audit level unchanged; production pass has no exception logic; dev dependencies are not omitted from the full audit (`NAW-BARE-AUDIT-LINE-ABSENT`, `INA-NPM-ARGS`); expiry enforced in code |

## Feature audit template (acceptance criteria of spec.md)

| # | Criterion | Result | Evidence |
|---|---|---|---|
| 1 | exception file with the single entry | PASS | NAG-EXC-COMMITTED-FILE |
| 2 | validation codes, failing-then-passing tests | PASS | evidence/regression-testing/fail-before-exception.2026-11-18T04-05.md; NAG-EXC-* cases |
| 3 | module and script implement approach A, five codes in order | PASS | NAG-DEC-ORDER, INA-NPM-ARGS, INA-EXIT-1-FOR-EACH-CODE |
| 4 | applied exceptions to log and summary; unused informational | PASS | INA-OUTPUT-WRITER, NAG-DEC-UNUSED-INFORMATIONAL, gate-script-local-run |
| 5 | workflow step replaced, level and ids unchanged, actionlint passes | PASS | NAW cases; actionlint.2026-11-18T05-06.md |
| 6 | decision tests | PASS | NAG-DEC cases |
| 7 | workflow tests | PASS | NpmAuditGateWorkflow.Tests.ps1, 7 cases |
| 8 | no temp files, no real npm, no Python, files under 500 lines | PASS | scope-and-size.2026-11-18T05-44.md |
| 9 | coverage at least 85% | PASS | final-qc-pester.2026-11-18T05-43.md |
| 10 | ledger entry 0013 and index row; chain and index tests pass | PASS | task-check.P2-T4; phase-gate.P2 |
| 11 | real run confirms `--omit=dev` honored | PASS | npm-audit-observation.2026-11-18T03-41.md (`OMIT_DEV_HONORED: yes`) |
| 12 | CI-dependent: three `NPM Audit Gate` jobs pass on the PR head | N/A (pending CI) | left unchecked for S9 |
