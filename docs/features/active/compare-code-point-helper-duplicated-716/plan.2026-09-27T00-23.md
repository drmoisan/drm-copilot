# compare-code-point-helper-duplicated (Plan)

- **Issue:** #716
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T00-45
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Sole AC source:** `docs/features/active/compare-code-point-helper-duplicated-716/spec.md` (`## Acceptance Criteria`, AC1-AC10 below). `issue.md`'s own AC checklist is not the checkoff target for this plan.

**Fail-closed evidence rule:** Every baseline, detection, and final-QA artifact named below must exist with the required schema fields before its owning checklist item is marked `[x]`. A missing or incomplete artifact leaves the item `[ ]` and blocks Phase 4 AC checkoff for the AC(s) it backs.

**Evidence location rule:** All evidence artifacts are written under `docs/features/active/compare-code-point-helper-duplicated-716/evidence/<kind>/` (canonical scheme). No artifact is written under `artifacts/baselines/`, `artifacts/qa/`, or any other non-canonical path. `<timestamp>` in filenames below is the literal execution time in `yyyy-MM-ddTHH-mm` format, filled in by the executor.

**Merge-order independence (D7):** Every removal/import edit in Phase 2 is anchored on literal text (the full JSDoc+function-body text, or an existing import line), never on a line number. A file that no longer contains the anchor text at execution time (because a sibling branch already consolidated it) is treated as already satisfied for that file's task — mark it `[x]` with a one-line note "already satisfied at execution time; no local copy found" instead of applying an edit.

**Scope:** `extensions/drm-copilot/src/lib/pr-context/` only (spec.md Scope & Non-Goals, D6). The differently-named comparator copies under `codex-native-converter/` and `push-down/` are explicitly out of scope and are not touched by any task below.

**No new dependency (D4):** No task in this plan modifies `extensions/drm-copilot/package.json` or `extensions/drm-copilot/package-lock.json`. The property-based test (Phase 3) is a deterministic enumerative Jest test using only `@jest/globals`, already a declared devDependency.

---

### Phase 0 — Policy Reads & Toolchain Baseline

- [ ] [P0-T1] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/architecture-boundaries.md`, and `.claude/rules/plan-acceptance-gates.md` (`CLAUDE.md` is auto-loaded and does not require a separate read task). Write `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:` (the exact list above, in order), and the explicit list of files read.
  - Acceptance: the artifact file exists and contains all three required fields plus the seven-file list.

- [ ] [P0-T2] Capture the baseline Prettier check. Run `npx prettier --check "src/lib/pr-context/*.ts" "test/lib/pr-context/models.test.ts"` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/prettier-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (Prettier's known check-mode success line is `All matched files use Prettier code style!` at exit code `0`; a drift run instead lists the offending file paths and exits `1` — record whichever the run actually prints).
  - Acceptance: artifact exists with all four fields populated from the actual run.

- [ ] [P0-T3] Capture the baseline ESLint check. Run `npx eslint --no-error-on-unmatched-pattern src test` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/eslint-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (ESLint prints no output and exits `0` on a clean run; a failing run prints a problem list and exits `1`).
  - Acceptance: artifact exists with all four fields populated from the actual run.

- [ ] [P0-T4] Capture the baseline TypeScript type-check. Run `npx tsc -p ./ --noEmit` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/tsc-typecheck.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (`tsc` prints no output and exits `0` on a clean run).
  - Acceptance: artifact exists with all four fields populated from the actual run.

- [ ] [P0-T5] Capture baseline Jest coverage for the full suite. Run `npx jest --coverage --coverageReporters=text --coverageReporters=lcov` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/jest-coverage.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing: the printed `Test Suites:` and `Tests:` summary lines, and the printed per-file coverage row for `models.ts` (its `% Lines` and `% Branch` values as printed by the `text` reporter) as the numeric baseline for AC9.
  - Acceptance: artifact exists with all four fields and the `models.ts` row's numeric Lines/Branch values recorded.

---

### Phase 1 — Duplicate Detection

- [ ] [P1-T1] Run `git grep -n "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context` from the repository root. Record the full matched-file list to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/compare-code-point-detection.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing, for each of the eight named files (`collector-core.ts`, `autoclose.ts`, `feature-docs-parsers.ts`, `gh-client-details.ts`, `render.ts`, `render-pr-helpers.ts`, `render-feature-excerpts.ts`, `verification-evidence.ts`), whether it matched (private copy present) or did not match (already satisfied). `git grep` exits `0` when at least one match exists.
  - Acceptance: artifact exists, command executed, and the per-file present/absent list covers all eight named files. Phase 2 tasks P2-T2 through P2-T9 each read this artifact to decide whether their edit applies or the file is a no-op.

