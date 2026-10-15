# Remediation Cycle 2 AC-24 Per-Surface Measurement ([P3-T4], r1 rule 10)

Timestamp: 2026-10-10T21-23
Pass: 1
Command: git checks of r1 [P3-T6] (a); sh <SCRATCHPAD>/r.sh r1-p3t6-prep ((b) parse and (c) file lists); sh <SCRATCHPAD>/r.sh r2-parse -Names r1-covprobe2.ps1,r1-ac24-cur.ps1; sh <SCRATCHPAD>/r.sh r1-ac24-cur -Label h2-ac24-cur-r2-pass1 ((d) R-COVPROBE, hosting H2, list <SCRATCHPAD>/h2-ac24-cur-r2-pass1.list); (e) BASE extraction and BASE probe reused; sh <SCRATCHPAD>/r.sh r1-ac24 -Current <SCRATCHPAD>/r1-probe-h2-ac24-cur-r2-pass1-coverage.xml -Base <SCRATCHPAD>/r1-probe-h2-ac24-base-coverage.xml -FileList <SCRATCHPAD>/r1-ac24-files.list -JudgedList <SCRATCHPAD>/r1-ac24-psset.list ((f)); all route sh, fresh processes
EXIT_CODE: 0
Output Summary: PS-SET (judged): .codex/hooks/enforce-epic-child-worktree-binding.ps1 per-surface 95.78 / base-surface 95.62; .codex/hooks/enforce-epic-planning-only.ps1 per-surface 95.86 / base-surface 95.71; .codex/hooks/hook-dependency-guard.ps1 per-surface 100.00 / base-surface new file; .codex/hooks/validate-bash.ps1 per-surface 100.00 / base-surface 100.00; .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 per-surface 100.00 / base-surface 100.00; .codex/hooks/enforce-epic-merge-gate.ps1 per-surface 98.73 / base-surface 98.68. PER-SURFACE-RESULT: pass. Current-tree probe PROBE: h2-ac24-cur-r2-pass1 | containers=61 | passed=1652 | failed=0.

## Pass 1

HEAD_SHA: b054e8a59d90aeeca486893468e2b80205d17abb
GIT-VERSION: git version 2.53.0.windows.1

### (a) Currency and hosting

Command: git diff --name-only df0965aeaa8a3905fe4966fcbb4b49143d566941 HEAD -- .claude/hooks .claude/lib .codex tests scripts/powershell/PoshQC config/poshqc-coverage.json config/poshqc-scan.json
Output: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1; tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1; tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1; tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1; tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1; tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1; tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
Command: git status --porcelain -- .claude/hooks .claude/lib .codex tests scripts/powershell/PoshQC config/poshqc-coverage.json config/poshqc-scan.json
Output: (empty)
XS-REUSABLE: no | remediation cycle 2 re-run
Command: git diff --name-only 86e457a003be0c60b65e01156e4cccd6495dfd1a HEAD -- scripts/powershell/PoshQC config/poshqc-coverage.json config/poshqc-scan.json
Output: (empty)
Command: git status --porcelain -- scripts/powershell/PoshQC config/poshqc-coverage.json config/poshqc-scan.json
Output: (empty)
BASE-HOSTING-IDENTICAL: yes

### (b) Scripts

PROBE-SCRIPT: reused
PARSE: <SCRATCHPAD>/r1-ac24-base.ps1 | 0
PARSE: <SCRATCHPAD>/r1-ac24.ps1 | 0
PARSE: <SCRATCHPAD>/r1-p3t6-prep.ps1 | 0
PARSE: r1-covprobe2.ps1 | 0
PARSE: r1-ac24-cur.ps1 | 0

### (c) File lists

