# 0005: Policy-read removal

## Summary

reduction: 0005
Date: 2026-11-07
Issue: #1097
Merge commit: pending (PR #1097)

Removes the routine Phase 0 policy-read task and its `phase0-instructions-read.md` artifact as a planning requirement. The planner stop hook no longer reports `Phase 0 must include a policy-read task.`, the planning contract states that Phase 0 carries no routine policy-read task and that a plan that keeps one stays valid, and the planner agents, the remediation handoff skill, the Copilot executors, orchestrators, and planners, both `execute-hard-lock` prompts, the feature plan template, and the architecture document drop the requirement. Only the requirement is removed: `policy-compliance-order` is unchanged and agents still follow policy. Every baseline requirement is unchanged. Until the pull request exists, the `Merge commit:` line carries the canonical issue number as a stand-in, and the orchestrator replaces it with the pull request number right after PR creation.

## Reason and Evidence

Research section 3 of `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/research/research.2026-11-06.md` lists every producer and consumer of the routine policy-read task and its artifact, and records that `policy-compliance-order` governs reading, which agents keep doing, and that removing the check only widens acceptance, so a plan that keeps the task stays valid. The owner's condition is that only the routine read task and its artifact are dropped; the baseline requirements stay, and this entry changes no baseline wording. A coordinator baseline hold is in force while the owner decides how baselines and the coverage reading interact, and this entry presumes neither outcome.

The removal is incomplete on one surface. `.github/prompts/review-feature.prompt.md` and its bundle `extensions/drm-copilot/resources/customizations/.github/prompts/review-feature.prompt.md` are held under the baseline hold and still expect the `phase0-instructions-read.md` artifact, so a Copilot review of a plan without the read task can report that artifact missing until the owner decides. The time saved is unknown until stage timing has data.

## Files Changed

- `.claude/hooks/validate-planner-output.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1`, a byte-identical bundle copy
- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`: `blocks when Phase 0 baseline and policy-read tasks are missing` renamed to `blocks when Phase 0 baseline tasks are missing`; `reports an error when Phase 0 mentions baseline but no policy-read wording` replaced by `accepts Phase 0 with baseline wording and no policy-read wording`; `accepts a plan that keeps the policy-read task` added
- `.claude/skills/atomic-plan-contract/SKILL.md`
- `.agents/skills/atomic-plan-contract/SKILL.md`
- `.github/skills/atomic-plan-contract/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md`, a byte-identical bundle copy
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`, a byte-identical bundle copy
- `.claude/agents/atomic-planner.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`, a byte-identical bundle copy
- `.codex/agents/atomic-planner.toml`, the hand-edited Codex base agent
- `.codex/agents/atomic-planner-c1.toml`, `-c2`, `-c3`, `-c3-elevated`, and `-c4`, generated variants
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml` and its five variants, generated bundle copies
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, a byte-identical bundle copy
- `.github/agents/atomic_executor.agent.md`, `.github/agents/csharp-atomic-executor.agent.md`, `.github/agents/powershell-atomic-executor.agent.md`, and `.github/agents/python-atomic-executor.agent.md`, with their byte-identical bundle copies under `extensions/drm-copilot/resources/customizations/.github/agents/`
- `.github/agents/orchestrator.agent.md`, `.github/agents/csharp-orchestrator.agent.md`, `.github/agents/powershell-orchestrator.agent.md`, and `.github/agents/python-orchestrator.agent.md`, with their byte-identical bundle copies under `extensions/drm-copilot/resources/customizations/.github/agents/`
- `.github/agents/atomic_planning.agent.md`, `.github/agents/csharp-atomic-planning.agent.md`, `.github/agents/powershell-atomic-planning.agent.md`, and `.github/agents/python-atomic-planning.agent.md`, with their byte-identical bundle copies under `extensions/drm-copilot/resources/customizations/.github/agents/`
- `.github/prompts/execute-hard-lock.prompt.md` and `.github/codex/execute-hard-lock.prompt.md`, with their byte-identical bundle copies under `extensions/drm-copilot/resources/customizations/.github/`
- `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md`
- `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`, a byte-identical bundle copy
- `docs/engineering/claude-code-architecture.md`, which has no bundle
- `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`, the `PCW-POLICY-READ-REMOVED` and `PCW-SURFACE` rows
- `docs/engineering/process-reductions/README.md`, the index row of this entry

Not changed, and held: `.github/prompts/review-feature.prompt.md` and its bundle, whose `phase0-instructions-read.md` bullet stays until the owner's decision is relayed.

## Prior Text

### Revert Block: .claude/hooks/validate-planner-output.ps1

````Current
      - the plan contains canonical `### Phase N — <Title>` headings,
      - Phase 0 exists and includes baseline tasks,
      - each task uses `- [ ] [P#-T#]` (or checked equivalent),

````

````Prior
      - the plan contains canonical `### Phase N — <Title>` headings,
      - Phase 0 exists and includes policy-read and baseline tasks,
      - each task uses `- [ ] [P#-T#]` (or checked equivalent),

````

### Revert Block: .claude/hooks/validate-planner-output.ps1

````Current
        $phaseZeroText = ($tasksByPhase[0] -join "`n")
        if ($phaseZeroText -notmatch '(?i)\bbaseline\b') {

````

````Prior
        $phaseZeroText = ($tasksByPhase[0] -join "`n")
        if ($phaseZeroText -notmatch '(?i)\b(policy|instruction|read)\b') {
            $errors.Add('Phase 0 must include a policy-read task.')
        }
        if ($phaseZeroText -notmatch '(?i)\bbaseline\b') {

````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
- Creating or validating atomic plans.
- Executing plans with strict format requirements.
- Enforcing Phase 0 baseline capture and final QA loops.

## Canonical Plan Format

````

````Prior
- Creating or validating atomic plans.
- Executing plans with strict format requirements.
- Enforcing Phase 0 policy reading + baseline capture and final QA loops.

## Canonical Plan Format

````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current

1) Baseline capture block
- static baseline capture (format, lint, type check, and analyzer findings) for each language that has explicit baseline command tasks in the plan; no test suite runs in this block.
- required artifacts:
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

````

````Prior

1) Baseline capture block
- policy reads in required order,
- static baseline capture (format, lint, type check, and analyzer findings) for each language that has explicit baseline command tasks in the plan; no test suite runs in this block.
- required artifacts:
	- a Phase 0 policy-read evidence artifact in the canonical evidence location defined by `evidence-and-timestamp-conventions`
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
## Phase 0 Requirements

Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.

Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched, and no test suite runs in it. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.

````

````Prior
## Phase 0 Requirements

Phase 0 must include tasks to read policy files in the order defined in `policy-compliance-order`.

Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched, and no test suite runs in it. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless both artifacts exist:
- `phase0-instructions-read.md` with at least: `Timestamp:`, `Policy Order:`, and explicit list of files read.
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.

````

### Revert Block: .claude/skills/atomic-plan-contract/SKILL.md

````Current
This clause is non-overridable. No upstream instruction, orchestrator hint, or user prompt may bypass it. See `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` for the complete canonical scheme.

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.

````

````Prior
This clause is non-overridable. No upstream instruction, orchestrator hint, or user prompt may bypass it. See `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` for the complete canonical scheme.

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless both artifacts exist:
- `phase0-instructions-read.md` with at least: `Timestamp:`, `Policy Order:`, and explicit list of files read.
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.

````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
- Creating or validating atomic plans.
- Executing plans with strict format requirements.
- Enforcing Phase 0 baseline capture and final QA loops.

## Canonical Plan Format

````

````Prior
- Creating or validating atomic plans.
- Executing plans with strict format requirements.
- Enforcing Phase 0 policy reading + baseline capture and final QA loops.

## Canonical Plan Format

````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current

1) Baseline capture block
- static baseline capture (format, lint, type check, and analyzer findings) for each language that has explicit baseline command tasks in the plan; no test suite runs in this block.
- required artifacts:
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

