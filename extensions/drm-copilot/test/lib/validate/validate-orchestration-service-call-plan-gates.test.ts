import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import { validateOrchestrationServiceCall } from "../../../src/lib/validate/validate-orchestration-service-call";

const WARNING_ONLY_PLAN = [
  "### Phase 1 — Work",
  "- [ ] [P1-T1] Do the thing",
  "  - Acceptance: `poetry run pytest -q --cov tests.foo` reports 0 failed.",
  "",
].join("\n");

const CLEAN_PLAN = [
  "### Phase 1 — Work",
  "- [ ] [P1-T1] Do the thing",
  "  - Acceptance: `poetry run pytest -q --cov=scripts.dev_tools.foo` passes.",
  "",
].join("\n");

const COMBINED_ERROR_AND_WARNING_PLAN = [
  "### Phase 1 — Work",
  "- [ ] [P1-T1] Do the first thing",
  "  - Acceptance: `poetry run pytest -q --cov=scripts/dev_tools/foo.py` passes.",
  "- [ ] [P1-T2] Do the second thing",
  "  - Acceptance: `poetry run pytest -q --cov tests.bar` reports 0 failed.",
  "",
].join("\n");

/** Filesystem stub returning one fixed artifact text for any path. */
function stubFileSystem(text: string): FileSystem {
  return {
    glob: () => [],
    isFile: () => true,
    exists: () => true,
    isDirectory: () => false,
    listDirectory: () => [],
    readTextFile: () => text,
    writeTextFile: () => undefined,
    ensureDir: () => undefined,
  };
}

describe("validateOrchestrationServiceCall plan acceptance gates", () => {
  it("does not throw when the only finding is a warning", () => {
    // Arrange
    const fileSystem = stubFileSystem(WARNING_ONLY_PLAN);

    // Act / Assert
    expect(() =>
      validateOrchestrationServiceCall({
        fileSystem,
        workspaceRoot: "/workspace",
        artifactType: "plan",
        artifactPath: "docs/plan.md",
      }),
    ).not.toThrow();
  });

  it("surfaces the warning on the result warnings field", () => {
    // Arrange
    const fileSystem = stubFileSystem(WARNING_ONLY_PLAN);

    // Act
    const result = validateOrchestrationServiceCall({
      fileSystem,
      workspaceRoot: "/workspace",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
    });

    // Assert
    expect(result.summary).toBe("Validated plan artifact at 'docs/plan.md'.");
    expect(result.warnings).toEqual([
      "[P1-T1] --cov argument value `tests.foo` is supplied space-separated; " +
        "the ambiguous form can bind the following positional argument. " +
        "Use the --cov=<module> form.",
    ]);
  });

  it("omits the warnings field when there are no warnings", () => {
    // Arrange
    const fileSystem = stubFileSystem(CLEAN_PLAN);

    // Act
    const result = validateOrchestrationServiceCall({
      fileSystem,
      workspaceRoot: "/workspace",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
    });

    // Assert: the own-property list is byte-identical to the pre-change shape.
    expect(Object.keys(result)).toEqual(["tool", "workspaceRoot", "summary"]);
  });

  it("throws the combined error-and-warning message when both channels are non-empty", () => {
    // Arrange: task 1's `--cov` value is a filesystem path ending in `.py`
    // (G1 Blocking, errors channel); task 2's `--cov` value is supplied
    // space-separated (G4 Warning, warnings channel).
    const fileSystem = stubFileSystem(COMBINED_ERROR_AND_WARNING_PLAN);

    // Act / Assert
    expect(() =>
      validateOrchestrationServiceCall({
        fileSystem,
        workspaceRoot: "/workspace",
        artifactType: "plan",
        artifactPath: "docs/plan.md",
      }),
    ).toThrow(
      "Validation failed for plan artifact at 'docs/plan.md':\n" +
        "[P1-T1] --cov argument `scripts/dev_tools/foo.py` names a " +
        "filesystem path; coverage.py accepts only directories or " +
        "importable names. Use --cov=scripts.dev_tools.foo.\n" +
        "PLAN GATE WARNING: [P1-T2] --cov argument value `tests.bar` is " +
        "supplied space-separated; the ambiguous form can bind the " +
        "following positional argument. Use the --cov=<module> form.",
    );
  });
});
