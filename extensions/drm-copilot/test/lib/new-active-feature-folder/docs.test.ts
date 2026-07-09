/**
 * Unit tests for `src/lib/new-active-feature-folder/docs.ts`.
 *
 * Hermetic: uses a `Map`-backed `FolderFileSystem` fake. AAA; one behavior per
 * test.
 */

import { describe, expect, it } from "@jest/globals";

import {
  shouldUseMinorAuditMode,
  updateFeatureDocs,
} from "../../../src/lib/new-active-feature-folder/docs";
import { FakeFolderFileSystem } from "./fakes";

const ARGS = {
  issue: "#123",
  owner: "octocat",
  updated: "2026-03-14T10-00",
  parent: "none",
  status: "Draft",
  version: "0.1",
  planUpdated: "2026-03-14T11-00",
};

/**
 * Invoke updateFeatureDocs with the shared metadata fields.
 *
 * @param fs Filesystem fake.
 * @param featureType Feature type under test.
 * @param targetDir Active folder directory.
 * @param sections Seeded section bodies.
 * @returns The files-to-open list.
 */
function run(
  fs: FakeFolderFileSystem,
  featureType: string,
  targetDir: string,
  sections: Record<string, string>,
): string[] {
  return updateFeatureDocs(
    featureType,
    "notes-feature",
    targetDir,
    ARGS.issue,
    ARGS.owner,
    ARGS.updated,
    ARGS.parent,
    ARGS.status,
    ARGS.version,
    ARGS.planUpdated,
    fs,
    sections,
  );
}

describe("updateFeatureDocs feature", () => {
  it("writes user-story and spec sections and the plan, returning [user-story, spec, plan]", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const dir = "/ws/active/notes-feature";
    fs.seed(`${dir}/user-story.md`, "# <feature-name>\n");
    fs.seed(`${dir}/spec.md`, "# <feature-name>\n");
    fs.seed(
      `${dir}/plan.md`,
      "# <feature-name>\n- **Last Updated:** <yyyy-MM-ddTHH-mm>\n",
    );

    // Act
    const files = run(fs, "feature", dir, {
      problem: "why text",
      criteria: "do a thing",
      behavior: "behaves",
      constraints: "risky",
      tests: "verify",
    });

    // Assert
    expect(files).toEqual([
      `${dir}/user-story.md`,
      `${dir}/spec.md`,
      `${dir}/plan.md`,
    ]);
    const userStory = fs.files.get(`${dir}/user-story.md`) ?? "";
    expect(userStory).toContain("## Problem / Why\nwhy text");
    expect(userStory).toContain("## Acceptance Criteria\n- [ ] do a thing");
    const spec = fs.files.get(`${dir}/spec.md`) ?? "";
    expect(spec).toContain("## Overview\nwhy text");
    expect(spec).toContain("## Behavior\nbehaves");
    expect(spec).toContain("## Constraints & Risks\nrisky");
    expect(spec).toContain(
      "## Seeded Test Conditions (from potential)\n- [ ] verify",
    );
    const plan = fs.files.get(`${dir}/plan.md`) ?? "";
    expect(plan).toContain("- **Last Updated:** 2026-03-14T11-00");
  });
});

describe("updateFeatureDocs refactor", () => {
  it("writes spec sections + plan, returning [spec, plan]", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const dir = "/ws/active/notes-feature";
    fs.seed(`${dir}/spec.md`, "# <feature-name>\n");
    fs.seed(`${dir}/plan.md`, "# <feature-name>\n");

    // Act
    const files = run(fs, "refactor", dir, {
      problem: "intent",
      behavior: "scope",
      constraints: "mitigate",
      tests: "seed-test",
    });

    // Assert
    expect(files).toEqual([`${dir}/spec.md`, `${dir}/plan.md`]);
    const spec = fs.files.get(`${dir}/spec.md`) ?? "";
    expect(spec).toContain("## Intent & Outcomes\nintent");
    expect(spec).toContain("## Scope (structural changes)\nscope");
    expect(spec).toContain("## Risks & Mitigations\nmitigate");
    expect(spec).toContain(
      "## Seeded Test Conditions (from potential)\n- [ ] seed-test",
    );
  });
});