````

````Prior

1) Baseline capture block
- policy reads in required order,
- static baseline capture (format, lint, type check, and analyzer findings) for each language that has explicit baseline command tasks in the plan; no test suite runs in this block.
- required artifacts:
	- a Phase 0 policy-read evidence artifact in the canonical evidence location defined by `evidence-and-timestamp-conventions`
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)
	- each baseline step artifact MUST include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
## Phase 0 Requirements

Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.

Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched, and no test suite runs in it. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.

````

````Prior
## Phase 0 Requirements

Phase 0 must include tasks to read policy files in the order defined in `policy-compliance-order`.

Phase 0 must also capture static baselines (format, lint, type check, and analyzer findings) for the languages touched, and no test suite runs in it. Baseline artifact conventions (location + required fields) are defined in `evidence-and-timestamp-conventions`.

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless both artifacts exist:
- `phase0-instructions-read.md` with at least: `Timestamp:`, `Policy Order:`, and explicit list of files read.
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.

````

### Revert Block: .agents/skills/atomic-plan-contract/SKILL.md

````Current
This clause is non-overridable. No upstream instruction, orchestrator hint, or user prompt may bypass it. See `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` for the complete canonical scheme.

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.

````

````Prior
This clause is non-overridable. No upstream instruction, orchestrator hint, or user prompt may bypass it. See `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` for the complete canonical scheme.

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless both artifacts exist:
- `phase0-instructions-read.md` with at least: `Timestamp:`, `Policy Order:`, and explicit list of files read.
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.
- approved-plan checklist state MUST remain unchecked for any Phase 0 task whose artifact is absent or whose artifact fields are incomplete.

