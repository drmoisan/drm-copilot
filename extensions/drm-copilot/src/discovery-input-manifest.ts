/**
 * Recompute the complete discovery input set independently of the runtime.
 *
 * The Python runtime reports the inputs it read (`input_manifest` on the
 * service result). Before the gateway records any success it re-reads every
 * listed input from the workspace through an injected byte reader, recomputes
 * the digests and sizes, confirms that paths reported missing are still
 * missing, checks that the protected profile binding is still what was read,
 * and classifies every difference as drift: edited, deleted, appeared, renamed,
 * evidence replaced or profile changed. The recomputed manifest, not the
 * runtime's, is what a protected receipt carries. This module performs no
 * writes and holds no authority.
 */

import { createHash } from "node:crypto";
import * as nodeFs from "node:fs";

import { sha256Hex } from "./discovery-authority-paths";
import { assertRelativePath } from "./discovery-authority-record";
import { canonicalJson } from "./discovery-authorization-record";

export const INPUT_CATEGORIES: ReadonlyArray<string> = [
  "profile",
  "activation",
  "scope",
  "inventory",
  "artifact",
  "evidence",
  "source-snapshot",
  "extension-schema",
  "extension-result",
  "source",
  "test",
  "documentation",
];
const SHA256 = /^[0-9a-f]{64}$/u;
const IDENTIFIER = /^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$/u;
const REVISION = /^(?:[0-9a-f]{40}|[0-9a-f]{64})$/u;
const ENTRY_KEYS = "category,path,sha256,size";
const MANIFEST_KEYS =
  "entries,missing_paths,sha256,source_repositories,target_repositories";

export type InputManifestCode = "INPUT_MANIFEST_INVALID" | "INPUT_DRIFT";

export type InputDriftKind =
  | "edited"
  | "deleted"
  | "appeared"
  | "renamed"
  | "evidence-replaced"
  | "profile-changed";

export interface InputDrift {
  readonly kind: InputDriftKind;
  readonly path: string;
  readonly detail: string;
}

/** Raised when a manifest is malformed or the workspace no longer matches it. */
export class DiscoveryInputManifestError extends Error {
  readonly code: InputManifestCode;
  readonly drift: ReadonlyArray<InputDrift>;

  constructor(
    code: InputManifestCode,
    message: string,
    drift: ReadonlyArray<InputDrift> = [],
  ) {
    super(message);
    this.name = "DiscoveryInputManifestError";
    this.code = code;
    this.drift = drift;
  }
}

export interface InputManifestEntry {
  readonly path: string;
  readonly sha256: string;
  readonly size: number;
  readonly category: string;
}

export interface RepositoryReference {
  readonly id: string;
  readonly revision: string;
}

/** Validated `service-result#/$defs/input-manifest`. */
export interface InputManifest {
  readonly entries: ReadonlyArray<InputManifestEntry>;
  readonly missing_paths: ReadonlyArray<string>;
  readonly source_repositories: ReadonlyArray<RepositoryReference>;
  readonly target_repositories: ReadonlyArray<RepositoryReference>;
  readonly sha256: string;
}

/** Narrow byte reader; the Node adapter and test fakes implement it. */
export interface InputBytesReader {
  /** Bytes at the absolute `path`, or null when no regular file exists. */
  readBytes(path: string): Uint8Array | null;
}

export interface RecomputedInputs {
  readonly manifest: InputManifest;
  readonly drift: ReadonlyArray<InputDrift>;
}

function invalid(detail: string): DiscoveryInputManifestError {
  return new DiscoveryInputManifestError(
    "INPUT_MANIFEST_INVALID",
    `Input manifest is malformed: ${detail}`,
  );
}

function relative(value: unknown, detail: string): string {
  if (typeof value !== "string") {
    throw invalid(detail);
  }
  try {
    return assertRelativePath(value);
  } catch {
    throw invalid(detail);
  }
}

