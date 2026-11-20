# Acceptance Criteria Verification — AC1 through AC17

Timestamp: 2026-07-26T01-28

Task: [P4-T13]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Work Mode: full-bug — `spec.md` is the sole acceptance-criteria source (`user-story.md` intentionally
absent by design)
AC Source: `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/spec.md` →
`## Acceptance Criteria` (17 checkbox items)

`<FEATURE>` = `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423`

---

## AC1 — testMatch values and shape contract

Criterion: root exports `["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]`,
extension exports `["**/test/**/*.test.ts"]`; no entry contains `<rootDir>` or a backslash.

Verifying artifacts:
- `<FEATURE>/evidence/other/config-diff.2026-07-26T01-03.md` — loaded-config inspection shows root
  `testMatch` = the exact two-element array and extension `testMatch` = the exact one-element array;
  per-entry checks report `isString: true | hasRootDir: false | hasBackslash: false |
  startsWithGlobstar: true` for all three entries.
- `<FEATURE>/evidence/other/regression-test-review.2026-07-26T01-12.md` — group-1 shape-guard
  assertions present in both test files.
- `<FEATURE>/evidence/qa-gates/final-root-test.2026-07-26T01-20.md` and
  `final-extension-test.2026-07-26T01-23.md` — those shape assertions execute green.

**Verdict: PASS**

---

## AC2 — No `roots` change; adjacent keys byte-identical to base

Criterion: neither config adds/modifies `roots`; `testPathIgnorePatterns`, `collectCoverageFrom`,
`coverageThreshold`, `coverageDirectory`, and the ts-jest `tsconfig` references unchanged from
`fb483b84`.

Verifying artifact: `<FEATURE>/evidence/other/config-diff.2026-07-26T01-03.md` —
`git diff fb483b84 -- jest.config.cjs extensions/drm-copilot/jest.config.cjs` produces exactly two
hunks, three lines replaced, touching only `testMatch` array elements. `roots` is `undefined` in both
loaded config objects (key never introduced). A key-by-key table records every named option as
unchanged.

**Verdict: PASS**

---

## AC3 — Fail-before evidence captured

Criterion: outputs of root `node run-jest.cjs` and `npm --prefix extensions/drm-copilot run test`
against the unfixed configs, each showing `No tests found, exiting with code 1` with 0 matches,
stored under `<FEATURE>/evidence/regression-testing/`.

Verifying artifacts:
- `<FEATURE>/evidence/regression-testing/fail-before-root-jest.2026-07-26T00-55.md` — EXIT_CODE 1,
  `No tests found, exiting with code 1`, 435 files checked, `testMatch: ... - 0 matches`, escaped
  `drm-copilot\.claude` byte pair visible in the reported pattern.
- `<FEATURE>/evidence/regression-testing/fail-before-extension-jest.2026-07-26T00-56.md` — EXIT_CODE
  1, same diagnostic, 368 files checked (matching the spec exactly), 0 matches.

Both captured in Phase 0, **before** any fix was applied (plan ordering enforced: [P0-T3]/[P0-T4]
precede [P1-T1]).

**Verdict: PASS**

---

## AC4 — Pass-after evidence captured

Criterion: with the fix applied, root discovers a non-zero suite count matching the on-disk inventory
(expected 171) and the extension discovers a non-zero count (expected 169); both exit 0 with all
tests passing.

Verifying artifacts:
- `<FEATURE>/evidence/regression-testing/pass-after-root-jest.2026-07-26T01-14.md` — EXIT_CODE 0,
  **171 suites passed / 171 total**, **2061 tests passed**. Inventory reconciled by direct
  enumeration: 2 files under `tests/unit/` + 169 under `extensions/drm-copilot/test/` = 171.
- `<FEATURE>/evidence/regression-testing/pass-after-extension-jest.2026-07-26T01-15.md` — EXIT_CODE
  0, **169 suites passed / 169 total**, **2046 tests passed**, matching the 169-file inventory.

Observed counts equal the spec's expected counts exactly.

**Verdict: PASS**

---

## AC5 — Root `--passWithNoTests` rejected

Criterion: exits 1 at the repository root without spawning Jest, prints a stderr message naming the
flag and citing issue #423; captured in the evidence directory.

Verifying artifact: `<FEATURE>/evidence/regression-testing/guard-root.2026-07-26T01-06.md` —
invocation 1, EXIT_CODE 1, stderr
`--passWithNoTests is prohibited in this repository: zero discovered tests must fail (issue #423).`,
single line of output with no Jest run summary and no no-tests diagnostic, proving Jest was not
spawned.

