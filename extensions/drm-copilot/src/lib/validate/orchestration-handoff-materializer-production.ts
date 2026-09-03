import * as fs from "node:fs";

import type { FileSystem } from "../file-system";
import type { CommandRunner } from "../subprocess-runner";
import type { PortableHandoffProvider } from "../../mcp-repo-automation-tool-definitions-handoff";
import {
  HandoffContractError,
  parseHandoffEnvelopeText,
} from "./orchestration-handoff-contract";
import {
  OrchestrationHandoffMaterializer,
  type HandoffEnvelopeValidationResult,
  type HandoffMaterializerDependencies,
} from "./orchestration-handoff-materializer";
import { providerAdapterFor } from "./orchestration-handoff-provider-adapters";
import { resolvePortableHandoffAuthority } from "./orchestration-handoff-authority-service";
import { createNodeHandoffPathBoundary } from "./orchestration-handoff-path-boundary";

function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function validateEnvelope(text: string): HandoffEnvelopeValidationResult {
  try {
    return {
      envelope: parseHandoffEnvelopeText(text),
      primaryFailureCode: null,
      affectedPaths: [],
      unsupportedCapabilities: [],
    };
  } catch (error: unknown) {
    return {
      envelope: null,
      primaryFailureCode:
        error instanceof HandoffContractError
          ? error.code
          : "HANDOFF_UNSUPPORTED_VERSION",
      affectedPaths: [],
      unsupportedCapabilities: [],
    };
  }
}

function validateDestinationProjection(text: string): readonly string[] {
  let value: unknown;
  try {
    value = JSON.parse(text);
  } catch {
    return ["destination checkpoint must be valid JSON"];
  }
  if (!isRecord(value)) return ["destination checkpoint must be an object"];
  const provider = value["provider"];
  if (provider !== "claude" && provider !== "codex") {
    return ["destination checkpoint provider is invalid"];
  }
  const adapter = providerAdapterFor(provider as PortableHandoffProvider);
  const evidence = value["destination_evidence"];
  if (
    value["checkpoint_expression"] !== adapter.checkpointExpression ||
    value["destination_projector"] !== adapter.destinationProjector ||
    typeof value["plan-path"] !== "string" ||
    typeof value["next_step"] !== "string" ||
    !isRecord(value["portable_handoff"]) ||
    !isRecord(evidence) ||
    evidence["status"] !== "pending_first_delegation" ||
    !Array.isArray(evidence["receipts"]) ||
    evidence["receipts"].length !== 0
  ) {
    return ["destination checkpoint projection is invalid"];
  }
  return [];
}

function buildDependencies(
  fileSystem: FileSystem,
  runner: CommandRunner,
): HandoffMaterializerDependencies {
  const pathBoundary = createNodeHandoffPathBoundary();
  return {
    fileSystem: {
      readFile: (filePath) => fs.readFileSync(filePath),
      createDirectory: (directoryPath) =>
        fs.mkdirSync(directoryPath, { recursive: true }),
      writeFile: (filePath, content, options) =>
        fs.writeFileSync(filePath, content, {
          flag: options?.exclusive === true ? "wx" : "w",
        }),
      replaceFile: (candidatePath, destinationPath) =>
        fs.renameSync(candidatePath, destinationPath),
      removeFile: (filePath) => fs.unlinkSync(filePath),
    },
    pathBoundary,
    git: {
      readPorcelainStatus: async (workspaceRoot) =>
        runner.run(["git", "status", "--porcelain=v1"], {
          cwd: workspaceRoot,
        }).stdout,
    },
    topology: {
      resolve: async (request) =>
        resolvePortableHandoffAuthority(
          fileSystem,
          request,
          "topology",
          pathBoundary,
        ),
    },
    routing: {
      resolve: async (request) =>
        resolvePortableHandoffAuthority(
          fileSystem,
          request,
          "provider_routing",
          pathBoundary,
        ),
    },
    validator: { validateEnvelope, validateDestinationProjection },
    clock: { nowIso8601: () => new Date().toISOString() },
  };
}

/** Build the production transition coordinator from repository I/O boundaries. */
export function createProductionHandoffMaterializer(
  fileSystem: FileSystem,
  runner: CommandRunner,
): OrchestrationHandoffMaterializer {
  return new OrchestrationHandoffMaterializer(
    buildDependencies(fileSystem, runner),
  );
}
