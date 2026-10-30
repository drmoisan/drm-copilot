/**
 * Prove the protected activation store over injected I/O seams.
 *
 * The store is exercised over an in-memory `AuthorityStoreIO` and the Node
 * adapter over an injected fake `node:fs` subset, so no filesystem is touched.
 * Expected record bytes come from the shared Python fixture.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import {
  ActivationStore,
  type AuthorityStoreIO,
  DiscoveryAuthorityError,
  PROTECTED_CLAIM_KEYS,
  rejectCallerAuthorityClaims,
} from "../src/discovery-authority";
import {
  resolveAuthorityLocation,
  sha256Hex,
} from "../src/discovery-authority-paths";
import type { ActivationRecord } from "../src/discovery-authority-record";

interface RecordRow {
  readonly name: string;
  readonly profile_bytes: string | null;
  readonly locator_text: string | null;
  readonly record: ActivationRecord;
  readonly encoded: string;
  readonly encoded_sha256: string;
}

interface AuthorityVectors {
  readonly locations: { workspace_root: string; workspace_sha256: string }[];
  readonly records: RecordRow[];
  readonly invalid_records: { name: string; text: string; code: string }[];
}

const FIXTURE_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "discovery_authority",
  "authority-vectors.json",
);
const vectors = JSON.parse(
  fs.readFileSync(FIXTURE_PATH, "utf8"),
) as AuthorityVectors;
const WORKSPACE_SHA256 = vectors.locations[0]!.workspace_sha256;
const LOCATION = resolveAuthorityLocation(
  vectors.locations[0]!.workspace_root,
  {
    platform: "windows",
    userHome: "C:/Users/Example",
    localAppData: "C:/Users/Example/AppData/Local",
  },
);

/** In-memory store I/O that records every touched path and supports race hooks. */
class MemoryAuthorityIO implements AuthorityStoreIO {
  readonly files = new Map<string, string>();
  readonly directories = new Set<string>();
  readonly reads: string[] = [];
  readonly operations: string[] = [];
  afterCreate: (path: string) => void = () => undefined;
  afterRead: (count: number) => void = () => undefined;
  failPublish = false;

  readText(path: string): string | null {
    this.reads.push(path);
    const text = this.files.get(path) ?? null;
    this.afterRead(this.reads.length);
    return text;
  }

  createExclusive(path: string, text: string): void {
    this.operations.push(`create ${path}`);
    if (this.files.has(path)) {
      throw new DiscoveryAuthorityError("AUTHORITY_LOCKED", `exists ${path}`);
    }
    this.files.set(path, text);
    this.afterCreate(path);
  }

  publish(stagedPath: string, targetPath: string, replace: boolean): void {
    this.operations.push(
      `publish ${stagedPath} -> ${targetPath} ${String(replace)}`,
    );
    if (this.failPublish) {
      throw new Error("publish failed");
    }
    if (!replace && this.files.has(targetPath)) {
      throw new DiscoveryAuthorityError("ACTIVATION_CHANGED", "target exists");
    }
    this.files.set(targetPath, this.files.get(stagedPath)!);
    this.files.delete(stagedPath);
  }

  remove(path: string): void {
    this.operations.push(`remove ${path}`);
    this.files.delete(path);
  }

  ensureDirectory(path: string): void {
    this.operations.push(`mkdir ${path}`);
    this.directories.add(path);
  }
}

function makeStore(io: MemoryAuthorityIO): ActivationStore {
  let counter = 0;
  return new ActivationStore({
    location: LOCATION,
    io,
    nonce: () => {
      counter += 1;
      return `nonce${String(counter)}`;
    },
  });
}

function codeOf(action: () => unknown): string {
  try {
    action();
  } catch (error) {
    if (error instanceof DiscoveryAuthorityError) {
      return error.code;
    }
    throw error;
  }
  return "NO_ERROR";
}

