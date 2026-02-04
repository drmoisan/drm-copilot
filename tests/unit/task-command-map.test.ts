import { describe, expect, test } from "@jest/globals";

import {
  getTaskLabelForCommandId,
  TASK_COMMAND_MAP,
} from "../../src/task-command-map";

describe("task-command-map", () => {
  test("maps known commands to stable task labels", () => {
    expect(getTaskLabelForCommandId("drm-copilot.loadOpenAIKey")).toBe(
      "Load OpenAI Key",
    );
    expect(getTaskLabelForCommandId("drm-copilot.qcBlackFormat")).toBe(
      "QC: 1 Black: format",
    );
    expect(getTaskLabelForCommandId("drm-copilot.tsJestUnitTests")).toBe(
      "TS: 4 Jest: unit tests",
    );
  });

  test("does not contain empty command IDs or task labels", () => {
    for (const [commandId, taskLabel] of Object.entries(TASK_COMMAND_MAP)) {
      expect(commandId).toBeTruthy();
      expect(taskLabel).toBeTruthy();
    }
  });
});
