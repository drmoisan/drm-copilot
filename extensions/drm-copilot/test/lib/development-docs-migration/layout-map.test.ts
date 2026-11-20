import { describe, expect, it } from "@jest/globals";

import {
  isMappedTargetPath,
  LEGACY_LAYOUT_MAP,
  mapLegacyPath,
  rowTarget,
} from "../../../src/lib/development-docs-migration/layout-map";

const TARGET = ".dev/discovery/templates";

describe("LEGACY_LAYOUT_MAP", () => {
  it.each([
    ["docs/features/potential/promoted/x.md", ".dev/potential/promoted/x.md"],
    ["docs/features/potential/template.md", ".dev/potential/template.md"],
    ["docs/features/active/f/spec.md", ".dev/active/f/spec.md"],
    ["docs/features/completed/f/plan.md", ".dev/completed/f/plan.md"],
    ["docs/features/archive/f/a.md", ".dev/archive/f/a.md"],
    ["docs/features/epics/e/epic.md", ".dev/epics/e/epic.md"],
    ["docs/features/parallel/p/status.md", ".dev/parallel/p/status.md"],
    [
      "docs/features/templates/feature/spec.md",
      ".dev/templates/feature/spec.md",
    ],
    ["docs/features/research/r.md", ".dev/research/r.md"],
    ["docs/features/backlog.md", ".dev/backlog.md"],
    ["docs/research/r.md", ".dev/research/r.md"],
    ["docs/engineering/x.md", ".dev/engineering/x.md"],
    [
      "docs/discovery/templates/v2/a.json",
      ".dev/discovery/templates/v2/a.json",
    ],
  ])("maps %s to %s", (source, expected) => {
    // Act
    const result = mapLegacyPath(source, TARGET);

    // Assert
    expect(result).toMatchObject({ kind: "mapped", target: expected });
  });

  it("orders rows longest prefix first", () => {
    // Arrange
    const lengths = LEGACY_LAYOUT_MAP.map((row) => row.from.length);
    const research = LEGACY_LAYOUT_MAP.findIndex(
      (row) => row.from === "docs/features/research/",
    );
    const discovery = LEGACY_LAYOUT_MAP.findIndex(
      (row) => row.from === "docs/discovery/templates/",
    );

    // Assert
    expect(lengths).toEqual([...lengths].sort((a, b) => b - a));
    expect(research).toBeLessThan(
      LEGACY_LAYOUT_MAP.findIndex((row) => row.from === "docs/research/"),
    );
    expect(discovery).toBeGreaterThanOrEqual(0);
    expect(LEGACY_LAYOUT_MAP).toHaveLength(12);
  });

  it("maps a directory path without its trailing slash", () => {
    // Act / Assert
    expect(mapLegacyPath("docs/features/active", TARGET)).toMatchObject({
      kind: "mapped",
      target: ".dev/active",
    });
  });

  it("takes the OQ-1 target from the argument", () => {
    // Act
    const alternative = mapLegacyPath(
      "docs/discovery/templates/v2/a.json",
      ".dev/templates/",
    );

    // Assert
    expect(alternative).toMatchObject({
      kind: "mapped",
      target: ".dev/templates/v2/a.json",
    });
  });

  it("marks only the active, completed and archive rows as renaming folders", () => {
    // Act
    const renaming = LEGACY_LAYOUT_MAP.filter((row) => row.renamesFolders).map(
      (row) => row.from,
    );

    // Assert
    expect(renaming.sort()).toEqual([
      "docs/features/active/",
      "docs/features/archive/",
      "docs/features/completed/",
    ]);
  });

  it("substitutes the OQ-1 target only for the discovery row", () => {
    // Arrange
    const discoveryRow = LEGACY_LAYOUT_MAP.find((row) => row.discovery);
    const activeRow = LEGACY_LAYOUT_MAP.find(
      (row) => row.from === "docs/features/active/",
    );

    // Assert
    expect(discoveryRow && rowTarget(discoveryRow, "x/y/")).toBe("x/y/");
    expect(activeRow && rowTarget(activeRow, "x/y")).toBe(".dev/active/");
  });
});

describe("mapLegacyPath path classes (decision A1)", () => {
  it("reports an entry under docs/features with no row as unmapped", () => {
    expect(mapLegacyPath("docs/features/unknown-area/x.md", TARGET)).toEqual({
      kind: "unmapped",
    });
  });

  it.each(["docs/README.md", "docs/documentation-estate/docs-profile.json"])(
    "retains production documentation %s",
    (path) => {
      expect(mapLegacyPath(path, TARGET)).toEqual({ kind: "retained" });
    },
  );

  it("maps docs/engineering/documentation-estate with docs/engineering", () => {
    expect(
      mapLegacyPath("docs/engineering/documentation-estate/x.md", TARGET),
    ).toMatchObject({
      kind: "mapped",
      target: ".dev/engineering/documentation-estate/x.md",
    });
  });

  it("classifies a path outside docs as outside", () => {
    expect(mapLegacyPath("src/x.ts", TARGET)).toEqual({ kind: "outside" });
  });
});

describe("isMappedTargetPath (finding F1)", () => {
  it.each([
    ".dev/potential/x.md",
    ".dev/active/1016-foo/spec.md",
    ".dev/completed/0012-bar/plan.md",
    ".dev/archive/f/a.md",
    ".dev/epics/e/epic.md",
    ".dev/parallel/p/status.md",
    ".dev/templates/feature/plan.md",
    ".dev/research/r.md",
    ".dev/engineering/x.md",
    ".dev/discovery/templates/v2/a.json",
    ".dev/active",
    ".dev/discovery/templates",
    ".dev/backlog.md",
  ])("reports %s as a mapped target path", (path) => {
    // Act / Assert
    expect(isMappedTargetPath(path, TARGET)).toBe(true);
  });

  it("covers the target of every row of the table", () => {
    // Arrange
    const samples = LEGACY_LAYOUT_MAP.map((row) => {
      const target = rowTarget(row, TARGET);
      return row.kind === "file" ? target : `${target}x.md`;
    });

    // Assert
    expect(samples.every((path) => isMappedTargetPath(path, TARGET))).toBe(
      true,
    );
  });

  it("takes the discovery target from the argument", () => {
    // Act / Assert
    expect(isMappedTargetPath(".dev/kits/v2/a.json", ".dev/kits/")).toBe(true);
    expect(isMappedTargetPath(".dev/kits/v2/a.json", TARGET)).toBe(false);
  });

  it.each([
    ".dev/other/x.md",
    "docs/README.md",
    "README.md",
    ".dev/activex/a.md",
  ])("reports %s as not a mapped target path", (path) => {
    // Act / Assert
    expect(isMappedTargetPath(path, TARGET)).toBe(false);
  });
});
