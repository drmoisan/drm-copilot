# Ledger Regeneration [P3-T9]

Timestamp: 2026-11-20T15-35
Command: sh SCRATCH/issue-1016-regen.sh <file> [<diff sections>] (applies S = `docs/features/templates/` to `.dev/templates/` and `'docs/features/templates'` to `'.dev/templates'` to a live file, or to every non-header line of the listed diff sections of a stored patch; headers, `index` lines and `@@` ranges untouched); git commit -F per entry; sh SCRATCH/issue-1016-tc-p3t9.sh; git diff --name-status <apply commit> HEAD -- .dev/engineering/process-reductions
EXIT_CODE: 0
Output Summary: One preparatory commit and four reduction commits, newest entry first. After the last commit the task check passes PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-SUBCHAIN-HOLDS, ProcessReductionLedger.Index.Tests.ps1, ProcessReductionLedger.Replay.Tests.ps1, PRL-RULE-STATED-IN-EVERY-COPY (four rows), PCW-STANDING-RULE-<Copy> (four rows), test_contract_requires_final_phase_self_review, parallel-gate-wording.Tests.ps1 and less-evidence-contract.Tests.ps1 (Pester 566 tests, 0 failures; pytest 35 passed). Against the apply commit, the ledger folder shows `M` for exactly the four regenerated patches; entry Markdown files, README and the 0010 patch are unchanged.

## Commits

| Order | Subject | Regenerated hunks | Live edits |
| --- | --- | --- | --- |
| 1 | `feat(1016): flip dependents to the .dev root ([P3-T3] to [P3-T8])` | none (no `reduction:` token) | the [P3-T3] to [P3-T8] changes and plan check-offs |
| 2 | `test(1016): read moved policy-audit templates in the less-evidence contract ([P3-T9]) reduction: 0009` | 0009 create hunk of `less-evidence-contract.Tests.ps1` (2 lines) | `TEMPLATE`, `AUDIT-AGENTS` paths |
| 3 | `docs(1016): point the plan contract at the .dev templates and ledger ([P3-T9]) reduction: 0008` | the four 0008 `atomic-plan-contract` hunks (4 lines) | in the four `SKILL_COPIES`: self-review bullet to `.dev/templates/policy_audit/`, ledger applicability bullet to `.dev/engineering/process-reductions/`; preflight-fix-record sentence in two copies |
| 4 | `test(1016): read moved policy-audit templates in the parallel gate wording suite ([P3-T9]) reduction: 0006` | 0006 modify hunk of `parallel-gate-wording.Tests.ps1` (3 lines) | `AUDIT-TEMPLATE`, `AUDIT-AGENTS` paths and the sweep root `'.dev/templates'` |
| 5 | `docs(1016): regenerate the 0001 hunks for the .dev template paths ([P3-T9]) reduction: 0001` | 0001 create hunk of `parallel-gate-wording.Tests.ps1` (3 lines) and the four 0001 `atomic-plan-contract` hunks (4 lines) | none |

The two `atomic-plan-contract` byte pairs hold after commit 3 (`.claude` copy and bundle copy share one digest, `.agents` copy and bundle copy share another).

## Preflight-fix-record sentence (`### Single-Pass Preflight`)

| Copy | Result | Reason |
| --- | --- | --- |
| `.claude/skills/atomic-plan-contract/SKILL.md` | UPDATED (ends "path under `docs/features/` or `.dev/`.") | `.claude/hooks/validate-executor-output.ps1` accepts a record under any root of `Get-DevelopmentDocsKnownRoot` (`docs/features` and `.dev`) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | UPDATED | same |
| `.agents/skills/atomic-plan-contract/SKILL.md` | NOT_PRESENT | the copy carries no such sentence |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md` | NOT_PRESENT | the copy carries no such sentence |

No stored hunk or revert block holds the sentence or the ledger applicability bullet (search of the ledger folder returned no match), so both edits lie outside every recorded region.

## Other checks

- The four `feature-review-workflow` `SKILL_COPIES` already name `.dev/engineering/process-reductions/` after the apply; none needed an edit.
- `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py`: passed.
- PowerShell format drift 0 and PSSA findings 0 for both edited Pester files.

## Deviation (recorded, non-blocking)

The commit protocol says a commit task checks itself off before staging. The four reduction commits were made before this task's verification ran, so the [P3-T9] check-off lands in the next commit, together with this evidence. No content of the five commits changes.
