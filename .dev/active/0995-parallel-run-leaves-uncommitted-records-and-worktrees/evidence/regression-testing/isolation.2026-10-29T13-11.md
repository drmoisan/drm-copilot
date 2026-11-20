# Isolation checks

Timestamp: 2026-10-29T13-11
Command: (1) three seeded shuffled file-order Invoke-Pester runs of the 19 touched suites, seeds 995, 4242, 31337, coverage disabled; (2) pytest of test_push_down_claude_pack_manifest_completeness.py, test_push_down_claude_resource_contracts.py, test_parallel_orchestrator_surface_contracts.py in reversed order in one process; (3) the fresh single-process PoshQC Pester run over tests/scripts/claude-hooks, claude-lib, claude-runtime
EXIT_CODE: 0
Output Summary: 
- Seed 995: 496 passed, 0 failed. Order: WorktreeResolution(parallel gate), epic RelativeRecord, epic ManifestBranch, epic WorktreeResolution, parallel Issue824, WorktreeRunResolution.Record, parallel TriggerScoping, parallel EpicAuthorization, epic Issue824, parallel RelativeRecord, epic Diagnostics, WorktreeRunRecordPath, CleanupWorktreeManifestGateMatrix, parallel gate Tests, epic gate Tests, parallel-orchestrate-run-closing, WorktreeRunResolution.RelativeRecord, epic TriggerScoping, CleanupWorktreeManifest.
- Seed 4242: 496 passed, 0 failed. Order: epic ManifestBranch, epic TriggerScoping, epic Issue824, parallel TriggerScoping, epic Diagnostics, epic WorktreeResolution, parallel RelativeRecord, WorktreeRunResolution.RelativeRecord, parallel EpicAuthorization, CleanupWorktreeManifestGateMatrix, parallel Issue824, run-closing, parallel gate Tests, epic RelativeRecord, parallel WorktreeResolution, epic gate Tests, WorktreeRunRecordPath, WorktreeRunResolution.Record, CleanupWorktreeManifest.
- Seed 31337: 496 passed, 0 failed. Order: epic Diagnostics, parallel EpicAuthorization, CleanupWorktreeManifest, epic gate Tests, parallel RelativeRecord, epic Issue824, epic ManifestBranch, run-closing, WorktreeRunResolution.RelativeRecord, epic WorktreeResolution, parallel TriggerScoping, parallel gate Tests, parallel Issue824, parallel WorktreeResolution, epic RelativeRecord, epic TriggerScoping, WorktreeRunResolution.Record, WorktreeRunRecordPath, CleanupWorktreeManifestGateMatrix.
- Reversed-order Python run: 52 passed, 0 failed (forward order also 52 passed).
- Fresh single-process Pester run over the three trees: 8724 passed, 0 failed (see pester-final).
