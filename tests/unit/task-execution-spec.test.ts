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
});
