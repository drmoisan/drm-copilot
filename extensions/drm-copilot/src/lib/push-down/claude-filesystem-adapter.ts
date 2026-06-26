/**
 * Filtering filesystem wrapper for the `.claude` customization push-down.
 *
 * Purpose:
 *     Port the `ExcludingFileSystem` of `push_down_claude_filesystem.py`. It
 *     presents a filtered, variant-aware view of the source `.claude` tree to
 *     the shared publisher engine so the engine's destination derivation stays
 *     correct while the published set, per-file source content, and agent-memory
 *     handling all honor the selected packs, C# variant, and memory mode.
 *
 * Responsibilities:
 *     - Exclude host-specific files (for example `settings.local.json`).
 *     - Apply the general-vs-repo agent-memory scope filter.
 *     - Restrict enumeration to the published-pack set when a selection is
 *       active.
 *     - Redirect legacy C# canonical reads to the bundle-only legacy source.
 *     - Apply the memory mode (overwrite / skip / merge).
 *
 * Path model:
 *     All paths are forward-slash POSIX strings. The Python resolved-vs-
 *     unresolved root distinction is replicated by normalizing POSIX strings, so
 *     comparisons stay hermetic and host-independent.
 *
 * Side effects:
 *     Delegates all I/O to the inner adapter.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import { isGeneralMemoryFile, isUnderAgentMemory } from "./claude-memory-scope";
import {
  CSHARP_CANONICAL_PATHS,
  type CSharpVariant,
  type MemoryMode,
  resolveVariantSourcePath,
} from "./claude-pack-selection";

export {
  AGENT_MEMORY_RELATIVE_ROOT,
  GENERAL_MEMORY_SCOPE,
  REPO_MEMORY_SCOPE,
  isGeneralMemoryFile,
  readMemoryScope,
} from "./claude-memory-scope";

/**
 * Normalize a path to forward-slash separators with no trailing slash.
 *
 * @param value Path that may use OS-specific separators.
 * @returns Forward-slash POSIX path without a trailing separator.
 */
function normalizePosix(value: string): string {
  return value.replace(/\\/g, "/").replace(/\/+$/, "");
}

/**
 * Join two POSIX path fragments with a single forward slash.
 *
 * @param root Base POSIX path.
 * @param relative Relative POSIX path.
 * @returns The combined POSIX path.
 */
function joinPosix(root: string, relative: string): string {
  const normalizedRoot = normalizePosix(root);
  const normalizedRelative = relative.replace(/\\/g, "/").replace(/^\/+/, "");
  if (normalizedRoot === "") {
    return normalizedRelative;
  }
  if (normalizedRelative === "") {
    return normalizedRoot;
  }
  return `${normalizedRoot}/${normalizedRelative}`;
}

/**
 * Return the POSIX path relative to a root, or null when not under the root.
 *
 * @param path Candidate child POSIX path.
 * @param root Candidate parent POSIX path.
 * @returns The relative POSIX path, or `null` when not under the root.
 */
function relativeToPosix(path: string, root: string): string | null {
  const normalizedPath = normalizePosix(path);
  const normalizedRoot = normalizePosix(root);
  if (normalizedPath === normalizedRoot) {
    return "";
  }
  const prefix = `${normalizedRoot}/`;
  if (normalizedPath.startsWith(prefix)) {
    return normalizedPath.slice(prefix.length);
  }
  return null;
}

/** Construction options for {@link ExcludingFileSystem}. */
export interface ExcludingFileSystemOptions {
  /** Root the engine enumerates from; defaults to `repoRoot`. */
  readonly sourceRoot?: string;
  /** Destination workspace root, required for the `merge` memory mode. */
  readonly destinationRoot?: string;
  /** The `.claude`-relative paths to publish, or null to publish everything. */
  readonly publishedPaths?: ReadonlySet<string> | null;
  /** Selected C# variant; `legacy` redirects canonical C# reads. */
  readonly csharpVariant?: CSharpVariant;
  /** Memory mode: `overwrite` (default), `merge`, or `skip`. */
  readonly memoryMode?: MemoryMode;
  /** Bundle root that holds the legacy variant subtree; defaults to source. */
  readonly variantRoot?: string;
}

/**
 * Wrap a {@link PushDownFileSystem} with scope, pack, variant, and memory
 * filters.
 *
 * Mirrors the Python `ExcludingFileSystem`. Enumeration drops hard-excluded
 * paths, agent-memory files outside the active scope, files outside the active
 * published set, and agent-memory files excluded by the memory mode. Reads of
 * canonical C# paths are redirected to the legacy source for the legacy
 * variant.
 */
export class ExcludingFileSystem implements PushDownFileSystem {
  private readonly inner: PushDownFileSystem;
  private readonly repoRoot: string;
  private readonly sourceRoot: string;
  private readonly variantRoot: string;
  private readonly destinationRoot: string | undefined;
  private readonly publishedPaths: ReadonlySet<string> | null;
  private readonly csharpVariant: CSharpVariant;
  private readonly memoryMode: MemoryMode;
  private readonly excluded: ReadonlySet<string>;

