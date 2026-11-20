# Mirror Hashes (after the loop-2 module change)

Timestamp: 2026-11-03T14-22
Task: [P6-T3] re-verification during the Phase 8 loop
Command: sha256sum over each primary and its bundle copy under extensions/drm-copilot/resources/claude-customizations/
EXIT_CODE: 0
Output Summary: 11 of 11 SHA256 pairs match after the ParallelAdmissionPrecedence.psm1 change of the Phase 8 loop (pass 2); this record supersedes mirror-hashes.2026-11-03T13-37.md for that file.

| Primary | Primary SHA256 | Bundle SHA256 | Result |
| --- | --- | --- | --- |
| .claude/skills/parallel-add/SKILL.md | 8043899f7c6ff20cb45f5d76d2b8e54034252b9e88c4efee86176e6194a6f098 | 8043899f7c6ff20cb45f5d76d2b8e54034252b9e88c4efee86176e6194a6f098 | MATCH |
| .claude/skills/parallel-plan/SKILL.md | 6a77bfbede7e3da0db97f83d5fb39d643b5d767d15674b645247d160ae8b8088 | 6a77bfbede7e3da0db97f83d5fb39d643b5d767d15674b645247d160ae8b8088 | MATCH |
| .claude/skills/parallel-orchestrate/SKILL.md | 96b8663e224dcb4913fb146b75aa24a2d5c4378bc0ad4e76b97bcfdc480b8b84 | 96b8663e224dcb4913fb146b75aa24a2d5c4378bc0ad4e76b97bcfdc480b8b84 | MATCH |
| .claude/rules/parallel-orchestration.md | 3614c6de31587646146947b3e0140207edf0c7ec0383f883c37bb5e252f25fc0 | 3614c6de31587646146947b3e0140207edf0c7ec0383f883c37bb5e252f25fc0 | MATCH |
| .claude/agents/parallel-planner.md | f9d8c6b52618a186691f75d1b878433289c3409ceb1a41f136276b32a6a07548 | f9d8c6b52618a186691f75d1b878433289c3409ceb1a41f136276b32a6a07548 | MATCH |
| .claude/agents/parallel-orchestrator.md | ce78b680ec4738b3e8d59212696ffe4d378df5c55f2cd7d64722fd0ce3fdfd2c | ce78b680ec4738b3e8d59212696ffe4d378df5c55f2cd7d64722fd0ce3fdfd2c | MATCH |
| .claude/settings.json | 0e915397f1a93e292b54c7bec79ba52ca08101e2dc6d5043ec560d45c0c1dc61 | 0e915397f1a93e292b54c7bec79ba52ca08101e2dc6d5043ec560d45c0c1dc61 | MATCH |
| .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1 | cd065d41ae3ff1b9053433a7236c01739009becdad10324d530fe4f019304358 | cd065d41ae3ff1b9053433a7236c01739009becdad10324d530fe4f019304358 | MATCH |
| .claude/lib/parallel-admission/ParallelAdmission.psm1 | fddb9a9063cbca48ab2864257e039bef7a11df0ed94334350ace9db78e192362 | fddb9a9063cbca48ab2864257e039bef7a11df0ed94334350ace9db78e192362 | MATCH |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 0f1c3f690cf0fa67ac19df440006699296992c720b426782779a10f3792603a9 | 0f1c3f690cf0fa67ac19df440006699296992c720b426782779a10f3792603a9 | MATCH |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | dfb1c3c654320e584cd5b2db3c10986f3c25983f88a2e5453c4993a38c2ca50e | dfb1c3c654320e584cd5b2db3c10986f3c25983f88a2e5453c4993a38c2ca50e | MATCH |
