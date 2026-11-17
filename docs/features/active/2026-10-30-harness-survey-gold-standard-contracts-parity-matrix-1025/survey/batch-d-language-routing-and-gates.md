# Batch D: Language Routing and Gates (Issue #1025)

Per-skill records in the shape of spec `### Survey Records`. Each copy was read; a section missing from one copy was searched for as a heading across that ecosystem's agent bodies, rules, instructions and sibling skills before it was recorded as missing. Classes and port directions are proposals for the owner approval artifact `difference-approval.md`.

### csharp-change-budget-router

- Presence: claude=`.claude/skills/csharp-change-budget-router/SKILL.md` | codex=`.agents/skills/csharp-change-budget-router/SKILL.md` | copilot=`.github/skills/csharp-change-budget-router/SKILL.md`
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Budget-first routing contract for C# work: estimate production-file scope, choose small vs large path, enforce orchestration-first routing for larger changes, and use the VS Code extension command surface for promotion lifecycle steps when available.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-csharp-change-budget-router-01 | codex:.agents/skills/csharp-change-budget-router/SKILL.md#Orchestrated Small-Path Requirements | Section `Orchestrated Small-Path Requirements` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-csharp-change-budget-router-02 | codex:.agents/skills/csharp-change-budget-router/SKILL.md#Direct-Mode Rejection Rule | Section `Direct-Mode Rejection Rule` is worded differently in copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-csharp-change-budget-router-03 | codex:.agents/skills/csharp-change-budget-router/SKILL.md#Invocation Mode | Section `Invocation Mode` is present in codex and absent from the copilot copy of the skill. | no | neutral | none | The copilot copy is proposed dropped in favor of the shared .agents copy, so no port to it is needed. |
| D-csharp-change-budget-router-04 | codex:.agents/skills/csharp-change-budget-router/SKILL.md#Per-Batch Cap | Section `Per-Batch Cap` is present in codex and absent from the copilot copy of the skill. | no | neutral | none | The copilot copy is proposed dropped in favor of the shared .agents copy, so no port to it is needed. |
| D-csharp-change-budget-router-05 | codex:.agents/skills/csharp-change-budget-router/SKILL.md#Orchestrator-Mode Delegation Chain | Section `Orchestrator-Mode Delegation Chain` is present in codex and absent from the copilot copy of the skill. | no | neutral | none | The copilot copy is proposed dropped in favor of the shared .agents copy, so no port to it is needed. |

### csharp-orchestration-state-machine

- Presence: claude=`.claude/skills/csharp-orchestration-state-machine/SKILL.md` | codex=`.agents/skills/csharp-orchestration-state-machine/SKILL.md` | copilot=`.github/skills/csharp-orchestration-state-machine/SKILL.md`
- Identity: wording-only
- Proposed disposition: shared
- Objective (draft): Checkpoint schema and resume protocol for long-running C# orchestration workflows.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-csharp-orchestration-state-machine-01 | codex:.agents/skills/csharp-orchestration-state-machine/SKILL.md#Canonical Checkpoint Location | Section `Canonical Checkpoint Location` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

### csharp-qa-gate

- Presence: claude=`.claude/skills/csharp-qa-gate/SKILL.md` | codex=`.agents/skills/csharp-qa-gate/SKILL.md` | copilot=absent
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Final QA gate for C# changes.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-csharp-qa-gate-01 | codex:.agents/skills/csharp-qa-gate/SKILL.md#frontmatter | The frontmatter `description` differs between copies. | no | neutral | none | Equal intent in different words; the shared body selects one description. |
| D-csharp-qa-gate-02 | codex:.agents/skills/csharp-qa-gate/SKILL.md#Toolchain Execution Sequence | Section `Toolchain Execution Sequence` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-csharp-qa-gate-03 | codex:.agents/skills/csharp-qa-gate/SKILL.md#Delta Requirements (Zero-Regression Hard Gate) | Section `Delta Requirements (Zero-Regression Hard Gate)` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-csharp-qa-gate-04 | codex:.agents/skills/csharp-qa-gate/SKILL.md#Required Reporting Block | Section `Required Reporting Block` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-csharp-qa-gate-05 | codex:.agents/skills/csharp-qa-gate/SKILL.md#Evidence Storage | Section `Evidence Storage` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-csharp-qa-gate-06 | codex:.agents/skills/csharp-qa-gate/SKILL.md#Test-Execution Launcher | Section `Test-Execution Launcher` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

### invoke-csharp-engineer

