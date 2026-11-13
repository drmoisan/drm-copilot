# documentation-workflow-end-to-end-runnable — Spec

- **Issue:** #1169
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-13
- **Status:** Approved for planning
- **Version:** 1.0
- **Research:** `docs/features/active/2026-11-13-documentation-workflow-end-to-end-runnable-1169/research/research.2026-11-13T18-22.md`

## Overview

A documentation run (`/documentation-workflow`) writes no orchestration checkpoint by design. Today such a run cannot commit, cannot delegate `Agent(pr-author)`, and its first pull request cannot pass the docs-only exemptions. Its docs-complete receipt also cannot satisfy the integration docs-complete gate. This feature gives a docs run a checkpoint-free path that is fail-closed and modelled on the issue #1026 cleanup-worktrees legs. The readiness evidence is the docs profile plus a passing docs-complete receipt.

## Scope

In scope: Part A of `issue.md`, items A1 to A5.

- A1: a docs-estate leg in the preimplementation gate for `git add`, `git commit`, and the pr-author receipt Write.
- A2: a docs-estate delegation leg in the model-routing gate for a checkpoint-free `Agent(pr-author)`.
- A3: docs-init writes its linter configuration under `docs/documentation-estate/`. The E7 and M9 docs-only classifiers admit exactly one non-`docs/` path, the docs-init workflow file.
- A4: one receipt revision rule, shared by `validate` and the integration docs-complete gate.
- A5: a root-owned commit, receipt, and pull-request stage and a refresh procedure in the documentation-workflow skill, plus the delegation-prompt contract in the pr-author skill.

## Non-Goals

