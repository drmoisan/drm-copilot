# Research Addendum: Docs-Only Exemption for the Epic Merge Gate (issue #927)

- **Issue:** #927
- **Addendum to:** `research/research.2026-10-15T11-52.md` (unchanged)
- **Timestamp:** 2026-10-15T19-46
- **Tree:** branch `rev/927-merge-gate` (tracks `bug/pr-author-docs-only-exemption-hardening-927`), origin/main `adb9aa5f` merged in.
- **Method:** every citation below was read from the current tree with the Read and Grep tools. No command was executed (no git, gh, or pwsh), so no runtime behavior is claimed as observed. Statements about PR #939 are taken from the delegation prompt and were not verified here.
- **Superseded duplicate (remediation cycle R1, CR-6):** this file duplicates `research/2026-10-15T19-46-merge-gate-addendum-research.md`, the convention-compliant copy that `spec.md` and the plan cite. It is retained and is not a design input.

## 0. Scope addition (primary criterion)

The #901 exemption covers `gh pr create` only (`.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, called from `.claude/hooks/enforce-pr-author-skill-helpers.ps1:424`). The epic merge gate denies a `gh pr merge <N> --merge` for a PR that no checkpoint records. Required behavior: the merge gate allows such an invocation, with no exception or authorization record, when the PR's diff against `origin/<base>` lists only `docs/**` paths and no checkpoint records the PR, under the create-side fail-closed rules (exactly one resolvable base; non-empty diff; every path under `docs/`; `--no-renames`; any diff failure denies).

## 1. Claude merge gate: current decision flow

