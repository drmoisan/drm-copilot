# Feature Audit: docs-mcp-tools (#1036)

- Review stamp: 2026-11-06T00-28 (UTC)

## Scope and Baseline

- Branch: `feature/docs-mcp-tools-1036-r2`, head `ca0d5c2dc29d29c4d70468957ee8eb911085cb05`.
- Resolved base: `origin/epic/documentation-estate-tooling-integration` (epic mode; integration tip `82492b61a7788befcde52353a6fc3925c99a783c`). The merge base `82492b61a7788befcde52353a6fc3925c99a783c` was confirmed with `git merge-base`.
- Diff: `git diff 82492b61a7788befcde52353a6fc3925c99a783c...HEAD` covers 64 paths and 10 commits.
- Feature folder: `docs/features/active/2026-10-30-docs-mcp-tools-1036`.
- PR context artifacts are absent (no pull request exists yet). The git diff above is the scope source.

## Requirements Source and Work Mode

`issue.md` line 12: `- Work Mode: full-feature`. AC sources: `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`.

## Acceptance Criteria Inventory

### Acceptance criteria

- `spec.md`: 31 checkbox items. SAC-1 to SAC-5 are the epic criteria; SAC-6 to SAC-31 are the refined criteria, numbered in document order.
- `user-story.md`: 23 checkbox items. US-E1 to US-E5 are the epic criteria; US1-1 to US1-6, US2-1 to US2-6 and US3-1 to US3-6 are the story criteria.
- At review start, 50 of 54 items were checked by the executor. The 4 unchecked items were SAC-27, SAC-31, US2-6 and US3-6.

## Acceptance Criteria Evaluation

Each item was re-evaluated by the reviewer against code inspection, the reviewer's own Jest re-run (13 suites, 188 passed), the lcov recomputation, the line-count measurement, the brief hashes, and the executor evidence.

| ID | Criterion (abridged) | Status | Evidence |
|---|---|---|---|
| SAC-1 / US-E1 | Six tools validate input, invoke the subcommand with `-Json`, return exit code and findings | PASS | `resolveDocsToolInput`, `buildDocsCommandArguments`, `handleDocsTool`; argv tests in `test/repo-automation-execute-docs.test.ts`; probe `evidence/other/docs-probe.2026-11-06T00-18.md` |
| SAC-2 / US-E2 | Invalid input is rejected before any process starts | PASS | resolver throws before the `runDocsCommand` call; `rejects invalid input` tests assert the launcher is not called |
| SAC-3 / US-E3 | `update_docs_ledger` is the only mutating tool and routes via `update-ledger` | PASS | `DOCS_MUTATING_TOOLS`; only the `update_docs_ledger` table has a `write` switch row |
| SAC-4 / US-E4 | No logic beyond mapping and parsing in TypeScript | PASS | code inspection: tables, grammar checks, structural parse; `result` opaque |
| SAC-5 / US-E5 | Jest >= 85% lines, >= 75% branches on new modules | PASS | lcov: 99.88% lines, 98.05% branches combined; minimum per file 99.59% / 92.86% |
| SAC-6 / US3-2 | 49 tools, docs block after `render_subagent_tree` and before `validate_discovery_artifacts` | PASS | `src/repo-automation-tool-names.ts` diff; `mcp-discovery-authority-tool-definitions.test.ts` asserts 49 |
| SAC-7 | Literal `case` labels; packaging test passes unedited | PASS | `src/mcp-tools.ts` diff; `test/packaging/discovery-resources.test.ts` not in diff, passes in reviewer re-run |
| SAC-8 | Closed schemas, `workspace_root` required, one shared constant in both surfaces | PASS | `definition()` in `mcp-docs-tool-definitions.ts`; `...DOCS_TOOL_DEFINITIONS` in both definition files |
| SAC-9 / US1-5 | Optional `annotations`; read-only and destructive hints; `listTools()` observes them | PASS | `ToolDefinition.annotations?` in both files; `test/mcp-server.docs.test.ts` |
| SAC-10 | `DOCS_MUTATING_TOOLS` equals the non-read-only set; only the ledger has `write`; no receipt/output field | PASS | `test/mcp-docs-tool-definitions.test.ts` |
| SAC-11 / US2-1 / US2-2 | Exact argv per tool; options per upstream row; one table per tool | PASS | `DOCS_TOOL_INPUT_TABLES`; `evidence/baseline/upstream-contract.2026-11-05T23-35.md` |
| SAC-12 / US1-3 | `-Write` only when `write` is `true` | PASS | `emitRow` boolean case returns `[]` for `false` |
| SAC-13 / US1-4 | No `-Write` on inventory or reference; no `-WriteReceipt` on validate | PASS | no such rows in those tables |
| SAC-14 | No reserved option derived from input; empty array or omitted field emits nothing | PASS | unknown-key rejection; `items.flatMap` of an empty array; omitted fields skipped |
| SAC-15 / US1-6 | Rejection matrix (unknown key, type, enum, empty, grammar, leading `-`, duplicate pages, per-operation, validate without mode or revision) | PASS | `checkString`, `emitRow`, `checkLedgerOperation`; `test/mcp-tool-inputs-docs*.test.ts` |
| SAC-16 / US2-4 | Missing companion value not rejected | PASS | `does not reject a missing companion value that the ledger reports as a finding` |
| SAC-17 | Grammar parity test against the committed docs-common schema | PASS | parity test in `test/mcp-tool-inputs-docs.test.ts`; `evidence/baseline/upstream-grammars.2026-11-05T23-35.md` |
| SAC-18 / US1-2 / US2-5 | Host failure codes in order; launcher not called; code-prefixed `ok: false` | PASS | `invokeDocsCommand` check order; `checks workspace root, entry script and pwsh in that order`; entry-script message names `push_down_claude_customizations` |
| SAC-19 | Launch error yields `DOCS_PWSH_UNAVAILABLE`; no `powershell` fallback | PASS | `outcome.launchError` branch; resolver names `pwsh` only |
| SAC-20 | Parser envelope codes; valid envelopes for exit codes 0 to 3 | PASS | `test/docs-command-envelope.test.ts` |
| SAC-21 / US3-3 | Contract test reads the committed envelope schema read-only | PASS | envelope contract test passes in reviewer re-run |
| SAC-22 / US1-1 / US2-3 | Exit-code mapping, `docs` unchanged, summary form, `stderr_excerpt` only for exit 3, `isError` through `InMemoryTransport` | PASS | `handleDocsTool`; `test/mcp-handlers/docs-handlers.test.ts`; `test/mcp-server.docs.test.ts` |
| SAC-23 | `cwd` equals workspace root; one launch, no retry; launcher from `discovery-runtime.ts`, which is unchanged | PASS | `invokeDocsCommand`; `src/discovery-runtime.ts` not in diff |
| SAC-24 | `runDocsCommand` optional; mocks compile unedited; service test uses injected seams | PASS | contract diff; `test/repo-automation-service.test.ts` |
| SAC-25 / US3-1 | Enumeration rows 1, 2, 14 updated; Unchanged rows pass unedited | PASS | diff touches only rows 1, 2, 8 (permitted addition) and 14; unchanged suites pass in reviewer re-run |
| SAC-26 | `.codex/config.toml`, bundle copy, `.claude/settings.json` unchanged | PASS | none in `git diff --name-status` |
| SAC-27 / US2-6 | Brief bullet byte-identical in every copy, and push-down resource contract tests pass | PENDING CI | six copies MD5 `fe43258b50ec159b4fafdeef50efb595`; the stage 6 test cannot pass locally under a `worktrees` path (finding PA-1) |
| SAC-28 | README lists tools, inputs, `docs` field, prerequisites; CHANGELOG `### Added` | PASS | `extensions/drm-copilot/README.md` lines 128-221; CHANGELOG diff |
| SAC-29 / US3-4 | `jest.docs-coverage.json` 85/75 entries; one spread line; per-file figures recorded | PASS | config diff; figures are recorded in `evidence/qa-gates/jest-coverage.2026-11-06T00-09.md`. The criterion names `evidence/coverage/`, which is not a canonical evidence kind, and the non-overridable evidence skill requires `evidence/qa-gates/` |
| SAC-30 / US3-5 | No temporary file or `pwsh` spawn; injected fakes; seeded shuffle passes | PASS | `evidence/qa-gates/test-isolation-scan.2026-11-06T00-10.md`; `evidence/regression-testing/jest-shuffle.2026-11-06T00-09.md`; [P8-T8] orchestrator decision |
| SAC-31 / US3-6 | New files below 500 lines, no edited file above 800, seven-stage toolchain in a single pass | PENDING CI | sizes verified by reviewer (max new 492, max edited 562); stages 1-3, 5 and 7 pass; stage 4 N/A; stage 6 awaits CI (PA-1) |

