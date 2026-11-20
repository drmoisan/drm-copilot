# GitHub-Native Inventory Comparison ([P2-T6])

Timestamp: 2026-11-19T12-00
Plan: plan.2026-10-30T18-39.md
Command: sh SCRATCH/issue-1032-invcmp.sh (git ls-files .github/prompts .github/hooks .github/agents with git hash-object per file, diffed against the path and hash list of github-native-inventory.2026-11-19T07-51.md)
EXIT_CODE: 0
Output Summary: 86 files at Phase 0 and 86 now. `.github/prompts` (30 files) and `.github/hooks` (6 files) are identical in path and hash, so no child 5 difference applies. Of the 50 `.github/agents` files, exactly the four `READ-FIRST-AGENTS` files differ in hash (P1-T8 read-first repoint); the other 46 hashes equal Phase 0. (The comparison diff exits 1 because of those four expected differences.)

| File | Phase 0 hash | Current hash |
| --- | --- | --- |
| `.github/agents/atomic_executor.agent.md` | b1bb7b3c270ee259e216f455cc6dd005813e217d | 941f334916123a7ed245ef74e502779b95f757e8 |
| `.github/agents/atomic_planning.agent.md` | 7fbfab4bb1469246bf856a5ecb027ed4a821b271 | 75c3efce133e5c08c9e0943a1cea65e9ba3a97d8 |
| `.github/agents/orchestrator.agent.md` | 44c0ce9c585fa2e0ac43c9560bf08f8ef874025d | 8399203c8af18f687a47f9cb25a85bc4afc62aca |
| `.github/agents/task-researcher.agent.md` | 63e94bb14aee716d61a7c105c731df44a2d05bbc | 9d732f74428aaee59b06f66cca15cd08fa22b726 |
