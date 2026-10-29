# Mirror Parity (issue #997)

Timestamp: 2026-10-29T16-35
Command: sh SCRATCH/issue-997-mirror.sh (cp of each file to extensions/drm-copilot/resources/claude-customizations/<same path>, then sha256sum of source and copy); git status --porcelain
EXIT_CODE: 0
Output Summary: six pairs, all equal; `git status --porcelain` lists `?? extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` and the five modified bundle copies.

| File | Source SHA-256 | Bundle SHA-256 | Result |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | b3300da389af029f3acc0faad2993923ddf5181db4012ba9d864211a6fe52587 | b3300da389af029f3acc0faad2993923ddf5181db4012ba9d864211a6fe52587 | EQUAL |
| `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` | 3f998c583a87ba034fc843e6fd5a4ddec843b78e2246041285ead496df26c854 | 3f998c583a87ba034fc843e6fd5a4ddec843b78e2246041285ead496df26c854 | EQUAL |
| `.claude/skills/orchestrate/SKILL.md` | 3d445e57f8c05e1f13eeff58580581a884a69262faf9ecc37f4379ba727833bc | 3d445e57f8c05e1f13eeff58580581a884a69262faf9ecc37f4379ba727833bc | EQUAL |
| `.claude/skills/parallel-orchestrate/SKILL.md` | fe6c53caf9b3267144a4c2fd1fde2198c639db052b42f487a7ce23de4e7b2c7f | fe6c53caf9b3267144a4c2fd1fde2198c639db052b42f487a7ce23de4e7b2c7f | EQUAL |
| `.claude/rules/orchestrator-state.md` | f8398cb3c44eb17a55e47f9b2d3134c7f8067a2d6225747634488ab9734ac501 | f8398cb3c44eb17a55e47f9b2d3134c7f8067a2d6225747634488ab9734ac501 | EQUAL |
| `.claude/rules/parallel-orchestration.md` | 1ac52fd1e551386b6374e87dbec7b37bb5ed6425ace0d2d534cec7af767076a5 | 1ac52fd1e551386b6374e87dbec7b37bb5ed6425ace0d2d534cec7af767076a5 | EQUAL |

Note: these hashes describe the files at this write; a later toolchain change that alters a mirrored file reruns this step and writes a new artifact.
