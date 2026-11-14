---
name: documentation-workflow
description: 'Run the documentation estate workflow from initialization to docs-complete validation by dispatching the seven docs skills in order. Use when a repository documentation estate must be created, extended or brought to docs-complete.'
---

# Documentation Workflow

## When to Use This Skill

Use this skill from the root session to run the whole documentation workflow, or
to resume it at a named step. It is an alias: it adds no tool call, receipt or
write authority of its own and dispatches to the seven skills below.

## Prerequisites

Root steps run `Invoke-DocsCommand.ps1` from the docs helper library that the Claude customization push-down delivers, under PowerShell 7.4 or later. Without that library every root step in this skill is unavailable; the docs MCP tools stay available.

## Dispatch Order

Run the skills in this order. Each step names the role that runs it; a root step
runs in the root session.

1. [docs-init](../docs-init/SKILL.md) (root): create and validate the docs profile.
2. [docs-inventory-surface](../docs-inventory-surface/SKILL.md) ([docs-architect](../../../.codex/agents/docs-architect.toml)): inventory the documented surface.
3. [docs-plan-ia](../docs-plan-ia/SKILL.md) ([docs-architect](../../../.codex/agents/docs-architect.toml)): plan the information architecture.
4. [docs-author-page](../docs-author-page/SKILL.md) ([docs-author](../../../.codex/agents/docs-author.toml)): write and revise pages.
5. [docs-reconcile-behavior](../docs-reconcile-behavior/SKILL.md) ([docs-reconciler](../../../.codex/agents/docs-reconciler.toml)): record dispositions, pins and dimensions.
6. [docs-review-coverage](../docs-review-coverage/SKILL.md) ([docs-coverage-reviewer](../../../.codex/agents/docs-coverage-reviewer.toml)): review coverage and accuracy.
7. [docs-validate](../docs-validate/SKILL.md) ([docs-coverage-reviewer](../../../.codex/agents/docs-coverage-reviewer.toml) or root): validate `docs-complete` for the head revision.

## Rules

- Pass each role its prepared inputs: `workspace_root`, the profile path and the
  outputs of the earlier steps.
- Read each role's report tokens before the next step. A `BLOCKED` or `FAIL`
  result stops the workflow until the cause is resolved.
- Every write of a profile artifact goes through a root step or through
  `update_docs_ledger`; no role writes the profile, the ledger, the matrix, the
  pins or a receipt directly.

## Commit, Receipt and Pull Request

The root session runs this stage itself after the dispatch order. It is not a dispatch row and
writes no orchestration checkpoint; the repository hooks admit it through their docs-estate legs.

1. Commit: after `docs-init`, and again after `docs-complete` validation passes, stage the changed
   paths with `git add -- <paths>` and commit with `git commit -F <file>`. Give the commit no
   pathspec.
2. Receipt: write the receipt with the command below, which defaults the revision to the snapshot
   revision of the inventory, then stage and commit it with the same command shape.

   ```powershell
   Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete -WriteReceipt
   ```

3. Push: run `git push origin <branch>`.
4. Delegate: delegate `Agent(pr-author)` with a prompt that carries each of these lines exactly once:
   - `branch: <branch>`
   - `base: <base>`
   - `Canonical issue number for this feature is <N>.`
   - `Author-asserted autoclose issues: #<N>`

   and that asks for the pull request with this command form:

   ```text
   gh pr create --head <branch> --base <base>
   ```

Rules:

- A docs run that opens a pull request requires a tracking issue, so `<N>` in
  `artifacts/pr_body_<N>.md` and in its receipt is defined before the pull request exists.
- A session root that holds another item's checkpoint makes every docs leg decline. This is
  intended fail-closed behavior: decline to run the stage there, and run it from a root that holds
  no checkpoint.
- Only docs path set changes may be on the branch: paths under `docs/` that lie under the
  profile's documentation roots or artifact directories, and the docs-init workflow file. Any
  other path is denied at commit, PR creation, and merge.

## Refresh After Rebase or Source Change

After a rebase, or after a source path under `surface_selection.source_roots` changes, the receipt
revision rule denies the existing receipt. Run these steps in order before the stage above:

1. Re-inventory at the new revision.
2. Regenerate the reference pages.
3. Update the `surface_refs` of hand-written pages for added and removed elements.
4. Re-review the changed elements.
5. Rebuild the ledger.
6. Re-validate.
7. Write a new receipt.
