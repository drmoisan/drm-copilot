import type { FileSystem } from "./lib/file-system";
import { toPosixPath } from "./lib/file-system";

/**
 * Default workspace-relative location of the persisted PoshQC scan configuration.
 *
 * This is the single source of the test-scan folder set shared by the local
 * task, the extension command, and the MCP tool through the PoshQC module. The
 * TypeScript reader/writer here and the PowerShell `Get-PoshQCScanConfigFolder`
 * function enforce identical validation rules against this same file.
 */
export const SCAN_CONFIG_RELATIVE_PATH = "config/poshqc-scan.json";

/**
 * Schema version required by the scan configuration file. Any other value is a
 * fail-fast validation error, providing a forward-compatibility gate.
 */
const REQUIRED_CONFIG_VERSION = 1;

/**
 * Detects absolute paths in a portable way (POSIX root, Windows drive-rooted,
 * and UNC paths). Scan-folder entries must be workspace-relative, so any match
 * is a validation error.
 */
const ABSOLUTE_PATH_PATTERN = /^(?:[a-zA-Z]:[\\/]|[\\/])/;

/**
 * Resolve the absolute (POSIX-separated) path to the scan configuration file.
 *
 * @param workspaceRoot Workspace root the configuration path resolves against.
 * @param configRelativePath Workspace-relative configuration path.
 * @returns The joined configuration path using forward-slash separators.
 */
export function resolveScanConfigPath(
  workspaceRoot: string,
  configRelativePath: string = SCAN_CONFIG_RELATIVE_PATH,
): string {
  const normalizedRoot = toPosixPath(workspaceRoot).replace(/\/+$/, "");
  const normalizedRelative = toPosixPath(configRelativePath).replace(
    /^\/+/,
    "",
  );
  if (normalizedRoot === "") {
    return normalizedRelative;
  }
  return `${normalizedRoot}/${normalizedRelative}`;
}

/**
 * Normalize a folder entry to its canonical, workspace-relative, forward-slash
 * form: backslashes become forward slashes, any leading `./` is dropped, and
 * trailing slashes are removed. Normalization never alters `..` segments, so it
 * cannot mask a traversal that validation must reject.
 *
 * @param folder Raw folder entry.
 * @returns The canonicalized folder entry.
 */
