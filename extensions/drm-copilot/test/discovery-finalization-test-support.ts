/**
 * Shared fixtures for the discovery finalization suites.
 *
 * A scenario prepares an invocation through the P8-T4 flow, populates an
 * in-memory workspace with the profile, one source input and the required
 * output, and builds the matching `finalize-agent` service result, so the
 * receipt and refusal suites exercise one consistent end-to-end setup.
 */

import {
  DiscoveryFinalizationError,
  type FinalizationOptions,
} from "../src/discovery-finalization";
import {
  DiscoveryInputManifestError,
  workspacePath,
} from "../src/discovery-input-manifest";
import {
  DiscoveryInvocationError,
  prepareDiscoveryInvocation,
} from "../src/discovery-invocation";
import type { DiscoveryServiceResult } from "../src/discovery-service-types";
import {
  capability,
  LOCATION,
  options,
  request,
  RUNTIME,
  seeded,
  WORKSPACE,
} from "./discovery-invocation-test-support";
import {
  digestOf,
  MemoryInputReader,
  type MemoryStoreIO,
} from "./discovery-store-test-helpers";
import {
  buildBlockingResult,
  buildServiceResult,
} from "./discovery-test-helpers";
export const PROFILE_TEXT = "schema_version: 2.0.0\nname: example\n";
export const SOURCE = "src/Orders/Order.cs";
export const SOURCE_TEXT = "public class Order {}\n";
export const MISSING = "docs/migration/discovery/scope.yaml";
export const WS = { ...WORKSPACE, profile_sha256: digestOf(PROFILE_TEXT) };
export const ACTIVATION = {
  envelope: () => ({
    workspace: WS,
    activation_sha256: "e".repeat(64),
    generation: 1,
  }),
};
export const NOW = new Date("2026-10-22T12:30:00Z");
export const WRITER = {
  component: "extension" as const,
  id: "gateway-alpha",
  build_sha256: "f".repeat(64),
};

export interface Scenario {
  io: MemoryStoreIO;
  reader: MemoryInputReader;
  invocationId: string;
  role: string;
  outputPath: string;
  outputKind: string;
  outputText: string;
}

export function scenario(skillId = "inventory-legacy-system"): Scenario {
  const io = seeded(capability({ workspace: WS }));
  const prepared = prepareDiscoveryInvocation(
    options(io, { activation: ACTIVATION, request: request(skillId) }),
  );
  const output = prepared.record.required_outputs.outputs[0]!;
  const outputText = `{"kind": "${output.artifact_kind}"}\n`;
  const reader = new MemoryInputReader();
  reader.write(workspacePath(WS.workspace_root, WS.profile_path), PROFILE_TEXT);
  reader.write(workspacePath(WS.workspace_root, SOURCE), SOURCE_TEXT);
  reader.write(workspacePath(WS.workspace_root, output.path), outputText);
  return {
    io,
    reader,
    invocationId: prepared.record.invocation_id,
    role: prepared.record.role,
    outputPath: output.path,
    outputKind: output.artifact_kind,
    outputText,
  };
}

export function entry(relative: string, text: string, category: string) {
  return {
    path: relative,
    sha256: digestOf(text),
    size: new TextEncoder().encode(text).byteLength,
    category,
  };
}

export function result(
  scene: Scenario,
  overrides: Partial<DiscoveryServiceResult> = {},
): DiscoveryServiceResult {
  return buildServiceResult({
    operation: "finalize-agent",
    mode: "agent-output",
    artifacts: [
      {
        path: scene.outputPath,
        kind: scene.outputKind,
        status: "created",
        sha256: digestOf(scene.outputText),
      },
    ],
    summary: {
      message: "Role output validated.",
      counts: [],
      validation_result: "pass",
      receipt_ref: null,
      invocation_ref: scene.invocationId,
    },
    input_manifest: {
      entries: [
        entry(WS.profile_path, PROFILE_TEXT, "profile"),
        entry(SOURCE, SOURCE_TEXT, "source"),
      ],
      missing_paths: [MISSING],
      source_repositories: [{ id: "legacy-crm", revision: "a".repeat(40) }],
      target_repositories: [],
      sha256: "0".repeat(64),
    },
    runtime: RUNTIME,
    ...overrides,
  });
}

export function failingResult(scene: Scenario): DiscoveryServiceResult {
  const base = result(scene);
  const blocking = buildBlockingResult();
  return {
    ...base,
    ok: false,
    exit_code: 1,
    findings: blocking.findings,
    summary: { ...base.summary, validation_result: "fail" },
  };
}

export function finalizeOptions(
  scene: Scenario,
  overrides: Partial<FinalizationOptions> = {},
): FinalizationOptions {
  return {
    location: LOCATION,
    io: scene.io,
    reader: scene.reader,
    activation: ACTIVATION,
    identity: {
      host: "codex",
      session_id: "session-alpha",
      agent_id: "agent-alpha",
      role: scene.role,
      invocation_id: scene.invocationId,
    },
    requestId: "request-finalize",
    result: result(scene),
    writer: WRITER,
    now: NOW,
    nonce: () => "fedcba9876543210",
    ...overrides,
  };
}

export function codeOf(action: () => unknown): string {
  try {
    action();
  } catch (error) {
    if (
      error instanceof DiscoveryFinalizationError ||
      error instanceof DiscoveryInputManifestError ||
      error instanceof DiscoveryInvocationError
    ) {
      return error.code;
    }
    throw error;
  }
  return "NO_ERROR";
}
