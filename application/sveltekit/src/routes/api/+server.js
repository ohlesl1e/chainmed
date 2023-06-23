import { connection } from '$lib/server/db'

export const GET = async ({ params, url }) => {
    console.log('hit')
    // console.log({ params, url });
    let query = `%advil%`

    let db = await connection()
    let [rows, fields] = await db.execute('SELECT PROPRIETARYNAME,NONPROPRIETARYNAME,MARKETINGCATEGORYNAME,LABELERNAME,SUBSTANCENAME,ACTIVE_NUMERATOR_STRENGTH,ACTIVE_INGRED_UNIT,PHARM_CLASSES FROM medicine WHERE PROPRIETARYNAME LIKE ? OR NONPROPRIETARYNAME LIKE ?', [query, query])

    return new Response(JSON.stringify(rows))
}