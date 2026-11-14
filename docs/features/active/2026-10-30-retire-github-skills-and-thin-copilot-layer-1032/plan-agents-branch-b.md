# 2026-10-30-retire-github-skills-and-thin-copilot-layer - Agents Branch B Plan

- **Issue:** #1032
- **Parent (optional):** epic #1018, child 6
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Draft
- **Version:** 0.3 (refresh: 50 agent files including `DOCS-AGENT-ROLES`, parallel-only gates, phase gate, self-review)
- **Work Mode:** full-feature
- **Selected when:** the main plan's greatest `<FEATURE>/evidence/other/agents-branch-selection.*.md` records `SelectedBranch: B` (E3 absent, deferred or non-zero).

## Required References

- Main plan `plan.2026-10-30T18-39.md` in this folder: `## Terms` (`<FEATURE>`, `MB`, `C1`, `SCRATCH`, `GATE-RUN`, `LAST-PLAN-CRITERIA`, artifact `Plan:` rule).
- `spec.md` `## Scope` item 2 (Branch B), risk R4, AC4 to AC6, AC14; child 1 spec `### Parity Matrix: Feature Entry` and `### Decision Reference Format`.
- Tool routes and command shapes: `.claude/skills/execution-environment/SKILL.md` (not restated).

## Execution Order

Delegated after the main plan completes, as the only branch plan, before or after `plan-h3-sync-writer-retirement.md`. Branch B keeps `.github/agents` as the repository agent source for the Copilot CLI and cloud agent; handoffs stay native. This plan covers the native case: P0-T2 stops for re-planning when the main plan's child 3 record shows `GithubAgentsTarget: yes` (generated case). Every artifact carries `Plan: plan-agents-branch-b.md`.

## Terms

- `SCRATCH`: `<session scratchpad>/issue-1032/`, as in the main plan.
- `AGENT-PY`: spec `UNCHANGED-AGENT-PYTEST`. `AGENT-PESTER`: spec `UNCHANGED-AGENT-PESTER`, `docs-authoring-roles.Mirrors.Tests.ps1` and `docs-authoring-roles.Allowlist.Tests.ps1` (agent rows), and every suite under `tests/scripts/harness/`. None is edited.

## Upstream Assumptions

| ID | Assumption | Task | On mismatch |
| --- | --- | --- | --- |
| UB-1 | The main plan is complete (every task checked; its greatest self-review with `Plan: plan.2026-10-30T18-39.md` has no FAIL row) and the selection records `SelectedBranch: B`. | P0-T1 | Stop |
| UB-2 | The greatest `phase0-upstream-child3.*.md` records `GithubAgentsTarget: no`. | P0-T2 | Stop (generated case) |
| UB-3 | The `COPILOT-AGENT-FILES` set under `.github/agents/` (including the four `DOCS-AGENT-ROLES`) has one `copilot:agent:*` id per file and one `copilot:handoff:*` id per handoff-bearing file; names match the main plan's greatest `github-native-inventory.*.md` and counts match its greatest `phase0-upstream-child1.*.md`. | P0-T2 | Stop |
| UB-4 | `Get-DiscoveryAgentProfilePath` still resolves `.github/agents/<role>.agent.md`; `Get-DocsAuthoringAgentPath` still binds the docs roles. | P0-T2 | Stop |

## Language Classification

| Planned artifact | Change | Classification |
| --- | --- | --- |
| `config/harness-parity-matrix.json` | Edit | JSON data (child 1 schema) |
| Binding-resolution and hash-record helpers | Not committed | PowerShell under `SCRATCH` |
| `AGENT-PY`, `AGENT-PESTER` | Run only | Existing Python, called; PowerShell |

No artifact adds Python, nothing is pushed down, and no tool, command, skill or hook changes; no case needs an owner language decision.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Gate and Baseline

