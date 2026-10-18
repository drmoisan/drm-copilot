# P2-T5 scoped decision and supersession handoff

Timestamp: 2026-10-18T09-09
Command: poetry run python SCRATCH/issue-980-p2t5-task-audit.py 4
EXIT_CODE: 0
Output Summary: Three staged files; 88 focused and 88 reversed tests pass; 183/183 lines and 75/76 branches covered; 186 prior accepted paths and 24 frozen paths unchanged; no findings.

## Scope, baseline and approved plan

- packages/discovery-runtime/src/drm_copilot_discovery/decision_rules.py (477 physical lines)
- tests/discovery_runtime/test_decision_rules.py (474 physical lines)
- tests/discovery_runtime/test_decision_supersession.py (357 physical lines)

This implements only P2-T5 in plan.2026-10-17T22-38.md. All three paths are new; the complete staged additions provide the reviewable diff. No extra production/test split was required. A draft test module exceeded 500 lines after formatting; moving retirement assertions into the already prescribed supersession test module restored compliance. The final maximum is 477 physical lines. No dependency, suppression, coverage setting, accepted earlier path, checkpoint or plan/AC was changed by this worker.

The accepted Phase 0 baseline has zero Ruff findings and Pyright diagnostics, 7,336 passing tests, six existing skips, 94.111715% line coverage and 88.783742% branch coverage. New files have zero baseline executable lines. Prior task preservation uses the latest accepted per-path hashes. Full repository feature QA remains Phase 11; this task did not repeat that full test/coverage run.

## Pure interfaces and deterministic semantics

validate_decisions(snapshot, index=..., evidence=...) returns immutable DecisionValidation with findings and current eligible ApprovedDecision records. Each includes a DecisionScope containing resolved repository/feature identity and client/platform/mode/dimension selectors. Empty non-feature selectors are unrestricted; every axis must overlap before same-key approvals conflict. Equal bare feature IDs from different repositories remain separate; ambiguous selected identity is rejected. The accepted ClaimContext and evidence assessment boundaries are reused without file/process/network access or a second catalog.

Approval requires a configured owner, accepted RFC3339 timestamp, intact local evidence in the decision's repository, and every evidence type required by that owner. Additional cited proof cannot hide a broken reference. Proposed/rejected records never establish target requirements; ready criteria on unapproved records are blocking. An eligible approval does not grant host mutation authority or establish implementation verification.

Supersession requires the same decision key and complete predecessor scope coverage. A partial overlap is an invalid edge and cannot retire predecessor requirements outside that overlap. Proposed successors cannot deactivate approvals. A valid acyclic chain may preserve approved or superseded historical records, while only current approvals supply target requirements. Directed cycles, including self-links and proposed cycles, are explicit blockers. When one valid successor covers several overlapping predecessors, those replaced predecessors no longer produce active conflicts. Orphan superseded labels are rejected. Arbitrary contradictory prose is not mechanically interpreted.

Retired feature claims require linked current approval covering the whole feature. Decision-backed unresolved resolution must match the active approval's owner, target decision text, required behavior and covering feature/dimension scope. Verified-observation resolution instead requires observation evidence and cannot introduce approved target behavior. Inputs and historical observations remain byte-for-byte unchanged. The retained claim validator independently requires unknown legacy observations to keep open legacy question coverage; resolving target policy does not establish a previously unknown historical fact. The measured integration case passes with a resolved target-policy question plus a separate, explicitly linked open legacy-observation question. Coordinator disposition retains accepted claim rules unchanged: approval cannot close the remaining observation uncertainty or relabel it verified. Carry this distinction into later acceptance/completion checks and documentation; full combined-mode composition remains P2-T9.

## Verification and retained corrections

Clean ordered pass 4: Black and Ruff pass all three paths, full repository Pyright reports zero diagnostics, and 88 focused tests pass. Reversed module order passes 88 tests in one process. Production coverage is 183/183 lines and 75/76 branches. All 19 measured new class/callable ranges have 100.000000% or greater line coverage. New lint/type/test-failure deltas are zero; accepted earlier hashes preserve prior changed-line coverage.

