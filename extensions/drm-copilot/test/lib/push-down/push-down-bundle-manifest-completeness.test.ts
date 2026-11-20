/**
 * Full-bundle pack-manifest completeness (issue #1029, O-12).
 *
 * Reads the tracked bundles under `extensions/drm-copilot/resources` read-only
 * and asserts that every file a layer can publish is listed by a manifest of
 * its bundle, or, for a path of the shared set S (D15), by `shared.json`.
 * Unlisted files are allowed only for the paths named in `ALLOWED_UNLISTED`,
 * each with its reason.
 */

import * as nodePath from "node:path";

import { RealPushDownFileSystem } from "../../../src/lib/push-down/filesystem-adapter";
import {
  EXCLUDED_RELATIVE_PATHS,
  ROOT_FOLDERS as CLAUDE_ROOT_FOLDERS,
} from "../../../src/lib/push-down/claude-customizations";
import { LOCAL_RUNTIME_RELATIVE_DIRECTORIES } from "../../../src/lib/push-down/claude-filesystem-adapter";
import {
  ROOT_FOLDERS as CODEX_ROOT_FOLDERS,
  VIRTUAL_RESOURCE_DIRECTORIES,
  VIRTUAL_RESOURCE_PAIRS,
} from "../../../src/lib/push-down/codex-agents-customizations";
import { COPILOT_ROOT_FOLDERS } from "../../../src/lib/push-down/copilot-customizations-engine";
import { LAYER_ROOT_FILES } from "../../../src/lib/push-down/push-down-layer";
import { SHARED_LAYER_ECOSYSTEM_EXCEPTIONS } from "../../../src/lib/push-down/push-down-shared-layer";

const REPO_ROOT = nodePath
  .resolve(__dirname, "../../../../..")
  .replace(/\\/g, "/");
const RESOURCES = `${REPO_ROOT}/extensions/drm-copilot/resources`;
const CLAUDE_BUNDLE = `${RESOURCES}/claude-customizations`;
const CODEX_BUNDLE = `${RESOURCES}/codex-and-agents-customizations`;
const COPILOT_BUNDLE = `${RESOURCES}/customizations`;
const real = new RealPushDownFileSystem();

/**
 * Bundle files that are allowed to be unlisted, each with its reason:
 * the Claude host-specific exclusions and the local runtime directories.
 */
const ALLOWED_UNLISTED: ReadonlyArray<{
  readonly matches: (path: string) => boolean;
  readonly reason: string;
}> = [
  {
    matches: (path) => EXCLUDED_RELATIVE_PATHS.includes(path),
    reason:
      "EXCLUDED_RELATIVE_PATHS: host-specific files the Claude push-down never publishes",
  },
  {
    matches: (path) =>
      LOCAL_RUNTIME_RELATIVE_DIRECTORIES.some(
        (directory) => path === directory || path.startsWith(`${directory}/`),
      ),
    reason:
      "LOCAL_RUNTIME_RELATIVE_DIRECTORIES: machine-local runtime state is never published",
  },
];

/** Paths listed by every manifest JSON in a directory, keyed by file stem. */
function manifestPaths(directory: string): Map<string, ReadonlySet<string>> {
  const manifests = new Map<string, ReadonlySet<string>>();
  for (const file of real.listFiles(directory)) {
    if (!file.endsWith(".json")) {
      continue;
    }
    const parsed = JSON.parse(real.readTextFile(file)) as { paths: string[] };
    manifests.set(
      nodePath.posix.basename(file, ".json"),
      new Set(parsed.paths),
    );
  }
  return manifests;
}

/** Union of the path sets of the named manifests (or all of them). */
function union(
  manifests: Map<string, ReadonlySet<string>>,
  exclude: ReadonlyArray<string> = [],
): ReadonlySet<string> {
  const paths = new Set<string>();
  for (const [name, set] of manifests) {
    if (!exclude.includes(name)) {
      for (const path of set) {
        paths.add(path);
      }
    }
  }
  return paths;
}

/** Bundle-relative files under the given root folders of a bundle. */
function bundleFiles(bundle: string, roots: ReadonlyArray<string>): string[] {
  return roots.flatMap((root) =>
    real
      .listFiles(`${bundle}/${root}`)
      .map((path) => path.slice(bundle.length + 1)),
  );
}

/** The shared set S of D15, derived from the parity matrix. */
function sharedSet(): ReadonlySet<string> {
  const matrix = JSON.parse(
    real.readTextFile(`${REPO_ROOT}/config/harness-parity-matrix.json`),
  ) as { features: Array<Record<string, unknown>> };
  const exceptions = new Set(
    SHARED_LAYER_ECOSYSTEM_EXCEPTIONS.map((entry) => entry.path),
  );
  const skills = matrix.features
    .filter(
      (entry) =>
        entry["kind"] === "skill" &&
        entry["ecosystem"] === "codex" &&
        entry["disposition"] === "shared",
    )
    .map((entry) => `.agents/skills/${String(entry["name"])}`);
  return new Set([
    ...bundleFiles(CODEX_BUNDLE, skills).filter(
      (path) => !exceptions.has(path),
    ),
    "AGENTS.md",
    "config/orchestration-routing.json",
    "config/orchestration-handoff-registry.json",
    "config/orchestration-handoff.schema.json",
  ]);
}

