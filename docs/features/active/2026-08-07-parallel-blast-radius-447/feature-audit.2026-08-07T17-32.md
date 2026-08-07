# Feature Audit — F1 Blast-Radius Library (Issue #447)

- Timestamp: 2026-08-07T17-32
- Branch: `feature/parallel-blast-radius-447`
- Base: `epic/parallel-orchestration-integration`
- Work mode: `full-feature` (`issue.md:10`)
- AC sources: `spec.md` `## Acceptance Criteria` (14 items) and `user-story.md` `## Acceptance Criteria` (8 items)
- Companion artifacts: `policy-audit.2026-08-07T17-32.md`, `code-review.2026-08-07T17-32.md`

## Verdict

**ACCEPT. Blocking findings: 0.**

All 22 acceptance criteria across both sources are PASS. Both open adjudications are ruled below. Two Major non-blocking findings are recorded and routed to a follow-up issue against the epic; neither fails an acceptance criterion, because in both cases the implementation matches the approved specification and the gap is in the specification's scope rather than in the code that implements it.

---

## Adjudication 1 — PowerShell Branch Coverage (spec AC11, user-story AC8)

### Question referred

`spec.md` AC11 and `user-story.md` AC8 both require branch coverage >= 75% for every new module in **both** languages. Pester 5.x emits no BRANCH counter. Is command coverage an acceptable proxy, in which case the two AC may be checked, or does this require separate adjudication or remediation?

### Facts established independently

1. **The counter set is a Pester capability limit, not artifact staleness.** `artifacts/pester/powershell-coverage.xml` contains exactly `CLASS`, `INSTRUCTION`, `LINE`, `METHOD`. This review additionally generated a **fresh** JaCoCo report from a new `Invoke-Pester` run in this worktree; it contains the identical four counter types and no BRANCH counter. The metric is not obtainable from the mandated toolchain.
2. **The proxy figures are real.** Re-measured from scratch rather than accepted on report:
   ```
   TESTS total=284 passed=284 failed=0 skipped=0
   COMMANDS analyzed=547 executed=542 missed=5
   COMMAND_PCT=99.09
   ```
   Package aggregate: INSTRUCTION 542/547 = 99.09%, LINE 409/412 = 99.27%, METHOD 42/42, CLASS 5/5. Per-module minimum line coverage 96.84% (`BlastRadiusValidation.psm1`). Every figure reproduces the executor's claim exactly, including the identity of the 5 missed commands and 3 missed lines.
3. **The five uncovered commands are individually named and benign.** Two are `throw` invariant guards in `New-RadiusFinding` for out-of-vocabulary `Rule`/`Severity` values that no production caller can supply; one is the multi-slot backscan step of the finding insertion sort. None is a behavioural branch of the derivation, validation, or contention logic.
4. **The metric is equally absent at baseline** (`evidence/baseline/baseline-powershell-test-coverage.2026-08-07T14-17.md`), so checking these AC conceals no regression.
5. **The executor did not overstate.** `evidence/qa-gates/coverage-delta-verification.2026-08-07T17-06.md:114-118` records the gap as an explicit tooling-capability declaration rather than substituting a passing value — the correct posture under `.claude/rules/tonality.md` evidence-first wording.

### Ruling

**Command coverage is an acceptable proxy for the PowerShell branch clause in this instance. Both AC may be checked, and this review checks them.** The underlying policy conflict is Advisory severity, owned by the repository rather than by #447.

### Reasoning

The proxy is defensible here for a specific reason, not because 99.09% is a large number. In Pester's JaCoCo output the INSTRUCTION counter counts each executable command, and a branch arm that contains at least one command is counted as covered only if that arm actually executed. At 99.09% with all five uncovered commands enumerated by name and each shown to sit in a guard or a sort backscan, the statement "every reachable behavioural branch arm in the new modules was executed" is supported by the enumeration itself, not merely inferred from the aggregate.

The proxy has one real limitation, and this review tested against it rather than around it. An `if` with no `else` contains no commands in its implicit false arm, so an INSTRUCTION counter cannot detect an unexercised false path. That limitation would matter most in the fail-closed comparison logic, where a missed false path is precisely the kind of defect that produces silent under-reporting. Both languages' false paths in that logic were therefore verified behaviourally rather than by counter:

