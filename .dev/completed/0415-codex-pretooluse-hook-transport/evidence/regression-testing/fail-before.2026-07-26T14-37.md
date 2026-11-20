# Fail-Before Probe — Detached-HEAD Transport Failure (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P0-T7] `[expect-fail]`
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Findings reproduced:** C1 (Blocking), A1 (Adjacent, deliberate-behavior)
- **Probe protocol:** convention C4 (non-committed evidence probe at a short path outside REPO)

Timestamp: 2026-07-26T14-37

## Expected-Failure Declaration

This task is tagged `[expect-fail]`. A **failing** hook invocation is the required outcome: both hooks must
exit 2 with the diagnostic stderr recorded below, reproducing CI run 30213678367 against head `06473a63`.
A `worktree add` failure is **not** the expected probe failure; the C4 add-success gate below distinguishes
the two so that an add failure cannot be mistaken for a reproduction.

## Probe Root

`PROBE_ROOT = C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415` — 50 characters, outside REPO. The session
scratchpad path (148 characters) is not used: `core.longpaths` is unset and worktree checkout there fails with
`Filename too long` on this repository's long feature-doc paths.

## Commands and Results

### 1. HEAD SHA at probe time

Command: `git -C <REPO> rev-parse HEAD`
EXIT_CODE: 0

```
37d0ecb46c222ddd3f20d1e26e5742ecf26acd73
```

This equals the [P0-T2] recorded `<BASELINE_SHA>`; the probe therefore exercises the pre-fix code exactly as
committed. Preflight confirmed no non-docs file changed between the CI failure commit `06473a63` and this SHA.

### 2. Detached worktree creation (C4 add-success gate)

Command: `git -C <REPO> worktree add --detach C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415 37d0ecb46c222ddd3f20d1e26e5742ecf26acd73`
EXIT_CODE: 0

Terminal output (progress lines elided; first and last lines verbatim):

```
Preparing worktree (detached HEAD 37d0ecb4)
Updating files:  40% (3071/7503)
... (progress) ...
Updating files: 100% (7503/7503), done.
HEAD is now at 37d0ecb4 docs(415): clear cycle-2 remediation plan preflight
```

**ADD_GATE: PASSED** — the output reports `HEAD is now at 37d0ecb4`. No `Filename too long` error; the
checkout is complete (7503/7503 files). Probes are therefore authorized to run.

### 3. Detachment confirmation

Command: `git -C <PROBE_ROOT> branch --show-current`
EXIT_CODE: 0

```
OUTPUT: []  (length=0)
```

Exit code 0 with zero-length output. This is the precise condition that triggers both defects: git
**succeeds** while emitting nothing, so a `$LASTEXITCODE -ne 0` guard does not fire.

Corroborating command: `git -C <PROBE_ROOT> status --short --branch`

```
## HEAD (no branch)
```

### 4. Probe (a) — C1 reproduction

Command: `<BENIGN payload> | pwsh -NoProfile -File <PROBE_ROOT>/.codex/hooks/enforce-epic-child-worktree-binding.ps1`

Payload (single-line JSON, piped via `System.Diagnostics.ProcessStartInfo` with `RedirectStandardInput`):

```json
{"session_id":"probe","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git status"},"cwd":"C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415"}
```