```
text
W-CHANGED-PROD-COUNT: 57
CODEX-CHANGED-PROD-COUNT: 21
CODEX-CHANGED-PROD: .codex/hooks/check-powershell-test-purity.ps1
CODEX-CHANGED-PROD: .codex/hooks/check-python-test-purity.ps1
CODEX-CHANGED-PROD: .codex/hooks/codex-epic-child-launch-attestation.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-checkpoint-monotonic.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-codex-model-routing.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-completion-consistency.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-epic-child-worktree-binding.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-epic-merge-gate.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-epic-planning-only.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-epic-root-invocation.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-epic-wave-barrier.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-epic-worktree-removal-gate.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-evidence-locations.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-powershell-batch-budget.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-promotion-mcp-only.ps1
CODEX-CHANGED-PROD: .codex/hooks/enforce-python-batch-budget.ps1
CODEX-CHANGED-PROD: .codex/hooks/hook-dependency-guard.ps1
CODEX-CHANGED-PROD: .codex/hooks/validate-bash.ps1
CODEX-CHANGED-PROD: .codex/hooks/validate-codex-subagent-routing.ps1
CODEX-CHANGED-PROD: .codex/hooks/validate-feature-review-coverage.ps1
PS-SET-COUNT: 6
PS-SET: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | in-files-list=yes
PS-SET: .codex/hooks/enforce-epic-planning-only.ps1 | in-files-list=yes
PS-SET: .codex/hooks/hook-dependency-guard.ps1 | in-files-list=yes
PS-SET: .codex/hooks/validate-bash.ps1 | in-files-list=yes
PS-SET: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | in-files-list=yes
PS-SET: .codex/hooks/enforce-epic-merge-gate.ps1 | in-files-list=yes
```

### (d) Current tree

CURRENT-SOURCE: run h2-ac24-cur-r2-pass1
POPULATION-MATCH: met (POPULATION-LINE: Code coverage population: source=config; files=192; control `Covered line: Covered 87.07% / 0%. 25,713 analyzed Commands in 192 Files.`, evidence/baseline/r2-pester-coverage.md [P0-T8])

