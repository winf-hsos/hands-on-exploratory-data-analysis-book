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