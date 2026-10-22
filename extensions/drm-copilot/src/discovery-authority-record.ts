/**
 * Encode and decode the protected activation record shared with Python.
 *
 * The format is byte-identical to `ActivationRecord` in
 * `drm_copilot_discovery.configuration`: eight sorted keys, two-space
 * indentation, ASCII-escaped strings and a trailing newline. Both runtimes
 * replay `tests/fixtures/discovery_authority/authority-vectors.json`, so a
 * drift in either codec fails a test on one side or the other.
 *
 * This module is pure: it performs no I/O and grants no authority. A malformed
 * record is an error, never an inactive state, because a damaged registry must
 * not silently disable gates.
 */

export const ACTIVATION_SCHEMA_VERSION = "2.0.0";
export const ACTIVATION_RECORD_KEYS: ReadonlyArray<string> = [
  "action",
  "generation",
  "locator_sha256",
  "previous_sha256",
  "profile_path",
  "profile_sha256",
  "schema_version",
  "workspace_sha256",
];
const SHA256 = /^[0-9a-f]{64}$/u;
const RELATIVE_PATH =
  /^(?!\/)(?!.*(?:^|\/)\.{1,2}(?:\/|$))[^/\\:\u2028\u2029*?<>|]+(?:\/[^/\\:\u2028\u2029*?<>|]+)*$/u;
const RESERVED_DEVICE =
  /^(?:CON|PRN|AUX|NUL|CONIN\$|CONOUT\$|CLOCK\$|(?:COM|LPT)[1-9\u00b9\u00b2\u00b3])$/u;
/** JSON number literal following the generation key; Python rejects `1.0`. */
const GENERATION_LITERAL = /"generation"\s*:\s*(-?[0-9][0-9.eE+-]*)/gu;
const MAX_RECORD_BYTES = 65536;
const CONTROL_LIMIT = 0x20;

export type ActivationAction = "activate" | "deactivate";

export type DiscoveryAuthorityCode =
  | "ACTIVATION_INVALID"
  | "ACTIVATION_WORKSPACE"
  | "ACTIVATION_CHANGED"
  | "ACTIVATION_INACTIVE"
  | "ACTIVATION_REQUEST_INVALID"
  | "AUTHORITY_CLAIM_REJECTED"
  | "AUTHORITY_LOCKED"
  | "AUTHORITY_IO";

/** Raised for every protected-store contract violation. */
export class DiscoveryAuthorityError extends Error {
  readonly code: DiscoveryAuthorityCode;

  constructor(code: DiscoveryAuthorityCode, message: string) {
    super(message);
    this.name = "DiscoveryAuthorityError";
    this.code = code;
  }
}

/** One protected transition; mirrors the Python dataclass field for field. */
export interface ActivationRecord {
  readonly workspace_sha256: string;
  readonly generation: number;
  readonly action: ActivationAction;
  readonly profile_path: string | null;
  readonly profile_sha256: string | null;
  readonly locator_sha256: string | null;
  readonly previous_sha256: string | null;
  readonly schema_version: "2.0.0";
}

/** True when `text` contains a C0 control character (U+0000 to U+001F). */
function hasControlCharacter(text: string): boolean {
  // Checked by code point so the pattern itself carries no control characters.
  for (const character of text) {
    if (character.codePointAt(0)! < CONTROL_LIMIT) {
      return true;
    }
  }
  return false;
}

/** Validate a workspace-relative POSIX path with the shared schema rules. */
export function assertRelativePath(path: string): string {
  if (!RELATIVE_PATH.test(path) || hasControlCharacter(path)) {
    throw new DiscoveryAuthorityError(
      "ACTIVATION_REQUEST_INVALID",
      `Use a nonempty workspace-relative POSIX path: ${path}`,
    );
  }
  // Windows strips trailing dots/spaces and reserves device stems.
  for (const part of path.split("/")) {
    const stem = part.split(".", 1)[0]!.replace(/ +$/u, "").toUpperCase();
    if (
      part.endsWith(".") ||
      part.endsWith(" ") ||
      part.includes('"') ||
      part.includes("\u007f") ||
      RESERVED_DEVICE.test(stem)
    ) {
      throw new DiscoveryAuthorityError(
        "ACTIVATION_REQUEST_INVALID",
        `Remove reserved or unsafe path segments: ${path}`,
      );
    }
  }
  return path;
}

/** Render the fixed four-key workspace locator (`config/discovery.json`). */
export function renderLocator(profilePath: string): string {
  return encodeSorted({
    enabled: true,
    profile_path: assertRelativePath(profilePath),
    required_runtime_major: 2,
    schema_version: ACTIVATION_SCHEMA_VERSION,
  });
}

