# Feature Audit: Current Codex model routing (#977)

**Audit Date:** 2026-10-17T19-07 UTC
**Feature Folder:** docs/features/active/2026-10-17-current-codex-model-routing-977
**Base Branch:** main
**Head Branch:** feature/current-codex-model-routing-977
**Work Mode:** full-feature, from issue.md persisted marker.
**Audit Type:** Refreshed full feature acceptance review; prior audit set preserved.
**Template:** MCP feature-audit-template copied to this path before population.

## Scope and Baseline

- Base and merge-base: main / f1408d0040e11432f3efbf4f7b6af4115c0b1f3d; timestamp 2026-10-17T12:17:11-05:00.
- Reviewed head: c9902b54ffdb146b5039d5b7aaf4c1145afe5066.
- Primary evidence: artifacts/pr_context.summary.txt; secondary: artifacts/pr_context.appendix.txt. Both carry identical generation timestamp 2026-10-17 19:06:08 UTC and exact reviewed head.
- Feature folder was selected from primary changed scoping documents and issue suffix 977; source issue.md contains Work Mode: full-feature.
- Authoritative AC sources: spec.md and user-story.md. All checkbox items in these sources are included independently, including seeded conditions. Early draft issue.md checkboxes are supplemental, not authoritative.
- Scope: complete feature-vs-base diff, all changed language coverage and actual bundled production copies. No caller narrowing was supplied or accepted.
- No source, test, config, generated-profile or bundled-code changes occurred since prior review. Full language QA and coverage evidence is reused across the complete current feature-vs-base scope. Current new evidence and checkbox changes were independently examined.
- Live gh reads establish draft/open PR #978 at 6b7572ae6fcfe863d13609fe9452d5f769715209 with 26 passing checks. The local reviewed check-off commit c9902b54ffdb146b5039d5b7aaf4c1145afe5066 still awaits required resulting-head re-verification.
- Coordinator corrected two nonblocking local-vsix evidence-document nits in the working tree after this head; exact MCP rejection remains preserved. No criterion text or executable file changed.

## Acceptance Criteria Inventory

The following inventory preserves source criterion text. All 16 source boxes are checked: 13 local items by the executor and three CI-dependent items by the item's orchestrator during the initial-green S9 check-off step. The latter remain conditional in this review until the resulting commit is pushed and CI is reverified.

### From spec.md

- SPEC-01: Current policy, base agents, generated variants, runtime defaults, and validators use the exact model/effort table above, with no stale legacy default in an active Codex routing path.
- SPEC-02: C1-C4 decisions, elevated C3 activation in both epic-child contexts and under a C4 ceiling, forced epic Astra/ultra, aliases, and monotonic ceilings are verified against the shared routing corpus without changing topology budgets.
- SPEC-03: Invalid/absent inputs and profiles, wrong exact model/effort/path/hash, invalid topology, failed start attestation, and unavailable exact models retain fail-closed behavior without fallback.
- SPEC-04: The Codex generator passes `--check`; resource, pack-manifest, wrapper, handoff, and routing parity contracts pass for affected distributable surfaces.
- SPEC-05: Current model-routing documentation and skills describe the replacement table and Codex epic ultra capability; historical checkpoint/fixture evidence and unrelated provider settings are preserved.
- SPEC-06: Receipt schema and diagnostic behavior remain unchanged; newly resolved receipts identify the actual current generated profile and hash, and validators continue to reject stale former-model receipts under current policy without a compatibility exception.
- SPEC-07: Complete applicable local Python, PowerShell, and TypeScript toolchains pass in formatting → linting → type-checking → testing order, with PowerShell type checking omitted; required changed-file coverage and isolation checks have recorded evidence.
- SPEC-08 (CI-dependent): The item's orchestrator records required CI success at the final PR head, then pushes any CI criterion check-off and verifies CI again so the recorded head equals the final PR head before completion.
- Boundary tests cover all four complexity bands, all three execution contexts, C3/C4 ceiling transitions, and both root epic personas.
- Current generated-profile freshness and mirror parity tests pass, and exact-model mismatch rejection is tested independently of successful resolution.
- CI-dependent: Local toolchain evidence and final PR-head CI evidence are recorded separately; CI remains pending until the remote gate succeeds.

### From user-story.md

