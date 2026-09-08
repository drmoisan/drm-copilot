# 2026-09-06-cleanup-worktrees-sanctioned-removal-manifest (Spec)

- **Issue:** #635
- **Parent (optional):** epic `cleanup-merged-worktrees-hardening` (child D; gaps 3 and 9a)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-07
- **Status:** Ready for planning
- **Version:** 1.0

## Document Conventions

- Every `path:line` citation in this document was derived against the branch
  `bug/cleanup-worktrees-sanctioned-removal-manifest-635` on 2026-09-07 and is recorded in
  `research/2026-09-07-sanctioned-removal-manifest-research.md`. This child executes after
  sibling children merge into `epic/cleanup-merged-worktrees-hardening-integration`, so
  **line numbers must be re-derived at execution time** rather than pinned to the values
  quoted here. File names, function names, constant names, and reason-code strings are the
  stable identifiers; line numbers are navigational aids only.
- Claim strength matches evidence strength. Where the research established a fact by reading
  repository content, this document states it as verified. Where the research recorded that a
  fact was not verified by execution, this document says so explicitly and does not upgrade it.
- The primary evidence base is
  `docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/research/2026-09-07-sanctioned-removal-manifest-research.md`
  (sections R1–R8, section 12 behavior semantics, section 14 open questions).

## Context

The `cleanup-merged-worktrees` skill has no sanctioned way to run `git worktree remove` from a
Bash tool call. Two PreToolUse hooks deny the command unless an epic or parallel orchestrator
checkpoint already records the exact target path with `merge_status` in
`{merged, worktree_removed}`. During the 2026-09-06 `/cleanup-merged-worktrees` run the only way
to complete the removals was to write them into a shell script file and invoke `bash <file>`,
which neither hook inspects. Separately, the skill hard-codes `<N> = 396` for the `pr-author`
body-file and receipt contract, so every run reuses one run's number.

Environment:

- OS/version: Windows 11 Pro 10.0.26200, PowerShell 7+ (`pwsh`), Git Bash for the Bash tool.
- Python version: n/a. The enforcement surface is PowerShell;
  `.claude/rules/general-code-change.md` and the epic's shared constraints prohibit a Python leg
  in enforcement hooks.
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh`, then
  `bash scripts/bash/cleanup-worktrees.sh --apply`, then per-worktree `git worktree remove <path>`.
- Data source or fixture: the 2026-09-06 `/cleanup-merged-worktrees` run on the TaskMaster
  checkout (45 branches classified, 7 worktrees removed, 30 detached worktrees invisible to apply
  mode, 14 dirty worktrees blocked).

Impact / Severity:

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The enforcement outcome is worse than either a clean allow or a clean deny. The operator who
needs the removal reaches for the file-indirection workaround, which suppresses the gate for
every removal in the file including ones no verdict covers, so the gate's protective value is
lost precisely in the runs where it was intended to apply.

## Repro & Evidence

Steps to Reproduce:

1. Run `bash scripts/bash/cleanup-worktrees.sh` in report mode and complete the Dirty Worktree
   Triage Procedure in `.claude/skills/cleanup-merged-worktrees/SKILL.md` until one or more
   worktrees carry a `SAFE_TO_DELETE` verdict with recorded justification.
2. Issue the removal the verdict authorizes as a single Bash tool call:
   `git worktree remove <path>`.
3. Observe the PreToolUse denial. `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` denies
   with `EPIC_WORKTREE_REMOVAL_BLOCKED`;
   `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` denies with
   `PARALLEL_WORKTREE_REMOVAL_BLOCKED`.
4. Write the same removals into a shell script file and run `bash <file>`. Both hooks inspect
   only `tool_input.command`, so neither sees the removal and both allow the invocation.

Actual (verified against the current tree):

- `enforce-epic-worktree-removal-gate.ps1` (419 lines; 81 lines of headroom against the 500-line
  cap) extracts the target path with `'(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)'` at :147
  followed by `.Trim('"''')` at :148, then evaluates two positive predicates in order —
  `Find-EpicWorktreeFeatureRecord` + `Test-EpicWorktreeRemovalAllowed` (called :355-358) and
  `Test-ParallelCheckpointAllowsWorktreeRemoval` (called :360-363) — and otherwise reaches
  `Get-EpicWorktreeGateBlockDecision` at :365. There is no third branch.
- `enforce-parallel-worktree-removal-gate.ps1` (281 lines; 219 lines of headroom) carries a
  byte-identical copy of that regex at :70-71, has one positive predicate
  (`Test-ParallelWorktreeRemovalAllowed`, called :223-225), and otherwise denies at :227.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md:4-23` grants
  `Bash(bash scripts/bash/cleanup-worktrees.sh *)` and a set of narrow `git` verbs at :10-19 —
  `fetch`, `merge-base`, `push`, `rev-parse`, `status`, `log`, `show`, `diff`, `branch -r`, and
  `worktree list` — but no `git worktree remove`. (The research file describes this set as "nine
  narrow `git` verbs" at :83-85 while enumerating ten entries; the enumeration above is what
  `SKILL.md:10-19` contains and is the form relied on here. No acceptance criterion depends on a
  count of this set.)
- `.claude/skills/cleanup-merged-worktrees/SKILL.md:104` reads "using `<N> = 396` for the
  body-file and receipt contract". This is the single occurrence of the literal in the file.

Correction to `issue.md`. `issue.md:19-20` and :70-73 state the removal is "blocked twice over",
by the missing skill `allowed-tools` grant and by the two hooks. The verified blocker is the
**hooks**. `.claude/settings.json:5` already grants `Bash(git *)` at the project permission layer
and the `deny` list (:68-73) carries no Bash entry. Whether a skill's `allowed-tools` list further
narrows a project-level allow is runtime composition that cannot be verified from repository
content. This specification therefore adds the `allowed-tools` grant as part of the fix (so the
grant matches the command the sanctioned path uses, per `issue.md:56-57`) but carries **no
acceptance criterion asserting a permission-layer block**. See D3.

Correction to `issue.md` and to the run observations. `SKILL.md` step 9 does **not** instruct a
manual `git worktree remove`. `SKILL.md:212-214` authorizes exactly two manual actions — clearing
the dirty working tree and deleting a disposable `NOT_MERGED`/`HAS_UNIQUE_RESIDUALS` branch.
`SKILL.md:193-194` forbids `git worktree remove` for orphaned directories and `SKILL.md:236-237`
forbids force flags. Consequently a hook-only change would allow a command the skill never
instructs. See D1 and the skill-text obligations below.

Deny reason emitted by the epic gate today (must survive unchanged for uncovered removals):

```text
EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '<path>' requires either an epic
checkpoint features[] record with merge_status in {merged, worktree_removed}, or a
parallel-orchestrator checkpoint with route_id == "parallel" whose matching items[] record
(matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint
authorized this removal.
```

## Root Cause Analysis

The gates were written for the epic and parallel orchestration surfaces, where every legitimate
removal target is already recorded in a checkpoint. The `cleanup-merged-worktrees` skill removes
worktrees that no orchestration checkpoint ever recorded, so it falls into the gates' fail-closed
default with no route out. The skill text compounds this: it never authorizes the per-worktree
removal command at all, so there is no documented action for the hook to authorize.

