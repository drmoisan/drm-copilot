/**
 * Agent-lifecycle operations of the shared discovery service: prepare,
 * finalize and the doctor capability projection.
 *
 * Each wraps the protected-store modules around one runtime call. Prepare
 * consumes the root grant the native gate issued for the root call, pins the
 * pre-invocation baseline and the installed runtime identity through the root
 * `prepare-agent` route, then routes and persists bindings; finalize obtains
 * the authoritative `finalize-agent` result under the identity of the consumed
 * one-use authorization before minting the receipt. Host, session, parent and
 * agent values come only from those consumed records; the injected
 * {@link DiscoveryAuthorityProvider} supplies the store, clock and nonce.
 */

import type { CommandOutput } from "./command-runtime";
import type { DiscoveryAuthorityProvider } from "./discovery-authority-provider";
import type { ConsumedAuthorization } from "./discovery-authorization";
import {
  DiscoveryAuthorizationError,
  refuse,
} from "./discovery-authorization-record";
import {
  assessSessionCapability,
  missingContextAssessment,
  projectCapabilityDiagnostics,
} from "./discovery-capabilities";
import { finalizeDiscoveryInvocation } from "./discovery-finalization";
import { prepareDiscoveryInvocation } from "./discovery-invocation";
import {
  type ConsumedRootGrant,
  consumeRootGrant,
} from "./discovery-root-grant";
import {
  type DiscoveryRuntimeDependencies,
  invokeDiscoveryRuntime,
} from "./discovery-runtime";
import { consumeSentinelGrant } from "./discovery-sentinel";
import type { RepoAutomationExecutionResult } from "./repo-automation-service-contract";
import { hostInvocationOptions } from "./repo-automation-service-discovery-identity";
import type {
  DiscoveryCapabilitySentinelInput,
  FinalizeDiscoveryAgentInput,
  PrepareDiscoveryAgentInput,
  RunDiscoveryDoctorInput,
} from "./repo-automation-service-discovery-types";

export interface DiscoveryAgentOperationDeps {
  readonly output: CommandOutput;
  readonly runtime: DiscoveryRuntimeDependencies;
  readonly authority: DiscoveryAuthorityProvider;
}

/**
 * Consume the root grant of a root call when the raw tool input is known.
 *
 * Returns null when the call carries no raw input (an extension command, which
 * no host gate observed) or when no usable grant exists; doctor treats null as
 * `context-missing`, prepare refuses.
 */
function consumeOptionalRootGrant(
  authority: DiscoveryAuthorityProvider,
  workspaceRoot: string,
  tool: string,
  operation: string,
  toolInputs: Readonly<Record<string, unknown>> | undefined,
): ConsumedRootGrant | null {
  if (toolInputs === undefined) {
    return null;
  }
  try {
    return consumeRootGrant({
      location: authority.location(workspaceRoot),
      io: authority.io,
      tool,
      operation,
      inputs: toolInputs,
      now: authority.now(),
    });
  } catch (error) {
    // Every authorization refusal means no grant admits this call; other
    // failures (store I/O outside the seam's contract) propagate.
    if (error instanceof DiscoveryAuthorizationError) {
      return null;
    }
    throw error;
  }
}

/**
 * Consume the one-use sentinel grant the host gate recorded for this call and
 * report what the host observed. The result is evidence the capability probe
 * reads from the same records; it grants nothing and never fails the call.
 */
export function discoveryCapabilitySentinelOperation(
  authority: DiscoveryAuthorityProvider,
  input: DiscoveryCapabilitySentinelInput,
): RepoAutomationExecutionResult {
  const observation = consumeSentinelGrant({
    location: authority.location(input.workspaceRoot),
    io: authority.io,
    inputs: input.toolInputs,
    now: authority.now(),
  });
  return {
    tool: "discovery_capability_sentinel",
    workspaceRoot: input.workspaceRoot,
    summary: observation.observed
      ? `The host gate observed this sentinel call ${observation.agentIdPresent === true ? "with" : "without"} an agent identity.`
      : "No host observation matches this sentinel call.",
    sentinel: {
      observed: observation.observed,
      observation_ref: observation.observationRef,
      agent_id_present: observation.agentIdPresent,
      agent_type: observation.agentType,
    },
  };
}

