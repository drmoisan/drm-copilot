import { beforeEach, describe, expect, it, jest } from "@jest/globals";

import { InMemoryPushDownFileSystem } from "./lib/push-down/push-down.test-helpers";

const appendLineMock = jest.fn<(line: string) => void>();

jest.mock("vscode", () => ({}), { virtual: true });

import { createRepoAutomationService } from "../src/repo-automation-service";

const EXT = "C:/extension";
const WS = "C:/workspace";
const BUNDLE = `${EXT}/resources/codex-and-agents-customizations`;

function seedCodexBundle(): InMemoryPushDownFileSystem {
  const fs = new InMemoryPushDownFileSystem();
  fs.seedDir(WS);
  fs.seedFile(`${BUNDLE}/.codex/config.toml`, "core\n");
  fs.seedFile(`${BUNDLE}/.agents/skills/typescript/SKILL.md`, "ts\n");
  fs.seedFile(`${BUNDLE}/.agents/skills/csharp/SKILL.md`, "modern\n");
  fs.seedFile(
    `${BUNDLE}/.agents-variants/csharp-legacy/skills/csharp/SKILL.md`,
    "legacy\n",
  );
  fs.seedFile(
    `${BUNDLE}/pack-manifests/core.json`,
    JSON.stringify({
      name: "core",
      paths: [".codex/config.toml"],
    }),
  );
  fs.seedFile(
    `${BUNDLE}/pack-manifests/csharp-legacy.json`,
    JSON.stringify({
      name: "csharp-legacy",
      paths: [".agents/skills/csharp/SKILL.md"],
    }),
  );
  return fs;
}

describe("repo automation service pushDownCodexAndAgentsCustomizations", () => {
  beforeEach(() => {
    appendLineMock.mockReset();
  });

  it("threads packs, csharpVariant, and memoryMode into the in-process port", async () => {
    const pushDownFileSystem = seedCodexBundle();
    const service = createRepoAutomationService({
      extensionRoot: EXT,
      output: { appendLine: appendLineMock },
      pushDownFileSystem,
    });

    await service.pushDownCodexAndAgentsCustomizations({
      workspaceRoot: WS,
      packs: ["core", "csharp-legacy"],
      csharpVariant: "legacy",
      memoryMode: "skip",
    });

    expect(
      pushDownFileSystem.readTextFile(`${WS}/.agents/skills/csharp/SKILL.md`),
    ).toBe("legacy\n");
    expect(pushDownFileSystem.isFile(`${WS}/.codex/config.toml`)).toBe(true);
    expect(
      pushDownFileSystem.isFile(`${WS}/.agents/skills/typescript/SKILL.md`),
    ).toBe(false);
  });
});
