# Research: product-name examples remain in generic rules (issue #894)

- Issue: #894 (bug, work mode minor-audit)
- Branch: bug/product-name-examples-remain-in-generic-rules-894
- Base: origin/main 2ef8d361e
- Method: Grep/Read over the worktree. Pytest was NOT executed (the research session had no shell tool); section G records commands only and marks the baseline as not collected.

## A. Occurrences of `TaskMaster` and `No-COM`

The guard test treats exactly two tokens as product names: `CONSUMING_NAMES = ("TaskMaster", "No-COM")` (`tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py:31`). Verified by grep over `.claude/rules/`, the bundle rules tree, `.github/instructions/`, and all of `extensions/drm-copilot/resources` (4 occurrences in 3 files per tree, no others).

Per-file occurrence counts (token-level, both tokens summed):

| File | Count | Lines |
|---|---|---|
| `.claude/rules/typescript.md` | 1 | 57 |
| `.claude/rules/csharp.md` | 2 | 5, 10 |
| `.claude/rules/parallel-orchestration.md` | 1 | 411 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md` | 1 | 57 |
| `.../claude-customizations/.claude/rules/csharp.md` | 2 | 5, 10 |
| `.../claude-customizations/.claude/rules/parallel-orchestration.md` | 1 | 411 |

The bundled mirror lines are identical to the source lines (same line numbers, same text).

Occurrences, verbatim, with proposed neutral wording:

1. `.claude/rules/parallel-orchestration.md:409-411` (mirror: same lines). Sentence: "**Accepted residuals (fail-closed direction).** Three token shapes that do not name a file are accepted by this rule: a dotted directory cited without a trailing slash, such as the C#-style `src/TaskMaster.Domain`; host-qualified tokens such as `example.com/page.html` or `owner/repo.git`; and refs whose final segment has a letter-led dotted tail."
   Proposed: replace the example with a neutral placeholder: "such as the C#-style `src/<Product>.Domain`" (matches the placeholder convention already used at `.claude/rules/architecture-boundaries.md:40`, `<Product>.Domain`). Alternative neutral literal: `src/Contoso.Domain`. Caveat: `<Product>` contains angle brackets and the classifier would read it differently if the sentence were ever harvested as plan text; the rule file is not a plan, so this is not a runtime concern. The issue text says "remove the example"; deleting the clause ", such as the C#-style `src/TaskMaster.Domain`" outright is also valid. Recommendation: keep an example with the `<Product>` placeholder, because the shape is hard to recognize without one.
2. `.claude/rules/typescript.md:57` (mirror: same). Sentence: "Layer rules and the No-COM architecture assertions are defined in `.claude/rules/architecture-boundaries.md`. The TypeScript enforcement tool is `dependency-cruiser` with configuration file `.dependency-cruiser.cjs`."
   Proposed: "Layer rules and the host-neutral architecture assertions are defined in `.claude/rules/architecture-boundaries.md`. ..." This also resolves item B.
3. `.claude/rules/csharp.md:5` (mirror: same), frontmatter: `description: C#-specific toolchain and coding standards (No-COM, xUnit).`
   Proposed: `description: C#-specific toolchain and coding standards (xUnit).` (or "(host-neutral, xUnit)").
4. `.claude/rules/csharp.md:10` (mirror: same): "This rule file summarizes the C#-specific policies for this repository. It targets the No-COM .NET foundation: xUnit, NSubstitute, FluentAssertions, `dotnet build`, the analyzer stack, `TimeProvider`, and uniform coverage thresholds."
   Proposed: "It targets a host-neutral .NET foundation: xUnit, ..." (or "It targets the .NET toolchain: xUnit, ...").
   Check on frontmatter edit: `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` validates rule frontmatter; the `description` change is wording only and `paths:` is untouched (not re-run; confirm in the verification step).

