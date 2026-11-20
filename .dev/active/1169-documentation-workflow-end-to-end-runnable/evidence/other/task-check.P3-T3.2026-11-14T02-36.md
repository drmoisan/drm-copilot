# Task Check P3-T3 (Remediation Cycle 1)

Timestamp: 2026-11-14T02-36
Command: perl substitution of the rule sentence in the six documentation-workflow/SKILL.md copies; sha256sum of the six copies; sh SCRATCH/issue-1169-tc.sh R1-P3-T3 "documentation-workflow.CommitStage.Tests.ps1" "documentation-workflow.CommitStage.Tests.ps1,docs-authoring-roles.Skills.Tests.ps1"; sh SCRATCH/issue-1169-tc.sh R1-P3-T3b "" "DocumentationEstateOnboarding.Tests.ps1,docs-authoring-roles.Registration.Tests.ps1"
EXIT_CODE: 0
Output Summary:
- Changed files: documentation-workflow/SKILL.md in .claude/skills/, .agents/skills/, .github/skills/, and the claude-customizations, codex-and-agents-customizations, and customizations bundles (the docs-path-only rule of `## Commit, Receipt and Pull Request` now reads "Only docs path set changes may be on the branch: paths under `docs/` that lie under the profile's documentation roots or artifact directories, and the docs-init workflow file. Any other path is denied at commit, PR creation, and merge."); tests/scripts/claude-runtime/documentation-workflow.CommitStage.Tests.ps1 (row `limits the docs path set to paths under docs/ in <Path>`, one per copy, asserting the token "paths under `docs/` that lie under" in the whitespace-normalized section).
- The three edited lines are identical in all six copies (one MD5 for the line range in each copy).
- Pair hashes (SHA-256): .claude and claude-customizations cc4bac7146ec9641171846ff6d8dc822e14cbd0f96e854afe5fabf19e9b455d2; .agents and codex-and-agents-customizations 18b36d1e5e54c4848bae8482618592958da29c78bf8b865e7cf927e62d177f64; .github and customizations d1f2e211e7f4ef7f49d5bb1c61dab8c1d97c1425b683c2a440ed71058911777f. Each copy equals its bundle mirror.
- Selection rule: the contract suites that read the changed skill path (`git grep -l documentation-workflow -- tests`): documentation-workflow.CommitStage.Tests.ps1, docs-authoring-roles.Skills.Tests.ps1, docs-authoring-roles.Registration.Tests.ps1, DocumentationEstateOnboarding.Tests.ps1.
- Format 0 findings, lint 0 findings on the edited test file; type check not applicable.
- Pester run 1: 178 passed, 0 failed. Pester run 2: 36 passed, 0 failed.
