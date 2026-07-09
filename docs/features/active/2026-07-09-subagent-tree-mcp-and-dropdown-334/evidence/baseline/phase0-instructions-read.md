# Phase 0 — Instructions Read

Timestamp: 2026-07-09T09-59

Policy Order:
1. CLAUDE.md (standing instructions; loaded via project context)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. Language/domain-specific rules for files in scope:
   - TypeScript: .claude/rules/typescript.md, .claude/rules/typescript-suppressions.md
   - PowerShell: .claude/rules/powershell.md
   - Supporting: .claude/rules/quality-tiers.md, .claude/rules/architecture-boundaries.md, .claude/rules/tonality.md

Files Read:
- CLAUDE.md (project instructions block)
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/quality-tiers.md
- .claude/rules/tonality.md
- .claude/rules/typescript.md
- .claude/rules/typescript-suppressions.md
- .claude/rules/architecture-boundaries.md
- .claude/rules/powershell.md
- .claude/rules/benchmark-baselines.md
- .claude/rules/ci-workflows.md
- .claude/rules/orchestrator-state.md

Key constraints acknowledged for this feature:
- No production file may exceed 500 lines.
- No new runtime dependency may be added (only @modelcontextprotocol/sdk today).
- New src/lib/subagent-tree/** modules must import neither `vscode` nor `node:fs`
  (RealFileTimes in src/lib/file-system.ts is the sanctioned exception).
- Coverage: >= 85% line / >= 75% branch on new files; no production file excluded
  from coverage measurement.
- Extension toolchain is Jest (recorded deviation from typescript.md Vitest/`tests/`);
  tests live under extensions/drm-copilot/test/** mirroring src/.
- Evidence artifacts are written only under <FEATURE>/evidence/<kind>/.
