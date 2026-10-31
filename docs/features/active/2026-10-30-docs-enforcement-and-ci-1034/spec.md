# docs-enforcement-and-ci — Spec

- **Issue:** #1034
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child `docs-enforcement-and-ci`, manifest placeholder and anchor label `900008`, wave 2, band C3)
- **Depends on:** #1021 (`check` subcommand), #1023 (`validate -Mode docs-complete` and the persisted receipt); transitively #1020
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2
- **Research:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/research/research.2026-10-30.md`
- **Binding requirement sources:** `docs/features/epics/documentation-estate-tooling/epic.md` (owner directive, artifact classes, owner decisions, amendment of 1020, PowerShell contracts of 1020, command contracts of 1023, naming contract, `### 900008 - docs-enforcement-and-ci`) and `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` `## Decisions Later Children Must Honor`. Contracts of 1021 and 1023 are taken from `epic.md`, because both children are being re-prepared concurrently.

## Owner Decisions and Directives (propagated verbatim)

Owner decisions (2026-10-30, verbatim): "(1) A1 to A8 are CONFIRMED as written (separate Python/config and TypeScript/.NET analyzer features with 900004 later; no docs-site build; epic separate from issue #5; integration branch from origin/main; pushed-down logic is PowerShell under .claude/lib/docs/ behind Invoke-DocsCommand.ps1; TypeScript MCP wrappers call it; reuse discovery schemas and existing PowerShell discovery libs and do not call the Python discovery runtime; no new third-party PowerShell modules). (2) D1: the PowerShell rewrite counts as a NEW planning cycle for 1022 and 1024 (and for every superseded child); each gets a fresh allowance of one planner revision and the single-pass preflight; 1024's halted preflight must be addressed in the new plan (property tests for the six pure functions). (3) D3, language exception approved by the owner: a language-native analyzer is allowed when it analyzes that same language and is pushed down only with that language's pack (python pack for Python). The PowerShell text scanner stays the always-available baseline and keeps its documented precision limit, recorded as deferred-with-owner in the coverage ledger. The Python-native analyzer (Python ast, written in Python, shipped in the python pack manifest, tested under the Python gates) is IN THE FIRST RELEASE: keep 1022 as the PowerShell baseline scanner for Python/config surfaces and add a new child for the Python-native analyzer depending on 1022, in the earliest wave its dependencies allow; the planner decides the exact split and records it. C# and TypeScript native analyzers are LATER, optional children (900004 stays the baseline TypeScript/.NET scanner). The ledger must record the analysis method (native or scanner) per finding. (4) D4: linting stays optional by default (config only, no required Node or Python linter). (5) D5: docs-complete fails closed when the inventory snapshot has no revision; an element digest covers the declaration's lines, not the whole file; the JSON output envelope gets its own schema; test PowerShell Test-Json cross-file $ref first and use self-contained schemas as the fallback. Language rule otherwise unchanged: pushed-down skills, hooks and libs are PowerShell or bash; TypeScript only for MCP and extension commands."

Owner pacing directive (verbatim): "the quota pacing limits I gave you earlier are LIFTED. Ignore the cap of 3 concurrent preparation children, the cap of 8 agents in your subtree, and the 5-minute stagger. Launch every preparation child whose dependencies are satisfied at once, and run as parallel as the epic's dependency waves allow. Three accounts are available and the coordinator switches accounts when one nears its limit, so a rate-limit or account-switch error is never a failure signal: commit your working documents, wait and retry, and continue. Keep committing working documents regularly. All other rules are unchanged (language rule and the language-native analyzer exception, no forbidden tokens in any file, planning only, stop at preflight clearance)."

## Overview

### Problem

The documentation-estate tooling of epic #1019 can check pages (1021) and emit a `docs-complete`
receipt (1023), but nothing enforces either result. A destination repository can change its
documentable surface (for example, add a CLI command) without changing its coverage ledger, and an
epic integration branch can merge to `main` without a passing receipt for its head revision. In one
consumer repository, a feature epic changed 138 `src/` files while only 4 of 79 documentation pages
were edited, and the gap was found by hand. The correspondence half of the epic needs a CI surface,
a merge gate, and a review check that act on the tooling's results.

### Solution summary

This child delivers four enforcement surfaces, all pushed down as PowerShell or data:

1. A consumer reusable workflow template `_docs-quality.yml`, shipped as data under
   `.claude/lib/docs/templates/` and written into a destination by `Invoke-DocsCommand.ps1 -Command init`
   through one `Get-DocsInitTemplate` row. It requires `pwsh` only.
2. A `surface-delta -Base <ref>` subcommand (pure module `DocsSurfaceDelta.psm1` plus command module
   `DocsSurfaceDeltaCommands.psm1`, one dispatch row) that reports surface elements added or changed
   since a base revision that have no matching ledger change.
3. An opt-in PreToolUse hook `.claude/hooks/enforce-docs-complete-gate.ps1` (with pure predicates in
   `DocsCompleteGate.psm1`) that, when the consumer profile enables it, denies the epic
   integration-to-`main` merge unless a passing persisted receipt pins the pull request head revision.
4. A `## Documentation Surface Check` in the procedure-bearing `feature-review` surfaces that turns a
   surface change without a ledger change into a Blocking review finding.

## Scope

In scope:

- `DocsSurfaceDelta.psm1`, `DocsSurfaceDeltaCommands.psm1` and the `surface-delta` dispatch row under
  the `# --- 900008: surface-delta ---` anchor.
- An additive extension of the 1020 command context with read-only revision members, subject to
  owner question OQ-1.
- The workflow template `.claude/lib/docs/templates/_docs-quality.yml` and its `Get-DocsInitTemplate`
  row under the `# --- 900008: docs workflow ---` anchor.
