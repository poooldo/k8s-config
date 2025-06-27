local k = import 'k.libsonnet';
local networkPolicy = k.networking.v1.networkPolicy;
local networkPolicyIngressRule = k.networking.v1.networkPolicyIngressRule;
local networkPolicyPeer = k.networking.v1.networkPolicyPeer;

{
  // allow ingress-nginx pods to reach flux ns acme pods (certmanager auto created)
  acmeSolver:
    networkPolicy.new('allow-acme') +
    networkPolicy.metadata.withNamespace('flux-system') +
    networkPolicy.spec.podSelector.withMatchLabels({ 'acme.cert-manager.io/http01-solver': 'true' }) +
    networkPolicy.spec.withIngress([
      networkPolicyIngressRule.withFrom([
        networkPolicyPeer.namespaceSelector.withMatchLabels({ 'kubernetes.io/metadata.name': 'ingress-nginx' }),
      ]),
    ]) +
    networkPolicy.spec.withPolicyTypes(['Ingress']),
}
