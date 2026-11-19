/**
 * Hash parity between the push-down manifest writer and the shared corpus
 * (issue #1049).
 *
 * `tests/fixtures/push-down-manifest-hash/corpus.json` is read by this test
 * and by the PoshQC Pester suite, so the TypeScript writer and the PowerShell
 * checker are held to the same canonical hash rule: CRLF and then lone CR
 * become LF, the UTF-8 bytes are hashed, and a byte-order mark is kept.
 */

import { createHash } from "node:crypto";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  hashPayloadText,
  parseDestinationManifest,
} from "../../../src/lib/push-down/push-down-destination-manifest";

interface CorpusCase {
  readonly name: string;
  readonly text: string;
  readonly sha256: string;
}

interface Corpus {
  readonly cases: ReadonlyArray<CorpusCase>;
}

const FIXTURE_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "push-down-manifest-hash",
  "corpus.json",
);

const CORPUS = JSON.parse(fs.readFileSync(FIXTURE_PATH, "utf8")) as Corpus;

const ABC_SHA256 =
  "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";

/** Render a minimal valid manifest with optional extra fields. */
function manifestText(
  extraTopLevel: Record<string, unknown>,
  extraPerFile: Record<string, unknown>,
): string {
  return JSON.stringify({
    schema_version: "1.0.0",
    payload_version: "1.2.3",
    selection: { claude: { packs: ["core"] } },
    files: {
      ".claude/hooks/a.ps1": {
        layer: "claude",
        pack: "core",
        sha256: ABC_SHA256,
        ...extraPerFile,
      },
    },
    ...extraTopLevel,
  });
}

const EXPECTED_MANIFEST = {
  schemaVersion: "1.0.0",
  payloadVersion: "1.2.3",
  selection: { claude: { packs: ["core"] } },
  files: {
    ".claude/hooks/a.ps1": {
      layer: "claude",
      pack: "core",
      sha256: ABC_SHA256,
    },
  },
};

describe("push-down manifest hash corpus", () => {
  it.each(CORPUS.cases.map((entry) => [entry.name, entry] as const))(
    "hashPayloadText matches the corpus digest for %s",
    (_name, entry) => {
      expect(hashPayloadText(entry.text)).toBe(entry.sha256);
    },
  );

  it.each(CORPUS.cases.map((entry) => [entry.name, entry] as const))(
    "an independent node:crypto digest of the normalized UTF-8 bytes matches the corpus for %s",
    (_name, entry) => {
      const normalized = entry.text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
      const digest = createHash("sha256")
        .update(Buffer.from(normalized, "utf8"))
        .digest("hex");

      expect(digest).toBe(entry.sha256);
    },
  );

  it("the corpus names every required case", () => {
    expect(CORPUS.cases.map((entry) => entry.name)).toEqual([
      "empty",
      "abc",
      "lf-pair",
      "crlf-pair",
      "lone-cr",
      "cr-crlf",
      "bom",
      "non-ascii",
      "trailing-crlf",
    ]);
  });
});

describe("parseDestinationManifest reader tolerance", () => {
  it("parseDestinationManifest ignores an unknown top-level field", () => {
    const parsed = parseDestinationManifest(
      manifestText({ future_field: { nested: true } }, {}),
    );

    expect(parsed).toEqual(EXPECTED_MANIFEST);
  });

  it("parseDestinationManifest ignores an unknown per-file field", () => {
    const parsed = parseDestinationManifest(
      manifestText({}, { source_ref: "abc", mode: "copy" }),
    );

    expect(parsed).toEqual(EXPECTED_MANIFEST);
  });
});
