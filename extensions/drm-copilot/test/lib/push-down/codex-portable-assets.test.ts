import {
  PORTABLE_ASSET_RELATIVE_PATHS,
  PortableAssetFileSystem,
} from "../../../src/lib/push-down/codex-portable-assets";
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

function buildResourceFiles(resourceRoot: string): Record<string, string> {
  return Object.fromEntries(
    PORTABLE_ASSET_RELATIVE_PATHS.map((relativePath) => [
      `${resourceRoot}/${relativePath}`,
      `generic:${relativePath}\n`,
    ]),
  );
}

describe("PortableAssetFileSystem", () => {
  it("defines exactly the approved portable asset set", () => {
    expect(PORTABLE_ASSET_RELATIVE_PATHS).toHaveLength(15);
    expect(new Set(PORTABLE_ASSET_RELATIVE_PATHS).size).toBe(15);
    expect(
      PORTABLE_ASSET_RELATIVE_PATHS.filter((path) =>
        path.startsWith(".claude/lib/bash/"),
      ),
    ).toHaveLength(9);
    expect(
      PORTABLE_ASSET_RELATIVE_PATHS.filter((path) =>
        path.startsWith(".claude/lib/blast-radius/"),
      ),
    ).toHaveLength(5);
    expect(PORTABLE_ASSET_RELATIVE_PATHS).toContain("config/blast-radius.json");
  });

  it("virtualizes only approved assets and reads the generic config", () => {
    const resourceRoot = "/resources/claude-customizations";
    const inner = new MemoryFileSystem({
      ...buildResourceFiles(resourceRoot),
      "/src/.claude/rules/unrelated.md": "unrelated\n",
      "/src/config/blast-radius.json": "repo-specific\n",
      "/src/config/orchestration-routing.json": "routing\n",
    });
    const fs = new PortableAssetFileSystem(inner, {
      sourceRoot: "/src",
      resourceRoot,
      publishedPaths: null,
    });

    const claudeFiles = fs.listFiles("/src/.claude");
    const configFiles = fs.listFiles("/src/config");

    expect(claudeFiles).toEqual(
      PORTABLE_ASSET_RELATIVE_PATHS.filter((path) =>
        path.startsWith(".claude/"),
      ).map((path) => `/src/${path}`),
    );
    expect(claudeFiles).not.toContain("/src/.claude/rules/unrelated.md");
    expect(configFiles).toEqual([
      "/src/config/blast-radius.json",
      "/src/config/orchestration-routing.json",
    ]);
    expect(fs.readTextFile("/src/config/blast-radius.json")).toBe(
      "generic:config/blast-radius.json\n",
    );
    expect(fs.isFile("/src/config/blast-radius.json")).toBe(true);
  });

  it("honors manifest selection and delegates nonportable operations", () => {
    const resourceRoot = "/resources/claude-customizations";
    const selectedPath = PORTABLE_ASSET_RELATIVE_PATHS[0];
    const inner = new MemoryFileSystem(buildResourceFiles(resourceRoot));
    const fs = new PortableAssetFileSystem(inner, {
      sourceRoot: "/src",
      resourceRoot,
      publishedPaths: new Set([selectedPath]),
    });

    fs.ensureDir("/dest/.claude");
    fs.writeTextFile("/dest/result.txt", "result\n");

    expect(fs.listFiles("/src/.claude")).toEqual([`/src/${selectedPath}`]);
    expect(fs.listFiles("/src/config")).toEqual([]);
    expect(fs.isFile("/src/config/blast-radius.json")).toBe(false);
    expect(fs.isDir("/dest/.claude")).toBe(true);
    expect(fs.readTextFile("/dest/result.txt")).toBe("result\n");
  });

  it("reports unequal destination collisions in stable allowlist order", () => {
    const resourceRoot = "/resources/claude-customizations";
    const first = PORTABLE_ASSET_RELATIVE_PATHS[0];
    const second = PORTABLE_ASSET_RELATIVE_PATHS[1];
    const inner = new MemoryFileSystem({
      ...buildResourceFiles(resourceRoot),
      [`/dest/${first}`]: "destination:first\n",
      [`/dest/${second}`]: "destination:second\n",
    });
    const fs = new PortableAssetFileSystem(inner, {
      sourceRoot: "/src",
      resourceRoot,
      publishedPaths: new Set([second, first]),
    });

    expect(() => fs.validateDestinationCollisions("/dest")).toThrow(
      `Portable asset collision(s) detected: ${first}, ${second}`,
    );
    expect(inner.readTextFile(`/dest/${first}`)).toBe("destination:first\n");
    expect(inner.readTextFile(`/dest/${second}`)).toBe("destination:second\n");
  });
});
