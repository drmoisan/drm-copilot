# Policy Audit — F7 Parallel Enforcement Hooks (Issue #440)

- Feature folder: `docs/features/active/2026-08-07-parallel-enforcement-hooks-440`
- Branch: `feature/parallel-enforcement-hooks-440` @ `59796e82`
- Base: `epic/parallel-orchestration-integration`, merge base `c939b5b8`
- Authoritative diff: `git diff c939b5b8..HEAD` (152 files, +14915 / -113)
- Work mode: `full-feature` (marker read from `issue.md`) → AC sources `spec.md` + `user-story.md`
- Audit type: REAUDIT, remediation cycle 1 exit
- Supersedes: `policy-audit.2026-08-08T23-10.md`
- Timestamp: 2026-08-09T01-35

## Verdict Summary

| Severity | Count |
|---|---|
| Blocking | 0 |
| PARTIAL | 0 |
| Advisory | 5 |
| Informational | 2 |

Overall: **PASS**. The one Blocking finding from the previous pass (B-1) is closed. The one
required action (R-1) is resolved. No new Blocking or PARTIAL finding was identified.

## Rejected Scope Narrowing

None. The delegation prompt directed a full branch-diff audit against the resolved merge base and
explicitly named `git diff c939b5b8..HEAD` as the authoritative feature diff. No attempt was made
to narrow scope to a plan, task, phase, file subset, or to mark a language's coverage as
out-of-scope. No coverage or toolchain check was waived by the caller.

One exclusion was asserted by the caller and independently examined rather than accepted on
trust: the single remaining Pester failure
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 :: 'allows gh pr create --body-file
artifacts/pr_body_12.md when context exists'`. This is a legitimate pre-existing-defect exclusion,
verified below under `## Test Isolation`, not a scope narrowing.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. Language rules in scope: `.claude/rules/powershell.md`, `.claude/rules/python.md`,
   `.claude/rules/python-suppressions.md`, `.claude/rules/typescript.md`,
   `.claude/rules/typescript-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`
6. Domain rules: `.claude/rules/parallel-orchestration.md`, `.claude/rules/ci-workflows.md`,
   `.claude/rules/benchmark-baselines.md`, `.claude/rules/architecture-boundaries.md`

No policy document was modified. Confirmed: no path under `.claude/rules/` or
`.github/instructions/` appears in the branch diff.

## B-1 Closure Determination — CLOSED

The previous pass recorded B-1: the F7 extension seam in
`extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` was empty, so the
TypeScript surface reported a cohort-ordering violation as clean while the Python surface
rejected it. Three independent verifications were performed.

### 1. The seam invokes the helper, and the edit is confined to two added lines

`git diff c939b5b8..HEAD -- extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`
yields exactly two `+` lines and zero `-` lines:

- line 36: `import { validateCohortBarrierOrdering } from "./parallel-orchestrator-state-cohort-barrier";`
- line 315: `errors.push(...validateCohortBarrierOrdering(state));`

Line 315 sits between `// Add F7 helper invocations below this line, one per line.` and
`// END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION`, i.e. inside the delimiter the F3
seam contract reserves for F7. No pre-existing line was moved, reflowed, or reworded. The Python
counterpart edit is symmetric (`errors.extend(validate_cohort_barrier_ordering(state_map))`),
also two added lines, zero deleted.

File grew 320 → 322 lines, matching a pure two-line insertion.

### 2. The TypeScript port reproduces the Python reference semantics

Verified constant-for-constant and helper-for-helper against
`scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py`.

