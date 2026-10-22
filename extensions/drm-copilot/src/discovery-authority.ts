/**
 * Own the protected discovery activation record outside the workspace.
 *
 * Reads never create paths. Writes hold the cooperative `mutation.lock`,
 * compare the original bytes, stage a nonce-named file and publish it in one
 * step. Analyst-supplied destinations, identities and success claims are
 * rejected before any I/O: only the trusted host decides where authority lives
 * and what it says. All I/O flows through {@link AuthorityStoreIO} so the
 * store is testable without a filesystem; the record codec lives in
 * `discovery-authority-record.ts` and the location policy in
 * `discovery-authority-paths.ts`.
 */

import * as nodeFs from "node:fs";

import {
  activationRecordPath,
  type AuthorityLocation,
  mutationLockPath,
  sha256Hex,
} from "./discovery-authority-paths";
import {
  ACTIVATION_SCHEMA_VERSION,
  type ActivationRecord,
  assertRelativePath,
  decodeActivationRecord,
  DiscoveryAuthorityError,
  encodeActivationRecord,
  renderLocator,
} from "./discovery-authority-record";

export {
  ACTIVATION_RECORD_KEYS,
  ACTIVATION_SCHEMA_VERSION,
  assertRelativePath,
  decodeActivationRecord,
  DiscoveryAuthorityError,
  encodeActivationRecord,
  renderLocator,
} from "./discovery-authority-record";
export type {
  ActivationAction,
  ActivationRecord,
  DiscoveryAuthorityCode,
} from "./discovery-authority-record";

export const PROTECTED_CLAIM_KEYS: ReadonlyArray<string> = [
  "activation_sha256",
  "authority_directory",
  "authorization_ref",
  "destination",
  "identity",
  "ok",
  "output_valid",
  "principal",
  "receipt_ref",
  "validation_result",
  "workspace_sha256",
  "writer",
];

/** Workspace binding projected from the protected record for receipts. */
export interface ProtectedWorkspaceBinding {
  readonly workspace_root: string;
  readonly workspace_sha256: string;
  readonly profile_path: string;
  readonly profile_sha256: string;
}

export interface ProtectedEnvelope {
  readonly workspace: ProtectedWorkspaceBinding;
  readonly activation_sha256: string;
  readonly generation: number;
}

/** Narrow I/O seam; the Node adapter and the test fake implement it. */
export interface AuthorityStoreIO {
  /** Return UTF-8 text at `path`, or null when the file does not exist. */
  readText(path: string): string | null;
  /** Create `path` exclusively; a present file is an `AUTHORITY_LOCKED` error. */
  createExclusive(path: string, text: string): void;
  /** Move `stagedPath` onto `targetPath`; without `replace` an existing target fails. */
  publish(stagedPath: string, targetPath: string, replace: boolean): void;
  remove(path: string): void;
  ensureDirectory(path: string): void;
}

/**
 * Reject a payload that carries protected-store claims.
 *
 * Reports, invocation mirrors and requests are analyst-editable. Any field
 * that names a destination, an identity or a validation outcome is ignored by
 * the store and is treated here as an attempt to forge authority.
 */
export function rejectCallerAuthorityClaims(
  payload: unknown,
  context: string,
): void {
  if (payload === null || typeof payload !== "object") {
    return;
  }
  const present = PROTECTED_CLAIM_KEYS.filter((key) =>
    Object.prototype.hasOwnProperty.call(payload, key),
  );
  if (present.length > 0) {
    throw new DiscoveryAuthorityError(
      "AUTHORITY_CLAIM_REJECTED",
      `${context} must not supply protected claims: ${present.join(", ")}`,
    );
  }
}

/** Typed activation input accepted after claim rejection. */
export interface ActivationInput {
  readonly profilePath: string;
  readonly profileText: string;
}

