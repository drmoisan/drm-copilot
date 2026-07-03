## MCP Settings Root-Cause Confirmation — Remediation Cycle 1 (Issue #272)

**Timestamp:** 2026-07-02T20-38
**Command:** `grep -n "enforce-pr-author-skill" <each discovered path>` plus `stat` mtime comparison.
**EXIT_CODE:** 0
**Output Summary:**

Of the 4 non-repo `pester.runsettings.psd1` copies discovered in P1-T1:
- `danmoisan.drm-copilot-0.0.2\...\pester.runsettings.psd1` — `CodeCoverage.Path` **omits** `.claude/hooks/enforce-pr-author-skill.ps1` (5-entry list, no `ExcludedPath` mention either).
- `danmoisan.drm-copilot-0.0.6\...\pester.runsettings.psd1` — `CodeCoverage.Path` **includes** `.claude/hooks/enforce-pr-author-skill.ps1` (added at line 31, with an Issue #272-referencing comment).
- `danmoisan.drm-copilot-1.0.2\...\pester.runsettings.psd1` — `CodeCoverage.Path` **omits** it.
- `undefined_publisher.drm-copilot-0.0.1\...\pester.runsettings.psd1` — `CodeCoverage.Path` **omits** it.

Per `extensions.json` (`.vscode-server-insiders`), the currently-active installed extension is `danmoisan.drm-copilot` version `0.0.6` — the one copy that DOES already include the hook file in its `CodeCoverage.Path`.

**mtime comparison:**
- Active extension's settings file (`danmoisan.drm-copilot-0.0.6\...\pester.runsettings.psd1`): `2026-07-02 18:36:10`
- Repo-tracked settings file (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`): `2026-07-02 18:32:16`
- Canonical coverage artifact (`artifacts/pester/powershell-coverage.xml`): `2026-07-02 19:13:52` (generated AFTER both settings edits above)

**Interpretation:** The active installed extension's on-disk settings file already contained the correct `CodeCoverage.Path` entry roughly 37 minutes before the stale coverage artifact was generated. This indicates the MCP tool's stale-behavior root cause is not a simple "on-disk file omits the entry" condition for the currently-active extension version — it is more consistent with the MCP server process caching Pester settings/module state in memory from an earlier session and not re-reading the file on each invocation within that session (matching prior session feedback recorded in agent memory `feedback_poshqc_coverage_tool_config.md`). This corroborates, with refinement, the root cause in `remediation/2026-07-02T20-15/remediation-inputs.md` item 1: the practical fix remains bypassing the MCP wrapper for this regeneration, per P1-T5's selected approach, rather than editing the already-correct on-disk extension copy.
