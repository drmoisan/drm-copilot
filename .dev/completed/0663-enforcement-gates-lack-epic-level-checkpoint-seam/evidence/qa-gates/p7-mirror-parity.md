# Mirror Parity ([P7-T8], AC-16, AC-22)

Timestamp: 2026-09-25T19-52
Command: sh <SCRATCHPAD>/i663/run.sh p7-mirror  (fresh PowerShell 7 process; `(Get-FileHash -Algorithm SHA256 -LiteralPath <p>).Hash.ToLowerInvariant()` and `git hash-object -- <p>` per path); cross-check: git ls-tree -r HEAD -- <28 paths>
EXIT_CODE: 0
Output Summary: Twelve `.claude/**` source/mirror pairs, one four-copy helpers set, and one runsettings pair recorded; every pair and the set have equal SHA-256 and equal `git hash-object` values (AllEqual: True). RS-8 cross-check: `git ls-tree -r HEAD` reports, for all 28 paths, the same blob ID that `git hash-object` computed from the worktree file, so the recorded hashes describe the committed content at HEAD b66d79b6.

Mirror root: `extensions/drm-copilot/resources/claude-customizations/`.

## Twelve .claude pairs

| Source | Source SHA-256 | Mirror SHA-256 | Source git hash-object | Mirror git hash-object | Mark |
| --- | --- | --- | --- | --- | --- |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | ebb3a95392b8b8eb02e2d692804de55ac40503f5 | ebb3a95392b8b8eb02e2d692804de55ac40503f5 | equal |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | bb587d8e3eea0de900a2428a5ee155bf983ae869e697db6a94b2a2898d4da2b3 | bb587d8e3eea0de900a2428a5ee155bf983ae869e697db6a94b2a2898d4da2b3 | 786d22c193a57e670d29b6a3b4b31130e154a689 | 786d22c193a57e670d29b6a3b4b31130e154a689 | equal |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 1bd743bbf35af67caa1e03525129e88ce67029695c81e9d85afcdc0ccf2fdc61 | 1bd743bbf35af67caa1e03525129e88ce67029695c81e9d85afcdc0ccf2fdc61 | 65ae3c30b4a0a28738ada5e0f2b2be6bc09904f4 | 65ae3c30b4a0a28738ada5e0f2b2be6bc09904f4 | equal |
| .claude/hooks/enforce-pr-author-skill-helpers.ps1 | fae566112a3c4b394a9f11e4ef6f7db76ff1569b1ca1ce9eb90c2c5c64ab4e32 | fae566112a3c4b394a9f11e4ef6f7db76ff1569b1ca1ce9eb90c2c5c64ab4e32 | 89b286e8fd286bb1c9005729335f99c16554512e | 89b286e8fd286bb1c9005729335f99c16554512e | equal |
| .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | f47367ef0b7b360f5cf343d742c3086499365ea128e0a05ae363180e4c2ec266 | f47367ef0b7b360f5cf343d742c3086499365ea128e0a05ae363180e4c2ec266 | 66bc15ed51bf12c5e8aa9e89f06fec7b8b5adab9 | 66bc15ed51bf12c5e8aa9e89f06fec7b8b5adab9 | equal |
| .claude/hooks/enforce-model-routing-receipt.ps1 | 59145ac5f0f44aa4ea1fa0a6e78bd3520446837406521cadf63fd1bdf500f586 | 59145ac5f0f44aa4ea1fa0a6e78bd3520446837406521cadf63fd1bdf500f586 | 1a3216a27716e683794cc1e048e88525dee4d2d2 | 1a3216a27716e683794cc1e048e88525dee4d2d2 | equal |
| .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 7d5d603e61480732326c05bca7848f765c33e98e5a5265e917ec28f91cd80a61 | 7d5d603e61480732326c05bca7848f765c33e98e5a5265e917ec28f91cd80a61 | 2bdcadee2697a19d96a028b744aaa89ebaff92ab | 2bdcadee2697a19d96a028b744aaa89ebaff92ab | equal |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | 30ba3d84926953536018e7d473238cf52bb4900555dc177c81cf518bd74d88b1 | 30ba3d84926953536018e7d473238cf52bb4900555dc177c81cf518bd74d88b1 | 2859877be01cd3978285c4e65d203e19e5de5d7a | 2859877be01cd3978285c4e65d203e19e5de5d7a | equal |
| .claude/skills/epic-plan/SKILL.md | 61362a445de03fc4202881ce4f59b2292b5bd37a42c4553cdbd6147f993df595 | 61362a445de03fc4202881ce4f59b2292b5bd37a42c4553cdbd6147f993df595 | d884bb8daf8027781a1043d3f9da27c2e72a66a4 | d884bb8daf8027781a1043d3f9da27c2e72a66a4 | equal |
| .claude/skills/epic-orchestrate/SKILL.md | 14d6bf2f76f64d8c6be9c7c675e828f474ebc20d52ed60096d612302a77f21a0 | 14d6bf2f76f64d8c6be9c7c675e828f474ebc20d52ed60096d612302a77f21a0 | acd7bc6ff6633523eb728104bc55b3cc50258e07 | acd7bc6ff6633523eb728104bc55b3cc50258e07 | equal |
| .claude/agents/epic-planner.md | 3ebf5ab00d651866900d45f5625046626b8a11052a64629081350eb7e0a7570c | 3ebf5ab00d651866900d45f5625046626b8a11052a64629081350eb7e0a7570c | 4cd57e20f5a05d14543c0153e78c74046ca699c0 | 4cd57e20f5a05d14543c0153e78c74046ca699c0 | equal |
| .claude/agents/epic-orchestrator.md | 0d01e5484d63e418a6bc31f219aecaef7381cc439a4a796664006879f6a027ba | 0d01e5484d63e418a6bc31f219aecaef7381cc439a4a796664006879f6a027ba | 24c861bae8bcbb683a760e5f254e3234e18f2487 | 24c861bae8bcbb683a760e5f254e3234e18f2487 | equal |

PairCount: 12

## Four-copy helpers set

| Copy | SHA-256 | git hash-object |
| --- | --- | --- |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | ebb3a95392b8b8eb02e2d692804de55ac40503f5 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | ebb3a95392b8b8eb02e2d692804de55ac40503f5 |
| extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | ebb3a95392b8b8eb02e2d692804de55ac40503f5 |
| extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 28164c591831d1f3e62dc2a5dbecea0abebd1792d607a95aec191be943486c77 | ebb3a95392b8b8eb02e2d692804de55ac40503f5 |

HelpersSet: equal

## Runsettings pair

| Source | Source SHA-256 | Mirror SHA-256 | Source git hash-object | Mirror git hash-object | Mark |
| --- | --- | --- | --- | --- | --- |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 -> extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | 5988cba0f4a1700dda571f36652623d797d1dc1d5a4b12a462a483fc79f35eda | 5988cba0f4a1700dda571f36652623d797d1dc1d5a4b12a462a483fc79f35eda | 8499327d02ab3ff7de8c049c3f1157fd2c5665ee | 8499327d02ab3ff7de8c049c3f1157fd2c5665ee | equal |

AllEqual: True

## RS-8 cross-check against git object storage

`git ls-tree -r HEAD` over the 28 paths returned the blob IDs listed in the `git hash-object` columns above for every path (for example `ebb3a95392b8b8eb02e2d692804de55ac40503f5` for all four helpers copies and `8499327d02ab3ff7de8c049c3f1157fd2c5665ee` for both runsettings copies).

Result: PASS
