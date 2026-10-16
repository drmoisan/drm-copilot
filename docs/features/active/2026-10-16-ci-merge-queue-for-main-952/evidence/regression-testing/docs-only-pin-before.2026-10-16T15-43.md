# #927 docs-only deny-text pins, before-state (remediation cycle 1, R-MERGE)

Timestamp: 2026-10-16T15-43
Task: [P2-T6]
Command: git grep -n -F -e "gh pr merge --merge requires" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
EXIT_CODE: 0
Output Summary: two lines, at tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:63 and tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:59 (the lines P2-T7 and P2-T8 edit)
FailBeforeSource: CI run 38915280068 (workflow_dispatch, head f03bc9b72, orchestrator-observed; Scope, R-MERGE)

## Output (verbatim)

```text
tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:63:        $script:BareDenyText = 'EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green". No checkpoint satisfied this gate.'
tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:59:        $script:CodexBareDenyText = 'EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires a safe epic child checkpoint or a successful final epic CI gate with a matching PR number.'
```

## RowAttribution:

RowAttributionSource: CI-RUN

| Row | Suite | Job `poshqc / PowerShell QC` | Job `poshqc / PowerShell hook suites (Linux)` |
|---|---|---|---|
| makes no docs-only call for a bare merge and keeps its exact deny text (issue #927) | tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | FAILED (expected length 408, actual 521, first difference at index 25) | FAILED (same) |
| keeps the bare-merge deny text unchanged (codex, issue #927) | tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | FAILED (expected 144, actual 257, first difference at index 25) | FAILED (same) |

## Expected after-state

Both rows pass in both jobs of `R_final_2` (ORCH-R1 rows (k) and (l), ORCH-R2). The local `t-claude-hooks` and `t-codex-hooks` calls of P2-T10 and P2-T11 list them as `Passed` when the JUnit file is fresh.

## Local baseline (P0-T8)

- t-claude-hooks: `Baseline: GREEN-AFTER-PIN`, `KNOWN_BASELINE_FAILURE=makes no docs-only call for a bare merge and keeps its exact deny text (issue #927)` (ps-test-t-claude-hooks.2026-10-16T15-36.md)
- t-codex-hooks: `Baseline: GREEN-AFTER-PIN`, `KNOWN_BASELINE_FAILURE=keeps the bare-merge deny text unchanged (codex, issue #927)` (ps-test-t-codex-hooks.2026-10-16T15-36.md)