/** Escape non-ASCII characters exactly as Python `json.dumps(ensure_ascii=True)`. */
function escapeAscii(json: string): string {
  return json.replace(/[\u007f-\uffff]/gu, (character) => {
    return `\\u${character.charCodeAt(0).toString(16).padStart(4, "0")}`;
  });
}

/** Encode a flat record with sorted keys, two-space indent and a trailing newline. */
function encodeSorted(value: Record<string, unknown>): string {
  const sorted: Record<string, unknown> = {};
  // Python sort_keys orders by code point; the same order is used here.
  for (const key of Object.keys(value).sort()) {
    sorted[key] = value[key];
  }
  return `${escapeAscii(JSON.stringify(sorted, null, 2))}\n`;
}

/** Return deterministic record text identical to `ActivationRecord.encode()`. */
export function encodeActivationRecord(record: ActivationRecord): string {
  return encodeSorted({ ...record });
}

function isDigest(value: unknown): value is string {
  return typeof value === "string" && SHA256.test(value);
}

function invalidRecord(message: string): DiscoveryAuthorityError {
  return new DiscoveryAuthorityError("ACTIVATION_INVALID", message);
}

/** True when every textual `generation` literal is a plain integer. */
function generationLiteralsAreIntegers(text: string): boolean {
  // Each literal must be digits only; `1.0`, `1e0` and `-1` are all rejected.
  for (const match of text.matchAll(GENERATION_LITERAL)) {
    if (!/^[0-9]+$/u.test(match[1]!)) {
      return false;
    }
  }
  return true;
}

/**
 * Parse protected record text, rejecting wrong workspaces and malformed data.
 *
 * Field rules mirror `ActivationRecord.__post_init__`; the workspace digest
 * must equal `options.workspaceSha256` or the record belongs to another
 * workspace (`ACTIVATION_WORKSPACE`). Every other defect is
 * `ACTIVATION_INVALID`.
 */
export function decodeActivationRecord(
  text: string,
  options: { workspaceSha256: string },
): ActivationRecord {
  if (Buffer.byteLength(text, "utf8") > MAX_RECORD_BYTES) {
    throw invalidRecord("Protected activation record exceeds the size limit.");
  }
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw invalidRecord("Protected activation record is not JSON.");
  }
  if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw invalidRecord("Protected activation record is malformed.");
  }
  const value = parsed as Record<string, unknown>;
  const keys = Object.keys(value).sort();
  if (keys.join(",") !== ACTIVATION_RECORD_KEYS.join(",")) {
    throw invalidRecord("Protected activation record is malformed.");
  }
  const {
    action,
    generation,
    profile_path: profilePath,
    schema_version: schemaVersion,
    workspace_sha256: workspaceDigest,
    profile_sha256: profileDigest,
    locator_sha256: locatorDigest,
    previous_sha256: previousDigest,
  } = value;
  // JSON.parse turns `1.0` into an integer, so the textual literal is checked
  // as well to keep parity with Python's exact-int rule.
  if (
    schemaVersion !== ACTIVATION_SCHEMA_VERSION ||
    (action !== "activate" && action !== "deactivate") ||
    typeof generation !== "number" ||
    !Number.isInteger(generation) ||
    generation < 1 ||
    !generationLiteralsAreIntegers(text)
  ) {
    throw invalidRecord("Invalid activation version, action or generation.");
  }
  const digests = [
    workspaceDigest,
    profileDigest,
    locatorDigest,
    previousDigest,
  ];
  if (digests.some((digest) => digest !== null && !isDigest(digest))) {
    throw invalidRecord("Activation digests must be lowercase SHA-256.");
  }
  if (!isDigest(workspaceDigest)) {
    throw invalidRecord("Activation requires a canonical workspace digest.");
  }
  if (profilePath !== null) {
    if (typeof profilePath !== "string") {
      throw invalidRecord("Activation profile path must be a string or null.");
    }
    try {
      assertRelativePath(profilePath);
    } catch {
      throw invalidRecord("Activation profile path is not workspace-relative.");
    }
  }
  // Bindings are all-or-nothing, and activation always carries them.
  const linked = [profilePath, profileDigest, locatorDigest];
  const incomplete = linked.some((entry) => entry === null);
  if (
    incomplete &&
    (action === "activate" || linked.some((entry) => entry !== null))
  ) {
    throw invalidRecord(
      "Activation profile and locator bindings must be complete.",
    );
  }
  if (workspaceDigest !== options.workspaceSha256) {
    throw new DiscoveryAuthorityError(
      "ACTIVATION_WORKSPACE",
      "Protected activation belongs to another workspace.",
    );
  }
  return {
    workspace_sha256: workspaceDigest,
    generation,
    action,
    profile_path: profilePath,
    profile_sha256: profileDigest as string | null,
    locator_sha256: locatorDigest as string | null,
    previous_sha256: previousDigest as string | null,
    schema_version: ACTIVATION_SCHEMA_VERSION,
  };
}
