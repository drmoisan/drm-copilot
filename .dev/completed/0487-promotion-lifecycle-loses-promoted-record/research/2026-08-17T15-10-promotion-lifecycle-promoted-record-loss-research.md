# Promotion Lifecycle Loses the Promoted Record — Research (Issue #487)

- Timestamp: 2026-08-17T15-10
- Feature: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487`
- Issue: #487
- Work mode: `full-bug`
- Requirements source: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/issue.md`
- Mode: read-only investigation. No implementation file was modified. The missing promoted record was
  not recreated.

## Summary

The loss is real, reproducible, and fully explained by code that was read directly.

`mcp__drm-copilot__new_active_feature_folder` removes the promoted lifecycle record. It does so by
design: `createActiveFolder` discovers a seeding source by scanning `docs/features/potential/` and
then `docs/features/potential/promoted/`, and then **moves** the winning file into the new active
folder as `issue.md`. After `potential_to_issue` has run, the only copy of the record lives in
`promoted/`, so the fallback scan selects the archive copy and the move consumes it.

The mechanism is confirmed by four independent lines of evidence:

1. The discovery fallback into `promoted/` at `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts:104-107`.
2. The unconditional `filesystem.move(potentialFile, potentialIssuePath)` at
   `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts:346` (full path) and `:283`
   (minor-audit path).
3. The `new_active_feature_folder` receipt from this run, whose `artifacts` entry is
   `.../active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/issue.md` — the field that
   `new-active-feature-folder-service-call.ts:130-132` populates only when a potential file was
   moved.
4. Content identity: the `issue.md` now in the active folder is the promoted record verbatim
   (potential-entry H1, `Status: Promoted -> ...`, the `Automation note` line, and the four prior
   observation sections), with `- Work Mode: full-bug` upserted. It is not a rendering of the bug
   template.

`potential_to_issue` behaved correctly in this run and is **not** the removing operation. Its move is
a single `fs.renameSync` (`promotion-filesystem.ts:87-90`), not a delete-plus-write, so the
"write leg fails silently" hypothesis recorded in the issue is disproved by code reading, not merely
unobserved.

A separate, real defect remains in both tools: neither receipt verifies that the path it reports as
`destination_path` exists at the moment the receipt is emitted. `ok: true` is set unconditionally
whenever no exception was thrown (`extensions/drm-copilot/src/mcp-tools.ts:88-108`).

The defect is a contract collision between two documented behaviors, not an undocumented bug:

- `docs/engineering/Feature Playbook.md:14` documents `new_active_feature_folder` as it behaves
  today: "move the promoted potential into the active folder as `issue.md`".
- `docs/research/2026-07-09-potential-entries-duplicate-audit.md:15,28` records the opposite
  convention: files moved into `promoted/` "stay there permanently as the historical record of
  promotion; no code path deletes or relocates them afterward."

That audit's negative claim is factually wrong. Its grep was scoped to
`extensions/drm-copilot/src/lib/potential-to-issue/` only, so it never examined the
`new-active-feature-folder` cluster, which does relocate them. Issue #487's Expected Behavior
resolves the conflict in favor of retention; the Feature Playbook line and
`docs/features/potential/README.md:6` become stale under the fix.

## Probe Evidence (Probe A / Probe B)

This orchestration run's own promotion exercised the code path under investigation and reproduced the
loss with clean two-sided bracketing. The transcript below is reproduced verbatim from the
instrumented run. The corresponding evidence artifact is
`docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/promotion-lifecycle-probe.2026-08-17T15-02.md`.

### Step T0 — pre-promotion baseline

Timestamp: 2026-08-17T19:00:52.893347300Z
Command: `stat -c '%n | %s bytes | %y' <source>` ; `stat -c '%n | %y' docs/features/potential/promoted` ; `ls -1 docs/features/potential/promoted | wc -l` ; `test -f <destination>`
EXIT_CODE: 0

```
docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md | 8261 bytes | 2026-08-17 15:00:41.426902700 -0400
docs/features/potential/promoted | 2026-08-17 14:58:21.071779900 -0400
promoted dir entry count: 26
target present? ABSENT
```

Output Summary: Source present at 8261 bytes. Destination absent. Promoted directory holds 26
entries.

### Step T1 — `mcp__drm-copilot__potential_to_issue`

Timestamp: 2026-08-17T19:01:04Z (destination mtime)
Command: `mcp__drm-copilot__potential_to_issue` with `potential_path=docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md`, `promotion_type=bug`, `work_mode=full-bug`
EXIT_CODE: 0

```
{"ok":true,"tool":"potential_to_issue","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-abfc86b76ed919bd8","summary":"Promoted 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-abfc86b76ed919bd8/docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md' as a bug workflow in full-bug mode.","artifacts":["https://github.com/drmoisan/drm-copilot/issues/487"],"destination_path":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-abfc86b76ed919bd8/docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md"}
```

Output Summary: Promotion reported `ok: true`, issue #487 created, `destination_path` reported.

