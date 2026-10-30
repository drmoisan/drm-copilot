# docs-enforcement-and-ci — Spec

- **Issue:** #1034
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child `docs-enforcement-and-ci`, wave 2, band C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T23-30
- **Status:** Draft
- **Version:** 0.2 (preparation under the refined implementation-language rule)
- **Work Mode:** full-feature (acceptance criteria sources: this file and `user-story.md`)
- **Depends on:** #1021 (`check` subcommand), #1023 (`validate -Mode docs-complete` and the persisted receipt); transitively #1020
- **Research (primary design source):** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/research/research.2026-10-30T23-01.md`
- **Research (numeric derivation for the feature-review family):** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/research/2026-10-30T23-30-feature-review-family-derivation-research.md`

## Overview

The documentation-estate tooling of epic #1019 can check pages (1021) and emit a `docs-complete`
receipt (1023), but nothing acts on either result. A destination repository can change its
documentable surface, for example by adding a CLI command, without changing its coverage ledger, and
an epic integration branch can merge to `main` without a passing receipt for its head revision. In
one consumer repository, a feature epic changed 138 `src/` files while only 4 of 79 documentation
pages were edited, and the gap was found by hand.

This feature delivers the enforcement half of the correspondence goal:

1. A consumer reusable workflow template `_docs-quality.yml` that runs the docs commands with `pwsh`
   only, delivered by `Invoke-DocsCommand.ps1 -Command init`.
2. A `surface-delta` subcommand (`.claude/lib/docs/DocsSurfaceDelta.psm1`) that reports surface
   elements added or changed since a base revision that have no matching ledger change.
3. An opt-in PreToolUse hook `.claude/hooks/enforce-docs-complete-gate.ps1` that denies the epic
   integration-to-`main` merge unless a passing persisted receipt pins the pull request head.
4. A `surface-change-without-ledger-change` review check in the feature-review agent and skill
   surfaces.

Every pushed-down artifact is PowerShell or data. No Python or TypeScript file is created or edited.
Upstream contracts of 1020, 1021 and 1023 are taken from `docs/features/epics/documentation-estate-tooling/epic.md`
and the 1020 `spec.md` `## Decisions Later Children Must Honor`, not from the 1021 or 1023 folders,
which are being re-prepared concurrently.

## Behavior

- **Workflow template.** `init` lists `.github/workflows/_docs-quality.yml` as a planned write. With
  `-Write` it creates the file from `.claude/lib/docs/templates/_docs-quality.yml`; an existing
  destination is reported as `DOCS_INIT_TARGET_EXISTS` unless `-Force` (1020 OQ-5 provisional
  default). In the consumer repository the reusable workflow checks out the pull request head, runs
  `check`, captures the inventory at the head revision, and runs `validate -Mode docs-complete` for
  that revision. Every step uses `pwsh`; no Python, Node.js or linter setup is required (D4).
- **`surface-delta`.** Given a full base revision and caller-materialized base snapshot and base
  ledger, plus the head snapshot, head ledger and head evidence pins from the profile, the command
  reports each element that is added (identifier absent at base) or changed (element digest differs)
  and has no matching ledger change. It exits 0 when every such element is accounted for and 1
  otherwise. The command reads only through the 1020 command context and starts no process.
- **Gate hook.** For a Bash tool call, the hook allows immediately unless the command is an in-scope
  merge command (the scope predicate of the existing epic merge gate). For an in-scope command it reads
  the consumer profile. When the profile is absent or `completion_gates.integration_pr_gate.enabled`
  is not `true`, it allows. When enabled, it resolves the pull request through one bounded `gh pr view`
  call; when the pull request is an `epic/<slug>-integration` to `main` merge, it allows only when the
  receipt at `artifact_paths.validation_receipt` is schema-valid, has `mode` `docs-complete`,
  belongs to the profile repository, has `validation_result` `pass`, and has `revision` ordinally equal
  to the live head object id. Every deny reason begins `DOCS_COMPLETE_GATE_BLOCKED:` followed by a
  named reason code.
- **Settings registration.** `.claude/settings.json` and its bundle copy register the hook in the
  existing `"matcher": "Bash"` PreToolUse group. Claude Code applies `deny` over `allow` across
  parallel hooks, so the docs gate and `enforce-epic-merge-gate.ps1` each must allow for a merge to
  proceed; the docs gate replaces no epic-gate branch.
- **Review check.** When a docs profile exists at the branch head, the reviewer compares changed
  source files with ledger and pin changes and reports surface changes without ledger changes. A
  repository without a docs profile, including this repository, records the check as not applicable.

## Inputs / Outputs

- Inputs
  - `surface-delta`: `-Base <full revision>`, `-BaseSnapshot <relative path>`, `-BaseLedger <relative
    path>`, optional `-Profile <relative path>` (default `docs/documentation-estate/docs-profile.json`
    through the 1020 profile convention), shared `-Json`, `-Help`, `-RepositoryRoot`. Head artifacts
    come from profile `artifact_paths.inventory_snapshot`, `artifact_paths.coverage_ledger` and
    `artifact_paths.evidence_pins`.
  - Gate hook: the PreToolUse JSON payload on standard input (`tool_name`, `tool_input.command`);
    `docs/documentation-estate/docs-profile.json` in the session working tree; the receipt at the
    profile's `artifact_paths.validation_receipt`; `gh pr view [<n>] --json baseRefName,headRefName,headRefOid`.
  - Workflow template: an optional `profile` string input on `workflow_call` (default
    `docs/documentation-estate/docs-profile.json`).
- Outputs
  - `surface-delta`: findings and a `result` object (see `## API / CLI Surface`); exit code 0/1/2/3;
    the `-Json` envelope `{command, exit_code, findings, ok, result}`.
  - Gate hook: one PreToolUse decision on standard output (`hookSpecificOutput.permissionDecision`
    `allow` or `deny`, with `permissionDecisionReason` on deny).
  - `init`: one additional planned write `{path: ".github/workflows/_docs-quality.yml", action}`.
