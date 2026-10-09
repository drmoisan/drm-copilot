# QC Pass 2: Format ([P10-T2])

Timestamp: 2026-10-08T23-06

Command: mcp__drm-copilot__run_poshqc_format (workspace_root = <WORKSPACE_ROOT>; scan_folders = .claude/hooks, .codex/hooks, tests/scripts/claude-hooks, tests/scripts/codex-hooks)
MCP_CALL: returned
EXIT_CODE: 0 (MCP result `ok: true`; no output is read from the result, rule 4)

Command: git status --porcelain (after the MCP call)
EXIT_CODE: 0
Listing: identical to the [P10-T1] pass-2 listing plus the new untracked `FEATURE/` artifact `qc-pass-2-porcelain-before.2026-10-08T23-05.md`. The six modified write-set test files and the plan file are the only non-`??` lines; no other path appears.

Command: git hash-object -- (the six write-set paths of [P10-T1] pass 2)
EXIT_CODE: 0

| Write-set path | [P10-T1] hash | Recomputed hash | Equal |
|---|---|---|---|
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | 56af7cc8c1d252c38fd874f90e4e62452ef05e6b | 56af7cc8c1d252c38fd874f90e4e62452ef05e6b | yes |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | 6169ce3b233bdf9b264accc9dd26b04fb731152f | 6169ce3b233bdf9b264accc9dd26b04fb731152f | yes |
| tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | 4d4d4a74d525e3e902a064f36beab66a496ce19e | 4d4d4a74d525e3e902a064f36beab66a496ce19e | yes |
| tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | 2a28cddb9fe4bda427f95418cb8b7b8f1d053a89 | 2a28cddb9fe4bda427f95418cb8b7b8f1d053a89 | yes |
| tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 | e6b80b93212ec5ef3beadebb3c34b0bc399f3fc7 | e6b80b93212ec5ef3beadebb3c34b0bc399f3fc7 | yes |
| tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | eb2ff328cdb097a7afdf808c089ade17a03443de | eb2ff328cdb097a7afdf808c089ade17a03443de | yes |

Restore step: no path outside the write set and outside `FEATURE/` appears in the post-call listing, so no `git restore` call was made. Restored paths: none. FORMAT_OUTSIDE_BASELINE: none.

Command: git status --porcelain (after the restore step)
EXIT_CODE: 0
Listing: same as the post-call listing. After removing every line under `FEATURE/` from this listing and from the [P10-T1] pass-2 listing, both reduce to the same six ` M tests/...` lines, so they are equal.

Command: sh <SCRATCHPAD>/s-fmtcheck.sh writeset
EXIT_CODE: 0
Output Summary:
FORMAT_CLEAN for all 60 write-set `.ps1` files (same file set as pass 1).
FORMAT_DRIFT_COUNT: 0
Rewritten write-set paths: none (every recomputed hash equals its [P10-T1] value).
