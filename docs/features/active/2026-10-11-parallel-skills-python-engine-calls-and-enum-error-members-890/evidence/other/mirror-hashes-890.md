# Mirror Hashes (Issue #890)

Mirror root: `extensions/drm-copilot/resources/claude-customizations/`.

## P1-T15 — five bash library files

Timestamp: 2026-10-12T20-20
Command: one `cp .claude/lib/bash/<name> extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/<name>` per file, then `sha256sum <repo path> <mirror path>` over all five pairs in one invocation.
EXIT_CODE: 0
Output Summary: all five pairs have equal SHA-256 values.

| File | Repository SHA-256 | Mirror SHA-256 | Equal |
| --- | --- | --- | --- |
| `.claude/lib/bash/parallel-mutation.sh` | d352cb0a63b698465c9887fbfa96d561727aad3d48b7f48135f5b68b807f5a6e | d352cb0a63b698465c9887fbfa96d561727aad3d48b7f48135f5b68b807f5a6e | yes |
| `.claude/lib/bash/remove-parallel-item.sh` | b00110a6ba61961d57d73e4359cd135d8b7af64b0d7330b83f8a3e8c5d56ef08 | b00110a6ba61961d57d73e4359cd135d8b7af64b0d7330b83f8a3e8c5d56ef08 | yes |
| `.claude/lib/bash/parallel-mutation-cli.sh` | 3f2727781bf4d7f6d461740d4bf1508e23d3e358afad5f764c12ab2dd4f9312e | 3f2727781bf4d7f6d461740d4bf1508e23d3e358afad5f764c12ab2dd4f9312e | yes |
| `.claude/lib/bash/parallel-mutation-ops.sh` | dbd319a91efdd8c362e47bc9ec03a8c994636437abb0acbe53f6df2e055f0c43 | dbd319a91efdd8c362e47bc9ec03a8c994636437abb0acbe53f6df2e055f0c43 | yes |
| `.claude/lib/bash/mutate-parallel-run.sh` | e358a2977feb14b6c66ee6c792320f7b9748fd478e2f2cf6271711d3b4faff89 | e358a2977feb14b6c66ee6c792320f7b9748fd478e2f2cf6271711d3b4faff89 | yes |

## P1-T25 — five edited documents

Timestamp: 2026-10-12T20-26
Command: one `cp <path> extensions/drm-copilot/resources/claude-customizations/<path>` per file, then `sha256sum <path> <mirror path>` over all five pairs in one invocation.
EXIT_CODE: 0
Output Summary: all five pairs have equal SHA-256 values. Precondition checked first: at HEAD (`git rev-parse HEAD:<path> HEAD:<mirror path>`) each repository file and its mirror had the same blob SHA, so a straight copy preserves the mirror relationship.

| File | Repository SHA-256 | Mirror SHA-256 | Equal |
| --- | --- | --- | --- |
| `.claude/skills/parallel-add/SKILL.md` | addb55db184fe2f861fdee96aa852f5e283bc983c1a58cdabc206584fb6e6ad6 | addb55db184fe2f861fdee96aa852f5e283bc983c1a58cdabc206584fb6e6ad6 | yes |
| `.claude/skills/parallel-close/SKILL.md` | 9df5ed8354001ed2ac1497cc4c533bb21a79da795035ad4d7592e41715de09bc | 9df5ed8354001ed2ac1497cc4c533bb21a79da795035ad4d7592e41715de09bc | yes |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 35cc60377f37465fd4ea463bfdb1a78e462161ce9c094a64ac61c1f9cf49c9dc | 35cc60377f37465fd4ea463bfdb1a78e462161ce9c094a64ac61c1f9cf49c9dc | yes |
| `.claude/agents/parallel-orchestrator.md` | 49eba236cd68ce736120827f6d52596937c4fc2eff47d54219decbd9c14f0844 | 49eba236cd68ce736120827f6d52596937c4fc2eff47d54219decbd9c14f0844 | yes |
| `.claude/settings.json` | cb9893ee9d71397106cb17a71843eacd96b22e59691a101540f9f4e30d32d082 | cb9893ee9d71397106cb17a71843eacd96b22e59691a101540f9f4e30d32d082 | yes |
