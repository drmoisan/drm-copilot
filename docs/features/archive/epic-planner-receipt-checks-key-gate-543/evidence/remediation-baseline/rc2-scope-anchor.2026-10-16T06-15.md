# Remediation Cycle 2 Scope Anchor (P0-T3)

Timestamp: 2026-10-16T06-15
Command: git fetch origin; git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git rev-parse origin/bug/epic-planner-receipt-checks-key-gate-543; git rev-parse origin/main; git merge-base HEAD origin/main; git merge-base --is-ancestor origin/bug/epic-planner-receipt-checks-key-gate-543 HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary:
- Branch: bug/epic-planner-receipt-checks-key-gate-543
- CYCLE_BASE_SHA: 254b5a5420ff37e894ed0b69f19971f4843f5214 (planning-time HEAD was 94a3f012c; the two later commits 3e1c9e1b9 and 254b5a542 add only this plan file)
- Remote branch SHA: 254b5a5420ff37e894ed0b69f19971f4843f5214 (equals HEAD)
- Ancestry check (origin branch is ancestor of HEAD): exit 0
- origin/main SHA: 5bc97774b8322e57abb94dfac3cd0a000a136c5b (moved after the planning-time merge)
- MAIN_BASE_SHA: afa951ac0207eae934ac695e7340f18b3cf77522 (the merged main tip in HEAD's history; a fixed ancestor)
- Porcelain output (verbatim):
  ?? docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/remediation-baseline/rc2-phase0-instructions-read.2026-10-16T06-14.md
  ?? docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/remediation-baseline/rc2-scope-confirmation.2026-10-16T06-14.md
- Both porcelain paths lie under the feature folder. No path outside it; Phase 1 may proceed.
