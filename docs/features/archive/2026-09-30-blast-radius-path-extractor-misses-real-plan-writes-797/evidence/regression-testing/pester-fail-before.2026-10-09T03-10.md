# Pester Fail-Before (P1-T10, expect-fail)

Timestamp: 2026-10-09T03-10
Command: mcp__drm-copilot__run_poshqc_test scan_folders ["tests/scripts/claude-lib/blast-radius"]; then poetry run python (ElementTree) over the run's JUnit output artifacts/pester/pester-junit.xml, selecting the testsuites BlastRadiusTokenShape.Tests.ps1 and BlastRadiusExtraction.Path.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: substitute evidence. MCP result ok:false ("Command exited with code 10."). Within the two P1-T10 files: Passed=91 Failed=9 (TokenShape 39 tests, 8 failures; Path 61 tests, 1 failure). The nine failed names are exactly the seven `classifies the file-shaped token ... as concrete` expansions, `classifies the dotted-directory residual as concrete`, and `accepts a token outside the known segments with an unlisted letter-led extension`. No `still rejects the non-file token` expansion failed. Folder-wide the run had 636 tests and 10 failures; the tenth is the parity case `reproduces the expected radius for derivation-file-shaped-tokens`, the new shared fixture, which is also expected to fail before the fix.

## Deviation (PowerShell route denied)

The plan's `Invoke-Pester -Path <two files> -PassThru` needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md). The PoshQC MCP test tool ran Pester over the folder containing both files; the counts and names above are read from the JUnit file that run wrote, not from the MCP return value.

## Failed names (Pester ExpandedName path)

```text
Get-PathTokenKind.Extension fallback rule.accepts a token outside the known segments with an unlisted letter-led extension
File-shaped token classification (issue #797).Tokens whose final component names a file.classifies the file-shaped token tests/shell/foo.bats as concrete
File-shaped token classification (issue #797).Tokens whose final component names a file.classifies the file-shaped token extensions/drm-copilot/jest.config.cjs as concrete
File-shaped token classification (issue #797).Tokens whose final component names a file.classifies the file-shaped token tests/out/run.out as concrete
File-shaped token classification (issue #797).Tokens whose final component names a file.classifies the file-shaped token .agents/skills/x/refs/foo.bats as concrete
File-shaped token classification (issue #797).Tokens whose final component names a file.classifies the file-shaped token .claude/lib/x/.shellcheckrc as concrete
File-shaped token classification (issue #797).Tokens whose final component names a file.classifies the file-shaped token .devcontainer/codespaces/Dockerfile as concrete
File-shaped token classification (issue #797).Tokens whose final component names a file.classifies the file-shaped token tests/shell/parallel_lane_assertion.bats:12 as concrete
File-shaped token classification (issue #797).Documented fail-closed residual.classifies the dotted-directory residual as concrete
(outside the two files) Blast-radius derivation and validation parity.Derived radius.reproduces the expected radius for derivation-file-shaped-tokens
```
