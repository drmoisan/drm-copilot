import * as vscode from "vscode";
import type { CommandOutput } from "./command-runtime";

/** Stable, recognizable name for the PoshQC integrated terminal. */
export const POSHQC_TERMINAL_NAME = "drm-copilot: PoshQC";

/**
 * A {@link CommandOutput} sink that also exposes a way to reveal its backing
 * integrated terminal.
 *
 * Purpose:
 *     Let PoshQC command handlers stream process output to an integrated
 *     terminal (in addition to the `OutputChannel`) and reveal that terminal at
 *     command start, without depending on `vscode.window.createTerminal`
 *     directly. Tests inject the harness `createTerminal` mock.
 */
export interface TerminalOutput extends CommandOutput {
  /** Reveal (focus) the underlying integrated terminal. */
  reveal(): void;
}

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
class PseudoterminalStreamingWriter implements TerminalOutput {
  private terminal: vscode.Terminal | undefined;
  private writeEmitter: vscode.EventEmitter<string> | undefined;
  private isOpen = false;
  private pending: string[] = [];

  /** @inheritdoc */
  appendLine(line: string): void {
    // Normalize every internal break to CRLF and terminate the line with CRLF.
    const chunk = `${line.replace(/\r?\n/g, "\r\n")}\r\n`;
    this.ensureTerminal();

    // Emit immediately when the terminal is open; otherwise buffer until open.
    if (this.isOpen && this.writeEmitter !== undefined) {
      this.writeEmitter.fire(chunk);
    } else {
      this.pending.push(chunk);
    }
  }

  /** @inheritdoc */
  reveal(): void {
    this.ensureTerminal();
    this.terminal?.show();
  }

  /**
   * Ensure a live terminal exists, creating a replacement when none exists or
   * the previous terminal has exited.
   */
  private ensureTerminal(): void {
    const hasLiveTerminal =
      this.terminal !== undefined && this.terminal.exitStatus === undefined;
    if (hasLiveTerminal) {
      return;
    }
    this.createTerminal();
  }

  /** Create the reusable Pseudoterminal-backed integrated terminal. */
  private createTerminal(): void {
    const writeEmitter = new vscode.EventEmitter<string>();
    this.writeEmitter = writeEmitter;
    this.isOpen = false;

    const pty: vscode.Pseudoterminal = {
      onDidWrite: writeEmitter.event,
      open: (): void => {
        this.isOpen = true;
        // Flush any lines appended before the terminal reported open, in order.
        for (const chunk of this.pending) {
          writeEmitter.fire(chunk);
        }
        this.pending = [];
      },
      close: (): void => {
        this.isOpen = false;
      },
    };

    this.terminal = vscode.window.createTerminal({
      name: POSHQC_TERMINAL_NAME,
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
export function createPoshQcTerminalOutput(): TerminalOutput {
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
export function createTeeOutput(
  primary: CommandOutput,
  secondary: CommandOutput,
): CommandOutput {
  return {
    appendLine(line: string): void {
      primary.appendLine(line);
      secondary.appendLine(line);
    },
  };
}