- [ ] [P0-T1] Confirm UB-1 from the main plan file and its evidence under `<FEATURE>/evidence/qa-gates` and `<FEATURE>/evidence/other`.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-main-plan-check.<timestamp>.md` records the checked-task count against the total, the self-review path with zero FAIL rows, and `SelectedBranch: B`; any mismatch records `blocked: premise_falsified`.
- [ ] [P0-T2] Check UB-2 to UB-4: read `GithubAgentsTarget` from the greatest `phase0-upstream-child3.*.md`; record every `COPILOT-AGENT-FILES` file under `.github/agents/` with its `git hash-object` value; compare with the matrix ids and the main-plan cross-checks; read `$script:AgentProfileLayout` and `Get-DocsAuthoringAgentPath`.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-recheck.<timestamp>.md` records `GithubAgentsTarget`, each file with its hash, the file and handoff-bearing counts, the two id counts, both cross-check results, and each assumption as `holds` or `differs`; any `differs` records `blocked: premise_falsified`.
- [ ] [P0-T3] Run the pytest `Phase 0 baseline` `GATE-RUN` over `tests/scripts` and the other configured test roots with coverage.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-pytest-baseline.<timestamp>.md` records pass and fail counts and repository-wide line and branch coverage, with every `AGENT-PY` module in the run, and `no in-scope production file`.
- [ ] [P0-T4] Run the Pester `Phase 0 baseline` `GATE-RUN` over the scan folders of `config/poshqc-scan.json`.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-pester-baseline.<timestamp>.md` records `ExitCode`, pass and fail counts, repository-wide line coverage, and the pass state of every `AGENT-PESTER` suite.

### Phase 1 — Matrix, Bindings and Outcome

- [ ] [P1-T1] In `config/harness-parity-matrix.json`, set every entry whose id starts with `copilot:agent:` to `disposition` `native` and `reason` "Branch B: E3 did not show that the Copilot CLI and cloud agent read .claude/agents, so .github/agents stays the repository agent source; no .github/agents generator target exists.", removing `target_paths` and `generated_from`. Decision fields follow spec R4, keyed on the greatest selection record: an E3 result file path gives `decision_status` `approved` and `decision_ref` `#1025:evidence/other/<E3 result file name>`; a deferral reference gives `provisional` and `#1025:survey/difference-approval.md#owner-overrides`.
  - Acceptance: `HarnessParityMatrix.RepoGate.Tests.ps1` passes in the task check; every `copilot:agent:` entry is `native`, and `approved` exactly when the selection record names an E3 result file present under `C1/evidence/other/`, otherwise `provisional`.
- [ ] [P1-T2] Set every entry whose id starts with `copilot:handoff:` to `native`, `approved`, `reason` "Handoffs stay native in .github/agents (settled design).", `decision_ref` `#1018:epic.md#shared-design`.
  - Acceptance: the repository gate passes; every `copilot:handoff:` entry is `native` and `approved`.
- [ ] [P1-T3] Run a `SCRATCH` helper that resolves every `agent:` value of `.github/prompts/**/*.prompt.md` frontmatter and every `agent:` under `handoffs:` in `.github/agents/*.agent.md` to a `.github/agents` file by `name:` (or, when `name:` is absent, the file name without its `.agent.md` suffix) or to the built-in `agent`, comparing values with surrounding quotes removed.
  - Acceptance: `<FEATURE>/evidence/other/agent-binding-resolution.<timestamp>.md` lists every binding with its resolved file and zero unresolved bindings.
- [ ] [P1-T4] Record the outcome: the `.github/agents` file set and hashes equal the P0-T2 record, and every file has a `native` entry with a reason.
  - Acceptance: `<FEATURE>/evidence/other/agents-branch-outcome.<timestamp>.md` records `Branch: B (native)`, each file with equal current and P0-T2 hashes, zero removed or added files, a `native` `copilot:agent:` count equal to the file count, and the `decision_status` P1-T1 applied.
- [ ] [P1-T5] [phase-gate] Run stages 1 to 6 across the repository per `## Test Cadence (Mandatory)`, with the unit stage as the three `PARALLEL-GATES` runs, writing `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/phase-gate.P1.<timestamp>.md` carries `Plan: plan-agents-branch-b.md` and one clean pass of every stage.

### Phase 2 — Final QA, Evidence and Self-Review

