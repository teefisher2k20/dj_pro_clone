# Spline Skill for AI Agents

Purpose:

- Instruct AI agents how to integrate Spline assets into the `site/` landing page.

Guidelines:

- Replace `site/assets/spline-url.txt` with the exact Spline Viewer URL.
- Ensure the Spline scene Play Settings use a transparent background so the scene blends with the site's black background.
- Use `@splinetool/viewer` via CDN for vanilla pages:
  import from: https://cdn.jsdelivr.net/npm/@splinetool/viewer@latest/dist/spline-viewer.mjs
- Initialize with:
  new Spline({ url: '<SPLINE_URL>', container: document.getElementById('spline-root') });

Behavior:

- The viewer should fill the viewport and sit behind content (z-index 0).
- Mouse interaction: add subtle camera rotation or object follow to increase perceived depth. Do not block form or UI interactions (use `pointer-events` selectively).
- If creating React/Vite variant, use `@splinetool/viewer` NPM package and wrap the viewer initialization in a component lifecycle.

Agent Tasks:

- Replace placeholder URL.
- Confirm background transparency in Spline scene.
- Optionally export optimized assets (if large), or provide an animation-only variant for mobile.
- Update `site/brand_guidelines.mmd` to match provided logo/colors when available.
