# Phase 5 Existing Suites Unchanged in Assertions ([P5-T3], AC-12, AC-13)

Timestamp: 2026-09-27T07-22
Command: sh <SCRATCHPAD>/x707p5-git.sh (sections `T3`): per file `git diff -U0 daae7f796ebbd87e2170df3c86a9901ce11a4b68 HEAD -- <file>` counting added lines (`+` excluding the `+++` header), removed lines (`-` excluding the `---` header), and added lines containing `Should`; `git status --porcelain -- <nine paths>`; `git ls-tree --name-only daae7f796ebbd87e2170df3c86a9901ce11a4b68 tests/scripts/codex-hooks/` filtered to names beginning `enforce-orchestration-preimplementation-gate-` and ending `.Tests.ps1`
EXIT_CODE: 0
Output Summary: Nine rows; every removed-line count and every added-Should count is 0. Mode-resolution, mode-routing, codex-completion-consistency-hook, and enforce-completion-consistency-codex show 0 added lines. The five D10 suites show only their 2- or 3-line mock insertions. Porcelain over the nine paths is empty. The base-tree set is exactly the four expected files.

BASE_SHA: daae7f796ebbd87e2170df3c86a9901ce11a4b68

## Per-file rows

| File | Added lines | Removed lines | Added `Should` lines |
| --- | --- | --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 2 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 0 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` | 0 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 2 | 0 | 0 |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | 2 | 0 | 0 |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | 3 | 0 | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 3 | 0 | 0 |
| `tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1` | 0 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` | 0 | 0 | 0 |

## Porcelain (nine paths)

```
(empty)
```

## Base-tree set (`enforce-orchestration-preimplementation-gate-*.Tests.ps1` under `tests/scripts/codex-hooks/` at BASE_SHA)

```
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
```

Result: the recorded set equals the four files required by the acceptance condition; all counts meet the acceptance condition.