Other host/product-flavored wording that is NOT a guard token (record only; do not widen scope without a decision): `.claude/rules/typescript.md:28` ("Office.js, Microsoft Graph SDK"), `:44` ("Outlook host runtime"); `.claude/rules/general-unit-test.md:95` ("Office.js, Microsoft Graph"); `.claude/rules/architecture-boundaries.md:21-27,40` (Outlook/VSTO/Office.js, intentionally the architecture assertions). `test_push_down_tier_rule_adoption_gate.py:121` scans `QUALITY_TIERS_COPIES` only, for `("TaskMaster", "No-COM", "SpamBayes", "Outlook")`; it does not scan typescript.md or csharp.md.

Copilot-surface copies under `.github/instructions/`: no `parallel-orchestration`, `typescript.md`, or `csharp.md` rule copy exists. The glob found only `csharp-code-change.instructions.md`, `csharp-unit-test.instructions.md`, `typescript-code-change.instructions.md`, `typescript-suppressions.instructions.md`, `typescript-unit-test.instructions.md` (different documents), and grep for `TaskMaster|No-COM` over `.github/`, `.agents/`, `.codex/`, `.claude/skills/`, `.claude/agents/`, `AGENTS.md`, `CLAUDE.md` returned no files. The bundle's csharp-legacy variant rule (`extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md`) also carries no token. Result: no Copilot-surface follow-up candidates carrying these tokens.

## B. typescript.md cross-reference

- Referencing text: `.claude/rules/typescript.md:55-57`, section `## Architecture Boundaries`: "Layer rules and the No-COM architecture assertions are defined in `.claude/rules/architecture-boundaries.md`."
- Intended target: the architecture assertions in `.claude/rules/architecture-boundaries.md`, formerly headed "No-COM Architecture Rules". Verified from the #824 spec (`docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md:82`: rename the "No-COM Architecture Rules" heading to "Host-Neutral Architecture Rules") and the #824 research note (`.../research/2026-10-09T02-25-issue-823-tier-rule-adoption-follow-ups-research.md:57`, which records this exact mismatch as a follow-up).
- Current headings in `.claude/rules/architecture-boundaries.md`: line 17 `## Host-Neutral Architecture Rules (enforceable assertions)`; line 32 `## Layer Boundary Assertions (TypeScript)`; line 38 `## Layer Boundary Assertions (.NET, applies once the backend exists)`.
- Fix: reference by current wording (see A.2). Optionally name the sections exactly: "The layer rules (`Layer Boundary Assertions (TypeScript)`) and the host-neutral architecture assertions (`Host-Neutral Architecture Rules`) are defined in `.claude/rules/architecture-boundaries.md`." Exact heading names are brittle on rename; the descriptive wording is the lower-maintenance form.
- `csharp.md` has no analogous cross-reference (no mention of `architecture-boundaries` in `csharp.md`; the only `architecture-boundaries` hit in `.claude/rules/` is `typescript.md:57`).
- Test impact: `test_typescript_toolchain_instruction_contracts.py` reads `typescript.md` (lines 128-184) but pins only `npm run` commands, the Testing line, and the coverage line; the edit does not affect it.

## C. "Known false negatives" list in parallel-orchestration.md

`.claude/rules/parallel-orchestration.md:557-578` (mirror identical):

```
557 #### Known false negatives
559 Write-intent extraction can drop a genuine write in these cases:
561 1. a genuine write stated only as a glob (W1);
562 2. a genuine write stated only inside a command span (W2);
563 3. a write named only in spec prose (W5);
564 4. a read-verb task that also writes without a write verb in its title (W3);
565 5. a new top-level directory not yet in `path_roots` (W4);
566 6. a genuine file whose stem is in the placeholder set (W6).
567 7. a genuine file cited only as a separator-free bare file name is not recorded, because only repository-relative paths and configured root surfaces are accepted (issue #797); the planner cites the repository-relative path or appends it to the declared radius.
569 Three mitigations bound these cases:
571 1. **The planner remains obliged to enumerate a genuine write explicitly.** ...
```

(The first physical line numbers: 558 and 560 and 568 are blank lines; the list lines above are as read.)

