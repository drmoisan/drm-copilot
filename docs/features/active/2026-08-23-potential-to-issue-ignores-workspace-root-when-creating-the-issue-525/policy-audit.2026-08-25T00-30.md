# Policy Compliance Audit — Issue #525

- **Timestamp:** 2026-08-25T00-30
- **Feature folder:** `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`
- **Branch:** `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`
- **Base:** `origin/main` (three-dot diff)
- **Merge base:** `0c7469f8c6e2a8e9915789875b436085e704b114`
- **Behind `origin/main`:** 0 commits (`git rev-list --count HEAD..origin/main` = 0)
- **Work mode:** `full-bug` (persisted marker `- Work Mode: full-bug` in `issue.md` line 12)
- **Review worktree:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a38eff9588c69b6ec`

## Verdict Summary

| Channel | Count |
| --- | --- |
| **Blocking (FAIL)** | **0** |
| **PARTIAL** | **2** |
| **PASS** | **21** |
| **UNVERIFIED** | **1** |

No finding requires remediation before merge. No `remediation-inputs` artifact was produced.

## Policy Reading Order Executed

Read in the mandated order before any evidence was evaluated:

1. `CLAUDE.md` (standing instructions, auto-loaded)
2. `.claude/rules/general-code-change.md` (auto-loaded)
3. `.claude/rules/general-unit-test.md` (auto-loaded)
4. `.claude/rules/typescript.md`
5. `.claude/rules/typescript-suppressions.md`
6. `.claude/rules/quality-tiers.md` (auto-loaded)

Supplementary policy consulted for evidence and AC handling: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `.claude/rules/tonality.md`.

## Rejected Scope Narrowing

**None detected.**

The caller prompt directed the full-branch audit against `origin/main` and requested *additional* explicit adjudication of two items plus four supplementary verifications. It did not narrow scope to a plan, task, phase, or file subset; it did not mark any language as out of scope; it did not instruct any toolchain or coverage check to be skipped. The audit executed against the full 37-path branch diff.

## Scope of the Branch Diff

`git diff --name-status origin/main...HEAD` returns **37 paths**, all under `docs/` or `extensions/drm-copilot/` (verified: 37 of 37 matched `^(docs/|extensions/drm-copilot/)`).

| Class | Count |
| --- | --- |
| Production TypeScript source (`extensions/drm-copilot/src/`) | 5 (4 M, 1 A) |
| Test TypeScript source (`extensions/drm-copilot/test/`) | 7 (3 M, 4 A) |
| Configuration (`extensions/drm-copilot/jest.config.cjs`) | 1 (M) |
| Feature documents, plan, research, evidence (`docs/`) | 24 (A) |

Only one language has changed files in the branch diff: **TypeScript**. Every non-TypeScript language has **zero** changed files.

## Language Coverage Verdicts

Explicit `PASS`/`FAIL` is required for every language with changed files. `N/A` is used only for languages with zero changed files on the branch.

| Language | Changed files | Coverage artifact | Repo-wide line | Repo-wide branch | Verdict |
| --- | --- | --- | --- | --- | --- |
| TypeScript | 12 | `extensions/drm-copilot/coverage/lcov.info` (603,029 bytes, present) | **96.69%** (43349/44831) | **90.12%** (6158/6833) | **PASS** |
| Python | 0 | not applicable | — | — | N/A (zero changed files) |
| PowerShell | 0 | not applicable | — | — | N/A (zero changed files) |
| C# | 0 | not applicable | — | — | N/A (zero changed files) |

**Artifact-path note.** The reviewer coverage table names `coverage/lcov.info` for TypeScript. The repository root carries no such file; the changed TypeScript files belong entirely to the `extensions/drm-copilot` package, whose Jest project writes to `extensions/drm-copilot/coverage/lcov.info`. That artifact was located, parsed, and independently regenerated. This is a path variance, not an absent artifact.

### Per-file coverage — independently regenerated, not merely read

The reviewer re-ran `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` in `extensions/drm-copilot` and reproduced the recorded figures byte-for-byte (197/197 suites, 2677/2677 tests, exit 0). Counters extracted from the regenerated `coverage/lcov.info`:

| File | Tier | LH/LF | Line % | BRH/BRF | Branch % | Gate 85/75 |
| --- | --- | --- | --- | --- | --- | --- |
| `src/lib/potential-to-issue/repo-slug.ts` | **new** | 193/193 | 100.00% | 19/19 | 100.00% | PASS |
| `src/lib/potential-to-issue/gh-client.ts` | modified | 358/358 | 100.00% | 27/33 | 81.82% | PASS |
| `src/lib/potential-to-issue/potential-to-issue-service-call.ts` | modified | 238/238 | 100.00% | 17/20 | 85.00% | PASS |
| `src/mcp-tools.ts` | modified | 305/324 | 94.14% | 52/60 | 86.67% | PASS |
| `src/repo-automation-service-contract.ts` | modified | 0/182 | 0.00% | 0/1 | 0.00% | no threshold entry — see §Coverage Exclusion |

No regression on any changed file. Baseline (`evidence/baseline/ts-changed-file-coverage.2026-08-23T23-23.md`) versus post-change deltas are all >= 0; two files improved on branch coverage (`gh-client.ts` +2.51, `service-call.ts` +1.67) and `mcp-tools.ts` improved on both.

The new-file threshold (>= 90% line for added files) is exceeded: `repo-slug.ts` measures 100.00% line and 100.00% branch.

`extensions/drm-copilot/jest.config.cjs` carries **no global threshold key**; it uses per-path entries. Jest exits non-zero when any configured per-path threshold is unmet, so the reproduced `EXIT_CODE: 0` is a second, mechanical confirmation of all three new entries.

## Coverage Exclusion Policy — dedicated verification

Requested check: confirm no `exclude` or `coveragePathIgnorePatterns` entry was added that matches a production source path.

- `collectCoverageFrom` in `extensions/drm-copilot/jest.config.cjs` line 17 is `["src/**/*.ts", "!src/**/*.d.ts"]`. The single negation targets `.d.ts` ambient declaration files, which contain no executable code. **Unchanged by this branch.**
- `coveragePathIgnorePatterns` is **absent from the file entirely** (grep returns no match). None was added.
- `testPathIgnorePatterns` (line 5) is `["/node_modules/", "/out/"]` — test discovery, not coverage measurement. **Unchanged by this branch.**
- The branch's only change to `jest.config.cjs` is `+23 / -0`: three per-file threshold entries at 85 lines / 75 branches, plus two explanatory comment blocks. **No exclusion of any kind was added.**
- `src/repo-automation-service-contract.ts` remains **inside** `collectCoverageFrom` and therefore inside the coverage denominator at 0/182 lines. It carries no *threshold* entry, which the policy permits for interface/type-only modules (`.claude/rules/general-unit-test.md`, "Type-only / interface-only modules"; `.claude/rules/typescript.md` line 53). Verified interface-only: the file's imports are all `import { type ... }` and it declares no `const`, `function`, `class`, `let`, or `var`. Omission from a threshold gate is not exclusion from measurement.

**Verdict: PASS.** No production file was excluded from coverage measurement.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` → **exit 0**, zero reported paths.
- Grep of the 37-path diff for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`, and any `^artifacts/` prefix → **0 matches**.
- All 20 evidence artifacts resolve under `<FEATURE>/evidence/<kind>/` using the canonical kinds `baseline`, `regression-testing`, `qa-gates`, `issue-updates`, `other`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose; no caller instruction specified a non-canonical evidence path.

**Verdict: PASS.**

Observation (non-blocking, no rule violated): evidence filenames carry the plan's fixed timestamp token `2026-08-23T23-23` while several artifacts' internal `Timestamp:` fields record the later execution time (`2026-08-25T09-33`, `2026-08-25T10-14`). `evidence-and-timestamp-conventions` mandates the `yyyy-MM-ddTHH-mm` format for both but does not require the filename token and the content field to be equal, and the plan fixed the filename token in advance so its acceptance conditions would be checkable. No finding.

Correction to the caller prompt: the write-set audit artifact is at `evidence/other/write-set-diff-audit.2026-08-23T23-23.md`, not `...2026-08-25T00-30.md`. The `evidence/other/` directory holds exactly three files, all on the `2026-08-23T23-23` token. The caller's instruction to verify the filename rather than trust the quoted timestamp was correct.

## Prohibited-Path Zero-Appearance Verification

Requested check, executed against `git diff --name-only origin/main...HEAD` (37 paths):

| Prohibited class | Pattern | Matches |
| --- | --- | --- |
| Python promotion module `scripts/dev_tools/potential_to_issue.py` and its pytest modules | `_to_issue\.py` | **0** |
| Any path in the Python script tree | `^scripts/` | **0** |
| Any path in the Python test tree | `^tests/` | **0** |
| `feature-promotion-lifecycle` skill and bundled copies | `promotion-lifecycle`, `resources/` | **0** |
| Every file under `.claude/rules/` | `\.claude/rules/` | **0** |
| Any file under the Claude runtime surface | `^\.claude/` | **0** |
| The tier map | `quality-tiers` | **0** |
| Both tool-definitions modules | `tool-definitions` | **0** |
| Any instruction document | `^\.github/` | **0** |

Composite regex over all nine classes returned **0 total occurrences**. Complementary check: all 37 paths matched `^(docs/|extensions/drm-copilot/)`.

**Verdict: PASS.** Every enumerated class appears zero times, as the spec's non-goals and the plan's Out-of-Scope Reminders require.

## Toolchain Loop — Reviewer Re-Execution

The reviewer re-ran every stage that has a runner, check-only where a check-only form exists. `npm run format` is `prettier --write` (mutating); `prettier --check` over the identical glob set was substituted so the review performed no mutation.

| Stage | Command | Exit | Result |
| --- | --- | --- | --- |
| 1. Formatting | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | 0 | "All matched files use Prettier code style!" |
| 2. Linting | `npx eslint --no-error-on-unmatched-pattern src test` | 0 | No output; 0 errors, 0 warnings |
| 3. Type checking | `npx tsc -p ./ --noEmit` | 0 | 0 diagnostics |
| 4. Architecture boundaries | none exists | — | See PARTIAL-1 |
| 5. Unit tests | `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` | 0 | 197/197 suites, 2677/2677 tests |
| 6. Contract / schema | none exists | — | See PARTIAL-1 |
| 7. Integration tests | none exists | — | See PARTIAL-1 |

Every runnable stage passed on first execution with no restart. The recorded QA-gate evidence is confirmed accurate against independent re-execution.

## Findings

### PARTIAL-1 — Three of the seven mandated toolchain stages have no runner in this repository

- **Rule:** `.claude/rules/general-code-change.md`, "Mandatory Toolchain Loop" — seven stages must complete without errors in a single pass.
- **Evidence:** `extensions/drm-copilot/package.json` declares exactly `compile`, `build`, `bundle:extension`, `bundle:mcp-server`, `format`, `lint`, `typecheck`, `test`, `test:unit`, `test:coverage`. The repository-root `package.json` declares `compile`, `typecheck`, `watch`, `format`, `format:check`, `pretest`, `lint`, `test:unit`, `test:unit:coverage`, `test`. Neither declares a dependency-cruiser, contract/schema-diff, or integration-test script.
- **Corroboration:** `.dependency-cruiser.cjs` does not exist at the repository root or in the extension package. A repository-wide content search for `dependency-cruiser|depcruise` returns matches only in documentation, policy prose, bundled policy copies, prior audit artifacts, and one blast-radius fixture — never in a runnable configuration or script.
- **Assessment:** stages 4, 6, and 7 are unexecutable in this repository. This is a **pre-existing repository property, not a gap introduced by this branch**, and the tier map and CI configuration are explicitly outside this feature's write set. The three stages are correctly recorded as "no configured runner" rather than claimed as passed.
- **Verdict: PARTIAL.** Not Blocking. No remediation required on this branch.

### PARTIAL-2 — One test-support path outside the plan's declared Write Set

- **Path:** `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts` (status **A**, 149 lines, added in commit `279d4f7c`).
- **Declared Write Set:** `plan.2026-08-23T23-23.md` lines 40-72 enumerate five production source paths, six test source paths, one configuration path, and two feature documents. This path is not among them.
- **Disclosure:** recorded in full under `## Finding — one unclaimed path` in `evidence/other/write-set-diff-audit.2026-08-23T23-23.md` lines 107-138. That artifact explicitly declines to count the path as satisfying the Write Set assertion.
- **Adjudication — acceptable documented divergence, NOT Blocking.** Five independent grounds, stated so a later reader can re-test the reasoning:
  1. **Reverting is not available without violating a hard rule.** The two files measure 397 and 149 lines (verified by `wc -l`). Folding the helper back produces a 546-line test file, breaching the 500-line limit in `.claude/rules/general-code-change.md`, which admits no exception for test code. Where a plan artifact and a hard policy rule conflict, the policy rule is authoritative.
  2. **The plan anticipated this exact remedy, for a sibling file.** Plan line 70 fixes the identical extraction for `extension.potential-to-issue.test.ts` ("stands at 497 lines and the repository limit is 500"), and plan line 36 names the `-test-support.ts` convention. The service-call suite hit the same constraint from the same cause — unconditional slug resolution plus the `[P3-T8]` fail-closed scenario. The executor applied the plan's own stated remedy to a second instance the plan did not foresee.
  3. **Zero production surface.** The module exports test fixtures, a recording `CommandRunner` stub, a filesystem-fake subclass, a seeding helper, and a recording resolver. No production module imports it (it lives under `test/`). It cannot change runtime behavior.
  4. **Zero blast-radius impact.** It sits in `extensions/drm-copilot/test/lib/potential-to-issue/`, the same subtree as three declared Write Set test files. It adds no path, module, or shared-surface contention the declared radius did not already carry, so the scheduling purpose the plan cites for fixing paths in advance is unharmed.
  5. **Disclosed, not absorbed.** It was recorded in a committed evidence artifact before review, with its own line count, its commit SHA, and an explicit refusal to treat it as satisfying the assertion.
