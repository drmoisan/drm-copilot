# Batch B10 — batch toolchain gate (`enforce-pr-author-skill-helpers.ps1`, both Claude copies)

Timestamp: 2026-09-07T14-04

Task: [P7-T4]

Batch B10 contents: production `.claude/hooks/enforce-pr-author-skill-helpers.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`;
test `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (3 paths):

```
 M .claude/hooks/enforce-pr-author-skill-helpers.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
?? tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
```

Porcelain capture AFTER the formatter (3 paths):

```
 M .claude/hooks/enforce-pr-author-skill-helpers.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1
?? tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
```

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

Corroborating observation beyond the exit code: the edited hook's SHA-256 is
`658277ddc0523c07ad9c488215fc56bf3e045777e71b8950459676c8d87c61c5` both before and after the
formatter run, and the new suite's is
`9da8f61550250eff076d79f1db9222072411ed06c0246182d8bf97d0ed3c250d`. The formatter neither created a
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

EXIT_CODE: 5 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `enforce-pr-author-skill.TriggerScoping.Tests.ps1` (owned by this batch) | 18 | **0** | 0 | 0 |
| `enforce-pr-author-skill.Tests.ps1` | 43 | 1 | 0 | 0 |
| `enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | **0** | 0 | 0 |
| `enforce-pr-author-skill.Payload.Tests.ps1` | 9 | **0** | 0 | 0 |
| `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 3 | **0** | 0 | 0 |

All eighteen cases in the suite this batch owns pass:

| Case | Result |
| --- | --- |
| allows a quoted --body-file mention inside a JSON receipt value | PASS |
| classifies gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md | PASS |
| classifies gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md | PASS |
| does not match --body against a --body-file token | PASS |
| wrapper deny pin 1: classifies a gh pr create relocated through xargs | PASS |
| wrapper deny pin 2: classifies a gh pr create nested inside a bash -c argument | PASS |
| wrapper deny pin 3: classifies a gh pr create nested inside an sh -c argument | PASS |
| wrapper deny pin 4: classifies a gh pr create behind the env transparent wrapper | PASS |
| wrapper deny pin 5: classifies a gh pr create behind the pwsh -Command wrapper | PASS |
| wrapper deny pin 6: classifies a heredoc body piped into bash | PASS |
| wrapper deny pin 7: classifies a live substitution inside a double-quoted span | PASS |
| PR_AUTHOR_SKILL_BLOCKED for gh pr create with no body flag | PASS |
| PR_CONTEXT_MISSING for gh pr create --body-file when the context artifact is absent | PASS |
| PR_BODY_PATH_NONCANONICAL for a --body-file path outside the canonical pattern | PASS |
| PR_AUTHOR_RECEIPT_MISSING when the sibling receipt is absent | PASS |
| PR_AUTHOR_RECEIPT_NUMBER_MISMATCH when the receipt number does not equal the path number | PASS |
| PR_AUTHOR_RECEIPT_HASH_MISMATCH when the body hash does not equal the recorded hash | PASS |
| PR_AUTHOR_RECEIPT_STALE when created_at is not newer than the context last-write | PASS |

### Reconciliation of the folder-wide failure count

`tests/scripts/claude-hooks`: 1491 tests, **5** failures, 0 errors, 0 skipped.

- 4 from `hook-command-parser.AcceptanceCases.Tests.ps1`: `AT-1`, `AT-2`, `AT-4`, and `AT-7`. These
  are rows 1, 2, 4, and 6 of the [P1-T13] known-red inventory, closed by [P8-T14] (AT-1, AT-7) and
  [P9-T11] (AT-2, AT-4). Batch B10 closes no inventory row, which is the expectation the inventory
  records for Phase 7.
- 1 from `enforce-pr-author-skill.Tests.ps1`, case
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. This is the
  pre-existing baseline failure recorded in the appendix of the [P1-T13] inventory and in
  `evidence/baseline/baseline-selfhosted-test.2026-09-07T10-57.md`. It is **not** an inventory member
  and **not** a regression introduced by [P7-T1]: its observed decision is `deny` where `allow` is
  expected, byte-for-byte the same failure text recorded at baseline. Its cause is ambient: the case
  leaves `Get-PrAuthorCheckpointContent` unmocked, so receipt check 6 reads the real
  `artifacts/orchestration/orchestrator-state.json` in this worktree, which carries
  `epic_mode: true` and `epic_context.integration_branch` equal to
  `epic/cleanup-merged-worktrees-hardening-integration`, while the fixture command carries no
  `--base`. `Test-EpicBaseBranchOverride` therefore returns `EPIC_BASE_BRANCH_MISMATCH`. The sibling
  `gh pr edit` case in the same Context passes, because check 6 constrains `gh pr create` only.

Post-change counts for the four other pr-author suites are unchanged from baseline, so [P7-T1] moved
no case in either direction beyond the intended trigger-scoping behaviour.

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `658277ddc0523c07ad9c488215fc56bf3e045777e71b8950459676c8d87c61c5` | 240 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `658277ddc0523c07ad9c488215fc56bf3e045777e71b8950459676c8d87c61c5` | 240 |

Equal, and both at or under the 500-line cap. The new test suite measures 280 lines.

## Batch budget reset (closes B10, opens B11)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Derivation: `CLAUDE_SESSION_ID` is
unset and `.claude/state/current-session-id` is absent, so the worktree-derived form applies. The
normalized repository root is
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31`; its leaf is
`agent-a478b73e41951af31` and the first four bytes of its UTF-8 SHA-256 render as `e3281c7b`.
Cross-checked against the files actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.claude/hooks/enforce-pr-author-skill-helpers.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. Batch B10's real file count is 2 production and 1 test file, under the
3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files.

Output Summary: batch B10 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; the before and after porcelain captures are byte-identical and the
edited hook's SHA-256 is unchanged across the run. Stage 2 analyze returned `ok: true`, equal to
**0** repository-wide diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports
**18 tests / 0 failures** for the suite this batch owns. The folder-wide count is 1491 tests with 5
failures: four are the known-red inventory rows AT-1, AT-2, AT-4, and AT-7, which Phase 7 does not
close, and one is the documented pre-existing, ambient-state-dependent `enforce-pr-author-skill`
baseline failure, unchanged in direction and message by [P7-T1]. No stage failed and no stage rewrote
a file, so no restart from stage 1 was required. The closing batch-budget reset exited 0.
