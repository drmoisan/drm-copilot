# Blast-Radius False Conflict Edges — Research (Issue #489)

- **Issue:** #489
- **Date:** 2026-08-17
- **Researcher:** task-researcher agent
- **Inputs:** `artifacts/orchestration/parallel-orchestrator-state.json` (gitignored, read from working tree), the blast-radius library under `scripts/dev_tools/`, the #452 and #472 feature records, the parallel-plan skill, and the parity test surfaces.
- **Method note:** this session had no shell tool. Every claim below is grounded in file reads with line references; set intersections were computed manually from the recorded radii. Claims that require executing code are marked as such and deferred to the empirical test specified in Q7.

## 0. Verification of the operator's intersection claims

The three recorded radii were read directly from `artifacts/orchestration/parallel-orchestrator-state.json` (items at issue_num 485, 486, 487; all `state: "prepared"`, all `blast_radius.source: "declared"`, `computed_at: "2026-08-17T19:20:00Z"`). Recorded sizes match the operator's numbers (485 = 184/6/1/40, 486 = 125/3/2/45, 487 = 140/4/1/10 for paths/modules/shared_surfaces/contracts).

**Exact-string pairwise path intersections — CONFIRMED as stated:**

- 485 ∩ 486 = `.claude/rules/general-code-change.md`, `general-unit-test.md`, `python-suppressions.md`, `python.md`, `quality-tiers.md`, `typescript-suppressions.md`, `typescript.md` (7 rule files), `.claude/skills/atomic-plan-contract/SKILL.md`, `quality-tiers.yml`, bare `extensions/drm-copilot`, bare `scripts/dev_tools`. Zero concrete source files.
- 485 ∩ 487 = `.claude/rules/general-code-change.md`, `general-unit-test.md`, `python.md`, `quality-tiers.md`, `typescript.md` (5 rule files), `quality-tiers.yml`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `artifacts/` plus the eight subdirectory entries `artifacts/{baseline,baselines,coverage,evidence,post-change,qa-gates,qa,regression-testing}/`, and `extensions/drm-copilot/`. Zero concrete source files.
- 486 ∩ 487 = the same 5 rule files, `quality-tiers.yml`, and `extensions/drm-copilot/src/mcp-tools.ts`. One genuine source-file conflict.

**Divergence 1 — the operative overlap set is larger than the exact intersections.** The comparison relation `_entries_overlap` (`scripts/dev_tools/_blast_radius_glob.py:273-316`) honours directory prefixes (concrete×concrete branch at lines 299-304, added by #452) and glob prefixes (lines 305-316). Additional pairs that fire under the real relation but are absent from exact intersection:

- 485 `tests/scripts/dev_tools/` (trailing slash) × 486 `tests/scripts/dev_tools` and its test files — `_directory_prefix` normalizes the trailing slash (`_blast_radius_glob.py:225-246`).
- 485 bare `extensions/drm-copilot/src` × 486/487 concrete files under `src/`.
- 485 bare `docs/features` × every `docs/features/...` entry on both other items.
- **486 `docs/features/**/plan*.md` (a glob) × 485's and 487's own feature-folder globs** — glob×glob branch: literal prefixes `docs/features/` and `docs/features/active/<folder>/` nest (`_blast_radius_glob.py:314-316`). This is a **fourth false-contention source** not in the operator's list ("cross-corpus document globs": 486's plan-gate validator genuinely reads every plan document; 485/487 write only their own). It survives all three named fixes and is addressed separately below.

- 487 `.claude/rules/` and `.claude/rules/**` × every 485/486 rule-file citation (directory and glob containment).

**Divergence 2 — decisive: paths are not the only edge-forming level.** The edge relation used by the parallel planner is the full four-disjunct `conflicts(a, b, config)` (`.claude/skills/parallel-plan/SKILL.md:213-217, 282-285`; `scripts/dev_tools/_blast_radius_conflicts.py:137-177`). On the recorded radii:

| Pair | path_overlap | module_overlap | shared_surface_overlap | contract_dependency |
| --- | --- | --- | --- | --- |
| 485-486 | yes | yes — `claude-runtime`, `python-dev-tools`, `vscode-extension` shared | yes — `quality-tiers.yml` | yes — shared token `->` |
| 485-487 | yes | yes — `claude-runtime`, `copilot-surface`, `python-dev-tools`, `vscode-extension` shared | yes — `quality-tiers.yml` | no |
| 486-487 | yes (genuine: `mcp-tools.ts`) | yes | yes — `quality-tiers.yml` | no |