---

### Phase 2 — Consolidate `compareCodePoint` into `models.ts`

- [ ] [P2-T1] In `extensions/drm-copilot/src/lib/pr-context/models.ts`, append the following immediately after the closing brace of the existing `formatList` function (the last export in the file today, ending `return valuesList.map((item) => \`- ${item}\`).join("\n");` then `}`), separated by one blank line:
  ```ts
  /** Compare two strings by Unicode code point (Python `sorted` semantics). */
  export function compareCodePoint(left: string, right: string): number {
    if (left < right) {
      return -1;
    }
    if (left > right) {
      return 1;
    }
    return 0;
  }
  ```
  - Acceptance: `git grep -c "export function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/models.ts` returns `1`.

- [ ] [P2-T2] In `extensions/drm-copilot/src/lib/pr-context/collector-core.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment `/** Compare two strings by Unicode code point (Python \`sorted\` semantics). */` and the immediately following function body (`function compareCodePoint(left: string, right: string): number { ... return 0; }`), and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `type FeatureDocExcerpt,` / `type IssueDetails,` / `type PrContextResult,` / `type PullRequestDetails,` / `type ScopingDocChange,`). If P1-T1 shows no match, mark this task `[x]` with the note "already satisfied at execution time; no local copy found" and make no edit.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/collector-core.ts` produces no output and exits with code `1` (no match), and `git grep -n "compareCodePoint" -- extensions/drm-copilot/src/lib/pr-context/collector-core.ts` shows it appears in the `from "./models"` import block.

- [ ] [P2-T3] In `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment `/** Compare two strings by Unicode code point (Python \`sorted\` semantics). */` and the immediately following function body, and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `AUTOCLOSE_PENDING_NOT_OPEN_TEXT,` / `AUTOCLOSE_UNVERIFIED_ANNOTATION,` / `type IssueDetails,` / `formatList,` / `normalizeReference,` / `section,`). If no match, mark `[x]` with the "already satisfied" note and make no edit.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/autoclose.ts` produces no output and exits with code `1` (no match), and the `from "./models"` import block contains `compareCodePoint`.

- [ ] [P2-T4] In `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following `export function compareCodePoint(left: string, right: string): number { ... return 0; }` body, and (b) change the existing line `import { ISSUE_REFERENCE_PATTERN, splitLines } from "./models";` to `import { ISSUE_REFERENCE_PATTERN, compareCodePoint, splitLines } from "./models";`. If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "export function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts` produces no output and exits with code `1` (no match), and `git grep -c "import { ISSUE_REFERENCE_PATTERN, compareCodePoint, splitLines } from \"./models\";" -- extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts` returns `1`.

- [ ] [P2-T5] In `extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following `export function compareCodePoint(left: string, right: string): number { ... return 0; }` body, and (b) change the existing line `import { findUserStoryLink } from "./models";` to `import { compareCodePoint, findUserStoryLink } from "./models";` (this file has a second, separate `import { type IssueDetails, type PullRequestDetails } from "./models";` line — leave it untouched). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "export function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts` produces no output and exits with code `1` (no match), and `git grep -c "import { compareCodePoint, findUserStoryLink } from \"./models\";" -- extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts` returns `1`.

- [ ] [P2-T6] In `extensions/drm-copilot/src/lib/pr-context/render.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following function body, and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `type PrContextResult,` / `type PullRequestDetails,` / `normalizeReference,` / `section,`). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/render.ts` produces no output and exits with code `1` (no match), and the `from "./models"` import block contains `compareCodePoint`.

