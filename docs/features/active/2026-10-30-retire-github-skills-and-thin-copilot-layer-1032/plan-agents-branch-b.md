# 2026-10-30-retire-github-skills-and-thin-copilot-layer - Agents Branch B Plan

- **Issue:** #1032
- **Parent (optional):** epic #1018, child 6
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Draft
- **Version:** 0.4 (preflight revision: selection by E3 observation lines, owner-override precedence per AD-5, per-entry outcome record; 0.3: 50 agent files including `DOCS-AGENT-ROLES`, parallel-only gates, phase gate, self-review)
- **Work Mode:** full-feature
- **Selected when:** the main plan's greatest `<FEATURE>/evidence/other/agents-branch-selection.*.md` records `SelectedBranch: B`: E3 is deferred, or the greatest E3 result file does not record both `CLI-Lists-Claude-Agent: yes` and `Cloud-Lists-Claude-Agent: yes` (main plan `## Derivation Rules`).

## Required References

- Main plan `plan.2026-10-30T18-39.md` in this folder: `## Terms` (`<FEATURE>`, `MB`, `C1`, `SCRATCH`, `GATE-RUN`, `LAST-PLAN-CRITERIA`, artifact `Plan:` rule) and `## Derivation Rules`.
- `spec.md` `## Scope` item 2 (Branch B), risk R4, AC4 to AC6, AC14; child 1 spec `### Parity Matrix: Feature Entry`, `### Decision Reference Format` and `### Owner Approval Artifact`; child 1 `owner-decision-plan.md` `## Decision Application Rules` (rule 1, precedence H2).
- Tool routes and command shapes: `.claude/skills/execution-environment/SKILL.md` (not restated).

## Execution Order

Delegated after the main plan completes, as the only branch plan, before or after `plan-h3-sync-writer-retirement.md`. Branch B keeps `.github/agents` as the repository agent source for the Copilot CLI and cloud agent; handoffs stay native. This plan covers the native case: P0-T2 stops for re-planning when the main plan's child 3 record shows `GithubAgentsTarget: yes` (generated case). Owner overrides and decided disputed cases in `C1/survey/difference-approval.md` take precedence over the E3 result (child 1 rule H2; orchestrator decision AD-5, recorded in `autonomous_decisions` of the item checkpoint), so the entries they name keep their matrix fields. Every artifact carries `Plan: plan-agents-branch-b.md`.

## Terms

- `SCRATCH`: `<session scratchpad>/issue-1032/`, as in the main plan.
- `AGENT-PY`: spec `UNCHANGED-AGENT-PYTEST`. `AGENT-PESTER`: spec `UNCHANGED-AGENT-PESTER`, `docs-authoring-roles.Mirrors.Tests.ps1` and `docs-authoring-roles.Allowlist.Tests.ps1` (agent rows), and every suite under `tests/scripts/harness/`. None is edited.
- `E3-RESULT`: the result file name the greatest selection record names, when it names one and that file is present under `C1/evidence/other/`; otherwise `none`, and the selection record's deferral reference applies.
- `OVERRIDE-IDS`: the `copilot:agent:` and `copilot:handoff:` ids that P0-T2 records from `## Owner Overrides` rows and from `## Disputed Cases` blocks with a non-empty `Owner-Decision`.

## Upstream Assumptions

| ID | Assumption | Task | On mismatch |
| --- | --- | --- | --- |
| UB-1 | The main plan is complete (every task checked; its greatest self-review with `Plan: plan.2026-10-30T18-39.md` has no FAIL row); the selection records `SelectedBranch: B`; E3 is deferred or `E3-RESULT` does not record both observation values `yes`. | P0-T1 | Stop |
| UB-2 | The greatest `phase0-upstream-child3.*.md` records `GithubAgentsTarget: no`. | P0-T2 | Stop (generated case) |
| UB-3 | The `COPILOT-AGENT-FILES` set under `.github/agents/` (including the four `DOCS-AGENT-ROLES`) has one `copilot:agent:*` id per file and one `copilot:handoff:*` id per handoff-bearing file; names match the main plan's greatest `github-native-inventory.*.md` and counts match its greatest `phase0-upstream-child1.*.md`. | P0-T2 | Stop |
| UB-4 | `Get-DiscoveryAgentProfilePath` still resolves `.github/agents/<role>.agent.md`; `Get-DocsAuthoringAgentPath` still binds the docs roles. | P0-T2 | Stop |
| UB-5 | Owner overrides and decided disputed cases naming a `copilot:agent:` or `copilot:handoff:` id are recorded with their current matrix fields (`OVERRIDE-IDS`, possibly empty). | P0-T2 | Record |

## Language Classification

