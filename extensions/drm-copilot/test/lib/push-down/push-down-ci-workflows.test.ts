/**
 * Unit tests for the destination CI workflow logic (issue #1050).
 *
 * The template and fragments are built in code; no file is read.
 */

import { ManifestError } from "../../../src/lib/push-down/claude-pack-selection";
import {
  CI_GATE_NEEDS_MARKER,
  CI_JOBS_MARKER,
  CI_USES_MARKER,
  CI_WITH_MARKER,
  ciCopyRelativePath,
  type CiPackJob,
  type CiStem,
  inferCiWorkflowsMode,
  parseCiWorkflowsMode,
  renderCiCaller,
  resolveCiPackJobs,
} from "../../../src/lib/push-down/push-down-ci-workflows";
import { type DestinationManifest } from "../../../src/lib/push-down/push-down-destination-manifest";

const TEMPLATE = [
  "name: CI",
  "on:",
  "  pull_request:",
  "    branches:",
  "      - main",
  '      - "epic/**"',
  "  push:",
  "    branches:",
  "      - main",
  "  workflow_dispatch:",
  "  merge_group:",
  "jobs:",
  `  ${CI_JOBS_MARKER}`,
  "  ci-required-gate:",
  "    name: CI Required Gate",
  "    if: always()",
  `    ${CI_GATE_NEEDS_MARKER}`,
  "    runs-on: ubuntu-latest",
  "    steps:",
  "      - shell: pwsh",
  "        env:",
  "          NEEDS_JSON: ${{ toJSON(needs) }}",
  "        run: if ($result -ne 'success') { exit 1 }",
  "",
].join("\r\n");

/** Fragment text of one stem, built in code. */
function fragment(stem: CiStem): string {
  return [
    `  ${stem}:`,
    `    name: ${stem}`,
    `    uses: ${CI_USES_MARKER}`,
    `    ${CI_WITH_MARKER}`,
    "",
  ].join("\n");
}

const FRAGMENTS: Record<CiStem, string> = {
  python: fragment("python"),
  powershell: fragment("powershell"),
  typescript: fragment("typescript"),
  dotnet: fragment("dotnet"),
};

/** Render a caller for jobs in a mode with payload version 1.2.3. */
function render(
  mode: "reference" | "copy",
  jobs: ReadonlyArray<CiPackJob>,
): string {
  return renderCiCaller({
    mode,
    jobs,
    payloadVersion: "1.2.3",
    template: TEMPLATE,
    fragments: FRAGMENTS,
  });
}

/** Return the lines of one job block of a rendered caller. */
function jobBlock(text: string, id: string): string[] {
  const lines = text.split("\n");
  const start = lines.indexOf(`  ${id}:`);
  if (start < 0) {
    return [];
  }
  const end = lines.findIndex(
    (line, index) => index > start && /^ {2}\S/.test(line),
  );
  return lines.slice(start, end < 0 ? undefined : end);
}

/** Build a manifest with the given file paths. */
function manifestWith(paths: ReadonlyArray<string>): DestinationManifest {
  return {
    schemaVersion: "1.0.0",
    payloadVersion: "1.0.0",
    selection: {},
    files: Object.fromEntries(
      paths.map((path) => [
        path,
        { layer: "shared", pack: "core", sha256: "x" },
      ]),
    ),
  };
}

describe("parseCiWorkflowsMode", () => {
  it("parseCiWorkflowsMode accepts off, reference and copy and names a rejected value", () => {
    expect(["off", "reference", "copy"].map(parseCiWorkflowsMode)).toEqual([
      "off",
      "reference",
      "copy",
    ]);
    expect(() => parseCiWorkflowsMode("on")).toThrow(
      "Field 'ci_workflows' must be one of off, reference, copy when provided; received 'on'.",
    );
    expect(() => parseCiWorkflowsMode(3)).toThrow("received '3'");
  });
});

