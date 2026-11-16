/**
 * Unit tests for the development-docs root resolver (issue #1035).
 *
 * Each resolution rule is titled by its spec ID (R-1 to R-8). Every case uses
 * an in-memory reader; no test touches the file system.
 */
import {
  DEFAULT_DEVELOPMENT_DOCS_ROOT,
  DEVELOPMENT_DOCS_AREAS,
  DEVELOPMENT_DOCS_ROOT_KEY,
  KNOWN_DEVELOPMENT_DOCS_ROOTS,
  developmentDocsPath,
  isKnownDevelopmentDocsRoot,
  knownRootPrefixes,
  resolveDevelopmentDocsRoot,
  type DevelopmentDocsArea,
  type DevelopmentDocsReader,
  type DevelopmentDocsRoot,
} from "../../../src/lib/development-docs/root";

const WORKSPACE = "/ws";
const CONFIG = "/ws/config/orchestration-routing.json";

/** In-memory reader with call counters. */
class FakeReader implements DevelopmentDocsReader {
  readonly directoryProbes: string[] = [];

  constructor(
    private readonly files: Readonly<Record<string, string>>,
    private readonly directories: ReadonlySet<string> = new Set(),
    private readonly unreadable: ReadonlySet<string> = new Set(),
  ) {}

  exists(path: string): boolean {
    return (
      path in this.files ||
      this.unreadable.has(path) ||
      this.directories.has(path)
    );
  }

  isDirectory(path: string): boolean {
    this.directoryProbes.push(path);
    return this.directories.has(path);
  }

