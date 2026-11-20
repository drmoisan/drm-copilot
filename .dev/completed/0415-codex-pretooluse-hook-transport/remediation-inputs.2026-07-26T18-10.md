# Remediation Inputs — CI Failure, Codex PreToolUse Hook Transport Repair (#415)

- Timestamp: 2026-07-26T18-10
- Cycle: 2 (S9 CI-failure handling)
- Branch: `bug/codex-pretooluse-hook-transport-415` @ `06473a63bc7a0ee72cd3cdb47c8b4dc6ee5c7d8a`
- Base: `main`, merge-base `fb483b8468204e4385b5583c3b3ec4c0a987eede`
- PR: https://github.com/drmoisan/drm-copilot/pull/427
- Produced by: orchestrator (S9 CI green gate)

## Source

CI run https://github.com/drmoisan/drm-copilot/actions/runs/30213678367 against PR head `06473a63`.

Required-check results: **10 of 11 pass, 1 fails.**

| Bucket | State | Check |
|---|---|---|
| fail | FAILURE | `poshqc / PowerShell QC` |
| pass | SUCCESS | `build-check / Build Package` |
| pass | SUCCESS | `docs-validation / Documentation Validation` |
| pass | SUCCESS | `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` |
| pass | SUCCESS | `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` |
| pass | SUCCESS | `quality-checks7 / Code Quality & Tests (3.10)` |
| pass | SUCCESS | `quality-checks7 / Code Quality & Tests (3.11)` |
| pass | SUCCESS | `quality-checks7 / Code Quality & Tests (3.12)` |
| pass | SUCCESS | `quality-checks7 / Code Quality & Tests (3.13)` |
| pass | SUCCESS | `security-scan / Security Scanning` |
| pass | SUCCESS | `shell-coverage / Shell Coverage (Bats + kcov)` |

Failing job: `poshqc / PowerShell QC`
Job URL: https://github.com/drmoisan/drm-copilot/actions/runs/30213678367/job/89824044113

## Blocking Findings Requiring Remediation

**Blocking count: 1.**

### C1 — `enforce-epic-child-worktree-binding.ps1` exits 2 on a detached HEAD (Severity: Blocking)

**Failing check:** `poshqc / PowerShell QC`
**Failing job:** https://github.com/drmoisan/drm-copilot/actions/runs/30213678367/job/89824044113

Verbatim failure from `gh run view 30213678367 --log-failed`:

```
[-] Every registered Codex PreToolUse handler accepts every tool name its matcher admits.
    allows every registered handler for every tool name its own matcher admits 26.29s
Expected $null or empty, because every registered handler must allow a benign admitted payload,
but got 'enforce-epic-child-worktree-binding.ps1 x Bash: exit=2 stdout=[]
         stderr=[You cannot call a method on a null-valued expression.]'

Tests Passed: 1658, Failed: 1, Skipped: 9, Inconclusive: 0, NotRun: 0
##[error]Process completed with exit code 1.
```

This failure was surfaced by the config-driven integration test added in the delivered cycle (`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`), which derives its matrix live from `.codex/config.toml`. The test is behaving correctly; it caught a real defect that the local environment masked.

**Root cause — reproduced deterministically, not inferred.**

The handler is registered under the `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` matcher and was classified during initial diagnosis as not implicated, because it exits 0 for every admitted tool name in a normal branch checkout. It fails only when `HEAD` is detached.

GitHub Actions checks out a PR merge ref (`refs/pull/427/merge`), which is a detached HEAD. Reproduction in a local detached worktree at the same commit:

```
$ git worktree add --detach <path> 06473a63
$ git -C <path> branch --show-current      # exits 0, prints nothing
$ printf '{"session_id":"probe","hook_event_name":"PreToolUse","tool_name":"Bash",
           "tool_input":{"command":"git status"},"cwd":"<path>"}' \
  | pwsh -NoProfile -File <path>/.codex/hooks/enforce-epic-child-worktree-binding.ps1
EXIT=2
stdout=[]
stderr=[You cannot call a method on a null-valued expression.]
```

The defect is at `.codex/hooks/enforce-epic-child-worktree-binding.ps1:311-316`:

```powershell
$liveBranch = [string](Invoke-CodexChildGuardGit -GitArgs @('-C', $repositoryRoot, 'branch', '--show-current'))
if ($LASTEXITCODE -ne 0) {
    $liveBranch = ''
}
$decision = Invoke-CodexEpicChildGuardDecision -PayloadRaw $payloadRaw -ReceiptRaw $receiptRaw `
    -Attestation $attestation -HookRepositoryRoot $repositoryRoot -LiveBranch $liveBranch.Trim() `
    -ActualSpecSha256 $actualSpecSha256 -ActualProfileSha256 $actualProfileSha256
```

