# MONU Planner (iOS)

A thoughtfully designed personal planning app that helps users organize goals, habits, and daily focus — built with a strong emphasis on **UX clarity**, **real-world state handling**, and **production-ready architecture**.

## Overview

MONU is a personal planning companion designed to support intentional goal-setting and daily execution without overwhelming the user.  
The app focuses on clarity, calm visual structure, and predictable behavior across empty, loading, and failure states.

This repository contains the **native iOS implementation** of MONU, built with SwiftUI and backed by AWS services.

## Key Features

- Daily planning with time-aware tasks
- Habit tracking with progress visualization
- Yearly goals and future vision planning
- Pomodoro-style focus sessions
- Calm, minimal UI inspired by physical planners
- Persistent user data across sessions

## UX & Product Focus

This project prioritizes how the app behaves when things are *not* ideal:

- Clear empty states for first-time users
- Explicit loading and saving feedback
- Graceful error handling and recovery
- Predictable navigation and state transitions
- Interfaces designed to reduce cognitive load

The goal is not feature density, but **trust and usability**.

## Architecture

- **UI**: SwiftUI with modular, reusable views
- **State Management**: ViewModels with clear separation of concerns
- **Authentication**: AWS Cognito
- **Data Layer**: AWS Amplify + GraphQL
- **Persistence**: Cloud-backed user data (no local-only assumptions)

The codebase is structured to support incremental feature growth without rewriting core flows.

## Tech Stack

- SwiftUI
- AWS Amplify
- Cognito (Auth)
- GraphQL API
- Cloud-backed storage
- Modular MVVM-style architecture

## Status

MONU is an active, evolving product.  
Features are added iteratively with an emphasis on stability, UX consistency, and real-world usage patterns.

## Related Work

- **MONU Planner Website** — marketing site + App Store compliance
- **AI Chat Demo** — UX-state–driven chat interface (separate repository)

## About the Author

Built by Ashley Chang, a full-stack engineer focused on building production-ready products with strong UX foundations.

Open to software engineering internships.
