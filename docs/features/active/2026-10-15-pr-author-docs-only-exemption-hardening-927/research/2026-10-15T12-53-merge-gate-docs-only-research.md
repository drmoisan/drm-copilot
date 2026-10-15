# Research Addendum: docs-only exemption for the epic merge gate (Issue #927)

- Timestamp: 2026-10-15T12-53 (UTC, read from a network clock, `timeapi.io`; no shell was available to read the host clock)
- Branch: `bug/pr-author-docs-only-exemption-hardening-rev-927`
- Base research (unchanged): `research/research.2026-10-15T11-52.md`
- Related artifacts read: `spec.md`, `plan.2026-10-15T07-41.md` (lines 1-115), `issue.md`
- Filename note: the orchestrator requested `research-addendum-merge-gate.2026-10-15T12-53.md`. The task-researcher stop hook requires the `<timestamp>-<short-name>-research.md` convention, so this file is the authoritative addendum and the requested path holds a pointer to it.
- Method limitation: file read, search, and web fetch tools only. No `git`, `gh`, `pwsh`, or Pester command ran. Facts are marked verified only where a file read or a fetched page established them.

## 0. New requirement (operator priority)

The #901 exemption covers `gh pr create` only. The merge gate denies a docs-only PR merge when no checkpoint records the PR, with `TARGET_WORKTREE_NOT_DERIVABLE` and `STANDALONE_MERGE_AUTHORIZATION_ABSENT`. Required: the merge gate allows a merge invocation when the PR diff against its base lists only `docs/**` paths and no checkpoint records the PR, with no exception or authorization record. Fail-closed rules match the create side: exactly one resolvable base, non-empty diff, every path under `docs/`, `--no-renames`, and any lookup or diff failure denies.

## 1. Merge-gate decision flow (verified by Read)

### 1.1 Claude: `.claude/hooks/enforce-epic-merge-gate.ps1` (472 lines; 28 lines of headroom)