## Summary

- Total AC items: 54 (31 spec, 23 user story).
- PASS: 50. PENDING CI: 4 (SAC-27, SAC-31, US2-6, US3-6). PARTIAL, FAIL or UNVERIFIED: 0.
- The pending items are CI-dependent criteria under `acceptance-criteria-tracking` `### CI-Dependent Criteria`. They are owned by the item's orchestrator run at S9, together with plan tasks [P7-T4], [P8-T7] and [P8-T13].
- Blocking finding: PA-1, remediability `awaiting_ci`. Review verdict: `AWAITING_CI`.
- Non-blocking note: spec `### Tool input tables` still states `limit` as a positive integer; the implementation follows plan D-1 (`diagnostic-` identifier), which is backed by upstream evidence.

## Acceptance Criteria Check-off

- Newly checked by this review: none. All 50 items evaluated as PASS were already `[x]` in `spec.md` and `user-story.md`, and the reviewer's evaluation agrees with each existing check-off.
- Left unchecked: SAC-27 and SAC-31 in `spec.md`; US2-6 and US3-6 in `user-story.md`. Each is pending CI as described above.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-docs-mcp-tools-1036/spec.md`, `docs/features/active/2026-10-30-docs-mcp-tools-1036/user-story.md`
- Total AC items: 54
- Checked off (delivered): 50
- Remaining (unchecked): 4
- Items remaining: "The execution-environment brief bullet for the docs tools is present and byte-identical in every copy listed under `## Implementation Strategy`, and the push-down resource contract tests pass." (spec); "Every new production and test file is below 500 logical lines, no edited file rises above 800, and the seven-stage toolchain passes in a single pass." (spec); "The execution-environment brief bullet stating that the docs tools run the workspace's `.claude/lib/docs/Invoke-DocsCommand.ps1` is present and byte-identical in every copy listed in spec `## Implementation Strategy`." (user story); "Every new file is below 500 logical lines and the seven-stage toolchain passes in a single pass." (user story)
