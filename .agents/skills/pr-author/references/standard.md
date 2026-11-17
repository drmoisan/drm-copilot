# Gold Standard: pr-author

## Objective

Write a GitHub-ready pull request body from the canonical PR-context bundle with strict verification and auto-close rules. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: The skill takes the PR context summary `artifacts/pr_context.summary.txt` as its primary input, the PR context appendix `artifacts/pr_context.appendix.txt` (full baseline diff, commits and changed files) and optional user directives, and it references only files listed under Additional context files in the context bundle.
- **OB-2** Output Requirements: Output only the PR text body in GitHub-flavored Markdown.
- **OB-3** PR Body Structure: The PR body uses eleven sections in order: Suggested title (crisp, prioritizing the primary outcome), Summary (three to seven bullets, most important first), Why (motivation, constraints and root cause from the embedded feature-doc excerpts and PR Intent fields only), What Changed (grouped by theme), Architecture / How It Fits Together (a short wiring description), Verification (Completed from context and Recommended commands), Backward Compatibility / Migration Notes, Risks and Mitigations, Review Guide, Follow-ups, and GitHub Auto-close (`- Closes #NNN` only from verified autoclose lists).
- **OB-4** Issue/PR Reference Rules: Only mention an issue/PR number if it appears verbatim in the provided context.
- **OB-5** Checkpoint-Free Docs-Estate Delegation (issue #1169): A documentation run (`/documentation-workflow`) writes no orchestration checkpoint.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Output Requirements, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under PR Body Structure, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Issue/PR Reference Rules, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Checkpoint-Free Docs-Estate Delegation (issue #1169), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
