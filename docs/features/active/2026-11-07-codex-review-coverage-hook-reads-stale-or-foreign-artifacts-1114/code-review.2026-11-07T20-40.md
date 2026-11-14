# Code Review: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the canonical issue number 1114.
**Base Branch:** `main` (merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e`, equal to `origin/main`)
**Head Branch:** `bug/codex-coverage-hook-freshness` (`378c0035a0e423bb4d230e162a6c896c6a567e2f`)
**Review Type:** Re-audit after remediation cycle 1

---

## Executive Summary

This re-audit covers the full branch diff. It also examines the cycle 1 change to `Get-CodexReviewPolicyAuditPath` in detail. The extractor now merges three candidate sources: the label remainder, quote and backtick spans, and the token scan. It strips trailing sentence punctuation after `.md` and checks `..` before the shape test. The rest of the branch is unchanged since the initial review. The initial review found it sound: the freshness twin is text-identical to the Claude file, bundle copies are byte-identical, and the Claude tree is untouched.

CR-1 is resolved. This review ran the head hook files and the pre-cycle extractor in the same real-process harness. The harness used a root containing a space (long-name path), a policy audit, and an empty PR summary, with SubagentStop payloads piped into `pwsh -File`:

| Message shape | Pre-cycle extractor | Head |
|---|---|---|
| `policy-audit-path: <absolute path under a root with a space>` | block, `AUDIT_NOT_NAMED` | exit 0, no output (pass) |
| `The audit is docs/features/active/<f>/policy-audit.<ts>.md.` | block, `AUDIT_NOT_NAMED` | pass |
| `policy-audit-path: <relative audit>` plus a second line `code-review-path: docs/features/active/<f>/../y/code-review.<ts>.md` | pass | block, `AUDIT_PATH_TRAVERSAL` |
| `Review complete.` (no audit) | block, `AUDIT_NOT_NAMED` | block, `AUDIT_NOT_NAMED` |

The third row is a new behavior introduced by the CR-2 change (CR-3 below). It fails closed, it is repairable in one message, and it requires a `..` path in the reviewer's report, which compliant reviewers do not normally write. It is recorded as Low and non-blocking.

Direct calls of the head extractor (14 message shapes) also confirmed these extractions: a list-item label with a backticked space path, a Windows absolute path with a space written with backslashes, a double-quoted space path, a space path followed by `.` on a label line, a label line ending in two spaces and CRLF, prose containing apostrophes, a backticked path followed by `.`, and a `./` prefix. The pre-cycle extractor failed the first five of these.

**Top 3 risks:**
1. CR-3: a non-audit `..` path cited beside a valid audit causes a one-time false block with a misnamed reason.
2. Function-text drift between the Claude freshness file and the twin; mitigated by the parity rows.
3. Linux-only behavior of the new space-root fixtures; covered by the pending CI-dependent criterion.

**PR readiness recommendation:** **Ready**. No blocking finding. CR-3 can be addressed in this item at low cost or accepted as is.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low | `.codex/hooks/feature-review-coverage-target.ps1` | `Get-CodexReviewPolicyAuditPath`, the `..` segment check in the candidate loop | CR-3. The traversal check runs on every candidate that contains `docs/features/active/` once, before the shape test, so it also fires for non-audit paths. A message that names a valid audit and cites, for example, `docs/features/active/<f>/../y/code-review.<ts>.md` or an evidence path with `..` returns `AUDIT_PATH_TRAVERSAL`, and the reason calls that non-audit path "the policy-audit path". Before cycle 1 the same message passed. | Optional: apply the `..` check only to candidates whose last segment matches `policy-audit.*.md` or `policy-audit.md` (which still catches the CR-2 shape `<f>/../other/policy-audit.<ts>.md`), and add a row naming a valid audit beside a non-audit `..` path. Mirror the file to the bundle. | Fail-closed and repairable in one message; reviewers rarely write `..` paths. The initial review's resolution item 4 recommended checking every candidate, and the cycle implemented that literally. | Direct-call probes P07 and P13 (head: `AUDIT_PATH_TRAVERSAL`; pre-cycle: audit selected); real-process row 3 in the Executive Summary. |
| Info | `.codex/hooks/feature-review-coverage-target.ps1` | `Get-CodexReviewPolicyAuditPath`, label source | An absolute path under a root containing a space is not extracted when the label is wrapped in Markdown emphasis (`**policy-audit-path:** <path>`), when text follows the path on the label line (`<path> (final)`), or when two such paths share one label line. The pre-cycle extractor failed these as well. Paths without spaces in these shapes pass through the token scan. | None required. A later change could strip leading `*` and `_` from the label remainder. | Outside the shapes the remediation inputs named; fail-closed with an actionable `AUDIT_NOT_NAMED` message. | Direct-call probes P01, P02, P09. |
| Info | `.codex/hooks/feature-review-coverage-target.ps1` | `Get-CodexReviewPolicyAuditPath`, token scan | A path followed by `!` is not extracted (the lookahead accepts `.` and `:` and the delimiter set). | None. | Outside the named punctuation set. | Probe P08. |
| Info | `.codex/hooks/feature-review-coverage-target.ps1` | `Resolve-CodexReviewCoverageTarget` | Carried from the initial review: an absolute path written with an 8.3 short name does not match a long-name session root and yields `AUDIT_NOT_FOUND`. Reproduced again in this review's first real-process run. | None in this item; the comparison belongs to the shared resolver, which the spec keeps unchanged. | Reviewers report long names in practice. | Short-name run blocked with `AUDIT_NOT_FOUND`; the long-name rerun passed. |
| Info | `.codex/hooks/feature-review-coverage-target.ps1` and bundle copy | whole file | The two copies have equal SHA-256 hashes; the file is 245 lines, within the Codex 500-line cap; the only command named `git` remains inside `Invoke-CodexReviewCoverageGitExe`. | None. | Mirror and size contracts. | `sha256sum` by this review; `legacy-codex-hook-contracts.Tests.ps1` 43 passed. |

No covered file in the branch diff is at or above 700 lines (largest: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, 506), so no file-size Warning row applies.

---

## Detailed Review

### Cycle 1 change (`Get-CodexReviewPolicyAuditPath`)

- The label source reads to end of line only (`[^\r\n]*`), trims, and removes one pair of matching surrounding quotes or backticks, so a label line cannot merge content across lines.
- The span source is single-line. An apostrophe in prose can open a single-quote span that captures sentence text. Such a candidate fails the shape test or the prefix rule and is skipped, and the token scan still extracts the path. Probe P05 confirmed this.
- The eligibility rule (exactly one `docs/features/active/` per candidate) keeps a label line that carries two audits from being read as one path; the guard row passes, and the token scan extracts both.
- The trailing punctuation strip `(?<=\.md)[.,:;]+$` runs after `/` normalization and before the prefix split; the token lookahead admits `.` and `:` before a delimiter or the end of text, and `,` and `;` were already delimiters.
- The prefix rule is unchanged: the fragment `root/repo/docs/...` that the token scan yields from a space root is dropped, so it cannot add a spurious relative path beside the absolute one.
- The help text describes the new sources, the eligibility rule, and the traversal order.

### Tests

- Seven rows were added, and no existing row was edited (`git diff --numstat` of the test file across the cycle reads 55 added and 0 removed lines). All seven pass in the merged JUnit. The six rows that target CR-1 and CR-2 failed on outcome assertions before the fix. The guard row passed both before and after.
- The resolver row registers `/synthetic root/repo` in a mocked worktree list and asserts `ItemRoot`, `Source` `FilePath`, and the relative audit path, which exercises `Resolve-HookTargetWorktree` with a space root through the real resolver code.

### Rest of the branch

- Unchanged since the initial review. Hook ordering, freshness twin parity, bundle copies, `core.json` entries, and the brief copies are as the initial review recorded. This review re-ran the pytest contract set (50 passed) and the Codex generator check (exit 0) at head.
