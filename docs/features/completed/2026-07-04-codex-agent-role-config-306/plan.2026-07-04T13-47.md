# codex-agent-role-config (Issue #306 Plan)

- **Issue:** #306
- **Feature Folder:** `docs/features/active/2026-07-04-codex-agent-role-config-306`
- **Plan Path:** `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md`
- **Requirements Sources:** `docs/features/active/2026-07-04-codex-agent-role-config-306/issue.md`, `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md`, `docs/features/active/2026-07-04-codex-agent-role-config-306/research/2026-07-04T13-52-issue-306-codex-agent-role-config-research.md`
- **Evidence Root:** `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/`
- **Last Updated:** 2026-07-04T14-20
- **Status:** Draft

Execution note: this plan reconciles the canonical timestamped plan path. Executors must use `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md` for execution, plan validation, and checklist updates. Do not create `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.md` or any sibling plan file.

Evidence rule: each evidence artifact named below must include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` unless the task states a non-command schema. Coverage-bearing artifacts must include numeric coverage values.

### Phase 0 — Policy And Plan-Path Baseline

- [x] [P0-T1] Read `AGENTS.md`, `.agents/skills/policy-compliance-order/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.agents/skills/typescript/SKILL.md`, `.agents/skills/typescript-suppressions/SKILL.md`, `.agents/skills/python/SKILL.md`, and `.agents/skills/python-suppressions/SKILL.md`, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/phase0-instructions-read.md` with the ordered file list, timestamp, and `EXIT_CODE: 0`.
- [x] [P0-T2] Verify `artifacts/orchestration/orchestrator-state.json` contains `"issue-num": "306"` and `"plan-path": "docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md"`, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/orchestrator-state-plan-path.baseline.md`.
- [x] [P0-T3] Verify `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.md` does not exist and `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md` does exist, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/plan-path-continuity.baseline.md`.
- [x] [P0-T4] Run `codex doctor --json` using the resolved Codex executable for this workstation and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/codex-doctor.baseline.md` with the warning classes reported for `.codex/agents/orchestrator.toml`.

### Phase 1 — TypeScript Baseline QA

- [x] [P1-T1] Run `Push-Location extensions/drm-copilot; npm run format; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/typescript-format.baseline.md`.
- [x] [P1-T2] Run `Push-Location extensions/drm-copilot; npm run lint; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/typescript-lint.baseline.md`.
- [x] [P1-T3] Run `Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/typescript-typecheck.baseline.md`.
- [x] [P1-T4] Run `Push-Location extensions/drm-copilot; npm run test:unit -- --coverage test/extension.test.ts test/codex-worktree-session-command.test.ts; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/typescript-jest-coverage.baseline.md` with numeric overall and `src/command-runtime.ts` line coverage.

### Phase 2 — Python Baseline QA

- [x] [P2-T1] Run `poetry run black --check .` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/python-black.baseline.md`.
- [x] [P2-T2] Run `poetry run ruff check .` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/python-ruff.baseline.md`.
- [x] [P2-T3] Run `poetry run pyright` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/python-pyright.baseline.md`.
- [x] [P2-T4] Run `poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py --cov=scripts/dev_tools --cov-report=term-missing` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/python-contract-coverage.baseline.md` with numeric coverage.

### Phase 3 — Python Role Skills Regression

- [x] [P3-T1] Add Python contract assertions to `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` proving `.codex/agents/orchestrator.toml` has `[skills].config` as a sequence of objects with `name` and `enabled = true`.
- [x] [P3-T2] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py -k role_skills --color=no` before the TOML fix and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/python-role-skills-shape.fail-before.md`.

### Phase 4 — Python Role MCP Regression

- [x] [P4-T1] Add Python contract assertions to `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` proving `.codex/agents/orchestrator.toml` does not contain role-local MCP transport settings.
- [x] [P4-T2] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py -k role_mcp --color=no` before the TOML fix and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/python-role-mcp-location.fail-before.md`.

### Phase 5 — Python Transport Location Regression

- [x] [P5-T1] Add Python contract assertions to `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` proving `.codex/config.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` retain the full `drm-copilot` MCP transport while the role TOML files do not.
- [x] [P5-T2] [expect-fail] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -k transport --color=no` before the TOML fix and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/python-config-transport.fail-before.md`.

### Phase 6 — TypeScript Resolver Regression

- [x] [P6-T1] Add Jest coverage to `extensions/drm-copilot/test/extension.test.ts` proving `resolveCodexExecutable` resolves an installed OpenAI/Codex extension package executable when `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath` is blank and PATH/PATHEXT lacks `codex`.
- [x] [P6-T2] [expect-fail] Run `Push-Location extensions/drm-copilot; npm run test:unit -- test/extension.test.ts -t "installed extension package executable"; Pop-Location` before the resolver fix and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/typescript-resolver-extension-package.fail-before.md`.

