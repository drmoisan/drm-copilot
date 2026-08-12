import { type PushDownFileSystem } from "./filesystem-adapter";

/** Exact cross-runtime assets permitted in a Codex publication. */
export const PORTABLE_ASSET_RELATIVE_PATHS: ReadonlyArray<string> = [
  ".claude/lib/bash/compute-cohorts.sh",
  ".claude/lib/bash/compute-concurrency-batches.sh",
  ".claude/lib/bash/parallel-cohorts.sh",
  ".claude/lib/bash/parallel-common.sh",
  ".claude/lib/bash/parallel-items-validate.sh",
  ".claude/lib/bash/parallel-manifest-validate.sh",
  ".claude/lib/bash/parallel-yaml-emit.sh",
  ".claude/lib/bash/parallel-yaml-scan.sh",
  ".claude/lib/bash/validate-parallel-manifest.sh",
  ".claude/lib/blast-radius/BlastRadius.psm1",
  ".claude/lib/blast-radius/BlastRadiusConfig.psm1",
  ".claude/lib/blast-radius/BlastRadiusExtraction.psm1",
  ".claude/lib/blast-radius/BlastRadiusGlob.psm1",
  ".claude/lib/blast-radius/BlastRadiusValidation.psm1",
  "config/blast-radius.json",
];

const PORTABLE_ASSET_PATH_SET: ReadonlySet<string> = new Set(
  PORTABLE_ASSET_RELATIVE_PATHS,
);

function normalizePosix(value: string): string {
  return value.replace(/\\/g, "/").replace(/\/+$/, "");
}

function joinPosix(root: string, relative: string): string {
  const normalizedRoot = normalizePosix(root);
  const normalizedRelative = relative.replace(/\\/g, "/").replace(/^\/+/, "");
  return normalizedRoot === ""
    ? normalizedRelative
    : `${normalizedRoot}/${normalizedRelative}`;
}

function relativeToPosix(path: string, root: string): string | null {
  const normalizedPath = normalizePosix(path);
  const normalizedRoot = normalizePosix(root);
  if (normalizedPath === normalizedRoot) {
    return "";
  }
  const prefix = `${normalizedRoot}/`;
  return normalizedPath.startsWith(prefix)
    ? normalizedPath.slice(prefix.length)
    : null;
}

/**
 * Expose only selected approved portable assets from a generic resource bundle.
 */
export class PortableAssetFileSystem implements PushDownFileSystem {
  private readonly sourceRoot: string;
  private readonly resourceRoot: string;
  private readonly publishedPaths: ReadonlySet<string> | null;

  constructor(
    private readonly inner: PushDownFileSystem,
    options: {
      readonly sourceRoot: string;
      readonly resourceRoot: string;
      readonly publishedPaths: ReadonlySet<string> | null;
    },
  ) {
    this.sourceRoot = normalizePosix(options.sourceRoot);
    this.resourceRoot = normalizePosix(options.resourceRoot);
    this.publishedPaths = options.publishedPaths;
  }

  private sourceRelative(path: string): string | null {
    return relativeToPosix(path, this.sourceRoot);
  }

  private isSelected(relativePath: string): boolean {
    return (
      PORTABLE_ASSET_PATH_SET.has(relativePath) &&
      (this.publishedPaths === null || this.publishedPaths.has(relativePath))
    );
  }

  private resourcePath(path: string): string | null {
    const relativePath = this.sourceRelative(path);
    if (relativePath === null || !this.isSelected(relativePath)) {
      return null;
    }
    const canonicalPath = joinPosix(this.sourceRoot, relativePath);
    if (
      relativePath !== "config/blast-radius.json" &&
      this.inner.isFile(canonicalPath)
    ) {
      return canonicalPath;
    }
    const genericPath = joinPosix(this.resourceRoot, relativePath);
    return this.inner.isFile(genericPath) ? genericPath : null;
  }

  private selectedVirtualPaths(): string[] {
    return PORTABLE_ASSET_RELATIVE_PATHS.filter((relativePath) => {
      const virtualPath = joinPosix(this.sourceRoot, relativePath);
      return (
        this.isSelected(relativePath) && this.resourcePath(virtualPath) !== null
      );
    }).map((relativePath) => joinPosix(this.sourceRoot, relativePath));
  }

  /** Reject unequal portable destinations before any publisher write. */
  validateDestinationCollisions(destinationRoot: string): void {
    const collisions: string[] = [];
    for (const virtualPath of this.selectedVirtualPaths()) {
      const relativePath = this.sourceRelative(virtualPath);
      if (relativePath === null) {
        continue;
      }
      const destinationPath = joinPosix(destinationRoot, relativePath);
      const resourcePath = this.resourcePath(virtualPath);
      if (resourcePath === null) {
        continue;
      }
      if (
        this.inner.isFile(destinationPath) &&
        this.inner.readTextFile(destinationPath) !==
          this.inner.readTextFile(resourcePath)
      ) {
        collisions.push(relativePath);
      }
    }
    if (collisions.length > 0) {
      throw new Error(
        `Portable asset collision(s) detected: ${collisions.join(", ")}`,
      );
    }
  }

  listFiles(root: string): string[] {
    const normalizedRoot = normalizePosix(root);
    const claudeRoot = joinPosix(this.sourceRoot, ".claude");
    const configRoot = joinPosix(this.sourceRoot, "config");
    const selectedPaths = this.selectedVirtualPaths();
    if (normalizedRoot === claudeRoot) {
      return selectedPaths.filter(
        (path) => relativeToPosix(path, claudeRoot) !== null,
      );
    }

    const delegated = this.inner.listFiles(root);
    if (normalizedRoot !== configRoot) {
      return delegated;
    }

    const blastRadiusPath = joinPosix(
      this.sourceRoot,
      "config/blast-radius.json",
    );
    const combined = new Set(
      delegated.filter((path) => normalizePosix(path) !== blastRadiusPath),
    );
    for (const path of selectedPaths) {
      if (relativeToPosix(path, configRoot) !== null) {
        combined.add(path);
      }
    }
    return [...combined].sort();
  }

  isDir(path: string): boolean {
    return this.inner.isDir(path);
  }

  isFile(path: string): boolean {
    const relativePath = this.sourceRelative(path);
    if (relativePath !== null && PORTABLE_ASSET_PATH_SET.has(relativePath)) {
      const resourcePath = this.resourcePath(path);
      return resourcePath !== null && this.inner.isFile(resourcePath);
    }
    return this.inner.isFile(path);
  }

  readTextFile(path: string): string {
    return this.inner.readTextFile(this.resourcePath(path) ?? path);
  }

  writeTextFile(path: string, content: string): void {
    this.inner.writeTextFile(path, content);
  }

  ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }
}
