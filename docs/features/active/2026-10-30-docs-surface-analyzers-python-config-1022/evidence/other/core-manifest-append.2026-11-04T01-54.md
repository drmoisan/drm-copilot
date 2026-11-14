# [P5-T2] core.json append of the 1022 library paths (issue #1022)

Timestamp: 2026-11-04T01-54
Command: git diff --numstat MERGE_BASE -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json; git diff --numstat MERGE_BASE -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/python.json (`MERGE_BASE` = `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`)
EXIT_CODE: 0
Output Summary: `19	1	extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (19 added, 1 deleted: `CORE_TAIL` is `last`, so the former final entry `.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json` is rewritten with a trailing comma and the eighteen new `.claude/lib/docs/` paths follow it, each exactly once); the `python.json` numstat prints nothing. `core.json` now lists 35 `.claude/lib/docs/` entries (17 from 1020 plus 18 from 1022) with no duplicate.

## Appended entries (in order, after the final 1020 docs entry)

`.claude/lib/docs/DocsSourceText.psm1`, `DocsPythonTokens.psm1`, `DocsPythonSyntax.psm1`, `DocsPythonBindings.psm1`, `DocsTomlKeys.psm1`, `DocsYamlKeys.psm1`, `DocsJsonSchemaKeys.psm1`, `DocsPythonCliArgparse.psm1`, `DocsPythonCliClick.psm1`, `DocsPythonCliTyper.psm1`, `DocsAnalyzerPythonCli.psm1`, `DocsPythonHttpSites.psm1`, `DocsAnalyzerPythonHttp.psm1`, `DocsAnalyzerPythonApi.psm1`, `DocsAnalyzerArchitecture.psm1`, `DocsAnalyzerConfigFiles.psm1`, `DocsInventorySnapshot.psm1`, `DocsInventory.psm1`.

Count note: the plan states 18 added and 1 deleted for seventeen modules; the `DocsPythonBindings.psm1` split adds one to each count per the trailing paragraph of `## Artifact Classification`, giving the observed 19 added and 1 deleted.

Proven further by [P5-T3] (`Docs.Manifest.Tests.ps1` and the other manifest-reading suites) and [P5-T4] (the push-down contract tests).