  /**
   * @param inner The wrapped adapter performing real I/O.
   * @param repoRoot Repository root used to resolve excluded paths and the
   *   agent-memory scope prefix.
   * @param excluded Repo-relative POSIX paths to always exclude.
   * @param options Optional source/destination roots and selection inputs.
   */
  constructor(
    inner: PushDownFileSystem,
    repoRoot: string,
    excluded: ReadonlyArray<string>,
    options: ExcludingFileSystemOptions = {},
  ) {
    this.inner = inner;
    this.repoRoot = normalizePosix(repoRoot);
    // Keep the source root for relative-path comparisons and redirected reads.
    this.sourceRoot = normalizePosix(options.sourceRoot ?? repoRoot);
    // The variant root holds the legacy subtree; legacy reads redirect beneath.
    this.variantRoot = normalizePosix(
      options.variantRoot ?? options.sourceRoot ?? repoRoot,
    );
    this.destinationRoot =
      options.destinationRoot === undefined
        ? undefined
        : normalizePosix(options.destinationRoot);
    this.publishedPaths = options.publishedPaths ?? null;
    this.csharpVariant = options.csharpVariant ?? "modern";
    this.memoryMode = options.memoryMode ?? "overwrite";
    // Resolve excluded paths once for O(1) membership checks.
    this.excluded = new Set(excluded.map((p) => joinPosix(this.repoRoot, p)));
  }

  /**
   * Return the source-relative POSIX path, or null when outside the root.
   *
   * @param path An absolute candidate POSIX path from the inner adapter.
   * @returns The source-relative POSIX path, or `null`.
   */
  private sourceRelativePosix(path: string): string | null {
    return relativeToPosix(path, this.sourceRoot);
  }

  /**
   * Return whether a candidate path is in the active published set.
   *
   * @param path An absolute candidate POSIX path.
   * @returns True when no pack filter is active or the path is published.
   */
  private isPackIncluded(path: string): boolean {
    // A null published set means no selection: every enumerated file is in.
    if (this.publishedPaths === null) {
      return true;
    }
    const relative = this.sourceRelativePosix(path);
    if (relative === null) {
      return true;
    }
    return this.publishedPaths.has(relative);
  }

  /**
   * Return whether a candidate file passes the agent-memory scope filter.
   *
   * Reads file content only for agent-memory candidates.
   *
   * @param path An absolute candidate POSIX path.
   * @returns True when the file is outside the memory subtree or general-scoped.
   */
  private isScopeIncluded(path: string): boolean {
    const relativePath = relativeToPosix(path, this.repoRoot);
    if (relativePath === null) {
      // A path outside the repo root cannot be an agent memory; include it.
      return true;
    }
    // Skip the content read entirely for files outside the memory subtree.
    if (!isUnderAgentMemory(relativePath)) {
      return true;
    }
    const content = this.readText(path);
    return isGeneralMemoryFile(relativePath, content);
  }

  /**
   * Return whether a candidate file passes the memory-mode filter.
   *
   * @param path An absolute candidate POSIX path.
   * @returns True when the file should be published under the active mode.
   */
  private isMemoryModeIncluded(path: string): boolean {
    const relative = this.sourceRelativePosix(path);
    if (relative === null) {
      return true;
    }
    // Only agent-memory files are affected by the memory mode.
    if (!isUnderAgentMemory(relative)) {
      return true;
    }
    // Route by mode: skip drops all memories; merge keeps only those absent at
    // the destination; overwrite (default) keeps everything.
    if (this.memoryMode === "skip") {
      return false;
    }
    if (this.memoryMode === "merge") {
      if (this.destinationRoot === undefined) {
        return true;
      }
      const destinationPath = joinPosix(this.destinationRoot, relative);
      return !this.inner.isFile(destinationPath);
    }
    return true;
  }

  /**
   * Return the actual source path to read for a requested path.
   *
   * Redirects canonical C# reads to the bundle-only legacy source when the
   * legacy variant is active; otherwise passes the path through unchanged.
   *
   * @param path The absolute POSIX path the engine asked to read.
   * @returns The redirected legacy source path, or the original path.
   */
  private resolveReadSource(path: string): string {
    if (this.csharpVariant !== "legacy") {
      return path;
    }
    const relative = this.sourceRelativePosix(path);
    if (relative === null || !CSHARP_CANONICAL_PATHS.includes(relative)) {
      return path;
    }
    const redirectedRelative = resolveVariantSourcePath(relative, "legacy");
    // Join under the variant (bundle) root so the read lives in the same key
    // space the engine enumerated from.
    return joinPosix(this.variantRoot, redirectedRelative);
  }

  listFiles(root: string): string[] {
    // Apply the four enumeration filters in sequence: hard exclusions, pack
    // selection, agent-memory scope, then memory mode.
    return this.inner
      .listFiles(root)
      .filter(
        (p) =>
          !this.excluded.has(normalizePosix(p)) &&
          this.isPackIncluded(p) &&
          this.isScopeIncluded(p) &&
          this.isMemoryModeIncluded(p),
      );
  }

  isDir(path: string): boolean {
    return this.inner.isDir(path);
  }

  isFile(path: string): boolean {
    return this.inner.isFile(path);
  }

  readText(path: string): string {
    return this.inner.readTextFile(this.resolveReadSource(path));
  }

  readTextFile(path: string): string {
    return this.readText(path);
  }

  writeTextFile(path: string, content: string): void {
    this.inner.writeTextFile(path, content);
  }

  ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }
}
