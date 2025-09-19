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
{{- if .Values.microservice.protocol | eq "https" }}
acme.cert-manager.io/http01-edit-in-place: 'true'
cert-manager.io/cluster-issuer: letsencrypt-prod
kubernetes.io/tls-acme: 'true'
{{- end }}
{{- if .Values.ingress.ingressClassName | eq "nginx" }}
nginx.ingress.kubernetes.io/force-ssl-redirect: 'true'
{{- end }}
{{- if .Values.ingress.ingressClassName | eq "alb" }}
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/backend-protocol: "{{ .Values.microservice.protocol | upper }}"
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
alb.ingress.kubernetes.io/ssl-redirect: '443'
{{- end }}
external-dns.alpha.kubernetes.io/hostname: {{ .Values.ingress.host }}
{{- end }}

{{- define "flask-hello-world.ingressClassName" -}}
{{- default "nginx" .Values.ingress.ingressClassName }}
{{- end }}