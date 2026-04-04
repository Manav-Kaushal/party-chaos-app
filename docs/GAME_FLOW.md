# Odd One Out - Game Flow

## Overview
A multiplayer word game where players must identify who has the unique word (the "Odd One") among them.

## Rules
- 2-6 players
- Rounds = players.length - 2 (e.g., 5 players = 3 rounds)
- One player gets a unique word (odd one), others get the same word
- Sequential hint submission phase
- Voting phase to identify the odd one
- Eliminated player cannot participate in subsequent rounds
- Odd one wins if not caught; players win if odd one caught

---

## Game Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    GAME SETUP                               │
│         (Select 2-6 players, enter names)                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    START GAME                                │
│    • Random word pair selected                              │
│    • One player gets unique word (Odd One)                  │
│    • Others get the matching word                           │
│    • Rounds = players.length - 2                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
           ┌───────────────┴───────────────┐
           │         ROUND START            │
           │  (Word revealed to all players)│
           └───────────┬───────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              HINT SUBMISSION PHASE                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Players take turns giving one-word hints            │   │
│  │ (Eliminated players skip this phase)                │   │
│  │                                                      │   │
│  │ ┌────────┐    ┌────────┐    ┌────────┐               │   │
│  │ │Player 1│───▶│Player 2│───▶│Player 3│───▶ ...      │   │
│  │ │ Submit │    │ Submit │    │ Submit │               │   │
│  │ └────────┘    └────────┘    └────────┘               │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│               VOTING PHASE                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ All players (except eliminated) vote for Odd One   │   │
│  │                                                      │   │
│  │ ┌────────┐    ┌────────┐    ┌────────┐               │   │
│  │ │Player 1│───▶│Player 2│───▶│Player 3│───▶ ...      │   │
│  │ │  Vote  │    │  Vote  │    │  Vote  │               │   │
│  │ └────────┘    └────────┘    └────────┘               │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              ROUND RESULT                                    │
│  • Most voted player eliminated                             │
│  • If eliminated = Odd One → Players Win                     │
│  • If eliminated ≠ Odd One → Odd One Wins (this round)      │
│  • Same words used for next round                           │
└──────────┬──────────────────────────┬─────────────────────────┘
           │                          │
    ┌──────┴──────┐            ┌──────┴──────┐
    │ Round <     │            │ Round >=    │
    │ Total       │            │ Total       │
    └──────┬──────┘            └──────┬──────┘
           │                          │
           ▼                          ▼
┌──────────────────┐      ┌──────────────────────────────────┐
│   NEXT ROUND     │      │        GAME OVER                 │
│   (Repeat)       │      │   • Reveal Odd One               │
└────────┬─────────┘      │   • Reveal their word            │
         │                │   • Show winner                   │
         │                └─────────────┬──────────────────────┘
         │                              │
         └──────────────┬───────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    PLAY AGAIN?                               │
│         Yes → Game Setup (with previous players)           │
│         No  → Exit to Home                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase Details

### 1. Game Setup
- Player count: 2-6 players
- Each player enters their name and selects an avatar
- Press "Start Game" to begin

### 2. Round Start
- A random word pair is selected from the word bank
- One random player receives the **unique word** (Odd One)
- All other players receive the **matching word**
- Round number displayed (e.g., Round 1/3)

### 3. Hint Submission Phase
- Players take turns sequentially
- Each player submits a one-word hint
- Eliminated players cannot give hints
- When all hints submitted → Voting Phase

### 4. Voting Phase
- All non-eliminated players vote
- Each player sees all hints given
- Cannot vote for themselves
- Cannot vote for eliminated players
- When all votes cast → Round Result

### 5. Round Result
- Player with most votes is eliminated
- If eliminated player was the Odd One:
  - Players win this round
  - Game ends
- If eliminated player was NOT the Odd One:
  - Odd One wins this round
  - Continue to next round (same words)
- If last round reached → Game Over

### 6. Game Over
- Reveal the Odd One's identity
- Reveal the unique word vs matching word
- Show winner message
- Option to "Play Again" (returns to setup with previous players)

---

## Win Conditions

| Scenario | Winner |
|----------|--------|
| Odd One caught (eliminated) | Players |
| Odd One survives all rounds | Odd One |
