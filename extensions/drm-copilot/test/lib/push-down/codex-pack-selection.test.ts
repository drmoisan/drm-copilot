import { describe, expect, it } from "@jest/globals";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import {
  CSHARP_CANONICAL_PATHS,
  assertSingleCsharpToolchain,
  computePublishedPaths,
  loadPackManifests,
  ManifestError,
  resolveManifestPackNames,
  resolveVariantSourcePath,
  type PackManifest,
} from "../../../src/lib/push-down/codex-pack-selection";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

const MANIFEST_DIR = "/bundle/pack-manifests";
const REAL_MANIFEST_DIR = resolve(
  __dirname,
  "../../../resources/codex-and-agents-customizations/pack-manifests",
);
const PARALLEL_CORE_PATHS = [
  ".agents/skills/parallel-add/SKILL.md",
  ".agents/skills/parallel-close/SKILL.md",
  ".agents/skills/parallel-orchestrate/SKILL.md",
  ".agents/skills/parallel-plan/SKILL.md",
  ".agents/skills/parallel-remove/SKILL.md",
  ".agents/skills/parallel-run/SKILL.md",
  ".codex/agents/parallel-orchestrator.toml",
  ".codex/agents/parallel-planner.toml",
  ".codex/hooks/authorize-root-parallel-invocation.ps1",
  ".codex/hooks/codex-authority-store.ps1",
  ".codex/hooks/enforce-codex-model-routing.ps1",
  ".codex/hooks/enforce-completion-consistency.ps1",
  ".codex/hooks/enforce-parallel-abandon-gate.ps1",
  ".codex/hooks/enforce-parallel-child-worktree-binding.ps1",
  ".codex/hooks/enforce-parallel-cohort-barrier.ps1",
  ".codex/hooks/enforce-parallel-drift-gate.ps1",
  ".codex/hooks/enforce-parallel-root-invocation.ps1",
  ".codex/hooks/enforce-parallel-worktree-removal-gate.ps1",
  ".codex/hooks/parallel-hook-common.ps1",
  ".codex/hooks/record-subagent-routing-attestation.ps1",
  ".codex/hooks/validate-codex-subagent-routing.ps1",
  ".codex/hooks/validate-parallel-agent-output.ps1",
  ".codex/scripts/codex-child-launch-contract-core.ps1",
  ".codex/scripts/codex-child-launch-persistence.ps1",
  ".codex/scripts/codex-child-launch-resume.ps1",
  ".codex/scripts/codex-child-launch-runtime.ps1",
  ".codex/scripts/launch-parallel-child-batch.ps1",
  ".codex/scripts/parallel-child-launch-contract.ps1",
  ".codex/scripts/parallel-child-post-session.ps1",
  ".codex/scripts/resume-parallel-child.ps1",
  ".codex/config.toml",
  "AGENTS.md",
  "config/blast-radius.json",
  "config/orchestration-routing.json",
  ".claude/lib/bash/compute-cohorts.sh",
  ".claude/lib/bash/compute-concurrency-batches.sh",
  ".claude/lib/bash/parallel-cohorts.sh",
  ".claude/lib/bash/parallel-common.sh",
  ".claude/lib/bash/parallel-items-validate.sh",
  ".claude/lib/bash/parallel-manifest-validate.sh",
  ".claude/lib/bash/parallel-yaml-emit.sh",
  ".claude/lib/bash/parallel-yaml-scan.sh",
  ".claude/lib/bash/validate-parallel-manifest.sh",
  ".claude/lib/blast-radius/BlastRadius.psm1",
  ".claude/lib/blast-radius/BlastRadiusConfig.psm1",
  ".claude/lib/blast-radius/BlastRadiusExtraction.psm1",
  ".claude/lib/blast-radius/BlastRadiusGlob.psm1",
  ".claude/lib/blast-radius/BlastRadiusValidation.psm1",
] as const;
const LANGUAGE_MANIFESTS = [
  "python",
  "powershell",
  "typescript",
  "csharp-modern",
  "csharp-legacy",
] as const;

function manifestJson(manifest: Record<string, unknown>): string {
  return JSON.stringify(manifest);
}

function readRealManifestPaths(name: string): string[] {
  const parsed: unknown = JSON.parse(
    readFileSync(resolve(REAL_MANIFEST_DIR, `${name}.json`), "utf8"),
  );
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    throw new Error(`${name}.json must be an object`);
  }
  const paths = (parsed as Record<string, unknown>)["paths"];
  if (
    !Array.isArray(paths) ||
    !paths.every((path) => typeof path === "string")
  ) {
    throw new Error(`${name}.json paths must be strings`);
  }
  return paths as string[];
}

describe("Codex loadPackManifests", () => {
  it("loads selected manifests and always includes core", () => {
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        paths: [".codex/config.toml"],
      }),
      [`${MANIFEST_DIR}/typescript.json`]: manifestJson({
        name: "typescript",
        label: "TypeScript",
        paths: [".agents/skills/typescript/SKILL.md"],
      }),
    });

    const manifests = loadPackManifests(
      MANIFEST_DIR,
      new Set(["typescript"]),
      fs,
    );

    expect([...manifests.keys()].sort()).toEqual(["core", "typescript"]);
  });

  it("rejects missing, malformed, and unknown manifests", () => {
    const missingFs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        paths: [".codex/config.toml"],
      }),
    });
    expect(() =>
      loadPackManifests(MANIFEST_DIR, new Set(["python"]), missingFs),
    ).toThrow(ManifestError);

    const malformedFs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: "{not json",
    });
    expect(() =>
      loadPackManifests(MANIFEST_DIR, new Set(["core"]), malformedFs),
    ).toThrow("not valid JSON");

    expect(() =>
      loadPackManifests(MANIFEST_DIR, new Set(["ruby"]), malformedFs),
    ).toThrow("Unknown Codex pack");
  });

  it.each([
    ["[]", "must be a JSON object"],
    [manifestJson({ paths: [".codex/config.toml"] }), "name"],
    [
      manifestJson({ name: "core", label: "", paths: [".codex/config.toml"] }),
      "label",
    ],
    [manifestJson({ name: "core", paths: [] }), "paths"],
    [manifestJson({ name: "core", paths: [7] }), "paths"],
    [
      manifestJson({
        name: "core",
        paths: [".codex/config.toml"],
        source_prefix: 7,
      }),
      "source_prefix",
    ],
  ])("rejects invalid manifest shape %#", (payload, message) => {
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: payload,
    });

    expect(() =>
      loadPackManifests(MANIFEST_DIR, new Set(["core"]), fs),
    ).toThrow(message);
  });
});