Files and line counts (verified): `.claude/hooks/enforce-epic-merge-gate.ps1` 472, `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` 443, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` 243.

### 1.1 Load order

- `enforce-epic-merge-gate.ps1:62` bootstrap of `hook-dependency-guard.ps1`.
- `:64` `HookPayload.psm1`; `:67-68` `hook-command-scanner.ps1`, `hook-command-invocation.ps1`; `:70` authorization sibling; `:72` resolution sibling. Each is a single-statement `try { ... } catch { Add-HookDependencyFailure ... }`.
- `enforce-epic-merge-gate-resolution.ps1:35-36` imports `WorktreeRunResolution.psm1` and `WorktreeItemResolution.psm1` under the same guard.

### 1.2 Scope filter (which command shapes are intercepted)

`Invoke-EpicMergeGateDecision` (`enforce-epic-merge-gate.ps1:295-416`):

1. `:318-319` dependency-failure deny first.
2. `:321-327` envelope anomaly deny.
3. `:329-332` no `command` field: allow.
4. `:343` `Test-CommandLineInvocation ... -SubcommandPath @('pr','merge')`; `:344` `Test-CommandLineFlag -FlagName '--merge'`; `:345-353` raw-scan fallback for wrapper-led, live-substitution, or unbalanced segments that contain `--merge`.
5. `:354-356` anything that is not `gh pr merge` carrying `--merge` is allowed. The header states `--squash` is out of scope (`:34`). `Test-CommandLineFlag` matches only the exact token or `--merge=` (`hook-command-invocation-operands.ps1:149-153`), so the `-m` shorthand is not in scope either (pre-existing; outside this item).

### 1.3 PR number, head, and base derivation

- PR number: `Get-EpicMergeGateCommandPrNumber` (`:99-143`): first all-digit positional operand of the structural `gh pr merge` match (`:131-135`), else the value token after `--merge` (`:137-140`), else `$null`. URL or branch selectors yield `$null`.
- Session root: `Get-EpicMergeGateSessionWorktreeRoot` (`resolution.ps1:98-110`) resolves `(Get-Location).Path` through `Resolve-WorktreeOperandTarget`. Nothing checks that its `HEAD` is the PR head.
- Head and base: **not derived**. The gate never calls gh or git. The header records this as a design decision (`enforce-epic-merge-gate.ps1:36-39`: the gate trusts the on-disk checkpoint "rather than shelling out live to gh pr view"). A Grep of `.claude/**/*.ps1|psm1` for `& gh`, `gh pr view`, and `Invoke-*GhExe` finds no gh invocation in any hook. There is no git or gh seam in any of the three files.

### 1.4 Checkpoint branches and where the two codes are emitted

With an explicit number:

- `:365-370` item target via `Resolve-EpicMergeGateItemTarget` (`resolution.ps1:133-149`); root used only for status `SessionRoot` or `OtherWorktree`.
- `:371-375` branch 1 (child) plus `Test-ChildCheckpointPrGateBinding` (`resolution.ps1:151-203`).
- `:383-388` epic and parallel targets via `Resolve-EpicMergeGateRunTarget` (`resolution.ps1:112-131`).
- `:390-398` branches 2 and 3.
- `:402-413` branch 4 (standalone): `Test-StandaloneCheckpointAllowsMerge` (`authorization.ps1:372-443`).

Emission of the two codes seen on PR #939:

- `STANDALONE_MERGE_AUTHORIZATION_ABSENT`: literal at `authorization.ps1:46`; selected at `authorization.ps1:415-417` when no checkpoint carries `standalone_merge_authorizations`.
- `TARGET_WORKTREE_NOT_DERIVABLE`: literal at `.claude/lib/worktree-resolution/WorktreeResolution.psm1:59`; it arrives as the target's `ReasonCode` and is composed by `Get-EpicMergeGateUnresolvedReason` (`resolution.ps1:205-243`, code selection `:241`), which returns non-null only when all three targets are `NoTarget` or `Ambiguous` (`:230-239`).
- Both are joined into one deny at `enforce-epic-merge-gate.ps1:410-412`: `EPIC_MERGE_GATE_BLOCKED: <TARGET_WORKTREE_NOT_DERIVABLE: details>; STANDALONE_MERGE_AUTHORIZATION_ABSENT: <message>`.

When all three targets are `NoTarget`, `childRoot`, `epicRoot`, and `parallelRoot` are `$null` (`:369`, `:386-387`), so all three checkpoints are `$null` and branch 4 necessarily returns `ABSENT`. That combination is exactly "no checkpoint records the PR" and is the PR #939 path.

A bare command (no number) falls to `:415` (fixed text, asserted with `-BeExactly` at `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:83,152`).

### 1.5 Insertion point

- Insert after `enforce-epic-merge-gate.ps1:407` (closing brace of `if ($standalone.Allowed)`) and before `:408`, inside the explicit-number block:
  1. When `Test-EpicMergeGateNoRecordingTarget` (new, in `enforce-epic-merge-gate-resolution.ps1`; true only when item, epic, and parallel targets all have `Status -eq 'NoTarget'`; `Ambiguous` returns false) holds, call the shared `Get-DocsOnlyMergeExemption -CommandText $commandText -PrNumber $commandPrNumber -WorktreeRoot $sessionRoot`.
  2. `Exempt` returns `Get-EpicMergeGateAllowDecision`.
  3. Otherwise `:412` appends ` (docs-only exemption not applied: <Reason>)` after the existing standalone message, keeping the existing prefix order so current `-Match` and trailing-wildcard `-BeLike` assertions still hold. A Grep found no `-BeLike` pattern without a trailing `*` in the merge-gate suites.
- Add one guarded dot-source of the shared helper after `:72`.
- Bare commands are not eligible. `:415` and its `-BeExactly` tests stay unchanged.
- Size: the gate gains about 4 code lines, 1 dot-source line, and a header paragraph that replaces the `:36-39` design-decision text. That keeps it under 500 (headroom 28). `Test-EpicMergeGateNoRecordingTarget` (about 20 lines) goes in the resolution file (headroom 257).

## 2. Codex merge gate

`.codex/hooks/enforce-epic-merge-gate.ps1` (385 lines) is standalone. It shares no function with the Claude gate. It dot-sources only its own `.codex/hooks` copies of `hook-dependency-guard.ps1` (`:7`), `hook-command-scanner.ps1` (`:12`), and `hook-command-invocation.ps1` (`:13`). It re-implements the standalone predicate with its own code literals (`:18-21`, `:196-361`).

- Scope filter: `:144-157`, same structure as the Claude gate.
- PR number: `Get-CodexMergeCommandPrNumber` (`:43-76`).
- Checkpoints: read only at the repository root. `:372` computes `$repositoryRoot` from `$PSScriptRoot/../..`; `:373-376` read `artifacts/orchestration/orchestrator-state.json` and `epic-orchestrator-state.json`. There is no parallel checkpoint, no worktree resolution, and no `TARGET_WORKTREE_NOT_DERIVABLE`.
- Decision: `Invoke-CodexEpicMergeDecision` (`:123-194`) takes raw strings. Allow is `$null`. The standalone deny is at `:172-185`; the bare deny is at `:187-193`.
- Insertion point: after `:177` (closing brace of `if ($verdict.Allowed)`), before `:178`.
  - Eligibility: `[string]::IsNullOrWhiteSpace($ChildCheckpointRaw) -and [string]::IsNullOrWhiteSpace($EpicCheckpointRaw)`. Codex has no per-PR resolution, so "no checkpoint records it" is approximated by "no checkpoint is present". This is stricter than the Claude rule and fails closed.
  - Add an optional parameter `[AllowNull()][AllowEmptyString()][string] $RepositoryRoot` to `Invoke-CodexEpicMergeDecision`. Pass `-RepositoryRoot $repositoryRoot` at `:377`.
  - The shared helper denies a blank root before any process seam runs. Existing Codex suites, which never pass `-RepositoryRoot`, therefore never reach gh or git. Their explicit-number deny reasons gain only the appended docs-only suffix, and their assertions use `-Match` (for example `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:117-120`).
- Add a guarded dot-source of `.codex/hooks/hook-docs-only-diff.ps1` after `:13`. Estimated size after the change: about 400 lines.
- Registration is unchanged: `.codex/config.toml:140-144` (timeout 30 s). The Claude registration at `.claude/settings.json:112-115` sets no explicit timeout.

## 3. Create-side logic and the shared helper

### 3.1 Current create-side structure (verified, 265 lines)

- `Invoke-PrAuthorDocsOnlyGitExe` `:36-71`: the seam; capture at `:64`, `$code` at `:65`, catch return at `:68`, success return at `:70`.
- `Test-PrAuthorDocsOnlyCheckpointPresence` `:73-94`.
- `Get-PrAuthorDocsOnlyBaseName` `:96-139`: `-B` check at `:124`; `--base` count at `:127-133`; branch regex `^[A-Za-z0-9][A-Za-z0-9._/-]*$` plus no `..` at `:135`.
- `ConvertFrom-PrAuthorDocsOnlyNameList` `:141-167` (pure); `Get-PrAuthorDocsOnlyPathViolation` `:169-198` (pure; texts `DOCS_ONLY_EXEMPTION_EMPTY_DIFF` and `DOCS_ONLY_EXEMPTION_NON_DOCS_PATH`).
- `Get-PrAuthorDocsOnlyExemption` `:200-265`: rev-parse `:235-248`; diff `:250-258` with argument list at `:251` (`<commit>...HEAD`); classification at `:260`.
- Loaded unguarded by `enforce-pr-author-skill-helpers.ps1:58`. The helpers file is loaded under a guard at `enforce-pr-author-skill.ps1:190`.

The planned #927 CR-1 and CR-2 edits (plan Appendix H, edits H1-H10) are unchanged by this addendum except where 3.3 relocates the H10 guard.

### 3.2 Can the diff classification be shared cleanly?

Yes, provided the shared part is limited to the pure classification and the merge-side orchestration. The create-side seam and its diff argument list stay where they are. Evidence:

- **Pure portion.** NUL-termination check, NUL split, empty check, and `docs/` prefix check need no process, file, or clock. They are identical for create and merge.
- **Create-side seam must stay local.** The DocsOnly suites mock `Invoke-PrAuthorDocsOnlyGitExe` by name (for example `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1:50-51,196,206`). AC-7, AC-8, and AC-9 bind to that function in the docs-only file.
- **Create-side argument list must stay local.** AC-10 pins the `($commit + '...HEAD')` literal and the unmodified row at `Exemption.Tests.ps1:189-197`. A shared argument builder would break AC-10.
- **Merge diff range differs.** The merge side cannot use `...HEAD`. The session root's `HEAD` is not the PR head (1.3), so the range must be `<origin/base commit>...<headRefOid>`.
- **The Codex runtime cannot dot-source `.claude/`.** The codex pack (`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`) ships without the Claude tree. A Grep of `.codex/hooks` finds no `.claude/` load path; the only `../..` reference is to `config/` (`enforce-completion-helpers.ps1:134`).
- **Precedent for shared files.** Byte-identical shared files across both runtimes already exist: `hook-dependency-guard.ps1` ("Byte-identical at .claude/hooks, .codex/hooks, and both bundle mirrors", `.codex/hooks/hook-dependency-guard.ps1:19`) and `feature-folder-resolution.ps1` (`:20`). Four-way identity is asserted by test (`tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1:135`).

### 3.3 Recommended design

**New file `hook-docs-only-diff.ps1`**, byte-identical at four paths:

1. `.claude/hooks/hook-docs-only-diff.ps1` (Write)
2. `.codex/hooks/hook-docs-only-diff.ps1` (cp)
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1` (cp)
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1` (cp)

The file imports nothing and dot-sources nothing. At call time it depends on the command parser functions, which every consumer already loads. Contents:

| Function | Kind | Purpose |
|---|---|---|
| `ConvertFrom-DocsOnlyNameList` | pure | Moved from docs-only `:141-167`; renamed. |
| `Get-DocsOnlyPathViolation` | pure | Moved from docs-only `:169-198`; renamed; reason texts unchanged. |
| `Get-DocsOnlyDiffTextViolation -DiffText -BaseName` | pure | NUL guard (CR-2 text `DOCS_ONLY_EXEMPTION_DIFF_FAILED: git diff against origin/<base> did not return NUL-terminated output.`), then split, then path violation. Returns `$null` or the sub-code text. |
| `Invoke-DocsOnlyGitExe -WorktreeRoot -GitArgs [-GitCommand 'git']` | seam | Never throws (CR-2 pattern). |
| `Invoke-DocsOnlyGhExe -WorkingRoot -GhArgs [-GhCommand 'gh']` | seam | `Push-Location -LiteralPath`, `& $GhCommand @GhArgs 2>$null`, `Pop-Location` in `finally`. Never throws. gh has no `-C`. The name follows the purity hook's `Invoke-GhExe` wrapper convention (`.claude/hooks/check-powershell-test-purity.ps1:104,107`). |
| `Get-DocsOnlyMergeExemption -CommandText -PrNumber -WorktreeRoot` | orchestration | M1-M9 below. Returns `[ordered]@{ Exempt; Reason }`. |

**Merge-side conditions, evaluated in order. The first failure returns `Exempt = $false`:**

- **M1 shape (pure, before any process); fail code `DOCS_ONLY_EXEMPTION_PR_UNRESOLVED`, new.** The command must meet all of these:
  - `PrNumber -gt 0`.
  - `Read-CommandLineSegment` returns exactly one segment, and that segment is not raw-scan (`Test-CommandLineSegmentRawScan` false: not wrapper-led, no live substitution, balanced).
  - `Get-CommandLineStructuralMatch gh pr merge` is non-null.
  - No token matches `^[A-Za-z_][A-Za-z0-9_]*=` (any inline `VAR=` prefix, which covers `GH_REPO=` and `GH_HOST=`).
  - No single-dash token (second character not `-`) contains `R` (ordinal, case-sensitive). This covers `-R`, `-Ro/r`, and `-dR`. gh models `-R` and `--repo` as global options, so `gh -R o/r pr merge` is a structural match whose tokens include them (`hook-command-invocation.ps1:47-51`).
  - No token equals `--repo` or starts with `--repo=`.
  - No `--auto` token. Auto-merge completes asynchronously at a later head.

  Rationale for the single-segment rule: a leading `cd <other-repo> &&` makes gh act on a different repository than the one evaluated, and a second `gh pr merge` in the same command would not be checked.
- **M2 root (no process); fail code `PR_UNRESOLVED`.** `WorktreeRoot` must be non-blank and an existing directory.
- **M3 PR lookup; fail code `PR_UNRESOLVED`.** `Invoke-DocsOnlyGhExe -WorkingRoot <root> -GhArgs @('pr','view',"$PrNumber",'--json','baseRefName,headRefOid')`. Requirements: exit 0; JSON parses; `baseRefName` passes the create-side branch rule (`docs-only.ps1:135`), failing with `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED`; `headRefOid` matches `^[0-9a-f]{40}([0-9a-f]{24})?$`. When the command carries `--match-head-commit <oid>`, it must equal `headRefOid`.
- **M4; fail code `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED`.** `git -C <root> rev-parse --verify --quiet refs/remotes/origin/<base>^{commit}` must print a hex commit.
- **M5; fail code `DOCS_ONLY_EXEMPTION_DIFF_FAILED`.** `git -C <root> rev-parse --verify --quiet <headRefOid>^{commit}` must print `headRefOid`. The message names the missing commit and the fetch the operator can run.
- **M6; fail code `DIFF_FAILED`.** `git -C <root> diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <baseCommit>...<headRefOid>` must exit 0.
- **M7-M9.** `Get-DocsOnlyDiffTextViolation` (NUL guard, then `EMPTY_DIFF` or `NON_DOCS_PATH`).

**Base and head resolution.**

- `gh pr merge` has no `--base` flag, so the base can only come from GitHub. A gh call (M3) is required.
- The session root's `HEAD` is not the PR head (1.3), so the diff names `headRefOid` explicitly.

**Fetch policy.** The hook does not fetch. A missing `origin/<base>` or a head commit that is not present locally denies (fail closed). Reasons:

- A PreToolUse hook should not mutate refs or depend on network time beyond the one gh call (Codex timeout 30 s, `.codex/config.toml:144`).
- A stale local `origin/<base>` cannot produce a false allow. An older base gives an older or equal merge base, so the three-dot listing is a superset of the PR's own changes. This is reasoned from three-dot semantics and was not tested here.

**Consumers.**

- **Claude merge gate:** guarded dot-source in the gate (1.5).
- **Codex merge gate:** guarded dot-source of its own `.codex/hooks` copy (2).
- **pr-author:** `enforce-pr-author-skill.docs-only.ps1` dot-sources `hook-docs-only-diff.ps1` (unguarded) directly after `param()`. Its local `ConvertFrom-PrAuthorDocsOnlyNameList` and `Get-PrAuthorDocsOnlyPathViolation` are deleted, and H10's guard plus `:260` become one call to `Get-DocsOnlyDiffTextViolation`. The unguarded nested dot-source is covered by the guarded edge at `enforce-pr-author-skill.ps1:190`. This matches the existing pattern at `helpers.ps1:56,58`, and the structural guard test counts an edge as covered when a shallower edge is guarded (`tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1:255-257`). `enforce-pr-author-skill-helpers.ps1` is not edited.

**Required registrations and contract tests for the new file.**

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (hooks block `:25-80`). Required by `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:139` (enumerates every bundled hook, `:86-91`) and by `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (on-disk versus manifest union, `:229-234`).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (hooks block `:29-69`). Required by `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py:218`; the hook exception set is empty (`:92`).
- Byte parity: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-229`.
- Dependency-guard structure: `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (S2 single-statement guard per direct edge; S4 transitive coverage). Also `hook-import-failure-exemptions.Guard.Tests.ps1`: G2 forbids a new scoped import-failure handler, and the helper has none.
- Coverage population: `config/poshqc-coverage.json:4,6` includes both `.claude/hooks` and `.codex/hooks`, so both canonical copies enter the denominator and both need driving tests.

