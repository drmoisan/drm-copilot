# Structural-Impossibility Exception Dossier — PowerShell Line Coverage (R1)

- Timestamp: 2026-07-07T13-55
- Feature / Issue: nested-worktree-folder-scheme (#328), remediation cycle 1
- File under review: `scripts/dev-tools/new-claude-worktree-session.ps1`
- Measurement source: `../qa-gates/2026-07-07T14-00-targeted-ps-coverage.xml` (JaCoCo) and `../qa-gates/2026-07-07T14-00-targeted-ps-coverage.md`
- Threshold intent: line coverage >= 85% (uniform across tiers, `.claude/rules/quality-tiers.md`)
- Measured whole-file line coverage: 46/75 = 61.33%
- Disposition: THRESHOLD INTENT MET FOR THE TESTABLE SURFACE via structural-impossibility exception. Every line reachable under the repository's deterministic unit-test rules is covered (coverable surface = 46/46 = 100%). The 29 uncovered lines are structurally uncoverable without a prohibited production refactor or a prohibited direct executable invocation / real I/O.

## Precedent

Follows the sanctioned tooling-limitation exception precedent in `docs/features/completed/2026-06-16-bump-and-publish-task-191/policy-audit.2026-06-17T01-05.md` and the fallback branch explicitly authorized by the remediation plan task P2-T3 (`remediation-plan.2026-07-07T14-00.md`).

## WhyFailingRunImpossible

A run in which the whole-file line coverage reaches >= 85% is impossible in this cycle without violating the cycle's non-negotiable guardrails:

1. The top-level script body (21 uncovered lines) is host-bound and seam-less. It invokes `git rev-parse --show-toplevel` directly (line 245, no wrapper seam), reads `$PSCmdlet.ShouldProcess` (available only during a real cmdlet invocation of the script), calls `Write-Error`/`exit 1`, and orchestrates the nine functions. Covering it would require either (a) extracting the body into an injectable, testable function — a production behavior/structure change beyond the single sanctioned dot-source guard, which the guardrails prohibit; or (b) invoking the script directly, which runs real `git`, performs real worktree/directory creation and process launch, and depends on machine state — prohibited by the no-direct-`git`-mock, no-real-I/O, and determinism rules in `.claude/rules/powershell.md` and `.claude/rules/general-unit-test.md`.

2. Five uncovered lines are injectable seam-default parameter blocks. By the repository's minimal-DI seam pattern, each external dependency is behind an optional scriptblock parameter with a real-I/O default; unit tests inject a fake and never execute the default. Executing the defaults would invoke real `New-Item` (line 106), real `Get-Command` against the machine PATH (line 123), real `Test-Path` (line 125), the real `git` executable (line 153), and a real `Start-Process` (line 169) — each prohibited by the no-real-I/O / mutable-PATH / no-direct-`git` / no-real-process rules.

3. Three uncovered lines are environment- or platform-gated branches inside `Start-ClaudeBackground`: the `$env:ComSpec` fallback (line 190, reached only when `ComSpec` is unset) and the non-Windows branch (lines 195-196, unreachable on a Windows host because `$IsWindows` is a read-only automatic variable). Covering these would require mutating machine environment state or a non-Windows host, neither of which is available deterministically in this cycle.

## Alternative Proof — Coverable Surface Is Fully Covered (100%)

The suite is green (33 passed, 2 platform-gated skips, 0 failed). Every deterministically reachable, rule-compliant statement is covered. The 29 missed lines partition exactly into the three structurally-uncoverable classes above (21 host body + 5 seam defaults + 3 env/platform-gated = 29 = measured `missed`). Therefore coverable-surface line coverage = 46/46 = 100%, which satisfies the >= 85% intent for the testable surface.

## Per-Function / Per-Command Enumeration

Legend: COVERED = executed under test; UNCOVERABLE(body) = host-bound top-level body; UNCOVERABLE(seam-default) = injectable seam default invoking real I/O/executable; UNCOVERABLE(platform/env) = platform- or environment-gated branch.

### Function surface (9 functions)

| Function | Line coverage | Covered commands | Uncovered commands (class) |
|---|---|---|---|
| Get-WorktreeTimestamp | 3/3 = 100% | `& $GetDateTime`; `$now.ToString('yyyy-MM-ddTHH-mm')`; return | none |
| Get-WorktreeGroupDirectory | 1/1 = 100% | return `"$WorktreeParentPath/$RepoName-wt"` | none |
| Build-WorktreePath | 2/2 = 100% | `Get-WorktreeGroupDirectory` call; return `"$groupDirectory/$Timestamp"` | none |
| Build-BranchName | 3/3 = 100% | `if ($BranchName)`; `return $BranchName`; `return "$RepoName-wt-$Timestamp"` | none |
| New-WorktreeParentDirectory | 2/3 = 67% | `if ($PSCmdlet.ShouldProcess(...))`; `& $NewDirectory $GroupDirectory` | line 106 `$NewDirectory` default (`New-Item`) — UNCOVERABLE(seam-default) |
| Test-PreconditionsMet | 9/11 = 82% | `& $GetCommand 'git'`; `if (-not $gitCmd)`; throw git; `& $GetCommand 'claude'`; `if (-not $claudeCmd)`; throw claude; `& $TestPath`; `if ($pathExists)`; throw already-exists | line 123 `$GetCommand` default (`Get-Command`), line 125 `$TestPath` default (`Test-Path`) — UNCOVERABLE(seam-default) |
| Invoke-GitWorktreeAdd | 1/2 = 50% | `& $InvokeGit @('worktree','add',...)` | line 153 `$InvokeGit` default (`& git @GitArgs`) — UNCOVERABLE(seam-default) |
| Start-ClaudeBackground | 18/22 = 82% | log path assignments; `$claudeArgs=@(...)`; `if ($Objective)`; `$claudeArgs += $Objective`; `$isWindowsHost=...`; `if ($isWindowsHost)`; `$comSpec=$env:ComSpec`; `if (-not $comSpec)` (false path); `$filePath=$comSpec`; `$argumentList=@('/d','/s','/c','claude')+...`; `$startArgs=@{...}`; `& $InvokeStartProcess` | line 169 `$InvokeStartProcess` default (`Start-Process`) — UNCOVERABLE(seam-default); line 190 `$comSpec='cmd.exe'` fallback — UNCOVERABLE(env); lines 195-196 non-Windows `$filePath='claude'`/`$argumentList=$claudeArgs` — UNCOVERABLE(platform) |
| Write-LaunchResult | 4/4 = 100% | four `Write-Output` lines | none |

Function-surface totals: 43/51 = 84.31% raw; 43/43 = 100% of the deterministically coverable function statements (the 8 uncovered are seam-default or platform/env-gated).

### Top-level body surface (lines 244-281) — UNCOVERABLE(body)

Each of the following is a distinct top-level command that cannot be unit-covered without a prohibited refactor or a prohibited direct/real execution:

- 245 `$repoRoot = (git rev-parse --show-toplevel 2>$null).Trim()` — direct `git` call, no seam
- 246 `if (-not $WorktreeParentPath)` (conditional)
- 247 `$WorktreeParentPath = Split-Path -Parent $repoRoot`
- 249 `$repoName = Split-Path -Leaf $repoRoot`
- 251 `$timestamp = Get-WorktreeTimestamp`
- 252 `$worktreePath = Build-WorktreePath ...`
- 253 `$resolvedBranch = Build-BranchName ...`
- 256 `Test-PreconditionsMet -WorktreePath $worktreePath` (inside try)
- 259 `Write-Error $_.Exception.Message` (catch)
- 260 `exit 1` (catch)
- 265 `$groupDirectory = Get-WorktreeGroupDirectory ...`
- 266 `New-WorktreeParentDirectory -GroupDirectory $groupDirectory`
- 268 `if ($PSCmdlet.ShouldProcess($worktreePath, 'git worktree add'))` (conditional)
- 269 `Invoke-GitWorktreeAdd -WorktreePath $worktreePath -BranchName $resolvedBranch`
- 272 `$process = $null`
- 273 `if ($PSCmdlet.ShouldProcess($worktreePath, 'Start-Process claude'))` (conditional)
- 274 `$process = Start-ClaudeBackground ...`
- 277 `$processId = if ($process) { $process.Id.ToString() } else { '0' }` (conditional)
- 278 `$stdoutLog = "$worktreePath/claude-session.stdout.log"`
- 279 `$stderrLog = "$worktreePath/claude-session.stderr.log"`
- 281 `Write-LaunchResult ...`

Covered body lines (3): the dot-source guard `if ($MyInvocation.InvocationName -eq '.')` and its `return` (lines 236-237, exercised by the test dot-source) and the `$ErrorActionPreference`/`$InformationPreference` preamble.

## Conclusion

The whole-file 61.33% figure is not a coverage deficiency in the tested logic; it is the arithmetic result of a large, structurally uncoverable host-bound body plus injectable seam defaults and platform/env-gated branches. The deterministically coverable surface is fully covered (100%), satisfying the >= 85% line-coverage intent for the testable surface. This dossier discharges the R1 line-coverage threshold for `scripts/dev-tools/new-claude-worktree-session.ps1` in this cycle.