describe("Codex computePublishedPaths", () => {
  const manifests = new Map<string, PackManifest>([
    [
      "core",
      {
        name: "core",
        label: "Core",
        paths: [".codex/config.toml"],
        sourcePrefix: null,
      },
    ],
    [
      "typescript",
      {
        name: "typescript",
        label: "TypeScript",
        paths: [".agents/skills/typescript/SKILL.md"],
        sourcePrefix: null,
      },
    ],
  ]);

  it("returns null for empty selection and includes core for explicit selection", () => {
    expect(computePublishedPaths(null, manifests)).toBeNull();
    expect(computePublishedPaths(new Set(), manifests)).toBeNull();
    expect([
      ...(computePublishedPaths(new Set(["typescript"]), manifests) ?? []),
    ]).toEqual([".agents/skills/typescript/SKILL.md", ".codex/config.toml"]);
  });

  it("keeps the complete parallel closure unique and core-owned", () => {
    const corePaths = readRealManifestPaths("core");
    const required = new Set(PARALLEL_CORE_PATHS);

    expect(PARALLEL_CORE_PATHS).toHaveLength(48);
    expect(new Set(corePaths).size).toBe(corePaths.length);
    expect(
      PARALLEL_CORE_PATHS.filter((path) => !corePaths.includes(path)),
    ).toEqual([]);
    expect(corePaths.filter((path) => path.startsWith(".claude/"))).toEqual(
      PARALLEL_CORE_PATHS.filter((path) => path.startsWith(".claude/")),
    );
    for (const manifestName of LANGUAGE_MANIFESTS) {
      expect(
        readRealManifestPaths(manifestName).filter((path) =>
          required.has(path),
        ),
      ).toEqual([]);
    }
  });

  it("keeps the complete commit-steward generated family in core", () => {
    const corePaths = readRealManifestPaths("core");
    const commitStewardPaths = [
      ".codex/agents/commit-steward.toml",
      ".codex/agents/commit-steward-c1.toml",
      ".codex/agents/commit-steward-c2.toml",
      ".codex/agents/commit-steward-c3.toml",
      ".codex/agents/commit-steward-c3-elevated.toml",
      ".codex/agents/commit-steward-c4.toml",
    ];

    expect(corePaths.filter((path) => path.includes("commit-steward"))).toEqual(
      commitStewardPaths,
    );
  });
});

describe("Codex resolveManifestPackNames", () => {
  it("maps public csharp selection to the selected variant manifest", () => {
    expect(
      resolveManifestPackNames(new Set(["core", "csharp"]), "legacy"),
    ).toEqual(new Set(["core", "csharp-legacy"]));
    expect(resolveManifestPackNames(new Set(["csharp"]), "modern")).toEqual(
      new Set(["csharp-modern"]),
    );
  });

  it("returns null for null or empty public selection", () => {
    expect(resolveManifestPackNames(null, "legacy")).toBeNull();
    expect(resolveManifestPackNames(new Set(), "modern")).toBeNull();
  });

  it("rejects variant-specific pack names in public input", () => {
    expect(() =>
      resolveManifestPackNames(new Set(["csharp", "csharp-legacy"]), "legacy"),
    ).toThrow("public Codex pack 'csharp'");
  });

  it("rejects unknown public pack names", () => {
    expect(() => resolveManifestPackNames(new Set(["ruby"]), "modern")).toThrow(
      "Unknown Codex pack",
    );
  });
});

describe("Codex C# variant routing", () => {
  it("declares canonical destinations and routes legacy agents/codex sources", () => {
    expect(CSHARP_CANONICAL_PATHS).toEqual([
      ".agents/skills/csharp/SKILL.md",
      ".agents/skills/csharp-qa-gate/SKILL.md",
      ".agents/skills/invoke-csharp-engineer/SKILL.md",
      ".codex/agents/csharp-typed-engineer.toml",
    ]);
    expect(
      resolveVariantSourcePath(".agents/skills/csharp/SKILL.md", "legacy"),
    ).toBe(".agents-variants/csharp-legacy/skills/csharp/SKILL.md");
    expect(
      resolveVariantSourcePath(
        ".codex/agents/csharp-typed-engineer.toml",
        "legacy",
      ),
    ).toBe(".codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml");
    expect(
      resolveVariantSourcePath(".agents/skills/csharp/SKILL.md", "modern"),
    ).toBe(".agents/skills/csharp/SKILL.md");
  });

  it("rejects selecting both C# variants", () => {
    expect(() =>
      assertSingleCsharpToolchain(
        new Set(CSHARP_CANONICAL_PATHS),
        new Set(["csharp-modern", "csharp-legacy"]),
      ),
    ).toThrow(ManifestError);
  });
});
