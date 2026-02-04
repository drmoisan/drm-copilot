import { describe, expect, it } from "@jest/globals";

import {
  getRequiredInputIds,
  getUtilitySpec,
  UTILITY_COMMAND_SPECS,
} from "../../src/utilities/utility-spec.ts";

describe("utility-spec", () => {
  it("qcFixAll uses extension PYTHONPATH", () => {
    const spec = getUtilitySpec("drm-copilot.qcFixAll");

    expect(spec).toBeDefined();
    expect(spec.kind).toBe("external");
    expect(spec.env).toBeDefined();
    expect(spec.env.PYTHONPATH).toBe("${extensionRoot}");
  });

  it("devNewPotentialEntry uses extensionRoot script", () => {
    const spec = getUtilitySpec("drm-copilot.devNewPotentialEntry");

    expect(spec).toBeDefined();
    expect(spec.kind).toBe("powershell");
    expect(spec.scriptPath).toBe(
      "${extensionRoot}/scripts/dev-tools/new-potential-entry.ps1",
    );
  });

  it("devNewPotentialEntry requires PotentialShortName", () => {
    const requiredIds = getRequiredInputIds("drm-copilot.devNewPotentialEntry");

    expect(requiredIds).toEqual(["PotentialShortName"]);
  });

  it("ps scripts use extensionRoot", () => {
    // Validate that all PowerShell utility specs use ${extensionRoot} paths
    // and never use ${workspaceFolder} (REQ-002)
    const powershellSpecs = Object.values(UTILITY_COMMAND_SPECS).filter(
      (spec) => spec.kind === "powershell",
    );

    expect(powershellSpecs.length).toBeGreaterThan(0);

    for (const spec of powershellSpecs) {
      expect(spec.scriptPath).toContain("${extensionRoot}");
      expect(spec.scriptPath).not.toContain("${workspaceFolder}");
    }
  });
});
