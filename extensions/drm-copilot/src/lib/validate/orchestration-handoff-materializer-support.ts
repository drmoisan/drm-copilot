import { createHash } from "node:crypto";
import * as path from "node:path";

import type { HandoffPathBoundary } from "./orchestration-handoff-path-boundary";

export function sha256(content: Uint8Array): string {
  return createHash("sha256").update(content).digest("hex");
}

function toPosixPath(value: string): string {
  return value.replaceAll("\\", "/");
}

export function resolveWorkspaceFile(
  workspaceRoot: string,
  repositoryPath: string,
): string | null {
  if (
    !path.isAbsolute(workspaceRoot) ||
    repositoryPath.includes("\\") ||
    repositoryPath.startsWith("/") ||
    repositoryPath
      .split("/")
      .some((part) => part === "" || part === "." || part === "..")
  ) {
    return null;
  }
  const root = toPosixPath(path.resolve(workspaceRoot)).replace(/\/+$/, "");
  const candidate = toPosixPath(path.resolve(workspaceRoot, repositoryPath));
  return candidate.startsWith(`${root}/`) ? candidate : null;
}

/** Compatibility boundary for callers that already provide isolated I/O seams. */
export function createSyntacticHandoffPathBoundary(): HandoffPathBoundary {
  const resolveWorkspaceRoot = (workspaceRoot: string): string | null => {
    if (!path.isAbsolute(workspaceRoot)) return null;
    return toPosixPath(path.resolve(workspaceRoot)).replace(/\/+$/, "");
  };
  const resolveTarget = (
    canonicalWorkspaceRoot: string,
    repositoryPath: string,
  ): string | null =>
    resolveWorkspaceFile(canonicalWorkspaceRoot, repositoryPath);
  return {
    resolveWorkspaceRoot,
    resolveExistingTarget: resolveTarget,
    resolveCreatableTarget: resolveTarget,
  };
}

export function candidateFilePath(
  destinationPath: string,
  envelopeSha256: string,
): string {
  const extension = path.posix.extname(destinationPath);
  const stem = destinationPath.slice(
    0,
    destinationPath.length - extension.length,
  );
  return `${stem}.handoff-candidate-${envelopeSha256}${extension}`;
}

export function porcelainAffectedPaths(output: string): readonly string[] {
  const paths = new Set<string>();
  for (const line of output.split(/\r?\n/)) {
    if (line.length < 4) continue;
    const pathField = line.slice(3);
    const renameSeparator = pathField.indexOf(" -> ");
    if (renameSeparator === -1) {
      paths.add(pathField);
      continue;
    }
    paths.add(pathField.slice(0, renameSeparator));
    paths.add(pathField.slice(renameSeparator + 4));
  }
  return [...paths].sort((left, right) => left.localeCompare(right));
}
