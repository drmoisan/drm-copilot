# Gold Standard: atomic-plan-contract

## Objective

Atomic plan format and toolchain contract shared by planning and execution agents. Use when generating, validating, or executing atomic plans with Phase 0, baseline capture, and final QA loops. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Plan Format: Phase headings must be: `### Phase N — <Title>`.
- **OB-2** Design-Level Plan Contract (Mandatory): A plan is a design-level document: it states what changes and how the change is proven, not a transcript of commands.
- **OB-3** Process-Reduction Ledger: This rule applies only when `docs/engineering/process-reductions/` exists, so a repository without that folder is unaffected.
- **OB-4** Short-Path Minimal Plan Contract: 1) Baseline capture block.
- **OB-5** Minimal-Audit Directive Contract (Small Path): `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Plan Format, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Design-Level Plan Contract (Mandatory), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Process-Reduction Ledger, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Short-Path Minimal Plan Contract, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Minimal-Audit Directive Contract (Small Path), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
