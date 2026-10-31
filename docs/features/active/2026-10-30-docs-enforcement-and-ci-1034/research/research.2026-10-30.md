# docs-enforcement-and-ci (Issue #1034) - Research

- Issue: #1034 (epic #1019 child; manifest placeholder and anchor label `900008`; wave 2; band C3)
- Branch: `feature/docs-enforcement-and-ci-1034`
- Date: 2026-10-30
- Requirements source: `docs/features/epics/documentation-estate-tooling/epic.md` (binding sections listed in the
  delegation brief) and `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md`.
- Status of upstream code: none of the 1020, 1021 or 1023 code is present on this branch. A Glob of
  `.claude/lib/docs/**` returns no file. Every 1020/1021/1023 artifact below is therefore a contract,
  not verified code.

## Owner Decisions and Directives (propagated verbatim)

Owner decisions (2026-10-30, verbatim): "(1) A1 to A8 are CONFIRMED as written (separate Python/config and TypeScript/.NET analyzer features with 900004 later; no docs-site build; epic separate from issue #5; integration branch from origin/main; pushed-down logic is PowerShell under .claude/lib/docs/ behind Invoke-DocsCommand.ps1; TypeScript MCP wrappers call it; reuse discovery schemas and existing PowerShell discovery libs and do not call the Python discovery runtime; no new third-party PowerShell modules). (2) D1: the PowerShell rewrite counts as a NEW planning cycle for 1022 and 1024 (and for every superseded child); each gets a fresh allowance of one planner revision and the single-pass preflight; 1024's halted preflight must be addressed in the new plan (property tests for the six pure functions). (3) D3, language exception approved by the owner: a language-native analyzer is allowed when it analyzes that same language and is pushed down only with that language's pack (python pack for Python). The PowerShell text scanner stays the always-available baseline and keeps its documented precision limit, recorded as deferred-with-owner in the coverage ledger. The Python-native analyzer (Python ast, written in Python, shipped in the python pack manifest, tested under the Python gates) is IN THE FIRST RELEASE: keep 1022 as the PowerShell baseline scanner for Python/config surfaces and add a new child for the Python-native analyzer depending on 1022, in the earliest wave its dependencies allow; the planner decides the exact split and records it. C# and TypeScript native analyzers are LATER, optional children (900004 stays the baseline TypeScript/.NET scanner). The ledger must record the analysis method (native or scanner) per finding. (4) D4: linting stays optional by default (config only, no required Node or Python linter). (5) D5: docs-complete fails closed when the inventory snapshot has no revision; an element digest covers the declaration's lines, not the whole file; the JSON output envelope gets its own schema; test PowerShell Test-Json cross-file $ref first and use self-contained schemas as the fallback. Language rule otherwise unchanged: pushed-down skills, hooks and libs are PowerShell or bash; TypeScript only for MCP and extension commands."

Owner pacing directive (verbatim): "the quota pacing limits I gave you earlier are LIFTED. Ignore the cap of 3 concurrent preparation children, the cap of 8 agents in your subtree, and the 5-minute stagger. Launch every preparation child whose dependencies are satisfied at once, and run as parallel as the epic's dependency waves allow. Three accounts are available and the coordinator switches accounts when one nears its limit, so a rate-limit or account-switch error is never a failure signal: commit your working documents, wait and retry, and continue. Keep committing working documents regularly. All other rules are unchanged (language rule and the language-native analyzer exception, no forbidden tokens in any file, planning only, stop at preflight clearance)."

Hard constraints carried into the plan: refer to the originating consumer only as "one consumer
repository"; no forbidden tokens; planning only; never bypass a hook; pure functions take strings and
hashtables; no test creates a temporary file; an artifact that cannot follow the language rule is an
owner question; no absolute paths or host names in any artifact.

## Upstream Contract Inventory (1020, 1021, 1023)

Contracts this child consumes. "Present" means present in the tree at research time.

| Contract | Source | Present | Use in this child |
|---|---|---|---|
| `Invoke-DocsCommand.ps1` dispatch table with anchor `# --- 900008: surface-delta ---` | 1020 spec `#### Dispatch table` | No | One row for `surface-delta` |
| Row form `[pscustomobject]@{ Name; Module = (Join-Path -Path $PSScriptRoot -ChildPath '<literal>'); Function; Option = @{...} }`; option kinds `value`/`multi`/`switch`; reserved names `Command`, `Json`, `Help`, `RepositoryRoot`; function grammar `^Invoke-Docs[A-Za-z]+Command$` | 1020 spec | No | Row shape and command function name |
| Command function contract `Invoke-Docs<Area>Command -Argument <IDictionary> -Context <object>` returning `New-DocsCommandResult` | 1020 spec | No | `Invoke-DocsSurfaceDeltaCommand` |
| Command context members `RepositoryRoot`, `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow` (no git, no process member) | 1020 spec `### Entry script` | No | Working-tree reads; base-revision read is a gap (see Q6) |
| `Get-DocsInitTemplate` row form `{ Source = (Join-Path -Path $PSScriptRoot -ChildPath 'templates/<file>'); Destination }` under anchor `# --- 900008: docs workflow ---` | 1020 spec `### DocsProfileCommands.psm1` | No | Workflow template row |
| `init` semantics: dry run by default, `-Write` create-only, `-Force` overwrite, `DOCS_INIT_TARGET_EXISTS` | 1020 spec | No | Template delivery behavior |
| Profile path `docs/documentation-estate/docs-profile.json` (`Get-DocsDefaultProfilePath`); JSON only | 1020 spec | No | Hook and `surface-delta` profile read |
| Profile keys `completion_gates.integration_pr_gate.enabled` (closed object, only `enabled`; starter value `false`) and `artifact_paths.{inventory_snapshot, coverage_ledger, evidence_pins, validation_receipt}` | 1020 spec `### Artifact schema: docs-profile` | No | Gate switch, receipt path, snapshot and ledger paths |
| `docs-validation-receipt` fields `mode`, `repository`, `revision` (non-null; "900008 matches it against the head revision"), `inputs` (`artifact-pin`), `counts`, `validation_result`, `findings`, `issued_at`, `writer` | 1020 spec | No | Hook receipt check |
| `surface-inventory-snapshot` `revision` (or `null`), `inputs[{path, sha256, size}]`, `elements[]` with `element_id`, `kind`, `path`, `declaration`, `source_sha256`, `line_range` | 1020 spec | No | `surface-delta` inputs |
| `docs-coverage-ledger` `entries[]` keyed by `element_id`; `docs-evidence-pin` `pins[]` with `element_id`, `source_sha256` | 1020 spec | No | Ledger-change and pin-change detection |
| `ConvertFrom-DocsJsonText`, `ConvertTo-DocsCanonicalJson` (DocsJson.psm1); `New-DocsFinding`, `New-DocsCommandResult` (DocsFinding.psm1); `Test-DocsRelativePath`, `Test-DocsFullRevision` (DocsSurface.psm1) | 1020 spec | No | Parsing, findings, path and revision grammar |
| Rule "Parse JSON with `ConvertFrom-DocsJsonText`; never `ConvertFrom-Json` for artifacts" and "No filesystem, clock or process access outside the command context" | 1020 spec `## Decisions Later Children Must Honor` | n/a | Binding on hook and lib design |
| `check` subcommand (1021) | epic naming contract | No | Workflow step; PowerShell option names unspecified |
| `validate -Mode docs-complete` with required revision; explicit write-receipt switch persists to `artifact_paths.validation_receipt`; `DOCS_SNAPSHOT_UNPINNED` when snapshot revision is null; 900007 never persists receipts; "900008 reads a persisted receipt" | epic `### Command contract decisions from the first preparation of 1023` | No | Workflow step and hook input |
| Exit codes 0/1/2/3; `DOCS_CLI_ARGUMENTS` (2), `DOCS_CLI_RUNTIME` (3); `-Json` envelope `{command, exit_code, findings, ok, result}` | epic and 1020 spec | No | `surface-delta` output |

