# Research: blast-radius over-reporting and zero-overlap tolerance (Issue #722)

- Timestamp: 2026-09-27T12-25
- Issue: #722 (bug, Work Mode full-bug)
- Branch: `bug/blast-radius-over-reports-and-zero-overlap-tolerance-722`
- Parallel run: `blast-radius-tolerance-2026-09-27` (preparation mode)
- Inputs read: `issue.md`, the template `spec.md` and `plan.2026-09-27T12-16.md` in this feature folder,
  `.claude/rules/parallel-orchestration.md`, the #452 spec (read-only), and the modules cited below.

## Method and evidence limits

- Every file and line citation below was read in the current tree of this worktree.
- This agent had no shell. The three historical manifests live only on plan-home refs, so they were
  read through `https://raw.githubusercontent.com/drmoisan/drm-copilot/parallel/<slug>-plan/docs/features/parallel/<slug>/parallel.md`
  (the repository is public). That tool passes the page through a summarizing model. For
  `followups-2026-09-27` the model returned the radius lists verbatim. For `backlog-2026-09-26` and for
  item #663 of `epic-655-followups` it elided some entries. Every manifest-derived count below
  therefore needs to be re-verified by P0 with `git show origin/parallel/<slug>-plan:docs/features/parallel/<slug>/parallel.md`.
  The pairwise enumeration for followups and backlog does cross-check against the recorded cohort
  assignment in the kickoff tables (see Q2), which is strong corroboration.
- The two kickoff files are gitignored and exist only in the main checkout
  (`artifacts/orchestration/parallel-kickoff-followups-2026-09-27.md`,
  `artifacts/orchestration/parallel-kickoff-backlog-2026-09-26.md`). No kickoff was found for
  `epic-655-followups`. The recorded `conflict_edges[]` of all three runs are gone: manifests do not
  carry edges (manifest invariants M1-M8, `.claude/rules/parallel-orchestration.md:112-144`), and the
  current `artifacts/orchestration/parallel-planner-state.json` belongs to this run (`parallel_slug`
  `blast-radius-tolerance-2026-09-27`, `conflict_edges: []`).

---

## Q1. Pipeline map, per runtime

### Python (authority)

| Stage | Function | Location |
| --- | --- | --- |
| Line partition | `scan_plan_lines` (task titles, phase titles, other lines) | `scripts/dev_tools/_blast_radius_extraction.py:165-209` |
| Token harvest | `extract_inline_code_tokens`: every backtick span, split on whitespace | `_blast_radius_extraction.py:212-240` (split at 238) |
| Token classification | `classify_path_token` | `_blast_radius_extraction.py:243-341` |
| Line scan | `extract_paths_from_lines` | `_blast_radius_extraction.py:344-375` |
| Plan extraction | `extract_plan_paths` scans task titles + phase titles + ALL other lines | `_blast_radius_extraction.py:378-413` (411) |
| Derivation | `derive_blast_radius`: plan paths + spec paths, mandate-read exclusion, feature glob, modules, surfaces, contracts | `scripts/dev_tools/compute_blast_radius.py:223-291` |
| Mandate-read filter | `matches_mandate_read` / `exclude_mandate_reads` | `scripts/dev_tools/_blast_radius_normalization.py:40-107` |
| Normalization of recorded radii | `normalize_declared_radius` (token-level only) | `compute_blast_radius.py:294-363` |
| Detection | `conflicts(a, b, config)` four disjuncts | `scripts/dev_tools/_blast_radius_conflicts.py:160-208` |
| Entry overlap primitive | `_entries_overlap`, `_literal_prefix`, `_prefixes_nest` | `scripts/dev_tools/_blast_radius_glob.py:207-316` |
| Mergeable exclusion | `exclude_mergeable_paths` applied only inside `conflicts` | `_blast_radius_conflicts.py:187-191`; `_blast_radius_mergeable.py:137-160` |
| Edge construction | **No library function.** The planner applies the relation to every unordered pair and records `{a, b, reason}` | `.claude/skills/parallel-plan/SKILL.md:314-318, 344`; `.claude/skills/parallel-add/SKILL.md:61-73` |
| Coloring | `compute_cohorts(item_keys, conflict_edges)` (Welsh-Powell) | `scripts/dev_tools/parallel_cohort_computation.py:350-416`; the module never evaluates `conflicts` (`:27-31`) |
| Drift recoloring input | `recompute_conflicts_with_observed` calls `conflicts(...).conflict` per in-flight peer | `scripts/dev_tools/parallel_drift_detection.py:271-338, 473-499` |

Token handling facts that produce the reported over-reporting:

- **Glob mentions are admitted.** A wildcard token is kept when it starts with a known top-level
  segment or ends in a recognized extension (`_blast_radius_extraction.py:330-341`). `**/models.ts`
  passes on the `.ts` extension. `.github/workflows/*.yml` passes on both rules. `tests/*` and `.claude/**`
  pass on the segment rule.