### 3.4 Rejected alternatives

- **Merge gate dot-sources `enforce-pr-author-skill.docs-only.ps1`.** Not available to the Codex runtime. It couples the merge gate to pr-author naming and the create-only E1 rule.
- **Full refactor that moves the create-side seam and argument list into the shared file.** Breaks AC-7, AC-8, AC-9 (seam location) and AC-10 (pinned literal), and requires renaming many mock call sites in the DocsOnly suites.
- **`gh pr diff --name-only` or `gh pr view --json files`.** These need no local refs, but they report only the new path of a rename. A rename from outside `docs/` into `docs/` would pass, which contradicts the `--no-renames` requirement.
- **Requiring `--match-head-commit` as an eligibility precondition.** This binds the merge to the diffed commit and keeps existing Claude suites off the gh path. It adds a condition the stated requirement does not include. Retained instead as an optional equality check in M3, and listed as operator decision OD-2.
- **Docs-only eligibility for a bare `gh pr merge --merge`.** gh would resolve the PR from the current branch of the cwd. Excluding it keeps PR identity explicit and leaves `:415` and its exact-text tests unchanged.

### 3.5 Residual limits to document in the hook headers

- An ambient `GH_REPO` or `GH_HOST` exported earlier or inherited is not visible in the command text (same limit as create-side CR-1).
- The window between the gh lookup and the merge allows a new push to change the head. This is closed only when the operator passes `--match-head-commit`.
- The control is policy-level, not cryptographic, as stated at `enforce-epic-merge-gate.ps1:36-39,54-58`. The design-decision paragraph at `:36-39` must be revised because the gate will now call `gh pr view` on this one branch.