function normalizeFolder(folder: string): string {
  return toPosixPath(folder).replace(/^\.\//, "").replace(/\/+$/, "");
}

/**
 * Validate a single scan-folder entry against the shared contract, throwing a
 * fail-fast error that names the configuration file on any violation.
 *
 * @param folder Candidate entry (already known to be present in the array).
 * @param configRelativePath Configuration path used in error messages.
 * @throws Error When the entry is blank, absolute, or contains a `..` segment.
 */
function assertValidFolderEntry(
  folder: unknown,
  configRelativePath: string,
): asserts folder is string {
  if (typeof folder !== "string" || folder.trim() === "") {
    throw new Error(
      `Scan configuration '${configRelativePath}' contains a blank 'test.scanFolders' entry.`,
    );
  }
  if (ABSOLUTE_PATH_PATTERN.test(folder)) {
    throw new Error(
      `Scan configuration '${configRelativePath}' entry '${folder}' must be a workspace-relative path, not an absolute path.`,
    );
  }
  // Reject parent-directory traversal in any path segment.
  const segments = folder.split(/[\\/]+/);
  if (segments.includes("..")) {
    throw new Error(
      `Scan configuration '${configRelativePath}' entry '${folder}' must not contain '..' segments.`,
    );
  }
}

/**
 * Shape of the parsed configuration document. Only the fields consumed by the
 * reader are modeled; unknown fields are ignored.
 */
interface ParsedScanConfig {
  version?: unknown;
  test?: { scanFolders?: unknown } | null;
}

/**
 * Read and validate the persisted scan-folder set from the configuration file.
 *
 * Returns an empty array when the file is absent or when `test.scanFolders` is
 * absent or empty, so that an absent configuration preserves the downstream
 * `Run.Path` defaults. Validation is fail-fast and names the file: malformed
 * JSON, a `version` other than 1, blank entries, absolute-path entries, and
 * entries containing `..` segments are errors. Returned entries are
 * canonicalized (forward-slash, deduplicated, sorted).
 *
 * @param fileSystem Injected filesystem seam (in-memory fake in tests).
 * @param workspaceRoot Workspace root the configuration path resolves against.
 * @param configRelativePath Workspace-relative configuration path.
 * @returns The validated, canonical scan-folder list, or an empty array.
 * @throws Error On malformed JSON or any entry-level validation failure.
 */
export function readPoshQcScanFolders(
  fileSystem: FileSystem,
  workspaceRoot: string,
  configRelativePath: string = SCAN_CONFIG_RELATIVE_PATH,
): string[] {
  const configPath = resolveScanConfigPath(workspaceRoot, configRelativePath);

  // Absent configuration file means defaults apply (empty result, no error).
  if (!fileSystem.isFile(configPath)) {
    return [];
  }

  const raw = fileSystem.readTextFile(configPath);
  // Absent or whitespace-only content is treated the same as an absent file.
  if (raw.trim() === "") {
    return [];
  }

  let parsed: ParsedScanConfig;
  try {
    parsed = JSON.parse(raw) as ParsedScanConfig;
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new Error(
      `Invalid JSON in scan configuration '${configRelativePath}': ${detail}`,
      { cause: error },
    );
  }

  if (parsed.version !== REQUIRED_CONFIG_VERSION) {
    throw new Error(
      `Scan configuration '${configRelativePath}' must declare 'version' equal to 1.`,
    );
  }

  // Absent 'test' section, or absent/empty 'test.scanFolders', means defaults apply.
  const scanFolders = parsed.test?.scanFolders;
  if (scanFolders === undefined || scanFolders === null) {
    return [];
  }
  if (!Array.isArray(scanFolders)) {
    throw new Error(
      `Scan configuration '${configRelativePath}' 'test.scanFolders' must be an array of workspace-relative folder paths.`,
    );
  }
  if (scanFolders.length === 0) {
    return [];
  }

  // Validate every entry before canonicalizing so error messages reference the
  // author's original text.
  for (const folder of scanFolders) {
    assertValidFolderEntry(folder, configRelativePath);
  }

  return canonicalizeFolders(scanFolders as string[]);
}

/**
 * Canonicalize a folder list: normalize each entry, drop blanks produced by
 * normalization, deduplicate, and sort for stable diffs.
 *
 * @param folders Raw folder entries (already validated when read from config).
 * @returns The canonical folder list.
 */
export function canonicalizeFolders(folders: readonly string[]): string[] {
  const normalized = folders
    .map((folder) => normalizeFolder(folder))
    .filter((folder) => folder !== "");
  const unique = Array.from(new Set(normalized));
  unique.sort((left, right) => left.localeCompare(right));
  return unique;
}

/**
 * Write the scan-folder selection to the configuration file in canonical form.
 *
 * The written document uses `version: 1`, canonical folder entries
 * (workspace-relative forward-slash paths, deduplicated, sorted), two-space
 * indentation, and a trailing newline, so a read-after-write round-trip is
 * byte-stable. The parent directory is created when missing.
 *
 * @param fileSystem Injected filesystem seam.
 * @param workspaceRoot Workspace root the configuration path resolves against.
 * @param folders Selected folders (any separator style; canonicalized here).
 * @param configRelativePath Workspace-relative configuration path.
 */
export function writePoshQcScanFolders(
  fileSystem: FileSystem,
  workspaceRoot: string,
  folders: readonly string[],
  configRelativePath: string = SCAN_CONFIG_RELATIVE_PATH,
): void {
  const configPath = resolveScanConfigPath(workspaceRoot, configRelativePath);
  const canonicalFolders = canonicalizeFolders(folders);

  const document = {
    version: REQUIRED_CONFIG_VERSION,
    test: {
      scanFolders: canonicalFolders,
    },
  };
  const content = `${JSON.stringify(document, null, 2)}\n`;

  // Ensure the parent directory exists before writing the file.
  const lastSlash = configPath.lastIndexOf("/");
  if (lastSlash > 0) {
    fileSystem.ensureDir(configPath.slice(0, lastSlash));
  }
  fileSystem.writeTextFile(configPath, content);
}
