# Policy Audit — missing-ci-gate-parser-script (Issue #229)

- Feature: 2026-06-24-missing-ci-gate-parser-script-229
- Issue: #229
- Base branch: main
- Merge-base SHA: e93a0fd4ccf4f39f946f04fa70b9a56f4ed6f22f
- Head SHA: 819350a80747a3d963c189729e85251a9cb5920a
- Work Mode: full-bug (AC source: spec.md)
- Timestamp: 2026-06-24T17-55
- Reviewer: feature-review agent

> Template-resolution note: the MCP tool `mcp__drm-copilot__resolve_policy_audit_template_asset` was not available in this session. Per `policy-audit-template-usage` fallback guidance, this artifact reproduces the canonical major sections directly. The MCP validator `mcp__drm-copilot__validate_orchestration_artifacts` was likewise unavailable; section structure was verified manually against the canonical heading list.

## Executive Summary

The branch adds a single PowerShell production script (`scripts/orchestration/Invoke-CiGateParser.ps1`, +330/-0) and its mirrored Pester test file (`tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1`, +205/-0), plus feature scoping and evidence documents. The script implements the Step S9 (CI Green Gate) `ci_gate` derivation contract from `.claude/skills/orchestrate/SKILL.md`: it parses `gh pr checks` JSON and emits the five contract fields (`head_sha`, `pr_pipeline_run_id`, `pr_pipeline_run_url`, `conclusion`, `verified_at`), deriving `conclusion` as `success`/`failure`/`pending`.

PowerShell is the only language with changed production/test files in the branch diff. The PowerShell toolchain (format, analyze, test) was independently re-run during this review and is clean. Per-script line coverage on the new file is 94.1% (JaCoCo LINE: 32 covered / 34 total) / 93.02% command coverage, above the 85% threshold. The script does not invoke `gh`, contains no temporary-file usage, no global/script-scoped mutable production state, and uses an injectable clock delegate (`-NowProvider`) for determinism.

Overall verdict: PASS. No blocking findings. Remediation is not required.

## 1. General Unit Test Policy Compliance

PASS.

- Independence: each `It` constructs its own inputs; no shared mutable state across tests. The `script:`-scoped helpers (`ConvertChecksToJson`, `fixedClock`, `scriptPath`) are read-only fixtures.
- Isolation: tests target single behaviors (one conclusion case or one error path per `It`).
- Fast execution: pure in-process function calls; no I/O, no sleeps.
- Determinism: `verified_at` is pinned via an injected fixed clock (`{ '2026-06-24T17:00:00Z' }`); no wall-clock reads in tests. No network, no live `gh`, no temp files.
- Readability: Arrange/Act/Assert structure is present and commented; descriptive `It` names.
- Test file location: `tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1` mirrors `scripts/orchestration/Invoke-CiGateParser.ps1` (PASS — no colocation in source tree).
- Scenario completeness: positive (all-pass success), negative (fail, cancel), boundary (empty set, skipping, pending-vs-failure precedence), error handling (malformed JSON, unknown bucket, missing-bucket property). Determinism case and field-passthrough/emission cases are present.

## 2. General Code Change Policy Compliance

PASS.

- Simplicity: single-purpose advanced function with a pure derivation helper (`Get-CiGateConclusion`), a thin object constructor (`ConvertTo-CiGateObject`), and a wrapper (`Invoke-CiGateParser`). Separation of pure logic from JSON parsing and clock I/O is explicit.
- Fail-fast error handling: malformed JSON, unknown bucket value, and missing `bucket` property each throw explicit, parser-attributed errors. No broad catch-all that swallows errors (the single `catch` rethrows with added context).
- I/O boundary: the script does not invoke `gh`; the orchestrator runs `gh` and pipes JSON in. Clock access is injected. This isolates network/executable I/O outside the derivation.
- File size: 330 lines, under the 500-line limit (PASS).
- Naming: approved verbs (`Get-`, `ConvertTo-`, `Invoke-`); descriptive nouns. Confirmed by PSScriptAnalyzer (no `PSUseApprovedVerbs` finding).
- Extensibility: keyword-style parameters with defaults; optional `-AsJson` switch for serialization.

## 3. Language-Specific Code Change Policy Compliance (PowerShell)

PASS.

