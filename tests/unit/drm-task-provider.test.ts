import { afterEach, describe, expect, jest, test } from "@jest/globals";

import { createDrmCopilotTaskProvider } from "../../src/drm-task-provider";
import type { TaskCommandId } from "../../src/task-command-map";
import * as taskCommandMap from "../../src/task-command-map";
import * as vscode from "vscode";

jest.mock("../../src/task-command-map", () => ({
  getAllTaskCommandIds: jest.fn(),
  getTaskExecutionSpec: jest.fn(),
  getTaskLabelForCommandId: jest.fn(),
  getDefaultInputValuesForCommand: jest.fn(),
  resolveTaskArgs: jest.fn(),
}));

jest.mock(
  "vscode",
  () => {
    class ShellExecution {
      command: string;
      args: string[];
      options: { cwd?: string };

      constructor(command: string, args: string[], options: { cwd?: string }) {
        this.command = command;
        this.args = args;
        this.options = options;
      }
    }

    class Task {
      definition: object;
      scope: object;
      name: string;
      source: string;
      execution: ShellExecution;

      constructor(
        definition: object,
        scope: object,
        name: string,
        source: string,
        execution: ShellExecution,
      ) {
        this.definition = definition;
        this.scope = scope;
        this.name = name;
        this.source = source;
        this.execution = execution;
      }
    }

    return {
      ShellExecution,
      Task,
      workspace: {
        workspaceFolders: [{ uri: { fsPath: "C:/repo" } }],
        asRelativePath: jest.fn(),
      },
      window: {
        activeTextEditor: undefined,
      },
    };
  },
  { virtual: true },
);

