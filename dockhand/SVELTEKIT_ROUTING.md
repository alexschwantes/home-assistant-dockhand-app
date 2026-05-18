# SvelteKit Ingress Routing Notes

## Root Cause

Dockhand is built as a root-hosted SvelteKit app, but Home Assistant serves it under a sub-path ingress entry.
The ingress gateway strips that prefix before proxying to the add-on container, so backend routing works, but
client-side URLs generated as root-relative paths can still escape the ingress prefix.

## Current Mitigation

The nginx ingress config now injects two things into HTML responses:

- A dynamic base tag: `<base href="$http_x_ingress_path/">`
- An external shim script: `__ha_ingress_shim.js`

The shim normalizes root-relative and same-origin absolute URLs by prefixing the active ingress path.

## What The Shim Patches

- `window.URL` constructor (critical for `goto('/...')` URL normalization)
- `window.fetch` and `XMLHttpRequest.open`
- `window.EventSource`
- `history.pushState` and `history.replaceState`
- `Location.prototype.assign` and `Location.prototype.replace`
- Dynamic DOM attributes (`src`, `href`, `action`) via `MutationObserver`
- SvelteKit runtime globals (`__sveltekit*`) to align runtime base with ingress path

## Why This Is Better Than The Previous Inline Shim

- Easier to maintain and review than a single massive `sub_filter` inline script
- More reliable for SvelteKit `goto('/...')` because `window.URL` is patched directly
- Keeps ingress-specific behavior isolated to nginx (no Dockhand image rebuild needed)

## Remaining Limitation

This is still a compatibility layer. The robust long-term fix is upstream in Dockhand:

- Build SvelteKit with a dynamic base path, or
- Ensure all `goto('/...')` / root-relative internal links are base-aware

If Dockhand adds native base-path support, this shim can be reduced or removed.
