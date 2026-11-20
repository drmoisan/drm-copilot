# Ledger Commits and Added Files ([P2-T7])

Timestamp: 2026-11-19T12-00
Plan: plan.2026-10-30T18-39.md
Command: sh SCRATCH/issue-1032-ledgeraudit.sh (for each commit in MB..HEAD: git show --name-only of docs/engineering/process-reductions and the subject; git show --name-status of the P1-T9 commit; git diff --name-status MB HEAD for ProcessReductionChain.psm1 and for added files; git status --porcelain), MB = merge base of origin/epic/shared-agent-harness-layer-integration and HEAD (AD-7)
EXIT_CODE: 0
Output Summary: five branch commits modify LEDGER-RECORDS files and every one carries the `reduction: NNNN` token of each entry it modifies; the P1-T9 commit modifies every LEDGER-RECORDS file that REGION-MAP lists for a retired path; ProcessReductionChain.psm1 is unchanged; the only added file is the new Pester guard suite; no added Python file and no added TypeScript or Python file under a pushed-down tree.

## Commits That Modify LEDGER-RECORDS

| Commit | Subject tokens | Entries modified | Missing tokens |
| --- | --- | --- | --- |
| `[P1-T2]` test(1032): drop retired Copilot copies from brief and contract pins | reduction: 0001 | 0001 | none |
| `[P1-T5]` test(1032): drop Copilot skill rows from claude-runtime contract suites | reduction: 0001, 0006, 0009 | 0001, 0006, 0009 | none |
| `[P1-T9]` feat(1032): retire the Copilot skill copies and their ledger regions | reduction: 0001, 0003, 0004, 0005, 0006, 0008, 0009, 0011, 0012 | 0001, 0003, 0004, 0005, 0006, 0008, 0009, 0011, 0012 | none |
| `[P1-T10]` docs(1032): update the execution-environment brief copy counts to four | reduction: 0001, 0006, 0011 | 0001, 0006, 0011 | none |
| `[P1-T11]` docs(1032): update the plan-contract brief-copy count to four | reduction: 0001, 0008 | 0001, 0008 | none |

## P1-T9 Coverage of Retired-Path Records

REGION-MAP lists retired-path regions in entries 0001, 0003, 0004, 0005, 0006, 0011 and 0012 (revert blocks) and patches 0001, 0006, 0008 and 0009 (sections). The P1-T9 commit modifies all of them (`M` status): entry files 0001, 0003, 0004, 0005, 0006, 0008, 0009, 0011, 0012 and patches 0001, 0006, 0008, 0009 (entries 0008 and 0009 receive the `## Files Changed` note for their patch sections). Entry 0012 is included per `ledger-records-entry-0012-deviation.2026-11-19T07-46.md`.

## Other Checks

- `scripts/dev-tools/ProcessReductionChain.psm1` in `git diff --name-status MB HEAD`: 0 lines (unchanged).
- Added files (`git diff --name-status --diff-filter=A MB HEAD`, outside `docs/features/`): `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` only; `git status --porcelain`: 0 lines (nothing untracked or uncommitted at the time of the audit).
- Added `*.py` files: 0. Added TypeScript or Python files under a pushed-down tree (`.claude/`, `.agents/`, `.codex/`, `.github/`, `extensions/drm-copilot/resources/`): 0.
