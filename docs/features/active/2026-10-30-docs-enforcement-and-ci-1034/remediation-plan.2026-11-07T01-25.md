# 2026-10-30-docs-enforcement-and-ci - Remediation Plan (proportionate cycle 1)

- **Issue:** #1034
- **Branch:** `feature/docs-enforcement-and-ci-1034-r2`
- **Status:** Authored; `## Open Questions` resolved by the orchestrator (Option A). Executor preflight has not run.
- **Inputs:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-inputs.2026-11-07T01-25.md`, and `policy-audit`, `code-review` and `feature-audit` artifacts of the same stamp.
- **Scope:** F1, F2 and notes N1 to N6. N7 is outside this cycle.

## Execution Rules

- Commit and push after every task, including the `[expect-fail]` tasks. Each commit stages only that task's files.
- `.claude/skills/execution-environment/SKILL.md` owns tool routes, launchers, command-text restrictions and CI shape; this plan does not restate them. Its `## Batch Budget` applies through the item checkpoint `artifacts/orchestration/orchestrator-state.json`, which selects the `large` route. Under `## Hook Execution Context` a branch hook is not exercised by an isolated subagent, so hook behavior is proven only by Pester rows and by the real-process run of P2-T4.
- Language: PowerShell, YAML and Markdown only. No Python file is added or edited.
- `.claude/hooks/enforce-epic-merge-gate-command.ps1` and `.codex/hooks/enforce-epic-merge-gate-command.ps1` stay unchanged and byte-identical. All new logic stays inside `.claude/hooks/enforce-docs-complete-gate.ps1`, so no helper file, manifest row or dependency-closure entry changes.
- Every `spec.md` and `user-story.md` edit above `## Acceptance Criteria` preserves the physical line count, so the criterion positions cited by the review artifacts stay valid. New text goes after the last existing section. Acceptance criterion text and checkboxes are not edited.

## Definitions

- `FEATURE` is `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`.
- `SCRATCH` is `<session scratchpad>/issue-1034/`; scratch file names start with `issue-1034-`, and evidence records the token `SCRATCH`, never a host path.
- `MERGE_BASE` is the live output of `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`, derived in P0-T2 and re-derived before each scope comparison.
- `PLAN_HEAD` is the commit that added this plan, the output of `git log --diff-filter=A --format=%H -- FEATURE/remediation-plan.2026-11-07T01-25.md`. The `## Acceptance Criteria` sections differ from `MERGE_BASE` by check-offs made before this cycle, so the no-change acceptances of `spec.md` and `user-story.md` compare with `PLAN_HEAD`.
- `HOOK` is `.claude/hooks/enforce-docs-complete-gate.ps1`, and `HOOK_BUNDLE` is `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1`.
- `HOOK_SUITE` is `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`.
- `TOUCHED_SUITES` are `HOOK_SUITE`, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1`, `tests/scripts/claude-lib/docs/Invoke-DocsCommand.RevisionContext.Tests.ps1`, `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` and `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1`.
- The Pester count source and the baseline-relative rule are those of `FEATURE/plan.2026-10-30T18-40.md` `## Definitions`, as extended by the checkpoint rule for the latest integration merge: a failure outside `TOUCHED_SUITES` is pre-existing only when the same test fails at `MERGE_BASE` on this host. `FEATURE/evidence/regression-testing/pester-isolation.2026-11-07T01-02.md` lists the known host failures.
- Each step script that gates a value ends with an exit status that fails when any stated value fails, so the recorded `EXIT_CODE:` carries the acceptance.

## F1 Target Form Sweep

`Test-EpicMergeGateCommandInScope` admits a command through any `gh pr merge` match that is not a Structural `--disable-auto`-only match, and through any `gh api` match whose tokens name a merge mutation or a `pulls/<n>/merge` path. Each form below is one way such a command names a pull request or repository. Lookup arguments are written before the fixed `--json baseRefName,headRefName,headRefOid` suffix.

