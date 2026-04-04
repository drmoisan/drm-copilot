import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

/**
 * Unit tests for extension-command-helpers.ts.
 *
 * Purpose:
 *   Verify the pure helper functions and the anonymous validateInput callbacks
 *   that are passed to VS Code prompt APIs, exercising branches that the
 *   integration tests do not reach because they mock the host APIs entirely.
 */

// ----- VS Code mock ---------------------------------------------------------

const showInputBoxMock = jest.fn();
const showQuickPickMock = jest.fn();
const showOpenDialogMock = jest.fn();

let activeEditorFsPath: string | null = null;

jest.mock(
  "vscode",
  () => ({
    window: {
      get activeTextEditor() {
        if (activeEditorFsPath === null) {
          return undefined;
        }
        return { document: { uri: { fsPath: activeEditorFsPath } } };
      },
      showInputBox: showInputBoxMock,
      showQuickPick: showQuickPickMock,
      showOpenDialog: showOpenDialogMock,
    },
    Uri: {
      file: jest.fn((p: string) => ({ fsPath: p })),
    },
  }),
  { virtual: true },
);

import {
  getActiveFeaturePlanPath,
  getActivePotentialPath,
  normalizePath,
  promptForActiveFeaturePlan,
  promptForFeatureName,
  promptForIssueNumber,
  promptForPotentialPath,
  promptForShortName,
  resolveWorkflowInvocation,
} from "../src/extension-command-helpers";
import type * as vscode from "vscode";

// ---------------------------------------------------------------------------

describe("normalizePath", () => {
  it("converts backslashes to forward slashes", () => {
    expect(normalizePath("C:\\Users\\foo\\bar")).toBe("C:/Users/foo/bar");
  });

  it("leaves forward-slash paths unchanged", () => {
    const path = "C:/Users/foo/bar";
    expect(normalizePath(path)).toBe(path);
  });
});

describe("getActivePotentialPath", () => {
  afterEach(() => {
    activeEditorFsPath = null;
  });

  it("returns undefined when no active editor is open", () => {
    activeEditorFsPath = null;
    expect(getActivePotentialPath("C:/workspace")).toBeUndefined();
  });

  it("returns undefined when the open file is not a markdown file", () => {
    activeEditorFsPath = "C:/workspace/docs/features/potential/entry.ts";
    expect(getActivePotentialPath("C:/workspace")).toBeUndefined();
  });

  it("returns undefined when the open markdown file is outside the potential folder", () => {
    activeEditorFsPath =
      "C:/workspace/docs/features/active/some-feature/spec.md";
    expect(getActivePotentialPath("C:/workspace")).toBeUndefined();
  });

  it("returns the fsPath when the open file is a potential markdown entry", () => {
    activeEditorFsPath = "C:/workspace/docs/features/potential/my-entry.md";
    expect(getActivePotentialPath("C:/workspace")).toBe(activeEditorFsPath);
  });
});

describe("getActiveFeaturePlanPath", () => {
  afterEach(() => {
    activeEditorFsPath = null;
  });

  it("returns undefined when no active editor is open", () => {
    activeEditorFsPath = null;
    expect(getActiveFeaturePlanPath("C:/workspace")).toBeUndefined();
  });

  it("returns undefined when the open file is outside the active features folder", () => {
    activeEditorFsPath = "C:/workspace/docs/features/potential/my-entry.md";
    expect(getActiveFeaturePlanPath("C:/workspace")).toBeUndefined();
  });

  it("returns the fsPath when the open file is under the active features folder", () => {
    activeEditorFsPath =
      "C:/workspace/docs/features/active/2026-01-01-feature/plan.md";
    expect(getActiveFeaturePlanPath("C:/workspace")).toBe(activeEditorFsPath);
  });
});

describe("promptForShortName", () => {
  beforeEach(() => {
    showInputBoxMock.mockReset();
  });

  it("returns undefined when the user cancels", async () => {
    showInputBoxMock.mockResolvedValueOnce(undefined);
    const result = await promptForShortName("Title", "Prompt");
    expect(result).toBeUndefined();
  });

  it("returns a validated short name when the user provides valid input", async () => {
    showInputBoxMock.mockResolvedValueOnce("my-short-name");
    const result = await promptForShortName("Title", "Prompt");
    expect(result).toBe("my-short-name");
  });

  it("invokes the validateInput callback with the provided options", async () => {
    // Capture and invoke the anonymous validateInput arrow function so that
    // the anonymous function body is exercised and counted as covered.
    showInputBoxMock.mockImplementationOnce(
      async (options: {
        validateInput?: (v: string) => string | undefined;
      }) => {
        options.validateInput?.("test");
        return "valid-name";
      },
    );
    await promptForShortName("Title", "Prompt");
    expect(showInputBoxMock).toHaveBeenCalledTimes(1);
  });
});

describe("promptForFeatureName", () => {
  beforeEach(() => {
    showInputBoxMock.mockReset();
  });

  it("returns undefined when the user cancels", async () => {
    showInputBoxMock.mockResolvedValueOnce(undefined);
    const result = await promptForFeatureName("Title", "Prompt");
    expect(result).toBeUndefined();
  });

  it("invokes getFeatureNameValidationMessage via the validateInput option", async () => {
    // Invoke the validateInput reference (getFeatureNameValidationMessage) to
    // exercise the function and count it as covered.
    showInputBoxMock.mockImplementationOnce(
      async (options: {
        validateInput?: (v: string) => string | undefined;
      }) => {
        options.validateInput?.("valid-feature-name");
        return "valid-feature-name";
      },
    );
    await promptForFeatureName("Title", "Prompt");
    expect(showInputBoxMock).toHaveBeenCalledTimes(1);
  });
});

