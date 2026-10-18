# P2-T4 observation and runtime claim handoff

Timestamp: 2026-10-18T08-54
Command: poetry run python SCRATCH/issue-980-p2t4-task-audit.py 5
EXIT_CODE: 0
Output Summary: Four staged files; 98 focused and 98 reversed tests pass; 217/220 lines and 125/132 branches covered; 182 prior accepted paths and 24 frozen paths unchanged; no findings.

## Scope, baseline and approved plan

- packages/discovery-runtime/src/drm_copilot_discovery/claim_rules.py (341 physical lines)
- packages/discovery-runtime/src/drm_copilot_discovery/runtime_claim_rules.py (237 physical lines)
- tests/discovery_runtime/test_observation_claims.py (379 physical lines)
- tests/discovery_runtime/test_runtime_claims.py (484 physical lines)

This implements only P2-T4 in plan.2026-10-17T22-38.md. The coordinator approved the same-component runtime_claim_rules.py split under the plan's 500-line provision: claim_rules.py retains shared graph/evidence support and observed-feature checks; runtime_claim_rules.py owns summary/run/expectation checks. The maximum physical length is 484. All four paths are new, with zero baseline executable lines. Their complete staged additions are the reviewable diff. No dependency, suppression, coverage setting, accepted earlier path, plan/AC or checkpoint was changed by this worker.

The accepted Phase 0 baseline has zero Ruff findings and Pyright diagnostics, 7,336 passing tests, six existing skips, 94.111715% line coverage and 88.783742% branch coverage. Task-local changes are checked against that baseline and latest prior-task hash receipts. Full repository feature QA remains Phase 11; the complete repository test/coverage run was not repeated for this task.

## Interfaces and supported claims

validate_claims(snapshot, index=..., evidence=...) returns immutable ClaimValidation.findings and reuses accepted graph/evidence assessments. ClaimContext groups links once and validates exact repository/pin evidence without I/O, promotion, or mutation. Verified observations require usable evidence; unknown/contradictory dimensions require linked open same-feature unresolved coverage; intentionally-unspecified observations require a linked scoped declared approval and rationale. Confidence labels do not establish state. Root summaries cannot conceal unresolved required dimensions or dimensionless open questions. Runtime-typed references are checked independently so a valid source reference cannot conceal invalid runtime proof.

An executed scenario summary must match at least one recorded run on result_status, expected_result, core environment identity (id/platform/operating_mode/client_id), and observed pre/post states. Each executed run is checked independently for runtime proof, recorded observation, and pre/post captures. Different historical results and expectations remain valid when one run supports the current summary. Array order does not imply chronology or select a latest run. Unknown expectation basis remains null and cannot establish a passed or failed result. Draft/not-run/blocked observations remain structurally usable without fabricated execution evidence.

Source-contract expectation basis requires a linked known evidenced ready criterion, or a verified evidenced known dimension named by the scenario observation_plan. An unrelated known trigger cannot justify a plan addressing an unknown state transition; a target decision alone is insufficient. Prior-runtime-observation basis requires a separate observed run with null expected_result, complete runtime/pre/post proof and matching core environment. This establishes recorded supporting provenance without claiming chronological ordering. A current pass alone does not establish a prior observation.

Upstream schema/reference/evidence/revision findings remain separate for later combined validation. Full approval authority, decision conflicts, required-mode activation and completion rules remain later tasks.

## Ordered checks and isolation

Clean ordered pass 5: Black and Ruff pass all four files; full repository Pyright reports zero diagnostics; 98 focused tests pass. Reversed module order passes 98 tests in one process. The 20 measured new class/callable ranges have at least 90.909091% line coverage. All new modules exceed 90% lines and 75% branches. Ruff, typing and test-failure deltas are zero; exact prior hashes preserve the earlier accepted changed-line coverage.

| Module | Covered lines | Covered branches |
| --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/claim_rules.py | 127/128 | 70/72 |
| packages/discovery-runtime/src/drm_copilot_discovery/runtime_claim_rules.py | 90/92 | 55/60 |

Tests reuse immutable catalog/profile fixtures and build fresh in-memory documents, manifests and payloads. They create no temporary files and invoke no network or subprocess. Static checks find no missing function/class docstring, physical-limit violation, suppression, external unit-test operation or trailing whitespace. Tracked quality-tier and packaged schema-resource contracts pass. Exact staged hashes and all 182 prior/24 frozen paths were verified.

Failed evidence is retained. The initial independent review found four unsupported claims: omitted dimensionless unresolved question, a source-type reference placed in runtime_evidence_refs, an unknown source-contract basis, and a prior-runtime basis supported only by the current pass. Focused regressions now cover these boundaries, including unrelated known dimensions and absent/foreign prior proof. Earlier ordered attempts stopped at typing of required-dimension values and dynamic test mappings, or comment/docstring line widths; corrections added explicit narrowing and the fixture overrides parameter without suppressions. No pytest failure occurred. The final independent bounded probe passes 34/34 against unchanged production bytes. Final acceptance remains executor-owned.

Aggregate commands and retained failed attempts: evidence/regression-testing/p2t4-gates.2026-10-18T08-44.md.
Initial independent review: evidence/regression-testing/p2t4-executor-review.2026-10-18T08-45.json.
Exact staged hashes, prior/frozen inventories and callable ranges: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t4-coverage-metrics.2026-10-18T08-54.json.
Raw final coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t4-coverage.2026-10-18T08-54.json.

TASK_READY_FOR_VERIFICATION. No P2-T5 or later task is released by this handoff.


## Command-receipt format correction — 2026-10-18T09-02

The retained aggregate command log was normalized into individual write-time-stamped receipts without rerunning commands or changing their recorded results. Original capture/start timestamps, commands, exit codes and output are preserved. See the [verified extraction index](../regression-testing/p2-command-receipt-normalization-verification.2026-10-18T09-02.md) for the one-to-one mapping and unchanged aggregate hashes. This note corrects evidence format only; the task acceptance and production-byte verification above are unchanged.