- Config keys and defaults
  - `completion_gates.integration_pr_gate.enabled` (boolean; `New-DocsStarterProfile` sets `false`).
  - `artifact_paths.validation_receipt` (relative path; read by the hook).
  - `artifact_paths.inventory_snapshot`, `artifact_paths.coverage_ledger`,
    `artifact_paths.evidence_pins` (read by `surface-delta` and by the review check).
  - `surface_selection.source_roots`, `surface_selection.exclusions` (read by the review check).
  - No 1020 schema field is added by 1034.
- Versioning or backward-compatibility constraints
  - The hook is disabled by default, so a destination that adopts the push-down without enabling the
    gate sees no behavior change.
  - The feature-review agent `tools` list is unchanged (pinned by
    `test_feature_review_agent_grants_mcp_artifact_validator`).
  - No dispatch-table anchor or existing row of `Invoke-DocsCommand.ps1`, and no existing
    `Get-DocsInitTemplate` row, is renamed or changed.

## API / CLI Surface

### `surface-delta` command contract

- Invocation:
  `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command surface-delta -Base <40-or-64-hex> -BaseSnapshot <rel> -BaseLedger <rel> [-Profile <rel>] [-Json]`
- Dispatch row (one line, under the 1034 anchor that 1020 commits; currently
  `# --- 900008: surface-delta ---`, see S1 and OQ-6):
  `[pscustomobject]@{ Name = 'surface-delta'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurfaceDelta.psm1'); Function = 'Invoke-DocsSurfaceDeltaCommand'; Option = @{ Base = 'value'; BaseSnapshot = 'value'; BaseLedger = 'value'; Profile = 'value' } }`
- Command function: `Invoke-DocsSurfaceDeltaCommand -Argument <hashtable> -Context <command context>`;
  returns `New-DocsCommandResult`; never prints and never calls `exit`.
- Pure function: `Compare-DocsSurfaceDelta -BaseSnapshot <IDictionary> -HeadSnapshot <IDictionary> -BaseLedger <IDictionary> -HeadLedger <IDictionary> [-HeadPins <IDictionary>]`
  returns records `{element_id, kind, path, declaration, change, ledger_changed}` sorted by
  `element_id` with ordinal comparison.
- Validation rules
  - `-Base` must pass `Test-DocsFullRevision` (full lowercase 40 or 64 hex). Symbolic references
    such as `origin/main` are not accepted (OQ-1).
  - `-BaseSnapshot`, `-BaseLedger` and `-Profile` must pass `Test-DocsRelativePath` before any
    context call.
  - Each input is parsed with `ConvertFrom-DocsJsonText` and validated with `Test-DocsArtifactText`
    (`surface-inventory-snapshot`, `docs-coverage-ledger`, `docs-evidence-pin`).
  - The base snapshot `revision` must be non-null and ordinally equal to `-Base`.
- Comparison rules
  - Elements are indexed by `element_id`. `added`: present in head, absent in base. `changed`:
    present in both with different element digests. The digest is the element digest defined by the
    1020 amendment (declaration lines, D5; currently the field `source_sha256`), compared as an opaque
    string. Removed elements are not reported (ledger completeness belongs to 1023 `validate`).
  - `analysis_method` is ignored, so a change from `scanner` to `native` with equal identifier and
    digest is not a surface change.
  - Ledger change for an element: the head ledger has an entry for the identifier and the base ledger
    has none, or both have an entry and their canonical JSON (`ConvertTo-DocsCanonicalJson`) differs.
  - A `changed` element is also accounted for when a head evidence pin for the identifier records the
    head digest and the base digest differs (re-pin through 1023 `update-ledger -Operation pin`).
- Result shape: `{base_revision, head_revision, elements: [{element_id, kind, path, declaration, change, ledger_changed}]}`.
  `head_revision` is the head snapshot `revision` value as read (it may be `null`).
- Finding codes (built with `New-DocsFinding`)

| Code | Severity | Exit | Condition |
|---|---|---|---|
| `DOCS_SURFACE_DELTA_UNLEDGERED` | error | 1 | One per added or changed element with no ledger change; `RelatedId` is the element id; `ArtifactPath` is the head ledger path. |
| `DOCS_SURFACE_DELTA_BASE_UNPINNED` | error | 1 | Base snapshot `revision` is `null`. |
| `DOCS_SURFACE_DELTA_BASE_MISMATCH` | error | 1 | Base snapshot `revision` differs from `-Base`. |
| `DOCS_SURFACE_DELTA_INPUT_MISSING` | error | 1 | A base or head input file does not exist; the message names the relative path. |
| schema findings from `Test-DocsArtifactText` | error | 1 | An input is not schema-valid. |
| `DOCS_CLI_ARGUMENTS` | error | 2 | Invalid `-Base`, non-relative path, missing required option, unknown option (exactly one finding, `result` `null`). |
| `DOCS_RUNTIME_UNSUPPORTED` or `DOCS_CLI_RUNTIME` | error | 3 | PowerShell below 7.4, or an internal or I/O error (exactly one finding). |

- Exit codes: 0 no finding; 1 one or more `error` findings from comparison or input validation; 2
  usage error; 3 runtime error.
- `-Json`: exactly one canonical JSON document `{command, exit_code, findings, ok, result}` with
  `command` `surface-delta`, `ok` true exactly when `exit_code` is 0, findings in the fixed 1020
  order. The document validates against `schemas/docs/v1/docs-command-envelope.schema.json`, which
  the 1020 amendment required by D5 delivers (S2).
- Example: an added `cli-command` with no head ledger entry yields one `DOCS_SURFACE_DELTA_UNLEDGERED`
  and exit 1; the same input with a head ledger entry for that identifier yields no finding and exit 0.

### Gate hook contract (`.claude/hooks/enforce-docs-complete-gate.ps1`)

- Structure mirrors `enforce-epic-merge-gate.ps1`: the `hook-dependency-guard.ps1` bootstrap; guarded
  single-statement edges to `../lib/hook-payload/HookPayload.psm1`, `hook-command-scanner.ps1`,
  `hook-command-invocation.ps1`, `enforce-epic-merge-gate-command.ps1`, `hook-docs-only-diff.ps1` and
  `../lib/docs/DocsCompleteGate.psm1`; decision function `Invoke-DocsCompleteGateDecision -ToolInputRaw`;
  entry `Invoke-DocsCompleteGateEntryPoint -ReadPayload`; dot-source guard
  `if ($MyInvocation.InvocationName -eq '.') { return }`; tail
  `Get-HookDependencyFailureDecision -HookEvent PreToolUse -ReasonPrefix 'DOCS_COMPLETE_GATE_BLOCKED:'`.
