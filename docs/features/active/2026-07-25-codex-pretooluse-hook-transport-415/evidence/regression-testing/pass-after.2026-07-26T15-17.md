# Pass-After Probe — Detached-HEAD Transport Fixed (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P3-T1]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Findings verified fixed:** C1 (Blocking), A1 (Adjacent, deliberate-behavior per RD-1)
- **Paired with:** `FEATURE/evidence/regression-testing/fail-before.2026-07-26T14-37.md`
- **Probe protocol:** convention C4 (non-committed evidence probe at a short path outside REPO)

Timestamp: 2026-07-26T15-17

## Probe Root

`PROBE_ROOT = C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415` — 50 characters, outside REPO. No file
was created inside REPO by this probe.

## Commands and Results

### 1. HEAD SHA at probe time

Command: `git -C <REPO> rev-parse HEAD`
EXIT_CODE: 0

```
bb12591b048bbf00ffe5a55d91a5287e85231a84
```

This is the post-rebase HEAD carrying the committed [P1-T1] C1 fix. The [P2-T1] A1 fix is present in the
working tree but not yet committed, which is why the overlay in step 4 is required and why the plan
authorizes it ("the fixes need not be committed for the probe").

### 2. Detached worktree creation (C4 add-success gate)

Command: `git -C <REPO> worktree add --detach C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415 bb12591b048bbf00ffe5a55d91a5287e85231a84`
EXIT_CODE: 0

Terminal output (progress lines elided; first and last lines verbatim):

```
Preparing worktree (detached HEAD bb12591b)
Updating files:  37% (2867/7619)
... (progress) ...
Updating files: 100% (7619/7619), done.
HEAD is now at bb12591b fix(codex-hooks): treat an empty live branch as unset on detached HEAD (#415)
```

**ADD_GATE: PASSED** — the output reports `HEAD is now at bb12591b`. No `Filename too long` error; the
checkout is complete (7619/7619 files). Probes are therefore authorized to run.

### 3. Detachment confirmation

Command: `git -C <PROBE_ROOT> branch --show-current`
EXIT_CODE: 0

```
OUTPUT: []  (length=0)
```

Exit code 0 with zero-length output — the same condition that produced the fail-before failures.

Corroborating command: `git -C <PROBE_ROOT> status --short --branch`

```
## HEAD (no branch)
```

### 4. Overlay of the FIXED root hooks and the overlay-integrity check

Command: `Copy-Item <REPO>/.codex/hooks/enforce-epic-child-worktree-binding.ps1 <PROBE_ROOT>/.codex/hooks/ -Force`
EXIT_CODE: 0

```
SRC_SHA256: EAE9CFD299632BB2898C01B36336033A519F2DE2C5852F172F176FA4CE3730DB
DST_SHA256: EAE9CFD299632BB2898C01B36336033A519F2DE2C5852F172F176FA4CE3730DB
HASH_MATCH: True
```

Command: `Copy-Item <REPO>/.codex/hooks/enforce-epic-planning-only.ps1 <PROBE_ROOT>/.codex/hooks/ -Force`
EXIT_CODE: 0

```
SRC_SHA256: F642232C51EB7D27DB40DED41E86E100DB54513DEE1DDE8DD717F8B7DF94FB18
DST_SHA256: F642232C51EB7D27DB40DED41E86E100DB54513DEE1DDE8DD717F8B7DF94FB18
HASH_MATCH: True
```

**OVERLAY_INTEGRITY: PASSED** — both `Get-FileHash` pairs match, so the probed files are byte-identical to
the fixed working-tree hooks. A stale file could not have been silently probed; a mismatch would have
failed this task before any probe ran.

### 5. Probe (a) — C1 required outcome 1

Command: `<BENIGN payload> | pwsh -NoProfile -File <PROBE_ROOT>/.codex/hooks/enforce-epic-child-worktree-binding.ps1`

Payload (single-line JSON, piped via `System.Diagnostics.ProcessStartInfo` with `RedirectStandardInput`):

```json
{"session_id":"probe","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git status"},"cwd":"C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415"}
```