```
text
S-CURRENT-COUNT: 61
S-CURRENT: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/epic-provenance.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
S-CURRENT: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
S-CURRENT-MATCHES-C0: yes
S-CURRENT-SET-EQUALS-C0: yes
Scan configuration 'config/poshqc-scan.json' folder 'tests/powershell' does not exist under root '<WORKSPACE_ROOT>'; skipping.
Code coverage population: source=config; files=192

Starting discovery in 61 files.
Discovery found 1652 tests in 1.85s.
Starting code coverage.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1
 897ms (484ms|298ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1
 203ms (102ms|68ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1
 14.52s (14.48s|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1
 227ms (167ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1
 387ms (336ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1
 127ms (91ms|25ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1
 662ms (612ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1
 350ms (237ms|88ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1
 112ms (44ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1
 265ms (183ms|62ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1
 282ms (167ms|75ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1
 619ms (518ms|76ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1
 198ms (115ms|55ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1
 32.06s (32.02s|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1
 25.6s (25.53s|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1
 234ms (154ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1
 322ms (220ms|56ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1
 192ms (122ms|49ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1
 334ms (282ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1
 124ms (80ms|30ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1
 175ms (100ms|58ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1
 137ms (88ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1
 106ms (47ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1
 116ms (73ms|29ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1
 699ms (630ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1
 289ms (230ms|38ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1
 345ms (290ms|40ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1
 187ms (136ms|37ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1
 377ms (301ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
 518ms (437ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1
 1.35s (1.26s|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
 268ms (219ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
 3.84s (3.67s|127ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
 645ms (496ms|108ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
 869ms (806ms|43ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
 1.21s (1.09s|96ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
 350ms (261ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
 311ms (211ms|70ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
 217ms (150ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
 207ms (173ms|22ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
 828ms (754ms|53ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1
 372ms (289ms|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
 254ms (194ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1
 128ms (79ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1
 376ms (323ms|35ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1
 234ms (165ms|48ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1
 4.62s (4.53s|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-provenance.Tests.ps1
 273ms (204ms|50ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1
 182ms (137ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1
 213ms (104ms|80ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1
 412ms (318ms|57ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1
 243ms (132ms|82ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1
 4.15s (3.62s|116ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1
 103ms (54ms|33ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1
 394ms (336ms|46ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1
 12.01s (11.93s|60ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1
 146ms (104ms|28ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1
 532ms (443ms|61ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1
 199ms (153ms|32ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1
 214ms (154ms|44ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1
 437ms (354ms|56ms)
Tests completed in 116.32s
Tests Passed: 1652, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
Processing code coverage result.
Covered 24.8% / 0%. 25,713 analyzed Commands in 192 Files.
PROBE: h2-ac24-cur-r2-pass1 | containers=61 | passed=1652 | failed=0
POPULATION-LINE: Code coverage population: source=config; files=192
ORDER: 1 | tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
ORDER: 2 | tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1
ORDER: 3 | tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1
ORDER: 4 | tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1
ORDER: 5 | tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1
ORDER: 6 | tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1
ORDER: 7 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
ORDER: 8 | tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
ORDER: 9 | tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
ORDER: 10 | tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
ORDER: 11 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ORDER: 12 | tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
ORDER: 13 | tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1
ORDER: 14 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
ORDER: 15 | tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
ORDER: 16 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
ORDER: 17 | tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1
ORDER: 18 | tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
ORDER: 19 | tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1
ORDER: 20 | tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1
ORDER: 21 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1
ORDER: 22 | tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1
ORDER: 23 | tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1
ORDER: 24 | tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1
ORDER: 25 | tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1
ORDER: 26 | tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1
ORDER: 27 | tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
ORDER: 28 | tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1
ORDER: 29 | tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1
ORDER: 30 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
ORDER: 31 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
ORDER: 32 | tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
ORDER: 33 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
ORDER: 34 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1
ORDER: 35 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
ORDER: 36 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1
ORDER: 37 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1
ORDER: 38 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
ORDER: 39 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
ORDER: 40 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1
ORDER: 41 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
ORDER: 42 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1
ORDER: 43 | tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1
ORDER: 44 | tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1
ORDER: 45 | tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
ORDER: 46 | tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
ORDER: 47 | tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
ORDER: 48 | tests/scripts/codex-hooks/epic-provenance.Tests.ps1
ORDER: 49 | tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1
ORDER: 50 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1
ORDER: 51 | tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1
ORDER: 52 | tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
ORDER: 53 | tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1
ORDER: 54 | tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1
ORDER: 55 | tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
ORDER: 56 | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
ORDER: 57 | tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1
ORDER: 58 | tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1
ORDER: 59 | tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
ORDER: 60 | tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1
ORDER: 61 | tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1 | passed=55 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-child-launch-attestation.Coverage.Tests.ps1 | passed=4 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | passed=10 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | passed=38 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | passed=51 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | passed=34 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | passed=36 | failed=0
CONTAINER: tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-codex-model-routing.Coverage.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1 | passed=7 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1 | passed=16 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1 | passed=13 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-root-invocation.Coverage.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed=21 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed=41 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed=6 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed=120 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed=49 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed=14 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed=54 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed=26 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed=56 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed=3 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed=24 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | passed=18 | failed=0
CONTAINER: tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | passed=19 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | passed=22 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | passed=50 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | passed=29 | failed=0
CONTAINER: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | passed=61 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | passed=39 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | passed=46 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed=75 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed=5 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | passed=43 | failed=0
CONTAINER: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | passed=9 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | passed=37 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | passed=8 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-codex-subagent-routing.Coverage.Tests.ps1 | passed=17 | failed=0
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | passed=29 | failed=0
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | passed
INTERCEPTION-ROW: tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | passed
ORDER-PRESERVED: yes
```

### (e) BASE tree

BASE-EXTRACTION: reused (<SCRATCHPAD>/r1-base/scripts/powershell/PoshQC/PoshQC.psd1 present)
BASE-XML: reused (<SCRATCHPAD>/r1-probe-h2-ac24-base-coverage.xml present; recorded output of the r1 [P3-T6] (e) BASE probe below)
BASE-POPULATION-LINE: Code coverage population: source=config; files=190

ROOT-IS-EXTRACTION: yes
S-BASE-COUNT: 52
PROBE: h2-ac24-base | containers=52 | passed=1465 | failed=0
POPULATION-LINE: Code coverage population: source=config; files=190
ORDER-PRESERVED: yes

### (f) r1-ac24.ps1 output

