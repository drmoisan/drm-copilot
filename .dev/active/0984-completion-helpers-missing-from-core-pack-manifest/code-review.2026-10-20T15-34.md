# Code Review: Completion helpers missing from the Claude core pack manifest (#984)

---

**Review Date:** 2026-10-20
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches issue #984 in the branch name.
**Base Branch:** `main` (merge base `58e5001c5907d74ee24f205690d891b4352fda23`)
**Head Branch:** `bug/completion-helpers-missing-from-core-pack-manifest-984` (`a114539915767e4d9f04fe1c8df3b1debb8b11df`)
**Review Type:** Initial review

---

## Executive Summary

The branch closes a packaging gap and a scope defect that together blocked every Write/Edit call in repositories that received the Claude core pack at 1.1.19 to 1.1.21. The packaging fix adds seven paths to the Claude `core.json` (the completion helper, the pr-author agent and its output validator, and four language hooks that core `settings.json` registers) and one path to the Codex `core.json`. The scope fix converts six hooks to the established H1 named-handler pattern so that a failed evaluation-only dependency denies only in-scope paths. The guard that preserved the gap (grandfathered exception sets in the Python and TypeScript completeness tests) is emptied, and a new dependency-closure test prevents recurrence.

The production delta is small (two lines per hook, 16 manifest lines) and follows existing patterns. The test delta is larger and well-structured: four Pester suites cover both repository and bundle roots, and the Python closure test is backed by in-memory self-tests for every recognized `$PSScriptRoot` form plus an exhaustiveness guard. All toolchain stages pass; mirror parity holds; `hook-dependency-guard.ps1` and the Codex `enforce-completion-consistency.ps1` are unchanged.

**What changed:**
Claude and Codex `core.json` additions; `$script:<Name>ImportFailure` handler variables and single-line in-scope denies in `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-discovery-artifact-gate.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1` and their bundle copies; handler rows H9 to H12 with a per-row leaf column in `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`; new Python scanner, self-tests, and closure test; four new Pester suites; emptied exception sets; CHANGELOG `### Fixed`.

