/**
 * Prove the activation record codec against the shared Python fixture.
 *
 * Record encoding, decoding, locator rendering and rejection codes replay
 * `tests/fixtures/discovery_authority/authority-vectors.json`, so the
 * TypeScript codec cannot drift from `ActivationRecord` in Python.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import {
  ACTIVATION_RECORD_KEYS,
  type ActivationRecord,
  assertRelativePath,
  decodeActivationRecord,
  DiscoveryAuthorityError,
  encodeActivationRecord,
  renderLocator,
} from "../src/discovery-authority-record";
import { sha256Hex } from "../src/discovery-authority-paths";

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

describe("activation record fixture parity", () => {
  it.each(vectors.records.map((row) => [row.name, row]))(
    "decodes and re-encodes %s byte for byte",
    (_name, row) => {
      const decoded = decodeActivationRecord(row.encoded, {
        workspaceSha256: WORKSPACE_SHA256,
      });
      expect(decoded).toEqual(row.record);
      expect(encodeActivationRecord(decoded)).toBe(row.encoded);
      expect(sha256Hex(row.encoded)).toBe(row.encoded_sha256);
    },
  );

  it.each(
    vectors.records
      .filter((row) => row.locator_text !== null)
      .map((row) => [row.name, row]),
  )("renders the locator for %s exactly as Python", (_name, row) => {
    expect(renderLocator(row.record.profile_path!)).toBe(row.locator_text);
    expect(sha256Hex(row.locator_text!)).toBe(row.record.locator_sha256);
    expect(sha256Hex(row.profile_bytes!)).toBe(row.record.profile_sha256);
  });

  it.each(vectors.invalid_records.map((row) => [row.name, row]))(
    "rejects malformed record %s with the Python code",
    (_name, row) => {
      expect(
        codeOf(() =>
          decodeActivationRecord(row.text, {
            workspaceSha256: WORKSPACE_SHA256,
          }),
        ),
      ).toBe(row.code);
    },
  );

  it("rejects an oversized record and a non-string profile path", () => {
    const base = vectors.records[0]!.record;
    const oversized = `${vectors.records[0]!.encoded}${" ".repeat(65536)}`;
    expect(
      codeOf(() =>
        decodeActivationRecord(oversized, {
          workspaceSha256: WORKSPACE_SHA256,
        }),
      ),
    ).toBe("ACTIVATION_INVALID");
    expect(
      codeOf(() =>
        decodeActivationRecord(JSON.stringify({ ...base, profile_path: 7 }), {
          workspaceSha256: WORKSPACE_SHA256,
        }),
      ),
    ).toBe("ACTIVATION_INVALID");
    expect([...ACTIVATION_RECORD_KEYS]).toEqual(Object.keys(base).sort());
  });

  it.each([
    "/absolute.yaml",
    "docs/../x.yaml",
    "docs/./x.yaml",
    "docs/trailing./x.yaml",
    "docs/trailing /x.yaml",
    "docs/CON.yaml",
    "docs/com1/x.yaml",
    'docs/"quoted".yaml',
    "docs\\windows.yaml",
    "docs/control\u0001.yaml",
    "docs/delete\u007f.yaml",
    "",
  ])("rejects relative path %j", (candidate) => {
    expect(codeOf(() => assertRelativePath(candidate))).toBe(
      "ACTIVATION_REQUEST_INVALID",
    );
  });

  it("accepts Unicode, spaces and capitals in relative paths", () => {
    expect(assertRelativePath("docs/équipe/Discovery Profile.yaml")).toBe(
      "docs/équipe/Discovery Profile.yaml",
    );
  });
});
