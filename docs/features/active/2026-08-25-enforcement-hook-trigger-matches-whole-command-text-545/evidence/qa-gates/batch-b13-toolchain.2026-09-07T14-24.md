# Batch B13 — batch toolchain gate (Codex `enforce-epic-worktree-removal-gate.ps1`, both copies)

Timestamp: 2026-09-07T14-24

Task: [P8-T9]

Batch B13 contents: production `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` and
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1`;
test `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1`.

## Timestamp correction applied before this gate

Six artifacts written earlier in this delegation carried timestamps taken from an estimate rather
than from the clock, and four of the six were in the future relative to UTC. Each was renamed to its
actual UTC write time, read from the file's own modification time, and its `Timestamp:` field was
updated to match. The corrected set:

| Old | Corrected |
| --- | --- |
| `qa-gates/batch-b10-toolchain.2026-09-07T14-03.md` | `qa-gates/batch-b10-toolchain.2026-09-07T14-04.md` |
| `regression-testing/pass-after-epic-base-branch-existing-suite.2026-09-07T14-15.md` | `...2026-09-07T14-07.md` |
| `qa-gates/batch-b11-toolchain.2026-09-07T14-22.md` | `qa-gates/batch-b11-toolchain.2026-09-07T14-10.md` |
| `qa-gates/test-suite-line-count-pr-author.2026-09-07T14-25.md` | `...2026-09-07T14-11.md` |
| `regression-testing/pass-after-epic-worktree-existing-suite.2026-09-07T14-34.md` | `...2026-09-07T14-14.md` |
| `qa-gates/batch-b12-toolchain.2026-09-07T14-40.md` | `qa-gates/batch-b12-toolchain.2026-09-07T14-18.md` |

Two consequences are recorded so they are not mistaken for tampering. First, the porcelain captures
inside the batch B11 and B12 artifacts named three of these files by their pre-correction names; the
names in those captures were updated to the corrected ones, so the captures now name paths that
exist in the tree rather than paths that do not. The path COUNT in each capture, which is the figure
those gates assert on, is unchanged. Second, no measured value — no exit code, hash, line count, or
test count — was altered by the correction.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (19 paths):

```
 M .claude/hooks/enforce-epic-worktree-removal-gate.ps1
 M .claude/hooks/enforce-pr-author-skill-helpers.ps1
 M .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
 M .codex/hooks/enforce-epic-worktree-removal-gate.ps1
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1
?? docs/features/active/.../evidence/qa-gates/batch-b10-toolchain.2026-09-07T14-04.md
?? docs/features/active/.../evidence/qa-gates/batch-b11-toolchain.2026-09-07T14-10.md
?? docs/features/active/.../evidence/qa-gates/batch-b12-toolchain.2026-09-07T14-18.md
?? docs/features/active/.../evidence/qa-gates/test-suite-line-count-pr-author.2026-09-07T14-11.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-base-branch-existing-suite.2026-09-07T14-07.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-worktree-existing-suite.2026-09-07T14-14.md
?? tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
?? tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
?? tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
?? tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
```

The six evidence paths are abbreviated to `docs/features/active/.../evidence/` for width; their full
prefix is `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/`.

Porcelain capture AFTER the formatter: the same 19 paths; `git status --porcelain | wc -l` returned
19 both before and after.

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observation beyond the exit code: the edited Codex hook's SHA-256 is
`3a93339ee3c84a2ed5bbf5278975b228a7a3a802e0ba07b221e65db3fe7d29a8` both before and after the
formatter run — the same value recorded by the [P8-T7] mirror comparison — and the new suite's is
`a10274a8d94b4547980ad27ea0bf376bc8efe008befa66150904b376832a4d12`. The formatter neither created a
path nor rewrote a file in this batch, so no restart from stage 1 was required.

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

## Stage 3 — targeted Pester over the test file this batch owns

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-suite
results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after stages 1
and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` (owned by this batch) | 5 | **0** | 0 | 0 |
| `epic-execution-gates.Tests.ps1` | 40 | **0** | 0 | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | 43 | **0** | 0 | 0 |

All five cases in the suite this batch owns pass, matching the Claude sibling case for case:

| Case | Result |
| --- | --- |
| denies git -C /repo/main worktree remove against a checkpoint with no authorizing record | PASS |
| resolves the operand when --force precedes the path | PASS |
| resolves the same operand when --force follows the path | PASS |
| allows a command whose quoted text merely mentions the removal phrase | PASS |
| keeps git worktree list out of scope | PASS |

`epic-execution-gates.Tests.ps1` is recorded because its `worktree removal gate` Context drives
`Invoke-CodexWorktreeRemovalDecision` with a double-quoted, backslash-separated Windows worktree
path. Its zero failures confirm that the tokenizer's quote stripping reproduces what the previous
pattern's `double` alternative did, and that the allow-after-merge, deny-while-PR-open, and
malformed-stdin cases are unchanged.

`legacy-codex-hook-contracts.Tests.ps1` is recorded because it enforces the 500-line cap and the
root-versus-bundle SHA-256 byte-identity of every Codex hook and drives each hook as a child process.
Its zero failures independently confirm the [P8-T7] mirror, the 180-line count, and that the two new
dot-source lines resolve at run time in a real process.

### Reconciliation of the folder-wide failure count

`tests/scripts/codex-hooks`: 744 tests, **1** failure, 0 errors. The test total rose by 5, the size
of the new suite; the composition is otherwise unchanged from the batch B9 gate.

- 1 from `codex-pretooluse-integration.Tests.ps1`, case `allows every registered handler for every
  tool name its own matcher admits` — the out-of-inventory, out-of-scope, environment-dependent
  failure traced to `enforce-epic-wave-barrier.ps1` reading the live epic checkpoint, which names
  item `545` with unmerged `depends_on` edges and denies with `EPIC_WAVE_BARRIER_BLOCKED`.

Batch B13 closes no row of the known-red inventory directly. The two rows Phase 8 closes, rows 1 and
6, are Claude-side acceptance cases; row 1 already passes and row 6 closes at [P8-T14].

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | `3a93339ee3c84a2ed5bbf5278975b228a7a3a802e0ba07b221e65db3fe7d29a8` | 180 |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | `3a93339ee3c84a2ed5bbf5278975b228a7a3a802e0ba07b221e65db3fe7d29a8` | 180 |

Equal, and both at or under the 500-line cap. `cmp` between the two files exited 0, so the pair is
byte-identical and not merely hash-equal. The new test suite measures 110 lines.

## Batch budget reset (closes B13, opens B14)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.codex/hooks/enforce-epic-worktree-removal-gate.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. Batch B13's real file count is 2 production and 1 test file, under the
3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files.

Output Summary: batch B13 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; the porcelain path count is 19 before and after, and the edited Codex
hook's SHA-256 is unchanged across the run. Stage 2 analyze returned `ok: true`, equal to **0**
repository-wide diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports
**5 tests / 0 failures** for the suite this batch owns, **40 / 0** for `epic-execution-gates`, and
**43 / 0** for `legacy-codex-hook-contracts`, the last of which re-proves the bundle byte-identity
and the 500-line cap in a real child process. The single remaining folder-wide failure is the
documented ambient-state-dependent case in `codex-pretooluse-integration.Tests.ps1`. No stage failed
and no stage rewrote a file, so no restart from stage 1 was required. The closing batch-budget reset
exited 0.
