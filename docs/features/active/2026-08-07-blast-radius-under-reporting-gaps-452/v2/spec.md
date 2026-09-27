# 2026-08-07-blast-radius-under-reporting-gaps — v2 Regression Cycle (Spec)

- **Issue:** #452
- **Parent (optional):** epic parallel-orchestration, F1 follow-up (issue #447)
- **Owner:** drmoisan
- **Branch:** bug/blast-radius-under-reporting-regression-452
- **Baseline:** main at beae3f02
- **Last Updated:** 2026-09-27T12-45
- **Status:** Draft
- **Version:** 2.0
- **Work Mode:** full-bug (this document is the sole acceptance-criteria source for the v2 cycle; no user-story.md exists for this item)
- **Scope:** v2 regression cycle. The v1 documents in the feature root (issue.md, spec.md, the v1 plan, the v1 research, the v1 audits, and the v1 evidence tree) are read-only background and are not modified by this cycle.

## Context

### Problem Statement

Issue #452 recorded two under-reporting gaps in the F1 blast-radius library:

- **Gap 1.** Separator-free repository-root shared surfaces (poetry.lock, package-lock.json, quality-tiers.yml) could not be extracted from plan or spec text, so two items that both write one of them showed no shared-surface overlap.
- **Gap 2.** The contention relation treated a listed directory and a glob beneath it as disjoint, while the V1 subsumption helper treated a file under that directory as covered.

Both gaps were corrected by PR #453 under the v1 spec in the feature root. PR #453 did not carry a closing reference, so issue #452 remained open after the corrections merged.

This v2 cycle does three things:

1. Re-verifies, by execution, that every runtime that evaluates contention carries both corrections on current main.
2. Pins both corrections with one shared, two-direction regression corpus that the Python authority and the PowerShell port both consume, so that a later rewrite of extraction or contention (the sibling item #722, which addresses blast-radius over-reporting and zero-overlap tolerance) cannot silently reintroduce under-reporting.
3. Closes issue #452. The pull request body contains the literal text `Fixes #452`.

### Source Research

The v2 research artifact in this feature folder (v2/research/2026-09-27T12-15-blast-radius-regression-corpus-research.md, read-only) is authoritative for implementation detail: function signatures and line citations, the returned conflict structure, the fixture-driver discovery behaviour, the test-file line counts, and the corpus case traces.

The research verdicts for PowerShell were derived by code reading only; the research session had no shell tool. The Python verdicts were also derived by code reading. The orchestrator executed a subset on main beae3f02 with poetry run python on 2026-09-27:

- extract_plan_paths on a plan line naming poetry.lock returns a one-element tuple containing poetry.lock when root_surfaces contains poetry.lock, and an empty tuple without it.
- _entries_overlap returns True for the directory scripts/dev_tools against the glob scripts/dev_tools/** in both argument orders, and False for the directory scripts/dev_tools against the sibling glob scripts/dev_tools_extra/**.

No PowerShell verdict has been confirmed by execution. Phase 0 of the plan must confirm every runtime verdict by execution before any test is authored (see "Phase 0 Execution Requirements").

## Runtime Inventory

| Runtime | Location (read-only) | Evaluates contention | Corpus consumer | Research verdict |
| --- | --- | --- | --- | --- |
| Python authority | the blast-radius modules under scripts/dev_tools (extraction, validation, glob, conflicts, and the compute_blast_radius facade) | Yes: `conflicts(a, b, config)` returns a `ConflictResult` with `conflict` and ordered `reasons` | Yes | Gap 1 and Gap 2 corrected |
| PowerShell port | the blast-radius modules under .claude/lib/blast-radius, with a text-identical bundled copy under the extension's claude-customizations resources | Yes: `Test-BlastRadiusConflict` returns a hashtable whose `conflict` key carries the verdict and whose `reasons` key carries kind and detail entries | Yes | Gap 1 and Gap 2 corrected (code reading only) |
| TypeScript push-down derivation | the three claude-blast-radius-derive modules under the extension's push-down source folder | No | No (excluded) | Not applicable |
| bash cohort library | the parallel-cohorts and compute-cohorts scripts under .claude/lib/bash | No | No | Not applicable |

### TypeScript exclusion evidence

TypeScript is excluded from corpus consumption on the following evidence from research section 3:

- The TypeScript modules derive a destination module map and copy the version, shared_surfaces, shared_surface_globs, mandate_reads, mergeable_paths, and over_breadth_fraction keys verbatim from the bundled source. They do not extract plan tokens and do not compute overlap.
- A search for blast_radius, entriesOverlap, pathOverlap, and conflict function definitions under the extension source returns only validator shape checks and `validateConflictEdges`, which validates recorded edge shape rather than computing overlap.
- The carried surface list is already pinned by the existing TypeScript tests for verbatim shared_surfaces carriage and for source-constant parity with the committed bundled resource.

### bash exclusion evidence

The bash library contains no path-overlap, shared-surface-overlap, or entry-overlap logic. `pcoh_compute_cohorts` colors a caller-supplied edge list; it does not derive edges.

### Bundled configuration

The bundled blast-radius configuration under the extension's claude-customizations resources is not byte-identical to the root config/blast-radius.json, by design (issue #500 doctrine). Its separator-free shared_surfaces subset is the same set as the root configuration's separator-free subset: poetry.lock, package-lock.json, and quality-tiers.yml. The research records this with a complete two-derivation numeric evidence block (claims N1 and N2). This cycle asserts the equality of the two separator-free subsets as a set comparison computed at test time from both committed files, not as a hardcoded list or count.

### Conditional production correction

- If Phase 0 execution shows that the Python authority or the PowerShell port (root or bundled copy) is missing either correction for any corpus case, that runtime is corrected in this cycle. A PowerShell correction is applied to the root module and its bundled copy together, and the existing bundled-payload content-identity test must pass.
- If Phase 0 execution confirms both corrections in both runtimes, this cycle changes no production file. The change set is limited to the corpus file, the two consumer test files, and the v2 documents and evidence.
- A Phase 0 verdict that differs from the research trace by adding a reason or a conflict is recorded and investigated, but is not an under-report. A Phase 0 verdict that removes a reason or a conflict the research trace expects is treated as a missing correction and triggers the first bullet.

## Scope & Non-Goals

### In scope

- The shared regression corpus `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`.
- The Python consumer `tests/scripts/dev_tools/test_blast_radius_regression_452.py`.
- The Pester consumer `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`.
- Phase 0 execution evidence for both runtimes on both gaps, the mutation demonstrations, and QA gate evidence, stored under the v2 evidence tree `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/evidence` in the canonical baseline, regression-testing, and qa-gates kinds.
- This spec, `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md`, and the v2 plan in the same folder.
- A production correction only when the conditional in "Conditional production correction" fires.

### Non-goals

- No change to any v1 document in the feature root (issue.md, spec.md, the v1 plan, the v1 research, the v1 audits, the v1 evidence tree).
- No change to any existing file in the blast-radius parity fixture corpus. The v1 issue text describes that corpus as 21 files; it has grown since, and this non-goal covers every existing file in it and in its existing verification-integrity subfolder. No existing fixture is modified or deleted, and the parity-driver fixture-count floors are not changed.
- No change to the existing parity drivers or any other existing test file.
- No change to scheduling or cohort code in any runtime: the Python cohort computation, drift-detection, and mutation-protocol modules, and the bash cohort library, are read-only.
- No TypeScript change, production or test, unless the conditional production correction fires for a runtime that TypeScript mirrors. The research shows TypeScript mirrors neither the extraction nor the contention logic, so this is not expected.
- No change to the root or bundled blast-radius configuration.
- No token-level classification cases in the corpus. Token-level admission and rejection (including the case-variant and unconfigured-file rejections) are already pinned by the existing Python and Pester extraction token matrices (research section 5); this corpus pins the relation-level and plan-to-verdict outcomes that no existing test covers.
- No bats test is added.

## Corpus Contract

### Path

The corpus lives at exactly `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`.

- The issue-numbered subfolder name makes a path collision with sibling #722 unlikely; the research found only one existing subfolder (verification-integrity) and confirmed this path absent at main beae3f02.
- Neither existing parity driver scans subfolders. The Python parity driver discovers fixtures with a non-recursive glob and cross-checks the on-disk count with a non-recursive directory listing; the Pester parity driver uses a non-recursive Get-ChildItem. A file in this subfolder is therefore not discovered by either driver and changes neither driver's fixture count or floor.

### Top-level shape

A single JSON object with:

| Field | Type | Rule |
| --- | --- | --- |
| schema_version | integer | 1 |
| issue | integer | 452 |
| description | string | non-empty |
| cases | array | non-empty; one object per case |

### Case shape

| Field | Type | Rule |
| --- | --- | --- |
| id | string | unique within the corpus; kebab-case |
| gap | integer | 1 or 2 |
| kind | string | radius_pair or plan_pair |
| direction | string | must-conflict or must-not-conflict |
| paired_case_id | string | the id of another case in the corpus (see "Pairing rules") |
| doctrine_pin | boolean | optional, default false; true only for a must-not-conflict case that pins designed non-conflict behaviour |
| config_ref | string | self_hosted (the root blast-radius configuration); mutually exclusive with config |
| config | object | an inline configuration mapping; mutually exclusive with config_ref |
| input | object | by kind, see below |
| expected | object | conflict (boolean) and reasons (array of objects with kind and detail) |

Exactly one of config_ref and config is present on each case.

Input by kind:

- radius_pair: radius_a and radius_b, each in the exact six-key radius shape accepted by the Python radius deserializer and the PowerShell conflict function (paths, modules, shared_surfaces, contracts, source, computed_at).
- plan_pair: plan_a and plan_b (plan text), feature_folder_a and feature_folder_b, and computed_at. Spec text is empty for both sides. Each side's radius is derived with `derive_blast_radius` (Python) or `Get-BlastRadius` (PowerShell) and the two derived radii are passed to the contention function.

Expected:

- conflict equals true for must-conflict cases and false for must-not-conflict cases. A consumer asserts this consistency as a corpus meta-check.
- reasons lists the exact reason kinds as named in the code (`path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency`), in that fixed order, each with its exact detail string. A path-overlap detail is the ordinally smaller entry, a space, a tilde, a space, and the ordinally larger entry. A set-level detail is the smallest common element. reasons is empty for must-not-conflict cases.
- Expected values are the values produced by Phase 0 execution. Where Phase 0 output differs from the research trace, the rule in "Conditional production correction" applies before the expected value is committed.

Every computed_at value uses the non-ISO shape of four-digit year, month, day, the letter T, hour, a hyphen, and minute (for example 2026-09-27T12-15), so that ConvertFrom-Json -AsHashtable does not convert it to a datetime.

### Pairing rules

- Every must-conflict case names, in paired_case_id, a must-not-conflict control case, and that control names the must-conflict case back. This reciprocal pairing links each positive to its matched negative control.
- A must-not-conflict case that is not the reciprocal control of any positive (the doctrine pin) names, in paired_case_id, the must-conflict case whose behaviour it bounds.
- Every paired_case_id resolves to a case in the corpus with the opposite direction and the same gap.

### Plan-line intent rule

- Every plan line in a must-conflict plan case and in every non-doctrine must-not-conflict plan case is a checkbox task line with a task identifier, followed by the explicit write verb Edit or Create, followed by the path wrapped in a backtick-delimited inline-code span, followed by a period. The verb Edit is used unless the case requires Create.
- Reason: sibling #722 may replace the current extraction with a write-intent-only extraction. The current extraction harvests any inline-code path in a task line regardless of verb, and a write-intent-only extraction harvests a path that follows an explicit write verb. A plan line with an explicit write verb therefore produces the same harvested path under both extractions, so these cases hold regardless of which of #452 and #722 merges first.
- Exception, the doctrine pin: the plan lines in the quality-tiers.yml mandate-read case use the read verb Read instead of a write verb. Under the current extraction, the token is admitted and then removed as a mandate read, so no conflict results. Under a write-intent-only extraction, a read-intent line is not harvested, so no conflict results. A write verb in this case would pin two items that both edit quality-tiers.yml as non-conflicting, which is an under-report and would contradict the doctrine that a genuine write is appended to the declared radius. The declared-radius case g1-radius-quality-tiers pins the genuine-write outcome.

## Case List

The corpus contains exactly the cases below, and no other cases. Feature folders for every plan case are 2026-09-27-regression-452-left (side A) and 2026-09-27-regression-452-right (side B); their derived feature-folder globs have diverging literal prefixes and never overlap. All radius_pair cases have empty modules, shared_surfaces, and contracts lists unless the row states otherwise.

### Gap 1 — plan to verdict (config_ref self_hosted)

| id | direction | plan A path and verb | plan B path and verb | expected reasons | paired_case_id |
| --- | --- | --- | --- | --- | --- |
| g1-plan-poetry-lock | must-conflict | Edit poetry.lock | Edit poetry.lock | path_overlap with detail "poetry.lock ~ poetry.lock"; shared_surface_overlap with detail "poetry.lock" | g1-plan-different-surfaces |
| g1-plan-package-lock | must-conflict | Edit package-lock.json | Edit package-lock.json | path_overlap with detail "package-lock.json ~ package-lock.json"; shared_surface_overlap with detail "package-lock.json" | g1-plan-unconfigured-root-file |
| g1-plan-different-surfaces | must-not-conflict | Edit poetry.lock | Edit package-lock.json | none | g1-plan-poetry-lock |
| g1-plan-unconfigured-root-file | must-not-conflict | Edit pyproject.toml | Edit pyproject.toml | none | g1-plan-package-lock |
| g1-plan-quality-tiers-mandate-read (doctrine_pin true) | must-not-conflict | Read quality-tiers.yml | Read quality-tiers.yml | none | g1-radius-quality-tiers |

The doctrine pin records designed behaviour, not an under-report: quality-tiers.yml is admitted at token level by the Gap 1 correction and is then removed because it is an exact mandate_reads entry in the root configuration. This is the "Read-by-mandate classification" doctrine in the parallel-orchestration rule (read-only).

### Gap 1 — declared radius (inline config with only version 1)

| id | direction | radius A | radius B | expected reasons | paired_case_id |
| --- | --- | --- | --- | --- | --- |
| g1-radius-quality-tiers | must-conflict | paths and shared_surfaces both contain only quality-tiers.yml | same as A | path_overlap with detail "quality-tiers.yml ~ quality-tiers.yml"; shared_surface_overlap with detail "quality-tiers.yml" | g1-radius-quality-tiers-vs-poetry-lock |
| g1-radius-quality-tiers-vs-poetry-lock | must-not-conflict | paths and shared_surfaces both contain only quality-tiers.yml | paths and shared_surfaces both contain only poetry.lock | none | g1-radius-quality-tiers |

This pair expresses the genuine-write path: a planner that appends quality-tiers.yml to a declared radius produces a conflict, because the contention function does not apply mandate_reads.

### Gap 2 — radius pairs (inline config with only version 1, except where stated)

| id | direction | radius A paths | radius B paths | expected reasons | paired_case_id |
| --- | --- | --- | --- | --- | --- |
| g2-dir-vs-glob | must-conflict | scripts/dev_tools | scripts/dev_tools/** | path_overlap with detail "scripts/dev_tools ~ scripts/dev_tools/**" | g2-dir-vs-sibling-glob |
| g2-glob-vs-dir | must-conflict | scripts/dev_tools/** | scripts/dev_tools | path_overlap with detail "scripts/dev_tools ~ scripts/dev_tools/**" | g2-sibling-glob-vs-dir |
| g2-dir-vs-sibling-glob | must-not-conflict | scripts/dev_tools | scripts/dev_tools_extra/** | none | g2-dir-vs-glob |
| g2-sibling-glob-vs-dir | must-not-conflict | scripts/dev_tools_extra/** | scripts/dev_tools | none | g2-glob-vs-dir |
| g2-artifacts-dir-vs-glob | must-conflict | artifacts/orchestration | artifacts/orchestration/** | path_overlap with detail "artifacts/orchestration ~ artifacts/orchestration/**" | g2-artifacts-dir-vs-sibling-glob |
| g2-artifacts-glob-vs-dir | must-conflict | artifacts/orchestration/** | artifacts/orchestration | path_overlap with detail "artifacts/orchestration ~ artifacts/orchestration/**" | g2-artifacts-sibling-glob-vs-dir |
| g2-artifacts-dir-vs-sibling-glob | must-not-conflict | artifacts/orchestration | artifacts/orchestration-archive/** | none | g2-artifacts-dir-vs-glob |
| g2-artifacts-sibling-glob-vs-dir | must-not-conflict | artifacts/orchestration-archive/** | artifacts/orchestration | none | g2-artifacts-glob-vs-dir |
| g2-empty-modules-dir-vs-glob | must-conflict | scripts/powershell/PoshQC | scripts/powershell/PoshQC/** | path_overlap with detail "scripts/powershell/PoshQC ~ scripts/powershell/PoshQC/**", and no module_overlap | g2-empty-modules-dir-vs-sibling-glob |
| g2-empty-modules-dir-vs-sibling-glob | must-not-conflict | scripts/powershell/PoshQC | scripts/powershell/PoshQCExtra/** | none | g2-empty-modules-dir-vs-glob |

The two g2-empty-modules cases use an inline config with version 1 and a modules map containing one module, poshqc, mapped to the glob scripts/powershell/**. That module map would match both radii, but the deserialized radii carry empty modules lists and the contention function reads modules only from the radii, so the path level is the only level that can report the overlap. This is the unmasked case that issue #452 names for deserialized radii with empty modules.

The artifacts cases cover the other unmasked case that issue #452 names: artifacts entries are accepted by extraction but absent from the module map. None of the configured mergeable_paths patterns matches these entries (research section 8); Phase 0 confirms this by execution.

All paths in the Case List are input data inside the corpus. None of them is written by this cycle.

## Consumers

### Python consumer

- Path: `tests/scripts/dev_tools/test_blast_radius_regression_452.py`. This mirrors the Python production location of the blast-radius modules under scripts/dev_tools, following the existing tests/scripts/dev_tools blast-radius test files.
- Loads the corpus relative to the test file's own location: the repository root is resolved from `__file__` by walking up to the repository root (the pattern used by the existing Python parity driver), and the corpus and the self_hosted configuration are joined from that root. The bundled configuration used for the parity assertion is resolved the same way.
- Parametrizes one test per case id. For radius_pair cases it deserializes both radii and calls `conflicts`; for plan_pair cases it derives both radii with `derive_blast_radius` under the referenced configuration and then calls `conflicts`. It asserts the verdict and the exact ordered list of reason kind and detail pairs.
- Includes corpus meta-tests: the top-level and case shapes, id uniqueness, the direction-to-verdict consistency, the pairing rules, the presence of both a must-conflict and a must-not-conflict case for each gap, and the plan-line intent rule.
- Includes the bundled-configuration parity test: `config_root_surfaces` over the root configuration and over the bundled configuration return the same set.
- Includes the tolerance-branch test defined in "Merge-Order Independence with #722".

### Pester consumer

- Path: `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`. This mirrors the PowerShell production location of the blast-radius modules under .claude/lib/blast-radius, following the existing tests/scripts/claude-lib/blast-radius Pester files.
- Loads the corpus relative to the test file's own location: the repository root is resolved from `$PSScriptRoot` (the pattern used by the existing Pester parity driver), and the corpus is parsed with ConvertFrom-Json -AsHashtable. The case list is built at discovery time, outside BeforeAll, so that It blocks can use -ForEach.
- For radius_pair cases it calls `Test-BlastRadiusConflict`; for plan_pair cases it derives both radii with `Get-BlastRadius` under the referenced configuration and then calls `Test-BlastRadiusConflict`. It reads the verdict from the conflict key of the returned hashtable (the hashtable itself is always truthy) and asserts the exact ordered reason kind and detail pairs.
- Includes the same corpus meta-tests as the Python consumer and the bundled-configuration parity test using `Get-ConfigRootSurface` over both committed configurations.
- Includes the tolerance-branch test defined in "Merge-Order Independence with #722".

### Loading constraints (both consumers)

- No dependency on the current working directory.
- No reference to origin/main and no git invocation.
- No read of the gitignored artifacts directory at runtime. The artifacts strings in the Gap 2 cases are input data only.
- No Windows-only path, drive letter, or backslash-separated path literal.
- No temporary file, temporary directory, TestDrive, or pytest tmp_path usage.
- No subprocess.

## Merge-Order Independence with #722

Sibling #722 may merge before or after this cycle. The corpus and both consumers must remain valid in either order.

- **Detection level only.** Every verdict assertion targets the Python `conflicts(a, b, config)` result (verdict and ordered reasons) or the PowerShell `Test-BlastRadiusConflict` equivalent. No assertion targets cohort scheduling, edge construction, coloring, or tolerance. Neither consumer calls `compute_cohorts`, `pcoh_compute_cohorts`, or any drift-detection or mutation-protocol function.
- **Plan-text cases.** The plan-line intent rule in "Corpus Contract" makes every plan case hold under both the current extraction and a write-intent-only extraction.
- **Signature change.** If #722 merges first and changes the signature of `conflicts`, `derive_blast_radius`, `Test-BlastRadiusConflict`, or `Get-BlastRadius`, only the consumers' call sites are updated. No corpus expected value is weakened to accommodate the change. A must-conflict case that stops conflicting after a #722 merge is an under-report regression and is reported as such.
- **Conditional tolerance requirement.** At execution start (after the branch is brought up to date with main), Phase 0 searches the working tree for a conflict_tolerance configuration key or a tolerance scheduling layer in any runtime, and records the search and its result as evidence.
  - If such a key or layer exists, each consumer adds assertions that, at the strictest tolerance setting, every must-conflict case still produces a scheduling edge, and those assertions pass.
  - If none exists, those assertions are skipped through an explicit, pre-authorized branch in each consumer (a pytest skip with a reason naming #722 and the absence of the tolerance layer, and a Pester Set-ItResult -Skipped with the same reason). The detection-level verdicts for every must-conflict case are recorded as evidence in place of the tolerance assertion. This branch is pre-authorized by this spec and is not a policy exception.
  - No tolerance layer exists at main beae3f02 (research section 6). The skip branch is therefore the expected outcome unless #722 merges before execution starts.

## Phase 0 Execution Requirements

Phase 0 of the v2 plan runs before any corpus or test file is authored and records its outputs under the baseline kind of the v2 evidence tree.

1. **Python, both gaps.** Execute, with poetry run python on a script file written to the session scratchpad (a multi-line poetry run python -c invocation is a silent no-op in this repository and must not be used), the research's proposed runtime confirmation script extended to compute the verdict and ordered reasons for every case in the Case List. Record the full output.
2. **PowerShell, both gaps.** Execute the equivalent calls against the root PowerShell modules: `Get-ConfigRootSurface`, `Get-PathTokenKind`, `Test-EntryOverlap`, `Get-BlastRadius`, and `Test-BlastRadiusConflict`, for every case in the Case List. If the worktree guard refuses a direct pwsh invocation, run a Pester file through the PoshQC MCP test tool and record the per-case pass or fail results; code reading alone does not satisfy this requirement.
3. **Comparison.** Record, per case, the Python verdict and reasons, the PowerShell verdict and reasons, and the research trace, and state whether all three agree. Apply the "Conditional production correction" rules to any disagreement.
4. **Tolerance search.** Record the tolerance-layer search defined in "Merge-Order Independence with #722".
5. **Bundled configuration.** Record the separator-free shared_surfaces subsets computed by `config_root_surfaces` over the root and bundled configurations.

## Test Strategy

- New tests only; no existing test is edited. The consumers are dedicated new files because several existing blast-radius test files are at or near the 500-line limit (research section 5 records, for example, the Python config and config-parity test files and the Pester config test file at or within one line of the limit) and because #722 is likely to edit the existing conflicts and extraction test files.
- **Mutation demonstration.** For each consumer, flip the expected conflict value (and the matching direction and reasons, so that only the verdict expectation is wrong) of one must-conflict case and one must-not-conflict case for each gap, one flip at a time, run the consumer, and record the failing output naming the flipped case. Restore the corpus after each flip and record that git reports no difference in the corpus file afterwards. The demonstration is an execution procedure recorded as regression-testing evidence; it is not committed as a test and creates no temporary file inside any test.
- **Toolchain, Python.** poetry run black, poetry run ruff check, poetry run pyright, and poetry run pytest with coverage and branch coverage, repeated from the first step if any step fails or changes files.
- **Toolchain, PowerShell.** The PoshQC MCP format, analyze, and test tools with the repository Pester runsettings, repeated from the first step if any step fails or changes files. The new Pester file is discovered through the existing runsettings test path, which includes tests/scripts; no runsettings change is needed.
- **CI.** The Python consumer runs in the pytest job of the quality-checks workflow. The Pester consumer runs in the poshqc workflow's Pester job, which runs on windows-latest; it is the only CI Pester job. No bats job is affected.

## Constraints

- 500-line limit for every new or changed test file and for any production file changed under the conditional correction.
- Tests must not create temporary files or directories.
- No bats test is added. In particular, no bats test that sources a script under set -u inside bash -c is introduced.
- No new dependency in any language.
- No new configuration key.
- Evidence is written only under the v2 evidence tree in the canonical kinds (baseline, regression-testing, qa-gates, other). No evidence is written under the repository artifacts directory.
- No absolute host paths in the corpus, the consumers, or the evidence.

## Acceptance Criteria

- [x] The corpus file `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` exists, parses as JSON, conforms to the top-level and case shapes in "Corpus Contract", contains every case id listed in "Case List" and no other id, and has unique ids; verified by the corpus shape and case-set meta-tests in `tests/scripts/dev_tools/test_blast_radius_regression_452.py`.
- [x] Every must-conflict case names a must-not-conflict control of the same gap that names it back, the doctrine-pin case names the must-conflict case it bounds, and every paired_case_id resolves to a case of the opposite direction and the same gap; verified by the pairing meta-test in both consumer files.
- [x] For each of gap 1 and gap 2, the corpus contains both a must-conflict case and a must-not-conflict case, and every case's expected conflict value matches its direction; verified by the direction meta-test in both consumer files.
- [x] The corpus pins quality-tiers.yml both as the documented mandate-read exclusion (the doctrine-pin plan case, expected no conflict) and as a declared-radius case that does conflict; verified by the per-case tests for g1-plan-quality-tiers-mandate-read and g1-radius-quality-tiers in both consumer files.
- [x] Every plan line in a must-conflict plan case and in every non-doctrine must-not-conflict plan case uses the write verb Edit or Create before the backticked path, and the doctrine-pin plan lines use the verb Read; verified by the plan-line intent meta-test in both consumer files.
- [x] Phase 0 Python execution evidence exists under the baseline kind of the v2 evidence tree, recording the executed verdict and ordered reasons for every Case List case on both gaps, produced by poetry run python on a scratchpad script file.
- [x] Phase 0 PowerShell execution evidence exists under the baseline kind of the v2 evidence tree, recording executed results for every Case List case on both gaps from the root PowerShell modules (direct invocation or the PoshQC MCP test tool), together with the per-case three-way comparison against the Python output and the research trace.
- [ ] The conditional production correction is resolved and recorded: either the Phase 0 evidence shows both corrections present in both runtimes and git diff --name-only between main and the branch head lists no file under scripts, .claude/lib, or extensions; or the evidence names the runtime missing a correction, that runtime (and, for PowerShell, its bundled copy) is corrected, the relevant consumer test is recorded failing before and passing after the correction, and the bundled-payload content-identity test passes.
- [x] `poetry run pytest tests/scripts/dev_tools/test_blast_radius_regression_452.py` passes, with the corpus and configurations loaded relative to the test file's `__file__`.
- [x] The Python mutation demonstration is recorded under the regression-testing kind of the v2 evidence tree: flipping the expected verdict of one must-conflict and one must-not-conflict case for each gap, one flip at a time, makes the Python consumer fail and name the flipped case, and git reports no difference in the corpus file after restoration.
- [ ] `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1` passes when run through the PoshQC MCP test tool with the repository Pester runsettings, with the corpus loaded relative to `$PSScriptRoot` and the case list built at discovery time.
- [x] The Pester mutation demonstration is recorded under the regression-testing kind of the v2 evidence tree with the same flips and the same property as the Python demonstration.
- [ ] Both consumers assert that the separator-free shared_surfaces subset of the bundled configuration equals that of the root configuration, computed at test time with `config_root_surfaces` and `Get-ConfigRootSurface` respectively; verified by the bundled-parity test in each consumer file.
- [ ] Merge-order independence holds: a text search of both consumer files finds no call to compute_cohorts, pcoh_compute_cohorts, or any drift-detection or mutation-protocol function, and every verdict assertion is made on the `conflicts` or `Test-BlastRadiusConflict` result.
- [ ] The conditional tolerance branch is resolved and recorded: the Phase 0 tolerance-layer search result is recorded as evidence, and either the strictest-tolerance scheduling-edge assertions exist and pass for every must-conflict case, or the pre-authorized skip branch is taken in both consumers with a reason naming #722 and the detection-level verdicts for every must-conflict case are recorded as evidence.
- [ ] Neither consumer depends on the current working directory, origin/main, the gitignored artifacts directory at runtime, a Windows-only path, a subprocess, or a temporary file or directory; verified by a text search of both consumer files for os.getcwd, Get-Location, origin/main, subprocess, tmp_path, TestDrive, New-TemporaryFile, and drive-letter path literals, with the result recorded under the qa-gates kind of the v2 evidence tree.
- [ ] The non-goals are untouched: git diff --name-status between main and the branch head lists no change to any v1 document in the feature root, no modified or deleted file in the existing blast-radius fixture corpus, no change to any existing test file, no change to the root or bundled blast-radius configuration, no change to scheduling or cohort code, and no TypeScript change (unless the conditional production correction fired and the evidence names the reason).
- [ ] Every file added or changed by this cycle, other than Markdown documents and the JSON corpus, is at or below 500 lines, verified by a line count recorded under the qa-gates kind of the v2 evidence tree.
- [ ] The full Python toolchain passes in a single pass: poetry run black, poetry run ruff check, poetry run pyright, and poetry run pytest with coverage and branch coverage, with line coverage at or above 85% and branch coverage at or above 75%, no coverage exclusion added, and no new suppression.
- [ ] The full PowerShell toolchain passes in a single pass: the PoshQC MCP format, analyze, and test tools with the repository Pester runsettings, with zero PSScriptAnalyzer findings and line coverage at or above 85%.
- [ ] All required CI checks are green on the pull request head commit, including the pytest job and the windows-latest Pester job.
- [ ] The pull request body contains the literal text `Fixes #452`.

## Risks & Mitigations

1. **Research verdicts were not executed.** The PowerShell verdicts and most Python verdicts come from code reading. Mitigation: Phase 0 executes every case in both runtimes before any file is authored, and expected values are taken from executed output.
2. **Sibling #722 merges first and changes extraction.** Mitigation: the plan-line intent rule, the Read-verb doctrine pin, and detection-level-only assertions. A must-conflict case that stops conflicting is reported as a regression, not absorbed by weakening the corpus.
3. **Sibling #722 merges first and adds a tolerance layer.** Mitigation: the conditional tolerance requirement adds strictest-tolerance scheduling-edge assertions in that case.
4. **Local-only failures.** The existing bundled-payload content-identity test enumerates the working tree, so untracked local files can fail it locally while CI is green. This cycle does not touch that tree unless the conditional correction fires; CI on the pull request head is the authoritative result.
5. **Discovery drift.** If a future change makes either parity driver recursive, the corpus would be discovered by a driver whose fixture shape it does not match. Mitigation: the corpus top-level shape (schema_version and cases) differs from the parity fixture shape, so such a change would fail visibly rather than silently; this cycle records the non-recursive discovery in the spec for the reviewer of that future change.

## Rollout & Follow-up

- Deliver the corpus, both consumers, and the v2 documents and evidence in one pull request against main, whose body contains `Fixes #452`.
- No deployment, migration, or configuration rollout is required.
- After merge, confirm that issue #452 is closed by the pull request.
- If #722 is still open at merge, its implementer must run both consumers against the #722 branch; the corpus is the regression gate for under-reporting in that work.

## Links

- Issue: https://github.com/drmoisan/drm-copilot/issues/452
- Sibling: issue #722 (blast-radius over-reporting and zero-overlap tolerance)
- Correcting pull request for v1: PR #453
- v2 research (read-only): v2/research/2026-09-27T12-15-blast-radius-regression-corpus-research.md in this feature folder
- v1 spec (read-only): spec.md in the feature root
- Layout precedent for a versioned scope: the archived push-down-copilot-customizations feature for issue 84, v2 subfolder
