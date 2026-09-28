# Batch B17 — batch toolchain gate (Claude `validate-bash.ps1`, both copies)

Timestamp: 2026-09-07T15-17

Task: [P10-T7]

Batch B17 contents: production `.claude/hooks/validate-bash.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`;
test `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter: **21 paths.** Porcelain capture AFTER the formatter: the same
**21 paths**, in the same order. The after-set is reproduced in full:

```
 M .claude/hooks/enforce-epic-merge-gate.ps1
 M .claude/hooks/validate-bash.ps1
 M .codex/hooks/enforce-epic-merge-gate.ps1
 M docs/features/active/.../evidence/regression-testing/known-red-inventory.2026-09-07T11-53.md
 M docs/features/active/.../plan.2026-08-25T08-13.md
 M docs/features/active/.../spec.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1
?? docs/features/active/.../evidence/qa-gates/batch-b15-toolchain.2026-09-07T14-55.md
?? docs/features/active/.../evidence/qa-gates/batch-b16-toolchain.2026-09-07T15-03.md
?? docs/features/active/.../evidence/qa-gates/codex-merge-gate-no-digit-scan.2026-09-07T14-59.md
?? docs/features/active/.../evidence/regression-testing/ea2-false-allow-direction.2026-09-07T14-51.md
?? docs/features/active/.../evidence/regression-testing/fail-before-validate-bash.2026-09-07T15-10.md
?? docs/features/active/.../evidence/regression-testing/pass-after-at2-at4.2026-09-07T15-06.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-merge-existing-suite.2026-09-07T14-51.md
?? docs/features/active/.../evidence/regression-testing/pass-after-epic-merge-triggerscoping.2026-09-07T14-50.md
?? docs/features/active/.../evidence/regression-testing/pass-after-validate-bash.2026-09-07T15-14.md
?? tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1
?? tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
?? tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
```

The feature paths are abbreviated to `docs/features/active/.../` for width; their full prefix is
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/`. The
`spec.md` modification is the AC-27, AC-28, and AC-34 check-offs performed at the end of Phase 9; the
`known-red-inventory` modification is the amendment appended at [P10-T2].

**Set-difference count (paths in the after-set and absent from the before-set): 0.** Computed
mechanically with `comm -13` over the two sorted captures.

Corroborating observation beyond the exit code: the edited hook's SHA-256 is
`bd0c2ffe8f1e490c417d21717393878d05f5f15038899da09928e91ba22d3146` both before and after the
formatter run — the same value recorded by the [P10-T5] mirror comparison. The formatter neither
created a path nor rewrote a file in this batch, so no restart from stage 1 was required.

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
and per-case results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after
stages 1 and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `validate-bash.TriggerScoping.Tests.ps1` (owned by this batch) | 7 | **0** | 0 | 0 |
| `validate-bash.Tests.ps1` | 26 | **0** | 0 | 0 |

All seven cases in the suite this batch owns pass; the per-case table is in
`evidence/regression-testing/pass-after-validate-bash.2026-09-07T15-14.md`.

### Reconciliation of the folder-wide failure count

`tests/scripts/claude-hooks`: 1517 tests, **1** failure, 0 errors, 0 skipped.

- 1 from `enforce-pr-author-skill.Tests.ps1`, case
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` — the documented
  pre-existing, ambient-state-dependent baseline failure recorded in the known-red inventory's
  appendix. Out of scope for this change.

Known-red inventory rows 35 through 38, appended at [P10-T2], all closed at [P10-T3], so the
inventory contributes **0** failures here. No name outside the inventory appendix fails.

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.claude/hooks/validate-bash.ps1` | `bd0c2ffe8f1e490c417d21717393878d05f5f15038899da09928e91ba22d3146` | 402 |
| `extensions/.../claude-customizations/.claude/hooks/validate-bash.ps1` | `bd0c2ffe8f1e490c417d21717393878d05f5f15038899da09928e91ba22d3146` | 402 |

Equal, and both at or under the 500-line cap. The file was 230 lines before this work and is 402
after. The new test suite measures 82 lines and hashes to
`a5d95e1d4ea03b0dbe0a9883fbd9f790719e49d3a5128f2befdd137dcd42f5b7`.

## Byte-unchanged constraint check

`git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks/validate-bash.ps1`
produces eight hunks. None of them touches the body of `Get-BlockedBashPattern`: the hunk boundaries
run `@@ -41,0 +42,5 @@` (the dot-source lines) and then `@@ -57,0 +63,71 @@` (immediately after the
function's closing brace at original line 56), so original lines 48 through 56, which hold the six
denylist literals, are untouched. **All six denylist literal strings are byte-unchanged.** The
`$script:CdChainedReadCommandPattern` assignment likewise produces no `+` or `-` diff line and is
retained verbatim as a declared constant.

## Batch budget reset (closes B17, opens B18)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.claude/hooks/validate-bash.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. Batch B17's real file count is 2 production and 1 test file, under the
3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files. This reset opens
batch B18.

Output Summary: batch B17 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; the porcelain path count is 21 before and after, and the edited hook's
SHA-256 is unchanged across the run. Stage 2 analyze returned `ok: true`, equal to **0**
repository-wide diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports
**7 tests / 0 failures** for the suite this batch owns and **26 tests / 0 failures** for the existing
`validate-bash.Tests.ps1`, matching its [P0-T10] baseline. The folder-wide count is 1517 tests with 1
failure, the documented pre-existing `enforce-pr-author-skill.Tests.ps1` case. All six denylist
literals and the retained `cd`-chain pattern string are byte-unchanged, confirmed by hunk-boundary
inspection. Both hook copies hash equal at 402 lines, under the 500-line cap. No stage failed and no
stage rewrote a file, so no restart from stage 1 was required. The closing batch-budget reset
exited 0.
