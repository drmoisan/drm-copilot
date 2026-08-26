# Code Review: routed-subagent attestation launch binding (#552)

**Review Date:** 2026-08-26
**Reviewer:** feature-reviewer
**Feature Folder:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552`
**Feature Folder Selection Rule:** supplied active feature folder for Issue #552.
**Base Branch:** `origin/main` at `b5a7490b685a08584ab618a1debfed7ba4417a32`
**Head Branch:** `bug/codex-subagent-routing-attestation-launch-binding-552` at `5697e55979ad9834a001ca2fe06f0ea66e64b983`
**Review Type:** Post-remediation re-review

## Executive Summary

The full branch diff adds exact generated `commit-steward` profiles, registers the family in deterministic routing sources and generated bundle assets, verifies checkpoint receipt acceptance, and adds regression coverage for route selection and hook attestation. Review of the canonical PR context, raw branch diff, current root/bundle hashes, and existing QA evidence found no correctness or security blocker in the routing implementation.

One policy-level structural finding remains: a modified Python test file now exceeds the repository's 500-line limit. It does not invalidate the observed routing behavior, but it prevents a Go recommendation until the test is split into cohesive files and the affected Python checks are rerun.

**What changed:**

- `.codex/agents/commit-steward*.toml` and bundled copies define C1-C4 generated profiles.
- `config/orchestration-routing.json`, Python resolver/generator, and TypeScript checkpoint validation include `commit-steward` in the generated-agent family.
- PowerShell Pester coverage settings include the routing-attestation recorder.
- Python, PowerShell, and TypeScript tests verify exact generated-profile selection, receipt binding, and bundle parity.

**Top 3 risks:**

1. The active host registry may require reload before recognizing a newly added generated profile; source/bundle correctness does not refresh an already running registry.
2. The 541-line modified test file violates the repository structural limit.
3. Future routing-family additions can drift across source, bundle, and manifest copies unless the existing parity checks continue to run.

**PR readiness recommendation:** **Needs Revision** — split the oversized test file, then run its affected Python toolchain and coverage checks; no implementation-correctness blocker was found.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | whole file | The modified test file is 541 lines. | Split cohesive test groups into a second test module; preserve existing assertions and coverage scope. | Repository policy limits production, test, and reusable script files to 500 lines. | Current `Get-Content` line count: 541; `AGENTS.md` General Code Change Policy. |
| Info | `.codex/agents/commit-steward-c3.toml` and bundled copy | generated profile | Standalone C3 maps to the exact Terra/high profile. | Retain exact profile-only launch behavior. | Avoids logical-alias fallback and matches persisted receipt requirements. | Current root/bundle SHA-256 equality; resolver and Jest/Pytest evidence. |

No Blocker findings were identified.

## Implementation Audit

### Python implementation audit

The resolver and generator make one consistent family-list extension rather than introducing a parallel selection path. The `commit-steward` standalone C3 assertion expects `commit-steward-c3`, `gpt-5.6-terra`, and `high`, preserving the existing typed receipt contract and explicit model-unavailable failure behavior.

### TypeScript implementation audit

The validator uses the same generated-family registration as the Python resolver. The added test validates a full standalone C3 receipt, and the full coverage evidence reports 95.67% line coverage for the changed validator file.

### PowerShell implementation audit

The Pester coverage configuration adds the existing routing-attestation hook to the denominator without weakening hook behavior. Both source and bundled settings files are byte-identical in the current checkout; PoshQC analysis records zero diagnostics.

## Test Quality Audit

- `evidence/qa-gates/commit-steward-routing-python-test-coverage.2026-08-25T22-08.md` — 41 focused pytest cases passed; modified resolver/generator scope retained the 93% combined baseline.
- `evidence/qa-gates/powershell-test-coverage.2026-08-25T21-51.md` — 3,585 Pester cases passed with 96.14% line coverage.
- `evidence/qa-gates/claude-config-carriage-typescript-unit-coverage.2026-08-25T22-43.md` — 195 Jest suites and 2,660 tests passed with 96.66% repository line coverage.
- Current `git diff --check` and root/bundle SHA-256 comparisons passed.

The reviewed tests use explicit fixtures and deterministic configuration selection. Failure output identifies the expected generated profile and mismatch category, which provides useful routing diagnostics. The completed QA evidence was inspected instead of replayed in this review.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Added code/config diff had no password, secret, token, or API-key assignment matches. |
| No unsafe subprocess construction | PASS | Reviewed scope changes static configuration and deterministic resolver family lists; no new subprocess invocation was added. |
| Input validation at boundaries | PASS | Existing resolver invalid-input and exact-model-unavailable tests remain in the focused suite. |
| Error handling remains explicit | PASS | Model/profile mismatch behavior remains fail-closed and tested. |
| Configuration/path handling is safe | PASS | Root/bundle profiles, routing JSON triplet, and Pester settings mirrors are currently byte-identical. |

## Research Log

No external research was required. The canonical PR context, feature specification, branch diff, source code, and repository evidence are sufficient implementation authorities.

## Verdict

The routing implementation and its test evidence support the acceptance behavior for Issue #552. The branch is not ready for final PR approval until the 541-line modified test file complies with the mandatory 500-line limit. Remediation should be limited to splitting that test coverage and rerunning the affected Python quality loop.
