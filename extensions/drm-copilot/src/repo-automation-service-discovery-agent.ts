/**
 * Agent-lifecycle operations of the shared discovery service: prepare and
 * finalize.
 *
 * Both wrap the protected-store modules around one runtime call. Prepare pins
 * the pre-invocation baseline and the installed runtime identity through the
 * root `prepare-agent` route before routing and persisting bindings; finalize
 * obtains the authoritative `finalize-agent` result before minting the
 * receipt. Trusted identity comes only from the injected
 * {@link DiscoveryAuthorityProvider}.
 */

import type { CommandOutput } from "./command-runtime";
import type { DiscoveryAuthorityProvider } from "./discovery-authority-provider";
import {
  assessSessionCapability,
  missingContextAssessment,
  projectCapabilityDiagnostics,
} from "./discovery-capabilities";
import { finalizeDiscoveryInvocation } from "./discovery-finalization";
import { prepareDiscoveryInvocation } from "./discovery-invocation";
import {
  type DiscoveryRuntimeDependencies,
  invokeDiscoveryRuntime,
} from "./discovery-runtime";
import type { RepoAutomationExecutionResult } from "./repo-automation-service-contract";
import { hostInvocationOptions } from "./repo-automation-service-discovery-identity";
import type {
  FinalizeDiscoveryAgentInput,
  PrepareDiscoveryAgentInput,
} from "./repo-automation-service-discovery-types";

export interface DiscoveryAgentOperationDeps {
  readonly output: CommandOutput;
  readonly runtime: DiscoveryRuntimeDependencies;
  readonly authority: DiscoveryAuthorityProvider;
}

/**
 * Project the session's host capability into a `doctor` result.
 *
 * The runtime cannot see the protected attestation, so the gateway replaces
 * its generic enforcement warning with the verified finding or one warning
 * per deficiency. Results without a discovery payload pass through unchanged.
 * A process without a trusted host session answers `context-missing` before
 * any protected path is resolved, so doctor stays diagnostic everywhere.
 */
export function projectDoctorCapability(
  authority: DiscoveryAuthorityProvider,
  workspaceRoot: string,
  result: RepoAutomationExecutionResult,
): RepoAutomationExecutionResult {
  if (result.discovery === undefined) {
    return result;
  }
  const missing = missingContextAssessment(authority.context);
  if (missing !== null) {
    return {
      ...result,
      discovery: projectCapabilityDiagnostics(result.discovery, missing),
    };
  }
  const location = authority.location(workspaceRoot);
  const assessment = assessSessionCapability({
    location,
    io: authority.io,
    activation: authority.activation(location),
    context: authority.context,
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
 * Prepare a constrained invocation: pin the pre-invocation baseline and the
 * installed runtime identity through the root `prepare-agent` route, then
 * route and persist protected bindings before returning the exact deployment.
 *
 * The runtime checks every expected output against the configured capture; a
 * non-ok result is refused before any protected write so a drifted or
 * misplaced output can never become an invocation baseline.
 */
export async function prepareDiscoveryAgentOperation(
  deps: DiscoveryAgentOperationDeps,
  input: PrepareDiscoveryAgentInput,
): Promise<RepoAutomationExecutionResult> {
  const { authority } = deps;
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
    context: authority.context,
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
 * `finalize-agent` result, then mint the protected receipt.
 */
export async function finalizeDiscoveryAgentOperation(
  deps: DiscoveryAgentOperationDeps,
  input: FinalizeDiscoveryAgentInput,
): Promise<RepoAutomationExecutionResult> {
  const { authority } = deps;
  if (authority.agent === null) {
    throw new Error(
      "FINALIZATION_IDENTITY_UNAVAILABLE: finalize_discovery_agent requires the trusted discovery agent identity of this process.",
    );
  }
  // The finalize request runs under the host principal with the trusted
  // agent, session, host and role values; the runtime never sees local-user here.
  const result = await invokeDiscoveryRuntime(
    deps.output,
    {
      invocationId: input.invocationId ?? input.invocationRef,
      request: {
        operation: "finalize-agent",
        mode: "agent-output",
        workspaceRoot: input.workspaceRoot,
        invocationRef: input.invocationRef,
        ...(input.profilePath === undefined
          ? {}
          : { profilePath: input.profilePath }),
      },
      ...(input.interpreter === undefined
        ? {}
        : { interpreter: input.interpreter }),
      ...hostInvocationOptions(authority),
    },
    deps.runtime,
  );
  const location = authority.location(input.workspaceRoot);
  const finalized = finalizeDiscoveryInvocation({
    location,
    io: authority.io,
    reader: authority.reader,
    activation: authority.activation(location),
    identity: {
      host: authority.context.host,
      session_id: authority.context.sessionId,
      agent_id: authority.agent.agentId,
      role: authority.agent.role,
      invocation_id: input.invocationRef,
    },
    requestId: input.requestId,
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
