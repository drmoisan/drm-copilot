"use strict";
/**
 * Core models and basic utilities for active feature folder creation.
 *
 * Purpose:
 *     Direct TypeScript port of the bundled
 *     `dev_tools/new_active_feature_folder_models.py`. Holds the constants,
 *     value types, the port-local filesystem seam, and the small pure helpers
 *     (`resolveWorkspace`, `getEstTimestamp`, `extractDateFromTimestamp`,
 *     `validateFeatureName`) consumed by the rest of the cluster.
 *
 * Parity:
 *     Constants, regexes, formats, and error messages are byte-identical to the
 *     Python source. Paths are forward-slash POSIX strings (not `Path` objects),
 *     consistent with the F1 `file-system.ts` and the F6/F7 ports.
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.RealFolderFileSystem = exports.PLAN_TIMESTAMP_TEMPLATE_NAME = exports.PLACEHOLDERS = exports.EXCLUDED_POTENTIAL_NAMES = exports.NAME_PATTERN = void 0;
exports.joinPosix = joinPosix;
exports.resolveWorkspace = resolveWorkspace;
exports.getEstTimestamp = getEstTimestamp;
exports.extractDateFromTimestamp = extractDateFromTimestamp;
exports.validateFeatureName = validateFeatureName;
const nodeFs = __importStar(require("node:fs"));
const nodePath = __importStar(require("node:path"));
const file_system_1 = require("../file-system");
/**
 * Slug validation pattern (anchored full-match) for feature/folder names.
 *
 * Mirrors Python `re.compile(r"^[a-z0-9]+(?:[-_][a-z0-9]+)*$")` used with
 * `fullmatch`. The `^...$` anchors give full-match semantics under
 * `RegExp.test`.
 */
exports.NAME_PATTERN = /^[a-z0-9]+(?:[-_][a-z0-9]+)*$/;
/** Potential-file names excluded from feature-name matching. */
exports.EXCLUDED_POTENTIAL_NAMES = new Set(["template.md", "README.md"]);
/** Header placeholder tokens replaced with the resolved feature name (exact order). */
exports.PLACEHOLDERS = [
    "<feature-name>",
    "<refactor-name>",
    "<epic-name>",
    "<name>",
    "<bug-name>",
];
/** Template filename for the timestamped plan template. */
exports.PLAN_TIMESTAMP_TEMPLATE_NAME = "plan.yyyy-MM-ddTHH-mm.md";
/**
 * Join two POSIX path segments with a single forward slash.
 *
 * @param root Base path segment.
 * @param relative Path relative to the base.
 * @returns The combined forward-slash path.
 */
function joinPosix(root, relative) {
    const normalizedRoot = (0, file_system_1.toPosixPath)(root).replace(/\/+$/, "");
    const normalizedRelative = (0, file_system_1.toPosixPath)(relative).replace(/^\/+/, "");
    if (normalizedRoot === "") {
        return normalizedRelative;
    }
    if (normalizedRelative === "") {
        return normalizedRoot;
    }
    return `${normalizedRoot}/${normalizedRelative}`;
}
/**
 * Disk-backed {@link FolderFileSystem} implementation.
 *
 * Purpose:
 *     Provide real `node:fs`/`node:path`-backed I/O for production wiring.
 *     Tests inject a `Map`-backed fake instead.
 *
 * Side effects:
 *     Reads from and writes to the local filesystem.
 */
