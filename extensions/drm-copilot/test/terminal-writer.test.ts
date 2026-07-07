import { beforeEach, describe, expect, it, jest } from "@jest/globals";

/** In-test fake mirroring `vscode.EventEmitter<string>`'s observable shape. */
class FakeEventEmitter {
  private readonly listeners: Array<(value: string) => void> = [];

  event = (listener: (value: string) => void): { dispose: () => void } => {
    this.listeners.push(listener);
    return { dispose: (): void => undefined };
  };

  fire(value: string): void {
    for (const listener of this.listeners) {
      listener(value);
    }
  }
}

/** Minimal mutable stand-in for `vscode.Terminal`. */
interface FakeTerminal {
  readonly name: string;
  readonly show: jest.Mock;
  exitStatus: { code: number } | undefined;
}

const createTerminalMock = jest.fn(
  (terminalOptions: {
    readonly name: string;
    readonly pty: {
      readonly onDidWrite: (listener: (value: string) => void) => unknown;
      readonly open: () => void;
      readonly close: () => void;
    };
  }) => {
    const terminal: FakeTerminal = {
      name: terminalOptions.name,
      show: jest.fn(),
      exitStatus: undefined,
    };
    return terminal;
  },
);

jest.mock(
  "vscode",
  () => ({
    EventEmitter: FakeEventEmitter,
    window: {
      createTerminal: createTerminalMock,
    },
  }),
  { virtual: true },
);

import {
  createSubagentTreeTerminalWriter,
  SUBAGENT_TREE_TERMINAL_NAME,
} from "../src/terminal-writer";

describe("createSubagentTreeTerminalWriter", () => {
  beforeEach(() => {
    createTerminalMock.mockClear();
  });

  it("creates a single named terminal backed by a Pseudoterminal that emits header and body joined by \\r\\n", () => {
    // Arrange
    const writer = createSubagentTreeTerminalWriter();

    // Act
    writer.write("HEADER", "BODY");

    // Assert: exactly one terminal was created, with the stable name and a
    // Pseudoterminal that, once opened, emits the joined content.
    expect(createTerminalMock).toHaveBeenCalledTimes(1);
    const terminalOptions = createTerminalMock.mock.calls[0]?.[0];
    expect(terminalOptions?.name).toBe(SUBAGENT_TREE_TERMINAL_NAME);
    const received: string[] = [];
    terminalOptions?.pty.onDidWrite((chunk: string) => received.push(chunk));
    terminalOptions?.pty.open();
    expect(received.join("")).toBe("HEADER\r\nBODY");
  });

  it("reveals the terminal via show()", () => {
    // Arrange
    const writer = createSubagentTreeTerminalWriter();
    writer.write("h", "b");
    const terminal = createTerminalMock.mock.results[0]?.value as FakeTerminal;

    // Act
    writer.reveal();

    // Assert
    expect(terminal.show).toHaveBeenCalledTimes(1);
  });

  it("reuses the same terminal across repeated writes while it remains open", () => {
    // Arrange
    const writer = createSubagentTreeTerminalWriter();
    writer.write("h1", "b1");
    const terminalOptions = createTerminalMock.mock.calls[0]?.[0];
    const received: string[] = [];
    terminalOptions?.pty.onDidWrite((chunk: string) => received.push(chunk));
    terminalOptions?.pty.open();

    // Act: a second write while the terminal is still open and has not exited.
    writer.write("h2", "b2");

    // Assert: no second terminal was created, and the new content was
    // written to the existing (already-open) Pseudoterminal.
    expect(createTerminalMock).toHaveBeenCalledTimes(1);
    expect(received[received.length - 1]).toBe("h2\r\nb2");
  });

  it("creates a replacement terminal once the previous terminal has exited", () => {
    // Arrange
    const writer = createSubagentTreeTerminalWriter();
    writer.write("h1", "b1");
    const firstTerminal = createTerminalMock.mock.results[0]
      ?.value as FakeTerminal;
    firstTerminal.exitStatus = { code: 0 };

    // Act
    writer.write("h2", "b2");

    // Assert: the exited terminal is replaced rather than reused.
    expect(createTerminalMock).toHaveBeenCalledTimes(2);
  });

  it("does not fire pending content before the Pseudoterminal reports it is open", () => {
    // Arrange
    const writer = createSubagentTreeTerminalWriter();

    // Act: write before the host ever calls `pty.open()`.
    writer.write("h1", "b1");
    const terminalOptions = createTerminalMock.mock.calls[0]?.[0];
    const received: string[] = [];
    terminalOptions?.pty.onDidWrite((chunk: string) => received.push(chunk));
    writer.write("h2", "b2");

    // Assert: no content was emitted yet (matches real VS Code semantics:
    // writes before `open()` are ignored), and only the latest pending
    // content is emitted once the terminal opens.
    expect(received).toEqual([]);
    terminalOptions?.pty.open();
    expect(received).toEqual(["h2\r\nb2"]);
  });

  it("normalizes every internal line break in a multi-line body to \\r\\n", () => {
    // Arrange
    const writer = createSubagentTreeTerminalWriter();

    // Act
    writer.write("HEADER", "line1\nline2\nline3");
    const terminalOptions = createTerminalMock.mock.calls[0]?.[0];
    const received: string[] = [];
    terminalOptions?.pty.onDidWrite((chunk: string) => received.push(chunk));
    terminalOptions?.pty.open();

    // Assert: every line break — header/body boundary and every internal
    // break within the multi-line body — is normalized to `\r\n`, not a
    // bare `\n`, so a real VS Code Pseudoterminal renders each line flush
    // left instead of staircasing.
    expect(received.join("")).toBe("HEADER\r\nline1\r\nline2\r\nline3");
  });
});
