/**
 * Prove every prepare_discovery_agent refusal happens before protected I/O.
 *
 * Context, request, routing, activation and capability failures are driven
 * through the shared fixtures; each case asserts the refusal code and that the
 * store recorded no write.
 */

import { DiscoveryAuthorityError } from "../src/discovery-authority";
import { prepareDiscoveryInvocation } from "../src/discovery-invocation";
import {
  capability,
  codeOf,
  CONTEXT,
  options,
  request,
  RUNTIME,
  seeded,
  WORKSPACE,
} from "./discovery-invocation-test-support";
describe("prepareDiscoveryInvocation refusals", () => {
  it.each([
    [
      "nested self-launch",
      { parentRole: "legacy-parity-analyst" },
      "INVOCATION_NESTED_LAUNCH",
    ],
    [
      "nested reviewer launch",
      { parentRole: "migration-coverage-reviewer" },
      "INVOCATION_NESTED_LAUNCH",
    ],
    ["unknown host", { host: "shell" }, "INVOCATION_CONTEXT_INVALID"],
    ["blank session", { sessionId: "" }, "INVOCATION_CONTEXT_INVALID"],
    [
      "bad parent id",
      { parentAgentId: "has space" },
      "INVOCATION_CONTEXT_INVALID",
    ],
  ])("refuses %s before any I/O", (_label, overrides, code) => {
    const io = seeded();
    expect(
      codeOf(() =>
        prepareDiscoveryInvocation(
          options(io, { context: { ...CONTEXT, ...overrides } }),
        ),
      ),
    ).toBe(code);
    expect(io.operations).toEqual([]);
  });

  it.each([
    [
      "caller session claim",
      { session_id: "session-beta" },
      "INVOCATION_REQUEST_INVALID",
    ],
    [
      "caller role claim",
      { role: "native-root" },
      "INVOCATION_REQUEST_INVALID",
    ],
    [
      "caller capability",
      { capability: { status: "supported" } },
      "INVOCATION_REQUEST_INVALID",
    ],
    [
      "identity claim",
      { identity: { host: "codex" } },
      "AUTHORITY_CLAIM_REJECTED",
    ],
    ["destination claim", { destination: "C:/x" }, "AUTHORITY_CLAIM_REJECTED"],
    ["unknown key", { model: "gpt-6-astra" }, "INVOCATION_REQUEST_INVALID"],
    ["production write", { production_write_count: 1 }, "ROUTING_WRITE_COUNT"],
    [
      "unknown skill",
      { skill_id: "deploy-production" },
      "ROUTING_SKILL_UNKNOWN",
    ],
    ["bad complexity", { complexity: "C9" }, "ROUTING_COMPLEXITY_INVALID"],
    ["bad scope", { paths: ["../secrets"] }, "ROUTING_SCOPE_INVALID"],
    [
      "output-contract substitution",
      {
        expected_outputs: [
          {
            artifact_kind: "feature-contract",
            id: "x",
            path: "out/x.yaml",
            format: "yaml",
            expected_sha256: null,
          },
        ],
      },
      "ROUTING_OUTPUT_KIND_FORBIDDEN",
    ],
    ["missing outputs", { expected_outputs: [] }, "ROUTING_OUTPUT_INVALID"],
  ])("refuses %s before any I/O", (_label, overrides, code) => {
    const io = seeded();
    expect(
      codeOf(() =>
        prepareDiscoveryInvocation(
          options(io, {
            request: request("inventory-legacy-system", overrides),
          }),
        ),
      ),
    ).toBe(code);
    expect(io.operations).toEqual([]);
  });

  it.each([
    ["missing request keys", { skill_id: "inventory-legacy-system" }],
    ["array request", []],
    ["null request", null],
  ])("refuses %s", (_label, value) => {
    expect(
      codeOf(() =>
        prepareDiscoveryInvocation(options(seeded(), { request: value })),
      ),
    ).toBe("INVOCATION_REQUEST_INVALID");
  });

  it("refuses an unavailable model without writing anything", () => {
    const io = seeded();
    expect(
      codeOf(() =>
        prepareDiscoveryInvocation(
          options(io, { availableModels: new Set(["gpt-6-luna"]) }),
        ),
      ),
    ).toBe("ROUTING_MODEL_UNAVAILABLE");
    expect(io.operations).toEqual([]);
  });

  it("propagates an inactive activation before touching the store", () => {
    const io = seeded();
    const inactive = {
      envelope: () => {
        throw new DiscoveryAuthorityError("ACTIVATION_INACTIVE", "inactive");
      },
    };
    expect(
      codeOf(() =>
        prepareDiscoveryInvocation(options(io, { activation: inactive })),
      ),
    ).toBe("ACTIVATION_INACTIVE");
    expect(io.operations).toEqual([]);
  });

  it.each([
    ["missing attestation", null, "INVOCATION_CAPABILITY_MISSING"],
    ["malformed attestation", "{", "INVOCATION_CAPABILITY_INVALID"],
    ["array attestation", "[]", "INVOCATION_CAPABILITY_INVALID"],
    [
      "wrong schema",
      capability({ $schema: "urn:other" }),
      "INVOCATION_CAPABILITY_INVALID",
    ],
    [
      "short reference",
      capability({ attestation_ref: "short" }),
      "INVOCATION_CAPABILITY_INVALID",
    ],
    [
      "bad timestamps",
      capability({ expires_at: "soon" }),
      "INVOCATION_CAPABILITY_INVALID",
    ],
    [
      "unsupported status",
      capability({ status: "unsupported" }),
      "INVOCATION_CAPABILITY_UNSUPPORTED",
    ],
    [
      "control false",
      capability({
        controls: {
          ...(capability()["controls"] as object),
          forbidden_tools_denied: false,
        },
      }),
      "INVOCATION_CAPABILITY_UNSUPPORTED",
    ],
    [
      "probe allowed",
      capability({
        probe: { sentinel_id: "s", result: "allowed", evidence_ref: null },
      }),
      "INVOCATION_CAPABILITY_UNSUPPORTED",
    ],
    [
      "other workspace",
      capability({
        workspace: { ...WORKSPACE, profile_sha256: "9".repeat(64) },
      }),
      "INVOCATION_CAPABILITY_MISMATCH",
    ],
    [
      "other host",
      capability({ host: "claude-code" }),
      "INVOCATION_CAPABILITY_MISMATCH",
    ],
    [
      "other session",
      capability({ session_id: "session-beta" }),
      "INVOCATION_CAPABILITY_MISMATCH",
    ],
    [
      "other runtime",
      capability({ runtime: { ...RUNTIME, build_sha256: "0".repeat(64) } }),
      "INVOCATION_CAPABILITY_MISMATCH",
    ],
    [
      "expired",
      capability({ expires_at: "2026-10-22T11:59:59Z" }),
      "INVOCATION_CAPABILITY_EXPIRED",
    ],
    [
      "not yet observed",
      capability({ observed_at: "2026-10-22T12:00:01Z" }),
      "INVOCATION_CAPABILITY_EXPIRED",
    ],
  ])("refuses %s without persisting bindings", (_label, attestation, code) => {
    const io = seeded(attestation);
    expect(codeOf(() => prepareDiscoveryInvocation(options(io)))).toBe(code);
    expect(io.writtenPaths()).toEqual([]);
  });

  it("refuses a nonce that cannot form identifiers", () => {
    expect(
      codeOf(() =>
        prepareDiscoveryInvocation(
          options(seeded(), { nonce: () => "Bad-Nonce" }),
        ),
      ),
    ).toBe("INVOCATION_REQUEST_INVALID");
  });
});
