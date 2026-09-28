# [P13-T7] Pass-after run of the acceptance-case suite

Timestamp: 2026-09-07T17-20

Mandated command (attempted first, refused by the runtime worktree-isolation guard):
`pwsh -NoProfile -Command "Invoke-Pester -Path 'tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1'"`

Command:

```
mcp__drm-copilot__run_poshqc_test    # workspace_root: the worktree root, scan_folders: ["tests/scripts/claude-hooks"]
# suite result read from artifacts/pester/pester-junit.xml
```

EXIT_CODE: 1

The exit code belongs to the folder-scoped invocation, not to the target suite. The folder contains
one ambient-state failure in a different file, named below.
`hook-command-parser.AcceptanceCases.Tests.ps1` itself reports **0 failures**.

TOOLCHAIN_SUBSTITUTION: `pwsh` is not invocable anywhere in this session, so `Invoke-Pester` could
not be called against a single file path. The MCP PoshQC test runner accepts a folder scope rather
than a file path, so the suite was run inside the smallest scope that contains it,
`tests/scripts/claude-hooks`, and the per-suite result was read from the emitted
`artifacts/pester/pester-junit.xml` by matching the `testsuite` element whose `name` ends with
`hook-command-parser.AcceptanceCases.Tests.ps1`. That element carries its own `tests`, `errors`, and
`failures` attributes, so the suite's result is isolated from the rest of the folder.

## Suite result

`testsuite` element attributes, verbatim from the report:

```
name="...\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1" tests="11" errors="0" failures="0" skipped="0" disabled="0" time="0.364"
```

| Measure | Value |
|---|---|
| Tests | 11 |
| Errors | 0 |
| **Failures** | **0** |
| Skipped | 0 |
| Wall time | 0.364 s |

**Zero failed tests.** The same suite reported 11 tests and 0 failures in the [P13-T3] whole-suite
run 9 minutes earlier, so the result is reproduced across two independent invocations at two
different scopes.

## AT-1 through AT-7, each passing by name

| ID | Case name | Observed |
|---|---|---|
| AT-1 | `AT-1 denies a relocating git worktree remove against an epic checkpoint with no authorizing record` | **Passed** |
| AT-2 | `AT-2 returns 688 for a cd-prefixed gh pr merge whose PR number follows the merge flag` | **Passed** |
| AT-3 | `AT-3 allows a heredoc whose JSON body names promotion tools as receipt values` | **Passed** |
| AT-4 | `AT-4 allows a printf whose double-quoted text mentions the gated merge phrase` | **Passed** |
| AT-5 | `AT-5 blocks a relocating gh issue create spelling that carries a repo global option` | **Passed** |
| AT-6 | `AT-6 still classifies a pwsh -Command wrapper carrying a test invocation` | **Passed** |
| AT-7 | `AT-7 resolves the worktree path when the force flag precedes it, in both removal gates` | **Passed** |

Each case sits under its own `Context` in the suite: `AT-1 - the mandatory latent-bypass case`,
`AT-2 - the issue #591 operand mis-parse`, `AT-3 - the promotion-hook over-match on receipt values`,
`AT-4 - the merge-gate over-match on quoted prose`, `AT-5 - the promotion-hook gh relocation bypass`,
`AT-6 - the wrapper deny pin`, and `AT-7 - the cross-runtime operand divergence`, all inside the
`Describe` named `hook-command-parser acceptance cases (issue #545)`.

## The four paired negatives, each passing by name

All four sit under the `Context` named
`paired negatives that must hold alongside the acceptance cases`.

| # | Case name | Observed |
|---|---|---|
| 1 | `paired negative for AT-2: a bare gh pr merge --merge with no number still returns $null` | **Passed** |
| 2 | `paired negative for AT-2: the number-before-flag form gh pr merge 410 --merge still returns 410` | **Passed** |
| 3 | `paired negative for AT-3: a genuine promotion-script invocation still returns its blocked reason` | **Passed** |
| 4 | `paired negative for AT-5: a relocating gh issue list spelling still returns $null` | **Passed** |

7 acceptance cases + 4 paired negatives = 11 cases, matching the suite's `tests="11"` attribute
exactly, so no case in the file is unaccounted for.

The paired negatives are what make the seven acceptance cases meaningful. AT-2 asserts a specific
operand is now returned; without negatives 1 and 2 the same result would follow from a parser that
returned an operand unconditionally. AT-3 and AT-5 assert an over-match is now allowed; without
negatives 3 and 4 the same result would follow from a hook that stopped denying anything.

## The folder-scoped run's one failure, which is not in this suite

- Suite file: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- It: `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`

This is baseline failure 1 from [P0-T7]. The case does not mock `Get-PrAuthorCheckpointContent`, so
it reads this run's real orchestrator-state checkpoint, which carries `epic_mode: true` while the
fixture command carries no `--base`; the hook denies correctly on that state. It is in a different
file, it is recorded in the [P0-T7] baseline as failing before any task in this plan ran, and it is
green on the clean CI checkout (run `34145103168`). It is the sole reason the folder-scoped
invocation exits 1.

## Output Summary

`tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`: **11 tests, 0 failures,
0 errors, 0 skipped**, 0.364 s. AT-1 through AT-7 each pass by name, and all four paired negatives
pass by name. The folder-scoped invocation exits 1 solely because of one ambient-state failure in
`enforce-pr-author-skill.Tests.ps1`, which is a [P0-T7] baseline failure in a different file and is
green on CI.
