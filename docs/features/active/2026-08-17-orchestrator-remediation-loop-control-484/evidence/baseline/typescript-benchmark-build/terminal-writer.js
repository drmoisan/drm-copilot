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
exports.SUBAGENT_TREE_TERMINAL_NAME = void 0;
exports.createSubagentTreeTerminalWriter = createSubagentTreeTerminalWriter;
const vscode = __importStar(require("vscode"));
/** Stable, recognizable name for the Subagent Tree integrated terminal. */
exports.SUBAGENT_TREE_TERMINAL_NAME = "drm-copilot: Subagent Tree";
/**
 * `TerminalWriter` backed by a single reusable VS Code integrated terminal
 * whose content is driven by a `vscode.Pseudoterminal`.
 *
 * Purpose:
 *     Render output to a stably-named integrated terminal, reusing the same
 *     terminal instance across repeated command invocations instead of
 *     accumulating a new terminal per run. When the previously created
 *     terminal has exited (e.g. the user closed it), the next `write` call
 *     replaces it with a freshly created terminal of the same name.
 */
class PseudoterminalTerminalWriter {
    terminal;
    writeEmitter;
    isOpen = false;
    pendingContent = "";
    /** @inheritdoc */
    write(header, body) {
        this.pendingContent = `${header}\r\n${body}`.replace(/\r?\n/g, "\r\n");
        const hasLiveTerminal = this.terminal !== undefined && this.terminal.exitStatus === undefined;
        if (hasLiveTerminal) {
            if (this.isOpen && this.writeEmitter !== undefined) {
                this.writeEmitter.fire(this.pendingContent);
            }
            return;
        }
        this.createTerminal();
    }
    /** @inheritdoc */
    reveal() {
        this.terminal?.show();
    }
    createTerminal() {
        const writeEmitter = new vscode.EventEmitter();
        this.writeEmitter = writeEmitter;
        this.isOpen = false;
        const pty = {
            onDidWrite: writeEmitter.event,
            open: () => {
                this.isOpen = true;
                writeEmitter.fire(this.pendingContent);
            },
            close: () => {
                this.isOpen = false;
            },
        };
        this.terminal = vscode.window.createTerminal({
            name: exports.SUBAGENT_TREE_TERMINAL_NAME,
            pty,
        });
    }
}
/**
 * Create the real `TerminalWriter` used by `registerSubagentTreeCommand`.
 *
 * @returns A `TerminalWriter` backed by a single reusable integrated
 *   terminal named `"drm-copilot: Subagent Tree"`.
 */
function createSubagentTreeTerminalWriter() {
    return new PseudoterminalTerminalWriter();
}
