# epic-orchestrate - Plan

- **Issue:** #275
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-02
- **Status:** Draft
- **Version:** 0.2

## Required References

- Standing instructions: [`CLAUDE.md`](../../../../CLAUDE.md)
- General Code Change Policy: [`.claude/rules/general-code-change.md`](../../../../.claude/rules/general-code-change.md)
- General Unit Test Policy: [`.claude/rules/general-unit-test.md`](../../../../.claude/rules/general-unit-test.md)
- Python: [`.claude/rules/python.md`](../../../../.claude/rules/python.md), [`.claude/rules/python-suppressions.md`](../../../../.claude/rules/python-suppressions.md)
- PowerShell: [`.claude/rules/powershell.md`](../../../../.claude/rules/powershell.md)
- TypeScript: [`.claude/rules/typescript.md`](../../../../.claude/rules/typescript.md), [`.claude/rules/typescript-suppressions.md`](../../../../.claude/rules/typescript-suppressions.md)
- Quality tiers / coverage floor: [`.claude/rules/quality-tiers.md`](../../../../.claude/rules/quality-tiers.md)
- Checkpoint invariants: [`.claude/rules/orchestrator-state.md`](../../../../.claude/rules/orchestrator-state.md)
- Code commenting: [`.claude/rules/self-explanatory-code-commenting.md`](../../../../.claude/rules/self-explanatory-code-commenting.md)
- Architecture boundaries (TypeScript): [`.claude/rules/architecture-boundaries.md`](../../../../.claude/rules/architecture-boundaries.md)
- Spec: [`spec.md`](spec.md); User Story: [`user-story.md`](user-story.md)
- Research: [`research/orchestration-mechanics.research.md`](research/orchestration-mechanics.research.md), [`research/concurrency-and-hardening.research.md`](research/concurrency-and-hardening.research.md)

**All work must comply with these policies; do not duplicate their content here.**

