# Batch B3 — batch toolchain gate (Claude bundle parser mirrors)

Timestamp: 2026-09-07T12-48

Task: [P4-T3]

Batch B3 contents: production
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1`.
The batch owns no test file.

## Batch budget reset (closes B3, opens B4)

Pre-reset listing of `.claude/state/`: empty.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: empty.

The state file was already absent at reset time, because the two mirrors were produced with `cp` so
that byte identity holds by construction, and `cp` does not pass through the
`enforce-powershell-batch-budget.ps1` PreToolUse hook. The reset is therefore a no-op on the counter
in this batch. Both listings are recorded so that fact is visible rather than inferred: an artifact
recording only `EXIT_CODE: 0` would read identically whether the file had been deleted or had never
existed. Batch B3's real file count is 2 production and 0 test files, under the 3-and-3 cap.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

The porcelain captures taken immediately before and immediately after the formatter are identical,
line for line. Both list the same 17 paths: the modified plan file, the four canonical parser copies,
the six evidence artifacts written so far, the two new Claude bundle mirrors, and the four parser test
suites.

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observation: both Claude bundle mirrors still carry the same SHA-256 as their canonical
sources after the formatter ran, which a rewrite of either member of either pair would have broken.

## Stage 2 — linting

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Result: `ok: true`, equivalent to a repository-wide total of **0** diagnostics. The
`$script:DefaultExcludedDirs` list recorded in the [P0-T6] baseline artifact does not exclude
`extensions` or `resources`, so the two new bundle mirrors are inside the analyzed set rather than
skipped by it.

| Measure | Value |
| --- | --- |
| Error-severity diagnostics on the files this batch touched | 0 |
| Repository-wide total | 0 |
| [P0-T6] baseline repository-wide total | 0 |
| At or below baseline? | yes (equal) |

## Stage 3 — targeted Pester

This batch owns no test file, so stage 3 runs over the two suites that exercise the canonical files
these mirrors copy, as the task directs.

TOOLCHAIN_SUBSTITUTION: the plan's `Invoke-Pester -Path <suite>` form is not invocable in this session;
the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used and the per-suite results were
read out of `artifacts/pester/pester-junit.xml`. The run was executed after stages 1 and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 21 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | 42 | **0** | 0 | 0 |
| `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` | 44 | **0** | 0 | 0 |

Both named suites report a numeric failed count of zero.

A limitation of this stage is recorded rather than left implicit: these two suites dot-source the
**canonical** `.claude/hooks` copies, not the bundle mirrors this batch created, so they cannot detect
a divergence between a mirror and its source. The property that actually guards the mirrors is byte
identity, and it is asserted directly in the parity section below and again by
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` at [P4-T15].

### Reconciliation of the folder-wide failure count

`tests/scripts/claude-hooks`: 1465 tests, **21** failures — unchanged from the batch B2 gate. Batch B3
closes no known-red inventory row; it adds two bundle mirrors and modifies no hook call site. The
composition is the 20 Claude-side inventory rows plus the one out-of-inventory environment-dependent
failure in `enforce-pr-author-skill.Tests.ps1` that the batch B1 artifact identified by name and traced
to the unmocked `Get-PrAuthorCheckpointContent` seam.

## Batch-level parity

| Canonical | Bundle mirror | SHA-256 (both) |
| --- | --- | --- |
| `.claude/hooks/hook-command-scanner.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | `19223e297d621f5787b54ddaba745e591950d153a8eb749cc21b22509f45dc7d` |
| `.claude/hooks/hook-command-invocation.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` | `b82246c61bb9fcb44ad6471dfa15278069c599ac3a52da26e62ede0cf1e92609` |

Both pairs are equal, satisfying the [P4-T1] and [P4-T2] acceptance conditions.

Output Summary: batch B3 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**. Stage 2 analyze returned `ok: true`, equal to **0** repository-wide
diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports **42 / 0** and **44 / 0**
tests-to-failures over the two named suites. Both Claude bundle mirrors are byte-identical to their
canonical sources by SHA-256. The closing batch-budget reset exited 0 and opens batch B4.