- STORY-01: Operators resolve C1 to `gpt-6-luna`/low, C2 to `gpt-6.1-sol`/medium, and standalone C3 under a C3 ceiling to `gpt-6.1-sol`/high through the existing command surface.
- STORY-02: Elevated C3 resolves `gpt-6-astra`/high under the existing epic-child or C4-ceiling conditions, C4 resolves Astra/max, and both root epic personas resolve Astra/ultra without changing file-count topology or ceiling rules.
- STORY-03: Missing/unavailable exact models and invalid profile/model/effort/hash receipts still block delegation; operators receive the existing diagnostic and no silent fallback occurs.
- STORY-04: Maintainers can regenerate a synchronized current policy/profile/bundle set that passes routing, generator, mirror, and manifest checks while preserving historical evidence and unrelated provider settings.
- STORY-05 (CI-dependent): Completion includes applicable local toolchain evidence and required CI success recorded for the final PR head, with any CI check-off push reverified at its resulting head.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| 1 | SPEC-01: Current policy, base agents, generated variants, runtime defaults, and validators use the exact model/effort table above, with no stale legacy default in an active Codex routing path. | PASS | Current policy, generated profiles and resolver constants; generator --check and cross-language deployment corpus. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 2 | SPEC-02: C1-C4 decisions, elevated C3 activation in both epic-child contexts and under a C4 ceiling, forced epic Astra/ultra, aliases, and monotonic ceilings are verified against the shared routing corpus without changing topology budgets. | PASS | Topology, elevated contexts/C4 ceiling, forced epic personas and corpus tests; no topology/budget/effort delta. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 3 | SPEC-03: Invalid/absent inputs and profiles, wrong exact model/effort/path/hash, invalid topology, failed start attestation, and unavailable exact models retain fail-closed behavior without fallback. | PASS | Malformed inputs, profiles, model/effort/path/hash, topology, failed attestation and unavailable-model rejection tests retained. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 4 | SPEC-04: The Codex generator passes `--check`; resource, pack-manifest, wrapper, handoff, and routing parity contracts pass for affected distributable surfaces. | PASS | Generator freshness; current resource/manifest/wrapper/handoff contracts; mirror comparison. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 5 | SPEC-05: Current model-routing documentation and skills describe the replacement table and Codex epic ultra capability; historical checkpoint/fixture evidence and unrelated provider settings are preserved. | PASS | Five authorized current skills and mirrors; epic instruction prose; historical/provider scope preserved. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 6 | SPEC-06: Receipt schema and diagnostic behavior remain unchanged; newly resolved receipts identify the actual current generated profile and hash, and validators continue to reject stale former-model receipts under current policy without a compatibility exception. | PASS | Unchanged receipt schema and diagnostics; Python/TypeScript stale former-model rejection tests independently pass. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 7 | SPEC-07: Complete applicable local Python, PowerShell, and TypeScript toolchains pass in formatting → linting → type-checking → testing order, with PowerShell type checking omitted; required changed-file coverage and isolation checks have recorded evidence. | PASS | Complete ordered toolchain, raw coverage and seeded isolation evidence; reviewer repeated Python/TypeScript checks. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 8 | SPEC-08 (CI-dependent): The item's orchestrator records required CI success at the final PR head, then pushes any CI criterion check-off and verifies CI again so the recorded head equals the final PR head before completion. | PARTIAL | ci-initial evidence and live PR #978: 26 checks pass at prior head; resulting check-off head not yet reverified. | Final PR-head CI gate (coordinator-owned) | Remediability: awaiting_ci; source checked at authorized initial-green S9 step; final re-verification pending. |
| 9 | Boundary tests cover all four complexity bands, all three execution contexts, C3/C4 ceiling transitions, and both root epic personas. | PASS | Boundary corpus and generation/mirror contract tests pass. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 10 | Current generated-profile freshness and mirror parity tests pass, and exact-model mismatch rejection is tested independently of successful resolution. | PASS | Boundary corpus and generation/mirror contract tests pass. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 11 | CI-dependent: Local toolchain evidence and final PR-head CI evidence are recorded separately; CI remains pending until the remote gate succeeds. | PARTIAL | ci-initial evidence and live PR #978: 26 checks pass at prior head; resulting check-off head not yet reverified. | Final PR-head CI gate (coordinator-owned) | Remediability: awaiting_ci; source checked at authorized initial-green S9 step; final re-verification pending. |
| 12 | STORY-01: Operators resolve C1 to `gpt-6-luna`/low, C2 to `gpt-6.1-sol`/medium, and standalone C3 under a C3 ceiling to `gpt-6.1-sol`/high through the existing command surface. | PASS | Current policy, generated profiles and resolver constants; generator --check and cross-language deployment corpus. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 13 | STORY-02: Elevated C3 resolves `gpt-6-astra`/high under the existing epic-child or C4-ceiling conditions, C4 resolves Astra/max, and both root epic personas resolve Astra/ultra without changing file-count topology or ceiling rules. | PASS | Topology, elevated contexts/C4 ceiling, forced epic personas and corpus tests; no topology/budget/effort delta. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 14 | STORY-03: Missing/unavailable exact models and invalid profile/model/effort/hash receipts still block delegation; operators receive the existing diagnostic and no silent fallback occurs. | PASS | Malformed inputs, profiles, model/effort/path/hash, topology, failed attestation and unavailable-model rejection tests retained. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 15 | STORY-04: Maintainers can regenerate a synchronized current policy/profile/bundle set that passes routing, generator, mirror, and manifest checks while preserving historical evidence and unrelated provider settings. | PASS | Generator freshness; current resource/manifest/wrapper/handoff contracts; mirror comparison. | Commands and exact scope in policy-audit.2026-10-17T19-07.md Appendix B | Already checked; verified in this review. |
| 16 | STORY-05 (CI-dependent): Completion includes applicable local toolchain evidence and required CI success recorded for the final PR head, with any CI check-off push reverified at its resulting head. | PARTIAL | ci-initial evidence and live PR #978: 26 checks pass at prior head; resulting check-off head not yet reverified. | Final PR-head CI gate (coordinator-owned) | Remediability: awaiting_ci; source checked at authorized initial-green S9 step; final re-verification pending. |

