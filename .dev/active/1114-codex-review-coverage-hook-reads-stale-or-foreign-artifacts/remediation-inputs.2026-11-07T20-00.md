# Remediation Inputs: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate

- Timestamp: 2026-11-07T20-00
- Review: initial feature review
- Branch: `bug/codex-coverage-hook-freshness` at `ee3bffcf773e6b3238c02878a8fb97eebbdb3b50`
- Base: `main`, merge base `c24cbd295ecec1fc759f52a42806ad991aa49478` (`origin/main` at `12825cb00`; merge-tree clean)

## Source audit artifacts

- `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/policy-audit.2026-11-07T20-00.md`
- `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/code-review.2026-11-07T20-00.md` (1 blocking: CR-1)
- `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/feature-audit.2026-11-07T20-00.md` (0 blocking; criterion 20 pending CI)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `ee3bffcf7`)

## Remediation-required findings

### CR-1 - Audit-path extraction drops valid paths

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the defect and its fix lie in one function of a branch-added file, and the reviewer reproduced it with real hook processes; no external party or decision is needed.
- Finding-Scope: contained
- File/location: `.codex/hooks/feature-review-coverage-target.ps1`, `Get-CodexReviewPolicyAuditPath`, `$tokenPattern` (line 115), and its bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- Defect:
  1. An absolute path whose root contains whitespace is split at the space, including after the `policy-audit-path:` label and inside backticks; the remaining token has a prefix that is neither empty nor absolute and is discarded. A reviewer in an item worktree whose path contains a space has no message form that passes, because only the absolute form resolves the item root.
  2. A path followed by `.` or `:` (sentence punctuation) fails the trailing lookahead and is discarded.
  Both yield `AUDIT_NOT_NAMED`.
- Reproduction: copy `.codex/hooks/*.ps1` to `<scratch>/with space/repo/.codex/hooks`, add `docs/features/active/2026-11-07-x-1114/policy-audit.2026-11-07T20-00.md` and `artifacts/pr_context.summary.txt`, and pipe `{"stop_hook_active":false,"hook_event_name":"SubagentStop","agent_type":"feature-reviewer","last_assistant_message":"policy-audit-path: <absolute audit path>"}` into `pwsh -NoProfile -File <repo>/.codex/hooks/validate-feature-review-coverage.ps1`. Observed: block with `AUDIT_NOT_NAMED`. The same payload under a root without a space exits 0 with no output.
- Resolution:
  1. Treat the remainder of a line after `policy-audit-path:` (trimmed, with surrounding backticks or quotes removed) as one candidate path, spaces included.
  2. Treat the content of a backtick or quote span that contains `docs/features/active/` as one candidate path, spaces included.
  3. Strip trailing `.`, `,`, `:`, and `;` after `.md` before the shape test.
  4. Optionally (CR-2, non-blocking) apply the `..` segment check to every candidate containing `docs/features/active/` before the shape filter, so such paths report `AUDIT_PATH_TRAVERSAL`.
  5. Keep the existing rows passing; copy the file byte-identically to the bundle.
- Tests to add in `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1`: a labelled absolute path whose root contains a space; a backticked absolute path whose root contains a space; a sentence-final path followed by `.`; a path followed by `:`. Use `/`-rooted forward-slash fixtures (for example `/synthetic root/repo/...`) so the rows pass on Linux.
- Verification: the new rows fail against the current extractor and pass after the fix; `feature-review-coverage-target.ps1` stays at or above 85% line coverage and within 500 lines; `legacy-codex-hook-contracts.Tests.ps1` passes; full PoshQC format, analyze, and one `Invoke-PoshQCParallelTest` run with no new failures.

## Pending CI

Criterion 20 of `spec.md` is CI-dependent and stays unchecked; it carries no finding block. The S9 gate owns its check-off.

## Non-blocking items

- CR-2 (Low): a `..` path with two segments below the feature folder reports `AUDIT_NOT_NAMED` rather than `AUDIT_PATH_TRAVERSAL`; no `..` path can be selected.
- 8.3 short-name absolute paths do not match a long-name session root (Info; shared resolver, out of scope).

## Do not do

- Do not change `.codex/hooks/hook-target-worktree.ps1`, any `.claude/hooks` or `.claude/lib` file, or `.codex/config.toml`.
- Do not add a recency fallback (decision D2).
