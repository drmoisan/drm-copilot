# Feature Audit — Acceptance Criteria Verification, Issue #525

- **Timestamp:** 2026-08-25T00-30
- **Branch:** `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`
- **Baseline:** `origin/main` (merge base `0c7469f8`), three-dot diff
- **Work mode:** `full-bug`
- **AC source:** `spec.md`, section `## Acceptance Criteria` (17 criteria) — **sole** source under `full-bug`
- **`user-story.md`:** intentionally absent; correct under `full-bug` and not a finding

## Verdict Summary

| Channel | Count |
| --- | --- |
| **Blocking (FAIL)** | **0** |
| **PARTIAL** | **0** |
| **PASS** | **17 of 17 acceptance criteria** |
| **UNVERIFIED** | **0** |

All 17 criteria are independently verified. Two carry a disclosure note that is examined explicitly below (AC-15 and AC-17); neither disclosure reduces the verdict, and neither is an overclaim.

## AC Source Resolution

The persisted marker `- Work Mode: full-bug` appears at `issue.md` line 12 and at `spec.md` line 8. Per `acceptance-criteria-tracking`, `full-bug` resolves the AC source to `spec.md` only. The `spec.md` header block states this explicitly at lines 11-13. `user-story.md` is not an AC source in this mode and its absence is correct.

The spec's `## Acceptance Criteria` section contains 17 checkbox items, all currently `- [x]`. Check-off was performed under `[P6-T8]` with the mapping recorded at `evidence/other/acceptance-criteria-checkoff.2026-08-23T23-23.md`.

## Criterion-by-Criterion Verification

Each verdict below is stated with the evidence the reviewer inspected directly, not with a restatement of the executor's own mapping.

