# 2026-10-30-retire-github-skills-and-thin-copilot-layer - Agents Branch B Plan

- **Issue:** #1032
- **Parent (optional):** epic #1018, child 6
- **Owner:** drmoisan
- **Last Updated:** 2026-10-31
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Selected when:** the main plan's `<FEATURE>/evidence/other/agents-branch-selection.*.md` records `SelectedBranch: B` (E3 result absent, deferred, or non-zero).

## Required References

- Main plan: `plan.2026-10-30T18-39.md` in this folder (terms, upstream assumptions, derivation rules).
- `spec.md` `## Scope` item 2 (Branch B) and `## Acceptance Criteria`; research `research/research.2026-10-30T23-02.md` section 2.3.
- Child 1 spec `origin/feature/harness-survey-gold-standard-contracts-parity-matrix-1025:docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md` (`### Parity Matrix: Feature Entry`, `### Decision Reference Format`).
- Tool routes, launchers, CI shape: `.claude/skills/execution-environment/SKILL.md` (not restated here).

## Execution Order

The orchestrator delegates this plan only after the main plan completed with every task checked. It is the only branch plan executed for issue #1032. Branch B keeps `.github/agents` as the repository agent source for the Copilot CLI and cloud agent; handoffs stay native.

This plan covers the Branch B native case. The generated case (child 3 emits a `.github/agents` target with `handoffs:` and Copilot tool identifiers) is not planned: P0-T3 stops for re-planning when the main plan's child 3 evidence records `GithubAgentsTarget: yes`, and that re-plan is the one permitted revision.

## Terms

- `<FEATURE>`, `MB`, `C1` and `SCRATCH` as defined in the main plan; `SCRATCH` is `<session scratchpad>/issue-1032/` and scratch file names start with `issue-1032-`.
- `AGENT-PY`: `tests/scripts/dev_tools/` modules `test_orchestrator_direct_command_contracts.py`, `test_discovery_publication_contracts.py`, `test_push_down_copilot_customizations_helpers.py`, `test_codex_full_migration_inventory.py`, `test_single_pass_preflight_contracts.py`, `test_csharp_orchestration_contracts.py` (agent-pinning; unchanged because no agent file changes in this plan).
- `AGENT-PESTER`: `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1`, `tests/scripts/dev-tools/agents-attribution.Tests.ps1`, `tests/scripts/claude-lib/discovery-validation/DiscoveryStart.Tests.ps1`, `tests/scripts/copilot-hooks/discovery-start.Tests.ps1` (unchanged), plus every suite under `tests/scripts/harness/` (matrix data edited).

## Upstream Assumptions

| ID | Assumption | Task | On mismatch |
| --- | --- | --- | --- |
| UB-1 | The main plan is complete: every task checked, the greatest `self-review.*.md` has no FAIL row, and the greatest `agents-branch-selection.*.md` records `SelectedBranch: B`. | P0-T2 | Stop |
| UB-2 | The greatest `phase0-upstream-child3.*.md` records `GithubAgentsTarget: no`. | P0-T3 | Stop (generated case) |
| UB-3 | The `.github/agents/*.agent.md` file set at Branch B start, recorded by P0-T3 with one `git hash-object` value per file and the count, matches the matrix: one `copilot:agent:*` id per recorded file and one `copilot:handoff:*` id per recorded handoff-bearing file (a file whose frontmatter has `handoffs:`). Cross-checks only: the recorded file names equal the `.github/agents` names in the main plan's greatest `github-native-inventory.*.md` (main P0-T7), and the two id counts equal the per-kind counts in the main plan's greatest `phase0-upstream-child1.*.md` (main P0-T4). | P0-T3 | Stop |
| UB-4 | `Get-DiscoveryAgentProfilePath` still resolves `.github/agents/<role>.agent.md` for `github-copilot`. | P0-T3 | Stop |

## Edit Set

`config/harness-parity-matrix.json` (`copilot:agent:*` and `copilot:handoff:*` entries) and evidence files only. No agent, prompt, hook or test file changes.

## Language Classification

| Planned artifact | Change | Classification |
| --- | --- | --- |
| `config/harness-parity-matrix.json` | Edit | JSON data (child 1 schema) |
| Binding-resolution helper (P1-T3) and the `.github/agents` hash-record helper (P0-T3, P1-T4) | Not committed | PowerShell under `SCRATCH` |
| Parity-matrix repository gate and `AGENT-PESTER` suites | Run only, not edited | PowerShell |
| `AGENT-PY` modules | Run only, not edited | Existing Python tests, tolerated (called) |

