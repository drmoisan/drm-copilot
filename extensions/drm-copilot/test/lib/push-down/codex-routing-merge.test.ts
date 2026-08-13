import {
  AdditiveRoutingMergeFileSystem,
  mergeAdditiveRoutingDocuments,
  RoutingMergeConflictError,
} from "../../../src/lib/push-down/claude-routing-merge";
import { type PushDownFileSystem } from "../../../src/lib/push-down/filesystem-adapter";

class MemoryFileSystem implements PushDownFileSystem {
  readonly files = new Map<string, string>();
  readonly directories = new Set<string>();

  constructor(files: Readonly<Record<string, string>>) {
    for (const [path, content] of Object.entries(files)) {
      this.files.set(path, content);
    }
  }

  listFiles(root: string): string[] {
    const prefix = `${root.replace(/\/+$/, "")}/`;
    return [...this.files.keys()]
      .filter((path) => path.startsWith(prefix))
      .sort();
  }

  isDir(path: string): boolean {
    return this.directories.has(path);
  }

  isFile(path: string): boolean {
    return this.files.has(path);
  }

  readTextFile(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`Missing in-memory file: ${path}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    this.files.set(path, content);
  }

  ensureDir(path: string): void {
    this.directories.add(path);
  }
}

function document(value: Readonly<Record<string, unknown>>): string {
  return `${JSON.stringify(value, null, 2)}\n`;
}

describe("additive Codex routing merge", () => {
  it("preserves destination ownership and sorts source additions", () => {
    const destination = document({
      routes: { destination: { owner: "destination" } },
      destination_only: { enabled: true },
    });
    const source = document({
      source_z: 2,
      routes: {
        beta: { owner: "source" },
        alpha: { owner: "source" },
      },
      codex_model_policy: {
        generated_agent_families: ["commit-steward"],
      },
      source_a: 1,
    });

    const merged = JSON.parse(
      mergeAdditiveRoutingDocuments(
        destination,
        source,
        "config/orchestration-routing.json",
      ),
    ) as Record<string, unknown>;
    const routes = merged["routes"] as Record<string, unknown>;

    expect(Object.keys(merged)).toEqual([
      "routes",
      "destination_only",
      "codex_model_policy",
      "source_a",
      "source_z",
    ]);
    expect(Object.keys(routes)).toEqual(["destination", "alpha", "beta"]);
    expect(routes["destination"]).toEqual({ owner: "destination" });
    expect(merged["destination_only"]).toEqual({ enabled: true });
    expect(merged["codex_model_policy"]).toEqual({
      generated_agent_families: ["commit-steward"],
    });
  });

  it("skips equal entries without rewriting destination bytes", () => {
    const destination = '{"routes":{"shared":{"a":1,"b":2}},"owned":true}\n';
    const source = '{"routes":{"shared":{"b":2,"a":1}}}\n';

    const merged = mergeAdditiveRoutingDocuments(
      destination,
      source,
      "config/orchestration-routing.json",
    );

    expect(merged).toBe(destination);
  });

  it("rejects non-object routing document roots", () => {
    const invalidDestination = "[]\n";

    expect(() =>
      mergeAdditiveRoutingDocuments(
        invalidDestination,
        "{}\n",
        "config/orchestration-routing.json",
      ),
    ).toThrow("document root is not a JSON object");
  });

  it("adds a sorted routes object when the destination has no routes", () => {
    const merged = JSON.parse(
      mergeAdditiveRoutingDocuments(
        "{}\n",
        document({ routes: { zeta: 2, alpha: 1 } }),
        "config/orchestration-routing.json",
      ),
    ) as Record<string, unknown>;

    expect(merged).toEqual({ routes: { alpha: 1, zeta: 2 } });
  });

  it("reports unequal array configuration as a substantive conflict", () => {
    expect(() =>
      mergeAdditiveRoutingDocuments(
        document({ generated_agent_families: ["planner"] }),
        document({ generated_agent_families: ["orchestrator"] }),
        "config/orchestration-routing.json",
      ),
    ).toThrow(
      expect.objectContaining({
        conflicts: ["generated_agent_families"],
      }),
    );
  });

  it("fails substantive collisions in stable reason order", () => {
    const target = "/dest/config/orchestration-routing.json";
    const destination = document({
      routes: {
        zeta: { owner: "destination" },
        alpha: { owner: "destination" },
      },
    });
    const source = document({
      routes: {
        zeta: { owner: "source" },
        alpha: { owner: "source" },
      },
    });
    const inner = new MemoryFileSystem({ [target]: destination });
    const fs = new AdditiveRoutingMergeFileSystem(
      inner,
      "/dest",
      "config/orchestration-routing.json",
    );

    let captured: RoutingMergeConflictError | null = null;
    try {
      fs.writeTextFile(target, source);
    } catch (error) {
      if (error instanceof RoutingMergeConflictError) {
        captured = error;
      } else {
        throw error;
      }
    }

    expect(captured?.reasonCode).toBe("ROUTING_MERGE_SUBSTANTIVE_COLLISION");
    expect(captured?.conflicts).toEqual(["routes.alpha", "routes.zeta"]);
    expect(captured?.message).toBe(
      "ROUTING_MERGE_SUBSTANTIVE_COLLISION: " +
        "/dest/config/orchestration-routing.json: " +
        "routes.alpha, routes.zeta",
    );
    expect(inner.readTextFile(target)).toBe(destination);
  });

  it("delegates unrelated configuration and non-write operations", () => {
    const routingPath = "/dest/config/orchestration-routing.json";
    const unrelatedPath = "/dest/config/blast-radius.json";
    const inner = new MemoryFileSystem({
      [routingPath]: document({ routes: {} }),
      [unrelatedPath]: "destination-owned\n",
    });
    const fs = new AdditiveRoutingMergeFileSystem(
      inner,
      "/dest",
      "config/orchestration-routing.json",
    );

    fs.ensureDir("/dest/config");
    fs.writeTextFile(unrelatedPath, "source-content\n");

    expect(fs.listFiles("/dest")).toEqual([unrelatedPath, routingPath]);
    expect(fs.isDir("/dest/config")).toBe(true);
    expect(fs.isFile(unrelatedPath)).toBe(true);
    expect(fs.readTextFile(unrelatedPath)).toBe("source-content\n");
  });
});