| Planned artifact | Change | Classification |
| --- | --- | --- |
| `config/harness-parity-matrix.json` | Edit | JSON data (child 1 schema) |
| Binding-resolution and hash-record helpers | Not committed | PowerShell under `SCRATCH` |
| `AGENT-PY`, `AGENT-PESTER` | Run only | Existing Python, called; PowerShell |

No artifact adds Python, nothing is pushed down, and no tool, command, skill or hook changes; no case needs an owner language decision.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Gate and Baseline

- [x] [P0-T1] Confirm UB-1 from the main plan file, its evidence under `<FEATURE>/evidence/qa-gates` and `<FEATURE>/evidence/other`, and `E3-RESULT` when present.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-main-plan-check.<timestamp>.md` records the checked-task count against the total, the self-review path with zero FAIL rows, `SelectedBranch: B`, the `E3-RESULT` name or the deferral reference, and `CLI-Lists-Claude-Agent:` and `Cloud-Lists-Claude-Agent:` as read (`none` without a result file); any mismatch, or an `E3-RESULT` recording both values `yes`, records `blocked: premise_falsified`.
- [x] [P0-T2] Check UB-2 to UB-5: read `GithubAgentsTarget` from the greatest `phase0-upstream-child3.*.md`; record every `## Owner Overrides` row and every `## Disputed Cases` block with a non-empty `Owner-Decision` in `C1/survey/difference-approval.md` that names a `copilot:agent:` or `copilot:handoff:` id; record every `COPILOT-AGENT-FILES` file under `.github/agents/` with its `git hash-object` value; compare with the matrix ids and the main-plan cross-checks; read `$script:AgentProfileLayout` and `Get-DocsAuthoringAgentPath`.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-recheck.<timestamp>.md` records `GithubAgentsTarget`, each file with its hash, the file and handoff-bearing counts, the two id counts, both cross-check results, each assumption as `holds` or `differs`, and under `OVERRIDE-IDS:` each recorded id with its source row or Diff ID, the owner decision, and its current `disposition`, `reason`, `decision_status` and `decision_ref` (or `none`); any `differs` on UB-2 to UB-4 records `blocked: premise_falsified`.
- [x] [P0-T3] Run the pytest `Phase 0 baseline` `GATE-RUN` over `tests/scripts` and the other configured test roots with coverage.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-pytest-baseline.<timestamp>.md` records pass and fail counts and repository-wide line and branch coverage, with every `AGENT-PY` module in the run, and `no in-scope production file`.
- [x] [P0-T4] Run the Pester `Phase 0 baseline` `GATE-RUN` over the scan folders of `config/poshqc-scan.json`.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-pester-baseline.<timestamp>.md` records `ExitCode`, pass and fail counts, repository-wide line coverage, and the pass state of every `AGENT-PESTER` suite.

### Phase 1 — Matrix, Bindings and Outcome

- [ ] [P1-T1] In `config/harness-parity-matrix.json`, set every entry whose id starts with `copilot:agent:` and is not in `OVERRIDE-IDS` to `disposition` `native` and `reason` "Branch B: E3 did not show that the Copilot CLI and cloud agent read .claude/agents, so .github/agents stays the repository agent source; no .github/agents generator target exists.", removing `target_paths` and `generated_from`. Decision fields follow spec R4: when `E3-RESULT` is a file name, `decision_status` `approved` and `decision_ref` `#1025:evidence/other/` followed by that name; otherwise `provisional` and the deferral reference `#1025:survey/difference-approval.md#owner-overrides`. Entries in `OVERRIDE-IDS` keep their `disposition`, `reason`, `decision_status` and `decision_ref`.
  - Acceptance: `HarnessParityMatrix.RepoGate.Tests.ps1` passes in the task check; every non-override `copilot:agent:` entry is `native`, and `approved` exactly when `E3-RESULT` is a file name, otherwise `provisional`.
- [ ] [P1-T2] Set every entry whose id starts with `copilot:handoff:` and is not in `OVERRIDE-IDS` to `native`, `approved`, `reason` "Handoffs stay native in .github/agents (settled design).", `decision_ref` `#1018:epic.md#shared-design`; entries in `OVERRIDE-IDS` keep their four fields.
  - Acceptance: the repository gate passes; every non-override `copilot:handoff:` entry is `native` and `approved`.
- [ ] [P1-T3] Run a `SCRATCH` helper that resolves every `agent:` value of `.github/prompts/**/*.prompt.md` frontmatter and every `agent:` under `handoffs:` in `.github/agents/*.agent.md` to a `.github/agents` file by `name:` (or, when `name:` is absent, the file name without its `.agent.md` suffix) or to the built-in `agent`, comparing values with surrounding quotes removed.
  - Acceptance: `<FEATURE>/evidence/other/agent-binding-resolution.<timestamp>.md` lists every binding with its resolved file and zero unresolved bindings.
