# `documentation-workflow-end-to-end-runnable` — User Story

- Issue: #1169
- Owner: drmoisan
- Status: Approved for planning
- Last Updated: 2026-11-13
- Spec: `docs/features/active/2026-11-13-documentation-workflow-end-to-end-runnable-1169/spec.md`

## Story Statement

- As an operator running `/documentation-workflow` from a session root, I want the run to commit, push, and open its pull request through `Agent(pr-author)` without an orchestration checkpoint, so that a completed documentation estate can be delivered without manual workarounds.
- As a repository maintainer, I want every checkpoint-free docs allowance to be limited to documentation paths and fail-closed, so that a non-documentation change cannot use the docs path to bypass the orchestration gates.
- As an integration-branch owner, I want the docs-complete gate to accept a receipt produced by the documented workflow and to deny a receipt whose source has drifted, so that the gate is satisfiable and still meaningful.

## Problem / Why

A first consumer run of `/documentation-workflow` reached docs-complete and then could not deliver its work. The preimplementation gate denied every `git add` and `git commit`. The model-routing gate denied `Agent(pr-author)`, because no checkpoint existed. The docs-only exemptions rejected the configuration files that docs-init itself creates. The integration docs-complete gate required a receipt revision equal to the PR head, which a committed snapshot can never name. The documentation-workflow skill also had no commit or PR stage and no procedure for a rebase. This story covers Part A of issue #1169. Part B defects are tracked in #1173.

## Personas & Scenarios

- Persona: Documentation operator
  - Runs the documentation workflow from a session root for a repository that has a docs profile.
  - Cares about reaching a merged documentation PR with the toolchain's normal gates, with no hand-made checkpoint and no hook bypass.
  - Constraint: a docs run writes no orchestration checkpoint, and isolated subagents run `main`'s hooks.
  - Frustration: after a long run reached docs-complete, every delivery step was denied.
- Persona: Repository maintainer
  - Owns the enforcement hooks and their mirrors across the Claude, Codex, Copilot, and push-down surfaces.
  - Cares that each new allowance is narrow, ordinal, tested for every deny condition, and does not change deny text in repositories without a docs estate.
- Scenario: First docs PR in a repository
  - The operator runs docs-init and commits its outputs with `git add -- <paths>` and `git commit -F <file>`. The docs-estate leg allows the commit, because every staged path is in the docs path set.
  - The operator completes inventory, authoring, reconciliation, review, and validation, then commits the estate.
  - The operator runs `validate -Mode docs-complete -WriteReceipt` with no `-Revision`. The receipt records the snapshot revision, and the operator commits and pushes it.
  - The operator delegates `Agent(pr-author)` with `branch:`, `base:`, the canonical issue line, and the autoclose line. The delegation leg checks the diff against the explicit base and the receipt, and allows the delegation. pr-author writes its receipt under `artifacts/` and creates the PR, which passes the docs-only exemption, because the only non-`docs/` path is the docs-init workflow file.
  - Expected outcome: a docs PR exists with no hook denial.
- Scenario: Non-docs path on a docs branch
  - The branch also contains a change to a source file.
  - The commit is denied with a docs-estate suffix naming `DOCS_LEG_STAGED_PATH_NOT_ALLOWED`. If the change reached the branch by another route, the delegation, the PR creation, and the merge each deny.
- Scenario: Rebase after source change
  - The operator rebases the docs branch onto a newer `main` that changed files under a source root.
  - The delegation leg and the docs-complete gate deny with `RECEIPT_REVISION_NOT_ANCESTOR` or `RECEIPT_SOURCE_DRIFT`, and the message names the refresh procedure.
  - The operator follows `## Refresh After Rebase or Source Change` and writes a new receipt, after which the delegation is allowed.

## Acceptance Criteria

- [x] A checkpoint-free docs run's `git add` and `git commit` of docs path set changes are allowed by the Claude and Codex preimplementation gates. Each deny condition (invalid profile, path outside the set, unreadable or empty staged index, staged path outside the set, chained non-git segment, checkpoint present) is denied, and when a profile exists the deny reason names the failed condition. Proven by `enforce-orchestration-preimplementation-gate.DocsEstate.Tests.ps1` and `enforce-orchestration-preimplementation-gate-docs.Tests.ps1`.
- [x] The pr-author receipt Write `artifacts/pr_body_<N>.receipt.json` is allowed in a checkpoint-free docs run and denied without a valid profile or with a checkpoint present. Proven by the same suites.
- [x] A checkpoint-free `Agent(pr-author)` delegation with exactly one `branch:` line and exactly one explicit `base:` line is allowed only when the diff against that base is non-empty and entirely docs path set changes and a passing docs-complete receipt satisfies the revision rule. Each failing condition denies with a named sub-code. Proven by `enforce-model-routing-receipt.DocsEstate.Tests.ps1`.
- [x] docs-init writes its Vale and markdownlint configuration under `docs/documentation-estate/`, and a branch of `docs/` paths plus `.github/workflows/_docs-quality.yml` passes E7 and M9, while one extra non-docs path denies. The `--config` usage for consumers is documented. Proven by the updated docs-init, `hook-docs-only-diff`, E7, and M9 suites and the init-workflow parity suite.
- [x] The integration docs-complete gate accepts a receipt produced by the documented workflow, and it denies a receipt whose source drifted or whose revision is not an ancestor of the head. `validate -WriteReceipt` defaults `-Revision` to the snapshot revision and says so in its help. Proven by `DocsReceiptRevision.Tests.ps1`, `DocsReceiptRevision.Properties.Tests.ps1`, `DocsCompleteGate.Tests.ps1`, `enforce-docs-complete-gate.Tests.ps1`, and `DocsValidateCommands.Tests.ps1`.
- [x] The documentation-workflow skill copies contain the commit, receipt, and pull-request stage, the tracking-issue rule, and the refresh procedure. The pr-author skill copies contain the delegation-prompt contract, and the execution-environment brief copies contain the docs-estate legs bullet and remain byte-identical. Proven by `documentation-workflow.CommitStage.Tests.ps1`, `pr-author-docs-estate-delegation-contract.Tests.ps1`, and the existing brief contract tests.
- [x] A composed end-to-end Pester scenario shows a synthetic checkpoint-free docs branch allowed at commit, receipt Write, delegation, PR creation, and merge. It also shows the same branch with one non-docs path denied at commit, delegation, PR creation, and merge. Proven by `docs-estate-workflow.EndToEnd.Tests.ps1`.
- [ ] The full toolchain loop passes with parallel-only test execution, mirrors and push-down bundles are in parity, and no new or changed hook invokes Python.

## Non-Goals

- Part B items B1 to B13 of issue #1169, including bulk `update-ledger` performance for estates of about 3,000 elements. These are tracked in #1173.
- Adding a Vale or markdownlint step to `_docs-quality.yml`.
- Changing the docs profile schema, `New-DocsStarterProfile`, or the default documentation roots.
- Changing the Codex model-routing gate, the PR-create gate's E1 to E6 logic, or the cleanup legs of issue #1026.
- A live post-merge end-to-end run as a merge precondition.
