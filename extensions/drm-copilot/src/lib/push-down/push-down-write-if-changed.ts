/**
 * Write-if-changed filesystem decorator of the push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Sit directly above the destination adapter so a write whose text equals
 *     the current destination text (after LF normalization) is skipped. Merged
 *     paths, merged deliveries, and the destination manifest therefore change a
 *     destination only when their text changes, which makes a second apply run
 *     a no-op.
 *
 * Side effects:
 *     Delegates every call to the inner adapter; records written and skipped
 *     paths in memory.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import { stringifySorted } from "./copilot-customizations-engine";
import { normalizeLineEndings } from "./push-down-destination-manifest";

/** Options of {@link WriteIfChangedFileSystem}. */
export interface WriteIfChangedOptions {
  /**
   * Absolute paths of merged JSON documents. A write to one of them is also
   * skipped when the current and new texts parse to the same JSON value, so a
   * merge that changes nothing writes nothing even when its serialization
   * differs from the destination's formatting.
   */
  readonly jsonEquivalentPaths?: ReadonlyArray<string>;
}

/**
 * Return whether two texts parse to the same JSON value.
 *
 * @param left First text.
 * @param right Second text.
 * @returns True when both parse and their sorted-key forms are equal.
 */
function isSameJson(left: string, right: string): boolean {
  try {
    return (
      stringifySorted(JSON.parse(left), 0) ===
      stringifySorted(JSON.parse(right), 0)
    );
  } catch {
    return false;
  }
}

/**
 * Resolve destination-relative merged paths to the absolute paths the pipeline
 * writes.
 *
 * @param destinationRoot Destination workspace root.
 * @param relativePaths Destination-relative merged paths.
 * @returns The absolute POSIX paths.
 */
export function mergedDestinationPaths(
  destinationRoot: string,
  relativePaths: ReadonlyArray<string>,
): string[] {
  const root = destinationRoot.replace(/\\/g, "/").replace(/\/+$/, "");
  return relativePaths.map((relative) => `${root}/${relative}`);
}

/** Decorator that skips writes whose LF-normalized text is unchanged. */
export class WriteIfChangedFileSystem implements PushDownFileSystem {
  /** Paths actually written through to the inner adapter, in order. */
  readonly writtenPaths: string[] = [];
  /** Paths whose write was skipped because the text was unchanged, in order. */
  readonly skippedPaths: string[] = [];
  private readonly inner: PushDownFileSystem;
  private readonly jsonEquivalentPaths: ReadonlySet<string>;

  /**
   * @param inner Adapter that performs the real I/O.
   * @param options Paths compared as JSON values.
   */
  constructor(inner: PushDownFileSystem, options: WriteIfChangedOptions = {}) {
    this.inner = inner;
    this.jsonEquivalentPaths = new Set(options.jsonEquivalentPaths ?? []);
  }

  listFiles(root: string): string[] {
    return this.inner.listFiles(root);
  }

  isDir(path: string): boolean {
    return this.inner.isDir(path);
  }

  isFile(path: string): boolean {
    return this.inner.isFile(path);
  }

  readTextFile(path: string): string {
    return this.inner.readTextFile(path);
  }

  ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }

  /**
   * Write `content` unless the current file holds the same LF-normalized text.
   *
   * @param path Target path.
   * @param content Text to write.
   */
  writeTextFile(path: string, content: string): void {
    if (this.inner.isFile(path)) {
      const current = this.inner.readTextFile(path);
      const unchanged =
        normalizeLineEndings(current) === normalizeLineEndings(content) ||
        (this.jsonEquivalentPaths.has(path) && isSameJson(current, content));
      if (unchanged) {
        this.skippedPaths.push(path);
        return;
      }
    }
    this.inner.writeTextFile(path, content);
    this.writtenPaths.push(path);
  }
}