On a detached HEAD, `git branch --show-current` **succeeds** (exit 0) and emits **no output**. `Invoke-CodexChildGuardGit` therefore returns an empty pipeline, and `[string](<empty pipeline>)` evaluates to `$null` — not to `''`. Because `$LASTEXITCODE` is 0, the existing guard does not fire, so `$liveBranch` stays `$null` and `$liveBranch.Trim()` throws.

Confirmed directly:

```
branch cmd -> NULL (no output) LASTEXITCODE=0
liveBranch null? True   Trim -> THREW: You cannot call a method on a null-valued expression.
```

The guard is keyed on the wrong condition: it defends against git *failing*, but the null arises when git *succeeds with empty output*.

**Expected behavior after fix:**

1. `enforce-epic-child-worktree-binding.ps1` exits 0 with empty stdout and empty stderr for a benign admitted payload when `HEAD` is detached, matching its behavior on a normal branch checkout.
2. The handler's existing allow/deny policy is unchanged. An empty live branch must be treated exactly as the pre-existing `$LASTEXITCODE -ne 0` path already treats it — as an empty string — not as a new deny.
3. The root file and its bundled mirror at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-child-worktree-binding.ps1` stay byte-identical.
4. Regression coverage exists for the detached-HEAD case so this cannot silently return. The existing `ProcessStartInfo` + `RedirectStandardInput` and in-process `[System.Console]::SetIn` patterns both apply; no temporary files.

**Adjacent occurrence to assess (do not assume it is identical):**

`.codex/hooks/enforce-epic-planning-only.ps1:273` uses the same git call:

```powershell
$currentBranch = [string](& git -C $repositoryRoot branch --show-current 2>$null)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($currentBranch)) {
    throw 'EPIC_PLANNING_ONLY_BLOCKED: current branch could not be resolved before push.'
}
```

This site *does* test `IsNullOrWhiteSpace`, so it will not throw a null-reference error — but on a detached HEAD it takes the `throw` path, which the entrypoint converts to **exit 2**. That branch is reached only when `tool_name` is `Bash` and the command matches `^\s*git\s+push\b`, so the benign `git status` probe did not trigger it and CI did not catch it. Determine whether a `git push` under a detached HEAD should be a transport error (exit 2), a policy deny (exit 0 + deny envelope), or an allow, and make the behavior deliberate and covered. Do not change the intended policy; make the transport correct.

Sweep `.codex/hooks/**` for any other `[string](<git invocation>)` followed by a method call, and for any other guard keyed on `$LASTEXITCODE` alone where empty successful output is possible.

**Verification commands:**

- Reproduce before the fix and confirm after: create a detached worktree (`git worktree add --detach <path> <sha>`), pipe a benign `PreToolUse` `Bash` payload into the handler, assert exit 0 with empty stdout and empty stderr.
- `mcp__drm-copilot__run_poshqc_test` (full workspace) → exit 0, and `Invoke-PoshQCTest -Root <repo>` for the CI-path coverage measurement.
- Record `Timestamp:` / `Command:` / `EXIT_CODE:` / `Output Summary:` evidence under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/regression-testing/` and `evidence/qa-gates/`.

## Do-Not-Do List

- Do not modify any file under `.claude/` or any bundled `.claude` copy.
- Do not weaken, skip, or narrow the config-driven integration test that caught this. It is correct.
- Do not touch `.codex/config.toml` registrations, matchers, or the handler set.
- Do not change any handler's allow/deny policy semantics; this is a transport and null-handling fix.
- Do not break root/bundle byte-identity; mirror any hook change in the same batch.
- Do not create temporary files in tests.
- Do not exceed 500 lines in any production or test file.
- Do not remove files from `CodeCoverage.Path`, lower a threshold, shrink a denominator, weaken an assertion, or add an analyzer suppression.
- Do not write evidence outside `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/<kind>/`.
- Do not uncheck or edit the spec acceptance-criteria text.

## Handoff

Per `remediation-handoff-atomic-planner`, the remediation plan is authored by `atomic-planner`, preflighted by `atomic-executor`, executed task-by-task, and re-audited by `feature-review`. This is remediation pass 2 of a cap of 3. The exit gate is: C1 resolved with regression coverage, PoshQC loop green, a re-audit with `blocking_count == 0`, and a green `poshqc / PowerShell QC` check against the new PR head SHA.
