# Phase 0 — Policy Instructions Read

Timestamp: 2026-07-03T16-43

Policy Order:
1. CLAUDE.md (standing instructions, always loaded)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. .claude/rules/python.md (Python toolchain and coding standards)
5. .claude/rules/python-suppressions.md (Python suppression authorization policy)
6. .claude/rules/powershell.md (PowerShell toolchain and coding standards)
7. .claude/rules/orchestrator-state.md (checkpoint invariant prose precedent)
8. .claude/rules/quality-tiers.md (coverage thresholds: line >= 85%, branch >= 75%)
9. .claude/rules/tonality.md (required professional tone policy)

Files Read (explicit list):
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/python.md
- .claude/rules/python-suppressions.md
- .claude/rules/powershell.md
- .claude/rules/orchestrator-state.md
- .claude/rules/quality-tiers.md
- .claude/rules/tonality.md
- .claude/rules/self-explanatory-code-commenting.md (docstring/comment policy referenced by Python module authoring)

Output Summary: All required policy files read in the mandated order prior to any code or test change. No policy file was modified. Key constraints noted for this feature: additive/optional fields only; no TypeScript MCP port edits; no JSON Schema file; uniform coverage thresholds (line >= 85%, branch >= 75%); 500-line file limit; professional tone; canonical evidence path `docs/features/active/2026-07-03-two-axis-model-selection-286/evidence/<kind>/`.
