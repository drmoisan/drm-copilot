# Research: sanctioned removal manifest for `cleanup-merged-worktrees` (Issue #635)

- Date: 2026-09-07
- Branch: `bug/cleanup-worktrees-sanctioned-removal-manifest-635`
- Workspace: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a47a5e3350ed0e0de`
- Scope: epic child D of `cleanup-merged-worktrees-hardening`; gaps 3 and 9a
- Status: research complete; `spec.md` in this feature folder is still an unfilled template (226 lines,
  headings present, bodies empty from line 100 onward), so nothing here contradicts an approved spec.

Every claim below was re-derived against the current tree on this branch. Where a fact supplied in
the delegation prompt or in `issue.md` proved wrong, the correction is stated explicitly.

---

## 0. Corrections to facts supplied for this task

| Supplied claim | Verified state | Impact |
| --- | --- | --- |
| `enforce-epic-worktree-removal-gate.ps1` is 418 lines | **419 lines.** Last line is `exit ([int]$entryPointResult[-1])` at :419. | Headroom is 81, not 82. Cosmetic. |
| `enforce-parallel-worktree-removal-gate.ps1` is 280 lines | **281 lines.** Last line at :281. | Headroom is 219. Cosmetic. |
| `enforce-pr-author-skill.ps1` runs "five receipt checks" | **Six.** `enforce-pr-author-skill-helpers.ps1:9` and :36-45 say six; the parent hook's docstring at `enforce-pr-author-skill.ps1:25` and its decision-order list at :29-30 say five and omit check 6. See the Numeric Derivation Evidence section. | In-repo documentation discrepancy. Does not change the R7 conclusion. |
| Issue #545 "replaces the substring command matching in the gate hooks — including the regex cited above" | **False.** #545's approved `spec.md` places both worktree-removal gates **out of scope** (:153-158) and carries an acceptance criterion requiring they "carry no diff" (:807-810). | Load-bearing. See R6. |
| #545 introduces "a shared, tested command-word parser in a new `.claude/lib/**/*.psm1` module" | **False.** #545 D7 (:446-462) settles the name `hook-command-scanner.ps1`, a dot-sourced entrypoint-free `.ps1` at `.claude/hooks/`, `.codex/hooks/`, and both bundle roots, "because the `.codex` side has no `lib/` directory" (:602-603). The file does not exist in the tree today. | Load-bearing. See R6. |
| The observation's claim that SKILL.md step 9 instructs a manual `git worktree remove` | **False**, as the delegation prompt already noted. `SKILL.md:212-214` authorizes only "clear the dirty working tree" and "delete a disposable `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS` branch directly". `SKILL.md:193-194` forbids `git worktree remove` for orphaned directories; :236-237 forbids force flags. | Load-bearing. See R1. |
| "the skill's `allowed-tools` list does not grant `Bash(git worktree remove*)` at all … the removal is therefore blocked twice over" (`issue.md:19-20`, :70-73) | The skill list omits it (`SKILL.md:4-23`), but `.claude/settings.json:5` grants `Bash(git *)` at the project permission layer and the `deny` list (:68-73) contains no Bash entry. | The *hooks* are the verified blocker. Whether a skill's `allowed-tools` further narrows a project allow is runtime composition I cannot verify from repository content. Do not write an acceptance criterion that asserts a permission-layer block. |

Facts confirmed exactly as supplied: `SKILL.md` is 264 lines with headings at 25, 41, 57, 73, 122,
129, 231, 253; the `<N> = 396` literal is at `SKILL.md:104` and is its only occurrence; the regex
`'(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)'` is at `enforce-epic-worktree-removal-gate.ps1:147`
with `.Trim('"''')` at :148 and byte-identically at `enforce-parallel-worktree-removal-gate.ps1:70-71`;
both hooks are registered on the `Bash` matcher at `.claude/settings.json:115` and :119;
`.claude/lib/hook-payload/HookPayload.psm1` is 496 lines; the two Pester suites are 428 and 392 lines.

---

## 1. Current state

### 1.1 The two gates

`.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (419 lines) and
`.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (281 lines) are pure decision functions
over injected text. Both:

1. Resolve the PreToolUse envelope through `Resolve-ClaudeHookToolInput` (epic :334, parallel :193)
   and deny on an envelope anomaly (epic :335-340, parallel :194-199).
2. Extract `tool_input.command` via `Get-ClaudeHookToolInputString ... -Name 'command'`
   (epic :342, parallel :201) and **allow** when it is empty (epic :344, parallel :203).
3. **Allow** when the command text does not match `'(?i)\bgit\s+worktree\s+remove\b'`
   (epic :347-349, parallel :206-208).
4. Extract the target path (epic :351 → :131-151, parallel :210 → :54-74).
5. Consult checkpoints and allow only on a positive match; otherwise deny.

The epic gate's cascade is a disjunction of two positive predicates, evaluated in order and
documented as ORed at :9-11:

- Branch 1 — epic checkpoint `features[]` matched by `worktree_path`, `merge_status` in
  `@('merged','worktree_removed')` (:65, :153-196, :198-223, called at :355-358).
- Branch 2 — parallel checkpoint with `route_id == 'parallel'`, `items[]` matched by
  `worktree_path`, same `merge_status` set (:225-287, called at :360-363).
- Otherwise `Get-EpicWorktreeGateBlockDecision` with `EPIC_WORKTREE_REMOVAL_BLOCKED` (:365).
  There is no third branch.

The parallel gate has one positive predicate (`items[]` by `worktree_path` + `merge_status`,
:76-146, called at :222-225) and otherwise denies with `PARALLEL_WORKTREE_REMOVAL_BLOCKED` (:227).

Branch 2 of the epic gate exists because of issue #573
(`docs/features/completed/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/spec.md`).
That is the direct precedent for adding a further positive predicate to this cascade.

### 1.2 A third, structurally different copy on the Codex surface

`.codex/hooks/enforce-epic-worktree-removal-gate.ps1` is 152 lines and is **not** a copy of the
Claude hook: it reads stdin directly (:135), resolves the checkpoint path from `$PSScriptRoot`
(:136-137), normalizes paths through `[System.IO.Path]::GetFullPath` against `payload.cwd` (:47-58,
:105-109), uses a quote-aware extraction regex that also absorbs `--force` (:35), has only the epic
branch, and exits 2 on an exception (:150). It is not registered in `.claude/settings.json` and so
does not participate in the Claude-side hook conjunction. Whether it must also learn the manifest is
an open question (see section 10).

### 1.3 The skill

`.claude/skills/cleanup-merged-worktrees/SKILL.md` (264 lines). Its `allowed-tools` (`:4-23`) grants
`Bash(bash scripts/bash/cleanup-worktrees.sh *)` (:9) and nine narrow `git` verbs — `fetch`,
`merge-base`, `push`, `rev-parse`, `status`, `log`, `show`, `diff`, `branch -r`, `worktree list`
(:10-19). It grants no `git worktree remove`, no `git branch -D`, no `rm`, and no `git reset`.

Verdict vocabulary already defined by the skill:

- Branch/worktree states (`:61-62`): `NOT_MERGED`, `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`,
  `MERGED_EQUIVALENT`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`.
- Triage dispositions (`:141`, :201, :211, :242): `SAFE_TO_DELETE`, `PRESERVE`.
- Step-5 content classifications (`:168-182`): `DEAD_ONE_OFF`, `ALREADY_SOLVED_ELSEWHERE`,
  `STALE_OR_CONTRADICTED`, and `GENUINELY_NEW` / `STILL_RELEVANT` (one bullet, two labels, :179).

Hard prohibitions the fix must not weaken: no force flag on `git worktree remove` (:236-237); no
`git worktree prune` (:238); never act on `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS`/`PROTECTED_CURRENT`
through the script or its apply-mode allowlist, and the `SAFE_TO_DELETE` verdict authorizes "only a
distinct, individually confirmed manual action outside that automated path … never a change to the
classification ladder itself, and never for `PROTECTED_CURRENT`" (:239-245).

### 1.4 The bash tool

