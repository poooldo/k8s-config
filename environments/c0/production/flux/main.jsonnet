local config = import '../config.libsonnet';
local renderKustomization = (import 'flux/flux-objects/utils.libsonnet').renderKustomization;

{
  networkPolicies: (import 'flux/networkpolicies/main.libsonnet'),
  kustomizations: {
    certManager: renderKustomization(name='cert-manager', namespace='cert-manager', retryInterval='10s', cluster=config.cluster),
    ingressNginx: renderKustomization(name='ingress-nginx', namespace='ingress-nginx', retryInterval='10s', cluster=config.cluster),
    sealedSecrets: renderKustomization(name='sealed-secrets', namespace='kube-system', cluster=$._config.cluster),
    itTools: renderKustomization(name='ittools', namespace='tools', cluster=$._config.cluster), 
  },
}
