# Atomic Implementation Plan — enforce-model-selection-routing (Issue #305)

- **Issue:** #305
- **Feature folder:** `docs/features/active/2026-07-04-enforce-model-selection-routing-305`
- **Work Mode:** full-bug (spec.md present; user-story.md absent by default)
- **Spec (AC source of truth):** `docs/features/active/2026-07-04-enforce-model-selection-routing-305/spec.md`
- **Research:** `docs/features/active/2026-07-04-enforce-model-selection-routing-305/research/model-selection-enforcement.research.md`
- **Evidence root (canonical, non-overridable):** `docs/features/active/2026-07-04-enforce-model-selection-routing-305/evidence/`

## Conventions

- Every command-bearing task writes an evidence artifact to `docs/features/active/2026-07-04-enforce-model-selection-routing-305/evidence/<kind>/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields (coverage headline numeric values where coverage is measured). Non-canonical evidence paths (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`) are rejected; if any caller supplies one, substitute the canonical path and record `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied> replaced with <canonical>`.
- Languages in scope with mandatory coverage: Python (Black/Ruff/Pyright/Pytest, >= 85% line / >= 75% branch), PowerShell (PoshQC format/analyze + Pester), TypeScript (Prettier/ESLint/TSC/Vitest).
- Reuse `scripts/dev_tools/compute_complexity_floor.py::compute_complexity_floor` and `scripts/dev_tools/resolve_delegation_model.py::resolve_delegation_model`; never reimplement either. Per-receipt correctness reuses `_validate_model_routing_receipts` and `_validate_complexity_assessments`.
- No production, test, or script file may exceed 500 lines. If a test file would exceed it, split by scenario.
- Python `scripts/**` files have no bundle mirror. Every edited `.claude/**` file must be mirrored byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/**`.

---

### Phase 0 — Baseline capture and policy reads

- [x] [P0-T1] Read the mandatory policy files in required order (`CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; `.claude/rules/powershell.md`; `.claude/rules/typescript.md`; `.claude/rules/typescript-suppressions.md`; `.claude/rules/self-explanatory-code-commenting.md`; `.claude/rules/orchestrator-state.md`; `.claude/rules/quality-tiers.md`) and write `evidence/baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:`, and the explicit list of files read. Verification: artifact exists and lists every file above.
- [x] [P0-T2] Capture Python baseline: run `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`, `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`, `poetry run pyright scripts/dev_tools`, and `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`. Write `evidence/baseline/python-baseline.md` with each `Command:`, `EXIT_CODE:`, and an `Output Summary:` including the numeric line and branch coverage headline for `scripts/dev_tools`. Verification: artifact records all four commands with numeric coverage values.
- [x] [P0-T3] Capture PowerShell baseline: run `mcp__drm-copilot__run_poshqc_format` (check), `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` scoped to existing hook tests under `tests/scripts/claude-hooks`. Write `evidence/baseline/powershell-baseline.md` with each `Command:`, `EXIT_CODE:`, and an `Output Summary:` including Pester pass/fail counts and coverage headline. Verification: artifact records all three commands.
- [x] [P0-T4] Capture TypeScript baseline: from `extensions/drm-copilot` run `npm run format` (`prettier --write`), `npm run lint`, `npm run typecheck`, and `npm run test` (Jest via `run-jest.cjs`). Write `evidence/baseline/typescript-baseline.md` with each `Command:`, `EXIT_CODE:`, and `Output Summary:` including test pass counts. Verification: artifact records all four commands.
- [x] [P0-T5] Capture bundle-parity baseline: run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Write `evidence/baseline/bundle-parity-baseline.md` with `Command:`, `EXIT_CODE:`, `Output Summary:` (pass/fail). Verification: artifact records the command and result.

Satisfies: preflight baseline obligations for all in-scope languages; anchors the backward-compatibility regression comparison in later phases.

---

### Phase 1 — Python validator core (new gate delegate + flag wiring)

- [x] [P1-T1] Create `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` with a module docstring (Purpose/Usage/Invariants/Side Effects per `.claude/rules/self-explanatory-code-commenting.md`), a `MODEL_ROUTING_GATE` constant surface, and an `__all__` re-export list. Import `resolve_delegation_model` / `compute_complexity_floor` reuse indirectly via `_validate_model_routing_receipts` and `_validate_complexity_assessments`; do not import the two formula modules to reimplement them. Verification: `poetry run pyright scripts/dev_tools/_orchestrator_state_model_routing_gate.py` exits 0.
- [x] [P1-T2] In `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`, implement a private helper `_delegated_agents(state_map: dict[str, Any]) -> set[str]` that derives the set of delegating agents from `delegation_receipts[].agent_name` (well-formed list entries only) plus the agent implied by the delegating step named in `next_step`, with a full docstring and intent comments on the loop. Verification: `poetry run pyright` on the file exits 0.
- [x] [P1-T3] In the same module, implement the public entry point `validate_model_routing_gate(state_map: dict[str, Any]) -> list[str]` that (a) returns `[]` when `_delegated_agents(...)` is empty (backward-compat: fires only when at least one delegation record exists); (b) requires the set of `model_routing_receipts[].agent` to be a superset of the delegated-agent set, appending one checkpoint-context-prefixed error per missing agent; (c) requires a `complexity_assessments[]` entry for each phase referenced by matched routing receipts; (d) delegates per-entry correctness to `_validate_model_routing_receipts(state_map.get("model_routing_receipts"))` and `_validate_complexity_assessments(state_map.get("complexity_assessments"))` and appends their results. Include decision-logic comments on each branch. Verification: `poetry run pyright` on the file exits 0 and the module is < 500 lines.
- [x] [P1-T4] In `scripts/dev_tools/validate_orchestrator_state.py`, add the import `from scripts.dev_tools._orchestrator_state_model_routing_gate import validate_model_routing_gate` in the existing import block. Verification: `poetry run ruff check scripts/dev_tools/validate_orchestrator_state.py` exits 0 (no unused-import error).
- [x] [P1-T5] In `scripts/dev_tools/validate_orchestrator_state.py`, add the keyword-only parameter `require_model_routing: bool = False` to `validate_orchestrator_state_text(...)` and document it in the docstring `Args:` section (mirroring the `require_pr_creation_ready` wording). Verification: `poetry run pyright scripts/dev_tools/validate_orchestrator_state.py` exits 0.
- [x] [P1-T6] In `scripts/dev_tools/validate_orchestrator_state.py`, append `errors.extend(validate_model_routing_gate(state_map))` inside a new `if require_model_routing:` block placed after the `require_pr_creation_ready` block, with an intent comment noting the gate fires only when delegation records exist. Confirm the file stays <= 500 lines. Verification: `poetry run black scripts/dev_tools/validate_orchestrator_state.py` then `wc -l` shows <= 500; `poetry run pyright` exits 0.

Satisfies: AC "validate_orchestrator_state_text(..., require_model_routing=True) fails a checkpoint whose delegations lack matching receipts and passes once present/consistent"; AC "new logic lives in the new delegate; validate_orchestrator_state.py stays within 500 lines; gate reuses the per-receipt validators and does not reimplement the formulas."

---

### Phase 2 — CLI + MCP surface

- [x] [P2-T1] In `scripts/dev_tools/validate_orchestration_artifacts.py`, add `state_parser.add_argument("--require-model-routing", action="store_true", help=...)` to the `orchestrator-state` subparser in `build_parser()`. Verification: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` exits 0.
- [x] [P2-T2] In `scripts/dev_tools/validate_orchestration_artifacts.py`, forward `require_model_routing=bool(args.require_model_routing)` to `validate_orchestrator_state_text(...)` inside `_validate_from_args` for the `orchestrator-state` branch. Verification: `poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py` exits 0.
- [x] [P2-T3] In `extensions/drm-copilot/src/mcp-tool-inputs.ts`, add an optional `requireModelRouting?: boolean` field to the orchestration-artifacts input type/parse path used for the `orchestrator-state` artifact, mirroring the existing `requireComplete` plumbing. Verification: from `extensions/drm-copilot`, `npm run typecheck` exits 0.
- [x] [P2-T4] In `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, add `requireModelRouting?: boolean` to the input interface and thread it into the `orchestrator-state` case options object (mirroring the `requireComplete` spread), forwarding to `ValidateOrchestratorStateOptions`. Verification: `npm run typecheck` exits 0.
- [x] [P2-T5] In `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`, add `readonly requireModelRouting?: boolean` to `ValidateOrchestratorStateOptions` and implement the existence check ONLY: when `requireModelRouting === true` and at least one well-formed delegation receipt exists, require the set of `model_routing_receipts[].agent` to be a superset of the delegated-agent set, appending one error per missing agent. Do NOT reimplement `resolveDelegationModel` or the complexity floor (per-receipt correctness parity is out of scope for #305). Verification: `npm run lint && npm run typecheck` exits 0.
- [x] [P2-T6] In `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (and `extensions/drm-copilot/src/mcp-tool-definitions.ts` if the parameter schema is duplicated there), add the `require_model_routing` parameter to the `validate_orchestration_artifacts` tool definition with a description noting the TS side performs the existence check only and the Python validator is authoritative. Verification: `npm run typecheck` exits 0.
- [x] [P2-T7] Fallback guard: if implementing the TS existence check in P2-T5 proves disproportionate during execution, instead accept and plumb the `require_model_routing` parameter through P2-T3/P2-T4/P2-T6 as a surfacing-only no-op documented as Python-authoritative, and record full TS existence-check parity as an explicit out-of-scope follow-up in the PR description. The parameter must at minimum be accepted and plumbed. Verification: `npm run typecheck` exits 0 and the parameter appears in the tool definition.

Satisfies: AC "--require-model-routing CLI flag is added and forwarded"; AC "the MCP tool surfaces a require_model_routing parameter; the TypeScript side performs the existence check only, with full per-receipt correctness parity noted as follow-up."

---

### Phase 3 — Hooks (PreToolUse deterrent + completion gate wiring + settings)

- [x] [P3-T1] Create `.claude/hooks/enforce-model-routing-receipt.ps1` modeled on `.claude/hooks/enforce-prd-feature-before-planner.ps1`: a `[CmdletBinding()]` script with an injectable checkpoint-read wrapper function, a decision function `Invoke-ModelRoutingReceiptDecision -ToolInputRaw <string>`, and the dot-source guard `if ($MyInvocation.InvocationName -eq '.') { return }`. It reads `subagent_type` from `CLAUDE_TOOL_INPUT`, reads `artifacts/orchestration/orchestrator-state.json`, and emits a PreToolUse allow/deny JSON. Include a comment-based help block. Verification: `mcp__drm-copilot__run_poshqc_analyze` on the file exits clean.
- [x] [P3-T2] In `.claude/hooks/enforce-model-routing-receipt.ps1`, define the gated set of delegating subagent types as the union of `required_agents` across routes in `config/orchestration-routing.json`, restricted to types delegated via the `Agent` tool: the six gated types are atomic-planner, atomic-executor, feature-review, task-researcher, prd-feature, pr-author. Explicitly EXCLUDE `orchestrator` from the gated set: although the epic route's `required_agents` includes `orchestrator`, it is the caller (the orchestrating agent itself), not a subagent delegated via the `Agent` tool, so it never appears as a gated `subagent_type` and is not receipt-gated. Allow-through for any non-delegating `subagent_type`, empty/absent tool input, and malformed JSON (graceful allow). Verification: `mcp__drm-copilot__run_poshqc_analyze` exits clean.
- [x] [P3-T3] In `.claude/hooks/enforce-model-routing-receipt.ps1`, implement presence-only gating: when the `subagent_type` is in the gated set, deny with a clear `MODEL_ROUTING_RECEIPT_BLOCKED:` reason unless `model_routing_receipts[]` in the checkpoint contains at least one entry whose `agent` equals `subagent_type`; otherwise allow. Verification: `mcp__drm-copilot__run_poshqc_format` (check) and `run_poshqc_analyze` exit clean.
- [x] [P3-T4] In `.claude/hooks/validate-orchestrator-output.ps1`, update the default `$Invoker` scriptblock in `Invoke-RoutingContractValidation` to pass `--require-model-routing` alongside `--require-complete` to the Python CLI. Verification: `mcp__drm-copilot__run_poshqc_analyze` exits clean.
- [x] [P3-T5] In `.claude/hooks/validate-orchestrator-output.ps1`, surface a validator error originating from the model-routing gate as a `MODEL_ROUTING_BLOCKED:` block reason at DONE. Since one subprocess call now covers both `--require-complete` and `--require-model-routing`, ensure the block message distinguishes model-routing failures (e.g., branch on the presence of `model_routing_receipts` text in the validator output, else fall back to `ROUTING_CONTRACT_BLOCKED:`). Verification: `mcp__drm-copilot__run_poshqc_analyze` exits clean.
- [x] [P3-T6] In `.claude/settings.json`, add `{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-model-routing-receipt.ps1" }` to the existing `PreToolUse` `Agent`-matcher `hooks` array. Verification: `poetry run python -c "import json; json.load(open('.claude/settings.json'))"` exits 0.

Satisfies: AC "the PreToolUse hook blocks or flags a delegation lacking a routing receipt ... and allows non-delegating tool inputs and malformed JSON gracefully"; AC "the Completion Requirements gate refuses DONE when a delegation lacks a recorded model choice (MODEL_ROUTING_BLOCKED:)."

---

### Phase 4 — Documentation (skill, rule, orchestrator agent)

- [x] [P4-T1] In `.claude/skills/orchestrate/SKILL.md`, document the `require_model_routing` mode and the required-once-delegated invariant in the section adjacent to `## Model Selection`, and update `## Completion Requirements` to cite the new gate as part of the DONE gate. Verification: `mcp__drm-copilot__validate_orchestration_artifacts` not applicable to skills; verify by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` after the mirror is updated in Phase 6 (documentation edit itself has no toolchain gate beyond markdown).
- [x] [P4-T2] In `.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling`, add the "Model-choice reconciliation on resume" sub-procedure with steps a-e from the spec: (a) run the validator with `--require-model-routing` before the first delegation; (b) recompute the floor via `compute_complexity_floor`; (c) record a `complexity_assessments[]` entry; (d) resolve via `resolve_delegation_model` and record a `model_routing_receipts[]` entry; (e) persist and delegate with `model` = receipt model; and state that a `model_routing_preflight` block `{status, checked_at, validator_command, output_summary}` is written on resume. Verification: manual review that steps a-e and the preflight block are present; bundle-parity test in Phase 6 confirms the mirror.
- [x] [P4-T3] In `.claude/agents/orchestrator.md`, mirror the resume reconciliation steps into the Startup Protocol and state that the orchestrator MUST NOT delegate at a delegating `next_step` while `model_routing_preflight` status is `fail`. Verification: manual review; bundle-parity test in Phase 6 confirms the mirror.
- [x] [P4-T4] In `.claude/rules/orchestrator-state.md`, add a section documenting the `require_model_routing` mode and the required-once-delegated invariant as prose enforced by the Python validator (no imported schema), consistent with the existing Model-Routing-Receipt and Complexity-Assessment invariant sections. Note: this is a policy rule file; editing it is permitted for this feature because the change documents the new validator behavior (not a suppression-policy change). Verification: manual review; bundle-parity test in Phase 6 confirms the mirror.

Satisfies: AC "resume reconciliation is documented in SKILL.md Checkpoint Handling and mirrored into orchestrator.md Startup Protocol"; AC "orchestrator does not delegate at a delegating next_step while model_routing_preflight status is fail"; AC ".claude/rules/orchestrator-state.md and SKILL.md document the new mode, invariant, and resume procedure."

---

### Phase 5 — Agent frontmatter floor defaults

- [x] [P5-T1] Set `model: opus` in the frontmatter of `.claude/agents/atomic-executor.md` (mandatory). Verification: `grep -n '^model: opus' .claude/agents/atomic-executor.md` returns a match.
- [x] [P5-T2] Set `model: opus` in the frontmatter of each of `.claude/agents/atomic-planner.md`, `.claude/agents/epic-orchestrator.md`, `.claude/agents/epic-review.md`, `.claude/agents/feature-review.md`, `.claude/agents/orchestrator.md`, `.claude/agents/prd-feature.md`, `.claude/agents/staged-review.md` (each currently lacking `model:`, per the Agent Frontmatter Audit). Verification: `grep -L '^model: opus' <each file>` returns empty for all seven.
- [x] [P5-T3] Set `model: sonnet` in the frontmatter of each of `.claude/agents/csharp-typed-engineer.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/agents/python-typed-engineer.md`, `.claude/agents/typescript-engineer.md` (each currently lacking `model:`). Verification: `grep -l '^model: sonnet' <each file>` returns all four.
- [x] [P5-T4] Set `model: haiku` in the frontmatter of `.claude/agents/status-updater.md` (currently lacking `model:`). Verification: `grep -n '^model: haiku' .claude/agents/status-updater.md` returns a match.
- [x] [P5-T5] Confirm no change is made to agents that already declare a correct `model:` (`commit-message.md` haiku, `human-exception-runbook.md` sonnet, `pr-author.md` sonnet, `task-researcher.md` sonnet). Verification: `git diff --name-only` does not list those four files.

Satisfies: AC "every .claude/agents/*.md model: default is consistent with the Model-Budget Contract, with atomic-executor explicitly set to opus."

---

### Phase 6 — Bundle mirrors

- [x] [P6-T1] Mirror `.claude/settings.json` byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`. Verification: file compare shows byte identity.
- [x] [P6-T2] Mirror `.claude/hooks/enforce-model-routing-receipt.ps1` (new) and `.claude/hooks/validate-orchestrator-output.ps1` (edited) byte-identically to their `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` counterparts. Verification: file compare shows byte identity for both.
- [x] [P6-T3] Mirror `.claude/skills/orchestrate/SKILL.md` and `.claude/rules/orchestrator-state.md` byte-identically to their bundle counterparts. Verification: file compare shows byte identity for both.
- [x] [P6-T4] Mirror every edited `.claude/agents/*.md` (atomic-executor, atomic-planner, epic-orchestrator, epic-review, feature-review, orchestrator, prd-feature, staged-review, csharp-typed-engineer, powershell-typed-engineer, python-typed-engineer, typescript-engineer, status-updater) byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`. Verification: file compare shows byte identity for each edited agent file.
- [x] [P6-T5] Confirm no codex mirror is required: verify the new Agent-matcher hook is absent from `.codex/hooks/` following the precedent of `enforce-prd-feature-before-planner.ps1`, by checking the codex pack-selection manifest excludes Agent-matcher deterrents. Verification: `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` exits 0 without requiring the new hook.
- [x] [P6-T6] Run the bundle-parity contract test. Verification: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` exits 0. Write `evidence/qa-gates/bundle-parity-postchange.md` with `Command:`, `EXIT_CODE:`, `Output Summary:`.

Satisfies: AC "all bundled mirrors under extensions/drm-copilot/resources/claude-customizations/.claude/** match runtime sources byte-identically; bundle-parity contract tests pass."

---

### Phase 7 — Tests

- [x] [P7-T1] Add `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_gate.py` covering strict-mode missing-entry: a checkpoint with `delegation_receipts` for agents X and Y but `model_routing_receipts` missing Y is rejected under `require_model_routing=True`. Reuse `build_valid_orchestrator_state()` from `test_validate_orchestrator_state_remediation_loop.py`. Verification: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_gate.py -k missing` exits 0.
- [x] [P7-T2] In the same file, add strict-mode present-and-consistent: routing receipts (built from `resolve_delegation_model`) and complexity assessments present for every delegated agent/phase → zero errors under the flag. Verification: `poetry run pytest ... -k present_and_consistent` exits 0.
- [x] [P7-T3] In the same file, add strict-mode present-but-model-mismatch: a receipt whose `model != resolve_delegation_model(...)` is rejected under the flag (exercises delegation to the reused `_validate_model_routing_receipts`). Verification: `poetry run pytest ... -k mismatch` exits 0.
- [x] [P7-T4] In the same file, add backward-compatible no-delegation: a delegation-free checkpoint under `require_model_routing=True` passes (empty error list). Verification: `poetry run pytest ... -k no_delegation` exits 0. Keep the file <= 500 lines; if exceeded, split into `..._gate_strict.py` and `..._gate_backcompat.py`.
- [x] [P7-T5] Add `tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_backcompat.py` asserting byte-identical error-list equality for plain, `require_complete`, and `require_pr_creation_ready` calls with and without the routing arrays present, comparing the current output to the output with `require_model_routing` NOT passed (regression guard for backward compatibility). Verification: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_backcompat.py` exits 0.
- [x] [P7-T6] Add CLI-forwarding coverage in `tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py` (mirroring `test_validate_orchestration_artifacts_pr_creation_readiness.py`): assert `--require-model-routing` reaches `validate_orchestrator_state_text(require_model_routing=True)` via monkeypatch/spy, and flag independence (passing `--require-model-routing` alone does not trigger `require_complete`/`require_pr_creation_ready` checks and vice versa). Verification: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py` exits 0.
- [x] [P7-T7] Add `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` (dot-source the hook, inject a synthetic checkpoint via the checkpoint-read seam): allow when a `model_routing_receipts[]` entry exists for `subagent_type`; deny with `MODEL_ROUTING_RECEIPT_BLOCKED:` when absent; allow non-delegating `subagent_type`; allow on malformed JSON. Verification: `mcp__drm-copilot__run_poshqc_test` scoped to this file exits 0.
- [x] [P7-T8] Extend the existing `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` (add new cases) to assert the default `$Invoker` threads `--require-model-routing` and that a validator error naming model routing surfaces as the `MODEL_ROUTING_BLOCKED:` block reason (inject a mock `RoutingInvoker` returning model-routing error text). Verification: `mcp__drm-copilot__run_poshqc_test` scoped to this file exits 0.
- [x] [P7-T9] Add TS coverage in `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.model-routing.test.ts`: with `requireModelRouting: true`, a checkpoint whose delegated-agent set is not a subset of the routing-receipt-agent set produces an existence error; a consistent checkpoint produces none; `requireModelRouting` absent/false leaves output unchanged. Verification: from `extensions/drm-copilot`, `npm run test -- orchestrator-state-core.model-routing` exits 0. (If P2-T7 fallback was taken, assert the parameter is accepted as a no-op instead.)

Satisfies: AC "new/updated tests under tests/scripts/dev_tools/ cover strict-mode missing entry, present-and-consistent, present-but-model-mismatch, and backward-compatible no-delegation"; AC "flag-independence covered"; AC "Pester tests for the PreToolUse hook and MODEL_ROUTING_BLOCKED surfacing"; AC "plain/require_complete/require_pr_creation_ready calls return byte-identical results (regression-covered)."

---

### Phase 8 — Final QA loop and coverage gate

- [x] [P8-T1] Python format: run `poetry run black scripts/dev_tools tests/scripts/dev_tools`. If files change, restart the Python loop from this step. Write `evidence/qa-gates/python-format.md` (`Command:`, `EXIT_CODE:`, `Output Summary:`). Verification: exit 0 with no reformatting on the final pass.
- [x] [P8-T2] Python lint: run `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`. Write `evidence/qa-gates/python-lint.md`. Verification: exit 0.
- [x] [P8-T3] Python type-check: run `poetry run pyright scripts/dev_tools`. Write `evidence/qa-gates/python-typecheck.md`. Verification: exit 0.
- [x] [P8-T4] Python tests + coverage: run `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`. Write `evidence/qa-gates/python-tests.md` with numeric post-change line and branch coverage in `Output Summary:`. Verification: exit 0 and coverage >= 85% line / >= 75% branch on `scripts/dev_tools`.
- [x] [P8-T5] Coverage delta verification: compare `evidence/baseline/python-baseline.md` and `evidence/qa-gates/python-tests.md`; record baseline coverage, post-change coverage, and new/changed-code coverage for the new gate module in `evidence/qa-gates/python-coverage-delta.md`. Verification: no regression on changed lines; new module lines meet thresholds.
- [x] [P8-T6] PowerShell QA: run `mcp__drm-copilot__run_poshqc_format`, then `mcp__drm-copilot__run_poshqc_analyze`, then `mcp__drm-copilot__run_poshqc_test` for the two hooks and their tests. If any step changes files, restart the PowerShell loop from format. Write `evidence/qa-gates/powershell-qa.md` with each `Command:`, `EXIT_CODE:`, and Pester pass counts + coverage headline. Verification: all three exit clean; coverage >= 85% line / >= 75% branch on changed hooks.
- [x] [P8-T7] TypeScript QA: from `extensions/drm-copilot` run `npm run format` (`prettier --write`), `npm run lint`, `npm run typecheck`, `npm run test` (Jest via `run-jest.cjs`). If any step changes files, restart from format. Write `evidence/qa-gates/typescript-qa.md` with each `Command:`, `EXIT_CODE:`, `Output Summary:`. Verification: all four exit 0.
- [x] [P8-T8] Full bundle-parity re-run: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`. Write `evidence/qa-gates/bundle-parity-final.md`. Verification: exit 0.

Satisfies: AC "full toolchain green: format -> lint -> type-check -> tests (Pytest with coverage thresholds >= 85% line / >= 75% branch, plus Pester for the hooks)"; confirms backward-compatibility and bundle-mirror ACs under the final gate.

---

## Acceptance-Criteria Traceability Summary

- Validator gate correctness (fail when missing, pass when consistent): Phase 1, Phase 7 (P7-T1..T3).
- Backward-compatible byte-identical results: Phase 7 (P7-T5), Phase 8 (P8-T4).
- PreToolUse presence hook + graceful non-delegating/malformed handling: Phase 3 (P3-T1..T3), Phase 7 (P7-T7).
- Completion gate MODEL_ROUTING_BLOCKED: Phase 3 (P3-T4..T5), Phase 7 (P7-T8).
- Agent frontmatter floor defaults (atomic-executor = opus): Phase 5.
- Resume reconciliation documented + mirrored + preflight fail invariant: Phase 4 (P4-T2..T3).
- Tests for strict-mode scenarios + flag independence: Phase 7 (P7-T1..T4, T6).
- CLI flag added and forwarded: Phase 2 (P2-T1..T2), Phase 7 (P7-T6).
- MCP parameter surfaced, TS existence check only (parity follow-up noted): Phase 2 (P2-T3..T7), Phase 7 (P7-T9).
- Rule + skill documentation of the mode/invariant/procedure: Phase 4 (P4-T1, T4).
- New delegate module, 500-line limit, formula reuse: Phase 1 (P1-T1..T3, T6).
- Bundle mirrors byte-identical: Phase 6.
- Full toolchain green with coverage thresholds: Phase 8.

## Preflight

DIRECTIVE: PREFLIGHT VALIDATION ONLY — this plan is submitted to `atomic-executor` for validation-only preflight. The target plan path `docs/features/active/2026-07-04-enforce-model-selection-routing-305/plan.md` is reused across all revision iterations; no timestamped sibling plan file is created.
