/**
 * Packaging contracts for the issue #980 discovery resources (P10-T2).
 *
 * The VSIX is assembled by vsce from `.vscodeignore`, and the standalone npm
 * package by `packages/mcp-server/prepack.cjs` plus its `files` allowlist. Both
 * must carry every published native resource (GitHub hooks, Claude and Codex
 * hooks, the shared PowerShell helpers, the routing config, setup templates)
 * while excluding every Python source, and the standalone server must bundle
 * the same tool set the extension registers without importing the VS Code
 * host. Every assertion reads committed files; no build output is required.
 */

import { afterAll, describe, expect, it, jest } from "@jest/globals";
import type * as NodeFs from "node:fs";
import * as path from "node:path";

import {
  DISCOVERY_GATEWAY_MODULE,
  DISCOVERY_WHEEL_FILE_NAME,
} from "../../src/discovery-runtime";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../../src/mcp-repo-automation-tool-definitions";
import { REPO_AUTOMATION_TOOLS } from "../../src/repo-automation-tool-names";

interface PrepackModule {
  readonly SOURCE_DIR: string;
  readonly shouldCopy: (source: string) => boolean;
}

interface McpPackageManifest {
  readonly files: ReadonlyArray<string>;
  readonly bin: Readonly<Record<string, string>>;
  readonly scripts: Readonly<Record<string, string>>;
  readonly dependencies?: Readonly<Record<string, string>>;
  readonly peerDependencies?: Readonly<Record<string, string>>;
  readonly engines: Readonly<Record<string, string>>;
}

interface ExtensionManifest {
  readonly contributes: {
    readonly mcpServerDefinitionProviders: ReadonlyArray<{
      readonly id: string;
    }>;
  };
}

// eslint-disable-next-line @typescript-eslint/no-require-imports -- the spy must patch the shared CommonJS node:fs object that prepack.cjs destructures at load; an ES namespace import yields an interop copy the spy would not reach
const nodeFs = require("node:fs") as typeof NodeFs;
const cpSyncSpy = jest.spyOn(nodeFs, "cpSync").mockImplementation(() => {
  return undefined;
});
const PREPACK_PATH = "../../../../packages/mcp-server/prepack.cjs";
// eslint-disable-next-line @typescript-eslint/no-require-imports -- prepack.cjs is a CommonJS build script run by node; require loads the same module object that packaging executes
const prepack = require(PREPACK_PATH) as PrepackModule;

const EXTENSION_ROOT = path.resolve(__dirname, "..", "..");
const REPO_ROOT = path.resolve(EXTENSION_ROOT, "..", "..");
const RESOURCES = prepack.SOURCE_DIR;
const MCP_PACKAGE_ROOT = path.join(REPO_ROOT, "packages", "mcp-server");

const ROLES = [
  "legacy-parity-analyst",
  "runtime-characterization-analyst",
  "requirements-reconciler",
  "migration-coverage-reviewer",
] as const;
const SHARED_HELPERS = [
  "DiscoveryAuthority.psd1",
  "DiscoveryAuthority.psm1",
  "DiscoveryAuthorization.psm1",
  "DiscoveryCapability.psm1",
  "DiscoveryEncoding.psm1",
  "DiscoveryManifest.psm1",
  "DiscoveryPayload.psm1",
  "DiscoveryPlanning.psm1",
  "DiscoveryStart.psm1",
  "DiscoveryStartRecord.psm1",
  "DiscoveryStop.psm1",
] as const;
const GITHUB_HOOKS = [
  "discovery-agent-start.ps1",
  "discovery-pre-tool.ps1",
  "discovery-planning.ps1",
  "discovery-agent-stop.ps1",
  "discovery-capability-probe.ps1",
  "discovery.json",
] as const;
const CLAUDE_HOOKS = [
  "discovery-capability-probe.ps1",
  "enforce-discovery-artifact-gate.ps1",
  "enforce-discovery-planning-gate.ps1",
  "record-discovery-agent-start.ps1",
  "validate-discovery-artifact-gate.ps1",
] as const;
const CODEX_HOOKS = [
  "discovery-capability-probe.ps1",
  "discovery-start-attestation.ps1",
  "enforce-discovery-artifact-gate.ps1",
  "enforce-discovery-planning-gate.ps1",
  "validate-discovery-agent-output.ps1",
] as const;
const SETUP_RESOURCES = [
  "config/orchestration-routing.json",
  "claude-customizations/config/orchestration-routing.json",
  "claude-customizations/config/blast-radius.json",
  "claude-customizations/.claude/settings.json",
  "codex-and-agents-customizations/.codex/config.toml",
  "templates/new-claude-worktree-session.ps1",
  "templates/run-poshqc-test.ps1",
  "templates/policy_audit/AGENTS.md",
] as const;

