# 2026-10-30-retire-github-skills-and-thin-copilot-layer - Agents Branch A Plan

- **Issue:** #1032
- **Parent (optional):** epic #1018, child 6
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.1
- **Work Mode:** full-feature
- **Selected when:** the main plan's `<FEATURE>/evidence/other/agents-branch-selection.*.md` records `SelectedBranch: A` (E3 result records `EXIT_CODE: 0`: both the Copilot CLI and the Copilot cloud agent read `.claude/agents`).

## Required References

- Main plan: `plan.2026-10-30T18-39.md` in this folder (terms, upstream assumptions, derivation rules).
- `spec.md` `## Scope` item 2 (Branch A), `## Owner Questions` OQ2, and `## Acceptance Criteria`; research `research/research.2026-10-30T23-02.md` sections 2.1 and 2.3.
- Child 1 spec `origin/feature/harness-survey-gold-standard-contracts-parity-matrix-1025:docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md` (`### Parity Matrix: Feature Entry`, `### Owner Approval Artifact`).
- Tool routes, launchers, CI shape: `.claude/skills/execution-environment/SKILL.md` (not restated here).

## Execution Order

The orchestrator delegates this plan only after the main plan completed with every task checked. It is the only branch plan executed for issue #1032. Handoffs stay native.

Branch A retires only `.github/agents` files outside every native binding, and only with an owner-approved `dropped` reason. By the bindings in research section 2.1, the eligible files are the personas with no `.claude/agents` equivalent, and OQ2's default keeps them. This plan therefore implements the OQ2 default: no `.github/agents` file is removed, and Branch A reduces to matrix status and the binding and outcome records (the collision controls were delivered by the main plan). P0-T3 stops for re-planning when child 1's approval artifact records an owner approval to drop any `copilot:agent:*` entry; that re-plan is the one permitted revision.

## Terms

- `<FEATURE>`, `MB`, `C1` and `SCRATCH` as defined in the main plan; `SCRATCH` is `<session scratchpad>/issue-1032/` and scratch file names start with `issue-1032-`.
- `AGENT-PY`: `tests/scripts/dev_tools/` modules `test_orchestrator_direct_command_contracts.py`, `test_discovery_publication_contracts.py`, `test_push_down_copilot_customizations_helpers.py`, `test_codex_full_migration_inventory.py`, `test_single_pass_preflight_contracts.py`, `test_csharp_orchestration_contracts.py` (agent-pinning; unchanged because no agent file changes in this plan).
- `AGENT-PESTER`: `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1`, `tests/scripts/dev-tools/agents-attribution.Tests.ps1`, `tests/scripts/claude-lib/discovery-validation/DiscoveryStart.Tests.ps1`, `tests/scripts/copilot-hooks/discovery-start.Tests.ps1` (unchanged), plus every suite under `tests/scripts/harness/` (matrix data edited).

## Upstream Assumptions

| ID | Assumption | Task | On mismatch |
| --- | --- | --- | --- |
| UA-A1 | The main plan is complete: every task checked, the greatest `self-review.*.md` has no FAIL row, and the greatest `agents-branch-selection.*.md` records `SelectedBranch: A`. | P0-T2 | Stop |
| UA-A2 | `C1/survey/difference-approval.md` (`## Disposition Proposals`, `## Owner Overrides`, `## Disputed Cases`) records no owner approval to drop any `copilot:agent:*` entry (OQ2 default). | P0-T3 | Stop |
| UA-A3 | At `MB`, the `.github/agents/*.agent.md` file set equals the set the main plan's Phase 0 recorded, and the matrix holds one `copilot:agent:*` entry per file and one `copilot:handoff:*` entry per handoff-bearing file. | P0-T3 | Stop |
| UA-A4 | `Get-DiscoveryAgentProfilePath` still resolves `.github/agents/<role>.agent.md` for `github-copilot`. | P0-T3 | Stop |