function decodeEntry(value: unknown): InputManifestEntry {
  const row = value as Record<string, unknown> | null;
  if (
    row === null ||
    typeof row !== "object" ||
    Object.keys(row).sort().join(",") !== ENTRY_KEYS
  ) {
    throw invalid("entry keys");
  }
  const { path, sha256, size, category } = row;
  if (
    typeof sha256 !== "string" ||
    !SHA256.test(sha256) ||
    typeof size !== "number" ||
    !Number.isInteger(size) ||
    size < 0 ||
    typeof category !== "string" ||
    !INPUT_CATEGORIES.includes(category)
  ) {
    throw invalid("entry fields");
  }
  return { path: relative(path, "entry path"), sha256, size, category };
}

function decodeRepository(value: unknown): RepositoryReference {
  const row = value as { id?: unknown; revision?: unknown } | null;
  if (
    row === null ||
    typeof row !== "object" ||
    Object.keys(row).sort().join(",") !== "id,revision" ||
    typeof row.id !== "string" ||
    !IDENTIFIER.test(row.id) ||
    typeof row.revision !== "string" ||
    !REVISION.test(row.revision)
  ) {
    throw invalid("repository reference");
  }
  return { id: row.id, revision: row.revision };
}

function unique(values: ReadonlyArray<string>, detail: string): void {
  if (new Set(values).size !== values.length) {
    throw invalid(detail);
  }
}

/** Parse a runtime-reported input manifest strictly. */
export function validateInputManifest(value: unknown): InputManifest {
  const document = value as Record<string, unknown> | null;
  if (
    document === null ||
    typeof document !== "object" ||
    Array.isArray(document) ||
    Object.keys(document).sort().join(",") !== MANIFEST_KEYS
  ) {
    throw invalid("manifest keys");
  }
  const {
    entries,
    missing_paths: missing,
    source_repositories: sources,
    target_repositories: targets,
    sha256,
  } = document;
  if (
    !Array.isArray(entries) ||
    !Array.isArray(missing) ||
    !Array.isArray(sources) ||
    !Array.isArray(targets) ||
    typeof sha256 !== "string" ||
    !SHA256.test(sha256)
  ) {
    throw invalid("manifest fields");
  }
  const decodedEntries = entries.map((entry: unknown) => decodeEntry(entry));
  const missingPaths = missing.map((path: unknown) =>
    relative(path, "missing path"),
  );
  unique(
    decodedEntries.map((entry) => entry.path),
    "duplicate entry paths",
  );
  unique(missingPaths, "duplicate missing paths");
  // A path cannot be both read and missing in one manifest.
  const listed = new Set(decodedEntries.map((entry) => entry.path));
  if (missingPaths.some((path) => listed.has(path))) {
    throw invalid("missing path also listed as an entry");
  }
  const sourceRefs = sources.map((row: unknown) => decodeRepository(row));
  const targetRefs = targets.map((row: unknown) => decodeRepository(row));
  unique(
    sourceRefs.map((ref) => ref.id),
    "duplicate source repositories",
  );
  unique(
    targetRefs.map((ref) => ref.id),
    "duplicate target repositories",
  );
  return {
    entries: decodedEntries,
    missing_paths: missingPaths,
    source_repositories: sourceRefs,
    target_repositories: targetRefs,
    sha256,
  };
}

/** Digest of the four manifest members in canonical JSON. */
export function inputManifestDigest(
  manifest: Omit<InputManifest, "sha256">,
): string {
  return sha256Hex(
    canonicalJson({
      entries: manifest.entries,
      missing_paths: manifest.missing_paths,
      source_repositories: manifest.source_repositories,
      target_repositories: manifest.target_repositories,
    }),
  );
}

function digestBytes(bytes: Uint8Array): string {
  return createHash("sha256").update(bytes).digest("hex");
}

/** Join a workspace-relative path to the absolute root with forward slashes. */
export function workspacePath(
  workspaceRoot: string,
  relativePath: string,
): string {
  return `${workspaceRoot.replace(/[\\/]+$/u, "")}/${relativePath}`;
}

/**
 * Re-read every input from the workspace and classify every difference.
 *
 * Returns the recomputed manifest (same entry set with freshly computed
 * digests and sizes, digest recomputed) together with the drift list. Callers
 * that need a hard stop use {@link requireFreshInputs}.
 */
