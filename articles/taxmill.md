# From PDF accounts to a tidy dataset

A financial statement is a table. It was a table when it was drawn up,
and it is still a table when it arrives as a PDF – only now the
structure lives in the layout instead of in the file. Tax accounts and
ordinary annual accounts are both like this, and that shared layout is
the only thing this package relies on.

`taxmill` is the route back to a dataset: text out of the PDF, a manual
pass to shape the statement into simple lines, and one call that parses
every file at once into a validated Excel workbook in tidy form.

The two `accounts_*` functions were built for collecting financial
statements and tax documents in a setting where the PDF is often the
only digital trace of the report, and sometimes just a scan of paper.
That is the reality behind the accounts statistics at Statistics
Greenland. Nothing in the method is tied to that setting, though: the
same steps work for any workflow that has to go from PDF reports through
manual review to structured data.

## Nothing leaves the machine

This matters more here than in most packages. The documents you point
`taxmill` at are usually confidential – a tax account is not a published
annual report – and there is no upload, no API call, and no service in
the loop.
[`accounts_pdf_to_txt()`](https://dataniel.github.io/taxmill/reference/accounts_pdf_to_txt.md)
reads local PDFs and writes local text files.
[`accounts_txt_to_xlsx()`](https://dataniel.github.io/taxmill/reference/accounts_txt_to_xlsx.md)
reads those and writes one workbook. That is the whole surface.

## The four steps

1.  **Convert** the PDFs to text files with
    [`accounts_pdf_to_txt()`](https://dataniel.github.io/taxmill/reference/accounts_pdf_to_txt.md).
2.  **Format** the text files by hand: financial statements are
    inherently table-like, so the relevant lines are shaped into a
    simple space-delimited format.
3.  **Parse and combine** all text files into a single validated Excel
    file with
    [`accounts_txt_to_xlsx()`](https://dataniel.github.io/taxmill/reference/accounts_txt_to_xlsx.md).
4.  **Review and code** in Excel: the element labels are free text taken
    from the PDFs, so this is where they are checked and mapped to a
    classification if needed.

If the PDFs are *published* annual reports, `cvrr` fetches them from
Erhvervsstyrelsens distribution service and its output directory feeds
directly into step 1. Confidential statements – tax accounts and the
like – you already have; they go into the same directory and through the
same steps.

Before you start shaping text by hand, check whether the filing exists
as XBRL. If it does, `cvrr::read_xbrl()` parses it straight into a
tibble with no manual step at all. The mill is for the filings with no
machine-readable form – older reports, small companies, and anything
that began life on paper.

## Step 1: `accounts_pdf_to_txt()`

Reads all PDF files in a directory, extracts their text, and writes one
`.txt` file per PDF. Requires `pdftools`.

``` r
accounts_pdf_to_txt(
  pdf_dir = "data/pdf",
  txt_dir = "data/txt"
)
```

- The output directory is created automatically; file names (typically
  CVR numbers) are preserved.
- PDFs with no extractable text (typically scanned or photo-printed
  reports) are skipped with a warning, and no `.txt` file is written for
  them. Those companies have to be keyed in manually or OCR’ed.
- Existing `.txt` files are never overwritten unless you pass
  `overwrite = TRUE`.

## Step 2: the text file format

This is the manual step. Open each text file, find the financial
statement, and shape the relevant lines into the format below; delete
the rest. Each line is either a *category line* or a *data line*:

- **Category line:** a single string with no field delimiter. Sets the
  `note` value for all subsequent data lines.
- **Data line:** three fields separated by `min_spaces` or more
  consecutive spaces (default 3): (1) element name, (2) amount for
  `year`, (3) amount for `year - 1`.

&nbsp;

    Resultatopgoerelse
    Nettoomsaetning   1.234.000   1.100.000
    Andre indtaegter   200.000
    Omkostninger statnatio
    Personaleomkostninger   500.000   400.000

The conventions:

- Amounts are whole kroner; periods used as thousands separators are
  stripped automatically. Values are scaled to thousands in the output.
- If no previous-year amount exists, the third field may be left empty
  and becomes `NA`.
- Appending `statnatio` to a category line negates all amounts in that
  category, useful when costs appear with a positive sign in notes. The
  suffix is stripped from the final output.
- File names become the `cvr` column. A trailing `_spec` suffix is
  stripped automatically (e.g. `12345678_spec.txt` -\> `12345678`).

Why *statnatio*? The negation marker has to stand out visually, and it
must be a word that never occurs in a real financial statement, since a
genuine label would otherwise trigger the negation by accident.
*statnatio* is the name of the national accounts project folder at
Statistics Greenland, suggested by the colleague who runs the national
accounts and helps prepare these data. It does the job on both counts.

The `_spec` suffix exists for a similar practical reason. One company
often comes with several documents, and it is not always obvious which
one is the right basis for the statistics. Tagging the file names lets
you keep all of them for the same CVR without losing the link from file
to company: the document you believe holds the specifications gets
`_spec`, and other candidates can get other tags. Note that the parser
only recognises `_spec`, so files with other tags should be kept out of
the text directory (or renamed) before step 3, since their tag would
otherwise end up in the `cvr` column.

### Why this step is not automated

It is the slow part, and it is slow on purpose. A PDF financial
statement has no reliable machine-readable structure, and the line
labels differ between preparers. A parser that guessed would produce
numbers that look right and are wrong – which is worse than no numbers,
because nothing downstream would flag them. Shaping the lines is the
point at which a person decides what the table actually says.

What the package can do is make everything around that step cheap:
extraction is one call over a whole directory, unreadable PDFs are named
rather than silently skipped, and every mistake in the shaped files is
caught in one pass before anything is written.

## Step 3: `accounts_txt_to_xlsx()`

Parses every text file in the directory, validates them, and writes one
combined Excel file. Requires `writexl`.

``` r
df <- accounts_txt_to_xlsx(
  txt_dir  = "data/txt",
  out_file = "data/output.xlsx",
  year     = 2024
)
```

Validation is built into this step. Every company is checked for:

1.  Commas in value columns (a sign of a wrong decimal separator).
2.  `NA` in `note` or `elementid` (a missing category line).
3.  Non-numeric current-year values (a parsing failure).

Violations are collected across *all* companies and reported together in
one error that names each offending company, file, and line or element,
so one run gives you the complete fix-list instead of one error at a
time. Nothing is written until every file passes. Files with no data
lines at all are skipped with a warning, and an existing `out_file` is
guarded by `overwrite`.

## Step 4: review and code

The result is a long-format dataset with one row per company, element,
and year, in both the returned tibble and the Excel file. The
`elementid` and `note` columns hold the free-text labels from the PDFs,
lowercased but otherwise untouched. The Excel file is where those labels
are reviewed and, if the downstream statistics require it, mapped to a
standard classification.

A practical Excel tip for the coding itself: filter the rows down to the
labels that should get the same code, then fill the code down across the
*filtered* rows only. An ordinary copy-paste also fills the hidden rows
in between, which is the trap. The way around it is the easy-to-forget
*visible cells only* selection: select the target cells, press `Alt+;`
(Go To Special -\> Visible cells only), type the code, and confirm with
`Ctrl+Enter`. Every visible cell is filled and the hidden rows are left
untouched.