- **Counter-argument considered and rejected:** the plan states that "a conditional path cannot be scheduled," which argues for treating any unenumerated creation as a scope escape. That reasoning exists to protect blast-radius-derived concurrent scheduling. Ground 4 establishes the protected harm did not occur, and ground 1 establishes the alternative was a policy violation. The counter-argument does not survive.
- **Advisory (bookkeeping, not a merge condition):** amending the plan's Write Set to enumerate the path would close the discrepancy for the record. This is documentation hygiene, not remediation.
- **Verdict: PARTIAL.** Not Blocking.

### UNVERIFIED-1 — Tier-dependent gates cannot be adjudicated

- **Rule:** `.claude/rules/quality-tiers.md` — "`quality-tiers.yml` at repo root maps every project to one tier."
- **Concrete reason:** the file does not exist. `Glob **/quality-tiers.y*ml` across the worktree returns no files.
- **Consequence:** the tier-dependent gates — untyped-escape-hatch budget, property-test density (>= 1 per pure function for T1/T2), mutation score (>= 75% for T1), determinism retry rate, golden tests, E2E scope — cannot be adjudicated for the changed modules because no tier is assigned to them.
- **Impact on this branch: none.** (a) The uniform gates are tier-independent by Authoritative Decision #2, so the coverage verdict above stands regardless of tier. (b) The changed modules contain zero untyped escape hatches (verified: no `any`, no `as` assertions added, no suppressions), so the strictest tier budget is met unconditionally. (c) The tier map is explicitly outside this feature's write set (spec, Explicit non-goals) and its absence is repository-wide and pre-existing, present at the merge base.
- **Verdict: UNVERIFIED**, pre-existing, out of scope for this branch. Recommend filing a separate repository-hygiene item.

