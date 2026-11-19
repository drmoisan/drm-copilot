/**
 * Unit tests for the push-down destination manifest (issue #1029).
 *
 * Each case builds its input in memory; reads go through a fresh
 * {@link buildInMemoryFileSystem} fake, so no test touches the disk.
 */

import {
  DESTINATION_MANIFEST_RELATIVE_PATH,
  DESTINATION_MANIFEST_SCHEMA_VERSION,
  type DestinationManifest,
  DestinationManifestError,
  describeInvalidRelativePath,
  hashPayloadText,
  parseDestinationManifest,
  readDestinationManifest,
  renderDestinationManifest,
} from "../../../src/lib/push-down/push-down-destination-manifest";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

const HASH_A = "a".repeat(64);

/** A valid manifest document as raw JSON-ready data. */
function validDocument(): Record<string, unknown> {
  return {
    schema_version: "1.0.0",
    payload_version: "1.2.3",
    selection: {
      claude: {
        packs: ["core", "python"],
        csharp_variant: "modern",
        memory_mode: "overwrite",
      },
    },
    files: {
      ".claude/agents/a.md": { layer: "claude", pack: "core", sha256: HASH_A },
    },
  };
}

/** Parse a document and return the thrown manifest error. */
function parseError(document: unknown): DestinationManifestError {
  try {
    parseDestinationManifest(JSON.stringify(document));
  } catch (error) {
    if (error instanceof DestinationManifestError) {
      return error;
    }
    throw error;
  }
  throw new Error("expected parseDestinationManifest to throw");
}

describe("parseDestinationManifest", () => {
  it("accepts a valid manifest and maps snake_case fields", () => {
    const manifest = parseDestinationManifest(JSON.stringify(validDocument()));
    expect(manifest.schemaVersion).toBe("1.0.0");
    expect(manifest.payloadVersion).toBe("1.2.3");
    expect(manifest.selection["claude"]).toEqual({
      packs: ["core", "python"],
      csharpVariant: "modern",
      memoryMode: "overwrite",
    });
    expect(manifest.files[".claude/agents/a.md"]).toEqual({
      layer: "claude",
      pack: "core",
      sha256: HASH_A,
    });
  });

  it("rejects invalid JSON", () => {
    expect(() => parseDestinationManifest("{not json")).toThrow(
      DestinationManifestError,
    );
  });

  it("rejects a document that is not an object", () => {
    expect(parseError([1, 2]).field).toBe("(document)");
  });

  it.each([
    ["missing", undefined],
    ["non-string", 1],
    ["non-semver", "1.0"],
    ["unknown major", "2.0.0"],
  ])("rejects schema_version (%s)", (_label, value) => {
    const document = validDocument();
    document["schema_version"] = value;
    expect(parseError(document).field).toBe("schema_version");
  });

  it.each([
    ["missing", undefined],
    ["empty", ""],
  ])("rejects payload_version (%s)", (_label, value) => {
    const document = validDocument();
    document["payload_version"] = value;
    expect(parseError(document).field).toBe("payload_version");
  });

  it("rejects selection when missing", () => {
    const document = validDocument();
    delete document["selection"];
    expect(parseError(document).field).toBe("selection");
  });

  it("rejects a selection key that is not an ecosystem name", () => {
    const document = validDocument();
    document["selection"] = { vim: { packs: ["core"] } };
    expect(parseError(document).message).toContain("not an ecosystem name");
  });

  it("rejects a selection value that is not an object", () => {
    const document = validDocument();
    document["selection"] = { codex: "core" };
    expect(parseError(document).field).toBe("selection.codex");
  });

  it("rejects selection packs that are not a list of strings", () => {
    const document = validDocument();
    document["selection"] = { codex: { packs: ["core", 3] } };
    expect(parseError(document).field).toBe("selection.codex.packs");
  });

  it.each([
    ["unsorted", ["python", "core"], "not sorted"],
    ["omitting core", ["python"], "omit core"],
  ])(
    "rejects a selection whose packs are unsorted or omit core (%s)",
    (_label, packs, reason) => {
      const document = validDocument();
      document["selection"] = { copilot: { packs } };
      const error = parseError(document);
      expect(error.field).toBe("selection.copilot.packs");
      expect(error.message).toContain(reason);
    },
  );

  it.each([
    ["csharp_variant", { packs: ["core"], csharp_variant: 1 }],
    ["memory_mode", { packs: ["core"], memory_mode: false }],
  ])("rejects selection %s that is not a string", (field, entry) => {
    const document = validDocument();
    document["selection"] = { claude: entry };
    expect(parseError(document).field).toBe(`selection.claude.${field}`);
  });

  it("rejects files when missing", () => {
    const document = validDocument();
    delete document["files"];
    expect(parseError(document).field).toBe("files");
  });

  it("rejects a files entry that is not an object", () => {
    const document = validDocument();
    document["files"] = { "a.md": "x" };
    expect(parseError(document).field).toBe("files.a.md");
  });

  it("rejects an unknown layer", () => {
    const document = validDocument();
    document["files"] = {
      "a.md": { layer: "vim", pack: "core", sha256: HASH_A },
    };
    expect(parseError(document).field).toBe("files.a.md.layer");
  });

  it("rejects an empty pack", () => {
    const document = validDocument();
    document["files"] = {
      "a.md": { layer: "shared", pack: "", sha256: HASH_A },
    };
    expect(parseError(document).field).toBe("files.a.md.pack");
  });

  it.each([
    ["short", "abc123"],
    ["uppercase", "A".repeat(64)],
    ["non-string", 42],
  ])("rejects a non-64-hex sha256 (%s)", (_label, sha256) => {
    const document = validDocument();
    document["files"] = { "a.md": { layer: "codex", pack: "core", sha256 } };
    expect(parseError(document).field).toBe("files.a.md.sha256");
  });

  it.each([
    ["leading slash", "/etc/a.md", "absolute"],
    ["drive letter", "C:/repo/a.md", "drive letter"],
    ["UNC prefix", "\\\\server\\share\\a.md", "backslash"],
    ["UNC forward-slash prefix", "//server/share/a.md", "absolute"],
    ["backslash", ".claude\\a.md", "backslash"],
    ["dot-dot segment", ".claude/../a.md", "'..' segment"],
  ])("rejects a path with a %s", (_label, path, reason) => {
    const document = validDocument();
    document["files"] = {
      [path]: { layer: "claude", pack: "core", sha256: HASH_A },
    };
    const error = parseError(document);
    expect(error.field).toBe("files");
    expect(error.message).toContain(reason);
  });
});

