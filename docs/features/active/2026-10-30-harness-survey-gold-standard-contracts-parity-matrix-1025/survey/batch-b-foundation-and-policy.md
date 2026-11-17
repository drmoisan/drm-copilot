# Batch B: Foundation and Policy (Issue #1025)

Per-skill records in the shape of spec `### Survey Records`. Each copy was read; a section missing from one copy was searched for as a heading across that ecosystem's agent bodies, rules, instructions and sibling skills before it was recorded as missing. Classes and port directions are proposals for the owner approval artifact `difference-approval.md`.

### acceptance-criteria-tracking

- Presence: claude=`.claude/skills/acceptance-criteria-tracking/SKILL.md` | codex=`.agents/skills/acceptance-criteria-tracking/SKILL.md` | copilot=`.github/skills/acceptance-criteria-tracking/SKILL.md`
- Identity: wording-only
- Proposed disposition: shared
- Objective (draft): Track and check off acceptance criteria in requirement source files (issue.md, spec.md, user-story.md) as they are delivered.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-acceptance-criteria-tracking-01 | codex:.agents/skills/acceptance-criteria-tracking/SKILL.md#AC Identification | Section `AC Identification` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

### atomic-plan-contract

- Presence: claude=`.claude/skills/atomic-plan-contract/SKILL.md` | codex=`.agents/skills/atomic-plan-contract/SKILL.md` | copilot=`.github/skills/atomic-plan-contract/SKILL.md`
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Atomic plan format and toolchain contract shared by planning and execution agents.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-atomic-plan-contract-01 | codex:.agents/skills/atomic-plan-contract/SKILL.md#Canonical Plan Format | Section `Canonical Plan Format` is worded differently in copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-atomic-plan-contract-02 | codex:.agents/skills/atomic-plan-contract/SKILL.md#Phase-0-Only Execution Contract (Small Path) | Section `Phase-0-Only Execution Contract (Small Path)` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-atomic-plan-contract-03 | codex:.agents/skills/atomic-plan-contract/SKILL.md#No-Manual-Step Contract (Mandatory) | Section `No-Manual-Step Contract (Mandatory)` is present in codex and copilot and absent from the claude copy, with no equivalent heading elsewhere in that ecosystem. | no | positive | codex->claude | Adds guidance that serves the objective; port it so every expression carries it. |
| D-atomic-plan-contract-04 | codex:.agents/skills/atomic-plan-contract/SKILL.md#Non-Overridable Evidence Path Clause | Section `Non-Overridable Evidence Path Clause` is present in codex and absent from the copilot copy of the skill. | no | neutral | none | The copilot copy is proposed dropped in favor of the shared .agents copy, so no port to it is needed. |
| D-atomic-plan-contract-05 | codex:.agents/skills/atomic-plan-contract/SKILL.md#Preflight Validation (Planner ↔ Executor) | Section `Preflight Validation (Planner ↔ Executor)` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-atomic-plan-contract-06 | codex:.agents/skills/atomic-plan-contract/SKILL.md#Single-Pass Preflight | Section `Single-Pass Preflight` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-atomic-plan-contract-07 | codex:.agents/skills/atomic-plan-contract/SKILL.md#Validator Gate (Mandatory) | Section `Validator Gate (Mandatory)` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-atomic-plan-contract-08 | claude:.claude/skills/atomic-plan-contract/SKILL.md#Planner Adversarial Self-Review (Mandatory) | Section `Planner Adversarial Self-Review (Mandatory)` is present in claude and absent from the codex copy, with no equivalent heading elsewhere in that ecosystem. | no | positive | claude->codex | Adds guidance that serves the objective; port it so every expression carries it. |
| D-atomic-plan-contract-09 | claude:.claude/skills/atomic-plan-contract/SKILL.md#Planner Adversarial Self-Review (Mandatory) | Section `Planner Adversarial Self-Review (Mandatory)` is present in claude and absent from the copilot copy of the skill. | no | neutral | none | The copilot copy is proposed dropped in favor of the shared .agents copy, so no port to it is needed. |
| D-atomic-plan-contract-10 | claude:.claude/skills/atomic-plan-contract/SKILL.md#Planner Internal Review Record | Section `Planner Internal Review Record` is present in claude and absent from the codex copy, with no equivalent heading elsewhere in that ecosystem. | no | positive | claude->codex | Adds guidance that serves the objective; port it so every expression carries it. |
| D-atomic-plan-contract-11 | claude:.claude/skills/atomic-plan-contract/SKILL.md#Planner Internal Review Record | Section `Planner Internal Review Record` is present in claude and absent from the copilot copy of the skill. | no | neutral | none | The copilot copy is proposed dropped in favor of the shared .agents copy, so no port to it is needed. |
| D-atomic-plan-contract-12 | claude:.claude/skills/atomic-plan-contract/SKILL.md#Wrap-Tolerant Assertion Authoring (Mandatory) | Section `Wrap-Tolerant Assertion Authoring (Mandatory)` is present in claude and absent from the codex copy, with no equivalent heading elsewhere in that ecosystem. | no | positive | claude->codex | Adds guidance that serves the objective; port it so every expression carries it. |
| D-atomic-plan-contract-13 | claude:.claude/skills/atomic-plan-contract/SKILL.md#Wrap-Tolerant Assertion Authoring (Mandatory) | Section `Wrap-Tolerant Assertion Authoring (Mandatory)` is present in claude and absent from the copilot copy of the skill. | no | neutral | none | The copilot copy is proposed dropped in favor of the shared .agents copy, so no port to it is needed. |