describe("ActivationStore transitions", () => {
  it("reproduces the fixture chain through activate, activate and deactivate", () => {
    const io = new MemoryAuthorityIO();
    const store = makeStore(io);
    const [first, second, third] = vectors.records;
    expect(store.read()).toBeNull();

    store.activate({
      profilePath: first!.record.profile_path,
      profileText: first!.profile_bytes,
    });
    expect(io.readText(`${LOCATION.directory}/activation.json`)).toBe(
      first!.encoded,
    );

    store.activate({
      profilePath: second!.record.profile_path,
      profileText: second!.profile_bytes,
    });
    expect(io.readText(`${LOCATION.directory}/activation.json`)).toBe(
      second!.encoded,
    );

    const tombstone = store.deactivate();
    expect(io.readText(`${LOCATION.directory}/activation.json`)).toBe(
      third!.encoded,
    );
    expect(tombstone).toEqual(third!.record);
    expect(store.read()?.action).toBe("deactivate");
    // Lock and staged files never outlive a transition.
    expect([...io.files.keys()]).toEqual([
      `${LOCATION.directory}/activation.json`,
    ]);
    expect(io.directories.has(LOCATION.directory)).toBe(true);
  });

  it("deactivating an empty registry writes a bare tombstone", () => {
    const io = new MemoryAuthorityIO();
    const record = makeStore(io).deactivate();
    expect(record).toEqual({
      workspace_sha256: WORKSPACE_SHA256,
      generation: 1,
      action: "deactivate",
      profile_path: null,
      profile_sha256: null,
      locator_sha256: null,
      previous_sha256: null,
      schema_version: "2.0.0",
    });
  });

  it("holds the lock exclusively and never steals a present lock", () => {
    const io = new MemoryAuthorityIO();
    io.files.set(`${LOCATION.directory}/mutation.lock`, "");
    const store = makeStore(io);
    expect(codeOf(() => store.deactivate())).toBe("AUTHORITY_LOCKED");
    expect(io.files.get(`${LOCATION.directory}/mutation.lock`)).toBe("");
    expect(io.files.has(`${LOCATION.directory}/activation.json`)).toBe(false);
  });

  it("rejects reentrant guards from within a transition", () => {
    const io = new MemoryAuthorityIO();
    const store = makeStore(io);
    let inner = "unset";
    io.afterCreate = (created) => {
      if (created.endsWith("mutation.lock")) {
        inner = codeOf(() => store.deactivate());
      }
    };
    store.deactivate();
    expect(inner).toBe("AUTHORITY_LOCKED");
    expect(io.files.has(`${LOCATION.directory}/mutation.lock`)).toBe(false);
  });

  it("fails with ACTIVATION_CHANGED when the record moves under the lock", () => {
    const io = new MemoryAuthorityIO();
    const store = makeStore(io);
    // A writer that ignores the lock lands between the original read and the
    // pre-publication re-read; the second read is the decode re-read.
    io.afterRead = (count) => {
      if (count === 2) {
        io.files.set(
          `${LOCATION.directory}/activation.json`,
          vectors.records[0]!.encoded,
        );
      }
    };
    expect(codeOf(() => store.deactivate())).toBe("ACTIVATION_CHANGED");
    expect(io.files.has(`${LOCATION.directory}/.activation-nonce1`)).toBe(
      false,
    );
    expect(io.files.has(`${LOCATION.directory}/mutation.lock`)).toBe(false);
    expect(io.files.get(`${LOCATION.directory}/activation.json`)).toBe(
      vectors.records[0]!.encoded,
    );
  });

  it("removes the staged file and releases the lock when publication fails", () => {
    const io = new MemoryAuthorityIO();
    io.failPublish = true;
    const store = makeStore(io);
    expect(() => store.deactivate()).toThrow("publish failed");
    expect([...io.files.keys()]).toEqual([]);
    expect(io.operations.filter((entry) => entry.startsWith("remove"))).toEqual(
      [
        `remove ${LOCATION.directory}/.activation-nonce1`,
        `remove ${LOCATION.directory}/mutation.lock`,
      ],
    );
  });

  it("treats a malformed or foreign record as an error, not as inactive", () => {
    const io = new MemoryAuthorityIO();
    const store = makeStore(io);
    io.files.set(`${LOCATION.directory}/activation.json`, "{");
    expect(codeOf(() => store.read())).toBe("ACTIVATION_INVALID");
    expect(codeOf(() => store.deactivate())).toBe("ACTIVATION_INVALID");
    io.files.set(
      `${LOCATION.directory}/activation.json`,
      vectors.invalid_records.find((row) => row.name === "wrong-workspace")!
        .text,
    );
    expect(codeOf(() => store.read())).toBe("ACTIVATION_WORKSPACE");
  });

  it("reads only the protected directory and ignores workspace copies", () => {
    const io = new MemoryAuthorityIO();
    const store = makeStore(io);
    io.files.set(
      `${LOCATION.workspace}/.drm-copilot/activation.json`,
      vectors.records[0]!.encoded,
    );
    io.files.set(`${LOCATION.workspace}/config/discovery.json`, "{}");
    expect(store.read()).toBeNull();
    expect(codeOf(() => store.envelope())).toBe("ACTIVATION_INACTIVE");
    expect(
      io.reads.every((read) => read.startsWith(`${LOCATION.directory}/`)),
    ).toBe(true);
  });
});