- [ ] [P2-T7] In `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following function body, and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `CONVENTIONAL_TYPES,` / `ISSUE_REFERENCE_PATTERN,` / `type IssueDetails,` / `type PullRequestDetails,` / `formatList,` / `section,` / `truncate,`). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts` produces no output and exits with code `1` (no match), and the `from "./models"` import block contains `compareCodePoint`.

- [ ] [P2-T8] In `extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following function body, and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `type FeatureDocExcerpt,` / `ISSUE_REFERENCE_PATTERN,` / `section,` / `splitLines,` / `truncate,`). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts` produces no output and exits with code `1` (no match), and the `from "./models"` import block contains `compareCodePoint`.

- [ ] [P2-T9] In `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following function body, and (b) insert a new line `import { compareCodePoint } from "./models";` immediately after the file's sole existing import line `import { type FileSystem, toPosixPath } from "../file-system";` (this file has no pre-existing `./models` import). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` produces no output and exits with code `1` (no match), and `git grep -c "import { compareCodePoint } from \"./models\";" -- extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` returns `1`.

- [ ] [P2-T10] In `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts`: if the existing import block `import { compareCodePoint, completedPlanTasks, extractIssueReferences, latestGlobPath, parsePrimaryIssueFromMetadata, parseSection, readText, relativeToPosix, resolveFeatureDir, resolveReadinessSignal, verificationText, } from "./feature-docs-parsers";` still contains `compareCodePoint,`, (a) remove that line from the block, and (b) change the existing line `import { type FeatureDocExcerpt, section, truncate } from "./models";` to `import { type FeatureDocExcerpt, compareCodePoint, section, truncate } from "./models";`. If the block no longer contains `compareCodePoint,` (a sibling already redirected it), mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "^  compareCodePoint,$" -- extensions/drm-copilot/src/lib/pr-context/feature-docs.ts` exits with code `1` (no line remains at the 2-space import-block indent level — this file also has an unrelated, untouched 4-space-indented `    compareCodePoint,` call-site line inside its own `.sort(...)` call near the end of the file, which is not part of this check and must remain unchanged), and `git grep -c "import { type FeatureDocExcerpt, compareCodePoint, section, truncate } from \"./models\";" -- extensions/drm-copilot/src/lib/pr-context/feature-docs.ts` returns `1`.

---

### Phase 3 — Unit and Property-Based Tests (`models.test.ts`)

- [ ] [P3-T1] In `extensions/drm-copilot/test/lib/pr-context/models.test.ts`: (a) add `compareCodePoint,` as a new first line inside the top import block (currently `findUserStoryLink,` / `formatList,` / `normalizeReference,` / `section,` / `truncate,` / `truncateLines,` from `"../../../src/lib/pr-context/models"`), and (b) append this block after the file's existing final `describe("formatList", ...)` block:
  ```ts
  describe("compareCodePoint", () => {
    it("returns 0 for identical strings", () => {
      expect(compareCodePoint("abc", "abc")).toBe(0);
    });

    it("returns -1 when left sorts before right", () => {
      expect(compareCodePoint("a", "b")).toBe(-1);
    });

    it("returns 1 when left sorts after right", () => {
      expect(compareCodePoint("b", "a")).toBe(1);
    });

    it("treats the empty string as less than a non-empty string", () => {
      expect(compareCodePoint("", "a")).toBe(-1);
    });

    it("is case-sensitive, sorting uppercase before lowercase", () => {
      expect(compareCodePoint("A", "a")).toBe(-1);
    });

    it("orders a prefix before its longer extension", () => {
      expect(compareCodePoint("a", "ab")).toBe(-1);
    });
  });
  ```
  - Acceptance: run `npx jest test/lib/pr-context/models.test.ts --testNamePattern "^compareCodePoint [a-z]"` from `extensions/drm-copilot`; the printed `Tests:` line reads `6 passed, 6 total` and exit code is `0`. (The pattern requires a lowercase letter immediately after `compareCodePoint ` so it cannot also match the `compareCodePoint - enumerative properties ...` describe title added by P3-T2, whose text continues with a hyphen at that position.)

- [ ] [P3-T2] In the same file, append this second block directly after the block added by P3-T1:
  ```ts
  describe("compareCodePoint - enumerative properties over a fixed domain", () => {
    const DOMAIN = ["", "a", "A", "aa", "ab", "b", "ba", "é", "😀"];

    it("is reflexive for every value in the domain", () => {
      for (const value of DOMAIN) {
        expect(compareCodePoint(value, value)).toBe(0);
      }
    });

    it("is antisymmetric for every ordered pair in the domain", () => {
      for (const left of DOMAIN) {
        for (const right of DOMAIN) {
          const forward = compareCodePoint(left, right);
          const backward = compareCodePoint(right, left);
          expect(forward === -backward).toBe(true);
        }
      }
    });

    it("is transitive for every ordered triple in the domain", () => {
      for (const a of DOMAIN) {
        for (const b of DOMAIN) {
          for (const c of DOMAIN) {
            if (compareCodePoint(a, b) <= 0 && compareCodePoint(b, c) <= 0) {
              expect(compareCodePoint(a, c)).toBeLessThanOrEqual(0);
            }
          }
        }
      }
    });

    it("returns only -1, 0, or 1 for every ordered pair in the domain", () => {
      for (const left of DOMAIN) {
        for (const right of DOMAIN) {
          expect([-1, 0, 1]).toContain(compareCodePoint(left, right));
        }
      }
    });

    it("agrees with the native < and > operators for every ordered pair in the domain", () => {
      for (const left of DOMAIN) {
        for (const right of DOMAIN) {
          const result = compareCodePoint(left, right);
          if (left < right) {
            expect(result).toBe(-1);
          } else if (left > right) {
            expect(result).toBe(1);
          } else {
            expect(result).toBe(0);
          }
        }
      }
    });

    it("produces the same order as native comparison via Array.prototype.sort, including an astral surrogate-pair string", () => {
      const sample = ["b", "😀", "a", "é", "", "A", "ab"];
      const expected = [...sample].sort((left, right) =>
        left < right ? -1 : left > right ? 1 : 0,
      );
      expect([...sample].sort(compareCodePoint)).toEqual(expected);
    });
  });
  ```
  Note: `"é"` (U+00E9) is the fixed domain's BMP non-ASCII member; `"😀"` (U+1F600) is the fixed domain's astral surrogate-pair member, satisfying spec.md AC4's domain requirement.
  - Acceptance: run `npx jest test/lib/pr-context/models.test.ts --testNamePattern "enumerative properties"` from `extensions/drm-copilot`; the printed `Tests:` line reads `6 passed, 6 total` and exit code is `0`.

---

### Phase 4 — Final QA Loop, Verification, and Acceptance Criteria Checkoff

- [ ] [P4-T1] Run `npx prettier --check src/lib/pr-context/models.ts src/lib/pr-context/collector-core.ts src/lib/pr-context/autoclose.ts src/lib/pr-context/feature-docs-parsers.ts src/lib/pr-context/gh-client-details.ts src/lib/pr-context/render.ts src/lib/pr-context/render-pr-helpers.ts src/lib/pr-context/render-feature-excerpts.ts src/lib/pr-context/verification-evidence.ts src/lib/pr-context/feature-docs.ts test/lib/pr-context/models.test.ts` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/prettier-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If drift is reported, restart the loop from this task after running `npx prettier --write` on the same file list and re-verifying with `--check`.
  - Acceptance: `EXIT_CODE: 0` and `Output Summary:` records the literal line `All matched files use Prettier code style!`.

- [ ] [P4-T2] Run `npx eslint --no-error-on-unmatched-pattern src test` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/eslint-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0` and `Output Summary:` records "no problems reported" (empty stdout).

