# Code Review: require-pr-author-agent-for-prs (#231) — F-1 Re-Review

**Review Date:** 2026-06-24
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231`
**Feature Folder Selection Rule:** Suffix `-231` matches the issue number in the branch name `feature/require-pr-author-agent-for-prs-231`; it is the only active folder with material scoping-doc changes in the diff.
**Base Branch:** `main` (merge-base `258aa903542346cc534c03da39e4b938223c1f2d`)
**Head Branch:** `feature/require-pr-author-agent-for-prs-231` @ `cbf915c30e23bf8ee10978c13137885bea4280e9`
**Review Type:** Post-remediation re-review (blocking finding F-1)

---

## Executive Summary

This re-review verifies the remediation of blocking finding F-1 across the full branch diff (`258aa90..cbf915c`), comprising the original implementation commit `0beb721` and the F-1 fix commit `cbf915c`. The feature adds a `pr-author` agent and strengthens the `enforce-pr-author-skill.ps1` PreToolUse hook with an authorization-sentinel mechanism (Cases D/E/F + malformed), plus a new SubagentStop validator `validate-pr-author-output.ps1`, with byte-identical Claude bundled mirrors and a Codex translation.

**What changed (F-1 remediation):** In `.claude/hooks/enforce-pr-author-skill.ps1`, the Case A inline-body guard was widened from `$isPrCreate`-only to `($isPrCreate -or $isPrEdit) -and $hasInlineBody -and -not $hasBodyFile` (line 215) and is now evaluated before the `gh pr edit` no-body allow short-circuit (lines 226–231). This blocks inline `gh pr edit --body "x"` and the equals form `gh pr edit --body='x'` with `PR_AUTHOR_SKILL_BLOCKED`, while `gh pr edit --title`/`--add-label` (no body flag) still short-circuit to allow. The identical change was applied to the bundled Claude mirror and the Codex translation. Three tests were added: two inline-edit-body BLOCK cases and one `--title` no-body ALLOW regression.

**Top 3 risks:**
1. Sentinel forgeability (documented known limitation, not a regression): any actor with `Write(/artifacts/**)` can forge the sentinel. The implementation and docs correctly characterize this as a policy guardrail, not a security control.
2. Cross-ecosystem drift over time: three copies of the hook must stay in sync. Currently verified identical; relies on ongoing parity checks.
3. Entry-point-tail commands remain uncovered by in-process Pester (covered by end-to-end subprocess tests). Acceptable per the repository PowerShell coverage characteristic.

**PR readiness recommendation:** **Go** — F-1 is resolved with verified evidence; toolchain and coverage pass; no Blocker or Major findings remain.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/enforce-pr-author-skill.ps1` | L210–217 | F-1 resolved: `$hasInlineBody = $CommandText -match '(?i)--body(?!-file)\b'` matches both `--body "x"` and `--body='x'` (the `\b` boundary after `body` matches before a space or `=`); the unified Case A guard runs before the edit no-body allow path. | None. Verified correct. | Confirms the prior blocking gap is closed for both inline forms. | Live `Invoke-Pester` 44/44 pass; inline-edit-body block cases at test L52–66; equals-form regex confirmed by passing equals-form test. |
| Info | `.claude/hooks/enforce-pr-author-skill.ps1` | L226–231 | `gh pr edit` with no body flag (`--title`/`--add-label`/`--reviewer`) returns `$null` (allow) only after Case A and Case B are evaluated, preserving the intended allow path. | None. | Confirms the F-1 fix did not over-block legitimate edits. | Tests at L68–73, L144–154 pass (allow). |
| Info | bundled + Codex hooks | whole file | Cross-ecosystem parity holds: root == bundled (byte-identical); Codex == root with only the 3-line `# Converted hook` header prepended. | None. | Spec Section 5 requires identical Claude copies and a Codex translation. | `diff` root vs bundled = empty; `diff` root vs Codex = only 3 leading header lines. |
| Nit | `.claude/hooks/enforce-pr-author-skill.ps1` | L325–333 | Entry-point tail (after dot-source guard) is not covered by in-process Pester (7 commands). | Keep covering via the existing end-to-end `pwsh` subprocess tests; no extraction needed. | Known PowerShell coverage characteristic; line coverage still 92.13%, above floor. | Targeted `Invoke-Pester` CommandsMissed = lines 325–333. |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The F-1 fix is minimal and correct: a single predicate widening plus a deliberate evaluation-order placement, rather than a parallel edit-specific branch. This avoids logic duplication and keeps the decision order auditable.
- Evaluation order is the load-bearing detail and is handled correctly: Case A (inline body, create or edit) is checked before the `gh pr edit` no-body short-circuit, so an inline-body edit cannot fall through to allow.
- The regex `--body(?!-file)\b` correctly distinguishes inline `--body` from `--body-file` and matches both space- and equals-delimited inline forms.
- Injectable seams (`Get-PrAuthorAuthorizationContent`, `Get-CurrentDateTimeUtc`, `Get-PrContextArtifactExistence`) keep the decision logic deterministic and testable without disk or wall-clock dependencies.

#### API and safety notes

- All functions are advanced functions with `[CmdletBinding()]` and `[OutputType()]`; mandatory parameters validated. Approved verbs used throughout.
- The script honestly documents enforcement strength in NOTES: the sentinel is a policy guardrail, forgeable by any actor with `Write(/artifacts/**)`, and must not be described as tamper-proof. This matches spec Section 2.3 and the `Do Not Do` guidance in the remediation inputs.
- No `Invoke-Expression`, no plaintext secrets, no hard-coded credentials.

#### Error handling and logging

- `ConvertFrom-Json -ErrorAction Stop` inside `try/catch` surfaces malformed `CLAUDE_TOOL_INPUT` as a thrown error and exit 1; malformed sentinel JSON or unparseable `issued_at` returns a specific `PR_AGENT_AUTHORIZATION_MALFORMED` reason. Failure modes are explicit, not silently swallowed.

---

## Test Quality Audit

The added tests directly target the F-1 gap and its regression boundary. The inline-edit-body BLOCK cases (quoted and equals) and the `--title` no-body ALLOW case pin both the fix and the boundary it must not cross. All pre-existing Case A/B/C and sentinel tests retain their original expectations; the previously-allowed `--body-file` path now additionally mocks a valid in-TTL sentinel, which is a mock addition rather than an expectation change.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — 44 tests covering Cases A–F, malformed, allow paths, helpers, and end-to-end; live run 44/44 pass.
- `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1` — 15 tests covering PR-reference detection and exit-code semantics; live run 15/15 pass.
- `evidence/qa-gates/final-pester.md` — full bundled suite 291 tests, 0 failures; enforce hook 92.13% line/command.
- `evidence/regression-testing/backward-compat.md` — per-case backward-compat table including the two F-1 inline-edit-body rows.
- `evidence/qa-gates/final-parity.md` — SHA-256 parity of root vs bundled and Codex-minus-header.

### Quality assessment prompts

- **Determinism:** Time and sentinel content fully injected via seams; no `Start-Sleep`, no real `gh`, no wall-clock reads in TTL logic.
- **Isolation:** One behavior per `It`; per-context `BeforeEach` mock registration.
- **Speed:** 3.7s for 59 targeted tests.
- **Diagnostics:** Reason-string assertions identify the exact failing case.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or tokens in hooks/tests (inspection). |
| No unsafe subprocess or command construction | ✅ PASS | Hook only parses command text; it never executes `gh`. End-to-end tests invoke the hook script itself via `pwsh -NoProfile -File`. |
| Input validation at boundaries | ✅ PASS | `CLAUDE_TOOL_INPUT` parsed with `-ErrorAction Stop`; empty/missing command treated as allow; sentinel validated for issuer/TTL/parseability. |
| Error handling remains explicit | ✅ PASS | Specific block reasons per case; malformed inputs throw or return typed reasons. |
| Configuration / path handling is safe | ✅ PASS | Artifact and sentinel paths are script-scoped constants; `Test-Path -LiteralPath` used. |

---

## Research Log

No external research was required. All evidence was derived from the branch diff, the PR-context summary, live PowerShell toolchain execution, and the feature-folder evidence artifacts.

---

## Verdict

The F-1 remediation is correct, minimal, and well-tested. Inline `gh pr edit --body` (both quoted and equals forms) is now blocked by the unified Case A guard before the edit no-body allow short-circuit, while `gh pr edit --title`/`--add-label` remains allowed; Cases B/C and sentinel Cases D/E/F are unchanged. Cross-ecosystem parity holds, the toolchain passes in a single pass, and per-file coverage exceeds the line floor. The change is ready for normal PR flow with no required follow-up.
