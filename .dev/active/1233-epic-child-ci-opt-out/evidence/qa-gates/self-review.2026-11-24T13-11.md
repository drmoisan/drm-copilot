# Self-review: issue #1233 epic child CI opt-out (P5-T9)

Timestamp: 2026-11-24T13-11
Scope: the branch diff from the merge base of origin/main and HEAD (a4ebf9668) plus the uncommitted final-QA fixes, walked against `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md`, and `feature-audit.yyyy-MM-ddTHH-mm.md`.
Result: no FAIL row.

## Policy audit template

| Item | Status | Evidence |
| --- | --- | --- |
| 1.1 Independence | PASS | New suites read committed fixtures or build checkpoints in memory; per-row state is reset by `Initialize-OptOutRow` or a BeforeEach mock; all gates run in parallel shards and passed. |
| 1.1 Isolation | PASS | One behavior per row: one stage condition per deny row, one corpus case per parametrized row, one unit per contract row. |
| 1.1 Fast execution | PASS | New Pester suites 50 to 65 tests in under 2 s each inside their shard; corpus tests under 0.1 s each. |
| 1.1 Determinism | PASS | gh, git, and checkpoint reads are mocked by name; no clock, network, or process; fixed heads and timestamps. |
| 1.1 Readability | PASS | Row ids (OPT-*, CLAUDE-OPT-*, OCC-*, CCO-*) and Arrange/Act/Assert comments. |
| 1.2 Baseline coverage documented | PASS | evidence/baseline/baseline-pester.2026-11-24T05-33.md, baseline-pytest.2026-11-24T05-52.md, baseline-jest.2026-11-24T06-30.md. |
| 1.2 No coverage regression | PASS | evidence/qa-gates/coverage-comparison.2026-11-24T13-09.md: no per-file or repo-wide drop. |
| 1.2 Changed files meet thresholds | PASS | PowerShell files 93.33% to 100% lines; Python 99.52% lines, 99% branches; TypeScript 98.91%/96.25% and 100%/100%. |
| 1.2 New code coverage at least 90% | PASS | Changed-line coverage 95.65% to 100% per file (coverage-comparison). |
| 1.2 Comprehensive coverage | PASS | Every stage B, R, L1, L2, L3, every fallback and default variant, every validator string, and every completion field has a row. |
| 1.2 Positive flows | PASS | Allow rows (40- and 64-character heads), corpus `opt-out-accepted`, completion DONE-allowed rows. |
| 1.2 Negative flows | PASS | 31 Codex and 30 Claude deny rows; 17 failing corpus cases; completion deny rows. |
| 1.2 Edge cases | PASS | Case variants of base, head, conclusion, and child_ci; first EXIT_CODE 1 then 0; empty review list; non-object last entry. |
| 1.2 Error handling | PASS | gh non-zero and unparseable output, cat-file non-zero; the helper never throws (existing catch). |
| 1.2 Concurrency | N/A | No concurrent code paths. |
| 1.2 State transitions | N/A | Stateless validators and gates. |
| 1.3 Clear failure messages | PASS | `-Because` texts carry the reason or the missing tokens. |
| 1.3 Arrange-Act-Assert | PASS | All new rows. |
| 1.3 Document intent | PASS | Suite synopsis blocks and row names. |
| 1.4 Avoid external dependencies | PASS | No network or process; fixtures are committed files read in place. |
| 1.4 Use mocks | PASS | Invoke-DocsOnlyGhExe, Invoke-DocsOnlyGitExe, checkpoint seams, review decision (one row). |
| 1.4 Environment stability | PASS | No temporary file; no global state; leak scan 0 failures. |
| 1.5 Pre-submission review | PASS | This file and the per-phase pre-push reviews. |
| 2.1 Before making changes | PASS | Plan .dev/active/1233-epic-child-ci-opt-out/plan.2026-11-23T22-42.md executed in order; Phase 0 baselines. |
| 2.2 Simplicity / reusability / extensibility / separation | PASS | One predicate per runtime; the gate logic stays in the existing byte-identical helper with one new seam; validators select the check in one dispatch function; I/O stays in seams. |
| 2.3 Cohesive modules | PASS | New TypeScript module holds only the selection; PowerShell helpers private. |
| 2.3 At or below 800 lines | PASS | Largest changed code file 689 lines (jest.config.cjs); no file at or above 700 lines among the changed production PowerShell, Python, or TypeScript files; the legacy pins hold (Codex completion hook 500, Claude gate 500). |
| 2.3 Public vs internal | PASS | Python dispatch public (plan decision), helpers private; PowerShell helpers not exported. |
| 2.3 No circular dependencies | PASS | orchestrator-state-child-ci.ts imports orchestrator-state-completion.ts only; core imports both. |
| 2.4 Descriptive names, docstrings, comments | PASS | Comment-based help on every new PowerShell function; docstrings and TSDoc on every new Python and TypeScript function. |
| 2.5 Toolchain (format, lint, type check, tests) | PASS | final-qc-powershell-static.2026-11-24T12-54.md, final-qc-python-static.2026-11-24T12-54.md, final-qc-typescript-static.2026-11-24T12-54.md, final-qc-pester.2026-11-24T13-00.md, final-qc-pytest.2026-11-24T13-06.md, final-qc-jest.2026-11-24T13-09.md. |
| 2.5 Full toolchain loop | PASS | Three passes of the final loop; the two restarts are recorded in evidence/other/final-qa-remediation.*.md. |
| 2.6 Summarize and document | PASS | Commit messages per phase; ledger entry 0014; skills, rule, and brief updated. |
| 3A Python tooling and typing | PASS | black, ruff, pyright strict clean; no new module; key-gated inline change. |
| 3B PowerShell tooling and safety | PASS | Invoke-Formatter clean; PSScriptAnalyzer 0 findings; no dynamic invocation in hooks; no new dot-source. |
| 3C Bash | N/A | No bash file changed. |
| 3D JSON | PASS | Corpus files parse, LF, `name` equals stem; rule JSON section list valid (generator passes). |
| 4A Python tests | PASS | pytest parametrized corpus rows and two completion rows; no subprocess, no temporary file. |
| 4B PowerShell tests | PASS | Pester 6 suites with -ForEach rows; baseline isolation form satisfied (EpicStateIsolation discovery guard passed). |
| 7 Code quality checks | PASS | Zero findings in every static stage. |
| CI cross-check | N/A | The pull request is not yet open; the pull request's own CI is orchestrator-owned (S9). |
| 8 Gaps and exceptions | PASS | No skipped or removed test; the one uncovered changed line (.claude helper line 196) is exercised through the byte-identical Codex copy. |