| Semantic requirement | Python reference | TypeScript port | Verdict |
|---|---|---|---|
| Barrier-satisfying set `{merged, worktree_removed}` | `MERGED_MERGE_STATUSES = ("merged", "worktree_removed")` (`_parallel_state_common.py:84`) | `MERGED_MERGE_STATUSES = words("merged worktree_removed")` (`parallel-state-shared.ts:74`) | MATCH |
| `ci_green` does NOT satisfy the barrier | not a member | not a member | MATCH |
| `ITEM_START_TIMESTAMP_FIELD` | `"worktree_created_at"` | `"worktree_created_at"` | MATCH |
| `MERGE_CONFIRMATION_TIMESTAMP_FIELD` | `"merged_at"` | `"merged_at"` | MATCH |
| `NOT_STARTED_MERGE_STATUS` | `"not_started"` | `"not_started"` | MATCH |
| `GATING_KEYS` | `("conflict_edges", "cohorts")` | `["conflict_edges", "cohorts"]` | MATCH |
| Strict generation-equality current-generation projection | `row.get("generation") != recolor_generation → continue` | `entry["generation"] !== recolorGeneration → continue` | MATCH (see Informational I-1) |
| Superseded generations ignored | yes | yes | MATCH |
| Structural reading (index equality) | `first_index is not None and first_index == second_index` | `firstIndex !== undefined && firstIndex === secondIndex` | MATCH |
| Endpoint outside current coloring left unjudged | `first_index is None or second_index is None → None` | `firstIndex === undefined \|\| secondIndex === undefined → null` | MATCH |
| Temporal reading, status disjunct | `_has_started(later) and not _satisfies_barrier(earlier)` | `hasStarted(later) && !satisfiesBarrier(earlier)` | MATCH |
| Temporal reading, timestamp disjunct | `confirmed > started` (ISO-8601 string compare) | `confirmed > started` | MATCH |
| Degrade when either timestamp absent or non-string | `not isinstance(confirmed, str) or not isinstance(started, str) → False` | `typeof confirmed !== "string" \|\| typeof started !== "string" → false` | MATCH |
| Absent `merge_status` never evidences a start | yes | yes | MATCH |
| Key-gated backward compatibility | `any(key not in state ...) → []` | `GATING_KEYS.some((key) => !(key in state)) → []` | MATCH |
| `conflict_edges` non-list → `[]` | yes | yes | MATCH |
| Folder-hint prefix order (longest first) | 4 entries, same order | 4 entries, same order | MATCH (see Advisory A-3) |
| First-occurrence resolution | `records.setdefault`, `by_folder_hint.setdefault`, `assignments.setdefault` | `!records.has`, `!byFolderHint.has`, `!assignments.has` | MATCH (see Advisory A-1) |
| Self-edge / unresolved endpoint skipped | `first is None or second is None or first == second` | `first === null \|\| second === null \|\| first === second` | MATCH |
| One message per violated edge, document order | yes | yes | MATCH |
| `<a>` is the earlier/first endpoint | `(earlier_key, later_key)` / `(first, second)` | same | MATCH |
| Byte-exact message, no context prefix, no trailing period | `f"{VIOLATION_PREFIX}: {endpoints[0]} ran concurrently with conflicting {endpoints[1]}"` | identical template | MATCH |

Message literal confirmed byte-exact from the committed corpus expectations, e.g.
`PARALLEL_COHORT_BARRIER_VIOLATION: 444 ran concurrently with conflicting 445` — no
`Parallel checkpoint` prefix, no trailing period. The case
`earlier-cohort-endpoint-named-first` expects
`PARALLEL_COHORT_BARRIER_VIOLATION: 445 ran concurrently with conflicting 444`, which pins the
earlier/later swap when the edge's `b` endpoint holds the lower cohort index.

**No semantic divergence was found within the corpus's declared value scope.** The three
divergence classes recorded in `.claude/rules/parallel-orchestration.md` remain unfixed and are
explicitly excluded by both parity suites — see Informational I-1.

### 3. The seam is empirically reached at run time

The 33-case TypeScript parity suite routes every document through the dispatched public entry
point `validateArtifact({ artifactType: "parallel-orchestrator-state", text })` and imports the
barrier helper nowhere. Eight of the 30 corpus cases declare non-empty
`expected_barrier_errors` (10 messages in total). Those eight cases pass. With an empty seam the
dispatched validator would emit zero barrier messages and all eight would fail. The seam is
therefore proven live through the public dispatch path, not merely present in source.

