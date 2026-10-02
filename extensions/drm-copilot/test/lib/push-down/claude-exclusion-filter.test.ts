import { describe, expect, it, jest } from "@jest/globals";

import { type DirectoryLister } from "../../../src/lib/push-down/claude-customizations";
import {
  ExclusionFilterFileSystem,
  ExclusionViolationError,
  readExclusionManifest,
  renderExclusionLines,
} from "../../../src/lib/push-down/claude-exclusion-filter";
import {
  ExclusionManifestError,
  parseExclusionManifest,
} from "../../../src/lib/push-down/claude-exclusion-manifest";
import {
  renderPushDownSummary,
  stringifySorted,
} from "../../../src/lib/push-down/copilot-customizations-engine";
import { DEST, publish, SRC, seedTree } from "./config-carriage.test-helpers";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

/**
 * Filter-level tests for the destination exclusion manifest (issue #621).
 *
 * Purpose:
 *     Drive the real Claude entry point over the hermetic in-memory adapter
 *     with a manifest seeded at `${DEST}/.push-down-exclusions`, and assert the
 *     skip, conflict, unmatched, write-guard, decorator-isolation, gitignore,
 *     artifact, and composition-order contracts. No test touches the disk.
 */

/** Absolute destination path of the manifest. */
const MANIFEST = `${DEST}/.push-down-exclusions`;

/** A payload path present in the seeded source tree. */
const RULE = ".claude/rules/parallel-orchestration.md";

/**
 * Seed the standard tree plus a manifest and optional extra files.
 *
 * @param manifestText Manifest content.
 * @param extraFiles Additional files to seed.
 * @returns The seeded in-memory filesystem.
 */
function seedWithManifest(
  manifestText: string,
  extraFiles: Record<string, string> = {},
): ReturnType<typeof seedTree> {
  return seedTree({ [MANIFEST]: manifestText, ...extraFiles });
}

/**
 * Capture the error a callback throws.
 *
 * @param action Callback expected to throw.
 * @returns The thrown value.
 */
function captureError(action: () => unknown): unknown {
  try {
    action();
  } catch (error: unknown) {
    return error;
  }
  throw new Error("expected the action to throw");
}

/**
 * Parse the summary artifact the run wrote.
 *
 * @param seeded The in-memory filesystem.
 * @param artifactPath Artifact path from the summary.
 * @returns The parsed artifact object.
 */
function readArtifact(
  seeded: ReturnType<typeof seedTree>,
  artifactPath: string,
): Record<string, unknown> {
  return JSON.parse(seeded.readTextFile(artifactPath)) as Record<
    string,
    unknown
  >;
}

