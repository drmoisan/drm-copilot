# Final QA Remediation (P4-T2 first attempt)

Timestamp: 2026-11-24T09-16
Command: sh SCRATCH/issue-1234-taskcheck.sh (static over the two edited suites; launcher `pester -TestPath` over 8 files; launcher `pytest` over 4 contract files)
EXIT_CODE: 0
Output Summary:
- The first final Pester gate (2026-11-24T08-42 to 08-58, launcher exit 1, workers=8) failed 5 tests in 3 shards; no merged artifact was written:
  1. `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` AC-4 for `tests/scripts/claude-hooks/release-merge.Parity.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-release.Tests.ps1`: the baseline read-seam mocks were missing from the outermost BeforeAll. Fix: the parity suite registers the baseline mocks through Register-EpicStateBaselineMock and calls the interception probe from an It; the Codex suite adds the three conditional checkpoint-content mocks used by its docs-only sibling.
  2. `enforce-pr-author-command-allowlist.Tests.ps1` AL-34: the new pr-author sentence carried a `gh pr merge ... <sha>` code span, which the receipt-procedure scan reads as a command. Fix: the `.agents/skills/pr-author/SKILL.md` sentence describes the merge without a command span; regenerated with Invoke-HarnessGeneration.ps1 (`-Check`: no drift) and the Codex bundle copy re-mirrored.
  3. `ProcessReductionChain.Ledger.Tests.ps1` PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-SUBCHAIN-HOLDS: the new Claude `core.json` entry, inserted after `enforce-epic-merge-gate-child-ci.ps1`, changed the context of the stored hunk of ledger entry 0010. Fix: the entry moved after `.claude/hooks/hook-release-pull-request-context.ps1`; no ledger record was edited.
- Compliance helper re-run (Get-EpicStateSuiteCompliance) over the five new suites: 0 findings.
- Targeted re-run: format 0 changed, analyzer 0 findings; Pester exit 0 (805 tests, 0 failures) over the discovery guard, AL-34 suite, ledger chain suite, both edited suites, HarnessGeneration.RepoGate, pr-author-docs-estate-delegation-contract, release-pull-request.Parity; pytest exit 0 after 6 queue timeouts (43 passed).
- The final QA loop restarts from format (P4-T1) per the plan.
