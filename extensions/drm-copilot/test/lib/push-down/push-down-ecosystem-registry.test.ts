/**
 * Unit tests for the push-down ecosystem registry (issue #1029).
 */

import {
  assertDestinationManifestOutsideLayers,
  ECOSYSTEM_BUNDLE_DIRECTORIES,
  ECOSYSTEM_LAYER_BUILDERS,
  LAYER_ROOT_FOLDERS,
} from "../../../src/lib/push-down/push-down-ecosystem-registry";
import {
  ECOSYSTEM_NAMES,
  LAYER_ROOT_FILES,
  type LayerName,
} from "../../../src/lib/push-down/push-down-layer";
import {
  seedThreeBundles,
  SEED_EXTENSION_ROOT,
} from "./push-down-pipeline.test-helpers";

describe("push-down ecosystem registry", () => {
  it.each(ECOSYSTEM_NAMES)(
    "builds each layer with its declared roots (%s)",
    (ecosystem) => {
      const fs = seedThreeBundles();

      const layer = ECOSYSTEM_LAYER_BUILDERS[ecosystem]({
        bundleRoot: `${SEED_EXTENSION_ROOT}/resources/${ECOSYSTEM_BUNDLE_DIRECTORIES[ecosystem]}`,
        destinationRoot: "/dest",
        fs,
        packs: ["python"],
        csharpVariant: "modern",
        memoryMode: "overwrite",
        listEntries: () => [],
      });

      expect(layer.name).toBe(ecosystem);
      expect(layer.rootFolders).toEqual(LAYER_ROOT_FOLDERS[ecosystem]);
      expect(layer.rootFiles).toEqual(LAYER_ROOT_FILES[ecosystem]);
      expect(layer.selection?.packs).toEqual(["core", "python"]);
    },
  );

  it("accepts the destination manifest path as root-level", () => {
    const declarations = (Object.keys(LAYER_ROOT_FOLDERS) as LayerName[]).map(
      (name) => ({
        name,
        rootFolders: LAYER_ROOT_FOLDERS[name],
        rootFiles: LAYER_ROOT_FILES[name],
      }),
    );

    expect(() =>
      assertDestinationManifestOutsideLayers(declarations),
    ).not.toThrow();
  });

  it.each([
    [
      "a root folder",
      { name: "x", rootFolders: [".push-down"], rootFiles: [] },
    ],
    [
      "a root-file destination",
      {
        name: "x",
        rootFolders: [".x"],
        rootFiles: [[".push-down-manifest.json", "x.json"] as const],
      },
    ],
  ])(
    "rejects a layer root or root-file destination that captures the destination manifest path (%s)",
    (_label, declaration) => {
      expect(() =>
        assertDestinationManifestOutsideLayers([declaration]),
      ).toThrow(/\.push-down-manifest\.json|published root/);
    },
  );
});
