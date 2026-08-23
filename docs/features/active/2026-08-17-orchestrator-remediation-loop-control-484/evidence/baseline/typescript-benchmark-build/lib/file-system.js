"use strict";
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
exports.RealFileTimes = exports.RealFileSystem = void 0;
exports.toPosixPath = toPosixPath;
const fs = __importStar(require("node:fs"));
const nodePath = __importStar(require("node:path"));
/**
 * Normalize a path to forward-slash separators.
 *
 * @param value A path that may contain OS-specific separators.
 * @returns The path with all backslashes converted to forward slashes.
 */
function toPosixPath(value) {
    return value.replace(/\\/g, "/");
}
/**
 * Join a root and a relative path using forward-slash separators.
 *
 * @param root Base path.
 * @param relative Path relative to the base.
 * @returns The combined POSIX-style path.
 */
function joinPosix(root, relative) {
    const normalizedRoot = toPosixPath(root).replace(/\/+$/, "");
    const normalizedRelative = toPosixPath(relative).replace(/^\/+/, "");
    if (normalizedRoot === "") {
        return normalizedRelative;
    }
    if (normalizedRelative === "") {
        return normalizedRoot;
    }
    return `${normalizedRoot}/${normalizedRelative}`;
}
/**
 * Escape regular-expression metacharacters in a literal pattern segment.
 *
 * @param value Literal text that may contain regex metacharacters.
 * @returns The text with metacharacters escaped for safe use in a RegExp.
 */
function escapeRegExp(value) {
    return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
/**
 * Compile a glob pattern into an anchored RegExp matching a relative path.
 *
 * Supported tokens (sufficient for the governed/exclude patterns and Python
 * `Path.glob` semantics used by `json-config`):
 * - `**` matches any number of path segments (including zero).
 * - `*` matches any run of characters within a single path segment.
 * - `?` matches a single non-separator character.
 * - All other characters match literally.
 *
 * The pattern is matched against a relative POSIX path (no leading slash).
 *
 * @param pattern Glob pattern using forward-slash separators.
 * @returns A RegExp anchored to the full relative path.
 */
function compileGlob(pattern) {
    const normalized = toPosixPath(pattern);
    let regex = "";
    let index = 0;
    // Walk the pattern character by character, translating glob tokens. A
    // single pass keeps `**`, `*`, and `?` handling unambiguous and ordered.
    while (index < normalized.length) {
        const char = normalized[index];
        if (char === "*") {
            const isDoubleStar = normalized[index + 1] === "*";
            if (isDoubleStar) {
                // `**/` (or trailing `**`) spans zero or more full path segments.
                const followedBySlash = normalized[index + 2] === "/";
                if (followedBySlash) {
                    regex += "(?:.*/)?";
                    index += 3;
                }
                else {
                    regex += ".*";
                    index += 2;
                }
                continue;
            }
            // Single `*` matches within one segment (no separators).
            regex += "[^/]*";
            index += 1;
            continue;
        }
        if (char === "?") {
            regex += "[^/]";
            index += 1;
            continue;
        }
        regex += escapeRegExp(char ?? "");
        index += 1;
    }
    return new RegExp(`^${regex}$`);
}
/**
 * Production {@link FileSystem} backed by `node:fs`.
 *
 * Purpose:
 *     Provide real disk I/O and a glob walker whose matching semantics align
 *     with the compiled glob RegExp, so hermetic fakes that reuse the same
 *     pattern semantics validate consumer logic rather than the glob engine.
 *
 * Side effects:
 *     Reads from and writes to the local filesystem.
 */
class RealFileSystem {
    /**
     * Enumerate files and directories under `root` matching `pattern`.
     *
     * Walks the directory tree once and tests each discovered relative path
     * against the compiled glob. Both files and directories are returned, so the
     * caller (e.g. `iterGovernedFiles`) can apply its own file/exclude checks.
     *
     * @param root Root directory to search under.
     * @param pattern Glob pattern relative to `root`.
     * @returns Matching absolute-style POSIX paths joined to `root`.
     */
    glob(root, pattern) {
        const matcher = compileGlob(pattern);
        const matches = [];
        const normalizedRoot = toPosixPath(root);
        // Recursively descend the tree, recording every relative path that matches.
        const walk = (currentDir, relativePrefix) => {
            let entries;
            try {
                entries = fs.readdirSync(currentDir, { withFileTypes: true });
            }
            catch {
                // A missing or unreadable directory yields no matches rather than
                // raising; this mirrors Path.glob returning nothing for absent roots.
                return;
            }
            // Inspect each entry: test it against the matcher and recurse into dirs.
            for (const entry of entries) {
                const relativePath = relativePrefix === ""
                    ? entry.name
                    : `${relativePrefix}/${entry.name}`;
                if (matcher.test(relativePath)) {
                    matches.push(joinPosix(normalizedRoot, relativePath));
                }
                if (entry.isDirectory()) {
                    walk(nodePath.join(currentDir, entry.name), relativePath);
                }
            }
        };
        walk(normalizedRoot, "");
        return matches;
    }
    /**
     * @param path Path to test.
     * @returns True when `path` exists and is a regular file.
     */
    isFile(path) {
        try {
            return fs.statSync(path).isFile();
        }
        catch {
            return false;
        }
    }
    /**
     * @param path Path to test.
     * @returns True when `path` exists; false on any access error.
     */
    exists(path) {
        return fs.existsSync(path);
    }
    /**
     * @param path Path to test.
     * @returns True when `path` exists and is a directory; false otherwise.
     */
    isDirectory(path) {
        try {
            return fs.statSync(path).isDirectory();
        }
        catch {
            return false;
        }
    }
    /**
     * @param path Directory whose immediate children are listed.
     * @returns Sorted child names; an empty array when `path` is not a readable
     *   directory.
     */
    listDirectory(path) {
        try {
            // `readdirSync` raises for a missing path or a non-directory; treat any
            // such failure as "no children" to match Python's tolerant discovery.
            return fs
                .readdirSync(path)
                .sort((left, right) => left.localeCompare(right));
        }
        catch {
            return [];
        }
    }
    /**
     * @param path File to read.
     * @returns The file content decoded as UTF-8.
     */
    readTextFile(path) {
        return fs.readFileSync(path, "utf8");
    }
    /**
     * @param path File to write.
     * @param content Text content to write as UTF-8.
     */
    writeTextFile(path, content) {
        fs.writeFileSync(path, content, "utf8");
    }
    /**
     * Create the directory at `path`, including any missing parents.
     *
     * Uses `fs.mkdirSync(path, { recursive: true })`, which is idempotent and
     * does not raise when the directory already exists, matching Python
     * `Path.mkdir(parents=True, exist_ok=True)`.
     *
     * @param path Directory path to create.
     */
    ensureDir(path) {
        fs.mkdirSync(path, { recursive: true });
    }
}
exports.RealFileSystem = RealFileSystem;
/**
 * Production {@link FileTimes} backed by `node:fs`.
 *
 * Side effects:
 *     Reads file metadata from the local filesystem.
 */
class RealFileTimes {
    /**
     * @param path Path whose modified time is requested.
     * @returns The file's `mtimeMs`, or `undefined` on any stat failure.
     */
    getModifiedTimeMs(path) {
        try {
            return fs.statSync(path).mtimeMs;
        }
        catch {
            return undefined;
        }
    }
}
exports.RealFileTimes = RealFileTimes;
