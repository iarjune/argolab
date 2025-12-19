docker run --rm \
  -e APP=ci-test-python-project \
  -e TAG=1.12.182 \
  -e STAGE=dev \
  -e KARGO_SERVER_URL="https://kargo.ric1.admarketplace.net" \
  -e KARGO_PW="iIUSN4aAGVeT83odP8nb3hTI" \
  -e KARGO_PROJECT=ci-test-python-project\
  kargo-runner
