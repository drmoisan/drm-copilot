# Code Review: restore-pr-author-receipt-and-orchestrator-governance (#261)

**Review Date:** 2026-06-27
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-06-27-restore-pr-author-receipt-and-orchestrator-governance-261`
**Feature Folder Selection Rule:** Suffix `-261` matches the issue number in the branch name `feature/restore-pr-author-receipt-and-orchestrator-governance-261`; it holds the material scoping-doc changes (`spec.md`, `user-story.md`).
**Base Branch:** `feature/harden-claude-pretooluse-hook-schema-259` @ `a17451e07d92147a48c9cb32d02193985a409e46`
**Head Branch:** `feature/restore-pr-author-receipt-and-orchestrator-governance-261` @ `041c9779bc12225a318bff987433934103b27b37`
**Review Type:** Initial review

---

## Executive Summary

This branch hardens two orchestration-governance controls. Part A replaces the forgeable authorization-sentinel PR-author gate with a SHA-256 content-hash receipt model in the `enforce-pr-author-skill.ps1` PreToolUse hook: the sentinel constants, read seam, and validation function are removed, and a new `Test-PrAuthorReceiptVerification` function runs five ordered, short-circuiting deny checks (`PR_BODY_PATH_NONCANONICAL` → `PR_AUTHOR_RECEIPT_MISSING` → `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH` → `PR_AUTHOR_RECEIPT_HASH_MISMATCH` → `PR_AUTHOR_RECEIPT_STALE`) through three injectable adapter seams. Part B restores `### Remediation Loop Checkpoint Shape`, `### CI Monitoring and Post-PR Remediation` (with the verbatim workflow-commit invariant), and `## Remediation Loop Protocol` into the always-loaded orchestrator agent contract. The orchestrate skill's `## PR Creation Gate` is expanded from five to six conditions.

**What changed:**
4 PowerShell files (1 production hook + 2 byte-identical mirrors + 1 test) and 11 Markdown contract/mirror files, plus feature-documentation and evidence files. The hook delta is +153/-86; the test delta is +105/-102. No TypeScript, Python, or C# production code changed. No GitHub Actions workflow, dependency, telemetry, or configuration-key change (consistent with the stated Non-Goals).

**Top 3 risks:**
1. Numeric PowerShell branch coverage is unavailable from the repo's JaCoCo tooling (no BRANCH counter), so the >= 75% branch threshold is verified behaviorally (per-branch test mapping) rather than numerically. Standing limitation, not introduced by this change.
2. The receipt is a policy-level integrity check, not a security boundary — an actor with `Write(/artifacts/**)` can replace both body and receipt. This is correctly disclosed in the hook `.NOTES` and the pr-author agent honest-disclosure section, and is an explicit Non-Goal, not a defect.
3. Two near-duplicate PR-handoff descriptions now exist (orchestrator agent `## PR Creation Delegation` and orchestrate skill `## PR Authoring (pr-author Handoff)`). The agent section explicitly defers to the skill as authoritative, so drift risk is bounded; spec accepts this duplication for governance-critical invariants.

