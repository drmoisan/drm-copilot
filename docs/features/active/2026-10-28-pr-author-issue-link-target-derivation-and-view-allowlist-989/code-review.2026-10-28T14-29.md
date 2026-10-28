# Code Review: pr-author issue-link, target derivation, and gh pr view allowlist (#989)

---

**Review Date:** 2026-10-28
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989`
**Feature Folder Selection Rule:** the single active folder whose `issue.md` records Issue #989 and whose name matches the branch suffix `-989`.
**Base Branch:** `main` (merge base `6c6aa4f0e123c25089f6669761d93d426eb4401c`)
**Head Branch:** `bug/pr-author-issue-link-target-derivation-and-view-allowlist-989` at `540819df84031888d4f297a7bf6be421e4e27be1`
**Review Type:** Re-review after remediation cycle 1 (prior: `code-review.2026-10-28T13-58.md`)

---

## Executive Summary

The branch changes four PowerShell hook files (one new), four `.claude` prose files, their byte-equal bundle mirrors, one pack-manifest entry, and six Pester suites (three new). This re-review covered the full diff `6c6aa4f0e..HEAD` (63 files), the PR context regenerated in this review for head `540819df8` (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`), and the feature-folder evidence. Remediation cycle 1 (`bda84fbf4..540819df8`) added only feature-folder documents and evidence; no production code or test changed, so the implementation findings of the prior review carry forward unchanged.

The prior Major finding (the canonical PowerShell coverage artifact reported 0% after a subset run overwrote it) is resolved. The reviewer parsed `artifacts/pester/powershell-coverage.xml` directly: report-level LINE 17787/19185 (92.71%); changed hook files 95.45% to 100%. `artifacts/pester/pester-junit.xml` records 11448 tests, 0 failures, 0 errors.

**What changed:**
- `enforce-pr-author-skill.current-branch.ps1` (new, 149 lines): `Invoke-PrAuthorCurrentBranchGitExe` (git seam, injectable `GitInvoker`, returns `ExitCode`/`Output`, never throws), `Get-PrAuthorCurrentBranch` (rejects non-zero exit, empty or whitespace-bearing output, and literal `HEAD`), `Resolve-PrAuthorCurrentBranchTarget` (fallback only when the command-text result is NoTarget and the text carries neither a branch signal nor an issue line), and `Get-PrAuthorTargetGuidanceText`.
- `enforce-pr-author-skill-helpers.ps1`: dot-sources the sibling; `Resolve-PrAuthorWorktreeTarget` passes its result through the fallback; the NoTarget deny reason appends the guidance text and keeps the `<ReasonCode>: <Detail>` prefix and the `--head` substring.
- `enforce-model-routing-receipt.ps1`: `Get-ModelRoutingAuthorAssertedReason` and a pr-author-only call after receipt presence is confirmed; deny sub-code `AUTHOR_ASSERTED_AUTOCLOSE_MISSING` under `MODEL_ROUTING_RECEIPT_BLOCKED:`.
- `enforce-pr-author-command-allowlist.ps1`: exact six-token, case-sensitive `gh pr view <digits> --json closingIssuesReferences,body` clause and updated form text.
- Prose: required delegation line (orchestrate skill, orchestrator agent); three `- Closes` sources and the `## Closing-Reference Verification` section (pr-author skill and agent); `gh pr edit` target forms; `Bash(gh pr view *)` tool entry.
- Cycle 1: prior review artifacts, remediation inputs and plan, and evidence records `pester-guards.2026-10-28T14-14.md`, `pester-full.2026-10-28T14-26.md`, `scope-check.2026-10-28T14-28.md`, `self-review.2026-10-28T14-30.md`, `phase0-instructions-read.2026-10-28T14-11.md`.

