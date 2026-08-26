# Feature Audit: Routed-subagent launch binding (Issue #552)

**Audit Date:** 2026-08-25
**Feature Folder:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552`
**Base Branch:** `main` at `66c648db3ecae063ef873b3e76b00ca0d9fb7944`
**Head Branch:** `bug/codex-subagent-routing-attestation-launch-binding-552` at `cacb27f3af2c0c2d56aeb9b9663fbe15b67a8865`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Base branch:** `main` (`66c648db3ecae063ef873b3e76b00ca0d9fb7944`)
- **Head branch/commit:** `bug/codex-subagent-routing-attestation-launch-binding-552` (`cacb27f3af2c0c2d56aeb9b9663fbe15b67a8865`)
- **Merge base:** `66c648db3ecae063ef873b3e76b00ca0d9fb7944`
- **Evidence sources:** primary `artifacts/pr_context.summary.txt`; secondary `artifacts/pr_context.appendix.txt`; feature `evidence/**` listed in the PR context.
- **Requirements source:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/spec.md`.
- **Work mode resolution note:** `issue.md` declares `- Work Mode: full-bug`; therefore `spec.md` is the sole authoritative acceptance-criteria source.
- **Scope note:** The PR-context pair matches the reviewed head and resolved `origin/main` base. The review is limited to the supplied commit range.

## Acceptance Criteria Inventory

**Authoritative AC source file:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/spec.md`.

1. Before every normal routed `spawn_agent` call, the selected checkpoint durably contains a non-empty-phase, delegation-identified receipt whose `deployment_agent`, model, and reasoning effort exactly match the child being started.
2. The launched child is exactly the resolver-returned generated profile, and `Get-CodexAgentProfileAttestation`/`Test-CodexAgentProfileBinding` confirm matching profile name, model, reasoning effort, path, and SHA-256.
3. A generic logical alias, absent receipt, late receipt, model mismatch, reasoning mismatch, profile-path mismatch, or profile-SHA mismatch is rejected and cannot authorize a routed child.
4. A nested child is independently resolved from logical family, complexity band, execution context, and monotonic ceiling; a parent C3 profile cannot authorize it, and C3-elevated selection remains correct when context requires it.
5. `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` proves start-only authority-store behavior: an exact pre-spawn nested receipt records `routing_valid: true`, while absent or late receipt records `routing_valid: false` before the child attempts a mutation.
6. Root and bundled hook/configuration copies, generated profiles, and pack manifests remain compliant with existing source/bundle parity checks.
7. Updated Pester and pytest regression tests pass, including resolver selection and generated-profile parity coverage, and changed branches meet repository coverage policy.
8. The applicable formatting, linting, type-checking, and test loop passes in one final run; fail-before, pass-after, baseline/comparison, and QA evidence is under the feature's canonical `evidence/` directories.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| 1 | Durable exact receipt before nested launch | PASS | Routing skill/profile diff; `pass-after-launch-binding.2026-08-25T16-32.md` | `poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py -k routed_delegation_launch_binding` | Requires independent resolution, durable flush, and resolver-returned profile. |
| 2 | Exact generated profile and attestation binding | PASS | `pester-start-only-attestation.2026-08-25T16-51-37.md` | `mcp__drm-copilot__run_poshqc_test` | Pester evidence covers profile/model/reasoning/path/SHA binding. |
| 3 | Invalid receipt shapes are rejected | PASS | Same Pester evidence | `mcp__drm-copilot__run_poshqc_test` | Covers generic alias, absent/late receipt, and all stated mismatches. |
| 4 | Independent nested C3 selection | PASS | `pytest-nested-c3-selection.2026-08-25T16-46-02.md` | `poetry run pytest tests/scripts/dev_tools/test_resolve_codex_deployment.py -k task_researcher` | Covers standalone C3 and both elevated triggers. |
| 5 | Start-only authority-store behavior | PASS | `pester-start-only-attestation.2026-08-25T16-51-37.md` | `mcp__drm-copilot__run_poshqc_test` | 9 passing Pester tests, including valid-before and invalid-before-mutation cases. |
| 6 | Root/bundle/generated profile parity | PASS | `pytest-source-bundle-parity.2026-08-25T16-52-03.md`; `generated-profile-drift-check.2026-08-25T16-52-22.md` | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | Review SHA-256 comparisons also matched all seven changed routing assets. |
| 7 | Tests and coverage pass | PASS | `final-python-test-coverage.2026-08-25T16-59-34.md`; `coverage-comparison.2026-08-25T17-00-20.md` | Final aggregate pytest and Pester commands recorded in QA evidence | 60 pytest and 9 Pester tests pass; changed Python line coverage is at least 93.48%. |
| 8 | Final toolchain and canonical evidence | PASS | `final-qa-single-pass.2026-08-25T17-00-43.md`; baseline, regression, and QA folders | P6-T1 through P6-T7 commands recorded in final QA artifact | All seven final steps exited 0 after the documented restart. |

## Summary

**Overall Feature Readiness: PASS**

- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:** None.

**Recommended follow-up verification steps:** Continue with normal PR review and CI. No corrective implementation work is identified by this audit.

## Acceptance Criteria Check-off

All eight authoritative `spec.md` acceptance criteria were already checked before this review. Each is evaluated as PASS above; no acceptance-criteria source file was modified by the reviewer.

### AC Status Summary

- Source: `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/spec.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 8 | 8 | 0 | Checkbox-backed and all checks pre-existed this review. |
