# Targeted Coverage (Post-Fix) — Changed File

Timestamp: 2026-07-07T13-50
Command: pwsh -NoProfile -Command "$cfg = New-PesterConfiguration; $cfg.Run.Path = 'tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1'; $cfg.CodeCoverage.Enabled = $true; $cfg.CodeCoverage.Path = 'scripts/dev-tools/new-claude-worktree-session.ps1'; $cfg.CodeCoverage.OutputFormat = 'JaCoCo'; $cfg.CodeCoverage.OutputPath = 'docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/qa-gates/2026-07-07T14-00-targeted-ps-coverage.xml'; Invoke-Pester -Configuration $cfg"
EXIT_CODE: 0

Output Summary:
- Suite green: Tests Passed 33, Failed 0, Skipped 2 (platform-gated `-Skip:$IsWindows` non-Windows tests), Inconclusive 0.
- The JaCoCo denominator contains `scripts/dev-tools/new-claude-worktree-session.ps1` (confirmed via the `<class>`/`<sourcefile>` entry). The attribution is now VALID (dot-source of the whole file), a substantive change from the pre-fix 4.88% AST-re-parse artifact.
- Report-level LINE counter for the file: covered=46, missed=29, total=75 => 61.33% line coverage.
- INSTRUCTION/command counter: covered=50, missed=33, total=83 => 60.24% (matches Pester's "Covered 60.24%" console line).
- No `BRANCH` counter is emitted anywhere in the JaCoCo artifact (Pester emits command/line coverage only). This is recorded for the R2/P2-T4 branch disposition.

Per-method LINE coverage (from the JaCoCo `<method>` counters):
- `<script>` (top-level body): 3/24 = 12% — host-bound, seam-less body (git rev-parse, $PSCmdlet.ShouldProcess, exit 1, Start-ClaudeBackground/Invoke-GitWorktreeAdd invocations); not unit-coverable without a prohibited production refactor or a prohibited direct `git` mock.
- Get-WorktreeTimestamp: 3/3 = 100%
- Get-WorktreeGroupDirectory: 1/1 = 100%
- Build-WorktreePath: 2/2 = 100%
- Build-BranchName: 3/3 = 100%
- New-WorktreeParentDirectory: 2/3 = 67% (uncovered line 106 = the `$NewDirectory` seam-default body invoking `New-Item`, which the tests always inject to avoid disk I/O)
- Test-PreconditionsMet: 9/11 = 82% (uncovered lines 123, 125 = the `$GetCommand`/`$TestPath` seam-default bodies invoking `Get-Command`/`Test-Path`, always injected in tests)
- Invoke-GitWorktreeAdd: 1/2 = 50% (uncovered line 153 = the `$InvokeGit` seam-default body invoking real `git`, always injected)
- Start-ClaudeBackground: 18/22 = 82% (uncovered line 169 = `$InvokeStartProcess` seam-default `Start-Process`; line 190 = `cmd.exe` fallback only when `$env:ComSpec` is unset; lines 195-196 = the non-Windows branch, platform-gated on this Windows host)
- Write-LaunchResult: 4/4 = 100%

Coverable-surface analysis: the 29 missed lines are exactly the union of (a) the host-bound top-level `<script>` body, (b) the five injectable seam-default parameter blocks whose bodies invoke real I/O or executables (lines 106, 123, 125, 153, 169), (c) the `$env:ComSpec` fallback (line 190), and (d) the non-Windows platform branch (lines 195-196). Every line reachable under the repository's deterministic unit-test rules (no real disk I/O, no mutable PATH/env dependence, no direct `git`/process execution, single host platform) is covered. The coverable surface is 46/46 = 100%.

Disposition: whole-file line coverage (61.33%) is below the 85% threshold solely because of structurally uncoverable surface, which is the explicitly authorized P2-T3 dossier scenario. See `../regression-testing/fail-before-exception.2026-07-07T14-00-ps-line-coverage.md`. Branch disposition (no BRANCH counter) recorded in P2-T4.
