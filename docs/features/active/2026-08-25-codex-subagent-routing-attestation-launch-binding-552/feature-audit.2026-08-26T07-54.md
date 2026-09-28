# Feature Audit: routed-subagent attestation launch binding (#552)

**Audit Date:** 2026-08-26
**Feature Folder:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552`
**Base Branch:** `origin/main` at `245b56a4a1618f25a26e87d60ac0b8894c0b9caa`
**Head Branch:** `bug/codex-subagent-routing-attestation-launch-binding-552` at `62972ab13b1917b019a70c20ed62b75cab6127c0`
**Work Mode:** `full-bug`
**Audit Type:** Post-remediation acceptance verification

## Scope and Baseline

- **Base branch:** `origin/main` at `245b56a4a1618f25a26e87d60ac0b8894c0b9caa`.
- **Head branch/commit:** `bug/codex-subagent-routing-attestation-launch-binding-552` at `62972ab13b1917b019a70c20ed62b75cab6127c0`.
- **Merge base:** `66c648db3ecae063ef873b3e76b00ca0d9fb7944`.
- **Evidence sources:** primary `artifacts/pr_context.summary.txt`; secondary `artifacts/pr_context.appendix.txt`; current-head QA and regression evidence under this feature's `evidence/` folder.
- **Feature folder used:** the supplied active Issue #552 folder.
- **Requirements source:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/spec.md`.
- **Work mode resolution note:** `issue.md` persists `- Work Mode: full-bug`; therefore `spec.md` is the only authoritative acceptance-criteria source.
- **Scope note:** This is a full feature-versus-base re-review. Completed QA was not replayed; the audit inspected committed current-head evidence as directed.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**

- `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/spec.md` — only source.

### Acceptance criteria

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
| 1 | Durable exact pre-spawn receipt | PASS | Orchestrator wrapper contract test and binding instruction add exact receipt/flush requirements. | Recorded Pester and Python QA commands in evidence. | No generic alias is accepted. |
| 2 | Exact generated-profile binding | PASS | Resolver, generated profile TOML, and profile-binding tests cover model, reasoning, path, and SHA fields. | `poetry run pytest` and recorded Pester QA. | `commit-steward-c3` resolves to Terra/high. |
| 3 | Invalid receipt rejection | PASS | Pester covers absent/generic/model/reasoning/path/SHA mismatches before mutation. | `mcp__drm-copilot__run_poshqc_test`. | Fail-closed behavior retained. |
| 4 | Independent nested selection | PASS | Resolver selection tests cover C3 and elevated contexts; generated family inventory includes `commit-steward`. | Recorded Python aggregate QA. | Parent profile does not authorize a child. |
| 5 | Start-only authority-store behavior | PASS | `model-profile-attestation.Tests.ps1` contains exact-valid and absent/generic invalid startup cases. | `mcp__drm-copilot__run_poshqc_test`. | The invalid result is established before mutation. |
| 6 | Root/bundle/profile/manifest parity | PASS | Current SHA-256 checks match routing-config triplet, profile pair, and Pester settings pair; parity tests passed. | Recorded Python and TypeScript QA. | Bundle manifest includes all commit-steward variants. |
| 7 | Regression tests and coverage | PASS | Python 93.48% equal to baseline; PowerShell 96.14%; TypeScript 96.66% repository and 95.67% changed validator. | Recorded pytest, Pester, and Jest coverage commands. | All thresholds exceed policy. |
| 8 | Final toolchain and canonical evidence | PASS | QA and fail-before/pass-after artifacts are under the feature `evidence/` directories; remediation loop completed with exit code 0. | Evidence commands listed in policy audit Appendix B. | The prior file-size finding is resolved. |

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**

- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:** None.

**Recommended follow-up verification steps:**

1. Push `62972ab1` to PR #553 and monitor CI for that exact head.
2. Run the repository's strict completion validation after exact-head CI completes.

## Acceptance Criteria Check-off

All eight authoritative `spec.md` criteria were already checked `[x]`; this re-review verified that status and made no source-file checkbox mutation.

### AC Status Summary

- Source: `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/spec.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 8 | 8 | 0 | Checkbox-backed authoritative full-bug source; no check-off edit was required. |
