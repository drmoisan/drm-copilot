# QA PoshQC Format - Issue #1021

Timestamp: 2026-11-03T23-28
Task: [P6-T1]
Command: `sh SCRATCH/issue-1021-format.sh` (PowerShell 7: SHA-256 listing of every file under `.claude/lib/docs` and `tests/scripts/claude-lib/docs`; `Import-Module scripts/powershell/PoshQC/PoshQC.psd1`; `Invoke-PoshQCFormat -Root <worktree> -ScanFolders .claude/lib/docs, tests/scripts/claude-lib/docs`; listing again)
EXIT_CODE: 0
Output Summary: final pass (pass 3): 54 files listed before and after; the formatter logged 0 `Formatted:` and 40 `Already formatted:` lines; the two listings are identical (the formatter changed nothing).

## Loop history

- Pass 1: the formatter changed `tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1` and `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1` (hashtable `=` alignment only). The formatted text was kept, [P5-T1] was re-run (16 of 16 digest pairs equal), and the loop restarted (`qa-poshqc-format.2026-11-03T23-26.md`).
- Pass 2: identical listings; [P6-T2] then reported 8 analyzer warnings, which were fixed (see `qa-pssa`), [P5-T1] was re-run (bundle copies of `DocsPageCheck.psm1` and `DocsPageLinks.psm1` refreshed; 16 of 16 digest pairs equal), and the loop restarted from [P6-T1].
- Pass 3 (below): identical listings.

## Run output of pass 3 (before listing, after listing, formatter log)

