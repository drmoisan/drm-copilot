# Remediation Cycle 1 Existing-Row Backslash Scan ([P0-T5])

Timestamp: 2026-09-25T21-11
Command: sh <SCRATCHPAD>/rem1/runout.sh p0-scan  (over the 16 S-GATE files: Select-String -SimpleMatch -Pattern '\"'; Select-String -SimpleMatch -Pattern "\'"; Select-String -Pattern '"[^"\r\n]*\\[^"\r\n]*"')
EXIT_CODE: 0
Output Summary: S-GATE list resolved to 16 entries. List 1: 0 matches. List 2: 9 matches (2 comments, 2 idiom deny rows, 5 file-path-leg constructions). List 3: 3 matches (assertion regexes). All three lists equal the plan's expected sets.

## Match Lists

- List 1 (`\"`, simple match): empty.
- List 2 (`\'`, simple match): nine matches, listed in the output below.
- List 3 (double-quoted span containing a backslash, regex): three matches, listed in the output below.

## Classification

| Match | List | Classification |
| --- | --- | --- |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:435 | 2 | comment |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:450 | 2 | idiom deny row (D4 `'\''`) |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:442 | 2 | comment |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:457 | 2 | idiom deny row (D4 `'\''`) |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:280 | 2 | file-path-leg construction |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1:64 | 2 | file-path-leg construction |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1:89 | 2 | file-path-leg construction |
| tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1:60 | 2 | file-path-leg construction |
| tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1:83 | 2 | file-path-leg construction |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:414 | 3 | assertion regex |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:421 | 3 | assertion regex |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:428 | 3 | assertion regex |

Result: the three lists equal the plan's expected sets. No accepted (allow) command row carries a backslash before a quote character or inside a double-quoted span, so the section 2.1 rule leaves existing allow rows unaffected; the only `\'` in a command literal is the D4 idiom deny row, which stays denied.

## Scan Output

```
S-GATE resolved entries: 16
Resolved S-GATE list:
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
  tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
  tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
  tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
  tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
  tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
  tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1

## List 1: Select-String -SimpleMatch -Pattern '\"'
Matches: 0

## List 2: Select-String -SimpleMatch -Pattern "\'"
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1:64: Path     = $WindowsBackslashPrefix + '\' + ($literal -replace '/', '\')
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1:89: Path     = $WindowsBackslashPrefix + '\' + ($DocumentationArtifact -replace '/', '\')
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:435: # `$` and backtick stay unresolvable in any quote state, the single-quoted `'\''`
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:450: @{ Label = 'the single-quoted apostrophe idiom'; Command = 'git commit -m ''it''\''''s done <noreply@anthropic.com>'' -- docs/features/epics/2026-08-24-sample-epic/epic-status.md' }
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:280: $backslashPath = $literal.Replace('/', '\')
tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1:60: Path     = $WindowsBackslashPrefix + '\' + ($literal -replace '/', '\')
tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1:83: Path     = $WindowsBackslashPrefix + '\' + ($DocumentationArtifact -replace '/', '\')
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:442: # unresolvable in any quote state, the single-quoted `'\''` apostrophe idiom stays
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:457: @{ Label = 'the single-quoted apostrophe idiom'; Command = 'git commit -m ''it''\''''s done <noreply@anthropic.com>'' -- docs/features/epics/2026-08-24-sample-epic/epic-status.md' }
Matches: 9

## List 3: Select-String -Pattern '"[^"\r\n]*\\[^"\r\n]*"'
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:414: $emitted[0] | Should -Match '"permissionDecision"\s*:\s*"deny"'
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:421: $emitted[0] | Should -Match '"permissionDecision"\s*:\s*"allow"'
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:428: $emitted[0] | Should -Match '"permissionDecision"\s*:\s*"deny"'
Matches: 3
PROCESS_EXIT_CODE: 0
```