| Lines | Step |
|---|---|
| 36-39 | Header design decision: the gate trusts the on-disk checkpoint and does not call `gh pr view`. The new exemption is the first live `gh` call in any hook (Grep for `& gh` under `.claude/` finds none). |
| 62-72 | Guarded dot-sources: dependency guard, `HookPayload.psm1`, `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `enforce-epic-merge-gate-authorization.ps1`, `enforce-epic-merge-gate-resolution.ps1`. |
| 99-143 | `Get-EpicMergeGateCommandPrNumber`: first all-digit operand of the structural `gh pr merge` segment, else the `--merge` flag value if all digits, else `$null`. A URL or branch selector yields `$null`. |
| 343-356 | Scope: `Test-CommandLineInvocation` for `gh pr merge` plus `Test-CommandLineFlag --merge`, with a raw-scan fallback for wrapper segments. Out of scope returns allow. |
| 358-359 | PR number; session root via `Get-EpicMergeGateSessionWorktreeRoot` (`resolution.ps1` 98-110, `Get-Location`). |
| 365-375 | Item target (`Resolve-EpicMergeGateItemTarget`, `resolution.ps1` 133-149); child checkpoint read only when the target is `SessionRoot` or `OtherWorktree`; branch 1 allow. |
| 379-398 | Epic and parallel run targets (`Resolve-EpicMergeGateRunTarget`, `resolution.ps1` 112-131); branches 2 and 3. |
| 402-412 | Branch 4 (explicit number only): standalone authorization over the three parsed checkpoints. Deny at 412: `EPIC_MERGE_GATE_BLOCKED: <unresolved>; <standalone code>: <message>`. |
| 410-411 | `Get-EpicMergeGateUnresolvedReason` (`resolution.ps1` 205-243) returns `<code>: <item>; <epic>; <parallel>` only when all three targets are `NoTarget` or `Ambiguous`; the code is `TARGET_WORKTREE_NOT_DERIVABLE` (`.claude/lib/worktree-resolution/WorktreeResolution.psm1` line 59) unless one target is `Ambiguous`. |
| 412 / `authorization.ps1` 46, 415-417 | `STANDALONE_MERGE_AUTHORIZATION_ABSENT` when no checkpoint carries the key. With all three targets `NoTarget`, every checkpoint is `$null` (lines 371, 390, 395), so the standalone result is always ABSENT. This is the PR #939 denial. |
| 415 | Bare command (no number) final deny. |
| 418-454 | `Invoke-EpicMergeGateEntryPoint`; the decision call is line 450. |

Insertion point: inside the `if ($null -ne $commandPrNumber)` block, after `if ($standalone.Allowed)` (lines 405-407) and before line 410. Guard: all three targets have `Status -eq 'NoTarget'` (statuses verified in `WorktreeTargetResolution.psm1` 31-34). This applies the exemption only when no live worktree checkpoint records the PR. Any `SessionRoot`, `OtherWorktree`, or `Ambiguous` target means a checkpoint records the number. In that case the recorded path governs and the exemption is never evaluated, so branches 1-4 cannot be weakened. A bare command never reaches the block.

### 1.2 Codex: `.codex/hooks/enforce-epic-merge-gate.ps1` (385 lines; 115 lines of headroom)

The file contains its logic inline and has no worktree resolution. It dot-sources only `hook-dependency-guard.ps1`, `hook-command-scanner.ps1`, and `hook-command-invocation.ps1` (lines 7-13).

| Lines | Step |
|---|---|
| 43-76 | `Get-CodexMergeCommandPrNumber` (same rules as Claude). |
| 123-157 | `Invoke-CodexEpicMergeDecision -PayloadRaw -ChildCheckpointRaw -EpicCheckpointRaw`; same scope test. |
| 159-167 | Child (`Test-CodexChildMergeReady`) and epic (`Test-CodexEpicMergeReady`) branches. There is no parallel branch. |
| 172-185 | Standalone branch; the deny at 178-184 is `EPIC_MERGE_GATE_BLOCKED: <code>: <message>`. Codex has no `TARGET_WORKTREE_NOT_DERIVABLE` prefix. |
| 187-193 | Bare-command deny. |
| 370-385 | Entry point: `$repositoryRoot` = two `Split-Path` levels above `$PSScriptRoot` (372). It reads the two checkpoints at fixed paths (373-376), calls the decision (377), and exits 2 on throw (382-384). |

Insertion point: after `if ($verdict.Allowed)` (175-177) and before the deny at 178. Codex reads repository-root checkpoints whether or not they record the PR, so "no checkpoint records the PR" needs its own predicate (section 6, M0).

## 2. PR identity, base, head, and range

### 2.1 gh semantics (verified from `cli.github.com/manual/gh_pr_merge` and `gh_pr_view`)

- `gh pr merge [<number> | <url> | <branch>]`. With no argument, the PR of the current branch is selected. Flags: `--admin`, `-A`, `--auto`, `-b`, `-F`, `-d`, `--disable-auto`, `--match-head-commit <SHA>` ("Commit SHA that the pull request head must match to allow merge"), `-m/--merge`, `-r/--rebase`, `-s/--squash`, `-t`. Inherited: `-R, --repo`. `--admin` bypasses requirements and the merge queue.
- `gh pr view --json` fields include `number`, `state`, `url`, `baseRefName`, `baseRefOid`, `headRefName`, `headRefOid`, `isCrossRepository`, and `files`.
- GitHub GraphQL `PullRequestChangedFile` has `path`, `changeType`, `additions`, `deletions`, and `viewerViewedState`. It has no previous path (verified, `docs.github.com/en/graphql/reference/pulls`). An API file listing cannot satisfy `--no-renames`, because a rename into `docs/` would report only the new path. The diff must be computed with local git.

### 2.2 PR selection

The exemption requires an explicit all-digit PR number. This matches branch 3 (line 264) and branch 4 (line 402). A URL, branch, or bare selector denies, because the hook could resolve a different PR than `gh pr merge` would (bare form: current branch of the Bash cwd). The hook runs `gh pr view <N> --json number,state,url,baseRefName,baseRefOid,headRefOid` and requires:

- the returned `number` equals N;
- `state` is `OPEN`;
- `headRefOid` and `baseRefOid` are 40- or 64-char lowercase hex;
- `baseRefName` passes the create-side spelling rule (`docs-only.ps1` line 135);
- `url` names the same `owner/repo` as `git remote get-url origin`. This cross-check ties gh's repository choice (default repo, multiple remotes) to the `origin` refs used for the diff. A parse failure or a non-`github.com` host denies.

### 2.3 Base and freshness

- Base commit: `git -C <root> rev-parse --verify --quiet refs/remotes/origin/<baseRefName>^{commit}`, the same form as create-side E4 (`docs-only.ps1` 235-248). A single `baseRefName` from one API record gives exactly one base by construction.
- Freshness: `git -C <root> merge-base --is-ancestor <baseRefOid> <baseCommit>` must exit 0. Exit 1 (stale local base) and exit 128 (object absent) deny, and the message names `git fetch origin <base>`. Rationale: a local `origin/<base>` that is behind GitHub can hide a non-docs change. The case is a head that merged a newer base and then reverted a non-docs path, so the stale three-dot diff shows no change to that path. GitHub documents `baseRefOid` only as "the oid of the base ref associated with the pull request". Whether it tracks the live tip is not documented. The ancestry test is fail-closed in both cases and causes no false denial when the local ref is current.
- The hook does not fetch. Fetch writes refs and objects, takes locks shared by concurrent worktrees, adds network latency, and increases the fail-open timeout exposure (section 7). Denials tell the caller which fetch to run.

### 2.4 Head and range

- Head: `headRefOid` from the same `gh pr view` record. Its object must exist locally (`rev-parse --verify --quiet <oid>^{commit}`); otherwise deny with `git fetch origin pull/<N>/head`.
- Range: `<baseCommit>...<headRefOid>`, with the argument list otherwise identical to `docs-only.ps1` line 251.
- Why not `...HEAD` (CR-3/D5 keeps it for create): in a merge, the hook cwd is the session worktree. Its `HEAD` is typically `main` or an unrelated branch, not the PR head. On `main` the diff would be empty (a useless deny). On a PR worktree with unpushed commits it would describe a tree GitHub does not merge.
- Why not `origin/<headRefName>`: a name is not an immutable id; the tracking ref can be stale or absent (fork heads).
- `headRefOid` is the commit GitHub records for the PR, and `--match-head-commit` (section 7) binds the merge to it.

### 2.5 Repository overrides (CR-1 analogue)

Deny when any token of the `gh pr merge` segment is:

- a single-dash cluster containing `R` (or `B`; the create-side predicate is reused unchanged, and `-B` on `gh pr merge` is an unknown flag, so denying it costs nothing);
- `--repo` or `--repo=...`;
- an inline `GH_REPO=` or `GH_HOST=` prefix.

The hook's own `gh pr view` never passes `-R`. Ambient `GH_REPO` stays a documented residual. It is partly mitigated by the `url`-versus-`origin` cross-check, because both the hook's gh and the merge inherit the same session environment.

### 2.6 Existing seams

- No hook has a gh seam. The purity hook names `Invoke-GhExe` as the expected wrapper to mock and denies `Mock gh` / `Mock 'gh'` (`.claude/hooks/check-powershell-test-purity.ps1` lines 15, 104, 107).
- Script precedent: `scripts/dev-tools/Invoke-ReleaseVerification.ps1` lines 56-71 (`Invoke-GhExe`).
- The only git seam in hooks is `Invoke-PrAuthorDocsOnlyGitExe` (`docs-only.ps1` 36-71).

## 3. Reuse and extraction

### 3.1 How Codex hooks locate shared code (verified)

No `.codex/hooks` file references `.claude/` code or `../lib` (Grep of `.codex/hooks` for `Join-Path $PSScriptRoot` and `.claude`). Shared logic is kept as byte-identical copies in both `hooks` directories:

- `feature-folder-resolution.ps1` header lines 20-21 state this. `tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1` lines 277-285 assert equal SHA256.
- `hook-command-*.ps1` follow the same pattern. `tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1` lines 20-24 and 62-65 run every row against both copies through `-ForEach @{Runtime; HookRoot}`.

A shared merge-gate helper must therefore be a byte-identical pair, not a `.claude/lib` module.

### 3.2 Recommendation: one shared, byte-identical helper

Create `docs-only-exemption.ps1` in both `.claude/hooks/` and `.codex/hooks/`, with the same content in each. It depends only on functions both runtimes already load: `Read-CommandLineSegment`, `Get-CommandLineInvocation`, `Get-CommandLineStructuralMatch`, `Get-CommandLineFlagValue`. Contents:

| Function | Kind | Purpose |
|---|---|---|
| `Test-DocsOnlyOverrideToken -Token` | pure | CR-1 rule: single-dash cluster containing `B` or `R` (ordinal), `--repo`, `--repo=`, `GH_REPO=`, `GH_HOST=` |
| `Test-DocsOnlyBranchSpelling -Name` | pure | `^[A-Za-z0-9][A-Za-z0-9._/-]*$`, no `..` |
| `Test-DocsOnlyObjectId -Text` | pure | 40- or 64-char lowercase hex |
| `Get-DocsOnlyDiffArgument -Range` | pure | the fixed list `diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <range>` |
| `Get-DocsOnlyListingViolation -Output` | pure | CR-2 NUL guard (DIFF_FAILED), NUL split, EMPTY_DIFF, NON_DOCS_PATH; returns `$null` or the reason |
| `Invoke-DocsOnlyNativeCommand -CommandName -Arguments` | seam | never throws; returns `ExitCode` and `Output`; stderr discarded. Tests pass a test-local function name as `-CommandName` (precedent `run-actionlint.ps1` 99-111) |
| `ConvertFrom-DocsOnlyPullRequestJson -Text -PrNumber` | pure | section 2.2 field checks |
| `Get-DocsOnlyMergeExemption -CommandText -PrNumber -WorktreeRoot` | decider | conditions M1-M10 (section 6); returns `[ordered]@{ Exempt; Reason }` |

Estimated size is 330-370 lines, under 500.

### 3.3 Consumers

- Claude merge gate: one guarded dot-source after line 72: `try { . (Join-Path $PSScriptRoot 'docs-only-exemption.ps1') } catch { Add-HookDependencyFailure ... }`.
- Codex merge gate: the same after line 13.
- pr-author: `enforce-pr-author-skill.docs-only.ps1` dot-sources the shared file at its top. It then delegates the CR-1 token test (`Test-DocsOnlyOverrideToken` inside `Get-PrAuthorDocsOnlyBaseName`), the CR-2 guard and listing classification (`Get-DocsOnlyListingViolation`, replacing `ConvertFrom-PrAuthorDocsOnlyNameList` and `Get-PrAuthorDocsOnlyPathViolation`), and the diff argument list (`Get-DocsOnlyDiffArgument -Range ($commit + '...HEAD')`; D5 is preserved).
- pr-author keeps its own seam, `Invoke-PrAuthorDocsOnlyGitExe` with the planned `-GitCommand` parameter. Its name is mocked by all three DocsOnly suites, and spec AC-7 and AC-9 pin its statements. Keeping it avoids churn on a seam that is already specified.

Why this is clean: every shared function is pure or a single never-throwing seam, and the per-runtime differences stay in each gate. Those differences are how "no checkpoint records the PR" is decided and which root is passed. One implementation of the CR-1 predicate, the CR-2 guard, and the `--no-renames` argument list prevents the create and merge rules from drifting.

### 3.4 Interaction with the existing plan and spec (conflicts the planner must resolve)

| Item | Conflict | Required revision |
|---|---|---|
| Spec Non-goals and AC-22 | "No change to ... any `.codex/` content"; AC-22 forbids `.codex/` paths | Remove the `.codex/` exclusion; keep the parser and helpers-file exclusions |
| Spec "No new reason code" | Merge needs `DOCS_ONLY_EXEMPTION_COMMAND_SHAPE`, `DOCS_ONLY_EXEMPTION_PR_LOOKUP_FAILED`, `DOCS_ONLY_EXEMPTION_HEAD_UNRESOLVED` | Scope the statement to the create path |
| Plan H8 and H10 | Implement the B/R rule and NUL guard inline in `docs-only.ps1` | Implement them once in the shared file; `docs-only.ps1` calls them |
| Plan D4 | No existing DocsOnly test line edited | The `ConvertFrom-PrAuthorDocsOnlyNameList` and `Get-PrAuthorDocsOnlyPathViolation` Contexts in `DocsOnly.Tests.ps1` move to the shared suite |
| Spec AC-10 | Pins the literal `-GitArgs` array in the decider | Restate as "the diff runs with exactly these arguments", pinned by the existing mock-filter row (behavior unchanged) |
| Plan rule 10 (two production files) | At least 5 production `.ps1` files are written with Write/Edit (section 8) | `.claude/hooks/enforce-powershell-batch-budget.ps1` (lines 10-23) denies the fourth distinct path unless the item checkpoint route is `large`, `remediation`, or `preparation` and non-terminal. The planner must confirm the route or sequence the work. Mirrors and the Codex copy are written with `cp`, which the `Write|Edit` matcher does not see |
| D5 / CR-3 | none | Create keeps `...HEAD`; merge uses `<base>...<headRefOid>` (section 2.4) |

Rejected alternative: per-runtime private copies of the merge logic in each gate. This duplicates about 200 lines across two runtimes plus the create side, the risk the byte-identity convention exists to prevent. The Claude gate also lacks the headroom (28 lines). A second rejected option is extracting only the merge decider and leaving pr-author's pure functions in place. That keeps two implementations of the CR-1 and CR-2 rules.

## 4. Test surfaces

### 4.1 Existing suites (line counts by Grep count of `^`)

| Suite | Lines | Seam style |
|---|---|---|
| `claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 465 | dot-sources the gate; `Mock Resolve-EpicMergeGateRunTarget/ItemTarget` default `SessionRoot` (lines 18-19); module-scoped resolver mocks |
| `claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` | 255 | `Set-MergeReadSeam` and `Set-MergeRunTopology` closures (57-82); item target default `NoTarget` (84-85) |
| `claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` | 309 | same family |
| `claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 187 | same family |
| `claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` | 181 | same family |
| `claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1` | 203 | pure predicates |
| `claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1` | 43 | |
| `codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` | 205 | decision called with raw checkpoint strings |
| `codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1` | 172 | raw strings; in-process entry point via `Console.SetIn` (48-76) |
| `codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 117 | raw strings |

