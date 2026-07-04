# Epic Artifact-Type Cross-Language Consistency (P4-T7)

- Timestamp: 2026-07-02T21-35
- Command: `grep -n '"epic-orchestrator-state"' scripts/dev_tools/validate_orchestration_artifacts.py extensions/drm-copilot/src/mcp-tool-definitions.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`

## Result

The literal string `"epic-orchestrator-state"` (byte-for-byte identical, including quoting)
appears in all three files:

- `scripts/dev_tools/validate_orchestration_artifacts.py:177` — `subparsers.add_parser("epic-orchestrator-state")`
- `scripts/dev_tools/validate_orchestration_artifacts.py:221` — `if args.artifact_type == "epic-orchestrator-state":`
- `extensions/drm-copilot/src/mcp-tool-definitions.ts:394` — enum array entry
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts:189` — `case "epic-orchestrator-state": {`

All hits use the identical literal string. Cross-language artifact-type consistency confirmed.