/**
 * Project the session's host capability into a `doctor` result.
 *
 * The runtime cannot see the protected attestation, so the gateway replaces
 * its generic enforcement warning with the verified finding or one warning
 * per deficiency. Results without a discovery payload pass through unchanged.
 * The host and session come from the root grant the native gate issued for
 * this doctor call; without a grant doctor answers `context-missing` before
 * any protected path is resolved, so doctor stays diagnostic everywhere.
 */
export function projectDoctorCapability(
  authority: DiscoveryAuthorityProvider,
  input: RunDiscoveryDoctorInput,
  result: RepoAutomationExecutionResult,
): RepoAutomationExecutionResult {
  if (result.discovery === undefined) {
    return result;
  }
  const grant = consumeOptionalRootGrant(
    authority,
    input.workspaceRoot,
    "run_discovery_doctor",
    "doctor",
    input.toolInputs,
  );
  const context =
    grant === null ? null : { host: grant.host, sessionId: grant.sessionId };
  const missing = missingContextAssessment(context);
  if (missing !== null || context === null) {
    return {
      ...result,
      discovery: projectCapabilityDiagnostics(
        result.discovery,
        missing ?? missingContextAssessment(null)!,
      ),
    };
  }
  const location = authority.location(input.workspaceRoot);
  const assessment = assessSessionCapability({
    location,
    io: authority.io,
    activation: authority.activation(location),
    context,
    runtime: result.discovery.runtime,
    ...(authority.capabilityPins === undefined
      ? {}
      : { pins: authority.capabilityPins }),
    now: authority.now(),
  });
  return {
    ...result,
    discovery: projectCapabilityDiagnostics(result.discovery, assessment),
  };
}

/**
 * Prepare a constrained invocation: consume the root grant of this call, pin
 * the pre-invocation baseline and the installed runtime identity through the
 * root `prepare-agent` route, then route and persist protected bindings before
 * returning the exact deployment.
 *
 * The grant is consumed first, so a prepare the host gate did not observe
 * launches no runtime and writes nothing. The runtime checks every expected
 * output against the configured capture; a non-ok result is refused before any
 * protected write so a drifted or misplaced output can never become an
 * invocation baseline.
 */
export async function prepareDiscoveryAgentOperation(
  deps: DiscoveryAgentOperationDeps,
  input: PrepareDiscoveryAgentInput,
): Promise<RepoAutomationExecutionResult> {
  const { authority } = deps;
  if (input.toolInputs === undefined) {
    throw refuse(
      "DISCOVERY_HOST_BINDING_REQUIRED",
      "DISCOVERY_HOST_BINDING_REQUIRED: prepare_discovery_agent requires the root grant the native host gate issued for this call; no grant can be consumed without the raw tool input.",
    );
  }
  const grant = consumeRootGrant({
    location: authority.location(input.workspaceRoot),
    io: authority.io,
    tool: "prepare_discovery_agent",
    operation: "prepare-agent",
    inputs: input.toolInputs,
    now: authority.now(),
  });
  const baseline = await invokeDiscoveryRuntime(
    deps.output,
    {
      invocationId: input.invocationId ?? "prepare_discovery_agent",
      request: {
        operation: "prepare-agent",
        workspaceRoot: input.workspaceRoot,
        ...(input.profilePath === undefined
          ? {}
          : { profilePath: input.profilePath }),
        inputs: {
          skill_id: input.skillId,
          selected_ids: input.selectedIds,
          paths: input.paths,
          expected_outputs: input.expectedOutputs,
          execution_context: input.executionContext,
          complexity: input.complexity,
        },
      },
      ...(input.interpreter === undefined
        ? {}
        : { interpreter: input.interpreter }),
    },
    deps.runtime,
  );
  if (
    !baseline.ok ||
    baseline.operation !== "prepare-agent" ||
    baseline.runtime === null
  ) {
    const codes = baseline.findings.map((finding) => finding.code).join(", ");
    throw new Error(
      `DISCOVERY_PREPARE_BASELINE_FAILED: the installed runtime did not pin the pre-invocation baseline (exit ${String(baseline.exit_code)}${codes.length > 0 ? `: ${codes}` : ""}); correct the expected outputs or repair the runtime and retry.`,
    );
  }
  const location = authority.location(input.workspaceRoot);
  const prepared = prepareDiscoveryInvocation({
    location,
    io: authority.io,
    activation: authority.activation(location),
    // The launch context is the consumed grant's; a root grant names no role.
    context: {
      host: grant.host,
      sessionId: grant.sessionId,
      parentAgentId: grant.parentAgentId,
      parentRole: null,
    },
    request: {
      skill_id: input.skillId,
      selected_ids: input.selectedIds,
      paths: input.paths,
      expected_outputs: input.expectedOutputs,
      execution_context: input.executionContext,
      complexity: input.complexity,
      ...(input.orchestrationComplexityCeiling === undefined
        ? {}
        : {
            orchestration_complexity_ceiling:
              input.orchestrationComplexityCeiling,
          }),
    },
    runtime: baseline.runtime,
    baseline,
    ...(authority.capabilityPins === undefined
      ? {}
      : { pins: authority.capabilityPins }),
    now: authority.now(),
    nonce: authority.nonce,
  });
  return {
    tool: "prepare_discovery_agent",
    workspaceRoot: input.workspaceRoot,
    summary: `Prepared ${prepared.record.role} invocation ${prepared.record.invocation_id} for ${prepared.record.skill_id}.`,
    artifacts: prepared.protectedPaths,
    invocation: {
      invocation_id: prepared.record.invocation_id,
      role: prepared.record.role,
      skill_id: prepared.record.skill_id,
      deployment: prepared.deployment,
      mirror_path: prepared.mirror.relative_path,
    },
  };
}