class RealFolderFileSystem {
    /**
     * @param path Path to test.
     * @returns True when `path` exists (file or directory).
     */
    exists(path) {
        return nodeFs.existsSync(path);
    }
    /**
     * Create `path` including missing parents.
     *
     * Mirrors Python `Path.mkdir(parents=True, exist_ok=True)`: idempotent and
     * does not raise when the directory already exists.
     *
     * @param path Directory path to create.
     */
    ensureDir(path) {
        nodeFs.mkdirSync(path, { recursive: true });
    }
    /**
     * Copy the file bytes from `src` to `dest`.
     *
     * Ensures the destination parent directory exists first, mirroring Python
     * `dest.parent.mkdir(parents=True, exist_ok=True)` + `shutil.copyfile`.
     *
     * @param src Source file path.
     * @param dest Destination file path.
     */
    copyFile(src, dest) {
        const parent = (0, file_system_1.toPosixPath)(nodePath.dirname(dest));
        nodeFs.mkdirSync(parent, { recursive: true });
        nodeFs.copyFileSync(src, dest);
    }
    /**
     * Recursively copy every file under `src` into `dest`, preserving layout.
     *
     * @param src Source directory root.
     * @param dest Destination directory root.
     */
    copyTree(src, dest) {
        const normalizedSrc = (0, file_system_1.toPosixPath)(src);
        // Walk the source tree depth-first and copy each regular file to the
        // destination at its source-relative path; directories are not copied
        // directly (they are created implicitly by copyFile's parent ensure).
        const walk = (currentDir) => {
            let entries;
            try {
                entries = nodeFs.readdirSync(currentDir, { withFileTypes: true });
            }
            catch {
                // A missing directory yields no copies rather than raising.
                return;
            }
            for (const entry of entries) {
                const childAbs = joinPosix((0, file_system_1.toPosixPath)(currentDir), entry.name);
                if (entry.isDirectory()) {
                    walk(childAbs);
                    continue;
                }
                if (entry.isFile()) {
                    const relative = childAbs.slice(normalizedSrc.length + 1);
                    this.copyFile(childAbs, joinPosix((0, file_system_1.toPosixPath)(dest), relative));
                }
            }
        };
        walk(normalizedSrc);
    }
    /**
     * List the regular files directly under `path`.
     *
     * @param path Directory to list.
     * @returns Forward-slash file paths directly under `path`, or `[]` when the
     *   directory is missing.
     */
    listFiles(path) {
        // Mirror Python `list_files`: return [] when the directory is absent rather
        // than raising, so callers can scan optional directories unguarded.
        if (!nodeFs.existsSync(path)) {
            return [];
        }
        const entries = nodeFs.readdirSync(path, { withFileTypes: true });
        const files = [];
        // Collect only the regular files directly under the directory (non-recursive).
        for (const entry of entries) {
            if (entry.isFile()) {
                files.push(joinPosix((0, file_system_1.toPosixPath)(path), entry.name));
            }
        }
        return files;
    }
    /**
     * @param path File to read.
     * @returns The file content decoded as UTF-8.
     */
    readText(path) {
        return nodeFs.readFileSync(path, "utf8");
    }
    /**
     * Write `content` to `path`, creating the parent directory first.
     *
     * @param path File to write.
     * @param content Text content to write as UTF-8.
     */
    writeText(path, content) {
        const parent = (0, file_system_1.toPosixPath)(nodePath.dirname(path));
        nodeFs.mkdirSync(parent, { recursive: true });
        nodeFs.writeFileSync(path, content, "utf8");
    }
    /**
     * Move `src` to `dest`, replacing an existing destination file.
     *
     * Ensures the destination parent exists, unlinks an existing destination FILE
     * first, then renames. Mirrors the Python `move` call order
     * (`mkdir` -> `unlink` -> `replace`).
     *
     * @param src Source path.
     * @param dest Destination path.
     */
    move(src, dest) {
        const parent = (0, file_system_1.toPosixPath)(nodePath.dirname(dest));
        nodeFs.mkdirSync(parent, { recursive: true });
        // Remove a pre-existing destination FILE before the rename so the move does
        // not fail on an existing target, matching the Python overwrite contract.
        if (nodeFs.existsSync(dest) && nodeFs.statSync(dest).isFile()) {
            nodeFs.unlinkSync(dest);
        }
        nodeFs.renameSync(src, dest);
    }
}
exports.RealFolderFileSystem = RealFolderFileSystem;
/**
 * Resolve the repository workspace root.
 *
 * Mirrors the BUNDLED runtime `resolve_workspace`, which returns the current
 * working directory. The service always supplies an explicit `workspaceRoot`,
 * so this default is only used when no workspace is injected.
 *
 * @returns The current working directory as a forward-slash path.
 */
function resolveWorkspace() {
    return (0, file_system_1.toPosixPath)(process.cwd());
}
/**
 * Return a Windows-safe timestamp string for `America/New_York`.
 *
 * Mirrors Python `get_est_timestamp`. The `nowProvider` is the injected clock
 * seam (per `.claude/rules/typescript.md`, production code must not read
 * `Date.now()` directly outside an injected clock); the default provider is the
 * single allowed wall-clock seam and is injectable so tests pass a fixed
 * instant.
 *
 * Divergence (documented): the Python source rejects a naive (tz-unaware)
 * datetime with `ValueError`. In TS a `Date` is always an absolute instant and
 * carries no naive form, so the tz-aware guard is satisfied by construction and
 * no spurious throw is introduced. The Python
 * `test_get_est_timestamp_rejects_naive_datetime` scenario has no TS analogue.
 *
 * @param nowProvider Optional clock seam returning the current instant.
 * @returns The instant formatted as `YYYY-MM-DDTHH-mm` in `America/New_York`.
 */
function getEstTimestamp(nowProvider) {
    // Injected clock seam: the default `new Date()` is the single allowed
    // wall-clock source; callers and tests inject a fixed instant via nowProvider.
    const now = nowProvider ? nowProvider() : new Date();
    // Format the instant in the America/New_York zone deterministically rather
    // than relying on the host's local timezone.
    const formatter = new Intl.DateTimeFormat("en-US", {
        timeZone: "America/New_York",
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        hour12: false,
    });
    const parts = formatter.formatToParts(now);
    const lookup = (type) => {
        const part = parts.find((candidate) => candidate.type === type);
        return part ? part.value : "";
    };
    // Intl `hour12: false` can emit "24" for midnight; normalize to "00" to match
    // the Python `%H` 24-hour zero-based hour formatting.
    const hour = lookup("hour") === "24" ? "00" : lookup("hour");
    return `${lookup("year")}-${lookup("month")}-${lookup("day")}T${hour}-${lookup("minute")}`;
}
/**
 * Extract the `YYYY-MM-DD` date component from a timestamp string.
 *
 * Mirrors Python `extract_date_from_timestamp`: returns the substring before
 * the first `T`.
 *
 * @param timestamp Timestamp string (e.g. `2026-03-14T15-48`).
 * @returns The portion before the first `T`.
 */
function extractDateFromTimestamp(timestamp) {
    return timestamp.split("T", 1)[0] ?? "";
}
/**
 * Validate a feature-name slug format.
 *
 * Mirrors Python `validate_feature_name`: throws with the byte-identical
 * message when the name is empty or fails the anchored full-match.
 *
 * @param featureName Candidate feature name.
 * @throws Error When the name is empty or does not match {@link NAME_PATTERN}.
 */
function validateFeatureName(featureName) {
    if (!featureName || !exports.NAME_PATTERN.test(featureName)) {
        throw new Error(`Aborted: '${featureName}' is invalid. Use kebab/underscore-case ` +
            "letters/numbers (e.g., notes-feature or notes_feature).");
    }
}
