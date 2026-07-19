import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import {
  setExecutablePresenceOnFsMock,
  type MockExistsSync,
} from "./runtime-test-helpers";

jest.mock("node:fs", () => ({
  existsSync: jest.fn(),
}));

import { detectRuntime } from "../src/runtime-detection";

const fsMock = jest.requireMock("node:fs") as { existsSync: MockExistsSync };

// The workspace root and the platform-specific `.venv` interpreter candidate
// the Python probe checks first.
const WORKSPACE_ROOT = "C:/workspace";
const VENV_INTERPRETER =
  process.platform === "win32"
    ? "C:/workspace/.venv/Scripts/python.exe"
    : "C:/workspace/.venv/bin/python";

describe("detectRuntime Python probe", () => {
  beforeEach(() => {
    process.env["PATH"] = "C:/bin";
    process.env["PATHEXT"] = ".EXE;.CMD";
    fsMock.existsSync.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("resolves the workspace .venv interpreter first when it exists", () => {
    // Arrange: only the workspace .venv interpreter is present; PATH probes fail.
    setExecutablePresenceOnFsMock(fsMock, {
      [VENV_INTERPRETER]: true,
      py: false,
      python: false,
    });

    // Act
    const runtime = detectRuntime("python", WORKSPACE_ROOT);

    // Assert
    expect(runtime.executable).toBe(VENV_INTERPRETER);
    expect(runtime.argsPrefix).toEqual([]);
  });

  it("strips a trailing slash from the workspace root before probing .venv", () => {
    // Arrange
    setExecutablePresenceOnFsMock(fsMock, {
      [VENV_INTERPRETER]: true,
      py: false,
      python: false,
    });

    // Act
    const runtime = detectRuntime("python", `${WORKSPACE_ROOT}/`);

    // Assert: the normalized candidate path is unchanged by the trailing slash.
    expect(runtime.executable).toBe(VENV_INTERPRETER);
  });

  it("falls back to the py launcher on PATH when no .venv interpreter exists", () => {
    // Arrange: no .venv interpreter; the py launcher is present on PATH.
    setExecutablePresenceOnFsMock(fsMock, {
      [VENV_INTERPRETER]: false,
      py: true,
      python: false,
    });

    // Act
    const runtime = detectRuntime("python", WORKSPACE_ROOT);

    // Assert
    expect(runtime.executable.toLowerCase()).toContain("py");
    expect(runtime.argsPrefix).toEqual([]);
  });

  it("falls back to python on PATH when neither .venv nor py is available", () => {
    // Arrange: only a plain python interpreter is present on PATH.
    setExecutablePresenceOnFsMock(fsMock, {
      py: false,
      python: true,
    });

    // Act: omit the workspace root to exercise the no-.venv-probe branch.
    const runtime = detectRuntime("python");

    // Assert
    expect(runtime.executable.toLowerCase()).toContain("python");
    expect(runtime.argsPrefix).toEqual([]);
  });

  it("ignores an empty workspace root and resolves from PATH", () => {
    // Arrange
    setExecutablePresenceOnFsMock(fsMock, {
      py: false,
      python: true,
    });

    // Act
    const runtime = detectRuntime("python", "   ");

    // Assert
    expect(runtime.executable.toLowerCase()).toContain("python");
  });

  it("resolves a python interpreter through a PATHEXT suffix on Windows", () => {
    // Arrange: only a Windows PATHEXT-suffixed python is present.
    if (process.platform !== "win32") {
      // On non-Windows PATHEXT does not apply; assert the plain probe resolves.
      setExecutablePresenceOnFsMock(fsMock, { python: true });
      expect(detectRuntime("python").executable).toContain("python");
      return;
    }

    process.env["PATHEXT"] = ".COM;.EXE";
    setExecutablePresenceOnFsMock(fsMock, {
      "C:/bin/python.EXE": true,
      py: false,
      python: false,
    });

    // Act
    const runtime = detectRuntime("python");

    // Assert: the resolved executable carries the PATHEXT-derived suffix.
    expect(runtime.executable).toBe("C:/bin/python.EXE");
  });

  it("throws a clear error when no Python interpreter can be resolved", () => {
    // Arrange: neither a .venv interpreter nor a PATH interpreter exists.
    setExecutablePresenceOnFsMock(fsMock, {
      py: false,
      python: false,
    });

    // Act / Assert
    expect(() => detectRuntime("python", WORKSPACE_ROOT)).toThrow(
      "Python runtime not found. Expected a workspace '.venv' interpreter or 'py' or 'python' on PATH.",
    );
  });
});
