# Code Review (Re-audit) - Issue #887 (also resolves #888)

- Branch: bug/host-tools-manifest-and-bootstrap-behavior-887, head b5e58fc60 (PR #919)
- Scope: full diff `origin/main...HEAD`
- Timestamp: 2026-10-12T15-30
- Supersedes: `code-review.2026-10-12T15-00.md` (not edited)

## Summary

No production or test file changed after the 15-00 review. `git diff --name-only 59fa06a04 HEAD` lists only `issue.md`, the plan, and four evidence files. The 15-00 per-file review therefore stands without change. The CI run 38294481892 (headSha 59fa06a04) exercised the same `scripts/` and `tests/` content as HEAD, and the `poshqc / PowerShell QC` job concluded success.

## Re-evaluation of 15-00 findings

| ID | 15-00 severity | Status | Severity now |
|---|---|---|---|
| CR-1 | non-blocking | Unchanged. Pinned minimum versions are machine-specific (python 3.13.12, node 24.14.0); state the risk in the PR description. | non-blocking |
| CR-2 | non-blocking | Unchanged. `Invoke-HostBootstrapNpm` ignores exit codes; pre-existing, pinned by `AC11-NPM-NONZERO-NO-THROW`. | non-blocking |
| CR-3 | non-blocking | Unchanged. Verbose/Debug inheritance recognizes only `Continue`, per the issue. | non-blocking |

## New observations

- CI coverage shows the new and changed lines are fully covered (changed-line coverage 100.00% in all four production files), which corroborates the earlier inspection finding that each new branch has a dedicated test.
- `HostTooling.psm1` retains two uncovered lines (95.24%); these are not in the changed lines and were uncovered in the baseline (94.74%). Non-blocking.

## Findings

| ID | Severity | Description |
|---|---|---|
| CR-1 | non-blocking | Pinned minimum versions are machine-specific; document in the PR description. |
| CR-2 | non-blocking | `Invoke-HostBootstrapNpm` ignores exit codes (pre-existing, pinned by test). |
| CR-3 | non-blocking | Verbose/Debug inheritance recognizes only `Continue`. Matches the issue. |

BLOCKING findings: 0.
