# Push-Down Resource Contracts Guard — State-Exempt Result

Timestamp: 2026-09-08T04-22

Task: [P6-T6]

Command:
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q --no-header -p no:cacheprovider`

EXIT_CODE: 1

ExpectedExitCode: 1

## Why this artifact rather than the main one

P6-T6 defines two alternative artifacts, not a pair. The run exited non-zero with every reported
path under `.claude/state/`, so this state-exempt artifact is written and
`evidence/qa-gates/push-down-resource-contracts.2026-09-06T23-09.md` is deliberately not written.
Writing the main artifact with a non-zero `EXIT_CODE:` and no expectation would make a passing gate
render as a failed one, because
`scripts/dev_tools/pr_context/verification_evidence.py:163-164` defaults a missing expectation to
`0` and `:61-74` normalizes a gate to `pass` only when the observed code equals the expectation.
`ExpectedExitCode: 1` is declared above and equals the observed code, so this gate normalizes to
`pass`. This file carries exactly one line whose text before the first colon is exactly
`EXIT_CODE`.

## Observed result

Numeric test count: 11 tests collected, 10 passed, 1 failed, 0 skipped.

The single failing test is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`.

## Complete observed path list

The failing assertion reported exactly one path:

- `.claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json`

That is the batch-budget state file under `.claude/state/` whose name embeds the resolved session
id `worktree-agent-a5a6952a0a1e65c6e-eefb09b2`, which is one of the two paths P6-T6 admits. The
assertion at `test_push_down_claude_resource_contracts.py:125` fails on the first offending path, so
the directory was enumerated independently to establish the complete set. `ls -la .claude/state/`
lists exactly one regular file, that same batch-budget state file;
`.claude/state/current-session-id` does not exist in this worktree. The observed path set is
therefore complete and every member sits under `.claude/state/`. No reported path lies outside that
directory.

## Why the set is non-empty here and was empty at baseline

P0-T8 recorded `.claude/state/` as **absent** at baseline with both Python guards passing and an
empty reported-path list. Equality with that baseline set is not the condition of this task and
would be unsatisfiable: `test_push_down_claude_resource_contracts.py:39-48` enumerates the `.claude`
tree with `rglob("*")` and collects files only, so an empty or absent directory produces no reported
path, while the state files this plan's own batch-budget resets re-create do. The file observed here
was re-created by `.claude/hooks/enforce-powershell-batch-budget.ps1:366` after [P6-T1]'s reset, when
the two `pester.runsettings.psd1` edits in [P6-T3] and [P6-T4] were made through the Edit tool and
the PreToolUse hook counted them. `.claude/state/` is gitignored (`.gitignore:68`). This is a
pre-existing repository defect tracked separately; no task in this plan attempts to fix it.

## Mirror presence and text equality

Each mirror was compared against its `.claude` source with `cmp`, which reports a byte difference
and exits non-zero when the files differ. All four comparisons exited 0.

| Source | Mirror | `cmp` exit |
| --- | --- | --- |
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | exit status 0 |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | exit status 0 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | exit status 0 |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | exit status 0 |

The module mirror, both hook mirrors, and the skill mirror are therefore present and text-equal.
The suite's own text-equality test over the bundled payload passed in the same run; the only failing
assertion was the enumeration one reported above.

Output Summary: 10 of 11 tests passed. The one failure is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, and the complete set of reported
paths is the single gitignored path
`.claude/state/powershell-batch-budget.worktree-agent-a5a6952a0a1e65c6e-eefb09b2.json`, which sits
under `.claude/state/` and is admitted by this task. No reported path lies outside `.claude/state/`.
All four mirrors this change introduces or updates are present and byte-identical to their `.claude`
sources. This satisfies AC-21.
