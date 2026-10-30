# 2026-10-30-retire-github-skills-and-thin-copilot-layer - Plan

- **Issue:** #1032
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`), child 6
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-39
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Requirements:** `spec.md` (AC1 to AC19) and `user-story.md` (US-AC1 to US-AC10) in this folder; research `research/research.2026-10-30T23-02.md`; child 1 spec `origin/feature/harness-survey-gold-standard-contracts-parity-matrix-1025:docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md`.

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Language policies in scope: Python, PowerShell, TypeScript (`.claude/rules/python.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`).
- Tool routes, launchers, command-text restrictions, batch budget, CI shape and contract tests: `.claude/skills/execution-environment/SKILL.md` (not restated here).

**All work must comply with these policies; do not duplicate their content here.**

## Execution Order (orchestrator)

1. Delegate this main plan. It carries the shared work: the Phase 0 gate, the `.github/skills` retirement, the brief and plan-contract fact update, the Copilot agent read-first repoints, the thin `.github/copilot-instructions.md`, documentation, collision controls, the skill parity-matrix entries, and the final QA loop with self-review.
2. After this plan completes with every task checked, read the lexicographically greatest `<FEATURE>/evidence/other/agents-branch-selection.*.md` (written by P0-T8) and delegate exactly one branch plan: `plan-agents-branch-a.md` when it records `SelectedBranch: A`, otherwise `plan-agents-branch-b.md`. Neither branch plan is delegated when this plan stops at its Phase 0 gate.
3. Ordering decision: this plan runs its final QA and self-review before the branch plan. The branch plans change only `config/harness-parity-matrix.json` and evidence, and each branch plan runs its own gates and self-review over the final tree, so the alternative ordering gains nothing.

A Phase 0 gate task that finds a mismatch writes `blocked: premise_falsified` and the mismatched item into its artifact, stays unchecked, and stops the run for re-planning. One plan revision is accepted (epic owner decision E3).

## Terms

- `<FEATURE>`: `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032`.
- `MB`: the merge base of `origin/main` and `HEAD`, derived after a fetch at each use; no commit identifier is recorded in this plan.
- `C1`: child 1's feature folder, the single directory matching `docs/features/*/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025` in the tree at `MB`. Matrix decision references use the issue-keyed form `#1025:<path inside C1>`.
- `SCRATCH`: `<session scratchpad>/issue-1032/`; scratch file names start with `issue-1032-`. Artifacts record the token `SCRATCH`, never a host path.
- `CHANGED-PY`: `tests/scripts/dev_tools/` modules `test_execution_environment_brief_contracts.py`, `test_discovery_documentation_contracts.py`, `test_legacy_discovery_skills_contracts.py`, `test_discovery_publication_contracts.py`, `test_discovery_workflow_contracts.py`, `test_completion_gate_documentation_contracts.py`, `test_evidence_timestamp_contracts.py`, `test_minor_audit_acceptance_criteria_contracts.py`, `test_single_pass_preflight_contracts.py`, `test_csharp_orchestration_contracts.py`, `test_push_down_issue_824_follow_ups.py`, `test_plan_gate_document_docs.py`, `test_agentic_sync.py`, `test_agentic_sync_artifacts.py`, `test_push_down_copilot_customizations.py`, `test_push_down_copilot_customizations_rewrites.py`.
- `RUN-ONLY-PY`: `tests/scripts/dev_tools/` modules `test_orchestrator_direct_command_contracts.py`, `test_push_down_copilot_customizations_helpers.py`, `test_codex_full_migration_inventory.py`, `test_vscode_workspace_settings.py`, `test_agentic_sync_branches.py`, `test_agentic_sync_filesystem.py` (asserting behavior this plan must not change; unchanged).
- `TOUCHED-PESTER`: `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` (edited) and every suite under `tests/scripts/harness/` (matrix data edited); run-only: `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1`, `tests/scripts/dev-tools/agents-attribution.Tests.ps1`.

## Upstream Assumptions

Each row is checked by the named Phase 0 task against the tree at `MB`. A row marked Stop halts the run for re-planning when it does not hold.

| ID | Upstream | Assumption | Task | On mismatch |
| --- | --- | --- | --- | --- |
| UA-P1 | Parallel run `bugs-1001-1002-1003-1006` | Issues #1001, #1002, #1003 and #1006 are closed by pull requests merged into `main`. | P0-T2 | Stop |
| UA-C1a | Child 1 (#1025) | `config/harness-parity-matrix.json` and `config/harness-parity-matrix.schema.json` exist; the schema `$id` is `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json`; entry fields follow child 1 spec `### Parity Matrix: Feature Entry`; `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` exists and passes. | P0-T4 | Stop |
| UA-C1b | Child 1 | The matrix has one `copilot:skill:*` entry per `.github/skills` skill folder, each `dropped` with `reason` and `decision_ref`; `copilot:skill-frontmatter-field:*` entries exist; one `copilot:agent:*` entry per `.github/agents/*.agent.md` file; one `copilot:handoff:*` entry per handoff-bearing agent file. | P0-T4 | Stop |
| UA-C1c | Child 1 | `C1/evidence/other/` holds an E3 result (`e3-copilot-cli-cloud-claude-agents-result.*.md`) and an E4 result (`e4-copilot-workspace-settings-result.*.md`), or `C1/survey/difference-approval.md` `## Owner Overrides` records the deferral; each result carries `EXIT_CODE:` and `Output Summary:`; the E3 runbook `C1/runbooks/e3-copilot-cli-cloud-claude-agents.runbook.md` defines exit 0 as both the Copilot CLI and the Copilot cloud agent loading an agent defined only in `.claude/agents`, and the E4 runbook defines exit 0 as the location settings taking effect at workspace scope. | P0-T4 | Stop |
| UA-C1d | Child 1 | `C1/survey/difference-approval.md` has `Approval-Status` `approved` or `approved-with-overrides`; every Diff ID recorded for `feature-promotion-lifecycle` and `feature-review-workflow` whose approved class is `positive` with a port into the shared skill is already present in `.agents/skills/<name>/SKILL.md` (child 1 Q4 assigns porting to child 3). | P0-T4 | Stop |
| UA-C3a | Child 3 | `.agents/skills` is the shared skill source, mirrored into `.claude/skills` by a child 3 generator with a `--check` mode; the mirror of `execution-environment` and `atomic-plan-contract` is byte-identical. | P0-T5 | Stop |
| UA-C3b | Child 3 (OQ4) | The sixteen legacy-discovery skills are generated from `.agents/skills/<name>/SKILL.md` with child 3's per-tool role-link rewrite; no child 3 generator input names `.github/skills`. | P0-T5 | Stop |
| UA-C3c | Child 3 | `AGENTS.md` carries the tone policy (`## Source: tonality.md`); `scripts/dev-tools/sync-agents-from-instructions.ps1` is removed or no longer reads `.github/copilot-instructions.md`. | P0-T5 | Stop |
| UA-C3d | Child 3 | Child 3's agent generator emits no `.github/agents` target (Branch B native case). | P0-T5 | Recorded for the branch plans |
| UA-C4a | Child 4 | `COPILOT_ROOT_FOLDERS` in `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` and `ROOT_FOLDERS` in `scripts/dev_tools/agentic_sync.py` exist and each lists `.github/skills`. | P0-T6 | Stop |
| UA-C4b | Child 4 | No pack manifest under `extensions/drm-copilot/resources/*/pack-manifests/` lists a `.github/` path, the Copilot bundle has no `pack-manifests` folder, and `extensions/drm-copilot/resources/customizations/.github/**` remains a hand-maintained byte mirror. | P0-T6 | Stop |
| UA-C4c | Child 4 | Child 4 owns destination cleanup of previously pushed `.github/skills` (risk R3). | P0-T6 | Recorded only |
| UA-C5a | Child 5 | `.github/hooks` file set at `MB` is recorded; any difference from the planning tree is a child 5 change recorded in child 5's evidence. | P0-T6 | Recorded only |
| UA-C5b | Child 5 | `Get-DiscoveryAgentProfilePath` in `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1` still resolves `.github/agents/<role>.agent.md` for the `github-copilot` layout. | P0-T6 | Stop |

## Derivation Rules

- **Agents branch (AC4).** `SelectedBranch: A` when the lexicographically greatest `C1/evidence/other/e3-copilot-cli-cloud-claude-agents-result.*.md` exists and records `EXIT_CODE: 0`; otherwise `SelectedBranch: B` (absent, deferred, or non-zero).
- **Collision-control scope (AC9).** `WorkspaceScope: yes` when the lexicographically greatest `C1/evidence/other/e4-copilot-workspace-settings-result.*.md` exists and records `EXIT_CODE: 0`; otherwise `WorkspaceScope: no`.

## Edit Set

P0-T3 re-reads every file below at `MB` and confirms each named anchor is present. Deleted trees: `.github/skills/**` and `extensions/drm-copilot/resources/customizations/.github/skills/**`.

| File | Anchors re-checked |
| --- | --- |
| `.agents/skills/execution-environment/SKILL.md`, `.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | `## Purpose and Maintenance` six-location sentence; `## Preflight Defect Classes the Validator Cannot See` token `in all six byte-identical copies`; byte identity of the four copies |
| `.agents/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/atomic-plan-contract/SKILL.md` and their two bundle copies | `## Design-Level Plan Contract (Mandatory)` Pre-Mortem bullet token `in all six byte-identical copies` |
| `.github/agents/atomic_executor.agent.md`, `atomic_planning.agent.md`, `orchestrator.agent.md`, `task-researcher.agent.md` and their copies under `extensions/drm-copilot/resources/customizations/.github/agents/` | read-first line naming `.github/skills/execution-environment/SKILL.md` |
| `.github/copilot-instructions.md` and its bundle copy | `# Tone policy` body |
| `docs/engineering/claude-code-architecture.md` | `### Canonical .github/skills migration map`; `### Authoritative source by asset category`; `### Manual sync procedure`; `## 1. Copilot-to-Claude Equivalence Table` |
| `.agents/README.md` and its bundle copy; `README.md` (`## Policy and skills references`); `CLAUDE.md` (`## Tone Policy`, `## Policy Compliance Reading Order`) | sentences naming `.github/skills` or `.github/copilot-instructions.md` |
| `docs/engineering/legacy-discovery-and-parity/maintainer-guide.md`, `workflow.md`, `consumer-onboarding.md` | sentences naming `.github/skills` |
| `.vscode/settings_required.json`; `config/harness-parity-matrix.json` | PowerShell 7 pin keys; `copilot:skill*` entries |
| `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` and `extensions/drm-copilot/test/lib/push-down/copilot-customizations-engine.test.ts` | `COPILOT_ROOT_FOLDERS`; tests `classifies created vs overwritten and enumerates in root then path order`, `accumulates rewrite counters and first-seen unmatched references`, `exposes the inlined copilot root-folder enumeration order` |
| `scripts/dev_tools/agentic_sync.py` | `ROOT_FOLDERS`; module docstring |
| Every `CHANGED-PY` module and `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | each symbol and test named by the task that edits it |

## Language Classification

| Planned artifact | Change | Classification |
| --- | --- | --- |
| `.github/skills/**` and its bundle mirror | Delete | Markdown; no code |
| Brief, plan contract, Copilot agents, `.github/copilot-instructions.md`, READMEs, `CLAUDE.md`, engineering documents, and their bundle copies | Edit | Markdown; no code |
| `.vscode/settings_required.json`, `config/harness-parity-matrix.json` | Edit | JSON data |
| `scripts/dev_tools/agentic_sync.py` | Edit in place | Existing Python, tolerated (not pushed down) |
| `CHANGED-PY` modules | Edit in place | Existing Python tests, tolerated |
| `claude-architecture-doc.Tests.ps1` | Edit in place | PowerShell |
| `copilot-customizations-engine.ts` and its Jest test | Edit in place | TypeScript in extension push-down code behind an MCP tool and extension command; permitted |
| Scratch helpers for evidence | Not committed | PowerShell under `SCRATCH` |

No artifact adds Python, and no pushed-down artifact is TypeScript or Python. No case needs an owner language decision.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Gate and Baseline

- [ ] [P0-T1] Read the policy files in `policy-compliance-order` order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/plan-acceptance-gates.md`, and `.claude/skills/execution-environment/SKILL.md`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` carries `Timestamp:`, `Policy Order:` and the ten files.
- [ ] [P0-T2] Confirm UA-P1 with `gh`: each of issues #1001, #1002, #1003 and #1006 is closed and its closing pull request is merged with base `main`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-parallel-run.<timestamp>.md` lists each issue, its pull request number and merge state; on any open issue or unmerged pull request it records `blocked: premise_falsified` and the task stays unchecked.
- [ ] [P0-T3] Re-read every file in `## Edit Set` at `MB` and confirm each named anchor is present and that `.github/skills` and its bundle mirror each still hold one `SKILL.md` per skill folder plus `README.md`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-edit-set.<timestamp>.md` has one row per file with `present` or `moved`; any `moved` row records `blocked: premise_falsified` and the task stays unchecked.
- [ ] [P0-T4] Check UA-C1a to UA-C1d against `C1` and the matrix at `MB`; run `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` and read pass and fail counts from `artifacts/pester/pester-junit.xml`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-upstream-child1.<timestamp>.md` records `C1`, each assumption as `holds` or `differs`, the entry counts per `copilot:` kind, the E3 and E4 result paths or deferral text, the U1 to U3 Diff IDs with approved classes, and the gate counts (zero failed); any `differs` records `blocked: premise_falsified`.
- [ ] [P0-T5] Check UA-C3a to UA-C3d: name the child 3 skill-mirror generator and its `--check` invocation, run that check (exit 0), search each child 3 generator input for the token `.github/skills` (zero matches), confirm the tone sections of `AGENTS.md`, and record the state of `scripts/dev-tools/sync-agents-from-instructions.ps1` and whether the agent generator has a `.github/agents` target.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-upstream-child3.<timestamp>.md` records the generator name and check command, each assumption as `holds` or `differs`, and `GithubAgentsTarget: yes|no`; a `differs` on UA-C3a, UA-C3b or UA-C3c records `blocked: premise_falsified`.
- [ ] [P0-T6] Check UA-C4a to UA-C5b: read both root-folder constants, list every pack-manifest file and search them for the token `.github/`, list `.github/hooks` files, and read `Get-DiscoveryAgentProfilePath` and `$script:AgentProfileLayout`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-upstream-children4-5.<timestamp>.md` records each assumption as `holds`, `differs` or `recorded`; a `differs` on UA-C4a, UA-C4b or UA-C5b records `blocked: premise_falsified`.
- [ ] [P0-T7] Record the `.github/prompts` and `.github/hooks` file inventories at `MB` with one `git hash-object` value per file.
  - Acceptance: `<FEATURE>/evidence/baseline/github-native-inventory.<timestamp>.md` lists every file under both folders with its hash and a total count per folder.
- [ ] [P0-T8] Apply `## Derivation Rules` to the E3 and E4 results recorded by P0-T4.
  - Acceptance: `<FEATURE>/evidence/other/agents-branch-selection.<timestamp>.md` carries `Timestamp:`, the E3 result path (or deferral reference), its `EXIT_CODE`, `SelectedBranch: A` or `SelectedBranch: B`, the E4 result path (or deferral reference), its `EXIT_CODE`, and `WorkspaceScope: yes` or `WorkspaceScope: no`.
- [ ] [P0-T9] Run `CHANGED-PY` and `RUN-ONLY-PY` in one pytest process at `MB` state, with `--cov=scripts.dev_tools.agentic_sync --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1032-agentic-sync-baseline.json`.
  - Acceptance: `<FEATURE>/evidence/baseline/pytest-baseline.<timestamp>.md` carries `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` with the pass count and the line and branch percentages of `scripts/dev_tools/agentic_sync.py` read from the JSON report.
- [ ] [P0-T10] Run the extension Jest suite file `test/lib/push-down/copilot-customizations-engine.test.ts` with coverage per the brief's TypeScript route.
  - Acceptance: `<FEATURE>/evidence/baseline/jest-baseline.<timestamp>.md` records `EXIT_CODE: 0`, the pass count, and the line and branch percentages of `src/lib/push-down/copilot-customizations-engine.ts` read from `extensions/drm-copilot/coverage/lcov.info`.
- [ ] [P0-T11] Run `TOUCHED-PESTER` through `Invoke-PoshQCTest` from the self-hosted PoshQC module and read the JUnit file.
  - Acceptance: `<FEATURE>/evidence/baseline/pester-baseline.<timestamp>.md` records the pass and fail counts per suite from `artifacts/pester/pester-junit.xml` (zero failed).
- [ ] [P0-T12] Run a fixed-string search for the token `.github/skills` over the working tree, excluding `.git`, `node_modules` and `docs/features/`, and record every matching file.
  - Acceptance: `<FEATURE>/evidence/baseline/stale-reference-baseline.<timestamp>.md` lists each matching file and its match count.

### Phase 1 — Unique-Content Record and Retirement

- [ ] [P1-T1] Record the dispositions of U1 (`.github/skills/feature-promotion-lifecycle/SKILL.md`, `## MCP-First Execution Rule`), U2 (same file, `## Canonical Fallback Command Sequence` and the VS Code command forms in `## Canonical Fallback Short-Path Sequence (Minor Audit Mode)`) and U3 (`.github/skills/feature-review-workflow/SKILL.md`, `## File Size Advisory`).
  - Acceptance: `<FEATURE>/evidence/other/unique-section-dispositions.<timestamp>.md` records U1 and U2 as `stale` citing `docs/features/completed/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`, U3 with the class approved for its Diff ID, each with `#1025:survey/difference-approval.md` and the Diff ID; for any port UA-C1d found, the ported text is quoted with its location in `.agents/skills/<name>/SKILL.md`.
- [ ] [P1-T2] Delete every file under `.github/skills/` and under `extensions/drm-copilot/resources/customizations/.github/skills/` in one change.
  - Acceptance: Glob `.github/skills/**` and Glob `extensions/drm-copilot/resources/customizations/.github/skills/**` each return no files; `git status --porcelain` lists only deletions under those two trees for this task.
- [ ] [P1-T3] Remove `.github/skills` from `COPILOT_ROOT_FOLDERS` in `copilot-customizations-engine.ts` and update its asserting Jest tests in `copilot-customizations-engine.test.ts`: `exposes the inlined copilot root-folder enumeration order` (four roots), `classifies created vs overwritten and enumerates in root then path order` (seed file moved to `.github/instructions/i.instructions.md`, expected order and counts adjusted), `accumulates rewrite counters and first-seen unmatched references` (seed moved to `.github/instructions/`); `enumerateSourceFiles` tests unchanged (unaffected).
  - Acceptance: the engine test file passes; a search of `copilot-customizations-engine.ts` for the token `.github/skills` returns zero matches.
- [ ] [P1-T4] Remove `Path(".github/skills")` from `ROOT_FOLDERS` in `scripts/dev_tools/agentic_sync.py` and from its module docstring, and update the asserting tests: `test_root_folders_include_published_github_hooks_in_scoped_order` (four roots), `test_force_left_to_right_overrides_newer_right` in `test_agentic_sync.py` (root `.github/instructions`), `_seed_scoped_source_files` and `test_push_down_copies_scoped_github_trees_to_empty_destination` in `test_push_down_copilot_customizations.py` (skill seed and assertion removed, `created_count` 4), and `test_push_down_reports_unmatched_script_references_without_rewrite` in `test_push_down_copilot_customizations_rewrites.py` (fixture under `.github/instructions/`); `test_agentic_sync_branches.py` and `test_agentic_sync_filesystem.py` unchanged (unaffected).
  - Acceptance: `test_agentic_sync.py`, `test_agentic_sync_artifacts.py`, `test_agentic_sync_branches.py`, `test_agentic_sync_filesystem.py`, `test_push_down_copilot_customizations.py` and `test_push_down_copilot_customizations_rewrites.py` pass; `agentic_sync.py` contains zero matches for `.github/skills`.

### Phase 2 — Brief, Plan Contract and Copilot Agent References

- [ ] [P2-T1] Update the execution-environment brief in its canonical copy `.agents/skills/execution-environment/SKILL.md`: the `## Purpose and Maintenance` sentence becomes the four-location fact naming `.agents/skills/execution-environment/SKILL.md` (canonical), `.claude/skills/execution-environment/SKILL.md` and their bundled copies under `extensions/drm-copilot/resources/`, and the `## Preflight Defect Classes the Validator Cannot See` brief-maintenance bullet reads `in all four byte-identical copies`; regenerate `.claude/skills/execution-environment/SKILL.md` with the child 3 generator recorded by P0-T5 and copy the bytes to both bundle copies.
  - Acceptance: the four copies have one `git hash-object` value; each contains `byte-identical in four locations` and `in all four byte-identical copies` and zero matches for `.github/skills`; the child 3 generator `--check` exits 0.
- [ ] [P2-T2] Change `in all six byte-identical copies` to `in all four byte-identical copies` in `## Design-Level Plan Contract (Mandatory)` of `.agents/skills/atomic-plan-contract/SKILL.md`; regenerate `.claude/skills/atomic-plan-contract/SKILL.md` with the child 3 generator and copy each source to its bundle copy.
  - Acceptance: each of the four copies contains `in all four byte-identical copies` and not `in all six byte-identical copies`; `.agents` and `.claude` copies equal their bundle copies byte for byte; the child 3 generator `--check` exits 0.
- [ ] [P2-T3] Repoint the read-first line in `.github/agents/atomic_executor.agent.md`, `atomic_planning.agent.md`, `orchestrator.agent.md` and `task-researcher.agent.md` to `.agents/skills/execution-environment/SKILL.md`, and copy each file to its bundle copy under `extensions/drm-copilot/resources/customizations/.github/agents/`.
  - Acceptance: each of the four agents contains ``Read `.agents/skills/execution-environment/SKILL.md` first``; a fixed-string search for `.github/skills` over `.github/agents/` and the bundle `.github/agents/` returns zero matches; each bundle copy is byte-identical to its source.
- [ ] [P2-T4] Update `docs/engineering/claude-code-architecture.md`: rename `### Canonical .github/skills migration map` to ``### Retired `.github/skills` migration map`` with a statement that issue #1032 retired `.github/skills` and the first column naming `.agents/skills/<name>/SKILL.md` (the README row names `.agents/skills/README.md` as documentation-only); retarget the `.github/skills` rows of `## 1. Copilot-to-Claude Equivalence Table` and `### Authoritative source by asset category`, the `.github/`-is-authoritative statement in `## 3. Sync Strategy` (authoritative for Copilot-native agents, prompts and hooks only), and `### Manual sync procedure`. Update `claude-architecture-doc.Tests.ps1`: the first `It` asserts the new heading, and the second `It` asserts `retired by issue #1032`, `.agents/skills/README.md`, `documentation-only`, and no `.claude/skills/README.md`.
  - Acceptance: `claude-architecture-doc.Tests.ps1` passes (counts read from `artifacts/pester/pester-junit.xml`); the document contains ``| `.agents/skills/execution-environment/SKILL.md` | `.claude/skills/execution-environment/SKILL.md` |``.
- [ ] [P2-T5] Update `test_execution_environment_brief_contracts.py`: drop the two `.github` paths from `_BRIEF_COPIES`, state four locations in the module docstring, change the instruction in `test_brief_is_referenced_by_copilot_base_agents` to ``Read `.agents/skills/execution-environment/SKILL.md` first``, change the token in `test_brief_preflight_classes_include_brief_maintenance` to `in all four byte-identical copies`, and change the row in `test_architecture_doc_lists_brief` to the `.agents` row. Update `test_execution_environment_fact_is_unchanged_across_copies` in `test_discovery_documentation_contracts.py`: canonical `.agents/skills/execution-environment/SKILL.md`, count 4.
  - Acceptance: both modules pass; neither contains the token `.github/skills`.
- [ ] [P2-T6] Update `test_single_pass_preflight_contracts.py`: remove the `.github/skills` entries from `_CONTRACTS`, `_REMEDIATION_SURFACES`, `_COPILOT_BASE_EDITED` and `_ROUTER_AND_PROMPT_SURFACES`, change the token in `test_contract_premortem_mirror_parity_requires_brief_update_task` to `in all four byte-identical copies`, and state four copies in its docstring; agent and prompt entries unchanged.
  - Acceptance: the module passes and contains zero matches for `.github/skills`.

### Phase 3 — Tests That Pinned Retired Skill Copies

- [ ] [P3-T1] Remove the `github` entries from `AC_TRACKING_SKILLS` and `EVIDENCE_SKILLS`, the `github-ac-tracking` and `github-evidence` mirror pairs, and the then-unused `_GITHUB_BUNDLE` from `test_completion_gate_documentation_contracts.py`.
  - Acceptance: the module passes and contains zero matches for `.github/skills`.
- [ ] [P3-T2] Remove the `github` entries from `EVIDENCE_SKILLS` and `PLAN_CONTRACT_SKILLS`, the `github` mirror pair, and the then-unused `_GITHUB_BUNDLE` from `test_evidence_timestamp_contracts.py`.
  - Acceptance: the module passes and contains zero matches for `.github/skills`.
- [ ] [P3-T3] Retarget the three skill entries of `ROOT_MIRROR_PAIRS` and `required_paths` in `test_minor_audit_acceptance_criteria_contracts.py` to `.agents/skills/<name>/SKILL.md` paired with `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/SKILL.md`; prompt entries unchanged.
  - Acceptance: the module passes (the token ``explicit `## Acceptance Criteria` section`` is present in the three `.agents` copies); zero matches for `.github/skills`.
- [ ] [P3-T4] Retarget `_assert_state_machine_contract` and `test_csharp_change_budget_router_requires_orchestrated_small_path_wording` in `test_csharp_orchestration_contracts.py` to `.agents/skills/csharp-orchestration-state-machine/SKILL.md` and `.agents/skills/csharp-change-budget-router/SKILL.md`; in `_assert_bundle_mirror_contract` remove the three Copilot-bundle skill assertions and assert the two `.agents` skills equal their `codex-and-agents-customizations` bundle copies; agent and prompt assertions unchanged.
  - Acceptance: the module passes and contains zero matches for `.github/skills`.
- [ ] [P3-T5] Remove the `.github/skills/feature-review-workflow/SKILL.md` entries and their bundle entries from `STEP_EIGHT_COPIES` and `FEATURE_REVIEW_TEXT_COPIES` in `test_push_down_issue_824_follow_ups.py`; `SOLUTION_SCAN_ROOTS` unchanged.
  - Acceptance: the module passes and contains zero matches for `.github/skills`.
- [ ] [P3-T6] Remove the two `.github` atomic-plan-contract paths from `_ALL_CONTRACT_COPIES` in `test_plan_gate_document_docs.py` and drop the Copilot copies from the module docstring.
  - Acceptance: the module passes; fixed-string searches of it for `"customizations"` and for `".github"` (quotes included) each return zero matches.
- [ ] [P3-T7] In `test_discovery_publication_contracts.py`, remove `.github/skills` from `COPILOT_ROOTS`, make `test_skill_is_represented_on_every_host` read the canonical source `.agents/skills/<skill>/SKILL.md` and drop its Copilot-bundle skill mirror assertion, and update the module docstring; role tests unchanged.
  - Acceptance: the module passes, including every `test_copilot_bundle_mirrors_every_scoped_github_file` parameter (four collected); fixed-string searches of the module for `.github/skills` and for `".github" / "skills"` each return zero matches.
- [ ] [P3-T8] Bring `test_legacy_discovery_skills_contracts.py` (`canonical_path`, module docstring, and `test_generated_copies_are_the_deterministic_role_link_rewrite`) and `skill` in `test_discovery_workflow_contracts.py` to the discovery source recorded by P0-T5 (`.agents/skills/<name>/SKILL.md` with child 3's per-tool rewrite); no edit when child 3 already re-anchored a symbol.
  - Acceptance: both modules pass; neither contains `.github/skills`; `test_legacy_discovery_skills_contracts.py` contains no `Path(".github") / "skills"` and `test_discovery_workflow_contracts.py` contains no `".github" / "skills"`.

### Phase 4 — Thin Copilot Layer, Documentation, Collision Controls and Matrix

- [ ] [P4-T1] Replace the body of `.github/copilot-instructions.md` with Copilot-only text under `# Copilot-only instructions`: shared instructions come from `AGENTS.md`, shared skills from `.agents/skills`, path-scoped rules from `.github/instructions`, prompts live natively in `.github/prompts`, handoff-bearing agents live natively in `.github/agents`; copy it to `extensions/drm-copilot/resources/customizations/.github/copilot-instructions.md`.
  - Acceptance: the file exists, contains neither `strictly professional` nor `Do not use jokes`, and equals its bundle copy byte for byte.
- [ ] [P4-T2] Update the pointer lines of `CLAUDE.md` per OQ5: `## Tone Policy` names `AGENTS.md` and `.github/instructions/tonality.instructions.md` as authoritative, and item 1 of `## Policy Compliance Reading Order` names `AGENTS.md`; no other line changes, and no edit when child 3 already made the change.
  - Acceptance: `CLAUDE.md` contains zero matches for `copilot-instructions.md`; a diff of `CLAUDE.md` between `MB` and the working tree changes only those two pointer locations.
- [ ] [P4-T3] Update `.agents/README.md` (the sentence that `.github/skills` and `.github/agents` remain as historical source material now states that issue #1032 retired `.github/skills` and that `.github/agents` remains the Copilot-native agent source) and copy it to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/README.md`; replace the `.github/skills/README.md` link in `README.md` `## Policy and skills references` with `.agents/skills/README.md`.
  - Acceptance: the bundle copy equals `.agents/README.md`; `README.md` contains zero matches for `.github/skills/README.md`.
- [ ] [P4-T4] Add `### Copilot collision controls` under `## Agentic runtime architecture` in `README.md`, listing `chat.agentSkillsLocations` with `".claude/skills": false`, `chat.instructionsFilesLocations` with `".claude/rules": false`, `chat.agentFilesLocations` with `".claude/agents": false`, and `chat.useClaudeMdFile: false`, and stating that `chat.useAgentsMdFile`, `chat.useClaudeHooks` and `github.copilot.chat.codeGeneration.useInstructionFiles` keep their defaults. With `WorkspaceScope: yes` (P0-T8) add the four keys to `.vscode/settings_required.json` and state the copy step into `.vscode/settings.json`; with `WorkspaceScope: no` leave `.vscode/settings_required.json` unchanged and state the keys as user-scope settings.
  - Acceptance: the section names all four keys and the scope matching P0-T8; `.vscode/settings_required.json` contains `chat.useClaudeMdFile` exactly when `WorkspaceScope: yes`; `test_vscode_workspace_settings.py` passes.
- [ ] [P4-T5] Update `docs/engineering/legacy-discovery-and-parity/maintainer-guide.md` and `workflow.md` to name `.agents/skills/<name>/SKILL.md` as the discovery skill source with child 3's generator, and remove `.github/skills` from the push-down output root list in `consumer-onboarding.md`; no edit where child 3 already made the change.
  - Acceptance: the three documents contain zero matches for `.github/skills`.
- [ ] [P4-T6] In `config/harness-parity-matrix.json`, set every entry whose `id` starts with `copilot:skill-frontmatter-field:` to `disposition` `dropped`, `reason` "Retired with .github/skills by issue #1032; superseded by the shared .agents/skills source.", `decision_ref` `#1018:epic.md#scope`, `decision_status` `approved`, removing `target_paths` and `generated_from`; set `decision_status` `approved` on every `copilot:skill:` entry and keep its child 1 `reason` and `decision_ref`.
  - Acceptance: `HarnessParityMatrix.RepoGate.Tests.ps1` passes with zero failed in `artifacts/pester/pester-junit.xml`; no `copilot:skill` or `copilot:skill-frontmatter-field` entry has a disposition other than `dropped`.

### Phase 5 — Final QA, Evidence and Self-Review

- [ ] [P5-T1] Run `black --check` on `scripts/dev_tools/agentic_sync.py` and every `CHANGED-PY` module.
  - Acceptance: `<FEATURE>/evidence/qa-gates/python-format.<timestamp>.md` records `EXIT_CODE: 0` and output containing `would be left unchanged` with no `would reformat` line; on a reformat, apply Black and restart at P5-T1.
- [ ] [P5-T2] Run `ruff check` on the same files.
  - Acceptance: `<FEATURE>/evidence/qa-gates/python-lint.<timestamp>.md` records `EXIT_CODE: 0` and `All checks passed!`.
- [ ] [P5-T3] Run Pyright on the same files.
  - Acceptance: `<FEATURE>/evidence/qa-gates/python-typecheck.<timestamp>.md` records `EXIT_CODE: 0` and `0 errors`.
- [ ] [P5-T4] Run `CHANGED-PY` and `RUN-ONLY-PY` in one process with `--cov=scripts.dev_tools.agentic_sync --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1032-agentic-sync-final.json`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/pytest-final.<timestamp>.md` records `EXIT_CODE: 0`, the pass count, and the line (at least 85%) and branch (at least 75%) percentages of `scripts/dev_tools/agentic_sync.py` read from the JSON report.
- [ ] [P5-T5] Run the contract tests the brief lists under `## Contract Tests That Pin Mirrored Files`, the Codex generator `--check`, and every child 3 generator `--check`; search every `pack-manifests/*.json` for the token `.github/skills`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/contract-checks.<timestamp>.md` records each command with `EXIT_CODE: 0` and zero pack-manifest matches.
- [ ] [P5-T6] Run the extension TypeScript static loop on the two edited TypeScript files: Prettier `--check`, ESLint, and the `typecheck` script.
  - Acceptance: `<FEATURE>/evidence/qa-gates/typescript-static.<timestamp>.md` records `All matched files use Prettier code style!`, an ESLint run with zero problems, and a `typecheck` exit 0.
- [ ] [P5-T7] Run the extension Jest suite with coverage per the brief's TypeScript route.
  - Acceptance: `<FEATURE>/evidence/qa-gates/jest-final.<timestamp>.md` records `EXIT_CODE: 0`, the pass count, and the line (at least 85%) and branch (at least 75%) percentages of `src/lib/push-down/copilot-customizations-engine.ts` from `extensions/drm-copilot/coverage/lcov.info`; the per-file `coverageThreshold` entry is unchanged.
- [ ] [P5-T8] Run PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` and an `Invoke-Formatter` comparison on `claude-architecture-doc.Tests.ps1`, then run `TOUCHED-PESTER` through `Invoke-PoshQCTest`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/pester-final.<timestamp>.md` records zero analyzer findings, formatter output identical to the file, and zero failed per suite from `artifacts/pester/pester-junit.xml`; these suites run in CI under `poshqc / PowerShell QC`.
- [ ] [P5-T9] Run the isolation checks: a reversed-order run of `CHANGED-PY` in one process; a seeded shuffled Jest run of `test/lib/push-down` with the seed recorded; three seeded shuffled file-order runs of `TOUCHED-PESTER`; and a fresh single-process Pester run over `tests/scripts`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/isolation.<timestamp>.md` records each run with its seed and file order and zero failures.
- [ ] [P5-T10] Write the coverage comparison for `scripts/dev_tools/agentic_sync.py` and `copilot-customizations-engine.ts` from P0-T9, P0-T10, P5-T4 and P5-T7, including coverage of the changed lines.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` lists baseline, final and changed-line coverage per file with no decrease.
- [ ] [P5-T11] Repeat the P0-T12 search and classify every remaining hit as `historical`, `fixture`, `generic-input` or `retirement-statement`.
  - Acceptance: `<FEATURE>/evidence/other/stale-reference-classification.<timestamp>.md` lists every hit with its class and zero `unclassified`; no hit is under `.github/agents/` or `extensions/drm-copilot/resources/customizations/.github/agents/`.
- [ ] [P5-T12] Compare the `.github/prompts` and `.github/hooks` inventories with P0-T7.
  - Acceptance: `<FEATURE>/evidence/qa-gates/github-native-inventory-compare.<timestamp>.md` reports identical file sets and hashes, or lists each difference with its child 5 evidence reference.
- [ ] [P5-T13] Check file size and new files: run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`; run `git diff --name-status` from `MB` to `HEAD` together with `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/size-and-new-files.<timestamp>.md` records zero failed for the file-size suite, no added `*.py` file, and no added TypeScript or Python file under `extensions/drm-copilot/resources/`.
- [ ] [P5-T14] Check off AC1, AC2, AC3, AC7, AC8, AC9, AC10, AC11, AC12, AC13 and AC15 in `<FEATURE>/spec.md` and US-AC1, US-AC2, US-AC4, US-AC5, US-AC6, US-AC7 and US-AC8 in `<FEATURE>/user-story.md` per `acceptance-criteria-tracking`, each against its evidence.
  - Acceptance: each listed criterion is `[x]`; AC4, AC5, AC6, AC14 and AC16 to AC19 and US-AC3, US-AC9 and US-AC10 remain open for the branch plan.
- [ ] [P5-T15] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from `MB`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed and the loop restarts at P5-T1 before the file is rewritten.

## Pre-Mortem

- Review checklists: a reviewer may flag lost unique content or stale references; P1-T1 records U1 to U3 with child 1 Diff IDs, P5-T11 classifies every remaining `.github/skills` hit, and P5-T15 walks all three templates.
- Coverage: the production edits are `agentic_sync.py` (Python) and `copilot-customizations-engine.ts` (TypeScript); P0-T9, P0-T10, P5-T4, P5-T7 and P5-T10 measure line and branch coverage per file in dotted-module and lcov form, with the existing Jest threshold entry kept.
- Mirror parity: every deleted source loses its bundle copy in the same task (P1-T2); each edited mirrored file is copied in its own task (P2-T1 to P2-T3, P4-T1, P4-T3); the execution-environment brief fact changes from six copies to four, and P2-T1 is the brief-update task across all four remaining byte-identical copies, with P2-T2 updating the matching plan-contract sentence; P5-T5 runs the brief's contract tests.
- File size: only Markdown, JSON, existing tests and two small production edits change; P5-T13 runs `FileSizePolicy.RepoGate.Tests.ps1` against `config/file-size-baseline.json`.
- Test isolation: P5-T9 runs a reversed-order run of the changed Python modules, a seeded shuffled Jest run with the seed recorded, three seeded shuffled file-order runs of the touched Pester suites with each seed recorded, and a fresh single-process run over `tests/scripts`; edited tests read committed files and in-memory fixtures only.
- CI-only behavior: `test_copilot_bundle_mirrors_every_scoped_github_file` fails on an empty root, so P3-T7 removes the root; the matrix gate runs in `poshqc / PowerShell QC` on Windows shards and is run locally in P4-T6 and P5-T8; no edited test diffs against `origin/main`.
- Evidence: every task names its artifact under `<FEATURE>/evidence/<kind>/` with a write-time stamp; command artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`; scratch paths are recorded as `SCRATCH`.

## Size Justification

The plan holds 51 tasks because the retirement must update, in the same plan, every existing test that pins a removed `.github/skills` path (fourteen Python modules, one Pester suite, one Jest suite), or its own acceptance cannot pass; the branch-dependent agent work is already split into the two branch plans, and the Phase 0 gate carries one task per upstream child as the epic requires.

## Test Plan

- Unit: `CHANGED-PY`, `RUN-ONLY-PY`, the engine Jest suite, `TOUCHED-PESTER`.
- Contract: the brief's contract tests, the Codex and child 3 generator checks, the parity-matrix repository gate.
- Manual: Copilot loads each shared skill once after the documented collision controls are applied (owner-run, outside this plan).
- Coverage evidence: baseline `evidence/baseline/pytest-baseline.*.md` and `jest-baseline.*.md`; final `evidence/qa-gates/pytest-final.*.md` and `jest-final.*.md`; comparison `evidence/qa-gates/coverage-delta.*.md`.

## Open Questions / Notes

- OQ1 to OQ5 take the spec defaults: collision controls per `WorkspaceScope` (P4-T4); no persona dropped (branch plans); U3 follows child 1's class; OQ4 is a Phase 0 stop (UA-C3b); OQ5 pointer-line edit in P4-T2.
- OQ6 (owner): `.claude/rules/parallel-orchestration.md` states that the policy reading order begins with `.github/copilot-instructions.md`. That file is a policy document outside this child's edit authority; recommended default: child 3 updates it with the rule source.
- Destination repositories that received `.github/skills` keep stale copies until child 4's migration removes them (UA-C4c, risk R3).
