import base64
import json
import logging
import os

from google.cloud import bigquery
from flask import current_app, Flask, request

app = Flask(__name__)

app.config['PUBSUB_VERIFICATION_TOKEN'] = \
    os.environ['PUBSUB_VERIFICATION_TOKEN']
app.config['PROJECT_ID'] = os.environ['PROJECT_ID']
app.config['BQ_DATASET_NAME'] = os.environ['BQ_DATASET_NAME']
app.config['BQ_TABLE_NAME'] = os.environ['BQ_TABLE_NAME']

@app.route('/')
def hello():
    return 'OK', 200

@app.route('/pubsub/push', methods=['POST'])
def pubsub_push():
    if (request.args.get('token', '') !=
            current_app.config['PUBSUB_VERIFICATION_TOKEN']):
        return 'Invalid request', 400

    logging.info('message is {}'.format(request.data.decode('utf-8')))
    envelope = json.loads(request.data.decode('utf-8'))
    payload = base64.b64decode(envelope['message']['data'])
    logging.info('data is {}'.format(payload))
    payload = json.loads(payload)
    record_to_bq = [payload['datetime'], payload['cpu_temperature'], payload['temperature']]

    if stream_data_to_bq(record_to_bq):
        return 'OK', 200
    else:
        return 'Insert failed', 200

def stream_data_to_bq(json_data):
    bigquery_client = bigquery.Client(current_app.config['PROJECT_ID'])
    dataset = bigquery_client.dataset(current_app.config['BQ_DATASET_NAME'])
    table = dataset.table(current_app.config['BQ_TABLE_NAME'])
    table.reload()

    logging.info('a record to insert to BigQuery: {}'.format(json.dumps(json_data)))

    errors = table.insert_data([json_data])

    if not errors:
        logging.info('Loaded 1 row into {}:{}'.format(app.config['BQ_DATASET_NAME'],
                                                      app.config['BQ_TABLE_NAME']))
        return True
    else:
        logging.error(errors)
        return False

@app.errorhandler(500)
def server_error(e):
    logging.exception('An error occurred during a request.')
    return 'An internal error occurred.', 500
