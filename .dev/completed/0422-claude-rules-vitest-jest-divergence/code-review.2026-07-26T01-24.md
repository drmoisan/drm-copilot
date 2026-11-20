# Code Review: Claude/Codex Rule Mirror Vitest→Jest Correction (#422)

**Review Date:** 2026-07-26
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422`
**Feature Folder Selection Rule:** Single active folder whose `-422` suffix matches the issue number in the branch name; supplied explicitly by the orchestrator and confirmed against the diff.
**Base Branch:** `origin/main` (merge base `fb483b8468204e4385b5583c3b3ec4c0a987eede`)
**Head Branch:** `bug/claude-rules-typescript-vitest-jest-divergence` (`042ed066b1350100513bc0a7e09c141b2f3ead12`)
**Review Type:** Initial review

---

## Executive Summary

This branch corrects twelve Markdown instruction files (six repo-root mirrors, six bundled extension copies edited in byte-identical pairs) so they describe the Jest toolchain the repository actually runs, replacing Vitest framework references and two wrong `npm run` commands. It adds one 184-line pytest regression module (15 cases) that locks the corrected state via forbidden-token, command-resolution, and semantic-anchor assertions. No production code changed.

Evidence reviewed: the full branch diff against the merge base, the regenerated PR context artifacts, all 26 executor evidence artifacts, and reviewer-executed re-runs of the complete Python toolchain (Black, Ruff, Pyright, full pytest suite: 2138 passed) plus SHA-256 parity hashing of all six mirror pairs. Implementation quality is high: the fix direction is canon-to-mirror as `CLAUDE.md` requires, every corrected command was verified against root `package.json`, and the runtime-affecting allowlist change (`Bash(npx jest *)`) is consistent with the pre-implementation gate hook and the installed Jest toolchain.

**What changed:**
- `.claude/rules/typescript.md` (+ bundle): Testing stage now names Jest and `npm run test:unit` (line 16); Testing Standards mandate Jest with `jest.spyOn`/`jest.mock`/`jest.resetAllMocks` (lines 42, 47); coverage command corrected to `npm run test:unit:coverage` with an accurate description of `run-jest.cjs --coverage`, replacing the stale "Prompt B1" clause (line 51); Jest fake timers (line 73).
- `.claude/rules/general-unit-test.md` (+ bundle): `vitest.config.ts` → `jest.config.cjs` in the permitted coverage-exclude list; `jest.useFakeTimers()` in the determinism section.
- `.claude/rules/general-code-change.md` (+ bundle): unit-test-stage runner list TypeScript slot now reads Jest.
- `.claude/agents/atomic-executor.md` (+ bundle): tool allowlist `Bash(npx vitest *)` → `Bash(npx jest *)`; TypeScript toolchain command list `npx vitest` → `npx jest`.
- `.agents/skills/general-unit-test/SKILL.md` and `.agents/skills/general-code-change/SKILL.md` (+ bundles): same corrections in lockstep.
- New `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`.
- Feature-folder documentation and evidence.

**Top 3 risks:**
1. The `.dependency-cruiser.cjs` stale reference (three instruction locations) remains unfixed by design; if the follow-up issue is not actually filed, agents will continue to be pointed at a nonexistent config file for architecture-boundary checks.
2. `README.md:303`/`README.md:318` still describe the TypeScript toolchain as Vitest, so human readers of the README receive instructions that now contradict the corrected rule mirrors until the recorded follow-up lands.
3. Bare `npx jest` bypasses the `run-jest.cjs` flag-alias rewrite (`--testPathPattern` → `--testPathPatterns`), so an agent using Jest 29 flag names with the newly allowlisted form will get a flag error; the caveat is documented in the spec and evidence but not in the corrected instruction text itself.

**PR readiness recommendation:** **Go** — all toolchain gates pass on independent re-run, all six mirror pairs are byte-identical, the regression module demonstrably failed pre-fix and passes post-fix, and no blocking findings exist.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/other/npx-jest-resolution.2026-07-26T00-58.md` | Part 2, `npx jest --version` bullet | The artifact records resolved Jest version `30.4.1` and asserts it "satisfies the declared `^30.4.2` range constraint family." Semver `^30.4.2` requires >= 30.4.2 < 31; 30.4.1 does not satisfy it. | Note-only for this branch. The installed-version drift belongs to the sibling orchestration that owns `package.json`; a future `npm install` reconciles it. Do not edit the frozen evidence artifact. | Evidence artifacts should not overstate what was verified. The artifact's substantive conclusion (the `npx jest` command form resolves and executes; `npx vitest` does not) remains correct and was the point of the task. | Reviewer read of the artifact; semver semantics of `^30.4.2`; `package.json:` `"jest": "^30.4.2"`. |
| Info | `.claude/rules/typescript.md` | line 57 (and `.claude/rules/general-unit-test.md:40`, `.agents/skills/general-unit-test/SKILL.md:45`) | `.dependency-cruiser.cjs` is named but does not exist anywhere in the repository (reviewer glob: no matches). Deliberately left unfixed per plan hard constraint 5. | File the separate issue named in spec `## Rollout & Follow-up` promptly after merge. | Distinct accuracy defect, correctly excluded from this feature's adjudicated scope; leaving it unfixed here is defensible, but only if the follow-up filing actually happens. | `evidence/other/adjacent-finding-dependency-cruiser.2026-07-26T00-58.md`; reviewer glob `**/.dependency-cruiser.cjs` → no files. |
| Info | `README.md` | lines 303, 318 | README still describes the TypeScript toolchain as Vitest ("Vitest (Jest in the bundled extension)" and "### TypeScript (Prettier → ESLint → tsc → Vitest)"). Outside the research-adjudicated owned file set. | Address in the recorded planner-optional follow-up. | Same reader-facing inaccuracy class as the fixed defect; defensible deferral given scope adjudication, but it now contradicts the corrected mirrors. | Reviewer grep of `README.md`; spec `## Rollout & Follow-up`. |
| Info | root `package.json` / `extensions/drm-copilot/package.json` | package `name` fields | Pre-existing `jest-haste-map` naming collision (both packages named `drm-copilot`) emits a warning under bare `npx jest`. Not touched by this branch; both manifests are sibling-orchestration-owned. | No action in this branch. | Warning-only baseline behavior; fixing it here would violate the prohibited-file constraint. | `evidence/other/npx-jest-resolution.2026-07-26T00-58.md` Part 2. |
| Info | `.claude/rules/typescript.md` | line 51 vicinity | The corrected text does not carry the spec-documented caveat that bare `npx jest` bypasses the `run-jest.cjs` `--testPathPattern` alias rewrite (Jest 30 flag names required). The named commands (`npm run test:unit`, `npm run test:unit:coverage`) go through the wrapper, so the instruction text as written is accurate. | Optional future enhancement; no change required. | The caveat matters only for the bare `npx jest` form allowlisted in `atomic-executor.md`; recorded in spec Risks and the resolution evidence. | `spec.md` Assumptions; `evidence/other/npx-jest-resolution.2026-07-26T00-58.md` flag-name note. |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The regression module follows the established live-tree contract-test precedent (`test_codex_orchestration_contracts.py`) instead of inventing a new pattern: `REPO_ROOT` from `__file__`, UTF-8 reads, required/forbidden token assertions.
- The transitive-parity design decision — asserting only the six repo-root mirrors and letting the two push-down parity tests extend the guarantee to the bundles — avoids twelve duplicate assertions and is documented in the module docstring.
- The semantic-anchor tests close a real gap a pure existence check would miss: `npm run test` resolves (to `vscode-test`) but is semantically wrong for unit tests. `test_typescript_rule_testing_line_names_the_unit_test_command` asserts both the presence of `` `npm run test:unit` `` and the absence of `` `npm run test` `` on the Testing line.
- `find_unique_line` asserts exactly one marker match, so structural drift in the rule file fails loudly rather than silently anchoring to the wrong line.

