# Bundle Mirror Parity (issue #1006)

Timestamp: 2026-10-31T08-30
Task: P7-T1
Command: sh SCRATCH/issue-1006-mirror.sh (cp each source file to BUNDLE/<same path>; sha256sum both)
EXIT_CODE: 0
Output Summary: six pairs, all EQUAL. BUNDLE = `extensions/drm-copilot/resources/claude-customizations`.

| File | Source SHA-256 | Bundle SHA-256 |
|---|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 86a88b5cd5f196adb7cdd29a32b6479f7185d502bc68c40f5a5895264e246261 | 86a88b5cd5f196adb7cdd29a32b6479f7185d502bc68c40f5a5895264e246261 |
| .claude/lib/blast-radius/BlastRadiusExtraction.psm1 | 96252b9c2c391496de5ec3f2864068cb853a88eedcf9822f1dd330a23bde8b21 | 96252b9c2c391496de5ec3f2864068cb853a88eedcf9822f1dd330a23bde8b21 |
| .claude/lib/blast-radius/BlastRadiusNormalization.psm1 | 141d3f611c021a8536e881f636521171a4bde59b9c86b502ca45ac0e25d7c549 | 141d3f611c021a8536e881f636521171a4bde59b9c86b502ca45ac0e25d7c549 |
| .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 66a41446f91c2c9e2e6ddfb1912cb9d312a1b10760dd4ada116c354f7fa1f675 | 66a41446f91c2c9e2e6ddfb1912cb9d312a1b10760dd4ada116c354f7fa1f675 |
| .claude/lib/blast-radius/BlastRadius.psm1 | 966b0212240ba8a99f302bfc28986c0f03995be5179d40d91bd187b746eed219 | 966b0212240ba8a99f302bfc28986c0f03995be5179d40d91bd187b746eed219 |
| .claude/rules/parallel-orchestration.md | c11e8594bcce79a6821c8e322dbc38d9850c2c0ea3881da59ec0b8edd39618b9 | c11e8594bcce79a6821c8e322dbc38d9850c2c0ea3881da59ec0b8edd39618b9 |