Why item 7 is under the wrong lead-in: the lead-in at 559 attributes every item to "Write-intent extraction", and items 1-6 each cite a W-rule (W1, W2, W5, W3, W4, W6). Item 7 is not a W-rule drop. It cites issue #797 and describes the file-shape classifier (see section "File-shape recognition (issue #797)", lines 385-421) rejecting a separator-free bare name before write-intent extraction runs. Also item 6 still ends with a period (line 566) although it is no longer last.

#797 code-review note, `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/code-review.2026-10-09T07-51.md:21`, verbatim:

> CR-2. Item 7 is appended to a list introduced as "Write-intent extraction can drop a genuine write in these cases", but the separator-free bare-name drop happens in the classifier, before write-intent extraction. Item 6 still ends with a period although it is no longer the last item, and item 7 embeds its own mitigation, while the following "Three mitigations bound these cases" text does not mention it. | Recommendation: In a later documentation pass, either broaden the lead-in to "Extraction can drop a genuine write in these cases", or move item 7 to a separate sentence. Change item 6's terminal period to a semicolon. Keep the mirror byte-identical. (Severity Low, non-blocking; file lines 559-567.)

Correct target position (recommendation): move item 7 out of the numbered write-intent list into its own lead-in sentence placed after item 6 and before "Three mitigations bound these cases:" at line 569, for example: "The file-shape classifier, which runs before write-intent extraction, drops one further case: a genuine file cited only as a separator-free bare file name is not recorded, because only repository-relative paths and configured root surfaces are accepted (issue #797); the planner cites the repository-relative path or appends it to the declared radius." With item 7 removed, item 6 is the last list item, so its terminal period at line 566 is correct and the semicolon edit in CR-2 is unnecessary. Alternative (CR-2 option a): broaden the lead-in to "Extraction can drop a genuine write in these cases:", change item 6 period to a semicolon, and rewrite item 7 to end with a period. Recommended path is the separate sentence because it preserves the "Write-intent extraction" scoping of the section heading (`### Write-intent extraction (issue #722)`, line 507) and the "Three mitigations bound these cases" text still applies, since mitigation 1 ("The planner remains obliged to enumerate a genuine write explicitly") already covers the planner action. Nothing in tests/ pins the item 7 text or the lead-in (grep over tests/, scripts/, hooks, skills, agents for "Known false negatives", "can drop a genuine write", "bare file name", "only repository-relative paths" found only the rule file itself).

## D. Guard test and other tests

`tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`: 356 lines (limit 500). Structure:

- Constants: `CONSUMING_NAMES` (31); `PRODUCT_NAME_COPIES` (32-39, six copies: architecture-boundaries rule and skill copies, quota-throttling skill copies); `HARD_CODED_SOLUTION`/`SOLUTION_SURFACES`/`SOLUTION_SCAN_ROOTS` (41-68); `STEP_EIGHT_COPIES` etc. (70-75); `FALLBACK_COPIES` (77-93); `EXPECTED_LISTED_COPY_COUNT = 36` (94); `PUSHED_RULE_AND_SKILL_GLOBS` (96-106, nine root/pattern pairs including `.claude/rules/*.md`, `.claude/skills/**/SKILL.md`, `.agents/skills/**/SKILL.md`, and the bundle equivalents plus `.claude-variants` and `.agents-variants`).
- `PRE_EXISTING_NAME_EXCEPTIONS` (lines 107-120), with the comments "Pushed files outside the FU-823-2 listed set that still name a product. They are out of scope for issue #824 and recorded as a follow-up; the staleness test below fails once an entry no longer names one." Entries: `.claude/rules/typescript.md`, `.claude/rules/csharp.md`, `CLAUDE_BUNDLE + ".claude/rules/typescript.md"`, `CLAUDE_BUNDLE + ".claude/rules/csharp.md"`, then under the comment "Added by #797 after #824 planning; out of scope for #824 (follow-up).": `.claude/rules/parallel-orchestration.md` and `CLAUDE_BUNDLE + ".claude/rules/parallel-orchestration.md"`.
- Helpers: `read_copy` (123), `normalize_whitespace` (129), `files_naming_solution` (135), `pushed_rule_and_skill_files` (150), `step_eight` (161).
- Consumers of the exception set:
  - `test_pushed_rule_and_skill_files_name_no_consuming_product` (320-338): scans every pushed file not in the exception set; asserts `offenders == []`. This is the CR-5 weakness: an excepted file is skipped entirely, so a new occurrence there is not detected.
  - `test_name_exceptions_still_name_a_consuming_product` (341-356): the staleness check; fails when an excepted file is missing or no longer contains a token.
