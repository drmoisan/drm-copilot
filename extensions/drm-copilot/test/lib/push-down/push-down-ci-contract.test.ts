/**
 * Contract tests of the destination CI workflows (issue #1050).
 *
 * The cases read tracked files of the repository read-only and run the pure
 * checks of `push-down-ci-contract.test-helpers.ts` against them; each check
 * is also run against in-memory variants that must fail.
 */

import { readdirSync, readFileSync } from "node:fs";
import { join, relative } from "node:path";

import {
  CI_STEMS,
  ciFragmentSource,
  renderCiCaller,
  resolveCiPackJobs,
} from "../../../src/lib/push-down/push-down-ci-workflows";
import {
  findCiContractDivergences,
  findHarnessWorkflowViolations,
  findPowerShellInputDivergences,
} from "./push-down-ci-contract.test-helpers";

const REPO_ROOT = join(__dirname, "..", "..", "..", "..", "..");
const EXTENSION_ROOT = join(REPO_ROOT, "extensions", "drm-copilot");
const CI_BUNDLE = join(EXTENSION_ROOT, "resources", "ci-workflows");
const CLAUDE_HOOKS = join(
  EXTENSION_ROOT,
  "resources",
  "claude-customizations",
  ".claude",
  "hooks",
);

/** Read a repository file by its repository-relative POSIX path. */
function readRepo(path: string): string {
  return readFileSync(join(REPO_ROOT, ...path.split("/")), "utf8");
}

/** Read a CI bundle file by its bundle-relative POSIX path. */
function readBundle(path: string): string {
  return readFileSync(join(CI_BUNDLE, ...path.split("/")), "utf8");
}

/** List every file under a directory as POSIX paths relative to it. */
function listFiles(root: string): string[] {
  return readdirSync(root, { recursive: true, withFileTypes: true })
    .filter((entry) => entry.isFile())
    .map((entry) =>
      relative(root, join(entry.parentPath, entry.name)).replace(/\\/g, "/"),
    )
    .sort();
}

const HARNESS = Object.fromEntries(
  CI_STEMS.map((stem) => [
    stem,
    readRepo(`.github/workflows/harness-${stem}.yml`),
  ]),
) as Record<(typeof CI_STEMS)[number], string>;

const CONTRACT_INPUTS = {
  callerTemplate: readBundle("caller/drm-copilot-ci.template.yml"),
  dataText: readBundle("ci-required-checks.json"),
  mergeGateHookText: readFileSync(
    join(CLAUDE_HOOKS, "enforce-epic-merge-gate-child-ci.ps1"),
    "utf8",
  ),
  coverageHookText: readFileSync(
    join(CLAUDE_HOOKS, "validate-feature-review-coverage-metrics.ps1"),
    "utf8",
  ),
};

/** Render a caller with every language job from the real bundle. */
function renderAll(mode: "reference" | "copy"): string {
  return renderCiCaller({
    mode,
    jobs: resolveCiPackJobs([
      { packs: ["python", "powershell", "typescript", "csharp-modern"] },
    ]),
    payloadVersion: "1.2.3",
    template: CONTRACT_INPUTS.callerTemplate,
    fragments: Object.fromEntries(
      CI_STEMS.map((stem) => [
        stem,
        readFileSync(
          join(EXTENSION_ROOT, "resources", ciFragmentSource(stem)),
          "utf8",
        ),
      ]),
    ),
  });
}