#### Typing and API notes

- Fully annotated, including `re.Pattern[str]` and `frozenset[str]` returns. The untyped-JSON boundary in `read_root_package_script_names` is handled with `isinstance` assertions plus explicit `cast` and an explanatory comment — no `Any`, Pyright-clean.
- No new public Python API surface was added; all helpers are module-internal to the test file.

#### Error handling and logging

- Shape violations (non-object `package.json`, missing `scripts`) fail with specific assertion messages, appropriate for test code. No broad exception handling, no `print`, no logging needed.

### Markdown/instruction-content audit (primary change surface)

- **Fix direction is correct.** The canonical `.github/instructions/typescript-unit-test.instructions.md` mandates Jest (line 24), uses `jest.spyOn`/`jest.mock`/`jest.resetAllMocks`/`jest.useFakeTimers` (lines 82–94), and approves `npm run test:unit` (line 110). Nothing under `.github/instructions/` was modified (verified against the full diff file list). Every correction flows canon-to-mirror.
- **Command accuracy verified against root `package.json`:** `format`, `lint`, `typecheck`, `test:unit` (`node run-jest.cjs`), `test:unit:coverage` (`node run-jest.cjs --coverage`) all exist; `npm run test` (→ `vscode-test`) and the nonexistent `npm run test:coverage` no longer appear anywhere in `.claude/rules/typescript.md`. The line-51 replacement text "(the root `package.json` script runs `node run-jest.cjs --coverage`)" is factually accurate.
- **Runtime contract change is sound.** `Bash(npx jest *)` in `atomic-executor.md` line 18: the pre-implementation gate hook (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:67`) already recognizes the family `npx (prettier|eslint|tsc|jest)`; Jest `^30.4.2` is a declared root devDependency; `jest.config.cjs` exists at the repo root; the executor evidence shows `npx jest --listTests` exits 0. The replaced `npx vitest` had no resolvable binary (no Vitest dependency exists), so the previous allowlist entry was dead.
- **Parity integrity verified independently:** SHA-256 hashes of all six repo-root/bundled pairs are identical (see policy audit Section 7), a stronger check than the parity tests' universal-newline text comparison, satisfying the plan's byte-wise requirement.

---

## Test Quality Audit

Automated evidence is complete: baseline and final toolchain runs, fail-before/pass-after regression capture, per-pair parity confirmation after each edit, coverage delta with numeric values, and end-state changed-file verification. The reviewer reproduced every executor-claimed terminal result (2138 passed; 28-test targeted selection; Black/Ruff/Pyright clean; lcov totals 91.00%/81.84%). No gaps remain.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` — 15 cases; verifies framework-token absence in six mirrors, `npm run` resolution, and two semantic anchors. Fast (0.05s), deterministic, no mocks needed.
- `evidence/regression-testing/fail-before.2026-07-26T00-58.md` — 12 of 15 cases failing against the pre-fix tree at exactly the spec-named lines, EXIT_CODE 1. Reviewer corroborated the pre-fix defect content at the merge base via `git show fb483b84:.claude/rules/typescript.md` (Vitest at lines 16, 42, 51, 73). Proves the assertions are live, not vacuous.
- `evidence/regression-testing/pass-after.2026-07-26T00-58.md` — 15 of 15 passing post-fix; delta table against fail-before.
- `evidence/other/parity-after-p2-t1..t6.2026-07-26T00-58.md` — parity test run after each of the six paired edits.
- `evidence/qa-gates/final-parity-and-regression.2026-07-26T01-08.md` — 17 tests (both parity tests plus the module) passing after the repo-wide Black pass, confirming final QA did not disturb parity.
- `evidence/qa-gates/coverage-delta.2026-07-26T01-08.md` — numeric baseline/post-change comparison, zero delta, explicit PASS verdict with new-code rationale.
- `evidence/qa-gates/end-state-changed-files.2026-07-26T01-12.md` — post-QA changed-file set re-verification; no out-of-scope path.

### Quality assessment prompts

- **Determinism:** Pure reads of checked-in files; no time, randomness, network, environment variables, or temp files. Identical results across reviewer re-runs.
- **Isolation:** One property per test function; parametrization gives per-file failure attribution.
- **Speed:** Full suite 3.52s (reviewer run); new module 0.05s.
- **Diagnostics:** Assertion messages name the file, offending lines with line numbers, and the policy rationale (demonstrated concretely in the fail-before capture).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff contains only Markdown text, one pytest module, and evidence docs; no credentials, tokens, or `.env` content. |
| No unsafe subprocess or command construction | ✅ PASS | The new test module spawns no subprocess. The allowlist change swaps one `npx` tool name for another within the same scoped-pattern mechanism already recognized by the enforcement hook. |
| Input validation at boundaries | ✅ PASS | `read_root_package_script_names` validates JSON shape before use; `find_unique_line` enforces single-match structure. |
| Error handling remains explicit | ✅ PASS | Assertions with specific messages; no silent fallbacks. |
| Configuration / path handling is safe | ✅ PASS | `REPO_ROOT = Path(__file__).resolve().parents[3]` is CWD-independent; all paths are repo-relative constants; no writes. |
| Agent-permission surface change reviewed | ✅ PASS | `Bash(npx jest *)` replaces a dead `Bash(npx vitest *)` entry; scope breadth is equivalent (single tool wildcard), the target binary is the repository's sanctioned unit-test runner, and the hook already treats `npx jest` as an implementation command. No privilege widening. |

---

## Research Log

No external research was required. All adjudication questions were answered from repository sources: the canonical `.github/instructions/` policy files, root `package.json`, `jest.config.cjs` (existence), the enforcement hook, the feature research artifact, and the executor evidence. Semver interpretation of `^30.4.2` (for the Minor finding) is standard npm range semantics.

---

## Verdict

The change is ready for the normal PR flow. It fixes a real runtime-affecting divergence (a dead `npx vitest` allowlist entry and Jest-incompatible test-authoring instructions), does so in the sanctioned canon-to-mirror direction, and locks the corrected state with a regression module whose assertions are proven live by fail-before evidence. All twelve mirror files are byte-identical in pairs, all prohibited files are untouched, and the full Python toolchain passes on independent re-execution with coverage exactly at baseline. The three deliberately-unfixed adjacent items are each defensible under the adjudicated scope and are recorded for follow-up; none blocks this merge. The only finding above Info severity is a wording inaccuracy inside one frozen evidence artifact, which requires no change to the branch.

Recommendation: **Go.**