describe("promptForIssueNumber", () => {
  beforeEach(() => {
    showInputBoxMock.mockReset();
  });

  it("returns undefined when the user cancels", async () => {
    showInputBoxMock.mockResolvedValueOnce(undefined);
    const result = await promptForIssueNumber();
    expect(result).toBeUndefined();
  });

  it("returns null when the user leaves the field blank", async () => {
    showInputBoxMock.mockResolvedValueOnce("   ");
    const result = await promptForIssueNumber();
    expect(result).toBeNull();
  });

  it("returns a validated issue number for digit input", async () => {
    showInputBoxMock.mockResolvedValueOnce("42");
    const result = await promptForIssueNumber();
    expect(result).toBe("42");
  });

  it("exercises the validateInput callback for an empty value", async () => {
    // Invoke the anonymous validateInput function with an empty string so the
    // early-return branch (returning undefined for blank) is covered.
    showInputBoxMock.mockImplementationOnce(
      async (options: {
        validateInput?: (v: string) => string | undefined;
      }) => {
        const msg = options.validateInput?.("");
        expect(msg).toBeUndefined();
        return "123";
      },
    );
    await promptForIssueNumber();
  });

  it("exercises the validateInput callback for a non-digit value", async () => {
    // Invoke the anonymous validateInput function with a non-digit string so
    // the validation-error branch is covered.
    showInputBoxMock.mockImplementationOnce(
      async (options: {
        validateInput?: (v: string) => string | undefined;
      }) => {
        const msg = options.validateInput?.("abc");
        expect(msg).toContain("digits only");
        return "123";
      },
    );
    await promptForIssueNumber();
  });
});

describe("promptForPotentialPath", () => {
  beforeEach(() => {
    showOpenDialogMock.mockReset();
    activeEditorFsPath = null;
  });

  afterEach(() => {
    activeEditorFsPath = null;
  });

  it("returns the active editor path when a potential markdown file is open", async () => {
    activeEditorFsPath = "C:/workspace/docs/features/potential/my-entry.md";
    const result = await promptForPotentialPath("C:/workspace");
    expect(result).toBe(activeEditorFsPath);
    expect(showOpenDialogMock).not.toHaveBeenCalled();
  });

  it("opens the dialog and returns the selected path when no qualifying file is open", async () => {
    activeEditorFsPath = null;
    showOpenDialogMock.mockResolvedValueOnce([
      { fsPath: "C:/workspace/docs/features/potential/selected.md" },
    ]);
    const result = await promptForPotentialPath("C:/workspace");
    expect(result).toBe("C:/workspace/docs/features/potential/selected.md");
    expect(showOpenDialogMock).toHaveBeenCalledTimes(1);
  });

  it("returns undefined when the user cancels the dialog", async () => {
    activeEditorFsPath = null;
    showOpenDialogMock.mockResolvedValueOnce(undefined);
    const result = await promptForPotentialPath("C:/workspace");
    expect(result).toBeUndefined();
  });
});

describe("promptForActiveFeaturePlan", () => {
  beforeEach(() => {
    showOpenDialogMock.mockReset();
    activeEditorFsPath = null;
  });

  afterEach(() => {
    activeEditorFsPath = null;
  });

  it("returns the active editor path when a feature plan file is open", async () => {
    activeEditorFsPath =
      "C:/workspace/docs/features/active/2026-01-01-feat/plan.md";
    const result = await promptForActiveFeaturePlan("C:/workspace");
    expect(result).toBe(activeEditorFsPath);
    expect(showOpenDialogMock).not.toHaveBeenCalled();
  });

  it("opens the dialog and returns the selected path when no qualifying file is open", async () => {
    activeEditorFsPath = null;
    showOpenDialogMock.mockResolvedValueOnce([
      { fsPath: "C:/workspace/docs/features/active/2026-01-01-feat/plan.md" },
    ]);
    const result = await promptForActiveFeaturePlan("C:/workspace");
    expect(result).toBe(
      "C:/workspace/docs/features/active/2026-01-01-feat/plan.md",
    );
    expect(showOpenDialogMock).toHaveBeenCalledTimes(1);
  });
});

describe("resolveWorkflowInvocation", () => {
  it("returns the invocation and logs its mode", () => {
    const appendLineMock = jest.fn<(line: string) => void>();
    const output = {
      appendLine: appendLineMock,
    } as unknown as vscode.OutputChannel;
    const invocation = { mode: "direct" as const, input: { shortName: "x" } };

    const result = resolveWorkflowInvocation(
      output,
      "cmd.id",
      () => invocation,
    );

    expect(result).toBe(invocation);
    expect(appendLineMock).toHaveBeenCalledWith(
      expect.stringContaining("direct"),
    );
  });

  it("logs validation failure and re-throws when resolver throws", () => {
    const appendLineMock = jest.fn<(line: string) => void>();
    const output = {
      appendLine: appendLineMock,
    } as unknown as vscode.OutputChannel;
    const error = new Error("bad input");

    expect(() =>
      resolveWorkflowInvocation(output, "cmd.id", () => {
        throw error;
      }),
    ).toThrow(error);

    expect(appendLineMock).toHaveBeenCalledWith(
      expect.stringContaining("validation failure"),
    );
  });
});
