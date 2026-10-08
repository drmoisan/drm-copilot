# Research: pr-author and merge gates read session-root files (#850, bundled #788, #789, #851)

- Feature folder: `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/`
- Epic: #852 (enforcement-hook-precision), child C3
- Branch researched: `bug/pr-author-and-merge-gates-read-session-root-files-850` (branched from `origin/epic/enforcement-hook-precision-integration`), files as present in this worktree on 2026-10-08, before C1a (#824) merges.
- Mode: research only. No source, test, or configuration file was changed.

## Method and citation convention

Every `file:line` citation below was re-derived in this worktree by reading the file with the Read tool or by a Grep over the tree. Line counts are the last numbered content line the Read tool reported; the plan must re-measure them with `(Get-Content -LiteralPath <file>).Count` (scratch script A4 of the #690 plan) after C1a merges, because C1a edits three of the files.

## Key Findings (summary)

1. The pr-author gate resolves its checkpoint through `WorktreeItemResolution.psm1` (`Resolve-WorktreeItemTarget`), not through `WorktreeRunResolution.psm1` as the delegation prompt assumed. The resolved target already exposes `WorktreeRoot`, `Status`, `ReasonCode`, and `Detail`; only `CheckpointPath` is consumed today. Every PR-artifact read (summary existence, summary last-write, body bytes, receipt text) still uses a relative path bound to the process directory.
2. The resolution happens after Case C (`PR_CONTEXT_MISSING`) and after the context-existence probe, so resolution must move ahead of Case C for the summary to be read beneath the resolved root. That changes deny precedence for one input class (a `--body-file` call with no resolvable target and no session-root summary now denies with the resolution code instead of `PR_CONTEXT_MISSING`).
3. `gh` resolves a relative `--body-file` against its own process directory. When the target is `OtherWorktree`, a relative `artifacts/pr_body_<N>.md` makes the hook verify worktree A's bytes while `gh` posts the session root's bytes (or fails). The stale copies left in the session root by the 2026-10-07 workaround make this an active integrity gap, not a theoretical one. Recommendation: for `OtherWorktree`, accept only the absolute canonical body path beneath the resolved root.
4. The merge gate has no resolver for an item checkpoint keyed by pull request number. `Resolve-WorktreeRunTargetByRecord` accepts only `epic` and `parallel` kinds, and `WorktreeRunResolution.psm1` is at 497 of 500 lines. The recommended home for an item-by-PR resolver is `WorktreeItemResolution.psm1` (407 lines), keyed on `pr_gate.pr_number` and `standalone_merge_authorizations[].pr_number`.
5. #788: `Test-ChildCheckpointPrGateBinding` returns `$true` (unbound) when `pr_gate` or `pr_gate.pr_number` is absent. Row M5 of `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` asserts exactly that and must flip to deny.
6. #789 CR-4 can be fixed in place in `WorktreeRunResolution.psm1` with zero net lines; CR-5 is a two-line restructure of the parallel removal gate's final deny. The epic removal gate carries the same doubled-token construct (not named in #789).
7. #851: at the final deny the epic removal gate holds both target results and both parsed checkpoints, but not the checkpoint paths it read and not the parallel record it matched; both must be surfaced from the read helpers to name them. The resolver and the gate read each checkpoint twice and compare paths with different case rules.
8. C1a overlaps C3 directly at Check 1 of the pr-author receipt verification (#733/#715 accepts quoted or absolute `--body-file` values) and adjacently at the removal gates' operand extraction and final deny. A pre-edit re-verification task is required.

---

## 1. #850 pr-author gate

### 1.1 Current reads of PR artifacts

| Read | Location | Path form |
|---|---|---|
| Summary path constant | `.claude/hooks/enforce-pr-author-skill.ps1:48` (`$script:PrContextArtifactPath = 'artifacts/pr_context.summary.txt'`) | relative literal |
| Summary existence seam `Get-PrContextArtifactExistence` | `.claude/hooks/enforce-pr-author-skill.ps1:55-67` (`Test-Path -LiteralPath $script:PrContextArtifactPath` at :66) | relative, follows PowerShell location |
| Existence probe call | `.claude/hooks/enforce-pr-author-skill.ps1:185-186` (called for every command, before `Get-PrAuthorBypassReason`) | relative |
| Body bytes seam `Get-PrBodyFileBytes` | `.claude/hooks/enforce-pr-author-skill.ps1:69-95` (`[System.IO.File]::ReadAllBytes($BodyFilePath)` at :94) | relative, follows the .NET current directory, not the PowerShell location (see `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1:50-53`) |
| Receipt text seam `Get-PrAuthorReceiptContent` | `.claude/hooks/enforce-pr-author-skill.ps1:97-122` (`Get-Content` at :121) | relative |
| Summary last-write seam `Get-PrContextSummaryLastWriteUtc` | `.claude/hooks/enforce-pr-author-skill.ps1:124-144` (`Get-Item ... LastWriteTimeUtc` at :143) | relative |
| Helper header stating the summary path "stays" process-relative | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:18-24` | documentation |
| Check 1 canonical-path regex | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:171` (`-cnotmatch '--body-file\s+artifacts/pr_body_(\d+)\.md\b'`) | relative literal only |
| Body and receipt path composition | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:175-177` | relative strings |
| Receipt read (Check 2) | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:180` | relative |
| Body read (Check 4) | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:203` | relative |
| Freshness comparison (Check 5) | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:221-234` (summary read at :231, comparison at :232) | relative |
| Case C `PR_CONTEXT_MISSING` | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:333-336` | uses the up-front `ContextExists` flag |

### 1.2 How the target is resolved today

- `Resolve-PrAuthorWorktreeTarget` (seam) at `.claude/hooks/enforce-pr-author-skill-helpers.ps1:51-72` calls `Resolve-WorktreeItemTarget -Text $CommandText -SessionRoot (Get-Location).Path` (:71).
- `Resolve-WorktreeItemTarget` is in `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:351-396`. It reads two identity signals from the command text: the canonical issue sentence (`Canonical issue number for this feature is #N`, pattern at :40) and a branch signal from `Find-WorktreeResolutionBranchSignal` (`.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:164-185`, pattern at :61: `--head`, `--branch` (space or `=`), or `branch:`). No identity yields `NoTarget` (:384-388); several issue numbers yield `Ambiguous` (:380-383). A branch selects the single live worktree with that branch checked out (`Resolve-WorktreeItemTargetByBranch`, :260-317).
- `Get-PrAuthorTargetCheckpointResolution` (`.claude/hooks/enforce-pr-author-skill-helpers.ps1:74-121`) maps `SessionRoot`/`OtherWorktree` to `Get-WorktreeItemCheckpointPath -WorktreeRoot $target.WorktreeRoot` (:113-115) and the unresolved states to a reason beginning with `$target.ReasonCode` (:117). It returns only `CheckpointPath` and `Reason`.
- It is invoked once, at `.claude/hooks/enforce-pr-author-skill-helpers.ps1:356`, inside `elseif ($hasBodyFile -and $ContextExists)` (:355). The result is stored in `$script:OrchestratorStateCheckpointPath` (:362) and reused by the preflight (:364) and Check 6 (:377, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:107`).
- The epic-scope branch (`.claude/hooks/enforce-pr-author-skill-helpers.ps1:342-354`) calls `Resolve-EpicScopeCheckpoint -Text $CommandText -SessionRoot (Get-Location).Path` (:344). That module locates the epic checkpoint through `Resolve-WorktreeEpicTarget` (`.claude/lib/worktree-resolution/EpicScopeResolution.psm1:353`), which is the only place `WorktreeRunResolution.psm1` participates (imported by `EpicScopeResolution.psm1:42`). In epic scope, `Get-PrAuthorTargetCheckpointResolution` is not called.

The resolved target object (constructed only by `New-WorktreeResolutionTargetResult`, `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:66-135`) exposes `Status`, `WorktreeRoot` (normalized forward-slash, populated only for `SessionRoot`/`OtherWorktree`), `SessionRoot`, `Signal`, `SignalValue`, `Candidates`, `ReasonCode` (`TARGET_WORKTREE_AMBIGUOUS` or `TARGET_WORKTREE_NOT_DERIVABLE` for the unresolved states), and `Detail`.

The epic-scope result (`New-EpicScopeResult`, `.claude/lib/worktree-resolution/EpicScopeResolution.psm1:88-111`) exposes `CheckpointPath` beneath the epic target root (:360), but its `WorktreeRoot` field is the session's ascended root (`$effectiveRoot`, :335 and :380), not the epic target root.

### 1.3 Ordering constraint

`ContextExists` is computed in `Invoke-PrAuthorSkillDecision` (`.claude/hooks/enforce-pr-author-skill.ps1:185`) before any resolution, and Case C (`.claude/hooks/enforce-pr-author-skill-helpers.ps1:334`) runs before resolution (:356). The summary can therefore be read beneath the resolved root only if resolution moves ahead of Case C. Cases A and B (:315-324) and the `gh pr edit` no-body allow (:326-331) read no file and need no resolution.

### 1.4 Recommended design (single resolution per invocation)

1. Remove the up-front existence probe from `Invoke-PrAuthorSkillDecision` and the `-ContextExists` parameter from `Get-PrAuthorBypassReason` and `Test-PrAuthorBypassRequired` (`.claude/hooks/enforce-pr-author-skill.ps1:239-261`). These are in-repo, dot-sourced functions; the callers are the hook and the test suites listed in section 7.
2. In `Get-PrAuthorBypassReason`, after Cases A/B and the edit no-body allow, and only when `--body-file` is present, resolve the artifact root exactly once:
   - Epic scope: call `Resolve-EpicScopeCheckpoint` (moved from :344 to before Case C). When `IsEpicScope`, the artifact root is the worktree that holds the epic checkpoint. Derive it from `$epicScope.CheckpointPath` by removing the `Get-EpicScopeCheckpointRelativePath` suffix (exported by `EpicScopeResolution.psm1`, export list at :383+); both strings are produced by `Join-WorktreeResolutionPath`, so the derivation is deterministic and needs no second resolution and no module change.
   - Otherwise: call `Get-PrAuthorTargetCheckpointResolution`, extended to also return `WorktreeRoot` and `Status`. An unresolved target returns its existing reason (leading `TARGET_WORKTREE_*` code) before Case C.
3. Compose the three artifact paths beneath the root with `Join-WorktreeResolutionPath` (already imported via `WorktreeTargetResolution.psm1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1:42`): `artifacts/pr_context.summary.txt`, `artifacts/pr_body_<N>.md`, `artifacts/pr_body_<N>.receipt.json`. Pass the absolute paths to the four seams (the summary seams gain a mandatory `-Path` parameter; the body and receipt seams already take a path).
4. Case C evaluates existence of the composed summary path. Keep the leading token and the relative literal, and add the worktree, following #690 decision D14 (`docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md:72`): `PR_CONTEXT_MISSING: 'artifacts/pr_context.summary.txt' in worktree '<root>' is absent. ...`.
5. Checks 2-5 read beneath the same root; Check 5 compares the receipt's `created_at` with the summary at the same root. Check 6 is unchanged (it already receives the resolved checkpoint path).
6. `$script:PrContextArtifactPath` stays as the relative literal used in messages and as the repo-relative composition input.

New deny precedence on the `--body-file` path: resolution reason (`TARGET_WORKTREE_*`) -> `PR_CONTEXT_MISSING` -> `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` -> Check 1 ... Check 6. Before this change, a `--body-file` call with no session-root summary returned `PR_CONTEXT_MISSING` even when the target was unresolvable. Both orders deny; the spec should state the new order.

### 1.5 Check 1 (`--body-file artifacts/pr_body_<N>.md`) once resolved

- Interpretation: the relative canonical literal names `artifacts/pr_body_<N>.md` beneath the resolved item worktree, not beneath the hook's process directory.
- `gh` resolves a relative `--body-file` against the process directory of the `gh` command, which in the reported topology is the session root B. With `Status = OtherWorktree`, a relative body path makes the hook verify A's bytes and receipt while `gh` reads B's file. B still holds copies from the 2026-10-07 workaround (`issue.md:39`), so the receipt check would pass against A and `gh` would post B's stale body. This defeats the receipt's stated purpose (bind the posted bytes to the receipt, `.claude/hooks/enforce-pr-author-skill.ps1:35-41`).
- Recommendation: Check 1 accepts (a) the relative canonical literal only when `Status = SessionRoot` (or epic scope with the epic root equal to the session worktree), and (b) the absolute canonical path whose normalized form equals `Join-WorktreeResolutionPath -WorktreeRoot <root> -RepoRelativePath "artifacts/pr_body_<N>.md"` for any resolved status. A relative literal with `Status = OtherWorktree` denies with `PR_BODY_PATH_NONCANONICAL` and a detail that names the absolute path to pass. Path equality: normalize both sides with `ConvertTo-WorktreeResolutionNormalizedPath` and compare `OrdinalIgnoreCase` when either side is drive-rooted or UNC (`//`), `Ordinal` otherwise (the same rule CR-4 establishes in section 4).
- `cd <A> && gh pr create ...` would make `gh` read A, but cd-chained commands are refused by the worktree isolation guard in agent worktrees (memory note "worktree-isolation-guard-denylist"; #690 plan Shell route, `plan.2026-09-29T22-17.md:106`), so the absolute form is the practical route.
- C1a (#733/#715) is expected to make Check 1 accept quoted or absolute values that "resolve to the canonical `artifacts/pr_body_<N>.md`" (`docs/features/potential/promoted/2026-09-27-pr-author-allowlist-chaining-and-false-positives.md:56`). C3 must bind that absolute form to the resolved root rather than to the session root. See section 8.

### 1.6 Which operands drive target resolution

- `--head <branch>` (or `--head=<branch>`), `--branch <branch>`, and a `branch:` label anywhere in the command text (`WorktreeTargetResolution.psm1:61`); the match is a whole-text regex, not segment-scoped.
- The canonical issue sentence (`WorktreeItemResolution.psm1:40`).
- Not used: `--base`, the `--body-file` path, `-H` (the short form of `--head` is not recognized by the pattern), and the positional PR number of `gh pr edit`.
- Pre-existing limitation, out of scope: `gh pr edit` has no `--head` option, so `gh pr edit <N> --body-file ...` resolves `NoTarget` unless the text carries the canonical issue sentence or a `branch:` label. Today that deny occurs after Case C; after the change it occurs before Case C. Candidate follow-up: resolve `gh pr edit <N>` by the item-by-PR resolver proposed in section 2.

---

## 2. #850 merge gate

### 2.1 Current flow (`.claude/hooks/enforce-epic-merge-gate.ps1`)

- Scope filter: `:342-355`. PR number: `Get-EpicMergeGateCommandPrNumber` `:96-140`.
- Session root: `$sessionRoot = Get-EpicMergeGateSessionWorktreeRoot` (`:358`), defined in `.claude/hooks/enforce-epic-merge-gate-resolution.ps1:117-129` as `(Resolve-WorktreeOperandTarget -Path '' -SessionRoot (Get-Location).Path).WorktreeRoot`.
- Child checkpoint: read unconditionally beneath the session root (`:362`); child allow requires `Test-ChildCheckpointAllowsEpicMerge` (`:142-169`) and `Test-ChildCheckpointPrGateBinding` (`:363-366`).
- Epic and parallel branches: with an explicit PR number, each run kind is resolved by record through `Resolve-EpicMergeGateRunTarget` (`enforce-epic-merge-gate-resolution.ps1:131-150` -> `Resolve-WorktreeRunTargetByRecord -RecordField pr_number`), `:374-379`; read at `:381` and `:386`.
- Standalone branch (#670): `:393-403`. It evaluates `@($childCheckpoint, $epicCheckpoint, $parallelCheckpoint)` (`:395`); the child slot is always the session root's per-feature checkpoint. Deny text: `EPIC_MERGE_GATE_BLOCKED: [<code>: <epic detail>; <parallel detail>; ]<standalone code>: <message>` (`:400-402`, prefix built by `Get-EpicMergeGateUnresolvedReason`, `enforce-epic-merge-gate-resolution.ps1:191-221`).
- Bare command (no PR number): every checkpoint is read beneath the session root (`:368-373`); this is intentional (`:368-369`) and pinned by row M6 (`tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:139-153`).

### 2.2 Why the existing resolver cannot key the item checkpoint

- `Resolve-WorktreeRunTargetByRecord` (`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1:405-448`) validates `-Kind` to `epic|parallel` (:426) and reads only run checkpoints that carry the matching `route_id` (`Get-WorktreeRunCheckpoint`, :179-192). Record fields searched: epic `features[].pr_number` and `epic_merge_pr.pr_number`, parallel `items[].pr_number` (`Test-WorktreeRunCheckpointRecord`, :376-403).
- An item checkpoint (`artifacts/orchestration/orchestrator-state.json`) has no record array and no fixed `route_id`. The fields that carry the item's own PR number are:
  - `pr_gate.pr_number` (key set `pr_number, pr_url, head_branch, head_sha`, `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1:71`); required only for routes with `requires_pr_gate = $true` (`large`, `epic`; `small`, `remediation`, `preparation` are `$null`, `parallel` is `$false`: `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1:51-93`).
  - `standalone_merge_authorizations[].pr_number`, a positive JSON integer per `.claude/rules/orchestrator-state.md:207,215`.
  - `pr_author_receipt` is recorded by the orchestrator (`.claude/skills/orchestrate/SKILL.md:190`) but its shape is not validated and carries no defined `pr_number`; it is not a reliable key.
- `WorktreeRunResolution.psm1` is 497 lines (export list ends at :497). Adding an `item` kind (route-agnostic read, two record fields) would exceed 500.

### 2.3 Recommended design

- Add `Resolve-WorktreeItemTargetByPrNumber -PrNumber <long> -SessionRoot <path>` to `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (407 lines). It enumerates `Get-WorktreeItemLiveRoot` (:179-214), reads each root's item checkpoint through the existing seam `Get-WorktreeItemCheckpointText` (:131-149), and matches when `pr_gate.pr_number` or any `standalone_merge_authorizations[].pr_number` equals N. Zero matches -> `NoTarget`; one -> `ConvertTo-WorktreeItemResolvedResult` (:216-256); several -> `Ambiguous` with the handoff remedy, matching `Resolve-WorktreeItemTargetByIssue` (:321-349), which also does not tie-break. The module's "only filesystem read is the checkpoint-text seam" property (:23-24) is preserved.
- In `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, import `WorktreeItemResolution.psm1` inside the existing import guard (:30-36) and add a seam `Resolve-EpicMergeGateItemTarget -PrNumber` (mockable like `Resolve-EpicMergeGateRunTarget`). Hooks cannot see nested-module exports (#690 decision D2, `plan.2026-09-29T22-17.md:60`), so the explicit import is required. Follow #690 rule LH-6 on import order (`plan.2026-09-29T22-17.md:119`) and prove with a test that a `-ModuleName WorktreeItemResolution` mock is observed by the gate.
- In `Invoke-EpicMergeGateDecision`, with an explicit PR number, resolve the item target once and read the child checkpoint beneath its `WorktreeRoot`; when unresolved, the child checkpoint is `$null` (child and standalone-child slots cannot allow). A bare command keeps the session-root read.
- `Get-EpicMergeGateUnresolvedReason` gains the item target so that, when no branch allows and the item, epic, and parallel targets are all unresolved, the deny prefix carries the code (ambiguity wins, as #690 D8 established, `plan.2026-09-29T22-17.md:66`) and the item detail first.
- Record field that keys the resolution for `gh pr merge <N>`: `pr_gate.pr_number` and `standalone_merge_authorizations[].pr_number` in the item checkpoint. Epic and parallel continue to key on their existing record fields.

Line budget: gate file 459 lines, about +6 to +10 lines in the decision function and header; resolution sibling 221 lines, about +40; `WorktreeItemResolution.psm1` 407 lines, about +45 to +55. All stay under 500.

---

## 3. #788 child-branch PR-number binding

- Current unbound returns: `.claude/hooks/enforce-epic-merge-gate-resolution.ps1:174-176` (bare command or `$null` checkpoint), `:177-179` (no `pr_gate`), `:181-183` (no `pr_gate.pr_number`). Only when both numbers are present are they compared (:184-188). The gate calls it at `.claude/hooks/enforce-epic-merge-gate.ps1:363-364`.
- Proposed binding (replaces `Test-ChildCheckpointPrGateBinding`, same file, pure function):
  - No command PR number -> `$true` (bare command, unchanged).
  - `$null` checkpoint -> `$false` (the child allow is already false for `$null`, `enforce-epic-merge-gate.ps1:158-160`).
  - `pr_gate.pr_number` present -> must parse and equal N (a recorded `pr_gate` is authoritative for the item's PR).
  - Otherwise -> `$true` only when a `standalone_merge_authorizations` entry has a positive JSON-integer `pr_number` equal to N (same predicate as `Test-StandalonePositiveJsonInteger`, `enforce-epic-merge-gate-authorization.ps1:86-108`).
  - Otherwise -> `$false`.
- The gate re-checks the binding on the checkpoint it reads, even though the resolver selected the worktree by N, because the resolver and the gate read the file twice (resolver seam, then `Get-ChildOrchestratorCheckpointContent`), and a write between the two reads must not produce an unbound allow.
- Deny reason: no new token. When no live item checkpoint records N (covers both "mismatch" and "no PR number recorded at all"), the item resolver returns `NoTarget`, and the final deny reads `EPIC_MERGE_GATE_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE: <item detail naming pull request N and the two fields>; ...` followed by the unchanged standalone reason. When the item checkpoint is found but its `pr_gate.pr_number` differs, the child branch declines and the existing final deny text applies. Leading token `EPIC_MERGE_GATE_BLOCKED:` is preserved (epic Shared Design, `docs/features/epics/enforcement-hook-precision/epic.md:174`).
- Behavior change to call out in the spec: an epic child on a route that records neither `pr_gate` nor a standalone record (for example `small`) can no longer merge with an explicit PR number through the child branch. The remedy is to record `pr_gate` (or a standalone record). A bare `gh pr merge --merge` is unchanged.
- Existing tests asserting the unbound behavior:
  - `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:127-137` (M5, "allows a child merge whose checkpoint records no pr_gate") must flip to deny with `TARGET_WORKTREE_NOT_DERIVABLE`.
  - M3 (:103-113) and M4 (:115-125) remain deny and allow, but need the new item seam mocked (or the real resolver over mocked WIR seams).
  - M9 (:185-199) places the standalone record in the child slot; it needs the item seam to resolve to the root whose checkpoint holds it.
  - Child-allow rows in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:42-61` and `:446-454` use bare commands and are unaffected.

---

## 4. #789 CR-4 and CR-5

### CR-4 `Test-WorktreeRunPathEqual`

- Location: `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1:342-358`. Comment `:342-343` states "case-insensitive only for drive-letter paths". Normalization `:353-354` (backslash to slash, trailing slash trimmed; repeated separators are not collapsed, so `\\server\share` becomes `//server/share`). Case selection `:355-356`: `OrdinalIgnoreCase` only when a side matches `^[A-Za-z]:`.
- Only caller: `Test-WorktreeRunCheckpointRecord` `:400` (worktree_path records).
- Fix in place with zero net lines: change `:355` to treat a side matching `^([A-Za-z]:|//)` as case-insensitive, and update the comment at `:342-343`. Slash-rooted POSIX paths (single leading `/`) stay `Ordinal`.
- Existing tests: `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1:217-226` (B11, drive paths case-insensitive) and `:228-237` (B12, slash-rooted paths case-sensitive, expects `NoTarget`). B12 must keep passing; a new row (for example B14) asserts `//Server/Share/x` and `//server/share/X` resolve `OtherWorktree`. The same suite pins the export set (X1, `:419-432`), so CR-4 must not add an export. Suite length 441 lines.

### CR-5 doubled `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token

- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:415-420`: the prefix at `:418` begins with the token, and the returned string at `:420` begins with the token again.
- Fix: build the prefix as `"$code: $detail. "` and emit `'PARALLEL_WORKTREE_REMOVAL_BLOCKED: ' + $prefix + "git worktree remove for '...' ..."`. With a resolved target the prefix is empty, so the text is byte-identical to today, and the exact-text row `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1:449-457` keeps passing. Y3 (`tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1:103-115`) asserts `^PARALLEL_WORKTREE_REMOVAL_BLOCKED: ` and the no-target code, and keeps passing. A new row counts token occurrences when both kinds resolve `NoTarget`.
- Same construct, not named in #789: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:398-403` (prefix at :401 starts with `EPIC_WORKTREE_REMOVAL_BLOCKED:`, final string at :403 starts with it again). #851 rewrites this deny; the recommendation is to apply the CR-5 shape there in the same change so the diagnostics are not appended to a doubled token. The spec should state this explicitly, because it is outside #789's literal text.

---

## 5. #851 epic worktree removal gate (diagnostics only)

### 5.1 Decision flow (`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`)

1. Import guard deny (`:334-337`), envelope anomaly deny (`:339-345`), no-command allow (`:347-350`), scope filter allow (`:355-357`).
2. Operand: `Get-EpicWorktreeRemovalCommandPath` (`:111-150`); `--force` returned in place of a missing operand (`:146-148`); `$null` when neither.
3. `Read-EpicWorktreeGateRunCheckpoint` for epic, then parallel (`:363-364`). Each resolves through `Resolve-EpicWorktreeGateRunTarget` (`enforce-epic-worktree-removal-gate-resolution.ps1:94-113`, `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path`) and, when resolved, re-reads the checkpoint beneath the root through the gate seam (`enforce-epic-worktree-removal-gate-resolution.ps1:115-144`; path composed at :136, read at :137, parsed at :138). The path is not returned (:140-143).
4. Either target `Ambiguous` -> deny with the code and detail (`:365-369`).
5. Epic allow: `Find-EpicWorktreeFeatureRecord` + `Test-EpicWorktreeRemovalAllowed` (`:372-375`).
6. Parallel allow: `Test-ParallelCheckpointAllowsWorktreeRemoval` (`:377-380`); it returns a bool and does not expose the matched item record (`:224-286`).
7. Manifest branch (`:392-396`).
8. Final deny (`:398-403`), with the `NoTarget` prefix when both kinds are `NoTarget`.

### 5.2 Data available at the final deny

| Datum | Available today | Source |
|---|---|---|
| Epic and parallel target status, root, code, detail | yes | `$epicRead.Target`, `$parallelRead.Target` |
| Parsed epic and parallel checkpoints (or `$null`) | yes | `$epicRead.Checkpoint`, `$parallelRead.Checkpoint` |
| Matched epic `features[]` record and its `merge_status` | yes | `$featureRecord` (`:372`) |
| Matched parallel `items[]` record and its `merge_status` | no | must be located again (for example with a record finder; the parallel gate already has one, `Find-ParallelWorktreeItemRecord`, `enforce-parallel-worktree-removal-gate.ps1:213-264`, but it is not visible to the epic gate) |
| Checkpoint path read for each kind | no | computed at `enforce-epic-worktree-removal-gate-resolution.ps1:136` but not returned; add a `Path` property to the returned object |
| Whether the re-read parsed | derivable | resolved status with `$null` checkpoint means absent or unparseable on the second read |
| Extracted operand | yes | `$worktreePath` |

### 5.3 Double read and comparison-rule mismatch

- First read: `Resolve-WorktreeRunTargetByRecord` reads every live root's run checkpoint through `Get-WorktreeRunCheckpointText` (`WorktreeRunResolution.psm1:442-446`, `:99-119`) and keeps only checkpoints with the kind's `route_id` (:179-192). Second read: the gate seam beneath the resolved root (`enforce-epic-worktree-removal-gate-resolution.ps1:137`). A write between them can change the verdict without any trace in the deny text.
- Path equality differs: the resolver uses `Test-WorktreeRunPathEqual` (trimmed, `Ordinal` for slash-rooted paths, `WorktreeRunResolution.psm1:352-357`); the gate uses PowerShell `-eq` (case-insensitive, untrimmed, `enforce-epic-worktree-removal-gate.ps1:180,189-190,263,275`). Neither resolves a relative operand. A relative operand, or a slash-rooted operand that differs in case from the recorded path, makes the resolver return `NoTarget` and the gate deny.
- These are unverified candidate causes for the unreproduced #851 deny. The diagnostics proposed below would distinguish them in a recurrence.

### 5.4 Proposed deny text

Keep the leading token once, then the existing sentence, then a diagnostics clause, for example: `EPIC_WORKTREE_REMOVAL_BLOCKED: [<code>: <detail>. ]git worktree remove for '<operand>' requires ... No checkpoint authorized this removal. Diagnostics: epic run <Status> (checkpoint '<path>' | not read), <merge_status '<value>' | no matching features[] record | checkpoint absent or unparseable>; parallel run <Status> (...), <...>.` Build the clause in a pure helper in `enforce-epic-worktree-removal-gate-resolution.ps1` (144 lines) so the gate file (457 lines) grows by only a few lines. The decision is unchanged; the exact-text row `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1:480-488` must be updated (that suite is 497 lines, so new rows go in a new suite file).

---

## 6. Copies, mirrors, and line counts

### 6.1 Copy and mirror inventory

| File | Lines | Codex copy | Bundled mirror (byte-identical required) |
|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill.ps1` | 314 | none | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 384 | none | same tree, `-helpers.ps1` |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 144 | none | same tree (not expected to change) |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 459 | `.codex/hooks/enforce-epic-merge-gate.ps1` (379 lines) | same tree |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | 221 | none | same tree |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 443 | none | same tree (not expected to change) |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 457 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` (177 lines) | same tree |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 144 | none | same tree |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 474 | none | same tree |
| `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | 497 | none | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | 407 | none | same tree |

- The two Codex hooks are independent implementations, not copies: they read checkpoints from `$PSScriptRoot`-derived repository roots (`.codex/hooks/enforce-epic-merge-gate.ps1:366-370`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1:162-165`), import no worktree-resolution module, and the Codex merge gate's child branch has no PR binding at all (`.codex/hooks/enforce-epic-merge-gate.ps1:156-159`). No test requires Claude/Codex byte identity for these files. #690 kept `.codex/**` out of scope (`plan.2026-09-29T22-17.md:27`). Recommendation: leave both Codex hooks unchanged and record the Codex session-root reads and the Codex #788 equivalent as a follow-up candidate. If the Codex files are not changed, their bundled mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` are unaffected.
- Parity enforcement:
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`): every distributable `.claude` file must exist in the bundle with identical content. Known local-only failure mode KL-510 (gitignored `.claude/state/**`), described at `plan.2026-09-29T22-17.md:97`.
  - `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1:37-104`: every `.claude/lib/worktree-resolution/*.psm1` is listed in `core.json` exactly once, is registered in the suite's expected list (four copies of the list, :27-34, :38-45, :53-60, :84-91), and is SHA-256-identical to its bundle copy. A new module in that folder requires all three.
  - `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`: pack manifest completeness for `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (current hook entries at :30-35, :48-51; modules at :194, :197).
  - `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228`: Codex repo files must equal their bundle copies (relevant only if a `.codex` file changes).
- Mirrors are produced by `cp <primary> <mirror>` after the primary is final (#690 convention, `plan.2026-09-29T22-17.md:108`).

### 6.2 500-line cap projection

| File | Now | Estimated after C3 | Risk |
|---|---|---|---|
| `WorktreeRunResolution.psm1` | 497 | 497 (CR-4 in place) | Any addition beyond 3 lines breaches the cap; nothing else may be added here. |
| `enforce-parallel-worktree-removal-gate.ps1` | 474 | 474 (CR-5 net zero) | C1a may add lines first; re-measure. |
| `enforce-epic-merge-gate.ps1` | 459 | about 468 | Keep logic in the resolution sibling. |
| `enforce-epic-worktree-removal-gate.ps1` | 457 | about 465 | Keep the diagnostics builder in the resolution sibling. |
| `WorktreeItemResolution.psm1` | 407 | about 455 | If it exceeds about 490, place the PR resolver in a new module (requires the manifest-test list, `core.json`, and mirror updates). |
| `enforce-pr-author-skill-helpers.ps1` | 384 | about 430-445 before C1a growth | If C1a plus C3 push it past about 480, move artifact-root composition and Check 1 root binding into a new dot-sourced sibling (for example `enforce-pr-author-skill.artifact-root.ps1`, following the `.epic-base-branch.ps1` precedent), registered in `core.json` and mirrored. |
| `enforce-pr-author-skill.ps1` | 314 | about 320 | none |
| `enforce-epic-merge-gate-resolution.ps1` | 221 | about 265 | none |
| `enforce-epic-worktree-removal-gate-resolution.ps1` | 144 | about 200 | none |

Test files near the cap: `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` (497), `enforce-pr-author-skill.Tests.ps1` (456), `enforce-parallel-worktree-removal-gate.Tests.ps1` (466), `WorktreeRunResolution.Record.Tests.ps1` (441), `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` (399). New rows go in new suite files where a suite cannot absorb them.

---

## 7. Tests

### 7.1 Existing suites per changed file

- pr-author: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, `.TargetResolution.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `.EpicScope.Tests.ps1`, `.OrchestratorStatePreflight.Tests.ps1`, `.Payload.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `enforce-pr-author-skill.epic-base-branch.Tests.ps1`, `.epic-base-branch.TriggerScoping.Tests.ps1`; plus the cross-folder `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1:288-326` (dot-sources the hook and mocks `Get-PrContextArtifactExistence` and `Resolve-PrAuthorWorktreeTarget`).
- Merge gate: `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.AuthorizationFields.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`; plus `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` (default mocks at :69-70).
- Removal gates: `enforce-epic-worktree-removal-gate.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`; `enforce-parallel-worktree-removal-gate.Tests.ps1`, `.EpicAuthorization.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`; `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` (default mocks at :222, :275).
- Modules: `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1`, `.Record.Tests.ps1`, `.Signal.Tests.ps1`, `WorktreeItemResolution.Tests.ps1`, `WorktreeResolution.Manifest.Tests.ps1`.
- Structural guard: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1:38-47` lists eight suites (two are pr-author suites) that must, in the outermost `BeforeAll`, import `EpicScopeResolution.psm1` and `WorktreeRunResolution.psm1` without `-Force` and mock their checkpoint-text seams to `$null`. Any new pr-author suite that reaches `Resolve-EpicScopeCheckpoint` should follow that pattern and be added to the list.

### 7.2 Seams and isolation patterns in use

- `TestDrive` is not used anywhere under `tests/scripts` (Grep count 0). Temporary files are prohibited by policy; no suite creates one.
- Synthetic roots of the form `/synthetic-worktrees/<name>` with read seams mocked to return in-memory JSON (`enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:43-53`), and the real record resolver over mocked `Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution` and `Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution` keyed by path (`:55-69`).
- A one-line default resolution mock in each suite's `BeforeAll` returning a `SessionRoot` target at `/synthetic-worktrees/default-session` (for example `enforce-epic-merge-gate.Tests.ps1:12`, `enforce-parallel-worktree-removal-gate.Tests.ps1:22`, #690 decision D10).
- Committed read-only fixtures under `tests/fixtures/worktree-resolution/` with `Invoke-WorktreeResolutionFixtureCall` setting both the PowerShell location and the .NET current directory and restoring them in `finally` (`tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1:45-78`). Present fixtures: `pr-author/session-root/` and `pr-author/item-own-ready/` both hold `pr_body_1.md`, `pr_body_1.receipt.json` (`created_at` 2099-01-01, so it is always newer than a checked-out summary), and `pr_context.summary.txt`; `pr-author/item-own-not-ready/` and `pr-author/item-own-epic-mode/` hold only a checkpoint; `shared/item-no-checkpoint/` holds only the summary.

### 7.3 Existing rows that change behavior

- `enforce-pr-author-skill.WorktreeResolution.Tests.ps1:195-214` (R4 epic base-branch row): its comment states the resolved worktree carries no artifact files and the receipt, body, and context come from the working directory. After the change it would deny `PR_CONTEXT_MISSING` instead of `EPIC_BASE_BRANCH_MISMATCH`. Options: add the three artifact files to `pr-author/item-own-epic-mode/` (committed fixture bytes, using the absolute body path for the `OtherWorktree` row) or move the row to seam mocks.
- R1 rows (:106-132) resolve to `item-own-ready` from `session-root`; with the recommended Check 1 rule they need the absolute body path.
- The suite header (:17-28) documents the process-directory binding and must be revised.
- Rows calling `Get-PrAuthorBypassReason`/`Test-PrAuthorBypassRequired` with `-ContextExists`: Grep finds the parameter in `enforce-pr-author-skill.TargetResolution.Tests.ps1` and `enforce-pr-author-skill.Tests.ps1`. Seam unit rows that call `Get-PrContextArtifactExistence` with no argument (`enforce-pr-author-skill.Tests.ps1:393`) or set `$script:PrContextArtifactPath` (`:426-444`) need the new `-Path` parameter. The out-of-process row in `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1:77-115` sets `$script:PrContextArtifactPath` to bypass Case C; it still expects `TARGET_WORKTREE_NOT_DERIVABLE`, which resolution-before-Case-C still produces.
- M5 (section 3) and the epic removal exact-text row (section 5.4).

### 7.4 Two-worktree topology tests consistent with existing patterns

- pr-author, fixture-based (no new files needed): run from `pr-author/item-own-not-ready` (no PR artifacts at that root) with the resolution seam returning `OtherWorktree` at `pr-author/item-own-ready` and an absolute `--body-file <item-own-ready>/artifacts/pr_body_1.md` -> allow. Reverse: run from `pr-author/session-root` (has artifacts) with the target at `pr-author/item-own-not-ready` (no artifacts) -> `PR_CONTEXT_MISSING` naming the item worktree, which proves the session-root files are ignored.
- pr-author, seam-based: mock the four artifact seams and capture the path each receives; assert every path begins with `/synthetic-worktrees/item-a/artifacts/`, the summary last-write is read from the same root as the receipt, and `Resolve-PrAuthorWorktreeTarget` is invoked `-Times 1 -Exactly`. A freshness row returns different last-write values per path (`-ParameterFilter`) to prove the item's summary is the comparison basis.
- Merge gate: synthetic roots; mock `Get-WorktreeItemLiveRoot` and `Get-WorktreeItemCheckpointText` in module scope `WorktreeItemResolution` so only `/synthetic-worktrees/item-a` records the standalone record for N while `/synthetic-worktrees/session` records none; assert allow and `Should -Invoke Get-ChildOrchestratorCheckpointContent -ParameterFilter { $Path -eq '/synthetic-worktrees/item-a/artifacts/orchestration/orchestrator-state.json' }`. A `pr_gate`-less, standalone-less checkpoint with N -> deny naming `TARGET_WORKTREE_NOT_DERIVABLE` (the #788 row).

### 7.5 Reason codes for unresolvable or ambiguous targets

- Status values: `SessionRoot`, `OtherWorktree`, `NoTarget`, `Ambiguous` (`.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:31-34`, validated at :97).
- Codes: `TARGET_WORKTREE_NOT_DERIVABLE` for `NoTarget` and `TARGET_WORKTREE_AMBIGUOUS` for `Ambiguous` (`.claude/lib/worktree-resolution/WorktreeResolution.psm1:55,59`), obtained only through `Get-WorktreeResolutionNoTargetReasonCode` and `Get-WorktreeResolutionAmbiguityReasonCode` (:463-487) and carried on `ReasonCode` of every target result (`WorktreeTargetResolution.psm1:128-132`). Hooks and tests must not restate the literals (`enforce-pr-author-skill-helpers.ps1:98-99`; tests read them from the accessors, `enforce-pr-author-skill.WorktreeResolution.Tests.ps1:54-55`).

---

## 8. Upstream overlap with C1a (#824, #742, #733)

| C3 edit region | File and current lines | Likely C1a edit | Overlap |
|---|---|---|---|
| Check 1 canonical path and body/receipt composition | `enforce-pr-author-skill-helpers.ps1:169-177` | #715 under #733: accept quoted or absolute `--body-file` values | Direct. C3 must build root binding on C1a's accepted forms. |
| Resolution moved before Case C; Case C; epic-scope call | `enforce-pr-author-skill-helpers.ps1:313-373` | #733/#714 token-aware `gh pr create` matching and the raw-scan fallback at `:293-311` | Adjacent; same function. |
| Up-front context probe removal | `enforce-pr-author-skill.ps1:185-186` | possibly unchanged | Low. |
| Merge-gate child read and binding | `enforce-epic-merge-gate.ps1:357-366` | the raw-scan fallback at `:344-352` consumes `Test-CommandLineSegmentRawScan`; C1a rewrites raw containment in `hook-command-invocation.ps1` (`Test-CommandLineRawContainment` at :92) | Adjacent; behavior dependency only. |
| Epic removal final deny and diagnostics; read helper return object | `enforce-epic-worktree-removal-gate.ps1:398-403`; `-resolution.ps1:115-144` | #824 addendum 1 empty-operand false positive: operand extraction `:111-150` and scope filter `:352-359`, and possibly the deny for an empty operand | Adjacent; possibly direct if C1a changes the final deny. |
| Parallel removal CR-5 | `enforce-parallel-worktree-removal-gate.ps1:415-420` | addendum 1: operand extraction `:167-211`, scope filter `:358-365` | Adjacent; possibly direct. |

Recommended plan task before any edit: after C1a merges into the integration branch, rebase, re-read the three hooks and `hook-command-invocation.ps1`, re-derive every line number in this section, confirm whether Check 1 already accepts absolute or quoted paths and relative to which root, confirm whether either removal gate's final deny or operand handling changed, re-measure line counts, and stop if a C3 region was rewritten in a way this research did not anticipate.

---

## 9. Coverage and toolchain

- Coverage population: `config/poshqc-coverage.json:3-9` lists roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`; `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` enables coverage with no `Path` list (issue #527 comment at :23-24) and `CoveragePercentTarget = 0`. New files under those roots are covered automatically; no runsettings edit is needed (the #690 plan's runsettings edits predate #527).
- Threshold: line coverage >= 85% per changed PowerShell file; PowerShell is exempt from the branch threshold (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`).
- MCP tools: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` (#690 plan catalogue, `plan.2026-09-29T22-17.md:150-152`). Their result is a fixed summary composed before the child process runs and carries no exit code or test output (`:159`; memory note "poshqc-mcp-results-carry-no-output"). Acceptance conditions must not assert counts, percentages, or findings from an MCP result; only that the call returned.
- Direct invocations that print results (scratch scripts, `plan.2026-09-29T22-17.md:842-944`, carried from the #769 plan): A1 `run-ps.sh` runs `pwsh -NoProfile -NonInteractive -File "$@"`, invoked as `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>` (`:107`, `:149`); A2 `pester-counts.ps1` prints `TotalCount=`, `PassedCount=`, `FailedCount=`, `FAILED:` lines; A3 `pester-coverage.ps1` sets `CodeCoverage.Path` to the named production files and prints `COVERAGE file=... LinePercent=` plus `HIT`/`MISSED`; A6 `ps-format-check.ps1` prints `FORMAT-SUMMARY ChangedCount=` (read-only `Invoke-Formatter` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`); A7 `pssa-count.ps1` prints `PSSA-SUMMARY DiagnosticCount=`; A15 stage-check for staged writes of live hooks. A3 prints `LinePercent=NA` when a file has zero analyzed lines; acceptance should reject `NA` for a changed file.
- Python parity harness: `poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (`plan.2026-09-29T22-17.md:147`).
- Live hooks: the session executing the plan runs these hooks, so a partially written gate takes effect on the next tool call. Reuse #690's staged-write procedure (LH-1 to LH-4, `plan.2026-09-29T22-17.md:112-118`): stage, stage-check, whole-file Write, hash compare, sibling before gate.

---

## 10. Hook constraints

- No Python in enforcement hooks; enforced by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`. All changes stay in PowerShell 7 and run under `pwsh`.
- PowerShell batch budget (`.claude/hooks/enforce-powershell-batch-budget.ps1`): fires on Write/Edit of `.ps1/.psm1/.psd1` (:6-8, :281-284); counts distinct production paths per session id in `.claude/state/powershell-batch-budget.<session>.json` (:10-14, :382); cap 3 (`ProdCap = 3`, :330), so the 4th distinct production file is denied with `POWERSHELL_LARGE_PATH_REQUIRED` (:309-316). Test files (`tests/**/*.ps1`, `*.Tests.ps1`) are never counted (:298-302). No cap applies when the checkpoint at the batch-budget root selects `large`, `remediation`, or `preparation` and is not terminal (:384-399; `.claude/hooks/enforce-batch-budget-route.ps1:121,130`). The root is derived from `$PSScriptRoot` (:329). There is no reset within a session other than that route exemption; a plan must not assume a reset. Bundle mirrors written with `cp` through Bash are not Write/Edit events and are not counted.
- This child changes at least eight production PowerShell files, so execution must run on an exempt route with a non-terminal checkpoint at the batch-budget root.

---

## Candidate Approaches

### pr-author artifact root

- Selected: resolve once inside `Get-PrAuthorBypassReason` before Case C, reuse the existing item resolution (non-epic) and the epic checkpoint's root (epic scope), and pass absolute paths to the existing seams. Advantages: one resolution, no new module, no new import, seams stay mockable, Check 6 and preflight unchanged.
- Rejected: resolve in `Invoke-PrAuthorSkillDecision` and pass the root down. It spreads resolution across two functions and would resolve for out-of-scope commands.
- Rejected: use `Resolve-PrAuthorWorktreeTarget` for epic scope as well. It would add a `NoTarget` deny for epic integration PRs whose branch is not checked out in a live worktree, and it is a second resolution.

### Merge-gate item resolution

- Selected: item-by-PR resolver in `WorktreeItemResolution.psm1`, keyed on `pr_gate.pr_number` and `standalone_merge_authorizations[].pr_number`, plus a binding re-check in the gate.
- Rejected: extend `Resolve-WorktreeRunTargetByRecord` with an `item` kind. It breaches the 500-line cap of `WorktreeRunResolution.psm1` and changes the pinned export/validation contract (X1).
- Rejected: derive the item worktree from the run checkpoint's `items[]/features[].worktree_path`. It covers only parallel and epic runs, not a standalone item whose checkpoint holds the authorization record.

### CR-4 location

- Selected: in-place edit of `Test-WorktreeRunPathEqual` (zero net lines).
- Rejected: promote the comparison to an exported helper in `WorktreeTargetResolution.psm1`. It would let the pr-author Check 1 binding reuse it, but widens a module contract and its mirror for one rule; the pr-author binding can apply the same rule locally in a few lines.

## Behavior Semantics and Edge Cases

- pr-author, `--body-file` absent: unchanged (Cases A/B, edit no-body allow); no resolution.
- pr-author, unresolved target: deny with `TARGET_WORKTREE_NOT_DERIVABLE`/`TARGET_WORKTREE_AMBIGUOUS` before Case C; preflight not invoked (existing row `enforce-pr-author-skill.WorktreeResolution.Tests.ps1:349-369` keeps its meaning).
- pr-author, resolved `SessionRoot`: identical to today except paths are absolute.
- pr-author, resolved `OtherWorktree`: summary, body, receipt, and freshness read beneath the item root; relative body path denied; absolute body path must equal the composed canonical path under the root.
- Merge gate, bare command: unchanged.
- Merge gate, explicit N: item checkpoint located by N; child branch requires `epic_mode`, `step9_status == passed`, and binding; standalone child slot reads the item checkpoint; epic and parallel branches unchanged; final deny prefix includes the item target when all three are unresolved.
- Removal gates: allow/deny decisions unchanged; one leading token; epic deny gains diagnostics.
- Resolution path comparison: drive-letter and UNC paths case-insensitive; single-slash-rooted paths case-sensitive.

## Requirements Mapping (proposed file changes)

- `.claude/hooks/enforce-pr-author-skill.ps1`: seams gain `-Path`; remove the up-front probe; header text.
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1`: resolution before Case C; root-relative composition; Check 1 root binding; `Get-PrAuthorTargetCheckpointResolution` returns `WorktreeRoot` and `Status`; header text at :18-24.
- `.claude/hooks/enforce-epic-merge-gate.ps1`: item resolution for explicit N; header text at :41-44.
- `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`: guarded WIR import, `Resolve-EpicMergeGateItemTarget`, binding function, unresolved-reason extension.
- `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`: `Resolve-WorktreeItemTargetByPrNumber` and export.
- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`: CR-4.
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`: CR-5.
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and `-resolution.ps1`: single token, `Path` on the read result, diagnostics builder.
- Bundle mirrors of each of the above under `extensions/drm-copilot/resources/claude-customizations/`.
- `.claude/rules/orchestrator-state.md` (and its bundle mirror): one sentence stating that, for an explicit PR number, the per-feature checkpoint consulted by the merge gate is the live worktree whose checkpoint records that number in `pr_gate.pr_number` or a `standalone_merge_authorizations` entry. The pr-author handoff text in `.claude/skills/orchestrate/SKILL.md:183-192` should state that a child working outside the item worktree passes the absolute body path.

## Testing Implications

- New suites rather than growth of near-cap suites: for example `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, `enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1`, `WorktreeItemResolution.PrNumber.Tests.ps1`.
- Every suite that dot-sources the merge gate and passes an explicit PR number receives a one-line default mock of `Resolve-EpicMergeGateItemTarget` (SessionRoot at `/synthetic-worktrees/default-session`) so it stays independent of the machine's worktrees: `enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1` (where not overridden), `hook-command-parser.AcceptanceCases.Tests.ps1`. The row `enforce-epic-merge-gate.Tests.ps1:436-444` currently reaches real checkpoint reads for PR 999; the default mock removes that dependency for the item read.
- Decision-unchanged proof for #851: run the existing allow/deny rows of both removal suites unmodified (except the one exact-text row) and assert the same decisions.
- Determinism: no wall-clock reads (freshness compares artifact metadata through seams), no temporary files, no network.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for a `spec.md` acceptance criterion in this research. Line counts and suite counts above are planning inputs that the plan must re-derive after C1a merges; they are not proposed as acceptance assertions. The only numeric property proposed for a test is a per-string occurrence count (exactly one leading deny token), which is a single-value assertion on one output string, not a family enumeration.

## Automation Feasibility

No step requires human interaction. Every change is a file edit, a `cp` mirror, a Pester or pytest run, or a git operation that the plan can perform. Two conditions must hold for unattended execution: the execution session runs on a batch-budget-exempt route with a non-terminal checkpoint at the batch-budget root (section 10), and C1a has merged into the integration branch before the pre-edit re-verification task (section 8). The stale session-root copies from the 2026-10-07 workaround are out of scope and must not be modified; no task needs to touch them.

## Open Items for the Spec Author

1. Confirm the new deny precedence on the `--body-file` path (resolution before `PR_CONTEXT_MISSING`).
2. Confirm the relative body path is denied for `OtherWorktree` targets (section 1.5).
3. Confirm the #788 behavior change for epic children on routes without `pr_gate` (section 3).
4. Decide whether the epic removal gate's doubled token (section 4) is fixed in this child alongside the #851 diagnostics.
5. Confirm the Codex merge and removal gates are out of scope and recorded as follow-ups (section 6.1).