### PASS Findings

| # | Rule | Evidence |
| --- | --- | --- |
| 1 | Tonality — professional, factual, no humor/hyperbole/metaphor | `spec.md`, `issue.md`, plan, and all 20 evidence artifacts read; measured, evidence-matched wording throughout; no celebratory or promotional phrasing |
| 2 | Simplicity first | `repo-slug.ts` is one exported function plus two private helpers and a two-constant vocabulary; no indirection layer, no class, no abstract type introduced for a single implementation |
| 3 | Reusability / no copy-paste | `repoSelector()` is a single private method spliced into all three vectors, so the three call sites cannot drift apart |
| 4 | Extensibility — non-breaking public API | `repo`, `repoSlugResolver`, `targetRepository`, and `target_repository` are all optional. Absent-binding vectors are byte-identical to pre-change form, pinned by the test `leaves the three vectors unchanged when no repo is supplied` |
| 5 | Separation of concerns | `repo-slug.ts` performs no filesystem or network I/O of its own; runner and path lookup are both injected. Pure parsing (`extractSlug`) is separated from invocation (`resolveRepoSlug`) |
| 6 | File size limit (500 lines) | Largest changed file is `extension.potential-to-issue.test.ts` at **442** lines. All 13 changed code files verified by `wc -l`: 358, 238, 193, 324, 182, 236, 135, 442, 415, 149, 397, 206, 126 |
| 7 | Fail fast and explicitly | Every one of the six unresolvable code paths throws a prefixed `Error` naming the workspace root. No branch returns null, no branch falls back, no error is swallowed |
| 8 | No broad catch-all | The single `catch` (`repo-slug.ts` lines 119-126) immediately re-throws with added context, and carries a comment stating why the context is required |
| 9 | Naming | `camelCase` functions/variables, `PascalCase` types, `SCREAMING_SNAKE` module constants, kebab-case filename `repo-slug.ts`. No abbreviations outside `gh`/`fs`/`args` |
| 10 | Dependencies | Zero new runtime or dev dependencies. `package.json` is not in the diff |
| 11 | I/O boundaries | Domain logic is testable without network or filesystem — proven by the entire suite running with no `gh` binary present |
| 12 | Test independence, isolation, speed, determinism, readability | 2677 tests complete in 10.5s; every new test constructs its own fakes with no shared mutable state; names state scenario and expected outcome |
| 13 | Coverage thresholds >= 85% line / >= 75% branch | Table above; all gated files clear both floors; repo-wide 96.69% / 90.12% |
| 14 | No coverage regression on changed lines | `evidence/other/coverage-delta.2026-08-23T23-23.md` — all five deltas >= 0, independently reproduced from regenerated `lcov.info` |
| 15 | Coverage Exclusion Policy | See dedicated section above. No production path excluded; no exclusion added |
| 16 | Scenario completeness | Positive flow, seven negative flows (spec E3), boundary (empty output, non-object payload), error handling (fail-closed), and the R3 regression case are all covered |
| 17 | Arrange–Act–Assert structure | All new tests carry explicit `// Arrange` / `// Act` / `// Assert` comments |
| 18 | **No temporary files in tests** | Search for `mkdtemp`, `tmpdir`, `os.tmp` across the changed test tree returns **0 matches**. `FakePotentialFileSystem` is an in-memory `Map`; the extension suite registers `jest.mock("node:fs", ...)` |
| 19 | **No external process or real `gh` binary** | `repo-slug.test.ts` injects `ghPathLookup: () => "/usr/bin/gh"` at every call site. `extension.potential-to-issue.test.ts` registers `jest.mock("node:child_process", ...)`. The default resolver deliberately returns the bare program name and performs no `where`/`which` PATH probe (`defaultGhProgramName`, documented at `repo-slug.ts` lines 60-75). Confirmed empirically: the full suite passes in this worktree with exit 0 |
| 20 | Test file location mirrors production tree | `src/lib/potential-to-issue/repo-slug.ts` → `test/lib/potential-to-issue/repo-slug.test.ts`. No test file was placed under `src/`. Both `-test-support.ts` modules sit beside the suites they serve, inside `test/` |
| 21 | TypeScript suppression policy | **Zero** suppressions across the entire diff: no `eslint-disable`, no `@ts-ignore`, no `@ts-expect-error`, no `@ts-nocheck`. ES module syntax throughout; no `require`/`module.exports` added; no `any`; no new type assertions in production code |

