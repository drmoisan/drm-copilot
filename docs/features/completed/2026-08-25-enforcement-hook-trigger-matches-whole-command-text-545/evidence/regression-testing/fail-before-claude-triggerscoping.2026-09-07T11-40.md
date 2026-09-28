# Fail-Before — Claude Trigger Scoping (issue #545)

Timestamp: 2026-09-07T11-40

Task: [P1-T5] `[expect-fail]`

Mandated command (attempted first, refused by the runtime worktree-isolation guard):
`pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 -Output Detailed"`

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31` and `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 20

ExpectedExitCode: 1

## Reading the exit code

The observed exit code is **20**, non-zero as the fail-before requirement demands. It is not 1 because
`Run.Exit = $true` makes Pester return the failed-test count, and the executed command ran the whole
`tests/scripts/claude-hooks` folder. The 20 decomposes exactly:

| Source | Failing cases |
| --- | --- |
| `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` (this task's suite) | 13 |
| `hook-command-parser.AcceptanceCases.Tests.ps1` ([P1-T3], still red as designed) | 6 |
| `enforce-pr-author-skill.Tests.ps1` (pre-existing at baseline, recorded in [P0-T7]) | 1 |
| **Total** | **20** |

## Route deviation

The mandated single-suite `pwsh` invocation was refused by the runtime worktree-isolation guard, in
the same terms recorded in [P0-T7]. The folder-scoped MCP route was used instead; per-case results
below are read from this suite's own `<testsuite>` element.

## Suite result

19 cases: **13 failed, 6 passed**, 0 errors, 0 skipped, 0.325 s. The suite parsed and executed.

## FAILING cases (13), named

### Over-match allow cases that deny today (4 of 5)

| `It` | Observed |
| --- | --- |
| `allows a quoted mention of the staging invocation inside an echo argument` | `Expected: 'allow' But was: 'deny'` |
| `allows a heredoc body that quotes the staging invocation in prose` | `Expected: 'allow' But was: 'deny'` |
| `allows prose containing the English word black` | `Expected: 'allow' But was: 'deny'` |
| `allows a cross-segment line whose npm segment and lint mention are in different segments` | `Expected: 'allow' But was: 'deny'` |

### Under-match deny cases that allow today (6 of 6)

| `It` | Observed |
| --- | --- |
| `denies a relocating git add carrying a directory global option` | `Expected: 'deny' But was: 'allow'` |
| `denies a relocating git commit carrying a git-dir global option` | `Expected: 'deny' But was: 'allow'` |
| `denies a relocating git add carrying a work-tree global option` | `Expected: 'deny' But was: 'allow'` |
| `denies an unmodeled dash-leading token between git and its subcommand` | `Expected: 'deny' But was: 'allow'` |
| `denies the subshell spelling of a staging command` | `Expected: 'deny' But was: 'allow'` |
| `denies the command-substitution spelling of a staging command` | `Expected: 'deny' But was: 'allow'` |

Every one of these six is a genuine governed command proceeding with no checkpoint authorization
against an explicitly not-ready checkpoint. This is the latent-bypass direction, and it is now
recorded failing on six distinct spellings rather than one.

### Wrapper deny pins that allow today (3 of 7)

| `It` | Observed |
| --- | --- |
| `wrapper deny pin 2: denies a staging command nested inside a bash -c argument` | `Expected: 'deny' But was: 'allow'` |
| `wrapper deny pin 3: denies a staging command nested inside an sh -c argument` | `Expected: 'deny' But was: 'allow'` |
| `wrapper deny pin 7: denies a live substitution inside a double-quoted span` | `Expected: 'deny' But was: 'allow'` |

## PASSING cases (6), named

| `It` | Why it passes today |
| --- | --- |
| `allows a heredoc whose JSON body names a governed tool as a receipt value` | Already allowed. See the analysis below; it is a deny-preservation pin in the allow direction, not a fail-before case. |
| `does not classify git log --grep add as a staging command` | The trigger requires `git` immediately followed by `add` or `commit`; here `log` intervenes, so no match. Must keep passing. |
| `wrapper deny pin 1: denies a staging command relocated through xargs` | Denies today. |
| `wrapper deny pin 4: denies a staging command behind the env transparent wrapper` | Denies today. |
| `wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper` | Denies today. |
| `wrapper deny pin 6: denies a heredoc body piped into bash` | Denies today. |

13 failing + 6 passing = 19, the full case count.

## Wrapper deny pin status against the unfixed hook, stated per pin as the plan requires

| # | Pin | Against the unfixed hook |
| --- | --- | --- |
| 1 | `xargs git add` | **PASSED** (denies today) |
| 2 | `bash -c 'git add .'` | **FAILED** (allows today) |
| 3 | `sh -c "git add ."` | **FAILED** (allows today) |
| 4 | `env git add .` | **PASSED** (denies today) |
| 5 | `pwsh -NoProfile -Command "Invoke-Pester ..."` | **PASSED** (denies today) |
| 6 | heredoc body piped into `bash` | **PASSED** (denies today) |
| 7 | `echo "$(git add .)"` | **FAILED** (allows today) |

Four of seven pass; three fail.

### Why exactly those three fail, and why it corroborates the specification

The current trigger is `(^|\s)git\s+(add|commit)\b`. Its left anchor requires start-of-string or a
whitespace character immediately before `git`. In the three failing pins the preceding character is
**not** whitespace:

- pin 2, `bash -c 'git add .'` — preceded by a single quote
- pin 3, `sh -c "git add ."` — preceded by a double quote
- pin 7, `echo "$(git add .)"` — preceded by an opening parenthesis

They therefore pass by non-match today. This is the same mechanism as the subshell and substitution
under-match cases above, and it independently confirms the specification's D3 Conclusion, which
records that `bash -c 'git add .'`, `sh -c "git add ."`, and `echo "$(git add .)"` "were **already
ungated before this change**". The three are written here as deny assertions because the D3
fail-closed table states **deny** as the post-fix decision for all seven rows, and D12's wrapper rule
supplies the mechanism: a wrapper-led segment classifies whenever its `RawText` contains the command
word and every subcommand element in any arrangement, which these three satisfy.

The four passing pins are the ones D8 cited as the genuine fail-open risk, and they deny both before
and after. Their value is regression protection: if any of the four turns red later, the masking
model has been applied to a wrapper-led segment and the D8 objection has been answered wrongly.

## The one over-match case that already allows

`allows a heredoc whose JSON body names a governed tool as a receipt value` passes today. The reason
is the same left-anchor property: the JSON body spells the tool names as quoted values, so each is
preceded by a double quote rather than whitespace and pattern 2 does not match. The case is retained
because it must keep allowing after the change, but it is **not** fail-before evidence and is not
counted as such. The corresponding fail-before evidence for the receipt-value class is AT-3 in
[P1-T3], which drives the promotion hook's `IndexOf` scan; that scan has no boundary requirement at
all, so it does fire, and AT-3 is recorded failing.

Output Summary: **Fail-before recorded as required.** Non-zero exit code **20**, decomposing as 13
failures in this suite, 6 in the [P1-T3] suite, and 1 pre-existing baseline failure. This suite
reports 19 tests, **13 failed, 6 passed**. Failing: 4 of 5 over-match allow cases, all 6 under-match
deny cases, and 3 of 7 wrapper deny pins. Passing: the `git log --grep add` stop case, 1 over-match
case that already allows for a left-anchor reason, and 4 of 7 wrapper deny pins. Every wrapper deny
pin's status is stated individually above: pins 1, 4, 5, and 6 **passed**; pins 2, 3, and 7
**failed**, all three because the character preceding `git` is a quote or a parenthesis rather than
whitespace, which independently corroborates the specification's D3 Conclusion.
