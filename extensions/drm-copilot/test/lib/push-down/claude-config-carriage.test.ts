import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  pushDownCustomizations,
  ROOT_FOLDERS,
  ROUTING_MERGE_RELATIVE_PATH,
  RoutingMergeError,
} from "../../../src/lib/push-down/claude-customizations";
import {
  pushDownCustomizations as pushDownCodexCustomizations,
  ROOT_FOLDERS as CODEX_ROOT_FOLDERS,
} from "../../../src/lib/push-down/codex-agents-customizations";
import { pushDownCustomizations as pushDownCopilotCustomizations } from "../../../src/lib/push-down/copilot-customizations";
import { COPILOT_ROOT_FOLDERS } from "../../../src/lib/push-down/copilot-customizations-engine";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

/**
 * Config carriage for the Claude push-down (issue #462).
 *
 * Purpose:
 *     Cover the destination-portability blocker that a workspace receiving the
 *     Claude customization payload previously got only `.claude` and therefore
 *     could not resolve `config/orchestration-routing.json` or
 *     `config/blast-radius.json`. These suites assert that both files are
 *     published on a plain publish and under a pack-scoped publish, that the
 *     routing write merges rather than overwrites, that the published
 *     blast-radius document is the generic default with no drm-copilot-only
 *     entries, and that the Copilot and Codex published sets are unchanged by
 *     the `ROOT_FOLDERS` extension.
 *
 * Scope note:
 *     The three-copy pin (repo-root, extension-runtime mirror, push-down
 *     source) is asserted here against the real files on disk; every other case
 *     uses the hermetic in-memory adapter.
 */

const CLOCK = fixedClock("2026-08-10T00:15:00.000Z");
const SRC = "/src";
const DEST = "/dest";
const BUNDLE = `${SRC}/extensions/drm-copilot/resources/claude-customizations`;
const MANIFEST_DIR = `${BUNDLE}/pack-manifests`;

/** Repository root resolved from this test file's location. */
const REPO_ROOT = path.join(__dirname, "..", "..", "..", "..", "..");

