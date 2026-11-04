---
name: yo-revise
description: "Revise an issue's plan from feedback in chat or issue comments"
argument-hint: "Issue (e.g. 12) and your feedback"
agent: Work Buddy
---
Revise the plan for an issue in the GitHub Project. Input: ${input:feedback}

1. Identify the issue from the input or the current conversation; ask if unclear.
2. Run `./scripts/yo-gh show <ref>`; read the latest `## Plan v<n>` comment and every comment after it, plus the feedback above.
3. Re-read the existing bolts. Reuse their issue refs and post updated scope, acceptance criteria, verification, or dependencies as needed; create a new linked bolt only for genuinely new work. Follow the shared **Bolts** rules and ask before replacing or retiring existing work.
4. Post `## Plan v<n+1>` with `./scripts/yo-gh comment`, starting with "Changes since v<n>" and the exact retained, changed, and added bolt refs. Keep the parent and pending changed/new bolts in `Plan review`; this version needs fresh approval. Do not reset completed or in-progress bolts without discussing it with the human.
5. Show the revised plan and offer **Approve & implement** or **Revise plan** again.