**Top 3 risks:**
1. CI on the PR head (Windows shards and the Linux hook-suite job) has not run; the Linux leg exercises case-sensitive paths and the real-pwsh row on a detached checkout.
2. Wrong-worktree derivation when the pr-author runs a no-signal command outside the item worktree; the spec documents that this fails closed through the preflight and receipt checks.
3. Isolated subagents run `main`'s hook copies, so the new behavior is demonstrated by Pester only until the branch merges (documented in the spec as a residual limit).

**PR readiness recommendation:** **Ready pending CI** — no code defect and no open evidence defect; merge readiness depends on CI succeeding on the PR head (AC8, GEN1).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | `Invoke-PrAuthorCurrentBranchGitExe`, `$code = $LASTEXITCODE` | The exit code is read from the automatic `$LASTEXITCODE` after the invoker runs. An injected invoker that runs no native command and does not set it would return a stale value from an earlier native call (or 0 when none has run). Carried forward; cycle 1 made no code change. | No change required for production: the default invoker always runs git. Optionally document in the `GitInvoker` parameter help that a stand-in must set `$global:LASTEXITCODE`, as the CB stand-ins already do. | Keeps the seam contract explicit for future test authors. | Diff inspection; `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1` stand-ins set `$global:LASTEXITCODE` explicitly. |
| Info | `.claude/hooks/enforce-model-routing-receipt.ps1` | `Get-ModelRoutingAuthorAssertedReason`, regex `(?m)^Author-asserted autoclose issues:` | The line must start at column 0; an indented or bulleted line is denied. | None. This matches the spec ("anchored at line start") and the skill text ("on its own line"); the deny reason names the exact expected line. | Strictness is intended; recorded so the behavior is not mistaken for a defect. | AA-09 (mid-line text denies); `spec.md` Data flow. |
| Info | `artifacts/pester/powershell-coverage.xml` (gitignored) | n/a | Prior Major finding resolved: the artifact is the final full run (report time 14:22:01 UTC, written after the coverage-disabled guard re-run) and reports 92.71% repo-wide line coverage; the four changed hook files are at 97.41%, 95.45%, 100.00%, and 96.43%. | None. | Coverage is now verifiable from the canonical artifact. | Reviewer parse of the XML report-level and per-file LINE counters; `pester-junit.xml` header (11448 tests, 0 failures); `evidence/qa-gates/pester-full.2026-10-28T14-26.md`. |
| Info | `.agents/skills/pr-author/SKILL.md` | n/a | The optional AC2 parity sentence for the `.agents` pr-author skill was not applied. | None required; the spec marks it optional and no contract test requires it. | Recorded for completeness against the spec's mirror-surface list. | `spec.md` Mirror surface; branch diff. |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fallback re-enters `Resolve-WorktreeItemTarget` with a `branch: <name>` text signal, so ambiguity handling and SessionRoot/OtherWorktree labelling stay in one place (CB-07, CB-08, CB-09).
- The fallback runs only on NoTarget with no signal in the text; a signal that resolves nowhere does not fall back (CB-12), which preserves the "explicit signal wins" ordering in the spec.
- The single executable seam is never-throwing, with a documented reason (an uncaught hook error exits 1, which PreToolUse treats as non-blocking); every failure path returns the original NoTarget result and reason code.
- The helpers file stays at 443 lines because the new logic lives in a sibling, and the sibling imports nothing.
- The author-asserted check runs after the receipt-presence check and only for `pr-author`, so the epic-scope early return and other subagent types are unchanged (AA-10, AA-11, AA-12).

#### API and safety notes

- All new functions use `[CmdletBinding()]` and `[OutputType()]`, with `Mandatory`, `ValidateNotNull`, `AllowNull`, and `AllowEmptyString` where appropriate.
- The view clause compares six tokens exactly and case-sensitively (`-ceq`, `-cmatch '^\d+$'`), so `--web`, `--jq`, `-R`, extra or reordered fields, and trailing tokens deny (AL-40 to AL-48). Record-level checks still run before the form test (AL-47).
- The issue number in the regex is the integer from `ConvertTo-WorktreeItemIssueNumber`, so no regex metacharacter can enter the pattern; `(?!\d)` prevents prefix collisions in both directions (AA-04, AA-05).
- `epic_mode` is tested by property presence before value, consistent with the strict-mode pattern used elsewhere.
- PSScriptAnalyzer reports 0 findings; approved verbs only.

