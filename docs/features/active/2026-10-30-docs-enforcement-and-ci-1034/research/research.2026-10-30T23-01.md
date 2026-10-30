# docs-enforcement-and-ci (#1034) - Preparation Research

- Issue: #1034 (epic #1019 `documentation-estate-tooling`, child `docs-enforcement-and-ci`, wave 2, band C3)
- Branch: `feature/docs-enforcement-and-ci-1034`
- Mode: preparation (PowerShell design under the refined implementation-language directive)
- Sources read in full or in the cited sections: `docs/features/epics/documentation-estate-tooling/epic.md`;
  `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` and its addendum research
  `research/2026-10-30T21-45-docs-profile-powershell-design-addendum-research.md` (section 5 and section 6);
  `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/issue.md` and `spec.md`;
  the current 1021, 1022 and 1023 folders (context only).

Every path and symbol below was verified by reading the file in this worktree unless it is marked
UNVERIFIED. `.claude/lib/docs/` does not exist on this branch; every docs-lib symbol is taken from the
1020 specification and is a planned contract, not an existing file.

## 1. Requirements Baseline and Source Disagreements

### 1.1 Binding requirements for 1034

From epic `### 1034 - docs-enforcement-and-ci`, the owner decisions of 2026-10-30, and the 1020
`## Decisions Later Children Must Honor`:

- Create: consumer reusable workflow `_docs-quality.yml` (runs `Invoke-DocsCommand.ps1` `check` and
  `validate -Mode docs-complete` with `pwsh`), delivered by `init` from `.claude/lib/docs/templates/`;
  `.claude/lib/docs/DocsSurfaceDelta.psm1` and the `surface-delta` subcommand;
  `.claude/hooks/enforce-docs-complete-gate.ps1` (opt-in, PowerShell); Pester suites.
- Edit: `.claude/settings.json` (hook registration), `.claude/agents/feature-review.md` and its
  mirrors (surface-change-without-ledger-change check), `Invoke-DocsCommand.ps1` (one row).
- Acceptance (epic): the hook allows every call when disabled; when enabled it denies when the
  receipt is absent, failing, or pinned to another revision, and the deny text names the reason;
  `surface-delta` reports an added CLI command with no ledger change and reports nothing when the
  ledger records it; the workflow template requires `pwsh` only; mirror parity passes for the edited
  `feature-review` surfaces.
- Language rule: pushed-down skills, hooks and libs are PowerShell or bash; TypeScript only for MCP
  and extension commands; no new Python. Linting stays optional (D4). No new third-party PowerShell
  module (A8).

### 1.2 Disagreements found (for the orchestrator)

| # | Disagreement | Where | Effect on 1034 |
|---|---|---|---|
| S1 | The 1020 spec still uses the placeholder numbers of the first preparation: dispatch anchors `# --- 900003: inventory ---`, `# --- 900006: generate-reference ---`, `# --- 900008: surface-delta ---`; init-template anchor `# --- 900008: docs workflow ---`; profile consumer note "900008 reads `completion_gates.integration_pr_gate.enabled`". The epic now names these children 1022, 1024 and 1034. | 1020 `#### Dispatch table`, `### DocsProfileCommands.psm1`, `### Artifact schema: docs-profile` | 1034 inserts under whatever anchor text 1020 commits. 1020's own acceptance criterion pins the anchor order ("1021, 900003, 1023, 900006 and 900008"), so 1034 must not rename an anchor. Owner question OQ-6. |
| S2 | Epic `### PowerShell contracts from the re-preparation of 1020` and the 1020 spec state "the envelope has no schema file"; owner decision D5 and `### Amendment of 1020 required by D3 and D5` add `schemas/docs/v1/docs-command-envelope.schema.json`. | epic, 1020 `#### Exit codes and the -Json envelope` | `surface-delta -Json` must validate against the envelope schema once the 1020 amendment lands. The D5 text is later and governs. |
| S3 | The 1023 folder (`spec.md` version 0.2) still specifies the withdrawn Python design (`dev.docs.validate --mode --revision --write-receipt`, `mutation.commit_artifact_writes`). | 1023 `spec.md` `### Downstream constraints (binding on 900007 and 900008)` | 1034 takes the receipt contract from the epic (`### Command contract decisions from the first preparation of 1023`). The receipt-gating rule (`mode` is `docs-complete`, `validation_result` is `pass`, `revision` equals the head revision) agrees in both sources. The PowerShell spelling of the write-receipt switch is not fixed by the epic (planned `-WriteReceipt`; confirm against the re-prepared 1023). |
| S4 | The 1021 folder still places base configuration under `extensions/drm-copilot/resources/templates/docs-quality/`. | 1021 `spec.md` | Contradicts epic and 1020 (template data under `.claude/lib/docs/templates/`, not a push-down root). 1034 follows the epic. The `check` option set is not fixed anywhere in PowerShell form; 1034 uses only `-Command check` plus the shared `-Json` and `-Profile` conventions. |
| S5 | The 1022 folder (Python design) defines `--revision` and `--output` for `inventory`; the epic fixes only the subcommand name. | 1022 `spec.md` | The workflow template needs `inventory` at the head revision before `validate -Mode docs-complete` (section 4.4). The PowerShell option names (`-Revision`, `-Output`) are a dependency to confirm against the re-prepared 1022. |
| S6 | D5 says the element digest covers the declaration's source lines. The 1020 snapshot element carries `source_sha256`; the amendment may rename or redefine it. | epic `### Amendment of 1020 required by D3 and D5`; 1020 `### Artifact schema: surface-inventory-snapshot` | `surface-delta` compares "the element digest defined by the 1020 amendment" (currently `source_sha256`) as an opaque value. |

## 2. Current State Relevant to 1034

### 2.1 The 1020 docs-lib contracts 1034 builds on (planned, from the 1020 spec)

- Entry script `Invoke-DocsCommand.ps1`: parameters `-Command`, `-Json`, `-Help`, `-RepositoryRoot`,
  `ValueFromRemainingArguments` `CommandArgument`; functions `Get-DocsCommandTable`,
  `Test-DocsCommandTable`, `ConvertFrom-DocsCommandArgument`, `New-DocsCommandContext`,
  `Write-DocsFileText`, `Invoke-DocsCommandCli`. Row form
  `[pscustomobject]@{ Name; Module = (Join-Path -Path $PSScriptRoot -ChildPath '<file>'); Function; Option = @{...} }`,
  one row per line, option kinds `value`, `multi`, `switch`; function grammar
  `^Invoke-Docs[A-Za-z]+Command$`; reserved option names `Command`, `Json`, `Help`, `RepositoryRoot`.
- Command context (built for real only by `New-DocsCommandContext`): `RepositoryRoot`, `ReadText`,
  `ReadBytes`, `TestFile`, `ListFile`, `WriteText` (`create` or `overwrite`), `UtcNow`. Relative paths
  are checked with `Test-DocsRelativePath` before any context call. **There is no git, process, or
  revision-read member.**
