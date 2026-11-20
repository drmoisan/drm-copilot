import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });
// The stdio transport would bind the Jest process streams; a stub stands in.
jest.mock("@modelcontextprotocol/sdk/server/stdio.js", () => ({
  StdioServerTransport: class StubStdioServerTransport {},
}));

import { Server } from "@modelcontextprotocol/sdk/server/index.js";

import {
  DEFAULT_MAIN_ENTRY_POINTS,
  main,
  type MainEntryPoints,
} from "../src/mcp-server";

function entries(code = 0) {
  const runCli = jest.fn<MainEntryPoints["runCli"]>(() => code);
  const startServer = jest.fn<MainEntryPoints["startServer"]>(
    async () => undefined,
  );
  return { runCli, startServer, value: { runCli, startServer } };
}

describe("main", () => {
  let priorExitCode: typeof process.exitCode;

  beforeEach(() => {
    priorExitCode = process.exitCode;
  });

  afterEach(() => {
    // Restore the exit code so no case leaves a non-zero code in the Jest process.
    process.exitCode = priorExitCode;
  });

  it("dispatches the migrate-development-docs subcommand and sets the exit code from the CLI", async () => {
    // Arrange
    const fake = entries(2);

    // Act
    await main(["migrate-development-docs", "--workspace", "/w"], fake.value);

    // Assert
    expect(fake.runCli).toHaveBeenCalledWith(["--workspace", "/w"]);
    expect(fake.startServer).not.toHaveBeenCalled();
    expect(process.exitCode).toBe(2);
  });

  it.each([[[]], [["--stdio"]], [["serve", "migrate-development-docs"]]])(
    "starts the server for the arguments %p",
    async (argv) => {
      // Arrange
      const fake = entries();

      // Act
      await main(argv, fake.value);

      // Assert
      expect(fake.startServer).toHaveBeenCalledTimes(1);
      expect(fake.runCli).not.toHaveBeenCalled();
    },
  );

  it("reads process.argv when no arguments are given", async () => {
    // Arrange: the Jest process arguments never begin with the subcommand.
    const fake = entries();

    // Act
    await main(undefined, fake.value);

    // Assert
    expect(fake.startServer).toHaveBeenCalledTimes(1);
  });

  it("connects the repo-automation server to the stdio transport through the default startServer", async () => {
    // Arrange
    const connect = jest
      .spyOn(Server.prototype, "connect")
      .mockResolvedValue(undefined);

    // Act
    await DEFAULT_MAIN_ENTRY_POINTS.startServer();

    // Assert
    expect(connect).toHaveBeenCalledTimes(1);
    connect.mockRestore();
  });

  it("routes the subcommand to the real CLI through the default entry points", async () => {
    // Arrange: a usage error exits 2 before any file system or git access.
    const write = jest
      .spyOn(process.stderr, "write")
      .mockImplementation(() => true);

    // Act
    await main(["migrate-development-docs", "--bogus"]);

    // Assert
    expect(process.exitCode).toBe(2);
    expect(DEFAULT_MAIN_ENTRY_POINTS.startServer).toEqual(expect.any(Function));
    write.mockRestore();
  });
});
