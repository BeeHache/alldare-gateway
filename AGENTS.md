# Guidelines for AI Agents (AGENTS.md) — alldare-gateway

`alldare-gateway` is the OpenResty Edge Ingress Proxy microservice for the Alldare Platform. It handles TLS/SSL termination, dynamic CORS resolution, rate limiting, and traffic routing to `alldare-web` (Angular UI) and `alldare-api` (BFF Gateway).

---

## 1. Component Architecture & File Layout
- **`conf.d/gateway.conf`**: Core OpenResty virtual host routing, CORS rules, and upstream proxy definitions.
- **`nginx.conf`**: Master Nginx process configuration, worker connections, and log formats.
- **`lua/`**: Custom OpenResty Lua scripts (`verify_jwt.lua`, `auth_utils.lua`) executing lightweight edge request inspection.
- **`certs/`**: TLS/SSL certificate placeholders for local development and staging.
- **`Dockerfile`**: Container definition based on `openresty/openresty:alpine`.

---

## 2. Technical Constraints & Guardrails

### CORS Policy Rules (W3C Spec Compliance)
- **Prohibition of Wildcard Origin with Credentials:** When `Access-Control-Allow-Credentials: true` is returned, W3C CORS specs prohibit returning `Access-Control-Allow-Origin: *`.
- **Dynamic Origin Reflection:** The gateway uses OpenResty Lua in `conf.d/gateway.conf` to reflect explicit matching origins (`localhost`, `127.0.0.1`, `*.alldare.online`).

### Upstream Routing Protocols
- `/` ➔ Proxies static SPA asset requests to `alldare-web:4200`.
- `/api/` ➔ Proxies API requests to BFF Gateway `alldare-api:8080`.
- Direct microservice upstreams (`AUTH_SERVICE_URL`, `POSTS_SERVICE_URL`, etc.) are resolved dynamically using Nginx runtime variables to prevent startup crashes when an upstream container is restarting.

---

## 3. Local Verification & Docker Commands
- **Build Container:** `docker build -t alldare-gateway .`
- **Run Container:** `docker run -d -p 80:80 -p 443:443 --name alldare-gateway alldare-gateway`
- **Nginx Configuration Syntax Check:** `docker exec -it alldare-gateway openresty -t`
- **Reload Configuration:** `docker exec -it alldare-gateway openresty -s reload`
