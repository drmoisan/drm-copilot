# 2026-10-30-docs-enforcement-and-ci - Plan

- **Issue:** #1034
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child `docs-enforcement-and-ci`, anchor label `900008`, wave 2, band C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-40
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-feature (from `issue.md`)
- **Requirements sources:** `spec.md` and `user-story.md` (acceptance criteria), `issue.md`, `research/research.2026-10-30.md`, `docs/features/epics/documentation-estate-tooling/epic.md`, and `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` `## Decisions Later Children Must Honor`.

## Required References

- `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`
- `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/github-actions.instructions.md`
- `.claude/skills/execution-environment/SKILL.md` owns tool routes, launchers, the batch budget, hook context, and CI shape; this plan does not restate them.

## Owner Decisions and Directives (propagated verbatim)

Owner decisions (2026-10-30, verbatim): "(1) A1 to A8 are CONFIRMED as written (separate Python/config and TypeScript/.NET analyzer features with 900004 later; no docs-site build; epic separate from issue #5; integration branch from origin/main; pushed-down logic is PowerShell under .claude/lib/docs/ behind Invoke-DocsCommand.ps1; TypeScript MCP wrappers call it; reuse discovery schemas and existing PowerShell discovery libs and do not call the Python discovery runtime; no new third-party PowerShell modules). (2) D1: the PowerShell rewrite counts as a NEW planning cycle for 1022 and 1024 (and for every superseded child); each gets a fresh allowance of one planner revision and the single-pass preflight; 1024's halted preflight must be addressed in the new plan (property tests for the six pure functions). (3) D3, language exception approved by the owner: a language-native analyzer is allowed when it analyzes that same language and is pushed down only with that language's pack (python pack for Python). The PowerShell text scanner stays the always-available baseline and keeps its documented precision limit, recorded as deferred-with-owner in the coverage ledger. The Python-native analyzer (Python ast, written in Python, shipped in the python pack manifest, tested under the Python gates) is IN THE FIRST RELEASE: keep 1022 as the PowerShell baseline scanner for Python/config surfaces and add a new child for the Python-native analyzer depending on 1022, in the earliest wave its dependencies allow; the planner decides the exact split and records it. C# and TypeScript native analyzers are LATER, optional children (900004 stays the baseline TypeScript/.NET scanner). The ledger must record the analysis method (native or scanner) per finding. (4) D4: linting stays optional by default (config only, no required Node or Python linter). (5) D5: docs-complete fails closed when the inventory snapshot has no revision; an element digest covers the declaration's lines, not the whole file; the JSON output envelope gets its own schema; test PowerShell Test-Json cross-file $ref first and use self-contained schemas as the fallback. Language rule otherwise unchanged: pushed-down skills, hooks and libs are PowerShell or bash; TypeScript only for MCP and extension commands."

Owner pacing directive (verbatim): "the quota pacing limits I gave you earlier are LIFTED. Ignore the cap of 3 concurrent preparation children, the cap of 8 agents in your subtree, and the 5-minute stagger. Launch every preparation child whose dependencies are satisfied at once, and run as parallel as the epic's dependency waves allow. Three accounts are available and the coordinator switches accounts when one nears its limit, so a rate-limit or account-switch error is never a failure signal: commit your working documents, wait and retry, and continue. Keep committing working documents regularly. All other rules are unchanged (language rule and the language-native analyzer exception, no forbidden tokens in any file, planning only, stop at preflight clearance)."

The originating consumer is referred to only as "one consumer repository". Linting stays optional (D4): no task adds a required linter.

## Definitions

- `FEATURE` is `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`.
- `SCRATCH` is `<session scratchpad>/issue-1034/`; every scratch file and launcher lives there, file names start with `issue-1034-`, and evidence records the token `SCRATCH`, never a host path.
- `MERGE_BASE` is the output of `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`, derived once in P0-T2 and recorded in its evidence. Every scope diff uses `MERGE_BASE` as its ref operand.
- Branch-current Pester runs import `scripts/powershell/PoshQC/PoshQC.psd1` and call `Invoke-PoshQCTest` with `-ScanFolders`, per `## PowerShell Route and PoshQC MCP Limits` in the execution-environment skill. Pass and fail counts come from `artifacts/pester/pester-junit.xml`; per-file line coverage comes from `artifacts/pester/powershell-coverage.xml`.
- Evidence artifacts are `FEATURE/evidence/<kind>/<name>.<timestamp>.md` with a UTC write-time stamp, and carry `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`. A consumer task selects the lexicographically greatest `<name>.*.md`.

## Execution Preconditions

Execution starts only when all of the following hold; P0-T2 verifies each and stops the run as BLOCKED, with no later task checked, when any is false.

1. 1020 (docs-profile-and-artifact-schemas), including its D5 amendment cycle (`schemas/docs/v1/docs-command-envelope.schema.json`), is merged into `epic/documentation-estate-tooling-integration`.
2. OQ-1 provisional default: 1020's amendment merge supplies the two read-only command-context members `ResolveRevision` and `ReadRevisionText` in `New-DocsCommandContext` (`.claude/lib/docs/Invoke-DocsCommand.ps1`), with a 1020 test that drives both through an injected process stand-in. This plan does not edit `New-DocsCommandContext`. If the members are absent, the change of owner requires an epic update and a specification revision; the run stops as BLOCKED on 1020.
3. 1021 (`check` row), 1022 (`inventory` row, invoked by the workflow template) and 1023 (`validate` row with mode `docs-complete`, the revision option, and the write-receipt switch) are merged into the same integration branch.
4. This branch contains the integration branch head that carries items 1 to 3.
5. Execution runs in the item worktree, whose `artifacts/orchestration/orchestrator-state.json` selects the `large` route and is not terminal (batch-budget exemption; four production PowerShell files are created and two edited, each with a bundle copy).