- Module docstring (1-16) mentions `PRE_EXISTING_NAME_EXCEPTIONS` at lines 9-11 and must be edited.
- Related negative test: `test_consuming_product_detection_flags_a_reintroduced_name` (274-287) uses in-memory strings (pattern to follow).
- "AC-5 exception set": defined by the #824 spec, `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/spec.md:216`: "AC-5: FU-823-2 -- a test fails if `TaskMaster` or `No-COM` reappears in pushed rule or skill files (repository and bundled copies), with any pre-existing out-of-scope occurrences held in an explicit exception set guarded against staleness." It is not defined in a separate test file; it is `PRE_EXISTING_NAME_EXCEPTIONS`. The #824 code review records the gap: `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/code-review.2026-10-10T14-25.md:50` "CR-5 | Minor (Non-blocking) | Open, deferred | `PRE_EXISTING_NAME_EXCEPTIONS` is per file, so new occurrences in excepted files are not detected." The #824 plan states a grep acceptance that `PRE_EXISTING_NAME_EXCEPTIONS` appears 4 times (`plan.2026-10-08T22-16.md:197`) and the #824 policy-audit (`policy-audit.2026-10-10T14-25.md:294`, PA-2) records the parallel-orchestration entry as an operator-approved deferral; those historical artifacts are not edited by #894.

Other tests that touch these tokens or files:

| Test | Reference | Breaks on token removal / text change? | Required action |
|---|---|---|---|
| `test_push_down_issue_824_follow_ups.py::test_name_exceptions_still_name_a_consuming_product` | stale check | Yes. Fails once all six entries contain no token. | Replace with the pinned-count staleness check (section F). |
| `test_push_down_issue_824_follow_ups.py::test_pushed_rule_and_skill_files_name_no_consuming_product` | scan | No (it passes more strongly). | Rework to compare observed counts against the pinned map. |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py:299-313` (`test_classify_path_token_admits_the_dotted_directory_residual_797`) | classifier input `src/TaskMaster.Domain` | No. It tests the classifier on a token string, not the rule file. | None. It is test data in `tests/`, not a pushed surface; the guard scans only rules/skills. Optional: neutral token such as `src/Contoso.Domain`. |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1:258-261` (`$token = 'src/TaskMaster.Domain'`) | Pester mirror of the same residual | No. | None (optional neutral rename; parity with the Python test). |
| `tests/scripts/dev_tools/discovery/test_domain_neutrality.py:14` | `DISALLOWED_TOKEN_PATTERN` for discovery module | Unrelated (scans discovery code). | None. |
| `tests/scripts/dev_tools/test_parallel_mergeable_cohort.py:42-51`, `test_validate_parallel_orchestrator_state_mergeable.py:25` | fixture data (`TaskMaster.Test/...`) | Unrelated. | None. |
| `test_push_down_tier_rule_adoption_gate.py:121,283` | token scan of `QUALITY_TIERS_COPIES` only | No. | None. |
| `test_push_down_claude_resource_contracts.py:89-110` | root-to-bundle parity | Breaks if only one of the pair is edited. | Edit both files identically. |
| `test_typescript_toolchain_instruction_contracts.py` | pins npm commands in typescript.md | No. | None. |
| `test_claude_rules_frontmatter.py:434` (`assert_rule_paths_reach("parallel-orchestration.md", ...)`) | frontmatter `paths` reach | No, unless the frontmatter is touched (it is not). | None. |
| `test_parallel_complexity_routing_contracts.py:195-199`, `test_epic_bounded_child_return_contract.py:78`, `test_parallel_planner_surface_contracts_landed.py:259`, `test_validate_orchestration_artifacts_parallel_dispatch.py:204` | pin other phrases in `parallel-orchestration.md` | No. None cite the "Accepted residuals" paragraph, the "Known false negatives" lead-in, or item 7. | None. Re-run them as a regression set because they read the same file. |
| `tests/shell/parallel_payload_only.bats:68` | existence check for the bundled rule | No. | None. |