- Advanced function with `[CmdletBinding()]` and named parameters (PASS).
- `[Parameter(Mandatory = $true)]` and validation attributes (`ValidateNotNullOrEmpty` on `-HeadSha`, `ValidateNotNull` on `-NowProvider`) are applied (PASS).
- Pipeline input: `-ChecksJson` uses `ValueFromPipeline`; the script correctly uses `begin`/`process` named blocks (resolving the prior `PSUseProcessBlockForPipelineCommand` warning) (PASS).
- ShouldProcess: the script is a pure derivation/emission with no state-changing side effects, so `SupportsShouldProcess` is not required. The prior `PSUseShouldProcessForStateChangingFunctions` warning on the `New-CiGateObject` name was resolved by renaming to `ConvertTo-CiGateObject` (a non-state-changing verb) (PASS).
- No global/script-scoped mutable production state (PASS — verified by grep; matches are comments and the default scriptblock literal).
- No `Invoke-Expression`, no plaintext secrets, no hard-coded credentials (PASS).
- PowerShell 7+ compatible; analyzer run with repo `pssa.settings.psd1` returns 0 findings (PASS).

## 4. Language-Specific Unit Test Policy Compliance (PowerShell)

PASS.

- Pester v5.x with `Describe`/`Context`/`It`; one behavior per `It` (PASS).
- Test file named `*.Tests.ps1` and located under `tests/scripts/orchestration/` mirroring source (PASS).
- No external executable mocking; the design avoids `gh` entirely so no executable seam mock is needed. No mocking of `git`/`gh` directly (PASS).
- Deterministic: no network, no PATH/profile dependence, no temp files, injected clock (PASS).
- The dot-source pattern (`$MyInvocation.InvocationName -eq '.'`) suppresses the entry-point body so functions are testable in isolation while the on-disk lines run under coverage instrumentation (PASS).
- No weakened assertions: each `It` asserts a specific value or a specific thrown-message pattern (`Should -Throw -ExpectedMessage`) (PASS).

## 5. Test Coverage Detail

PASS.

Language with changed files: PowerShell. Coverage artifact inspected: `artifacts/pester/cigate-coverage.xml` (JaCoCo, dedicated per-script run) and `artifacts/pester/powershell-coverage.xml` (bundled suite).

New file: `scripts/orchestration/Invoke-CiGateParser.ps1` (added this feature; all lines are new code).

- Line coverage (JaCoCo LINE counter): 32 covered / 34 total = 94.1%. PASS (>= 85%).
- Command coverage (Pester model): 40 executed / 43 analyzed = 93.02%. PASS (>= 85%).
- Uncovered lines:
  - L85 — default `-NowProvider` wall-clock scriptblock (`Get-Date`). Not exercised because tests inject a fixed clock per determinism policy (wall-clock reads are prohibited in tests). Legitimate uncovered host-bound line.
  - L321 — the entry-point `Invoke-CiGateParser` call inside the `process` block, suppressed under the dot-source test pattern by design.
  Both uncovered lines are the thinnest possible host-bound wiring; no production logic is excluded from measurement and no `exclude` entry was used.
- Branch coverage: Pester/JaCoCo emit no BRANCH counters for PowerShell in this repository (the JaCoCo report contains `cb="0" mb="0"` on every line). A numeric branch percentage is therefore UNAVAILABLE-BY-TOOLING, consistent with the Phase 0 baseline. This is a known PowerShell-tooling limitation, not a missing-artifact condition. Every conclusion branch (success/failure/pending), the cancel and skipping buckets, the empty-set case, the failure-over-pending precedence, and all three fail-fast throws are individually asserted by the 15 tests, so there is no untested branch.

No coverage regression: the new file did not exist at baseline; no pre-existing production line was modified, so there is no changed-line regression. The bundled hooks-subset coverage is unchanged because no hook files were modified.

Coverage verdict (PowerShell): PASS.

