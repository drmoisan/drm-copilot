# 2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs (Spec)

- **Issue:** #573
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-28T11-05
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** `full-bug` (from `issue.md` line 12). Under `full-bug` this document is the sole acceptance-criteria source; `user-story.md` is deliberately not authored for this defect fix.

## Context
The epic worktree-removal `PreToolUse` gate denies every `git worktree remove` issued by a parallel run, because it authorizes only from a matching epic checkpoint `features[]` record and a parallel run never writes an epic checkpoint. Merged parallel items therefore cannot reach `merge_status: worktree_removed`, and every parallel run leaks one worktree per item.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (PowerShell hook; Python appears only in the push-down contract tests that verify the bundle mirror)
- Command/flags used: `git worktree remove <path>` issued by the parallel-orchestrator after a per-item merge
- Data source or fixture: parallel run `critical-bug-fixes` (11 items, completed 2026-08-26)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Every parallel run leaks one worktree per item (23 leaked in the first full run). Disk and `git worktree list` clutter accumulates; no data loss. The parallel completion predicate keys on `merged`, not `worktree_removed`, so the run still completes and the leak is per-item housekeeping debt rather than a run failure.

## Repro & Evidence
Steps to Reproduce:
1. Complete a parallel-run item to `merge_status: merged` (its PR merged into main).
2. From the parallel-orchestrator, attempt `git worktree remove` on that item's worktree.
3. The hook denies with: `EPIC_WORKTREE_REMOVAL_BLOCKED: ... requires a matching epic checkpoint features[] record with merge_status in {merged, worktree_removed}.`

Expected:
A parallel-run item whose own checkpoint records `merge_status: merged` (re-derivable from `gh pr view`) can have its worktree removed, reaching the `worktree_removed` terminal state defined in `.claude/rules/parallel-orchestration.md`. The gate should carry a parallel allow-branch keyed on the parallel-orchestrator checkpoint, analogous to the parallel allow-branch already present in `.claude/hooks/enforce-epic-merge-gate.ps1`.

Actual:
The gate consults only `artifacts/orchestration/epic-orchestrator-state.json` `features[]`. A parallel run has no such record, and the gate fails closed on its absence. `PreToolUse` denials are conjunctive, so no allow-hook can override it. The removal was attempted during the `critical-bug-fixes` closing pass and denied verbatim; 23 run worktrees remain on disk requiring manual cleanup.

**Correction to the issue text (established by research, not to be re-litigated).** `issue.md` states that "F7 (parallel enforcement hooks, issue #440) shipped no parallel counterpart for this gate." That claim is inaccurate. `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` exists, is registered in `.claude/settings.json` on the `Bash` matcher alongside the epic gate, and returns `permissionDecision = 'allow'` for a merged parallel item. It requires no change. What F7 did not ship is the second half of its own documented obligation: coordinating the epic gate's allow conditions. See Root Cause Analysis.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `EPIC_WORKTREE_REMOVAL_BLOCKED: ... requires a matching epic checkpoint features[] record with merge_status in {merged, worktree_removed}.` (demonstrated 2026-08-26 during the critical-bug-fixes closing pass)
- Research artifact: `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/research/research.2026-08-28T10-05.md`

## Scope & Non-Goals
- In scope:
  - Add a second, parallel-checkpoint allow-branch to `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, forming a two-branch cascade that mirrors the three-branch cascade already shipped in `.claude/hooks/enforce-epic-merge-gate.ps1`.
  - Mirror that edit byte-for-byte into the claude-customizations bundle copy.
  - Extend the existing Pester suite with parallel-branch allow and deny cases, and add the mandatory parallel-seam `$null` mock to every existing deny test.
  - Correct three prose passages whose documented contract becomes false once the code changes: the hook's own `.DESCRIPTION`, two passages in `.claude/skills/parallel-orchestrate/SKILL.md`, and the `## Enforcement` section of `.claude/rules/parallel-orchestration.md` (with the two bundle mirrors of the latter two).