`enforce-epic-merge-gate.Tests.ps1` (465) has no room. All new rows go in new suites.

### 4.2 Keeping existing rows deterministic: opt-in evaluation

Many existing rows reach the insertion point. Examples: WorktreeResolution M5 and M7 (lines 150-200) use an explicit number with all targets `NoTarget`. Unconditional evaluation would make those rows start a real `gh` process. Recommended:

- Claude: add `[switch] $EvaluateDocsOnlyExemption` to `Invoke-EpicMergeGateDecision`. Only `Invoke-EpicMergeGateEntryPoint` (line 450) passes it.
- Codex: add `[AllowNull()][string] $DocsOnlyWorktreeRoot` to `Invoke-CodexEpicMergeDecision`. Only the entry point passes `$repositoryRoot` (line 377). Empty means not evaluated.

Every existing entry-point row returns before the insertion point:

- `enforce-epic-merge-gate.Tests.ps1` 391-463: payload anomalies, or the default `SessionRoot` targets;
- WorktreeResolution M10 (236-254): dependency failure;
- `hook-dependency-failure.SpecialCases.Tests.ps1` 162-169: load failure;
- Codex decision-surface 153-170: non-Bash or malformed stdin.

No other suite contains `gh pr merge` in an entry-point context (Grep of `hook-dependency-failure*` and `codex-bundle-hook-probe.Tests.ps1`). Expected result: no existing suite needs editing. This is likely but unconfirmed until the executor's expect-pass run. A new wiring row must prove the entry point passes the switch or parameter.