Other languages (TypeScript, Python, C#): zero changed production/test files in the branch diff; coverage is N/A for those languages (acceptable only because they have no changed files on the branch).

## 6. Test Execution Metrics

PASS.

- Independent re-run during this review: `Invoke-Pester` on `tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1` → Passed=15 Failed=0 Total=15.
- Executor evidence (p3-pester.md): bundled MCP suite exit 0; dedicated coverage run Passed=15 Failed=0 Total=15.

## 7. Code Quality Checks

PASS.

- Format: `mcp__drm-copilot__run_poshqc_format` (executor) exit 0; stable on a second consecutive pass. Independent review confirms no analyzer formatting findings.
- Analyze: `mcp__drm-copilot__run_poshqc_analyze` (executor) exit 0, 0 violations. Independent re-run via `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` on both files returned 0 findings.
- Type check: N/A for PowerShell (per `.claude/rules/powershell.md`).
- File size: 330 lines < 500 (PASS).
- No temp files, no `gh` invocation, no global/script-scoped mutable production state (verified by grep).

## 8. Gaps and Exceptions

- Branch coverage numeric percentage is unavailable from the repository's PowerShell coverage tooling (no BRANCH counters in JaCoCo output). This is a tooling limitation documented in the Phase 0 baseline, not a coverage gap; all branches are behaviorally covered by the 15 tests. This is recorded as a documented exception, not a finding.
- MCP template-resolution and orchestration-artifact-validation tools were not available in this review session; artifacts were constructed against the canonical heading list directly. This does not affect the compliance verdict.

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope below the full branch diff. The caller directed a full feature-vs-base audit and enumerated specific verification points (S9 contract conformance, bucket mapping, no-`gh`/determinism, coverage, formatting) that are consistent with — not narrower than — the full-branch scope. None of these are scope-narrowing instructions; no narrowing was rejected.

## Evidence Location Compliance

PASS. `scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (no violations). The branch diff was scanned for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, and `artifacts/coverage/`; none were found. All feature evidence is written under the canonical `docs/features/active/2026-06-24-missing-ci-gate-parser-script-229/evidence/<kind>/` paths. The coverage artifacts under `artifacts/pester/` are tool outputs at the SKILL-defined coverage-artifact path, not evidence-location violations.

## 9. Summary of Changes

Production/test (core logic):
- `scripts/orchestration/Invoke-CiGateParser.ps1` (+330/-0) — new S9 ci_gate parser.
- `tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1` (+205/-0) — 15 Pester tests.

Docs/evidence (18 files): feature `issue.md`, `spec.md`, `plan.2026-06-24T17-34.md`, and `evidence/` baseline, qa-gates, regression-testing, and issue-updates artifacts.

## 10. Compliance Verdict

PASS. No blocking or partial findings. The branch satisfies general code-change, general unit-test, PowerShell code-change, and PowerShell unit-test policy. Coverage for the only changed language (PowerShell) is above threshold. The `modified-workflow-needs-green-run` rule does not fire (no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths in the diff). Remediation is not required.

## Appendix A: Test Inventory

`tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1` — 15 tests:
1. returns success when all required checks pass
2. returns failure when any required check failed
3. returns pending when a check is in progress and none failed
4. returns failure when a check is cancelled (cancel maps to failure)
5. returns success when a check is skipping (skipping is non-blocking)
6. returns success for an empty required-check array (vacuous satisfaction)
7. prefers failure over pending when both are present
8. throws an explicit error on malformed JSON
9. throws an explicit error naming an unrecognized bucket value
10. throws an explicit error when a check element lacks a bucket property
11. produces verified_at from the injected NowProvider delegate
12. passes head_sha, pr_pipeline_run_id, and pr_pipeline_run_url through to the emitted object
13. emits all five ci_gate fields
14. emits a JSON string carrying the conclusion when -AsJson is set
15. returns success for a null check set (Get-CiGateConclusion pure helper)

## Appendix B: Toolchain Commands Reference

- Format (executor): `mcp__drm-copilot__run_poshqc_format` (scan_folders: scripts/orchestration, tests/scripts/orchestration) → exit 0.
- Analyze (executor): `mcp__drm-copilot__run_poshqc_analyze` (same scan_folders) → exit 0, 0 violations.
- Analyze (review re-run): `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` → 0 findings on both files.
- Test (executor): `mcp__drm-copilot__run_poshqc_test` → exit 0; dedicated coverage run with `CodeCoverage.Path = scripts/orchestration/Invoke-CiGateParser.ps1`, JaCoCo output to `artifacts/pester/cigate-coverage.xml`.
- Test (review re-run): `Invoke-Pester` on the test file → Passed=15 Failed=0 Total=15.
- Coverage artifact inspected: `artifacts/pester/cigate-coverage.xml` (LINE 32/34 = 94.1%).
- Evidence-location validator: `python scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0.
- Diff range: `git diff e93a0fd4ccf4f39f946f04fa70b9a56f4ed6f22f..819350a80747a3d963c189729e85251a9cb5920a`.
