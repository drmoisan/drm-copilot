# Cycle 1 Root/Bundle Registration and Byte Parity

Timestamp: `2026-08-15T00:34:00-04:00`

Plan task: `[P5-T19]`

Command: enumerate every file below root `.codex/` and `.agents/`, excluding runtime `.codex/state/**`, enumerate the corresponding files below `extensions/drm-copilot/resources/codex-and-agents-customizations/`, hash each file with SHA-256, and compare the complete path and byte maps.

- EXIT_CODE: `0`
- Root source files: `237`.
- Bundle files: `237`.
- Byte-identical matches: `237/237`.
- Missing paths: `0`.
- Extra paths: `0`.
- Mismatched paths: `0`.
- Root sorted path/SHA-256 inventory digest: `E2485AB43C74C471B6455BD55337B71FD64655F2242E22537C2769C63BBAA850`.
- Registration parity: root `.codex/config.toml`, all registered hook targets, profiles, and shared skills are included in the identical 237-path comparison; the focused registration and publisher tests also passed under P5-T15.

Acceptance result: `PASS`.