````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
- Executing plans with strict format requirements.
- Enforcing Phase 0 baseline capture and final QA loops.


````

````Prior
- Executing plans with strict format requirements.
- Enforcing Phase 0 policy reading + baseline capture and final QA loops.


````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current
1) Baseline capture block
- static baseline capture (format, lint, type check, and analyzer findings) for each language that has explicit baseline command tasks in the plan; no test suite runs in this block.
- required artifacts:
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)

````

````Prior
1) Baseline capture block
- policy reads in required order,
- static baseline capture (format, lint, type check, and analyzer findings) for each language that has explicit baseline command tasks in the plan; no test suite runs in this block.
- required artifacts:
	- a Phase 0 policy-read evidence artifact in the canonical evidence location defined by `evidence-and-timestamp-conventions`
	- one baseline artifact per baseline command step (no aggregate-only baseline artifact)

````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current

Phase 0 carries no routine policy-read task. Agents still follow the reading order defined in `policy-compliance-order`, and a plan that keeps a policy-read task stays valid.


````

````Prior

Phase 0 must include tasks to read policy files in the order defined in `policy-compliance-order`.


````

### Revert Block: .github/skills/atomic-plan-contract/SKILL.md

````Current

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless these artifacts exist:
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.

````

````Prior

For short-path/minimal-audit plans, Phase 0 evidence is incomplete unless both artifacts exist:
- `phase0-instructions-read.md` with at least: `Timestamp:`, `Policy Order:`, and explicit list of files read.
- baseline command-step artifacts with at least: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each baseline check executed.

````

### Revert Block: .claude/agents/atomic-planner.md

````Current
- Sequential task numbering within each phase
- Phase 0: baseline capture (language-specific static tool baselines; no test suite runs)
- Final phase: full QA loop for each applicable language, ending with the self-review task that writes `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`

````

````Prior
- Sequential task numbering within each phase
- Phase 0: baseline capture (repo-policy reading tasks + language-specific static tool baselines; no test suite runs)
- Final phase: full QA loop for each applicable language, ending with the self-review task that writes `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md`

````

### Revert Block: .codex/agents/atomic-planner.toml

````Current
- Sequential task numbering within each phase
- Phase 0: baseline capture (language-specific static tool baselines; no test suite runs)
- Final phase: full QA loop for each applicable language

````

````Prior
- Sequential task numbering within each phase
- Phase 0: baseline capture (repo-policy reading tasks + language-specific static tool baselines; no test suite runs)
- Final phase: full QA loop for each applicable language

````

### Revert Block: .claude/skills/remediation-handoff-atomic-planner/SKILL.md

