# Research: pr-author hook docs-only exemption (#901) and #850 review notes (#903)

- Issue: #901
- Work mode: minor-audit (requirements source: `issue.md` `## Acceptance Criteria`)
- Branch: `bug/pr-author-hook-docs-only-exemption-901`
- Tree inspected: worktree at main 2ef8d361 plus the feature-folder commit
- Author: task-researcher
- Date: 2026-10-11

All file:line citations below were read in this worktree during this research session. Line numbers refer to the current tree, not to the line numbers quoted in the #850 review where they differ.

---

## 1. Summary of findings

1. The exemption belongs inside `Get-PrAuthorBypassReason` (`.claude/hooks/enforce-pr-author-skill-helpers.ps1:408-420`), in the non-epic branch only, evaluated **after** `Invoke-OrchestratorStatePreflight` reports `HasErrors`. Target resolution, Case C (`PR_CONTEXT_MISSING`), and receipt checks 1-6 must stay in force.
2. Receipt checks 1-5 do not read the checkpoint. Check 6 reads it through `Get-PrAuthorCheckpointContent` and is a no-op when the file is absent (`enforce-pr-author-skill.epic-base-branch.ps1:107-110`). No check in the pr-author family reads `pr_gate`, `pr_gate.pr_number`, or `issue-num` directly. The delegation prompt's statement that "the artifact-root helper reads `pr_gate.pr_number`" is not accurate: `pr_gate.pr_number` is read in `enforce-epic-merge-gate-resolution.ps1:183-189` and `WorktreeItemResolution.psm1:415-417`, both outside the pr-author family.
3. Target resolution with `--head` does not require a checkpoint: `Resolve-WorktreeItemTargetByBranch` returns a resolved target when the branch is checked out in exactly one live worktree and the command carries no canonical issue line (`WorktreeItemResolution.psm1:272-288`). A docs-only branch is therefore resolvable, provided it is checked out in a live worktree and `--head` is passed.
4. The hook already parses `--base` (only for the epic check, `enforce-pr-author-skill.epic-base-branch.ps1:100,138`) through `Get-CommandLineFlagValue`, which does not recognize the `-B` short form (`hook-command-invocation-operands.ps1:104-110`). The hook resolves no default base. Recommended rule: require an explicit `--base <branch>`; fail closed when it is absent, malformed, accompanied by a `-B` token, or not resolvable as `refs/remotes/origin/<base>`.
5. No git subprocess exists anywhere in the pr-author family today; worktree resolution reads the filesystem only. A new executable seam is required. Repository precedent is a single `Invoke-GitExe` wrapper (`.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1:48-69`), and `check-powershell-test-purity.ps1:103,106` forbids `Mock git` in Pester tests and directs tests to mock the wrapper.
6. Helpers file is at 429 lines (71 lines of headroom). New functions should go in a new sibling, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, dot-sourced from the helpers file next to the artifact-root dot-source (`enforce-pr-author-skill-helpers.ps1:53`).
7. The new sibling must be copied to the bundle mirror and registered in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`:50-54` region). Byte/content parity is enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`:89-110`); manifest membership by `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:200-214`.
8. No Codex counterpart exists. `.codex/hooks/` contains no `enforce-pr-author-skill*` file; `.codex` and `.agents` contain no text describing the orchestrator-state preflight.
9. PowerShell coverage is root-based (`config/poshqc-coverage.json:3-9` includes `.claude/hooks`). A new file under `.claude/hooks/` is measured automatically; no registration is required.
10. #850 notes L20, L21, L22, and L23 concern files **outside** the pr-author hook family (`enforce-epic-merge-gate-resolution.ps1`, `enforce-epic-worktree-removal-gate-resolution.ps1`, `enforce-epic-merge-gate-authorization.ps1`, `WorktreeItemResolution.psm1`). This conflicts with the `issue.md` constraint "Edits stay within the pr-author hook family". AC-6 (L20) cannot be met without adding a row to an out-of-family test file. The planner must state this scope exception explicitly.
11. An additional pre-existing defect was found next to L19: a relative `--body-file artifacts/pr_body_007.md` is accepted with body number 7, so the hook verifies `pr_body_7.md`/`pr_body_7.receipt.json` while `gh` uploads `pr_body_007.md` (`enforce-pr-author-skill.artifact-root.ps1:179-188` with `enforce-pr-author-skill-helpers.ps1:229-231`). The L19 fix can close it at no extra cost.

---

## 2. Current state: decision flow for `gh pr create` / `gh pr edit --body*`

Entry: `.claude/settings.json:105` registers `pwsh -NoProfile -File .claude/hooks/enforce-pr-author-skill.ps1` as a Bash PreToolUse hook.