```
text
PER-SURFACE: .codex/hooks/check-powershell-test-purity.ps1 | 100.00 | covered=68 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/check-powershell-test-purity.ps1 | 100.00 | covered=62 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/check-powershell-test-purity.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/check-powershell-test-purity.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/check-powershell-test-purity.ps1:35 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-powershell-test-purity.ps1:39 | post-ci=3 | base-line=38 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-powershell-test-purity.ps1:76 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-powershell-test-purity.ps1:77 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-powershell-test-purity.ps1:151 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-powershell-test-purity.ps1:152 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-powershell-test-purity.ps1:153 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/check-powershell-test-purity.ps1 | covered=7 | total=7 | scope=informational
PER-SURFACE: .codex/hooks/check-python-test-purity.ps1 | 100.00 | covered=73 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/check-python-test-purity.ps1 | 100.00 | covered=67 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/check-python-test-purity.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/check-python-test-purity.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/check-python-test-purity.ps1:32 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-python-test-purity.ps1:36 | post-ci=3 | base-line=35 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-python-test-purity.ps1:73 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-python-test-purity.ps1:74 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-python-test-purity.ps1:151 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-python-test-purity.ps1:152 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/check-python-test-purity.ps1:153 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/check-python-test-purity.ps1 | covered=7 | total=7 | scope=informational
PER-SURFACE: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 98.48 | covered=65 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 77.27 | covered=51 | missed=15 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/codex-epic-child-launch-attestation.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/codex-epic-child-launch-attestation.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/codex-epic-child-launch-attestation.ps1:5 | post-ci=2 | base-line=5 | base-ci=1 | covered | scope=informational
CHANGED-LINES: .codex/hooks/codex-epic-child-launch-attestation.ps1 | covered=1 | total=1 | scope=informational
PER-SURFACE: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 99.09 | covered=109 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 99.04 | covered=103 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-checkpoint-monotonic.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-checkpoint-monotonic.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-checkpoint-monotonic.ps1:46 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-checkpoint-monotonic.ps1:50 | post-ci=3 | base-line=49 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-checkpoint-monotonic.ps1:218 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-checkpoint-monotonic.ps1:219 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-checkpoint-monotonic.ps1:318 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-checkpoint-monotonic.ps1:319 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-checkpoint-monotonic.ps1:320 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-checkpoint-monotonic.ps1 | covered=7 | total=7 | scope=informational
PER-SURFACE: .codex/hooks/enforce-codex-model-routing.ps1 | 100.00 | covered=78 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-codex-model-routing.ps1 | 56.94 | covered=41 | missed=31 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-codex-model-routing.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-codex-model-routing.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-codex-model-routing.ps1:7 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-codex-model-routing.ps1:9 | post-ci=3 | base-line=8 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-codex-model-routing.ps1:10 | post-ci=3 | base-line=9 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-codex-model-routing.ps1:95 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-codex-model-routing.ps1:96 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-codex-model-routing.ps1:156 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-codex-model-routing.ps1:157 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-codex-model-routing.ps1:158 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-codex-model-routing.ps1 | covered=8 | total=8 | scope=informational
PER-SURFACE: .codex/hooks/enforce-completion-consistency.ps1 | 100.00 | covered=153 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-completion-consistency.ps1 | 100.00 | covered=148 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-completion-consistency.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-completion-consistency.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-completion-consistency.ps1:48 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-completion-consistency.ps1:52 | post-ci=3 | base-line=51 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-completion-consistency.ps1:58 | post-ci=3 | base-line=57 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-completion-consistency.ps1:62 | post-ci=3 | base-line=61 | base-ci=1 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-completion-consistency.ps1:386 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-completion-consistency.ps1:387 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-completion-consistency.ps1:467 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-completion-consistency.ps1:468 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-completion-consistency.ps1:469 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-completion-consistency.ps1 | covered=9 | total=9 | scope=informational
PER-SURFACE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.78 | covered=159 | missed=7 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 95.62 | covered=153 | missed=7 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | met | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:13 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:17 | post-ci=2 | base-line=16 | base-ci=1 | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:222 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:223 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:288 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:289 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-child-worktree-binding.ps1:290 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINES: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | covered=7 | total=7 | scope=judged
PER-SURFACE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.73 | covered=155 | missed=2 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.68 | covered=149 | missed=2 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/enforce-epic-merge-gate.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/enforce-epic-merge-gate.ps1 | met | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:7 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:12 | post-ci=3 | base-line=11 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:13 | post-ci=3 | base-line=12 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:131 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:132 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:366 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:367 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-merge-gate.ps1:368 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINES: .codex/hooks/enforce-epic-merge-gate.ps1 | covered=8 | total=8 | scope=judged
PER-SURFACE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.86 | covered=162 | missed=7 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/enforce-epic-planning-only.ps1 | 95.71 | covered=156 | missed=7 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/enforce-epic-planning-only.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/enforce-epic-planning-only.ps1 | met | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-planning-only.ps1:12 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-planning-only.ps1:213 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-planning-only.ps1:214 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-planning-only.ps1:331 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-planning-only.ps1:332 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-epic-planning-only.ps1:333 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINES: .codex/hooks/enforce-epic-planning-only.ps1 | covered=6 | total=6 | scope=judged
PER-SURFACE: .codex/hooks/enforce-epic-root-invocation.ps1 | 100.00 | covered=56 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-epic-root-invocation.ps1 | 40.00 | covered=20 | missed=30 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-epic-root-invocation.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-epic-root-invocation.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-root-invocation.ps1:11 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-root-invocation.ps1:13 | post-ci=3 | base-line=12 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-root-invocation.ps1:58 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-root-invocation.ps1:59 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-root-invocation.ps1:93 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-root-invocation.ps1:94 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-root-invocation.ps1:95 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-epic-root-invocation.ps1 | covered=7 | total=7 | scope=informational
PER-SURFACE: .codex/hooks/enforce-epic-wave-barrier.ps1 | 95.68 | covered=133 | missed=6 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-epic-wave-barrier.ps1 | 65.41 | covered=87 | missed=46 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-epic-wave-barrier.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-epic-wave-barrier.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-wave-barrier.ps1:13 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-wave-barrier.ps1:15 | post-ci=3 | base-line=14 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-wave-barrier.ps1:182 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-wave-barrier.ps1:183 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-wave-barrier.ps1:258 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-wave-barrier.ps1:259 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-wave-barrier.ps1:260 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-epic-wave-barrier.ps1 | covered=7 | total=7 | scope=informational
PER-SURFACE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.72 | covered=77 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.61 | covered=71 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:7 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:12 | post-ci=3 | base-line=11 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:13 | post-ci=3 | base-line=12 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:84 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:85 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:169 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:170 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-epic-worktree-removal-gate.ps1:171 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | covered=8 | total=8 | scope=informational
PER-SURFACE: .codex/hooks/enforce-evidence-locations.ps1 | 100.00 | covered=47 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-evidence-locations.ps1 | 100.00 | covered=41 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-evidence-locations.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-evidence-locations.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-evidence-locations.ps1:43 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-evidence-locations.ps1:47 | post-ci=3 | base-line=46 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-evidence-locations.ps1:126 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-evidence-locations.ps1:127 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-evidence-locations.ps1:198 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-evidence-locations.ps1:199 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-evidence-locations.ps1:200 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-evidence-locations.ps1 | covered=7 | total=7 | scope=informational
PER-SURFACE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=171 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 100.00 | covered=165 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | met | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:14 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:18 | post-ci=3 | base-line=18 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:23 | post-ci=3 | base-line=23 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:29 | post-ci=3 | base-line=29 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32 | post-ci=3 | base-line=32 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:34 | post-ci=3 | base-line=34 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:35 | post-ci=3 | base-line=35 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:366 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:367 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:466 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:467 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:468 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | covered=12 | total=12 | scope=judged
PER-SURFACE: .codex/hooks/enforce-powershell-batch-budget.ps1 | 99.05 | covered=104 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-powershell-batch-budget.ps1 | 98.99 | covered=98 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-powershell-batch-budget.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-powershell-batch-budget.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-powershell-batch-budget.ps1:48 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-powershell-batch-budget.ps1:52 | post-ci=3 | base-line=51 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-powershell-batch-budget.ps1:55 | post-ci=3 | base-line=54 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-powershell-batch-budget.ps1:138 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-powershell-batch-budget.ps1:139 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-powershell-batch-budget.ps1:336 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-powershell-batch-budget.ps1:337 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-powershell-batch-budget.ps1:338 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-powershell-batch-budget.ps1 | covered=8 | total=8 | scope=informational
PER-SURFACE: .codex/hooks/enforce-promotion-mcp-only.ps1 | 100.00 | covered=71 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-promotion-mcp-only.ps1 | 100.00 | covered=65 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-promotion-mcp-only.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-promotion-mcp-only.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-promotion-mcp-only.ps1:31 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-promotion-mcp-only.ps1:36 | post-ci=3 | base-line=35 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-promotion-mcp-only.ps1:37 | post-ci=3 | base-line=36 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-promotion-mcp-only.ps1:231 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-promotion-mcp-only.ps1:232 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-promotion-mcp-only.ps1:282 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-promotion-mcp-only.ps1:283 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-promotion-mcp-only.ps1:284 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-promotion-mcp-only.ps1 | covered=8 | total=8 | scope=informational
PER-SURFACE: .codex/hooks/enforce-python-batch-budget.ps1 | 99.05 | covered=104 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/enforce-python-batch-budget.ps1 | 98.99 | covered=98 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/enforce-python-batch-budget.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/enforce-python-batch-budget.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/enforce-python-batch-budget.ps1:48 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-python-batch-budget.ps1:52 | post-ci=3 | base-line=51 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-python-batch-budget.ps1:55 | post-ci=3 | base-line=54 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-python-batch-budget.ps1:141 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-python-batch-budget.ps1:142 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-python-batch-budget.ps1:339 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-python-batch-budget.ps1:340 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/enforce-python-batch-budget.ps1:341 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/enforce-python-batch-budget.ps1 | covered=8 | total=8 | scope=informational
PER-SURFACE: .codex/hooks/hook-dependency-guard.ps1 | 100.00 | covered=19 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/hook-dependency-guard.ps1 | new file | scope=judged
FLOOR: .codex/hooks/hook-dependency-guard.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/hook-dependency-guard.ps1 | n/a | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:22 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:42 | post-ci=2 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:43 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:44 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:45 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:57 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:58 | post-ci=2 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:75 | post-ci=2 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:76 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:100 | post-ci=2 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:101 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:103 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:104 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:105 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:107 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:108 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:109 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:110 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/hook-dependency-guard.ps1:111 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINES: .codex/hooks/hook-dependency-guard.ps1 | covered=19 | total=19 | scope=judged
PER-SURFACE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=81 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
BASE-SURFACE: .codex/hooks/validate-bash.ps1 | 100.00 | covered=75 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=judged
FLOOR: .codex/hooks/validate-bash.ps1 | met | scope=judged
NO-REGRESSION: .codex/hooks/validate-bash.ps1 | met | scope=judged
CHANGED-LINE: .codex/hooks/validate-bash.ps1:16 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/validate-bash.ps1:22 | post-ci=3 | base-line=21 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/validate-bash.ps1:23 | post-ci=3 | base-line=22 | base-ci=2 | covered | scope=judged
CHANGED-LINE: .codex/hooks/validate-bash.ps1:267 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/validate-bash.ps1:268 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/validate-bash.ps1:304 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/validate-bash.ps1:305 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINE: .codex/hooks/validate-bash.ps1:306 | post-ci=5 | base-line=none | base-ci=n/a | covered | scope=judged
CHANGED-LINES: .codex/hooks/validate-bash.ps1 | covered=8 | total=8 | scope=judged
PER-SURFACE: .codex/hooks/validate-codex-subagent-routing.ps1 | 100.00 | covered=68 | missed=0 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/validate-codex-subagent-routing.ps1 | 32.26 | covered=20 | missed=42 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/validate-codex-subagent-routing.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/validate-codex-subagent-routing.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/validate-codex-subagent-routing.ps1:11 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/validate-codex-subagent-routing.ps1:13 | post-ci=3 | base-line=12 | base-ci=2 | covered | scope=informational
CHANGED-LINE: .codex/hooks/validate-codex-subagent-routing.ps1:72 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/validate-codex-subagent-routing.ps1:73 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/validate-codex-subagent-routing.ps1:136 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/validate-codex-subagent-routing.ps1:137 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/validate-codex-subagent-routing.ps1:138 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/validate-codex-subagent-routing.ps1 | covered=7 | total=7 | scope=informational
PER-SURFACE: .codex/hooks/validate-feature-review-coverage.ps1 | 99.29 | covered=140 | missed=1 | SOURCEFILE_MATCHES: 1 | scope=informational
BASE-SURFACE: .codex/hooks/validate-feature-review-coverage.ps1 | 7.30 | covered=10 | missed=127 | SOURCEFILE_MATCHES: 1 | scope=informational
FLOOR: .codex/hooks/validate-feature-review-coverage.ps1 | met | scope=informational
NO-REGRESSION: .codex/hooks/validate-feature-review-coverage.ps1 | met | scope=informational
CHANGED-LINE: .codex/hooks/validate-feature-review-coverage.ps1:43 | post-ci=4 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/validate-feature-review-coverage.ps1:233 | post-ci=3 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/validate-feature-review-coverage.ps1:234 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINE: .codex/hooks/validate-feature-review-coverage.ps1:235 | post-ci=1 | base-line=none | base-ci=n/a | covered | scope=informational
CHANGED-LINES: .codex/hooks/validate-feature-review-coverage.ps1 | covered=4 | total=4 | scope=informational
PER-SURFACE-FILES: 21
PER-SURFACE-JUDGED: 6
PER-SURFACE-LOST: 0
PER-SURFACE-UNCOVERED-INFO: 0
PER-SURFACE-RESULT: pass
```

