# CodeCoverage.Path Bundled-Mirror Scope Decision

Timestamp: 2026-07-04T12-00

Decision: Do NOT add the following bundled-resource mirror files to `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`:
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1`

Rationale: These two files are byte-identical mirrors of the canonical `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` files, which are being added to `CodeCoverage.Path` in this remediation cycle (P1-T2). Measuring both the canonical files and their byte-identical bundled mirrors would double-count identical code without producing any new coverage signal, since the Pester test suites in `tests/scripts/claude-hooks/` exercise the canonical `.codex/hooks/` paths, not the bundled mirror paths. Adding the mirrors to `CodeCoverage.Path` would not increase measured coverage (no test exercises those mirror paths) and would only inflate the array with entries that report 0% coverage, which does not serve the remediation goal of closing the coverage-measurement gap for the four in-scope hook files.

Output Summary: Scope decision recorded — the two bundled-resource mirror files are explicitly excluded from `CodeCoverage.Path` in this remediation cycle. Only the four canonical in-scope hook files (`.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`) are added in P1-T2.
