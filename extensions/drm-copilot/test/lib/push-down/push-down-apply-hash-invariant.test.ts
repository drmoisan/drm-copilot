/**
 * Hash-of-written-bytes invariant of the push-down apply step (issue #1049).
 *
 * After one apply run over an in-memory destination, every `files` entry of
 * `.push-down-manifest.json` records the canonical hash (CR/LF-normalized
 * UTF-8 SHA-256) of the bytes now at that destination path, for the `create`,
 * `update`, `adopt` and `converged` decisions. CRLF payload text is built in
 * code, so no CRLF fixture is committed.
 */

import { createHash } from "node:crypto";

import { applyPushDownPlan } from "../../../src/lib/push-down/push-down-apply";
import {
  hashPayloadText,
  parseDestinationManifest,
} from "../../../src/lib/push-down/push-down-destination-manifest";
import { runPushDownPipeline } from "../../../src/lib/push-down/push-down-pipeline";
import {
  buildInMemoryFileSystem,
  fixedClock,
  type InMemoryPushDownFileSystem,
} from "./push-down.test-helpers";
import { makeTestLayer } from "./push-down-pipeline.test-helpers";

const CLOCK = fixedClock("2026-11-19T09:00:00Z");
const MANIFEST_PATH = "/dest/.push-down-manifest.json";
const CRLF = "\r\n";

/** Seed one file per arranged decision plus a previous manifest. */
function arrangedDestination(): InMemoryPushDownFileSystem {
  const h = hashPayloadText;
  return buildInMemoryFileSystem({
    "/src/codex/.x/create.md": `new${CRLF}line${CRLF}`,
    "/src/codex/.x/update.md": `v2${CRLF}`,
    "/dest/.x/update.md": "v1\n",
    "/src/codex/.x/adopt.md": "same\nline\n",
    "/dest/.x/adopt.md": `same${CRLF}line${CRLF}`,
    "/src/codex/.x/converged.md": "v2\n",
    "/dest/.x/converged.md": `v2${CRLF}`,
    [MANIFEST_PATH]: JSON.stringify({
      schema_version: "1.0.0",
      payload_version: "0.9.0",
      selection: {},
      files: {
        ".x/update.md": { layer: "codex", pack: "core", sha256: h("v1\n") },
        ".x/converged.md": { layer: "codex", pack: "core", sha256: h("v1\n") },
      },
    }),
  });
}

/** Plan once and apply once; return the apply result. */
function planAndApply(fs: InMemoryPushDownFileSystem) {
  const planned = runPushDownPipeline({
    repoRoot: "/src",
    destinationRoot: "/dest",
    fs,
    buildLayers: () => [makeTestLayer(fs, "codex")],
    clock: CLOCK,
  });
  return applyPushDownPlan(planned, {
    payloadVersion: "1.2.3",
    artifactRoot: "/dest",
    clock: CLOCK,
  });
}

/**
 * Canonical hash of the bytes now stored at a destination path, computed
 * independently of `hashPayloadText`: CR LF and then lone CR become LF, and
 * the UTF-8 bytes are hashed with `node:crypto`.
 */
function hashOfBytesAt(fs: InMemoryPushDownFileSystem, path: string): string {
  const bytes = Buffer.from(fs.readTextFile(path), "utf8");
  const normalized = bytes
    .toString("utf8")
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n");
  return createHash("sha256")
    .update(Buffer.from(normalized, "utf8"))
    .digest("hex");
}

describe("push-down apply hash-of-written-bytes invariant", () => {
  it("classifies the four arranged files as create, update, adopt and converged", () => {
    const fs = arrangedDestination();

    const applied = planAndApply(fs);

    const actions = Object.fromEntries(
      applied.report.files.map((file) => [file.path, file.action]),
    );
    expect(actions).toEqual({
      ".x/adopt.md": "adopt",
      ".x/converged.md": "converged",
      ".x/create.md": "create",
      ".x/update.md": "update",
    });
  });

  it("records for every files entry the sha256 of the bytes now at that path", () => {
    const fs = arrangedDestination();

    planAndApply(fs);
    const manifest = parseDestinationManifest(fs.readTextFile(MANIFEST_PATH));

    const entries = Object.entries(manifest.files);
    expect(entries.map(([path]) => path).sort()).toEqual([
      ".x/adopt.md",
      ".x/converged.md",
      ".x/create.md",
      ".x/update.md",
    ]);
    for (const [path, entry] of entries) {
      expect({ path, sha256: entry.sha256 }).toEqual({
        path,
        sha256: hashOfBytesAt(fs, `/dest/${path}`),
      });
    }
  });
});