Independently executed in this audit:

- `npx jest test/lib/validate/parallel-cohort-barrier-parity.test.ts` → 33 passed
- `npx jest test/lib/validate/parallel-orchestrator-state-cohort-barrier.test.ts` → 5 passed
- `npx jest test/lib/validate/parallel-orchestrator-state-structures.test.ts` → 83 passed
- `pytest test_parallel_cohort_barrier_parity.py test_validate_parallel_orchestrator_state_cohort_barrier.py` → 64 passed
- `pytest test_parallel_orchestrator_surface_contracts.py` → 36 passed
- Pester, the three hook suites → Total=123 Passed=123 Failed=0 Skipped=0

**B-1 verdict: CLOSED.**

## Parity Mechanism Adequacy

The mechanism is **adequate** for its stated purpose, with named residual gaps.

Properties verified on both sides:

- **Same files.** Python resolves `REPO_ROOT / "tests" / "fixtures" / "parallel_cohort_barrier"`;
  TypeScript resolves the same directory five levels up from its test directory. Both read
  `*.json`.
- **Same expectation list.** Both read the `expected_barrier_errors` key and compare
  element-for-element in order (`assert observed == expected` / `expect(observed).toEqual(...)`).
- **Same filter token.** Both restate `VIOLATION_LABEL = "PARALLEL_COHORT_BARRIER_VIOLATION"` from
  the specification rather than importing the implementation's constant, so a renamed constant
  cannot silently move both sides together.
- **Vacuous pass is impossible.** Each side asserts (a) discovered count `>= MINIMUM_CORPUS_COUNT`
  of 30, and (b) discovered count equals an independently enumerated on-disk `.json` count. A
  third test requires the corpus to contain at least one violating and at least one clean
  document, so an all-clean corpus cannot silently stop exercising the message-emitting path.
- **Name/stem binding.** Both fail load if a fixture's `name` differs from its file stem, so a
  case cannot be renamed away from the file the other suite reads.
- **Dispatched entry point on the TypeScript side.** `validateArtifact` with artifact type
  `parallel-orchestrator-state`, with the helper imported nowhere in the test module. The Python
  side likewise imports only `validate_parallel_orchestrator_state_text`.
- **Corpus size confirmed:** 30 files on disk; 33 tests per side (3 guards + 30 cases) on both
  sides.

**Would it have caught B-1?** Yes, unambiguously. An empty seam yields zero barrier messages from
`validateArtifact`, and eight corpus cases assert non-empty ordered message lists. Eight test
failures would have resulted.

**Would it catch a future one-sided edit?** Yes for any behavior the corpus exercises, because
both runtimes are bound to one committed expectation file that neither can relax alone. It would
not catch a one-sided edit confined to the branches named in Advisory A-1 and A-2, nor to the
value classes named in Informational I-1.

## Corpus Behavioral Adequacy

The corpus exercises the following branches, verified by inspecting each document rather than by
counting files: key gate (3 cases), non-list `conflict_edges`, non-object edge entry, non-list
`items`, non-list `cohorts`, non-object cohort row, cohort row missing `item_keys`, non-integer
`recolor_generation`, superseded generation, folder-hint resolution (repository-rooted and bare
forms), unresolved endpoint, self-edge, structural same-cohort (single and three-edge), endpoint
outside coloring, temporal status disjunct via `merge_status`, temporal status disjunct via start
timestamp alone, `ci_green` non-satisfaction, earlier-endpoint-named-first swap, timestamp
disjunct true and false, and all four degradation permutations (both absent, start only, merged_at
only, both non-string), plus a clean ordered pair.

Reachable behaviors with **no** corpus case (verified programmatically across all 30 documents):

- No document contains a non-object entry inside `items[]`.
- No document contains an item whose `issue_num` is not a positive integer.
- No document contains an item whose `feature_folder` is absent, blank, or non-string.
- No document contains a duplicate `issue_num` across `items[]`.
- No document places one member in two current-generation cohort rows.
- No document uses a boolean or float `generation` / `recolor_generation`.