/** The generic routing document a destination workspace receives. */
const SOURCE_ROUTING = `${JSON.stringify(
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

/** The generic blast-radius document a destination workspace receives. */
const SOURCE_BLAST_RADIUS = `${JSON.stringify(
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
      docs: ["docs/**"],
      tests: ["tests/**"],
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
function manifestJson(fields: Record<string, unknown>): string {
  return JSON.stringify(fields);
}

/**
 * Seed a `.claude` tree plus the bundled `config/` tree and pack manifests.
 *
 * @param extraFiles Additional files to seed (for example a destination-side
 *   routing document already present in the workspace).
 * @returns A seeded in-memory filesystem with `/dest` ensured.
 */
function seedTree(
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
 * @returns The completed run summary.
 */
function publish(
  seeded: ReturnType<typeof buildInMemoryFileSystem>,
  packs: ReadonlySet<string> | null = null,
): ReturnType<typeof pushDownCustomizations> {
  return pushDownCustomizations({
    repoRoot: SRC,
    destinationRoot: DEST,
    fs: seeded,
    bundleRoot: BUNDLE,
    packs,
    clock: CLOCK,
  });
}

describe("issue #462 AC6: the Claude push-down publishes the config tree", () => {
  it("publishes both config files on a plain publish", () => {
    // Arrange
    const seeded = seedTree();

    // Act
    publish(seeded);

    // Assert
    expect(seeded.isFile(`${DEST}/config/orchestration-routing.json`)).toBe(
      true,
    );
    expect(seeded.isFile(`${DEST}/config/blast-radius.json`)).toBe(true);
  });

  it("publishes both config files under a pack-scoped publish", () => {
    // Arrange: the R11 proof -- a manifest-scoped run must not drop config/.
    const seeded = seedTree();

    // Act
    publish(seeded, new Set(["core"]));

    // Assert
    expect(seeded.isFile(`${DEST}/config/orchestration-routing.json`)).toBe(
      true,
    );
    expect(seeded.isFile(`${DEST}/config/blast-radius.json`)).toBe(true);
  });

  it("appends config after .claude in the enumeration-order contract", () => {
    // Arrange / Act / Assert
    expect(ROOT_FOLDERS).toEqual([".claude", "config"]);
  });

  it("pins the bundled routing source byte-identical to the repo-root file", () => {
    // Arrange: the three-copy rule requires one canonical content across the
    // repo root, the extension-runtime mirror, and the push-down source.
    const rootPath = path.join(
      REPO_ROOT,
      "config",
      "orchestration-routing.json",
    );
    const bundledPath = path.join(
      REPO_ROOT,
      "extensions",
      "drm-copilot",
      "resources",
      "claude-customizations",
      "config",
      "orchestration-routing.json",
    );

    // Act
    const rootBytes = fs.readFileSync(rootPath);
    const bundledBytes = fs.readFileSync(bundledPath);

    // Assert
    expect(bundledBytes.equals(rootBytes)).toBe(true);
  });
});

describe("issue #462 AC7: the routing write merges rather than overwrites", () => {
  it("copies the source text unchanged when the destination file is absent", () => {
    // Arrange
    const seeded = seedTree();

    // Act
    publish(seeded);

    // Assert
    expect(
      seeded.readTextFile(`${DEST}/config/orchestration-routing.json`),
    ).toBe(SOURCE_ROUTING);
  });

  it("adds the parallel and preparation routes to a pre-existing destination", () => {
    // Arrange: a workspace whose routing document predates both routes.
    const seeded = seedTree({
      [`${DEST}/config/orchestration-routing.json`]: `${JSON.stringify(
        { version: 1, routes: { small: { route_id: "small" } } },
        null,
        2,
      )}\n`,
    });

    // Act
    publish(seeded);

    // Assert
    const merged: unknown = JSON.parse(
      seeded.readTextFile(`${DEST}/config/orchestration-routing.json`),
    );
    const routes = (merged as Record<string, Record<string, unknown>>)[
      "routes"
    ];
    expect(Object.keys(routes)).toEqual(["small", "parallel", "preparation"]);
  });

  it("overwrites a stale destination parallel route with the source definition", () => {
    // Arrange
    const seeded = seedTree({
      [`${DEST}/config/orchestration-routing.json`]: `${JSON.stringify(
        {
          version: 1,
          routes: {
            parallel: { route_id: "parallel", requires_pr_gate: true },
          },
        },
        null,
        2,
      )}\n`,
    });

    // Act
    publish(seeded);

    // Assert
    const merged: unknown = JSON.parse(
      seeded.readTextFile(`${DEST}/config/orchestration-routing.json`),
    );
    const routes = (merged as Record<string, Record<string, unknown>>)[
      "routes"
    ];
    expect(routes["parallel"]).toEqual({
      route_id: "parallel",
      requires_pr_gate: false,
    });
  });

  it("preserves destination-local routes and top-level blocks verbatim", () => {
    // Arrange
    const seeded = seedTree({
      [`${DEST}/config/orchestration-routing.json`]: `${JSON.stringify(
        {
          version: 1,
          routes: {
            house_style: { route_id: "house_style", local: true },
          },
          local_policy: { retain: "yes" },
        },
        null,
        2,
      )}\n`,
    });

    // Act
    publish(seeded);

    // Assert
    const merged: unknown = JSON.parse(
      seeded.readTextFile(`${DEST}/config/orchestration-routing.json`),
    );
    const document = merged as Record<string, unknown>;
    const routes = document["routes"] as Record<string, unknown>;
    expect(routes["house_style"]).toEqual({
      route_id: "house_style",
      local: true,
    });
    expect(document["local_policy"]).toEqual({ retain: "yes" });
    // The destination's own version is preserved; the source does not clobber it.
    expect(document["version"]).toBe(1);
    // The source's top-level block the destination lacked is appended.
    expect(document["model_policy"]).toEqual({ default: "opus" });
  });

  it("is byte-stable across a second push", () => {
    // Arrange
    const seeded = seedTree({
      [`${DEST}/config/orchestration-routing.json`]: `${JSON.stringify(
        { version: 1, routes: { small: { route_id: "small" } } },
        null,
        2,
      )}\n`,
    });

    // Act
    publish(seeded);
    const afterFirst = seeded.readTextFile(
      `${DEST}/config/orchestration-routing.json`,
    );
    publish(seeded);
    const afterSecond = seeded.readTextFile(
      `${DEST}/config/orchestration-routing.json`,
    );

    // Assert
    expect(afterSecond).toBe(afterFirst);
  });

  it("fails an unparseable destination file and leaves its bytes unchanged", () => {
    // Arrange
    const corrupt = "{ not json at all\n";
    const seeded = seedTree({
      [`${DEST}/config/orchestration-routing.json`]: corrupt,
    });

    // Act / Assert: the error names the offending file so the caller can report
    // it, and the destination content is untouched.
    let caught: unknown;
    try {
      publish(seeded);
    } catch (error) {
      caught = error;
    }
    expect(caught).toBeInstanceOf(RoutingMergeError);
    expect((caught as RoutingMergeError).path).toBe(
      `${DEST}/${ROUTING_MERGE_RELATIVE_PATH}`,
    );
    expect((caught as RoutingMergeError).message).toContain(
      `${DEST}/config/orchestration-routing.json`,
    );
    expect(
      seeded.readTextFile(`${DEST}/config/orchestration-routing.json`),
    ).toBe(corrupt);
  });
});

describe("issue #462 AC8: the published blast-radius default is generic", () => {
  it("publishes the pinned generic document with no drm-copilot-only entries", () => {
    // Arrange
    const seeded = seedTree();

    // Act
    publish(seeded);
    const published = seeded.readTextFile(`${DEST}/config/blast-radius.json`);

    // Assert
    expect(published).toBe(SOURCE_BLAST_RADIUS);
    for (const forbidden of [
      "scripts/dev_tools",
      "packages/mcp-server",
      "poetry.lock",
      "package-lock.json",
    ]) {
      expect(published).not.toContain(forbidden);
    }
  });

  it("overwrites the destination blast-radius rather than merging it", () => {
    // Arrange: only the routing path is merged; blast-radius is a plain write.
    const seeded = seedTree({
      [`${DEST}/config/blast-radius.json`]: '{"version": 99}\n',
    });

    // Act
    publish(seeded);

    // Assert
    expect(seeded.readTextFile(`${DEST}/config/blast-radius.json`)).toBe(
      SOURCE_BLAST_RADIUS,
    );
  });
});

describe("issue #462 AC9: the Copilot and Codex published sets are unchanged", () => {
  it("publishes no config file from the Copilot entry point", () => {
    // Arrange
    const seeded = buildInMemoryFileSystem(
      {
        [`${SRC}/.github/copilot-instructions.md`]: "# Copilot\n",
        [`${SRC}/config/orchestration-routing.json`]: SOURCE_ROUTING,
        [`${SRC}/config/blast-radius.json`]: SOURCE_BLAST_RADIUS,
      },
      [DEST],
    );

    // Act
    pushDownCopilotCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs: seeded,
      clock: CLOCK,
    });

    // Assert
    expect(COPILOT_ROOT_FOLDERS).not.toContain("config");
    expect(seeded.isFile(`${DEST}/config/orchestration-routing.json`)).toBe(
      false,
    );
    expect(seeded.isFile(`${DEST}/config/blast-radius.json`)).toBe(false);
  });

  it("publishes no config file from the Codex entry point", () => {
    // Arrange
    const seeded = buildInMemoryFileSystem(
      {
        [`${SRC}/.codex/AGENTS.md`]: "# Codex\n",
        [`${SRC}/.agents/agent.md`]: "# Agent\n",
        [`${SRC}/config/orchestration-routing.json`]: SOURCE_ROUTING,
        [`${SRC}/config/blast-radius.json`]: SOURCE_BLAST_RADIUS,
      },
      [DEST],
    );

    // Act
    pushDownCodexCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs: seeded,
      clock: CLOCK,
    });

    // Assert
    expect(CODEX_ROOT_FOLDERS).toEqual([".codex", ".agents"]);
    expect(seeded.isFile(`${DEST}/config/orchestration-routing.json`)).toBe(
      false,
    );
    expect(seeded.isFile(`${DEST}/config/blast-radius.json`)).toBe(false);
  });
});

describe("issue #462 AC16: a payload-only publish clears all four blockers", () => {
  it("publishes the rule, every bash entry point, and both config files", () => {
    // Arrange
    const seeded = seedTree();

    // Act
    publish(seeded);

    // Assert
    for (const relative of [
      ".claude/rules/parallel-orchestration.md",
      ".claude/lib/bash/compute-cohorts.sh",
      ".claude/lib/bash/compute-concurrency-batches.sh",
      ".claude/lib/bash/validate-parallel-manifest.sh",
      "config/orchestration-routing.json",
      "config/blast-radius.json",
    ]) {
      expect(seeded.isFile(`${DEST}/${relative}`)).toBe(true);
    }
  });
});
