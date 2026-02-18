export ARGO_TOKEN='Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6InV6RVliaGthdHFwckYwcW5kMlFhc0kyTHF2Z3lZOTg2djByOE9mTUlXdTQifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZXYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiY2xpLXRva2VuLnNlcnZpY2UtYWNjb3VudC10b2tlbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJjbGktdG9rZW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJhZWJhMjk2Ni05Y2YyLTQ5MTAtOGMyNy1iMzUwZDlhMDcwNzUiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGV2OmNsaS10b2tlbiJ9.EbRXG2ClujZ23Mu-9ijOAXb8YXuVCTHh0uxrTtghu6sTN-YY8K9JopVZv1xo2jsxATnDBF4CqbQ5nt86p_A3Q7vs4iFgv6xDuJW0T6yaxHFjABzW7CD2rC9X2hInRASjrsW6Nt3tCt14UEqvJRxBnyVkVrXhhtxq64T0WOjIdQ80lPIwT8QkR234jxC0ndVfKHcT7u8xnHVJuHlOjw38erOlyw7iBuQhnibIjguUhwoDWdZu3XdOywwzQok5Pah6P3E5sX2xaUvLjsoP2U8Ka4Vfbq2_RzDR-CLVu-_H8zUACVATzUyUuhhoEBA71gUl-YTw3iWlS9_d_1n7blQLRg'
export ARGO_SERVER="dev-argowf.ric1.admarketplace.net"
export ARGO_NAMESPACE="dev"
export ARGO_TEMPLATE_NAME="cd-promote-template"
export BITBUCKET_REPO_SLUG="ci-test-python-project"
export BITBUCKET_DEPLOYMENT_ENVIRONMENT="dev"
export VERSION="2.0.601-feat-1"
export BITBUCKET_BRANCH=feat-1
export ENABLE_VARIANT_CONFIGS=false
export SKIP_CLEANUP=true
export ARGOCD_WAIT_TIMEOUT=500
export ARGOWF_PARAMS=" -p project_name=ci-test-python-project -p promotion_stage=dev -p build_tag=2.0.601-feat-1 -p argocd_env=npe -p cd_deploy_configs_branch=master -p project_branch=feat-1 -p enable_variant_configs=false -p skip_cleanup=true -p timeout=500"



docker run --rm \
  -e ARGO_SERVER \
  -e ARGO_TOKEN \
  -e ARGO_TEMPLATE_NAME \
  -e ARGO_NAMESPACE \
  -e ARGOWF_PARAMS \
  --dns=10.11.128.70 \
  admarketplace/amp-argowf-cli:3.5
