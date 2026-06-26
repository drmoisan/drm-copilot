import { afterEach, describe, expect, it } from "@jest/globals";

import {
  ARTIFACT_DIRECTORY,
  pushDownCustomizations,
  resolveCliPath,
} from "../../../src/lib/push-down/copilot-customizations";
import {
  buildArtifactPath,
  renderPushDownSummary,
  type PushDownSummary,
} from "../../../src/lib/push-down/copilot-customizations-engine";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

const CLOCK = fixedClock("2026-06-26T00:15:00.000Z");

describe("resolveCliPath", () => {
  const originalPlatform = process.platform;

  afterEach(() => {
    // Restore the real platform after any override.
    Object.defineProperty(process, "platform", {
      value: originalPlatform,
      configurable: true,
    });
  });

  it("returns a Windows-absolute drive-letter path unchanged on a POSIX host", () => {
    // Arrange: force a POSIX host so the Windows-absolute guard branch runs.
    Object.defineProperty(process, "platform", {
      value: "linux",
      configurable: true,
    });

    // Act
    const result = resolveCliPath("C:\\workspace\\dest");

    // Assert: the drive-letter path is returned verbatim, not mangled.
    expect(result).toBe("C:\\workspace\\dest");
  });

  it("returns a Windows UNC path unchanged on a POSIX host", () => {
    // Arrange
    Object.defineProperty(process, "platform", {
      value: "linux",
      configurable: true,
    });

    // Act / Assert
    expect(resolveCliPath("\\\\server\\share\\dir")).toBe(
      "\\\\server\\share\\dir",
    );
  });

  it("resolves a relative path to an absolute path", () => {
    // Arrange / Act
    const result = resolveCliPath(".");

    // Assert
    expect(result.length).toBeGreaterThan(1);
  });
});

describe("buildArtifactPath", () => {
  it("names the artifact deterministically under the artifact directory", () => {
    // Arrange
    const startedAt = new Date("2026-06-26T00:15:00.000Z");

    // Act
    const result = buildArtifactPath(startedAt, "/dest", ARTIFACT_DIRECTORY);

    // Assert
    expect(result).toBe(
      "/dest/artifacts/copilot-customizations/push-down-20260626T001500Z.json",
    );
  });
});

describe("renderPushDownSummary", () => {
  it("renders the exact top-level JSON key set, sorted, with 2-space indent", () => {
    // Arrange
    const summary: PushDownSummary = {
      repoRoot: "/src",
      destinationRoot: "/dest",
      startedAt: new Date("2026-06-26T00:15:00.000Z"),
      finishedAt: new Date("2026-06-26T00:15:01.000Z"),
      createdCount: 1,
      overwrittenCount: 0,
      rewrittenReferenceCount: 0,
      placeholderRewriteCount: 0,
      unmatchedReferences: [],
      files: [
        {
          relativePath: ".github/agents/a.md",
          destinationStatus: "created",
          rewrittenReferenceCount: 0,
          placeholderRewriteCount: 0,
          unmatchedReferences: [],
        },
      ],
      artifactPath: "",
    };

    // Act
    const rendered = renderPushDownSummary(summary);
    const parsed = JSON.parse(rendered) as Record<string, unknown>;

    // Assert: exact top-level key set (order-independent membership).
    expect(Object.keys(parsed).sort()).toEqual(
      [
        "repo_root",
        "destination_root",
        "started_at",
        "finished_at",
        "created_count",
        "overwritten_count",
        "rewritten_reference_count",
        "placeholder_rewrite_count",
        "unmatched_references",
        "files",
      ].sort(),
    );

    // Assert: keys are emitted in sorted order and indentation is two spaces.
    const emittedKeyOrder = rendered
      .split("\n")
      .map((line) => /^ {2}"([a-z_]+)":/.exec(line)?.[1])
      .filter((key): key is string => key !== undefined);
    expect(emittedKeyOrder).toEqual([...emittedKeyOrder].sort());
    expect(rendered).toContain('\n  "created_count": 1');
  });

  it("renders per-file objects with the parity snake_case field names", () => {
    // Arrange
    const summary: PushDownSummary = {
      repoRoot: "/src",
      destinationRoot: "/dest",
      startedAt: new Date("2026-06-26T00:15:00.000Z"),
      finishedAt: new Date("2026-06-26T00:15:01.000Z"),
      createdCount: 1,
      overwrittenCount: 0,
      rewrittenReferenceCount: 0,
      placeholderRewriteCount: 0,
      unmatchedReferences: [],
      files: [
        {
          relativePath: ".github/agents/a.md",
          destinationStatus: "created",
          rewrittenReferenceCount: 0,
          placeholderRewriteCount: 0,
          unmatchedReferences: ["scripts.dev_tools.unknown"],
        },
      ],
      artifactPath: "",
    };

    // Act
    const parsed = JSON.parse(renderPushDownSummary(summary)) as {
      files: Array<Record<string, unknown>>;
    };

    // Assert
    expect(Object.keys(parsed.files[0]!).sort()).toEqual(
      [
        "relative_path",
        "destination_status",
        "rewritten_reference_count",
        "placeholder_rewrite_count",
        "unmatched_references",
      ].sort(),
    );
  });
});

describe("pushDownCustomizations (public wrapper)", () => {
  it("defaults the copilot root folders and rewrite function", () => {
    // Arrange: a known rewrite reference under a copilot root proves both
    // defaults (root folders enumerated, rewrite applied) without overrides.
    const fs = buildInMemoryFileSystem(
      {
        "/src/.github/prompts/p.prompt.md":
          "Run scripts.dev_tools.potential_to_issue now.",
      },
      ["/dest"],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      clock: CLOCK,
    });

    // Assert
    expect(summary.rewrittenReferenceCount).toBe(1);
    expect(fs.readTextFile("/dest/.github/prompts/p.prompt.md")).toContain(
      "command ID: `drmCopilotExtension.potentialToIssue`",
    );
    expect(ARTIFACT_DIRECTORY).toBe("artifacts/copilot-customizations");
  });

  it("defaults sourceRoot/artifactRoot to repoRoot and uses a real clock when omitted", () => {
    // Arrange: omit sourceRoot, artifactRoot, and clock to exercise the
    // option-defaulting branches in the public wrapper.
    const fs = buildInMemoryFileSystem(
      { "/repo/.github/agents/a.md": "body" },
      ["/dest-omit"],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/repo",
      destinationRoot: "/dest-omit",
      fs,
    });

    // Assert: artifact path is rooted at repoRoot (the default artifact root).
    expect(summary.artifactPath).toContain(
      "/repo/artifacts/copilot-customizations/push-down-",
    );
  });
});
