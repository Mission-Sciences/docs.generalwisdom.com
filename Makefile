ENVS := dev dev2 dib_prd gf_prd ian mission_prd patrick todd
include $(foreach element,${ENVS},./make-vars/${element}.mk)

BUILD_OUTPUT_DIR := ./tmp
CRX_OUTPUT_DIR := ./build
WEB_OUTPUT_DIR := ./build-web
EXTENSION_NAME := ghostdog-extension

# Arg 1 is lowercase env name, Arg 2 is uppercase env name.
define make-env-targets
build-${1}:
	npm run build:${1}
.PHONY: build-${1}

watch-${1}:
	npm run watch:${1}
.PHONY: watch-${1}

check-aws-sso-${1}:
	@./scripts/check-aws-sso.sh "$${${2}_AWS_PROFILE_ADMIN}"
.PHONY: check-aws-sso-${1}

deploy-${1}: check-git-unstaged check-aws-sso-${1} create-output-dirs
	@./scripts/deploy.sh \
		--aws-profile "$${${2}_AWS_PROFILE_ADMIN}" \
		--build-output-dir "$${BUILD_OUTPUT_DIR}" \
		--crx-output-dir "$${CRX_OUTPUT_DIR}" \
		--environment-name "$${${2}_ENVIRONMENT_NAME}" \
		--environment-name-proper "$${${2}_ENVIRONMENT_NAME_PROPER}" \
		--environment-name-proper-short "$${${2}_ENVIRONMENT_NAME_PROPER_SHORT}" \
		--extension-id "$${${2}_EXTENSION_ID}" \
		--extension-name "$${EXTENSION_NAME}" \
		--make-target-build "build-${1}" \
		--private-key-path "$${${2}_PRIVATE_KEY_PATH}" \
		--public-key-path "$${${2}_PUBLIC_KEY_PATH}" \
		--root-domain "$${${2}_ROOT_DOMAIN}" \
		--root-hosted-zone-id "$${${2}_ROOT_HOSTED_ZONE_ID}" \
		--slack-webhook-url "$${${2}_SLACK_WEBHOOK_URL}" \
		--updates-url "$${${2}_UPDATES_URL}" \
		--web-output-dir "$${WEB_OUTPUT_DIR}"
.PHONY: deploy-${1}
endef

$(foreach element,${ENVS},$(eval $(call make-env-targets,${element},$(shell echo ${element} | tr '[:lower:]' '[:upper:]'))))

check-git-unstaged:
	@./scripts/check-git-unstaged.sh
.PHONY: check-git-unstaged

create-output-dirs:
	@mkdir -p "${BUILD_OUTPUT_DIR}"
	@mkdir -p "${CRX_OUTPUT_DIR}"
	@mkdir -p "${WEB_OUTPUT_DIR}"
.PHONY: create-output-dirs

serve:
	npm run serve
.PHONY: serve

lint:
	npm run lint
.PHONY: lint

lint-fix:
	npm run lint:fix
.PHONY: lint-fix

pretty:
	npm run pretty
.PHONY: pretty

build:
	@echo "Build"
.PHONY: build

test:
	@echo "Test"
.PHONY: test

build-docker:
	docker build \
		-f "Dockerfile" \
		-t "extension-ghostdog:latest" \
		.
.PHONY: build-docker

run-docker:
	docker run \
		--rm \
		-it \
		-p "8888:5000" \
		"extension-ghostdog:latest"
.PHONY: run-docker