````Current
- Tasks: `- [ ] [P#-T#]` with sequential per-phase IDs.
- Phase 0 captures static baseline results per `evidence-and-timestamp-conventions`.
- Final phase runs the full toolchain QA loop in the order specified by `atomic-plan-contract` and records numeric coverage values where the repository policy requires coverage.

````

````Prior
- Tasks: `- [ ] [P#-T#]` with sequential per-phase IDs.
- Phase 0 captures policy reads and static baseline results per `policy-compliance-order` and `evidence-and-timestamp-conventions`.
- Final phase runs the full toolchain QA loop in the order specified by `atomic-plan-contract` and records numeric coverage values where the repository policy requires coverage.

````

### Revert Block: .github/agents/atomic_executor.agent.md

````Current

If the plan does not include Phase 0, treat the plan as **invalid** and request a corrected plan. (Do not “silently add” Phase 0; that is replanning.)


````

````Prior

If the plan does not include Phase 0 tasks that cover the above, treat the plan as **invalid** and request a corrected plan. (Do not “silently add” Phase 0; that is replanning.)


````

### Revert Block: .github/agents/atomic_executor.agent.md

````Current
- Task numbers are sequential within each phase.
- Phase 0 exists.
- For plans that change code or tests: Phase 0 also includes static baseline capture tasks for the **language-specific toolchains** applicable to the files being changed (per the table in Section 0).

````

````Prior
- Task numbers are sequential within each phase.
- Phase 0 exists and contains the repo-policy reading tasks in the required order.
- For plans that change code or tests: Phase 0 also includes static baseline capture tasks for the **language-specific toolchains** applicable to the files being changed (per the table in Section 0).

````

### Revert Block: .github/agents/csharp-atomic-executor.agent.md

````Current

If the plan does not include Phase 0, treat the plan as **invalid** and request a corrected plan. (Do not "silently add" Phase 0; that is replanning.)


````

````Prior

If the plan does not include Phase 0 tasks that cover the above, treat the plan as **invalid** and request a corrected plan. (Do not "silently add" Phase 0; that is replanning.)


````

### Revert Block: .github/agents/csharp-atomic-executor.agent.md

````Current
- Task numbers are sequential within each phase.
- Phase 0 exists.
- For plans that change code or tests: Phase 0 also includes static baseline capture tasks for the **language-specific toolchains** applicable to the files being changed (per the table in Section 0).

````

````Prior
- Task numbers are sequential within each phase.
- Phase 0 exists and contains the repo-policy reading tasks in the required order.
- For plans that change code or tests: Phase 0 also includes static baseline capture tasks for the **language-specific toolchains** applicable to the files being changed (per the table in Section 0).

````

### Revert Block: .github/agents/powershell-atomic-executor.agent.md

````Current

If the plan does not include Phase 0, treat the plan as **invalid** and request a corrected plan. (Do not "silently add" Phase 0; that is replanning.)


````

````Prior

If the plan does not include Phase 0 tasks that cover the above, treat the plan as **invalid** and request a corrected plan. (Do not "silently add" Phase 0; that is replanning.)


````

### Revert Block: .github/agents/powershell-atomic-executor.agent.md

````Current
- Task numbers are sequential within each phase.
- Phase 0 exists.
- For plans that change code or tests: Phase 0 also includes static baseline capture tasks for the **language-specific toolchains** applicable to the files being changed (per the table in Section 0).

````

````Prior
- Task numbers are sequential within each phase.
- Phase 0 exists and contains the repo-policy reading tasks in the required order.
- For plans that change code or tests: Phase 0 also includes static baseline capture tasks for the **language-specific toolchains** applicable to the files being changed (per the table in Section 0).

````

### Revert Block: .github/agents/python-atomic-executor.agent.md

````Current

If the plan does not include Phase 0, treat the plan as **invalid** and request a corrected plan. (Do not "silently add" Phase 0; that is replanning.)


````

````Prior

If the plan does not include Phase 0 tasks that cover the above, treat the plan as **invalid** and request a corrected plan. (Do not "silently add" Phase 0; that is replanning.)


