# Remediation Inputs: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

Review-Verdict: PASS

- Timestamp: 2026-11-07T20-40
- Review: re-audit after remediation cycle 1
- Branch: `bug/codex-coverage-hook-freshness` at `378c0035a0e423bb4d230e162a6c896c6a567e2f`
- Base: `main`, merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e` (equal to `origin/main`)
- Supersedes: `remediation-inputs.2026-11-07T20-00.md` (its CR-1 and CR-2 are resolved)

## Source audit artifacts

- `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/policy-audit.2026-11-07T20-40.md`
- `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/code-review.2026-11-07T20-40.md`
- `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/feature-audit.2026-11-07T20-40.md`
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `378c0035a`)

## Remediation-required findings

None.

## Pending CI

Criterion 20 of `spec.md` is CI-dependent and stays unchecked; it carries no finding block. The S9 gate owns its check-off.

## Non-required items (no remediation cycle needed)

- CR-3 (Low): in `Get-CodexReviewPolicyAuditPath`, the `..` check applies to every candidate containing `docs/features/active/`. A valid audit cited beside a non-audit `..` path is therefore rejected with `AUDIT_PATH_TRAVERSAL`, and the reason calls that path the policy-audit path. Optional fix: limit the check to candidates whose last segment is a policy-audit file name, add a row for that case, and mirror the file to the bundle.
- Info: space-root absolute paths after a Markdown-emphasised label or followed by text on the label line are not extracted (pre-existing).
- Info: 8.3 short-name absolute paths do not match a long-name session root (shared resolver, out of scope).