## Edit Set

`config/harness-parity-matrix.json` (`copilot:agent:*` and `copilot:handoff:*` entries) and evidence files only. No agent, prompt, hook or test file changes.

## Language Classification

| Planned artifact | Change | Classification |
| --- | --- | --- |
| `config/harness-parity-matrix.json` | Edit | JSON data (child 1 schema) |
| Binding-resolution helper | Not committed | PowerShell under `SCRATCH` |

No artifact adds Python, and nothing is pushed down. No case needs an owner language decision.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Gate and Baseline

- [ ] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/plan-acceptance-gates.md` and `.claude/skills/execution-environment/SKILL.md` in `policy-compliance-order` order.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-a-instructions-read.<timestamp>.md` carries `Timestamp:`, `Policy Order:` and the six files.
- [ ] [P0-T2] Re-read the main plan evidence to confirm UA-A1.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-a-main-plan-check.<timestamp>.md` records the main plan's checked-task count against its total, the self-review path with zero FAIL rows, and the `SelectedBranch` value; any mismatch records `blocked: premise_falsified` and the task stays unchecked.
- [ ] [P0-T3] Check UA-A2 to UA-A4 against the tree at `MB`: read the three approval sections for any `copilot:agent:` id marked for dropping, compare the `.github/agents` file list and the matrix `copilot:agent:*` and `copilot:handoff:*` ids with the main plan's Phase 0 evidence, and read `$script:AgentProfileLayout` in `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1`.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-a-recheck.<timestamp>.md` records each assumption as `holds` or `differs`, with counts; any `differs` records `blocked: premise_falsified` and the task stays unchecked.
- [ ] [P0-T4] Run `AGENT-PY` in one pytest process and `AGENT-PESTER` through `Invoke-PoshQCTest`.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-a-tests-baseline.<timestamp>.md` records `EXIT_CODE: 0` for pytest with the pass count, and zero failed per Pester suite from `artifacts/pester/pester-junit.xml`.

### Phase 1 — Matrix, Bindings and Outcome

- [ ] [P1-T1] In `config/harness-parity-matrix.json`, set every entry whose `id` starts with `copilot:agent:` to `disposition` `native`, `decision_status` `approved`, `reason` "Branch A under OQ2 default: kept in .github/agents because the file is in the handoff closure, a prompt binding or a discovery profile binding, or has no .claude/agents equivalent; no owner-approved drop.", and `decision_ref` `#1025:evidence/other/<E3 result file name>`; remove `target_paths` and `generated_from` from those entries.
  - Acceptance: `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes with zero failed in `artifacts/pester/pester-junit.xml`; every `copilot:agent:` entry is `native` and `approved`.
- [ ] [P1-T2] Set every entry whose `id` starts with `copilot:handoff:` to `disposition` `native`, `decision_status` `approved`, `reason` "Handoffs stay native in .github/agents (settled design).", and `decision_ref` `#1018:epic.md#shared-design`.
  - Acceptance: the repository gate passes with zero failed; every `copilot:handoff:` entry is `native` and `approved`.
- [ ] [P1-T3] Write a PowerShell helper under `SCRATCH` (not committed) that reads every `agent:` value from `.github/prompts/**/*.prompt.md` frontmatter and every `agent:` value under `handoffs:` in `.github/agents/*.agent.md`, and resolves each to a `.github/agents` file by `name:` or, for files without `name:`, by file stem, or to the built-in `agent`; run it.
  - Acceptance: `<FEATURE>/evidence/other/agent-binding-resolution.<timestamp>.md` lists every binding with its resolved file and records zero unresolved bindings.
- [ ] [P1-T4] Record the Branch A outcome: the `.github/agents` file set and hashes equal the main plan's Phase 0 set, every file has a `native` matrix entry with a reason, and the agent names that collide with `.claude/agents` are listed as a recorded risk for the Copilot CLI and cloud agent (the collision controls apply to VS Code only).
  - Acceptance: `<FEATURE>/evidence/other/agents-branch-outcome.<timestamp>.md` records `Branch: A (OQ2 default)`, zero removed or added agent files, zero `dropped` `copilot:agent:` entries, and the collision-name list.

