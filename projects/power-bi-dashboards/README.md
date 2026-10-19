# Power BI Dashboards

**CSS 475 — Business Intelligence** · A multi-source BI final project plus lab dashboards.

> **โปรเจกต์ CSS 475** — แดชบอร์ด Power BI จากข้อมูลหลายแหล่ง (อีคอมเมิร์ซ/ค้าปลีก/โทรคมนาคม/บันเทิง) พร้อมรายงานวิเคราะห์ และชุดแล็บฝึกทำแผนที่กับ DAX

## What's here

### [`final/`](final/) — final project

| File | What it is |
|---|---|
| [`final/final.pbix`](final/final.pbix) | The dashboard (open with [Power BI Desktop](https://powerbi.microsoft.com/downloads)) |
| [`final/report.pdf`](final/report.pdf) | Written report documenting the analysis |
| [`final/Ecommerce.xlsx`](final/Ecommerce.xlsx), [`final/Retails.xlsx`](final/Retails.xlsx), [`final/Telecom.xlsx`](final/Telecom.xlsx), [`final/Entertainment.xlsx`](final/Entertainment.xlsx) | The four source datasets loaded into the model |
| [`final/variable-notes.xlsx`](final/variable-notes.xlsx) | Notes on the variables used |

**Scope:** load four unrelated business tables → clean and shape them in Power Query → model a star schema → build DAX measures (revenue, growth, share, KPIs) → interactive report pages with drill-through and conditional formatting.

### [`labs/`](labs/) — lab dashboards

| File | What it is |
|---|---|
| [`labs/lab.pbix`](labs/lab.pbix) | Core lab dashboard |
| [`labs/lab-web.pbix`](labs/lab-web.pbix) | Variant using the web data connector |
| [`labs/SalesData.xlsx`](labs/SalesData.xlsx) | Sales dataset for the labs |
| [`labs/Nakhon-Si-Thammarat-boundary.json`](labs/Nakhon-Si-Thammarat-boundary.json) | GeoJSON boundary used for map visuals |
| [`labs/Nakhon-Si-Thammarat.xlsx`](labs/Nakhon-Si-Thammarat.xlsx) | Aggregated figures joined to the map |
| [`labs/Nakhon-Si-Thammarat-shapefile.zip`](labs/Nakhon-Si-Thammarat-shapefile.zip) | Original shapefile (shp/dbf/prj/shx) for the map layer |

**Skills shown:** Power Query transformations, DAX measures & time intelligence, data modelling, map/geospatial visuals.

## Opening the dashboards

`.pbix` files require **Power BI Desktop** (Windows, free). No refresh is needed to browse — the datasets are embedded; the source `.xlsx` files are included if you want to re-point the queries.

## Note

Screenshots of the report pages are not committed yet — see [`docs/adding-screenshots.md`](../../docs/adding-screenshots.md) for the export steps if you want to add them to this README.