/** Codex-layer destination paths of the virtual resource pairs and folders. */
function codexVirtualPaths(): string[] {
  const pairs = VIRTUAL_RESOURCE_PAIRS.filter(([, resource]) =>
    real.isFile(`${RESOURCES}/${resource}`),
  ).map(([destination]) => destination);
  const directories = VIRTUAL_RESOURCE_DIRECTORIES.flatMap(
    ([destination, resource]) =>
      real
        .listFiles(`${RESOURCES}/${resource}`)
        .map(
          (path) =>
            `${destination}/${path.slice(`${RESOURCES}/${resource}/`.length)}`,
        ),
  );
  return [...pairs, ...directories];
}

/** Root-file destinations whose source exists in the bundle. */
function rootFileDestinations(
  pairs: ReadonlyArray<readonly [string, string]>,
): string[] {
  return pairs
    .filter(([, source]) => real.isFile(`${RESOURCES}/${source}`))
    .map(([destination]) => destination);
}

/** Paths that no manifest lists and no allowed exception covers. */
function unlisted(
  candidates: ReadonlyArray<string>,
  listed: ReadonlySet<string>,
  shared: ReadonlySet<string>,
  sharedListed: ReadonlySet<string>,
): string[] {
  return candidates
    .filter(
      (path) =>
        !listed.has(path) &&
        !(shared.has(path) && sharedListed.has(path)) &&
        !ALLOWED_UNLISTED.some((allowed) => allowed.matches(path)),
    )
    .sort();
}

describe("push-down bundle manifest completeness", () => {
  const shared = sharedSet();
  const codexManifests = manifestPaths(`${CODEX_BUNDLE}/pack-manifests`);
  const sharedListed = codexManifests.get("shared") ?? new Set<string>();

  it("enumerates a non-empty bundle tree", () => {
    expect(
      bundleFiles(CLAUDE_BUNDLE, CLAUDE_ROOT_FOLDERS).length,
    ).toBeGreaterThan(100);
    expect(
      bundleFiles(CODEX_BUNDLE, CODEX_ROOT_FOLDERS).length,
    ).toBeGreaterThan(100);
    expect(
      bundleFiles(COPILOT_BUNDLE, COPILOT_ROOT_FOLDERS).length,
    ).toBeGreaterThan(50);
    expect(shared.size).toBeGreaterThan(100);
    expect(
      ALLOWED_UNLISTED.every((allowed) => allowed.reason.trim() !== ""),
    ).toBe(true);
  });

  it("lists every Claude bundle file", () => {
    const candidates = [
      ...bundleFiles(CLAUDE_BUNDLE, CLAUDE_ROOT_FOLDERS),
      ...rootFileDestinations(LAYER_ROOT_FILES.claude),
    ];
    const listed = union(manifestPaths(`${CLAUDE_BUNDLE}/pack-manifests`));

    expect(unlisted(candidates, listed, shared, sharedListed)).toEqual([]);
  });

  it("lists every Codex bundle file", () => {
    const candidates = [
      ...bundleFiles(CODEX_BUNDLE, CODEX_ROOT_FOLDERS),
      ...codexVirtualPaths(),
      ...rootFileDestinations(LAYER_ROOT_FILES.shared),
    ];
    const listed = union(codexManifests, ["shared"]);

    expect(unlisted(candidates, listed, shared, sharedListed)).toEqual([]);
  });

  it("lists every Copilot bundle file", () => {
    const candidates = [
      ...bundleFiles(COPILOT_BUNDLE, COPILOT_ROOT_FOLDERS),
      ...rootFileDestinations(LAYER_ROOT_FILES.copilot),
    ];
    const listed = union(manifestPaths(`${COPILOT_BUNDLE}/pack-manifests`));

    expect(unlisted(candidates, listed, shared, sharedListed)).toEqual([]);
  });

  it("lists no path outside the shared set in shared.json", () => {
    expect([...sharedListed].filter((path) => !shared.has(path))).toEqual([]);
  });

  it("keeps every ecosystem-layer exception in a Codex manifest and out of shared.json", () => {
    const codexListed = union(codexManifests, ["shared"]);

    for (const exception of SHARED_LAYER_ECOSYSTEM_EXCEPTIONS) {
      expect(codexListed.has(exception.path)).toBe(true);
      expect(sharedListed.has(exception.path)).toBe(false);
    }
  });
});
