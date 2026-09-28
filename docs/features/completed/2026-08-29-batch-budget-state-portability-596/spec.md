# 2026-08-29-batch-budget-state-portability (Spec)

- **Issue:** #596
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-29T16-05
- **Status:** Ready for planning
- **Version:** 0.2
- **Work Mode:** full-bug (`spec.md` is the sole acceptance-criteria source; no `user-story.md`)

## Context
The batch-budget PreToolUse hooks keep session state that is neither session-scoped nor
worktree-scoped, and the push-down mechanism that publishes the `.claude/**` payload into a consumer
repository has no destination-side `.gitignore` writer at all, so the runtime-created state file
becomes a tracked file in the consumer repository.

This is Feature B (wave 0) of the `claude-runtime-portability` epic
(`docs/features/epics/claude-runtime-portability/epic.md`).

Environment:
- OS/version: Windows 11 Pro 10.0.26200; PowerShell 7 (`pwsh`)
- Python version: not applicable — the affected hooks are PowerShell, and the push-down code is TypeScript
- Command/flags used: the PreToolUse hook invocations of `.claude/hooks/enforce-powershell-batch-budget.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1`; the extension's push-down command
- Data source or fixture: `.claude/state/powershell-batch-budget.<SessionId>.json` (runtime-created; the directory is git-ignored at `.gitignore:68` and does not exist in a fresh checkout)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The shared counter denies legitimate work in a session that did not perform it, and the missing
destination ignore entry lets a consumer repository track runtime state, which poisons a fresh
checkout.


## Repro & Evidence
Steps to Reproduce:
1. Run any agent session in which `$env:CLAUDE_SESSION_ID` is not set, and let the PowerShell
   batch-budget hook record at least one file. The hook writes
   `.claude/state/powershell-batch-budget.default.json`.
2. Start a second, unrelated session that also has no resolved session id. It reads and increments
   the same `default` counter rather than starting a fresh one, and the budget denies work that the
   second session never performed. Nothing resets the counter: the hook has no TTL and no timestamp
   check, and its own deny message instructs the operator to delete the file by hand.
3. From a second git worktree of the same repository, let the hook record a file. The recorded path
   is the raw `file_path` string from the tool payload, so a path belonging to a different worktree
   is counted against the current worktree's budget.
4. Push the `.claude/**` payload down into a consumer repository. No `.gitignore` entry for
   `.claude/state/` is written at the destination, so the runtime-created state file is untracked
   only until someone stages it, and a fresh clone of the consumer repository can carry a tracked
   batch-budget session-state file.

Expected:
- A session without a resolved session id gets a counter that is distinct per session, or the state
  is reset on a defined condition rather than never.
- Recorded paths are canonicalized and constrained to the current worktree root, so a path from
  another worktree is discarded rather than counted.
- A push-down delivers whatever destination-side ignore configuration the payload requires, so a
  consumer repository never tracks runtime session state. The delivery is idempotent across repeat
  push-downs.

Actual:
Verified against the current tree at commit `c861ddff`:

- `.claude/hooks/enforce-powershell-batch-budget.ps1:157` declares `[string] $SessionId = 'default'`
  as the parameter default, and lines 248-250 in the entry point assign `$sessionId = 'default'`
  when `$env:CLAUDE_SESSION_ID` is unset. Line 193 composes the state path as
  `powershell-batch-budget.$SessionId.json`. Every session without a resolved session id therefore
  shares one counter.
- `.claude/hooks/enforce-python-batch-budget.ps1` has the identical defect at lines 154, 190, and
  245-247, so the sibling hook is in scope.
- Recorded paths are normalized only by `-replace '\\', '/'` at
  `.claude/hooks/enforce-powershell-batch-budget.ps1:122` and `:183`. There is no `Resolve-Path`,
  no canonicalization, and no check that a recorded path falls under the current worktree root.
- No destination-side `.gitignore` writer exists anywhere in the push-down pipeline.
  `pushDownClaudeCustomizationsServiceCall`
  (`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:166`) copies from the
  pre-built bundle root, and `enumerateSourceFiles`
  (`extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts:156`) walks the two
  root folders `.claude` and `config`, excluding only `.claude/settings.local.json`. A repository
  search for `gitignore` under `extensions/drm-copilot/src/` returns exactly one match, an unrelated
  comment in `render-pr-helpers.ts:422`.

Note on scope correction: the originating intake framed the fourth item as a missing `.gitignore`
line. It is larger than that. There is no writer to add the line to, so the fix is net-new
TypeScript capability in the extension.

Live artifact observed during preparation:

`.claude/state/python-batch-budget.default.json` exists in this worktree with the content below. Its
provenance is stated precisely so it is not misread: it did **not** pre-exist. The orchestrator
created it during this preparation run at approximately 16:07 local time by writing a single
scratchpad file. The epic manifest's statement that `.claude/state/` "does not exist in this worktree
at all" was accurate when the manifest was authored; it is no longer accurate, and the manifest was
not wrong.

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    "C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-08-29T15-07/10460c0f-1dc1-4f43-8a37-0453379bc08a/scratchpad/make_negative_control.py"
  ],
  "testFiles": []
}
```

The artifact demonstrates two of the three defects in one file, without constructing a repro:

- Defect 2 (shared identity): the filename component is the literal `default`, so
  `$env:CLAUDE_SESSION_ID` was unset in the hook process and the fallback fired.
- Defect 3 (unscoped paths): the recorded path is not merely in another worktree. It is outside the
  repository entirely, under the OS temporary directory. It has permanently consumed one of the
  three production Python slots for every subsequent session that also resolves to `default`.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: see the live artifact above. The remaining evidence is the static citations enumerated
  under Actual Behavior; no failing run is required to observe them.


## Scope & Non-Goals

- In scope:
  - `.claude/hooks/enforce-powershell-batch-budget.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1`:
    session-identity resolution, state-path composition, recorded-path canonicalization, and
    worktree-root containment.
  - `.claude/hooks/persist-session-id.ps1`: unconditional publication of
    `.claude/state/current-session-id`, which is what makes the second source of the documented
    session-id chain populated in every session (see Proposed Fix, session identity).
  - The byte-identical bundle mirrors of all three hooks under
    `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
  - Net-new destination-side ignore-delivery capability in the push-down pipeline: a new pure merge
    module under `extensions/drm-copilot/src/lib/push-down/`, its call site in
    `pushDownCustomizations`, its per-file coverage-threshold entry in
    `extensions/drm-copilot/jest.config.cjs`, and its tests.
  - The Pester suites for the three hooks and the Jest suites for the new module and its end-to-end
    delivery.