- `DocsCompleteGate.psm1` and the hook `enforce-docs-complete-gate.ps1`, registered in
  `.claude/settings.json` and its push-down copy, listed in the Claude `core.json` pack manifest.
- The `feature-review` surface-change-without-ledger-change check in the mirror set identified by
  research (see `### feature-review check and mirror set`).
- Pester suites for every new PowerShell file, and the edits needed for existing registered-hook
  enumeration tests (one `$script:ReasonPrefix` row).

## Non-Goals

- No required linter. Linting stays optional by default (D4); the workflow template runs no Markdown
  or prose linter and installs no Node or Python runtime.
- No Codex twin of the hook and no `.codex/config.toml` change (OQ-4 provisional default).
- No new MCP tool for `surface-delta` (OQ-7 provisional default; 900007 owns MCP tools).
- No change to the `check` (1021), `inventory` (1022) or `validate` (1023) subcommands, their modules,
  or their dispatch rows.
- No edit of another child's anchor or row in `Invoke-DocsCommand.ps1`, `DocsProfileCommands.psm1` or
  `DocsAnalyzerRegistry.psm1`.
- No gate on a direct `git push` to `main`; the hook gates `gh` merge and enqueue commands only, as the
  existing epic merge gate does.
- No protected-authority-store enforcement for documentation artifacts (epic non-goal).
- No new Python, no TypeScript, no new third-party PowerShell module.
- No change to `.github/workflows/` of this repository; the template is consumer data.

## Behavior

- With no consumer profile, or a profile whose `completion_gates.integration_pr_gate.enabled` is
  `false` (the starter value written by `init`), the hook allows every Bash call and performs no `gh`
  call.
- With the gate enabled, the hook allows every Bash call that is not a `gh` merge or enqueue command,
  and every merge whose pull request is not the epic integration-to-`main` merge. For the
  integration-to-`main` merge it allows only when the persisted receipt at
  `artifact_paths.validation_receipt` has `mode` `docs-complete`, `validation_result` `pass`, and
  `revision` equal (ordinal) to the pull request `headRefOid`; otherwise it denies with
  `DOCS_COMPLETE_GATE_BLOCKED: <REASON_CODE> ...` naming the reason.
- `surface-delta -Base <ref>` compares the head inventory snapshot, ledger and evidence pins in the
  working tree with the same artifacts at the base revision and reports each added or changed element
  that has no ledger change; it exits 0 with no `error` finding when every added or changed element has
  a ledger change.
- `init` (dry run) plans `.github/workflows/_docs-quality.yml`; `init -Write` writes the template bytes
  create-only; `-Force` overwrites (1020 semantics).
- `feature-review` raises Blocking finding `surface-change-without-ledger-change` when a docs profile
  exists on the branch head, a changed path lies under a profile `surface_selection.source_roots` entry,
  and the newest `docs-surface-delta` QA-gate evidence artifact is absent or records `EXIT_CODE: 1`.

## Design

### `DocsSurfaceDelta.psm1` (pure)

All functions take strings and ordinal hashtables produced by `ConvertFrom-DocsJsonText`; none reads a
file, the clock, or a process.

- `Compare-DocsSurfaceSnapshot -BaseSnapshot <IDictionary|null> -HeadSnapshot <IDictionary>` returns
  `{added, changed, removed}` (each an ordinally sorted array of `element_id`).
  - Element identity is `element_id` (`<kind>-<sha256>` over kind, path, declaration; 1020).
  - Added: identifier in the head snapshot only. Removed: identifier in the base snapshot only.
    Changed: identifier in both with a different `source_sha256` (the declaration-lines digest under
    D5). Differences in `line_range` or `analysis_method` alone are not changes, so a scanner/native
    switch or a line shift reports nothing.
  - A base snapshot that is `$null` (absent at the base revision) means the estate was adopted on this
    branch: the base is empty and every head element is added.
- `Get-DocsLedgerChange -BaseLedger -HeadLedger -BasePins -HeadPins -ElementId` returns whether the
  element's ledger entry differs between base and head (canonical JSON from
  `ConvertTo-DocsCanonicalJson`, including absent to present) and, for a changed element, whether any
  evidence pin with that `element_id` differs.
- `Get-DocsSurfaceDeltaFinding` builds findings with `New-DocsFinding`, ordered by
  `Get-DocsOrderedFinding`:

| Code | Severity | Condition |
|---|---|---|
| `DOCS_SURFACE_UNLEDGERED_ADDITION` | error | Added element with no ledger change |
| `DOCS_SURFACE_UNLEDGERED_CHANGE` | error | Changed element with no ledger change and no pin change |
| `DOCS_SURFACE_REMOVED_ENTRY_RETAINED` | warning | Removed element whose head ledger still holds an unchanged entry |
| `DOCS_SURFACE_SNAPSHOT_MISSING` | error | No head snapshot at `artifact_paths.inventory_snapshot` |
| `DOCS_SURFACE_SNAPSHOT_STALE` | error | A head snapshot `inputs[]` digest differs from the working-tree bytes (`Get-DocsBytesSha256Hex` over `Context.ReadBytes`) |
| `DOCS_SURFACE_BASE_UNRESOLVED` | error | The base ref does not resolve to a commit |

Each finding names the `element_id`, its `kind` and `path` where an element is involved. The planner may
rename codes before planning completes; once planned, the codes are a contract (see
`## Decisions Later Children Must Honor`).

### `DocsSurfaceDeltaCommands.psm1` and the dispatch row

- `Invoke-DocsSurfaceDeltaCommand -Argument <IDictionary> -Context <object>` returns
  `New-DocsCommandResult`; it never prints and never calls `exit` (1020 rule).
- Options: `Base` (`value`, required) and `Profile` (`value`, optional; default
  `Get-DocsDefaultProfilePath`, `docs/documentation-estate/docs-profile.json`).