Gaps and conflicts found while reading the upstream documents:

- Envelope schema conflict. The epic section `### PowerShell contracts from the re-preparation of 1020`
  and 1020 spec `#### Exit codes and the -Json envelope` say "the envelope has no schema file"; D5 and
  `### Amendment of 1020 required by D3 and D5` add `schemas/docs/v1/docs-command-envelope.schema.json`.
  D5 is the later owner decision; `surface-delta -Json` output must validate against the envelope
  schema once 1020's amendment lands.
- Anchor labels. 1020 spec uses the labels `900003` (inventory, now 1022) and `900006`
  (generate-reference, now 1024), while the epic uses 1022 and 1024. The labels are literal comment
  text fixed by 1020's code. This child inserts under whatever literal `900008` anchor 1020 commits
  (`# --- 900008: surface-delta ---` and `# --- 900008: docs workflow ---` in the current spec); the
  executor must re-read the committed anchors because 1020's re-plan may renumber them.
- 1021 spec (`docs/features/active/2026-10-30-docs-page-quality-checker-1021/spec.md`) still describes
  the withdrawn Python package (`dev.docs.check --root --entry --exclude --format`). The PowerShell
  option names of `check` are unspecified.
- 1023 spec (`docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/spec.md`) still
  describes the withdrawn Python design (`dev.docs.validate --mode --revision --write-receipt`). Its
  `### Downstream constraints (binding on 900007 and 900008)` states the hook "reads the file at
  `artifact_paths.validation_receipt` and allows the gated merge only when `mode` is `docs-complete`,
  `validation_result` is `pass` and `revision` equals the head revision"; the receipt is written
  "exclusive create when absent, digest-checked replace when present". The PowerShell names of the
  mode, revision and write-receipt options are unspecified until 1023's re-preparation.
- Receipt persistence location is specified (`artifact_paths.validation_receipt`); whether the persisted
  receipt is committed is not specified. This matters for the hook (see Q3).

## Research Questions

### Q1. Hook registration, mirroring, Codex twins, opt-in precedent

Verified facts:

- Registration: `.claude/settings.json` `hooks.PreToolUse` has a group with `"matcher": "Bash"` whose
  entries are `{"type": "command", "command": "pwsh -NoProfile -File .claude/hooks/<name>.ps1"}`; the
  group currently lists `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`,
  `enforce-pr-author-skill.ps1`, `enforce-orchestration-preimplementation-gate.ps1`,
  `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`,
  `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`.
