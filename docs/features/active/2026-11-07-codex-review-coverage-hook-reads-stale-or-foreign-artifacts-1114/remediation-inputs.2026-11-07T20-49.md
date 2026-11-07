# Remediation Inputs: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114), cycle 2

Remediation-Mode: proportionate

- Timestamp: 2026-11-07T20-49
- Opened by: the orchestrator after the cycle 1 re-audit returned PASS, to correct a related non-blocking finding inside the item before merge.
- Branch: `bug/codex-coverage-hook-freshness` at `37e2f147a`
- Base: `main`, merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e`

## Source audit artifacts

- `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/code-review.2026-11-07T20-40.md` (CR-3, Low)
- `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/feature-audit.2026-11-07T20-40.md`
- `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/policy-audit.2026-11-07T20-40.md`

## Findings

### CR-3 - Traversal check applies to non-audit paths

- Severity: Low (non-blocking in the re-audit; corrected here because cycle 1 introduced it)
- Remediability: autonomous
- Finding-Scope: contained
- File/location: `.codex/hooks/feature-review-coverage-target.ps1`, `Get-CodexReviewPolicyAuditPath`, the `..` segment check added for CR-2; and its bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- Defect: the `..` check runs on every candidate containing `docs/features/active/`. A reviewer message that names a valid policy audit and also cites another artifact path with a `..` segment (for example a code-review path) now blocks with `AUDIT_PATH_TRAVERSAL`, and the reason text calls that other path the policy-audit path. Before cycle 1 the same message passed.
- Resolution: apply the `..` check only to candidates whose final segment is a policy-audit file name (`policy-audit.<timestamp>.md`, or `policy-audit.md` under an `audit/<timestamp>/` folder), so non-audit candidates are ignored as before; keep the CR-2 behavior for policy-audit candidates. Copy the file byte-identically to the bundle.
- Tests to add in `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1`: a message naming a valid policy audit plus a code-review path containing `..` selects the audit with no block; the existing CR-2 row (a policy-audit path with `..`) still reports `AUDIT_PATH_TRAVERSAL`. Use `/`-rooted forward-slash fixtures.
- Verification: the new row fails against the current extractor and passes after the fix; the file stays at or above 85% line coverage and within 500 lines; `legacy-codex-hook-contracts.Tests.ps1` passes; PoshQC format, analyze, the leak scan, and one `Invoke-PoshQCParallelTest` run with no new failures; the bundle contract pytest passes.

## Do not do

- Do not change `.codex/hooks/hook-target-worktree.ps1`, any `.claude/hooks` or `.claude/lib` file, or `.codex/config.toml`.
- Do not add a recency fallback (decision D2).