**Verdict: PASS**

---

## AC6 — Extension `--passWithNoTests` rejected

Criterion: same, run from `extensions/drm-copilot/`.

Verifying artifact: `<FEATURE>/evidence/regression-testing/guard-extension.2026-07-26T01-07.md` —
invocation 1, EXIT_CODE 1, identical message content, no Jest output. In this entry point the guard
precedes `require.resolve("jest/bin/jest")` as well as `cp.spawnSync(...)`.

**Verdict: PASS**

---

## AC7 — Both entry points also reject `--onlyChanged` and `--lastCommit`

Criterion: exit 1 with a message citing issue #423; each flag invoked once per entry point and
captured.

Verifying artifacts:
- `<FEATURE>/evidence/regression-testing/guard-root.2026-07-26T01-06.md` — invocations 2 and 3,
  both EXIT_CODE 1, messages naming `--onlyChanged` and `--lastCommit` respectively and citing
  issue #423.
- `<FEATURE>/evidence/regression-testing/guard-extension.2026-07-26T01-07.md` — invocations 2 and 3,
  same results.

Four invocations total across the two entry points; six including the AC5/AC6 cases.

**Verdict: PASS**

---

## AC8 — Guard is inline; rewrite and exit-code propagation unchanged

Criterion: no new helper module; `--testPathPattern` → `--testPathPatterns` rewrite and exit-code
propagation unchanged. Verified by review of the diff.

Verifying artifact: `<FEATURE>/evidence/other/run-jest-diff.2026-07-26T01-05.md` — the diff comprises
18 added lines per file, 0 removals, no `new file mode` hunk. The three `rewrittenArgs` lines appear
as unchanged context (leading space, no `+`/`-`) in both hunks. The exit-propagation code
(`process.exit(runNodeTool(...))` root; `result.error` handling and `process.exit(result.status ?? 1)`
extension) lies entirely outside both hunks. A seven-row review checklist records PASS on each
sub-requirement.

**Verdict: PASS**

---

## AC9 — Root regression test exists, runs, and passes with groups 1–6

Verifying artifacts:
- File: `tests/unit/jest-config-resolution.test.ts` (191 lines).
- `<FEATURE>/evidence/other/regression-test-review.2026-07-26T01-12.md` — assertion-group coverage
  matrix confirms all six groups present, with line citations (group 1 at line 98, group 2 at 131,
  group 3 at 145, group 4 at 159, group 5 at 167, group 6 at 181).
- `<FEATURE>/evidence/regression-testing/pass-after-root-jest.2026-07-26T01-14.md` and
  `<FEATURE>/evidence/qa-gates/final-root-test.2026-07-26T01-20.md` — the file runs under the root
  Jest project (1 of the 171 discovered suites) and passes; targeted run recorded 14 tests passed.

**Verdict: PASS**

---

## AC10 — Extension regression test exists, runs, and passes with groups 1–6

Verifying artifacts:
- File: `extensions/drm-copilot/test/jest-config-resolution.test.ts` (164 lines).
- `<FEATURE>/evidence/other/regression-test-review.2026-07-26T01-12.md` — all six groups present
  (group 1 at line 92, group 2 at 122, group 3 at 130, group 4 at 138, group 5 at 146, group 6 at
  154).
- `<FEATURE>/evidence/regression-testing/pass-after-extension-jest.2026-07-26T01-15.md` and
  `<FEATURE>/evidence/qa-gates/final-extension-test.2026-07-26T01-23.md` — runs under the extension
  Jest project (1 of the 169 discovered suites) and passes; targeted run recorded 11 tests passed.

**Verdict: PASS**

---

## AC11 — Each configured pattern individually asserted

Criterion: per-pattern assertions via `globsToMatcher([pattern])` against both a dot-prefixed Windows
path and a POSIX path, so a partial collapse of one pattern fails the test.

Verifying artifact: `<FEATURE>/evidence/other/regression-test-review.2026-07-26T01-12.md` § AC11 —
a call-site table lists six single-element matcher constructions in the root test (lines 133, 139,
147, 153, 169, 175), covering both root patterns separately in the Windows-positive, POSIX-positive,
and negative cases. Every matcher is built from a one-element array, never from the full
`config.testMatch`. The extension test applies the same pattern to its single configured entry.
Group 1 additionally deep-equals `config.testMatch` against the exact expected array, catching
addition, removal, or reordering.

**Verdict: PASS**

---