### 4.3 New suites and required rows

The new suites must keep the epic-state isolation structure: the read-seam mocks and the `It 'baseline mock interception probe'` row, copied from WorktreeResolution lines 26-90. The structural guard `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` discovers suites by directory enumeration (`enforce-gate-suites.EpicStateIsolation.Tests.ps1` lines 15-17). Synthetic roots use `/synthetic-worktrees/...` (Linux CI safe).

1. `tests/scripts/claude-hooks/docs-only-exemption.Tests.ps1` (new, about 300 lines). Every row runs against both copies through `-ForEach @{Runtime='claude';HookRoot='.claude/hooks'}, @{Runtime='codex';HookRoot='.codex/hooks'}`. Rows:
   - SHA256 equality of the two copies;
   - override-token accept and reject tables;
   - branch spelling and object-id tables;
   - diff argument list;
   - listing violations: NUL missing, empty, non-docs, rename pair `.claude/x.ps1<NUL>docs/x.ps1<NUL>` reports the `.claude` path, docs-only accept;
   - native seam via `-CommandName <test-local function>` and `-Arguments`: success, multi-line join, non-zero exit, throw, with `$global:LASTEXITCODE` reset per test;
   - PR JSON parser: valid, malformed, number mismatch, non-OPEN, bad oid.

   Both copies sit under coverage roots (`config/poshqc-coverage.json`: `.claude/hooks`, `.codex/hooks`), so both need 85% line coverage.
