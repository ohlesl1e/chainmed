import { connection, closeConnection } from '$lib/server/db'

export const GET = async ({ request, url }) => {
    let db = await connection()
    let query = `%${url.searchParams.get('search').split(' ').join('%')}%`
    let [results, field] = await db.execute('SELECT PROPRIETARYNAME,NONPROPRIETARYNAME,MARKETINGCATEGORYNAME,LABELERNAME,SUBSTANCENAME,ACTIVE_NUMERATOR_STRENGTH,ACTIVE_INGRED_UNIT,PHARM_CLASSES FROM medicine WHERE PROPRIETARYNAME LIKE ? OR NONPROPRIETARYNAME LIKE ? LIMIT 100', [query, query])
    closeConnection()
    return new Response(JSON.stringify(results))
}