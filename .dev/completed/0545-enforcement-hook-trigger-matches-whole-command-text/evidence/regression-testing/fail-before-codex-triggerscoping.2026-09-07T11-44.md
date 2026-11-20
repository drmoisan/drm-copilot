# Fail-Before — Codex Trigger Scoping (issue #545)

Timestamp: 2026-09-07T11-44

Task: [P1-T7] `[expect-fail]`

Mandated command (attempted first, refused by the runtime worktree-isolation guard):
`pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 -Output Detailed"`

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31` and `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 14

ExpectedExitCode: 1

## Reading the exit code

The observed exit code is **14**, non-zero as the fail-before requirement demands. `Run.Exit = $true`
makes Pester return the failed-test count, and the executed command ran the whole
`tests/scripts/codex-hooks` folder. The 14 decomposes exactly:

| Source | Failing cases |
| --- | --- |
| `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` (this task's suite) | 13 |
| `codex-pretooluse-integration.Tests.ps1` (pre-existing at baseline, recorded in [P0-T7]) | 1 |
| **Total** | **14** |

## Route deviation

The mandated single-suite `pwsh` invocation was refused by the runtime worktree-isolation guard, in
the same terms recorded in [P0-T7]. The folder-scoped MCP route was used instead.

## Suite result

23 cases: **13 failed, 10 passed**, 0 errors, 0 skipped, 0.257 s. The suite parsed and executed.

## FAILING cases (13), named

### Over-match allow cases that deny today (4 of 5)

1. `allows a quoted mention of the staging invocation inside an echo argument` — `Expected: 'allow' But was: 'deny'`
2. `allows a heredoc body that quotes the staging invocation in prose` — `Expected: 'allow' But was: 'deny'`
3. `allows prose containing the English word black` — `Expected: 'allow' But was: 'deny'`
4. `allows a cross-segment line whose npm segment and lint mention are in different segments` — `Expected: 'allow' But was: 'deny'`

### Under-match deny cases that allow today (6 of 6)

5. `denies a relocating git add carrying a directory global option` — `Expected: 'deny' But was: 'allow'`
6. `denies a relocating git commit carrying a git-dir global option` — `Expected: 'deny' But was: 'allow'`
7. `denies a relocating git add carrying a work-tree global option` — `Expected: 'deny' But was: 'allow'`
8. `denies an unmodeled dash-leading token between git and its subcommand` — `Expected: 'deny' But was: 'allow'`
9. `denies the subshell spelling of a staging command` — `Expected: 'deny' But was: 'allow'`
10. `denies the command-substitution spelling of a staging command` — `Expected: 'deny' But was: 'allow'`

### Wrapper deny pins that allow today (3 of 7)

11. `wrapper deny pin 2: denies a staging command nested inside a bash -c argument` — `Expected: 'deny' But was: 'allow'`
12. `wrapper deny pin 3: denies a staging command nested inside an sh -c argument` — `Expected: 'deny' But was: 'allow'`
13. `wrapper deny pin 7: denies a live substitution inside a double-quoted span` — `Expected: 'deny' But was: 'allow'`

## PASSING cases (10), named

| `It` | Why it passes today |
| --- | --- |
| `allows a heredoc whose JSON body names a governed tool as a receipt value` | Already allowed: the tool names are quoted JSON values, so each is preceded by a double quote rather than whitespace and pattern 2's `(^\|\s)` anchor is not satisfied. A deny-preservation pin in the allow direction, not fail-before evidence. |
| `does not classify git log --grep add as a staging command` | `log` intervenes between `git` and `add`, so the trigger does not match. Must keep passing. |
| `wrapper deny pin 1: denies a staging command relocated through xargs` | Denies today. |
| `wrapper deny pin 4: denies a staging command behind the env transparent wrapper` | Denies today. |
| `wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper` | Denies today. |
| `wrapper deny pin 6: denies a heredoc body piped into bash` | Denies today. |
| `still classifies an apply_patch add of a production script` | Marker leg, upstream of every change. |
| `still declines to classify an apply_patch add of feature documentation` | Marker leg, upstream of every change. |
| `still classifies an apply_patch rename onto a production script` | Marker leg, upstream of every change. |
| `still declines to classify an apply_patch update of feature documentation` | Marker leg, upstream of every change. |

13 failing + 10 passing = 23, the full case count.

## The `apply_patch` marker legs

All four marker-leg assertions **pass**. These are the two legs the Codex copy carries and the Claude
copy does not: `Test-ImplementationCommand` scans for `*** Add|Update|Delete File:` and
`*** Move to:` markers before it reaches the pattern loop. They are asserted here so that "the
marker legs are unaffected" is a measured claim with a before-state on record, rather than an
assumption. All four must still pass after the change.

## Cross-runtime symmetry

The Codex result is identical to the Claude result recorded in [P1-T5], case for case, on the 19
shared scenarios: the same 4 over-match allow cases fail, the same 6 under-match deny cases fail,
the same wrapper pins 2, 3, and 7 fail, and the same pins 1, 4, 5, and 6 pass alongside the
`git log --grep add` stop case and the JSON-receipt-value case.

That symmetry is itself a finding. The defect is present in both runtimes in exactly the same
spellings, which supports the D11.1 ruling that a Claude-only fix would convert a uniform, documented
defect into a runtime-dependent one.

Wrapper deny pin status against the unfixed Codex hook, stated per pin:

| # | Pin | Against the unfixed hook |
| --- | --- | --- |
| 1 | `xargs git add` | **PASSED** |
| 2 | `bash -c 'git add .'` | **FAILED** |
| 3 | `sh -c "git add ."` | **FAILED** |
| 4 | `env git add .` | **PASSED** |
| 5 | `pwsh -NoProfile -Command "Invoke-Pester ..."` | **PASSED** |
| 6 | heredoc body piped into `bash` | **PASSED** |
| 7 | `echo "$(git add .)"` | **FAILED** |

The three failures share one cause: the character immediately preceding `git` is a single quote, a
double quote, or an opening parenthesis, none of which satisfies the `(^|\s)` left anchor of the
current pattern.

Output Summary: **Fail-before recorded as required.** Non-zero exit code **14**, decomposing as 13
failures in this suite plus the 1 pre-existing baseline failure in
`codex-pretooluse-integration.Tests.ps1`. The suite reports 23 tests, **13 failed, 10 passed**.
Failing: 4 of 5 over-match allow cases, all 6 under-match deny cases, and 3 of 7 wrapper deny pins.
Passing: the stop case, 1 already-allowing over-match case, 4 of 7 wrapper deny pins, and all 4
`apply_patch` marker-leg assertions. The per-case result is identical to the Claude side recorded in
[P1-T5] on all 19 shared scenarios.