2. `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` (new, about 350 lines). It drives `Invoke-EpicMergeGateDecision -EvaluateDocsOnlyExemption` with targets mocked `NoTarget` and `Mock Invoke-DocsOnlyNativeCommand` filtered on `$CommandName` and `$Arguments[0..1]`. Rows:
   - allow (gh JSON valid; rev-parse, is-ancestor, and head resolve; diff `docs/a.md<NUL>`);
   - deny, no single base: `baseRefName` empty or invalid, `origin/<base>` unresolved, stale base (is-ancestor exit 1);
   - deny, empty diff;
   - deny, non-docs path;
   - deny, rename-related (`--no-renames` listing with old `.claude/...` path, plus an argument-pin row asserting `--no-renames`, `-z`, and `<base>...<headOid>`);
   - deny, diff failure (exit 128, and output without NUL);
   - deny, gh lookup failure (exit 1, throw, malformed JSON, number mismatch, state `MERGED`, url/origin mismatch);
   - deny, repository override (`-R o/r`, `--repo=o/r`, `GH_REPO=o/r` prefix), each with zero seam invocations;
   - deny, checkpoint present: item target `OtherWorktree` with a non-satisfying checkpoint, and an `Ambiguous` epic target; each asserts zero seam invocations and an unchanged reason;
   - deny, command shape: `--auto`, `--admin`, missing or mismatched `--match-head-commit`, `cd x && gh pr merge ...`, bare command;
   - not evaluated without the switch;
   - entry-point wiring row (allow through `Invoke-EpicMergeGateEntryPoint`);
   - deny reason keeps `EPIC_MERGE_GATE_BLOCKED:` first and carries `(docs-only exemption not applied: <code>...)`.
