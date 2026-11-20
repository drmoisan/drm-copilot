# Code Review: docs-mcp-tools (#1036)

- Branch: `feature/docs-mcp-tools-1036-r2` at `ca0d5c2dc29d29c4d70468957ee8eb911085cb05`
- Base: `origin/epic/documentation-estate-tooling-integration`, merge base `82492b61a7788befcde52353a6fc3925c99a783c`
- Scope: full branch diff (`git diff 82492b61a7788befcde52353a6fc3925c99a783c...HEAD`), 64 paths
- Review stamp: 2026-11-06T00-28 (UTC)

## Executive Summary

The change adds six MCP tools as thin TypeScript wrappers over `.claude/lib/docs/Invoke-DocsCommand.ps1`. The design follows the spec. Each tool has one declarative input table (`src/mcp-tool-inputs-docs.ts`). The executor (`src/repo-automation-execute-docs.ts`) performs three ordered pre-launch checks (absolute workspace root, entry script present, `pwsh` resolvable) and one argv-array launch with no shell. The envelope parser (`src/docs-command-envelope.ts`) is pure and has no state. The handler (`src/mcp-handlers/docs-handlers.ts`) passes the envelope through unchanged. TypeScript does not inspect or reshape `result`, and only `update_docs_ledger` can emit `-Write`, and only when `write` is `true`.

The review found no Blocker and no Major code defect. The one blocking item is a CI-dependent contract-test confirmation (stage 6), recorded in the policy audit as PA-1 and classified `awaiting_ci`. The Minor and Info findings below are non-blocking. No covered file is at or above the 700-line advisory tier, so no file-size Warning row applies.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking (awaiting_ci) | `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` (unchanged; exercised by this change) | `test_execution_environment_fact_is_unchanged_across_copies`, path filter at line 454 | The stage 6 test excludes every path with a `worktrees` component, so in this checkout it finds 0 of 6 brief copies and fails (`assert 0 == 6`). The six copies are byte-identical, so the test is expected to pass in CI. | Run CI on the PR head (dispatch `ci.yml` manually for an epic-child PR) and confirm this test passes before checking off SAC-27, SAC-31, US2-6 and US3-6. | Toolchain stage 6 must pass in a single pass. Local evidence cannot produce that pass for an environment reason, not a code reason. | `evidence/qa-gates/contract-tests-final.2026-11-06T00-09.md`; reviewer MD5 of all six copies = `fe43258b50ec159b4fafdeef50efb595` |
| Minor | `docs/features/active/2026-10-30-docs-mcp-tools-1036/spec.md` | `### Tool input tables`, `update_docs_ledger` row; `### Option emission` ("integers are emitted as decimal strings") | The spec still describes `limit` as a positive integer. The implementation treats it as a `diagnostic-`-prefixed identifier string, per plan D-1 and the binding confirmation `### F1a`. | Optionally amend the spec row and the integer-emission sentence to match D-1 so that 900009 reads one contract. Not required for this review. | Documentation drift between spec and implementation can mislead later children. The code follows the authoritative upstream contract. | `plan.2026-10-30T18-58.md` line 27; `evidence/baseline/upstream-grammars.2026-11-05T23-35.md` line 28 |
| Info | `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` | `fieldSchema`, `FIELD_DESCRIPTIONS[row.field] ?? row.field` | The `?? row.field` fallback cannot be reached because every table field has a description. It is the one uncovered branch in this module (13/14). | Keep it as a defensive default, or add a test asserting that every table field has a description entry. | Branch coverage remains 92.86%, above 75%. | `extensions/drm-copilot/coverage/lcov.info` |
| Info | `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` | `fieldSchema` case `"string"` | The advertised input schemas carry `minLength: 1` but not the grammar `pattern` strings. Clients learn about grammar violations only from the `DOCS_INPUT_INVALID` error, not from the schema. | Consider adding `pattern` to string fields in a later change if client-side validation is wanted. | This is not required by the spec. Server-side validation before launch is complete and parity-tested. | `src/mcp-tool-inputs-docs.ts` grammar constants |
| Info | `extensions/drm-copilot/src/mcp-tools.ts`, `src/mcp-handlers/docs-handlers.ts` | imports | A type-only import cycle exists (`mcp-tools.ts` imports `handleDocsTool`; `docs-handlers.ts` imports the `RepoAutomationMcpToolResult` type). It is erased at compile time and creates no runtime cycle. | None required. | This matches the existing handler pattern in the extension. | `git diff` of both files |

## Implementation Audit

### TypeScript implementation audit

