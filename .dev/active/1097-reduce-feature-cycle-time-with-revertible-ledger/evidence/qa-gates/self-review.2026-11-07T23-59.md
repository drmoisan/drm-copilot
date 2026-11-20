# Self-Review: Issue 1097 Stage F (G13 guideline with a zone-aware cutoff, reduction 0008)

Timestamp: 2026-11-07T23-59
Command: policy-audit, code-review, and feature-audit templates under docs/features/templates/policy_audit/ walked against the diff from the merge base of origin/main and HEAD (git diff --name-status --no-renames; git fetch origin first) and against the stage F commits (git log from the merge base), with the stage F gate artifacts read as evidence
EXIT_CODE: 0
Output Summary: no FAIL row. Stage F lowers the G13 guideline to 20 tasks and 250 lines with one zone-aware cutoff pair in both validators, the rule file, and the 0008 entry, as one reduction commit; one later fix commit with the same token removes an unreachable branch and regenerates the stored patch. All four gate artifacts pass with no figure below the Phase 0 baseline.

## Diff Scope

- Merge-base diff: 20 added and 28 modified paths. Production: `scripts/dev_tools/plan_gate_document.py`, `plan_gate_discrimination.py`, `validate_orchestration_artifacts.py`, and the three TypeScript twins under `extensions/drm-copilot/src/lib/validate/`; the rule file `.claude/rules/plan-acceptance-gates.md` and its bundle copy; the six `atomic-plan-contract` copies and the two planner agents with their bundle copies; the `0008` entry, its stored patch, and the README row. Tests: `test_plan_gate_guideline_cutoff.py`, `plan-gate-guideline-cutoff.test.ts`, the docs and parity tests of both runtimes, `test_validate_orchestration_artifacts_plan_gates.py`, and `planning-contract-wording.Tests.ps1`. The remaining paths are feature-folder documents and evidence.
- Not in the diff: `scripts/dev-tools/ProcessReductionLedger.psm1` and `ProcessReductionChain.psm1`, any workflow, the execution-environment brief, any Codex file, any `.github/instructions/` file, and any Epic #1019 folder. The `0007` entry change is the post-merge record of its merge commit (`reduction: 0007` token), not a stage F edit.
- Stage F commits: the reduction commit (subject carries `reduction: 0008`), the fix commit after it (same token), the D2 correction, the plan revision commits, and evidence commits.

## Policy Audit Rows

| Item | Status | Evidence |
| --- | --- | --- |
| Independence, Isolation, Determinism | PASS | New tests use in-memory strings and fixed values, read no clock, and create no file; the three gates are one parallel run each |
| Fast Execution | PASS | stage-f-python-test: 51 new cases in one file; stage-f-typescript-test (23-58): whole Jest run well under a minute |
| Baseline Coverage Documented | PASS | stage-f-powershell-test-baseline, stage-f-python-test-baseline, stage-f-typescript-test-baseline from the Phase 0 runs |
| No Coverage Regression | PASS | PowerShell 94.18% against 94.18%; Python 96.99% line and 94.17% branch against the same (one thread-timing arc outside the diff, recorded); TypeScript totals 97.09% line and 93.72% branch against 97.09% and 93.71% |
| Changed Files Meet Thresholds | PASS | plan_gate_document.py 100% line and 100% branch; plan_gate_discrimination.py 99.26% and 98.08%; validate_orchestration_artifacts.py 97.99% and 92.86%; plan-gate-document.ts 100% and 95.83%; orchestration-artifacts.ts 100% and 97.62%; plan-gate-discrimination.ts 100% and 100% |
| Per-file figure against its baseline | PASS | Every Python and TypeScript figure equals or exceeds its Phase 0 value; plan-gate-discrimination.ts moved from 98.28% to 100% branch after the fix removed the unreachable G5 arm |
| New Code Coverage | PASS | New cutoff, stamp-zone, and no-path code is run by the 51 Python and the added TypeScript cases at 100% line |
| Comprehensive, Positive, Negative, Edge, Error-handling coverage | PASS | Each K4 stamp shape and its zone, boundary minutes in each zone, the no-path case, a UTC stamp after the New York entry but before the instant, and the rejected names |
| Concurrency, State Transitions | N/A | Pure functions |
| Arrange-Act-Assert, Document Intent, External Dependencies, Mocks | PASS | New tests carry descriptive names and AAA structure; no mock and no external call |
| Pre-submission Review | PASS | This self-review |
| Simplicity, Reusability, Extensibility, Separation of concerns | PASS | One cutoff constant pair per runtime, a pure stamp-to-instant helper, an optional `planPath` parameter with a default; the fix removes a branch with no behavior |
| At or below the 800-line hard limit | PASS | validate_orchestration_artifacts.py about 500 lines (guidance tier); plan_gate_document.py and plan-gate-document.ts well below 700; new test files under 400 |
| Descriptive names, Docstrings | PASS | New functions carry docstrings or comment help |
| Error handling | PASS | Unreadable stamps keep the legacy guideline; no catch-all handler added |
| 1. Formatting | PASS | stage-f-format-lint: Black 7 files unchanged, Prettier clean, PoshQC `Already formatted`, no `Formatted` line; the fix file passes Prettier unchanged |
| 2. Linting | PASS | Ruff 0 findings, ESLint 0 findings (also after the fix), analyzer 0 findings |
| 3. Type checking | PASS | Pyright 0 errors; tsc 0 errors |
| 4. Testing / Full toolchain loop | PASS | Parallel Pester 16132 tests, 0 failures (rerun after the fix); pytest -n auto 16270 passed, 0 failed; Jest 5397 passed, 0 failed (rerun after the fix) |
| No single-process, seeded, reversed, or comparison run | PASS | One run of each gate, re-run only after the fix |
| Pester v6, PoshQC configuration, test location and naming | PASS | `PCW-SIZE-` rows added to the existing `planning-contract-wording.Tests.ps1` under `tests/scripts/claude-runtime/` |
| Python and TypeScript sections | PASS | Python tests under `tests/scripts/dev_tools/`; Jest tests under `extensions/drm-copilot/test/lib/validate/` |
| Evidence location and content | PASS | Artifacts under FEATURE/evidence/baseline, other, and qa-gates with write-time stamps and the four fields; SCRATCH appears as a token only; no host path |
| Tonality of added prose | PASS | Rule-file, entry, and skill additions are factual |

