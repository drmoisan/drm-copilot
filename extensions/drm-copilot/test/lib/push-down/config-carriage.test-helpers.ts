import * as path from "node:path";

import {
  type DirectoryLister,
  pushDownCustomizations,
} from "../../../src/lib/push-down/claude-customizations";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

/**
 * Shared seeding constants and setup helpers for the config-carriage suites.
 *
 * Purpose:
 *     Hold the fixed roots, the two generic source documents, and the seeding
 *     and publishing helpers that `claude-config-carriage.test.ts` reuses across
 *     every case, so that file stays inside the 500-line limit while the
 *     assertions themselves remain in one place.
 *
 * Responsibilities:
 *     Own only inert setup: path constants, serialized source documents, the
 *     in-memory tree seeder, and the push invoker. No assertion lives here.
 *
 * Side effects:
 *     None. Every helper operates on the in-memory adapter; the one real-disk
 *     read in the suite (the three-copy pin) stays in the test file and uses
 *     {@link REPO_ROOT} only as a path root.
 */

/** Fixed clock so `startedAt` / `finishedAt` are deterministic. */
export const CLOCK = fixedClock("2026-08-10T00:15:00.000Z");

/** In-memory source workspace root. */
export const SRC = "/src";

/** In-memory destination workspace root. */
export const DEST = "/dest";

/** Bundled customization root beneath the source workspace. */
export const BUNDLE = `${SRC}/extensions/drm-copilot/resources/claude-customizations`;

/** Pack-manifest directory beneath the bundle root. */
export const MANIFEST_DIR = `${BUNDLE}/pack-manifests`;

/** Repository root resolved from this file's location. */
export const REPO_ROOT = path.join(__dirname, "..", "..", "..", "..", "..");

/** The generic routing document a destination workspace receives. */
export const SOURCE_ROUTING = `${JSON.stringify(
  {
    version: 3,
    routes: {
      small: { route_id: "small" },
      parallel: { route_id: "parallel", requires_pr_gate: false },
      preparation: { route_id: "preparation" },
    },
    model_policy: { default: "opus" },
  },
  null,
  2,
)}\n`;

/**
 * The bundled blast-radius document the payload ships.
 *
 * This is the derivation's base document, not the bytes a destination receives:
 * {@link BlastRadiusDeriveFileSystem} replaces the module map with one computed
 * from the destination's own layout. The constant mirrors the shape of the
 * corrected bundled copy at
 * `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`,
 * which declares only the two payload modules. The `docs` and `tests` location
 * buckets it previously carried were removed in issue #472 because a bucket
 * keyed on where a file lives attaches to nearly every work item and makes
 * every pair of items contend at the module level.
 */
export const SOURCE_BLAST_RADIUS = `${JSON.stringify(
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
 * Serialize a pack manifest for seeding.
 *
 * @param fields Manifest fields to serialize.
 * @returns Serialized manifest JSON.
 */
export function manifestJson(fields: Record<string, unknown>): string {
  return JSON.stringify(fields);
}

/**
 * Seed a `.claude` tree plus the bundled `config/` tree and pack manifests.
 *
 * @param extraFiles Additional files to seed (for example a destination-side
 *   routing document already present in the workspace).
 * @returns A seeded in-memory filesystem with `/dest` ensured.
 */
export function seedTree(
  extraFiles: Record<string, string> = {},
): ReturnType<typeof buildInMemoryFileSystem> {
  return buildInMemoryFileSystem(
    {
      [`${SRC}/.claude/settings.json`]: '{"core": true}\n',
      [`${SRC}/.claude/agents/orchestrator.md`]: "# Orchestrator\n",
      [`${SRC}/.claude/rules/parallel-orchestration.md`]: "# Parallel rules\n",
      [`${SRC}/.claude/lib/bash/compute-cohorts.sh`]: "#!/usr/bin/env bash\n",
      [`${SRC}/.claude/lib/bash/compute-concurrency-batches.sh`]:
        "#!/usr/bin/env bash\n",
      [`${SRC}/.claude/lib/bash/validate-parallel-manifest.sh`]:
        "#!/usr/bin/env bash\n",
      [`${SRC}/config/orchestration-routing.json`]: SOURCE_ROUTING,
      [`${SRC}/config/blast-radius.json`]: SOURCE_BLAST_RADIUS,
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        label: "Core",
        paths: [
          ".claude/settings.json",
          ".claude/agents/orchestrator.md",
          ".claude/rules/parallel-orchestration.md",
          ".claude/lib/bash/compute-cohorts.sh",
          ".claude/lib/bash/compute-concurrency-batches.sh",
          ".claude/lib/bash/validate-parallel-manifest.sh",
          "config/orchestration-routing.json",
          "config/blast-radius.json",
        ],
      }),
      ...extraFiles,
    },
    [DEST],
  );
}

/**
 * Run the Claude push-down against a seeded filesystem.
 *
 * @param seeded The seeded in-memory filesystem.
 * @param packs Optional pack selection.
 * @param listEntries Optional destination-layout lister. The in-memory
 *   destination is invisible to the real-filesystem default lister, so a case
 *   that needs the derivation to observe a layout must inject one here.
 * @returns The completed run summary.
 */
export function publish(
  seeded: ReturnType<typeof buildInMemoryFileSystem>,
  packs: ReadonlySet<string> | null = null,
  listEntries?: DirectoryLister,
): ReturnType<typeof pushDownCustomizations> {
  return pushDownCustomizations({
    repoRoot: SRC,
    destinationRoot: DEST,
    fs: seeded,
    bundleRoot: BUNDLE,
    packs,
    clock: CLOCK,
    ...(listEntries === undefined ? {} : { listEntries }),
  });
}

/**
 * Build a lister describing a destination layout by absolute directory path.
 *
 * @param layout Map of absolute directory path to its shallow entries.
 * @returns A lister returning the mapped entries, or none for an unmapped path.
 */
export function layoutLister(
  layout: Readonly<
    Record<string, ReadonlyArray<{ name: string; isDir: boolean }>>
  >,
): DirectoryLister {
  return (root) => layout[root] ?? [];
}

/**
 * A destination layout carrying one C# project under `src/App`.
 *
 * Used by the genericity and overwrite cases so the derived document differs
 * observably from both the seeded source constant and any pre-existing
 * destination bytes.
 */
export const SRC_APP_LAYOUT: Readonly<
  Record<string, ReadonlyArray<{ name: string; isDir: boolean }>>
> = {
  [DEST]: [{ name: "src", isDir: true }],
  [`${DEST}/src`]: [{ name: "App", isDir: true }],
  [`${DEST}/src/App`]: [{ name: "App.csproj", isDir: false }],
};