### PS-SET deltas (informational; r1 from [P0-T9], r2 from this pass)

PS-DELTA: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | r1=95.78 | r2=95.78
PS-DELTA: .codex/hooks/enforce-epic-planning-only.ps1 | r1=95.86 | r2=95.86
PS-DELTA: .codex/hooks/hook-dependency-guard.ps1 | r1=100.00 | r2=100.00
PS-DELTA: .codex/hooks/validate-bash.ps1 | r1=100.00 | r2=100.00
PS-DELTA: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | r1=100.00 | r2=100.00
PS-DELTA: .codex/hooks/enforce-epic-merge-gate.ps1 | r1=98.73 | r2=98.73

### Combined-run figures (this pass [P3-T3], reported unchanged)

COMBINED-FINAL: .codex/hooks/check-powershell-test-purity.ps1 | 100.00 | missed=0
COMBINED-FINAL: .codex/hooks/check-python-test-purity.ps1 | 100.00 | missed=0
COMBINED-FINAL: .codex/hooks/codex-epic-child-launch-attestation.ps1 | 98.48 | missed=1
COMBINED-FINAL: .codex/hooks/enforce-checkpoint-monotonic.ps1 | 99.09 | missed=1
COMBINED-FINAL: .codex/hooks/enforce-codex-model-routing.ps1 | 100.00 | missed=0
COMBINED-FINAL: .codex/hooks/enforce-completion-consistency.ps1 | 100.00 | missed=0
COMBINED-FINAL: .codex/hooks/enforce-epic-child-worktree-binding.ps1 | 74.70 | missed=42
COMBINED-FINAL: .codex/hooks/enforce-epic-merge-gate.ps1 | 98.09 | missed=3
COMBINED-FINAL: .codex/hooks/enforce-epic-planning-only.ps1 | 82.25 | missed=30
COMBINED-FINAL: .codex/hooks/enforce-epic-root-invocation.ps1 | 100.00 | missed=0
COMBINED-FINAL: .codex/hooks/enforce-epic-wave-barrier.ps1 | 95.68 | missed=6
COMBINED-FINAL: .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.72 | missed=1
COMBINED-FINAL: .codex/hooks/enforce-evidence-locations.ps1 | 100.00 | missed=0
COMBINED-FINAL: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | 86.55 | missed=23
COMBINED-FINAL: .codex/hooks/enforce-powershell-batch-budget.ps1 | 99.05 | missed=1
COMBINED-FINAL: .codex/hooks/enforce-promotion-mcp-only.ps1 | 100.00 | missed=0
COMBINED-FINAL: .codex/hooks/enforce-python-batch-budget.ps1 | 99.05 | missed=1
COMBINED-FINAL: .codex/hooks/hook-dependency-guard.ps1 | 57.89 | missed=8
COMBINED-FINAL: .codex/hooks/validate-bash.ps1 | 80.25 | missed=16
COMBINED-FINAL: .codex/hooks/validate-codex-subagent-routing.ps1 | 100.00 | missed=0
COMBINED-FINAL: .codex/hooks/validate-feature-review-coverage.ps1 | 99.29 | missed=1