### evidence-and-timestamp-conventions

- Presence: claude=`.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | codex=`.agents/skills/evidence-and-timestamp-conventions/SKILL.md` | copilot=`.github/skills/evidence-and-timestamp-conventions/SKILL.md`
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Evidence storage and timestamp naming conventions for audits and remediation.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-evidence-and-timestamp-conventions-01 | codex:.agents/skills/evidence-and-timestamp-conventions/SKILL.md#Non-Overridable Authority | Section `Non-Overridable Authority` is present in codex and absent from the copilot copy of the skill. | no | neutral | none | The copilot copy is proposed dropped in favor of the shared .agents copy, so no port to it is needed. |

### execution-environment

- Presence: claude=`.claude/skills/execution-environment/SKILL.md` | codex=`.agents/skills/execution-environment/SKILL.md` | copilot=`.github/skills/execution-environment/SKILL.md`
- Identity: byte-identical
- Proposed disposition: shared
- Objective (draft): Execution-environment brief for research, planning, preflight, execution, and orchestration.

### make-skill-template

- Presence: claude=`.claude/skills/make-skill-template/SKILL.md` | codex=`.agents/skills/make-skill-template/SKILL.md` | copilot=`.github/skills/make-skill-template/SKILL.md`
- Identity: wording-only
- Proposed disposition: shared
- Objective (draft): Create new Agent Skills for GitHub Copilot from prompts or by duplicating this template.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-make-skill-template-01 | codex:.agents/skills/make-skill-template/SKILL.md#document | Copies differ only in whitespace, heading levels, or wording outside the H2 and H3 sections. | no | neutral | none | No section or rule differs; the shared body picks one form. |

### policy-audit-template-usage

- Presence: claude=`.claude/skills/policy-audit-template-usage/SKILL.md` | codex=`.agents/skills/policy-audit-template-usage/SKILL.md` | copilot=`.github/skills/policy-audit-template-usage/SKILL.md`
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Policy audit template usage and output requirements.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-policy-audit-template-usage-01 | codex:.agents/skills/policy-audit-template-usage/SKILL.md#frontmatter | The frontmatter `description` differs between copies. | no | neutral | none | Equal intent in different words; the shared body selects one description. |
| D-policy-audit-template-usage-02 | codex:.agents/skills/policy-audit-template-usage/SKILL.md#Template Source | Section `Template Source` is worded differently in copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-policy-audit-template-usage-03 | codex:.agents/skills/policy-audit-template-usage/SKILL.md#Required Steps | Section `Required Steps` is worded differently in copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

### policy-compliance-order

- Presence: claude=`.claude/skills/policy-compliance-order/SKILL.md` | codex=`.agents/skills/policy-compliance-order/SKILL.md` | copilot=`.github/skills/policy-compliance-order/SKILL.md`
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Repository policy compliance order and hard constraints.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-policy-compliance-order-01 | codex:.agents/skills/policy-compliance-order/SKILL.md#Required Policy Reading Order (Baseline) | Section `Required Policy Reading Order (Baseline)` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-policy-compliance-order-02 | codex:.agents/skills/policy-compliance-order/SKILL.md#Hard Constraints (Baseline) | Section `Hard Constraints (Baseline)` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

### skill-canonical-location-audit

- Presence: claude=`.claude/skills/skill-canonical-location-audit/SKILL.md` | codex=`.agents/skills/skill-canonical-location-audit/SKILL.md` | copilot=`.github/skills/skill-canonical-location-audit/SKILL.md`
- Identity: wording-only
- Proposed disposition: shared
- Objective (draft): Audit skills for canonical-location duplication.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-skill-canonical-location-audit-01 | codex:.agents/skills/skill-canonical-location-audit/SKILL.md#Scope | Section `Scope` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

### test-execution-policy

- Presence: claude=`.claude/skills/test-execution-policy/SKILL.md` | codex=`.agents/skills/test-execution-policy/SKILL.md` | copilot=`.github/skills/test-execution-policy/SKILL.md`
- Identity: byte-identical
- Proposed disposition: shared
- Objective (draft): Test-execution policy and launcher.