## 4. Existing test suites and placement of new rows

Line counts (verified):

| Suite | Lines |
|---|---|
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 465 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` | 181 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1` | 203 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` | 309 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` | 255 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 187 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1` | 43 |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` | 205 |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1` | 172 |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 117 |

Other suites that drive a merge-gate decision function:

- `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1:49,151`
- `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1:90`
- `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1:21,385-404`
- `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1:162-169` (process run with a simulated load failure; denies before the new branch)

**Current seams.** Checkpoint read seams are `Get-ChildOrchestratorCheckpointContent`, `Get-EpicOrchestratorCheckpointContent`, and `Get-ParallelOrchestratorCheckpointContent` (`resolution.ps1:38-96`). Module text seams are mocked with `-ModuleName` (for example `WorktreeResolution.Tests.ps1:31-36`). Some suites mock the target resolvers `Resolve-EpicMergeGateRunTarget` and `Resolve-EpicMergeGateItemTarget` (for example `Authorization.Tests.ps1:84-85`, default `SessionRoot`). There is no gh or git seam today. No suite mocks `Get-EpicMergeGateSessionWorktreeRoot` (Grep: no match), so the real session root is used.

**Consequence for existing Claude suites.** Any row with an explicit PR number whose three targets resolve `NoTarget` will reach `Get-DocsOnlyMergeExemption`, which passes M1 and M2 against the real session root and would invoke real gh. Example: `WorktreeResolution.Tests.ps1:188` (M7). Recommended rule: every suite that dot-sources `.claude/hooks/enforce-epic-merge-gate.ps1` adds two lines to its top-level `BeforeAll`:

- `Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }`
- `Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }`

Their reasons gain only the appended suffix. `enforce-epic-merge-gate.Tests.ps1` has 35 lines of headroom, which is enough for two lines. Existing Codex suites need no edit (section 2, blank-root rule).

**New suites, each under 500 lines:**

1. `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1`: pure-function rows, including the relocated `Get-PrAuthorDocsOnlyPathViolation` and `ConvertFrom-PrAuthorDocsOnlyNameList` contexts (`enforce-pr-author-skill.DocsOnly.Tests.ps1:35-~125`) renamed to the shared names; `Get-DocsOnlyDiffTextViolation` NUL, empty, and non-docs rows; seam-body rows for both seams through `-GitCommand` and `-GhCommand` test-local functions (the plan's T2 pattern, without `Mock git` or `Mock gh`); four-way byte-identity row (precedent `hook-dependency-guard.Tests.ps1:135`).
2. `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1`: M1-M9 deny rows and the allow row, with both seams mocked. Include zero-invocation assertions for the M1 and M2 denials: `-R`, `-dR`, `--repo=`, `GH_REPO=`, `GH_HOST=`, `cd x && gh pr merge`, two merges in one command, `--auto`, a `bash -c` wrapper, and a blank root. Include an argument-list assertion for the M6 range `<base>...<oid>` with `--no-renames` and `-z`, and a `--match-head-commit` mismatch row.
3. `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`: end-to-end through `Invoke-EpicMergeGateDecision`:
   - allow when all three targets are `NoTarget` and the diff is docs-only;
   - deny with `TARGET_WORKTREE_NOT_DERIVABLE`, `STANDALONE_MERGE_AUTHORIZATION_ABSENT`, and the docs-only sub-code for a non-docs path;
   - no seam call for `Ambiguous` or `SessionRoot` targets, and for a bare command (whose `-BeExactly` text is unchanged).

   The suite must follow the epic-state isolation pattern: baseline mocks plus `It 'baseline mock interception probe'`, as in `enforce-epic-merge-gate.Coverage.Tests.ps1:16-23`.
4. `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`: drives the `.codex` copy so that copy is covered.
5. `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1`: `Invoke-CodexEpicMergeDecision -RepositoryRoot <synthetic>` allow and deny rows; a present-checkpoint row with no seam call; a blank-root row.

Purity constraints carry over from plan rule 11: no `Mock git` or `Mock gh` (`check-powershell-test-purity.ps1:103-107`), no `Start-Process`, no temporary files. Rows that run the seam bodies use test-local functions passed by name.

This addendum proposes no numeric acceptance criterion. Any count of affected suites or rows that the spec author wants to assert requires the `## Numeric Derivation Evidence` procedure first.

