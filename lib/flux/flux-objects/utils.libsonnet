local fluxcd = import 'fluxcd.libsonnet';
local kustomization = fluxcd.kustomization;

{
  renderKustomization(name, cluster, namespace, interval='30m', retryInterval='1m', timeout='5m', prune=true, wait=true)::
    kustomization.new(name) +
    kustomization.metadata.withNamespace(namespace) +
    kustomization.spec.withInterval(interval) +
    kustomization.spec.withRetryInterval(retryInterval) +
    kustomization.spec.withTimeout(timeout) +
    kustomization.spec.sourceRef.withKind('GitRepository') +
    kustomization.spec.sourceRef.withName('flux-system') +
    kustomization.spec.sourceRef.withNamespace('flux-system') +
    kustomization.spec.withPath('./%(cluster)s/%(name)s' % { cluster: cluster, name: name }) +
    kustomization.spec.withPrune(prune) +
    kustomization.spec.withWait(wait),
}

