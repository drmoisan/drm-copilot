import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { createRepoAutomationService } from "../src/repo-automation-service";
import {
  dispatchRepoAutomationTool,
  listRepoAutomationTools,
} from "../src/mcp-tools";
import { resolveRenderSubagentTreeToolInput } from "../src/mcp-tool-inputs-subagent-tree";
import { buildSubagentTree, formatTree } from "../src/lib/subagent-tree";
import { InMemoryFileSystem } from "./lib/subagent-tree/in-memory-file-system";

/** Fake CLAUDE config dir; its `projects` subfolder is the projects root. */
const CONFIG_DIR = "/claude-config";
const PROJECTS_ROOT = `${CONFIG_DIR}/projects`;
/** Workspace root and its encoded directory name. */
const WORKSPACE_ROOT = "C:\\ws\\repo";
const ENCODED_DIR = "C--ws-repo";
/** A valid (UUIDv4-shaped) session id. */
const VALID_ID = "ef8e8029-7c73-4346-80c7-5b0ad94b33fe";

/** Build a root transcript line carrying one `Agent` tool-use block. */
function agentToolUseLine(model: string, toolUseId: string): string {
  return JSON.stringify({
    message: {
      model,
      content: [{ type: "tool_use", name: "Agent", id: toolUseId }],
    },
  });
}

/**
 * Register a root transcript plus one subagent under the encoded directory,
 * returning the root transcript path. Mirrors the command-test fixture so
 * `formatTree` renders a root line plus one indented child line.
 */
function seedSessionWithSubagent(fileSystem: InMemoryFileSystem): string {
  const rootPath = `${PROJECTS_ROOT}/${ENCODED_DIR}/${VALID_ID}.jsonl`;
  fileSystem.addFile(
    rootPath,
    agentToolUseLine("claude-sonnet-5", "toolu_child"),
  );
  fileSystem.addFile(
    `${PROJECTS_ROOT}/${ENCODED_DIR}/${VALID_ID}/subagents/agent-child.meta.json`,
    JSON.stringify({
      agentType: "atomic-executor",
      description: "Execute plan",
      toolUseId: "toolu_child",
      spawnDepth: 1,
    }),
  );
  fileSystem.addFile(
    `${PROJECTS_ROOT}/${ENCODED_DIR}/${VALID_ID}/subagents/agent-child.jsonl`,
    JSON.stringify({ message: { model: "claude-sonnet-5" } }),
  );
  return rootPath;
}

function createService(fileSystem: InMemoryFileSystem) {
  return createRepoAutomationService({
    extensionRoot: "/ext",
    output: { appendLine: (): void => undefined },
    fileSystem,
  });
}

