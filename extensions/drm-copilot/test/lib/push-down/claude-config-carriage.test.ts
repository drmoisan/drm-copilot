import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
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
import { buildInMemoryFileSystem } from "./push-down.test-helpers";
import {
  CLOCK,
  DEST,
  layoutLister,
  publish,
  REPO_ROOT,
  seedTree,
  SOURCE_BLAST_RADIUS,
  SOURCE_ROUTING,
  SRC,
  SRC_APP_LAYOUT,
} from "./config-carriage.test-helpers";

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

  it("keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource", () => {
    // Arrange: SOURCE_BLAST_RADIUS is an in-memory fixture claimed to mirror
    // the committed bundled blast-radius.json key for key (issue #500, cycle
    // 3 CR-4). Nothing previously enforced that claim, so the fixture could
    // drift from the real on-disk resource without any test noticing.
    const bundledPath = path.join(
      REPO_ROOT,
      "extensions",
      "drm-copilot",
      "resources",
      "claude-customizations",
      "config",
      "blast-radius.json",
    );

    // Act: read the real committed file and parse both it and the fixture,
    // so the comparison is structural rather than byte-for-byte (both are
    // JSON text with independent formatting and key order).
    const bundledText = fs.readFileSync(bundledPath, "utf8");
    const committed = JSON.parse(bundledText);
    const fixture = JSON.parse(SOURCE_BLAST_RADIUS);

    // Assert
    expect(fixture).toEqual(committed);
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
  it("publishes a document derived from the destination's own layout", () => {
    // Arrange: a destination carrying one C# project. The layout is visible only
    // through the injected lister, because the real-filesystem default lister
    // cannot see the in-memory destination tree.
    const seeded = seedTree();

    // Act
    publish(seeded, null, layoutLister(SRC_APP_LAYOUT));
    const published = seeded.readTextFile(`${DEST}/config/blast-radius.json`);

    // Assert: genericity is asserted as a property rather than as equality with
    // a seeded constant (issue #472). The published map must name the
    // destination's own module and must carry no location bucket or universal
    // glob.
    //
    // The retained criterion is what must never reach a destination: an entry
    // naming THIS repository's directory layout. `scripts/dev_tools` and
    // `packages/mcp-server` are directories only drm-copilot has, so a
    // destination that received one would carry a module or surface pointing at
    // nothing.
    //
    // An ecosystem-standard root filename is a different case, and
    // `poetry.lock` and `package-lock.json` were removed from this list for
    // that reason (issue #500, DD-1). Any Python or Node destination may
    // legitimately carry them, and under the governing surfaces-versus-modules
    // asymmetry the cost of a surface entry a destination lacks is zero: an
    // over-matching module glob costs concurrency on every pair it touches,
    // whereas an unmatched surface entry is inert. Their presence is therefore
    // not evidence of a leaked repository layout.
    expect(published).toContain('"src/App"');
    expect(published).toContain('"src/App/**"');
    for (const forbidden of [
      '"**"',
      '"docs/**"',
      '"tests/**"',
      "scripts/dev_tools",
      "packages/mcp-server",
    ]) {
      expect(published).not.toContain(forbidden);
    }
  });

  it("publishes no claude-runtime module into a layout-free destination", () => {
    // Arrange: a destination whose layout reports no entry at any path, so the
    // scan contributes nothing and the assembled map is exactly the payload
    // module set. That isolates the assertion to `PAYLOAD_MODULES`.
    const seeded = seedTree();

    // Act
    publish(seeded, null, layoutLister({}));
    const published = JSON.parse(
      seeded.readTextFile(`${DEST}/config/blast-radius.json`),
    ) as { modules: Record<string, ReadonlyArray<string>> };

    // Assert: `.claude/**` is an umbrella that matches nearly every radius in a
    // destination, because every agent in the runtime is instructed to read the
    // policy rules and process skills before doing any work. A module that
    // always fires carries no contention information and only suppresses
    // concurrency, so it must never reach a published document (issue #500).
    expect(Object.keys(published.modules)).not.toContain("claude-runtime");
  });

  it("overwrites the destination blast-radius rather than merging it", () => {
    // Arrange: only the routing path is merged; blast-radius is replaced. The
    // layout-bearing lister makes the derived document differ observably from
    // both the seeded source constant and the pre-existing destination bytes,
    // so the assertion has discriminating force.
    const preExisting = `${JSON.stringify(
      { version: 99, modules: { "destination-local": ["local/**"] } },
      null,
      2,
    )}\n`;
    const seeded = seedTree({
      [`${DEST}/config/blast-radius.json`]: preExisting,
    });

    // Act
    publish(seeded, null, layoutLister(SRC_APP_LAYOUT));
    const published = seeded.readTextFile(`${DEST}/config/blast-radius.json`);

    // Assert: the pre-existing content is gone rather than merged in, and the
    // replacement is the derived document, not the seeded source bytes.
    expect(published).not.toContain("destination-local");
    expect(published).not.toContain('"version": 99');
    expect(published).toContain('"src/App/**"');
    expect(published).not.toBe(SOURCE_BLAST_RADIUS);
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
