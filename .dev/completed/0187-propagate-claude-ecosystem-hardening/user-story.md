# `propagate-claude-ecosystem-hardening` — User Story

- Issue: #187
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-06-16T10-28

## Story Statement

- As a repository maintainer, I want the orchestrator completion gate to block DONE when an unautomatable requirement is unresolved, halted, or recorded as an exception without an on-disk runbook, so that workflows cannot silently complete with manual blockers outstanding.
- As a task-researcher consumer, I want autonomous-execution research artifacts to be rejected unless they carry an `## Automation Feasibility` section, so that automation feasibility is recorded before downstream work depends on it.
- As a feature-review agent, I want explicit rules for coverage exclusions and test-file location, so that production paths cannot be silently dropped from coverage and test files cannot be colocated with production source.
- As an orchestrator operator, I want the remediation-handoff skill to specify the full handoff chain, per-artifact entry-vs-exit timestamps, plan shape, preflight sub-loop, and exit gate, so that remediation cycles are not malformed.
- As a runtime-asset owner, I want every `.claude/` change mirrored byte-identically into both bundled mirrors, so that the packaged customization payloads match the canonical runtime.

## Problem / Why

A Claude customization tree copied from another repository (`artifacts/tocompare/.claude`) was audited against this repository's canonical `.claude` runtime and its bundled mirrors. The audit (`artifacts/research/20260616-tocompare-claude-ecosystem-hardening-audit-research.md`) identified seven hardened elements present in the source tree that this repository lacks or has in a weaker form. These elements form a coherent autonomous-execution / human-exception enforcement subsystem plus two independent rule and skill improvements. Without them, the orchestrator can write DONE while unautomatable steps remain unresolved, research artifacts can omit automation-feasibility assessments, coverage measurement can silently exclude production paths, and remediation handoff cycles can be malformed.


## Personas & Scenarios

- Persona: Orchestrator operator (a Claude Code agent running the orchestrate skill).
  - Who: the agent that drives a feature or remediation workflow end to end.
  - What they care about: completing only when all required work is genuinely done, including any human-only steps.
  - Constraints: cannot perform third-party UI actions; relies on validators and hooks to enforce the autonomous-execution mandate.
  - Goals and frustrations: avoid writing DONE while a manual blocker is unresolved; today nothing blocks DONE for an unresolved `halt` or a runbook-less `exception`.
  - Context and motivations: a silent manual blocker discovered at the end of a workflow is indistinguishable from a workflow defect (research Section 4.1).
- Scenario: Exception with missing runbook.
  - Who is acting: the orchestrator operator at the completion gate.
  - Trigger: the operator records a `human_interaction` requirement with `response == exception` but omits a valid `runbook_path`.
  - Steps: the operator attempts to emit DONE; `validate-orchestrator-output.ps1` runs `Test-HumanInteractionShape`.
  - Obstacle/decision: the hook detects that `runbook_path` is empty or does not exist on disk and emits a Blocking finding.
  - Expected outcome: DONE is blocked until the operator authors a conformant runbook at `<FEATURE>/runbooks/<name>.runbook.md` per the `human-exception-runbook` skill.
- Persona: Feature-review agent.
  - Who: the agent that audits a feature branch against the rules.
  - What they care about: deterministic, citable rules to classify findings as Blocking.
  - Constraints: must cite an authoritative rule file when blocking a change.
  - Goals and frustrations: today the coverage-exclusion loophole and test-colocation are not addressed by repo rule prose, so they cannot be cited as Blocking.
  - Context and motivations: the new `general-unit-test.md` sections give the reviewer explicit text to cite (research Section 4.5).
- Scenario: Production path excluded from coverage.
  - Who is acting: the feature-review agent reviewing a coverage-config diff.
  - Trigger: a diff adds an `exclude` entry that matches a path under `src/` containing production runtime code.
  - Steps: the reviewer reads `## Coverage Exclusion Policy` and compares the excluded path against the prohibited-entry definition.
  - Obstacle/decision: the entry matches a production source path.
  - Expected outcome: the reviewer classifies the entry as a Blocking finding and cites the policy section.


## Acceptance Criteria

- [x] `Test-HumanInteractionShape` is present in `validate-orchestrator-output.ps1` (canonical + both mirrors), wired into the validation entrypoint, with Pester coverage for absent-key, missing-requirements, missing-response, invalid-enum, halt, and exception-without-runbook cases.
- [x] `Test-AutomationFeasibilitySection` is present in `validate-task-researcher-output.ps1` (canonical + both mirrors), with Pester coverage for matching and non-matching artifacts.
- [x] `## Autonomous-Execution Mandate` section is present in `orchestrate/SKILL.md` (canonical + both mirrors).
- [x] `skills/human-exception-runbook/SKILL.md` and `example.runbook.md` exist (canonical + both mirrors).
- [x] `validate_orchestrator_state.py` enforces the `human_interaction` invariants with pytest coverage; `rules/orchestrator-state.md` documents them.
- [x] `general-unit-test.md` contains the Coverage Exclusion Policy and Test File Location sections (canonical + both mirrors).
- [x] `remediation-handoff-atomic-planner/SKILL.md` matches the expanded source version (canonical + both mirrors).
- [x] Bundle-sync contract tests (`test_push_down_claude_resource_contracts.py`) pass.
- [x] Full toolchain (PowerShell, Python, contract tests) passes.


## Non-Goals

- Copying `schemas/orchestrator-state.schema.json` verbatim into the repository. Invariants are enforced via the existing Python validator pattern (research Section 5). Adding the schema only as machine-readable documentation is optional and out of scope for this feature unless separately decided.
- Propagating `settings.local.json` from the SOURCE tree (developer-local; contains another repository's allow-list entries).
- Propagating `agent-memory/**` from the SOURCE tree (project-specific memory from the source repository).
- Regressing `rules/orchestrator-state.md`; the repository is ahead on this file and only additive `human_interaction` documentation is in scope.
- Propagating any SOURCE file classified NOISE (byte-identical) or REPO-AHEAD in the audit's propagation-recommendation table.
- Adding an automated parity gate for the `packages/mcp-server/resources/claude-customizations/` mirror; that mirror is updated in this change but has no standalone contract test (research Section 2).
- Introducing new dependencies, CLI commands, services, telemetry, or runtime feature flags.
