# P16-T5 Seeded shuffled Jest runs, seed 1616 (extension and root)

Timestamp: 2026-10-30T01-45
Task: [P16-T5] Run the isolation checks on the remediated tree.
Command: node run-jest.cjs --randomize --seed=1616 (in extensions/drm-copilot, the full extension population including every Phase 15 TypeScript suite); node run-jest.cjs --randomize --seed=1616 (worktree root, the full root population)
EXIT_CODE: 0 (extension), 0 (root)
Output Summary: Extension: "Seed: 1616"; 321 suites passed of 321, 5177 tests passed of 5177, 0 failed, matching the in-order coverage run in `evidence/qa-gates/p16-typescript-extension-tests.2026-10-30T01-40.md`. Root: "Seed: 1616"; 324 suites passed of 324, 5194 tests passed of 5194, 0 failed, matching `evidence/qa-gates/p16-typescript-root-tests.2026-10-30T01-40.md`. The randomized test order exposed no order dependence in either project.
Result: PASS
