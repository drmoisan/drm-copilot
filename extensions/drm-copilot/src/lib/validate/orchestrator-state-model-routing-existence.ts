/** Legacy model-routing receipt existence gate. */

const DELEGATING_AGENTS: ReadonlySet<string> = new Set([
  "atomic-planner",
  "atomic-executor",
  "feature-review",
  "task-researcher",
  "prd-feature",
  "pr-author",
]);

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function delegatedAgents(state: Record<string, unknown>): Set<string> {
  const agents = new Set<string>();
  let receipts = state["delegation_receipts"];
  if (isObject(receipts)) {
    receipts = receipts["agents"];
  }
  if (Array.isArray(receipts)) {
    for (const receipt of receipts) {
      if (!isObject(receipt)) {
        continue;
      }
      const agentName = receipt["agent_name"];
      if (typeof agentName === "string" && agentName.trim().length > 0) {
        agents.add(agentName);
      }
    }
  }

  const nextStep = state["next_step"];
  if (typeof nextStep === "string" && DELEGATING_AGENTS.has(nextStep)) {
    agents.add(nextStep);
  }
  return agents;
}

/** Require one legacy model-routing receipt per delegated or pending agent. */
export function validateModelRoutingExistence(
  state: Record<string, unknown>,
): string[] {
  const delegated = delegatedAgents(state);
  if (delegated.size === 0) {
    return [];
  }

  const receiptAgents = new Set<string>();
  const receipts = state["model_routing_receipts"];
  if (Array.isArray(receipts)) {
    for (const receipt of receipts) {
      if (!isObject(receipt)) {
        continue;
      }
      const agent = receipt["agent"];
      if (typeof agent === "string" && agent.trim().length > 0) {
        receiptAgents.add(agent);
      }
    }
  }

  return [...delegated]
    .filter((agent) => !receiptAgents.has(agent))
    .sort()
    .map(
      (agent) =>
        "Checkpoint model_routing_receipts is missing a receipt for " +
        `delegated agent: ${agent}.`,
    );
}
