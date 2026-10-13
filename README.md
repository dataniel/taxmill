# taxmill

[![R-CMD-check](https://github.com/dataniel/taxmill/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dataniel/taxmill/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![pkgdown](https://img.shields.io/badge/docs-pkgdown-blue.svg)](https://dataniel.github.io/taxmill)

> **Experimental.** A mill for digital PDF financial statements: text out,
> a manual pass to shape the lines, and one tidy Excel workbook in. Tax
> accounts and ordinary annual accounts both work, because both are laid
> out as tables. Grown out of the accounts statistics at Statistics
> Greenland, by way of [daos](https://github.com/dataniel/daos), where it
> started as a handful of helpers.

## Installation

```r
pak::pak("dataniel/taxmill")
```

## The three steps

```r
library(taxmill)

accounts_pdf_to_txt("data/pdf", "data/txt")

# ... shape the statements into category and data lines by hand ...

accounts_txt_to_xlsx("data/txt", "data/accounts.xlsx", year = 2024)
```

## Nothing leaves the machine

The documents this package is pointed at are usually confidential — a tax
account is not a published annual report. So there is no upload, no API
call, and no service in the loop. `accounts_pdf_to_txt()` reads local PDFs
and writes local text files; `accounts_txt_to_xlsx()` reads those and
writes one workbook. That is the whole surface.

## Why the middle step is manual

A PDF financial statement is a table whose structure lives in the layout,
not in the file, and the line labels differ between preparers. A parser
that guessed would produce numbers that look right and are wrong — which is
worse than no numbers, because nothing downstream would flag them. Shaping
the lines is the point at which a person decides what the table actually
says.

What the package does is make everything around that step cheap:

- Extraction is one call over a whole directory.
- PDFs with no extractable text — scans, photographs — are skipped with a
  warning and no `.txt` file. The function will not pretend it read them.
- Validation problems are collected across **all** files and reported
  together at the end, so one malformed line in the twentieth file does not
  cost you nineteen files' worth of feedback. Nothing is written until every
  file has passed.

`vignette("taxmill")` documents the text-file format exactly.

## If you do not have the PDFs yet

For *published* Danish annual reports,
[cvrr](https://github.com/dataniel/cvrr) searches Erhvervsstyrelsens
distribution service and downloads them; point `accounts_pdf_to_txt()` at
the directory it filled.

And check whether the filing exists as XBRL first. If it does,
`cvrr::read_xbrl()` parses it straight into a tibble with no manual step at
all. The mill is for the filings with no machine-readable form — older
reports, small companies, and anything that began life on paper.

## Functions

| Function | Description |
|----------|-------------|
| `accounts_pdf_to_txt()` | Convert PDF financial statements to text files |
| `accounts_txt_to_xlsx()` | Parse shaped text files and export to Excel, validated first |