describe("destination CI contract", () => {
  it("harness workflows are destination-generic", () => {
    for (const stem of CI_STEMS) {
      expect(findHarnessWorkflowViolations(stem, HARNESS[stem])).toEqual([]);
    }
    const powershell = HARNESS.powershell;
    expect(
      findHarnessWorkflowViolations(
        "powershell",
        `${powershell}\n# run scripts/ci/Invoke-CiRequiredGate.ps1\n`,
      ),
    ).toContain("powershell: names a scripts/ path outside the side folder");
    expect(
      findHarnessWorkflowViolations(
        "powershell",
        powershell.replace(
          "repository: ${{ inputs.harness_repository }}",
          "repository: ${{ job.workflow_repository }}",
        ),
      ).length,
    ).toBeGreaterThan(0);
    expect(
      findHarnessWorkflowViolations(
        "python",
        HARNESS.python.replace("  workflow_call:", "  push:\n  workflow_call:"),
      ),
    ).toContain("python: triggers are push,workflow_call");
    expect(
      findHarnessWorkflowViolations(
        "dotnet",
        HARNESS.dotnet.replace(
          "runs-on: windows-latest",
          "runs-on: ubuntu-latest",
        ),
      ),
    ).toContain("dotnet: legacy does not run on windows-latest");
  });

  it("caller, data file and consumers agree", () => {
    expect(findCiContractDivergences(CONTRACT_INPUTS)).toEqual([]);
    expect(JSON.parse(CONTRACT_INPUTS.dataText)).toEqual({
      required_contexts: ["CI Required Gate"],
      schema_version: "1.0.0",
      workflow: "CI",
      workflow_file: ".github/workflows/drm-copilot-ci.yml",
    });
  });

  it("reports a diverging in-memory template", () => {
    const divergences = findCiContractDivergences({
      ...CONTRACT_INPUTS,
      callerTemplate: CONTRACT_INPUTS.callerTemplate
        .replace("name: CI\n", "name: Build\n")
        .replace('      - "epic/**"\n', ""),
    });

    expect(divergences.length).toBeGreaterThan(0);
    expect(
      findCiContractDivergences({ ...CONTRACT_INPUTS, dataText: "{" }),
    ).toContain("data file is not JSON");
    expect(
      findCiContractDivergences({
        ...CONTRACT_INPUTS,
        coverageHookText: "",
      }).length,
    ).toBe(4);
  });

  it("rendered PowerShell job inputs match harness-powershell.yml declarations", () => {
    for (const mode of ["reference", "copy"] as const) {
      expect(
        findPowerShellInputDivergences(HARNESS.powershell, renderAll(mode)),
      ).toEqual([]);
    }
    expect(renderAll("reference")).toContain("harness_ref: v1.2.3");
    const withoutRef = HARNESS.powershell.replace(
      /\n {6}harness_ref:\n(?: {8}.*\n)+/,
      "\n",
    );
    expect(
      findPowerShellInputDivergences(withoutRef, renderAll("reference")),
    ).toContain("caller passes undeclared input harness_ref");
    expect(
      findPowerShellInputDivergences(
        HARNESS.powershell.replace(
          "repository: ${{ inputs.harness_repository }}",
          "repository: drmoisan/drm-copilot",
        ),
        renderAll("reference"),
      ),
    ).toContain("harness checkout does not read inputs.harness_repository");
  });

  it("CI bundle is complete and copies match", () => {
    const declared = [
      "Set-CiRequiredChecks.ps1",
      "caller/drm-copilot-ci.template.yml",
      ...CI_STEMS.map((stem) => `caller/jobs/${stem}.yml`),
      "ci-required-checks.json",
      ...CI_STEMS.map((stem) => `workflows/harness-${stem}.yml`),
    ].sort();

    expect(listFiles(CI_BUNDLE)).toEqual(declared);
    for (const stem of CI_STEMS) {
      expect(readBundle(`workflows/harness-${stem}.yml`)).toBe(HARNESS[stem]);
    }
    expect(readBundle("Set-CiRequiredChecks.ps1")).toBe(
      readRepo("scripts/ci/Set-CiRequiredChecks.ps1"),
    );
  });

  it("every brief copy names the CI data file after the refresh rule", () => {
    const copies = [
      ".claude/skills/execution-environment/SKILL.md",
      "extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md",
      ".agents/skills/execution-environment/SKILL.md",
      "extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md",
      ".github/skills/execution-environment/SKILL.md",
      "extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md",
    ];
    const token = ".github/drm-copilot/ci-required-checks.json";

    for (const copy of copies) {
      const text = readRepo(copy).replace(/\r\n?/g, "\n");
      const start = text.indexOf("## CI Shape and Required Checks");
      const end = text.indexOf("\n## ", start + 1);
      const section = text.slice(start, end < 0 ? undefined : end);
      const refresh = section.indexOf("- Refresh rule:");
      const skipped = section.indexOf("- Skipped-check semantics:");
      const position = section.indexOf(token);

      expect(start).toBeGreaterThanOrEqual(0);
      expect(refresh).toBeGreaterThanOrEqual(0);
      expect(position).toBeGreaterThan(refresh);
      expect(position).toBeLessThan(skipped);
    }
  });

  it("new push-down CI modules invoke no gh", () => {
    for (const module of [
      "push-down-ci-workflows.ts",
      "push-down-ci-layer.ts",
    ]) {
      const text = readFileSync(
        join(EXTENSION_ROOT, "src", "lib", "push-down", module),
        "utf8",
      );
      expect(text).not.toMatch(/\bgh\b/);
      expect(text).not.toContain("child_process");
      expect(text).not.toContain("node:fs");
    }
  });
});