#### Error handling and logging

- New deny reason `MODEL_ROUTING_RECEIPT_BLOCKED: AUTHOR_ASSERTED_AUTOCLOSE_MISSING: ...` names the issue number and the exact expected line.
- `TARGET_WORKTREE_NOT_DERIVABLE` keeps its reason code; only the guidance sentence changes, and it states that `--head` is not valid for `gh pr edit` (CB-14).
- Standard error from git is discarded so that it cannot be read as a branch name.
- No new telemetry channel, consistent with the spec.

---

## Test Quality Audit

The new and updated suites cover every new function and the changed decision paths. The expect-fail run shows the 32 new behavioral rows failing against unchanged production code and the 56 preserved-behavior rows passing; after implementation all rows pass.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` — AA-01 to AA-12.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1` — CB-01 to CB-16.
- `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` — AL-39 allow and AL-40 to AL-48 deny rows; AL-49 form text.
- `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1` — PC-01 to PC-07 prose contracts.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `...OrchestratorStatePreflight.Tests.ps1` — neutralize the branch seam so existing NoTarget rows do not depend on the real checkout.
- `evidence/regression-testing/expect-fail.2026-10-28T13-12.md` — 32 expected failures before implementation, with messages.
- `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` — parsed directly: 11448 tests, 0 failures; LINE 92.71% repo-wide.
- `evidence/qa-gates/pester-full.2026-10-28T14-26.md` — matches the artifacts.
- `evidence/qa-gates/pester-guards.2026-10-28T14-14.md` — coverage-disabled guard re-run before the final coverage run.
- `evidence/regression-testing/pester-shuffle.2026-10-28T13-32.md` — three seeded orders, 0 failures.
- `evidence/other/bundle-parity.2026-10-28T13-25.md` — re-verified by the reviewer with `git hash-object` (8/8 identical object IDs at head `540819df8`).

### Quality assessment prompts

- **Determinism:** no real git, network, clock, or temporary file in the new rows; synthetic roots; seeded shuffle shows no order dependence.
- **Isolation:** one behavior per `It`; resolver mocks use a `ParameterFilter` on `$Text`.
- **Speed:** the new rows start no process; the full run completed in 682.53 s for 11448 tests.
- **Diagnostics:** `-Because $reason` carries the full deny text into failure output.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspected; no credentials, tokens, or keys added. |
| No unsafe subprocess or command construction | PASS | Git runs with fixed arguments `rev-parse --abbrev-ref HEAD` through the call operator; the allowlisted view form is read-only and matched exactly. |
| Input validation at boundaries | PASS | Branch output rejected when empty, whitespace-bearing, `HEAD`, or non-zero exit; issue number normalized to an integer before use in the regex. |
| Error handling remains explicit | PASS | The one catch-all is the documented never-throw seam, and it maps to the existing NoTarget deny (fail closed). |
| Configuration / path handling is safe | PASS | No new paths; re-resolution uses the existing resolver and session root; manifest entry added in sorted position. |
| Fail-closed behavior of the new fallback | PASS | Detached HEAD, git failure, or empty output keeps the NoTarget deny (CB-04 to CB-06, CB-10); a derived branch still passes the full preflight and receipt checks (CB-15). |

---

## Research Log

No external research was required. The review relied on the branch diff, the spec, the research note in the feature folder, the canonical Pester artifacts, and the evidence records.

---

## Verdict

The implementation is consistent with the spec, keeps target resolution in the existing resolver, and is covered by focused, deterministic Pester rows with recorded expect-fail evidence. The prior Major evidence finding is resolved. Remaining findings are one Minor documentation suggestion and three Info notes; none requires a change before merge. Merge readiness depends on CI succeeding on the PR head, which the feature audit tracks as the pending-CI items AC8 and GEN1.