- [ ] [P1-T4] Record the outcome: the `.github/agents` file set and hashes equal the P0-T2 record; list every `copilot:agent:` and `copilot:handoff:` entry with `disposition`, `decision_status`, `reason` and `decision_ref`, each marked `override kept` (in `OVERRIDE-IDS`), `set by P1-T1` or `set by P1-T2`; map each `.github/agents` file to the `copilot:agent:` entries whose `source_path` field equals the file's repository-relative path (child 1 spec `### Parity Matrix: Feature Entry`: `name` is the agent file stem, whose `.agent` handling the spec leaves open, and consumers that select by `name` also use `source_path`).
  - Acceptance: `<FEATURE>/evidence/other/agents-branch-outcome.<timestamp>.md` records `Branch: B (native)`, each file with equal current and P0-T2 hashes, zero removed or added files, each file mapped to exactly one `copilot:agent:` entry, every non-override `copilot:agent:` entry `native` with the P1-T1 `reason` and either `approved` with `decision_ref` `#1025:evidence/other/` plus the `E3-RESULT` name (exactly when the selection record names an E3 result file present under `C1/evidence/other/`) or `provisional` with `#1025:survey/difference-approval.md#owner-overrides`, every non-override `copilot:handoff:` entry `native`, `approved`, with a non-empty `reason` and `decision_ref` `#1018:epic.md#shared-design`, no non-override entry carrying `target_paths` or `generated_from`, each `override kept` entry equal to its P0-T2 fields, `NonConforming: 0` (the count of listed `copilot:agent:` and `copilot:handoff:` entries that fail any per-entry condition above), and the `decision_status` P1-T1 applied.
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
| Scope 2 Branch B selection (E3 no or deferred) | P0-T1 | Phase 0 stop when `E3-RESULT` records both values `yes` |
| Scope 2 Branch B native case; `COPILOT-AGENT-FILES`; `DOCS-AGENT-ROLES`; AC5 | P0-T2, P1-T4 | Phase 0 stop; outcome record; `docs-authoring-roles.Mirrors.Tests.ps1` agent `It` |
| Branch B generated case | P0-T2 | Phase 0 stop (re-plan) |
| Owner overrides take precedence over E3 (child 1 H2; AD-5) | P0-T2, P1-T1, P1-T2, P1-T4 | `override kept` rows equal to P0-T2 fields in the outcome record |
| Handoffs native; AC6 | P1-T2, P1-T3 | binding-resolution record; repository gate |
| AC14 agent and handoff entries; R4 `provisional`; matrix invariant; US-AC9 | P1-T1, P1-T2, P1-T4 | `HarnessParityMatrix.RepoGate.Tests.ps1`; `NonConforming: 0` in the outcome record |
| AC4; `LAST-PLAN-CRITERIA` | P0-T1, P2-T3 | Phase 0 stop; plan-order record |
| AC17; AC18; AC19 | P0-T3, P0-T4, P1-T5, P2-T1, P2-T2 | gate runs; `FileSizePolicy.RepoGate.Tests.ps1` |

## Pre-Mortem

- Review checklists: a reviewer may ask why no agent was generated and whether an owner override was overwritten; the Execution Order states the native-case scope and AD-5, P0-T2 records the overrides, P1-T4 records each entry's origin, and P2-T4 walks all three templates.
- Coverage: not applicable to per-file thresholds; this plan changes JSON data and evidence only, and P2-T1 shows no repository-wide drop against the `Phase 0 baseline`.
- Mirror parity: not applicable; no mirrored or bundled file changes, no fact of the execution-environment brief changes (no brief-update task), and no ledger record changes (P2-T2 confirms).
- File size: matrix field values change and no entry is added; `FileSizePolicy.RepoGate.Tests.ps1` runs in each Pester gate.
- Test isolation: one `Invoke-PoshQCParallelTest` and one `pytest -n auto` at baseline and final QA, and all three gates including Jest through its normal workers at the phase gate, each re-run only after a fix; no serial, single-process, shuffled or reversed run.
- CI-only behavior: the matrix gate runs in `poshqc / PowerShell QC` on the Windows shards and in each local Pester gate before push; child 1's schema requires `decision_ref` only for `provisional` and `dropped`, so the P1-T4 per-entry record, not the gate, proves each `approved` `native` entry carries one.
- Evidence: every artifact is `<name>.<timestamp>.md` under `<FEATURE>/evidence/<kind>/`, stamped at write time, append-only, carrying `Plan:`; helper paths are recorded as `SCRATCH`.
