# Synthetic-Path-Constant Audit for the Two New Suites (issue #516)

Timestamp: 2026-08-24T15-52
Command: `Get-Content | .Count` for the line counts, and `Select-String -SimpleMatch` for each of the five audited tokens (`Resolve-Path`, `PSScriptRoot`, `Get-Location`, `PWD`, and the source-control executable name), over both new suites
EXIT_CODE: 0

This audit was taken twice. The first pass (15:41) audited the suites as originally authored; the second and authoritative pass (15:52) audited them after the two case-sensitivity cases in each suite were converted to `-ForEach` data-bound cases. The conversion changed line counts and the line number of the hook-locating line but changed no audited verdict: every count below is identical in both passes. The figures recorded here are the second pass.

## Raw Result

```text
FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 lines=223
  Resolve-Path: count=1 lines=141
  PSScriptRoot: count=1 lines=141
  Get-Location: count=0 lines=none
  PWD: count=0 lines=none
  git: count=0 lines=none
FILE: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 lines=242
  Resolve-Path: count=1 lines=132
  PSScriptRoot: count=1 lines=132
  Get-Location: count=0 lines=none
  PWD: count=0 lines=none
  git: count=0 lines=none
```

## Line Counts Against the 500-Line Cap

| Suite | Lines | Cap | Headroom |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 223 | 500 | 277 |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | 242 | 500 | 258 |

Both suites are well under the 500-line cap in `.claude/rules/general-code-change.md`. Table-driven `It` blocks with `-ForEach` hold the full matrix within the cap.

## Per-Token Occurrence Audit

| Token | Claude suite | Codex suite | Required | Verdict |
| --- | --- | --- | --- | --- |
| `Resolve-Path` | 1 occurrence, line 141 | 1 occurrence, line 132 | exactly 1 per suite, on the hook-locating line | PASS |
| `PSScriptRoot` | 1 occurrence, line 141 | 1 occurrence, line 132 | exactly 1 per suite, on the hook-locating line | PASS |
| `Get-Location` | 0 | 0 | 0 | PASS |
| `PWD` | 0 | 0 | 0 | PASS |
| source-control executable name | 0 | 0 | 0 | PASS |

## The Single Permitted Occurrence Is Not Test-Path Construction

In each suite the sole `Resolve-Path` occurrence and the sole `PSScriptRoot` occurrence sit on the **same single line**, inside `BeforeAll`, and that line does nothing but locate the hook file under test for dot-sourcing. This is the exempt line named in the plan's Standing Constraints and it follows the pattern already used at line 6 of `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`.

- Claude suite, line 141: `$script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path`
- Codex suite, line 132: `$script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-orchestration-preimplementation-gate.ps1").Path`

Neither line constructs a path that any test case asserts against. Both resolve only the file to dot-source.

## Every Synthetic Absolute Prefix Is a Bare String Literal

Three prefix constants are declared per suite, each on a line containing none of the five audited tokens:

```powershell
$WindowsForwardPrefix   = 'C:/synthetic-drive-root/synthetic-checkout'
$PosixAbsolutePrefix    = '/synthetic-posix-root/synthetic-checkout'
$WindowsBackslashPrefix = 'C:\synthetic-drive-root\synthetic-checkout'
```

Every absolute path asserted by either suite is one of these three literals joined to a repo-relative literal. No value is read from the environment, the working directory, the script location, or a source-control query, so both suites are independent of checkout location, operating system, and linked-worktree layout.

Output Summary: Both new suites pass the synthetic-path-constant audit. Line counts are 223 (Claude) and 242 (Codex), both under the 500-line cap. `Resolve-Path` occurs exactly once per suite and `PSScriptRoot` occurs exactly once per suite, together on the single `BeforeAll` hook-locating line (line 141 Claude, line 132 Codex), which is the permitted exemption and is not test-path construction. `Get-Location`, `PWD`, and the source-control executable name each occur zero times in both suites. All three synthetic absolute prefixes in each suite are bare string literals.