These are recorded as Advisory A-1, A-2 and Informational I-1.

## Findings

### A-1 (Advisory) — Corpus does not pin first-occurrence resolution semantics

Both implementations resolve duplicates by first occurrence, verified by reading:

- `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py:139` `records.setdefault`,
  `:142` `by_folder_hint.setdefault`, `:217` `assignments.setdefault`
- `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-cohort-barrier.ts:158`
  `if (!records.has(...))`, `:164` `if (!byFolderHint.has(hint))`, `:241` `!assignments.has(key)`

No corpus document exercises either duplicate path. A one-sided change to last-occurrence
semantics — for example replacing the TypeScript `!assignments.has(key)` guard with an
unconditional `set` — would leave both suites green. The delegation prompt asked specifically for
first-occurrence semantics to be confirmed; they are correct today but unpinned by the corpus.

Suggested (non-blocking) closure: add two corpus cases — one item list with a duplicate
`issue_num` whose two records carry different `merge_status`, and one member appearing in cohort 0
and cohort 1 of the current generation.

### A-2 (Advisory) — Corpus does not exercise the malformed-item skip branches

No corpus document contains a non-object `items[]` entry, an item with a non-positive-integer
`issue_num`, or an item with an absent/blank/non-string `feature_folder`. Both runtimes implement
these as guard-continues and agree by inspection, but the branches are unpinned. Note that the
`issue_num` guard is precisely where the integral-float divergence class of I-1 would surface.

### A-3 (Advisory) — Folder-hint prefix ordering is behaviorally inert and partly unexercised

`FOLDER_HINT_PREFIXES` is identical and identically ordered on both sides. The
"longest first so the repository-rooted form is stripped before the bare lifecycle form" rationale
in both files cannot be falsified by any input: no member of
`{docs/features/active/, docs/features/completed/, active/, completed/}` is a prefix of another, so
iteration order cannot change any result. Only `docs/features/active/` and the bare-basename form
are exercised by the corpus. Not a defect; the ordering claim is untestable by construction and
the comment slightly overstates what the order accomplishes.

### A-4 (Advisory) — Mirrored unreachable defensive guard

`parallel-orchestrator-state-cohort-barrier.ts:344-346`
(`if (earlier === undefined || later === undefined) { return null; }`) and its Python equivalent
(`if earlier is None or later is None: return None`) are structurally unreachable. Every key in
`assignments` was produced by `resolveReference`, which admits a number only when
`records.has(reference)` and a string only via `byFolderHint`, whose values are all keys of
`records`. Therefore `records.get(earlierKey)` cannot be undefined.

Lines 345-346 are the only two uncovered lines in the new module (409/411). Retained for
line-for-line parity with the reference implementation; harmless, and preferable to a divergent
port. Recorded so the coverage shortfall is understood rather than re-investigated.

### A-5 (Advisory) — File-size headroom is nearly exhausted in three files

Limit is 500 lines (`.claude/rules/general-code-change.md`). All files comply:

| File | Lines |
|---|---|
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 499 |
| `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` | 498 |
| `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py` | 496 |
| `extensions/.../parallel-orchestrator-state-cohort-barrier.ts` | 411 |
| `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` | 378 |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 350 |
| all other new/changed source and test files | <= 322 |

Three files sit within 4 lines of the cap. Any future addition to them forces a split. Compliant
now; flagged so a later change does not breach the limit unnoticed.

### I-1 (Informational) — Three pre-documented divergence classes remain out of corpus scope

Both parity suites state in their module docstrings that corpus documents are restricted to
JSON-representable values that round-trip through both runtimes' native types, so the three
classes recorded in `.claude/rules/parallel-orchestration.md` are "avoided rather than fixed":
`pythonRepr` quote selection, integral floats erased by `JSON.parse`, and boolean/integer
equality.

Two of those classes are reachable through this module's guards:

- **Integral floats.** `is_positive_integer` / `is_non_negative_integer` require `isinstance(int)`
  and so reject `444.0`; the TypeScript `isIntegral` uses `Number.isInteger`, and `JSON.parse`
  has already erased the distinction. An `issue_num` or `generation` written as an integral float
  would be judged differently.
- **Boolean/integer equality.** Python `row.get("generation") != recolor_generation` treats
  `True == 1`; TypeScript `!==` does not.

This is a pre-existing epic-level scope statement inherited from the F3 port, not introduced by
F7, and it is explicitly and honestly documented in three places. Recorded for completeness, not
charged to this feature.

### I-2 (Informational) — Python repo-wide branch figure differs from the delegation prompt

Parsing `artifacts/python/lcov.info` yields repo-wide Python branch coverage of **83.96%**
(4245/5056), not the 88.98% stated in the delegation prompt. Line coverage matches exactly at
91.88% (12541/13649). The difference is most consistent with coverage.py's terminal branch figure
being a combined line-plus-branch ratio rather than a pure branch ratio. Both values clear the
>= 75% threshold, so no gate outcome changes. Recorded for accuracy.

## Coverage Verification (mandatory, per language with changed files)

Changed-file counts by language in the branch diff: PowerShell 9 `.ps1`, Python 7 `.py`,
TypeScript 5 `.ts`, plus 2 `.psd1`, 1 `.cjs`, 33 `.json`, 94 `.md`, 1 `.xml`. C#: zero changed
files.

Coverage artifacts were inspected, not regenerated.

| Language | Artifact | Present | Repo-wide line | Repo-wide branch | Verdict |
|---|---|---|---|---|---|
| TypeScript | `extensions/drm-copilot/coverage/lcov.info` | yes | 96.56% (40624/42072) | 89.87% (5774/6425) | **PASS** |
| Python | `artifacts/python/lcov.info` | yes | 91.88% (12541/13649) | 83.96% (4245/5056) | **PASS** |
| PowerShell | `artifacts/pester/powershell-coverage.xml` | yes | 94.34% (3148/3337) | not emitted | **PASS** |
| C# | `artifacts/csharp/coverage.xml` | n/a | — | — | N/A (zero changed files) |

Thresholds applied: line >= 85%, branch >= 75%, uniform across T1–T4 per
`.claude/rules/quality-tiers.md` Authoritative Decision #2.

### Per-file coverage, new and modified files

| File | Tier status | Line | Branch | Verdict |
|---|---|---|---|---|
| `extensions/.../parallel-orchestrator-state-cohort-barrier.ts` | new | 99.51% (409/411) | 98.88% (88/89) | PASS |
| `extensions/.../parallel-orchestrator-state-core.ts` | modified | 99.38% (320/322) | 92.11% (35/38) | PASS |
| `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` | new | 99.07% (107/108) | 98.21% (55/56) | PASS |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | modified | 97.62% (82/84) | 94.12% (32/34) | PASS |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | new | 96.38% | not emitted | PASS |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | new | 91.80% | not emitted | PASS |
| `.claude/hooks/enforce-epic-invocation-origin.ps1` | modified | 91.67% | not emitted | PASS |

The new TypeScript module carries a Jest per-file `coverageThreshold` entry
(`jest.config.cjs`, lines 179-182: `lines: 85, branches: 75`), so the figures are machine-enforced
rather than merely reported.

**No regression on changed lines.** The seam file's two uncovered lines are 253-254, inside a
pre-existing `entries.forEach` in an unrelated completion-gate function. The two lines F7 added
(36 and 315) are both covered. Verified by reading the `DA:` records with zero hit counts from
`lcov.info` and mapping them to source.

### PowerShell branch coverage — explicit absence note

BRANCH is not a metric the PowerShell toolchain emits. Verified positively rather than assumed: the
JaCoCo `counter` types present in `artifacts/pester/powershell-coverage.xml` are exactly
`INSTRUCTION`, `LINE`, `METHOD`, `CLASS`. The same four and only those four appear in the per-file
artifact
`evidence/qa-gates/powershell-per-file-coverage.2026-08-08T22-50.xml`. No `BRANCH` counter exists
in either file. This is a capability limit of PoshQC/Pester coverage output, not absent evidence.
`INSTRUCTION` (command) coverage at 93.95% repo-wide is the closest available proxy and is
recorded as the substitute metric.

