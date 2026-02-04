import { afterEach, describe, expect, it, jest } from "@jest/globals";

jest.mock(
  "vscode",
  () => ({
    window: {
      showInputBox: jest.fn(),
    },
  }),
  { virtual: true },
);

import * as vscode from "vscode";

import { collectCommandInputs } from "../../src/utilities/input-collection";

afterEach(() => {
  jest.resetAllMocks();
});

describe("input-collection", () => {
  it("cancel returns undefined", async () => {
    (
      vscode.window.showInputBox as jest.MockedFunction<
        typeof vscode.window.showInputBox
      >
    ).mockResolvedValue(undefined);

    const result = await collectCommandInputs(
      "drm-copilot.devNewPotentialEntry",
    );

    expect(result).toBeUndefined();
  });
});