describe("updateFeatureDocs epic", () => {
  it("stamps epic.md and returns [epic], never initiative.md", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const dir = "/ws/epics/notes-feature";
    fs.seed(`${dir}/epic.md`, "# <epic-name> - Epic\n");
    fs.seed(
      `${dir}/epic-status.md`,
      "# <epic-name> - Epic Status (generated)\n",
    );

    // Act
    const files = run(fs, "epic", dir, {});

    // Assert
    expect(files).toEqual([`${dir}/epic.md`]);
    expect(fs.files.get(`${dir}/epic.md`)).toContain("# notes-feature");
    // epic-status.md is generated-only: it is not stamped and not opened.
    expect(files).not.toContain(`${dir}/epic-status.md`);
    expect(fs.files.has(`${dir}/initiative.md`)).toBe(false);
  });
});

describe("updateFeatureDocs bug", () => {
  it("builds Context/Repro/Root Cause from bug parts and seeds Test Strategy", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    const dir = "/ws/active/notes-feature";
    fs.seed(
      `${dir}/spec.md`,
      "# <feature-name>\n\n## Test Strategy\nexisting strategy\n",
    );
    fs.seed(`${dir}/plan.md`, "# <feature-name>\n");

    // Act
    const files = run(fs, "bug", dir, {
      bug_summary: "summary",
      bug_environment: "env",
      bug_impact: "high",
      bug_steps: "step1",
      bug_expected: "ok",
      bug_actual: "broken",
      bug_logs: "logtext",
      bug_cause: "root",
      bug_validation: "fix idea",
    });

    // Assert
    expect(files).toEqual([`${dir}/spec.md`, `${dir}/plan.md`]);
    const spec = fs.files.get(`${dir}/spec.md`) ?? "";
    expect(spec).toContain(
      "## Context\nsummary\n\nEnvironment:\nenv\n\nImpact / Severity:\nhigh",
    );
    expect(spec).toContain(
      "## Repro & Evidence\nSteps to Reproduce:\nstep1\n\nExpected:\nok\n\nActual:\nbroken\n\nLogs / Screenshots:\nlogtext",
    );
    expect(spec).toContain("## Root Cause Analysis\nroot");
    expect(spec).toContain("## Test Strategy\nSeeded from issue:\n\nfix idea");
    expect(spec).toContain("existing strategy");
  });
});

describe("applyHeaderAndSections (via updateFeatureDocs)", () => {
  it("is a no-op for a file that does not exist", () => {
    // Arrange: target docs are not seeded, so nothing should be written.
    const fs = new FakeFolderFileSystem();
    const dir = "/ws/active/notes-feature";

    // Act
    const files = run(fs, "feature", dir, { problem: "x" });

    // Assert: files-to-open still lists the paths, but no content was written.
    expect(files).toEqual([
      `${dir}/user-story.md`,
      `${dir}/spec.md`,
      `${dir}/plan.md`,
    ]);
    expect(fs.files.has(`${dir}/user-story.md`)).toBe(false);
  });
});

describe("shouldUseMinorAuditMode", () => {
  it("returns [false, ''] for non-minor-audit modes", () => {
    // Arrange / Act / Assert
    expect(shouldUseMinorAuditMode("full-feature", "feature", "")).toEqual([
      false,
      "",
    ]);
    expect(shouldUseMinorAuditMode("full", "feature", "")).toEqual([false, ""]);
  });

  it("returns [true, ''] for minor-audit", () => {
    // Arrange / Act / Assert
    expect(shouldUseMinorAuditMode("minor-audit", "feature", "")).toEqual([
      true,
      "",
    ]);
  });

  it("throws the byte-identical message for an out-of-set mode", () => {
    // Arrange / Act / Assert
    expect(() => shouldUseMinorAuditMode("bogus", "feature", "")).toThrow(
      "work_mode must be one of: minor-audit, full-feature, full-bug, full",
    );
  });
});
