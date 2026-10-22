/**
 * Resolver and role-policy contract for the authority discovery tools.
 *
 * Configure, transfer, import, migrate, doctor, read, prepare and finalize
 * accept only their closed v2 input shapes; the root-only tool set and the
 * discovery-role predicate drive the dispatch denial.
 */

import { describe, expect, it } from "@jest/globals";

import {
  COMPLEXITY_BANDS,
  CONFIGURATION_ACTIONS,
  discoveryRoleDeniedMessage,
  EXECUTION_CONTEXTS,
  isDiscoveryRole,
  isRootOnlyDiscoveryTool,
  READ_OPERATIONS,
  resolveConfigureDiscoveryWorkspaceToolInput,
  resolveFinalizeDiscoveryAgentToolInput,
  resolveImportDiscoveryInventoryToolInput,
  resolveMigrateDiscoveryArtifactsToolInput,
  resolvePrepareDiscoveryAgentToolInput,
  resolveReadDiscoverySourceToolInput,
  resolveRunDiscoveryDoctorToolInput,
  resolveTransferDiscoverySnapshotToolInput,
  ROOT_ONLY_DISCOVERY_TOOLS,
  SKILL_IDS,
  TRANSFER_DIRECTIONS,
} from "../src/mcp-tool-inputs-discovery-authority";
import { DISCOVERY_ROLES, DISCOVERY_SKILL_IDS } from "../src/discovery-routing";

const WS = "C:/ws";
const OUTPUT = {
  artifact_kind: "inventory-snapshot",
  id: "inventory-one",
  path: "out/inventory.json",
  format: "json",
  expected_sha256: null,
};

describe("resolveConfigureDiscoveryWorkspaceToolInput", () => {
  it("normalizes activation with an explicit profile and dry run", () => {
    expect(
      resolveConfigureDiscoveryWorkspaceToolInput({
        workspace_root: WS,
        configuration_action: "activate",
        input_path: "docs/profile.yaml",
        dry_run: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      configurationAction: "activate",
      inputPath: "docs/profile.yaml",
      dryRun: true,
    });
    expect([...CONFIGURATION_ACTIONS]).toEqual(["activate", "deactivate"]);
  });

  it.each([
    [
      "deactivate with a profile",
      { configuration_action: "deactivate", input_path: "p" },
      /input_path/,
    ],
    [
      "unknown action",
      { configuration_action: "enable" },
      /configuration action/,
    ],
    ["missing action", {}, /configuration_action/],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveConfigureDiscoveryWorkspaceToolInput({
        workspace_root: WS,
        ...args,
      }),
    ).toThrow(pattern);
  });
});

