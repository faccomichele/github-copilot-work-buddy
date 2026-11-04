---
name: yo-capture
description: "Quickly add a new idea or task to the project backlog"
argument-hint: "What needs doing (mention repos, goal, urgency if known)"
agent: Work Buddy
---
Create a new issue in the GitHub Project from: ${input:idea}

1. Write a concise imperative title and a short Markdown body (context, expected outcome).
2. Keep the issue in the tracking repo unless another issue home is explicitly requested. Confirm code targets, allow multiple short `repo:<name>` labels, and resolve them with `./scripts/yo-gh resolve-repos` (short-label default is the tracking repo owner; `YO_REPO_OWNER` overrides it, and explicit `repo:owner/name` preserves its owner). These labels identify code targets, not where the issue must live. Planning creates the bolt sub-issues; do not pre-split by repo during capture.
3. Run `./scripts/yo-gh goals`; if the work clearly serves an existing goal, use it (`--milestone` applies only to issues in the tracking repo). Do not invent a goal; suggest `/yo-goal` if none fits.
4. Set priority only if stated or clearly implied.
5. Run `./scripts/yo-gh create` with `--status Backlog` (or `Todo` if the human says it is for now).
6. Reply with `owner/repo#n Title`, goal, priority, and the link.