| # | Criterion (abbreviated) | Reviewer verification | Verdict |
| --- | --- | --- | --- |
| 1 | Issue-creation vector carries explicit `--repo <owner/name>` resolved from `workspace_root`, asserted at the injected CLI boundary with no live GitHub call | `gh-client.ts` lines 307-310 splice `...this.repoSelector()` after `["issue","create"]`. Test `binds the repo selector into the issue create vector` asserts the full 10-element vector with `"--repo", REPO` at positions 2-3. Runner is the recording fake; `ghPathLookup` is injected | **PASS** |
| 2 | Label-create and issue-view calls carry the same selector | `gh-client.ts` lines 328-331 and 348-351. Tests `binds the repo selector into the label create vector` and `binds the repo selector into the issue view vector` assert both full vectors | **PASS** |
| 3 | The re-created issue on the missing-label recovery leg carries the same selector as the initial attempt | Test `carries the same repo selector on the missing-label recovery retry` drives one bound client through create → ensureLabel → create and asserts `[[2, REPO], [2, REPO], [2, REPO]]` — identical value **and** identical position in all three vectors. Structurally guaranteed: all three read the same `this.repo` field | **PASS** |
| 4 | Slug resolution runs against the checkout at the resolved `workspace_root`, recorded through an injected seam; recorded value is the supplied root, not the process cwd | Two independent levels. `repo-slug.test.ts` asserts `recorded[0]?.options?.cwd` equals `WORKSPACE_ROOT`. `potential-to-issue-service-call.test.ts` test `...differs from the process working directory` asserts `recordedWorkspaces` equals `[DIFFERING_WORKSPACE]` where `DIFFERING_WORKSPACE` is `/other-checkout`, deliberately not the process cwd. Implementation: `repo-slug.ts` line 169-172 passes `cwd: workspaceRoot` | **PASS** |
| 5 | With no repository binding, the three vectors are byte-identical to their pre-change form | `repoSelector()` returns `[]` when `this.repo` is `undefined`, so the spread contributes nothing. Test `leaves the three vectors unchanged when no repo is supplied` asserts all three against literal pre-change forms. The three pre-existing exact-vector tests also still pass unmodified | **PASS** |
| 6 | Same-repository promotion yields unchanged summary, `destination_path`, and `artifacts`, echoes that checkout's slug, and every pre-existing assertion passes with unmodified expected values | Test `...matches the process working directory` asserts the echoed slug **and** re-asserts `summary`, `destinationPath`, and `artifacts` with the pre-existing expected forms rebased on `PROCESS_ROOT`. **Independently verified by the reviewer:** `git diff origin/main...HEAD` over the two seam-only test files, filtered to removed lines containing `expect(`, `toBe(`, `toEqual(`, or `toThrow(`, returns **zero lines**. No assertion was deleted or altered in either file | **PASS** |
| 7 | Result exposes the resolved slug snake-cased on the MCP surface, verified through the full projection chain rather than only at the service-call return | `mcp-tools.ts` lines 109-111 add the conditional spread inside the unexported `toMcpToolResult`. Test `projects the target repository onto the potential to issue MCP result` dispatches `dispatchRepoAutomationTool` against a fully-stubbed service and asserts `result.target_repository`. The chain traversed is service result → `toMcpToolResult` → dispatch result, which satisfies "full projection chain" rather than a seam-local check | **PASS** |
| 8 | The field is optional on the shared execution-result contract; other tools' results are unchanged with the field absent | `repo-automation-service-contract.ts` declares `readonly targetRepository?: string`. Test `omits the target repository key for tools that resolve none` dispatches `new_potential_entry` and asserts `"target_repository" in result` is `false`, then pins the complete remaining key set with `toEqual`. Using `in` correctly distinguishes an absent key from a present-and-`undefined` key. `tsc --noEmit` exit 0 confirms no other tool's result construction was broken by the addition | **PASS** |
| 9 | Unresolvable slug fails with an explicit error naming the `workspace_root`; no `--repo`-less invocation and no implicit-resolution fallback | All six throw sites in `repo-slug.ts` route through `unresolved(workspaceRoot, reason)`, which interpolates the root. Test `names the workspace root in the thrown message` uses a root distinct from every other test's (`/checkout-that-cannot-be-resolved`) so the assertion cannot pass on an incidental substring. **No fallback exists in the source:** the function has no `return` reachable after any failure classification, and no `catch` that continues | **PASS** |
| 10 | On resolution failure no issue-creation invocation is made and the record is not moved, asserted against the recording CLI fake and the in-memory filesystem fake | Test `fails closed without creating an issue or moving the record...` asserts three post-conditions: recorded vectors filtered to `issue create` equal `[]`; `gh.calls` equal `[]`; `fs.exists(DIFFERING_POTENTIAL)` is `true` **and** `fs.moves` equals `[]`. Ordering confirmed by source position — resolution at line 174, `promotePotential` at line 191, nothing between | **PASS** |
| 11 | Resolver unit tests cover success, no `origin` remote, non-zero exit, empty output, unparseable output, non-object payload, and missing or non-string owner/name field | `repo-slug.test.ts` contains 9 tests: 1 success, 7 named failure conditions matching the enumeration one-for-one, and 1 message-content test. Independently confirmed by the reviewer's own suite run. Coverage: 19/19 branches, 100.00% | **PASS** |
| 12 | The client docstring no longer asserts byte-identical argument vectors with the Python sibling and states the divergence and its reason | **Reviewer re-ran the check:** `git grep -n -F "are byte-identical to the Python source" -- extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts` exits **1** (zero matches). The replacement text at lines 11-25 states the divergence, scopes it to the three vectors, and gives its structural reason. The separate, still-true `GH_NOT_FOUND_MESSAGE` parity claim was correctly left intact | **PASS** |
| 13 | `scripts/dev_tools/potential_to_issue.py` and its three dedicated pytest modules are unmodified in the branch diff | Pattern `_to_issue\.py` matches **0** of 37 paths. `^scripts/` matches **0**. `^tests/` matches **0**. No Python file of any kind appears in the diff | **PASS** |
| 14 | No file under `.claude/skills/feature-promotion-lifecycle/`, no bundled copy, no file under `.claude/rules/`, and no tool-definition module appears in the branch diff | Patterns `promotion-lifecycle`, `resources/`, `\.claude/rules/`, `^\.claude/`, `tool-definitions`, and `^\.github/` each match **0** of 37 paths. Complementary check: all 37 paths match `^(docs/\|extensions/drm-copilot/)` | **PASS** |
| 15 | Per-changed-file Jest thresholds of 85% line and 75% branch are configured for and met by every changed extension source file, including the new resolver | Four of five changed source files carry a threshold entry and clear both floors: `repo-slug.ts` 100.00/100.00, `gh-client.ts` 100.00/81.82, `potential-to-issue-service-call.ts` 100.00/85.00, `mcp-tools.ts` 94.14/86.67 (pre-existing entry). Figures independently regenerated from `coverage/lcov.info`. Jest exit 0 is the mechanical confirmation. **Disclosure examined below** | **PASS** |
| 16 | New and updated tests create no temporary files, mock the child-process boundary, and inject the CLI path lookup; suite passes with no network and no real GitHub CLI execution | Search for `mkdtemp`, `tmpdir`, `os.tmp` across the changed test tree: **0 matches**. `extension.potential-to-issue.test.ts` registers `jest.mock("node:fs", ...)` and `jest.mock("node:child_process", ...)`. `repo-slug.test.ts` injects `ghPathLookup: () => GH_PATH` at every call site. `defaultGhProgramName` performs no PATH probe by design. **Empirically confirmed:** the reviewer ran the full 2677-test suite to exit 0 in this worktree | **PASS** |
| 17 | The full seven-stage toolchain completes without errors in a single pass | Four stages ran and passed; three have no runner in the repository. **Disclosure examined below** | **PASS** |