The recorded `reason: "path_overlap"` on each edge is only `reasons[0]` in the fixed `CONFLICT_KINDS` order (`_blast_radius_conflicts.py:48-53, 159-177`); it does not mean the other disjuncts were silent. Consequence: **a fix limited to the three named path-level sources leaves the K3 intact** through `module_overlap` (and `shared_surface_overlap`, and `contract_dependency` for 485-486). The module overlaps are not extraction junk: all three items genuinely write files under `scripts/dev_tools/**` and `extensions/drm-copilot/**`, so `resolve_modules` (`_blast_radius_validation.py:263-288`) resolves the same coarse modules from real write targets.

## 1. Current state — the derivation and comparison pipeline

- **Extraction** (`scripts/dev_tools/_blast_radius_extraction.py`). Inline-code spans are the only token source (line 61). `classify_path_token` (lines 223-287) accepts a token when (a) it exactly equals a configured separator-free root surface (lines 255-256, the #452 Gap 1 mechanism), or (b) it contains `/`, is repo-relative, and either starts with a `KNOWN_TOP_LEVEL_SEGMENTS` prefix (lines 69-74: `scripts/ tests/ docs/ config/ schemas/ packages/ extensions/ .claude/ .codex/ .github/ .agents/ artifacts/`) or its final component carries a recognized extension (lines 78-83). The known-segment rule deliberately "admits directory-shaped tokens" (comment, lines 66-68). The docstring states over-inclusion of read-only references is accepted (lines 32-33) — that acceptance is the defect under study.
- **Contracts** (`extract_contract_identifiers`, lines 362-419): inside interface-keyword sections, every separator-free inline-code token is admitted (lines 415-417) — including pure punctuation (`->`, `{`, `=`, `0`).
- **Derivation** (`scripts/dev_tools/compute_blast_radius.py:216-275`): union of plan and spec extraction, plus the own-feature-folder glob (line 265); modules and shared surfaces are resolved from the resulting paths (lines 270-272).
- **Comparison** (`_blast_radius_conflicts.py`, `_blast_radius_glob.py`): four independent disjuncts; `conflicts()` reads no config key (line 145-147 docstring). The #452 hardening lives in (i) root-surface admission (`_blast_radius_extraction.py:250-256`, `_blast_radius_validation.py:194-229`) and (ii) directory-prefix honouring in `_entries_overlap` (`_blast_radius_glob.py:296-304`). Neither touches the module disjunct.
- **Cohorts**: `compute_cohorts(item_keys, conflict_edges)` (`scripts/dev_tools/parallel_cohort_computation.py:350-416`), Welsh-Powell greedy coloring; consumes the edge set only, `reason` is audit metadata (module docstring lines 19-31).

**#452 (PR #453) — what the hardening protects.** Gap 1: separator-free root surfaces (`poetry.lock`, `package-lock.json`, `quality-tiers.yml` — named at `docs/features/epics/parallel-orchestration/epic.md:151`) were unreachable from plan text, so a genuine writer's radius under-reported and V2 had no force. Gap 2: a plan citing a directory did not contend with a plan citing a file inside it (fixture descriptions in `tests/fixtures/blast_radius/conflict-directory-vs-file.json`, `conflict-directory-vs-glob.json`, `conflict-sibling-prefix-disjoint.json`). Both corrections move fail-closed. The parallel-plan skill pins this as load-bearing and prohibits narrowing a radius to suppress an edge (`.claude/skills/parallel-plan/SKILL.md:219-225`).

**#472 — precedent.** Delivered 2026-08-15 (all 18 ACs checked in `docs/features/active/2026-08-15-blast-radius-module-map-forces-serial-runs-472/spec.md`). Defect A fix was **config content**: delete the `docs` and `tests` location-bucket modules from both committed truth tables, with the explicit rationale that a bucket "attaches to essentially every item" and "is not a coherent unit of contention" (spec.md:96-104). `conflicts()` was left unchanged (spec.md:82). The #472 spec also established the destination-derivation principle "leaf granularity maximizes concurrency; an umbrella module would re-couple siblings the way `docs` coupled everything" (spec.md:158). Issue #489 is the same defect class one scale down: `python-dev-tools` (`scripts/dev_tools/**`), `vscode-extension` (`extensions/drm-copilot/**`), and `claude-runtime` (`.claude/**`) are umbrella buckets that nearly every work item in this repository genuinely writes into.

## Q1 — Extraction side versus comparison side

**Answer: the entire fix is extraction-side plus config-content. No comparison-side change is required, and none is recommended.** The #452 hardening (`classify_path_token` root-surface admission; `_entries_overlap` directory rules) is preserved byte-for-byte.

Source-by-source sufficiency, with the level each source poisons:

| False-contention source | Level poisoned | Fix site | Sufficient extraction/config fix |
| --- | --- | --- | --- |
| 1. Phase-0 policy-read paths (`.claude/rules/*.md`, `quality-tiers.{yml,md}`, mandate-read SKILLs) | paths, shared_surfaces (via `quality-tiers.yml`), modules (via `.claude/**` etc.) | extraction + config | config-driven mandate-read exclusion applied during derivation harvest (Q2) |
| 2. Bare directory tokens (`extensions/drm-copilot`, `scripts/dev_tools`, `docs/features`, `.claude/rules/`, `extensions/drm-copilot/src`, ...) | paths, modules | extraction | reject wildcard-free tokens whose final component has no recognized extension (Q4) |
| 3. Evidence-output directories (`artifacts/`, `artifacts/*`) | paths | extraction + config | remove `artifacts/` from `KNOWN_TOP_LEVEL_SEGMENTS` (`_blast_radius_extraction.py:69-74`) and add `artifacts/**` to the exclusion list, which also catches extension-bearing leaks such as `artifacts/pr_context.summary.txt` |
| 4. Cross-corpus document globs (486's `docs/features/**/plan*.md`) | paths | extraction | drop harvested glob tokens rooted under `docs/features/` that span multiple feature folders (own-folder globs, which carry a complete folder segment, are retained); rationale: a corpus-wide doc glob is a read-scan by construction, and an actual cross-folder write is caught by drift detection |
| 5. Coarse repo-layout modules resolved from genuine, disjoint writes | modules | **config content** (#472 precedent) | remove the umbrella module entries from `config/blast-radius.json` (see below) |
| 6. Punctuation contract tokens (`->` shared by 485-486) | contracts | extraction | require a contract identifier to contain at least one ASCII letter (`extract_contract_identifiers`, `_blast_radius_extraction.py:415-417`) |

**Why source 5 cannot be fixed by extraction alone, and why it still is not a comparison-side change.** 485 writes `extensions/drm-copilot/src/lib/pr-context/*` and `scripts/dev_tools/pr_context/*`; 486 writes `extensions/drm-copilot/src/lib/validate/*` and `scripts/dev_tools/plan_gate_*`; 487 writes `extensions/drm-copilot/src/lib/new-active-feature-folder/*` and `scripts/dev_tools/new_active_feature_folder_*`. After any conceivable path cleanup, all three still resolve `python-dev-tools` and `vscode-extension` from real write targets, so `module_overlap` fires for every pair (`_blast_radius_conflicts.py:167-175`: plain set intersection). Map granularity cannot separate them either — #472's own destination-derivation algorithm treats a manifest-bearing directory as one module, and `extensions/drm-copilot` is a single npm project. The only fixes are (a) delete the umbrella entries from the truth table, or (b) change the module disjunct's semantics. (a) is config content, exactly the #472 Defect-A fix class; (b) is the comparison-side change the operator warned against. **Recommend (a): remove `python-dev-tools`, `vscode-extension`, `claude-runtime`, `copilot-surface`, and `agents-surface` from `config/blast-radius.json` `modules`.** The five removals are the buckets that (i) every work item in this repository routinely writes into (Python tools, the extension, and the three six-copy customization surfaces) and (ii) provide no signal the post-#452 path level does not already provide (a radius reaches a module only through its own paths; prefix- and glob-honouring path comparison already adjudicates those same paths at file/subtree granularity). Retain the leaf-granularity entries (`mcp-server`, `benchmarks`, `poshqc`, `powershell-dev-tools`, `codex-runtime`, `config`, `schemas`) so the module level, the `module_overlap` enum member, and the non-empty-map pins remain live. Whether `codex-runtime` should also be removed is a spec-time decision; it is not needed for this run's outcome.

**Proof the recommendation cannot reintroduce the #452 defect.** #452's two corrections are untouched files: `_blast_radius_glob.py` (directory rules, lines 296-304) and the root-surface admission chain (`_blast_radius_extraction.py:250-256`, `_blast_radius_validation.py:194-229`) are not modified. The exclusion list narrows only the harvest of citations of enumerated mandate-read entries; every other token classifies exactly as today. The one deliberate interaction — excluding `quality-tiers.yml` citations, which #452 Gap 1 made admissible — is analyzed in Q3 with its backstop.

**Rejected alternative (comparison side).** Demoting or conditioning `module_overlap` inside `conflicts()` was evaluated and rejected: it changes a frozen relation consumed by drift detection (`parallel_drift_detection.py:499`) and the F3-owned edge-reason enum semantics, it contradicts the #472 spec's explicit non-goal ("The conflict relation ... unchanged", spec.md:82), and the config-content route achieves the identical outcome for this repository with zero relation-code risk.

## Q2 — Read/write distinction versus exclusion list

**Recommendation: the config-driven exclusion list.**

- **Can the extractor determine read-versus-write intent?** No, not with acceptable reliability. Extraction is a pure token scan over inline-code spans (`_blast_radius_extraction.py:192-220, 290-321`); it sees tokens, not verbs. Plans cite paths inside task titles, guardrail clauses, and evidence clauses interchangeably (comment at lines 353-355); there is no structured intent marker in the plan contract. An NLP-ish heuristic over surrounding prose would misclassify, and a misclassified write is a silent radius under-report — the exact direction #452 exists to prevent.
- **Failure modes.** Read/write classifier wrong on a write → that path silently exits contention for arbitrary, unenumerated files; the failure surface is unbounded. Exclusion list wrong (a listed file is genuinely written) → under-report bounded to a small, reviewed, committed enumeration whose members are policy files written rarely, with a deterministic backstop: `detect_escaped_paths` (`scripts/dev_tools/parallel_drift_detection.py:104-139`) tests every observed diff path against the declared radius with `is_path_subsumed`, so an actual write to an excluded path escapes and produces a drift event (`raised_blocking_finding` / `halted_later_started_item`). Observed radii are built verbatim from diff paths (`compute_blast_radius.py:278-313`) and diffs contain writes only, so the read/write distinction is exact at drift time even though it is unavailable at plan time.
- **Indeterminate paths under the read/write model** would have to default to contention (fail-closed) — which means every mandate-read path stays contention unless an authored read-list overrides it. The read/write model therefore collapses into an exclusion list plus an unreliable classifier; the list alone is the smaller mechanism.
- **Fail-closed preservation, stated explicitly:** the exclusion list is default-deny. An absent config key excludes nothing (matching the `config_string_list` absent-key convention, `_blast_radius_validation.py:173-191`); any path not enumerated continues to count as contention; a genuine write to an enumerated path is caught by the drift backstop above; and the planner remains permitted (and, per prose amendment, obliged) to append an excluded path to a declared radius explicitly when a plan's diff will touch it — derivation output is a floor, not a ceiling.

**Runner-up (read/write model), rejected because** it requires intent inference the extractor cannot perform, its wrong-answer failure mode is unbounded silent under-reporting, and its fail-closed default reproduces the defect for exactly the mandate-read set the fix targets.

## Q3 — `quality-tiers.yml` and the rest of `shared_surfaces`

**History and rationale.** `quality-tiers.yml` has been a `shared_surfaces` entry since the F1 truth table; the parallel-orchestration epic names it among the three separator-free root surfaces whose unreachability motivated #452 Gap 1 (`docs/features/epics/parallel-orchestration/epic.md:151`; the epic even originally specified module mapping via `quality-tiers.yml`, epic.md:226-229). The write-contention rationale is real: `.claude/rules/quality-tiers.md` requires every project to be classified in `quality-tiers.yml`, so any two items that each add a project write the same file.

**Determination: the declaration is correct and should stay; the classification error is upstream of it.** The false contention does not come from `shared_surfaces` membership per se — it comes from the #452 root-surface mechanism admitting every mandate-driven *citation* into `paths` (`classify_path_token` line 255-256), after which `resolve_shared_surfaces` (`_blast_radius_validation.py:291-319`) faithfully lifts it. Do NOT remove it from `shared_surfaces`: removal would (a) strip root-surface admissibility from genuine writers (directly reversing #452 Gap 1 for this file), and (b) remove V2's enumeration force. Instead add `quality-tiers.yml` (and `.claude/rules/quality-tiers.md`) to the mandate-read exclusion. Residual risk: a genuine `quality-tiers.yml` writer whose planner does not explicitly enumerate it under-reports until drift detection catches the write; accepted and documented, with the planner-obligation prose as first mitigation.

**Every other current entry, assessed (config/blast-radius.json:3-19):**

| Entry | Read-only-by-mandate? | Disposition |
| --- | --- | --- |
| `config/orchestration-routing.json`, mirror | no — cited when routed behavior changes | keep; not excluded |
| `.claude/settings.json` | no — cited when permissions/hooks change | keep; not excluded |
| `poetry.lock`, `package-lock.json`, `extensions/drm-copilot/package-lock.json`, `packages/mcp-server/package-lock.json` | no — citation almost always accompanies a dependency change (a write) | keep; not excluded |
| `quality-tiers.yml` | **yes** — every plan must consult it (CLAUDE.md policy order) | keep in `shared_surfaces`; add to mandate-read exclusion |
| `config/blast-radius.json` | no — cited when the truth table changes | keep; not excluded |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | mostly read (test config consulted by PS work) | borderline; recommend keep un-excluded (its citations are confined to PowerShell items, so it does not build complete graphs) |
| `shared_surface_globs` (`validate_*.py`, `_orchestrator_state_*.py`, `_epic_orchestrator_state_*.py`) | no — these are production files matched only when actually listed as paths | keep; not excluded |

Only `quality-tiers.yml` is read-by-mandate among the shared surfaces. Note the bundled base document (`extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json:3-7`) does not list `quality-tiers.yml` at all — see Q5.

## Q4 — Bare directory tokens

**Entry point, precisely.** `classify_path_token`, `scripts/dev_tools/_blast_radius_extraction.py:277-281`: `token.startswith(KNOWN_TOP_LEVEL_SEGMENTS)` accepts any token beginning with one of the twelve top-level prefixes (lines 69-74) with **no extension requirement**; the comment at lines 66-68 states this "admits directory-shaped tokens and `**` globs" by design. `extensions/drm-copilot` enters via the `extensions/` prefix, `scripts/dev_tools` via `scripts/`, `docs/features` via `docs/`, `.claude/rules/` via `.claude/`, `artifacts/` via `artifacts/`. The tokens originate in plan/spec prose inline code (`extract_paths_from_lines`, lines 290-321), harvested from task titles, phase titles, and other lines alike (lines 351-359).

**Relationship to the `modules` mechanism: none, mechanically.** `resolve_modules` output feeds only the radius `modules` field (`compute_blast_radius.py:270-271`); module names and globs never leak into `paths`. The resemblance (bare `scripts/dev_tools` token vs `python-dev-tools: scripts/dev_tools/**` module) is coincidental — both are breadth expressions of the same subtree, one accidental, one configured.

**Is a bare directory token ever legitimate?** As a deliberate subtree claim, yes — but the glob form `dir/**` already expresses that intent unambiguously, is admitted today, and participates in the same overlap rules. Fix: reject wildcard-free tokens whose final component carries no recognized extension (directory-shaped tokens), and amend planner prose to require subtree claims be written as `**` globs. Line-suffixed citations (`.claude/rules/python.md:90`) remain admitted and are inert for overlap (the `:90` suffix defeats both equality and directory anchoring); trimming them is optional hygiene, not required for the outcome. V1 self-consistency is automatic: derivation and rule V1 share `extract_plan_paths` (`_blast_radius_extraction.py:324-333`; `_blast_radius_validation.py:353-355`), so a token dropped from the radius is identically dropped from the plan-side extraction.

## Q5 — Backward compatibility and the config contract

**New config key.** One optional key on `config/blast-radius.json`, working name `mandate_reads` (final name at spec time): a list of exact paths and `**` globs whose harvested citations are excluded from derivation's path collection (and therefore from module/shared-surface resolution of derived radii). Absent key → empty exclusion → byte-identical current behavior, matching the absent-key convention of `config_string_list` (`_blast_radius_validation.py:186-191`). Fail-closed default confirmed: exclusion requires explicit enumeration.

**Mirror contract — operator premise is out of date.** Since #472, `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` is **not** a byte-identical mirror; it is a two-module base document (`claude-runtime`, `config`; verified by reading the file) consumed by the TypeScript push-down derivation, which rewrites `modules` from the destination layout and carries the other keys verbatim. There is no byte-identity test for blast-radius configs (byte-for-byte mirroring applies to `config/orchestration-routing.json`, per `.claude/rules/parallel-orchestration.md` Enforcement section). The tests that pin both copies are `test_no_committed_copy_declares_a_location_bucket_module` (`tests/scripts/dev_tools/test_blast_radius_config.py:483-499`) and the Pester `Committed blast-radius truth table shape` / `Location-bucket modules` blocks (`tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:302-436`).

**Critical carriage gap.** The TS derive core emits a fixed key set: `CARRIED_KEYS` = `version`, `shared_surfaces`, `shared_surface_globs`, `over_breadth_fraction` plus derived `modules`, in fixed order (`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:146-149, 406-407, 432-436`). **A new config key not added to `CARRIED_KEYS` and the assembly is silently dropped from every pushed-down destination config.** The fix must extend `CARRIED_KEYS`, the assembly object, the emission-order documentation, and the bundled base document, with a Jest assertion that the key survives derivation.

**Validators that read a radius, and what added-field/changed-content does to each:**

| Validator | Behavior |
| --- | --- |
| `BlastRadius.from_dict` (`compute_blast_radius.py:194-213`) | rejects any unexpected radius key (lines 200-202). **Do not add a radius field**; the fix adds a config key only, so the radius dict shape is unchanged. Content changes (fewer paths) are fine. |
| `validate_blast_radius_block` (`scripts/dev_tools/_parallel_state_common.py:249-288`) — invariant 9 for both parallel checkpoints and manifest M6 | checks the six required fields only; tolerant of content changes; recorded checkpoints keep validating. |
| `validate_blast_radius` V1-V3 (`_blast_radius_validation.py:322-366`) | an old (junk-bearing) recorded radius validated against its plan under the new extraction still passes V1 (the radius is a superset of the narrowed plan extraction) and V2 (its paths still enumerate the surfaces they contain). |
| PowerShell mirrors (`.claude/lib/blast-radius/BlastRadiusValidation.psm1` etc.) and TS parallel-state validators | same shape-only posture as their Python counterparts. |

**Is a recorded radius ever re-validated against recomputation?** No. The planner's recomputation-parity obligation re-runs `compute_cohorts` over the *recorded* `item_keys` and `conflict_edges` only (`.claude/skills/parallel-plan/SKILL.md:313-329`); no surface re-derives a radius from plan text and compares. A semantics change therefore does not invalidate already-recorded items. One second-order effect: for in-flight items, a narrowed declared radius could newly classify a write as escaped in drift detection; no item is in flight in the `verification-integrity` run (all `merge_status: not_started`).

## Q6 — Parity surface and exhaustive change inventory

**Parity binding is a shared corpus, not per-side assertion.** `tests/fixtures/blast_radius/*.json` is asserted by both `tests/scripts/dev_tools/test_blast_radius_parity.py` (module docstring lines 1-24; fixture floor `MINIMUM_FIXTURE_COUNT = 26` at line 56) and `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (same corpus, same floor discipline). The corpus supports two fixture kinds: derivation/validation (`input: {plan_text, spec_text, feature_folder, config, ...}`) and conflict (`input: {radius_a, radius_b, config}`) — the exact shapes this fix needs. Adding fixtures is safe (floor plus on-disk-count equality; no exact count pin). A one-sided semantic edit is caught because both suites recompute the same `expected` blocks.

**Files that must change:**

- Python (authoritative): `scripts/dev_tools/_blast_radius_extraction.py` (classifier shape rule; contract-identifier letter filter; exclusion application or a parameter for it), `scripts/dev_tools/_blast_radius_validation.py` (new config reader beside `config_root_surfaces`), `scripts/dev_tools/compute_blast_radius.py` (derivation applies exclusions; new pure normalization entry point for existing radii — Q7), `config/blast-radius.json` (new key; five module removals). **Unchanged:** `_blast_radius_conflicts.py`, `_blast_radius_glob.py`, `_blast_radius_thresholds.py`, `parallel_cohort_computation.py`.
- PowerShell (destination-runtime mirror, used by the planner via `Test-BlastRadiusConflict`, `.claude/lib/blast-radius/BlastRadius.psm1:302`): `BlastRadiusExtraction.psm1`, `BlastRadiusConfig.psm1`, `BlastRadius.psm1`; tests under `tests/scripts/claude-lib/blast-radius/` including new parity Describe cases. `BlastRadiusGlob.psm1`, `BlastRadiusValidation.psm1` comparison logic unchanged.
- TypeScript: `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` (`CARRIED_KEYS` + assembly, lines 146-149/432-436) and its tests; the bundled resource config. TypeScript implements **no** extraction/conflict semantics — no TS port of the new rules exists or is owed.
- Bash: `.claude/lib/bash/compute-cohorts.sh` consumes keys and edges only — unchanged.
- Prose: `.claude/skills/parallel-plan/SKILL.md` (Q8), rule-file prose (Q8), plus the pushed-down mirrors of any amended rule under `extensions/drm-copilot/resources/*/`.

**Exhaustiveness check.** All in-repo consumers of `conflicts`/`derive_blast_radius`/radius structures were enumerated (54 occurrences across 14 `scripts/dev_tools` files): `parallel_drift_detection.py` (+`_cli`), `parallel_drift_resolution.py`, `parallel_mutation_protocol.py`, `parallel_lane_assertion.py`, `_parallel_mutation_*.py`, `_parallel_state_*.py`, `parallel_cohort_computation.py`. All consume radii or edge sets structurally through the frozen relation and shape; none re-implements extraction, so none needs a semantic change. The parallel skills (`parallel-plan`, `parallel-orchestrate`, `parallel-add`, `parallel-remove`) reference the contracts as prose.

## Q7 — Empirical demonstration mechanism

**Recolor authority.** `compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]) -> list[list[int]]` in `scripts/dev_tools/parallel_cohort_computation.py:350-416` (Welsh-Powell, `(-degree, item_key)` order). Destination-runtime bash entry point: `bash .claude/lib/bash/compute-cohorts.sh --keys "<k1> <k2> ..." --edges "<a>:<b> ..."` (file verified present; contract at `.claude/skills/parallel-plan/SKILL.md:249-274`). There is no PowerShell cohort port; PowerShell supplies the edge relation (`Test-BlastRadiusConflict`), bash/Python supply coloring.

**Hand-verified expected outcome.** With the true single edge (486, 487): degrees 486=1, 487=1, 485=0; visit order 486, 487, 485; assignment 486→0, 487→1, 485→0; `compute_cohorts([485, 486, 487], [(486, 487)]) == [[485, 486], [487]]` — 485 and 486 concurrent, exactly the required two-cohort outcome.

**Fixture (before-state promotion).** Commit `tests/fixtures/blast_radius/verification-integrity-485-486-487.json` (name final at spec time) holding: the three recorded `blast_radius` dicts verbatim (they match `RADIUS_KEYS` exactly, so `BlastRadius.from_dict` loads them), the pre-fix config content, and the post-fix config content. All entries are non-blank strings, so `require_str_tuple` accepts them.

**Why a normalization entry point is required for the after-state.** `conflicts()` is deliberately config-blind on comparison and must stay so; applied to the *recorded* radii it will yield K3 forever (that is the pinned before-state, and it stays true post-fix). The two-cohort after-state therefore needs a pure function — recommend `sanitize` semantics on `compute_blast_radius.py`, e.g. `normalize_declared_radius(radius, config) -> BlastRadius` — that filters excluded/mandate-read entries, directory-shaped tokens, cross-corpus doc globs, and letterless contract tokens, then re-resolves modules and shared surfaces against the (fixed) config. The planner calls it after derivation; the demonstration calls it on the fixture radii. The alternative (promote the three plan/spec documents to fixtures and re-derive) is heavier and couples the test to full plan texts; rejected as runner-up. `normalize` must never run on `observed` radii (diff paths stay verbatim so drift keeps its force).

**Regression test placement.**

- Python: `tests/scripts/dev_tools/test_blast_radius_verification_integrity.py` (or a section of `test_blast_radius_config.py`): (a) before-state pin — pairwise `conflicts()` on the raw fixture radii yields three conflicting pairs; (b) after-state — normalize with the fixed committed config, assert the edge set is exactly `{(486, 487)}` and `compute_cohorts([485, 486, 487], [(486, 487)]) == [[485, 486], [487]]`.
- PowerShell: matching cases in `BlastRadius.Parity.Tests.ps1` (the committed-truth-table Describe at line 302 is the precedent for committed-artifact cases).
- The parity corpus additionally gains ordinary derivation fixtures exercising each new rule in isolation (both runtimes recompute them).

**Evidence.** The committed evidence artifact referencing the fixture and recording the before/after edge sets and cohort partitions goes to `docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/regression-testing/<name>.<timestamp>.md` (and `qa-gates/` for the gate runs). No `artifacts/`-rooted evidence path is permitted; the before-state currently living only in the gitignored checkpoint is preserved by the fixture, not by an artifacts copy.

## Q8 — Prose, doctrine, and fragment pins

**Prose to amend (prose + validator doctrine; no JSON Schema, and the disqualified foreign schema with the `drmoisan.github.io/mix-calculator/` `$id` is not copied):**

1. `.claude/skills/parallel-plan/SKILL.md:219-225` — the F1a load-bearing paragraph. It currently ends "do not narrow a radius in order to suppress a conflict edge they produce." The mandate-read exclusion must be described there as part of the landed contract so the prohibition reads "do not narrow a radius beyond the configured exclusions," otherwise the fix's own behavior violates the skill's text.
2. `.claude/rules/parallel-orchestration.md` — add a section documenting the mandate-read/never-contend classification concept and the module-map granularity doctrine (extending the #472 rationale), or create a dedicated `.claude/rules/blast-radius.md`; either way the pushed-down rule mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/` must be updated in the same commit. Invariant 9 (radius shape) is unchanged — no new radius field.

**Fragment-pin audit (tests that pin prose or config content and must move in the same commit):**

- `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py:59-71` pins that the parallel-plan skill contains the literal `conflicts(a, b, config)` **and does not contain** the literal `conflicts(a, b)`; lines 117-129 pin the derive signature string. Amended skill text must preserve the first literal and must not introduce the second. No test pins the "#452 load-bearing"/"narrow a radius" sentences verbatim (grep of `tests/` for `narrow a radius`, `F1a`, `honours listed-directory` returned no skill-text pins).
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:119-276` (including `COHORT_BARRIER_FRAGMENTS` at line 154) pins parallel-orchestrate skill fragments; none quote the sentences this fix amends — verified against the fragment list; re-verify at spec time if additional prose is touched.
- **Config-content pins that break on the module removals** and must be amended in the same commit: `tests/scripts/dev_tools/test_blast_radius_config.py:407-422` (`test_items_sharing_a_dev_tools_file_contend_on_path_and_module` asserts `python-dev-tools` resolves and `module_overlap` fires — rewrite against a retained module or drop the module_overlap clause), `:180-191` (modules map must be non-empty — satisfied by the retained entries), `:444-463` (pins the `config` module — retained, so it survives). PowerShell: `BlastRadius.Parity.Tests.ps1:323-338` (non-empty module map — survives) and any behavior-matrix case naming a removed module.
- `tests/fixtures/blast_radius/*` fixtures embed their own `config` blocks and are unaffected by committed-config edits; additions only (floor 26, `test_blast_radius_parity.py:56`).

## Recommended approach (single consolidated recommendation)

1. **Config:** add optional `mandate_reads` (exact files + globs; initial content: the Phase-0 rule files, `quality-tiers.yml`, `.claude/rules/quality-tiers.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `artifacts/**`); remove the five umbrella module entries (`python-dev-tools`, `vscode-extension`, `claude-runtime`, `copilot-surface`, `agents-surface`). Keep `quality-tiers.yml` in `shared_surfaces`.
2. **Extraction:** directory-shaped token rejection; cross-corpus `docs/features/` glob rejection; letterless contract-token rejection; remove `artifacts/` from `KNOWN_TOP_LEVEL_SEGMENTS`.
3. **Normalization entry point** applied by the planner post-derivation and usable on recorded radii; never applied to `observed` radii.
4. **Parity:** mirror 2-3 in the PowerShell modules; extend the shared fixture corpus; extend TS `CARRIED_KEYS`.
5. **Demonstration:** committed before-state fixture + the two-cohort regression test in both runtimes, evidence under the feature's `evidence/` tree.
6. **Prose:** parallel-plan skill paragraph, rule-file doctrine, pushed-down mirrors; move the enumerated pins in the same commit.

**Known residual risks (accepted, documented):** a genuine write to a `mandate_reads` entry or a genuine cross-feature-folder write is invisible at scheduling time unless the planner enumerates it explicitly; both are caught at execution time by `detect_escaped_paths`. Two items retained in the same surviving module entry still serialize; that is the deliberate remaining scope of the module level.

**Not verifiable in this session (no shell):** actual execution of `conflicts()`/`compute_cohorts` over the recorded radii (edge table in section 0 is manual set analysis over the recorded JSON), and the exact provenance (plan vs spec) of individual recorded tokens such as 486's `docs/features/**/plan*.md`. The Q7 test is the mechanism that converts the manual analysis into executable evidence.

## Testing implications (summary)

- New unit tests per extraction rule (positive, negative, boundary: trailing-slash directories, line-suffixed citations, `${EXT}`-style placeholder tokens which are admitted today via the extension fallback and self-neutralize in comparison, `--cov=`-prefixed tokens admitted via the extension fallback).
- Parity corpus additions for every new rule (both runtimes recompute; floors are additive-safe).
- The verification-integrity fixture regression test (Q7) in Python and PowerShell.
- Amend the pinned config tests listed in Q8 in the same commit as the config change.
- No temporary files; committed fixtures only; all pure-function tests.
