# Baseline — Pre-Fix Targeted Coverage of Changed File (Attribution Artifact)

Timestamp: 2026-07-07T13-45
Command: pwsh -NoProfile -Command "$cfg = New-PesterConfiguration; $cfg.Run.Path = 'tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1'; $cfg.CodeCoverage.Enabled = $true; $cfg.CodeCoverage.Path = 'scripts/dev-tools/new-claude-worktree-session.ps1'; $cfg.CodeCoverage.OutputFormat = 'JaCoCo'; $cfg.CodeCoverage.OutputPath = 'docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/remediation-baseline/2026-07-07T14-00-baseline-targeted-ps-coverage.xml'; Invoke-Pester -Configuration $cfg"
EXIT_CODE: 0

Output Summary:
- Discovery found 33 tests; Tests Passed: 31, Failed: 0, Skipped: 2 (platform-gated), Inconclusive: 0.
- Pester reported: "Covered 4.88% / 75%. 82 analyzed Commands in 1 File." for `scripts/dev-tools/new-claude-worktree-session.ps1`.
- This 4.88% figure is an ATTRIBUTION ARTIFACT, NOT a valid coverage result. Root cause (R1): the test suite resolves functions via `Import-ScriptFunction` (`tests/scripts/powershell/Support/TestHelpers.ps1`), which extracts each function's AST `Extent.Text` and re-parses it with `Parser::ParseInput`. Re-parsing restarts line numbers at 1, so the commands executed under test do not map to the original file's line numbers where Pester set coverage breakpoints. The executed commands therefore do not attribute to the file's real lines, producing an artificially low percentage.
- Interpretation: the tests do exercise the functions (31 passing), but coverage attribution is broken by the AST re-parse seam. The direct fix (Phase 1) replaces per-function `Import-ScriptFunction` resolution with dot-sourcing the whole file (guarded so the top-level body does not execute during tests), restoring valid line-number attribution.
- This artifact is the pre-fix reference figure only.
