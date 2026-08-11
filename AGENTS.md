# Guidelines for AI Agents (AGENTS.md) — alldare-gateway

`alldare-gateway` is the OpenResty Edge Ingress Proxy microservice for the Alldare Platform. It handles TLS/SSL termination, dynamic CORS resolution, JWT cryptographic verification at the edge, rate limiting, and traffic routing to `alldare-web` (Angular UI) and `alldare-api` (BFF Gateway).

---

## 1. Component Architecture & File Layout
- **`conf.d/gateway.conf`**: Core OpenResty virtual host routing, CORS rules, and upstream proxy definitions.
- **`nginx.conf`**: Master Nginx process configuration, worker connections, environment variable declarations (`env WEB_SERVICE_URL;`, etc.), and log formats.
- **`lua/`**: Custom OpenResty Lua scripts:
  - `verify_jwt.lua`: Edge authentication inspection and JWT signature verification.
  - `auth_utils.lua`: Cryptographic helper utilities.
- **`certs/`**: TLS/SSL certificate placeholders for local development and staging.
- **`Dockerfile`**: Container definition based on `openresty/openresty:alpine`.

---

## 2. Technical Constraints & Guardrails

### CORS Policy Rules (W3C Spec Compliance)
- **Prohibition of Wildcard Origin with Credentials:** When `Access-Control-Allow-Credentials: true` is returned, W3C CORS specs prohibit returning `Access-Control-Allow-Origin: *`.
- **Dynamic Origin Reflection:** The gateway uses OpenResty Lua in `conf.d/gateway.conf` to reflect explicit matching origins (`localhost`, `127.0.0.1`, `alldare.local`, `*.alldare.online`).

### Edge Security & Authentication Standards
- **Environment Variable Declarations:** Any system environment variable accessed via `os.getenv(...)` inside OpenResty Lua scripts **must** be explicitly declared in `nginx.conf` (e.g. `env WEB_SERVICE_URL;`).
- **Cryptographic Guardrail:** Incoming client requests containing authentication bearer tokens **must** be validated at the edge boundary via `lua/verify_jwt.lua`.
- **Downstream Identity Ingress:** On successful signature verification, the gateway strips the raw signature and injects clean headers (`X-User-ID` and `X-User-Roles`) down to `alldare-api` and internal microservices.
- **SSE Stream Bypass Exception:** Native browser `EventSource` clients cannot supply custom HTTP headers. Consequently, the edge route `/api/v1/notifications/stream` bypasses edge Lua header verification (`verify_jwt.lua`) to allow `alldare-notifications` to parse the token from query parameters (`?token=...`).

### Upstream Routing Protocols
- `/auth`, `/admin`, `/` ➔ Proxies static SPA asset requests to `$web_url$request_uri` (`alldare-web:4200`) with `proxy_redirect` internal port stripping.
- `/api/` ➔ Proxies API requests to BFF Gateway `$api_url$request_uri` (`alldare-api:8080`).
- **Resilient Upstream Upgrades:** All upstream backend pass-throughs map dynamic variables combined with a local DNS resolver block (`resolver 127.0.0.11 valid=30s;`) to prevent the OpenResty container from crashing at boot time if a sibling service is unreachable.

---

## 3. Local Verification & Docker Commands
- **Build Container:** `docker build -t alldare-gateway .`
- **Run Container:** `docker run -d -p 80:80 -p 443:443 --name alldare-gateway alldare-gateway`
- **Nginx Configuration Syntax Check:** `docker exec -it alldare-gateway openresty -t`
- **Reload Configuration:** `docker exec -it alldare-gateway openresty -s reload`
