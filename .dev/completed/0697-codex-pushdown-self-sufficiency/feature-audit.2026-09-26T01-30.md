# Feature Audit: Codex push-down payload self-sufficiency (#697)

---

**Audit Date:** 2026-09-26
**Feature Folder:** `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697`
**Base Branch:** `main`
**Head Branch:** `bug/codex-pushdown-self-sufficiency-697`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (PR context resolved `origin/main` @ `d754f83f714b087e404577cb7a1b02f48d2023bb`)
- **Head branch/commit:** `bug/codex-pushdown-self-sufficiency-697` (commit `59c4fda88023355353d0802c826d62347f7d4662`)
- **Merge base:** `26d57cb37f91e6a695f4ab4c1f57366229756fdc`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-26 01:20:35 UTC, head SHA equal to the branch head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 26d57cb3..59c4fda8`
  - Feature evidence: `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/**` (baseline, qa-gates, regression-testing, other, coverage)
  - Additional evidence: reviewer re-runs recorded in `policy-audit.2026-09-26T01-30.md` Appendix B; coverage artifacts `artifacts/python/coverage.json`, `extensions/drm-copilot/coverage/lcov.info`, `artifacts/pester/powershell-coverage.xml`
- **Feature folder used:** `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` line 12 carries `- Work Mode: full-bug`; `spec.md` line 9 confirms "acceptance-criteria source: this file only".
- **Scope note:** Full branch diff against the merge base (152 files, 46 outside `evidence/`). PR context was current (same head SHA) and was not regenerated. Python checks were re-run with `PYTHONPATH=<repo>` after the shared Poetry venv was found to resolve `scripts.*` to another worktree for out-of-tree scripts; module origins were confirmed to be this worktree.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/spec.md` — only source (46 checkbox items under `## Acceptance Criteria`)

### Acceptance criteria

Item 1 — `csharp-legacy` role file and role-schema guard

1. AC-1.1 The `csharp-legacy` variant `csharp-typed-engineer.toml` contains no `variant` key and declares `model = "gpt-5.6-terra"` and `model_reasoning_effort = "high"`; proven by the AC-1.5 case, which fails against the old file.
2. AC-1.2 New `test_codex_agent_role_schema.py` parses every repository `.codex/agents/*.toml`, every bundle `.codex/agents/*.toml`, and every bundle `.codex-variants/**/agents/*.toml` with `tomllib`, asserts top-level keys are a subset of an allowlist excluding `variant` and `mcp_servers`, and includes an in-memory `variant = "legacy"` negative case.
3. AC-1.3 The same file asserts `name`, `description`, and `developer_instructions` in every file of the three sets.
4. AC-1.4 The same file asserts `model` and `model_reasoning_effort` for every base alias and profile of each `GENERATED_AGENT_FAMILIES` family and both epic personas, and does not require them elsewhere (`5.1-beast-adjusted.toml` passes).
5. AC-1.5 The same file asserts each variant role file has the same key set, `model`, and `model_reasoning_effort` as its canonical bundle file, parametrized per variant file.

Item 2 — In-PR evidence in place of live destination verification

6. AC-2.1 A new Jest integration test drives the real TypeScript publisher over the real bundle with an in-memory destination in full-tree mode and asserts the 3 config files, 2 `.codex/lib/codex-routing` modules (bytes equal to `.claude/lib/codex-routing`), and 2 wrappers; no temporary file.
7. AC-2.2 The same file runs `typescript` pack mode and asserts every registered hook and its dot-source closure is present.
8. AC-2.3 The same file runs `csharp-legacy` pack mode and asserts the published role has `model = "gpt-5.6-terra"` and no `variant` key.
9. AC-2.4 A new Pester hook probe runs every bundle-registered hook through `pwsh -NoProfile -File` from the bundle location with `Bash`, `apply_patch`, `Edit`, and `mcp__` payloads and asserts exit 0 and empty or `hookSpecificOutput` stdout; the legacy shape fails; fails before the item 3 fix.
10. AC-2.5 A potential item under `docs/features/potential/` records the post-release pin bump and live re-push, and the spec links it.

Item 3 — Fail-soft registry loading

11. AC-3.1 AST Pester test: no top-level statement invokes `Get-EpicPlanningRegisteredMcpTool`; fails against the old file.
12. AC-3.2 `-RegistryPath` parameter exists; non-existent path with no checkpoint or attestation returns `$null`.
13. AC-3.3 Non-existent path, non-preparation route, `mcp__` call returns `$null`.
14. AC-3.4 Non-existent path in preparation mode: `apply_patch` and `Bash` decisions equal those with the committed registry.
15. AC-3.5 Non-existent path in preparation mode: each `$script:AllowedPreparationMcpTools` tool is allowed, subject to the `workspace_root` check.
16. AC-3.6 Non-existent path in preparation mode: each registered semantic tool plus one unregistered `mcp__` tool is denied with a reason naming the path and stating it does not exist.
17. AC-3.7 Committed registry in preparation mode: each semantic tool is allowed.
18. AC-3.8 Malformed committed fixture: a semantic call in preparation mode throws.
19. AC-3.9 Bundle hook copy is byte-identical, proven by three named parity tests.

Item 4 — Resolver delivery, both publishers, packaging, port fix

20. AC-4.1 Pytest: `_RoutingConfigFileSystem` publishes both `.codex/lib/codex-routing/*.psm1` from `lib/codex-routing/*` under the bundle parent, full-tree and pack mode.
21. AC-4.2 Pytest: an unmapped physical `config/` file is not published; `.codex/lib/codex-routing` is walked as a published root.
22. AC-4.3 Jest: `RoutingConfigFileSystem` publishes the 3 config files and 2 modules in both modes, omits an unmapped virtual-root file; the ordering test is updated and passes.
23. AC-4.4 Shared mirror `resources/lib/codex-routing/*.psm1` exists and a pytest asserts byte identity with `.claude/lib/codex-routing`.
24. AC-4.5 Pytest: no physical `.codex/lib/` in the repository or bundle.
25. AC-4.6 Committed corpus `tests/fixtures/codex_routing/*.json`; pytest runs each record through the Python `main(argv)` and asserts exit and stdout.
26. AC-4.7 Pester invokes both wrappers through `pwsh -NoProfile -File` per corpus record and asserts normalized byte-equal stdout, equal parsed objects, and equal exit codes.
27. AC-4.8 Corpus covers the listed success cases and the exit-2 and exit-1 error cases.
28. AC-4.9 Two-candidate module resolution with first-wins, fallback, and none-exists (non-zero exit naming candidates) tests; fallback proven end to end.
29. AC-4.10 Bundle wrapper copies text-equal, proven by the resource-contract test.
30. AC-4.11 `CodexDeployment.psm1` accepts `commit-steward`; family-list case extended; new receipt-equality case.
31. AC-4.12 Claude bundle mirror updated in lockstep, proven by `CodexRouting.Manifest.Tests.ps1`.
32. AC-4.13 `prepack.cjs` exports `shouldCopy` and copies only as main module.
33. AC-4.14 Unit test: `shouldCopy` true for the wrapper and epic-child scripts, false for `<resources>/scripts` and beneath; path strings only, CI-executed runner.
34. AC-4.15 Same test: `shouldCopy` false for `.py` at root, under `scripts/`, under `.codex/scripts/`, and at depth >= 3.
35. AC-4.16 Named pytest: skill (both copies) has no Python resolver invocation, instructs both wrappers, and directs validation to the MCP tool with both flags; fails against the old file.

Item 5 — `core.json` completeness and closure guard

36. AC-5.1 `core.json` lists all 21 registered hooks, the 12 missing paths, every transitive dependency, and the 4 item-4 paths.
37. AC-5.2 New pytest guard computes the closure from the bundle `config.toml` plus wrappers and module imports and asserts subset of core `paths` and existence; fails against the old `core.json`.
38. AC-5.3 Closure computation unit-tested on in-memory text for the three dot-source forms, plus a negative absent-hook case.
39. AC-5.4 The 12 entries are removed from `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS` and the two completeness tests pass.
40. AC-5.5 `test_generator_check_mode_reports_no_drift` passes after the edit.

Cross-cutting

41. AC-6.1 Mirrors updated in lockstep and the eight named parity tests pass.
42. AC-6.2 Both wrappers registered for coverage in both `pester.runsettings.psd1` copies.
43. AC-6.3 Coverage evidence under `evidence/coverage/` shows >= 85% line and >= 75% branch for changed Python and TypeScript files, >= 85% line for changed PowerShell files, no changed-line regression, and no production path added to an exclude list.
44. AC-6.4 Python, TypeScript, and PowerShell toolchains each complete format, lint, type check (where applicable), and test in a single clean pass, recorded under `evidence/`.
45. AC-6.5 No new or changed production or test file exceeds 500 lines.
46. AC-6.6 Non-goals: no change to `packages/mcp-server/package.json`, `.claude/hooks/**`, portable-handoff tool implementations, the MCP version pin, or `enabled_tools` in either `.codex/config.toml`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1.1 role file corrected | PASS | Diff replaces `variant = "legacy"` with the two keys; `test_variant_role_file_matches_canonical_keys_and_pins`; `evidence/regression-testing/fail-before-role-schema.2026-09-25T20-47.md` | `git diff 26d57cb3..HEAD -- <toml>`; `poetry run pytest tests/scripts/dev_tools/test_codex_agent_role_schema.py` | Reviewer run passed |
| 2 | AC-1.2 allowlist + in-memory negative | PASS | `test_role_file_top_level_keys_are_allowlisted`, `test_allowlist_rule_reports_variant_key_in_memory` | same | |
| 3 | AC-1.3 identity keys | PASS | `test_role_file_declares_identity_keys` | same | |
| 4 | AC-1.4 model pins for routed roles only | PASS | `test_routed_role_file_declares_model_pins`, `test_routed_role_file_counts_per_set`, `test_model_pins_not_required_for_unrouted_role` | same | |
| 5 | AC-1.5 variant equals canonical | PASS | `test_variant_role_file_matches_canonical_keys_and_pins` (parametrized) | same | |
| 6 | AC-2.1 real-bundle full-tree publish | PASS | `codex-bundle-publish.integration.test.ts` "publishes the config and codex-routing resources from the real bundle in full-tree mode" | `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/codex-bundle-publish.integration.test.ts` | `git status --porcelain` empty after run |
| 7 | AC-2.2 `typescript` pack hook closure | PASS | "publishes every registered hook and its dot-source closure in typescript pack mode" | same | |
| 8 | AC-2.3 `csharp-legacy` pack role | PASS | "publishes the corrected csharp-legacy role file" | same | |
| 9 | AC-2.4 bundle hook probe | PASS | `codex-bundle-hook-probe.Tests.ps1`: 17 PreToolUse hooks, 41 invocations; `fail-before-bundle-hook-probe.2026-09-25T21-05.md` (exit 1) / `pass-after-bundle-hook-probe.2026-09-25T21-10.md` | `Invoke-Pester` (reviewer targeted run) | The 4 non-PreToolUse registrations are asserted as an exact excluded set rather than probed, consistent with the criterion's PreToolUse payloads |
| 10 | AC-2.5 follow-up potential item | PASS | `docs/features/potential/2026-09-25-codex-pushdown-live-verification.md`; `spec.md:338` links it | `grep -n codex-pushdown-live-verification spec.md` | |
| 11 | AC-3.1 AST top-level check | PASS | "invokes Get-EpicPlanningRegisteredMcpTool from no top-level statement"; `fail-before-planning-only-registry.2026-09-25T21-02.md` (33 failures before fix) | `Invoke-Pester` | |
| 12 | AC-3.2 `-RegistryPath`, no checkpoint allows | PASS | Hook line 210 parameter; "allows any tool with a missing registry when no checkpoint or attestation is present" | same | |
| 13 | AC-3.3 non-preparation `mcp__` allows | PASS | "allows an mcp__ tool with a missing registry on a non-preparation route" | same | |
| 14 | AC-3.4 `apply_patch`/`Bash` decisions unchanged | PASS | Two parametrized "returns the committed-registry decision" cases | same | |
| 15 | AC-3.5 lifecycle tools allowed | PASS | "allows lifecycle tool `<Tool>`"; "denies a lifecycle tool whose workspace_root differs" | same | |
| 16 | AC-3.6 semantic tools denied with named reason | PASS | "denies `<Tool>` with a reason naming the missing registry in preparation mode"; hook line 277 | same | |
| 17 | AC-3.7 committed registry allows semantic tools | PASS | "allows semantic tool `<Tool>` with the committed registry in preparation mode" | same | |
| 18 | AC-3.8 malformed fixture throws | PASS | `tests/fixtures/codex-hooks/invalid-orchestration-handoff-registry.json`; "throws for a semantic tool when the registry fixture is invalid" | same | |
| 19 | AC-3.9 bundle hook byte-identical | PASS | Blob hashes equal; `codex-epic-runtime-contracts.Tests.ps1` and the two pytest parity tests passed in reviewer runs | `git rev-parse HEAD:<path>` for both copies | |
| 20 | AC-4.1 Python rename publish, both modes | PASS | `test_module_pairs_publish_renamed_resources_in_full_tree_mode`, `..._in_pack_mode` | `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py` | |
| 21 | AC-4.2 unmapped config not published | PASS | `test_unmapped_config_file_is_not_published`, `test_codex_routing_lib_is_walked_as_published_root` | same | |
| 22 | AC-4.3 TypeScript pair publish | PASS | `codex-agents-customizations.test.ts` lines 58 (ordering test updated) and 159 (unmapped file) plus pair tests | `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/codex-agents-customizations.test.ts` | |
| 23 | AC-4.4 shared mirror byte-identical | PASS | `test_shared_codex_routing_modules_match_claude_lib_sources`; blob hashes equal | pytest; `git rev-parse` | |
| 24 | AC-4.5 no physical `.codex/lib/` | PASS | `test_no_physical_codex_lib_directory_exists`; `ls` reports both paths absent | pytest; `ls -d` | |
| 25 | AC-4.6 corpus proven against Python | PASS | `test_topology_corpus_matches_python_cli`, `test_deployment_corpus_matches_python_cli` | `poetry run pytest tests/scripts/dev_tools/test_codex_routing_cli_corpus.py` | |
| 26 | AC-4.7 wrapper parity via `pwsh -File` | PASS | `Resolve-CodexRouting.Parity.Tests.ps1` "matches the Python CLI for topology/deployment case `<id>` through pwsh -File" | `Invoke-Pester` | |
| 27 | AC-4.8 corpus case coverage | PASS | `test_corpus_covers_required_cases` | pytest | |
| 28 | AC-4.9 module candidate resolution | PASS | `codex-routing-cli-common.Tests.ps1` "module candidates" context (5 cases); "resolves modules through the .claude/lib fallback inside drm-copilot" | `Invoke-Pester` | |
| 29 | AC-4.10 bundle wrappers text-equal | PASS | Blob hashes equal for 3 script pairs; `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` passed | pytest; `git rev-parse` | |
| 30 | AC-4.11 `commit-steward` in port | PASS | `CodexDeployment.psm1:74`; family case extended; "resolves commit-steward to the Python resolver receipt"; `fail-before-commit-steward.2026-09-25T21-16.md` | `Invoke-Pester tests/scripts/claude-lib/codex-routing` | |
| 31 | AC-4.12 Claude bundle mirror | PASS | "mirrors every codex-routing module byte-identically into the bundle" passed; blob hashes equal | same | |
| 32 | AC-4.13 `shouldCopy` export, main-only copy | PASS | `prepack.cjs` diff; "exports shouldCopy and performs no copy when required" | `npm ... run test -- test/packaging/mcp-server-prepack.test.ts` | |
| 33 | AC-4.14 nested scripts copied, root scripts excluded | PASS | "copies the codex resolver wrappers and epic-child scripts"; "excludes the resources-root scripts subtree" | same | Extension Jest suite runs in CI |
| 34 | AC-4.15 `.py` excluded at every depth | PASS | "excludes Python files at every depth" | same | |
| 35 | AC-4.16 skill repointed | PASS | `test_codex_model_routing_skill.py` (3 tests, both copies); `fail-before-skill-repoint.2026-09-25T22-25.md` | pytest | MCP argument names confirmed in `mcp-tool-definitions.ts:440-445` |
| 36 | AC-5.1 `core.json` complete | PASS | Diff adds 12 hook/dependency paths and 5 routing paths; guard passes | pytest `test_codex_core_manifest_closure.py` | |
| 37 | AC-5.2 closure guard | PASS | `test_core_manifest_contains_registered_hook_closure_and_resolver_paths`; `fail-before-core-closure.2026-09-25T22-45.md` | same | |
| 38 | AC-5.3 closure unit tests | PASS | Three `test_closure_follows_*` tests and `test_guard_reports_hook_absent_from_manifest` | same | |
| 39 | AC-5.4 exception set pruned | PASS | `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS` is now `frozenset()`; completeness tests passed | pytest `test_push_down_codex_and_agents_pack_manifest_completeness.py` | |
| 40 | AC-5.5 generator no drift | PASS | `test_generator_check_mode_reports_no_drift` passed | pytest `test_generate_codex_agent_variants.py` | |
| 41 | AC-6.1 mirror parity tests | PASS | All named pytest and Pester parity tests passed in reviewer runs; 9 blob-hash pairs equal | pytest (11 files); `Invoke-Pester` (7 paths) | |
| 42 | AC-6.2 coverage registration | PASS | Both runsettings copies list the 3 `.codex/scripts` files; post-change XML has `sourcefile` entries for all three | `git diff ... pester.runsettings.psd1`; XML parse | |
| 43 | AC-6.3 coverage thresholds and no exclusions | PASS | Reviewer parse: Python file 98.04% / 85.71%, TS file 98.87% / 95.31%, PS new files 100%, hook 93.87%; 0 changed lines uncovered in each language; no exclude entry added | Reviewer scripts over the three coverage artifacts and `git diff -U0` hunks | The `evidence/coverage/` files exist on disk but are gitignored repository-wide (`.gitignore:59`); see code-review Minor finding |
| 44 | AC-6.4 single clean toolchain pass | PASS | `final-toolchain-single-pass.2026-09-26T00-26.md`; reviewer re-runs clean for all three languages | See policy-audit Appendix B | Python full suite carries 1 failure identical to the Phase 0 baseline (issue #510, gitignored `.claude/state` file), not attributable to the branch |
| 45 | AC-6.5 500-line limit | PASS | Largest changed non-doc file 428 lines | `wc -l` over the changed files | |
| 46 | AC-6.6 non-goals | PASS | `git diff --name-only 26d57cb3..HEAD` lists none of the protected paths, including both `.codex/config.toml` copies | `git diff --name-only 26d57cb3..HEAD -- packages/mcp-server/package.json .claude/hooks .codex/config.toml <bundle config.toml>` | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 46 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the CI run on the PR head is green (S9 gate); no CI status was available in the PR context (`gh` not installed).
2. After the next `@danmoisan/drm-copilot-mcp` release, execute `docs/features/potential/2026-09-25-codex-pushdown-live-verification.md`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, criteria evaluated as PASS may be checked off in the authoritative source file. All 46 criteria in `spec.md` were already checked (`- [x]`) by the executor before this review, and all 46 were evaluated PASS here, so no source-file change was needed and none was made. No criterion required unchecking.

### AC Status Summary

- Source: `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/spec.md`
- Total AC items: 46
- Checked off (delivered): 46
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/spec.md` | 46 | 46 | 0 | Checkbox-backed; only authoritative source for `full-bug` |
| `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/issue.md` | 0 | 0 | 0 | Not authoritative for `full-bug` |