- `-Base` grammar is checked before any read: a full revision (`Test-DocsFullRevision`) or a ref
  matching `^[A-Za-z0-9][A-Za-z0-9._/-]*$` that contains no `..`. A violation exits 2 with
  `DOCS_CLI_ARGUMENTS` (prevents option injection into the revision call).
- Reads: profile through `ConvertFrom-DocsProfileText`; head snapshot, ledger and pins through
  `Context.ReadText`; base artifacts through `Context.ReadRevisionText` after
  `Context.ResolveRevision` (OQ-1).
- Exit codes: 0 when no `error` finding; 1 when any `error` finding (including
  `DOCS_SURFACE_BASE_UNRESOLVED`); 2 usage error; 3 runtime error (`DOCS_CLI_RUNTIME`).
- `-Json` `result`: `{base_revision, added, changed, removed}`, each array sorted ordinally. The
  envelope is `{command, exit_code, findings, ok, result}` and validates against
  `schemas/docs/v1/docs-command-envelope.schema.json` once 1020's D5 amendment lands (see
  `## Upstream Contract Notes`).
- Dispatch row, inserted directly under the `# --- 900008: surface-delta ---` anchor and nowhere else:

```powershell
[pscustomobject]@{ Name = 'surface-delta'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurfaceDeltaCommands.psm1'); Function = 'Invoke-DocsSurfaceDeltaCommand'; Option = @{ Base = 'value'; Profile = 'value' } }
```

- Freshness boundary: the stale check covers changed inputs only; a new source file not yet in the
  snapshot is not detected by `surface-delta`. The workflow template regenerates the snapshot with
  `inventory` before the delta (OQ-5 provisional default).

### Command-context extension for base-revision reads (provisional, OQ-1)

The 1020 command context exposes working-tree reads only, and 1020 binds "No filesystem, clock or
process access outside the command context". Under the OQ-1 provisional default, the context gains two
read-only members, built only by `New-DocsCommandContext`:

- `ResolveRevision` (`param($Ref)`): runs `git -C <root> rev-parse --verify --end-of-options <ref>^{commit}`
  with a bounded wait, and returns the full revision string, or `$null` when the ref does not resolve.
- `ReadRevisionText` (`param($Revision, $RelativePath)`): checks the path with
  `Test-DocsRelativePath`, runs `git -C <root> show <revision>:<relative path>` with a bounded wait, and
  returns the text (leading BOM stripped), or `$null` when the path is absent at that revision.

The change is additive: two new members only; no existing member, anchor or row changes. The process
call goes through a `[scriptblock]`-typed parameter declared in the same file, so
`enforcement-hooks-no-python-invocation.Tests.ps1` stays green. Tests extend the in-memory context in
`tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` with in-memory implementations of both members.
This is a cross-child contract change to 1020's entry script; the owner must confirm it, and the owner
or the epic decides whether 1020's amendment cycle or this child performs the edit.

### Workflow template `_docs-quality.yml`

- File: `.claude/lib/docs/templates/_docs-quality.yml` (data; listed in `core.json`; byte-mirrored).
- Delivery: one row, inserted directly under the `# --- 900008: docs workflow ---` anchor in
  `Get-DocsInitTemplate` (`DocsProfileCommands.psm1`):

```powershell
[pscustomobject]@{ Source = (Join-Path -Path $PSScriptRoot -ChildPath 'templates/_docs-quality.yml'); Destination = '.github/workflows/_docs-quality.yml' }
```

- Content (data only; `pwsh` is the only runtime):
  - `on: workflow_call` with optional input `base-ref`, plus `workflow_dispatch`.
  - One job with a `name:`, `runs-on: ubuntu-latest`, `permissions: contents: read`.
  - `actions/checkout@v7` with `ref: ${{ github.event.pull_request.head.sha || github.sha }}` and
    `fetch-depth: 0` (the pull request default checkout is the merge commit, and `surface-delta` needs
    base history).
  - The revision reaches steps through `env:` (for example `DOCS_REVISION`), never through inline
    `${{ }}` inside `run:`.
  - Steps, each with `shell: pwsh`, invoking `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1`:
    `-Command inventory` (OQ-5 provisional default), `-Command check -Json`,
    `-Command validate -Mode docs-complete` with the revision option and the write-receipt switch named by
    1023's committed row, and `-Command surface-delta -Base <base-ref>` only when `base-ref` is supplied.
  - Optional receipt upload with `actions/upload-artifact@v7`.
  - No `setup-python`, `setup-node`, `python`, `npm` or `node` token; no linter step (D4).
- The option spellings for `check` and `validate` are copied from the dispatch rows that 1021 and 1023
  commit; the executor re-reads those rows before writing the template (see
  `## Upstream Contract Notes`).

### `DocsCompleteGate.psm1` (pure gate predicates)

Imports only `DocsJson.psm1` and `DocsSurface.psm1` (closure per 1020: `DocsFinding.psm1` and
`../discovery-validation/DiscoveryEncoding.psm1`). It must not import `DocsProfile.psm1`,
`DocsAnalyzerRegistry.psm1` or `Invoke-DocsCommand.ps1`, because their closures contain runtime imports
that fail rule S5 of `hook-dependency-guard-completeness.Tests.ps1`. It writes nothing to the success or
warning stream at module scope.

- `Get-DocsCompleteGateEnabled -ProfileText <string|null>`: `$null` text returns disabled; parsed
  `completion_gates.integration_pr_gate.enabled` equal to `$true` returns enabled; absent or `false`
  returns disabled; unparseable text or a duplicate key returns `PROFILE_UNREADABLE`.
- `Get-DocsCompleteGateReceiptPath -ProfileText`: reads `artifact_paths.validation_receipt`, checked
  with `Test-DocsRelativePath`; a missing or invalid path returns `RECEIPT_PATH_INVALID`.