function parseActivationInput(input: unknown): ActivationInput {
  rejectCallerAuthorityClaims(input, "Activation request");
  if (input === null || typeof input !== "object" || Array.isArray(input)) {
    throw new DiscoveryAuthorityError(
      "ACTIVATION_REQUEST_INVALID",
      "Activation requires an object with profilePath and profileText.",
    );
  }
  const value = input as Record<string, unknown>;
  const keys = Object.keys(value).sort().join(",");
  const { profilePath, profileText } = value;
  if (
    keys !== "profilePath,profileText" ||
    typeof profilePath !== "string" ||
    typeof profileText !== "string"
  ) {
    throw new DiscoveryAuthorityError(
      "ACTIVATION_REQUEST_INVALID",
      "Activation accepts exactly profilePath and profileText strings.",
    );
  }
  return { profilePath: assertRelativePath(profilePath), profileText };
}

export interface ActivationStoreOptions {
  readonly location: AuthorityLocation;
  readonly io: AuthorityStoreIO;
  readonly nonce: () => string;
}

type TransitionFields = Omit<
  ActivationRecord,
  "workspace_sha256" | "previous_sha256" | "schema_version"
>;

/** Guarded reader and writer for one workspace's protected record. */
export class ActivationStore {
  private readonly location: AuthorityLocation;
  private readonly io: AuthorityStoreIO;
  private readonly nonce: () => string;
  private held = false;

  constructor(options: ActivationStoreOptions) {
    this.location = options.location;
    this.io = options.io;
    this.nonce = options.nonce;
  }

  /** Raw record text, or null when no record exists. Never creates paths. */
  readRaw(): string | null {
    return this.io.readText(activationRecordPath(this.location));
  }

  /** Decoded record bound to this workspace, or null when absent. */
  read(): ActivationRecord | null {
    const raw = this.readRaw();
    return raw === null
      ? null
      : decodeActivationRecord(raw, {
          workspaceSha256: this.location.workspaceSha256,
        });
  }

  /**
   * Project the active record into the receipt workspace binding.
   *
   * Only the protected record supplies these values; workspace locator or
   * profile deletion does not change them.
   */
  envelope(): ProtectedEnvelope {
    const raw = this.readRaw();
    const record = raw === null ? null : this.read();
    if (
      raw === null ||
      record === null ||
      record.action !== "activate" ||
      record.profile_path === null ||
      record.profile_sha256 === null
    ) {
      throw new DiscoveryAuthorityError(
        "ACTIVATION_INACTIVE",
        "Protected activation is absent or deactivated for this workspace.",
      );
    }
    return {
      workspace: {
        workspace_root: this.location.workspace,
        workspace_sha256: record.workspace_sha256,
        profile_path: record.profile_path,
        profile_sha256: record.profile_sha256,
      },
      activation_sha256: sha256Hex(raw),
      generation: record.generation,
    };
  }

  /** Record activation of `profilePath`, binding exact profile and locator digests. */
  activate(input: unknown): ActivationRecord {
    const request = parseActivationInput(input);
    return this.transition((prior) => ({
      action: "activate",
      profile_path: request.profilePath,
      profile_sha256: sha256Hex(request.profileText),
      locator_sha256: sha256Hex(renderLocator(request.profilePath)),
      generation: prior === null ? 1 : prior.generation + 1,
    }));
  }

  /** Record deliberate deactivation, retaining the prior bindings as a tombstone. */
  deactivate(): ActivationRecord {
    return this.transition((prior) => ({
      action: "deactivate",
      profile_path: prior?.profile_path ?? null,
      profile_sha256: prior?.profile_sha256 ?? null,
      locator_sha256: prior?.locator_sha256 ?? null,
      generation: prior === null ? 1 : prior.generation + 1,
    }));
  }

  private transition(
    build: (prior: ActivationRecord | null) => TransitionFields,
  ): ActivationRecord {
    return this.guarded(() => {
      const raw = this.readRaw();
      const prior = this.read();
      const next: ActivationRecord = {
        ...build(prior),
        workspace_sha256: this.location.workspaceSha256,
        previous_sha256: raw === null ? null : sha256Hex(raw),
        schema_version: ACTIVATION_SCHEMA_VERSION,
      };
      this.write(encodeActivationRecord(next), raw);
      return next;
    });
  }