- Out of scope / non-goals:
  - **A TTL, age-based reset, or any timestamp field in the persisted state schema.** Rationale is
    recorded in Proposed Fix, "TTL decision". Not deferred ambiguously: it is excluded from this
    feature and recorded as a candidate follow-up.
  - Relocating batch-budget state outside the repository (for example to the OS user-state
    directory). That would remove the need for a destination ignore entry, but it changes the
    state-file contract referenced by the deny message, the Pester suites, and the Codex sibling
    hooks, and the epic's leading indicator is satisfied directly by an ignore entry.
  - The Codex runtime surface: `.codex/hooks/**` and
    `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/**`. The epic
    scopes this work to "only the `.claude/**` runtime surface, its bundle mirror, and the push-down
    code that publishes it".
  - `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts`. It is the shared
    engine used by the Copilot and Codex entry points; a Claude-specific destination write there
    would leak into both. It also has 52 lines of headroom against the 500-line cap in
    `.claude/rules/general-code-change.md` (448 lines as measured), so it could not absorb the
    capability even if the boundary argument did not already exclude it.
  - Adding the delivered destination `.gitignore` to the `PushDownSummary.files` list or otherwise
    changing the summary-artifact schema.
  - **Amending `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` to exclude
    `.claude/state/**` from its parity enumeration.** That change is open issue #510,
    `claude-resource-parity-enumerates-gitignored-state`. It is tracked separately and is not this
    feature's work. The behaviour is real and reproducible: `list_scoped_files` (lines 34-43)
    enumerates with `rglob("*")` against the filesystem rather than the git index and applies no
    ignore filter, so the git-ignored, untracked `.claude/state/python-batch-budget.default.json` is
    enumerated as a repository runtime file. Running the suite in this worktree gives
    `1 failed, 9 passed`, failing with
    `Repo file missing from bundle: .claude\state\python-batch-budget.default.json`. Fixing #510
    would not help this feature: this feature makes the batch-budget state file session-scoped and
    worktree-scoped, and does not stop the file being written, so the local parity failure persists
    after this feature ships exactly as it does before. The exclusion is therefore not a prerequisite
    for any behaviour this feature delivers. CI is unaffected, because a CI checkout is fresh and
    does not run the batch-budget PreToolUse hooks, so `.claude/state/` does not exist there.

