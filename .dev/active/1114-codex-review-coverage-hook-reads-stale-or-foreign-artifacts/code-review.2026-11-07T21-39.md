# Code Review: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the canonical issue number 1114.
**Base Branch:** `main` (merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e`, equal to `origin/main`)
**Head Branch:** `bug/codex-coverage-hook-freshness` (`eb20091a7891728d6455578f4376801a04bde37f`)
**Review Type:** Re-audit after remediation cycle 2

---

## Executive Summary

This re-audit covers the full branch diff and examines the cycle 2 change in detail. In `Get-CodexReviewPolicyAuditPath`, the `..` segment check now requires both conditions: the final segment of the candidate matches `$auditNamePattern = '^policy-audit\.(?:[^/]+\.)?md$'`, and the candidate contains a `..` segment. The help text states the narrowed rule. The bundle copy is byte-identical (SHA-256 `4ad81883...c65198` for both). The rest of the branch is unchanged since the cycle 1 re-audit.

CR-3 is resolved. This review called the head extractor directly on nine message shapes, and ran the pre-cycle extractor (from `37e2f147a`) on the new row's message:

| Message shape | Pre-cycle | Head |
|---|---|---|
| `policy-audit-path: <audit>` plus a code-review path with `..` (forward slashes) | `AUDIT_PATH_TRAVERSAL`, no paths | audit selected, no reason code |
| `policy-audit-path: <audit> and C:\r\docs\features\active\x\..\y\code-review.t.md` | not run | audit selected, no reason code |
| `docs/features/active/x-1114/../y/policy-audit.<ts>.md` (labelled) | not run | `AUDIT_PATH_TRAVERSAL` |
| `docs/features/active/x/audit/../policy-audit.md` | not run | `AUDIT_PATH_TRAVERSAL` |
| `docs/features/active/x/../y/POLICY-AUDIT.t.md` | not run | `AUDIT_PATH_TRAVERSAL` |
| `see docs/features/active/x/../y/policy-audit.t.md.` (trailing `.`) | not run | `AUDIT_PATH_TRAVERSAL` |
| `docs/features/active/../policy-audit.md` | not run | `AUDIT_PATH_TRAVERSAL` |
| `docs/features/active/x/../y/feature-audit.t.md` alone | not run | no paths, no reason code (`AUDIT_NOT_NAMED` at the hook) |
| `docs/features/active/x/../policy-audit.t.md/code-review.md` | not run | no paths, no reason code |

Soundness of the narrowing: the shape test (`-notmatch $shapePattern`) and the name test (`-match $auditNamePattern`) are both case-insensitive. The shape pattern accepts final segments of the form `policy-audit.<x>.md` or `policy-audit.md`, and every such segment matches the name pattern. A candidate that the name test exempts from the `..` check therefore fails the shape test and cannot be selected. Fail-closed behavior for policy-audit paths is preserved.

**Top 3 risks:**
1. Function-text drift between the Claude freshness file and the twin; mitigated by the parity rows.
2. Linux-only behavior of the space-root and forward-slash fixtures; covered by the pending CI-dependent criterion.
3. Carried Info: label shapes with Markdown emphasis under a space root are not extracted (fail-closed `AUDIT_NOT_NAMED`).

**PR readiness recommendation:** **Ready**. No blocking finding and no new finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.codex/hooks/feature-review-coverage-target.ps1` | `Get-CodexReviewPolicyAuditPath`, the `..` check | CR-3 from the cycle 1 re-audit is resolved. The check now applies only to candidates whose final segment is a policy-audit file name; a valid audit cited beside a non-audit `..` path is selected, and policy-audit `..` paths still block. | None. | Matches the remediation inputs and the plan's Fixed Design. | Fail-before `evidence/regression-testing/fail-before.2026-11-07T21-08.md`; final gate `evidence/qa-gates/pester-parallel.2026-11-07T21-21.md` (42 of 42 in the target suite); this review's head and pre-cycle probes. |
| Info | `.codex/hooks/feature-review-coverage-target.ps1` | `Get-CodexReviewPolicyAuditPath`, label source | Carried: an absolute path under a root containing a space is not extracted when the label is wrapped in Markdown emphasis, when text follows the path on the label line, or when two such paths share one label line. Paths without spaces in these shapes pass through the token scan. | None required. A later change could strip leading `*` and `_` from the label remainder. | Fail-closed with an actionable `AUDIT_NOT_NAMED` message. | Cycle 1 re-audit probes P01, P02, P09. |
| Info | `.codex/hooks/feature-review-coverage-target.ps1` | `Get-CodexReviewPolicyAuditPath`, token scan | Carried: a path followed by `!` is not extracted. | None. | Outside the named punctuation set. | Cycle 1 re-audit probe P08. |
| Info | `.codex/hooks/feature-review-coverage-target.ps1` | `Resolve-CodexReviewCoverageTarget` | Carried: an absolute path written with an 8.3 short name does not match a long-name session root and yields `AUDIT_NOT_FOUND`. | None in this item; the comparison belongs to the shared resolver, which the spec keeps unchanged. | Reviewers report long names in practice. | Cycle 1 re-audit real-process run. |
| Info | `.codex/hooks/feature-review-coverage-target.ps1` and bundle copy | whole file | The two copies have equal SHA-256 hashes; the file is 249 logical lines, within the Codex 500-line cap; the only command named `git` remains inside `Invoke-CodexReviewCoverageGitExe`. | None. | Mirror and size contracts. | `sha256sum` by this review; `legacy-codex-hook-contracts.Tests.ps1` 43 passed in the merged JUnit. |

No covered file in the branch diff is at or above 700 lines (largest: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, 506 logical lines), so no file-size Warning row applies.

---

## Detailed Review

### Cycle 2 change (`Get-CodexReviewPolicyAuditPath`)

- The candidate is split once into `$segments`. The condition `$segments[-1] -match $auditNamePattern -and $segments -contains '..'` replaces `@($token -split '/') -contains '..'`. The candidate sources, normalization, eligibility rule, prefix rule, shape pattern, and return shape are unchanged, as the plan's Fixed Design requires.
- The check still runs before the shape test, so a policy-audit candidate with `..` in any position reports `AUDIT_PATH_TRAVERSAL` with the existing reason text.
- Trailing punctuation is stripped before the split, so `policy-audit.<ts>.md.` is recognised as a policy-audit name (probe row 6).
- The reason text still calls the path "the policy-audit path"; after the narrowing that description is accurate for every path that reaches it.

### Tests

- One row was added and no existing row was edited (the cycle 2 test diff has 7 added and 0 removed lines). It asserts the exact `Paths` list and an empty `ReasonCode`. It failed before the fix on its outcome assertion and passes after. The three existing `AUDIT_PATH_TRAVERSAL` rows pass in both runs, so both branches of the new conjunct are exercised.
- The fixture uses `$script:AuditA` and a forward-slash exact-case literal with no drive letter, suitable for the Linux hook-suite job.

### Rest of the branch

- Unchanged since the cycle 1 re-audit. Hook ordering, freshness twin parity, bundle copies (SHA-256 equal for all three hook files), `core.json` entries, and the brief copies are as previously recorded. This review re-ran the pytest contract set (50 passed) and the Codex generator check (exit 0) at head.
- The cycle 2 do-not-do boundary holds: `git diff --name-only` from the merge base lists no path under `.claude/hooks`, `.claude/lib`, `.codex/config.toml`, `.codex/hooks/hook-target-worktree.ps1`, or `config/file-size-baseline.json`.
