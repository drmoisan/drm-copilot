# Baseline Mirror Hashes (issue #928)

Timestamp: 2026-10-16T01-06
Command: git hash-object --no-filters <source> ; git hash-object --no-filters <mirror> (14 pairs, via SCRATCH/928/pair_hashes.sh)
EXIT_CODE: 0

Output Summary: 14 pairs recorded; all 14 IDENTICAL; no pre-existing drift.

Mirror root C = `extensions/drm-copilot/resources/claude-customizations/`; A = `extensions/drm-copilot/resources/codex-and-agents-customizations/`.

| # | Source | Source hash | Mirror | Mirror hash | Result |
| --- | --- | --- | --- | --- | --- |
| 1 | .claude/hooks/subagentstop-envelope.ps1 | 2cc85967e7755907f77ee7263298f0af7739d7aa | C/.claude/hooks/subagentstop-envelope.ps1 | 2cc85967e7755907f77ee7263298f0af7739d7aa | IDENTICAL |
| 2 | .claude/hooks/validate-discovery-artifact-gate.ps1 | cae4cc6e21a50d101e32887c2dbecb0f32942cf8 | C/.claude/hooks/validate-discovery-artifact-gate.ps1 | cae4cc6e21a50d101e32887c2dbecb0f32942cf8 | IDENTICAL |
| 3 | .claude/hooks/validate-executor-output.ps1 | fff421245f8d144d01b4e2f3f43a3c38fbbe535b | C/.claude/hooks/validate-executor-output.ps1 | fff421245f8d144d01b4e2f3f43a3c38fbbe535b | IDENTICAL |
| 4 | .claude/hooks/validate-feature-review-coverage.ps1 | 50edc3294e0e8595d27397bb70b66a5c794bdbd1 | C/.claude/hooks/validate-feature-review-coverage.ps1 | 50edc3294e0e8595d27397bb70b66a5c794bdbd1 | IDENTICAL |
| 5 | .claude/hooks/validate-orchestrator-output.ps1 | 0b8f6f541a3ebf36bc90740684d61ba6d5f7dde7 | C/.claude/hooks/validate-orchestrator-output.ps1 | 0b8f6f541a3ebf36bc90740684d61ba6d5f7dde7 | IDENTICAL |
| 6 | .claude/hooks/validate-planner-output.ps1 | e8c93c8e26e86a1639d17497aa9370337520e275 | C/.claude/hooks/validate-planner-output.ps1 | e8c93c8e26e86a1639d17497aa9370337520e275 | IDENTICAL |
| 7 | .claude/hooks/validate-pr-author-output.ps1 | 78ac52ff9fa5fe153aae86f3210b8f10eabd27db | C/.claude/hooks/validate-pr-author-output.ps1 | 78ac52ff9fa5fe153aae86f3210b8f10eabd27db | IDENTICAL |
| 8 | .claude/hooks/validate-prd-feature-output.ps1 | 9f3ff43cf9c714d535690287f51df6eacd25d6b2 | C/.claude/hooks/validate-prd-feature-output.ps1 | 9f3ff43cf9c714d535690287f51df6eacd25d6b2 | IDENTICAL |
| 9 | .claude/hooks/validate-required-artifact-output.ps1 | 8d77d94a93adcdae8b220f2f8eed211a4e69fbc3 | C/.claude/hooks/validate-required-artifact-output.ps1 | 8d77d94a93adcdae8b220f2f8eed211a4e69fbc3 | IDENTICAL |
| 10 | .claude/hooks/validate-task-researcher-output.ps1 | 84919e34b9fa65c176a436a1e178d29532420e65 | C/.claude/hooks/validate-task-researcher-output.ps1 | 84919e34b9fa65c176a436a1e178d29532420e65 | IDENTICAL |
| 11 | .claude/hooks/enforce-epic-wave-barrier.ps1 | 2dae0884ab120232006cc1b2074521862fbace10 | C/.claude/hooks/enforce-epic-wave-barrier.ps1 | 2dae0884ab120232006cc1b2074521862fbace10 | IDENTICAL |
| 12 | .claude/skills/epic-orchestrate/SKILL.md | 7a21440358463eabc98f7a6c874e96a87be6d357 | C/.claude/skills/epic-orchestrate/SKILL.md | 7a21440358463eabc98f7a6c874e96a87be6d357 | IDENTICAL |
| 13 | .claude/agents/epic-orchestrator.md | 1bda9c9ee54345665ae94dec4ce6d35f2ed72992 | C/.claude/agents/epic-orchestrator.md | 1bda9c9ee54345665ae94dec4ce6d35f2ed72992 | IDENTICAL |
| 14 | .agents/skills/translate-claude-to-codex/SKILL.md | 52b8c917d4c31b6cdb16617aed9b9ffb9725465b | A/.agents/skills/translate-claude-to-codex/SKILL.md | 52b8c917d4c31b6cdb16617aed9b9ffb9725465b | IDENTICAL |