````

### Revert Block: .github/agents/python-atomic-executor.agent.md

````Current
- Task numbers are sequential within each phase.
- Phase 0 exists.
- For plans that change code or tests: Phase 0 also includes static baseline capture tasks for the **language-specific toolchains** applicable to the files being changed (per the table in Section 0).

````

````Prior
- Task numbers are sequential within each phase.
- Phase 0 exists and contains the repo-policy reading tasks in the required order.
- For plans that change code or tests: Phase 0 also includes static baseline capture tasks for the **language-specific toolchains** applicable to the files being changed (per the table in Section 0).

````

### Revert Block: .github/agents/orchestrator.agent.md

````Current
- Persist checkpoint with Phase 0 completion evidence.
- Do not mark S4 complete unless the baseline command-step artifacts referenced by the plan exist on disk, and the corresponding Phase 0 checklist items are checked from execution evidence rather than inferred summary text.


````

````Prior
- Persist checkpoint with Phase 0 completion evidence.
- Do not mark S4 complete unless `phase0-instructions-read.md` and the baseline command-step artifacts referenced by the plan exist on disk, and the corresponding Phase 0 checklist items are checked from execution evidence rather than inferred summary text.


````

### Revert Block: .github/agents/orchestrator.agent.md

````Current
- At least one short-path `feature-audit.<timestamp>.md` exists under `${feature-folder}`.
- baseline command-step artifacts required by the approved plan exist under `${feature-folder}`.
- If remediation triggered, `remediation-inputs.<timestamp>.md` and `remediation-plan.<timestamp>.md` must exist, at least one remediation execution receipt and one remediation commit receipt must exist, and the latest re-audit must return `REVIEW_STATUS: PASS`.

````

````Prior
- At least one short-path `feature-audit.<timestamp>.md` exists under `${feature-folder}`.
- `phase0-instructions-read.md` and baseline command-step artifacts required by the approved plan exist under `${feature-folder}`.
- If remediation triggered, `remediation-inputs.<timestamp>.md` and `remediation-plan.<timestamp>.md` must exist, at least one remediation execution receipt and one remediation commit receipt must exist, and the latest re-audit must return `REVIEW_STATUS: PASS`.

````

### Revert Block: .github/agents/csharp-orchestrator.agent.md

````Current
- Persist checkpoint with Phase 0 completion evidence.
- Do not mark S4 complete unless the baseline command-step artifacts referenced by the plan exist on disk, and the corresponding Phase 0 checklist items are checked from execution evidence rather than inferred summary text.


````

````Prior
- Persist checkpoint with Phase 0 completion evidence.
- Do not mark S4 complete unless `phase0-instructions-read.md` and the baseline command-step artifacts referenced by the plan exist on disk, and the corresponding Phase 0 checklist items are checked from execution evidence rather than inferred summary text.


````

### Revert Block: .github/agents/csharp-orchestrator.agent.md

````Current
- At least one short-path `feature-audit.<timestamp>.md` exists under `${feature-folder}`.
- baseline command-step artifacts required by the approved plan exist under `${feature-folder}`.
- If remediation triggered, `remediation-inputs.<timestamp>.md` and `remediation-plan.<timestamp>.md` must exist and the latest re-audit must pass.

````

````Prior
- At least one short-path `feature-audit.<timestamp>.md` exists under `${feature-folder}`.
- `phase0-instructions-read.md` and baseline command-step artifacts required by the approved plan exist under `${feature-folder}`.
- If remediation triggered, `remediation-inputs.<timestamp>.md` and `remediation-plan.<timestamp>.md` must exist and the latest re-audit must pass.

````

### Revert Block: .github/agents/powershell-orchestrator.agent.md

````Current
- Persist checkpoint with Phase 0 completion evidence.
- Do not mark S4 complete unless the baseline command-step artifacts referenced by the plan exist on disk, and the corresponding Phase 0 checklist items are checked from execution evidence rather than inferred summary text.


````

