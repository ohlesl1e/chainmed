import webpush from 'web-push'
import { connection } from '$lib/server/db'
import { PRIVATE_PUSH_KEY, PUSH_SUB } from '$env/static/private'
import { PUBLIC_PUSH_KEY } from '$env/static/public'

webpush.setVapidDetails(PUSH_SUB, PUBLIC_PUSH_KEY, PRIVATE_PUSH_KEY)

export const POST = async ({ request }) => {
    let db = await connection()
    let { address, treatment, access } = await request.json()

    try {
        let [result] = await db.execute('SELECT endpoint, sub_keys FROM subscription WHERE address=?', [address])

        result.forEach(sub => {
            webpush.sendNotification({
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
            console.log(sub)
        });

        return new Response(JSON.stringify({ message: 'success' }))
    } catch (error) {
        console.log(error);
        return new Response(JSON.stringify({ message: 'failed' }), { status: 500 })
    }
}