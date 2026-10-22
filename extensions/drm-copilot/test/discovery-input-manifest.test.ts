/**
 * Prove the independent input-manifest recomputation and drift classification.
 *
 * The runtime-reported manifest is validated against the committed
 * `service-result` schema shape, then re-read from an in-memory workspace so
 * every drift kind (edited, deleted, appeared, renamed, evidence replaced,
 * profile changed) is observed from bytes rather than trusted from the result.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import {
  createNodeInputReader,
  DiscoveryInputManifestError,
  INPUT_CATEGORIES,
  type InputManifest,
  inputManifestDigest,
  recomputeInputManifest,
  requireFreshInputs,
  validateInputManifest,
  workspacePath,
} from "../src/discovery-input-manifest";
import { digestOf, MemoryInputReader } from "./discovery-store-test-helpers";

const SCHEMA = JSON.parse(
  fs.readFileSync(
    path.resolve(
      __dirname,
      "..",
      "..",
      "..",
      "schemas",
      "discovery",
      "v2",
      "service-result.schema.json",
    ),
    "utf8",
  ),
) as {
  $defs: Record<
    string,
    { required: string[]; properties: Record<string, { enum?: string[] }> }
  >;
};

const ROOT = "C:/Users/Example/Repos/Workspace";
const PROFILE = "docs/migration/discovery/domain-profile.yaml";
const SOURCE = "src/Orders/Order.cs";
const EVIDENCE = "docs/evidence/run-1.json";
const MISSING = "docs/migration/discovery/scope.yaml";
const TEXT = {
  profile: "schema_version: 2.0.0\nname: example\n",
  source: "public class Order {}\n",
  evidence: '{"run": 1}\n',
};

function entry(relative: string, text: string, category: string) {
  return {
    path: relative,
    sha256: digestOf(text),
    size: new TextEncoder().encode(text).byteLength,
    category,
  };
}

function manifest(): InputManifest {
  return {
    entries: [
      entry(PROFILE, TEXT.profile, "profile"),
      entry(SOURCE, TEXT.source, "source"),
      entry(EVIDENCE, TEXT.evidence, "evidence"),
    ],
    missing_paths: [MISSING],
    source_repositories: [{ id: "legacy-crm", revision: "a".repeat(40) }],
    target_repositories: [{ id: "modern-crm", revision: "b".repeat(64) }],
    sha256: "0".repeat(64),
  };
}

function workspace(): MemoryInputReader {
  const reader = new MemoryInputReader();
  reader.write(workspacePath(ROOT, PROFILE), TEXT.profile);
  reader.write(workspacePath(ROOT, SOURCE), TEXT.source);
  reader.write(workspacePath(ROOT, EVIDENCE), TEXT.evidence);
  return reader;
}

const PROFILE_BINDING = { path: PROFILE, sha256: digestOf(TEXT.profile) };

function recompute(
  reader: MemoryInputReader,
  value: InputManifest = manifest(),
) {
  return recomputeInputManifest({
    manifest: value,
    reader,
    workspaceRoot: ROOT,
    profile: PROFILE_BINDING,
  });
}

function codeOf(action: () => unknown): string {
  try {
    action();
  } catch (error) {
    if (error instanceof DiscoveryInputManifestError) {
      return error.code;
    }
    throw error;
  }
  return "NO_ERROR";
}

describe("validateInputManifest", () => {
  it("accepts a schema-shaped manifest and pins the category enum", () => {
    expect(validateInputManifest(manifest())).toEqual(manifest());
    expect([...INPUT_CATEGORIES]).toEqual(
      SCHEMA.$defs["input"]!.properties["category"]!.enum,
    );
    expect(Object.keys(manifest()).sort()).toEqual(
      [...SCHEMA.$defs["input-manifest"]!.required].sort(),
    );
    expect(Object.keys(manifest().entries[0]!).sort()).toEqual(
      [...SCHEMA.$defs["input"]!.required].sort(),
    );
  });

  it.each([
    ["null", null],
    ["array", []],
    ["extra key", { ...manifest(), destination: "x" }],
    ["entries not array", { ...manifest(), entries: {} }],
    [
      "entry extra key",
      { ...manifest(), entries: [{ ...manifest().entries[0]!, note: 1 }] },
    ],
    [
      "entry bad category",
      {
        ...manifest(),
        entries: [{ ...manifest().entries[0]!, category: "shell" }],
      },
    ],
    [
      "entry negative size",
      { ...manifest(), entries: [{ ...manifest().entries[0]!, size: -1 }] },
    ],
    [
      "entry float size",
      { ...manifest(), entries: [{ ...manifest().entries[0]!, size: 1.5 }] },
    ],
    [
      "entry bad digest",
      {
        ...manifest(),
        entries: [{ ...manifest().entries[0]!, sha256: "ABC" }],
      },
    ],
    [
      "entry absolute path",
      {
        ...manifest(),
        entries: [{ ...manifest().entries[0]!, path: "/etc/x" }],
      },
    ],
    [
      "duplicate entries",
      {
        ...manifest(),
        entries: [manifest().entries[0]!, manifest().entries[0]!],
      },
    ],
    ["duplicate missing", { ...manifest(), missing_paths: [MISSING, MISSING] }],
    ["missing path listed", { ...manifest(), missing_paths: [SOURCE] }],
    ["missing path invalid", { ...manifest(), missing_paths: ["../x"] }],
    [
      "repository bad id",
      {
        ...manifest(),
        source_repositories: [{ id: "Legacy", revision: "a".repeat(40) }],
      },
    ],
    [
      "repository bad revision",
      { ...manifest(), target_repositories: [{ id: "x", revision: "abc" }] },
    ],
    [
      "repository extra key",
      {
        ...manifest(),
        target_repositories: [{ id: "x", revision: "a".repeat(40), url: "u" }],
      },
    ],
    [
      "duplicate repositories",
      {
        ...manifest(),
        source_repositories: [
          { id: "x", revision: "a".repeat(40) },
          { id: "x", revision: "b".repeat(40) },
        ],
      },
    ],
    ["bad manifest digest", { ...manifest(), sha256: "nope" }],
  ])("rejects %s", (_label, value) => {
    expect(codeOf(() => validateInputManifest(value))).toBe(
      "INPUT_MANIFEST_INVALID",
    );
  });
});

describe("recomputeInputManifest", () => {
  it("reproduces an unchanged workspace with a recomputed digest and no drift", () => {
    const result = recompute(workspace());
    expect(result.drift).toEqual([]);
    expect(result.manifest.entries).toEqual(manifest().entries);
    expect(result.manifest.missing_paths).toEqual([MISSING]);
    expect(result.manifest.source_repositories).toEqual(
      manifest().source_repositories,
    );
    const { sha256, ...members } = result.manifest;
    expect(sha256).toBe(inputManifestDigest(members));
    expect(sha256).not.toBe(manifest().sha256);
    expect(
      requireFreshInputs({
        manifest: manifest(),
        reader: workspace(),
        workspaceRoot: ROOT,
        profile: PROFILE_BINDING,
      }),
    ).toEqual(result.manifest);
  });

  it("classifies an edited source input", () => {
    const reader = workspace();
    reader.write(
      workspacePath(ROOT, SOURCE),
      "public class Order { int Id; }\n",
    );
    const result = recompute(reader);
    expect(result.drift).toEqual([
      {
        kind: "edited",
        path: SOURCE,
        detail: expect.stringContaining(digestOf(TEXT.source)) as string,
      },
    ]);
    expect(result.manifest.entries[1]!.sha256).toBe(
      digestOf("public class Order { int Id; }\n"),
    );
  });

  it("classifies a deleted input", () => {
    const reader = workspace();
    reader.files.delete(workspacePath(ROOT, SOURCE));
    const result = recompute(reader);
    expect(result.drift.map((item) => item.kind)).toEqual(["deleted"]);
    expect(result.manifest.entries.map((item) => item.path)).toEqual([
      PROFILE,
      EVIDENCE,
    ]);
  });

  it("classifies a newly appeared input that the runtime found missing", () => {
    const reader = workspace();
    reader.write(workspacePath(ROOT, MISSING), "scope: all\n");
    const result = recompute(reader);
    expect(result.drift).toEqual([
      { kind: "appeared", path: MISSING, detail: "missing input now exists" },
    ]);
    expect(result.manifest.missing_paths).toEqual([]);
  });

  it("classifies a rename as deleted plus renamed", () => {
    const reader = workspace();
    reader.files.delete(workspacePath(ROOT, SOURCE));
    reader.write(workspacePath(ROOT, MISSING), TEXT.source);
    const result = recompute(reader);
    expect(result.drift.map((item) => [item.kind, item.path])).toEqual([
      ["deleted", SOURCE],
      ["renamed", MISSING],
    ]);
    expect(result.drift[1]!.detail).toBe(`moved from ${SOURCE}`);
  });

  it("names evidence replacement separately from ordinary edits", () => {
    const reader = workspace();
    reader.write(workspacePath(ROOT, EVIDENCE), '{"run": 2}\n');
    expect(recompute(reader).drift.map((item) => item.kind)).toEqual([
      "evidence-replaced",
    ]);
  });

  it("reports a changed profile as both an edit and a binding change", () => {
    const reader = workspace();
    reader.write(
      workspacePath(ROOT, PROFILE),
      "schema_version: 2.0.0\nname: other\n",
    );
    expect(recompute(reader).drift.map((item) => item.kind)).toEqual([
      "edited",
      "profile-changed",
    ]);
  });

  it("reports a profile that was never read as a binding change", () => {
    const value = { ...manifest(), entries: manifest().entries.slice(1) };
    const result = recompute(workspace(), value);
    expect(result.drift).toEqual([
      {
        kind: "profile-changed",
        path: PROFILE,
        detail: "profile was not among the inputs read",
      },
    ]);
  });

  it("reports a profile whose bytes differ from the activation binding", () => {
    const result = recomputeInputManifest({
      manifest: manifest(),
      reader: workspace(),
      workspaceRoot: ROOT,
      profile: { path: PROFILE, sha256: "9".repeat(64) },
    });
    expect(result.drift[0]!.kind).toBe("profile-changed");
    expect(result.drift[0]!.detail).toContain("differs from activation");
  });

  it("throws INPUT_DRIFT carrying every drift item", () => {
    const reader = workspace();
    reader.files.delete(workspacePath(ROOT, EVIDENCE));
    reader.write(workspacePath(ROOT, SOURCE), "changed\n");
    let caught: DiscoveryInputManifestError | undefined;
    try {
      requireFreshInputs({
        manifest: manifest(),
        reader,
        workspaceRoot: ROOT,
        profile: PROFILE_BINDING,
      });
    } catch (error) {
      caught = error as DiscoveryInputManifestError;
    }
    expect(caught?.code).toBe("INPUT_DRIFT");
    expect(caught?.drift.map((item) => item.kind)).toEqual([
      "edited",
      "deleted",
    ]);
    expect(caught?.message).toContain(`edited:${SOURCE}, deleted:${EVIDENCE}`);
  });

  it("joins workspace paths with a single separator", () => {
    expect(workspacePath("C:/root/", "a/b")).toBe("C:/root/a/b");
    expect(workspacePath("C:\\root\\", "a/b")).toBe("C:\\root/a/b");
    expect(workspacePath("/srv/ws", "a")).toBe("/srv/ws/a");
  });
});

describe("createNodeInputReader", () => {
  function errno(code: string): Error {
    return Object.assign(new Error(code), { code });
  }

  it("returns bytes for files and null for absent paths or directories", () => {
    const reader = createNodeInputReader({
      readFileSync: (target: string) => {
        if (target.endsWith("dir")) {
          throw errno("EISDIR");
        }
        if (target.endsWith("missing")) {
          throw errno("ENOENT");
        }
        if (target.endsWith("notdir")) {
          throw errno("ENOTDIR");
        }
        return Buffer.from("bytes");
      },
    });
    expect(Array.from(reader.readBytes("/x/file")!)).toEqual(
      Array.from(Buffer.from("bytes")),
    );
    expect(reader.readBytes("/x/dir")).toBeNull();
    expect(reader.readBytes("/x/missing")).toBeNull();
    expect(reader.readBytes("/x/notdir")).toBeNull();
  });

  it("propagates other failures and defaults to node:fs", () => {
    const denied = createNodeInputReader({
      readFileSync: () => {
        throw errno("EACCES");
      },
    });
    expect(() => denied.readBytes("/x")).toThrow("EACCES");
    expect(
      createNodeInputReader().readBytes(
        path.join(__dirname, "does-not-exist.bin"),
      ),
    ).toBeNull();
  });
});