/**
 * Finalize the calling agent's output: obtain the authoritative
 * `finalize-agent` result under the consumed authorization's identity, then
 * mint the protected receipt.
 *
 * `consumed` is the one-use record the MCP gate consumed for this finalize
 * call; without it there is no trusted identity and the call is refused.
 */
export async function finalizeDiscoveryAgentOperation(
  deps: DiscoveryAgentOperationDeps,
  input: FinalizeDiscoveryAgentInput,
  consumed: ConsumedAuthorization | undefined,
): Promise<RepoAutomationExecutionResult> {
  const { authority } = deps;
  if (
    consumed === undefined ||
    consumed.identity.invocation_id !== input.invocationRef
  ) {
    throw new Error(
      "FINALIZATION_IDENTITY_UNAVAILABLE: finalize_discovery_agent requires the one-use authorization the host gate issued for this invocation; its identity is never taken from the request or the process.",
    );
  }
  // A gated agent call cannot carry request_id (the native hook and the MCP gate
  // refuse caller identity fields), so the consumed one-use grant correlates the
  // receipt.
  const requestId = input.requestId ?? consumed.authorizationRef;
  // The finalize request runs under the host principal with the consumed
  // record's agent, session, host and role; the runtime never sees local-user here.
  const result = await invokeDiscoveryRuntime(
    deps.output,
    {
      invocationId: input.invocationId ?? input.invocationRef,
      request: {
        operation: "finalize-agent",
        mode: "agent-output",
        workspaceRoot: input.workspaceRoot,
        invocationRef: input.invocationRef,
        authorizationRef: consumed.authorizationRef,
        ...(input.profilePath === undefined
          ? {}
          : { profilePath: input.profilePath }),
      },
      ...(input.interpreter === undefined
        ? {}
        : { interpreter: input.interpreter }),
      ...hostInvocationOptions(consumed),
    },
    deps.runtime,
  );
  const location = authority.location(input.workspaceRoot);
  const finalized = finalizeDiscoveryInvocation({
    location,
    io: authority.io,
    reader: authority.reader,
    activation: authority.activation(location),
    identity: consumed.identity,
    requestId,
    result,
    writer: authority.writer,
    now: authority.now(),
    nonce: authority.nonce,
  });
  return {
    tool: "finalize_discovery_agent",
    workspaceRoot: input.workspaceRoot,
    summary: `Finalized invocation ${input.invocationRef}: ${finalized.receipt.validation_result}.`,
    artifacts: [finalized.receiptPath],
    receipt: {
      receipt_ref: finalized.receipt.receipt_ref,
      validation_result: finalized.receipt.validation_result,
      output_valid: finalized.receipt.output_valid,
      planning_authorized: finalized.planningAuthorized,
    },
    discovery: result,
  };
}
