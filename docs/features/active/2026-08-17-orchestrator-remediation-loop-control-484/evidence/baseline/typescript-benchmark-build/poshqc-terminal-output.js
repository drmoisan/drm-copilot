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
exports.POSHQC_TERMINAL_NAME = void 0;
exports.createPoshQcTerminalOutput = createPoshQcTerminalOutput;
exports.createTeeOutput = createTeeOutput;
const vscode = __importStar(require("vscode"));
/** Stable, recognizable name for the PoshQC integrated terminal. */
exports.POSHQC_TERMINAL_NAME = "drm-copilot: PoshQC";
/**
 * Streaming (append-mode) {@link TerminalOutput} backed by a single reusable VS
 * Code integrated terminal driven by a `vscode.Pseudoterminal`.
 *
 * Purpose:
 *     Unlike the replace-mode `PseudoterminalTerminalWriter` used by the
 *     Subagent Tree command, this writer appends each line as it arrives so
 *     Pester output streams live. Every `\n` (bare or `\r\n`) is normalized to
 *     `\r\n` and each appended line is terminated with `\r\n`, so a real
 *     Pseudoterminal renders each line flush-left rather than staircasing.
 *
 * Lifecycle:
 *     - The terminal is created lazily on the first `appendLine` or `reveal`.
 *     - Lines appended before the host calls `pty.open()` are buffered and
 *       flushed, in order, once the terminal opens.
 *     - When the previously created terminal has exited (e.g. the user closed
 *       it), the next append or reveal replaces it with a fresh terminal of the
 *       same name, starting a new buffered stream.
 */
class PseudoterminalStreamingWriter {
    terminal;
    writeEmitter;
    isOpen = false;
    pending = [];
    /** @inheritdoc */
    appendLine(line) {
        // Normalize every internal break to CRLF and terminate the line with CRLF.
        const chunk = `${line.replace(/\r?\n/g, "\r\n")}\r\n`;
        this.ensureTerminal();
        // Emit immediately when the terminal is open; otherwise buffer until open.
        if (this.isOpen && this.writeEmitter !== undefined) {
            this.writeEmitter.fire(chunk);
        }
        else {
            this.pending.push(chunk);
        }
    }
    /** @inheritdoc */
    reveal() {
        this.ensureTerminal();
        this.terminal?.show();
    }
    /**
     * Ensure a live terminal exists, creating a replacement when none exists or
     * the previous terminal has exited.
     */
    ensureTerminal() {
        const hasLiveTerminal = this.terminal !== undefined && this.terminal.exitStatus === undefined;
        if (hasLiveTerminal) {
            return;
        }
        this.createTerminal();
    }
    /** Create the reusable Pseudoterminal-backed integrated terminal. */
    createTerminal() {
        const writeEmitter = new vscode.EventEmitter();
        this.writeEmitter = writeEmitter;
        this.isOpen = false;
        const pty = {
            onDidWrite: writeEmitter.event,
            open: () => {
                this.isOpen = true;
                // Flush any lines appended before the terminal reported open, in order.
                for (const chunk of this.pending) {
                    writeEmitter.fire(chunk);
                }
                this.pending = [];
            },
            close: () => {
                this.isOpen = false;
            },
        };
        this.terminal = vscode.window.createTerminal({
            name: exports.POSHQC_TERMINAL_NAME,
            pty,
        });
    }
}
/**
 * Create a streaming {@link TerminalOutput} backed by a single reusable
 * integrated terminal named `"drm-copilot: PoshQC"`.
 *
 * @returns A terminal-backed output sink that streams appended lines.
 */
function createPoshQcTerminalOutput() {
    return new PseudoterminalStreamingWriter();
}
/**
 * Create a tee {@link CommandOutput} that forwards every `appendLine` to two
 * sinks, in order (primary first, then secondary).
 *
 * Purpose:
 *     Display command output in an integrated terminal while preserving the
 *     existing `OutputChannel` log, without changing the spawn pipeline or the
 *     failure-reporting contract (`CommandExecutionError` / `getStderrExcerpt`).
 *
 * @param primary The first sink to receive each line (e.g. the OutputChannel).
 * @param secondary The second sink to receive each line (e.g. the terminal).
 * @returns A sink forwarding every line to both `primary` and `secondary`.
 */
function createTeeOutput(primary, secondary) {
    return {
        appendLine(line) {
            primary.appendLine(line);
            secondary.appendLine(line);
        },
    };
}
