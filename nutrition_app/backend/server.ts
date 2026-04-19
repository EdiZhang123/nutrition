import Anthropic from "@anthropic-ai/sdk";
import cors from "cors";
import "dotenv/config";
import express, { Request, Response } from "express";

const app = express();
app.use(cors());
app.use(express.json());

// Anthropic client — reads ANTHROPIC_API_KEY from .env automatically
const client = new Anthropic();

// ── Types ────────────────────────────────────────────────────────────────────

interface UserProfile {
  ageRange: string;
  height: string;   // e.g. "5'10\""
  weight: string;   // e.g. "165"
  lifestyle: string;
  healthGoal: string;
}

interface AnalyzeRequest {
  food: string;
  goal: string;
  profile: UserProfile;
}

// ── In-memory cache ──────────────────────────────────────────────────────────
// Keyed by normalized food name. Resets on server restart — fine for a demo.
const cache = new Map<string, object>();

// ── Prompt ───────────────────────────────────────────────────────────────────

const SYSTEM_PROMPT = `You are a concise nutrition advisor. Analyze foods across 5 lenses.
Respond ONLY with a raw JSON object — no markdown, no code fences, no explanation outside the JSON.

Required format (output exactly this structure):
{
  "food": "Proper Name",
  "summary": "2-3 sentence plain-English verdict tailored to this user's profile and primary goal.",
  "lenses": [
    { "name": "Fat Loss",            "verdict": "✅", "reason": "max 12 words, direct and specific" },
    { "name": "Muscle Gain",         "verdict": "⚠️", "reason": "max 12 words, direct and specific" },
    { "name": "Whole Foods",         "verdict": "❌", "reason": "max 12 words, direct and specific" },
    { "name": "Athletic Performance","verdict": "✅", "reason": "max 12 words, direct and specific" },
    { "name": "Budget",              "verdict": "✅", "reason": "max 12 words, direct and specific" }
  ],
  "alternatives": ["Food 1", "Food 2", "Food 3"]
}

Verdict values (use exactly): ✅ beneficial  ⚠️ moderate  ❌ avoid
summary: plain English, 2-3 sentences max, reference the user's profile and primary goal.
Reasons must be under 12 words and specific.`;

// Strip markdown code fences if the model wraps its response despite instructions
function extractJSON(text: string): string {
  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
  return fenced ? fenced[1] : text.trim();
}

// ── Routes ───────────────────────────────────────────────────────────────────

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.post("/analyze", async (req: Request, res: Response) => {
  const { food, goal, profile } = req.body as AnalyzeRequest;

  if (!food?.trim() || !goal?.trim()) {
    return res.status(400).json({ error: "food and goal are required" });
  }

  const cacheKey = `${food.toLowerCase().trim()}::${goal}`;

  if (cache.has(cacheKey)) {
    console.log(`[cache hit]  ${cacheKey}`);
    return res.json(cache.get(cacheKey));
  }

  // Compact profile string — minimizes tokens while preserving all context
  const profileLine = `age=${profile.ageRange}, ht=${profile.height}, wt=${profile.weight}lb, lifestyle=${profile.lifestyle}, goal=${profile.healthGoal}`;

  const userMessage =
    `Analyze "${food}".\n` +
    `User profile: ${profileLine}.\n` +
    `Primary lens to emphasize in reasoning: ${goal}.\n` +
    `Suggest 3 alternatives better suited for their primary goal.`;

  try {
    const message = await client.messages.create({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 500,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content: userMessage }],
    });

    const rawText =
      message.content[0].type === "text" ? message.content[0].text : "";

    const parsed = JSON.parse(extractJSON(rawText));

    cache.set(cacheKey, parsed);
    console.log(`[analyzed]   ${food}  (${message.usage.input_tokens}in / ${message.usage.output_tokens}out tokens)`);
    return res.json(parsed);
  } catch (err) {
    console.error("[error]", err);
    return res
      .status(500)
      .json({ error: "Analysis failed. Check your API key and try again." });
  }
});

// ── Start ─────────────────────────────────────────────────────────────────────

const PORT = Number(process.env.PORT ?? 3000);
app.listen(PORT, () => {
  console.log(`✅  Nutrition Lens backend running on http://localhost:${PORT}`);
});
