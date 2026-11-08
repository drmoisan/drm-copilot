# [P1-T5] Pester gate: DocsYamlKeys (issue #1022)

Timestamp: 2026-11-03T23-33
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsYamlKeys.Tests.ps1 -CoverageFile .claude/lib/docs/DocsYamlKeys.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsYamlKeys.Tests.ps1: 21 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=21 Failed=0 Skipped=0). .claude/lib/docs/DocsYamlKeys.psm1: 151 of 152 analyzed lines executed (99.34%). The JUnit file is well-formed; counts were read from it.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsYamlKeys.psm1` and `tests/scripts/claude-lib/docs/DocsYamlKeys.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings.
- Physical line counts: `DocsYamlKeys.psm1` 279; `DocsYamlKeys.Tests.ps1` 186.

## Behavior covered

- Classified constructs: block mappings, nested mappings, block sequences with scalar and mapping items (segment `[]`, sibling keys inside an item), plain, single-quoted and escape-free double-quoted keys, comments (top, trailing, between keys), `---` before the first content line (with and without a comment) and a final `...`, single-line scalars (string, integer, number, boolean, null), plain multi-line continuation lines, block scalars `|` and `>-` with blank lines inside, single-line flow collections and the empty flow mapping; spans run from the key line through the last non-blank, non-comment line of the value block; marker values never appear in the output (JSON serialization of the result contains no marker); `App` and `app` stay distinct.
- Diagnostics with code, severity, blocking flag, line and effect: `YAML_INVALID` (tab indentation, dedent to an unknown column, unterminated quoted scalar, continuation line containing a mapping separator; blocking, no keys), `YAML_MULTI_DOCUMENT` (second `---` after content, content after `...`), `YAML_ANCHOR_ALIAS` (anchor, alias, merge key), `YAML_UNSUPPORTED` (tag, complex key, directive, flow collection spanning lines), `YAML_ROOT_NOT_MAPPING` (root sequence, root scalar), each input level with no keys; `YAML_FLOW_COLLECTION_NOT_EXPANDED` (key emitted with `object` or `array`, inner keys not emitted, other keys kept); `YAML_KEY_ESCAPE_UNSUPPORTED` (only the escaped double-quoted key dropped; a single-quoted key with a backslash kept).
- `property: Get-DocsYamlKey is invariant under comment insertion` (seed 102260, 100 random insertions of comment and blank lines outside block scalars; key paths and value types equal the reference run).

CI: `poshqc / PowerShell QC` (windows-latest shards).