- `Test-DocsCompleteGateIntegrationTarget -BaseRefName -HeadRefName`: true when `BaseRefName` is `main`
  and `HeadRefName` matches `^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$` (OQ-3 provisional default).
- `Test-DocsCompleteGateReceipt -ReceiptText <string|null> -HeadRevision <string>` returns the first
  failing reason in this order, or allow:

| Reason code | Condition |
|---|---|
| `RECEIPT_ABSENT` | No file at the receipt path |
| `RECEIPT_UNREADABLE` | Text does not parse, or `artifact_kind` is not the receipt kind |
| `RECEIPT_MODE` | `mode` is not `docs-complete` |
| `RECEIPT_FAILING` | `validation_result` is not `pass` |
| `RECEIPT_REVISION_MISMATCH` | `revision` is not ordinally equal to the head revision; deny text names both revisions |

### Hook `enforce-docs-complete-gate.ps1`

- Skeleton follows the sibling hooks and the rules enforced by
  `hook-dependency-guard-completeness.Tests.ps1` (S1 to S6): the dependency-guard bootstrap line, one
  guarded single-statement import per edge (including `DocsCompleteGate.psm1` and `HookPayload.psm1`),
  `Get-HookDependencyFailureDecision` first in the decision function, the dot-source early return, then
  the tail. Literal `Join-Path -Path $PSScriptRoot -ChildPath '<literal>'` only.
- Reuse: `Test-EpicMergeGateCommandInScope` and `Get-EpicMergeGateSelectorPrNumber`
  (`enforce-epic-merge-gate-command.ps1`), `Invoke-DocsOnlyGhExe` (`hook-docs-only-diff.ps1`, bounded,
  never throws, `[scriptblock]` invoker seam), payload readers from `HookPayload.psm1`, and the
  allow/deny decision JSON shape of the epic merge gate.
- Decision order, in `Invoke-DocsCompleteGateDecision -ToolInputRaw`:
  1. Dependency-failure decision; then envelope anomaly denies (sibling convention).
  2. No `command`, or `Test-EpicMergeGateCommandInScope` false: allow. No I/O.
  3. Read the profile through the file seam `Get-DocsCompleteGateFileText` at
     `docs/documentation-estate/docs-profile.json` under the root returned by the root seam. Absent
     profile or gate disabled: allow, with no `gh` call. `PROFILE_UNREADABLE`: deny.
  4. One bounded `gh pr view [<N>] --json baseRefName,headRefName,headRefOid` through
     `Invoke-DocsOnlyGhExe`. Unresolved: deny `PR_UNRESOLVED`. A `--match-head-commit` value that
     differs from `headRefOid`: deny `MATCH_HEAD_MISMATCH`.
  5. Not the integration target: allow.
  6. Receipt path check, read through the file seam, and `Test-DocsCompleteGateReceipt` against
     `headRefOid`. Deny with the reason code, or allow.
- Deny text form: `DOCS_COMPLETE_GATE_BLOCKED: <REASON_CODE>: <one-sentence reason and remediation>`.
  The prefix is added to `$script:ReasonPrefix` in `hook-dependency-failure.Claude.Tests.ps1`.
- Head revision: the pull request `headRefOid`, never local `git rev-parse HEAD`, because the session
  worktree may hold a different commit than the pull request head.
- Residual limits, recorded in the hook header: the profile and receipt are read from the local working
  tree; ambient `GH_REPO` selects the repository; a push after the lookup is not observed; a GraphQL
  mutation supplied from a file is not visible; a direct `git push` to `main` is outside `gh` scope.
- Dependency failure: if a guarded import fails, the hook returns the standard dependency-failure deny
  decision required of every registered Claude hook. This applies to a broken installation, not to the
  disabled-gate default, because the hook and its library ship together in the core pack.

### Registration and push-down

- `.claude/settings.json` and `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`:
  one entry `{"type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1"}`
  in the existing `hooks.PreToolUse` group with `"matcher": "Bash"`, placed after
  `enforce-epic-merge-gate.ps1`. Both copies stay byte-identical.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: the hook and every
  new `.claude/lib/docs/` file (PowerShell and data) are listed exactly once; each has a byte-identical
  bundle copy.
- The destination receives `.claude/settings.json` as a plain overwrite (no merge), so the registration
  arrives with the core pack. Receipt ignoring in the destination `.gitignore` is an onboarding item for
  900010.

### feature-review check and mirror set

A new section `## Documentation Surface Check` is added to the procedure-bearing copies identified by
the research mirror map (the same set that carries the `## File Size Advisory` precedent; see the
research `## Numeric Derivation Evidence` record):

- `.claude/agents/feature-review.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`
- `.codex/agents/feature-review.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`
- `.agents/skills/feature-review/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md`
- `.github/skills/feature-review-workflow/SKILL.md` and `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`

Unchanged, because they delegate to the skills that carry the procedure: the Codex
`feature-reviewer*.toml` variant family and `.github/agents/feature-review.agent.md`. The Codex variant
generator check is therefore unaffected.

Check semantics (evidence model: inspect pre-existing artifacts, do not rerun):

- Not applicable, and no finding, when `docs/documentation-estate/docs-profile.json` is absent on the
  branch head.
- The reviewer lists changed paths with `git diff --name-only <merge-base>..HEAD` (already permitted).
  When any changed path lies under a profile `surface_selection.source_roots` entry, the reviewer
  requires the newest `<FEATURE>/evidence/qa-gates/docs-surface-delta.<timestamp>.md` (fields
  `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`).
- Absent artifact, or `EXIT_CODE: 1`: Blocking finding `surface-change-without-ledger-change` with
  `Remediability: autonomous`.
- No tool is added to any agent frontmatter (OQ-6 provisional default).

## Inputs / Outputs

- Inputs: consumer profile `docs/documentation-estate/docs-profile.json`; artifacts at
  `artifact_paths.{inventory_snapshot, coverage_ledger, evidence_pins, validation_receipt}`; the
  `-Base` ref; the hook PreToolUse payload `{session_id, tool_name, tool_input: {command}}`; live pull
  request data from `gh pr view`.
