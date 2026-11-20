# Feature Audit: Push-Down Consolidation and Ecosystem Packs (#1029)

**Audit Date:** 2026-11-18
**Feature Folder:** `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029`
**Base Branch:** `origin/epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/push-down-consolidation-and-ecosystem-packs-1029`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (commit `2d487f5b070b401a6d14271a039b1207a6e0383f` at the merge base)
- **Head branch/commit:** `feature/push-down-consolidation-and-ecosystem-packs-1029` (commit `9345046c3a64c95a56cec354fba3ed2fb9e04110`)
- **Merge base:** `2d487f5b070b401a6d14271a039b1207a6e0383f`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-18 11:40 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/evidence/**` (baseline, qa-gates, other, regression-testing)
  - Additional evidence: reviewer recomputation of `extensions/drm-copilot/coverage/lcov.info` and `artifacts/python/lcov.info`; logical line counts of changed covered files; render-and-diff of the orchestrator-state rule from its #1028 generator source; test-name inspection under `extensions/drm-copilot/test/`
- **Feature folder used:** `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 12 carries `- Work Mode: full-feature`, so the AC sources are `spec.md` (`## Acceptance Criteria`) and `user-story.md` (`## Acceptance Criteria`).
- **Scope note:** The review covers the full branch diff from the integration merge base. The spec criterion on language classification names `origin/main`; against `origin/main`, the only added `.py` file and the only changed `scripts/dev_tools/push_down_*.py` file are present at the integration merge base (from #1035), so they are not part of this branch's change. The criterion is judged on this branch's diff, following `evidence/other/execution-decision.scope-base.2026-11-18T07-54.md`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/spec.md` — primary source (24 items)
- `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/user-story.md` — secondary source (13 items)

### From spec.md

1. `push_down_claude_customizations`, `push_down_codex_and_agents_customizations` and `push_down_copilot_customizations` each delegate to the same pipeline entry point with a selection that names only their own ecosystem; a Jest test per wrapper verifies the delegation, and no wrapper module contains its own enumeration, planning or write loop.
2. For each ecosystem, an apply run into an empty in-memory destination writes every file of the shared-layer set resolved at the Phase 0 gate; verified by a data-driven Jest test over the Claude, Codex and Copilot wrappers.
3. For each ecosystem, every path written by a run lies in the shared-layer set or under that ecosystem's layer roots, and no path lies under another ecosystem's layer (including Codex-only `.agents/skills` entries for non-Codex runs); verified by a data-driven Jest test.
4. Each wrapper, including `push_down_copilot_customizations`, accepts `packs` and publishes only `core` plus the selected packs for its ecosystem layer, with C# variant rules unchanged; verified by Jest tests.
5. A call with `dry_run: true` leaves the in-memory destination byte-identical (no payload file, no `.push-down-manifest.json`, no summary artifact) and returns `push_down_report` with `mode` `dry-run` listing every planned path with its action.
6. An apply run returns `push_down_report` with `mode` `apply`, and for identical inputs its `files` and `counts` equal those of the preceding dry run; the plan is computed before the first write.
7. Each row of the decision table in `### Decision Table` has a Jest unit test asserting the action and whether the file is written.
8. A destination file edited locally after a push-down (hash differs from its manifest entry and from the payload) is not overwritten, is reported as `conflict` in `push_down_report` and in `warnings`, and keeps its previous manifest hash.
9. A second apply run with no source change and no destination change writes no file outside `artifacts/` and reports every path as `unchanged`, `merge` or `excluded`; verified by an integration-style Jest test using the real bundle reader and an in-memory destination.
10. A first run against a destination with no manifest creates absent files, adopts identical files, and reports differing files as `unmanaged-conflict` without writing them; with `overwrite_unmanaged: true` those files are overwritten. Every existing test changed by this behavior is listed in the plan with its reason.
11. `.push-down-manifest.json` is written at the destination root as sorted-key LF JSON with `schema_version`, `payload_version`, `selection` per pushed-down ecosystem, and a `layer`, `pack` and SHA-256 of LF-normalized text for each managed file; a Jest test asserts it contains no timestamp and no absolute path, and that a CRLF destination copy of an unchanged file is classified `unchanged`.
12. A malformed or unknown-major `.push-down-manifest.json`, a malformed pack manifest, both C# variants selected, or a malformed `.push-down-exclusions` fails the run with a specific error before any write; verified by Jest tests.
13. Merged paths (`config/orchestration-routing.json`, `config/blast-radius.json`, `.gitignore`) are reported as `merge`, preserve destination content, and are written only when the merged text differs, for every wrapper that delivers them (including the Codex wrapper for `config/orchestration-routing.json`).
14. Paths in `.push-down-exclusions` are withheld and reported as `excluded` for the Claude, Codex and Copilot wrappers (O-8 default).
15. Manifest entries without a payload counterpart are reported as `orphaned` and no destination file is deleted.
16. An omitted `packs` reuses the selection recorded for that ecosystem in `.push-down-manifest.json`, and publishes the full ecosystem tree when no selection is recorded (O-5 default).
17. The pack manifests list every generated file that child 3 produces, as recorded by the Phase 0 gate, and a Jest full-bundle completeness test passes: every file under a published root of each bundle is listed by a layer manifest or by a documented exception with a stated reason.
18. The Phase 0 gate and the execution-precondition gate ran before any edit and their records are under `<FEATURE>/evidence/qa-gates/`, including confirmation that child 1 (#1025) and child 3 (#1028) have merged.
19. The language classification holds: the branch diff against `origin/main` adds no `.py` file, adds no TypeScript or Python file under a pushed-down root or its bundle copy, and adds or changes no `scripts/dev_tools/push_down_*.py` file.
20. Existing MCP tool names are unchanged, existing input properties keep their types, enums and defaults, and for calls without the new properties the result keeps `ok`, `tool`, `workspace_root`, `summary`, a one-element `artifacts` and `warnings` only when non-empty, with `push_down_report` as the only added field; verified by a wrapper-compatibility Jest test.
21. The static parity tests (`test_push_down_claude_parity.py`, `test_push_down_claude_overlay_parity.py`, `test_push_down_claude_exclusion_parity.py`, `test_push_down_claude_gitignore_parity.py`, `test_skill_bundle_contract_repo.py`) pass without modification (O-6 default).
22. The bundle-mirror and contract tests listed in `## Non-Functional Requirements`, the Pester `*.Manifest.Tests.ps1` suites and the Codex generator `--check` pass, with results recorded under `<FEATURE>/evidence/qa-gates/`.
23. Each new production TypeScript file has its own `coverageThreshold` entry (lines 85, branches 75) in `extensions/drm-copilot/jest.config.cjs`, and the Jest run meets every threshold.
24. No new or changed file exceeds 800 lines, no test creates a temporary file, and no file under `.claude/hooks`, `.codex/hooks` or `.github/hooks` is changed.

### From user-story.md

25. The MCP tools `push_down_claude_customizations`, `push_down_codex_and_agents_customizations` and `push_down_copilot_customizations` keep their names and existing inputs and results, and each delegates to the same pipeline for its own ecosystem.
26. Every push-down installs the shared layer, whichever ecosystem's tool is called.
27. A push-down for one ecosystem writes no file under another ecosystem's layer.
28. A maintainer can select packs per ecosystem, including for Copilot, and only `core` plus the selected packs of that ecosystem are installed.
29. A dry run returns the full plan (path, layer, pack and action per file) and leaves the destination unchanged.
30. An apply run reports the same plan it executes, computed before its first write.
31. A file the maintainer edited since the last push-down is not overwritten and is reported as a conflict.
32. A destination pushed down by an earlier release (no manifest) is not overwritten where its files differ from the payload; those files are reported, and an explicit `overwrite_unmanaged: true` opt-in overwrites them.
33. A second push-down with no source change and no destination change changes no file outside `artifacts/`.
34. The destination receives `.push-down-manifest.json` at its root with a SHA-256 hash per managed file and the pack selection per ecosystem, and with no timestamp and no absolute path.
35. Destination exclusions in `.push-down-exclusions` are honored by all three tools, and files of a deselected pack or ecosystem are reported as orphaned rather than deleted.
36. The pack manifests list the generated files that child 3 (#1028) produces, as confirmed at the Phase 0 gate.
37. No new Python file is added, and no TypeScript or Python file is pushed down to destinations.

---

## Acceptance Criteria Evaluation

All Jest evidence comes from the final extension run (`evidence/qa-gates/final-jest.2026-11-18T11-19.md`: 369 suites, 6119 tests passed, 0 failed) at the reviewed head.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Wrappers delegate to one pipeline; no own loop | PASS | `push-down-service-call.test.ts` `push-down service calls over the unified harness (issue #1029)` (`it.each(calls)`); `enumerateSourceFiles` count 0 in the four wrapper modules (`final-scope-and-size`); reviewer grep shows no write loop in `claude-customizations.ts` or `copilot-customizations.ts` | `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage` | Remaining loops in `codex-agents-customizations.ts` belong to the virtual-resource filesystem adapter |
| 2 | Shared-layer set written for each ecosystem | PASS | `push-down-harness.real-bundle.test.ts` `installs every shared-layer file (%s)` over `ECOSYSTEMS` | same | Data-driven over three ecosystems |
| 3 | No path under another ecosystem's layer | PASS | `push-down-harness.real-bundle.test.ts` `it.each(ECOSYSTEMS)` layer-confinement case; `publishes ecosystem-layer exceptions only in a Codex run` | same | |
| 4 | `packs` per wrapper incl. Copilot; C# variants unchanged | PASS | `publishes core plus selected packs`; `passes the Copilot packs selection to the harness`; new Copilot manifests under `resources/customizations/pack-manifests/` | same | |
| 5 | Dry run leaves destination byte-identical | PASS | `push-down-pipeline.test.ts` `dry run leaves the destination byte-identical` | same | |
| 6 | Apply report equals dry run; plan before first write | PASS | `push-down-harness.test.ts` `dry run and apply report identical files and counts`, `reports mode apply for an apply run`; `push-down-pipeline.test.ts` `computes the full plan before the first write` | same | |
| 7 | Decision-table row tests | PASS | `push-down-plan-comparator.test.ts` `it.each(rows)("classifies %s")` with action and write flag; reviewer inspection of `classifyPayloadFile` matches the table | same | |
| 8 | Local edit not overwritten; `conflict`; previous hash kept | PASS | `keeps a local edit and reports conflict` (real bundle); `keeps the previous manifest hash for conflict`; `routes conflict, unmanaged-conflict and deleted-locally lines to warnings and log` | same | |
| 9 | Second apply no-op over the real bundle | PASS | `push-down-harness.real-bundle.test.ts` `second apply is a no-op (%s)` | same | |
| 10 | First run without manifest: create/adopt/unmanaged-conflict; opt-in overwrite | PASS | `first run without a manifest adopts and reports unmanaged-conflict`; `overwrites unmanaged-conflict when overwriteUnmanaged is true`; plan `## Existing Test Dispositions` lists changed tests | same | |
| 11 | Manifest format; no timestamp/absolute path; CRLF unchanged | PASS | `push-down-destination-manifest.test.ts`; `classifies a CRLF copy as unchanged` | same | |
| 12 | Malformed inputs fail before any write | PASS | `push-down-pipeline.test.ts` `fails before any write on <case>` (`it.each(cases)`) | same | |
| 13 | Merged paths reported `merge`, written only when changed | PASS | `classifies merged paths and merged deliveries as merge`; `merges the Codex routing document`; second-apply no-op; `evidence/other/execution-decision.merged-json-idempotence.2026-11-18T09-15.md` | same | |
| 14 | Exclusions withheld for all three wrappers | PASS | `reports excluded paths for every layer`; `returns exclusions when the destination lists any` | same | |
| 15 | Orphaned entries reported, not deleted | PASS | `reports orphaned entries without deleting`; `reports entries of a deselected pack as orphaned` | same | |
| 16 | Omitted `packs` reuses recorded selection; full tree otherwise | PASS | `reuses the recorded packs when packs is omitted`; `publishes the full tree with no recorded selection` | same | |
| 17 | Manifests list child 3 outputs; completeness test passes | PASS | `push-down-bundle-manifest-completeness.test.ts` passes at the final run; expected-fail first run recorded in `evidence/regression-testing/completeness-first-run.2026-11-18T10-21.md` | same | |
| 18 | Phase 0 and precondition gates recorded first | PASS | `evidence/qa-gates/phase0-upstream-recheck.2026-11-18T07-50.md` (#1025 and #1028 merged), `phase0-tree-recheck.2026-11-18T07-54.md`, `phase0-owner-answers.2026-11-18T07-55.md`; first code task-check at 08:35 | `git log` of the branch | |
| 19 | Language classification | PASS | Branch diff adds no `.py` file, adds no `.ts`/`.py` under a pushed-down root, and changes no `scripts/dev_tools/push_down_*.py` (`final-scope-and-size`; reviewer `git diff --diff-filter=A` from the merge base) | `git diff --diff-filter=A --name-only origin/main...HEAD -- '*.py'` | Against `origin/main`, `tests/scripts/dev_tools/atomic_executor/test_cli_compat_proxies.py` and `scripts/dev_tools/push_down_codex_and_agents_customizations.py` appear; both are present at the integration merge base (#1035) and unchanged by this branch |
| 20 | MCP tool compatibility | PASS | `push-down-wrapper-compatibility.test.ts`; `mcp-repo-automation-tool-definitions.test.ts` | same | |
| 21 | Static parity tests unmodified and passing | PASS | `final-pytest.2026-11-18T11-19.md` (17122 passed); `final-scope-and-size` shows no change to the five files | `run-test-suite.sh pytest` | |
| 22 | Bundle-mirror/contract tests, Pester Manifest suites, Codex `--check` | PASS | `final-pytest` (contract tests passed); `final-pester` (`*.Manifest.Tests.ps1` suites passed); `final-qc-python-static` (`--check` exit 0) | `run-test-suite.sh pester`; `generate_codex_agent_variants --check` | The Pester run fails one unrelated harness-generation test (see Summary, F-1); the named Manifest suites pass |
| 23 | Per-file `coverageThreshold` entries met | PASS | 13 entries in `jest.push-down-coverage.json`, spread into `coverageThreshold` by `jest.config.cjs`; Jest run reports no threshold failure; reviewer recomputation: lowest 99.21% lines, 96.00% branches | `run-test-suite.sh jest-extension --coverage` | Entries live in a JSON file wired into `jest.config.cjs` (plan D9) |
| 24 | No file over 800 lines; no temp files; no hook changes | PASS | Reviewer logical line count: largest 627; no `mkdtemp`/`tmpdir` in new tests; no path under `.claude/hooks`, `.codex/hooks`, `.github/hooks` in the diff | `git diff --name-only <merge-base> HEAD` | |
| 25 | Tools keep names, inputs, results; delegate | PASS | Same evidence as 1 and 20 | same | |
| 26 | Shared layer always installed | PASS | Same evidence as 2; `builds shared plus the selected ecosystem only` | same | |
| 27 | No writes under another ecosystem's layer | PASS | Same evidence as 3 | same | |
| 28 | Packs per ecosystem incl. Copilot | PASS | Same evidence as 4 | same | |
| 29 | Dry run returns full plan, destination unchanged | PASS | Same evidence as 5; `reports every planned, merged, excluded and orphaned path once` | same | |
| 30 | Apply reports the plan it executes, computed first | PASS | Same evidence as 6 | same | |
| 31 | Edited file not overwritten, reported as conflict | PASS | Same evidence as 8 | same | |
| 32 | No-manifest destination protected; opt-in overwrite | PASS | Same evidence as 10 | same | |
| 33 | Second push-down changes nothing outside `artifacts/` | PASS | Same evidence as 9 | same | |
| 34 | Manifest with hashes and selection, no timestamp or absolute path | PASS | Same evidence as 11; `records the selection with sorted packs including core` | same | |
| 35 | Exclusions honored; deselected files orphaned | PASS | Same evidence as 14 and 15 | same | |
| 36 | Manifests list child 3 outputs | PASS | Same evidence as 17 | same | |
| 37 | No new Python; no TS/Python pushed down | PASS | Same evidence as 19 | same | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 37 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

Every acceptance criterion is met by the branch. The readiness verdict is NEEDS REVISION because of one blocking finding that is not an acceptance criterion: the repository Pester gate fails on `HarnessGeneration.RepoGate.Tests.ps1`, which will make the CI PowerShell QC shards and `CI Required Gate` red for this PR.

**Top gaps preventing PASS:**

1. F-1: `.claude/rules/orchestrator-state.md` and its bundle copy carry a `## Release-Commit Allowance Scope` section (added by `db46ac6ad`, #1201) that the #1028 generator source `scripts/harness-generation/sources/rules/orchestrator-state.md` / `.json` does not produce. Remediability: autonomous; Finding-Scope: contained.

**Recommended follow-up verification steps:**

1. After the source is updated and regenerated, rerun `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` and confirm 0 failures, and confirm `git diff` shows no change to the two generated files.
2. After the PR is opened, confirm the integration-lane `codex-bundle-publish.integration.test.ts` and the PowerShell QC shards pass in CI at the final head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 37 criteria were already checked (`- [x]`) in the source files at the reviewed head and all evaluate PASS, so no source-file checkbox change was made by this review. No item was unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/spec.md`, `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/user-story.md`
- Total AC items: 37
- Checked off (delivered): 37
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/spec.md` | 24 | 24 | 0 | Checkbox-backed (`## Acceptance Criteria`); `## Definition of Done` and seeded test conditions are not AC |
| `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/user-story.md` | 13 | 13 | 0 | Checkbox-backed |