- [ ] [P4-T3] Run `npx tsc -p ./ --noEmit` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/tsc-typecheck.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0` and `Output Summary:` records "no diagnostics" (empty stdout).

- [ ] [P4-T4] Run `git grep -c "function compareCodePoint" -- extensions/drm-copilot/src/lib/pr-context` from the repository root. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/structural-uniqueness.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: exactly one output line, `extensions/drm-copilot/src/lib/pr-context/models.ts:1`, and no other file listed. Backs spec.md AC1 and AC2.

- [ ] [P4-T5] Run `npx jest test/lib/pr-context` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/pr-context-regression.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing the printed `Test Suites:` and `Tests:` lines.
  - Acceptance: `EXIT_CODE: 0`, `Test Suites:` line shows `0 failed`, `Tests:` line shows `0 failed`. Backs spec.md AC5 (no changes to expected output in the pre-existing suites).

- [ ] [P4-T6] Run `npx jest test/lib/pr-context/models.test.ts` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/models-test-count.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0` and the printed `Tests:` line reads `32 passed, 32 total` (20 pre-existing + 6 from P3-T1 + 6 from P3-T2). Backs spec.md AC3 and AC4.

- [ ] [P4-T7] Run `npx jest --coverage --coverageReporters=text --coverageReporters=lcov` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/jest-coverage-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing the printed per-file coverage row for `models.ts` (its `% Lines` and `% Branch` values).
  - Acceptance: `EXIT_CODE: 0` (confirms every per-file `coverageThreshold` entry in `jest.config.cjs`, including `models.ts` at `lines: 85, branches: 75`, passes) and the `models.ts` row's Lines/Branch values are recorded.

