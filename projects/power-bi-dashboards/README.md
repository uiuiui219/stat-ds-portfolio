# Power BI Dashboards

**CSS 475 — Business Intelligence (final project)** · A four-source BI dashboard built in Power BI.

> **โปรเจกต์รายวิชา CSS 475** — แดชบอร์ด Power BI จากข้อมูล 4 แหล่ง (อีคอมเมิร์ซ/ค้าปลีก/โทรคมนาคม/บันเทิง) พร้อมรายงานวิเคราะห์

## Dashboard

**[เปิดแดชบอร์ดแบบโต้ตอบ (Power BI Service) →](https://app.powerbi.com/view?r=eyJrIjoiYTkwYmEyZTQtMjUzZS00M2JkLWJjMTgtZTY1YWZlODc0Nzc3IiwidCI6IjZmNDQzMmRjLTIwZDItNDQxZC1iMWRiLWFjMzM4MGJhNjMzZCIsImMiOjEwfQ%3D%3D)**

No Power BI Desktop needed — the report opens in the browser.

## What's here

| File | What it is |
|---|---|
| [`final/final.pbix`](final/final.pbix) | The dashboard (open with [Power BI Desktop](https://powerbi.microsoft.com/downloads)) |
| [`final/BI_Final.pdf`](final/BI_Final.pdf) | Written report documenting the analysis |
| [`final/Ecommerce.xlsx`](final/Ecommerce.xlsx), [`final/Retails.xlsx`](final/Retails.xlsx), [`final/Telecom.xlsx`](final/Telecom.xlsx), [`final/Entertainment.xlsx`](final/Entertainment.xlsx) | The four source datasets loaded into the model |
| [`final/variable-notes.xlsx`](final/variable-notes.xlsx) | Notes on the variables used |

**Scope:** load four unrelated business tables → clean and shape them in Power Query → model a star schema → build DAX measures (revenue, growth, share, KPIs) → interactive report pages with drill-through and conditional formatting.

**Skills shown:** Power Query transformations, DAX measures & time intelligence, data modelling, geospatial visuals.

## Opening the dashboard locally

`.pbix` files require **Power BI Desktop** (Windows, free). No refresh is needed to browse — the datasets are embedded; the source `.xlsx` files are included if you want to re-point the queries.

## Note

Screenshots of the report pages are not committed yet — see [`docs/adding-screenshots.md`](../../docs/adding-screenshots.md) for the export steps if you want to add them to this README.