- Named seams that tests mock: `Get-DocsCompleteGateRepositoryRoot`,
  `Get-DocsCompleteGateFileText -RepositoryRoot -RelativePath` (returns `$null` when absent),
  `Get-DocsCompleteGatePullRequest -Selector -RepositoryRoot` (one
  `gh pr view [<n>] --json baseRefName,headRefName,headRefOid` through `Invoke-DocsOnlyGhExe`,
  bounded by `Invoke-DocsOnlyBoundedNative`).
- Pure logic in `.claude/lib/docs/DocsCompleteGate.psm1` (imports `DocsJson.psm1`,
  `DocsFinding.psm1` and `DocsSchema.psm1` only): `Test-DocsCompleteGateIntegrationTarget
  -BaseRefName -HeadRefName`; `Get-DocsCompleteGateProfileState -ProfileText -ComposedSchemaSet`
  (returns `Enabled`, `ReceiptPath`, `RepositoryId`, `Findings`);
  `Get-DocsCompleteGateReceiptVerdict -ReceiptText -ReceiptPath -HeadSha -RepositoryId
  -ComposedSchemaSet` (returns `Allowed`, `Code`, `Message`).
- Profile path: `docs/documentation-estate/docs-profile.json`, hard-coded and pinned to
  `Get-DocsDefaultProfilePath` by a test (OQ-4). The profile is validated with
  `Test-DocsArtifactText -ArtifactKind docs-profile`, not `ConvertFrom-DocsProfileText` (OQ-4).
- Decision order (first matching row wins; no file or process access before step 3 completes):

| Step | Condition | Decision | Reason code (after `DOCS_COMPLETE_GATE_BLOCKED:`) |
|---|---|---|---|
| 1 | A guarded dependency failed to load | deny | dependency-guard text naming the edge |
| 2 | Payload not valid (`Resolve-ClaudeHookToolInput`) | allow when the gate is absent or disabled; deny when enabled | `DOCS_COMPLETE_GATE_PAYLOAD_INVALID` |
| 3 | No `command`, or `Test-EpicMergeGateCommandInScope` is false | allow | none |
| 4a | Profile absent | allow | none |
| 4b | Profile present and not schema-valid | deny (OQ-5) | `DOCS_COMPLETE_GATE_PROFILE_INVALID` |
| 4c | `completion_gates.integration_pr_gate.enabled` is not `true` | allow | none |
| 5 | `Get-DocsRuntimeVersionError` returns non-null | deny | `DOCS_COMPLETE_GATE_RUNTIME_UNSUPPORTED` |
| 6 | No resolvable pull request for a `gh api` mutation; lookup failure, timeout, unparseable output, or `headRefOid` not matching `^[0-9a-f]{40}([0-9a-f]{24})?$` | deny | `DOCS_COMPLETE_GATE_PR_UNRESOLVED` |
| 7 | `baseRefName` is not exactly `main`, or `headRefName` does not match `^epic/[A-Za-z0-9._-]+-integration$` (ordinal) | allow (OQ-7) | none |
| 8a | Receipt file absent | deny | `DOCS_COMPLETE_GATE_RECEIPT_MISSING` (names the path) |
| 8b | Receipt not schema-valid (`docs-validation-receipt`) | deny | `DOCS_COMPLETE_GATE_RECEIPT_INVALID` |
| 8c | `mode` is not `docs-complete` | deny | `DOCS_COMPLETE_GATE_RECEIPT_MODE` |
| 8d | `repository` differs from profile `repository.id` | deny | `DOCS_COMPLETE_GATE_RECEIPT_REPOSITORY` |
| 8e | `validation_result` is not `pass` | deny | `DOCS_COMPLETE_GATE_RECEIPT_FAILED` (names the receipt `id`) |
| 8f | `revision` is not ordinally equal to `headRefOid` | deny | `DOCS_COMPLETE_GATE_RECEIPT_STALE` (names both values) |
| 8g | A `--match-head-commit` value differs from `headRefOid` | deny | `DOCS_COMPLETE_GATE_HEAD_MISMATCH` |
| 9 | Otherwise | allow | none |

- "Pins the head revision" means ordinal string equality between the receipt `revision` and the live
  `headRefOid`; both are lowercase hex by schema pattern, so no case folding is applied.
- Disabled behavior: when the profile is absent or the gate is not enabled, every call is allowed,
  including malformed payloads, and `Get-DocsCompleteGatePullRequest` is never invoked.
- Documented residual limits (hook help text): the profile and receipt are read from the session
  working tree, not from the pull request head commit; an ambient `GH_REPO` or `GH_HOST` is not
  visible; a push after the lookup can change the head unless `--match-head-commit` is passed; the
  control is policy-level, not cryptographic; the receipt must be an untracked file (OQ-2); Codex
  sessions are not gated (OQ-3).

### Workflow template contract

- Data file: `.claude/lib/docs/templates/_docs-quality.yml` (byte-identical bundle copy; listed in
  `core.json`).
- `Get-DocsInitTemplate` row in `DocsProfileCommands.psm1`, one line under the 1034 anchor that 1020
  commits (currently `# --- 900008: docs workflow ---`, see S1 and OQ-6):
  `[pscustomobject]@{ Source = (Join-Path -Path $PSScriptRoot -ChildPath 'templates/_docs-quality.yml'); Destination = '.github/workflows/_docs-quality.yml' }`.
  This edit is required by the 1020 delivery decision although the epic's 1034 "Files (edit)" list
  omits it.