| Form | Example | Disposition |
|---|---|---|
| Number | `gh pr merge 12 --merge` | Lookup `pr view 12`, unchanged |
| Bare | `gh pr merge --squash` | Lookup `pr view`, unchanged |
| Equals-joined number | `gh pr merge --merge=12` | Lookup `pr view 12`, unchanged |
| URL | `gh pr merge https://github.com/o/r/pull/12 --merge` | Lookup with the URL token unchanged |
| Branch | `gh pr merge epic/x-integration --merge` | Lookup with the branch token unchanged |
| Selector after flags or `--` | `gh pr merge --merge -- epic/x-integration` | Same lookup as the selector form |
| Value flag before selector | `gh pr merge --subject title epic/x-integration` | Value is skipped, then same lookup |
| Short cluster | `gh pr merge -sd epic/x-integration` | Each letter read; a value letter consumes the rest of the token or the next token |
| Cluster holding a value | `gh pr merge -sb 99 epic/x-integration` | `99` is the body value, not the selector |
| Repository flag forms | `-R o/r`, `--repo o/r`, `--repo=o/r`, `-Ro/r`, `-R=o/r` | Forward as `--repo <value>` after the selector |
| Repository before the subcommand | `gh --repo o/r pr merge 12`, `gh pr -R o/r merge 12` | Read from `GlobalOptions` and forward |
| REST endpoint | `gh api -X PUT repos/o/r/pulls/12/merge` | Lookup `pr view 12 --repo o/r` |
| REST placeholder | `gh api -X PUT 'repos/{owner}/{repo}/pulls/12/merge'` | Lookup `pr view 12` |
| Wrapper or redirection | `timeout 30 gh pr merge epic/x-integration`, `sh -c 'gh pr merge epic/x-integration'`, `gh pr merge epic/x-integration > log` | Same reading; redirection tokens are not operands |
| Selector beside a disabled-auto sibling | `gh pr merge 99 --disable-auto; gh pr merge epic/x-integration --merge` | The sibling is not gated; lookup with the branch token |
| GraphQL mutation | `gh api graphql -f query='mutation{mergePullRequest(...)}'`, also `enqueuePullRequest` and `enablePullRequestAutoMerge` | Deny `PR_UNRESOLVED`: a node identifier has no selector |
| More than one gated invocation | `gh pr merge 99 --merge; gh pr merge 12 --merge`, or a merge plus a gated `gh api` | Deny `PR_UNRESOLVED`; a `--disable-auto`-only or ungated sibling does not count |
| Indeterminate match | `gh --unknown pr merge 12`, an unbalanced quote | Deny `PR_UNRESOLVED` |
| Injected arguments | `echo 12 \| xargs gh pr merge --merge` | Deny `PR_UNRESOLVED` |
| Non-literal target | `gh pr merge $PR`, `gh pr merge 12 -R $REPO` | Deny `PR_UNRESOLVED` |
| Unreadable operands | unknown flag, two selectors, dash-led selector after `--`, repository value not `OWNER/REPO` or `HOST/OWNER/REPO` | Deny `PR_UNRESOLVED` |
| Other REST shapes | an absolute URL endpoint, `--hostname`, more than one merge path | Deny `PR_UNRESOLVED` |
| Visible repository context change | `cd`, `pushd`, `chdir`, `Set-Location`, `Push-Location`, `sl`, or a `GH_REPO` or `GH_HOST` assignment anywhere in the command | Deny `PR_UNRESOLVED` unless the selector is a URL, which names its own repository |

Accepted residual limits, listed in the `HOOK` header and in `spec.md`:

- The profile and receipt are read from the local working tree.
- An ambient `GH_REPO` or `GH_HOST`, and a directory change made by an earlier Bash call, are not visible in the command text.
- A `gh` alias is not visible.
- `Test-EpicMergeGateCommandInScope` does not admit a mutation supplied from a file, a merge endpoint whose number is a variable, or an unquoted `{owner}` endpoint, because the scanner splits that token at the braces. Correcting these needs a change to the shared file, which this cycle keeps unchanged.
- A read of the merge state through `GET` on the same endpoint is treated as a merge.
- A push after the lookup is not observed unless `--match-head-commit` is passed.
- A direct `git push` to `main` is outside `gh` scope.

## F2 Read Seam Sweep

| Seam | Current behavior | Required behavior |
|---|---|---|
| Profile read in `Get-DocsCompleteGateFileText` | Failure leaves `$null`, read as absent, so the hook allows | Deny `PROFILE_UNREADABLE` with no `gh` call |
| Receipt read in the same seam | Failure leaves `$null`, reported as `RECEIPT_ABSENT` | Deny `RECEIPT_UNREADABLE`; the message states a read failure and does not claim the file is absent |
| `[System.IO.File]::Exists` pre-check | Returns false for a directory or an inaccessible path, so an existing path reads as absent | Removed; only `FileNotFoundException` and `DirectoryNotFoundException` mean absent |
| `ReadPayload` in `Invoke-DocsCompleteGateEntryPoint` | A throw leaves the process with no decision | Caught; the empty payload then denies `PAYLOAD_ANOMALY` and the function returns 0 |
| `Invoke-DocsOnlyGhExe` in `Get-DocsCompleteGatePullRequest` | Documented as never throwing, but a throw would leave no decision | Caught and treated as `PR_UNRESOLVED` |
| `Get-DocsCompleteGateRepositoryRoot` | Pure path arithmetic | No change |

Deny messages name the exception type only, so no host path reaches a decision.

## Existing Asserting Tests and Dispositions

Found by searching `tests/` for `Get-DocsCompleteGateFileText`, `Get-DocsCompleteGatePullRequest`, `enforce-docs-complete-gate`, `Documentation Surface Check`, `surface-change-without-ledger-change`, `_docs-quality`, `base-ref` and the BOM constant.

