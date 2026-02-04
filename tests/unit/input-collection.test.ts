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

import { collectCommandInputs } from "../../src/utilities/input-collection.ts";

afterEach(() => {
  jest.resetAllMocks();
});

describe("input-collection", () => {
  it("cancel returns undefined", async () => {
    (vscode.window.showInputBox as jest.Mock).mockResolvedValue(undefined);

    const result = await collectCommandInputs(
      "drm-copilot.devNewPotentialEntry",
    );

    expect(result).toBeUndefined();
  });
});
