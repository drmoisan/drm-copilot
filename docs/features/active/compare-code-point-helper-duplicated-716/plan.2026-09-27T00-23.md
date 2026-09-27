# compare-code-point-helper-duplicated (Plan)

- **Issue:** #716
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T02-15
- **Status:** Draft
- **Version:** 0.4
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

- [ ] [P0-T2] Install pinned dependencies. Run `npm ci` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/npm-ci.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (a clean install prints an `added <N> packages` line; an already-current install prints `up to date`; either is valid). `npm ci` does not modify `package.json` or `package-lock.json` (D4).
  - Acceptance: `EXIT_CODE: 0` and `Output Summary:` records the printed `added ... packages` or `up to date` line.

- [ ] [P0-T3] Capture the baseline Prettier check. Run `npx prettier --check "src/lib/pr-context/*.ts" "test/lib/pr-context/models.test.ts"` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/prettier-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (Prettier's known check-mode success line is `All matched files use Prettier code style!` at exit code `0`; a drift run instead lists the offending file paths and exits `1` — record whichever the run actually prints).
  - Acceptance: artifact exists with all four fields populated from the actual run.

- [ ] [P0-T4] Capture the baseline ESLint check. Run `npx eslint --no-error-on-unmatched-pattern src test` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/eslint-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (ESLint prints no output and exits `0` on a clean run; a failing run prints a problem list and exits `1`).
  - Acceptance: artifact exists with all four fields populated from the actual run.

- [ ] [P0-T5] Capture the baseline TypeScript type-check. Run `npx tsc -p ./ --noEmit` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/tsc-typecheck.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (`tsc` prints no output and exits `0` on a clean run).
  - Acceptance: artifact exists with all four fields populated from the actual run.

- [ ] [P0-T6] Capture baseline Jest coverage for the full suite. Run `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=lcov` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/baseline/jest-coverage.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing: the printed `Test Suites:` and `Tests:` summary lines, and the printed per-file coverage row for `models.ts` (the row under the `src/lib/pr-context` group heading; the table lists three files named `models.ts`), specifically its `% Lines` and `% Branch` values as printed by the `text` reporter, as the numeric baseline for AC9.
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
  - Acceptance: `git grep -c "export function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/models.ts` prints `extensions/drm-copilot/src/lib/pr-context/models.ts:1`.

- [ ] [P2-T2] In `extensions/drm-copilot/src/lib/pr-context/collector-core.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment `/** Compare two strings by Unicode code point (Python \`sorted\` semantics). */` and the immediately following function body (`function compareCodePoint(left: string, right: string): number { ... return 0; }`), and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `type FeatureDocExcerpt,` / `type IssueDetails,` / `type PrContextResult,` / `type PullRequestDetails,` / `type ScopingDocChange,`). If P1-T1 shows no match, mark this task `[x]` with the note "already satisfied at execution time; no local copy found" and make no edit.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/collector-core.ts` produces no output and exits with code `1` (no match), and `git grep -n "compareCodePoint" -- extensions/drm-copilot/src/lib/pr-context/collector-core.ts` shows it appears in the `from "./models"` import block.

- [ ] [P2-T3] In `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment `/** Compare two strings by Unicode code point (Python \`sorted\` semantics). */` and the immediately following function body, and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `AUTOCLOSE_PENDING_NOT_OPEN_TEXT,` / `AUTOCLOSE_UNVERIFIED_ANNOTATION,` / `type IssueDetails,` / `formatList,` / `normalizeReference,` / `section,`). If no match, mark `[x]` with the "already satisfied" note and make no edit.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/autoclose.ts` produces no output and exits with code `1` (no match), and the `from "./models"` import block contains `compareCodePoint`.

- [ ] [P2-T4] In `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following `export function compareCodePoint(left: string, right: string): number { ... return 0; }` body, and (b) change the existing line `import { ISSUE_REFERENCE_PATTERN, splitLines } from "./models";` to the multi-line block (required to stay within Prettier's 80-character `printWidth`):
  ```ts
  import {
    ISSUE_REFERENCE_PATTERN,
    compareCodePoint,
    splitLines,
  } from "./models";
  ```
  If a sibling branch has already changed the `./models` import's member list, add `compareCodePoint` to the existing import in sorted position consistent with the file's current member ordering, rather than replacing the import wholesale. If no match (per P1-T1), mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "export function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts` produces no output and exits with code `1` (no match), and `git grep -c "^  compareCodePoint,$" -- extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts` prints `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:1` (this file also has an unrelated, untouched 4-space-indented `    compareCodePoint,` call-site line inside its own `.sort(...)` call in `resolveReadinessSignal`, which is unaffected by this 2-space anchor and must remain unchanged).

- [ ] [P2-T5] In `extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following `export function compareCodePoint(left: string, right: string): number { ... return 0; }` body, and (b) change the existing line `import { findUserStoryLink } from "./models";` to `import { compareCodePoint, findUserStoryLink } from "./models";` (this file has a second, separate `import { type IssueDetails, type PullRequestDetails } from "./models";` line — leave it untouched). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "export function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts` produces no output and exits with code `1` (no match), and `git grep -c "import { compareCodePoint, findUserStoryLink } from \"./models\";" -- extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts` prints `extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts:1`.

- [ ] [P2-T6] In `extensions/drm-copilot/src/lib/pr-context/render.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following function body, and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `type PrContextResult,` / `type PullRequestDetails,` / `normalizeReference,` / `section,`). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/render.ts` produces no output and exits with code `1` (no match), and the `from "./models"` import block contains `compareCodePoint`.

- [ ] [P2-T7] In `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following function body, and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `CONVENTIONAL_TYPES,` / `ISSUE_REFERENCE_PATTERN,` / `type IssueDetails,` / `type PullRequestDetails,` / `formatList,` / `section,` / `truncate,`). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts` produces no output and exits with code `1` (no match), and the `from "./models"` import block contains `compareCodePoint`.

- [ ] [P2-T8] In `extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following function body, and (b) add `compareCodePoint,` as a new first line inside the existing import block that closes with `} from "./models";` (currently `type FeatureDocExcerpt,` / `ISSUE_REFERENCE_PATTERN,` / `section,` / `splitLines,` / `truncate,`). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts` produces no output and exits with code `1` (no match), and the `from "./models"` import block contains `compareCodePoint`.