- Exit codes 0/1/2/3; exit 2 carries exactly one `DOCS_CLI_ARGUMENTS`; exit 3 carries exactly one
  `DOCS_RUNTIME_UNSUPPORTED` or `DOCS_CLI_RUNTIME`. `-Json` prints canonical JSON
  `{command, exit_code, findings, ok, result}`.
- Init templates (`DocsProfileCommands.psm1`, `Get-DocsInitTemplate`, pure): rows
  `[pscustomobject]@{ Source = (Join-Path -Path $PSScriptRoot -ChildPath 'templates/<file>'); Destination = '<destination-relative path>' }`
  under owner anchors. `init` without `-Write` writes nothing and returns
  `{profile, planned_writes: [{path, action}]}` with `action` `create`, `overwrite` (exists and
  `-Force`) or `exists`; with `-Write` it checks every destination first and exits 1 with one
  `DOCS_INIT_TARGET_EXISTS` per existing path unless `-Force`; writes go through `Context.WriteText`.
  Q10/OQ-5 provisional default: `-Write` required, create-only unless `-Force`.
- Profile schema (`### Artifact schema: docs-profile`): `completion_gates.integration_pr_gate` is a
  closed object `{enabled: boolean}`; `artifact_paths` is a closed object with `inventory_snapshot`,
  `coverage_ledger`, `parity_matrix`, `evidence_pins`, `validation_receipt` (each relative-path);
  `repository` is `{id}`. `New-DocsStarterProfile` sets `completion_gates.integration_pr_gate.enabled`
  to `false`. **Both fields the hook needs exist; no 1020 schema amendment is required for them.**
- Receipt schema (`### Artifact schema: docs-validation-receipt`): header (`$schema`,
  `schema_version` `"1.0.0"`, `artifact_kind` `docs-validation-receipt`, `id` identifier,
  `extensions`), `mode` (`profile|ledger|matrix|docs-complete`), `repository` (identifier),
  `revision` (non-null docs common `revision`), `inputs`, `counts`, `validation_result`
  (`pass|fail`), `findings`, `issued_at`, `writer`. `pass` forbids an `error` finding. The docs
  common `revision` is copied from `schemas/discovery/v2/common.schema.json` `$defs/revision`:
  pattern `^(?:[0-9a-f]{40}|[0-9a-f]{64})$` (verified in the discovery file), so a valid receipt
  revision is full and lowercase.
- Validation helpers: `Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet`, `Test-DocsArtifactText`
  (`DocsSchema.psm1`), `ConvertFrom-DocsJsonText` (`DocsJson.psm1`), `Get-DocsRuntimeVersionError`
  (fail closed below PowerShell 7.4), `New-DocsFinding`, `New-DocsCommandResult`.
- Import graph: `DocsProfile.psm1` imports `DocsAnalyzerRegistry.psm1`, whose `Invoke-DocsAnalyzer`
  has an `-ImportModule` scriptblock whose default body is `Import-Module -Name <path> -Force -ErrorAction Stop`.

### 2.2 Existing merge-gate hook and helpers (verified)

- `.claude/hooks/enforce-epic-merge-gate.ps1`: bootstrap
  `$script:HookDependencyGuardLoadFailed ... . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1')`;
  guarded edges `../lib/hook-payload/HookPayload.psm1`, `hook-command-scanner.ps1`,
  `hook-command-invocation.ps1`, `enforce-epic-merge-gate-authorization.ps1`,
  `enforce-epic-merge-gate-resolution.ps1`, `enforce-epic-merge-gate-command.ps1`,
  `hook-docs-only-diff.ps1`, `enforce-epic-merge-gate-green-ci.ps1`. Decision function
  `Invoke-EpicMergeGateDecision -ToolInputRaw`; entry `Invoke-EpicMergeGateEntryPoint -ReadPayload`
  (scriptblock seam); dot-source guard `if ($MyInvocation.InvocationName -eq '.') { return }`; tail
  `Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'EPIC_MERGE_GATE_BLOCKED:'`.
- How it identifies an integration-to-`main` merge: it does **not** inspect branch names. Branch 2
  (`Test-EpicCheckpointAllowsMerge`) reads `artifacts/orchestration/epic-orchestrator-state.json` and
  requires `epic_merge_pr.ci_gate.conclusion == "success"` and, for an explicit number,
  `epic_merge_pr.pr_number` equal to it. Checkpoints are trusted on disk; branches 1 to 4 never call
  `gh`.
- Scope predicate (`enforce-epic-merge-gate-command.ps1`, pure, dot-sources nothing):
  `Test-EpicMergeGateCommandInScope -CommandText` (every `gh pr merge` except a structural
  `--disable-auto`-only command, and every `gh api` text naming `enqueuePullRequest`,
  `enablePullRequestAutoMerge`, `mergePullRequest` or a `pulls/<n>/merge` path) and
  `Get-EpicMergeGateSelectorPrNumber -CommandText` (digit or `/pull/<n>` selector, value flags
  skipped, `pulls/<n>/merge` for `gh api`; `$null` otherwise). Both depend on
  `Get-CommandLineInvocation` and `Get-CommandLineStructuralMatch` from `hook-command-invocation.ps1`.
- Live PR lookup: `Get-EpicMergeGateLivePrHeadSha` (`enforce-epic-merge-gate-green-ci.ps1`) and
  `Get-DocsOnlyPullRequestTarget` (`hook-docs-only-diff.ps1`) run
  `gh pr view <PR> --json headRefOid` and `--json baseRefName,headRefOid` through
  `Invoke-DocsOnlyGhExe -WorkingRoot -GhArgs [-GhInvoker]` (never throws; bounded at 7000 ms by
  `Invoke-DocsOnlyBoundedNative`; exit 124 on timeout, -1 on a missing root). Head validation:
  `Test-EpicMergeGateGreenCiObjectId` (`^[0-9a-f]{40}([0-9a-f]{24})?$`, `-cmatch`). Comparisons are
  `[string]::Equals(..., [System.StringComparison]::Ordinal)`. `--match-head-commit` is read with
  `Test-CommandLineFlag` and `Get-CommandLineFlagValue`.
- Decision factories (`enforce-epic-merge-gate-authorization.ps1`): `Get-EpicMergeGateAllowDecision`
  emits `hookSpecificOutput.permissionDecision = 'allow'`; `Get-EpicMergeGateBlockDecision -Reason`
  emits `deny` with `permissionDecisionReason`.
