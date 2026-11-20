# Phase 0 Execution Gate — Issue #1028 ([P0-T1])

Timestamp: 2026-11-17T17-17
Command: sh SCRATCH/issue-1028-ps.sh SCRATCH/issue-1028-matrix-summary.ps1 <worktree root>; sh SCRATCH/issue-1028-check5.sh; repository reads (Read, Grep) of the child 1 and child 2 feature folders, `config/harness-parity-matrix.json`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `docs/engineering/process-reductions/`, `artifacts/orchestration/orchestrator-state.json`
EXIT_CODE: 1
Output Summary: GATE: STOP. Checks 1, 5, 6 and 7 pass. Check 2 fails (OQ-5: no single-ecosystem agent entry is `native`). Check 3 fails (child 2 `### Interface for epic child 3` still states that child 3 imports the TypeScript exports, contrary to OQ-9). Check 4 fails (ten approved `codex->claude` positives target the pinned `.claude/skills/epic-orchestrate/SKILL.md`; the ledger-region part is undetermined).

Branch: `feature/shared-source-generators-skills-rules-mcp-agents-1028`. Merge base: the merge base of `origin/main` and `HEAD`. The integration-branch content of children 1 and 2 is on `HEAD` and is not on the merge base.

## Check 1 — Owner decisions (spec `## Owner Decisions`, `### Planning Refresh Decisions (2026-11-14)`)

| Row | Status | Default or decision the plan follows | Result |
| --- | --- | --- | --- |
| OQ-1 | pending-owner-confirmation | Repository-internal `scripts/harness-generation/`, T4 entry, PowerShell ([P1-T1]) | PASS (D-1) |
| OQ-2 | pending-owner-confirmation | Rules generator emits Codex rule-skills with per-target precedence substitutions ([P4-T1]) | PASS (D-1) |
| OQ-3 | pending-owner-confirmation | One source per Claude rule; `CLAUDE.md` reading order rewritten ([P1-T4], [P4-T2]) | PASS (D-1) |
| OQ-4 | pending-owner-confirmation | Per-target MCP data; Codex pin from `packages/mcp-server/package.json` `version` ([P1-T2]) | PASS (D-1) |
| OQ-5 | pending-owner-confirmation | Dual-ecosystem agents reconciled; single-ecosystem agents `native` through a child 1 override ([P5-T2]) | PASS for the plan; the upstream precondition fails under check 2 |
| OQ-6 | decided by owner (H3, 2026-10-31) | Converter redirected; `sync-agents-from-instructions.ps1` left to child 6 ([P2-T1] to [P2-T3]) | PASS |
| OQ-7 | pending-owner-confirmation | `AGENTS.md` carries no coverage threshold ([P1-T3], [P1-T4]) | PASS (D-1) |
| OQ-8 | pending-owner-confirmation | One feature, one plan with `## Size Justification` | PASS (D-1) |
| OQ-9 | pending-owner-confirmation | Write-scope literals passed through verbatim ([P5-T1]) | PASS for the plan; the child 2 text precondition fails under check 3 |
| PQ-1 | pending-owner-confirmation | No Copilot instruction file renamed or deleted ([P4-T1]) | PASS (D-1) |
| PQ-2 | decided by coordinator (autonomous mode, 2026-11-14) | Append-only `jest.config.cjs` entries; pinned files rendered byte-equal, no re-baseline | PASS for the plan; the gate stop condition of PQ-2 triggers under check 4 |
| D-1 to D-10 | decided by coordinator (autonomous mode, 2026-11-14) | Followed as written by the plan | PASS |

No owner answer recorded in the table differs from its default.

## Check 2 — Child 1 delivered on `HEAD`

| Item | Observation | Result |
| --- | --- | --- |
| `config/harness-parity-matrix.json` | Present; `schema_version` `1.0.0` (major 1); 655 entries | PASS |
| `config/harness-parity-matrix.schema.json` | Present | PASS |
| `scripts/harness/HarnessParityMatrix.psm1` | Present | PASS |
| `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` | Present | PASS |
| Child 1 spec heading `### Parity Matrix: Identifier Encoding` | Present in child 1 `spec.md` | PASS |
| `survey/difference-approval.md` `Approval-Status` | `approved-with-overrides` | PASS |
| E2 result or owner deferral | `## Owner Overrides` row E2: deferred (owner-run runbook not executed); no E2 result shows Codex rejecting Claude-only frontmatter keys | PASS |
| Q2 and Q4 answers | `## Owner Questions`: both "Default accepted (orchestrator, autonomous mode)" | PASS |
| `codex` `skill` entries with `disposition` `shared` | 65 entries; 0 missing `references/standard.md` and 0 missing bundle copies | PASS |
| Skill mirror selection (`claude` `skill` `generated` owner 3) | 65 entries, each `generated_from` under `.agents/skills/` | PASS |
| Rules selection (`path-scoped-rule` `generated` owner 3) | 20 Claude and 18 Copilot entries | PASS |
| MCP selection (`mcp-server` `generated` owner 3) | `claude:mcp-server:drm-copilot`, `codex:mcp-server:drm-copilot` | PASS |
| Instructions (`instructions` owner 3) | `cross-tool:instructions:AGENTS.md` `shared`; `claude:instructions:CLAUDE.md` `native` | PASS |
| Agents: Claude-only and Codex-only agents `native` (OQ-5) | The matrix holds no `native` agent entry. All 29 Claude agents and all 54 base Codex agents are `generated` with `owner_child` 3, and `## Owner Overrides` records no OQ-5 override. Single-ecosystem agents recorded as `generated`: Claude-only `commit-message`, `human-exception-runbook`, `parallel-orchestrator`, `parallel-planner`; Codex-only `5.1-beast-adjusted`, `5.1-thinking-beast-mode-adjusted`, `api-architect`, `atomic-planning`, `commentary-remediation`, `commit-steward`, `csharp-atomic-executor`, `csharp-atomic-planning`, `csharp-orchestrator`, `expert-nextjs-developer`, `expert-react-frontend-engineer`, `feature-reviewer`, `gpt-5-beast-mode`, `hlbpa`, `mentor`, `powershell-atomic-executor`, `powershell-atomic-planning`, `powershell-di-unit-test-engineer`, `powershell-orchestrator`, `prd`, `pytest-unit-test-coding`, `python-atomic-executor`, `python-atomic-planning`, `python-execution-only-typed`, `python-orchestrator`, `tdd-green`, `tdd-red`, `tdd-refactor`, `voidbeast-gpt41enhanced` (33 in total) | FAIL |

