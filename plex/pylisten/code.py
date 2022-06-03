import boto3, json, requests, sys, os, time
from threading import Timer

queue_url = os.environ['QUEUE_URL']
rclone_url_refresh = 'http://rclone:5572/vfs/refresh'
rclone_url_forget = 'http://rclone:5572/vfs/forget'
plex_token = os.environ['PLEX_TOKEN']
i=0

client = boto3.client('sqs', 'us-east-1')
t = Timer(0,0)
ltype = None

def notify_plex(type):
    plex = {'Movies':'2', 'TV':'39', 'Scenes':'46', 'token': plex_token}
    if type not in plex:    return
    try:
        url ='http://plex:32400/library/sections/{}/refresh?X-Plex-Token={}'.format(plex[type], plex['token'])
        r = requests.get(url)
        if r.status_code == 200:
            print("Notifying Plex. Refreshing {}. {}".format(type, url))
        else:
            print("Plex notify failed")
    except:
        print("Exception raised")
        pass

print('Started pylisten')
time.sleep(30)
print('Init FS Refresh')
init_refresh = requests.post(rclone_url_refresh, json={'recursive': 'true'}).json()
print(init_refresh)
print("Started listening")

while True:
    i = (i + 1) % 10
    # print("Ping %d" % i)
    try:
        messages = client.receive_message(QueueUrl=queue_url, MaxNumberOfMessages=10)
    except:
        print("Exception in receive message")
        continue
    if 'Messages' in messages:
        for message in messages['Messages']:
            body = json.loads(message['Body'])['Message']
            path = json.loads(body)['Records'][0]['s3']['object']['key']
            path = path.split("/x/")[1]
            dpath = path.rsplit("/", 1)[0]
            walk = ''
            for p in dpath.split("/"):
                walk = walk + p + '/'
                resp = requests.post(rclone_url_refresh, json={'dir': walk}).json()
                #print(resp)
            resp = requests.post(rclone_url_forget, json={'file': path}).json()
            print(resp)

            if 'Anime/' in path:
                type = 'Anime'
            if 'TV/' in path:
                type = 'TV'
            if 'TV-UHD/' in path:
                type = 'TV'
            if 'TV-Old/' in path:
                type = 'TV'
            if 'Movies/' in path:
                type = 'Movies'
            if 'Movies-UHD/' in path:
                type = 'Movies'
            if 'Scenes/' in path:
                type = 'Scenes'

            if ( type != ltype or (not t.is_alive()) ):
                notify_plex(type)
                t = Timer(60, notify_plex, [type])
                t.start()
            else:
                t.cancel()
                t = Timer(60, notify_plex, [type])
                t.start()

            ltype = type
            client.delete_message(QueueUrl=queue_url, ReceiptHandle=message['ReceiptHandle'])