describe("claude-exclusion-filter", () => {
  it("returns undefined and constructs no filter when the manifest is absent", () => {
    // Arrange
    const seeded = seedTree();

    // Act
    const manifest = readExclusionManifest(seeded, DEST);
    const summary = publish(seeded);

    // Assert
    expect(manifest).toBeUndefined();
    expect("exclusions" in summary).toBe(false);
  });

  it("throws ExclusionManifestError when a directory sits at the manifest path", () => {
    // Arrange
    const seeded = seedTree();
    seeded.seedDir(MANIFEST);

    // Act
    const error = captureError(() => publish(seeded));

    // Assert
    expect(error).toBeInstanceOf(ExclusionManifestError);
    expect((error as ExclusionManifestError).path).toBe(
      ".push-down-exclusions",
    );
    expect((error as ExclusionManifestError).line).toBeUndefined();
    expect(seeded.writtenPaths).toEqual([]);
  });

  it("fails before any write, directory creation, or artifact write on a malformed manifest", () => {
    // Arrange
    const seeded = seedWithManifest(`${RULE}\n!x\n`);

    // Act
    const error = captureError(() => publish(seeded));

    // Assert
    expect(error).toBeInstanceOf(ExclusionManifestError);
    expect((error as ExclusionManifestError).message).toContain("line 2");
    expect(seeded.writtenPaths).toEqual([]);
    expect(seeded.ensuredDirs).toEqual([]);
  });

  it("skips an absent destination path and records destination_status absent", () => {
    // Arrange
    const seeded = seedWithManifest(`${RULE}\n`);

    // Act
    const summary = publish(seeded);

    // Assert
    expect(seeded.writtenPaths).not.toContain(`${DEST}/${RULE}`);
    expect(summary.files.map((file) => file.relativePath)).not.toContain(RULE);
    expect(summary.createdCount + summary.overwrittenCount).toBe(
      summary.files.length,
    );
    expect(summary.exclusions?.skipped).toEqual([
      {
        relativePath: RULE,
        entry: RULE,
        line: 1,
        destinationStatus: "absent",
      },
    ]);
  });

  it("leaves a present destination file byte-identical and counts a conflict", () => {
    // Arrange
    const seeded = seedWithManifest(`${RULE}\n`, {
      [`${DEST}/${RULE}`]: "local\n",
    });

    // Act
    const summary = publish(seeded);

    // Assert
    expect(seeded.readTextFile(`${DEST}/${RULE}`)).toBe("local\n");
    expect(seeded.writtenPaths).not.toContain(`${DEST}/${RULE}`);
    expect(summary.exclusions?.skipped[0]?.destinationStatus).toBe("present");
    const exclusions = readArtifact(seeded, summary.artifactPath)[
      "exclusions"
    ] as Record<string, unknown>;
    expect(exclusions["conflict_count"]).toBe(1);
  });

  it("reports an entry that matches no payload path and completes normally", () => {
    // Arrange
    const seeded = seedWithManifest(".claude/agent-memory/**\n");

    // Act
    const summary = publish(seeded);

    // Assert
    expect(summary.exclusions?.skipped).toEqual([]);
    expect(
      summary.exclusions?.unmatchedEntries.map((entry) => entry.normalized),
    ).toEqual([".claude/agent-memory/**"]);
    expect(
      summary.exclusions === undefined
        ? []
        : renderExclusionLines(summary.exclusions),
    ).toEqual([
      "push-down exclusion: entry matched no payload path: .claude/agent-memory/** (line 1)",
    ]);
  });

  it("write guard throws for a matched path and for the manifest path", () => {
    // Arrange
    const inner = buildInMemoryFileSystem({}, [DEST]);
    const manifest = parseExclusionManifest(
      "config/x.json\nartifacts/**\n",
      ".push-down-exclusions",
    );
    const filter = new ExclusionFilterFileSystem(inner, SRC, DEST, manifest);

    // Act
    const matched = captureError(() => {
      filter.writeTextFile(`${DEST}/config/x.json`, "{}");
    });
    const manifestWrite = captureError(() => {
      filter.writeTextFile(MANIFEST, "x\n");
    });
    filter.writeTextFile(
      `${DEST}/artifacts/claude-customizations/x.json`,
      "{}",
    );
    filter.writeTextFile(`${DEST}/config/kept.json`, "{}");
    filter.writeTextFile(`${SRC}/config/x.json`, "{}");

    // Assert
    expect(matched).toBeInstanceOf(ExclusionViolationError);
    expect((matched as Error).message).toContain("config/x.json");
    expect(manifestWrite).toBeInstanceOf(ExclusionViolationError);
    expect(inner.writtenPaths).toEqual([
      `${DEST}/artifacts/claude-customizations/x.json`,
      `${DEST}/config/kept.json`,
      `${SRC}/config/x.json`,
    ]);
  });

  it("never writes the manifest path and leaves its content unchanged", () => {
    // Arrange
    const manifestText = "# local\n.claude/agent-memory/**\n";
    const seeded = seedWithManifest(manifestText);

    // Act
    publish(seeded);

    // Assert
    expect(seeded.writtenPaths).not.toContain(MANIFEST);
    expect(seeded.readTextFile(MANIFEST)).toBe(manifestText);
  });

  it("neither reads nor writes an excluded routing-merge destination document", () => {
    // Arrange
    const destinationRouting = `${DEST}/config/orchestration-routing.json`;
    const localRouting = '{"version": 3, "routes": {"local": {}}}\n';
    const seeded = seedWithManifest("config/orchestration-routing.json\n", {
      [destinationRouting]: localRouting,
    });
    const readSpy = jest.spyOn(seeded, "readTextFile");

    // Act
    const summary = publish(seeded);

    // Assert
    expect(readSpy.mock.calls.map(([path]) => path)).not.toContain(
      destinationRouting,
    );
    expect(seeded.writtenPaths).not.toContain(destinationRouting);
    readSpy.mockRestore();
    expect(seeded.readTextFile(destinationRouting)).toBe(localRouting);
    expect(summary.exclusions?.skipped[0]?.destinationStatus).toBe("present");
  });

  it("never invokes the layout lister when config/blast-radius.json is excluded", () => {
    // Arrange
    const seeded = seedWithManifest("config/blast-radius.json\n");
    const lister: DirectoryLister = () => {
      throw new Error("layout lister must not be invoked");
    };

    // Act
    const summary = publish(seeded, null, lister);

    // Assert
    expect(seeded.writtenPaths).not.toContain(
      `${DEST}/config/blast-radius.json`,
    );
    expect(
      summary.exclusions?.skipped.map((skip) => skip.relativePath),
    ).toEqual(["config/blast-radius.json"]);
  });

  it("skips the gitignore delivery when .gitignore is excluded and records its status", () => {
    // Arrange
    const absentRun = seedWithManifest(".gitignore\n");
    const presentRun = seedWithManifest(".gitignore\n", {
      [`${DEST}/.gitignore`]: "node_modules/\n",
    });

    // Act
    const absentSummary = publish(absentRun);
    const presentSummary = publish(presentRun);

    // Assert
    expect(absentRun.writtenPaths).not.toContain(`${DEST}/.gitignore`);
    expect(absentRun.isFile(`${DEST}/.gitignore`)).toBe(false);
    expect(absentSummary.exclusions?.skipped).toEqual([
      {
        relativePath: ".gitignore",
        entry: ".gitignore",
        line: 1,
        destinationStatus: "absent",
      },
    ]);
    expect(presentRun.writtenPaths).not.toContain(`${DEST}/.gitignore`);
    expect(presentRun.readTextFile(`${DEST}/.gitignore`)).toBe(
      "node_modules/\n",
    );
    expect(presentSummary.exclusions?.skipped[0]?.destinationStatus).toBe(
      "present",
    );
    expect(presentSummary.exclusions?.unmatchedEntries).toEqual([]);
  });

  it("produces a byte-identical artifact, a single artifact write, and no exclusions key without a manifest", () => {
    // Arrange
    const seeded = seedTree();

    // Act
    const summary = publish(seeded);

    // Assert
    const text = seeded.readTextFile(summary.artifactPath);
    expect(text).toBe(renderPushDownSummary(summary));
    expect(Object.keys(JSON.parse(text) as object)).not.toContain("exclusions");
    expect(
      seeded.writtenPaths.filter((p) => p === summary.artifactPath).length,
    ).toBe(1);
    expect(summary.exclusions).toBeUndefined();
  });

  it("writes the sorted exclusions object into the artifact only when a manifest was read", () => {
    // Arrange
    const seeded = seedWithManifest(`${RULE}\n.claude/agent-memory/**\n`);

    // Act
    const summary = publish(seeded);

    // Assert
    const text = seeded.readTextFile(summary.artifactPath);
    expect(text).toBe(stringifySorted(JSON.parse(text), 2));
    const exclusions = readArtifact(seeded, summary.artifactPath)[
      "exclusions"
    ] as Record<string, unknown>;
    expect(Object.keys(exclusions).sort()).toEqual([
      "conflict_count",
      "entries",
      "manifest_path",
      "skipped",
      "skipped_count",
      "unmatched_entries",
    ]);
    const skipped = exclusions["skipped"] as Array<Record<string, unknown>>;
    expect(skipped.map((skip) => Object.keys(skip).sort())).toEqual([
      ["destination_status", "entry", "line", "relative_path"],
    ]);
    expect(exclusions).toEqual({
      conflict_count: 0,
      entries: [RULE, ".claude/agent-memory/**"],
      manifest_path: ".push-down-exclusions",
      skipped: [
        {
          destination_status: "absent",
          entry: RULE,
          line: 1,
          relative_path: RULE,
        },
      ],
      skipped_count: 1,
      unmatched_entries: [".claude/agent-memory/**"],
    });
  });

  it("is composed outermost so pack-excluded paths are reported as unmatched", () => {
    // Arrange: a source file outside the core pack is removed by pack
    // selection before the exclusion filter sees the enumeration.
    const outsidePack = ".claude/rules/outside-pack.md";
    const extra = { [`${SRC}/${outsidePack}`]: "# outside\n" };
    const packRun = seedWithManifest(`${outsidePack}\n`, extra);
    const unscopedRun = seedWithManifest(`${outsidePack}\n`, extra);

    // Act
    const packSummary = publish(packRun, new Set(["core"]));
    const unscopedSummary = publish(unscopedRun);

    // Assert
    expect(packSummary.exclusions?.skipped).toEqual([]);
    expect(
      packSummary.exclusions?.unmatchedEntries.map((entry) => entry.normalized),
    ).toEqual([outsidePack]);
    expect(
      unscopedSummary.exclusions?.skipped.map((skip) => skip.relativePath),
    ).toEqual([outsidePack]);
  });
});
