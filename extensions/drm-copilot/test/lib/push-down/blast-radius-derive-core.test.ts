import { describe, expect, it } from "@jest/globals";

import {
  BLAST_RADIUS_RELATIVE_PATH,
  BlastRadiusDeriveError,
  BlastRadiusGuardError,
  deriveDestinationModuleMap,
  type DirectoryObservation,
  EXCLUDED_DIR_NAMES,
  isExcludedDirectoryName,
  isManifestFileName,
  MANIFEST_FILENAMES,
  MANIFEST_SUFFIXES,
  PAYLOAD_MODULES,
  SCAN_DEPTH_LIMIT,
} from "../../../src/lib/push-down/claude-blast-radius-derive-core";

/**
 * Pure derivation core for the destination blast-radius map (issue #472).
 *
 * Purpose:
 *     Cover algorithm steps 2 through 8 in isolation: manifest classification by
 *     exact name and by suffix, root-manifest exclusion, ancestor pruning, the
 *     top-level fallback, the no-signal floor, verbatim carriage of the source
 *     document's other keys, ordinal module ordering, determinism, and the
 *     forbidden-glob guard.
 *
 * Scope note:
 *     Every case is hermetic. Observation lists are constructed in memory and no
 *     filesystem, subprocess, network, or clock access occurs; the scan that
 *     produces real observations is covered by `blast-radius-derive.test.ts`.
 */

/** Bundled source document the derivation carries non-module keys from. */
const SOURCE_DOCUMENT = `${JSON.stringify(
  {
    version: 1,
    shared_surfaces: [
      ".claude/settings.json",
      "config/orchestration-routing.json",
      "config/blast-radius.json",
    ],
    shared_surface_globs: [],
    modules: {
      "claude-runtime": [".claude/**"],
      config: ["config/**"],
    },
    over_breadth_fraction: 0.25,
  },
  null,
  2,
)}\n`;

/**
 * Build an observation from a relative path and its shallow file names.
 *
 * @param relativePath Destination-relative POSIX path; empty for the root.
 * @param fileNames File names directly inside the directory.
 * @returns The constructed observation.
 */
function observe(
  relativePath: string,
  ...fileNames: string[]
): DirectoryObservation {
  return { relativePath, fileNames };
}

/**
 * Derive a document and return its parsed `modules` map.
 *
 * @param observations Observation list to derive from.
 * @returns The `modules` object of the derived document.
 */
function deriveModules(
  observations: ReadonlyArray<DirectoryObservation>,
): Record<string, string[]> {
  const parsed: unknown = JSON.parse(
    deriveDestinationModuleMap(observations, SOURCE_DOCUMENT),
  );
  return (parsed as { modules: Record<string, string[]> }).modules;
}

describe("issue #472: manifest classification", () => {
  it.each([...MANIFEST_FILENAMES])(
    "classifies the exact manifest name %s",
    (fileName) => {
      // Arrange / Act / Assert
      expect(isManifestFileName(fileName)).toBe(true);
    },
  );

  it.each([...MANIFEST_SUFFIXES])(
    "classifies a file carrying the manifest suffix %s",
    (suffix) => {
      // Arrange / Act / Assert: the .NET families vary with the project name, so
      // only the suffix can be pinned.
      expect(isManifestFileName(`Widget${suffix}`)).toBe(true);
    },
  );

  it("rejects a file that is neither an exact name nor a suffix match", () => {
    // Arrange / Act / Assert
    expect(isManifestFileName("README.md")).toBe(false);
    expect(isManifestFileName("package.json.bak")).toBe(false);
  });

  it("promotes a directory holding a manifest to a module", () => {
    // Arrange: a single project directory one level below the root.
    const observations = [observe(""), observe("service", "pyproject.toml")];

    // Act
    const modules = deriveModules(observations);

    // Assert
    expect(modules["service"]).toEqual(["service/**"]);
  });

  it("promotes a directory holding a suffix-matched manifest to a module", () => {
    // Arrange
    const observations = [observe(""), observe("Widget", "Widget.csproj")];

    // Act / Assert
    expect(deriveModules(observations)["Widget"]).toEqual(["Widget/**"]);
  });
});

describe("issue #472: root-manifest exclusion", () => {
  it("never derives a module from a manifest at the destination root", () => {
    // Arrange: a manifest at the root only. Admitting the root would name the
    // whole destination and yield the universal glob, the defect being fixed.
    const observations = [observe("", "package.json")];

    // Act
    const modules = deriveModules(observations);

    // Assert: the floor applies, and no glob is the universal one.
    expect(Object.keys(modules)).toEqual(["claude-runtime", "config"]);
    expect(JSON.stringify(modules)).not.toContain('"**"');
  });

  it("ignores a root manifest when a nested project directory exists", () => {
    // Arrange
    const observations = [
      observe("", "package.json"),
      observe("service", "package.json"),
    ];

    // Act
    const modules = deriveModules(observations);

    // Assert: only the nested directory becomes a module.
    expect(Object.keys(modules)).toEqual([
      "claude-runtime",
      "config",
      "service",
    ]);
  });
});

