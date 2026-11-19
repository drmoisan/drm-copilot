# Feature Audit: push-down integration MCP tools and skill (#1051)

---

**Audit Date:** 2026-11-19
**Feature Folder:** `docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051`
**Base Branch:** `epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/push-down-integration-mcp-tools-and-skill-1051`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (commit `9ccf8b13ae530225a2b0175a9cd417b1403f2905`)
- **Head branch/commit:** `feature/push-down-integration-mcp-tools-and-skill-1051` (commit `370a84268c96ce408aaba260de56948071b6e120`)
- **Merge base:** `9ccf8b13ae530225a2b0175a9cd417b1403f2905`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-19 19:05:09 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051/evidence/**`
  - Additional evidence: `extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`, direct inspection of the branch diff and test files
- **Feature folder used:** `docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 10 carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources.
- **Scope note:** The audit covers the full branch diff against the resolved base (118 files). The seeded scratch-destination integration scenario is CI-dependent or orchestrator-owned per the spec and is represented locally by the S44 case.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051/spec.md` — primary source (`## Acceptance Criteria`, 8 items)
- `docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051/user-story.md` — secondary source (8 items with the same meaning; wording adds the word "spec" before rule references)

### Acceptance criteria

1. AC1 (draft 1): An apply-mode push-down writes `.push-down-integration-needed.json` listing each unresolved decision it observes, with the schema, kind vocabulary, id, ordering, rendering and forbidden-content rules of S1 to S9, the sources of S10, the post-run view of S11, the write rule of S12, no manifest entry (S13) and the result field of S14; a dry run returns the same items without writing; and the writer module passes the no-model-call text test of S49.
2. AC2 (draft 2): `detect_push_down_integration` returns `integration.ecosystems`, `integration.workflows` and `integration.conflicts` per S21 to S31, using the workflow reader of S15 to S20, and a write-recording fake records no write (S32, S33).
3. AC3 (draft 3): `validate_push_down_integration` fails on unparsable or unsupported YAML (V1, S36), a malformed data file (V2, S37), missing required check names (V3, S38), mismatched coverage artifact paths (V4, S39) and inconsistent manifest hashes (V5, S40), each shown by a failing fixture; passes on a correct integration shown by a passing fixture per rule and by the end-to-end case of S44; and returns the verdict shape and `not_checked` list of S35 and S41 with read-only, deterministic behavior (S43).
4. AC4 (draft 4): The `push-down-integration` skill documents the read, resolve, validate loop and stop condition, names `detect_push_down_integration` and `validate_push_down_integration`, covers every item kind and resolution option, and states the same not-checked list as the tool (S51 to S54).
5. AC5 (draft 5): `detect_push_down_integration` and `validate_push_down_integration` follow the existing MCP tool conventions (explicit required `workspace_root`, `additionalProperties: false`, read-only annotations, structured `integration` result, `ok` semantics) and have unit tests with injected in-memory file-system seams (S23, S34, S42, S45 to S48).
6. AC6 (draft 6): No new Python file is added; the tools and writer are TypeScript and no helper script is added (C1, C2, Language Classification).
7. AC7 (owner behavior 5): No new module calls a model or uses MCP sampling, shown by the text test of S49 and the capability and in-memory client test of S50.
8. AC8: Both tools are reachable from Codex through `enabled_tools` and the `repo-automation-adapter` skill without a `.claude/settings.json` edit (S55), and the execution-environment brief bullet is present after the docs-tools bullet in every `_BRIEF_COPIES` copy with byte identity preserved (S56).

The `user-story.md` items AC1 to AC8 carry the same criteria with rule references written as "spec S1", "spec S21" and so on; they are evaluated together with the `spec.md` items below.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 integration-needed writer | PASS | `src/lib/push-down/push-down-integration-needed.ts` (one call site in `pushDownHarness`; `PostRunOverlayFileSystem` for dry runs; `WriteIfChangedFileSystem` write); `src/lib/push-down-integration/integration-items.ts` (S2 to S9 constants and rendering); `RESERVED_ROOT_LEVEL_PATHS` in `push-down-ecosystem-registry.ts` (S1); tests `push-down-integration-needed.test.ts`, `integration-items.test.ts`, S49 text test; `push-down-apply.ts` not in the diff. 100.00% lines, 95.56% branches for the writer. | `git diff --name-status 9ccf8b13ae530225a2b0175a9cd417b1403f2905..HEAD`; `node <scratch>/lcov.cjs extensions/drm-copilot/coverage/lcov.info ...` | Collision items are parsed from the #1050 warning line (Minor code-review note); behavior is covered by S10 and S44 tests. |
| 2 | AC2 detect tool | PASS | `integration-detect.ts`, `integration-ecosystems.ts`, `workflow-yaml-reader.ts`; tests `integration-detect.test.ts`, `integration-ecosystems.test.ts`, `workflow-yaml-reader.test.ts`, `workflow-yaml-reader-templates.test.ts` (S20 against the rendered #1050 caller and bundled harness workflows); write-recording fake asserts no write (S32), reverse-order fake (S33). | Jest final gate (`evidence/qa-gates/jest-coverage.2026-11-19T18-44.md`, 6454 passed) | Reader 98.46% lines, 97.67% branches. |
| 3 | AC3 validate tool | PASS | `integration-validate.ts` (V1 to V3, verdict, `VALIDATE_NOT_CHECKED`), `integration-validate-artifacts.ts` (V4 transitive `uses:`, V5 manifest hash with `.push-down-exclusions`); 20 rule-named positive and negative cases across `integration-validate.test.ts` and `integration-validate-artifacts.test.ts`; S44 end-to-end loop passes after resolution and fails without it. | `grep` of rule-named test titles; Jest final gate | V4 contract case reads `.claude/hooks/validate-feature-review-coverage-metrics.ps1` and the bundled workflows from the tracked tree, as the spec requires. |
| 4 | AC4 skill | PASS | `.agents/skills/push-down-integration/SKILL.md` and five copies, byte-identical (one SHA-256 `7a43116e...` for all six); `references/standard.md` identical in both locations; `push-down-integration-skill.test.ts` S51 to S54 with negative fixtures; pack manifests and `config/harness-parity-matrix.json` updated. | `sha256sum <six SKILL.md copies>`; Jest final gate; pytest and Pester pinned contract tests | — |
| 5 | AC5 MCP conventions | PASS | `mcp-push-down-integration-tool-definitions.ts` (`workspace_root` required, `additionalProperties: false`, `readOnlyHint: true`, `openWorldHint: false`); `mcp-tool-inputs-push-down-integration.ts`; handler returns `ok: true` with `integration` for completed runs and throws coded errors otherwise; registration in `repo-automation-tool-names.ts`, both definition surfaces and `dispatchRepoAutomationTool`; service wiring through a read-only seam. Tests: tool-definitions, inputs, handlers, service and server test files. | Jest final gate; diff of `mcp-tools.ts`, `repo-automation-service.ts`, `repo-automation-service-contract.ts` | Three test files renamed with a `-tools` suffix (DEV-1) to stay in the unit lane. |
| 6 | AC6 no new Python | PASS | `git diff --name-status` shows one Python file, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, status `M`; no `.py` file added; no helper script added; all new production files are `.ts`. | `git diff --name-status 9ccf8b13ae530225a2b0175a9cd417b1403f2905..HEAD` | — |
| 7 | AC7 no model call, no sampling | PASS | `push-down-integration-no-model-call.test.ts` (S49, every new production module, with a negative case); `mcp-server.push-down-integration-tools.test.ts` (S50: only the `tools` capability, both calls complete with a client declaring `capabilities: {}`, no server-to-client request). | Jest final gate | — |
| 8 | AC8 Codex exposure and brief | PASS | `.codex/config.toml` and its bundle copy are byte-identical and add both names; `repo-automation-adapter` skill and bundle copy list both tools; `.claude/settings.json` not in the diff; brief bullet added to every execution-environment copy; `push-down-integration-exposure.test.ts`, `push-down-integration-brief.test.ts`, `test_push_down_codex_and_agents_resource_contracts.py` and `test_brief_copies_are_byte_identical` pass. | `sha256sum .codex/config.toml <bundle copy>`; pytest final gate (17122 passed) | — |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 8 criteria (in each of `spec.md` and `user-story.md`)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the S9 CI green gate on the PR head, including the CI integration lane and the seeded scratch-destination scenario where the orchestrator runs it.
2. After the next extension and MCP package release, confirm both tools are listed by an installed host.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051/spec.md`, `docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051/user-story.md`
- Total AC items: 16 (8 per file)
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 8 | 8 | 0 | Checkbox-backed; all eight were already checked by the executor and are confirmed PASS by this review |
| `user-story.md` | 8 | 8 | 0 | Checkbox-backed; all eight were already checked by the executor and are confirmed PASS by this review |

No source-file checkbox change was made by this review, because every criterion evaluated PASS was already checked. The unchecked `## Definition of Done` and `## Seeded Test Conditions` items in `spec.md` are not acceptance criteria and were not changed.
