# Follow-Ups (issue #713)

Timestamp: 2026-09-27T03-43

This plan files nothing. Each entry below is filed, if at all, as a separate issue promoted by the orchestrator through `mcp__drm-copilot__potential_to_issue`.

## 1. Integration Commit Form for the `.agents` epic-plan skill

Title: Add the Integration Commit Form and attribution-trailer forms to `.agents/skills/epic-plan/SKILL.md`
Scope: Add an Integration Commit Form section carrying the two admitted attribution-trailer forms (the `--trailer` option and the one-paragraph multi-message form) to `.agents/skills/epic-plan/SKILL.md` and to its Codex bundle mirror, matching the subsection added to `.claude/skills/epic-plan/SKILL.md` by issue #713. Out of scope for #713 per spec Rollout and plan section 1.
Filing route: separate issue promoted by the orchestrator through `mcp__drm-copilot__potential_to_issue`; this plan files nothing.

## 2. Optional modelling of heredoc-fed commit messages

Title: Optionally model heredoc-fed commit messages in the preimplementation gate staging exemption
Scope: If demand appears, extend the staging exemption to admit heredoc-fed message forms such as `git commit -m "$(cat <<'EOF' ... EOF)"` and `git commit -F - <<'EOF'`, which decision D5 of issue #713 documents as not admitted. Any such change must keep every parse ambiguity on the deny side.
Filing route: separate issue promoted by the orchestrator through `mcp__drm-copilot__potential_to_issue`; this plan files nothing.

## 3. Out-of-scope defect observed during execution: worktree-removal gate denies `git --version`

Title: enforce-parallel-worktree-removal-gate.ps1 denies bare `git --version` as a worktree removal with an empty path (PARALLEL_WORKTREE_REMOVAL_BLOCKED)
Scope: Out-of-scope defect observed during execution of this plan, not introduced by #713. The PreToolUse hook `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` denied the read-only command `git --version` with `PARALLEL_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '' requires a matching parallel checkpoint items[] record ...`. The command names neither `worktree` nor `remove`, so the scope filter (`Test-CommandLineInvocation -CommandWord 'git' -SubcommandPath @('worktree', 'remove')`) appears to match a git invocation whose first argument is a long option with no subcommand. Observed text and analysis are recorded in `evidence/baseline/p0-git-trailer-support.md`; execution substituted `git version` under deviation X3.
Filing route: separate issue promoted by the orchestrator through `mcp__drm-copilot__potential_to_issue`; this plan files nothing.