- `Test-EntryOverlap` returns `False` in the differential probe for `scripts/a*` versus `scripts/b*` (provably disjoint) and `True` for `a/**` versus `**/b` (undecidable, fail closed) — both outcomes of the branch exercised.
- `Test-PathSubsumed` returns `False` for `scripts/*` against a nested path and for an empty covering collection, and `True` for exact match, trailing-slash directory, bare directory, and `**` glob — all four rules plus both false paths exercised.
- `Test-BlastRadius` produces the empty finding list for `v2_enumerated` and `v3_at`, and non-empty lists for `v1_uncovered`, `v2_glob_only`, `v2_rootfile_declared`, and `v3_over` — both outcomes of each rule's decision exercised.

Command coverage is an upper bound on branch coverage, not an equivalent. For the modules where an unexercised false arm would be a safety defect, this review closed that gap with direct behavioural assertions in both languages. The AC's intent — that the new modules are thoroughly exercised, including their decision logic — is satisfied on the available evidence.

### Severity of the underlying policy conflict

**Advisory, repository-scoped, not chargeable to #447.** `.claude/rules/quality-tiers.md` mandates branch coverage >= 75% uniformly across T1–T4, while `.claude/rules/powershell.md` mandates a Pester-based toolchain that cannot produce the metric. Every PowerShell feature in this repository has silently occupied this position; #447 is the first to state it explicitly with numbers rather than passing over it. That is an improvement in evidence quality, not a defect introduced here.

