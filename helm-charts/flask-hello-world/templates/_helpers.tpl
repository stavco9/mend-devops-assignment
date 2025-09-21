{{- define "flask-hello-world.name" -}}
{{- default .Chart.Name .Values.microservice.name | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "flask-hello-world.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "flask-hello-world.labels" -}}
helm.sh/chart: {{ include "flask-hello-world.chart" . }}
{{ include "flask-hello-world.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
microservice: {{ .Values.microservice.name }}
environment: {{ .Values.microservice.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "flask-hello-world.selectorLabels" -}}
app.kubernetes.io/name: {{ include "flask-hello-world.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
microservice: {{ .Values.microservice.name }}
environment: {{ .Values.microservice.environment }}
{{- end }}

{{/*
Deployment annotations
*/}}
{{- define "flask-hello-world.deployment.annotations" -}}
{{- if .Values.prometheusMetrics.enabled }}
prometheus.io/path: "/metrics"
prometheus.io/scheme: "{{ .Values.microservice.protocol }}"
prometheus.io/scrape: "true"
prometheus.io/port: "{{ .Values.microservice.port }}"
{{- end }}
{{- end }}

{{/*
Ingress annotations
*/}}
{{- define "flask-hello-world.ingress.annotations" -}}

{{/*
Use Let's Encrypt ACME for any Ingress Controller which is no AWS ALB (Since in ALB we use the AWS ACM Certificate)
*/}}
{{- if and (.Values.ingress.protocol | eq "https") (.Values.provider | ne "aws") (.Values.ingress.ingressClassName | ne "alb") }}
cert-manager.io/cluster-issuer: letsencrypt-prod
kubernetes.io/tls-acme: 'true'
{{- end }}

{{/*
Annotation for NGINX Ingress Controller
*/}}
{{- if and (.Values.ingress.protocol | eq "https") (.Values.ingress.ingressClassName | eq "nginx") }}
nginx.ingress.kubernetes.io/force-ssl-redirect: 'true'
{{- end }}

{{/*
Annotations for AWS LB Controller
*/}}
{{- if and (.Values.provider | eq "aws") (.Values.ingress.ingressClassName | eq "alb") }}
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/backend-protocol: "{{ .Values.microservice.protocol | upper }}"
{{/*
Whether the ALB listens on HTTP or HTTPS (In case of HTTPS it redirects HTTP traffic to HTTPS)
*/}}
{{- if .Values.ingress.protocol | eq "https" }}
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
alb.ingress.kubernetes.io/ssl-redirect: '443'
{{- else }}
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
{{- end }}
{{- end }}

{{/*
Annotations for Azure AppGW Controller
*/}}
{{- if and (.Values.provider | eq "azure") (.Values.ingress.ingressClassName | eq "appgw") }}
kubernetes.io/ingress.class: azure/application-gateway
{{/*
Whether the APPGW listens on HTTP or HTTPS (In case of HTTPS it redirects HTTP traffic to HTTPS)
*/}}
{{- if .Values.ingress.protocol | eq "https" }}
appgw.ingress.kubernetes.io/ssl-redirect: "true"
{{- end }}
{{- end }}

{{/*
Add the host in the external DNS Annotation in order to create a DNS Record in the Cloud Provider
*/}}
external-dns.alpha.kubernetes.io/hostname: {{ .Values.ingress.host }}
{{- end }}

{{- define "flask-hello-world.ingressClassName" -}}
{{- default "nginx" .Values.ingress.ingressClassName }}
{{- end }}