## Summary

**Overall Feature Readiness:** BLOCKED (HALT_NON_REMEDIABLE).

- PASS: 13 criteria.
- PARTIAL: 3 CI-dependent criteria.
- FAIL: 0 criteria.
- UNVERIFIED: 0 criteria.

Locally delivered behavior and coverage PASS. R1 is a separate operational completion blocker: installed MCP checkpoint validation requires gpt-5.6-terra for current Sol receipts. Spec Constraints & Risks explicitly requires a matching installed validator for authoritative completion. R1 is external_dependency and is not resolved by weakening approved source policy, relabelling old launch records or adding compatibility exceptions.

R2 covers the three conditional CI criteria and is awaiting_ci. Initial CI passed at 6b7572ae6fcfe863d13609fe9452d5f769715209, supporting the coordinator-owned S9 check-off. Required resulting-head revalidation is still outstanding for local reviewed head c9902b54ffdb146b5039d5b7aaf4c1145afe5066; checkboxes alone do not prove this final step.

The coordinator may prepare a draft PR and CI. Merge/DONE must wait for matching installed validation, truthful current launch/checkpoint evidence and exact final-head CI. No autonomous remediation finding exists and no remediation plan/planner delegation is warranted.

## Acceptance Criteria Check-off

No requirement source checkbox was changed or reverted by this reviewer. All 13 local PASS items were already checked and individually verified. Three CI-dependent items were checked by the item's orchestrator in the specifically authorized initial-green S9 continuation; their evaluation remains PARTIAL until resulting-head re-verification. This interim check-off is preserved without claiming 16 criteria fully verified. Criterion wording was preserved.

### Acceptance Criteria Status

- Source: docs/features/active/2026-10-17-current-codex-model-routing-977/spec.md and docs/features/active/2026-10-17-current-codex-model-routing-977/user-story.md.
- Total AC items: 16.
- Source boxes checked: 16 (13 fully verified local items; three conditional CI items).
- Checked off and fully delivered: 13.
- Remaining unchecked: 0.
- Remaining verification obligations: 3.
- Items remaining to verify at the final resulting PR head:

- spec.md: SPEC-08 (CI-dependent): The item's orchestrator records required CI success at the final PR head, then pushes any CI criterion check-off and verifies CI again so the recorded head equals the final PR head before completion.
- spec.md: CI-dependent: Local toolchain evidence and final PR-head CI evidence are recorded separately; CI remains pending until the remote gate succeeds.
- user-story.md: STORY-05 (CI-dependent): Completion includes applicable local toolchain evidence and required CI success recorded for the final PR head, with any CI check-off push reverified at its resulting head.

| Source File | Total AC | Source checked | Unchecked | Notes |
|---|---|---|---|---|
| spec.md | 11 | 11 | 0 | Nine fully verified, two CI items checked at initial S9 step and conditional |
| user-story.md | 5 | 5 | 0 | Four fully verified, one CI item checked at initial S9 step and conditional |

Evidence references: sibling policy/code review; latest ordered language QA, coverage-and-size, actual bundle coverage and isolation artifacts. Required review artifacts are validated with installed MCP structural validators; that success does not imply the installed runtime accepts new model-routing checkpoint receipts.


Additional operational evidence: evidence/qa-gates/local-vsix-readiness.2026-10-17T18-54.md records successful package/install/file verification but MCP_VALIDATION_OK=false. Fresh direct MCP validation continues to reject current Sol receipts 11-16 under legacy expectations. Installation success does not clear R1 or establish completed checkpoint validity.
