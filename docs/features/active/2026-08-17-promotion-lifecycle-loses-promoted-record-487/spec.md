# 2026-08-17-promotion-lifecycle-loses-promoted-record (Spec)

- **Issue:** #487
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-17T15-25
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; `user-story.md` is intentionally absent)

## Context

The promotion lifecycle — `mcp__drm-copilot__potential_to_issue` followed by `mcp__drm-copilot__new_active_feature_folder` — destroys the promoted lifecycle record under `docs/features/potential/promoted/`. After the two-call sequence completes, neither the pre-promotion source at `docs/features/potential/<name>.md` nor the promoted record at `docs/features/potential/promoted/<name>.md` exists, while the `potential_to_issue` receipt still reports the promoted path as its `destination_path`.

The record's content is not lost: it is relocated to `<active-folder>/issue.md`. What is lost is the promotion audit trail — the local marker that records that an idea was promoted, which is the only durable evidence of the transition once the pre-promotion source is consumed. Because the record is created and removed inside a single session and is never committed, its removal produces no `git status` deletion entry, which is why the defect survived six observations before it was bracketed.

Environment:

- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: `mcp__drm-copilot__potential_to_issue` with `promotion_type: bug`, `work_mode: full-bug`, followed by `mcp__drm-copilot__new_active_feature_folder` with `type: bug`, `work_mode: full-bug`
- Data source or fixture (original report): `docs/features/potential/2026-08-15-blast-radius-module-map-forces-serial-runs.md`
- Data source or fixture (this run's controlled reproduction): `docs/features/potential/2026-08-17-promotion-lifecycle-loses-promoted-record.md`

Impact / Severity:

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Local lifecycle-record loss only. Content is recoverable from the active feature folder and from the GitHub issue, so the impact is a broken promotion audit trail rather than data loss. The severity is raised above Low because the `potential_to_issue` receipt asserts that a file exists when, after the second call, it does not — which makes the receipt unusable as evidence.

## Repro & Evidence

The reproduction for this fix is not the narrative inherited from the original report. This orchestration run's own promotion was instrumented as a controlled reproduction with two-sided bracketing. The verbatim transcript is at `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/promotion-lifecycle-probe.2026-08-17T15-02.md`.

Steps to reproduce (the bracketed form; use this, not the single-probe form):

1. Author a potential entry at `docs/features/potential/<name>.md`.
2. Record a T0 baseline: size and mtime of the source, mtime of `docs/features/potential/promoted`, and the entry count of that directory.
3. Call `potential_to_issue` against the entry.
4. **Probe A**, immediately: list the reported `destination_path` and the original source path, and re-stat `docs/features/potential/promoted`.
5. Call `new_active_feature_folder` for the promoted issue.
6. **Probe B**, immediately: list the same two file paths, and stat `docs/features/potential/promoted`, `docs/features/potential`, and the newly created active folder.

Expected:

After step 3 the pre-promotion source is absent and the reported `destination_path` exists. After step 5 the promoted record **still** exists and is byte-identical to its state at Probe A, and `<active-folder>/issue.md` exists carrying the selected work-mode marker.

Actual (Probe A / Probe B, 2026-08-17):

- Probe A: destination **present** at 8446 bytes (the 8261-byte source plus the injected promotion header); pre-promotion source correctly absent; promoted directory grew from 26 to 27 entries. `potential_to_issue` behaved correctly.
- Probe A-prime, after `git checkout -b`: destination still present, size and mtime unchanged. Branch creation is excluded as a cause.
- Probe B: destination **absent**; source absent; promoted directory returned from 27 to 26 entries. `docs/features/potential/promoted` and the new active folder carried the identical mtime to the nanosecond (`2026-08-17 15:01:50.613026300 -0400`), while `docs/features/potential` retained its earlier `potential_to_issue` mtime.
- `git status --short` reported only `?? docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/`. No deletion entry appeared, confirming that `git status` is not a valid probe for this defect.

The nanosecond-identical mtime pair on the source archive directory and the destination active folder is the signature of a single `rename` syscall between them, not of two unrelated operations.

Logs / Screenshots:

- [x] Attached — the full probe transcript is the evidence artifact cited above.
- The `new_active_feature_folder` receipt from that run reports `artifacts: [".../active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/issue.md"]`, which the service-call helper populates only when a potential file was relocated (`new-active-feature-folder-service-call.ts:129-132`).

The removed record was deliberately **not** recreated by hand, so the defect remains observable in this working tree.

## Scope & Non-Goals

### In scope

1. **Source-directory-aware disposition in `new_active_feature_folder`.** When the potential file resolved by `findPotentialFile` lies under `docs/features/potential/promoted/`, copy it into `<targetDir>/issue.md` and leave the archive record in place. When it lies directly under `docs/features/potential/`, keep today's move. Applies to both work-mode branches in `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` (`:283` minor-audit, `:346` full).
2. **Receipt post-condition assertions.** Both `potential_to_issue` and `new_active_feature_folder` must verify, at the service-call layer, that every path they report exists on disk before the result record is constructed.
3. **Python parity mirror.** The disposition change is mirrored into `scripts/dev_tools/new_active_feature_folder_flow.py` (`:206`, `:266`) so the declared byte-parity relationship with the TypeScript port is preserved. The receipt assertion has no Python analogue and is deliberately not mirrored.
4. **Inversion of the two defect-codifying Python tests.** `tests/scripts/dev_tools/test_new_active_feature_folder.py:333` and `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py:284` currently assert that the promoted-seeded source is removed. Both must assert retention instead.
5. **New regression coverage** in the Jest and pytest suites, including the sequenced two-call lifecycle test whose absence allowed the defect to persist.
6. **Documentation correction** of the artifacts that conflict with the fixed behavior (see the required-plan-work list below).

### Out of scope / non-goals

- Any change to the issue-creation path of `potential_to_issue` (`gh` invocation, template selection, label handling, metadata injection).
- Any change to `potential_to_issue`'s move mechanics. Its terminal `fs.renameSync` (`promotion-filesystem.ts:87-90`) is correct and is not modified; only its receipt gains a post-condition assertion.
- Any change to the `findPotentialFile` two-directory scan order or its `promoted/` fallback. The fallback is deliberate and tested (`io.test.ts:43-53`); removing it would degrade seeding to the bare template.
- Hand-repair or backfill of previously lost promoted records, including the record removed during this run. The absence is retained as evidence.
- Creating `quality-tiers.yml`. Its absence is a separately tracked repository condition.
- Reducing the pre-existing over-limit size of `scripts/dev_tools/potential_to_issue.py` (639 lines), which is separately tracked. This fix must not touch or worsen it.
- Any decision about whether the Python cluster should remain a maintained parity source.

### Required plan work outside this agent's write scope

This spec was authored with a write scope limited to `docs/features/active/**`. The following documentation corrections are in scope for the fix but must be performed by the executing agent:

| File | Current text | Required correction |
| --- | --- | --- |
| `docs/engineering/Feature Playbook.md:14` | "...and move the promoted potential into the active folder as `issue.md`" | State that the promoted potential is **copied** into the active folder as `issue.md` and that the promoted record is retained. |
| `docs/features/potential/README.md:6` | "Move the file into `docs/features/active/<feature-name>/`" | State that a promoted file is copied and that the record under `promoted/` is retained. |
| `docs/research/2026-07-09-potential-entries-duplicate-audit.md:15,28` | "no code path deletes or relocates them afterward" | Append a dated correction note: the claim was falsified by issue #487; the supporting grep at line 24 covered only `extensions/drm-copilot/src/lib/potential-to-issue/` and never examined the `new-active-feature-folder` cluster, which did relocate them. Do not rewrite the historical body. |
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` (optional) | No mention of `promoted/` | Optionally add the retained-promoted-record expectation to the post-`new_active_feature_folder` integrity checks. |

## Root Cause Analysis

The narrative inherited from the potential entry — "the move is a delete plus a write whose write leg fails silently" — is **refuted**. So is its attribution of the loss to `potential_to_issue`. Both were superseded first by the fourth observation recorded in `issue.md` and then by direct code reading recorded in `research/2026-08-17T15-10-promotion-lifecycle-promoted-record-loss-research.md`. The record's disappearance is a **deliberate move whose destination is `<active-folder>/issue.md`**, not a failed write.

### Confirmed cause

`new_active_feature_folder` removes the promoted record by design, in three steps.

1. **Discovery selects the archive copy.** `findPotentialFile` (`extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts:98-130`) scans two directories in order — `docs/features/potential` at `:105`, then `docs/features/potential/promoted` at `:106` — and returns the name-descending winner from the **first** directory that yields any candidate (`:111-128`). In the canonical lifecycle, `potential_to_issue` has already moved the source out of `docs/features/potential/`, so the first directory yields nothing and the archive copy is always the discovery winner.

2. **The winner is moved, not copied.** `createActiveFolder` places the discovered file at `<targetDir>/issue.md` with an unconditional `filesystem.move`, once per work-mode branch:
   - minor-audit branch, `flow.ts:282-283`: `potentialIssuePath = joinPosix(targetDir, "issue.md"); filesystem.move(potentialFile, potentialIssuePath);`
   - full branch, `flow.ts:345-346`: the same two calls, followed by the read-back-and-upsert of the work-mode marker at `:347-351` and `emit("Moved potential file to " + potentialIssuePath)` at `:352`.

   The Python parity source contains the identical pair of sites: `scripts/dev_tools/new_active_feature_folder_flow.py:205-206` and `:265-266`.

3. **The move is a rename.** `RealFolderFileSystem.move` (`extensions/drm-copilot/src/lib/new-active-feature-folder/models.ts:281-290`) is `mkdirSync(dirname(dest), {recursive:true})`, then `unlinkSync(dest)` when a destination file already exists, then `renameSync(src, dest)`. A rename out of `docs/features/potential/promoted/` into the new active folder updates the mtime of exactly those two directories in one syscall and leaves `docs/features/potential` untouched — precisely the pattern Probe B recorded.

The defect is therefore not the `promoted/` fallback in discovery; it is that a file selected from the **archive** is consumed rather than duplicated.

### Why `potential_to_issue` is exonerated

`promotePotential` ends at `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts:433-440` with `ensureDir(promotedDir)`, `destPath = posixJoin(promotedDir, basename)`, `filesystem.move(resolved, destPath)`. That `move` is `promotion-filesystem.ts:87-90` — `fs.mkdirSync(dirname(dest), {recursive:true})` followed by a single `fs.renameSync(src, dest)`. A single intra-volume rename has no separable "write leg" that can fail while the delete succeeds; if it throws, the exception propagates out of `potentialToIssueServiceCall` and `mcp-tools.ts:110-123` converts it to `ok: false`. Probe A independently confirms the write succeeded in this run.

Observations 1 through 3 in `issue.md` cannot be re-attributed with confidence, because each probed only once and after both calls had run. They are consistent with the mechanism established here, but this spec does not claim to have proven their cause.

### The separate, narrower defect in both receipts

`toMcpToolResult` (`extensions/drm-copilot/src/mcp-tools.ts:88-108`) sets `ok: true` unconditionally and forwards `destination_path` verbatim from the service-call result. `ok: false` is produced only by `toFailureToolResult` (`:110-123`), which runs only when the handler threw. Neither service-call helper checks the paths it reports:

- `potential-to-issue-service-call.ts:183-191` copies `normalizeGeneratedPath(outcome.destination)` into `destinationPath` with no existence check.
- `new-active-feature-folder-service-call.ts:124-133` copies `normalizeGeneratedPath(result.target)` into `destinationPath` and `normalizeGeneratedPath(result.potentialIssuePath)` into `artifacts`, likewise unchecked.

This is a robustness gap, not the active cause. It did not produce the observed loss, but it is what made the loss look like a `potential_to_issue` failure for five observations: the receipt asserted a path that a later call had removed, and nothing in the receipt could distinguish "never written" from "written and then consumed".

### Documented-behavior collision

The removal is documented behavior, so this is a contract collision rather than an undocumented bug. `docs/engineering/Feature Playbook.md:14` documents the move as intended; `docs/research/2026-07-09-potential-entries-duplicate-audit.md:15,28` asserts the opposite convention — that promoted files "stay there permanently... no code path deletes or relocates them afterward". The audit's negative claim is factually wrong: its supporting grep (line 24) was scoped to `extensions/drm-copilot/src/lib/potential-to-issue/` only and never examined the `new-active-feature-folder` cluster. Issue #487's Expected Behavior is the requirements source for this fix and resolves the collision in favor of retention.

### Dispatch chain (the implementation that actually runs)

| Step | File | Lines |
| --- | --- | --- |
| MCP tool dispatch | `extensions/drm-copilot/src/mcp-tools.ts` | 201-205 |
| Handler | `extensions/drm-copilot/src/mcp-handlers/feature-entry-handlers.ts` | 36-42 |
| Service method | `extensions/drm-copilot/src/repo-automation-service.ts` | 248-262 |
| Service-call helper | `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts` | 105-134 |
| Workflow | `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` | 90-390 |
| Discovery | `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts` | 98-130 |
| Filesystem | `extensions/drm-copilot/src/lib/new-active-feature-folder/models.ts` | 281-290 |
| Receipt shaping | `extensions/drm-copilot/src/mcp-tools.ts` | 88-108 |

There is no Python spawn on this path. The Python cluster under `scripts/dev_tools/new_active_feature_folder*.py` retains its own CLI entry points and pytest suite and is a maintained byte-parity source, not dead code; it is simply not reached from the MCP surface.

## Proposed Fix

### Design summary (what changes where)

Adopt **source-directory-aware disposition**. At each of the two placement sites, decide between copy and move from the *resolved source path*:

- resolved source is under `<workspace>/docs/features/potential/promoted/` → `filesystem.copyFile(potentialFile, potentialIssuePath)`; the archive record is retained unchanged.
- otherwise → `filesystem.move(potentialFile, potentialIssuePath)`, exactly as today; the unpromoted entry leaves the idea queue.

The read-back-and-upsert of the work-mode marker (`flow.ts:284-288`, `:347-351`) is unchanged: it operates on `<targetDir>/issue.md` after placement, so the active `issue.md` still receives the selected work mode and the archive record keeps its original content.

This alternative was evaluated against four others and is adopted for the reasons below.

| Alternative | Disposition |
| --- | --- |
| Always copy, never move | Rejected. Leaves an unpromoted entry in the idea queue permanently, and `findPotentialFile` would keep matching it on later runs. Changes behavior for a case that is not defective. |
| Move, then rewrite the content back into `promoted/` | Rejected. Same end state with an extra write and a window in which no copy exists. |
| Drop the `promoted/` fallback from `findPotentialFile` | Rejected. After `potential_to_issue` the record exists only in `promoted/`, so discovery would find nothing and `issue.md` would be generated from the bare template — strictly worse than the current defect, which at least preserves content. |
| Have `potential_to_issue` leave a copy in `docs/features/potential/` | Rejected. Reintroduces the entry into the unpromoted queue, and `findPotentialFile`'s first-directory-wins rule would then prefer the stale copy over the metadata-stamped promoted copy. |

Separately, add an existence post-condition to both service-call helpers so a receipt cannot claim a path that is not on disk.

### Boundaries and invariants to preserve

- **INV-1 — Discovery contract unchanged.** `findPotentialFile`'s two-directory order, its `_`-to-`-` normalization, its `.md` filter, its exclusion set, and its name-descending tie-break are not modified. The fix reads the returned path; it does not change how the path is chosen.
- **INV-2 — Unpromoted sources still move.** A source directly under `docs/features/potential/` is absent after the call, as today. Every existing test that seeds there keeps passing unchanged.
- **INV-3 — `issue.md` content is unchanged.** The bytes written to `<targetDir>/issue.md` — the seeded content plus the upserted `- Work Mode:` marker — are identical to today's output for the same input, for both work-mode branches.
- **INV-4 — No interface growth.** `FolderFileSystem.copyFile` already exists (`models.ts:99`, implementation at `:187-191`); the Python `FileSystem` protocol already has `copy_file` (used at `new_active_feature_folder_io.py:104`). A containment predicate already exists at `flow.ts:413-420` (`isRelativeTo`). No new interface member, no new module, and no new dependency are required.
- **INV-5 — `flow.ts` must not exceed the 500-line limit.** The file is currently **444 lines** against the 500-line cap in `.claude/rules/general-code-change.md`. A compact disposition helper fits; anything larger must be extracted into `io.ts` (396 lines) rather than appended to `flow.ts`. This is a hard constraint on the implementation, not a preference.
- **INV-6 — Byte parity with the Python source.** The workflow modules declare byte parity with their Python counterparts (`flow.ts:4-14`). Any workflow-layer change must be mirrored in `new_active_feature_folder_flow.py`. Conversely, the receipt assertion must **not** be placed in the workflow layer, because the Python CLI emits no receipt and a workflow-layer assertion would create a parity divergence.
- **INV-7 — MCP surface unchanged.** No tool signature, no new `artifact_type`, no orchestrator-state field, and no checkpoint schema change.
- **INV-8 — No test may create temporary files or invoke `gh`.** All new coverage uses the existing `Map`-backed fakes and the injected `nowProvider`/`GhClient` seams.

### Dependencies or blocked work

None. The fix depends on no unmerged branch, no external service, and no configuration change. The `gh` CLI is authenticated in this environment but is not required by any new test.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

| # | File | Language | Change | Current lines |
| --- | --- | --- | --- | --- |
| 1 | `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` | TypeScript | Source-directory-aware disposition at both placement sites (`:280-289`, `:344-353`); reuse `isRelativeTo` (`:413-420`) | 444 |
| 2 | `scripts/dev_tools/new_active_feature_folder_flow.py` | Python | Byte-parity mirror of the same change (`:203-212`, `:260-272`) | 373 |
| 3 | `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts` | TypeScript | Hoist the filesystem instance constructed inline at `:115`; assert `result.target` and, when non-null, `result.potentialIssuePath` exist before the return at `:124-133` | 134 |
| 4 | `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` | TypeScript | Hoist the filesystem instance constructed inline at `:164`; assert `outcome.destination` exists before the return at `:183-191` | 192 |

#### Functions/classes/CLI commands impacted

- `createActiveFolder` (`flow.ts:90-390`) — both placement branches.
- `create_active_folder` (`new_active_feature_folder_flow.py`) — both placement branches.
- `newActiveFeatureFolderServiceCall` (`new-active-feature-folder-service-call.ts:105-134`).
- `potentialToIssueServiceCall` (`potential-to-issue-service-call.ts`, return at `:183-191`).
- Not impacted: `findPotentialFile`, `promotePotential`, `updateFeatureDocs`, `upsertWorkModeMarker`, `toMcpToolResult`, `toFailureToolResult`, `RealFolderFileSystem.move`, `RealPotentialFileSystem.move`, and both CLI `parse_args`/`main` entry points.

#### Data flow and validation changes

1. `findPotentialFile` returns a resolved absolute POSIX path (unchanged).
2. **New:** the workflow evaluates `isRelativeTo(potentialFile, joinPosix(workspace, "docs/features/potential/promoted"))`.
3. True → `copyFile`; false → `move`.
4. Read back `<targetDir>/issue.md`, upsert the work-mode marker, write (unchanged).
5. **New:** at the service-call layer, assert every reported path exists via the already-present `exists` member of the injected filesystem, then construct the result record.

The disposition decision must be taken from the **resolved source path at the time of placement**, never from the requested feature name, because `findPotentialFile` may legitimately return a file from either directory.

#### Error handling and logging updates

- A failed existence post-condition must `throw` with a message that names the tool and the absent path, so `toFailureToolResult` (`mcp-tools.ts:110-123`) renders `ok: false` and the message reaches the caller as `summary`. Silent degradation, a warning-only path, and a partially populated `ok: true` receipt are all prohibited.
- The emitted seeding line must state the operation actually performed. The move branch keeps `Moved potential file to <path>`; the copy branch emits `Copied potential file to <path>`. Rationale: an inaccurate log line is a contributing cause of the five-observation misattribution, and the Python source is already being edited for parity, so accuracy costs nothing extra. The Python `print` statements at `new_active_feature_folder_flow.py:263` and `:272` must be mirrored. The existing Jest assertion on the moved-file line covers the unpromoted-source case (`flow.test.ts:254-286`, which seeds under `docs/features/potential/`) and is therefore unaffected.
- No new logging channel, telemetry field, or log level is introduced.

#### Rollback/feature-flag considerations (if applicable)

Not applicable. The change is a two-branch disposition rule and two assertions, with no persisted state and no migration. Rollback is a revert of the commit. A feature flag would add a configuration surface for a behavior with no operational risk profile and is explicitly not introduced.

### Technical specifications (interfaces/contracts)

#### Receipt post-condition contract (normative)

> A promotion-lifecycle MCP tool MUST NOT emit a receipt with `ok: true` and a `destination_path` unless that path exists on disk at the moment the receipt is emitted. When a reported path is absent, the tool MUST fail, and the failure `summary` MUST name both the tool and the absent path.

Binding details:

- **Applies to:** `potential_to_issue` and `new_active_feature_folder`.
- **Checked paths:** `destination_path` for both tools; additionally every entry of `artifacts` that is a filesystem path. For `new_active_feature_folder`, `artifacts` carries the placed `issue.md` path and is the more load-bearing claim, so it is included. For `potential_to_issue`, `artifacts` carries a GitHub issue URL, which is not a filesystem path and is therefore excluded from the check. Issue #487 names only `destination_path`; extending the assertion to filesystem-path `artifacts` entries is a deliberate superset and is recorded here so it is not mistaken for scope creep.
- **Check timing:** after every filesystem mutation the call performs, and before the result record is constructed.
- **Check mechanism:** the `exists` member already present on both `PotentialFileSystem` and `FolderFileSystem`, called on the same injected instance the workflow used. The instance must be hoisted into a local `const` rather than constructed twice, so the assertion observes the same filesystem the workflow wrote to — this is what makes the assertion testable with the `Map`-backed fakes.
- **Placement:** the service-call layer of each cluster. Not the workflow layer: `flow.ts` and `promotion.ts` declare byte parity with Python sources that emit no receipt, so a workflow-layer assertion would create a parity divergence that a later parity audit would flag. The service-call layer has no Python counterpart by construction and is therefore divergence-free.
- **Failure mode:** `throw`. The receipt shaping in `mcp-tools.ts` is not modified.

#### Inputs/outputs and formats

- Tool inputs are unchanged for both tools.
- The success receipt shape is unchanged: `ok`, `tool`, `workspace_root`, `summary`, optional `artifacts`, optional `destination_path`.
- The failure receipt shape is unchanged: `ok: false`, `tool`, `workspace_root`, `summary`, optional `stderr_excerpt`.

#### Required configuration keys and defaults

None. No new configuration key, environment variable, or CLI flag is introduced in either language.

#### Backward-compatibility expectations

- **`destination_path` semantics are unchanged and strengthened, never narrowed.** A caller that reads `destination_path` from a successful receipt continues to receive the same value for the same input: the promoted record path for `potential_to_issue`, the active folder path for `new_active_feature_folder`. The only change is that the value is now guaranteed to exist when `ok: true`. A caller that previously handled an absent `destination_path` defensively remains correct; that branch simply becomes unreachable on the success path.
- **Failures that were previously reported as successes now surface as `ok: false`.** This is the intended behavior change. A caller that treats any `ok: true` as terminal success must be prepared for a failure receipt in the case where the destination is absent — a case in which the caller's subsequent filesystem access would have failed regardless.
- **The `artifacts` field is unchanged in shape and content.** For `new_active_feature_folder` it still carries the placed `issue.md` path; the path is now produced by a copy rather than a move in the promoted-source case, which callers cannot observe from the receipt.
- **The Python CLI surface is unchanged.** `new_active_feature_folder_flow.py` keeps its `parse_args`/`main` entry points and its stdout contract, except for the one emitted line that becomes `Copied potential file to <path>` in the copy branch.
- **No MCP tool signature, `artifact_type`, or orchestrator-state field changes**, so no consumer needs to be updated in lockstep.

#### Performance constraints (latency/throughput/memory)

No meaningful constraint. Both tools operate on a single Markdown file of order 10 KB. `copyFileSync` replaces `renameSync` for the promoted-source case, substituting one small file read-write for a directory-entry update; the added cost is below measurement noise on a local filesystem. Each post-condition assertion adds one to two `stat` calls per tool invocation. No performance test or budget is required, and none is added.

## Assumptions, Constraints, Dependencies

- **Assumptions.** The workspace resides on a single volume, so both the retained `move` and the new `copyFile` operate intra-volume. `docs/features/potential/promoted/` is the canonical archive location and is not relocated by this fix. The Python cluster remains a maintained parity source for the duration of this fix; whether it should remain so is a separate decision.
- **Constraints.** `flow.ts` must stay under 500 lines (INV-5). Byte parity between `flow.ts` and `new_active_feature_folder_flow.py` must be preserved (INV-6). No new dependency may be added. `scripts/dev_tools/potential_to_issue.py` is already over the limit at 639 lines as a separately tracked condition and must not be touched or worsened.
- **External dependencies.** None. No network, no `gh` invocation, and no external service is required by the fix or by any new test.

## Data / API / Config Impact

- **User-facing or API changes.** One observable behavior change: the promoted record under `docs/features/potential/promoted/` is retained after `new_active_feature_folder`. One observable receipt change: a reported path that is absent now yields `ok: false` instead of `ok: true`. One observable log change: the copy branch emits `Copied potential file to <path>`.
- **Data or migration considerations.** None. No persisted schema, no checkpoint field, and no stored artifact format changes. Records lost by prior runs are not backfilled (out of scope).
- **Logging/telemetry updates.** The emitted-line wording change described above. No telemetry exists on this path and none is added.
- **Compatibility notes.** No CLI flag, config schema, or version identifier changes in either language. The MCP tool list, tool schemas, and `artifact_type` registry are untouched.

## Test Strategy

Coverage policy: line coverage >= 85% and branch coverage >= 75% for both TypeScript and Python, per `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`. No production file may be excluded from measurement. All test files live in the mirrored test tree; every file below already exists at a compliant location except item 10, which follows the same rule.

**Tier classification:** `quality-tiers.yml` does not exist at the repository root (verified by a recursive glob for `quality-tiers.y*ml`, which returned no files). No T1–T4 classification therefore applies to the touched modules, and the tier-dependent gates — property-test density and mutation score — have no classification source and are not asserted. The uniform gates (format, lint, type, architecture, line and branch coverage, no regression on changed lines) apply unchanged. Creating `quality-tiers.yml` is out of scope.

### Fail-before regression (required)

Item 10 below is the fail-before case. Before the fix it must fail by observing the promoted record absent after `createActiveFolder`; after the fix it must pass by observing the record present and byte-identical. The plan must record the failing run as baseline evidence under `<FEATURE>/evidence/baseline/` before the production change lands, so the test is demonstrated to be capable of failing.

### TypeScript (Jest)

| # | File | Test name (proposed) | Asserts |
| --- | --- | --- | --- |
| 1 | `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts` | `retains the promoted potential file and writes issue.md in full mode` | Seed under `docs/features/potential/promoted/` in `FakeFolderFileSystem`, run `createActiveFolder` with `workMode: "full-bug"`; assert `<target>/issue.md` exists with the `- Work Mode: full-bug` marker **and** the promoted path is still present with unchanged content; assert the emitted line is `Copied potential file to <path>`. |
| 2 | `flow.test.ts` | `retains the promoted potential file in minor-audit mode` | Same, with `workMode: "minor-audit"`, covering the second placement site (`flow.ts:283`). |
| 3 | `flow.test.ts` (existing `:254-286`) | `moves the potential file to issue.md, marks the work mode, and emits seeding lines` | Left intact. It seeds under `docs/features/potential/` and asserts removal at `:282`; that is INV-2 and must keep passing unmodified. |
| 4 | `flow.test.ts` (existing `:90-113`) | `resolves the feature name from a valid promoted active file` | Extend with a retention assertion. This path always reads from `promoted/`, so it always takes the copy branch after the fix. |
| 5 | `extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` | `throws when the reported destination path is absent` / `throws when the reported artifact path is absent` / `returns the enriched record when every reported path exists` | Inject a fake filesystem whose `exists` returns `false` for the reported path; assert the call throws with a message naming the tool and the path. Assert the positive path still returns the enriched record. |
| 6 | `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` | `throws when the promoted destination is absent` / `returns the enriched record when the destination exists` | Same pattern against `outcome.destination`. |
| 7 | `extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts` (existing `:26-76`) | unchanged | Confirms INV-1: the discovery contract, including the promoted fallback at `:43-53`, is not modified. |
| 10 | new file under `extensions/drm-copilot/test/lib/` (for example `promotion-lifecycle-sequence.test.ts`) | `retains the promoted record across potential_to_issue then new_active_feature_folder` | Run `promotePotential` and then `createActiveFolder` against one shared in-memory filesystem implementing both `PotentialFileSystem` and `FolderFileSystem` (neither is a class, so a single fake can satisfy both), with an injected `GhClient` fake. Assert the promoted record is present and byte-identical after both calls, and that `<active>/issue.md` carries the work-mode marker. **This is the coverage whose absence let the defect persist across six observations.** |

### Python (pytest)

| # | File | Test name | Change |
| --- | --- | --- | --- |
| 8 | `tests/scripts/dev_tools/test_new_active_feature_folder.py` | `test_create_feature_folder_moves_potential_and_updates_files` | **Invert** `assert potential_path not in fs.files` at `:333` to assert retention. The source is seeded under `docs/features/potential/promoted/` at `:290-297`, so this assertion currently codifies the defect. Rename the test to reflect retention. |
| 8b | `tests/scripts/dev_tools/test_new_active_feature_folder.py` | `test_create_feature_folder_moves_unpromoted_potential` (new) | Seed under `docs/features/potential/` and assert the source **is** removed, so the move branch keeps its coverage after the inversion (INV-2). |
| 9 | `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py` | `test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file` | **Invert** `assert active_file not in fs.files` at `:284` to assert retention. The source is seeded under `promoted/` at `:241-248`. |
| — | `test_new_active_feature_folder_part2.py`, `_part3.py`, `_bug_template_preserved.py`, `_markdown_escape.py`, `_models_coverage.py` | unchanged | All seed under `docs/features/potential/` (unpromoted) and remain valid without modification. |
| — | `tests/scripts/dev_tools/test_potential_to_issue.py` and siblings | unchanged | `:228-234` already asserts the promoted destination content; `potential_to_issue`'s move mechanics are unmodified. |

### Edge cases and negative scenarios

- **No potential file found.** `potentialIssuePath` stays `null`; the minor-audit branch writes the verbatim body (`flow.ts:291-317`) and the full branch relies on `updateFeatureDocs`. No `artifacts` entry is emitted and the post-condition skips the null path. Unaffected by the fix; assert explicitly.
- **`--force` re-run over an existing target.** `move` unlinks a pre-existing `issue.md` (`models.ts:286-288`); `copyFile` overwrites via `copyFileSync`. Behavior is equivalent; assert the overwrite in the copy branch.
- **Auto-resolve path** (`activeFileForFeatureName`, `flow.ts:115-145`). The supplied path is required to be under `promoted/`, so it always takes the copy branch. Covered by item 4 and item 9.
- **Path-form robustness.** The containment predicate must not be defeated by a mixed-separator or non-normalized path. `isRelativeTo` normalizes via `toPosixPath` and requires either equality or a `<root>/` prefix, so a sibling directory named `promoted-old` does not match. Assert the sibling-directory negative case.
- **Cross-volume rename.** Not applicable; both paths are inside the workspace.

### Error handling and logging verification

- Assert the thrown message names the tool and the absent path for each of the two tools (items 5 and 6).
- Assert the copy branch emits `Copied potential file to <path>` and the move branch emits `Moved potential file to <path>`, in both languages.

### Determinism

All cases use the existing `Map`-backed fakes (`extensions/drm-copilot/test/lib/new-active-feature-folder/fakes.ts`, `FakeFileSystem` in the pytest suites), the injected `nowProvider` (`FIXED_INSTANT` in `flow.test.ts`), a fixed `datetime` in the pytest suites, and the injected `GhClient` fake. No temporary files, no wall-clock reads, no sleeps, no network, and no dependency on the real `docs/features/` tree.

### Coverage impact and targets

- Changed lines in all four production files must be covered. `flow.ts` gains two branch points (copy versus move at each placement site); both arms of both branches must be exercised — items 1, 2, 3, 4 for TypeScript and items 8, 8b, 9 for Python.
- Both service-call helpers gain a failure branch; both arms must be exercised — items 5 and 6.
- Record the post-fix line and branch percentages for both languages under `<FEATURE>/evidence/coverage/`.

### Toolchain commands to run (format → lint → type-check → architecture → test)

TypeScript, from `extensions/drm-copilot/`:

1. `npm run format`
2. `npm run lint`
3. `npm run typecheck`
4. dependency-cruiser against `.dependency-cruiser.cjs`
5. `npm run test:coverage`

Python, from the repository root:

1. `poetry run black .`
2. `poetry run ruff check .`
3. `poetry run pyright`
4. `poetry run pytest --cov --cov-branch --cov-report=term-missing`

Restart from step 1 in the affected language if any stage fails or auto-fixes a file. Do not stop until every stage passes in a single pass.

### Manual validation steps (optional evidence only)

Re-running the two-call lifecycle against a throwaway potential entry would reconfirm the fix end to end, but it creates a real GitHub issue and mutates the repository's issue list. The sequenced unit test (item 10) is the preferred verification; a live re-run is optional supplementary evidence and must not be treated as required.

## Acceptance Criteria

- [ ] **AC-1 — The promoted record survives `new_active_feature_folder` in full mode.** With a potential file seeded under `docs/features/potential/promoted/`, `createActiveFolder` with `workMode: "full-bug"` leaves that path present and byte-identical. Verified by the new `flow.test.ts` case (Test Strategy item 1).
- [ ] **AC-2 — The promoted record survives in minor-audit mode.** The same holds for `workMode: "minor-audit"`, covering the second placement site at `flow.ts:283`. Verified by the new `flow.test.ts` case (item 2).
- [ ] **AC-3 — The active folder's `issue.md` is still produced with identical content.** For the same input, the bytes written to `<targetDir>/issue.md` — seeded content plus the upserted `- Work Mode:` marker — are unchanged from pre-fix output in both work-mode branches. Verified by the content assertions in items 1, 2, and 4, and by the existing unmodified assertions in `flow.test.ts:254-286`.
- [ ] **AC-4 — An unpromoted source is still moved.** A source directly under `docs/features/potential/` is absent after the call. Verified by the unmodified existing case at `flow.test.ts:254-286` (assertion at `:282`) and by the new pytest case (item 8b).
- [ ] **AC-5 — The `new_active_feature_folder` receipt post-condition holds.** `newActiveFeatureFolderServiceCall` throws, naming the tool and the absent path, when `result.target` or a non-null `result.potentialIssuePath` does not exist; the success path still returns the enriched record. Verified by the new cases in `new-active-feature-folder-service-call.test.ts` (item 5).
- [ ] **AC-6 — The `potential_to_issue` receipt post-condition holds.** `potentialToIssueServiceCall` throws, naming the tool and the absent path, when `outcome.destination` does not exist; the success path still returns the enriched record. Verified by the new cases in `potential-to-issue-service-call.test.ts` (item 6).
- [ ] **AC-7 — The sequenced lifecycle regression exists and reproduces the defect before the fix.** A test runs `promotePotential` then `createActiveFolder` against one shared in-memory filesystem and asserts the promoted record survives. Its pre-fix failure is recorded under `<FEATURE>/evidence/baseline/` and its post-fix pass under `<FEATURE>/evidence/qa/`. Verified by the new file under `extensions/drm-copilot/test/lib/` (item 10).
- [ ] **AC-8 — The two defect-codifying Python assertions are inverted.** `tests/scripts/dev_tools/test_new_active_feature_folder.py:333` and `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py:284` assert retention rather than removal, and both tests pass. Verified by `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py tests/scripts/dev_tools/test_new_active_feature_folder_part4.py`.
- [ ] **AC-9 — The Python cluster stays in parity with the TypeScript behavior.** `scripts/dev_tools/new_active_feature_folder_flow.py:206` and `:266` implement the same source-directory-aware disposition and the same emitted-line wording as `flow.ts:283` and `:346`. Verified by inspection of the two files side by side and by the pytest cases in items 8, 8b, and 9. The receipt assertion is deliberately not mirrored, because the Python CLI emits no receipt.
- [ ] **AC-10 — `flow.ts` remains within the 500-line limit.** Verified by a line count of `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` (444 lines before the change).
- [ ] **AC-11 — The full toolchain passes for both languages with coverage recorded.** TypeScript: `npm run format`, `npm run lint`, `npm run typecheck`, dependency-cruiser, and `npm run test:coverage` all pass in a single pass. Python: `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest --cov --cov-branch --cov-report=term-missing` all pass in a single pass. Line coverage >= 85% and branch coverage >= 75% for both languages, with the figures written to `<FEATURE>/evidence/coverage/`.
- [ ] **AC-12 — The conflicting documentation is corrected.** `docs/engineering/Feature Playbook.md:14` and `docs/features/potential/README.md:6` describe retention of the promoted record, and `docs/research/2026-07-09-potential-entries-duplicate-audit.md` carries a dated correction note recording that its line-15/28 claim was falsified by issue #487 and that its supporting grep at line 24 was scoped to the `potential-to-issue` cluster only. Verified by inspection of the three files.

## Risks & Mitigations

- **Risk — Parity divergence between the TypeScript and Python clusters.** The two implementations declare byte parity, but only the TypeScript one is reached from MCP, so a Python-side omission produces no observable runtime failure and can persist undetected. The emitted-line wording change widens the surface on which the two can drift.
  - *Mitigation:* Treat the Python mirror as part of the same change, not a follow-up. AC-9 requires side-by-side inspection of both placement sites and both emitted lines. The pytest cases in items 8, 8b, and 9 exercise both arms of the new branch, so a missing Python mirror fails the suite rather than passing silently.

- **Risk — A copy leaves a stale promoted record if the active folder is later deleted.** After the fix, the promoted record and `<active-folder>/issue.md` are two copies of the same content. If the active folder is later removed — an abandoned fix, a discarded worktree, a manual cleanup — the promoted record remains and marks a promotion whose work no longer exists. A later `findPotentialFile` scan for a similar name will still match it and reseed from it.
  - *Mitigation:* This is the intended trade-off and matches the retention convention that issue #487 selects. The promoted record is an archive marker, not a work item; a marker that outlives its work is the expected cost of an audit trail, and it is strictly preferable to the current behavior in which the marker is destroyed. Reseeding from a stale record is not a new failure mode: it already occurs today for any entry left in `docs/features/potential/`. No cleanup automation is added, and none is in scope.

- **Risk — The disposition predicate misclassifies a path.** A non-normalized or mixed-separator path could cause a promoted source to take the move branch (the defect persists) or an unpromoted source to take the copy branch (the entry stays in the idea queue).
  - *Mitigation:* Reuse the existing `isRelativeTo` helper (`flow.ts:413-420`), which normalizes through `toPosixPath` and requires equality or a `<root>/` prefix. Assert the sibling-directory negative case (`promoted-old`) so a prefix-only match cannot pass.

- **Risk — The receipt assertion converts a previously silent partial success into a hard failure.** A caller that treated any `ok: true` as terminal will now see `ok: false` in cases it did not previously handle.
  - *Mitigation:* The failure occurs only where the caller's subsequent filesystem access would have failed anyway, so the change moves the failure earlier and attaches a specific message. The success-path receipt shape is unchanged (see Backward-compatibility expectations), and no in-repo caller depends on a receipt whose `destination_path` is absent.

- **Risk — `flow.ts` exceeds the 500-line limit.** The file is at 444 lines and the change adds a branch at each of two sites.
  - *Mitigation:* INV-5 and AC-10 make this an explicit gate. If a compact helper does not fit, extract the disposition helper into `io.ts` (396 lines) rather than appending to `flow.ts`.

- **Risk — The fix silently regresses the promoted-fallback discovery.** Removing or narrowing the `promoted/` fallback would degrade seeding to the bare template — an outcome strictly worse than the present defect.
  - *Mitigation:* INV-1 forbids touching `findPotentialFile`. `io.test.ts:26-76`, including the fallback case at `:43-53`, remains unmodified and must keep passing.

## Rollout & Follow-up

- **Release/rollout steps.** A single branch and pull request against `main`. No migration, no configuration change, no coordinated release, and no consumer update. The TypeScript change takes effect for MCP callers when the extension bundle is rebuilt (`npm run build`); the Python change takes effect immediately for direct CLI use.

- **Post-fix monitoring or clean-up tasks.**
  1. On the next real promotion after merge, run the Probe A / Probe B sequence once and confirm the promoted record is present at Probe B. Record the transcript under `<FEATURE>/evidence/qa/`.
  2. The record removed during this run (`docs/features/potential/promoted/2026-08-17-promotion-lifecycle-loses-promoted-record.md`) is deliberately still absent as evidence. Recreating it is out of scope for this fix; if it is recreated later, do so only after review has observed the absence.

- **Open items deferred out of this fix.** Each is recorded so it is not mistaken for an oversight.
  1. Whether the previously lost promoted records (issues #469, #472, #479, and this run's) should be backfilled, and at what point in the phase order. Out of scope here.
  2. The superseded predecessor entry `docs/features/potential/2026-08-15-potential-to-issue-loses-promoted-record.md` still sits in the unpromoted queue and will be matched by future `findPotentialFile` scans for similar names. Its disposition is handled separately.
  3. Whether the Python cluster should remain a maintained parity source, given that it is no longer reached from the MCP surface and costs a mirrored edit on every workflow change. This fix is a data point for that decision, not the decision.
  4. `quality-tiers.yml` is absent at the repository root, so no tier classification is available for any module. Separately tracked; out of scope.
  5. `scripts/dev_tools/potential_to_issue.py` is 639 lines against a 500-line limit. Pre-existing and separately tracked; untouched by this fix.

- **Links.**
  - Issue: https://github.com/drmoisan/drm-copilot/issues/487
  - Requirements source: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/issue.md`
  - Root-cause research: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/research/2026-08-17T15-10-promotion-lifecycle-promoted-record-loss-research.md`
  - Reproduction evidence: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/promotion-lifecycle-probe.2026-08-17T15-02.md`
  - PRs: to be linked on creation
