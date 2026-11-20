# Fail-Before Exception Dossier for CASE-A ([P1-T3])

Timestamp: 2026-11-20T05-46
Plan: remediation-plan.2026-11-20T05-28.md
Command: sh SCRATCH/issue-1032-c3-failbefore.sh a (variant build and launcher attempt); sh SCRATCH/issue-1032-c3-proof.sh (in-memory proof, pwsh -NoProfile -File SCRATCH/issue-1032-c3-proof.ps1)
EXIT_CODE: 0
WhyFailingRunImpossible: The test-execution launcher pester suite refuses a -TestPath outside the repository root. The attempt with the variant under SCRATCH ended with launcher exit 1 after 1.68 s and shard error text "Scan folder ... must resolve inside root", so no Pester run of the variant exists. The variant must stay outside the tree (a copy in the tree would be discovered by sibling suites).
Variant description: copy of copilot-layer-retirement.Tests.ps1 in SCRATCH with the one line `if ($text.Contains($RetiredPath)) { ... }` (the retired-path branch of Test-ClrBriefCount) deleted; $script:RepoRoot set to the repository root. Nothing under the variant is tracked.
Alternative proof: the Test-ClrBriefCount function text is read by AST from the committed file and from the variant and dot-sourced in memory; the CASE-A fixture (all five count targets plus the retired path, contract holding the S6 target) is fed to each.
Output Summary: CASE-A committed helper violations: 1. CASE-A variant helper violations: 0. The CASE-A assertion (exactly 1 violation matching "names the retired path") therefore holds for the committed helper and fails for the variant without the branch (0 against 1).
