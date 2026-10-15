# Line Counts and Projections ([P0-T12])

Timestamp: 2026-10-09T22-07
Command: sh <SCRATCHPAD>/r.sh p0t12 (R-LINES `@(Get-Content -LiteralPath <file>).Count` for every W-FILES path, W-690-TESTS path, section 2.6.6 assertion-map path, legacy-codex-hook-contracts.Tests.ps1, the no-Python guard files, and the C2 and near-cap lists; section 3 projection for every file this plan edits)
EXIT_CODE: 0
Output Summary: every PROJECTED value is at most 500; the highest is .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 at 500 (L=496, A=4 with the section 2.2(f) headroom H=2); the two FailClosed proof files are absent (created by this plan).

Projection inputs (section 2.2 line budget A(H) = 6 + P(H) - R(H) - V(H) - H(H)):
- P(H) (distinct W-RUNTIME targets): enforce-discovery-artifact-gate 1; enforce-pr-author-skill 2; validate-discovery-artifact-gate 1; validate-orchestrator-output 3.
- R(H): enforce-parallel-worktree-removal-gate 13 (#690 region 8 lines to 1, deny block 6 lines); enforce-epic-wave-barrier 6 (comment and try, 7 lines to 1); enforce-parallel-drift-gate 8 and enforce-parallel-cohort-barrier 8 (comment and loop, 10 lines to 2); enforce-epic-merge-gate 4 and enforce-epic-worktree-removal-gate 4 (deny call and closing brace); enforce-orchestration-preimplementation-gate 2 (comment and call).
- V(H): .claude/hooks/enforce-completion-consistency.ps1 1; .claude/hooks/enforce-parallel-drift-gate.ps1 1; .codex/hooks/enforce-completion-consistency.ps1 1.
- H(H): .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 2.
- W-690 siblings L - R + n: enforce-epic-merge-gate-resolution R=37 (region 18 lines, function 18 lines plus one adjacent blank line) n=2; enforce-epic-worktree-removal-gate-resolution R=27 n=1; enforce-orchestration-preimplementation-gate-epic-scope R=31 n=4.
- Line-for-line files (projection L): the W-NONTERM file, the W-COND helper, legacy-codex-hook-contracts.Tests.ps1, and the W-690-TESTS files.

Output:

```text
LINES: .claude/hooks/check-powershell-test-purity.ps1 | 145
LINES: .claude/hooks/check-python-test-purity.ps1 | 147
LINES: .claude/hooks/enforce-checkpoint-monotonic.ps1 | 309
LINES: .claude/hooks/enforce-completion-consistency.ps1 | 465
LINES: .claude/hooks/enforce-discovery-artifact-gate.ps1 | 232
LINES: .claude/hooks/enforce-epic-invocation-origin.ps1 | 280
LINES: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 278
LINES: .claude/hooks/enforce-epic-merge-gate.ps1 | 470
LINES: .claude/hooks/enforce-epic-wave-barrier.ps1 | 380
LINES: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 262
LINES: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 459
LINES: .claude/hooks/enforce-evidence-locations.ps1 | 223
LINES: .claude/hooks/enforce-feature-folder-order.ps1 | 281
LINES: .claude/hooks/enforce-mermaid-validation.ps1 | 402
LINES: .claude/hooks/enforce-model-routing-receipt.ps1 | 295
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 302
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 470
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 496
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 468
LINES: .claude/hooks/enforce-parallel-abandon-gate.ps1 | 353
LINES: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 348
LINES: .claude/hooks/enforce-parallel-drift-gate.ps1 | 454
LINES: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 464
LINES: .claude/hooks/enforce-powershell-batch-budget.ps1 | 486
LINES: .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 429
LINES: .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 144
LINES: .claude/hooks/enforce-pr-author-skill.ps1 | 326
LINES: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 343
LINES: .claude/hooks/enforce-prd-feature-before-planner.ps1 | 477
LINES: .claude/hooks/enforce-promotion-mcp-only.ps1 | 306
LINES: .claude/hooks/enforce-python-batch-budget.ps1 | 489
LINES: .claude/hooks/hook-command-invocation.ps1 | 482
LINES: .claude/hooks/hook-command-payload.ps1 | 484
LINES: .claude/hooks/hook-command-scanner.ps1 | 400
LINES: .claude/hooks/validate-bash.ps1 | 442
LINES: .claude/hooks/validate-discovery-artifact-gate.ps1 | 257
LINES: .claude/hooks/validate-feature-review-coverage.ps1 | 459
LINES: .claude/hooks/validate-orchestrator-output.ps1 | 482
LINES: .claude/hooks/validate-planner-output.ps1 | 410
LINES: .claude/hooks/validate-pr-author-output.ps1 | 136
LINES: .claude/hooks/validate-prd-feature-output.ps1 | 91
LINES: .claude/lib/hook-payload/HookPayload.psm1 | 496
LINES: .claude/lib/mermaid/MermaidLineScanner.psm1 | 490
LINES: .claude/lib/mermaid/MermaidValidation.psm1 | 498
LINES: .claude/lib/orchestrator-state/OrchestratorState.psm1 | 492
LINES: .claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1 | 299
LINES: .claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1 | 300
LINES: .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 | 434
LINES: .claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 | 418
LINES: .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | 375
LINES: .claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1 | 368
LINES: .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 | 417
LINES: .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1 | 337
LINES: .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 | 438
LINES: .claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1 | 379
LINES: .claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1 | 168
LINES: .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 390
LINES: .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | 484
LINES: .claude/lib/worktree-resolution/WorktreeResolution.psm1 | 500
LINES: .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 497
LINES: .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 347
LINES: .codex/hooks/check-powershell-test-purity.ps1 | 166
LINES: .codex/hooks/check-python-test-purity.ps1 | 166
LINES: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 129
LINES: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 339
LINES: .codex/hooks/enforce-codex-model-routing.ps1 | 198
LINES: .codex/hooks/enforce-completion-consistency.ps1 | 486
LINES: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 334
LINES: .codex/hooks/enforce-epic-merge-gate.ps1 | 379
LINES: .codex/hooks/enforce-epic-planning-only.ps1 | 365
LINES: .codex/hooks/enforce-epic-root-invocation.ps1 | 135
LINES: .codex/hooks/enforce-epic-wave-barrier.ps1 | 295
LINES: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 184
LINES: .codex/hooks/enforce-evidence-locations.ps1 | 196
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 | 493
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 218
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 470
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 493
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 496
LINES: .codex/hooks/enforce-powershell-batch-budget.ps1 | 341
LINES: .codex/hooks/enforce-promotion-mcp-only.ps1 | 291
LINES: .codex/hooks/enforce-python-batch-budget.ps1 | 344
LINES: .codex/hooks/hook-command-invocation.ps1 | 482
LINES: .codex/hooks/hook-command-payload.ps1 | 484
LINES: .codex/hooks/hook-command-scanner.ps1 | 400
LINES: .codex/hooks/validate-bash.ps1 | 313
LINES: .codex/hooks/validate-codex-subagent-routing.ps1 | 154
LINES: .codex/hooks/validate-feature-review-coverage.ps1 | 300
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | 309
LINES: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | 255
LINES: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | 258
LINES: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | 217
LINES: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 176
LINES: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | 374
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | 279
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | 256
LINES: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | 181
LINES: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | 181
LINES: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | 191
LINES: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | 168
LINES: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 193
LINES: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | 104
LINES: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | absent (created by this plan)
LINES: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | 235
LINES: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | 249
LINES: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 488
LINES: tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1 | 500
LINES: tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1 | 82
LINES: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | 276
LINES: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | absent (created by this plan)
LINES: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 497
PROJECTED: .claude/hooks/check-powershell-test-purity.ps1 | 151 | L=145 A=6
PROJECTED: .claude/hooks/check-python-test-purity.ps1 | 153 | L=147 A=6
PROJECTED: .claude/hooks/enforce-checkpoint-monotonic.ps1 | 315 | L=309 A=6
PROJECTED: .claude/hooks/enforce-completion-consistency.ps1 | 470 | L=465 A=5
PROJECTED: .claude/hooks/enforce-discovery-artifact-gate.ps1 | 239 | L=232 A=7
PROJECTED: .claude/hooks/enforce-epic-invocation-origin.ps1 | 286 | L=280 A=6
PROJECTED: .claude/hooks/enforce-epic-merge-gate.ps1 | 472 | L=470 A=2
PROJECTED: .claude/hooks/enforce-epic-wave-barrier.ps1 | 380 | L=380 A=0
PROJECTED: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 461 | L=459 A=2
PROJECTED: .claude/hooks/enforce-evidence-locations.ps1 | 229 | L=223 A=6
PROJECTED: .claude/hooks/enforce-feature-folder-order.ps1 | 287 | L=281 A=6
PROJECTED: .claude/hooks/enforce-mermaid-validation.ps1 | 408 | L=402 A=6
PROJECTED: .claude/hooks/enforce-model-routing-receipt.ps1 | 301 | L=295 A=6
PROJECTED: .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 472 | L=468 A=4
PROJECTED: .claude/hooks/enforce-parallel-abandon-gate.ps1 | 359 | L=353 A=6
PROJECTED: .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 346 | L=348 A=-2
PROJECTED: .claude/hooks/enforce-parallel-drift-gate.ps1 | 451 | L=454 A=-3
PROJECTED: .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 457 | L=464 A=-7
PROJECTED: .claude/hooks/enforce-powershell-batch-budget.ps1 | 492 | L=486 A=6
PROJECTED: .claude/hooks/enforce-pr-author-skill.ps1 | 334 | L=326 A=8
PROJECTED: .claude/hooks/enforce-prd-feature-before-planner.ps1 | 483 | L=477 A=6
PROJECTED: .claude/hooks/enforce-promotion-mcp-only.ps1 | 312 | L=306 A=6
PROJECTED: .claude/hooks/enforce-python-batch-budget.ps1 | 495 | L=489 A=6
PROJECTED: .claude/hooks/validate-bash.ps1 | 448 | L=442 A=6
PROJECTED: .claude/hooks/validate-discovery-artifact-gate.ps1 | 264 | L=257 A=7
PROJECTED: .claude/hooks/validate-feature-review-coverage.ps1 | 465 | L=459 A=6
PROJECTED: .claude/hooks/validate-orchestrator-output.ps1 | 491 | L=482 A=9
PROJECTED: .claude/hooks/validate-planner-output.ps1 | 416 | L=410 A=6
PROJECTED: .claude/hooks/validate-pr-author-output.ps1 | 142 | L=136 A=6
PROJECTED: .claude/hooks/validate-prd-feature-output.ps1 | 97 | L=91 A=6
PROJECTED: .codex/hooks/check-powershell-test-purity.ps1 | 172 | L=166 A=6
PROJECTED: .codex/hooks/check-python-test-purity.ps1 | 172 | L=166 A=6
PROJECTED: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 345 | L=339 A=6
PROJECTED: .codex/hooks/enforce-codex-model-routing.ps1 | 204 | L=198 A=6
PROJECTED: .codex/hooks/enforce-completion-consistency.ps1 | 491 | L=486 A=5
PROJECTED: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 340 | L=334 A=6
PROJECTED: .codex/hooks/enforce-epic-merge-gate.ps1 | 385 | L=379 A=6
PROJECTED: .codex/hooks/enforce-epic-planning-only.ps1 | 371 | L=365 A=6
PROJECTED: .codex/hooks/enforce-epic-root-invocation.ps1 | 141 | L=135 A=6
PROJECTED: .codex/hooks/enforce-epic-wave-barrier.ps1 | 301 | L=295 A=6
PROJECTED: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 190 | L=184 A=6
PROJECTED: .codex/hooks/enforce-evidence-locations.ps1 | 202 | L=196 A=6
PROJECTED: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 500 | L=496 A=4
PROJECTED: .codex/hooks/enforce-powershell-batch-budget.ps1 | 347 | L=341 A=6
PROJECTED: .codex/hooks/enforce-promotion-mcp-only.ps1 | 297 | L=291 A=6
PROJECTED: .codex/hooks/enforce-python-batch-budget.ps1 | 350 | L=344 A=6
PROJECTED: .codex/hooks/validate-bash.ps1 | 319 | L=313 A=6
PROJECTED: .codex/hooks/validate-codex-subagent-routing.ps1 | 160 | L=154 A=6
PROJECTED: .codex/hooks/validate-feature-review-coverage.ps1 | 306 | L=300 A=6
PROJECTED: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 243 | L=278 R=37 n=2
PROJECTED: .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 236 | L=262 R=27 n=1
PROJECTED: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 275 | L=302 R=31 n=4
PROJECTED: .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 343 | line-for-line
PROJECTED: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 129 | line-for-line
PROJECTED: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 497 | line-for-line
PROJECTED: tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | 309 | line-for-line
PROJECTED: tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | 255 | line-for-line
PROJECTED: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 176 | line-for-line
PROJECTED: tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | 217 | line-for-line
PROJECTED: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | 256 | line-for-line
PROJECTED: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 193 | line-for-line
PROJECTED: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | 181 | line-for-line
PROJECTED: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | 168 | line-for-line
```
