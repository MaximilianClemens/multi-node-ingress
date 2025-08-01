# Yes, this is LLM generated Code, keep scrolling
nothing to see here

# Multi-Node Ingress Helm Chart

Ein flexibles Helm Chart für NGINX Ingress Controller mit dynamischer Service-zu-Controller Bindung.

## 🌟 Neue Features

- **🎯 Dynamische Controller-Bindung**: Services können an beliebige Controller gebunden werden
- **🔄 Flexible Port-Konfiguration**: HTTP, HTTPS, TCP und UDP Ports pro Controller
- **📡 Multi-Protocol Support**: Nicht nur HTTP/HTTPS, sondern auch TCP/UDP Services
- **🏷️ Einfache Benennung**: Controller haben aussagekräftige Namen wie `node01-public`
- **⚡ Hot-Reconfiguration**: Services können zur Laufzeit zu verschiedenen Controllern verschoben werden

## 🏗️ Architektur

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Service A     │────│  node01-public  │────│    Node01       │
│ (WordPress)     │    │  185.0.0.1      │    │                 │
└─────────────────┘    │  :80, :443      │    └─────────────────┘
                       └─────────────────┘
┌─────────────────┐    
│   Service B     │────┐
│ (API)           │    │ ┌─────────────────┐    ┌─────────────────┐
└─────────────────┘    ├─│  node01-private │────│    Node01       │
                       │ │  10.0.1.100     │    │                 │
┌─────────────────┐    │ │  :80,:443,:8080 │    └─────────────────┘
│   Service C     │────┘ └─────────────────┘
│ (Monitoring)    │
└─────────────────┘
```

## 📁 Chart Struktur

```
multi-node-ingress/
├── Chart.yaml                    # Chart Metadaten
├── values.yaml                   # Haupt-Konfiguration
├── values-example.yaml           # Production Beispiel
├── templates/
│   ├── _helpers.tpl              # Template Hilfsfunktionen
│   ├── namespaces.yaml           # Dynamische Namespaces
│   ├── rbac.yaml                 # RBAC für alle Controller
│   ├── ingressclass.yaml         # IngressClass Definitionen
│   ├── configmaps.yaml           # ConfigMaps mit TCP/UDP Support
│   ├── deployments.yaml          # Controller Deployments
│   ├── services.yaml             # NodePort Services
│   ├── demo-app.yaml             # Demo App (conditional)
│   ├── ingress.yaml              # Dynamische Ingress Generierung
│   └── NOTES.txt                 # Installation Summary
└── README.md
```

## 🚀 Schnellstart

### 1. Chart Setup

```bash
mkdir multi-node-ingress
cd multi-node-ingress
# Kopiere alle Chart-Dateien hierher
```

### 2. Basis Installation (mit Demo)

```bash
helm install my-ingress . -f values.yaml
```

### 3. Production Setup

```bash
# Erstelle deine Production Config
cp values-example.yaml values-prod.yaml
# Bearbeite values-prod.yaml mit deinen Werten

# Installiere ohne Demo
helm install prod-ingress . -f values-prod.yaml
```

## ⚙️ Konfiguration

### Controller Definition

```yaml
ingressControllers:
  my-public-controller:
    enabled: true
    node: "worker-01"              # Kubernetes Node
    ip: "185.0.0.1"               # Externe IP
    namespace: "ingress-my-public" # Eindeutiger Namespace
    ingressClass: "my-public"      # IngressClass Name
    controllerClass: "k8s.io/ingress-nginx-my-public"
    electionId: "leader-my-public"
    ports:
      - name: http
        port: 80
        protocol: TCP
        targetPort: 80
        nodePort: 30080
      - name: https
        port: 443
        protocol: TCP
        targetPort: 443
        nodePort: 30443
      - name: custom-api
        port: 8080
        protocol: TCP
        targetPort: 8080
        nodePort: 38080
```

### Service zu Controller Bindung

```yaml
ingressServices:
  - name: "my-app"
    namespace: "default"
    port: 80
    enabled: true
    ingressControllers:              # Hier die Magie!
      - my-public-controller         # Kann an mehrere Controller
      - my-private-controller        # gebunden werden
    hosts:
      - "app.example.com"
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
```

## 🎯 Anwendungsfälle

### 1. Hochverfügbarkeit
```yaml
# Service läuft auf mehreren Nodes
ingressServices:
  - name: "shop"
    ingressControllers:
      - node01-public
      - node02-public              # Load Balancing
      - node03-public