  readTextFile(path: string): string {
    if (this.unreadable.has(path)) {
      throw new Error(`EACCES: ${path}`);
    }
    const text = this.files[path];
    if (text === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return text;
  }
}

/** Build routing JSON text carrying the key with the given raw value. */
function routingWith(value: unknown): string {
  return JSON.stringify({ version: 1, [DEVELOPMENT_DOCS_ROOT_KEY]: value });
}

describe("resolveDevelopmentDocsRoot", () => {
  it("R-1 resolves docs/features when the routing file is absent", () => {
    // Arrange
    const reader = new FakeReader({});
    // Act
    const root = resolveDevelopmentDocsRoot(reader, WORKSPACE);
    // Assert
    expect(root).toBe("docs/features");
    expect(reader.directoryProbes).toEqual([]);
  });

  it("R-1 resolves docs/features when the routing file is unreadable", () => {
    const reader = new FakeReader({}, new Set(), new Set([CONFIG]));
    expect(resolveDevelopmentDocsRoot(reader, WORKSPACE)).toBe("docs/features");
  });

  it("R-2 resolves docs/features when the key is absent and never probes .dev", () => {
    // Arrange: .dev exists, which must not matter when the key is absent (OQ-1).
    const reader = new FakeReader(
      { [CONFIG]: JSON.stringify({ version: 1 }) },
      new Set(["/ws/.dev"]),
    );
    // Act
    const root = resolveDevelopmentDocsRoot(reader, WORKSPACE);
    // Assert
    expect(root).toBe("docs/features");
    expect(reader.directoryProbes).toEqual([]);
  });

  it("R-3 throws an error naming the file, key and value for malformed JSON", () => {
    const reader = new FakeReader({ [CONFIG]: "{ not json" });
    expect(() => resolveDevelopmentDocsRoot(reader, WORKSPACE)).toThrow(
      /config\/orchestration-routing\.json.*development_docs_root.*value: unparseable/,
    );
  });

  it("R-3 throws an error naming the file, key and value for a non-object document", () => {
    const reader = new FakeReader({ [CONFIG]: "[1]" });
    expect(() => resolveDevelopmentDocsRoot(reader, WORKSPACE)).toThrow(
      /config\/orchestration-routing\.json.*development_docs_root.*value: \[1\]/,
    );
  });

  it.each([
    ["other string", "docs/other", '"docs/other"'],
    ["blank", "  ", '"  "'],
    ["non-string", 7, "7"],
    ["backslash", "docs\\features", '"docs\\\\features"'],
    ["leading slash", "/docs/features", '"/docs/features"'],
    ["dot-dot segment", "../.dev", '"../.dev"'],
  ])(
    "R-4 throws an error naming the file, key and value for %s",
    (_label, value, rendered) => {
      // Arrange
      const reader = new FakeReader({ [CONFIG]: routingWith(value) });
      // Act
      const act = (): DevelopmentDocsRoot =>
        resolveDevelopmentDocsRoot(reader, WORKSPACE);
      // Assert
      expect(act).toThrow("config/orchestration-routing.json");
      expect(act).toThrow("development_docs_root");
      expect(act).toThrow(
        `value ${rendered} is not one of: docs/features, .dev.`,
      );
    },
  );

  it("R-4 throws for a null value", () => {
    const reader = new FakeReader({ [CONFIG]: routingWith(null) });
    expect(() => resolveDevelopmentDocsRoot(reader, WORKSPACE)).toThrow(
      "value null is not one of",
    );
  });

  it("R-5 resolves docs/features for value docs/features whether or not .dev exists", () => {
    const reader = new FakeReader(
      { [CONFIG]: routingWith("docs/features") },
      new Set(["/ws/.dev"]),
    );
    expect(resolveDevelopmentDocsRoot(reader, WORKSPACE)).toBe("docs/features");
    expect(reader.directoryProbes).toEqual([]);
  });

  it("R-6 resolves .dev for value .dev when .dev exists", () => {
    const reader = new FakeReader(
      { [CONFIG]: routingWith(".dev") },
      new Set(["/ws/.dev"]),
    );
    expect(resolveDevelopmentDocsRoot(reader, WORKSPACE)).toBe(".dev");
  });

  it("R-7 falls back to docs/features for value .dev when only docs/features exists", () => {
    const reader = new FakeReader(
      { [CONFIG]: routingWith(".dev") },
      new Set(["/ws/docs/features"]),
    );
    expect(resolveDevelopmentDocsRoot(reader, WORKSPACE)).toBe("docs/features");
  });

  it("R-8 resolves .dev for value .dev when neither directory exists", () => {
    const reader = new FakeReader({ [CONFIG]: routingWith(".dev") });
    expect(resolveDevelopmentDocsRoot(reader, WORKSPACE)).toBe(".dev");
    expect(reader.directoryProbes).toEqual(["/ws/.dev", "/ws/docs/features"]);
  });

  it("joins a backslash workspace root with forward slashes", () => {
    const reader = new FakeReader(
      { "C:/ws/config/orchestration-routing.json": routingWith(".dev") },
      new Set(["C:/ws/.dev"]),
    );
    expect(resolveDevelopmentDocsRoot(reader, "C:\\ws\\")).toBe(".dev");
  });

  it("reads a config at an empty workspace root as a relative path", () => {
    const reader = new FakeReader(
      { "config/orchestration-routing.json": routingWith(".dev") },
      new Set([".dev"]),
    );
    expect(resolveDevelopmentDocsRoot(reader, "")).toBe(".dev");
  });
});

describe("constants", () => {
  it("lists the known roots in order with the default first", () => {
    expect(KNOWN_DEVELOPMENT_DOCS_ROOTS).toEqual(["docs/features", ".dev"]);
    expect(DEFAULT_DEVELOPMENT_DOCS_ROOT).toBe("docs/features");
    expect(DEVELOPMENT_DOCS_ROOT_KEY).toBe("development_docs_root");
  });

  it("narrows only exact known roots", () => {
    expect(isKnownDevelopmentDocsRoot(".dev")).toBe(true);
    expect(isKnownDevelopmentDocsRoot("docs/features/")).toBe(false);
    expect(isKnownDevelopmentDocsRoot(undefined)).toBe(false);
  });
});

const AREA_TABLE: ReadonlyArray<[DevelopmentDocsArea, string, string]> = [
  ["active", "docs/features/active", ".dev/active"],
  ["completed", "docs/features/completed", ".dev/completed"],
  ["archive", "docs/features/archive", ".dev/archive"],
  ["potential", "docs/features/potential", ".dev/potential"],
  [
    "potential/promoted",
    "docs/features/potential/promoted",
    ".dev/potential/promoted",
  ],
  ["epics", "docs/features/epics", ".dev/epics"],
  ["parallel", "docs/features/parallel", ".dev/parallel"],
  ["templates", "docs/features/templates", ".dev/templates"],
  ["backlog", "docs/features/backlog.md", ".dev/backlog.md"],
  ["research", "docs/research", ".dev/research"],
  [
    "discovery-templates",
    "docs/discovery/templates",
    ".dev/discovery/templates",
  ],
  ["engineering", "docs/engineering", ".dev/engineering"],
];

describe("developmentDocsPath", () => {
  it("covers every area of the area map", () => {
    expect(AREA_TABLE.map(([area]) => area)).toEqual(DEVELOPMENT_DOCS_AREAS);
  });

  it.each(AREA_TABLE)(
    "maps area %s under both roots",
    (area, docsForm, devForm) => {
      expect(developmentDocsPath("docs/features", area)).toBe(docsForm);
      expect(developmentDocsPath(".dev", area)).toBe(devForm);
    },
  );

  it("unknown area raises an explicit error", () => {
    expect(() =>
      developmentDocsPath(".dev", "nope" as DevelopmentDocsArea),
    ).toThrow("Unknown development docs area: nope");
  });
});

describe("knownRootPrefixes", () => {
  it.each(AREA_TABLE)(
    "returns both root forms for area %s",
    (area, docsForm, devForm) => {
      const suffix = area === "backlog" ? "" : "/";
      expect(knownRootPrefixes(area)).toEqual([
        `${docsForm}${suffix}`,
        `${devForm}${suffix}`,
      ]);
    },
  );

  it("unknown area raises an explicit error", () => {
    expect(() =>
      knownRootPrefixes("constructor" as DevelopmentDocsArea),
    ).toThrow("Unknown development docs area: constructor");
  });
});
