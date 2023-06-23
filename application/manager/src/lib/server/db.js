import mysql from 'mysql2/promise'
import { DB_PASS } from '$env/static/private'

/** @type {mysql.Connection} */
let mysqlconn

export const connection = async () => {
    if (!mysqlconn) {
        mysqlconn = await mysql.createConnection({
            host: 'localhost',
            user: 'root',
            password: DB_PASS,
            database: 'mydb',
        })
    }
    return mysqlconn
}

export const closeConnection = () => {
    mysqlconn.end()
    mysqlconn = undefined
}