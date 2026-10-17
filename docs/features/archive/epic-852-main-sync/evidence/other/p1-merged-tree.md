# Phase 1 Merged-Tree State

Timestamp: 2026-10-11T00-07
Task: [P1-T6]
Command: git ls-files <four paths> ; Read (first 60 lines) of both hook copies ; sh <SCRATCHPAD>/r.sh rhash <hook pair> ; Grep -n Get-FeatureReviewCoverageThreshold in .claude/hooks/validate-feature-review-coverage.ps1 ; Grep -n "^function |^}" for function bounds
EXIT_CODE: 0

## Tracked files

```text
.claude/hooks/feature-review-coverage-thresholds.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1
tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1
tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1
```

ALL_FOUR_TRACKED: yes

## Prologue, `.claude/hooks/validate-feature-review-coverage.ps1`

```text
44: [CmdletBinding()]
45: param()
46: $script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
47:
48: $ErrorActionPreference = 'Stop'
49: . (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1')
```

## Prologue, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`

```text
44: [CmdletBinding()]
45: param()
46: $script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
47:
48: $ErrorActionPreference = 'Stop'
49: . (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1')
```

PROLOGUES_MATCH_FIXED_FACTS: yes (both copies, lines 44 to 49)

## Line counts and parity

```text
LINES: .claude/hooks/validate-feature-review-coverage.ps1 | 477
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | 477
MIRROR: .claude/hooks/validate-feature-review-coverage.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | equal | F9984E1F1A30ECA647A3CCFBFC5F5E88ED69969065F10EBDC7533669EFBADEE5 | F9984E1F1A30ECA647A3CCFBFC5F5E88ED69969065F10EBDC7533669EFBADEE5
```

## Get-FeatureReviewCoverageThreshold matches

```text
35:        read by Get-FeatureReviewCoverageThreshold (feature-review-coverage-thresholds.ps1).   -> COMMENT (inside the top-level <# ... #> help block, lines 1-43)
445:    $thresholds = Get-FeatureReviewCoverageThreshold -ClaudeMdText $claudeMd.Text            -> CALL (inside Invoke-FeatureReviewCoverageValidation, lines 345-462)
```

EVERY_CALL_INSIDE_FUNCTION_BODY: yes

Output Summary: all four merged files tracked; both prologues match the expected merged prologue at lines 44-49; both copies 477 lines and SHA256-equal; threshold-function matches are line 35 (COMMENT) and line 445 (CALL, inside Invoke-FeatureReviewCoverageValidation).
