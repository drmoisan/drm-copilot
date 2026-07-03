## Coverage Fix Approach Decision — Remediation Cycle 1 (Issue #272)

**Timestamp:** 2026-07-02T20-41

**Selected approach:** Regenerate the canonical coverage artifact by importing the repo-tracked PoshQC module directly (`Import-Module ./scripts/powershell/PoshQC -Force`) and invoking `Invoke-PoshQCTest -Root '.' -ScanFolders @('tests/scripts/claude-hooks')` — bypassing the `mcp__drm-copilot__run_poshqc_test` MCP wrapper's stale bundled settings entirely, per `remediation-inputs.2026-07-02T20-15.md` item 1(b)'s third option.

**Rationale:**
- P1-T4 confirmed the repo-tracked module import resolves `PoshQC.psm1` under the repository tree, which in turn resolves `$script:PesterSettings` to the repo-tracked `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (confirmed correct and current in P1-T3).
- P1-T2 found that even the currently-active installed extension copy (`danmoisan.drm-copilot-0.0.6`) already has the correct `CodeCoverage.Path` entry on disk, predating the stale coverage artifact's generation timestamp — indicating the MCP wrapper's staleness is more consistent with in-memory/session-level caching than a simple on-disk configuration gap. Editing an already-correct on-disk extension copy would not reliably fix this within the same session.
- Attempting to locate and edit the external extension's installed settings copy is non-reproducible (the exact installed extension version and its file layout are environment-specific, not repository version-controlled) and would not persist as a durable fix for future sessions or other developers.
- Direct module import + `Invoke-PoshQCTest` invocation uses the same underlying Pester v5.x engine and the same repo-tracked settings file that `mcp__drm-copilot__run_poshqc_test` is intended to use, so this is not a policy-violating substitute — it is the documented fallback already used in this feature's own baseline/final evidence (`evidence/baseline/poshqc-test-baseline.md` Infrastructure Note).

**Not selected:** Editing the non-repo-tracked installed extension copies at `.vscode-server-insiders`/`.vscode-insiders` — rejected as non-reproducible and outside repository version control.