- Out of scope / non-goals:
  - **`.codex/hooks/enforce-epic-worktree-removal-gate.ps1` and its bundle mirror `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1`.** Verified by grep during research: `.codex/hooks/enforce-epic-merge-gate.ps1` has zero matches for `parallel` or `route_id`. The codex runtime has no parallel surface at all — no `enforce-parallel-*` hook, no `parallel-orchestrator.toml` agent, no `.agents/skills/parallel-orchestrate/SKILL.md`, and no parallel hook registered in `.codex/config.toml`. The codex gate is also a materially different implementation (151/152 lines versus 274), using a silent-allow protocol, absolute-path resolution against the payload `cwd`, and no shared payload module; a parallel branch there would be new logic rather than a mirrored edit, would be unexercisable, and would create a second implementation of the allow rule that can drift. The landed convention is decisive: when the parallel surface added an allow-branch to the epic *merge* gate, it added it to the `.claude` copy only. This gate follows the same convention.
  - **`.claude/settings.json` and its bundle mirror.** Both gates are already registered on the `Bash` matcher (lines 115 and 119). No registration change is required, and hook registration carries no route predicate, so a conditional registration is not expressible.
  - **`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.** Test discovery already covers `tests/scripts`, and both hooks are already present in the explicit `CodeCoverage.Path` allow-list. This holds only while the change stays inside the existing 274-line hook file; see the file-size note under Constraints.
  - **`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.** Already correct; it allows for a merged parallel item today.
  - **The `--force` path-extraction defect.** Both `.claude` gates extract the removal target with `'(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)'`, so `git worktree remove --force <path>` captures `--force` as the path and denies. This is fail-closed and therefore safe, and `.claude/skills/cleanup-merged-worktrees/SKILL.md` forbids the force flag. Widening the regex would change epic-path behavior currently pinned by tests. Separately trackable; not fixed here.
  - **`.claude/skills/epic-orchestrate/SKILL.md`.** Its description of the gate remains accurate for an epic run: branch 1 is unchanged and is evaluated first.
  - **Historical feature documents** under `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/` and `docs/research/`. These record the state of the world at their authoring time and are not live contracts.

- Explicitly excluded systems, integrations, or datasets: the codex runtime surface in its entirety; the `.agents` surface; the MCP TypeScript validators (this fix touches no validator and adds no `artifact_type`); no JSON Schema is authored, imported, or read at any point.

### Policy resolution — writing `.claude/rules/parallel-orchestration.md`
`.claude/skills/policy-compliance-order/SKILL.md` line 32 states "Do NOT modify policy documents under `.claude/rules/` or `.github/instructions/`." This fix writes `.claude/rules/parallel-orchestration.md`. The edit is justified, and the justification is recorded here so a later reviewer does not read it as a violation:

1. **CLAUDE.md scopes the canonical-source prohibition to `.github/`.** Its "Policy Compliance Reading Order" section names `.github/copilot-instructions.md` and `.github/instructions/*` and states "These files are the canonical policy source. Do not modify them. `.claude/` files mirror or reference their content." `.claude/rules/parallel-orchestration.md` mirrors nothing under `.github/instructions/` — the enumerated instruction files are general, tonality, and the four language pairs plus GitHub Actions and mermaid. It is a repository-local rule authored by the parallel-surface features themselves.
2. **The rule file carries its own amendment provision.** Its "Enum Ownership" section states that a feature needing a change "must amend this rule file and the validators at spec review, not add the member at implementation time." The provision presumes amendment at spec review, which is precisely when this document authorizes it.
3. **There is landed precedent.** Issue #502 amended the same file as a first-class deliverable with a dedicated QA gate at `docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/rule-file-amendment.md`, and mirrored the amendment into the bundle.
4. **Declining the edit has a cost.** The file's `## Enforcement` section records the merge gate's parallel allow-branch verbatim and would, after this change, be silently incomplete about the worktree gate's. An enforcement section that omits half the enforcement is worse than the edit it avoids.

Scope limit on the edit: append one enforcement bullet describing the worktree gate's parallel allow-branch. Do not alter the Foreign Schema Warning, any numbered invariant, any enum table row, or the Cache Doctrine. No new invariant, enum member, or configuration key is introduced.

## Root Cause Analysis
The gate predates the parallel surface and was written epic-singular, and the parallel surface's own enforcement feature landed only half its obligation.

**The deciding execution chain** in `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`:

1. Line 199 — the in-scope check `if ($commandText -notmatch '(?i)\bgit\s+worktree\s+remove\b')` does not fire for a parallel removal, so the early allow is not taken.
2. Line 205 — `Get-EpicWorktreeGateCheckpointContent` is the only read seam in the file. It reads `$script:EpicCheckpointPath` (`artifacts/orchestration/epic-orchestrator-state.json`, line 26) and returns `$null` when the file is absent (lines 41-43). A parallel run never writes that file.
3. Lines 89-91 — `Find-EpicWorktreeFeatureRecord` returns `$null` for a `$null` checkpoint.
4. Lines 131-133 — `Test-EpicWorktreeRemovalAllowed` returns `$false` for a `$null` record.
5. Line 220 — the terminal deny is emitted.

**The parallel gate is not the defect.** `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` matches `items[].worktree_path` (lines 108-117) and allows when `merge_status` is in `@('merged', 'worktree_removed')` (lines 138-145, script variable at line 34), returning an allow at lines 222-225. Both gates fire on the same `Bash` matcher, and `PreToolUse` denials are conjunctive, so the parallel gate's allow cannot override the epic gate's independent deny.

**The defect was predicted verbatim in committed prose.** `.claude/skills/parallel-orchestrate/SKILL.md` lines 390-398 already state:

> A parallel run has no epic checkpoint record for its worktrees, so removal is denied until F7 both delivers `enforce-parallel-worktree-removal-gate.ps1` and coordinates the epic gate's allow conditions: `PreToolUse` denials are conjunctive, so a new allow-hook alone cannot override the existing deny.

F7 (issue #440) delivered the first conjunct and not the second. Issue #573 is exactly the residual of that half-completed obligation. This is why the fix belongs in the *epic* gate rather than anywhere else, and why the corrective prose edit is part of the fix rather than optional documentation hygiene.

## Proposed Fix

### Design summary (what changes where):
Convert `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` from a single-branch authorization into a two-branch disjunctive cascade with one terminal deny, mirroring the structure of `.claude/hooks/enforce-epic-merge-gate.ps1` reduced from three branches to two (there is no child-checkpoint analogue for worktree removal).

- **Branch 1 (existing, unchanged, evaluated first):** the epic checkpoint carries a `features[]` record whose normalized `worktree_path` matches the removal target and whose `merge_status` is in `{merged, worktree_removed}`.
- **Branch 2 (new):** the parallel-orchestrator checkpoint at `artifacts/orchestration/parallel-orchestrator-state.json` has `route_id` exactly `parallel`, and carries an `items[]` entry whose normalized `worktree_path` matches the removal target and whose `merge_status` is in `{merged, worktree_removed}`.
- **Terminal deny:** when neither branch authorizes, deny with a combined reason preserving the `EPIC_WORKTREE_REMOVAL_BLOCKED:` prefix.

Prose is corrected in three places so the documented contract matches behavior, and every changed `.claude/**` file is mirrored into the claude-customizations bundle.

### Boundaries and invariants to preserve:
- **Fail-closed is the gate's purpose.** Every failure mode — neither checkpoint present, either checkpoint unparseable, `route_id` absent or not `parallel`, no matching `worktree_path`, matched item with a non-authorizing `merge_status`, matched item with no `merge_status` key — must fall through to the deny. The cascade is a disjunction of two positive predicates; there is no negative path that returns allow.
- **The envelope-anomaly deny (lines 187-192) remains the first check** and must not be moved behind the new branch.
- **The `EPIC_WORKTREE_REMOVAL_BLOCKED:` reason prefix is preserved verbatim.** Seven assertions in `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` match it (lines 18, 66, 74, 86, 98, 183, 223), and `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` line 338 matches the same token for the codex gate. No `PARALLEL_` prefix is introduced on this gate: two gates emitting the same prefix would make transcript attribution ambiguous. The parallel gate owns `PARALLEL_WORKTREE_REMOVAL_BLOCKED`; this gate keeps `EPIC_WORKTREE_REMOVAL_BLOCKED` for both branches, exactly as `enforce-epic-merge-gate.ps1` emits `EPIC_MERGE_GATE_BLOCKED` for its parallel branch.
- **Branch 1 behavior is bit-for-bit unchanged.** Every input that allowed before still allows; the only newly-allowed inputs are those where branch 1 denies and all of branch 2's conjuncts hold.
- **Path normalization is shared, not re-derived.** Branch 2 uses the same `(-replace '\\', '/').TrimEnd('/')` normalization as lines 97 and 106, so the two branches and the sibling parallel gate agree by construction.
- **Path is the only correct key for removal.** Do not key branch 2 on `pr_number`. The merge gate keys on `pr_number` because the command names a PR; the removal command names a path.
- **The read seam must be a distinct named function.** Tests mock the seam function, not the filesystem. A shared or inlined read would make the two branches unmockable independently and break the suite's isolation model.
- **No JSON Schema.** Enforcement stays prose plus hook logic, per the doctrine in `.claude/rules/parallel-orchestration.md`.

### Dependencies or blocked work:
- No blocking dependency. `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` and both gate registrations already exist.
- Related: issue #440 (F7 parallel enforcement hooks), whose second conjunct this fix completes.
- Known unrelated condition: issue #510 records a bundle-parity test that can be red locally on gitignored state while green in CI. A red push-down contract result must be attributed before it is treated as caused by this change.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
Exactly seven files, all repository-relative, no globs:

```
.claude/hooks/enforce-epic-worktree-removal-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1
tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
.claude/skills/parallel-orchestrate/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
.claude/rules/parallel-orchestration.md
extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
```

The three `.claude/**` files and their three bundle mirrors are byte-identical pairs. Byte identity of the gate pair was re-confirmed by a real `git diff` during orchestration (the research session had no shell and established it by full-text reading only). Mirroring is mandatory and is enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, which asserts UTF-8 text equality over the whole `.claude/**` tree with only `.claude/settings.local.json` and `.claude/agent-memory/**` exempt.

Note for blast-radius declaration: `.claude/rules/parallel-orchestration.md` is a mandate-read path excluded from the harvest by `config/blast-radius.json`. Because this fix genuinely writes it, the planner must append the exact path to the declared radius after normalization, per constraint 1 of the read-by-mandate classification in that same rule file.

No new file is created. Keeping the change inside the existing 274-line hook avoids three otherwise-mandatory registrations: the bundle, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and `CodeCoverage.Path`.

#### Functions/classes/CLI commands impacted:
In `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`:

- `$script:ParallelCheckpointPath` — new script variable, `'artifacts/orchestration/parallel-orchestrator-state.json'`, adjacent to line 26.
- `Get-EpicWorktreeGateParallelCheckpointContent` — new read seam, structurally mirroring `Get-EpicWorktreeGateCheckpointContent` (lines 29-45) against the parallel path. Returns `$null` when the file is absent.
- `Test-ParallelCheckpointAllowsWorktreeRemoval -Checkpoint -WorktreePath` — new predicate returning `[bool]`. Returns `$false` for a `$null` checkpoint, `$false` unless `route_id` is exactly `parallel`, `$false` when `items` is absent, scans `items[]` skipping entries with no `worktree_path`, and returns `$true` only when the matched entry's `merge_status` is in `@('merged', 'worktree_removed')`.
- Optional, at the plan's discretion and to be stated explicitly there: extract the inline parse at lines 207-213 into a shared `ConvertFrom-EpicWorktreeGateJson` helper used by both branches, matching the merge gate's `ConvertFrom-EpicMergeGateJson`. Recommended for symmetry; it slightly widens the diff by touching existing lines. Either choice is acceptable provided the plan records which was taken.
- `Invoke-EpicWorktreeRemovalGateDecision` — the branch-2 allow is inserted between the existing epic allow (lines 216-218) and the deny (line 220); the deny reason is replaced with the combined wording.
- `.DESCRIPTION` (lines 5-14) — rewritten as a numbered two-branch description following `enforce-epic-merge-gate.ps1` lines 5-27, including the fail-closed statement and the mutual-exclusivity argument.

`Get-EpicWorktreeRemovalCommandPath`, `Find-EpicWorktreeFeatureRecord`, `Test-EpicWorktreeRemovalAllowed`, `Get-EpicWorktreeGateAllowDecision`, `Get-EpicWorktreeGateBlockDecision`, and `Invoke-EpicWorktreeRemovalGateEntryPoint` are unchanged. No CLI command changes; no MCP surface changes.

#### Data flow and validation changes:
The gate gains a second read of a second untracked JSON document. Flow after the change:

1. Parse envelope. Anomaly -> deny (first, unchanged).
2. No `command` string, or command is not `git worktree remove` -> allow (unchanged).
3. Extract the target path (unchanged regex).
4. Read and parse the epic checkpoint; evaluate branch 1. Allow on success.
5. Read and parse the parallel checkpoint; evaluate branch 2. Allow on success.
6. Deny.

Branch 2 validates only the three fields it needs — `route_id`, `items[].worktree_path`, `items[].merge_status` — and does not re-implement the parallel checkpoint validators. `route_id == 'parallel'` is checked because it is orchestrator invariant 2 in `.claude/rules/parallel-orchestration.md` ("Route identity. `route_id` must be exactly `'parallel'`"), so a document at that path failing the check is malformed by the rule's own definition; the check also makes a non-parallel document that happens to sit at the parallel path inert. `merged` and `worktree_removed` are members of the eight-value `merge_status` enum fixed by invariant 7, and invariant 8 requires an item at either value to have `state == 'merged'`.

#### Error handling and logging updates:
- Both reads are guarded: an absent file yields `$null` from the seam; an empty or unparseable body yields `$null` from the parse inside a `try`/`catch`. Neither raises.
- The terminal deny reason enumerates both branches in a single sentence, following the merge gate's enumerate-then-conclude form, preserving the `EPIC_WORKTREE_REMOVAL_BLOCKED:` prefix and the existing single-quoted `'$worktreePath'` interpolation. Proposed wording:

  ```
  EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '<path>' requires either an epic checkpoint features[] record with merge_status in {merged, worktree_removed}, or a parallel-orchestrator checkpoint with route_id == "parallel" whose matching items[] record (matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint authorized this removal.
  ```

- The entry point still always returns exit code 0; `exit 1` is non-blocking for `PreToolUse`, so every anomaly is already a deny decision. This is unchanged.
- No new logging channel, telemetry field, or output stream is added. The hook's only output remains the compact decision JSON.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. A flag would add a second reachable configuration of an enforcement gate and a second state to test, for a change whose whole content is one additional allow-branch. Rollback is reverting the commit; because branch 1 is untouched, reverting restores exactly the pre-change behavior with no data or state migration.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- **Input:** the `PreToolUse` envelope JSON on stdin, read through the existing `Read-ClaudeHookRawPayload` seam and resolved by `Resolve-ClaudeHookToolInput`. The only field consumed is `tool_input.command`.
- **New input:** `artifacts/orchestration/parallel-orchestrator-state.json`, read as raw UTF-8 text through `Get-EpicWorktreeGateParallelCheckpointContent`. Consumed fields: `route_id` (string), `items[].worktree_path` (string), `items[].merge_status` (string).
- **Output:** unchanged. A compact JSON object `{ hookSpecificOutput: { hookEventName: 'PreToolUse', permissionDecision: 'allow' } }` or the same with `permissionDecision: 'deny'` and `permissionDecisionReason`. Depth 5, compressed. Process exit code 0 in all cases.

#### Required configuration keys and defaults:
None. No configuration key is added or read. The two checkpoint paths remain hard-coded script variables, consistent with the existing gate and with `enforce-epic-merge-gate.ps1`. Both hooks are already registered in `.claude/settings.json` and in `CodeCoverage.Path`.

#### Backward-compatibility expectations:
- Epic runs: no observable change. Branch 1 is evaluated first and is unmodified.
- Standalone (non-epic, non-parallel) runs: no observable change. A standalone run writes neither checkpoint, so both branches deny, as before.
- The deny reason *text* changes while the `EPIC_WORKTREE_REMOVAL_BLOCKED:` *prefix* does not. Any consumer matching on the prefix is unaffected; a consumer matching on the full sentence would break, and no such consumer exists in the repository (all seven in-repo assertions match the prefix or a prefix-anchored fragment).
- The hook's public function set grows by two functions and one script variable. All existing function names, parameters, and return types are unchanged.

#### Performance constraints (latency/throughput/memory):
The gate gains one `Test-Path` and, when the file exists, one `Get-Content -Raw` plus one `ConvertFrom-Json` per in-scope command. Both reads occur only after the command has already matched `git worktree remove`, so no additional I/O is added to the common path of unrelated `Bash` calls. The added cost is a single small local-file read on a command that is itself a filesystem mutation; no measurable latency constraint applies and none is asserted.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - `PreToolUse` hook decisions combine conjunctively — any deny wins. This is asserted by committed repository prose (`.claude/skills/parallel-orchestrate/SKILL.md` lines 396-397) and corroborated by the field outcome of 2026-08-26, where both gates fired and the removal was denied with the epic gate's reason while the parallel gate allowed. It was not re-verified by execution; verification would require observing the runtime's hook combination, which is not this repository's code.
  - The parallel-orchestrator writes `worktree_path` into `items[]` in a form that normalizes to the same string the removal command names. The sibling parallel gate already depends on this and works.
  - `artifacts/` remains gitignored, so `parallel-orchestrator-state.json` is untracked local state. This is the premise of the determinism obligation below and of the accepted residual risk.
- Constraints (budget, performance, compatibility):
  - PowerShell 7+ compatibility; no external module dependency beyond the existing `../lib/hook-payload/HookPayload.psm1` import.
  - PowerShell change budget: the production-file cap is at most 3 production files per batch. This change touches two production PowerShell files (the hook and its bundle mirror, which are the same content) plus one test file, so it is within budget.
  - 500-line file limit. The gate is 274 lines; the addition is expected to land near 340. If a plan revision would push it over 500, splitting into a dot-sourced sibling incurs three new obligations — bundle mirror, `pack-manifests/core.json` entry, and a `CodeCoverage.Path` entry, because that list is an explicit allow-list and an unregistered production file is silently excluded from the coverage denominator in violation of the Coverage Exclusion Policy. Keeping the change in one file is required unless the plan explicitly accepts all three.
  - Temporary files in tests are prohibited outright. All checkpoint fixtures are injected as literal JSON strings through mocked read seams.
- External dependencies (services, libraries, releases):
  - None. No network access, no `gh`, no `git` invocation from the hook, no new package.
  - Verification depends on the PoshQC toolchain (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) and on pytest for the two push-down contract tests.

## Data / API / Config Impact
- User-facing or API changes: none. No CLI flag, no MCP tool, no `artifact_type`, no schema. The only externally visible change is that a merged parallel item's `git worktree remove` is now authorized instead of denied, and that the deny sentence for the unauthorized case enumerates two branches instead of one.
- Data or migration considerations: none. No checkpoint field is added, removed, or reinterpreted. The parallel checkpoint is read, never written, by this gate. No migration of existing checkpoints is required, and the already-leaked worktrees from the `critical-bug-fixes` run are cleaned up operationally, not by a migration.
- Logging/telemetry updates (if any): none beyond the revised deny reason string described above.
- Compatibility notes (CLI flags, config schemas, versioning): no version bump is implied. `.claude/settings.json` and `pester.runsettings.psd1` are unchanged. The claude-customizations bundle payload changes content but not its file list, so `pack-manifests/core.json` is unchanged (the gate is already listed at line 31).

## Test Strategy
Framework: Pester 5, extending the existing suite at `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` (currently 236 lines, ten `Context` blocks). No new test file is created; the location already mirrors the source tree as required.

Seeded from issue:

- [ ] Pester cases: parallel item merged — allow; parallel item not merged — deny; no parallel checkpoint — deny (unchanged epic behavior); epic path unchanged.
- [ ] ~~Propagate to `.codex` and extension-resource copies per surface parity.~~ Amended: propagate to the **claude-customizations** extension-resource copy only. The `.codex` copies are an explicit non-goal for the reasons recorded under Scope & Non-Goals.
- [ ] Manual verification: rerun the denied removal from the completed run.

- Regression tests to add or update:
  - Existing epic allow tests (`merge_status` merged; `merge_status` worktree_removed; separator normalization) re-run with the parallel seam mocked to `$null`; each must produce the identical decision it produces today.
  - Existing deny tests (unreadable checkpoint x2, no matching record, other `merge_status`) plus the entry-point `BeforeEach` (lines 165-167, covering seven entry-point tests) each gain a parallel-seam `$null` mock.
  - New: epic checkpoint authorizes and the parallel checkpoint denies -> allow, proving the branches are ORed rather than ANDed.
- Unit tests for the fixed behavior and boundaries (the framework here is Pester, not pytest; the template's pytest wording does not apply to a PowerShell hook):
  - Allow: `route_id == "parallel"`, matching `items[].worktree_path`, `merge_status == "merged"`, epic seam `$null`.
  - Allow: same with `merge_status == "worktree_removed"`.
  - Allow: parallel branch honors separator normalization (backslash in the checkpoint, forward slash in the command), mirroring the existing epic normalization test.
  - Direct predicate coverage of `Test-ParallelCheckpointAllowsWorktreeRemoval`, reaching guard clauses the end-to-end cases cannot: `$null` checkpoint; checkpoint lacking `route_id`; checkpoint lacking `items`; an item lacking `worktree_path` (skipped, not matched). This mirrors the merge gate's `direct branch coverage` contexts.
  - Read-seam coverage of `Get-EpicWorktreeGateParallelCheckpointContent`: returns `$null` when `Test-Path` is mocked `$false` for `$script:ParallelCheckpointPath`; returns content when `Test-Path` is mocked `$true` and `Get-Content` is mocked with `-ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }`.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Parallel checkpoint present, matching item, `merge_status == "pr_open"` -> deny.
  - Parallel checkpoint present with a merged matching item but `route_id` absent or not `"parallel"` -> deny (proves the route guard).
  - Parallel checkpoint present, `route_id == "parallel"`, no `items` key -> deny.
  - Parallel checkpoint present, no `items[]` entry matching the target path -> deny.
  - Parallel checkpoint content is malformed JSON -> deny.
  - Matching item carrying no `merge_status` key -> deny.
  - Both seams `$null` -> deny (the #573 field scenario inverted: no parallel checkpoint means unchanged epic behavior).
  - Envelope anomaly -> deny, still emitted before any checkpoint read.
- Error handling and logging verification: every deny case asserts the reason matches `EPIC_WORKTREE_REMOVAL_BLOCKED`; no case asserts the full revised sentence, so the wording stays revisable. The entry point returns exit code 0 in every case, including every deny.
- Coverage impact and targets for changed lines/modules: line coverage must remain at or above 85% for the changed hook, with no regression on changed lines. Branch coverage has no threshold for PowerShell because Pester does not measure it. Both hooks are already in `CodeCoverage.Path`, so the new lines land in the denominator automatically without a settings edit. If a coverage figure is obtained through the MCP PoshQC runner and appears to omit an expected file, re-verify by invoking the self-hosted PoshQC module directly before treating it as a policy violation; the MCP runner reads the installed extension's settings.
- Toolchain commands to run (format -> lint -> type-check -> test): PoshQC format (`run_poshqc_format`) -> PSScriptAnalyzer (`run_poshqc_analyze`) -> type check **not applicable to PowerShell**, skipped per `.claude/rules/powershell.md` -> Pester (`run_poshqc_test`). Restart from format if any stage fails or changes a file. Separately, run `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` to verify the bundle mirror.
- Manual validation steps (if required): from the main checkout with a parallel checkpoint recording a merged item, issue `git worktree remove` for that item's path and confirm the command is permitted and that neither gate emits a deny. No integration test is warranted: the gate is a pure decision function over injected text, and the only genuinely external behavior — the runtime's conjunctive combination of hook decisions — is not exercisable from a unit test and is not this repository's code.

## Acceptance Criteria
- [ ] A `git worktree remove <path>` whose normalized path matches an `items[]` entry with `merge_status: "merged"` in a parallel checkpoint carrying `route_id == "parallel"` is allowed by `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` when the epic seam returns `$null`, proven by a passing Pester test.
- [ ] The same case with `merge_status: "worktree_removed"` is allowed, proven by a separate passing Pester test.
- [ ] The parallel branch applies the same path normalization as the epic branch: a checkpoint path written with backslashes matches a command path written with forward slashes, proven by a passing Pester test.
- [ ] Fail-closed is preserved for every one of the following, each proven by its own passing Pester test asserting a deny: both seams return `$null`; the parallel checkpoint body is malformed JSON; `route_id` is absent or is not `"parallel"` while a merged matching item is present; `route_id == "parallel"` but no `items` key exists; no `items[]` entry matches the target path; the matched item's `merge_status` is `"pr_open"`; the matched item carries no `merge_status` key.
- [ ] The envelope-anomaly deny remains the first check in `Invoke-EpicWorktreeRemovalGateDecision` and is emitted before either checkpoint is read, proven by the existing anomaly tests passing unmodified in ordering behavior.
- [ ] Epic-branch behavior is unchanged: the pre-existing epic allow tests (`merged`, `worktree_removed`, separator normalization) and the pre-existing epic deny tests produce the identical decisions they produced before the change.
- [ ] Branch precedence is proven ORed, not ANDed: a case where the epic checkpoint authorizes and the parallel checkpoint does not is allowed, by a passing Pester test.
- [ ] `Test-ParallelCheckpointAllowsWorktreeRemoval` has direct predicate tests covering `$null` checkpoint, checkpoint lacking `route_id`, checkpoint lacking `items`, and an item lacking `worktree_path`, each returning `$false`.
- [ ] `Get-EpicWorktreeGateParallelCheckpointContent` exists as a distinct named read seam and has read-seam tests covering the `Test-Path` false case (returns `$null`) and the `Test-Path` true case with `Get-Content` mocked under `-ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }`.
- [ ] Every deny-expecting test in `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` — including the entry-point `BeforeEach` — mocks the new parallel read seam to `$null`, so no test reads the real gitignored `artifacts/orchestration/parallel-orchestrator-state.json`. The test file states this determinism rule in its file docstring, matching the statement already present in `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`.
- [ ] No test in the suite creates a temporary file or reads a real checkpoint from disk; every checkpoint fixture is a literal JSON string injected through a mocked seam.
- [ ] Every deny reason emitted by the gate begins with the literal `EPIC_WORKTREE_REMOVAL_BLOCKED:`, and no reason string in this hook introduces a `PARALLEL_` prefix.
- [ ] `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` passes unmodified, and neither `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` nor `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` appears in the diff.
- [ ] `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` are byte-identical after the change, as are the two `parallel-orchestrate/SKILL.md` copies and the two `parallel-orchestration.md` copies; verified by a passing `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- [ ] `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` passes, and `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` is unchanged (no new file was created).
- [ ] The gate's `.DESCRIPTION` describes both branches as a numbered cascade, states the fail-closed rule, and no longer describes the gate as consulting only the epic checkpoint.
- [ ] `.claude/skills/parallel-orchestrate/SKILL.md` lines 390-398 no longer state that removal "is denied until F7 both delivers ... and coordinates the epic gate's allow conditions"; the replacement records that both halves have landed and retains the explanation that `PreToolUse` denials are conjunctive.
- [ ] `.claude/skills/parallel-orchestrate/SKILL.md`'s worktree-removal-gate passage (near line 733) additionally notes that the epic gate fires on the same command and now carries a matching parallel allow-branch, so both gates must allow for the removal to proceed.
- [ ] The `## Enforcement` section of `.claude/rules/parallel-orchestration.md` gains a bullet describing the worktree gate's parallel allow-branch (`route_id == "parallel"`, normalized `items[].worktree_path` match, `merge_status` in `{merged, worktree_removed}`, fail closed with `EPIC_WORKTREE_REMOVAL_BLOCKED`), alongside the existing merge-gate bullet.
- [ ] The rule-file edit is confined to appending that enforcement bullet: no numbered invariant, no enum table row, no Foreign Schema Warning text, and no Cache Doctrine text is altered, verified against a merge-base-anchored diff of that file recorded under `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/evidence/qa-gates/`.
- [ ] No file outside the seven listed under "Files/modules to change" appears in the change's diff.
- [ ] The full PowerShell toolchain passes in a single clean pass in order — PoshQC format, then PSScriptAnalyzer with zero findings, then Pester with zero failures (type checking is not applicable to PowerShell) — with the run output and the reported line coverage for the changed hook recorded under `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/evidence/regression-testing/`.
- [ ] Line coverage for `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is at or above 85% and shows no regression on the changed lines.

## Risks & Mitigations
- Technical or operational risks:
  - **Accepted residual: a stale parallel checkpoint can authorize a path.** `artifacts/` is gitignored (`.gitignore` line 6), so `parallel-orchestrator-state.json` persists on disk after a run ends and remains readable by the gate. For a stale document to authorize a removal it should not, a worktree would have to be created at a path that, after separator normalization and trailing-slash trim, is byte-identical to a path recorded in the stale checkpoint with `merge_status` in `{merged, worktree_removed}`. Worktree paths in this repository carry a session or timestamp component, so a collision is implausible; and where the recorded status is `worktree_removed`, the path was already deleted, so any directory recreated there is a distinct directory that happens to share a name. This is recorded as a documented accepted trade rather than an unexamined gap. The `route_id` check does not reduce this specific residual (a stale parallel checkpoint legitimately carries `route_id == "parallel"`); it guards a different case.
  - **Double-allow weakening.** The authorization is a property of the path, not of the caller: an allow fires only when a checkpoint records that exact worktree path as already merged or already removed, and the safety property the gate protects — do not destroy unmerged work — is a property of the path's merge state. This argument is stronger than the merge gate's, whose key is a PR number drawn from a repository-global namespace where a cross-surface collision is at least expressible; worktree paths are per-run and per-item.
  - **Test non-determinism introduced by the second read seam.** Without the mandatory parallel-seam `$null` mock, every existing deny test would read gitignored local state and pass or fail depending on whether a parallel run happens to be live on the machine — the failure class of issue #510. This is a required invariant, not a suggestion; both precedents already apply it (`enforce-epic-merge-gate.Tests.ps1` mocks `Get-ParallelOrchestratorCheckpointContent` to `$null` at lines 91, 105, 117, 127, 188, and in its entry-point `BeforeEach` at line 378; `enforce-parallel-worktree-removal-gate.Tests.ps1` states the rule in its file docstring at lines 7-11).
  - **Prose drifting from behavior.** The defect's own root cause includes prose that described an unfinished obligation and was never revisited. Leaving the three passages uncorrected would recreate that condition in mirror image, with prose describing an epic-only gate that is no longer epic-only.
  - **Bundle mirror omission.** A `.claude/**` edit without its mirror fails the push-down contract test with `Bundle content differs from repo for: <path>`.
  - **Pre-existing red from issue #510.** A local push-down contract failure may predate this change. Attribute the failure before concluding the mirror is wrong.
- Mitigations and rollbacks:
  - The residual risk is documented here and in the hook's `.DESCRIPTION`; no code mitigation is added because the only available one (narrowing on run identity) does not address the collision case and would weaken the legitimate path.
  - The determinism obligation is an explicit acceptance criterion and a test-file docstring statement, so a later contributor adding a deny test inherits the rule.
  - Prose correctness is carried by four acceptance criteria, one per passage plus a scope-limit check on the rule-file diff.
  - Mirror correctness is carried by an acceptance criterion bound to the push-down contract test rather than to manual inspection.
  - Rollback is a straight revert. Branch 1 is untouched, no state is migrated, and reverting restores the pre-change behavior exactly.

## Rollout & Follow-up
- Release/rollout steps:
  1. Land the seven-file change on a single branch with a pull request against `main`.
  2. Run the PowerShell toolchain to a clean single pass and the two push-down contract tests.
  3. No version bump, no configuration change, and no user action are required. The `.claude/` runtime change takes effect for the self-hosted repository on merge.
  4. The bundled copy reaches an installed extension only after the extension is rebuilt and reinstalled; a repository-side `resources/` edit does not change what a push-down writes until then. This is expected and is not a defect of this change.
- Post-fix monitoring or clean-up tasks:
  - Manually remove the 23 worktrees leaked by the `critical-bug-fixes` run (completed 2026-08-26). This is operational cleanup and is not gated by this fix.
  - On the next parallel run, confirm that each merged item reaches `merge_status: worktree_removed` and that `git worktree list` is clean at run close.
  - Consider filing the `--force` path-extraction defect (both `.claude` gates capture `--force` as the removal path) as a separate issue. It is fail-closed today and is an explicit non-goal here.
  - Revisit the `.codex` gate only if and when a codex parallel surface is built, at which point the branch can be exercised.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/573
  - Related issue: #440 (F7 parallel enforcement hooks) — this fix completes F7's second conjunct.
  - Related issue: #510 (bundle-parity test red locally on gitignored state) — attribution caveat for the push-down contract tests.
  - Research: `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/research/research.2026-08-28T10-05.md`
  - Precedent implementation: `.claude/hooks/enforce-epic-merge-gate.ps1`
  - Precedent rule-file amendment: `docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/rule-file-amendment.md`
  - Contract rule: `.claude/rules/parallel-orchestration.md`