## Check 3 — Child 2 delivered on `HEAD`

| Item | Observation | Result |
| --- | --- | --- |
| `development_docs_root` in `config/orchestration-routing.json` | Present (`docs/features`) | PASS |
| `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` | Present | PASS |
| `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts` | Present | PASS |
| Write-scope checker suite | `extensions/drm-copilot/test/lib/development-docs/write-scopes.contract.test.ts` (with `write-scopes.test.ts`); recorded for [P5-T3] | PASS |
| Child 2 `### Interface for epic child 3` agrees with OQ-9 | The section still reads "Child 3's agent generator imports `WRITE_SCOPE_RULES`, `SETTINGS_ALLOW_RULES`, `REQUIRED_ARTIFACT_RULES`, `expandWriteScopeLiterals`, `expandRequiredArtifactPattern` and `KNOWN_DEVELOPMENT_DOCS_ROOTS` ...". OQ-9 states that under either answer this text must be amended by child 2's owner, and it has not been amended | FAIL |

## Check 4 — Pinned files, ledger regions and target existence

| Item | Observation | Result |
| --- | --- | --- |
| No approved child 1 difference changes a file pinned in `PINNED_FROZEN_SURFACE_HASHES` | Ten bulk-approved differences are `positive` with port direction `codex->claude` for skill `epic-orchestrate`: D-epic-orchestrate-03 (`Manifest Contract`), -04 (`Wave Computation`), -05 (`Entry Paths`), -06 (`Integration Branch and Child Worktrees`), -07 (`Wave Barrier`), -10 (`Fan-In and Conflict Handling`), -12 (`Model and Deployment Policy`), -13 (`Status Projection and Checkpoint`), -14 (`Final Integration PR`), -15 (`Completion`). Porting each adds a section to `.claude/skills/epic-orchestrate/SKILL.md`, which `PINNED_FROZEN_SURFACE_HASHES` pins. Spec PQ-2 and check 4 state that the gate stops in this case | FAIL |
| No approved child 1 difference changes text inside a recorded ledger region (D-10) | Not determined. The ledger names files of selected skills that carry approved positives (`epic-orchestrate`, `orchestrate`, `atomic-plan-contract`, `remediation-handoff-atomic-planner`, `epic-run`, `invoke-csharp-engineer`, `invoke-powershell-engineer`, `invoke-python-engineer`). Whether a ported section falls inside a stored-patch hunk or its context lines depends on where the port is placed, and can only be decided per Diff ID when the port is authored | UNDETERMINED |
| Every selected target exists at `HEAD` (D-8) | 190 selected entries; 0 missing `target_paths`. Codex rule-skill targets of [P4-T1] are defined as the existing `.agents/skills/<rule>/SKILL.md` files, so none is missing | PASS |

## Check 5 — Citation register and test disposition at the merge base

Every file, symbol and heading of `## Citation Register`, and every existing test that `## Existing Test Disposition` lists as updated or unchanged, is present at the merge base (0 missing). Every test that `## Existing Test Disposition` lists as new is absent from the working tree, and `scripts/harness-generation/` and `tests/scripts/harness-generation/` do not exist. Result: PASS.

## Check 6 — Item checkpoint route

`artifacts/orchestration/orchestrator-state.json` in the item worktree records `route_id` `large` (`next_step` `S5_atomic_execution`). Result: PASS.

## Check 7 — Measurement

The largest `.codex/agents/*.toml` holds 214 physical lines (`orchestrator-c3.toml`, `orchestrator-c3-elevated.toml`, `orchestrator-c4.toml`). Recorded for [P5-T3].

## Decision

Checks 2, 3 and 4 do not pass. No Phase 0 baseline and no later task runs.

GATE: STOP