- `HOOK_SUITE`, unchanged because the lookup strings and outcomes hold: 'allows a passing receipt whose revision equals headRefOid and looks up the named pull request', 'looks up the current-branch pull request for a bare merge', the `gate disabled` rows (the target is read only after the profile enables the gate), every `denies <Code>` row with a numeric selector, 'denies MATCH_HEAD_MISMATCH when --match-head-commit differs from headRefOid', 'allows when --match-head-commit equals headRefOid', the `payload anomaly` and `entry point` rows, and the three seam rows of `Describe 'enforce-docs-complete-gate seams (issue #1034)'` (an absent file still returns `$null`). `Set-TestFileSeam` keeps its string-or-null contract because `Get-DocsCompleteGateFileText` keeps its return type.
- `HOOK_SUITE`, updated: the header sentence that no row reads beyond the hook's own file now also names the hook directory, because the seam row of P1-T2 reads that directory to force a read failure. Reason: the row needs a real failing read with no temporary file.
- Unchanged because the hook keeps its entry point, imports and prefix: `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` (asserts the `Read-ClaudeHookRawPayload` text, which stays), `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` (its `$script:ExemptHook` row), and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1`.
- `tests/scripts/claude-lib/docs/DocsCompleteGate.Tests.ps1` is unchanged because `.claude/lib/docs/DocsCompleteGate.psm1` is not edited.
- `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` is unchanged: 'runs surface-delta only when the base-ref input is supplied' asserts the `if:` line, which stays, and no test pins the `description` text. `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1` reads the committed template at run time and is unchanged. `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` asserts template byte identity, so P3-T5 copies the bundle in the same task.
- The `feature-review` copies: no test pins the check text. `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` require equal bundle text, so P3-T4 edits all eight files together. `parallel_orchestrator_surface_expectations.py` names no `feature-review` file.
- `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1` and `Invoke-DocsCommand.RevisionContext.Tests.ps1` gain or strengthen assertions only (P3-T1, P3-T2); production behavior does not change.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md` and `.github/instructions/github-actions.instructions.md`, and write `FEATURE/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:` and the seven paths in order.
- [x] [P0-T2] Fetch `origin/epic/documentation-estate-tooling-integration`, derive `MERGE_BASE`, confirm `artifacts/orchestration/orchestrator-state.json` selects the `large` route and is not terminal, and write `FEATURE/evidence/remediation-baseline/preconditions.<timestamp>.md`.
  - Acceptance: the artifact records `MERGE_BASE`, the route value, and equal SHA-256 values for each `.claude/hooks` and `.codex/hooks` pair of `enforce-epic-merge-gate-command.ps1`. Any failure stops the run as BLOCKED.
- [x] [P0-T3] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `.claude/hooks/enforce-docs-complete-gate.ps1`, `HOOK_SUITE`, `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1` and `tests/scripts/claude-lib/docs/Invoke-DocsCommand.RevisionContext.Tests.ps1`, and write `FEATURE/evidence/remediation-baseline/pssa.<timestamp>.md`.
  - Acceptance: the artifact records the finding count per file.
- [ ] [P0-T4] Run branch-current Pester with coverage over `-ScanFolders` `tests/scripts/claude-hooks` and `tests/scripts/claude-lib`, and write `FEATURE/evidence/remediation-baseline/pester-coverage.<timestamp>.md`.
  - Acceptance: `Output Summary:` records passed and failed counts and the numeric line coverage of `.claude/hooks/enforce-docs-complete-gate.ps1`. Python coverage is not captured because no Python file is in scope.

### Phase 1 — Failing Rows

- [ ] [P1-T1] [expect-fail] In `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`, add the helper `Set-TestTargetSeam` and the Contexts `merge target binding (F1)` and `merge target controls`.
  - The stand-in mocks `Invoke-DocsOnlyGhExe` and answers by the joined `GhArgs`, each ending in the fixed `--json` suffix: no selector returns head `feature/current-branch` into `development`; `99` returns a non-integration pull request; `12`, `epic/x-integration`, `https://github.com/o/r/pull/12` and `12 --repo other/repo` return head `epic/x-integration` into `main`; every other argument list exits 1. Each row runs with an enabled profile and no receipt.
  - `merge target binding (F1)` holds one row per sweep form that changes behavior. Rows that resolve assert deny `RECEIPT_ABSENT` and the exact lookup string. Rows that cannot resolve assert deny `PR_UNRESOLVED` and zero `gh` calls. Every example of a form whose disposition is not `unchanged` in the `## F1 Target Form Sweep` table is a row, using `other/repo` as the repository, except the REST placeholder, which is a control. A row for the URL exemption pairs `cd ../other` with the URL selector and asserts the URL lookup.
  - `merge target controls` holds the forms that do not change: number, bare, `--merge=12`, `gh pr merge 12 --merge 2>&1`, `gh pr merge 12 --merge; echo done`, `gh pr view 12; gh pr merge 12 --merge`, `gh pr merge --help`, the quoted REST placeholder, `gh pr merge 12 --disable-auto` (allow, zero `gh` calls), a GraphQL query with no merge mutation (allow, zero `gh` calls), and the N6 row of `## Open Questions`, in which a full-length uppercase `headRefOid` denies `PR_UNRESOLVED`.
  - Acceptance: the file parses and every row of `merge target controls` passes; P1-T3 records the failing rows.
