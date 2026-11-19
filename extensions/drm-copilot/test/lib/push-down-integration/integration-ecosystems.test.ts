/**
 * Unit tests for ecosystem detection (issue #1051, S21 and S22).
 */

import { detectIntegrationEcosystems } from "../../../src/lib/push-down-integration/integration-ecosystems";
import { DEST, destination, manifestText } from "./integration-test-helpers";

describe("detectIntegrationEcosystems", () => {
  it("S21 positive: reports selection from the manifest and presence from root evidence", () => {
    const fs = destination({
      ".push-down-manifest.json": manifestText({
        claude: { packs: ["core"] },
        copilot: { packs: ["core"] },
      }),
      ".claude/agents/a.md": "a\n",
      "AGENTS.md": "agents\n",
      ".github/copilot-instructions.md": "x\n",
    });

    const result = detectIntegrationEcosystems(fs, DEST);

    expect(result.harness).toEqual([
      { name: "claude", selected: true, present: true },
      { name: "codex", selected: false, present: true },
      { name: "copilot", selected: true, present: true },
    ]);
  });

  it("S21 positive: a file under .codex is codex evidence", () => {
    const fs = destination({ ".codex/config.toml": "x\n" });

    expect(detectIntegrationEcosystems(fs, DEST).harness[1]).toEqual({
      name: "codex",
      selected: false,
      present: true,
    });
  });

  it.each([
    ["absent", {}],
    ["unparseable", { ".push-down-manifest.json": "{ not json" }],
  ])(
    "S21 negative: a manifest that is %s selects nothing and evidence alone sets presence",
    (_label, files) => {
      const fs = destination({ ...files, ".github/other.md": "x\n" });

      const result = detectIntegrationEcosystems(fs, DEST);

      expect(result.harness.every((entry) => !entry.selected)).toBe(true);
      expect(result.harness.every((entry) => !entry.present)).toBe(true);
    },
  );

  it("S22 positive: reports selected packs and file evidence, sorted by name", () => {
    const fs = destination({
      ".push-down-manifest.json": manifestText({
        claude: { packs: ["core", "python"] },
        codex: { packs: ["core", "csharp"], csharpVariant: "legacy" },
      }),
      "pyproject.toml": "x\n",
      "web/package.json": "{}\n",
      "web/tsconfig.json": "{}\n",
      "src/App.csproj": "<Project/>\n",
      "scripts/build.psm1": "x\n",
    });

    const result = detectIntegrationEcosystems(fs, DEST);

    expect(result.packs).toEqual([
      { name: "csharp-legacy", selected: true, present: true },
      { name: "powershell", selected: false, present: true },
      { name: "python", selected: true, present: true },
      { name: "typescript", selected: false, present: true },
    ]);
  });

  it.each([
    ["csharp-modern", { claude: { packs: ["core", "csharp-modern"] } }],
    ["csharp-legacy", { codex: { packs: ["core", "csharp-legacy"] } }],
    ["csharp-modern", { codex: { packs: ["core", "csharp"] } }],
  ])(
    "S22 positive: names the C# entry %s from the selection",
    (name, selection) => {
      const fs = destination({
        ".push-down-manifest.json": manifestText(selection),
      });

      const entry = detectIntegrationEcosystems(fs, DEST).packs.find((pack) =>
        pack.name.startsWith("csharp"),
      );

      expect(entry).toEqual({ name, selected: true, present: false });
    },
  );

  it("S22 negative: harness folders, pruned directories and split TypeScript files are not evidence", () => {
    const fs = destination({
      ".claude/hooks/a.ps1": "x\n",
      ".github/x/pyproject.toml": "x\n",
      "node_modules/pkg/setup.py": "x\n",
      "tests/fixture.ps1": "x\n",
      "dist/App.sln": "x\n",
      "a/package.json": "{}\n",
      "b/tsconfig.json": "{}\n",
    });

    const result = detectIntegrationEcosystems(fs, DEST);

    expect(result.packs).toEqual([
      { name: "csharp", selected: false, present: false },
      { name: "powershell", selected: false, present: false },
      { name: "python", selected: false, present: false },
      { name: "typescript", selected: false, present: false },
    ]);
  });
});
