# Task check [P5-T1]

Timestamp: 2026-11-14T04-35
Command: sh SCRATCH/issue-1159-taskcheck.sh <corpus files> "" (Invoke-Formatter compare, Invoke-ScriptAnalyzer with pssa.settings.psd1); formatting applied first with SCRATCH/issue-1159-fmt.sh
EXIT_CODE: 0
Output Summary: format 0 files needing change; analyzer 0 findings; no test consumes the corpus before [P5-T2], so the test selection is empty.

## Changed files
- tests/scripts/claude-hooks/PreToolUseDispatch.ParityCorpus.Claude.ps1 (115 physical lines; 13 envelopes)
- tests/scripts/claude-hooks/PreToolUseDispatch.ParityCorpus.Codex.ps1 (102 physical lines; 13 envelopes)

## Envelope derivation
Candidate envelopes were probed by running each runtime's dispatcher once per candidate with -PerHookTrace (SCRATCH/issue-1159-probe.sh), with a recording gh stand-in first on PATH and the tracked tree plus .claude/state and .codex/state compared before and after: no gh call, no tracked or untracked file change and no state file change for any candidate. Envelopes kept are those whose outcome is decided by the payload or by an environment variable the envelope sets.

## Hooks without a complete envelope pair (reported by name in [P5-T2])
- Claude enforce-docs-role-write-scope.ps1: deny needs the subagent transcript (filesystem).
- Claude enforce-model-routing-receipt.ps1: allow needs the item worktree and routing receipt on disk (deny is covered by the missing-tool_input envelope).
- Codex enforce-epic-root-invocation.ps1, enforce-codex-model-routing.ps1, enforce-epic-planning-only.ps1: deny needs attestation or epic checkpoint files.
