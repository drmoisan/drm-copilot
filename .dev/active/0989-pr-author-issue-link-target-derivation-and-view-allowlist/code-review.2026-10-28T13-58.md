# Code Review: pr-author issue-link, target derivation, and gh pr view allowlist (#989)

---

**Review Date:** 2026-10-28
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989`
**Feature Folder Selection Rule:** the single active folder whose `issue.md` records Issue #989 and whose name matches the branch suffix `-989`.
**Base Branch:** `main` (merge base `6c6aa4f0e123c25089f6669761d93d426eb4401c`)
**Head Branch:** `bug/pr-author-issue-link-target-derivation-and-view-allowlist-989` at `bda84fbf45da8c0c27c660e62ebb71d2ca3262d3`
**Review Type:** Initial review

---

## Executive Summary

The branch changes four PowerShell hook files (one new), four `.claude` prose files, their byte-equal bundle mirrors, one pack-manifest entry, and six Pester suites (three new). The review covered the full diff `6c6aa4f0e..HEAD` (52 files), the regenerated PR context (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, head `bda84fbf4`), and the feature-folder evidence. The implementation follows the spec closely, reuses the existing resolver rather than duplicating resolution logic, and isolates the only new process call behind an injectable, never-throwing seam.

**What changed:**
- `enforce-pr-author-skill.current-branch.ps1` (new, 149 lines): `Invoke-PrAuthorCurrentBranchGitExe` (git seam, injectable `GitInvoker`, returns `ExitCode`/`Output`, never throws), `Get-PrAuthorCurrentBranch` (rejects non-zero exit, empty or whitespace-bearing output, and literal `HEAD`), `Resolve-PrAuthorCurrentBranchTarget` (fallback only when the command-text result is NoTarget and the text carries neither a branch signal nor an issue line), and `Get-PrAuthorTargetGuidanceText`.
- `enforce-pr-author-skill-helpers.ps1`: dot-sources the sibling; `Resolve-PrAuthorWorktreeTarget` passes its result through the fallback; the NoTarget deny reason appends the guidance text and keeps the `<ReasonCode>: <Detail>` prefix and the `--head` substring.
- `enforce-model-routing-receipt.ps1`: `Get-ModelRoutingAuthorAssertedReason` and a pr-author-only call after receipt presence is confirmed; deny sub-code `AUTHOR_ASSERTED_AUTOCLOSE_MISSING` under `MODEL_ROUTING_RECEIPT_BLOCKED:`.
- `enforce-pr-author-command-allowlist.ps1`: exact six-token, case-sensitive `gh pr view <digits> --json closingIssuesReferences,body` clause and updated form text.
- Prose: required delegation line (orchestrate skill, orchestrator agent); three `- Closes` sources and the `## Closing-Reference Verification` section (pr-author skill and agent); `gh pr edit` target forms; `Bash(gh pr view *)` tool entry.

**Top 3 risks:**
1. CI on the PR head (Windows shards and the Linux hook-suite job) has not run; the Linux leg exercises case-sensitive paths and the real-pwsh row on a detached checkout.
2. Wrong-worktree derivation when the pr-author runs a no-signal command outside the item worktree; the spec documents that this fails closed through the preflight and receipt checks.
3. Isolated subagents run `main`'s hook copies, so the new behavior is demonstrated by Pester only until the branch merges (documented in the spec as a residual limit).

**PR readiness recommendation:** **Needs Revision** — no code defect; the PowerShell coverage artifact must be regenerated so repo-wide coverage is verifiable (PA-B1), and merge readiness then depends on CI succeeding on the PR head (AC8, GEN1).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` | `Invoke-PrAuthorCurrentBranchGitExe`, `$code = $LASTEXITCODE` | The exit code is read from the automatic `$LASTEXITCODE` after the invoker runs. An injected invoker that runs no native command and does not set it would return a stale value from an earlier native call (or 0 when none has run). | No change required for production: the default invoker always runs git. Optionally document in the `GitInvoker` parameter help that a stand-in must set `$global:LASTEXITCODE`, as the CB stand-ins already do. | Keeps the seam contract explicit for future test authors. | Diff inspection; `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1` stand-ins set `$global:LASTEXITCODE` explicitly. |
| Info | `.claude/hooks/enforce-model-routing-receipt.ps1` | `Get-ModelRoutingAuthorAssertedReason`, regex `(?m)^Author-asserted autoclose issues:` | The line must start at column 0; an indented or bulleted line (for example `- Author-asserted autoclose issues: #989`) is denied. | None. This matches the spec ("anchored at line start") and the skill text ("on its own line"); the deny reason names the exact expected line. | Strictness is intended; recorded so the behavior is not mistaken for a defect. | AA-09 (mid-line text denies); `spec.md` Data flow. |
| Major | `artifacts/pester/powershell-coverage.xml` (gitignored) | n/a | The canonical coverage artifact was overwritten by the later architecture-guard run (636 tests) and reports 0% PowerShell repo-wide line coverage; the per-file figures exist only in the evidence markdown. Policy audit finding PA-B1. | Rerun the full single-process `Invoke-PoshQCTest -ScanFolders tests/scripts` with coverage as the last coverage-producing run, and record the figures read from the artifact. | Coverage must be verifiable from the canonical artifact; the current artifact fails the 85% floor. | Reviewer parse of the XML (LINE 0/19185); `evidence/qa-gates/contract-final.2026-10-28T13-50.md`. |
| Info | `.agents/skills/pr-author/SKILL.md` | n/a | The optional AC2 parity sentence for the `.agents` pr-author skill was not applied. | None required; the spec marks it optional and no contract test requires it. | Recorded for completeness against the spec's mirror-surface list. | `spec.md` Mirror surface; branch diff. |

