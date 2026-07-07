import * as vscode from "vscode";

/**
 * Minimal terminal-writing seam used by host-bound commands that render
 * multi-line output to an integrated VS Code terminal rather than an
 * `OutputChannel`.
 *
 * Purpose:
 *     Let command handlers (e.g. `registerSubagentTreeCommand`) depend on an
 *     injectable interface instead of `vscode.window.createTerminal`
 *     directly, so unit tests can assert on captured terminal output without
 *     a live VS Code host, mirroring how the `FileSystem` seam is injected.
 */
export interface TerminalWriter {
  /**
   * Write `header` and `body` to the terminal, joined by `\r\n`. Replaces any
   * previously written content rather than appending to it.
   *
   * @param header A single header line describing the rendered content.
   * @param body The full rendered body to display beneath the header.
   */
  write(header: string, body: string): void;

  /** Reveal (focus) the underlying terminal. */
  reveal(): void;
}

/** Stable, recognizable name for the Subagent Tree integrated terminal. */
export const SUBAGENT_TREE_TERMINAL_NAME = "drm-copilot: Subagent Tree";

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
class PseudoterminalTerminalWriter implements TerminalWriter {
  private terminal: vscode.Terminal | undefined;
  private writeEmitter: vscode.EventEmitter<string> | undefined;
  private isOpen = false;
  private pendingContent = "";

  /** @inheritdoc */
  write(header: string, body: string): void {
    this.pendingContent = `${header}\r\n${body}`.replace(/\r?\n/g, "\r\n");

    const hasLiveTerminal =
      this.terminal !== undefined && this.terminal.exitStatus === undefined;
    if (hasLiveTerminal) {
      if (this.isOpen && this.writeEmitter !== undefined) {
        this.writeEmitter.fire(this.pendingContent);
      }
      return;
    }

    this.createTerminal();
  }

  /** @inheritdoc */
  reveal(): void {
    this.terminal?.show();
  }

  private createTerminal(): void {
    const writeEmitter = new vscode.EventEmitter<string>();
    this.writeEmitter = writeEmitter;
    this.isOpen = false;

    const pty: vscode.Pseudoterminal = {
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
      name: SUBAGENT_TREE_TERMINAL_NAME,
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
export function createSubagentTreeTerminalWriter(): TerminalWriter {
  return new PseudoterminalTerminalWriter();
}