### Phase 7 — TypeScript Command Launch Regression

- [x] [P7-T1] Add Jest coverage to `extensions/drm-copilot/test/codex-worktree-session-command.test.ts` proving `drm-copilot: New Codex Worktree Session` launches the installed extension package Codex path through the PowerShell call operator.
- [x] [P7-T2] [expect-fail] Run `Push-Location extensions/drm-copilot; npm run test:unit -- test/codex-worktree-session-command.test.ts -t "installed extension package codex"; Pop-Location` before the command wiring fix and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/typescript-command-launch.fail-before.md`.

### Phase 8 — TypeScript Missing Executable Regression

- [x] [P8-T1] Add Jest coverage to `extensions/drm-copilot/test/codex-worktree-session-command.test.ts` proving terminal creation does not occur when configured, PATH, and installed-extension Codex executable candidates are all absent.
- [x] [P8-T2] [expect-fail] Run `Push-Location extensions/drm-copilot; npm run test:unit -- test/codex-worktree-session-command.test.ts -t "fails before terminal creation"; Pop-Location` before the command wiring fix and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/typescript-command-missing-executable.fail-before.md`.

### Phase 9 — Codex Role And Plan-Path Configuration

- [x] [P9-T1] Update `.codex/agents/orchestrator.toml` so it removes `[mcp_servers.drm-copilot]`, replaces map-style `[skills.config]` with `[skills] config = [{ name = "...", enabled = true }, ...]`, and retains the issue #306 plan-path resolution instruction naming `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md`.
- [x] [P9-T2] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml` to match `.codex/agents/orchestrator.toml` byte-for-byte for the role schema and plan-path resolution instruction.
- [x] [P9-T3] Verify `.codex/config.toml` retains `[mcp_servers.drm-copilot]` with `command = "npx"`, `args = ["-y", "@danmoisan/drm-copilot-mcp"]`, `required = true`, and `validate_orchestration_artifacts` approval settings.
- [x] [P9-T4] Verify `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` retains the same `drm-copilot` MCP transport requirements as `.codex/config.toml`.
- [x] [P9-T5] Write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/other/role-config-location-verification.md` summarizing the role TOML and config TOML checks from `P9-T1` through `P9-T4`.

### Phase 10 — Worktree Session Resolver Implementation

- [x] [P10-T1] Update `extensions/drm-copilot/src/command-runtime.ts` so `resolveCodexExecutable` preserves configured executable and PATH/PATHEXT behavior and then probes bounded installed OpenAI/Codex extension package candidate roots for `bin/windows-x86_64/codex.exe`, `bin/codex`, and platform-appropriate executable extensions.
- [x] [P10-T2] Update `extensions/drm-copilot/src/extension.ts` so `drmCopilotExtension.newCodexWorktreeSession` passes installed OpenAI/Codex extension candidate roots into `resolveCodexExecutable` before terminal creation.
- [x] [P10-T3] Update `extensions/drm-copilot/test/extension-test-harness.ts` and `extensions/drm-copilot/test/runtime-test-helpers.ts` so Jest tests can provide installed extension candidate roots and file-existence responses without touching real VS Code extension folders.
- [x] [P10-T4] Update `extensions/drm-copilot/package.json` so `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath` documentation states the blank-setting resolution order: PATH/PATHEXT first, then installed OpenAI/Codex extension package executable candidates, then explicit failure.