describe("drm-task-provider", () => {
  const workspace = vscode.workspace as unknown as {
    workspaceFolders?: Array<{ uri: { fsPath: string } }>;
    asRelativePath: (pathOrUri: string | vscode.Uri) => string;
  };
  const window = vscode.window as unknown as {
    activeTextEditor?: vscode.TextEditor;
  };
  const defaultWorkspaceFolders = [{ uri: { fsPath: "C:/repo" } }];
  type MockTask = {
    name: string;
    source: string;
    execution: { command: string; args: string[]; options: { cwd?: string } };
  };
  const createContext = () =>
    ({
      asAbsolutePath: jest.fn().mockReturnValue("C:\\ext"),
    }) as unknown as vscode.ExtensionContext;

  afterEach(() => {
    jest.resetAllMocks();
    workspace.workspaceFolders = defaultWorkspaceFolders;
    delete window.activeTextEditor;
    workspace.asRelativePath = jest.fn((pathOrUri: string | vscode.Uri) =>
      typeof pathOrUri === "string" ? pathOrUri : pathOrUri.fsPath,
    );
  });

  test("provideTasks returns tasks only when spec, label, and workspace exist", () => {
    const context = createContext();
    const commandWithSpec: TaskCommandId = "drm-copilot.qcBlackFormat";
    const commandWithoutSpec: TaskCommandId = "drm-copilot.qcRuffLint";

    jest
      .mocked(taskCommandMap.getAllTaskCommandIds)
      .mockReturnValue([commandWithSpec, commandWithoutSpec]);
    jest
      .mocked(taskCommandMap.getTaskExecutionSpec)
      .mockImplementation((commandId) =>
        commandId === commandWithSpec
          ? { command: "echo", args: ["${extensionRoot}/tool", "--flag"] }
          : undefined,
      );
    jest
      .mocked(taskCommandMap.getTaskLabelForCommandId)
      .mockImplementation((commandId) =>
        commandId === commandWithSpec ? "My Task" : undefined,
      );
    jest
      .mocked(taskCommandMap.getDefaultInputValuesForCommand)
      .mockReturnValue({});

    jest
      .mocked(taskCommandMap.resolveTaskArgs)
      .mockImplementation((args, resolveContext) => {
        expect(args).toEqual(["C:/ext/tool", "--flag"]);
        expect(resolveContext.extensionRoot).toBe("C:/ext");
        expect(resolveContext.workspaceRoot).toBe("C:/repo");
        return ["resolved-arg"];
      });

    const provider = createDrmCopilotTaskProvider(context);
    const tasks = provider.provideTasks({} as vscode.CancellationToken);

    expect(tasks).toHaveLength(1);
    if (!Array.isArray(tasks)) {
      throw new Error("Expected provideTasks to return an array of tasks.");
    }
    const [task] = tasks as MockTask[];
    if (!task) {
      throw new Error("Expected a task to be created for the command.");
    }
    expect(task.name).toBe("My Task");
    expect(task.source).toBe("drm-copilot");
    expect(task.execution.command).toBe("echo");
    expect(task.execution.args).toEqual(["resolved-arg"]);
    expect(task.execution.options).toEqual({ cwd: "C:/repo" });
  });

  test("provideTasks returns empty when workspace is missing", () => {
    const context = createContext();

    workspace.workspaceFolders = [];

    jest
      .mocked(taskCommandMap.getAllTaskCommandIds)
      .mockReturnValue(["drm-copilot.qcBlackFormat"]);
    jest
      .mocked(taskCommandMap.getTaskExecutionSpec)
      .mockReturnValue({ command: "echo", args: [] });
    jest
      .mocked(taskCommandMap.getTaskLabelForCommandId)
      .mockReturnValue("My Task");
    jest
      .mocked(taskCommandMap.getDefaultInputValuesForCommand)
      .mockReturnValue({});

    const provider = createDrmCopilotTaskProvider(context);

    expect(provider.provideTasks({} as vscode.CancellationToken)).toEqual([]);
    expect(taskCommandMap.resolveTaskArgs).not.toHaveBeenCalled();
  });

  test("provideTasks skips commands without execution specs or labels", () => {
    const context = createContext();
    const commandMissingSpec: TaskCommandId = "drm-copilot.qcBlackFormat";
    const commandMissingLabel: TaskCommandId = "drm-copilot.qcRuffLint";

    jest
      .mocked(taskCommandMap.getAllTaskCommandIds)
      .mockReturnValue([commandMissingSpec, commandMissingLabel]);
    jest
      .mocked(taskCommandMap.getTaskExecutionSpec)
      .mockImplementation((commandId) =>
        commandId === commandMissingSpec
          ? undefined
          : { command: "echo", args: [] },
      );
    jest
      .mocked(taskCommandMap.getTaskLabelForCommandId)
      .mockImplementation((commandId) =>
        commandId === commandMissingSpec ? "My Task" : undefined,
      );
    jest
      .mocked(taskCommandMap.getDefaultInputValuesForCommand)
      .mockReturnValue({});

    const provider = createDrmCopilotTaskProvider(context);

    expect(provider.provideTasks({} as vscode.CancellationToken)).toEqual([]);
  });

  test("provideTasks includes active editor context when resolving args", () => {
    const context = createContext();

    window.activeTextEditor = {
      document: { uri: { fsPath: "C:/repo/docs/readme.md" } },
    } as unknown as vscode.TextEditor;
    workspace.asRelativePath = jest
      .fn((pathOrUri: string | vscode.Uri) =>
        typeof pathOrUri === "string" ? pathOrUri : pathOrUri.fsPath,
      )
      .mockReturnValue("docs/readme.md");

    jest
      .mocked(taskCommandMap.getAllTaskCommandIds)
      .mockReturnValue(["drm-copilot.qcBlackFormat"]);
    jest.mocked(taskCommandMap.getTaskExecutionSpec).mockReturnValue({
      command: "echo",
      args: ["${file}", "${relativeFile}"],
    });
    jest
      .mocked(taskCommandMap.getTaskLabelForCommandId)
      .mockReturnValue("My Task");
    jest
      .mocked(taskCommandMap.getDefaultInputValuesForCommand)
      .mockReturnValue({});

    jest
      .mocked(taskCommandMap.resolveTaskArgs)
      .mockImplementation((_args, resolveContext) => {
        expect(resolveContext.activeFilePath).toBe("C:/repo/docs/readme.md");
        expect(resolveContext.activeRelativePath).toBe("docs/readme.md");
        return ["resolved"];
      });

    const provider = createDrmCopilotTaskProvider(context);
    const tasks = provider.provideTasks({} as vscode.CancellationToken);

    expect(tasks).toHaveLength(1);
  });

  test("resolveTask returns undefined", () => {
    const context = createContext();

    const provider = createDrmCopilotTaskProvider(context);

    expect(
      provider.resolveTask({} as vscode.Task, {} as vscode.CancellationToken),
    ).toBeUndefined();
  });
});