- [ ] [P4-T8] Compare the `models.ts` Lines/Branch values recorded in P0-T5 (baseline) against those recorded in P4-T7 (final). Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/coverage-delta.<timestamp>.md` with `Timestamp:`, the two numeric pairs, and a explicit statement of whether final >= baseline for both Lines and Branch.
  - Acceptance: final `% Lines` >= baseline `% Lines`, final `% Branch` >= baseline `% Branch`, and both final values are `>= 85` / `>= 75` respectively. Backs spec.md AC9 (no coverage regression on changed lines).

- [ ] [P4-T9] Run `git merge-base HEAD origin/main` from the repository root. Record the resulting commit SHA to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/merge-base-sha.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the printed 40-character SHA).
  - Acceptance: `EXIT_CODE: 0` and a 40-character SHA is recorded.

- [ ] [P4-T10] Run `git diff --exit-code <merge-base-sha-from-P4-T9> -- extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json` from the repository root, substituting the literal SHA recorded in P4-T9. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/dependency-diff-check.<timestamp>.md` with `Timestamp:`, `Command:` (with the substituted SHA), `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0` (no diff output), confirming `package.json` and `package-lock.json` are unchanged relative to the branch point. Backs spec.md AC10. This is a local-execution verification, not a test; it is exempt from the depth-1 CI parity constraint because it runs against a merge-base SHA computed at execution time, not a checked-in test asserting `origin/main`.

