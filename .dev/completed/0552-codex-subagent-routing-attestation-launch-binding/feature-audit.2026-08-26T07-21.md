# Feature Audit: routed-subagent attestation launch binding (#552)

**Audit Date:** 2026-08-26
**Feature Folder:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552`
**Base Branch:** `origin/main` at `b5a7490b685a08584ab618a1debfed7ba4417a32`
**Head Branch:** `bug/codex-subagent-routing-attestation-launch-binding-552` at `5697e55979ad9834a001ca2fe06f0ea66e64b983`
**Work Mode:** `full-bug`
**Audit Type:** Post-remediation acceptance verification

## Scope and Baseline

- **Base branch:** `origin/main` at `b5a7490b685a08584ab618a1debfed7ba4417a32`.
- **Head branch/commit:** `bug/codex-subagent-routing-attestation-launch-binding-552` at `5697e55979ad9834a001ca2fe06f0ea66e64b983`.
- **Merge base:** `66c648db3ecae063ef873b3e76b00ca0d9fb7944`.
- **Evidence sources:** primary `artifacts/pr_context.summary.txt`; secondary `artifacts/pr_context.appendix.txt`; feature QA evidence under `evidence/qa-gates/` and `evidence/regression-testing/`.
- **Feature folder used:** supplied Issue #552 active folder.
- **Requirements source:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/spec.md`.
- **Work mode resolution note:** `issue.md` persists `- Work Mode: full-bug`; therefore `spec.md` is the sole acceptance-criteria authority.
- **Scope note:** Completed QA was reviewed from canonical exact-head evidence; it was not replayed during this re-review.

## Acceptance Criteria Inventory

**Authoritative AC source file:**

- `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/spec.md` — only source for `full-bug` mode.

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
|---:|---|---|---|---|---|
| 1 | Durable exact pre-spawn receipt | PASS | `evidence/regression-testing/commit-steward-c3-pass-after.2026-08-25T22-06.md`; exact receipt tests | Focused pytest and Pester commands recorded in QA evidence | Checkpoint receipt remains profile-specific. |
| 2 | Resolver-returned generated profile and binding | PASS | `.codex/agents/commit-steward-c3.toml`; bundled profile hash equality; resolver tests | `poetry run pytest ...test_resolve_codex_deployment.py...` | Exact C3 maps to Terra/high. |
| 3 | Reject aliases and all mismatch forms | PASS | `model-profile-attestation.Tests.ps1`; fail-before evidence | Pester coverage command in `powershell-test-coverage.2026-08-25T21-51.md` | Generic, model, reasoning, path, and SHA mismatches are covered. |
| 4 | Independent nested selection and C3 elevation | PASS | `test_resolve_codex_deployment.py` context/ceiling parametrization | Focused pytest coverage command | Tests cover standalone C3, epic context, and C4 ceiling. |
| 5 | Start-only authority-store behavior | PASS | `model-profile-attestation.Tests.ps1` exact/absent/generic cases | Full PoshQC Pester evidence | Validity is asserted before mutation. |
| 6 | Source/bundle/profile/manifest parity | PASS | Current SHA-256 comparisons and `claude-config-carriage-pass-after.2026-08-25T22-41.md` | `git diff --no-index`, carriage Jest coverage | Root and bundled routing/configuration copies are equal. |
| 7 | Regression suites and coverage policy | PASS | Python 41 passed, PowerShell 3,585 passed, TypeScript 2,660 passed; coverage artifacts | Commands recorded in three language QA artifacts | All changed-language thresholds and no-regression checks are evidenced. |
| 8 | Final toolchain and canonical evidence | PASS | `evidence/baseline/`, `evidence/regression-testing/`, and `evidence/qa-gates/` contents | Exact commands in policy audit Appendix B | Existing evidence records a completed final loop. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**

- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

Acceptance behavior is fully evidenced. The overall readiness is held at NEEDS REVISION solely because the separate policy audit identifies a 541-line modified Python test file that must be split before PR approval.

**Recommended follow-up verification steps:**

1. Split `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` into cohesive test files below 500 lines without weakening coverage.
2. Run the affected Python format, lint, Pyright, pytest, and coverage commands, then repeat the feature review.

## Acceptance Criteria Check-off

No acceptance-criteria source-file change was made: all eight authoritative `spec.md` checkboxes were already marked `[x]`, and this review independently evaluated each as PASS.

### AC Status Summary

- Source: `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/spec.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 8 | 8 | 0 | Checkbox-backed, authoritative for `full-bug`. |
