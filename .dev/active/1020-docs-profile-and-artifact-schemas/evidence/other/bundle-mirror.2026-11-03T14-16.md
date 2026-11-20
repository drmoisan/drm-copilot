# Bundle Mirror ([P5-T1])

Timestamp: 2026-11-03T14-16
Command: sh SCRATCH/issue-1020-exec-mirror.sh (one copy step of `.claude/lib/docs/*.psm1`, `.claude/lib/docs/*.ps1`, and `.claude/lib/docs/schemas/v1/*.schema.json` into `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, then `git status --porcelain --untracked-files=all -- extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs` and `sha256sum` of each pair)
EXIT_CODE: 0
Output Summary: Seventeen new untracked files in the bundle mirror (nine PowerShell files, including the [P3-T3] split `DocsSchemaWalk.psm1` under the plan's `File size` Pre-Mortem clause, and eight runtime schemas, including `docs-command-envelope.schema.json`); every mirror file has the same SHA-256 as its source. The plan text names sixteen files; the seventeenth is the split module recorded in `## Artifact Classification`.

## Status listing

```
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerRegistry.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsFinding.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsJson.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsProfile.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsProfileCommands.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsSchema.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsSchemaWalk.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsSurface.psm1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/common.schema.json
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-coverage-ledger.schema.json
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-evidence-pin.schema.json
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-parity-matrix.schema.json
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-profile.schema.json
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/docs-validation-receipt.schema.json
?? extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/schemas/v1/surface-inventory-snapshot.schema.json
```

Listing count: 17. Source files under `.claude/lib/docs/`: 17. Mirror files: 17.

## Per-file digests (source = mirror)

| File (relative to `.claude/lib/docs/`) | SHA-256 | Equal |
|---|---|---|
| DocsAnalyzerRegistry.psm1 | d4a4fc5fa28e9560f81147211f66a77784a25e91f16a9650cc8ae82c42eb9e18 | yes |
| DocsFinding.psm1 | 8165050be4f00ae8c7c9e2fac64073c008d0070d5a768620143c0dc6981f2ceb | yes |
| DocsJson.psm1 | 0b876afa08cc4a35330e35cbefb70f2f9c212c715c5d168f1ab1eecc0b43371e | yes |
| DocsProfile.psm1 | eeda9be7e18bf959ad153211dcc1cb50fe741651663ad5c178e9131f5c0f91d6 | yes |
| DocsProfileCommands.psm1 | 5e987f3e08ef9df7a703ffa6462ba27d7615f8bf74c15a6df78c706fcdb362df | yes |
| DocsSchema.psm1 | c29910f99d9e56e01899ab367ad438a4d58adbeead21f3b96b40a6137e7ac9c3 | yes |
| DocsSchemaWalk.psm1 | 1f16337dcf3deacfe6f19947b8d5115922bfa369e63868ce9360c9f346b7f90e | yes |
| DocsSurface.psm1 | a7b760b4e28e57a3bc2ec6729c67067fb3cd59d2446f8a8ff14f56e0a6bf28ad | yes |
| Invoke-DocsCommand.ps1 | b0c98dbc76b53a38947980a938e20bfe34a9fa2185fe130eb613fb413e471858 | yes |
| schemas/v1/common.schema.json | 7e9f04527049ddc027237122ddad64048f42be5d76bbcc3a33af083195e5c8dd | yes |
| schemas/v1/docs-command-envelope.schema.json | ce0ed48c85990999a0856f89ff656cf364398bf3109ecc707fbecd1d188d08bb | yes |
| schemas/v1/docs-coverage-ledger.schema.json | 461c9b25ae6c1455fb560f89616f0971925673c3b0a03232ceb59f8cf4472358 | yes |
| schemas/v1/docs-evidence-pin.schema.json | d25c85cf257a76e9782378b16cca4eebd82269833658aa3e16be2e5ad579e2f1 | yes |
| schemas/v1/docs-parity-matrix.schema.json | bde17f6f48a4f3d47ade11a563213e695c1a6e450906e3bdf3fb2dc5ed6ab8e5 | yes |
| schemas/v1/docs-profile.schema.json | b9bdb572f6912a17bd84d9c03a9a94bdbb68ee818f39f5e867ef5c786632f23e | yes |
| schemas/v1/docs-validation-receipt.schema.json | ec77894a038b27fc16826f4d51aef5cdb77da7d7442bed55a25db3ae8f4b2dc6 | yes |
| schemas/v1/surface-inventory-snapshot.schema.json | 4cd767089dbf44b8f227b68ad0b4cc3b40a3ac7bfa391304e7d3a6eb908ad609 | yes |

## Re-sync during [P5-T5]

`DocsAnalyzerRegistry.psm1` changed during [P5-T5] (recognized `$PSScriptRoot` form; see `evidence/regression-testing/p5-existing-gates.2026-11-03T14-21.md`). The same copy step was re-run: 17 of 17 files EQUAL, new `DocsAnalyzerRegistry.psm1` SHA-256 `8d75a5f564a9957c7c728d8d6fe39453db7910f97700683aade4ae33aa92da09`. Byte identity of the final tree is asserted by `Docs.Manifest.Tests.ps1` in every later run.
