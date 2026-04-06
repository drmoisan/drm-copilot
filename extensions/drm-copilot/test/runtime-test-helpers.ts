import { EventEmitter } from "node:events";
import { jest } from "@jest/globals";

export interface ExecutablePresence {
  readonly python?: boolean;
  readonly py?: boolean;
  readonly pwsh?: boolean;
  readonly powershell?: boolean;
}

export type MockExistsSync = jest.MockedFunction<(filePath: string) => boolean>;

export type MockChildProcess = EventEmitter & {
  stdout: EventEmitter;
  stderr: EventEmitter;
};

/**
 * Applies the runtime-presence fixture to a mocked fs.existsSync implementation.
 *
 * @param fsModule The mocked fs module used by the test file.
 * @param presence The executable-presence matrix to simulate.
 */
export function setExecutablePresenceOnFsMock(
  fsModule: { existsSync: MockExistsSync },
  presence: ExecutablePresence,
): void {
  fsModule.existsSync.mockImplementation((filePath: string) => {
    const lowerPath = filePath.toLowerCase();
    if (lowerPath.includes("python")) {
      return presence.python ?? false;
    }

    if (lowerPath.includes(`${"\\"}py.`) || lowerPath.endsWith("/py")) {
      return presence.py ?? false;
    }

    if (lowerPath.includes("pwsh")) {
      return presence.pwsh ?? false;
    }

    if (lowerPath.includes("powershell")) {
      return presence.powershell ?? false;
    }

    return false;
  });
}

/**
 * Forces node:path.resolve to use POSIX semantics for Windows-root fixture tests.
 */
export function prepareFreshModulesWithPosixPathResolve(): void {
  jest.resetModules();
  jest.doMock("node:path", () => {
    const actual = jest.requireActual(
      "node:path",
    ) as typeof import("node:path");
    return {
      ...actual,
      resolve: actual.posix.resolve,
    };
  });
}

/**
 * Returns the freshly required child_process mock after a fresh-module setup.
 *
 * @returns The mocked child_process module for the fresh module graph.
 */
export function getFreshChildProcessMock(): {
  spawn: jest.Mock;
  spawnSync?: jest.Mock;
} {
  // eslint-disable-next-line @typescript-eslint/no-require-imports -- Jest fresh-module loading needs CommonJS require in this runner
  return require("node:child_process") as {
    spawn: jest.Mock;
    spawnSync?: jest.Mock;
  };
}

/**
 * Returns the freshly required fs mock after a fresh-module setup.
 *
 * @returns The mocked fs module for the fresh module graph.
 */
export function getFreshFsMock(): { existsSync: MockExistsSync } {
  // eslint-disable-next-line @typescript-eslint/no-require-imports -- Jest fresh-module loading needs CommonJS require in this runner
  return require("node:fs") as { existsSync: MockExistsSync };
}

/**
 * Creates a mock child process that exits with the provided code.
 *
 * @param exitCode The simulated process exit code.
 * @param stdoutText Optional stdout text emitted before the process closes.
 * @returns A mocked child process instance.
 */
export function createMockProcess(
  exitCode: number,
  stdoutText: string = "",
): MockChildProcess {
  const processMock = new EventEmitter() as MockChildProcess;
  processMock.stdout = new EventEmitter();
  processMock.stderr = new EventEmitter();
  process.nextTick(() => {
    if (stdoutText.length > 0) {
      processMock.stdout.emit("data", Buffer.from(stdoutText, "utf-8"));
    }

    processMock.emit("close", exitCode);
  });
  return processMock;
}

/**
 * Creates a mock child process that emits stderr before exiting.
 *
 * @param exitCode The simulated process exit code.
 * @param stderrLine The stderr line emitted before exit.
 * @returns A mocked child process instance.
 */
export function createMockProcessWithStderr(
  exitCode: number,
  stderrLine: string,
): MockChildProcess {
  const processMock = new EventEmitter() as MockChildProcess;
  processMock.stdout = new EventEmitter();
  processMock.stderr = new EventEmitter();
  process.nextTick(() => {
    processMock.stderr.emit("data", Buffer.from(stderrLine, "utf-8"));
    processMock.emit("close", exitCode);
  });
  return processMock;
}
