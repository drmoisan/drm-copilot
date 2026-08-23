"use strict";
/**
 * Port-local filesystem seam for the potential-to-issue promotion workflow.
 *
 * Purpose:
 *     Define exactly the filesystem operations the workflow needs
 *     (`resolvePath`, `exists`, `readText`, `writeLines`, `ensureDir`, `move`)
 *     without widening the shared F1 `FileSystem` interface (which lacks
 *     `exists`/`move`/`writeLines`/`resolvePath`). Extracted from `promotion.ts`
 *     so that module stays within the 500-line limit, and re-exported from it
 *     for a stable public surface.
 *
 * Seam usage:
 *     Tests inject a Map-backed fake; production wiring uses
 *     {@link RealPotentialFileSystem}, backed by `node:fs`/`node:path`/`node:os`.
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
exports.RealPotentialFileSystem = void 0;
const fs = __importStar(require("node:fs"));
const nodeOs = __importStar(require("node:os"));
const nodePath = __importStar(require("node:path"));
/**
 * Production {@link PotentialFileSystem} backed by `node:fs`/`node:path`/`node:os`.
 *
 * Side effects:
 *     Reads from and writes to the local filesystem; creates directories and
 *     moves files.
 */
class RealPotentialFileSystem {
    /**
     * Resolve a path string: expand a leading `~` then resolve to an absolute
     * path. Mirrors Python `Path(path_str).expanduser().resolve()`.
     *
     * @param pathStr Raw path string.
     * @returns The resolved absolute path string.
     */
    resolvePath(pathStr) {
        // Expand a leading `~` to the user home directory before resolving.
        const expanded = pathStr === "~" || pathStr.startsWith("~/")
            ? nodePath.join(nodeOs.homedir(), pathStr.slice(1))
            : pathStr;
        return nodePath.resolve(expanded);
    }
    /** @returns True when `path` exists. */
    exists(path) {
        return fs.existsSync(path);
    }
    /** @returns The UTF-8 file content. */
    readText(path) {
        return fs.readFileSync(path, "utf8");
    }
    /** Write `lines` joined with `\n` as UTF-8 text. */
    writeLines(path, lines) {
        fs.writeFileSync(path, lines.join("\n"), "utf8");
    }
    /** Create `path` and any missing parents (idempotent). */
    ensureDir(path) {
        fs.mkdirSync(path, { recursive: true });
    }
    /** Move `src` to `dest`, ensuring the destination parent exists first. */
    move(src, dest) {
        fs.mkdirSync(nodePath.dirname(dest), { recursive: true });
        fs.renameSync(src, dest);
    }
}
exports.RealPotentialFileSystem = RealPotentialFileSystem;
