# Pre-merge integration pass ([P7-T1])

Timestamp: 2026-11-14T06-37
Command: git fetch origin main; git merge --no-ff origin/main; git merge-base origin/main HEAD; git merge-base --is-ancestor origin/main HEAD; SCRATCH/issue-1159-genreg.ps1 (registry regeneration at the merge base); SCRATCH/issue-1159-sets.ps1 (sets (a) and (b)); git grep consumer search (c); sh SCRATCH/issue-1159-taskcheck.sh over the integration selection
EXIT_CODE: 0
Output Summary: merged origin/main 063504dc4b2ea08a2c5bd39b57d70ce5963815ed (issue 1160) without conflicts; new merge base 063504dc4b2ea08a2c5bd39b57d70ce5963815ed, an ancestor of HEAD. PreToolUse inventory diff against the [P0-T2] inventory: one Claude group added (enforce-owner-directive-pass-down.ps1, issue 1157), nothing removed, reordered or changed; Codex unchanged. Post-integration PreToolUse registrations outside the dispatcher: Claude 0, Codex 0 (one [[hooks.PreToolUse]] table naming the dispatcher). Integration selection: Pester 2424 passed, 0 failed, 6 skipped.

## Merge
- Result: merged (no conflicts); merge commit on feature/hook-dispatcher-process-cost-1159 records this pass.
- origin/main merged: 063504dc4b2ea08a2c5bd39b57d70ce5963815ed (Merge pull request #1174, issue 1160). The orchestrator's earlier main sync (merge commit ccc307aae, origin/main f9e817b2ace9875b24f3df8ad27b97a4065a435e) is included.
- Merge base before this merge: f9e817b2ace9875b24f3df8ad27b97a4065a435e. Merge base after (git merge-base origin/main HEAD): 063504dc4b2ea08a2c5bd39b57d70ce5963815ed. git merge-base --is-ancestor origin/main HEAD: exit 0.

## Inventory diff (derived inventory of [P0-T2] at 228e6f8c4606e53f36963dc9aa57d71b4882b49e versus the new merge base)
- Added: Claude group 6, matcher Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|mcp__.*, command pwsh -NoProfile -File .claude/hooks/enforce-owner-directive-pass-down.ps1 (issue 1157), placed after the five existing groups as at the merge base.
- Removed, reordered, changed matcher, changed command, changed Codex timeout: none.
- Entries left beside the dispatcher by the merges: Claude .claude/settings.json held the owner-directive entry beside the dispatcher (from the main sync); removed. Codex: none.

## Actions
- Registries: both regenerated from the new merge base with the recreated [P3-T1] helper SCRATCH/issue-1159-genreg.ps1, which first reproduced both committed registries byte for byte from 228e6f8c4606e53f36963dc9aa57d71b4882b49e; .claude/hooks/pretooluse-dispatch.json gains the owner-directive group; .codex/hooks/pretooluse-dispatch.json is unchanged. isolation and notes kept.
- Dispatcher registration: .claude/settings.json keeps one PreToolUse entry; the union matcher Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|WebFetch|WebSearch|mcp__.* already admits every owner-directive tool name, so it is unchanged. Codex dispatcher table and timeout sum (690) unchanged.
- Set (a), D13 tails: recomputed over all registry hooks of both runtimes; no unhandled member (the owner-directive hook and every hook whose content changed end in a form other than exit (Invoke-...EntryPoint)). No d13-tail-output file is needed; the [P1-T1] It already exists.
- Set (b), D6: 7 unhandled members; -Force removed from 16 guarded edges after auditing 9 modules as stateless; record d6-module-audit.2026-11-14T04-58.md.
- Consumer search (c): arrived consumer tests/scripts/claude-runtime/owner-directive-pass-down.Registration.Tests.ps1 re-targeted ('registers exactly one PreToolUse pass-down group in <Path>' reads both registry copies; intent kept). cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 and hook-dependency-failure.Claude.Tests.ps1 also changed on main; both already read the registry through the Phase 4 re-targeting.
- Parity corpus, arrived registry hook: enforce-owner-directive-pass-down.ps1 -- allow envelopes: the existing bash-allow, write-allow, agent-allow and mcp-allow envelopes select it (it emits no decision without a ledger); no deny envelope: a deny needs an owner-directive ledger or checkpoint entry under artifacts/orchestration (filesystem mock), and a missing tool_input ends in a terminating error (exit 1, no decision). Reason recorded in PreToolUseDispatch.ParityCorpus.Claude.ps1 NoEnvelope.
- Bundle mirrors refreshed (cmp equal): .claude/settings.json, .claude/hooks/pretooluse-dispatch.json and the 7 set-(b) files. core.json: no new path (all already listed).

## Post-integration inventory (PreToolUse registrations outside the dispatcher; agent-frontmatter hooks excluded per D11)
- Claude .claude/settings.json: 0
- Codex .codex/config.toml: 0

## Observation (not changed here)
enforce-owner-directive-pass-down.ps1 ends a missing-tool_input payload in a terminating error (exit 1), which PreToolUse treats as non-blocking, in both per-process and in-process modes; the parity suite shows the two modes agree. This is the hook's existing behavior from issue 1157 and is reported to the orchestrator.

## Addendum ([P7-T4] and [P7-T8])
Supersedes main-integration.2026-11-14T05-03.md (and through it 05-02). Content above is unchanged except the timestamp; this section adds the paths the final gates showed and the earlier record did not list.

- docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch -- arrived consumer of hook text: the main sync brought a 0010 stored patch (regenerated on main by issue 1157) whose hunk context for .claude/hooks/enforce-epic-wave-barrier.ps1 and its bundle copy holds the guarded imports with -Force that [P3-T2] removed. Pester run 1 of [P7-T4] failed the ledger chain (PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-SUBCHAIN-HOLDS); action: the four context lines now carry the D6 edit in both images, committed with 'reduction: 0010' in the subject (record: evidence/qa-gates/pester.2026-11-14T05-36.md).
- tests/fixtures/dev-tools/hook-process-cost/stdin-exit-hook.ps1 -- test fixture of the [P0-T8]/[P0-T9] measurement-tool suites (recorded in evidence/baseline/leak-scan.2026-11-10T04-33.md); no action.
- origin/main advanced after this pass to 2c8dee6dd3a82f210561d9efe623767ae902de51 (PR #1175, issue 1169: preimplementation gate docs helper, docs hooks, .claude/lib/docs modules including DocsCompleteGate.psm1). No .claude/settings.json or .codex/config.toml PreToolUse change arrived with it. Per the plan's Open Questions, movement after [P7-T1] is handled by the orchestrator's main sync; it is not merged here.
