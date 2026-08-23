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
exports.writeHelloMessage = writeHelloMessage;
const nodePath = __importStar(require("node:path"));
const file_system_1 = require("./file-system");
/** Relative POSIX path of the file the smoke test writes. */
const HELLO_OUTPUT_RELATIVE_PATH = "artifacts/hello_python.txt";
/**
 * Byte-identical content the former `hello_python.py` wrote, including the
 * trailing newline, preserved so the observable output contract is unchanged.
 */
const HELLO_OUTPUT_CONTENT = "hello_python:ok\n";
/**
 * Write the `hello_python` smoke-test artifact in-process.
 *
 * Purpose:
 *     In-process replacement for `resources/templates/hello_python.py`. Writes
 *     `artifacts/hello_python.txt` under the workspace root with the exact
 *     content `"hello_python:ok\n"`, removing the last Python-spawn code path
 *     while preserving the `drmCopilotExtension.helloPython` command surface and
 *     its observable output.
 *
 * Responsibilities:
 *     - Resolve `<workspaceRoot>/artifacts/hello_python.txt`.
 *     - Ensure the parent `artifacts/` directory exists, then write the file.
 *     - Return a structured result and emit the summary via `log`.
 *
 * Side effects:
 *     Creates one directory (idempotent) and writes one file through the
 *     injected {@link FileSystem}. Performs no subprocess execution and no
 *     direct stdout writes.
 *
 * @param input See {@link WriteHelloMessageInput}.
 * @returns The structured {@link WriteHelloMessageResult} describing the write.
 */
function writeHelloMessage(input) {
    const { fileSystem, workspaceRoot, log } = input;
    // Resolve the output path under the workspace root, then normalize to POSIX
    // separators so the path is OS-neutral for both the filesystem write and the
    // returned/observed value.
    const outputPath = (0, file_system_1.toPosixPath)(nodePath.join(workspaceRoot, HELLO_OUTPUT_RELATIVE_PATH));
    // Ensure the parent `artifacts/` directory exists, then write the file with
    // the byte-identical content of the former Python source.
    fileSystem.ensureDir(nodePath.dirname(outputPath));
    fileSystem.writeTextFile(outputPath, HELLO_OUTPUT_CONTENT);
    const summary = "Wrote artifacts/hello_python.txt.";
    log?.(summary);
    return {
        tool: "hello_python",
        workspaceRoot,
        summary,
        artifacts: [HELLO_OUTPUT_RELATIVE_PATH],
    };
}
