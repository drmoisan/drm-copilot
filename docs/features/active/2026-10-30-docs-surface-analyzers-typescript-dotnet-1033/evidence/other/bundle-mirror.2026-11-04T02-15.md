# Phase 6 bundle mirror ([P6-T5])

Timestamp: 2026-11-04T02-15
Command: sh SCRATCH/issue-1033-bundle-copy.sh (copies every new 1033 module and the edited registry from `.claude/lib/docs/` to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` with `cp`, then prints `SAME <path> <sha256>` when the source and bundle SHA-256 agree), followed by `git status --porcelain --untracked-files=all -- extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs`
EXIT_CODE: 0
Output Summary: 18 files copied; every pair reports SAME (byte-identical): the 17 new modules (DocsScannerCommon, DocsTypeScriptTokens, DocsCSharpTokens, DocsTypeScriptSyntax, DocsTypeScriptCliSupport, DocsAnalyzerTypeScriptCli, DocsTypeScriptHttpDeclaration, DocsTypeScriptHttpSupport, DocsAnalyzerTypeScriptHttp, DocsAnalyzerTypeScriptExports, DocsCSharpSyntax, DocsAnalyzerDotnetHttp, DocsAnalyzerDotnetConfig, DocsCSharpMember, DocsAnalyzerDotnetApi, DocsExtensionShape, DocsAnalyzerExtensionImport) and the edited registry (DocsAnalyzerRegistry). The porcelain listing shows the modified registry copy (` M`) and the 17 new copies (`??`). The plan's "ten or eleven" count is superseded by the 500-line split rule of `## Design Constraints From Existing Tests` (seven split helper modules).

## Per-file digests (source and bundle equal)

| `.claude/lib/docs/` file | SHA-256 |
|---|---|
| DocsScannerCommon.psm1 | c0631d4318bb228d89e40d5a804a2c95834a35a7e4498b81f060e00853aa186f |
| DocsTypeScriptTokens.psm1 | c09b2a99b7d24ad93be40fc423514383ad33c43c948d15978b696bda5cc72577 |
| DocsCSharpTokens.psm1 | bf1a0cf944a1c3ad9ee87f1594dbfc5ed933c7f4af070df733638f89be1632cd |
| DocsTypeScriptSyntax.psm1 | 8e614cd488a7df8722fa2a1604cba72b891445e5ac7459832c0c62dc40c47e12 |
| DocsTypeScriptCliSupport.psm1 | 04c17cdf0bd8cc92cec3bf159669a1948424e315105b94afb90b853b43b935e7 |
| DocsAnalyzerTypeScriptCli.psm1 | 68a7ef850cd5a175a960cadc5d2210060d4bb910193dc50346f4c1fa551ceba5 |
| DocsTypeScriptHttpDeclaration.psm1 | bce21af6e393376130f6989a2082134adbb39b32b90bf11c3f193178315b3e45 |
| DocsTypeScriptHttpSupport.psm1 | 1aed2a6ac9e7313061e0805a1ce7826a6cab603df687ad1d7cad277585f52a84 |
| DocsAnalyzerTypeScriptHttp.psm1 | eaa91261849bee3e9a9661bbe0694caa10f46aac0b083a8cda72de162d2cfd0c |
| DocsAnalyzerTypeScriptExports.psm1 | 9fdb234b66f888645e34a1f0980315fee89adabbb3b72a21b9e7dfd24ae62a7f |
| DocsCSharpSyntax.psm1 | 6cb6f7f6bfd7c7a2115e34e1d8462d73a99560078d2f87fac2b76791f3eeaea3 |
| DocsAnalyzerDotnetHttp.psm1 | 08f3e9e325bb62076ae379e8968eab260460578ae596838b8160fc7f517eff13 |
| DocsAnalyzerDotnetConfig.psm1 | fd9e605988b001418a077cec748843045801da63983564eda7fa7a680311f2f0 |
| DocsCSharpMember.psm1 | bfae43d78368405e5274990166645de11cbeb6cc2100549451ccaf066bea8d47 |
| DocsAnalyzerDotnetApi.psm1 | 92ab3fc911ef9d138dab0d5620337079a2b14e2046f7272b52a8dec013a5d1bc |
| DocsExtensionShape.psm1 | 8392b386e0328575147fb2fc94f54febc55c9253bc5c81858fec876329a8c321 |
| DocsAnalyzerExtensionImport.psm1 | 36fa987cc0d39c936f7392d66a4ce348f7223fe61048794d6040112b7063f29e |
| DocsAnalyzerRegistry.psm1 (edited) | fc3c05729e2463e16ae0d79fdad35116a63c06f02a1cbd36ff7c72c867efc481 |

## Porcelain listing (`extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs`)

```
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerRegistry.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerDotnetApi.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerDotnetConfig.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerDotnetHttp.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerExtensionImport.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerTypeScriptCli.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerTypeScriptExports.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerTypeScriptHttp.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsCSharpMember.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsCSharpSyntax.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsCSharpTokens.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsExtensionShape.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsScannerCommon.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptCliSupport.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptHttpDeclaration.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptHttpSupport.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptSyntax.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptTokens.psm1
```
