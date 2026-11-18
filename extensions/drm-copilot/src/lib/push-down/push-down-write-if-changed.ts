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
import { normalizeLineEndings } from "./push-down-destination-manifest";

/** Decorator that skips writes whose LF-normalized text is unchanged. */
export class WriteIfChangedFileSystem implements PushDownFileSystem {
  /** Paths actually written through to the inner adapter, in order. */
  readonly writtenPaths: string[] = [];
  /** Paths whose write was skipped because the text was unchanged, in order. */
  readonly skippedPaths: string[] = [];
  private readonly inner: PushDownFileSystem;

  /**
   * @param inner Adapter that performs the real I/O.
   */
  constructor(inner: PushDownFileSystem) {
    this.inner = inner;
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
    if (
      this.inner.isFile(path) &&
      normalizeLineEndings(this.inner.readTextFile(path)) ===
        normalizeLineEndings(content)
    ) {
      this.skippedPaths.push(path);
      return;
    }
    this.inner.writeTextFile(path, content);
    this.writtenPaths.push(path);
  }
}
