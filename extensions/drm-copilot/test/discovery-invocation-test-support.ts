/**
 * Shared fixtures for the discovery invocation suites.
 *
 * The protected location, workspace binding, runtime identity, trusted
 * context, a supported capability attestation builder, a prepare request
 * builder, a seeded in-memory store and the option factory live here so the
 * prepare, refusal and record suites exercise one consistent setup.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { DiscoveryAuthorityError } from "../src/discovery-authority";
import {
  type AuthorityLocation,
  resolveAuthorityLocation,
  sessionDirectory,
} from "../src/discovery-authority-paths";
import {
  CAPABILITY_ATTESTATION_FILE,
  CAPABILITY_ATTESTATION_SCHEMA,
  DiscoveryInvocationError,
  type PrepareContext,
  type PrepareOptions,
} from "../src/discovery-invocation";
import { DiscoveryRoutingError } from "../src/discovery-routing";
import type { DiscoveryServiceResult } from "../src/discovery-service-types";
import { DISCOVERY_OPERATIONS } from "../src/lib/validate/codex-discovery-routing";
import { MemoryStoreIO } from "./discovery-store-test-helpers";
import { buildServiceResult } from "./discovery-test-helpers";
export const SCHEMA_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "schemas",
  "discovery",
  "v2",
  "discovery-invocation.schema.json",
);
export const INVOCATION_SCHEMA = JSON.parse(
  fs.readFileSync(SCHEMA_PATH, "utf8"),
) as {
  required: string[];
};

export const LOCATION: AuthorityLocation = resolveAuthorityLocation(
  "C:/Users/Example/Repos/Workspace",
  {
    platform: "windows",
    userHome: "C:/Users/Example",
    localAppData: "C:/Users/Example/AppData/Local",
  },
);
export const WORKSPACE = {
  workspace_root: LOCATION.workspace,
  workspace_sha256: LOCATION.workspaceSha256,
  profile_path: "docs/migration/discovery/domain-profile.yaml",
  profile_sha256: "b".repeat(64),
};
export const RUNTIME = {
  package_version: "2.0.0",
  schema_version: "2.0.0",
  build_sha256: "c".repeat(64),
  policy_version: 1,
  policy_sha256: "d".repeat(64),
};
export const CONTEXT: PrepareContext = {
  host: "codex",
  sessionId: "session-alpha",
  parentAgentId: "root-alpha",
  parentRole: null,
};
export const NOW = new Date("2026-10-22T12:00:00Z");
export const ACTIVATION = {
  envelope: () => ({
    workspace: WORKSPACE,
    activation_sha256: "e".repeat(64),
    generation: 1,
  }),
};

export function capability(
  overrides: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    $schema: CAPABILITY_ATTESTATION_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "capability-attestation",
    id: "capability-alpha",
    attestation_ref: "attestation-alpha-00000000001",
    workspace: WORKSPACE,
    host: "codex",
    session_id: "session-alpha",
    runtime: RUNTIME,
    configuration_sha256: "f".repeat(64),
    handlers: ["start", "tool", "stop"].map((event) => ({
      event,
      path: `hooks/${event}.ps1`,
      sha256: "1".repeat(64),
    })),
    controls: Object.fromEntries(
      [
        "workspace_trusted",
        "hooks_enabled",
        "trusted_attribution",
        "start_event",
        "tool_event",
        "stop_event",
        "forbidden_tools_denied",
      ].map((name) => [name, true]),
    ),
    probe: {
      sentinel_id: "sentinel-alpha",
      result: "denied",
      evidence_ref: "evidence-alpha-000000000001",
    },
    status: "supported",
    findings: [],
    observed_at: "2026-10-22T11:50:00Z",
    expires_at: "2026-10-22T12:50:00Z",
    ...overrides,
  };
}

export function request(
  skillId = "inventory-legacy-system",
  overrides: Record<string, unknown> = {},
) {
  const kind = DISCOVERY_OPERATIONS[skillId]!.permissible_artifact_kinds[0]!;
  return {
    skill_id: skillId,
    selected_ids: ["legacy-crm"],
    paths: ["src/Orders"],
    expected_outputs: [
      {
        artifact_kind: kind,
        id: "output-one",
        path: `out/${kind}.json`,
        format: "json",
        expected_sha256: null,
      },
    ],
    execution_context: "standalone",
    complexity: "C2",
    ...overrides,
  };
}

/** An ok `prepare-agent` result of RUNTIME: the baseline the prepare flow persists. */
export function baselineResult(
  overrides: Partial<DiscoveryServiceResult> = {},
): DiscoveryServiceResult {
  return buildServiceResult({
    operation: "prepare-agent",
    mode: "structural",
    summary: {
      message: "Operation passed.",
      counts: [
        { name: "expected_outputs", value: 1 },
        { name: "existing_outputs", value: 0 },
      ],
      validation_result: null,
      receipt_ref: null,
      invocation_ref: null,
    },
    input_manifest: {
      entries: [
        {
          path: WORKSPACE.profile_path,
          sha256: WORKSPACE.profile_sha256,
          size: 32,
          category: "profile",
        },
      ],
      missing_paths: [],
      source_repositories: [],
      target_repositories: [],
      sha256: "a".repeat(64),
    },
    runtime: RUNTIME,
    ...overrides,
  });
}

export function seeded(
  attestation: Record<string, unknown> | string | null = capability(),
): MemoryStoreIO {
  const io = new MemoryStoreIO();
  if (attestation !== null) {
    io.files.set(
      `${sessionDirectory(LOCATION, CONTEXT.sessionId)}/${CAPABILITY_ATTESTATION_FILE}`,
      typeof attestation === "string"
        ? attestation
        : JSON.stringify(attestation),
    );
  }
  return io;
}

export function options(
  io: MemoryStoreIO,
  overrides: Partial<PrepareOptions> = {},
): PrepareOptions {
  let counter = 0;
  return {
    location: LOCATION,
    io,
    activation: ACTIVATION,
    context: CONTEXT,
    request: request(),
    runtime: RUNTIME,
    baseline: baselineResult(),
    now: NOW,
    nonce: () => {
      counter += 1;
      return `0123456789abcdef${String(counter).padStart(4, "0")}`;
    },
    ...overrides,
  };
}

export function codeOf(action: () => unknown): string {
  try {
    action();
  } catch (error) {
    if (
      error instanceof DiscoveryInvocationError ||
      error instanceof DiscoveryRoutingError ||
      error instanceof DiscoveryAuthorityError
    ) {
      return error.code;
    }
    throw error;
  }
  return "NO_ERROR";
}
