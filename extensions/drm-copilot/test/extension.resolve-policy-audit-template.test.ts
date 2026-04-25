import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import {
  activateAndGetHandler,
  openTextDocumentMock,
  resetExtensionHarnessState,
  showQuickPickMock,
  showTextDocumentMock,
} from "./extension-test-harness";

const fsMock = jest.requireMock("node:fs") as {
  copyFileSync: jest.MockedFunction<
    (source: string, destination: string) => void
  >;
  mkdirSync: jest.MockedFunction<
    (filePath: string, options?: { recursive?: boolean }) => void
  >;
};

describe("drm-copilot resolvePolicyAuditTemplateAsset command", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
    fsMock.copyFileSync.mockReset();
    fsMock.mkdirSync.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers resolvePolicyAuditTemplateAsset", () => {
    activateAndGetHandler(
      "drmCopilotExtension.resolvePolicyAuditTemplateAsset",
    );
  });

  it("prompts for an asset in interactive mode and opens the bundled document", async () => {
    showQuickPickMock.mockResolvedValueOnce("agents");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolvePolicyAuditTemplateAsset",
    );
    await handler();

    expect(showQuickPickMock).toHaveBeenCalledWith(
      ["template", "agents", "code-review-template", "feature-audit-template"],
      expect.objectContaining({
        title: "drm-copilot: Resolve Policy Audit Template Asset",
      }),
    );
    expect(openTextDocumentMock).toHaveBeenCalledWith(
      expect.objectContaining({
        fsPath: "C:/extension/resources/templates/policy_audit/AGENTS.md",
      }),
    );
    expect(showTextDocumentMock).toHaveBeenCalledTimes(1);
    expect(fsMock.copyFileSync).not.toHaveBeenCalled();
  });

  it("opens the bundled document directly when -asset is supplied without -target", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolvePolicyAuditTemplateAsset",
    );
    await handler(["-asset", "code-review-template"]);

    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(openTextDocumentMock).toHaveBeenCalledWith(
      expect.objectContaining({
        fsPath:
          "C:/extension/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md",
      }),
    );
    expect(showTextDocumentMock).toHaveBeenCalledTimes(1);
  });

  it("copies to the requested target path without opening the document when -target is supplied", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolvePolicyAuditTemplateAsset",
    );
    await handler([
      "-asset",
      "agents",
      "-target",
      "docs/policy-audit/AGENTS.md",
    ]);

    expect(fsMock.mkdirSync).toHaveBeenCalledWith(
      "C:/workspace/docs/policy-audit",
      {
        recursive: true,
      },
    );
    expect(fsMock.copyFileSync).toHaveBeenCalledWith(
      "C:/extension/resources/templates/policy_audit/AGENTS.md",
      "C:/workspace/docs/policy-audit/AGENTS.md",
    );
    expect(openTextDocumentMock).not.toHaveBeenCalled();
    expect(showTextDocumentMock).not.toHaveBeenCalled();
  });
});