All `CODEX_EPIC_CHILD_*` variables were removed from the child process environment, so the attestation is
inactive (the hook's dormant default, matching a CI runner).

EXIT_CODE: **0** (required 0)

```
STDOUT: []
STDERR: []
```

**FIXED.** `Get-CodexChildGuardLiveBranch` returns `''` when git succeeds with empty output, so the
`.Trim()` that previously threw is gone and the dormant guard allows the call. This matches
normal-checkout behavior exactly.

### 6. Probe (b) — A1 required outcome, RD-1 policy mapping

Command: `<PUSH payload> | pwsh -NoProfile -File <PROBE_ROOT>/.codex/hooks/enforce-epic-planning-only.ps1`

Payload:

```json
{"session_id":"probe","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git push origin main"},"cwd":"C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415"}
```

Checkpoint state observed in the probe worktree, recorded because RD-1 makes the outcome
checkpoint-dependent:

```
CHECKPOINT_PRESENT_IN_PROBE_WORKTREE: False
```

`artifacts/orchestration/orchestrator-state.json` is not tracked, so a fresh worktree checkout does not
contain it. The entrypoint therefore reads `$checkpointRaw = ''`, `CODEX_EPIC_CHILD_EXECUTION_CONTEXT` is
unset, and `Invoke-EpicPlanningOnlyDecision` returns `$null` at its dormant-mode guard.

EXIT_CODE: **0** (required 0)

```
STDOUT: []
STDERR: []
```

**FIXED.** Which RD-1 branch occurred and why: the **dormant allow** branch. Empty stdout is the correct
outcome because the hook is dormant (no preparation checkpoint in the probe worktree), so no decision
envelope is emitted. The deny-envelope branch — the other policy-level outcome RD-1 permits — is the one
that applies when the checkpoint selects preparation; it is locked deterministically at the decision
layer by the [P2-T2] case *"denies a push with an empty current branch while preparation is selected
(RD-1b)"*, which asserts the deny reason matches
`outside the preparation read, branch, commit, push, or validator allowlist`. Both RD-1 outcomes are
therefore evidenced: the dormant allow here, and the preparation deny in the committed test suite.

Critically, neither outcome is exit 2. Exit 2 is now reserved for a genuine `git` failure
(`$LASTEXITCODE -ne 0`), which the [P2-T2] case *"throws the transport-blocked message when the git
wrapper reports a non-zero exit code"* pins.

### 7. Cleanup (C4, mandatory on success or failure)

Command: `git -C <REPO> worktree remove --force C:/Users/DanMoisan/repos/drm-copilot-wt/wt-det-415`
EXIT_CODE: 0 (no output)

Command: `git -C <REPO> worktree prune`
EXIT_CODE: 0 (no output)

Verification: `Test-Path <PROBE_ROOT>` → `False`. `git -C <REPO> worktree list` no longer contains
`wt-det-415`.

Incidental observation, recorded for honesty: the mandated `git worktree prune` also cleared two stale
administrative entries — `.claude/worktrees/agent-a08c9cf1932159e8f` and
`.claude/worktrees/agent-ab68fbeb0ce28fc0d`. Both directories were verified **already absent from disk**
before the prune (`test -d` → no for each), so `prune` removed only bookkeeping for worktrees that no
longer existed. No live worktree was removed, no tracked file changed, and nothing under `.claude/` in
this repository's working tree was created, modified, or deleted (the pruned records live in the primary
checkout's `.git/worktrees/` administrative directory, not in a `.claude/` source path). Hard Constraint 1
is not implicated.

## Output Summary

### Fail-before paired against pass-after

| Probe | Hook | Payload | Fail-before ([P0-T7], SHA `37d0ecb4`) | Pass-after ([P3-T1], SHA `bb12591b` + overlay) | Verdict |
|---|---|---|---|---|---|
| (a) C1 | `enforce-epic-child-worktree-binding.ps1` | BENIGN (`git status`) | exit **2**, stdout `[]`, stderr `[You cannot call a method on a null-valued expression.]` | exit **0**, stdout `[]`, stderr `[]` | **FIXED** |
| (b) A1 | `enforce-epic-planning-only.ps1` | PUSH (`git push origin main`) | exit **2**, stdout `[]`, stderr `[EPIC_PLANNING_ONLY_BLOCKED: current branch could not be resolved before push.]` | exit **0**, stdout `[]`, stderr `[]` (dormant allow) | **FIXED** |

### Gate results

| Gate | Result |
|---|---|
| C4 add-success gate (`HEAD is now at <sha>`) | PASSED |
| Detachment confirmed (exit 0, empty output) | PASSED |
| Overlay integrity — hash pair, worktree-binding hook | MATCH |
| Overlay integrity — hash pair, planning-only hook | MATCH |
| Probe (a): exit 0, empty stdout, empty stderr | PASSED |
| Probe (b): exit 0, empty stderr | PASSED |
| Worktree removed and pruned; `PROBE_ROOT` absent | PASSED |

Both findings are verified fixed in an actual detached-HEAD worktree — the same repository state GitHub
Actions produces when it checks out `refs/pull/N/merge`. Neither hook reports a transport error on a
detached HEAD, and exit 2 remains reserved for genuine git failure.

EXIT_CODE: 0
