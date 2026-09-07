# [P13-T1] Final PoshQC format stage

Timestamp: 2026-09-07T17-03

Command:

```
git status --porcelain                                  # before-set capture
mcp__drm-copilot__run_poshqc_format                     # workspace_root: the worktree root, no scan_folders (whole repository)
git status --porcelain                                  # after-set capture
git status --porcelain | grep -F -f <the 38 copy-set paths>   # copy-set restriction, for the AC-16 staleness check
```

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `pwsh` is not invocable anywhere in this session, so the self-hosted
`Invoke-PoshQCFormat` entry point could not be called directly. The formatter was run through the
`mcp__drm-copilot__run_poshqc_format` MCP function, which executes the bundled PoshQC formatter over
the same workspace root. The two porcelain captures were taken with `git` directly and are the
observation that distinguishes a clean run from a repairing one; they do not depend on the route.

## Porcelain captures, verbatim

### Before-set

```
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/coverage-remediation.2026-09-07T16-46.md
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/coverage-delta.2026-09-07T17-00.md
```

### Formatter result

```
{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a478b73e41951af31","summary":"Ran bundled PoshQC format against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a478b73e41951af31'."}
```

### After-set

```
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/coverage-remediation.2026-09-07T16-46.md
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/coverage-delta.2026-09-07T17-00.md
```

## Set-difference count

**0.**

The after-set and the before-set are identical, path for path and status code for status code. The
three paths present in both are the two Markdown evidence and plan files this delegation had already
edited before the formatter ran, plus the untracked `coverage-delta` artifact written by [P12-T10].
No path is present in the after-set and absent from the before-set, so the formatter rewrote nothing.

The set difference is computed on the path component of each porcelain line, with the two-character
status field and its separator stripped, so a status transition on an already-listed path would also
have registered. None did.

## AC-16 staleness check on the copy set

The [P12-T4] pair-hash artifact `evidence/other/pair-hash-parity.2026-09-07T15-52.md` computed all
19 pair hashes at commit `cc83c0c8`. AC-16 requires those hashes to describe the final commit, so
the formatter's effect on the copy set is checked directly rather than inferred.

| Check | Command | Result |
|---|---|---|
| Copy-set restriction of the after-set porcelain | `git status --porcelain` filtered to the 38 copy-set paths | **empty, 0 lines** |
| Copy-set paths touched between `cc83c0c8` and the current HEAD `5903d0c7` | `git diff --name-only cc83c0c84ecede048fa5e275eb7a6d66248639fc 5903d0c7` | **0 of the 38**; the 26 paths listed are 20 Markdown documents under `docs/` and 5 new `tests/scripts/codex-hooks/` suites, plus this feature's plan file |

**No copy-set file was rewritten by this formatter run, and no copy-set file changed between the
commit at which the pair hashes were computed and the current HEAD.** The existing pair-hash
artifact therefore still describes the final tree, and the [P12-T4] procedure was **not** re-run.
Had either check been non-empty, the recorded hashes would have been stale and a fresh
`evidence/other/pair-hash-parity.TIMESTAMP.md` would have been required.

The 38 copy-set paths are the two members of each of the 19 pairs enumerated in the [P12-T4]
artifact: 4 parser-sibling pairs, 10 four-copy-hook pairs, 4 two-copy-hook pairs, and the
`pester.runsettings.psd1` registry pair.

## Output Summary

The PoshQC formatter ran over the whole repository and returned `ok: true`. The count of paths
present in the after-set and absent from the before-set is **0**, so the formatter repaired nothing
and the QA loop does not restart at this task. The copy-set-restricted porcelain is empty, which
confirms no file covered by the [P12-T4] pair-hash artifact was rewritten; that artifact still
describes the final tree and no re-run was required.