3. `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (new, about 250 lines). It drives `Invoke-CodexEpicMergeDecision -DocsOnlyWorktreeRoot '/synthetic-worktrees/root'` with the same rows as a `-ForEach` table. Codex-specific rows:
   - checkpoint records the PR: child `pr_gate.pr_number`, epic `epic_merge_pr.pr_number`, standalone entry naming N;
   - malformed non-empty checkpoint means "recorded" (not applied);
   - `NOT_PR_SPECIFIC` verdict means not applied;
   - `PR_MISMATCH` verdict with no recording means evaluated;
   - parameter empty means not evaluated.

Purity: no `Mock git`, `Mock gh`, `Start-Process`, temporary files, or function named `git` or `gh`. Fakes are test-local functions passed by name. The CI Linux job `poshqc-linux-hooks` runs both test directories (`.github/workflows/_poshqc.yml` 54-90, cited in base research section 4).

## 5. Other consumers

| Surface | Change | Evidence |
|---|---|---|
| `.claude/settings.json` line 114, bundle `settings.json` line 114, `.codex/config.toml` 140-144 | none (gate already registered; no new hook entry) | Read |
| `extensions/.../claude-customizations/pack-manifests/core.json` (30-32) | add `.claude/hooks/docs-only-exemption.ps1` | `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` enumerates `hooks/*` (86-91) |
| `extensions/.../codex-and-agents-customizations/pack-manifests/core.json` (36) | add `.codex/hooks/docs-only-exemption.ps1` | `test_push_down_codex_and_agents_pack_manifest_completeness.py` 165-169, 218-239; `test_codex_core_manifest_closure.py` 277-288 (dot-source closure of registered hooks must be in `core.json`) |
| Bundle byte identity | the four new and edited `.claude` files and the two `.codex` files mirrored | `test_push_down_claude_resource_contracts.py` 89-110; `test_push_down_codex_and_agents_resource_contracts.py` 215-228 |
| Dependency guard | each new dot-source must be a single guarded statement recorded through `Add-HookDependencyFailure` | `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` 8-12, 17-28 (repository and both mirror roots) |
| `quality-tiers.yml` | none; directory-level entries `.claude/hooks` (28) and `.codex/hooks` (31) | Read |
| `.claude/rules/orchestrator-state.md` 234-242 and bundle mirror | add a short "Docs-only merge exemption" paragraph after the honest-disclosure paragraph (line 242) | Read; the gate behavior described at line 238 otherwise becomes incomplete |
| Optional docs | `.claude/skills/parallel-orchestrate/SKILL.md` 396-433 and `.claude/skills/cleanup-merged-worktrees/SKILL.md` 549, 575 describe the gate; a one-sentence mention is optional | Grep |
| Claude/Codex reason-code parity | standalone codes unchanged; docs-only codes live in the byte-identical shared file, so the SHA row is the parity check | `authorization.ps1` 43-49 |

## 6. Recommended design

### 6.1 Gate integration

Claude (`enforce-epic-merge-gate.ps1`, estimated +18 to +20 lines, ending at about 490-492):

- One guarded dot-source.
- Header condition 5 in at most 4 lines. Lines 36-39 must state that the docs-only branch makes one live `gh pr view` call.
- The `-EvaluateDocsOnlyExemption` switch with its help text.
- Between lines 407 and 410:
  `if ($EvaluateDocsOnlyExemption -and @(@($itemTarget,$epicTarget,$parallelTarget) | Where-Object { $_.Status -ne 'NoTarget' }).Count -eq 0) { $docsOnly = Get-DocsOnlyMergeExemption -CommandText $commandText -PrNumber $commandPrNumber -WorktreeRoot $sessionRoot; if ($docsOnly.Exempt) { return Get-EpicMergeGateAllowDecision }; $docsOnlySuffix = " (docs-only exemption not applied: $($docsOnly.Reason))" }`
- Line 412 appends `$docsOnlySuffix`.
- Line 450 passes the switch.

The 500-line limit is tight. If the header cannot fit in 4 lines, move the prose into the shared file's header.

Codex (`.codex/hooks/enforce-epic-merge-gate.ps1`, about +45 lines, ending at about 430):

- One guarded dot-source.
- `Test-CodexMergeCheckpointRecordsPr -ChildRaw -EpicRaw -PrNumber`, which returns true when:
  - a non-empty raw text does not parse;
  - child `pr_gate.pr_number` equals N;
  - epic `epic_merge_pr.pr_number` equals N;
  - any `standalone_merge_authorizations` entry in either checkpoint names N.
- Evaluation only when `$DocsOnlyWorktreeRoot` is non-empty, `$verdict.ReasonCode` is ABSENT or PR_MISMATCH, and the predicate is false.
- Deny suffix as for Claude.
- Entry point passes `$repositoryRoot`.
- Header `.DESCRIPTION` extended.

### 6.2 Decider conditions (`Get-DocsOnlyMergeExemption`, evaluated in order; first failure returns)

| # | Condition | Deny code |
|---|---|---|
| M1 | `Read-CommandLineSegment` yields exactly one segment, and `Get-CommandLineInvocation` for `gh pr merge` yields exactly one `Structural` match (no chain, `cd`, pipe, wrapper payload, or substitution) | `DOCS_ONLY_EXEMPTION_COMMAND_SHAPE` |
| M2 | PrNumber non-null (explicit all-digit selector) | `DOCS_ONLY_EXEMPTION_COMMAND_SHAPE` |
| M3 | No token satisfies `Test-DocsOnlyOverrideToken` | `DOCS_ONLY_EXEMPTION_COMMAND_SHAPE` (message names repository override) |
| M4 | No `--auto`, `--auto=`, `--admin`, `--admin=` token | `DOCS_ONLY_EXEMPTION_COMMAND_SHAPE` |
| M5 | Exactly one `--match-head-commit` with a lowercase hex value | `DOCS_ONLY_EXEMPTION_COMMAND_SHAPE` (message gives the expected form) |
| M6 | `gh pr view <N> --json number,state,url,baseRefName,baseRefOid,headRefOid` exits 0; JSON passes section 2.2; `git remote get-url origin` names the same owner/repo | `DOCS_ONLY_EXEMPTION_PR_LOOKUP_FAILED` |
| M7 | `origin/<baseRefName>` resolves; `merge-base --is-ancestor <baseRefOid> <baseCommit>` exits 0 | `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` |
| M8 | `headRefOid` equals the M5 value (ordinal) and resolves locally to itself | `DOCS_ONLY_EXEMPTION_HEAD_UNRESOLVED` (message includes the `headRefOid` and fetch command) |
| M9 | diff `<baseCommit>...<headRefOid>` with the shared argument list exits 0 | `DOCS_ONLY_EXEMPTION_DIFF_FAILED` |
| M10 | `Get-DocsOnlyListingViolation` returns `$null` | `DIFF_FAILED` (no trailing NUL), `EMPTY_DIFF`, or `NON_DOCS_PATH` |

The caller-side precondition (M0, no checkpoint records the PR) is section 6.1. Every seam call is wrapped so a throw denies. No path other than full success returns `Exempt = $true`.

Decision for the operator (D-M1): M5 requires `--match-head-commit`. This closes the check-to-merge race, because GitHub refuses the merge if the head moved, and the M8 denial prints the exact SHA to pass. The friction is one retry. The alternative is to treat the flag as optional: bind it when present and accept the race when absent, consistent with the gate's non-adversarial posture (lines 36-39). Recommendation: require it.

## 7. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Head changes after the check (TOCTOU) | Require `--match-head-commit` equal to the diffed `headRefOid` (M5, M8); GitHub enforces it at merge time |
| `--auto`: merge occurs later at a possibly different head | Deny (M4). Whether gh forwards `--match-head-commit` to auto-merge was not verified |
| `--admin`: bypasses required checks and the merge queue; the exemption performs no CI check | Deny (M4). Without `--admin`, branch protection still enforces required checks |
| Non-`main` base (epic integration branch) | Allowed when the PR is docs-only relative to that base. Epic and parallel PRs recorded in checkpoints never reach the exemption (target resolves). Restricting to `main` is an optional operator choice, not recommended |
| Stale local base hides a reverted non-docs path | Ancestry check (M7) |
| gh resolves a different repository than `origin` | `url`/origin cross-check (M6); override tokens denied (M3) |
| Bash cwd in another repository (no `cd` in the command) | Residual, shared with branches 1-4, which also read relative to `Get-Location`. Documented |
| Ambient `GH_REPO` | Residual; partly covered by the M6 cross-check |
| Hook timeout is fail-open | Verified (`code.claude.com/docs/en/hooks`): a timed-out PreToolUse command hook "doesn't block the tool call" unless `onFailure: "block"` is set (Claude Code v2.1.295+). The default is 600 s for command hooks; the Claude gate entry sets no timeout (`.claude/settings.json` 112-115). The new network call adds exposure. Recommend a follow-up decision on `"onFailure": "block"` for this gate. Codex sets `timeout = 30` (`.codex/config.toml` 144); Codex timeout semantics were not verified |
| Fork PR | Head object absent locally, so HEAD_UNRESOLVED (fail closed) |
| Pre-existing gap outside this item | The gate's scope test reads only the long `--merge` token (`hook-command-invocation-operands.ps1` 146-153; gate 343-356), so `gh pr merge <N> -m` is outside the gate entirely and allowed today. Related to this gate but not to the exemption. Recommend the orchestrator decide whether to remediate it in this item (per the related-follow-ups policy) or record it separately |
| Change budget | At least 5 production `.ps1` Write/Edit targets; see section 3.4 |

## 8. Files to create or edit (repository-relative)

Create:

1. `.claude/hooks/docs-only-exemption.ps1`
2. `.codex/hooks/docs-only-exemption.ps1` (`cp` of 1)
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/docs-only-exemption.ps1` (`cp`)
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/docs-only-exemption.ps1` (`cp`)
5. `tests/scripts/claude-hooks/docs-only-exemption.Tests.ps1`
6. `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`
7. `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1`

Edit:

8. `.claude/hooks/enforce-epic-merge-gate.ps1`, plus mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` (`cp`)
9. `.codex/hooks/enforce-epic-merge-gate.ps1`, plus mirror `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` (`cp`)
10. `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, plus mirror (consume shared helpers; CR-1/CR-2 per the revised plan)
11. `.claude/hooks/enforce-pr-author-skill.ps1`, plus mirror (header, as already planned)
12. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
13. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
14. `.claude/rules/orchestrator-state.md`, plus mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` (`cp`)
15. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` (move the two pure-function Contexts to suite 5; add the planned CR-1 and seam rows)
16. `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` and `...DocsOnly.Decision.Tests.ps1` (planned rows)
17. `spec.md` and the plan (revisions in section 3.4)

Unchanged: `enforce-epic-merge-gate-authorization.ps1` and `enforce-epic-merge-gate-resolution.ps1` (and their mirrors), `enforce-pr-author-skill-helpers.ps1`, all `hook-command-*.ps1`, `.claude/settings.json`, `.codex/config.toml`, `quality-tiers.yml`, and the ten existing merge-gate suites (expected; section 4.2).

## Numeric Derivation Evidence

### N3: existing production copies of the merge-gate hook family

- Complete Family: every non-test PowerShell file implementing the epic merge gate or its dot-sourced siblings, on both runtimes, canonical and bundled.
- Exhaustive Search Scope: whole worktree.
- Inclusion Rules: file name begins `enforce-epic-merge-gate`; extension `.ps1`; not under `tests/`.
- Exclusion Rules: `tests/**` suites; Markdown.
- Primary Search Strategy or Query Expression: Glob `**/enforce-epic-merge-gate*.ps1`.
- Primary Member Set: `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, and the four same-named files under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (3) and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (1).
- Primary Count: 8.
- Cross-check Search Strategy or Query Expression: Grep of both `pack-manifests/core.json` files for `enforce-epic-merge-gate` (canonical relative paths), each confirmed present at both repository root (Read) and bundle root (Grep count of `^` under `extensions/drm-copilot/resources` with glob `*merge-gate*`).
- Cross-check Member Set: claude `core.json` lines 30-32 (three `.claude/hooks/...` paths), codex `core.json` line 36 (one `.codex/hooks/...` path); each at repository root and bundle root.
- Cross-check Count: 4 x 2 = 8.
- Member-set Comparison: identical sets.

