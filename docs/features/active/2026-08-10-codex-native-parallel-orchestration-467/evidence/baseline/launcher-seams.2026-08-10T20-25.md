# Launcher Seam and Line-Count Baseline

Timestamp: 2026-08-10T22-40

Command: `Get-ChildItem .codex/scripts -File | Where-Object Name -Match 'epic|child|launch|resume|worktree' | Sort-Object FullName | ForEach-Object { '{0}`t{1}' -f $_.FullName,(Get-Content -LiteralPath $_.FullName).Count }; rg -n 'integration|fan-in|CODEX_HOME|launch_spec|sha256|worktree|child_status|origin/main' .codex/scripts tests/scripts/codex-epic`

EXIT_CODE: 1

Output Summary: The line-count portion completed and found seven launcher-related scripts, all below 500 lines. The prescribed search then reported `tests/scripts/codex-epic` missing. A bounded discovery command located the live epic tests under `tests/scripts/codex-hooks`, and the corrected scoped search exited 0. The live files establish a surface-neutral contract/runtime/persistence/resume core with thin epic and parallel adapters; all proposed reusable scripts have a current source basis below 500 lines.

Corrective Command: `rg --files tests | rg '(codex.*epic|epic.*codex|epic.*launcher|launcher.*epic|epic-provenance)'`; then search the returned `tests/scripts/codex-hooks` epic files with the original seam pattern.

Corrective EXIT_CODE: 0

## Existing script line counts

| Script | Lines | Current role |
|---|---:|---|
| `.codex/scripts/epic-child-launch-contract.ps1` | 475 | Pure JSON, hashing, canonical-path, profile, receipt, and epic launch-spec validation |
| `.codex/scripts/epic-child-launch-runtime.ps1` | 445 | Git/trusted-surface checks, profile resolution, isolated `CODEX_HOME`, and runtime configuration |
| `.codex/scripts/epic-child-persistence-runtime.ps1` | 118 | Atomic JSON persistence, semantic wave locking, and external authority validation |
| `.codex/scripts/epic-child-sandbox-preflight.ps1` | 69 | Isolated sandbox process construction and bounded preflight |
| `.codex/scripts/launch-epic-child-wave.ps1` | 471 | Epic adapter plus receipt construction, process launch, bounded supervision, and status persistence |
| `.codex/scripts/resume-epic-child.ps1` | 263 | Sealed receipt/spec/live-state reconciliation and external process resume |
| `.codex/scripts/post-codex-worktree-session.ps1` | 280 | Existing post-worktree session behavior outside the new shared launcher core |

## Live test seams

- `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`: launch-spec, exact model/reasoning/permission/worktree, `codex exec`, and PreToolUse binding contracts.
- `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`: per-worktree profile identity, isolated `CODEX_HOME`, same-repository ancestry, clean worktrees, trusted surfaces, persistence, and failure cleanup.
- `tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1`: sealed launch-attestation identity.
- `tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1`: dependency/wave admission and worktree-removal readiness.
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`: public runtime/configuration and distribution closure.
- `tests/scripts/codex-hooks/epic-provenance.Tests.ps1`: root provenance, model routing, authority isolation, and continuation behavior.
- `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`: preparation, wave, merge, and worktree-removal gates.

## Shared-core ownership

- `codex-child-launch-contract-core.ps1`: surface-neutral JSON parsing, SHA-256, canonical paths, model/profile parsing, immutable identity fields, common launch/receipt structure, and structural validation. Surface-specific base/target fields are supplied by an adapter policy rather than encoded in this core.
- `codex-child-launch-runtime.ps1`: Git wrapper seams, common-directory and ancestry checks, trusted customization fingerprinting, profile resolution, isolated `CODEX_HOME`, permission/project overrides, and external `codex exec` process construction.
- `codex-child-launch-persistence.ps1`: create-new and atomic JSON writes, semantic scheduling locks, receipt/status transitions, and launcher-owned authority-root checks.
- `codex-child-launch-resume.ps1`: sealed launch/receipt/profile/hash reconciliation against live Git, worktree, status, authority, and process truth before a resume start-info object can be created.
- Existing sandbox preflight behavior remains a cohesive reusable module or is consumed by the shared runtime without duplicating its logic.

## Thin-adapter ownership

- `epic-child-launch-contract.ps1`, `launch-epic-child-wave.ps1`, and `resume-epic-child.ps1` retain epic-only integration-branch, fan-in, wave, prompt, and error-prefix behavior while delegating common mechanics.
- Parallel adapters supply `surface=parallel`, `base_branch=main`, `pr_target=main`, no integration/fan-in fields, persisted cohort/batch ordering, and per-item identity while reusing the shared mechanics.
- Surface-neutral modules must not decide epic integration semantics or parallel main-only scheduling policy.

## Epic public parameters to preserve

- `.codex/scripts/launch-epic-child-wave.ps1`: `LaunchSpecPath`, `MaxParallel`, `Supervisor`, `Wait`, and `RepositoryRoot`, including `ValidateRange(1, 8)` and existing defaults.
- `.codex/scripts/resume-epic-child.ps1`: `ReceiptPath`, `Prompt`, and `LastMessagePath`, including `SupportsShouldProcess`, the mandatory receipt path, and existing defaults.
- Existing epic launch-spec fields and prompt contract remain compatible, including `integration_branch`, wave identity, per-child branch/worktree, agent/model/reasoning/permissions, delegation and routing receipts, `CODEX_HOME`, status/receipt paths, and SHA-256 fields.

## Under-500 proof for proposed reusable scripts

Every source unit used for extraction is already below 500 lines. The largest inputs are 475-line contract, 471-line wave launcher, and 445-line runtime. Moving surface-neutral subsets into four cohesive modules removes those lines from the epic adapters; it does not require combining the inputs. The planned allocation keeps contract validation, process/runtime, persistence/status, and resume reconciliation in separate files, each bounded by its corresponding existing input of 475, 445, 118, and 263 lines respectively. Thin epic and parallel adapters contain only surface policy and invocation wiring and therefore remain smaller than the current 471-line launcher. The existing 69-line sandbox module also remains below the limit.
