# Bundle Mirror - Issue #1021

Timestamp: 2026-11-03T23-22
Task: [P5-T1]
Command: `sh SCRATCH/issue-1021-bundle-copy.sh` (one `cp` step per file from `.claude/lib/docs/` to `B`, then `git status --porcelain --untracked-files=all -- extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs` and `sha256sum` of each source and copy)
EXIT_CODE: 0
Output Summary: 13 new files (7 modules, 1 schema, 5 templates) and 3 modified files (`DocsProfileCommands.psm1`, `DocsSchema.psm1`, `Invoke-DocsCommand.ps1`); all 16 SHA-256 pairs equal. The copy ran after the last source edit ([P4-T7] edited a test only).

## Listing

```text
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsProfileCommands.psm1
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsSchema.psm1
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageCheck.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageDiataxis.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageFrontMatter.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageLinks.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageMarkdown.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageMetadata.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPageOrphans.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/page-metadata.schema.json
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/templates/page-check/markdownlint.json
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/templates/page-check/vale.ini
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/templates/page-check/vale/DocsBase/HeadingPunctuation.yml
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/templates/page-check/vale/DocsBase/Placeholders.yml
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/templates/page-check/vale/Project/accept.txt
```

## Digests (path under `.claude/lib/docs/`, source SHA-256, bundle SHA-256)

| File | SHA-256 (source = bundle) |
|---|---|
| `DocsPageMarkdown.psm1` | `31d9ca4c232554afa2f9227d5020e358f86b647f53830b769adc3e5714a5f3ea` |
| `DocsPageFrontMatter.psm1` | `679263c785ea932d45bbe92535a1b556e49e4850327b8df44a189e46bd61042f` |
| `DocsPageMetadata.psm1` | `b9f7b0f5a02f363e9ebdb457bce3ee7ce29fd3bf411ec34a54b4e1b1731a81e4` |
| `DocsPageLinks.psm1` | `f5279e7e7b72f88f07c2c3a13cb329a0e9f24feee2642aeab425d36db4b1477e` |
| `DocsPageDiataxis.psm1` | `38867744d332091c33957a133cd383123c67d42f2a8d09536e7d83e74f7fb5ee` |
| `DocsPageOrphans.psm1` | `69d18d394cd4094fe458feb413d403d15505549d137fd5215d1d2cb83c7a13f6` |
| `DocsPageCheck.psm1` | `6c0fb20571b56427a846869b988419c0051dd6317562a4c58ecf2450b33c7864` |
| `Invoke-DocsCommand.ps1` | `594a8de627f2e45f195d7b127453be2fdf882b83b2b784dead01cb2daa9f79d2` |
| `DocsSchema.psm1` | `681e926e8a355ffdab852a7a87e25237913aba3f658505ce94d5fada10523efd` |
| `DocsProfileCommands.psm1` | `2237ec9f5859ec6fd13ac08ee1df8f8ac0d0c68171170747f0d1e693f9e4883b` |
| `schemas/v1/page-metadata.schema.json` | `0212c2a141dfdc8c11f864ee48e60df1079e3e9ff2ca3e6a370e518ccdeb2690` |
| `templates/page-check/markdownlint.json` | `743f53216106cfbfe5afc3177bf5d94a5d44bb188fcdf9efa61eb015980e67e4` |
| `templates/page-check/vale.ini` | `ef78a18cc94570393d55ac70d8f1a9f4decd61efd79bc12a0960eb20423d902c` |
| `templates/page-check/vale/DocsBase/HeadingPunctuation.yml` | `a96337efc72456f9ff558f6699c56fb6094b20f9eb37fd6ff0a94065998172bd` |
| `templates/page-check/vale/DocsBase/Placeholders.yml` | `9af39b706ee803f618e84d3cc5a8d5f657b351d96280884e65293ca23bb7189b` |
| `templates/page-check/vale/Project/accept.txt` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (zero bytes) |