### N4: existing merge-gate Pester suites

- Complete Family: Pester suites whose file name targets the merge gate.
- Exhaustive Search Scope: `tests/scripts/**`.
- Inclusion Rules: name contains `merge-gate`, ends `.Tests.ps1`.
- Exclusion Rules: helper files without `.Tests.ps1`.
- Primary Search Strategy or Query Expression: Glob `tests/scripts/{claude-hooks,codex-hooks}/*merge-gate*`.
- Primary Member Set: seven `claude-hooks/enforce-epic-merge-gate.*.Tests.ps1` (Authorization, AuthorizationFields, Coverage, ItemResolution, Tests, TriggerScoping, WorktreeResolution) and three `codex-hooks/enforce-epic-merge-gate-*.Tests.ps1` (authorization, decision-surface, trigger-scoping).
- Primary Count: 10.
- Cross-check Search Strategy or Query Expression: Grep count mode with pattern `^` under `tests/scripts` with glob `*merge-gate*`.
- Cross-check Member Set: the same ten files with line counts 465, 255, 309, 187, 181, 203, 43, 205, 172, 117.
- Cross-check Count: 10.
- Member-set Comparison: identical sets.

Withheld: the claim that no existing suite needs editing under the opt-in design is not proposed as a numeric acceptance criterion. It rests on reading the entry-point call sites (section 4.2) and must be confirmed by the executor's expect-pass run.

## Automation Feasibility

All work can be done by agents:

- Write, Edit, and `cp` for code and mirrors; `cmp -s` and `git hash-object` for byte identity.
- PoshQC MCP for format, analyze, and test pass/fail; per-file coverage for the four new or edited hook files from the Windows CI artifact `poshqc-test-results`.
- `poetry run pytest` for the four Python bundle and manifest contract tests named in section 5.

The live behavior can be observed without a unit test calling `gh`. After merge, run a docs-only `gh pr merge <N> --merge --match-head-commit <sha>` with no checkpoint as the end-state check. This step needs a real docs-only PR and is the only step that depends on live GitHub state.
