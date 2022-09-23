const fs = require('fs')
const csv = require('csv').parse
const papa = require('papaparse')

let med

fs.readFile('product_processed.csv', 'utf-8', (err, data) => {
    if (err) {
        console.error(err)
        return
    }
    const result = papa.parse(data, { header: true, worker: true })
    med = result.data
    console.log(med[652]);
})