describe("ActivationStore envelope", () => {
  it("binds receipts to the protected record and survives workspace deletion", () => {
    const io = new MemoryAuthorityIO();
    const store = makeStore(io);
    const row = vectors.records[1]!;
    const workspaceFiles = new Map<string, string>([
      [`${LOCATION.workspace}/${row.record.profile_path!}`, row.profile_bytes!],
      [`${LOCATION.workspace}/config/discovery.json`, row.locator_text!],
    ]);
    store.activate({
      profilePath: row.record.profile_path,
      profileText: workspaceFiles.get(
        `${LOCATION.workspace}/${row.record.profile_path!}`,
      ),
    });
    const before = store.envelope();
    workspaceFiles.clear();
    const after = store.envelope();
    expect(after).toEqual(before);
    expect(after.workspace).toEqual({
      workspace_root: LOCATION.workspace,
      workspace_sha256: WORKSPACE_SHA256,
      profile_path: row.record.profile_path,
      profile_sha256: row.record.profile_sha256,
    });
    expect(after.generation).toBe(1);
    expect(after.activation_sha256).toBe(
      sha256Hex(io.files.get(`${LOCATION.directory}/activation.json`)!),
    );
  });

  it("refuses an envelope for a deactivated workspace", () => {
    const io = new MemoryAuthorityIO();
    const store = makeStore(io);
    store.activate({
      profilePath: vectors.records[0]!.record.profile_path,
      profileText: vectors.records[0]!.profile_bytes,
    });
    store.deactivate();
    expect(codeOf(() => store.envelope())).toBe("ACTIVATION_INACTIVE");
  });
});

describe("caller claim rejection", () => {
  it.each(PROTECTED_CLAIM_KEYS.map((key) => [key]))(
    "rejects an activation request carrying %s",
    (key) => {
      const io = new MemoryAuthorityIO();
      const store = makeStore(io);
      const request: Record<string, unknown> = {
        profilePath: "docs/profile.yaml",
        profileText: "name: x\n",
      };
      request[key] = "claimed";
      expect(codeOf(() => store.activate(request))).toBe(
        "AUTHORITY_CLAIM_REJECTED",
      );
      expect(io.operations).toEqual([]);
    },
  );

  it.each([
    [null],
    ["string"],
    [["array"]],
    [{ profilePath: "docs/profile.yaml" }],
    [{ profilePath: "docs/profile.yaml", profileText: "x", extra: 1 }],
    [{ profilePath: 1, profileText: "x" }],
    [{ profilePath: "docs/../profile.yaml", profileText: "x" }],
  ])("rejects activation input %j", (input) => {
    const io = new MemoryAuthorityIO();
    expect(codeOf(() => makeStore(io).activate(input))).toBe(
      "ACTIVATION_REQUEST_INVALID",
    );
    expect(io.operations).toEqual([]);
  });

  it("ignores non-object payloads and lists every protected key present", () => {
    expect(() => rejectCallerAuthorityClaims("text", "Report")).not.toThrow();
    expect(() => rejectCallerAuthorityClaims(null, "Report")).not.toThrow();
    expect(() =>
      rejectCallerAuthorityClaims({ summary: "ok", items: [] }, "Report"),
    ).not.toThrow();
    expect(() =>
      rejectCallerAuthorityClaims(
        { destination: "C:/x", identity: {}, validation_result: "pass" },
        "Invocation mirror",
      ),
    ).toThrow(
      "Invocation mirror must not supply protected claims: destination, identity, validation_result",
    );
  });
});
