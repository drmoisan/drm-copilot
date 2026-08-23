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
exports.RealPushDownFileSystem = void 0;
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
 * Production {@link PushDownFileSystem} backed by `node:fs`.
 *
 * Purpose:
 *     Provide the real-disk behavior for source enumeration, destination writes,
 *     and summary-artifact emission. Mirrors the Python
 *     `RealPushDownFileSystem`: recursive sorted enumeration, UTF-8 reads, and
 *     LF-normalized writes (Python `newline="\n"`).
 *
 * Invariants / Constraints:
 *     The scoped customization trees contain repository text content, so this
 *     adapter reads and writes UTF-8 text.
 *
 * Side effects:
 *     Reads from and writes to the real filesystem.
 */
class RealPushDownFileSystem {
    /**
     * Return all files beneath a root path in sorted order.
     *
     * Mirrors Python `RealPushDownFileSystem.list_files`: returns an empty list
     * when the root is not a directory, otherwise recursively collects every file
     * and sorts the result so summary artifacts remain deterministic.
     *
     * @param root Root directory to enumerate (POSIX path).
     * @returns Sorted forward-slash POSIX file paths beneath `root`.
     */
    listFiles(root) {
        const normalizedRoot = toPosixPath(root);
        if (!this.isDir(normalizedRoot)) {
            return [];
        }
        const files = [];
        // Walk the tree recursively so every nested file is collected; sorting is
        // applied once at the end to keep enumeration order stable for artifacts.
        const walk = (currentDir) => {
            let entries;
            try {
                entries = fs.readdirSync(currentDir, { withFileTypes: true });
            }
            catch {
                // A directory that becomes unreadable mid-walk contributes no files.
                return;
            }
            // Inspect each entry: record files and descend into subdirectories.
            for (const entry of entries) {
                const childPosix = joinPosix(currentDir, entry.name);
                if (entry.isDirectory()) {
                    walk(childPosix);
                }
                else if (entry.isFile()) {
                    files.push(childPosix);
                }
            }
        };
        walk(normalizedRoot);
        // Sort lexicographically to match Python's `sorted(files)` on POSIX paths.
        return files.sort((left, right) => left < right ? -1 : left > right ? 1 : 0);
    }
    /**
     * @param path Path to inspect.
     * @returns True when `path` exists and is a directory.
     */
    isDir(path) {
        try {
            return fs.statSync(path).isDirectory();
        }
        catch {
            return false;
        }
    }
    /**
     * @param path Path to inspect.
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
     * @param path File to read.
     * @returns The file content decoded as UTF-8.
     */
    readTextFile(path) {
        return fs.readFileSync(path, "utf8");
    }
    /**
     * Write UTF-8 text to a file path, creating parent directories first.
     *
     * Mirrors Python `RealPushDownFileSystem.write_text`, which creates the parent
     * directory and writes with `newline="\n"`. Content is LF-normalized so the
     * write is byte-stable regardless of the host line-ending convention.
     *
     * @param path Destination file path.
     * @param content UTF-8 text to write.
     */
    writeTextFile(path, content) {
        const parent = nodePath.dirname(path);
        fs.mkdirSync(parent, { recursive: true });
        // Normalize CRLF/CR to LF so writes match Python's newline="\n" behavior.
        const lfNormalized = content.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
        fs.writeFileSync(path, lfNormalized, "utf8");
    }
    /**
     * Ensure a directory exists, creating any missing parents.
     *
     * @param path Directory path to create.
     */
    ensureDir(path) {
        fs.mkdirSync(path, { recursive: true });
    }
}
exports.RealPushDownFileSystem = RealPushDownFileSystem;