- Destination in the consumer repository: `.github/workflows/_docs-quality.yml`.
- Shape: `on:` with `workflow_call` (optional `profile` string input) and `workflow_dispatch`;
  `permissions: contents: read`; one job on `ubuntu-latest`; `actions/checkout@v7` with
  `ref: ${{ github.event.pull_request.head.sha || github.sha }}` and `fetch-depth: 0`; every `run:`
  step declares `shell: pwsh` and invokes
  `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name> ...` for, in order,
  `check`, `inventory` at the head revision (1022 option names, S5), and `validate -Mode docs-complete`
  with the head revision and the write-receipt switch (1023 spelling, S3); an optional
  `actions/upload-artifact` step for the receipt.
- Forbidden content: any of the tokens `setup-python`, `setup-node`, `python`, `pip`, `poetry`,
  `node`, `npm`, `npx`; any linter step (D4); any consumer identifier (1020 neutrality test).
- This repository's own workflows are not changed; the template is data until `init` writes it in a
  consumer repository.

### Settings registration

- Add `{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1" }`
  to the `"matcher": "Bash"` group of `hooks.PreToolUse` in `.claude/settings.json`, after the
  `enforce-epic-merge-gate.ps1` entry, and make the identical edit in
  `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (the two files stay
  byte-identical).
- Add `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/lib/docs/DocsSurfaceDelta.psm1`,
  `.claude/lib/docs/DocsCompleteGate.psm1` and `.claude/lib/docs/templates/_docs-quality.yml` to
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths`, each
  with a byte-identical bundle copy.
- No `.codex/config.toml` or `.codex/hooks/` change (OQ-3).

### Feature-review `surface-change-without-ledger-change` check

- Placement
  - `.claude/agents/feature-review.md`: a new self-contained section (the agent preloads only
    `policy-compliance-order` and `acceptance-criteria-tracking`).
  - The three `feature-review-workflow` skills: a new rule `### surface-change-without-ledger-change`
    under `## Policy Rules`, alongside `### modified-workflow-needs-green-run`.
  - `.agents/skills/feature-review/SKILL.md`: the same rule.
  - `.codex/agents/feature-review.toml` (converted Codex agent): the same section as the Claude agent,
    added by hand.
- Semantics (tools limited to the existing `Read`, `Grep`, `Glob`, `Bash(git diff *)`,
  `Bash(git log *)`, `Write(/docs/features/active/**)`, `mcp__drm-copilot__validate_orchestration_artifacts`;
  no tool is added)
  - Applicability: `docs/documentation-estate/docs-profile.json` exists at the branch head; otherwise
    the reviewer records "not applicable: no docs profile".
  - The reviewer reads `surface_selection.source_roots`, `surface_selection.exclusions`,
    `artifact_paths.coverage_ledger` and `artifact_paths.evidence_pins` from the profile and lists
    changed files with `git diff --name-only <merge-base>...HEAD`.
  - When a `surface-delta` result for the branch exists in the feature evidence (for example
    `<FEATURE>/evidence/other/surface-delta.<timestamp>.md` containing its `-Json` output), each
    reported element is a Blocking finding (`Remediability: autonomous`) naming the element id.
  - Without such a result, changed files under a source root with no change to the ledger or pin file
    produce one non-blocking `Warning` row that recommends running `surface-delta`.
  - Findings are reported as Findings Table rows and, when blocking, in the remediation inputs; the
    `docs/features/templates/policy_audit/` templates are not changed.
- Edited file set: 12 of the 26 feature-review family files (numeric derivation in
  `research/2026-10-30T23-30-feature-review-family-derivation-research.md`):

| File | Edited | Parity guard |
|---|---|---|
| `.claude/agents/feature-review.md` | yes | `test_push_down_claude_resource_contracts.py`; `MIRROR_PAIRS` in `test_completion_gate_documentation_contracts.py` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` | yes | same |
| `.codex/agents/feature-review.toml` | yes | `test_push_down_codex_and_agents_resource_contracts.py` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | yes | same |
| `.claude/skills/feature-review-workflow/SKILL.md` | yes | Claude resource contracts; `test_push_down_issue_824_follow_ups.py` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` | yes | same |
| `.agents/skills/feature-review-workflow/SKILL.md` | yes | Codex resource contracts |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md` | yes | same |
| `.github/skills/feature-review-workflow/SKILL.md` | yes | `test_push_down_issue_824_follow_ups.py` fragments; SHA-256 evidence (no byte-parity test found) |
| `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md` | yes | same |
| `.agents/skills/feature-review/SKILL.md` | yes | Codex resource contracts; `test_codex_handoff_contract_parity.py` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md` | yes | same |
| `.github/agents/feature-review.agent.md` and its `resources/customizations` copy | no | delegates to the skill |
| `.codex/agents/feature-reviewer.toml` and its bundle copy | no | `test_codex_agent_wrapper_contracts.py` |
| `.codex/agents/feature-reviewer-{c1,c2,c3,c3-elevated,c4}.toml` and their bundle copies | no | `generate_codex_agent_variants.py --check` |

## Data & State

- Data transformations and invariants
  - `surface-delta` is read-only: it writes no file and starts no process. Output order is
    deterministic (ordinal by `element_id`) and independent of input element order.
  - The gate hook is read-only: it writes no file and changes no checkpoint. It does not read
    `artifacts/orchestration/epic-orchestrator-state.json`.
  - `init` gains one planned write; its dry-run and `-Write`/`-Force` semantics are unchanged.
- Caching or persistence details: none. The receipt is persisted by 1023, not by 1034; the hook only
  reads it.
- Migration or backfill requirements: none. The gate is disabled in every existing and starter
  profile.

## Constraints & Risks

- Language rule (owner directive 2026-10-30, refined): pushed-down skills, skill helpers, hooks and
  libs are PowerShell or bash; TypeScript only for MCP and extension commands; no new Python. Linting
  stays optional (D4). No new third-party PowerShell module (A8).
- Pure functions take strings and hashtables; file, clock and process access happens only in the
  command context (`surface-delta`) or in the hook's named seams.
- Tests create no temporary files: no `New-TemporaryFile`, `TestDrive`, `GetTempPath`,
  `GetTempFileName` or `$env:TEMP`; hook payloads and command contexts are built in memory; committed
  runtime schemas may be read.
