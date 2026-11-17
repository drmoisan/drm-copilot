# Source Comparison — All 65 Contracts (Issue 1025, remediation cycle 2, [P1-T6])

Timestamp: 2026-11-17T05-30
Head: c20fbd453fb88881dbf31ccf604083436e6fef0f (working tree after [P1-T1] to [P1-T5])
Command: `pwsh -NoProfile -File SCRATCH/issue-1025-sweep.ps1 -Root <worktree> -Dispositions SCRATCH/issue-1025-sweep-dispositions.tsv -OutRows SCRATCH/issue-1025-sweep-rows.md` (run by `sh SCRATCH/issue-1025-sweep-write.sh`)
EXIT_CODE: 0
Output Summary: OB_ROWS=262 AC_ROWS=327 TOTAL=589 AC_NON_TEMPLATE=0;COUNT accepted=501;COUNT fixed-P1-T1=10;COUNT fix-required=56;COUNT fixed-P1-T2=9;COUNT fixed-P1-T4=4;COUNT fixed-P1-T3=8;COUNT fixed-P1-T5=1;FIX_REQUIRED_OB=56;UNUSED_KEYS=;

## Method

- OB rows: each Observable Behavior item of each `.agents/skills/<name>/references/standard.md` was read against the `## <Heading>` section of `.agents/skills/<name>/SKILL.md` that its per-behavior AC names (the reviewer's source-comparison method), and judged with the plan's `## Defect Class Tests` (R1 to R5 and the accepted forms). The script confirms that each source heading exists in the SKILL.md. Items not listed in the disposition data take the default disposition `accepted` with the reason "CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail."; every item named as a candidate in [P1-T6] carries an explicit reasoned disposition.
- AC rows: an AC row is `accepted` when its text is one of the two template forms, its per-behavior form names the heading of its cited OB, and the closing AC cites every OB (checked mechanically).
- Dispositions: `fixed-P1-T<M>` for the 32 items fixed in [P1-T1] to [P1-T5]; `fix-required` only with the failing class test stated; `accepted` with its reason.
- Reviewer CR-12 boundary: the inputs accept 45 complete-sentence items that copy one rule of a multi-rule section. A row here is `fix-required` only when a class test fails and the reason names it (plan [P1-T6]); items that are complete sentences stating one real rule stay `accepted`.

## Per-Disposition Count Summary

| Disposition | Rows |
| --- | --- |
| accepted | 501 |
| fixed-P1-T1 | 10 |
| fix-required | 56 |
| fixed-P1-T2 | 9 |
| fixed-P1-T4 | 4 |
| fixed-P1-T3 | 8 |
| fixed-P1-T5 | 1 |
| Total | 589 |

OB rows: 262; AC rows: 327; AC rows not in a template form: 0; `fix-required` OB rows: 56; rows without a reason: 0.

## Rows

| Contract | Id | Source heading | Class | Disposition | Reason |
| --- | --- | --- | --- | --- | --- |
| acceptance-criteria-tracking | OB-1 | `## AC Source Resolution (by Work Mode)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| acceptance-criteria-tracking | OB-2 | `## AC Identification` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| acceptance-criteria-tracking | OB-3 | `## Check-Off Protocol` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| acceptance-criteria-tracking | OB-4 | `## AC Status Summary (Required at Completion)` | R3 | fixed-P1-T1 | CR-9 named item: was a noun phrase naming one of two report locations; rewritten in [P1-T1]. |
| acceptance-criteria-tracking | AC-1 | AC Source Resolution (by Work Mode) | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| acceptance-criteria-tracking | AC-2 | AC Identification | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| acceptance-criteria-tracking | AC-3 | Check-Off Protocol | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| acceptance-criteria-tracking | AC-4 | AC Status Summary (Required at Completion) | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| acceptance-criteria-tracking | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| adjudicate-unspecified-behavior | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: "These are ..." is a demonstrative reference to the input table, which the item does not contain; R4 also fails, because the section enumerates the inputs and the item names none. |
| adjudicate-unspecified-behavior | OB-2 | `## Routing` | R3 | fix-required | R3 fails: label-and-value "Logical role: ..." naming one of several rules of a multi-rule section (root-owned launch, resolver selection, no self-launch, zero production writes); the single-value acceptance does not apply. |
| adjudicate-unspecified-behavior | OB-3 | `## Exact output boundary` | R3 | fix-required | R3 fails: "These rows are ..." is a demonstrative reference to the artifact-kind table, which the item does not contain; R4 also fails, because the section enumerates the artifact kinds and the item names none. |
| adjudicate-unspecified-behavior | OB-4 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule (malformed configuration blocks delegation) of the Prerequisites section. |
| adjudicate-unspecified-behavior | OB-5 | `## Step-by-Step Workflows` | none | accepted | CR-12: complete sentence stating one real step of the workflow, worded as a step rather than as the whole workflow (same form as the accepted pr-base-branch-merge-base OB-2). |
| adjudicate-unspecified-behavior | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| adjudicate-unspecified-behavior | AC-2 | Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| adjudicate-unspecified-behavior | AC-3 | Exact output boundary | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| adjudicate-unspecified-behavior | AC-4 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| adjudicate-unspecified-behavior | AC-5 | Step-by-Step Workflows | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| adjudicate-unspecified-behavior | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| atomic-plan-contract | OB-1 | `## Canonical Plan Format` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| atomic-plan-contract | OB-2 | `## Design-Level Plan Contract (Mandatory)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| atomic-plan-contract | OB-3 | `## Process-Reduction Ledger` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| atomic-plan-contract | OB-4 | `## Short-Path Minimal Plan Contract` | R3 | fixed-P1-T1 | CR-9 named item: was an ordinal fragment; rewritten in [P1-T1] with all four blocks. |
| atomic-plan-contract | OB-5 | `## Minimal-Audit Directive Contract (Small Path)` | R3 | fixed-P1-T1 | CR-9 named item: was a bare directive token; rewritten in [P1-T1] with every planner output. |
| atomic-plan-contract | AC-1 | Canonical Plan Format | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| atomic-plan-contract | AC-2 | Design-Level Plan Contract (Mandatory) | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| atomic-plan-contract | AC-3 | Process-Reduction Ledger | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| atomic-plan-contract | AC-4 | Short-Path Minimal Plan Contract | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| atomic-plan-contract | AC-5 | Minimal-Audit Directive Contract (Small Path) | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| atomic-plan-contract | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| characterize-runtime-behavior | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: "These are ..." is a demonstrative reference to the input table, which the item does not contain; R4 also fails, because the section enumerates the inputs and the item names none. |
| characterize-runtime-behavior | OB-2 | `## Routing` | R3 | fix-required | R3 fails: label-and-value "Logical role: ..." naming one of several rules of a multi-rule section (root-owned launch, resolver selection, no self-launch, zero production writes); the single-value acceptance does not apply. |
| characterize-runtime-behavior | OB-3 | `## Exact output boundary` | R3 | fix-required | R3 fails: "These rows are ..." is a demonstrative reference to the artifact-kind table, which the item does not contain; R4 also fails, because the section enumerates the artifact kinds and the item names none. |
| characterize-runtime-behavior | OB-4 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule (malformed configuration blocks delegation) of the Prerequisites section. |
| characterize-runtime-behavior | OB-5 | `## Step-by-Step Workflows` | none | accepted | CR-12: complete sentence stating one real step of the workflow, worded as a step rather than as the whole workflow (same form as the accepted pr-base-branch-merge-base OB-2). |
| characterize-runtime-behavior | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| characterize-runtime-behavior | AC-2 | Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| characterize-runtime-behavior | AC-3 | Exact output boundary | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| characterize-runtime-behavior | AC-4 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| characterize-runtime-behavior | AC-5 | Step-by-Step Workflows | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| characterize-runtime-behavior | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| commit-message | OB-1 | `## Inputs` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| commit-message | OB-2 | `## Context Gathering` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| commit-message | OB-3 | `## Classification` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| commit-message | OB-4 | `## Message Format` | R3 | fix-required | R3 fails: label-and-value naming the header rules only, while the section also requires one fenced text block and body and reference rules. |
| commit-message | OB-5 | `## Prohibitions` | R3 | fix-required | R3 fails: noun phrase with no finite verb naming one of six prohibitions; R4 also fails. |
| commit-message | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| commit-message | AC-2 | Context Gathering | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| commit-message | AC-3 | Classification | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| commit-message | AC-4 | Message Format | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| commit-message | AC-5 | Prohibitions | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| commit-message | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| csharp-change-budget-router | OB-1 | `## Canonical Routing Rules` | R4 | fix-required | R4 fails: the section estimates the budget and then routes to a small or a large path, and the item names the small-path rule only, as a label-and-value. |
| csharp-change-budget-router | OB-2 | `## Orchestrated Small-Path Requirements` | none | accepted | CR-12: complete sentence stating the tool-neutral lifecycle rule (cycle 1 rewrite). |
| csharp-change-budget-router | OB-3 | `## Direct-Mode Rejection Rule` | none | accepted | CR-12: complete imperative sentence stating the rejection rule its heading names. |
| csharp-change-budget-router | OB-4 | `## Invocation Mode` | R4 | fix-required | R4 fails: the section defines two modes and the handoff-mode context package, and the item names direct mode only, as a label-and-value. |
| csharp-change-budget-router | OB-5 | `## Per-Batch Cap` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| csharp-change-budget-router | AC-1 | Canonical Routing Rules | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| csharp-change-budget-router | AC-2 | Orchestrated Small-Path Requirements | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| csharp-change-budget-router | AC-3 | Direct-Mode Rejection Rule | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| csharp-change-budget-router | AC-4 | Invocation Mode | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| csharp-change-budget-router | AC-5 | Per-Batch Cap | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| csharp-change-budget-router | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| csharp-orchestration-state-machine | OB-1 | `## Canonical Checkpoint Location` | none | accepted | Label-and-value naming the single required value of a single-valued section: one checkpoint path. |
| csharp-orchestration-state-machine | OB-2 | `## Required Checkpoint Fields` | R4 | fixed-P1-T2 | CR-10 named item: one of the required checkpoint fields; rewritten in [P1-T2]. |
| csharp-orchestration-state-machine | OB-3 | `## Update Protocol` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| csharp-orchestration-state-machine | OB-4 | `## Resume Protocol` | R3 | fixed-P1-T1 | D-C2-1: ordinal-fragment form; rewritten in [P1-T1] as one sentence with all four steps. |
| csharp-orchestration-state-machine | AC-1 | Canonical Checkpoint Location | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| csharp-orchestration-state-machine | AC-2 | Required Checkpoint Fields | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| csharp-orchestration-state-machine | AC-3 | Update Protocol | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| csharp-orchestration-state-machine | AC-4 | Resume Protocol | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| csharp-orchestration-state-machine | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| csharp-qa-gate | OB-1 | `## Required Inputs` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| csharp-qa-gate | OB-2 | `## Toolchain Execution Sequence` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| csharp-qa-gate | OB-3 | `## Delta Requirements (Zero-Regression Hard Gate)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| csharp-qa-gate | OB-4 | `## Required Reporting Block` | R4 | fix-required | R4 fails: the section requires five reporting sections and the item names Scope only, as a label-and-value. |
| csharp-qa-gate | OB-5 | `## Evidence Storage` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| csharp-qa-gate | AC-1 | Required Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| csharp-qa-gate | AC-2 | Toolchain Execution Sequence | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| csharp-qa-gate | AC-3 | Delta Requirements (Zero-Regression Hard Gate) | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| csharp-qa-gate | AC-4 | Required Reporting Block | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| csharp-qa-gate | AC-5 | Evidence Storage | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| csharp-qa-gate | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| discovery-behavior-reconciliation | OB-1 | `## Inputs` | none | accepted | CR-12: complete sentence; the section has one input row (forwarded unchanged) and "all other" means every input besides the dispatch selection the contract states in OB-2. |
| discovery-behavior-reconciliation | OB-2 | `## Dispatch` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-behavior-reconciliation | OB-3 | `## Stop and result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-behavior-reconciliation | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| discovery-behavior-reconciliation | AC-2 | Dispatch | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| discovery-behavior-reconciliation | AC-3 | Stop and result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| discovery-behavior-reconciliation | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| discovery-coverage-ledger | OB-1 | `## Inputs` | none | accepted | CR-12: complete sentence; the section has one input row (forwarded unchanged) and "all other" means every input besides the dispatch selection the contract states in OB-2. |
| discovery-coverage-ledger | OB-2 | `## Dispatch` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-coverage-ledger | OB-3 | `## Stop and result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-coverage-ledger | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| discovery-coverage-ledger | AC-2 | Dispatch | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| discovery-coverage-ledger | AC-3 | Stop and result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| discovery-coverage-ledger | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| discovery-parity-matrix | OB-1 | `## Inputs` | none | accepted | CR-12: complete sentence; the section has one input row (forwarded unchanged) and "all other" means every input besides the dispatch selection the contract states in OB-2. |
| discovery-parity-matrix | OB-2 | `## Dispatch` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-parity-matrix | OB-3 | `## Stop and result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-parity-matrix | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| discovery-parity-matrix | AC-2 | Dispatch | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| discovery-parity-matrix | AC-3 | Stop and result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| discovery-parity-matrix | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| discovery-repo-inventory | OB-1 | `## Inputs` | none | accepted | CR-12: complete sentence; the section has one input row (forwarded unchanged) and "all other" means every input besides the dispatch selection the contract states in OB-2. |
| discovery-repo-inventory | OB-2 | `## Dispatch` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-repo-inventory | OB-3 | `## Stop and result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-repo-inventory | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| discovery-repo-inventory | AC-2 | Dispatch | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| discovery-repo-inventory | AC-3 | Stop and result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| discovery-repo-inventory | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| discovery-runtime-characterization | OB-1 | `## Inputs` | none | accepted | CR-12: complete sentence; the section has one input row (forwarded unchanged) and "all other" means every input besides the dispatch selection the contract states in OB-2. |
| discovery-runtime-characterization | OB-2 | `## Dispatch` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-runtime-characterization | OB-3 | `## Stop and result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-runtime-characterization | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| discovery-runtime-characterization | AC-2 | Dispatch | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| discovery-runtime-characterization | AC-3 | Stop and result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| discovery-runtime-characterization | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| discovery-validate-artifacts | OB-1 | `## Inputs` | none | accepted | CR-12: complete sentence; the section has one input row (forwarded unchanged) and "all other" means every input besides the dispatch selection the contract states in OB-2. |
| discovery-validate-artifacts | OB-2 | `## Dispatch` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-validate-artifacts | OB-3 | `## Stop and result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-validate-artifacts | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| discovery-validate-artifacts | AC-2 | Dispatch | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| discovery-validate-artifacts | AC-3 | Stop and result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| discovery-validate-artifacts | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| discovery-workflow | OB-1 | `## Inputs` | none | accepted | CR-12: complete sentence; the section has one input row (forwarded unchanged) and "all other" means every input besides the dispatch selection the contract states in OB-2. |
| discovery-workflow | OB-2 | `## Dispatch` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-workflow | OB-3 | `## Stop and result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| discovery-workflow | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| discovery-workflow | AC-2 | Dispatch | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| discovery-workflow | AC-3 | Stop and result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| discovery-workflow | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| docs-author-page | OB-1 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-author-page | OB-2 | `## Templates` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-author-page | OB-3 | `## Steps` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-author-page | OB-4 | `## Result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-author-page | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| docs-author-page | AC-2 | Templates | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| docs-author-page | AC-3 | Steps | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| docs-author-page | AC-4 | Result | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| docs-author-page | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| docs-init | OB-1 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-init | OB-2 | `## Steps` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-init | OB-3 | `## Linter Configuration` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-init | OB-4 | `## Result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-init | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| docs-init | AC-2 | Steps | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| docs-init | AC-3 | Linter Configuration | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| docs-init | AC-4 | Result | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| docs-init | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| docs-inventory-surface | OB-1 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-inventory-surface | OB-2 | `## Steps` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-inventory-surface | OB-3 | `## Result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-inventory-surface | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| docs-inventory-surface | AC-2 | Steps | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| docs-inventory-surface | AC-3 | Result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| docs-inventory-surface | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| docs-plan-ia | OB-1 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-plan-ia | OB-2 | `## Steps` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-plan-ia | OB-3 | `## Result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-plan-ia | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| docs-plan-ia | AC-2 | Steps | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| docs-plan-ia | AC-3 | Result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| docs-plan-ia | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| docs-reconcile-behavior | OB-1 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-reconcile-behavior | OB-2 | `## Steps` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-reconcile-behavior | OB-3 | `## Result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-reconcile-behavior | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| docs-reconcile-behavior | AC-2 | Steps | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| docs-reconcile-behavior | AC-3 | Result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| docs-reconcile-behavior | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| docs-review-coverage | OB-1 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-review-coverage | OB-2 | `## Steps` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-review-coverage | OB-3 | `## Result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-review-coverage | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| docs-review-coverage | AC-2 | Steps | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| docs-review-coverage | AC-3 | Result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| docs-review-coverage | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| docs-validate | OB-1 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-validate | OB-2 | `## Steps` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-validate | OB-3 | `## Result` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| docs-validate | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| docs-validate | AC-2 | Steps | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| docs-validate | AC-3 | Result | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| docs-validate | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| documentation-workflow | OB-1 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| documentation-workflow | OB-2 | `## Dispatch Order` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| documentation-workflow | OB-3 | `## Rules` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| documentation-workflow | OB-4 | `## Commit, Receipt and Pull Request` | none | accepted | CR-12: complete sentence; "this stage" is the commit, receipt and pull-request stage that the item's own heading names. |
| documentation-workflow | OB-5 | `## Refresh After Rebase or Source Change` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| documentation-workflow | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| documentation-workflow | AC-2 | Dispatch Order | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| documentation-workflow | AC-3 | Rules | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| documentation-workflow | AC-4 | Commit, Receipt and Pull Request | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| documentation-workflow | AC-5 | Refresh After Rebase or Source Change | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| documentation-workflow | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| epic-orchestrate | OB-1 | `## Early Dependent Starts (early_start)` | none | accepted | CR-12: complete sentence; "This section" is the early-start section that the item's own heading names. |
| epic-orchestrate | OB-2 | `## Cross-Epic Dependencies (cross_epic_depends_on)` | none | accepted | CR-12: complete sentence; "This section" is the cross-epic section that the item's own heading names. |
| epic-orchestrate | OB-3 | `## Worktree Cleanup` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| epic-orchestrate | AC-1 | Early Dependent Starts (early_start) | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| epic-orchestrate | AC-2 | Cross-Epic Dependencies (cross_epic_depends_on) | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| epic-orchestrate | AC-3 | Worktree Cleanup | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| epic-orchestrate | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| epic-plan | OB-1 | `## Prerequisites` | R5 | fixed-P1-T4 | CR-11 named item: stated through a standing-instruction file name and policy-mirror path; rewritten in [P1-T4]. |
| epic-plan | OB-2 | `## Epic-Worthiness Gate` | R3 | fix-required | R3 fails: "It" refers to an objective the item does not name; R4 also fails, because the gate has two conditions and the item names the first only. |
| epic-plan | OB-3 | `## Decomposition and Wave Design` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| epic-plan | OB-4 | `## Preparation Worktree Records` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| epic-plan | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| epic-plan | AC-2 | Epic-Worthiness Gate | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| epic-plan | AC-3 | Decomposition and Wave Design | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| epic-plan | AC-4 | Preparation Worktree Records | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| epic-plan | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| epic-run | OB-1 | `## Procedure` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| epic-run | AC-1 | Procedure | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| epic-run | AC-2 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| evidence-and-timestamp-conventions | OB-1 | `## Non-Overridable Authority` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| evidence-and-timestamp-conventions | OB-2 | `## ISO-8601 Timestamp Format` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| evidence-and-timestamp-conventions | OB-3 | `## Canonical Evidence Locations` | R4 | fixed-P1-T2 | CR-10 named item: one of five locations; rewritten in [P1-T2]. |
| evidence-and-timestamp-conventions | OB-4 | `## Feature Scope (Versioned Features)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| evidence-and-timestamp-conventions | OB-5 | `## Canonical Evidence Discovery Order` | R3 | fixed-P1-T1 | CR-9 named item: referred to a list the item did not contain; rewritten in [P1-T1]. |
| evidence-and-timestamp-conventions | AC-1 | Non-Overridable Authority | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| evidence-and-timestamp-conventions | AC-2 | ISO-8601 Timestamp Format | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| evidence-and-timestamp-conventions | AC-3 | Canonical Evidence Locations | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| evidence-and-timestamp-conventions | AC-4 | Feature Scope (Versioned Features) | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| evidence-and-timestamp-conventions | AC-5 | Canonical Evidence Discovery Order | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| evidence-and-timestamp-conventions | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| execute-hard-lock | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section requires two inputs (plan-path and work-mode) and the item names plan-path only. |
| execute-hard-lock | OB-2 | `## Invocation Flow` | R4 | fixed-P1-T3 | CR-10 named item: one of two resolver inputs; rewritten in [P1-T3]. |
| execute-hard-lock | OB-3 | `## Abort Conditions` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| execute-hard-lock | OB-4 | `## Equivalent Entry Points (Reference)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| execute-hard-lock | OB-5 | `## Delegation Contract` | R4 | fixed-P1-T3 | CR-10 named item: one of four preloaded shared skills; rewritten in [P1-T3]. |
| execute-hard-lock | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| execute-hard-lock | AC-2 | Invocation Flow | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| execute-hard-lock | AC-3 | Abort Conditions | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| execute-hard-lock | AC-4 | Equivalent Entry Points (Reference) | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| execute-hard-lock | AC-5 | Delegation Contract | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| execute-hard-lock | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| execution-environment | OB-1 | `## Purpose and Maintenance` | none | accepted | CR-12: complete sentence; "This brief" is the skill itself, named in the contract objective, not absent text. |
| execution-environment | OB-2 | `## Development Toolchain Baseline` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| execution-environment | OB-3 | `## Tool Routes by Agent` | none | accepted | CR-12: complete sentence stating one real rule of the section; it names an agent tool because the contract's subject is the tool routes of each agent (mechanism-subject acceptance). |
| execution-environment | OB-4 | `## Command-Text Restrictions` | none | accepted | CR-12: complete sentence; it names the command-text mechanism because the section's subject is that mechanism (mechanism-subject acceptance). |
| execution-environment | OB-5 | `## PowerShell Route and PoshQC MCP Limits` | none | accepted | CR-12: complete sentence; the section's subject is the PoshQC MCP route, so naming it is the mechanism-subject acceptance. |
| execution-environment | AC-1 | Purpose and Maintenance | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| execution-environment | AC-2 | Development Toolchain Baseline | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| execution-environment | AC-3 | Tool Routes by Agent | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| execution-environment | AC-4 | Command-Text Restrictions | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| execution-environment | AC-5 | PowerShell Route and PoshQC MCP Limits | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| execution-environment | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| extract-feature-contract | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: "These are ..." is a demonstrative reference to the input table, which the item does not contain; R4 also fails, because the section enumerates the inputs and the item names none. |
| extract-feature-contract | OB-2 | `## Routing` | R3 | fix-required | R3 fails: label-and-value "Logical role: ..." naming one of several rules of a multi-rule section (root-owned launch, resolver selection, no self-launch, zero production writes); the single-value acceptance does not apply. |
| extract-feature-contract | OB-3 | `## Exact output boundary` | R3 | fix-required | R3 fails: "These rows are ..." is a demonstrative reference to the artifact-kind table, which the item does not contain; R4 also fails, because the section enumerates the artifact kinds and the item names none. |
| extract-feature-contract | OB-4 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule (malformed configuration blocks delegation) of the Prerequisites section. |
| extract-feature-contract | OB-5 | `## Step-by-Step Workflows` | none | accepted | CR-12: complete sentence stating one real step of the workflow, worded as a step rather than as the whole workflow (same form as the accepted pr-base-branch-merge-base OB-2). |
| extract-feature-contract | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| extract-feature-contract | AC-2 | Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| extract-feature-contract | AC-3 | Exact output boundary | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| extract-feature-contract | AC-4 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| extract-feature-contract | AC-5 | Step-by-Step Workflows | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| extract-feature-contract | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| feature-promotion-lifecycle | OB-1 | `## MCP Tool Availability Preflight` | none | accepted | CR-12: complete sentence; the MCP tool availability preflight is the subject the heading names (mechanism-subject acceptance), and no tool name appears. |
| feature-promotion-lifecycle | OB-2 | `## Agent-Session Promotion Execution Rule` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| feature-promotion-lifecycle | OB-3 | `## Canonical Variables` | R4 | fixed-P1-T2 | CR-10 named item: one of eleven canonical variables; rewritten in [P1-T2]. |
| feature-promotion-lifecycle | OB-4 | `## Required Outputs for Downstream Handoffs` | R4 | fixed-P1-T2 | CR-10 named item: one of five handoff outputs; rewritten in [P1-T2]. |
| feature-promotion-lifecycle | AC-1 | MCP Tool Availability Preflight | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| feature-promotion-lifecycle | AC-2 | Agent-Session Promotion Execution Rule | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| feature-promotion-lifecycle | AC-3 | Canonical Variables | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| feature-promotion-lifecycle | AC-4 | Required Outputs for Downstream Handoffs | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| feature-promotion-lifecycle | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| feature-review-workflow | OB-1 | `## Required Shared Skills` | R4 | fixed-P1-T2 | CR-10 named item: one of seven required shared skills; rewritten in [P1-T2]. |
| feature-review-workflow | OB-2 | `## Role` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| feature-review-workflow | OB-3 | `## Workflow Contract` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| feature-review-workflow | OB-4 | `## Policy Rules` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| feature-review-workflow | OB-5 | `## Ordered Procedure` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| feature-review-workflow | AC-1 | Required Shared Skills | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| feature-review-workflow | AC-2 | Role | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| feature-review-workflow | AC-3 | Workflow Contract | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| feature-review-workflow | AC-4 | Policy Rules | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| feature-review-workflow | AC-5 | Ordered Procedure | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| feature-review-workflow | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| fill-feature-docs | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section lists two inputs and the item names the first only, as a noun phrase. |
| fill-feature-docs | OB-2 | `## Output Paths` | R4 | fixed-P1-T2 | CR-10 named item: one of two output paths; rewritten in [P1-T2]. |
| fill-feature-docs | OB-3 | `## Worker Routing` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| fill-feature-docs | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| fill-feature-docs | AC-2 | Output Paths | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| fill-feature-docs | AC-3 | Worker Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| fill-feature-docs | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| generate-acceptance-scenarios | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: "These are ..." is a demonstrative reference to the input table, which the item does not contain; R4 also fails, because the section enumerates the inputs and the item names none. |
| generate-acceptance-scenarios | OB-2 | `## Routing` | R3 | fix-required | R3 fails: label-and-value "Logical role: ..." naming one of several rules of a multi-rule section (root-owned launch, resolver selection, no self-launch, zero production writes); the single-value acceptance does not apply. |
| generate-acceptance-scenarios | OB-3 | `## Exact output boundary` | R3 | fix-required | R3 fails: "These rows are ..." is a demonstrative reference to the artifact-kind table, which the item does not contain; R4 also fails, because the section enumerates the artifact kinds and the item names none. |
| generate-acceptance-scenarios | OB-4 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule (malformed configuration blocks delegation) of the Prerequisites section. |
| generate-acceptance-scenarios | OB-5 | `## Step-by-Step Workflows` | none | accepted | CR-12: complete sentence stating one real step of the workflow, worded as a step rather than as the whole workflow (same form as the accepted pr-base-branch-merge-base OB-2). |
| generate-acceptance-scenarios | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| generate-acceptance-scenarios | AC-2 | Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| generate-acceptance-scenarios | AC-3 | Exact output boundary | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| generate-acceptance-scenarios | AC-4 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| generate-acceptance-scenarios | AC-5 | Step-by-Step Workflows | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| generate-acceptance-scenarios | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| human-exception-runbook | OB-1 | `## Canonical Path` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| human-exception-runbook | OB-2 | `## Required Sections` | R4 | fix-required | R4 fails: the section requires five ordered sections and the item names one (the cue) as a noun phrase; R3 also fails (no finite verb). |
| human-exception-runbook | OB-3 | `## Sourcing Rule (MCP-first / web-second)` | none | accepted | CR-12: complete sentence; the MCP documentation source is the subject of the MCP-first sourcing rule (mechanism-subject acceptance). |
| human-exception-runbook | OB-4 | `## Tool Command Version Rule` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| human-exception-runbook | OB-5 | `## Conformance` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| human-exception-runbook | AC-1 | Canonical Path | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| human-exception-runbook | AC-2 | Required Sections | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| human-exception-runbook | AC-3 | Sourcing Rule (MCP-first / web-second) | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| human-exception-runbook | AC-4 | Tool Command Version Rule | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| human-exception-runbook | AC-5 | Conformance | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| human-exception-runbook | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| initialize-discovery-workspace | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: "These are ..." is a demonstrative reference to the input table, which the item does not contain; R4 also fails, because the section enumerates the inputs and the item names none. |
| initialize-discovery-workspace | OB-2 | `## Routing` | R3 | fix-required | R3 fails: label-and-value "Logical role: ..." naming one of several rules of a multi-rule section (root-owned launch, resolver selection, no self-launch, zero production writes); the single-value acceptance does not apply. |
| initialize-discovery-workspace | OB-3 | `## Exact output boundary` | R3 | fix-required | R3 fails: "These rows are ..." is a demonstrative reference to the artifact-kind table, which the item does not contain; R4 also fails, because the section enumerates the artifact kinds and the item names none. |
| initialize-discovery-workspace | OB-4 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule (malformed configuration blocks delegation) of the Prerequisites section. |
| initialize-discovery-workspace | OB-5 | `## Step-by-Step Workflows` | none | accepted | CR-12: complete sentence stating one real step of the workflow, worded as a step rather than as the whole workflow (same form as the accepted pr-base-branch-merge-base OB-2). |
| initialize-discovery-workspace | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| initialize-discovery-workspace | AC-2 | Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| initialize-discovery-workspace | AC-3 | Exact output boundary | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| initialize-discovery-workspace | AC-4 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| initialize-discovery-workspace | AC-5 | Step-by-Step Workflows | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| initialize-discovery-workspace | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| inventory-legacy-system | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: "These are ..." is a demonstrative reference to the input table, which the item does not contain; R4 also fails, because the section enumerates the inputs and the item names none. |
| inventory-legacy-system | OB-2 | `## Routing` | R3 | fix-required | R3 fails: label-and-value "Logical role: ..." naming one of several rules of a multi-rule section (root-owned launch, resolver selection, no self-launch, zero production writes); the single-value acceptance does not apply. |
| inventory-legacy-system | OB-3 | `## Exact output boundary` | R3 | fix-required | R3 fails: "These rows are ..." is a demonstrative reference to the artifact-kind table, which the item does not contain; R4 also fails, because the section enumerates the artifact kinds and the item names none. |
| inventory-legacy-system | OB-4 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule (malformed configuration blocks delegation) of the Prerequisites section. |
| inventory-legacy-system | OB-5 | `## Step-by-Step Workflows` | none | accepted | CR-12: complete sentence stating one real step of the workflow, worded as a step rather than as the whole workflow (same form as the accepted pr-base-branch-merge-base OB-2). |
| inventory-legacy-system | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| inventory-legacy-system | AC-2 | Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| inventory-legacy-system | AC-3 | Exact output boundary | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| inventory-legacy-system | AC-4 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| inventory-legacy-system | AC-5 | Step-by-Step Workflows | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| inventory-legacy-system | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| invoke-csharp-engineer | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section lists five inputs and the item names the objective statement only, as a noun phrase. |
| invoke-csharp-engineer | OB-2 | `## Output Paths` | R4 | fix-required | R4 fails: the section lists source and test files, baseline and post-change evidence, and plan artifacts, and the item names the source and test files only. |
| invoke-csharp-engineer | OB-3 | `## Required Reporting Block` | R4 | fixed-P1-T3 | CR-10 named item: one of five reporting-block entries; rewritten in [P1-T3]. |
| invoke-csharp-engineer | OB-4 | `## Worker Routing` | none | accepted | Label-and-value naming the single required value of a single-valued section: Worker Routing lists one worker. |
| invoke-csharp-engineer | OB-5 | `## Preloaded Contracts` | R4 | fixed-P1-T3 | CR-10 named item: one of the preloaded contracts; rewritten in [P1-T3]. |
| invoke-csharp-engineer | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| invoke-csharp-engineer | AC-2 | Output Paths | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| invoke-csharp-engineer | AC-3 | Required Reporting Block | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| invoke-csharp-engineer | AC-4 | Worker Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| invoke-csharp-engineer | AC-5 | Preloaded Contracts | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| invoke-csharp-engineer | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| invoke-powershell-engineer | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section lists four inputs and the item names the objective statement only, as a noun phrase. |
| invoke-powershell-engineer | OB-2 | `## Output Paths` | R4 | fix-required | R4 fails: the section lists source and test files, baseline and post-change evidence, and plan artifacts, and the item names the source and test files only. |
| invoke-powershell-engineer | OB-3 | `## Required Reporting Block` | R4 | fixed-P1-T3 | CR-10 named item: one of five reporting-block entries; rewritten in [P1-T3]. |
| invoke-powershell-engineer | OB-4 | `## Worker Routing` | none | accepted | Label-and-value naming the single required value of a single-valued section: Worker Routing lists one worker. |
| invoke-powershell-engineer | OB-5 | `## Preloaded Contracts` | R4 | fixed-P1-T3 | CR-10 named item: one of the preloaded contracts; rewritten in [P1-T3]. |
| invoke-powershell-engineer | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| invoke-powershell-engineer | AC-2 | Output Paths | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| invoke-powershell-engineer | AC-3 | Required Reporting Block | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| invoke-powershell-engineer | AC-4 | Worker Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| invoke-powershell-engineer | AC-5 | Preloaded Contracts | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| invoke-powershell-engineer | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| invoke-python-engineer | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section lists four inputs and the item names the objective statement only, as a noun phrase. |
| invoke-python-engineer | OB-2 | `## Output Paths` | R4 | fix-required | R4 fails: the section lists source and test files, baseline and post-change evidence, and plan artifacts, and the item names the source and test files only. |
| invoke-python-engineer | OB-3 | `## Required Reporting Block` | R4 | fixed-P1-T3 | CR-10 named item: one of five reporting-block entries; rewritten in [P1-T3]. |
| invoke-python-engineer | OB-4 | `## Worker Routing` | none | accepted | Label-and-value naming the single required value of a single-valued section: Worker Routing lists one worker. |
| invoke-python-engineer | OB-5 | `## Preloaded Contracts` | R4 | fixed-P1-T3 | CR-10 named item: one of the preloaded contracts; rewritten in [P1-T3]. |
| invoke-python-engineer | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| invoke-python-engineer | AC-2 | Output Paths | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| invoke-python-engineer | AC-3 | Required Reporting Block | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| invoke-python-engineer | AC-4 | Worker Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| invoke-python-engineer | AC-5 | Preloaded Contracts | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| invoke-python-engineer | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| make-skill-template | OB-1 | `## Prerequisites` | R4 | fix-required | R4 fails: the section lists three prerequisites and the item names the first only, as a noun phrase; R3 also fails. |
| make-skill-template | OB-2 | `## Creating a New Skill` | none | accepted | CR-12: complete sentence stating the description rule of the section. |
| make-skill-template | OB-3 | `## Example: Complete Skill Structure` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. The AC per-behavior form names this source heading up to its first colon; AC text is outside the edit scope (Do Not Do). |
| make-skill-template | OB-4 | `## Quick Start: Duplicate This Template` | none | accepted | CR-12: complete imperative sentence stating the first real step of the quick start. The AC per-behavior form names this source heading up to its first colon; AC text is outside the edit scope (Do Not Do). |
| make-skill-template | OB-5 | `## Validation Checklist` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| make-skill-template | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| make-skill-template | AC-2 | Creating a New Skill | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| make-skill-template | AC-3 | Example | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| make-skill-template | AC-4 | Quick Start | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| make-skill-template | AC-5 | Validation Checklist | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| make-skill-template | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| orchestrate | OB-1 | `## Prerequisites` | R5 | fixed-P1-T4 | CR-11 named item: stated through a standing-instruction file name; rewritten in [P1-T4]. |
| orchestrate | OB-2 | `## Checkpoint Handling` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| orchestrate | OB-3 | `## Prepared-State Portable Handoff Intake` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| orchestrate | OB-4 | `## Preparation Mode` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| orchestrate | OB-5 | `## Autonomous-Execution Mandate` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| orchestrate | AC-1 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| orchestrate | AC-2 | Checkpoint Handling | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| orchestrate | AC-3 | Prepared-State Portable Handoff Intake | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| orchestrate | AC-4 | Preparation Mode | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| orchestrate | AC-5 | Autonomous-Execution Mandate | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| orchestrate | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| owner-directives | OB-1 | `## Framing (normative)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| owner-directives | OB-2 | `## Checkpoint Schemas` | R3 | fix-required | R3 fails: "Both keys" refers to keys the item does not name. |
| owner-directives | OB-3 | `## Directive Classes` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| owner-directives | OB-4 | `## Coordinator Procedure (Record Before Relay)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| owner-directives | OB-5 | `## Coordinator Ledger` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| owner-directives | AC-1 | Framing (normative) | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| owner-directives | AC-2 | Checkpoint Schemas | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| owner-directives | AC-3 | Directive Classes | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| owner-directives | AC-4 | Coordinator Procedure (Record Before Relay) | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| owner-directives | AC-5 | Coordinator Ledger | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| owner-directives | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| policy-audit-template-usage | OB-1 | `## Template Source` | none | accepted | CR-12: complete sentence; the resolved MCP asset is the template source the heading names (mechanism-subject acceptance), and no tool name appears. |
| policy-audit-template-usage | OB-2 | `## Required Steps` | R3 | fixed-P1-T1 | CR-9 named item: was a bare heading token; rewritten in [P1-T1] with all six steps. |
| policy-audit-template-usage | OB-3 | `## Invalid Outputs` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| policy-audit-template-usage | AC-1 | Template Source | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| policy-audit-template-usage | AC-2 | Required Steps | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| policy-audit-template-usage | AC-3 | Invalid Outputs | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| policy-audit-template-usage | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| policy-compliance-order | OB-1 | `## Required Policy Reading Order (Baseline)` | R4 | fixed-P1-T2 | CR-10 named item: named the Python rules only of the full order; rewritten in [P1-T2]. |
| policy-compliance-order | OB-2 | `## Hard Constraints (Baseline)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| policy-compliance-order | AC-1 | Required Policy Reading Order (Baseline) | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| policy-compliance-order | AC-2 | Hard Constraints (Baseline) | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| policy-compliance-order | AC-3 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| powershell-change-budget-router | OB-1 | `## Canonical Routing Rules` | R4 | fix-required | R4 fails: the section estimates the budget and then routes to a small or a large path, and the item names the small-path rule only, as a label-and-value. |
| powershell-change-budget-router | OB-2 | `## Orchestrated Small-Path Requirements` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| powershell-change-budget-router | OB-3 | `## Direct-Mode Rejection Rule` | none | accepted | CR-12: complete imperative sentence stating the rejection rule its heading names. |
| powershell-change-budget-router | OB-4 | `## Documentation Expectations` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| powershell-change-budget-router | AC-1 | Canonical Routing Rules | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| powershell-change-budget-router | AC-2 | Orchestrated Small-Path Requirements | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| powershell-change-budget-router | AC-3 | Direct-Mode Rejection Rule | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| powershell-change-budget-router | AC-4 | Documentation Expectations | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| powershell-change-budget-router | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| powershell-orchestration-state-machine | OB-1 | `## Canonical Checkpoint Location` | none | accepted | Label-and-value naming the single required value of a single-valued section: one checkpoint path. |
| powershell-orchestration-state-machine | OB-2 | `## Required Checkpoint Fields` | R4 | fixed-P1-T2 | CR-10 named item: one of the required checkpoint fields; rewritten in [P1-T2]. |
| powershell-orchestration-state-machine | OB-3 | `## Update Protocol` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| powershell-orchestration-state-machine | OB-4 | `## Resume Protocol` | R3 | fixed-P1-T1 | D-C2-1: ordinal-fragment form; rewritten in [P1-T1] as one sentence with all four steps. |
| powershell-orchestration-state-machine | AC-1 | Canonical Checkpoint Location | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| powershell-orchestration-state-machine | AC-2 | Required Checkpoint Fields | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| powershell-orchestration-state-machine | AC-3 | Update Protocol | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| powershell-orchestration-state-machine | AC-4 | Resume Protocol | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| powershell-orchestration-state-machine | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| powershell-qa-gate | OB-1 | `## Required Inputs` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| powershell-qa-gate | OB-2 | `## Toolchain Execution Sequence` | none | fixed-P1-T5 | CR-14 nit (D-C2-2): source qualifier added to the coverage step in [P1-T5]. |
| powershell-qa-gate | OB-3 | `## Delta Requirements (Zero-Regression Hard Gate)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| powershell-qa-gate | OB-4 | `## Required Reporting Block` | R4 | fix-required | R4 fails: the section requires five reporting sections and the item names Scope only, as a label-and-value. |
| powershell-qa-gate | OB-5 | `## Evidence Storage` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| powershell-qa-gate | AC-1 | Required Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| powershell-qa-gate | AC-2 | Toolchain Execution Sequence | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| powershell-qa-gate | AC-3 | Delta Requirements (Zero-Regression Hard Gate) | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| powershell-qa-gate | AC-4 | Required Reporting Block | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| powershell-qa-gate | AC-5 | Evidence Storage | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| powershell-qa-gate | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| pr-author | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section lists the summary, the appendix and optional user directives plus a citation rule, and the item names the summary only. |
| pr-author | OB-2 | `## Output Requirements` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| pr-author | OB-3 | `## PR Body Structure` | R4 | fix-required | R4 fails: the section orders eleven body sections and the item names the suggested title only, as a label-and-value. |
| pr-author | OB-4 | `## Issue/PR Reference Rules` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| pr-author | OB-5 | `## Checkpoint-Free Docs-Estate Delegation (issue #1169)` | none | accepted | CR-12: complete sentence; the documentation workflow is the subject of the section. |
| pr-author | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| pr-author | AC-2 | Output Requirements | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| pr-author | AC-3 | PR Body Structure | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| pr-author | AC-4 | Issue/PR Reference Rules | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| pr-author | AC-5 | Checkpoint-Free Docs-Estate Delegation (issue #1169) | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| pr-author | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| pr-base-branch-merge-base | OB-1 | `## Selection Contract` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| pr-base-branch-merge-base | OB-2 | `## Deterministic Procedure` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| pr-base-branch-merge-base | OB-3 | `## Guardrails` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| pr-base-branch-merge-base | OB-4 | `## Collector Invocation Rule` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| pr-base-branch-merge-base | OB-5 | `## Evidence Recommendation` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| pr-base-branch-merge-base | AC-1 | Selection Contract | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| pr-base-branch-merge-base | AC-2 | Deterministic Procedure | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| pr-base-branch-merge-base | AC-3 | Guardrails | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| pr-base-branch-merge-base | AC-4 | Collector Invocation Rule | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| pr-base-branch-merge-base | AC-5 | Evidence Recommendation | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| pr-base-branch-merge-base | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| pr-context-artifacts | OB-1 | `## Canonical Artifact Locations` | R4 | fixed-P1-T2 | CR-10 named item: summary only of summary and appendix; rewritten in [P1-T2]. |
| pr-context-artifacts | OB-2 | `## Refresh Rule` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| pr-context-artifacts | AC-1 | Canonical Artifact Locations | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| pr-context-artifacts | AC-2 | Refresh Rule | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| pr-context-artifacts | AC-3 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| python-change-budget-router | OB-1 | `## Canonical Routing Rules` | none | accepted | CR-12: complete imperative sentence stating the first real routing rule, worded as a step rather than as the whole. |
| python-change-budget-router | OB-2 | `## Direct-Mode Rejection Rule` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| python-change-budget-router | OB-3 | `## Orchestrated Small-Path Requirements` | none | accepted | CR-12: complete sentence stating the stop rule; it names the MCP server, not an MCP tool, and the section's subject is that availability. |
| python-change-budget-router | OB-4 | `## Documentation Expectations` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| python-change-budget-router | AC-1 | Canonical Routing Rules | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| python-change-budget-router | AC-2 | Direct-Mode Rejection Rule | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| python-change-budget-router | AC-3 | Orchestrated Small-Path Requirements | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| python-change-budget-router | AC-4 | Documentation Expectations | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| python-change-budget-router | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| python-qa-gate | OB-1 | `## Required Inputs` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| python-qa-gate | OB-2 | `## Toolchain Execution Sequence` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| python-qa-gate | OB-3 | `## Delta Requirements (Zero-Regression Hard Gate)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| python-qa-gate | OB-4 | `## Required Reporting Block` | R4 | fix-required | R4 fails: the section requires five reporting sections and the item names Scope only, as a label-and-value. |
| python-qa-gate | OB-5 | `## Evidence Storage` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| python-qa-gate | AC-1 | Required Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| python-qa-gate | AC-2 | Toolchain Execution Sequence | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| python-qa-gate | AC-3 | Delta Requirements (Zero-Regression Hard Gate) | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| python-qa-gate | AC-4 | Required Reporting Block | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| python-qa-gate | AC-5 | Evidence Storage | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| python-qa-gate | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| reconcile-parity-matrix | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: "These are ..." is a demonstrative reference to the input table, which the item does not contain; R4 also fails, because the section enumerates the inputs and the item names none. |
| reconcile-parity-matrix | OB-2 | `## Routing` | R3 | fix-required | R3 fails: label-and-value "Logical role: ..." naming one of several rules of a multi-rule section (root-owned launch, resolver selection, no self-launch, zero production writes); the single-value acceptance does not apply. |
| reconcile-parity-matrix | OB-3 | `## Exact output boundary` | R3 | fix-required | R3 fails: "These rows are ..." is a demonstrative reference to the artifact-kind table, which the item does not contain; R4 also fails, because the section enumerates the artifact kinds and the item names none. |
| reconcile-parity-matrix | OB-4 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule (malformed configuration blocks delegation) of the Prerequisites section. |
| reconcile-parity-matrix | OB-5 | `## Step-by-Step Workflows` | none | accepted | CR-12: complete sentence stating one real step of the workflow, worded as a step rather than as the whole workflow (same form as the accepted pr-base-branch-merge-base OB-2). |
| reconcile-parity-matrix | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| reconcile-parity-matrix | AC-2 | Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| reconcile-parity-matrix | AC-3 | Exact output boundary | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| reconcile-parity-matrix | AC-4 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| reconcile-parity-matrix | AC-5 | Step-by-Step Workflows | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| reconcile-parity-matrix | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| remediation-handoff-atomic-planner | OB-1 | `## Required Remediation Inputs` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| remediation-handoff-atomic-planner | OB-2 | `## Context Package (When Required)` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| remediation-handoff-atomic-planner | AC-1 | Required Remediation Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| remediation-handoff-atomic-planner | AC-2 | Context Package (When Required) | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| remediation-handoff-atomic-planner | AC-3 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| research-issue | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section accepts three feature documents and the item names the issue only. |
| research-issue | OB-2 | `## Output` | R4 | fix-required | R4 fails: the section defines a feature-associated and a one-off path plus template and placement rules, and the item names the feature-associated path only. |
| research-issue | OB-3 | `## Investigation Areas` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| research-issue | OB-4 | `## Constraints` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| research-issue | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| research-issue | AC-2 | Output | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| research-issue | AC-3 | Investigation Areas | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| research-issue | AC-4 | Constraints | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| research-issue | AC-5 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| review-discovery-coverage | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: "These are ..." is a demonstrative reference to the input table, which the item does not contain; R4 also fails, because the section enumerates the inputs and the item names none. |
| review-discovery-coverage | OB-2 | `## Routing` | R3 | fix-required | R3 fails: label-and-value "Logical role: ..." naming one of several rules of a multi-rule section (root-owned launch, resolver selection, no self-launch, zero production writes); the single-value acceptance does not apply. |
| review-discovery-coverage | OB-3 | `## Exact output boundary` | R3 | fix-required | R3 fails: "These rows are ..." is a demonstrative reference to the artifact-kind table, which the item does not contain; R4 also fails, because the section enumerates the artifact kinds and the item names none. |
| review-discovery-coverage | OB-4 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule (malformed configuration blocks delegation) of the Prerequisites section. |
| review-discovery-coverage | OB-5 | `## Step-by-Step Workflows` | none | accepted | CR-12: complete sentence stating one real step of the workflow, worded as a step rather than as the whole workflow (same form as the accepted pr-base-branch-merge-base OB-2). |
| review-discovery-coverage | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| review-discovery-coverage | AC-2 | Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| review-discovery-coverage | AC-3 | Exact output boundary | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| review-discovery-coverage | AC-4 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| review-discovery-coverage | AC-5 | Step-by-Step Workflows | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| review-discovery-coverage | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| review-epic | OB-1 | `## Inputs` | R3 | fixed-P1-T1 | CR-9 named item: "that epic" had no antecedent; rewritten in [P1-T1] with both inputs. |
| review-epic | OB-2 | `## Output Paths` | none | accepted | Label-and-value naming the single required value of a single-valued section: Output Paths lists one path. |
| review-epic | OB-3 | `## Worker Routing` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| review-epic | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| review-epic | AC-2 | Output Paths | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| review-epic | AC-3 | Worker Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| review-epic | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| review-feature | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section lists the folder path and the implementation, evidence and requirement files under it, and the item names the path only. |
| review-feature | OB-2 | `## Output Paths` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| review-feature | OB-3 | `## Worker Routing` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| review-feature | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| review-feature | AC-2 | Output Paths | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| review-feature | AC-3 | Worker Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| review-feature | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| review-staged | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section lists the staged diff and the repository context, and the item names the second only. |
| review-staged | OB-2 | `## Output Paths` | none | accepted | Label-and-value naming the single required value of a single-valued section: Output Paths lists one path. |
| review-staged | OB-3 | `## Worker Routing` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| review-staged | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| review-staged | AC-2 | Output Paths | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| review-staged | AC-3 | Worker Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| review-staged | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| skill-canonical-location-audit | OB-1 | `## Scope` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| skill-canonical-location-audit | OB-2 | `## Audit Workflow` | R3 | fixed-P1-T1 | CR-9 named item: was an ordinal fragment; rewritten in [P1-T1] with all three steps. |
| skill-canonical-location-audit | OB-3 | `## Output Template (Suggested)` | R3 | fixed-P1-T1 | CR-9 named item: was a template placeholder; rewritten in [P1-T1] with every field. |
| skill-canonical-location-audit | AC-1 | Scope | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| skill-canonical-location-audit | AC-2 | Audit Workflow | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| skill-canonical-location-audit | AC-3 | Output Template (Suggested) | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| skill-canonical-location-audit | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| test-execution-policy | OB-1 | `## Commands` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| test-execution-policy | OB-2 | `## Exit Codes and Messages` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| test-execution-policy | OB-3 | `## Configuration` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| test-execution-policy | OB-4 | `## Machine Test-Suite Lock` | none | accepted | CR-12: complete sentence stating one real rule of the lock section. |
| test-execution-policy | OB-5 | `## Hook` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| test-execution-policy | AC-1 | Commands | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| test-execution-policy | AC-2 | Exit Codes and Messages | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| test-execution-policy | AC-3 | Configuration | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| test-execution-policy | AC-4 | Machine Test-Suite Lock | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| test-execution-policy | AC-5 | Hook | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| test-execution-policy | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| translate-copilot-to-claude | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: noun phrase naming the required input only, while the section also defines four optional inputs and the plan-only default. |
| translate-copilot-to-claude | OB-2 | `## Phase 1 — Intake and Section Extraction` | R5 | fixed-P1-T4 | CR-11 named item: stated through a runtime tool name; rewritten in [P1-T4]. |
| translate-copilot-to-claude | OB-3 | `## Phase 2 — Classification Taxonomy` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| translate-copilot-to-claude | OB-4 | `## Phase 3 — Target Resolution` | R4 | fix-required | R4 fails: the section resolves six target kinds and the item names the rule target only, as a label-and-value. |
| translate-copilot-to-claude | OB-5 | `## Phase 4 — Existing State Diff` | R5 | fixed-P1-T4 | CR-11 named item: stated through a runtime tool name; rewritten in [P1-T4]. |
| translate-copilot-to-claude | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| translate-copilot-to-claude | AC-2 | Phase 1 — Intake and Section Extraction | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| translate-copilot-to-claude | AC-3 | Phase 2 — Classification Taxonomy | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| translate-copilot-to-claude | AC-4 | Phase 3 — Target Resolution | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| translate-copilot-to-claude | AC-5 | Phase 4 — Existing State Diff | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| translate-copilot-to-claude | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| update-status | OB-1 | `## Inputs` | R4 | fix-required | R4 fails: the section lists the folder path and the plan, evidence and issue status context, and the item names the path only. |
| update-status | OB-2 | `## Output Paths` | none | accepted | Label-and-value naming the single required value of a single-valued section: Output Paths lists one path. |
| update-status | OB-3 | `## Worker Routing` | none | accepted | CR-12: complete sentence stating one real rule of its source section; R1 to R5 do not fail. |
| update-status | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| update-status | AC-2 | Output Paths | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| update-status | AC-3 | Worker Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| update-status | AC-4 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
| validate-discovery-artifacts | OB-1 | `## Inputs` | R3 | fix-required | R3 fails: "These are ..." is a demonstrative reference to the input table, which the item does not contain; R4 also fails, because the section enumerates the inputs and the item names none. |
| validate-discovery-artifacts | OB-2 | `## Routing` | R3 | fix-required | R3 fails: label-and-value "Logical role: ..." naming one of several rules of a multi-rule section (root-owned launch, resolver selection, no self-launch, zero production writes); the single-value acceptance does not apply. |
| validate-discovery-artifacts | OB-3 | `## Exact output boundary` | R3 | fix-required | R3 fails: "These rows are ..." is a demonstrative reference to the artifact-kind table, which the item does not contain; R4 also fails, because the section enumerates the artifact kinds and the item names none. |
| validate-discovery-artifacts | OB-4 | `## Prerequisites` | none | accepted | CR-12: complete sentence stating one real rule (malformed configuration blocks delegation) of the Prerequisites section. |
| validate-discovery-artifacts | OB-5 | `## Step-by-Step Workflows` | none | accepted | CR-12: complete sentence stating one real step of the workflow, worded as a step rather than as the whole workflow (same form as the accepted pr-base-branch-merge-base OB-2). |
| validate-discovery-artifacts | AC-1 | Inputs | none | accepted | Per-behavior template form; names the heading of its cited OB-1. |
| validate-discovery-artifacts | AC-2 | Routing | none | accepted | Per-behavior template form; names the heading of its cited OB-2. |
| validate-discovery-artifacts | AC-3 | Exact output boundary | none | accepted | Per-behavior template form; names the heading of its cited OB-3. |
| validate-discovery-artifacts | AC-4 | Prerequisites | none | accepted | Per-behavior template form; names the heading of its cited OB-4. |
| validate-discovery-artifacts | AC-5 | Step-by-Step Workflows | none | accepted | Per-behavior template form; names the heading of its cited OB-5. |
| validate-discovery-artifacts | AC-6 | (closing) | none | accepted | Closing template form; cites every OB of the contract. |