- The push-down copy `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` has
  the same content (read in full; byte equality is enforced by
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`).
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  (`paths`) lists `.claude/settings.json`, `.claude/agents/feature-review.md`, the five
  `.claude/hooks/enforce-epic-merge-gate*.ps1` files, `.claude/hooks/hook-docs-only-diff.ps1`, and the
  `.claude/lib/mermaid/*.psm1` modules. Completeness is pinned by
  `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`.
- Dependency closure: `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`
  (`test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`,
  `test_claude_command_text_closure`) checks that every `$PSScriptRoot` target of a manifested
  PowerShell file and every hook named by `.claude/settings.json` is in core. Recognized forms are
  listed in `tests/scripts/dev_tools/pack_manifest_dependency_scan.py` (F1 positional
  `Join-Path $PSScriptRoot '<child>'`, F2 named `Join-Path -Path $PSScriptRoot -ChildPath '<child>'`,
  and others).
- Codex twin: not required. Several pushed-down Claude hooks have no `.codex/hooks/` twin, for example
  `enforce-mermaid-validation.ps1`, `enforce-pr-author-skill.ps1`, `enforce-feature-folder-order.ps1`,
  `enforce-parallel-abandon-gate.ps1` (Glob of `.codex/hooks/*` versus `.claude/hooks/*`). Codex
  registration lives in `.codex/config.toml` (`[[hooks.PreToolUse]]` with `matcher = "^Bash$"`,
  `command = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/<name>.ps1"'`,
  `timeout = 30`). The Copilot hook surface `.github/hooks/` holds discovery hooks only.
- Opt-in precedent: no existing hook reads a consumer-profile switch (Grep for `enabled|opt-in` in
  `.claude/hooks` returns nothing). The closest precedent is `.claude/hooks/enforce-mermaid-validation.ps1`,
  which allows by design when its library module is absent (exemption D2 in
  `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`). The docs gate is therefore
  the first profile-gated hook; the profile key is `completion_gates.integration_pr_gate.enabled`.

Recommendation: register `pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1` as a
new entry in the existing `Bash` PreToolUse group, after `enforce-epic-merge-gate.ps1`, in both
settings copies; add the hook to `core.json`. No Codex twin and no `.codex/config.toml` change (owner
question OQ-4 records the Codex reach consequence).

### Q2. Merge detection, payload shape, test structure, Linux job

Verified facts:

- `.claude/hooks/enforce-epic-merge-gate.ps1` gates every `gh pr merge` (any method, `--auto`,
  `--admin`, bare) except a pure `--disable-auto`, and every `gh api` merge or enqueue mutation
  (`enqueuePullRequest`, `enablePullRequestAutoMerge`, `mergePullRequest`, REST `pulls/<n>/merge`).
  The predicate is `Test-EpicMergeGateCommandInScope` and the PR number reader is
  `Get-EpicMergeGateSelectorPrNumber`, both in `.claude/hooks/enforce-epic-merge-gate-command.ps1`
  (pure string logic; consumes `Get-CommandLineInvocation` and `Get-CommandLineStructuralMatch` from
  `hook-command-invocation.ps1`, which needs `hook-command-scanner.ps1`). Known limitation recorded in
  that file: a GraphQL mutation supplied from a file is not visible.
- The existing gate never identifies "integration to main" by branch name; it trusts checkpoints.
  Live PR data comes from `gh pr view <N> --json baseRefName,headRefOid`
  (`Get-DocsOnlyPullRequestTarget` in `.claude/hooks/hook-docs-only-diff.ps1`) or
  `gh pr view <N> --json headRefOid` (`Get-EpicMergeGateLivePrHeadSha` in
  `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1`). Both run through `Invoke-DocsOnlyGhExe`, which
  never throws, takes a `[scriptblock] $GhInvoker` seam, and bounds the process with
  `Invoke-DocsOnlyBoundedNative` (7000 ms for gh, 3000 ms for git, exit 124 on expiry). The same file
  validates the head as `^[0-9a-f]{40}([0-9a-f]{24})?$`, the base as a conservative branch spelling,
  and an optional `--match-head-commit` value against `headRefOid`.
- Integration branch naming: `epic/<epic-slug>-integration` created from `origin/main`
  (`.claude/skills/epic-plan/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`).
- Payload: `Read-ClaudeHookRawPayload`, `Resolve-ClaudeHookToolInput`, `Get-ClaudeHookToolInputString`,
  `Get-ClaudeHookEnvelopeValue` in `.claude/lib/hook-payload/HookPayload.psm1`. Envelope shape used by
  tests: `{session_id, tool_name: "Bash", tool_input: {command}}`. Decision shape:
  `{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "allow"|"deny",
  permissionDecisionReason}}` emitted as compact JSON with exit 0 (`Get-EpicMergeGateAllowDecision`,
  `Get-EpicMergeGateBlockDecision` in `enforce-epic-merge-gate-authorization.ps1`). Envelope anomalies
  deny.
- Hook skeleton enforced by tests: bootstrap line
  `$script:HookDependencyGuardLoadFailed = $false; try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { ... }`,
  one guarded single-statement `try { Import-Module ... -ErrorAction Stop } catch { Add-HookDependencyFailure ... }`
  per edge, `Get-HookDependencyFailureDecision` first in the decision function, dot-source early return,
  then the tail check (`tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`
  S1 to S6).
- Test structure: `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` dot-sources
  the hook, mocks the read seams (`Get-*CheckpointContent`), mocks `Invoke-DocsOnlyGhExe` and
  `Invoke-DocsOnlyGitExe` with `-ParameterFilter`, builds the envelope with `ConvertTo-Json`, and calls
  `Invoke-EpicMergeGateDecision -ToolInputRaw`. No process, no file write.
- Linux job: `.github/workflows/_poshqc.yml` job `poshqc-linux-hooks` ("PowerShell hook suites (Linux)",
  `ubuntu-latest`) runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` with coverage off.
  A new suite under `tests/scripts/claude-hooks/` runs there and in the Windows shards.
- Registered-hook enumerations that a new hook joins automatically:
  `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (B1 to B3 per hook; B4 requires a
  `$script:ReasonPrefix` entry for every registered Claude hook and no other),
  `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`,
  `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` (imports `HookPayload.psm1` and
  calls `Read-ClaudeHookRawPayload`), `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`
  (repository and mirror roots), `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1`
  (no success- or warning-stream write in any module a registered hook imports),
  `tests/scripts/claude-runtime/claude-settings.Tests.ps1` (membership assertions only).

Recommended hook design (`enforce-docs-complete-gate.ps1`, deny prefix `DOCS_COMPLETE_GATE_BLOCKED:`):

1. Dependency decision first; envelope anomaly denies (sibling convention).
2. No `command`, or `Test-EpicMergeGateCommandInScope` false: allow (pure, no I/O).
3. Profile read through a file seam (`Get-DocsCompleteGateFileText`) at
   `docs/documentation-estate/docs-profile.json` under the session repository root. Absent profile:
   allow. `enabled` false or absent: allow. Profile text that does not parse: deny
   `PROFILE_UNREADABLE` (only reached for an in-scope merge command).
4. Resolve the pull request with one bounded call:
   `gh pr view [<N>] --json baseRefName,headRefName,headRefOid` through `Invoke-DocsOnlyGhExe`
   (number from `Get-EpicMergeGateSelectorPrNumber`; no number means the current branch). Unresolved:
   deny `PR_UNRESOLVED`. A `--match-head-commit` that differs from `headRefOid`: deny.
5. Scope to the integration merge: `baseRefName` equals `main` and `headRefName` matches
   `^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$`; otherwise allow (OQ-3 covers other default branches).
6. Receipt checks (pure, in `DocsCompleteGate.psm1`) on the file at `artifact_paths.validation_receipt`
   (path checked with `Test-DocsRelativePath`): absent `RECEIPT_ABSENT`; unparseable or wrong
   `artifact_kind` `RECEIPT_UNREADABLE`; `mode` not `docs-complete` `RECEIPT_MODE`; `validation_result`
   not `pass` `RECEIPT_FAILING`; `revision` not equal (ordinal) to `headRefOid`
   `RECEIPT_REVISION_MISMATCH` (deny text names both revisions). Allow otherwise.

The deny text names the reason code, which satisfies the acceptance criterion "the deny text names the
reason". Residual limits (record them in the hook header as the existing gates do): local working-tree
reads; ambient `GH_REPO`; a push after the lookup; a direct `git push` to `main` is outside `gh` scope.

### Q3. Head revision, receipt and profile location; may the hook import `.claude/lib/docs/`

- Head revision: the PR `headRefOid` from `gh pr view` (Q2 step 4) is the revision the merge will
  land; a local `git rev-parse HEAD` is not used, because the session worktree may hold a different
  commit than the PR head.
- Receipt: 1023 persists it at `artifact_paths.validation_receipt` (1023 spec, downstream constraints;
  epic command contract). Open contract: whether that file is committed. A receipt committed inside the
  head commit cannot record that commit's own identifier (the same constraint that
  `.claude/skills/feature-review-workflow/SKILL.md` `### modified-workflow-needs-green-run` condition (b)
  documents). With strict equality (the acceptance criterion "pinned to another revision" denies), the
  receipt must be a working-tree artifact produced at the PR head immediately before the merge and not
  committed. OQ-2 records the alternative.
- Profile: `docs/documentation-estate/docs-profile.json` relative to the session repository root
  (1020 `Get-DocsDefaultProfilePath`).
- Importing `.claude/lib/docs/`: permitted with conditions, verified against the two named tests.
  - `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.claude/hooks`,
    `.codex/hooks` and `.claude/lib` (not the bundle mirror). It flags interpreter commands,
    `Invoke-Expression`/`iex`, and `&` on any variable that is not a `[scriptblock]` parameter in the
    same function; it allows `[scriptblock]` seams and dot-sourcing `Join-Path $PSScriptRoot '<x>.ps1'`.
    Running `gh` through `Invoke-DocsOnlyGhExe` satisfies it.
  - `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` S4 requires every
    transitive edge to be covered and terminating (a column-0 `Import-Module ... -ErrorAction Stop` in a
    module imported under the hook's guard qualifies). S5 requires every runtime edge (an
    `Import-Module` inside a function or script-block expression anywhere in the closure) to be
    pre-loaded under a guard at hook level, unless a named Design exemption exists; S8 pins the Design
    exemptions to exactly `D2`, `D3`, `D4`.
  - Consequence: the hook must not import a docs module whose closure contains a runtime import. Per the
    1020 spec, `DocsAnalyzerRegistry.psm1` carries a default `-ImportModule` script block that runs
    `Import-Module -Name <path>`, `DocsProfile.psm1` imports `DocsAnalyzerRegistry.psm1`, and
    `Invoke-DocsCommand.ps1` imports command modules only when a row is selected. Importing any of
    them would produce an S5 finding that only a new exemption (and an edit of the S8 assertion) could
    clear. Recommendation: a new pure module `.claude/lib/docs/DocsCompleteGate.psm1` that imports only
    `DocsJson.psm1` and `DocsSurface.psm1` (closure per 1020: `DocsFinding.psm1`,
    `../discovery-validation/DiscoveryEncoding.psm1`, which has no import). The hook imports
    `DocsCompleteGate.psm1` with one guarded edge. The absence of runtime imports in those 1020 modules
    is a contract to verify after 1020 merges.
  - The same closure must write nothing at module scope (`hook-imported-modules-no-stdout.Tests.ps1`).

### Q4. `feature-review` mirrors and parity coverage; where the check belongs

Verified mirror and coupling map:

| File | Nature | Kept in sync by |
|---|---|---|
| `.claude/agents/feature-review.md` | Canonical Claude agent (frontmatter tools: `Read`, `Grep`, `Glob`, `Bash(git diff *)`, `Bash(git log *)`, `Write(/docs/features/active/**)`, `mcp__drm-copilot__validate_orchestration_artifacts`) | Hand-edited |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md` | Byte copy | `test_push_down_claude_resource_contracts.py` |
| `.codex/agents/feature-review.toml` | "Converted subagent": a TOML wrapper embedding a drifted copy of the Claude body with `.claude/rules` and `.claude/skills` paths rewritten to `.agents/skills` | Hand-edited; no CI step regenerates it (only `generate_codex_agent_variants --check` runs in `_quality-checks.yml`); converter sources `scripts/dev_tools/codex_native_converter/pipeline.py` and `extensions/drm-copilot/src/lib/codex-native-converter/pipeline-render.ts` exist |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | Byte copy | Codex resource contracts; listed in `test_push_down_codex_and_agents_pack_manifest_completeness.py` and `test_push_down_issue_824_follow_ups.py` |
| `.codex/agents/feature-reviewer.toml` and generated `feature-reviewer-c1`/`-c2`/`-c3`/`-c3-elevated`/`-c4` | Codex routed reviewer; delegates to the `feature-review` skill and carries no procedure text | `scripts/dev_tools/generate_codex_agent_variants.py --check` (`CORE_FAMILIES` includes `feature-reviewer`), `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py` |
| `.agents/skills/feature-review/SKILL.md` and its bundle copy | Codex review procedure (has `## File Size Advisory`) | Codex resource contracts |
| `.github/agents/feature-review.agent.md` and bundle copy | Copilot agent; delegates to shared skills; no `## File Size Advisory` | Copilot push-down |
| `.github/skills/feature-review-workflow/SKILL.md` and bundle copy | Copilot review procedure (has `## File Size Advisory`) | Copilot push-down (parity test for this pair not located; see Unverified Facts) |
| `.claude/skills/feature-review-workflow/SKILL.md` | Claude workflow skill; has `## Policy Rules` (`### modified-workflow-needs-green-run`); not preloaded by the Claude agent (`skills:` lists `policy-compliance-order`, `acceptance-criteria-tracking`) | Six-copy text tests in `test_push_down_issue_824_follow_ups.py` |

- `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
  pins `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`; no
  feature-review surface is pinned.
- Text tests that read `.claude/agents/feature-review.md`: `claude-architecture-doc.Tests.ps1`
  (version-folder sentence), `test_completion_gate_documentation_contracts.py`,
  `test_orchestrator_state_remediation_docs.py`, `test_push_down_tier_rule_adoption_gate.py`,
  `test_push_down_issue_824_follow_ups.py` (`FALLBACK_COPIES`, `FEATURE_REVIEW_TEXT_COPIES`,
  `EXPECTED_LISTED_COPY_COUNT = 40`). An additive section changes none of their asserted phrases, but
  the planner records each with disposition "unchanged because unaffected".

Precedent: the `## File Size Advisory` section was placed in exactly the procedure-bearing copies listed
in the Numeric Derivation Evidence record below (Claude agent, Codex converted agent, Codex
`feature-review` skill, Copilot `feature-review-workflow` skill, each with its bundle copy).

Recommendation:

- Place the check as a new `## Documentation Surface Check` section in the procedure-bearing copies
  that follow the `## File Size Advisory` precedent: `.claude/agents/feature-review.md`,
  `.codex/agents/feature-review.toml`, `.agents/skills/feature-review/SKILL.md`,
  `.github/skills/feature-review-workflow/SKILL.md`, and the bundle copy of each. The Codex variant
  family `feature-reviewer*.toml` and `.github/agents/feature-review.agent.md` stay unchanged, because
  they delegate to the skills that carry the procedure; the generator check is therefore unaffected.
- Check semantics (evidence model, consistent with "inspect pre-existing artifacts, do not rerun"):
  applicable only when `docs/documentation-estate/docs-profile.json` exists on the branch head. The
  reviewer lists changed paths with `git diff --name-only <merge-base>..HEAD` (already permitted). When
  any changed path is under a profile `surface_selection.source_roots` entry, the reviewer requires the
  newest `<FEATURE>/evidence/qa-gates/docs-surface-delta.<timestamp>.md` (schema `Timestamp`,
  `Command`, `EXIT_CODE`, `Output Summary`). Absent artifact, or `EXIT_CODE: 1`: Blocking finding
  `surface-change-without-ledger-change` with `Remediability: autonomous`. Profile absent: not
  applicable, no finding.
- No tool is added to the agent frontmatter; adding `Bash(pwsh ...)` would touch the architecture
  document test and the Codex wrappers (OQ-6 offers it as an owner choice).

### Q5. Push-down carriage of hooks and settings

- `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`: `ROOT_FOLDERS` is
  `[".claude", "config"]`; `EXCLUDED_RELATIVE_PATHS` holds `.claude/settings.local.json` and
  `config/blast-radius.local.json`; `MERGED_RELATIVE_PATHS` holds only
  `config/orchestration-routing.json` and `config/blast-radius.json`; the comment states "Every other
  published file is a plain overwrite". `.claude/settings.json` is therefore overwritten in the
  destination, so the hook registration arrives with the core pack. `BUNDLE_ROOT_RELATIVE_DIR` is
  `extensions/drm-copilot/resources/claude-customizations`; manifests live in `pack-manifests/`.
- A destination `.gitignore` merge exists (`claude-gitignore-merge.ts`, `.claude/state/` stanza); it
  cannot carry a profile-configured receipt path, so receipt ignoring is a consumer onboarding item
  (900010).
- Required edits: hook file plus bundle copy; both settings copies; `core.json` entries for the hook and
  every new `.claude/lib/docs/` file (1020 decision: every docs lib file, PowerShell and data, is listed
  in core and mirrored byte-identically; `Docs.Manifest.Tests.ps1` from 1020 enforces it).
- Destination prerequisite inherited from 1020: PowerShell 7.4.

### Q6. `surface-delta` design

Contract gap (blocking for the design, owner question OQ-1): the 1020 command context exposes
working-tree reads only (`ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow`), and
1020 binds "No filesystem, clock or process access outside the command context". `surface-delta -Base
<ref>` must read the snapshot, ledger and pins as they were at a base revision, which needs a git
process. Existing PowerShell git helpers: `Invoke-DocsOnlyGitExe` and `Invoke-DocsOnlyBoundedNative`
(`.claude/hooks/hook-docs-only-diff.ps1`, a hooks file, not a lib); `Invoke-GitExe`
(`.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1`, `git show :N:<path>`); the
`WorktreeListInvoker` seam in `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`. None is a docs
lib module.

Candidate approaches:

1. Recommended - extend the 1020 command context (epic-level amendment, implemented by 1020's re-plan or
   delegated to this child by an epic update) with read-only revision members built only by
   `New-DocsCommandContext`: `ResolveRevision` (`git -C <root> rev-parse --verify --end-of-options
   <ref>^{commit}`, returning a full revision or `$null`) and `ReadRevisionText` (`git -C <root> show
   <revision>:<relative path>`, returning text or `$null` when the path is absent at that revision),
   bounded like `Invoke-DocsOnlyBoundedNative`. Keeps every process call inside the context, keeps
   `DocsSurfaceDelta.psm1` pure, and lets tests inject an in-memory context.
2. Rejected - a git I/O module owned by this child outside the context: violates the binding 1020 rule.
3. Rejected - `-BaseSnapshot <path>` and `-BaseLedger <path>` files materialized by the caller: changes
   the `-Base <ref>` contract and moves git into workflow YAML and every other caller.
4. Rejected - re-running analyzers over base sources: needs captured inputs at the base revision,
   couples this child to 1022 and 900004 analyzer code, and is slow.

Comparison model (snapshot to snapshot; pure functions in `DocsSurfaceDelta.psm1`, inputs are parsed
ordinal hashtables, `$null` for an artifact absent at base):

- Element identity: `element_id` (`<kind>-<sha256>` over kind, path, declaration; 1020). An element is
  added when its identifier is in the head snapshot only, removed when in the base snapshot only, and
  changed when present in both with a different `source_sha256` (the declaration-lines digest under D5;
  `line_range` and `analysis_method` differences are not changes, so a scanner/native switch or a line
  shift reports nothing).
- Ledger change for an element: the canonical JSON (`ConvertTo-DocsCanonicalJson`) of its ledger entry
  differs between base and head (including absent to present), or, for a changed element, any evidence
  pin with that `element_id` differs.
- Findings (codes proposed; planner may rename): `DOCS_SURFACE_UNLEDGERED_ADDITION` (error; added element
  with no ledger change), `DOCS_SURFACE_UNLEDGERED_CHANGE` (error; changed element with no ledger or pin
  change), `DOCS_SURFACE_REMOVED_ENTRY_RETAINED` (warning; removed element whose head ledger still holds
  an unchanged entry), `DOCS_SURFACE_SNAPSHOT_MISSING` (error; no head snapshot),
  `DOCS_SURFACE_SNAPSHOT_STALE` (error; a head snapshot `inputs[]` digest differs from the working-tree
  bytes, computed with `Get-DocsBytesSha256Hex` over `Context.ReadBytes`), `DOCS_SURFACE_BASE_UNRESOLVED`
  (exit 1; base ref does not resolve). Base snapshot absent at the base revision means "adopted on this
  branch": the base is empty and every head element is added.
- `-Base` grammar check before any read: full revision, or a ref matching
  `^[A-Za-z0-9][A-Za-z0-9._/-]*$` without `..` (prevents option injection; mirrors
  `Get-DocsOnlyPullRequestTarget`); violation exits 2 with `DOCS_CLI_ARGUMENTS`.
- Result (`-Json` `result`): `{base_revision, added: [element_id...], changed: [...], removed: [...]}`
  each sorted ordinally; findings ordered by `Get-DocsOrderedFinding`.
- Dispatch row under `# --- 900008: surface-delta ---`:
  `[pscustomobject]@{ Name = 'surface-delta'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurfaceDeltaCommands.psm1'); Function = 'Invoke-DocsSurfaceDeltaCommand'; Option = @{ Base = 'value'; Profile = 'value' } }`.
- Module split: `DocsSurfaceDelta.psm1` (pure comparison, epic-named) and
  `DocsSurfaceDeltaCommands.psm1` (command function using the context), following the
  `DocsProfile.psm1`/`DocsProfileCommands.psm1` split in 1020.
- Freshness boundary: the stale check covers changed inputs; a new source file that is not yet in the
  snapshot is not detected by `surface-delta`. The workflow closes this by regenerating the snapshot
  with `inventory` (1022) before running the delta (Q7; OQ-5).

Test patterns: `tests/scripts/claude-lib/<area>/` suites (for example `tests/scripts/claude-lib/mermaid/`)
and `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`; 1020 adds
`tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` with an in-memory command context, which this
child extends with in-memory `ResolveRevision`/`ReadRevisionText` members once OQ-1 is settled.

### Q7. Workflow template

- Conventions (`.github/workflows/_docs-validation.yml`, `_poshqc.yml`): reusable file named
  `_<name>.yml`, `on: workflow_call` plus `workflow_dispatch`, job `name:` set, `runs-on: ubuntu-latest`,
  `permissions: contents: read`, `actions/checkout@v7`, PowerShell steps with `shell: pwsh`.
- Lint exposure: `.github/instructions/github-actions.instructions.md` applies to
  `.github/workflows/**/*.yml` only and names `scripts/dev-tools/run-actionlint.ps1` and "job `actionlint`
  in `.github/workflows/ci.yml`"; Grep finds no `actionlint` in `ci.yml`. Root Prettier
  (`package.json` `format:check`) covers `src/` and `tests/` JSON and script files only. No test globs
  every `*.yml` (Grep for `rglob("*.yml")`-style patterns under `tests/` found none). The
  `modified-workflow-needs-green-run` review rule matches `.github/workflows/**` only. A template at
  `.claude/lib/docs/templates/_docs-quality.yml` therefore trips no workflow lint or manifest rule beyond
  the 1020 core-manifest listing, byte mirroring and neutrality scan (`DocsNeutrality.Tests.ps1` scans
  every file under `.claude/lib/docs/`).
- Recommended content (data only; `pwsh` is the only runtime, satisfying "requires `pwsh` only"):
  `on: workflow_call` (inputs `base-ref`, optional) and `workflow_dispatch`; checkout with
  `ref: ${{ github.event.pull_request.head.sha || github.sha }}` and `fetch-depth: 0` (the PR default
  checkout is the merge commit, and `surface-delta` needs base history); revision passed to the step
  through `env:` rather than inline `${{ }}` in `run:` (injection hygiene); steps
  `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command check -Json` and
  `... -Command validate -Mode docs-complete -Revision $env:DOCS_REVISION <write-receipt switch> -Json`;
  optional `surface-delta -Base` step when `base-ref` is supplied; optional receipt upload with
  `actions/upload-artifact@v7`. No `setup-python`/`setup-node` step.
- Template-row test: a Pester test asserts the `Get-DocsInitTemplate` row under the 900008 anchor maps
  `templates/_docs-quality.yml` to `.github/workflows/_docs-quality.yml`, that `init` without `-Write`
  plans the destination, that `-Write` writes the template bytes through the in-memory context, and that
  the template text contains `shell: pwsh` and `Invoke-DocsCommand.ps1` and no `setup-python`,
  `setup-node`, `python` or `npm` token.
- Consumer prerequisite (onboarding, 900010): the destination must commit the pushed-down `.claude/lib/docs/`
  tree, or the workflow cannot find `Invoke-DocsCommand.ps1`.

### Q8. Quality tiers, file size, batch budget

- `quality-tiers.yml` already classifies `.claude/hooks` as T3; 1020 adds `.claude/lib/docs` as T3. No
  tier edit in this child. T3 carries no property-test density or mutation obligation; seeded
  order-invariance tests are still recommended for the pure comparison.
- File size: all files are new or receive small edits. Keep each new production file under the 500-line
  guidance (hook, `DocsCompleteGate.psm1`, `DocsSurfaceDelta.psm1`, `DocsSurfaceDeltaCommands.psm1`).
  No `config/file-size-baseline.json` change. Markdown and TOML agent files are exempt or not covered
  extensions.
- Batch budget: production PowerShell files touched are four created (hook, `DocsCompleteGate.psm1`,
  `DocsSurfaceDelta.psm1`, `DocsSurfaceDeltaCommands.psm1`) and two edited (`Invoke-DocsCommand.ps1`,
  `DocsProfileCommands.psm1`), each with a bundle copy; this exceeds the direct-mode cap of three, so
  execution runs in the item worktree under a `large` (or `preparation`) route checkpoint, never in an
  isolated executor worktree (`.claude/skills/execution-environment/SKILL.md` `## Batch Budget`).

### Q9. Artifact classification table

Rule references: R1 = language rule clause (1) (pushed-down skills, helpers, hooks and libs are
PowerShell or bash); D = epic `### Artifact classes for this epic` (hook, skill/agent, schema/config/data,
test rows). No row is TypeScript or Python.

| File (create unless noted) | Class | Language | Permitting rule |
|---|---|---|---|
| `.claude/lib/docs/DocsSurfaceDelta.psm1` | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1` (module-name refinement) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsCompleteGate.psm1` (refinement; pure gate predicates for the hook) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/templates/_docs-quality.yml` | schema/config/data (consumer workflow template) | YAML | D |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edit: one row; plus context members if OQ-1 assigns them here) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsProfileCommands.psm1` (edit: one `Get-DocsInitTemplate` row) | pushed-down helper/lib | PowerShell | R1 |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | hook | PowerShell | R1, D |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/**` and `.../.claude/hooks/enforce-docs-complete-gate.ps1` (byte copies of every row above) | pushed-down helper/lib, hook, data (mirror) | PowerShell, YAML | R1, D |
| `.claude/settings.json` and its bundle copy (edit) | schema/config/data | JSON | D |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (edit) | schema/config/data | JSON | D |
| `.claude/agents/feature-review.md` and bundle copy (edit) | agent | Markdown | D |
| `.codex/agents/feature-review.toml` and bundle copy (edit) | agent (Codex mirror) | TOML wrapper with Markdown body | D |
| `.agents/skills/feature-review/SKILL.md` and bundle copy (edit) | skill | Markdown | D |
| `.github/skills/feature-review-workflow/SKILL.md` and bundle copy under `extensions/drm-copilot/resources/customizations/` (edit) | skill (Copilot) | Markdown | D |
| `tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1`, `DocsSurfaceDeltaCommands.Tests.ps1`, `DocsCompleteGate.Tests.ps1`, `DocsInitTemplate.DocsWorkflow.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | test | PowerShell (Pester) | D |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (edit: one `$script:ReasonPrefix` row) | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/**` | documentation | Markdown | D |

Every artifact follows the language rule; no language owner question arises.

### Q10. Contracts set for later children, and owner questions

Contracts this child sets:

- 900007 (MCP): `surface-delta` is a subcommand with the `-Json` envelope and `result`
  `{base_revision, added, changed, removed}`. The naming contract's six MCP tools do not include it;
  wrapping it needs an epic naming-contract update (OQ-7). `validate_docs_artifacts` must still not
  persist receipts, because the hook trusts only persisted receipts.
- 900009 (authoring roles): the `docs-coverage-reviewer` role and the `docs-review-coverage` skill can
  call `surface-delta`; the finding codes above and the evidence artifact name
  `docs-surface-delta.<timestamp>.md` under `<FEATURE>/evidence/qa-gates/` are fixed by this child.
- 900010 (template and onboarding): the epic template's final gate sets
  `completion_gates.integration_pr_gate.enabled` to `true`; onboarding documents (a) running
  `validate -Mode docs-complete` with the write-receipt switch at the integration branch head before
  merging, (b) not committing the receipt path (or the OQ-2 alternative), (c) adding a caller job for
  `_docs-quality.yml`, (d) committing the pushed-down `.claude/lib/docs/` tree, (e) the deny prefix
  `DOCS_COMPLETE_GATE_BLOCKED:` and its reason codes, and (f) that the gate is Claude-only (OQ-4).
- Hook contract: profile at `docs/documentation-estate/docs-profile.json`; integration merge means base
  `main` and head `epic/<slug>-integration`; receipt equality is ordinal on the full revision.

Owner questions (provisional defaults in parentheses; none is decided here):

- OQ-1 (contract gap, coordinator and 1020): base-revision read access for `surface-delta`. Add
  `ResolveRevision` and `ReadRevisionText` to the 1020 command context through an epic-level amendment
  (default: yes, owned by 1020's amendment cycle; if 1020 has already cleared, an epic update authorizes
  this child to edit `New-DocsCommandContext`).
- OQ-2: receipt commit policy. (Default: strict revision equality; the receipt is an uncommitted
  working-tree artifact.) Alternative: accept a receipt whose revision is an ancestor of the head when
  every later commit changes only the receipt path, mirroring condition (b) of
  `modified-workflow-needs-green-run`; costs two bounded git calls in the hook.
- OQ-3: integration branch detection. `integration_pr_gate` is a closed object with only `enabled`, so
  base and head patterns cannot be configured without a 1020 schema change. (Default: fixed `main` and
  `epic/<slug>-integration`.)
- OQ-4: Codex reach of the gate. The docs lib ships in the Claude bundle only (epic Q7, 1020 OQ-2), so a
  Codex twin cannot import it. (Default: Claude-only hook.)
- OQ-5 (cross-child, 1022 and 1023): snapshot freshness. Whether `docs-complete` requires the snapshot
  revision to equal `-Revision`, and whether `inventory` writes the snapshot so the workflow can
  regenerate it before `validate` and `surface-delta`. (Default: the workflow runs `inventory` first.)
- OQ-6: grant `feature-review` a narrow `Bash(pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 *)`
  tool so the reviewer can run `surface-delta` itself. (Default: no; the evidence model applies.)
- OQ-7: add an MCP tool for `surface-delta` in 900007. (Default: no; skills call the entry script.)

## Rejected Alternatives (summary)

- Gate logic inside `Invoke-DocsCommand.ps1` called from the hook: the entry script performs runtime
  imports, which fail the S5 dependency-guard rule.
- Reading the profile and receipt with `ConvertFrom-Json` and no docs import: breaks the binding 1020
  JSON-parsing rule.
- Placing the review rule in `.claude/skills/feature-review-workflow/SKILL.md` only: the Claude agent does
  not preload that skill, and the `## File Size Advisory` precedent uses the agent.
- Approaches 2 to 4 under Q6.

## Test Strategy

- `DocsSurfaceDelta.Tests.ps1`: added CLI command with no ledger change reports
  `DOCS_SURFACE_UNLEDGERED_ADDITION` (acceptance criterion); the same with a head ledger entry reports
  nothing; changed digest with and without pin change; removed element; absent base snapshot; line-range
  and `analysis_method` changes report nothing; seeded shuffled input order yields identical output
  (seed printed on failure). All inputs are in-memory hashtables.
- `DocsSurfaceDeltaCommands.Tests.ps1`: in-memory context including revision members; exit 0/1/2/3
  paths; `-Base` grammar rejection; stale snapshot; envelope shape.
- `DocsCompleteGate.Tests.ps1`: profile parsing outcomes (absent key, `false`, `true`, invalid JSON,
  duplicate key), integration-target predicate, each receipt reason code, revision equality (case and
  length mismatches).
- `enforce-docs-complete-gate.Tests.ps1` (runs on Linux and Windows): dot-source the hook; mock
  `Get-DocsCompleteGateFileText`, `Invoke-DocsOnlyGhExe` and the root seam; rows for gate disabled
  (profile absent, `enabled` false: allow every call, with `Should -Invoke Invoke-DocsOnlyGhExe -Times 0`),
  out-of-scope commands, non-integration PR, each deny reason, matching receipt allow,
  `--match-head-commit` mismatch, payload anomaly deny. Forward-slash relative paths, `Join-Path`,
  exact file-name case, no drive letters.
- Template-row test as described under Q7.
- Contract suites run unchanged and must pass: push-down resource, completeness and dependency-closure
  tests; `hook-dependency-guard-completeness.Tests.ps1`; `hook-dependency-failure.Claude.Tests.ps1` (with
  the new prefix row); `hook-imported-modules-no-stdout.Tests.ps1`; `PreToolUsePayload.Contract.Tests.ps1`;
  `enforcement-hooks-no-python-invocation.Tests.ps1`; `claude-settings.Tests.ps1`;
  `ClaudeLibModuleConvention.Tests.ps1`; 1020's `Docs.Manifest.Tests.ps1` and `DocsNeutrality.Tests.ps1`;
  `test_push_down_issue_824_follow_ups.py`; the Codex generator `--check`.
- Coverage: Pester line coverage of at least 85% per new production file from
  `artifacts/pester/powershell-coverage.xml`; no branch gate for PowerShell.

## Pre-Mortem

- Review checklists: a reviewer can flag the `.codex/agents/feature-review.toml` edit as drift from the
  Claude body, or flag a mirror copy missing the new section. Mitigation: the plan edits the four
  procedure-bearing copies and their four bundle copies in one task, and a task verifies the section
  heading is present in each named file and that each bundle copy is byte-identical.
- Coverage: hook tail lines after the dot-source guard and the default gh invoker body are not reached by
  unit tests. Mitigation: keep the tail to the sibling-hook shape, keep logic in `DocsCompleteGate.psm1`
  and decision functions, and drive the default invoker path through `-ProcessStarter` stand-ins as
  `hook-docs-only-diff.ps1` tests do.
- Mirror parity: settings, hook, lib and template copies drifting from their bundle copies, or a file
  missing from `core.json`, fails the push-down contract tests and 1020's `Docs.Manifest.Tests.ps1`.
  Mitigation: one copy task per edit wave followed by a hash comparison task. The plan changes no fact
  in `.claude/skills/execution-environment/SKILL.md` (no CI job, required context, tool route or
  batch-budget rule changes), so no brief-update task is needed; preflight confirms this.
- File size: the hook can grow past 500 lines if decision logic stays in it. Mitigation: pure predicates
  live in `DocsCompleteGate.psm1`; the hook keeps payload, scope and seams only.
- Test isolation: dot-sourcing the hook defines functions and imports `HookPayload`, docs and
  `DiscoveryEncoding` modules into the session; leaked mocks or modules cause order dependence in the
  single-process run. Mitigation: `AfterAll` removes imported modules; three seeded shuffled file-order
  runs of the touched suites plus a fresh single-process run over `tests/scripts`, recorded under
  `<FEATURE>/evidence/regression-testing/`.
- CI-only behavior: the Linux hook job is case-sensitive, and `_shell-coverage.yml` has no `origin/main`.
  Mitigation: forward-slash relative paths and exact case; no test diffs against `origin/main`; no test
  reads gitignored `artifacts/` state; `Test-Json` behavior on `windows-latest` is not relied on by this
  child.
- Evidence: an acceptance claim depending on unmerged 1020/1021/1023 code would be unprovable.
  Mitigation: execution starts only after those children merge into the integration branch; evidence
  files carry `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary` with UTC write-time stamps under
  `<FEATURE>/evidence/<kind>/`, and record no absolute path (scratch locations as `SCRATCH`).

## Numeric Derivation Evidence

No acceptance criterion proposed here asserts a count; files are enumerated by name. The following
record supports the mirror-set statement in Q4.

- Complete Family: feature-review surfaces
- Exhaustive Search Scope: entire repository tree of the item worktree, excluding `docs/**` (feature
  evidence files quote these texts)
- Inclusion Rules: a file that carries the feature-review procedure text block introduced by the file-size advisory precedent
- Exclusion Rules: files under `docs/`; Codex `feature-reviewer*.toml` and `.github/agents/feature-review.agent.md`, which delegate to skills and carry no procedure text
- Primary Search Strategy or Query Expression: content search across feature-review surfaces for the heading text `## File Size Advisory` with glob `!docs/**`
- Primary Member Set: .claude/agents/feature-review.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md, .codex/agents/feature-review.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml, .agents/skills/feature-review/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md, .github/skills/feature-review-workflow/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md
- Primary Count: 8
- Cross-check Search Strategy or Query Expression: content search across feature-review surfaces for the body sentence `Produce no finding for the 500-line guidance tier` with glob `!docs/**`, compared against path enumeration globs `**/feature-review*.{md,toml,agent.md}`, `**/skills/feature-review/SKILL.md` and `**/feature-review-workflow/**`
- Cross-check Member Set: .claude/agents/feature-review.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md, .codex/agents/feature-review.toml, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml, .agents/skills/feature-review/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review/SKILL.md, .github/skills/feature-review-workflow/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md
- Cross-check Count: 8
- Member-set Comparison: the normalized primary and cross-check member sets are equal; the path globs list every member and additionally list delegating files that the exclusion rules remove.

## Automation Feasibility

All design and test work is automatable by the executor in the item worktree. Items needing the
orchestrator: `gh`/`git show` confirmations listed below, the OQ-1 contract decision before planning
`surface-delta`, and starting execution only after 1020, 1021 and 1023 merge into
`epic/documentation-estate-tooling-integration`. No step needs an interactive human action.

## Unverified Facts (for the orchestrator to confirm with git or gh)

- The 1020 module import graph as committed (no runtime import in `DocsJson.psm1`, `DocsFinding.psm1`,
  `DocsSurface.psm1`; module-scope output silence), the literal 900008 anchor text, and the
  `Get-DocsInitTemplate` row form; none exists on this branch.
- The PowerShell option names of 1021 `check` and of 1023 `validate` (mode, revision, write-receipt
  switch) and the receipt write semantics.
- Byte equality of `.claude/settings.json` with its bundle copy (content read as identical; hash not
  computed).
- Whether a test pins `.github/skills/feature-review-workflow/SKILL.md` to its copy under
  `extensions/drm-copilot/resources/customizations/` (not located).
- Whether `scripts/dev_tools/codex_native_converter/pipeline.py` has a check mode that would regenerate
  `.codex/agents/feature-review.toml` from the Claude agent (no CI step found).
- The claim in `.github/instructions/github-actions.instructions.md` that `ci.yml` has an `actionlint`
  job (Grep finds none).
- `gh pr view --json baseRefName,headRefName,headRefOid` with no number resolving the current branch's
  pull request from an agent worktree.