- Coverage: Pester line coverage >= 85% for each new PowerShell production file, read from
  `poshqc / PowerShell QC` (merged result of the `poshqc / PowerShell QC shard 1|2|3` jobs on
  `windows-latest`) or the local `Invoke-PoshQCTest` report. No branch-coverage gate applies to
  Pester. No production file is excluded from measurement; `config/poshqc-coverage.json` already
  includes `.claude/hooks` and `.claude/lib`.
- Hook suites under `tests/scripts/claude-hooks/` also run in `poshqc / PowerShell hook suites (Linux)`
  on `ubuntu-latest` without coverage; they use `Join-Path`, forward-slash relative paths, exact
  file-name case and no drive letters.
- Mirror parity, pack-manifest completeness and dependency-closure contract tests must pass.
- Tier: `.claude/hooks` is T3 and `.claude/lib/docs` is T3 (added by 1020); no property-test density
  obligation applies, but one seeded order-invariance property test for `Compare-DocsSurfaceDelta` is
  required by this specification.
- File size: every new production file stays below 500 logical lines; `Invoke-DocsCommand.ps1` and
  `DocsProfileCommands.psm1` each gain one line.
- Risks
  - The hook's profile handling deviates from the 1020 decision "Profile access goes through
    `ConvertFrom-DocsProfileText`" (OQ-4); the guard test S5 is inferred, not yet observed, to reject
    the alternative.
  - Upstream PowerShell spellings (write-receipt switch, `inventory -Revision`) are not fixed yet
    (S3, S5); the workflow template depends on them.
  - `hook-dependency-guard-completeness.Tests.ps1` and `hook-dependency-failure.Claude.Tests.ps1` see
    the real 1020 import graph only after 1020 merges into the integration branch.
  - Twelve hand-edited feature-review files must stay identical to their copies; the Copilot skill
    bundle has no byte-parity test (UNVERIFIED in research).

## Artifact Classification

Rule references: R1 = language rule clause (1) (pushed-down skills, skill helpers, hooks and libs are
PowerShell or bash); R2 = clause (2) (TypeScript only for MCP and extension commands; not used here);
D = epic `### Artifact classes for this epic` rows for schema/config/data, test and documentation;
S = epic class row "Skill, agent" (Markdown). "Avoid new Python" applies to every row.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsSurfaceDelta.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsCompleteGate.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/templates/_docs-quality.yml` | schema/config/data (consumer workflow template) | YAML | D; epic Q4 (`pwsh` on the runner) |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one dispatch row) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsProfileCommands.psm1` (edit: one `Get-DocsInitTemplate` row) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | hook | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/{DocsSurfaceDelta.psm1, DocsCompleteGate.psm1, templates/_docs-quality.yml, Invoke-DocsCommand.ps1, DocsProfileCommands.psm1}` (create or edit, byte-identical copies) | pushed-down helper/lib and data (mirror) | PowerShell, YAML | R1, D |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1` | hook (mirror) | PowerShell | R1 |
| `.claude/settings.json` (edit) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` (edit) | schema/config/data (mirror) | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `.claude/agents/feature-review.md` and its Claude bundle copy (edit) | agent | Markdown | S |
| `.codex/agents/feature-review.toml` and its Codex bundle copy (edit) | agent | TOML wrapper of Markdown | S |
| `.claude/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review-workflow/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review/SKILL.md` and their four bundle copies (edit) | skill | Markdown | S |
| `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsCompleteGate.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/DocsQualityWorkflowTemplate.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` (split into `enforce-docs-complete-gate.<Area>.Tests.ps1` files if the size guidance requires) | test | PowerShell (Pester) | D |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (edit: one `$script:ReasonPrefix` row) | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/**` (spec, user story, research, plan, evidence) | documentation | Markdown | D |

No Python, TypeScript or JavaScript file is created or edited. No `.github/workflows/` file of this
repository changes. No `.codex/config.toml` or `.codex/hooks/` file changes. Every artifact follows
the language rule; no artifact needs an exception, so no language owner question is raised.

## Implementation Strategy

- Implementation scope: two new PowerShell modules, one hook, one YAML template, two one-line rows in
  1020-owned files under 1034 anchors, settings and manifest registration, feature-review text in
  twelve files, and Pester suites.
- New functions: `Compare-DocsSurfaceDelta`, `Invoke-DocsSurfaceDeltaCommand`
  (`DocsSurfaceDelta.psm1`); `Test-DocsCompleteGateIntegrationTarget`,
  `Get-DocsCompleteGateProfileState`, `Get-DocsCompleteGateReceiptVerdict` (`DocsCompleteGate.psm1`);
  `Invoke-DocsCompleteGateDecision`, `Invoke-DocsCompleteGateEntryPoint`,
  `Get-DocsCompleteGateRepositoryRoot`, `Get-DocsCompleteGateFileText`,
  `Get-DocsCompleteGatePullRequest` (hook).
- Reused functions: `Test-EpicMergeGateCommandInScope`, `Get-EpicMergeGateSelectorPrNumber`
  (`enforce-epic-merge-gate-command.ps1`); `Invoke-DocsOnlyGhExe` (`hook-docs-only-diff.ps1`);
  `Test-CommandLineFlag`, `Get-CommandLineFlagValue`; `Resolve-ClaudeHookToolInput`
  (`HookPayload.psm1`); the 1020 helpers `ConvertFrom-DocsJsonText`, `Test-DocsArtifactText`,
  `Get-DocsComposedSchemaSet`, `ConvertTo-DocsCanonicalJson`, `Test-DocsFullRevision`,
  `Test-DocsRelativePath`, `Get-DocsRuntimeVersionError`, `New-DocsFinding`, `New-DocsCommandResult`.
- Dependency changes: none. PowerShell 7.4 built-ins only (A8).
- Logging: none beyond the hook decision text and command findings.
- Rollout: the gate is opt-in and disabled by default; consumers enable it by setting
  `completion_gates.integration_pr_gate.enabled` to `true` after running `inventory` and
  `validate -Mode docs-complete` with the write-receipt switch for the head (900010 documents this).