- Explicitly excluded systems, integrations, or datasets (per the epic's Feature A/C/D boundaries):
  - `.claude/lib/blast-radius/**` and the blast-radius calling-convention work (Feature A).
  - `.claude/skills/parallel-*/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, and
    `.claude/agents/parallel-planner.md` (Features C and D).
  - The PowerShell/bash port of `scripts/dev_tools/parallel_lane_assertion.py` (Feature D).
  - Any change to TaskMaster-repository code.

## Root Cause Analysis
The `'default'` fallback was chosen so the hook has a usable path when the session id is absent,
but it makes the absent-id case collapse to one shared identity instead of separating sessions. The
push-down pipeline was designed to copy a payload, and the destination-side ignore obligation was
never part of that payload contract.

Cross-cutting constraint for any fix:
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
asserts every repository `.claude/**` file — excluding `settings.local.json` and the
`.claude/agent-memory/**` subtree — is byte-identical to its copy under
`extensions/drm-copilot/resources/claude-customizations/.claude/**`. Every `.claude/**` edit must be
mirrored into the bundle copy in the same change.


## Proposed Fix

### Design summary (what changes where):

Three decisions are settled here rather than deferred to the plan.

**1. Session identity — align both hooks with the documented `identify-session-id` chain, and make
its second source actually populated.**

The repository already owns a complete session-id mechanism, and the batch-budget hooks do not use
it. Verified in this worktree:

- `.claude/hooks/persist-session-id.ps1` is a SessionStart hook, registered in
  `.claude/settings.json:84` as `pwsh -NoProfile -File .claude/hooks/persist-session-id.ps1`. It
  reads `session_id` from the hook payload (lines 55-56) and persists it by **either** appending
  `CLAUDE_SESSION_ID=<id>` to `$env:CLAUDE_ENV_FILE` **or**, when that variable is unset, writing the
  bare id to `.claude/state/current-session-id` (path composed at line 150, written through the
  `WriteStateFile` seam at line 110). The two branches are mutually exclusive:
  `Get-PersistSessionIdDecision` returns `'env-file'` **or** `'state-file'`, never both (lines 63-67).
- `.claude/skills/identify-session-id/SKILL.md` documents the canonical resolution order:
  (1) `$env:CLAUDE_SESSION_ID`, (2) `.claude/state/current-session-id`, (3) newest-mtime transcript
  stem.
- Both batch-budget hooks consume source 1 only and then fall back to the literal `'default'`
  (PowerShell hook lines 248-251; Python hook lines 245-248). Neither consults source 2.

Consuming source 2 in the hooks is necessary but not sufficient. Observed in this worktree:
`$env:CLAUDE_SESSION_ID` is unset from the hook process's view **and**
`.claude/state/current-session-id` does not exist (a glob of `.claude/state/**` returns exactly one
file, the python budget state). That combination is explained by the mutually exclusive branches
above: when `CLAUDE_ENV_FILE` is set, `persist-session-id.ps1` takes the env-file branch and never
writes the state file, and the env-file channel exports into subsequent **Bash tool** commands (the
hook's own documentation, lines 12-15), whereas a PreToolUse command hook is spawned directly by
Claude Code and is not a Bash tool command. So in exactly the sessions where the batch-budget hooks
need source 2, source 2 is empty.

The fix therefore has two parts:

- `persist-session-id.ps1` writes `.claude/state/current-session-id` **unconditionally** whenever a
  `session_id` is present, and additionally appends to `$env:CLAUDE_ENV_FILE` when that variable is
  set. The env-file channel is preserved unchanged for its existing Bash-tool consumers; the state
  file becomes a reliable second source for every consumer that is not a Bash tool command.
- Both batch-budget hooks resolve the session id in this order, first non-empty value winning:
  1. `$env:CLAUDE_SESSION_ID` (trimmed).
  2. The trimmed contents of `<Root>/.claude/state/current-session-id`, read through a new injected
     scriptblock seam so the Pester suites remain filesystem-free.
  3. A worktree-derived identifier composed from the resolved root, of the form
     `worktree-<sanitized-leaf-name>-<short stable hash of the normalized root path>`.
  The resolved value is sanitized with `-replace '[^A-Za-z0-9._-]', '_'` before path composition,
  matching the Codex sibling hook. The literal `'default'` is removed from both files, including the
  `Invoke-*BatchBudgetHook` parameter default, which becomes an empty default that routes into the
  same resolution helper.

Alternatives considered and rejected:

- **Codex-parity fail-closed (`-RequireSessionId`).** The Codex hook
  (`.codex/hooks/enforce-powershell-batch-budget.ps1`, lines 223-227) requires `session_id` from its
  transport and throws when it is absent, because the Codex PreToolUse transport contract guarantees
  the field. The Claude side has no such guarantee: whether a Claude Code PreToolUse envelope carries
  `session_id` is **unknown** — no `.claude/**` file reads it and no fixture under
  `tests/scripts/claude-hooks/` constructs one containing it. If the answer is no, fail-closed
  converts both hooks into an unconditional denial of every PowerShell and Python `Write`/`Edit`.
  Rejected on blast radius. It remains available as a later tightening once the carriage question is
  settled empirically.
- **Reading `session_id` from the PreToolUse envelope as a source 0.** The plumbing exists
  (`Get-ClaudeHookEnvelopeValue` is already exported from `HookPayload.psm1`), but the carriage is
  unverified, and the source is not part of the documented `identify-session-id` chain. Adding it
  would create a fourth source that the skill document does not describe. Not adopted here.
- **Implementing source 3 (newest-mtime transcript).** Rejected for a PreToolUse hook: it requires a
  directory scan of `~/.claude/projects/<encoded-workspace>/` on every `Write` and `Edit`, and its
  documented failure mode — picking the wrong sibling when concurrent sessions share one workspace —
  reintroduces the cross-session collision this feature exists to remove.

Residual unresolved case, stated explicitly as required: if the SessionStart hook did not run, or its
payload carried no `session_id`, sources 1 and 2 are both empty and the worktree-derived identifier
(source 3 above) is used. Its semantics are: **distinct per worktree, shared by concurrent sessions
within the same worktree.** This is accepted rather than eliminated. Justification: it strictly
improves on the current machine-global `default` counter by bounding collisions to one worktree; it
never denies work in a session that has an id; and the alternatives are either fail-closed (rejected
above) or fail-open, which silently removes the control the hooks exist to provide.

**2. Destination-side ignore delivery — a post-copy merge into the destination-root `.gitignore`,
using a sentinel-delimited managed block.**

A new pure module, `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`, exports a
merge function with no I/O. `pushDownCustomizations`
(`extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, currently `return
enginePushDown({...})` at line 304) captures the engine summary, then reads
`<destinationRoot>/.gitignore` through the injected `fs`, computes the merged text, writes it back
through the same `fs` **only when the merged text differs from the current text**, and returns the
unmodified summary.

The rejected alternative is a payload file `.claude/.gitignore` shipped through the existing copy
loop. The decisive objection from the research was re-verified here:
`ExcludingFileSystem.isPackIncluded` (`claude-filesystem-adapter.ts:179-189`) returns `false` for any
enumerated path whose source-relative spelling is absent from `publishedPaths` whenever a pack
selection is active. A `.claude/.gitignore` omitted from a pack manifest is therefore silently
dropped from every `--packs` push-down, and the guard that would normally catch that omission does
not cover the path: `claude-pack-manifest-completeness.test.ts` enumerates `agents/*.md`,
`hooks/*.ps1`, `skills/*/SKILL.md`, `rules/*.md`, a recursive `lib/**` walk, and a bundle-root
`config/**` walk — none of which matches a file sitting directly at `.claude/.gitignore`. The failure
would be silent in CI. Two further objections: a payload file is a plain overwrite, which is the
behaviour this repository already rejected for `config/orchestration-routing.json`
(`claude-routing-merge.ts:14-31` exists precisely because overwriting a destination's locally
extended file "would silently discard them"); and a nested `.gitignore` under `.claude/` cannot
express any pattern outside that directory, while this repository's own `.gitignore` already carries
two runtime-state entries in different roots (`.claude/state/` at line 68 and `.codex/state/` at
line 69).

**Idempotency across repeat push-downs is a required, testable property**, achieved as follows. The
managed entries are written between two sentinel comment lines. The merge function locates the block
by its opening and closing sentinels and **replaces it in place**; it appends a block only when no
opening sentinel is present. It never appends a second block and never appends bare entries outside a
block, so repeated runs cannot accumulate lines. Content outside the block is preserved byte-for-byte
including its ordering. When a managed entry also appears outside the block (hand-added by the
consumer), the block still carries the full managed entry set: suppression would make the output
depend on unmanaged content and would produce two different fixed points, whereas a duplicate ignore
pattern is semantically inert to git. **What the second run must observe:** the destination
`.gitignore` is byte-identical to its state after the first run; each sentinel line occurs exactly
once; and the destination path does not appear in the fake filesystem's `writtenPaths` for the second
publish, because the merged text equals the current text and the write is skipped.

**3. Worktree scoping — normalize, then ordinal prefix comparison; out-of-root paths are
discarded.**

- `$Root` on `Invoke-*BatchBudgetHook` changes its default from `(Get-Location).Path` to a
  `$PSScriptRoot`-derived two-level ascent, `Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`,
  matching the Codex hook. A worktree contains its own `.claude/hooks/` directory, so `$PSScriptRoot`
  is already worktree-local. Because it is a parameter default, every existing test that passes
  `-Root '/repo'` explicitly is unaffected.
- Containment rule: normalize both the candidate path and the root with `-replace '\\', '/'`,
  `TrimEnd('/')` the root, and compare with
  `StartsWith($root + '/', [System.StringComparison]::OrdinalIgnoreCase)`. Case-insensitive because
  Windows drive letters and directory names are case-insensitive.
- `Resolve-Path` is **not** used. It throws on a path that does not exist, and every `Write` target a
  PreToolUse hook sees is by definition a path that may not exist yet.
  `[System.IO.Path]::GetFullPath` is also not used: it would resolve a relative candidate against the
  hook process's current directory, which is an incidental property of the `-File` invocation rather
  than a guaranteed one.
- A relative candidate path is treated as worktree-relative and admitted. An absolute candidate is
  admitted only when it passes the containment test.
- **An out-of-root path is discarded**, not ignored and not denied. Concretely: the decision is
  `allow`, the path is not appended to `prodFiles`/`testFiles`, no slot is consumed, and
  `shouldWriteState` is `$false`. Budget semantics: the cap governs how much of *this worktree's*
  source a batch changes. Denying is the wrong scope — `enforce-evidence-locations.ps1` is the hook
  that polices where writes land — and denying would block legitimate scratchpad writes, which is
  precisely the case visible in the live artifact. Recording-but-excluding would require a second
  list or a state-schema flag for no additional actionable signal.
- **Rehydrate-time filter.** `ConvertTo-*BatchBudgetState` additionally drops persisted
  `prodFiles`/`testFiles` entries that fail the containment test, so a state file already poisoned by
  an out-of-root entry (the live artifact is one) stops charging that entry against the cap on the
  next run. This is the cheap remedy for already-persisted damage and is the reason a TTL is not
  needed for that purpose.

Known limitation, recorded rather than fixed: a path expressed in Windows 8.3 short-name form (the
live artifact records `C:/Users/DANMOI~1/...`) will not prefix-match a long-form root and would be
classified as out-of-root. The consequence is under-counting, never a false denial. Resolving short
names requires filesystem access to a path that may not exist, which is the same objection that
excludes `Resolve-Path`.

**TTL decision: out of scope.** Recorded here and in Non-Goals with the reason. The persisted state
shape is exactly `{prodCap, testCap, prodFiles, testFiles}` with no timestamp material of any kind
(verified against `Get-PowerShellBatchBudgetState`, lines 53-58, and the live artifact). A TTL
therefore requires a schema addition, an extension to `ConvertTo-*BatchBudgetState` (lines 61-82,
which copies only the four known keys and silently drops anything else), and an injected clock seam
to satisfy the determinism requirements in `.claude/rules/general-unit-test.md`. With per-session
identity plus the rehydrate-time containment filter, the unbounded-inheritance failure this feature
targets is removed at its source rather than time-bounded, and a TTL would not address the remaining
case (two concurrent sessions in one worktree with no resolvable id) at all. Recorded as a candidate
follow-up, not as deferred scope.

### Boundaries and invariants to preserve:

- The deny-envelope shape pinned for both hooks by
  `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (lines 77 and 89).
- Exit code 0 on every path, including denials. A Claude PreToolUse hook must never `throw`: a
  non-zero exit is non-blocking for PreToolUse and is therefore itself a fail-open.
- The deny-only emission convention: an allow decision writes nothing to stdout.
- The `-SessionId` / `-Root` / four-scriptblock parameter surface of `Invoke-*BatchBudgetHook`, so the
  existing Pester suites keep exercising the same seams. New behaviour is added through additional
  optional seams, not by replacing existing ones.
- The existing `CLAUDE_ENV_FILE` channel of `persist-session-id.ps1`, and its exit-0-always contract.
- Byte-identical bundle mirrors for every edited `.claude/**` file.
- The push-down enumeration-order contract (`.claude` before `config`) and the summary-artifact
  schema, both of which existing tests pin.
- The I/O boundary of `copilot-customizations-engine.ts`: it is not modified.

### Dependencies or blocked work:

- None. Feature B is wave 0 with an empty `depends_on` and does not share a file with Feature A.
- One item that is **not** a blocker but must not be misread as settled: whether a Claude Code
  PreToolUse envelope carries `session_id` is unknown. The chosen design does not depend on the
  answer. If a later change wants the Codex fail-closed posture, that question must be resolved
  first.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production `.claude/**` (each requires a byte-identical mirror under
`extensions/drm-copilot/resources/claude-customizations/`):

1. `.claude/hooks/enforce-powershell-batch-budget.ps1` (+ mirror)
2. `.claude/hooks/enforce-python-batch-budget.ps1` (+ mirror)
3. `.claude/hooks/persist-session-id.ps1` (+ mirror)

TypeScript (no bundle mirror; `src/**` is not part of the payload):

4. `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` (new)
5. `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (post-copy call site)
6. `extensions/drm-copilot/jest.config.cjs` (per-file coverage-threshold entry for item 4)

Tests:

7. `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`
8. `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`
9. `tests/scripts/claude-hooks/persist-session-id.Tests.ps1`
10. `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` (new)
11. `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` or a new sibling suite,
    for end-to-end delivery and second-push byte stability

**Change-budget interaction, stated because it will bind.** Items 1-3 plus their three mirrors are
six `.ps1` files, none of which matches the hook's test-file predicate
(`(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$`), so all six count against the 3-file production cap in
`.claude/rules/powershell.md:40`. Items 7-9 are three test `.ps1` files, exactly at the 3-file test
cap. The hook being repaired is the hook that enforces this. The plan must handle it explicitly by
splitting the production edits across batches (deleting the state file between them), or by setting
`CLAUDE_POWERSHELL_BUDGET_PROD` with approved scope before the session starts, or by writing an
elevated `prodCap` into the state file. This is a sequencing obligation for the plan, not a design
change.

#### Functions/classes/CLI commands impacted:

- `Invoke-PowerShellBatchBudgetHook` / `Invoke-PythonBatchBudgetHook`: `$SessionId` default, `$Root`
  default, one new seam for reading the session-id state file, containment applied before recording.
- `Invoke-PowerShellBatchBudgetDecision` / `Invoke-PythonBatchBudgetDecision`: accepts the resolved
  root and discards out-of-root candidates.
- `ConvertTo-PowerShellBatchBudgetState` / `ConvertTo-PythonBatchBudgetState`: rehydrate-time
  containment filter.
- `Invoke-PowerShellBatchBudgetEntryPoint` / `Invoke-PythonBatchBudgetEntryPoint`: the `'default'`
  assignment is replaced by the resolution chain.
- `Get-PersistSessionIdDecision` / `Invoke-PersistSessionIdHook`: the decision gains a combined
  action so the state file is written in every branch that has a `session_id`.
- `pushDownCustomizations` (`claude-customizations.ts`): captures the engine summary and performs the
  post-copy merge.
- New exported pure function in `claude-gitignore-merge.ts`, exported separately from its call site in
  the same way `mergeRoutingDocuments` is exported at `claude-routing-merge.ts:191`.

#### Data flow and validation changes:

- Hook: payload `file_path` -> separator normalization -> extension classification -> **containment
  test against the resolved worktree root** -> test/production classification -> dedupe -> cap check
  -> record. The containment test is inserted ahead of classification so a discarded path never
  reaches the cap arithmetic.
- Hook: session id -> environment -> state file -> worktree-derived fallback -> sanitization -> state
  path composition.
- Push-down: engine copy completes -> read destination `.gitignore` (absent is a valid input) ->
  compute merged text -> compare with current text -> write only on difference.

#### Error handling and logging updates:

- Reading `.claude/state/current-session-id` is wrapped so an unreadable or absent file falls through
  to the next source rather than throwing, consistent with the existing `Write-Verbose` handling of
  an unreadable state file (PowerShell hook lines 200-202).
- A discarded out-of-root path emits a `Write-Verbose` line naming the path and the resolved root. No
  new stdout output: the hooks remain deny-only.
- The push-down merge treats a missing destination `.gitignore` as an empty input, not an error. A
  read failure for an existing file propagates rather than being swallowed, matching the fail-fast
  posture in `.claude/rules/general-code-change.md`.
- The destination is **not** probed for a `.git` directory. `validateDestination` only guarantees an
  existing directory that is not the source root; writing a `.gitignore` into a non-repository
  directory is inert, and probing would add an I/O dependency and a new failure mode for no benefit.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. Every change is a behaviour correction in a hook or an additive destination write;
rollback is a revert of the commit. The push-down merge is additive at the destination: reverting the
extension does not remove an already-delivered managed block, which is acceptable because the block's
content (ignoring runtime state) is correct independently of the extension version.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- State file name: `<language>-batch-budget.<sanitized-session-id>.json` under `<Root>/.claude/state`.
  The sanitized component matches `^[A-Za-z0-9._-]+$` by construction.
- Persisted state document: unchanged — `{prodCap, testCap, prodFiles, testFiles}`, serialized with
  `ConvertTo-Json -Depth 5`. No new keys.
- `.claude/state/current-session-id`: unchanged format — the bare id, UTF-8, no trailing newline
  (written with `-NoNewline`). Only the condition under which it is written changes.
- Destination `.gitignore`: UTF-8 text, LF line endings. Managed entries appear between a fixed
  opening sentinel comment line and a fixed closing sentinel comment line. The initial managed entry
  set is `.claude/state/` and `.codex/state/`.

#### Required configuration keys and defaults:

- `CLAUDE_SESSION_ID` (environment, optional) — unchanged meaning; now the first of three sources
  rather than the only one.
- `CLAUDE_ENV_FILE` (environment, optional) — unchanged meaning; it no longer suppresses the
  state-file write.
- `CLAUDE_POWERSHELL_BUDGET_PROD` / `_TEST`, `CLAUDE_PYTHON_BUDGET_PROD` / `_TEST` — unchanged.
- `jest.config.cjs` `coverageThreshold` gains one entry for the new module at `lines: 85,
  branches: 75`. The map has no `global` key, so a new production file without an entry is ungated.

#### Backward-compatibility expectations:

- A pre-existing `<language>-batch-budget.default.json` is not migrated and not read under the new
  identity scheme. It becomes an orphaned file inside a git-ignored directory. This is intentional:
  it is the poisoned artifact the feature exists to stop producing.
- The `-SessionId` and `-Root` parameters keep their names and positions, so existing Pester
  invocations continue to work.
- A destination repository that already carries a hand-added `.claude/state/` line keeps that line;
  the managed block is added alongside it.
- **A destination `.gitignore` with CRLF line endings will be rewritten wholly to LF on the first
  push-down.** This is a property of `RealPushDownFileSystem.writeTextFile`
  (`filesystem-adapter.ts:188-194`), which normalizes CRLF and CR to LF, not of the merge logic. It
  produces a whole-file diff in the consumer repository on first delivery. Called out because a
  consumer will notice it. Subsequent push-downs are byte-stable.

#### Performance constraints (latency/throughput/memory):

Both hooks run on every `Write` and `Edit`, so the added cost per invocation must stay bounded: at
most one additional small file read (`.claude/state/current-session-id`), performed only when
`$env:CLAUDE_SESSION_ID` is empty, and string comparisons that are linear in the number of recorded
paths (bounded by the caps, which are 3 and 3 by default). No directory scans, no process launches,
no network. The push-down merge adds one read and at most one write of a small text file per
push-down invocation. No specific latency budget is asserted; none was measured.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - PowerShell 7+ is available at the destination; both hooks are invoked as
    `pwsh -NoProfile -File .claude/hooks/<name>.ps1` from the workspace root.
  - `$PSScriptRoot` for a hook resolves inside the worktree that owns the hook, so a two-level ascent
    yields that worktree's root. This holds because a worktree carries its own `.claude/hooks/`
    directory.
  - The SessionStart hook runs before any `Write` or `Edit` in a session. Where it does not, the
    worktree-derived fallback applies; that case is specified rather than assumed away.
  - Whether a Claude Code PreToolUse envelope carries `session_id` is **unknown**. The design does not
    depend on it.
  - `quality-tiers.yml` does not exist at the repository root; a repository-wide glob for
    `**/quality-tiers.y*ml` returns no files. No tier classification is available for these modules.
    The uniform thresholds apply regardless of tier, so no acceptance criterion depends on reading
    that file.

- Constraints (budget, performance, compatibility):
  - Per-batch change budget: 3 production and 3 test PowerShell files
    (`.claude/rules/powershell.md:40`). Six production `.ps1` files are in scope; see the
    change-budget note under Files/modules to change.
  - 500-line file cap (`.claude/rules/general-code-change.md`). Current sizes measured in this
    worktree: `copilot-customizations-engine.ts` 448 lines (52 of headroom, which is why the new
    capability is a separate module), `claude-routing-merge.ts` 311,
    `claude-filesystem-adapter.ts` 303, `push-down-service-call.ts` 201,
    `enforce-powershell-batch-budget.ps1` 284, `enforce-python-batch-budget.ps1` 281. Both hooks have
    ample headroom, so extraction of shared logic into a new `.claude/lib/**` module is **not**
    required by the cap, and is not adopted: it would add two more production files plus a pack
    manifest entry against an already-binding change budget.
  - Line coverage >= 85% for both languages; branch coverage >= 75% for TypeScript only, since Pester
    does not measure branch coverage. PowerShell files remain in the coverage denominator.
  - Toolchain commands must be runnable under the executing agent's tool allowlist. `npm run ...` is
    not available to `atomic-executor` or `typescript-engineer`; both have `npx` only.

- External dependencies (services, libraries, releases):
  - None. No new runtime dependency in the extension and no new PowerShell module.

## Data / API / Config Impact

- User-facing or API changes:
  - A push-down now writes or updates `<destination>/.gitignore`. This is a new destination-side
    effect of the push-down command and is the only user-visible behaviour change outside the hooks.
  - Deny messages continue to name the state file path; that path now contains a resolved session
    identifier instead of `default`.

- Data or migration considerations:
  - No schema change to the persisted state document. Existing `*.default.json` files are orphaned
    rather than migrated (see Backward-compatibility expectations).
  - `.claude/state/current-session-id` is written in sessions where it previously was not. It is
    inside a git-ignored directory in this repository and in any destination that received the
    managed ignore block.

- Logging/telemetry updates (if any):
  - `Write-Verbose` diagnostics only: session-source selection and discarded out-of-root paths. No
    change to stdout, which remains deny-only.

- Compatibility notes (CLI flags, config schemas, versioning):
  - No CLI flag changes. `--packs` push-downs are explicitly covered by the design, since the
    post-copy merge runs outside the pack-filtered enumeration and is therefore unaffected by
    `ExcludingFileSystem.isPackIncluded`.
  - The `PushDownSummary` schema is unchanged. The delivered `.gitignore` is deliberately not added
    to its `files` list, because that list is keyed on source-relative payload paths and the merged
    file has none. Consequence, recorded as a known limitation: a delivered file goes unreported in
    the summary artifact.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: session-id resolution and state-path composition in both hooks; recorded-path canonicalization and worktree-root containment; the new destination-side ignore writer in the push-down engine, including its idempotency on repeat push-downs.
- [ ] Integration scenario to retest: a push-down into a scratch destination, run twice, asserting the destination ignore configuration is present and unchanged by the second run.
- [ ] Manual verification notes: confirm the bundle mirror stays byte-identical by running the push-down resource-contract test named above.

- Regression tests to add or update:
  - `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` and
    `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`: session-source precedence
    (environment beats state file; state file used when the environment is empty; worktree-derived
    identifier when both are empty), sanitization of a hostile id, state-path composition asserted
    through the existing `WriteState` seam, containment admission and discard, and the rehydrate-time
    filter.
  - `tests/scripts/claude-hooks/persist-session-id.Tests.ps1`: the state file is written in the
    `CLAUDE_ENV_FILE`-set branch as well as the unset branch, and the env-file append is unchanged.
  - `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`: run unchanged as a regression
    guard on the deny envelope for both hooks.
  - `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` (new): the pure merge
    function with no filesystem — absent input, present without a block, present with an identical
    block, present with a stale block, entry present outside the block, input with no trailing
    newline, input with CRLF endings.
  - End-to-end delivery and second-push byte stability through `InMemoryPushDownFileSystem`, in
    `claude-config-carriage.test.ts` or a new sibling suite. The byte-stability assertion follows the
    existing template at `claude-config-carriage.test.ts:241-263`.

- Unit tests (pytest) for the fixed behavior and boundaries:
  - This feature adds no pytest test and changes no pytest file.
    `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is run unchanged as the mirror
    gate.

- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Session id containing path separators or other characters outside `[A-Za-z0-9._-]`.
  - `.claude/state/current-session-id` present but empty or whitespace-only: falls through to the
    worktree-derived identifier.
  - `.claude/state/current-session-id` unreadable: falls through without throwing.
  - Candidate path that is relative, absolute-in-root, absolute-out-of-root, and absolute-in-root with
    differing letter case.
  - Persisted state already containing an out-of-root entry, using the test-defined synthetic fixture
    constant `C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.py` as the fixture value.
  - Destination `.gitignore` absent, empty, without a trailing newline, with CRLF endings, and
    containing a `!`-negation of a managed entry outside the block (which git resolves by last match;
    the writer must not reorder the destination's file).
  - Cap boundary preserved: the fourth distinct in-root production file is still denied.

- Error handling and logging verification:
  - Both hooks exit 0 on every path, including the deny path, and emit nothing on stdout when the
    decision is allow.
  - The deny reason text still names the state file path.
  - A discarded out-of-root path produces a `Write-Verbose` record and no stdout output.

- Coverage impact and targets for changed lines/modules:
  - Line coverage >= 85% for the three changed hooks (Pester; no branch gate).
  - Line coverage >= 85% and branch coverage >= 75% for the new TypeScript module, enforced by a new
    per-file entry in the `coverageThreshold` map of `extensions/drm-copilot/jest.config.cjs`. The map
    has no `global` key, so without that entry the new file is ungated.
  - No coverage regression on changed lines in either language.
  - Baseline coverage for the affected hooks and push-down modules is captured **before** any edit and
    written to
    `docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/baseline/`. The
    current coverage posture for the two hooks is unknown; no report for them was located in the tree.

- Toolchain commands to run (format → lint → type-check → test):
  - PowerShell: `mcp__drm-copilot__run_poshqc_format`, then `mcp__drm-copilot__run_poshqc_analyze`,
    then `mcp__drm-copilot__run_poshqc_test` (type checking is not applicable). Do not substitute VS
    Code task wrappers.
  - TypeScript tests and coverage: `npx jest --coverage`, run from `extensions/drm-copilot`. This is
    the form recorded as working in prior feature QA-gate evidence. `npm run test:unit:coverage` is
    documented in `.claude/rules/typescript.md` but is **not** invocable by `atomic-executor` or
    `typescript-engineer`, whose allowlists carry `npx` and not `npm`.
  - TypeScript format, lint, and type-check must likewise be invoked in an `npx` form. The exact
    spellings are **not verified in this document**; the plan must confirm them against the executing
    agent's allowlist before relying on them, rather than copying the `npm run` spellings from the
    rule file.
  - Python: the resource-contract test is run by node id, for example
    `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`.
    The runner spelling must match the executing agent's allowlist.
  - Restart the loop from formatting if any stage fails or modifies files.

- Manual validation steps (if required):
  - A real push-down into an external consumer repository is **not** fully automatable: it requires a
    packaged and installed `.vsix`, a VS Code session with that workspace open, and manual inspection
    of the resulting `.gitignore` and `git status`. It is not an acceptance criterion for that reason.
    The automatable substitute — driving `pushDownClaudeCustomizationsServiceCall` against
    `InMemoryPushDownFileSystem` and asserting the destination content and its byte stability — covers
    the whole code path from the service-call entry point down, and the adapter it substitutes has its
    own direct unit tests in `filesystem-adapter.test.ts`.
  - Note for anyone attempting the manual check: a repository-side `resources/` edit does not change
    what a push-down writes until the extension is rebuilt and reinstalled, so a naive run can
    validate stale bytes.


## Acceptance Criteria

Each criterion names the artifact that proves it. Where a criterion is verified by a search that is
expected to return no matches, the same search must be shown to return a non-zero result **before**
the change, so it is demonstrated capable of failing.

Defect 1 — shared session identity (both hooks and the sibling Python hook):

- [x] `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` contains three passing
      tests that assert the composed state-file name for (a) `$env:CLAUDE_SESSION_ID` set, (b) the
      environment variable empty and `.claude/state/current-session-id` supplying the id through the
      new read seam, and (c) both sources empty, yielding the worktree-derived identifier. The three
      composed names are asserted to be pairwise different.
- [x] `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` contains the same three
      passing tests for `enforce-python-batch-budget.ps1`.
- [x] A case-sensitive search for the literal `'default'` across
      `.claude/hooks/enforce-powershell-batch-budget.ps1`,
      `.claude/hooks/enforce-python-batch-budget.ps1`, and their two bundle mirrors under
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` returns no matching
      lines. The same search returns matches in all four files before the change (2 per file: the
      parameter default and the entry-point assignment).
- [x] Each hook suite contains a passing test asserting that a session id containing characters
      outside `[A-Za-z0-9._-]` produces a state-file name matching
      `^(powershell|python)-batch-budget\.[A-Za-z0-9._-]+\.json$`.
- [x] `tests/scripts/claude-hooks/persist-session-id.Tests.ps1` contains a passing test asserting the
      `WriteStateFile` seam is invoked with the session id when `CLAUDE_ENV_FILE` **is** set, and a
      passing test asserting the `AppendLine` seam is still invoked in that same case. Both suites'
      pre-existing tests remain green.

Defect 2 — never-resetting inheritance of a poisoned counter:

- [x] Each hook suite contains a passing test in which the persisted state's `prodFiles` already
      contains an out-of-root absolute path, and three distinct in-root production files are still
      admitted without a deny — proving the rehydrate-time containment filter drops the poisoned
      entry from the cap arithmetic. The out-of-root path is the fixed synthetic constant
      `C:/synthetic-out-of-root/scratchpad/out_of_root_fixture.py`, defined by the test itself. It is
      a test fixture, not an observed path: it is stated literally in the suite so the test carries
      no dependence on transient local state such as an orchestrator scratchpad directory.

Defect 3 — unscoped recorded paths:

- [x] Each hook suite contains passing tests asserting that (a) a relative path is recorded, (b) an
      absolute path under the resolved root is recorded, (c) an absolute path outside the resolved
      root yields `permissionDecision = 'allow'` with `shouldWriteState` false and an unchanged
      recorded-file list, and (d) an in-root absolute path differing only in letter case is recorded.
- [x] A search for `(Get-Location).Path` across `.claude/hooks/enforce-powershell-batch-budget.ps1`,
      `.claude/hooks/enforce-python-batch-budget.ps1`, and their two bundle mirrors returns no
      matching lines; the same search returns one match per file before the change. Neither hook
      introduces `Resolve-Path` or `[System.IO.Path]::GetFullPath`.

Defect 4 — destination-side ignore delivery:

- [x] `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` exists, exports a merge
      function that performs no I/O, and its suite
      `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` passes under
      `npx jest` with cases for: absent input, present without a managed block, present with an
      identical block, present with a stale block, a managed entry already present outside the block
      (no duplicate block emitted), input without a trailing newline, and CRLF input.
- [x] A passing Jest test drives the push-down against `InMemoryPushDownFileSystem` and asserts that
      `<destination>/.gitignore` contains `.claude/state/` between the two sentinel lines, on both an
      unscoped publish and a pack-scoped publish (`packs: ["core"]`).
- [x] **Idempotency.** A passing Jest test publishes, reads `<destination>/.gitignore`, publishes
      again, reads again, and asserts (a) the two reads are byte-identical, (b) each sentinel line
      occurs exactly once in the final content, and (c) the destination `.gitignore` path is absent
      from the fake filesystem's recorded writes for the second publish.
- [x] A passing Jest test seeds a destination `.gitignore` containing unrelated entries and asserts
      every one of those lines is present and in its original relative order after the publish.
- [x] `extensions/drm-copilot/jest.config.cjs` contains a `coverageThreshold` entry for
      `./src/lib/push-down/claude-gitignore-merge.ts` with `lines: 85` and `branches: 75`, and
      `npx jest --coverage` run from `extensions/drm-copilot` passes with that entry present.

Cross-cutting gates:

- [x] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      passes when no `.claude/state/` directory is present — the state a fresh checkout and CI are
      in — with every edited `.claude/**` file byte-identically mirrored under
      `extensions/drm-copilot/resources/claude-customizations/.claude/**`. A working tree in which
      the batch-budget hooks have already run will instead show the open issue #510 failure on
      `.claude/state/**`; that failure is unrelated to this feature and is recorded in Non-Goals.
- [x] Mirror parity is additionally proven by an environment-independent hash comparison that does
      not depend on `.claude/state/` and therefore holds in any tree state: for each of the three
      file pairs below, `git hash-object` reports the same object id for the repository file and its
      bundle mirror. (a) `.claude/hooks/enforce-powershell-batch-budget.ps1` and
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`;
      (b) `.claude/hooks/enforce-python-batch-budget.ps1` and
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`;
      (c) `.claude/hooks/persist-session-id.ps1` and
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/persist-session-id.ps1`.
      The pairs are enumerated explicitly so a third party re-running the check obtains the same set
      rather than selecting its own evidence. The check fails on a genuine mirroring miss and cannot
      pass vacuously, because each named pair must yield a hash and the two hashes must match.
- [x] `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` passes with no change to its
      assertions, confirming the deny-envelope shape for both batch-budget hooks is unaltered.
- [ ] `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and
      `mcp__drm-copilot__run_poshqc_test` all pass in a single consecutive run with no file
      modifications, and the Pester line coverage for
      `.claude/hooks/enforce-powershell-batch-budget.ps1`,
      `.claude/hooks/enforce-python-batch-budget.ps1`, and `.claude/hooks/persist-session-id.ps1` is
      >= 85% for each file, compared against the pre-change baseline stored under
      `docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/baseline/`.

## Risks & Mitigations

- Technical or operational risks:
  - The change budget binds: six production `.ps1` files against a 3-file per-batch cap, enforced by
    the very hook being repaired. An unplanned run will be denied partway through.
  - The worktree-derived fallback still shares one counter between two concurrent sessions in the same
    worktree. This is an accepted residual, not a fixed defect.
  - Windows 8.3 short-name paths inside the worktree are classified as out-of-root and therefore
    under-counted.
  - A destination `.gitignore` with CRLF endings is rewritten wholly to LF on first delivery,
    producing a large diff in the consumer repository.
  - A destination `!`-negation of a managed entry placed after the managed block still wins under
    git's last-match-wins semantics. The writer does not reorder the destination's file.
  - The merged `.gitignore` is delivered but not reported in the push-down summary artifact.
  - Whether a Claude Code PreToolUse envelope carries `session_id` remains unknown, so a future
    tightening to a fail-closed posture is not yet decidable.

- Mitigations and rollbacks:
  - The plan sequences the production `.ps1` edits across batches, or sets
    `CLAUDE_POWERSHELL_BUDGET_PROD` with approved scope, before implementation starts.
  - The concurrent-same-worktree residual, the 8.3 limitation, the CRLF normalization, the negation
    behaviour, and the summary omission are each documented in this spec so they are visible to
    reviewers and to consumers rather than discovered in the field.
  - Rollback is a plain revert. An already-delivered managed ignore block remains at the destination
    after a revert, which is harmless: its content is correct independently of the extension version.

## Rollout & Follow-up

- Release/rollout steps:
  - Merge delivers the hook fixes to this repository immediately. The destination-side ignore
    delivery reaches consumers only after the extension is rebuilt, repackaged, and reinstalled; a
    repository-side `resources/` edit alone does not change what an installed extension writes.

- Post-fix monitoring or clean-up tasks:
  - Delete any orphaned `.claude/state/*-batch-budget.default.json` files after merge. They are inside
    a git-ignored directory and are no longer read.
  - Candidate follow-ups, each deliberately excluded from this feature: a TTL or age-based reset for
    batch-budget state; relocating batch-budget state outside the repository entirely; resolving
    empirically whether a Claude PreToolUse envelope carries `session_id`, which is the precondition
    for adopting the Codex fail-closed posture; and adding the delivered `.gitignore` to the push-down
    summary artifact.

- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/596
  - Epic: `docs/features/epics/claude-runtime-portability/epic.md` (Feature B, wave 0, C3)
  - Research: `docs/features/active/2026-08-29-batch-budget-state-portability-596/research/2026-08-29T15-07-batch-budget-state-portability-research.md`
  - Session-id chain: `.claude/skills/identify-session-id/SKILL.md`