### Step T2 — PROBE A (immediately after `potential_to_issue`)

Timestamp: 2026-08-17T19:01:22Z
Command: `ls -la --time-style=full-iso <destination>` ; `ls -la --time-style=full-iso <source>` ; `stat -c '%n | %y' docs/features/potential/promoted`
EXIT_CODE: 0 for destination and directory probes; 2 for the source probe (expected absence)

```
-rw-r--r-- 1 DanMoisan 197121 8446 2026-08-17 15:01:04.704909100 -0400 docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md
ls: cannot access 'docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md': No such file or directory
docs/features/potential/promoted | 2026-08-17 15:01:04.704909100 -0400
promoted dir entry count: 27
```

Output Summary: Probe A outcome — destination PRESENT at 8446 bytes; pre-promotion source correctly
ABSENT. The move succeeded.

### Step T3 — PROBE A-prime (after branch creation, before `new_active_feature_folder`)

Timestamp: 2026-08-17T19:01:40Z (approximate; between T2 and T4)
Command: `git checkout -b bug/promotion-lifecycle-loses-promoted-record-487 origin/main` then `ls -la --time-style=full-iso <destination>`
EXIT_CODE: 0

```
-rw-r--r-- 1 DanMoisan 197121 8446 2026-08-17 15:01:04.704909100 -0400 docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md
```

Output Summary: Still PRESENT, unchanged size and mtime. No file removal occurred at this step.

### Step T4 — `mcp__drm-copilot__new_active_feature_folder`

Timestamp: 2026-08-17T19:01:50Z (folder mtime)
Command: `mcp__drm-copilot__new_active_feature_folder` with `feature_name=2026-08-17-promotion-lifecycle-loses-promoted-record`, `type=bug`, `work_mode=full-bug`, `issue_number=487`
EXIT_CODE: 0

```
{"ok":true,"tool":"new_active_feature_folder","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-abfc86b76ed919bd8","summary":"Created a new active bug feature folder for '2026-08-17-promotion-lifecycle-loses-promoted-record'.","artifacts":["C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-abfc86b76ed919bd8/docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/issue.md"],"destination_path":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-abfc86b76ed919bd8/docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487"}
```

Output Summary: Active feature folder created and reported `ok: true`.

### Step T5 — PROBE B (immediately after `new_active_feature_folder`)

Timestamp: 2026-08-17T19:02:00Z
Command: `ls -la --time-style=full-iso <destination>` ; `ls -la --time-style=full-iso <source>` ; `stat -c '%n | %y' docs/features/potential/promoted docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487 docs/features/potential`
EXIT_CODE: 2 for both file probes (absence); 0 for the directory probes

```
ls: cannot access 'docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md': No such file or directory
ls: cannot access 'docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md': No such file or directory
docs/features/potential/promoted | 2026-08-17 15:01:50.613026300 -0400
docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487 | 2026-08-17 15:01:50.613026300 -0400
docs/features/potential | 2026-08-17 15:01:04.704909100 -0400
promoted dir entry count: 26
```

Output Summary: Probe B outcome — destination ABSENT, source ABSENT, promoted dir entry count
returned from 27 to 26. `docs/features/potential/promoted` and the newly created active feature
folder carry the IDENTICAL mtime to the nanosecond (`2026-08-17 15:01:50.613026300 -0400`), while
`docs/features/potential` retained its earlier `potential_to_issue` mtime.

### Step T6 — `git status` control

Timestamp: 2026-08-17T19:02:10Z
Command: `git status --short`
EXIT_CODE: 0

```
?? docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/
```

Output Summary: No deletion entry appears, because the promoted record was created and deleted within
one session and was never committed.

### Verdict

The loss REPRODUCED, and the removing operation is `new_active_feature_folder`, not
`potential_to_issue`. No hand repair of the record was performed (deliberately, so the defect stays
visible).

### Corroboration added by this research (not part of the probe)

The nanosecond-identical mtime pair is now explained rather than merely observed. A single
`fs.renameSync(promotedRecord, activeFolder/issue.md)` updates the mtime of both the source directory
(`docs/features/potential/promoted`) and the destination directory (the new active folder) in the same
syscall, and leaves `docs/features/potential` untouched. That is exactly the pattern Probe B recorded.

