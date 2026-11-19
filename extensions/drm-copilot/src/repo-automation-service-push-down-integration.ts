/**
 * Service wiring of the two push-down integration tools (issue #1051, S48).
 *
 * Purpose:
 *     Check that the workspace root is a directory, then run detect or
 *     validate through a read-only seam (`listFiles`, `isFile`,
 *     `readTextFile`) over the injected push-down file system. The bundled
 *     reference workflows are read through the same seam from the extension
 *     root.
 *
 * Side effects:
 *     Reads only; the seam exposes no write operation.
 */

import {
  type PushDownFileSystem,
  toPosixPath,
} from "./lib/push-down/filesystem-adapter";
import {
  type DetectIntegrationResult,
  detectPushDownIntegration,
} from "./lib/push-down-integration/integration-detect";
import { type IntegrationReadFileSystem } from "./lib/push-down-integration/integration-ecosystems";
import {
  type ValidateIntegrationResult,
  validatePushDownIntegration,
} from "./lib/push-down-integration/integration-validate";
import { type PushDownIntegrationToolInput } from "./mcp-tool-inputs-push-down-integration";

/** Dependencies of the push-down integration service calls. */
export interface PushDownIntegrationServiceDeps {
  /** Push-down file system (in-memory in tests, real in production). */
  readonly fs: Pick<
    PushDownFileSystem,
    "isDir" | "listFiles" | "isFile" | "readTextFile"
  >;
  /** Extension root holding `resources/ci-workflows/`. */
  readonly extensionRoot: string;
}

/**
 * Return the read-only seam over the dependencies' file system.
 *
 * @param deps Service dependencies.
 * @returns An object exposing only the three read operations.
 */
function readOnlySeam(
  deps: PushDownIntegrationServiceDeps,
): IntegrationReadFileSystem {
  return {
    listFiles: (root) => deps.fs.listFiles(root),
    isFile: (path) => deps.fs.isFile(path),
    readTextFile: (path) => deps.fs.readTextFile(path),
  };
}

/**
 * Return the POSIX workspace root after checking it is a directory.
 *
 * @param input Resolved tool input.
 * @param deps Service dependencies.
 * @returns The POSIX root.
 * @throws Error When the root is not a directory.
 */
function directoryRoot(
  input: PushDownIntegrationToolInput,
  deps: PushDownIntegrationServiceDeps,
): string {
  const root = toPosixPath(input.workspaceRoot);
  if (!deps.fs.isDir(root)) {
    throw new Error(
      `workspace_root is not a directory: ${input.workspaceRoot}`,
    );
  }
  return root;
}

/**
 * Detect the integration facts of a destination.
 *
 * @param input Resolved tool input.
 * @param deps Service dependencies.
 * @returns The detect `integration` object.
 * @throws Error When the root is not a directory.
 */
export function detectPushDownIntegrationServiceCall(
  input: PushDownIntegrationToolInput,
  deps: PushDownIntegrationServiceDeps,
): DetectIntegrationResult {
  return detectPushDownIntegration({
    fs: readOnlySeam(deps),
    destinationRoot: directoryRoot(input, deps),
    extensionRoot: toPosixPath(deps.extensionRoot),
  });
}

/**
 * Validate an integrated destination.
 *
 * @param input Resolved tool input.
 * @param deps Service dependencies.
 * @returns The validate `integration` object.
 * @throws Error When the root is not a directory.
 */
export function validatePushDownIntegrationServiceCall(
  input: PushDownIntegrationToolInput,
  deps: PushDownIntegrationServiceDeps,
): ValidateIntegrationResult {
  return validatePushDownIntegration({
    fs: readOnlySeam(deps),
    destinationRoot: directoryRoot(input, deps),
  });
}
