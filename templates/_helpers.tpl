{{/*
Expand the name of the chart.
*/}}
{{- define "multi-node-ingress.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "multi-node-ingress.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "multi-node-ingress.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "multi-node-ingress.labels" -}}
helm.sh/chart: {{ include "multi-node-ingress.chart" . }}
{{ include "multi-node-ingress.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "multi-node-ingress.selectorLabels" -}}
app.kubernetes.io/name: {{ include "multi-node-ingress.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate controller instance name
*/}}
{{- define "ingress.instanceName" -}}
{{- printf "ingress-nginx-%s" . }}
{{- end }}

{{/*
Check if a service uses a specific ingress controller
*/}}
{{- define "service.usesController" -}}
{{- $service := .service }}
{{- $controllerName := .controllerName }}
{{- $uses := false }}
{{- range $service.ingressControllers }}
{{- if eq . $controllerName }}
{{- $uses = true }}
{{- end }}
{{- end }}
{{- $uses }}
{{- end }}

{{/*
Get HTTP/HTTPS ports for a controller
*/}}
{{- define "controller.httpPorts" -}}
{{- $controller := . }}
{{- range $controller.ports }}
{{- if or (eq .name "http") (eq .name "https") }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: {{ .protocol }}
  targetPort: {{ .targetPort }}
  nodePort: {{ .nodePort }}
{{ end }}
{{- end }}
{{- end }}

{{/*
Get all ports for a controller
*/}}
{{- define "controller.allPorts" -}}
{{- $controller := . }}
{{- range $controller.ports }}
- name: {{ .name }}
  port: {{ .port }}
  protocol: {{ .protocol }}
  targetPort: {{ .targetPort }}
  nodePort: {{ .nodePort }}
{{ end }}
{{- end }}

{{/*
Filter hosts for specific controller (falls später node-spezifische Hosts gewünscht)
*/}}
{{- define "service.hostsForController" -}}
{{- $service := .service }}
{{- $controllerName := .controllerName }}
{{- range $service.hosts }}
{{- . }}
{{ end }}
{{- end }}