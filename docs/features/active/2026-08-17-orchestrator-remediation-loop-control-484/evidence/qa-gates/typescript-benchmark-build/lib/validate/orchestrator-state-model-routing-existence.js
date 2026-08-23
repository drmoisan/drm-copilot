"use strict";
/** Legacy model-routing receipt existence gate. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateModelRoutingExistence = validateModelRoutingExistence;
const DELEGATING_AGENTS = new Set([
    "atomic-planner",
    "atomic-executor",
    "feature-review",
    "task-researcher",
    "prd-feature",
    "pr-author",
]);
function isObject(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
function delegatedAgents(state) {
    const agents = new Set();
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
function validateModelRoutingExistence(state) {
    const delegated = delegatedAgents(state);
    if (delegated.size === 0) {
        return [];
    }
    const receiptAgents = new Set();
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
        .map((agent) => "Checkpoint model_routing_receipts is missing a receipt for " +
        `delegated agent: ${agent}.`);
}
