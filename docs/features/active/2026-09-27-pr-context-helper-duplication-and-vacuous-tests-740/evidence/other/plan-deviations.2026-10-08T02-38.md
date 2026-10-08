# Plan Deviations

Timestamp: 2026-10-08T02-38
Plan: docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/plan.2026-09-29T22-17.md

## DEV-1 — verification-evidence.ts line shift (+2)

Source: orchestrator, after merging origin/main (6dac65b0) into the branch (#744 JSDoc edits).
Effect: private `relativeToPosix` is at lines 261-274 (definition line 268); private `splitLines` at 276-295 (definition line 282). P0-T17 expected `verification-evidence.ts:268` and `:282` instead of `:266` and `:280`; total remains 12. P1-T13 line citations shift by +2. The file has 295 lines.
Observed: confirmed by P0-T17 (lines 268 and 282, 12 lines total) and P0-T16 (295 lines).

## DEV-2 — jest.config.cjs grew to 455 lines

Source: orchestrator, origin/main merge.
Effect: P1-T18 adds about 15 lines, giving about 470 (under 500). D6 headroom re-derived in evidence/baseline/line-counts.2026-10-08T02-38.md.
Observed: P0-T16 recorded 455.

## DEV-3 — BASE_SHA is the post-merge merge-base

Expected: 6dac65b0930b299dc7b3c3925a607735a05fca35; BASELINE-DRIFT empty.
Observed: `git merge-base HEAD origin/main` printed 6dac65b0930b299dc7b3c3925a607735a05fca35; BASELINE-DRIFT empty (evidence/baseline/scope-baseline.2026-10-08T02-38.md).

## DEV-4 — P0-T9 install performed by the orchestrator

Source: `npm` is not in the executor tool allowlist. The orchestrator ran `npm --prefix extensions/drm-copilot ci --no-audit --no-fund` (EXIT 0, "added 452 packages"). The Glob for extensions/drm-copilot/node_modules/jest/package.json returned the file, so the plan's conditional `npm ci` branch did not run. Recorded in evidence/baseline/ts-npm-ci.2026-10-08T02-38.md.

## DEV-5 — git commands issued with `git -C REPO`

Reason: the worktree isolation guard refused a compound command line containing `cd ... && ... git ...` with the text: "This agent is isolated in the worktree ..., but this command names git in a form too complex to verify that it stays inside the worktree. Refusing to run it — a worktree-isolated agent's git operations must target its own worktree. Split it into plain, separate commands and run them from ...".
Substitution: each plan `git <subcommand> <args>` is issued as `git -C REPO <subcommand> <args>` with unchanged subcommand and arguments. Artifacts record the plan form.

## DEV-6 — Jest output read from a session scratch file

Reason: the PreToolUse hook denied a `cd ... && npx jest ... | tail -15` pipeline with the text: "PreToolUse:Bash hook error: Forbidden Bash pattern: 'cd ... && tail' (or ';'-chained). Claude Code's Bash permission engine cannot resolve a file-reading command (tail) against Read() rules once a preceding 'cd' has changed the working directory in the same command line - it always requires manual approval, regardless of any Read() or Bash() allow rule, and regardless of whether the path argument is relative or absolute. Rewrite as a single command using an absolute path instead of 'cd'-ing first, e.g. run tail directly against the absolute file path, with no leading 'cd'."
Substitution: the plan's `cd extensions/drm-copilot && npx jest ...` command is run unchanged with stdout and stderr redirected to a session scratch file; summary lines are read from that file with the Grep tool. The Jest command itself is not altered.
