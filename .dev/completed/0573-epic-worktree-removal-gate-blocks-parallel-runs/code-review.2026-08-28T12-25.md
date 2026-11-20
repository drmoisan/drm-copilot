# Code Quality Review — Issue #573

- **Timestamp:** 2026-08-28T12-25
- **Issue:** #573
- **Branch under review:** `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`
- **Merge-base anchor:** `c7133fe75ce1ea1737843330b2232c175a689e37`
- **Language in scope:** PowerShell (production hook, its bundle mirror, one Pester suite) plus three Markdown prose files and their two bundle mirrors.

## Change Summary (as read from the diff, not from the executor's report)

| Path | +/− | Nature |
|---|---|---|
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | +163 / −18 | Second allow-branch, new read seam, extracted JSON parser, rewritten `.DESCRIPTION`, revised terminal deny reason |
| `extensions/…/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | +163 / −18 | Byte-identical mirror |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | +192 / −0 | 19 new tests, determinism mocks on pre-existing deny tests, file docstring |
| `.claude/skills/parallel-orchestrate/SKILL.md` | +18 / −9 | Two prose passages corrected |
| `extensions/…/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | +18 / −9 | Byte-identical mirror |
| `.claude/rules/parallel-orchestration.md` | +1 / −0 | One appended `## Enforcement` bullet |
| `extensions/…/claude-customizations/.claude/rules/parallel-orchestration.md` | +1 / −0 | Byte-identical mirror |

The test file has **zero deleted lines**. The base file was 236 lines carrying 27 `It` blocks; the head file is 428 lines carrying 46. Every pre-existing test therefore survives verbatim, and all 46 pass. This is a stronger statement about the "epic behavior unchanged" property than any assertion in the evidence artifacts: no pre-existing assertion was weakened, reworded, or deleted, only supplemented with mocks.

## Design and Structure

### Branch semantics are correct

`Invoke-EpicWorktreeRemovalGateDecision` (lines 319-366) executes in this order:

1. Line 335 — envelope-anomaly check, denying at 336-339 **before any checkpoint read**. Unchanged and still first.
2. Lines 342-345 — no `command` field, allow.
3. Line 347 — command is not `git worktree remove`, allow.
4. Line 351 — extract the target path (regex unchanged).
5. Line 353 — read and parse the epic checkpoint; lines 355-358 evaluate branch 1 and **return early** on authorize.
6. Line 360 — read and parse the parallel checkpoint; lines 361-363 evaluate branch 2 and return on authorize.
7. Line 365 — terminal deny.

The early return at 357 is what makes the cascade a genuine disjunction: branch 2's read is not even performed when branch 1 authorizes. The suite pins this from both directions — the test at line 368 proves ORed-not-ANDed (epic authorizes while the parallel checkpoint records `pr_open`, decision is `allow`), and the test at line 380 proves the anomaly ordering with `Should -Invoke … -Times 0 -Exactly` against **both** seams. Both are behavioral assertions about invocation counts, not textual assertions about source order, which is the right shape.

**Assessment: correct. No finding.**

### Fail-closed structure

`Test-ParallelCheckpointAllowsWorktreeRemoval` (lines 225-287) is a positive predicate. Every guard returns `$false`:

- line 251 — `$null` checkpoint or blank path
- line 257 — `route_id` absent, or present and not exactly `parallel`
- line 260 — `items` absent or null
- line 273 — `continue` for an item with no `worktree_path` (skip, do not match)
- line 280 — matched item with no `merge_status` returns `$false`
- line 283 — the only `$true` path, gated on membership in `$script:AllowedMergeStatuses`
- line 286 — fall-through returns `$false`

There is no code path through this function that returns `$true` from a negative condition. The claim in the `.DESCRIPTION` ("no negative path returns an allow") is verified by reading, not merely asserted.

One behavioral detail worth recording: on the **first** matching `worktree_path`, the function decides and returns rather than continuing to scan for a second match. This mirrors `Find-EpicWorktreeFeatureRecord`, which likewise returns the first match, so the two branches agree. It is also the fail-closed choice — a duplicate path entry with a non-authorizing status cannot be overridden by a later duplicate with an authorizing one. Correct as written; no change recommended.

**Assessment: correct. No finding.**

### Path normalization is shared by construction, not by duplication of intent

Branch 1 normalizes at lines 181 and 190; branch 2 at lines 264 and 276. Both use the identical expression `($x -replace '\\', '/').TrimEnd('/')` applied to both sides of the comparison. The suite pins the parallel side with a dedicated separator test (line 284) mirroring the pre-existing epic one (line 125).

**Minor observation (C-1, Non-blocking).** The normalization expression is now written four times across two functions. The spec calls for shared normalization and the two copies do agree textually today, but they are not enforced to agree — a future edit to one branch's expression would silently diverge, and no test would catch it because each branch has its own normalization test. Extracting a two-line `Get-EpicWorktreeGateNormalizedPath` helper would make the agreement structural rather than conventional, and would sit naturally alongside the `ConvertFrom-EpicWorktreeGateJson` extraction the change already performs. This was not required by the spec and is not required for merge.