describe("resolveTransferDiscoverySnapshotToolInput", () => {
  it("normalizes an export selection and an import manifest", () => {
    expect(
      resolveTransferDiscoverySnapshotToolInput({
        workspace_root: WS,
        direction: "export",
        selected_ids: ["orders"],
        paths: ["docs/orders.yaml"],
        write: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      direction: "export",
      selectedIds: ["orders"],
      paths: ["docs/orders.yaml"],
      write: true,
    });
    expect(
      resolveTransferDiscoverySnapshotToolInput({
        workspace_root: WS,
        direction: "import",
        manifest_path: "snapshots/manifest.json",
        dry_run: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      direction: "import",
      manifestPath: "snapshots/manifest.json",
      dryRun: true,
    });
    expect([...TRANSFER_DIRECTIONS]).toEqual(["export", "import"]);
  });

  it.each([
    ["export without ids", { direction: "export" }, /selected_ids/],
    [
      "export with empty ids",
      { direction: "export", selected_ids: [] },
      /at least one/,
    ],
    [
      "export with manifest",
      { direction: "export", selected_ids: ["a"], manifest_path: "m" },
      /manifest_path/,
    ],
    [
      "import with ids",
      { direction: "import", manifest_path: "m", selected_ids: ["a"] },
      /selected_ids/,
    ],
    ["import without manifest", { direction: "import" }, /manifest_path/],
    ["unknown direction", { direction: "sync" }, /direction/],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveTransferDiscoverySnapshotToolInput({
        workspace_root: WS,
        ...args,
      }),
    ).toThrow(pattern);
  });
});

describe("resolveImportDiscoveryInventoryToolInput", () => {
  it("normalizes the manifest path and flags, and requires the manifest", () => {
    expect(
      resolveImportDiscoveryInventoryToolInput({
        workspace_root: WS,
        manifest_path: "inventory/manifest.json",
        write: true,
        dry_run: false,
      }),
    ).toEqual({
      workspaceRoot: WS,
      manifestPath: "inventory/manifest.json",
      write: true,
      dryRun: false,
    });
    expect(() =>
      resolveImportDiscoveryInventoryToolInput({ workspace_root: WS }),
    ).toThrow(/manifest_path/);
  });
});

describe("resolveMigrateDiscoveryArtifactsToolInput", () => {
  const base = {
    workspace_root: WS,
    destination: "docs/migration/discovery",
    system_id: "crm",
    system_name: "Legacy CRM",
    system_role: "legacy-source",
    repository_id: "legacy-crm",
  };

  it("normalizes a single-file migration and a multi-path migration", () => {
    expect(
      resolveMigrateDiscoveryArtifactsToolInput({
        ...base,
        input_path: "legacy/profile.yaml",
        production_roots: ["src"],
        draft: true,
        write: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      destination: "docs/migration/discovery",
      systemId: "crm",
      systemName: "Legacy CRM",
      systemRole: "legacy-source",
      repositoryId: "legacy-crm",
      inputPath: "legacy/profile.yaml",
      productionRoots: ["src"],
      draft: true,
      write: true,
    });
    expect(
      resolveMigrateDiscoveryArtifactsToolInput({
        ...base,
        paths: ["legacy/a.yaml"],
      }),
    ).toMatchObject({ paths: ["legacy/a.yaml"] });
  });

  it.each([
    ["no source", {}, /exactly one/],
    ["two sources", { input_path: "a", paths: ["b"] }, /exactly one/],
    ["unknown role", { input_path: "a", system_role: "owner" }, /system role/],
    [
      "missing destination",
      { input_path: "a", destination: undefined },
      /destination/,
    ],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveMigrateDiscoveryArtifactsToolInput({ ...base, ...args }),
    ).toThrow(pattern);
  });
});

describe("resolveRunDiscoveryDoctorToolInput", () => {
  it("accepts only the workspace and optional profile", () => {
    expect(
      resolveRunDiscoveryDoctorToolInput({
        workspace_root: WS,
        profile_path: "p.yaml",
      }),
    ).toEqual({ workspaceRoot: WS, profilePath: "p.yaml" });
    expect(resolveRunDiscoveryDoctorToolInput({}, "D:/fallback")).toEqual({
      workspaceRoot: "D:/fallback",
    });
  });
});

describe("resolveReadDiscoverySourceToolInput", () => {
  it("normalizes list, read and search operations", () => {
    expect(
      resolveReadDiscoverySourceToolInput({
        workspace_root: WS,
        read_operation: "list",
        paths: ["src"],
      }),
    ).toEqual({ workspaceRoot: WS, readOperation: "list", paths: ["src"] });
    expect(
      resolveReadDiscoverySourceToolInput({
        workspace_root: WS,
        read_operation: "read",
        paths: ["src/Order.cs"],
        line_start: 1,
        line_end: 40,
        max_bytes: 4096,
      }),
    ).toEqual({
      workspaceRoot: WS,
      readOperation: "read",
      paths: ["src/Order.cs"],
      maxBytes: 4096,
      lineStart: 1,
      lineEnd: 40,
    });
    expect(
      resolveReadDiscoverySourceToolInput({
        workspace_root: WS,
        read_operation: "search",
        paths: ["src"],
        query: "Order",
        regex: false,
        invocation_ref: "invocation-alpha-0000000001",
        authorization_ref: "authz-alpha-000000000000001",
      }),
    ).toEqual({
      workspaceRoot: WS,
      readOperation: "search",
      paths: ["src"],
      query: "Order",
      regex: false,
      invocationRef: "invocation-alpha-0000000001",
      authorizationRef: "authz-alpha-000000000000001",
      mode: "agent-output",
    });
    expect([...READ_OPERATIONS]).toEqual(["list", "read", "search"]);
  });

  it.each([
    [
      "search without query",
      { read_operation: "search", paths: ["src"] },
      /query/,
    ],
    [
      "list with query",
      { read_operation: "list", paths: ["src"], query: "x" },
      /query/,
    ],
    [
      "list with regex",
      { read_operation: "list", paths: ["src"], regex: true },
      /regex/,
    ],
    [
      "list with lines",
      { read_operation: "list", paths: ["src"], line_start: 1 },
      /line_start/,
    ],
    [
      "reversed lines",
      { read_operation: "read", paths: ["a"], line_start: 5, line_end: 2 },
      /line_start/,
    ],
    [
      "zero max_bytes",
      { read_operation: "list", paths: ["src"], max_bytes: 0 },
      /max_bytes/,
    ],
    ["missing paths", { read_operation: "list" }, /paths/],
    [
      "unknown operation",
      { read_operation: "exec", paths: ["src"] },
      /read operation/,
    ],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveReadDiscoverySourceToolInput({ workspace_root: WS, ...args }),
    ).toThrow(pattern);
  });
});

