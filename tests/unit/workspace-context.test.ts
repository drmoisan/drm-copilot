import { afterEach, describe, expect, it, jest } from "@jest/globals";

jest.mock(
  "vscode",
  () => ({
    workspace: {
      workspaceFolders: [],
    },
    window: {
      showWorkspaceFolderPick: jest.fn(),
      showErrorMessage: jest.fn(),
    },
  }),
  { virtual: true },
);

import * as vscode from "vscode";

import { resolveWorkspaceFolder } from "../../src/utilities/workspace-context";

afterEach(() => {
  jest.resetAllMocks();
});

describe("workspace-context", () => {
  it("single-root returns only folder", async () => {
    const folder = {
      index: 0,
      name: "root",
      uri: { fsPath: "/repo" },
    } as unknown as import("vscode").WorkspaceFolder;

    (
      vscode.workspace as unknown as { workspaceFolders: unknown }
    ).workspaceFolders = [folder];

    const result = await resolveWorkspaceFolder();

    expect(result).toBe(folder);
    expect(vscode.window.showWorkspaceFolderPick).not.toHaveBeenCalled();
  });

  it("no workspace returns undefined", async () => {
    (
      vscode.workspace as unknown as { workspaceFolders: unknown }
    ).workspaceFolders = [];

    const result = await resolveWorkspaceFolder();

    expect(result).toBeUndefined();
    expect(vscode.window.showErrorMessage).toHaveBeenCalled();
    expect(vscode.window.showWorkspaceFolderPick).not.toHaveBeenCalled();
  });
});
