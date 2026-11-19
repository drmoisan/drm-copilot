# Scope Assertions — [P3-T4]

Timestamp: 2026-11-18T11-18
Command: `sh SCRATCH/issue-1030-scope.sh` (BASE is `git merge-base origin/epic/shared-agent-harness-layer-integration HEAD`; the changed set is `git diff --name-status <BASE> HEAD` together with `git status --porcelain`, which printed 0 lines because every change is committed)
EXIT_CODE: 0
Output Summary: `SCOPE-FAILURES=0`; every assertion holds, and the greatest `pester-gate.*.md` (`pester-gate.2026-11-18T11-16.md`) reports `sets the Codex dispatcher timeout to the registry timeout sum` passing.

| Assertion | Result |
| --- | --- |
| No path in `CAPPED` (root or bundle) | PASS |
| No `.claude/agents/*.md`, `.claude/settings.json` or `.claude/hooks/pretooluse-dispatch.json` path, nor their bundle copies | PASS |
| No path under `docs/engineering/process-reductions/` | PASS |
| No execution-environment brief copy | PASS |
| No path under `extensions/drm-copilot/src/` or `packages/` | PASS |
| No added `.py` or `.ts` file | PASS |
| Every added hook and test file is `.ps1` or `.psm1` | PASS |
| AD-8: no `.codex/hooks/enforce-feature-folder-order.ps1` root or `BUNDLE` path | PASS |
| AD-8: no `.codex/hooks/pretooluse-dispatch.json` root or `BUNDLE` path | PASS |
| AD-8: no `tests/scripts/claude-hooks/PreToolUseDispatch.ParityCorpus.Codex.ps1` or `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1` path | PASS |
| `.codex/config.toml` diff against BASE adds only the pr-author `[[hooks.SubagentStop]]` table (0 removed lines), leaves the dispatcher `timeout` unchanged, and every added command starts with `pwsh` | PASS |
| Same for the `BUNDLE` `.codex/config.toml` | PASS |

Changed set (50 paths): `.codex/config.toml` (M), `.codex/hooks/subagentstop-envelope.ps1` (A), `.codex/hooks/validate-pr-author-output.ps1` (A), `config/harness-parity-matrix.json` (M), the `BUNDLE` copies of the two hooks (A) and of `.codex/config.toml` (M), `BUNDLE-MANIFEST` (M), `scripts/harness/HarnessHookParity.psm1` (A), eleven Pester test files and helpers under `tests/scripts/` (A or M), `FEATURE/hook-parity-dispositions.md` (A), the plan, `spec.md` and `user-story.md` check-offs (M), and the feature evidence files (A).
