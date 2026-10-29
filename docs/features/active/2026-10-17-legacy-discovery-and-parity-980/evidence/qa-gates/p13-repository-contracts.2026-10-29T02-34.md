# P13-T6 Repository and publication contracts on the final tree

Timestamp: 2026-10-29T02-34
Task: [P13-T6] Repeat repository and publication contracts on the final tree.
Command: the command-step records in this directory stamped `2026-10-29T02-34`: `p13-generator-check`, `p13-mirror-and-publication-contracts`, `p13-tier-classification`, `p13-architecture-boundaries`, `p13-packaging-closure`, `p13-source-neutrality`, `p13-file-size-and-test-io`
EXIT_CODE: 0 (every command step)
Output Summary: On the final tree (branch HEAD `24e9989cb` plus untracked P13-T5 evidence records only) every repository and publication contract passes:
- Generation and mirrors: zero generated drift (782 mirrored files identical; the 13 orphans are the same pre-existing seed-memory files as before) and no Codex variant drift.
- Contract suites: the complete `tests/scripts/dev_tools` and `tests/schemas` contract population passes (9541 passed, 6 pre-existing skips), and so do the routing and runtime-contract Pester suites (1024).
- Tier classification: 27 of 27 projects classified.
- Packaging: the staged resource hashes reproduce, and the rebuilt VSIX and npm package and the current wheel report zero closure defects.
- Architecture boundaries: the boundary and packaging Jest suites pass (5 suites, 29 tests).
- Source neutrality and file size: no consumer-specific core content, and zero branch files over 500 physical lines, including `scripts/dev_tools/agentic_sync.py` and `tests/scripts/dev_tools/test_agentic_sync.py`.
- Test I/O: no forbidden I/O in any changed test.
Result: PASS (the P11-T8 file-size deviation is closed)
