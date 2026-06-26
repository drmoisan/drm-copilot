import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  collectSchemaErrors,
  collectTargets,
  validateFile,
} from "../../../src/lib/validate/json-validator";

/**
 * Compile a glob into an anchored RegExp using the `**`/`*`/`?` token semantics
 * shared with the production glob, so the fake validates consumer logic rather
 * than the glob engine.
 */
function compileGlob(pattern: string): RegExp {
  let regex = "";
  let index = 0;
  while (index < pattern.length) {
    const char = pattern[index];
    if (char === "*") {
      if (pattern[index + 1] === "*") {
        if (pattern[index + 2] === "/") {
          regex += "(?:.*/)?";
          index += 3;
        } else {
          regex += ".*";
          index += 2;
        }
        continue;
      }
      regex += "[^/]*";
      index += 1;
      continue;
    }
    if (char === "?") {
      regex += "[^/]";
      index += 1;
      continue;
    }
    regex += (char ?? "").replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    index += 1;
  }
  return new RegExp(`^${regex}$`);
}

/** In-memory FileSystem fake mapping file paths to their text content. */
class VirtualFileSystem implements FileSystem {
  private readonly contents: Map<string, string>;
  private readonly dirs: Set<string>;

  constructor(files: Record<string, string>) {
    this.contents = new Map(Object.entries(files));
    this.dirs = new Set<string>();
    // Derive every ancestor directory of each file path for glob/dir checks.
    for (const file of this.contents.keys()) {
      const segments = file.split("/");
      for (let count = 1; count < segments.length; count += 1) {
        this.dirs.add(segments.slice(0, count).join("/"));
      }
    }
  }

  glob(root: string, pattern: string): string[] {
    const normalizedRoot = root.replace(/\/+$/, "");
    const prefix = `${normalizedRoot}/`;
    const matcher = compileGlob(pattern);
    const matches: string[] = [];
    // Test each known file relative to the root against the compiled glob.
    for (const file of this.contents.keys()) {
      if (!file.startsWith(prefix)) {
        continue;
      }
      const relative = file.slice(prefix.length);
      if (matcher.test(relative)) {
        matches.push(file);
      }
    }
    return matches;
  }

  isFile(path: string): boolean {
    return this.contents.has(path);
  }