describe("resolvePrepareDiscoveryAgentToolInput", () => {
  const base = {
    workspace_root: WS,
    skill_id: "inventory-legacy-system",
    selected_ids: ["legacy-crm"],
    paths: ["src"],
    expected_outputs: [OUTPUT],
    execution_context: "standalone",
    complexity: "C2",
  };

  it("normalizes the prepare request and pins the routing enums", () => {
    expect(
      resolvePrepareDiscoveryAgentToolInput({
        ...base,
        orchestration_complexity_ceiling: "C3",
      }),
    ).toEqual({
      workspaceRoot: WS,
      skillId: "inventory-legacy-system",
      selectedIds: ["legacy-crm"],
      paths: ["src"],
      expectedOutputs: [OUTPUT],
      executionContext: "standalone",
      complexity: "C2",
      orchestrationComplexityCeiling: "C3",
    });
    expect([...SKILL_IDS]).toEqual([...DISCOVERY_SKILL_IDS]);
    expect([...EXECUTION_CONTEXTS]).toEqual([
      "standalone",
      "epic_preparation_child",
      "epic_execution_child",
    ]);
    expect([...COMPLEXITY_BANDS]).toEqual(["C1", "C2", "C3", "C4"]);
  });

  it.each([
    ["unknown skill", { skill_id: "deploy" }, /skill id/],
    ["unknown context", { execution_context: "root" }, /execution context/],
    ["unknown complexity", { complexity: "C9" }, /complexity/],
    ["empty outputs", { expected_outputs: [] }, /expected_outputs/],
    ["non-object output", { expected_outputs: ["x"] }, /expected_outputs/],
    ["missing selected_ids", { selected_ids: undefined }, /selected_ids/],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolvePrepareDiscoveryAgentToolInput({ ...base, ...args }),
    ).toThrow(pattern);
  });
});

describe("resolveFinalizeDiscoveryAgentToolInput", () => {
  it("normalizes the invocation reference and request id", () => {
    expect(
      resolveFinalizeDiscoveryAgentToolInput({
        workspace_root: WS,
        invocation_ref: "invocation-alpha",
        request_id: "request-alpha",
      }),
    ).toEqual({
      workspaceRoot: WS,
      invocationRef: "invocation-alpha",
      requestId: "request-alpha",
    });
    expect(() =>
      resolveFinalizeDiscoveryAgentToolInput({
        workspace_root: WS,
        request_id: "r",
      }),
    ).toThrow(/invocation_ref/);
  });
});

describe("role policy", () => {
  it("names exactly the root-only tools and recognises the four roles", () => {
    expect([...ROOT_ONLY_DISCOVERY_TOOLS]).toEqual([
      "run_discovery_init",
      "configure_discovery_workspace",
      "transfer_discovery_snapshot",
      "import_discovery_inventory",
      "migrate_discovery_artifacts",
      "prepare_discovery_agent",
    ]);
    expect(isRootOnlyDiscoveryTool("run_discovery_doctor")).toBe(false);
    expect(isRootOnlyDiscoveryTool("read_discovery_source")).toBe(false);
    expect(isRootOnlyDiscoveryTool("prepare_discovery_agent")).toBe(true);
    for (const role of DISCOVERY_ROLES) {
      expect(isDiscoveryRole(role)).toBe(true);
    }
    expect(isDiscoveryRole(null)).toBe(false);
    expect(isDiscoveryRole(undefined)).toBe(false);
    expect(isDiscoveryRole("native-root")).toBe(false);
    expect(
      discoveryRoleDeniedMessage(
        "prepare_discovery_agent",
        "legacy-parity-analyst",
      ),
    ).toBe(
      "DISCOVERY_ROLE_DENIED: prepare_discovery_agent is a root-only operation and is not available to the legacy-parity-analyst role.",
    );
  });
});