export function recomputeInputManifest(options: {
  readonly manifest: InputManifest;
  readonly reader: InputBytesReader;
  readonly workspaceRoot: string;
  readonly profile: { readonly path: string; readonly sha256: string };
}): RecomputedInputs {
  const { manifest, reader, workspaceRoot, profile } = options;
  const drift: InputDrift[] = [];
  const entries: InputManifestEntry[] = [];
  const deletedDigests = new Map<string, string>();
  // Every listed input is re-read; a changed digest or size is an edit, an
  // absent file is a deletion, and evidence edits are named separately.
  for (const entry of manifest.entries) {
    const bytes = reader.readBytes(workspacePath(workspaceRoot, entry.path));
    if (bytes === null) {
      deletedDigests.set(entry.sha256, entry.path);
      drift.push({
        kind: "deleted",
        path: entry.path,
        detail: "input no longer exists",
      });
      continue;
    }
    const digest = digestBytes(bytes);
    if (digest !== entry.sha256 || bytes.byteLength !== entry.size) {
      drift.push({
        kind: entry.category === "evidence" ? "evidence-replaced" : "edited",
        path: entry.path,
        detail: `digest ${entry.sha256} is now ${digest}`,
      });
    }
    entries.push({ ...entry, sha256: digest, size: bytes.byteLength });
  }
  const missing: string[] = [];
  // A path the runtime found absent that now exists was created after the
  // result; when its bytes equal a deleted input it is a rename.
  for (const path of manifest.missing_paths) {
    const bytes = reader.readBytes(workspacePath(workspaceRoot, path));
    if (bytes === null) {
      missing.push(path);
      continue;
    }
    const digest = digestBytes(bytes);
    const previous = deletedDigests.get(digest);
    drift.push(
      previous === undefined
        ? { kind: "appeared", path, detail: "missing input now exists" }
        : { kind: "renamed", path, detail: `moved from ${previous}` },
    );
  }
  // The protected activation binding must be one of the inputs and unchanged.
  const profileEntry = entries.find((entry) => entry.path === profile.path);
  if (profileEntry === undefined || profileEntry.sha256 !== profile.sha256) {
    drift.push({
      kind: "profile-changed",
      path: profile.path,
      detail:
        profileEntry === undefined
          ? "profile was not among the inputs read"
          : `profile digest ${profileEntry.sha256} differs from activation ${profile.sha256}`,
    });
  }
  const recomputed = {
    entries,
    missing_paths: missing,
    source_repositories: manifest.source_repositories,
    target_repositories: manifest.target_repositories,
  };
  return {
    manifest: { ...recomputed, sha256: inputManifestDigest(recomputed) },
    drift,
  };
}

/** Recompute and throw `INPUT_DRIFT` when the workspace moved. */
export function requireFreshInputs(
  options: Parameters<typeof recomputeInputManifest>[0],
): InputManifest {
  const result = recomputeInputManifest(options);
  if (result.drift.length > 0) {
    const summary = result.drift
      .map((item) => `${item.kind}:${item.path}`)
      .join(", ");
    throw new DiscoveryInputManifestError(
      "INPUT_DRIFT",
      `Inputs changed after the runtime result: ${summary}`,
      result.drift,
    );
  }
  return result.manifest;
}

/** `node:fs` subset the Node reader uses; injectable for hermetic tests. */
export interface InputFileSystemModule {
  readFileSync(path: string): Buffer;
}

/** Build the production reader over `node:fs` (or an injected equivalent). */
export function createNodeInputReader(
  fs: InputFileSystemModule = nodeFs,
): InputBytesReader {
  return {
    readBytes(path) {
      try {
        return new Uint8Array(fs.readFileSync(path));
      } catch (error) {
        // Absence and directories read as "no regular file"; other failures surface.
        const code = (error as { code?: unknown }).code;
        if (code === "ENOENT" || code === "EISDIR" || code === "ENOTDIR") {
          return null;
        }
        throw error;
      }
    },
  };
}
