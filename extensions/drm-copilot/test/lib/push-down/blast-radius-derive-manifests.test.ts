import { describe, expect, it } from "@jest/globals";

import {
  classifyProjectDirectories,
  isManifestFileName,
  isModuleManifestFileName,
  MANIFEST_SUFFIXES,
  MODULE_MANIFEST_SUFFIXES,
  NON_MODULE_MANIFEST_SUFFIXES,
} from "../../../src/lib/push-down/claude-blast-radius-derive-manifests";
import {
  classifyProjectDirectories as coreClassifyProjectDirectories,
  deriveDestinationModuleMap,
  type DirectoryObservation,
  isManifestFileName as coreIsManifestFileName,
} from "../../../src/lib/push-down/claude-blast-radius-derive-core";

/**
 * Manifest-family split and project-directory classification (issue #643).
 *
 * Purpose:
 *     Cover the two manifest families, the module and non-module predicates, and
 *     the classification step that reports module paths separately from the
 *     structure signal that suppresses the top-level-directory fallback.
 *
 * Scope note:
 *     Every case is hermetic. Observation lists are constructed in memory and no
 *     filesystem, subprocess, network, or clock access occurs.
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

/**
 * Build the observation list for a .NET solution of N sibling projects.
 *
 * @param count Number of sibling project directories to construct.
 * @returns The root observation followed by one observation per project.
 */
function dotNetSolution(count: number): DirectoryObservation[] {
  const observations = [observe("")];
  for (let index = 1; index <= count; index += 1) {
    observations.push(observe(`Proj${index}`, `Proj${index}.csproj`));
  }
  return observations;
}

describe("issue #643: manifest suffix families", () => {
  it("splits the manifest suffixes into an empty module family and the five-member non-module family", () => {
    // Arrange / Act / Assert: the concatenation is what preserves the previous
    // isManifestFileName behaviour across the split.
    expect(MODULE_MANIFEST_SUFFIXES).toEqual([]);
    expect(NON_MODULE_MANIFEST_SUFFIXES).toEqual([
      ".csproj",
      ".fsproj",
      ".vbproj",
      ".sln",
      ".slnx",
    ]);
    expect(MANIFEST_SUFFIXES).toEqual([
      ...MODULE_MANIFEST_SUFFIXES,
      ...NON_MODULE_MANIFEST_SUFFIXES,
    ]);
  });

  it.each([...NON_MODULE_MANIFEST_SUFFIXES])(
    "classifies every non-module suffix as a manifest but not as a module manifest for %s",
    (suffix) => {
      // Arrange / Act / Assert: a .NET project file marks structure without
      // making its directory a module.
      expect(isManifestFileName(`Widget${suffix}`)).toBe(true);
      expect(isModuleManifestFileName(`Widget${suffix}`)).toBe(false);
    },
  );
});

describe("issue #643: multi-project .NET classification", () => {
  it("returns no module path and a structure signal for a nine-project .NET layout", () => {
    // Arrange: nine sibling project directories plus the root.
    const observations = dotNetSolution(9);

    // Act
    const classification = classifyProjectDirectories(observations);

    // Assert: nine per-assembly modules would have put every pair of items in
    // the solution into contention.
    expect(classification.modulePaths).toEqual([]);
    expect(classification.structureObserved).toBe(true);
  });

  it("derives exactly the config payload module for a nine-project .NET layout", () => {
    // Arrange / Act: the structure signal suppresses the top-level fallback, so
    // only the payload floor remains.
    const modules = deriveModules(dotNetSolution(9));

    // Assert
    expect(modules).toEqual({ config: ["config/**"] });
  });

  it("yields no module for a nested solution file", () => {
    // Arrange: a solution beside a project directory beneath it. Ancestor
    // pruning no longer removes the solution directory, so `.sln` must be
    // classified as non-module for the result to stay at the floor.
    const observations = [
      observe(""),
      observe("src", "All.sln"),
      observe("src/App", "App.csproj"),
    ];

    // Act / Assert
    expect(deriveModules(observations)).toEqual({ config: ["config/**"] });
  });

  it("keeps the non-.NET module beside config in a mixed layout", () => {
    // Arrange: one Node module and two .NET project directories.
    const observations = [
      observe(""),
      observe("tools", "package.json"),
      observe("Proj1", "Proj1.csproj"),
      observe("Proj2", "Proj2.csproj"),
    ];

    // Act
    const modules = deriveModules(observations);

    // Assert: the .NET directories contribute nothing, the Node module survives.
    expect(Object.keys(modules).sort()).toEqual(["config", "tools"]);
  });
});

describe("issue #643: re-export surface", () => {
  it("re-exports the manifest surface from the derivation core", () => {
    // Arrange / Act / Assert: identity, not merely equal behaviour, so an
    // accidental second declaration in the core would fail here.
    expect(coreIsManifestFileName).toBe(isManifestFileName);
    expect(coreClassifyProjectDirectories).toBe(classifyProjectDirectories);
  });
});