- [ ] [P2-T9] In `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`: if P1-T1 shows this file matched, (a) delete the JSDoc comment and the immediately following function body, and (b) insert a new line `import { compareCodePoint } from "./models";` immediately after the file's sole existing import line `import { type FileSystem, toPosixPath } from "../file-system";` (this file has no pre-existing `./models` import). If no match, mark `[x]` with the "already satisfied" note.
  - Acceptance: `git grep -c "function compareCodePoint(left: string, right: string): number {" -- extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` produces no output and exits with code `1` (no match), and `git grep -c "import { compareCodePoint } from \"./models\";" -- extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` prints `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:1`.

- [ ] [P2-T10] In `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts`: if the existing import block `import { compareCodePoint, completedPlanTasks, extractIssueReferences, latestGlobPath, parsePrimaryIssueFromMetadata, parseSection, readText, relativeToPosix, resolveFeatureDir, resolveReadinessSignal, verificationText, } from "./feature-docs-parsers";` still contains `compareCodePoint,`, (a) remove that line from the block, and (b) change the existing line `import { type FeatureDocExcerpt, section, truncate } from "./models";` to the multi-line block (required to stay within Prettier's 80-character `printWidth`):
  ```ts
  import {
    type FeatureDocExcerpt,
    compareCodePoint,
    section,
    truncate,
  } from "./models";
  ```
  If a sibling branch has already changed the `./models` import's member list, add `compareCodePoint` to the existing import in sorted position consistent with the file's current member ordering, rather than replacing the import wholesale. If the `./feature-docs-parsers` import block no longer contains `compareCodePoint,` (a sibling already redirected it), mark `[x]` with the "already satisfied" note for step (a) only.
  - Acceptance: `git grep -n -A11 "^  compareCodePoint,$" -- extensions/drm-copilot/src/lib/pr-context/feature-docs.ts` prints exactly one matched `compareCodePoint,` line, and the first line beginning with `} from` that follows it in the output is `} from "./models";`. At baseline (before this task) the first following `} from` line is `} from "./feature-docs-parsers";`, so this condition fails on a no-op; two matched `compareCodePoint,` lines means the old `./feature-docs-parsers` occurrence was not removed. The window is `-A11`, not `-A8`: at baseline the 2-space `compareCodePoint,` line sits at line 23 of the `./feature-docs-parsers` import block and that block's closing `} from "./feature-docs-parsers";` sits at line 34, an 11-line span, so an `-A8` window would stop three lines short of the closing line and could never observe the baseline no-op condition this assertion exists to catch; `-A11` is the minimum window that reaches it. After a correct edit, `compareCodePoint,` sits inside the new multi-line `./models` import block only 3 lines above its own `} from "./models";` closer, which is well within `-A11`, and no other `} from` line falls within 11 lines of either position, so the "first line beginning with `} from`" reading is unambiguous in both states. The unrelated 4-space `    compareCodePoint,` call-site lines (the inline `.sort(compareCodePoint)` call and the multi-line `.sort(\n    compareCodePoint,\n  )` call near the end of the file) are not matched by the 2-space anchor and must remain unchanged. The Phase 4 `tsc` gate is the authoritative compile-level check that `compareCodePoint` is no longer imported from `./feature-docs-parsers` (P2-T4 removes that export).

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
  - Acceptance: run `node run-jest.cjs test/lib/pr-context/models.test.ts --testNamePattern "^compareCodePoint [a-z]"` from `extensions/drm-copilot`; the printed `Tests:` line reads `20 skipped, 6 passed, 26 total` and exit code is `0`. (The pattern requires a lowercase letter immediately after `compareCodePoint ` so it cannot also match the `compareCodePoint - enumerative properties ...` describe title added by P3-T2, whose text continues with a hyphen at that position. Jest reports every test excluded by `--testNamePattern` as skipped rather than omitting it, so the 20 pre-existing tests in this file are counted as skipped, not absent.)

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
  - Acceptance: run `node run-jest.cjs test/lib/pr-context/models.test.ts --testNamePattern "enumerative properties"` from `extensions/drm-copilot`; the printed `Tests:` line reads `26 skipped, 6 passed, 32 total` and exit code is `0`. (At this point the file holds 20 pre-existing tests plus the 6 added by P3-T1, all excluded by the pattern and counted as skipped, plus the 6 added by this task that pass.)

---

### Phase 4 — Final QA Loop, Verification, and Acceptance Criteria Checkoff

- [ ] [P4-T1] Run `npx prettier --check src/lib/pr-context/models.ts src/lib/pr-context/collector-core.ts src/lib/pr-context/autoclose.ts src/lib/pr-context/feature-docs-parsers.ts src/lib/pr-context/gh-client-details.ts src/lib/pr-context/render.ts src/lib/pr-context/render-pr-helpers.ts src/lib/pr-context/render-feature-excerpts.ts src/lib/pr-context/verification-evidence.ts src/lib/pr-context/feature-docs.ts test/lib/pr-context/models.test.ts` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/prettier-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If drift is reported, restart the loop from this task after running `npx prettier --write` on the same file list; a file it actually rewrote is printed without the `(unchanged)` suffix (an unchanged file prints `<path> <N>ms (unchanged)`); record which files, if any, lost the suffix, then re-verify with `--check`.
  - Acceptance: `EXIT_CODE: 0` and `Output Summary:` records the literal line `All matched files use Prettier code style!`.

- [ ] [P4-T2] Run `npx eslint --no-error-on-unmatched-pattern src test` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/eslint-check.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0` and `Output Summary:` records "no problems reported" (empty stdout).

- [ ] [P4-T3] Run `npx tsc -p ./ --noEmit` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/tsc-typecheck.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0` and `Output Summary:` records "no diagnostics" (empty stdout).

- [ ] [P4-T4] Run `git grep -c "function compareCodePoint" -- extensions/drm-copilot/src/lib/pr-context` from the repository root. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/structural-uniqueness.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: exactly one output line, `extensions/drm-copilot/src/lib/pr-context/models.ts:1`, and no other file listed. Backs spec.md AC1 and AC2.

- [ ] [P4-T5] Run `node run-jest.cjs test/lib/pr-context` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/pr-context-regression.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing the printed `Test Suites:` and `Tests:` lines.
  - Acceptance: `EXIT_CODE: 0`, `Test Suites:` line shows `0 failed`, `Tests:` line shows `0 failed`. Backs spec.md AC5 (no changes to expected output in the pre-existing suites).

- [ ] [P4-T6] Run `node run-jest.cjs test/lib/pr-context/models.test.ts` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/models-test-count.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0` and the printed `Tests:` line reads `32 passed, 32 total` (20 pre-existing + 6 from P3-T1 + 6 from P3-T2). Backs spec.md AC3 and AC4.

- [ ] [P4-T7] Run `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=lcov` from `extensions/drm-copilot`. Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/jest-coverage-final.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing the printed per-file coverage row for `models.ts` (the row under the `src/lib/pr-context` group heading; the table lists three files named `models.ts`), specifically its `% Lines` and `% Branch` values.
  - Acceptance: `EXIT_CODE: 0` (confirms every per-file `coverageThreshold` entry in `jest.config.cjs`, including `models.ts` at `lines: 85, branches: 75`, passes) and the `models.ts` row's Lines/Branch values are recorded.

- [ ] [P4-T8] Compare the `models.ts` Lines/Branch values recorded in P0-T6 (baseline) against those recorded in P4-T7 (final). Record to `docs/features/active/compare-code-point-helper-duplicated-716/evidence/qa-gates/coverage-delta.<timestamp>.md` with `Timestamp:`, the two numeric pairs, and a explicit statement of whether final >= baseline for both Lines and Branch.
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

This is a revision-delta pass responding to `PREFLIGHT: REVISIONS REQUIRED` (seven deltas: P0 dependency-install task insertion and P0-T2..T5 renumbering, `npx jest` → `node run-jest.cjs` substitution, corrected `--testNamePattern` skip/pass/total counts, the three-`models.ts`-files coverage-table clarification, single-file `git grep -c` path-prefix corrections, Prettier-printWidth-driven multi-line import rewrites for P2-T4/P2-T10, and the P4-T1 retry-observation sentence). Every citation touched by these seven deltas, and the sibling region of each, is re-derived directly against current repository state in this pass; citations for files untouched by this round's deltas (`collector-core.ts`, `autoclose.ts`, `render.ts`, `render-pr-helpers.ts`, `render-feature-excerpts.ts`, and `jest.config.cjs`) are carried forward unchanged from the prior verified round and are not re-read here because no delta edited a task that cites them.

- `.claude/rules/plan-acceptance-gates.md` — the Write-Mode Register exclusions section, re-derived by direct `Read` this pass: confirms `npm ci` is deliberately excluded from the G7 write-mode register because "its only write target is git-ignored, so it rewrites no tracked source," supporting the new P0-T2 claim that `npm ci` does not modify `package.json`/`package-lock.json` (D4).
- `extensions/drm-copilot/run-jest.cjs` — full file (39 lines) re-derived by direct `Read` this pass; confirmed it forwards `process.argv.slice(2)` verbatim (with a `--testPathPattern` → `--testPathPatterns` rewrite not used by any command in this plan) to `jest --config jest.config.cjs ...`, and rejects only `--passWithNoTests`/`--onlyChanged`/`--lastCommit`, none of which this plan's commands use. This confirms `node run-jest.cjs <args>` is a behavior-preserving substitute for `npx jest <args>` for every renumbered/replaced command (P0-T6, P3-T1, P3-T2, P4-T5, P4-T6, P4-T7).
- `extensions/drm-copilot/package.json` — lines 202-213 (`scripts` block) re-derived by direct `Read` this pass; confirmed the repository's own `test`, `test:unit`, and `test:coverage` scripts already invoke `node run-jest.cjs` rather than `npx jest`, corroborating the delta-2 substitution as the project's established convention (issue #423) rather than a plan-only deviation. Lines 228-241 (`devDependencies`) re-derived, confirming no `fast-check` entry (D4 unaffected).
- `extensions/drm-copilot/test/lib/pr-context/models.test.ts` — full file (147 lines, confirmed by `Grep -c "^"` this pass) re-derived by direct `Read` this pass. Recount of pre-existing `it` blocks: `section` 1, `truncate` 3, `truncateLines` 3, `normalizeReference` 4, `findUserStoryLink` 6, `formatList` 3 — total 20. This directly supports the corrected P3-T1 acceptance (`20 skipped, 6 passed, 26 total`, i.e. 20 pre-existing + 6 added by P3-T1) and P3-T2 acceptance (`26 skipped, 6 passed, 32 total`, i.e. 20 pre-existing + 6 from P3-T1 + 6 added by P3-T2), consistent with the unchanged P4-T6 full-file expectation of `32 passed, 32 total`.
- `extensions/drm-copilot/src/lib` — re-derived this pass via `Glob **/models.ts`: exactly three matches, `lib/codex-native-converter/models.ts`, `lib/new-active-feature-folder/models.ts`, `lib/pr-context/models.ts`. This directly supports the P0-T6/P4-T7 clarification that the Jest `text`-reporter coverage table lists three files named `models.ts` and that the correct row is the one grouped under the `src/lib/pr-context` directory heading.
- `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts` — re-derived by direct `Read` this pass: line 18 is exactly `import { ISSUE_REFERENCE_PATTERN, splitLines } from "./models";` (the P2-T4 edit anchor); lines 304-313 hold the JSDoc + `export function compareCodePoint(...)` body to remove. **Sibling-region finding (new this pass):** lines 272-274 hold a second, previously uncited call site — `resolveReadinessSignal`'s `[...fs.glob(...)].sort(\n    compareCodePoint,\n  )` — at 4-space indent, structurally identical to the already-documented `feature-docs.ts` line-306 call site. Because it sits at 4-space indent, it cannot collide with the P2-T4 acceptance's `^  compareCodePoint,$` (2-space) anchor; the P2-T4 acceptance text was updated in this pass to state this explicitly.
- `extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts` — re-derived by direct `Read` this pass: line 18 is exactly `import { findUserStoryLink } from "./models";` and line 19 is the untouched `import { type IssueDetails, type PullRequestDetails } from "./models";` (the P2-T5 edit anchors); lines 127-136 hold the JSDoc + `export function compareCodePoint(...)` body to remove; line 124 (`sortedSet`'s `.sort(compareCodePoint)`) is an unqualified call site unaffected by the import redirect. The full replacement import line `import { compareCodePoint, findUserStoryLink } from "./models";` is 64 characters, under Prettier's 80-character `printWidth`, so no multi-line rewrite is required for this file (unlike P2-T4/P2-T10).
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` — re-derived by direct `Read` this pass: line 21 is exactly `import { type FileSystem, toPosixPath } from "../file-system";` (the sole existing import, the P2-T9 insertion anchor); lines 273-282 hold the JSDoc + non-exported `function compareCodePoint(...)` body to remove.
- `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts` — re-derived by direct `Read` this pass: line 21 is exactly `import { type FeatureDocExcerpt, section, truncate } from "./models";` (the P2-T10 edit anchor); lines 22-34 hold the `./feature-docs-parsers` import block with `compareCodePoint,` as its first member (line 23); line 99 (`[...features].sort(compareCodePoint)`) and lines 305-307 (`.sort(\n    compareCodePoint,\n  )`, 4-space indent) are unqualified call sites confirmed unaffected by the `^  compareCodePoint,$` (2-space) acceptance anchor, consistent with the existing task-text caveat.
- `extensions/drm-copilot/src/lib/pr-context/models.ts` — re-derived by direct `Read` this pass: lines 328-337 hold the `formatList` function through its closing brace (the P2-T1 insertion anchor, and the file this pass's P2-T1 `git grep -c` path-prefix fix applies to); file total is 337 lines, confirmed by `Grep -c "^"`.
- Import-member ordering check (new this pass): no `import/order` or `sort-imports` rule was found in `extensions/drm-copilot/eslint.config.*` (searched this pass), so member order within an import statement is not lint-enforced; the multi-line blocks specified for P2-T4 and P2-T10 place `compareCodePoint` alphabetically among the non-type members, consistent with the existing manual convention visible in `render-pr-helpers.ts` (uppercase constants, then `type` imports, then alphabetical functions), but this ordering is a style choice, not a gate.
- Confirmed this pass by direct `Grep -c "^"` re-read (not carried forward) that the four files whose tasks this round's deltas touched remain under the 500-line cap: `feature-docs-parsers.ts` 323, `gh-client-details.ts` 398, `verification-evidence.ts` 303, `feature-docs.ts` 308. The five untouched-this-round files (`collector-core.ts` 396, `autoclose.ts` 304, `render.ts` 410, `render-pr-helpers.ts` 417, `render-feature-excerpts.ts` 452) and `models.test.ts` (147, re-derived above) and `models.ts` (337, re-derived above) carry forward from the prior round with no plan-text change affecting their line-count citations. P4-T11 re-verifies every count numerically at execution time regardless.

**Round 3 (this pass) — response to `PREFLIGHT: REVISIONS REQUIRED` (one defect: P2-T10's `git grep -c "^  compareCodePoint,$"` acceptance was vacuous, printing count `1` both before and after a correct edit, because the pre-existing `./feature-docs-parsers` import block already contributes one such line at baseline).** Only P2-T10's acceptance bullet was edited this round. Every citation that bullet depends on, and the sibling region around it, is re-derived directly against current repository state in this pass:

- `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts` — lines 20-35 re-read by direct `Read` this pass. Confirmed line 21 is exactly `import { type FeatureDocExcerpt, section, truncate } from "./models";` (the P2-T10 `./models`-side edit target); lines 22-34 hold the `./feature-docs-parsers` import block, with the 2-space `  compareCodePoint,` line at line 23 and the block's closing `} from "./feature-docs-parsers";` at line 34 — an 11-line span (lines 24 through 34 inclusive, counted forward from the match). Confirmed by a whole-file `Grep` count that `^  compareCodePoint,$` has exactly one match in the file at baseline (line 23), and by a plain `compareCodePoint` search that the file's only other two occurrences are line 99 (`.sort(compareCodePoint)`, inline call site) and line 306 (`    compareCodePoint,`, 4-space indent, inside the `.sort(\n    compareCodePoint,\n  )` call spanning lines 305-307) — both structurally distinct from the 2-space anchor and unaffected by it.
- The revised P2-T10 acceptance uses `-A11`, not the previously proposed `-A8`: `-A8` was checked against the 11-line baseline span above and found insufficient — it stops at line 31, three lines short of the closing `} from "./feature-docs-parsers";` line at line 34 — so it could never observe the baseline no-op condition the assertion exists to catch. `-A11` is the minimum window that reaches that closing line. The post-edit span (the new `compareCodePoint,` position inside the multi-line `./models` import block to its own `} from "./models";` closer) is 3 lines by direct construction of the P2-T10 edit text, well inside `-A11`, and re-derivation confirmed no other `} from` line falls within 11 lines of either the baseline or the post-edit match position, so the "first line beginning with `} from`" reading stays unambiguous in both states.
- **Sibling check, P2-T4** (`extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts`) — re-read this pass: line 18 (`import { ISSUE_REFERENCE_PATTERN, splitLines } from "./models";`) and lines 304-313 (JSDoc + the exported `compareCodePoint` body to remove) are unchanged from the prior round's citation; lines 272-274 (the `resolveReadinessSignal` 4-space `.sort(\n    compareCodePoint,\n  )` call site) are likewise unchanged. P2-T4's own acceptance condition — absence of the `export function compareCodePoint(left: string, right: string): number {` line, plus presence of a 2-space `^  compareCodePoint,$` line in this same file (distinct from and unaffected by the `feature-docs.ts` anchor discussed above) — is unaffected by the P2-T10 wording change and remains valid as written.
- **Sibling check, AC-MAPPING row for AC2** (`IMPLEMENTATION: P2-T2..P2-T10 | TESTS: P1-T1, P4-T4 | EVIDENCE: evidence/baseline/compare-code-point-detection.<timestamp>.md`) — the row names a task range and an evidence artifact path, neither of which changed by this round's edit; the corrected defect was confined to P2-T10's own acceptance-condition wording and does not alter AC2's implementation, test, or evidence attribution.

---

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: .claude/rules/plan-acceptance-gates.md | Write-Mode Register exclusions (npm ci excluded: writes only git-ignored targets)
CITATION: extensions/drm-copilot/run-jest.cjs | lines 1-39 (Jest wrapper, --config jest.config.cjs, prohibited-flag guard, argv passthrough)
CITATION: extensions/drm-copilot/package.json | lines 202-213 (scripts: test/test:unit/test:coverage already use node run-jest.cjs), lines 228-241 (devDependencies, no fast-check)
CITATION: extensions/drm-copilot/test/lib/pr-context/models.test.ts | lines 1-10 (import block), lines 18-147 (all six pre-existing describe blocks, 20 it blocks total), lines 135-147 (append anchor)
CITATION: extensions/drm-copilot/src/lib (Glob **/models.ts) | three matches: lib/codex-native-converter/models.ts, lib/new-active-feature-folder/models.ts, lib/pr-context/models.ts
CITATION: extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts | line 18 (import line), lines 304-313 (function to remove), lines 272-274 (sibling 4-space call site, unaffected by 2-space anchor)
CITATION: extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts | lines 18-19 (two import lines), lines 127-136 (function to remove), line 124 (call site)
CITATION: extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts | line 21 (sole import line), lines 273-282 (function to remove)
CITATION: extensions/drm-copilot/src/lib/pr-context/feature-docs.ts | line 21 (./models import line), lines 22-34 (./feature-docs-parsers import block; line 23 is the 2-space `compareCodePoint,` anchor, line 34 is its closing `} from "./feature-docs-parsers";`, an 11-line span, driving the P2-T10 acceptance's `-A11` window), line 99 and lines 305-307 (call sites)
CITATION: extensions/drm-copilot/src/lib/pr-context/models.ts | lines 328-337 (formatList, insertion anchor for P2-T1)
CITATION: extensions/drm-copilot/src/lib/pr-context/collector-core.ts | lines 21-27 (./models import block), lines 387-396 (function to remove) [carried forward, untouched this round]
CITATION: extensions/drm-copilot/src/lib/pr-context/autoclose.ts | lines 25-32 (./models import block), lines 295-304 (function to remove) [carried forward, untouched this round]
CITATION: extensions/drm-copilot/src/lib/pr-context/render.ts | lines 18-23 (./models import block), lines 380-389 (function to remove) [carried forward, untouched this round]
CITATION: extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts | lines 19-27 (./models import block), lines 387-396 (function to remove) [carried forward, untouched this round]
CITATION: extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts | lines 19-25 (./models import block), lines 438-447 (function to remove) [carried forward, untouched this round]
CITATION: extensions/drm-copilot/jest.config.cjs | lines 25-324 (coverageThreshold map) [carried forward, untouched this round]
CITATION: docs/features/active/compare-code-point-helper-duplicated-716/spec.md | lines 147-156 (AC1-AC10) [carried forward, untouched this round]
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