## Code Review Rows

| Item | Status | Evidence |
| --- | --- | --- |
| Findings table | PASS | No Blocking, Major, or Minor finding open; the one gate shortfall (plan-gate-discrimination.ts branch figure) was fixed by the fix commit and re-gated |
| Python implementation | PASS | Typed helper, stamp parsing without lookbehind, zone conversion in tests only through `zoneinfo` with the `tzdata` package already locked |
| TypeScript implementation | PASS | No `any`, no new dependency; the validators convert no time; `G5_SEVERITY` stays exported and unchanged, and the parity test that reads it still passes |
| PowerShell test rows | PASS | Rows assert exact copy and agent texts |
| Test quality | PASS | Assertions name exact values; boundary tests run both sides of the cutoff in both zones |
| No secrets; no unsafe command construction; input validation | PASS | None added; the stamp parser accepts only the recognized shapes |
| Configuration and path handling | PASS | Split on both separators so Linux and Windows read the same paths |
| Ledger chain | PASS | stage-f-powershell-test (23-58): ledger IsValid True with 8 entries and 0 errors; chain full and StopBefore 0001, 0006, 0008 IsValid True with 0 errors; `git apply -R --check` of the regenerated patch exit 0; PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-SUBCHAIN-HOLDS Passed |
| Patch matches the tree | PASS | The regeneration method was first run against the reduction commit and reproduced the stored patch byte for byte, then run against the fixed tree |

## Feature Audit Rows

| Item | Status | Evidence |
| --- | --- | --- |
| [F] G13 reports at 20 tasks and 250 lines in both validators with parity, at and one above the guideline, with and without a justification | PASS | `test_plan_gate_guideline_cutoff.py` (51 cases), `plan-gate-guideline-cutoff.test.ts`, and the parity `g13` rows pass in the pytest and Jest gates |
| [F] Parity tests run both sides of the cutoff and the no-path case, cover each K4 stamp shape, and keep the stamp result with absent wiring | PASS | `test_plan_path_reaches_g13_without_a_context`, the `validateArtifactWithWarnings` cases, and the boundary and shape tests pass |
| [F] The message states the applied guideline, the scope section describes the cutoff, and G13 lands as its own commit with its entry | PASS | The reduction commit holds the validators, rule file, contract copies, tests, entry, patch, and README row; the fix commit after it carries `reduction: 0008` |
| Zone-aware cutoff pair from one reading, widened result check, and date match | PASS | stage-f-g13-result-check (146 of 146 entries keep their result); stage-f-ledger-replay (reading 23:31:26Z); stage-f-cutoff-commit-time (author and committer dates equal the reading in UTC and America/New_York); the fix commit does not move the written cutoff values |
| The reduction as one commit with its entry, patch, and `reduction: 0008` subject | PASS | One reduction commit; the fix commit is a later commit with the same token, which the plan's Execution Terms permit |
| Chain replays of P0-T5 and P2-T5 and the P3-T2 chain tests | PASS | stage-f-g13-results, stage-f-ledger-replay, and stage-f-powershell-test (23-58) |
| D2 correction in its own commit with the [F] text unchanged | PASS | One commit edits one line of spec.md, and the diff of that commit holds no changed `[F]` line |
| D13: no baseline task, evidence, or comparison removed | PASS | All Phase 0 baseline artifacts and the Phase 3 comparisons are present; the earlier 23-45 and 23-39 gate artifacts are kept and superseded by the 23-58 artifacts |
| Out-of-scope set of `## Scope` | PASS | Diff Scope above; `plan.2026-11-07T12-43.md` carries an uncommitted refresh that no stage F commit stages |
| No tag pushed; nothing force-pushed | PASS | No remote tag names the issue; every push was a normal push |
| Phase 0 baseline read from artifacts | PASS | Each gate artifact compares with the greatest matching baseline artifact |

## Acceptance Criteria Status

- Source: `spec.md` and `user-story.md` of the feature folder (full-feature mode).
- Stage F criteria ([F], three items): 3 of 3 checked in each file.
- All items in `spec.md`: 64 total, 38 checked, 26 unchecked. All items in `user-story.md`: 57 total, 38 checked, 19 unchecked.
- Items remaining: the [G], [H], [I], and [J] criteria of later stages and the generic definition-of-done lines; none belongs to stage F.
