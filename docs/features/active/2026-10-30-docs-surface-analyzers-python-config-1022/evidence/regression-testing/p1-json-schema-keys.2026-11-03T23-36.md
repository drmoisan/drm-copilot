# [P1-T6] Pester gate: DocsJsonSchemaKeys (issue #1022)

Timestamp: 2026-11-03T23-36
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsJsonSchemaKeys.Tests.ps1 -CoverageFile .claude/lib/docs/DocsJsonSchemaKeys.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsJsonSchemaKeys.Tests.ps1: 20 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=20 Failed=0 Skipped=0). .claude/lib/docs/DocsJsonSchemaKeys.psm1: 134 of 134 analyzed lines executed (100%). The JUnit file is well-formed; counts were read from it.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsJsonSchemaKeys.psm1` and `tests/scripts/claude-lib/docs/DocsJsonSchemaKeys.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings.
- Physical line counts: `DocsJsonSchemaKeys.psm1` 288; `DocsJsonSchemaKeys.Tests.ps1` 246.

## Behavior covered

- `Get-DocsJsonMemberSpan`: object members (name line through value end), array elements, nested containers, pointer escaping of `/` and `~`, escaped quotes inside strings, the root span, CRLF and BOM normalization, one-line documents; `property: Get-DocsJsonMemberSpan places each generated member on its written lines` (seed 102270).
- `Get-DocsJsonSchemaKey`: root and nested `properties`, object-form `items.properties` (segment `[]`), `allOf` (not conditional), `anyOf` and `oneOf` (`Conditional` true), local `$ref` to `#/$defs/` and `#/definitions/` (span of the target member), `schema_type` literal, `multiple` for a type list and absent, `required`; `default`, `enum`, `const`, `examples` and `pattern` never appear in the output (JSON serialization of the result contains no marker); a null value and a schema without properties yield nothing.
- Diagnostics with code, severity `warning`, blocking `$false`, line and effect: `JSON_SCHEMA_REF_UNRESOLVED` for a remote `$ref`, a missing target, a `$ref` cycle (visited set) and property nesting depth 17 (depth 16 walked without a diagnostic; keys beneath the bound not enumerated), other keys kept; `JSON_SCHEMA_KEYWORD_NOT_EXPANDED` for `if`, `then`, `else`, `not`, `patternProperties`, schema-valued `additionalProperties` (a boolean `additionalProperties` is not reported), `dependentSchemas`, `prefixItems` and `unevaluatedProperties`, with no key enumerated beneath the keyword.
- `property: Get-DocsJsonSchemaKey emits every generated property path once with its type and required flag` (seed 102271).

CI: `poshqc / PowerShell QC` (windows-latest shards).
