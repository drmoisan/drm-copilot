# CodeCoverage.Path Bundled-Mirror Scope Decision

Timestamp: 2026-07-04T12-00

Decision: Do NOT add the following bundled-resource mirror files to `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`:
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1`

Rationale: These two files are byte-identical mirrors of the canonical `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` files, which are being added to `CodeCoverage.Path` in this remediation cycle (P1-T2). Measuring both the canonical files and their byte-identical bundled mirrors would double-count identical code without producing any new coverage signal, since the Pester test suites in `tests/scripts/claude-hooks/` exercise the canonical `.codex/hooks/` paths, not the bundled mirror paths. Adding the mirrors to `CodeCoverage.Path` would not increase measured coverage (no test exercises those mirror paths) and would only inflate the array with entries that report 0% coverage, which does not serve the remediation goal of closing the coverage-measurement gap for the four in-scope hook files.

Output Summary: Scope decision recorded — the two bundled-resource mirror files are explicitly excluded from `CodeCoverage.Path` in this remediation cycle. Only the four canonical in-scope hook files (`.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`) are added in P1-T2.

## Correction (Appended 2026-07-04T13-15, Remediation Cycle 2, P4-T1)

**Do not edit the original text above — this is an append-only correction.**

The original rationale sentence above states: "the Pester test suites in `tests/scripts/claude-hooks/` exercise the canonical `.codex/hooks/` paths, not the bundled mirror paths." This was reversed from fact at the time it was written (2026-07-04T12-00). The correct fact, prior to this cycle's Phase 1 retargeting: `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` dot-sourced the **bundled-mirror path** (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`), not the canonical `.codex/hooks/` path. This meant the canonical `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` files — which had just been added to `CodeCoverage.Path` in that same cycle-1 commit — showed 0.00% real coverage, because no test in the repository dot-sourced their exact file path.

This discrepancy was independently identified in cycle 1's own follow-up evidence (`feature-audit.2026-07-04T12-00.md`) and re-confirmed independently in `code-review.2026-07-04T13-00.md`, both of which are the artifacts that surfaced this remediation cycle's Fix 1 (retarget `$script:UnderTest` in `enforce-completion-consistency-codex.Tests.ps1` to the canonical `.codex/hooks/enforce-completion-consistency.ps1` path). This cycle's Phase 1 fix (see `remediation-plan.2026-07-04T13-15.md`, P1-T2 through P1-T5) corrected the dot-source target, closing the coverage-measurement gap this reversed sentence had misdescribed. The scope decision itself (excluding the bundled-mirror files from `CodeCoverage.Path` to avoid double-counting byte-identical code) remains valid and unchanged; only the rationale sentence's factual direction is corrected here.