- Part B of `issue.md` (B1 to B13) is out of scope. It is tracked in issue #1173 (owner decision 2026-11-13). The early-draft criteria for bulk `update-ledger` performance (reconciling an estate of about 3,000 elements in minutes) and for B regression tests moved to #1173.
- No change to `New-DocsStarterProfile` (`.claude/lib/docs/DocsProfile.psm1`) or its `documentation_roots` default. B6 and B7 in #1173 own that function.
- No Vale or markdownlint step is added to `_docs-quality.yml` (see A3).
- No change to the Codex model-routing gate (`.codex/hooks/enforce-codex-model-routing.ps1`). It checks a profile attestation and does not read a checkpoint receipt, so it does not block a checkpoint-free pr-author delegation.
- No change to the PR-create gate's E1 to E6 logic. The research found that once A3 makes E7 pass, a checkpoint-free docs PR already passes E1 to E7.
- No change to the existing cleanup legs (issue #1026) or their contract text.
- No live end-to-end run before merge is required (see `## Verification Model`).

## Definitions

- **Resolved root (R):** the single worktree root that the existing target resolution returns for the command, Write path, or delegation prompt. When resolution returns no root or more than one root, the call is denied before any docs leg runs, as it is today.
- **Docs profile:** `docs/documentation-estate/docs-profile.json` beneath R.
- **Structurally valid profile:** a JSON object with `artifact_kind` equal to `docs-profile`, a non-empty `documentation_roots` array whose `path` values are plain repository-relative paths, and an `artifact_paths` object whose values are strings. The hooks validate the structure only, because the Codex hooks cannot import `.claude/lib`.
- **Docs path set:** a repository-relative path is in the set when it passes the character-class and `..` rules of `Test-CleanupConsolidationRelativePath` and at least one of the following holds:
  1. It lies under the directory of an `artifact_paths` value.
  2. It equals the shared docs-init workflow constant (A3).
  3. It lies under a `documentation_roots[].path`. When that root is not under `docs/`, the path must also end in `.md`.
  All comparisons are ordinal and segment-anchored.
- **Docs-init workflow constant:** the literal `.github/workflows/_docs-quality.yml`, held once as `$script:DocsOnlyInitWorkflowPath` in `.claude/hooks/hook-docs-only-diff.ps1`.

## Behavior

### A1. Docs-estate leg in the preimplementation gate

A new sibling hook, `enforce-orchestration-preimplementation-gate-docs.ps1`, exposes `Get-OrchestrationDocsEstateContextResult`. Its result has the same shape as `Get-OrchestrationCleanupContextResult` (`Allowed`, `DenySuffix`), and it never throws. The Claude and Codex main gates (`enforce-orchestration-preimplementation-gate.ps1`) call it once, only where the gate would otherwise deny and only after the cleanup leg has declined. Its suffix is appended after the cleanup suffix. Pure profile and path predicates live in a new hook file, `hook-docs-estate-context.ps1`.

Prefilters (pure, evaluated before any I/O):

- Command form: every segment of `Split-OrchestrationCommandLine` is either `git add -- <operand>...` or `git commit` with only `-m`, `--message`, `-F`, `--file`, or `--trailer` and no pathspec, each optionally written as `git -C <absolute root>`.
- Write form: the target path is `artifacts/pr_body_<digits>.receipt.json`, given as a relative or absolute path.
- Any other shape declines with `Allowed $false` and an empty suffix. A chained `pytest`, `ruff`, `black`, `pyright`, `npm`, `npx`, or `Invoke-Pester` segment therefore still denies with the unchanged deny text.

Conditions, evaluated in order (the first failure declines):

- D1, target and checkpoint: R resolves, and no orchestration checkpoint exists at R. A present checkpoint, ready or not, governs the call, and the docs leg does not apply.
- D2, profile: the docs profile beneath R exists and is structurally valid.
- D3, add: every `git add` operand is in the docs path set.
- D4, commit: the staged index beneath R, read through `Get-OrchestrationGateStagedIndex`, is readable, NUL-terminated, non-empty, and entirely in the docs path set.
- Receipt Write: D1 and D2 hold.

Deny suffix: `' Docs-estate leg not applied: <SUB_CODE>: <detail>'`, with sub-codes `DOCS_LEG_PROFILE_INVALID`, `DOCS_LEG_PATH_NOT_ALLOWED`, `DOCS_LEG_STAGED_INDEX_UNREADABLE`, `DOCS_LEG_STAGED_INDEX_EMPTY`, and `DOCS_LEG_STAGED_PATH_NOT_ALLOWED`. The suffix is set only after the leg has resolved R and found a profile file. When no profile file exists, the suffix is empty, so repositories without a docs estate see byte-identical deny text.

The new sibling and `hook-docs-estate-context.ps1` are byte-identical in `.claude/hooks/`, `.codex/hooks/`, and both push-down bundles.

### A2. Docs-estate delegation leg in the model-routing gate

In `Invoke-ModelRoutingReceiptDecision` (`.claude/hooks/enforce-model-routing-receipt.ps1`), a docs-estate leg sits after the cleanup exemption under the same `$subagent -eq 'pr-author' -and $null -eq $checkpoint` conjunct. The planner may place the leg's logic in a new sibling file to keep the main hook small. Conditions, evaluated in order (the first failure denies with the existing final reason plus a docs suffix):

1. Labels: the prompt carries exactly one line-anchored `branch: <name>` line (the shape of `Test-CleanupConsolidationBranchLabel`) and exactly one line-anchored `base: <branch>` line. Both values use a conservative branch spelling with no `..`. The base is explicit and is not fixed to `main`, because a docs PR may target an epic integration branch.
2. Profile: the docs profile beneath R is structurally valid.
3. Diff: in R, `refs/remotes/origin/<base>` and `HEAD` resolve, and the `<base>...HEAD` diff (`--name-only -z --no-renames --no-relative`) is readable, NUL-terminated, non-empty, and entirely in the docs path set.
4. Receipt: the receipt at `artifact_paths.validation_receipt` beneath R has `artifact_kind` `docs-validation-receipt`, `mode` `docs-complete`, and `validation_result` `pass`, and it passes the A4 rule against the `HEAD` of R.

Every git call goes through `Invoke-DocsOnlyGitExe` (bounded, never throws). A timeout or a non-zero exit is a denial, not an allowance. Deny suffix: `' Docs-estate delegation leg not applied: <SUB_CODE>: <detail>'`, with sub-codes `DOCS_DELEGATION_LABEL_INVALID`, `DOCS_DELEGATION_PROFILE_INVALID`, `DOCS_DELEGATION_DIFF_UNREADABLE`, `DOCS_DELEGATION_DIFF_EMPTY`, `DOCS_DELEGATION_PATH_NOT_ALLOWED`, `DOCS_DELEGATION_RECEIPT_INVALID`, and the A4 reason codes. When no profile file exists beneath R, the suffix is empty and the existing deny text is unchanged. The cleanup exemption keeps its behavior.

### A3. Docs-init outputs and the docs-only exemptions

Selected option: the preferred option of the issue, recorded here as the documented choice.

- `Get-DocsInitTemplate` (`.claude/lib/docs/DocsProfileCommands.psm1`) writes the markdownlint and Vale configuration under `docs/documentation-estate/`: `docs/documentation-estate/.markdownlint.json`, `docs/documentation-estate/.vale.ini`, and the Vale styles and vocabulary under `docs/documentation-estate/.vale/styles/`. `StylesPath = .vale/styles` stays valid, because Vale resolves it relative to the `.vale.ini` that sets it.
- `.github/workflows/_docs-quality.yml` is still written by docs-init, and it is the one non-`docs/` path the exemptions admit.
- `Get-DocsOnlyPathViolation` (`hook-docs-only-diff.ps1`) admits a path that equals `$script:DocsOnlyInitWorkflowPath`, by one ordinal equality and not by a glob. Because E7 (`Get-PrAuthorDocsOnlyExemption`) and M9 (`Get-DocsOnlyMergeExemption`, both runtimes' `enforce-epic-merge-gate.ps1`) share this classifier, the one change covers both on both runtimes. The A1 and A2 legs read the same constant.
- Parity: a Pester test pins `$script:DocsOnlyInitWorkflowPath` equal to the workflow destination row of `Get-DocsInitTemplate`. It follows the precedent of `hook-cleanup-context.Parity.Tests.ps1`, because a hook cannot import the docs library.
- `--config` choice: `_docs-quality.yml` runs no Vale or markdownlint step, so no `--config` argument is added to it. Instead, `docs-init/SKILL.md` and `docs/engineering/documentation-estate/consumer-onboarding.md` (`## Linting`) state that a consumer passes `--config docs/documentation-estate/.vale.ini` (or sets `VALE_CONFIG_PATH`) to Vale, and passes the markdownlint configuration path explicitly. The documentation records this as the documented choice the issue requires.
- Policy note: admitting the workflow path applies to every pull request, not only to docs-estate runs. A PR that edits only that workflow passes the docs-only exemptions. CI still runs in full for it, because the path is outside `config/ci-docs-only-paths.json`, and the required CI gate still applies. The skill and engineering documentation state this as a policy-level control.

### A4. One receipt revision rule

A new pure module, `.claude/lib/docs/DocsReceiptRevision.psm1`, exports `Get-DocsReceiptRevisionDecision -ReceiptRevision -SnapshotRevision -HeadRevision -IsAncestor -ChangedPath -SourceRoot`, which returns `Allow`, `Reason`, and `Message`. It does no git I/O; each caller supplies `IsAncestor` and `ChangedPath`.

- Allow when the receipt revision equals the snapshot revision, the receipt revision is an ancestor of the head, and no changed path between the receipt revision and the head lies under any `surface_selection.source_roots` entry (ordinal, segment-anchored).
- A head equal to the receipt revision allows without needing ancestry or diff input, which keeps the CI template's inventory-at-head flow passing.
- Deny reasons:
  - `RECEIPT_REVISION_SNAPSHOT_MISMATCH`: the receipt revision differs from the snapshot revision.
  - `RECEIPT_REVISION_NOT_ANCESTOR`: the receipt revision is not an ancestor of the head, as after a rebase.
  - `RECEIPT_SOURCE_DRIFT`: the message names a bounded list of drifted paths.
  - `RECEIPT_REVISION_UNRESOLVED`: a git failure, a timeout, or a head not present locally. The message includes a fetch remediation.
- Every deny message names the refresh procedure of the documentation-workflow skill (A5).

Callers:

- `Test-DocsCompleteGateReceipt` (`DocsCompleteGate.psm1`) delegates its revision step to the new function in place of the head-equality comparison. `enforce-docs-complete-gate.ps1` supplies ancestry and the changed paths through `Invoke-DocsOnlyGitExe`.
- The A2 leg uses the same function.
- `validate`: `Test-DocsValidateArgument` and `Invoke-DocsValidateCommand` first move unchanged from `DocsLedgerCommands.psm1` (785 lines) to a new module, `DocsValidateCommands.psm1`, and the `validate` dispatch row in `Invoke-DocsCommand.ps1` is updated. Only then do they change:
  - With `-WriteReceipt` and no `-Revision`, the revision defaults to the snapshot `revision`. When the snapshot revision is null or absent, a usage error names `inventory -Revision`.
  - `-Help` and `docs/engineering/documentation-estate/command-reference.md` state the default.
  - In `docs-complete` mode, `validate` applies the rule against the repository `HEAD` through new bounded command-context members in `Invoke-DocsCommand.ps1`. A denial is reported as an error finding, so a drifted estate cannot be written as a pass receipt.
  - Without `-WriteReceipt`, `-Revision` remains required. The MCP `validate_docs_artifacts` path, which passes `-Revision` and never persists a receipt, keeps its behavior.
- The unused `Get-DocsReceiptGateDecision` (`DocsReceipt.psm1`) either delegates to the new function or is left unchanged with its tests. The planner records the choice.

### A5. Skill stages and contracts

`.claude/skills/documentation-workflow/SKILL.md` and its mirrors gain a final root-owned section, `## Commit, Receipt and Pull Request`, placed after `## Dispatch Order`. It is not a dispatch row, so the existing dispatch-order test is unchanged. Steps:

1. Commit after docs-init and again after docs-complete, using `git add -- <paths>` and `git commit -F <file>` with no pathspec on the commit.
2. Write the receipt with `validate -Mode docs-complete -WriteReceipt`, using the default revision, and commit it with the same command shape.
3. Push.
4. Delegate `Agent(pr-author)` with the delegation-prompt contract: one `branch: <name>` line, one `base: <branch>` line, the `Canonical issue number for this feature is <N>.` line, `Author-asserted autoclose issues: #<N>`, and `gh pr create --head <branch> --base <base>`.

Rules stated in the stage:

- A docs run that opens a PR requires a tracking issue, so `<N>` in `artifacts/pr_body_<N>.md` and its receipt is defined before the PR exists.
- A session root that holds another item's checkpoint makes every docs leg decline. This is intended fail-closed behavior; run the docs stage from a root without a checkpoint.
- Only docs path set changes may be on the branch. Any other path is denied at commit, PR creation, and merge.

A `## Refresh After Rebase or Source Change` section lists, in order: re-inventory at the new revision; regenerate reference pages; update `surface_refs` of hand-written pages for added and removed elements; re-review changed elements; rebuild the ledger; re-validate; write a new receipt.

`.claude/skills/pr-author/SKILL.md` and its mirrors gain a section after `## Coordinator-Session Topology (issue #1011)` that documents the checkpoint-free docs-estate delegation-prompt contract and its preconditions (profile, docs-only diff against the explicit base, passing receipt). The `.claude/skills/execution-environment/SKILL.md` brief and all its byte-identical copies gain a docs-estate legs bullet in `## Hook Execution Context`, beside the cleanup-legs bullet. The bullet covers the A1 leg, the receipt Write, the A2 leg, and the A3 constant. The brief's `## Contract Tests That Pin Mirrored Files` lists the new suites. Non-Claude skill copies contain no `.claude/` text and reference only dispatch-table options.

## Inputs / Outputs

- Inputs: `docs/documentation-estate/docs-profile.json`; the receipt at `artifact_paths.validation_receipt`; the surface snapshot `revision`; the delegation prompt's `branch:` and `base:` lines; the staged index; git ancestry and diff output through bounded seams.
- Outputs: allow or deny hook decisions with named sub-codes; docs-init writes at the new destinations; receipts whose revision is the snapshot revision; skill text.
- Config keys: `surface_selection.source_roots`, `documentation_roots[].path`, and `artifact_paths.*` (read only; the schema is unchanged).
- Compatibility: repositories without a docs profile see unchanged deny text on every gate. Existing estates that already hold root-level `.vale.ini` or `.markdownlint.json` are not migrated. The consumer-onboarding documentation states the new locations.

## API / CLI Surface

- `Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete -WriteReceipt`: `-Revision` is optional and defaults to the snapshot revision.
- `Invoke-DocsCommand.ps1 -Command validate` without `-WriteReceipt`: `-Revision` remains required.
- `Get-DocsReceiptRevisionDecision` (new, pure) and `Get-OrchestrationDocsEstateContextResult` (new, never throws).
- Delegation-prompt contract for a checkpoint-free `Agent(pr-author)`: `branch: <name>` and `base: <branch>`, each exactly once.

## Data & State

- No orchestration checkpoint is written by a docs run.
- Receipt `revision` equals the snapshot `revision`. Its validity against a later head is decided by the A4 rule, not by equality with the head.
- Linter configuration moves under `docs/documentation-estate/` for new inits only. No migration is performed.

## Constraints & Risks

- Every new allow leg is fail-closed and ordinal. Prefilters run before any I/O. Every git call is bounded, and a timeout or error denies.
- New code and tests are PowerShell. Enforcement hooks invoke no Python.
- Mirrors stay in parity: `.claude/`, `.codex/`, `.agents/`, `.github/`, and the push-down bundles under `extensions/drm-copilot/resources/`. The Claude `core.json` pack manifest lists the new files, and the Codex manifest is regenerated through `scripts/dev_tools/generate_codex_agent_variants.py`.
- File size: `DocsLedgerCommands.psm1` is at 785 lines, so the validate command is extracted before any change. `hook-docs-only-diff.ps1` and the Codex main gate cross the 500-line guidance tier only.
- Issue #1160 concurrently edits the Claude main preimplementation gate. The A1 edit to it is limited to the guarded dot-source and the call site.
- Tests run in parallel only. No test may depend on order. Suites dot-sourcing hook files remove their functions in `AfterAll`, set no environment variables, and use no temporary files. Fixtures use forward-slash relative paths and `/`-rooted synthetic roots, so the Linux CI job passes.
- Evidence is append-only. Every timestamp is read from the clock. No artifact encodes an absolute path.
- A2 adds bounded git calls to every checkpoint-free pr-author delegation in a repository with a docs profile.

## Verification Model

Isolated subagents run `main`'s hooks, so a live run on this branch cannot exercise the new legs. Before merge, behavior is proven by Pester suites for each leg and by a composed end-to-end Pester scenario that drives the A1, A2, A3 (E7 and M9), and A4 decision functions in sequence for one synthetic docs branch through injected seams. No acceptance criterion requires a live post-merge run.

## Acceptance Criteria

Each criterion names the Pester suite intended to prove it. Suite names under `tests/scripts/` are the planned names; the planner may adjust a name but must keep one named suite per criterion.

### A1

- [ ] With no checkpoint at R, a structurally valid profile, and every operand in the docs path set, `git add -- <paths>` is allowed by the Claude and Codex preimplementation gates. Suites: `claude-hooks/enforce-orchestration-preimplementation-gate.DocsEstate.Tests.ps1` and `codex-hooks/enforce-orchestration-preimplementation-gate-docs.Tests.ps1`.
- [ ] With the same preconditions and a readable, non-empty staged index entirely in the docs path set, `git commit -F <file>` with no pathspec is allowed by both gates. Same suites.
- [ ] Each of the following denies, and the deny reason ends with the docs-estate suffix naming the listed sub-code: an invalid profile (`DOCS_LEG_PROFILE_INVALID`); an add operand outside the docs path set (`DOCS_LEG_PATH_NOT_ALLOWED`); an unreadable or non-NUL-terminated staged index (`DOCS_LEG_STAGED_INDEX_UNREADABLE`); an empty staged index (`DOCS_LEG_STAGED_INDEX_EMPTY`); a staged path outside the docs path set (`DOCS_LEG_STAGED_PATH_NOT_ALLOWED`). Same suites.
- [ ] A path under a documentation root outside `docs/` is allowed only when it ends in `.md`, and a non-`.md` path under that root denies with `DOCS_LEG_PATH_NOT_ALLOWED`. Suites: the same gate suites and `claude-hooks/hook-docs-estate-context.Tests.ps1`.
- [ ] A docs-path `git add` chained with a `pytest`, `ruff`, or `Invoke-Pester` segment, a commit that carries a pathspec, and a commit with any option other than `-m`, `--message`, `-F`, `--file`, or `--trailer` each deny with the existing deny text and an empty docs suffix. Same gate suites.
- [ ] With a checkpoint present at R, ready or not, the docs leg does not allow, and the gate's existing checkpoint-governed behavior is unchanged. Same gate suites.
- [ ] Without a profile file at R, every gate deny reason is byte-identical to the reason produced before this change. Same gate suites.
- [ ] A Write to `artifacts/pr_body_<N>.receipt.json` with no checkpoint and a valid profile at R is allowed. The same Write denies with no profile, with an invalid profile, or with a checkpoint present, and a Write to any other `.json` path is not admitted by the docs leg. Same gate suites.
- [ ] The existing cleanup-leg suites (`claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1`, `codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1`) pass unchanged.
- [ ] `hook-docs-estate-context.ps1` and `enforce-orchestration-preimplementation-gate-docs.ps1` are byte-identical across `.claude/hooks/`, `.codex/hooks/`, and both push-down bundles. Suite: `claude-hooks/hook-docs-estate-context.Parity.Tests.ps1`, together with the existing push-down contract tests.

### A2

- [ ] A checkpoint-free `Agent(pr-author)` whose prompt carries exactly one `branch:` line and exactly one `base:` line is allowed when the profile is valid, the `<base>...HEAD` diff is non-empty and entirely in the docs path set, and the receipt passes with the A4 rule. Suite: `claude-hooks/enforce-model-routing-receipt.DocsEstate.Tests.ps1`.
- [ ] A base other than `main` (for example an epic integration branch) is accepted when the other conditions hold. Same suite.
- [ ] Each of the following denies with the named sub-code: a missing or duplicated `branch:` line, a missing or duplicated `base:` line, or a value containing `..` (`DOCS_DELEGATION_LABEL_INVALID`); an invalid profile (`DOCS_DELEGATION_PROFILE_INVALID`); an unresolvable `origin/<base>` or `HEAD`, a git timeout, or a non-NUL-terminated diff (`DOCS_DELEGATION_DIFF_UNREADABLE`); an empty diff (`DOCS_DELEGATION_DIFF_EMPTY`); a diff path outside the docs path set (`DOCS_DELEGATION_PATH_NOT_ALLOWED`); a receipt that is absent, unreadable, of the wrong kind or mode, or not `pass` (`DOCS_DELEGATION_RECEIPT_INVALID`); a receipt that fails the A4 rule (the A4 reason code). Same suite.
- [ ] With a checkpoint present, the docs leg does not apply and the existing receipt check governs. Without a profile file, the deny text is byte-identical to the text produced before this change. Same suite.
- [ ] The cleanup delegation exemption keeps its behavior. Suite: the existing `claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1` passes unchanged.

### A3

- [x] `docs-init -Write` plans and writes the markdownlint and Vale files under `docs/documentation-estate/` and writes `.github/workflows/_docs-quality.yml`. It writes no `.markdownlint.json`, `.vale.ini`, or `.vale/` at the repository root. Suites: `claude-lib/docs/DocsPageTemplates.Tests.ps1`, `claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1`, and `claude-lib/docs/DocsProfileCommands.Tests.ps1` (updated).
- [x] `Get-DocsOnlyPathViolation` reports no violation for a path list of `docs/` paths plus `.github/workflows/_docs-quality.yml`. It reports a violation when one further non-`docs/` path is added, and when a path differs from the constant only by case, by a prefix, or by a suffix. Suites: `claude-hooks/hook-docs-only-diff.Tests.ps1` and `codex-hooks/hook-docs-only-diff.Tests.ps1`.
- [x] E7 allows a docs-only PR whose diff is `docs/` paths plus the workflow path, and denies with `DOCS_ONLY_EXEMPTION_NON_DOCS_PATH` when one extra non-docs path is present. Suite: `claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1`.
- [x] M9 allows the same docs-plus-workflow diff and denies the same diff with one extra non-docs path, on both runtimes. Suites: `claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` and `codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1`.
- [x] `$script:DocsOnlyInitWorkflowPath` equals the workflow destination row returned by `Get-DocsInitTemplate`. Suite: `claude-hooks/hook-docs-only-diff.InitWorkflowParity.Tests.ps1`.
- [ ] `docs-init/SKILL.md` (all copies) and `consumer-onboarding.md` state the new configuration locations and the `--config` usage for Vale and markdownlint, and they state that no workflow step runs the linters. Suite: a skill-text assertion in `claude-runtime/docs-authoring-roles.Skills.Tests.ps1` (extended).

### A4

- [x] `Get-DocsReceiptRevisionDecision` allows when the receipt revision equals the snapshot revision, is an ancestor of the head, and no changed path lies under a source root. It also allows when the head equals the receipt revision. Suite: `claude-lib/docs/DocsReceiptRevision.Tests.ps1`.
- [x] The function denies with `RECEIPT_REVISION_SNAPSHOT_MISMATCH`, `RECEIPT_REVISION_NOT_ANCESTOR`, `RECEIPT_SOURCE_DRIFT` (listing drifted paths, including a path under a source root reached through a segment-anchored match only), and `RECEIPT_REVISION_UNRESOLVED` (null ancestry input). Each message names the refresh procedure. Same suite.
- [x] A property test over generated revisions, ancestry values, changed-path sets, and source roots shows that the function allows exactly when equality, ancestry, and the absence of drift all hold. Suite: `claude-lib/docs/DocsReceiptRevision.Properties.Tests.ps1`.
- [ ] `Test-DocsCompleteGateReceipt` accepts a pass receipt whose revision is an ancestor of the PR head with no source drift, and it denies a receipt whose source drifted and a receipt whose revision is not an ancestor. Suites: `claude-lib/docs/DocsCompleteGate.Tests.ps1` and `claude-hooks/enforce-docs-complete-gate.Tests.ps1` (updated; the earlier head-equality cases are revised to the new rule).
- [ ] `Test-DocsValidateArgument` and `Invoke-DocsValidateCommand` reside in `DocsValidateCommands.psm1`, the `validate` dispatch row resolves to that module, and `DocsLedgerCommands.psm1` no longer defines them. Suite: `claude-lib/docs/DocsValidateCommands.Tests.ps1`, with the existing `DocsLedgerCommands.Validate.Tests.ps1` cases moved or retargeted.
- [ ] `validate -Mode docs-complete -WriteReceipt` without `-Revision` writes a receipt whose `revision` equals the snapshot revision. It returns a usage error naming `inventory -Revision` when the snapshot revision is null or absent. `validate` without `-WriteReceipt` still requires `-Revision`. Suites: `claude-lib/docs/DocsValidateCommands.Tests.ps1` and `claude-lib/docs/DocsLedgerCommands.Properties.Tests.ps1` (the docs-complete plus `-WriteReceipt` row is given its deliberate disposition).
- [ ] In docs-complete mode, `validate` reports an error finding and writes no pass receipt when the snapshot revision is not an ancestor of the repository `HEAD` or when source paths drifted. Suite: `claude-lib/docs/DocsValidateCommands.Tests.ps1`.
- [ ] `validate -Help` output states that `-Revision` defaults to the snapshot revision under `-WriteReceipt`. Same suite.

### A5

- [ ] Every copy of `documentation-workflow/SKILL.md` contains `## Commit, Receipt and Pull Request`, with the commit, receipt, push, and delegation steps in that order, the delegation-prompt contract (`branch:`, `base:`, the canonical issue line, `Author-asserted autoclose issues:`, `gh pr create --head <branch> --base <base>`), and the tracking-issue rule. Every copy also contains `## Refresh After Rebase or Source Change`, with the refresh steps in the order stated in `## Behavior`. The existing dispatch-order and option-reference assertions still pass. Suite: `claude-runtime/documentation-workflow.CommitStage.Tests.ps1`.
- [ ] Every copy of `pr-author/SKILL.md` documents the checkpoint-free docs-estate delegation-prompt contract after `## Coordinator-Session Topology (issue #1011)`. Suite: `claude-runtime/pr-author-docs-estate-delegation-contract.Tests.ps1`. The existing pr-author contract suites pass.
- [ ] The execution-environment brief copies remain byte-identical and contain a docs-estate legs bullet in `## Hook Execution Context`, and `cleanup-merged-worktrees.SkillText.Tests.ps1` still passes. Suites: `dev_tools/test_execution_environment_brief_contracts.py` (existing contract test, run unchanged) and the existing cleanup skill-text suite.

### End-to-end and cross-cutting

- [ ] A composed scenario for one synthetic docs branch, with no checkpoint, a valid profile, `docs/` pages, estate artifacts, and the docs-init workflow, runs through the following sequence with injected seams: the A1 gate allows `git add` and `git commit` of the init outputs and of the docs-complete estate; the A1 gate allows the pr-author receipt Write; the A2 leg allows `Agent(pr-author)`; E7 allows `gh pr create`; and M9 and the A4-based docs-complete gate allow the merge. The same scenario with one added non-docs path denies at commit, at delegation, at PR creation, and at merge. Suite: `claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1`.
- [ ] No new or changed hook invokes Python. Suite: the existing `claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`. Each new hook uses the guarded dot-source pattern. Suite: the existing `claude-runtime/hook-dependency-guard-completeness.Tests.ps1`.
- [ ] The push-down resource and pack-manifest contract tests pass with the new Claude and Codex files, and the Codex generator `--check` reports no drift.
- [ ] The full toolchain loop passes in a single pass, with parallel test execution only. Every new or changed PowerShell production file has line coverage at or above 85%, measured from the Pester coverage report, and coverage does not regress on changed lines.

## Implementation Strategy

- New files: `enforce-orchestration-preimplementation-gate-docs.ps1` and `hook-docs-estate-context.ps1` (each in four copies); `DocsReceiptRevision.psm1` and `DocsValidateCommands.psm1` (each with a Claude bundle copy); optionally an `enforce-model-routing-receipt` docs sibling.
- Changed files: both main preimplementation gates (guarded dot-source and call site only), `hook-docs-only-diff.ps1` (four copies), `enforce-model-routing-receipt.ps1`, `enforce-docs-complete-gate.ps1`, `DocsCompleteGate.psm1`, `DocsLedgerCommands.psm1` (extraction), `Invoke-DocsCommand.ps1`, `DocsProfileCommands.psm1`, the skill copies named above, the engineering documentation pages (`consumer-onboarding.md`, `command-reference.md`, `workflow.md`), and the pack manifests.
- No dependency changes. Rollout is by merge. No feature flag is needed, because every leg is inert without a docs profile.

## Definition of Done

- [ ] All acceptance criteria above are checked off with evidence.
- [ ] Mirrors and push-down bundles are in parity.
- [ ] The full toolchain loop passes.
- [ ] The engineering documentation and skills are updated.
- [ ] Part B items remain tracked in #1173 and none is implemented here.