- Presence: claude=`.claude/skills/invoke-csharp-engineer/SKILL.md` | codex=`.agents/skills/invoke-csharp-engineer/SKILL.md` | copilot=absent
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Invoke the csharp-typed-engineer worker to design, implement, and verify C# changes within typed repository boundaries.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-invoke-csharp-engineer-01 | codex:.agents/skills/invoke-csharp-engineer/SKILL.md#frontmatter | The frontmatter `description` differs between copies. | no | neutral | none | Equal intent in different words; the shared body selects one description. |
| D-invoke-csharp-engineer-02 | codex:.agents/skills/invoke-csharp-engineer/SKILL.md#Output Paths | Section `Output Paths` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-csharp-engineer-03 | codex:.agents/skills/invoke-csharp-engineer/SKILL.md#Preloaded Contracts | Section `Preloaded Contracts` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-csharp-engineer-04 | codex:.agents/skills/invoke-csharp-engineer/SKILL.md#Test-Execution Launcher | Section `Test-Execution Launcher` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-csharp-engineer-05 | claude:.claude/skills/invoke-csharp-engineer/SKILL.md#Delegation Identity Lines | Section `Delegation Identity Lines` is present in claude and absent from the codex copy, with no equivalent heading elsewhere in that ecosystem. | no | positive | claude->codex | Adds guidance that serves the objective; port it so every expression carries it. |

### invoke-powershell-engineer

- Presence: claude=`.claude/skills/invoke-powershell-engineer/SKILL.md` | codex=`.agents/skills/invoke-powershell-engineer/SKILL.md` | copilot=absent
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Invoke the powershell-typed-engineer worker to design, implement, and verify PowerShell changes within typed repository boundaries.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-invoke-powershell-engineer-01 | codex:.agents/skills/invoke-powershell-engineer/SKILL.md#frontmatter | The frontmatter `description` differs between copies. | no | neutral | none | Equal intent in different words; the shared body selects one description. |
| D-invoke-powershell-engineer-02 | codex:.agents/skills/invoke-powershell-engineer/SKILL.md#When to Use This Skill | Section `When to Use This Skill` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-powershell-engineer-03 | codex:.agents/skills/invoke-powershell-engineer/SKILL.md#Output Paths | Section `Output Paths` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-powershell-engineer-04 | codex:.agents/skills/invoke-powershell-engineer/SKILL.md#Preloaded Contracts | Section `Preloaded Contracts` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-powershell-engineer-05 | codex:.agents/skills/invoke-powershell-engineer/SKILL.md#Test-Execution Launcher | Section `Test-Execution Launcher` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-powershell-engineer-06 | claude:.claude/skills/invoke-powershell-engineer/SKILL.md#Delegation Identity Lines | Section `Delegation Identity Lines` is present in claude and absent from the codex copy, with no equivalent heading elsewhere in that ecosystem. | no | positive | claude->codex | Adds guidance that serves the objective; port it so every expression carries it. |

### invoke-python-engineer

- Presence: claude=`.claude/skills/invoke-python-engineer/SKILL.md` | codex=`.agents/skills/invoke-python-engineer/SKILL.md` | copilot=absent
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Invoke the python-typed-engineer worker to design, implement, and verify Python changes within typed repository boundaries.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-invoke-python-engineer-01 | codex:.agents/skills/invoke-python-engineer/SKILL.md#frontmatter | The frontmatter `description` differs between copies. | no | neutral | none | Equal intent in different words; the shared body selects one description. |
| D-invoke-python-engineer-02 | codex:.agents/skills/invoke-python-engineer/SKILL.md#When to Use This Skill | Section `When to Use This Skill` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-python-engineer-03 | codex:.agents/skills/invoke-python-engineer/SKILL.md#Output Paths | Section `Output Paths` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-python-engineer-04 | codex:.agents/skills/invoke-python-engineer/SKILL.md#Preloaded Contracts | Section `Preloaded Contracts` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-python-engineer-05 | codex:.agents/skills/invoke-python-engineer/SKILL.md#Test-Execution Launcher | Section `Test-Execution Launcher` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-invoke-python-engineer-06 | claude:.claude/skills/invoke-python-engineer/SKILL.md#Delegation Identity Lines | Section `Delegation Identity Lines` is present in claude and absent from the codex copy, with no equivalent heading elsewhere in that ecosystem. | no | positive | claude->codex | Adds guidance that serves the objective; port it so every expression carries it. |

### powershell-change-budget-router

- Presence: claude=`.claude/skills/powershell-change-budget-router/SKILL.md` | codex=`.agents/skills/powershell-change-budget-router/SKILL.md` | copilot=`.github/skills/powershell-change-budget-router/SKILL.md`
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Budget-first routing contract for PowerShell work: estimate production-file scope, choose small vs large path, enforce direct-mode escalation to orchestrator, and use the VS Code extension command surface for promotion lifecycle steps when available.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-powershell-change-budget-router-01 | codex:.agents/skills/powershell-change-budget-router/SKILL.md#Canonical Routing Rules | Section `Canonical Routing Rules` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-powershell-change-budget-router-02 | codex:.agents/skills/powershell-change-budget-router/SKILL.md#Orchestrated Small-Path Requirements | Section `Orchestrated Small-Path Requirements` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-powershell-change-budget-router-03 | codex:.agents/skills/powershell-change-budget-router/SKILL.md#Direct-Mode Rejection Rule | Section `Direct-Mode Rejection Rule` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