Evidence for every baseline/QA/coverage artifact in this plan is written under
`docs/features/active/2026-07-02-epic-orchestrate-275/evidence/<kind>/` per
`evidence-and-timestamp-conventions`. No task in this plan writes evidence under `artifacts/baselines/`,
`artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture & Policy Reads

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/architecture-boundaries.md`, `.claude/rules/quality-tiers.md`, and `.claude/rules/orchestrator-state.md`, then write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/phase0-instructions-read.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Policy Order:`, and an explicit list of the 12 files read, in the order read.

- [x] [P0-T2] Capture PowerShell format baseline: run `mcp__drm-copilot__run_poshqc_format` (check mode) against `.claude/hooks/*.ps1` and `tests/scripts/claude-hooks/*.Tests.ps1`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/powershell-format-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (pass/fail and file count).

- [x] [P0-T3] Capture PowerShell analyze baseline: run `mcp__drm-copilot__run_poshqc_analyze` against the same file set; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/powershell-analyze-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (rule-violation count).

- [x] [P0-T4] Capture PowerShell test baseline: run `mcp__drm-copilot__run_poshqc_test` (Pester, with coverage, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`) against `tests/scripts/claude-hooks/`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/powershell-test-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with numeric line and branch coverage percentages.

- [x] [P0-T5] Capture Python format baseline: run `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/python-format-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T6] Capture Python lint baseline: run `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/python-lint-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (violation count).

- [x] [P0-T7] Capture Python type-check baseline: run `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/python-typecheck-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (error count).

- [x] [P0-T8] Capture Python test baseline: run `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/python-test-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with numeric line and branch coverage percentages.

- [x] [P0-T9] Capture TypeScript format baseline: run `npm run format -- --check` (or repository-equivalent check invocation) in `extensions/drm-copilot`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/typescript-format-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T10] Capture TypeScript lint baseline: run `npm run lint` in `extensions/drm-copilot`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/typescript-lint-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (violation count).

- [x] [P0-T11] Capture TypeScript type-check baseline: run `npm run typecheck` in `extensions/drm-copilot`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/typescript-typecheck-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (error count).

- [x] [P0-T12] Capture TypeScript test baseline: run `npm run test:coverage` in `extensions/drm-copilot`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/typescript-test-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with numeric line and branch coverage percentages.

- [x] [P0-T13] Capture bundled-mirror-parity baseline: run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v` to confirm the dynamic `.claude/`-tree parity test passes before any change in this plan; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/baseline/bundled-mirror-parity-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (pass count, zero failures).

### Phase 1 — Markdown/Config: Epic Agent, Skill, Orchestrate Edits, and Routing Config

- [x] [P1-T1] Create `.claude/agents/epic-orchestrator.md` with frontmatter `tools:` including `Agent(orchestrator)`, `Agent(pr-author)`, `Read`, `Grep`, `Glob`, `Write(docs/features/epics/**)`, `Edit(docs/features/epics/**)`, `Write(artifacts/orchestration/**)`, `Edit(artifacts/orchestration/**)`, `Bash(git *)`, `Bash(gh *)`, `mcp__drm-copilot__collect_pr_context`, `mcp__drm-copilot__validate_orchestration_artifacts`; `skills:` `policy-compliance-order`, `epic-orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `evidence-and-timestamp-conventions`; `memory: project`; `hooks.SubagentStop` matcher `"epic-orchestrator"` per spec §1 and Implementation Strategy
  - Acceptance: file exists at `.claude/agents/epic-orchestrator.md`; `grep -c "Agent(orchestrator)"` against the file's `tools:` block returns >= 1; the file is distinct from (does not duplicate) `.claude/agents/orchestrator.md`'s content.

- [x] [P1-T2] Create `.claude/skills/epic-orchestrate/SKILL.md` documenting: manifest parsing and the `feature_folder`/`depends_on` schema (spec §2); the longest-path-layering wave formula `wave(f) = 0` when `depends_on(f)` is empty, else `1 + max(wave(d) for d in depends_on(f))`, with cycle/unresolved-reference rejection before kickoff; the five-step integration-branch lifecycle (spec §3); the two-layer wave-barrier design naming both `enforce-epic-wave-barrier.ps1` (deterrent) and the retrospective validator inside `validate_epic_orchestrator_state_text` (backstop) by file name (spec §7); the merge-conflict-as-remediation-finding procedure reusing R1–R5 unmodified (spec §5); worktree cleanup gated by `enforce-epic-worktree-removal-gate.ps1` (spec §9); the `epic-status.md` documentation-maintenance boundaries (spec Documentation Maintenance section); and the context-handoff procedure to dependent features (spec §10): for each non-empty `depends_on` entry, `epic-orchestrator` resolves the concrete `<dep_...>` values from its own checkpoint's `features[]` records and appends one literal upstream-context citation line (per the exact template in spec.md §10, lines 227-233) to the delegation prompt, after the epic-mode kickoff line from spec §4
  - Acceptance: file exists; contains the literal wave formula text; contains the literal hook file names `enforce-epic-wave-barrier.ps1` and `enforce-epic-worktree-removal-gate.ps1`; contains a section titled to cover documentation maintenance boundaries; contains the literal upstream-context citation-line template from spec.md §10 (or an equivalent verifiable restatement) covering `<feature_folder>`, `<dep_feature_folder>`, the spec/plan paths, and the merged-PR-number/commit-SHA fields.

- [x] [P1-T3] Edit `.claude/skills/orchestrate/SKILL.md` — insert a new numbered step 6 into `## Step S9 — CI Green Gate`, immediately after existing step 5 and before the standalone "DONE is not written..." sentence, reading: "If the checkpoint's `epic_mode` is `true`, execute `gh pr merge --merge <PR>` merging the feature branch into `epic_context.integration_branch`... On success, record `epic_merge: { merge_commit_sha, target_branch, merged_at }` in the checkpoint. On failure due to merge conflict..., convert the conflict into a synthetic Blocking finding per 'Merge-Conflict Remediation' below and re-enter the standard R1–R5 remediation loop; do not proceed to DONE." (spec §4 exact text)
  - Acceptance: `## Step S9 — CI Green Gate` section contains exactly 6 numbered steps; step 6 mentions `epic_mode`, `gh pr merge --merge`, and `epic_context.integration_branch`; steps 1–5 are textually unchanged from the pre-edit file.

- [x] [P1-T4] Edit `.claude/skills/orchestrate/SKILL.md` — insert a new bullet in `## Checkpoint Schema — CI Gate Fields`, immediately after the existing `step9_status` bullet, documenting a top-level `epic_merge` object with sub-fields `merge_commit_sha`, `target_branch`, `merged_at`, following the existing "top-level object with named sub-fields" pattern used for `ci_gate` (spec §4)
  - Acceptance: the section contains a new bullet naming `epic_merge` with all three sub-fields listed; the pre-existing `ci_gate`/`last_verified_ci_sha`/`step9_status` bullets are textually unchanged.

- [x] [P1-T5] Edit `.claude/skills/orchestrate/SKILL.md` — insert a new condition 7 into `## PR Creation Gate`, immediately after existing condition 6, reading: "`epic_mode` is `false`, OR (`epic_mode` is `true` AND the integration-branch merge (`gh pr merge --merge`) has completed and `epic_merge.merge_commit_sha` is recorded in the checkpoint)."; update the closing annotation sentence to state conditions 5–7 are additive (spec §4)
  - Acceptance: `## PR Creation Gate` lists exactly 7 numbered conditions; condition 7 mentions both `epic_mode` and `epic_merge.merge_commit_sha`; conditions 1–6 are textually unchanged.

- [x] [P1-T6] Edit `.claude/agents/orchestrator.md` — add the "Epic path" outcome to the Change Budget Routing section (objective names/references `docs/features/epics/<epic-slug>/epic-plan.md`, or explicitly requests multi-feature/epic orchestration, delegates to `Agent(epic-orchestrator)` with the manifest path instead of running change-budget/small/large routing); add `Agent(epic-orchestrator)` to the file's own `tools:` frontmatter; confirm `Agent(orchestrator)` is absent from the file's own `tools:` frontmatter (spec §1)
  - Acceptance: `grep "Agent(epic-orchestrator)"` against the file's `tools:` block returns >= 1; `grep "Agent(orchestrator)"` against the same block returns 0; the Change Budget Routing section documents a third "Epic path" outcome alongside the existing small/large outcomes.

- [x] [P1-T7] Edit `config/orchestration-routing.json` — add a new `"epic"` route object with `description`, `requires_pr_gate: true`, `required_agents: ["orchestrator", "pr-author"]`, `required_skills: ["epic-orchestrate", "orchestrate", "feature-promotion-lifecycle", "atomic-plan-contract", "acceptance-criteria-tracking", "evidence-and-timestamp-conventions", "pr-context-artifacts", "pr-base-branch-merge-base"]`, `required_mcp_tools: ["collect_pr_context", "validate_orchestration_artifacts"]`, matching the exact object shape already used by `small`/`large`/`remediation` (spec §8)
  - Acceptance: `python -m json.tool config/orchestration-routing.json` exits 0; the parsed JSON's `routes.epic` object has all five listed fields with the exact values above.

- [x] [P1-T8] Create/update the byte-identical mirror `extensions/drm-copilot/resources/config/orchestration-routing.json` to match `config/orchestration-routing.json` from P1-T7 exactly
  - Acceptance: `Compare-Object (Get-Content config/orchestration-routing.json -Raw) (Get-Content extensions/drm-copilot/resources/config/orchestration-routing.json -Raw)` (or `cmp`) reports zero differences.

### Phase 2 — PowerShell: Epic Hooks, Pester Tests, and Settings Wiring

- [x] [P2-T1] Edit `.claude/hooks/validate-orchestrator-output.ps1` — extend the top-level `param()` block with optional `-CheckpointPath` (default unchanged: `artifacts/orchestration/orchestrator-state.json`) and `-ArtifactType` (default unchanged: `orchestrator-state`) parameters; thread both into `Invoke-RoutingContractValidation`'s default `$Invoker`, changing the hardcoded `orchestrator-state` literal in its `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete` invocation to `... $ArtifactType $Path --require-complete` (spec Hooks item a)
  - Acceptance: calling the script with no parameters produces the identical default invocation string as before the edit; calling with `-CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state` produces an invocation string containing both overridden values.

- [x] [P2-T2] Update `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` — add test cases for `-CheckpointPath`/`-ArtifactType` parameterization (custom path/artifact-type threaded into the invoker) and a default-preserves-existing-behavior regression test (spec Affected Test Files)
  - Acceptance: `mcp__drm-copilot__run_poshqc_test` targeting this file reports the new `It` blocks passing and all pre-existing `It` blocks in the file still passing.

- [x] [P2-T3] Edit `.claude/hooks/enforce-pr-author-skill.ps1` — add a sixth ordered check, `Test-EpicBaseBranchOverride`, to `Test-PrAuthorReceiptVerification`: when the resolved checkpoint has `epic_mode == true`, the `gh pr create` command text must contain `--base <epic_context.integration_branch>` with the exact branch value recorded in the checkpoint; deny with reason `EPIC_BASE_BRANCH_MISMATCH` on a missing `--base` or a mismatched value; no-op (allow, unchanged behavior) when `epic_mode` is absent or `false` (spec Hooks item c)
  - Acceptance: `Test-EpicBaseBranchOverride` exists as a named function and is invoked as the sixth ordered check inside `Test-PrAuthorReceiptVerification`.

- [x] [P2-T4] Update `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — add the `Test-EpicBaseBranchOverride` allow/deny matrix: `epic_mode` false (no-op/allow), `epic_mode` true with correct `--base` (allow), `epic_mode` true with missing `--base` (deny `EPIC_BASE_BRANCH_MISMATCH`), `epic_mode` true with mismatched `--base` (deny `EPIC_BASE_BRANCH_MISMATCH`) (spec Affected Test Files)
  - Acceptance: `mcp__drm-copilot__run_poshqc_test` reports all four new `It` cases passing and all pre-existing `It` blocks in the file still passing.

- [x] [P2-T5] Create `.claude/hooks/enforce-epic-merge-gate.ps1` (new) — `PreToolUse` hook to be registered under the existing `"Bash"` matcher; regex-matches `gh pr merge` with a `--merge` flag against `CLAUDE_TOOL_INPUT.command`; decision logic per spec Hooks item b: (1) read `artifacts/orchestration/orchestrator-state.json` — allow if it exists, `epic_mode == true`, and `step9_status == "passed"`; (2) else read `artifacts/orchestration/epic-orchestrator-state.json` — allow if it exists, `epic_merge_pr.ci_gate.conclusion == "success"`, and the command's PR argument (or current branch's PR) matches `epic_merge_pr.pr_number`; (3) otherwise deny with reason `EPIC_MERGE_GATE_BLOCKED`; fail closed (deny) on missing/unreadable checkpoints in both branches; emit `hookSpecificOutput.{hookEventName, permissionDecision, permissionDecisionReason}` JSON
  - Acceptance: script exists at `.claude/hooks/enforce-epic-merge-gate.ps1`; invoking it with a synthetic `CLAUDE_TOOL_INPUT` for each of the three documented cases produces the correct `permissionDecision`/`permissionDecisionReason` values.

- [x] [P2-T6] Create `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` (new) — cover: allow via the child-checkpoint (`epic_mode`+`step9_status=="passed"`) path; allow via the epic-checkpoint (`epic_merge_pr.ci_gate.conclusion=="success"` + matching PR number) path; deny `EPIC_MERGE_GATE_BLOCKED` on a missing/unreadable checkpoint; deny on a non-matching PR number; deny on a non-`success` `ci_gate.conclusion` (spec Affected Test Files)
  - Acceptance: `mcp__drm-copilot__run_poshqc_test` reports all five `It` cases passing with zero failures.

- [x] [P2-T7] Run PowerShell format on the batch-1 files (`.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`) via `mcp__drm-copilot__run_poshqc_format`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-batch1-format.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; if any file was reformatted, this task is re-run before proceeding to P2-T8.

- [x] [P2-T8] Run PowerShell analyze on the same batch-1 file set via `mcp__drm-copilot__run_poshqc_analyze`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-batch1-analyze.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (zero rule violations); restart from P2-T7 if any violation is found and fixed.

- [x] [P2-T9] Run PowerShell Pester tests with coverage on the same batch-1 file set via `mcp__drm-copilot__run_poshqc_test`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-batch1-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` with numeric line coverage >= 85% and branch coverage >= 75% for the batch-1 files.

- [x] [P2-T10] Create `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (new) — `PreToolUse` hook to be registered under the existing `"Bash"` matcher; regex-matches `git worktree remove` against `CLAUDE_TOOL_INPUT.command`, extracts the target worktree path, reads `artifacts/orchestration/epic-orchestrator-state.json`, finds the `features[]` record whose `worktree_path` matches; allows only when that record's `merge_status` is `merged` or `worktree_removed`; denies with reason `EPIC_WORKTREE_REMOVAL_BLOCKED` when the checkpoint is unreadable, no matching record exists, or `merge_status` is anything else (spec Hooks item d)
  - Acceptance: script exists at `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`; invoking it with a synthetic `CLAUDE_TOOL_INPUT` for each documented case produces the correct `permissionDecision`/`permissionDecisionReason`.

- [x] [P2-T11] Create `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` (new) — cover: allow-on-`merged`, allow-on-`worktree_removed`, deny-on-unreadable-checkpoint, deny-on-no-matching-record, deny-on-other-status (spec Affected Test Files)
  - Acceptance: `mcp__drm-copilot__run_poshqc_test` reports all five `It` cases passing with zero failures.

- [x] [P2-T12] Create `.claude/hooks/enforce-epic-wave-barrier.ps1` (new) — `PreToolUse` hook to be registered under the existing `"Agent"` matcher; fires when `CLAUDE_TOOL_INPUT.subagent_type == "orchestrator"` and the serialized prompt contains the marker `Epic mode: true`; resolves the target `feature_folder` from the prompt text via regex scan (mirroring `enforce-prd-feature-before-planner.ps1`'s technique), reads `artifacts/orchestration/epic-orchestrator-state.json`, looks up that feature's `depends_on`, and denies with reason `EPIC_WAVE_BARRIER_BLOCKED` unless every dependency's `merge_status` is `merged` or `worktree_removed` (spec Hooks "Additional hook", §7 Layer 1)
  - Acceptance: script exists at `.claude/hooks/enforce-epic-wave-barrier.ps1`; invoking it with a synthetic `CLAUDE_TOOL_INPUT` for each documented case produces the correct `permissionDecision`/`permissionDecisionReason`.

- [x] [P2-T13] Create `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1` (new) — cover: allow (no-op) when the prompt lacks the epic-mode marker; allow when all dependencies are `merged`/`worktree_removed`; deny `EPIC_WAVE_BARRIER_BLOCKED` when a dependency is not yet merged; deny on an unreadable epic checkpoint (spec Affected Test Files)
  - Acceptance: `mcp__drm-copilot__run_poshqc_test` reports all four `It` cases passing with zero failures.

- [x] [P2-T14] Run PowerShell format on the batch-2 files (`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1`) via `mcp__drm-copilot__run_poshqc_format`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-batch2-format.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; if any file was reformatted, this task is re-run before proceeding to P2-T15.

- [x] [P2-T15] Run PowerShell analyze on the same batch-2 file set via `mcp__drm-copilot__run_poshqc_analyze`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-batch2-analyze.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (zero rule violations); restart from P2-T14 if any violation is found and fixed.

- [x] [P2-T16] Run PowerShell Pester tests with coverage on the same batch-2 file set via `mcp__drm-copilot__run_poshqc_test`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-batch2-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` with numeric line coverage >= 85% and branch coverage >= 75% for the batch-2 files.

- [x] [P2-T17] Edit `.claude/settings.json` — add `"Agent(epic-orchestrator)"` to `permissions.allow`; add a `SubagentStop` matcher block `"orchestrator"` running `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1` (default parameters); add a `SubagentStop` matcher block `"epic-orchestrator"` running `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state`; append `orchestrator` and `epic-orchestrator` to the catch-all `SubagentStop` matcher's `|`-delimited agent list; add `enforce-epic-merge-gate.ps1` and `enforce-epic-worktree-removal-gate.ps1` as new entries in the existing `"Bash"` `PreToolUse` matcher block; add `enforce-epic-wave-barrier.ps1` as a new entry in the existing `"Agent"` `PreToolUse` matcher block (spec Hooks items a, b, d, and Additional hook; spec §1)
  - Acceptance: `python -m json.tool .claude/settings.json` exits 0; `"Agent(epic-orchestrator)"` is present in `permissions.allow`; both new `SubagentStop` matcher blocks are present with the exact commands above; both new `Bash`-matcher hook entries and the new `Agent`-matcher hook entry are present.

- [x] [P2-T18] Verify internal consistency of `.claude/settings.json` — extract every `.claude/hooks/*.ps1` filename referenced anywhere in the file's `hooks` block and confirm each referenced file exists on disk under `.claude/hooks/`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/other/settings-hook-reference-consistency.<timestamp>.md`
  - Acceptance: artifact lists every referenced hook filename and confirms zero referenced-but-missing files.

### Phase 3 — Python: Epic Checkpoint Validator Module and Dispatch

- [x] [P3-T1] Create `scripts/dev_tools/validate_epic_orchestrator_state.py` (new) exposing `validate_epic_orchestrator_state_text(text, *, require_complete=False)` per spec §6: validates presence of the four baseline fields (`objective`, `completed_steps`, `next_step`, `last_updated`) plus `route_id == "epic"`, `epic_feature_folder`, `integration_branch`, `waves[]`, `features[]`; `features[].feature_folder` uniqueness and `depends_on` reference resolution (rejecting cycles and unresolved references); `merge_status` enum membership; the wave-barrier ordering invariant (appending `EPIC_WAVE_BARRIER_VIOLATION: <f> started before dependency <d> merged` on violation); consistency between `waves[].feature_folders` and each feature's own `wave_number`; and, under `require_complete=True`, every feature's `merge_status` in `{merged, worktree_removed}` and non-empty `epic_merge_pr.merge_commit_sha`
  - Acceptance: `python -c "from scripts.dev_tools.validate_epic_orchestrator_state import validate_epic_orchestrator_state_text"` exits 0; the file is <= 500 lines.

- [x] [P3-T2] Edit `scripts/dev_tools/validate_orchestration_artifacts.py` — add a new subparser for `"epic-orchestrator-state"` in `build_parser` (parallel to the existing `orchestrator-state` subparser, including its own `--require-complete` flag); add a new dispatch branch `if args.artifact_type == "epic-orchestrator-state": return validate_epic_orchestrator_state_text(text, require_complete=bool(args.require_complete))` in `_validate_from_args`, immediately after the existing `orchestrator-state` branch (spec §6 item 2)
  - Acceptance: `python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state --help` exits 0 and shows `--require-complete`.

- [x] [P3-T3] Create `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` (new) — cover: missing-baseline-field shape violations; missing `route_id`/`epic_feature_folder`/`integration_branch`/`waves`/`features`; `feature_folder` duplication; unresolved `depends_on` reference; dependency cycle rejection; `merge_status` enum membership (valid and invalid values); wave-barrier ordering pass and violation (asserting the `EPIC_WAVE_BARRIER_VIOLATION` string); `waves[].feature_folders`-vs-`wave_number` consistency; `require_complete=True` gating (spec Affected Test Files)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py -v` passes with zero failures.

- [x] [P3-T4] Edit `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` — add tests confirming the `epic-orchestrator-state` dispatch branch routes to `validate_epic_orchestrator_state_text` and that the CLI subparser accepts `--require-complete` (spec Affected Test Files)
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py -v` passes with zero failures.

- [x] [P3-T5] Run `poetry run black --check scripts/dev_tools/validate_epic_orchestrator_state.py scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/python-format.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`; restart from this task if any file is reformatted.

- [x] [P3-T6] Run `poetry run ruff check` on the same 4 files; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/python-lint.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (zero violations).

- [x] [P3-T7] Run `poetry run pyright` on the same 4 files; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/python-typecheck.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (zero errors).

- [x] [P3-T8] Run `poetry run pytest --cov=scripts.dev_tools.validate_epic_orchestrator_state --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/python-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` with numeric line coverage >= 85% and branch coverage >= 75%.

### Phase 4 — TypeScript: MCP Artifact-Type Enum and Dispatch

- [x] [P4-T1] Create `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` (new) exposing `validateEpicOrchestratorStateText(text, options)`, mirroring `scripts/dev_tools/validate_epic_orchestrator_state.py`'s invariants (required fields, `route_id == "epic"`, `features[]` uniqueness/`depends_on` resolution, `merge_status` enum membership, wave-barrier ordering `EPIC_WAVE_BARRIER_VIOLATION` check, `waves[]`-vs-`wave_number` consistency, `requireComplete` gate), following the existing `orchestrator-state-core.ts` TS-port pattern
  - Acceptance: the module exports `validateEpicOrchestratorStateText`; `npx tsc --noEmit` on the file (as part of the project build) reports zero errors for it.

- [x] [P4-T2] Edit `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` — import `validateEpicOrchestratorStateText` from `./epic-orchestrator-state-core`; add a `case "epic-orchestrator-state":` branch in `validateArtifact`'s `switch`, alongside the existing `"orchestrator-state"` case, dispatching to it with `requireComplete` threaded through from `ValidateArtifactInput` (spec §6 item 2)
  - Acceptance: `grep 'case "epic-orchestrator-state"'` against the file returns >= 1; the `default` unsupported-type fallback is unchanged.

- [x] [P4-T3] Edit `extensions/drm-copilot/src/mcp-tool-definitions.ts` — add `"epic-orchestrator-state"` to the `artifact_type` `enum` array (lines 388–394); update the tool `description` string (line 381) and the `require_complete` property `description` (line 405) to mention `epic-orchestrator-state` (spec §6 item 1)
  - Acceptance: `grep '"epic-orchestrator-state"'` against the file returns >= 1 inside the `enum` array; both description strings mention `epic-orchestrator-state`.

- [x] [P4-T4] Create `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` (new) — cover the same scenarios as the Python Pytest suite from P3-T3 (shape validation, `depends_on` reference/cycle rejection, `merge_status` enum, wave-barrier ordering pass/violation, `requireComplete` gating)
  - Acceptance: `npx vitest run extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` passes with zero failures.

- [x] [P4-T5] Edit `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` — add tests confirming the `epic-orchestrator-state` dispatch branch routes to `validateEpicOrchestratorStateText` (spec Affected Test Files)
  - Acceptance: `npx vitest run extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` passes with zero failures.

- [x] [P4-T6] Edit `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` — add an enum-membership test asserting `"epic-orchestrator-state"` is present in the `validate_orchestration_artifacts` tool's `artifact_type` enum (spec Affected Test Files)
  - Acceptance: `npx vitest run extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` passes with zero failures.

- [x] [P4-T7] Verify cross-language artifact-type string consistency: grep-confirm the literal string `epic-orchestrator-state` appears identically in `scripts/dev_tools/validate_orchestration_artifacts.py`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, and `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/other/epic-artifact-type-consistency.<timestamp>.md`
  - Acceptance: artifact lists all three grep hits and confirms the literal string matches byte-for-byte across all three files.

- [x] [P4-T8] Run `npm run format` (Prettier) in `extensions/drm-copilot` scoped to the 6 files touched in P4-T1–P4-T6; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/typescript-format.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`; restart from this task if any file is reformatted.

- [x] [P4-T9] Run `npm run lint` (ESLint) on the same 6 files; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/typescript-lint.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (zero violations).

- [x] [P4-T10] Run `npm run typecheck` (TSC) in `extensions/drm-copilot`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/typescript-typecheck.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (zero errors).

- [x] [P4-T11] Run `npm run test:coverage` (Vitest, coverage mode) in `extensions/drm-copilot`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/typescript-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` with numeric line coverage >= 85% and branch coverage >= 75%.

### Phase 5 — Bundled Mirror Parity

- [x] [P5-T1] Copy the following 10 files from the repository root into `extensions/drm-copilot/resources/claude-customizations/` at identical relative paths, byte-for-byte: `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/settings.json` (spec Bundled Mirror Parity)
  - Acceptance: for each of the 10 files, `Compare-Object (Get-Content <repo-path> -Raw) (Get-Content extensions/drm-copilot/resources/claude-customizations/<repo-path> -Raw)` (or `cmp`) reports zero differences.

- [x] [P5-T2] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v` to confirm the dynamic full-`.claude/`-tree parity test reports zero failures after P5-T1 (spec Bundled Mirror Parity, AC13); write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/bundled-mirror-parity.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (pass count, zero failures).

- [x] [P5-T3] Manually mirror the same 10 files listed in P5-T1, byte-for-byte, into `packages/mcp-server/resources/claude-customizations/` at identical relative paths, and verify each with `cmp` (or `Compare-Object`) reporting zero differences; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/other/mcp-server-mirror-cmp-verification.<timestamp>.md` (spec Bundled Mirror Parity: this mirror is gitignored, has no automated gate, and is a manual pre-publish verification step)
  - Acceptance: artifact lists a per-file `cmp` result for all 10 files, each reporting zero differences.

### Phase 6 — Definition of Done Mapping and Final Cross-Language QA Loop

- [x] [P6-T1] Create `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/other/ac-mapping.<timestamp>.md` mapping each of AC1–AC14 in `spec.md`'s Definition of Done to the specific plan task ID(s)/test file(s) that satisfy it
  - Acceptance: artifact contains exactly 14 rows (one per AC1–AC14), each citing at least one `P#-T#` task ID and/or test-file path from this plan; no row is blank.

- [x] [P6-T2] Re-run the full PowerShell toolchain (format → analyze → test-with-coverage, via `mcp__drm-copilot__run_poshqc_format`/`run_poshqc_analyze`/`run_poshqc_test`) in a single combined pass across every changed/new `.claude/hooks/*.ps1` and `tests/scripts/claude-hooks/*.Tests.ps1` file from Phase 2; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-powershell.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` with numeric line/branch coverage; restart from format if any step fails or changes files.

- [x] [P6-T3] Re-run the full Python toolchain (`black` → `ruff` → `pyright` → `pytest --cov`) in a single combined pass across every changed/new file from Phase 3; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-python.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` with numeric line/branch coverage; restart from format if any step fails or changes files.

- [x] [P6-T4] Re-run the full TypeScript toolchain (`npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:coverage`) in a single combined pass across every changed/new file from Phase 4; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-typescript.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` with numeric line/branch coverage; restart from format if any step fails or changes files.

- [x] [P6-T5] Compare baseline vs. final coverage for PowerShell, Python, and TypeScript (P0-T4/P0-T8/P0-T12 vs. P6-T2/P6-T3/P6-T4) and confirm no line/branch coverage regression on changed lines for any of the three languages; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/coverage-delta-verification.<timestamp>.md`
  - Acceptance: artifact records baseline coverage, post-change coverage, and the delta for each of the three languages, and states explicitly that no regression was found (or, if a regression is found, the outcome is remediation-required and is not reported as PASS).

- [x] [P6-T6] Re-run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v` one final time after all phases (including the Phase 5 mirror copies and the Phase 2 `.claude/settings.json` edit) to confirm the bundled-mirror-parity gate still reports zero failures; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-bundled-mirror-parity.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (pass count, zero failures).

- [x] [P6-T7] Cross-reference the evidence from P6-T1 through P6-T6 against `spec.md`'s Definition of Done checklist (AC1–AC14 plus the six generic closing items) and update each satisfied checkbox in `spec.md` to the checked state
  - Acceptance: every Definition of Done checkbox in `spec.md` is checked; no item remains unchecked without an explicit, recorded reason.

## Test Plan

- **Unit (PowerShell):** `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`, `enforce-pr-author-skill.Tests.ps1`, `enforce-epic-merge-gate.Tests.ps1` (new), `enforce-epic-worktree-removal-gate.Tests.ps1` (new), `enforce-epic-wave-barrier.Tests.ps1` (new).
- **Unit (Python):** `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` (new), `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` (dispatch additions).
- **Unit (TypeScript):** `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` (new), `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` (dispatch additions), `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` (enum membership).
- **Integration/Contract:** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (dynamic `.claude/`-tree bundled-mirror parity — no code change required, but re-run after every phase that touches `.claude/`).
- **Manual/CLI:** `packages/mcp-server/resources/claude-customizations/` mirror verified per-file with `cmp` (Phase 5, no automated gate).
- **Coverage evidence:**
  - PowerShell: baseline `evidence/baseline/powershell-test-baseline.<timestamp>.md`; post-change `evidence/qa-gates/powershell-batch1-test.<timestamp>.md`, `evidence/qa-gates/powershell-batch2-test.<timestamp>.md`, `evidence/qa-gates/final-powershell.<timestamp>.md`; comparison `evidence/qa-gates/coverage-delta-verification.<timestamp>.md`.
  - Python: baseline `evidence/baseline/python-test-baseline.<timestamp>.md`; post-change `evidence/qa-gates/python-test.<timestamp>.md`, `evidence/qa-gates/final-python.<timestamp>.md`; comparison `evidence/qa-gates/coverage-delta-verification.<timestamp>.md`.
  - TypeScript: baseline `evidence/baseline/typescript-test-baseline.<timestamp>.md`; post-change `evidence/qa-gates/typescript-test.<timestamp>.md`, `evidence/qa-gates/final-typescript.<timestamp>.md`; comparison `evidence/qa-gates/coverage-delta-verification.<timestamp>.md`.

## Open Questions / Notes

- Design decisions (manifest format, wave algorithm, hook names, checkpoint schema, merge-conflict handling) are committed in `spec.md` and are not re-litigated by this plan; this plan only decomposes, sequences, and batches the implementation.
- `epic-status.md` generation/update logic is documented as an agent-followed procedure in `.claude/skills/epic-orchestrate/SKILL.md` (P1-T2); it is not a separate source file requiring its own toolchain-gated implementation task, consistent with the spec's Documentation Maintenance section.
- `packages/mcp-server/resources/claude-customizations/` (P5-T3) has no automated test coverage per spec; its verification is manual `cmp`-based and must be repeated before any npm publish that includes this change, per `spec.md`'s Bundled Mirror Parity section.
