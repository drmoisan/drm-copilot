# Research: epic-worktree-removal-gate blocks parallel runs (Issue #573)

- Date: 2026-08-28
- Issue: #573
- Feature folder: `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/`
- Scope: read-only analysis. No source, configuration, or test file was modified.

## Session Tool Constraint (affects two claims)

The `Bash` tool was disabled for this session ("No such tool available: Bash"). Every finding below
was established by reading files with the `Read` and `Grep` tools. Two consequences:

1. **Byte-identity between mirrored copies was established by full-text reading, not by a
   `git diff` or a hash comparison.** Where I claim two files are identical, I read both in full and
   compared line-for-line, including line counts. That is strong evidence but is not a byte-level
   diff, so trailing-whitespace or line-ending differences invisible to `cat -n` rendering would not
   have been caught. The plan should re-confirm with a real diff before relying on "no change
   needed" for any copy.
2. **The conjunctive-deny semantics of `PreToolUse` hooks were not re-verified by execution.** The
   claim is supported by repository prose and by the observed field outcome (see Q1).

## Q1 — Root cause, exactly

### Verdict

**The orchestrator's hypothesis is CONFIRMED. The issue text's claim that "F7 shipped no parallel
counterpart for this gate" is INACCURATE.** The parallel counterpart exists, is registered, and
allows correctly. The removal is denied solely by the epic gate's independent fail-closed deny,
which the parallel gate's allow cannot override.

Stronger than that: **the defect was predicted in committed repository prose before it occurred**,
and the prose names the exact missing half of the fix. See "Q1.4 — Prior documentation of this
defect" below.

### Q1.1 — Both gates are registered on the same matcher

`.claude/settings.json`, `PreToolUse` → `"matcher": "Bash"` (block begins line 89, matcher line 91):

- line 115: `"command": "pwsh -NoProfile -File .claude/hooks/enforce-epic-worktree-removal-gate.ps1"`
- line 119: `"command": "pwsh -NoProfile -File .claude/hooks/enforce-parallel-worktree-removal-gate.ps1"`

Both fire on every `Bash` tool call. Neither is conditioned on route, agent, or checkpoint.

### Q1.2 — The parallel gate ALLOWS correctly (it is not the defect)

`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`:

- line 33: `$script:ParallelCheckpointPath = 'artifacts/orchestration/parallel-orchestrator-state.json'`
- line 34: `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')`
- lines 108-117: scans `$Checkpoint.items` for a `worktree_path` matching the normalized target.
- lines 138-145: `Test-ParallelWorktreeRemovalAllowed` returns `$true` when the matched item's
  `merge_status` is in the allowed set.
- lines 222-225:
  ```powershell
  $itemRecord = Find-ParallelWorktreeItemRecord -Checkpoint $checkpoint -WorktreePath $worktreePath
  if (Test-ParallelWorktreeRemovalAllowed -ItemRecord $itemRecord) {
      return Get-ParallelWorktreeGateAllowDecision
  }
  ```

For a merged parallel item this gate returns `permissionDecision = 'allow'`. It is behaving as
designed and requires no change.

### Q1.3 — The epic gate DENIES unconditionally when no epic checkpoint exists

`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`. The deciding chain, in execution order:

1. **line 199-201 — the command is IN scope, so the early allow is not taken.**
   ```powershell
   if ($commandText -notmatch '(?i)\bgit\s+worktree\s+remove\b') {
       return Get-EpicWorktreeGateAllowDecision
   }
   ```
   A parallel `git worktree remove` matches, so control falls through.

2. **line 205 — only the EPIC checkpoint is read. There is no second read seam.**
   ```powershell
   $checkpointRaw = Get-EpicWorktreeGateCheckpointContent
   ```
   `Get-EpicWorktreeGateCheckpointContent` (lines 29-45) reads
   `$script:EpicCheckpointPath` = `'artifacts/orchestration/epic-orchestrator-state.json'`
   (line 26) and returns `$null` when the file is absent (lines 41-43).

3. **lines 89-91 — a `$null` checkpoint yields no record.**
   ```powershell
   if ($null -eq $Checkpoint -or [string]::IsNullOrWhiteSpace($WorktreePath)) {
       return $null
   }
   ```

4. **lines 131-133 — a `$null` record is not allowed.**
   ```powershell
   if ($null -eq $FeatureRecord) {
       return $false
   }
   ```

5. **line 220 — the deny is emitted.**
   ```powershell
   return Get-EpicWorktreeGateBlockDecision -Reason "EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '$worktreePath' requires a matching epic checkpoint features[] record with merge_status in {merged, worktree_removed}. ..."
   ```

Note that step 3 also fires when an epic checkpoint DOES exist but carries no `features` key
(lines 92-95), and step 4's sibling at lines 134-137 fires when the matched record has no
`merge_status`. None of these paths can be reached by a parallel run, because the parallel run
never writes `epic-orchestrator-state.json` at all — the gate stops at step 2 with `$null`.

### Q1.4 — Prior documentation of this defect (decisive corroboration)

`.claude/skills/parallel-orchestrate/SKILL.md`, lines 390-398, verbatim:

> Mechanical gating of this command for parallel worktrees is F7 scope.
> `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is a project-wide `PreToolUse` Bash-matcher
> hook that denies any `git worktree remove` unless the epic checkpoint carries a matching
> `features[]` record whose `merge_status` is `merged` or `worktree_removed`; an unreadable checkpoint
> or an absent record also denies. Its block reason is `EPIC_WORKTREE_REMOVAL_BLOCKED`. A parallel run
> has no epic checkpoint record for its worktrees, so removal is denied until F7 both delivers
> `enforce-parallel-worktree-removal-gate.ps1` and coordinates the epic gate's allow conditions:
> `PreToolUse` denials are conjunctive, so a new allow-hook alone cannot override the existing deny.
> This feature ships no hook file and makes no `.claude/settings.json` change.

F7 delivered the first conjunct (`enforce-parallel-worktree-removal-gate.ps1` exists and is
registered) and did not deliver the second (coordinating the epic gate's allow conditions). The
present issue is exactly the residual of that half-completed obligation.

The conjunctive-deny semantics ("a new allow-hook alone cannot override the existing deny") are
asserted by this committed prose and are corroborated by the field outcome recorded in the promoted
record: 23 worktrees leaked across the `critical-bug-fixes` parallel run completed 2026-08-26, with
`EPIC_WORKTREE_REMOVAL_BLOCKED` as the observed block reason. **I did not independently re-verify
the conjunctive semantics by execution**, because no shell was available in this session.

### Q1.5 — Incidental observation: the `--force` extraction defect (out of scope, but note it)

Both `.claude` gates extract the path with
`'(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)'` (epic line 63, parallel line 70). A command of the
form `git worktree remove --force <path>` captures `--force` as the path, which matches no record
and denies. This is fail-closed and therefore safe, but it means a forced removal can never be
authorized by either `.claude` gate. The `.codex` copy handles this correctly with
`'(?i)\bgit\s+worktree\s+remove(?:\s+--force)?\s+(?:"(?<double>[^"]+)"|''(?<single>[^'']+)''|(?<bare>\S+))'`
(`.codex/hooks/enforce-epic-worktree-removal-gate.ps1` line 35).

This is **out of scope for #573** — the repository's `cleanup-merged-worktrees` skill forbids the
force flag (`.claude/skills/cleanup-merged-worktrees/SKILL.md` line 116) — but the plan should not
"improve" the regex while making the fix, because widening extraction changes epic-path behavior
that is currently pinned by tests.

## Q2 — Surface parity inventory

Complete enumeration from `Glob **/enforce-*worktree-removal-gate.ps1` (six files, no others):

| # | Path | Lines | Relationship |
|---|---|---|---|
| 1 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 274 | **Canonical. Must change.** |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 274 | **Byte-identical mirror of #1. Must change identically.** |
| 3 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 281 | Sibling gate. **No change required.** |
| 4 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | — | Mirror of #3. No change required. |
| 5 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 151 | **Independent codex-native implementation, NOT a mirror of #1. Recommend no change — see Q4.** |
| 6 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 152 | Byte-identical mirror of #5. No change if #5 is unchanged. |

### Divergence detail

**#1 vs #2 — identical.** I read both in full. Every line matches, including the docstring, the
`$script:` variable block, all six function bodies, the entry-point tail comment, and the final
`exit ([int]$entryPointResult[-1])`. Both are 274 lines.

**#1 vs #5 — completely different implementations, not a drifted copy.** The `.codex` gate:

- Uses no shared payload module. #1 imports `../lib/hook-payload/HookPayload.psm1` (line 25); #5
  imports nothing and reads stdin directly at its tail (`[Console]::In.ReadToEnd()`, line 135).
- Uses a **silent-allow** protocol: it returns `$null` for both out-of-scope and authorized cases and
  emits nothing (lines 96-102, 115-119, 144-146). #1 always emits an explicit `permissionDecision`
  JSON object.
- Checks `tool_name -ne 'Bash'` inside the script (line 96); #1 relies on the settings matcher.
- Resolves the checkpoint path relative to the repository root computed from `$PSScriptRoot`
  (lines 136-137), rather than from a fixed relative literal (#1 line 26).
- Resolves worktree paths to absolute form via `[System.IO.Path]::GetFullPath` against the payload's
  `cwd` (lines 47-58, 105-109); #1 only normalizes separators and trims a trailing slash (line 97).
- Handles `--force` and quoted path forms (line 35); #1 does not.
- Exits 2 on an exception (line 150); #1 never returns non-zero (documented at lines 228-232).

**#5 vs #6 — identical.** Read both in full; identical through line 151, with #6 carrying a trailing
newline that renders as a line-152 marker. Treat as identical.

## Q3 — Parity / bundle tests that fail if copies diverge

**Yes. Mirroring #1 into #2 is MANDATORY, enforced by a byte-comparing test.**

### Claude parity test (authoritative for this fix)

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`