```

### 2. Staging/Production Trennung
```yaml
ingressControllers:
  prod-controller:
    ip: "185.0.0.1"
  staging-controller:
    ip: "185.0.0.2"

ingressServices:
  - name: "app"
    ingressControllers:
      - prod-controller            # Production
  - name: "app-staging"
    ingressControllers:
      - staging-controller         # Staging
```

### 3. Public/Private Hybrid
```yaml
ingressServices:
  - name: "api"
    ingressControllers:
      - public-controller          # Öffentlicher API Zugang
      - private-controller         # Interner Admin Zugang
    hosts:
      - "api.example.com"          # Öffentlich
      - "api.internal.company.com" # Privat
```

### 4. Multi-Protocol Services
```yaml
ingressControllers:
  game-server:
    ports:
      - name: web
        port: 80
        protocol: TCP
        nodePort: 30080
      - name: game-tcp
        port: 7777
        protocol: TCP
        nodePort: 37777
      - name: game-udp
        port: 7778
        protocol: UDP
        nodePort: 37778
```

## 🔧 Verwaltung

### Services zur Laufzeit verschieben

```yaml
# Von einem Controller zu einem anderen
ingressServices:
  - name: "my-app"
    ingressControllers:
      - old-controller      # Entfernen
      + new-controller      # Hinzufügen
```

```bash
helm upgrade my-ingress . -f values.yaml
```

### Neuen Controller hinzufügen

```yaml
ingressControllers:
  new-controller:
    enabled: true
    node: "new-node"
    ip: "185.0.0.3"
    # ... ports
```

### Service Debugging

```bash
# Controller Status
kubectl get pods -n ingress-my-public -l app.kubernetes.io/component=controller

# Service Ingress
kubectl get ingress --all-namespaces -l service.name=my-app

# Routing testen
curl -H "Host: app.example.com" http://185.0.0.1:30080
```

## 📊 Monitoring

```bash
# Alle Controller Status
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx

# Traffic zu Services
kubectl top pods --all-namespaces -l app.kubernetes.io/component=controller

# Ingress Events
kubectl get events --all-namespaces --field-selector reason=CreateIngress
```

## 🛠️ Erweiterte Features

### Custom Annotations per Service
```yaml
ingressServices:
  - name: "api"
    annotations:
      nginx.ingress.kubernetes.io/rate-limit: "100"
      nginx.ingress.kubernetes.io/cors-allow-origin: "*"
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
```

### Multi-Port Services
```yaml
ingressControllers:
  api-controller:
    ports:
      - name: api-http
        port: 8080
        targetPort: 8080
        nodePort: 38080
      - name: api-grpc
        port: 9090
        targetPort: 9090
        nodePort: 39090
```

## 🔍 Troubleshooting

### Controller startet nicht
```bash
kubectl describe pod -n <controller-namespace> -l app.kubernetes.io/component=controller
kubectl logs -n <controller-namespace> -l app.kubernetes.io/component=controller
```

### Service nicht erreichbar
```bash
# 1. Ingress prüfen
kubectl describe ingress <service-name>-<controller-name> -n <service-namespace>

# 2. Backend Service prüfen
kubectl get endpoints <service-name> -n <service-namespace>

# 3. Controller Logs
kubectl logs -n <controller-namespace> -l app.kubernetes.io/component=controller
```

### DNS/Host Issues
```bash
# Direct IP Test
curl -H "Host: your-domain.com" http://<controller-ip>:<nodeport>

# Check IngressClass
kubectl get ingressclass
```

## 🎯 Best Practices

1. **Controller Naming**: Verwende aussagekräftige Namen wie `prod-api`, `staging-web`
2. **Namespace Isolation**: Jeder Controller bekommt einen eigenen Namespace
3. **Port Planning**: Dokumentiere NodePort Ranges für verschiedene Services
4. **Gradual Migration**: Verschiebe Services schrittweise zwischen Controllern
5. **Monitoring**: Überwache Controller Health und Traffic Distribution

Das Chart macht Multi-Node Ingress endlich einfach und flexibel! 🎉