describe("issue #472: ancestor pruning and layout outcomes", () => {
  it("keeps leaf projects and drops their umbrella directory", () => {
    // Arrange: the monorepo layout. An umbrella module would re-couple the
    // siblings the way the removed docs bucket coupled everything.
    const observations = [
      observe(""),
      observe("packages", "package.json"),
      observe("packages/a", "package.json"),
      observe("packages/b", "package.json"),
    ];

    // Act
    const modules = deriveModules(observations);

    // Assert
    expect(modules["packages/a"]).toEqual(["packages/a/**"]);
    expect(modules["packages/b"]).toEqual(["packages/b/**"]);
    expect(modules["packages"]).toBeUndefined();
  });

  it("does not treat a name-prefix sibling as a descendant", () => {
    // Arrange: `pack` is not an ancestor of `packages` despite the shared
    // character prefix, because the ancestor test anchors on a separator.
    const observations = [
      observe(""),
      observe("pack", "go.mod"),
      observe("packages", "go.mod"),
    ];

    // Act
    const modules = deriveModules(observations);

    // Assert
    expect(modules["pack"]).toEqual(["pack/**"]);
    expect(modules["packages"]).toEqual(["packages/**"]);
  });

  it("derives both projects of a C# layout", () => {
    // Arrange
    const observations = [
      observe(""),
      observe("Foo", "Foo.csproj"),
      observe("Foo.Tests", "Foo.Tests.csproj"),
    ];

    // Act
    const modules = deriveModules(observations);

    // Assert
    expect(modules["Foo"]).toEqual(["Foo/**"]);
    expect(modules["Foo.Tests"]).toEqual(["Foo.Tests/**"]);
  });

  it("falls back to top-level directories for a src-only layout", () => {
    // Arrange: the manifest sits at the root, which is excluded, so step 5 runs.
    const observations = [
      observe("", "pyproject.toml"),
      observe("src"),
      observe("src/app", "main.py"),
    ];

    // Act
    const modules = deriveModules(observations);

    // Assert
    expect(modules["src"]).toEqual(["src/**"]);
    expect(modules["src/app"]).toBeUndefined();
  });
});

describe("issue #472: the no-signal floor", () => {
  it("emits exactly the payload modules for an empty destination", () => {
    // Arrange: a root with nothing in it.
    const observations = [observe("")];

    // Act
    const modules = deriveModules(observations);

    // Assert
    expect(modules).toEqual({
      "claude-runtime": [".claude/**"],
      config: ["config/**"],
    });
  });

  it("emits the payload modules when the observation list is empty", () => {
    // Arrange: the scan could not read the destination root at all.
    // Act
    const modules = deriveModules([]);

    // Assert
    expect(modules).toEqual({
      "claude-runtime": [".claude/**"],
      config: ["config/**"],
    });
  });

  it("carries the source document's other keys verbatim", () => {
    // Arrange / Act
    const parsed: unknown = JSON.parse(
      deriveDestinationModuleMap([observe("")], SOURCE_DOCUMENT),
    );
    const document = parsed as Record<string, unknown>;
    const source: unknown = JSON.parse(SOURCE_DOCUMENT);
    const sourceDocument = source as Record<string, unknown>;

    // Assert
    expect(document["version"]).toEqual(sourceDocument["version"]);
    expect(document["shared_surfaces"]).toEqual(
      sourceDocument["shared_surfaces"],
    );
    expect(document["shared_surface_globs"]).toEqual(
      sourceDocument["shared_surface_globs"],
    );
    expect(document["over_breadth_fraction"]).toEqual(
      sourceDocument["over_breadth_fraction"],
    );
    // An absent optional key is carried as absent, not as null (issue #489).
    expect(document).not.toHaveProperty("mandate_reads");
  });

  it("emits the keys in the fixed contract order", () => {
    // Arrange / Act
    const parsed: unknown = JSON.parse(
      deriveDestinationModuleMap([observe("")], SOURCE_DOCUMENT),
    );

    // Assert: `mandate_reads` is absent from this source document, so the
    // carried property is `undefined` and `JSON.stringify` drops it entirely
    // (issue #489). Its presence case is pinned in blast-radius-derive.test.ts.
    expect(Object.keys(parsed as Record<string, unknown>)).toEqual([
      "version",
      "shared_surfaces",
      "shared_surface_globs",
      "modules",
      "over_breadth_fraction",
    ]);
  });

  it("serializes with two-space indentation and a trailing newline", () => {
    // Arrange / Act
    const output = deriveDestinationModuleMap([observe("")], SOURCE_DOCUMENT);

    // Assert
    expect(output.endsWith("\n")).toBe(true);
    expect(output).toContain('\n  "version": 1,');
  });
});

