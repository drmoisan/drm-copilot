import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import type {
  CommandResult,
  CommandRunner,
} from "../../../src/lib/subprocess-runner";
import {
  validateArtifact,
  validateArtifactWithWarnings,
} from "../../../src/lib/validate/orchestration-artifacts";

const CLEAN_PLAN = [
  "### Phase 1 — Work",
  "- [ ] [P1-T1] Do the thing",
  "  - Acceptance: `poetry run pytest -q --cov=scripts.dev_tools.foo` passes.",
  "",
].join("\n");

const G1_PLAN = [
  "### Phase 1 — Work",
  "- [ ] [P1-T1] Do the thing",
  "  - Acceptance: `poetry run pytest -q --cov=scripts/dev_tools/foo.py` passes.",
  "",
].join("\n");

const GREP_PLAN = [
  "### Phase 1 — Work",
  "- [ ] [P1-T1] Do the thing",
  "  - Acceptance: `grep -F -n 'pinned items occupy' docs/design.md` matches.",
  "",
].join("\n");

/** Read-only filesystem stub that answers negatively and reads nothing. */
const STUB_FILE_SYSTEM: FileSystem = {
  glob: () => [],
  isFile: () => false,
  exists: () => false,
  isDirectory: () => false,
  listDirectory: () => [],
  readTextFile: () => "",
  writeTextFile: () => undefined,
  ensureDir: () => undefined,
};

/** Command runner stub that records every argv and answers with empty output. */
class RecordingRunner implements CommandRunner {
  public readonly calls: string[][] = [];

  public run(args: readonly string[]): CommandResult {
    this.calls.push([...args]);
    return { stdout: "", stderr: "", code: 0 };
  }
}

describe("validateArtifact plan acceptance gates", () => {
  it("reports a G1 finding on the existing plan route with no new flag", () => {
    // Arrange / Act: the pre-existing `plan` artifact type, no extra option.
    const errors = validateArtifact({ artifactType: "plan", text: G1_PLAN });

    // Assert
    expect(errors).toEqual([
      "[P1-T1] --cov argument `scripts/dev_tools/foo.py` names a filesystem " +
        "path; coverage.py accepts only directories or importable names. " +
        "Use --cov=scripts.dev_tools.foo.",
    ]);
  });

  it("returns the seven existing structural error strings unchanged", () => {
    // Arrange: one document exercising the five line-scoped errors in order.
    const malformed = [
      "- [ ] [P1-T1] Task before any phase heading",
      "### Phase 1 - hyphen instead of em dash",
      "### Phase 1 — Work",
      "- [x] [P1-T1] Correct first task",
      "- [ ] [P2-T2] Task whose phase does not match",
      "- [ ] [P1-T9] Task whose number is unexpected",
      "- [ ] [P1-T] Task line missing the task number",
      "",
    ].join("\n");

    // Act
    const errors = validateArtifact({
      artifactType: "plan",
      text: malformed,
    });
    const empty = validateArtifact({
      artifactType: "plan",
      text: "no plan content here\n",
    });

    // Assert
    expect(errors).toEqual([
      "Line 1: task appears before a canonical phase heading.",
      "Line 2: phase heading must match `### Phase N — <Title>`.",
      "Line 5: task phase P2 does not match current phase 1.",
      "Line 5: expected task number T1 for phase 2, found T2.",
      "Line 6: expected task number T2 for phase 1, found T9.",
      "Line 7: task line must match `- [ ] [P#-T#] <Title>`.",
    ]);
    expect(empty).toEqual([
      "Plan does not contain any canonical phase headings.",
      "Plan does not contain any canonical task lines.",
    ]);
  });

  it("returns an empty error list for a clean plan without context", () => {
    // Arrange / Act
    const result = validateArtifactWithWarnings({
      artifactType: "plan",
      text: CLEAN_PLAN,
    });

    // Assert
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it("returns an empty error list for a clean plan with a stub context", () => {
    // Arrange
    const runner = new RecordingRunner();

    // Act
    const result = validateArtifactWithWarnings({
      artifactType: "plan",
      text: CLEAN_PLAN,
      artifactPath: "docs/plan.md",
      fs: STUB_FILE_SYSTEM,
      root: "/workspace",
      runner,
    });

    // Assert
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it("invokes the injected runner on the plan route when supplied", () => {
    // Arrange: a grep acceptance command forces a tracked-tree query.
    const runner = new RecordingRunner();

    // Act
    const result = validateArtifactWithWarnings({
      artifactType: "plan",
      text: GREP_PLAN,
      artifactPath: "docs/plan.md",
      fs: STUB_FILE_SYSTEM,
      root: "/workspace",
      runner,
    });

    // Assert
    expect(runner.calls.length).toBeGreaterThanOrEqual(1);
    expect(runner.calls[0]).toEqual([
      "git",
      "grep",
      "-F",
      "-l",
      "--",
      "pinned items occupy",
    ]);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toHaveLength(1);
  });

  it("runs no tracked-tree query when the wiring fields are absent", () => {
    // Arrange / Act: without a runner the gate must stay context-free.
    const result = validateArtifactWithWarnings({
      artifactType: "plan",
      text: GREP_PLAN,
      fs: STUB_FILE_SYSTEM,
      root: "/workspace",
      artifactPath: "docs/plan.md",
    });

    // Assert
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it("leaves every non-plan route on the single-channel path", () => {
    // Arrange / Act
    const result = validateArtifactWithWarnings({
      artifactType: "not-a-real-type",
      text: "",
    });

    // Assert
    expect(result.errors).toEqual([
      "Unsupported artifact type: not-a-real-type",
    ]);
    expect(result.warnings).toEqual([]);
  });
});
