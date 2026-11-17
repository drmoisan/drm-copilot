# Gold Standard: atomic-plan-contract

## Objective

Atomic plan format and toolchain contract shared by planning and execution agents. Use when generating, validating, or executing atomic plans with Phase 0, baseline capture, and final QA loops. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Plan Format: Phase headings must be: `### Phase N — <Title>`.
- **OB-2** Design-Level Plan Contract (Mandatory): A plan is a design-level document: it states what changes and how the change is proven, not a transcript of commands.
- **OB-3** Process-Reduction Ledger: This rule applies only when `docs/engineering/process-reductions/` exists, so a repository without that folder is unaffected.
- **OB-4** Short-Path Minimal Plan Contract: When orchestration selects the short path, a minimal plan is still mandatory and contains four blocks in order: a baseline capture block (static baselines and, for each language with mandatory coverage policy, one `Phase 0 baseline` run of its test gate, with one artifact per baseline step carrying `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`, and pass, fail and coverage values for each test step), a delegated implementation block (an explicit handoff task to the small-path implementation engineer with acceptance criteria for completion), a final QC block (the full format, lint, type-check and test loop, rerun when any step changes files or fails, with one static artifact per language and one artifact per test gate, coverage-mode test commands compared with the `Phase 0 baseline`, and no `SKIPPED` result unless the task text authorizes a skip), and a reduced audit block (an explicit post-implementation small-audit handoff with the reduced artifact checks of the short path).
- **OB-5** Minimal-Audit Directive Contract (Small Path): For a short-path planning handoff the orchestrator includes the directive `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`, and the planner then returns a plan that uses `${feature-folder}/issue.md` as its sole requirements source, requires that file to contain an explicit `## Acceptance Criteria` section and treats only that section as the minor-audit acceptance-criteria source, does not require `spec.md`, `user-story.md` or `research.md`, has exactly three phases (Phase 0 baseline capture, a Phase 1 placeholder for constrained small-path implementation and a Phase 2 final QC loop), makes every final-QC command task unconditional with no in-scope or out-of-scope branch and no skipped completion path unless the task text authorizes a skip branch, and returns the `plan-path` and the final preflight signal.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Plan Format, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Design-Level Plan Contract (Mandatory), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Process-Reduction Ledger, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Short-Path Minimal Plan Contract, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Minimal-Audit Directive Contract (Small Path), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