  /** Hold the cooperative lock for one transition; never steal a present lock. */
  private guarded<T>(action: () => T): T {
    if (this.held) {
      throw new DiscoveryAuthorityError(
        "AUTHORITY_LOCKED",
        "Activation guard is already held.",
      );
    }
    const lock = mutationLockPath(this.location);
    this.io.ensureDirectory(this.location.directory);
    this.io.createExclusive(lock, "");
    this.held = true;
    try {
      return action();
    } finally {
      this.held = false;
      this.io.remove(lock);
    }
  }

  /** Compare original bytes under the lock, then publish exactly one record. */
  private write(content: string, expected: string | null): void {
    if (this.readRaw() !== expected) {
      throw new DiscoveryAuthorityError(
        "ACTIVATION_CHANGED",
        "Protected activation changed before publication.",
      );
    }
    const staged = `${this.location.directory}/.activation-${this.nonce()}`;
    this.io.createExclusive(staged, content);
    try {
      this.io.publish(
        staged,
        activationRecordPath(this.location),
        expected !== null,
      );
    } catch (error) {
      this.io.remove(staged);
      throw error;
    }
  }
}

/** Subset of `node:fs` the Node adapter uses; injectable for hermetic tests. */
export interface AuthorityFileSystemModule {
  readFileSync(path: string, encoding: "utf8"): string;
  writeFileSync(
    path: string,
    data: string,
    options: { encoding: "utf8"; flag: "wx" },
  ): void;
  renameSync(from: string, to: string): void;
  linkSync(from: string, to: string): void;
  unlinkSync(path: string): void;
  mkdirSync(path: string, options: { recursive: true }): string | undefined;
}

function errnoCode(error: unknown): string | undefined {
  if (error !== null && typeof error === "object" && "code" in error) {
    const { code } = error as { code?: unknown };
    return typeof code === "string" ? code : undefined;
  }
  return undefined;
}

function ioError(operation: string, path: string, error: unknown): never {
  const detail = error instanceof Error ? error.message : String(error);
  throw new DiscoveryAuthorityError(
    "AUTHORITY_IO",
    `Protected store ${operation} failed for ${path}: ${detail}`,
  );
}

/** Build the production adapter over `node:fs` (or an injected equivalent). */
export function createNodeAuthorityStoreIO(
  fs: AuthorityFileSystemModule = nodeFs,
): AuthorityStoreIO {
  return {
    readText(path) {
      try {
        return fs.readFileSync(path, "utf8");
      } catch (error) {
        // Absence is the only tolerated failure; anything else is reported.
        if (errnoCode(error) === "ENOENT") {
          return null;
        }
        return ioError("read", path, error);
      }
    },
    createExclusive(path, text) {
      try {
        fs.writeFileSync(path, text, { encoding: "utf8", flag: "wx" });
      } catch (error) {
        if (errnoCode(error) === "EEXIST") {
          throw new DiscoveryAuthorityError(
            "AUTHORITY_LOCKED",
            `Protected store entry already exists: ${path}`,
          );
        }
        ioError("exclusive create", path, error);
      }
    },
    publish(stagedPath, targetPath, replace) {
      try {
        // Replacement renames atomically; first publication links so a racing
        // writer that created the target first is detected instead of clobbered.
        if (replace) {
          fs.renameSync(stagedPath, targetPath);
        } else {
          fs.linkSync(stagedPath, targetPath);
          fs.unlinkSync(stagedPath);
        }
      } catch (error) {
        if (errnoCode(error) === "EEXIST") {
          throw new DiscoveryAuthorityError(
            "ACTIVATION_CHANGED",
            `Protected activation appeared before publication: ${targetPath}`,
          );
        }
        ioError("publish", targetPath, error);
      }
    },
    remove(path) {
      try {
        fs.unlinkSync(path);
      } catch (error) {
        if (errnoCode(error) !== "ENOENT") {
          ioError("remove", path, error);
        }
      }
    },
    ensureDirectory(path) {
      try {
        fs.mkdirSync(path, { recursive: true });
      } catch (error) {
        ioError("directory creation", path, error);
      }
    },
  };
}
