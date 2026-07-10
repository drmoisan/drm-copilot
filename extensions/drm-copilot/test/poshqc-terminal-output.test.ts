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
  POSHQC_TERMINAL_NAME,
  createPoshQcTerminalOutput,
  createTeeOutput,
} from "../src/poshqc-terminal-output";

describe("createPoshQcTerminalOutput", () => {
  beforeEach(() => {
    createTerminalMock.mockClear();
  });

  it("creates a stably-named terminal and streams appended lines with CRLF termination", () => {
    // Arrange
    const writer = createPoshQcTerminalOutput();

    // Act: append two lines, then open the Pseudoterminal.
    writer.appendLine("first");
    writer.appendLine("second");
    const terminalOptions = createTerminalMock.mock.calls[0]?.[0];
    const received: string[] = [];
    terminalOptions?.pty.onDidWrite((chunk: string) => received.push(chunk));
    terminalOptions?.pty.open();

    // Assert: one terminal, stable name, both buffered lines flushed in order
    // with CRLF termination.
    expect(createTerminalMock).toHaveBeenCalledTimes(1);
    expect(terminalOptions?.name).toBe(POSHQC_TERMINAL_NAME);
    expect(received.join("")).toBe("first\r\nsecond\r\n");
  });

  it("streams lines appended after open immediately and reuses the same terminal", () => {
    // Arrange
    const writer = createPoshQcTerminalOutput();
    writer.appendLine("before-open");
    const terminalOptions = createTerminalMock.mock.calls[0]?.[0];
    const received: string[] = [];
    terminalOptions?.pty.onDidWrite((chunk: string) => received.push(chunk));
    terminalOptions?.pty.open();

    // Act: an append after the terminal is open.
    writer.appendLine("after-open");

    // Assert: no second terminal created; both lines present in order.
    expect(createTerminalMock).toHaveBeenCalledTimes(1);
    expect(received.join("")).toBe("before-open\r\nafter-open\r\n");
  });

  it("normalizes internal line breaks within a single appended line to CRLF", () => {
    // Arrange
    const writer = createPoshQcTerminalOutput();

    // Act
    writer.appendLine("line1\nline2");
    const terminalOptions = createTerminalMock.mock.calls[0]?.[0];
    const received: string[] = [];
    terminalOptions?.pty.onDidWrite((chunk: string) => received.push(chunk));
    terminalOptions?.pty.open();

    // Assert: the internal break and the terminating break are both CRLF.
    expect(received.join("")).toBe("line1\r\nline2\r\n");
  });

  it("reveals the terminal via show()", () => {
    // Arrange
    const writer = createPoshQcTerminalOutput();

    // Act
    writer.reveal();
    const terminal = createTerminalMock.mock.results[0]?.value as FakeTerminal;

    // Assert: the terminal was created and shown.
    expect(createTerminalMock).toHaveBeenCalledTimes(1);
    expect(terminal.show).toHaveBeenCalledTimes(1);
  });

  it("creates a replacement terminal once the previous terminal has exited", () => {
    // Arrange
    const writer = createPoshQcTerminalOutput();
    writer.appendLine("run-1");
    const firstTerminal = createTerminalMock.mock.results[0]
      ?.value as FakeTerminal;
    firstTerminal.exitStatus = { code: 0 };

    // Act
    writer.appendLine("run-2");

    // Assert: the exited terminal is replaced rather than reused.
    expect(createTerminalMock).toHaveBeenCalledTimes(2);
  });
});

describe("createTeeOutput", () => {
  it("forwards every appendLine to both sinks in order", () => {
    // Arrange
    const primaryLines: string[] = [];
    const secondaryLines: string[] = [];
    const callOrder: string[] = [];
    const primary = {
      appendLine(line: string): void {
        primaryLines.push(line);
        callOrder.push(`primary:${line}`);
      },
    };
    const secondary = {
      appendLine(line: string): void {
        secondaryLines.push(line);
        callOrder.push(`secondary:${line}`);
      },
    };
    const tee = createTeeOutput(primary, secondary);

    // Act
    tee.appendLine("a");
    tee.appendLine("b");

    // Assert: both sinks receive identical streams; primary is called first.
    expect(primaryLines).toEqual(["a", "b"]);
    expect(secondaryLines).toEqual(["a", "b"]);
    expect(callOrder).toEqual([
      "primary:a",
      "secondary:a",
      "primary:b",
      "secondary:b",
    ]);
  });
});