- First plan task: read the merged 1020, 1021, 1022 and 1023 contracts on the integration branch
  (anchor text, envelope schema, write-receipt switch, `inventory` options, element digest field) and
  record them under `<FEATURE>/evidence/baseline/`.

## Source Disagreements

| # | Disagreement | Where | Resolution in this spec |
|---|---|---|---|
| S1 | The 1020 spec uses first-preparation placeholder numbers for later anchors (`# --- 900008: surface-delta ---`, `# --- 900008: docs workflow ---`, and the profile note "900008 reads `completion_gates.integration_pr_gate.enabled`"); the epic now names this child 1034. | 1020 `#### Dispatch table`, `### DocsProfileCommands.psm1`, `### Artifact schema: docs-profile` | 1034 inserts under whatever anchor text 1020 commits and renames none, because the 1020 acceptance criterion pins anchor order. OQ-6. |
| S2 | Epic `### PowerShell contracts from the re-preparation of 1020` and the 1020 spec state "the envelope has no schema file"; D5 and `### Amendment of 1020 required by D3 and D5` add `schemas/docs/v1/docs-command-envelope.schema.json`. | epic; 1020 `#### Exit codes and the -Json envelope` | D5 is later and governs: `surface-delta -Json` validates against the envelope schema. |
| S3 | The 1023 folder still specifies the withdrawn Python design (`dev.docs.validate --mode --revision --write-receipt`). | 1023 `spec.md` | Receipt contract taken from the epic `### Command contract decisions from the first preparation of 1023`; the gating fields agree in both sources. The PowerShell write-receipt switch spelling (planned `-WriteReceipt`) is confirmed against the re-prepared 1023 at execution start. |
| S4 | The 1021 folder places base configuration under `extensions/drm-copilot/resources/templates/docs-quality/`. | 1021 `spec.md` | The epic and 1020 govern: template data under `.claude/lib/docs/templates/`. The workflow uses only `-Command check` plus the shared `-Json` and `-Profile` conventions. |
| S5 | The 1022 folder (Python design) defines `--revision` and `--output` for `inventory`; the epic fixes only the subcommand name. | 1022 `spec.md` | The template needs `inventory` at the head revision; the PowerShell option names (planned `-Revision`, `-Output`) are confirmed against the re-prepared 1022 at execution start. |
| S6 | D5 defines the element digest over the declaration's lines; the 1020 snapshot element carries `source_sha256`, which the amendment may rename or redefine. | epic amendment; 1020 `### Artifact schema: surface-inventory-snapshot` | `surface-delta` compares the amended element digest field as an opaque value. |

## Owner Questions

None of these is decided beyond its provisional default. An owner answer that differs changes the
affected criteria through a specification revision.

1. **OQ-1 - Base-revision access for `surface-delta`.** The 1020 command context has no git, process
   or revision-read member. Provisional default: caller-materialized base snapshot and base ledger
   (`-BaseSnapshot`, `-BaseLedger`); `-Base` is a full object id, which narrows the issue wording
   `surface-delta -Base <ref>`. Alternative: a 1020 amendment adding a git-backed `ReadRevisionText`
   context member.
2. **OQ-2 - Revision-pinning model across 1022, 1023 and 1034.** A committed snapshot or receipt cannot
   carry the SHA of the commit that contains it. Provisional default: the snapshot and receipt used
   for gating are produced at validation time for the checked-out head (the workflow runs `inventory`
   at the head first); the receipt path is untracked; 1023 defines how the ledger's `snapshot_ref`
   digest is compared when the snapshot is regenerated.
3. **OQ-3 - Codex reach of the gate.** Provisional default: Claude only; no `.codex/hooks/` twin,
   because the docs lib ships in the Claude bundle only (epic Q7, 1020 OQ-2). Codex sessions are not
   gated.
4. **OQ-4 - Profile access in the hook.** 1020 binds profile access to `ConvertFrom-DocsProfileText`,
   which would bring a runtime `Import-Module` (through `DocsAnalyzerRegistry.psm1`) into the hook
   closure and fail guard check S5. Provisional default: the hook and `DocsCompleteGate.psm1` validate
   the profile with `Test-DocsArtifactText` (schema only) and hard-code the default profile path,
   pinned to `Get-DocsDefaultProfilePath` by a test. Alternative: a 1020 amendment that moves the
   registry import out of `DocsProfile.psm1`.
5. **OQ-5 - Invalid profile on an in-scope merge.** Provisional default: deny with
   `DOCS_COMPLETE_GATE_PROFILE_INVALID`; an absent profile allows.
6. **OQ-6 - Anchor numbering.** Provisional default: 1034 inserts under the anchor text 1020 commits
   (currently `900008`) and renames nothing; the orchestrator decides whether 1020 commits `1034`
   instead.
7. **OQ-7 - Gated target.** Provisional default: base exactly `main` and head matching
   `^epic/[A-Za-z0-9._-]+-integration$`; a configurable base would need a new field in the 1020
   `integration_pr_gate` schema.

## Contracts Later Children Must Honor

- `surface-delta` (900009 skills, 900010 end-to-end test): options `-Base <full revision>`,
  `-BaseSnapshot`, `-BaseLedger`, `-Profile`; result
  `{base_revision, head_revision, elements[{element_id, kind, path, declaration, change, ledger_changed}]}`;
  finding codes `DOCS_SURFACE_DELTA_UNLEDGERED`, `DOCS_SURFACE_DELTA_BASE_UNPINNED`,
  `DOCS_SURFACE_DELTA_BASE_MISMATCH`, `DOCS_SURFACE_DELTA_INPUT_MISSING`; exit 0 clean, 1 findings, 2
  usage, 3 runtime. Callers invoke it through `Invoke-DocsCommand.ps1`; it is not one of the six 900007
  MCP tools.
- Gate: opt-in through `completion_gates.integration_pr_gate.enabled`; receipt read from
  `artifact_paths.validation_receipt` in the working tree; deny prefix `DOCS_COMPLETE_GATE_BLOCKED:`
  and the reason codes of the decision table; target `main` <- `epic/<slug>-integration`. 900010
  onboarding documents: run `inventory` and `validate -Mode docs-complete` for the head with the
  write-receipt switch before the integration merge, keep the receipt path untracked, and state that
  Codex sessions are not gated.
