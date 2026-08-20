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
});