  readTextFile(path: string): string {
    const content = this.contents.get(path);
    if (content === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return content;
  }

  writeTextFile(): void {
    throw new Error("not used");
  }

  ensureDir(): void {
    throw new Error("not used");
  }
}

describe("collectSchemaErrors", () => {
  it("reports a missing required property", () => {
    // Arrange / Act
    const errors = collectSchemaErrors(
      { type: "object", required: ["key"] },
      {},
    );

    // Assert
    expect(errors).toContain("['key']: is a required property");
  });

  it("reports a number-type mismatch", () => {
    // Arrange / Act
    const errors = collectSchemaErrors(
      { type: "object", properties: { key: { type: "number" } } },
      { key: "bad" },
    );

    // Assert
    expect(errors).toContain("['key']: expected number");
  });

  it("returns no errors when the data satisfies the schema", () => {
    // Arrange / Act
    const errors = collectSchemaErrors(
      {
        type: "object",
        properties: { key: { type: "number" } },
        required: ["key"],
      },
      { key: 1 },
    );

    // Assert
    expect(errors).toEqual([]);
  });
});

describe("validateFile", () => {
  it("returns ok for JSON validating against a local relative schema", () => {
    // Arrange
    const fs = new VirtualFileSystem({
      "/repo/schema.json": JSON.stringify({
        type: "object",
        properties: { key: { type: "number" } },
        required: ["key"],
      }),
      "/repo/data.json": '{"$schema": "./schema.json", "key": 1}',
    });

    // Act
    const [ok, msg] = validateFile(fs, "/repo/data.json");

    // Assert
    expect(ok).toBe(true);
    expect(msg).toBe("/repo/data.json: ok");
  });

  it("reports invalid JSON", () => {
    // Arrange
    const fs = new VirtualFileSystem({ "/repo/f.json": '{"key":' });

    // Act
    const [ok, msg] = validateFile(fs, "/repo/f.json");

    // Assert
    expect(ok).toBe(false);
    expect(msg).toContain("invalid JSON");
  });

  it("reports a non-object root", () => {
    // Arrange
    const fs = new VirtualFileSystem({ "/repo/f.json": '["array"]' });

    // Act
    const [ok, msg] = validateFile(fs, "/repo/f.json");

    // Assert
    expect(ok).toBe(false);
    expect(msg).toContain("JSON root must be an object");
  });

  it("reports a missing $schema", () => {
    // Arrange
    const fs = new VirtualFileSystem({ "/repo/f.json": '{"key":1}' });

    // Act
    const [ok, msg] = validateFile(fs, "/repo/f.json");

    // Assert
    expect(ok).toBe(false);
    expect(msg).toContain("missing $schema");
  });

  it("reports a non-string $schema as missing", () => {
    // Arrange
    const fs = new VirtualFileSystem({ "/repo/f.json": '{"$schema": 123}' });

    // Act
    const [ok, msg] = validateFile(fs, "/repo/f.json");

    // Assert
    expect(ok).toBe(false);
    expect(msg).toContain("missing $schema");
  });

  it("reports a schema file that is not found", () => {
    // Arrange: $schema points at a relative file that does not exist.
    const fs = new VirtualFileSystem({
      "/repo/data.json": '{"$schema": "./missing.json", "key": 1}',
    });

    // Act
    const [ok, msg] = validateFile(fs, "/repo/data.json");

    // Assert
    expect(ok).toBe(false);
    expect(msg).toContain("Schema file not found:");
    expect(msg).toContain("validation error");
  });

  it("reports an unsupported http scheme", () => {
    // Arrange
    const fs = new VirtualFileSystem({
      "/repo/f.json": '{"$schema":"https://example.com/schema.json","key":1}',
    });

    // Act
    const [ok, msg] = validateFile(fs, "/repo/f.json");

    // Assert
    expect(ok).toBe(false);
    expect(msg).toContain("Unsupported schema URI scheme: https");
  });

  it("reports a built-in checker required-property failure", () => {
    // Arrange
    const fs = new VirtualFileSystem({
      "/repo/schema.json": JSON.stringify({
        type: "object",
        properties: { key: { type: "number" } },
        required: ["key"],
      }),
      "/repo/data.json": '{"$schema": "./schema.json"}',
    });

    // Act
    const [ok, msg] = validateFile(fs, "/repo/data.json");

    // Assert
    expect(ok).toBe(false);
    expect(msg).toContain("schema validation failed");
    expect(msg).toContain("is a required property");
  });

  it("reports a built-in checker number-type failure", () => {
    // Arrange
    const fs = new VirtualFileSystem({
      "/repo/schema.json": JSON.stringify({
        type: "object",
        properties: { key: { type: "number" } },
        required: ["key"],
      }),
      "/repo/data.json": '{"$schema": "./schema.json", "key": "bad"}',
    });

    // Act
    const [ok, msg] = validateFile(fs, "/repo/data.json");

    // Assert
    expect(ok).toBe(false);
    expect(msg).toContain("schema validation failed");
    expect(msg).toContain("expected number");
  });
});

describe("collectTargets", () => {
  it("collects explicit file targets verbatim", () => {
    // Arrange
    const fs = new VirtualFileSystem({
      "/repo/a.json": "{}",
      "/repo/b.json": "{}",
    });

    // Act
    const targets = collectTargets(fs, "/repo", [
      "/repo/a.json",
      "/repo/b.json",
    ]);

    // Assert
    expect(targets).toContain("/repo/a.json");
    expect(targets).toContain("/repo/b.json");
  });

  it("expands a directory target to its contained JSON files", () => {
    // Arrange
    const fs = new VirtualFileSystem({
      "/repo/subdir/test.json": "{}",
    });

    // Act
    const targets = collectTargets(fs, "/repo", ["/repo/subdir"]);

    // Assert
    expect(targets).toContain("/repo/subdir/test.json");
  });

  it("falls back to governed files when no paths are given", () => {
    // Arrange: scripts/**/*.json is a governed glob; data/** is excluded.
    const fs = new VirtualFileSystem({
      "/repo/scripts/config.json": "{}",
      "/repo/data/corpus.json": "{}",
    });

    // Act
    const targets = collectTargets(fs, "/repo", []);

    // Assert
    expect(targets).toContain("/repo/scripts/config.json");
    expect(targets).not.toContain("/repo/data/corpus.json");
  });
});