### Phase 2 — Final QA, Evidence and Self-Review

- [ ] [P2-T1] Run `AGENT-PY` in one process, then in reversed module order.
  - Acceptance: `<FEATURE>/evidence/qa-gates/branch-a-pytest.<timestamp>.md` records `EXIT_CODE: 0` and the pass count for both runs.
- [ ] [P2-T2] Run `AGENT-PESTER` through `Invoke-PoshQCTest`, then three seeded shuffled file-order runs of `tests/scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/branch-a-isolation.<timestamp>.md` records zero failed from `artifacts/pester/pester-junit.xml` for each run with each seed and file order; these suites run in CI under `poshqc / PowerShell QC`.
- [ ] [P2-T3] Check file size and new files: run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`; run `git diff --name-status` from `MB` to `HEAD` together with `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/branch-a-size-and-new-files.<timestamp>.md` records zero failed, no added `*.py` file, and no added TypeScript or Python file under `extensions/drm-copilot/resources/`.
- [ ] [P2-T4] Confirm the main plan's toolchain and coverage evidence still applies: no file outside `config/harness-parity-matrix.json` and `<FEATURE>/` changed since the main plan's self-review.
  - Acceptance: `<FEATURE>/evidence/qa-gates/branch-a-toolchain-carryover.<timestamp>.md` lists the files changed by this plan and cites the main plan's `pytest-final`, `jest-final`, `pester-final` and `coverage-delta` artifacts.
- [ ] [P2-T5] Check off AC4, AC5, AC6, AC14, AC16, AC17, AC18 and AC19 in `<FEATURE>/spec.md` and US-AC3, US-AC9 and US-AC10 in `<FEATURE>/user-story.md` per `acceptance-criteria-tracking`.
  - Acceptance: each listed criterion is `[x]` with its evidence; every spec and user-story criterion is checked.
- [ ] [P2-T6] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from `MB`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed and the loop restarts at P2-T1 before the file is rewritten.

## Pre-Mortem

- Review checklists: a reviewer may ask why Branch A removed nothing; the Execution Order cites OQ2, P0-T3 proves no owner-approved drop exists, P1-T4 records the outcome, and P2-T6 walks all three templates.
- Coverage: not applicable; this plan changes no production code (JSON data and evidence only); the main plan's coverage evidence is carried over by P2-T4.
- Mirror parity: not applicable; no mirrored or bundled file changes, and no fact stated by the execution-environment brief changes, so no brief-update task is needed.
- File size: this plan edits field values in existing matrix entries and adds no entry; P2-T3 runs `FileSizePolicy.RepoGate.Tests.ps1` against `config/file-size-baseline.json`.
- Test isolation: P2-T1 runs a reversed-order run of the agent-pinning Python modules; P2-T2 runs three seeded shuffled file-order runs of the touched Pester suites under `tests/scripts/harness` with each seed recorded; no Jest test changes, so no Jest run is required.
- CI-only behavior: the matrix gate runs in `poshqc / PowerShell QC` on Windows shards; P1-T1, P1-T2 and P2-T2 run it locally before push.
- Evidence: every task names its artifact under `<FEATURE>/evidence/<kind>/` with a write-time stamp; command artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`; the helper path is recorded as `SCRATCH`.

## Open Questions / Notes

- An owner approval to drop personas (OQ2 answered "yes") is a re-plan trigger (UA-A2), not a planned path; it would add deletions of the approved files and their bundle copies, `dropped` matrix entries, and updates to `agents-attribution.Tests.ps1` and `test_thinking_beast_mode_bundle_mirror_matches_root_agent` where those pin a dropped file.