- [ ] [P1-T2] [expect-fail] In `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`, add the Context `read failures (F2)` and the seam rows.
  - `read failures (F2)` rows: a throwing profile read denies `PROFILE_UNREADABLE` with zero `gh` calls; a throwing receipt read denies `RECEIPT_UNREADABLE` and the reason does not contain `RECEIPT_ABSENT`; a throwing `Invoke-DocsOnlyGhExe` denies `PR_UNRESOLVED`; `Invoke-DocsCompleteGateEntryPoint -ReadPayload { throw 'read failed' }` returns 0 and emits a `PAYLOAD_ANOMALY` deny. Each deny asserts the reason contains no path separator.
  - Seam rows in `Describe 'enforce-docs-complete-gate seams (issue #1034)'`: 'throws for an existing path that cannot be read as a file' reads the hook directory; 'returns $null when a parent directory does not exist' is a control.
  - Acceptance: the file parses and the control row passes; P1-T3 records the failing rows.
- [ ] [P1-T3] [expect-fail] Run branch-current Pester over `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` and write `FEATURE/evidence/regression-testing/fail-before.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Acceptance: the step script exits 1 only when every row of `merge target binding (F1)`, every row of `read failures (F2)` and the row 'throws for an existing path that cannot be read as a file' fail while every other row passes, and exits 255 otherwise. The artifact lists each failing row name. A row that passes against the current code is a task failure, because it proves nothing.

### Phase 2 — Hook Correction

- [ ] [P2-T1] Correct the read seams of `.claude/hooks/enforce-docs-complete-gate.ps1` as `## F2 Read Seam Sweep` states, and copy the file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1`.
  - `Get-DocsCompleteGateFileText` keeps its return type, removes the `Exists` pre-check, returns `$null` for `FileNotFoundException` and `DirectoryNotFoundException`, and lets every other failure propagate. `Invoke-DocsCompleteGateDecision` wraps each of its two reads and maps the failure to the deny of the sweep table. `.SYNOPSIS` and `.DESCRIPTION` text of the seam and the decision order in the header are updated.
  - Acceptance: `read failures (F2)` and `Describe 'enforce-docs-complete-gate seams (issue #1034)'` report zero failures in a branch-current Pester run; the SHA-256 of the two copies is equal.