## Code review template

| Item | Status | Evidence |
| --- | --- | --- |
| Python implementation | PASS | Strings and order identical to the spec; `_orchestrator_state_concurrent_review` import line and `errors.extend(validate_concurrent_review_completion(state_map))` untouched. |
| TypeScript implementation | PASS | Strict types; `orchestrator-state-completion.ts` unchanged; own coverageThreshold entry. |
| PowerShell implementation | PASS | Opt-out stages return ordered results; denial prefix chosen by the detail origin; `-GitRoot` defaults to GhRoot. |
| Test quality: determinism, isolation, speed, diagnostics | PASS | See section 1 rows. |
| No secrets in code | PASS | None added. |
| No unsafe subprocess or command construction | PASS | gh and git run only through the existing bounded wrappers with argument arrays. |
| Input validation at boundaries | PASS | Object id, base, evidence path (no backslash, empty, `.`, `..` segment; folder prefix; `.md`), feature folder through the existing validator. |
| Error handling remains explicit | PASS | Every failure denies with a stage id and detail; no fall-through. |
| Configuration and path handling is safe | PASS | The evidence path is read only from the live head tree through `git cat-file`; the working tree is not read. |
| Research log | PASS | No external research; the feature research file is cited in the ledger. |

## Feature audit template: acceptance criteria

| Criterion (spec.md) | Status | Evidence |
| --- | --- | --- |
| Opt-out allows a child merge without CI on Claude and Codex | PASS | Allow rows of both merge-gate suites (task-check.P2-T1, P2-T2). |
| Default behavior unchanged, seam never called, deny texts unchanged | PASS | Default rows; unchanged existing suites in Set H. |
| No opt-out for base main, other base, or malformed integration branch | PASS | Fallback rows of both suites. |
| Each stage failure denies with the local-QC prefix and stage id | PASS | Deny rows of both suites. |
| Claude passes `-GitRoot`; default is GhRoot | PASS | CLAUDE-OPT-GITROOT-ITEM; OPT-COUNT-GITROOT-DEFAULT. |
| Completion-consistency hooks accept only a valid local_qc_gate; keyless text unchanged | PASS | Extended completion suites and helper rows. |
| Validators accept the opt-out and emit the strings in order | PASS | Corpus (19 cases) in pytest, Jest, and Pester. |
| Strings byte-identical across runtimes | PASS | Same corpus `expected_errors` asserted by all three. |
| Python confined; TypeScript module meets its threshold | PASS | Scope check; final-qc-jest (100%/100%). |
| Orchestrate skills state the S9 procedure | PASS | child-ci-opt-out-skill-contract.Tests.ps1; test_ci_gate_epic_child_contracts.py green. |
| Epic skills and template state the key, kickoff line, and integration CI | PASS | Contract suite; early-start-skill-contract.Tests.ps1 green. |
| Generated rule holds the section with the disclosure | PASS | HarnessGeneration.RepoGate; contract suite rule rows. |
| Brief updated identically in four copies | PASS | cmp; push-down contracts; contract suite brief rows. |
| Pin re-baselined with the RE-BASELINED paragraph | PASS | test_parallel_orchestrator_surface_contracts.py. |
| Twins and bundles byte-identical | PASS | cross-tree-helper-identity; push-down resource, pack-manifest, dependency-closure contracts. |
| Generator `-Check` and Codex `--check` | PASS | scope-check.2026-11-24T13-10.md. |
| Ledger entry with prior text, revert steps, signals, D1 residual, D10 disclosure | PASS | phase-gate.P4.2026-11-24T11-28.md (chain test on the committed tree). |
| No file above the hard limit; ci.yml, review guard, docs lib and skills unchanged | PASS | scope-check.2026-11-24T13-10.md. |
| Toolchain loop passes and the pull request's own CI run is green | PASS for the toolchain loop; CI pending | The pull request's own `CI` run is orchestrator-owned (S9) and stays unchecked as pending-CI. |

User-story criteria: all ten map to the rows above (kickoff; allow; deny; base fallback; S9 procedure; completion hooks; validators; integration PR; default behavior; ledger) and are checked off in user-story.md.

## AC Status Summary

- Source: .dev/active/1233-epic-child-ci-opt-out/spec.md and user-story.md
- spec.md: 19 criteria, 18 checked, 1 pending-CI (the pull request's own CI run).
- user-story.md: 10 criteria, 10 checked.