**PR readiness recommendation:** **Go** — The implementation matches the spec and all acceptance criteria; the toolchain is clean, coverage thresholds (line) are met, bundle parity passes, and all targeted invariants are confirmed. No Blocker or Major findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/enforce-pr-author-skill.ps1` | `Test-PrAuthorReceiptVerification` (~186-190, ~204-206, ~227-229) | Three defensive edge guards (invalid-JSON receipt, unreadable body, unparseable `created_at`) are uncovered by tests. | Optional: add targeted `It` blocks for malformed-JSON receipt and unparseable `created_at` to raise line coverage above 91.40%. | These are fail-safe guards on already-validated paths; behavior is conservative (deny). Not a regression on changed primary logic. | `evidence/qa-gates/final-coverage-delta.md`; `git show 041c977:.claude/hooks/enforce-pr-author-skill.ps1` |
| Info | repo coverage tooling | `artifacts/pester/powershell-coverage.xml` | Pester/CoverageGutters JaCoCo emits no `type="BRANCH"` counter, so numeric branch coverage is unmeasurable for the changed hook. | None for this PR; the limitation is repo-wide tooling. Track separately if numeric branch coverage becomes a hard gate. | The >= 75% branch threshold cannot be read from the artifact; per-branch test mapping and the 90.99% instruction proxy provide behavioral assurance. | `grep -c 'type="BRANCH"' artifacts/pester/powershell-coverage.xml` = 0 |
| Info | `.claude/agents/orchestrator.md` / `.claude/skills/orchestrate/SKILL.md` | agent `## PR Creation Delegation`; skill `## PR Authoring (pr-author Handoff)` | Receipt-handoff description is duplicated between the always-loaded agent and the on-demand skill. | Keep the agent section's explicit deferral to the skill as the authoritative source (already present). | Spec explicitly accepts duplication for governance-critical invariants; the agent must remain self-contained when the skill is not loaded. | `git show 041c977:.claude/agents/orchestrator.md` lines 76-78; spec.md "Content duplication ... is acceptable" |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The five ordered deny checks are implemented as short-circuiting branches in a single `Test-PrAuthorReceiptVerification` function, exactly matching the spec's fixed order; the most specific failure surfaces first (noncanonical path before missing receipt, etc.).
- The sentinel removal is complete: `$script:PrAuthorAuthorizationPath`, `$script:PrAuthorAuthorizationTtlSeconds`, `Get-PrAuthorAuthorizationContent`, and `Test-PrAuthorAuthorization` are gone, and the `Get-PrAuthorBypassReason` body-file-with-context path now calls receipt verification instead of the sentinel check. Cases A/B/C and the deny/allow builders are unchanged.
- I/O is isolated behind three named adapter seams (`Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`, `Get-PrContextSummaryLastWriteUtc`), so tests mock at the boundary with no disk or temp-file access. SHA-256 is computed inline over the bytes from the seam, with the hash object disposed in a `finally` block.

#### API and safety notes

- All functions use `[CmdletBinding()]`, `[OutputType(...)]`, and `[Parameter(Mandatory)]` validation. The single analyzer suppression (`PSUseSingularNouns` on `Get-PrBodyFileBytes`) is justified inline.
- The canonical-path match uses case-sensitive `-cnotmatch` so a path differing only in case is correctly rejected as non-canonical before any disk read.
- The staleness check uses strict inequality (`$createdAt -le $contextLastWrite` denies), matching the spec's "strictly newer" requirement, and compares two metadata values without reading wall-clock time, preserving determinism.

#### Error handling and logging

- `ConvertFrom-Json -ErrorAction Stop` is wrapped in `try/catch`; a malformed receipt is treated as missing content (deny), and malformed tool-input JSON throws with explicit context. No broad silent catch-all. The hook's only output remains the PreToolUse decision JSON; the deny path uses `hookSpecificOutput.permissionDecision='deny'` with `permissionDecisionReason`, and the allow path uses `permissionDecision='allow'`, matching the hardened PreToolUse shape from issue #259.

### Markdown contract audit (orchestrate skill, orchestrator agent, pr-author surfaces)

- `.claude/skills/orchestrate/SKILL.md` `## PR Creation Gate` lists six numbered conditions; condition 5 is the receipt condition and condition 6 is the CI-green condition (`ci_gate.conclusion == "success"` AND head-SHA match). The former `## PR Creation Delegation` sentinel section is replaced by `## PR Authoring (pr-author Handoff)`.
- `.claude/agents/orchestrator.md` contains the verbatim string "The orchestrator must not commit workflow-file changes outside the remediation loop." (line 109) and all three governance sections, with `## Remediation Loop Protocol` carrying the six required subsections (Prohibited Delegations, Required Artifacts Per Cycle, Preflight Sub-State Semantics, Scope-change Rule, Exit Gate, Citations). The PR section references the receipt handoff and defers to the orchestrate skill.
- No runtime file references the forgeable sentinel as the PR gate (grep over `.claude/**`, `.codex/**`, `.github/**`, `README.md`, bundled mirrors returned zero matches for `pr_author_authorization`, `issued_by`, `issued_at`, `ttl_seconds`, `Test-PrAuthorAuthorization`).