````Prior
- Persist checkpoint with Phase 0 completion evidence.
- Do not mark S4 complete unless `phase0-instructions-read.md` and the baseline command-step artifacts referenced by the plan exist on disk, and the corresponding Phase 0 checklist items are checked from execution evidence rather than inferred summary text.


````

### Revert Block: .github/agents/powershell-orchestrator.agent.md

````Current
- At least one short-path `feature-audit.<timestamp>.md` exists under `${feature-folder}`.
- baseline command-step artifacts required by the approved plan exist under `${feature-folder}`.
- If remediation triggered, `remediation-inputs.<timestamp>.md` and `remediation-plan.<timestamp>.md` must exist and the latest re-audit must pass.

````

````Prior
- At least one short-path `feature-audit.<timestamp>.md` exists under `${feature-folder}`.
- `phase0-instructions-read.md` and baseline command-step artifacts required by the approved plan exist under `${feature-folder}`.
- If remediation triggered, `remediation-inputs.<timestamp>.md` and `remediation-plan.<timestamp>.md` must exist and the latest re-audit must pass.

````

### Revert Block: .github/agents/python-orchestrator.agent.md

````Current
- Persist checkpoint with Phase 0 completion evidence.
- Do not mark S4 complete unless the baseline command-step artifacts referenced by the plan exist on disk, and the corresponding Phase 0 checklist items are checked from execution evidence rather than inferred summary text.


````

````Prior
- Persist checkpoint with Phase 0 completion evidence.
- Do not mark S4 complete unless `phase0-instructions-read.md` and the baseline command-step artifacts referenced by the plan exist on disk, and the corresponding Phase 0 checklist items are checked from execution evidence rather than inferred summary text.


````

### Revert Block: .github/agents/python-orchestrator.agent.md

````Current
- At least one short-path `feature-audit.<timestamp>.md` exists under `${feature-folder}`.
- baseline command-step artifacts required by the approved plan exist under `${feature-folder}`.
- If remediation triggered, `remediation-inputs.<timestamp>.md` and `remediation-plan.<timestamp>.md` must exist and the latest re-audit must pass.

````

````Prior
- At least one short-path `feature-audit.<timestamp>.md` exists under `${feature-folder}`.
- `phase0-instructions-read.md` and baseline command-step artifacts required by the approved plan exist under `${feature-folder}`.
- If remediation triggered, `remediation-inputs.<timestamp>.md` and `remediation-plan.<timestamp>.md` must exist and the latest re-audit must pass.

````

### Revert Block: .github/agents/atomic_planning.agent.md

````Current

### 2.3 Phase 0 — Context & Inputs


````

````Prior

### 2.3 Phase 0 — Context & Inputs (Mandatory Policy & Research)


````

### Revert Block: .github/agents/csharp-atomic-planning.agent.md

````Current

### 2.3 Phase 0 — Context & Inputs


````

````Prior

### 2.3 Phase 0 — Context & Inputs (Mandatory Policy & Research)


````

### Revert Block: .github/agents/powershell-atomic-planning.agent.md

````Current

### 2.3 Phase 0 — Context & Inputs


````

````Prior

### 2.3 Phase 0 — Context & Inputs (Mandatory Policy & Research)


````

### Revert Block: .github/agents/python-atomic-planning.agent.md

````Current

### 2.3 Phase 0 — Context & Inputs


````

````Prior

### 2.3 Phase 0 — Context & Inputs (Mandatory Policy & Research)


````

### Revert Block: .github/prompts/execute-hard-lock.prompt.md

````Current
- If Phase 0 does not include:
  - Static baseline capture for each language touched by the plan,

````

````Prior
- If Phase 0 does not include:
  - Repo-policy reading tasks, AND
  - Static baseline capture for each language touched by the plan,

````

### Revert Block: .github/prompts/execute-hard-lock.prompt.md

````Current
- Phase 0 exists and includes:
  - Static baseline runs for each language touched

````

````Prior
- Phase 0 exists and includes:
  - Repo-policy reading
  - Static baseline runs for each language touched

````

### Revert Block: .github/codex/execute-hard-lock.prompt.md

````Current
- If Phase 0 does not include:
  - Static baseline capture for each language touched by the plan,