## AC-15 — Examination of the fifth changed source file

AC-15 reads "every changed extension source file." Five source files changed; four carry a threshold entry. The fifth, `src/repo-automation-service-contract.ts`, carries none and measures 0.00% on both metrics.

This is **not** an executor-invented exemption. Three independent grounds:

1. **The spec pre-authorized it in its own Constraints section**, before implementation: "An interface-only contract file is already documented as excluded from the threshold gate and needs no entry." The exemption is part of the requirement AC-15 encodes, not a deviation from it.
2. **The file is verifiably interface-only.** Its imports are all `import { type ... }` form; it declares no `const`, `function`, `class`, `let`, or `var`. Its declarations are erased at transpile time, so it can never report non-zero executable coverage. `.claude/rules/general-unit-test.md` and `.claude/rules/typescript.md` line 53 both permit such modules to be omitted from threshold measurement.
3. **The exemption is from the threshold gate, not from measurement.** The file remains inside `collectCoverageFrom` and therefore inside the coverage denominator at 0/182 lines. Under the Coverage Exclusion Policy this is the required disposition — excluding it would be the violation.

`jest.config.cjs` records the reasoning inline (lines 230-234), stating that the omission still holds after the optional `targetRepository` property was added because an interface property declaration emits no executable statement. Verified against the lcov counters: `LF` moved from 176 to 182 while `LH` remained 0, so the ratio is unchanged at 0.00% and the delta is exactly zero — no regression.

**AC-15 verdict: PASS.** The disclosure is accurate and the carve-out is spec-authorized.

## AC-17 — Examination of the seven-stage scope claim

**Requested adjudication: is the criterion-17 disposition honest, or an overclaim?**

**It is honest. Independently verified, and it is not an overclaim.**

Three things had to be true for the disposition to be honest, and all three were checked directly rather than accepted from the mapping artifact.

**1. The four claimed stages genuinely pass.** The reviewer re-executed all four in this worktree:

| Stage | Reviewer command | Exit |
| --- | --- | --- |
| Formatting | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | 0 — "All matched files use Prettier code style!" |
| Linting | `npx eslint --no-error-on-unmatched-pattern src test` | 0 |
| Type checking | `npx tsc -p ./ --noEmit` | 0 |
| Unit tests | `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` | 0 — 197/197 suites, 2677/2677 tests |

These reproduce the recorded QA-gate figures exactly, including the coverage percentages to two decimals.

**2. The three unclaimed stages genuinely have no runner.** Verified independently of the mapping artifact:

- `extensions/drm-copilot/package.json` declares exactly `compile`, `build`, `bundle:extension`, `bundle:mcp-server`, `format`, `lint`, `typecheck`, `test`, `test:unit`, `test:coverage`.
- The **repository-root** `package.json` was also checked, because a stage could plausibly be configured one level up: it declares `vscode:prepublish`, `compile`, `typecheck`, `watch`, `format`, `format:check`, `pretest`, `lint`, `test:unit`, `test:unit:coverage`, `test`. Neither file declares a dependency-cruiser, contract/schema-diff, or integration-test script.
- `.dependency-cruiser.cjs` — the configuration file `.claude/rules/typescript.md` names as the TypeScript architecture-boundary tool — **does not exist** at the repository root or in the extension package.
- A repository-wide content search for `dependency-cruiser|depcruise` returns matches only in `README.md`, policy prose, bundled policy copies under `resources/`, prior feature audit artifacts, and one blast-radius test fixture. It returns **no runnable configuration and no script**.

**3. The wording does not claim more than was done.** The mapping artifact states, in terms: "It is not a claim that architecture-boundary, contract, and integration suites exist and passed; those three stages have no runner to execute, and their absence is a pre-existing property of this package, not a gap introduced by this change." It marks the three stages `n/a — no configured runner`, names the file it checked, and confirms the single-pass property separately (the format stage rewrote zero files, so the Phase 6 restart condition never fired).

**Assessment.** An overclaim would be a check-off asserting that seven stages ran clean. This one asserts that four ran clean, names the three that cannot run, names the file that establishes they cannot, and states the limit of what it claims. The reviewer independently confirmed both halves — that the four pass and that the three have no runner anywhere in the repository, not merely in the extension package. The disposition is an accurate, appropriately bounded record.

The residual policy question — that `.claude/rules/general-code-change.md` mandates seven stages while the repository provides runners for four — is a genuine gap, but it is repository-wide, pre-existing at the merge base, and outside this feature's write set. It is recorded as **PARTIAL-1** in `policy-audit.2026-08-25T00-30.md` against the repository, not against this branch.

**AC-17 verdict: PASS**, with the scope of the claim recorded above.

## Required Behavior and Error Handling Traceability

Beyond the checkbox list, the spec states R1-R4 and E1-E5. Mapped for completeness:

| Requirement | Implementation | Verified |
| --- | --- | --- |
| R1 — target repository resolved from `workspace_root` via the CLI repository-view operation through the injected runner, after normalization | `repo-slug.ts` `resolveRepoSlug`; invoked at `potential-to-issue-service-call.ts` line 174 with `input.workspaceRoot` (the resolved value). **No leg reads a remote URL** — confirmed by reading the whole 193-line module; there is no URL string, no `parse`, and no `origin` reference outside a comment | Yes |
| R2 — all repository-scoped legs name the same repository, including the recovery retry | All three vectors read the same `this.repo` field; retry pinned by test | Yes |
| R3 — same-repository case unchanged, plus byte-identical unbound vectors | Two dedicated tests, plus zero removed assertions in the seam-only suites | Yes |
| R4 — result exposes the slug through the projection chain, snake-cased at the MCP surface, optional on the shared contract | Three-stage projection traversed by test; optionality confirmed by `tsc` and by the absent-key test | Yes |
| E1 — fail closed on unresolvable slug, no implicit fallback | Six throw sites; no fallback path exists in source | Yes |
| E2 — failure precedes any GitHub write and the filesystem move | Source ordering lines 174 → 191; three-way post-condition assertion | Yes |
| E3 — enumerated unresolvable conditions | Seven conditions across six code paths (two share the non-zero-exit branch, which is correct — the CLI reports both identically); seven named tests | Yes |
| E4 — retired; unreachable under the adopted mechanism | Annotated in place at `spec.md` lines 203-211 rather than deleted, preserving the enumeration. No implementation branch and no test exists for it, as intended | Yes |
| E5 — pre-existing failure surfaces preserved | Non-zero-exit throw, `PromotionError` propagation, and destination-existence post-condition all retain their pre-existing tests with unmodified expected values | Yes |