- [ ] [P2-T1] Run the pytest (`tests/scripts` and the other configured roots) and Pester (`config/poshqc-scan.json` folders) `GATE-RUN`s with coverage; no Jest-tested file changes, and the phase gate ran Jest.
  - Acceptance: `<FEATURE>/evidence/regression-testing/branch-b-pytest-final.<timestamp>.md` and `branch-b-pester-final.<timestamp>.md` record zero failures, pass counts and repository-wide coverage no lower than the P0-T3 and P0-T4 values, with every `AGENT-PY` module, every `AGENT-PESTER` suite and `FileSizePolicy.RepoGate.Tests.ps1` passing.
- [ ] [P2-T2] Record end state: list added files from the diff of `MB` and `HEAD` together with `git status --porcelain`, confirm no `LEDGER-RECORDS` file under `docs/engineering/process-reductions/` changed in this plan's commits (the range from the parent of the commit that added the greatest `branch-b-main-plan-check.*.md` to `HEAD`), and write the completion record.
  - Acceptance: `<FEATURE>/evidence/qa-gates/branch-b-end-state.<timestamp>.md` records no added `*.py` file, no pushed-down TypeScript or Python, and no ledger change; `<FEATURE>/evidence/other/plan-completion-branch.<timestamp>.md` records `Branch: B`.
- [ ] [P2-T3] Check off AC5, AC6, AC14 and US-AC9; when the greatest `plan-completion-h3.*.md` exists, also check off `LAST-PLAN-CRITERIA` against the three plans' gate, coverage and end-state artifacts, writing `<FEATURE>/evidence/other/plan-order.<timestamp>.md` (E3 result path or deferral, selected branch, order of the executed plans).
  - Acceptance: AC5, AC6, AC14 and US-AC9 are `[x]`; `LAST-PLAN-CRITERIA` are `[x]` exactly when the H3 completion record exists, with the plan-order record written.
- [ ] [P2-T4] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from `MB`, which includes this plan's commits.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` carries `Plan: plan-agents-branch-b.md` and one PASS, FAIL or N/A row per checklist item with no FAIL row; a FAIL is fixed and the loop restarts at P2-T1.

## Spec Traceability

| Spec element | Task | Check that fails if broken |
| --- | --- | --- |
| Scope 2 Branch B native case; `COPILOT-AGENT-FILES`; `DOCS-AGENT-ROLES`; AC5 | P0-T2, P1-T4 | Phase 0 stop; outcome record; `docs-authoring-roles.Mirrors.Tests.ps1` agent `It` |
| Branch B generated case | P0-T2 | Phase 0 stop (re-plan) |
| Handoffs native; AC6 | P1-T2, P1-T3 | binding-resolution record; repository gate |
| AC14 agent and handoff entries; R4 `provisional`; matrix invariant; US-AC9 | P1-T1, P1-T2 | `HarnessParityMatrix.RepoGate.Tests.ps1` |
| AC4; `LAST-PLAN-CRITERIA` | P0-T1, P2-T3 | Phase 0 stop; plan-order record |
| AC17; AC18; AC19 | P0-T3, P0-T4, P1-T5, P2-T1, P2-T2 | gate runs; `FileSizePolicy.RepoGate.Tests.ps1` |

## Pre-Mortem

- Review checklists: a reviewer may ask why no agent was generated; the Execution Order states the native-case scope, P1-T4 records the outcome, and P2-T4 walks all three templates.
- Coverage: not applicable to per-file thresholds; this plan changes JSON data and evidence only, and P2-T1 shows no repository-wide drop against the `Phase 0 baseline`.
- Mirror parity: not applicable; no mirrored or bundled file changes, no fact of the execution-environment brief changes (no brief-update task), and no ledger record changes (P2-T2 confirms).
- File size: matrix field values change and no entry is added; `FileSizePolicy.RepoGate.Tests.ps1` runs in each Pester gate.
- Test isolation: one `Invoke-PoshQCParallelTest` and one `pytest -n auto` at baseline and final QA, and all three gates including Jest through its normal workers at the phase gate, each re-run only after a fix; no serial, single-process, shuffled or reversed run.
- CI-only behavior: the matrix gate runs in `poshqc / PowerShell QC` on the Windows shards and in each local Pester gate before push.
- Evidence: every artifact is `<name>.<timestamp>.md` under `<FEATURE>/evidence/<kind>/`, stamped at write time, append-only, carrying `Plan:`; helper paths are recorded as `SCRATCH`.