### Coverage exclusion policy

`extensions/drm-copilot/jest.config.cjs` gained four lines only — a per-file threshold entry for
the new module. No `exclude`/`coveragePathIgnorePatterns` entry was added or widened, and no path
under `src/` is excluded. Both `pester.runsettings.psd1` copies were changed to **add** the three
production hook files to the measured set, which strengthens rather than weakens measurement.
Verdict: PASS.

## Feature-Review Workflow Policy Rules

### `modified-workflow-needs-green-run` — NOT TRIGGERED

`git diff --name-only c939b5b8..HEAD` filtered against `^\.github/(workflows|actions)/` and
`^scripts/benchmarks/` returns zero paths. No workflow, no composite action, and no benchmark
script is in the diff, so the rule does not apply and no green-run evidence is required.

### `ci.yml` scheduling determination — VERIFIED POSITIVELY

`.github/workflows/ci.yml` declares:

```yaml
on:
  push:
    branches: [main, development]
  pull_request:
    branches: [main, development]
  workflow_dispatch:
```

A pull request whose base is `epic/parallel-orchestration-integration` matches neither
`pull_request` branch filter, so `ci.yml` schedules no run for this PR. This was established by
reading the trigger block, not by waiving a check. The consequence is recorded plainly: repository
CI provides no signal for this branch, and the local gate evidence plus the independent
re-execution documented above is the only verification available. That is a property of the
epic's integration-branch strategy, not a defect in this feature.

### `.claude/rules/benchmark-baselines.md` — NOT APPLICABLE

No baseline JSON and no file under `scripts/benchmarks/**` in the diff.

### `.claude/rules/ci-workflows.md` — NOT APPLICABLE

No workflow `run:` block added or modified.

## Evidence Location Compliance

`git diff --name-only` filtered against
`^artifacts/(baselines|qa|evidence|coverage)/` returns zero paths. All feature evidence is written
under the canonical
`docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/<kind>/` tree
(`baseline/`, `other/`, `qa-gates/`, `verification/`, `preflight/`).

`python scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0, no output. No
violation. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose in this audit.

## Carried-Forward Verifications

### Epic invocation-origin behavioral preservation — PASS

- `.claude/hooks/enforce-epic-invocation-origin.ps1`: 23 added, 11 deleted. Every deleted line is
  doc-comment prose or the `$script:GatedSubagentTypes` declaration. The
  `EPIC_INVOCATION_ORIGIN_BLOCKED` reason string appears in the diff as an unchanged context line.
- The parallel family is handled by an early `return` placed before the epic reason is
  constructed, so epic targets reach the identical unchanged string.
- Byte-identity asserted by exact-string comparison in the test file at lines 222 and 234, for
  `epic-orchestrator` and `epic-planner` respectively.
- Main-thread callers (absent/blank `agent_type`) and non-orchestrator callers still allow:
  `if ($caller -ne $script:ProhibitedCallerAgentType) { return Get-EpicInvocationOriginAllowDecision }`
  is unchanged.
- Non-gated targets still do not parse the payload: the `$hookInputParsed` guard and its comment
  are unchanged apart from the words "non-epic" → "non-gated".
- Pre-existing tests unmodified: `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1`
  is **154 added, 0 deleted**. New contexts only, as the spec requires.

### Concurrent-feature boundary (F6 #442, F8 #446) — PASS

- `.claude/skills/parallel-orchestrate/SKILL.md` diff is a **single hunk** that replaces the
  one-line F7 placeholder with 48 lines of F7 content. The hunk is bounded above by the F6
  placeholder text and below by the `## Radius Drift Detection (F8)` heading, both appearing as
  unchanged context lines.