No Blocker findings. One Major finding concerns evidence (the coverage artifact), not code.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The fallback re-enters `Resolve-WorktreeItemTarget` with a `branch: <name>` text signal, so ambiguity handling and SessionRoot/OtherWorktree labelling stay in one place (CB-07, CB-08, CB-09).
- The fallback runs only on NoTarget with no signal in the text; a signal that resolves nowhere does not fall back (CB-12), which preserves the "explicit signal wins" ordering in the spec.
- The single executable seam is never-throwing, with a documented reason (an uncaught hook error exits 1, which PreToolUse treats as non-blocking); every failure path returns the original NoTarget result and reason code.
- The helpers file stays at 443 lines because the new logic lives in a sibling, and the sibling imports nothing (architecture guard S4).
- The author-asserted check runs after the receipt-presence check and only for `pr-author`, so the epic-scope early return and other subagent types are unchanged (AA-10, AA-11, AA-12).

#### API and safety notes

- All new functions use `[CmdletBinding()]` and `[OutputType()]`, with `Mandatory`, `ValidateNotNull`, `AllowNull`, and `AllowEmptyString` where appropriate.
- The view clause compares six tokens exactly and case-sensitively (`-ceq`, `-cmatch '^\d+$'`), so `--web`, `--jq`, `-R`, extra or reordered fields, and trailing tokens deny (AL-40 to AL-48). Record-level checks (wrappers, substitutions, redirections) still run before the form test (AL-47).
- The issue number in the regex is the integer from `ConvertTo-WorktreeItemIssueNumber`, so no regex metacharacter can enter the pattern; `(?!\d)` prevents prefix collisions in both directions (AA-04, AA-05).
- `epic_mode` is tested by property presence before value, consistent with the strict-mode pattern used in `Test-EpicBaseBranchOverride`.
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

- `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` — AA-01 to AA-12: present, absent, wrong number, both prefix collisions, no issue-num, epic_mode true and false, mid-line, other subagent, epic scope, receipt-missing precedence.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.CurrentBranch.Tests.ps1` — CB-01 to CB-16: seam with injected stand-ins (no process start), branch reader edge cases, fallback ordering, ambiguity passthrough, guidance text, existing checks applied to the derived item, skill-gate allow.
- `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1` — AL-39 allow and AL-40 to AL-48 deny rows; AL-49 form text.
- `tests/scripts/claude-runtime/pr-author-issue-link-contract.Tests.ps1` — PC-01 to PC-07 prose contracts over the skill and agent sections and frontmatter.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `...OrchestratorStatePreflight.Tests.ps1` — neutralize the branch seam so existing NoTarget rows do not depend on the real checkout.
- `evidence/regression-testing/expect-fail.2026-10-28T13-12.md` — 32 expected failures before implementation, with messages.
- `evidence/qa-gates/pester-gss.2026-10-28T13-31.md`, `evidence/qa-gates/pester-full.2026-10-28T13-48.md` — 454/0 and 11438/0, with per-file line coverage.
- `evidence/regression-testing/pester-shuffle.2026-10-28T13-32.md` — three seeded orders, 0 failures.
- `evidence/other/bundle-parity.2026-10-28T13-25.md` — eight equal SHA-256 pairs; re-verified by the reviewer with `git hash-object` (8/8 identical object IDs).

### Quality assessment prompts

- **Determinism:** no real git, network, clock, or temporary file in the new rows; synthetic `/synthetic-worktrees/...` roots; seeded shuffle shows no order dependence.
- **Isolation:** one behavior per `It`; resolver mocks use a `ParameterFilter` on `$Text` to separate the command-text call from the branch re-resolution.
- **Speed:** the new rows start no process; the full single-process run completed in 714.87 s for 11448 tests.
- **Diagnostics:** `-Because $reason` carries the full deny text into failure output.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspected; no credentials, tokens, or keys added. |
| No unsafe subprocess or command construction | PASS | Git runs with fixed arguments `rev-parse --abbrev-ref HEAD` through the call operator; no string-built command. The allowlisted view form is read-only and matched exactly. |
| Input validation at boundaries | PASS | Branch output rejected when empty, whitespace-bearing, `HEAD`, or non-zero exit; issue number normalized to an integer before use in the regex. |
| Error handling remains explicit | PASS | The one catch-all is the documented never-throw seam, and it maps to the existing NoTarget deny (fail closed). |
| Configuration / path handling is safe | PASS | No new paths; re-resolution uses the existing resolver and session root; manifest entry added in sorted position. |
| Fail-closed behavior of the new fallback | PASS | Detached HEAD, git failure, or empty output keeps the NoTarget deny (CB-04 to CB-06, CB-10); a derived branch still passes the full preflight and receipt checks (CB-15). |

---

## Research Log

No external research was required. The review relied on the branch diff, the spec, the research note in the feature folder, and the evidence artifacts.

---

## Verdict

The implementation is consistent with the spec, keeps target resolution in the existing resolver, and is covered by focused, deterministic Pester rows with recorded expect-fail evidence. The findings are one Major evidence finding (the canonical PowerShell coverage artifact reports 0% after being overwritten), one Minor documentation suggestion, and two Info notes. None requires a code change.

The change needs one evidence revision: regenerate the full-run coverage artifact (PA-B1). Merge readiness then depends on CI succeeding on the PR head, which the feature audit tracks as the pending-CI items AC8 and GEN1.
