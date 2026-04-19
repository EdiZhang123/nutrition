# Nutrition Lens — Claude.md

You are building a hackathon MVP called **"Nutrition Lens"** — a web app that helps users understand conflicting nutrition advice by showing how different dietary frameworks evaluate the same food.

---

# Goal

Build an **iOS mobile app** where a user inputs a food and receives structured evaluations across multiple “nutrition lenses.”

---

# Core Concept

We want to make nutrition information more accessible.

Because there is so much misinformation and conflicting advice online, it is hard to know what to believe—especially for individual cases.

Different nutrition philosophies judge foods differently. Instead of claiming one truth, the app compares perspectives.

---

# Lenses to Include

## Personal Health Profile (collected at signup)
- Age range  
- Height  
- Weight  
- Lifestyle  
- Personal health goals  

---

## Health Goals Lenses
- Fat Loss  
- Muscle Gain  
- Whole Foods / Clean Eating  
- Athletic Performance  

---

## Constraints Lens
- Budget  
- Cost efficiency  

---

# User Flow

1. User types a food (e.g., "protein bar", "white rice", "eggs")
2. User selects a primary goal (one of the lenses)
3. App displays:

### Results (Card or Table Format)
For each lens:
- Lens name  
- Verdict (✅ good / ⚠️ moderate / ❌ avoid)  
- Short reasoning (1 sentence, clear and direct)

Highlight the user’s selected lens.

---

### Below Results:
- "Better alternatives for your goal" (2–3 items)

---

# Output Format (IMPORTANT)

All responses must follow this JSON structure:

```json
{
  "food": "string",
  "lenses": [
    {
      "name": "Fat Loss",
      "verdict": "✅",
      "reason": "..."
    }
  ],
  "alternatives": ["food1", "food2", "food3"]
}
