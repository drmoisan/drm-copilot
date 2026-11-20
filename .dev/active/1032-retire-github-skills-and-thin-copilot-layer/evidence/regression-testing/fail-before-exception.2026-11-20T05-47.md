# Fail-Before Exception Dossier for CASE-B ([P1-T4])

Timestamp: 2026-11-20T05-47
Plan: remediation-plan.2026-11-20T05-28.md
Command: sh SCRATCH/issue-1032-c3-failbefore.sh b (variant build and launcher attempt); sh SCRATCH/issue-1032-c3-proof.sh (in-memory proof, pwsh -NoProfile -File SCRATCH/issue-1032-c3-proof.ps1; one run covers CASE-A and CASE-B, recorded at 2026-11-20T05-46)
EXIT_CODE: 0
WhyFailingRunImpossible: The test-execution launcher pester suite refuses a -TestPath outside the repository root (launcher exit 1 after 1.22 s, shard error text "Scan folder ... must resolve inside root"), so no Pester run of the variant exists; the variant must stay outside the tree so sibling suites do not discover it.
Variant description: copy of copilot-layer-retirement.Tests.ps1 in SCRATCH in which the workspace branch of Test-ClrCollisionControl no longer compares values: the `-or $settings[$location][$folder] -ne $false` clause of the three-location check and the `chat.useClaudeMdFile` comparison line are removed, so a key-presence-only workspace case counts as complete. $script:RepoRoot is set to the repository root. Nothing under the variant is tracked.
Alternative proof: the Test-ClrCollisionControl function text is read by AST from the committed file and from the variant and dot-sourced in memory; the CASE-B fixture (all four collision keys present, chat.agentSkillsLocations mapping .claude/skills to true, readme without a collision-controls section, required file absent) is fed to each.
Output Summary: CASE-B committed helper violations: 1. CASE-B variant helper violations: 0. The CASE-B assertion (exactly 1 violation matching "exactly one AD-3 case must hold in full") holds for the committed helper and fails for the variant without the value comparison (0 against 1).