````

````Prior
- If Phase 0 does not include:
  - Repo-policy reading tasks, AND
  - Static baseline capture for each language touched by the plan,

````

### Revert Block: .github/codex/execute-hard-lock.prompt.md

````Current
- Phase 0 exists and includes:
  - Static baseline runs for each language touched

````

````Prior
- Phase 0 exists and includes:
  - Repo-policy reading
  - Static baseline runs for each language touched

````

### Revert Block: docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md

````Current

### Phase 0: Context & Inputs
- [ ] [P0-T1] <Atomic task>


````

````Prior

### Phase 0: Compliance & Context
- [ ] [P0-T1] Confirm alignment with repo policies by reading `.github/instructions/general-code-change.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, and `.github/instructions/python-unit-test.instructions.md` before touching code
  - Acceptance: Development log contains policy review timestamp prior to Phase 1 commits


````

### Revert Block: docs/engineering/claude-code-architecture.md

````Current

The `atomic-planner` produces a phased plan file at `docs/features/active/<feature>/plan.md`. The plan follows the format defined in the `atomic-plan-contract` skill, with Phase 0, implementation phases, and a final QA loop. The planner's `SubagentStop` hook (defined in `.claude/settings.json`) blocks termination unless the planner's output includes a plan file path.


````

````Prior

The `atomic-planner` produces a phased plan file at `docs/features/active/<feature>/plan.md`. The plan follows the format defined in the `atomic-plan-contract` skill, with Phase 0 policy reads, implementation phases, and a final QA loop. The planner's `SubagentStop` hook (defined in `.claude/settings.json`) blocks termination unless the planner's output includes a plan file path.


````

## Revert Steps

1. Apply the blocks: replace each `Current` fence with its `Prior` fence in the named file, in the order of this entry. Revert this entry before `0001`: several blocks edit text inside hunks of `patches/0001-parallel-only-test-gates.patch` (the planner agents and their Codex variants, the handoff skill, the Copilot executors, both `execute-hard-lock` prompts, and the feature plan template), so that patch does not reverse-apply to those files while this entry is in place.
2. Re-copy mirrors and bundles: copy each of these to its bundle path under `extensions/drm-copilot/resources/`: `.claude/hooks/validate-planner-output.ps1`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/agents/atomic-planner.md`, and `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` under `claude-customizations/`; `.agents/skills/atomic-plan-contract/SKILL.md` under `codex-and-agents-customizations/`; `.github/skills/atomic-plan-contract/SKILL.md`, the twelve Copilot agents named under `## Files Changed`, `.github/prompts/execute-hard-lock.prompt.md`, and `.github/codex/execute-hard-lock.prompt.md` under `customizations/`; and `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` to `feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`.
3. Regenerate Codex variants: applicable, because the base agent `.codex/agents/atomic-planner.toml` changed. Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form to rewrite the variants and their bundle copies, then run it with `--check`.
4. Restore pinned hashes: not applicable, because no pinned surface moved.
5. Restore contract-test literals: in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, rename `blocks when Phase 0 baseline tasks are missing` back to `blocks when Phase 0 baseline and policy-read tasks are missing` with its body unchanged, restore `reports an error when Phase 0 mentions baseline but no policy-read wording` in place of `accepts Phase 0 with baseline wording and no policy-read wording`, asserting a `policy-read task` error, and remove `accepts a plan that keeps the policy-read task`; in `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`, remove the `PCW-POLICY-READ-REMOVED` and `PCW-SURFACE` rows and the `PolicyReadSurface` list; and remove `tests/scripts/dev-tools/ProcessReductionLedger.Replay.Tests.ps1` when it is present, because it replays this entry's hook blocks and asserts that the live hook reports no policy-read error.
6. Run the contract tests: run `validate-planner-output.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, `ProcessReductionLedger.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_codex_agent_wrapper_contracts.py`, `test_single_pass_preflight_contracts.py`, and `test_claude_planning_integrity_contracts.py`.

## Revert Signals

- Review findings that cite a policy the executor did not follow.
- A remediation cycle traced to a skipped policy rule.