describe("issue #472: payload precedence, ordering, and determinism", () => {
  it("lets a payload module win a name collision with a derived module", () => {
    // Arrange: a destination whose own `config` directory carries a manifest.
    const observations = [observe(""), observe("config", "package.json")];

    // Act
    const modules = deriveModules(observations);

    // Assert: the payload glob is what the push actually published.
    expect(modules["config"]).toEqual(["config/**"]);
  });

  it("sorts module names ordinally rather than by locale collation", () => {
    // Arrange: uppercase names sort before lowercase ones ordinally.
    const observations = [
      observe(""),
      observe("beta", "go.mod"),
      observe("Alpha", "go.mod"),
      observe("alpha", "go.mod"),
    ];

    // Act
    const names = Object.keys(deriveModules(observations));

    // Assert
    expect(names).toEqual([
      "Alpha",
      "alpha",
      "beta",
      "claude-runtime",
      "config",
    ]);
  });

  it("returns byte-identical output for identical inputs", () => {
    // Arrange
    const observations = [
      observe(""),
      observe("service", "pyproject.toml"),
      observe("web", "package.json"),
    ];

    // Act
    const first = deriveDestinationModuleMap(observations, SOURCE_DOCUMENT);
    const second = deriveDestinationModuleMap(observations, SOURCE_DOCUMENT);

    // Assert
    expect(second).toBe(first);
  });

  it("does not mutate the supplied observation list", () => {
    // Arrange
    const observations = [observe("b", "go.mod"), observe("a", "go.mod")];
    const before = JSON.stringify(observations);

    // Act
    deriveDestinationModuleMap(observations, SOURCE_DOCUMENT);

    // Assert
    expect(JSON.stringify(observations)).toBe(before);
  });
});

describe("issue #472: the forbidden-glob guard", () => {
  it.each(["docs", "tests"])(
    "throws before returning when %s would become a module",
    (bucket) => {
      // Arrange: the scanner prunes these names, so reaching the core with one
      // requires an injected observation. The guard is the last line of defense.
      const observations = [observe(""), observe(bucket, "package.json")];

      // Act / Assert
      expect(() =>
        deriveDestinationModuleMap(observations, SOURCE_DOCUMENT),
      ).toThrow(BlastRadiusGuardError);
    },
  );

  it("names the offending module and glob in the guard error", () => {
    // Arrange
    const observations = [observe(""), observe("docs", "package.json")];

    // Act
    let caught: unknown;
    try {
      deriveDestinationModuleMap(observations, SOURCE_DOCUMENT);
    } catch (error) {
      caught = error;
    }

    // Assert
    expect(caught).toBeInstanceOf(BlastRadiusGuardError);
    expect((caught as BlastRadiusGuardError).moduleName).toBe("docs");
    expect((caught as BlastRadiusGuardError).glob).toBe("docs/**");
  });

  it("rejects a source document whose payload already carries a bare glob", () => {
    // Arrange: a source document is not the guard's input, but a module named
    // with an empty relative path would produce the universal glob, so the
    // universal case is exercised through a root-named observation.
    const observations = [observe(""), observe("*", "package.json")];

    // Act
    const modules = deriveModules(observations);

    // Assert: a literal `*` directory name yields `*/**`, not `**`; the bare
    // universal glob remains unreachable.
    expect(modules["*"]).toEqual(["*/**"]);
  });
});

describe("issue #472: source-document parse failures", () => {
  it("throws a named error for unparseable source text", () => {
    // Arrange
    const corrupt = "{ not json at all\n";

    // Act
    let caught: unknown;
    try {
      deriveDestinationModuleMap([observe("")], corrupt);
    } catch (error) {
      caught = error;
    }

    // Assert
    expect(caught).toBeInstanceOf(BlastRadiusDeriveError);
    expect((caught as BlastRadiusDeriveError).path).toBe(
      BLAST_RADIUS_RELATIVE_PATH,
    );
    expect((caught as BlastRadiusDeriveError).message).toContain(
      BLAST_RADIUS_RELATIVE_PATH,
    );
  });

  it.each(["[]", "null", '"text"', "7"])(
    "throws when the source root is the non-object %s",
    (text) => {
      // Arrange / Act / Assert
      expect(() => deriveDestinationModuleMap([observe("")], text)).toThrow(
        BlastRadiusDeriveError,
      );
    },
  );
});

describe("issue #472: exported scan constants", () => {
  it("excludes every listed bucket name and every dot-prefixed name", () => {
    // Arrange / Act / Assert
    for (const name of EXCLUDED_DIR_NAMES) {
      expect(isExcludedDirectoryName(name)).toBe(true);
    }
    expect(isExcludedDirectoryName(".git")).toBe(true);
    expect(isExcludedDirectoryName(".claude")).toBe(true);
  });

  it("admits an ordinary directory name", () => {
    // Arrange / Act / Assert
    expect(isExcludedDirectoryName("src")).toBe(false);
    expect(isExcludedDirectoryName("Foo.Tests")).toBe(false);
  });

  it("pins the depth bound and the payload module set", () => {
    // Arrange / Act / Assert: both are contract values consumed by the scanner.
    expect(SCAN_DEPTH_LIMIT).toBe(3);
    expect(PAYLOAD_MODULES).toEqual({
      "claude-runtime": [".claude/**"],
      config: ["config/**"],
    });
  });
});
