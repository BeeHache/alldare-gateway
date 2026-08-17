# Architecture Specification: `alldare-gateway`

This document defines the OpenResty edge ingress proxy architecture, TLS termination, CORS routing, rate limiting, and backend service resolution matrix for **`alldare-gateway`**.

---

## 1. Domain & Edge Responsibilities

`alldare-gateway` acts as the edge ingress proxy and security boundary for all incoming client HTTP/HTTPS requests.

* **OpenResty (Nginx + Lua)**: High-performance Lua-based proxy routing.
* **TLS Termination & SSL**: Listens on Ports `80` (HTTP) and `443` (HTTPS with SSL certificates).
* **CORS & Rate Limiting**: Enforces global CORS headers and per-IP rate limits.

---

## 2. Ingress Route Matrix

```text
[ Client (Browser / Mobile) ] ──HTTPS (443)──► [ alldare-gateway (OpenResty) ]
                                                       │
        ┌───────────────────┬──────────────────┬───────┴───────────┬───────────────────┐
        ▼                   ▼                  ▼                   ▼                   ▼
[ phase0-ui:4200 ]   [ auth:9000 ]     [ profiles:8083 ]   [ podcasts:8089 ]    [ posts:8080 ]
  (/, /podcasts)     (/oauth2/...)     (/api/v1/profiles)  (/api/v1/podcasts)   (/api/v1/posts)
```
