---
name: pr-author
description: Write a GitHub-ready pull request body from the canonical PR-context bundle with strict verification and auto-close rules.
allowed-tools:
  - Read
  - "Bash(git log *)"
---

# PR Author Skill

Produce a GitHub-ready Pull Request description from the standard PR context files. The pull request must be in a copy / paste block so that it can be copied easily to the PR extension.

## Inputs

- `artifacts/pr_context.summary.txt` — PR context summary (primary)
- `artifacts/pr_context.appendix.txt` — PR context appendix (full baseline diff, commits, changed files)
- Optional user directives

Only reference files that are listed under "Additional context files" in the context bundle. Do not cite or summarize files outside that enumeration.

## Output Requirements

1. Output only the PR text body in GitHub-flavored Markdown.
2. Use clear headings, consistent structure, and concise bullets.
3. Do not invent tests or results; if not in context, state "Not verified in this PR."
4. If scope is large, include a Review Guide with suggested review order.
5. The output is a PR body artifact or PR-ready body text only.

## PR Body Structure

Use these sections in this order:

1. **Suggested title** — crisp, prioritizing the primary outcome
2. **Summary** — 3–7 bullets, most important first; lead with the primary product/feature/architecture change
3. **Why** — motivation, constraints, root cause; rely on embedded feature-doc excerpts and PR Intent fields only
4. **What Changed** — grouped by theme (core feature, tooling/CI, tests, docs/templates)
5. **Architecture / How It Fits Together** — short wiring description with components, entry points, control flow
6. **Verification** — "Completed" (from context) and "Recommended" (commands to run)
7. **Backward Compatibility / Migration Notes** — breaking changes, removals, renamed paths
8. **Risks and Mitigations** — realistic risks with mitigations and rollback notes
9. **Review Guide** — suggested order, noisy mechanical moves, large diffs
10. **Follow-ups** — known TODOs, deferred cleanup, next PRs
11. **GitHub Auto-close** — `- Closes #NNN` from the three sources in Issue/PR Reference Rules (the PR-context "Issues to autoclose" list, the PR-context "Author-asserted autoclose issues" list, and an issue named as author-asserted in the delegation prompt); `- None` only when no source has an entry; do not invent issue numbers

## Output Artifact

The PR body produced by this skill is persisted as a body file plus a sibling receipt so the
PreToolUse hook can verify the body passed to `gh pr create --body-file` is the one this skill
produced:

1. Write the body text to `artifacts/pr_body_<N>.md`, where `<N>` is the target issue or PR number.
2. Compute the SHA-256 of the body file by running `sha256sum artifacts/pr_body_<N>.md` as a single command (no chaining) and take the lowercase hexadecimal digest.
3. Write the sibling receipt `artifacts/pr_body_<N>.receipt.json` with the shape:

   ```json
   {
     "skill": "pr-author",
     "pr_body_path": "artifacts/pr_body_<N>.md",
     "number": <N>,
     "sha256": "<lowercase-hex SHA-256 of the body bytes>",
     "context_summary_path": "artifacts/pr_context.summary.txt",
     "created_at": "<ISO-8601 UTC timestamp newer than pr_context.summary.txt last-write>"
   }
   ```

   Obtain it by running `date -u +%Y-%m-%dT%H:%M:%SZ` as a single command.

4. Pass the body to the pull request via `--body-file artifacts/pr_body_<N>.md`; do not use inline
   `--body`.

The body-file and receipt write operations remain in the pr-author agent scope, which holds
`Write(/artifacts/**)`. This skill authors the body text; the pr-author agent performs the file
writes and the `gh pr create` / `gh pr edit --body-file` handoff.

## Issue/PR Reference Rules

- Only mention an issue/PR number if it appears verbatim in the provided context or in the delegation prompt.
- Do not treat PR numbers as issues.
- Auto-close bullets must use exactly `- Closes #NNN` format. Three sources are valid:
  1. the PR-context "Issues to autoclose" list;
  2. the PR-context "Author-asserted autoclose issues" list (rendered from the PR Intent);
  3. an issue named as author-asserted in the delegation prompt, on the line
     `Author-asserted autoclose issues: #NNN`. This source is valid even when the PR context
     lists no verified autoclose issues.
- Emit the fallback `- None` bullet only when no source has an entry.
- GitHub validation applies to the two PR-context lists: if it is unavailable or unverified for
  an entry on those lists, do not emit `Closes` for that entry. An issue named as author-asserted
  in the delegation prompt is emitted without that validation; the closing-reference
  verification below confirms it after the pull request exists.

## Closing-Reference Verification

The pr-author agent MUST run `gh pr view <N> --json closingIssuesReferences,body` as a single
command (no chaining, no extra flags) after every `gh pr create` or `gh pr edit` it issues, where
`<N>` is the pull request number. It reports the closing issue numbers that
`closingIssuesReferences` lists, and reports any mismatch with the author-asserted list: an
author-asserted issue that GitHub does not list as closing, or a closing issue that no source
named. The command is read-only, and this exact form is the only pull-request view form the
agent's allowlist hook permits.

## Required `--head` on `gh pr create` (issue #687)

Every `gh pr create` command this agent issues MUST carry an explicit
`--head <branch>` naming the branch the pull request is opened from, for example
`gh pr create --head <branch> --body-file artifacts/pr_body_<N>.md`.

This is what makes the call's target derivable. `enforce-pr-author-skill.ps1` resolves the
worktree the call pertains to from the command text, and validates the orchestrator checkpoint
belonging to that worktree. Without `--head`, `gh pr create` infers its head branch from the
current checkout and the command carries no signal at all, so the gate falls back to the branch
checked out in its own working directory (issue #989) and denies with
`TARGET_WORKTREE_NOT_DERIVABLE` when that checkout is detached or unreadable, rather than
validating against whichever checkpoint occupies the session root, which in a parallel or epic
topology belongs to a different item.

Pass `--head` even when the branch is the current one: the gate resolves it to the session root
and behaves exactly as before, and the command stays correct if it is ever replayed elsewhere.

`gh pr edit` takes no head-branch flag, and --head is not valid for gh pr edit. Name the target of
an edit in one of two ways:

- Run `gh pr edit <N> --body-file artifacts/pr_body_<N>.md` from the item worktree. The gate
  derives the branch from that worktree's checkout.
- When running outside the item worktree, append the shell comment `# branch: <branch>` to the
  command, and pass the absolute canonical body path beneath the item worktree.