## 5. Spec and plan constraints that must be relaxed

**Spec `spec.md`:**

- **AC-22 (`:213`).** Allow these paths:
  - `.codex/hooks/enforce-epic-merge-gate.ps1`
  - `.codex/hooks/hook-docs-only-diff.ps1`
  - both `pack-manifests/core.json` files: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`. The spec's unqualified `pack-manifests/core.json` matches both.

  The prohibitions on `hook-command-invocation*.ps1` and `enforce-pr-author-skill-helpers.ps1` can remain; the recommended design edits neither.
- **Non-goals `:51`.** Remove "`pack-manifests/core.json`, or any `.codex/` content" and "No `.codex` copy of the hook exists" (true for pr-author, false for the merge gate).
- **`:164`.** "No configuration, schema, or manifest change" becomes "manifest path additions only".
- **Implementation strategy (`:120-130`) and Data/API (`:161-164`).** Add:
  - the three Claude merge-gate files (gate, resolution; the authorization file only if guidance text changes);
  - the Codex gate;
  - the shared helper at its four paths;
  - both manifests;
  - the merge-gate and Codex suites listed in section 4;
  - the new reason code `DOCS_ONLY_EXEMPTION_PR_UNRESOLVED`. The "No new reason code" non-goal at `:50` stays true for the create side only.
- **Boundaries (`:107-112`).** "No new code path returns `Exempt = $true`" must be scoped to the create side. The merge branch is a new allow path by requirement.

**Plan `plan.2026-10-15T07-41.md`:**

- **Rule 10 (`:32`).** The new scope writes more than three production PowerShell files with Write or Edit:
  - `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`
  - `.claude/hooks/enforce-pr-author-skill.ps1`
  - `.claude/hooks/hook-docs-only-diff.ps1`
  - `.claude/hooks/enforce-epic-merge-gate.ps1`
  - `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`
  - `.codex/hooks/enforce-epic-merge-gate.ps1`

  `.claude/hooks/enforce-powershell-batch-budget.ps1:10-23` denies the fourth distinct production path in direct mode unless the checkpoint route is `large`, `remediation`, or `preparation` and the run is not terminal. The item must run on such a route, or the rule must be rewritten accordingly.
- **Rule 13 and section 9 `## WRITES` (`:348-389`), and [P4-T9] (`:151`).** Extend to the new write set. Section 9's "Never written" list must drop `.codex/` and `pack-manifests/core.json`.
- **Decision D4 and [P4-T8] (`:70`, `:150`).** "No existing line of the three DocsOnly suites is edited" conflicts with relocating the two pure-helper contexts out of `enforce-pr-author-skill.DocsOnly.Tests.ps1`. Revise D4 to allow that relocation only.
- **[P2-T6] expected count `285` (`:109`), [P4-T5] (`:147`), AC-9 line set `75,76,79,81` (`:152`, `:213`), and Appendix H anchors.** The new dot-source line after `param()` shifts the seam statements, and the function removals change the total. Re-derive these after the refactor.

