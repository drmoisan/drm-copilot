/**
 * Invoke the fixed installed discovery runtime with one versioned request.
 *
 * The host selects a trusted interpreter, launches
 * `python -I -m drm_copilot_discovery.gateway --workspace-root <absolute>
 * --principal <principal>` without a shell, writes exactly one canonical JSON
 * `service-request` document to stdin and validates the single JSON result on
 * stdout through `discovery-result`. No caller-selected module, program or
 * code string is ever executed, and no stdout sentence is parsed.
 */

import * as cp from "node:child_process";
import { createHash } from "node:crypto";
import * as path from "node:path";

import type { CommandOutput } from "./command-runtime";
import {
  DiscoveryTransportError,
  parseDiscoveryResult,
} from "./discovery-result";
import type {
  DiscoveryMode,
  DiscoveryOperation,
  DiscoveryOutputFormat,
  DiscoveryPrincipal,
  DiscoveryRequestInputs,
  DiscoveryServiceRequest,
  DiscoveryServiceResult,
} from "./discovery-service-types";
import { detectRuntime, type RuntimeResolution } from "./runtime-detection";

export const DISCOVERY_GATEWAY_MODULE = "drm_copilot_discovery.gateway";
export const DISCOVERY_WHEEL_FILE_NAME =
  "drm_copilot_discovery-2.0.0-py3-none-any.whl";
