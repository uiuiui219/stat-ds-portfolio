# Adding dashboard screenshots

Power BI `.pbix` files render nothing on GitHub — a recruiter clicking the link only sees a binary. Exporting a few report pages as images makes the dashboards visible without opening Power BI.

## Export from Power BI Desktop

1. Open the `.pbix` (e.g. `projects/power-bi-dashboards/final/final.pbix`).
2. For each report page you want to show: **File → Export → Export to image → PNG** (or take a screenshot of the report canvas at 16:9).
3. Save images as:

   ```
   projects/power-bi-dashboards/final/screenshots/page-01-overview.png
   projects/power-bi-dashboards/labs/screenshots/page-01-map.png
   ```

   Keep each image **under ~1 MB** (scale to ~1600 px wide) so the repo stays light.

4. Reference them from the README:

   ```markdown
   ![Overview](final/screenshots/page-01-overview.png)
   ```

## Tips

- Export only 2–3 pages per dashboard; the first page should be the overview.
- Redact anything personal (names, account numbers) before committing.
- F1 poster/report figures can be exported the same way from the PDF for the project README if you want a preview image at the top.
