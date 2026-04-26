# 🧺 Pantry Pilot

[![Security & CI](https://github.com/RealWorldApplications/pantry_pilot/actions/workflows/security_and_ci.yml/badge.svg)](https://github.com/RealWorldApplications/pantry_pilot/actions/workflows/security_and_ci.yml)
[![Dependabot](https://img.shields.io/badge/Dependabot-active-brightgreen.svg)](https://github.com/RealWorldApplications/pantry_pilot/network/updates)

A modern Flutter application designed to help you manage your pantry with ease, featuring intelligent scanning and inventory tracking.

## 🛡️ Security & Quality

This project is configured with several security and quality checks to ensure a robust codebase:

- **Static Analysis**: Custom `analysis_options.yaml` with strict linting rules to catch common security pitfalls and bugs early.
- **Automated Workflows**: GitHub Actions run on every push to verify:
  - Code formatting (`dart format`)
  - Static analysis (`flutter analyze`)
  - Vulnerable dependency check (`flutter pub outdated --fatal-security`)
  - Unit & Widget tests
- **Dependency Management**: Dependabot is configured to automatically scan and suggest updates for vulnerable packages.

## 🚀 Getting Started

1. Clone the repository.
2. Run `flutter pub get`.
3. Create a `.env` file (see `.env.example` if available) with your API keys.
4. Run `flutter run`.

---
*Generated with ❤️ by Pantry Pilot Team*