- **A leading-wildcard glob overlaps every entry.** `_literal_prefix("**/models.ts")` is `""`
  (`_blast_radius_glob.py:207-222`), and `_prefixes_nest("", x)` is always `True` (`:270`). So that
  single token overlaps every path of every other radius, including the other item's own feature-folder
  glob (`:305-316`). This is the mechanism behind the #716 fan-out.
- **Mandate reads do not remove glob citations.** A glob entry is excluded only on exact equality
  with a configured entry. It is never tested for containment (`_blast_radius_normalization.py:71-80`).
  `artifacts/orchestration/*.json` therefore survives even though `artifacts/**` is a mandate read
  (`config/blast-radius.json:25`).
- **`.github/copilot-instructions.md` is not a mandate read.** `mandate_reads` lists
  `.github/instructions/**` but not that file (`config/blast-radius.json:20-32`). As a concrete `.md`
  token it is accepted (`_blast_radius_extraction.py:324-325`).
- **Placeholder markers are rejected, but placeholder-looking paths are not.** Only `< > ${ $( %` are
  rejected (`_blast_radius_extraction.py:297-298`). `src/x.ts` has no marker, has an extension, and
  is accepted. The known-top-level-segment test applies only to wildcard tokens
  (`:324-331`). Feature-relative fragments such as `research/...md`, `evidence/other/follow-ups.md`,
  `qa-gates/...`, and `origin/main:scripts/...` are accepted for the same reason.
- **Multi-word inline spans are tokenized.** A command span such as `` `git add src/x.ts` `` yields
  the path token `src/x.ts` (`_blast_radius_extraction.py:234-238`).
- **Spec text contributes paths from every line** (`compute_blast_radius.py:268-272`), not only from a
  "files to change" section.

### PowerShell (destination runtime)

- Facade `.claude/lib/blast-radius/BlastRadius.psm1` imports six sibling modules (`:57-62`) and
  exports `Get-PlanPaths`, `Get-BlastRadius`, `Get-NormalizedDeclaredRadius`,
  `Get-BlastRadiusFromObservedPaths`, `Test-BlastRadius`, and `Test-BlastRadiusConflict` (`:432-438`).
- Detection: `Test-BlastRadiusConflict` (`BlastRadius.psm1:342-430`), with the mergeable filter at
  `:405-408`. It returns a hashtable that is always truthy (`:371-380`).
- Extraction constants are mirrored in `BlastRadiusExtraction.psm1` (`$script:KnownTopLevelSegment`
  at `:76`, `$script:RecognizedPathExtension` at `:88`).
- PowerShell has no edge-construction function. The planner loops pairs itself
  (`parallel-plan/SKILL.md:314-318`).

### bash

- `.claude/lib/bash/compute-cohorts.sh` is a pure coloring entry point over `--keys` and `--edges a:b`
  (`:1-26`, `:128-133`). It never sees radii, so the scheduling layer does not touch bash.
- No bash port of extraction or detection exists (`.claude/lib/bash/` holds cohort, manifest, YAML, and
  lane-assertion scripts only).

### TypeScript

- Push-down: `claude-blast-radius-derive-core.ts` publishes the destination truth table. It carries
  top-level keys verbatim only when they are listed in `CARRIED_KEYS` (`:132-139`), and it emits a
  fixed key order (`:369-377`). **Any new config key that is absent from `CARRIED_KEYS` is silently
  dropped from every destination.**
- Validator port: `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts:407-466`
  reads only `a`, `b`, and `reason` on each `conflict_edges[]` entry. There is no TypeScript port of
  extraction or detection.

### Insertion point for the scheduling layer

Detection (`conflicts` / `Test-BlastRadiusConflict`) stays byte-identical. A new pure function takes
the declared radii, the per-item complexity bands, and the config. It calls the unchanged relation on
each pair and then decides whether each conflicting pair becomes an edge. Edge construction becomes
library code, where today it is done by hand in the planner:

- Python: new `scripts/dev_tools/_blast_radius_scheduling.py`, re-exported from `compute_blast_radius.py`.
- PowerShell: new `Get-BlastRadiusConflictEdge` in a new `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`
  (or appended to `BlastRadiusConflict.psm1`, which has 291 lines, if it fits under 500).
- Consumers updated to call it: `parallel-plan/SKILL.md:314-318`, `parallel-add/SKILL.md:61-73`,
  `.claude/agents/parallel-planner.md:160-163`, and their bundled mirrors.

---

## Q2. Historical runs

### followups-2026-09-27 (11 items, #706-#716)

Recorded result: the kickoff cohort column (main checkout
`artifacts/orchestration/parallel-kickoff-followups-2026-09-27.md:21-31`) gives 8 cohorts:
`0{710} 1{713} 2{716} 3{707,714} 4{708} 5{712} 6{706,709} 7{711,715}`. `issue.md:27` states 46 of 55
pairs conflicted.

Reconstruction: I enumerated all 55 pairs against the manifest radii by hand, applying the rules
of `_entries_overlap` and `conflicts`. Nine pairs do not conflict: 706-709, 706-714, 707-714,
708-714, 709-714, 711-714, 711-715, 712-714, 714-715. That leaves 46 edges. I then ran the
Welsh-Powell procedure of `parallel_cohort_computation.py:266-347` by hand on those 46 edges. It
reproduces the recorded partition exactly: degrees 710/713/716 = 10, 707/708/712 = 9,
706/709/711/715 = 8, 714 = 3.