- All three wave-4 headings survive in original order in **both** copies, at identical line
  numbers: `## Mutation Protocol (F6)` at 435, `## Enforcement Hooks (F7)` at 439,
  `## Radius Drift Detection (F8)` at 491. No relocation, reflow, reorder, retitle, or edit of the
  F6 or F8 sections.
- `## Enforcement Hooks (F7)` is the only region F7 touched.
- Repo copy and bundled mirror are byte-identical (`cmp` exit 0).

Note on the caller's phrasing "the remediation cycle added zero lines to that file": the branch was
rewritten to a single commit, so per-cycle attribution is not recoverable from git history. What is
verifiable, and what matters for the boundary constraint, is that the **total** branch diff for this
file is confined to the F7 section. That is confirmed.

### F5 reserved-body pin narrowing — PASS

`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` gained 8 lines: a new
`LANDED_WAVE_FOUR_FEATURES: frozenset[str] = frozenset({"F7"})` constant plus its comment.

- `RESERVED_HEADINGS` is **untouched** — all three headings, including F6 and F8, remain pinned.
- The heading-order and uniqueness pins are in other test functions, unmodified.
- `test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body` now `continue`s only for
  features in `LANDED_WAVE_FOUR_FEATURES`, which contains `"F7"` alone. The one-line-reserved-body
  pin therefore **remains fully in force for F6 and F8**.
- The narrowing is principled: the pin exists to catch content added ahead of its owning feature, and
  a section filled by its own owner is not ahead of itself.
- `pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` → 36 passed.

### PowerShell hook seam binding — PASS

| Hook | Seam defined | Seam called | Mocks in test |
|---|---|---|---|
| `enforce-parallel-cohort-barrier.ps1` | `Get-ParallelCohortBarrierCheckpointContent` line 54 | line 467 | 20+ |
| `enforce-parallel-worktree-removal-gate.ps1` | `Get-ParallelWorktreeRemovalGateCheckpointContent` line 34 | line 212 | 20 |

Both hooks read the checkpoint exclusively through the seam. The mocked value demonstrably changes
the decision: `-MockWith { $null }` yields `deny`, `-MockWith { '{ broken json' }` yields `deny`,
and mocked well-formed checkpoints with varying `merge_status` yield `allow` or `deny` accordingly.
No test reads a real checkpoint file.

### Test isolation — PASS

- Grep across the new Pester suites for `artifacts/orchestration/orchestrator-state.json`,
  `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `tempfile`, `tmp_path`, `os.tmpdir`, `mkdtemp`,
  `writeFileSync`: **no matches**.
- The only filesystem access in the two parity suites is the read-only load of the committed
  corpus, resolved from `__file__` / `__dirname`. Committed fixtures are not temporary files.
- No new test creates, writes, or deletes any file.
- The single remaining Pester failure is `enforce-pr-author-skill.Tests.ps1 :: 'allows gh pr create
  --body-file artifacts/pr_body_12.md when context exists'`. Independently confirmed out of scope:
  the file is **not in the branch diff**; the test invokes
  `Invoke-PrAuthorSkillDecision` with **no seam mock**, so the hook reads the live working-tree
  `artifacts/orchestration/orchestrator-state.json`; and `/artifacts` is gitignored
  (`.gitignore:6`), so the test's expectation depends on volatile session state. This is a
  pre-existing defect in a file F7 does not touch and is **not charged to this feature**.

### Bundle contracts — PASS

All five changed non-memory `.claude` files are byte-identical to their bundled mirrors under
`extensions/drm-copilot/resources/claude-customizations/.claude/` (`cmp` exit 0 for each):
`hooks/enforce-parallel-cohort-barrier.ps1`, `hooks/enforce-parallel-worktree-removal-gate.ps1`,
`hooks/enforce-epic-invocation-origin.ps1`, `settings.json`,
`skills/parallel-orchestrate/SKILL.md`.

`pack-manifests/core.json` gained exactly the two new hook entries, in alphabetical position:

```
".claude/hooks/enforce-parallel-cohort-barrier.ps1",
".claude/hooks/enforce-parallel-worktree-removal-gate.ps1",
```

`enforce-epic-invocation-origin.ps1` was already registered, so no entry was needed. Both
`pester.runsettings.psd1` copies (`scripts/powershell/` and
`extensions/drm-copilot/resources/powershell/`) received the identical 7-line coverage
registration.

## Toolchain Gates — Independently Re-Verified

| Stage | Language | Command run in this audit | Result |
|---|---|---|---|
| Format | Python | `black --check` on 4 changed files | 4 unchanged |
| Lint | Python | `ruff check` on 3 new files | All checks passed |
| Type check | Python | `pyright` on 3 new files | 0 errors, 0 warnings |
| Format | TS/JSON | `prettier --check` on corpus + 3 TS files | All match Prettier style |
| Lint | TypeScript | `eslint` on 2 src + 2 test files | exit 0 |
| Type check | TypeScript | `tsc --noEmit -p tsconfig.json` | exit 0 |
| Unit tests | Python | 2 barrier suites + surface contracts | 64 + 36 passed |
| Unit tests | TypeScript | 3 validate suites | 33 + 5 + 83 passed |
| Unit tests | PowerShell | 3 hook suites via Pester 5 | 123/123 passed |

Reported full-gate state, accepted as evidence and consistent with the spot checks above:
TypeScript 182 suites / 2472 tests; Python 3071 passed / 0 failed; PowerShell 2131 passed /
1 pre-existing failure / 9 skipped.

## Suppression Policy — PASS

Grep across all new and changed F7 source and test files for `noqa`, `type: ignore`,
`eslint-disable`, `@ts-expect-error`, `@ts-ignore`, `@ts-nocheck`, and PSScriptAnalyzer
suppressions: **no matches**. Zero suppressions were introduced, so no authorization question
arises.

## Spec Design-Constraint Compliance

| Constraint | Verdict | Evidence |
|---|---|---|
| 1. Both layers shipped; neither collapsed | PASS | Layer 1 hook (499 lines) and Layer 2 helper (378 lines) both present; SKILL.md section states why both are required |
| 2. Barrier over the conflict relation, not a dependency graph | PASS | Logic reads `conflict_edges[]` + cohort indices only; no `depends_on` anywhere in the diff |
| 3. Surface named `parallel` throughout | PASS | hook filenames, module names, checkpoint path, and all reason strings carry `PARALLEL_` / `parallel` |
| 4. Invocation-origin extended, epic behavior byte-compatible | PASS | see Carried-Forward Verifications |
| 5. Additive only; epic wave-barrier and removal-gate untouched | PASS | neither `enforce-epic-wave-barrier.ps1` nor `enforce-epic-worktree-removal-gate.ps1` nor `enforce-epic-merge-gate.ps1` appears in the diff |
| 6. Fail closed | PASS | null checkpoint, malformed JSON, unresolvable target, no cohort assignment all deny (Pester) |
| Non-goal: no drift logic | PASS | no `drift_events` reference in F7 code |
| Non-goal: no abandon gate | PASS | no `disposition` reference in F7 code |
| Non-goal: no parallel merge gate | PASS | no merge-gate hook added |
| Wave-4: SKILL.md confined to one named section | PASS | single hunk in `## Enforcement Hooks (F7)` |
| Wave-4: validator edit confined to two lines | PASS | 1 import + 1 `errors.extend`, both runtimes |
| Wave-4: no schema fields added | PASS | module reads existing fields only; docstring states this explicitly |
| Wave-4: F7 owns its own Python test file | PASS | `test_validate_parallel_orchestrator_state_cohort_barrier.py` is F7-owned |

## Remediation Requirement

**None.** Zero Blocking findings and zero PARTIAL findings. The five Advisory and two
Informational findings are non-blocking observations; A-1 and A-2 are the only ones that would
strengthen the divergence-detection guarantee and are recommended as follow-up corpus additions
rather than merge blockers. No `remediation-inputs` artifact is produced for this cycle.