No artifact adds Python, nothing is pushed down, and no MCP tool, extension command, skill or hook is added or changed. No case needs an owner language decision.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Gate and Baseline

- [ ] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/plan-acceptance-gates.md` and `.claude/skills/execution-environment/SKILL.md` in `policy-compliance-order` order.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-instructions-read.<timestamp>.md` carries `Timestamp:`, `Policy Order:` and the six files.
- [ ] [P0-T2] Re-read the main plan evidence to confirm UB-1.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-main-plan-check.<timestamp>.md` records the main plan's checked-task count against its total, the self-review path with zero FAIL rows, and the `SelectedBranch` value; any mismatch records `blocked: premise_falsified` and the task stays unchecked.
- [ ] [P0-T3] Check UB-2 to UB-4: read the `GithubAgentsTarget` value from the lexicographically greatest `<FEATURE>/evidence/baseline/phase0-upstream-child3.*.md` (UB-2); record every `.github/agents/*.agent.md` file in the working tree at Branch B start with its `git hash-object` value, and the file count; compare that set with the matrix `copilot:agent:*` ids and the handoff-bearing files with the `copilot:handoff:*` ids; cross-check the file names against the main plan's greatest `github-native-inventory.*.md` and the two id counts against the main plan's greatest `phase0-upstream-child1.*.md`; read `$script:AgentProfileLayout` in `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1`.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-recheck.<timestamp>.md` records the `GithubAgentsTarget` value, lists every `.github/agents/*.agent.md` file with its hash, the file count, the handoff-bearing file count, the `copilot:agent:*` and `copilot:handoff:*` id counts, the two cross-check results, and each assumption as `holds` or `differs`; any `differs` records `blocked: premise_falsified` and the task stays unchecked.
- [ ] [P0-T4] Run `AGENT-PY` in one pytest process and `AGENT-PESTER` through `Invoke-PoshQCTest`.
  - Acceptance: `<FEATURE>/evidence/baseline/branch-b-tests-baseline.<timestamp>.md` records `EXIT_CODE: 0` for pytest with the pass count, and zero failed per Pester suite from `artifacts/pester/pester-junit.xml`.

### Phase 1 — Matrix, Bindings and Outcome

- [ ] [P1-T1] In `config/harness-parity-matrix.json`, set every entry whose `id` starts with `copilot:agent:` to `disposition` `native` and `reason` "Branch B: E3 did not show that the Copilot CLI and cloud agent read .claude/agents, so .github/agents stays the repository agent source; no .github/agents generator target exists.", and remove `target_paths` and `generated_from` from those entries. The decision fields follow spec R4 and child 1's Definition of Done, keyed on the lexicographically greatest `<FEATURE>/evidence/other/agents-branch-selection.*.md`: when it records an E3 result file path (E3 ran with a non-zero exit code), set `decision_status` `approved` and `decision_ref` `#1025:evidence/other/<E3 result file name>` (the file name of that path); when it records a deferral reference instead (E3 deferred, no result file), set `decision_status` `provisional` and `decision_ref` `#1025:survey/difference-approval.md#owner-overrides`.
  - Acceptance: `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes with zero failed in `artifacts/pester/pester-junit.xml`; every `copilot:agent:` entry is `native`; every such entry has `decision_status` `approved` exactly when the selection record names an E3 result file that exists under `C1/evidence/other/`, and `provisional` otherwise.
- [ ] [P1-T2] Set every entry whose `id` starts with `copilot:handoff:` to `disposition` `native`, `decision_status` `approved`, `reason` "Handoffs stay native in .github/agents (settled design).", and `decision_ref` `#1018:epic.md#shared-design`.
  - Acceptance: the repository gate passes with zero failed; every `copilot:handoff:` entry is `native` and `approved`.
- [ ] [P1-T3] Write a PowerShell helper under `SCRATCH` (not committed) that reads every `agent:` value from `.github/prompts/**/*.prompt.md` frontmatter and every `agent:` value under `handoffs:` in `.github/agents/*.agent.md`, and resolves each to a `.github/agents` file by `name:` or, for files without `name:`, by file stem, or to the built-in `agent`, comparing values after removing surrounding single or double quotes (several prompt `agent:` values and agent `name:` values are quoted); run it.
  - Acceptance: `<FEATURE>/evidence/other/agent-binding-resolution.<timestamp>.md` lists every binding with its resolved file and records zero unresolved bindings.
- [ ] [P1-T4] Record the Branch B outcome: the `.github/agents` file set and `git hash-object` values equal the P0-T3 record in the greatest `branch-b-recheck.*.md`, and every file has a `native` matrix entry with a reason.
  - Acceptance: `<FEATURE>/evidence/other/agents-branch-outcome.<timestamp>.md` records `Branch: B (native)`, each file with its current hash and its P0-T3 hash (all equal), zero removed or added agent files, the count of `native` `copilot:agent:` entries equal to the agent file count, and the `decision_status` value P1-T1 applied (`approved` or `provisional`).

### Phase 2 — Final QA, Evidence and Self-Review

- [ ] [P2-T1] Run `AGENT-PY` in one process, then in reversed module order.
  - Acceptance: `<FEATURE>/evidence/qa-gates/branch-b-pytest.<timestamp>.md` records `EXIT_CODE: 0` and the pass count for both runs.
- [ ] [P2-T2] Run `AGENT-PESTER` through `Invoke-PoshQCTest`, then three seeded shuffled file-order runs of `tests/scripts/harness`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/branch-b-isolation.<timestamp>.md` records zero failed from `artifacts/pester/pester-junit.xml` for each run with each seed and file order; these suites run in CI under `poshqc / PowerShell QC`.
- [ ] [P2-T3] Check file size and new files: run `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`; run `git diff --name-status` from `MB` to `HEAD` together with `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/branch-b-size-and-new-files.<timestamp>.md` records zero failed, no added `*.py` file, and no added TypeScript or Python file under `extensions/drm-copilot/resources/`.
- [ ] [P2-T4] Confirm the main plan's toolchain and coverage evidence still applies: no file outside `config/harness-parity-matrix.json` and `<FEATURE>/` changed since the main plan's self-review, derived as `git diff --name-status` from the commit that added the self-review path recorded by P0-T2 (found by `git log` on that path) to `HEAD`, together with `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/branch-b-toolchain-carryover.<timestamp>.md` lists the files changed by this plan and cites the main plan's `pytest-final`, `jest-final`, `pester-final` and `coverage-delta` artifacts.
- [ ] [P2-T5] Check off AC4, AC5, AC6, AC14, AC16, AC17, AC18 and AC19 in `<FEATURE>/spec.md` and US-AC3, US-AC9 and US-AC10 in `<FEATURE>/user-story.md` per `acceptance-criteria-tracking`.
  - Acceptance: each listed criterion is `[x]` with its evidence; every spec and user-story criterion is checked.
- [ ] [P2-T6] Walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from `MB`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` has one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed and the loop restarts at P2-T1 before the file is rewritten.

## Pre-Mortem

- Review checklists: a reviewer may ask why no agent was generated; the Execution Order states the native-case scope, P1-T4 records the outcome, and P2-T6 walks all three templates.
- Coverage: not applicable; this plan changes no production code (JSON data and evidence only); the main plan's coverage evidence is carried over by P2-T4.
- Mirror parity: not applicable; no mirrored or bundled file changes, and no fact stated by the execution-environment brief changes, so no brief-update task is needed.
- File size: this plan edits field values in existing matrix entries and adds no entry; P2-T3 runs `FileSizePolicy.RepoGate.Tests.ps1` against `config/file-size-baseline.json`.
- Test isolation: P2-T1 runs a reversed-order run of the agent-pinning Python modules; P2-T2 runs three seeded shuffled file-order runs of the touched Pester suites under `tests/scripts/harness` with each seed recorded; no Jest test changes, so no Jest run is required.
- CI-only behavior: the matrix gate runs in `poshqc / PowerShell QC` on Windows shards; P1-T1, P1-T2 and P2-T2 run it locally before push.
- Evidence: every task names its artifact under `<FEATURE>/evidence/<kind>/` with a write-time stamp; command artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`; the helper path is recorded as `SCRATCH`; the agent file set and hashes are recorded at Branch B start (P0-T3) and re-compared in P1-T4, with the main plan's P0-T4 and P0-T7 records used as cross-checks only.

## Open Questions / Notes

- The Branch B generated case is a re-plan trigger (UB-2), not a planned path. Child 3's spec (`docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/spec.md`, `### Surface: agents`) lists only `.claude/agents` and base `.codex/agents` outputs, so `GithubAgentsTarget: no` is the expected record.
- Spec R4: with E3 deferred, the `copilot:agent:*` entries stay `provisional` (P1-T1); they become `approved` only through a later E3 result, which is outside this plan.
