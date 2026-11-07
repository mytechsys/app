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



// Load: <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
 
function downloadTemplate() {
  const categories = ['Benefits', 'Work', 'Bonus', 'Allowance'];
  const processingTypes = ['Off Cycle', 'Urgent', 'Regular', 'Retro'];
  const maxRows = 500; // last row that gets text format and formula
 
  const headers = ['Row ID', 'Name', 'Category', 'Processing Type', 'Combined'];
  const ws = XLSX.utils.aoa_to_sheet([headers]);
 
  // Column widths (header + dropdown values)
  const longest = (arr) => Math.max(...arr.map(v => String(v).length));
  ws['!cols'] = [
    { wch: longest(['Row ID']) + 4 },
    { wch: 28 },
    { wch: longest(['Category', ...categories]) + 4 },
    { wch: longest(['Processing Type', ...processingTypes]) + 4 },
    { wch: 45 }
  ];
 
  for (let r = 2; r <= maxRows; r++) {
    // Columns A-D: Text format ('@')
    ['A', 'B', 'C', 'D'].forEach(col => {
      ws[col + r] = { t: 's', v: '', z: '@' };
    });
 
    // Column E: combined value, e.g. 101|Ravi|Bonus|Off Cycle
    ws['E' + r] = {
      t: 's',
      f: `IF(COUNTA(A${r}:D${r})=0,"",TEXTJOIN("|",TRUE,A${r}:D${r}))`
    };
  }
 
  ws['!ref'] = `A1:E${maxRows}`;
 
  // SheetJS Pro only: dropdown lists
  // ws['!dataValidation'] = [
  //   { sqref: `C2:C${maxRows}`, type: 'list', formula1: `"${categories.join(',')}"` },
  //   { sqref: `D2:D${maxRows}`, type: 'list', formula1: `"${processingTypes.join(',')}"` }
  // ];
 
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Template');
  XLSX.writeFile(wb, 'template.xlsx');
}


// Load: <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
 
function downloadTemplate() {
  const categories = ['Benefits', 'Work', 'Bonus', 'Allowance'];
  const processingTypes = ['Off Cycle', 'Urgent', 'Regular', 'Retro'];
  const maxRows = 500;
 
  const headers = ['Row ID', 'Name', 'Category', 'Processing Type', 'Combined'];
  const ws = XLSX.utils.aoa_to_sheet([headers]);
 
  const longest = arr => Math.max(...arr.map(v => String(v).length));
  ws['!cols'] = [
    { wch: longest(['Row ID']) + 4 },
    { wch: 28 },
    { wch: longest(['Category', ...categories]) + 4 },
    { wch: longest(['Processing Type', ...processingTypes]) + 4 },
    { wch: 45 }
  ];
 
  for (let r = 2; r <= maxRows; r++) {
    ['A', 'B', 'C', 'D'].forEach(col => {
      ws[col + r] = { t: 's', v: '', z: '@' };
    });
    ws['E' + r] = {
      t: 's',
      f: `IF(COUNTA(A${r}:D${r})=0,"",TEXTJOIN("|",TRUE,A${r}:D${r}))`
    };
  }
  ws['!ref'] = `A1:E${maxRows}`;
 
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Template');
 
  const data = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
  const blob = new Blob([data], {
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  });
  const url = URL.createObjectURL(blob);
 
  // Open in a new tab AND download with a proper file name
  const a = document.createElement('a');
  a.href = url;
  a.target = '_blank';
  a.rel = 'noopener';
  a.download = 'template.xlsx';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
 
  // Keep the URL alive long enough for the new tab to load it
  setTimeout(() => URL.revokeObjectURL(url), 60000);
}
 
document.getElementById('downloadBtn')?.addEventListener('click', downloadTemplate);
 
 