- What changed well: argv construction comes only from declarative tables, and the reserved names `Command`, `Json`, `Help` and `RepositoryRoot` cannot be produced from input because no table row maps to them. Option values that begin with `-` are rejected before launch (OQ-C). Pre-launch checks run in the specified order, and a launcher-reported error maps to `DOCS_PWSH_UNAVAILABLE`. The `pwsh` resolver names only `pwsh`, with no fallback to Windows `powershell`.
- Type safety and maintainability: `DocsToolName` is derived from `DOCS_TOOL_INPUT_TABLES` with `as const satisfies`, so the dispatcher and the tables cannot drift. `DocsHostErrorCode` is a closed union. The project compiles under strict TypeScript with `exactOptionalPropertyTypes`, with zero `any` and zero suppressions in new code. There are two narrowing casts: `JSON.parse(...) as unknown` and `rawInput as InputRecord` after an object check. Both are justified.
- Error handling: input errors are thrown as `DocsInputError` (`DOCS_INPUT_INVALID: ...`), and host errors as code-prefixed `DocsHostError`. Exit codes 1 to 3 are returned as `ok: false` results that carry the envelope, not thrown. No error is swallowed. `parseJsonDocument` rethrows with context.
- Envelope parsing: the parser enforces the exact top-level key set, the exact finding key set, `exit_code` in 0 to 3, `ok === (exit_code === 0)`, agreement between the process and envelope exit codes, and command agreement. `result` is passed through as `unknown`.
- Service seam: `runDocsCommand?` is optional on `RepoAutomationService`, so existing `jest.Mocked<RepoAutomationService>` literals compile unchanged. `DefaultRepoAutomationService.runDocsCommand` spreads the optional `docs` seams over the Node defaults.

Python, PowerShell and C# implementation audits: not applicable; zero changed files in those languages.

## Test Quality Audit

### Reviewed test and QA artifacts

- New tests: `test/docs-command-envelope.test.ts`, `test/mcp-tool-inputs-docs.test.ts`, `test/mcp-tool-inputs-docs.ledger.test.ts`, `test/repo-automation-execute-docs.test.ts`, `test/mcp-docs-tool-definitions.test.ts`, `test/mcp-handlers/docs-handlers.test.ts`, `test/mcp-server.docs.test.ts`.
- Edited tests: `test/mcp-server.test.ts`, `test/mcp-discovery-authority-tool-definitions.test.ts` (count 43 to 49), `test/mcp-server-test-service.ts`, `test/repo-automation-service.test.ts`.
- QA artifacts: `evidence/qa-gates/*.2026-11-06T00-0*.md`, `evidence/regression-testing/jest-shuffle.2026-11-06T00-09.md`, `evidence/other/docs-probe.2026-11-06T00-18.md`.
- Reviewer re-run: 13 suites (the seven new suites, the four edited suites, and the unchanged enumeration suites `test/packaging/discovery-resources.test.ts`, `test/mcp-repo-automation-tool-definitions.test.ts`, `test/mcp-discovery-tool-definitions.test.ts`): 188 passed, 0 failed.

### Quality assessment prompts

| Prompt | Assessment |
|---|---|
| Determinism | No clock, randomness or real I/O; seeded shuffle passes |
| Isolation | One behavior per test; fresh fakes per test |
| Speed | 13 suites in 3.2 s |
| Diagnostics | Case-labelled loop assertions |
| Temporary files / processes | None; `pwsh` appears only as a stub resolver label and in an argv assertion |

## Security / Correctness Checks

| Check | Result |
|---|---|
| No secrets in code | PASS |
| Subprocess construction | PASS: argv array, no shell, `pwsh` resolved from PATH, values beginning with `-` rejected, empty stdin |
| Input validation at the boundary | PASS: unknown keys, wrong types, enum, grammar, duplicate pages, per-operation rules |
| Path handling | PASS: absolute workspace root required; relative-path grammar rejects leading `/` and `.`/`..` segments |
| Mutation surface | PASS: TypeScript writes nothing; only `update_docs_ledger` with `write: true` emits `-Write`; `-WriteReceipt` is never emitted |
| Permission exposure (OQ-B) | PASS: `.codex/config.toml`, its bundle copy and `.claude/settings.json` are not in the diff |

## Research Log

- Read `spec.md`, `user-story.md`, `issue.md` (Work Mode `full-feature`), plan D-1, and the evidence artifacts listed above.
- Read all five new production modules in full, plus the production diffs of the six edited modules.
- Parsed `extensions/drm-copilot/coverage/lcov.info` for per-file and suite figures.
- Measured logical line counts with `awk 'END{print NR}'` for all 23 covered changed files.
- Hashed the six execution-environment brief copies.
- Searched the new sources and tests for `any` and suppression directives (0 matches).
- Confirmed that `repo-automation-service-contract.ts` is type-only.

## Verdict

No code changes are required. Review verdict `AWAITING_CI`: the single blocking item is the CI confirmation of the stage 6 contract test, classified `awaiting_ci`.
