Suggested title: Bind routed subagents to exact durable deployment receipts

## Summary

- Require a durable, exact deployment receipt before every normal routed subagent launch.
- Launch only the resolver-returned generated profile and retain fail-closed profile, authority-store, mutation, and stop-time enforcement.
- Preserve independent nested-child selection across logical family, complexity, execution context, and monotonic ceiling.
- Synchronize routing customizations and generated profiles while excluding ephemeral `.codex/state/**` files from customization payloads.
- Add regression, parity, and final-QA evidence for the routing and payload contracts.

## Why

Nested routed workers could start before their exact deployment receipt was durable in the checkpoint read by `SubagentStart`. That ordering produced an invalid authority-store attestation and caused the downstream mutation gate to block the child. The change makes the pre-spawn receipt/profile binding explicit without relaxing existing fail-closed controls.

## What Changed

- Core routing behavior: resolve and validate the generated deployment profile, persist the exact receipt with phase and delegation identity to the selected checkpoint, flush it, and then launch that exact profile.
- Routing configuration and distribution: update routing skill and generated orchestrator-profile assets, keep root and bundled customization copies aligned, and exclude ephemeral runtime state from published payloads.
- Tests: add Pester coverage for valid pre-spawn admission and rejected receipt/profile mismatches, plus pytest coverage for nested C3 selection, launch binding, source/bundle parity, and runtime-state exclusion.
- Documentation and evidence: record fail-before/pass-after results, acceptance-criteria reconciliation, coverage comparison, final QA, and plan validation.

## Architecture / How It Fits Together

1. The coordinator resolves the child profile from its logical family, complexity, execution context, and monotonic ceiling.
2. It validates and durably appends the exact receipt to the checkpoint that `SubagentStart` will read.
3. It starts only the resolver-returned `deployment_agent` after the durable write completes.
4. `SubagentStart` records the authority-store attestation, while mutation and stop-time gates continue to reject missing, late, alias, model, reasoning, profile-path, and SHA-256 mismatches.

## Verification

### Completed

- Completed the restarted Phase 6 formatting, linting, type-checking, and test loop with exit code 0 for all seven steps and no subsequent restart.
- PoshQC formatting and analysis passed; the final Pester run passed 9 tests with 0 failures, errors, or skips.
- Final aggregate pytest passed 60 tests. Coverage was non-regressing: `resolve_codex_deployment.py` was 100.00% line and branch covered, and the changed push-down module was 93.48% line covered.
- Verified 3 nested-C3 resolver-selection tests, 1 durable launch-binding regression test, 31 source/bundle and runtime-state-exclusion parity tests, and a generated-profile/pack-manifest drift check.
- Validated the exact canonical plan artifact successfully.

### Recommended

- Run `poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py -k routed_delegation_launch_binding` on the PR head.
- Run `poetry run pytest tests/scripts/dev_tools/test_resolve_codex_deployment.py -k task_researcher` on the PR head.
- Run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`.
- Run the scoped PoshQC format, analyze, and Pester commands for `model-profile-attestation.Tests.ps1` during CI or PR review.

## Backward Compatibility / Migration Notes

- No public CLI or API change is introduced.
- Existing valid exact receipts remain valid and use the existing checkpoint schema.
- Missing, late, or logical-alias receipts now fail before launch rather than allowing a child to start and fail later.
- No migration or feature flag is required.

## Risks and Mitigations

- Persisting to a checkpoint other than the one read at `SubagentStart` would recreate the ordering failure; the coordinator selects and validates the same checkpoint before launch.
- Accepting a logical alias could hide an incorrect profile selection; exact generated-profile, model, reasoning, path, and SHA-256 binding remains required.
- Source-only changes could create bundled-customization drift; parity tests, generated-profile drift checks, and successful customization synchronization mitigate this risk.
- The configured PowerShell hook target reports 0/0 measurable lines in both baseline and final runs; the final Pester result is non-regressing and no PowerShell production lines were changed in this batch.

## Review Guide

- Review the normal routed-delegation path for the durable receipt write before `spawn_agent` and its use of the resolver-returned generated profile.
- Review the Pester negative cases for absent, late, alias, model, reasoning, path, and SHA-256 mismatches.
- Review nested C3 and elevated selection tests to confirm the parent profile cannot authorize a child.
- Review customization publishing and parity coverage to confirm ephemeral `.codex/state/**` content is excluded while required routing assets remain synchronized.

## Follow-ups

- Continue with normal PR review and CI.
- During the next nested routed delegation, review the checkpoint receipt and authority-store attestation for exact profile binding; do not treat a late receipt or alias as successful.

## GitHub Auto-close

- Closes #552

## Related issues / PRs

- None.
