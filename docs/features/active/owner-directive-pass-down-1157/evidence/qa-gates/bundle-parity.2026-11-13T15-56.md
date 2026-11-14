# Bundle byte parity (issue #1157, cycle 1, P2-T6)

Timestamp: 2026-11-13T15-56
Command: sh SCRATCH/issue-1157-parity.sh (in the item worktree: for each path of git diff --name-only --diff-filter=AMR from the merge base of origin/main and HEAD under .claude that has a copy under extensions/drm-copilot/resources/claude-customizations/, sha256sum of both files); contract test results read from the P2-T5 JUnit file SCRATCH/issue-1157-pytest-junit.xml
EXIT_CODE: 0
Output Summary:
- Pairs 23; unequal 0. Each line is the source path, the SHA-256 shared by the source and its bundle copy, and the result.
- .claude/agents/atomic-executor.md 1d3f54a824aad9449d9c49890fbecd6475858ea9e8659a5297483273414ae9ac equal
- .claude/agents/atomic-planner.md 6ef656ad8916608368c9f2f9e49f69cc1c98fbc0aa721269941bbcc26362923e equal
- .claude/agents/csharp-typed-engineer.md c294e620bf89252fcdcdbc89fbc7fba9c53d9dfead2090b0bdefe64a1753ba2a equal
- .claude/agents/feature-review.md c2756153ab1c1f190cdacad76f18684214c711dfb5a75a694921ecafbbd41cd6 equal
- .claude/agents/powershell-typed-engineer.md 055087b9f8e29d999b6464e40d61dbec71efff98d8fbe36b70c17dffa019a693 equal
- .claude/agents/prd-feature.md fa5b5b211aee2a76bb4a19d5b7d50d623cfb64b11e0175b72114e27269a9bf20 equal
- .claude/agents/python-typed-engineer.md 98ceb2156319a80193dffea18e95a230bc8cfb5599dbc724d0a22a169430179f equal
- .claude/agents/task-researcher.md 177987cfd7f21f9004c723f98c924ab1004e1a82eae7781a1974bd809102d6bd equal
- .claude/agents/typescript-engineer.md cf4a8e452d8edf9e9d391779a710c742a9695f9a837aefdeafc294c8d54c8e4a equal
- .claude/hooks/enforce-owner-directive-pass-down.ps1 3ba3a12b2d4820172748bd7cbfd98bc0968c06526616be51fdcdfc652e19091e equal
- .claude/hooks/owner-directive-pass-down-target.ps1 0fb994e2666241b7735b9c6b8e8775dd7af7ac9d9e944b9288e0ffc129cea2bf equal
- .claude/hooks/validate-orchestrator-output-owner-pass-down.ps1 bc61fab629243cd79260f22cf77cc1c814989c444562bf0db70e0bafb4e55547 equal
- .claude/hooks/validate-orchestrator-output.ps1 6a00fc5e23af94303b86310b8848fd9962b3c451969691ec7c168f9129982902 equal
- .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1 8283f8b7eb971aeb48508892730c82b13172109c209625a8315b1d280af61a9f equal
- .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1 711027990977a698e44ac4fd44f5a910de78d74a059099f93d5d03163dfec71b equal
- .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1 73a36b3d87966197c0dfc1721c74835f5d7efc6b24601218a50d4a484d5f43e6 equal
- .claude/rules/orchestrator-state.md 42c79680846fad1b6e7ea900d2f7b4035d6cf202e5bb2a28e363c7b40a6cad02 equal
- .claude/settings.json 1b3397d2efda5790a9ce5444d30e65b77b77b02365cc3d8ed0c4594e537d1a77 equal
- .claude/skills/epic-orchestrate/SKILL.md ef59580f8306d5ae8f313d80cb7d25e3718828fcb2a1c116a8491d7b04921517 equal
- .claude/skills/execution-environment/SKILL.md 0c5225d7c4477cdba2c0c0d3e685cced8e90c685c2f7acd679810611715599d9 equal
- .claude/skills/orchestrate/SKILL.md f2887879b92a5b9d5ecff6e8004393ed966246e59cfed805d61d4d9a2ccd6b7c equal
- .claude/skills/owner-directives/SKILL.md 85b54d4b5d3210294fc1f0ebc5d7a6fb3709ea30e5573eba7d6298efe8341f6f equal
- .claude/skills/parallel-orchestrate/SKILL.md 5e03f9fe2fe3111bab2bbb3394482da19e43d0145766b23ddec32d9509098b7e equal
- Contract tests in the P2-T5 run: test_push_down_claude_resource_contracts.py 14 test cases, 0 failed; test_push_down_pack_manifest_dependency_closure.py 18 test cases, 0 failed.
