<!-- markdownlint-disable-file -->

# Task Research Notes: Claude Planning Integrity (Issue #593)

## Research Executed

### File Analysis

- `.claude/skills/atomic-plan-contract/SKILL.md`
  - Already contains issue #586's adversarial self-review and executor-preflight convergence rules. It requires citation re-derivation and sibling-region checks, but not one planner review explicitly structured as citation-to-tree verification, AC-to-implementation traceability, and scope-boundary consistency.
- `.claude/agents/atomic-planner.md` and `.claude/hooks/validate-planner-output.ps1`
  - The agent delegates validation-only preflight; the termination hook requires a plan path, a preflight signal, and structural plan validity. Neither requires an internal preflight-shaped review declaration.
- `.claude/agents/task-researcher.md`, `.claude/skills/research-issue/SKILL.md`, `.claude/agents/prd-feature.md`, and `.claude/skills/fill-feature-docs/SKILL.md`
  - Research precedes `prd-feature`, which writes `spec.md` and `user-story.md`. No current contract requires a full symbol/method-family derivation plus independent cross-check before a numeric population is written into a `spec.md` AC.
- `.claude/skills/acceptance-criteria-tracking/SKILL.md`
  - Establishes authoritative AC headings and source files but contains no reusable section-bounded generated-document counter. `validate-executor-output.ps1` counts plan-task boxes, not AC boxes in generated requirements documents.
- `.claude/skills/parallel-plan/SKILL.md` and `.claude/skills/parallel-add/SKILL.md`
  - `/parallel-plan` already accepts the complete initial item set and launches bounded waves in one invocation. `/parallel-add` is one-item admission for an in-progress run, but does not explicitly diagnose a pending/not-started run as an intake-batching error.
- `docs/features/active/2026-08-28-atomic-preflight-convergence-586/plan.2026-08-28T20-02.md`
  - Issue #586 added the existing preflight controls to `atomic-plan-contract` and `remediation-handoff-atomic-planner`. The new behavior should extend those controls, not create a second preflight loop.
- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` and `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`
  - The repository tests Claude contracts through mockable hooks and discriminating text fixtures. They are within the 500-line limit (277 and 410 lines respectively).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  - Requires every non-memory repository `.claude/**` file to be byte-identical to the counterpart in `extensions/drm-copilot/resources/claude-customizations/.claude/**`.

### Code Search Results

- `Planner Adversarial Self-Review`, `Preflight Validation`, and `CONVERGENCE:` occur in `.claude/skills/atomic-plan-contract/SKILL.md`; related iteration recording and the two-iteration ceiling occur in `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`.
- `PREFLIGHT: ALL CLEAR|REVISIONS REQUIRED` occurs in `.claude/hooks/validate-planner-output.ps1`; the current hook accepts a structurally valid plan without internal-review evidence.
- `parallel-add` and `parallel-plan` occur in their two corresponding skills. The plan skill already states that `/parallel-add` is not the initial intake path.
- `count_checkboxes` occurs in `scripts/dev_tools/plan_progress_report.py`. Its whole-document plan-task count is intentional. No current Claude runtime counter processes `spec.md`, `user-story.md`, or `issue.md` AC sections; the reported #440 over-count was therefore an ad hoc verification procedure, not a reusable parser.

### External Research

- No external source was used. This request is governed by repository-owned Claude contracts, hooks, tests, and bundle publication behavior; those local sources are authoritative.

### Project Conventions

- Standards referenced: `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, and `.claude/rules/powershell.md`.
- Instructions followed: `.github/agents/task-researcher.agent.md`, the issue #586 plan, current Claude runtime contracts, and current bundle-parity tests.

## Key Discoveries

### Project Structure

The repository `.claude/` tree is canonical. Every changed canonical runtime file must have the same relative file under `extensions/drm-copilot/resources/claude-customizations/.claude/`. `test_push_down_claude_resource_contracts.py` verifies this relationship. The Python and TypeScript push-down implementations publish the already-bundled tree, so a text-only runtime-contract update does not require publisher behavior changes.

### Implementation Patterns

Use the issue #586 pattern: put the normative rule in `atomic-plan-contract`, add the owning agent's operational instruction, and make the owning `SubagentStop` hook reject a terminal response that omits the required declaration. Retain executor-owned, validation-only preflight and the existing remediation loop.

For AC counts, use a pure parser that receives an explicit heading, starts after that heading, and stops before the next heading of equal or shallower level. Test it with checkbox items before and after `## Acceptance Criteria`, so an unscoped whole-file scan fails the fixture. Do not change `plan_progress_report.count_checkboxes`; it measures plan progress, not ACs.

### Complete Examples

The existing contract already models mandatory signals:

```text
SELF-REVIEW: RE-DERIVED THIS PASS
PREFLIGHT: ALL CLEAR
CONVERGENCE: NO FURTHER ROUNDS EXPECTED
```

Issue #593 should add a separate, evidence-bearing declaration for the preflight-shaped internal review, rather than overload these signals.

### API and Schema Documentation

No checkpoint-schema extension is necessary. `remediation_loop.cycles[current_cycle].preflight.iterations` already records the count. When it exceeds one, the workflow should write a process-defect investigation that identifies the incomplete internal-review dimension, while preserving the current final-status values and issue #586 iteration ceiling.

### Technical Requirements

1. A numeric population in an approved `spec.md` AC must point to a derivation record with the complete symbol/method family, inclusion and exclusion rules, member set, and an independently constructed second search that reaches the same set. A single grep cannot authorize the number.
2. Before executor preflight, the planner must perform a single review of citation-to-tree verification, AC-to-implementation traceability, and scope-boundary consistency. Findings are resolved before handoff. A preflight iteration count above one is a process-defect signal, not routine iteration.
3. Each new reusable generated-document counter must accept a named section and prove, with an inline fixture, that unrelated checkboxes outside the section do not affect the result.
4. Initial parallel intake is one complete `/parallel-plan` item set. `/parallel-add` remains one-item admission only after execution has started; a pending or not-started run is rejected with direction to consolidate the list into `/parallel-plan`.

## Recommended Approach

Extend existing Claude controls in three narrow groups, with exact bundle mirrors and focused tests.

1. **Research-to-spec numeric evidence.** Add a `## Numeric Derivation Evidence` requirement to `task-researcher` and `research-issue`. Require `prd-feature` to write a numeric `spec.md` AC only when the research record contains two independently constructed full-family derivations and an explicit comparison. Require a no-numeric-claim declaration when none applies.
2. **Planner internal review before preflight.** Extend `atomic-plan-contract` and `atomic-planner` with the three-part review, and require its terminal declaration in `validate-planner-output.ps1`. Extend `remediation-handoff-atomic-planner` only to record and escalate `iterations > 1` as a process-defect investigation; preserve the issue #586 validation-only executor loop and iteration ceiling.
3. **Section-bounded AC accounting and initial intake.** Add a small portable `.claude/lib/` PowerShell module with a pure named-section checkbox summary, use it for AC status reporting, and cover it with inline Pester fixtures. Strengthen `parallel-add` and `parallel-plan` to distinguish an executing open run from a pending initial intake, then add a discriminating text-contract test.

Rejected alternatives: prompt-only wording leaves the planner hook able to accept an unreviewed handoff; modifying the generic plan-progress counter conflates plan tasks with ACs; modifying push-down publishers is unnecessary because the bundle parity gate protects each `.claude` mirror.

## Implementation Guidance

- **Candidate canonical files**:
  - `.claude/agents/task-researcher.md`
  - `.claude/skills/research-issue/SKILL.md`
  - `.claude/agents/prd-feature.md`
  - `.claude/skills/fill-feature-docs/SKILL.md`
  - `.claude/skills/atomic-plan-contract/SKILL.md`
  - `.claude/agents/atomic-planner.md`
  - `.claude/hooks/validate-planner-output.ps1`
  - `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
  - `.claude/skills/acceptance-criteria-tracking/SKILL.md`
  - `.claude/lib/<new-ac-section-parser>.psm1`
  - `.claude/skills/parallel-add/SKILL.md`
  - `.claude/skills/parallel-plan/SKILL.md`
- **Required bundle copies**: one identical corresponding file under `extensions/drm-copilot/resources/claude-customizations/.claude/` for each candidate `.claude` file, including the new parser module.
- **Test strategy**:
  - Extend `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` with accepting and rejecting internal-review declarations.
  - Add a Pester suite mirroring the new portable parser. Use inline document text only, with boxes before, inside, and after `## Acceptance Criteria`, and a nested-heading boundary case.
  - Extend `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` with an initial-intake predicate and a pending-run `/parallel-add` counterexample.
  - Add focused text-contract tests for research and PRD numeric-evidence requirements, or make that research section mechanically mandatory through `validate-task-researcher-output.ps1` and extend its Pester suite.
  - Run `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` after copying mirrors.
- **Dependencies**: no third-party dependency. A small PowerShell module is sufficient for a reusable counter.
- **Success criteria**: each numeric `spec.md` AC fact has two matching derivations; preflight cannot start without the three-part internal review; AC counters ignore outside-section boxes; initial parallel intake cannot be drip-fed through `/parallel-add`; canonical and bundled files remain byte-identical.