| Order | Step | Location | Outcome |
|---|---|---|---|
| 0 | Dependency guard. Any failed dot-source or module import becomes a deny with prefix `PR_AUTHOR_SKILL_BLOCKED:` | `enforce-pr-author-skill.ps1:51,54,60,165,169-171,192-193,322-324` | deny |
| 1 | Envelope parse; anomaly denies; missing `command` allows | `enforce-pr-author-skill.ps1:195-206` | deny / allow |
| 2 | Trigger scoping: structural `gh pr create` / `gh pr edit` invocation, otherwise allow | `enforce-pr-author-skill-helpers.ps1:329-334` | allow |
| 3 | Flag detection (`--body-file`, `--body`), raw-scan fallback for indeterminate segments | `helpers.ps1:339-360` | - |
| 4 | Case A: inline `--body` without `--body-file` | `helpers.ps1:364-366` | deny `PR_AUTHOR_SKILL_BLOCKED` |
| 5 | Case B: `gh pr create` with no body flag | `helpers.ps1:368-373` | deny `PR_AUTHOR_SKILL_BLOCKED` |
| 6 | `gh pr edit` with no body flag | `helpers.ps1:375-380` | allow |
| 7 | Artifact-root / target resolution (epic scope first, else identity resolution from `--head`, issue line) | `helpers.ps1:386-389` -> `enforce-pr-author-skill.artifact-root.ps1:87-140` -> `helpers.ps1:78-127` -> `Resolve-PrAuthorWorktreeTarget` seam `helpers.ps1:55-76` | deny `TARGET_WORKTREE_NOT_DERIVABLE` / ambiguity code / epic-suffix `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` |
| 8 | Case C: context summary absent beneath the resolved root | `helpers.ps1:391-395` (seam `Get-PrContextArtifactExistence`, `enforce-pr-author-skill.ps1:62-79`) | deny `PR_CONTEXT_MISSING` |
| 9a | Epic scope: `Get-EpicPrCreationReadinessFailure` against the epic checkpoint | `helpers.ps1:401-407` | deny `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` |
| 9b | Non-epic: assign `$script:OrchestratorStateCheckpointPath`, call `Invoke-OrchestratorStatePreflight -CheckpointPath` | `helpers.ps1:408-420` | deny `ORCHESTRATOR_STATE_PREFLIGHT_FAILED: <summary>` |
| 10 | Receipt checks 1-6 | `helpers.ps1:423-426` -> `Test-PrAuthorReceiptVerification` `helpers.ps1:165-298` | deny with the first failing code |
| 11 | Allow | `helpers.ps1:428` | allow |

Preflight internals: `Invoke-OrchestratorStatePreflight` (`.claude/lib/orchestrator-state/OrchestratorState.psm1:394-...`) takes an injectable `[scriptblock] $Invoker` (`:423-461`). The default invoker loads the checkpoint via `Get-OrchestratorStateCheckpoint` and fails closed when it cannot load (`:435-437`), then runs the U-family checks and `Test-OrchestratorStatePrCreationReadiness` (`:441-459`). It starts no subprocess (`:402-403`). A missing checkpoint therefore yields `HasErrors = $true`, which the hook maps to `"checkpoint missing at <path>"` when the error text is empty (`helpers.ps1:413-418`).

Receipt checks and their dependence on the checkpoint:

| Check | Code | Reads | Depends on checkpoint |
|---|---|---|---|
| 1 | `PR_BODY_PATH_NONCANONICAL` | command text, artifact root (`artifact-root.ps1:142-200`) | No |
| 2 | `PR_AUTHOR_RECEIPT_MISSING` | `Get-PrAuthorReceiptContent` (`enforce-pr-author-skill.ps1:110-136`) | No |
| 3 | `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH` | receipt `number`, `[int]::TryParse` (`helpers.ps1:247-255`) | No |
| 4 | `PR_AUTHOR_RECEIPT_HASH_MISMATCH` | `Get-PrBodyFileBytes` (`enforce-pr-author-skill.ps1:81-108`) | No |
| 5 | `PR_AUTHOR_RECEIPT_STALE` | `Get-PrContextSummaryLastWriteUtc` (`enforce-pr-author-skill.ps1:138-163`) | No |
| 6 | `EPIC_BASE_BRANCH_MISMATCH` | `Get-PrAuthorCheckpointContent` (`epic-base-branch.ps1:17-48`), `epic_mode`, `epic_context.integration_branch` (`:107-141`) | Reads it; returns `$null` (no-op) when absent, empty, or unparseable (`:107-121`) |

`Test-PrAuthorReceiptVerification` declares `-CheckpointPath` as `[Parameter(Mandatory)] [string]` (`helpers.ps1:210-211`). In the non-epic branch the path is always a composed string (`helpers.ps1:120` via `Get-WorktreeItemCheckpointPath`), so it is non-null even when the file does not exist. The receipt checks can therefore run unchanged on an exempt branch.

Conclusion for item 1: the exemption replaces only step 9b. It must not bypass step 7 (it needs the resolved worktree root to run git in, and checks 1-5 need `ArtifactRoot`), step 8, or step 10. The receipt checks do not depend on the checkpoint, so the issue's default ("does not relax the body-file and receipt checks") holds with no exception.

---

## 3. Recommended design

### 3.1 Insertion point and ordering

Modify only the non-epic `else` branch at `enforce-pr-author-skill-helpers.ps1:408-420`:

1. Run `Invoke-OrchestratorStatePreflight` exactly as today.
2. If `HasErrors` is false, continue to receipt verification (unchanged path; no git call, satisfies AC-3).
3. If `HasErrors` is true, call one new function, for example `Get-PrAuthorDocsOnlyExemption -CommandText $CommandText -WorktreeRoot $artifact.ArtifactRoot -CheckpointPath $checkpointPath`, which returns `[ordered]@{ Exempt = [bool]; Reason = [string] }`.
4. If `Exempt` is true, fall through to receipt verification. Otherwise return the existing denial with the exemption sub-code appended, for example `"ORCHESTRATOR_STATE_PREFLIGHT_FAILED: $preflightSummary (docs-only exemption not applied: $($exemption.Reason))"`.

Rationale for "after the preflight fails":
- A branch with a valid checkpoint never reaches git, so AC-3 holds by construction and the suites that mock the preflight to succeed are unaffected.
- Every existing assertion on this denial uses a prefix or substring match (`Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'` or `-BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'`; full list in section 9). Keeping the prefix and appending a sub-code keeps all of them valid while giving each fail-closed branch a distinct, assertable code (AC-2 allows "the existing checkpoint-preflight denial or a new documented denial code").
- The epic branch (`helpers.ps1:401-407`) is not touched; the exemption never applies under epic scope.

