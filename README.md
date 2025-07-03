# Project CheckPDFIncomplete:

## Objective:

Scan a especific diretory verifying all PDF files is complete or have a problem, providing status of each file analised.

## Main function

**CheckFilePDF**: function file's verify:

- **EmptyPDF**: not exists;
- **ErrorOnLoadPDF**: isn't readable;
- **PDFIncompleted**: has start tag (**%PDF**) but not ended with tag (**%%EOF**); and
- **PDFOk**: is complete, has start tag (**%PDF**) and end tag (**%%EOF**).
