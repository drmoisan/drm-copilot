# Bundle Copy (issue #1012)

Timestamp: 2026-10-31T10-53
Command: sh SCRATCH/issue-1012-copy-bundle.sh (cp of each source file to the same relative path under extensions/drm-copilot/resources/claude-customizations/, then sha256sum of both files)
EXIT_CODE: 0
Output Summary:
- 7 of 7 SHA-256 pairs EQUAL.

| Source | Source SHA-256 | Bundle SHA-256 | Result |
| --- | --- | --- | --- |
| `.claude/hooks/validate-orchestrator-output.ps1` | 1f98e6fc666455bf5ec48157d600fe9e86cb9afecc3ad4912c16c814a58915dd | 1f98e6fc666455bf5ec48157d600fe9e86cb9afecc3ad4912c16c814a58915dd | EQUAL |
| `.claude/hooks/validate-orchestrator-output-rejection.ps1` | 82d0eb81d4473a08dcf4d059d21c7c1244b3ff4359b0a69e2c444c58641630f1 | 82d0eb81d4473a08dcf4d059d21c7c1244b3ff4359b0a69e2c444c58641630f1 | EQUAL |
| `.claude/rules/parallel-orchestration.md` | 53f96d7abf10b99ff472033ad2dc9a4af6341cb42ae55643ec01a5729fc72d58 | 53f96d7abf10b99ff472033ad2dc9a4af6341cb42ae55643ec01a5729fc72d58 | EQUAL |
| `.claude/skills/parallel-run/SKILL.md` | d6c47506261b6f4cacccde58118c9b21ca9458f225b0fa3dc74544132ae59309 | d6c47506261b6f4cacccde58118c9b21ca9458f225b0fa3dc74544132ae59309 | EQUAL |
| `.claude/skills/parallel-add/SKILL.md` | 118eb2f5ff853d4767e88f5d0ff29ed6dffd613f335e94f0fff45e1589853b19 | 118eb2f5ff853d4767e88f5d0ff29ed6dffd613f335e94f0fff45e1589853b19 | EQUAL |
| `.claude/skills/parallel-close/SKILL.md` | e33091cc87dad4a835a6d6237f1b4b8d3d87896b5432b46eba1bdb67e295eb09 | e33091cc87dad4a835a6d6237f1b4b8d3d87896b5432b46eba1bdb67e295eb09 | EQUAL |
| `.claude/skills/parallel-remove/SKILL.md` | a96e8c9e4b985dbae9822762beff7caa8652b3182f853e695a6e7fd48d18840e | a96e8c9e4b985dbae9822762beff7caa8652b3182f853e695a6e7fd48d18840e | EQUAL |

Bundle paths are the source paths prefixed with `extensions/drm-copilot/resources/claude-customizations/`.
