# Code Review — F1 Blast-Radius Library (Issue #447)

- Timestamp: 2026-08-07T17-32
- Branch: `feature/parallel-blast-radius-447`
- Base: `epic/parallel-orchestration-integration`
- Complexity band: C4 (epic's highest-risk child)
- Reviewer posture: adversarial and evidence-first. Executor claims were independently re-executed where re-execution was possible; where it was not, the claim is labelled as such.

## Overall Assessment

The implementation is of high quality and matches its approved specification closely. The design is genuinely pure, the two language implementations are demonstrably equivalent beyond the committed corpus, and the fail-closed reasoning in the contention relation is sound where it matters most. Coverage claims that could not be re-derived from the canonical artifacts were re-measured from scratch and reproduced exactly.

Eight findings are recorded. **None is Blocking.** Two are Major and share a single theme worth stating plainly: the derivation heuristic and the contention relation each contain one narrow path where they can under-report, and under-reporting is the failure mode the epic itself names as dominant (`epic.md:271`). Both are spec-conformant — the implementation did what it was told — so the correct disposition is a follow-up issue against the epic before F4 consumes this library, not a remediation cycle against #447.

## Independent Verification Performed

This review did not rely on the executor's self-report for anything that could be checked directly.

| Executor claim | How verified | Result |
|---|---|---|
| black / ruff / pyright clean | Re-ran all three | Confirmed: 345 unchanged, "All checks passed!", 0 errors |
| Python line 91.28% / branch 82.46% | Parsed `artifacts/python/lcov.info` independently | Confirmed exactly |
| Python per-module coverage | Parsed lcov per-file counters | Confirmed exactly (100/100/100/98.67 line) |
| PowerShell package 99.09% command / 99.27% line | Re-ran `Invoke-Pester` with coverage from scratch | Confirmed exactly, including the 5 missed commands and 3 missed lines |
| Pester emits no BRANCH counter | Inspected the canonical XML *and* a freshly generated one | Confirmed: only CLASS, INSTRUCTION, LINE, METHOD |
| Feature Pester suites green | Re-ran the 284-test feature scope | Confirmed: 284 passed, 0 failed |
| Feature Python suites green | Re-ran 7 suites + 2 mirror gates | Confirmed: 286 passed |
| Bundled mirrors byte-identical | MD5 over all 5 pairs + both `.psd1` copies | Confirmed |
| Exactly 3 append-only pre-existing edits | Full diff inspection | Confirmed |
| Workflow-doc diffs are checkbox-only | Mechanical pairing over the normalized diff | Confirmed, zero unpaired lines |
| Cross-language semantic parity | Built an independent differential harness (see below) | Confirmed: zero differences over 71 probe cases outside the corpus |
| ADJ-2 premise (`/` required) | Called `extract_plan_paths` directly | Confirmed: returns `()` |
| ADJ-2 mitigation (V2 still fires) | Called `validate_blast_radius` with a declared root-file radius | Confirmed: V2 Blocking emitted |

## Cross-Language Parity — Is It Genuinely Proven?

This was the review's central question, because a corpus can prove only what it contains, and a corpus back-filled from observed output proves nothing at all.

### Corpus provenance

The delegating prompt asked whether fixture `expected` values were spec-derived or back-filled from observed output. **Authorship cannot be established from the artifacts** — the corpus is uncommitted, so there is no per-file history to inspect, and no agent can prove its own derivation order after the fact. That question is therefore not answerable as posed, and this review declines to certify it either way.

The stronger and answerable question is whether the `expected` values are *correct against the spec*, independent of how they were produced. Sampled fixtures were hand-derived from the spec rules and compared:

- `derivation-basic.json` — the expected radius contains `docs/research/design.md`, harvested from a non-task "Guardrail:" prose line, which is required by `spec.md:41` ("Non-task plan lines are also scanned"). It contains `config/blast-radius.json`, harvested from the spec's `## Public API Contract` section, required by `spec.md:31`. Its `contracts` are exactly `["conflicts", "derive_blast_radius"]`: `internal_helper` is correctly excluded because it sits under `## Notes`, a non-qualifying heading, and `config/blast-radius.json` is correctly excluded from `contracts` because it contains `/`. Every value is independently derivable from the stated rules and every value is right.
- `conflict-glob-undecidable.json` — deliberately encodes an *incorrect but required* answer: `scripts/*/alpha.py` and `scripts/*/beta.py` are in fact disjoint, and the fixture asserts `conflict: true` with a description stating why the conservative test cannot prove it. A back-filled corpus would record whatever the code produced without that reasoning; this fixture records the spec's fail-closed clause and pins the over-reporting direction. That is evidence of spec-derivation, not proof, but it is the right shape.
- `validation-v3-at-threshold.json` — the description reasons about binary floating-point exactness (`0.25 * 12`) to justify why the boundary is not fuzzy in either language. That reasoning precedes an implementation choice (`covered <= threshold * tracked_file_count`, multiplication rather than division, `_blast_radius_validation.py:479-484`) rather than describing it.

**Assessment: the sampled `expected` values are spec-correct and the corpus reasons about spec intent rather than restating observed output.** Provenance is UNVERIFIED; spec-correctness is verified for the sampled subset.

### Corpus gap analysis by independent differential testing

Because corpus correctness does not establish corpus *sufficiency*, this review built a differential harness that exercises both implementations over inputs deliberately chosen to lie **outside** the committed corpus, and compared the outputs structurally.

Probe surface: 14 plan texts × 3 spec texts = 42 derived radii, plus 11 glob-match cases, 6 subsumption cases, 6 conflict pairs, 6 validation cases, and 1 observed radius — 71 comparison points, each asserting the full output shape.

Inputs targeted the rules most likely to diverge: URL-scheme tokens, absolute paths, `..` traversal, `?` wildcards, leading `**`, the extension-fallback acceptance rule with an unrecognized top-level segment, unrecognized extensions, CR-only line endings, CRLF, malformed task lines (`- [y]`), multi-token inline-code spans, `[abc]` character-class-shaped tokens, trailing `*`, uppercase extensions, empty input, nested-heading contract scoping (3 levels), and `Surface`-keyword headings.

Result:

```
NO DIFFERENCES across all probed cases.
```

**Assessment: parity is genuinely proven, not corpus-shaped.** The two implementations agree on 71 independently constructed cases none of which appear in the fixture corpus, including every documented edge rule. This is materially stronger evidence than the corpus alone provides, and it substantiates the executor's claim of semantic equivalence.

The parity suites are also structurally sound: both iterate the corpus by directory enumeration, both assert exact equality on the full expected block, and both carry an anti-vacuity floor (`MINIMUM_FIXTURE_COUNT = 12` / `$minimumFixtureCount = 12`) against a 21-file corpus, so a broken glob cannot yield a silently passing empty suite. Neither suite starts a process or writes a file.

### Documented parity hazards, and whether they hold

The PowerShell module headers document three deliberate divergences. Each was checked:

- `[regex]::Escape` versus `re.escape` escape different punctuation sets. Both produce literals for every character in the supported vocabulary; the probe's `bracket_glob` and `scripts/[abc].py` cases confirm identical behaviour in both languages.
- `\A...\z` versus `re.fullmatch`. `^`/`$` in .NET would additionally admit a trailing newline; `\A`/`\z` do not. Correct choice, correctly explained (`BlastRadiusGlob.psm1:29-31`).
- `-like` deliberately not used because its character-class semantics differ from fnmatch. Confirmed: `ConvertTo-GlobRegexText` translates explicitly and escapes `[`.

One additional divergence risk was checked and found handled: `ConvertTo-GlobRegexText` guards `**` detection with `$index + 1 -lt $Pattern.Length`, which correctly matches Python's `pattern.startswith("**", index)` at every position including a trailing single `*`.

---

## Findings

### F-01 — Major (non-blocking): `conflicts` ignores listed-directory semantics that V1 honours

**Location:** `scripts/dev_tools/_blast_radius_conflicts.py:219-224`; mirrored at `.claude/lib/blast-radius/BlastRadiusGlob.psm1:308-316`.

`is_path_subsumed` deliberately treats a wildcard-free entry as a listed directory covering everything beneath it:

```python
elif path.startswith(entry.rstrip("/") + "/"):
    return True
```
(`_blast_radius_extraction.py:491-492`)

`_entries_overlap` does not. A wildcard-free entry participates only in equality:

```python
if not a_is_glob and not b_is_glob:
    return entry_a == entry_b
```

**Consequence:** two radii that provably share files can report no `path_overlap`. Verified in both languages:

| Entry A | Entry B | `_entries_overlap` | Should overlap? |
|---|---|---|---|
| `scripts/dev_tools` | `scripts/dev_tools/foo.py` | `False` | Yes |
| `scripts/dev_tools` | `scripts/dev_tools/**` | `False` | Yes |
| `scripts/dev_tools/` | `scripts/dev_tools/foo.py` | `False` | Yes |

Confirmed for `Test-EntryOverlap` by the differential probe (conflict pairs 0 and 1, both `conflict: false` in both languages with `modules` held empty to isolate the path disjunct).

Directory-shaped tokens are reachable from derivation: `classify_path_token` accepts any token containing `/` that starts with a known top-level segment, with no requirement of a file extension. `spec.md` itself cites `tests/fixtures/blast_radius/`, which would be extracted as a concrete directory entry.

**This is spec-conformant.** `spec.md:118` states "Concrete×concrete: equality." The implementation did what it was told. But the spec's own V1 rule recognizes directory prefixes as a coverage form, so the library holds two different meanings for the same token depending on which function reads it, and the divergence resolves in the fail-open direction in a relation the epic requires to fail closed (`epic.md:113`).

**Practical exposure is bounded, not eliminated.** The `modules` disjunct is the backstop: the config module map is coarse (`scripts/dev_tools/**`, `tests/**`, `docs/**`, etc.), so in the common case both radii resolve to the same module and `conflicts` still returns `true` — with the wrong reason kind, but the right verdict. The backstop fails in two situations:

1. Paths under a top-level segment accepted by extraction but absent from the module map. `artifacts/` is exactly this: it is in `KNOWN_TOP_LEVEL_SEGMENTS` (`_blast_radius_extraction.py:71`) and has no `modules` entry. Two radii under `artifacts/` with a directory entry versus a file entry produce `conflict: false` with no reason at all.
2. Hand-authored or deserialized `declared` radii whose `modules` list is empty or narrow. F3 will deserialize radii from manifest frontmatter via `from_dict`, which takes `modules` at face value and does not recompute it.

**Recommendation:** extend `_entries_overlap`'s concrete branch to treat a wildcard-free entry as a directory prefix, matching `is_path_subsumed`. This is a pure widening (it can only add conflicts), so it is safe in the fail-closed direction and cannot break a downstream consumer that has not yet been written. It requires a `spec.md` amendment to `## Public API Contract`, mirrored changes in both languages, and one new corpus fixture. Fold into the same follow-up issue as ADJ-2.

### F-02 — Advisory: hand-rolled insertion sort with an unexercised, unreachable-from-outside branch

**Location:** `.claude/lib/blast-radius/BlastRadiusValidation.psm1:266-294`, uncovered line 291.

`Get-SortedRadiusFinding` reimplements `list.sort(key=(rule, subject))` as a stable insertion sort, correctly avoiding culture-sensitive `Sort-Object`. Line 291 (`$position -= 1`, the multi-slot backscan) is never executed, and this is one of the three uncovered PowerShell lines.

The reason is structural, not incidental: `Test-BlastRadius` appends V1 findings (over an already ordinal-sorted plan-path list), then V2 findings (over the sorted output of `Resolve-BlastRadiusSharedSurface`), then at most one V3 finding. The input is therefore always already fully ordered, and the backscan never runs more than zero steps. The sort is effectively inert given its current callers.

The function is not exported (`BlastRadiusValidation.psm1:361` exports only `ConvertTo-NormalizedBlastRadius` and `Test-BlastRadius`), so it cannot be unit-tested at the module boundary. The Python side carries no equivalent risk because it delegates to `list.sort()`.

**Risk:** latent. If a future rule appends findings out of order — plausible when F4 or F8 add a rule — the ordering guarantee that the parity corpus and downstream planner records depend on would rest on never-executed code. A defect there would surface as a silent cross-language ordering divergence.

**Recommendation:** either export `Get-SortedRadiusFinding` and add a direct test with a deliberately unsorted input, or add a validation scenario that produces genuinely out-of-order findings. Low cost, removes a latent parity risk. Note that the executor's own evidence artifact identifies this line individually and states the same cause (`evidence/qa-gates/final-powershell-test-coverage.2026-08-07T17-05.md:90`), which is good practice.

### F-03 — Advisory: `../` traversal tokens are accepted as repository paths

**Location:** `scripts/dev_tools/_blast_radius_extraction.py:243-246`.

`classify_path_token` rejects a leading `/` and rejects a `:` in the leading segment (URL scheme or Windows drive), but does not reject `..`. Verified:

```
extract_plan_paths("- [ ] [P1-T1] Touch `../outside/a.py`.")  ->  ('../outside/a.py',)
```

Identical in PowerShell (differential probe, `extract.dotdot`).

The token enters `paths`, resolves to no module, and inflates the V3 concrete-coverage numerator. It cannot match any repository file, so it errs wide — the fail-closed direction — and is not a safety defect.

Worth noting because the asymmetry is visible in the feature's own tests: the config-pinning test asserts that `shared_surfaces` entries contain no `..` (`plan.md` P3-T2), so the authors treated `..` as a correctness concern for configuration but not for extraction.

**Recommendation:** optional. If addressed, reject tokens whose first segment is `..` in both languages and add one corpus fixture.

### F-04 — Advisory: `?` is a wildcard to one rule and not to another

**Location:** `scripts/dev_tools/_blast_radius_extraction.py:266` versus `scripts/dev_tools/_blast_radius_validation.py:57-60`.

`classify_path_token` marks a token as a glob only when it contains `*`:

```python
if "*" in token:
    return PATH_KIND_GLOB
return PATH_KIND_CONCRETE
```

`is_glob_entry` counts both `*` and `?` (`GLOB_WILDCARDS = ("*", "?")`), and its own comment explains that admitting `?` "keeps every comparison in the fail-closed direction."

Verified: `classify_path_token("scripts/dev_tools/a?.py")` returns `"concrete"`, while `is_glob_entry` on the same string returns `True`.

Downstream behaviour is nonetheless correct and consistent, because `concrete_entries` filters on `is_glob_entry`, not on the classifier's verdict, so the entry is excluded from V2's surface resolution and from V3's file count as intended. Both languages agree (differential probe, `extract.qmark` and conflict pair 4). This is a naming and internal-consistency wart, not a behavioural defect.

**Recommendation:** optional. Reuse the single `GLOB_WILDCARDS` vocabulary in `classify_path_token` so the two rules cannot drift apart in future edits.

### F-05 — Advisory: PowerShell per-module coverage evidence not persisted

The canonical `artifacts/pester/powershell-coverage.xml` does not contain the five new modules, for the reason the executor documents and this review independently corroborated (installed extension v1.0.21 resolves pre-Phase-4 Pester settings; the XML's root counters are identical to baseline and its package list has no `.claude/lib/blast-radius`). The supplementary direct-run JaCoCo report that produced the claimed figures was written to a session scratchpad and is not retained.

This review closed the audit gap by re-measuring from scratch and reproducing every figure exactly, so no remediation is required for #447. Recorded so the practice changes: persist the direct-run report to `<FEATURE>/evidence/coverage/` when the MCP surface cannot measure new modules.

### F-06 — Advisory: pyright venv-resolution warning

`poetry run pyright` prints `venv .venv subdirectory not found in venv path c:\Users\...\agent-a2857bcb4458f15cf` before reporting `0 errors, 0 warnings, 0 informations`. Pre-existing worktree environment condition, not introduced by #447. The zero-error result should be read with that caveat.

---

## Design Quality

### Module decomposition — coherent, not incidental fragmentation

The delegating prompt asked whether the 500-line limit produced meaningful modules or arbitrary slices. **The Python decomposition is coherent; the PowerShell decomposition is coherent and arguably better than the Python one.**

Python, four modules along genuine seams:

| Module | Concern | Assessment |
|---|---|---|
| `compute_blast_radius.py` (321) | Data model + two derivation entry points + facade re-exports | Cohesive. The facade pattern means every consumer imports one module regardless of the split. |
| `_blast_radius_extraction.py` (494) | Text scanning: normalization, plan partitioning, token classification, contract extraction, glob translation, subsumption | Cohesive: everything that reads text or compares path patterns. |
| `_blast_radius_validation.py` (497) | Input guards, truth-table readers, module/surface resolution, V1–V3 | The weakest seam. It carries three concerns: caller-input guards (`require_text`, `require_str_tuple`, `require_mapping`), config readers, and the validation rules. |
| `_blast_radius_conflicts.py` (277) | `ConflictReason`, `ConflictResult`, `conflicts`, overlap primitives | Cohesive. |

PowerShell, five modules, with `BlastRadiusGlob.psm1` and `BlastRadiusConfig.psm1` split out as separate concerns. That is the cleaner cut: the glob module gathers exactly the pattern-comparison primitives that Python scatters across three files, and its header says so explicitly (`BlastRadiusGlob.psm1:6-13`).

One import-graph observation: `_blast_radius_conflicts.py` imports `matches_glob` from `_blast_radius_extraction` and `is_glob_entry`, `require_mapping`, `require_text` from `_blast_radius_validation`. A contention module depending on the validation module for glob and guard primitives is upside-down layering. It works (the facade re-exports everything and there is no cycle, since `_blast_radius_validation` does not import `_blast_radius_conflicts`), but the dependency direction reflects where lines fit rather than where concerns belong. The PowerShell layout does not have this problem.

**Assessment:** the split is justified and the seams are real. `_blast_radius_validation.py` at 497 lines and `_blast_radius_extraction.py` at 494 leave 3 and 6 lines of headroom respectively; the next change to either will force a split. Consider pre-emptively extracting the guard helpers (`require_text`, `require_str_tuple`, `require_mapping`) into a small `_blast_radius_guards.py`, which would both create headroom and correct the layering. Not required now.

### V1 / V2 / V3 severity assignment

| Rule | Severity | Assessment |
|---|---|---|
| V1 coverage | Blocking | Correct. An uncovered plan path means the declared radius does not describe what the item will touch, which is the epic's leading-indicator scenario. One finding per uncovered path, subject naming the path (`_blast_radius_validation.py:397-407`), so the planner report is actionable. |
| V2 shared-surface enumeration | Blocking | Correct. Glob coverage genuinely is insufficient: the enumeration is what the scheduler intersects, and a glob is not an element of `shared_surfaces`. |
| V3 over-breadth | Advisory | Correct. An over-broad radius is safe and merely serializes; making it Blocking would punish the fail-closed direction. At most one finding, subject `blast_radius.paths`. Boundary is exact (`covered <= threshold * tracked_file_count`, multiplication not division, `_blast_radius_validation.py:479-484`) so exactly-at does not trigger — verified in both languages by the probe (`v3_at` → `[]`, `v3_over` → one Advisory). |

### The V2 "union of radius paths and plan paths" deviation

`_shared_surface_findings` builds its touched set from the union of the radius's own concrete paths and the plan's concrete paths:

```python
touched_source = tuple(concrete_entries(radius.paths)) + tuple(plan_concrete)
```
(`_blast_radius_validation.py:429`)

The delegating prompt flags this as a deliberate deviation. **It is correct and it is fail-closed. It should be kept.**

Reading the spec literally — "a shared surface touched by the item" determined from the plan alone — would make V2 unenforceable in exactly the case it exists to catch. The user story's own V2 scenario is a plan that touches `pester.runsettings.psd1` while the radius covers it "only by a broad glob in `paths`" (`user-story.md:27`). Under a plan-only reading, that surface is in `plan_concrete` and V2 fires — so the plan-only reading handles the stated scenario. The union adds the complementary case: a `declared` radius that names a shared surface concretely in `paths` while the plan text does not (or cannot) mention it. Without the union that case passes silently.

That second case is not hypothetical. It is the only mechanism by which a repository-root shared surface such as `poetry.lock` can be validated at all, because plan-text extraction cannot see it (ADJ-2). Verified directly:

```
validate_blast_radius(radius=BlastRadius(paths=["poetry.lock"], shared_surfaces=[], ...),
                      plan_text="", config=CONFIG, tracked_file_count=100)
-> [RadiusFinding(rule="V2", severity="Blocking", subject="poetry.lock")]
```

Identical in PowerShell. The union is strictly widening — it can only produce more Blocking findings, never fewer — so it moves in the fail-closed direction, and it is what makes ADJ-2's residual risk survivable. Both languages implement it identically.

### Determinism and purity

Confirmed by inspection and by the probe's determinism cases. No wall-clock, filesystem, subprocess, or network access in any production module. All collections deduplicated and ordinally sorted at construction; `BlastRadius.__post_init__` normalizes regardless of construction route, including `from_dict` deserialization, so a radius rebuilt from manifest frontmatter carries the same invariant as a derived one. `from_dict` enforces an exact key set and rejects both missing and unexpected keys, with the rationale stated in-code (`compute_blast_radius.py:193-195`): a missing key would silently narrow a radius, an extra key would silently drop data, and both under-report.

`conflicts` symmetry is achieved rather than assumed: `_smallest_path_overlap` orders each pair before recording it and takes the minimum over an order-independent set (`_blast_radius_conflicts.py:248-260`), so the reported `detail` string is identical under argument swap, not just the verdict. The PowerShell mirror does the same with `[string]::CompareOrdinal`. This is a real correctness detail that a naive implementation would get wrong, and the symmetry invariant test would have caught it.

### PowerShell sibling `Import-Module` at load time

`BlastRadius.psm1:54-57` imports its four siblings with `-Force` at module load. Assessed against the `.claude/lib/orchestrator-state/` precedent, which uses the same composition pattern for the same reason (the 500-line limit). **Acceptable.**

One practical consequence observed during review, worth recording for future maintainers: because the facade re-imports siblings with `-Force`, a caller that imports a leaf module *before* importing the facade loses its own binding — `-Force` unloads and reloads the module into the facade's session state. This review hit it directly (`Test-GlobMatch` became unresolvable) and worked around it by importing the facade first. The Pester suites import in an order that avoids the problem, so no test is affected, but a downstream F7 hook that imports `BlastRadiusGlob.psm1` directly and then `BlastRadius.psm1` would be surprised. A one-line note in the facade's "Parity notes for maintainers" block would prevent that.

### Test quality — are the invariants meaningful or tautological?

Reviewed `tests/scripts/dev_tools/test_blast_radius_invariants.py` in full and the Pester mirror. **The invariants are meaningful, with one partial exception.**

| Invariant | Assessment |
|---|---|
| Conflict symmetry (verdict) | Meaningful but weak in isolation — set intersection is inherently symmetric. |
| Conflict symmetry (reason sequence) | **Strong.** Asserts the full `reasons` tuple including `detail` strings under argument swap. This is exactly the property that required the deliberate pair-ordering and min-selection design; a natural first-match implementation would fail it. Not a tautology. |
| Monotonicity | **Meaningful.** Two directions are tested: widening a conflicting pair keeps the conflict (`test_widening_a_radius_never_removes_a_conflict`), and widening a disjoint radius toward the other creates one (`test_widening_a_disjoint_radius_can_only_create_a_conflict`, which asserts `False` before and `True` after). The second is the stronger of the pair and is not tautological. |
| Self-conflict | Weakest. A radius with a non-empty level conflicting with itself follows almost directly from intersection semantics. It does have value as a regression tripwire for the empty-versus-empty special case. Spec-named, so its presence is correct even though its discriminating power is low. |
| Determinism / order independence | **Meaningful.** `PLAN_A` and `PLAN_B` carry the same two tasks in swapped order and must produce equal radii — this exercises the sort-and-dedupe invariant against a real perturbation, not a repeated call. The repeated-call variant additionally asserts `to_dict()` equality. |
| V1 self-consistency | **Strongest.** Parametrized over 5 plans including empty and prose-only, asserting a derived radius emits no V1 finding against its own plan. This directly proves the shared-extraction-function property that `spec.md:44` requires, and it would break immediately if derivation and V1 ever diverged. |
| V2 self-consistency | Meaningful, and beyond what the spec required. Proves derivation enumerates every shared surface its own plan touches. |

Choosing `pytest.mark.parametrize` matrices over `hypothesis` is correct given the no-new-dependency constraint (`user-story.md:57`), and the matrices are genuinely parametrized (10 radius pairs, 5 non-empty radii, 4 additions × 2 directions, 5 plans) rather than a single case wearing a decorator.

**Gap:** no invariant asserts the property F-01 violates — that two radii sharing a concrete file must report `path_overlap`. A property of the form "if `is_path_subsumed(p, a.paths)` and `is_path_subsumed(p, b.paths)` for some concrete `p`, then `conflicts(a, b)` includes `path_overlap`" would have surfaced F-01 immediately. Recommend adding it alongside the F-01 fix.

### Configuration

`config/blast-radius.json` matches the spec shape exactly: `version: 1`, the ten-entry `shared_surfaces` list, three `shared_surface_globs`, the fourteen-module map, `over_breadth_fraction: 0.25`. Presence of each configured surface was checked against the working tree — nine of ten exist; only `quality-tiers.yml` is absent, exactly as `spec.md:177` documents as a deliberate forward-looking entry. The deviation from design §5.1 (module resolution from the config map rather than `quality-tiers.yml`) is recorded in `spec.md` `### Deviation from design §5.1` with four substantive reasons and leaves issue #336 independently resolvable. Both language suites pin the config shape, so the two implementations and the truth table cannot drift.

## Summary of Recommendations

| Priority | Recommendation |
|---|---|
| Before F4 begins | File one follow-up issue against the epic covering ADJ-2 (separator-free root surfaces) and F-01 (directory-entry overlap). Both are spec-conformant under-reporting paths in the mechanism the epic names as its dominant risk. |
| Before F4 begins | Add the "shared concrete file implies `path_overlap`" invariant test alongside the F-01 fix. |
| Low | Export or otherwise exercise `Get-SortedRadiusFinding`'s multi-slot backscan (F-02). |
| Low | Reuse `GLOB_WILDCARDS` in `classify_path_token` (F-04); reject `..` first segments (F-03). |
| Low | Extract Python guard helpers to create headroom under the 500-line limit and correct the `_blast_radius_conflicts` → `_blast_radius_validation` layering. |
| Low | Persist direct-run PowerShell coverage reports to `<FEATURE>/evidence/coverage/` (F-05). |
| Low | Note the facade's `-Force` sibling-import side effect in the maintainer parity block. |

**Blocking findings: 0.**
