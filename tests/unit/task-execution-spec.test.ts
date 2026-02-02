/**
 * Tests for task execution specification and argument resolution.
 *
 * These tests validate the task provider's ability to map command IDs
 * to execution specs and resolve variable tokens.
 */

import { describe, expect, it } from "@jest/globals";

import {
  getTaskExecutionSpec,
  getTaskInputIdsForCommand,
  // resolveTaskArgs, // Not yet implemented - Phase 2
} from "../../src/task-command-map";

describe("task-execution-spec", () => {
  describe("getTaskExecutionSpec", () => {
    it("returns QC black format command and args", () => {
      const spec = getTaskExecutionSpec("drm-copilot.qcBlackFormat");

      expect(spec).toBeDefined();
      expect(spec?.command).toBe("poetry");
      expect(spec?.args).toEqual(["run", "black", "."]);
    });
  });

  describe("getTaskInputIdsForCommand", () => {
    it("uses inputs for devPromotePotentialToIssue command", () => {
      const inputIds = getTaskInputIdsForCommand(
        "drm-copilot.devPromotePotentialToIssue",
      );

      expect(inputIds).toEqual(["PotentialPromotionType"]);
    });
  });

  describe.skip("resolveTaskArgs", () => {
    it("replaces tokens with provided context values", () => {
      const args = [
        "${workspaceFolder}/scripts/test.ps1",
        "-ExtensionRoot",
        "${extensionRoot}",
        "-File",
        "${file}",
        "-RelativeFile",
        "${relativeFile}",
        "-ShortName",
        "${input:PotentialShortName}",
      ];

      const context = {
        workspaceRoot: "/home/user/workspace",
        extensionRoot: "/home/user/.vscode/extensions/drm-copilot-1.0.0",
        activeFilePath: "/home/user/workspace/src/main.ts",
        activeRelativePath: "src/main.ts",
        inputValues: {
          PotentialShortName: "my-feature",
        },
      };

      // const resolved = resolveTaskArgs(args, context);

      // expect(resolved).toEqual([
      //   "/home/user/workspace/scripts/test.ps1",
      //   "-ExtensionRoot",
      //   "/home/user/.vscode/extensions/drm-copilot-1.0.0",
      //   "-File",
      //   "/home/user/workspace/src/main.ts",
      //   "-RelativeFile",
      //   "src/main.ts",
      //   "-ShortName",
      //   "my-feature",
      // ]);
    });

    it("throws error when missing input value", () => {
      const args = ["-ShortName", "${input:PotentialShortName}"];

      const context = {
        workspaceRoot: "/home/user/workspace",
        extensionRoot: "/home/user/.vscode/extensions/drm-copilot-1.0.0",
        inputValues: {}, // Empty - missing PotentialShortName
      };

      // expect(() => resolveTaskArgs(args, context)).toThrow(
      //   "Missing input value: PotentialShortName",
      // );
    });
  });
});