### 3.2 Exemption predicate (fail closed at every step)

Evaluate in this order; the first failure returns its sub-code and the exemption is not applied.

| Step | Condition | Sub-code (proposed) |
|---|---|---|
| E1 | Command is `gh pr create` (structural match). `gh pr edit` is not exempt. | `DOCS_ONLY_EXEMPTION_NOT_CREATE` |
| E2 | No checkpoint file exists at the resolved checkpoint path (new presence seam, `Test-Path -LiteralPath -PathType Leaf`). A present-but-invalid checkpoint means the branch is under orchestration; its preflight governs. | `DOCS_ONLY_EXEMPTION_CHECKPOINT_PRESENT` |
| E3 | Base: exactly one explicit `--base <value>` (via `Get-CommandLineFlagValue -FlagName '--base'`), no `-B`-prefixed token in the structural match, value matches a conservative pattern such as `^[A-Za-z0-9][A-Za-z0-9._/-]*$` and contains no `..`. | `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` |
| E4 | `git -C <root> rev-parse --verify --quiet refs/remotes/origin/<base>^{commit}` exits 0 and prints one hex object id (`^[0-9a-f]{40}([0-9a-f]{24})?$`). | `DOCS_ONLY_EXEMPTION_BASE_UNRESOLVED` |
| E5 | `git -C <root> diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <oid>...HEAD` exits 0. | `DOCS_ONLY_EXEMPTION_DIFF_FAILED` |
| E6 | At least one path after splitting on NUL and discarding the empty trailing element. | `DOCS_ONLY_EXEMPTION_EMPTY_DIFF` |
| E7 | Every path satisfies `$path.StartsWith('docs/', [System.StringComparison]::Ordinal)` and `$path.Length -gt 5`. | `DOCS_ONLY_EXEMPTION_NON_DOCS_PATH` (name the first offending path) |

Decision on E1: AC-1 names `gh pr create --body-file` only. `gh pr edit` carries no base in normal use, so restricting the exemption to create keeps the weakening minimal. If the operator wants body edits on docs-only PRs, the same predicate can be extended later; record this as a plan decision.

Decision on E2: the issue text is "allowing `gh pr create --body-file` without an orchestrator-state checkpoint". Gating on file absence keeps orchestrated docs-only items (which do have a checkpoint) under the full readiness preflight. The existing `Get-PrAuthorCheckpointContent` seam cannot serve this purpose, because `Get-Content -Raw` returns `$null` for both an absent file and an empty file, and many suites mock it to `$null`.

### 3.3 Base resolution rule (item 2)

Current behavior:
- `--base` is parsed only by `Test-EpicBaseBranchOverride` (`epic-base-branch.ps1:100,138`), using `Get-CommandLineFlagValue` (`hook-command-invocation-operands.ps1:70-...`), which recognizes `--base value` and `--base=value` and returns `$null` for a missing or dash-leading value (`:75-79`). It does not recognize `-B`.
- Epic scope requires `--base main` (`epic-base-branch.ps1:99-105`); per-feature `epic_mode` requires `--base <epic_context.integration_branch>` (`:118-141`).
- The hook resolves no default base. When `--base` is omitted, `gh` uses the repository default branch, which the hook does not observe.

Recommended rule: require an explicit long-form `--base <branch>` for the exemption and verify `refs/remotes/origin/<branch>` with `rev-parse --verify`. The deny text should tell the caller to pass `--base <branch>`.

Rejected alternative: default to `git symbolic-ref refs/remotes/origin/HEAD` when `--base` is absent. It adds a git call, `origin/HEAD` is not set in every clone, and a `-B develop` spelling would be invisible to the hook, so the diff could be computed against `main` while the PR targets `develop`. That is a false-allow path.

Notes:
- Using the resolved object id (not the ref name) in the `diff` call removes any option-injection surface in the second git call.
- A stale local `origin/<base>` errs toward deny: the three-dot form diffs from the merge base, so commits merged to the base after the local fetch can only add paths, not remove them.
- The remote name `origin` is assumed; a clone without it fails closed at E4.

### 3.4 Git diff form and path-normalization edge cases (item 8)

| Edge case | Handling |
|---|---|
| Rename from outside `docs/` into `docs/` | `--name-only` with rename detection prints only the new path, which would be a false allow. `--no-renames` reports a delete plus an add, so the old path is checked. Required. `--no-renames` also overrides `diff.renames` config. |
| Copies | Copy detection is off unless `-C`/`--find-copies` is passed; not passed. |
| Deletions | A deleted path is listed by `--name-only`; deleting a non-docs file denies. |
| Prefix collisions (`docsx/`, `doc/`, `docs` as a file) | Ordinal `StartsWith('docs/')` with the trailing slash, plus length > 5. |
| Case (`Docs/`, `DOCS/`) | Ordinal comparison; git reports tree paths as stored, so a differently-cased directory is denied. |
| Quoted paths, spaces, unicode | `-z` disables C-style quoting (`core.quotePath` is irrelevant with `-z`) and separates entries with NUL. Native output in pwsh is decoded per line; re-join the captured lines with "`n" before splitting on "`0" so a path containing LF is not split. A mis-decoded non-ASCII path cannot acquire the ASCII prefix `docs/`, so decoding errors can only deny. |
| Empty output | E6 deny. |
| `diff.relative` config | `--no-relative` forces repository-root paths (git 2.28+; an older git rejects the option and E5 denies). |
| External diff / textconv / color config | `--no-ext-diff`, `--no-color`; `--name-only` does not run textconv. |
| Unrelated history, shallow clone | `A...B` needs a merge base; git exits non-zero and E5 denies. |
| Uncommitted or untracked files | Not part of the PR; diffing commits (`...HEAD`) is correct. |
| Submodule (gitlink) changes | Reported as a path; outside `docs/` denies. |
| Unpushed local commits vs remote head | Residual risk: the hook diffs the resolved worktree's local `HEAD`; if the remote head branch carries commits not present locally, they are not seen. Optional hardening: also require `rev-parse HEAD` to equal `rev-parse refs/remotes/origin/<head>`; record as a plan decision. |