No test pins `PRE_EXISTING_NAME_EXCEPTIONS` outside the 824 test.

## E. Bundle byte parity

- The enforcing test is `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 89-110). It enumerates every distributable file under the repo `.claude/` (via `filter_distributable_claude_paths`), requires presence in `extensions/drm-copilot/resources/claude-customizations/.claude/`, and asserts `read_text` equality (UTF-8 text compare, so a CRLF/LF difference is normalized only if Python universal newlines apply; keep line endings identical anyway). Scope is `SCOPED_ROOTS = (Path(".claude"),)` (line 29), so `.claude-variants` and `pack-manifests` are outside it (tests at 144-192 pin that).
- `test_planner_review_resources_exist_and_are_byte_identical` (113) and `test_handoff_runtime_has_bundle_pack_and_effective_install_parity` (126) cover other files and do not include the three rule files.
- Manifest/hash files: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json` list relative paths only (for example `csharp-modern.json` lists `.claude/rules/csharp.md`); grep for sha256/checksum/hash/digest in `extensions/drm-copilot/resources/**/*.json` matched only `config/orchestration-handoff.schema.json`, which is unrelated. Conclusion: no manifest or hash update is required when the content of a bundled rule file changes. Membership is unchanged because no file is added or removed.
- Run command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`. Node ID for the parity assertion: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`. No jest command is involved for this parity; the extension jest suite is not part of the check.
- Edit procedure: apply each change to the source file and the same change to the mirror (six files in total: three source, three mirror). Do not edit by regenerating via push-down, since the repo-side `resources/` edit is the mirror itself.

## F. Post-change counts and pinned-count design

Expected counts after the A.1-A.4 edits: zero in all six files (typescript 1 -> 0, csharp 2 -> 0, parallel-orchestration 1 -> 0, in source and mirror). The pinned-count map therefore ends up empty. Consequences: the per-file exemption disappears entirely, and the guard becomes "every pushed rule/skill file has zero occurrences", expressed through a pinned map so a future deliberate exception must be a visible, counted entry.

Proposed design (pure functions, no I/O inside the comparison):

1. Replace `PRE_EXISTING_NAME_EXCEPTIONS` with `PINNED_NAME_OCCURRENCES: dict[str, int] = {}` (path -> exact expected total of `CONSUMING_NAMES` occurrences; empty because all six counts reach zero). Comment: an entry records an accepted, counted occurrence; the count is exact.
2. Add `count_name_occurrences(text: str) -> int` = `sum(text.count(name) for name in CONSUMING_NAMES)`.
3. Add pure `pinned_count_mismatches(observed: Mapping[str, int], pinned: Mapping[str, int]) -> list[str]` returning one message for each scanned path whose `observed[path] != pinned.get(path, 0)` (covers both a new occurrence and a removed occurrence, so the pin cannot drift upward silently or stay stale downward).
4. Real-tree test replacing `test_pushed_rule_and_skill_files_name_no_consuming_product`: build `observed = {path: count_name_occurrences(read_copy(path)) for path in pushed_rule_and_skill_files()}` and assert `pinned_count_mismatches(observed, PINNED_NAME_OCCURRENCES) == []`.
5. Staleness test replacing `test_name_exceptions_still_name_a_consuming_product`: every key of `PINNED_NAME_OCCURRENCES` must be in `pushed_rule_and_skill_files()` and have a pinned value > 0 (a zero pin is redundant). With an empty map it passes vacuously, which is correct; add a type or content assertion so the empty map is a stated outcome, e.g. `assert PINNED_NAME_OCCURRENCES == {}` is not recommended (it would force an edit to add a legitimate pin); the vacuous pass plus negative tests below is sufficient.
6. Negative tests with in-memory data only (no temporary files, matching repository policy and the existing pattern at lines 274-287):
   - A new occurrence in a file pinned at 1 (observed 2) yields a mismatch message naming the path.
   - A new occurrence in an unpinned file (observed 1, pin absent) yields a mismatch.
   - A removed occurrence in a file pinned at 1 (observed 0) yields a mismatch (staleness).
   - `count_name_occurrences("TaskMaster and No-COM and TaskMaster")` returns 3 and `count_name_occurrences("<Product>.Domain")` returns 0.
   - Equal observed and pinned maps yield `[]`.
   - Optional: staleness helper test over a synthetic pinned map with a zero value and a missing path.