The moved file is present and inspectable: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/issue.md`
is the promoted record's content verbatim. The active folder contains exactly three files —
`issue.md`, `plan.2026-08-17T15-01.md`, `spec.md` — which is the bug-template set (`spec.md`,
timestamped plan) plus the moved record. The promoted record is therefore not "missing"; it was
consumed and renamed.

## Dispatch Chain

Two parallel implementations exist. The TypeScript implementation is the one that runs. The Python
implementation is a maintained parity source with its own CLI, not dead code, and is not invoked by
the MCP surface.

### `new_active_feature_folder` (live path)

| Step | File | Lines |
| --- | --- | --- |
| MCP tool dispatch | `extensions/drm-copilot/src/mcp-tools.ts` | 201-205 (`case "new_active_feature_folder"`) |
| Handler | `extensions/drm-copilot/src/mcp-handlers/feature-entry-handlers.ts` | 36-42 |
| Service method | `extensions/drm-copilot/src/repo-automation-service.ts` | 248-262 |
| Service-call helper | `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts` | 105-134 |
| Workflow | `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` | 90-390 (`createActiveFolder`) |
| Discovery | `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` | 98-130 (`findPotentialFile`) |
| Filesystem | `extensions/drm-copilot/src/lib/new-active-feature-folder/models.ts` | 281-290 (`RealFolderFileSystem.move`) |
| Receipt shaping | `extensions/drm-copilot/src/mcp-tools.ts` | 88-108 (`toMcpToolResult`) |

`repo-automation-service.ts:256` calls `newActiveFeatureFolderServiceCall` directly. There is no
Python spawn on this path; the header of `new-active-feature-folder-service-call.ts:30-35` records
that the prior Python-spawn path was replaced in-process.

### `potential_to_issue` (live path)

| Step | File | Lines |
| --- | --- | --- |
| MCP tool dispatch | `extensions/drm-copilot/src/mcp-tools.ts` | 197-199 |
| Handler | `extensions/drm-copilot/src/mcp-handlers/feature-entry-handlers.ts` | 28-34 |
| Service method | `extensions/drm-copilot/src/repo-automation-service.ts` | 229-247 (comment at 236-238 records the in-process TS port) |
| Service-call helper | `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` | 149-192 |
| Workflow | `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` | 291-443 (`promotePotential`); the terminal move is 433-440 |
| Filesystem | `extensions/drm-copilot/src/lib/potential-to-issue/promotion-filesystem.ts` | 87-90 (`RealPotentialFileSystem.move`) |

### Status of the Python implementation

`scripts/dev_tools/new_active_feature_folder_flow.py` and `scripts/dev_tools/potential_to_issue.py`
are byte-parity sources for the TypeScript ports (declared in the TS module headers, e.g.
`flow.ts:4-14`). They retain their own `parse_args`/`main` CLI entry points and their own pytest
suites, so they are live for direct CLI use but are **not** reached from the MCP surface. A
repository grep for `new_active_feature_folder.py` / `potential_to_issue.py` found no production
invocation outside test harnesses and documentation; the only runtime references are the
`new-active-feature-folder-fs-harness.ts:187-194` and `extension.potential-to-issue.test.ts:207`
assertions that verify **no** Python spawn occurs.

No bundled copy of these Python modules exists under `extensions/drm-copilot/resources/` on this
branch (glob for `extensions/drm-copilot/resources/**/new_active_feature_folder*.py` returned no
files), so the historical bundled mirror is no longer a synchronization target. There is exactly one
TypeScript copy of `createActiveFolder`.

## Root Cause Analysis

### The removing operation

`createActiveFolder` performs the removal in two places, one per work-mode branch. Both are
unconditional moves of the discovered potential file into `<targetDir>/issue.md`:

- Minor-audit branch — `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts:280-289`:
  `potentialIssuePath = joinPosix(targetDir, "issue.md"); filesystem.move(potentialFile, potentialIssuePath);`
  then a read-back and a `writeText` that upserts `- Work Mode: minor-audit`.
- Full branch — `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts:344-353`: the same
  two calls, with the marker set to `selectedWorkMode` (`full-bug` in this run), followed by
  `emit("Moved potential file to " + potentialIssuePath)`.

This run took the full branch (`work_mode=full-bug`, so `shouldUseMinorAuditMode` returns
`[false, ""]` at `docs.ts:349-352`).

`RealFolderFileSystem.move` (`models.ts:281-290`) is `mkdirSync(parent, {recursive:true})`, then an
`unlinkSync` of a pre-existing destination file, then `renameSync(src, dest)`. A rename out of
`docs/features/potential/promoted/` is precisely the single operation that stamps both directories
with the same mtime.

### Why the promoted record is the file that gets moved

`findPotentialFile` (`extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts:98-130`) scans
two directories in order:

```
docs/features/potential
docs/features/potential/promoted
```

It returns the name-descending winner from the **first** directory that yields any candidate. In the
canonical lifecycle documented in `.claude/skills/feature-promotion-lifecycle/SKILL.md`,
`potential_to_issue` runs first and moves the source out of `docs/features/potential/`. By the time
`new_active_feature_folder` runs, the first directory has no match and the second — the archive —
does. The archive copy is therefore always the seeding source in the standard flow, and the move
always consumes it.

This fallback is deliberate and tested:
`extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts:43-53` —
"falls back to the promoted directory when potential has no match". The defect is not the fallback
itself (removing it would break seeding entirely); the defect is that the file selected from the
archive is **moved** rather than **copied**.

The Python source is identical in both respects: `scripts/dev_tools/new_active_feature_folder_io.py:35-55`
(`find_potential_file`, same two-directory order) and
`scripts/dev_tools/new_active_feature_folder_flow.py:203-212` and `:260-272` (the two
`filesystem.move(potential_file, potential_issue_path)` sites).

### Why `potential_to_issue` is not the cause

`promotePotential` ends at `promotion.ts:433-440` with `ensureDir(promotedDir)`,
`destPath = posixJoin(promotedDir, basename)`, `filesystem.move(resolved, destPath)`. The production
implementation of that `move` is `promotion-filesystem.ts:87-90`:

```ts
move(src: string, dest: string): void {
  fs.mkdirSync(nodePath.dirname(dest), { recursive: true });
  fs.renameSync(src, dest);
}
```

This is a single atomic rename within one volume. It is not a delete-plus-write, so there is no
"write leg" that can fail silently while the delete succeeds. If `renameSync` throws, the exception
propagates out of `promotePotential` and out of `potentialToIssueServiceCall`, and
`mcp-tools.ts:110-123` converts it to `ok: false`. There is no code path in which the source is
removed, the destination is absent, and `ok: true` is still reported by this tool.

Probe A independently confirms the write succeeded in this run (destination present at 8446 bytes,
which is the 8261-byte source plus the injected issue-metadata lines written at `promotion.ts:415-428`
before the move).

The correct characterization of `potential_to_issue`, therefore, is a **robustness gap, not the
active cause**: its receipt asserts a `destination_path` without confirming it, so if a future
failure mode did produce an absent destination the receipt would still read `ok: true`. That gap is
real and worth closing, but it did not produce the observed loss.

Observations 1 through 3 recorded in `issue.md` cannot be re-attributed with confidence, because each
probed only once and after both calls had run. They are consistent with the mechanism established
here, but this research does not claim to have proven their cause.

### Documented-behavior conflict

The removal is documented behavior of `new_active_feature_folder`:

- `docs/engineering/Feature Playbook.md:14` — "create/seed `docs/features/active/<feature>-<issue>/`
  from templates and matching potential/promoted doc; ... move the promoted potential into the active
  folder as `issue.md`".
- `docs/features/potential/README.md:6` — step 2 of the manual lifecycle: "Move the file into
  `docs/features/active/<feature-name>/`".

The retention expectation is documented elsewhere:

- `docs/research/2026-07-09-potential-entries-duplicate-audit.md:15,28` — promoted files "stay there
  permanently as the historical record of promotion; no code path deletes or relocates them
  afterward" and "should be deleted" is explicitly rejected. That negative claim is wrong: its
  supporting grep (line 24) covered only `extensions/drm-copilot/src/lib/potential-to-issue/`, never
  the `new-active-feature-folder` cluster.
- Issue #487 Expected Behavior — the promoted record "continues to exist after
  `new_active_feature_folder` runs".

Issue #487 is the requirements source for this fix, so retention wins and the two documentation lines
above become stale under the fix.

## Receipt Post-condition Gap

### Current behavior

`ok` is set unconditionally. `extensions/drm-copilot/src/mcp-tools.ts:88-108`:

```ts
function toMcpToolResult(result: RepoAutomationExecutionResult): RepoAutomationMcpToolResult {
  return {
    ok: true,
    ...
    ...(result.destinationPath === undefined ? {} : { destination_path: result.destinationPath }),
```

`ok: false` is produced only by `toFailureToolResult` (`mcp-tools.ts:110-123`), which runs only when
the handler threw. Neither tool verifies the path it reports.

- `potential_to_issue`: `potential-to-issue-service-call.ts:183-191` copies
  `normalizeGeneratedPath(outcome.destination)` into `destinationPath` with no existence check.
- `new_active_feature_folder`: `new-active-feature-folder-service-call.ts:124-133` copies
  `normalizeGeneratedPath(result.target)` into `destinationPath` and
  `normalizeGeneratedPath(result.potentialIssuePath)` into `artifacts`, likewise unchecked.

### Where the check belongs

The required post-condition is: **a receipt must not report `ok: true` with a `destination_path`
unless that file or directory is present on disk at the moment the receipt is emitted.**

Recommended placement is the **service-call layer** in each cluster, immediately before the result
record is constructed:

- `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` — hoist the
  filesystem instance currently constructed inline at line 164
  (`input.fileSystem ?? new RealPotentialFileSystem()`) into a local `const`, pass it to
  `promotePotential`, and assert `filesystem.exists(outcome.destination)` before returning at
  lines 183-191. Throw on failure so `toFailureToolResult` produces `ok: false`.
- `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts`
  — hoist the instance constructed inline at line 115
  (`input.fileSystem ?? new RealFolderFileSystem()`), and assert existence of `result.target` and,
  when non-null, `result.potentialIssuePath` before returning at lines 124-133.

Rationale for this layer rather than the workflow layer:

1. It is the layer that constructs the receipt fields, so the assertion is co-located with the claim
   it guards.
2. The workflow modules (`promotion.ts`, `flow.ts`) declare byte-parity with their Python sources in
   their headers. A TypeScript-only assertion there would create a parity divergence that a future
   parity audit would flag. The Python CLI has no receipt and therefore needs no analogue, so the
   service-call layer — which has no Python counterpart by construction — is divergence-free.
3. Both seams are already injectable, so the assertion is unit-testable with the existing
   `Map`-backed fakes and requires no new interface member (`exists` is already on both
   `PotentialFileSystem` and `FolderFileSystem`).

Alternative placement (workflow layer, immediately after each `move`) is viable and would be covered
by both language suites, at the cost of the parity divergence in point 2. The plan should choose one;
this research recommends the service-call layer.

Note that the disposition fix itself (copy vs move) is a workflow change and **must** be mirrored in
Python to preserve parity. Only the receipt assertion is TypeScript-only.

## Candidate Approaches

### Recommended: source-directory-aware disposition

When the resolved potential file lies under `docs/features/potential/promoted/`, **copy** it to
`<targetDir>/issue.md` and leave the archive record in place. When it lies directly under
`docs/features/potential/` (an unpromoted entry activated without a prior `potential_to_issue`),
**move** it as today, so the idea does not remain in the unpromoted queue.

- Applies at both move sites in `flow.ts` (`:283` and `:346`) and both in
  `new_active_feature_folder_flow.py` (`:206` and `:266`).
- Requires no interface change: `FolderFileSystem.copyFile` already exists
  (`models.ts:99`, `RealFolderFileSystem.copyFile` at `models.ts:187-191`), and the Python
  `FileSystem` protocol has `copy_file` (used at `new_active_feature_folder_io.py:104`).
- A containment predicate already exists in `flow.ts`: the private `isRelativeTo` helper at
  `flow.ts:413-420`, currently used only by the auto-resolve guard. It can be reused directly, so the
  change adds a handful of lines rather than a new module.
- The read-back-and-upsert-marker step (`flow.ts:284-288`, `:347-351`) is unaffected: it operates on
  `<targetDir>/issue.md` after placement, so the archive record keeps its original marker and the
  active `issue.md` still receives the selected work mode.
- Existing tests that seed under `docs/features/potential/` (the majority) keep passing unchanged,
  because the move path is preserved for them.

Advantages: minimal blast radius; preserves both documented behaviors in the cases where each is
correct; no change to the `findPotentialFile` contract; the emitted line and the `artifacts` field
remain semantically accurate for the active folder.

Limitations: the emitted line "Moved potential file to `<path>`" becomes inaccurate for the copy case.
The plan must decide between keeping the message (preserving byte-parity with the Python source and
with `flow.test.ts:284`) and introducing a second message such as "Copied potential file to `<path>`"
(more accurate, requires a matching Python change and new assertions in both suites). This research
does not pre-empt that decision; either is defensible, and the accuracy argument is stronger if the
plan is already touching the Python source for parity.

### Rejected alternatives

- **Always copy, never move.** Leaves an unpromoted entry in `docs/features/potential/` after its
  active folder exists, so `findPotentialFile` would keep matching it on subsequent runs and the
  entry would remain in the idea queue indefinitely. Changes behavior for a case that is not
  defective.
- **Move, then write the content back into `promoted/`.** Reaches the same end state as the
  recommendation with an extra write and a window in which neither copy exists. No advantage.
- **Drop the `promoted/` fallback from `findPotentialFile`.** After `potential_to_issue`, the record
  exists only in `promoted/`, so discovery would find nothing and `issue.md` would be generated from
  the template instead of the authored content. That is a strictly worse outcome than the current
  defect, which at least preserves the content.
- **Have `potential_to_issue` leave a copy in `docs/features/potential/`.** Reintroduces the entry
  into the unpromoted queue and would cause `findPotentialFile` to prefer the stale unpromoted copy
  (first directory wins) over the metadata-stamped promoted copy.

## Behavior Semantics

Success conditions after the fix, for the canonical two-call lifecycle:

1. After `potential_to_issue` returns `ok: true`: `docs/features/potential/<name>.md` is absent;
   `docs/features/potential/promoted/<name>.md` is present and contains the issue-metadata lines
   written at `promotion.ts:415-428`; the reported `destination_path` equals that path and exists.
2. After `new_active_feature_folder` returns `ok: true`:
   `docs/features/potential/promoted/<name>.md` is **still** present and byte-identical to its state
   at step 1; `<active-folder>/issue.md` exists and carries the correct `- Work Mode:` marker; the
   reported `destination_path` (the active folder) and every reported `artifacts` path exist.

Failure conditions:

- If the placement of `issue.md` fails, the tool must throw so the receipt reads `ok: false`; it must
  not report a `destination_path` that is absent.
- If the post-condition check finds a reported path absent, the tool must throw with a message naming
  the tool and the absent path.

Ordering rules:

- The existence assertion must run after every filesystem mutation the call performs, and before the
  result record is constructed.
- The disposition decision must be made from the **resolved source path** at the time of placement,
  not from the requested feature name, because `findPotentialFile` may return a file from either
  directory.

Edge cases:

- Unpromoted source (`docs/features/potential/<name>.md`): move preserved; the source is absent
  afterward.
- No potential file found: `potentialIssuePath` stays `null`; the minor-audit branch writes the
  verbatim body (`flow.ts:291-317`) and the full branch relies on `updateFeatureDocs`; no `artifacts`
  entry is emitted. Unaffected by the fix.
- Auto-resolve path (`activeFileForFeatureName`, `flow.ts:115-145`): the supplied path is required to
  be under `promoted/`, so this path always takes the copy branch after the fix.
- `--force` re-run over an existing target: `move` currently unlinks a pre-existing `issue.md`
  (`models.ts:286-288`); `copyFile` overwrites via `copyFileSync`. Behavior is equivalent; no special
  handling needed.
- Cross-volume rename: not applicable — both paths are inside the workspace.

## Requirements Mapping

Issue #487's Expected Behavior maps to three checkable post-conditions and one receipt invariant:

| Requirement (issue.md) | Design element | File |
| --- | --- | --- |
| Promoted record exists after `potential_to_issue` | unchanged (already correct) | `promotion.ts:433-440` |
| Promoted record still exists after `new_active_feature_folder` | copy instead of move when the source is under `promoted/` | `flow.ts:280-289`, `:344-353`; `new_active_feature_folder_flow.py:203-212`, `:260-272` |
| Reported `destination_path` exists at receipt time | existence assertion before result construction | `potential-to-issue-service-call.ts:183-191`; `new-active-feature-folder-service-call.ts:124-133` |
| Receipt must not report success with an absent destination | throw so `toFailureToolResult` yields `ok: false` | `mcp-tools.ts:110-123` (unchanged consumer) |

No state model or checkpoint schema changes are required. No MCP tool signature changes, no new
`artifact_type`, and no orchestrator-state field changes.

## Existing Test Surface

### TypeScript (Jest) — the live implementation

- `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts` — the workflow suite.
  Relevant cases: `:254-286` ("moves the potential file to issue.md, marks the work mode, and emits
  seeding lines"), which seeds under `docs/features/potential/` and asserts
  `fs.files.has(potential) === false` at `:282`; `:290-319` (minor-audit with a potential file);
  `:90-113` ("resolves the feature name from a valid promoted active file"), which seeds under
  `promoted/` but does **not** assert removal.
- `extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts:26-76` — `findPotentialFile`,
  including the promoted fallback case at `:43-53`.
- `extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts`
  — the service-call return contract.
- `extensions/drm-copilot/test/lib/new-active-feature-folder/fakes.ts` — `FakeFolderFileSystem`
  (`Map`-backed), the seam the new cases will use.
- `extensions/drm-copilot/test/lib/new-active-feature-folder/docs.test.ts`, `markdown.test.ts`,
  `models.test.ts` — unaffected.
- `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts` and
  `extension.new-active-feature-folder-inprocess.test.ts` — extension-level, including the
  no-Python-spawn assertion via `new-active-feature-folder-fs-harness.ts:187-194`.
- `extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts`,
  `promotion.matrix.test.ts`, `promotion.missing-label.test.ts`,
  `potential-to-issue-service-call.test.ts`, `content.test.ts`, `gh-client.test.ts`, plus
  `promotion-test-support.ts`.
- `extensions/drm-copilot/test/mcp-server.test.ts`, `mcp-tools.workspace-root.test.ts` — receipt
  shaping.

### Python (pytest) — the parity source

- `tests/scripts/dev_tools/test_new_active_feature_folder.py` — `:284-338`
  (`test_create_feature_folder_moves_potential_and_updates_files`) seeds the source under
  `docs/features/potential/promoted/` at `:290-297` and asserts
  `assert potential_path not in fs.files` at `:333`. **This assertion codifies the defect and must be
  inverted by the fix.**
- `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py:234-284`
  (`test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file`) — seeds under
  `promoted/` at `:241-248` and asserts `assert active_file not in fs.files` at `:284`. **Also
  codifies the defect and must be inverted.**
- `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py`, `_part3.py`,
  `_bug_template_preserved.py`, `_markdown_escape.py`, `_models_coverage.py` — all seed under
  `docs/features/potential/` (unpromoted) and remain valid unchanged.
- `tests/scripts/dev_tools/test_potential_to_issue.py`, `_branches.py`, `_content.py`,
  `_missing_label_regression.py` — the promotion suite; `test_potential_to_issue.py:228-234` already
  asserts the promoted destination content.

No dedicated integration test exercises the two tools in sequence. That gap is why the defect
survived six observations.

### Coverage and tier policy

- Line coverage must remain >= 85%; branch coverage >= 75% for TypeScript and Python
  (`.claude/rules/general-unit-test.md`). PowerShell and bash are exempt from the branch threshold
  only; no PowerShell or bash file is in scope for this fix.
- No production file may be excluded from coverage measurement.
- Test files must mirror the production tree; all files identified above already comply, so the new
  cases extend existing files rather than creating new locations.
- **Tier classification is unavailable.** `quality-tiers.yml` does not exist at the repository root
  (verified in this research by a recursive glob for `**/quality-tiers.y*ml`, which returned only
  policy Markdown, no YAML). This is a known, previously recorded repository condition — see
  `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/quality-tiers-observed.2026-08-07T18-08.md`
  and the tracked entry `docs/features/potential/promoted/2026-07-09-quality-tiers-yml-missing-at-repo-root.md`.
  Consequently no T1/T2 classification applies to the touched modules, and the tier-dependent gates
  (property-test density, mutation score) have no classification source. The uniform gates (format,
  lint, type, coverage thresholds) apply unchanged. Creating `quality-tiers.yml` is out of scope for
  this fix.

## Testing Implications

Proposed strategy, consistent with `.claude/rules/general-unit-test.md` (no test code written here):

1. **TypeScript workflow, promoted source retained (full mode).** Seed a potential file under
   `docs/features/potential/promoted/` in `FakeFolderFileSystem`, run `createActiveFolder` with
   `workMode: "full-bug"`, and assert both that `<target>/issue.md` exists with the correct marker
   **and** that the promoted path is still present with unchanged content. Add to
   `flow.test.ts`.
2. **TypeScript workflow, promoted source retained (minor-audit mode).** Same, with
   `workMode: "minor-audit"`, covering the second move site at `flow.ts:283`.
3. **TypeScript workflow, unpromoted source still moved.** Assert the existing behavior explicitly so
   the move path stays covered — the existing case at `flow.test.ts:254-286` already does this and
   should be left intact.
4. **TypeScript workflow, auto-resolve path.** Extend `flow.test.ts:90-113` with a retention
   assertion, since that path always reads from `promoted/`.
5. **Python parity, both branches.** Invert `test_new_active_feature_folder.py:333` and
   `test_new_active_feature_folder_part4.py:284` to assert retention, and add an unpromoted-source
   case to each file so the move branch keeps its coverage.
6. **Receipt post-condition, positive and negative, both tools.** In
   `new-active-feature-folder-service-call.test.ts` and `potential-to-issue-service-call.test.ts`,
   inject a fake filesystem whose `exists` returns `false` for the destination and assert the call
   throws; and assert the normal path still returns the enriched record. These are the tests that
   make the receipt claim falsifiable.
7. **Sequenced lifecycle test (the missing coverage).** A single test that runs
   `promotePotential` and then `createActiveFolder` against one shared in-memory filesystem, and
   asserts the promoted record survives. This is the case whose absence let the defect persist across
   six observations. It requires reconciling the two port-local filesystem seams
   (`PotentialFileSystem` and `FolderFileSystem`) — a single fake can implement both interfaces, since
   neither is a class. Placement: a new file under
   `extensions/drm-copilot/test/lib/` following the mirrored-tree rule.
8. **Determinism.** All cases use the existing `Map`-backed fakes and the injected `nowProvider`
   (`FIXED_INSTANT` in `flow.test.ts`). No temporary files, no wall-clock reads, no `gh` calls — the
   promotion suite already injects a `GhClient` fake.

Prohibited by policy and therefore excluded: temporary files in tests, real `gh` invocation, and any
test that depends on the real `docs/features/` tree.

## Proposed Fix Footprint

### Production files

| # | File | Language | Change | Current lines |
| --- | --- | --- | --- | --- |
| 1 | `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` | TypeScript | Source-directory-aware disposition at both placement sites (`:280-289`, `:344-353`); reuse `isRelativeTo` (`:413-420`) | 445 |
| 2 | `scripts/dev_tools/new_active_feature_folder_flow.py` | Python | Parity mirror of the same change (`:203-212`, `:260-272`) | 373 |
| 3 | `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts` | TypeScript | Hoist the fs instance (`:115`); assert `target` and `potentialIssuePath` exist before the return (`:124-133`) | 134 |
| 4 | `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` | TypeScript | Hoist the fs instance (`:164`); assert `outcome.destination` exists before the return (`:183-191`) | 192 |

File-size constraint: `flow.ts` is 445 lines against the 500-line limit
(`.claude/rules/general-code-change.md`). A compact disposition helper fits; a larger addition would
require extracting into `io.ts` (397 lines) instead. `potential_to_issue.py` at 639 lines already
exceeds the limit — a pre-existing, separately tracked condition
(`docs/features/potential/promoted/2026-07-24-potential-to-issue-python-files-oversized.md`) that this
fix does not touch and must not worsen.

### Test files

| # | File | Change |
| --- | --- | --- |
| 5 | `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts` | Add promoted-retention cases (full and minor-audit); extend the auto-resolve case |
| 6 | `tests/scripts/dev_tools/test_new_active_feature_folder.py` | Invert `:333`; add an unpromoted-source move case |
| 7 | `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py` | Invert `:284` |
| 8 | `extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` | Post-condition positive and negative cases |
| 9 | `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` | Post-condition positive and negative cases |
| 10 | new file under `extensions/drm-copilot/test/lib/` | Sequenced two-call lifecycle test |

### Documentation files (stale under the fix)

| # | File | Change |
| --- | --- | --- |
| 11 | `docs/engineering/Feature Playbook.md:14` | "move the promoted potential into the active folder" becomes "copy"; state that the promoted record is retained |
| 12 | `docs/features/potential/README.md:6` | Step 2 wording; state retention of the promoted record |
| 13 | `docs/research/2026-07-09-potential-entries-duplicate-audit.md` | Optional correction note: the line-15/28 negative claim was scope-limited and was falsified by issue #487 |
| 14 | `.claude/skills/feature-promotion-lifecycle/SKILL.md` | Optional: add the retained-promoted-record expectation to the post-`new_active_feature_folder` integrity checks (the skill currently does not mention `promoted/` at all) |

### Size assessment

Four production files (three TypeScript, one Python), six test files, and two to four documentation
files. Two languages. No new modules are strictly required, no interface members are added, no
schema or MCP-surface change. This is a small, well-bounded fix whose main risk is the
message-wording parity decision noted under the recommended approach.

## Automation Feasibility

No step of this fix or its verification requires human interaction, and there is no third-party UI
dependency.

- **Implementation** — local file edits in TypeScript and Python only.
- **Verification** — the full seven-stage toolchain runs locally and in CI: Prettier/Black,
  ESLint/Ruff, `tsc`/Pyright, dependency-cruiser, Jest/pytest, and the existing contract checks. Every
  new test uses in-memory fakes; none requires network, `gh`, or the real `docs/features/` tree.
- **End-to-end reconfirmation (optional)** — re-running the two-call lifecycle against a throwaway
  potential entry would create a real GitHub issue. That is scriptable through `gh` with no UI step,
  but it mutates the repository's issue list, so the sequenced unit test (item 7 above) is the
  preferred verification and the live re-run should be treated as optional evidence.
- **No credential prompt, browser step, or manual approval** is on the path. The `gh` CLI is already
  authenticated in this environment, as demonstrated by the successful issue creation at step T1.

Assessment recorded: fully automatable.

## Open Questions

1. **Emitted-message wording.** Should the copy branch keep the existing
   `Moved potential file to <path>` line (preserving byte-parity with the Python source and with
   `flow.test.ts:284`), or emit a distinct `Copied potential file to <path>` line (accurate, but
   requires a matching Python change and new assertions in both suites)? This research recommends the
   distinct line, because the plan is already touching the Python source for parity and an inaccurate
   log line is what made the behavior hard to attribute across six observations. The decision is the
   plan's.
2. **Receipt-assertion layer.** Service-call layer (recommended, parity-divergence-free) versus
   workflow layer (covered by both language suites, but introduces a documented parity divergence).
   Only one should be chosen.
3. **Scope of the receipt assertion.** Should it cover only `destination_path`, or also every entry
   in `artifacts`? For `new_active_feature_folder`, `artifacts` is the moved `issue.md` path and is
   the more load-bearing claim. This research recommends covering both, but the acceptance criteria
   in `issue.md` name only `destination_path` explicitly.
4. **Retroactive repair.** Three promoted records were previously recreated by hand
   (`issue.md`, "Current repository state (2026-08-17)"). The record lost in this run
   (`2026-08-17-promotion-lifecycle-loses-promoted-record.md`) is deliberately still absent as
   evidence. Should the fix's final phase recreate it from
   `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/issue.md`, and if
   so, at what point in the phase order so the evidence is not destroyed before review?
5. **Superseded potential entry.** `docs/features/potential/2026-08-15-potential-to-issue-loses-promoted-record.md`
   is the un-promoted predecessor that issue #487 re-scopes and replaces (per the "Re-scoping note"
   in `issue.md`). It still sits in the unpromoted queue and will be matched by future
   `findPotentialFile` scans for similar names. Should it be moved to `promoted/` or removed as part
   of this fix, or handled separately?
6. **Python CLI retention.** The Python cluster is no longer reached from the MCP surface. Keeping it
   in parity costs a mirrored edit on every workflow change. Whether it should remain a maintained
   parity source is out of scope here, but this fix is a data point for that decision.

## Verification Record for This Research

- Every file path and line number cited above was read directly in this session; no claim rests on
  inference from documentation alone.
- The two claims this research could **not** confirm by reading code are stated as such: the causes of
  observations 1 through 3 in `issue.md` (insufficient bracketing at the time), and the precise
  historical intent behind the `promoted/` fallback in `findPotentialFile` (the fallback is tested and
  therefore deliberate, but no design document explains why it moves rather than copies).
- No implementation, configuration, or documentation file was modified. No git worktree was removed,
  pruned, or otherwise touched.
