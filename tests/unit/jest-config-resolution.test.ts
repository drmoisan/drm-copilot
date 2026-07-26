import { describe, expect, it } from "@jest/globals";
import { globsToMatcher } from "jest-util";

/**
 * Regression tests for issue #423 — root Jest project.
 *
 * Defect: `testMatch` entries that interpolate `<rootDir>` produce an absolute
 * host path inside a glob. `jest-util`'s `replacePathSepForGlob` normalizes
 * separators with `/\\(?![$()+.?^{}])/g`, whose negative lookahead deliberately
 * preserves a backslash that precedes a glob metacharacter. A dot-prefixed
 * directory segment (`\.claude`) therefore keeps its backslash, and picomatch
 * reads the surviving `\.` as an escaped literal dot rather than a path
 * separator. Result: zero discovered tests in any checkout whose path contains
 * a dot-prefixed segment, such as `.claude/worktrees/<name>/`.
 *
 * Fix: relative `**\/`-anchored patterns never enter `<rootDir>` interpolation,
 * so no host path is ever compiled into a glob.
 *
 * Test constraints (repository unit-test policy): the only filesystem access is
 * the `require` of the config module under test. Every matcher input is a
 * synthetic path string; no temporary file or directory is created, no
 * dot-prefixed checkout is materialised, and no process is spawned. The
 * assertions are therefore byte-identical on Windows and Linux.
 */

interface JestConfigUnderTest {
  readonly testMatch: readonly string[];
  readonly testPathIgnorePatterns: readonly string[];
  readonly passWithNoTests?: unknown;
}

const config = require("../../jest.config.cjs") as JestConfigUnderTest;

/** Index of the `tests/unit` pattern in the root config's `testMatch`. */
const UNIT_PATTERN_INDEX = 0;

/** Index of the `extensions/drm-copilot/test` pattern in `testMatch`. */
const EXTENSION_PATTERN_INDEX = 1;

/**
 * Reads one configured `testMatch` entry by index.
 *
 * Each pattern is asserted individually rather than as a collapsed set, so a
 * partial regression — one of the two root patterns silently matching nothing
 * while the other still works — fails the suite instead of hiding behind its
 * sibling.
 *
 * @param index - Position of the pattern within `config.testMatch`.
 * @returns The configured glob pattern at that position.
 */
function patternAt(index: number): string {
  const pattern = config.testMatch[index];

  if (pattern === undefined) {
    throw new Error(
      `Root jest.config.cjs defines no testMatch pattern at index ${index}; ` +
        `found ${String(config.testMatch.length)} pattern(s).`,
    );
  }

  return pattern;
}

// --- Synthetic path fixtures (strings only; none of these paths exist) -------

/** Dot-prefixed Windows worktree path for the `tests/unit` pattern. */
const WINDOWS_UNIT_PATH =
  "C:\\Users\\x\\repos\\drm-copilot\\.claude\\worktrees\\wt-1\\tests\\unit\\sample.test.ts";

/** Dot-prefixed Windows worktree path for the extension pattern. */
const WINDOWS_EXTENSION_PATH =
  "C:\\Users\\x\\repos\\drm-copilot\\.claude\\worktrees\\wt-1\\extensions\\drm-copilot\\test\\lib\\sample.test.ts";

/** POSIX CI-runner path for the `tests/unit` pattern. */
const POSIX_UNIT_PATH =
  "/home/runner/work/drm-copilot/drm-copilot/tests/unit/sample.test.ts";

/** POSIX CI-runner path for the extension pattern. */
const POSIX_EXTENSION_PATH =
  "/home/runner/work/drm-copilot/drm-copilot/extensions/drm-copilot/test/lib/sample.test.ts";

/** Production source file that must never be treated as a test. */
const WINDOWS_PRODUCTION_PATH =
  "C:\\Users\\x\\repos\\drm-copilot\\.claude\\worktrees\\wt-1\\src\\extension.ts";

