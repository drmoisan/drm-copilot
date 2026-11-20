# Preflight Fixes (round two)

Timestamp: 2026-11-09T22-42
Plan: docs/features/active/owner-directive-pass-down-1157/plan.2026-11-09T16-32.md

Round-one defects re-checked: all four resolved in plan version 0.3 ([P3-T1] linked-item activation and key-gate rows with counting seams; Binding Constraints parallel-only binding with per-task `binding:` markers; [P1-T2] B2-B8 selection rows; [P2-T1] `Get-OwnerDirectiveItemBranch` rows and [P2-T4] AC-33 worker-side rows).

1. [P2-T2] | test-row list under-specified against the cited AC | the relay rows now name both AC-10 deny conditions (entry absent from the item checkpoint; entry present with rendered lines absent from the prompt) and the deny-reason content (rendered block and JSON entry to append). The task already implemented both conditions and cited AC-10; what is asserted is unchanged.
2. [P2-T3] | test-row list under-specified against the cited AC | the per-agent-type held rows now assert the AC-14 reason content (rendered block, always-refused note, absolute decision-file path, grammar, injected clock value), which the task's implementation clause already lists.
3. [P5-T4] | missing file citation | `$script:PointerFile` now names its file `tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1`.
4. [P5-T5] | changed-behavior disposition incomplete | the keep-list now also names `OWNER_DIRECTIVE_BLOCKED`, `Python and TypeScript parity gap`, and `Codex enforcement gap`, which the existing S13 rows of the contract suite assert, with the disposition that those rows stay unchanged.

Validation after fixes: branch-current Python CLI `plan` subcommand (see final line of the preflight return).