Recommended commands (two calls, each through the seam):

```
git -C <root> rev-parse --verify --quiet refs/remotes/origin/<base>^{commit}
git -C <root> diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <oid>...HEAD
```

### 3.5 Seams and testability (item 3)

Existing mocking patterns in `tests/scripts/claude-hooks/enforce-pr-author-skill*.Tests.ps1`:
- Pester `Mock -CommandName <function>` against functions defined in the dot-sourced hook family: `Resolve-PrAuthorWorktreeTarget` (`OrchestratorStatePreflight.Tests.ps1:39-41`), `Get-PrContextArtifactExistence` (`:46`), `Invoke-OrchestratorStatePreflight` (`:53-55,66-68`), `Get-PrAuthorCheckpointContent`, `Get-PrAuthorReceiptContent` (`:26-27`).
- `-ModuleName` mocks for module read seams: `Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState`, `Get-WorktreeItemCheckpointText`/`Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution`, `Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution`, `Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution` (`OrchestratorStatePreflight.Tests.ps1:24-30`).
- The injectable `$Invoker` scriptblock parameter of `Invoke-OrchestratorStatePreflight` (`OrchestratorState.psm1:423`); the suite-level `PSReviewUnusedParameter` suppression references it (`OrchestratorStatePreflight.Tests.ps1:12`).
- Committed fixture roots run through `Invoke-WorktreeResolutionFixtureCall` (`WorktreeResolution.Tests.ps1:17-21,62,125-127`) and `Set-LiveTopology` / `Set-ResolvedSeam` helpers (`:89-110`).
- Baseline isolation probe `Invoke-EpicStateInterceptionProbe` / `Register-EpicStateBaselineMock` from `EpicStateIsolation.Baseline.Helpers.ps1` (`OrchestratorStatePreflight.Tests.ps1:19,33`).

Constraint: `check-powershell-test-purity.ps1:102-120` rejects `Mock git`, `Mock 'git'`, temporary files, `$env:TEMP`, `Start-Process`, and `Start-Sleep` in Pester test content; it names `Invoke-GitExe` as the wrapper to mock. Repository precedent for the wrapper: `Resolve-MergeableConflict.ps1:48-69` ("The single executable seam of this script").

Recommended seams in the new sibling:
1. `Invoke-PrAuthorDocsOnlyGit -WorktreeRoot <string> -GitArgs <string[]>` returns `[pscustomobject]@{ ExitCode = <int>; Output = <string> }` and **never throws**. Unlike `Invoke-GitExe`, it must not throw on non-zero exit: an uncaught error in this hook ends `pwsh -File` with exit 1, which PreToolUse treats as non-blocking (`enforce-pr-author-skill.ps1:286-288`), so a throw would be a fail-open. Body: return a failure object when `-not (Test-Path -LiteralPath $WorktreeRoot -PathType Container)` (so a nonexistent fixture root never spawns git); otherwise `try { $out = & git -C $WorktreeRoot @GitArgs 2>$null; $code = $LASTEXITCODE } catch { return failure }` (covers git not on PATH). Keep the body to a few lines so its unmockable `& git` lines stay a small share of the file's coverage denominator.
2. `Test-PrAuthorDocsOnlyCheckpointPresence -CheckpointPath <string>` returns `[bool]` (`Test-Path -LiteralPath -PathType Leaf`).
3. Pure functions, unit-testable without mocks: base-name extraction/validation from command text; NUL-list parsing; the path-set classifier returning `$null` or a sub-code.
4. One orchestrating function `Get-PrAuthorDocsOnlyExemption` composing the above.

Do not embed the literal `orchestrator-state.json` in any string expression; `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1:117-151` enforces this for the main hook, helpers, and epic-base-branch files. The new sibling is not in that list, but the rule should be followed; use the resolved `$artifact.CheckpointPath`.

### 3.6 File placement and dot-sourcing (item 4)

Current line counts (counted with `Grep -c '^'`; the Read tool output agrees):

