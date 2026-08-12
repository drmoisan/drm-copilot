# 2026-08-10-codex-native-parallel-orchestration - Plan

- **Issue:** #467
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-10T20-25
- **Status:** Ready for Preflight
- **Version:** 0.1
- **Work Mode:** full-feature
- **Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
- **Plan of Record:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/plan.2026-08-10T20-25.md`
- **Evidence Timestamp:** `2026-08-10T20-25`
- **Authorized Translation:** `translate-claude-to-codex mode=apply`
- **Release Ledger:** `16 PRESERVED / 2 DEGRADED with tested mechanical compensating controls / 0 LOST`

## Required References

- Requirements: [`issue.md`](issue.md), [`spec.md`](spec.md), and [`user-story.md`](user-story.md)
- Feature research: [`artifacts/research/2026-08-10T20-10-codex-native-parallel-orchestration-research.md`](../../../../artifacts/research/2026-08-10T20-10-codex-native-parallel-orchestration-research.md)
- Corrected Codex research basis: [`docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`](../../../research/20260616-codex-native-ecosystem.2026-06-16T13-32.md)
- Repository policies: [`AGENTS.md`](../../../../AGENTS.md), [`.agents/skills/general-code-change/SKILL.md`](../../../../.agents/skills/general-code-change/SKILL.md), and [`.agents/skills/general-unit-test/SKILL.md`](../../../../.agents/skills/general-unit-test/SKILL.md)
- Language policies: [`.agents/skills/python/SKILL.md`](../../../../.agents/skills/python/SKILL.md), [`.agents/skills/python-suppressions/SKILL.md`](../../../../.agents/skills/python-suppressions/SKILL.md), [`.agents/skills/typescript/SKILL.md`](../../../../.agents/skills/typescript/SKILL.md), [`.agents/skills/typescript-suppressions/SKILL.md`](../../../../.agents/skills/typescript-suppressions/SKILL.md), [`.agents/skills/powershell/SKILL.md`](../../../../.agents/skills/powershell/SKILL.md), and [`.agents/skills/ci-workflows/SKILL.md`](../../../../.agents/skills/ci-workflows/SKILL.md)
- Planning and evidence contracts: [`.agents/skills/atomic-plan-contract/SKILL.md`](../../../../.agents/skills/atomic-plan-contract/SKILL.md), [`.agents/skills/policy-compliance-order/SKILL.md`](../../../../.agents/skills/policy-compliance-order/SKILL.md), and [`.agents/skills/evidence-and-timestamp-conventions/SKILL.md`](../../../../.agents/skills/evidence-and-timestamp-conventions/SKILL.md)
- Authorized translation workflow: [`.agents/skills/translate-claude-to-codex/SKILL.md`](../../../../.agents/skills/translate-claude-to-codex/SKILL.md)

**All work must comply with these policies; do not duplicate their content here.**

## Execution Invariants

- Execute every task non-interactively and fail closed when its acceptance criterion is not met; no task may be completed as `SKIPPED` unless its text contains an explicit automated skip branch.
- Write evidence only below `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/<kind>/`; every command receipt must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- Record this required override exactly in translation evidence: `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...`.
- Preserve `.claude/` byte-for-byte. Reuse the issue-462 portable assets from their canonical locations; do not copy, regenerate, or edit `.claude/` files.
- Close TypeScript/MCP mutation and semantic-drift parity before enabling runtime completion work. Any missing ledger row, untested DEGRADED control, or LOST gate blocks delivery.
- Keep every production, test, and reusable script file below 500 lines; introduce no dependency or suppression without separate authorization.
- For each applicable language, run formatting, linting, type checking where applicable, and coverage-enabled tests in that order; restart at formatting whenever a step fails or changes files.
- The configured `drm-copilot` process remains pinned to published npm package `@danmoisan/drm-copilot-mcp@1.0.23`; no package version change, npm publish, MCP configuration mutation, invented reload, or claimed in-session restart is authorized. Because this session exposes no MCP reload/restart operation, the fresh local stdio process in `P6-T37` is the authoritative plan-authorized actual MCP public-boundary gate for this strict-validation step; the configured failure remains stale-runtime evidence, and direct TypeScript/service-function invocation is never a substitute.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance, Scoped Seam Verification, and Baselines

- [x] [P0-T1] Record the mandatory policy read in repository precedence order before any implementation edit.
  - Files/seams: `AGENTS.md`; `.agents/skills/general-code-change/SKILL.md`; `.agents/skills/general-unit-test/SKILL.md`; `.agents/skills/python/SKILL.md`; `.agents/skills/python-suppressions/SKILL.md`; `.agents/skills/typescript/SKILL.md`; `.agents/skills/typescript-suppressions/SKILL.md`; `.agents/skills/powershell/SKILL.md`; `.agents/skills/ci-workflows/SKILL.md`; `.agents/skills/translate-claude-to-codex/SKILL.md`; `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
  - Command: `Get-Content -Raw AGENTS.md,.agents/skills/general-code-change/SKILL.md,.agents/skills/general-unit-test/SKILL.md,.agents/skills/python/SKILL.md,.agents/skills/python-suppressions/SKILL.md,.agents/skills/typescript/SKILL.md,.agents/skills/typescript-suppressions/SKILL.md,.agents/skills/powershell/SKILL.md,.agents/skills/ci-workflows/SKILL.md,.agents/skills/translate-claude-to-codex/SKILL.md,.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/phase0-instructions-read.2026-08-10T20-25.md`.
  - Acceptance: the receipt contains `Timestamp:`, `Policy Order:`, and the complete ordered file list above, and predates every implementation diff.