Edge classification (token that produced the edge; G = glob, P = placeholder or non-root fragment,
M = `.github/copilot-instructions.md`, S = shared surface `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`,
H = same concrete file cited by both):

| Class | Count | Pairs |
| --- | --- | --- |
| G only | 22 | 706-711, 706-712, 706-716, 707-711, 707-712, 707-716, 708-712, 708-716, 709-711, 709-712, 709-716, 710-711, 710-712, 710-716, 711-712, 711-713, 711-716, 712-713, 712-715, 712-716, 713-716, 715-716 |
| G + P | 2 | 710-714 (`src/x.ps1` vs `src/**/*.ts`), 713-714 (`src/x.ts` vs `src/**/*.ts`) |
| M only | 5 | 707-715, 708-715, 709-715, 710-715, 713-715 |
| G + P + module `config` | 1 | 708-711 (`research/research.2026-09-27T03-00.md` fragment in both, `tests/scripts/**`) |
| S (hard) + H + module + M | 10 | all pairs of {707, 708, 709, 710, 713} (708-710 also has contract `CodeCoverage.Path`) |
| H only (write or read not decidable from radius) | 6 | 706-707, 706-708, 706-710, 706-713 (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`); 706-715 (five `scripts/bash/*` files, `_shell-coverage.yml`); 714-716 (`extensions/drm-copilot/src/lib/pr-context/collector-core.ts`, genuine) |

The main glob sources are 716 `**/models.ts`, 711 `tests/scripts/**`, 712 `tests/*` and
`.github/workflows/*.yml`, and 714 `src/**/*.ts`. Plan context confirms that these are mentions, not
writes: `Glob **/models.ts` is a two-word span (`compare-code-point-helper-duplicated-716/plan.2026-09-27T00-23.md:312`).
`src/**/*.ts` sits in a read-only Prettier command and in the tsconfig `include` quotation
(`collector-core-no-whichgh-branch-untested-714/plan.2026-09-27T00-23.md:17-19`).
`.github/copilot-instructions.md` and `tests/shell/**` appear only inside "Read ..." tasks
(`cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/plan.2026-09-27T00-23.md:43-54`).

Projection (not verified; the executor must compute it): token-level rules (glob, root-anchoring,
mandate read) remove 29 of the 46 edges and make 708-711 a module-only soft pair. If the 6 H pairs
remain, the graph is 16 edges containing the 5-clique {707,708,709,710,713}, and greedy coloring gives
5 cohorts. The clique is a hard floor as long as all five radii keep `pester.runsettings.psd1`.

### backlog-2026-09-26 (5 items)

Recorded: kickoff cohorts `0{513,528,622} 1{588,594}` (main checkout
`artifacts/orchestration/parallel-kickoff-backlog-2026-09-26.md:21-25`). Reconstructed edges: 528-588
(`out/mcp-server.js`, `extensions/drm-copilot/package.json`), 528-594 (`.github/workflows/*` glob),
588-622 (shared `extensions/drm-copilot/src/lib/pr-context/*` files, genuine), and 594-622
(`scripts/dev_tools/pr_context/*.py` glob). That is 4 edges. Greedy coloring of these edges reproduces
the recorded partition. This matches `issue.md:36`: only 588-622 is real.

Projection: 1 edge. The cohort count stays at 2 (`{513,528,588,594}`, `{622}`), and the maximum
cohort width grows from 3 to 4. Acceptance evidence should therefore report edges and maximum cohort
width as well as cohort count.

### epic-655-followups (2 items, #660 and #663)

The manifest (`max_concurrency: 4`, created 2026-09-25T14:45Z) shows **both items with `.claude/settings.json`
in `shared_surfaces`**. #663 additionally carries `.claude/**`. So the single edge carries
`shared_surface_overlap` as well as the glob `path_overlap` that `issue.md:35` names. Under design
point 2 a shared surface is a hard edge at every tolerance. The run improves only if write-intent
extraction drops #660's citation of `.claude/settings.json`, which would be its read citation per
`issue.md:35`. Before: 1 edge, 2 cohorts. After: 0 edges and 1 cohort if #660's citation is
classified as a read; otherwise unchanged. #663 lists 159 entries, which the fetch summarized. P0
must read it verbatim.

### Fixture feasibility

The precedent is `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json`,
driven by `tests/scripts/dev_tools/test_blast_radius_verification_integrity.py:1-83`. That fixture
holds recorded radii, a pre-fix config, pinned radius sizes, and BEFORE/AFTER edges and cohorts. The
parity driver globs only the top level of `tests/fixtures/blast_radius/`
(`test_blast_radius_parity.py:174`), so a subdirectory is not auto-discovered.

- Proposed location: `tests/fixtures/blast_radius/historical-runs/{followups-2026-09-27,backlog-2026-09-26,epic-655-followups}.json`.
- Content per file: the recorded radii copied from the manifest, `complexity_band` per item (from
  the kickoff table), the pre-change config embedded, `EXPECTED_SIZES`, and before/after edges plus
  cohorts.
- Estimated size: followups ~50 KB (707 ≈ 150 paths, 713 ≈ 115, 710 ≈ 85, the other eight small),
  backlog ~30 KB (622 ≈ 156, 588 ≈ 121), epic-655 ~15 KB. JSON fixtures are test data and follow the
  verification-integrity precedent.
- Limitation: recorded radii support only the token-level rules (through `normalize_declared_radius`)
  and the scheduling layer. The line-context rules (command span, read task) need plan text. Those
  plans are on main, so the AFTER derivation for those rules must be an evidence artifact generated by
  a one-off script at a pinned commit. An automated test for them would need the plan text embedded
  (about 50 KB per plan, 16+ plans), which is not proposed.
- Tests must read only these committed fixtures and never `origin/*` refs or `artifacts/`.

---

## Q3. Configuration

- Self-hosted `config/blast-radius.json` keys: `version`, `shared_surfaces` (10), `shared_surface_globs` (3),
  `mandate_reads` (11), `mergeable_paths` (5), `modules` (7), `over_breadth_fraction` (`:1-50`).
- The second copy is the bundled payload
  `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` (`:1-36`): the same
  key set, a 6-entry portable `shared_surfaces`, an empty `shared_surface_globs`, and `modules` = `config` only.
- Partition gate: `BYTE_EQUAL_KEYS = (version, over_breadth_fraction, mandate_reads, mergeable_paths)`
  (`tests/scripts/dev_tools/blast_radius_parity_test_support.py:108-113`). Class 2/3 key names come
  from assertion registries (`:132-137`), and `DECLARED_TOP_LEVEL_KEYS` is their union (`:143-145`).
  The exhaustiveness test is `test_every_top_level_key_is_classified_and_shared_by_both_copies`
  (`test_blast_radius_config_parity.py:205-238`). The PowerShell mirror is
  `$script:ClassOneKeys` in `BlastRadius.KeyPartition.Tests.ps1:33`.

Recommended keys and what each requires:

| Key | Shape | Class | Absent-key behaviour | Committed value |
| --- | --- | --- | --- | --- |
| `write_intent_extraction` | boolean | 1 (byte-equal) | `false`: current extraction, byte-identical | `true` in both copies |
| `path_roots` | list of first path segments | 2 (bundled is `[]`) | no root-anchoring | self-hosted: this repository's tracked top-level directories (P0 derives them with `git ls-files`); bundled: `[]` |
| `conflict_scheduling` | object `{tolerance_percent:int>=0, weights:{same_file,possible_overlap,append_only,module}:int>=1, band_durations:{C1..C4}:int>=1, default_band, append_only_paths:[...]}` | 1 (byte-equal) | strict: `tolerance_percent = 0`, which reproduces today's edges | parallelism-leaning, for example `tolerance_percent: 100` |
| `mandate_reads` (amend) | add `.github/copilot-instructions.md` | 1 | n/a | both copies |

Absent keys default to the strict or current behaviour. This follows the repository convention for
optional keys (`parallel-orchestration.md:241-242, 280-281`). The committed copies carry the
parallelism-leaning value, which satisfies design point 3 ("defaulting toward parallelism") at the
configuration level. It also keeps every existing fixture, each of which embeds its own config, byte-identical.

Required edits for the new keys:

1. Both config copies.
2. Add `write_intent_extraction` and `conflict_scheduling` to `BYTE_EQUAL_KEYS`. Register
   `path_roots` in the Class 2 registry with a consuming test that asserts the bundled copy is empty,
   following `test_class_two_bundled_shared_surface_globs_are_empty` (`test_blast_radius_config_parity.py:273`).
   That test module has 500 lines, so the new test goes in a new module.
3. Mirror the same change in `BlastRadius.KeyPartition.Tests.ps1:33` (272 lines).
4. TypeScript: append the three keys to `CARRIED_KEYS` and to the document literal
   (`claude-blast-radius-derive-core.ts:132-139, 369-377`). Update the key-order assertions in
   `blast-radius-derive.test.ts:438-469` and `blast-radius-derive-mergeable.test.ts:114-146`. Update
   `SOURCE_BLAST_RADIUS` (`config-carriage.test-helpers.ts:88-127`), which
   `claude-config-carriage.test.ts:110-130` requires to stay in step with the bundled file. Add a
   carriage test modelled on `blast-radius-derive-mergeable.test.ts:98-146`.
5. Config readers with strict validation (reject booleans and zero weights) belong with their
   consumers, as `config_mergeable_paths` does (`_blast_radius_mergeable.py:60-79`).
   `_blast_radius_validation.py` (465 lines) and `BlastRadiusConfig.psm1` (474 lines) have no room.

---

## Q4. Deterministic write-intent rules

Signals that exist in the canonical plan format:

- Task lines match `PLAN_TASK_RE` (`_blast_radius_extraction.py:61-63`). The same regex text is used
  by `PLAN_GATE_TASK_RE` (`plan_gate_commands.py:20-22`), which already implements a task
  attribution window: a task line plus following non-task lines up to an ATX heading
  (`.claude/rules/plan-acceptance-gates.md`, "Attribution window").
- Task titles open with a verb. The corpus shows read forms (`Read ...`, `Verify ...`,
  `Baseline capture: confirm ...`) and write forms (`In \`path\`, ...`, `Write ...`, `Author ...`)
  (`cleanup-worktrees-bats-vacuous-t9-and-stale-citation-715/plan.2026-09-27T00-23.md:43-194`).
- Multi-word inline spans are commands or code samples. Paths are single-token spans.
- The bug spec template's "Files/modules to change" section
  (`extensions/drm-copilot/resources/feature-templates/bug/spec.md`) appears in **0** of the 11
  followups specs (Grep count). It is not a usable signal.

Proposed rule set (active only when `write_intent_extraction` is `true`; each rule is statically decidable):

- **W1 glob mention:** drop any harvested token containing `*` or `?`. The feature-folder glob is added
  afterwards and is never dropped (`compute_blast_radius.py:281`).
- **W2 command span:** drop every token of an inline span whose whitespace split has more than one word.
- **W3 read task:** drop tokens whose owning attribution window starts with a task title whose first
  word (after an optional bold label) is in a fixed read-verb set: `Read`, `Verify`, `Confirm`,
  `Inspect`, `Review`, `Baseline`. The set is a code constant pinned by a Python/PowerShell parity test,
  like the placeholder markers (`parallel-orchestration.md:320-330`).
- **W4 root anchoring:** drop a concrete token whose first segment (after stripping a leading `./`) is
  not in `path_roots` and is not a configured root surface. An empty or absent `path_roots` disables W4.
- **W5 spec paths:** in write-intent mode the spec contributes contracts only, not paths. The plan is
  what the executor writes from, and V1 checks plan coverage only.
- Mandate amendment: `.github/copilot-instructions.md`.

Rules W1, W4, and the mandate amendment are token-level. They also apply in `normalize_declared_radius`,
which is what makes the recorded-radius fixtures in Q2 usable. Rules W2, W3, and W5 need line context.
To preserve "a derived radius passes V1 against its own plan", derivation and `validate_blast_radius`
must select the same extractor from the same config flag, as the #452 root-surface plumbing does
(`compute_blast_radius.py:256-262`).

False-negative risks (the #452 class):

1. A genuine write stated only as a glob ("delete `tests/fixtures/old/*.json`").
2. A genuine write stated only inside a command span (`` `git mv a b` ``, `sed -i`).
3. A write stated only in preamble prose or in spec prose. Example: the only non-evidence file 714
   creates is named in its preamble (`collector-core-no-whichgh-branch-untested-714/plan.2026-09-27T00-23.md:15`).
   Rules W1-W5 keep preamble single-token paths, so that case survives. W5 would drop a write named
   only in the spec.
4. A read-verb task that also writes (for example "Verify and fix ...").
5. A new top-level directory created by the change (W4 drops it until `path_roots` is updated).
6. A placeholder quoted as file content inside a write task (`src/x.ps1` at
   `preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md:380`). W1-W3 miss
   it. Only W4 catches it, and only in this repository (the bundled `path_roots` is empty).

Mitigations, all existing and all to be restated in the rule file: the planner obligation to append a
genuine write explicitly (`parallel-orchestration.md:246-249`); `detect_escaped_paths` as the
execution-time backstop (`:252-255`); and the fail-closed absent key.

---

## Q5. Cost model and edge rule

Inputs are available per pair: the unchanged `ConflictResult` (verdict plus reason kinds), the two
radii, and the item bands (`complexity_band`, which is optional on planner items, P3 at
`parallel-orchestration.md:96`).

- **Hard:** the reasons include `shared_surface_overlap` or `contract_dependency`. This is always an
  edge (design point 2).
- **Cost (integers, computed only when `conflict` is true):**
  `cost = Σ over overlapping path pairs (after the mergeable exclusion) of w(pair) + weights.module × |modules_a ∩ modules_b|`.
  - `w = same_file` (e.g. 8) when both entries are concrete and equal, which approximates same-region
    or same-symbol edits (the radius has no line or symbol data).
  - `w = append_only` (e.g. 1) when the concrete path matches `append_only_paths` (registries, changelogs).
  - `w = possible_overlap` (e.g. 2) for glob or directory-prefix overlap (the #452 Gap 2 pairs).
  - Mergeable paths already contribute 0, because `conflicts` excludes them
    (`_blast_radius_conflicts.py:187-191`). The scheduling layer re-enumerates pairs with the same
    `exclude_mergeable_paths` and `_entries_overlap` (`_blast_radius_glob.py:273-316`), since
    `ConflictResult` reports only the smallest detail per kind (`_blast_radius_conflicts.py:211-240`).
- **Benefit:** `min(band_durations[band_a], band_durations[band_b])`, with C1=1, C2=2, C3=4, C4=8.
  A missing band uses `default_band`, which should be C1 (smallest benefit, the fail-closed direction).
  Running the pair concurrently saves at most one cohort step of the shorter item. This is a pairwise
  proxy for "cohorts saved × duration". The global cohort saving depends on the whole coloring and
  would make the edge set non-pairwise, so it is rejected.
- **Edge rule:** `edge ⇔ conflict ∧ (hard ∨ cost × 100 > benefit × tolerance_percent)`.
- **Recorded reason:** the first kind in `CONFLICT_KINDS` order (`_blast_radius_conflicts.py:56-61`).
  This keeps the F3 enum unchanged.

Proof that the strictest setting reproduces today's edges: every weight is validated `>= 1`, so any
`conflict = true` pair has a non-empty reason list (`_blast_radius_conflicts.py:132-133`). It is either
hard or has `cost >= 1`. With `tolerance_percent = 0`, `cost × 100 > 0` holds, so an edge exists iff
`conflict` is true, which is exactly today's rule. In general, `edge ⇒ conflict` for every tolerance,
so the new edge set is always a subset of today's. That monotonicity is what keeps #452 safe.

#452 cases (`docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/spec.md:353-372`).
The detection fixtures are **already on main**: `conflict-directory-vs-glob.json`,
`conflict-directory-vs-file.json`, `conflict-sibling-prefix-disjoint.json`,
`derivation-root-surface-reached.json`, and `derivation-root-surface-not-configured.json` (all tagged
`#452`, Grep). Every AC in that spec is checked except the PowerShell toolchain AC (`spec.md:668`). `conflict-shared-surface.json` is the hard
case (`poetry.lock`).

- Shared-surface case: hard at every tolerance.
- Directory-prefix fixtures: `conflict` is true, cost = `possible_overlap`, and they are an edge at
  `tolerance_percent = 0`.
- `conflict-sibling-prefix-disjoint.json` and `conflict-none-disjoint.json`: no edge.

A P0 detection step should list `tests/fixtures/blast_radius/`, grep for `#452`, and check for any
sibling-added fixture. The current branch name `bug/blast-radius-under-reporting-regression-452`
suggests a sibling item may add fixtures before this one merges. P0 should also confirm
`_directory_prefix` and `config_root_surfaces` are present. New scheduling fixtures should reference
these existing fixtures and must not modify them.

Enum and extra fields: `conflict_edges[].reason` is F3-owned (`parallel-orchestration.md:194-210`,
invariant 15 at `:72`). The Python validator reads only `a`, `b`, and `reason`
(`_parallel_state_structures.py:417-470`), and so does the TypeScript validator
(`parallel-state-structures.ts:407-466`). Only `mutations[]` rejects unexpected fields
(`_parallel_orchestrator_state_mutations.py:130-155`). So `cost`, `benefit`, and `hard` can travel as
tolerated-not-validated fields on edges, and soft pairs can be recorded in a tolerated
`tolerated_overlaps[]` list. This follows the `mergeable_conflicts_resolved` precedent
(`parallel-orchestration.md:307-316`). The enum stays unchanged.

---

## Q6. File-size budget and split decision

| File | Lines | Change |
| --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 475 | none (new module reuses its public helpers) |
| `scripts/dev_tools/compute_blast_radius.py` | 422 | derive/normalize flag branch, re-exports (~+20) |
| `scripts/dev_tools/_blast_radius_validation.py` | 465 | V1/V2 extractor selection (~+10) |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 257 | none |
| `scripts/dev_tools/parallel_drift_detection.py` | **500** | needs relief if touched (see Risks) |
| `scripts/dev_tools/parallel_cohort_computation.py` | 468 | none |
| new `_blast_radius_write_intent.py`, `_blast_radius_scheduling.py` | 0 | new |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 439 | flag branch + export (~+25) |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 475 | none |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 474 | none (no room) |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 375 | extractor selection |
| `.claude/lib/blast-radius/BlastRadiusConflict.psm1` | 291 | optionally hosts scheduling |
| new `BlastRadiusWriteIntent.psm1` (+ `BlastRadiusScheduling.psm1`) | 0 | new; each requires `pester.runsettings.psd1:174-185` + its bundled mirror + `pack-manifests/core.json:136-144` |
| `claude-blast-radius-derive-core.ts` | 381 | CARRIED_KEYS |
| `tests/scripts/dev_tools/test_blast_radius_config.py` | 500 | none possible |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | 500 | none possible |
| `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | 258 | key classes |
| `tests/scripts/dev_tools/test_blast_radius_parity.py` | 470 | fixture floor only |
| `BlastRadius.KeyPartition.Tests.ps1` / `.TruthTable.Tests.ps1` / `.Parity.Tests.ps1` | 272 / 392 / 410 | key classes |

Batch budgets: PowerShell allows 3 production and 3 test files per batch (`.claude/rules/powershell.md`,
Change Budget). Python has the same cap (`.claude/hooks/enforce-python-batch-budget.ps1:423-424`).
Every `.psm1` edit also needs its bundled mirror.

**Recommendation: split into two sequential plans under #722 (two PRs, not a parallel pair).** Both
plans write `config/blast-radius.json`, which is a shared surface, so they would serialize anyway.
Together they span about 6 Python, 5 PowerShell (+5 mirrors), 1 TypeScript, 2 config, and 8+ doc or
skill files.

- **Plan A: scheduling layer** (design points 2, 3, 4; the scheduling half of 5 and 6). Python
  `_blast_radius_scheduling.py`, PowerShell scheduling function, `conflict_scheduling` key (both
  copies, partition tests, TypeScript carriage), skill/agent doc updates, drift interaction,
  historical-run fixtures with BEFORE pins and strict-reproduction tests, and the #452 non-regression
  scheduling fixtures. Detection is unchanged. Strict equals today, provable and testable.
- **Plan B: write-intent extraction** (design point 1; the extraction half of 5 and 6; design point 7
  acceptance). W1-W5 in both runtimes, the `write_intent_extraction` and `path_roots` keys, the
  mandate amendment, new derivation fixtures, the historical-run AFTER pins, and the re-derivation
  evidence for all three runs.

Plan B's acceptance evidence uses Plan A's harness, so A lands first. Each plan amends only its own
section of the rule file, which preserves design point 5 in both.

---

## Q7. Rule file amendments

Amend `.claude/rules/parallel-orchestration.md`:

- Read-by-mandate (`:229-261`): add `.github/copilot-instructions.md`, and add W1-W5 as a new
  "Write-intent extraction" subsection with the false-negative list from Q4.
- The prohibition on hand-narrowing (`:134`, `:246-249`; also `parallel-plan/SKILL.md:238-255`):
  state that configured tolerance is not narrowing and that planners still never edit a radius to
  suppress an edge.
- A new "Integration-cost scheduling" subsection: the edge rule, the strict-equals-today proof, the
  hard-edge classes, soft pairs recorded as tolerated fields, and design point 4. Tie it to A7's
  per-edge barrier (`:182`).
- Enum Ownership (`:194-210`): record that no member is added and that `cost`, `benefit`, `hard`, and
  `tolerated_overlaps` are tolerated-not-validated.
- #500 section (`:429-464`): extend the list of byte-equal keys (`:433-434`) and name the `path_roots` class.

Mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
is kept content-identical by `test_push_down_claude_resource_contracts.py` (#452 spec `:230-235`).
**No `.github/instructions` mirror exists** (Glob on `**/*parallel-orchestration*` returns only those
two files and a research document).

Design point 4 wording: the existing protocol already syncs the later item with main by
`git merge origin/main` (`parallel-orchestrate/SKILL.md:374-389`) plus an `update-branch` re-green
cycle (`:369-372`). I recommend stating design point 4 as "the later item syncs with `origin/main`
under the existing Per-Item Merge-Conflict Handling and re-passes CI" rather than "rebase". A rebase
needs a force push, which I recall (from agent memory, not re-verified here) is blocked by a repository hook.

---

## Q8. Test infrastructure

- pytest: 13 `tests/scripts/dev_tools/test_blast_radius_*.py` modules; parity driver
  `test_blast_radius_parity.py` (`MINIMUM_FIXTURE_COUNT = 30` at `:60`); historical-pin precedent
  `test_blast_radius_verification_integrity.py`; drift tests `test_parallel_drift_detection*.py`.
- Pester: 14 files under `tests/scripts/claude-lib/blast-radius/`, including `BlastRadius.Parity.Tests.ps1`,
  `BlastRadius.KeyPartition.Tests.ps1`, `BlastRadius.Manifest.Tests.ps1`, and `BlastRadiusConflict.Tests.ps1`.
- bats: `tests/shell/parallel_cohorts*.bats`, `parallel_lane_assertion*.bats`,
  `parallel_payload_only.bats`, `parallel_bash_manifest_membership.bats`. None changes if bash is untouched.
- jest: `extensions/drm-copilot/test/lib/push-down/blast-radius-derive*.test.ts`,
  `claude-config-carriage.test.ts`, `claude-pack-manifest-completeness.test.ts` (the last one changes if a new `.psm1` is added).
- bats caveat: a helper that enables `set -u` aborts under the kcov PS4 trace, and only in CI
  (`tests/shell/test_cleanup_worktrees_scan_helper.bats:43, 72`; recorded in
  `cleanup-report-registration-lost-false-positive-706/code-review.2026-09-27T10-48.md:28`). It is
  relevant only if a bash file changes.
- CI's only Pester job is `.github/workflows/_poshqc.yml:10` (`windows-latest`). Pester path handling
  must be Windows-correct, and Linux-only failure modes do not apply.

Test strategy:

- Unit tests per rule (W1-W5, cost terms, benefit default, config reader rejections).
- Property tests (T2 obligation) for these properties: `edge ⇒ conflict`; strict equals conflict for
  random radii; monotonicity in `tolerance_percent`; symmetry.
- A Python/PowerShell parity fixture kind `scheduling-*`. The drivers need a third fixture kind; see
  `test_corpus_covers_both_fixture_kinds` at `test_blast_radius_parity.py:355`.
- Historical-run pins in both runtimes.
- Key-partition updates and the TypeScript carriage test.

---

## Q9. Risks

1. **Drift false halts.** A tolerated pair has no edge, so `recompute_conflicts_with_observed`
   (`parallel_drift_detection.py:323-337`) reports it as newly conflicting when either item drifts,
   and it halts the later item. Mitigation: treat recorded `tolerated_overlaps` pairs as known, or run
   the recomputation through the scheduling rule. The file has 500 lines, so this change needs a
   helper module.
2. **Hard edges from read citations of shared surfaces.** `pester.runsettings.psd1` (the followups
   clique) and `.claude/settings.json` (epic-655) are hard at every tolerance. The gain for those runs
   comes from W1-W5, not from tolerance. Consider adding `pester.runsettings.psd1` to `mandate_reads`,
   using the same dual-listing rationale as `quality-tiers.yml` (`parallel-orchestration.md:249-251`).
3. **Noisy contracts are hard.** Examples: 708 `allow`, `deny`, `new_string,`; 716 `package.json`,
   `index.ts`. These produce hard edges. Recommend recording this as a follow-up rather than widening scope.
4. **Silent destination fallback.** A missing `CARRIED_KEYS` entry silently turns destinations to
   strict or current behaviour.
5. **Under-reporting from W1-W5.** See the Q4 list. The backstop is the absent-key fail-closed
   default plus drift detection.
6. **Cohort count alone understates the change** (backlog stays at 2 cohorts). Report edges, cohort
   count, and maximum width.

---

## Numeric Derivation Evidence

Numeric claims proposed for spec ACs are limited to the recorded BEFORE cohort counts. Edge counts
(46, 4, 1) are **withheld** from spec ACs. Their only independent cross-check (the kickoff partition)
is a consistency check, not an independent enumeration of the edge member set. P0 must derive the edge
counts with Python `conflicts` and PowerShell `Test-BlastRadiusConflict` over the committed fixture,
compare the two member sets, and only then assert them.

**Claim 1: followups-2026-09-27 BEFORE cohort count = 8.**

- Complete Family: all current-generation cohorts of run `followups-2026-09-27`.
- Exhaustive Search Scope: all 11 item rows in the kickoff table
  (`parallel-kickoff-followups-2026-09-27.md:21-31`) and all 55 item pairs of the manifest radii.
- Inclusion Rules: every distinct cohort index with at least one member.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: read the kickoff table's `cohort` column row by row.
- Primary Member Set: {0:[710], 1:[713], 2:[716], 3:[707,714], 4:[708], 5:[712], 6:[706,709], 7:[711,715]}.
- Primary Count: 8.
- Cross-check Search Strategy or Query Expression: enumerate all 55 pairs by hand under
  `_entries_overlap`/`conflicts` semantics, then apply Welsh-Powell by hand
  (`parallel_cohort_computation.py:266-347`).
- Cross-check Member Set: {0:[710], 1:[713], 2:[716], 3:[707,714], 4:[708], 5:[712], 6:[706,709], 7:[711,715]}.
- Cross-check Count: 8.
- Member-set Comparison: identical partitions and identical index assignments.

**Claim 2: backlog-2026-09-26 BEFORE cohort count = 2.**

- Complete Family: all current-generation cohorts of run `backlog-2026-09-26`.
- Exhaustive Search Scope: all 5 kickoff rows (`parallel-kickoff-backlog-2026-09-26.md:21-25`) and all 10 pairs.
- Inclusion Rules: every distinct cohort index with at least one member.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: the kickoff `cohort` column.
- Primary Member Set: {0:[513,528,622], 1:[588,594]}.
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: pairwise enumeration (edges 528-588, 528-594,
  588-622, 594-622) plus Welsh-Powell by hand.
- Cross-check Member Set: {0:[513,528,622], 1:[588,594]}.
- Cross-check Count: 2.
- Member-set Comparison: identical. The cross-check relies on a summarized fetch of 588, 594, and
  622, so it must be re-verified at P0.

epic-655-followups: no kickoff is available locally. The count is withheld until P0.

---

## Automation Feasibility

The work can be fully automated with no human interaction:

- Every rule is a pure function over committed text.
- The plan-home manifests can be read with `git show origin/parallel/<slug>-plan:...` at P0. The
  fixtures are then committed, and tests read only those fixtures.
- The toolchains are runnable: pytest, Pester via PoshQC MCP, and jest. bats is not needed if bash is untouched.
- The operator has already approved the design (issue direction, 2026-09-27).
- The only judgment calls are the default weight and tolerance values. They are configuration, and
  the planner can fix them from the Q5 defaults.

## Rejected alternatives

- **Global benefit function** (cohorts saved computed over the whole coloring): rejected. The edge
  set would stop being pairwise, which breaks recoloring determinism.
- **New `reason` enum members** (such as `soft_overlap`): rejected. The enum is F3-owned, and
  tolerated fields suffice.
- **Changing `conflicts` or `Test-BlastRadiusConflict`:** rejected. It would violate the #452 detection invariant.
- **Spec "Files/modules to change" as the write-intent source:** rejected, because 0 of the 11
  followups specs contain that section.
- **Hardcoding `KNOWN_TOP_LEVEL_SEGMENTS` for W4:** rejected. It would drop genuine `src/` writes in
  destinations. The configured `path_roots`, empty in the bundle, avoids that.
