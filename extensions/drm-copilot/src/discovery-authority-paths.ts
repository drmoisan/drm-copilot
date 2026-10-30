/**
 * Resolve the protected discovery authority location from trusted host values.
 *
 * The native host (extension or standalone MCP server) resolves the workspace
 * root and the platform user-state directory before any request is read. This
 * module turns those trusted values into the fixed external registry layout
 * shared with the Python runtime (`RegistryLocation.for_host`):
 *
 *     <user-state>/drm-copilot/discovery/workspaces/<sha256(canonical workspace)>
 *
 * Session and invocation partitions live under that workspace directory. No
 * request field, profile, locator or analyst-authored artifact can redirect the
 * location, and nothing here touches the filesystem; the resolved paths are
 * values that the store module reads and writes through injected adapters.
 */

import { createHash } from "node:crypto";

export type AuthorityPlatform = "windows" | "macos" | "linux";

export const AUTHORITY_ROOT_SEGMENT = "drm-copilot/discovery";
export const ACTIVATION_RECORD_FILE = "activation.json";
export const MUTATION_LOCK_FILE = "mutation.lock";
export const SESSION_PARTITION = "sessions";
export const INVOCATION_PARTITION = "invocations";

/** Correlation identifiers accepted by the v2 schemas (`correlation-id`). */
const CORRELATION_ID = /^[A-Za-z0-9][A-Za-z0-9._:-]*$/u;
const WINDOWS_DRIVE_ROOT = /^[A-Za-z]:[\\/]/u;
const WINDOWS_UNC_ROOT = /^[\\/]{2}[^\\/]+[\\/][^\\/]+/u;

export type DiscoveryAuthorityPathCode =
  | "AUTHORITY_PLATFORM_UNSUPPORTED"
  | "AUTHORITY_STATE_ROOT_MISSING"
  | "AUTHORITY_PATH_NOT_CANONICAL"
  | "AUTHORITY_INSIDE_WORKSPACE"
  | "AUTHORITY_PARTITION_INVALID"
  | "AUTHORITY_DESTINATION_REJECTED";

/** Raised when trusted host values cannot describe a protected location. */
export class DiscoveryAuthorityPathError extends Error {
  readonly code: DiscoveryAuthorityPathCode;

  constructor(code: DiscoveryAuthorityPathCode, message: string) {
    super(message);
    this.name = "DiscoveryAuthorityPathError";
    this.code = code;
  }
}

/** Host-resolved values; never taken from a request or a workspace file. */
export interface TrustedHostEnvironment {
  readonly platform: AuthorityPlatform;
  readonly userHome: string;
  readonly localAppData?: string | null;
  readonly xdgStateHome?: string | null;
}

/** Fixed external storage layout for one workspace. */
export interface AuthorityLocation {
  readonly platform: AuthorityPlatform;
  /** Workspace root in POSIX spelling, case preserved as supplied. */
  readonly workspace: string;
  /** Digest of the canonical workspace identity (lowercase on Windows). */
  readonly workspaceSha256: string;
  /** `<user-state>/drm-copilot/discovery` in POSIX spelling. */
  readonly root: string;
  /** `<root>/workspaces/<workspaceSha256>` in POSIX spelling. */
  readonly directory: string;
}

interface CanonicalPath {
  readonly platform: AuthorityPlatform;
  readonly anchor: string;
  readonly parts: ReadonlyArray<string>;
}

/** Return the lowercase hex SHA-256 of UTF-8 `text`. */
export function sha256Hex(text: string): string {
  return createHash("sha256").update(text, "utf8").digest("hex");
}

function isAbsolute(raw: string, platform: AuthorityPlatform): boolean {
  if (platform === "windows") {
    return WINDOWS_DRIVE_ROOT.test(raw) || WINDOWS_UNC_ROOT.test(raw);
  }
  return raw.startsWith("/");
}

/**
 * Split a trusted absolute path the way `pathlib` does: separators collapse,
 * `.` segments vanish, trailing separators are dropped and `..` is rejected
 * because an unresolved alias cannot identify a workspace.
 */