| File | Lines | Headroom to 500 |
|---|---|---|
| `.claude/hooks/enforce-pr-author-skill.ps1` | 334 | 166 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 429 | 71 |
| `.claude/hooks/enforce-pr-author-skill.artifact-root.ps1` | 200 | 300 |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 144 | 356 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | 469 | 31 |
| `tests/.../enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | 418 | 82 |
| `tests/.../enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1` | 353 | 147 |
| `tests/.../enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 350 | 150 |
| `tests/.../enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 221 | 279 |
| `tests/.../enforce-pr-author-skill.EpicScope.Tests.ps1` | 174 | 326 |
| `tests/.../enforce-pr-author-skill.Issue824.Tests.ps1` | 168 | 332 |
| `tests/.../enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 131 | 369 |
| `tests/.../enforce-pr-author-skill.TargetResolution.Tests.ps1` | 128 | 372 |
| `tests/.../enforce-pr-author-skill.Payload.Tests.ps1` | 126 | 374 |
| `tests/.../enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | 71 | 429 |
| Bundle mirrors of the four hook files | 334 / 429 / 200 / 144 | same |

Recommendations:
- Create `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (naming follows `enforce-pr-author-skill.artifact-root.ps1` and `.epic-base-branch.ps1`). Start it with `[CmdletBinding()] param()` and a comment-based header, as `artifact-root.ps1:1-26` does. It must emit nothing at load time (`tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` covers hook load output).
- Dot-source it from `enforce-pr-author-skill-helpers.ps1` directly after line 53, using the same unguarded form as the artifact-root line. A load failure is then reported as the enclosing top-level edge `enforce-pr-author-skill-helpers.ps1` by the dependency guard, matching the nested-failure behavior asserted in `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1:138-149`. Do not add a scoped `try { . } catch { $script:X = ... }` handler: `tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1:69-71` (G2) fails on any scoped import-failure handler not in the named-exemption list.
- Expected edits to the helpers file: about 8-12 lines in the non-epic branch, one dot-source line, and a sentence in `.DESCRIPTION`, giving roughly 440-445 lines.
- New tests: `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1`. `enforce-pr-author-skill.Tests.ps1` has only 31 lines of headroom and should not receive new rows.

### 3.7 Bundle mirrors and parity (item 5)