- `SCOPED_ROOTS: tuple[Path, ...] = (Path(".claude"),)` — line 20.
- `BUNDLED_ROOT = REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"`
  — lines 17-19.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` — lines 101-126. Assertion
  mechanism, lines 119-126:
  ```python
  for relative_path in repo_runtime_files:
      assert (
          relative_path in bundled_files
      ), f"Repo file missing from bundle: {relative_path}"
      assert read_text(BUNDLED_ROOT, relative_path) == read_text(
          REPO_ROOT,
          relative_path,
      ), f"Bundle content differs from repo for: {relative_path}"
  ```
  `read_text` (lines 46-49) reads UTF-8 decoded text, so the comparison is text-equality over the
  entire `.claude/**` tree. Editing `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` without
  mirroring fails this test with `Bundle content differs from repo for: .claude/hooks/enforce-epic-worktree-removal-gate.ps1`.

Exclusions from the parity scope (lines 113-117): `.claude/settings.local.json` and the
`.claude/agent-memory/**` subtree only. Hooks are not exempt.

### Codex parity test (equivalent, but not triggered if `.codex` is left unchanged)

`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`

- `SCOPED_ROOTS: tuple[Path, ...] = (Path(".codex"), Path(".agents"))` — line 35.
- `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` — lines 215-228, with
  the same `read_text(BUNDLED_ROOT, ...) == read_text(REPO_ROOT, ...)` assertion at lines 225-228.

If the plan does elect to change `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`, the codex
bundle copy must be mirrored in the same commit.

### Pack-manifest completeness (relevant only if a NEW file is created)

`tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`,
`test_bundled_claude_files_are_listed_in_some_pack_manifest` (line 139). Every bundled `.claude`
file must appear in a pack manifest. The current manifest already lists the gate:
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` line 31.

**Implication for the fix design:** if the plan splits helper functions into a new dot-sourced
sibling file (for example to stay under the 500-line limit — the gate is currently 274 lines, so
this should not be necessary), that new file must be added to the bundle, to `core.json`, AND to
`pester.runsettings.psd1`. Keeping the fix inside the existing file avoids all three obligations.

### Relation to known issue #510

Issue #510 records a bundle-parity test that fails locally on gitignored state while passing in CI.
The `.claude/agent-memory/**` exemption at lines 68-98 and 113-117 of the Claude contracts test is
the mechanism that handles the memory-tree case. The exemption is scoped to `.claude/agent-memory`
only, so it does **not** attenuate the hook-file assertion above. #510 is not a reason to skip the
mirror edit; it only means a local run of these tests may already be red for an unrelated reason,
and a red result must be attributed before it is treated as caused by this change.

## Q4 — Does the `.codex` parallel surface exist?

**No. The codex runtime cannot drive a parallel run.** Recommendation: **do not change either
`.codex` copy.**

### Evidence of absence

- `Glob .codex/hooks/*.ps1` returns 28 files. **None** is named `enforce-parallel-*`. There is no
  codex cohort barrier, no codex parallel worktree gate, no codex parallel drift gate, and no codex
  parallel abandon gate. Contrast `.claude/hooks/`, which carries all four.
- `Grep parallel` over `.agents/` matches only three files, all epic skills
  (`.agents/skills/epic-run/SKILL.md`, `epic-orchestrate/SKILL.md`, `epic-plan/SKILL.md`). There is
  no `.agents/skills/parallel-orchestrate/SKILL.md`, no `parallel-plan`, and no `parallel-remove`.
- `.codex/agents/` carries `epic-planner.toml` and `epic-orchestrator.toml`
  (`tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` lines 16-17) and no
  `parallel-planner.toml` or `parallel-orchestrator.toml`.
- `.codex/config.toml` registers exactly five hooks on `matcher = "^Bash$"` (line 120):
  `validate-bash.ps1` (124), `enforce-promotion-mcp-only.ps1` (130),
  `enforce-orchestration-preimplementation-gate.ps1` (136), `enforce-epic-merge-gate.ps1` (142), and
  `enforce-epic-worktree-removal-gate.ps1` (148). No parallel gate is registered.

### The one partial exception, and why it does not change the answer

`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` **does** know the parallel
route: line 59 maps `'parallel' = 'artifacts/orchestration/parallel-orchestrator-state.json'`, and
lines 429-448 implement a parallel readiness predicate keyed on `route_id == 'parallel'` and
`parallel_slug`. Its header comment at line 16 even references
`enforce-parallel-cohort-barrier.ps1` — a file that **does not exist under `.codex/hooks/`**. That
module was added by issue #554 for route-shape symmetry in the preimplementation gate; it does not
constitute a parallel execution surface, because no codex persona, skill, or gate can conduct a
parallel run.

### The controlling precedent

**`.codex/hooks/enforce-epic-merge-gate.ps1` has NO parallel branch.** `Grep -i 'parallel|route_id'`
over that file returns zero matches. The `.claude` merge gate carries the three-branch structure
including `Test-ParallelCheckpointAllowsMerge` (lines 247-308); the codex merge gate does not.

This establishes the repository's landed convention: when the parallel surface added an allow-branch
to an epic gate, it added it to the `.claude` copy only and left the `.codex` copy epic-only. The
worktree gate should follow that same convention.

### Justification for the recommendation

Adding a parallel branch to the `.codex` epic worktree gate would be **inert** (no codex-driven
parallel run can exist to exercise it) and would carry three costs:

1. It would require re-deriving the branch against a materially different implementation shape
   (silent-allow protocol, absolute-path resolution, no shared payload module), which is new logic
   rather than a mirrored edit.
2. It would create an untested-in-practice second implementation of the parallel allow rule — the
   exact drift risk that motivates the repository's existing single-implementation preference for
   enforcement hooks.
3. It would diverge from the merge-gate precedent without a behavioral reason to do so.

If a codex parallel surface is later built, the codex gate should be updated as part of that work,
where it can be exercised.

## Q5 — Correct fix design

### Recommended branch structure

Adopt the two-branch cascade of `enforce-epic-merge-gate.ps1`, reduced from three branches to two
(there is no child-checkpoint analogue for worktree removal).

The precedent structure in `.claude/hooks/enforce-epic-merge-gate.ps1`:

- A per-branch read seam: `Get-ParallelOrchestratorCheckpointContent` (lines 84-100), structurally
  identical to the epic seam but reading `$script:ParallelCheckpointPath` (line 46).
- A shared JSON parser: `ConvertFrom-EpicMergeGateJson` (lines 102-125), returning `$null` on empty
  or unparseable text.
- A per-branch predicate: `Test-ParallelCheckpointAllowsMerge` (lines 247-308).
- A sequential cascade in the entry point (lines 383-396): try branch 1, return allow on success;
  try branch 2; try branch 3; fall through to one combined deny at line 398.

Applied to the worktree gate, in `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`:

1. Add `$script:ParallelCheckpointPath = 'artifacts/orchestration/parallel-orchestrator-state.json'`
   adjacent to line 26.
2. Add read seam `Get-EpicWorktreeGateParallelCheckpointContent`, mirroring lines 29-45 against the
   parallel path. **The seam must be a distinct named function** so tests can mock it independently
   — this is the mocking contract the whole existing suite relies on.
3. Optionally factor the inline parse at lines 207-213 into a `ConvertFrom-...Json` helper so both
   branches share it, matching the merge gate's `ConvertFrom-EpicMergeGateJson`. This is a small
   refactor of existing behavior and keeps the file well under the 500-line limit.
4. Add predicate `Test-ParallelCheckpointAllowsWorktreeRemoval -Checkpoint -WorktreePath`, which:
   - returns `$false` when `$Checkpoint` is `$null`;
   - returns `$false` unless `route_id` is exactly `'parallel'` (see below);
   - scans `items[]` for a normalized `worktree_path` match, reusing the same normalization as
     lines 97 and 106;
   - returns `$true` only when the matched item's `merge_status` is in
     `@('merged', 'worktree_removed')`.
5. In `Invoke-EpicWorktreeRemovalGateDecision`, insert the parallel branch between the existing epic
   allow at lines 216-218 and the deny at line 220.
6. Replace the deny reason at line 220 with the combined wording below.
7. Update the `.DESCRIPTION` docstring (lines 5-14) to describe two branches, mirroring the merge
   gate's numbered-branch docstring at lines 5-27.

### Should the epic gate consult `route_id == "parallel"`?

**Yes.** Three reasons:

1. It matches the merge-gate precedent exactly (`enforce-epic-merge-gate.ps1` lines 273-276):
   ```powershell
   if ($props -notcontains 'route_id' -or ([string]$Checkpoint.route_id) -ne 'parallel') {
       return $false
   }
   ```
2. `route_id == 'parallel'` is a rule-level invariant, not an incidental field:
   `.claude/rules/parallel-orchestration.md`, orchestrator invariant 2, states "**Route identity.**
   `route_id` must be exactly `'parallel'`." A checkpoint at that path that fails the check is
   malformed by the rule's own definition, and refusing to authorize from it is correct.
3. It makes a non-parallel document that happens to sit at the parallel checkpoint path inert,
   narrowing the allow surface at zero cost to the legitimate path.

### Should it match on `items[].worktree_path` with `merge_status` in `{merged, worktree_removed}`?

**Yes.** Both halves are pinned by rule prose:

- `.claude/rules/parallel-orchestration.md` invariant 5 requires each `items[]` entry to be an object
  with a unique positive-integer `issue_num`; invariant 7 fixes the eight-member `merge_status` enum
  including `merged` and `worktree_removed`; invariant 8 requires that an item whose `merge_status`
  is `merged` or `worktree_removed` have `state == 'merged'`.
- The already-shipped sibling gate uses exactly this predicate
  (`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` lines 108-117 and 138-145), so the two
  gates will agree by construction rather than by coincidence.
- `.claude/skills/parallel-orchestrate/SKILL.md` lines 733-738 states the same contract in prose.

Do **not** key on `pr_number` here. The merge gate keys on `pr_number` because the command names a
PR; the removal command names a path, so the path is the only correct key.

### Combined deny message wording

Follow the merge gate's single-sentence enumerate-then-conclude form (line 398). Proposed:

```
EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '<path>' requires either an epic checkpoint features[] record with merge_status in {merged, worktree_removed}, or a parallel-orchestrator checkpoint with route_id == "parallel" whose matching items[] record (matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint authorized this removal.
```

Constraints on the wording that the plan must respect:

- **The `EPIC_WORKTREE_REMOVAL_BLOCKED:` prefix must be preserved verbatim.** Five existing
  assertions match it (`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
  lines 18, 66, 74, 86, 98, plus entry-point assertions at 183 and 223), and
  `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` line 338 matches the same token for the
  codex gate. Renaming the reason code breaks both suites and every transcript grep.
- Keep the `'$worktreePath'` interpolation; the existing message uses single quotes around it
  (line 220) and the parallel gate matches that convention (line 227).
- Do not introduce a `PARALLEL_` prefix on this gate's message. Two gates emitting the same prefix
  would make transcript attribution ambiguous. The parallel gate owns
  `PARALLEL_WORKTREE_REMOVAL_BLOCKED`; this gate keeps `EPIC_WORKTREE_REMOVAL_BLOCKED` even for its
  parallel branch, exactly as `enforce-epic-merge-gate.ps1` emits `EPIC_MERGE_GATE_BLOCKED` for its
  parallel branch (line 398).

### How fail-closed is preserved when NEITHER checkpoint authorizes

The cascade is a disjunction of two positive predicates with a single terminal deny. Every failure
mode falls through to the deny:

| Condition | Branch 1 result | Branch 2 result | Outcome |
|---|---|---|---|
| Neither checkpoint file exists | seam returns `$null` → `$false` | seam returns `$null` → `$false` | deny |
| Epic checkpoint unparseable | parse yields `$null` → `$false` | `$false` | deny |
| Parallel checkpoint unparseable | `$false` | parse yields `$null` → `$false` | deny |
| Parallel checkpoint present, `route_id != 'parallel'` | `$false` | `$false` at the route check | deny |
| Parallel checkpoint present, no matching `worktree_path` | `$false` | `$false` at the scan | deny |
| Matching item, `merge_status == 'pr_open'` | `$false` | `$false` at the status check | deny |
| Matching item, no `merge_status` key | `$false` | `$false` | deny |
| Envelope anomaly | — | — | deny at lines 187-192, before any checkpoint read |

The envelope-anomaly deny at lines 187-192 must remain the first check and must not be moved behind
the new branch.

### Double-allow weakening analysis

**The mutual-exclusivity argument holds here, and is materially STRONGER than the merge gate's.**

The merge gate's docstring (lines 23-27) argues: "standalone (non-epic, non-parallel) orchestration
never sets `epic_mode`, populates `epic_merge_pr`, or writes a parallel checkpoint with
`route_id == "parallel"`, so it is structurally prevented from invoking `gh pr merge --merge` at
all." That argument is about *which runs can write the authorizing document*.

For the worktree gate the argument is stronger because **the authorization is about the path, not
about the run**. An allow fires only when a checkpoint records that exact worktree path as already
merged or already removed. If a path is genuinely recorded as `merged` in the parallel checkpoint,
removing it is safe irrespective of which orchestration surface issues the command — the safety
property the gate protects (do not destroy unmerged work) is a property of the path's merge state,
not of the caller's identity.

Contrast the merge gate, whose key is a PR number drawn from a repository-global namespace. There a
number recorded in one checkpoint could in principle name a PR the other surface intends to merge.
The worktree gate has no such namespace collision: worktree paths are per-run and per-item.

**Residual risk, stated precisely.** `/artifacts` is gitignored (`.gitignore` line 6), so
`artifacts/orchestration/parallel-orchestrator-state.json` persists on disk after a parallel run
ends. A stale parallel checkpoint whose items are all `worktree_removed` therefore remains readable.
For that stale document to authorize an epic-run removal, an epic child worktree would have to be
created at a path byte-identical (after separator normalization and trailing-slash trim) to a path
recorded in the stale parallel checkpoint. Worktree paths in this repository carry a session or
timestamp component, so a collision is implausible; and were one to occur, the recorded state is
`worktree_removed`, meaning the path was already deleted and an epic worktree recreated there would
be a distinct directory with the same name. I judge this an accepted residual, not a blocker, but it
should be recorded in the plan rather than left unstated. Adding the `route_id` check does not
reduce this specific residual (a stale parallel checkpoint legitimately carries
`route_id == 'parallel'`); it guards a different case.

**No weakening of the epic path.** Branch 1 is unchanged and is evaluated first. Any input that
allowed before still allows, and the only newly-allowed inputs are those where branch 1 denies and
branch 2's four conjuncts all hold.

## Q6 — Test surface

### Existing structure

`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` — 236 lines, one
`Describe` (line 8), `BeforeAll` dot-sources the hook (lines 9-12). Ten `Context` blocks:

| Lines | Context | Note |
|---|---|---|
| 14-36 | commands outside scope | 4 tests; no checkpoint mock |
| 38-47 | allow on `merge_status` merged | mocks the epic seam |
| 49-58 | allow on `merge_status` worktree_removed | mocks the epic seam |
| 60-76 | deny on unreadable checkpoint | **2 deny tests — must gain the parallel-seam mock** |
| 78-88 | deny on no matching record | **1 deny test — must gain the parallel-seam mock** |
| 90-100 | deny on other `merge_status` | **1 deny test — must gain the parallel-seam mock** |
| 102-111 | path normalization | mocks the epic seam, expects allow |
| 113-122 | `Get-EpicWorktreeRemovalCommandPath` helper | pure, unaffected |
| 124-138 | `Find-EpicWorktreeFeatureRecord` helper | pure, unaffected |
| 140-149 | `Test-EpicWorktreeRemovalAllowed` helper | pure, unaffected |
| 151-162 | real `Test-Path` read seam | mocks `Test-Path`/`Get-Content` by `-ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }` |
| 164-235 | entry-point exit code and emitted decision | `BeforeEach` at 165-167 mocks the epic seam to `$null`; **must gain the parallel-seam mock** |

### The mocking seam pattern

Pester `Mock -CommandName <read-seam-function> -MockWith { <literal JSON string> }`. Example,
lines 40-42:

```powershell
Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
    '{"features":[{"worktree_path":"/repo/worktrees/child-a","merge_status":"merged"}]}'
}
```

The seam is the function, not the filesystem. No test writes a temporary file, satisfying the
repository prohibition on temporary files in tests.

### CRITICAL: the determinism obligation the fix creates

Once a second read seam exists, **every test that currently expects a deny must mock the new
parallel seam to `$null`**. Otherwise those tests read the real
`artifacts/orchestration/parallel-orchestrator-state.json`. Because `/artifacts` is gitignored
(`.gitignore` line 6), that file's presence and contents are untracked local state, so the tests'
outcomes would depend on whether a parallel run happens to be in progress on the developer's
machine. That violates the determinism requirement in `.claude/rules/general-unit-test.md` and
reproduces the failure class of known issue #510 (a test red locally, green in CI, caused by
gitignored state).

This is not speculative — the repository already applies the mitigation in both relevant places:

- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` mocks
  `Get-ParallelOrchestratorCheckpointContent -MockWith { $null }` in every deny context: lines 91,
  105, 117, 127, 188, and in the entry-point `BeforeEach` at line 378.
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` states the rule
  explicitly in its file docstring, lines 7-11:
  > Every checkpoint fixture is injected through the mocked read seam
  > `Get-ParallelWorktreeRemovalGateCheckpointContent`. No test reads the real
  > `artifacts/orchestration/parallel-orchestrator-state.json` and no test writes a temporary
  > file, so the suite is deterministic regardless of live orchestration state.

The epic gate's test file should gain the same docstring statement.

Concretely, the affected existing tests are at lines 61-67, 69-75, 79-87, 91-99, and the
`BeforeEach` at 165-167 (which covers the seven entry-point tests at 170-234, of which the deny ones
at 170, 186, 194, 202, 209, and 216 all depend on it).

### New test cases the fix requires

Allow via the parallel branch:

1. Parallel checkpoint with `route_id == "parallel"` and a matching `items[]` entry whose
   `merge_status` is `merged`, epic seam `$null` → **allow**.
2. Same with `merge_status` `worktree_removed` → **allow**.
3. Parallel branch honors separator normalization (backslash in checkpoint, forward slash in
   command), mirroring the existing epic test at lines 103-110 → **allow**.

Deny via the parallel branch (fail-closed):

4. Parallel checkpoint present, matching item, `merge_status == "pr_open"` → **deny**, reason
   matches `EPIC_WORKTREE_REMOVAL_BLOCKED`.
5. Parallel checkpoint present, `route_id` absent or not `"parallel"`, matching merged item →
   **deny** (proves the route guard).
6. Parallel checkpoint present with `route_id == "parallel"` but no `items` key → **deny**.
7. Parallel checkpoint present, no `items[]` entry matching the target path → **deny**.
8. Parallel checkpoint content is malformed JSON → **deny**.
9. Parallel checkpoint seam returns `$null` (file absent) AND epic seam returns `$null` → **deny**
   (the exact #573 field scenario inverted; this is the "no parallel checkpoint → epic behavior
   unchanged" case).
10. Matching item present but carrying no `merge_status` key → **deny**.

Epic path unchanged (regression pins):

11. Every existing epic test above, re-run with the parallel seam mocked to `$null`, must produce
    the identical decision it produces today. These are the five deny tests plus the two allow tests
    at lines 39-46 and 50-57 and the normalization test at 103-110.
12. Epic checkpoint authorizes AND parallel checkpoint denies → **allow** (branch 1 wins; proves the
    branches are ORed, not ANDed).

Direct predicate coverage, mirroring the merge gate's
`Context 'Test-ParallelCheckpointAllowsMerge helper (direct branch coverage)'`
(`enforce-epic-merge-gate.Tests.ps1` line 245):

13. `Test-ParallelCheckpointAllowsWorktreeRemoval -Checkpoint $null` → `$false`.
14. Same with a checkpoint lacking `route_id` → `$false`.
15. Same with a checkpoint lacking `items` → `$false`.
16. Same with an item lacking `worktree_path` (skipped, not matched) → `$false`.

Read-seam coverage, mirroring the merge gate's
`Context 'real Test-Path read seam for the parallel checkpoint'` (line 232) and the existing epic
`Context 'real Test-Path read seam'` (lines 151-162):

17. `Get-EpicWorktreeGateParallelCheckpointContent` returns `$null` when `Test-Path` is mocked
    `$false` for `$script:ParallelCheckpointPath`.
18. It returns the real content when `Test-Path` is mocked `$true` and `Get-Content` is mocked, with
    `-ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }`.

No new test FILE is required; extend the existing
`tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`.

## Q7 — Documentation obligations

The repository's doctrine is prose rules plus validator/hook logic, never an imported JSON Schema
(`.claude/rules/parallel-orchestration.md`, "Foreign Schema Warning" and "Enforcement"). The fix must
therefore land prose alongside the code.

### 7.1 `.claude/skills/parallel-orchestrate/SKILL.md` lines 390-398 — MUST CHANGE

Currently reads (quoted in full in Q1.4). The passage is written in the future tense against an
unfinished obligation: "so removal is denied until F7 both delivers
`enforce-parallel-worktree-removal-gate.ps1` and coordinates the epic gate's allow conditions".

After the fix this is factually wrong. Replace with prose stating that both halves have landed: the
parallel gate exists, and `enforce-epic-worktree-removal-gate.ps1` now carries a parallel
allow-branch keyed on `route_id == "parallel"` and the matching `items[].worktree_path`, so the
conjunctive-deny interaction no longer blocks a merged parallel item's removal. Retain the sentence
explaining that `PreToolUse` denials are conjunctive — that is the load-bearing explanation of *why*
the epic gate had to change, and it should survive as the rationale.

The final sentence "This feature ships no hook file and makes no `.claude/settings.json` change"
remains true of *that* feature (F5) and should be left alone or scoped explicitly to F5.

### 7.2 `.claude/skills/parallel-orchestrate/SKILL.md` lines 733-738 — SHOULD BE EXTENDED

Currently documents only `enforce-parallel-worktree-removal-gate.ps1` and its
`PARALLEL_WORKTREE_REMOVAL_BLOCKED` reason. Add one sentence noting that the epic gate also fires on
the same command and now carries a matching parallel allow-branch, so both gates must allow for the
removal to proceed.

### 7.3 `.claude/rules/parallel-orchestration.md` — SHOULD GAIN ONE BULLET

The `## Enforcement` section already records the merge-gate analogue verbatim:

> The `PreToolUse` merge gate `.claude/hooks/enforce-epic-merge-gate.ps1` carries a parallel
> allow-branch that authorizes a per-item `gh pr merge --merge` from the parallel-orchestrator
> checkpoint when `route_id == "parallel"`, the target item's `merge_status == "ci_green"`, and the
> command's PR number matches that item's `pr_number`; any other case fails closed with
> `EPIC_MERGE_GATE_BLOCKED`.

There is **no corresponding sentence for the worktree-removal gate**. Add a parallel bullet, for
example:

> The `PreToolUse` worktree gate `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` carries a
> parallel allow-branch that authorizes `git worktree remove <path>` from the parallel-orchestrator
> checkpoint when `route_id == "parallel"` and the `items[]` entry whose `worktree_path` matches the
> normalized target has `merge_status` in `{merged, worktree_removed}`; any other case fails closed
> with `EPIC_WORKTREE_REMOVAL_BLOCKED`. Both this gate and
> `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` fire on the same command, and
> `PreToolUse` denials are conjunctive, so both must allow.

### 7.4 `.claude/skills/epic-orchestrate/SKILL.md` lines 245-254 — NO CHANGE REQUIRED

The passage describes the epic path only:

> `epic-orchestrator` (running from the main repository checkout, not any child worktree) issues
> `git worktree remove <worktree_path>`, gated by
> `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, which denies with reason
> `EPIC_WORKTREE_REMOVAL_BLOCKED` unless the epic checkpoint's matching `features[]` record has
> `merge_status` in `{merged, worktree_removed}`.

This remains accurate for an epic run — branch 1 is unchanged and is evaluated first. Optionally
soften "unless" to "unless … (a parallel allow-branch also exists; see
`.claude/rules/parallel-orchestration.md`)", but this is not required for correctness. **Recommend
no change**, to keep the diff and the blast radius minimal.

### 7.5 Hook docstring — MUST CHANGE

`.claude/hooks/enforce-epic-worktree-removal-gate.ps1` `.DESCRIPTION` at lines 5-14 describes a
single epic branch. Rewrite as a numbered two-branch description following
`enforce-epic-merge-gate.ps1` lines 5-27, including the fail-closed statement and the
mutual-exclusivity argument from Q5.

### 7.6 Historical feature documents — DO NOT CHANGE

`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/spec.md` lines 428-434 and
`user-story.md` lines 82 and 139 record the state of the world at that feature's authoring time, as
does `docs/research/2026-08-07-parallel-orchestration-design-research.md` lines 222-223. These are
historical records, not live contracts. Editing them would inflate the blast radius for no benefit.

## Q8 — PoshQC / Pester registration

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`:

- **Test discovery:** `Run.Path = @('scripts', 'tests/powershell', 'tests/scripts')` (line 3).
  `tests/scripts/claude-hooks/` is under `tests/scripts`, so **no registration is needed for test
  files**, whether extended or newly created.
- **Coverage:** `CodeCoverage.Path` (lines 23-245) is an explicit per-file allow-list. Both relevant
  hooks are already registered:
  - line 46: `'.claude/hooks/enforce-epic-worktree-removal-gate.ps1'` (added for issue #275
    remediation cycle 1)
  - line 175: `'.claude/hooks/enforce-parallel-worktree-removal-gate.ps1'` (added for issue #440)

  **No `pester.runsettings.psd1` change is required** if the fix stays inside the existing hook file.

- If the plan creates a new dot-sourced sibling (for example
  `enforce-epic-worktree-removal-gate-helpers.ps1`), that file MUST be added to `CodeCoverage.Path`.
  The Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` forbids any production file
  sitting outside the denominator, and because this list is an allow-list rather than a glob, an
  unregistered new file is silently excluded. Precedents for exactly this obligation are recorded in
  the file's own comments at lines 132-135, 136-139, 156-162, and 207-214. **Recommendation: keep
  the change inside the existing 274-line file and avoid the obligation entirely.**

- `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` is **NOT** in `CodeCoverage.Path`. This is
  consistent with the Q4 recommendation to leave the codex copy unchanged; changing it would create
  a registration obligation that does not exist today.

### Known caveat on the runner

The MCP PoshQC test runner reads the *installed extension's* settings, so newly added
`CodeCoverage.Path` entries can be ignored when the suite is invoked through MCP. If a coverage
entry is added, verify by invoking the self-hosted PoshQC module directly rather than through the
MCP runner, and treat an MCP-reported coverage figure that omits the new file as a runner artifact
rather than as evidence of a policy violation.

## Recommended fix shape

**One-sentence statement:** add a second, parallel-checkpoint allow-branch to
`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, mirroring the three-branch cascade already
shipped in `.claude/hooks/enforce-epic-merge-gate.ps1`, keyed on `route_id == "parallel"` plus a
normalized `items[].worktree_path` match plus `merge_status` in `{merged, worktree_removed}`;
mirror the edit byte-for-byte into the claude-customizations bundle; extend the existing Pester suite
with the parallel branch cases and add the mandatory parallel-seam `$null` mock to every existing
deny test; and correct the three prose passages that describe the gate contract.

### Ordered change list

1. `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
   - Rewrite `.DESCRIPTION` (lines 5-14) as a numbered two-branch description.
   - Add `$script:ParallelCheckpointPath` next to line 26.
   - Add read seam `Get-EpicWorktreeGateParallelCheckpointContent`.
   - Optionally extract the inline parse (lines 207-213) into a shared
     `ConvertFrom-EpicWorktreeGateJson` helper used by both branches.
   - Add `Test-ParallelCheckpointAllowsWorktreeRemoval`.
   - Insert the branch-2 allow between lines 218 and 220.
   - Replace the deny reason at line 220 with the combined wording, preserving the
     `EPIC_WORKTREE_REMOVAL_BLOCKED:` prefix.
2. Mirror the identical file into the claude-customizations bundle (mandatory; enforced by
   `test_bundled_claude_payload_contains_all_repo_runtime_contracts`).
3. Extend `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` with the 18 new
   cases of Q6 and add the parallel-seam `$null` mock to the five existing deny tests and the
   entry-point `BeforeEach` at lines 165-167. Add the determinism docstring.
4. Update `.claude/skills/parallel-orchestrate/SKILL.md` lines 390-398 and 733-738; mirror into the
   bundle.
5. Add the worktree-gate enforcement bullet to `.claude/rules/parallel-orchestration.md`; mirror into
   the bundle.

### Explicitly out of scope

- The `.codex` copies (Q4).
- `.claude/settings.json` — both gates are already registered at lines 115 and 119.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — both hooks already registered
  (Q8).
- `enforce-parallel-worktree-removal-gate.ps1` — already correct (Q1.2).
- The `--force` extraction defect (Q1.5) — fail-closed and separately trackable.
- Historical feature documents under `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/`
  and `docs/research/` (Q7.6).

### Rejected alternatives

- **Register the parallel gate and de-register the epic gate for parallel runs.** Rejected:
  `.claude/settings.json` hook registration has no conditional/route predicate, so this is not
  expressible. It would also require the epic gate to stop firing entirely, removing the epic
  protection.
- **Have the parallel orchestrator write a shim `epic-orchestrator-state.json` containing a
  `features[]` record for each parallel worktree.** Rejected: it manufactures a malformed epic
  checkpoint to satisfy a gate, would be caught by the epic checkpoint validators, and conflicts
  with the parallel rule's cache doctrine that each surface's checkpoint is derived from its own
  durable state.
- **Relax the epic gate to allow when no epic checkpoint exists.** Rejected: it destroys the
  fail-closed property that is the gate's entire purpose and is explicitly contradicted by the
  hook's own `.NOTES` rationale at lines 11-14.
- **Port the fix to the `.codex` gate as well.** Rejected on the evidence in Q4 — no codex parallel
  surface exists, and the codex merge gate's own lack of a parallel branch is the controlling
  precedent.

## Files the fix will write (exact concrete paths, no globs)

These five paths feed blast-radius derivation. All are repository-relative.

```
.claude/hooks/enforce-epic-worktree-removal-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
.claude/skills/parallel-orchestrate/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
.claude/rules/parallel-orchestration.md
extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
```

Seven paths. Note that `.claude/rules/parallel-orchestration.md` is cited by essentially every
well-formed plan in this repository as a mandated read, and the mandate-read exclusion set in
`config/blast-radius.json` removes such citations from the harvest. Because this fix will genuinely
**write** that file, the planner must append the exact path to the declared radius after
normalization, per constraint 1 of the read-by-mandate classification in
`.claude/rules/parallel-orchestration.md`.

### Paths the fix will NOT write

```
.codex/hooks/enforce-epic-worktree-removal-gate.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1
.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
.claude/settings.json
extensions/drm-copilot/resources/claude-customizations/.claude/settings.json
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
.claude/skills/epic-orchestrate/SKILL.md
```

## Testing implications (strategy only, no test code)

- **Framework and location.** Pester 5, extending the existing suite at
  `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`. Location satisfies the
  mirror-the-source-tree requirement in `.claude/rules/general-unit-test.md`.
- **Isolation.** Every checkpoint fixture is injected through a mocked read-seam function. No test
  touches the real filesystem for a checkpoint, and no test creates a temporary file — the
  repository prohibits temporary files in tests outright.
- **Determinism.** The mandatory parallel-seam `$null` mock in every deny test is the determinism
  control, as analyzed in Q6. Without it the suite reads gitignored state.
- **Scenario completeness.** The 18 cases of Q6 cover positive flows (2 allow branches × 2 statuses),
  negative flows (absent, malformed, wrong route, no match, wrong status, missing key), boundary
  behavior (path separator normalization), branch precedence (epic allow wins over parallel deny),
  and error handling (envelope anomalies, already covered at lines 15-19 and 31-35).
- **Coverage.** Both changed files' hooks are already in `CodeCoverage.Path`, so the new branch lines
  land in the denominator automatically. The direct-predicate cases (13-16) exist specifically to
  reach the guard clauses that the end-to-end cases cannot, mirroring the merge gate's
  `direct branch coverage` contexts at its test lines 245, 315, and 336.
- **Parity verification.** After mirroring, run the two push-down contract tests
  (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and
  `test_push_down_claude_pack_manifest_completeness.py`). Attribute any pre-existing red result to
  issue #510 before concluding the mirror is wrong.
- **No integration test is warranted.** The gate is a pure decision function over injected text; the
  only genuinely external behavior — Claude Code's conjunctive combination of hook decisions — is
  not exercisable from a unit test and is not this repository's code.

## Open items the plan should resolve

1. **Re-confirm byte identity with a real diff.** Q2's identity claims were established by full-text
   reading, not by a hash or diff, because no shell was available. Confirm before relying on "no
   change needed" for copies 3, 4, and 6.
2. **Decide whether to extract the shared JSON parser.** Recommended for symmetry with the merge
   gate, but it touches existing lines 207-213 and slightly widens the diff. Either choice is
   defensible; state it explicitly in the plan.
3. **Record the stale-parallel-checkpoint residual** from Q5 in the plan's risk section so it is a
   documented accepted trade rather than an unexamined gap.
