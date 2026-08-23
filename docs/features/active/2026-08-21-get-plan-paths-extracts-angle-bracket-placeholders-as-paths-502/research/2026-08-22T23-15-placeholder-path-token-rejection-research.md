# Research — Placeholder path-token rejection in the blast-radius extractor (Issue #502)

- **Issue:** #502
- **Feature folder:** `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/`
- **Timestamp:** 2026-08-22T23-15
- **Inputs read:** `issue.md`, `spec.md` (template skeleton, `## Proposed Fix` unfilled), `plan.2026-08-22T22-57.md` (template skeleton)
- **Method:** static code trace plus repository measurement using Read/Grep/Glob only. This research role has no shell. Every claim below is either (a) a line-cited code trace of a pure, branch-simple function, or (b) a `ripgrep` count over tracked files. Claims that require execution are marked **EXECUTION-PENDING** and are converted into plan obligations rather than asserted.

---

## 1. Current State Analysis

### 1.1 The classifier and its five acceptance/rejection rules

`classify_path_token` in `scripts/dev_tools/_blast_radius_extraction.py:284-363` is the single decision point for whether an inline-code token becomes a `paths` entry. Its rule order is:

1. Exact ordinal membership in `root_surfaces` (issue #452) → `concrete`.
2. Reject if no `/`, or a leading `/`, or a `:` in the leading segment (`:326-329`).
3. Compute `has_extension` from the final component after stripping a `:<line>` suffix (`:335-340`).
4. If no `*`: accept as `concrete` iff `has_extension`, else reject (directory-shaped rejection, issue #489) (`:346-347`).
5. If `*`: require a known top-level segment or a recognized extension (`:352-353`), then reject a corpus-spanning `docs/features/` glob (`:358-359`), else `glob`.

`.claude/lib/blast-radius/BlastRadiusExtraction.psm1:290-398` (`Get-PathTokenKind`) reproduces the same five rules in the same order. Neither runtime contains any placeholder rule. Confirmed: the defect is present in both, exactly as the delegation prompt states.

### 1.2 Why the classifier is the correct seam, not `extract_plan_paths`

Three call sites read the classifier, and only a fix at the classifier reaches all three:

| Consumer | Path to the classifier | Reached by a fix in `classify_path_token`? | Reached by a fix in `extract_plan_paths`? |
| --- | --- | --- | --- |
| `derive_blast_radius` (`compute_blast_radius.py:265-270`) | `extract_plan_paths` + `extract_paths_from_lines` (spec text) | Yes, both plan and spec harvest | No — the spec harvest bypasses `extract_plan_paths` |
| `validate_blast_radius` V1/V2 (`_blast_radius_validation.py:330-335`) | `extract_plan_paths` | Yes | Yes |
| `normalize_declared_radius` (`compute_blast_radius.py:341-345`) | direct `classify_path_token` call per recorded entry | Yes | **No** |

The third row is decisive. `normalize_declared_radius` exists precisely to re-filter radii recorded by an older extractor, and it is the mechanism by which the #489 fix was demonstrated against already-recorded data (`tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json`, asserted by `BlastRadius.Parity.Tests.ps1:301-405`). A guard placed in `classify_path_token` retroactively cleans every recorded manifest and checkpoint radius; a guard placed in `extract_plan_paths` does not.

The classifier seam also delivers V1/V2 symmetry for free: `validate_blast_radius` filters the plan side through the same `extract_plan_paths`, so a token dropped at derivation is also dropped at validation and a derived radius keeps passing V1 against its own plan. This is the same symmetry property `mandate_reads` had to arrange explicitly (`_blast_radius_validation.py:326-335`), and it needs no arrangement here.

### 1.3 Hard structural constraint: both extraction files are at the 500-line limit

Measured line counts (`rg -c '^'`):

| File | Lines | Headroom to the 500-line limit |
| --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 497 | **3** |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 498 | **2** |

An in-place guard is not implementable. A minimum-viable Python edit is a marker constant with its rationale comment (~6 lines), a guarded branch with its decision-logic comment as `.claude/rules/self-explanatory-code-commenting.md` requires (~5 lines), and a `Returns:` docstring amendment (~2 lines) — about 13 lines against 3 available. The PowerShell edit is worse: a comment-block `.DESCRIPTION` amendment plus a commented branch against 2 available lines.

This is the single most consequential finding for planning. Relocation is mandatory, not optional, and there is direct precedent in both runtimes:

- `Get-ContractIdentifier` was relocated to `BlastRadiusNormalization.psm1` for this exact reason (module header, `BlastRadiusExtraction.psm1:10-13`).
- `Get-OrdinalSortedEntry` was relocated to `BlastRadiusGlob.psm1` for this exact reason and is re-imported and re-exported (`BlastRadiusExtraction.psm1:40-45`, `:491`).

### 1.4 Dependency-graph constraint on the PowerShell side

`BlastRadiusNormalization.psm1:34` imports `BlastRadiusExtraction.psm1`. `BlastRadiusExtraction.psm1` therefore cannot import Normalization without a cycle, so the placeholder predicate cannot be hosted in Normalization (295 lines, 205 free) on the destination runtime. The Python graph has no such constraint (`_blast_radius_normalization.py` imports only `_blast_radius_glob`), but placing the two runtimes' predicate in structurally different modules would break the one-to-one port mapping the modules' headers assert. A **new leaf module in both runtimes** is the only design that satisfies both the size limit and the cycle constraint.

Sibling module sizes for reference: `_blast_radius_guards.py` 96, `_blast_radius_thresholds.py` 73, `_blast_radius_normalization.py` 107 — small leaf modules are the established pattern here.

---

## 2. Implementation Surfaces That Must Change In Lockstep

### 2.1 Production code

| # | Path | Role | Status |
| --- | --- | --- | --- |
| 1 | `scripts/dev_tools/_blast_radius_token_shapes.py` | **NEW** leaf module: token-shape rejection rules | Authoritative Python reference |
| 2 | `scripts/dev_tools/_blast_radius_extraction.py` | Import the new module; call the guard in `classify_path_token`; relocate `spans_multiple_feature_folders` and its two constants out to buy headroom | Production |
| 3 | `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | **NEW** leaf module, port of #1 | Destination-runtime production |
| 4 | `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | Mirror of #2; import the new module and re-export `Test-MultipleFeatureFolderSpan` following the `Get-OrdinalSortedEntry` pattern | Destination-runtime production |

Relocation safety verified: `spans_multiple_feature_folders` has exactly two references repo-wide, both inside `_blast_radius_extraction.py` (`:242` definition, `:358` call). No test and no other module imports it, and `compute_blast_radius.py:40-47` does not re-export it. `Test-MultipleFeatureFolderSpan` has three references, all inside `BlastRadiusExtraction.psm1` (`:236`, `:391`, `:495`); no `.Tests.ps1` file references it, so the only obligation is to preserve the existing export.

### 2.2 Byte-for-byte mirrors and what enforces each

| Mirror pair | Enforcer | Consequence of drift |
| --- | --- | --- |
| `.claude/**` ↔ `extensions/drm-copilot/resources/claude-customizations/.claude/**` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) asserts `read_text` equality for **every** repo `.claude` file except `settings.local.json` and `.claude/agent-memory/**` | pytest failure |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` ↔ `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:16,58` | pytest failure |
| `.claude/rules/parallel-orchestration.md` ↔ bundled copy | same `.claude/**` parity test as row 1 | pytest failure |
| `config/blast-radius.json` ↔ `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | bundle-side manifest completeness (`claude-pack-manifest-completeness.test.ts:216-235`) plus the config-carriage suite | see §4 — the recommendation avoids touching this file |

So items 3 and 4 in §2.1 each require an identical bundled counterpart. Item 3 is a new bundled file.

### 2.3 Registration surfaces a new `.psm1` triggers

These are easy to miss and each fails only at a gate:

| Path | Why | Enforcer |
| --- | --- | --- |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | a bundled `.claude/lib/**` file absent from every manifest is silently dropped from a pack-scoped push-down | `BlastRadius.Manifest.Tests.ps1:44-59` (discovers `*.psm1` on disk, requires manifest membership) **and** `claude-pack-manifest-completeness.test.ts:120-122,199-214` (recursive `.claude/lib` walk) |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `CodeCoverage.Path` is an explicit per-file allow-list (`:148-153`). A new `.psm1` omitted from it falls outside the coverage denominator, which the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` prohibits | Pester coverage gate; policy audit |
| its bundled mirror | byte parity | `test_poshqc_bundled_parity.py` |

Note: `pack-manifests/**` is deliberately outside the `.claude/**` parity scope (`test_push_down_claude_resource_contracts.py:129-146`), so `core.json` is edited in the bundle only and has no repo-root counterpart.

**`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is a declared shared surface** (`config/blast-radius.json:13`). Touching it means this item's own blast radius must enumerate it in `shared_surfaces`, and it will legitimately contend with any concurrent item that adds a PowerShell module.

### 2.4 Bash surfaces — verified not involved

`.claude/lib/bash/` contains nine scripts. A grep for `classify|inline|backtick|extract|plan_text|PlanPaths` returns only YAML-fence and scalar-classification hits in `parallel-yaml-scan.sh` and `parallel-yaml-emit.sh`. The bash layer parses an **already-declared** `blast_radius` block out of the manifest frontmatter (`parallel-items-validate.sh`) and colours the supplied edge list (`compute-cohorts.sh`, `parallel-cohorts.sh`). No bash surface performs path-token extraction. **No bash change is required.**

### 2.5 TypeScript surfaces — verified not involved

A grep for `classifyPathToken|extractPlanPaths|RECOGNIZED_PATH_EXTENSIONS|KNOWN_TOP_LEVEL` returns exactly one code file, `scripts/dev_tools/_blast_radius_extraction.py`; the remaining hits are documentation. There is no TypeScript port of the extractor.

`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` is unrelated: it derives a destination **module map** from a directory scan and carries five source keys verbatim (`CARRIED_KEYS`, `:153-159`). It never classifies a path token. It is affected only if the fix adds a `config/blast-radius.json` key — which is the main reason §4 recommends against that.

### 2.6 `config/blast-radius.json` — recommended **not** to change

Three independent reasons:

1. **Wrong kind of fact.** `mandate_reads` is config because it is a repository-specific *path list*. A placeholder marker set is a token-syntax fact, in the same category as `RECOGNIZED_PATH_EXTENSIONS` and `KNOWN_TOP_LEVEL_SEGMENTS`, both of which are module constants.
2. **Push-down cost.** A new key must be appended to `CARRIED_KEYS` in `claude-blast-radius-derive-core.ts`, inserted into the assembly literal at `:442-449`, and covered in `blast-radius-derive-core.test.ts`, plus the two byte-mirrored config copies.
3. **Collision with #508.** Issue #508 is open and is specifically about `config/blast-radius.json` losing destination-local entries on push-down because it has no merge decorator. Adding a key now lands in the middle of that file's contested carriage semantics.

---

## 3. Marker-Set Decision — Per-Marker Trace and Corpus Evidence

### 3.1 Per-marker behaviour, traced against the code

The delegation prompt requires an empirical determination per marker rather than an assumption. `classify_path_token` is pure with no I/O and five straight-line branches, so a line-cited trace is a verifiable determination; the executable confirmation is recorded as **EXECUTION-PENDING** below.

Probe token per marker, traced through `_blast_radius_extraction.py:319-363`:

| Marker | Probe token | Step 2 (`/`, leading `/`, leading-segment `:`) | Step 3 extension | Step 4 (`*`-free) | **Current verdict** | Changes behaviour? |
| --- | --- | --- | --- | --- | --- | --- |
| `<` `>` | `<FEATURE>/spec.md` | passes: has `/`, no leading `/`, `<FEATURE>` has no `:` | `md` ∈ recognized | no `*` → accept | **`concrete`** | **Yes** |
| `${` | `${FEATURE}/spec.md` | passes: `${FEATURE}` has no `:` | `md` ∈ recognized | no `*` → accept | **`concrete`** | **Yes** |
| `${` | `${VAR}/y.cs` | passes | `cs` ∈ recognized | no `*` → accept | **`concrete`** | **Yes** |
| `$(` | `$(pwd)/x.md` | passes: `$(pwd)` has no `:` | `md` ∈ recognized | no `*` → accept | **`concrete`** | Yes, but zero corpus incidence |
| `%` | `%FEATURE%/spec.md` | passes | `md` ∈ recognized | no `*` → accept | **`concrete`** | Yes, but zero corpus incidence |

**The issue's scope correction is wrong, and the probable cause is identifiable.** The issue states `${VAR}/y.cs` "was **not** reproduced as extracting — that form is already rejected." No branch in either runtime distinguishes `${VAR}` from `<FEATURE>`: both are wildcard-free, colon-free leading segments followed by a recognized extension. The likely explanation is PowerShell string interpolation in the probe harness. Inside a double-quoted PowerShell string, `"${VAR}/y.cs"` expands `${VAR}` to the empty string when `$VAR` is unset, yielding the literal `/y.cs`, which the leading-separator guard at `BlastRadiusExtraction.psm1:341` rejects. The same idiom appears in this repository's own test file at `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1:50` — `$token = "${_}thing/**"` relies on exactly that expansion — so the harness pattern is idiomatic here and easy to trip over.

**Corroborating corpus evidence:** the `${...}` form is not merely traceable to acceptance, it is *in use*. `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/plan.2026-08-17T15-00.md` carries 71 inline-code tokens of the form `${FEATURE}/...` and `${EXT}/...`, and issue #487's plan carries one (`${WORKSPACE}/docs/features/potential/promoted-notes-feature.md`). If `${...}` were rejected, `${FEATURE}/spec.md` would not be a live token in a committed plan's harvest.

**Plan obligation (EXECUTION-PENDING):** the plan must include a single-quoted-literal probe for each of the five markers in both runtimes, and must state explicitly that the PowerShell cases use single-quoted strings or `[char]` concatenation so no interpolation can occur. A test written with double quotes would reproduce the original mis-measurement.

### 3.2 The decisive argument: no marker-bearing token can ever produce a *true* edge

A `path_overlap` edge requires string-level agreement between two radii's entries. A marker-bearing token can agree only with another marker-bearing token spelled identically — never with a real repository path, because no tracked path contains a marker character.

Verification:
- `<` and `>` are Win32/NTFS-reserved characters and cannot appear in a file name at all. This repository is developed and CI-tested on Windows, so the angle-bracket rejection is **lossless by construction**, not merely lossless today.
- `$` and `%` are legal on Windows but absent from the tracked tree: `Glob **/*$*` and `Glob **/*%*` both return no files.

Consequence: rejecting any of the five markers removes only spurious edges. It cannot remove a true `path_overlap` edge, because there was never a real path on the other side of it. The `${EXT}/src/lib/pr-context/verification-evidence.ts` family in plan #485 illustrates this sharply — it is a genuine *write intent*, but as a contention token it is already broken, since it can never match the spelled-out `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` that another item would cite. Dropping it removes a spurious-edge source and forfeits no detectable true edge.

### 3.3 The false-negative class documented for the acceptance-gate guard largely does not transfer

`.claude/rules/plan-acceptance-gates.md` documents a false-negative class for its placeholder guard: a TypeScript generic, a comparison operator, a version constraint, an HTML/XML tag. Those examples were measured against *search literals*, which have no shape requirement. A path token must additionally satisfy the classifier's own shape rules, and each documented example fails them independently of any marker:

| Documented false-negative example | Fate under `classify_path_token`, before any placeholder guard |
| --- | --- |
| `ReadonlyArray<string>` (TS generic) | rejected at `:326` — no `/` |
| `Node >=18` (version constraint) | whitespace-split by `extract_inline_code_tokens:237`; neither `Node` nor `>=18` contains `/` |
| `a > b` (comparison) | same — whitespace-split, no `/` |
| `<div>` (markup tag) | rejected at `:326` — no `/` |

Measured against the corpus: zero accepted-shape tokens containing `%` (`rg` count 0) and zero containing `$(` (count 0). The false-positive exposure the acceptance-gate rule had to accept is therefore substantially smaller here.

### 3.4 Recommendation: option (a), reuse the exact five-marker set

**Recommended: option (a) — reject a token containing any of `<`, `>`, `${`, `$(`, `%`.**

| Criterion | Option (a) five markers | Option (b) bracket pairs enclosing an identifier |
| --- | --- | --- |
| Covers `<FEATURE>/spec.md` | Yes | Yes |
| Covers `${FEATURE}/spec.md`, `${EXT}/...` (71 live corpus tokens) | Yes | Only if `${...}` counts as a "bracket pair" — the option as stated in the issue says *bracket* pairs, which reads as angle brackets and would leave the largest live family accepted |
| Covers `%VAR%/x.md`, `$(cmd)/x.md` | Yes | Requires a further sub-rule per delimiter family |
| True edges lost | None (§3.2) | None |
| Implementation | one substring test over a five-element marker tuple; trivially portable to PowerShell with `IndexOf` | a regex with an identifier-class definition, which must be character-identical across `re` and .NET regex — a new parity hazard in a module whose header already documents named-group syntax divergence |
| Agreement with the sibling rule set | Exact. `.claude/rules/plan-acceptance-gates.md` already fixes this marker set, so the two subsystems stop disagreeing, which is the issue's stated motivation | Introduces a second, differently-shaped definition — the outcome the issue explicitly asks to avoid |

The false-negative trade, stated explicitly: option (a) will reject any future token that uses `<`, `>`, `$`, or `%` as an ordinary character in a repository path. For `<` and `>` that trade costs nothing, ever, because those characters are unrepresentable in a Windows path. For `$` and `%` the trade is a real but currently empty exposure: no tracked file carries either character, so the cost is zero today and would surface only if such a file were added. That is a materially better trade than the acceptance-gate rule had to accept, and it does not require re-litigating option (b)'s narrowing.

The false-positive trade, stated explicitly: option (a) rejects real write intent expressed through an abbreviation (`${EXT}/...`). §3.2 establishes that such a token was never a working contention signal, so the loss is nominal. The mitigation is the same one #489 recorded for `mandate_reads`: the planner remains obliged to enumerate a genuine write explicitly, and drift detection (`detect_escaped_paths`) catches a write against observed diff evidence rather than against plan prose.

### 3.5 One genuine fail-open exposure, measured to be empty

`resolve_shared_surfaces` (`_blast_radius_validation.py:265-293`) matches concrete entries against `shared_surface_globs`. A placeholder-bearing concrete token such as `scripts/dev_tools/validate_<thing>.py` currently *does* match the configured glob `scripts/dev_tools/validate_*.py`, so it is currently reported as a touched shared surface. Dropping the token loses that V2 signal. This is the only fail-open direction the fix introduces, and the design doctrine names radius under-reporting as the dominant risk, so it must be recorded rather than glossed.

Measured exposure: a search for `` `scripts/dev_tools/(validate_|_orchestrator_state_|_epic_orchestrator_state_)[^`\s]*<[^`\s]*` `` across `docs/features/active/**` returns **zero matches**. No committed plan exercises this case.

Recommended handling: accept the exposure, pin it with an explicit regression test that documents the trade, and record the planner obligation in the rule-file amendment (§8) using the `mandate_reads` constraint-1 language already in force.

---

## 4. Corpus Measurement

### 4.1 Scope

Denominator: 58 top-level plan documents under `docs/features/active/*/plan*.md` (67 `plan*.md` files matched, of which 6 are QA-gate evidence artifacts under `evidence/qa-gates/` and 1 is `evidence/other/plan-reconciliation...`, all excluded).

### 4.2 Incidence of accepted placeholder tokens

| Measurement | Files | Occurrences |
| --- | --- | --- |
| Plans carrying at least one inline-code token that contains an `<identifier>` pair, a `/`, and a recognized final extension (i.e. accepted by the classifier) | **22 of 58 (38%)** | 414 |
| Plans carrying at least one `` `<FEATURE>/...` `` token | 12 | 332 |
| Plans carrying at least one `` `${identifier}/...` `` token | 2 | 72 |
| Plans carrying a `$(...)`-bearing accepted token | 0 | 0 |
| Plans carrying a `%`-bearing accepted token | 0 | 0 |

Note that `` `<FEATURE>/evidence/<kind>/` `` itself is **already rejected**: its final component after the last `/` is the empty string, so `has_extension` is false and step 4 rejects it. Only the leaf-file forms are accepted.

### 4.3 The spurious cliques, by exact shared token

Two radii conflict on `path_overlap` when they share an entry string. The clique structure therefore follows exact token identity, not the placeholder family:

| Exact token | Distinct plan files citing it | Spurious edges induced (`C(n,2)`) |
| --- | --- | --- |
| `<FEATURE>/evidence/baseline/phase0-instructions-read.md` | **9** | **36** |
| `<FEATURE>/spec.md`, `<FEATURE>/issue.md`, `<FEATURE>/plan.md`, `<FEATURE>/user-story.md` (family) | 8 | up to 28 |
| `.claude/state/powershell-batch-budget.<session_id>.json` | 4 | 6 |

The nine plans sharing `<FEATURE>/evidence/baseline/phase0-instructions-read.md` are `334`, `344`, `369`, `396`, `413`, `423`, `442`, `462`, `479` — thematically unrelated work. The `<FEATURE>/spec.md` family set is `334`, `369`, `413`, `423`, `442`, `462`, `479`, `491`; the union with the phase0 set is 10 files and the intersection is 7, so those ten items form one dense connected component whose densest subgraph is a complete K9.

**Cohort consequence.** `scripts/dev_tools/parallel_cohort_computation.py` assigns cohorts by deterministic greedy (Welsh-Powell) graph colouring, where a cohort is one colour class. A K9 clique requires at least nine colours, so those nine items land in at least nine distinct cohorts and execute strictly serially, whatever `max_concurrency` is set to. The root cause is structurally identical to the two defects #489 fixed: the token originates in a *mandated* artifact — `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:12` declares `<FEATURE>/evidence/<kind>/` the non-overridable canonical scheme, so every compliant plan restates it, and a signal that fires on every compliant plan carries no information about contention.

### 4.4 Before/after measurement design, with the positive control

The plan must produce a single evidence artifact at `<FEATURE>/evidence/qa-gates/conflict-graph-density.<timestamp>.md` recording, for the same item set, before and after the fix:

1. **Item set.** The 58 top-level plans under `docs/features/active/*/plan*.md`, enumerated deterministically and sorted, with the count asserted non-zero so a broken glob fails loudly instead of passing vacuously (the non-vacuity discipline in `BlastRadius.Parity.Tests.ps1:194-230`).
2. **Radius per item.** `derive_blast_radius(plan_text, spec_text, feature_folder, committed_config, computed_at=<fixed>)` with a constant `computed_at`, so the run is deterministic. `spec_text` is the sibling `spec.md` when present, else `""`.
3. **Edge set.** `conflicts(radius_a, radius_b, config)` over every canonical ascending pair; record each edge with its reason kind and detail, using the same `'a-b'` rendering as the #489 regression harness.
4. **Density.** `|E| / C(n,2)`, reported to one decimal place.
5. **Cohorts.** `compute_cohorts` over the edge set; report cohort count and maximum cohort width.
6. **Positive control — three independent guards against a density collapse.** The delegation prompt correctly requires that an over-broad fix be distinguishable from the intended narrow improvement:
   - **6a. Total-entry accounting.** Report the total number of `paths` entries across all radii before and after, plus the *set difference*. Every dropped entry must contain a marker character. A dropped entry with no marker is a defect. This is the strongest control because it is exact rather than statistical.
   - **6b. Named survivor assertions.** Assert that a fixed list of real paths survives, including at least one from each acceptance rule: a recognized-extension file (`scripts/dev_tools/compute_blast_radius.py`), a line-suffixed citation (`config/blast-radius.json:12`), a known-segment subtree glob (`tests/scripts/dev_tools/**`), a configured root surface (`quality-tiers.yml`), and an own-feature-folder doc glob.
   - **6c. Surviving-edge identity.** Assert that a known-genuine edge survives with its reason unchanged. The #489 capture already provides one: `486`–`487` must still conflict on `extensions/drm-copilot/src/mcp-tools.ts` (`BlastRadius.Parity.Tests.ps1:321,386-403`). A fix that collapsed density would delete that edge too.
7. **Expected after-state, stated as a falsifiable prediction.** The K9 on `<FEATURE>/evidence/baseline/phase0-instructions-read.md` disappears entirely; the 36 edges it induced are removed unless the same pair also shares a real path. Predict the specific edge-count delta before running, so an unexpected larger delta is visible as a signal rather than absorbed as success.

---

## 5. Drop Silently Versus Diagnostic

**Recommendation: drop silently. Do not add a diagnostic channel in this fix.**

Evidence and reasoning:

1. **No channel exists at the seam, and adding one is a two-language contract change.** `classify_path_token` returns `PathTokenKind | None`; `Get-PathTokenKind` returns `[string]` or `$null`. Emitting a diagnostic requires widening that return, which propagates to `extract_paths_from_lines`, `extract_plan_paths`, `normalize_declared_radius`, and both PowerShell counterparts.
2. **A diagnostic cannot be surfaced through `validate_blast_radius` without a second extraction pass.** V1/V2 read the plan through the *same* `extract_plan_paths` (`_blast_radius_validation.py:330-335`). Post-fix, a placeholder is already gone before V1 sees it, so reporting it needs a second, unfiltered harvest — a new API in both runtimes, mirrored, with fixture-corpus consequences.
3. **It would be inconsistent with four sibling rules.** Every existing rejection is a silent drop: directory-shaped tokens, corpus-spanning doc globs, letterless contract tokens, and the removal of `artifacts/` from `KNOWN_TOP_LEVEL_SEGMENTS`. Singling out the fifth for a warning has no principled basis.
4. **Authoring quality is already owned elsewhere, and better.** The issue's concern — that a plan citing `<FEATURE>/spec.md` is under-specified — is a plan-authoring concern. `.claude/rules/plan-acceptance-gates.md` owns exactly that domain, already applies the identical marker set to plan text, already carries the authoring guidance, and already has a working non-blocking channel (`PLAN GATE WARNING: ` on stderr, exit code derived from the error channel alone). Duplicating the signal inside the blast-radius classifier would put two subsystems in the business of judging plan wording.
5. **The advisory precedents do not fit.** `parallel_lane_assertion.py` is a standalone CLI diagnostic over a manifest, invoked advisory-only with exit 0 — not a per-token hook inside a pure classifier. The `RadiusFinding` Advisory severity used by V3 is a closer fit, but adding a `V4` extends `FINDING_RULES`, which `_blast_radius_validation.py:53-61` designates a contract literal consumed by downstream parallel features, and would perturb the `expected.findings` block of every parity fixture.

If a diagnostic is wanted later, the correct home is `.claude/rules/plan-acceptance-gates.md` as a new plan-gate warning rule, measured the way G5 and G6 were measured. That is a separate feature.

---

## 6. Parity-Test Obligation

### 6.1 Existing parity machinery

| Artifact | Role |
| --- | --- |
| `tests/fixtures/blast_radius/*.json` | The shared corpus that pins both runtimes. 32 files at the directory top level; `verification-integrity/` is a subdirectory and is not part of the glob. |
| `tests/scripts/dev_tools/test_blast_radius_parity.py` | Python side. `FIXTURE_DIR` at `:50`, `MINIMUM_FIXTURE_COUNT = 26` at `:56`, glob at `:170`; asserts radius, findings, conflict verdict, and conflict reasons per fixture, plus three non-vacuity tests at `:319-359`. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | PowerShell side over the same corpus. `$minimumFixtureCount = 26` at `:57`; three non-vacuity tests at `:194-231`; the #489 before/after regression at `:301-405`. |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` (156 lines) | Python unit tests for the #489 shape rules. |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` (460 lines) | PowerShell mirror of the above. **Only 40 lines of headroom** — do not host the new cases here. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | The byte-parity enforcer for the `.claude` payload (§2.2). |

### 6.2 Required new test artifacts

Layout follows `.claude/rules/general-unit-test.md` (tests mirror production layout; no colocation; no temporary files). Every input below is an in-memory literal or a committed fixture, matching the existing suites' stated discipline.

**New module tests (mirroring the two new production modules):**

- `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` — the placeholder predicate and the relocated feature-corpus-span predicate. Cases: one per marker (`<FEATURE>/spec.md`, `${FEATURE}/spec.md`, `${VAR}/y.cs`, `$(pwd)/x.md`, `%FEATURE%/spec.md`), each asserted rejected; a marker in the *filename* position (`x/y.<TS>.md`) rejected; a marker-free real path accepted; the empty string and a marker-only token handled without raising.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` — the character-for-character mirror. **Mandatory constraint: every probe string must be single-quoted or built by concatenation.** A double-quoted `"${FEATURE}/spec.md"` interpolates to `/spec.md` and would silently re-create the mis-measurement recorded in §3.1. This constraint should appear as a comment in the test file, not only in the plan.

**Extension of the existing shape-rule suites:**

- `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` — add a parametrized rejection test asserting `classify_path_token` returns `None` for each marker probe, and a companion test asserting a real path cited on the *same* plan line is still harvested (the issue's stated unit requirement).
- Add the same two cases to the new `BlastRadiusTokenShape.Tests.ps1` rather than to the near-full `...Path.Tests.ps1`.

**New shared fixtures** (each requires the same `input`/`expected` shape as `derivation-directory-shaped-rejected.json`, and each is automatically asserted by *both* parity suites):

| Fixture | Purpose |
| --- | --- |
| `derivation-placeholder-token-rejected.json` | A plan whose task lines cite `<FEATURE>/spec.md`, `${FEATURE}/issue.md`, and one real path. `expected.radius.paths` contains the real path and the feature-folder glob only. Directly encodes the issue's unit requirement. |
| `derivation-placeholder-marker-variants.json` | One task line per marker (`%`, `$(`, `${`, `<`), all rejected. This is the fixture that makes the §3.1 determination executable in both runtimes, retiring the assumption in the issue's scope correction. |
| `conflict-placeholder-only-overlap.json` | Two radii whose only shared entry is a placeholder token, with disjoint real files. `expected.conflict` is `false`. This is the issue's integration probe expressed as a fixture rather than a script. |
| `conflict-real-path-overlap-preserved.json` | Two radii sharing a real file. `expected.conflict` stays `true` — the negative control the issue requires. If an equivalent fixture already covers this (`conflict-path-overlap.json`), reuse it and record the reuse rather than duplicating. |
| `validation-placeholder-self-consistent.json` | A radius derived from a placeholder-citing plan validates clean against that same plan: `expected.findings` is `[]`. This pins the V1/V2 symmetry property, mirroring `validation-mandate-read-self-consistent.json`. |

**Counter bumps (both must move together or the corpus floor goes stale):**

- `MINIMUM_FIXTURE_COUNT` in `test_blast_radius_parity.py:56`, currently 26.
- `$minimumFixtureCount` in `BlastRadius.Parity.Tests.ps1:57`, currently 26.

**Retrospective-cleaning test:** add a case asserting `normalize_declared_radius` / `Get-NormalizedDeclaredRadius` strips a placeholder entry from an already-recorded radius while preserving its real entries and re-resolving `modules` and `shared_surfaces`. This is what proves the seam choice in §1.2 and mirrors how #489 was demonstrated.

**Fail-open trade test:** a case asserting `scripts/dev_tools/validate_<thing>.py` is dropped and therefore no longer reported as a touched shared surface, with a docstring recording that this is the accepted trade of §3.5 and citing the planner's explicit-enumeration obligation.

### 6.3 Coverage obligations

New production lines in two new modules must satisfy line >= 85% and, for Python, branch >= 75% (`.claude/rules/quality-tiers.md`). PowerShell has no branch gate (Pester does not measure it), but the new `.psm1` must appear in the `CodeCoverage.Path` allow-list per §2.3 or its lines leave the denominator, which the Coverage Exclusion Policy prohibits.

---

## 7. Interactions With Adjacent Open Issues

| Issue | State (verified 2026-08-22 via GitHub) | Overlapping files | Independent of #502? |
| --- | --- | --- | --- |
| **#500** — blast-radius `claude-runtime` umbrella serializes all work | Open | `.claude/rules/parallel-orchestration.md` and its bundled mirror; `config/blast-radius.json` (`mandate_reads` extension); the real fix target is `PAYLOAD_MODULES` in `claude-blast-radius-derive-core.ts:131-135`, which injects `claude-runtime: [".claude/**"]` into every *derived destination* config | **Independent in mechanism, overlapping in one file.** #500 is a module-map/config defect; #502 is a token-shape defect. This repository's `config/blast-radius.json:28-36` already carries no `claude-runtime` module, which is consistent with #500 having been observed in a push-down destination rather than here. The overlap is the rule file: both amend `.claude/rules/parallel-orchestration.md`. Because the recommendation in §2.6 avoids `config/blast-radius.json`, the two items collide on exactly one file pair (the rule file and its mirror). Sequence them, or accept one `path_overlap` edge. Note that the two fixes are *complementary*: in a destination where `claude-runtime` exists, `.claude/skills/<name>/SKILL.md` currently produces both a spurious `path_overlap` (fixed by #502) and a spurious `module_overlap` (fixed by #500). |
| **#508** — blast-radius config has no merge decorator | Open | `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:53-64`; `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | **Independent**, provided §2.6 is followed. #502 touches neither file. Had #502 chosen the config route it would have collided directly, which is the third reason §2.6 rejects that route. |
| **#452** — blast-radius under-reporting gaps | Open (partially landed: the `root_surfaces` half is in the code and cited at `_blast_radius_extraction.py:311-318`) | `_blast_radius_extraction.py`, `_blast_radius_validation.py` | **Independent in direction, same file.** #452 is fail-*open* (radius under-reports); #502 is fail-*closed* (radius over-reports). #502 narrows the radius, so it moves in #452's adverse direction and the plan must state that explicitly. §3.2 is the argument that the movement is nominal: a dropped token could never have matched a real path, so no true edge is lost. The one exception — the shared-surface-glob case — is §3.5, measured empty. The file-level collision on `_blast_radius_extraction.py` is real; if #452's remaining work is scheduled concurrently, one `path_overlap` edge is correct and expected. |

---

## 8. Rule-File Obligation

**Yes, the fix must amend `.claude/rules/parallel-orchestration.md`.** Enforcement in this repository is prose plus validator logic and never an imported JSON Schema, so the prose is a load-bearing part of the contract, not commentary.

Exact location: the paragraph at **lines 236-240**, inside the `### Read-by-mandate classification` subsection of `## Blast-Radius Contention Doctrine (issue #489)`. Current text opens:

> The extractor additionally rejects three token shapes that were never write claims: a wildcard-free token whose final component names a directory rather than a file, a `docs/features/` glob whose wildcard occupies or truncates the feature-folder segment, and a contract token carrying no ASCII letter.

Required amendment, in outline (the planner authors the final prose; research does not modify policy files):

1. Change "three token shapes" to "four token shapes" and append the fourth: a token containing a placeholder or interpolation marker (`<`, `>`, `${`, `$(`, `%`).
2. State the marker set explicitly and cross-reference `.claude/rules/plan-acceptance-gates.md` as the origin, so the two subsystems are documented as agreeing rather than coincidentally similar.
3. Record the two-part rationale: a marker-bearing token can never string-match a tracked path (with the Windows-reserved-character argument for `<`/`>`), and the dominant instance originates in a mandated artifact — `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` declares `<FEATURE>/evidence/<kind>/` non-overridable, so every compliant plan restates it.
4. Restate the planner obligation in the `mandate_reads` constraint-1 form: when an item will actually write a path it expressed as a shape, it appends the concrete path to the declared radius.
5. Record the §3.5 fail-open trade and its measured-empty exposure, so a later reader does not mistake the omission for an oversight — the same discipline the file already applies to planner invariant P5.

The bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md:236-240` must receive the byte-identical edit; `test_push_down_claude_resource_contracts.py` fails otherwise.

`.claude/rules/plan-acceptance-gates.md` requires **no** change: its guard is unaffected, and the cross-reference is one-directional from the parallel-orchestration file.

---

## 9. Recommended Approach

### 9.1 Design

1. **New leaf module, both runtimes.** `scripts/dev_tools/_blast_radius_token_shapes.py` and `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`. Each holds the placeholder marker tuple, the placeholder predicate (`has_placeholder_marker` / `Test-PlaceholderToken`), and the relocated feature-corpus-span predicate with its two constants (`FEATURE_CORPUS_PREFIX`, `FEATURE_FOLDER_SEGMENT_INDEX`).
2. **Relocate, do not merely add.** Moving `spans_multiple_feature_folders` / `Test-MultipleFeatureFolderSpan` out of the extraction modules is what makes the change fit under the 500-line limit (§1.3). The PowerShell module re-imports and re-exports `Test-MultipleFeatureFolderSpan`, following the `Get-OrdinalSortedEntry` precedent at `BlastRadiusExtraction.psm1:40-45,491`.
3. **Guard placement.** In `classify_path_token`, immediately after the root-surface test and before the separator test. Ordering rationale, which must appear as a decision-logic comment: a configured root surface is an exact ordinal match against a real repository path and can never carry a marker, so testing it first costs nothing and keeps the #452 rule's precedence visible; running the marker test before the separator test means a marker-bearing token is rejected for the right reason rather than incidentally.
4. **Silent drop.** Return `None` / `$null`. No new API surface, no diagnostic channel (§5).
5. **Marker set hardcoded as a module constant**, not a config key (§2.6).
6. **Registration.** Add the new `.psm1` to `pack-manifests/core.json` and to the `CodeCoverage.Path` allow-list in both copies of `pester.runsettings.psd1` (§2.3).
7. **Rule-file amendment** per §8, in both copies.

### 9.2 Ordered file-change map

*Production*
1. `scripts/dev_tools/_blast_radius_token_shapes.py` — new
2. `scripts/dev_tools/_blast_radius_extraction.py` — import, guard call, relocation
3. `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` — new
4. `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` — mirror of 2

*Byte-identical mirrors (enforced by `test_push_down_claude_resource_contracts.py`)*
5. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`
6. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1`

*Registration and policy*
7. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
8. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — **declared shared surface**, must be enumerated in this item's `shared_surfaces`
9. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
10. `.claude/rules/parallel-orchestration.md`
11. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`

*Tests and fixtures* — per §6.2, plus the two `MINIMUM_FIXTURE_COUNT` / `$minimumFixtureCount` bumps.

*Evidence* — `<FEATURE>/evidence/qa-gates/conflict-graph-density.<timestamp>.md` per §4.4, plus the standard baseline and final-QA artifacts for Python and PowerShell.

### 9.3 Rejected alternatives

- **Guard in `extract_plan_paths` only.** Rejected: misses the spec-text harvest in `derive_blast_radius` and misses `normalize_declared_radius` entirely, so already-recorded radii stay dirty (§1.2).
- **Marker set as a `config/blast-radius.json` key.** Rejected: wrong category of fact, forces a `CARRIED_KEYS` change in the push-down derivation core, and lands inside #508's contested file (§2.6).
- **Option (b), bracket pairs enclosing an identifier.** Rejected: as stated it leaves the 71 live `${...}` corpus tokens accepted, introduces a second definition where the issue asks for agreement, and adds a cross-runtime regex-parity hazard for no measured false-positive reduction (§3.4).
- **Emit a diagnostic or a new `V4` Advisory finding.** Rejected: no channel at the seam, requires a second unfiltered extraction pass, inconsistent with four sibling silent rejections, and duplicates a concern `.claude/rules/plan-acceptance-gates.md` already owns with a working warning channel (§5).
- **In-place edit of the two extraction modules without relocation.** Rejected: arithmetically impossible against 3 and 2 lines of headroom (§1.3).
- **Reject the token only when it appears in a plan, not in a recorded radius.** Rejected: it is exactly the asymmetry that would break the V1 self-consistency invariant and leave `normalize_declared_radius` unable to clean historic data.

---

## 10. Behaviour Semantics and Edge Cases

- **Success condition.** For every token containing any of `<`, `>`, `${`, `$(`, `%`, both runtimes return no classification, and the token appears in no radius level.
- **Marker position is irrelevant.** The test is containment, not prefix. `x/y.<TS>.md` (marker in the filename) and `<FEATURE>/spec.md` (marker in the leading segment) are both rejected. The corpus contains both forms.
- **Whitespace interaction.** `extract_inline_code_tokens` (`:233-239`) splits each inline-code span on whitespace runs before classification, so a `$(git rev-parse)/x.md` span yields the two tokens `$(git` and `rev-parse)/x.md`. The first is rejected for having no `/`; the second contains `)` but **no marker**, and would still be accepted. This is a genuine residual gap in the marker approach and must be recorded rather than assumed away. It is not a regression (the behaviour is unchanged) and the corpus incidence of `$(` is zero, so the recommendation is to document it in the rule-file amendment as a known residual rather than to widen the marker set to closing delimiters.
- **Ordering.** The marker test runs after the root-surface test and before the separator test; a configured root surface is separator-free and marker-free by construction, so no ordering conflict arises.
- **Empty and degenerate input.** An empty token, a marker-only token, and a token that is exactly `<>` must all be handled without raising. `AllowEmptyString` is already declared on the PowerShell parameter (`:321-322`).
- **Determinism.** The predicate is pure containment over a fixed constant tuple; no clock, no randomness, no I/O. Output collections remain deduplicated and ordinally sorted, so the two runtimes stay byte-comparable.
- **Backward compatibility.** The change is a pure narrowing of the accepted set. No radius gains an entry. Every existing fixture whose plan text is marker-free produces a byte-identical result, which the 32-fixture corpus verifies in both runtimes.

---

## Automation Feasibility

**Assessment: every step of the fix and its verification can be performed unattended by an agent. No step requires human interaction.**

Enumerated per phase:

| Step | Unattended? | Basis |
| --- | --- | --- |
| Read policy files, issue, spec, plan | Yes | file reads only |
| Author the two new leaf modules and edit the two extraction modules | Yes | file writes |
| Reproduce the defect and confirm the five-marker determination | Yes | both libraries are pure and importable in-process (`poetry run python`, `Import-Module`). No network, no external service, no interactive prompt. The only hazard is the PowerShell double-quote interpolation trap of §3.1, which is a code-authoring constraint, not a human-interaction requirement. |
| Update the two byte-identical `.claude` mirrors | Yes | file copies; verified by `test_push_down_claude_resource_contracts.py` |
| Update `pack-manifests/core.json` and both `pester.runsettings.psd1` copies | Yes | file edits; verified by `BlastRadius.Manifest.Tests.ps1`, `claude-pack-manifest-completeness.test.ts`, `test_poshqc_bundled_parity.py` |
| Author new fixtures and tests; bump both corpus-floor counters | Yes | file writes |
| Python toolchain: `black` → `ruff` → `pyright` → `pytest --cov --cov-branch` | Yes | local, offline |
| PowerShell toolchain: `run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test` | Yes | local, offline, via MCP |
| TypeScript toolchain | Yes, and expected to be a no-op | no TS file changes (§2.5); run to confirm the manifest-completeness Jest suites still pass |
| Before/after conflict-graph density and cohort measurement (§4.4) | Yes | reads committed plan files; calls `derive_blast_radius`, `conflicts`, `compute_cohorts` in-process with a constant `computed_at`. Deterministic and repeatable. |
| Amend `.claude/rules/parallel-orchestration.md` and its mirror | Yes with one caveat | this research role is prohibited from modifying policy files, so the amendment is delegated to the executor as a plan task. That is a role boundary inside the automation, not a human-interaction requirement. |
| PR authoring and checkpoint updates | Yes | existing skills and hooks |

**Steps that cannot be performed unattended: none identified.**

Residual risks that could *become* blockers if not pre-empted in the plan, each with its pre-emption:

1. **500-line limit on the two extraction modules.** Pre-empted by mandating relocation (§9.1 step 2) rather than discovering the ceiling mid-execution.
2. **PowerShell string interpolation in test probes.** Pre-empted by the single-quote constraint being a stated plan requirement and an in-file comment (§6.2).
3. **Forgetting a registration surface.** Pre-empted by the explicit table in §2.3; each omission fails only at a gate, late.
4. **The `#500` rule-file overlap.** Pre-empted by scheduling: either sequence #502 and #500, or accept and declare the one `path_overlap` edge on `.claude/rules/parallel-orchestration.md`.
5. **Shared-surface enumeration.** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is a declared shared surface; omitting it from this item's `shared_surfaces` produces a V2 Blocking finding at validation time.

---

## Open Items For The Planner

1. Convert the §3.1 marker determination from a code trace into an executed, single-quoted probe in both runtimes, and record the result in `<FEATURE>/evidence/baseline/`. If any marker turns out to be already rejected, the marker tuple narrows accordingly and §3.4's recommendation is unchanged in shape.
2. Decide whether `conflict-real-path-overlap-preserved.json` is a new fixture or a documented reuse of `conflict-path-overlap.json`.
3. Fix the numeric before/after prediction of §4.4 step 7 before running the measurement, so the positive control is falsifiable rather than confirmatory.
4. Confirm the `#500` sequencing decision and record it, since it determines whether this item's declared radius should list the rule file at all.
