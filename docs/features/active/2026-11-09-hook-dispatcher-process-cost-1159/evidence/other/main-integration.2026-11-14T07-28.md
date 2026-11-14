# Main-sync integration record — remediation cycle 1 ([P1-T6])

Timestamp: 2026-11-14T07-28
Command: git merge-base origin/main HEAD; cmp of every repository/bundle pair of the [P0-T1] hook and module list and of the file changed by [P1-T1]; search of extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json and extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json for each path; sh SCRATCH/issue-1159-c1-gen.sh (poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check from the worktree root)
EXIT_CODE: 0
Output Summary: The orchestrator main sync merged origin/main 2c8dee6dd3a82f210561d9efe623767ae902de51 (issues 1160 and 1169) in merge commit 1083e7680, with no conflicts. Merge bases: previous 063504dc4b2ea08a2c5bd39b57d70ce5963815ed, new 2c8dee6dd3a82f210561d9efe623767ae902de51. Inventory: no PreToolUse change arrived, and registrations are unchanged (both registries equal at the new merge base). Unhandled members: (a) none; (b) one, and -Force was removed from it; (c) none. Corpus: no change needed. Mirrors: 17 of 17 pairs equal, every path listed in its core.json, generator check exit 0. Post-integration registrations outside the dispatcher: Claude 0, Codex 0.

## Merge
- Main-sync merge commit: 1083e7680 (Merge remote-tracking branch 'origin/main' into feature/hook-dispatcher-process-cost-1159); second parent 2c8dee6dd3a82f210561d9efe623767ae902de51.
- Merge base before the merge (from main-integration.2026-11-14T06-37.md): 063504dc4b2ea08a2c5bd39b57d70ce5963815ed.
- Merge base after (git merge-base origin/main HEAD): 2c8dee6dd3a82f210561d9efe623767ae902de51; git merge-base --is-ancestor of the merged origin/main commit against HEAD: exit 0. Record: evidence/remediation-baseline/main-sync-merge.2026-11-14T07-06.md.

## Inventory
- no PreToolUse change arrived: the PreToolUse blocks of .claude/settings.json and .codex/config.toml at the new merge base regenerate both registries byte for byte (evidence/other/main-sync-registrations.2026-11-14T07-09.md).
- registrations unchanged ([P1-T3] skip branch).

## Unhandled members and actions (evidence/other/main-sync-sets.2026-11-14T07-17.md)
| Set | Member | Action |
|---|---|---|
| (a) D13 | none | none. The D13 tail run on the 4 changed registered hooks shows FailOpen: no for each (evidence/baseline/d13-tail-output.2026-11-14T07-19.md). [P1-T2] wrote the N/A record evidence/regression-testing/d13-remediation.2026-11-14T07-26.md |
| (b) D6 | .claude/hooks/enforce-model-routing-receipt-docs.ps1 (DocsReceiptRevision.psm1 edge) | -Force removed ([P1-T1]); the module was audited stateless (evidence/other/d6-module-audit.2026-11-14T07-19.md); no registry notes entry |
| (c) consumers | none | none ([P1-T4] skip branch) |

## Parity corpus ([P1-T5])
| Hook | Result |
|---|---|
| .claude/hooks/enforce-docs-complete-gate.ps1 | allow bash-allow, deny bash-missing-tool-input |
| .claude/hooks/enforce-model-routing-receipt.ps1 | deny agent-missing-tool-input; allow covered by a recorded NoEnvelope reason |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | allow bash/write/agent-allow, deny bash/write/agent-missing-tool-input |
| .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 | allow bash-allow and patch-allow, deny bash- and patch-missing-tool-input |

## Mirrors and core.json
All 17 hook and module paths of the [P0-T1] list have a bundle copy that is byte-equal (cmp) and are listed once in their runtime's core.json. These are the 13 under .claude/hooks and .claude/lib/docs and the 4 under .codex/hooks. The list includes .claude/hooks/enforce-model-routing-receipt-docs.ps1, the one file this cycle changed. No missing manifest path. Codex generator --check: exit 0.

## Paths this cycle changed
- .claude/hooks/enforce-model-routing-receipt-docs.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt-docs.ps1
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/remediation-plan.2026-11-14T06-51.md and new evidence files under docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/

## Post-integration inventory (PreToolUse registrations outside the dispatcher; agent-frontmatter hooks excluded per D11)
- Claude .claude/settings.json: 0
- Codex .codex/config.toml: 0