- Mirror directory: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. All four family files are present there with line counts equal to the repository copies.
- Content parity test: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`:89-110`) enumerates every distributable repo `.claude` file and asserts that it exists in the bundle with equal `read_text` content. It walks the filesystem, so a new repo file without a mirror fails it.
- Manifest registration: every bundled `.claude` file must appear in some pack manifest, asserted by `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:200-214`. The family is listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:51-54` in sorted order. Add `".claude/hooks/enforce-pr-author-skill.docs-only.ps1"` between `:51` (`.artifact-root.ps1`) and `:52` (`.epic-base-branch.ps1`).
- A local failure of the parity test can come from gitignored `.claude/state/` files (open issue #510). For AC-4 evidence, also record a `git hash-object` comparison of each repo file against its mirror.
- Codex: `.codex/hooks/` has no `enforce-pr-author-skill*` file (40 files listed; none match), and `extensions/drm-copilot/resources/codex-and-agents-customizations/` contains only `.codex/agents/pr-author*.toml` agent definitions. `.codex/agents/pr-author.toml` contains no "checkpoint" or "preflight" text. The only Codex mention is a comment, `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:22` ("precedent set by enforce-pr-author-skill.ps1"), which is unaffected. No Codex change is required.

### 3.8 Coverage configuration (item 6)

- `Invoke-PoshQCTest` derives the coverage population from `config/poshqc-coverage.json` (`scripts/powershell/PoshQC/README.md:70-75`). That file lists `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts` (`config/poshqc-coverage.json:3-9`). A new `.ps1` under `.claude/hooks/` is measured automatically; no registration is needed.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` sets CoverageGutters output to `artifacts/pester/powershell-coverage.xml` with `CoveragePercentTarget = 0` (no threshold failure in the runner).
- CI: `.github/workflows/_poshqc.yml:38-52` runs `Invoke-PoshQCTest` on `windows-latest` and uploads `artifacts/pester/powershell-coverage.xml` and `powershell-coverage.koverage.xml` as the `poshqc-test-results` artifact. Per-file figures for AC-9 come from that artifact. The Linux job (`:54-90`) runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` with coverage disabled, so new tests must also pass on Linux (forward-slash synthetic paths, no Windows-only assumptions).
- The PoshQC MCP test tool returns a summary only, so per-file percentages must be read from the CI artifact.

### 3.9 Documentation that would become incomplete (item 7)

| File:line | Current statement | Effect of exemption |
|---|---|---|
| `.claude/agents/pr-author.md:38-43` | The hook "blocks with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` when the checkpoint is missing" | Incomplete: a docs-only branch with no checkpoint is allowed |
| `.claude/agents/pr-author.md:68-72` | Five ordered receipt checks | Still accurate |
| `.claude/agents/orchestrator.md:93` | Hook re-validates the checkpoint "via an injectable `$Invoker` subprocess seam" and blocks when missing | Incomplete in the same way; describes the orchestrated flow, where a checkpoint exists, so it remains accurate for that context. The phrase "subprocess seam" is already stale (`OrchestratorState.psm1:402-403`: no subprocess since #475) |
| `.claude/skills/orchestrate/SKILL.md:195` | Same text as orchestrator.md, including "subprocess seam" | Same |
| `.claude/skills/pr-author/SKILL.md:87-92` | Hook "validates the orchestrator checkpoint belonging to that worktree" | Incomplete |
| `CLAUDE.md:56` | Hook performs checkpoint enforcement ahead of PR authoring | Remains true for orchestrated work |
| Bundle mirrors of the agent and skill files | Same text | Same |

Recommendation: do not edit these files in this item. The issue's scope boundary is the hook family, its mirrors, and its tests; AC-10 places the authoritative description in the hook header. The orchestrator and orchestrate texts describe the orchestrated path, where the behavior does not change. Record a follow-up for `pr-author.md:38-43` and `pr-author/SKILL.md:87-92` (the two texts a pr-author run reads directly) and for the stale "subprocess seam" wording. `.claude/rules/` and `.github/instructions/` are not edited.

### 3.10 Header documentation (AC-8, AC-10)

- `enforce-pr-author-skill.ps1:39`: "Compatible with PowerShell 7+. No external module dependencies." Actual dependencies: dot-sources `hook-dependency-guard.ps1` (`:51`), `enforce-pr-author-skill.epic-base-branch.ps1` (`:165`), `enforce-pr-author-skill-helpers.ps1` (`:169`); imports `HookPayload.psm1` (`:54`), `OrchestratorState.psm1` (`:60,171`), `OrchestratorStateUnconditional.psm1` (`:170`). Through the helpers it loads `hook-command-scanner.ps1`, `hook-command-invocation.ps1` (`helpers.ps1:36-37`), five worktree-resolution modules (`:43-51`), and `enforce-pr-author-skill.artifact-root.ps1` (`:53`). After this change it also loads `git` at run time on the exemption path. Replace the sentence with an accurate list (PowerShell 7+, in-repo modules and siblings only, no PowerShell Gallery modules, and the `git` executable on the exemption path).
- The same stale sentence also appears at `enforce-pr-author-skill-helpers.ps1:29`. The #850 review cited only the main hook; correct both.
- `.DESCRIPTION` (`enforce-pr-author-skill.ps1:19-36`): add the docs-only exemption to the block-case list after "Preflight", naming the conditions (no checkpoint file, `gh pr create`, explicit `--base`, diff resolvable, non-empty, every path under `docs/`) and the fail-closed sub-codes. `.SYNOPSIS` can stay as is or gain one clause. The helpers `.DESCRIPTION` (`helpers.ps1:300-312`) describes the deny precedence and should name the exemption step.

---

## 4. #850 review notes (#903)

Source rows: `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/code-review.2026-10-09T01-12.md:19-23,25`.

### L19: body number above Int32.MaxValue (fix; in family)

- Code: `enforce-pr-author-skill.artifact-root.ps1:180` (`$number = [int]$Matches[1]`, relative form) and `:192` (absolute form). The regexes are `'^artifacts/pr_body_(\d+)\.md$'` (`:179`) and `'/artifacts/pr_body_(\d+)\.md$'` (`:191`).
- Defect: `[int]"99999999999"` throws a `RuntimeException`. Nothing in the call chain catches it (`enforce-pr-author-skill.ps1:312,329` have no try/catch), so `pwsh -File` exits 1, which PreToolUse treats as non-blocking. That is a fail-open. .NET `\d` also matches non-ASCII Unicode decimal digits, which the cast does not accept either.
- Fix: replace both casts with `[int]::TryParse($Matches[1], [System.Globalization.NumberStyles]::None, [System.Globalization.CultureInfo]::InvariantCulture, [ref] $number)`. On failure return the generic `PR_BODY_PATH_NONCANONICAL` result (`:173,199`). `[int]` matches the receipt-number parse at `helpers.ps1:250`, so the family stays on one integer width.
- Same-site additional defect (recommend fixing in the same edit): leading zeros. `artifacts/pr_body_007.md` matches `:179`, parses to 7, and on the relative branch returns `BodyNumber = 7` (`:188`). The verifier then composes `pr_body_7.md` and `pr_body_7.receipt.json` (`helpers.ps1:230-231`) while `gh` uploads `pr_body_007.md`, so the verified bytes are not the bytes sent. The absolute branch is not affected (the composed canonical path differs, so `:194` fails). Fix: require `$number.ToString([CultureInfo]::InvariantCulture) -ceq $Matches[1]`, or use the pattern `(0|[1-9][0-9]*)`.
- Optional defense in depth: wrap `Invoke-PrAuthorSkillDecision` in the entry point so any unexpected exception becomes a deny decision. Not required by AC-5; record as a plan decision.
- Test: a new row (relative and absolute forms) asserting `deny` with `PR_BODY_PATH_NONCANONICAL*` and no exception, for `pr_body_99999999999.md`. Place it in `ItemArtifactRoot.Tests.ps1` (147 lines of headroom) or the new DocsOnly suite.

### L20: unparseable `pr_gate.pr_number` branch uncovered (fix; out of family, test only)

- Code: `.claude/hooks/enforce-epic-merge-gate-resolution.ps1:183-189`, `Test-ChildCheckpointPrGateBinding` (the review cites line 222; the current line is 186): `if (-not [int]::TryParse([string]$Checkpoint.pr_gate.pr_number, [ref] $recorded)) { return $false }`.
- Defect: no test row drives a present but non-integer `pr_gate.pr_number`. The behavior is correct (fail closed); only coverage is missing.
- Fix: add one row to `Context 'child checkpoint pull request binding'` in `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1:238-308` (file is 310 lines), for example extend the `-ForEach` at `:258-261` or add an `It` with `'{"pr_gate":{"pr_number":"abc"}}'` and `-CommandPrNumber 812`, expecting `$false`.
- Scope: this file is outside the pr-author family. AC-6 requires the test, so the plan must name this single test-file edit as an explicit exception to the `issue.md` scope boundary and check that no concurrent epic owns the file. No production edit or mirror edit is needed.

### L21: `PSUseSingularNouns` suppression (recommend no change)

- Code: `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1:179` (function `Get-EpicWorktreeGateDenyDiagnostics`), suppression at `:197`.
- A rename to `Get-EpicWorktreeGateDenyDiagnostic` would touch: the definition `:179`, the doc mention `:21`, the suppression `:197`, the caller `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:403`, the same four sites in the bundle mirror (`extensions/.../enforce-epic-worktree-removal-gate-resolution.ps1:21,179,197` and `.../enforce-epic-worktree-removal-gate.ps1:403`), and the test call `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1:198`. No `.codex` copy references it. The rename would not break external callers (the function is not exported from a module), but it edits four production files and one test outside the pr-author family.
- Recommendation: no change in this item. The suppression is localized and carries a justification, PSScriptAnalyzer reports no diagnostic, the review classified it as non-blocking and not a policy violation, and the edit lies outside the scope boundary. Record the rationale in an evidence artifact (AC-7) and leave the rename for the next change that edits the removal gate.

### L22: duplicated positive-JSON-integer rule (recommend no change)

- Copy 1: `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:424`, inline `($value -is [int] -or $value -is [long]) -and $value -gt 0`, inside private `Test-WorktreeItemCheckpointRecordsPr` (`:401-427`).
- Copy 2: `.claude/hooks/enforce-epic-merge-gate-authorization.ps1:86-108`, `Test-StandalonePositiveJsonInteger`, used at `enforce-epic-merge-gate-resolution.ps1:198` and `enforce-epic-merge-gate-authorization.ps1:189,305,365`.
- Can one call the other: the module cannot reliably call a function dot-sourced into a hook's script scope, and making a library module depend on a hook file would invert the dependency direction. The reverse is possible (export the predicate from a module and have the hook call it), but that changes a module's export surface and two hook files, all outside the family, and the merge gate's bundle mirror.
- Recommendation: no change. The two copies are equivalent today. The review states that a drift would produce a deny, not an unbound allow, because the gate re-checks the checkpoint it reads. Record the rationale (AC-7) and a trigger: consolidate when either copy changes.

### L23: `[long]` vs `[int]` TryParse (recommend no change)

- `WorktreeItemResolution.psm1:416-417` parses `pr_gate.pr_number` with `[long]::TryParse` against `[long] $PrNumber` (`:406`).
- `enforce-epic-merge-gate-resolution.ps1:185-186` parses it with `[int]::TryParse` against `[Nullable[int]] $CommandPrNumber` (`:173`).
- Behavior: for a recorded value above Int32.MaxValue, the module parse succeeds and the equality with an `[int]`-ranged command number is false; the gate parse fails and returns `$false`. The observable result is the same for every input.
- Recommendation: no change; both files are outside the family and there is no behavioral difference. Record the rationale (AC-7). Within the pr-author family, `[int]` is used throughout after the L19 fix.

### L25: stale `.NOTES` text (fix; in family)

See section 3.10. `enforce-pr-author-skill.ps1:39` and `enforce-pr-author-skill-helpers.ps1:29`.

---

## 5. Requirements mapping

| AC | Design element | Files |
|---|---|---|
| AC-1 | E1-E7 pass -> receipt checks -> allow | new sibling; `helpers.ps1:408-420`; new DocsOnly suite |
| AC-2 | Sub-codes `CHECKPOINT_PRESENT`, `BASE_UNRESOLVED`, `DIFF_FAILED`, `EMPTY_DIFF`, `NON_DOCS_PATH` under the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` prefix; one test per branch, including `.claude/`, `.github/`, a root file, `docsx/`, `doc/`, and a rename whose old path is outside `docs/` | new sibling; DocsOnly suite |
| AC-3 | Exemption evaluated only after the preflight fails; valid-checkpoint path unchanged; added mocks are behavior-preserving | `helpers.ps1`; suites listed in section 9 |
| AC-4 | Copy edited and new hook files to the mirror; register in `core.json`; parity test plus `git hash-object` record | mirror dir; `pack-manifests/core.json` |
| AC-5 | `[int]::TryParse` with generic deny | `artifact-root.ps1:179-197` |
| AC-6 | New row in merge-gate ItemResolution suite | `enforce-epic-merge-gate.ItemResolution.Tests.ps1` (out-of-family exception) |
| AC-7 | No-change rationale for L21, L22, L23 | evidence artifact under the feature folder |
| AC-8 | Correct `.NOTES` | `enforce-pr-author-skill.ps1:39` (and `helpers.ps1:29`) |
| AC-9 | Line caps per section 3.6; PoshQC MCP format/analyze/test; CI coverage artifact | all edited files |
| AC-10 | Header documentation of the exemption | `enforce-pr-author-skill.ps1:1-48` |

State model for the exemption: `PreflightPassed` -> receipt checks (unchanged). `PreflightFailed` -> `NotCreate | CheckpointPresent | BaseUnresolved | DiffFailed | EmptyDiff | NonDocsPath` (deny) or `Exempt` -> receipt checks.

---

## 6. Rejected alternatives

- Run the docs-only check before the preflight: every branch would pay two git calls; suites that mock the preflight to succeed would also need git-seam mocks; AC-3 would hold only through extra mocking.
- Bypass worktree resolution for docs-only branches: the exemption needs the resolved root for `git -C` and for the receipt checks; skipping resolution would bring back the process-directory binding removed in #673/#850.
- Default base from `origin/HEAD` or hard-coded `main`: see section 3.3; `-B` is invisible to the parser, and the bundled hook runs in repositories whose default branch may not be `main`.
- `git diff --name-status -z` with rename parsing: equivalent safety to `--no-renames` with more parsing code.
- Throwing `Invoke-GitExe` seam: a throw in this hook is a fail-open (exit 1 is non-blocking).

---

## 7. Testing implications

New suite `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1` (Pester 5, AAA, no temporary files, no real git):
- Pure classifier rows: all-`docs/` set -> exempt; `.claude/x`, `.github/x`, `README.md`, `docsx/a.md`, `doc/a.md`, `Docs/a.md`, a bare `docs` path -> `NON_DOCS_PATH`; empty set -> `EMPTY_DIFF`; a NUL list with spaces and non-ASCII names; a NUL list containing an LF inside a name.
- Base rows: `--base main` accepted; `--base=main` accepted; no `--base` -> `BASE_UNRESOLVED`; `-B main` -> `BASE_UNRESOLVED`; `--base -x`, `--base a..b` -> `BASE_UNRESOLVED`.
- Seam rows (mock `Invoke-PrAuthorDocsOnlyGit` with a `-ParameterFilter` on the subcommand): rev-parse non-zero -> `BASE_UNRESOLVED`; rev-parse output not an object id -> `BASE_UNRESOLVED`; diff non-zero -> `DIFF_FAILED`; assert the diff call carries `-z`, `--no-renames`, and `<oid>...HEAD`; a rename modeled as delete-plus-add with the old path outside `docs/` -> `NON_DOCS_PATH`.
- Default-seam rows: a nonexistent worktree root returns a failure object without spawning a process.
- End-to-end rows through `Invoke-PrAuthorSkillDecision` with the existing hook mocks: AC-1 allow (presence `$false`, git seam returns an object id and a docs-only list, receipt seams return a valid receipt); checkpoint present and failing -> deny with `CHECKPOINT_PRESENT`; preflight passes -> `Should -Invoke Invoke-PrAuthorDocsOnlyGit -Times 0 -Exactly`; epic scope -> git seam not invoked; `gh pr edit --body-file` -> deny `NOT_CREATE`; exempt branch with a receipt hash mismatch still denies `PR_AUTHOR_RECEIPT_HASH_MISMATCH`.
- L19 rows: `pr_body_99999999999.md` relative and absolute -> `PR_BODY_PATH_NONCANONICAL`, no throw; optional leading-zero row.
- L20 row: as in section 4.

Coverage: plan real-seam rows (nonexistent root) alongside the mocks so the new sibling clears 85% line coverage; the `& git` call lines are the only lines no unit test can reach.

---

## 8. Existing tests affected

No existing `It` name needs to change. Behavior-preserving edits (adding a mock of the new git seam, and of the presence seam where the root is the executing worktree) are needed where a non-epic preflight failure can reach the exemption:

| Suite | Rows reaching the exemption | Required edit |
|---|---|---|
| `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | "blocks gh pr create --body-file when the checkpoint is missing" (`:49-60`); "blocks gh pr create --body-file with the summarized output when --require-pr-creation-ready fails" (`:62-74`). Resolved root is `(Get-Location).Path` (`:39-41`), so presence and git would read the executing worktree | Mock the presence seam and `Invoke-PrAuthorDocsOnlyGit` in `BeforeAll`; assertions unchanged (`-Match`) |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | "pr-author R3 denies with the preflight reason when the checkpoint is absent at the resolved target" (`:178-191`), fixture `shared/item-no-checkpoint` lies inside the repository, so real git would run against the executing worktree | Mock `Invoke-PrAuthorDocsOnlyGit` in `BeforeAll`; assertion `-BeLike 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED*'` unchanged. Rows R3 not-ready, R4, R7 (unparseable, empty), and the genuine-absence row have a checkpoint file present and stop at `CHECKPOINT_PRESENT` without git |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` (out of family) | "blocks a not-ready checkpoint with ORCHESTRATOR_STATE_PREFLIGHT_FAILED through the default path" (`:307-326`), resolved root is a nonexistent directory (`:316-319`) | No edit if the default git seam returns failure for a nonexistent root without spawning git; assertion `-Match` unchanged |

Suites that mock the preflight to succeed (`Tests.ps1:155-383`, `TriggerScoping.Tests.ps1:222`, `Issue824.Tests.ps1:109`, `ItemArtifactRoot.Tests.ps1:55`, `TargetResolution.Tests.ps1:56-120`, `epic-base-branch.Tests.ps1:114,157`, `EpicScope.Tests.ps1:95`) never reach the exemption. `ItemArtifactRoot.Tests.ps1:339` and `EpicScope.Tests.ps1:125,141` assert the epic-path denial, which is unchanged. Out-of-family suites that dot-source the hook (`hook-command-invocation.Issue824Regression.Tests.ps1:210-298`, `hook-command-consumers.Issue824.Tests.ps1:108-128`, `PreToolUseSchema.Contract.Tests.ps1:59-60`) do not reach the non-epic preflight failure. `hook-dependency-failure.*` suites derive the dependency graph dynamically and pick up the new nested dot-source automatically; run them to confirm.

---

## 9. Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for a `spec.md` acceptance criterion in this research. Counts above (line counts, file lists) are descriptive context for the planner and are not acceptance-criterion assertions.

---

## 10. Automation Feasibility

Fully automatable.

- All production changes are PowerShell edits in the pr-author hook family, one new sibling file, bundle mirror copies, and one `core.json` entry. All tests are Pester suites that use existing mocking patterns and need no real git, network, or temporary files.
- PowerShell verification is restricted to the PoshQC MCP tools `run_poshqc_format`, `run_poshqc_analyze`, and `run_poshqc_test`, plus CI evidence. No `sh`, `bash`, or `pwsh` wrapper runs Pester or PSScriptAnalyzer.
- PoshQC MCP results carry a summary only. Per-file coverage for AC-9 must be read from the CI `poshqc-test-results` artifact (`artifacts/pester/powershell-coverage.xml`, `.github/workflows/_poshqc.yml:44-52`).
- AC-4 parity: the Python parity test runs in CI. Locally it can fail on gitignored `.claude/state/` files (#510), so a `git hash-object` comparison should be recorded as well.
- Batch budget: `enforce-powershell-batch-budget.ps1:296-317` caps production PowerShell files on the non-orchestrated path. This change touches four or more production PowerShell files plus mirrors, so it belongs on the orchestrated path, or mirror copies must be made with `Copy-Item` rather than Write/Edit.
- Scope exception requiring an operator-visible plan statement: AC-6 (L20) edits `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`, which is outside the pr-author family.