- Outputs: `surface-delta` findings and `-Json` envelope; hook decision JSON
  `{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision, permissionDecisionReason}}`
  with exit 0; `init` planned or written `.github/workflows/_docs-quality.yml`; review findings.
- Config keys and defaults: `completion_gates.integration_pr_gate.enabled` (starter value `false`);
  `surface_selection.source_roots` (used by the review check).
- Compatibility: additive only. No existing subcommand, option, finding code, context member or hook
  behavior changes.

## API / CLI Surface

- `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command surface-delta -Base origin/main -Json`
  exits 1 and lists `DOCS_SURFACE_UNLEDGERED_ADDITION` for an added `cli-command` element with no ledger
  change; exits 0 with `result.added` containing that element when the head ledger records it.
- `... -Command surface-delta -Base '--upload-pack=x'` exits 2 with one `DOCS_CLI_ARGUMENTS` finding and
  `result` `null`.
- `... -Command init` lists `.github/workflows/_docs-quality.yml` in `result.planned_writes` with action
  `create` (or `exists`); `-Write` writes it.
- Hook deny example: `DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_REVISION_MISMATCH: receipt revision <a> does not equal pull request head <b>; run validate -Mode docs-complete with the write-receipt switch at the head revision`.

## Data & State

- No new schema or artifact kind. `surface-delta` reads the snapshot, ledger and pins; it writes
  nothing. The hook reads the profile and receipt; it writes nothing.
- Receipt state: under the OQ-2 provisional default, the receipt is an uncommitted working-tree artifact
  produced at the pull request head immediately before the merge, because a receipt committed inside the
  head commit cannot record that commit's own identifier.
- No migration or backfill.

## Constraints & Risks

- Language rule (owner directive 2026-10-30, refined): pushed-down helpers, hooks and libs are
  PowerShell or bash; TypeScript only for MCP and extension commands; no new Python.
- Pure functions take strings and hashtables; tests create no temporary files and use in-memory
  contexts and mocked seams.
- 1020, 1021 and 1023 code is not present on this branch; every upstream item is a contract. Execution
  starts only after those children merge into `epic/documentation-estate-tooling-integration`.
- Batch budget: four production PowerShell files are created and two edited, each with a bundle copy;
  execution runs in the item worktree under an exempt-route checkpoint.
- Test isolation: dot-sourcing the hook imports modules into the session; suites remove imported
  modules in `AfterAll`, and the touched suites run in three seeded shuffled file orders.
- CI-only behavior: the Linux hook job is case-sensitive; tests use forward-slash relative paths and
  exact file-name case, and no test reads gitignored state or diffs against `origin/main`.
- File size: each new production file stays under the 500-line guidance; the hook keeps payload, scope
  and seams only, and pure logic lives in `DocsCompleteGate.psm1`.

## Implementation Strategy

- Create `DocsSurfaceDelta.psm1`, `DocsSurfaceDeltaCommands.psm1`, `DocsCompleteGate.psm1`,
  `templates/_docs-quality.yml` and the hook; insert one row under each 900008 anchor; add the context
  members if OQ-1 assigns them to this child.
- Edit both settings copies, `core.json`, the procedure-bearing `feature-review` copies and their bundle
  copies, and `hook-dependency-failure.Claude.Tests.ps1`.
- No dependency changes. No new logging beyond findings and decision reasons.
- Rollout: the gate is disabled by default; a consumer enables it through the profile (900010 template).

## Artifact Classification

