# Continuous Deployment README Update Plan

This plan will update the continuous-deployment project's README.md with a concise, high-level overview of all components in this CI/CD system, including CI Docker images and implementation details in cd-deploy-configs.

## Current State Analysis
The project contains several key components:
- **Kargo Server** - GitOps promotion engine for continuous deployment
- **Kargo Global Credentials** - Authentication, RBAC, and secret management
- **Argo Workflows CLI Permissions** - CLI access configuration for workflows
- **Cert-Manager** - Automated certificate management for services
- **Workflow Templates** - Reusable CI/CD pipeline templates for promotion and CI
- **Documentation** - Comprehensive guides and references

## CI Docker Images (External Dependencies)
- **ci-docker-argowf-cli** - Argo Workflows CLI (amp-argowf-cli:3.5) for workflow execution
- **ci-docker-argocd-cli** - ArgoCD CLI (amp-argocd-cli:2.12) for GitOps operations
- **ci-docker-cookiecutter** - Cookiecutter (amp-cookiecutter:2.6) for project scaffolding
- **ci-docker-kargo** - Kargo CLI (ci-docker-kargo:latest) for freight promotions

## Implementation in cd-deploy-configs
- **Application Configs** - Kubernetes manifests and environment-specific overlays in apps/
- **Global Components** - Infrastructure components in components/
- **Kargo Promotion Tasks** - Global promotion workflows in components/kargo-global-promotiontasks/

## Proposed README Structure
1. Brief project description
2. Core platform components with one-line descriptions
3. CI Docker images with versions and purposes
4. Implementation locations in cd-deploy-configs
5. Quick links to key documentation and repositories

## Implementation Steps
1. Create high-level project description
2. List core platform components with concise descriptions
3. Add CI Docker images section with versions and usage
4. Include cd-deploy-configs implementation details
5. Add quick navigation and external resource links
6. Keep it brief and scannable

The goal is to provide immediate understanding of the system's architecture, dependencies, and implementation locations without overwhelming detail.
