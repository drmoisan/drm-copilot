import * as fs from "node:fs";
import * as path from "node:path";

import { toPosixPath } from "../file-system";

/** Metadata needed to distinguish a creatable descendant from a file child. */
export interface HandoffPathMetadata {
  readonly isDirectory: () => boolean;
}

/** Injectable host filesystem operations used only for canonical path checks. */
export interface HandoffPathFileSystemBoundary {
  readonly realpath: (targetPath: string) => string;
  readonly stat: (targetPath: string) => HandoffPathMetadata;
}

/** Canonical containment checks for contract-controlled repository paths. */
export interface HandoffPathBoundary {
  readonly resolveWorkspaceRoot: (workspaceRoot: string) => string | null;
  readonly resolveExistingTarget: (
    canonicalWorkspaceRoot: string,
    repositoryPath: string,
  ) => string | null;
  readonly resolveCreatableTarget: (
    canonicalWorkspaceRoot: string,
    repositoryPath: string,
  ) => string | null;
}

function normalizedAbsolutePath(targetPath: string): string {
  const resolved = toPosixPath(path.resolve(targetPath));
  return resolved === "/" || /^[A-Za-z]:\/$/.test(resolved)
    ? resolved
    : resolved.replace(/\/+$/, "");
}

function comparisonPath(targetPath: string, caseSensitive: boolean): string {
  const normalized = normalizedAbsolutePath(targetPath);
  return caseSensitive ? normalized : normalized.toLocaleLowerCase("en-US");
}

function isContained(
  canonicalWorkspaceRoot: string,
  candidatePath: string,
  caseSensitive: boolean,
): boolean {
  const root = comparisonPath(canonicalWorkspaceRoot, caseSensitive);
  const candidate = comparisonPath(candidatePath, caseSensitive);
  return candidate === root || candidate.startsWith(`${root}/`);
}

function normalizedRepositorySegments(
  repositoryPath: string,
): readonly string[] | null {
  if (
    repositoryPath.length === 0 ||
    repositoryPath.includes("\\") ||
    repositoryPath.includes(":") ||
    repositoryPath.includes("\0") ||
    path.posix.isAbsolute(repositoryPath) ||
    path.win32.isAbsolute(repositoryPath) ||
    path.posix.normalize(repositoryPath) !== repositoryPath
  ) {
    return null;
  }
  const segments = repositoryPath.split("/");
  return segments.some(
    (segment) => segment.length === 0 || segment === "." || segment === "..",
  )
    ? null
    : segments;
}

function missingPath(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error !== null &&
    "code" in error &&
    error.code === "ENOENT"
  );
}

function lexicalCandidate(
  canonicalWorkspaceRoot: string,
  repositoryPath: string,
  caseSensitive: boolean,
): string | null {
  if (!path.isAbsolute(canonicalWorkspaceRoot)) return null;
  const segments = normalizedRepositorySegments(repositoryPath);
  if (segments === null) return null;
  const candidate = path.resolve(canonicalWorkspaceRoot, ...segments);
  return isContained(canonicalWorkspaceRoot, candidate, caseSensitive)
    ? candidate
    : null;
}

/**
 * Build canonical path checks from an injectable metadata boundary.
 *
 * Existing targets are accepted only after `realpath` resolves every path
 * component. Creatable targets resolve their nearest existing ancestor before
 * appending missing normalized segments, so links and junctions cannot redirect
 * a later caller outside the canonical workspace root.
 */
export function createHandoffPathBoundary(
  fileSystem: HandoffPathFileSystemBoundary,
  caseSensitive = process.platform !== "win32",
): HandoffPathBoundary {
  const resolveWorkspaceRoot = (workspaceRoot: string): string | null => {
    if (!path.isAbsolute(workspaceRoot)) return null;
    try {
      const canonicalRoot = normalizedAbsolutePath(
        fileSystem.realpath(path.resolve(workspaceRoot)),
      );
      return fileSystem.stat(canonicalRoot).isDirectory()
        ? canonicalRoot
        : null;
    } catch {
      return null;
    }
  };

  const resolveExistingTarget = (
    canonicalWorkspaceRoot: string,
    repositoryPath: string,
  ): string | null => {
    const candidate = lexicalCandidate(
      canonicalWorkspaceRoot,
      repositoryPath,
      caseSensitive,
    );
    if (candidate === null) return null;
    try {
      const canonicalTarget = normalizedAbsolutePath(
        fileSystem.realpath(candidate),
      );
      return isContained(canonicalWorkspaceRoot, canonicalTarget, caseSensitive)
        ? canonicalTarget
        : null;
    } catch {
      return null;
    }
  };

  const resolveCreatableTarget = (
    canonicalWorkspaceRoot: string,
    repositoryPath: string,
  ): string | null => {
    const candidate = lexicalCandidate(
      canonicalWorkspaceRoot,
      repositoryPath,
      caseSensitive,
    );
    if (candidate === null) return null;

    let probe = candidate;
    const missingSegments: string[] = [];
    while (isContained(canonicalWorkspaceRoot, probe, caseSensitive)) {
      try {
        const canonicalAncestor = normalizedAbsolutePath(
          fileSystem.realpath(probe),
        );
        if (
          missingSegments.length > 0 &&
          !fileSystem.stat(canonicalAncestor).isDirectory()
        ) {
          return null;
        }
        const canonicalTarget = path.resolve(
          canonicalAncestor,
          ...missingSegments,
        );
        return isContained(
          canonicalWorkspaceRoot,
          canonicalTarget,
          caseSensitive,
        )
          ? normalizedAbsolutePath(canonicalTarget)
          : null;
      } catch (error: unknown) {
        if (!missingPath(error)) return null;
      }

      const parent = path.dirname(probe);
      if (parent === probe) return null;
      missingSegments.unshift(path.basename(probe));
      probe = parent;
    }
    return null;
  };

  return {
    resolveWorkspaceRoot,
    resolveExistingTarget,
    resolveCreatableTarget,
  };
}

/** Build the production boundary from Node's canonical filesystem operations. */
export function createNodeHandoffPathBoundary(): HandoffPathBoundary {
  return createHandoffPathBoundary({
    realpath: (targetPath) => fs.realpathSync.native(targetPath),
    stat: (targetPath) => fs.statSync(targetPath),
  });
}