- [ ] [P2-T2] Bind the lookup to the merged pull request in `.claude/hooks/enforce-docs-complete-gate.ps1` as `## F1 Target Form Sweep` states, and copy the file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1`.
  - `Get-DocsCompleteGateMergeTarget -CommandText` mirrors the two loops of `Test-EpicMergeGateCommandInScope`, using `Test-EpicMergeGateDisableAutoOnly` and `Test-EpicMergeGateApiMutationText`, to collect the gated invocations. It returns `Reason`, `Message`, `Selector`, `Repository` and `MatchHeadCommit`.
  - `Read-DocsCompleteGateMergeOperand` walks the record tokens from `OperandIndex` with a closed table of `gh pr merge` flags: `$script:EpicMergeGateValueFlags` for values, and `--merge`, `-m`, `--squash`, `-s`, `--rebase`, `-r`, `-d`, `--delete-branch`, `--auto`, `--admin`, `--disable-auto`, `--help` and `-h` as standalone. A flag outside the table is unreadable. `Test-CommandLineTokenLiteral` decides non-literal tokens. Redirection tokens are skipped as `Get-CommandLineInvocationOperand` skips them, and `ConvertFrom-EpicMergeGateSelector` reads an equals-joined `--merge` number.
  - `Read-DocsCompleteGateApiTarget` accepts exactly one anchored `repos/<owner>/<repo>/pulls/<n>/merge` token with an optional leading slash; `{owner}` and `{repo}` placeholders mean the local repository.
  - `Test-DocsCompleteGateContextChange` reads `Read-CommandLineInvocationSegment` records.
  - `Get-DocsCompleteGatePullRequest` takes the target and `-RepositoryRoot`, builds `pr view [<selector>] [--repo <value>] --json baseRefName,headRefName,headRefOid`, and compares the target `MatchHeadCommit` with `headRefOid`, replacing its `Test-CommandLineFlag` calls. `Get-EpicMergeGateSelectorPrNumber` is no longer called and is not edited.
  - The header decision order and `Residual limits` paragraph are updated to the sweep. The comment above the `enforce-epic-merge-gate-command.ps1` import names what the hook still uses.
  - Acceptance: every Context of `HOOK_SUITE` reports zero failures in a branch-current Pester run; `@(Get-Content -LiteralPath .claude/hooks/enforce-docs-complete-gate.ps1).Count` is at most 500, because the file-size criterion binds this file; the SHA-256 of the two copies is equal. A count above 500 stops the run as BLOCKED, because a split needs a new helper file that this plan does not list.
- [ ] [P2-T3] Run branch-current Pester over `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `PreToolUsePayload.Contract.Tests.ps1`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1`, and write `FEATURE/evidence/regression-testing/gate-rows.<timestamp>.md`.
  - Acceptance: zero failed and zero errored in the JUnit file, and the artifact records the passed count of each new Context.
- [ ] [P2-T4] Run the real-process locked-file check against a consumer copy of `.claude/hooks` and `.claude/lib` under `SCRATCH/consumer/` and write `FEATURE/evidence/regression-testing/locked-file-run.<timestamp>.md`.
  - Profile cases run the hook as a real PowerShell 7 process, fed the envelope for `gh pr merge 12 --merge` on standard input: (a) an enabled profile held open by the parent with `FileShare.None` prints a `deny` with `PROFILE_UNREADABLE`, exit 0, and no `allow`; (b) no profile prints `allow`, exit 0.
  - Receipt cases run a `SCRATCH` driver in a real process that dot-sources the hook, replaces only `Invoke-DocsOnlyGhExe` with a function returning an integration pull request, and reads real files through the real seam: (c) a receipt held with `FileShare.None` denies `RECEIPT_UNREADABLE`; (d) no receipt denies `RECEIPT_ABSENT`.
  - Acceptance: the step script exits 0 only when all four outcomes hold, and the artifact records each decision text with host paths replaced by the token `SCRATCH`.
- [ ] [P2-T5] Update the non-criterion hook design text of `FEATURE/spec.md`.
  - Edits, each keeping its physical line count: `### Hook enforce-docs-complete-gate.ps1` reuse list, decision steps 3 and 4 and residual limits; the `RECEIPT_ABSENT` and `RECEIPT_UNREADABLE` table rows, stating that a read failure on an existing file is `RECEIPT_UNREADABLE`; `## Constraints & Risks` file-size bullet, stating that target reading stays in the hook because it depends on hook-loaded functions. `## Acceptance Criteria` is not touched.
  - Acceptance: `## Acceptance Criteria` keeps its line position, and `git diff PLAN_HEAD -- FEATURE/spec.md` together with `git status --porcelain -- FEATURE/spec.md` shows no change to any line of that section.

### Phase 3 — Notes N1 to N5

- [ ] [P3-T1] (N1) In `tests/scripts/claude-lib/docs/Invoke-DocsCommand.RevisionContext.Tests.ps1`, strengthen 'returns stdout without its leading BOM and records argv ending in show and the revision-qualified path' with an ordinal comparison through `[string]::Equals` and `[System.StringComparison]::Ordinal`, replacing the `Should -BeExactly` line. No other BOM assertion exists in the suite.
  - Acceptance: the file reports zero failures in a branch-current Pester run.
- [ ] [P3-T2] (N2) In `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1`, add the row 'reports no finding for a removed element with no ledger entry at base or head' after 'reports no finding for a removed element whose entry was removed from the head ledger', with empty ledgers on both sides and no `DOCS_SURFACE_REMOVED_ENTRY_RETAINED` finding.
  - Acceptance: the file reports zero failures in a branch-current Pester run.
- [ ] [P3-T3] Re-run review mutants M5 and M10 against copies of `.claude/lib/docs/DocsSurfaceDelta.psm1` and `.claude/lib/docs/Invoke-DocsCommand.ps1` under `SCRATCH/mutants/` and write `FEATURE/evidence/regression-testing/mutant-checks.<timestamp>.md`.
  - M5 removes the head-entry condition of the `DOCS_SURFACE_REMOVED_ENTRY_RETAINED` branch of `Get-DocsSurfaceDeltaFinding`. M10 removes the leading U+FEFF strip of `Read-DocsContextRevisionText`. Each copy runs with its suite, and an unmutated control copy runs first.
  - Acceptance: the step script exits 0 only when both controls pass and the P3-T1 and P3-T2 rows are the rows that fail under their mutants. The tree is not modified.
- [ ] [P3-T4] (N3) In `## Documentation Surface Check`, replace the `EXIT_CODE: 1` condition of step 4 with any non-zero `EXIT_CODE`, in `.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, `.agents/skills/feature-review/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, and their bundle copies `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md` and `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`. In `FEATURE/spec.md`, make the same change in `## Behavior` and `Check semantics`, with line counts preserved.
  - Step 5 is unchanged, so exit codes 2 and 3 now receive the blocking verdict. The added text names no consuming product and carries no triple single quote.
  - Acceptance: the four source and bundle pairs have equal SHA-256 values; the step 4 sentence is identical in all eight files; the Codex file still parses as TOML; `.github/agents/feature-review.agent.md` and every `.codex/agents/feature-reviewer*.toml` show no change against `MERGE_BASE`.
