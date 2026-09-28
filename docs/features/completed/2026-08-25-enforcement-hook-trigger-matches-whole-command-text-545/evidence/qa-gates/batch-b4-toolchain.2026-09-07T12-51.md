# Batch B4 — batch toolchain gate (Codex bundle parser mirrors)

Timestamp: 2026-09-07T12-51

Task: [P4-T6]

Batch B4 contents: production
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1`
and
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1`.
The batch owns no test file.

## Batch budget reset (closes B4, opens B5)

Pre-reset listing of `.claude/state/`: empty.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: empty.

The state file was already absent, for the same reason recorded in the batch B3 artifact: both mirrors
were produced with `cp` so byte identity holds by construction, and `cp` does not pass through the
`enforce-powershell-batch-budget.ps1` PreToolUse hook. Batch B4's real file count is 2 production and
0 test files, under the 3-and-3 cap.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain captures before and after the formatter are byte-identical. Both were reduced to an MD5
digest for comparison so the equality is a single decidable observation rather than a visual diff of
21 lines; both digests are `3e2187b142e7181f353b12c43123b857`. The 21 paths listed are the modified
plan file, the four canonical parser copies, the four bundle parser mirrors, the seven evidence
artifacts written so far, and the four parser test suites.

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observation: both Codex bundle mirrors still carry the same SHA-256 as their canonical
sources after the formatter ran.

## Stage 2 — linting

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Result: `ok: true`, equivalent to a repository-wide total of **0** diagnostics.

| Measure | Value |
| --- | --- |
| Error-severity diagnostics on the files this batch touched | 0 |
| Repository-wide total | 0 |
| [P0-T6] baseline repository-wide total | 0 |
| At or below baseline? | yes (equal) |

## Stage 3 — targeted Pester

This batch owns no test file, so stage 3 runs over the two suites that exercise the canonical files
these mirrors copy, as the task directs.

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-suite
results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after stages 1 and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 15 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` | 41 | **0** | 0 | 0 |
| `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1` | 39 | **0** | 0 | 0 |

Both named suites report a numeric failed count of zero.

The same stage-3 limitation recorded for batch B3 applies here: these suites dot-source the canonical
`.codex/hooks` copies, not the bundle mirrors, so they cannot detect a mirror-to-source divergence.
That property is byte identity and it is asserted in the parity section below, and again at [P4-T15]
by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, whose byte-identity leg compares
SHA-256 and which [P4-T9] extends to cover these two new files.

### Reconciliation of the folder-wide failure count

`tests/scripts/codex-hooks`: 731 tests, **15** failures — unchanged from the batch B2 gate. Batch B4
closes no known-red inventory row. The composition is the 14 Codex-side inventory rows plus the one
out-of-inventory environment-dependent failure in `codex-pretooluse-integration.Tests.ps1` that the
batch B1 artifact identified by name and traced to `enforce-epic-wave-barrier.ps1` reading the live
epic checkpoint.

## Batch-level parity

| Canonical | Bundle mirror | SHA-256 (both) |
| --- | --- | --- |
| `.codex/hooks/hook-command-scanner.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | `19223e297d621f5787b54ddaba745e591950d153a8eb749cc21b22509f45dc7d` |
| `.codex/hooks/hook-command-invocation.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` | `b82246c61bb9fcb44ad6471dfa15278069c599ac3a52da26e62ede0cf1e92609` |

Both pairs are equal, satisfying the [P4-T4] and [P4-T5] acceptance conditions. All eight parser
copies now in the tree carry only two distinct hashes — one per parser file — which is the strongest
available statement of the copy-set parity requirement.

Output Summary: batch B4 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**, the before and after porcelain captures sharing MD5
`3e2187b142e7181f353b12c43123b857`. Stage 2 analyze returned `ok: true`, equal to **0** repository-wide
diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports **41 / 0** and **39 / 0**
tests-to-failures over the two named suites. Both Codex bundle mirrors are byte-identical to their
canonical sources. The closing batch-budget reset exited 0 and opens batch B5.