The tests cover configured-owner evidence conjunctions, malformed/missing evidence, proposed versus approved target state, wildcard/disjoint selectors, complete and partial replacement, multi-predecessor history, one/two/three-node cycles for approved and proposed records, cross-repository feature identity, retirement and both resolution bases. Immutable fixtures are shared; mutable records and captured payload stores are fresh per test. No unit test creates temporary files or invokes processes/network. Static docstring/line-limit/suppression/whitespace checks pass, as do staged whitespace and tracked quality-tier/resource contracts.

Failed command receipts are retained separately. The initial lint pass rejected Python 3.12 alias syntax under the supported Python 3.10 target, long strings/docstrings and one import ordering issue. The next typing pass exposed selector narrowing, untyped empty sets and dynamic fixture overrides; compatible aliases and explicit typed boundaries corrected them without suppressions. Pass 3 passed 87 tests. Independent review then identified a conflict incorrectly retained between two fully superseded predecessors; the focused multi-predecessor regression and current-approval conflict filtering corrected it. Prior accepted claim rules were not modified. Final independent acceptance remains executor-owned.

Exact staged hashes, prior/frozen inventories and callable ranges: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t5-coverage-metrics.2026-10-18T09-09.json.
Raw final coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t5-coverage.2026-10-18T09-09.json.

## Separate command evidence

- evidence/regression-testing/p2t5-callable-preaudit-pass4.2026-10-18T09-07.md
- evidence/regression-testing/p2t5-executor-probe-setup-pass1.2026-10-18T09-07.md
- evidence/regression-testing/p2t5-executor-probe-setup-pass2.2026-10-18T09-07.md
- evidence/regression-testing/p2t5-executor-review.2026-10-18T09-07.md
- evidence/regression-testing/p2t5-format-batch.2026-10-18T09-03.md
- evidence/regression-testing/p2t5-format-draft.2026-10-18T09-00.md
- evidence/regression-testing/p2t5-format-pass1.2026-10-18T09-03.md
- evidence/regression-testing/p2t5-format-pass2.2026-10-18T09-04.md
- evidence/regression-testing/p2t5-format-pass3.2026-10-18T09-05.md
- evidence/regression-testing/p2t5-format-pass4.2026-10-18T09-07.md
- evidence/regression-testing/p2t5-format-tests-draft.2026-10-18T09-02.md
- evidence/regression-testing/p2t5-format-type-correction.2026-10-18T09-05.md
- evidence/regression-testing/p2t5-import-format-correction.2026-10-18T09-04.md
- evidence/regression-testing/p2t5-isolation-pass4.2026-10-18T09-09.md
- evidence/regression-testing/p2t5-lint-pass1.2026-10-18T09-04.md
- evidence/regression-testing/p2t5-lint-pass2.2026-10-18T09-04.md
- evidence/regression-testing/p2t5-lint-pass3.2026-10-18T09-05.md
- evidence/regression-testing/p2t5-lint-pass4.2026-10-18T09-07.md
- evidence/regression-testing/p2t5-packaging-pass4.2026-10-18T09-09.md
- evidence/regression-testing/p2t5-quality-tiers-pass4.2026-10-18T09-09.md
- evidence/regression-testing/p2t5-review-correction-format.2026-10-18T09-07.md
- evidence/regression-testing/p2t5-static-before-pass4.2026-10-18T09-07.md
- evidence/regression-testing/p2t5-tests-pass3.2026-10-18T09-05.md
- evidence/regression-testing/p2t5-tests-pass4.2026-10-18T09-07.md
- evidence/regression-testing/p2t5-types-pass2.2026-10-18T09-04.md
- evidence/regression-testing/p2t5-types-pass3.2026-10-18T09-05.md
- evidence/regression-testing/p2t5-types-pass4.2026-10-18T09-07.md

TASK_READY_FOR_VERIFICATION. No P2-T6 or later task is released by this handoff.