### Parser extraction

The change replaces the inline six-line parse (old lines 207-213) with `ConvertFrom-EpicWorktreeGateJson` (lines 103-129), used by both branches. Behavioral equivalence was checked line by line: the old code set `$checkpoint = $null` when the raw text was null/empty/whitespace and otherwise attempted `ConvertFrom-Json -ErrorAction Stop` inside a `try`/`catch` that set `$null`. The helper does exactly this. The `[AllowNull()] [string] $Raw` signature coerces a `$null` argument to the empty string, which `[string]::IsNullOrWhiteSpace` catches at line 121, so the null case is handled.

This is the right call under `.claude/rules/general-code-change.md`, which ranks reusability second and prohibits copy-paste. It also matches the merge gate's `ConvertFrom-EpicMergeGateJson` precedent, so the two gates now have the same internal shape. The cost — six touched pre-existing lines — is explicitly accepted in plan decision 1.

**Assessment: correct and well-motivated. No finding.**

### Documentation quality

The rewritten `.DESCRIPTION` (lines 5-56) is unusually substantial for a hook header, and each part earns its place:

- lines 13-18 — the numbered two-branch cascade
- lines 20-26 — the enumerated fail-closed modes and the "anomaly checked first" statement
- lines 28-36 — why the key is the path and why the two branches are mutually exclusive in practice
- lines 38-46 — the accepted stale-checkpoint residual, stated with its bound rather than dismissed
- lines 48-51 — the relationship to the sibling gate and the reason the prefix is not renamed

The residual passage is the most valuable part: it records a known limitation, the argument for why it is bounded, and the explicit note that the `route_id` guard does **not** address it. That last sentence prevents a future reader from mistaking the route check for a mitigation it is not.

The passage refers to the sibling gate by **file name** rather than by its `PARALLEL_WORKTREE_REMOVAL_BLOCKED` reason prefix, which is what keeps the `PARALLEL_` sequence out of the file. That is a deliberate and non-obvious authoring constraint, correctly observed.

**Assessment: high quality. No finding.**

### Reason-prefix discipline

Independently verified by fixed-string search:

- `git grep -c "PARALLEL_" -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1` → **no match, exit 1**.
- `EPIC_WORKTREE_REMOVAL_BLOCKED` appears four times: two prose references in `.DESCRIPTION` (lines 20, 50) and two constructed reasons (line 337 anomaly deny, line 365 terminal deny). Those two are the **only** two calls to `Get-EpicWorktreeGateBlockDecision` in the file, so every deny reason the gate can emit begins with the literal prefix.

The revised terminal reason at line 365 uses `""parallel""` inside a double-quoted PowerShell string, which renders as `"parallel"` in the emitted text. Correct escaping. The single-quoted `'$worktreePath'` interpolation is preserved from the original.

**Assessment: correct. No finding.**

## Test Quality

### Coverage of the new surface

| Category | Count | Location |
|---|---|---|
| Parallel allow (merged, worktree_removed, separator normalization) | 3 | lines 266, 275, 284 |
| Parallel fail-closed deny | 8 | lines 300, 307, 314, 323, 332, 339, 348, 357 |
| Ordering and precedence | 2 | lines 368, 380 |
| Direct predicate guard clauses | 4 | lines 392, 397, 403, 409 |
| Read-seam behavior | 2 | lines 417, 422 |
| **Total added** | **19** | |

The count of 19 was verified by counting `It` blocks in the new contexts and cross-checked against the delta from 27 to 46 in the reviewer's own Pester run.

The eight deny cases exhaust every failure mode the `.DESCRIPTION` enumerates, including the two that end-to-end tests reach only through the predicate's interior (`route_id` present-but-wrong versus absent). The four direct-predicate tests reach guard clauses no end-to-end path can (a `$null` checkpoint distinct from an unreadable one, and the `worktree_path`-less item that must be *skipped* rather than *matched*). This layering — end-to-end for behavior, direct for guards — mirrors the merge gate's structure and is the right allocation.

**Assessment: thorough. No finding.**

### Test purity

Verified three ways:

1. Reading all 46 `It` blocks. Every checkpoint fixture is a single-quoted literal JSON string returned from a `-MockWith` block. No file is created, opened, or written.
2. Running the repository's own purity hook, `.claude/hooks/check-powershell-test-purity.ps1`, against the suite content: **no decision returned (clean)**.
3. The two `real Test-Path read seam` contexts (lines 173-184 and 416-427) mock both `Test-Path` **and** `Get-Content` under `-ParameterFilter { $LiteralPath -eq $script:…CheckpointPath }`. The `Get-Content` mock is what keeps the "file exists" case from touching the disk — without it, a `Test-Path` returning `$true` would send the seam to a real read. Both contexts get this right.

**Assessment: clean. No finding.**

### Determinism

Nine `-MockWith { $null }` mocks of `Get-EpicWorktreeGateParallelCheckpointContent` were counted, covering every deny-expecting test that can reach line 360 plus the entry-point `BeforeEach` at lines 187-190 (which covers seven entry-point tests). The file docstring at lines 8-21 states the rule in prose and adds an explicit instruction to future contributors: "Every deny-expecting test MUST mock BOTH seams." This mirrors the statement already carried by `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` lines 7-11.