**Top 3 risks:**
1. The closure test's command-text check recognizes only `.ps1` hook names (`_HOOK_PATH`). A non-PowerShell hook script registered in `settings.json` or agent frontmatter would not be checked. The reviewer verified that every `.claude/hooks` and `.claude/lib` path named in the bundled `settings.json` is in core today.
2. The real-bundle source floor (`test_scanned_source_floor`) requires only one scanned source per surface, so a regression that drops most sources from the scan would not fail that test on its own. The parametrized published-set rows and the closure assertions reduce this risk.
3. Downstream repositories remain affected until they re-run push-down; the CHANGELOG entry states this, and no automated notice exists.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; all toolchain stages and coverage thresholds pass, subject to the S9 CI gate on the final PR head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | `test_scanned_source_floor` | The non-vacuity floor is `len(scanned) >= 1` per surface. | Consider asserting a known core source (for example `.claude/hooks/enforce-completion-consistency.ps1`) is in the scanned set, or a floor derived from the manifest's `.ps1` count. | A floor of one does not detect a partial scan regression. | Inspected test source; spec FR-4.9 requires only a non-empty floor, so the current form meets the specification. |
| Minor | `tests/scripts/dev_tools/pack_manifest_dependency_scan.py` | `_HOOK_PATH` | Command-text closure matches `.(claude|codex)/hooks/<name>.ps1` only. | Extend the pattern to other script extensions if non-PowerShell hooks are registered in the future. | Limits the command-text closure to PowerShell hooks. | Reviewer check: every `.claude/hooks` and `.claude/lib` path in the bundled `settings.json` is listed in core `core.json` (no gaps). |
| Info | `.claude/hooks/enforce-discovery-artifact-gate.ps1` | `Invoke-DiscoveryArtifactGateDecision`, handler deny | The handler deny precedes the `RequiredArtifactReader` fail-open check, so with the module absent a discovery-artifact Write is denied even in a repository without a required-artifact declaration (where the loaded module path would allow). | No change required; this matches spec FR-6 ("in-scope path still fails closed") and is narrower than the pre-change behavior, which denied every call. | Recorded so the ordering is a known design choice. | `DiscoveryValidation.psm1` is listed in Claude `core.json`, so the case arises only when the module is removed after push-down. |
| Info | `artifacts/pester/powershell-coverage.xml` | coverage population | The six bundle copies of the converted hooks are not in the Pester coverage population (pre-existing configuration). | No change required in this item. | Byte-identical mirrors are exercised by the mirror-root rows; their lines are not counted. | `cmp` equality for every pair; package list of the coverage XML. |
| Info | `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | `ISSUE_984_CORE_PATHS`, `ISSUE_984_CLAUDE_CORE_PATHS` | The seven issue #984 paths are listed in both runtimes. | No change required. | Intentional cross-runtime twin, consistent with the existing completeness twins. | Inspected sources. |
| Info | `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1` | handler table | Ids H7 and H8 are skipped because the FailClosed suite already labels rows H7/H8. | No change required. | Avoids an id collision. | `evidence/other/decision-record.2026-10-20T12-51.md`. |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The scanner is pure: every function takes text and returns values, so the self-tests run over in-memory strings with no file access.
- Pack combination and published-path computation are imported from `scripts.dev_tools.push_down_claude_pack_selection` and `push_down_codex_pack_selection`, so the test cannot drift from the publishing logic.
- The exhaustiveness guard (`find_unrecognized_psscriptroot`) makes the regex approach fail loudly on unrecognized forms rather than silently missing dependencies; two additional named forms found in the real bundle are documented in the decision record.
- Path resolution uses `posixpath.normpath` and rejects targets that escape the bundle root.

#### Typing and API notes

- Pyright strict reports 0 errors. `HookCommandSource` is a `Literal` alias; JSON narrowing uses `cast` with string literal types; `Surface` is a frozen dataclass. No new public production API.

#### Error handling and logging

- `ValueError` with the source and resolved path for an escaping target; assertion messages name each missing pair.

### TypeScript implementation audit

#### What changed well

- `coreManifestPaths` narrows `unknown` JSON with explicit checks and a type guard; no `any` and no suppression.

#### Type safety and maintainability

- `PRE_EXISTING_UNRELATED_EXCEPTIONS` is kept as an empty `ReadonlySet<string>` with an assertion that it stays empty, matching the Python twin.

#### Error handling and logging

- A malformed manifest yields an empty set, which makes the per-path rows fail with a clear test name; acceptable for test code.

### PowerShell implementation audit

#### What changed well

- Each conversion is a single-statement handler assignment plus a single-line deny placed directly after the path-scope allow, which keeps the files under 500 lines (largest 496).
- Scope dependencies (`HookPayload.psm1`, `codex-pretooluse-file-mapping.ps1`) remain on `Add-HookDependencyFailure` and still deny every call; only evaluation-only dependencies moved to handlers.
- Deny reasons keep each hook's existing code prefix and name the failed leaf.

#### API and safety notes

- No function signatures changed. PSScriptAnalyzer reports 0 findings across the 11 changed PowerShell files.

#### Error handling and logging

- In-scope denies state that the gate fails closed and name the dependency; the Pester rows assert both the prefix and the leaf name.

---

## Test Quality Audit

The reviewer re-ran the Python, TypeScript, and generator checks and parsed the PowerShell coverage artifact; PowerShell format, analyzer, and Pester results come from loop-pass-3 evidence whose coverage figures match the artifact. Fail-before evidence shows each new test failing for the intended reason against the unfixed code.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1` — CH0 to CH6 on repository and mirror roots, including relative, absolute, and backslash checkpoint paths and the `&` process route; `Should -Invoke ... -Times 0` proves helpers are not called on the deny path.
- `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidationImportFailure.Tests.ps1`, `enforce-batch-budget.RouteImportFailure.Tests.ps1`, `tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1` — out-of-scope allow and in-scope deny for each converted hook.
- `tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py` — 16 self-tests (F1 to F7, comments, quoted `#`, named forms, unrecognized form, synthetic missing target, bundle-root escape, command-text extraction).
- `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` — 16 real-bundle tests; reviewer run passed.
- `evidence/regression-testing/fail-before-pester.2026-10-20T13-37.md` — 50 expected failures before the fix.
- `evidence/regression-testing/fail-before-python-ts.2026-10-20T13-34.md` — 11 Pytest and 8 Jest expected failures before the fix.
- `evidence/regression-testing/pester-shuffle-seed-*.2026-10-20T15-03.md` — three seeded shuffled runs pass.

### Quality assessment prompts

- **Determinism:** load failures are simulated with leaf-filtered `Join-Path` mocks; envelopes and manifests are in-memory or committed files; seeded shuffles pass.
- **Isolation:** each row asserts one decision; handler variables are reset in `finally` and the clean hook is restored in `AfterAll`.
- **Speed:** targeted Python files 0.76s; changed Jest file 24 tests in one suite.
- **Diagnostics:** `-Because` carries the decision reason; Python messages name pack, source, and target.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | PASS | No new subprocess calls; the `&` route in tests invokes the hook script path. |
| Input validation at boundaries | PASS | Envelope anomalies still deny (CH6); missing `file_path` still allows. |
| Error handling remains explicit | PASS | Fail-closed preserved for in-scope paths and for scope dependencies (NFR-7). |
| Configuration / path handling is safe | PASS | Backslash normalization before path-scope checks; scanner rejects targets escaping the bundle root. |
| No host paths in committed artifacts | PASS | Added-line scan for `C:/Users`, `/home/`, `AppData`: no matches. |

---

## Research Log

No external research was required. The review relied on the branch diff, the feature folder's research and decision record, and repository policy files.

---

## Verdict

The change is ready for the normal PR flow. The fix is minimal in production code, follows the H1 handler precedent, and is protected against recurrence by an emptied exception set and a dependency-closure test with self-tests. The two Minor findings concern the strength of the closure test's guards and do not affect correctness of the delivered fix; they can be addressed at the author's discretion. Merge remains subject to the orchestrator's S9 CI green gate on the final PR head.
