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

## P1-T31 — committed index blobs of the bash pairs

Timestamp: 2026-10-12T20-29
Command: `git ls-files -s <repo path> <mirror path>` over the five bash pairs, after the Phase 1 commit eba4d72cc81110b979f7534c898cf3cc3121f676 was pushed.
EXIT_CODE: 0
Output Summary: each repository/mirror pair reports the same blob SHA (mode 100644).

| File | Blob SHA (repository and mirror) |
| --- | --- |
| `parallel-mutation.sh` | 8e1629e54a664decae04915a1eb9c8a654741d8c |
| `remove-parallel-item.sh` | 3af7c826bc65712d2b9796aff368112909f3fce4 |
| `parallel-mutation-cli.sh` | 111c8d0c3557df39735fb5adcad9c26fba2e6dd9 |
| `parallel-mutation-ops.sh` | 997345e73615a51b1e45a1d25d03aebe5fa951b8 |
| `mutate-parallel-run.sh` | 9bd6ee6f7d76d4f8ee8a61769d3e12677c882f47 |
