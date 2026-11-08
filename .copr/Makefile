# COPR webhook / make_srpm entrypoint
# https://docs.pagure.org/copr.copr/user_documentation.html#make_srpm
#
# main  → beta RPMs (Release ….beta)
# tags  → stable / rc (see scripts/rpm-version.sh)
#
# IMPORTANT:
# - One shell for the whole recipe so VERSION/RELEASE from eval persist.
# - Bake Version/Release into the spec shipped in the SRPM. COPR rebuilds
#   binaries from that spec WITHOUT our --define macros; leaving
#   %{!?devenv_ai_rel:1} produces 1.0.0-1 even when the SRPM filename is .beta.
# - Do not put the make automatic variable $? in the recipe (breaks %{?dist}).

SHELL := /bin/bash
.ONESHELL:
.PHONY: srpm

srpm:
	set -euo pipefail
	dnf -y install git rpm-build rpmdevtools 2>/dev/null || \
	  yum -y install git rpm-build rpmdevtools 2>/dev/null || true
	chmod +x ./scripts/rpm-version.sh
	eval "$$(./scripts/rpm-version.sh --shell)"
	if [[ -z "$${VERSION}" || -z "$${RELEASE}" ]]; then
	  echo "rpm-version.sh produced empty VERSION/RELEASE" >&2
	  ./scripts/rpm-version.sh >&2 || true
	  exit 1
	fi
	if [[ "$${RELEASE}" == "1" && "$${CHANNEL}" != "stable" ]]; then
	  echo "Refusing non-stable Release=1 (channel=$${CHANNEL})" >&2
	  exit 1
	fi
	echo "channel=$${CHANNEL} version=$${VERSION} release=$${RELEASE}"

	# Avoid make's $$? eating "%{?dist}" — build the dist suffix in the shell.
	qmark='?'
	dist_suffix="%{$${qmark}dist}"

	SPEC_BUILT=/tmp/devenv-ai-assistant-built.spec
	sed \
	  -e "s/^Version:.*/Version:        $${VERSION}/" \
	  -e "s/^Release:.*/Release:        $${RELEASE}$${dist_suffix}/" \
	  devenv-ai-assistant.spec > "$${SPEC_BUILT}"
	grep -E '^(Version|Release):' "$${SPEC_BUILT}"
	if grep -E '^(Version|Release):' "$${SPEC_BUILT}" | grep -q 'devenv_ai_'; then
	  echo "ERROR: baked spec still references devenv_ai_* macros" >&2
	  exit 1
	fi

	mkdir -p "$(outdir)"
	rm -rf /tmp/devenv-ai-assistant-pack
	mkdir -p "/tmp/devenv-ai-assistant-pack/devenv-ai-assistant-$${VERSION}"
	cp -a nvim-init.lua vimrc QUICKREF.txt README.md LICENSE \
	  rpm \
	  "/tmp/devenv-ai-assistant-pack/devenv-ai-assistant-$${VERSION}/"
	cp "$${SPEC_BUILT}" "/tmp/devenv-ai-assistant-pack/devenv-ai-assistant-$${VERSION}/devenv-ai-assistant.spec"
	tar -C /tmp/devenv-ai-assistant-pack -czf "/tmp/devenv-ai-assistant-$${VERSION}.tar.gz" \
	  "devenv-ai-assistant-$${VERSION}"

	rm -rf /tmp/devenv-ai-assistant-rpmbuild
	mkdir -p /tmp/devenv-ai-assistant-rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	rpmbuild -bs "$${SPEC_BUILT}" \
	  --define "_topdir /tmp/devenv-ai-assistant-rpmbuild" \
	  --define "_sourcedir /tmp" \
	  --define "_srcrpmdir $(outdir)"
	echo "Built SRPM channel=$${CHANNEL} $${VERSION}-$${RELEASE}"
	ls -la "$(outdir)"/devenv-ai-assistant-*.src.rpm
