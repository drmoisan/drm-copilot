# Remediation Inputs: TaskMaster #469 Fixture Byte Portability (#614)

- Timestamp: 2026-09-02T22-17
- Review status: REMEDIATION_REQUIRED
- Reviewed head: 6230d7912e1ea6ab600609c11420caad74ffed6e
- Base branch: main
- Merge base: 9f3514bf5da84110f23617382cbbeabf54f27427
- Work mode: full-feature
- Primary finding: FR-614-004
- Prior findings: FR-614-001 RESOLVED; FR-614-003 RESOLVED
- Required plan target: docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-09-02T22-17.md

## Authoritative Requirements

These remediation inputs are the primary requirements source for the next plan. The implementation must also preserve the feature requirements and completed behavior in:

- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/plan.2026-08-31T07-58.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-08-31T17-20.md

## Finding FR-614-004

### Observed defect

Both TaskMaster #469 plan fixture files are committed with LF bytes and hash to:

089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864

Both fixture manifests pin:

54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f

Repository .gitattributes line 1 applies text=auto and eol=lf to both paths. The exact committed-head verification failed both directions at tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py:77.

### Affected paths

- .gitattributes
- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/fixture.json
- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md
- tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/fixture.json
- tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md
- tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py

The planner must determine the smallest correct changed-path set. A listed affected path is not automatic permission to edit every path.

### Required behavior

1. A fresh checkout of the committed head must contain a deterministic byte representation for both pinned plan fixtures.
2. Each fixture.json plan.sha256 value must equal the SHA-256 of its corresponding committed plan bytes.
3. The chosen representation must preserve the feature's provenance intent. Do not silently rewrite the test to normalize newlines before hashing or otherwise weaken raw-byte identity.
4. Claude-to-Codex and Codex-to-Claude fixtures must continue to prove the same TaskMaster #469 plan identity and symmetric continuation behavior.
5. The focused pinned-hash test, full Python coverage suite, and integration/parity suite must pass from unmodified checkout bytes. No pre-test, in-test, or working-copy hydration is allowed.
6. The fix must behave consistently on Windows and Linux checkouts under repository Git attributes.
7. Spec AC13 and user-story criterion 11 may be checked again only after direct clean-byte verification passes.
8. FR-614-001 canonical containment and FR-614-003 coverage remediation must remain passing.

### Required verification

- git status --short --branch and git diff --check against the merge base.
- git check-attr -a for both plan fixture paths.
- SHA-256 calculation for each working-tree plan plus proof that each file has no diff from the index/HEAD.
- poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py -k fixture_hashes_and_source_history_are_pinned --no-cov -q
- poetry run black .
- poetry run ruff check .
- poetry run pyright
- poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing
- poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py tests/scripts/dev_tools/test_orchestration_handoff_adapters.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
- TypeScript focused containment tests and coverage verification sufficient to prove FR-614-001 and FR-614-003 remain resolved.
- Full MCP PoshQC format, analyze, and test gates with scan_folders omitted where the repository workflow requires them.
- Fresh-checkout or index-materialization verification that does not rely on the current worktree's pre-existing line endings.

Each command-step evidence artifact must use the canonical feature evidence tree and include Timestamp, exact Command, numeric EXIT_CODE, and Output Summary. Coverage evidence must include numeric line and branch values where measured.

## Acceptance Criteria Reconciliation

- spec.md AC13: FAIL and now unchecked.
- user-story.md criterion 11: FAIL and now unchecked.
- Remaining authoritative criteria: 26 PASS and checked.
- issue.md contains early-draft checkboxes but is not an authoritative AC source under full-feature mode.

The remediation executor may change only the two failing authoritative markers from unchecked to checked, one at a time, after their mapped verification passes. Criterion text must remain unchanged.

## Do Not Do

- Do not normalize fixture bytes in production code, test helpers, test setup, or a pre-test command merely to make the assertion pass.
- Do not replace raw-byte SHA-256 verification with text-normalized hashing.
- Do not update pinned metadata without establishing and documenting the provenance of the chosen committed byte representation.
- Do not weaken, skip, deselect, or delete the pinned-hash test.
- Do not edit unrelated production, hook, schema, registry, publishing, orchestration, or policy files.
- Do not regress canonical path containment, failure precedence, provider neutrality, scheduler ownership, replay prevention, archive integrity, or current coverage.
- Do not add dependencies, suppressions, coverage exclusions, temporary-file tests, sleeps, retries, or external-service requirements.
- Do not commit, push, create a PR, monitor CI, or merge within the remediation plan; the parent orchestrator owns those lifecycle steps. Merge is not authorized.

## Evidence Package

- artifacts/pr_context.summary.txt
- artifacts/pr_context.appendix.txt
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-02T22-17.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-09-02T22-17.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-09-02T22-17.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/python-taskmaster-fixture-line-endings.2026-09-02T22-17.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-python-pytest-coverage.2026-09-02T20-55.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-integration-and-parity.2026-09-02T20-55.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-typescript-jest-coverage.2026-09-02T20-55.md
- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/remediation-powershell-pester-coverage.2026-09-02T20-55.md

## Completion Condition

Remediation is complete only when the selected byte-preservation contract is auditable, both fixture digests match unmodified committed bytes on the required checkout platforms, all required commands pass in one clean loop, spec AC13 and user-story criterion 11 are individually rechecked, fresh evidence is written, and a new full feature review reports PASS.
