# Remediation Inputs — Codex PreToolUse Hook Transport Repair (#415)

- Timestamp: 2026-07-25T21-03
- Cycle: 1 (initial audit)
- Branch: `bug/codex-pretooluse-hook-transport-415` @ `ee98ca7fb69901f541ae10cf8f63f46262f3e6d5`
- Base: `main`, merge-base `009808510363081d0db7684f7b555f2ded4b0b7c`
- Produced by: feature-review agent

## Source Audit Artifacts

- `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/policy-audit.2026-07-25T21-03.md` (findings B1, B2 — Sections 1.2, 1.2.1, 8, 10)
- `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/code-review.2026-07-25T21-03.md` (Findings Table: 2 Blockers, 1 Minor, 4 Info)
- `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/feature-audit.2026-07-25T21-03.md` (all 12 ACs PASS; PR flow gated by B1/B2)

## Blocking Findings Requiring Remediation

**Blocking count: 2.**

### R1 — Add the changed PowerShell production surface to coverage measurement (policy-audit B1)

- **File:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`CodeCoverage.Path`)
- **Problem:** The new production module `.codex/hooks/codex-pretooluse-file-mapping.ps1` (474 lines) and 7 of the 8 rewired hooks (`check-python-test-purity.ps1`, `check-powershell-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, `enforce-evidence-locations.ps1`, `enforce-checkpoint-monotonic.ps1`, `enforce-orchestration-preimplementation-gate.ps1`) are outside `CodeCoverage.Path`, so per-file line coverage for the changed production surface is unmeasured. This violates the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` (every production file in the denominator) and leaves the new-file (>= 85% line) and modified-file (>= 85% line, no changed-line regression) thresholds unverifiable. Repository precedent in the same settings file (issues #275, #301, #305, #312, #334, #344, #357, #366, #392) adds new/changed production files to the measured set; several of those entries were themselves remediation-cycle fixes for this exact gap.
- **Expected behavior after fix:**
  1. `CodeCoverage.Path` lists the 8 root `.codex/hooks` files above (the 9th changed hook, `enforce-completion-consistency.ps1`, is already listed).
  2. `mcp__drm-copilot__run_poshqc_test` produces per-file line coverage for each newly listed file in `artifacts/pester/powershell-coverage.xml`.
  3. The shared module reports >= 85% line coverage. Note for the planner: the module is entrypoint-free and already dot-sourced in-process by `legacy-codex-hook-contracts.Tests.ps1` and `codex-pretooluse-transport.Tests.ps1`, so line attribution should bind; if in-process exercise of specific functions is insufficient, add dot-sourced unit cases (no temp files, `ProcessStartInfo` for any process-level needs) rather than weakening thresholds.
  4. For the 7 rewired hook entrypoints: lines behind the `if ($MyInvocation.InvocationName -eq '.') { return }` guard are unreachable in-process (documented instrument behavior, see `evidence/qa-gates/coverage-comparison.2026-07-25T21-06.md`). The policy functions and any dot-source-reachable lines must be measured; record the resulting per-file numbers and the entrypoint-guard residual explicitly in the coverage evidence. If a per-file number lands below threshold solely due to guarded entrypoint lines, document that computation transparently in the evidence artifact for the re-audit to adjudicate — do not remove the files from measurement again.
  5. Repo-wide line coverage stays >= 85% and the movement is explained numerically (baseline vs post-change) in a refreshed coverage-comparison artifact under `evidence/qa-gates/`.
- **Verification commands:**
  - `mcp__drm-copilot__run_poshqc_test` (full workspace) → exit 0
  - Parse `artifacts/pester/powershell-coverage.xml` per-file LINE counters for the 8 added paths
  - Record `Timestamp:` / `Command:` / `EXIT_CODE:` evidence under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/qa-gates/`

### R2 — Capture Python per-language coverage evidence (policy-audit B2)

- **File:** none (evidence gap); artifact target `artifacts/python/lcov.info` and an evidence record under `evidence/qa-gates/`
- **Problem:** The branch changes one Python file (`tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`) but no Python coverage artifact exists; plan `[P0-T6]` scoped out the full `--cov` run. Coverage verification is mandatory for every language with changed files; the absence fails closed.
- **Expected behavior after fix:**
  1. One full `poetry run pytest --cov --cov-branch --cov-report=term-missing` run (or the repo-standard lcov-producing equivalent) executes green.
  2. Repo-wide Python line coverage >= 85% and branch coverage >= 75% are recorded numerically, with the artifact path, under `evidence/qa-gates/`.
  3. Since no production Python changed on this branch, no per-file movement is expected; the evidence should state this comparison explicitly.
- **Verification commands:**
  - `poetry run pytest --cov --cov-branch --cov-report=term-missing` → exit 0, coverage summary captured
  - Evidence record with `Timestamp:` / `Command:` / `EXIT_CODE:` / `Output Summary:` under `evidence/qa-gates/`

## Non-Blocking Items (fix only if trivially adjacent; otherwise record as follow-ups)

- **Minor:** shared parser no longer asserts `hook_event_name == 'PreToolUse'` (code-review Findings Table). Optional hardening; do not change deny/allow policy semantics.
- **Info:** `.codex/state/` is not gitignored; a `.gitignore` entry would make the no-committed-session-state invariant structural.

## Do-Not-Do List

- Do not modify any file under `.claude/` or any bundled `.claude` copy (spec Hard Constraint 1).
- Do not touch `.codex/config.toml` registrations, matchers, or the handler set (Hard Constraint 2).
- Do not change any handler's allow/deny policy functions (Hard Constraint 3); R1 is a measurement-configuration change plus, at most, additive tests.
- Do not break root/bundle byte-identity; any hook file change must mirror into the bundle in the same batch (Hard Constraint 4).
- Do not create temporary files in tests; process stdin via `ProcessStartInfo` + `RedirectStandardInput` (Hard Constraint 5).
- Do not exceed 500 lines in any production or test file, measured as `(Get-Content -LiteralPath $path).Count` (Hard Constraint 6).
- Do not remove production files from `CodeCoverage.Path`, lower any coverage threshold, weaken assertions, or add analyzer suppressions.
- Do not write evidence anywhere except `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/<kind>/`.
- Do not uncheck or edit the spec acceptance-criteria text; all 12 are verified and checked off.

## Handoff

Per `remediation-handoff-atomic-planner`, the remediation plan must be authored by `atomic-planner` (plan shape per `atomic-plan-contract`), preflighted by `atomic-executor`, executed task-by-task, and re-audited by `feature-review`. This reviewer session has no delegation capability; the orchestrator owns the handoff. The exit gate for cycle 1 is: both R1 and R2 evidenced, PoshQC loop green, and a re-audit with `blocking_count == 0`.