## 6. #901 folder location (archive move)

The `F901` constant is set at plan `:13`. The literal active path recurs in [P3-T1] `:118`, [P3-T3]-[P3-T18] `:120-135` (every grep acceptance command), [P3-T19] `:136`, [P3-T20] `:137`, and section 9 `:370-383`. The spec repeats it at `:21,28,74,103,129,204,207-208`. Today only `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/` exists (Glob over `docs/features/*/2026-10-11-...-901/issue.md` returns only the active path).

Recommendations:

- Add a Phase 0 locator task. It records which of `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` and `docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901` exists. Either is accepted for locating and reading. If both exist, or neither, stop as BLOCKED.
- Keep every #901 edit target at the active path, as directed. If the locator finds only the archive path (main moved it and was merged into this branch), Phase 3 stops as BLOCKED and does not edit the archive copy.
- The pathspec in [P3-T1] (`git show --name-status ff1b7cbd4 70e58ca84 -- docs/features/active/...`) names where the files were at those historical commits. It must stay the active path regardless of the locator result.

## 7. Re-verification of plan citations after main advanced to `adb9aa5f`

All citations the plan relies on were re-read. **None moved.**

| Plan citation | Current tree | Status |
|---|---|---|
| docs-only hook 265 lines ([P0-T4]) | 265 | unchanged |
| `enforce-pr-author-skill.ps1` 355 lines; Docs-only block `:26-41` (Appendix M) | 355; `:26-41` | unchanged |
| DocsOnly suites 218 / 209 / 149 | 218 / 209 / 149 | unchanged |
| AC-9 statements `:64,65,68,70` | capture `:64`, `$code` `:65`, catch return `:68`, success return `:70` | unchanged |
| H1 `:15-16`, H2 `:18`, H3 anchor `:24`, H4 `:47-48`, H5 `:56`, H6 `:64`, H7 `:101-104`, H8 `:124-126`, H9 `:232`, H10 `:260` | same lines and text | unchanged |
| D1: `hook-command-payload.ps1` line 188 | `:188` VAR=value skip | unchanged |
| D1: `hook-command-invocation.ps1` lines 47-51 | gh `WithArgument @('-R','--repo')` at `:47-51` | unchanged |
| D3: `scripts/dev-tools/run-actionlint.ps1` lines 99-111 | `Invoke-ActionlintExe` at `:99`, `-CommandPath` `:103`, call `:109` | unchanged |
| T1 anchor `It 'returns null for gh pr edit'` | DocsOnly.Tests `:161` | unchanged |
| T2 final five lines | DocsOnly.Tests `:214-218` | unchanged |
| T3 final four lines | Exemption.Tests `:206-209` | unchanged |
| T4 final four lines | Decision.Tests `:146-149` | unchanged |
| Rows `denies an empty diff`, `runs the diff with -z, ...` | Exemption.Tests `:155`, `:189` | unchanged |
| P4b: `.github/workflows/_poshqc.yml` lines 41-42 | `Import-Module` and `Invoke-PoshQCTest` at `:41-42` | unchanged |

## 8. Operator decisions to record in the revised spec

- **OD-1.** Codex eligibility uses "no checkpoint present at the repository root" (recommended, fail closed). The alternative is a per-PR record scan of the present checkpoints.
- **OD-2.** `--match-head-commit`: optional equality check (recommended), or required for docs-only eligibility (closes the head-race window but changes the operator command shape).
- **OD-3.** Whether `.claude/rules/orchestrator-state.md` (Standalone-Merge-Authorization section, `:234`) gains a sentence describing the docs-only merge route. Plan rule 13 currently forbids edits under `.claude/rules/`. The recommendation is hook-header documentation only.
