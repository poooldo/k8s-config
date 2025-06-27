local k = import 'k.libsonnet';

local container = k.core.v1.container;
local containerPort = k.core.v1.containerPort;
local deployment = k.apps.v1.deployment;
local envVar = k.core.v1.envVar;
local service = k.core.v1.service;
local ingress = k.networking.v1.ingress;
local ingressRule = k.networking.v1.ingressRule;
local httpIngressPath = k.networking.v1.httpIngressPath;
local ingressTLS = k.networking.v1.ingressTLS;

{
  _config:: {
    name: 'it-tools',
    namespace: 'tools',
    registry: {
      image: 'ghcr.io/corentinth/it-tools',
      tag: 'latest',
    },
    environment: error 'environment required',
    ingressHostname: error 'ingressHostname required',

    resources: {
      limits: { cpu: '600m', memory: '500Mi' },
      requests: { cpu: '500m', memory: '500Mi' },
    },
  },

  local c = $._config,

  labels:: {
    'app.kubernetes.io/name': c.name,
    'app.kubernetes.io/part-of': c.name,
    'dawex.net/environment': c.environment,
    name:: null,
  },

  container::
    container.new(c.name, '%s:%s' % [$._config.registry.image, $._config.registry.tag]) +
    container.withImagePullPolicy('Always') +
    container.withPorts([
      containerPort.newNamed(80, 'http'),
    ]) +
    container.resources.withLimits(c.resources.limits) +
    container.resources.withRequests(c.resources.requests) +
    container.readinessProbe.httpGet.withPath('/') +
    container.readinessProbe.httpGet.withPort('http') +
    container.readinessProbe.withInitialDelaySeconds(10) +
    container.readinessProbe.withTimeoutSeconds(5) +
    container.readinessProbe.withPeriodSeconds(5) +
    container.livenessProbe.withPeriodSeconds(5) +
    container.livenessProbe.httpGet.withPath('/') +
    container.livenessProbe.httpGet.withPort('http') +
    container.livenessProbe.withInitialDelaySeconds(10) +
    container.livenessProbe.withTimeoutSeconds(5) +
    container.readinessProbe.withPeriodSeconds(5), 

  deployment:
    deployment.new(c.name, 1, [$.container], $.labels) +
    deployment.metadata.withNamespace(c.namespace) +
    deployment.metadata.withLabels($.labels) +
    deployment.spec.strategy.rollingUpdate.withMaxSurge(0) +
    deployment.spec.strategy.rollingUpdate.withMaxUnavailable(1),

  service:
    service.new(c.name, $.labels, [
      { name: 'http', port: 80 },
    ]) +
    service.metadata.withLabels($.labels) +
    service.metadata.withNamespace(c.namespace),

  ingress:
    ingress.new(c.name) +
    ingress.metadata.withNamespace(c.namespace) +
    ingress.metadata.withLabels($.labels) +
    ingress.metadata.withAnnotations({
      'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
    }) +
    ingress.spec.withIngressClassName('nginx') +
    ingress.spec.withRules(
      [
        ingressRule.withHost(c.ingressHostname) +
        ingressRule.http.withPaths([
          httpIngressPath.withPath('/') +
          httpIngressPath.withPathType('ImplementationSpecific') +
          httpIngressPath.backend.service.withName($.service.metadata.name) +
          httpIngressPath.backend.service.port.withName('http'),
        ]),
      ]
    ) +
    ingress.spec.withTls(
      ingressTLS.withHosts([c.ingressHostname]) +
      ingressTLS.withSecretName('tls-%s' % c.name)
    ),
}
