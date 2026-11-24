# Task check R1 P1-T3 (merge-gate ordinal reads)

Timestamp: 2026-11-24T16-29
Changed files: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1 (new private Get-EpicMergeGateChildCiOrdinalProperty and Get-EpicMergeGateChildLocalQcReviewedHead; Test-EpicMergeGateChildCiOptOut, Get-EpicMergeGateChildCiLivePullRequest, and Get-EpicMergeGateChildLocalQcResult read their #1233 keys ordinally; stage L2 reads the reviewed head through the new function; one header sentence), its byte-identical copies .codex/hooks/enforce-epic-merge-gate-child-ci.ps1, extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-child-ci.ps1, and extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-child-ci.ps1 (copied by SCRATCH/issue-1233-copy.sh), tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1 (15 OPT-ORD- rows), tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1 (12 CLAUDE-OPT-ORD- rows), and the first and second 0014 revert blocks of the helper.
Selection rule: the merge-gate, enforce-gate-suites.EpicStateIsolation.*, cross-tree-helper-identity, and hook-dependency-failure.* files of Set P, plus the other Set P suites that name the helper or the gates (release-merge.Parity, session-root-reads-850.Constraints, codex-epic-runtime-contracts, epic-execution-gates, legacy-codex-hook-contracts): 46 files listed in SCRATCH/issue-1233-r1-t3sel.txt.

Command: sh SCRATCH/issue-1233-ps-files.sh check <the four helper copies>,<the two opt-out suites>
EXIT_CODE: 0
Output Summary: 6 files already formatted, drift 0, 0 PSSA findings (a first pass reported 4 PSUseOutputTypeCorrectly findings for Get-EpicMergeGateChildLocalQcReviewedHead, one per copy; fixed by declaring [object[]] in its OutputType, then re-copied and re-checked).

Command: cmp of the helper against its three copies (SCRATCH/issue-1233-copy.sh)
EXIT_CODE: 0
Output Summary: byte-identical. Helper 629 lines; opt-out suites 455 (Codex) and 411 (Claude) lines; all below 700.

Command: sh SCRATCH/issue-1233-ledger-verify.sh
EXIT_CODE: 1
Output Summary: blocks=65; every 0014 Current is found once and the helper reverts to its merge-base bytes. Remaining mismatches are the two known ones: .claude/hooks/enforce-epic-merge-gate.ps1 (pre-existing post-sync reflow without a block; O5) and .codex/hooks/enforce-epic-merge-gate.ps1 (restored by P1-T5).

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <46 files> (through SCRATCH/issue-1233-r1-pester.sh)
EXIT_CODE: 0
Output Summary: workers=8, wall-clock 428.7s; merged JUnit tests=2807, failures=0, errors=0. Every OPT-ORD- and CLAUDE-OPT-ORD- row passes, and every pre-existing row of both opt-out suites, enforce-epic-merge-gate.ChildCi.Tests.ps1, and tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci.Tests.ps1 passes unchanged. Attempts 1 to 12 exited 75 (queue timeout), recorded as queue timeouts. Selection coverage: .claude/hooks/enforce-epic-merge-gate-child-ci.ps1 166/166 (100%), .codex/hooks/enforce-epic-merge-gate-child-ci.ps1 164/166 (98.8%).
