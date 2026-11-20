/**
 * Real-bundle tests of the push-down harness (issue #1029).
 *
 * The extension directory is read through `ReadThroughPushDownFileSystem`
 * (real reads, writes refused), and every destination write lands in a fresh
 * in-memory `/dest`, so no test creates a file or modifies the bundle.
 */

import * as nodePath from "node:path";

import {
  pushDownHarness,
  type PushDownHarnessOptions,
} from "../../../src/lib/push-down/push-down-harness";
import { type EcosystemName } from "../../../src/lib/push-down/push-down-layer";
import { SHARED_LAYER_ECOSYSTEM_EXCEPTIONS } from "../../../src/lib/push-down/push-down-shared-layer";
import {
  buildInMemoryFileSystem,
  fixedClock,
  type InMemoryPushDownFileSystem,
} from "./push-down.test-helpers";
import { ReadThroughPushDownFileSystem } from "./real-bundle-filesystem.test-helpers";

const EXTENSION_ROOT = nodePath
  .resolve(__dirname, "../../..")
  .replace(/\\/g, "/");
const CODEX_BUNDLE = `${EXTENSION_ROOT}/resources/codex-and-agents-customizations`;
const DEST = "/dest";
const CLOCK = fixedClock("2026-11-18T10:00:00Z");

/** Read a JSON manifest of the real Codex bundle. */
function codexManifestPaths(name: string): string[] {
  const fs = new ReadThroughPushDownFileSystem(
    EXTENSION_ROOT,
    buildInMemoryFileSystem(),
  );
  const parsed = JSON.parse(
    fs.readTextFile(`${CODEX_BUNDLE}/pack-manifests/${name}.json`),
  ) as { paths: string[] };
  return parsed.paths;
}

const SHARED_PATHS = codexManifestPaths("shared");

/** A fresh read-through adapter with an empty in-memory destination. */
function freshFs(): {
  fs: ReadThroughPushDownFileSystem;
  memory: InMemoryPushDownFileSystem;
} {
  const memory = buildInMemoryFileSystem({}, [DEST]);
  return {
    fs: new ReadThroughPushDownFileSystem(EXTENSION_ROOT, memory),
    memory,
  };
}

/** Run the harness for one ecosystem. */
function run(
  fs: ReadThroughPushDownFileSystem,
  ecosystem: EcosystemName,
  extra: Partial<PushDownHarnessOptions> = {},
  packs?: string[],
) {
  return pushDownHarness({
    extensionRoot: EXTENSION_ROOT,
    destinationRoot: DEST,
    fs,
    ecosystems: { [ecosystem]: packs === undefined ? {} : { packs } },
    clock: CLOCK,
    listEntries: () => [],
    ...extra,
  });
}

/** Destination-relative paths written into the in-memory destination. */
function destinationPaths(memory: InMemoryPushDownFileSystem): string[] {
  return memory.listFiles(DEST).map((path) => path.slice(DEST.length + 1));
}

const ECOSYSTEMS: ReadonlyArray<EcosystemName> = ["claude", "codex", "copilot"];

