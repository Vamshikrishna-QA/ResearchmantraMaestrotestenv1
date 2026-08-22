# Cross-Repository CI/CD Integration Guide

This document outlines the steps required to automatically trigger the QA Maestro Automation suite whenever a new build is completed in the Development repository.

## Architecture Overview
1. **Development Repo** builds the Android `.apk`.
2. **Development Repo** uploads the `.apk` as a workflow artifact.
3. **Development Repo** triggers a `repository_dispatch` event to the **Testing Repo**.
4. **Testing Repo** receives the trigger, downloads the `.apk` from the Development Repo, boots the emulator, and runs the Maestro tests.

---

## Part 1: Tasks for the QA Team (You)

To allow the Development team to trigger your workflow, you need to provide them with a **Personal Access Token (PAT)**.

1. Go to your GitHub Settings -> **Developer settings** -> **Personal access tokens** -> **Tokens (classic)**.
2. Click **Generate new token (classic)**.
3. Give it a name (e.g., `MAESTRO_TRIGGER_TOKEN`), set expiration to `No expiration` (or 1 year), and check the **`repo`** scope.
4. Generate the token and **copy it**.
5. Send this token securely to the Developer Team.

---

## Part 2: Tasks for the Developer Team

The developers need to add two steps to the end of their existing Android build workflow (`.github/workflows/build.yml`). 

### Prerequisites
1. The Dev team must add the token provided by QA into their repository's **Secrets** as `QA_MAESTRO_TRIGGER_TOKEN`.
2. The Dev team must be uploading their `.apk` using the standard `actions/upload-artifact` step.

### Additions to the Developer's GitHub Action
Add the following steps to the end of your Android build job. This will notify the QA repository that a new build is ready and pass the ID of the workflow run so QA can download the APK.

```yaml
      # 1. Upload the APK as an artifact so the QA repo can download it
      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: app/build/outputs/apk/release/app-release.apk

      # 2. Trigger the Maestro Test Suite in the QA Repository
      - name: Trigger Maestro QA Tests
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.QA_MAESTRO_TRIGGER_TOKEN }}
          repository: Vamshikrishna-QA/ResearchmantraMaestrotestenv1
          event-type: run-maestro-tests
          client-payload: '{"run_id": "${{ github.run_id }}", "repo": "${{ github.repository }}"}'
```

---

## Part 3: What happens next?

Once the Developer Team configures this, our QA workflow is **already configured** to listen for the `run-maestro-tests` event type (via the `repository_dispatch` trigger). 

*Note: We will need to add a small step to our QA workflow to download the artifact using the `run_id` passed in the `client-payload`. Let your AI assistant know once the developers are ready, and the assistant will add the artifact download step to the QA workflow!*