**Recommended follow-up (separate issue, not a #447 remediation):** amend `.claude/rules/quality-tiers.md` to either (a) scope the branch clause to languages whose mandated toolchain emits it and name command/instruction coverage as the designated PowerShell substitute with its stated limitation, or (b) adopt a PowerShell coverage tool that emits branch data. Option (a) is the lower-cost path and would make future PowerShell audits deterministic instead of requiring a per-feature adjudication.

---

## Adjudication 2 — Radius Under-Reporting for Separator-Free Repository-Root Shared Surfaces

### Question referred

`classify_path_token` requires a `/`, so a repository-root file with no path separator can never be extracted from plan or spec text. Three of the ten configured `shared_surfaces` are separator-free: `poetry.lock`, `package-lock.json`, `quality-tiers.yml`. Is this acceptable as designed, or Blocking?

### Facts established independently

1. **The premise is correct.** `_blast_radius_extraction.py:243`:
   ```python
   if "/" not in token or token.startswith("/"):
       return None
   ```
   Direct call:
   ```
   extract_plan_paths("- [ ] [P1-T1] Touch `poetry.lock` and `package-lock.json` and `quality-tiers.yml`.")
   -> ()
   ```
   `classify_path_token` returns `None` for all three, and also for `pyproject.toml` and `README.md`. Identical in PowerShell (differential probe).
2. **It matches the approved spec.** `spec.md:42` defines the rule as "accept a token as a concrete repository path when it contains `/` and ...". This is not implementation drift.
3. **The executor's mitigations are real, both verified directly.**
   - V2 fires when the radius itself names the surface. `validate_blast_radius` on a radius with `paths=["poetry.lock"]`, `shared_surfaces=[]`, and empty plan text returns `[V2 / Blocking / poetry.lock]` in both languages. This works because `_shared_surface_findings` builds its touched set from the union of the radius's concrete paths and the plan's concrete paths (`_blast_radius_validation.py:429`).
   - `radius_from_observed_paths` takes paths verbatim without re-classification (`compute_blast_radius.py:292`). Probe result: observed paths `["poetry.lock", "quality-tiers.yml", "scripts/dev_tools/validate_x.py", "docs/a.md"]` resolve to `shared_surfaces = ["poetry.lock", "quality-tiers.yml", "scripts/dev_tools/validate_x.py"]`. The F8 drift-detection path is unaffected.
4. **The blind spot is precisely one path**: plan text names a root-level shared surface, and the declared radius omits it. V1 cannot flag it (the path is not extractable, so there is nothing to check), and V2 cannot flag it (the surface is in neither the radius nor the extracted plan set).

### Ruling

**Acceptable as designed for F1. Not Blocking. Recorded as a Major non-blocking finding with a mandatory follow-up issue that must be resolved before F4 lands.**

### Reasoning — the real risk, stated precisely

The residual exposure is narrower than "radius under-reporting" in general, and it is worth being exact about where it bites.

**What is not at risk.** The contention relation itself is fail-closed for these surfaces: given a radius that names `poetry.lock`, `conflicts` reports `shared_surface_overlap`. F3 is unaffected — it serializes whatever shape it is given. F8 is unaffected and is in fact the compensating control, since `radius_from_observed_paths` sees root-level files perfectly. The epic's Shared Design item 7 constrains the *contention relation*, and the relation satisfies it.

**What is at risk.** The gap is upstream of the relation, in derivation, and it lands on F4. `spec.md` §5.2 designates `declared` as "planner-computed from the approved atomic plan, authoritative for scheduling," and F4's job per the epic dependency table (`epic.md:132`) is to call radius derivation and V1–V3 validation. If F4 computes the declared radius by calling `derive_blast_radius` and stamping the result, the blindness propagates directly into the authoritative scheduling radius. Two items whose plans both say they will append to `poetry.lock` would then produce declared radii that omit it, `conflicts` would report no `shared_surface_overlap`, and the scheduler would co-schedule them. A concurrent lockfile append is not a merge-friendly outcome, and `poetry.lock` was placed in the truth table precisely because it is a high-contention artifact.

**Why this is nonetheless not Blocking against #447.** Three reasons, in order of weight:

1. The implementation matches the approved specification exactly. `spec.md:42` was reviewed and approved with this rule. Charging the executor with a Blocking defect for implementing the spec correctly would be wrong, and would set the precedent that an approved spec is not a defence.
2. The compensating controls are real and were verified working, not asserted. V2 catches the case whenever the radius names the surface; F8 catches the case at pre-review commit regardless. The window is plan-time-only, and it closes at execution time.
3. F1 has no callers. `spec.md:259` records that the library is inert until F3/F4/F8 land. There is no live scheduling decision that this gap can currently corrupt, so the correct instrument is a scheduled fix ahead of F4, not a remediation cycle that delays a wave-0 foundation with no consumers.

**Why it must not be closed silently.** This is exactly the §13.1 under-reporting failure mode the epic names as dominant (`epic.md:271`), affecting exactly the artifacts the design singled out as high-contention. Accepting it without a tracked follow-up would let the epic's most-cited risk enter the codebase unrecorded.

### Recommended remediation for the follow-up issue

Two options, with a preference:

- **(a) Preferred — extend the classifier.** Accept a separator-free token when it matches an entry in the config `shared_surfaces` list. This is a pure widening: it can only add paths and therefore only add findings and conflicts, so it moves in the fail-closed direction and cannot break an unwritten downstream consumer. It adds no dependency, keeps the rule in F1 where the two languages are already pinned together by the fixture corpus, and requires one `spec.md` amendment plus one new fixture.
- **(b) Alternative — push to F4.** Require the planner to union the derived radius with any config `shared_surfaces` entry appearing as a literal substring of the plan text. Workable, but it splits one rule across two features and two languages, and it leaves `derive_blast_radius` blind for every other caller.

Option (a) is recommended. Bundle finding F-01 (directory-entry overlap, see `code-review.2026-08-07T17-32.md`) into the same issue — both are narrow under-reporting paths in the same subsystem, both require a `spec.md` amendment plus mirrored two-language changes plus a fixture, and fixing them together costs materially less than fixing them separately.

---

## Acceptance Criteria — `spec.md` (14 items)

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | `compute_blast_radius.py` implements the four-level model, three sources, and the five documented functions with frozen contract literals | PASS | All five exported in `__all__` (`compute_blast_radius.py:59-69`) with the documented signatures. `RADIUS_KEYS`, `RADIUS_SOURCES`, `CONFLICT_KINDS`, `FINDING_RULES`, `FINDING_SEVERITIES` are named constants. `to_dict`/`from_dict` round-trip tested. |
| 2 | Derivation follows §5.3: plan tasks + spec inline code, feature folder appended, modules from config, surfaces from list and globs, contracts from interface headings, CRLF/CR normalization, plan-contract regexes | PASS | `derive_blast_radius:245-263`. `PLAN_PHASE_RE`/`PLAN_TASK_RE` text verified character-identical to `validate_orchestration_artifacts.py`. CRLF and CR-only inputs verified in both languages by differential probe (`extract.crlf`, `extract.cr_only`). Nested contract-heading scoping verified over 3 heading depths. |
| 3 | V1/V2/V3 with the documented severities, cardinalities, and (rule, subject) sort | PASS | `_blast_radius_validation.py:342-497`. Probe: `v1_uncovered` → one V1/Blocking naming the path; `v2_glob_only` → V2/Blocking; `v3_over` → one V3/Advisory; `v3_at` → empty. Identical in PowerShell. |
| 4 | `conflicts` implements the four disjuncts, fails closed on glob×glob not provably disjoint, returns all triggered kinds in fixed order | PASS | `_blast_radius_conflicts.py:137-177`. Glob×glob soundness proven in `policy-audit.2026-08-07T17-32.md` §16 and confirmed empirically. `ConflictResult.__post_init__` enforces the fixed kind order at construction. Finding F-01 concerns wildcard-free directory entries, which this criterion does not cover — its fail-closed clause is explicitly scoped to glob×glob. |
| 5 | Derivation and V1 share one extraction function per language; a derived radius passes V1 against its plan, proved by an invariant test in both languages | PASS | `extract_plan_paths` is called by both `derive_blast_radius:251` and `validate_blast_radius:368`. `test_a_derived_radius_passes_v1_against_its_own_plan` parametrized over 5 plans; Pester mirror present. |
| 6 | `BlastRadius.psm1` provides the five-function parity surface with identical keys and values, ordinal sorting, authoritative-reference header | PASS | `Export-ModuleMember` (`BlastRadius.psm1:368-373`) lists exactly the five. Header states the Python module is authoritative and the mirror never imports validator logic (`:20-22`). Ordinal comparison verified throughout. Value parity verified over 71 independent probe cases. |
| 7 | `config/blast-radius.json` has the documented shape including the forward-looking `quality-tiers.yml`; both suites pin it | PASS | Config read and compared to `spec.md` `## Configuration` field by field. 9 of 10 surfaces exist in the tree; only `quality-tiers.yml` is absent, as documented. `test_blast_radius_config.py` and `BlastRadiusConfig.Tests.ps1` both pin the shape. |
| 8 | Module resolution uses the config `modules` map; the §5.1 deviation is recorded in `spec.md` | PASS | `resolve_modules` reads `config["modules"]` only (`_blast_radius_validation.py:283-308`). Deviation recorded at `spec.md:204-227` with four reasons and an explicit note leaving issue #336 independently resolvable. |
| 9 | Fixture corpus at `tests/fixtures/blast_radius/` including CRLF and glob-undecidable fixtures; both parity tests iterate every fixture | PASS | 21 fixtures present including `derivation-crlf.json`, `derivation-cr-only.json`, `conflict-glob-undecidable.json`. Both suites enumerate the directory and carry a 12-fixture anti-vacuity floor. |
| 10 | Parametrized invariant tests pass in both languages; `hypothesis` not added | PASS | `test_blast_radius_invariants.py` (264 lines) plus the Pester mirror; all five named invariants present. No dependency-manifest change in the diff. Test-quality assessment in `code-review.2026-08-07T17-32.md`. |
| 11 | Line >= 85% and branch >= 75% for every new module in both languages; `CodeCoverage.Path` appended with an issue #447 comment | **PASS** | Python: 100/100/100/98.67% line, 100/100/100/96.88% branch — independently parsed from `artifacts/python/lcov.info`. PowerShell line: 100/100/100/100/96.84% — independently re-measured. PowerShell branch: ruled PASS by proxy under ADJ-1 above. Both `.psd1` copies carry the five entries under an issue #447 comment and are byte-identical (MD5 `415ead9d...`). |
| 12 | No production, test, or reusable script file exceeds 500 lines | PASS | Maximum 497 (`_blast_radius_validation.py`). Full table in `policy-audit.2026-08-07T17-32.md` §1. |
| 13 | `atomic-plan-contract/SKILL.md` unchanged; no existing epic implementation modified; only the three named append-only edits; new `.claude/**` files mirrored byte-identically | PASS | `git status --porcelain .claude/skills/atomic-plan-contract/` empty; `git diff <base> --name-only -- .claude/skills/` empty. Exactly three pre-existing non-workflow files modified, all pure additions. All five mirrors MD5-identical. Both repository parity gates re-run and green. |
| 14 | The library is pure: no filesystem, subprocess, network, or wall-clock reads; `computed_at`, `tracked_file_count`, observed paths caller-supplied | PASS | Verified by source inspection of all nine production modules. Detail in `policy-audit.2026-08-07T17-32.md` §5. |

**spec.md: 14 of 14 PASS.**

## Acceptance Criteria — `user-story.md` (8 items)

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | V1 rejects (Blocking) a radius when a plan task body names a concrete path not subsumed by `blast_radius.paths`, naming the uncovered path | PASS | Probe `v1_uncovered`: radius `["docs/other.md"]` against a plan naming `scripts/dev_tools/a.py` → `[V1 / Blocking / scripts/dev_tools/a.py]`. Subject names the uncovered path, satisfying the epic leading indicator (`epic.md:14`). Identical in PowerShell. |
| 2 | V2 rejects (Blocking) a touched shared surface not enumerated by concrete path; glob coverage alone does not pass | PASS | Probe `v2_glob_only`: radius `paths=["config/**"]`, `shared_surfaces=[]`, plan touching `config/orchestration-routing.json` → `[V2 / Blocking / config/orchestration-routing.json]`. Probe `v2_enumerated`: explicit enumeration → `[]`. This is the user story's own §27 scenario, reproduced. |
| 3 | V3 reports (Advisory, never Blocking); the item remains schedulable | PASS | Severity is the literal `SEVERITY_ADVISORY`; `_over_breadth_findings` can emit at most one finding and never a Blocking one. Probe `v3_over` → one Advisory; `v3_at` → none. |
| 4 | `conflicts` fails closed: shared-surface overlap conflicts by default, undecidable glob pairs count as overlap, every triggered reason kind carried; no key-level partitioning | PASS | All four clauses verified. Shared-surface overlap is unconditional set intersection with no key-level logic anywhere in either language. Undecidable glob pairs confirmed by fixture and by probe. `ConflictResult` enforces all triggered kinds in fixed order at construction. |
| 5 | A derived radius always passes V1 against its own plan | PASS | Same evidence as spec AC5; additionally the suite proves the analogous V2 property, beyond what was required. |
| 6 | Identical inputs produce identical radii, findings, and conflict results in both implementations, proven by both suites asserting the shared corpus | PASS | Both suites assert the 21-fixture corpus with anti-vacuity floors. This review added independent confirmation over 71 further cases outside the corpus with zero differences — see `code-review.2026-08-07T17-32.md` §Cross-Language Parity. Satisfies the epic NFR (`epic.md:17`) at the radius layer. |
| 7 | The public API is sufficient for F3, F4, and F8 as specified | PASS | F3: `to_dict()`/`from_dict()` with a frozen key set and enum values; `RadiusFinding` shape; `ConflictReason.kind` strings as named constants. F4: `derive_blast_radius` + `validate_blast_radius` + `conflicts`. F8: `radius_from_observed_paths` with `source == "observed"` and modules/surfaces resolved by the derivation rules — verified working over root-level files. Sufficiency is assessed against the spec's stated needs; actual adequacy is finally testable only when each consumer lands. ADJ-2 identifies one F4-facing derivation limitation that does not alter the API surface. |
| 8 | Delivered without modifying the atomic-plan contract, without modifying existing epic implementations, without adding dependencies; coverage meets the uniform gates for every new module | **PASS** | Atomic-plan contract and epic implementations untouched (spec AC13 evidence). No dependency-manifest change. Coverage verified per spec AC11, with the PowerShell branch clause ruled under ADJ-1. |

**user-story.md: 8 of 8 PASS.**

## Additional Verification Requested by the Delegating Prompt

| Item | Result |
|---|---|
| Guardrail 2 — exactly three pre-existing files edited, all append-only | **Confirmed.** Three files, `+10/-0`, `+10/-0`, `+7/-2` (the two removed lines are the prior last JSON array element with and without its trailing comma; its text is unchanged). Detail in `policy-audit.2026-08-07T17-32.md` §17. |
| `plan.md`, `spec.md`, `user-story.md` diffs are checkbox-only with no altered requirement text | **Confirmed mechanically.** All three normalize to zero unpaired lines under checkbox-marker collapse. No criterion text changed, none added, none removed. AC counts unchanged at 14 and 8. |
| No production file excluded from coverage measurement | **Confirmed.** No `exclude` entry added anywhere; the only coverage-config change widens the include list by five entries. All four Python modules appear in `lcov.info`; all five PowerShell modules were measured. |
| Tests under `tests/` mirroring production layout, never colocated | **Confirmed.** `find .claude scripts config -name "*.Tests.ps1" -o -name "test_*.py"` returns nothing. |
| Known-accepted `enforce-pr-author-skill.Tests.ps1` failure not counted as a feature defect | **Honoured, and independently corroborated.** The failure did not appear in the 284-test feature-scoped Pester run, which is independent evidence that it is not feature-induced. Not counted. |

## Findings Register (all non-blocking)

| ID | Severity | Summary | Disposition |
|---|---|---|---|
| ADJ-1 | Advisory | `quality-tiers.md` mandates a PowerShell branch metric the mandated toolchain cannot emit | Ruled PASS by proxy. Separate repository-scoped issue recommended. Not a #447 remediation. |
| ADJ-2 | Major | Separator-free repository-root shared surfaces invisible to plan-time derivation | Accepted as designed. Follow-up issue required before F4 lands. |
| F-01 | Major | `conflicts` path disjunct ignores listed-directory semantics that V1 honours | Follow-up issue, bundled with ADJ-2. |
| F-02 | Advisory | PowerShell insertion-sort backscan unexercised and untestable from the module boundary | Optional improvement. |
| F-03 | Advisory | `../` traversal tokens accepted as repository paths | Optional; errs wide. |
| F-04 | Advisory | `?` treated as a wildcard by `is_glob_entry` but not by `classify_path_token` | Optional; behaviour is consistent downstream. |
| F-05 | Advisory | Direct-run PowerShell coverage report not persisted to `evidence/coverage/` | Gap closed by this review's re-measurement; change the practice going forward. |
| F-06 | Advisory | Pyright venv-resolution warning precedes the zero-error result | Pre-existing environment condition. |

**Total Blocking findings: 0.**

No `remediation-inputs.<timestamp>.md` is produced, because no finding is remediation-required. The two Major findings are routed to a follow-up issue against the `parallel-orchestration` epic, to be resolved before F4 (#443) consumes this library.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: none

- Source: docs/features/active/2026-08-07-parallel-blast-radius-447/user-story.md
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: none
```

### Items checked off by this review

Two criteria were left unchecked by the executor pending adjudication. Both are ruled PASS above and were checked off in their source files by this review:

- `spec.md` AC11 — "Line coverage >= 85% and branch coverage >= 75% for every new module in both languages; `BlastRadius.psm1` (and any sibling PowerShell module) is appended to the `CodeCoverage.Path` list ... with an issue #447 comment." Checked under ADJ-1.
- `user-story.md` AC8 — "The feature is delivered without modifying the atomic-plan contract, without modifying existing epic implementations, and without adding dependencies; coverage meets the uniform gates (line >= 85%, branch >= 75%) for every new module." Checked under ADJ-1.

No criterion text was altered and no criterion was added. The executor's decision to leave both unchecked rather than check them on plausibility was the correct handling of an unresolved adjudication.
