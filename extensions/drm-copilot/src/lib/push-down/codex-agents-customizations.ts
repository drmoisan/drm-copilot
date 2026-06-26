/**
 * Codex/agents customization push-down publisher.
 *
 * Purpose:
 *     Port `push_down_codex_and_agents_customizations.py`. Provides a dedicated
 *     entry point for publishing the bundled `.codex` and `.agents` trees while
 *     reusing the shared copilot push-down engine.
 *
 * Side effects:
 *     Delegates all filesystem I/O to the injected {@link PushDownFileSystem}
 *     via the shared engine.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import {
  type Clock,
  pushDownCustomizations as enginePushDown,
  type PushDownSummary,
} from "./copilot-customizations-engine";

/** Artifact directory for the Codex/agents push-down summary. */
export const ARTIFACT_DIRECTORY = "artifacts/codex-and-agents-customizations";

/** Inlined Codex/agents scoped root folders (enumeration-order contract). */
export const ROOT_FOLDERS: ReadonlyArray<string> = [".codex", ".agents"];

/**
 * Passthrough rewrite for payloads that do not need command rewrites.
 *
 * Mirrors the Python `_passthrough_rewrite`: returns the text unchanged with
 * zero rewrite/placeholder counts and no unmatched references.
 *
 * @param text Source text.
 * @returns A tuple `[text, 0, 0, []]`.
 */
export function passthroughRewrite(
  text: string,
): [string, number, number, string[]] {
  return [text, 0, 0, []];
}

/** Options for the Codex/agents {@link pushDownCustomizations} entry point. */
export interface CodexAgentsPushDownOptions {
  readonly repoRoot: string;
  readonly destinationRoot: string;
  readonly fs: PushDownFileSystem;
  readonly sourceRoot?: string;
  readonly artifactRoot?: string;
  readonly clock?: Clock;
}

/**
 * Copy the bundled `.codex` and `.agents` trees into the destination workspace.
 *
 * Delegates to the shared engine with the Codex/agents root folders, artifact
 * directory, and the passthrough rewrite (no command-reference rewriting).
 *
 * @param options Entry options (roots, filesystem, optional clock).
 * @returns The completed run summary including the written artifact path.
 * @throws Error When destination validation fails.
 */
export function pushDownCustomizations(
  options: CodexAgentsPushDownOptions,
): PushDownSummary {
  return enginePushDown({
    repoRoot: options.repoRoot,
    destinationRoot: options.destinationRoot,
    fs: options.fs,
    ...(options.sourceRoot === undefined
      ? {}
      : { sourceRoot: options.sourceRoot }),
    ...(options.artifactRoot === undefined
      ? {}
      : { artifactRoot: options.artifactRoot }),
    rootFolders: ROOT_FOLDERS,
    artifactDirectory: ARTIFACT_DIRECTORY,
    rewriteReferences: passthroughRewrite,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  });
}