## AC12 — Defect-witness assertion present in both files

Verifying artifact: `<FEATURE>/evidence/other/regression-test-review.2026-07-26T01-12.md` § AC12 —
`DEFECTIVE_PATTERN` at root line 94 and extension line 88, each a hard-coded literal containing the
retained `\\.` (one runtime backslash-dot byte pair), each asserted `.toBe(false)` against the
corresponding group-2 synthetic path. The hard-coded value matches the pattern text Jest actually
reported in the fail-before capture (`drm-copilot\.claude`), and is independent of the current config
so it pins picomatch's escaped-dot semantics against future Jest changes.

**Verdict: PASS**

---

## AC13 — Jest + `@jest/globals`; no filesystem/temp/process usage beyond the config `require`

Verifying artifact: `<FEATURE>/evidence/other/regression-test-review.2026-07-26T01-12.md` § AC13 —
a seven-row sub-requirement table, all PASS. Line 1 of each file imports from `@jest/globals`; no
Vitest reference exists (and neither package installs Vitest). A grep for `readFile`, `writeFile`,
`mkdir`, `mkdtemp`, `existsSync`, `fs.`, `os.tmpdir`, `spawn`, `exec`, and `require(` returned only
the two config `require` calls (root line 32, extension line 37); all other hits were comment prose.
Neither file imports `node:fs`, `node:os`, `node:path`, or `node:child_process`. All matcher inputs
are module-level `const` string fixtures. The single suppression (extension line 36) matches the
pre-authorized `// eslint-disable-next-line <rule> -- <reason>` pattern and has precedent at
`extension-test-harness.ts:193` and `runtime-test-helpers.ts:86,99`.

**Verdict: PASS**

---

## AC14 — Loudness config guard (group 6) in both files

Verifying artifact: `<FEATURE>/evidence/other/regression-test-review.2026-07-26T01-12.md` § AC14 —
`expect(config.passWithNoTests).toBeFalsy()` and
`expect(config.testPathIgnorePatterns).toContain("/node_modules/")` / `.toContain("/out/")` present
in group 6 of both files. Independently corroborated by the loaded-config inspection in
`<FEATURE>/evidence/other/config-diff.2026-07-26T01-03.md`
(`root.passWithNoTests: undefined | ext.passWithNoTests: undefined`).

**Verdict: PASS**

---

## AC15 — Full toolchain pass, root package, single pass

Criterion: `npm run format:check`, `npm run lint`, `npm run typecheck`, and `node run-jest.cjs` all
succeed in a single pass.

Verifying artifacts (all EXIT_CODE 0):
- `<FEATURE>/evidence/qa-gates/final-root-format.2026-07-26T01-18.md`
- `<FEATURE>/evidence/qa-gates/final-root-lint.2026-07-26T01-18.md`
- `<FEATURE>/evidence/qa-gates/final-root-typecheck.2026-07-26T01-19.md`
- `<FEATURE>/evidence/qa-gates/final-root-test.2026-07-26T01-20.md` (171 suites / 2061 tests)
- `<FEATURE>/evidence/qa-gates/final-loop-summary.2026-07-26T01-27.md` — **0 loop restarts**; all
  four root commands belong to one uninterrupted pass.

**Verdict: PASS**

---

## AC16 — Full toolchain pass, extension package, single pass

Criterion: `npm --prefix extensions/drm-copilot run format` leaves no diff, and `lint`, `typecheck`,
`test` all succeed in a single pass.

Verifying artifacts (all EXIT_CODE 0):
- `<FEATURE>/evidence/qa-gates/final-extension-format.2026-07-26T01-21.md` — formatter rewrote zero
  files (all 358 entries `(unchanged)`); `git status --porcelain` captures taken before and after are
  byte-identical.
- `<FEATURE>/evidence/qa-gates/final-extension-lint.2026-07-26T01-22.md`
- `<FEATURE>/evidence/qa-gates/final-extension-typecheck.2026-07-26T01-22.md`
- `<FEATURE>/evidence/qa-gates/final-extension-test.2026-07-26T01-23.md` (169 suites / 2046 tests)
- `<FEATURE>/evidence/qa-gates/final-extension-coverage.2026-07-26T01-24.md` (96.34% statements /
  89.22% branches / 89.51% functions / 96.34% lines; all 30 per-file thresholds passed)
- `<FEATURE>/evidence/qa-gates/final-loop-summary.2026-07-26T01-27.md` — **0 loop restarts**.

**Verdict: PASS**

---

