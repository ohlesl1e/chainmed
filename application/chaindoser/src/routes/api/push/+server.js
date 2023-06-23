import webpush from 'web-push'
import { connection, closeConnection } from '$lib/server/db'
import { PRIVATE_PUSH_KEY, PUSH_SUB } from '$env/static/private'
import { PUBLIC_PUSH_KEY } from '$env/static/public'

webpush.setVapidDetails(PUSH_SUB, PUBLIC_PUSH_KEY, PRIVATE_PUSH_KEY)

export const POST = async ({ request }) => {
    let db = await connection()
    let { address, treatment, access } = await request.json()

    try {
        let [result] = await db.execute('SELECT endpoint, sub_keys FROM subscription WHERE address=?', [address])

        for (const sub of result) {
            try {
                const res = await webpush.sendNotification({
                    endpoint: sub.endpoint,
                    expirationTime: null,
                    keys: JSON.parse(sub.sub_keys)
                }, JSON.stringify(access ? {
                    title: 'Access Request',
                    body: access === 'request' ? 'You have a new access request' : 'Your request has been granted'
                } : {
                    title: 'Reminder',
                    body: treatment ? `Reminder to take your medicine for ${treatment}` : 'You have new treatment'
                }))
                console.log({ res });
            } catch (error) {
                // console.log({ error });
                if (error.statusCode === 410) {
                    try {
                        console.log({ sub });
                        await db.execute('DELETE FROM subscription WHERE endpoint=?', [sub.endpoint])
                    } catch (error) {
                        console.log('MySQL Error: ', { error });
                    }
                }
            }
        }
        // result.forEach(sub => {

        //     // console.log(sub)
        // });
        closeConnection()
        return new Response(JSON.stringify({ message: 'success' }))
    } catch (error) {
        console.log(error);
        closeConnection()
        return new Response(JSON.stringify({ message: 'failed' }), { status: 500 })
    }
}