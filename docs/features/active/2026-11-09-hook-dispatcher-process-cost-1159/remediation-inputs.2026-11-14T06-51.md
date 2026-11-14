# Remediation Inputs — Issue #1159 — Main-Sync Cycle 1

- Timestamp: 2026-11-14T06-51
- Issue: #1159
- Branch: feature/hook-dispatcher-process-cost-1159
- PR: #1177 (base main)
- Opened by: orchestrator main sync before the concurrent review (no review outcome)
- Merge commit: main sync of origin/main at 2c8dee6dd into the branch (clean merge, no conflict)
- Remediation-Mode: proportionate
- Review-Verdict: REMEDIATION_REQUIRED

## Context

The plan's pre-merge integration task [P7-T1] (spec D15) integrated origin/main as of the start of Phase 7. After PR #1177 opened, origin/main advanced (issues #1160 and #1169). The main-sync merge changed no PreToolUse registration in `.claude/settings.json` or `.codex/config.toml`, so no hook arrived beside the dispatcher, but it changed the content of dispatched hooks and their dot-sourced helpers and modules. Under spec D15 and the [P7-T1] rule, a dispatched hook or helper whose content changed between the previous merge base and the new merge base is an unhandled member of derived sets (a) and (b).

Files under `.claude/hooks/` and `.codex/hooks/` changed by the merge (diff of the previous merge base and origin/main): `enforce-docs-complete-gate.ps1`, `enforce-model-routing-receipt.ps1`, `enforce-model-routing-receipt-docs.ps1` (new helper), `enforce-orchestration-preimplementation-gate.ps1`, `enforce-orchestration-preimplementation-gate-docs.ps1` (new helper, both runtimes), `hook-docs-estate-context.ps1` (new, both runtimes), `hook-docs-only-diff.ps1` (new, both runtimes), and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; modules under `.claude/lib/docs/` changed: `DocsCompleteGate.psm1`, `DocsLedgerCommands.psm1`, `DocsProfileCommands.psm1`, `DocsReceiptRevision.psm1` (new), `DocsValidateCommands.psm1`, `Invoke-DocsCommand.ps1`.

## Findings

### F1 — Unhandled D6 member after main sync

- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Location: `.claude/hooks/enforce-model-routing-receipt-docs.ps1` (helper dot-sourced by the dispatched hook `.claude/hooks/enforce-model-routing-receipt.ps1`) carries a guarded `Import-Module ... DocsReceiptRevision.psm1 -Force`.
- Required: apply the [P3-T2] audit to `.claude/lib/docs/DocsReceiptRevision.psm1` and to every other module whose content the merge changed and that a D6-set hook or helper imports (`DocsCompleteGate.psm1` included); remove `-Force` for a stateless module, keep it with a registry `notes` entry for a stateful one; mirror each edited file into its bundle copy. Write a new `d6-module-audit.<timestamp>.md`.

### F2 — D13 tail check for changed dispatched hooks

- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Location: every registered hook of either runtime whose content changed in the merge (`enforce-docs-complete-gate.ps1`, `enforce-model-routing-receipt.ps1`, `enforce-orchestration-preimplementation-gate.ps1` in both runtimes).
- Required: run the [P0-T11] procedure on each changed registered hook and write a new `d13-tail-output.<timestamp>.md`; remediate any `FailOpen: yes` by the [P1-T2] rule with its own evidence.

### F3 — Integration proof on the merged tree

- Severity: Blocking
- Remediability: autonomous
- Finding-Scope: contained
- Required: confirm zero PreToolUse registrations outside the dispatcher in both registration files and that each registry still equals the registrations at the new merge base; re-run consumer search (c) and re-target any arrived registration consumer; confirm the parity corpus still has envelopes for every changed hook whose envelope behavior changed (or record why none is possible); refresh bundle mirrors and both `core.json` files for every changed file; then run the final QA loop (PowerShell static, Python static if any Python file changed, one `Invoke-PoshQCParallelTest`, one `pytest -n auto` with coverage, `Invoke-PoshQCLeakScan`), the consistency checks and a new self-review, each as new append-only evidence with a new `main-integration.<timestamp>.md` recording the merge, merge-base derivation, actions taken per member, and gate results compared with the Phase 0 baselines.