All `CODEX_EPIC_CHILD_*` environment variables were removed before the probe, so the attestation is inactive
(the hook's dormant default, matching a CI runner).

EXIT_CODE: **2** (expected 2)

```
STDOUT: []
STDERR: [You cannot call a method on a null-valued expression.]
```

**REPRODUCED.** This is the exact stderr reported by the failing CI integration case:
`enforce-epic-child-worktree-binding.ps1 x Bash: exit=2 stdout=[] stderr=[You cannot call a method on a null-valued expression.]`.

Root cause, `.codex/hooks/enforce-epic-child-worktree-binding.ps1:311-316` (verified against the file at this SHA):

```powershell
$liveBranch = [string](Invoke-CodexChildGuardGit -GitArgs @('-C', $repositoryRoot, 'branch', '--show-current'))
if ($LASTEXITCODE -ne 0) {
    $liveBranch = ''
}
$decision = Invoke-CodexEpicChildGuardDecision -PayloadRaw $payloadRaw -ReceiptRaw $receiptRaw `
    -Attestation $attestation -HookRepositoryRoot $repositoryRoot -LiveBranch $liveBranch.Trim() `
```

`[string](<empty pipeline>)` yields `$null`, not `''`. The guard keys only on `$LASTEXITCODE -ne 0`, which is
`0` here, so `$liveBranch` stays `$null` and `$liveBranch.Trim()` throws. The `catch` writes the message to
stderr and exits 2.

### 5. Probe (b) — A1 reproduction

Command: `<PUSH payload> | pwsh -NoProfile -File <PROBE_ROOT>/.codex/hooks/enforce-epic-planning-only.ps1`

Payload:

```json
{"session_id":"probe","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git push origin main"},"cwd":"C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415"}
```

EXIT_CODE: **2** (expected 2)

```
STDOUT: []
STDERR: [EPIC_PLANNING_ONLY_BLOCKED: current branch could not be resolved before push.]
```

**REPRODUCED.** Root cause, `.codex/hooks/enforce-epic-planning-only.ps1:271-278`:

```powershell
if ([string]$payload.tool_name -eq 'Bash' -and
    [string]$payload.tool_input.command -match '^\s*git\s+push\b') {
    $currentBranch = [string](& git -C $repositoryRoot branch --show-current 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($currentBranch)) {
        throw 'EPIC_PLANNING_ONLY_BLOCKED: current branch could not be resolved before push.'
    }
    $currentBranch = $currentBranch.Trim()
}
```

Here the `IsNullOrWhiteSpace` clause does fire, so no null-method error occurs; instead the hook takes the
`throw` → exit-2 path. Per RD-1 a detached HEAD is a legitimate repository state, not a transport failure, and
this outcome occurs even when the hook is dormant (no preparation checkpoint), so exit 2 is the wrong signal.
The deliberate corrected behavior is: keep exit 2 only when git genuinely fails (`$LASTEXITCODE -ne 0`), and
route empty successful output into the unmodified decision layer.

### 6. Cleanup (C4, mandatory on success or failure)

Command: `git -C <REPO> worktree remove --force C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415`
EXIT_CODE: 0 (no output)

Command: `git -C <REPO> worktree prune`
EXIT_CODE: 0 (no output)

Verification: `Test-Path <PROBE_ROOT>` → `False`. `git -C <REPO> worktree list` no longer contains
`wt-det-415`; the pre-existing worktree set is unchanged. No file was created inside REPO by this probe.

## Output Summary

| Probe | Hook | Payload | Expected | Observed exit | Observed stdout | Observed stderr | Verdict |
|---|---|---|---|---|---|---|---|
| (a) C1 | `enforce-epic-child-worktree-binding.ps1` | BENIGN (`git status`) | exit 2, empty stdout, null-method stderr | **2** | `[]` | `[You cannot call a method on a null-valued expression.]` | REPRODUCED |
| (b) A1 | `enforce-epic-planning-only.ps1` | PUSH (`git push origin main`) | exit 2, empty stdout, `EPIC_PLANNING_ONLY_BLOCKED` stderr | **2** | `[]` | `[EPIC_PLANNING_ONLY_BLOCKED: current branch could not be resolved before push.]` | REPRODUCED |

Add-success gate PASSED (`HEAD is now at 37d0ecb4`). Both probes reproduce the CI failure signature at the
recorded baseline SHA. Probe worktree removed and pruned; `PROBE_ROOT` no longer exists. The fail-before
condition is established and will be paired against the [P3-T1] pass-after probe.

EXIT_CODE (task): 0 — the `[expect-fail]` outcome was obtained as specified.
