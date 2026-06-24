# Code Review: require-pr-author-agent-for-prs (Issue #231)

**Review Date:** 2026-06-24
**Base Branch:** `main` (merge-base `258aa903542346cc534c03da39e4b938223c1f2d`)
**Head:** `0beb721d21c86ed944cc1090bae5085f595ea936`
**Scope:** Full branch diff against merge-base.

## Executive Summary

The change is cohesive and follows the repository's PowerShell seam/testing standards closely. The strengthened PreToolUse hook is implemented as a linear decision function with three injectable seams (`Get-PrAuthorAuthorizationContent`, `Get-CurrentDateTimeUtc`, `Get-PrContextArtifactExistence`), the new SubagentStop validator is small and well-factored, and the cross-ecosystem copies are consistent (Claude root/bundled byte-identical, Codex hook identical apart from the mandated converted-hook header, Codex/Copilot docs equivalent). Format is clean, PSScriptAnalyzer reports zero findings, and 56/56 in-scope tests pass on independent rerun. The guardrail-not-cryptographic limitation is disclosed honestly in every documentation surface.

One Blocking correctness defect exists: `gh pr edit --body "inline"` is allowed, despite AC3, spec FR-2 step 4, and FR-4 stating that inline `--body` on `gh pr edit` is blocked by Case A. The Case A inline-body block is gated on `isPrCreate` only, so the edit path falls through every guard and returns allow. This is a pre-existing condition the feature did not introduce, but the feature now documents and asserts that this path is blocked and adds no test for it; the result is a documented enforcement gap on the exact body-edit path the feature is meant to restrict. The remaining findings are non-blocking observations about the branch-coverage metric and a minor regex robustness note.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Blocking | `.claude/hooks/enforce-pr-author-skill.ps1` (and bundled + Codex mirrors) | `Get-PrAuthorBypassReason`, L212-229 | Inline `--body` is blocked only when `isPrCreate`. For `gh pr edit --body "inline"` the `isPrCreate` block is skipped, the `isPrEdit` no-body short-circuit (L226) is false, Case C is false (no `--body-file`), the sentinel check is false (no `--body-file`), so the function returns `$null` (allow). AC3/FR-2 step 4/FR-4 and `pr-author.md` require this path to be blocked by Case A. | Extend the Case A inline-body block to apply to `gh pr edit` as well as `gh pr create` (evaluate `$hasInlineBody -and -not $hasBodyFile` before the create/edit branch split, or add the same guard in the `isPrEdit` block). Add a test `blocks gh pr edit --body "inline"` and the equals-form variant. Apply identically to the bundled Claude mirror and the Codex translation. Update evidence (backward-compat matrix) to reflect the edit-inline case. | A documented enforcement path is bypassable: an actor can edit a PR body inline via `gh pr edit --body "..."` with no sentinel, no context artifact, and no `--body-file`, defeating AC3 and the body-edit restriction. Untested behavior on a security-relevant guard. | Reviewer direct call: `Get-PrAuthorBypassReason -CommandText 'gh pr edit 42 --body "inline text"' -ContextExists $true` returns `ALLOW`. Baseline (`258aa90`) had the same `isPrCreate`-scoped guard, confirming a pre-existing gap. No test in `enforce-pr-author-skill.Tests.ps1` covers `gh pr edit --body`. |
| Low | `.claude/hooks/validate-pr-author-output.ps1` | entrypoint L129-136 | Host-bound entrypoint block lowers JaCoCo physical-line coverage to 84.85% (below 85% on that alternate metric), though command coverage is 86.49% (above threshold). | No code change required; optionally keep the entrypoint minimal. Documented as the repository's known PowerShell entry-point-block limitation. | The repository's Pester tooling reports command/line coverage; the entrypoint is exercised only by subprocess tests and is unavoidable wiring. Recorded for transparency. | JaCoCo per-file parse: `validate-pr-author-output.ps1` LINE 28/33 = 84.85%; command 32/37 = 86.49%. Missed lines are exactly the entrypoint. |
| Info | `.claude/hooks/enforce-pr-author-skill.ps1` | `Get-PrAuthorBypassReason` L209-210 | Inline-body regex `--body(?!-file)\b` correctly distinguishes `--body` from `--body-file`, including the equals form `--body=...`. No defect; noted as verified. | None. | Confirms the equals-form Case A test and the `--body-file` allow path are not confused by the regex. | Test `blocks gh pr create --body='inline'` passes; reviewer edge-case run confirms `--body-file` is not matched by the inline regex. |
| Info | `.claude/hooks/enforce-pr-author-skill.ps1` | `Test-PrAuthorAuthorization` L156-162 | `ttl_seconds` is parsed defensively (falls back to the named 120s constant when absent or non-integer), and `issued_at` is parsed with invariant-culture UTC assumption. Robust and deterministic. | None. | Confirms TTL handling and timestamp parsing are deterministic and seam-driven. | Cases F/malformed tests pass; clock seam controls elapsed time. |

## Detailed Notes

### Hook decision-order correctness (Cases A/B/C/D/E/F)

The decision order on the `--body-file`-with-context path follows spec FR-2 step 3 exactly: missing -> malformed (invalid JSON, then missing/unparseable `issued_at`) -> invalid issuer -> expired -> allow. Each branch returns a distinct, explicit `PR_AGENT_AUTHORIZATION_*` reason. Cases A/B/C are evaluated first and are unchanged from baseline. The extension is additive: the previously-allowed `--body-file` + context path now additionally requires a valid sentinel. This portion is correct and well tested.

### Determinism and no-temp-file compliance

Tests inject the clock and sentinel-read seams; the two "real seam" tests repoint `$script:PrAuthorAuthorizationPath` at the hook script itself rather than writing a sentinel file, so no temporary files are created. No `Start-Sleep`, no real `gh`, no wall-clock reads. This satisfies the repository determinism infrastructure requirements and spec Section 7.3.

### Cross-ecosystem consistency

Claude root and bundled copies are byte-identical for all six paired files. The Codex hook is byte-identical to root except for the required two-line `# Converted hook` header plus a blank line. The Codex `pr-author.toml` and Copilot `pr-author.agent.md` carry the sentinel write/delete protocol and the guardrail disclosure; the Copilot doc correctly states enforcement is documentation-only (no PreToolUse surface). `config.toml` wires the Codex PreToolUse hook for the `Bash` matcher. This satisfies spec Section 5.

### Honest guardrail disclosure (AC8)

The "policy guardrail, not a cryptographic or security control" disclosure and the forgeability statement appear in `pr-author.md`, `enforce-pr-author-skill.ps1`, `validate-pr-author-output.ps1`, `pr-author.toml`, and `pr-author.agent.md`. Every occurrence of "tamper-proof" is a negation. AC8 is satisfied.
