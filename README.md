# LaunchPad — website + 2 Jenkins pipelines

Open this folder in VS Code. `index.html` is a static demo site (no Node.js required).

## Run the website locally
Open `index.html` in a browser, or use the VS Code Live Server extension.

## Push to GitHub
Create an empty repository called `website-jenkins-project` in GitHub. In the VS Code terminal, run:

```bash
git init
git add .
git commit -m "Add website and Jenkins pipelines"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/website-jenkins-project.git
git push -u origin main
```

Replace `YOUR_USERNAME`. Authenticate using GitHub's supported sign-in flow (not your GitHub account password).

## Jenkins requirements
- Jenkins with Pipeline, Git, GitHub Branch Source, and a compatible GitHub webhook integration.
- A Linux/Unix build agent with `bash`, `grep`, `cp`, and `mkdir`.
- GitHub credentials configured in Jenkins for private repositories.
- A Jenkins HTTPS URL reachable from GitHub (localhost alone will not receive GitHub webhooks).

## Job 1: website-build
1. Jenkins > New Item > Multibranch Pipeline > `website-build`.
2. Branch Sources > GitHub: configure owner, repository and credentials.
3. Enable PR discovery and main branch discovery. For PRs, choose the intended head/merge strategy.
4. Build Configuration > by Jenkinsfile > Script Path: `jenkins/Jenkinsfile-build`.
5. Save and run **Scan Multibranch Pipeline Now**.
6. This pipeline validates the static site and archives the `dist/` directory.

## Job 2: website-deploy
1. Jenkins > New Item > Multibranch Pipeline > `website-deploy`.
2. Use the same GitHub repository; discover ONLY `main`, not PRs. Set Script Path: `jenkins/Jenkinsfile-deploy`.
3. Set the environment variable `WEBSITE_DEPLOY_DIR` to the **local web server document root on the Jenkins deployment agent** (for example, a writable directory served by nginx). Ensure the agent can write there.
4. **Important:** Do not configure this deployment job to build directly on every GitHub push. Trigger it only after a successful `website-build/main` run. For a robust production setup, implement this with an orchestrator pipeline or a trusted, explicitly configured downstream build trigger, passing and verifying the tested commit SHA. Simply configuring both multibranch jobs with webhooks does not enforce a test-before-deploy dependency.
5. The deploy Jenkinsfile checks `BRANCH_NAME == main` and reruns validation, but the main branch guard is NOT a substitute for downstream dependency and commit verification.
6. The deployment copies static files to the configured local directory; it is NOT an AWS, Docker or remote-host deployment.

## GitHub webhook
GitHub repo > Settings > Webhooks > Add webhook:
- Payload URL: `https://YOUR-JENKINS-URL/github-webhook/`
- Content type: `application/json`
- Events: push and pull request
- Active: enabled
- Configure webhook authentication/secret according to the installed Jenkins GitHub integration and secure your public Jenkins endpoint.

## Test
1. Create a feature branch, edit the website, push and open a PR.
2. Check GitHub webhook recent deliveries and Jenkins `website-build` PR job.
3. Merge only after checks pass.
4. Confirm `website-build/main` passes; then use your configured downstream trigger to start `website-deploy/main`.

**Note:** This template includes working basic validation and a local directory publish step. You must configure the downstream trigger, web server, permissions, and destination before real automatic deployment is operational.
