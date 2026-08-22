maestro-e2e-automation

This repository contains a Maestro-style end-to-end test suite under `maestro-e2e-automation/`.

Quick actions

- Validate all YAML files locally (requires Python + PyYAML):

```bash
python -m pip install --user pyyaml
python scripts/validate_yaml.py
```

- Run the master suite (example placeholder — adapt to your runner):

```bash
# Install Maestro CLI according to your platform (example):
# npm i -g @maestro/cli
# Then run:
maestro test --file maestro-e2e-automation/master_suite.yaml
```

CI

This repo includes a ready workflow to run tests via Maestro Cloud or the local CLI: `.github/workflows/maestro-run.yml`.

Maestro Cloud (recommended):
- Add the following repository secrets (Settings → Secrets → Actions):
	- `MAESTRO_API_KEY` — your Maestro Cloud API key
	- `MAESTRO_PROJECT_ID` — your Maestro Cloud project id

When those secrets are present the workflow will use `mobile-dev-inc/action-maestro-cloud@v2` to execute tests in the cloud and upload artifacts.

CLI fallback (self-hosted or GitHub runner):
- If the Maestro Cloud secrets are not present the workflow installs the Maestro CLI and runs the suite on the runner. It produces JUnit XML at `build/reports/junit-report.xml` and artifacts under `build/artifacts/`.

Triggering from another repo: use the `repository_dispatch` event and a PAT stored in the triggering repo (see `.github/workflows/trigger-maestro-sample.yml` in the original guidance).

Files created

- `maestro-e2e-automation/master_suite.yaml` — orchestrator
- `maestro-e2e-automation/flows/*` and `maestro-e2e-automation/tests/*` — flows and tests
- `scripts/validate_yaml.py` — simple YAML validator script
- `.github/workflows/maestro-e2e.yml` — CI workflow scaffold
- `run_test.bat` — Windows runner to validate, record screen and run the master suite

Run locally (Windows)

1. Start an emulator or connect a device and verify `adb devices` lists it.
2. From the repository root run:

```powershell
.\run_test.bat
```

This batch will:
- validate YAMLs using `scripts/validate_yaml.py`
- start an on-device 720p recording (up to 30 minutes)
- run the master suite via `maestro` (falls back to `npx maestro`)
- pull the recording and reports into `build\artifacts` and `build\reports`

If you want, I can: (1) update CI to install a specific Maestro runner, (2) add Android emulator setup steps, or (3) run the suite here and capture the logs.

Simple npm helpers

After this cleanup you can use npm scripts to validate and run:

```powershell
npm run validate
npm run run
```