---

## Test Quality Audit

The test surface covers all five receipt deny reasons, the allow path, and the retained shape blocks (Case A inline `--body` on create and edit; Case B create with no body; Case C `--body-file` with no context on create and edit; edit-no-body allow). Determinism is achieved by mocking the read/existence seams; no temp files are created and no live `gh` invocation occurs. The full claude-hooks suite (378 tests) and the targeted run (46 tests) both report zero failures.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — verifies the five ordered receipt reasons, allow path, and shape blocks via seam-mocked decision calls; 476 lines (under cap).
- `evidence/qa-gates/final-pester.md` — 378 suite / 46 targeted, 0 failures; targeted line coverage 91.40%.
- `evidence/qa-gates/final-coverage-delta.md` — baseline 93.75% → final 91.40% line, denominator-growth explanation, no regression on changed lines.
- `evidence/qa-gates/final-poshqc-format.md` / `final-poshqc-analyze.md` — format clean (no rewrites), 0 analyzer findings.
- `evidence/qa-gates/final-bundle-parity.md` — runtime == mirror byte-identical for all changed `.claude/**` files; codex hook header-only difference. Independently re-run during this review: 9 passed, 0 failed.
- `evidence/qa-gates/final-grep-no-sentinel.md`, `final-grep-six-condition-gate.md`, `final-grep-orchestrator-governance.md`, `final-line-counts.md` — grep proofs and line-cap verification, all corroborated.

### Quality assessment prompts

- **Determinism:** Read/clock dependencies routed through injectable seams; staleness compares metadata, not wall-clock. No flaky dependencies.
- **Isolation:** Each `It` targets one decision branch or shape block.
- **Speed:** 46 targeted + 378 suite tests completed with EXIT_CODE 0; no sleeps.
- **Diagnostics:** Assertions match on the exact reason code, so a failure names the offending branch.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials or tokens in the hook or contracts; receipt carries only a path, number, hash, and timestamp. |
| No unsafe subprocess or command construction | ✅ PASS | The hook never invokes `gh` or any subprocess; it parses command text and reads artifacts through seams. No `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | `[Parameter(Mandatory)]` on all inputs; tool-input JSON parsed with `-ErrorAction Stop`; receipt JSON parse failure denies. |
| Error handling remains explicit | ✅ PASS | Explicit `try/catch`, deny-on-failure semantics, `finally` disposal of the SHA-256 object. |
| Configuration / path handling is safe | ✅ PASS | Canonical body-file path enforced via case-sensitive regex before any read; `-LiteralPath` used for all filesystem access. |
| Honest disclosure of enforcement strength | ✅ PASS | Hook `.NOTES` and pr-author agent state the receipt is a policy-level integrity check, not tamper-proof; matches the Non-Goal. |

---

## Research Log

No external research was required. All verification was performed against in-repo artifacts, the branch diff (`a17451e..041c977`), and re-run of the in-repo bundle-parity contract tests.

---

## Verdict

The change is ready for normal PR flow. The receipt-model hook, the six-condition PR Creation Gate, the restored orchestrator governance sections, and the runtime/mirror byte-parity all match the spec and acceptance criteria, with a clean PowerShell toolchain, 91.40% line coverage on the changed production file, and passing bundle-parity contract tests. The only non-PASS dimension — numeric PowerShell branch coverage — is a standing repository tooling-format limitation (no JaCoCo BRANCH counter), mitigated by per-branch test mapping and the 90.99% instruction proxy, and is not a defect introduced by this branch. This verdict is consistent with the Findings Table (no Blocker/Major) and the **Go** readiness recommendation above.