describe("push-down harness over the real bundle", () => {
  it.each(ECOSYSTEMS)("installs every shared-layer file (%s)", (ecosystem) => {
    const { fs, memory } = freshFs();

    run(fs, ecosystem);

    const written = new Set(destinationPaths(memory));
    expect(SHARED_PATHS.length).toBeGreaterThan(100);
    expect(SHARED_PATHS.filter((path) => !written.has(path))).toEqual([]);
  });

  it.each(ECOSYSTEMS)(
    "writes nothing under another ecosystem's layer (%s)",
    (ecosystem) => {
      const { fs, memory } = freshFs();
      const shared = new Set(SHARED_PATHS);

      run(fs, ecosystem);

      const outsideShared = destinationPaths(memory).filter(
        (path) => !shared.has(path),
      );
      const foreign = outsideShared.filter(
        (path) =>
          (ecosystem !== "claude" && path.startsWith(".claude/")) ||
          (ecosystem !== "codex" &&
            (path.startsWith(".codex/") || path.startsWith(".agents/"))) ||
          (ecosystem !== "copilot" && path.startsWith(".github/")),
      );
      expect(foreign).toEqual([]);
    },
  );

  it("publishes core plus selected packs", () => {
    const { fs, memory } = freshFs();
    const python = codexManifestPaths("python");
    const typescriptOnly = codexManifestPaths("typescript").filter(
      (path) =>
        !codexManifestPaths("core").includes(path) &&
        !python.includes(path) &&
        !SHARED_PATHS.includes(path),
    );

    const result = run(fs, "codex", {}, ["python"]);

    const written = new Set(destinationPaths(memory));
    expect(result.report.ecosystems["codex"]?.packs).toEqual([
      "core",
      "python",
    ]);
    expect(python.some((path) => written.has(path))).toBe(true);
    expect(typescriptOnly.length).toBeGreaterThan(0);
    expect(typescriptOnly.filter((path) => written.has(path))).toEqual([]);
  });

  it.each(ECOSYSTEMS)("second apply is a no-op (%s)", (ecosystem) => {
    const { fs, memory } = freshFs();
    run(fs, ecosystem);
    const firstWrites = memory.writtenPaths.length;

    const second = run(fs, ecosystem);

    const laterWrites = memory.writtenPaths
      .slice(firstWrites)
      .filter((path) => !path.startsWith(`${DEST}/artifacts/`));
    expect(laterWrites).toEqual([]);
    expect(
      Object.keys(second.report.counts).filter(
        (action) => !["unchanged", "merge", "excluded"].includes(action),
      ),
    ).toEqual([]);
  });

  it("keeps a local edit and reports conflict", () => {
    const { fs, memory } = freshFs();
    run(fs, "codex");
    memory.writeTextFile(`${DEST}/AGENTS.md`, "local edit\n");

    const second = run(fs, "codex");

    expect(memory.readTextFile(`${DEST}/AGENTS.md`)).toBe("local edit\n");
    expect(
      second.report.files.find((file) => file.path === "AGENTS.md")?.action,
    ).toBe("conflict");
    expect(second.warnings.some((line) => line.includes("AGENTS.md"))).toBe(
      true,
    );
    // Issue #1051: the kept edit is recorded as an integration item.
    expect(
      second.report.integration_needed?.items.map((item) => item.id),
    ).toEqual(["destination-edited-file:AGENTS.md"]);
  });

  it("first run without a manifest adopts and reports unmanaged-conflict", () => {
    const payload = new ReadThroughPushDownFileSystem(
      EXTENSION_ROOT,
      buildInMemoryFileSystem(),
    ).readTextFile(`${CODEX_BUNDLE}/AGENTS.md`);
    const declined = freshFs();
    declined.memory.seedFile(`${DEST}/AGENTS.md`, payload);
    declined.memory.seedFile(`${DEST}/.codex/config.toml`, "theirs\n");
    const opted = freshFs();
    opted.memory.seedFile(`${DEST}/.codex/config.toml`, "theirs\n");

    const result = run(declined.fs, "codex");
    run(opted.fs, "codex", { overwriteUnmanaged: true });

    const action = (path: string) =>
      result.report.files.find((file) => file.path === path)?.action;
    expect(action("AGENTS.md")).toBe("adopt");
    expect(action(".codex/config.toml")).toBe("unmanaged-conflict");
    expect(
      result.report.integration_needed?.items.map((item) => item.id),
    ).toContain("unmanaged-conflict:.codex/config.toml");
    expect(declined.memory.readTextFile(`${DEST}/.codex/config.toml`)).toBe(
      "theirs\n",
    );
    expect(opted.memory.readTextFile(`${DEST}/.codex/config.toml`)).not.toBe(
      "theirs\n",
    );
  });

  it("classifies a CRLF copy as unchanged", () => {
    const { fs, memory } = freshFs();
    run(fs, "copilot");
    const target = `${DEST}/.github/copilot-instructions.md`;
    memory.seedFile(target, memory.readTextFile(target).replace(/\n/g, "\r\n"));

    const second = run(fs, "copilot");

    expect(
      second.report.files.find(
        (file) => file.path === ".github/copilot-instructions.md",
      )?.action,
    ).toBe("unchanged");
  });

  it("merges the Codex routing document", () => {
    const { fs, memory } = freshFs();
    memory.seedFile(
      `${DEST}/config/orchestration-routing.json`,
      `${JSON.stringify({ routes: { "local-route": { description: "kept" } } })}\n`,
    );

    const result = run(fs, "codex");

    const merged = JSON.parse(
      memory.readTextFile(`${DEST}/config/orchestration-routing.json`),
    ) as { routes: Record<string, unknown> };
    expect(
      result.report.files.find(
        (file) => file.path === "config/orchestration-routing.json",
      )?.action,
    ).toBe("merge");
    expect(Object.keys(merged.routes)).toContain("local-route");
    expect(Object.keys(merged.routes)).toContain("small");
  });

  it.each(ECOSYSTEMS)(
    "honors .push-down-exclusions for all three (%s)",
    (ecosystem) => {
      const { fs, memory } = freshFs();
      memory.seedFile(`${DEST}/.push-down-exclusions`, "AGENTS.md\n");

      const result = run(fs, ecosystem);

      expect(memory.isFile(`${DEST}/AGENTS.md`)).toBe(false);
      expect(
        result.report.files.find((file) => file.path === "AGENTS.md")?.action,
      ).toBe("excluded");
    },
  );

  it("publishes ecosystem-layer exceptions only in a Codex run", () => {
    const outcomes = Object.fromEntries(
      ECOSYSTEMS.map((ecosystem) => {
        const { fs, memory } = freshFs();
        run(fs, ecosystem);
        return [ecosystem, memory] as const;
      }),
    ) as Record<EcosystemName, InMemoryPushDownFileSystem>;

    for (const exception of SHARED_LAYER_ECOSYSTEM_EXCEPTIONS) {
      expect(outcomes.codex.isFile(`${DEST}/${exception.path}`)).toBe(true);
      expect(outcomes.claude.isFile(`${DEST}/${exception.path}`)).toBe(false);
      expect(outcomes.copilot.isFile(`${DEST}/${exception.path}`)).toBe(false);
    }
    for (const ecosystem of ECOSYSTEMS) {
      expect(
        outcomes[ecosystem].isFile(
          `${DEST}/.agents/skills/test-execution-policy/SKILL.md`,
        ),
      ).toBe(true);
    }
  });
});
