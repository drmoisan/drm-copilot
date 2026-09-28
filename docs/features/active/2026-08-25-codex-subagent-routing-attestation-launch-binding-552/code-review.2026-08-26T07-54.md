# Code Review: routed-subagent attestation launch binding (#552)

**Review Date:** 2026-08-26
**Reviewer:** feature-reviewer
**Feature Folder:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552`
**Feature Folder Selection Rule:** Supplied active Issue #552 folder matching the feature branch and PR context.
**Base Branch:** `origin/main` at `245b56a4a1618f25a26e87d60ac0b8894c0b9caa`
**Head Branch:** `bug/codex-subagent-routing-attestation-launch-binding-552` at `62972ab13b1917b019a70c20ed62b75cab6127c0`
**Review Type:** Post-remediation re-review

## Executive Summary

The full branch range adds the `commit-steward` generated-profile family to the resolver, routing policy, generated TOML files, bundle manifest, and TypeScript checkpoint validator. It also preserves start-time exact receipt checks, adds positive and negative Pester coverage, and excludes ephemeral `.codex/state/` data from the customization payload. The remediation split moves shared in-memory test support and variant-pack tests into cohesive modules; the original test behavior remains covered and all split files are under the repository limit.

The evidence reviewed is current-head evidence committed with the remediation. I inspected the refreshed PR context, raw range diff, relevant source/test changes, coverage evidence, current line counts, SHA-256 parity, and `git diff --check`. The remote PR branch remains two commits behind the local head; that is an operational follow-up for the orchestrator, not a code defect.

**What changed:** exact generated `commit-steward` C1-C4 profiles are registered and bundled; the resolver and validator recognize that family; payload publication filters `.codex/state/`; and the Python publisher tests are split using shared in-memory support.

**Top 3 risks:**

1. The active Codex host must reload the newly published profile registry before recognizing `commit-steward-c3`.
2. The remote PR branch must be updated to `62972ab1` before CI can attest the reviewed head.
3. Future profile-family additions must continue to update the root, bundle, resolver, configuration, manifest, and validator surfaces together.

**PR readiness recommendation:** **Go** — no Blocker, Major, or Minor code findings remain; proceed with push and exact-head CI, without merging or publishing a package.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `origin/bug/codex-subagent-routing-attestation-launch-binding-552` | branch head | Remote PR branch is two commits behind reviewed local head. | Push `62972ab1` before monitoring PR #553 CI. | CI must run against the reviewed commit. | `git rev-list --left-right --count origin/bug/codex-subagent-routing-attestation-launch-binding-552...HEAD` returned `0 2`. |

No Blocker, Major, or Minor findings.

## Implementation Audit

### Python implementation audit

- `resolve_codex_deployment.py` extends the typed generated-family set with `commit-steward`; `generate_codex_agent_variants.py` includes it in the core pack.
- `ExcludingFileSystem._is_publishable_source_path` centrally removes source-relative `.codex/state/` entries while leaving non-source-relative paths untouched.
- Shared test support uses explicit `MemoryFile` and `RecordingFileSystem` types. The split modules retain behavior-specific test names and in-memory execution.

### TypeScript implementation audit

- `orchestrator-state-codex-model-routing.ts` uses the same generated-family inventory extension as configuration and Python validation.
- Dedicated Jest coverage validates the exact `commit-steward-c3` receipt behavior and rejects invalid routing data.

### PowerShell implementation audit

- `model-profile-attestation.Tests.ps1` verifies start-time acceptance and rejection before mutation for exact, missing, generic, model, reasoning, profile-path, and SHA conditions.
- Both Pester settings copies register the hook under coverage and have matching SHA-256 values.

## Test Quality Audit

- `evidence/qa-gates/python-test-coverage.2026-08-26T07-26.md` — 9 remediation tests passed; publisher coverage is 93.48% lines and equal to baseline.
- `evidence/qa-gates/powershell-test-coverage.2026-08-25T21-51.md` — 3,585 Pester tests passed with 96.14% line coverage.
- `evidence/qa-gates/claude-config-carriage-typescript-unit-coverage.2026-08-25T22-43.md` — 195 Jest suites and 2,660 tests passed; repository line coverage is 96.66%.
- Current line-count inspection confirms all changed executable files remain at or below 500 lines; `git diff --check` reports no whitespace errors.

- **Determinism:** The Python split uses an in-memory filesystem; Pester and Jest tests target checked-in profile/configuration data.
- **Isolation:** Each new test covers a narrow profile, payload, or variant-pack behavior.
- **Diagnostics:** Test names and assertions identify the profile, rejection shape, or payload category that fails.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Range-diff inspection found no credential or secret assignment additions. |
| No unsafe subprocess or command construction | PASS | Changed Python publisher/filter and test support introduce no subprocess invocation. |
| Input validation at boundaries | PASS | Exact generated-profile, model, reasoning, path, and SHA binding remains enforced by existing hook validation and new tests. |
| Error handling remains explicit | PASS | Invalid/absent routing remains fail-closed; no alias fallback was added. |
| Configuration and path handling is safe | PASS | Bundle/config/Pester mirrors match by SHA-256; `.codex/state/` is excluded from payload selection. |

## Research Log

No external research was required. The refreshed PR context, repository source, specification, tests, and committed evidence are the authoritative sources for this re-review.

## Verdict

The implementation is ready for the requested normal PR flow. The prior structural finding is resolved without weakening test coverage or routing enforcement. Push the reviewed head and monitor exact-head CI; do not merge or publish a package under this review.
