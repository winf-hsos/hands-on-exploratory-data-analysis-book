# Hands-On Exploratory Data Analytics (Quarto Book)

This repository contains a Quarto book project with R-based data analytics examples.

## Local Render, Then Push

The publish flow is:

1. Render locally to `_book`
2. Commit and push
3. GitHub Pages deploys the committed `_book` content

### Render locally

```bash
quarto render --to html
```

### Commit and push

```bash
git add .
git commit -m "Render book and update content"
git push origin main
```

## GitHub Pages setup (one-time)

1. Open repository `Settings` -> `Pages`
2. Set `Source` to `GitHub Actions`

A workflow at `.github/workflows/deploy-book.yml` deploys the `_book` directory.

## Notes

- `_book/` is intentionally tracked in Git.
- Quarto/R caches and local environment folders are ignored via `.gitignore`.

## Download Diagram SVGs From Google Slides

Manage slide exports in:

- `google-slides-images.yml`

Structure:

- `output_dir`: target folder (for example `images`)
- `presentations`: grouped by `document_id`
- `slides`: list of objects with:
- `pageid`: SVG for book image (`images/google_slides/<name>.svg`)
- optional `slide_pageid`: SVG for slide variant (`images/slides/google_slides/<same-name>.svg`)
- optional `filename`: base file name without extension

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/download-google-slides-svg.ps1
```

Naming behavior:

- Preferred: set `"filename"` in each slide entry.
- If omitted, fallback name is `<pageid>.svg`.

Example slide entry:

```yaml
output_dir: images
presentations:
  - document_id: your_google_presentation_id
    slides:
      - pageid: gBOOK_ID
        slide_pageid: gSLIDE_ID
        filename: select_schema
```