- `scripts/bash/cleanup-worktrees.sh` — 92 lines. `main()` reads only `${1:-}` (:65) and dispatches
  on a `case` (:66-81). `--apply | apply` → `run_apply`; anything unrecognized → usage to stderr,
  exit 2. **Extra arguments after `$1` are read by nothing**: `bash cleanup-worktrees.sh --apply
  --manifest x` runs apply and silently discards `--manifest` and `x`.
- `scripts/bash/cleanup_worktrees_actions_lib.sh` — 382 lines. `remove_worktree_safe` (:252-279)
  calls `cleanup_wt_git worktree remove "$path"` at :263 without force; `delete_branch` (:281-295)
  calls `cleanup_wt_git branch -D` at :288; consolidation cleanup calls `worktree remove` at :182.
  `run_apply` (:316-381) records a worktree only when its branch is not `DETACHED` (:347) and
  iterates `enumerate_branches` (:358), gating deletion on the explicit three-state allowlist at
  :375.
- `scripts/bash/cleanup_worktrees_lib.sh` — 479 lines (21 headroom).
  `scripts/bash/cleanup_worktrees_enumerate_lib.sh` — 236 lines.

### 1.5 A third hook that matters

`.claude/hooks/validate-bash.ps1` (230 lines) blocks by literal substring `Contains` (:73) against
`Get-BlockedBashPattern` (:48-56): `rm -rf`, `git push --force`, `git push origin --force`,
`Remove-Item -Recurse -Force`, `git reset --hard`, `git push -f`. Two of the skill's own step-7 and
step-9 manual actions land on this list. `git branch -D` and `git clean -fd` do not.

---

## 2. R1 — What command does the operator actually need sanctioned?

### 2.1 Enumeration of removal-shaped operations reachable from the documented workflow

| # | Operation | Where the workflow reaches it | Intercepted by the two removal gates? | Intercepted by anything else? |
| --- | --- | --- | --- | --- |
| 1 | `bash scripts/bash/cleanup-worktrees.sh --apply` | End-to-End step 6, `SKILL.md:113`; short path :126 | **No.** Both gates read only `tool_input.command` (epic :342, parallel :201). That text is `bash scripts/bash/cleanup-worktrees.sh --apply`, which fails `'(?i)\bgit\s+worktree\s+remove\b'` (epic :347, parallel :206), so both return allow. The internal `cleanup_wt_git worktree remove` at `cleanup_worktrees_actions_lib.sh:263` and :182 and `branch -D` at :288 execute inside a child bash process and are never presented to any PreToolUse hook. | No. Already granted by `SKILL.md:9`. |
| 2 | Per-worktree `git worktree remove <path>` as its own Bash tool call | Not authorized by any current sentence of the skill (see 2.3) | **Yes.** Matches at epic :147 / parallel :70; falls through to the deny at epic :365 and parallel :227 for any path no checkpoint records. | `.claude/settings.json:5` grants `Bash(git *)`; the `deny` list has no Bash entry. |
| 3 | Filesystem removal of an orphaned non-worktree directory | Step 7, `SKILL.md:190-197` | **No.** :193-194 explicitly forbids `git worktree remove` for these, so the regex never matches. | **Yes** for the `rm -rf` spelling: `validate-bash.ps1:49` + :73. `rm -r` and `rm -fr` are not on the list. Already required to be per-item user-confirmed (`SKILL.md:195-197`, :248-251). |
| 4 | `git branch -D <branch>` on a disposable branch | Step 9, `SKILL.md:213-214` | **No.** The regex requires `git worktree remove`. | **No.** Not in `Get-BlockedBashPattern`. Covered by `Bash(git *)`. Works today. |
| 5 | Clearing a dirty working tree | Step 9, `SKILL.md:213` | **No.** | **Partly.** `git reset --hard` is blocked by `validate-bash.ps1:53` + :73. `git clean -fd` and `git checkout -- .` are not. |

### 2.2 What the 2026-09-06 run had to issue

Primary source:
`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md`.

- Gap 1 (:25-36): "30 of the 57 worktrees had a detached HEAD … and were invisible to apply mode."
  Confirmed in code: `run_apply` populates `wt_of` only for `$wbranch != DETACHED`
  (`cleanup_worktrees_actions_lib.sh:347`) and iterates only `enumerate_branches` (:358). There is
  no code path by which operation 1 can remove a detached worktree. For those 30, operation 2 was
  the only mechanism that exists.
- Gap 2 (:38-53): 14 worktrees on merged branches reported `BLOCKED-DIRTY`. `remove_worktree_safe`
  runs without force, fails on a dirty tree, emits `DIRTY|` lines and returns 1 (:263-278). Clearing
  the dirt and re-running operation 1 would have worked for the branch-backed subset, except that the
  natural clearing spelling `git reset --hard` is denied by `validate-bash.ps1:53`.
- Gap 3 (:56-63): records the workaround — "write the removals to a script file and invoke
  `bash <file>`, which the hook does not inspect."

### 2.3 Answer to R1

**The command the operator needs sanctioned is operation 2: a per-worktree
`git worktree remove <path>`, issued as its own Bash tool call, for a path this skill's own triage
has classified `SAFE_TO_DELETE` with recorded justification.** It is the only removal-shaped
operation the two gates intercept, and in the observed run state it was the only mechanism that
could remove the 30 detached worktrees at all.

Two further findings that must shape the spec:

1. **No current sentence of the skill authorizes operation 2.** Step 9's authorized manual actions
   are clearing a working tree and deleting a branch (`SKILL.md:212-214`); step 7 forbids the
   removal command for orphaned directories (:193-194); the Prohibited Shortcuts forbid force flags
   (:236-237). A fix that adds only a hook branch would allow a command the skill never instructs.
   **The skill text change is not documentation of the hook change; it is half the fix.** This is
   exactly why the epic keeps hook and skill in one child (`epic.md:90-93`).

