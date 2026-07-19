# Code Review: legacy-discovery-mcp-vscode (#370)

---

**Review Date:** 2026-07-19
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370`
**Feature Folder Selection Rule:** Folder suffix matches the issue number (#370) in the branch name `feature/legacy-discovery-mcp-vscode-370`; it is the only active folder with material scoping-doc changes on this branch.
**Base Branch:** `epic/legacy-discovery-and-parity-integration` (merge-base `a6dd7d4591ef80f4d351cea4b0488ce08568286e`)
**Head Branch:** `feature/legacy-discovery-mcp-vscode-370` (head `9525dd0a529ff833f13c0c0bec8076794492d16e`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds an MCP + VS Code exposure layer over the landed `dev.discovery.*` Python CLI: seven new MCP tools, seven VS Code commands, a Python runtime probe, a central tool-to-CLI mapping table, and a Python `-c` subprocess executor. The diff is 4,422 insertions / 303 deletions across 45 files; all production code is TypeScript under `extensions/drm-copilot/`. Evidence reviewed: full baseline diff (`artifacts/pr_context.summary.txt` / `.appendix.txt` regenerated at head), executor baseline/QA evidence in the feature folder, and an independent reviewer re-run of the entire toolchain (Prettier check, ESLint, TSC, Jest coverage — all clean; 165 suites / 2006 tests; 96.30% lines / 89.22% branches).

**What changed:**
Six new production modules (`repo-automation-execute-discovery.ts`, `mcp-tool-inputs-discovery.ts`, `mcp-handlers/discovery-handlers.ts`, `mcp-discovery-tool-definitions.ts`, `discovery-command-registration.ts`, and the type-only `repo-automation-service-contract.ts` extraction) plus lockstep edits to the tool-name union, both definition files (via a shared spread), the exhaustive dispatch switch, the service implementation, `extension.ts` activation, `package.json` `contributes.commands`, and per-file coverage thresholds in a new `jest.config.cjs`. Ten test files added or extended (+120 tests).

**Top 3 risks:**
1. Runtime environmental dependency: at execution time the target workspace must supply a Python interpreter and an importable discovery package; this is by design (probed fail-fast, stderr surfaced) and is untestable end-to-end here (faked spawn boundary is an explicit non-goal boundary).
2. Enum/contract drift with the upstream Python CLI would only surface at runtime; mitigated by centralizing every landed `module:function` and flag in one mapping table with a reconciliation header comment.
3. Jest-on-Windows cannot discover tests under the dotted `.claude/worktrees` path; CI and non-dotted checkouts are unaffected, but local reviewers in dotted worktrees must use the documented mirror procedure.

**PR readiness recommendation:** **Go** — all toolchain gates pass in independent re-execution, coverage exceeds policy floors per file and in aggregate, and no Blocker or Major findings exist.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `extensions/drm-copilot/src/repo-automation-execute-discovery.ts` | lines 425–442 (`runDiscoveryReport`) | When called with a `RunDiscoveryReportInput` missing the report_type-conditional fields, the helper substitutes empty strings (`input.coverageInput ?? ""`, `input.inputPath ?? ""`) and proceeds to spawn, deferring failure to the CLI's argparse error. | Consider throwing an explicit `Error` naming the missing field instead of the `?? ""` fallback, mirroring the fail-fast style used for unsupported `report_type`. | Fail-fast at the TypeScript boundary produces a clearer error than a subprocess argparse failure. Unreachable through both exposed surfaces (MCP resolver and VS Code prompts enforce the fields first), so severity is Minor. | Inspected file; `resolveRunDiscoveryReportToolInput` (`mcp-tool-inputs-discovery.ts` lines 227–245) enforces the fields before any spawn. |
| Info | `extensions/drm-copilot/src/repo-automation-execute-discovery.ts` | lines 58–88 (input interfaces) | `artifactType`/`reportType` are typed `string` rather than the narrowed `DiscoveryArtifactType`/`DiscoveryReportType` unions. | None required. Narrowing would invert the module dependency (the union types live in `mcp-tool-inputs-discovery.ts`, which imports from this module) and create a cycle; the mapping-table lookup throws on unsupported values, preserving fail-fast behavior. | Documented so a future refactor can consider relocating the enum constants if compile-time narrowing is wanted. | Inspected both modules; unsupported-value tests pass (`test/repo-automation-execute-discovery.test.ts`). |
| Info | `extensions/drm-copilot/src/discovery-command-registration.ts` | lines 148–179 (`registerAnalyzerCommand`) | The interactive path for the three analyzer commands prompts for nothing and runs with workspace defaults (no `profile_path`/`output_dir` prompts). | None required; both fields are optional in the CLI contract and the inline comment records the intent. Direct-argument invocation supports the optional fields. | Interactive minimalism is a deliberate, documented choice, not an omission. | Inspected file; `test/extension.discovery-commands.test.ts` covers both paths. |
| Info | `extensions/drm-copilot/jest.config.cjs` | `coverageThreshold` block | Per-file thresholds only (no `global` key), with two type-only files omitted from the gate (justification comments inline). | None required; consistent with the pre-existing issue #305 convention and the interface-only clarification in `.claude/rules/general-unit-test.md`. Both omitted files remain in `collectCoverageFrom`. | Confirms no production path is excluded from coverage measurement. | Inspected config; lcov shows `repo-automation-service-contract.ts` measured (0/175 executable lines, type-only confirmed by file inspection). |

No Blockers or Major findings.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- Single-source contract surfaces: the seven tool definitions live once in `mcp-discovery-tool-definitions.ts` and are spread into both definition files, making cross-file misalignment structurally impossible; the enum literals live once in `mcp-tool-inputs-discovery.ts` and are consumed by schemas, resolvers, and VS Code prompts.
- The central mapping table plus reconciliation header comment (`repo-automation-execute-discovery.ts` lines 10–35) confines every landed `module:function` name and flag to one module and records why interpreter `-c` invocation is required (dotnet/vsto/init entries are not `python -m`-runnable; no Poetry-on-PATH dependency).
- The exhaustive `switch` over `RepoAutomationToolName` with no `default` turns a missing dispatch case into a compile error — the lockstep contract is compiler-enforced.
- Proactive extraction of the type-only service contract (`repo-automation-service-contract.ts`) with re-exports kept `repo-automation-service.ts` at 439 lines without breaking any importer.
- The Python runtime probe mirrors the existing PowerShell probe's structure, ordering rationale comments, and error-message style.

#### Type safety and maintainability

- No `any`; raw MCP input flows as `unknown` through `asToolArgumentObject` and field-level normalizers. No type assertions beyond `as const` tuples and a `candidate is string` filter predicate. Zero ESLint/TS suppressions added in the diff.
- Optional-field spreading (`...(x === undefined ? {} : { x })`) keeps `exactOptionalPropertyTypes`-style cleanliness in constructed inputs.
- See Findings Table (Info) for the deliberate wide `string` typing of `reportType`/`artifactType` at the executor layer.

#### Error handling and logging

- Invalid input throws in resolvers before any service or spawn work; the dispatch `catch` converts to the structured `{ ok: false, summary, stderr_excerpt }` failure result with `isError: true` — no silent failures.
- `CommandExecutionError` (carrying executable, args, cwd, exitCode, stdout, stderr) propagates unchanged from the spawn boundary; the executor logs probe start/success/failure and command start/success/failure through the injected `CommandOutput` sink, preserving the buffered no-terminal invariant on the MCP path (asserted by `test/mcp-server.discovery.test.ts`).

---

## Test Quality Audit

Automated evidence is strong: 120 new tests across resolvers, handlers, dispatch, service methods, argv composition, stdout parsing, runtime probing, MCP round-trips, and VS Code command paths, all against faked boundaries. Coverage evidence exists at both aggregate and per-file granularity and was independently regenerated by this reviewer at branch head. No end-to-end execution against the live Python CLI — an explicit spec non-goal, acceptable for this exposure layer.

### Reviewed test and QA artifacts

- `test/repo-automation-execute-discovery.test.ts` — exact `-c` argv per tool (incl. per-kind validate entries and the two-input completion report), `cwd === workspaceRoot`, artifact parsing per mode, `CommandExecutionError` propagation; spawn fully faked.
- `test/mcp-tool-inputs-discovery.test.ts` — per-resolver valid/missing/wrong-type/out-of-enum cases and the report_type-conditional required inputs; verifies rejection happens before any service call.
- `test/mcp-server.discovery.test.ts` — list/dispatch round-trips over `InMemoryTransport`, invalid-enum rejection, and the no-terminal invariant.
- `test/extension.discovery-commands.test.ts` — direct-args and interactive (including cancel) flows for all seven commands via the extension harness.
- `evidence/qa-gates/coverage-delta.2026-07-19T02-20.md` — baseline-vs-post-change and per-file numbers; matches this reviewer's independent lcov parse exactly.
- `evidence/qa-gates/file-size-audit.2026-07-19T02-10.md` — 500-line cap audit incl. the `mcp-server.test.ts` split rationale; spot-verified.
- `evidence/qa-gates/domain-neutrality.2026-07-19T02-10.md` — prohibited-identifier grep with SearchScope/SearchPatterns/SearchResult; re-run by reviewer over the new modules (zero matches).

### Quality assessment prompts

- **Determinism:** all external boundaries (spawn, VS Code API, PATH probing, service) are faked; no wall-clock, RNG, timers, or network in new tests.
- **Isolation:** one behavior per test; per-test fake construction; no shared mutable state.
- **Speed:** 8.7 s for 2006 tests in the reviewer run.
- **Diagnostics:** field-named resolver errors and full-array argv assertions produce actionable failure output.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no credentials, tokens, or `.env` content; only tool metadata, paths, and test fixtures. |
| No unsafe subprocess or command construction | ✅ PASS | Argv is passed as an array to `runCommandWithOutput` (no shell string interpolation); the `-c` code string interpolates only mapping-table constants (module/function names), never user input — user-supplied values travel exclusively as discrete argv elements. |
| Input validation at boundaries | ✅ PASS | Every MCP argument is normalized/validated in `mcp-tool-inputs-discovery.ts` before the service is called; enums duplicated in schema and resolver; `additionalProperties: false` on all seven input schemas. |
| Error handling remains explicit | ✅ PASS | Fail-fast resolver throws; structured `ok: false` + `stderr_excerpt` failure mapping; probe failure carries an explicit expected-locations message. |
| Configuration / path handling is safe | ✅ PASS | `workspace_root` defaults via existing `inferWorkspaceRoot`/`getWorkspaceRoot` helpers; `.venv` candidate path is normalized and existence-checked; no path concatenation from untrusted segments beyond the workspace root the user already controls. |

---

## Research Log

No external research was required. All conclusions derive from repository sources: the branch diff, feature-folder documents and evidence, repository policy rules, and independent toolchain execution. The jest-on-Windows dotted-path limitation was accepted from the executor's root-cause record (`evidence/baseline/baseline-test-coverage.2026-07-19T00-40.md`) and empirically confirmed by this reviewer (`node run-jest.cjs --listTests` → zero matches in the worktree; identical invocation in the non-dotted mirror discovers and passes 165 suites).

---

## Verdict

The change is ready for the normal PR flow. The implementation is a disciplined thin wrapper with compiler-enforced lockstep across the MCP touch-points, single-sourced contract data, fail-fast boundary validation, and thorough deterministic tests; the full toolchain passes in independent re-execution and coverage exceeds the uniform policy floors per file and in aggregate. The only actionable note is a Minor defense-in-depth suggestion (explicit throw instead of `?? ""` in `runDiscoveryReport`), which does not block merge because both exposed invocation surfaces validate the fields before the helper is reached. Recommendation: **Go**.
