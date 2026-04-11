import { describe, expect, it } from "@jest/globals";

import {
  resolveRunPoshQCAnalyzeAutofixInvocation,
  resolveRunPoshQCAnalyzeInvocation,
  resolveRunPoshQCFormatInvocation,
  resolveRunPoshQCSuiteInvocation,
  resolveRunPoshQCTestInvocation,
} from "../src/workflow-command-arguments";

const commandResolvers = [
  resolveRunPoshQCFormatInvocation,
  resolveRunPoshQCAnalyzeInvocation,
  resolveRunPoshQCTestInvocation,
  resolveRunPoshQCAnalyzeAutofixInvocation,
  resolveRunPoshQCSuiteInvocation,
] as const;

describe("PoshQC workflow command arguments", () => {
  it.each(commandResolvers)(
    "returns interactive mode when no args are supplied",
    (resolver) => {
      expect(resolver([])).toEqual({ mode: "interactive" });
    },
  );

  it.each(commandResolvers)(
    "parses repeated --scan-folder flags",
    (resolver) => {
      expect(
        resolver(["--scan-folder", "src", "--scan-folder", "tests/powershell"]),
      ).toEqual({
        mode: "direct",
        input: {
          scanFolders: ["src", "tests/powershell"],
        },
      });
    },
  );

  it.each(commandResolvers)("rejects unknown flags", (resolver) => {
    expect(() => resolver(["--bogus", "value"])).toThrow(/unknown flag/i);
  });

  it.each(commandResolvers)("rejects missing flag values", (resolver) => {
    expect(() => resolver(["--scan-folder"])).toThrow(/requires a value/i);
  });
});
