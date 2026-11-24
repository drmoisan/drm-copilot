# Codex bundle byte parity (P2-T6)

Timestamp: 2026-11-24T13-40
Command: cp of the three .agents files to the matching paths under extensions/drm-copilot/resources/codex-and-agents-customizations/, then sha256sum of each pair and a CR count per source file
EXIT_CODE: 0
Output Summary: SHA-256 pairs equal. documentation-workflow/SKILL.md 920678a9549f291299c390e6d02f42c3e505ef0374b1319b1b9097f497fa3623; documentation-workflow/references/standard.md 6ff8d2bbac1110ef7188852c309fe5ae48229ca4108355311a2840991d215c8c; execution-environment/SKILL.md 37ffd4d2853c71a1bf6e3c96d60cf114a2e18ec7d0efdb61932c219621820a4c. CR count 0 in each file (no CRLF). The push-down and pack-manifest contract tests run in the P2-T7 gate.