Rule references: R1 = language rule clause (1) (pushed-down skills, helpers, hooks and libs are
PowerShell or bash); D = epic `### Artifact classes for this epic` (hook, skill/agent,
schema/config/data, test rows). No row is TypeScript or Python.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsSurfaceDelta.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsCompleteGate.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/templates/_docs-quality.yml` | schema/config/data (consumer workflow template) | YAML | D |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one dispatch row; two context members if OQ-1 assigns them here) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsProfileCommands.psm1` (edit: one `Get-DocsInitTemplate` row) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | hook | PowerShell | R1, D |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/**` and `.../.claude/hooks/enforce-docs-complete-gate.ps1` (byte copies of the rows above) | pushed-down helper/lib, hook, data (mirror) | PowerShell, YAML | R1, D |
| `.claude/settings.json` and its bundle copy (edit) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `.claude/agents/feature-review.md` and bundle copy (edit) | agent | Markdown | D |
| `.codex/agents/feature-review.toml` and bundle copy (edit) | agent (Codex mirror) | TOML wrapper with Markdown body | D |
| `.agents/skills/feature-review/SKILL.md` and bundle copy (edit) | skill | Markdown | D |
| `.github/skills/feature-review-workflow/SKILL.md` and bundle copy (edit) | skill (Copilot) | Markdown | D |
| `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1`, `DocsSurfaceDeltaCommands.Tests.ps1`, `DocsCompleteGate.Tests.ps1`, `DocsInitTemplate.DocsWorkflow.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` (edit: in-memory revision members, if OQ-1 is adopted) | test | PowerShell (Pester) | D |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (edit: one `$script:ReasonPrefix` row) | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/**` | documentation | Markdown | D |

Every artifact follows the language rule; no language owner question arises.

## Upstream Contract Notes

These conflicts and gaps were found in the upstream documents. None is resolved by this child; each is
re-checked against committed code before execution.

- **Envelope schema versus D5.** The epic section `### PowerShell contracts from the re-preparation of
  1020` and the 1020 spec state that the `-Json` envelope has no schema file. D5 and
  `### Amendment of 1020 required by D3 and D5` add `schemas/docs/v1/docs-command-envelope.schema.json`.
  D5 is the later owner decision; `surface-delta -Json` output must validate against the envelope
  schema once 1020's amendment lands. If the amendment has not landed when this child executes, the
  envelope-schema criterion is reported as blocked on 1020, not waived.
- **Anchor labels.** The 1020 spec uses the labels `900003` (inventory, now 1022) and `900006`
  (generate-reference, now 1024), while the epic uses 1022 and 1024. Labels are literal comment text
  fixed by 1020's code. This child inserts only under the literal `900008` anchors that 1020 commits
  (`# --- 900008: surface-delta ---` and `# --- 900008: docs workflow ---` in the current spec); the
  executor re-reads the committed anchors, because 1020's re-plan may relabel them.
- **1021 spec still describes the withdrawn design.** `docs/features/active/2026-10-30-docs-page-quality-checker-1021/spec.md`
  still describes the withdrawn Python package and its options. The PowerShell option names of `check`
  are unspecified until 1021's re-preparation; the template copies them from 1021's committed row.
- **1023 spec still describes the withdrawn design.** `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/spec.md`
  still describes the withdrawn Python command. Its downstream constraint (the hook allows the gated
  merge only when `mode` is `docs-complete`, `validation_result` is `pass` and `revision` equals the head
  revision; the receipt is written exclusive-create when absent and digest-checked replace when present)
  is adopted here. The PowerShell names of the mode, revision and write-receipt options are unspecified
  until 1023's re-preparation.
- **Receipt persistence.** The location is specified (`artifact_paths.validation_receipt`); whether the
  persisted receipt is committed is not (OQ-2).
- **1020 import graph.** That `DocsJson.psm1`, `DocsFinding.psm1` and `DocsSurface.psm1` contain no
  runtime import and write nothing at module scope is a contract to verify after 1020 merges; the hook
  design depends on it.
- **Base-revision access.** The 1020 command context has no revision members (OQ-1).
- **Implicit 1022 reference.** The workflow template runs `inventory` (1022) although the epic manifest
  lists only 1021 and 1023 as dependencies; 1022 is in wave 1, so it is present before this wave-2 child
  executes (OQ-5).

## Decisions Later Children Must Honor

- **900007 (docs-mcp-tools):** `surface-delta` is a subcommand with the standard exit codes and `-Json`
  envelope and `result` `{base_revision, added, changed, removed}`. It is not among the six named MCP
  tools; wrapping it requires an epic naming-contract update (OQ-7). `validate_docs_artifacts` must not
  persist receipts, because the hook trusts only persisted receipts produced by the write-receipt switch.
- **900009 (docs-authoring-workflow):** the `docs-coverage-reviewer` role and the `docs-review-coverage`
  skill call `surface-delta` through `Invoke-DocsCommand.ps1`. The finding codes in
  `### DocsSurfaceDelta.psm1 (pure)`, the evidence artifact name
  `<FEATURE>/evidence/qa-gates/docs-surface-delta.<timestamp>.md` and its fields (`Timestamp`,
  `Command`, `EXIT_CODE`, `Output Summary`), and the review finding `surface-change-without-ledger-change`
  are fixed by this child. Any agent mirror 900009 generates for `feature-review` keeps the
  `## Documentation Surface Check` section.
- **900010 (documentation-estate-template-and-onboarding):** the epic template's final gate sets
  `completion_gates.integration_pr_gate.enabled` to `true`. Onboarding documents (a) running
  `validate -Mode docs-complete` with the write-receipt switch at the integration branch head before
  merging; (b) not committing the receipt path (or the OQ-2 alternative if the owner chooses it);
  (c) adding a caller job for `_docs-quality.yml` written by `init`; (d) committing the pushed-down
  `.claude/lib/docs/` tree so the workflow can find `Invoke-DocsCommand.ps1`; (e) the deny prefix
  `DOCS_COMPLETE_GATE_BLOCKED:` and its reason codes; (f) that the gate is Claude-only (OQ-4); and
  (g) PowerShell 7.4 as the destination prerequisite (inherited from 1020).
- **Hook contract (all children):** profile at `docs/documentation-estate/docs-profile.json`; the
  integration merge is base `main` and head `epic/<slug>-integration`; receipt equality is ordinal on
  the full revision.

## Owner Questions

None of these is decided beyond its provisional default. The design and criteria below follow the
provisional defaults so that planning can proceed; an owner answer may change the affected criteria
through a specification revision.

1. **OQ-1 - Base-revision read access for `surface-delta` (cross-child contract change to 1020's entry
   script).** Provisional default: add exactly two read-only members, `ResolveRevision` and
   `ReadRevisionText`, to the command context built only by `New-DocsCommandContext` in
   `Invoke-DocsCommand.ps1`, with the semantics in `### Command-context extension for base-revision reads
   (provisional, OQ-1)`. The change is additive (new members only; no edit to another child's anchor or
   row, and no change to an existing member). Ownership default: 1020's amendment cycle performs it; if
   1020 has already cleared, an epic update authorizes this child to make the additive edit. The owner
   must confirm the contract change. Rejected alternatives: a git I/O module outside the context
   (violates the 1020 rule); caller-materialized `-BaseSnapshot`/`-BaseLedger` files (changes the
   `-Base <ref>` contract); re-running analyzers at the base revision. Affected criteria: the
   `surface-delta` criteria and the context-member criterion.
2. **OQ-2 - Receipt commit policy.** Provisional default: strict ordinal revision equality, with the
   receipt as an uncommitted working-tree artifact. Alternative: accept a receipt whose revision is an
   ancestor of the head when every later commit changes only the receipt path (two bounded git calls in
   the hook). Affected criteria: the receipt-revision criteria.
3. **OQ-3 - Integration branch detection.** `integration_pr_gate` is a closed object with only
   `enabled`, so base and head patterns cannot be configured without a 1020 schema change. Provisional
   default: fixed base `main` and head `epic/<slug>-integration`. Affected criteria: the scope criterion.
4. **OQ-4 - Codex reach of the gate.** The docs lib ships in the Claude bundle only, so a Codex twin
   cannot import it. Provisional default: Claude-only hook; no `.codex/hooks/` twin and no
   `.codex/config.toml` change. Affected criteria: the registration criterion.
5. **OQ-5 - Snapshot freshness (cross-child, 1022 and 1023).** Whether `docs-complete` requires the
   snapshot revision to equal the requested revision, and whether `inventory` writes the snapshot so
   the workflow can regenerate it before `validate` and `surface-delta`. Provisional default: the
   workflow runs `inventory` first. Affected criteria: the workflow-content criterion.
6. **OQ-6 - feature-review tool grant.** Whether to grant `feature-review` a narrow
   `Bash(pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 *)` tool so the reviewer can run
   `surface-delta` itself. Provisional default: no; the evidence model applies. Affected criteria: the
   review-check criterion.
7. **OQ-7 - MCP tool for `surface-delta`.** Whether 900007 adds an MCP tool. Provisional default: no;
   skills call the entry script. Affected criteria: none in this child; 900007's scope.

No artifact in this child fails the language rule, so no language owner question is raised.

## Numeric Derivation Reference

The acceptance criteria enumerate the edited `feature-review` mirror files by name. That enumeration is
supported by the complete `## Numeric Derivation Evidence` record in
`docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/research/research.2026-10-30.md`
(complete family, exhaustive scope, inclusion and exclusion rules, a primary heading search and an
independent cross-check by body sentence and path enumeration, both member sets listed, and an explicit
member-set comparison). No criterion asserts a count. Percentages and line limits are thresholds.

## Acceptance Criteria

Epic criteria (from `### 900008 - docs-enforcement-and-ci`):

- [ ] With the gate disabled (default) the hook allows every call; enabled, it denies when the receipt is absent, failing, or pinned to another revision, and the deny text names the reason.
- [ ] `surface-delta` reports an added CLI command with no ledger change and reports nothing when the ledger records it.
- [ ] The workflow template requires `pwsh` only.
- [ ] Mirror parity checks pass for the edited `feature-review` surfaces.

Testable criteria:

- [ ] Gate disabled: for a missing profile and for a profile with `completion_gates.integration_pr_gate.enabled` set to `false`, `Invoke-DocsCompleteGateDecision` returns `permissionDecision` `allow` for every row of a command table that includes `gh pr merge` (bare, `--squash`, `--auto`, `--admin`), a `gh api` merge mutation and non-merge commands, and `Invoke-DocsOnlyGhExe` is invoked zero times (`tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`).
- [ ] Gate enabled, integration-to-`main` pull request (mocked `gh pr view` returning base `main` and head `epic/<slug>-integration`): the hook denies with text beginning `DOCS_COMPLETE_GATE_BLOCKED:` and containing `RECEIPT_ABSENT` for no receipt file, `RECEIPT_UNREADABLE` for unparseable receipt text, `RECEIPT_MODE` for a mode other than `docs-complete`, `RECEIPT_FAILING` for `validation_result` other than `pass`, and `RECEIPT_REVISION_MISMATCH` naming both revisions for a receipt pinned to another revision; it allows when the receipt passes and its `revision` equals `headRefOid` (`enforce-docs-complete-gate.Tests.ps1`).
- [ ] Gate enabled: the hook denies with `PROFILE_UNREADABLE` for an in-scope merge command when the profile text does not parse, with `PR_UNRESOLVED` when `gh pr view` fails, with `MATCH_HEAD_MISMATCH` when `--match-head-commit` differs from `headRefOid`, and with `RECEIPT_PATH_INVALID` when `artifact_paths.validation_receipt` is not a relative path; it allows non-merge commands and merges whose pull request is not base `main` with an `epic/<slug>-integration` head; a payload envelope anomaly denies (`enforce-docs-complete-gate.Tests.ps1`).
- [ ] `DocsCompleteGate.psm1` predicates are covered with in-memory strings only: enabled-flag parsing (absent key, `false`, `true`, invalid JSON, duplicate key), the integration-target predicate (matching and non-matching base and head names), each receipt reason code, and ordinal revision equality including case and length mismatches (`tests/scripts/claude-lib/docs/DocsCompleteGate.Tests.ps1`).
- [ ] `DocsCompleteGate.psm1` imports only `DocsJson.psm1` and `DocsSurface.psm1`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1` pass with no new Design exemption and no edit to the S8 exemption assertion.
- [ ] `.claude/settings.json` and its bundle copy each contain the entry `pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1` in the `PreToolUse` group with matcher `Bash`, the two copies are byte-identical, and `tests/scripts/claude-runtime/claude-settings.Tests.ps1`, `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1` (with the new `$script:ReasonPrefix` row) and `hook-dependency-failure.SpecialCases.Tests.ps1` pass.
- [ ] For in-memory base and head snapshots where the head adds a `cli-command` element and the head ledger equals the base ledger, `surface-delta` exits 1 with a `DOCS_SURFACE_UNLEDGERED_ADDITION` finding naming that `element_id`; when the head ledger adds an entry for that element, it exits 0 with no `error` finding and `result.added` contains the element (`tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1` and `DocsSurfaceDeltaCommands.Tests.ps1`).
- [ ] `Compare-DocsSurfaceSnapshot` and the finding builder report `DOCS_SURFACE_UNLEDGERED_CHANGE` for a changed `source_sha256` with no ledger or pin change and nothing when a pin for that element changes; report nothing for a `line_range`-only or `analysis_method`-only difference; treat a `$null` base snapshot as empty; report `DOCS_SURFACE_REMOVED_ENTRY_RETAINED` as a warning for a removed element whose ledger entry is unchanged; and produce identical output for seeded shuffled input orders, printing the seed on failure (`DocsSurfaceDelta.Tests.ps1`).
- [ ] `Invoke-DocsSurfaceDeltaCommand` with an in-memory context exits 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and `result` `null` for a `-Base` value beginning with `-` or containing `..`; exits 1 with `DOCS_SURFACE_BASE_UNRESOLVED` when `ResolveRevision` returns `$null`; exits 1 with `DOCS_SURFACE_SNAPSHOT_MISSING` for an absent head snapshot and `DOCS_SURFACE_SNAPSHOT_STALE` when an input digest differs from the working-tree bytes; and with `-Json` emits one canonical envelope whose `result` keys are `base_revision`, `added`, `changed` and `removed` (`DocsSurfaceDeltaCommands.Tests.ps1`).
- [ ] When 1020's D5 amendment has landed, the `surface-delta -Json` output for each tested exit path validates against `schemas/docs/v1/docs-command-envelope.schema.json` (`DocsSurfaceDeltaCommands.Tests.ps1`).
- [ ] `Invoke-DocsCommand.ps1` contains the `surface-delta` row directly under `# --- 900008: surface-delta ---`, `Test-DocsCommandTable` returns no finding, and `git diff <merge-base>..HEAD` of `Invoke-DocsCommand.ps1` and `DocsProfileCommands.psm1` shows only added lines under the 900008 anchors (plus, if OQ-1 assigns the edit to this child, added `ResolveRevision` and `ReadRevisionText` members in `New-DocsCommandContext`) and no changed or removed line.
- [ ] If OQ-1 assigns the context extension to this child, `New-DocsCommandContext` exposes `ResolveRevision` and `ReadRevisionText` with the specified return values, every git call goes through a `[scriptblock]`-typed parameter with a bounded wait, and a test drives both members through an injected process stand-in without starting a process (`tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` or a 900008 suite).
- [ ] `Get-DocsInitTemplate` returns a row under the `# --- 900008: docs workflow ---` anchor mapping `templates/_docs-quality.yml` to `.github/workflows/_docs-quality.yml`; `init` without `-Write` lists that destination in `result.planned_writes` and writes nothing; `init -Write` writes the template bytes through the in-memory context; and an existing destination without `-Force` yields `DOCS_INIT_TARGET_EXISTS` (`tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1`).
- [ ] The template text sets `shell: pwsh` on every `run` step, invokes `.claude/lib/docs/Invoke-DocsCommand.ps1` with `-Command check` and with `-Command validate` and `docs-complete`, passes the revision through `env:` rather than inline `${{ }}` in `run:`, checks out with `fetch-depth: 0`, and contains none of the tokens `setup-python`, `setup-node`, `python`, `npm` or `node` and no linter step (`DocsInitTemplate.DocsWorkflow.Tests.ps1`).
- [ ] The section `## Documentation Surface Check` is present in `.claude/agents/feature-review.md`, `.codex/agents/feature-review.toml`, `.agents/skills/feature-review/SKILL.md` and `.github/skills/feature-review-workflow/SKILL.md`, and each of their bundle copies under `extensions/drm-copilot/resources/` is SHA-256 identical to its source; `.github/agents/feature-review.agent.md` and the Codex `feature-reviewer*.toml` files are unchanged.
- [ ] The mirror and push-down parity suites pass on the feature branch: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_issue_824_follow_ups.py`, and `python -m scripts.dev_tools.generate_codex_agent_variants --check`; evidence records the SHA-256 comparison for the Copilot `feature-review-workflow` pair, for which no dedicated parity test was located.
- [ ] Every new file under `.claude/lib/docs/` (PowerShell and the workflow template) and the hook is listed exactly once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and is SHA-256 identical to its bundle copy; `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1`, `DocsNeutrality.Tests.ps1` and `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` pass.
- [ ] Pester line coverage is at least 85% for each new PowerShell production file (`DocsSurfaceDelta.psm1`, `DocsSurfaceDeltaCommands.psm1`, `DocsCompleteGate.psm1`, `enforce-docs-complete-gate.ps1`), read from the PoshQC coverage report, with no production file excluded from measurement and no regression on changed lines of `Invoke-DocsCommand.ps1` and `DocsProfileCommands.psm1`; no branch-coverage gate applies to Pester; figures are recorded under `<FEATURE>/evidence/coverage/`.
- [ ] No new production file exceeds 500 logical lines.
- [ ] No Python or TypeScript file is added or modified (`git diff --name-only <merge-base>..HEAD` lists no path ending in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`), and the plan's artifact classification table lists every created or edited file with its class, language and permitting rule.
- [ ] No test creates a temporary file: no new or edited test file contains `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`.
- [ ] (CI-dependent) The hook suite passes in the `poshqc-linux-hooks` job, and the required `poshqc / PowerShell QC` and `quality-checks7 / Code Quality & Tests` checks pass on the pull request head.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to Pester suites, contract tests or evidence files
- [ ] Behavior matches acceptance criteria on PowerShell 7.4 or later on Windows and Linux
- [ ] Edge cases covered: absent profile, invalid profile JSON, absent receipt, receipt revision case and length mismatch, `--match-head-commit` mismatch, unresolved base, absent base snapshot, stale snapshot, option-injection `-Base`
- [ ] Touched suites pass in three seeded shuffled file-order runs and a fresh single-process run over `tests/scripts`, with evidence under `<FEATURE>/evidence/regression-testing/`
- [ ] Toolchain pass completed (format, lint with PSScriptAnalyzer, architecture and contract tests, Pester) in a single clean pass
- [ ] Forbidden-token scan with bracket-class patterns over every changed file reports no match
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Pester unit suites for `DocsSurfaceDelta.psm1` and the hook (hook suite under `tests/scripts/claude-hooks/`)
- [ ] Template-row test for the `init` workflow template
- [ ] Mirror parity tests for `feature-review` surfaces
