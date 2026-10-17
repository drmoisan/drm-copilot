# Research: portable-handoff-614-review-follow-ups (Issue #645)

- Timestamp: 2026-09-29T23-40
- Branch: `feature/portable-handoff-614-review-follow-ups-645` (from `origin/main` 43c9e95e)
- Scope: R16, R17, R18, R19 only (2026-09-29 consolidation comment on #645).
- Excluded: R20 (`INDEPENDENT_CONTEXT` / TS2740 in `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts`). It is resolved by issue #647 and is not researched here. Consequence for this feature: no change in this feature may edit `orchestration-handoff-materializer-path-boundary.test.ts`. If it did, it would conflict with #647.

## Method and evidence limits

- Every file path and line number below was re-read in the current worktree tree with the Read and Grep tools during this session.
- This research session had Read, Grep, Glob, Write, and Edit tools. It had **no shell**. For that reason, no toolchain command (jest, pytest, Pester, prettier, eslint, tsc) was executed in this session.
- No coverage artifact exists in this worktree. `extensions/drm-copilot/coverage/*`, `artifacts/pester/*`, and `artifacts/python/*` all returned no files.
- All coverage figures below are therefore **previously recorded** values, cited with their source artifact. They are not fresh measurements. The planner must schedule fresh baselines as Phase 0 tasks.

---

## 1. Current State Analysis

### R16 — `Get-EpicPlanningRegisteredMcpTool` rejection paths

**Source.** The function is at `.codex/hooks/enforce-epic-planning-only.ps1` lines 49-83. The file has 365 lines. The four throws are at the cited lines:

| Line | Message (exact) | Trigger |
|---|---|---|
| 58 | `EPIC_PLANNING_ONLY_BLOCKED: semantic MCP registry '$RegistryPath' does not exist.` | `-RegistryPath` names no existing leaf (`Test-Path -PathType Leaf` is false). |
| 67 | `EPIC_PLANNING_ONLY_BLOCKED: semantic MCP id '$semanticId' is not registered.` | `semantic_tools` has no property named for the semantic id. |
| 72 | `EPIC_PLANNING_ONLY_BLOCKED: semantic MCP id '$semanticId' has an invalid operation.` | The entry's `operation` differs from the id suffix after the last `.`. For example, `drm-copilot.validate_orchestration_artifacts` requires `validate_orchestration_artifacts`. A missing `operation` also casts to `''` and throws. |
| 77 | `EPIC_PLANNING_ONLY_BLOCKED: semantic MCP id '$semanticId' has an invalid transport alias.` | An alias fails `^mcp__(?:drm-copilot\|drm_copilot)__<operation>$`. |

**Seam.** `-RegistryPath` is a mandatory `[string]` parameter of the function (line 53). It is also an optional parameter of `Invoke-EpicPlanningOnlyDecision` (line 210). That parameter defaults to `config/orchestration-handoff-registry.json` under the repository root. The loop iterates `-SemanticIds` in order and throws at the first failing id.

**Line 58 is unreachable through the decision function.** `Invoke-EpicPlanningOnlyDecision` checks registry existence at line 276 and returns a deny decision before it calls the loader (lines 279-281). A test for line 58 must therefore call `Get-EpicPlanningRegisteredMcpTool` directly. The existing suite dot-sources the hook, so the function is in scope.

**Existing test for line 67.**
- Location: `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1` lines 235-244, `It 'throws for a semantic tool when the registry fixture is invalid'`.
- Mechanism: it drives `Invoke-EpicPlanningOnlyDecision` with `-RegistryPath` set to `tests/fixtures/codex-hooks/invalid-orchestration-handoff-registry.json`. That fixture's content is `{"version": 1, "semantic_tools": {}}`.
- Assertion: `Should -Throw -ExpectedMessage '*is not registered*'`. This is a wildcard match, not an exact-message match.
- Attribution: the suite header cites issue #697. Attribution of that test to PR #699 was not verified in this session.
- File size: 261 lines.

**Fixture pattern in that suite (lines 13-24):**
- `$script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path`
- Fixtures are joined to the repo root with `Join-Path`.
- An intentionally absent sentinel path is used: `tests/fixtures/codex-hooks/absent-orchestration-handoff-registry.json`. A `BeforeAll` guard throws if that path exists.
- The hook is dot-sourced (`. $script:PlanningHookPath`).

**Existing fixtures in `tests/fixtures/codex-hooks/`:**
- `epic-planning-preparation-checkpoint.json`
- `invalid-orchestration-handoff-registry.json`

**Committed registry shape.** In `config/orchestration-handoff-registry.json`, `semantic_tools.<id>` has `operation` and `transport_aliases` (two aliases, hyphen and underscore server spellings) at lines 18-48.

**Fixture mirroring.** No test or manifest references `tests/fixtures/codex-hooks/` other than the two Pester suites. A Grep for `fixtures/codex-hooks` outside `docs/` matched only:
- `codex-planning-only-registry.Tests.ps1:15,17`
- `epic-execution-gates.Tests.ps1:11`

No `extensions/drm-copilot/resources/` mirror of test fixtures exists or is required.

**Hook mirror parity (unchanged by R16).** `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity` (line 285) compares normalized text for these files:
- `.codex/hooks/enforce-epic-planning-only.ps1` (`HANDOFF_RUNTIME_PATHS`, lines 34-40), compared with `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-planning-only.ps1`
- `config/orchestration-handoff-registry.json` and `config/orchestration-handoff.schema.json`, compared with `extensions/drm-copilot/resources/config/`

R16 edits neither file.

**Coverage configuration.**
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 157 lists `.codex/hooks/enforce-epic-planning-only.ps1` in `CodeCoverage.Path`. This is an explicit allow-list.
- Output: `artifacts/pester/powershell-coverage.xml` in CoverageGutters format. Test discovery roots are `scripts`, `tests/powershell`, and `tests/scripts` (line 3).
- The bundled copy `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` also contains the hook path. It was matched by Grep; its line number was not recorded.
- No runsettings edit is needed.

**Test-purity hook.** `.claude/hooks/check-powershell-test-purity.ps1` lines 105-108 deny these in Pester tests:
- `New-TemporaryFile`
- `[System.IO.Path]::GetTempPath`
- `$env:TEMP`

The committed-fixture approach does not trigger it.

**Last recorded PowerShell coverage.** 7447/7858 = 94.7697% line (`docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/powershell-pester-coverage.2026-09-07T03-16.md`). The issue's 94.77% floor matches this value. It was not re-measured in this session.

### R17 — jest `coverageThreshold`

**Current map.** `extensions/drm-copilot/jest.config.cjs` is 325 lines.
- `coverageThreshold` spans lines 25-324.
- Key format: `"./src/<repo-relative-under-extension>.ts": { lines: 85, branches: 75 }`, keyed relative to `extensions/drm-copilot/`.
- There is no `global` key.
- Each group is preceded by a `// Issue #NNN: ...` comment. The comment at lines 20-24 documents the no-`global` rule.
- `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` (line 17).
- `coverageProvider: "v8"` (line 10).

**No entry matches `orchestration-handoff` or `semantic-mcp`.** This was verified by reading the full file.

**Run command.** `test:coverage` is `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` (`package.json` line 212). `run-jest.cjs` spawns jest with `--config jest.config.cjs`, relative to the working directory, and rejects `--passWithNoTests`, `--onlyChanged`, and `--lastCommit`. `npm --prefix extensions/drm-copilot run test:coverage` runs the script with the extension folder as its working directory.

**Module set and last recorded per-file coverage.** Source: `docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T02-00.md` lines 363-376. Each module's recorded line denominator equals its current line count (counted with Grep `^` in this session). That indicates the files are unchanged in size since that measurement, but it is not a fresh measurement.

| # | Threshold key | Current lines | Recorded line % | Recorded branch % |
|---|---|---|---|---|
| 1 | `./src/lib/validate/orchestration-handoff-authority-service.ts` | 377 | 98.41 (371/377) | 88.41 (61/69) |
| 2 | `./src/lib/validate/orchestration-handoff-checkout-context.ts` | 212 | 100.00 | 100.00 (39/39) |
| 3 | `./src/lib/validate/orchestration-handoff-contract-support.ts` | 323 | 100.00 | 100.00 (46/46) |
| 4 | `./src/lib/validate/orchestration-handoff-contract.ts` | 497 | 98.79 (491/497) | 90.79 (69/76) |
| 5 | `./src/lib/validate/orchestration-handoff-materializer-production.ts` | 136 | 100.00 | 97.30 (36/37) |
| 6 | `./src/lib/validate/orchestration-handoff-materializer-request.ts` | 84 | 100.00 | 100.00 (11/11) |
| 7 | `./src/lib/validate/orchestration-handoff-materializer-support.ts` | 77 | 100.00 | 90.00 (18/20) |
| 8 | `./src/lib/validate/orchestration-handoff-materializer.ts` | 444 | 98.42 (437/444) | 94.87 (74/78) |
| 9 | `./src/lib/validate/orchestration-handoff-path-boundary.ts` | 205 | 97.56 (200/205) | 81.13 (43/53) |
| 10 | `./src/lib/validate/orchestration-handoff-provider-adapters.ts` | 273 | 99.27 (271/273) | 95.65 (22/23) |
| 11 | `./src/lib/validate/orchestration-handoff-validation.ts` | 248 | 99.19 (246/248) | 92.59 (25/27) |
| 12 | `./src/lib/validate/semantic-mcp-identity.ts` | 54 | 100.00 | 100.00 (11/11) |
| 13 | `./src/mcp-handlers/orchestration-handoff-handlers.ts` | 304 | 100.00 | 100.00 (64/64) |
| 14 | `./src/mcp-repo-automation-tool-definitions-handoff.ts` | 220 | 100.00 | no branch construct |

- No module was recorded below 85% lines or 75% branches.
- The lowest recorded branch figure is `orchestration-handoff-path-boundary.ts` at 81.13%. That leaves 6.13 points of headroom. R18 edits this file, so its branch figure must be re-measured after R18.
- Last recorded TypeScript totals: 96.82% line and 90.37% branch (`fr-614-005-coverage-comparison.2026-09-03T00-07.md` line 24).

### R18 — bare `catch {}` sites

**Files and line counts** (the 500-line limit applies):

| File | Lines |
|---|---|
| `src/lib/validate/orchestration-handoff-materializer.ts` | 444 |
| `src/lib/validate/orchestration-handoff-authority-service.ts` | 377 |
| `src/lib/validate/orchestration-handoff-path-boundary.ts` | 205 |
| `src/lib/validate/orchestration-handoff-materializer-production.ts` | 136 |
| `test/lib/validate/orchestration-handoff-materializer.test.ts` | 492 |
| `test/lib/validate/orchestration-handoff-authority-service.test.ts` | 495 |
| `test/lib/validate/orchestration-handoff-path-boundary.test.ts` | 224 |
| `test/lib/validate/orchestration-handoff-materializer-production.test.ts` | 423 |
| `test/lib/validate/orchestration-handoff-materializer-test-support.ts` | 323 |
| `test/mcp-handlers/orchestration-handoff-handlers.test.ts` | 304 |
| `src/lib/validate/orchestration-handoff-materializer-request.ts` | 84 |
| `src/mcp-handlers/orchestration-handoff-handlers.ts` | 304 |
| `src/mcp-tools.ts` | 360 |
| `src/mcp-repo-automation-tool-definitions-handoff.ts` | 220 |
| `src/repo-automation-service.ts` | 498 (not touched by the recommendation) |

**Per-site behavior.** All sites are under `extensions/drm-copilot/src/lib/validate/`.

| # | File:line | Guarded operation | Result today | Code |
|---|---|---|---|---|
| 1 | materializer.ts:162 | `readFile` of source checkpoint and envelope | `blockedResult(request, code)` | `HANDOFF_VALIDATOR_UNAVAILABLE` |
| 2 | materializer.ts:175 | `TextDecoder(fatal).decode(envelopeBytes)` | `blockedResult` | `HANDOFF_UNSUPPORTED_VERSION` |
| 3 | materializer.ts:298 | `git.readPorcelainStatus` | `blockedResult` + handoffId/historySha | `HANDOFF_VALIDATOR_UNAVAILABLE` |
| 4 | materializer.ts:351 | archive `createDirectory` + exclusive `writeFile` | Recovery path. Reads the existing archive. Codes arise at 358/365. | (see #5, and `HANDOFF_SOURCE_HASH_MISMATCH` at 365) |
| 5 | materializer.ts:357 | archive readback | `blockedResult` + `affectedPaths:[archivePath]` | `HANDOFF_VALIDATOR_UNAVAILABLE` |
| 6 | materializer.ts:379 | candidate exclusive `writeFile` | Recovery path. Reads the existing candidate. Codes arise at 386/393. | `HANDOFF_VALIDATOR_UNAVAILABLE` |
| 7 | materializer.ts:385 | candidate readback | `blockedResult` + `[candidatePath]` | `HANDOFF_VALIDATOR_UNAVAILABLE` |
| 8 | materializer.ts:413 | candidate re-read, decode, hash, validate. Includes the synthetic `throw new Error("Candidate validation failed.")` at 411. | `discardCandidate` + `blockedResult` | `HANDOFF_VALIDATOR_UNAVAILABLE` |
| 9 | materializer.ts:426 | `replaceFile` | `discardCandidate` + `blockedResult` | `HANDOFF_VALIDATOR_UNAVAILABLE` |
| 10 | materializer.ts:440 | `removeFile` in `discardCandidate` | Swallowed. Best-effort cleanup; no code. | none |
| 11 | authority-service.ts:133 | `readTextFile(envelopePath)` | `blocked(request, code)` (`PortableHandoffAuthorityResult`) | `HANDOFF_VALIDATOR_UNAVAILABLE` |
| 12 | authority-service.ts:168 | `readTextFile(planPath)` in private `observedPlanSha256` | Returns `null`. The caller at 327-330 maps it to a code. | `HANDOFF_PLAN_PATH_INVALID` |
| 13 | materializer-production.ts:49 | `JSON.parse` in `validateDestinationProjection` | Returns `["destination checkpoint must be valid JSON"]`. Only `.length` is consumed (materializer.ts 286, 408; test asserts `toHaveLength(1)` at production.test.ts:200). | `HANDOFF_VALIDATOR_UNAVAILABLE` (at the caller) |
| 14 | path-boundary.ts:118 | `realpath` + `stat` in `resolveWorkspaceRoot` | Returns `null` through the public `HandoffPathBoundary` interface. | `HANDOFF_PLAN_PATH_INVALID` (at materializer.ts:143, authority-service.ts:276) |
| 15 | path-boundary.ts:140 | `realpath` in `resolveExistingTarget` | Returns `null` through the public interface. | `HANDOFF_PLAN_PATH_INVALID` (at materializer.ts:154, authority-service.ts:128/165) |

**Existing bound-catch precedents:**
- materializer.ts:272-283 binds `catch (error: unknown)` and selects `error.code` when `error instanceof Error && "code" in error`.
- authority-service.ts:141 binds the error to select a `HandoffContractError.code`.
- path-boundary.ts:180-181 binds the error and uses the `missingPath(error)` predicate (`error.code === "ENOENT"`, lines 74-81).
- materializer-production.ts:32 binds the error.

**The `blockedResult` details channel.** `orchestration-handoff-materializer-request.ts` lines 43-66 define it. The options bag holds `handoffId`, `handoffHistorySha256`, `affectedPaths`, and `unsupportedCapabilities`. It returns `TransitionPreparedOrchestrationResult`.
- `TransitionPreparedOrchestrationResult` is defined at `src/mcp-repo-automation-tool-definitions-handoff.ts` lines 58-70.
- `PortableHandoffAuthorityResult` is defined at lines 48-56. It is built by the local `blocked` in authority-service.ts lines 97-115.
- `authorityFailure` (materializer-request.ts lines 68-84) copies authority fields into the transition result field by field.
- The MCP handler maps results explicitly, field by field: `toAuthorityMcpResult` lines 231-249 and `toTransitionMcpResult` lines 251-272 in `src/mcp-handlers/orchestration-handoff-handlers.ts`. The output type is `PortableHandoffMcpToolResult` in `src/mcp-tools.ts` lines 77-88, where all handoff fields are optional.

**Schema impact.** The only JSON schemas on this surface are MCP `inputSchema`s with `additionalProperties: false` (definitions-handoff.ts lines 172, 183, 217). There is no output schema. `config/orchestration-handoff.schema.json` is the envelope schema (`$id` `.../orchestration-handoff/2.0.0/schema.json`) and contains no result fields. An optional result field changes no schema or golden fixture.

**Parity and precedence tests.** Verified by content:
- Python `test_failure_precedence_matches_the_shared_registry` (`tests/scripts/dev_tools/test_orchestration_handoff_contract.py` lines 105-108) asserts `FAILURE_PRECEDENCE == REGISTRY_FAILURE_PRECEDENCE`, which is a tuple of codes.
- TS `orchestration-handoff-contract.test.ts` lines 258-268 assert `HANDOFF_FAILURE_PRECEDENCE` equals the registry `failure_precedence` and has length 16.
- `orchestration-handoff-authority-service.test.ts:461` tests registry-order selection.
- `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py` `NEGATIVE_SCENARIOS` (lines 43-62) compares codes only.
- `test_codex_handoff_contract_parity.py` compares skill/agent document text, not result objects.

**Full-object comparisons on handoff results.**
- No handoff test compares a *blocked* result object with `toEqual` or `toStrictEqual`. A Grep of `(toEqual|toStrictEqual)\(\{` across handoff test files matched only projection, observation, and identity objects.
- `materializer.test.ts:30` compares two *validated* results with `toEqual`.
- `mcp-server.test.ts:450` and `orchestration-handoff-handlers.test.ts:216-231` use `toMatchObject`.
- `repo-automation-orchestration-validation.test.ts:411-425` builds a mocked result literal. Its type remains valid if the new field is optional.

**Redaction facts:**
- Node filesystem errors carry absolute paths in `message`.
- The test fakes also embed paths in messages: `materializer-test-support.ts` lines 197, 201, 217, 220, 229, and `authority-service.test.ts:135`.
- `JSON.parse` `SyntaxError.message` quotes input text.
- `affectedPaths` already exposes the absolute canonical `archivePath` and `candidatePath` at materializer.ts 361, 368, 389, 396, 418, 431, because `resolveCreatableTarget` returns absolute paths (path-boundary.ts 169-178).
- A cause string built only from `error.code` (when it is a string matching `^[A-Z][A-Z0-9_]*$`, e.g. `ENOENT`, `EACCES`, `EEXIST`, `ERR_ENCODING_INVALID_ENCODED_DATA`) or `error.name` never exposes a path or an environment value.

**Lint.** `eslint.config.mjs` applies `tseslint.configs.recommended` (typescript-eslint ^8.70.1). Its `@typescript-eslint/no-unused-vars` defaults to `caughtErrors: "all"`, so a bound but unused `error` fails lint. Each rewritten site must therefore *use* the bound value. This default was not executed in this session; it is inferred from the typescript-eslint v8 documented default.

### R19 — `raw_file_sha256`

- Definition: `scripts/dev_tools/orchestration_handoff_contract_support.py` line 61, `def raw_file_sha256(path: Path) -> str: return raw_sha256(path.read_bytes())`. The file has 152 lines.
- Re-export: `scripts/dev_tools/orchestration_handoff_contract.py` lines 19-21. The file has 498 lines.
- A Grep outside `docs/` finds exactly these two occurrences and no caller.
- Inline recomputation: `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py` (440 lines).
  - Lines 76-77 are `hashlib.sha256(source_bytes).hexdigest()` and `hashlib.sha256(plan_bytes).hexdigest()` inside `test_taskmaster_469_fixture_hashes_and_source_history_are_pinned` (lines 65-78).
  - `hashlib` (line 5) is used only at lines 76-77 of that file.
  - `source_bytes` is still needed at line 78.
- The bytes come from `fixture_bytes` (`tests/scripts/dev_tools/orchestration_handoff_taskmaster_469_test_support.py` lines 110-118, file 312 lines). It resolves `case.root / _text(source["file"], ...)` and `case.root / _text(plan["file"], ...)`, then calls `.read_bytes()`.
- No bundled mirror of any `orchestration_handoff*.py` file exists under `extensions/drm-copilot/resources/` (Glob returned no files).
- Last recorded Python coverage:
  - `python-pytest-coverage.2026-09-07T03-16.md`: `TOTAL 15772 1121 5740 578 91%`, with 4390 passed and 5 skipped.
  - The issue's floors of 92.89% line and 85.51% branch come from the later review cycle. They were not re-derived in this session.

---

## 2. Candidate Approaches and Recommendations

### R16 — recommended: direct loader calls with committed fixtures

Add one new `Describe` block to `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1`. The file grows from 261 lines to about 320, which is under 500. The block reuses the existing `BeforeAll` dot-source and `$script:RepoRoot`. Each case calls `Get-EpicPlanningRegisteredMcpTool -RegistryPath <path> -SemanticIds @('drm-copilot.validate_orchestration_artifacts')`. Each case captures the exception and asserts `$_.Exception.Message | Should -BeExactly '<exact message>'`, with the path or id interpolated.

`-BeExactly` on the captured message is preferred over `-ExpectedMessage`. `-ExpectedMessage` uses `-like` wildcard semantics, and a path containing `[` or `]` would be misread.

| Throw | Registry input | Fixture |
|---|---|---|
| 58 | Existing absent sentinel `tests/fixtures/codex-hooks/absent-orchestration-handoff-registry.json` | none (reuse) |
| 67 | Existing `tests/fixtures/codex-hooks/invalid-orchestration-handoff-registry.json` | none (reuse). Adds an exact-message assertion; the existing wildcard test stays unchanged. |
| 72 | `{"version":1,"semantic_tools":{"drm-copilot.validate_orchestration_artifacts":{"operation":"resolve_provider_routing","transport_aliases":["mcp__drm-copilot__validate_orchestration_artifacts"]}}}` | **new** `tests/fixtures/codex-hooks/invalid-operation-orchestration-handoff-registry.json` |
| 77 | `{"version":1,"semantic_tools":{"drm-copilot.validate_orchestration_artifacts":{"operation":"validate_orchestration_artifacts","transport_aliases":["mcp__other-server__validate_orchestration_artifacts"]}}}` | **new** `tests/fixtures/codex-hooks/invalid-alias-orchestration-handoff-registry.json` |

Rejected alternative: driving every case through `Invoke-EpicPlanningOnlyDecision`. It cannot reach line 58, because of the pre-check at line 276, and it tests the loader less directly. The planner may add decision-level cases for 72 and 77 as secondary evidence, but they are not required.

### R17 — recommended: 14 entries under an issue comment

Append a `// Issue #645: ...` comment and the 14 keys from the table in section 1, each `{ lines: 85, branches: 75 }`, before the closing `}` of `coverageThreshold` (current line 324).
- No `global` key.
- No `coveragePathIgnorePatterns`.
- The trailing comment block for `./src/lib/pr-context/index.ts` (lines 319-323) stays in place; the new entries can go after it.

If R18 adds a new production module, it needs a 15th entry. The R18 recommendation below avoids a new module to keep the count at 14.

### R18 — recommended: optional `failureCause` field, pure helper in `materializer-request.ts`

1. **Pure helper.** Add `describeHandoffFailureCause(stage: string, error: unknown): string` to `orchestration-handoff-materializer-request.ts` (84 lines, the existing home of `blockedResult`). It returns `` `${stage}: ${token}` ``, where `token` is:
   - `error.code` when that is a string matching `^[A-Z][A-Z0-9_]*$`;
   - otherwise `error.name` when `error instanceof Error`;
   - otherwise `"non-error value"`.

   It never reads `message` or `stack`. `authority-service.ts` imports it. There is no cycle: `materializer-request.ts` imports types only.
2. **Result types (additive, optional).**
   - Add `readonly failureCause?: string` to `TransitionPreparedOrchestrationResult` and `PortableHandoffAuthorityResult`.
   - Add `failureCause?: string` to the `blockedResult` and `blocked` option bags. Set it only when provided, so existing results are unchanged.
   - `authorityFailure` forwards `authority.failureCause`.
3. **MCP output.**
   - Add `readonly failure_cause?: string` to `PortableHandoffMcpToolResult` (`mcp-tools.ts`).
   - Map it in `toAuthorityMcpResult` and `toTransitionMcpResult` with a conditional spread (`...(result.failureCause === undefined ? {} : { failure_cause: result.failureCause })`), so existing `toMatchObject` and `toEqual` expectations are unaffected.
4. **Sites.**
   - #1, 2, 3, 5, 7, 9, 11: bind `catch (error: unknown)` and pass `failureCause: describeHandoffFailureCause("<stage>", error)`. Suggested stage labels: `checkpoint-read`, `envelope-decode`, `git-status`, `archive-readback`, `candidate-readback`, `candidate-replace`, `envelope-read`.
   - #4, 6: bind the outer write error. If the recovery path then blocks (358/365 or 386/393), include the outer cause, for example `archive-write: EEXIST; archive-readback: EACCES`. If recovery succeeds (the idempotent retry case), the cause is not emitted. Behavior is unchanged.
   - #8: bind the error. Give the synthetic throw at line 411 a recognizable `code` (for example `Object.assign(new Error("Candidate validation failed."), { code: "HANDOFF_CANDIDATE_MISMATCH" })`), so a mismatch is distinguishable from an I/O error. This is an internal marker and not a `HandoffFailureCode`.
   - #10: `discardCandidate` returns `string | null`, the cleanup cause. Callers at 414 and 427 append it (`; candidate-cleanup: EPERM`). This makes the retained-candidate case diagnosable.
   - #12: private `observedPlanSha256` returns `{ sha256 } | { failureCause }` or equivalent. The caller at 327-330 passes the cause to `blocked(... "HANDOFF_PLAN_PATH_INVALID", { handoffId, failureCause })`. There is no public API change.
   - #13: bind the error and return `` [`destination checkpoint must be valid JSON (${describe...})`] ``. The array length is still 1, so every current consumer and assertion is unaffected.
   - #14, 15 (public `HandoffPathBoundary`, `string | null` contract): route the realpath and stat calls through a module-private helper that binds `error: unknown` and returns `{ ok: true; value } | { ok: false; cause }`. The public resolvers map a failure to `null`, which is unchanged. This removes the bare catch and satisfies lint, with no interface change. The calling sites (materializer.ts 143/154, authority-service.ts 128/165/276) then attach a stage-level cause (for example `workspace-root: unresolved`) to their existing `HANDOFF_PLAN_PATH_INVALID` results.
     - Surfacing the path-boundary errno itself requires a public interface change: a union return, or an optional additive method on `HandoffPathBoundary`. That change touches three implementations (path-boundary.ts, materializer-support.ts `createSyntacticHandoffPathBoundary`, authority-service.ts `createDefaultPathBoundary`) plus the test fakes. It is recorded as an open decision (section 7) and is not in the recommendation.
5. **Codes and precedence.** Unchanged at every site. `HANDOFF_*` selection logic is not touched.

**File-size projection.** These are estimates and not measured.
- materializer.ts: 444 → about 475. This is near the limit. The planner should require a post-edit line count. If it exceeds 490, move `stageMaterialization`'s archive and candidate recovery blocks into `materializer-support.ts` (77 lines).
- authority-service.ts: 377 → about 395.
- path-boundary.ts: 205 → about 220.
- materializer-request.ts: 84 → about 110.
- handlers.ts: 304 → about 308.
- mcp-tools.ts: 360 → about 361.
- definitions-handoff.ts: 220 → about 222.

**Tests.**
- New sibling test file `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts`. This is required because `materializer.test.ts` (492) and `authority-service.test.ts` (495) have no headroom. It covers:
  - the helper: code, name, and non-error branches; and the redaction property that the output contains no `/`, `\`, or `:` path fragment from a message containing an absolute path;
  - per-site causes via `createScenario` options from `materializer-test-support.ts`;
  - authority `envelopeReadFailure` and `planReadFailure`.
- One case in `orchestration-handoff-handlers.test.ts` (304 → about 335) for `failure_cause` mapping, present and absent.
- If path-boundary branches are added, one case in `orchestration-handoff-path-boundary.test.ts` (224).
- None may edit `orchestration-handoff-materializer-path-boundary.test.ts`, which is #647's file.

Rejected alternatives:
- (a) Log the cause instead of returning it. The handoff modules have no logger seam, and a log does not reach the MCP caller.
- (b) Put the cause in `unsupportedCapabilities` or `affectedPaths`. That overloads fields with fixed semantics that tests pin.
- (c) Change `HandoffPathBoundary` to a union return. This is invasive, as described above.

### R19 — recommended: use `raw_file_sha256` in the test (no production edit)

In `test_taskmaster_469_fixture_hashes_and_source_history_are_pinned`:
- Replace lines 76-77 with `raw_file_sha256(<source path>) == source["sha256"]` and `raw_file_sha256(<plan path>) == plan["sha256"]`, imported from `scripts.dev_tools.orchestration_handoff_contract`, the public re-export.
- Keep `fixture_bytes` for line 78.
- Remove the then-unused `import hashlib` (line 5).

To obtain the paths without the private `_text`, add a public `fixture_paths(case, fixture) -> tuple[Path, Path]` to the test support module and have `fixture_bytes` call it. The support module grows from 312 lines to about 322.

`orchestration_handoff_contract.py` (498) and `_support.py` (152) are **unchanged**, so the 498-line file needs no extraction.

Rejected alternative: removing the definition and re-export. That deletes public API; the issue prefers use, and use costs no production lines.

---

## 3. Behavior Semantics

- R16:
  - Success condition: each throw executes under test and the exact message matches.
  - Failure condition: any hook byte change. The parity test at `test_push_down_codex_and_agents_customizations.py:285` enforces this.
- R17: `test:coverage` exits 0 with all 14 files at or above 85% lines and 75% branches. Any file below the floor fails the run.
- R18:
  - For every input, `status`, `primaryFailureCode`, `affectedPaths`, `unsupportedCapabilities`, `handoffId`, and `handoffHistorySha256` are identical to today.
  - Validated and materialized results carry no `failureCause`.
  - Blocked results produced after a caught exception carry a `failureCause` whose token is only a code or a name.
  - Precedence (16 entries) is unchanged.
- R19: `raw_file_sha256` has at least one non-defining call site, and the pinned fixture hashes still match.

## 4. Requirements Mapping — proposed file set

Recommended write set, repo-relative:

- `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1` (modify: new `Describe`, 4 cases)
- `tests/fixtures/codex-hooks/invalid-operation-orchestration-handoff-registry.json` (new)
- `tests/fixtures/codex-hooks/invalid-alias-orchestration-handoff-registry.json` (new)
- `extensions/drm-copilot/jest.config.cjs` (modify: 14 entries)
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts` (modify: helper, `failureCause` option, forwarding)
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` (modify: sites 1-10)
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts` (modify: sites 11-12, stage causes on path-null returns)
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-production.ts` (modify: site 13)
- `extensions/drm-copilot/src/lib/validate/orchestration-handoff-path-boundary.ts` (modify: sites 14-15)
- `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-handoff.ts` (modify: optional result fields)
- `extensions/drm-copilot/src/mcp-handlers/orchestration-handoff-handlers.ts` (modify: conditional `failure_cause` mapping)
- `extensions/drm-copilot/src/mcp-tools.ts` (modify: optional `failure_cause`)
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts` (new)
- `extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts` (modify: mapping case)
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-path-boundary.test.ts` (modify only if new branches need coverage)
- `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py` (modify)
- `tests/scripts/dev_tools/orchestration_handoff_taskmaster_469_test_support.py` (modify: `fixture_paths`)

**Bundled mirrors touched: none.**
- The only mirrored files on this surface are `.codex/hooks/enforce-epic-planning-only.ps1`, `config/orchestration-handoff-registry.json`, and `config/orchestration-handoff.schema.json`, and none is edited.
- The MCP server bundle is produced by `npm run bundle:mcp-server` at build time from `src/`. It is not a committed mirror checked by a parity test in this set.
- `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts` references the Codex resources. Its assertions were not read in this session, and the planner should run it in the loop.

## Numeric Derivation Evidence

### N1 — "14 production modules require a `coverageThreshold` entry" (R17)

- **Complete Family:** production `.ts` files under `extensions/drm-copilot/src/` that belong to the portable handoff surface added by #614: `orchestration-handoff-*`, `semantic-mcp-identity`, the handoff handler, and the handoff tool definitions.
- **Exhaustive Search Scope:** all of `extensions/drm-copilot/src/**` (every subdirectory).
- **Inclusion Rules:** the file name contains `handoff` or `semantic-mcp-identity`, and the extension is `.ts`.
- **Exclusion Rules:** `.d.ts` files (none found); test files (these live under `test/`, outside the scope).
- **Primary Search Strategy:** Glob `extensions/drm-copilot/src/**/*{handoff,semantic-mcp-identity}*`.
- **Primary Member Set:** `lib/validate/orchestration-handoff-{authority-service,checkout-context,contract-support,contract,materializer-production,materializer-request,materializer-support,materializer,path-boundary,provider-adapters,validation}.ts`, `lib/validate/semantic-mcp-identity.ts`, `mcp-handlers/orchestration-handoff-handlers.ts`, `mcp-repo-automation-tool-definitions-handoff.ts`.
- **Primary Count:** 14.
- **Cross-check Search Strategy:** an independent historical enumeration, the table "Added TypeScript production modules" in `docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T02-00.md` lines 363-376. It was corroborated by directory listings of `src/lib/validate/*.ts`, `src/mcp-handlers/*.ts`, and `src/*.ts`, filtered by eye for handoff and semantic-mcp names.
- **Cross-check Member Set:** the same 14 paths as the audit rows at lines 363-376. The directory listings show no additional handoff or semantic-mcp file.
- **Cross-check Count:** 14.
- **Member-set Comparison:** the normalized sets are identical (14 = 14, same members). **Assertion permitted.**

### N2 — "15 bare `catch {}` sites in the four modules" (R18)

- **Complete Family:** `catch` clauses without a bound parameter in `extensions/drm-copilot/src/lib/validate/orchestration-handoff-{materializer,authority-service,path-boundary,materializer-production}.ts`.
- **Exhaustive Search Scope:** all `orchestration-handoff-*.ts` in `src/lib/validate/`, plus every handoff or semantic-mcp `.ts` file under `src/`.
- **Inclusion Rules:** a `catch` immediately followed by `{`.
- **Exclusion Rules:** `catch (error: unknown)` and any other bound form.
- **Primary Search Strategy:** Grep `catch\b` over `src/lib/validate/orchestration-handoff-*.ts`, then manual removal of the bound forms (materializer-production 32, authority 141, contract 475 and 492, materializer 272, path-boundary 180).
- **Primary Member Set:** materializer 162, 175, 298, 351, 357, 379, 385, 413, 426, 440; authority-service 133, 168; materializer-production 49; path-boundary 118, 140.
- **Primary Count:** 15.
- **Cross-check Search Strategy:** Grep `catch\s*\{` over `src/**/*{handoff,semantic-mcp}*.ts`. This is a different regex and a wider scope.
- **Cross-check Member Set:** identical list, with no hit in any other handoff file.
- **Cross-check Count:** 15.
- **Member-set Comparison:** identical. **Assertion permitted.**

### N3 — "2 new fixture files" (R16)

- **Complete Family:** registry inputs needed to trigger throws 58, 67, 72, and 77.
- **Exhaustive Search Scope:** `tests/fixtures/codex-hooks/**` and every reference to it in `tests/`.
- **Inclusion Rules:** a committed JSON file needed by a new case and not already present.
- **Exclusion Rules:** paths that already exist (`invalid-orchestration-handoff-registry.json`) and deliberately absent sentinels (`absent-orchestration-handoff-registry.json`).
- **Primary Search Strategy:** Glob `tests/fixtures/codex-hooks/**`, which found 2 existing files; then map each throw to an input (section 2 table).
- **Primary Member Set:** `invalid-operation-orchestration-handoff-registry.json`, `invalid-alias-orchestration-handoff-registry.json`.
- **Primary Count:** 2.
- **Cross-check Search Strategy:** Grep `fixtures/codex-hooks|invalid-orchestration-handoff-registry` across the repo excluding `docs/`, confirming which inputs existing tests already reference; then re-derive per throw from the hook source lines 57-78.
- **Cross-check Member Set:** 58 → sentinel (exists by reference); 67 → existing fixture; 72 → new; 77 → new.
- **Cross-check Count:** 2.
- **Member-set Comparison:** identical. **Assertion permitted.**

## 5. Testing Implications and Baseline Toolchain Commands

Each command below is as recorded in prior repository evidence. None was executed in this session.

- **Python** (from the repo root):
  - `poetry run black --check .`
  - `poetry run ruff check .`
  - `poetry run pyright`
  - `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
  - The pytest `addopts` also write `artifacts/python/lcov.info`.
  - Focused: `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py tests/scripts/dev_tools/test_orchestration_handoff_contract.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`
- **TypeScript** (from `extensions/drm-copilot/`):
  - `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (the `format` script uses `--write`)
  - `npm run lint`
  - `npm run typecheck` (`tsc -p ./ --noEmit`)
  - `npx tsc -p tsconfig.jest.json --noEmit` (test tree; the R20 TS2740 remains until #647 lands and must be treated as a pre-existing diagnostic)
  - `npm run test:coverage`
- **PowerShell:**
  - Run MCP `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root.
  - Then read `artifacts/pester/pester-junit.xml` (`<testsuites ... failures= errors=>`) and `artifacts/pester/powershell-coverage.xml` (report-level `<counter type="LINE" ...>`), because the MCP result carries no counts.
  - Format and lint: `mcp__drm-copilot__run_poshqc_format` / `run_poshqc_analyze` (tool names as used in prior evidence), or the equivalent PoshQC module functions. Format rewrites files; prior evidence substituted a recorder seam when a no-write run was required.
- **Test additions:**
  - 4 Pester `It` blocks.
  - 1 new jest file, plus 1 or 2 cases in existing suites.
  - The R19 edit to an existing pytest test.
  - Property test: the helper `describeHandoffFailureCause` is a pure function in a module that `quality-tiers.yml` may classify as T1/T2. If so, one `fast-check` property is required, for example "output never contains any substring of `error.message` longer than N characters". The planner should check the tier entry for `extensions/drm-copilot`.

## 6. Automation Feasibility

No human interaction is expected. Every step can run unattended:
- file edits;
- committed fixtures;
- the Python, TypeScript, and PowerShell toolchains through `poetry`, `npm`/`npx`, and the drm-copilot PoshQC MCP tools.

No credentials, UI, or external service beyond the local toolchains are required.

## 7. Open Risks

1. **Stale baselines.** No coverage figure was measured in this session. Phase 0 must capture fresh:
   - TS per-file lcov for the 14 modules;
   - repository Python line and branch;
   - PowerShell line coverage and the enforce-epic-planning-only per-file missed-line set.

   The issue's "nine pre-existing missed lines" claim is unverified.
2. **`materializer.ts` headroom.** The file is at 444 lines, and the projection is about 475 after R18. It must be re-counted after the edit, with an extraction fallback into `materializer-support.ts`.
3. **Path-boundary errno not surfaced.** The recommended approach removes the bare catches at 118 and 140 but surfaces only a stage-level cause at the callers. Surfacing the errno requires a public `HandoffPathBoundary` change. The spec must decide whether the AC "each site returns a cause alongside its code" applies to the four sentinel-returning sites (12, 13, 14, 15). None of them returns a code itself.
4. **Branch-coverage dilution.** New ternaries in the helper and at path-boundary sites add branches. `path-boundary.ts` had the lowest recorded branch figure (81.13%).
5. **MCP output additive field.** `failure_cause` is new, optional output on three MCP tools. No output schema or doc lists these fields: Grep for `unsupported_capabilities` outside feature docs matched only `mcp-tools.ts` and the handler. Downstream consumers that validate output strictly were not found. `mcp-server-prepack.test.ts` was not read in this session.
6. **#647 overlap.** #647 edits `orchestration-handoff-materializer-path-boundary.test.ts`, which R18 must not touch. If #647 merges first and changes `materializer-test-support.ts`, the new R18 test file may need a rebase adjustment.
7. **Lint default inference.** The `caughtErrors: "all"` behavior of `@typescript-eslint/no-unused-vars` was inferred from the typescript-eslint v8 default and not executed.