## Upstream Contracts Relied On

Each is read from merged code in P0-T3 and recorded; task text uses the names below, and P0-T3 evidence is authoritative for the literal anchor text and the option spellings.

- 1020: dispatch-row form and the anchors `# --- 900008: surface-delta ---` (`Invoke-DocsCommand.ps1`) and `# --- 900008: docs workflow ---` (`Get-DocsInitTemplate` in `DocsProfileCommands.psm1`); `Test-DocsCommandTable`; the command function contract returning `New-DocsCommandResult`; context members `ReadText`, `ReadBytes`, `TestFile`, `WriteText`, `ResolveRevision`, `ReadRevisionText`; `ConvertFrom-DocsJsonText`, `ConvertTo-DocsCanonicalJson` (`DocsJson.psm1`); `New-DocsFinding`, `Get-DocsOrderedFinding` (`DocsFinding.psm1`); `Test-DocsRelativePath`, `Test-DocsFullRevision`, `Get-DocsBytesSha256Hex` (`DocsSurface.psm1` or the module P0-T3 records); `ConvertFrom-DocsProfileText`, `Get-DocsDefaultProfilePath`; `init` semantics and `DOCS_INIT_TARGET_EXISTS`; exit codes 0/1/2/3 with `DOCS_CLI_ARGUMENTS` and `DOCS_CLI_RUNTIME`; the envelope schema; the in-memory context builder in `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1`; the import graph of `DocsJson.psm1` and `DocsSurface.psm1` (column-0 imports only, no runtime import, no module-scope output).
- 1021: the `check` dispatch row and its option names.
- 1022: the `inventory` dispatch row and its option names.
- 1023: the `validate` dispatch row (mode, revision and write-receipt option names) and the receipt fields `artifact_kind`, `mode`, `revision`, `validation_result` persisted at `artifact_paths.validation_receipt`.

## Artifact Classification

