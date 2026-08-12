# P4-T5 Native Parallel Admission Hook Evidence

## Scope

- Task: `[P4-T5]`
- Shared transport: `.codex/hooks/parallel-hook-common.ps1`
- Shared decision authority:
  `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state artifacts/orchestration/parallel-orchestrator-state.json --workspace-root <repository>`
- The PowerShell hooks perform call matching, native envelope handling, and shared-validator transport only.

## Hook Results

| Hook | Physical lines | Parser | PoshQC format | PoshQC analyze | Injected transport |
| --- | ---: | --- | --- | --- | --- |
| `enforce-parallel-cohort-barrier.ps1` | 124 | 0 errors | PASS | PASS | 4/4 |
| `enforce-parallel-drift-gate.ps1` | 124 | 0 errors | PASS | PASS | 4/4 |
| `enforce-parallel-child-worktree-binding.ps1` | 130 | 0 errors | PASS | PASS | 4/4 |
| `enforce-parallel-worktree-removal-gate.ps1` | 116 | 0 errors | PASS | PASS | 4/4 |
| `enforce-parallel-abandon-gate.ps1` | 115 | 0 errors | PASS | PASS | 4/4 |

Combined PoshQC formatting and analysis passed for all five files in one scoped run. Every file remains below the repository 500-line limit.

## Transport Matrix

The injected runner matrix passed 20/20 assertions: four assertions per hook.

- Shared-validator allow: exit 0, empty stdout, and empty stderr.
- Shared-validator rejection: exit 0, one native deny envelope on stdout, and empty stderr.
- Irrelevant call: exit 0 with no output and no validator invocation.
- Malformed hook input: exit 2, empty stdout, and the stable malformed-input diagnostic on stderr.

The cohort hook delegates predecessor receipt and cohort ordering decisions. The drift hook delegates quiescence, pinning, conflict halt, recoloring, and requeue decisions. The child-binding hook delegates item, repository, branch, worktree, launch, and receipt identity checks. The removal and abandon hooks delegate exact removal-receipt and operation/item/worktree/confirmation tuple checks.

## Algorithm Ownership

Static inspection verified that each hook dot-sources `parallel-hook-common.ps1` and calls the public `parallel-orchestrator-state` validator. No hook imports or defines cohort ordering, graph coloring, drift, pinning, recoloring, requeue, mutation, or receipt-decision algorithms. The only `ForEach-Object` occurrence in each hook converts shared-validator output to strings.

## Repository Invariants

- `.claude` status entries: 0.
- `.claude` diff entries: 0.
- The completed two-file PowerShell batch receipt named only the removal and abandon hooks; it was deleted, and the resulting empty `.codex/state` directory was removed.
- `.codex/state` exists after cleanup: false.
- `git diff --check`: PASS, exit 0. Git emitted only the existing line-ending advisory for `testResults.xml`; no whitespace error was reported.

## Result

`[P4-T5]` acceptance is verified: all five native hooks fail closed through the shared decision authority, and no PowerShell decision algorithm was duplicated.
