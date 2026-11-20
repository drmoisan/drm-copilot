/**
 * Unit tests for the CI shared-layer contribution (issue #1050).
 *
 * Every test builds its own in-memory destination; no file is read from disk.
 */

import {
  buildCiWorkflowsContribution,
  ciJobPackName,
  findCiWorkflowNameCollisions,
  withCiWorkflows,
} from "../../../src/lib/push-down/push-down-ci-layer";
import { CI_JOBS_MARKER } from "../../../src/lib/push-down/push-down-ci-workflows";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";
import { makeTestLayer } from "./push-down-pipeline.test-helpers";

/** Minimal CI bundle under `/res/ci-workflows`, built in code. */
function bundle(): Record<string, string> {
  const fragment = (stem: string): string =>
    `  ${stem}:\n    uses: __DRM_COPILOT_CI_USES__\n    __DRM_COPILOT_CI_WITH__\n`;
  return {
    "/res/ci-workflows/caller/drm-copilot-ci.template.yml": `name: CI\njobs:\n  ${CI_JOBS_MARKER}\n  ci-required-gate:\n    __DRM_COPILOT_CI_GATE_NEEDS__\n`,
    "/res/ci-workflows/caller/jobs/python.yml": fragment("python"),
    "/res/ci-workflows/caller/jobs/dotnet.yml": fragment("dotnet"),
  };
}

describe("findCiWorkflowNameCollisions", () => {
  it("detects unquoted and quoted CI names in .yml and .yaml files", () => {
    const fs = buildInMemoryFileSystem({
      "/dest/.github/workflows/a.yml": "name: CI\non: push\n",
      "/dest/.github/workflows/b.yaml": "name: 'CI'  # main\r\n",
      "/dest/.github/workflows/c.yml": 'name: "CI"\n',
      "/dest/.github/workflows/d.yml": "name: CI-Extra\n",
    });

    const lines = findCiWorkflowNameCollisions(fs, "/dest");

    expect(lines).toHaveLength(3);
    for (const name of ["a.yml", "b.yaml", "c.yml"]) {
      expect(
        lines.some(
          (line) =>
            line.startsWith("push-down conflict:") &&
            line.includes(`.github/workflows/${name}`),
        ),
      ).toBe(true);
    }
  });

  it("ignores the caller file and a non-top-level name", () => {
    const fs = buildInMemoryFileSystem({
      "/dest/.github/workflows/drm-copilot-ci.yml": "name: CI\n",
      "/dest/.github/workflows/e.yml": "jobs:\n  x:\n    name: CI\n",
      "/dest/.github/workflows/nested/f.yml": "name: CI\n",
      "/dest/.github/workflows/g.txt": "name: CI\n",
    });

    expect(findCiWorkflowNameCollisions(fs, "/dest")).toEqual([]);
    expect(
      findCiWorkflowNameCollisions(buildInMemoryFileSystem(), "/dest"),
    ).toEqual([]);
  });
});

describe("buildCiWorkflowsContribution", () => {
  it("contributes the caller, data file, command and selected copies with their packs", () => {
    const fs = buildInMemoryFileSystem(bundle());

    const contribution = buildCiWorkflowsContribution({
      fs,
      resourcesRoot: "/res",
      destinationRoot: "/dest",
      mode: "copy",
      selectionRecords: [{ packs: ["core", "python", "csharp-legacy"] }],
      payloadVersion: "1.0.0",
    });

    expect(contribution.rootFiles.map(([path]) => path)).toEqual([
      ".github/workflows/drm-copilot-ci.yml",
      ".github/drm-copilot/ci-required-checks.json",
      ".github/drm-copilot/Set-CiRequiredChecks.ps1",
      ".github/workflows/drm-copilot-python.yml",
      ".github/workflows/drm-copilot-dotnet.yml",
    ]);
    expect(
      contribution.packByPath[".github/workflows/drm-copilot-dotnet.yml"],
    ).toBe("csharp-legacy");
    expect(contribution.protectedPaths).toHaveLength(7);
    expect(contribution.callerText).toContain("variant: legacy");
    expect(contribution.warnings).toEqual([]);
  });

  it("withholds the caller when a collision exists", () => {
    const fs = buildInMemoryFileSystem({
      ...bundle(),
      "/dest/.github/workflows/ci.yml": "name: CI\n",
    });

    const contribution = buildCiWorkflowsContribution({
      fs,
      resourcesRoot: "/res",
      destinationRoot: "/dest",
      mode: "reference",
      selectionRecords: [],
      payloadVersion: "1.0.0",
    });

    expect(contribution.rootFiles.map(([path]) => path)).toEqual([
      ".github/drm-copilot/ci-required-checks.json",
      ".github/drm-copilot/Set-CiRequiredChecks.ps1",
    ]);
    expect(contribution.warnings).toHaveLength(1);
  });
});

describe("withCiWorkflows", () => {
  it("adds root files, renders the caller, maps packs and protects CI paths", () => {
    const base = buildInMemoryFileSystem();
    const shared = makeTestLayer(base, "shared", {
      rootFiles: [["AGENTS.md", "x/AGENTS.md"]],
      unmanagedProtectedPaths: ["kept.txt"],
    });

    const layer = withCiWorkflows(shared, {
      rootFiles: [[".github/drm-copilot/ci-required-checks.json", "ci.json"]],
      packByPath: { ".github/workflows/drm-copilot-python.yml": "python" },
      protectedPaths: [".github/drm-copilot/ci-required-checks.json"],
      callerText: "rendered\n",
      warnings: [],
    });

    expect(layer.rootFiles.map(([path]) => path)).toEqual([
      "AGENTS.md",
      ".github/drm-copilot/ci-required-checks.json",
    ]);
    expect(layer.rewrite(`a\n${CI_JOBS_MARKER}\n`)[0]).toBe("rendered\n");
    expect(layer.rewrite("plain\n")[0]).toBe("plain\n");
    expect(layer.ownerPack(".github/workflows/drm-copilot-python.yml")).toBe(
      "python",
    );
    expect(layer.ownerPack("AGENTS.md")).toBe("core");
    expect(layer.unmanagedProtectedPaths).toEqual([
      "kept.txt",
      ".github/drm-copilot/ci-required-checks.json",
    ]);
  });

  it("names the C# copy owner by variant", () => {
    expect(ciJobPackName({ stem: "dotnet", variant: "modern" })).toBe(
      "csharp-modern",
    );
    expect(ciJobPackName({ stem: "dotnet" })).toBe("csharp-modern");
    expect(ciJobPackName({ stem: "python" })).toBe("python");
  });
});
