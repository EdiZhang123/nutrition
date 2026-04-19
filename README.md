# Nutrition Lens

An iOS app that cuts through conflicting nutrition advice by showing how different dietary frameworks evaluate the same food — personalized to your profile and goals.

---

## The Problem

Nutrition advice is everywhere and contradicts itself constantly. Is white rice good or bad? Depends who you ask. Instead of claiming one truth, Nutrition Lens shows you multiple perspectives at once so you can decide what fits your life.

---

## How It Works

1. Complete a one-time profile (age, height, weight, lifestyle, primary goal)
2. Type any food
3. Select a lens to emphasize
4. Get instant verdicts across 5 frameworks — tailored to you
5. Tap any suggested alternative to analyze it directly

---

## Lenses

| Lens | Focus |
|------|-------|
| 🔥 Fat Loss | Calories, satiety, glycemic impact |
| 💪 Muscle Gain | Protein quality, amino acid profile |
| 🌿 Whole Foods | Processing level, ingredient quality |
| ⚡ Athletic Performance | Energy, recovery, timing |
| 💵 Budget | Cost per gram of protein, availability |

---

## Stack

**iOS App**
- SwiftUI
- AppStorage for user profile persistence

**Backend**
- Node.js + Express + TypeScript
- Anthropic Claude Haiku — analyzes any food via structured prompt
- In-memory cache keyed by food + goal (resets on restart)

---

## Setup

### Backend

```bash
cd nutrition_app/backend
npm install
```

Create a `.env` file:
```
ANTHROPIC_API_KEY=your-key-here
PORT=3000
```

Start the server:
```bash
npm run dev
```

You should see:
```
✅  Nutrition Lens backend running on http://localhost:3000
```

### iOS App

Open `nutrition_app/nutrition_app.xcodeproj` in Xcode and run on simulator or device. Make sure the backend is running first — the app falls back to mock data if it can't reach `localhost:3000`.

---

## Project Structure

```
nutrition2/
├── nutrition_app/
│   ├── backend/
│   │   ├── server.ts          # Express server + Claude integration
│   │   ├── .env               # API key (not committed)
│   │   └── package.json
│   └── nutrition_app/
│       ├── ContentView.swift       # Root router (onboarding → search)
│       ├── OnboardingView.swift    # 4-step profile setup
│       ├── SearchView.swift        # Food input + lens selection
│       ├── ResultsView.swift       # Lens cards + alternatives
│       ├── NutritionService.swift  # Backend networking + mock fallback
│       └── Models.swift            # Data models
```

---

## API

**POST** `/analyze`

Request:
```json
{
  "food": "white rice",
  "goal": "Fat Loss",
  "profile": {
    "ageRange": "18–25",
    "height": "5'10\"",
    "weight": "165",
    "lifestyle": "Moderately Active",
    "healthGoal": "Fat Loss"
  }
}
```

Response:
```json
{
  "food": "White Rice",
  "summary": "White rice is a fast-digesting carb that works well around workouts but isn't ideal for fat loss on its own.",
  "lenses": [
    { "name": "Fat Loss", "verdict": "⚠️", "reason": "High glycemic index — pair with protein to blunt spike." },
    { "name": "Muscle Gain", "verdict": "✅", "reason": "Fast carbs replenish glycogen quickly post-training." }
  ],
  "alternatives": ["Brown rice", "Quinoa", "Sweet potato"]
}
```
