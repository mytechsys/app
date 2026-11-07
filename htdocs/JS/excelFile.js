// Load: <script src="https://cdnjs.cloudflare.com/ajax/libs/exceljs/4.4.0/exceljs.min.js"></script>
 
async function downloadTemplate() {
  const categories = ['Benefits', 'Work', 'Bonus', 'Allowance'];
  const processingTypes = ['Off Cycle', 'Urgent', 'Regular', 'Retro'];
  const maxRows = 500; // last row that gets dropdowns, text format and formula
 
  const wb = new ExcelJS.Workbook();
  const ws = wb.addWorksheet('Template');
 
  // Columns A-D are Text format ('@'); E (Combined) stays General so its formula calculates
  ws.columns = [
    { header: 'Row ID', key: 'rowid', style: { numFmt: '@' } },
    { header: 'Name', key: 'name', style: { numFmt: '@' } },
    { header: 'Category', key: 'category', style: { numFmt: '@' } },
    { header: 'Processing Type', key: 'processingType', style: { numFmt: '@' } },
    { header: 'Combined', key: 'combined' }
  ];
 
  // Header styling
  ws.getRow(1).font = { bold: true };
  ws.getRow(1).fill = {
    type: 'pattern', pattern: 'solid',
    fgColor: { argb: 'FFD9E1F2' }
  };
 
  // Auto-fit column width
  const lists = { category: categories, processingType: processingTypes };
  ws.columns.forEach(col => {
    const candidates = [col.header, ...(lists[col.key] || [])];
    col.width = Math.max(...candidates.map(v => String(v).length)) + 4;
  });
  ws.getColumn('name').width = 28;
  ws.getColumn('combined').width = 45;
 
  const rule = list => ({
    type: 'list',
    allowBlank: true,
    formulae: [`"${list.join(',')}"`],
    showErrorMessage: true,
    errorTitle: 'Invalid value',
    error: 'Please select a value from the list'
  });
 
  for (let r = 2; r <= maxRows; r++) {
    // Text format on every input cell
    ['A', 'B', 'C', 'D'].forEach(col => {
      ws.getCell(col + r).numFmt = '@';
    });
 
    // Dropdowns
    ws.getCell('C' + r).dataValidation = rule(categories);
    ws.getCell('D' + r).dataValidation = rule(processingTypes);
 
    // Combined value of the whole row in one cell, e.g. 101|Ravi|Bonus|Off Cycle
    ws.getCell('E' + r).value = {
      formula: `IF(COUNTA(A${r}:D${r})=0,"",TEXTJOIN("|",TRUE,A${r}:D${r}))`
    };
  }
 
  // Download
  const buffer = await wb.xlsx.writeBuffer();
  const blob = new Blob([buffer], {
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'template.xlsx';
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}
 
