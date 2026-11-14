# Derived sets on the merged tree — main-sync cycle 1 ([P0-T4])

Timestamp: 2026-11-14T07-17
Command: sh SCRATCH/issue-1159-c1-sets.sh -- for every hook of .claude/hooks/pretooluse-dispatch.json and .codex/hooks/pretooluse-dispatch.json, the dot-source closure and module edges from Get-HookScriptEdge (tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1); per file: guarded Import-Module ... -Force lines, D13 tail (exit (Invoke-...EntryPoint)), content change and changed imported modules between merge bases 063504dc4b2ea08a2c5bd39b57d70ce5963815ed and 2c8dee6dd3a82f210561d9efe623767ae902de51; (c) changed files under tests/, .claude/lib/, .claude/hooks/, .codex/hooks/, scripts/ that read PreToolUse data from .claude/settings.json or .codex/config.toml; cross-check by searching the changed files for settings.json, config.toml and pretooluse-dispatch
EXIT_CODE: 0
Output Summary: (a) D13 tails: 0 members across both registries; no unhandled member. (b) D6 guarded -Force edges: 1 member, .claude/hooks/enforce-model-routing-receipt-docs.ps1 (new helper dot-sourced by the registered .claude/hooks/enforce-model-routing-receipt.ps1) with its guarded DocsReceiptRevision.psm1 -Force edge (finding F1); unhandled, because the file and the module are both new between the merge bases. (c) registration consumers: 0 changed files read PreToolUse registration data; no unhandled consumer.

## Set (a) — D13 tails (exit (Invoke-...EntryPoint))
| Hook | Tail | Unhandled |
|---|---|---|
| (none) | every registry hook of both runtimes ends in another form; the changed registered hooks end in exit ([int]$entryPointResult[-1]) (Claude preimplementation gate, docs-complete gate), exit 0 (model-routing receipt) or a closing brace (Codex preimplementation gate) | n/a |

## Set (b) — D6 guarded Import-Module -Force edges
| File | Owning registered hook | Edge | Content changed | Imported module changed | Unhandled |
|---|---|---|---|---|---|
| .claude/hooks/enforce-model-routing-receipt-docs.ps1 | .claude/hooks/enforce-model-routing-receipt.ps1 | DocsReceiptRevision.psm1 (guarded, -Force) | yes (added) | .claude/lib/docs/DocsReceiptRevision.psm1 (added) | yes |

Changed files in the hook closures with no guarded -Force edge, so they are not (b) members (recorded for [P0-T5] and [P0-T6]): .claude/hooks/enforce-orchestration-preimplementation-gate.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1, .claude/hooks/hook-docs-estate-context.ps1, .claude/hooks/hook-docs-only-diff.ps1 (dot-sourced by enforce-pr-author-skill.ps1, enforce-epic-merge-gate.ps1, enforce-docs-complete-gate.ps1, enforce-model-routing-receipt.ps1 and the preimplementation gate closures), .claude/hooks/enforce-docs-complete-gate.ps1 (imports the changed .claude/lib/docs/DocsCompleteGate.psm1 without -Force; DocsCompleteGate.psm1 imports DocsReceiptRevision.psm1 nested, without -Force), .claude/hooks/enforce-model-routing-receipt.ps1, and the Codex .codex/hooks/enforce-orchestration-preimplementation-gate.ps1, enforce-orchestration-preimplementation-gate-docs.ps1, hook-docs-estate-context.ps1 and hook-docs-only-diff.ps1 (no module imports).

## Set (c) — registration consumers
| File | In approved Phase 4 or a pre-cycle main-integration record | Unhandled |
|---|---|---|
| (none) | no changed file under tests/, .claude/lib/, .claude/hooks/, .codex/hooks/ or scripts/ names settings.json, config.toml or pretooluse-dispatch | n/a |
