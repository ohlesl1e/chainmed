const fs = require('fs')
require('dotenv').config()
const papa = require('papaparse')
const mysql = require('mysql2')

let meds = [{}]

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: process.env.DB_PASS,
    database: 'mydb',
    connectionLimit: 128,
})

fs.readFile('product_processed.csv', 'utf-8', (err, data) => {
    if (err) {
        console.error(err)
        return
    }
    const result = papa.parse(data, { header: true, worker: true })
    meds = result.data
    let counter = 0
    console.log(meds.length);
    for (const med of result.data) {
        let col = Object.keys(med)
        let val = Object.values(med)
        val[8] = parseFloat(val[8])
        val[9] = isNaN(parseFloat(val[9])) ? 0 : parseFloat(val[9])
        val[18] = 'N' ? 0 : 1
        val[19] = isNaN(parseFloat(val[19])) ? 0 : parseFloat(val[9])
        pool.execute(`INSERT INTO medicine (${col.join(',')}) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`, val, (err, result, fields) => {
            if (err) {
                throw (err)
            }
            counter++
            console.log(counter);
        })
        // if (counter === 65234) {
        //     process.exit(1)
        // }
    }
})