- Workflow template: destination `.github/workflows/_docs-quality.yml`, `workflow_call` plus
  `workflow_dispatch`, `pwsh` only; 900010 documents the consumer caller job, and the 900010 epic
  template's docs-CI wave-0 item points at `init -Write`.
- Review check: the `surface-change-without-ledger-change` rule text in the feature-review agent and
  skills is the single statement of the check; 900009's `docs-coverage-reviewer` references it rather
  than restating it.
- 1023 persists the receipt so that `revision`, `mode`, `repository`, `validation_result` and `id` are
  present as specified by the 1020 `docs-validation-receipt` schema.
- 1020 keeps `completion_gates.integration_pr_gate` as `{enabled: boolean}` and
  `artifact_paths.validation_receipt`; a rename or removal is an epic-level change that requires a
  1034 revision.

## Acceptance Criteria

- [ ] With the gate disabled, the hook allows every call: for a profile whose `completion_gates.integration_pr_gate.enabled` is `false`, for an absent profile, and for a malformed payload, an in-scope `gh pr merge` of an `epic/<slug>-integration` to `main` pull request, a `gh api` `pulls/<n>/merge` call and a non-merge command each receive `permissionDecision` `allow`, and `Get-DocsCompleteGatePullRequest` is never invoked (`tests/scripts/claude-hooks/enforce-docs-complete-gate*.Tests.ps1`).
- [ ] For a command outside `Test-EpicMergeGateCommandInScope`, the hook allows without invoking `Get-DocsCompleteGateFileText` or `Get-DocsCompleteGatePullRequest` (asserted with `Should -Invoke -Times 0`).
- [ ] With the gate enabled and an in-scope integration-to-`main` merge, the hook denies with a `permissionDecisionReason` that begins `DOCS_COMPLETE_GATE_BLOCKED:` and contains `DOCS_COMPLETE_GATE_RECEIPT_MISSING` and the receipt path when the receipt is absent, `DOCS_COMPLETE_GATE_RECEIPT_FAILED` and the receipt `id` when `validation_result` is `fail`, and `DOCS_COMPLETE_GATE_RECEIPT_STALE` and both revision values when the receipt `revision` differs from `headRefOid`.
- [ ] With the gate enabled, the hook denies with the named reason code for each remaining deny row of the decision table: `DOCS_COMPLETE_GATE_PAYLOAD_INVALID`, `DOCS_COMPLETE_GATE_PROFILE_INVALID`, `DOCS_COMPLETE_GATE_RUNTIME_UNSUPPORTED`, `DOCS_COMPLETE_GATE_PR_UNRESOLVED` (lookup failure, timeout exit 124, unparseable output, invalid `headRefOid`, unresolvable `gh api` selector), `DOCS_COMPLETE_GATE_RECEIPT_INVALID`, `DOCS_COMPLETE_GATE_RECEIPT_MODE`, `DOCS_COMPLETE_GATE_RECEIPT_REPOSITORY` and `DOCS_COMPLETE_GATE_HEAD_MISMATCH`.
- [ ] With the gate enabled, the hook allows a merge whose receipt is schema-valid with `mode` `docs-complete`, the profile repository, `validation_result` `pass` and `revision` ordinally equal to `headRefOid`; and it allows a merge whose base is not exactly `main` or whose head does not match `^epic/[A-Za-z0-9._-]+-integration$`, without reading the receipt.
- [ ] `tests/scripts/claude-lib/docs/DocsCompleteGate.Tests.ps1` covers the `Test-DocsCompleteGateIntegrationTarget` truth table (including case-variant and near-miss branch names), `Get-DocsCompleteGateProfileState` for disabled, enabled and invalid profiles, `Get-DocsCompleteGateReceiptVerdict` for every receipt row of the decision table, and asserts that the hook's hard-coded profile path equals `Get-DocsDefaultProfilePath`.
- [ ] `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` contains the row `'.claude/hooks/enforce-docs-complete-gate.ps1' = 'DOCS_COMPLETE_GATE_BLOCKED:'` and passes, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` passes with the new hook discovered from both settings files.
- [ ] `.claude/settings.json` and `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` are byte-identical and each registers `pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1` exactly once, in the `"matcher": "Bash"` PreToolUse group; `tests/scripts/claude-runtime/claude-settings.Tests.ps1` passes.
- [ ] `surface-delta` reports an added CLI command with no ledger change and reports nothing when the ledger records it: for an in-memory base and head snapshot where the head adds one `cli-command` element, a head ledger without an entry for it yields exactly one `DOCS_SURFACE_DELTA_UNLEDGERED` finding whose `RelatedId` is that element id and exit code 1, and a head ledger with an entry for it yields no finding and exit code 0 (`tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1`).
- [ ] `Compare-DocsSurfaceDelta` reports a digest change without a ledger change; reports nothing for a digest change with a changed ledger entry or with a head evidence pin that records the head digest; reports nothing for a change of `analysis_method` alone; and does not report a removed element (`DocsSurfaceDelta.Tests.ps1`).
- [ ] `surface-delta` exits 1 with `DOCS_SURFACE_DELTA_BASE_UNPINNED` for a base snapshot whose `revision` is `null`, with `DOCS_SURFACE_DELTA_BASE_MISMATCH` when the base snapshot `revision` differs from `-Base`, and with `DOCS_SURFACE_DELTA_INPUT_MISSING` naming the path for an absent input; it exits 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and `result` `null` for a `-Base` that fails `Test-DocsFullRevision` (including a symbolic ref such as `origin/main`) and for a non-relative `-BaseSnapshot` (in-memory command context).
- [ ] `surface-delta -Json` prints exactly one canonical JSON document with keys `command`, `exit_code`, `findings`, `ok` and `result`, `command` equal to `surface-delta`, and validates against `schemas/docs/v1/docs-command-envelope.schema.json`; if that schema is absent from the integration branch when execution begins, the executor records a blocker for the 1020 amendment instead of omitting this check.
- [ ] `Compare-DocsSurfaceDelta` output is sorted by `element_id` with ordinal comparison and is identical across at least three seeded shuffles of the input element order, with the seed printed on failure; two `surface-delta -Json` runs over identical inputs produce identical bytes.
- [ ] The committed dispatch table contains exactly one `surface-delta` row under the 1034 anchor that 1020 committed, `Test-DocsCommandTable` returns no finding, and `git diff` of `.claude/lib/docs/Invoke-DocsCommand.ps1` against the merge base shows one added line and no removed or changed line.
- [ ] `Get-DocsInitTemplate` returns a row with `Destination` `.github/workflows/_docs-quality.yml` whose `Source` is `templates/_docs-quality.yml` under the 1034 anchor; `init` without `-Write` lists that path with action `create` and writes nothing; `init -Write` with an existing destination exits 1 with `DOCS_INIT_TARGET_EXISTS` for that path (`tests/scripts/claude-lib/docs/DocsQualityWorkflowTemplate.Tests.ps1`, in-memory context).
- [ ] The workflow template requires `pwsh` only: `DocsQualityWorkflowTemplate.Tests.ps1` reads the committed template text and asserts that `on:` contains `workflow_call:` and `workflow_dispatch:`, that every `run:` step is paired with `shell: pwsh`, that the text invokes `Invoke-DocsCommand.ps1` with `-Command check`, `-Command inventory` and `-Command validate` with `-Mode docs-complete`, and that none of the tokens `setup-python`, `setup-node`, `python`, `pip`, `poetry`, `node`, `npm` or `npx` appears.
- [ ] `git diff --name-only <merge-base>..HEAD` lists no path under `.github/workflows/`, `.codex/hooks/` or `.codex/config.toml`.
- [ ] Each of the twelve edited feature-review files (`.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, `.claude/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review-workflow/SKILL.md`, `.github/skills/feature-review-workflow/SKILL.md`, `.agents/skills/feature-review/SKILL.md` and the bundle copy of each under `extensions/drm-copilot/resources/`) contains the `surface-change-without-ledger-change` check, and each source file is SHA-256 identical to its bundle copy, recorded in a hash table under `<FEATURE>/evidence/qa-gates/`.
- [ ] Mirror parity checks pass for the edited `feature-review` surfaces: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_completion_gate_documentation_contracts.py` (including `test_feature_review_agent_grants_mcp_artifact_validator`), `test_push_down_issue_824_follow_ups.py`, `test_orchestrator_state_remediation_docs.py`, `test_ci_gate_epic_child_contracts.py`, `test_push_down_tier_rule_adoption_gate.py` and `test_codex_handoff_contract_parity.py` pass without modification.
- [ ] The fourteen unedited feature-review family files (`.github/agents/feature-review.agent.md`, `.codex/agents/feature-reviewer.toml`, `.codex/agents/feature-reviewer-{c1,c2,c3,c3-elevated,c4}.toml` and the bundle copy of each) are absent from `git diff --name-only <merge-base>..HEAD`.
- [ ] The rule text in each edited feature-review file states the three outcomes: "not applicable: no docs profile" when `docs/documentation-estate/docs-profile.json` is absent; a Blocking finding naming the element id for each element of a recorded `surface-delta` result; and a non-blocking `Warning` recommending `surface-delta` when source-root files changed without a ledger or pin change and no result is recorded.
- [ ] Every new `.claude/lib/docs/` file (`DocsSurfaceDelta.psm1`, `DocsCompleteGate.psm1`, `templates/_docs-quality.yml`) and `.claude/hooks/enforce-docs-complete-gate.ps1` is listed exactly once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and is SHA-256 identical to its bundle copy; `Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1`, `ClaudeLibModuleConvention.Tests.ps1`, `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` (including `test_every_psscriptroot_occurrence_is_recognized` and `test_claude_command_text_closure`) pass.
- [ ] `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with the new hook and modules present.
- [ ] No Python, TypeScript or JavaScript file is added or modified: `git diff --name-only <merge-base>..HEAD` lists no path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`; and the plan's artifact classification table lists every created or edited file with its class, language and permitting rule, matching `## Artifact Classification`.
- [ ] No test creates a temporary file: no new or edited test file contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`; command tests use in-memory command contexts and hook tests use in-memory payloads and mocked seams.
- [ ] Pester line coverage is at least 85% for each of `.claude/lib/docs/DocsSurfaceDelta.psm1`, `.claude/lib/docs/DocsCompleteGate.psm1` and `.claude/hooks/enforce-docs-complete-gate.ps1`, read from the PoshQC coverage report of `Invoke-PoshQCTest`, with no production file excluded from measurement; figures recorded under `<FEATURE>/evidence/coverage/`.
- [ ] The touched suites pass in three seeded shuffled file-order runs in one process (seed and order recorded) and in one fresh single-process run over `tests/scripts`, with evidence under `<FEATURE>/evidence/regression-testing/`.
- [ ] No new production file exceeds 500 logical lines.
- [ ] (CI-dependent) On the pull request head, `poshqc / PowerShell QC` (merged result of the `windows-latest` shards, with coverage) and `poshqc / PowerShell hook suites (Linux)` (`ubuntu-latest`, Pester, no coverage) pass, and the `quality-checks7 / Code Quality & Tests` jobs (which run the Python contract tests under `tests/scripts/dev_tools/`) pass.

## Definition of Done

- [ ] Acceptance criteria mapped to Pester suites, existing contract tests or commands in the plan
- [ ] Behavior verified on PowerShell 7.4 or later on `windows-latest` and, for hook suites, on `ubuntu-latest`
- [ ] Edge cases covered: malformed payload, empty command, `gh` timeout, 64-hex object ids, null head snapshot revision, empty element sets
- [ ] Toolchain pass completed in a single clean pass (format, PSScriptAnalyzer lint, architecture and contract tests, Pester)
- [ ] Mirror-pair SHA-256 table and upstream-contract baseline recorded as evidence
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Pester unit suites for `DocsSurfaceDelta.psm1` and the hook (hook suite under `tests/scripts/claude-hooks/`)
- [ ] Template-row test for the `init` workflow template
- [ ] Mirror parity tests for `feature-review` surfaces
