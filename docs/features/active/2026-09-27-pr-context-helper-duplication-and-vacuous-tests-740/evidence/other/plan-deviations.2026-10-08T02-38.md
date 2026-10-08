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
A second denial of the same class was received for a `cd ... && grep ...` command line: "PreToolUse:Bash hook error: Forbidden Bash pattern: 'cd ... && grep' (or ';'-chained). ..." (remainder identical to the text above with `grep` in place of `tail`). The command was reissued with absolute paths and no leading `cd`.

## DEV-7 — `\uXXXX` escapes in models.test.ts were stored as raw characters in Phase 1

Observation: at P2-T1 (first loop pass) Prettier listed extensions/drm-copilot/test/lib/pr-context/models.test.ts. Inspection showed that every four-hex-digit JavaScript escape written in P1-T2 and P1-T16 (the escapes for U+E000, U+FFFF, U+FF5E, U+FFFD, U+00E9, and U+2028) had been written to disk as the raw character by the edit tool, while the `\u{...}` forms were stored literally. The Phase 1 commit 53304594 therefore contains raw characters on 13 lines, contrary to the Terms escape-form rule and P1-T2(c).
Runtime effect: none. A raw character and its escape produce the same string value, so the P1-T3 fail-before result (5 failed, 4 passed), the P1-T5 pass-after result (9 passed), and the P1-T16, P1-T19, and P1-T21 results apply unchanged to the escaped source.
Remediation (within the P2-T1 loop remediation clause): a session-scratch Node script replaced U+E000, U+FFFF, U+FF5E, U+FFFD, and U+2028 everywhere, and U+00E9 everywhere except the DOMAIN line, with their `\uXXXX` escapes (17 replacements); the existing DOMAIN elements `"é"` and `"😀"` remain raw per P1-T2(c). `npx prettier --write test/lib/pr-context/models.test.ts` then restored the expanded 13-line DOMAIN form. The loop restarted from P2-T1.

## DEV-8 — models.test.ts exceeded 500 lines; tests compacted

Observation: on loop pass 2, P2-T14 printed `extensions/drm-copilot/test/lib/pr-context/models.test.ts:524`, over the 500-line limit. The plan estimated about +165 lines (about 402). The Arrange, Act, and Assert sections written in P1-T2 and P1-T16 used more lines than that estimate assumed.
Remediation (within the Phase 2 loop remediation clause): the nine "compareCodePoint issue #740 code-point order" tests (D1-D4, S1 unchanged, A1-A4) and the first two "sortedSet" tests were rewritten with a combined `// Arrange / Act` section followed by `// Assert`. This form already appears elsewhere in the file. Test titles, the test count, and every literal expected value are unchanged. The file now has 486 lines. Because the edit tool decodes four-hex `\u` escapes (DEV-7), those escapes were first converted to ASCII placeholders with `sed`, the edit was made, and the placeholders were converted back with `sed`. A scan for non-ASCII characters afterwards found only the two existing raw DOMAIN elements. The loop restarted from P2-T1, and loop pass 3 passed P2-T1 through P2-T15 with no file changed.