/** Every published discovery resource, as a resources-root-relative POSIX path. */
function publishedDiscoveryResources(): ReadonlyArray<string> {
  const paths: string[] = [];
  // Shared helpers publish through the Codex virtual lib root and the Claude bundle.
  for (const helper of SHARED_HELPERS) {
    paths.push(`lib/discovery-validation/${helper}`);
    paths.push(
      `claude-customizations/.claude/lib/discovery-validation/${helper}`,
    );
  }
  paths.push(
    "claude-customizations/.claude/lib/discovery-validation/DiscoveryValidation.psm1",
  );
  // Native hooks and their registrations on the three hosts.
  for (const hook of GITHUB_HOOKS) {
    paths.push(`customizations/.github/hooks/${hook}`);
  }
  for (const hook of CLAUDE_HOOKS) {
    paths.push(`claude-customizations/.claude/hooks/${hook}`);
  }
  for (const hook of CODEX_HOOKS) {
    paths.push(`codex-and-agents-customizations/.codex/hooks/${hook}`);
  }
  // Roles on the three hosts.
  for (const role of ROLES) {
    paths.push(`customizations/.github/agents/${role}.agent.md`);
    paths.push(`claude-customizations/.claude/agents/${role}.md`);
    paths.push(`codex-and-agents-customizations/.codex/agents/${role}.toml`);
  }
  paths.push(...SETUP_RESOURCES);
  return paths;
}

/** Read a committed UTF-8 text file. */
function readText(filePath: string): string {
  return nodeFs.readFileSync(filePath, "utf-8");
}

/** Return the non-blank, non-comment lines of `.vscodeignore`. */
function vscodeIgnorePatterns(): ReadonlyArray<string> {
  return readText(path.join(EXTENSION_ROOT, ".vscodeignore"))
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith("#"));
}

afterAll(() => {
  cpSyncSpy.mockRestore();
});

