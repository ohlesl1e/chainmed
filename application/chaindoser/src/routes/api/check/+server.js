import { connection, closeConnection } from "$lib/server/db";

export const POST = async ({ request }) => {
    let db = await connection()
    let { address, schedule } = await request.json();
    let startTime = new Date(Date.now())
    if (schedule.frequency === 0) {
        startTime.setDate(startTime.getDate() - schedule.interval)
    } else {
        startTime.setDate(startTime.getDate() - 7)
    }
    let [rows, fields] = await db.execute('SELECT report_time FROM log WHERE treatment_address=? AND report_time BETWEEN ? AND now()', [address, startTime.toISOString().slice(0, 19).replace('T', ' ')])
    console.log(rows);
    closeConnection()
    return new Response(JSON.stringify(rows))
}