```text
EXIT_CODE: 0
FILES_BEFORE: 54
FILES_AFTER: 54
FORMATTED_COUNT: 0
ALREADY_FORMATTED_COUNT: 40
IDENTICAL: True
CHANGED: 
--- BEFORE
.claude/lib/docs/DocsAnalyzerRegistry.psm1 8d75a5f564a9957c7c728d8d6fe39453db7910f97700683aade4ae33aa92da09
.claude/lib/docs/DocsFinding.psm1 8165050be4f00ae8c7c9e2fac64073c008d0070d5a768620143c0dc6981f2ceb
.claude/lib/docs/DocsJson.psm1 0b876afa08cc4a35330e35cbefb70f2f9c212c715c5d168f1ab1eecc0b43371e
.claude/lib/docs/DocsPageCheck.psm1 1029b294a06c4ea6789c737c83372d067abe5167014ea3f4a5da8d17d959ddea
.claude/lib/docs/DocsPageDiataxis.psm1 38867744d332091c33957a133cd383123c67d42f2a8d09536e7d83e74f7fb5ee
.claude/lib/docs/DocsPageFrontMatter.psm1 679263c785ea932d45bbe92535a1b556e49e4850327b8df44a189e46bd61042f
.claude/lib/docs/DocsPageLinks.psm1 19695aaf6c9d14519d1e36084d940c08b71dc47013747a283a4dcc4b35b863a8
.claude/lib/docs/DocsPageMarkdown.psm1 31d9ca4c232554afa2f9227d5020e358f86b647f53830b769adc3e5714a5f3ea
.claude/lib/docs/DocsPageMetadata.psm1 b9f7b0f5a02f363e9ebdb457bce3ee7ce29fd3bf411ec34a54b4e1b1731a81e4
.claude/lib/docs/DocsPageOrphans.psm1 69d18d394cd4094fe458feb413d403d15505549d137fd5215d1d2cb83c7a13f6
.claude/lib/docs/DocsProfile.psm1 eeda9be7e18bf959ad153211dcc1cb50fe741651663ad5c178e9131f5c0f91d6
.claude/lib/docs/DocsProfileCommands.psm1 2237ec9f5859ec6fd13ac08ee1df8f8ac0d0c68171170747f0d1e693f9e4883b
.claude/lib/docs/DocsSchema.psm1 681e926e8a355ffdab852a7a87e25237913aba3f658505ce94d5fada10523efd
.claude/lib/docs/DocsSchemaWalk.psm1 1f16337dcf3deacfe6f19947b8d5115922bfa369e63868ce9360c9f346b7f90e
.claude/lib/docs/DocsSurface.psm1 a7b760b4e28e57a3bc2ec6729c67067fb3cd59d2446f8a8ff14f56e0a6bf28ad
.claude/lib/docs/Invoke-DocsCommand.ps1 594a8de627f2e45f195d7b127453be2fdf882b83b2b784dead01cb2daa9f79d2
.claude/lib/docs/schemas/v1/common.schema.json 7e9f04527049ddc027237122ddad64048f42be5d76bbcc3a33af083195e5c8dd
.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json ce0ed48c85990999a0856f89ff656cf364398bf3109ecc707fbecd1d188d08bb
.claude/lib/docs/schemas/v1/docs-coverage-ledger.schema.json 461c9b25ae6c1455fb560f89616f0971925673c3b0a03232ceb59f8cf4472358
.claude/lib/docs/schemas/v1/docs-evidence-pin.schema.json d25c85cf257a76e9782378b16cca4eebd82269833658aa3e16be2e5ad579e2f1
.claude/lib/docs/schemas/v1/docs-parity-matrix.schema.json bde17f6f48a4f3d47ade11a563213e695c1a6e450906e3bdf3fb2dc5ed6ab8e5
.claude/lib/docs/schemas/v1/docs-profile.schema.json b9bdb572f6912a17bd84d9c03a9a94bdbb68ee818f39f5e867ef5c786632f23e
.claude/lib/docs/schemas/v1/docs-validation-receipt.schema.json ec77894a038b27fc16826f4d51aef5cdb77da7d7442bed55a25db3ae8f4b2dc6
.claude/lib/docs/schemas/v1/page-metadata.schema.json 0212c2a141dfdc8c11f864ee48e60df1079e3e9ff2ca3e6a370e518ccdeb2690
.claude/lib/docs/schemas/v1/surface-inventory-snapshot.schema.json 4cd767089dbf44b8f227b68ad0b4cc3b40a3ac7bfa391304e7d3a6eb908ad609
.claude/lib/docs/templates/page-check/markdownlint.json 743f53216106cfbfe5afc3177bf5d94a5d44bb188fcdf9efa61eb015980e67e4
.claude/lib/docs/templates/page-check/vale.ini ef78a18cc94570393d55ac70d8f1a9f4decd61efd79bc12a0960eb20423d902c
.claude/lib/docs/templates/page-check/vale/DocsBase/HeadingPunctuation.yml a96337efc72456f9ff558f6699c56fb6094b20f9eb37fd6ff0a94065998172bd
.claude/lib/docs/templates/page-check/vale/DocsBase/Placeholders.yml 9af39b706ee803f618e84d3cc5a8d5f657b351d96280884e65293ca23bb7189b
.claude/lib/docs/templates/page-check/vale/Project/accept.txt e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1 da1cc2b616f86b9863c8e30df18caa96699f8863dbbf27f951b98bb068a87790
tests/scripts/claude-lib/docs/Docs.TestSupport.psm1 cc6410347b00b9c40213d43f6959b1da533d5141dc3630fbc549764645635218
tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1 cb6f204dc34ff32dde7308cc05e87a1de2b4c9233170058ca45b0876e7c5111a
tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1 a069905367b7d4d90887914cd99d1122641a6cf42f850c9c842dbb77b2c5ea50
tests/scripts/claude-lib/docs/DocsJson.Tests.ps1 0b76487dd6c0b3e5d7106e223bb9a3786809a1199471bd23fdcdda0e94eabbf2
tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1 d2ffd378f83734a13761a9dbadab77452dd2568eb3e055150190bd5b6af5de14
tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1 20e39677f819313d00d1f91668cd34dcd233b9c1c01c3cefe87bba29996e76a9
tests/scripts/claude-lib/docs/DocsPageDiataxis.Tests.ps1 a9fc282dc13f3ec02108b0463fc2dd3f4d055c3b0779b089de579e30e457902a
tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1 1230fb27b0feb66d216b1b7d4b2b6b65d0d52301380c46cafd1ed190d200b830
tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1 a8dc0c8ac6dc65a76ab673476fc5b5fc47c04ec936cb687e8e48cbe1e0fbe58e
tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1 04699d0367487bc1017f09aed07440c636e698e46f74ce80e2add7e2695a8460
tests/scripts/claude-lib/docs/DocsPageMarkdown.Tests.ps1 0f78b86c349fe05e315cfb775c212f5c7099658fa616f844a280e3e6de68e2af
tests/scripts/claude-lib/docs/DocsPageMetadata.Tests.ps1 f62415851cbe98171ee8e670f8c445d18604b205079583231c308619c6e8b055
tests/scripts/claude-lib/docs/DocsPageMetadataSchema.Tests.ps1 24cc8ab6642b8d4c34a5d27651507683fcde43bda6a16f75843473fa7187b500
tests/scripts/claude-lib/docs/DocsPageOrphans.Tests.ps1 eea198fdebc58e4f32d34ec726793ecda9f1339be64b35c2185f53047929efe7
tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1 d66c52e5baf424ac4833a0aa671551dd54988906a2ea924810a8bf683eba7309
tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1 d54feb63da6a140d2fe7dd8ce90db17bd0ac1f4efae32feb52eba097829302a9
tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1 165a55c184dfbf858be5051847f17110e8c3ae167ae92907ff01bedc8427ee04
tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1 64677bd37229b6de304db73707e2aeff0038dc712e0fd67a09f8fc8d5998adeb
tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1 cfb8bbeaca2280878ebe901d3518f3287f470504befd567e992835edebca7e7c
tests/scripts/claude-lib/docs/DocsSchemaWalk.Tests.ps1 eee95d0f74b9e29627eb2233f7c6cf404a8a50cd4e4146efbaaae25b710d1ee9
tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1 6dde8c038f21df7df2d5d02af1e14587f19e5b0d5817520fbf5a487c8556feda
tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 87bdcea3d35cebeb5fcc81095340e9c37db65dba0825c4a5d508bc46aa8aa821
tests/scripts/claude-lib/docs/fixtures/DocsAnalyzerFixture.psm1 97f01337e3ba802a0d1ae315524fa276e1f375db615048ea896e000f567859d2
--- AFTER
.claude/lib/docs/DocsAnalyzerRegistry.psm1 8d75a5f564a9957c7c728d8d6fe39453db7910f97700683aade4ae33aa92da09
.claude/lib/docs/DocsFinding.psm1 8165050be4f00ae8c7c9e2fac64073c008d0070d5a768620143c0dc6981f2ceb
.claude/lib/docs/DocsJson.psm1 0b876afa08cc4a35330e35cbefb70f2f9c212c715c5d168f1ab1eecc0b43371e
.claude/lib/docs/DocsPageCheck.psm1 1029b294a06c4ea6789c737c83372d067abe5167014ea3f4a5da8d17d959ddea
.claude/lib/docs/DocsPageDiataxis.psm1 38867744d332091c33957a133cd383123c67d42f2a8d09536e7d83e74f7fb5ee
.claude/lib/docs/DocsPageFrontMatter.psm1 679263c785ea932d45bbe92535a1b556e49e4850327b8df44a189e46bd61042f
.claude/lib/docs/DocsPageLinks.psm1 19695aaf6c9d14519d1e36084d940c08b71dc47013747a283a4dcc4b35b863a8
.claude/lib/docs/DocsPageMarkdown.psm1 31d9ca4c232554afa2f9227d5020e358f86b647f53830b769adc3e5714a5f3ea
.claude/lib/docs/DocsPageMetadata.psm1 b9f7b0f5a02f363e9ebdb457bce3ee7ce29fd3bf411ec34a54b4e1b1731a81e4
.claude/lib/docs/DocsPageOrphans.psm1 69d18d394cd4094fe458feb413d403d15505549d137fd5215d1d2cb83c7a13f6
.claude/lib/docs/DocsProfile.psm1 eeda9be7e18bf959ad153211dcc1cb50fe741651663ad5c178e9131f5c0f91d6
.claude/lib/docs/DocsProfileCommands.psm1 2237ec9f5859ec6fd13ac08ee1df8f8ac0d0c68171170747f0d1e693f9e4883b
.claude/lib/docs/DocsSchema.psm1 681e926e8a355ffdab852a7a87e25237913aba3f658505ce94d5fada10523efd
.claude/lib/docs/DocsSchemaWalk.psm1 1f16337dcf3deacfe6f19947b8d5115922bfa369e63868ce9360c9f346b7f90e
.claude/lib/docs/DocsSurface.psm1 a7b760b4e28e57a3bc2ec6729c67067fb3cd59d2446f8a8ff14f56e0a6bf28ad
.claude/lib/docs/Invoke-DocsCommand.ps1 594a8de627f2e45f195d7b127453be2fdf882b83b2b784dead01cb2daa9f79d2
.claude/lib/docs/schemas/v1/common.schema.json 7e9f04527049ddc027237122ddad64048f42be5d76bbcc3a33af083195e5c8dd
.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json ce0ed48c85990999a0856f89ff656cf364398bf3109ecc707fbecd1d188d08bb
.claude/lib/docs/schemas/v1/docs-coverage-ledger.schema.json 461c9b25ae6c1455fb560f89616f0971925673c3b0a03232ceb59f8cf4472358
.claude/lib/docs/schemas/v1/docs-evidence-pin.schema.json d25c85cf257a76e9782378b16cca4eebd82269833658aa3e16be2e5ad579e2f1
.claude/lib/docs/schemas/v1/docs-parity-matrix.schema.json bde17f6f48a4f3d47ade11a563213e695c1a6e450906e3bdf3fb2dc5ed6ab8e5
.claude/lib/docs/schemas/v1/docs-profile.schema.json b9bdb572f6912a17bd84d9c03a9a94bdbb68ee818f39f5e867ef5c786632f23e
.claude/lib/docs/schemas/v1/docs-validation-receipt.schema.json ec77894a038b27fc16826f4d51aef5cdb77da7d7442bed55a25db3ae8f4b2dc6
.claude/lib/docs/schemas/v1/page-metadata.schema.json 0212c2a141dfdc8c11f864ee48e60df1079e3e9ff2ca3e6a370e518ccdeb2690
.claude/lib/docs/schemas/v1/surface-inventory-snapshot.schema.json 4cd767089dbf44b8f227b68ad0b4cc3b40a3ac7bfa391304e7d3a6eb908ad609
.claude/lib/docs/templates/page-check/markdownlint.json 743f53216106cfbfe5afc3177bf5d94a5d44bb188fcdf9efa61eb015980e67e4
.claude/lib/docs/templates/page-check/vale.ini ef78a18cc94570393d55ac70d8f1a9f4decd61efd79bc12a0960eb20423d902c
.claude/lib/docs/templates/page-check/vale/DocsBase/HeadingPunctuation.yml a96337efc72456f9ff558f6699c56fb6094b20f9eb37fd6ff0a94065998172bd
.claude/lib/docs/templates/page-check/vale/DocsBase/Placeholders.yml 9af39b706ee803f618e84d3cc5a8d5f657b351d96280884e65293ca23bb7189b
.claude/lib/docs/templates/page-check/vale/Project/accept.txt e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1 da1cc2b616f86b9863c8e30df18caa96699f8863dbbf27f951b98bb068a87790
tests/scripts/claude-lib/docs/Docs.TestSupport.psm1 cc6410347b00b9c40213d43f6959b1da533d5141dc3630fbc549764645635218
tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1 cb6f204dc34ff32dde7308cc05e87a1de2b4c9233170058ca45b0876e7c5111a
tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1 a069905367b7d4d90887914cd99d1122641a6cf42f850c9c842dbb77b2c5ea50
tests/scripts/claude-lib/docs/DocsJson.Tests.ps1 0b76487dd6c0b3e5d7106e223bb9a3786809a1199471bd23fdcdda0e94eabbf2
tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1 d2ffd378f83734a13761a9dbadab77452dd2568eb3e055150190bd5b6af5de14
tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1 20e39677f819313d00d1f91668cd34dcd233b9c1c01c3cefe87bba29996e76a9
tests/scripts/claude-lib/docs/DocsPageDiataxis.Tests.ps1 a9fc282dc13f3ec02108b0463fc2dd3f4d055c3b0779b089de579e30e457902a
tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1 1230fb27b0feb66d216b1b7d4b2b6b65d0d52301380c46cafd1ed190d200b830
tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1 a8dc0c8ac6dc65a76ab673476fc5b5fc47c04ec936cb687e8e48cbe1e0fbe58e
tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1 04699d0367487bc1017f09aed07440c636e698e46f74ce80e2add7e2695a8460
tests/scripts/claude-lib/docs/DocsPageMarkdown.Tests.ps1 0f78b86c349fe05e315cfb775c212f5c7099658fa616f844a280e3e6de68e2af
tests/scripts/claude-lib/docs/DocsPageMetadata.Tests.ps1 f62415851cbe98171ee8e670f8c445d18604b205079583231c308619c6e8b055
tests/scripts/claude-lib/docs/DocsPageMetadataSchema.Tests.ps1 24cc8ab6642b8d4c34a5d27651507683fcde43bda6a16f75843473fa7187b500
tests/scripts/claude-lib/docs/DocsPageOrphans.Tests.ps1 eea198fdebc58e4f32d34ec726793ecda9f1339be64b35c2185f53047929efe7
tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1 d66c52e5baf424ac4833a0aa671551dd54988906a2ea924810a8bf683eba7309
tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1 d54feb63da6a140d2fe7dd8ce90db17bd0ac1f4efae32feb52eba097829302a9
tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1 165a55c184dfbf858be5051847f17110e8c3ae167ae92907ff01bedc8427ee04
tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1 64677bd37229b6de304db73707e2aeff0038dc712e0fd67a09f8fc8d5998adeb
tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1 cfb8bbeaca2280878ebe901d3518f3287f470504befd567e992835edebca7e7c
tests/scripts/claude-lib/docs/DocsSchemaWalk.Tests.ps1 eee95d0f74b9e29627eb2233f7c6cf404a8a50cd4e4146efbaaae25b710d1ee9
tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1 6dde8c038f21df7df2d5d02af1e14587f19e5b0d5817520fbf5a487c8556feda
tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 87bdcea3d35cebeb5fcc81095340e9c37db65dba0825c4a5d508bc46aa8aa821
tests/scripts/claude-lib/docs/fixtures/DocsAnalyzerFixture.psm1 97f01337e3ba802a0d1ae315524fa276e1f375db615048ea896e000f567859d2
--- LOG
Already formatted: <root>/.claude/lib/docs/DocsAnalyzerRegistry.psm1
Already formatted: <root>/.claude/lib/docs/DocsFinding.psm1
Already formatted: <root>/.claude/lib/docs/DocsJson.psm1
Already formatted: <root>/.claude/lib/docs/DocsPageCheck.psm1
Already formatted: <root>/.claude/lib/docs/DocsPageDiataxis.psm1
Already formatted: <root>/.claude/lib/docs/DocsPageFrontMatter.psm1
Already formatted: <root>/.claude/lib/docs/DocsPageLinks.psm1
Already formatted: <root>/.claude/lib/docs/DocsPageMarkdown.psm1
Already formatted: <root>/.claude/lib/docs/DocsPageMetadata.psm1
Already formatted: <root>/.claude/lib/docs/DocsPageOrphans.psm1
Already formatted: <root>/.claude/lib/docs/DocsProfile.psm1
Already formatted: <root>/.claude/lib/docs/DocsProfileCommands.psm1
Already formatted: <root>/.claude/lib/docs/DocsSchema.psm1
Already formatted: <root>/.claude/lib/docs/DocsSchemaWalk.psm1
Already formatted: <root>/.claude/lib/docs/DocsSurface.psm1
Already formatted: <root>/.claude/lib/docs/Invoke-DocsCommand.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/Docs.TestSupport.psm1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsFinding.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsJson.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageDiataxis.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageMarkdown.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageMetadata.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageMetadataSchema.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageOrphans.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsSchema.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsSchemaWalk.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/DocsSurface.Tests.ps1
Already formatted: <root>/tests/scripts/claude-lib/docs/fixtures/DocsAnalyzerFixture.psm1
Already formatted: <root>/tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1
```