function canonicalize(
  raw: string,
  platform: AuthorityPlatform,
  label: string,
): CanonicalPath {
  if (!isAbsolute(raw, platform)) {
    throw new DiscoveryAuthorityPathError(
      "AUTHORITY_PATH_NOT_CANONICAL",
      `${label} must be an absolute path: ${raw}`,
    );
  }
  const unified = platform === "windows" ? raw.replace(/\\/gu, "/") : raw;
  let anchor: string;
  let rest: string;
  if (platform === "windows" && WINDOWS_DRIVE_ROOT.test(raw)) {
    anchor = `${unified.slice(0, 2)}/`;
    rest = unified.slice(3);
  } else if (platform === "windows") {
    const match = /^\/\/([^/]+)\/([^/]+)\/?/u.exec(unified);
    anchor = `//${match![1]!}/${match![2]!}/`;
    rest = unified.slice(match![0].length);
  } else {
    // POSIX keeps exactly two leading slashes as a distinct root (pathlib does).
    anchor = /^\/\/(?!\/)/u.test(unified) ? "//" : "/";
    rest = unified.replace(/^\/+/u, "");
  }
  const parts: string[] = [];
  // Drop empty and current-directory segments; reject parent references.
  for (const segment of rest.split("/")) {
    if (segment === "" || segment === ".") {
      continue;
    }
    if (segment === "..") {
      throw new DiscoveryAuthorityPathError(
        "AUTHORITY_PATH_NOT_CANONICAL",
        `${label} must not contain parent references: ${raw}`,
      );
    }
    parts.push(segment);
  }
  return { platform, anchor, parts };
}

/** Render a canonical path in POSIX spelling (what `PurePath.as_posix` prints). */
function toPosix(path: CanonicalPath): string {
  const joined = path.parts.join("/");
  if (joined === "") {
    return path.anchor;
  }
  return `${path.anchor}${joined}`;
}