- [ ] [P3-T5] (N4) In `.claude/lib/docs/templates/_docs-quality.yml`, correct both `base-ref` descriptions to state that a remote-tracking ref such as `origin/main` or a full revision is required, because a bare branch name does not resolve in the detached checkout. Add a comment above the `Upload the validation receipt` step stating that a changed `artifact_paths.validation_receipt` needs a matching upload path. Copy the file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/templates/_docs-quality.yml`, and note both points in `### Workflow template _docs-quality.yml` of `FEATURE/spec.md` with the line count preserved.
  - Each description stays a valid YAML plain scalar, with no colon followed by a space, and the template gains none of the tokens forbidden by `DocsInitTemplate.DocsWorkflow.Tests.ps1`.
  - Acceptance: `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1`, `DocsPageTemplates.Tests.ps1` and `Docs.Manifest.Tests.ps1` report zero failures in a branch-current Pester run; the SHA-256 of the two copies is equal.
- [ ] [P3-T6] (N5) Reconcile the non-criterion text of `FEATURE/spec.md` with `## Notes` of `FEATURE/plan.2026-10-30T18-40.md` and the owner decision on OQ-1. This task runs only after `## Open Questions` is resolved.
  - Edits, each keeping its physical line count: `## Scope`, `### DocsSurfaceDeltaCommands.psm1 and the dispatch row`, `### Workflow template _docs-quality.yml` and `## Implementation Strategy` name the merged `1034` anchors; the `Get-DocsInitTemplate` row becomes the merged repository-relative form; `### Command-context extension for base-revision reads (provisional, OQ-1)` body, `## Artifact Classification` and `## Upstream Contract Notes` state that OQ-1 resolved to option (a) on 2026-11-04; `## Owner Questions` marks OQ-1 resolved and leaves OQ-2 to OQ-7 provisional; and the metadata block records the update. That heading text stays, because `FEATURE/plan.2026-10-30T18-40.md` cites it.
  - Under option A of `## Open Questions`, append `## Reconciliation Notes` after `## Seeded Test Conditions (from potential)`, stating for each stale criterion how it was evaluated. Under option B, follow the orchestrator's instruction.
  - Acceptance: `## Acceptance Criteria` keeps its line position; `git diff PLAN_HEAD -- FEATURE/spec.md` together with `git status --porcelain -- FEATURE/spec.md` shows no changed line in that section under option A.
- [ ] [P3-T7] (N5) In `## Owner Questions` of `FEATURE/user-story.md`, state that OQ-1 is resolved and that OQ-2 to OQ-7 remain provisional, with the line count preserved, and update the metadata block. Under option A of `## Open Questions`, append `## Reconciliation Notes` for the story criterion. This task runs only after `## Open Questions` is resolved.
  - Acceptance: `## Acceptance Criteria` keeps its line position and shows no changed line under option A.

### Phase 4 — Final QA Loop and Self-Review

Any failing step, or any step that changes a file, restarts the loop from P4-T1.

- [ ] [P4-T1] Run the PoshQC formatter over `.claude/hooks/enforce-docs-complete-gate.ps1`, `HOOK_SUITE`, `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1` and `tests/scripts/claude-lib/docs/Invoke-DocsCommand.RevisionContext.Tests.ps1`, and write `FEATURE/evidence/qa-gates/format.<timestamp>.md`.
  - Acceptance: the SHA-256 of each target and the `git status --porcelain` output captured before and after the run are identical, and both comparisons are recorded.
- [ ] [P4-T2] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the P4-T1 files and write `FEATURE/evidence/qa-gates/pssa.<timestamp>.md`.
  - Acceptance: zero findings for each file, compared against P0-T3.
- [ ] [P4-T3] Run branch-current Pester with coverage over `-ScanFolders` `tests/scripts/claude-hooks` and `tests/scripts/claude-lib`, and write `FEATURE/evidence/qa-gates/pester-coverage.<timestamp>.md`.
  - Acceptance: the baseline-relative rule holds, and `.claude/hooks/enforce-docs-complete-gate.ps1` has line coverage of at least 85% in `artifacts/pester/powershell-coverage.xml`, recorded numerically. `config/poshqc-coverage.json` shows no change against `MERGE_BASE`. No branch gate applies to Pester.
- [ ] [P4-T4] Compare P0-T4 and P4-T3 and write `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md`.
  - Acceptance: the artifact records baseline, post-change and changed-line coverage of `.claude/hooks/enforce-docs-complete-gate.ps1`; coverage does not decrease and no line of a function added or changed in Phase 2 is uncovered. Lines of the script tail after the dot-source return are outside this condition, because no in-process suite reaches them.
