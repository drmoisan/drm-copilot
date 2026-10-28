# Seeded Shuffled File-Order Isolation Runs (P6-T5, loop pass 1)

Timestamp: 2026-10-28T13-32
Command: sh SCRATCH/issue-989-shuffle.sh (per seed, one PowerShell 7 process: order the six touched suites by System.Random(seed).Next() keys, then Invoke-Pester with Run.Path in that order, JUnit to artifacts/pester/pester-shuffle-<seed>.xml; counts read from that JUnit file)
EXIT_CODE: 0

Touched suites: `enforce-model-routing-receipt.AuthorAsserted.Tests.ps1`, `enforce-pr-author-skill.CurrentBranch.Tests.ps1`, `pr-author-issue-link-contract.Tests.ps1`, `enforce-pr-author-command-allowlist.Tests.ps1`, `enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`.

| Seed | Executed file order | Tests | Failed |
|---|---|---|---|
| 11 | CurrentBranch ; OrchestratorStatePreflight ; WorktreeResolution ; pr-author-issue-link-contract ; AuthorAsserted ; command-allowlist | 111 | 0 |
| 23 | command-allowlist ; CurrentBranch ; WorktreeResolution ; OrchestratorStatePreflight ; AuthorAsserted ; pr-author-issue-link-contract | 111 | 0 |
| 37 | AuthorAsserted ; command-allowlist ; pr-author-issue-link-contract ; CurrentBranch ; OrchestratorStatePreflight ; WorktreeResolution | 111 | 0 |

The executed container order reported by Pester matched the seeded order for every seed. No order dependence was found.

Output Summary: three seeds (11, 23, 37), 111 tests each, 0 failures in every order.