describe("inferCiWorkflowsMode", () => {
  it("infers off without a data-file entry", () => {
    expect(inferCiWorkflowsMode(undefined)).toBe("off");
    expect(
      inferCiWorkflowsMode(
        manifestWith([".github/workflows/drm-copilot-ci.yml"]),
      ),
    ).toBe("off");
  });

  it("infers copy from the data-file entry and a drm-copilot stem copy entry", () => {
    expect(
      inferCiWorkflowsMode(
        manifestWith([
          ".github/drm-copilot/ci-required-checks.json",
          ".github/workflows/drm-copilot-ci.yml",
          ".github/workflows/drm-copilot-dotnet.yml",
        ]),
      ),
    ).toBe("copy");
  });

  it("infers reference when only the caller and data file are recorded", () => {
    expect(
      inferCiWorkflowsMode(
        manifestWith([
          ".github/drm-copilot/ci-required-checks.json",
          ".github/workflows/drm-copilot-ci.yml",
        ]),
      ),
    ).toBe("reference");
  });
});

describe("resolveCiPackJobs", () => {
  it("maps python, powershell and typescript packs to their stems", () => {
    expect(
      resolveCiPackJobs([
        { packs: ["typescript", "core", "python", "powershell"] },
      ]),
    ).toEqual([
      { stem: "python" },
      { stem: "powershell" },
      { stem: "typescript" },
    ]);
  });

  it("maps csharp-modern and csharp-legacy to dotnet variants", () => {
    expect(resolveCiPackJobs([{ packs: ["csharp-modern"] }])).toEqual([
      { stem: "dotnet", variant: "modern" },
    ]);
    expect(resolveCiPackJobs([{ packs: ["csharp-legacy"] }])).toEqual([
      { stem: "dotnet", variant: "legacy" },
    ]);
  });

  it("maps Codex csharp with csharp_variant legacy to variant legacy", () => {
    expect(
      resolveCiPackJobs([
        { packs: ["core", "csharp"], csharpVariant: "legacy" },
      ]),
    ).toEqual([{ stem: "dotnet", variant: "legacy" }]);
  });

  it("maps Copilot csharp with no recorded variant to variant modern", () => {
    expect(resolveCiPackJobs([{ packs: ["csharp"] }])).toEqual([
      { stem: "dotnet", variant: "modern" },
    ]);
  });

  it("core alone yields no job", () => {
    expect(resolveCiPackJobs([{ packs: ["core"] }, { packs: [] }])).toEqual([]);
  });

  it("rejects a selection union holding both C# variants", () => {
    expect(() =>
      resolveCiPackJobs([
        { packs: ["csharp-modern"] },
        { packs: ["csharp"], csharpVariant: "legacy" },
      ]),
    ).toThrow(ManifestError);
  });
});