- [ ] [P4-T11] Run `wc -l extensions/drm-copilot/src/lib/pr-context/models.ts extensions/drm-copilot/src/lib/pr-context/collector-core.ts extensions/drm-copilot/src/lib/pr-context/autoclose.ts extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts extensions/drm-copilot/src/lib/pr-context/render.ts extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts extensions/drm-copilot/src/lib/pr-context/feature-docs.ts extensions/drm-copilot/test/lib/pr-context/models.test.ts` from the repository root. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/file-size-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (each file's line count).
  - Acceptance: every printed per-file line count is `<= 500`.

- [ ] [P4-T12] In `docs/features/active/compare-code-point-helper-duplicated-716/spec.md`, change the AC1 line `- [ ] A search for \`function compareCodePoint\` under \`extensions/drm-copilot/src/lib/pr-context/\` returns exactly one match, in \`extensions/drm-copilot/src/lib/pr-context/models.ts\`, and it is exported.` to `- [x] ...` (same text), citing P4-T4's evidence artifact.
  - Acceptance: the line now begins `- [x]` and the artifact path from P4-T4 is referenced inline or in a trailing note.

- [ ] [P4-T13] In `spec.md`, change the AC2 line (`- [ ] Every module under ... imports it from \`./models\`; no private copy or independent \`export\` of \`compareCodePoint\` remains outside \`models.ts\`.`) to `- [x] ...`, citing P1-T1 and P4-T4's evidence artifacts.
  - Acceptance: the line now begins `- [x]` with the citations noted.

- [ ] [P4-T14] In `spec.md`, change the AC3 line (`- [ ] The shared helper's body is byte-identical to the pre-existing implementation ...`) to `- [x] ...`, citing P2-T1 (the inserted body matches research section 1.2 verbatim).
  - Acceptance: the line now begins `- [x]` with the citation noted.

- [ ] [P4-T15] In `spec.md`, change the AC4 line (`- [ ] \`compareCodePoint\` is covered by a unit test in ... including a deterministic enumerative property test ...`) to `- [x] ...`, citing P3-T1, P3-T2, and P4-T6.
  - Acceptance: the line now begins `- [x]` with the citations noted.

- [ ] [P4-T16] In `spec.md`, change the AC5 line (`- [ ] The existing \`extensions/drm-copilot/test/lib/pr-context/\` Jest test suites pass unmodified ...`) to `- [x] ...`, citing P4-T5.
  - Acceptance: the line now begins `- [x]` with the citation noted.

- [ ] [P4-T17] In `spec.md`, change the AC6 line (`- [ ] \`tsc\` (TypeScript type-check) passes with zero errors.`) to `- [x] ...`, citing P4-T3.
  - Acceptance: the line now begins `- [x]` with the citation noted.

- [ ] [P4-T18] In `spec.md`, change the AC7 line (`- [ ] ESLint passes with zero errors.`) to `- [x] ...`, citing P4-T2.
  - Acceptance: the line now begins `- [x]` with the citation noted.

- [ ] [P4-T19] In `spec.md`, change the AC8 line (`- [ ] Prettier formatting check passes with no reformatting required.`) to `- [x] ...`, citing P4-T1.
  - Acceptance: the line now begins `- [x]` with the citation noted.

- [ ] [P4-T20] In `spec.md`, change the AC9 line (`- [ ] Jest coverage for \`models.ts\` meets its configured per-file threshold ... with no coverage regression on changed lines ...`) to `- [x] ...`, citing P4-T7 and P4-T8.
  - Acceptance: the line now begins `- [x]` with the citations noted.

- [ ] [P4-T21] In `spec.md`, change the AC10 line (`- [ ] \`extensions/drm-copilot/package.json\` and \`extensions/drm-copilot/package-lock.json\` are unchanged by this fix ...`) to `- [x] ...`, citing P4-T9 and P4-T10.
  - Acceptance: the line now begins `- [x]` with the citations noted.

---

## Acceptance Criteria Cross-Reference (spec.md, sole source, full-bug mode)

| ID | spec.md AC text (abbreviated) | Implementation task(s) | Test/verification task(s) | Evidence artifact |
|---|---|---|---|---|
| AC1 | Exactly one `compareCodePoint` definition, in `models.ts`, exported | P2-T1 | P4-T4 | `evidence/qa-gates/structural-uniqueness.<timestamp>.md` |
| AC2 | Every consumer imports from `./models`; no private copy remains | P2-T2..P2-T10 | P1-T1, P4-T4 | `evidence/baseline/compare-code-point-detection.<timestamp>.md`, `evidence/qa-gates/structural-uniqueness.<timestamp>.md` |
| AC3 | Body byte-identical (code-unit ordering, -1/0/1) | P2-T1 | P3-T1, P4-T6 | `evidence/qa-gates/models-test-count.<timestamp>.md` |
| AC4 | Unit test incl. deterministic enumerative property test | P3-T1, P3-T2 | P3-T1, P3-T2, P4-T6 | `evidence/qa-gates/models-test-count.<timestamp>.md` |
| AC5 | Existing pr-context suites pass unmodified | P2-T1..P2-T10 | P4-T5 | `evidence/qa-gates/pr-context-regression.<timestamp>.md` |
| AC6 | `tsc` passes with zero errors | P2-T1..P2-T10 | P4-T3 | `evidence/qa-gates/tsc-typecheck.<timestamp>.md` |
| AC7 | ESLint passes with zero errors | P2-T1..P2-T10 | P4-T2 | `evidence/qa-gates/eslint-check.<timestamp>.md` |
| AC8 | Prettier check passes, no reformatting required | P2-T1..P2-T10, P3-T1, P3-T2 | P4-T1 | `evidence/qa-gates/prettier-check.<timestamp>.md` |
| AC9 | `models.ts` coverage meets threshold, no regression | P2-T1 | P4-T7, P4-T8 | `evidence/qa-gates/jest-coverage-final.<timestamp>.md`, `evidence/qa-gates/coverage-delta.<timestamp>.md` |
| AC10 | `package.json`/`package-lock.json` unchanged | (no production edit) | P4-T9, P4-T10 | `evidence/qa-gates/merge-base-sha.<timestamp>.md`, `evidence/qa-gates/dependency-diff-check.<timestamp>.md` |

---

## Planner Adversarial Self-Review

SELF-REVIEW: RE-DERIVED THIS PASS

- `extensions/drm-copilot/src/lib/pr-context/models.ts` — lines 328-337 (`formatList` function body and closing brace, the insertion anchor for P2-T1), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` — lines 21-27 (`./models` import block), lines 387-396 (JSDoc + function body to remove), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/src/lib/pr-context/autoclose.ts` — lines 25-32 (`./models` import block), lines 295-304 (JSDoc + function body), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts` — line 18 (`./models` import line), lines 304-313 (JSDoc + exported function body), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts` — lines 18-19 (two separate `./models` import lines), lines 127-136 (JSDoc + exported function body), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/src/lib/pr-context/render.ts` — lines 18-23 (`./models` import block), lines 380-389 (JSDoc + function body), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts` — lines 19-27 (`./models` import block), lines 387-396 (JSDoc + function body), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts` — lines 19-25 (`./models` import block), lines 438-447 (JSDoc + function body), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` — line 21 (sole existing import line, the anchor for the new `./models` import), lines 273-282 (JSDoc + function body), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts` — line 21 (`./models` import line), lines 22-34 (`./feature-docs-parsers` import block containing `compareCodePoint,`), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/test/lib/pr-context/models.test.ts` — lines 1-10 (top import block) and lines 135-147 (final `formatList` describe block and EOF, the append anchor for P3-T1/P3-T2), re-derived by direct `Read` this pass; test count of 20 pre-existing `it` blocks recounted directly from this read (section:1, truncate:3, truncateLines:3, normalizeReference:4, findUserStoryLink:6, formatList:3).
- `extensions/drm-copilot/jest.config.cjs` — lines 25-324 (`coverageThreshold` map), re-derived by direct `Read` this pass; confirmed per-file gates exist for `models.ts`, `collector-core.ts`, `autoclose.ts`, `feature-docs-parsers.ts`, `render-feature-excerpts.ts`, `render-pr-helpers.ts`, and confirmed no entry exists for `gh-client-details.ts`, `render.ts`, `verification-evidence.ts`, or `feature-docs.ts`.
- `extensions/drm-copilot/package.json` — lines 202-213 (`scripts` block: `format`, `lint`, `typecheck`, `test`, `test:coverage`) and lines 228-241 (`devDependencies`, confirming no `fast-check`), re-derived by direct `Read` this pass.
- `extensions/drm-copilot/run-jest.cjs` — full file re-derived by direct `Read` this pass; confirmed it invokes Jest with `--config jest.config.cjs` and rejects `--passWithNoTests`/`--onlyChanged`/`--lastCommit`, none of which this plan's commands use.
- `docs/features/active/compare-code-point-helper-duplicated-716/spec.md` — lines 147-156 (AC1-AC10, the sole checkoff source), re-derived by direct `Read` this pass.
- **Sibling-region check:** re-read the full surrounding function/import context (not just the single anchor line) in every one of the nine `.ts` files above, confirming each file's other call sites of `compareCodePoint` (e.g. `collector-core.ts` lines 199-201 and 384; `render-pr-helpers.ts` lines 151 and 202; `feature-docs-parsers.ts` lines 177 and 273; `feature-docs.ts` lines 99 and 306) remain valid unqualified references after the import redirect, since the imported binding name is unchanged.
- Confirmed via `Grep -c "^"` this pass that every file this plan writes to is currently well under 500 lines (`collector-core.ts` 396, `autoclose.ts` 304, `feature-docs-parsers.ts` 323, `gh-client-details.ts` 398, `render.ts` 410, `render-pr-helpers.ts` 417, `render-feature-excerpts.ts` 452, `verification-evidence.ts` 303, `feature-docs.ts` 308, `models.ts` 337, `models.test.ts` 147), so the net additions/removals in this plan (a ~9-line addition to `models.ts`, a ~12-test/~60-line addition to `models.test.ts`, and net line decreases in the other nine files) leave every touched file under the 500-line cap (P4-T11 re-verifies numerically at execution time).

---

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: extensions/drm-copilot/src/lib/pr-context/models.ts | lines 328-337 (formatList, insertion anchor for P2-T1)
CITATION: extensions/drm-copilot/src/lib/pr-context/collector-core.ts | lines 21-27 (./models import block), lines 387-396 (function to remove)
CITATION: extensions/drm-copilot/src/lib/pr-context/autoclose.ts | lines 25-32 (./models import block), lines 295-304 (function to remove)
CITATION: extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts | line 18 (import line), lines 304-313 (function to remove)
CITATION: extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts | lines 18-19 (two import lines), lines 127-136 (function to remove)
CITATION: extensions/drm-copilot/src/lib/pr-context/render.ts | lines 18-23 (./models import block), lines 380-389 (function to remove)
CITATION: extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts | lines 19-27 (./models import block), lines 387-396 (function to remove)
CITATION: extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts | lines 19-25 (./models import block), lines 438-447 (function to remove)
CITATION: extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts | line 21 (sole import line), lines 273-282 (function to remove)
CITATION: extensions/drm-copilot/src/lib/pr-context/feature-docs.ts | line 21 (./models import line), lines 22-34 (./feature-docs-parsers import block)
CITATION: extensions/drm-copilot/test/lib/pr-context/models.test.ts | lines 1-10 (import block), lines 135-147 (append anchor)
CITATION: extensions/drm-copilot/jest.config.cjs | lines 25-324 (coverageThreshold map)
CITATION: extensions/drm-copilot/package.json | lines 202-213 (scripts), lines 228-241 (devDependencies, no fast-check)
CITATION: extensions/drm-copilot/run-jest.cjs | lines 1-39 (Jest wrapper, --config jest.config.cjs, prohibited-flag guard)
CITATION: docs/features/active/compare-code-point-helper-duplicated-716/spec.md | lines 147-156 (AC1-AC10)
AC-INVENTORY: AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC9, AC10
AC-MAPPING: AC1 | IMPLEMENTATION: P2-T1 | TESTS: P4-T4 | EVIDENCE: evidence/qa-gates/structural-uniqueness.<timestamp>.md
AC-MAPPING: AC2 | IMPLEMENTATION: P2-T2..P2-T10 | TESTS: P1-T1, P4-T4 | EVIDENCE: evidence/baseline/compare-code-point-detection.<timestamp>.md
AC-MAPPING: AC3 | IMPLEMENTATION: P2-T1 | TESTS: P3-T1, P4-T6 | EVIDENCE: evidence/qa-gates/models-test-count.<timestamp>.md
AC-MAPPING: AC4 | IMPLEMENTATION: P3-T1, P3-T2 | TESTS: P3-T1, P3-T2, P4-T6 | EVIDENCE: evidence/qa-gates/models-test-count.<timestamp>.md
AC-MAPPING: AC5 | IMPLEMENTATION: P2-T1..P2-T10 | TESTS: P4-T5 | EVIDENCE: evidence/qa-gates/pr-context-regression.<timestamp>.md
AC-MAPPING: AC6 | IMPLEMENTATION: P2-T1..P2-T10 | TESTS: P4-T3 | EVIDENCE: evidence/qa-gates/tsc-typecheck.<timestamp>.md
AC-MAPPING: AC7 | IMPLEMENTATION: P2-T1..P2-T10 | TESTS: P4-T2 | EVIDENCE: evidence/qa-gates/eslint-check.<timestamp>.md
AC-MAPPING: AC8 | IMPLEMENTATION: P2-T1..P2-T10, P3-T1, P3-T2 | TESTS: P4-T1 | EVIDENCE: evidence/qa-gates/prettier-check.<timestamp>.md
AC-MAPPING: AC9 | IMPLEMENTATION: P2-T1 | TESTS: P4-T7, P4-T8 | EVIDENCE: evidence/qa-gates/jest-coverage-final.<timestamp>.md
AC-MAPPING: AC10 | IMPLEMENTATION: none (no production edit to package.json/package-lock.json) | TESTS: P4-T9, P4-T10 | EVIDENCE: evidence/qa-gates/dependency-diff-check.<timestamp>.md
UNRESOLVED-GAPS: NONE
