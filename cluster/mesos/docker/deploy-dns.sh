#!/bin/bash

# Copyright 2016 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Deploy the Kube-DNS addon

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

KUBE_ROOT=$(cd "$(dirname "${BASH_SOURCE}")/../../.." && pwd)
source "${KUBE_ROOT}/cluster/${KUBERNETES_PROVIDER}/${KUBE_CONFIG_FILE-"config-default.sh"}"
kubectl="${KUBE_ROOT}/cluster/kubectl.sh"

workspace=$(pwd)

# Process salt pillar templates manually
sed -e "s/{{ pillar\['dns_replicas'\] }}/${DNS_REPLICAS}/g;s/{{ pillar\['dns_domain'\] }}/${DNS_DOMAIN}/g" "${KUBE_ROOT}/cluster/saltbase/salt/kube-dns/skydns-rc.yaml.in" > "${workspace}/skydns-rc.yaml"
sed -e "s/{{ pillar\['dns_server'\] }}/${DNS_SERVER_IP}/g" "${KUBE_ROOT}/cluster/saltbase/salt/kube-dns/skydns-svc.yaml.in" > "${workspace}/skydns-svc.yaml"

# Use kubectl to create skydns rc and service
"${kubectl}" create -f "${workspace}/skydns-rc.yaml"
"${kubectl}" create -f "${workspace}/skydns-svc.yaml"
