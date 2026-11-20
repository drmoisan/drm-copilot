# R1 Brief and Contract Copy Facts ([P1-T4])

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T13-50
Command: git hash-object on each REMAINING-BRIEF-COPIES and REMAINING-CONTRACT-COPIES file; git ls-files for every tracked copy; git rev-parse of the contract copies at the first parent of SYNC-MERGE and at the merge base of origin/main and HEAD; sh SCRATCH/issue-1032-r1-run.sh issue-1032-r1-sfacts.ps1 (counts each S1 to S6 target and source wording per copy)
EXIT_CODE: 0
Output Summary: REMAINING-BRIEF-COPIES: one hash for all four copies, S1 to S5 hold in each. REMAINING-CONTRACT-COPIES: S6 holds in each of the four copies, but the set carries two hashes, not one: the `.claude` copy equals its Claude bundle copy and the `.agents` copy equals its Codex bundle copy. The two pairs already differed at the merge base of origin/main and HEAD, before this feature, and the sync merge changed neither copy. The plan's "all copies equal" clause for the contract set is therefore not met; this is recorded as a deviation below.

## Copy Sets

`git ls-files` lists exactly four tracked copies of each skill, all members of the named sets; no copy under a retired tree exists.

| Set | Copy | Hash |
| --- | --- | --- |
| REMAINING-BRIEF-COPIES | `.claude/skills/execution-environment/SKILL.md` | 4872f6185ea4aaccb74860990d0e24bda55f7b77 |
| REMAINING-BRIEF-COPIES | `.agents/skills/execution-environment/SKILL.md` | 4872f6185ea4aaccb74860990d0e24bda55f7b77 |
| REMAINING-BRIEF-COPIES | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | 4872f6185ea4aaccb74860990d0e24bda55f7b77 |
| REMAINING-BRIEF-COPIES | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | 4872f6185ea4aaccb74860990d0e24bda55f7b77 |
| REMAINING-CONTRACT-COPIES | `.claude/skills/atomic-plan-contract/SKILL.md` | da7e12b0c620e2d18412e702cf7d6f93333886fe |
| REMAINING-CONTRACT-COPIES | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | da7e12b0c620e2d18412e702cf7d6f93333886fe |
| REMAINING-CONTRACT-COPIES | `.agents/skills/atomic-plan-contract/SKILL.md` | ace630fce696ebfe458009b8efb0ced32f7bb90d |
| REMAINING-CONTRACT-COPIES | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md` | ace630fce696ebfe458009b8efb0ced32f7bb90d |

Brief set: one hash value, all copies equal.
Contract set: two hash values (each runtime copy equals its bundle mirror).

## Contract Copy History

| Ref | `.claude` copy blob | `.agents` copy blob |
| --- | --- | --- |
| merge base of origin/main and HEAD (before this feature) | e7b55a48064d616922cc1bff5da258e7cc141471 | 4fa2ccc48351f30e0e6f90b40b4fdc5128c465fc |
| first parent of SYNC-MERGE | da7e12b0c620e2d18412e702cf7d6f93333886fe | ace630fce696ebfe458009b8efb0ced32f7bb90d |
| HEAD | da7e12b0c620e2d18412e702cf7d6f93333886fe | ace630fce696ebfe458009b8efb0ced32f7bb90d |

The `.claude` and `.agents` contract copies differ at every ref above (current `git diff --no-index --stat`: 28 insertions, 70 deletions). The sync merge did not touch either copy (no contract copy is in MERGE-DELTA). Byte identity of the contract copies across runtimes is not a requirement of spec.md (`REMAINING-CONTRACT-COPIES` and S6 require only the S6 token), and no test asserts it.

## S1 to S6 Checks

| Check | Copies | Result |
| --- | --- | --- |
| S1 `byte-identical in four locations`, location list naming exactly the four brief copies and no retired path | 4 briefs | holds (1 each; list names the four `REMAINING-BRIEF-COPIES` paths) |
| S2 `in all four byte-identical copies` | 4 briefs | holds (1 each) |
| S3 `in the four` `documentation-workflow` copies and `in the four copies of this brief` | 4 briefs | holds (1 and 3 each) |
| S4 and S5 `in the four` `atomic-plan-contract` copies | 4 briefs | holds (2 each) |
| No "six" source wording, no RETIRED-PATH | 4 briefs | holds (0 each) |
| S6 `in all four byte-identical copies`, no `in all six byte-identical copies` | 4 contracts | holds (1 and 0 each) |

`CLR-BRIEF-COUNT holds every count target in each remaining brief and contract copy` passed in the [P1-T1] task check.

## Deviation

The [P1-T4] acceptance clause "one hash value per copy set (all copies equal)" holds for REMAINING-BRIEF-COPIES and does not hold for REMAINING-CONTRACT-COPIES. The divergence predates this feature and this cycle, the merge did not introduce it, and closing it would rewrite one runtime's planning contract, which is outside this item's scope and outside the plan. Decision (autonomous mode): record the observed state, do not edit either contract copy, and escalate it in the completion report for the orchestrator to decide whether a follow-up is needed.
