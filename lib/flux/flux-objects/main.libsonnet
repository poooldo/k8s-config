local renderKustomization = (import 'utils.libsonnet').renderKustomization;

{
  _config+:: {
    cluster: error 'cluster required',
  },

  kustomizations: {
    certManager: renderKustomization(name='cert-manager', namespace='cert-manager', cluster=$._config.cluster),
    ingressNginx: renderKustomization(name='ingress-nginx', namespace='ingress-nginx', cluster=$._config.cluster),
    sealedSecrets: renderKustomization(name='sealed-secrets', namespace='kube-system', cluster=$._config.cluster),
    itTools: renderKustomization(name='ittools', namespace='tools', cluster=$._config.cluster),
  },
}