## Recorded `scope_change` Disposition — reviewer acknowledgement

`issue.md` carried an inherited criterion requiring a live integration retest that promotes a throwaway record against a second real repository and deletes the resulting issue afterwards. The orchestrator recorded the disposition **`scope_change`**, replacing it with hermetic argument-boundary assertions against an injected fake GitHub CLI. Both `issue.md` (lines 113-117) and `spec.md` (lines 303-333) record the disposition and instruct that a later reviewer must not read the removal as a dropped requirement.

**The reviewer acknowledges the disposition and concurs with its reasoning, which was examined rather than accepted on assertion.** Two grounds:

1. **The live test was not executable unattended.** It creates a real GitHub issue in a second repository — which the promotion-gate hook exists specifically to keep off the agent command surface — and GitHub issues cannot be deleted through the CLI, so the cleanup step has no automated form and would leave residue in a real repository.
2. **The replacement is a stronger assertion, not a weaker substitute.** The live test could observe the target repository only indirectly, through the issue URL in the returned result. The hermetic form asserts the **exact argument vector** at the injected CLI boundary — the precise point where the defect lived — and additionally reaches the E3 failure branches on demand, which a live run could not. A live test that returned a correct URL would not have proven the selector was present; the vector assertion does.

The retained same-repository criterion (R3) is verified in the same test pass, as required. This is a recorded scope change with a stronger replacement, not a dropped requirement.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/spec.md
- Total AC items: 17
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: none
```

All 17 items were already checked off under `[P6-T8]` before this review. The reviewer independently verified each and **checked off no additional items**, because none remained unchecked. No item was found to be checked without supporting evidence, so no item was reverted.

## Baseline Comparison

| Dimension | Baseline (`origin/main`) | Post-change | Delta |
| --- | --- | --- | --- |
| Repository targeted by `gh issue create` on the promotion path | implicit — the MCP server's launch-time working directory | explicit `--repo <owner/name>` resolved from `workspace_root` | defect closed |
| Repository-scoped legs carrying an explicit selector | 0 of 3 | 3 of 3, plus the recovery retry | +3 |
| Behavior on an unresolvable target | silent misfile into the wrong repository, reported as `ok: true` | explicit throw naming the workspace root, before any side effect | fail-closed |
| Caller-observable target repository | none — inferable only by cross-reading two unrelated result fields | `targetRepository` / `target_repository`, echoed explicitly | new |
| Overall line coverage | 96.66% (43084/44571) | 96.69% (43349/44831) | +0.03 |
| Overall branch coverage | 90.05% (6128/6805) | 90.12% (6158/6833) | +0.07 |
| Test count | — | 2677 passing, 0 failing, 0 skipped | +25 tests added |
| Files exceeding the 500-line limit | 0 | 0 | unchanged |
| Suppressions in the changed surface | — | 0 | none added |

## Conclusion

The delivered change satisfies every acceptance criterion in the sole AC source. The defect described in `issue.md` — a promotion whose record and issue land in different repositories — is closed at its two root-cause omissions simultaneously, the failure mode is converted from a silent misfile to an explicit pre-side-effect throw, and the target repository is now observable at the call site. The two disclosures examined above (AC-15's interface-only carve-out and AC-17's stage scope) are both accurate and both independently confirmed.

**No acceptance criterion requires remediation.**
