#!/bin/bash
set -euo pipefail

# --- Configurable variables ---
SERVICE="openbao-internal"
NAMESPACE="openbao"
SECRET_NAME="openbao-server-tls"
TMPDIR="/tmp/openbao-tls"
CSR_NAME="openbao-csr"

mkdir -p "${TMPDIR}"

echo "Generating RSA private key..."
openssl genrsa -out "${TMPDIR}/openbao.key" 2048

echo "Creating CSR config..."
cat <<EOF > "${TMPDIR}/csr.conf"
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.${SERVICE}
DNS.2 = *.${SERVICE}.${NAMESPACE}
DNS.3 = *.${SERVICE}.${NAMESPACE}.svc
DNS.4 = *.${SERVICE}.${NAMESPACE}.svc.cluster.local
DNS.5 = ${SERVICE}.${NAMESPACE}.svc.cluster.local
DNS.6 = vault.agrimin.sarvam.ai
IP.1 = 127.0.0.1
EOF

echo "Generating CSR..."
openssl req -new \
  -key "${TMPDIR}/openbao.key" \
  -subj "/CN=system:node:${SERVICE}.${NAMESPACE}.svc/O=system:nodes" \
  -out "${TMPDIR}/server.csr" \
  -config "${TMPDIR}/csr.conf"

if [[ "$(uname)" == "Darwin" ]]; then
  # macOS
  base64_csr=$(base64 < "${TMPDIR}/server.csr" | tr -d '\n')
else
  # Linux and others
  base64_csr=$(base64 -w 0 < "${TMPDIR}/server.csr")
fi

echo "Creating CSR manifest..."
cat <<EOF > "${TMPDIR}/csr.yaml"
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  signerName: kubernetes.io/kubelet-serving
  groups:
  - system:authenticated
  request: ${base64_csr}
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

echo "Applying CSR manifest..."
kubectl apply -f "${TMPDIR}/csr.yaml"

echo "Waiting for CSR to appear..."
while ! kubectl get csr "${CSR_NAME}" > /dev/null 2>&1; do
  echo "Waiting for CSR resource..."
  sleep 2
done

echo "Approving CSR..."
kubectl certificate approve "${CSR_NAME}"

echo "Waiting for certificate issuance..."
serverCert=""
while [ -z "$serverCert" ]; do
  sleep 2
  serverCert=$(kubectl get csr "${CSR_NAME}" -o jsonpath='{.status.certificate}' || echo "")
done

echo "Writing certificate to file..."
echo "${serverCert}" | base64 -d > "${TMPDIR}/openbao.crt"

echo "Retrieving Kubernetes CA certificate..."
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > "${TMPDIR}/openbao.ca"
#kubectl get cm kube-root-ca.crt -n kube-system -o jsonpath='{.data.ca\.crt}' > "${TMPDIR}/openbao.ca"
#gcloud container clusters describe gcp-gke --zone asia-south1-a --project ea-agrimin-stage --format="value(masterAuth.clusterCaCertificate)" | base64 --decode > "${TMPDIR}/openbao.ca"

if [ ! -s "${TMPDIR}/openbao.ca" ]; then
  echo "Failed to retrieve Kubernetes CA certificate. Exiting."
  exit 1
fi

echo "Creating namespace if not exists..."
kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${NAMESPACE}"

echo "Creating Kubernetes secret with key, cert, and CA..."
kubectl create secret generic "${SECRET_NAME}" \
  --namespace "${NAMESPACE}" \
  --from-file=openbao.key="${TMPDIR}/openbao.key" \
  --from-file=openbao.crt="${TMPDIR}/openbao.crt" \
  --from-file=openbao.ca="${TMPDIR}/openbao.ca" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "TLS secret '${SECRET_NAME}' created/updated in namespace '${NAMESPACE}'."

echo "Cleanup temporary files..."
# Uncomment if you want to clean temporary files
rm -rf "${TMPDIR}"

echo "Done."

echo
echo "Use this secret in your Helm values:"
cat <<EOF
global:
  enabled: true
  tlsDisable: false

server:
  extraEnvironmentVars:
    OPENBAO_CACERT: /openbao/userconfig/${SECRET_NAME}/openbao.ca

  volumes:
    - name: userconfig-${SECRET_NAME}
      secret:
        defaultMode: 420
        secretName: ${SECRET_NAME}

  volumeMounts:
    - mountPath: /openbao/userconfig/${SECRET_NAME}
      name: userconfig-${SECRET_NAME}
      readOnly: true

  standalone:
    enabled: true
    config: |
      listener "tcp" {
        address = "[::]:8200"
        cluster_address = "[::]:8201"
        tls_cert_file = "/openbao/userconfig/${SECRET_NAME}/openbao.crt"
        tls_key_file  = "/openbao/userconfig/${SECRET_NAME}/openbao.key"
        tls_client_ca_file = "/openbao/userconfig/${SECRET_NAME}/openbao.ca"
      }

      storage "file" {
        path = "/openbao/data"
      }
EOF