const REQUEST_SCHEMA = "urn:drm-copilot:discovery:2.0.0:service-request";
const MISSING_MODULE = /No module named ['"]?drm_copilot_discovery/;

/** Outcome of one runtime process, including a failed launch. */
export interface DiscoveryProcessOutcome {
  readonly exitCode: number | null;
  readonly stdout: string;
  readonly stderr: string;
  /** Set when the executable could not be started at all. */
  readonly launchError?: string;
}

/** Process seam: production spawns a child process, tests inject a fake. */
export interface DiscoveryProcessLauncher {
  launch(
    executable: string,
    args: ReadonlyArray<string>,
    options: { readonly cwd: string; readonly stdin: string },
  ): Promise<DiscoveryProcessOutcome>;
}

/** Injectable collaborators of the runtime invocation. */
export interface DiscoveryRuntimeDependencies {
  readonly launcher?: DiscoveryProcessLauncher;
  readonly detectInterpreter?: (workspaceRoot: string) => RuntimeResolution;
}

/** Pre-identity request fields supplied by an operation adapter. */
export interface DiscoveryRequestSpec {
  readonly operation: DiscoveryOperation;
  readonly mode?: DiscoveryMode;
  readonly workspaceRoot: string;
  readonly profilePath?: string;
  readonly dryRun?: boolean;
  readonly write?: boolean;
  readonly format?: DiscoveryOutputFormat;
  readonly inputs?: DiscoveryRequestInputs;
  /** Protected invocation reference for agent-output requests. */
  readonly invocationRef?: string;
  /** One-use native tool authorization reference for controlled requests. */
  readonly authorizationRef?: string;
}

/** Trusted outer invocation options chosen by the host, never by request data. */
export interface DiscoveryRuntimeInvocation {
  readonly invocationId: string;
  readonly request: DiscoveryRequestSpec;
  /** Explicit trusted interpreter path or command; defaults to runtime detection. */
  readonly interpreter?: string;
  readonly principal?: DiscoveryPrincipal;
  readonly repositoryId?: string;
  /** Local author id, or the trusted agent id when the principal is `host`. */
  readonly authorId?: string;
  /** Trusted host session id; required with principal `host`, refused otherwise. */
  readonly sessionId?: string;
  /** Trusted host name; required with principal `host`, refused otherwise. */
  readonly hostName?: string;
  /** Trusted agent role; required with principal `host`, refused otherwise. */
  readonly agentRole?: string;
}

/** Host identity options and the gateway option that carries each one. */
const HOST_IDENTITY_OPTIONS: ReadonlyArray<
  readonly [keyof DiscoveryRuntimeInvocation, string]
> = [
  ["authorId", "--author-id"],
  ["sessionId", "--session-id"],
  ["hostName", "--host-name"],
  ["agentRole", "--agent-role"],
];

function isAbsoluteWorkspaceRoot(workspaceRoot: string): boolean {
  return (
    path.isAbsolute(workspaceRoot) ||
    /^[A-Za-z]:[/\\]/.test(workspaceRoot) ||
    /^\\\\[^\\/]+[\\/][^\\/]+/.test(workspaceRoot)
  );
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map((item) => stableStringify(item)).join(",")}]`;
  }
  if (typeof value === "object" && value !== null) {
    const record = value as Record<string, unknown>;
    const members = Object.keys(record)
      .sort()
      .map((key) => `${JSON.stringify(key)}:${stableStringify(record[key])}`);
    return `{${members.join(",")}}`;
  }
  return JSON.stringify(value);
}

/**
 * Build the complete v2 service-request document for one operation.
 *
 * The identity is `host-` plus the SHA-256 of the canonical pre-identity
 * fields, so equal requests have equal ids. Host references stay null: the
 * protected invocation and authorization providers belong to later tasks.
 */
export function buildDiscoveryServiceRequest(
  spec: DiscoveryRequestSpec,
): DiscoveryServiceRequest {
  if (!isAbsoluteWorkspaceRoot(spec.workspaceRoot)) {
    throw new DiscoveryTransportError({
      code: "DISCOVERY_WORKSPACE_ROOT_INVALID",
      message: `The workspace root must be an absolute path; received ${JSON.stringify(spec.workspaceRoot)}.`,
    });
  }
  const fields = {
    operation: spec.operation,
    mode: spec.mode ?? "structural",
    workspace_root: spec.workspaceRoot,
    profile_path: spec.profilePath ?? null,
    dry_run: spec.dryRun ?? false,
    write: spec.write ?? false,
    format: spec.format ?? "json",
    inputs: spec.inputs ?? {},
  };
  const identifier =
    "host-" +
    createHash("sha256").update(stableStringify(fields), "utf8").digest("hex");
  return {
    $schema: REQUEST_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "service-request",
    id: identifier,
    request_id: identifier,
    ...fields,
    invocation_ref: spec.invocationRef ?? null,
    authorization_ref: spec.authorizationRef ?? null,
  };
}

/** Node child-process launcher: no shell, piped stdin/stdout/stderr. */
export function createNodeProcessLauncher(): DiscoveryProcessLauncher {
  return {
    launch(executable, args, options) {
      return new Promise((resolve) => {
        const stdoutChunks: string[] = [];
        const stderrChunks: string[] = [];
        let launchError: string | undefined;
        const child = cp.spawn(executable, [...args], {
          cwd: options.cwd,
          stdio: ["pipe", "pipe", "pipe"],
          shell: false,
          windowsHide: true,
        });
        child.stdout.on("data", (chunk: Buffer) => {
          stdoutChunks.push(chunk.toString("utf-8"));
        });
        child.stderr.on("data", (chunk: Buffer) => {
          stderrChunks.push(chunk.toString("utf-8"));
        });
        child.on("error", (error: Error) => {
          launchError = error.message;
          resolve({
            exitCode: null,
            stdout: stdoutChunks.join(""),
            stderr: stderrChunks.join(""),
            launchError,
          });
        });
        child.on("close", (code: number | null) => {
          if (launchError !== undefined) {
            return;
          }
          resolve({
            exitCode: code,
            stdout: stdoutChunks.join(""),
            stderr: stderrChunks.join(""),
          });
        });
        // A write failure surfaces through the 'error' event, not an exception.
        child.stdin.on("error", () => undefined);
        child.stdin.end(options.stdin, "utf-8");
      });
    },
  };
}

function resolveInterpreter(
  invocation: DiscoveryRuntimeInvocation,
  dependencies: DiscoveryRuntimeDependencies,
): RuntimeResolution {
  const configured = invocation.interpreter?.trim() ?? "";
  // A trusted explicit interpreter wins; otherwise the shared probe order applies.
  if (configured.length > 0) {
    return { executable: configured, argsPrefix: [] };
  }
  const detect =
    dependencies.detectInterpreter ??
    ((workspaceRoot: string) => detectRuntime("python", workspaceRoot));
  try {
    return detect(invocation.request.workspaceRoot);
  } catch (error: unknown) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new DiscoveryTransportError({
      code: "DISCOVERY_INTERPRETER_UNAVAILABLE",
      message: `${detail} Configure the trusted discovery interpreter, then install the runtime with: python -I -m pip install ${DISCOVERY_WHEEL_FILE_NAME}`,
    });
  }
}

/**
 * Require the trusted identity set that matches the principal.
 *
 * A `host` invocation carries the agent id, session id, host name and agent
 * role together; a `local-user` invocation carries none of the session, host
 * or role values. A partial set would let the runtime admit a host request
 * under an unverifiable identity or a local request under a host marker, so
 * either shape is refused before any process is launched.
 */
function requireHostIdentity(invocation: DiscoveryRuntimeInvocation): void {
  const principal = invocation.principal ?? "local-user";
  const supplied = HOST_IDENTITY_OPTIONS.filter(
    ([key]) => invocation[key] !== undefined,
  ).map(([, option]) => option);
  const complete = supplied.length === HOST_IDENTITY_OPTIONS.length;
  const sessionBound = supplied.some((option) => option !== "--author-id");
  if (principal === "host" ? !complete : sessionBound) {
    throw new DiscoveryTransportError({
      code: "DISCOVERY_HOST_IDENTITY_INCOMPLETE",
      message:
        principal === "host"
          ? `A host invocation requires ${HOST_IDENTITY_OPTIONS.map(([, option]) => option).join(", ")}; received ${supplied.length > 0 ? supplied.join(", ") : "none"}.`
          : `A local-user invocation cannot carry ${supplied.filter((option) => option !== "--author-id").join(", ")}.`,
    });
  }
}

function buildGatewayArgs(
  runtime: RuntimeResolution,
  invocation: DiscoveryRuntimeInvocation,
): string[] {
  requireHostIdentity(invocation);
  const args = [
    ...runtime.argsPrefix,
    "-I",
    "-m",
    DISCOVERY_GATEWAY_MODULE,
    "--workspace-root",
    invocation.request.workspaceRoot,
    "--principal",
    invocation.principal ?? "local-user",
  ];
  if (invocation.repositoryId !== undefined) {
    args.push("--repository-id", invocation.repositoryId);
  }
  // Identity options follow the fixed order the gateway's option table expects.
  for (const [key, option] of HOST_IDENTITY_OPTIONS) {
    const value = invocation[key];
    if (typeof value === "string") {
      args.push(option, value);
    }
  }
  return args;
}

/**
 * Run one request through the fixed installed runtime and validate its result.
 *
 * @returns The validated result, including non-ok results; the adapter decides
 *   how a blocking result is surfaced.
 * @throws DiscoveryTransportError when the interpreter or runtime is missing,
 *   the workspace root is not absolute, or the output is not a valid result.
 */
export async function invokeDiscoveryRuntime(
  output: CommandOutput,
  invocation: DiscoveryRuntimeInvocation,
  dependencies: DiscoveryRuntimeDependencies = {},
): Promise<DiscoveryServiceResult> {
  const request = buildDiscoveryServiceRequest(invocation.request);
  const runtime = resolveInterpreter(invocation, dependencies);
  output.appendLine(
    `[${invocation.invocationId}] runtime probe success: ${runtime.executable}`,
  );
  const args = buildGatewayArgs(runtime, invocation);
  output.appendLine(
    `[${invocation.invocationId}] gateway start: ${runtime.executable} -I -m ${DISCOVERY_GATEWAY_MODULE} (${request.operation}, ${request.mode})`,
  );
  const launcher = dependencies.launcher ?? createNodeProcessLauncher();
  const outcome = await launcher.launch(runtime.executable, args, {
    cwd: invocation.request.workspaceRoot,
    stdin: JSON.stringify(request),
  });
  if (outcome.launchError !== undefined) {
    output.appendLine(`[${invocation.invocationId}] gateway launch failure`);
    throw new DiscoveryTransportError({
      code: "DISCOVERY_INTERPRETER_UNAVAILABLE",
      message: `The interpreter ${runtime.executable} could not be started: ${outcome.launchError}. Configure the trusted discovery interpreter, then install the runtime with: python -I -m pip install ${DISCOVERY_WHEEL_FILE_NAME}`,
      stderr: outcome.stderr,
    });
  }
  output.appendLine(
    `[${invocation.invocationId}] gateway exit ${String(outcome.exitCode)}`,
  );
  // A missing installed package is reported before the result parse, because
  // the interpreter prints the import failure on stderr and no JSON at all.
  if (
    outcome.stdout.trim().length === 0 &&
    MISSING_MODULE.test(outcome.stderr)
  ) {
    throw new DiscoveryTransportError({
      code: "DISCOVERY_RUNTIME_MISSING",
      message: `The discovery runtime is not installed in ${runtime.executable}. Install it with: ${runtime.executable} -I -m pip install ${DISCOVERY_WHEEL_FILE_NAME}`,
      stderr: outcome.stderr,
      exitCode: outcome.exitCode,
    });
  }
  return parseDiscoveryResult(outcome.stdout, {
    exitCode: outcome.exitCode,
    stderr: outcome.stderr,
  });
}
