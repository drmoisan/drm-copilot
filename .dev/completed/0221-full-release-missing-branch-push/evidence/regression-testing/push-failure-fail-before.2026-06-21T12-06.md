# Fail-Before Evidence — Push-Failure Negative-Path Test

- Timestamp: 2026-06-21T12-06
- Issue: #221
- Task: [P1-T1] [expect-fail]

## Command

```
Invoke-Pester -Configuration (
  Run.Path = tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1;
  Filter.FullName = "*git push -u origin*fails*"
)
```

- EXIT_CODE: 1 (1 test failed, as expected before the production fix)

## Test Added

`It "returns 1 and does not open a PR when 'git push -u origin <branch>' fails"` in the
"git/npm/gh seam failures" context. Mocks:
- `Invoke-GitExe` returns ExitCode 1 for `push ...` args, ExitCode 0 for all other git args.
- `Invoke-NpmExe` returns 0.
- `Invoke-GhExe` throws "gh wrapper should not be invoked" if called.

Assertions: result is `1`; `$script:capturedMessage` matches "Failed to push release branch";
`Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly`.

## Output Summary

RESULT_TOTAL=1 PASSED=0 FAILED=1.

The test fails before the production change because `Invoke-FullReleaseGuarded` has no push step:
control flows directly from the commit block to `gh pr create`, invoking `Invoke-GhExe`, which
the mock makes throw ("gh wrapper should not be invoked"). The failure confirms the missing
branch-push behavior described in spec.md and is the expected fail-before state for this
`[expect-fail]` task.
