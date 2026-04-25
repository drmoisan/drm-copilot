# Phase 5 Final QA: Hook Block Demonstration

- Timestamp: 2026-04-25T15-38
- Command: `$env:CLAUDE_TOOL_INPUT = '{"file_path":"artifacts/baselines/test.md"}'; pwsh -NoProfile -File .claude/hooks/enforce-evidence-locations.ps1`
- EXIT_CODE: 0

## Stdout JSON

```json
{"decision":"block","reason":"EVIDENCE_LOCATION_BLOCKED: 'artifacts/baselines/test.md' is not a canonical evidence location. Use <FEATURE>/evidence/<kind>/ instead. See .claude/skills/evidence-and-timestamp-conventions/SKILL.md for the canonical scheme."}
```

## Verification

- `decision` field: `"block"` ✓
- `reason` field contains `EVIDENCE_LOCATION_BLOCKED: artifacts/baselines/test.md` ✓
- EXIT_CODE: 0 ✓
