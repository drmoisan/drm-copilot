# Code Review — missing-ci-gate-parser-script (Issue #229)

- Feature: 2026-06-24-missing-ci-gate-parser-script-229
- Base branch: main @ e93a0fd4ccf4f39f946f04fa70b9a56f4ed6f22f
- Head: 819350a80747a3d963c189729e85251a9cb5920a
- Timestamp: 2026-06-24T17-55
- Languages in scope: PowerShell (1 production file, 1 test file)

> Template-resolution note: the MCP `code-review-template` asset and the orchestration-artifact validator were not available in this session. This artifact reproduces the required sections (`## Executive Summary`, `## Findings Table` with the canonical header) directly.

## Executive Summary

`scripts/orchestration/Invoke-CiGateParser.ps1` is a well-structured advanced function that implements the S9 `ci_gate` derivation contract. It correctly separates concerns into three units: a pure derivation helper (`Get-CiGateConclusion`), a thin object constructor (`ConvertTo-CiGateObject`), and an orchestrating wrapper (`Invoke-CiGateParser`) that owns the impure JSON-parse and clock-resolution steps. The bucket-to-conclusion mapping is explicit, conservative (cancel maps to failure; unknown buckets fail fast), and matches the documented S9 derivation rules. The script does not invoke `gh`, uses an injectable clock, and is deterministically testable. The companion Pester suite covers positive, negative, boundary, and error paths with specific assertions.

No blocking or major findings. Two informational observations are recorded below; neither requires remediation. The code is ready for PR from a code-quality standpoint.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | scripts/orchestration/Invoke-CiGateParser.ps1 | L68-89 (script param block) and L253-274 (inner wrapper param block) | The script-level parameters and the inner `Invoke-CiGateParser` function declare the same parameter set, including the default `-NowProvider` scriptblock, in two places. | Optional: keep as-is. The duplication is intentional to make the inner function independently callable and testable while the script provides the executable entry point. If consolidation is desired later, the entry point could forward via `$PSBoundParameters`. | The duplication is small, in one file, and serves the dot-source testability pattern. It is not a DRY violation worth changing because each block has a distinct role (CLI surface vs. testable function). | Read of both param blocks; both carry identical validation attributes. |
| Info | scripts/orchestration/Invoke-CiGateParser.ps1 | L320 | The entry-point guard `if ($MyInvocation.InvocationName -ne '.')` distinguishes direct execution from dot-sourcing. This idiom is correct but relies on invocation-name semantics. | No change required. The behavior is verified: the test file dot-sources the script and the entry point does not fire (15 tests pass without the process block executing). | The pattern is the established repo approach for making a `*.ps1` both executable and unit-testable; it is exercised by the test suite. | tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1 L11-12; coverage shows L321 uncovered (entry point suppressed under dot-source). |

## Detailed Observations

### Bucket-value mapping (verification point b)

The mapping is explicit and conservative (`scripts/orchestration/Invoke-CiGateParser.ps1` L154-165):
- `fail` -> `failure` (short-circuit return).
- `cancel` -> `failure` (conservative: a cancelled required check is treated as non-success rather than ignored).
- `pending` -> records `$anyPending` and defers, so a later `fail` still takes precedence (failure outranks pending).
- `pass` and `skipping` -> no state change (contribute to success; skipping is explicitly non-blocking).
- `default` (any unrecognized bucket) -> fail-fast `throw` naming the value, preventing a silent pass on an unknown enum.
- Empty/null set -> `success` (vacuous satisfaction), documented at L130-134.

This precedence (failure > pending > success) matches the S9 contract in `.claude/skills/orchestrate/SKILL.md` L158. The conservative treatment of `cancel` and the fail-fast on unknown buckets are appropriate for a gate that controls a DONE transition.

### No `gh` invocation and determinism (verification point c)

Verified by grep: every occurrence of `gh` in the script is within comments or the synopsis. The script consumes JSON via `-ChecksJson` (pipeline-capable) and never shells out. `verified_at` is produced through the injectable `-NowProvider` delegate (L85, L270, L295); the default reads UTC wall-clock time, and tests inject a fixed clock. No `setTimeout`/`Start-Sleep`/retry/timing hacks. Deterministic.

### S9 contract conformance (verification point a)

`ConvertTo-CiGateObject` (L211-217) emits exactly the five contract fields with the contract names: `head_sha`, `pr_pipeline_run_id`, `pr_pipeline_run_url`, `conclusion`, `verified_at`. The `conclusion` value is one of `success`/`failure`/`pending`. This matches the checkpoint schema at `.claude/skills/orchestrate/SKILL.md` L168-189. Test 13 asserts all five fields are present; test 12 asserts passthrough of the three input-sourced fields.

### Error handling

Three fail-fast paths, each with an explicit parser-attributed message: malformed JSON (L279-284), missing `bucket` property (L145-147), and unknown bucket value (L160-164). The single `catch` rethrows with added context rather than swallowing. Consistent with the fail-fast-and-explicitly policy.

### Test quality

15 tests with Arrange/Act/Assert structure and specific assertions. Error-path tests use `Should -Throw -ExpectedMessage` with targeted patterns rather than bare `Should -Throw`, so they assert the correct error, not merely that an error occurred. No assertions were weakened to pass. No temp files, no network, no live `gh`.

## Recommendation

Approve. No remediation required.