2. **The permanent residual is narrower than the observed run.** Once sibling children A (#630,
   detached-worktree classification) and C (#902, `--clear-disposable`) land, operation 1 covers the
   detached-and-clean case and the disposable-dirt case. What operation 1 can **never** cover is a
   `SAFE_TO_DELETE` verdict on a worktree whose branch is `NOT_MERGED` or `HAS_UNIQUE_RESIDUALS`,
   because `SKILL.md:239-245` permanently forbids adding those states to the apply-mode allowlist.
   That is the durable, permanent need for operation 2, and it is the narrow scope the manifest
   should authorize. Writing the manifest acceptance any wider than this is unjustified by evidence.

3. **Neither candidate design closes the file-indirection bypass.** No hook inspects file contents,
   so `bash <file>` remains ungated after either fix. This should be recorded as an accepted
   residual with the same posture the repository already uses for the pr-author receipt
   (`enforce-pr-author-skill.ps1:35-41`: "a policy-level integrity check … not a cryptographic or
   security boundary"), or filed as a separate follow-up. It must not be claimed as closed.

---

## 3. R2 — Are PreToolUse denials conjunctive, and does the parallel gate also need the manifest?

**Yes to both.** The combination is Claude Code runtime behavior, not repository code, so it cannot
be verified by executing anything in this repository. The evidence is:

1. **Repository prose, three independent statements.**
   `.claude/skills/parallel-orchestrate/SKILL.md:401`; `.claude/rules/parallel-orchestration.md:412`;
   and the epic gate's own docstring at `enforce-epic-worktree-removal-gate.ps1:48-51` ("both gates
   must allow for a removal to proceed; this gate keeps the `EPIC_WORKTREE_REMOVAL_BLOCKED` prefix
   for both of its branches so transcript attribution stays unambiguous").

2. **A recorded field observation.**
   `docs/features/completed/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/spec.md:86`
   and :200 record the 2026-08-26 outcome: both gates fired on the same command, the parallel gate
   allowed, the epic gate denied, and the removal was denied. That is an observed instance of
   deny-wins over a concurrent allow.

3. **The same source records the limit of the evidence.** `spec.md:200` states it "was not
   re-verified by execution; verification would require observing the runtime's hook combination,
   which is not this repository's code", and the #573 research says the same at
   `research.2026-08-28T10-05.md:19` and :126-130. Report the semantics at that strength.

4. **Structural corroboration.** Both hooks return `permissionDecision: 'allow'` unconditionally
   whenever the command does not match their trigger (epic :344 and :348; parallel :203 and :207).
   If decisions combined disjunctively on allow, every Bash command would be allowed by whichever
   hook did not match it and the entire eight-hook `Bash` matcher family would be inert. The
   family's existence and the 2026-08-26 denial are consistent only with deny-wins.

**Consequence for the fix.** Adding manifest acceptance to only the epic gate leaves the parallel
gate denying, and vice versa. Both hooks must gain it. This is the same coordination the #573 fix
had to perform in the opposite direction — it added a *parallel* branch to the *epic* gate
(`enforce-epic-worktree-removal-gate.ps1:225-287`) precisely because the parallel gate's allow could
not override the epic gate's deny.

---

## 4. R3 — Option (a) versus option (b)

### 4.1 Option (a) — manifest-aware hooks

**What code changes.**

- New `.claude/lib/<dir>/<Module>.psm1` holding: manifest path constant, read seam, JSON parse,
  record lookup by normalized path, and the removal-authorizing predicate.
  `.claude/lib/hook-payload/HookPayload.psm1` is at 496 of 500 and cannot absorb it.
- `enforce-epic-worktree-removal-gate.ps1`: one `Import-Module` at the top (precedent :62) and a
  third branch inserted between :363 and :365.
- `enforce-parallel-worktree-removal-gate.ps1`: one `Import-Module` (precedent :32) and a second
  branch inserted between :225 and :227.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md`: a manifest-write step, a new step-9 removal
  action for the `SAFE_TO_DELETE`/`NOT_MERGED`-or-`HAS_UNIQUE_RESIDUALS` case, and an `allowed-tools`
  grant matching whatever the sanctioned command actually is.
- Registrations: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  (new module entry alongside :113-136); `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  `CodeCoverage.Path` and its mirror; the `.claude/**` bundle mirror (three files).
- Tests: new sibling Pester suite for the module; additions to the two existing suites (428 and 392
  lines, 72 and 108 headroom).

**Do the hooks change?** Yes, both. That is the point of the option.

**Does the per-item "distinct, individually confirmed manual action" property survive?** **Yes.**
Each removal remains its own Bash tool call, authorized by its own manifest record. The manifest
authorizes; it does not execute. `SKILL.md:212-214` and :242-245 are satisfied literally.

**Residual bypass surface.** Three, all statable:
1. The manifest is written by the same agent that issues the removal, into gitignored `artifacts/`
   (`.gitignore:6`). This is a policy deterrent, not a boundary — the identical posture already
   recorded at `enforce-pr-author-skill.ps1:35-41`.
2. Staleness. The epic gate already documents this class of residual for the parallel checkpoint at
   :38-46, and argues it is implausible there because parallel worktree paths carry a session or
   timestamp component. **That argument does not transfer.** Cleanup targets are ordinary long-lived
   worktree paths, so a stale cleanup manifest is materially more re-matchable. A freshness
   discriminator is required, not optional. See section 6.4.
3. The `bash <file>` indirection, unchanged (see R1 finding 3).

**Interaction with the bash libraries.** **None.** No file under `scripts/bash/` is touched. The
21 lines of headroom in `cleanup_worktrees_lib.sh` are untouched and no collision is created with
children A, B, C, or F, whose conflict-freedom the epic explicitly depends on (`epic.md:143-147`).

### 4.2 Option (b) — script-routed removal

**What code changes.**

- `scripts/bash/cleanup-worktrees.sh` must gain real argument parsing. Today `main()` reads only
  `${1:-}` (:65) and the `case` (:66-81) dispatches on it, so `--apply --manifest <path>` runs apply
  and **silently discards** the manifest argument. Without this change the flag is decorative.
- A manifest reader must live somewhere in bash. `cleanup_worktrees_lib.sh` is at 479 of 500 and
  both the epic's shared constraint 2 (`epic.md:188-191`) and this child's stated constraint forbid
  growing it, so a new sibling library file is required.
- `cleanup_worktrees_actions_lib.sh` (382 lines) needs a manifest-driven removal path beside
  `run_apply` (:316-381), because the whole purpose is removing worktrees the existing three-state
  allowlist at :375 deliberately excludes.

**Do the hooks change?** Still yes — and to no effect. Today
`bash scripts/bash/cleanup-worktrees.sh --apply` already passes both gates by non-match (R1 row 1).
"Have the hooks recognize that invocation" is therefore a no-op recognition of something already
allowed. For (b) to be narrower than the status quo the hooks would have to newly **deny** other
spellings, which is a scope expansion, not the requested fix.

**Does the per-item confirmation property survive?** **No.** One
`--apply --manifest <path>` call performs N removals from a single confirmed tool call.
`SKILL.md:212-214` requires "a distinct, individually confirmed manual action" per finding, and
:242-245 says the `SAFE_TO_DELETE` verdict authorizes such an action "outside that automated path".
Option (b) routes exactly those findings back into the automated path. It also collides with
:239-245's prohibition on the apply-mode allowlist ever accepting `NOT_MERGED` or
`HAS_UNIQUE_RESIDUALS`.

**Residual bypass surface.** Larger than (a). Because the script ignores extra arguments today, a
hook recognizing the literal `--manifest <path>` would allow an invocation whose manifest the script
never reads, unless the script change lands first and is enforced. Every removal inside the script
stays invisible to every hook — the exact indirection `issue.md:22` calls "a hook bypass in all but
name", now promoted to the sanctioned path.

**Epic constraints.** The epic classifies this child's surface as "PowerShell hook + skill text
(removal manifest)" (`epic.md:102`) and gives its single-child rationale as "the hook contract and
its documented usage cannot be split" (:90-93). (b) adds a bash surface, contradicting that
rationale, and collides with the four bash children the epic keeps deliberately independent
(:143-147).

### 4.3 Recommendation

**Option (a).** In order of weight:

1. It is the only option that preserves the per-item confirmation property `SKILL.md:212-214` and
   :242-245 mandate. (b) violates it structurally.
2. It touches no bash file, so it consumes none of `cleanup_worktrees_lib.sh`'s 21 lines of headroom
   and creates no fan-in collision with children A, B, C, or F.
3. It stays on the surface the epic manifest assigned this child (`epic.md:102`).
4. It extends an existing shape: the epic gate's cascade already grew from one positive predicate to
   two for #573, and a third predicate of the same form is the smallest coherent increment.
5. (b) as literally specified in the run observations is a no-op against the current hooks, because
   the script invocation already passes.

The orchestrator makes the final call. If (b) is chosen anyway, the spec must additionally resolve
the `SKILL.md:239-245` conflict and the silent-argument-discard defect, and must state how per-item
confirmation is preserved.

### 4.4 Rejected alternatives (brief)

- **A Python leg in either hook.** Prohibited by `.claude/rules/general-code-change.md` reading
  order and by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`,
  whose allowlist ships empty and is asserted empty (:102-109). Not considered further.
- **Widening the hooks' `merge_status` allow-set to a cleanup value.** Rejected: it would let a
  cleanup verdict authorize removal of an *epic or parallel item* worktree, which
  `issue.md:154-156` and the run observations (:71) explicitly require to keep denying.
- **Adding the grant to `.claude/settings.json` only.** Rejected: `Bash(git *)` is already granted
  at :5; the permission layer is not the blocker (see section 0).

---

## 5. R4 — Manifest record-shape precedents and fail-closed conventions

### 5.1 Existing shapes a PowerShell hook reads

| Document | Discriminator | Array | Per-record match key | Per-record status key | Allowed values |
| --- | --- | --- | --- | --- | --- |
| `artifacts/orchestration/epic-orchestrator-state.json` | none | `features[]` | `worktree_path` | `merge_status` | `merged`, `worktree_removed` (`enforce-epic-worktree-removal-gate.ps1:65`) |
| `artifacts/orchestration/parallel-orchestrator-state.json` | `route_id == "parallel"` (epic :257) | `items[]` | `worktree_path` | `merge_status` | same set (parallel gate :34) |
| `artifacts/orchestration/orchestrator-state.json` | read by `enforce-pr-author-skill.ps1:49` through `Invoke-OrchestratorStatePreflight` | n/a | n/a | n/a | governed by `.claude/rules/orchestrator-state.md` |

Conventions to follow: snake_case keys; a top-level self-identifying discriminator; an array of
per-target records; a per-record status drawn from a small closed vocabulary held as a
script-scope constant (`$script:AllowedMergeStatuses`); matching by normalized path.

Module layout convention for the new helper: kebab-case directory, PascalCase module file, e.g.
`.claude/lib/hook-payload/HookPayload.psm1`, `.claude/lib/blast-radius/BlastRadius.psm1`,
`.claude/lib/orchestrator-state/OrchestratorState.psm1`.

### 5.2 Fail-closed conventions already implemented

Every one of these must be reproduced by the manifest predicate:

| Condition | Epic gate | Parallel gate | Result |
| --- | --- | --- | --- |
| File absent | :79-81, :97-99 | :48-51 | read seam returns `$null` |
| Raw text null/whitespace | :121-123 | :214 | parsed object `$null` |
| `ConvertFrom-Json` throws | :124-128 | :215-219 | parsed object `$null` |
| Parsed object `$null` | :173-175, :251-253 | :96-98 | no match / `$false` |
| Missing top-level array key | :177-179, :260-262 | :100-102 | no match / `$false` |
| Missing discriminator or wrong value | :257-259 | n/a | `$false` |
| Record missing the match key | :187-189 (`continue`), :273-275 | :110-112 (`continue`) | record skipped |
| Record missing the status key | :219-221, :280-282 | :142-144 | `$false` |
| Status not in the allowed set | :222 | :145 | `$false` |
| Path normalization | `-replace '\\','/'` then `.TrimEnd('/')` on both sides, :181/:190, :264/:276 | :104/:113 | Windows and POSIX spellings compare equal |

Note the asymmetry worth reproducing deliberately: the epic gate's parallel branch **returns
`$false` immediately** on the first path match whose record lacks `merge_status` (:280-282), rather
than continuing to scan for a later matching record. That is a fail-closed choice, and the manifest
predicate should make the same choice explicitly.

### 5.3 Evidence-location policy

`.claude/skills/evidence-and-timestamp-conventions/SKILL.md:32-33` lists `artifacts/orchestration/`
as the **only** permitted `artifacts/` sub-path for non-evidence orchestration use; :22-30 forbids
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`, and five
others for evidence output. **`artifacts/orchestration/cleanup-worktrees-manifest.json` is a
permitted path.** The enforcement mechanism is `.claude/hooks/enforce-evidence-locations.ps1`,
registered on the `Write|Edit` matcher at `.claude/settings.json:148`.

### 5.4 Naming decision, with a collision hazard

The proposed name `cleanup-worktrees-manifest.json` breaks the `*-state.json` suffix used by the
three existing documents. Keeping the suffix would be more consistent but creates two problems:

1. **Collision with sibling child G (#905).** The run observations propose
   `cleanup-worktrees-state.json` with a `consolidation_pr` block for the merge-gate child
   (`...-630/research/2026-09-06-cleanup-run-observations-user-context.md:80-82`). Two children
   would then contend for one filename.
2. **It would drag the file into `.claude/rules/orchestrator-state.md`'s path scope.** That rule's
   frontmatter `paths:` (:2-21) matches `artifacts/orchestration/*orchestrator-state.json` and
   `*planner-state.json`. `cleanup-worktrees-manifest.json` matches neither, so it inherits none of
   the orchestrator-state invariants and is not validated by
   `scripts/dev_tools/validate_orchestrator_state.py` (rule :31). That is correct: the manifest is a
   hook-read authorization document, not an orchestrator checkpoint.

**Recommendation: keep `artifacts/orchestration/cleanup-worktrees-manifest.json`** and record both
reasons in the spec so the naming is not "corrected" later.

---

## 6. R5 — What the manifest must carry for the `PRESERVE` consumer

### 6.1 The consumer

Epic child F (#904, `epic.md:46-48`), gap 5 in the run observations (:83-98). It stages
`PRESERVE`-marked untracked and modified files into a consolidation commit under three constraints
(:94-97, restated at `epic.md:179`): `MEMORY.md` index-line carriage, per-file line-ending
normalization to the target file's existing convention, and host-token refusal. Gap 5 already
proposes a per-file report line `PRESERVE|<worktree>|<path>|<verdict>` (:98).

### 6.2 Per-file fields the consumer needs

| Field | Why the consumer needs it | Evidence |
| --- | --- | --- |
| `worktree_path` | to open the file and to read that worktree's own `MEMORY.md` | run obs :91 ("each file's `MEMORY.md` index line taken from the source worktree") |
| `source_path` | repo-relative path within that worktree | run obs :98 record shape |
| `disposition` | `PRESERVE` vs `SAFE_TO_DELETE` | `SKILL.md:141`, :201 |
| `verdict` | the step-5 classification that produced the disposition | `SKILL.md:168-182` |
| `change_class` | `untracked` vs `modified` — determines whether staging adds a new file or carries a working-tree modification | run obs :86-87 |
| `target_path` | destination on the consolidation branch; the same relative path may already exist on `main` with different content, and a lesson file may be re-namespaced | `SKILL.md:157-159` (same fact re-recorded under a different filename on `main`) |
| `memory_index_line` | the `MEMORY.md` index line taken from the source worktree | run obs :91-92 |
| `line_ending` | the observed convention of the **target** file: `crlf` \| `lf` \| `absent` | run obs :92, :96 — the requirement is "normalizing line endings to the **target** file's existing convention", and the failure was LF appended to a CRLF file |
| `host_token_scan` | the token-scan result plus the identifier of the pattern set used | run obs :97 |
| `evidence` | the justification `SKILL.md:141-142` requires ("citing specific files or commit SHAs") | `SKILL.md:141-142` |

Two qualifications the spec should record:

- `line_ending` is an observation of a file the consumer will itself open. Record it as **advisory**,
  and have the consumer re-derive and compare rather than trust it. A stale manifest would otherwise
  drive exactly the mixed-ending defect gap 5 was filed to fix.
- **`_shared_no_absolute_host_paths` does not exist in this repository.** A repository-wide grep for
  that literal returns exactly one file: the run-observations document itself. Searching for
  `no_absolute_host_paths`, `absolute-host-path`, `host_path`, and `absolute host path`
  case-insensitively returns no production or test artifact defining it. The spec author must either
  locate it in the consumer repository or define the pattern set here. Recommend the manifest record
  a result plus a pattern-set identifier, never the patterns themselves.

### 6.3 Same record or sibling array?

**Sibling array.** Three reasons, each independent:

1. **Different keys.** Removal records are keyed by worktree path; preserve records by the pair
   (worktree path, file path).
2. **The hooks must not read the preserve data.** Every fail-closed convention in section 5.2 is
   written as "iterate the array, read two properties per record". Nesting a per-file array inside a
   removal record makes the hook's iteration traverse data it must never authorize on, and makes the
   "written too broadly" regression test (`issue.md:136-138`) harder to write.
3. **Preserve entries legitimately exist for worktrees with no removal record.** `SKILL.md:204-205`
   routes `PRESERVE` findings through consolidation **before** that worktree's dirty content is
   discarded — a `PRESERVE` finding is precisely a reason the worktree is not yet removable. A
   nested shape would force a removal record to exist for every preserve entry.

Recommended top level:

```
{
  "tool": "cleanup-merged-worktrees",
  "generated_at": "<ISO-8601 UTC>",
  "run_id": "<opaque per-run identifier>",
  "removals": [ ... ],
  "preserved_files": [ ... ]
}
```

`tool` plays the role `route_id` plays in the parallel checkpoint (epic gate :257): a
self-identifying discriminator the hook checks before reading anything else.

### 6.4 Vocabulary: reuse verbatim versus define anew

**Reuse verbatim from `SKILL.md`:**

| Term | Source | Manifest field |
| --- | --- | --- |
| `SAFE_TO_DELETE`, `PRESERVE` | `SKILL.md:141`, :201, :211, :242 | `disposition` on both arrays |
| `DEAD_ONE_OFF`, `ALREADY_SOLVED_ELSEWHERE`, `STALE_OR_CONTRADICTED`, `GENUINELY_NEW`, `STILL_RELEVANT` | `SKILL.md:169-182` | `verdict` |
| `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT` | `SKILL.md:61-62` | `branch_state` on removal records |

Note that `SKILL.md:179` writes `GENUINELY_NEW` / `STILL_RELEVANT` as one bullet holding two
alternative labels. The manifest must pick a representation; recommend two distinct enum members and
a spec note that the skill treats them as one class.

**Define anew:**

- The removal-authorizing status. **Do not reuse `merge_status` or its values `merged` /
  `worktree_removed`.** Those mean "this feature's PR merged", which is not the fact a cleanup
  verdict establishes. Recommend a distinct key such as `removal_disposition`, so a reader cannot
  confuse the two authorization families and a test can assert the epic and parallel branches were
  not widened.
- `evidence` — required non-empty, and the manifest predicate should require it non-empty. That is
  the single field that makes a record an auditable verdict rather than a bare allowlist entry, and
  it is what `issue.md:53-55` means by "a removal that a recorded verdict and its evidence cover".
- `generated_at` / `run_id` — the freshness discriminator required by section 4.1 residual 2.
- `branch_state` on removal records — so the predicate can require that the recorded state is one
  the script's allowlist deliberately excludes (`NOT_MERGED` or `HAS_UNIQUE_RESIDUALS`), keeping the
  manifest acceptance as narrow as R1 finding 2 establishes it should be.

---

## 7. R6 — Composing with issue #545

### 7.1 What #545 actually is

Read: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
(886 lines, Status "Ready for planning", Version 1.0).

- **In scope:** a new shared helper `hook-command-scanner.ps1` (D7, :446-462), and three hooks —
  `enforce-orchestration-preimplementation-gate.ps1`, `enforce-promotion-mcp-only.ps1`, and
  `enforce-pr-author-skill-helpers.ps1` (:352-356, D5 :425-434, D6 :436-444, D10 :537-563).
- **Out of scope, explicitly:** "The remaining hook-family members, to be filed as a single follow-up
  candidate citing this specification and the research: `enforce-epic-merge-gate.ps1`,
  `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`,
  `enforce-parallel-abandon-gate.ps1`, and `validate-bash.ps1`" (:153-158). Pinned by an acceptance
  criterion: "No out-of-scope hook is modified: … carry no diff" (:807-810). Restated in the rollout
  section as a follow-up to file (:874-878).
- **The helper is a `.ps1`, not a `.psm1`, and it does not live under `.claude/lib/`.** D7 settles
  `hook-command-scanner.ps1` at `.claude/hooks/`, `.codex/hooks/`, and both bundle roots (:446-462,
  AC at :776-778), on the stated ground that "the dot-sourced sibling `.ps1` idiom remains the only
  sharing mechanism that works on both pairs, because the `.codex` side has no `lib/` directory"
  (:602-603). Verified: `.claude/hooks/hook-command-scanner.ps1` does not exist in the tree.
- **No detection or extraction function is named.** D1's preamble states "the atomic-planner decides
  sequencing, batching, and final function boundaries within these constraints" (:211-212). What is
  fixed is a contract, not a signature:
  - **Piece 1**, a scanner producing an ordered list of segments, each carrying exactly five
    properties — `RawText`, `MaskedText`, `Tokens`, `HasLiveSubstitution`, `Unbalanced` (:252-260;
    acceptance criterion at :736-740).
  - **Piece 2**, three ordered scan-text-selection clauses and a fourteen-member wrapper carve-out
    constant (:279-308; AC :741-743).
  - **Piece 3**, a structural relocation classifier over `Tokens` with named script-scope git and gh
    option tables (:310-328; AC :744-747). Its modeled subcommand paths are `add`/`commit` for git
    and `pr create`/`pr edit`/`issue create`/`issue new` for gh (:318, :324-326). **There is no
    `worktree remove` leg.**

**Answer to "does it return the extracted path argument or only a boolean?"** Neither. It returns
neither a boolean nor a path: it returns per-segment records with the five properties above, plus a
separate structural classifier that yields a classification decision. It does not extract a
positional argument for any command, and it has no knowledge of `git worktree remove`.

### 7.2 The live contradiction the spec author must resolve

The epic manifest asserts "Both hooks are files E edits" and "Child E extends #545 to cover the
gate-hook instances rather than opening a second issue for the same defect class"
(`epic.md:118-123`, :132-138), and records the edge D→E on that basis (:42). **That extension is not
in #545's approved spec and is contradicted by its acceptance criterion at :807-810.** Two
self-consistent resolutions:

- **R6-A (recommended).** Treat #545 as scoped by its own approved spec. The two removal gates keep
  their regex at `enforce-epic-worktree-removal-gate.ps1:147` and
  `enforce-parallel-worktree-removal-gate.ps1:70`. #635 then touches no detection code, the two
  children touch disjoint files, and the D→E edge is not load-bearing for this child — #635 could
  run in wave 0 alongside E.
- **R6-B.** Amend #545's spec to widen scope to the two removal gates. This reverses an approved
  acceptance criterion and drops the "no diff" pin, and only then does the D→E edge do any work.

### 7.3 Can the manifest acceptance be written entirely below the detection call site?

**Yes, under either resolution, and that is the property to design for.** In both hooks the
detection result is a single local `$worktreePath` (epic :351, parallel :210). Everything after that
assignment is checkpoint policy.

**Must not touch:**

- The regex strings at epic :147 and parallel :70, and their `.Trim('"''')` at epic :148 /
  parallel :71.
- The trigger guards `'(?i)\bgit\s+worktree\s+remove\b'` at epic :347 and parallel :206.
- The bodies of `Get-EpicWorktreeRemovalCommandPath` and `Get-ParallelWorktreeRemovalCommandPath`.
- The deny reason strings at epic :365 and parallel :227 (the issue requires the existing reason
  codes survive for uncovered removals — `issue.md:136-138`).
- The decision constructors (epic :289-317, parallel :148-176), the entry points, and the thin tails.

**May touch:**

- The `Invoke-*GateDecision` body strictly after the `$worktreePath` assignment — a new branch
  between epic :363 and :365, and between parallel :225 and :227.
- A new `Import-Module` at the top (precedent: epic :62, parallel :32).
- A new `$script:CleanupManifestPath` constant (precedent: epic :63-64, parallel :33).

If R6-B is chosen anyway, the textual conflict is small: #545 would edit the trigger guards
(epic :347, parallel :206) and the extraction functions; #635 would edit :353-365 and :212-227. The
edits are in the same function but non-adjacent. The only semantic dependency is that
`$worktreePath` retains its meaning — the removal target, quote-stripped, not otherwise normalized.
Nothing in #635 should depend on the `Trim('"''')` spelling; #545's `Tokens` property is already
quote-stripped (:258), so the semantics would carry over.

---

## 8. R7 — The `396` hard-code

### 8.1 What `<N>` denotes

`.claude/skills/pr-author/SKILL.md:51`: "Write the body text to `artifacts/pr_body_<N>.md`, where
`<N>` is the target issue **or PR** number." The receipt shape at :53-64 requires
`"number": <N>` and `"pr_body_path": "artifacts/pr_body_<N>.md"`.

### 8.2 Which check compares it

The hook's receipt verification is `Test-PrAuthorReceiptVerification` in
`.claude/hooks/enforce-pr-author-skill-helpers.ps1:29-137`. It runs **six** ordered checks (see the
Numeric Derivation Evidence section for the enumeration).

- **Check 1** (`PR_BODY_PATH_NONCANONICAL`, :65-67) **captures** `<N>` from the command line itself:
  `-cnotmatch '--body-file\s+artifacts/pr_body_(\d+)\.md\b'`, then `$bodyNumber = [int]$Matches[1]`
  at :69.
- **Check 3** (`PR_AUTHOR_RECEIPT_NUMBER_MISMATCH`, :86-94) is the **only** check that compares
  `<N>`. The comparison at :92 is `$receiptNumber -ne $bodyNumber` — the receipt's `number` against
  the number in the path the command itself supplied.
- Checks 2, 4, 5 use `<N>` only to build paths (`$bodyFilePath` :70, `$receiptFilePath` :71).
- Check 6 (`EPIC_BASE_BRANCH_MISMATCH`, :130-134) does not reference `<N>`.

**The hook never compares `<N>` to a real PR number or issue number.** The contract is
self-referential: any integer passes so long as the path, the receipt's `number`, and the body bytes
agree. `issue.md:76-78`'s claim that the receipt check "compares `number` against that stale value"
is literally true but is not a failure mode — with `396` in both the path and a freshly written
receipt, check 3 passes. Check 5 (`PR_AUTHOR_RECEIPT_STALE`, :114-128) requires `created_at` to be
strictly newer than `artifacts/pr_context.summary.txt`'s last write; a run that regenerates both
artifacts satisfies it. **A hard-coded 396 with freshly written artifacts passes all six checks.**

The real defects of the hard-code, stated accurately:

1. Every run overwrites `artifacts/pr_body_396.md` and its receipt, destroying the prior run's
   artifacts and their audit value.
2. The filename asserts a provenance that is false for every run after the one that produced it.
3. If a stale pair survives and the run does not regenerate it, check 5 blocks with a reason that
   misdescribes the cause.

### 8.3 Every derivation mechanism, evaluated in the order the hook runs its checks

| Candidate | Available before `gh pr create` returns? | Passes check 1 | Passes check 3 | Passes checks 4/5/6 | Verdict |
| --- | --- | --- | --- | --- | --- |
| The GitHub issue number the run tracks | Yes, **when one exists** | Yes | Yes (self-consistent) | Yes | **Works, but not always available.** The skill never names an issue; step 4 (`SKILL.md:96-105`) is reached from the consolidation branch, and the Nothing-to-Consolidate short path (:122-127) skips the PR entirely. |
| A number derived from the consolidation branch name | Yes | Yes | Yes | Yes | **Mechanically works, semantically worse than a literal.** `documentationandmemories` is a fixed literal (`$CLEANUP_WT_CONSOLIDATION_BRANCH`, used at `cleanup_worktrees_actions_lib.sh:94`, :352-353, :360) carrying no number; any derivation is a hash or counter, i.e. arbitrary and unpredictable. |
| The PR number | **No.** Check 1 requires the number to already be in the `gh pr create` command line. | n/a | n/a | n/a | **Does not work for a create.** |
| Two-phase create-then-name | Partially | Yes on both calls | Yes on both | Yes on the second, if `created_at` is refreshed | **Works but is worse.** The `gh pr edit` path runs the same six checks (`Get-PrAuthorBypassReason:171`, :220-225), so a rewritten self-consistent pair passes. It doubles the artifact set and the first call still needs an arbitrary placeholder — the original problem, twice. |
| A run-scoped number the skill already holds | — | — | — | — | **None exists.** Nothing in `cleanup-merged-worktrees/SKILL.md` supplies one. |

### 8.4 Answer

No derivation produces the *PR* number before the PR exists, **and none is needed**: the hook's
contract is self-referential, so `<N>` is a naming choice, not a verified fact. The correct
alternative is to stop asserting a number the skill cannot know.

- **Preferred.** Replace the literal at `SKILL.md:104` with an instruction to use the GitHub issue
  number the run is executing under when one exists, deferring to `pr-author/SKILL.md:51` rather
  than restating a value. One-line skill-text edit, no hook change, false provenance eliminated.
- **If no issue number is ever available on the short path.** State in `SKILL.md` that `<N>` is an
  arbitrary run-scoped identifier the pr-author agent chooses, that it is **not** a PR number, and
  that the only requirement is agreement between the path, the receipt's `number`, and the body
  bytes — citing `enforce-pr-author-skill-helpers.ps1:65-94`. This satisfies `issue.md:57-58`'s
  "or the fixed value is justified in the skill text" while removing the specific falsehood.
- **Do not implement a hook change for gap 9a.** Nothing in the hook requires one.

---

## 9. R8 — Toolchain and delivery constraints

### 9.1 Push-down mirror contract

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

- `SCOPED_ROOTS = (Path(".claude"),)` (:20). `list_scoped_files` (:39-48) enumerates via
  `rglob("*")` under that single root, so **the whole `.claude/**` tree is in scope** — `hooks/`,
  `lib/`, `skills/`, `rules/`, `agents/` alike. There is no per-subtree list.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (:106-131) excludes exactly two
  things: `.claude/settings.local.json` (:121) and `.claude/agent-memory/**` (:76-103, :121). It
  asserts presence (:125-127) and **text equality** as decoded UTF-8 (:128-131, `read_text`), not
  byte equality. (`test_planner_review_resources_exist_and_are_byte_identical` at :134-144 is
  byte-level but covers only three named files.)
- **A NEW file under `.claude/lib/` IS covered** and must be mirrored into
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/...` in the same change.
- `pack-manifests/` is deliberately outside the parity scope (:147-164). Manifest completeness is
  enforced separately by `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`.
  `.claude/lib/**/*.psm1` entries already exist in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:113-136`.

### 9.2 The no-Python guard

`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.

- **Scan scope:** exactly two roots, `.claude/hooks` and `.claude/lib` (:39-42), recursing for
  `*.ps1` and `*.psm1` (:60-61), excluding `.claude/lib/bash/**` (:65-67) and, deliberately, the
  bundled mirror (:36-38, pinned by the `It` at :452-471). **A new `.claude/lib/**/*.psm1` is
  automatically in scope.**
- **How it detects:** AST analysis in the sibling `EnforcementHooksNoPythonInvocation.Helpers.ps1`
  (dot-sourced at :32), in four classes:
  1. Constant interpreter command — `python`, `python3`, `py`, `poetry`, case-insensitive, including
     `&`-invoked, `.`-invoked, and quoted forms (:112-193).
  2. Subprocess start whose `-FilePath` or first positional argument is an interpreter (:196-233).
  3. Dynamic invocation, fail-closed: `& $var` where `$var` is not a `[scriptblock]` parameter, or
     `& (expression)` in command position (:236-272). Carve-outs: a `[scriptblock]` seam parameter
     matched by name and case-insensitively (:350-385), and dot-sourced sibling-helper loads via a
     `Join-Path` with a literal `.ps1` argument (:387-410, boundaries pinned at :413-449).
  4. `Invoke-Expression` and its `iex` alias (:275-300).
- **What it does not flag:** interpreter names inside string literals (:304-317) or comments
  (:319-331), and function names containing "Python" (:333-348).
- **Allowlist:** ships empty and is asserted empty (:102-109); "An entry may only be added by an
  owner decision, never to pass a failure" (:106-107).

### 9.3 Adding a new `.psm1` to the Pester coverage denominator

- **Config file:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (255 lines).
- **Exact key:** `CodeCoverage.Path` — `CodeCoverage = @{` at :17, `Path = @(` at :23. The file's own
  comments state it is "an explicit per-file allow-list" (:159-162, :199-204), so an unregistered
  production file sits **outside** the denominator, which
  `.claude/rules/general-unit-test.md`'s Coverage Exclusion Policy forbids.
- **Mirror:** `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
  (255 lines, verified present). Both lists must gain the entry.
- **Precedent entries for `.claude/lib/**`:** `'.claude/lib/hook-payload/HookPayload.psm1'` (:204),
  the blast-radius modules (:163 and following), the mermaid modules (:195-197).

**The known environment defect and the concrete workaround.** `mcp__drm-copilot__run_poshqc_test`
reads the **installed extension's** PoshQC settings, so a coverage entry newly added to the repo's
runsettings is invisible to it. This is recorded independently in #545's `spec.md:711-714`.
`Invoke-PoshQCTest`'s `-SettingsPath` parameter defaults to `$script:PesterSettings`
(`scripts/powershell/PoshQC/PoshQC.Testing.psm1:156`), which `scripts/powershell/PoshQC/PoshQC.psm1:3`
binds to the module's own `settings/pester.runsettings.psd1`. Importing the repo's module therefore
uses the repo's runsettings. Concrete command:

```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
```

The `-SettingsPath` argument is redundant once the module is imported from the repository, but it
makes the binding explicit in the evidence record and defends against a future default change.

### 9.4 Other delivery obligations

- 500-line cap on every production, test, and reusable script file
  (`.claude/rules/general-code-change.md`, "File Size Limit"). Markdown is exempt.
- Line coverage >= 85% on every changed or added production PowerShell file; PowerShell is exempt
  from the branch threshold because Pester does not measure branch coverage
  (`.claude/rules/quality-tiers.md`).
- Toolchain loop: `mcp__drm-copilot__run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`,
  restarting from format on any failure or auto-fix, until a clean single pass.
- Tests must be deterministic with no temporary files
  (`.claude/rules/general-unit-test.md`, External Dependencies). Both existing gate suites already
  drive the pure decision functions through mocked read seams; follow that pattern.

---

## 10. Files a fix would touch

Line counts re-derived on this branch. "Headroom" is against the 500-line cap.

| File | Lines | Headroom | Role in the fix |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 419 | 81 | third authorization branch between :363 and :365 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 281 | 219 | second authorization branch between :225 and :227 |
| `.claude/lib/<dir>/<Module>.psm1` (NEW) | 0 | 500 | manifest read seam, parse, lookup, predicate |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | 264 | n/a (Markdown exempt) | manifest-write step, step-9 removal action, `allowed-tools` grant, `<N>` fix at :104 |
| `.claude/lib/hook-payload/HookPayload.psm1` | 496 | **4** | **must not be modified** |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 428 | 72 | narrow-scope deny pins |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 392 | 108 | narrow-scope deny pins |
| New Pester suite for the manifest module | 0 | 500 | unit surface |
| `extensions/.../claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | mirrors 419 | 81 | mirror (parity test) |
| `extensions/.../claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | mirrors 281 | 219 | mirror |
| `extensions/.../claude-customizations/.claude/lib/<dir>/<Module>.psm1` (NEW) | 0 | 500 | mirror |
| `extensions/.../claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | mirrors 264 | n/a | mirror |
| `extensions/.../claude-customizations/pack-manifests/core.json` | 169 | n/a (JSON) | +1 module entry |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 255 | 245 | +1 `CodeCoverage.Path` entry |
| `extensions/.../resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 255 | 245 | +1 entry (mirror) |

Not touched under the recommended option (a), listed so their headroom is on record and their
exclusion is deliberate:

| File | Lines | Headroom |
| --- | --- | --- |
| `scripts/bash/cleanup_worktrees_lib.sh` | 479 | 21 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 382 | 118 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 236 | 264 |
| `scripts/bash/cleanup-worktrees.sh` | 92 | 408 |
| `.claude/hooks/validate-bash.ps1` | 230 | 270 |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 152 | 348 |

---

## 11. Numeric Derivation Evidence

One numeric claim is proposed for possible use in an acceptance criterion: the number of ordered
checks in the pr-author receipt-verification family, and which of them compares `<N>`.

### Claim 1 — `Test-PrAuthorReceiptVerification` runs exactly six ordered checks

- **Complete Family:** the ordered failure checks reachable inside
  `Test-PrAuthorReceiptVerification` on the `--body-file`-with-context path.
- **Exhaustive Search Scope:** the full body of `Test-PrAuthorReceiptVerification`
  (`.claude/hooks/enforce-pr-author-skill-helpers.ps1:29-137`) plus every function it delegates to
  (`Test-EpicBaseBranchOverride` in `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`),
  and the whole of `.claude/hooks/` for any other reason code that could be returned from this path.
- **Inclusion Rules:** a check is one ordered decision position that can short-circuit with a block
  reason. Multiple `return` sites that encode alternative failure modes of the *same* decision
  position (e.g. receipt absent versus receipt non-JSON) count as one check.
- **Exclusion Rules:** reason codes returned by `Get-PrAuthorBypassReason` **upstream** of receipt
  verification (cases A/B/C and the orchestrator-state preflight) are excluded: they are reachable
  before `Test-PrAuthorReceiptVerification` is called at :221.
- **Primary Search Strategy:** sequential read of `enforce-pr-author-skill-helpers.ps1:63-136`,
  enumerating each numbered comment-delimited decision position and following the delegation at
  :131.
- **Primary Member Set:** `{ PR_BODY_PATH_NONCANONICAL (:65-67), PR_AUTHOR_RECEIPT_MISSING (:74-84),
  PR_AUTHOR_RECEIPT_NUMBER_MISMATCH (:86-94), PR_AUTHOR_RECEIPT_HASH_MISMATCH (:96-112),
  PR_AUTHOR_RECEIPT_STALE (:114-128), EPIC_BASE_BRANCH_MISMATCH (:130-134 → epic-base-branch.ps1:96,
  :100) }`
- **Primary Count:** 6.
- **Cross-check Search Strategy:** regex `return "(PR_[A-Z_]+|EPIC_BASE_BRANCH_MISMATCH)` across the
  whole of `.claude/hooks/`, match-only output, then filter to the receipt path by the exclusion
  rule. This is a different mechanism (repository-wide pattern scan over all hook files) from the
  primary (targeted sequential read of one function), and it covers every reason-code-returning site
  in the family, not only the ones named in the primary.
- **Cross-check Member Set (raw, 13 sites):** `epic-base-branch.ps1:96 EPIC_BASE_BRANCH_MISMATCH`,
  `epic-base-branch.ps1:100 EPIC_BASE_BRANCH_MISMATCH`, `helpers:66 PR_BODY_PATH_NONCANONICAL`,
  `helpers:76 PR_AUTHOR_RECEIPT_MISSING`, `helpers:83 PR_AUTHOR_RECEIPT_MISSING`,
  `helpers:93 PR_AUTHOR_RECEIPT_NUMBER_MISMATCH`, `helpers:99 PR_AUTHOR_RECEIPT_HASH_MISMATCH`,
  `helpers:111 PR_AUTHOR_RECEIPT_HASH_MISMATCH`, `helpers:122 PR_AUTHOR_RECEIPT_STALE`,
  `helpers:127 PR_AUTHOR_RECEIPT_STALE`, `helpers:183 PR_AUTHOR_SKILL_BLOCKED`,
  `helpers:189 PR_AUTHOR_SKILL_BLOCKED`, `helpers:202 PR_CONTEXT_MISSING`.
  Applying the exclusion rule removes :183, :189, :202 (all inside `Get-PrAuthorBypassReason`,
  upstream of :221). Applying the inclusion rule collapses the duplicate-code pairs
  (:76/:83, :99/:111, :122/:127, and the two epic-base-branch sites).
- **Cross-check Member Set (normalized):** `{ PR_BODY_PATH_NONCANONICAL,
  PR_AUTHOR_RECEIPT_MISSING, PR_AUTHOR_RECEIPT_NUMBER_MISMATCH, PR_AUTHOR_RECEIPT_HASH_MISMATCH,
  PR_AUTHOR_RECEIPT_STALE, EPIC_BASE_BRANCH_MISMATCH }`
- **Cross-check Count:** 6.
- **Member-set Comparison:** the normalized primary and cross-check member sets are identical,
  element for element, with no member present in one and absent from the other. Counts agree at 6.

The docstring at `enforce-pr-author-skill-helpers.ps1:9` and :36-45 independently states six. The
parent hook's docstring at `enforce-pr-author-skill.ps1:25` and its decision-order list at :29-30
state five and omit `EPIC_BASE_BRANCH_MISMATCH`; that is a stale docstring, not a sixth
implementation.

### Claim 2 — exactly one of those six checks compares `<N>`

- **Complete Family:** the same six checks.
- **Exhaustive Search Scope:** the same scope as Claim 1.
- **Inclusion Rules:** a check "compares `<N>`" when it performs a comparison one of whose operands
  is `$bodyNumber`, the value captured at :69 from the check-1 regex.
- **Exclusion Rules:** merely *deriving a path string* from `$bodyNumber` (:70-71) is not a
  comparison and is excluded.
- **Primary Search Strategy:** sequential read of :63-136, marking every comparison operator whose
  operand chain reaches `$bodyNumber`.
- **Primary Member Set:** `{ check 3 — :92, `$receiptNumber -ne $bodyNumber` }`
- **Primary Count:** 1.
- **Cross-check Search Strategy:** regex `bodyNumber|Matches\[1\]|receipt\.number` across
  `.claude/hooks/`, enumerating every occurrence and classifying it as capture, path-derivation, or
  comparison. Distinct mechanism from the primary (symbol-occurrence scan across all hook files
  rather than a read of one function).
- **Cross-check Member Set (raw):** `helpers:69 $bodyNumber = [int]$Matches[1]` (capture),
  `helpers:70` and `helpers:71` (path derivation), `helpers:89 [int]::TryParse([string]$receipt.number, …)`
  (parse, not comparison), `helpers:92 if ($receiptNumber -ne $bodyNumber)` (**comparison**),
  `helpers:93` (message interpolation), `helpers:39` (docstring). Additional `Matches[1]` hits at
  `enforce-epic-merge-gate.ps1:147` and :155 are in a different hook and outside the family scope.
- **Cross-check Member Set (normalized):** `{ helpers:92 }`
- **Cross-check Count:** 1.
- **Member-set Comparison:** the normalized primary and cross-check member sets are identical
  (`helpers:92`, check 3). Counts agree at 1.

---

## 12. Behavior semantics for the recommended design

Stated so the spec can lift them directly.

**Success condition (allow).** A `git worktree remove <path>` Bash command is allowed by both gates
when, in addition to the two existing epic/parallel branches, all of the following hold for the
manifest at `artifacts/orchestration/cleanup-worktrees-manifest.json`:

1. The file exists, is readable, and parses as JSON.
2. The top-level discriminator is present and equals the expected value.
3. The freshness discriminator satisfies the recorded policy.
4. `removals[]` is present and non-null.
5. Some record's `worktree_path`, normalized by `-replace '\\','/'` then `.TrimEnd('/')`, equals the
   command's target path normalized the same way.
6. That record carries `removal_disposition` and its value is in the manifest's own allowed set.
7. That record carries a non-empty `evidence` value.
8. That record carries `branch_state` and its value is one the script's apply-mode allowlist
   deliberately excludes.

**Failure condition (deny, with the existing reason code).** Every other state, including all ten
rows of section 5.2, and in particular: a removal targeting an epic or parallel item worktree that
no manifest record covers must still deny with `EPIC_WORKTREE_REMOVAL_BLOCKED` and
`PARALLEL_WORKTREE_REMOVAL_BLOCKED` respectively (`issue.md:136-138`, `epic.md:199`).

**Ordering.** The manifest branch runs **after** the existing branches in the epic gate, so an
epic-checkpoint-authorized removal continues to allow at the same decision point and no existing
transcript attribution changes. Conditions 1-4 are evaluated before condition 5, so an absent or
malformed manifest costs one file existence test and returns to the deny path.

**Edge cases the spec must pin:**

- Manifest present but `removals[]` empty → deny.
- Two records with the same normalized `worktree_path` and different dispositions → the fail-closed
  precedent at epic :280-282 is to decide on the first match; state the choice explicitly.
- A path present in **both** the manifest and an epic/parallel checkpoint with an unsafe
  `merge_status` → the manifest branch would allow, the checkpoint branches would not. State whether
  the manifest may override, and if not, add an explicit exclusion. **This is the single case in
  which the manifest could widen what the gates protect, and it needs a decision.**
- A trailing slash, a quoted path, and a Windows-separator path must all compare equal to the
  recorded POSIX path.

---

## 13. Testing implications (strategy only; no test code)

- **Regression-first.** A test asserting that a `git worktree remove` whose target a manifest record
  covers is allowed must fail against the unfixed hooks. Record fail-before output under
  `docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/regression-testing/`.
- **Narrow-scope deny pins**, the criterion `issue.md:136-138` calls out: a bare `git worktree
  remove` targeting an epic-checkpoint worktree with an unsafe `merge_status`, and one targeting a
  parallel item worktree, must still deny with their existing reason codes when the manifest does
  not cover them. These are the tests that fail if the manifest acceptance is written too broadly.
- **Fail-closed matrix.** One named case per row of section 5.2, driven through the module's read
  seam. No temporary files (`.claude/rules/general-unit-test.md`).
- **Vocabulary pins.** The manifest's allowed-disposition set is a script-scope constant asserted by
  a named test, following the `$script:AllowedMergeStatuses` precedent (epic :65, parallel :34) and
  #545's R6 (`spec.md:347`).
- **Non-widening pin.** A case asserting that the epic gate's branch-1 and branch-2 predicates return
  the same decisions they return today for the existing fixture set — i.e. the manifest branch adds
  allows and removes none.
- **Placement.** The two existing suites have 72 and 108 lines of headroom. The fail-closed matrix
  and the module unit surface belong in a new sibling suite; only the narrow-scope deny pins need to
  live beside the existing decision fixtures.
- **Coverage.** Line coverage >= 85% on the new module and on both changed hooks, with the new module
  registered in both `CodeCoverage.Path` lists and verified through the self-hosted PoshQC
  invocation in section 9.3, not through the MCP runner.
- **Parity and guards in the same change.**
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
  `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` must all be green.

---

## 14. Open questions the spec author must decide

| # | Question | Evidence bearing on it | Recommendation |
| --- | --- | --- | --- |
| 1 | Is #545 scoped by its approved `spec.md` (removal gates out of scope, :153-158, :807-810) or by the epic manifest's assertion that it "extends #545 to cover the gate-hook instances" (`epic.md:118-123`)? | Direct contradiction; the epic manifest also records the D→E edge on the disputed premise (:42, :132-138). | R6-A: honor the approved spec. The D→E edge then does no work for this child and #635 could move to wave 0. |
| 2 | May a manifest record override a checkpoint record that says a path is unsafe? | `issue.md:154-156` and `epic.md:199` require the gates keep denying unmanifested epic/parallel removals but are silent on the both-present case. This is the only path by which the manifest could widen the gates' protection. | Explicit exclusion: if any epic or parallel checkpoint records the path, the manifest branch does not apply. Pin by test. |
| 3 | How is manifest staleness bounded? | `/artifacts` is gitignored (`.gitignore:6`); the epic gate's accepted-residual argument at :38-46 turns on per-run path uniqueness, which cleanup targets do not have. | Require `generated_at` plus a bounded age, or a `run_id` the skill also records elsewhere. Do not carry the epic gate's residual argument across unexamined. |
| 4 | Must the manifest acceptance also land on `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` (152 lines)? | Not registered in `.claude/settings.json`, so it does not participate in the Claude-side conjunction; but it is a structurally different third implementation. `epic.md:102` names only the `.claude` hook. | Decide explicitly. If no, record the divergence; if yes, note the Codex byte-identity hash test (#545 `spec.md:514`) applies. |
| 5 | What is the exact `allowed-tools` grant the skill gains? | `SKILL.md:4-23` grants nine narrow git verbs; `.claude/settings.json:5` already grants `Bash(git *)`. `issue.md:56-57` requires the grant "matches whatever command the sanctioned path actually uses". | `Bash(git worktree remove *)` with no force spelling, plus a skill-text prohibition restating :236-237. |
| 6 | Does the fix also address the `git reset --hard` block (`validate-bash.ps1:53`) that prevents step 9's "clear the dirty working tree" action? | R1 row 5. It is in the same skill step as the removal and is blocked by a third hook. | Out of scope for #635 (different hook, different reason code) — but file it, or note that sibling child C (#902) routes clearing through the script and therefore side-steps it. |
| 7 | Where does the `_shared_no_absolute_host_paths` pattern set come from? | Repository-wide grep returns only the run-observations file; no production or test artifact defines it. | Locate it in the consumer repository or define it here; the manifest should record a scan result plus a pattern-set identifier, not the patterns. |
| 8 | Should `GENUINELY_NEW` / `STILL_RELEVANT` (one `SKILL.md:179` bullet, two labels) be one enum member or two? | The skill treats them as one class but writes two labels. | Two members plus a spec note that they are one class, so the manifest never has to invent a joined token. |
| 9 | Is the residual `bash <file>` indirection accepted or filed? | Neither candidate design closes it; `issue.md:22` names it as the defect's proximate cause. | Accept with the `enforce-pr-author-skill.ps1:35-41` posture, stated in the skill text; or file a separate follow-up. Do not claim it closed. |
| 10 | For gap 9a, does the run always have an issue number available? | `SKILL.md:96-105` reaches step 4 from the consolidation branch; the short path :122-127 skips the PR entirely. | If not always: adopt the "arbitrary run-scoped identifier, justified in skill text" option from section 8.4. Either way, no hook change. |
