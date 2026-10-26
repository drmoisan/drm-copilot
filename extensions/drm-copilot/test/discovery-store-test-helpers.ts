import { createHash } from "node:crypto";

import {
  type AuthorityStoreIO,
  DiscoveryAuthorityError,
} from "../src/discovery-authority";
import type { InputBytesReader } from "../src/discovery-input-manifest";

/**
 * In-memory `AuthorityStoreIO` shared by the discovery invocation suites.
 *
 * Records every operation so tests can prove which protected paths a flow
 * touched, and exposes a post-create hook for race simulations.
 */
export class MemoryStoreIO implements AuthorityStoreIO {
  readonly files = new Map<string, string>();
  readonly directories = new Set<string>();
  readonly operations: string[] = [];
  afterCreate: (path: string) => void = () => undefined;
  failPublish = false;

  readText(path: string): string | null {
    this.operations.push(`read ${path}`);
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
    this.directories.add(path);
  }

  /** Immediate entry names under `directory`, sorted; `[]` when none exist. */
  listEntries(directory: string): string[] {
    this.operations.push(`list ${directory}`);
    const prefix = `${directory}/`;
    return [...this.files.keys()]
      .filter(
        (entry) =>
          entry.startsWith(prefix) && !entry.slice(prefix.length).includes("/"),
      )
      .map((entry) => entry.slice(prefix.length))
      .sort();
  }

  /** Paths of every write-type operation recorded so far. */
  writtenPaths(): string[] {
    return this.operations
      .filter((entry) => !entry.startsWith("read "))
      .map((entry) => entry.split(" ")[1]!);
  }
}

/** In-memory workspace byte reader keyed by absolute forward-slash path. */
export class MemoryInputReader implements InputBytesReader {
  readonly files = new Map<string, Uint8Array>();
  readonly reads: string[] = [];

  /** Store UTF-8 text at `path`. */
  write(path: string, text: string): void {
    this.files.set(path, new TextEncoder().encode(text));
  }

  readBytes(path: string): Uint8Array | null {
    this.reads.push(path);
    return this.files.get(path) ?? null;
  }
}

/** Lowercase hex SHA-256 of UTF-8 `text`, for expected digests in tests. */
export function digestOf(text: string): string {
  return createHash("sha256").update(text, "utf8").digest("hex");
}
