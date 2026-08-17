# API Specification: `alldare-gateway`

This document defines the edge routing rules, path mappings, and header injection matrix for **`alldare-gateway`**.

---

## 1. Edge Ingress Routing Matrix

Ports: `80` (HTTP) & `443` (HTTPS) | Host: `https://alldare.local`

| Ingress Path Pattern | Target Upstream Service | Upstream URL | Description |
| :--- | :--- | :--- | :--- |
| `/` | `alldare-phase0-ui` / `alldare-web` | `http://phase0-ui:4200` | Angular Single Page Application static assets & routes. |
| `/podcasts` | `alldare-phase0-ui` / `alldare-web` | `http://phase0-ui:4200` | Podcast Studio UI SPA route. |
| `/podcast/{slug}/*` | `alldare-podcasts` | `http://podcasts:8089` | Public RSS 2.0 (`/rss.xml`), Atom 1.0 (`/atom.xml`), and landing pages. |
| `/oauth2/*` | `alldare-auth` | `http://auth:9000` | Spring Authorization Server OAuth2/OIDC endpoints. |
| `/api/v1/auth/*` | `alldare-auth` | `http://auth:9000` | Authentication & token endpoints. |
| `/api/v1/profiles/*` | `alldare-profiles` | `http://profiles:8083` | Profile identity metadata endpoints. |
| `/api/v1/posts/*` | `alldare-posts` | `http://posts:8080` | Post content ingestion endpoints. |
| `/api/v1/podcasts/*` | `alldare-podcasts` | `http://podcasts:8089` | Podcast show & episode management endpoints. |
| `/api/v1/comments/*` | `alldare-comments` | `http://comments:8083` | Comment thread endpoints. |
| `/api/v1/feeds/*` | `alldare-feeds` | `http://feeds:8082` | Timeline feed endpoints. |
| `/api/v1/media/*` | `alldare-media` | `http://media:8081` | Storage pre-signed upload URL endpoints. |
| `/api/v1/statistics/*`| `alldare-statistics` | `http://statistics:8084` | Analytics endpoints. |

---

## 2. Downstream Header Injection

On successful JWT edge signature verification via `lua/verify_jwt.lua`, the gateway strips raw bearer tokens and injects verified identity headers:

* `X-User-ID`: Account UUID string (`sub` claim).
* `X-User-Roles`: Granted user authorities array (e.g. `ROLE_USER`, `ROLE_ADMIN`).
