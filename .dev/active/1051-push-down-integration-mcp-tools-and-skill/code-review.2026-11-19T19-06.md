# Code Review: push-down integration MCP tools and skill (#1051)

---

**Review Date:** 2026-11-19
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue 1051 in the branch name
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `9ccf8b13ae530225a2b0175a9cd417b1403f2905`)
**Head Branch:** `feature/push-down-integration-mcp-tools-and-skill-1051` (head `370a84268c96ce408aaba260de56948071b6e120`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds 11 TypeScript production modules (about 2,770 executable lines) and 18 new Jest test files, edits 8 existing production modules with registration-only changes, and moves the `push-down-integration` skill, the Codex `enabled_tools` entries and the brief bullet through every mirror. The review inspected the full branch diff, the PR-context summary and appendix, the executor evidence under `evidence/`, the coverage artifacts and the modified production files line by line.

**What changed:**
`pushDownHarness` now calls `recordIntegrationNeeded` once after planning or applying; the writer collects items from report actions, #1050 workflow-name collisions and a shared conflict core evaluated over the post-run view (a read-only overlay for dry runs), and writes `.push-down-integration-needed.json` through `WriteIfChangedFileSystem`. `detect_push_down_integration` and `validate_push_down_integration` reach the destination only through a three-method read-only seam, and an owned YAML subset reader replaces any parser dependency. `push-down-ecosystem-registry.ts` generalizes its root-level guard into `RESERVED_ROOT_LEVEL_PATHS`.

**Top 3 risks:**
1. `collectCollisionItems` recovers the colliding path by matching a prose warning line produced by `findCiWorkflowNameCollisions`; a wording change upstream would silently drop `workflow-name-collision` items from the push-down (detect would still raise them through S25).
2. The owned YAML subset reader (712 lines) is the single parser for V1 and S29; constructs outside the subset fail V1 by design, which may reject some valid destination workflows until they are rewritten (spec Risks, "V1 strictness").
3. Tool availability in installed hosts depends on the next extension and MCP package release; until then the skill names tools that the installed MCP server does not expose.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; toolchain, coverage and contract tests pass at the reviewed head, subject to the S9 CI gate.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `extensions/drm-copilot/src/lib/push-down-integration/workflow-yaml-reader.ts` | whole file | 712 logical lines, at or above the 700-line advisory tier. | Consider splitting scalar and flow-collection parsing from extraction when the file is next changed; the spec's Language Classification also suggests a split near 500 lines. | File-size policy advisory tier; non-blocking. | Logical line count from a read-only Node count over the branch diff file list. |
| Minor | `extensions/drm-copilot/src/lib/push-down/push-down-integration-needed.ts` | lines 204-226 (`collectCollisionItems`) | The colliding path is parsed out of the human-readable `push-down conflict: workflow-name ... (layer ...` warning line with a regular expression, and `existing_name` is the literal `"CI"`. | When `push-down-ci-layer.ts` is next edited, expose a structured collision result (path and declared name) and build both the warning line and the item from it. | Couples the item source to warning wording; the literal is correct today only because `findCiWorkflowNameCollisions` matches the name `CI` alone. The S10 and S44 tests would catch a wording change, so the risk is contained. | `push-down-ci-layer.ts` lines 94-123; `push-down-integration-needed.test.ts`; `integration-end-to-end.test.ts` S44. |
| Info | `extensions/drm-copilot/src/lib/push-down/push-down-harness.ts` | `pushDownHarness`, lines 199-302 | The dry-run and apply return paths were merged into one, and the selection step now carries each ecosystem's input, removing an unreachable `?? {}` fallback. | None. | Behavior unchanged; branch coverage of the file rose from 96.92% to 98.46%. | `evidence/other/qa-loop-fix.2026-11-19T18-38.md`; lcov record for the file. |
| Info | repository | stage 4 | No `.dependency-cruiser.cjs` exists, so the architecture-boundary stage is not configured for `extensions/drm-copilot`. | None for this branch. | Pre-existing repository state; not introduced by this branch. | `evidence/qa-gates/typescript-static.2026-11-19T18-45.md`. |
| Info | `extensions/drm-copilot/test/` | three file names | Three plan-named test files gained a `-tools` suffix so the launcher keeps them in the unit lane (DEV-1). | None. | Keeps S42, S48 and S50 in the local gate and coverage run. | `evidence/other/deviations.2026-11-19T16-52.md`. |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The only Python change adds `detect_push_down_integration` and `validate_push_down_integration` to `EXPECTED_DRM_COPILOT_TOOLS` in the existing contract test; no Python file is added.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- Not affected.

### TypeScript implementation audit

#### What changed well

- I/O isolation: detect and validate receive an `IntegrationReadFileSystem` built by `readOnlySeam`, which exposes only `listFiles`, `isFile` and `readTextFile`; the dry-run overlay throws on `writeTextFile` and `ensureDir`.
- Reuse: `evaluateDestinationConflicts` is the single conflict core for the writer and detect; existing helpers (`compareCodePoint`, `stringifySorted`, `parseDestinationManifest`, `hashPayloadText`, `WriteIfChangedFileSystem`) are reused rather than duplicated.
- Registration edits in `mcp-tools.ts`, `repo-automation-service.ts`, `repo-automation-service-contract.ts`, the definition modules and `jest.config.cjs` are limited to imports, one `case` pair, two optional service methods and threshold entries (spec C6).
- `RESERVED_ROOT_LEVEL_PATHS` replaces a single-path guard with a list, so a future root-level file needs one line.

#### Type safety and maintainability

- No `any`, `as unknown as`, `@ts-*` or `eslint-disable` in the 11 new production files or the new tests (grep returned no match).
- Result types (`DetectIntegrationResult`, `ValidateIntegrationResult`, `IntegrationNeededResult`) are exported and used on the optional `integration` field of `RepoAutomationMcpToolResult`, leaving other tools' results unchanged (S47).

#### Error handling and logging

- Input errors and a host without the service method throw coded errors (`PUSH_DOWN_INTEGRATION_UNAVAILABLE`) to the dispatcher's existing failure path; a failing verdict is a completed run with `ok: true` (S42).
- `directoryRoot` fails fast when `workspace_root` is not a directory.

---

## Test Quality Audit

Every spec rule S1 to S56 has a named positive and negative Jest case or a named existing contract test. Coverage was re-derived by the reviewer from `extensions/drm-copilot/coverage/lcov.info`: the 11 new files total 99.60% lines and 97.15% branches; repo-wide Jest coverage rose from 97.44% to 97.52% lines and from 94.67% to 94.83% branches.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/push-down-integration/integration-end-to-end.test.ts` — S44 loop over one in-memory destination, including the negative case without the resolution edit.
- `extensions/drm-copilot/test/push-down-integration-no-model-call.test.ts` — S49 forbidden-token text test over every new production module, with a negative case for a look-alike import name.
- `extensions/drm-copilot/test/mcp-server.push-down-integration-tools.test.ts` — S50 capability and in-memory client test; the negative case shows a server-to-client request would be observed.
- `extensions/drm-copilot/test/packaging/push-down-integration-skill.test.ts` — S51 to S54 byte identity, loop order, per-kind table and not-checked list, each with a negative fixture.
- `evidence/qa-gates/coverage-comparison.2026-11-19T18-57.md` — per-file and repo-wide comparison against the Phase 0 baseline.

### Quality assessment prompts

- **Determinism:** pure functions over in-memory fakes; reverse-order listing fakes prove order independence (S7, S33).
- **Isolation:** one module per test file; cases named by rule.
- **Speed:** in-memory only; the full Jest suite passed inside the final gate.
- **Diagnostics:** structured `toEqual` comparisons print the differing item or rule entry.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credential or token literal. |
| No unsafe subprocess or command construction | ✅ PASS | No `child_process`, `http`, `https` or `net` import in new modules (S49 test). |
| Input validation at boundaries | ✅ PASS | `resolvePushDownIntegrationToolInput` with `additionalProperties: false`, required non-empty `workspace_root`, directory check. |
| Error handling remains explicit | ✅ PASS | Coded errors; no catch-all handler in new code. |
| Configuration / path handling is safe | ✅ PASS | S9 forbids absolute, drive-letter, UNC and `..` paths and any part of the destination root in the rendered file; manifest keys are validated by `parseDestinationManifest`. |
| No model call or MCP sampling | ✅ PASS | S49 and S50 tests; the server declares only the `tools` capability. |

---

## Research Log

No external research was required. Upstream contracts (#1029, #1049, #1050) were read from the repository and from `evidence/other/upstream-contracts.2026-11-19T15-34.md`.

---

## Verdict

The change is ready for the normal PR flow. The Findings Table holds one non-blocking file-size Warning, one Minor coupling observation and three Info notes; none requires remediation before merge. Merge readiness remains subject to the orchestrator's S9 CI green gate on the PR head.