### Phase 11 — Orchestration Plan-Path Guardrail Propagation

- [x] [P11-T1] Update `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, and `.agents/skills/feature-promotion-lifecycle/SKILL.md` so planner delegation enumerates existing `${feature-folder}/plan*.md` files and reuses the first deterministic existing plan path instead of defaulting to `${feature-folder}/plan.md`.
- [x] [P11-T2] Update `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-promotion-lifecycle/SKILL.md` with the same plan-path guardrail text as the root skill files.
- [x] [P11-T3] Verify root and bundled copies of the three plan-path guardrail skill files contain the same issue #306 invariant text, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/other/plan-path-guardrail-parity.md`.

### Phase 12 — Python Contract Pass-After

- [x] [P12-T1] Run `poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py --cov=scripts/dev_tools --cov-report=term-missing` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/python-contracts.pass-after.md` with numeric coverage.
- [x] [P12-T2] Compare `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/python-contract-coverage.baseline.md` against `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/python-contracts.pass-after.md`, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/python-coverage-comparison.md` with baseline coverage, post-change coverage, and changed-contract coverage.

### Phase 13 — TypeScript Resolver Pass-After

- [x] [P13-T1] Run `Push-Location extensions/drm-copilot; npm run test:unit -- --coverage test/extension.test.ts test/codex-worktree-session-command.test.ts; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/typescript-resolver-command.pass-after.md` with numeric overall and `src/command-runtime.ts` line coverage.
- [x] [P13-T2] Compare `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/typescript-jest-coverage.baseline.md` against `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/typescript-resolver-command.pass-after.md`, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/typescript-coverage-comparison.md` with baseline coverage, post-change coverage, and changed-module coverage.

### Phase 14 — Codex Doctor Pass-After

- [x] [P14-T1] Run `codex doctor --json` using the resolved Codex executable for this workstation and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/codex-doctor.pass-after.md` showing no warnings for `invalid transport`, `invalid type: map, expected a sequence`, `expected struct BundledSkillsConfig`, `invalid type: map, expected a boolean`, or `missing field enabled`.

### Phase 15 — TypeScript Final QA

- [x] [P15-T1] Run `Push-Location extensions/drm-copilot; npm run format; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/typescript-format.final.md`.
- [x] [P15-T2] Run `Push-Location extensions/drm-copilot; npm run lint; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/typescript-lint.final.md`.
- [x] [P15-T3] Run `Push-Location extensions/drm-copilot; npm run typecheck; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/typescript-typecheck.final.md`.
- [x] [P15-T4] Run `Push-Location extensions/drm-copilot; npm run test:unit -- --coverage; Pop-Location` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/typescript-jest-coverage.final.md` with numeric coverage.

### Phase 16 — Python Final QA

- [x] [P16-T1] Run `poetry run black --check .` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/python-black.final.md`.
- [x] [P16-T2] Run `poetry run ruff check .` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/python-ruff.final.md`.
- [x] [P16-T3] Run `poetry run pyright` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/python-pyright.final.md`.
- [x] [P16-T4] Run `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/python-pytest-coverage.final.md` with numeric coverage.

### Phase 17 — Completion Gates

- [x] [P17-T1] Verify the TypeScript and Python final QA artifacts in `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/` have no coverage regression from the Phase 0 baseline artifacts, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/final-coverage-comparison.md`.
- [x] [P17-T2] Run `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/evidence-location-validation.final.md`.
- [x] [P17-T3] Run `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: "plan"` and `artifact_path: "docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md"`, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/plan-validation.final.md`.
- [x] [P17-T4] Update acceptance-criteria checkboxes in `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md` and `docs/features/active/2026-07-04-codex-agent-role-config-306/issue.md` only for criteria backed by Phase 12 through Phase 17 evidence, then write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/issue-updates/acceptance-criteria-checkoff.final.md`.
- [x] [P17-T5] Run `git diff --check` from repository root `.` and write `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/git-diff-check.final.md`.