- [ ] [P4-T5] Compute SHA-256 for the pairs of `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/lib/docs/templates/_docs-quality.yml`, the four `feature-review` surfaces and `.claude/hooks/enforce-epic-merge-gate-command.ps1` against `.codex/hooks/enforce-epic-merge-gate-command.ps1`, and write `FEATURE/evidence/other/mirror-hashes.<timestamp>.md`.
  - Acceptance: every pair is equal, and `git diff MERGE_BASE HEAD -- .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1` is empty.
- [ ] [P4-T6] Run Pytest with `--strict-markers --strict-config -n auto` over the module set of P0-T6 of `FEATURE/plan.2026-10-30T18-40.md` under `tests/scripts/dev_tools/`, and write `FEATURE/evidence/qa-gates/python-contracts.<timestamp>.md`.
  - Acceptance: zero failures. This run also serves as the `pytest -n auto` check of `## Test Isolation Checks`.
- [ ] [P4-T7] Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form with `--check` and write `FEATURE/evidence/qa-gates/codex-generator-check.<timestamp>.md`.
  - Acceptance: exit code 0.
- [ ] [P4-T8] Run the seeded shuffled file-order check of `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` and the rest of `TOUCHED_SUITES` with three distinct seeds, one process each, and write `FEATURE/evidence/regression-testing/pester-isolation-shuffled.<timestamp>.md`.
  - Acceptance: each order derives from `[System.Random]::new($seed)`; the artifact records each seed, file order and counts; every run reports 0 failed and 0 errored. An order dependence is fixed on both sides and every seed re-run.
- [ ] [P4-T9] Run `Invoke-PoshQCParallelTest` from `scripts/powershell/PoshQC/PoshQC.psd1` with `-Root` at the worktree root and the default `-WorkerCount`, and write `FEATURE/evidence/regression-testing/pester-parallel.<timestamp>.md`.
  - Acceptance: the artifact records `ExitCode`, `WorkerCount` and per-shard exit codes, and the baseline-relative rule holds; a merged `artifacts/pester/pester-junit.xml` reporting zero failures is the expected result.
- [ ] [P4-T10] Run a fresh single-process `Invoke-PoshQCTest` with `-ScanFolders` `tests/scripts` in a new PowerShell process at the worktree root, and write `FEATURE/evidence/regression-testing/pester-single-process.<timestamp>.md`.
  - Reason this run is present: `## Test Isolation Checks` of the brief requires it. The run took about 18 minutes on the last pass, so the executor starts it as a background command.
  - Acceptance: every file in `TOUCHED_SUITES` reports 0 failed and 0 errored, and every other failure meets the baseline-relative rule.
- [ ] [P4-T11] Write `FEATURE/evidence/qa-gates/scope-check.<timestamp>.md` from `git diff --name-only MERGE_BASE HEAD` together with `git status --porcelain`, listing the paths this cycle changed since the head named in `FEATURE/remediation-inputs.2026-11-07T01-25.md`.
  - Acceptance: the cycle's paths outside `FEATURE/` are exactly the hook pair, `HOOK_SUITE`, the two Phase 3 test files, the template pair and the eight `feature-review` files; no path ends in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`; and no path is under `.github/workflows/`, `.codex/hooks/` or `pack-manifests/`.
- [ ] [P4-T12] Scan the files changed in this cycle and write `FEATURE/evidence/qa-gates/content-checks.<timestamp>.md`.
  - Checks: no edited test file contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`; `@(Get-Content -LiteralPath <path>).Count` is at most 500 for `.claude/hooks/enforce-docs-complete-gate.ps1` and below 700 for `HOOK_SUITE`; the bracket-class forbidden-token scan of `P7-T10` of `FEATURE/plan.2026-10-30T18-40.md` reports no match over the cycle's files.
  - Acceptance: the step script exits 0 only when every check passes.
- [ ] [P4-T13] Re-evaluate epic criterion E1 in `FEATURE/spec.md` and `FEATURE/user-story.md` and story criteria U2 and U3 of `FEATURE/user-story.md` (defined in `## Acceptance Criteria Traceability`) against the Phase 2 evidence, and write `FEATURE/evidence/other/criteria-reevaluation.<timestamp>.md`.
  - Acceptance: one PASS or FAIL row per criterion names its evidence file. Checkboxes are not edited; the next review owns them. A FAIL row returns to the owning Phase 2 task.
