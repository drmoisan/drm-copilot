/**
 * Shared fixtures for the tool-authorization suites.
 *
 * The host vectors, the protected location, the trusted binding, an in-memory
 * `AuthorizationStoreIO` with race hooks, a seeding helper and the request-id
 * consumer driver live here so the request-id and the binding suites exercise
 * one consistent setup.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { DiscoveryAuthorityError } from "../src/discovery-authority";
import {
  type AuthorityLocation,
  resolveAuthorityLocation,
} from "../src/discovery-authority-paths";
import {
  type AuthorizationStoreIO,
  authorizationsDirectory,
  consumeToolAuthorization,
  DiscoveryAuthorizationError,
  type NativeIdentity,
  type ToolAuthorizationRecord,
  type TrustedBinding,
} from "../src/discovery-authorization";

export interface DigestVector {
  readonly name: string;
  readonly tool: string;
  readonly operation: string;
  readonly inputs: Record<string, unknown>;
  readonly input_sha256: string;
}

export interface HostVectors {
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

export const FIXTURE_DIRECTORY = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "discovery_host",
);
export const vectors = JSON.parse(
  fs.readFileSync(
    path.join(FIXTURE_DIRECTORY, "tool-authorizations.json"),
    "utf8",
  ),
) as HostVectors;
export const LOCATION: AuthorityLocation = resolveAuthorityLocation(
  vectors.workspace.workspace_root,
  {
    platform: "windows",
    userHome: "C:/Users/Example",
    localAppData: "C:/Users/Example/AppData/Local",
  },
);
export const TRUSTED: TrustedBinding = {
  workspace: vectors.workspace,
  identity: vectors.identity,
};
export const NOW = new Date("2026-10-22T12:01:00Z");
export const [SORTED, UNSORTED, REORDERED] = vectors.digest_vectors;

/** In-memory store with a listing and race hooks. */
export class MemoryAuthorizationIO implements AuthorizationStoreIO {
  readonly files = new Map<string, string>();
  readonly operations: string[] = [];
  afterCreate: (path: string) => void = () => undefined;
  failPublish = false;

  readText(path: string): string | null {
    return this.files.get(path) ?? null;
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
    this.operations.push(`publish ${targetPath} ${String(replace)}`);
    if (this.failPublish) {
      throw new Error("publish failed");
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
  }

  listEntries(directory: string): string[] {
    const prefix = `${directory}/`;
    return [...this.files.keys()]
      .filter(
        (entry) =>
          entry.startsWith(prefix) && !entry.slice(prefix.length).includes("/"),
      )
      .map((entry) => entry.slice(prefix.length))
      .sort();
  }
}

export const DIRECTORY = authorizationsDirectory(LOCATION, vectors.identity);

/** Seed records under `directory` (the trusted invocation's folder by default). */
export function seeded(
  entries: Record<string, ToolAuthorizationRecord | string> = {
    "authz-alpha.json": vectors.records.issued,
  },
  directory: string = DIRECTORY,
): MemoryAuthorizationIO {
  const io = new MemoryAuthorizationIO();
  // Each entry is stored under the selected invocation's authorizations folder.
  for (const [name, record] of Object.entries(entries)) {
    io.files.set(
      `${directory}/${name}`,
      typeof record === "string" ? record : JSON.stringify(record),
    );
  }
  return io;
}

/** Return the refusal code of one consume attempt, or `ADMITTED`. */
export function refusalCode(action: () => unknown): string {
  try {
    action();
  } catch (error) {
    if (
      error instanceof DiscoveryAuthorizationError ||
      error instanceof DiscoveryAuthorityError
    ) {
      return error.code;
    }
    throw error;
  }
  return "ADMITTED";
}

export function attempt(
  io: MemoryAuthorizationIO,
  overrides: {
    requestId?: string;
    tool?: string;
    operation?: string;
    inputs?: unknown;
    trusted?: TrustedBinding;
    now?: Date;
  } = {},
): string {
  return refusalCode(() =>
    consumeToolAuthorization({
      location: LOCATION,
      io,
      request: {
        requestId: overrides.requestId ?? "request-alpha",
        tool: overrides.tool ?? UNSORTED!.tool,
        operation: overrides.operation ?? UNSORTED!.operation,
        inputs: overrides.inputs ?? UNSORTED!.inputs,
      },
      trusted: overrides.trusted ?? TRUSTED,
      now: overrides.now ?? NOW,
    }),
  );
}