The docstring's inclusion of the *rationale* ("would read live local state and pass or fail depending on whether a parallel run happens to be in flight") is what makes it durable — a rule without a reason gets deleted by the next person who finds it inconvenient.

The residual gap in the three allow-expecting tests is recorded as finding N-1 in the policy audit and is not repeated here.

**Assessment: satisfied, with the second-order gap noted in the policy audit.**

### Test naming and readability

Test names are descriptive full sentences stating the condition and expected decision ("denies when route_id is present but is not parallel even though a merged matching item is present"). Contexts are named for the behavior under test and tagged with the AC numbers they discharge, which makes the AC-to-test trace readable directly from the file without consulting the plan. `$script:RemoveItemA` in the deny context's `BeforeEach` removes eight repetitions of the same envelope literal without hiding anything material.

**Assessment: good. No finding.**

## Prose Changes

### `.claude/skills/parallel-orchestrate/SKILL.md` lines ~390-405

The stale passage claimed removal "is denied until F7 both delivers `enforce-parallel-worktree-removal-gate.ps1` and coordinates the epic gate's allow conditions." The replacement states both halves have landed, describes the epic gate's second branch, and **retains** the load-bearing rationale sentence about conjunctive `PreToolUse` denials — reframed from a prediction into an explanation of why the epic gate itself had to change. The final sentence about F7 shipping no hook file is retained and explicitly scoped to that feature rather than deleted.

This is the correct edit. The original passage is the reason issue #573 was predictable from committed prose; leaving it would have recreated the same drift in mirror image.

### `.claude/skills/parallel-orchestrate/SKILL.md` near line 742

Three sentences appended to the existing parallel-gate description. The pre-existing text and its `PARALLEL_WORKTREE_REMOVAL_BLOCKED` reference are untouched — the passage was extended, not replaced.

### `.claude/rules/parallel-orchestration.md`

One bullet, appended as the last entry of `## Enforcement`, immediately after the parallel merge-gate bullet it parallels. The diff is `+1 / −0`. The bullet states the route condition, the match key, the allowed statuses, the enumerated fail-closed modes, the reason prefix, why the key is the path rather than `pr_number`, and the conjunctive-denial relationship to the sibling gate.

Verified that nothing else in the file changed: the Foreign Schema Warning, all 21 numbered orchestrator invariants, P1-P9, M1-M8, all nine enum-table rows, the Cache Doctrine, the Concurrency Bound, and the Blast-Radius Contention Doctrine are byte-identical to the merge base.

**Assessment: correctly scoped. No finding.**

## Error Handling

Both checkpoint reads are guarded at two levels — an absent file yields `$null` from the seam (`Test-Path -PathType Leaf` at lines 79 and 97), and an empty or unparseable body yields `$null` from `ConvertFrom-EpicWorktreeGateJson`. Neither raises. For an enforcement gate, `$null` routes to a deny, so a swallowed parse error is the safe outcome and is documented as such at `.DESCRIPTION` lines 20-26. This is the deliberate exception the general policy's fail-fast rule permits, not a silent-ignore violation.

The entry point still returns 0 unconditionally, correctly, because `exit 1` is non-blocking for `PreToolUse` — an anomaly must be expressed as a deny *decision*, not as a process failure. Unchanged from the base and covered by seven entry-point tests.

## Performance

The gate gains one `Test-Path` and, when the file exists, one `Get-Content -Raw` plus one `ConvertFrom-Json` per in-scope command. Both occur only after the command has matched `git worktree remove` (line 347), so no I/O is added to the common path of unrelated `Bash` calls. The added cost is a single small local read on a command that is itself a filesystem mutation. No concern.

## Findings Summary

| ID | Severity | Location | Finding |
|---|---|---|---|
| C-1 | Non-blocking | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` lines 181, 190, 264, 276 | The path-normalization expression is written four times across two functions. The copies agree today but are not structurally enforced to agree; each branch has its own normalization test, so a divergence would not be caught. Consider extracting a shared normalization helper alongside the existing `ConvertFrom-EpicWorktreeGateJson` extraction. Not required for merge. |

Findings N-1 through N-5 are recorded in `policy-audit.2026-08-28T12-25.md` and are not duplicated here.

**Blocking findings: 0. Non-blocking findings in this document: 1 (C-1).**

## Overall Assessment

The implementation matches the specified design precisely. The disjunctive cascade is correctly ordered and correctly short-circuited; the anomaly deny remains first and is pinned by an invocation-count assertion rather than by inspection; the new predicate has no path from a negative condition to an allow; the parser extraction is behaviorally equivalent and reduces duplication; the reason prefix is preserved and the `PARALLEL_` sequence is absent; and the three mirrored pairs are byte-identical by independent recomputation. The test suite adds 19 tests with no deletion or weakening of the 27 pre-existing ones, is pure by both manual reading and the repository's own purity hook, and carries a durable determinism rule with its rationale in the file docstring. Documentation is accurate and records its own accepted residual rather than concealing it.