- [ ] [P4-T14] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff from `MERGE_BASE` and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md`.
  - Acceptance: one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed, the loop re-run from P4-T1, and the self-review rewritten.

## Acceptance Criteria Traceability

E1 is the first epic criterion, present in both `spec.md` and `user-story.md`. U2 and U3 are the second and third story criteria of `user-story.md`.

| ID | Requirement | Implementation | Tests | Evidence |
|---|---|---|---|---|
| F1 | Lookup bound to the merged pull request | P2-T2 | P1-T1, P2-T3 | `fail-before`, `gate-rows` |
| F2 | Read failure distinct from absence | P2-T1 | P1-T2, P2-T3 | `fail-before`, `locked-file-run` |
| E1, U2 | Integration merge denied with a receipt reason | P2-T1, P2-T2 | P2-T3 | `criteria-reevaluation` |
| U3 | Named denials in their conditions | P2-T1, P2-T2 | P2-T3, P2-T4 | `criteria-reevaluation` |
| N1 | BOM assertion can fail | P3-T1 | P3-T3 | `mutant-checks` |
| N2 | Removed element with no ledger entry | P3-T2 | P3-T3 | `mutant-checks` |
| N3 | Any non-zero exit code is blocking | P3-T4 | P4-T5, P4-T6 | `mirror-hashes` |
| N4 | Template description and upload note | P3-T5 | P3-T5, P4-T5 | `mirror-hashes` |
| N5 | Spec and story reconciled | P2-T5, P3-T6, P3-T7 | Not applicable; text only | `scope-check` |
| N6 | Uppercase head revision is unresolved | Existing `-cnotmatch` check | P1-T1, P2-T3 | `gate-rows` |

## Open Questions

N5 cannot be completed without a decision, because stale text sits inside acceptance criteria and this cycle may not change that text. These criteria carry it:

| Criterion | Stale text | Stale only in criterion text |
|---|---|---|
| `spec.md`, the `surface-delta` row and added-lines criterion | `900008` anchors; "no changed or removed line" | Yes, for the wording |
| `spec.md`, the `Get-DocsInitTemplate` row criterion | `900008` anchor | No |
| `spec.md`, the Pester line coverage criterion | `<FEATURE>/evidence/coverage/`, a non-canonical path | Yes |
| `spec.md`, the CI-dependent criterion | job id `poshqc-linux-hooks`, recorded in the plan `## Notes` | Yes |
| `user-story.md`, the `surface-delta` row criterion | `900008` anchors | No |

Later children read these criteria as a contract, and the anchors they name are forbidden by `Invoke-DocsCommand.Tests.ps1` and `DocsProfileCommands.Tests.ps1`.

- Option A: keep the criterion text verbatim and append `## Reconciliation Notes` after the criteria, recording how each stale phrase was evaluated. N5 is then partly reconciled, and the stale phrases stay in the criteria.
- Option B: the owner authorizes editing the five criteria to the merged names. P3-T6 and P3-T7 then edit those lines in place, and the affected criteria are re-evaluated in P4-T13.

Every task other than P3-T6 and P3-T7 is independent of this decision.

Resolution (orchestrator, 2026-11-07): Option A. Criterion text stays verbatim under the `acceptance-criteria-tracking` rule that criterion text is preserved, and `## Reconciliation Notes` records how each stale phrase was evaluated. N5 is a non-blocking note, so a partial reconciliation does not hold this cycle. Editing the criteria is left to the owner.

Scope addition (orchestrator, 2026-11-07): N6 is included. The Phase 1 rows of `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` gain one row showing that an uppercase `headRefOid` denies `PR_UNRESOLVED`. N7 requests no change and stays outside this cycle.

## Pre-Mortem

- Review checklists: P4-T14 walks all three templates against the branch diff, and P4-T13 re-evaluates the three criteria the audit reverted.
- Coverage: every new function in the hook is driven by the Phase 1 rows, P4-T3 asserts 85% for the hook, and P4-T4 asserts no uncovered line in the changed functions; the five uncovered tail lines predate this cycle.
- Mirror parity: P2-T1, P2-T2, P3-T4 and P3-T5 copy each mirrored file in the editing task, P4-T5 proves SHA-256 identity and that the shared command file is unchanged in both runtimes, and P4-T6 and P4-T7 run the contract and generator checks. No helper file is added, so `pack-manifests/core.json` and dependency closure are unchanged. The plan changes no fact in the execution-environment brief, so no brief-update task is needed.
- File size: the `spec.md` criterion on new production files binds the hook to 500 lines; the estimated result is about 450, P2-T2 stops as BLOCKED above 500, and P4-T12 measures both the hook and `HOOK_SUITE`.
- Test isolation: P4-T8 runs a seeded shuffled file-order Pester run of `TOUCHED_SUITES` with three seeds, each seed recorded; P4-T9 runs concurrent shards; P4-T10 runs the fresh single process; and P4-T6 runs `pytest -n auto`. The seeded Jest run and the reversed-order Python run are not applicable because no Jest or Python test is new or changed. Rows use Pester mocks scoped to each `It`, and the seam rows read only committed paths.
- CI-only behavior: the hook suite runs on case-sensitive `ubuntu-latest`, so rows use exact file-name case and no drive letter; the directory read row fails with an access exception on both platforms; and the file-lock run of P2-T4 is a local Windows check, not a suite row. `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` remain owned by the S9 CI gate, which also owns the CI-dependent criterion.
- Evidence: every artifact is under `FEATURE/evidence/<kind>/` with a write-time stamp and the four required fields; fail-before evidence is P1-T3 with `ExpectedExitCode: 1`; P2-T4 records the token `SCRATCH` rather than a host path.
