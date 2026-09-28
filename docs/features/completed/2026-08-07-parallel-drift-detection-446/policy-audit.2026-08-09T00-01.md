# Policy Compliance Audit — F8 Radius Drift Detection (issue #446)

- Timestamp: 2026-08-09T00-01
- Feature folder: `docs/features/active/2026-08-07-parallel-drift-detection-446`
- Branch: `feature/parallel-drift-detection-446`
- Base for the diff: `c939b5b80c8c297db49febaebdd35dda2c869a3f` (epic integration head)
- Single commit under review: `bcf2de15`
- Work mode: `full-feature` (from `issue.md` line 12) — AC sources are the `## Acceptance Criteria`
  sections of `spec.md` and `user-story.md`
- Diff scope audited: the full branch diff, 48 files, 9497 insertions, 68 deletions

## Rejected Scope Narrowing

None. The delegating prompt scoped the review to the full branch diff against the named base
commit and did not attempt to limit coverage, files, or toolchain checks. No narrowing was
detected, so no narrowing text is recorded here.

## Policy Reading Order Followed

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`,
   `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/powershell.md`
5. Domain rules: `.claude/rules/parallel-orchestration.md`, `.claude/rules/quality-tiers.md`,
   `.claude/rules/orchestrator-state.md`, `.claude/rules/tonality.md`
6. Feature documents: `issue.md`, `spec.md`, `user-story.md`, `plan.2026-08-07T11-11.md`
7. Evidence: `evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md`,
   `evidence/other/shared-file-edit-confinement.2026-08-09T03-19.md`, all `evidence/qa-gates/*`
8. Design: `docs/research/2026-08-07-parallel-orchestration-design-research.md` sections 7, 9, 12;
   `docs/features/epics/parallel-orchestration/epic.md` (Shared Design, Non-Goals, Wave-4
   Contention Note, F8)

No policy document was modified by this review, and none was modified by the branch.

## Verdict Summary

| # | Policy area | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | Enum ownership — wave-4 consumes, never extends | PASS | no schema field added, no enum extended; `drift_events[].action` still two members |
| 2 | Wave-4 shared-file edit confinement | PASS | SKILL.md in-place fill, validator +2 lines, settings.json append-only |
| 3 | F7 extension seam untouched | PASS | dispatch inserted above `BEGIN F7 EXTENSION SEAM`, seam bytes unchanged |
| 4 | Sibling reserved sections byte-identical and in order | PASS | `## Mutation Protocol (F6)` and `## Enforcement Hooks (F7)` unchanged; order preserved |
| 5 | Additive only — epic surface untouched | PASS | `.claude/skills/orchestrate/SKILL.md` and every epic validator/hook unchanged |
| 6 | File-size limit (500 lines) | PASS | largest production file 500 lines exactly (at the cap, not over) |
| 7 | Python toolchain (format, lint, typecheck, test) | PASS | four `EXIT_CODE: 0` artifacts; ruff and black independently re-verified clean |
| 8 | PowerShell toolchain (format, analyze, test) | PARTIAL | format and analyze `EXIT_CODE: 0`; test `EXIT_CODE: 1` from one verified pre-existing failure |
| 9 | Python coverage | PASS | 92.02% line / 84.11% branch repo-wide; six new modules 100%/100%; independently recomputed |
| 10 | PowerShell coverage | PASS | new hook 96.53% line; branch metric not emitted by the toolchain (verified) |
| 11 | TypeScript coverage | N/A — zero changed files | `git diff --name-only` returns no `.ts`/`.tsx` file |
| 12 | C# coverage | N/A — zero changed files | `git diff --name-only` returns no `.cs`/`.csproj` file |
| 13 | Coverage-exclusion policy | PASS | hook added to `CodeCoverage.Path`; no production path excluded |
| 14 | Test file location (mirrored `tests/` tree) | PASS | all seven test files mirror their production paths |
| 15 | No temporary files in tests | PASS | both read boundaries are injectable seams; no `New-Item`/`tmp_path` fixture use |
| 16 | Determinism of production logic | PASS | every timestamp is a function input; the one clock read is at the CLI boundary |
| 17 | Determinism of test code | PARTIAL | the cross-runtime seam test resolves `python` from machine PATH and spawns a process |
| 18 | Suppression policy (`noqa` / `type: ignore`) | PASS | zero suppressions in any production file |
| 19 | Docstring and commenting policy | PASS | module, class, function, loop, and branch comments present throughout |
| 20 | Evidence-location invariant | PASS | `validate_evidence_locations.py --root .` exits 0 |
| 21 | Fail-closed doctrine (epic Shared Design #7) | PARTIAL | three fail-open paths identified (F8-N3, F8-N4, plus F8-B1's consequence) |
| 22 | Directional halt rule | FAIL | halt selection can select the drifting item (F8-B2) |
| 23 | Drift gate has a documented release path | FAIL | no producer for either resolution disjunct (F8-B1) |
| 24 | Bundled-mirror parity | PASS | four mirrors byte-identical by SHA-256; the fifth is a manifest entry |
| 25 | Repo tier classification | UNVERIFIED — pre-existing gap | `quality-tiers.yml` absent at repo root and absent at the base commit |

Total Blocking findings: **2** (F8-B1, F8-B2).

## 1. Enum Ownership and Schema Consumption (PASS)

`.claude/rules/parallel-orchestration.md` `## Enum Ownership (F6/F7/F8 consume, never extend)`
binds F8 to consume the nine enums without extension. Verified:

- `drift_events[].action` remains exactly two members. `scripts/dev_tools/_parallel_state_common.py`
  `VALID_DRIFT_ACTIONS` is unmodified by this branch, and F8 imports it rather than restating it
  (`scripts/dev_tools/parallel_drift_detection.py:51-56`). There is **no `resolved` member**, and
  `tests/scripts/dev_tools/test_parallel_drift_detection.py:100-110` asserts at run time that the
  enum has length 2 and that `"resolved" not in VALID_DRIFT_ACTIONS`.
- No checkpoint field was added. The `drift_events[]` record key set is pinned by
  `DRIFT_EVENT_KEYS` (`parallel_drift_detection.py:93-95`) to the six section-12 fields and
  asserted by `test_drift_event_key_set_matches_the_section_12_shape`.
- No validator constant in `_parallel_state_common.py`, `_parallel_state_records.py`, or
  `_parallel_state_structures.py` was touched. `git diff` shows those files absent from the diff.
- Every enum member F8 emits passes through `require_enum_member(value, <F3 constant>, label)`
  (`_parallel_drift_shape.py:173-196`), so a member F3 renames or removes fails at the producer.
- `PROGRESSED_MERGE_STATUSES` (`_parallel_orchestrator_state_drift.py:83-87`) reuses F3's
  `MERGED_MERGE_STATUSES` for its two terminal members and is asserted to be a subset of
  `VALID_MERGE_STATUS` at run time
  (`test_validate_parallel_orchestrator_state_drift.py:116-119`).

The reconciliation artifact records the mandated consequence of the two-member enum: because a
zero-escape event is rejected by invariant 18, resolution had to be derived rather than recorded.
The adoption of that derivation is itself compliant with enum ownership. Its release path is not
(see F8-B1).

## 2. Wave-4 Shared-File Edit Confinement (PASS)

Three shared files were edited; each edit is confined as the epic Wave-4 Contention Note requires.

**`.claude/skills/parallel-orchestrate/SKILL.md`.** The diff touches only the region after the
heading `## Radius Drift Detection (F8)` (line 443 at base). The one-line reserved sentence was
replaced in place by F8 content, which is what the placeholder itself directs
("content is appended by that feature and must not be relocated"). No new `## ` heading was added:
F8 used `###`/`####` sub-headings, so `test_orchestrate_skill_first_thirteen_headings_match_
required_layout` still finds exactly sixteen `##` headings and
`test_orchestrate_skill_reserved_wave_four_sections_close_the_file` still finds the same final
three in the same order. Both sibling reserved sections are byte-identical: the diff's leading
context line is the unmodified `Reserved for F7; ...` body, and the F6 section lies wholly outside
the single hunk.

**`scripts/dev_tools/validate_parallel_orchestrator_state.py`.** Exactly two added lines, zero
removed, zero reflowed:

```
+from scripts.dev_tools._parallel_orchestrator_state_drift import validate_drift_gate
+    errors.extend(validate_drift_gate(state_map, CONTEXT))
```

The dispatch call is inserted immediately after `errors.extend(_validate_collections(state_map))`
and therefore **above and outside** the comment-delimited
`BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` block. The seam's comment lines are
untouched and the block remains empty, so F7's concurrent edit lands in a disjoint hunk.

**`.claude/settings.json`.** Exactly one entry appended to the end of the `PreToolUse` `Agent`
matcher hook list; no existing entry reordered or reflowed. The Pester test
`asserts the registered hook path resolves to an existing file` reads the live settings file at run
time, asserts exactly one `Agent` matcher group, exactly one entry naming this hook, and that the
path it names exists on disk.

Two further shared files were edited beyond the plan's three, both justified:

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — one appended `CodeCoverage.Path`
  entry plus a two-line comment citing issue #446. This is required by the Coverage Exclusion
  Policy, not optional.
- The F5-owned surface-contract test pair (see section 9).

## 3. Additive-Only Constraint (PASS)

`.claude/skills/orchestrate/SKILL.md` is absent from the diff, satisfying spec AC #10 and the
`Reuse R1-R5 unmodified` constraint. No epic validator, epic hook, or epic helper module appears in
the diff. `.claude/hooks/enforce-epic-wave-barrier.ps1`, the adaptation source, is unmodified. The
new hook is a new `parallel`-named file, which is the epic's prescribed reuse mechanism
("Reuse is by near-verbatim adaptation into new files, not by refactoring the epic
implementations").

## 4. Surface Naming (PASS)

Every new artifact is `parallel`-named: `parallel_drift_detection.py`,
`parallel_drift_detection_cli.py`, `parallel_drift_halt.py`, `_parallel_drift_shape.py`,
`_parallel_drift_cli_io.py`, `_parallel_orchestrator_state_drift.py`,
`enforce-parallel-drift-gate.ps1`. Error tokens are `PARALLEL_DRIFT_GATE_VIOLATION:` and
`PARALLEL_DRIFT_GATE_BLOCKED`, matching the spec.

## 5. File-Size Limit (PASS)

| File | Lines | Verdict |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 500 | at the cap, compliant |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | 500 | at the cap, compliant |
| `scripts/dev_tools/parallel_drift_detection.py` | 494 | compliant |
| `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` | 487 | compliant |
| `tests/scripts/dev_tools/test_parallel_drift_detection.py` | 454 | compliant |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 412 | compliant |
| every other new file | <= 411 | compliant |

The rule is "may not exceed 500 lines". Two files are exactly 500, which does not exceed the cap.
The verdict is PASS. See F8-N10 for the zero-headroom consequence.

## 6. Python Toolchain (PASS)

| Stage | Artifact | EXIT_CODE |
| --- | --- | --- |
| Format (`black .`) | `evidence/qa-gates/python-format-final.2026-08-08T23-24.md` | 0 |
| Lint (`ruff check .`) | `evidence/qa-gates/python-lint-final.2026-08-08T23-24.md` | 0 |
| Typecheck (`pyright`) | `evidence/qa-gates/python-typecheck-final.2026-08-08T23-24.md` | 0 |
| Test (`pytest --cov --cov-branch`) | `evidence/qa-gates/python-test-final.2026-08-08T23-24.md` | 0 |

Independently re-verified during this review: `ruff check` over the six new production modules and
one test module reports "All checks passed!"; `black --check` over three new modules reports
"3 files would be left unchanged"; `pytest` over the seven drift test files plus the F5 surface
contract file reports **205 passed** in 0.37s. Zero `# noqa` and zero `# type: ignore` appear in
any production file, so the suppression policy has nothing to authorize.

## 7. PowerShell Toolchain (PARTIAL — one verified pre-existing failure)

| Stage | Artifact | EXIT_CODE |
| --- | --- | --- |
| Format | `evidence/qa-gates/powershell-format-final.2026-08-08T23-24.md` | 0 |
| Analyze | `evidence/qa-gates/powershell-analyze-final.2026-08-08T23-24.md` | 0 |
| Test | `evidence/qa-gates/powershell-test-final.2026-08-08T23-24.md` | 1 |

The non-zero test exit code is attributable to exactly one failure, verified pre-existing:

- Test: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ::
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Assertion site: `enforce-pr-author-skill.Tests.ps1:142`; expected `'allow'`, observed `'deny'`
- Root cause: the suite exercises `.claude/hooks/enforce-pr-author-skill.ps1`, which reads the real
  gitignored `artifacts/orchestration/orchestrator-state.json` rather than a mocked seam, so it
  fails whenever an orchestrated run is live.
- Pre-existence: the Phase 0 baseline artifact
  `evidence/baseline/powershell-test-baseline.2026-08-08T20-59.md` records `EXIT_CODE: 1` with the
  **same test name, same assertion, same line 142, same expected/observed pair**. Post-change:
  2080 passed, 1 failed, 9 skipped.
- Out of scope: the file is absent from the branch diff, so it was neither edited nor weakened to
  force a green gate. That is the correct disposition; editing it would have been an out-of-scope
  change to an unrelated hook's test.

Verdict for this item: the pre-existing failure is genuinely pre-existing and out of scope, and the
PARTIAL verdict on the toolchain stage carries no F8 remediation obligation. Recorded as F8-I3.

## 8. Coverage Verification (mandatory, per changed language)

### Languages with changed files on the branch

| Language | Changed files | Coverage artifact | Present | Verdict |
| --- | --- | --- | --- | --- |
| Python | 13 (6 new production, 1 edited production, 6 new/edited test) | `artifacts/python/lcov.info` | yes | **PASS** |
| PowerShell | 2 new (hook + test) plus 2 config mirrors | `artifacts/pester/powershell-coverage.xml` | yes | **PASS** |
| TypeScript | 0 | `coverage/lcov.info` | absent | N/A — zero changed files |
| C# | 0 | `artifacts/csharp/coverage.xml` | absent | N/A — zero changed files |

The TypeScript and C# `N/A` verdicts rest on `git diff --name-only c939b5b8..HEAD` returning no
`.ts`, `.tsx`, `.cs`, or `.csproj` path. Both are permitted `N/A` under the coverage invariant
because the changed-file count is genuinely zero, not because a caller declared them out of scope.

### Python — independently recomputed from `artifacts/python/lcov.info`

| File | Line | Branch | New/Modified | Verdict |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | 94/94 = 100.00% | 32/32 = 100.00% | new | PASS |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 66/66 = 100.00% | 6/6 = 100.00% | new | PASS |
| `scripts/dev_tools/parallel_drift_halt.py` | 42/42 = 100.00% | 6/6 = 100.00% | new | PASS |
| `scripts/dev_tools/_parallel_drift_shape.py` | 40/40 = 100.00% | 20/20 = 100.00% | new | PASS |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | 41/41 = 100.00% | 18/18 = 100.00% | new | PASS |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | 44/44 = 100.00% | 14/14 = 100.00% | new | PASS |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 82/84 = 97.62% | 32/34 = 94.12% | modified | PASS |
| **Repo-wide** | **12761/13868 = 92.02%** | **4286/5096 = 84.11%** | — | **PASS** |

Every new file exceeds the 90% new-code line trigger and the 85%/75% uniform thresholds. Repo-wide
line coverage is above 80% and above 85%. Changed-line regression check on the one modified file:
statements rose from 82 to 84 (the two added lines), missed statements unchanged at 2, so both
added lines are covered — 2 of 2 changed lines covered, no regression. These figures were
recomputed from the LCOV report during this review and match the `coverage-delta` artifact exactly.

### PowerShell — independently recomputed from `artifacts/pester/powershell-coverage.xml`

For `enforce-parallel-drift-gate.ps1`:

```
<counter type="INSTRUCTION" missed="7"  covered="197" />   96.57%
<counter type="LINE"        missed="5"  covered="139" />   96.53%
<counter type="METHOD"      missed="0"  covered="15"  />  100.00%
<counter type="CLASS"       missed="0"  covered="1"   />  100.00%
```

Line coverage 96.53% exceeds both the 85% uniform threshold and the 90% new-file trigger. The five
uncovered lines (492, 494, 495, 498, 500) are exactly the dot-source-guarded entrypoint block,
which cannot execute while the suite dot-sources the file; the file is **not** excluded from
measurement, so those lines remain a visible cost in the denominator, which is what the Coverage
Exclusion Policy requires.

Branch coverage is **not obtainable**. Independently verified: the entire JaCoCo report contains
exactly four counter types — `CLASS` (103), `INSTRUCTION` (427), `LINE` (427), `METHOD` (427) — and
**no `BRANCH` counter anywhere**. The identical negative result is recorded at the Phase 0
baseline. This is a measurement limitation of Pester v5 and the PoshQC conversion step, not a
threshold waiver and not a value the executor chose to omit; no branch number was invented. The
finest-grained analogue the toolchain does emit, INSTRUCTION at 96.57%, is well above the analogous
threshold.

PowerShell verdict: **PASS**. Every obtainable metric is measured and exceeds its threshold; the
one unobtainable metric is documented with search evidence and is unobtainable from every
configuration of this repository's toolchain. Recorded as F8-I2.

### Coverage exclusion policy (PASS)

No production path was excluded. The branch moves in the opposite direction: `[P5-T4]` **added**
`.claude/hooks/enforce-parallel-drift-gate.ps1` to `CodeCoverage.Path`, enlarging the denominator.
No `exclude` entry matching a production source path was added anywhere.

## 9. F5-Owned Test Artifact Modification (PASS — minimum necessary)

Two F5-owned files were modified because filling the reserved placeholder necessarily invalidated
an assertion that pinned all three placeholders to their reserved one-line sentence.

**`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`** — added a
`FILLED_RESERVED_HEADINGS` tuple holding one entry, `"## Radius Drift Detection (F8)"`, one entry
per line with a citing comment. `RESERVED_HEADINGS` is **unchanged**: the diff shows the tuple only
as leading context.

**`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`** — modified exactly
one existing test, `test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body`. No test
was added and no test was removed (`grep -n "def test_"` returns the same 22 test functions before
and after).

Protection for F6 and F7 is preserved and, for F8, inverted rather than removed:

- The loop still iterates `RESERVED_HEADINGS`, so F6's and F7's placeholders are still asserted to
  equal their exact one-line reserved sentence. Any premature wave-4 content in either section
  still fails.
- For the one filled heading the assertion becomes `body and body != expected`, so the section must
  now hold real content and must **not** hold the placeholder sentence. The obligation is replaced,
  not dropped.
- A guard asserts `set(FILLED_RESERVED_HEADINGS) <= set(RESERVED_HEADINGS)`, so a typo in the
  filled set cannot silently exempt nothing while appearing to exempt something.
- The ordering, uniqueness, and heading-count tests are untouched, so the sibling sections' relative
  order and the sixteen-`##` layout are still enforced.

Verdict: this is the minimum necessary change. A narrower alternative — removing the assertion, or
pinning only two headings — would have deleted the protection F6 and F7 still depend on. Recorded
as compliant. One forward-looking note is filed as F8-I7.

## 10. Bundled-Mirror Parity (PASS)

Five files under `extensions/drm-copilot/resources/` were touched. Four are byte-identical mirrors,
verified by SHA-256 during this review:

| Source | Mirror | SHA-256 | Compelling parity test |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | `.../claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1` | `e88811ef…71cf5c` (identical) | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` |
| `.claude/settings.json` | `.../claude-customizations/.claude/settings.json` | `322fc04e…c20677` (identical) | same |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `.../claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | `c154616c…33e06` (identical) | same |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `3ebf24c9…6caab` (identical) | `test_poshqc_bundled_module_files_match_repo_root_sources` |

The fifth, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, is not
a mirror of a repo-root file; it is the pack manifest, and the one added line registers the new
hook path. It is compelled by
`test_bundled_claude_files_are_listed_in_some_pack_manifest`, which asserts every bundled `.claude`
hook appears in some manifest's `paths` union. `test_pack_manifests_are_outside_the_parity_scope`
confirms the manifest itself is deliberately outside the byte-identity scope, so no mirror
obligation attaches to it.

Every one of the five touched mirror files is therefore genuinely compelled by a named parity test.
No mirror was touched gratuitously, and none diverges from its source.

## 11. Fail-Closed Doctrine (PARTIAL)

Epic Shared Design item 7 requires the surface to fail closed. F8 honours this in most places and
the code documents each choice:

- `detect_escaped_paths` reports both paths of a rename independently, so either escaping is
  reported.
- `_observed_contends` returns `True` for a peer radius that cannot be parsed, because the
  contention relation reports no conflict for an empty radius and an unevaluable peer would
  otherwise look safe (`parallel_drift_detection.py:468-494`).
- `_existing_edge_pairs` omits an unreadable edge so a conflict over that pair is still reported as
  new (`parallel_drift_detection.py:442-465`).
- `_radii_by_item_key` omits an unreadable item, and `_is_drift_resolved` returns `False` for a
  missing radius, so absence means unresolved.
- `has_unresolved_drift` returns `True` on a malformed event log rather than propagating.
- `validate_drift_gate` emits one fail-closed error carrying the pure module's own refusal message
  when the log cannot be evaluated, and one error when a non-object entry left the gate inert for
  that entry, so a silently inert gate is impossible.
- The Layer-1 hook denies on a missing or unreadable checkpoint, an unresolvable target item, an
  unreadable event log, and a null `worktree_path`.
- `_parallel_drift_cli_io.checkpoint_items` **rejects** rather than filters a non-object item,
  because a silently dropped peer would never be evaluated against the observed radius.

Three fail-open paths remain and are filed as findings: F8-N3 (any `remediation-inputs.*.md` opens
the Layer-1 gate, including one written by an earlier unrelated remediation cycle), F8-N4 (ordinal
string comparison of two timestamps with no canonical-format contract can resolve drift spuriously),
and the consequence of F8-B1 (the gate has no documented release, which is fail-closed in the safety
direction but fails the liveness direction).

## 12. Directional Halt Rule (FAIL — see F8-B2)

The design rationale, the spec, and the user story all require the drifting item to be preserved.
The implementation implements the literal "later-started" rule without excluding the drifting item
from candidacy, so when the drifting item is the later-started member of a pair it is the item
halted. This is demonstrated by the feature's own tests. Full analysis is in
`code-review.2026-08-09T00-01.md` and the finding is F8-B2.

Partial credit where it is due: no code path selects an item *by virtue of drifting*.
`select_halted_item` receives two `ItemStart` markers and no drift information at all
(`parallel_drift_halt.py:167-195`), which is a genuine structural guarantee against inversion by a
caller, and `test_select_halted_item_is_total_and_order_independent_over_every_pair` asserts
argument-order independence across every pair of the marker matrix. The defect is the absence of a
drifting-item exclusion, not an inverted comparison.

## 13. Drift-Gate Release Path (FAIL — see F8-B1)

The Layer-2 invariant blocks merge progression while drift is unresolved, and resolution is derived
from the item's `blast_radius`. No code in the repository writes either resolving form, the CLI's
stdout payload does not carry an observed-radius block the parent could apply, and the SKILL.md
section documents the derivation without instructing any actor to perform the write. Full analysis
and remedy options are in `code-review.2026-08-09T00-01.md`; the finding is F8-B1.

## 14. Determinism (PASS for production, PARTIAL for tests)

Production: every timestamp entering a decision is a function input. The only clock read in the
feature is `default_timestamp()` at the CLI boundary (`parallel_drift_detection_cli.py:126-139`),
documented as such, and `test_default_timestamp_uses_the_repository_timestamp_shape` pins its
format. No pure module imports `datetime`, `random`, `subprocess`, `pathlib`, or `os`. The hook
runs no git command. `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls`
asserts field-by-field equality across two passes.

Tests: the cross-runtime seam test resolves `python`/`py` from the machine PATH via `Get-Command`
and spawns that interpreter as an external process. `.claude/rules/general-unit-test.md` prohibits
external processes in unit tests, and `.claude/rules/powershell.md` prohibits dependence on mutable
machine PATH state. No comparable precedent exists in the repository — a grep for
`Get-Command python`, `& python`, or `python -c` across `tests/scripts/` matches only this new file.
The deviation buys a genuine run-time cross-runtime binding, which the epic's producer/consumer
history makes valuable, so the finding is Non-blocking (F8-N8) rather than Blocking, but it must be
recorded as a justified exception rather than left as a silent rule breach.

## 15. Evidence-Location Compliance (PASS)

`python scripts/dev_tools/validate_evidence_locations.py --root .` exits **0**.

Scan of the branch diff for prohibited evidence paths — `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, `artifacts/coverage/` — returns **zero** files. All nineteen evidence
artifacts are written under the canonical `<FEATURE>/evidence/<kind>/` layout:

| Kind | Count |
| --- | --- |
| `evidence/baseline/` | 8 |
| `evidence/other/` | 2 |
| `evidence/qa-gates/` | 9 |

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record was required, because no delegation instruction
specified a non-canonical path.

## 16. Repo Tier Classification (UNVERIFIED — pre-existing gap)

`.claude/rules/quality-tiers.md` requires every project to be classified in `quality-tiers.yml` at
the repository root. That file does not exist. Verified pre-existing:
`git ls-tree c939b5b8 --name-only` returns no `quality-tiers.yml`, so the gap predates this branch
and is not attributable to F8. Consequence for this audit: the tier of the `scripts/dev_tools`
surface cannot be read from the source of truth, so tier-dependent gates are assessed against the
tier the rule file's own examples imply — T4, "dev tooling". Under T4 the property-test density
obligation is "none" and the mutation-score obligation is "none". The uniform coverage thresholds
are tier-independent and were verified directly. Recorded as F8-I1; remediation belongs to a
repository-level task, not to F8.

## 17. Tonality (PASS)

The SKILL.md section, all module and function docstrings, all validator error strings, and all
evidence artifacts use neutral, factual language. Error messages are literal and
context-prefixed, matching the existing validator style. No hyperbole, humour, or decorative
metaphor was found. One phrase warrants note for accuracy rather than tone: the SKILL.md's
"The drifting item is **never** halted by virtue of drifting" is a narrower claim than the spec's
"Halting the drifting item is not an option", and the narrowing is not flagged as a deviation — an
accuracy issue folded into F8-B2 rather than a tonality violation.

## Finding Register

| ID | Severity | Summary |
| --- | --- | --- |
| F8-B1 | Blocking | Derived resolution has no producer and no documented resolving write; the Layer-2 gate can permanently block an item's merge progression |
| F8-B2 | Blocking | Halt selection can select the drifting item, contradicting spec constraint 1 and a user-story AC |
| F8-N1 | Non-blocking | TypeScript Layer-2 drift-gate dispatch absent; divergence has no durable repo-level record |
| F8-N2 | Non-blocking | Layer-1 omission of resolution disjunct (a): residual risk accepted; recovery action not stated |
| F8-N3 | Non-blocking | Finding-presence check matches any `remediation-inputs.*.md`, so a stale finding opens the Layer-1 gate |
| F8-N4 | Non-blocking | Ordinal timestamp comparison with no canonical-format contract can resolve drift spuriously |
| F8-N5 | Non-blocking | No run-time binding between the documented CLI surface and the argparse implementation |
| F8-N6 | Non-blocking | Exported `has_unresolved_drift` takes two arguments, widening the reconciled IC-6a contract, unrecorded |
| F8-N7 | Non-blocking | Spec AC #7 check-off rests on the stub escape clause; no code appends a mutation or increments the generation |
| F8-N8 | Non-blocking | Cross-runtime seam test spawns an external `python` resolved from machine PATH, without a recorded exception |
| F8-N9 | Non-blocking | US-4 unchecked-disposition reason omits the "drifting item is never halted" clause |
| F8-N10 | Non-blocking | Hook and its test are each exactly 500 lines, leaving zero headroom |
| F8-I1 | Informational | `quality-tiers.yml` absent at repo root; pre-existing at the base commit |
| F8-I2 | Informational | PowerShell branch coverage not emitted by the toolchain; verified limitation |
| F8-I3 | Informational | Pre-existing `enforce-pr-author-skill.Tests.ps1` failure; correctly not edited |
| F8-I4 | Informational | Property-test obligation satisfied for the implied T4 tier |
| F8-I5 | Informational | Spec AC #11 names an H2 that does not exist; reconciled deviation |
| F8-I6 | Informational | Timestamp-naming inconsistency across the feature's own evidence artifacts |
| F8-I7 | Informational | `FILLED_RESERVED_HEADINGS` closing paren is a shared line for F6/F7 fan-in |
| F8-I8 | Informational | Layer-2 gate silently inert when `items` is absent or non-list |
| F8-I9 | Informational | Minute-granularity timestamps prevent same-minute satisfaction of disjunct (b) |

**Total Blocking: 2.**