## AC17 — No forbidden file modified; changed-file set limited to the six in-scope files plus feature docs

Verifying artifact: `<FEATURE>/evidence/qa-gates/scope-check.2026-07-26T01-26.md` — combined
inventory from `git diff --name-only fb483b84` and `git status --porcelain --untracked-files=all`
(37 entries). The 6 in-scope files are all present (4 modified, 2 untracked additions); the remaining
31 entries are feature-folder documentation and evidence under `<FEATURE>/**`, with all evidence in
canonical `evidence/<kind>/` sub-paths. A forbidden-pattern table records zero matches for root
`package.json`, `tsconfig*.json`, `.vscode-test.*`, `.claude/rules/**`, `.agents/skills/**`, and
`extensions/drm-copilot/resources/claude-customizations/**`. Gitignored
`extensions/drm-copilot/coverage/` is absent (confirmed via `git check-ignore -v`) and needs no
exception.

Note: the criterion text names `git diff --name-only fb483b84...HEAD`. That form alone would be
insufficient here because this plan performs no commit, so the four source modifications and both new
test files are uncommitted. The scope check therefore used the two-command form
(`git diff --name-only fb483b84` plus `git status --porcelain --untracked-files=all`), which is a
strict superset of the criterion's inventory and enumerates committed changes, uncommitted tracked
modifications, and untracked additions. The criterion's substance — no forbidden file present,
changed set limited to the six in-scope files plus feature documentation — is verified against the
larger inventory.

**Verdict: PASS**

---

## Summary Table

| AC | Subject | Verdict | Primary artifact |
|---|---|---|---|
| AC1 | testMatch values + shape contract | PASS | `evidence/other/config-diff.2026-07-26T01-03.md` |
| AC2 | No `roots`; adjacent keys unchanged | PASS | `evidence/other/config-diff.2026-07-26T01-03.md` |
| AC3 | Fail-before evidence | PASS | `evidence/regression-testing/fail-before-{root,extension}-jest.*.md` |
| AC4 | Pass-after evidence (171 / 169) | PASS | `evidence/regression-testing/pass-after-{root,extension}-jest.*.md` |
| AC5 | Root `--passWithNoTests` rejected | PASS | `evidence/regression-testing/guard-root.2026-07-26T01-06.md` |
| AC6 | Extension `--passWithNoTests` rejected | PASS | `evidence/regression-testing/guard-extension.2026-07-26T01-07.md` |
| AC7 | `--onlyChanged` / `--lastCommit` rejected, both entry points | PASS | `evidence/regression-testing/guard-{root,extension}.*.md` |
| AC8 | Guard inline; rewrite + exit propagation unchanged | PASS | `evidence/other/run-jest-diff.2026-07-26T01-05.md` |
| AC9 | Root regression test, groups 1–6 | PASS | `evidence/other/regression-test-review.2026-07-26T01-12.md` |
| AC10 | Extension regression test, groups 1–6 | PASS | `evidence/other/regression-test-review.2026-07-26T01-12.md` |
| AC11 | Per-pattern individual assertions | PASS | `evidence/other/regression-test-review.2026-07-26T01-12.md` |
| AC12 | Defect-witness assertion, both files | PASS | `evidence/other/regression-test-review.2026-07-26T01-12.md` |
| AC13 | Jest/`@jest/globals`; no fs/temp/process | PASS | `evidence/other/regression-test-review.2026-07-26T01-12.md` |
| AC14 | Loudness config guard, both files | PASS | `evidence/other/regression-test-review.2026-07-26T01-12.md` |
| AC15 | Root toolchain, single pass | PASS | `evidence/qa-gates/final-loop-summary.2026-07-26T01-27.md` |
| AC16 | Extension toolchain, single pass | PASS | `evidence/qa-gates/final-loop-summary.2026-07-26T01-27.md` |
| AC17 | No forbidden file modified | PASS | `evidence/qa-gates/scope-check.2026-07-26T01-26.md` |

**17 of 17 acceptance criteria PASS. 0 PARTIAL. 0 FAIL. 0 UNVERIFIED.**

All 17 checkboxes in `<FEATURE>/spec.md` → `## Acceptance Criteria` are checked off accordingly.

Output Summary: PASS. Every one of the 17 acceptance criteria in `spec.md` maps to at least one
schema-valid evidence artifact under `<FEATURE>/evidence/<kind>/` and evaluates to PASS. No criterion
is PARTIAL, FAIL, or UNVERIFIED, so no checkbox is left unchecked and the plan outcome is not
remediation-required.
