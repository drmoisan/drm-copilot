# [P12-T6] No-Python scan

Timestamp: 2026-09-07T15-58

Command:

```
mcp__drm-copilot__run_poshqc_test
  workspace_root = C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31
  scan_folders   = ["tests/scripts/claude-runtime"]
```

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context, so `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` could not
be run through `Invoke-Pester -Path <suite>`. It was run through
`mcp__drm-copilot__run_poshqc_test` scoped by `scan_folders` to `tests/scripts/claude-runtime`, and
the per-suite and per-case results below were read from `artifacts/pester/pester-junit.xml`.

## Output Summary

`enforcement-hooks-no-python-invocation.Tests.ps1` reports **27 tests, 0 failures, 0 errors**. The
folder-wide run over `tests/scripts/claude-runtime` reports **64 tests, 0 failures, 0 errors** across
5 suites, so the runner's exit code of 0 is attributable to the whole folder and not only to the
suite this task gates on.

| Suite in the scanned folder | Tests | Failures | Errors |
| --- | --- | --- | --- |
| `claude-architecture-doc.Tests.ps1` | 6 | 0 | 0 |
| `claude-runtime-structure.Tests.ps1` | 6 | 0 | 0 |
| `claude-settings.Tests.ps1` | 5 | 0 | 0 |
| **`enforcement-hooks-no-python-invocation.Tests.ps1`** | **27** | **0** | **0** |
| `legacy-discovery-agent-roles.Tests.ps1` | 15 | 0 | 0 |
| `test-name-uniqueness.Tests.ps1` | 5 | 0 | 0 |
| **Folder total** | **64** | **0** | **0** |

## Statement 1 — the two new helper files are inside this suite's scan set

The suite's scan set is defined at lines 39 to 42 of the suite file as two roots:

```powershell
    $script:ScanRoot = @(
        (Join-Path -Path $script:RepoRoot -ChildPath '.claude/hooks'),
        (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib')
    )
```

`Get-GuardedPowerShellFile` then enumerates each root with:

```powershell
            $files = Get-ChildItem -Path $root -Recurse -File |
                Where-Object { $_.Extension -in @('.ps1', '.psm1') }
```

The walk is `-Recurse` over `.claude/hooks` and admits every `.ps1` beneath it. The only exclusion
applied afterwards is `.claude/lib/bash/*`, which is the shell subtree and does not affect
`.claude/hooks`. The two helper files this change adds are:

- `.claude/hooks/hook-command-scanner.ps1`
- `.claude/hooks/hook-command-invocation.ps1`

Both are `*.ps1` files directly beneath `.claude/hooks`, so both are enumerated by that walk without
any registration step. This is why the plan's standing constraints record that the suite "can absorb
nothing" in the way of new cases and that "the new helpers are covered by its directory walk over
`.claude/hooks` automatically": no edit to the suite was needed or made, and the suite file is not in
the [P12-T1] enumeration.

Supporting observation: the suite's own case
`enumerates only the two guarded roots and never the bundled mirror` passed, which establishes that
the enumeration it performs is the enumeration described above rather than a wider or narrower one.
The case `reports no Python invocation beyond the allowlist across the guarded tree` passed, which is
the scan result over that enumeration and therefore covers the two new helper files. The case
`carries no stale allowlist entry` passed and the case `ships an empty allowlist` passed, so no file
in the guarded tree is exempted from the scan by an allowlist entry.

## Statement 2 — no `.py` production file was added or modified

Derived from the [P12-T1] enumeration at
`evidence/qa-gates/scope-and-size.2026-09-07T15-46.md`, which is the union of

```
git diff origin/epic/cleanup-merged-worktrees-hardening-integration --name-status
git status --porcelain
```

and holds 137 paths. That union was scanned for any path whose extension is `.py`. The scan returned
**0 paths**, covering added, modified, and untracked files alike, because the porcelain companion
makes newly created files visible to the scan that the name-listing diff alone cannot report.

There is therefore no Python production file in this change, no Python changed-code denominator, and
no Python coverage gate with a subject here. The Python obligation for this change is that the three
existing pytest modules pass, which is recorded by [P12-T5] and by the Phase 10 batch-B19 artifact.

## All 27 case results

| Context | Case | Result |
| --- | --- | --- |
| allowlist policy | ships an empty allowlist | Passed |
| detection class 1 | detects a bare python invocation | Passed |
| detection class 1 | detects an ampersand-invoked python invocation | Passed |
| detection class 1 | detects a dot-invoked python invocation | Passed |
| detection class 1 | detects a quoted python constant invocation | Passed |
| detection class 1 | detects python3, py, and poetry as interpreter commands | Passed |
| detection class 1 | detects an interpreter name written in mixed case | Passed |
| detection class 2 | detects a subprocess start whose FilePath is an interpreter | Passed |
| detection class 2 | detects a subprocess start whose first positional argument is an interpreter | Passed |
| detection class 2 | reports no finding for a subprocess start targeting an unrelated executable | Passed |
| detection class 3 | detects an ampersand-invoked variable that is not a scriptblock parameter | Passed |
| detection class 3 | detects an ampersand-invoked expression in the command position | Passed |
| detection class 4 | detects an Invoke-Expression call | Passed |
| detection class 4 | detects the built-in alias of Invoke-Expression | Passed |
| non-detection | reports no finding for interpreter names inside string literals | Passed |
| non-detection | reports no finding for interpreter names inside comments | Passed |
| non-detection | reports no finding for function names beginning with Invoke-Python | Passed |
| non-detection | reports no finding for a scriptblock-parameter seam invocation | Passed |
| non-detection | reports no finding when a seam variable differs from its parameter by letter case | Passed |
| non-detection | reports no finding for dot-sourcing a sibling helper path variable | Passed |
| non-detection | reports no finding for dot-sourcing an inline sibling helper path | Passed |
| carve-out boundaries | still reports a dot-sourced expression that is not a Join-Path call | Passed |
| carve-out boundaries | still reports a Join-Path load that does not resolve a ps1 sibling | Passed |
| carve-out boundaries | still reports an ampersand-invoked inline sibling-load expression | Passed |
| repository scan | enumerates only the two guarded roots and never the bundled mirror | Passed |
| repository scan | reports no Python invocation beyond the allowlist across the guarded tree | Passed |
| repository scan | carries no stale allowlist entry | Passed |

The two `non-detection` cases naming dot-sourced sibling helper paths are directly relevant to this
change: the nine rewired hooks consume the parser through
`. (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')` and
`. (Join-Path $PSScriptRoot 'hook-command-invocation.ps1')`, and those two passing cases establish
that the dot-source idiom this change introduces is not reported as a dynamic invocation, while the
three `carve-out boundaries` cases establish that the exemption stays narrow enough to keep reporting
the forms it is meant to report.