## Fail-Closed Ordering — dedicated verification

Requested check: confirm the fail-closed path genuinely precedes both the GitHub write and the filesystem move.

Read directly from `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts`:

- Line **174**: `const targetRepository = resolveSlug(input.workspaceRoot);` — the **first executable statement** of `potentialToIssueServiceCall`. Nothing precedes it but the resolver-selection expression on lines 170-173, which performs no work.
- Line **180-185**: `RealGhClient` construction. Follows resolution, and receives `repo: targetRepository`.
- Line **189**: filesystem instantiation.
- Line **191**: `promotePotential({...})` — the call that performs both the GitHub write and the record move.

Resolution therefore precedes the client construction by 6 lines and the promotion call by 17 lines, with no intervening side effect. Because `resolveSlug` throws rather than returning a sentinel, a failure short-circuits the function before either effect.

**Behaviorally confirmed**, not merely read: the test `fails closed without creating an issue or moving the record when the slug cannot be resolved` asserts three separate post-conditions — the recording runner logged zero `issue create` vectors, the injected client logged zero calls of any kind (`gh.calls` equals `[]`), and the in-memory filesystem still holds the record at its original path with `fs.moves` equal to `[]`. All three pass.

**Verdict: PASS.**

## Assumptions Recorded

1. **PR context artifacts are absent and were deliberately not regenerated.** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in this worktree. Regeneration was not attempted because `collect_pr_context` carries a known, separately tracked defect — recorded in this feature's own `spec.md` under Explicit non-goals — whereby it writes its artifact to the main checkout while reporting worktree paths. Running it from this isolated worktree would mutate a path outside the review worktree, which the review's no-mutation constraint forbids. Scope was instead derived directly from `git diff origin/main...HEAD` against the fetched remote-tracking ref, which the Scope Invariant names as an authoritative scope source co-equal with the PR context artifacts. No scope information was lost: the three-dot diff is the same input the artifacts summarize.
2. **`user-story.md` is correctly absent** under `full-bug`, per `acceptance-criteria-tracking`. `spec.md` is the sole AC source. Its absence is not a finding.
3. **Timestamp token.** This artifact uses the caller-supplied `2026-08-25T00-30` token, which differs from the evidence tree's `2026-08-23T23-23` token. Both satisfy the mandated `yyyy-MM-ddTHH-mm` format.
