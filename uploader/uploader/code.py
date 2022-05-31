import sys, os, signal, logging, requests, concurrent.futures, time, boto3, json
from flask import Flask, request

SNS_TOPIC_URL = os.environ['UPLOADER_SNS_TOPIC_URL']
S3_BASE_PATH = os.environ['UPLOADER_S3_BASE_PATH']
LOCAL_PATH = os.environ['UPLOADER_LOCAL_PATH']
REMOTE_PATH = os.environ['UPLOADER_REMOTE_PATH']
MOUNT_PATH = os.environ['UPLOADER_MOUNT_PATH']
REMOTE_PATH_NAME = REMOTE_PATH[:-1]
RCLONE_RC_ENDPOINT = os.environ['RCLONE_RC_ENDPOINT']

logging.basicConfig(format='%(asctime)s %(levelname)-8s %(message)s',level=logging.INFO,datefmt='%Y-%m-%d %H:%M:%S')
app = Flask(__name__)

client = boto3.client('sns', 'us-east-1')

executor = concurrent.futures.ThreadPoolExecutor(2)

def handler_stop_signals(signal, frame):
    logging.info('Killed')
    sys.exit(0)

signal.signal(signal.SIGINT, handler_stop_signals)
signal.signal(signal.SIGTERM, handler_stop_signals)

def upload(eppath, root):
    logging.info('Uploading ' + root + eppath)
    remotes = []
    remotes.append({'name': REMOTE_PATH_NAME, 'fs': REMOTE_PATH, 'id': ' ', 'status': False, 'isS3': True, 's3Path': S3_BASE_PATH})
    for remote in remotes:
        url = RCLONE_RC_ENDPOINT + 'operations/copyfile'
        reqObj = {}
        reqObj['srcFs'] = "/"
        reqObj['srcRemote'] = root + eppath
        reqObj['dstFs'] = remote['fs']
        reqObj['dstRemote'] = eppath
        reqObj['_async'] = True
        remote['id'] = requests.post(url, json=reqObj).json()['jobid']
        logging.info("Queued upload on {} ID {}".format(remote['name'], remote['id']))

    while True:
        check = 0
        for remote in remotes:
            if remote['status'] == True:    continue
            url = RCLONE_RC_ENDPOINT + 'job/status'
            reqObj = {}
            reqObj['jobid'] = remote['id']
            remote['status'] = requests.post(url, json=reqObj).json()['finished']
            if remote['status'] == True:
                logging.info("Upload completed on {} ID {}".format(remote['name'], remote['id']))
                if remote['isS3']:
                    message = { "Records": [{"eventName": "ObjectCreated:Put", "s3": {"object": {"key": remote['s3Path'] + eppath}}}] }
                    response = client.publish(TargetArn=SNS_TOPIC_URL, Message=json.dumps({'default': json.dumps(message)}), MessageStructure='json')
            else:
                check = 1
        if check==0:   break
        time.sleep(5)

    resp = requests.post(RCLONE_RC_ENDPOINT + 'vfs/forget', json={'dir': eppath}).json()
    os.remove(root + eppath)

@app.route("/upload", methods=['POST'])
def client_pushed():
    payload = request.get_json(silent=True)
    if payload['eventType'] == "Download":  # Sonarr
        temppath = payload['series']['path']
        if temppath[-1] == '/':
            temppath = temppath[:-1]
        temppath = os.path.basename(os.path.dirname(temppath)) + '/' + os.path.basename(temppath)
        checkpath = MOUNT_PATH + temppath + "/" + os.path.dirname(payload['episodeFile']['relativePath'])
        if not os.path.isdir(checkpath):
            logging.info("Creating path " + checkpath)
            os.makedirs(checkpath)
        recvpath = temppath + '/' + payload['episodeFile']['relativePath']
        executor.submit(upload, recvpath, LOCAL_PATH)
    else:
        executor.submit(upload, payload['file'], LOCAL_PATH + "completed/")
    return "OK"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=False, use_reloader=False)