/** Render the identity string hashed for the workspace partition. */
function identityString(path: CanonicalPath): string {
  // Windows identity uses native separators and invariant lowercase, matching
  // the existing native authority store; POSIX preserves case.
  if (path.platform === "windows") {
    const native = toPosix(path).replace(/\//gu, "\\");
    return native.toLowerCase();
  }
  return toPosix(path);
}

function comparable(segment: string, platform: AuthorityPlatform): string {
  return platform === "windows" ? segment.toLowerCase() : segment;
}

/** True when `candidate` equals or descends from `ancestor`. */
function isWithin(candidate: CanonicalPath, ancestor: CanonicalPath): boolean {
  if (
    comparable(candidate.anchor, candidate.platform) !==
      comparable(ancestor.anchor, ancestor.platform) ||
    candidate.parts.length < ancestor.parts.length
  ) {
    return false;
  }
  // Every ancestor segment must match the candidate prefix segment-wise.
  for (let index = 0; index < ancestor.parts.length; index += 1) {
    if (
      comparable(candidate.parts[index]!, candidate.platform) !==
      comparable(ancestor.parts[index]!, ancestor.platform)
    ) {
      return false;
    }
  }
  return true;
}

/** Resolve the platform user-state base from fixed policy, never from input. */
function stateBase(
  environment: TrustedHostEnvironment,
  home: CanonicalPath,
): CanonicalPath {
  const { platform } = environment;
  // Platform state locations are fixed policy; profiles cannot redirect them.
  if (platform === "windows") {
    if (!environment.localAppData) {
      throw new DiscoveryAuthorityPathError(
        "AUTHORITY_STATE_ROOT_MISSING",
        "Trusted LocalApplicationData is required on Windows.",
      );
    }
    return canonicalize(
      environment.localAppData,
      platform,
      "LocalApplicationData",
    );
  }
  if (platform === "macos") {
    return {
      platform,
      anchor: home.anchor,
      parts: [...home.parts, "Library", "Application Support"],
    };
  }
  if (platform === "linux") {
    if (environment.xdgStateHome) {
      return canonicalize(environment.xdgStateHome, platform, "XDG_STATE_HOME");
    }
    return {
      platform,
      anchor: home.anchor,
      parts: [...home.parts, ".local", "state"],
    };
  }
  throw new DiscoveryAuthorityPathError(
    "AUTHORITY_PLATFORM_UNSUPPORTED",
    `Unsupported activation registry platform: ${String(platform)}`,
  );
}

/**
 * Resolve the protected authority location for `workspaceRoot`.
 *
 * Mirrors `RegistryLocation.for_host`: the workspace, home and state roots must
 * be absolute without parent references, and the authority root must lie
 * outside the workspace. No directories are created.
 */
export function resolveAuthorityLocation(
  workspaceRoot: string,
  environment: TrustedHostEnvironment,
): AuthorityLocation {
  const { platform } = environment;
  if (platform !== "windows" && platform !== "macos" && platform !== "linux") {
    throw new DiscoveryAuthorityPathError(
      "AUTHORITY_PLATFORM_UNSUPPORTED",
      `Unsupported activation registry platform: ${String(platform)}`,
    );
  }
  const workspace = canonicalize(workspaceRoot, platform, "Workspace root");
  const home = canonicalize(environment.userHome, platform, "User home");
  const base = stateBase(environment, home);
  const root: CanonicalPath = {
    platform,
    anchor: base.anchor,
    parts: [...base.parts, "drm-copilot", "discovery"],
  };
  if (isWithin(root, workspace)) {
    throw new DiscoveryAuthorityPathError(
      "AUTHORITY_INSIDE_WORKSPACE",
      "Activation authority must remain outside the workspace.",
    );
  }
  const workspaceSha256 = sha256Hex(identityString(workspace));
  const directory: CanonicalPath = {
    platform,
    anchor: root.anchor,
    parts: [...root.parts, "workspaces", workspaceSha256],
  };
  return {
    platform,
    workspace: toPosix(workspace),
    workspaceSha256,
    root: toPosix(root),
    directory: toPosix(directory),
  };
}

/**
 * Return the filesystem-safe partition name for a correlation identifier.
 *
 * Correlation identifiers may contain `:` and are case-sensitive, so the
 * partition is the digest of the identifier rather than the identifier itself.
 */
export function partitionName(correlationId: string): string {
  if (!CORRELATION_ID.test(correlationId) || correlationId.length > 256) {
    throw new DiscoveryAuthorityPathError(
      "AUTHORITY_PARTITION_INVALID",
      `Partition identifier is not a valid correlation id: ${correlationId}`,
    );
  }
  return sha256Hex(correlationId);
}

/** `<directory>/sessions/<sha256(sessionId)>`. */
export function sessionDirectory(
  location: AuthorityLocation,
  sessionId: string,
): string {
  return `${location.directory}/${SESSION_PARTITION}/${partitionName(sessionId)}`;
}

/** `<session>/invocations/<sha256(invocationId)>`. */
export function invocationDirectory(
  location: AuthorityLocation,
  sessionId: string,
  invocationId: string,
): string {
  const session = sessionDirectory(location, sessionId);
  return `${session}/${INVOCATION_PARTITION}/${partitionName(invocationId)}`;
}

/** Path of the fixed activation record. */
export function activationRecordPath(location: AuthorityLocation): string {
  return `${location.directory}/${ACTIVATION_RECORD_FILE}`;
}

/** Path of the cooperative mutation lock. */
export function mutationLockPath(location: AuthorityLocation): string {
  return `${location.directory}/${MUTATION_LOCK_FILE}`;
}

/** True when `candidate` lies inside the workspace of `location`. */
export function isInsideWorkspace(
  location: AuthorityLocation,
  candidate: string,
): boolean {
  const target = canonicalize(candidate, location.platform, "Candidate path");
  const workspace = canonicalize(
    location.workspace,
    location.platform,
    "Workspace root",
  );
  return isWithin(target, workspace);
}

/** True when `candidate` lies inside the protected directory of `location`. */
export function isInsideAuthority(
  location: AuthorityLocation,
  candidate: string,
): boolean {
  const target = canonicalize(candidate, location.platform, "Candidate path");
  const directory = canonicalize(
    location.directory,
    location.platform,
    "Authority directory",
  );
  return isWithin(target, directory);
}

/**
 * Reject any destination that is not contained in the protected directory.
 *
 * Analyst-authored reports, invocation mirrors and workspace copies of the
 * registry are editable; a write that lands anywhere other than the protected
 * directory can never become native authority.
 */
export function assertProtectedDestination(
  location: AuthorityLocation,
  destination: string,
): string {
  const target = canonicalize(destination, location.platform, "Destination");
  const rendered = toPosix(target);
  if (isInsideWorkspace(location, rendered)) {
    throw new DiscoveryAuthorityPathError(
      "AUTHORITY_DESTINATION_REJECTED",
      `Destination lies inside the editable workspace: ${rendered}`,
    );
  }
  if (!isInsideAuthority(location, rendered)) {
    throw new DiscoveryAuthorityPathError(
      "AUTHORITY_DESTINATION_REJECTED",
      `Destination lies outside the protected authority directory: ${rendered}`,
    );
  }
  return rendered;
}
