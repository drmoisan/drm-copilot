# Batch B14 — batch toolchain gate (Claude `enforce-parallel-worktree-removal-gate.ps1`, both copies)

Timestamp: 2026-09-07T14-31

Task: [P8-T14]

Batch B14 contents: production `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`;
test `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (24 paths):

```
 M .claude/hooks/enforce-epic-worktree-removal-gate.ps1
 M .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
 M .claude/hooks/enforce-pr-author-skill-helpers.ps1
 M .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
 M .codex/hooks/enforce-epic-worktree-removal-gate.ps1
 M docs/features/active/.../plan.2026-08-25T08-13.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1
?? docs/features/active/.../evidence/qa-gates/batch-b10-toolchain.2026-09-07T14-04.md
?? docs/features/active/.../evidence/qa-gates/batch-b11-toolchain.2026-09-07T14-10.md
?? docs/features/active/.../evidence/qa-gates/batch-b12-toolchain.2026-09-07T14-18.md
?? docs/features/active/.../evidence/qa-gates/batch-b13-toolchain.2026-09-07T14-24.md
?? docs/features/active/.../evidence/qa-gates/test-suite-line-count-pr-author.2026-09-07T14-11.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-base-branch-existing-suite.2026-09-07T14-07.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-worktree-existing-suite.2026-09-07T14-14.md
?? docs/features/active/.../evidence/regression-testing/pass-after-parallel-worktree-existing-suite.2026-09-07T14-28.md
?? tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
?? tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
?? tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
?? tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
?? tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
```

The feature paths are abbreviated to `docs/features/active/.../` for width; their full prefix is
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/`.

Porcelain capture AFTER the formatter: the same 24 paths; `git status --porcelain | wc -l` returned
24 both before and after.

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observation beyond the exit code: the edited hook's SHA-256 is
`d81e2b558cdfa7cd3b87731794f240682542695457e65dc2b318434b5e0213ee` both before and after the
formatter run — the same value recorded by the [P8-T11] mirror comparison — and the new suite's is
`3dd74bd485099a76ad7ff5f0f14a3e8f5c660ee8b79734fa4122f794dcc36633`. The formatter neither created a
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

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 3 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` (owned by this batch) | 3 | **0** | 0 | 0 |
| `enforce-parallel-worktree-removal-gate.Tests.ps1` | 45 | **0** | 0 | 0 |
| `enforce-epic-worktree-removal-gate.Tests.ps1` | 46 | **0** | 0 | 0 |
| `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | 5 | **0** | 0 | 0 |

All three cases in the suite this batch owns pass:

| Case | Result |
| --- | --- |
| resolves the operand when --force precedes the path | PASS |
| brings git -C /repo/main worktree remove into scope | PASS |
| takes a quoted mention of the removal phrase out of scope | PASS |

### Reconciliation of the folder-wide failure count

`tests/scripts/claude-hooks`: 1501 tests, **3** failures, 0 errors, 0 skipped. The count fell from 4
at the batch B12 gate because inventory row 6 closed.

- 2 from `hook-command-parser.AcceptanceCases.Tests.ps1`: `AT-2` and `AT-4` — rows 2 and 4 of the
  [P1-T13] known-red inventory, both closed by [P9-T11].
- 1 from `enforce-pr-author-skill.Tests.ps1`, case
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` — the documented
  pre-existing, ambient-state-dependent baseline failure, unchanged in direction and message
  throughout Phases 7 and 8.

Every failing name is either a member of the [P1-T13] inventory minus the rows this phase closes, or
the one documented pre-existing baseline failure recorded in that inventory's appendix. No name
outside those two sets fails.

## Acceptance-case re-run required by this task

The separate re-run of `hook-command-parser.AcceptanceCases.Tests.ps1` is recorded in
`evidence/regression-testing/pass-after-at1-at7.2026-09-07T14-31.md`. Summary: 11 tests, 2 failures,
derived passed count 9. **AT-1 PASS** and **AT-7 PASS**, closing inventory rows 1 and 6. The two
remaining failures are AT-2 and AT-4, inventory rows 2 and 4.

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `d81e2b558cdfa7cd3b87731794f240682542695457e65dc2b318434b5e0213ee` | 316 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `d81e2b558cdfa7cd3b87731794f240682542695457e65dc2b318434b5e0213ee` | 316 |

Equal, and both at or under the 500-line cap. The new test suite measures 88 lines.

## Phase 8 file-size summary

| File | Lines | At or under 500? |
| --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 447 | yes |
| `extensions/.../claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 447 | yes |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 180 | yes |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 180 | yes |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 316 | yes |
| `extensions/.../claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 316 | yes |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | 107 | yes |
| `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` | 110 | yes |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` | 88 | yes |

## Batch budget reset (closes B14, opens B15)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.claude/hooks/enforce-parallel-worktree-removal-gate.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. Batch B14's real file count is 2 production and 1 test file, under the
3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files. This reset opens
batch B15, which is the first batch of Phase 9 and is not part of this delegation.

Output Summary: batch B14 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; the porcelain path count is 24 before and after, and the edited hook's
SHA-256 is unchanged across the run. Stage 2 analyze returned `ok: true`, equal to **0**
repository-wide diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports
**3 tests / 0 failures** for the suite this batch owns, plus 45, 46, and 5 passing cases for the
three other removal-gate suites. The folder-wide count is 1501 tests with 3 failures, down from 4,
because known-red inventory row 6 (AT-7) closed. The separately recorded acceptance-case re-run shows
**AT-1 and AT-7 both passing**, so this task closes inventory rows 1 and 6 and leaves a remainder of
**2 of 34 rows** — AT-2 and AT-4, both Phase 9. No stage failed and no stage rewrote a file, so no
restart from stage 1 was required. The closing batch-budget reset exited 0.