describe("describeInvalidRelativePath", () => {
  it("rejects an empty path and accepts a relative POSIX path", () => {
    expect(describeInvalidRelativePath("")).toBe("path is empty");
    expect(
      describeInvalidRelativePath(".agents/skills/a/SKILL.md"),
    ).toBeUndefined();
  });
});

describe("renderDestinationManifest", () => {
  const manifest: DestinationManifest = {
    schemaVersion: DESTINATION_MANIFEST_SCHEMA_VERSION,
    payloadVersion: "1.2.3",
    selection: {
      codex: { packs: ["core"] },
      claude: {
        packs: ["core", "python"],
        csharpVariant: "modern",
        memoryMode: "merge",
      },
    },
    files: {
      "z.md": { layer: "shared", pack: "core", sha256: HASH_A },
      "a.md": { layer: "claude", pack: "python", sha256: "b".repeat(64) },
    },
  };

  it("round-trips a valid manifest with sorted keys and a trailing LF", () => {
    const text = renderDestinationManifest(manifest);
    expect(text.endsWith("}\n")).toBe(true);
    expect(text.indexOf('"a.md"')).toBeLessThan(text.indexOf('"z.md"'));
    expect(text.indexOf('"claude"')).toBeLessThan(text.indexOf('"codex"'));
    expect(text.indexOf('"files"')).toBeLessThan(
      text.indexOf('"payload_version"'),
    );
    expect(text).toContain('\n  "files": {');
    expect(parseDestinationManifest(text)).toEqual(manifest);
  });

  it("renders no byte-order mark and no CR", () => {
    const text = renderDestinationManifest(manifest);
    expect(text.charCodeAt(0)).not.toBe(0xfeff);
    expect(text).not.toContain("\r");
  });

  it("renders exactly the schema fields", () => {
    const parsed = JSON.parse(renderDestinationManifest(manifest)) as {
      files: { "a.md": Record<string, unknown> };
      selection: {
        claude: Record<string, unknown>;
        codex: Record<string, unknown>;
      };
    };
    expect(Object.keys(parsed).sort()).toEqual([
      "files",
      "payload_version",
      "schema_version",
      "selection",
    ]);
    expect(Object.keys(parsed.files["a.md"]).sort()).toEqual([
      "layer",
      "pack",
      "sha256",
    ]);
    expect(Object.keys(parsed.selection.claude).sort()).toEqual([
      "csharp_variant",
      "memory_mode",
      "packs",
    ]);
    expect(Object.keys(parsed.selection.codex)).toEqual(["packs"]);
  });

  it("renders no timestamp field and no absolute path", () => {
    const text = renderDestinationManifest(manifest);
    expect(text).not.toMatch(/\d{4}-\d{2}-\d{2}T\d{2}/);
    expect(text).not.toMatch(/"(?:\/|[A-Za-z]:)/);
    expect(text).not.toMatch(/_at"/);
  });
});

describe("hashPayloadText", () => {
  it("hashes CRLF and LF text equally", () => {
    expect(hashPayloadText("a\r\nb\r\n")).toBe(hashPayloadText("a\nb\n"));
    expect(hashPayloadText("a\rb")).toBe(hashPayloadText("a\nb"));
    expect(hashPayloadText("a\nb")).toMatch(/^[0-9a-f]{64}$/);
    expect(hashPayloadText("a")).not.toBe(hashPayloadText("b"));
  });
});

describe("readDestinationManifest", () => {
  it("returns undefined when the destination has no manifest", () => {
    const fs = buildInMemoryFileSystem({}, ["/dest"]);
    expect(readDestinationManifest(fs, "/dest/")).toBeUndefined();
  });

  it("reads and validates a present manifest", () => {
    const fs = buildInMemoryFileSystem({
      [`/dest/${DESTINATION_MANIFEST_RELATIVE_PATH}`]:
        JSON.stringify(validDocument()),
    });
    expect(readDestinationManifest(fs, "/dest")?.payloadVersion).toBe("1.2.3");
  });

  it("rejects a directory at the manifest path", () => {
    const fs = buildInMemoryFileSystem({}, [
      `/dest/${DESTINATION_MANIFEST_RELATIVE_PATH}`,
    ]);
    expect(() => readDestinationManifest(fs, "/dest")).toThrow(
      "not a regular file",
    );
  });
});
