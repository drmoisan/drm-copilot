# Code Review: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the canonical issue number 1114.
**Base Branch:** `main` (merge base `c24cbd295ecec1fc759f52a42806ad991aa49478`; `origin/main` at `12825cb00`)
**Head Branch:** `bug/codex-coverage-hook-freshness` (`ee3bffcf773e6b3238c02878a8fb97eebbdb3b50`)
**Review Type:** Initial feature review

---

## Executive Summary

The change replaces recency-based audit selection in `.codex/hooks/validate-feature-review-coverage.ps1` with selection by the audit path that the reviewer names in `last_assistant_message`, resolves the item root through `Resolve-HookTargetWorktree`, reads the PR summary, `CLAUDE.md`, and coverage reports beneath that root, and adds a freshness decision through a function-text twin of the Claude file. The structure is sound: parsing and selection are pure, git sits behind one wrapper seam, the twin's four functions are text-identical to the Claude file (verified by this review with `diff`), the bundle copies are byte-identical, and coverage is 97.96% to 100%.

Real-process probes found one defect in the extractor. The hook was copied into scratch roots with and without a space in the path, given a policy audit and an empty PR summary, and run through `pwsh -File` with SubagentStop payloads:

| Message shape | Root without space | Root with space |
|---|---|---|
| `policy-audit-path: docs/features/active/<f>/policy-audit.<ts>.md` | exit 0, no output (pass) | exit 0, no output (pass) |
| `policy-audit-path: <absolute path>` | pass | block, `AUDIT_NOT_NAMED` |
| `policy-audit-path: `<absolute path>`` (backticked) | pass | block, `AUDIT_NOT_NAMED` |
| `The audit is docs/features/active/<f>/policy-audit.<ts>.md.` | block, `AUDIT_NOT_NAMED` | block, `AUDIT_NOT_NAMED` |

The token pattern treats whitespace as a hard delimiter even inside backticks or after the `policy-audit-path:` label, and requires the character after `.md` to be whitespace, a quote, or a bracket. For an item worktree whose path contains a space, the absolute form is the only form that resolves the item root, so the reviewer has no message that passes. Before this change the hook did not depend on message text. The failure is fail-closed (no foreign audit is accepted), but it blocks compliant reviews on such hosts, and the Codex core pack ships the hook to consumers.

**Top 3 risks:**
1. CR-1: extraction false negatives for whitespace roots and trailing punctuation.
2. Function-text drift between the Claude freshness file and the twin; mitigated by the parity rows.
3. Base drift: `origin/main` moved by PR #1112; merge-tree is clean and the merged tree passes the leak scan, so the risk is limited to CI on the merge commit.

**PR readiness recommendation:** **Not ready** - CR-1 requires a contained fix in `Get-CodexReviewPolicyAuditPath` and new rows in `feature-review-coverage-target.Tests.ps1`.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `.codex/hooks/feature-review-coverage-target.ps1` | `Get-CodexReviewPolicyAuditPath`, `$tokenPattern` (line 115) | CR-1. Valid audit paths are dropped: an absolute path whose root contains whitespace is split at the space (its remaining prefix is neither empty nor absolute, so it is discarded), including inside backticks and after the `policy-audit-path:` label; a path followed by `.` or `:` fails the trailing lookahead. Both yield `AUDIT_NOT_NAMED`. | Accept the remainder of a `policy-audit-path:` line and the content of a backtick or quote span as one path even when it contains spaces; strip trailing sentence punctuation (`.`, `,`, `:`, `;`) after `.md` before the shape test. Add target rows for a labelled and a backticked absolute path with a space, and for a sentence-final path; mirror the file to the bundle. | A compliant reviewer in a worktree whose path contains a space cannot pass the hook; the spec requires extraction of absolute paths with or without a label. | Real-process probe table in the Executive Summary; direct calls of `Get-CodexReviewPolicyAuditPath` (cases `win-abs-space`, `sentence-period`, `sentence-colon` return no path). |
| Low | `.codex/hooks/feature-review-coverage-target.ps1` | `Get-CodexReviewPolicyAuditPath`, lines 123-126 | CR-2. The shape filter runs before the `..` check, so `docs/features/active/<f>/../other/policy-audit.<ts>.md` is skipped silently and the result is `AUDIT_NOT_NAMED` rather than `AUDIT_PATH_TRAVERSAL`. No `..` path can be selected. | Optionally test `..` on every token containing `docs/features/active/` before the shape filter, in the same change as CR-1. | The block still names a condition, but a less precise one. | Probe case `traversal` returned no path and no reason code. |
| Info | `.codex/hooks/feature-review-coverage-target.ps1` | `Resolve-CodexReviewCoverageTarget` | An absolute path written with an 8.3 short name (for example `DANMOI~1`) does not match a long-name session root and yields `AUDIT_NOT_FOUND`. | None in this item; the comparison belongs to the shared resolver `hook-target-worktree.ps1`, which the spec keeps unchanged. | Reviewers report long names in practice. | First probe run used a short-name scratch root and blocked; the long-name rerun passed. |
| Info | `.codex/hooks/validate-feature-review-coverage-freshness.ps1` | whole file | The four function definitions equal the Claude file's text. | None. | Parity rows pass; the review's own `diff` of the function regions is empty. | `diff` of `sed -n '/^function /,$p'` output for both files. |
| Info | `.codex/hooks/validate-feature-review-coverage.ps1` | entry block | Ordering matches the spec: payload, extraction, root, audit, changed languages, freshness, thresholds, rows. Freshness runs before the zero-language exit, so an absent PR summary in an item worktree blocks. | None. | Spec Data flow. | Diff read by this review. |
| Info | branch | merge with `origin/main` | `git merge-tree --write-tree origin/main HEAD` exits 0; the six merged brief copies share blob `7d6520f96`; `Invoke-PoshQCLeakScan` over the merged tree: 570 files, 0 failures. | None. | PR #1112 added the leak-scan CI step and edited the brief. | Review commands run in the session scratchpad. |

---

## Detailed Review

### Target selection (`feature-review-coverage-target.ps1`)

- `Select-CodexReviewPolicyAudit` uses ordinal comparison for timestamps and a case-sensitive unique sort for folders; correct for the timestamp format.
- `Resolve-CodexReviewCoverageTarget` passes all paths to the resolver when any is absolute; relative paths in the same message are then read beneath the resolved root. This is consistent with the spec, since all named audits must share one folder.
- `Get-CodexReviewCoverageWorktreeList` returns an empty string on failure, which the resolver reads as no registered worktree, falling back to the session root; the audit existence probe then decides. This matches the spec.

### Hook changes

- `$message` is read only when the property exists, so a payload without `last_assistant_message` reaches the D2 block.
- The footer and freshness reason name `$auditPath` beneath the item root.

### Tests

- Entry rows mock the git seam to throw in `BeforeEach`, so no row can reach real git.
- The foreign-audit row keeps a `Get-ChildItem` mock returning a newer foreign audit, which makes it discriminating against the unfixed hook (confirmed by the fail-before evidence).