7. Remove: the module-docstring sentence at lines 8-11 about `PRE_EXISTING_NAME_EXCEPTIONS` (rewrite to describe pinned counts), the constant and its comments (107-120), and the two tests (320-356). Net line change is small; the file stays well under 500 lines (356 now).
8. Quality-tier note: this is a test module; the repository coverage and 85% thresholds are unaffected (no production code changes). Python toolchain policy (`.claude/rules/python.md`; not re-read here) requires the full black/ruff/pyright/pytest loop.

## G. Commands and baseline

Baseline NOT collected: this research session had no process-execution tool, so no pytest run was performed and no pass/fail counts are recorded. The implementer should capture the baseline before editing, into the feature `evidence/` folder per repository convention.

Commands (run from the worktree root):

- `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -q` (reported by the issue as passing on main; unverified here).
- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` (bundle parity).
- `poetry run pytest tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q` (rule text/frontmatter pins).
- `poetry run pytest tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py -q` (other readers of `parallel-orchestration.md`).
- `poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction_rules.py -q` (only if the optional token rename is made).
- The 824 test's own expected baseline per its plan was 43 collected tests (plan line 197); the actual count today is unverified.

Fail-before design for the new regression test: write the pinned-count tests first (they should fail by `test_name_exceptions_still_name_a_consuming_product` semantics changing, i.e. with the old exception entries gone and tokens still present, the real-tree test fails on all six files), then remove the tokens.

## H. CHANGELOG and docs

- `extensions/drm-copilot/CHANGELOG.md` has an `## [Unreleased]` section (line 8) with a `### Changed` list, which currently carries only the PoshQC coverage entry (issue #527). It documents extension-visible behavior; rule-file edits in the bundled mirror ship in the extension payload, so a one-line `### Changed` entry is optional and consistent with Keep a Changelog. The repository has no stated rule requiring a CHANGELOG entry for rule wording edits (grep of `.github/copilot-instructions.md` for "changelog" found nothing; no CHANGELOG rule was located). Recommendation: add one short entry only if the maintainer wants pushed rule wording tracked; otherwise none.
- Feature docs: update `docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md` (all sections currently "(not provided in potential file)") and the plan's Phase 5 spec/issue update task. The #824 and #797 artifacts are historical records and must not be edited.
- No Copilot-surface (`.github/`) or Codex/`.agents` doc requires a matching edit (no tokens found there).

## Recommended approach and rejected alternatives

Recommended: one change set of six rule-file edits (three source plus three byte-identical mirrors) and a rewrite of the 824 guard to pinned per-file counts with an empty pin map, with in-memory negative tests for the pure comparison function.

Rejected alternatives: (1) keep the frozenset and add a per-file count only for excepted files, rejected because every exception is removed by this change and the frozenset would be an empty exemption with no purpose; (2) delete the exemption and rely on `offenders == []` alone, rejected because it does not satisfy CR-5's pinned-count requirement and leaves no mechanism to hold a future counted exception.

## Open points for the planner

- Choice of placeholder in A.1 (`src/<Product>.Domain` versus a neutral literal versus deleting the example).
- Whether to also rename the `src/TaskMaster.Domain` test inputs in `test_blast_radius_extraction_rules.py:308` and `BlastRadiusTokenShape.Tests.ps1:261` (outside the guard's scan; optional).
- Whether the baseline pytest run shows any pre-existing failure (not collected here).