- Integration-branch convention: `epic/<epic-slug>-integration` created from `origin/main`
  (`.claude/skills/epic-plan/SKILL.md`, `.claude/agents/epic-planner.md`); the integration PR passes
  `--base main` (`.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, reason text
  "the integration pull request must pass --base main").

### 2.3 Hook registration and push-down (verified)

- `.claude/settings.json` `hooks.PreToolUse` has a group with `"matcher": "Bash"` whose `hooks`
  entries are `{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/<name>.ps1" }`;
  `enforce-epic-merge-gate.ps1` is in that group.
- Claude Code runs matching hooks in parallel, and for differing PreToolUse decisions "precedence is
  `deny` > `defer` > `ask` > `allow`" (Claude Code hooks reference, fetched 2026-10-30). Ordering within
  the group is therefore not significant; a deny from either merge hook blocks the command.
- `.claude/settings.json` is itself pushed down: it is listed in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and has a bundle
  copy `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`. It is a plain
  overwrite: `MERGED_RELATIVE_PATHS` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`
  lists only `config/orchestration-routing.json` and `config/blast-radius.json`; `ROOT_FOLDERS` is
  `[".claude", "config"]`. `tests/scripts/claude-runtime/claude-settings.Tests.ps1` ("requires one
  dedicated prd-feature stop-hook registration in byte-identical settings files") requires the two
  settings files to be byte-identical.
- Pack manifests: `core.json`, `csharp-legacy.json`, `csharp-modern.json`, `powershell.json`,
  `python.json`, `typescript.json` under `.../claude-customizations/pack-manifests/`. Hooks and
  `.claude/lib/*` files are listed in `core.json` `paths` (for example `.claude/hooks/enforce-epic-merge-gate.ps1`,
  `.claude/hooks/hook-docs-only-diff.ps1`, `.claude/lib/hook-payload/HookPayload.psm1`,
  `.claude/lib/mermaid/MermaidValidation.psm1`).
- Codex twin rule: there is no codified rule requiring a `.codex/hooks/` twin. Several registered
  Claude hooks have none (`enforce-mermaid-validation.ps1`, `enforce-feature-folder-order.ps1`,
  `enforce-parallel-*`), while `enforce-epic-merge-gate.ps1` has a twin registered in
  `.codex/config.toml`. The docs lib is published only in the Claude bundle (epic Q7, 1020 OQ-2), so
  a Codex twin could not import `.claude/lib/docs/`. Recommendation: no Codex twin; owner question
  OQ-3 records the consequence (Codex sessions are not gated).

## 3. Contract Tests That Pin Hooks, Settings and Mirrors (verified applicability)

| Test | Applies to 1034 | What it requires |
|---|---|---|
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) | Yes | Every distributable `.claude` file (hook, lib modules, template, settings, agent, skill) exists in the Claude bundle with equal text. |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | Yes | `.codex/agents/feature-review.toml`, `.agents/skills/feature-review/SKILL.md`, `.agents/skills/feature-review-workflow/SKILL.md` equal their Codex bundle copies. |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (`test_bundled_claude_files_are_listed_in_some_pack_manifest`) | Yes (hook) | `enumerate_bundled_claude_relative_paths` enumerates bundled agents, hooks and skills; the new hook must be listed in a manifest. Lib files are not enumerated here; 1020's `Docs.Manifest.Tests.ps1` guards them. |
| `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (`test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`, `test_claude_command_text_closure`) | Yes | Every literal `$PSScriptRoot` target of the hook, `DocsSurfaceDelta.psm1`, `DocsCompleteGate.psm1`, the template row and the dispatch row is in core; every hook named by `.claude/settings.json` is published by core. Only literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` forms. |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (S1-S9) | Yes | Discovers hooks from `.claude/settings.json` (repository and bundle roots); checks bootstrap and tail (S1), single-statement guarded edges (S2), `-ErrorAction Stop` (S3), transitive closure coverage and termination (S4), guarded pre-load of every runtime `Import-Module` in the closure (S5), dependency decision first (S6). |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (B1-B4) | Yes, **requires an edit** | B1 fails each direct edge and expects a deny naming it; B4 compares the discovered hook set with the `$script:ReasonPrefix` table by `Compare-Object`, so the new hook must be added with its prefix (`'.claude/hooks/enforce-docs-complete-gate.ps1' = 'DOCS_COMPLETE_GATE_BLOCKED:'`). |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | Yes | No interpreter invocation in `.claude/hooks` and `.claude/lib`; `&` only on a `[scriptblock]` parameter, not on a variable, member or expression. |
| `tests/scripts/claude-runtime/claude-settings.Tests.ps1` | Yes | Byte-identical settings copies; existing count assertions (Agent group, SubagentStop matcher of fifteen agents, one discovery-artifact registration) are unaffected by a new Bash-group entry. |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` ("all 16 hooks") | Not required | Fixed list; adding a row is optional and would change the title count. |
| `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` (`MIRROR_PAIRS` entry `claude-feature-review-agent`; `test_feature_review_agent_grants_mcp_artifact_validator`) | Yes | The Claude agent and its bundle copy are paired; the agent `tools` list must equal exactly `Read`, `Grep`, `Glob`, `Bash(git diff *)`, `Bash(git log *)`, `Write(/docs/features/active/**)`, `mcp__drm-copilot__validate_orchestration_artifacts`. **The check must not add a tool.** |
| `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | Yes (fragment checks) | Lists `.claude/agents/feature-review.md`, the three `feature-review-workflow` skills and their bundles, and `.codex/agents/feature-review.toml` for existing fragments; additive text keeps them green. |
| `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`, `test_ci_gate_epic_child_contracts.py`, `test_push_down_tier_rule_adoption_gate.py` | Yes (fragment checks) | Existing fragments in the feature-review agent and skills must survive. |
| `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py` | Only if `.codex/agents/feature-reviewer.toml` changes | Not edited under the recommendation. |
| Codex generator `--check` (`scripts/dev_tools/generate_codex_agent_variants.py`) | Only if `feature-reviewer.toml` changes | Not edited under the recommendation. |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`) | No | Contains no feature-review surface (searched). |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | No change | Agent tool names unchanged. |
| 1020 `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1`, `ClaudeLibModuleConvention.Tests.ps1` | Yes | Every new `.claude/lib/docs/` file (modules and the template) listed once in core and SHA-256 identical to its bundle copy; no consumer identifier digest in templates; module conventions. |
| 1020 `Invoke-DocsCommand.Tests.ps1` (anchor order) | Yes | 1034 adds a row under its anchor without renaming any anchor. |

## 4. Design

### 4.1 Consumer workflow template

- Template data file: `.claude/lib/docs/templates/_docs-quality.yml` (+ byte-identical bundle copy,
  + `core.json` entry). One row under the 1034 anchor of `Get-DocsInitTemplate` in
  `DocsProfileCommands.psm1` (anchor text as committed by 1020, currently
  `# --- 900008: docs workflow ---`, see S1):
  `[pscustomobject]@{ Source = (Join-Path -Path $PSScriptRoot -ChildPath 'templates/_docs-quality.yml'); Destination = '.github/workflows/_docs-quality.yml' }`.
  `.github/workflows/_docs-quality.yml` passes the docs `relative-path` grammar (only `.` and `..`
  segments are forbidden). Note: this edit of `DocsProfileCommands.psm1` (and its bundle copy) is not
  in the epic's 1034 "Files (edit)" list but is required by the 1020 delivery decision.
- `-Write`/`-Force` semantics follow 1020 exactly (dry run by default; existing destination yields
  `DOCS_INIT_TARGET_EXISTS` unless `-Force`). Destination in the consumer repository:
  `.github/workflows/_docs-quality.yml`.
- The file is data in this repository: GitHub Actions only runs workflows under `.github/workflows/`,
  so no workflow of this repository changes and `ci.yml` is unaffected. The feature-review rule
  `modified-workflow-needs-green-run` (`.claude/skills/feature-review-workflow/SKILL.md`) matches only
  `.github/workflows/**`, `scripts/benchmarks/**` and `.github/actions/**`, so it does not fire.
- Shape (recommended):
  - `on: workflow_call` (with an optional `profile` string input defaulting to
    `docs/documentation-estate/docs-profile.json`) and `workflow_dispatch`. A reusable workflow
    needs a caller job in the consumer CI; 900010 documents the caller snippet.
  - `permissions: contents: read`; one job on `ubuntu-latest`.
  - `actions/checkout@v7` (the tag convention used by `.github/workflows/ci.yml`) with
    `ref: ${{ github.event.pull_request.head.sha || github.sha }}` and `fetch-depth: 0`. A
    `pull_request` run otherwise checks out the merge commit, whose SHA is not the PR head
    (standard GitHub behavior; UNVERIFIED by tool here).
  - Every `run:` step declares `shell: pwsh` and invokes
    `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name> ...`:
    `check`; `inventory -Revision <head>` (1022 option names to confirm, S5); 
    `validate -Mode docs-complete -Revision <head>` plus the write-receipt switch; optionally
    `actions/upload-artifact` for the receipt.
  - No `setup-python`, `setup-node`, `python`, `pip`, `poetry`, `node`, `npm` or `npx` token; no
    linter step (D4).
- Why `inventory` is in the template although the scope names only `check` and `validate`:
  `docs-complete` fails closed with `DOCS_SNAPSHOT_UNPINNED` on a null snapshot revision and reports
  `DOCS_REVISION_MISMATCH` when a non-null snapshot revision differs from `-Revision` (epic, 1023).
  A snapshot committed to the branch can never carry the SHA of the commit that contains it, so the
  workflow must capture the snapshot at the checked-out head. Owner question OQ-2.
- Validation without a YAML module (A8): a Pester test reads the committed template text and checks
  it as lines: an `on:` block containing `workflow_call:`; each `run:` step paired with
  `shell: pwsh`; presence of `-Command check` and `-Command validate` with `-Mode docs-complete`;
  absence of the forbidden tokens above; no consumer identifier (1020 neutrality test covers
  `.claude/lib/docs/`). `scripts/dev-tools/run-actionlint.ps1` exists but no CI job runs actionlint
  (`.github/instructions/github-actions.instructions.md` names a `ci.yml` `actionlint` job that is
  absent); a local actionlint run is optional evidence only (D4).

### 4.2 `surface-delta` and base-revision access

Finding: the 1020 command context has no git, process or revision-read member, and 1020 forbids file,
clock and process access outside the context. The precedent in 1022 (Python design) is that the docs
tooling "starts no Git process" and receives the revision as an argument.

Candidate approaches:

- **A. Caller-materialized base artifacts (recommended, no contract change).** `surface-delta`
  takes `-Base <full revision>`, `-BaseSnapshot <relative path>` and `-BaseLedger <relative path>`;
  the head snapshot, head ledger and head evidence pins come from the profile `artifact_paths`. The
  command validates `-Base` with `Test-DocsFullRevision`, reads all inputs through
  `Context.ReadText`, validates them with `Test-DocsArtifactText`, and fails closed when the base
  snapshot `revision` is `null` (`DOCS_SURFACE_DELTA_BASE_UNPINNED`) or differs from `-Base`
  (`DOCS_SURFACE_DELTA_BASE_MISMATCH`). The caller (the workflow, an orchestrator, a skill) produces
  the base files, either with `git show <base>:<path>` for committed artifacts or by running
  `inventory` in a base checkout. The lib stays free of git and process access.
- **B. New context member `ReadRevisionText(param($Revision, $RelativePath))`** implemented in
  `New-DocsCommandContext` with `git show`. This edits 1020-owned code outside 1034's anchor and adds
  process access to the lib; it is a 1020 contract change. Rejected as the default; recorded as owner
  question OQ-1.
- Rejected: a 1034-owned git reader injected into the context from `Invoke-DocsCommand.ps1` (same
  contract change as B with an extra seam); resolving symbolic refs such as `origin/main` inside the
  lib (needs a process). Under A, `-Base` is a full object id, not a symbolic ref, which narrows the
  issue wording `surface-delta -Base <ref>`.

Pure comparison (`DocsSurfaceDelta.psm1`, strings and hashtables only):

- `Compare-DocsSurfaceDelta -BaseSnapshot <IDictionary> -HeadSnapshot <IDictionary> -BaseLedger <IDictionary> -HeadLedger <IDictionary> [-HeadPins <IDictionary>]`
  returns records `{element_id, kind, path, declaration, change, ledger_changed}` sorted by
  `element_id` (ordinal).
- Element index: `elements[]` keyed by `element_id`; digest is the 1020-amended element digest
  (currently `source_sha256`), compared as an opaque string. `analysis_method` is ignored, so a
  scanner-to-native switch (900011 keeps identifiers and digests equal) is not a surface change.
- `added`: id in head, not in base. `changed`: id in both, digest differs. Removed elements are not
  reported (ledger completeness is 1023's `validate` concern).
- Ledger change for an element: head ledger has an entry for the id and the base ledger has none,
  or both have an entry and their canonical JSON (`ConvertTo-DocsCanonicalJson`) differs. A
  `changed` element is also accounted for when a head evidence pin for the id records the head
  digest and the base digest differs (re-pin through `update-ledger -Operation pin`); planner
  decision whether to include `-HeadPins` in the first release (recommended: include, because a
  re-pin changes the pin collection, not the ledger entry).
- Output: one `error` finding `DOCS_SURFACE_DELTA_UNLEDGERED` per unaccounted element
  (`RelatedId` the element id, `ArtifactPath` the head ledger path); exit 0 when none, 1 otherwise;
  `result` `{base_revision, head_revision, elements: [...]}`; `-Json` envelope per 1020 (and the D5
  envelope schema once present).
- Command function `Invoke-DocsSurfaceDeltaCommand -Argument -Context`; dispatch row (one line,
  under the 1034 anchor, currently `# --- 900008: surface-delta ---`):
  `[pscustomobject]@{ Name = 'surface-delta'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurfaceDelta.psm1'); Function = 'Invoke-DocsSurfaceDeltaCommand'; Option = @{ Base = 'value'; BaseSnapshot = 'value'; BaseLedger = 'value'; Profile = 'value' } }`.
- AC mapping: an added `cli-command` with no head ledger entry yields one
  `DOCS_SURFACE_DELTA_UNLEDGERED` (exit 1); the same input with a head ledger entry yields no
  finding (exit 0).

### 4.3 Hook `enforce-docs-complete-gate.ps1`

Structure (mirrors `enforce-epic-merge-gate.ps1`): bootstrap guard; guarded single-statement edges
`../lib/hook-payload/HookPayload.psm1`, `hook-command-scanner.ps1`, `hook-command-invocation.ps1`,
`enforce-epic-merge-gate-command.ps1` (scope predicate and selector reader), `hook-docs-only-diff.ps1`
(`Invoke-DocsOnlyGhExe`), and `../lib/docs/DocsCompleteGate.psm1`; decision function
`Invoke-DocsCompleteGateDecision -ToolInputRaw`; entry `Invoke-DocsCompleteGateEntryPoint -ReadPayload`;
deny prefix `DOCS_COMPLETE_GATE_BLOCKED:`; dot-source guard and tail as in the epic gate. Seams as
named functions that tests mock: `Get-DocsCompleteGateRepositoryRoot` (current location),
`Get-DocsCompleteGateFileText -RepositoryRoot -RelativePath` (returns `$null` when absent),
`Get-DocsCompleteGatePullRequest -Selector -RepositoryRoot` (one `gh pr view [<n>] --json baseRefName,headRefName,headRefOid`
through `Invoke-DocsOnlyGhExe`).

Decision order (cheapest first; no read for an out-of-scope command):

1. Dependency failure: deny with the prefix (guard contract S6).
2. Payload anomaly (`Resolve-ClaudeHookToolInput` not valid): treated like step 4 onward with an
   unknown command: allow when the gate is not enabled, deny when enabled. This keeps "disabled
   allows every call" literally true.
3. No `command` or `Test-EpicMergeGateCommandInScope` is false: allow. No file or process access.
4. Profile: read `docs/documentation-estate/docs-profile.json` (the 1020 default; see OQ-4 for why it
   is not obtained from `Get-DocsDefaultProfilePath`). Absent: allow (not adopted). Present and not
   schema-valid (`Test-DocsArtifactText -ArtifactKind docs-profile`): deny
   `DOCS_COMPLETE_GATE_PROFILE_INVALID` (OQ-5). `completion_gates.integration_pr_gate.enabled` not
   `true`: allow.
5. Enabled: `Get-DocsRuntimeVersionError` non-null: deny `DOCS_COMPLETE_GATE_RUNTIME_UNSUPPORTED`.
6. PR resolution: number from `Get-EpicMergeGateSelectorPrNumber`; a bare `gh pr merge` uses
   `gh pr view` without a selector (current branch; gh behavior UNVERIFIED by tool); a `gh api`
   mutation with no resolvable number denies `DOCS_COMPLETE_GATE_PR_UNRESOLVED`. Lookup failure,
   unparseable output, or a `headRefOid` failing `^[0-9a-f]{40}([0-9a-f]{24})?$` denies
   `DOCS_COMPLETE_GATE_PR_UNRESOLVED`.
7. Target: in scope only when `baseRefName` is exactly `main` and `headRefName` matches
   `^epic/[A-Za-z0-9._-]+-integration$` (ordinal). Otherwise allow (OQ-7).
8. Receipt at `artifact_paths.validation_receipt`: absent: deny `DOCS_COMPLETE_GATE_RECEIPT_MISSING`
   naming the path. Not schema-valid (`docs-validation-receipt`): deny
   `DOCS_COMPLETE_GATE_RECEIPT_INVALID`. `mode` not `docs-complete`: deny
   `DOCS_COMPLETE_GATE_RECEIPT_MODE`. `repository` not equal to the profile `repository.id`: deny
   `DOCS_COMPLETE_GATE_RECEIPT_REPOSITORY`. `validation_result` not `pass`: deny
   `DOCS_COMPLETE_GATE_RECEIPT_FAILED` naming the receipt `id`. `revision` not ordinally equal to
   `headRefOid`: deny `DOCS_COMPLETE_GATE_RECEIPT_STALE` naming both values. A
   `--match-head-commit` value not equal to `headRefOid`: deny `DOCS_COMPLETE_GATE_HEAD_MISMATCH`.
   Otherwise allow.

Receipt fields used: `id` (receipt identifier, derived from content excluding `issued_at`, per epic),
`mode`, `repository`, `revision` (pin; full lowercase hex by schema), `validation_result`
(`pass`/`fail`). "Pins the head revision" means ordinal string equality between the receipt
`revision` and the live `headRefOid`; both are lowercase 40 or 64 hex by pattern, so no case folding.

Pure logic placement: `.claude/lib/docs/DocsCompleteGate.psm1` (new; imports `DocsJson.psm1`,
`DocsFinding.psm1`, `DocsSchema.psm1` only) holds `Test-DocsCompleteGateIntegrationTarget
-BaseRefName -HeadRefName`, `Get-DocsCompleteGateProfileState -ProfileText -ComposedSchemaSet`
(returns `Enabled`, `ReceiptPath`, `RepositoryId`, `Findings`) and `Get-DocsCompleteGateReceiptVerdict
-ReceiptText -ReceiptPath -HeadSha -RepositoryId -ComposedSchemaSet` (returns `Allowed`, `Code`,
`Message`). The hook keeps only payload, seams and envelope output. This module name is a research
refinement within the naming contract (`Docs<Area>.psm1`).

Why the hook must not import `DocsProfile.psm1`: `hook-dependency-guard-completeness.Tests.ps1` S5
requires every runtime `Import-Module` in a hook's closure to have a guarded hook-level pre-load of
the same target (`Get-HookDependencyClosure`, `Get-HookScriptEdge` mark an `Import-Module` inside a
function or script-block expression as `Runtime`; an unresolvable target becomes `UNRESOLVED: ...`).
`DocsProfile.psm1` imports `DocsAnalyzerRegistry.psm1`, whose `-ImportModule` default scriptblock
holds `Import-Module -Name <path>`; that edge is runtime and unresolved, so S5 would report it. This
is an inference from the 1020 spec text and `HookDependencyGraph.Helpers.ps1`, to be confirmed by
running the guard test once 1020 lands. Consequence: the hook validates the profile with
`Test-DocsArtifactText` (schema only), not `ConvertFrom-DocsProfileText`, which deviates from the
1020 decision "Profile access goes through `ConvertFrom-DocsProfileText`" (OQ-4).

Interaction with `enforce-epic-merge-gate.ps1`: both hooks are in the `Bash` PreToolUse group and
run in parallel on the same command; each must allow for the command to proceed. The docs gate does
not read orchestration checkpoints and does not replace any epic-gate branch. On a gated
integration merge the epic gate allows through branch 2 (checkpoint) and the docs gate allows only
with a passing receipt for the live head; added latency is one bounded `gh` call (at most 7 s plus
1 s output), only when the gate is enabled and the command is in scope.

Residual limits (documented in the hook help, as in the epic gate): the profile and receipt are read
from the session worktree, not from the PR head commit; an ambient `GH_REPO`/`GH_HOST` is invisible;
a push after the lookup can change the head unless `--match-head-commit` is passed; the control is
policy-level, not cryptographic. The receipt must be an untracked file (committing it changes the
head), which 900010 onboarding states (OQ-2).

### 4.4 Settings registration

Add `{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1" }`
to the `"matcher": "Bash"` PreToolUse group of `.claude/settings.json` (after
`enforce-epic-merge-gate.ps1` for readability) and make the identical edit in the bundle copy. Add
`.claude/hooks/enforce-docs-complete-gate.ps1` and `.claude/lib/docs/DocsCompleteGate.psm1`,
`.claude/lib/docs/DocsSurfaceDelta.psm1`, `.claude/lib/docs/templates/_docs-quality.yml` to
`core.json` `paths`, with byte-identical bundle copies. No `.codex/config.toml` or `.codex/hooks/`
change (OQ-3).

### 4.5 feature-review surface-change-without-ledger-change check

Where the check belongs:

- The Claude agent `.claude/agents/feature-review.md` is self-contained (it preloads only
  `policy-compliance-order` and `acceptance-criteria-tracking`), so the check is a new section there.
- The Copilot agent `.github/agents/feature-review.agent.md` states "Do not restate or override the
  shared workflow skill content" and delegates to `feature-review-workflow`; the Codex base agent
  `.codex/agents/feature-reviewer.toml` names the `feature-review` skill as its canonical workflow
  source. For those surfaces the check belongs in the skills: a new rule
  `### surface-change-without-ledger-change` under `## Policy Rules` in the three
  `feature-review-workflow` copies (alongside `modified-workflow-needs-green-run`), and the same rule in
  `.agents/skills/feature-review/SKILL.md`.
- `.codex/agents/feature-review.toml` is a "Converted subagent" whose body is a (drifted) copy of the
  Claude agent; produced by the codex-native converter (`scripts/dev_tools/codex_native_converter/pipeline.py`,
  `extensions/drm-copilot/src/lib/codex-native-converter/pipeline-render.ts`). No CI check that
  regenerates it was found (UNVERIFIED); recommended: hand-add the same section and keep its bundle
  copy identical.
- `docs/features/templates/policy_audit/` (`policy-audit.yyyy-MM-ddTHH-mm.md`,
  `code-review.yyyy-MM-ddTHH-mm.md`, `feature-audit.yyyy-MM-ddTHH-mm.md`) need no change if findings
  are reported as Findings Table rows (fixed header) and, when blocking, in the remediation inputs.

Check semantics (tools limited to Read, Grep, Glob, `git diff`, `git log`; no tool may be added):

- Applicability: `docs/documentation-estate/docs-profile.json` exists at the branch head; otherwise
  record "not applicable: no docs profile" (this repository has none, so its own reviews are
  unaffected).
- Read `surface_selection.source_roots`, `surface_selection.exclusions` and
  `artifact_paths.coverage_ledger` / `evidence_pins` from the profile; list changed files with
  `git diff --name-only <merge-base>...HEAD`.
- When a `surface-delta` result for the branch exists in the feature evidence (for example
  `<FEATURE>/evidence/other/surface-delta.<timestamp>.md` with its `-Json` output), each reported
  element is a Blocking finding (`Remediability: autonomous`) naming the element id.
- Without such a result: changed files under a source root with no change to the ledger or pin file
  are a non-blocking `Warning` row recommending `surface-delta` (file-level evidence cannot tell
  surface changes from internal edits).

Mirror set and generation (complete family enumerated in the Numeric Derivation Evidence below):

| File | Edited | Produced by | Parity guard |
|---|---|---|---|
| `.claude/agents/feature-review.md` | yes | hand-edited | `test_push_down_claude_resource_contracts.py`; `MIRROR_PAIRS` in `test_completion_gate_documentation_contracts.py` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` | yes | copy | same |
| `.codex/agents/feature-review.toml` | yes | converter output, maintained by hand (UNVERIFIED) | `test_push_down_codex_and_agents_resource_contracts.py` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | yes | copy | same |
| `.claude/skills/feature-review-workflow/SKILL.md` | yes | hand-edited | Claude resource contracts; `test_push_down_issue_824_follow_ups.py` fragments |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` | yes | copy | same |
| `.agents/skills/feature-review-workflow/SKILL.md` | yes | hand-edited | Codex resource contracts |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` | yes | copy | same |
| `.github/skills/feature-review-workflow/SKILL.md` | yes | hand-edited | `test_push_down_issue_824_follow_ups.py` fragments (no byte-parity test found for the Copilot bundle; UNVERIFIED) |
| `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md` | yes | copy | as above |
| `.agents/skills/feature-review/SKILL.md` | yes | hand-edited | Codex resource contracts; `test_codex_handoff_contract_parity.py` reads the bundle copy |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md` | yes | copy | same |
| `.github/agents/feature-review.agent.md` and its `resources/customizations` copy | no | hand-edited | delegates to the skill |
| `.codex/agents/feature-reviewer.toml` and its bundle copy | no | hand-edited base | `test_codex_agent_wrapper_contracts.py` |
| `.codex/agents/feature-reviewer-{c1,c2,c3,c3-elevated,c4}.toml` and bundle copies | no | `generate_codex_agent_variants.py` (`CORE_FAMILIES` includes `feature-reviewer`) | generator `--check` |

`scripts/dev_tools/agentic_sync.py` synchronizes `.github/{agents,hooks,instructions,prompts,skills}`
between two local repositories; it does not generate mirrors from `.claude/` and is not needed.
Because the plan must make identical additions in hand-edited copies, mirror parity evidence should
record a SHA-256 of each source and bundle pair.

## 5. Language-Rule Classification (rule references: R1 = directive clause (1); D = epic artifact-class table rows for schema/config/data, test and documentation)

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsSurfaceDelta.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsCompleteGate.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/templates/_docs-quality.yml` | schema/config/data (consumer workflow template) | YAML | D; Q4 (`pwsh` on the runner) |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one row) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsProfileCommands.psm1` (edit: one template row) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | hook | PowerShell | R1 |
| bundle copies of the above under `extensions/drm-copilot/resources/claude-customizations/.claude/` | mirror of helper/lib, hook, data | PowerShell, YAML | R1, D |
| `.claude/settings.json` and bundle copy (edit) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| feature-review agent, converted Codex agent and skill files with bundle copies (edit; section 4.5) | agent, skill | Markdown, TOML wrapper of Markdown | epic class "Skill, agent" (Markdown) |
| `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1`, `DocsCompleteGate.Tests.ps1`, `DocsQualityWorkflowTemplate.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate*.Tests.ps1`; edit of `hook-dependency-failure.Claude.Tests.ps1` | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/**` | documentation | Markdown | D |

No Python or TypeScript file is created or edited. No `.github/workflows/` file of this repository
changes. No artifact needs an exception to the language rule.

## 6. Testing Implications

- Runner and jobs: lib suites under `tests/scripts/claude-lib/docs/` run in
  `poshqc / PowerShell QC shard 1|2|3` (windows-latest, with coverage) and are merged by
  `poshqc / PowerShell QC`; hook suites under `tests/scripts/claude-hooks/` also run in
  `poshqc / PowerShell hook suites (Linux)` (ubuntu-latest, coverage disabled). Coverage figures come
  only from `poshqc / PowerShell QC` (`artifacts/pester/powershell-coverage.xml` locally through
  `Invoke-PoshQCTest`). Pester line coverage >= 85% per new production file; no branch gate.
- No coverage or scan configuration change: `config/poshqc-coverage.json` roots already include
  `.claude/hooks` and `.claude/lib`; `config/poshqc-scan.json` scans `tests/scripts`.
  `quality-tiers.yml` already classifies `.claude/hooks` (T3); `.claude/lib/docs` is added by 1020
  (T3). T3 carries no property-test density obligation; one seeded order-invariance property test for
  `Compare-DocsSurfaceDelta` is still recommended (D1 lesson from 1024).
- `DocsSurfaceDelta.Tests.ps1`: added unledgered `cli-command` reported; same with a head ledger
  entry reports nothing; digest change without ledger change reported; digest change with a changed
  entry or a re-pin reports nothing; `analysis_method`-only change reports nothing; removed element
  not reported; deterministic order under seeded input shuffles (seed printed on failure); command
  tests through an in-memory context: null base revision, base revision mismatch, missing input
  (exit 1), invalid `-Base` and non-relative path (exit 2 with one `DOCS_CLI_ARGUMENTS`), `-Json`
  envelope shape.
- `DocsCompleteGate.Tests.ps1`: integration-target truth table; profile state (disabled, enabled,
  invalid); receipt verdicts for absent, schema-invalid, wrong mode, wrong repository, `fail`, stale
  revision, matching revision; a parity assertion that the hard-coded profile path equals
  `Get-DocsDefaultProfilePath`.
- `DocsQualityWorkflowTemplate.Tests.ps1`: template row present under the 1034 anchor with
  destination `.github/workflows/_docs-quality.yml`; `init` dry run lists it as `create`; text checks
  of section 4.1.
- Hook suites: envelopes built in memory (`@{ session_id; tool_name = 'Bash'; tool_input = @{ command } } | ConvertTo-Json -Compress`,
  as in `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1`); seams mocked by name
  (`Get-DocsCompleteGateFileText`, `Get-DocsCompleteGatePullRequest`, `Invoke-DocsOnlyGhExe`); a
  non-merge command asserts the profile seam is never called; disabled gate allows a merge command;
  each deny reason asserted by code; payload-anomaly rows; the dependency-failure contract via the
  edited `hook-dependency-failure.Claude.Tests.ps1`. No temporary files; committed runtime schemas may
  be read.
- Linux constraints for hook suites: `Join-Path`, forward-slash relative paths, exact file-name
  case, no drive letters; synthetic roots such as `Join-Path '/synthetic-worktrees' 'item-1034'`.
- Isolation: remove `Docs*`, `DiscoveryEncoding` and `HookPayload` modules in `AfterAll`; three
  seeded shuffled file-order runs of the touched suites plus a fresh single-process run over
  `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`.

## 7. Contracts Later Children Must Honor

- `surface-delta`: options `-Base <full revision>`, `-BaseSnapshot`, `-BaseLedger`, `-Profile`;
  result `{base_revision, head_revision, elements[{element_id, kind, path, declaration, change, ledger_changed}]}`;
  finding `DOCS_SURFACE_DELTA_UNLEDGERED`; exit 0 clean, 1 findings. 900009 skills and 900010's
  end-to-end test call it through `Invoke-DocsCommand.ps1`; it is not one of the six 900007 MCP tools.
- Gate: opt-in through `completion_gates.integration_pr_gate.enabled`; receipt read from
  `artifact_paths.validation_receipt` in the working tree; deny prefix `DOCS_COMPLETE_GATE_BLOCKED:`
  and the reason codes of section 4.3; target `main` <- `epic/<slug>-integration`. 900010 onboarding
  documents: run `inventory` and `validate -Mode docs-complete -Revision <head>` with the
  write-receipt switch before the integration merge, keep the receipt path untracked, and that Codex
  sessions are not gated.
- Workflow template: destination `.github/workflows/_docs-quality.yml`, `workflow_call` plus
  `workflow_dispatch`, `pwsh` only; 900010 documents the caller job and the 900010 epic template's
  "docs CI" wave-0 item points at `init -Write`.
- Review check: the `surface-change-without-ledger-change` rule text in the feature-review agent and
  skills; 900009's `docs-coverage-reviewer` may reference it rather than restate it.
- 1023 must persist the receipt so that `revision`, `mode`, `repository`, `validation_result` and
  `id` are present as specified in the 1020 receipt schema.

## 8. Owner Questions (each with a provisional default)

1. **OQ-1 - Base-revision access for `surface-delta`.** The 1020 context has no revision reader.
   Default: caller-materialized base snapshot and ledger (approach A); `-Base` is a full object id.
   Alternative: a 1020 amendment adding a git-backed `ReadRevisionText` context member.
2. **OQ-2 - Revision-pinning model across 1022/1023/1034.** A committed snapshot or receipt can never
   carry the SHA of the commit containing it. Default: snapshot and receipt used for gating are
   produced at validation time for the checked-out head (workflow runs `inventory` at the head
   first); the receipt path is untracked; 1023 defines how the ledger's `snapshot_ref` digest is
   compared when the snapshot is regenerated.
3. **OQ-3 - Codex reach of the gate.** Default: Claude only, no `.codex/hooks/` twin (docs lib is
   Claude-bundle only per Q7/OQ-2 of 1020).
4. **OQ-4 - Profile access in the hook.** 1020 binds profile access to `ConvertFrom-DocsProfileText`,
   which would pull a runtime `Import-Module` into the hook closure (guard S5). Default: the hook and
   `DocsCompleteGate.psm1` validate the profile with `Test-DocsArtifactText` (schema only) and
   hard-code the default profile path, pinned to `Get-DocsDefaultProfilePath` by a test.
   Alternative: a 1020 amendment moving the registry import out of `DocsProfile.psm1`.
5. **OQ-5 - Invalid profile on an in-scope merge.** Default: deny
   (`DOCS_COMPLETE_GATE_PROFILE_INVALID`); an absent profile allows.
6. **OQ-6 - Anchor numbering.** Default: 1034 inserts under the anchor text 1020 commits (currently
   `900008`) and renames nothing; the orchestrator decides whether 1020 commits `1034` instead.
7. **OQ-7 - Gated target.** Default: base exactly `main`, head `^epic/[A-Za-z0-9._-]+-integration$`;
   a configurable base would need a 1020 schema field in `integration_pr_gate`.

## Numeric Derivation Evidence

Claim: the feature-review family comprises 26 files, of which 12 are edited by 1034 (section 4.5).

- Complete Family: every agent, converted-agent, generated-variant and skill file that defines
  feature-review behavior on the Claude, Codex, `.agents` and Copilot surfaces, including all bundle
  copies under `extensions/drm-copilot/resources/`.
- Exhaustive Search Scope: the whole worktree excluding `docs/` (feature folders hold historical
  evidence, not surfaces).
- Inclusion Rules: file name or containing directory begins with `feature-review`, or the file's
  frontmatter/TOML `name` is a feature-review family name; agent, skill and Codex agent files only.
- Exclusion Rules: hooks (`feature-review-coverage-thresholds.ps1`, `validate-feature-review-coverage.ps1`),
  prompts (`.codex/prompts/feature-review-remediate.md` and bundle), tests, `docs/**`, and
  `.github/skills/README.md` plus its bundle copy (index files that only mention the name).
- Primary Search Strategy or Query Expression: Glob `**/feature-review*` (files) and Glob
  `**/feature-review*/**` (skill directories), filtered by the rules above.
- Primary Member Set: `.claude/agents/feature-review.md`; Claude bundle `.claude/agents/feature-review.md`;
  `.codex/agents/feature-review.toml`, `feature-reviewer.toml`, `feature-reviewer-c1.toml`,
  `feature-reviewer-c2.toml`, `feature-reviewer-c3.toml`, `feature-reviewer-c3-elevated.toml`,
  `feature-reviewer-c4.toml` and the same seven under the Codex bundle; `.github/agents/feature-review.agent.md`
  and its `resources/customizations` copy; `.claude/skills/feature-review-workflow/SKILL.md`,
  `.agents/skills/feature-review-workflow/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`,
  `.agents/skills/feature-review/SKILL.md` and their four bundle copies.
- Primary Count: 26 (18 agent files + 8 skill files).
- Cross-check Search Strategy or Query Expression: content Grep
  `^name(:| =) "?feature-review(er)?(-workflow|-c1|-c2|-c3|-c3-elevated|-c4)?"?\s*$` with glob `!docs/**`,
  then the Copilot agent pair located by its frontmatter `name: feature_code_review_agent` (read).
- Cross-check Member Set: the 26 Grep hits minus the two `README.md` index files (24), plus the two
  Copilot agent files whose `name` is `feature_code_review_agent` (2).
- Cross-check Count: 26.
- Member-set Comparison: after normalizing to repository-relative paths, both sets contain the same
  26 paths; no path appears in one set only. The edited subset (12) is the four agent-text files
  (Claude agent pair, converted Codex agent pair) plus the eight skill files; the unedited 14 are the
  Copilot agent pair and the twelve `feature-reviewer*` TOML files.

## Rejected Alternatives (brief)

- Git-backed context member for `surface-delta` (OQ-1 alternative): contract change to 1020 and
  process access in the lib.
- Identifying the integration PR from the epic checkpoint (`epic_merge_pr.pr_number`): consumer
  merges made outside `epic-orchestrate` have no checkpoint; the branch-name rule from `gh pr view`
  works for both.
- Importing `DocsProfile.psm1` in the hook: fails guard S5 (OQ-4).
- Adding `Bash(pwsh *)` to the feature-review agent so it can run `surface-delta`: breaks
  `test_feature_review_agent_grants_mcp_artifact_validator`.
- A Python YAML-parse test for the template: new Python is not permitted; Pester text checks suffice.

## Pre-Mortem

- Review checklists: a reviewer may flag the hook's deviation from the 1020 "Profile access goes
  through `ConvertFrom-DocsProfileText`" decision or the extra edit of `DocsProfileCommands.psm1`
  that the epic's 1034 file list omits. Mitigation: the plan records OQ-4 and the 1020 delivery
  decision as the authority for both, and the artifact classification table lists every edited file.
- Coverage: the hook's process seam and entry tail are hard to cover, and the hook suites run without
  coverage on Linux. Mitigation: pure logic lives in `DocsCompleteGate.psm1` and
  `DocsSurfaceDelta.psm1`; the hook keeps thin seams mocked by name; per-file line coverage >= 85% is
  read from `poshqc / PowerShell QC` (windows-latest) or the local `Invoke-PoshQCTest` report.
- Mirror parity: twelve hand-edited feature-review files, the hook, three lib/template files, two
  settings files and `core.json` must stay identical to their bundle copies; the Copilot skill bundle
  has no byte-parity test (UNVERIFIED). Mitigation: one task per source/bundle pair, a SHA-256
  evidence table for every pair, and runs of the Claude and Codex resource-contract tests,
  `test_push_down_claude_pack_manifest_completeness.py`, the dependency-closure test, and
  `Docs.Manifest.Tests.ps1`. The execution-environment brief states no fact this feature changes, so
  no brief update is required.
- File size: `Invoke-DocsCommand.ps1` and `DocsProfileCommands.psm1` are 1020 files near their
  guidance tier; 1034 adds one line to each. Mitigation: new logic stays in the new modules; the plan
  measures logical lines of every touched file and stays below 500 for new files.
- Test isolation: dot-sourcing the hook and importing `Docs*`, `DiscoveryEncoding` and `HookPayload`
  modules can leak between suites in shard and single-process runs. Mitigation: `AfterAll` removal of
  every imported module, mocks scoped to `BeforeAll`/`It`, no temporary files, three seeded shuffled
  runs and one fresh single-process run over `tests/scripts` recorded as evidence.
- CI-only behavior: the Linux hook job runs the hook suites on a case-sensitive file system with the
  runner's PowerShell and bundled JsonSchema.Net (version UNVERIFIED), and the guard tests S4/S5 see
  the real 1020 import graph only after 1020 merges. Mitigation: Linux-safe paths, assertions on codes
  and pointers rather than `Test-Json` message text, and an early run of
  `hook-dependency-guard-completeness.Tests.ps1` and `hook-dependency-failure.Claude.Tests.ps1` on the
  branch after rebasing onto the integration branch that contains 1020, 1021 and 1023.
- Evidence: the hook and `surface-delta` depend on PowerShell spellings (write-receipt switch,
  `inventory -Revision`, `check` options) that 1021, 1022 and 1023 have not fixed yet (S3-S5), and an
  isolated subagent cannot exercise a branch hook. Mitigation: the plan's first task reads the merged
  1021/1022/1023 contracts and records them under `<FEATURE>/evidence/baseline/`; hook behavior is
  proven by Pester suites, not by a live subagent run; every command artifact carries `Timestamp:`,
  `Command:`, `EXIT_CODE:` and `Output Summary:`.

## Facts for the Orchestrator to Confirm (UNVERIFIED)

- Whether any CI step regenerates `.codex/agents/feature-review.toml` from the codex-native converter.
- Byte parity between `.github/skills/feature-review-workflow/SKILL.md` and its
  `resources/customizations` copy, and between `.github/agents/feature-review.agent.md` and its copy
  (no test found).
- The PowerShell version on `ubuntu-latest` and `windows-latest` runners (>= 7.4 needed by the docs lib).
- `gh pr view` without a selector resolving the current branch's PR inside a hook's working root.
- GitHub `pull_request` checkout defaulting to the merge commit (template uses the explicit head SHA).