The durable, permanent residual is narrower than the observed run. Once sibling children A (#630,
detached-worktree classification) and C (#902, `--clear-disposable`) land, the script's
deterministic apply path covers the detached-and-clean case and the disposable-dirt case. What
the script can **never** cover is a `SAFE_TO_DELETE` verdict on a worktree whose branch is
`NOT_MERGED` or `HAS_UNIQUE_RESIDUALS`, because `SKILL.md:239-245` permanently forbids adding
those states to the apply-mode allowlist. That is the narrow scope the manifest exists to serve.

## Scope & Non-Goals

### In scope

1. A new PowerShell module holding the cleanup manifest path constant, an injectable read seam,
   JSON parse, record lookup by normalized path, an injectable clock seam, and the
   removal-authorizing predicate (D5).
2. A manifest authorization branch added to **both** worktree-removal gate hooks (D2), written
   entirely below the detection call site (D6).
3. The normative cleanup manifest contract at
   `artifacts/orchestration/cleanup-worktrees-manifest.json` (D4), including the `preserved_files`
   array that sibling child F (#904) consumes.
4. Skill-text changes to `.claude/skills/cleanup-merged-worktrees/SKILL.md`: a manifest-write
   step, an explicit step-9 removal authorization, the `allowed-tools` grant, the `<N>` fix at
   :104 (D9), and the recorded accepted residual (D8).
5. Mirroring every `.claude/**` edit into
   `extensions/drm-copilot/resources/claude-customizations/.claude/**`, plus the pack-manifest
   entry and both `CodeCoverage.Path` registrations.
6. Pester coverage for the new module and both changed hooks.

### Out of scope / non-goals

- **`.codex/hooks/enforce-epic-worktree-removal-gate.ps1`** (D7). It is a structurally different
  152-line third implementation that reads stdin directly, normalizes through
  `[System.IO.Path]::GetFullPath` against `payload.cwd`, and has only the epic branch. It is not
  registered in `.claude/settings.json` and therefore does not participate in the Claude-side hook
  conjunction; `epic.md:102` names only the `.claude` hook. Recorded as a deliberate scope
  boundary and a follow-up candidate, not an oversight.
- **The `git reset --hard` block in `.claude/hooks/validate-bash.ps1`** (D10). `validate-bash.ps1`
  blocks by literal substring against `Get-BlockedBashPattern` (:48-56, matched at :73), which
  includes `git reset --hard` (:53). That prevents the "clear the dirty working tree" action in
  `SKILL.md:213`. It is a different hook with a different reason code, and sibling child C (#902)
  routes clearing through the script and therefore side-steps it. Recorded, not fixed. **No new
  GitHub issue is opened from this preparation run.**
- **The `bash <file>` indirection** (D8). Accepted residual, recorded and documented in the skill
  text; explicitly **not** claimed as closed by any acceptance criterion.
- **Closing the in-repo docstring discrepancy in the pr-author hook family** (D9). The research
  established that `enforce-pr-author-skill-helpers.ps1:9` and :36-45 describe six ordered receipt
  checks while the parent hook's docstring at `enforce-pr-author-skill.ps1:25` and its
  decision-order list at :29-30 state five and omit `EPIC_BASE_BRANCH_MISMATCH`. That is an
  observed in-repo documentation discrepancy. This child records it and does not fix it.
- Any change to `scripts/bash/cleanup_worktrees_lib.sh`,
  `scripts/bash/cleanup_worktrees_actions_lib.sh`,
  `scripts/bash/cleanup_worktrees_enumerate_lib.sh`, `scripts/bash/cleanup-worktrees.sh`, or
  `.claude/hooks/enforce-epic-merge-gate.ps1` (a sibling child owns the last).
- Any modification to `.claude/lib/hook-payload/HookPayload.psm1` (496 of 500 lines; 4 lines of
  headroom).
- Patching consumer-repository copies. All fixes land in `drm-copilot` and reach consumers through
  the push-down mechanism (`epic.md:185-187`).

### Explicitly excluded systems, integrations, or datasets

- The Claude Code runtime's hook-combination semantics. They are runtime behavior, not repository
  code, and cannot be verified by executing anything in this repository (D2).
- The host-token pattern set consumed by `preserved_files[].host_token_scan`. This child defines
  the field contract only; child F (#904) owns the pattern set and its identifier.

## Design Decisions

### D1 — Gap 3 design: option (a), manifest-aware hooks

**Decision.** The skill writes a cleanup manifest at
`artifacts/orchestration/cleanup-worktrees-manifest.json`; both gate hooks gain an authorization
branch that allows a `git worktree remove` whose target the manifest covers with a
removal-authorizing record.

**Justification (research 4.3), in order of weight:**

1. It is the only option that preserves the per-item confirmation property that
   `SKILL.md:212-214` and :242-245 mandate. Each removal remains its own Bash tool call authorized
   by its own manifest record; the manifest authorizes, it does not execute.
2. It touches no file under `scripts/bash/`, so it consumes none of `cleanup_worktrees_lib.sh`'s
   21 lines of headroom and creates no fan-in collision with children A, B, C, or F, whose
   conflict-freedom the epic explicitly depends on (`epic.md:143-147`).
3. It stays on the surface the epic manifest assigned this child, "PowerShell hook + skill text
   (removal manifest)" (`epic.md:102`).
4. It extends an existing shape. The epic gate's cascade already grew from one positive predicate
   to two for issue #573
   (`docs/features/completed/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/spec.md`);
   a third predicate of the same form is the smallest coherent increment.
5. Option (b) as literally specified is a no-op against the current hooks.

**Why option (b), script-routed removal, was rejected.** Three specific defects:

1. **(b) as literally specified is a no-op.** `bash scripts/bash/cleanup-worktrees.sh --apply`
   already passes both gates by non-match: both hooks read only `tool_input.command`, and that
   text fails the trigger `'(?i)\bgit\s+worktree\s+remove\b'` (epic :347, parallel :206), so both
   return allow today. "Have the hooks recognize that invocation" therefore recognizes something
   already allowed. For (b) to be narrower than the status quo the hooks would have to newly
   **deny** other spellings, which is a scope expansion rather than the requested fix.
2. **The `--manifest` argument would be silently discarded.**
   `scripts/bash/cleanup-worktrees.sh:65` reads only `${1:-}` and the `case` at :66-81 dispatches
   on it. `bash cleanup-worktrees.sh --apply --manifest x` runs apply and discards `--manifest`
   and `x` with no error. A hook recognizing the literal `--manifest <path>` would allow an
   invocation whose manifest the script never reads.
3. **It structurally destroys per-item confirmation.** One `--apply --manifest <path>` call
   performs N removals from a single confirmed tool call. `SKILL.md:212-214` requires "a distinct,
   individually confirmed manual action" per finding, and `SKILL.md:242-245` says the
   `SAFE_TO_DELETE` verdict authorizes such an action "outside that automated path". Option (b)
   routes exactly those findings back into the automated path, and additionally collides with
   :239-245's prohibition on the apply-mode allowlist ever accepting `NOT_MERGED` or
   `HAS_UNIQUE_RESIDUALS`.

### D2 — Both gate hooks gain the manifest branch

**Decision.** The manifest branch is added to `enforce-epic-worktree-removal-gate.ps1` **and**
`enforce-parallel-worktree-removal-gate.ps1`. Adding it to one leaves the other denying.

**Evidence for the conjunctive-denial premise, stated at the strength the research states it.**
The combination is Claude Code runtime behavior, not repository code, so it **cannot be verified
by executing anything in this repository**. The evidence is:

1. Three independent repository prose assertions:
   `.claude/skills/parallel-orchestrate/SKILL.md:401`;
   `.claude/rules/parallel-orchestration.md:412`; and the epic gate's own docstring at
   `enforce-epic-worktree-removal-gate.ps1:48-51` ("both gates must allow for a removal to
   proceed").
2. One recorded field observation. The #573 spec records the 2026-08-26 outcome at :86 and :200:
   both gates fired on the same command, the parallel gate allowed, the epic gate denied, and the
   removal was denied — an observed instance of deny-wins over a concurrent allow.
3. **That same source explicitly records that the semantics were never re-verified by execution.**
   #573 `spec.md:200` states verification "would require observing the runtime's hook combination,
   which is not this repository's code", and the #573 research says the same at
   `research.2026-08-28T10-05.md:19` and :126-130.
4. Structural corroboration. Both hooks return `permissionDecision: 'allow'` unconditionally when
   the command does not match their trigger (epic :344 and :348; parallel :203 and :207). If
   decisions combined disjunctively on allow, every Bash command would be allowed by whichever
   hook did not match it, and the entire `Bash`-matcher hook family would be inert.

This is a well-supported working premise, not an executed verification. No acceptance criterion in
this document asserts runtime hook combination; the criteria assert per-hook decision outputs.

### D3 — The blocker is the hooks, not the permission layer

**Decision.** `.claude/settings.json:5` already grants `Bash(git *)` and the deny list carries no
Bash entry, so the permission layer is not the verified blocker. The skill's `allowed-tools` omits
the removal verb and **gains `Bash(git worktree remove *)`** (no force spelling) as part of the fix,
because `issue.md:56-57` requires the grant to match whatever command the sanctioned path uses.

`spec.md` carries **no acceptance criterion asserting a permission-layer block**, because whether a
skill's `allowed-tools` list narrows a project-level allow is runtime composition and is not
verifiable from repository content.

### D4 — Manifest path and name

**Decision.** `artifacts/orchestration/cleanup-worktrees-manifest.json`.

The `*-state.json` suffix used by the three existing hook-read documents was rejected for two
reasons, both recorded so the name is not "corrected" later:

1. **Collision with sibling child G (#905).** The run observations propose
   `cleanup-worktrees-state.json` with a `consolidation_pr` block for the merge-gate child
   (`...-630/research/2026-09-06-cleanup-run-observations-user-context.md:80-82`). Two children
   would then contend for one filename.
2. **It would drag the file into the `paths:` scope of `.claude/rules/orchestrator-state.md`** and
   its Python validator `scripts/dev_tools/validate_orchestrator_state.py`. That rule's frontmatter
   `paths:` matches `artifacts/orchestration/*orchestrator-state.json` and `*planner-state.json`.
   Inheriting orchestrator-state invariants would be wrong: this is a hook-read authorization
   document, not an orchestrator checkpoint.

`artifacts/orchestration/` is a permitted path.
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md:32-33` lists it as the **only**
permitted `artifacts/` sub-path for non-evidence orchestration use; :22-30 forbids
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`, and further
sub-paths enumerated there. Enforcement is `.claude/hooks/enforce-evidence-locations.ps1`, registered on the
`Write|Edit` matcher at `.claude/settings.json:148`. All evidence artifacts produced by work under
this specification go to
`docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/<kind>/`.

### D5 — New module `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`

**Decision.** A new module at `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` holds:

- the manifest path constant;
- an injectable read seam (a function tests mock, matching the precedent
  `Get-EpicWorktreeGateCheckpointContent` and `Get-ParallelWorktreeRemovalGateCheckpointContent`);
- JSON parse with a fail-closed `try`/`catch` returning `$null`;
- record lookup by normalized path;
- an injectable clock seam for the freshness check;
- the removal-authorizing predicate.

`.claude/lib/hook-payload/HookPayload.psm1` is at 496 of 500 lines and **must not be modified**; it
cannot absorb these helpers. The naming follows the established precedent of kebab-case directory
plus PascalCase module file: `.claude/lib/model-routing/ModelRouting.psm1`,
`.claude/lib/hook-payload/HookPayload.psm1`, `.claude/lib/blast-radius/BlastRadius.psm1`,
`.claude/lib/orchestrator-state/OrchestratorState.psm1`.

The clock seam is required by two rules, not by preference: the adapter-seam rule in
`.claude/rules/powershell.md` ("Adapter seams for non-executable boundaries — for filesystem,
environment, or clock dependencies, introduce tiny helpers or narrow injectable parameters") and
the Determinism Infrastructure rule in `.claude/rules/general-unit-test.md` (controllable clock;
production code under test must not read wall-clock time directly).

### D6 — Composition with issue #545

**The contradiction, recorded as an open item escalated to the epic planner.**

`epic.md:118-123` and :132-138 assert that child E "extends #545 to cover the gate-hook instances"
and record the D-depends-on-E edge (:42) on that premise. That premise is contradicted by #545's
own approved specification:

- #545 `spec.md:153-158` places `enforce-epic-worktree-removal-gate.ps1` and
  `enforce-parallel-worktree-removal-gate.ps1` **explicitly out of scope**, alongside
  `enforce-epic-merge-gate.ps1`, `enforce-parallel-abandon-gate.ps1`, and `validate-bash.ps1`,
  "to be filed as a single follow-up candidate".
- #545 `spec.md:807-810` carries an acceptance criterion requiring that out-of-scope hooks
  "carry no diff". The scope boundary is restated as a follow-up to file at :874-878.
- #545's helper is **`hook-command-scanner.ps1`**, a dot-sourced, entry-point-free `.ps1` placed at
  `.claude/hooks/`, `.codex/hooks/`, and both bundle roots (D7, :446-462; acceptance criterion
  :776-778), on the stated ground that "the dot-sourced sibling `.ps1` idiom remains the only
  sharing mechanism that works on both pairs, because the `.codex` side has no `lib/` directory"
  (:602-603). It is **not** a `.claude/lib/**/*.psm1` module. The file does not exist in the tree
  today.

Two self-consistent resolutions exist and the epic planner owns the choice:

- **R6-A (recommended).** Honor #545's approved spec. The two removal gates keep their extraction
  regexes; #635 touches no detection code; the two children touch disjoint files; and the D→E edge
  does no work for this child, which could then run in wave 0.
- **R6-B.** Amend #545's spec to widen scope to the two removal gates. This reverses an approved
  acceptance criterion and drops the "no diff" pin.

**This child is designed to compose with either resolution**, because the manifest acceptance is
written entirely below the detection call site. In both hooks the detection result is a single
local `$worktreePath` (epic :351, parallel :210) and everything after that assignment is checkpoint
policy.

**Must-not-touch list (research 7.3):**

- The extraction regex strings at epic :147 and parallel :70, and their `.Trim('"''')` at epic :148
  and parallel :71.
- The trigger guards `'(?i)\bgit\s+worktree\s+remove\b'` at epic :347 and parallel :206.
- The bodies of `Get-EpicWorktreeRemovalCommandPath` and `Get-ParallelWorktreeRemovalCommandPath`.
- The two deny reason strings at epic :365 and parallel :227.
- The decision constructors (`Get-EpicWorktreeGateAllowDecision`,
  `Get-EpicWorktreeGateBlockDecision`, and their parallel counterparts), the entry points, and the
  thin tails.

**May-touch list:**

- The `Invoke-EpicWorktreeRemovalGateDecision` / `Invoke-ParallelWorktreeRemovalGateDecision` body
  strictly **after** the `$worktreePath` assignment — a new branch before the final deny in each.
- A new `Import-Module` at the top of each hook (precedent: epic :62, parallel :32).
- A new script-scope manifest path constant (precedent: epic :63-64, parallel :33).

If R6-B is chosen, the textual conflict is small and non-adjacent within the same function. The
only semantic dependency is that `$worktreePath` retains its meaning — the removal target,
quote-stripped, not otherwise normalized. Nothing in this child may depend on the `Trim('"''')`
spelling.

### D7 — `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` is out of scope

Recorded above under Non-Goals. It is not registered in `.claude/settings.json`, does not
participate in the Claude-side hook conjunction, and `epic.md:102` names only the `.claude` hook.
This is a deliberate scope boundary and a follow-up candidate. Pinned by an acceptance criterion
asserting the file carries no diff.

### D8 — The `bash <file>` indirection residual is accepted, not closed

No hook inspects file contents, so writing removals into a script file and invoking `bash <file>`
remains ungated after this fix. This is recorded here and **must be stated in the skill text**,
using the posture `.claude/hooks/enforce-pr-author-skill.ps1:35-41` already uses for its receipt
check: a policy-level integrity check that prevents accidental bypass and requires a deliberate,
documented act to circumvent — **not a cryptographic or security boundary**.

The same posture applies to the manifest itself: it is written by the same agent that issues the
removal, into a gitignored directory (`.gitignore:6`). That is a policy deterrent, not a boundary.

**No acceptance criterion in this document claims the indirection is closed.**

### D9 — Gap 9a: skill-text edit only, no hook change

**The receipt contract is self-referential.** In
`.claude/hooks/enforce-pr-author-skill-helpers.ps1`, check 1
(`PR_BODY_PATH_NONCANONICAL`, :65-67) **captures** `<N>` from the command line itself via
`-cnotmatch '--body-file\s+artifacts/pr_body_(\d+)\.md\b'` with `$bodyNumber = [int]$Matches[1]`
at :69. Check 3 (`PR_AUTHOR_RECEIPT_NUMBER_MISMATCH`, :86-94) is the only check that compares
`<N>`, and the comparison at :92 is `$receiptNumber -ne $bodyNumber` — the receipt's `number`
against the number in the path the command itself supplied. Checks 2, 4, and 5 use `<N>` only to
build paths; check 6 does not reference it. **The hook never compares `<N>` to a real PR number or
issue number.** A freshly written `pr_body_396` pair passes all six checks.

`issue.md:76-78`'s claim that the receipt check "compares `number` against that stale value" is
literally true but is not a failure mode. The real defects of the hard-code are: every run
overwrites `artifacts/pr_body_396.md` and its receipt, destroying the prior run's audit artifacts;
the filename asserts a provenance that is false for every run after the one that produced it; and
if a stale pair survives un-regenerated, check 5 (`PR_AUTHOR_RECEIPT_STALE`, :114-128) blocks with
a reason that misdescribes the cause.

**Observed in-repo documentation discrepancy, recorded and not fixed by this child.** The research
found that `enforce-pr-author-skill-helpers.ps1:9` and :36-45 state the family runs six ordered
checks, while the parent hook's docstring at `enforce-pr-author-skill.ps1:25` and its
decision-order list at :29-30 state five and omit `EPIC_BASE_BRANCH_MISMATCH`. The research's
Numeric Derivation Evidence section establishes six by two independently constructed derivations.
This child records the discrepancy; correcting the stale docstring is not in scope.

**The change.** `SKILL.md:104` becomes an instruction, not a literal:

- Use the GitHub issue number the run is executing under when one exists, deferring to
  `.claude/skills/pr-author/SKILL.md` for the body-file and receipt contract rather than restating
  a value.
- When no issue number is available — the Nothing-to-Consolidate short path (`SKILL.md:122-127`)
  skips the PR entirely, and step 4 (:96-105) is reached from the consolidation branch without any
  recorded issue number — state that `<N>` is an arbitrary run-scoped identifier chosen by the
  pr-author agent, that it is **not** a PR number, and that the only requirement is agreement
  between the body-file path, the receipt's `number` field, and the body bytes.

No hook change is made for gap 9a. Nothing in the hook requires one.

### D10 — `validate-bash.ps1` `git reset --hard` block: recorded, not fixed

Recorded above under Non-Goals. Different hook, different reason code; sibling child C (#902)
routes clearing through the script and side-steps it. **No new GitHub issue is opened from this
preparation run.**

## Proposed Fix

### Design summary (what changes where)

| File | Change |
| --- | --- |
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` (NEW) | Path constant, read seam, clock seam, JSON parse, normalized lookup, allow predicate |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | One `Import-Module`, one script-scope constant, one new branch before the final deny |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | Same three additions |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | Manifest-write step, step-9 removal authorization, `allowed-tools` grant, `<N>` fix at :104, accepted-residual note |
| `extensions/drm-copilot/resources/claude-customizations/.claude/**` | Mirrors of all four above |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | +1 module entry |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | +1 `CodeCoverage.Path` entry |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | +1 `CodeCoverage.Path` entry (mirror) |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` (428 lines) | Narrow-scope deny pins and allow cases |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` (392 lines) | Narrow-scope deny pins and allow cases |
| New Pester suite for the manifest module | Fail-closed matrix and module unit surface |

### Boundaries and invariants to preserve

- The two deny reason strings are unchanged, byte for byte.
- `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')` is unchanged in both hooks. The
  manifest introduces a **distinct** key (`removal_disposition`) with a distinct value set; the
  `merge_status` allow-set is not widened.
- The epic gate's existing two branches return the same decisions they return today for every
  existing fixture. The manifest branch adds allows and removes none.
- The must-not-touch list in D6.
- `HookPayload.psm1` carries no diff.
- No force flag is ever added to any removal spelling.

### Technical specification — the normative manifest contract

Sibling child F (#904) reads this shape verbatim. It is a normative cross-module contract.

#### Location and identity

- Path: `artifacts/orchestration/cleanup-worktrees-manifest.json`.
- Encoding: UTF-8 JSON. Key style: `snake_case`, matching the three existing hook-read documents.

#### Example

```json
{
  "tool": "cleanup-merged-worktrees",
  "schema_version": 1,
  "generated_at": "2026-09-07T03:40:00Z",
  "run_id": "cleanup-2026-09-07T03-40-00Z-a47a5e33",
  "removals": [
    {
      "worktree_path": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-0f1c2d",
      "branch": "drm-copilot-wt-2026-08-14T09-02",
      "branch_state": "HAS_UNIQUE_RESIDUALS",
      "removal_disposition": "SAFE_TO_DELETE",
      "verdict": "ALREADY_SOLVED_ELSEWHERE",
      "evidence": "Unique residual commit 3f9a1c2 records the cleanup-worktrees ancestry error; main already fixes it at scripts/bash/cleanup_worktrees_lib.sh:214-231 under issue #612."
    },
    {
      "worktree_path": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-77bb10",
      "branch": null,
      "branch_state": "NOT_MERGED",
      "removal_disposition": "SAFE_TO_DELETE",
      "verdict": "DEAD_ONE_OFF",
      "evidence": "Working tree carries only plan.2026-07-02T11-14.md for closed issue #488; diff against the closed feature's final artifacts shows no unique content."
    }
  ],
  "preserved_files": [
    {
      "worktree_path": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-91ee43",
      "source_path": ".claude/agent-memory/general-purpose/hook-payload-anomaly.md",
      "change_class": "untracked",
      "disposition": "PRESERVE",
      "verdict": "GENUINELY_NEW",
      "target_path": ".claude/agent-memory/general-purpose/hook-payload-anomaly-envelope.md",
      "memory_index_line": "- [Hook payload anomaly envelope](hook-payload-anomaly-envelope.md) - the deny path a malformed envelope takes",
      "line_ending": "crlf",
      "host_token_scan": {
        "result": "clean",
        "pattern_set_id": "child-f-host-tokens-v1"
      },
      "evidence": "No equivalent file on main under .claude/agent-memory/**; grep for 'payload anomaly' returns only this worktree."
    }
  ]
}
```

#### Top-level fields

| Name | JSON type | Required | Allowed values | Meaning | Fail-closed rule |
| --- | --- | --- | --- | --- | --- |
| `tool` | string | required | exactly `cleanup-merged-worktrees` | Self-identifying discriminator; plays the role `route_id` plays in the parallel checkpoint (epic gate :257) | Absent, non-string, or any other value ⇒ no record authorizes anything |
| `schema_version` | integer | required | exactly `1` | Contract version this document conforms to | Absent, non-integer, or any other value ⇒ fail closed. Forward versions are not accepted by silence |
| `generated_at` | string | required | ISO-8601 UTC timestamp | When the run wrote the manifest | Absent, unparseable, in the future, or older than the freshness bound ⇒ fail closed |
| `run_id` | string | required | non-empty | Opaque per-run identifier for audit correlation | Absent, non-string, or empty/whitespace ⇒ fail closed |
| `removals` | array | required | array of removal records (may be empty) | Per-worktree removal authorizations | Absent, non-array, or empty ⇒ no removal is authorized |
| `preserved_files` | array | required | array of preserve records (may be empty) | Per-file `PRESERVE` findings for child F | Never read by either hook. Absence or malformation must not affect any gate decision |

`removals` and `preserved_files` are **sibling arrays, never nested**. Three independent reasons:

1. **Different keys.** Removal records are keyed by worktree path; preserve records by the pair
   (worktree path, file path). A nested shape would force one key to masquerade as the other.
2. **The hooks must never traverse preserve data.** Every fail-closed convention the existing gates
   implement is written as "iterate the array, read two properties per record". Nesting a per-file
   array inside a removal record makes the hooks' iteration traverse data they must never authorize
   on, and makes the "written too broadly" regression test harder to write.
3. **`PRESERVE` entries legitimately exist for worktrees with no removal record.**
   `SKILL.md:204-205` routes `PRESERVE` findings through consolidation **before** that worktree's
   dirty content is discarded — a `PRESERVE` finding is precisely a reason a worktree is not yet
   removable. A nested shape would force a removal record to exist for every preserve entry.

#### `removals[]` record fields

| Name | JSON type | Required | Allowed values | Meaning | Fail-closed rule |
| --- | --- | --- | --- | --- | --- |
| `worktree_path` | string | required | non-empty | Absolute path of the worktree to remove | Absent or empty ⇒ record skipped (`continue`), consistent with epic :187-189 |
| `branch` | string or null | required key | any branch name, or `null` | The worktree's branch; `null` for a detached worktree | Key absent ⇒ record does not authorize. `null` is a valid, meaningful value |
| `branch_state` | string | required | a member of the branch-state vocabulary enumerated in the Vocabulary table below (source `SKILL.md:61-62`) | The classification the report emitted for that branch | Absent, out of vocabulary, or not in the authorized set ⇒ record does not authorize |
| `removal_disposition` | string | required | allowed set is exactly the single member `SAFE_TO_DELETE` | The triage disposition that authorizes removal | Absent or any other value ⇒ record does not authorize |
| `verdict` | string | required | a member of the step-5 verdict vocabulary enumerated in the Vocabulary table below (source `SKILL.md:169-182`) | The step-5 content classification that produced the disposition | Absent, out of vocabulary, or a preserve-implying value ⇒ record does not authorize |
| `evidence` | string | required | non-empty | The justification `SKILL.md:141-142` requires, citing specific files or commit SHAs | Absent, non-string, empty, or whitespace-only ⇒ record does not authorize |

#### `preserved_files[]` record fields

These are read by child F (#904), never by the hooks.

| Name | JSON type | Required | Allowed values | Meaning | Fail-closed rule |
| --- | --- | --- | --- | --- | --- |
| `worktree_path` | string | required | non-empty | Worktree holding the file; also where child F reads that worktree's `MEMORY.md` | Absent ⇒ record is not stageable; consumer skips and reports |
| `source_path` | string | required | repo-relative within that worktree | The file to preserve | Absent or absolute ⇒ consumer skips and reports |
| `change_class` | string | required | `untracked` \| `modified` | Whether staging adds a new file or carries a working-tree modification | Absent or out of set ⇒ consumer skips and reports |
| `disposition` | string | required | exactly `PRESERVE` | The triage disposition | Any other value ⇒ consumer skips |
| `verdict` | string | required | a member of the step-5 verdict vocabulary enumerated in the Vocabulary table below (source `SKILL.md:169-182`) | The classification that produced `PRESERVE` | Absent or out of vocabulary ⇒ consumer skips and reports |
| `target_path` | string | required | repo-relative on the consolidation branch | Destination. Required because the same relative path may already exist on `main` with different content (`SKILL.md:157-159`) and a lesson file may be re-namespaced | Absent ⇒ consumer must not guess; skip and report |
| `memory_index_line` | string or null | required key | the `MEMORY.md` index line from the source worktree, or `null` when the file is not a memory entry | Carried so the consolidated `MEMORY.md` index stays consistent | Key absent ⇒ consumer skips and reports. `null` is valid |
| `line_ending` | string | required | `crlf` \| `lf` \| `absent` | **ADVISORY.** The TARGET file's existing line-ending convention (`absent` when the target does not yet exist) | Child F must **re-derive and compare** rather than trust it. A stale value would drive exactly the mixed-ending defect gap 5 exists to fix |
| `host_token_scan` | object | required | `{ "result": <scan result>, "pattern_set_id": <identifier> }` | The scan outcome plus the identifier of the pattern set used — **never the patterns themselves** | Absent, non-object, or missing either member ⇒ consumer refuses to stage |
| `evidence` | string | required | non-empty | The justification `SKILL.md:141-142` requires | Absent or empty ⇒ consumer skips and reports |

**`_shared_no_absolute_host_paths` does not exist anywhere in this repository.** A
repository-wide search for that literal returns exactly one file — the run-observations document
itself. Searches for `no_absolute_host_paths`, `absolute-host-path`, `host_path`, and
`absolute host path`, case-insensitively, return no production or test artifact defining it. This
child therefore defines only the `host_token_scan` **field contract**; child F (#904) owns the
pattern set and its identifier. The manifest records a result plus a pattern-set identifier, never
the patterns.

#### Vocabulary

Reused verbatim from `.claude/skills/cleanup-merged-worktrees/SKILL.md`:

| Vocabulary | Members | Source | Manifest field |
| --- | --- | --- | --- |
| Dispositions | `SAFE_TO_DELETE`, `PRESERVE` | `SKILL.md:141`, :201, :211, :242 | `disposition` on `preserved_files[]` |
| Step-5 verdicts | `DEAD_ONE_OFF`, `ALREADY_SOLVED_ELSEWHERE`, `STALE_OR_CONTRADICTED`, `GENUINELY_NEW`, `STILL_RELEVANT` | `SKILL.md:169-182` | `verdict` on both arrays |
| Branch states | `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `NOT_MERGED`, `HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT` | `SKILL.md:61-62` | `branch_state` on `removals[]` |

`SKILL.md:179` writes `GENUINELY_NEW` / `STILL_RELEVANT` as one bullet holding two alternative
labels. **The manifest represents them as two distinct enum members**, with this note: the skill
treats them as one class. This avoids inventing a joined token that appears nowhere in the skill.

Defined anew by this specification, with justification:

- **`removal_disposition`** — the removal-authorizing key. Deliberately **not** `merge_status`.
  `merge_status` values `merged` and `worktree_removed` mean "this feature's PR merged", which is a
  different fact from what a cleanup verdict establishes. Keeping the keys distinct is also what
  lets a test assert that the epic and parallel `merge_status` branches were not widened.
- **`evidence`** — required non-empty. This is the single field that makes a record an auditable
  verdict rather than a bare allowlist entry, and it is what `issue.md:53-55` means by "a removal
  that a recorded verdict and its evidence cover".
- **`branch_state`** — carried so the predicate can require a state the script's apply-mode
  allowlist deliberately excludes, keeping the manifest acceptance as narrow as the evidence
  supports.
- **`generated_at`** and **`run_id`** — the freshness discriminator and audit correlator required
  by the staleness analysis below.
- **`schema_version`** — so a future shape change fails closed rather than being read under the
  wrong interpretation.

### Technical specification — the allow predicate

A `git worktree remove <path>` command is authorized by the manifest branch **only when every one
of the following holds**. Any other state denies with the gate's existing, unchanged reason code.

1. **The manifest file exists, is readable, and parses as JSON.** Absent file, null or whitespace
   raw text, and a `ConvertFrom-Json` throw each yield a `$null` parsed object, matching the
   existing gates' conventions.
2. **`tool` equals `cleanup-merged-worktrees` and `schema_version` equals `1`.** Either check
   failing ends evaluation.
3. **Freshness.** `generated_at` parses as a timestamp, is not in the future relative to the
   injected clock, and is no more than **24 hours** older than the injected clock's value.
   An **injectable clock seam** is required so the tests are deterministic and read no wall clock
   (`.claude/rules/powershell.md` adapter-seam rule; `.claude/rules/general-unit-test.md`
   Determinism Infrastructure). **Justification for the bound:** `artifacts/` is gitignored
   (`.gitignore:6`), so a stale manifest persists after a run ends. The epic gate's existing
   accepted-residual argument (:38-46) turns on worktree paths carrying a session or timestamp
   component, making a stale collision implausible. **That argument does not transfer.** Cleanup
   targets are ordinary long-lived worktree paths, so a stale cleanup manifest is materially more
   re-matchable, and the epic gate's residual argument must not be carried across unexamined.
4. **`removals` is present, is an array, and is non-empty.**
5. **Some record's `worktree_path` matches the command target after normalization.**
   Normalization on both sides is: replace backslashes with forward slashes, then trim a trailing
   slash. A trailing slash, a quoted path, and a Windows-separator path must all compare equal to a
   recorded POSIX path. (Quote stripping is already performed upstream by the extraction function;
   this child does not depend on that spelling — see D6.)
6. **That record's `removal_disposition` is `SAFE_TO_DELETE`.**
7. **That record's `evidence` is present and non-empty.**
8. **That record's `verdict` is present, is in the vocabulary, and is neither `GENUINELY_NEW` nor
   `STILL_RELEVANT`.** `SKILL.md:179-182` classifies both as content that "must be preserved before
   the worktree is deleted", so either value directly contradicts a `SAFE_TO_DELETE` disposition.
9. **That record's `branch_state` is in the narrow authorized set, which is exactly
   `NOT_MERGED` and `HAS_UNIQUE_RESIDUALS`.** Justification for the narrowness: those are precisely
   the two states `SKILL.md:239-245` permanently forbids adding to the script's apply-mode
   allowlist, so they are the durable residual the manifest exists to serve. `PROTECTED_CURRENT`
   is **never** authorized under any disposition. The three merged states
   (`MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`) and the detached case are
   excluded because the script's deterministic path owns them once sibling children #630 and #902
   land. **Bounded consequence, stated explicitly:** until #630 and #902 land, a `SAFE_TO_DELETE`
   verdict on a merged-state or detached worktree is not authorized by the manifest branch and
   still denies. That is intentional; widening it now would authorize removals the deterministic
   path is about to cover.
10. **Checkpoint exclusion.** If the normalized target path matches **any** record in the epic
    checkpoint's `features[]` or the parallel checkpoint's `items[]`, **regardless of that
    record's `merge_status`**, the manifest branch does not apply. A removal targeting an epic or
    parallel item worktree that no checkpoint authorizes must still deny with
    `EPIC_WORKTREE_REMOVAL_BLOCKED` and `PARALLEL_WORKTREE_REMOVAL_BLOCKED` respectively. **This is
    the only path by which the manifest could widen what the gates protect, and closing it is
    mandatory.**

#### Ordering

- The manifest branch runs **after** the existing branches in the epic gate, so an
  epic-checkpoint-authorized removal continues to allow at the same decision point and no existing
  transcript attribution changes.
- Conditions 1 through 4 are evaluated **before** condition 5, so an absent or malformed manifest
  costs one file-existence test and returns to the deny path.
- Condition 10 is evaluated such that a checkpoint-recorded path never reaches a manifest allow,
  under either evaluation order.

#### Pinned edge cases

- Manifest present but `removals` empty ⇒ **deny**.
- Two records with the same normalized `worktree_path` and different dispositions ⇒ **resolve on
  the first match**, following the existing fail-closed precedent at epic :280-282, where the
  parallel branch returns `$false` immediately on the first path match whose record lacks
  `merge_status` rather than continuing to scan. **This choice is stated explicitly rather than
  left implicit**, and is pinned by a named test.
- A record whose `worktree_path` key is absent ⇒ record skipped (`continue`), scan continues.
- Trailing slash, quoted path, and Windows-separator path all compare equal to a recorded POSIX
  path.

### Error handling and logging

- No new logging surface. Both gates emit a single compact decision JSON object; that contract is
  unchanged.
- The manifest module raises nothing on a malformed manifest. Every malformation resolves to a
  `$null` parsed object or a `$false` predicate result, matching the existing gates' fail-closed
  conventions. Broad catch-alls are confined to the JSON parse boundary, where the existing hooks
  already use `try { ... } catch { $parsed = $null }`.

### Skill-text changes required

1. **A new step or sub-step that writes the manifest**, naming the path
   `artifacts/orchestration/cleanup-worktrees-manifest.json` and the record shape (top-level
   fields, `removals[]` fields, `preserved_files[]` fields), so a reader of the skill can produce a
   conforming document without reading the hook source.
2. **An explicit authorization in step 9 of the Dirty Worktree Triage Procedure** for a
   per-worktree `git worktree remove <path>`, issued as its own Bash tool call, for a
   `SAFE_TO_DELETE` verdict on a `NOT_MERGED` or `HAS_UNIQUE_RESIDUALS` worktree that the manifest
   covers. **No current sentence of the skill authorizes this command**: `SKILL.md:212-214`
   authorizes only clearing the working tree and deleting a disposable branch, and :193-194 forbids
   the removal command for orphaned directories. **The skill-text change is therefore half the fix,
   not documentation of it**, which is why the epic keeps hook and skill in one child
   (`epic.md:90-93`).
3. **The `allowed-tools` grant `Bash(git worktree remove *)`**, with no force spelling, and the
   existing force-flag prohibition at `SKILL.md:236-237` restated adjacent to the new step so the
   grant is not read as permitting `--force`.
4. **The `<N>` fix at `SKILL.md:104`** per D9.
5. **The accepted `bash <file>` residual** per D8, stated with the
   `enforce-pr-author-skill.ps1:35-41` posture.
6. **Every one of these `.claude/**` edits mirrored byte-identically** into
   `extensions/drm-copilot/resources/claude-customizations/.claude/**`.

## Assumptions, Constraints, Dependencies

### Assumptions

- PreToolUse denials are conjunctive across hooks registered on the same matcher. Supported by
  three prose assertions, one 2026-08-26 field observation, and a structural argument, and
  explicitly **not** re-verified by execution (D2).
- Sibling children #630 and #902 land before or alongside this child, so the deterministic apply
  path covers the detached and disposable-dirt cases. Condition 9's narrowness is stated with its
  bounded consequence if they have not.

### Constraints

- **500-line cap** on every production, test, and reusable script file
  (`.claude/rules/general-code-change.md`). Markdown is exempt. Current headroom:
  `enforce-epic-worktree-removal-gate.ps1` 81 lines, `enforce-parallel-worktree-removal-gate.ps1`
  219 lines, `HookPayload.psm1` **4 lines — must not be modified**, the two existing Pester suites
  72 and 108 lines. Do not touch `scripts/bash/cleanup_worktrees_*_lib.sh` or
  `.claude/hooks/enforce-epic-merge-gate.ps1` (a sibling child owns the latter).
- **No Python in enforcement hooks.** `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
  scans exactly `.claude/hooks` and `.claude/lib` for `*.ps1` and `*.psm1`, so the new module is
  automatically in scope. Detection is AST-based in four classes: a constant interpreter command
  (`python`, `python3`, `py`, `poetry`, including `&`-invoked, `.`-invoked, and quoted forms); a
  subprocess start whose `-FilePath` or first positional argument is an interpreter; dynamic
  invocation, fail-closed (`& $var` where `$var` is not a `[scriptblock]` parameter, or
  `& (expression)` in command position, with carve-outs for a named `[scriptblock]` seam parameter
  and for dot-sourced sibling-helper loads via `Join-Path` with a literal `.ps1`); and
  `Invoke-Expression` with its `iex` alias. The allowlist ships empty and is asserted empty
  (:102-109). PowerShell only.
- **No temporary files in tests** (`.claude/rules/general-unit-test.md`). Everything is driven
  through the injectable read and clock seams.
- **PowerShell change budget** (`.claude/rules/powershell.md`): at most 3 production files and 3
  test files per batch. This change touches 3 production PowerShell files (one new module, two
  hooks) plus their mirrors and 3 test files; the planner must batch accordingly.

### External dependencies

- Child E (#545) per D6, whose actual scope contradicts the epic manifest's premise for the edge.
  Escalated to the epic planner. This child composes with either resolution.
- Child F (#904) consumes the `preserved_files[]` contract defined here.

## Data / API / Config Impact

- **New data artifact:** `artifacts/orchestration/cleanup-worktrees-manifest.json`, written by the
  skill, read by both gate hooks (`removals[]` only) and by child F (`preserved_files[]` only).
  Gitignored (`.gitignore:6`).
- **Config keys:** one new `CodeCoverage.Path` entry in
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and one in its mirror at
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. That key
  is an explicit per-file allow-list, so an unregistered production file sits outside the coverage
  denominator, which the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` forbids.
- **Pack manifest:** one new module entry in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, alongside the
  existing `.claude/lib/**/*.psm1` entries. `pack-manifests/` is outside the parity test's scope;
  completeness is enforced separately by
  `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`.
- **Backward compatibility:** additive. `schema_version` is `1` and any other value fails closed,
  so a future shape change cannot be misread as this one.
- **Command-line/CLI:** no bash script flags are added or changed.

## Delivery Obligations

### Push-down parity

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` sets
`SCOPED_ROOTS = (Path(".claude"),)` and enumerates via `rglob("*")` under that single root, so the
**whole `.claude` tree is in scope** — `hooks/`, `lib/`, `skills/`, `rules/`, `agents/` alike.
**The new module file IS covered** and must be mirrored into
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`
in the same change. Parity is **UTF-8 text equality** (`read_text`), not byte equality; the
byte-identity test at :134-144 covers only three named files. Exactly two exclusions exist:
`.claude/settings.local.json` and `.claude/agent-memory/**`.

### No-Python guard

As stated under Constraints. The guard's scan roots include `.claude/lib`, so the new module is
automatically in scope; its allowlist ships empty and is asserted empty, and an entry may only be
added by an owner decision, never to pass a failure.

### Coverage

- The new module is registered under the `CodeCoverage.Path` key in
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` **and** in its mirror under
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/`.
- **Known environment defect.** `mcp__drm-copilot__run_poshqc_test` reads the **installed
  extension's** PoshQC settings, so a coverage entry newly added to the repository's runsettings
  can be ignored by the MCP runner. Confirm the new file is in the denominator by invoking the
  self-hosted module directly:

  ```text
  pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
  ```

  `-SettingsPath` is redundant once the module is imported from the repository but makes the
  binding explicit in the evidence record.
- **Line coverage >= 85%** on the new module and both changed hooks. PowerShell is exempt from the
  branch-coverage threshold **only** because Pester does not measure branch coverage. That is a
  **threshold exemption, not a measurement exemption**: PowerShell production files remain in the
  coverage denominator (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`).

### Evidence locations

All evidence artifacts go to
`docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/<kind>/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Fail-before regression output is
recorded under `evidence/regression-testing/`. Writing to `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/coverage/`, or `artifacts/evidence/` is a policy violation caught by the
`enforce-evidence-locations.ps1` PreToolUse hook.

## Test Strategy

- **Regression-first.** The allow tests for a manifest-covered removal must be written and observed
  to **fail against the unfixed hooks** before the hook change lands. Fail-before output is
  recorded under `evidence/regression-testing/`.
- **Narrow-scope deny pins.** One per gate for condition 10: a bare `git worktree remove` targeting
  an epic-checkpoint `features[]` worktree, and one targeting a parallel-checkpoint `items[]`
  worktree, each with a manifest record that would otherwise authorize, must still deny with the
  existing reason code. These fail if the manifest acceptance is written too broadly.
- **Fail-closed matrix.** One named `It` per condition 1 through 9, driven through the module's
  injectable read seam and clock seam. No temporary files.
- **Non-widening pin.** The epic gate's branch-1 and branch-2 predicates return the same decisions
  they return today for the existing fixture set — the manifest branch adds allows and removes
  none.
- **Vocabulary pins.** The allowed-disposition set and the authorized-branch-state set are
  script-scope constants asserted by named tests, following the `$script:AllowedMergeStatuses`
  precedent (epic :65, parallel :34).
- **Placement.** Test files mirror the production tree per `.claude/rules/general-unit-test.md`.
  `tests/scripts/claude-lib/` mirrors `.claude/lib/` one directory per module, so the module unit
  surface belongs at `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`,
  matching the production path `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` and the
  convention every existing module suite already follows. The fail-closed matrix suite dot-sources
  the two gate hooks rather than the module alone, so it mirrors the hook tree and belongs at
  `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`. Only the narrow-scope
  deny pins and the gate allow cases need to live beside the existing decision fixtures in the two
  existing suites, which have 72 and 108 lines of headroom. No acceptance criterion asserts a
  test-file location, so these paths are a policy-conformance choice rather than a criterion.
- **Toolchain loop.** `mcp__drm-copilot__run_poshqc_format` → `run_poshqc_analyze` →
  `run_poshqc_test`, restarting from format on any failure or auto-fix, until a clean single pass;
  plus the self-hosted PoshQC invocation for the coverage evidence.

## Acceptance Criteria

Each criterion names a stable identifier. Criteria that assert behavior name a Pester `Describe` /
`It` and assert its outcome rather than searching for a prose phrase. Test names below are the
required names; the atomic planner may add cases but must not rename these.

### Fail-before regression

- [x] **AC-01** In `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, the
      test `It 'allows removal when a fresh manifest record authorizes the target'` passes:
      `Invoke-EpicWorktreeRemovalGateDecision` returns `permissionDecision` `allow` for
      `git worktree remove <path>` when a manifest satisfying conditions 1-10 covers `<path>` and
      no checkpoint records it. Fail-before output against the unfixed hook is recorded under
      `evidence/regression-testing/`.
- [x] **AC-02** In `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`,
      the test `It 'allows removal when a fresh manifest record authorizes the target'` passes for
      `Invoke-ParallelWorktreeRemovalGateDecision` under the same conditions. Fail-before output
      recorded under `evidence/regression-testing/`.

### Condition 10 — narrow-scope deny pins

- [x] **AC-03** `It 'denies a manifest-covered removal whose target an epic checkpoint records'`
      passes: with a manifest record satisfying conditions 1-9 for `<path>` **and** an epic
      checkpoint `features[]` record for the same normalized `<path>` carrying a `merge_status`
      outside `{merged, worktree_removed}`, the epic gate returns `deny` with a reason beginning
      `EPIC_WORKTREE_REMOVAL_BLOCKED`.
- [x] **AC-04** `It 'denies a manifest-covered removal whose target a parallel checkpoint records'`
      passes: with a manifest record satisfying conditions 1-9 for `<path>` **and** a parallel
      checkpoint `items[]` record for the same normalized `<path>` carrying a `merge_status`
      outside `{merged, worktree_removed}`, the parallel gate returns `deny` with a reason
      beginning `PARALLEL_WORKTREE_REMOVAL_BLOCKED`.

### Non-regression of existing enforcement

- [x] **AC-05** The two deny reason strings are unchanged. A named test asserts the epic gate's
      block reason and the parallel gate's block reason are character-for-character equal to the
      strings recorded in this specification's Repro & Evidence section for the epic gate and in
      `enforce-parallel-worktree-removal-gate.ps1` today for the parallel gate.
- [x] **AC-06** Non-widening pin: every pre-existing `It` in both gate suites that exercises the
      epic gate's branch 1 or branch 2, or the parallel gate's single branch, passes unchanged with
      no assertion weakened and no fixture altered. The manifest branch adds allows and removes
      none.
- [x] **AC-07** `$script:AllowedMergeStatuses` in both hooks still equals exactly
      `@('merged', 'worktree_removed')`, asserted by a named test. The `merge_status` allow-set is
      not widened by this change.

### Fail-closed matrix (conditions 1 through 9)

- [x] **AC-08** Condition 1: named tests cover manifest file absent, raw text null/whitespace, and
      `ConvertFrom-Json` throwing. Each returns `deny` from both gates.
- [x] **AC-09** Condition 2: named tests cover `tool` absent, `tool` set to any other value,
      `schema_version` absent, `schema_version` non-integer, and `schema_version` equal to `2`.
      Each returns `deny` from both gates.
- [x] **AC-10** Condition 3: named tests, driven through the injected clock seam with no wall-clock
      read, cover `generated_at` absent, unparseable, in the future, exactly at the 24-hour bound,
      and beyond the 24-hour bound. The out-of-bound, future, absent, and unparseable cases return
      `deny`; the at-bound case's decision is asserted explicitly.
- [x] **AC-11** Condition 4: named tests cover `removals` absent, `removals` non-array, and
      `removals` empty. Each returns `deny` from both gates.
- [x] **AC-12** Condition 5: named tests assert that a trailing-slash target, a quoted target, and
      a Windows-separator target each compare equal to a recorded POSIX `worktree_path` and are
      allowed; and that a non-matching path returns `deny`. A record whose `worktree_path` key is
      absent is skipped and the scan continues to a later matching record.
- [x] **AC-13** Condition 6: named tests cover `removal_disposition` absent, set to `PRESERVE`, and
      set to any value outside the single-member allowed set. Each returns `deny`.
- [x] **AC-14** Condition 7: named tests cover `evidence` absent, empty string, and whitespace-only.
      Each returns `deny`.
- [x] **AC-15** Condition 8: named tests cover `verdict` absent, out of vocabulary,
      `GENUINELY_NEW`, and `STILL_RELEVANT`. Each returns `deny`.
- [x] **AC-16** Condition 9: named tests cover `branch_state` absent, `PROTECTED_CURRENT`, each of
      `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, and `MERGED_EQUIVALENT`, and a value outside the
      vocabulary. Each returns `deny`. Named tests also confirm `NOT_MERGED` and
      `HAS_UNIQUE_RESIDUALS` are allowed when conditions 1-8 and 10 hold.

### Contract and vocabulary pins

- [x] **AC-17** `It 'never reads preserved_files'` passes: a manifest whose `preserved_files` array
      is malformed (non-array, or containing records missing every required field) produces exactly
      the same decision from both gates as the same manifest with `preserved_files` set to `[]`.
- [x] **AC-18** `It 'resolves duplicate worktree_path records on the first match'` passes: a
      manifest with two `removals[]` records sharing a normalized `worktree_path`, the first
      non-authorizing and the second authorizing, returns `deny`; and with the order reversed,
      returns `allow`.
- [x] **AC-19** The allowed-disposition set is a script-scope constant in the new module whose
      value is exactly the single member `SAFE_TO_DELETE`, asserted by a named test following the
      `$script:AllowedMergeStatuses` precedent.
- [x] **AC-20** The authorized-branch-state set is a script-scope constant in the new module whose
      value is exactly `NOT_MERGED` and `HAS_UNIQUE_RESIDUALS`, asserted by a named test.

### Delivery obligations

- [x] **AC-21** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes, with
      `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, both changed hooks, and the
      changed `SKILL.md` present and text-equal in
      `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- [x] **AC-22** `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`
      passes with the new module entry present in
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- [x] **AC-23** `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
      passes and its allowlist is still empty, asserted by the suite's existing empty-allowlist
      test.
- [x] **AC-24** `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` appears in the
      `CodeCoverage.Path` list of both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
      and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- [ ] **AC-25** Line coverage is >= 85% for `CleanupWorktreeManifest.psm1`,
      `enforce-epic-worktree-removal-gate.ps1`, and `enforce-parallel-worktree-removal-gate.ps1`,
      verified through the self-hosted PoshQC invocation
      (`Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`)
      rather than `mcp__drm-copilot__run_poshqc_test`, with the coverage report recorded under
      `evidence/qa-gates/`. `evidence/coverage/` is not a canonical evidence sub-path: the
      canonical set in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` is
      `baseline/`, `regression-testing/`, `qa-gates/`, `issue-updates/`, `other/`, and
      `remediation-baseline/`, and coverage output belongs under `qa-gates/`.
- [x] **AC-26** `.claude/lib/hook-payload/HookPayload.psm1` carries no diff in this change.
- [x] **AC-27** No file changed or added by this work exceeds 500 lines, verified per file:
      both gate hooks, the new module, both changed Pester suites, and the new Pester suite.
- [x] **AC-28** No test added by this work creates, writes, or reads a temporary file; the manifest
      read boundary and the clock boundary are exercised exclusively through the module's
      injectable seams.

### Scope-boundary pins

- [x] **AC-29** `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` carries no diff (D7).
- [x] **AC-30** `.claude/hooks/validate-bash.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`,
      `scripts/bash/cleanup-worktrees.sh`, `scripts/bash/cleanup_worktrees_lib.sh`,
      `scripts/bash/cleanup_worktrees_actions_lib.sh`, and
      `scripts/bash/cleanup_worktrees_enumerate_lib.sh` all carry no diff (D10 and the epic's
      conflict-freedom constraint).
- [x] **AC-31** In both gate hooks, the extraction regex strings, their `.Trim('"''')` calls, the
      trigger guards, the bodies of `Get-EpicWorktreeRemovalCommandPath` and
      `Get-ParallelWorktreeRemovalCommandPath`, the decision constructors, the entry points, and
      the thin tails are unchanged (D6 must-not-touch list). Line numbers re-derived at execution
      time.

### Skill-text changes

- [x] **AC-32** `.claude/skills/cleanup-merged-worktrees/SKILL.md` contains a manifest-write step
      naming `artifacts/orchestration/cleanup-worktrees-manifest.json` and specifying the top-level
      fields, the `removals[]` fields, and the `preserved_files[]` fields defined in this
      specification.
- [x] **AC-33** `SKILL.md` step 9 of the Dirty Worktree Triage Procedure explicitly authorizes a
      per-worktree `git worktree remove <path>`, issued as its own Bash tool call, for a
      `SAFE_TO_DELETE` verdict on a `NOT_MERGED` or `HAS_UNIQUE_RESIDUALS` worktree the manifest
      covers.
- [x] **AC-34** `SKILL.md` `allowed-tools` contains `Bash(git worktree remove *)` with no force
      spelling, and the force-flag prohibition is restated adjacent to the new step-9 action.
- [x] **AC-35** `SKILL.md` contains no occurrence of the literal `396`, and `SKILL.md:104`'s
      replacement text instructs use of the GitHub issue number the run executes under when one
      exists, deferring to `.claude/skills/pr-author/SKILL.md`, and states for the no-issue-number
      case that `<N>` is an arbitrary run-scoped identifier chosen by the pr-author agent, that it
      is not a PR number, and that the only requirement is agreement between the body-file path,
      the receipt's `number` field, and the body bytes.
- [x] **AC-36** `SKILL.md` records the `bash <file>` indirection as an accepted residual using the
      `enforce-pr-author-skill.ps1:35-41` posture — a policy-level integrity check that prevents
      accidental bypass and requires a deliberate, documented act to circumvent, not a
      cryptographic or security boundary.

### Toolchain

- [x] **AC-37** A full PowerShell toolchain loop completes in a single clean pass:
      `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` →
      `mcp__drm-copilot__run_poshqc_test`, with zero analyzer findings and no auto-fixed files on
      the final pass.

## Risks & Mitigations

| Risk | Mitigation |
| --- | --- |
| The manifest branch is written broadly enough to authorize removal of an epic or parallel item worktree | Condition 10 plus AC-03 and AC-04, which fail if the acceptance is written too broadly |
| A stale manifest in gitignored `artifacts/` re-authorizes a removal after the run ends | Condition 3's 24-hour bound with an injected clock; AC-10 |
| The `merge_status` allow-set is widened during implementation | `removal_disposition` is a deliberately distinct key; AC-07 asserts the constant is unchanged |
| #545's actual scope diverges from the epic manifest's premise, invalidating the dependency edge | D6 records the contradiction and escalates it; the design composes with either resolution because acceptance sits below the detection call site |
| Coverage appears green because the MCP runner read the installed extension's settings | AC-25 requires the self-hosted PoshQC invocation and a recorded coverage report |
| The skill ships describing a hook contract that the hooks do not yet accept | Hook and skill change ship in one child by epic design (`epic.md:90-93`); AC-32 through AC-34 pair with AC-01 and AC-02 |
| The `bash <file>` indirection is mistaken for closed | D8 records it as accepted; AC-36 requires the skill text to state the posture; no criterion claims closure |

## Rollout & Follow-up

- Ships in `drm-copilot`. Consumer repositories receive the change through the existing push-down
  mechanism; no consumer copy is patched (`epic.md:185-187`).
- Merges into `epic/cleanup-merged-worktrees-hardening-integration` as epic child D.

Follow-up candidates recorded, none opened as a GitHub issue from this preparation run:

1. Whether `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` must also learn the manifest (D7).
2. The `git reset --hard` block in `.claude/hooks/validate-bash.ps1` that prevents step 9's
   working-tree clearing (D10).
3. The stale docstring at `enforce-pr-author-skill.ps1:25` and :29-30 stating five receipt checks
   where the helper file and the implementation carry six (D9).
4. The `bash <file>` indirection, accepted rather than closed (D8).

Links:

- Issue: <https://github.com/drmoisan/drm-copilot/issues/635>
- Epic: `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`
- Research: `research/2026-09-07-sanctioned-removal-manifest-research.md`
- Narrative and non-functional context: `user-story.md`
