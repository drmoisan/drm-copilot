/**
 * Prove the authorization record codec and digest against the host fixture.
 *
 * `tests/fixtures/discovery_host/tool-authorizations.json` pins the Python
 * `canonical_json` input digests, the tool/operation table, the root-only
 * operations and schema-checked records; every vector must replay here.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import {
  type AuthorityLocation,
  resolveAuthorityLocation,
} from "../src/discovery-authority-paths";
import type { TrustedBinding } from "../src/discovery-authorization";
import {
  AUTHORIZATION_RECORD_KEYS,
  canonicalJson,
  computeInputDigest,
  CONTROLLED_OPERATIONS,
  decodeToolAuthorization,
  DiscoveryAuthorizationError,
  type NativeIdentity,
  ROOT_ONLY_OPERATIONS,
  TOOL_OPERATIONS,
  type ToolAuthorizationRecord,
} from "../src/discovery-authorization-record";
interface DigestVector {
  readonly name: string;
  readonly tool: string;
  readonly operation: string;
  readonly inputs: Record<string, unknown>;
  readonly input_sha256: string;
}

interface HostVectors {
  readonly tool_operations: Record<string, string[]>;
  readonly controlled_operations: string[];
  readonly root_only_operations: string[];
  readonly identity: NativeIdentity;
  readonly workspace: TrustedBinding["workspace"];
  readonly digest_vectors: DigestVector[];
  readonly records: {
    readonly issued: ToolAuthorizationRecord;
    readonly consumed: ToolAuthorizationRecord;
    readonly revoked: ToolAuthorizationRecord;
    readonly expired: ToolAuthorizationRecord;
    readonly "root-identity-forgery": ToolAuthorizationRecord;
  };
  readonly invalid_records: Record<string, unknown>;
}

const FIXTURE_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "discovery_host",
  "tool-authorizations.json",
);
const vectors = JSON.parse(
  fs.readFileSync(FIXTURE_PATH, "utf8"),
) as HostVectors;
const LOCATION: AuthorityLocation = resolveAuthorityLocation(
  vectors.workspace.workspace_root,
  {
    platform: "windows",
    userHome: "C:/Users/Example",
    localAppData: "C:/Users/Example/AppData/Local",
  },
);
const [SORTED, UNSORTED, REORDERED] = vectors.digest_vectors;

describe("fixture parity", () => {
  it("binds the host fixture to the P8-T2 workspace identity", () => {
    expect(LOCATION.workspaceSha256).toBe(vectors.workspace.workspace_sha256);
    expect(LOCATION.workspace).toBe(vectors.workspace.workspace_root);
  });

  it.each(vectors.digest_vectors.map((row) => [row.name, row]))(
    "computes the Python canonical digest for %s",
    (_name, row) => {
      expect(computeInputDigest(row.tool, row.operation, row.inputs)).toBe(
        row.input_sha256,
      );
    },
  );

  it("normalizes key order but preserves array order", () => {
    expect(SORTED!.input_sha256).toBe(UNSORTED!.input_sha256);
    expect(SORTED!.input_sha256).not.toBe(REORDERED!.input_sha256);
  });

  it("pins the tool table, controlled operations and root-only operations", () => {
    expect(TOOL_OPERATIONS).toEqual(vectors.tool_operations);
    expect([...CONTROLLED_OPERATIONS]).toEqual(
      [...vectors.controlled_operations].sort(),
    );
    expect([...ROOT_ONLY_OPERATIONS]).toEqual(vectors.root_only_operations);
    expect(
      CONTROLLED_OPERATIONS.some((op) => ROOT_ONLY_OPERATIONS.includes(op)),
    ).toBe(false);
  });

  it.each(Object.entries(vectors.records))(
    "decodes schema-valid record %s",
    (_name, record) => {
      const decoded = decodeToolAuthorization(JSON.stringify(record));
      expect(decoded).toEqual(record);
      expect(Object.keys(decoded).sort()).toEqual([
        ...AUTHORIZATION_RECORD_KEYS,
      ]);
    },
  );

  it.each([
    ...Object.entries(vectors.invalid_records).map(
      ([name, record]) => [name, JSON.stringify(record)] as const,
    ),
    ["not-json", "{"] as const,
    ["array", "[]"] as const,
  ])("rejects malformed record %s", (_name, text) => {
    let code = "NO_ERROR";
    try {
      decodeToolAuthorization(text);
    } catch (error) {
      code = (error as DiscoveryAuthorizationError).code;
    }
    expect(code).toBe("AUTHORIZATION_RECORD_INVALID");
  });

  it.each([
    [{ ratio: 1.5 }],
    [{ big: 2 ** 53 }],
    [{ fn: () => undefined }],
    [{ missing: undefined }],
    [{ symbol: Symbol("x") }],
    [["array"]],
    ["text"],
    [null],
  ])("refuses non-canonical inputs %p", (inputs) => {
    let code = "NO_ERROR";
    try {
      computeInputDigest("read_discovery_source", "read-source", inputs);
    } catch (error) {
      code = (error as DiscoveryAuthorizationError).code;
    }
    expect(code).toBe("AUTHORIZATION_INPUT_INVALID");
  });

  it("renders canonical JSON with sorted keys, compact separators and LF", () => {
    expect(canonicalJson({ b: [1, true, null], a: "x" })).toBe(
      '{"a":"x","b":[1,true,null]}\n',
    );
  });
});
