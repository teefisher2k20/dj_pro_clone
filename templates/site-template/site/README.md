# site — 3D Landing (Spline)

Quick start (no build tools required):

1. Serve with Python:

   ```bash
   cd site
   python -m http.server 8000
   ```

   Open http://localhost:8000

2. Or use npm (optional):
   ```bash
   cd site
   npm install
   npm run start
   ```

Replace the placeholder Spline URL:

- Edit `site/assets/spline-url.txt` and paste your Spline Viewer URL (example: https://prod.spline.design/XXXXX/scene.splinecode).

Deploy:

- Drag the `site/` folder into Netlify or Vercel, or push `site/` to a static site branch and connect the host.