describe("renderCiCaller", () => {
  it("Python-only selection renders no PowerShell, TypeScript or .NET job", () => {
    const text = render("reference", [{ stem: "python" }]);

    expect(jobBlock(text, "python")).not.toEqual([]);
    for (const id of ["powershell", "typescript", "dotnet"]) {
      expect(jobBlock(text, id)).toEqual([]);
    }
  });

  it("PowerShell plus TypeScript selection renders only those jobs", () => {
    const text = render("copy", [
      { stem: "powershell" },
      { stem: "typescript" },
    ]);

    expect(jobBlock(text, "powershell")).not.toEqual([]);
    expect(jobBlock(text, "typescript")).not.toEqual([]);
    expect(jobBlock(text, "python")).toEqual([]);
    expect(jobBlock(text, "dotnet")).toEqual([]);
  });

  it("csharp-modern and csharp-legacy render variant modern and variant legacy", () => {
    const modern = render(
      "reference",
      resolveCiPackJobs([{ packs: ["csharp-modern"] }]),
    );
    const legacy = render(
      "reference",
      resolveCiPackJobs([{ packs: ["csharp-legacy"] }]),
    );

    expect(jobBlock(modern, "dotnet")).toContain("      variant: modern");
    expect(jobBlock(legacy, "dotnet")).toContain("      variant: legacy");
  });

  it("no language pack renders only the gate job without needs", () => {
    const text = render("reference", []);

    expect(text).not.toContain("needs:");
    expect(text).not.toContain("uses:");
    expect(text).toContain("  ci-required-gate:");
    expect(text).not.toContain(CI_JOBS_MARKER);
    expect(text).not.toContain(CI_GATE_NEEDS_MARKER);
  });

  it("reference mode pins harness workflows at the payload version", () => {
    const text = render("reference", [
      { stem: "python" },
      { stem: "powershell" },
      { stem: "typescript" },
      { stem: "dotnet", variant: "modern" },
    ]);

    for (const stem of ["python", "powershell", "typescript", "dotnet"]) {
      expect(jobBlock(text, stem)).toContain(
        `    uses: drmoisan/drm-copilot/.github/workflows/harness-${stem}.yml@v1.2.3`,
      );
    }
    expect(text).not.toContain("drm-copilot-python.yml");
  });

  it("reference mode passes no poshqc input", () => {
    const text = render("reference", [
      { stem: "powershell" },
      { stem: "python" },
    ]);

    expect(text).not.toContain("poshqc");
  });

  it("reference mode passes harness_repository and harness_ref to the PowerShell job only", () => {
    const text = render("reference", [
      { stem: "python" },
      { stem: "powershell" },
      { stem: "typescript" },
      { stem: "dotnet", variant: "legacy" },
    ]);

    expect(jobBlock(text, "powershell")).toEqual(
      expect.arrayContaining([
        "    with:",
        "      harness_repository: drmoisan/drm-copilot",
        "      harness_ref: v1.2.3",
      ]),
    );
    for (const stem of ["python", "typescript", "dotnet"]) {
      const block = jobBlock(text, stem).join("\n");
      expect(block).not.toContain("harness_repository");
      expect(block).not.toContain("harness_ref");
    }
  });

  it("copy mode uses local copies and passes poshqc false to the PowerShell job only", () => {
    const stems: CiStem[] = ["python", "powershell", "typescript", "dotnet"];
    const text = render("copy", [
      { stem: "python" },
      { stem: "powershell" },
      { stem: "typescript" },
      { stem: "dotnet", variant: "modern" },
    ]);

    for (const stem of stems) {
      expect(jobBlock(text, stem)).toContain(
        `    uses: ./${ciCopyRelativePath(stem)}`,
      );
      const block = jobBlock(text, stem).join("\n");
      expect(block.includes("poshqc: false")).toBe(stem === "powershell");
    }
    expect(text).not.toContain("harness_repository");
    expect(text).not.toContain("harness_ref");
    expect(text).not.toContain("drmoisan/drm-copilot/");
  });

  it("renders the gate job and triggers", () => {
    const text = render("reference", [
      { stem: "python" },
      { stem: "dotnet", variant: "modern" },
    ]);
    const gate = jobBlock(text, "ci-required-gate");

    expect(text.split("\n")).toContain("name: CI");
    expect(text).not.toContain("\r");
    expect(gate).toContain("    if: always()");
    expect(gate).toEqual(
      expect.arrayContaining([
        "    needs:",
        "      - python",
        "      - dotnet",
      ]),
    );
    expect(gate.join("\n")).toContain("NEEDS_JSON: ${{ toJSON(needs) }}");
    expect(gate.join("\n")).toContain("-ne 'success'");
    expect(text).toContain('      - "epic/**"');
    expect(text).toContain("  pull_request:");
    expect(text).toContain("  push:");
    expect(text).toContain("  workflow_dispatch:");
    expect(text).toContain("  merge_group:");
  });

  it("throws when the template lacks a marker", () => {
    expect(() =>
      renderCiCaller({
        mode: "reference",
        jobs: [],
        payloadVersion: "1.2.3",
        template: "name: CI\n",
        fragments: FRAGMENTS,
      }),
    ).toThrow(CI_JOBS_MARKER);
  });

  it("throws when a needed fragment is missing or lacks the uses marker", () => {
    const base = {
      mode: "copy" as const,
      jobs: [{ stem: "python" as const }],
      payloadVersion: "1.2.3",
      template: TEMPLATE,
    };

    expect(() => renderCiCaller({ ...base, fragments: {} })).toThrow(
      "fragment for python is missing",
    );
    expect(() =>
      renderCiCaller({ ...base, fragments: { python: "  python:\n" } }),
    ).toThrow(CI_USES_MARKER);
  });
});
