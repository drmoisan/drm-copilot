# Portable Fallback Verification and Codex-Mirror Negative Claim (issue #413)

Timestamp: 2026-07-25T17-01

Purpose: verify (verify-only, no edits) that the `else` branch of the hook's default
`$Invoker` — `Test-OrchestratorStateCompletionReadiness` — carries no analogue of the
defect being fixed, and that it remains fail-closed under exit-code-only discrimination.
Covers plan tasks [P1-T1], [P1-T2], and [P1-T3].

## [P1-T1] Repo copy — `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`

Function: `Test-OrchestratorStateCompletionReadiness`. Three return sites, quoted with line
numbers as read from the file:

1. Line 227 — load-failure error path:

   ```powershell
   227:        return @{ ExitCode = 1; Output = $loaded.Error }
   ```

   Preceded by the guard at lines 223-226:

   ```powershell
   223:    # Fail closed when the checkpoint cannot be loaded: the load error is the whole
   224:    # output and ExitCode is 1.
   225:    $loaded = Get-OrchestratorStateCheckpoint -CheckpointPath $CheckpointPath
   226:    if (-not $loaded.Ok) {
   ```

2. Line 237 — combined base-presence error and model-routing gate error path:

   ```powershell
   232:    $errors = [System.Collections.Generic.List[string]]::new()
   233:    $errors.AddRange([string[]]@(Get-OrchestratorStateBasePresenceError -State $loaded.State))
   234:    $errors.AddRange([string[]]@(Get-OrchestratorStateModelRoutingGateError -State $loaded.State))
   235:
   236:    if ($errors.Count -gt 0) {
   237:        return @{ ExitCode = 1; Output = ($errors -join [System.Environment]::NewLine) }
   238:    }
   ```

   Both the base-presence error source and the gate error source accumulate into the same
   `$errors` list and therefore share this single `ExitCode = 1` return.

3. Line 240 — success path:

   ```powershell
   240:    return @{ ExitCode = 0; Output = '' }
   ```

Confirmation:

- (a) The success return is literally `@{ ExitCode = 0; Output = '' }` — **confirmed** (line 240).
  `Output` is the empty string literal, never a success message, so this branch can never
  present success text as error text.
- (b) Every error path (load failure, base-presence error, gate error) sets `ExitCode = 1` —
  **confirmed** (line 227 for load failure; line 237 for base-presence and gate errors, which
  share one accumulated return).

Consequence: `ExitCode = 0` with non-empty `Output` is structurally impossible on this
branch. It never false-blocked even under the defective two-disjunct rule, and after the fix
its fail-closed behavior is preserved because `ExitCode` fully discriminates. The module's
own docstring states the same contract at lines 207 and 214
(`ExitCode is 1 whenever any error is present, and Output carries the newline-joined error
text (empty on success)`; `ExitCode (int, 0 or 1)`).

No edit was made to this file.

## [P1-T2] Bundled copy — `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`

The same three return sites appear at the identical line numbers with identical text:

```powershell
227:        return @{ ExitCode = 1; Output = $loaded.Error }
237:        return @{ ExitCode = 1; Output = ($errors -join [System.Environment]::NewLine) }
240:    return @{ ExitCode = 0; Output = '' }
```

The surrounding docstring (lines 204-214) and the guard/accumulator block (lines 223-238) are
also identical to the repo copy.

Confirmation for the bundled copy:

- (a) Success return is literally `@{ ExitCode = 0; Output = '' }` — **confirmed** (line 240).
- (b) Every error path sets `ExitCode = 1` — **confirmed** (lines 227 and 237).

No edit was made to this file.

## [P1-T3] Negative claim — no Codex mirror of the hook

SearchScope: `.codex/hooks/` (relative to `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`)

SearchPatterns: `validate-orchestrator-output.ps1` (glob `.codex/hooks/**/validate-orchestrator-output.ps1`, plus a full directory listing of `.codex/hooks/`)

SearchResult: `none`

The full listing of `.codex/hooks/` contains 25 scripts, none named
`validate-orchestrator-output.ps1`:

```text
authorize-root-epic-invocation.ps1          enforce-epic-worktree-removal-gate.ps1
check-powershell-test-purity.ps1            enforce-evidence-locations.ps1
check-python-test-purity.ps1                enforce-orchestration-preimplementation-gate.ps1
codex-agent-profile-attestation.ps1         enforce-powershell-batch-budget.ps1
codex-authority-store.ps1                   enforce-promotion-mcp-only.ps1
codex-epic-child-launch-attestation.ps1     enforce-python-batch-budget.ps1
enforce-checkpoint-monotonic.ps1            record-subagent-routing-attestation.ps1
enforce-codex-model-routing.ps1             validate-bash.ps1
enforce-completion-consistency.ps1          validate-codex-subagent-routing.ps1
enforce-completion-helpers.ps1              validate-feature-review-coverage.ps1
enforce-epic-child-worktree-binding.ps1
enforce-epic-merge-gate.ps1
enforce-epic-planning-only.ps1
enforce-epic-root-invocation.ps1
enforce-epic-wave-barrier.ps1
```

This re-confirms research Section 4: there is no Codex copy of this hook to update, so the
spec's "no Codex mirror work" non-goal is satisfied by absence, not by omission.

EXIT_CODE: 0
Output Summary: Both copies of `OrchestratorStateCompletion.psm1` confirm the literal
`@{ ExitCode = 0; Output = '' }` success return and `ExitCode = 1` on every error path; no
file was edited. No `validate-orchestrator-output.ps1` exists under `.codex/hooks/`.
