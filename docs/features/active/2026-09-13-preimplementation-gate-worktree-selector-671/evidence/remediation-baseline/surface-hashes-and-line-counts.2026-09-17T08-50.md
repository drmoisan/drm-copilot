# Remediation Baseline — Surface Hashes and Line Counts (issue #671, R1)

Timestamp: 2026-09-17T09-37
Task: [P0-T4]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/p0t4.ps1` (per path: `(Get-FileHash -LiteralPath <p>).Hash` and `@(Get-Content -LiteralPath <p>).Count`; plus `(Get-Location).Path`, `git rev-parse --show-toplevel`, `git rev-parse HEAD`, `git merge-base --is-ancestor 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD` with `$LASTEXITCODE`, and a line scan of `git show 79fd5a95c00cd99238b69a3195788206ae96f4cd:.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`); then, through the Git route, `git diff --stat 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD -- <spec.md, four helpers copies, three suites>`, `git diff --name-status 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD`, and `git status --porcelain`.
EXIT_CODE: 0

## Location and revision

- `(Get-Location).Path`: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686` (normalized: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686`)
- `git rev-parse --show-toplevel`: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686`
- `git rev-parse HEAD`: `d082697789ea18167a1889c95a17aa11026463be`
- `git merge-base --is-ancestor 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD` exit code: `0`

## Helpers copies

| Path | SHA256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1 | 433 |

Distinct helpers hashes: `1`. This equals the hash on `evidence/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md` line 7 (`5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1`), so that artifact is the valid pre-fix reference for the 20-row comparison.

## Test suites

| Path | SHA256 | Lines |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | EA600CB7C3C488692545B0EE4BF3ED1C3B24D3721394C72C2CB540EE3B5ADADD | 350 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 4975F491CF94A10EA9E1419150DAB13B08E59EA79F6C7B8DBB7C550B0F899A4F | 357 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | C2066DD1FA37F9ADFBB91B0EBD86EA474033C4FD64A40236D1FF4DFE7A1B7F85 | 54 |

## Protected files (must not change)

| Path | SHA256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 218CBFADD55CC51547488332C33213339AF42E56B73408005F97101A06D9C176 | 496 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB | 500 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 218CBFADD55CC51547488332C33213339AF42E56B73408005F97101A06D9C176 | 496 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 427CA3034A7268EA37EE176DCC990F3DBB113A143D15B3D2E0AF0236D091A9BB | 500 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 5216EB9FD638C92761FFB553A8C8829BC3BA1EDAAA578AFF10755CB16A8806CD | 480 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A | 477 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 5216EB9FD638C92761FFB553A8C8829BC3BA1EDAAA578AFF10755CB16A8806CD | 480 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A | 477 |
| `.claude/hooks/hook-command-invocation.ps1` | B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609 | 483 |
| `.codex/hooks/hook-command-invocation.ps1` | B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609 | 483 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` | B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609 | 483 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` | B82246C61BB9FCB44AD6471DFA15278069C599AC3A52DA26E62EDE0CF1E92609 | 483 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 05FEEC2AE5CA73A8EA25314D4E7CA3219E3D023E1BBE8D2076E3905E5961D0E5 | 487 |

## Pre-change coordinates (from `git show 79fd5a95…:.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, 349 lines)

- Single line containing `[AllowEmptyCollection()][string[]] $Token)`: line `221`
- Single line containing `foreach ($segment in $segments) {`: line `342`

## Git-route captures (verbatim)

`git diff --stat 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD -- docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md <four helpers copies> <three suites>`:

```
```

(empty output)

`git diff --name-status 03f4f305765e15745b9275f3a8fd42758f2c6873 HEAD`:

```
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/code-review.2026-09-17T08-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/feature-audit.2026-09-17T08-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/policy-audit.2026-09-17T08-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-inputs.2026-09-17T08-40.md
A	docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-plan.2026-09-17T08-44.md
```

`git status --porcelain` (taken after [P0-T1]–[P0-T3] wrote their artifacts and check-offs):

```
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/remediation-plan.2026-09-17T08-44.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-batch-budget-reset.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/other/remediation-inputs-read.2026-09-17T08-50.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/remediation-baseline/
```

Output Summary:
- Both location values normalize to `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686`: PASS.
- Four helpers hashes collapse to one value (`5C906A2A…13B1`), each 433 lines; the hash equals pass-after artifact line 7: PASS.
- Suites count 350, 357, 54: PASS.
- Pre-change line numbers 221 and 342: PASS.
- `--is-ancestor` exit 0, and the limited `git diff --stat` printed nothing: PASS.
- Neither the `--name-status` capture nor the porcelain capture lists a `.ps1` or `.py` path: PASS.
- HEAD observed: `d082697789ea18167a1889c95a17aa11026463be`. Phase 1 is not blocked.