describe("render_subagent_tree service + dispatch", () => {
  const originalConfigDir = process.env["CLAUDE_CONFIG_DIR"];

  beforeEach(() => {
    process.env["CLAUDE_CONFIG_DIR"] = CONFIG_DIR;
  });

  afterEach(() => {
    if (originalConfigDir === undefined) {
      delete process.env["CLAUDE_CONFIG_DIR"];
    } else {
      process.env["CLAUDE_CONFIG_DIR"] = originalConfigDir;
    }
    jest.clearAllMocks();
  });

  it("returns ok:true with rendered_tree and a summary naming the session id and transcript path for a valid id", async () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();
    const rootPath = seedSessionWithSubagent(fileSystem);
    const service = createService(fileSystem);
    const expectedTree = formatTree(
      buildSubagentTree(rootPath, { fileSystem }),
    );

    // Act
    const result = await dispatchRepoAutomationTool(
      "render_subagent_tree",
      { workspace_root: WORKSPACE_ROOT, session_id: VALID_ID },
      service,
    );

    // Assert
    expect(result.ok).toBe(true);
    expect(result.tool).toBe("render_subagent_tree");
    expect(result.rendered_tree).toBe(expectedTree);
    expect(result.summary).toContain(VALID_ID);
    expect(result.summary).toContain(rootPath);
  });

  it("is reachable through dispatchRepoAutomationTool and echoes the requested workspace root", async () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();
    seedSessionWithSubagent(fileSystem);
    const service = createService(fileSystem);

    // Act
    const result = await dispatchRepoAutomationTool(
      "render_subagent_tree",
      { workspace_root: WORKSPACE_ROOT, session_id: VALID_ID },
      service,
    );

    // Assert: the dispatch case wired the tool through to the service.
    expect(result.ok).toBe(true);
    expect(result.workspace_root).toBe(WORKSPACE_ROOT);
  });

  it("returns ok:false naming the searched directory for a valid but unknown id", async () => {
    // Arrange: a matching directory exists but lacks the requested transcript.
    const fileSystem = new InMemoryFileSystem();
    fileSystem.addFile(
      `${PROJECTS_ROOT}/${ENCODED_DIR}/another-session.jsonl`,
      "",
    );
    const service = createService(fileSystem);

    // Act
    const result = await dispatchRepoAutomationTool(
      "render_subagent_tree",
      { workspace_root: WORKSPACE_ROOT, session_id: VALID_ID },
      service,
    );

    // Assert
    expect(result.ok).toBe(false);
    expect(result.summary).toContain(`${PROJECTS_ROOT}/${ENCODED_DIR}`);
    expect(result.rendered_tree).toBeUndefined();
  });

  it("returns ok:false naming the validation rule for a malformed id and never touches the filesystem", async () => {
    // Arrange: spy on the filesystem seam methods the resolver could use.
    const fileSystem = new InMemoryFileSystem();
    const listSpy = jest.spyOn(fileSystem, "listDirectory");
    const isFileSpy = jest.spyOn(fileSystem, "isFile");
    const service = createService(fileSystem);

    // Act: an id with an out-of-charset underscore.
    const result = await dispatchRepoAutomationTool(
      "render_subagent_tree",
      { workspace_root: WORKSPACE_ROOT, session_id: "abcd_efgh" },
      service,
    );

    // Assert
    expect(result.ok).toBe(false);
    expect(result.summary).toMatch(/must match \^\[0-9A-Za-z-\]\{8,64\}\$/);
    expect(listSpy).not.toHaveBeenCalled();
    expect(isFileSpy).not.toHaveBeenCalled();
  });
});

describe("listRepoAutomationTools advertisement", () => {
  it("advertises render_subagent_tree with required session_id and workspace_root", () => {
    // Act
    const definition = listRepoAutomationTools().find(
      (tool) => tool.name === "render_subagent_tree",
    );

    // Assert
    expect(definition).toBeDefined();
    expect(definition?.inputSchema.required).toEqual([
      "workspace_root",
      "session_id",
    ]);
    expect(definition?.inputSchema.additionalProperties).toBe(false);
    expect(
      Object.keys(definition?.inputSchema.properties ?? {}).sort(),
    ).toEqual(["session_id", "workspace_root"]);
  });
});

describe("resolveRenderSubagentTreeToolInput", () => {
  it("throws when session_id is missing", () => {
    expect(() =>
      resolveRenderSubagentTreeToolInput({ workspace_root: WORKSPACE_ROOT }),
    ).toThrow(/session_id/);
  });

  it("normalizes a present session_id and workspace_root", () => {
    const input = resolveRenderSubagentTreeToolInput({
      workspace_root: WORKSPACE_ROOT,
      session_id: VALID_ID,
    });
    expect(input).toEqual({
      workspaceRoot: WORKSPACE_ROOT,
      sessionId: VALID_ID,
    });
  });

  it("falls back to the provided workspace root when workspace_root is omitted", () => {
    const input = resolveRenderSubagentTreeToolInput(
      { session_id: VALID_ID },
      "/fallback-root",
    );
    expect(input.workspaceRoot).toBe("/fallback-root");
    expect(input.sessionId).toBe(VALID_ID);
  });
});