/**
 * The exact normalized pattern the pre-fix `<rootDir>` config produced, with
 * the retained `\.` byte pair before the dot-prefixed segment. Hard-coded on
 * purpose: it pins picomatch's escaped-dot semantics independently of the
 * current config, so a future Jest change to `replacePathSepForGlob` or to
 * picomatch escape handling breaks this assertion and forces re-evaluation of
 * the fix.
 */
const DEFECTIVE_PATTERN =
  "C:/Users/x/repos/drm-copilot\\.claude/worktrees/wt-1/tests/unit/**/*.test.ts";

describe("root jest.config.cjs testMatch resolution (issue #423)", () => {
  describe("group 1: testMatch shape guard", () => {
    it("declares exactly the two expected relative patterns", () => {
      expect(config.testMatch).toEqual([
        "**/tests/unit/**/*.test.ts",
        "**/extensions/drm-copilot/test/**/*.test.ts",
      ]);
    });

    it("declares every pattern as a string", () => {
      for (const pattern of config.testMatch) {
        expect(typeof pattern).toBe("string");
      }
    });

    it("interpolates <rootDir> into no pattern", () => {
      for (const pattern of config.testMatch) {
        expect(pattern).not.toContain("<rootDir>");
      }
    });

    it("embeds a backslash in no pattern", () => {
      for (const pattern of config.testMatch) {
        expect(pattern).not.toContain("\\");
      }
    });

    it("anchors every pattern with a leading globstar", () => {
      for (const pattern of config.testMatch) {
        expect(pattern.startsWith("**/")).toBe(true);
      }
    });
  });

  describe("group 2: per-pattern match, dot-prefixed Windows checkout", () => {
    it("matches a tests/unit file via the unit pattern alone", () => {
      const isMatch = globsToMatcher([patternAt(UNIT_PATTERN_INDEX)]);

      expect(isMatch(WINDOWS_UNIT_PATH)).toBe(true);
    });

    it("matches an extension test file via the extension pattern alone", () => {
      const isMatch = globsToMatcher([patternAt(EXTENSION_PATTERN_INDEX)]);

      expect(isMatch(WINDOWS_EXTENSION_PATH)).toBe(true);
    });
  });

  describe("group 3: per-pattern match, POSIX checkout", () => {
    it("matches a tests/unit file via the unit pattern alone", () => {
      const isMatch = globsToMatcher([patternAt(UNIT_PATTERN_INDEX)]);

      expect(isMatch(POSIX_UNIT_PATH)).toBe(true);
    });

    it("matches an extension test file via the extension pattern alone", () => {
      const isMatch = globsToMatcher([patternAt(EXTENSION_PATTERN_INDEX)]);

      expect(isMatch(POSIX_EXTENSION_PATH)).toBe(true);
    });
  });

  describe("group 4: defect witness", () => {
    it("confirms the pre-fix escaped-dot pattern matches nothing real", () => {
      const isMatch = globsToMatcher([DEFECTIVE_PATTERN]);

      expect(isMatch(WINDOWS_UNIT_PATH)).toBe(false);
    });
  });

  describe("group 5: negative flow", () => {
    it("rejects a production source file under the unit pattern", () => {
      const isMatch = globsToMatcher([patternAt(UNIT_PATTERN_INDEX)]);

      expect(isMatch(WINDOWS_PRODUCTION_PATH)).toBe(false);
    });

    it("rejects a production source file under the extension pattern", () => {
      const isMatch = globsToMatcher([patternAt(EXTENSION_PATTERN_INDEX)]);

      expect(isMatch(WINDOWS_PRODUCTION_PATH)).toBe(false);
    });
  });

  describe("group 6: loudness config guard", () => {
    it("leaves passWithNoTests strictly falsy", () => {
      expect(config.passWithNoTests).toBeFalsy();
    });

    it("still ignores node_modules and out during discovery", () => {
      expect(config.testPathIgnorePatterns).toContain("/node_modules/");
      expect(config.testPathIgnorePatterns).toContain("/out/");
    });
  });
});
