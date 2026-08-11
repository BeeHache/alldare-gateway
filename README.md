# Alldare Ingress Gateway Microservice (`alldare-gateway`)

This repository houses the **OpenResty Edge Ingress Proxy** for the Alldare Platform. It serves as the single public entrypoint for all platform traffic (`http://alldare.local`, `https://alldare.local`), handling TLS/SSL termination, dynamic W3C CORS resolution, edge JWT validation, header injection, and upstream microservice routing.

---

## 🌟 Key Responsibilities & Features
- **Public Ingress Proxy:** Listens on host ports `80` (HTTP) and `443` (HTTPS), enforcing SSL redirection and routing traffic to downstream microservices inside `alldare-network`.
- **Dynamic W3C CORS Resolution:** Dynamic Lua CORS filter (`set_by_lua_block $cors_origin`) supporting `localhost`, `127.0.0.1`, `alldare.local`, and `alldare.online` origins with full credentials support.
- **Edge JWT Verification & Identity Enrichment:** Validates JWT signatures using `verify_jwt.lua` and injects verified user identity headers (`X-User-ID`, `X-User-Roles`) for downstream Spring Boot microservices.
- **Dedicated Web SPA Ingress:** High-priority location blocks (`location ^~ /auth`, `location ^~ /admin`, `location /`) proxying Web UI requests to `alldare-web:4200` with `proxy_redirect` internal port stripping.
- **Real-Time SSE Streaming Proxy:** Zero-buffer HTTP/1.1 proxying for Server-Sent Events (`/api/v1/notifications/stream`) with 24-hour timeout windows.

---

## 📁 Repository Structure
- `conf.d/gateway.conf`: Main Nginx server blocks, upstream proxy rules, and CORS configuration.
- `nginx.conf`: OpenResty master configuration, worker pool settings, and environment variable declarations.
- `lua/`: Custom OpenResty Lua scripts:
  - `verify_jwt.lua`: Edge JWT signature verification and `X-User-ID` / `X-User-Roles` header extraction.
  - `auth_utils.lua`: RSA/HMAC JWT decoding and public key retrieval utilities.
- `certs/`: Local development SSL certificates (`server.crt`, `server.key`).
- `AGENTS.md`: Operational boundaries and security guidelines for AI agents.
- `Dockerfile`: OpenResty Alpine image with fallback package fetching (OPM / Git fallback).

---

## ⚙️ Environment Variables

All environment variables accessed by OpenResty Lua scripts are declared in `nginx.conf`:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `WEB_SERVICE_URL` | `http://alldare-web:4200` | Angular Web UI SPA service |
| `API_SERVICE_URL` | `http://alldare-api:8080` | BFF Gateway service |
| `AUTH_SERVICE_URL` | `http://alldare-auth:9000` | Authentication & OAuth service |
| `POSTS_SERVICE_URL` | `http://alldare-posts:8080` | Core post ingestion engine |
| `FEEDS_SERVICE_URL` | `http://alldare-feeds:8082` | Timeline fan-out engine |
| `PROFILES_SERVICE_URL` | `http://alldare-profiles:8083` | User identity & profile service |
| `MEDIA_SERVICE_URL` | `http://alldare-media:8081` | Asset processing & storage |
| `STATISTICS_SERVICE_URL` | `http://alldare-statistics:8084` | Async telemetry & analytics |
| `COMMENTS_SERVICE_URL` | `http://alldare-comments:8086` | Discussion thread service |
| `NOTIFICATIONS_SERVICE_URL` | `http://alldare-notifications:8087` | Live SSE notification service |
| `JWKS_URL` | `http://alldare-auth:9000/.well-known/jwks.json` | Public key endpoint for JWT validation |

---

## 🐳 Containerization & Local Execution

### Build Docker Image
```bash
docker build -t alldare-gateway .
```

### Run Locally via Docker Compose
`alldare-gateway` is orchestrated via `alldare-infrastructure`:
```bash
docker compose -f alldare-infrastructure/docker/docker-compose.local.yml up -d gateway
```

---

## 🔒 Edge Security Guardrails
- **Header Injection Trust Boundary:** `X-User-ID` and `X-User-Roles` headers are generated exclusively by `verify_jwt.lua` at the gateway layer. Downstream microservices treat these headers as trusted identity assertions.
- **CORS Protection:** Requests from unapproved origins receive empty CORS headers, preventing browser XHR/Fetch access.