- [x] [P0-T2] Resolve the exact native Codex hook registration and registered-process test seams without consulting Claude registration syntax.
  - Depends on: `P0-T1`.
  - Files/seams: `.codex/config.toml`; `.codex/hooks/`; `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`; existing completion-hook process tests.
  - Command: `rg -n 'PreToolUse|SubagentStop|PermissionRequest|matcher|permissionDecision|CLAUDE_TOOL_INPUT|CLAUDE_SESSION_ID' .codex/config.toml .codex/hooks tests/scripts/codex-hooks`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/codex-hook-seams.2026-08-10T20-25.md`.
  - Acceptance: the receipt identifies every reusable registration/process-test seam, the exact native matcher/command form, and the allow/deny/malformed stream and exit contract; unresolved syntax blocks Phase 1.

- [x] [P0-T3] Resolve surface-neutral launcher boundaries from the current epic launcher and record all reusable-script line counts before selecting implementation files.
  - Depends on: `P0-T1`.
  - Files/seams: `.codex/scripts/*epic*child*.ps1`; `.codex/scripts/*launch*.ps1`; `.codex/scripts/*resume*.ps1`; `tests/scripts/codex-epic/`; bundle mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/`.
  - Command: `Get-ChildItem .codex/scripts -File | Where-Object Name -Match 'epic|child|launch|resume|worktree' | Sort-Object FullName | ForEach-Object { '{0}`t{1}' -f $_.FullName,(Get-Content -LiteralPath $_.FullName).Count }; rg -n 'integration|fan-in|CODEX_HOME|launch_spec|sha256|worktree|child_status|origin/main' .codex/scripts tests/scripts/codex-epic`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/launcher-seams.2026-08-10T20-25.md`.
  - Acceptance: the receipt fixes shared-core versus thin-adapter ownership, identifies epic public parameters to preserve, and proves each proposed reusable script can remain below 500 lines.

- [x] [P0-T4] Resolve the additive Codex receipt-schema placement and existing Python/TypeScript validation entry points.
  - Depends on: `P0-T1`.
  - Files/seams: `scripts/dev_tools/*parallel*.py`; `scripts/dev_tools/*codex*.py`; `extensions/drm-copilot/src/mcp/`; `extensions/drm-copilot/src/lib/`; existing parallel planner/orchestrator fixtures.
  - Command: `rg -n 'schema_version|runtime|surface|mutation|drift|cohort|launch|model.routing|topology|worktree|completion' scripts/dev_tools extensions/drm-copilot/src tests extensions/drm-copilot/test`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/receipt-and-validator-seams.2026-08-10T20-25.md`.
  - Acceptance: the receipt selects either guarded additive shared fields or a referenced Codex launch record by compatibility evidence, names exact Python and TypeScript owners, and confirms delivered Claude fixtures remain valid.

- [x] [P0-T5] Resolve publisher, pack, root/bundle, portable-asset, and CI discovery seams before any manifest or workflow edit.
  - Depends on: `P0-T1`.
  - Files/seams: `scripts/dev_tools/push_down_codex_and_agents_customizations.py`; `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`; `extensions/drm-copilot/resources/`; pack manifests including `core.json`; `.github/workflows/`; publisher/parity/pack/destination tests.
  - Command: `rg -n 'codex-and-agents-customizations|blast-radius|compute-cohorts|parallel-manifest|core.json|pack|collision|destination|route|recursive|Pester|Bats' scripts extensions tests .github/workflows config`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/publisher-pack-ci-seams.2026-08-10T20-25.md`.
  - Acceptance: the receipt records complete pack closures or justified exclusions, additive route-merge ownership, fixed issue-462 selections, current recursive test discovery, and permits workflow edits only for a demonstrated discovery gap.

- [x] [P0-T6] Verify the corrected translation research basis, reject the obsolete basis, and bind apply evidence to the canonical feature tree.
  - Depends on: `P0-T1`.
  - Files/seams: `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`; absent `artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md`; feature `evidence/other/`.
  - Command: `if (-not (Test-Path -LiteralPath 'docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md')) { throw 'Corrected Codex research basis is missing' }; if (Test-Path -LiteralPath 'artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md') { throw 'Obsolete Codex research basis must not be authoritative' }`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/translation-authority.2026-08-10T20-25.md`.
  - Acceptance: the receipt records `mode=apply`, classifies feature/evidence/other outputs, names `translation-plan.2026-08-10T20-25.md`, `translation-diff.2026-08-10T20-25.md`, and `translation-snapshots/`, and contains exactly `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...`.

- [x] [P0-T7] Capture the pre-change Git state and a sorted SHA-256 manifest of every `.claude/` source file.
  - Depends on: `P0-T1`.
  - Files/seams: repository index/worktree; `.claude/**`.
  - Command: `git status --short; git rev-parse HEAD; Get-ChildItem -LiteralPath .claude -Recurse -File | Sort-Object FullName | ForEach-Object { '{0}  {1}' -f (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash,$_.FullName.Substring((Get-Location).Path.Length + 1).Replace('\\','/') }`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/git-and-claude-sha256.2026-08-10T20-25.md`.
  - Acceptance: the receipt contains the baseline HEAD, pre-existing worktree changes, and one stable relative-path hash row for every `.claude/` file; later phases use this manifest as the byte-invariance authority.

- [x] [P0-T8] Capture the TypeScript formatting baseline.
  - Depends on: `P0-T1`.
  - Command: `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/typescript-format.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the exact command, exit code, and changed-file count; any formatter mutation is preserved as baseline-owned work and causes the baseline loop to restart at `P0-T8`.

- [x] [P0-T9] Capture the TypeScript lint baseline.
  - Depends on: `P0-T8` passing without file changes.
  - Command: `npm --prefix extensions/drm-copilot run lint`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/typescript-lint.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the exact command, exit code, warning count, and error count without suppressing pre-existing findings.

- [x] [P0-T10] Capture the TypeScript type-check baseline.
  - Depends on: `P0-T9`.
  - Command: `npm --prefix extensions/drm-copilot run typecheck`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/typescript-typecheck.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the exact command, exit code, and diagnostic count.

- [x] [P0-T11] Capture the coverage-enabled TypeScript unit/integration baseline.
  - Depends on: `P0-T10`.
  - Command: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageDirectory=../../docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/typescript-coverage.2026-08-10T20-25`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/typescript-coverage.2026-08-10T20-25.md`.
  - Acceptance: the receipt records numeric line and branch coverage plus suite/test counts; unavailable numeric coverage is `BLOCKED`, not `PASS`.

- [x] [P0-T12] Capture the Python formatting baseline.
  - Depends on: `P0-T1`.
  - Command: `poetry run black --check .`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/python-format.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the exact command, exit code, and reformattable-file count.

- [x] [P0-T13] Capture the Python lint baseline.
  - Depends on: `P0-T12`.
  - Command: `poetry run ruff check .`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/python-lint.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the exact command, exit code, and finding count without adding suppressions.

- [x] [P0-T14] Capture the Python type-check baseline.
  - Depends on: `P0-T13`.
  - Command: `poetry run pyright`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/python-typecheck.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the exact command, exit code, error count, and warning count.

- [x] [P0-T15] Capture the coverage-enabled Python baseline with branch measurement.
  - Depends on: `P0-T14`.
  - Command: `poetry run pytest -o addopts='' --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/python-coverage.2026-08-10T20-25.json`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/python-coverage.2026-08-10T20-25.md` and the adjacent JSON report.
  - Acceptance: the receipt records numeric line and branch coverage plus passed/failed/skipped counts; unavailable numeric coverage is `BLOCKED`, not `PASS`.

- [x] [P0-T16] Capture the PowerShell formatting baseline through the repository PoshQC formatter.
  - Depends on: `P0-T1`.
  - Command: invoke `mcp__drm-copilot__run_poshqc_format` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` and record its complete result.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/powershell-format.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the MCP invocation, exit code, and changed-file count; any mutation restarts the PowerShell baseline loop at `P0-T16`.

- [x] [P0-T17] Capture the PowerShell analyzer baseline through the repository PoshQC settings.
  - Depends on: `P0-T16` passing without file changes.
  - Command: invoke `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` and record its complete result.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/powershell-analyze.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the MCP invocation, exit code, error count, and warning count.

- [x] [P0-T18] Capture the coverage-enabled Pester baseline through the repository PoshQC test runner.
  - Depends on: `P0-T17`.
  - Command: invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"`; the repository-configured Pester settings provide coverage.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/powershell-pester-coverage.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the MCP invocation, exit code, passed/failed/skipped counts, and numeric line coverage; unavailable coverage is `BLOCKED`, not `PASS`.

- [x] [P0-T19] Capture the portable Bash static-analysis baseline without changing canonical `.claude/` assets.
  - Depends on: `P0-T7`.
  - Command: `bash scripts/bash/shell-qc.sh check`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/bash-shellcheck.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the exact command, exit code, checked-file count, warning count, and error count while `git diff -- .claude` remains empty.

- [x] [P0-T20] Capture the published portable-runtime Bats baseline and its numeric coverage headline.
  - Depends on: `P0-T19`.
  - Command: `bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/bash-kcov.2026-08-10T20-25' bash scripts/bash/shell-qc.sh test --coverage"`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/bash-bats-coverage.2026-08-10T20-25.md`.
  - Acceptance: the receipt records the exact command, exit code, assertion counts, and numeric Bash line coverage from the repository coverage harness; missing `bats` or `kcov` is a blocking failure, not a passing skip.

- [x] [P0-T21] Consolidate baseline coverage and regression constraints without changing the individual command receipts.
  - Depends on: `P0-T11`, `P0-T15`, `P0-T18`, `P0-T20`.
  - Files/seams: the four baseline coverage receipts and generated machine-readable reports.
  - Command: run the repository coverage aggregation/changed-line validator identified by `P0-T5` against the baseline reports.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/coverage-summary.2026-08-10T20-25.md`.
  - Acceptance: the summary records numeric repository line and branch coverage, per-language baselines, and the changed/new-code comparison basis; missing values block Phase 1.

### Phase 1 — Close TypeScript/MCP Mutation and Semantic-Drift Parity

- [x] [P1-T1] Add shared mutation-decision fixtures that encode complete records, sequence gaps and duplicates, open/closed modes, pinned in-flight items, merged removal, and exact detach/abandon confirmation.
  - Depends on: all Phase 0 tasks.
  - Files/seams: create `tests/fixtures/parallel-orchestration/mutation-parity.json`; update Python fixture loader tests under `tests/scripts/dev_tools/`; create `extensions/drm-copilot/test/lib/validate/parallel-mutation-parity.test.ts`.
  - Acceptance: every fixture has one expected accept/reject result and stable reason code, Python accepts the fixture set, and the TypeScript test names each currently divergent case.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/typescript-mutation-fail-before.2026-08-10T20-25.md`.

- [x] [P1-T2] Run the TypeScript mutation parity tests before implementation and retain the expected failure.
  - Depends on: `P1-T1`.
  - Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-mutation-parity.test.ts`.
  - Acceptance: `[expect-fail]` the receipt records a non-zero exit caused only by missing TypeScript mutation invariants; an unexpected pass or unrelated failure blocks implementation.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/typescript-mutation-fail-before.2026-08-10T20-25.md`.

- [x] [P1-T3] Implement complete TypeScript mutation-record validation equivalent to the shared Python mutation authority.
  - Depends on: `P1-T2`.
  - Files/seams: create `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-mutations.ts`; update `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`, `parallel-state-records.ts`, and `parallel-state-structures.ts` only at their mutation composition seams.
  - Acceptance: the new validator rejects missing fields, non-contiguous or duplicate sequence numbers, invalid add/remove/close ordering, merged removal, unconfirmed in-flight detach/abandon, unpinned in-flight recomputation, premature close, and invalid terminal open-mode state with the fixture reason codes.

- [x] [P1-T4] Add shared semantic-drift fixtures for quiescence, observed-versus-declared files, later-started conflict halt, unstarted recoloring, deterministic requeue, and persisted resolution.
  - Depends on: `P1-T3`.
  - Files/seams: create `tests/fixtures/parallel-orchestration/drift-parity.json`; update Python drift fixture tests under `tests/scripts/dev_tools/`; create `extensions/drm-copilot/test/lib/validate/parallel-drift-parity.test.ts`.
  - Acceptance: every fixture has an expected normalized event, affected-item ordering, recomputed cohort/batch assignment, admission decision, completion decision, and stable reason code; Python remains authoritative for the expected output.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/typescript-drift-fail-before.2026-08-10T20-25.md`.

- [x] [P1-T5] Run the TypeScript semantic-drift parity tests before implementation and retain the expected failure.
  - Depends on: `P1-T4`.
  - Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-drift-parity.test.ts`.
  - Acceptance: `[expect-fail]` the receipt records a non-zero exit caused only by absent TypeScript semantic-drift enforcement; an unexpected pass or unrelated failure blocks implementation.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/typescript-drift-fail-before.2026-08-10T20-25.md`.

- [x] [P1-T6] Implement TypeScript semantic-drift validation equivalent to `scripts/dev_tools/parallel_drift_detection.py`.
  - Depends on: `P1-T5`.
  - Files/seams: create `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-drift.ts`; update `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` only at its drift composition seam.
  - Acceptance: unresolved drift blocks admission and completion; resolution requires a persisted event, scheduler quiescence, deterministic unstarted-graph recomputation, later-started-conflict halt, ordered requeue, and matching resolution generation.

- [x] [P1-T7] Wire mutation and drift validation through the MCP orchestration-artifact path without adding a second semantic implementation.
  - Depends on: `P1-T3`, `P1-T6`.
  - Files/seams: `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`; `parallel-orchestrator-state-core.ts`; `validate-orchestration-service-call.ts`; `build-validate-orchestration-service-call-input.ts`; existing MCP tool definition, input, dispatch, and integration-test files that expose `parallel-orchestrator-state`.
  - Acceptance: the public MCP validator returns the same ordered mutation/drift findings as direct TypeScript validation, rejects false-accept fixtures, and preserves every existing artifact-type contract.

- [x] [P1-T8] Prove Python and TypeScript/MCP mutation and drift decisions are byte-stable over the shared fixture corpus.
  - Depends on: `P1-T7`.
  - Command: `poetry run pytest -q tests/scripts/dev_tools -k 'parallel and (mutation or drift)'`; `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-mutation-parity.test.ts test/lib/validate/parallel-drift-parity.test.ts`.
  - Acceptance: both commands exit 0, normalized decision JSON and reason-code order are identical for every fixture, and no unresolved mutation or drift state can pass MCP completion validation.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/python-typescript-mutation-drift-parity.2026-08-10T20-25.md`.

### Phase 2 — Add Forced Parallel Roots, Personas, Routing, and Standalone Checkpoints

- [x] [P2-T1] Add failing provenance and routing contract tests for the six root entry skills and the two forced parallel personas.
  - Depends on: `P1-T8`.
  - Files/seams: create `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1`; extend Python topology/model-routing tests under `tests/scripts/dev_tools/`; extend `extensions/drm-copilot/test/lib/validate/codex-topology-resolver.test.ts` and existing Codex model-routing validator tests.
  - Acceptance: tests require `parallel-plan` to select only `parallel-planner`, require `parallel-run` and `parallel-orchestrate` to select only `parallel-orchestrator`, forbid ordinary/epic roots, and reject absent, mismatched, downgraded, or fallback topology/model receipts.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/parallel-routing-fail-before.2026-08-10T20-25.md`.

- [x] [P2-T2] Run the forced-routing contract before implementation and retain the expected failure.
  - Depends on: `P2-T1`.
  - Command: invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` and `scan_folders=["tests/scripts/codex-hooks"]`; then run `poetry run pytest -q tests/scripts/dev_tools -k 'codex and (topology or deployment or routing)'` and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/codex-topology-resolver.test.ts`.
  - Acceptance: `[expect-fail]` each failure is attributable only to the absent parallel route/persona contract; unrelated failures block implementation.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/parallel-routing-fail-before.2026-08-10T20-25.md`.

- [x] [P2-T3] Add deterministic parallel planning and execution contexts to the shared routing authority.
  - Depends on: `P2-T2`.
  - Files/seams: `config/orchestration-routing.json`; `extensions/drm-copilot/resources/config/orchestration-routing.json`; `scripts/dev_tools/resolve_codex_topology.py`; `scripts/dev_tools/resolve_codex_deployment.py`; `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts`; `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts`.
  - Acceptance: one canonical configuration maps root parallel planning/execution to exact generated profiles under the monotonic orchestration ceiling; Python and TypeScript resolve identical agent, model slug, reasoning effort, authority, and no-fallback decisions.

- [x] [P2-T4] Create the forced Codex `parallel-planner` and `parallel-orchestrator` agent profiles and byte-identical bundle mirrors.
  - Depends on: `P2-T3`.
  - Files/seams: create `.codex/agents/parallel-planner.toml`, `.codex/agents/parallel-orchestrator.toml`, and exact counterparts under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`.
  - Acceptance: the planner is planning-only and cannot execute implementation; the orchestrator is root-scheduler-only, cannot act as a child implementer, and both profiles require the exact routed model/reasoning/sandbox/authority without silent fallback.

- [x] [P2-T5] Create the root `parallel-plan` skill with deterministic preflight, standalone planner checkpoint, and committed kickoff output.
  - Depends on: `P2-T4`.
  - Files/seams: create `.agents/skills/parallel-plan/SKILL.md` and its byte-identical bundle counterpart; use `docs/features/parallel/<parallel-slug>/parallel-kickoff.md`, `artifacts/orchestration/parallel-planner-state.json`, shared blast-radius/cohort validators, and `parallel-planner` as the only delegate.
  - Acceptance: identical normalized issues produce identical conflict edges, Welsh-Powell order `(-degree, item_key)`, smallest-color cohorts, ascending bounded batches, complete item preflight, and a ready/not-ready checkpoint; no child implementation process can launch from this skill.

- [x] [P2-T6] Create the root `parallel-run` and manual `parallel-orchestrate` skills with the same committed-kickoff readiness contract.
  - Depends on: `P2-T5`.
  - Files/seams: create `.agents/skills/parallel-run/SKILL.md` and `.agents/skills/parallel-orchestrate/SKILL.md` plus byte-identical bundle counterparts; use `artifacts/orchestration/parallel-orchestrator-state.json` and only the forced `parallel-orchestrator` profile.
  - Acceptance: `parallel-run` rejects an uncommitted or not-ready kickoff; manual authorship cannot bypass validation; both surfaces fix base and PR target to `main`, reject integration/fan-in fields, and persist deterministic cohort/batch order before launch.

- [x] [P2-T7] Create the root `parallel-add`, `parallel-remove`, and `parallel-close` mutation skills as validated clients of the shared mutation authority.
  - Depends on: `P2-T6`.
  - Files/seams: create `.agents/skills/parallel-add/SKILL.md`, `.agents/skills/parallel-remove/SKILL.md`, and `.agents/skills/parallel-close/SKILL.md` plus byte-identical bundle counterparts; call the existing Python/MCP parallel validators rather than duplicating mutation rules in skill prose.
  - Acceptance: the skills persist complete monotonically ordered records, pin in-flight items, reject merged removal and duplicate keys, require exact item/worktree-bound detach/abandon confirmation, reject close with in-flight work, and enforce explicit close before open-mode completion.

- [x] [P2-T8] Extend standalone parallel planner/orchestrator checkpoint and kickoff validation for Codex provenance and readiness.
  - Depends on: `P2-T3`, `P2-T5`, `P2-T6`, `P1-T8`.
  - Files/seams: `scripts/dev_tools/validate_parallel_planner_state.py`; `scripts/dev_tools/validate_parallel_orchestrator_state.py` and focused helpers; `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts`; `parallel-orchestrator-state-core.ts`; `parallel-kickoff-artifact.ts`; MCP `require_ready_for_execution`, topology, and model-routing service-call paths.
  - Acceptance: schemas are versioned; parallel state never reuses epic checkpoints; readiness requires complete item preparation, committed kickoff identity, authority/topology/model receipts, mutation/drift validity, and a ledger with 0 LOST; stale or structurally mixed epic/fan-in state fails closed.

- [x] [P2-T9] Prove the root skills, forced personas, routing parity, deterministic cohort scheduling, and standalone checkpoint contracts pass together.
  - Depends on: `P2-T4`, `P2-T7`, `P2-T8`.
  - Command: invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` and `scan_folders=["tests/scripts/codex-hooks"]`; run `poetry run pytest -q tests/scripts/dev_tools -k 'parallel or codex_topology or codex_deployment'`; run `npm --prefix extensions/drm-copilot run test:unit -- --runInBand`.
  - Acceptance: all commands exit 0; positive routes resolve only the forced persona, negative ordinary/epic/fallback cases reject, planning cannot implement, and normalized conflicts/cohorts/batches plus ready-for-execution validation are identical through Python and MCP.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/parallel-roots-routing-checkpoints.2026-08-10T20-25.md`.

### Phase 3 — Generalize Child Launch and Implement the Parallel Runtime Lifecycle

- [x] [P3-T1] Add failing launcher contract tests for the surface discriminator and the parallel `main`-only adapter.
  - Depends on: `P2-T9`.
  - Files/seams: create `tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1`; extend `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` and existing epic child process-hardening/resume suites.
  - Acceptance: tests require `surface=parallel`, `base_branch=main`, `pr_target=main`, no integration/fan-in fields, one item/worktree/branch binding, immutable launch hashes, isolated `CODEX_HOME`, and unchanged epic public parameters.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/parallel-launcher-fail-before.2026-08-10T20-25.md`.

- [x] [P3-T2] Run the parallel launcher contract before implementation and retain the expected failure while proving the epic launcher remains green.
  - Depends on: `P3-T1`.
  - Command: invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` and `scan_folders=["tests/scripts/codex-hooks"]`.
  - Acceptance: `[expect-fail]` only the absent parallel adapter cases fail and all pre-existing epic cases pass; any epic regression blocks extraction.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/parallel-launcher-fail-before.2026-08-10T20-25.md`.

- [x] [P3-T3] Extract immutable launch-spec creation and validation into a surface-neutral child-launch contract core.
  - Depends on: `P3-T2`.
  - Files/seams: create `.codex/scripts/codex-child-launch-contract-core.ps1`; update `.codex/scripts/epic-child-launch-contract.ps1` into a thin epic adapter without changing its public parameter names.
  - Acceptance: the shared core version-validates surface, repository, base/head branch, worktree, exact agent/model/reasoning/permission profile, topology/model/authority/delegation receipt paths, isolated `CODEX_HOME`, child-status path, and SHA-256; the epic adapter preserves all existing inputs and integration semantics.

- [x] [P3-T4] Extract external-process launch, bounded scheduling, and status persistence into cohesive surface-neutral modules.
  - Depends on: `P3-T3`.
  - Files/seams: create `.codex/scripts/codex-child-launch-runtime.ps1` and `.codex/scripts/codex-child-launch-persistence.ps1`; update `.codex/scripts/launch-epic-child-wave.ps1` into a thin adapter.
  - Acceptance: write-heavy children launch only via `codex exec` in their bound worktree with immutable argv/environment, isolated `CODEX_HOME`, atomic status transitions, exact process exit capture, and no in-session agent as worktree authority; each reusable script remains below 500 lines.

- [x] [P3-T5] Extract authoritative child resume reconciliation into a surface-neutral module.
  - Depends on: `P3-T4`.
  - Files/seams: create `.codex/scripts/codex-child-launch-resume.ps1`; update existing epic resume/post-session callers only at their adapter seams.
  - Acceptance: resume treats cached status as non-authoritative and rejects corrupt/missing/mismatched launch hash, repository, branch, worktree, agent, model, reasoning, authority, delegation, topology, model-routing, permission, process, or child-status data before relaunch.

- [x] [P3-T6] Create the parallel launch-contract, bounded-batch launch, and resume adapters.
  - Depends on: `P3-T3`, `P3-T4`, `P3-T5`.
  - Files/seams: create `.codex/scripts/parallel-child-launch-contract.ps1`, `.codex/scripts/launch-parallel-child-batch.ps1`, and `.codex/scripts/resume-parallel-child.ps1`.
  - Acceptance: adapters require verified `origin/main`, reject integration/fan-in state, create one distinct worktree and branch per item, launch no more than manifest `max_concurrency`, fill slots by ascending item key within the persisted cohort/batch, and never let available Codex thread capacity reorder work.

- [x] [P3-T7] Add receipt-bound cohort admission and deterministic requeue validation to the shared Python and TypeScript runtime validators.
  - Depends on: `P3-T6`, `P1-T8`.
  - Files/seams: `scripts/dev_tools/validate_parallel_orchestrator_state.py` and focused cohort/drift helpers; `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-cohort-barrier.ts`, `parallel-orchestrator-state-drift.ts`, and `parallel-orchestrator-state-core.ts`.
  - Acceptance: a conflicting later cohort cannot start until every predecessor is both merged and worktree-removed; unresolved drift quiesces admission, pins running work, halts only later-started conflicts, recomputes only unstarted items, and persists ascending deterministic requeue order identically in Python and MCP.

- [x] [P3-T8] Add receipt-bound mutation, detach/abandon, and open/closed mode transitions to parallel runtime validation.
  - Depends on: `P3-T7`.
  - Files/seams: `scripts/dev_tools/parallel_mutation_protocol.py` and focused state helpers only where Codex receipt references are additive; `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-mutations.ts`; `parallel-state-records.ts`.
  - Acceptance: in-flight work remains pinned; merged removal is invalid; detach/abandon requires the exact operation, item key, worktree identity, and confirmation token; mutation records are complete and ordered; open mode cannot complete until closed; close with in-flight work is atomic rejection.

- [x] [P3-T9] Implement per-item current-head PR, merge, worktree-removal, and completion receipt handling without epic fan-in.
  - Depends on: `P3-T6`, `P3-T8`.
  - Files/seams: create `.codex/scripts/parallel-child-post-session.ps1`; update parallel checkpoint validators in Python and TypeScript only at PR/check/removal receipt seams; reuse existing Git/GitHub wrapper functions from the epic launcher.
  - Acceptance: each item owns exactly one PR targeting `main`; the recorded head SHA matches the checked head; all required checks are green for that SHA; the PR is merged to `main`; only the matching item worktree is removed; terminal completion rejects residual worktrees, stale checks, unmerged PRs, integration branches, and fan-in PRs.

- [x] [P3-T10] Reconcile parallel resume against live Git, GitHub, worktree, launch, mutation, drift, routing, model, and child-status truth.
  - Depends on: `P3-T5`, `P3-T7`, `P3-T8`, `P3-T9`.
  - Files/seams: `.codex/scripts/resume-parallel-child.ps1`; `scripts/dev_tools/validate_parallel_orchestrator_state.py` and focused resume helper; `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`.
  - Acceptance: corrupt, stale, incomplete, or mismatched external and receipt state blocks new scheduling with a stable reason code; valid interrupted state resumes the first incomplete item in persisted cohort/batch/item order without duplicating a worktree, branch, PR, mutation, or drift event.

- [x] [P3-T11] Add automated lifecycle tests for bounded concurrency, drift requeue, mutation/abandon, per-item PRs, and interrupted resume.
  - Depends on: `P3-T10`.
  - Files/seams: extend `tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1`; create `tests/scripts/codex-hooks/parallel-runtime-lifecycle.Tests.ps1`; extend Python/TypeScript parallel state suites and shared fixture corpus.
  - Acceptance: tests cover max-concurrency values 1 and greater than 1, ascending launch order, wrong profile/model/branch/repository/worktree, corrupt status, interrupted resume, later-cohort rejection, merged-versus-green distinction, drift halt/requeue, all mutation modes, matching removal, and no integration/fan-in state.

- [x] [P3-T12] Prove the generalized launcher preserves epic behavior and the parallel runtime completes only with valid child evidence.
  - Depends on: `P3-T11`.
  - Command: invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` and `scan_folders=["tests/scripts/codex-hooks"]`; run `poetry run pytest -q tests/scripts/dev_tools -k 'parallel or epic'`; run `npm --prefix extensions/drm-copilot run test:unit -- --runInBand`.
  - Acceptance: all commands exit 0; epic public behavior remains green; parallel launches are isolated and deterministically bounded; invalid lifecycle state cannot produce a completion receipt.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/parallel-launch-resume-lifecycle.2026-08-10T20-25.md`.

### Phase 4 — Apply the Authorized Translation and Register Native Mechanical Controls

- [x] [P4-T1] Generate the authorized `translate-claude-to-codex mode=apply` mapping plan from the corrected Codex research basis before applying translation-owned changes.
  - Depends on: `P3-T12`.
  - Files/seams: `.claude/settings.json`; delivered Claude parallel skills, agents, rules, and registered hooks; existing `AGENTS.md`, `.agents/`, `.codex/`; `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/translation-plan.2026-08-10T20-25.md`.
  - Acceptance: the plan contains Inputs, Mapping Table, action/trust classifications, conflicts, target files, config delta, CI backstops, and output classes; it does not cite the absent `artifacts/research/codex-native-ecosystem.2026-06-16T13-32.md` path and records exactly `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...`.

- [x] [P4-T2] Complete the translation enforceability ledger for all 18 Claude mechanical gates before applying any hook or permission target.
  - Depends on: `P4-T1`.
  - Files/seams: the Enforceability Preservation Ledger in `translation-plan.2026-08-10T20-25.md`; gate IDs G01-G18 from the feature research.
  - Acceptance: every process- or OS-enforced source gate has exactly one row; G02 per-agent tool allowlist and G16 hard stop rejection are `DEGRADED` with named tested mechanical controls; all other gates are `PRESERVED`; totals are exactly 16 PRESERVED, 2 DEGRADED, 0 LOST; any omitted, untested, or LOST row blocks apply.

- [x] [P4-T3] Implement one validation-only native hook adapter for parsing stdin, emitting deterministic decisions, and invoking shared parallel validators.
  - Depends on: `P4-T2`.
  - Files/seams: create `.codex/hooks/parallel-hook-common.ps1`; reuse native envelope and error helpers from existing Codex hooks without reading `CLAUDE_TOOL_INPUT` or `CLAUDE_SESSION_ID`.
  - Acceptance: the adapter parses `hook_event_name`, `tool_name`, and `tool_input` from stdin; allow returns exit 0 with empty stdout/stderr; deny returns exit 0 with exactly one native JSON deny envelope and empty stderr; missing/malformed stdin returns exit 2 with empty stdout and one stable hook-named stderr diagnostic; it performs no state mutation.

- [x] [P4-T4] Add root provenance and root-persona enforcement hooks for the parallel surface.
  - Depends on: `P4-T3`, `P2-T9`.
  - Files/seams: create `.codex/hooks/authorize-root-parallel-invocation.ps1` and `.codex/hooks/enforce-parallel-root-invocation.ps1`; extend existing authority store, `record-subagent-routing-attestation.ps1`, `enforce-codex-model-routing.ps1`, and `validate-codex-subagent-routing.ps1` only through additive `surface=parallel` branches.
  - Acceptance: only explicit root `parallel-plan`, `parallel-run`, or `parallel-orchestrate` invocation mints authority; mutation entries bind to the same authorized parallel identity; planner/orchestrator delegation, exact model/reasoning, and no-fallback receipts are validated; ordinary, child, and epic roots are denied.

- [x] [P4-T5] Add native cohort, drift, child-binding, worktree-removal, and abandon admission hooks as thin adapters over shared validators.
  - Depends on: `P4-T3`, `P3-T10`.
  - Files/seams: create `.codex/hooks/enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1`, `enforce-parallel-child-worktree-binding.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, and `enforce-parallel-abandon-gate.ps1`.
  - Acceptance: hooks deny a later-cohort start until conflicting predecessors are merged and worktree-removed, unresolved drift, wrong child/worktree/launch binding, mismatched removal, and any abandon request lacking the exact operation/item/worktree/confirmation tuple; PowerShell contains no duplicate cohort, mutation, or drift algorithm.

- [x] [P4-T6] Add the parallel SubagentStop continuation and root completion controls for invalid output/checkpoints.
  - Depends on: `P4-T3`, `P3-T10`.
  - Files/seams: create `.codex/hooks/validate-parallel-agent-output.ps1`; extend `validate-codex-subagent-routing.ps1` and `enforce-completion-consistency.ps1` only through parallel-specific validation dispatch.
  - Acceptance: invalid child output triggers at most one SubagentStop continuation, root completion remains denied until the full Python/MCP transition validator and immutable completion receipt pass, repeated continuation loops are prevented, and G16 remains explicitly DEGRADED pending its required CI hard gate.

- [x] [P4-T7] Add the least-privilege parallel permission/sandbox controls that compensate for the absent per-agent tool allowlist.
  - Depends on: `P4-T4`, `P4-T5`.
  - Files/seams: targeted additions to `.codex/config.toml` permission profiles, agent bindings, MCP enabled/disabled tools, network/filesystem boundaries, and PreToolUse matchers; sealed launch-spec permission fields from Phase 3.
  - Acceptance: planner has no implementation mutation authority; orchestrator alone schedules; children receive only the exact routed profile and isolated worktree boundary; forbidden tools/paths are denied mechanically; existing permissions are not removed or weakened; G02 remains explicitly DEGRADED with all compensating controls testable.

- [x] [P4-T8] Register every new hook through the repository's native nested-handler schema with targeted `.codex/config.toml` edits.
  - Depends on: `P4-T4`, `P4-T5`, `P4-T6`, `P4-T7`.
  - Files/seams: `.codex/config.toml` entries under `hooks.UserPromptSubmit`, `hooks.PreToolUse`, `hooks.SubagentStart`, and `hooks.SubagentStop`; commands point only to existing `.codex/hooks/*.ps1` entrypoints.
  - Acceptance: TOML parses; each registration has the exact matcher, command, `command_windows`, timeout/status metadata used by current Codex schema; no whole-file rewrite, Claude matcher, `notify` gate, duplicate handler, or unregistered script exists.

- [x] [P4-T9] Add registered-process tests that enumerate every new `.codex/config.toml` parallel hook rather than invoking guessed script paths.
  - Depends on: `P4-T8`.
  - Files/seams: create `tests/scripts/codex-hooks/codex-parallel-registered-transport.Tests.ps1`; extend `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1` for registration existence and parse/line-count coverage.
  - Acceptance: the test resolves matcher and command from parsed config for each new hook and covers allow, deny, malformed stdin, missing stdin, poisoned `CLAUDE_TOOL_INPUT`, poisoned `CLAUDE_SESSION_ID`, exact stdout bytes, exact stderr bytes, and exact exit code; missing any matrix cell fails the suite.

- [x] [P4-T10] Add mechanical compensating-control tests for both DEGRADED ledger rows.
  - Depends on: `P4-T7`, `P4-T9`.
  - Files/seams: `tests/scripts/codex-hooks/parallel-provenance.Tests.ps1`; `parallel-child-worktree-launcher.Tests.ps1`; `codex-parallel-registered-transport.Tests.ps1`; CI contract tests for the required parallel completion job.
  - Acceptance: G02 is tested through forced profile, permission/sandbox denial, PreToolUse denial, and sealed external launch; G16 is tested through one continuation, full state/root refusal, immutable completion receipt, and a required CI failure path; a failed control changes the row to LOST and blocks the plan.

- [x] [P4-T11] Apply translation-owned additive targets, synchronize the modified existing hook/config bundle pairs required by Phase 4 validation, and capture a deterministic diff plus target snapshots without modifying `.claude/`.
  - Depends on: `P4-T2`, `P4-T8`, `P4-T10`.
  - Files/seams: only conflict-free `add`/`merge` targets listed in `translation-plan.2026-08-10T20-25.md`; synchronize `.codex/config.toml`, `.codex/hooks/record-subagent-routing-attestation.ps1`, `.codex/hooks/enforce-codex-model-routing.ps1`, `.codex/hooks/validate-codex-subagent-routing.ps1`, and `.codex/hooks/enforce-completion-consistency.ps1` with their exact counterparts under `extensions/drm-copilot/resources/codex-and-agents-customizations/`; never modify `.claude/**`; snapshot each changed target under `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/translation-snapshots/` preserving its repository-relative path.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/translation-diff.2026-08-10T20-25.md` and `translation-snapshots/`.
  - Acceptance: the five named existing root/bundle pairs are byte-identical before `P4-T12`; the diff reports add/merge/skip/conflict status per row, contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`, 16/2/0 totals, config/trust/CI deltas, and no unresolved conflict; `.claude/` hash manifest exactly matches `P0-T7`.

- [x] [P4-T12] Prove native registration transport, compensating controls, translation structure, and `.claude/` byte invariance in one focused pass.
  - Depends on: `P4-T11`.
  - Command: verify SHA-256 equality for the five existing root/bundle pairs synchronized by `P4-T11`; invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` and `scan_folders=["tests/scripts/codex-hooks"]`; TOML-parse `.codex/config.toml`; parse every new PowerShell entrypoint; compare a fresh sorted `.claude/` SHA-256 manifest with `P0-T7`.
  - Acceptance: all five prerequisite pairs are byte-identical before PoshQC starts; all checks exit 0, every registered-process matrix cell passes, the ledger is exactly 16/2/0, each DEGRADED control is tested, all changed targets have snapshots, and `.claude/` has zero byte changes.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/native-hooks-translation-invariance.2026-08-10T20-25.md`.

### Phase 5 — Publish Root/Bundle Parity, Packs, and Payload-Only Portable Assets

- [x] [P5-T1] Add failing publisher and pack tests for every new Codex parallel source and the fixed issue-462 portable dependency set.
  - Depends on: `P4-T12`.
  - Files/seams: extend Python push-down/pack tests under `tests/scripts/dev_tools/`; extend TypeScript tests adjacent to `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` and `codex-pack-selection.ts`; extend `tests/shell/parallel_bash_manifest_membership.bats` and `parallel_payload_only.bats`.
  - Acceptance: tests enumerate the six skills, two agents, all registered hooks/shared hook modules, all launcher/runtime scripts, routing/config changes, the nine approved issue-462 Bash files, five blast-radius PowerShell modules, and `config/blast-radius.json`; missing files and any unrelated `.claude/` selection fail.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/codex-publisher-pack-fail-before.2026-08-10T20-25.md`.

- [x] [P5-T2] Run the publisher/pack contract before implementation and retain the expected missing-membership failures.
  - Depends on: `P5-T1`.
  - Command: `poetry run pytest -q tests/scripts/dev_tools -k 'codex and (push_down or pack or parity or publisher)'`; `npm --prefix extensions/drm-copilot run test:unit -- --runInBand`; `bash scripts/bash/shell-qc.sh test`.
  - Acceptance: `[expect-fail]` failures identify only missing new Codex membership, fixed portable selection, additive merge, or destination closure; existing Claude/epic publisher cases remain green.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/codex-publisher-pack-fail-before.2026-08-10T20-25.md`.

- [x] [P5-T3] Create every new bundle counterpart and enforce comprehensive byte parity for every new or modified root Codex customization.
  - Depends on: `P5-T2`.
  - Files/seams: create counterparts for every new `.agents/**` and `.codex/**` path, mirror every remaining changed `AGENTS.md`, `.agents/**`, `.codex/**`, and `config/orchestration-routing.json` path under `extensions/drm-copilot/resources/codex-and-agents-customizations/`, reverify the five existing pairs synchronized early by `P4-T11`, and retain `extensions/drm-copilot/resources/config/orchestration-routing.json` where required by the existing publisher contract.
  - Acceptance: every new counterpart exists, the comprehensive enumerated root/bundle path sets are equal, every new or modified pair has the same SHA-256 bytes, registrations reference files present in both sets, and no `.claude/` source is copied into the Codex bundle.

- [x] [P5-T4] Add the exact issue-462 cross-runtime asset allowlist to the Python Codex publisher.
  - Depends on: `P5-T3`.
  - Files/seams: `scripts/dev_tools/push_down_codex_and_agents_customizations.py` and its focused filesystem/pack selector helpers; canonical sources `.claude/lib/bash/{compute-cohorts.sh,compute-concurrency-batches.sh,parallel-cohorts.sh,parallel-common.sh,parallel-items-validate.sh,parallel-manifest-validate.sh,parallel-yaml-emit.sh,parallel-yaml-scan.sh,validate-parallel-manifest.sh}`, `.claude/lib/blast-radius/{BlastRadius.psm1,BlastRadiusConfig.psm1,BlastRadiusExtraction.psm1,BlastRadiusGlob.psm1,BlastRadiusValidation.psm1}`, and `config/blast-radius.json`.
  - Acceptance: Python publishes exactly this fixed portable set plus the Codex bundle, preserves the generic-default semantics of `config/blast-radius.json`, rejects collisions deterministically, and never selects the containing `.claude/` directories broadly.

- [x] [P5-T5] Add the same fixed cross-runtime asset allowlist to the TypeScript Codex publisher.
  - Depends on: `P5-T4`.
  - Files/seams: `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`, `codex-pack-selection.ts`, and focused filesystem adapter; use the same canonical sources and destination-relative paths as `P5-T4`.
  - Acceptance: TypeScript emits the same sorted file set and bytes as Python, applies the same collision and default-config decisions, and rejects every unrelated `.claude/` path.

- [x] [P5-T6] Generalize additive destination routing merge and reuse it from both Codex publishers.
  - Depends on: `P5-T4`, `P5-T5`.
  - Files/seams: preserve existing exports in `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts` while extracting/reusing its generic merge behavior; add the equivalent focused Python helper beside `push_down_codex_and_agents_customizations.py`; update both Codex publisher call sites.
  - Acceptance: destination-owned routes survive, source additions merge in deterministic key order, substantive collisions fail with the same reason in both languages, and neither publisher rewrites unrelated destination configuration.

- [x] [P5-T7] Add every parallel dependency closure to `core.json` and each applicable selected language pack.
  - Depends on: `P5-T3`, `P5-T4`, `P5-T5`.
  - Files/seams: the root and bundled `core.json` plus each exact language-pack manifest recorded by `P0-T5`; `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts` and Python pack selection.
  - Acceptance: full and selected packs contain all transitive skill, agent, hook, script, routing, blast-radius, Bash, and config dependencies or one machine-checked justified exclusion; duplicate membership, missing closure, and unrelated `.claude/` membership fail.

- [x] [P5-T8] Prove Python/TypeScript publisher output equality, root/bundle bytes, registrations, collisions, and pack closures.
  - Depends on: `P5-T6`, `P5-T7`.
  - Command: `poetry run pytest -q tests/scripts/dev_tools -k 'codex and (push_down or pack or parity or publisher)'`; `npm --prefix extensions/drm-copilot run test:unit -- --runInBand`; run the repository root/bundle SHA and registration-existence validators identified by `P0-T5`.
  - Acceptance: both publishers emit identical sorted path/hash manifests; every root/bundle pair is byte-identical; every config registration exists; full/selected packs close; equal existing files merge or skip and unequal collisions reject identically.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/publisher-pack-root-bundle-parity.2026-08-10T20-25.md`.

- [x] [P5-T9] Validate a published payload-only destination without Python or Poetry.
  - Depends on: `P5-T8`.
  - Files/seams: destination output from both publishers; `tests/shell/parallel_payload_only.bats`, `parallel_manifest_validate.bats`, `parallel_cohorts.bats`, `parallel_cohorts_parity.bats`, and `parallel_bash_manifest_membership.bats`.
  - Command: publish both implementations to isolated repository test destinations, remove Python/Poetry from the child `PATH`, then run `bash scripts/bash/shell-qc.sh test` against each payload-only destination.
  - Acceptance: both destinations retain destination-owned routes, validate manifests, compute identical conflict/cohort results and ascending `max_concurrency` batches, contain `config/blast-radius.json` and only approved portable assets, and run without Python or Poetry.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/payload-only-destination-parity.2026-08-10T20-25.md`.

- [x] [P5-T10] Verify CI discovers all new Python, TypeScript, Pester, Bats, parity, pack, registration, and destination suites before modifying workflows.
  - Depends on: `P5-T8`, `P5-T9`.
  - Files/seams: current `.github/workflows/` test selectors, `config/poshqc-scan.json`, Jest/Pytest/Bats discovery configuration, and the exact discovery evidence from `P0-T5`.
  - Command: run the repository test-discovery contract and enumerate every new test file against the workflow selectors.
  - Acceptance: the receipt maps every new suite to a required workflow/job; any unmapped suite is a demonstrated discovery gap and blocks `P5-T11` until mapped.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/ci-test-discovery.2026-08-10T20-25.md`.

- [x] [P5-T11] Register all new suites and the DEGRADED G16 hard backstop in CI using only demonstrated workflow deltas.
  - Depends on: `P5-T10`.
  - Files/seams: update only the exact `.github/workflows/*.yml` selectors/jobs shown missing by `P5-T10`; always ensure the required parallel completion-validation job mechanically fails invalid output/checkpoint state; include `_shell-coverage.yml` only when its existing discovery does not cover the new Bats paths.
  - Acceptance: automated branch: when discovery is complete, record `NO_WORKFLOW_DELTA_REQUIRED` and assert zero workflow diff; when a gap exists, add the smallest selector/job change, use explicit `exit 0` after intentionally failing nested `pwsh` probes, and prove every suite plus the G16 hard gate is required and executable.

- [x] [P5-T12] Prove the complete publishing and CI registration surface while preserving the delivered runtimes.
  - Depends on: `P5-T11`.
  - Command: rerun the commands from `P5-T8` and `P5-T9`, run the CI workflow-contract tests, run `bash scripts/bash/shell-qc.sh check`, and compare a fresh `.claude/` SHA-256 manifest with `P0-T7`.
  - Acceptance: all commands exit 0; publishers, packs, root/bundle, payload-only destination, registration, portable Bash, and CI contracts pass; existing epic/Claude publisher suites remain green; `.claude/` is byte-unchanged.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/publishing-ci-registration.2026-08-10T20-25.md`.

### Phase 6 — Run Full QA, Reconcile Acceptance Criteria, and Prepare the Pre-Review Commit

Each language loop below is ordered and indivisible. If a step fails or changes files, remediate the finding and restart that language at its formatting task. A clean pass requires every stated command to execute; `SKIPPED` is not a passing result.

- [x] [P6-T1] Freeze the implementation scope and reject policy, dependency, suppression, file-size, or source-ownership violations before final QA.
  - Depends on: `P5-T12`.
  - Files/seams: the baseline HEAD and exact pre-existing path/status set recorded by `P0-T7`; the explicit issue #467 path ownership declared by the `Files/seams` entries in Phases 1–5; changed `pyproject.toml`, `package.json`, lockfiles, `.agents/skills/`, `.codex/`, `.github/workflows/`, and `.claude/` paths only.
  - Command: load the `P0-T7` baseline HEAD and raw pre-existing `git status --short` path set from `evidence/baseline/git-and-claude-sha256.2026-08-10T20-25.md`; compute the current tracked path set with `git diff --name-only --diff-filter=ACMRT <P0-T7-HEAD> --` and add `git ls-files --others --exclude-standard`; subtract only byte-preserved pre-existing unrelated paths, fail closed with `SOURCE_OWNERSHIP_AMBIGUOUS` on any overlapping pre-existing path, and validate every remaining path against the explicit Phase 1–5 ownership inventory; run `git diff --check <P0-T7-HEAD> --`, `git diff --name-status <P0-T7-HEAD> --`, `git diff --numstat <P0-T7-HEAD> --`, the applicable dependency and suppression-policy checks over that owned diff, and `git diff --exit-code -- .claude`; from the owned changed paths that still exist, select only extensions `.py`, `.pyi`, `.ts`, `.tsx`, `.js`, `.mjs`, `.cjs`, `.ps1`, `.psm1`, `.psd1`, and `.sh`, then reject each file whose `(Get-Content -LiteralPath <path> | Measure-Object -Line).Lines` exceeds 500.
  - Acceptance: the baseline-derived owned path set is deterministic and contains every issue #467 production, test, and reusable script file but no preserved pre-existing unrelated path; all changes are authorized by the Phase 1–5 ownership inventory; no unapproved dependency/lockfile or suppression appears; every changed owned code file is at most 500 lines; `git diff --check` passes; and `.claude/` has no diff.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/final-scope-policy.2026-08-10T20-25.md`.

- [x] [P6-T2] Run the final TypeScript formatting step.
  - Depends on: `P6-T1`.
  - Command: `npm --prefix extensions/drm-copilot run format`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-format.2026-08-10T20-25.md`.
  - Acceptance: command exits 0 and the receipt records changed-file count; any change requires continuing only after restarting at `P6-T2`.

- [x] [P6-T3] Run the final TypeScript lint step.
  - Depends on: `P6-T2` passing without further changes.
  - Command: `npm --prefix extensions/drm-copilot run lint`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-lint.2026-08-10T20-25.md`.
  - Acceptance: command exits 0 with zero errors and no new warnings or suppressions relative to `P0-T9`.

- [x] [P6-T4] Run the final TypeScript type-check step.
  - Depends on: `P6-T3`.
  - Command: `npm --prefix extensions/drm-copilot run typecheck`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-typecheck.2026-08-10T20-25.md`.
  - Acceptance: command exits 0 with zero diagnostics and no type-check suppression.

- [x] [P6-T5] Run the final coverage-enabled TypeScript test step.
  - Depends on: `P6-T4`.
  - Command: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageDirectory=../../docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-coverage.2026-08-10T20-25`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-coverage.2026-08-10T20-25.md` and its named coverage directory.
  - Acceptance: command exits 0; all suites pass; the receipt records numeric statements, branches, functions, and lines plus new/changed-code coverage.

- [x] [P6-T6] Run the final Python formatting step.
  - Depends on: `P6-T1`.
  - Command: `poetry run black .`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-format.2026-08-10T20-25.md`.
  - Acceptance: command exits 0 and records reformatted-file count; any change requires restarting at `P6-T6`.

- [x] [P6-T7] Run the final Python lint step.
  - Depends on: `P6-T6` passing without further changes.
  - Command: `poetry run ruff check .`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-lint.2026-08-10T20-25.md`.
  - Acceptance: command exits 0 with zero findings and no new suppression relative to `P0-T13`.

- [x] [P6-T8] Run the final Python type-check step.
  - Depends on: `P6-T7`.
  - Command: `poetry run pyright`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-typecheck.2026-08-10T20-25.md`.
  - Acceptance: command exits 0 with zero errors and no type-check suppression.

- [x] [P6-T9] Run the final coverage-enabled Python test step with only canonical feature evidence outputs.
  - Depends on: `P6-T8`.
  - Command: `poetry run pytest -o addopts='' --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-coverage.2026-08-10T20-25.json`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-coverage.2026-08-10T20-25.md` and the adjacent JSON report.
  - Acceptance: command exits 0; all tests pass; the receipt records numeric line/branch coverage and new/changed-code coverage.

- [x] [P6-T10] Run the final PowerShell formatting step through PoshQC.
  - Depends on: `P6-T1`.
  - Command: invoke `mcp__drm-copilot__run_poshqc_format` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/powershell-format.2026-08-10T20-25.md`.
  - Acceptance: invocation succeeds and records changed-file count; any change requires restarting at `P6-T10`.

- [x] [P6-T11] Run the final PowerShell analyzer step through PoshQC.
  - Depends on: `P6-T10` passing without further changes.
  - Command: invoke `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/powershell-analyze.2026-08-10T20-25.md`.
  - Acceptance: invocation succeeds with zero errors and no new warnings or suppressions relative to `P0-T17`.

- [x] [P6-T12] Run the final coverage-enabled Pester step through PoshQC.
  - Depends on: `P6-T11`.
  - Command: invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` and the repository-configured scan folders.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/powershell-pester-coverage.2026-08-10T20-25.md`.
  - Acceptance: invocation succeeds; all Pester tests pass; the receipt records passed/failed/skipped counts, numeric line coverage, and new/changed hook/script coverage.

- [x] [P6-T13] Run the final Bash formatting step.
  - Depends on: `P6-T1`.
  - Command: `bash scripts/bash/shell-qc.sh format`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-format.2026-08-10T20-25.md`.
  - Acceptance: command exits 0 and records changed-file count; any change requires restarting at `P6-T13`, and `.claude/` must still match `P0-T7` before continuing.

- [x] [P6-T14] Run the final Bash shfmt/shellcheck step.
  - Depends on: `P6-T13` passing without further changes.
  - Command: `bash scripts/bash/shell-qc.sh check`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-check.2026-08-10T20-25.md`.
  - Acceptance: command exits 0 with all discovered shell files formatted and shellcheck-clean without new suppressions.

- [x] [P6-T15] Run the final Bats step with numeric Bash coverage.
  - Depends on: `P6-T14`.
  - Command: `bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-kcov.2026-08-10T20-25' bash scripts/bash/shell-qc.sh test --coverage"`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-bats-coverage.2026-08-10T20-25.md` and the named kcov directory.
  - Acceptance: command exits 0; every Bats assertion passes; the receipt records numeric Bash line coverage and new/changed portable-logic coverage.

- [x] [P6-T16] Run the deterministic cross-runtime, root/bundle, publisher, pack, registration, and payload-only parity gates.
  - Depends on: `P6-T5`, `P6-T9`, `P6-T12`, `P6-T15`.
  - Command: rerun `P1-T8`, `P2-T9`, `P3-T12`, `P4-T12`, and `P5-T12` focused commands against the final formatted tree, then run the Python/TypeScript/Bash normalized fixture comparator and root/bundle SHA validator identified by `P0-T5`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/cross-runtime-parity.2026-08-10T20-25.md`.
  - Acceptance: every command exits 0; Python, TypeScript/MCP, and Bash agree on normalization/conflicts/cohorts/batches and shared mutation/drift domains; publishers emit equal payloads; bundle, pack, registration, collision, additive merge, and payload-only gates pass.

- [x] [P6-T17] Run all existing epic and delivered Claude regression suites against the final tree.
  - Depends on: `P6-T16`.
  - Command: `poetry run pytest -q`; `npm --prefix extensions/drm-copilot run test:unit -- --runInBand`; invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"`; `bash scripts/bash/shell-qc.sh test`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/full-regression.2026-08-10T20-25.md`.
  - Acceptance: all commands exit 0; receipts include exact suite/test/assertion counts; no epic public contract, Claude parallel contract, or existing publisher behavior regresses.

- [x] [P6-T18] Exercise parallel readiness and completion through the public injected dispatch/service tests and run one feasible structural MCP dispatch/path smoke.
  - Depends on: `P6-T17`.
  - Files/seams: bounded test-only change owner `extensions/drm-copilot/test/lib/validate/parallel-codex-readiness-filesystem.test.ts` (306 lines at this revision baseline, with 194 lines of remaining policy headroom): add exactly one table-driven six-case invalid-file matrix and keep the final file at or below 500 lines; Python public-contract verification files `tests/scripts/dev_tools/test_parallel_kickoff_contract.py`, `test_validate_parallel_planner_state.py`, `test_validate_parallel_orchestrator_state.py`, `test_validate_parallel_orchestrator_state_completion.py`, `test_validate_parallel_orchestrator_state_mutations.py`, `test_validate_parallel_orchestrator_state_drift.py`, and `test_validate_parallel_orchestrator_state_cohort_barrier.py`; TypeScript verification-only public dispatch/service files `extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts`, `mcp-server-parallel-validation.test.ts`, `lib/validate/validate-orchestration-service-call.test.ts`, `orchestration-artifacts-parallel-dispatch.test.ts`, `parallel-kickoff-artifact.test.ts`, `parallel-planner-state-core.test.ts`, `parallel-orchestrator-state-completion.test.ts`, `parallel-orchestrator-state-completion-receipts.test.ts`, `parallel-orchestrator-state-mutation-receipts.test.ts`, `parallel-orchestrator-state-resume-truth.test.ts`, and `parallel-orchestrator-state-receipt-cohort.test.ts`; no production change, new test file, or lifecycle fixture path is authorized.
  - Command: first add the six rows to `extensions/drm-copilot/test/lib/validate/parallel-codex-readiness-filesystem.test.ts`, each cloning `validFiles()`, independently deleting exactly one referenced `item-101` launch, status, authority, delegation, topology, or model-routing receipt file, invoking the public injected-filesystem builder, and asserting its full exact expected stable missing-file diagnostic; before any corrective edit, run `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-codex-readiness-filesystem.test.ts` and record the exact failing row/diagnostic when RED, or record that fail-before is not applicable because all six cases already pass against the current implementation. Then run the clean TypeScript loop `npm --prefix extensions/drm-copilot run format` -> `npm --prefix extensions/drm-copilot run lint` -> `npm --prefix extensions/drm-copilot run typecheck` -> `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/repo-automation-orchestration-validation.test.ts test/mcp-server-parallel-validation.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts test/lib/validate/parallel-codex-readiness-filesystem.test.ts test/lib/validate/parallel-kickoff-artifact.test.ts test/lib/validate/parallel-planner-state-core.test.ts test/lib/validate/parallel-orchestrator-state-completion.test.ts test/lib/validate/parallel-orchestrator-state-completion-receipts.test.ts test/lib/validate/parallel-orchestrator-state-mutation-receipts.test.ts test/lib/validate/parallel-orchestrator-state-resume-truth.test.ts test/lib/validate/parallel-orchestrator-state-receipt-cohort.test.ts`, restarting at format whenever a step fails or format changes files, until one pass is clean; run the existing Python semantic command `poetry run pytest -q tests/scripts/dev_tools/test_parallel_kickoff_contract.py tests/scripts/dev_tools/test_validate_parallel_planner_state.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_completion.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`; without rerunning `P4-T12` or `P6-T16`, read `evidence/regression-testing/native-hooks-translation-invariance.2026-08-10T20-25.md` and `evidence/qa-gates/cross-runtime-parity.2026-08-10T20-25.md`, fail unless their canonical ledger summaries agree on exactly 16 PRESERVED, 2 tested DEGRADED, and 0 LOST, and cite both source artifacts in the P6-T18 evidence; then invoke `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type="plan"`, this canonical plan path, and the exact workspace root as a structural public MCP dispatch/path smoke only.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/deterministic-validator.2026-08-10T20-25.md`.
  - Acceptance: `extensions/drm-copilot/test/lib/validate/parallel-codex-readiness-filesystem.test.ts` remains at or below 500 lines and contains exactly six table rows that each remove only the named referenced file and assert the complete stable reason-code diagnostic exactly: `Parallel checkpoint items[0] launch record is missing at 'artifacts/orchestration/item-101.launch.json'.`, `Parallel checkpoint items[0] launch status is missing at 'artifacts/orchestration/item-101.status.json'.`, `Parallel checkpoint items[0] authority_receipt_path is missing at 'artifacts/orchestration/item-101.authority.json'.`, `Parallel checkpoint items[0] delegation_receipt_path is missing at 'artifacts/orchestration/item-101.delegation.json'.`, `Parallel checkpoint items[0] topology_receipt_path is missing at 'artifacts/orchestration/item-101.topology.json'.`, and `Parallel checkpoint items[0] model_routing_receipt_path is missing at 'artifacts/orchestration/item-101.model-routing.json'.`; the test-first result is attributed without fabricating a failure, and the final TypeScript format/lint/typecheck/focused-Jest loop plus the existing Python suite exit 0 in one clean pass. Through injected filesystem/Git/service fakes, the suites exercise valid and invalid canonical kickoff-path enforcement, plan-home reference versus embedded `planning_commit`, committed/worktree kickoff blob equality, referenced launch/status/authority/delegation/topology/model receipt existence, planner readiness, and orchestrator completion; the final matrices also exercise cohort barriers, ordered mutation and resolved drift, receipt binding, one per-item PR targeting `main`, exact current-head checks, merge, and matching worktree removal; the exact 16 PRESERVED/2 tested DEGRADED/0 LOST invariant is cited and revalidated only from the already-completed `P4-T12` native-hooks-translation-invariance and `P6-T16` cross-runtime-parity evidence, and is not claimed as an independent result of the named readiness/completion tests; the structural MCP plan smoke returns success and is recorded only as proof of public tool dispatch/path operation, while all semantic readiness/completion claims are assigned exclusively to the injected public tests; no temporary fixture, fake canonical lifecycle, or pre-existing lifecycle commit is required.

- [x] [P6-T19] Compare baseline and final coverage and enforce every numeric threshold and no-regression rule.
  - Depends on: `P0-T21`, `P6-T5`, `P6-T9`, `P6-T12`, `P6-T15`.
  - Files/seams: exactly two independent test-only batches with no production-file ownership. Batch A owns only `extensions/drm-copilot/test/lib/validate/parallel-codex-readiness-filesystem.test.ts` (337 lines at this revision baseline: add invalid guarded `kickoff_prompt_path` and missing committed-kickoff cases), `extensions/drm-copilot/test/lib/validate/parallel-codex-readiness.test.ts` (314 lines: add one composite malformed-evidence scenario covering launch permissions/SHA, ledger object/blank/duplicate/status, kickoff path/commit/blob/worktree, status, and authority/delegation identity with deterministic ordered errors and input immutability), and `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-completion-receipts.test.ts` (219 lines: add one `pr_number=0` rejection row). Batch B owns only `tests/shell/parallel_cohorts.bats` (222 lines: add `--help` and unknown-option cases), `tests/shell/parallel_yaml_subset.bats` (181 lines: add an exotic mapping-key case, a multi-document case, and null/false scalar cases), and `tests/shell/parallel_manifest_validate.bats` (165 lines: add `--help`). Every owner must remain at or below 500 lines and use existing in-memory, injected, environment, stub, or tracked-fixture seams without creating temporary files or directories. Coverage comparison ownership remains all baseline and QA coverage receipts/reports under this feature's `evidence/baseline/` and `evidence/qa-gates/` directories.
  - Command: execute Batch A first. Add only the specified TypeScript tests, run `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-codex-readiness-filesystem.test.ts test/lib/validate/parallel-codex-readiness.test.ts test/lib/validate/parallel-orchestrator-state-completion-receipts.test.ts` before any corrective edit, and record the exact failing test and diagnostic when RED or record that fail-before is not applicable when the new assertions already pass; a failure attributable to production is `BLOCKED` because no production change is authorized. Then restart and complete the full `P6-T2` through `P6-T5` loop in order with `npm --prefix extensions/drm-copilot run format`, `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, and `npm --prefix extensions/drm-copilot run test:coverage -- --coverageDirectory=../../docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-coverage.2026-08-10T20-25`; refresh `typescript-format.2026-08-10T20-25.md`, `typescript-lint.2026-08-10T20-25.md`, `typescript-typecheck.2026-08-10T20-25.md`, `typescript-coverage.2026-08-10T20-25.md`, and the named coverage directory, and restart at format whenever a step fails or changes files until one pass is clean. Only after Batch A is clean, execute Batch B: add only the specified Bats cases, run `bash scripts/bash/shell-qc.sh test` before any corrective edit and attribute any RED case exactly or record that fail-before is not applicable when the assertions already pass; a failure attributable to production is `BLOCKED`. Then restart and complete the full `P6-T13` through `P6-T15` loop in order with `bash scripts/bash/shell-qc.sh format`, `bash scripts/bash/shell-qc.sh check`, and `bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-kcov.2026-08-10T20-25' bash scripts/bash/shell-qc.sh test --coverage"`; refresh `bash-format.2026-08-10T20-25.md`, `bash-check.2026-08-10T20-25.md`, `bash-bats-coverage.2026-08-10T20-25.md`, and the named kcov directory, and restart at format whenever a step fails or changes files until one pass is clean. Deterministically count all six owners and fail if any exceeds 500 lines, then recompute P6-T19 from the canonical TypeScript, Python, PowerShell, and Bash baseline/final receipts and reports, including per-language baseline/final/delta values, changed-code values, and each individual issue #467 production owner's applicable threshold result.
  - Acceptance: Batch A and Batch B change only their three named test owners, execute sequentially, use no temporary filesystem artifact, and finish with every owner at or below 500 lines; test-first outcomes are attributed without fabricating a failure, and no production file changes. The refreshed TypeScript and Bash loops each pass in the mandated order in one clean pass and replace their canonical evidence with exact commands, exit codes, result summaries, and numeric coverage; the comparison then records numeric baseline, final, delta, and new/changed-code values for TypeScript, Python, PowerShell, and Bash plus a result for every individual issue #467 production owner/new module/class/method; repository line coverage is at least 85%, repository branch coverage is at least 75%, every new module/class/method reaches at least 90%, no changed-line coverage regresses, and any unavailable or sub-threshold aggregate or owner value is `BLOCKED` rather than `PASS`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/coverage-comparison.2026-08-10T20-25.md`.

- [x] [P6-T20] Recompute the complete `.claude/` SHA-256 manifest and prove byte invariance.
  - Depends on: `P6-T17`.
  - Command: `Get-ChildItem -LiteralPath .claude -Recurse -File | Sort-Object FullName | ForEach-Object { '{0}  {1}' -f (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash,$_.FullName.Substring((Get-Location).Path.Length + 1).Replace('\\','/') }; git diff --exit-code -- .claude`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/claude-sha256-invariance.2026-08-10T20-25.md`.
  - Acceptance: the sorted path/hash set equals `P0-T7` exactly, `git diff --exit-code -- .claude` exits 0, and no `.claude/` file was added, removed, copied, or modified.

- [x] [P6-T21] Validate canonical evidence locations, translation snapshots/diff, and the no-LOST ledger gate.
  - Depends on: `P6-T18`, `P6-T19`, `P6-T20`.
  - Files/seams: evidence-only write allowlist: existing baseline receipts `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/git-and-claude-sha256.2026-08-10T20-25.md`, `python-coverage.2026-08-10T20-25.md`, `translation-authority.2026-08-10T20-25.md`, and `typescript-coverage.2026-08-10T20-25.md`; existing regression receipts `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/codex-publisher-pack-fail-before.2026-08-10T20-25.md`, `parallel-hook-registrations.2026-08-10T20-25.md`, `parallel-permission-sandbox-controls.2026-08-10T20-25.md`, `parallel-roots-routing-checkpoints.2026-08-10T20-25.md`, and `typescript-mutation-fail-before.2026-08-10T20-25.md`; and only the G16 `parallel-completion-compensating-controls.Tests.ps1` snapshot-manifest row in `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/translation-diff.2026-08-10T20-25.md`. Read-only validation scope is the complete feature `evidence/` tree, `translation-plan.2026-08-10T20-25.md`, `translation-diff.2026-08-10T20-25.md`, and `translation-snapshots/`. Production, code, test, workflow, configuration, source snapshot, ledger-content, and recorded-result changes are prohibited.
  - Command: capture the pre-edit changed-path set and SHA-256 values for every file outside the evidence-only write allowlist in memory; use `apply_patch` to add only missing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` labels or concise summaries to the nine allowlisted command receipts while preserving every recorded command, exit code, count, hash, and result, with `parallel-roots-routing-checkpoints.2026-08-10T20-25.md` explicitly receiving its missing `Timestamp:` and `EXIT_CODE:` fields; then use `apply_patch` to change only the G16 `parallel-completion-compensating-controls.Tests.ps1` snapshot-manifest row's line-count value from `246` to `267`, final-byte value to `11,957`, and SHA-256 value to `D9ADCC70046BD0D8B8F13CDD3AF930131EB8FD2509ADEA61486CDA1D4B278121`, leaving every ledger cell and all other diff rows unchanged. Run `poetry run python scripts/dev_tools/validate_evidence_locations.py --root docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`; run a deterministic read-only schema assertion over the canonical command-receipt inventory requiring `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` on exactly 43 of 43 receipts; compare the 25 translation snapshots byte-for-byte with their final targets and require exactly 25 of 25 matching snapshot-manifest/diff rows, including the corrected G16 line count, byte count, and SHA; assert the exact `EVIDENCE_LOCATION_OVERRIDE_REJECTED: artifacts/translation/** replaced with <FEATURE>/evidence/other/...` marker and recompute the ledger totals as exactly 16 PRESERVED, 2 tested DEGRADED, and 0 LOST. Finally compare the in-memory pre-edit changed-path/hash baseline with the post-edit state and fail if any path outside the ten-file allowlist changed or if any allowlisted receipt's pre-existing command, exit code, count, hash, or result value changed.
  - Acceptance: the only content changes are missing schema labels/concise summaries in the nine named existing receipts and the three specified final-target cells in the single G16 translation-diff row; that row records `267` lines, `11,957` final bytes, and SHA-256 `D9ADCC70046BD0D8B8F13CDD3AF930131EB8FD2509ADEA61486CDA1D4B278121`; `parallel-roots-routing-checkpoints.2026-08-10T20-25.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Strict validation reports 43/43 schema-complete command receipts, 25/25 byte-matching snapshots and diff rows, the exact evidence-location override marker, and a 16 PRESERVED/2 tested DEGRADED/0 LOST ledger; no forbidden evidence location exists. Every previously recorded command, exit code, count, hash, result, ledger entry, source snapshot, and non-allowlisted file remains unchanged; any mismatch is `BLOCKED` rather than repaired by changing production, code, tests, workflows, configuration, source snapshots, ledger content, or recorded results.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/evidence-ledger-validation.2026-08-10T20-25.md`.

- [x] [P6-T22] Reconcile every acceptance-criteria checkbox only from validated evidence.
  - Depends on: `P6-T21`.
  - Files/seams: `.agents/skills/acceptance-criteria-tracking/SKILL.md`; `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/issue.md`, `spec.md`, and `user-story.md`; the canonical feature evidence tree; and `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/issue-updates/issue-467.2026-08-10T20-25.md`. In the three requirement sources, only an individually proven criterion's checkbox token may change from `[ ]` to `[x]`; criterion text and order must remain byte-identical, and no criterion may be added or removed.
  - Command: enumerate all 58 issue/spec/user-story criteria without altering their text; for each criterion, write its source path, exact criterion text, named canonical evidence path(s), verification result, and `PASS` or `DEFERRED` disposition to `evidence/issue-updates/issue-467.2026-08-10T20-25.md` before changing its checkbox. Check only the 55 criteria whose named local evidence proves the complete criterion. Leave exactly three hosted-CI criteria unchecked and record the exact defer reason that no exact-current-PR-head hosted CI result can exist until the orchestrator-owned post-`P6-T39` branch-push/PR boundary: the issue criterion ending `required CI gates pass for the current PR head`; the spec criterion `All required GitHub checks pass for the current PR head SHA; stale-head results do not satisfy completion.`; and the user-story criterion `All required GitHub checks pass for the exact current PR head SHA; results from an earlier head do not satisfy merge or completion.`. Verify the resulting matrix is exactly 55 `PASS`, 3 explicitly `DEFERRED`, and 0 contradictory mappings, and that every criterion other than those three is checked. Assign final evidence reconciliation and checkbox-only checkoff for those three criteria to the orchestrator-owned post-`P6-T39` feature-review/remediation, PR-author, branch-push/PR, and exact-current-head CI boundary before overall orchestration completion; that boundary must update the same mapping artifact with the PR head SHA and named hosted-check evidence before checking any of the three boxes.
  - Acceptance: all 58 criteria have individual named canonical-evidence mappings in `evidence/issue-updates/issue-467.2026-08-10T20-25.md`; the 55 locally proven criteria are checked, exactly the three named hosted-CI criteria remain unchecked with precise `DEFERRED` reasons, and no mapping is contradictory. P6-T22 may be checked when and only when the local result is 55 `PASS`/3 explicitly `DEFERRED`/0 contradictory and every other criterion is checked; the three deferrals do not authorize overall completion. Evidence must precede every checkoff, stale-head CI results cannot satisfy any deferred criterion, and fabricated or inferred CI proof is prohibited. Only the orchestrator-owned post-`P6-T39` PR/current-head CI boundary may reconcile and check those three criteria after exact-current-head hosted evidence exists; criterion text, criterion count, and criterion order remain unchanged.

- [x] [P6-T23] Stage only issue #467-owned changes and collect the canonical pre-review commit context.
  - Depends on: `P6-T22`.
  - Files/seams: evidence-only normalization write set derived from the first literal `git diff --cached --check`: exactly 398 canonical generated-evidence paths comprising 387 Jest LCOV HTML files, 4 kcov JavaScript assets, and 7 evidence Markdown files; the exact sorted path manifest plus per-file pre/post non-whitespace fingerprints are recorded in `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/pre-review-commit-context.2026-08-10T20-25.md`, which is one additional canonical issue-owned allowlisted path beyond the exact 782-path pre-normalization/pre-receipt staged baseline. Conditional secondary writes are limited to the minimum exact hash/manifest reference cells in existing canonical evidence files whose recorded artifact hashes are invalidated solely by this normalization; every such evidence-only path must already belong to the original 782-path baseline, cannot increase the path count, and must have its old/new value listed in the same manifest. Product, source, test, workflow, configuration, and `.claude/` file edits are prohibited.
  - Command: run literal `git diff --cached --check` first, preserve its stdout/stderr and exit code, and parse its unique repository-relative paths into one sorted in-memory manifest; require exactly 398 paths with the 387 Jest LCOV HTML/4 kcov JavaScript/7 evidence Markdown breakdown and fail before writing if the set or categories differ. For each manifest path, capture a pre-edit SHA-256 fingerprint of the UTF-8 sequence formed by removing all whitespace while retaining every non-whitespace character in order; then perform one deterministic bulk mechanical rewrite scoped to exactly those 398 paths that removes only spaces or tabs at line ends and redundant blank lines at EOF while retaining one terminal newline. Reject any changed span not matching those two transformations, any reordered line, or any non-whitespace-character difference; capture the same post-edit fingerprint and require equality for 398/398 files. If and only if a recorded artifact hash or manifest reference becomes stale because of the permitted normalization, update only the minimum evidence-only reference cell to the exact post-normalization value, list that path and old/new value in the manifest, and fail if the reference is not one of the original exact 782 issue #467 paths; otherwise make no reference update. Verify the changed-path delta introduced by P6-T23 contains all and only the 398 manifest paths plus any explicitly listed conditional evidence-reference paths, with zero product/source/test/workflow/configuration/`.claude/` paths. Reconcile the original exact 782-path pre-normalization/pre-receipt staged baseline against `P0-T7` and the plan ownership list; create and stage `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/pre-review-commit-context.2026-08-10T20-25.md` as the sole additional path; restage the resulting exact 783 issue #467 paths; and require set equality to the original 782 paths plus that one named receipt, with 0 unstaged issue-path remainder, 0 staged unrelated paths, and 0 staged or unstaged `.claude/` paths. Run literal `git diff --cached --check` again and require exit 0 before invoking `mcp__drm-copilot__collect_commit_context` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"`; if the MCP tool is unavailable, fails, or does not return an on-disk canonical commit-context artifact, stop as `BLOCKED` without local reconstruction or fallback.
  - Acceptance: the initial cached-diff check produces the recorded exact 398-path manifest and category counts; the only bulk rewrites are trailing-space/tab removal and redundant EOF-blank-line removal on that set; all 398 pre/post non-whitespace fingerprints match, line order and every non-whitespace character are preserved, and numeric coverage values, test counts, result claims, and semantic content are unchanged. Any normalization-driven hash/manifest reference update is minimal, evidence-only, exact, individually listed, and contained within the original 782-path baseline, so it cannot increase the path count; no path outside the 398-file set changes except those listed conditional reference cells and the named pre-review receipt, and no product, source, test, workflow, configuration, or `.claude/` file changes. The final index contains exactly 783 issue #467 paths: the original exact 782-path pre-normalization/pre-receipt baseline plus only `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/pre-review-commit-context.2026-08-10T20-25.md`, with 0 remainder, 0 unrelated paths, and 0 `.claude/` paths; literal `git diff --cached --check` exits 0; and the successful `drm-copilot` MCP response produces a canonical commit-context bundle describing all and only issue #467 changes.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/pre-review-commit-context.2026-08-10T20-25.md` plus the canonical orchestration commit-context artifact.

- [x] [P6-T24] [expect-fail] Add the Python fail-before contract for the missing generated `commit-steward` family.
  - Depends on: `P6-T23`.
  - Files/seams: test-only Batch A owns exactly `tests/scripts/dev_tools/test_resolve_codex_deployment.py`, `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`, and `tests/scripts/dev_tools/test_codex_model_policy_config_parity.py`; no production, configuration, generated-profile, manifest, dependency, suppression, `.claude/`, or temporary-file change is authorized.
  - Command: use `apply_patch` to add assertions that `commit-steward` is a canonical generated family, `resolve_codex_deployment("commit-steward", "C4", "standalone", "C4")` returns `commit-steward-c4`/`gpt-5.6-sol`/`max`, the generator inventory contains exactly C1/C2/C3/C3-elevated/C4 `commit-steward` paths, and the core family set requires the base plus all five profiles; then run `poetry run pytest -q tests/scripts/dev_tools/test_resolve_codex_deployment.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_codex_model_policy_config_parity.py` before any production edit.
  - Acceptance: the three test owners remain at or below 500 lines and use only in-memory or checked-in paths; the command exits nonzero solely because the current resolver/config/generator omit `commit-steward`, with the exact failing assertions captured. An unexpected pass or any unrelated failure is `BLOCKED`; no validator exemption or behavior-change exception is authorized for this proven defect.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/commit-steward-python-fail-before.2026-08-10T20-25.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P6-T25] [expect-fail] Add the TypeScript/MCP fail-before contract for `commit-steward` routing, topology, and selected-core publishing.
  - Depends on: `P6-T24`.
  - Files/seams: test-only Batch B owns exactly `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-topology.test.ts`, and `extensions/drm-copilot/test/lib/push-down/codex-pack-selection.test.ts`; no production, manifest, dependency, suppression, `.claude/`, or temporary-file change is authorized.
  - Command: use `apply_patch` to add direct semantic tests requiring the exact C4 `commit-steward-c4` receipt and acceptance of a checkpoint that records that generated delegation with matching model/topology evidence, plus a real-manifest publisher assertion requiring the core pack to contain `.codex/agents/commit-steward.toml` and all five generated profile paths; run `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts test/lib/push-down/codex-pack-selection.test.ts` before any TypeScript or manifest edit.
  - Acceptance: each owner remains at or below 500 lines, including `orchestrator-state-codex-model-routing.test.ts`; the command exits nonzero solely on the new unsupported-family/missing-pack assertions, and the exact Python-authority tuple from `P6-T24` is the TypeScript expectation. An unexpected pass or unrelated failure is `BLOCKED`, and no TypeScript-only semantic divergence is accepted.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/commit-steward-typescript-fail-before.2026-08-10T20-25.md` with the four required command-receipt fields.

- [x] [P6-T26] Add `commit-steward` to the canonical Python model-policy and generator family authority.
  - Depends on: `P6-T24` proving the defect.
  - Files/seams: production/config Batch A owns exactly `config/orchestration-routing.json`, `scripts/dev_tools/resolve_codex_deployment.py`, and `scripts/dev_tools/generate_codex_agent_variants.py`; existing generated families, forced epic/parallel personas, aliases, profile model slugs/reasoning, dependency files, suppressions, `.claude/`, and every unrelated routing field are read-only.
  - Command: use `apply_patch` to add exactly `commit-steward` to `codex_model_policy.generated_agent_families`, `GENERATED_AGENT_FAMILIES`, and `CORE_FAMILIES`; run `poetry run python -m scripts.dev_tools.resolve_codex_deployment --logical-agent commit-steward --complexity-band C4 --execution-context standalone --orchestration-complexity-ceiling C4`, parse its JSON in memory, and run `git diff --check -- config/orchestration-routing.json scripts/dev_tools/resolve_codex_deployment.py scripts/dev_tools/generate_codex_agent_variants.py`.
  - Acceptance: the resolver emits exactly `logical_agent=commit-steward`, `deployment_agent=commit-steward-c4`, `model=gpt-5.6-sol`, `model_reasoning_effort=max`, `c3_overlay_applied=false`, and ceiling `C4`; the three owners remain below 500 lines; every prior family and forced persona is unchanged; no dependency, suppression, exemption, or unrelated production change appears.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/commit-steward-python-authority.2026-08-10T20-25.md` with the four required command-receipt fields and the exact parsed receipt.

- [x] [P6-T27] Restore TypeScript/MCP and bundled-routing parity with the canonical Python generated-family authority.
  - Depends on: `P6-T25` and `P6-T26`.
  - Files/seams: production/config Batch B owns exactly `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts` and `extensions/drm-copilot/resources/config/orchestration-routing.json`; the latter remains a byte mirror of canonical `config/orchestration-routing.json`. No other TypeScript source, config, generated profile, dependency, suppression, or `.claude/` path may change.
  - Command: use `apply_patch` to add exactly `commit-steward` to the TypeScript `GENERATED_AGENT_FAMILIES` set without changing resolver branches or error strings and to apply the identical one-family JSON change to the bundled routing config; run `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts`, compare SHA-256 of `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json`, and run `git diff --check -- extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts extensions/drm-copilot/resources/config/orchestration-routing.json`.
  - Acceptance: both tests exit 0 and produce the exact Python-authority C4 tuple; the production file is at most 500 lines after the one-family addition; the root/bundled routing JSON files are byte-identical; forced personas, aliases, all prior family results, error ordering, and model identity remain unchanged; no semantic-drift exemption or broad validator bypass exists.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/commit-steward-typescript-resolver-parity.2026-08-10T20-25.md` with the four required command-receipt fields.

- [x] [P6-T28] Generate the backward-compatible base aliases and five native `commit-steward` profiles on both Codex surfaces.
  - Depends on: `P6-T26` and `P6-T27`.
  - Files/seams: generator outputs are exactly root `.codex/agents/commit-steward.toml`, `commit-steward-c1.toml`, `commit-steward-c2.toml`, `commit-steward-c3.toml`, `commit-steward-c3-elevated.toml`, and `commit-steward-c4.toml`; their six byte-identical counterparts under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`; and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`. All other generated families, manifests, `.claude/`, dependencies, and source files are read-only.
  - Command: run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`, then `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`; compute SHA-256 for each root/bundle pair; parse all ten generated TOML documents and the two base aliases; compare each generated persona body with the canonical base allowing only generated name, description suffix, model, and reasoning fields; and compare the changed output set with the exact 13-path allowlist above.
  - Acceptance: both commands exit 0; root and bundle contain byte-identical base/C1/C2/C3/C3-elevated/C4 files; the five profiles are respectively Luna/low, Terra/medium, Terra/high, Sol/high, and Sol/max; the base remains named `commit-steward` and is the backward-compatible C3 alias; the core manifest contains each of the six paths exactly once; no existing family/profile byte changes, duplicate entry, collision, `.claude/` change, or out-of-allowlist output occurs; every reusable/config file remains below 500 lines.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/commit-steward-generated-profile-parity.2026-08-10T20-25.md` with the four required command-receipt fields, exact path inventory, model matrix, and pairwise hashes.

- [x] [P6-T29] Add focused Python checkpoint-validator and runtime-inventory coverage for generated `commit-steward` receipts.
  - Depends on: `P6-T28`.
  - Files/seams: test-only Batch C owns exactly `tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py`, `tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py`, and `tests/scripts/dev_tools/test_codex_full_migration_inventory.py`; no production, generated, dependency, suppression, `.claude/`, or temporary-file change is authorized.
  - Command: use `apply_patch` to add a valid checkpoint case whose delegation is `commit-steward-c4` and whose logical model receipt is `commit-steward`, assert strict model-routing and topology gates both return no errors, assert a base-agent delegation cannot substitute for the generated C4 deployment, and assert the root/bundle inventory includes exactly the base plus five byte-equal profiles; run `poetry run pytest -q tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py`.
  - Acceptance: all tests pass; each owner remains at or below 500 lines; every receipt is validated through the existing resolver with no support-agent exemption; `commit-steward` adds one family without deleting or weakening any existing inventory or gate assertion; no temporary filesystem fixture is created.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/commit-steward-python-validator-inventory.2026-08-10T20-25.md` with the four required command-receipt fields.

- [x] [P6-T30] Add focused Python publisher and exact core-pack membership coverage for the generated family.
  - Depends on: `P6-T28`.
  - Files/seams: test-only Batch D owns exactly `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, and `tests/scripts/dev_tools/test_push_down_codex_pack_selection.py`; production publisher code is verification-only. The obsolete `commit-steward.toml` pre-existing manifest exception may be removed only because the core manifest now owns the base and five generated profiles.
  - Command: use `apply_patch` to require exact full-tree and selected-core carriage of the six `commit-steward` files, remove only the now-invalid `commit-steward.toml` manifest exception, assert no duplicate/collision and no broad `.claude` copy, then run `poetry run pytest -q tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_pack_selection.py`.
  - Acceptance: all tests pass; every owner remains at or below 500 lines; both Python publisher modes include the exact base-plus-five closure once, selected language packs inherit it through core, full-tree output remains unchanged except the authorized profiles, and all prior collision, route-merge, issue-462 allowlist, and portable-asset assertions remain enforced.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/commit-steward-python-publisher-pack.2026-08-10T20-25.md` with the four required command-receipt fields.

- [x] [P6-T31] Complete TypeScript/MCP validator, routing-merge, and publisher-output parity for the generated family.
  - Depends on: `P6-T27`, `P6-T28`, `P6-T29`, and `P6-T30`.
  - Files/seams: test-only Batch E may add publisher assertions only to `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts` and `extensions/drm-copilot/test/lib/push-down/codex-routing-merge.test.ts`; the three test owners changed by `P6-T25` are verification-only here. No TypeScript production change beyond `P6-T27`, dependency, suppression, `.claude/`, or temporary-file change is authorized.
  - Command: use `apply_patch` to assert selected-core publication writes the base plus five generated profiles exactly once and preserves a destination-owned routing document while merging the added generated-family value; run `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts test/lib/push-down/codex-pack-selection.test.ts test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-routing-merge.test.ts`.
  - Acceptance: all five suites pass; every changed test remains at or below 500 lines; TypeScript/MCP accepts the same generated C4 receipt as Python, full/selected publisher output contains the same six-path core closure, routing merge remains additive, and no collision, destination overwrite, broad `.claude` copy, or prior family regression occurs.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/commit-steward-typescript-validator-publisher.2026-08-10T20-25.md` with the four required command-receipt fields.

- [x] [P6-T32] Run the correction-scoped Python formatting, lint, type, test, and coverage loop in repository order.
  - Depends on: `P6-T29` and `P6-T30`.
  - Files/seams: all Python/config/generated/test owners in `P6-T24`, `P6-T26`, `P6-T28`, `P6-T29`, and `P6-T30`; canonical evidence outputs only. No dependency, suppression, temporary-file, `.claude/`, or unrelated fix is authorized.
  - Command: run `poetry run black .` -> `poetry run ruff check .` -> `poetry run pyright` -> `poetry run pytest -o addopts='' --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-python-coverage.2026-08-10T20-25.json`; whenever formatting changes a file or any step fails, remediate only the authorized owner and restart at Black until one full pass is clean.
  - Acceptance: the four commands exit 0 in one clean ordered pass; no suppression or dependency is added; all production/test/reusable files remain below 500 lines; the four individual receipts record exact commands and results, and the coverage receipt records numeric line and branch results with repository lines at least 85%, branches at least 75%, new correction logic at least 90%, and no changed-line regression relative to `P0-T21`/`P6-T19`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-python-format.2026-08-10T20-25.md`, `commit-steward-python-lint.2026-08-10T20-25.md`, `commit-steward-python-typecheck.2026-08-10T20-25.md`, `commit-steward-python-coverage.2026-08-10T20-25.md`, and the adjacent JSON; each command receipt contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P6-T33] Run the correction-scoped TypeScript formatting, lint, type, test, and coverage loop in repository order.
  - Depends on: `P6-T31`.
  - Routing-mirror correction: before restarting the existing format -> lint -> typecheck -> coverage loop, authorize exactly one additional write owner: `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`. Resolve the absolute workspace root, `config/orchestration-routing.json` source, `extensions/drm-copilot/resources/config/orchestration-routing.json` Codex bundle mirror, and Claude customization destination; require all four resolved paths to remain within the workspace, require each file path to equal its named repository-relative location, and reject a missing file, directory, reparse-point escape, or source/destination alias. Parse all three JSON files before writing; require the canonical source and Codex bundle mirror to be byte-identical with equal byte count and SHA-256; and prove by deterministic object/array comparison that the Claude mirror differs only by the absent `commit-steward` member at the canonical ordinal in `codex_model_policy.generated_agent_families`. Capture the pre-copy `git status --porcelain=v1 -z` path set and `.claude/` SHA-256 inventory, then perform one binary-safe exact-byte copy from the canonical source to only the Claude mirror, parse the destination again, and require all three files to have identical bytes, byte counts, SHA-256 values, and parsed JSON. Compare pre/post status path sets and require the correction to introduce only the named Claude mirror path; require `git diff --exit-code -- .claude` and the `.claude/` inventory comparison to pass; and prohibit any other product, source, test, config, generated, or `.claude/` write during this synchronization. Persist only the named post-command receipt `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-claude-routing-mirror-sync.2026-08-10T20-25.md` with `Timestamp:`, the containment/parse/compare/copy commands, `EXIT_CODE:`, `Output Summary:`, the three pre/post byte counts and SHA-256 values, the sole-delta proof, and the recorded fact that the preceding failed P6-T33 attempt made no unauthorized write. Only after this gate passes restart the task's TypeScript loop at formatting; any containment, JSON, sole-delta, three-surface parity, or `.claude/` failure is `BLOCKED` rather than broadened scope.
  - Files/seams: TypeScript production/test owners in `P6-T25`, `P6-T27`, and `P6-T31`; the complete regenerated Jest LCOV coverage set under `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-typescript-coverage.2026-08-10T20-25/`; and canonical evidence outputs only. The complete set must be partitioned into text and binary sets before normalization. The only permitted binary paths are `lcov-report/favicon.png` and `lcov-report/sort-arrow-sprite.png`; all other regenerated files must be text. Post-coverage normalization may write only regenerated text files in that named directory which contain trailing spaces/tabs or redundant blank lines at EOF, and may remove only those whitespace sequences while retaining one terminal newline. The two PNGs are read-only during normalization. No dependency, suppression, temporary-file, `.claude/`, pre-existing coverage artifact outside the named directory, other binary path, or unrelated fix is authorized.
  - Command: run `npm --prefix extensions/drm-copilot run format` -> `npm --prefix extensions/drm-copilot run lint` -> `npm --prefix extensions/drm-copilot run typecheck` -> `npm --prefix extensions/drm-copilot run test:coverage -- --coverageDirectory=../../docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-typescript-coverage.2026-08-10T20-25`; whenever formatting changes a file or any step fails, remediate only an authorized owner and restart at formatting until one full pass is clean. After the clean Jest coverage command, derive the complete exact sorted regenerated path set from changed and untracked files beneath only the named coverage directory and classify every path as text or binary. Require the binary set to equal exactly `lcov-report/favicon.png` and `lcov-report/sort-arrow-sprite.png`, reject any path outside the coverage directory and any other binary, and capture each PNG's pre-normalization raw byte count and SHA-256. For every text path, capture in memory its SHA-256 fingerprint after removing all whitespace while preserving every non-whitespace byte in order, and capture numeric statements/branches/functions/lines values from the Jest text summary and LCOV data. Select only text files containing spaces/tabs at line ends or redundant EOF blank lines, normalize only those sequences while retaining one terminal newline, then recompute every text fingerprint and numeric coverage value, rerun the text-only whitespace scan, and recompute both PNG raw byte counts and SHA-256 values without writing either PNG.
  - Acceptance: the four toolchain commands exit 0 in one clean ordered pass; `orchestrator-state-codex-model-routing.ts` and every changed test remain at or below 500 lines; no suppression or dependency is added; receipts record numeric statements, branches, functions, lines, and new/changed-code coverage satisfying at least 85% lines, 75% branches, 90% new logic, and no changed-line regression relative to `P0-T21`/`P6-T19`. The manifest enumerates the complete regenerated Jest LCOV coverage set and partitions it without omission or overlap into a text set and the exact two-PNG binary set; the normalization subset contains text files only; every text file has equal pre/post non-whitespace fingerprints; every numeric coverage value is unchanged; the text-only scan reports zero remaining trailing-whitespace or redundant-EOF findings; each PNG's post-normalization raw byte count and SHA-256 equal its captured pre-normalization values; and no file outside the complete regenerated set changes.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-typescript-format.2026-08-10T20-25.md`, `commit-steward-typescript-lint.2026-08-10T20-25.md`, `commit-steward-typescript-typecheck.2026-08-10T20-25.md`, `commit-steward-typescript-coverage.2026-08-10T20-25.md`, `commit-steward-typescript-lcov-normalization.2026-08-10T20-25.md`, and the named coverage directory; each command receipt contains the four required fields, and the normalization receipt contains the complete regenerated-set manifest, disjoint text/binary classifications, exact text normalization subset, text-only pre/post fingerprints, numeric coverage comparison, and pre/post raw byte counts and SHA-256 values for both permitted PNGs.

- [x] [P6-T34] Re-run distribution, PoshQC, scope, evidence, coverage, `.claude`, and acceptance-criteria gates after the generated-family correction.
  - Depends on: `P6-T32` and `P6-T33`.
  - Three-surface routing parity gate: treat `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` and `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-claude-routing-mirror-sync.2026-08-10T20-25.md` as explicit P6-T33 correction owners. Without rewriting any config, resolve and containment-check the canonical root, Codex bundle mirror, and Claude customization mirror paths; parse all three JSON documents; require byte-for-byte equality, equal byte counts, equal SHA-256 values, and exactly one `commit-steward` entry at the same ordinal in each `codex_model_policy.generated_agent_families` array; verify every pre-existing family and all other JSON content remain equal; and run `git diff --exit-code -- .claude`. Persist this independent check in `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-three-surface-routing-parity.2026-08-10T20-25.md` with the four required command-receipt fields, all three paths/byte counts/SHA-256 values, JSON assertions, correction-owner inventory, and `.claude/` result. A mismatch, second `commit-steward`, additional config write, or missing correction receipt blocks P6-T35.
  - Files/seams: read-only validation covers every correction owner from `P6-T24` through `P6-T33`, `.codex/config.toml`, `config/orchestration-routing.json`, all full/selected pack manifests, root/bundle Codex agents, Python/TypeScript publisher outputs, `config/poshqc-scan.json`, `.github/workflows/`, the `P0-T7` `.claude/` byte inventory, the complete regenerated Jest LCOV manifest, disjoint text/binary classifications, text normalization subset/fingerprints, numeric coverage values, and two-PNG byte/SHA evidence from `P6-T33`, and all prior evidence/coverage receipts. Writes are limited to new canonical command receipts and evidence-backed reference additions in `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/issue-updates/issue-467.2026-08-10T20-25.md`; issue/spec/user-story checkbox and criterion text changes are prohibited because the proven result must remain exactly 55 `PASS` and 3 hosted-CI `DEFERRED`.
  - Command: run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`; rerun the focused Python commands from `P6-T29`/`P6-T30` and the TypeScript command from `P6-T31`; invoke `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"` in that order, restarting at format if it changes files or a step fails; run the existing Python/TypeScript publisher equality, routing-merge, full/selected pack, collision, registration, and issue-462 allowlist suites named in `P6-T16`; compute and compare SHA-256 for every root/bundle `commit-steward` pair. Without rewriting coverage files, independently recompute the complete `P6-T33` regenerated Jest LCOV set, partition it into text and binary sets, require the binary set to equal exactly `lcov-report/favicon.png` and `lcov-report/sort-arrow-sprite.png`, reject any other binary, recompute the exact text normalization subset and every text-only non-whitespace fingerprint, compare numeric statements/branches/functions/lines values, run the text-only whitespace scan, and compare each PNG's current raw byte count and SHA-256 with both its recorded pre-normalization and post-normalization values. Run `git diff --exit-code -- .claude` and compare a new sorted `.claude/` SHA-256 inventory with `P0-T7`; validate evidence locations; recompute the correction scope/file-size/dependency/suppression inventory and numeric Python/TypeScript/PowerShell coverage deltas; then update only evidence references in the 58-row AC mapping and verify 55 `PASS`, exactly the same 3 hosted-CI `DEFERRED`, and 0 contradictions.
  - Acceptance: every command succeeds in one clean ordered pass; PoshQC records format/analyze/test success with no new PowerShell change or suppression; generator, root/bundle bytes, both publishers, routing merge, full/selected core membership, registration, collisions, and payload closure all pass; all six `commit-steward` paths are present exactly once where required. The complete regenerated Jest LCOV set, disjoint text/binary partitions, and text normalization subset equal the `P6-T33` manifests; the binary set is exactly the two permitted PNG paths; every current text-only non-whitespace fingerprint equals its recorded pre/post value; all numeric coverage values are unchanged; the text-only whitespace scan has zero findings; and each PNG's current raw byte count and SHA-256 equal its recorded pre- and post-normalization values. `.claude/` remains byte-identical; every changed code/test/reusable file is at most 500 lines; coverage remains at least 85% lines, 75% branches, and 90% for new logic with no changed-line regression; every command has one schema-complete canonical receipt. The requirements remain exactly 55 locally proven checked criteria and the same three unchecked exact-current-head CI criteria, which stay assigned to the post-`P6-T39` boundary.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-distribution-parity.2026-08-10T20-25.md`, `commit-steward-powershell-format.2026-08-10T20-25.md`, `commit-steward-powershell-analyze.2026-08-10T20-25.md`, `commit-steward-powershell-test.2026-08-10T20-25.md`, `commit-steward-scope-coverage-ac.2026-08-10T20-25.md`, and the refreshed AC mapping; every command receipt contains the four required fields and coverage receipts contain numeric results.

- [x] [P6-T35] [expect-fail] Confirm that the configured published MCP runtime is stale while the current workspace validators accept the generated `commit-steward` checkpoint.
  - Depends on: `P6-T34`.
  - Files/seams: read-only `.codex/config.toml`, `packages/mcp-server/package.json`, `artifacts/orchestration/orchestrator-state.json`, `scripts/dev_tools/validate_orchestration_artifacts.py` and its imported validators, `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts`, and `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-topology.ts`; no source, configuration, package, checkpoint, index, dependency, or `.claude/` write is authorized.
  - Command: run `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-codex-topology --require-codex-model-routing` and require exit 0; run `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts` and require exit 0; parse `.codex/config.toml` and `packages/mcp-server/package.json` read-only and require the configured command/arguments to remain exactly `npx -y @danmoisan/drm-copilot-mcp@1.0.23` and the local package version to remain `1.0.23`; then invoke the configured `mcp__drm-copilot__validate_orchestration_artifacts` tool with `workspace_root="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"`, `artifact_type="orchestrator-state"`, `artifact_path="artifacts/orchestration/orchestrator-state.json"`, `require_codex_topology=true`, and `require_codex_model_routing=true`, preserving the complete non-passing MCP result.
  - Acceptance: the Python strict validator and focused current-source TypeScript tests pass, while the configured MCP call fails only on its stale generated-family view and includes the `Unsupported Codex logical agent: 'commit-steward'.` diagnostic; the receipt records the configured package pin, exact input, tool result, and absence of parse, path, or unrelated checkpoint failures. This expected failure is retained as stale-runtime attribution and is not treated as validator success; any configuration/package mutation, direct function call, local CLI substitution for the required MCP result, or different failure is `BLOCKED`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-configured-mcp-stale-runtime.2026-08-10T20-25.md` with `Timestamp:`, all exact commands/tool input, the configured MCP process identity, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P6-T36] Build and check a fresh repository-local stdio MCP bundle from the already-validated current TypeScript source.
  - Depends on: `P6-T35` proving only stale configured-runtime attribution.
  - Files/seams: read-only `extensions/drm-copilot/src/mcp-server.ts` and its transitive TypeScript validation source; `packages/mcp-server/package.json`, `package-lock.json`, and `esbuild-mcp-server.cjs`; generated ignored outputs only under `packages/mcp-server/node_modules/` and `packages/mcp-server/out/`; no tracked source, test, manifest, lockfile, configuration, evidence result, or `.claude/` edit is authorized.
  - Command: run, in order, `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, and `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts test/lib/validate/validate-orchestration-service-call.test.ts`; then run `npm --prefix packages/mcp-server ci`, `npm --prefix packages/mcp-server run build`, and `node --check packages/mcp-server/out/mcp-server.js`. Record SHA-256 and byte count for `extensions/drm-copilot/src/mcp-server.ts` and `packages/mcp-server/out/mcp-server.js`, require the bundle path to resolve inside the workspace, require the build input in `packages/mcp-server/esbuild-mcp-server.cjs` to remain exactly `../../extensions/drm-copilot/src/mcp-server.ts`, and run `git diff --exit-code -- packages/mcp-server/package.json packages/mcp-server/package-lock.json packages/mcp-server/esbuild-mcp-server.cjs .codex/config.toml .claude`.
  - Acceptance: format check, lint, typecheck, focused tests, locked install, build, and JavaScript syntax check all exit 0 in the stated order; the fresh `packages/mcp-server/out/mcp-server.js` is produced from the current extension MCP entrypoint and has recorded processable bytes/SHA-256; all tracked package/configuration inputs and `.claude/` remain byte-unchanged. A version bump, package publish/dry-run publish, prepack resource mutation, configuration edit, or claimed integrated-server reload/restart is prohibited.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-local-mcp-build.2026-08-10T20-25.md` with one schema-complete command result per command plus source/bundle paths, byte counts, and SHA-256 values.

- [x] [P6-T37] Validate the strict checkpoint through the fresh bundle's actual stdio MCP public boundary and prove transport equivalence for the required semantic tool.
  - Depends on: `P6-T36`.
  - Files/seams: read-only `packages/mcp-server/out/mcp-server.js`, the MCP SDK `Client` and `StdioClientTransport` modules already installed below `extensions/drm-copilot/node_modules/@modelcontextprotocol/sdk/`, and `artifacts/orchestration/orchestrator-state.json`; the only write is the named canonical evidence receipt. Importing `extensions/drm-copilot/src/**`, `mcp-tools`, `repo-automation-service`, or any validator/service function into the client is prohibited.
  - Command: execute an inline Node client from the repository root with `Client` from `./extensions/drm-copilot/node_modules/@modelcontextprotocol/sdk/dist/cjs/client/index.js` and `StdioClientTransport` from `./extensions/drm-copilot/node_modules/@modelcontextprotocol/sdk/dist/cjs/client/stdio.js`; spawn `process.execPath` with the single absolute argument `C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25\\packages\\mcp-server\\out\\mcp-server.js`, `cwd="C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25"`, and piped stderr; call `client.connect(transport)` to complete MCP `initialize`, require server name `drmCopilotExtension`, a non-null child PID, and advertised `tools` capability; call `client.listTools()`, select exactly one `validate_orchestration_artifacts` definition, and require its public input schema to include required `workspace_root`, `artifact_type`, and `artifact_path` plus properties `require_codex_topology` and `require_codex_model_routing`; then call `client.callTool({name: "validate_orchestration_artifacts", arguments: {workspace_root: "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25", artifact_type: "orchestrator-state", artifact_path: "artifacts/orchestration/orchestrator-state.json", require_codex_topology: true, require_codex_model_routing: true}})`, require `isError !== true` and `structuredContent.ok === true`, record the complete structured result, close the client, and require the child process to terminate cleanly. The inline client must print one JSON receipt containing the absolute executable/bundle/cwd, bundle SHA-256, PID, initialized server identity/capabilities, complete selected tool schema, exact call arguments, `isError`, `structuredContent`, stderr, close result, and process exit status.
  - Acceptance: one newly spawned local process performs actual MCP `initialize`, `tools/list`, and `tools/call` over SDK stdio transport; the public list exposes the same semantic `validate_orchestration_artifacts` tool and strict flags required by the configured `drm-copilot` surface; the exact-workspace strict checkpoint call returns `structuredContent.ok=true`, `isError` is absent or false, stderr is empty, and shutdown is clean. This process/transport/schema/result proof is the authorized equivalence boundary for the stale configured process; it does not authorize a direct TypeScript/service-function call, Python-only success, validator bypass, `.codex/config.toml` mutation, npm publish/version change, or an invented reload.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/commit-steward-local-stdio-mcp-validation.2026-08-10T20-25.md` with `Timestamp:`, the exact inline-client command, `EXIT_CODE:`, `Output Summary:`, and the complete JSON receipt.

- [x] [P6-T38] [expect-fail] Persist the exact already-observed root/executor collaboration-catalog rejection for generated `commit-steward-c4` without fallback.
  - Depends on: `P6-T37`.
  - Files/seams: the already-observed failed `spawn_agent` request from the running root/executor collaboration catalog; read-only `.codex/agents/commit-steward-c4.toml`; and the sole new canonical receipt `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/commit-steward-c4-running-catalog-rejection.2026-08-10T20-25.md`. No retry, fallback agent, planner relay, commit-message synthesis, index mutation, source/test/config edit, or commit is authorized in this task.
  - Command: transcribe the exact failed request boundary and returned diagnostic from the already-running root/executor collaboration catalog into the named receipt, including the requested `agent_type="commit-steward-c4"`, requested `fork_turns="none"`, absence of model/reasoning overrides, and exact rejection `unknown agent_type 'commit-steward-c4'`; record whether an agent ID was allocated and prove that no base `commit-steward`, alternate persona, local generator, or message result followed the rejection.
  - Acceptance: `[expect-fail]` the receipt contains `Timestamp:`, `Command:`, non-zero `EXIT_CODE:`, and `Output Summary:`; attributes failure only to the already-running catalog's exact unknown-agent-type rejection; records `agent_id=none`, `fallback=none`, and `message=none`; and proves the Git index, current branch, HEAD, checkpoint, plan-of-record, hard-lock inputs, production/test/config paths, `.claude/`, and preserved LCOV set were not mutated by the rejected call. Any re-execution of the known-failing call, fallback to base `commit-steward`, local synthesis, model/reasoning override, validator exemption, planner-as-relay, or commit makes the task `BLOCKED`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/commit-steward-c4-running-catalog-rejection.2026-08-10T20-25.md` with the complete schema and exact diagnostic.

- [x] [P6-T39] Resume through a fresh generated `atomic-executor-c4` catalog, regenerate drifted context deterministically, and obtain exactly one generated C4 commit message.
  - Depends on: `P6-T38`.
  - Fresh-resume contract: the root must call `spawn_agent` with exactly `agent_type="atomic-executor-c4"` and `fork_turns="none"`, omit both `model` and `reasoning_effort`, and provide the canonical plan path plus `artifacts/hard_lock_prompt.txt`, `artifacts/hard_lock_plan.sha256`, and `artifacts/orchestration/orchestrator-state.json`. Before any repository mutation, that fresh executor must inspect its own callable `spawn_agent` schema and persist proof that the exact enumerated `agent_type="commit-steward-c4"` is available; absence of that exact enum value fails closed without base-agent fallback, override, planner relay, or local synthesis. The fresh executor, not this planner and not an already-running executor, owns all remaining P6-T39 validation, restaging, context generation, generated-agent delegation, and post-delegation validation.
  - Mandatory immutable gates before delegation: revalidate the exact plan-of-record and its current SHA-256 against a deterministically refreshed `artifacts/hard_lock_plan.sha256`; require `artifacts/hard_lock_prompt.txt` to bind execution to that same plan; validate the checkpoint schema and `next_step`; require branch `feature/codex-native-parallel-orchestration-467` and HEAD `fe0413d4aca1e76b2d02d05701fba79a887d5405`; require the staged manifest to be the exact 1,036-path issue-owned set with path-set SHA-256 `6C0D593FB334223E513400533D1699DC88B850D63894C42452B723F3E98ACCFE` unless this plan/checkpoint/evidence revision creates measured drift; and run the literal `git diff --cached --check`. Require the canonical commit-context path `artifacts/commit_context.txt`, previous context SHA-256 `F7F7EA0CBAC6B82753F30E2867F368058EF634CEFDA88F2EC988C1CF19B37804`, and exact staged-set equality unless measured drift requires deterministic regeneration. Any plan, hard-lock hash, checkpoint, rejection-evidence, staged-set, or context drift must be reconciled only by adding the authorized plan/checkpoint/evidence changes to the existing issue-owned union, restaging that exact sorted union, recomputing its LF-delimited path-set SHA-256, rerunning literal cached diff-check, recollecting the canonical MCP commit context, and proving path-set equality plus a new recorded context SHA-256 before delegation; stale hashes or contexts must never be reused as passing evidence.
  - Routing, bundle, and validation gates: resolve and containment-check `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json`, and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`; require parsed and byte-identical root/bundle profile authority with equal byte counts/SHA-256 values, exactly one same-ordinal `commit-steward` family, exact root/bundle `.codex/agents/commit-steward-c4.toml` parity, and `git diff --exit-code -- .claude`. Revalidate the persisted C4 topology, complexity, and deployment receipts as exactly `commit-steward-c4`, `gpt-5.6-sol`, and `max`; run `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-codex-topology --require-codex-model-routing`; and repeat the unchanged-bundle SDK stdio MCP `initialize` -> `tools/list` -> strict `tools/call` protocol from `P6-T37` against bundle SHA-256 `AF0EBD9D5C77E76AABC113FF4977083B0407EB1DA0D4B1EE07F7AE55AACCB38E`. Reload the `P6-T33` complete Jest LCOV manifest, require exact 206-path set equality partitioned into 204 text files plus only `lcov-report/favicon.png` and `lcov-report/sort-arrow-sprite.png`, and reprove all text non-whitespace fingerprints, numeric coverage values, PNG byte counts/SHA-256 values, and whitespace checks without rewriting coverage.
  - Delegation command: only after every preceding gate passes, the fresh executor must call its proven callable `spawn_agent` with exactly `agent_type="commit-steward-c4"` and `fork_turns="none"`, omit `model` and `reasoning_effort`, and pass the fresh canonical `artifacts/commit_context.txt` plus the verified staged manifest; require exactly one conventional commit message and no explanatory text. Persist the fresh-executor delegation receipt, exact generated-agent identity and skill source `.codex/agents/commit-steward-c4.toml`, returned message bytes, and SHA-256 in `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/commit-steward-routing-context-delegation.2026-08-10T20-25.md`; if that receipt edit changes the index/context, deterministically restage and recollect context to equality before treating P6-T39 as complete. Then rerun both the strict Python checkpoint validator and the same unchanged-bundle local SDK stdio validation and require success.
  - Acceptance: the fresh root-to-executor spawn and executor-to-commit-steward spawn both use exact generated C4 types with `fork_turns="none"` and no overrides; the fresh executor's callable schema proof contains `commit-steward-c4`; exact plan/lock/checkpoint/branch/HEAD, deterministic staged set, cached diff-check, canonical context hash/set equality, root/bundle profile parity, C4 model receipts, strict Python validation, unchanged local SDK stdio validation, and LCOV preservation all pass before commit-message delegation. Any measured drift is deterministically restaged and recollected until equality is proven. Exactly one conventional message and its hash are persisted, and both strict validators pass afterward. Local message synthesis, base `commit-steward`, model/reasoning override, validator exemption, planner-as-relay, delegation before regenerated-context equality, production/test/config edits, additional binary changes, LCOV loss, or a commit in this task is prohibited and blocks `P6-T40`.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/commit-steward-routing-context-delegation.2026-08-10T20-25.md`, `artifacts/commit_context.txt`, refreshed `artifacts/hard_lock_plan.sha256`, the unchanged P6-T35 through P6-T37 MCP receipts, and persisted checkpoint receipts; each new command record contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P6-T40] Create the pre-review commit with the generated `commit-steward-c4` message and verify its identity.
  - Depends on: `P6-T39`.
  - Files/seams: the exact refreshed staged issue #467 manifest and canonical MCP commit-context bundle from `P6-T39`; the single message returned by the generated `commit-steward-c4`; Git index and current feature branch. `.agents/skills/commit-message-conventions/SKILL.md` is read-only authority through the delegated generated profile.
  - Command: verify `git diff --cached --name-only` equals the `P6-T39` refreshed manifest, its path-set SHA-256 equals the value persisted with the fresh context, and `git diff --cached --check` exits 0; run `git commit` non-interactively with the exact delegated message without editing or locally regenerating it; then run `git show --stat --oneline --decorate --no-renames HEAD` and compare `git diff-tree --no-commit-id --name-only -r HEAD` with the staged manifest.
  - Acceptance: commit succeeds; HEAD contains exactly the refreshed issue #467 staged paths and no `.claude/`, ignored local MCP build output, or unrelated path; the message is byte-identical to the `commit-steward-c4` result and matches its recorded SHA-256; the commit hash and path count are recorded. Base-agent delegation, local commit-message generation, unstaged substitution, validator bypass, pre-context-equality commit, or unrelated/concurrent content is absent. All LCOV preservation, mandatory `feature-review`, evidence-driven remediation, `pr-author`, branch push/PR, exact-current-head required CI, post-CI acceptance-criteria reconciliation, final orchestration validation, and clean-tree obligations remain mandatory after this task.
  - Evidence: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/pre-review-commit.2026-08-10T20-25.md`.

## Test Plan

- TypeScript unit/MCP integration: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageDirectory=../../docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/typescript-coverage.2026-08-10T20-25`; covers mutation/drift parity, routing, checkpoint readiness, publishers, packs, and deterministic validators.
- Python unit/property/integration: `poetry run pytest -o addopts='' --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-coverage.2026-08-10T20-25.json`; covers shared semantics, receipts, resume, publishers, packs, and backward compatibility.
- PowerShell process/runtime: `mcp__drm-copilot__run_poshqc_test` at the exact workspace root; covers actual `.codex/config.toml` registrations, native stdin transport, poisoned Claude variables, launcher isolation, lifecycle gates, and epic regressions.
- Bash/Bats portability: `bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-kcov.2026-08-10T20-25' bash scripts/bash/shell-qc.sh test --coverage"`; covers manifest, cohort/batch, membership, and payload-only behavior without Python or Poetry.
- Cross-runtime and distribution: execute `P6-T16` and `P6-T18`; require Python/TypeScript/Bash decision parity, root/bundle SHA parity, registration existence, publisher equality, collision/additive-route behavior, full/selected pack closure, payload-only execution, and public MCP validator success.
- Coverage: compare the individual numeric baseline receipts under `evidence/baseline/` with the final reports under `evidence/qa-gates/` in `coverage-comparison.2026-08-10T20-25.md`; require at least 85% repository lines, 75% repository branches, 90% new logic, and no changed-line regression.
- Post-execution orchestration boundary: after terminal atomic task `P6-T40`, return control for mandatory `feature-review`, evidence-driven remediation when required, `pr-author`, branch push and PR creation/update, exact-current-head required CI, post-CI acceptance-criteria reconciliation, final orchestration validation, and clean-tree verification; these gates remain mandatory but are outside this atomic executor plan.
- Manual testing: none; every criterion is validated by an automated unit, integration, process, payload-only, deterministic-validator, parity, or CI gate.

## Resolved Planning Decisions

- PC-01 is resolved by `P0-T2` from the current `.codex/config.toml` nested-handler schema and is verified through actual-registration process tests in `P4-T9`.
- PC-02 is resolved by `P0-T3`; Phase 3 assigns a surface-neutral launcher core and thin epic/parallel adapters while retaining the 500-line limit and epic parameter compatibility.
- PC-03 is resolved by `P0-T4` through compatibility fixtures before schema mutation; implementation must select only the proven additive receipt layout.
- PC-04 is resolved by `P0-T5` and `P5-T7`; every full/selected pack path receives one deterministic membership or justified-exclusion result.
- PC-05 is resolved by `P5-T10`; `P5-T11` permits only the automated demonstrated-gap branch and always requires the G16 CI hard backstop.
- PC-06 is resolved by retaining the supplied feature research at `artifacts/research/2026-08-10T20-10-codex-native-parallel-orchestration-research.md`, using `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md` as the corrected translation basis, and writing all implementation evidence only under this feature's canonical `evidence/` tree.
- Any later repository drift that invalidates one of these decisions fails the dependent Phase 0 acceptance criterion and returns this same plan of record for revision; it does not authorize executor replanning.