describe("discovery resource packaging", () => {
  it("publishes every discovery resource as a committed file", () => {
    for (const relative of publishedDiscoveryResources()) {
      expect(
        nodeFs.existsSync(path.join(RESOURCES, ...relative.split("/"))),
      ).toBe(true);
    }
  });

  it("copies every discovery resource into the standalone MCP package", () => {
    // Assert: the prepack filter admits each published resource and the module copied nothing on load.
    expect(cpSyncSpy).not.toHaveBeenCalled();
    for (const relative of publishedDiscoveryResources()) {
      const source = path.join(RESOURCES, ...relative.split("/"));
      expect(prepack.shouldCopy(source)).toBe(true);
    }
  });

  it("keeps the explicit Python-source exclusion in both distributables", () => {
    const patterns = vscodeIgnorePatterns();
    expect(patterns).toContain("**/*.py");
    expect(patterns).toContain("resources/scripts/**");
    for (const relative of [
      "lib/discovery-validation/helper.py",
      "customizations/.github/hooks/handler.py",
      "scripts/dev_tools/validate_discovery_artifacts.py",
    ]) {
      expect(
        prepack.shouldCopy(path.join(RESOURCES, ...relative.split("/"))),
      ).toBe(false);
    }
  });

  it("excludes no published discovery resource from the VSIX", () => {
    // vsce matches patterns against the extension-relative path. A pattern can reach
    // beneath resources/ only when it is anchored there or begins with `**/`, so every
    // anchored pattern must be the removed Python tree and every `**/` pattern must be a
    // Python or bytecode pattern; all other patterns name top-level source and tooling.
    const pythonPatterns = new Set([
      "**/__pycache__/**",
      "**/*.pyc",
      "**/*.pyo",
      "**/*.py",
    ]);
    for (const pattern of vscodeIgnorePatterns()) {
      if (pattern.startsWith("**/")) {
        expect(pythonPatterns.has(pattern)).toBe(true);
      } else if (pattern.startsWith("resources/")) {
        expect(pattern).toBe("resources/scripts/**");
      } else {
        expect(pattern.split("/")[0]).not.toBe("resources");
      }
    }
  });

  it("ships the shared server bundle and the resources from the npm package", () => {
    const manifest = JSON.parse(
      readText(path.join(MCP_PACKAGE_ROOT, "package.json")),
    ) as McpPackageManifest;
    expect(manifest.files).toEqual(["out/mcp-server.js", "resources"]);
    expect(manifest.bin).toEqual({ "drm-copilot-mcp": "out/mcp-server.js" });
    expect(manifest.scripts["prepack"]).toBe("node prepack.cjs");
    expect(manifest.scripts["build"]).toBe("node esbuild-mcp-server.cjs");
    expect(manifest.engines["node"]).toMatch(/^>=18/);
    expect(Object.keys(manifest.dependencies ?? {})).not.toContain("vscode");
    expect(Object.keys(manifest.peerDependencies ?? {})).not.toContain(
      "vscode",
    );
  });

  it("bundles the same server entry for the extension and the standalone package", () => {
    const standalone = readText(
      path.join(MCP_PACKAGE_ROOT, "esbuild-mcp-server.cjs"),
    );
    const hosted = readText(
      path.join(EXTENSION_ROOT, "esbuild-mcp-server.cjs"),
    );
    expect(standalone).toContain(
      'entryPoints: ["../../extensions/drm-copilot/src/mcp-server.ts"]',
    );
    expect(hosted).toContain('entryPoints: ["src/mcp-server.ts"]');
    for (const config of [standalone, hosted]) {
      expect(config).toContain("bundle: true");
      expect(config).toContain('platform: "node"');
      // The VS Code host module is replaced by an empty shim; nothing in the bundle can reach it.
      expect(config).toContain("filter: /^vscode$/");
      expect(config).toContain('contents: "module.exports = {};"');
    }
  });

  it("imports no VS Code host module from the standalone server entry", () => {
    const entry = readText(path.join(EXTENSION_ROOT, "src", "mcp-server.ts"));
    expect(entry).not.toMatch(/from\s+"vscode"/);
    expect(entry).not.toMatch(/require\(\s*"vscode"\s*\)/);
    expect(entry).toContain("@modelcontextprotocol/sdk/server/stdio.js");
  });

  it("names the Python wheel runtime requirement explicitly", () => {
    const pyproject = readText(
      path.join(REPO_ROOT, "packages", "discovery-runtime", "pyproject.toml"),
    );
    const version = /^version = "([^"]+)"/m.exec(pyproject)?.[1];
    expect(version).toBeDefined();
    expect(DISCOVERY_WHEEL_FILE_NAME).toBe(
      `drm_copilot_discovery-${version ?? ""}-py3-none-any.whl`,
    );
    expect(DISCOVERY_GATEWAY_MODULE).toBe("drm_copilot_discovery.gateway");
  });

  it("exposes one shared tool set to the standalone server and the extension provider", () => {
    // The standalone server advertises REPO_AUTOMATION_TOOL_DEFINITIONS verbatim
    // (`listRepoAutomationTools` returns that array), so the definition names are the
    // advertised set; the shared dispatcher must carry a case for each of them.
    const advertised = REPO_AUTOMATION_TOOL_DEFINITIONS.map(
      (definition) => definition.name,
    );
    expect(advertised).toEqual([...REPO_AUTOMATION_TOOLS]);
    const dispatch = readText(path.join(EXTENSION_ROOT, "src", "mcp-tools.ts"));
    expect(dispatch).toContain("return REPO_AUTOMATION_TOOL_DEFINITIONS;");
    for (const name of REPO_AUTOMATION_TOOLS) {
      expect(dispatch).toContain(`case "${name}":`);
    }
    const manifest = JSON.parse(
      readText(path.join(EXTENSION_ROOT, "package.json")),
    ) as ExtensionManifest;
    const provider = readText(
      path.join(EXTENSION_ROOT, "src", "mcp-provider.ts"),
    );
    expect(
      manifest.contributes.mcpServerDefinitionProviders.map(
        (entry) => entry.id,
      ),
    ).toEqual(["drmCopilotMcpProvider"]);
    expect(provider).toContain('"drmCopilotMcpProvider"');
    expect(provider).toContain('"out", "mcp-server.js"');
  });
});