### powershell-orchestration-state-machine

- Presence: claude=`.claude/skills/powershell-orchestration-state-machine/SKILL.md` | codex=`.agents/skills/powershell-orchestration-state-machine/SKILL.md` | copilot=`.github/skills/powershell-orchestration-state-machine/SKILL.md`
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Checkpoint schema and resume protocol for long-running PowerShell orchestration workflows.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-powershell-orchestration-state-machine-01 | codex:.agents/skills/powershell-orchestration-state-machine/SKILL.md#Canonical Checkpoint Location | Section `Canonical Checkpoint Location` is worded differently in claude and copilot than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-powershell-orchestration-state-machine-02 | claude:.claude/skills/powershell-orchestration-state-machine/SKILL.md#Portable Prepared-State Projection | Section `Portable Prepared-State Projection` is present in claude and absent from the codex copy, with no equivalent heading elsewhere in that ecosystem. | no | positive | claude->codex | Adds guidance that serves the objective; port it so every expression carries it. |
| D-powershell-orchestration-state-machine-03 | claude:.claude/skills/powershell-orchestration-state-machine/SKILL.md#Portable Prepared-State Projection | Section `Portable Prepared-State Projection` is present in claude and absent from the copilot copy of the skill. | no | neutral | none | The copilot copy is proposed dropped in favor of the shared .agents copy, so no port to it is needed. |

### powershell-qa-gate

- Presence: claude=`.claude/skills/powershell-qa-gate/SKILL.md` | codex=`.agents/skills/powershell-qa-gate/SKILL.md` | copilot=absent
- Identity: wording-only
- Proposed disposition: shared
- Objective (draft): Final QA gate for PowerShell changes.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-powershell-qa-gate-01 | codex:.agents/skills/powershell-qa-gate/SKILL.md#frontmatter | The frontmatter `description` differs between copies. | no | neutral | none | Equal intent in different words; the shared body selects one description. |
| D-powershell-qa-gate-02 | codex:.agents/skills/powershell-qa-gate/SKILL.md#Delta Requirements (Zero-Regression Hard Gate) | Section `Delta Requirements (Zero-Regression Hard Gate)` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-powershell-qa-gate-03 | codex:.agents/skills/powershell-qa-gate/SKILL.md#Evidence Storage | Section `Evidence Storage` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-powershell-qa-gate-04 | codex:.agents/skills/powershell-qa-gate/SKILL.md#Prohibited Shortcuts | Section `Prohibited Shortcuts` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-powershell-qa-gate-05 | codex:.agents/skills/powershell-qa-gate/SKILL.md#Test-Execution Launcher | Section `Test-Execution Launcher` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

### python-change-budget-router

- Presence: claude=`.claude/skills/python-change-budget-router/SKILL.md` | codex=`.agents/skills/python-change-budget-router/SKILL.md` | copilot=absent
- Identity: substantive
- Proposed disposition: shared
- Objective (draft): Budget-first routing contract for Python work.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-python-change-budget-router-01 | codex:.agents/skills/python-change-budget-router/SKILL.md#Canonical Routing Rules | Section `Canonical Routing Rules` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-python-change-budget-router-02 | codex:.agents/skills/python-change-budget-router/SKILL.md#Direct-Mode Rejection Rule | Section `Direct-Mode Rejection Rule` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-python-change-budget-router-03 | codex:.agents/skills/python-change-budget-router/SKILL.md#Orchestrated Small-Path Requirements | Section `Orchestrated Small-Path Requirements` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

### python-qa-gate

- Presence: claude=`.claude/skills/python-qa-gate/SKILL.md` | codex=`.agents/skills/python-qa-gate/SKILL.md` | copilot=absent
- Identity: wording-only
- Proposed disposition: shared
- Objective (draft): Final QA gate for Python changes.

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-python-qa-gate-01 | codex:.agents/skills/python-qa-gate/SKILL.md#frontmatter | The frontmatter `description` differs between copies. | no | neutral | none | Equal intent in different words; the shared body selects one description. |
| D-python-qa-gate-02 | codex:.agents/skills/python-qa-gate/SKILL.md#Toolchain Execution Sequence | Section `Toolchain Execution Sequence` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-python-qa-gate-03 | codex:.agents/skills/python-qa-gate/SKILL.md#Delta Requirements (Zero-Regression Hard Gate) | Section `Delta Requirements (Zero-Regression Hard Gate)` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-python-qa-gate-04 | codex:.agents/skills/python-qa-gate/SKILL.md#Evidence Storage | Section `Evidence Storage` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |
| D-python-qa-gate-05 | codex:.agents/skills/python-qa-gate/SKILL.md#Test-Execution Launcher | Section `Test-Execution Launcher` is worded differently in claude than in codex. | no | neutral | none | The section exists in every copy; the shared body reconciles the wording against the objective. |