R1 = owner directive clause (1): pushed-down skills, helpers, hooks and libs are PowerShell or bash. D = epic `### Artifact classes for this epic`. No file is TypeScript or Python; no language owner question arises.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsCompleteGate.psm1` | pushed-down helper/lib | PowerShell | R1, D |
| `.claude/lib/docs/DocsSurfaceDelta.psm1` | pushed-down helper/lib | PowerShell | R1, D |
| `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1` | pushed-down helper/lib | PowerShell | R1, D |
| `.claude/lib/docs/templates/_docs-quality.yml` | schema/config/data (consumer workflow template) | YAML | D |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one dispatch row) | pushed-down helper/lib | PowerShell | R1, D |
| `.claude/lib/docs/DocsProfileCommands.psm1` (edit: one `Get-DocsInitTemplate` row) | pushed-down helper/lib | PowerShell | R1, D |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | hook | PowerShell | R1, D |
| Bundle copies of the seven rows above under `extensions/drm-copilot/resources/claude-customizations/.claude/` | pushed-down helper/lib, hook, data (mirror) | PowerShell, YAML | R1, D |
| `.claude/settings.json` and bundle copy (edit) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `.claude/agents/feature-review.md` and bundle copy (edit) | agent | Markdown | D |
| `.codex/agents/feature-review.toml` and bundle copy under `codex-and-agents-customizations/` (edit) | agent (Codex mirror) | TOML wrapper, Markdown body | D |
| `.agents/skills/feature-review/SKILL.md` and bundle copy under `codex-and-agents-customizations/` (edit) | skill | Markdown | D |
| `.github/skills/feature-review-workflow/SKILL.md` and bundle copy under `customizations/` (edit) | skill (Copilot) | Markdown | D |
| `tests/scripts/claude-lib/docs/DocsCompleteGate.Tests.ps1`, `DocsSurfaceDelta.Tests.ps1`, `DocsSurfaceDeltaCommands.Tests.ps1`, `DocsInitTemplate.DocsWorkflow.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (edit: one `$script:ReasonPrefix` row) | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`, `DocsProfileCommands.Tests.ps1` and any docs suite P0-T3 records as enumerating the complete subcommand or init planned-write set (edit only where recorded) | test | PowerShell (Pester) | D |
| `FEATURE/**` (plan, evidence) | documentation | Markdown | D |

## Existing Asserting Tests and Dispositions

- Hook registration (`.claude/settings.json` and bundle copy): `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` is updated (B4 requires one `$script:ReasonPrefix` entry per registered Claude hook; row `'.claude/hooks/enforce-docs-complete-gate.ps1' = 'DOCS_COMPLETE_GATE_BLOCKED:'`). Unchanged because they enumerate registrations, assert membership, or assert canonical-to-bundle identity, and the new hook is built to satisfy them: `tests/scripts/claude-runtime/claude-settings.Tests.ps1` (its byte-identity test "requires one dedicated prd-feature stop-hook registration in byte-identical settings files" holds only after the P6-T1 bundle copy, so the suite runs in P6-T4, not P2-T4), `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`, `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`, `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (no new Design exemption, S8 assertion unedited), `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- `feature-review` copies: unchanged because the edit is an additive section that removes no asserted phrase and adds no tool: `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` (tools list unchanged, OQ-6 default), `test_orchestrator_state_remediation_docs.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_push_down_issue_824_follow_ups.py` (listed-copy count unchanged; the section names no consuming product), `test_codex_handoff_contract_parity.py`, `test_push_down_codex_and_agents_resource_contracts.py`.
- Generated Codex variants: no `feature-reviewer*.toml` file is edited; `scripts/dev_tools/generate_codex_agent_variants.py --check` and `test_codex_agent_wrapper_contracts.py` are unchanged.
- Pinned hashes: `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` pins no file this plan edits; unchanged.
- Dispatch row and init row: 1020's `Invoke-DocsCommand.Tests.ps1` (`Test-DocsCommandTable`, anchor order) and `DocsProfileCommands.Tests.ps1`, 1020's `Docs.Manifest.Tests.ps1`, and 1021's template-row suite. Membership and anchor-order assertions are unchanged; each assertion that P0-T3 records as enumerating the complete subcommand set or the complete init planned-write set is updated in P3-T4 or P4-T2 to include the 900008 row, with the reason "the 900008 row joins the enumerated set". Canonical-to-bundle byte identity of `.claude/lib/docs/` files is asserted by `Docs.Manifest.Tests.ps1` (1020 spec acceptance criteria), which runs in P6-T4 after the P6-T1 copy; no suite run before P6-T1 asserts that identity for a file this plan edits.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline, Preconditions, and Upstream Contracts

- [ ] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md` and `.github/instructions/github-actions.instructions.md`, and write `FEATURE/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:` and the nine paths in the order above.
- [ ] [P0-T2] Verify the five `## Execution Preconditions`, derive `MERGE_BASE`, and write `FEATURE/evidence/baseline/upstream-preconditions.<timestamp>.md`.
  - Checks: `git log --oneline MERGE_BASE..HEAD` and the presence of `.claude/lib/docs/Invoke-DocsCommand.ps1`, `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1`, `DocsProfileCommands.psm1`, `schemas/docs/v1/docs-command-envelope.schema.json` and `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1`; dispatch rows named `check`, `inventory` and `validate`; members `ResolveRevision` and `ReadRevisionText` in `New-DocsCommandContext`, and the name of the 1020 test that drives them through an injected process stand-in; the checkpoint route value.
  - Acceptance: one PASS or FAIL row per precondition. Any FAIL stops the run as BLOCKED with the failing precondition named; no later task is checked.
- [ ] [P0-T3] Read the merged upstream files named in `## Upstream Contracts Relied On` and write `FEATURE/evidence/baseline/upstream-contracts.<timestamp>.md`.
  - Records: the literal text of both 900008 anchors; the option names of the `check`, `inventory` and `validate` rows (mode, revision, write-receipt switch); the receipt `artifact_kind` value; the defining module of each 1020 function this plan calls; the in-memory context builder in `Docs.TestSupport.psm1`; the in-process function that 1020's `Invoke-DocsCommand.Tests.ps1` uses to obtain a `-Json` envelope; the function that validates an envelope against `docs-command-envelope.schema.json`; the import statements of `DocsJson.psm1`, `DocsSurface.psm1` and their closure; and every assertion in `tests/scripts/claude-lib/docs/` that enumerates the complete subcommand set or the complete init planned-write set (file and test name).
  - Acceptance: every listed item has a recorded value. A 1020 function this plan calls that does not exist, or a runtime import in the `DocsJson.psm1` or `DocsSurface.psm1` closure, stops the run as BLOCKED on 1020.
- [ ] [P0-T4] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `.claude/lib/docs/Invoke-DocsCommand.ps1`, `.claude/lib/docs/DocsProfileCommands.psm1` and `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, and write `FEATURE/evidence/baseline/pssa.<timestamp>.md`.
  - Acceptance: the artifact records the finding count per file.
- [ ] [P0-T5] Run branch-current Pester with coverage over `-ScanFolders` `tests/scripts/claude-lib`, `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime`, and write `FEATURE/evidence/baseline/pester-coverage.<timestamp>.md`.
  - Acceptance: `Output Summary:` records passed and failed counts from the JUnit file, and the numeric line coverage of `Invoke-DocsCommand.ps1` and `DocsProfileCommands.psm1` from the coverage XML.
- [ ] [P0-T6] Run Pytest without coverage over `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_completion_gate_documentation_contracts.py`, `test_orchestrator_state_remediation_docs.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_codex_handoff_contract_parity.py` and `test_codex_agent_wrapper_contracts.py`, and write `FEATURE/evidence/baseline/python-contracts.<timestamp>.md`.
  - Acceptance: the artifact records passed and failed counts. Python coverage is not captured because no Python file is in scope.
- [ ] [P0-T7] Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form with `--check` and write `FEATURE/evidence/baseline/codex-generator-check.<timestamp>.md`.
  - Acceptance: the artifact records the exit code and the generator's summary output.
- [ ] [P0-T8] Run `node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts` in `extensions/drm-copilot/` and write `FEATURE/evidence/baseline/jest-manifest.<timestamp>.md`.
  - Acceptance: the artifact records passed and failed test counts.

### Phase 1 — Pure Gate Predicates (`DocsCompleteGate.psm1`)

- [ ] [P1-T1] Create `.claude/lib/docs/DocsCompleteGate.psm1` importing only `DocsJson.psm1` and `DocsSurface.psm1` through column-0 `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '<literal>') -ErrorAction Stop` statements, writing nothing at module scope, following the module conventions of 1020 spec `### Module conventions (all files under .claude/lib/docs/)` that `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` pins, and exporting four pure functions that take strings only.
  - `Get-DocsCompleteGateEnabled -ProfileText`: `$null` returns disabled; `completion_gates.integration_pr_gate.enabled` equal to `$true` returns enabled; absent or `false` returns disabled; unparseable text or a duplicate key (from `ConvertFrom-DocsJsonText`) returns reason `PROFILE_UNREADABLE`.
  - `Get-DocsCompleteGateReceiptPath -ProfileText`: returns `artifact_paths.validation_receipt` when `Test-DocsRelativePath` accepts it, otherwise reason `RECEIPT_PATH_INVALID`.
  - `Test-DocsCompleteGateIntegrationTarget -BaseRefName -HeadRefName`: true only when the base is ordinally `main` and the head matches `^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$` (OQ-3 default).
  - `Test-DocsCompleteGateReceipt -ReceiptText -HeadRevision`: returns the first failing reason in the order `RECEIPT_ABSENT`, `RECEIPT_UNREADABLE` (parse failure or `artifact_kind` other than the value recorded in P0-T3), `RECEIPT_MODE`, `RECEIPT_FAILING`, `RECEIPT_REVISION_MISMATCH` (ordinal comparison; the message names both revisions), or allow.
  - Acceptance: the file exists with comment-based help on every exported function and stays under 500 logical lines.
- [ ] [P1-T2] Create `tests/scripts/claude-lib/docs/DocsCompleteGate.Tests.ps1` with in-memory strings only: enabled-flag cases (absent key, `false`, `true`, invalid JSON, duplicate key, `$null`), receipt-path cases (valid, absolute, parent traversal, absent), integration-target cases (matching pair, base other than `main`, head without `-integration`, head with a leading separator), each receipt reason code, and revision equality with case and length mismatches.
  - Acceptance: a branch-current Pester run of this file reports zero failures and at least one passing test per reason code in the JUnit file.

### Phase 2 — Opt-In Merge Gate Hook

- [ ] [P2-T1] Create `.claude/hooks/enforce-docs-complete-gate.ps1` following the skeleton of `.claude/hooks/enforce-epic-merge-gate.ps1`: the dependency-guard bootstrap line; one guarded single-statement import each for `../lib/hook-payload/HookPayload.psm1`, `../lib/docs/DocsCompleteGate.psm1`, `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `enforce-epic-merge-gate-command.ps1` and `hook-docs-only-diff.ps1`; the dot-source early return; and the tail.
  - `Invoke-DocsCompleteGateDecision -ToolInputRaw` calls `Get-HookDependencyFailureDecision` first, then: envelope anomaly denies; no `command` or `Test-EpicMergeGateCommandInScope` false allows with no I/O; the profile is read through the seam `Get-DocsCompleteGateFileText` at `docs/documentation-estate/docs-profile.json` under the root from the seam `Get-DocsCompleteGateRepositoryRoot` (derived from `$PSScriptRoot`, no process); absent profile or disabled gate allows with no `gh` call; `PROFILE_UNREADABLE` denies; one bounded `gh pr view [<N>] --json baseRefName,headRefName,headRefOid` through `Invoke-DocsOnlyGhExe` (number from `Get-EpicMergeGateSelectorPrNumber`); failure denies `PR_UNRESOLVED`; a `--match-head-commit` value other than `headRefOid` denies `MATCH_HEAD_MISMATCH`; a non-integration target allows; otherwise the receipt path and receipt checks deny with their reason code or allow.
  - Deny text form: `DOCS_COMPLETE_GATE_BLOCKED: <REASON_CODE>: <reason and remediation>`; decision JSON has the shape produced by `Get-EpicMergeGateAllowDecision` and `Get-EpicMergeGateBlockDecision`, exit 0. The header records the residual limits listed in spec `### Hook enforce-docs-complete-gate.ps1`.
  - Acceptance: the file exists, uses `headRefOid` and never local `git rev-parse HEAD` as the head revision, and stays under 500 logical lines.
- [ ] [P2-T2] Create `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` that dot-sources the hook, mocks `Get-DocsCompleteGateFileText`, `Get-DocsCompleteGateRepositoryRoot` and `Invoke-DocsOnlyGhExe`, builds envelopes with `ConvertTo-Json`, uses forward-slash relative paths and exact file-name case, and removes imported modules in `AfterAll`.
  - Rows: gate disabled (absent profile; `enabled` `false`) allows every command in a table holding `gh pr merge` bare, `--squash`, `--auto` and `--admin`, a `gh api` merge mutation and non-merge commands, with `Should -Invoke Invoke-DocsOnlyGhExe -Times 0`; gate enabled with an integration pull request denies `RECEIPT_ABSENT`, `RECEIPT_UNREADABLE`, `RECEIPT_MODE`, `RECEIPT_FAILING` and `RECEIPT_REVISION_MISMATCH` (text names both revisions) and allows a passing receipt whose `revision` equals `headRefOid`; `PROFILE_UNREADABLE`, `PR_UNRESOLVED`, `MATCH_HEAD_MISMATCH` and `RECEIPT_PATH_INVALID` deny; non-merge commands and a non-integration pull request allow; a payload envelope anomaly denies. Every deny asserts the reason starts with `DOCS_COMPLETE_GATE_BLOCKED:`.
  - Acceptance: a branch-current Pester run of this file reports zero failures in the JUnit file.
- [ ] [P2-T3] Register `pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1` as a new entry in the `hooks.PreToolUse` group with matcher `Bash` in `.claude/settings.json`, directly after the `enforce-epic-merge-gate.ps1` entry, and add the row `'.claude/hooks/enforce-docs-complete-gate.ps1' = 'DOCS_COMPLETE_GATE_BLOCKED:'` to `$script:ReasonPrefix` in `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`.
  - Acceptance: `.claude/settings.json` parses as JSON and the Bash group lists the new command exactly once; the test file contains the new row exactly once. Dispositions of every other asserting test are in `## Existing Asserting Tests and Dispositions`.
- [ ] [P2-T4] Run branch-current Pester over `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `PreToolUsePayload.Contract.Tests.ps1`, `enforce-docs-complete-gate.Tests.ps1`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, and write `FEATURE/evidence/regression-testing/hook-contract-suites.<timestamp>.md`.
  - Ordering: none of these suites compares the canonical and bundle copies byte for byte; at this point the bundle settings file is unchanged, so the mirror rows of the two `claude-runtime` guard suites do not yet list the new hook. `tests/scripts/claude-runtime/claude-settings.Tests.ps1` is excluded here because its test "requires one dedicated prd-feature stop-hook registration in byte-identical settings files" (`Test-PrdFeatureRegistrationContract`) fails while the two settings files differ; it runs in P6-T4 after the P6-T1 copy.
  - Acceptance: zero failures in the JUnit file; `git diff MERGE_BASE HEAD -- tests/scripts/claude-runtime` together with `git status --porcelain -- tests/scripts/claude-runtime` shows no change (no new Design exemption, S8 assertion unedited). The mirror-root checks of `hook-dependency-guard-completeness.Tests.ps1` and `hook-imported-modules-no-stdout.Tests.ps1` are re-run in P6-T4 after the mirror copy.

### Phase 3 — `surface-delta` Subcommand

- [ ] [P3-T1] Create `.claude/lib/docs/DocsSurfaceDelta.psm1` with pure functions over ordinal hashtables from `ConvertFrom-DocsJsonText`, reading no file, clock or process, and following the same 1020 module conventions as P1-T1.
  - `Compare-DocsSurfaceSnapshot -BaseSnapshot -HeadSnapshot` returns `added`, `changed` and `removed` arrays of `element_id`, each sorted ordinally; changed means a different `source_sha256`; `line_range`-only and `analysis_method`-only differences are not changes; a `$null` base is empty.
  - `Get-DocsLedgerChange -BaseLedger -HeadLedger -BasePins -HeadPins -ElementId` compares `ConvertTo-DocsCanonicalJson` of the element's ledger entry (absent to present counts) and, separately, the pins carrying that `element_id`.
  - `Get-DocsSurfaceDeltaFinding` builds findings with `New-DocsFinding`, ordered by `Get-DocsOrderedFinding`, with the codes and severities of spec `### DocsSurfaceDelta.psm1 (pure)`: `DOCS_SURFACE_UNLEDGERED_ADDITION`, `DOCS_SURFACE_UNLEDGERED_CHANGE`, `DOCS_SURFACE_REMOVED_ENTRY_RETAINED` (warning), `DOCS_SURFACE_SNAPSHOT_MISSING`, `DOCS_SURFACE_SNAPSHOT_STALE`, `DOCS_SURFACE_BASE_UNRESOLVED`; element findings name `element_id`, `kind` and `path`. These codes are fixed as a contract for 900007 and 900009.
  - Acceptance: the file exists with comment-based help on every exported function and stays under 500 logical lines.
- [ ] [P3-T2] Create `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1` with in-memory hashtables: an added `cli-command` element with an unchanged ledger yields `DOCS_SURFACE_UNLEDGERED_ADDITION` naming its `element_id`, and a head ledger entry for it yields no finding; a changed `source_sha256` with no ledger or pin change yields `DOCS_SURFACE_UNLEDGERED_CHANGE`, and a changed pin yields none; `line_range`-only and `analysis_method`-only differences yield nothing; a `$null` base makes every head element added; a removed element with an unchanged head ledger entry yields `DOCS_SURFACE_REMOVED_ENTRY_RETAINED` as a warning; and a seeded `[System.Random]` shuffle of element and ledger order produces identical output, printing the seed on failure.
  - Acceptance: a branch-current Pester run of this file reports zero failures in the JUnit file.
- [ ] [P3-T3] Create `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1` exporting `Invoke-DocsSurfaceDeltaCommand -Argument -Context`, which returns `New-DocsCommandResult`, never prints and never calls `exit`; the module follows the same 1020 module conventions as P1-T1.
  - Behavior: `Base` is checked before any read (`Test-DocsFullRevision`, or `^[A-Za-z0-9][A-Za-z0-9._/-]*$` with no `..`); a violation returns exit 2 with one `DOCS_CLI_ARGUMENTS` finding and `result` `$null`. `Profile` defaults to `Get-DocsDefaultProfilePath`; the profile is read through `Context.ReadText` and `ConvertFrom-DocsProfileText`, whose findings return exit 1. `Context.ResolveRevision` returning `$null` yields `DOCS_SURFACE_BASE_UNRESOLVED`, exit 1. Head snapshot, ledger and pins come from `Context.ReadText` at `artifact_paths`; base artifacts come from `Context.ReadRevisionText`. An absent head snapshot yields `DOCS_SURFACE_SNAPSHOT_MISSING`; an `inputs[]` digest that differs from `Get-DocsBytesSha256Hex` over `Context.ReadBytes` yields `DOCS_SURFACE_SNAPSHOT_STALE`. `result` is `{base_revision, added, changed, removed}`. Exit 0 when no `error` finding, 1 otherwise.
  - Acceptance: the file exists with comment-based help and stays under 500 logical lines.
- [ ] [P3-T4] Insert the `surface-delta` row of spec `### DocsSurfaceDeltaCommands.psm1 and the dispatch row` directly under the 900008 surface-delta anchor recorded in P0-T3 in `.claude/lib/docs/Invoke-DocsCommand.ps1`, and add the `surface-delta` entry to each assertion that P0-T3 recorded as enumerating the complete subcommand set (no test file changes when P0-T3 recorded none).
  - Acceptance: `git diff MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1` (merge base against the working tree, so committed and uncommitted edits are both seen) shows exactly one added line, directly after the anchor, and no removed line; 1020's `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`, including its `Test-DocsCommandTable` test, reports zero failures.
- [ ] [P3-T5] Create `tests/scripts/claude-lib/docs/DocsSurfaceDeltaCommands.Tests.ps1` using the in-memory context builder recorded in P0-T3, with `ResolveRevision` and `ReadRevisionText` set through `Add-Member -Force` to in-memory script blocks.
  - Cases: `-Base` values `--upload-pack=x` and `main..topic` exit 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and `result` `$null`; unresolved base exits 1 with `DOCS_SURFACE_BASE_UNRESOLVED`; absent head snapshot exits 1 with `DOCS_SURFACE_SNAPSHOT_MISSING`; changed working-tree bytes exit 1 with `DOCS_SURFACE_SNAPSHOT_STALE`; an added `cli-command` with an unchanged ledger exits 1 with `DOCS_SURFACE_UNLEDGERED_ADDITION`, and with a head ledger entry exits 0 with `result.added` containing the element; the `-Json` envelope from the in-process function recorded in P0-T3 has `result` keys `base_revision`, `added`, `changed`, `removed`; and the envelope for each tested exit path is accepted by the envelope-schema validation function recorded in P0-T3.
  - Acceptance: a branch-current Pester run of this file reports zero failures in the JUnit file.

### Phase 4 — Consumer Workflow Template

- [ ] [P4-T1] Create `.claude/lib/docs/templates/_docs-quality.yml`: `on: workflow_call` with optional input `base-ref`, plus `workflow_dispatch`; one job with `name:`, `runs-on: ubuntu-latest` and `permissions: contents: read`; `actions/checkout@v7` with `ref: ${{ github.event.pull_request.head.sha || github.sha }}` and `fetch-depth: 0`; the revision passed through `env:` as `DOCS_REVISION`, never inline in `run:`; `shell: pwsh` steps invoking `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1` with `-Command inventory` (OQ-5 default), `-Command check -Json`, `-Command validate` with mode `docs-complete`, the revision option and the write-receipt switch, and `-Command surface-delta -Base` guarded by `if:` on a non-empty `base-ref`; an optional receipt upload with `actions/upload-artifact@v7`. Option spellings come from P0-T3 evidence.
  - Acceptance: the file contains no `setup-python`, `setup-node`, `python`, `npm` or `node` token and no linter step (D4).
- [ ] [P4-T2] Insert the row `[pscustomobject]@{ Source = (Join-Path -Path $PSScriptRoot -ChildPath 'templates/_docs-quality.yml'); Destination = '.github/workflows/_docs-quality.yml' }` directly under the 900008 docs-workflow anchor recorded in P0-T3 in `Get-DocsInitTemplate` of `.claude/lib/docs/DocsProfileCommands.psm1`, and add the new destination to each assertion that P0-T3 recorded as enumerating the complete init planned-write set (no test file changes when P0-T3 recorded none).
  - Acceptance: `git diff MERGE_BASE -- .claude/lib/docs/DocsProfileCommands.psm1` (merge base against the working tree) shows exactly one added line, directly after the anchor, and no removed line; 1020's `DocsProfileCommands.Tests.ps1` reports zero failures.
- [ ] [P4-T3] Create `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` with the in-memory context: `Get-DocsInitTemplate` returns the row mapping `templates/_docs-quality.yml` to `.github/workflows/_docs-quality.yml`; `init` without `-Write` lists that destination in `result.planned_writes` and writes nothing; `init -Write` writes the template bytes; an existing destination without `-Force` yields `DOCS_INIT_TARGET_EXISTS`; the template text, read through the in-memory map from the committed bytes, sets `shell: pwsh` on every `run` step, invokes `.claude/lib/docs/Invoke-DocsCommand.ps1` with `-Command check` and `-Command validate` with `docs-complete`, passes the revision through `env:`, checks out with `fetch-depth: 0`, and contains none of the tokens listed in P4-T1.
  - Acceptance: a branch-current Pester run of this file reports zero failures in the JUnit file.

### Phase 5 — `feature-review` Documentation Surface Check

The section text is identical in every copy. It states: not applicable, with no finding, when `docs/documentation-estate/docs-profile.json` is absent on the branch head; the reviewer lists changed paths with `git diff --name-only <merge-base>..HEAD`; when a changed path lies under a profile `surface_selection.source_roots` entry, the reviewer requires the newest `<FEATURE>/evidence/qa-gates/docs-surface-delta.<timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`; an absent artifact or `EXIT_CODE: 1` raises Blocking finding `surface-change-without-ledger-change` with `Remediability: autonomous` and a `Remediability-Evidence:` line; the reviewer inspects evidence and does not rerun tooling. No tool is added to any frontmatter (OQ-6 default), and the text names no consuming product.

- [ ] [P5-T1] Add `## Documentation Surface Check` to `.claude/agents/feature-review.md` directly after the `## File Size Advisory` section.
  - Acceptance: the heading occurs once in the file; the frontmatter `tools:` list is unchanged.
- [ ] [P5-T2] Add the same section to the `developer_instructions` body of `.codex/agents/feature-review.toml` directly after its `## File Size Advisory` section, with text containing no triple single quote.
  - Acceptance: the heading occurs once in the file and the file still parses as TOML with `tomllib`.
- [ ] [P5-T3] Add the same section to `.agents/skills/feature-review/SKILL.md` and `.github/skills/feature-review-workflow/SKILL.md`, each directly after its `## File Size Advisory` section.
  - Acceptance: the heading occurs once in each file; `.github/agents/feature-review.agent.md` and every `.codex/agents/feature-reviewer*.toml` show no change in `git diff MERGE_BASE HEAD` together with `git status --porcelain`.

### Phase 6 — Push-Down Mirrors and Pack Manifest

- [ ] [P6-T1] Copy byte-for-byte to the bundle trees: the four new `.claude/lib/docs/` files, the two edited `.claude/lib/docs/` files, the hook, `.claude/settings.json` and `.claude/agents/feature-review.md` under `extensions/drm-copilot/resources/claude-customizations/`; `.codex/agents/feature-review.toml` and `.agents/skills/feature-review/SKILL.md` under `extensions/drm-copilot/resources/codex-and-agents-customizations/`; `.github/skills/feature-review-workflow/SKILL.md` under `extensions/drm-copilot/resources/customizations/`.
  - Acceptance: each of the twelve bundle paths exists.
- [ ] [P6-T2] Add `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/lib/docs/DocsCompleteGate.psm1`, `.claude/lib/docs/DocsSurfaceDelta.psm1`, `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1` and `.claude/lib/docs/templates/_docs-quality.yml` to `paths` in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, following the file's existing ordering.
  - Acceptance: the manifest parses as JSON and each of the five paths occurs exactly once.
- [ ] [P6-T3] Compute SHA-256 for every source and bundle pair from P6-T1 and write `FEATURE/evidence/other/mirror-hashes.<timestamp>.md`.
  - Acceptance: every pair has equal hashes, including the Copilot `feature-review-workflow` pair, for which no dedicated parity test exists; `## Documentation Surface Check` is present in the eight `feature-review` source and bundle files.
- [ ] [P6-T4] Run branch-current Pester over `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1`, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/claude-settings.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1` and `hook-imported-modules-no-stdout.Tests.ps1`, and write `FEATURE/evidence/regression-testing/docs-manifest-suites.<timestamp>.md`.
  - Acceptance: zero failures in the JUnit file, including the `claude-settings.Tests.ps1` test "requires one dedicated prd-feature stop-hook registration in byte-identical settings files", the mirror rows of `hook-dependency-guard-completeness.Tests.ps1` that now list `.claude/hooks/enforce-docs-complete-gate.ps1`, and `N2: mirror findings equal repository findings`.

### Phase 7 — Final QA Loop and Self-Review

Any failing step, or any step that changes a file, restarts the loop from P7-T1.

- [ ] [P7-T1] Run the PoshQC formatter over every created or edited `.ps1` and `.psm1` file and write `FEATURE/evidence/qa-gates/format.<timestamp>.md`.
  - Acceptance: `git status --porcelain` output captured before and after the run is identical (before-and-after tree observation), recorded in the artifact.
- [ ] [P7-T2] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over every created or edited PowerShell file and write `FEATURE/evidence/qa-gates/pssa.<timestamp>.md`.
  - Acceptance: zero findings for each file, with counts compared against P0-T4.
- [ ] [P7-T3] Run branch-current Pester with coverage over `-ScanFolders` `tests/scripts/claude-lib`, `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime`, and write `FEATURE/evidence/qa-gates/pester-coverage.<timestamp>.md`.
  - Acceptance: zero failures in the JUnit file; line coverage of at least 85% for each of `DocsCompleteGate.psm1`, `DocsSurfaceDelta.psm1`, `DocsSurfaceDeltaCommands.psm1` and `enforce-docs-complete-gate.ps1` in the coverage XML, with numeric values recorded; no production file excluded from measurement (`config/poshqc-coverage.json` unchanged). No branch-coverage gate applies to Pester.
- [ ] [P7-T4] Compare P0-T5 and P7-T3 coverage and write `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md`.
  - Acceptance: the artifact records baseline, post-change and new-file line coverage, and the lines added to `Invoke-DocsCommand.ps1` and `DocsProfileCommands.psm1` are covered with no decrease for either file.
- [ ] [P7-T5] Re-run the Pytest module set of P0-T6 without coverage and write `FEATURE/evidence/qa-gates/python-contracts.<timestamp>.md`.
  - Acceptance: zero failures.
- [ ] [P7-T6] Re-run the Codex generator check of P0-T7 and write `FEATURE/evidence/qa-gates/codex-generator-check.<timestamp>.md`.
  - Acceptance: exit code 0.
- [ ] [P7-T7] Re-run the Jest test of P0-T8 and write `FEATURE/evidence/qa-gates/jest-manifest.<timestamp>.md`.
  - Acceptance: zero failures.
- [ ] [P7-T8] Run three seeded shuffled file-order Pester runs in one process each over the eight touched suites (`DocsCompleteGate.Tests.ps1`, `DocsSurfaceDelta.Tests.ps1`, `DocsSurfaceDeltaCommands.Tests.ps1`, `DocsInitTemplate.DocsWorkflow.Tests.ps1`, `enforce-docs-complete-gate.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `Invoke-DocsCommand.Tests.ps1` and `DocsProfileCommands.Tests.ps1`), and a fresh single-process run over `tests/scripts`, and write `FEATURE/evidence/regression-testing/pester-isolation.<timestamp>.md`.
  - Acceptance: each seed and its file order are recorded and every run reports zero failures; an order dependence is fixed on both sides and every seed re-run.
- [ ] [P7-T9] Write `FEATURE/evidence/qa-gates/scope-check.<timestamp>.md` from `git diff --name-only MERGE_BASE HEAD` together with `git status --porcelain`.
  - Acceptance: no listed path ends in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`; every listed path outside `FEATURE/` appears in `## Artifact Classification`; no path under `.github/workflows/`, `.codex/hooks/` or `.codex/config.toml` is listed.
- [ ] [P7-T10] Scan new and edited files and write `FEATURE/evidence/qa-gates/content-checks.<timestamp>.md`.
  - Checks: no new or edited test file contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`; `@(Get-Content -LiteralPath <path>).Count` is at most 500 for each new production file; a case-insensitive `grep -i -E -e 'r[g]f|fore[c]ast'` over every changed path returns no match.
  - Acceptance: every check reports zero matches or a passing count.
- [ ] [P7-T11] After the branch is pushed, record the conclusions of `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)` and `quality-checks7 / Code Quality & Tests (3.10)` through `(3.13)` from the newest `ci.yml` run whose head commit equals the branch head, and write `FEATURE/evidence/qa-gates/ci-checks.<timestamp>.md`.
  - Acceptance: every listed context reports `success` on a full run (`CI full run` succeeded); the hook suite is evidenced on `ubuntu-latest` by `poshqc / PowerShell hook suites (Linux)` (no coverage) and coverage by `poshqc / PowerShell QC` on `windows-latest`.
- [ ] [P7-T12] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against the branch diff from `MERGE_BASE` and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md`.
  - Acceptance: one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed, the loop re-run from P7-T1, and the self-review rewritten.

## Acceptance Criteria Traceability

| AC | Source criterion | Tasks |
|---|---|---|
| E1 | Gate disabled allows; enabled denies absent, failing, or mismatched receipt with named reason | P1-T1, P2-T1, P2-T2 |
| E2 | `surface-delta` reports an added CLI command and nothing when ledgered | P3-T1, P3-T2, P3-T5 |
| E3 | Workflow template requires `pwsh` only | P4-T1, P4-T3 |
| E4 | Mirror parity for edited `feature-review` surfaces | P5-T1 to P5-T3, P6-T1, P6-T3, P7-T5 |
| T1 to T3 | Hook disabled, receipt reasons, other reasons | P2-T1, P2-T2 |
| T4, T5 | Predicate tests; import graph and guard suites | P1-T1, P1-T2, P2-T4, P6-T4 |
| T6 | Settings registration and registered-hook suites | P2-T3, P2-T4, P6-T1, P6-T4 |
| T7 to T9 | Delta addition, comparison rules, command exits | P3-T1 to P3-T5 |
| T10 | Envelope schema validation | P0-T2, P3-T5 |
| T11 | Row under anchor; added-lines-only diff | P3-T4, P4-T2 |
| T12 | Context members (supplied by 1020 under OQ-1 default) | P0-T2, P3-T5 |
| T13, T14 | Init row and template content | P4-T1 to P4-T3 |
| T15, T16 | Review section and parity suites | P5-T1 to P5-T3, P6-T3, P7-T5 to P7-T7 |
| T17 | `core.json` listing and docs manifest suites | P6-T2, P6-T4 |
| T18 | Pester line coverage | P7-T3, P7-T4 |
| T19 to T21 | File size, language scope, no temporary files | P7-T9, P7-T10 |
| T22 | CI checks | P7-T11 |

## Pre-Mortem

- Review checklists: P7-T12 walks all three templates against the branch diff; the review section is identical in every copy (Phase 5 preamble), and the delegating `feature-review` files are proven unchanged in P5-T3.
- Coverage: pure logic lives in `DocsCompleteGate.psm1`, `DocsSurfaceDelta.psm1` and the command module, all driven by in-memory tests; the hook keeps seams and decision flow, which P2-T2 drives through mocks; P7-T3 asserts 85% per new file and P7-T4 the changed lines of the two edited files; no file is excluded.
- Mirror parity: P6-T1 copies twelve files, P6-T2 lists five new paths in `core.json`, P6-T3 proves SHA-256 identity, P6-T4 runs every Pester suite that compares canonical and bundle copies (no such suite runs before P6-T1), and P7-T5 to P7-T7 run the push-down, generator and Jest manifest checks. The plan changes no fact in the execution-environment brief (no CI job, required context, tool route, or batch-budget rule changes), so no brief-update task is needed.
- File size: every new production file is designed under 500 logical lines and P7-T10 measures each; the hook delegates predicates to `DocsCompleteGate.psm1`.
- Test isolation: P7-T8 performs three seeded shuffled file-order Pester runs of the eight touched suites with each seed recorded, plus a fresh single-process run over `tests/scripts`; suites remove imported modules in `AfterAll`. The seeded Jest run is not applicable because no Jest test is new or changed, and the reversed-order Python run is not applicable because no Python test is new or changed.
- CI-only behavior: the hook suite runs on case-sensitive `ubuntu-latest`, so it uses forward-slash relative paths, exact case and no drive letter; no test reads gitignored `artifacts/` state or diffs against `origin/main`; P7-T11 records the CI conclusions.
- Evidence: execution starts only after the P0-T2 preconditions pass, so no acceptance claim rests on unmerged code; every artifact is under `FEATURE/evidence/<kind>/` with a write-time stamp and the four required fields, and records `SCRATCH` rather than a host path.

## Size Justification

The plan holds 41 tasks, one above the 40-task guideline, and stays under 400 physical lines. The task count is necessary because it covers four enforcement surfaces (hook, subcommand, workflow template, review check) across six file families with push-down mirrors, and because the brief requires per-command baseline and final-QA artifacts for PowerShell, the Python contract suites, the Codex generator check and the Jest manifest test, plus the upstream-contract evidence tasks that replace guesses about unmerged children.

## Owner Questions (open; provisional defaults planned)

- OQ-1: 1020's amendment supplies `ResolveRevision` and `ReadRevisionText` (precondition 2).
- OQ-2: strict ordinal revision equality; the receipt is an uncommitted working-tree artifact.
- OQ-3: fixed base `main` and head `epic/<slug>-integration`.
- OQ-4: Claude-only hook; no `.codex/hooks/` twin and no `.codex/config.toml` change.
- OQ-5: the workflow runs `inventory` before `check`, `validate` and `surface-delta`.
- OQ-6: no tool grant for `feature-review`; the evidence model applies.
- OQ-7: no MCP tool for `surface-delta`.

## Notes

- EVIDENCE_LOCATION_OVERRIDE_REJECTED: `<FEATURE>/evidence/coverage/` (spec coverage criterion) replaced with `<FEATURE>/evidence/qa-gates/`.
- The spec names the Linux hook job by its job id; this plan cites the check name `poshqc / PowerShell hook suites (Linux)`.
