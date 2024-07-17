import time
import logging
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, StandardOptions
from apache_beam.io.gcp.bigquery import WriteToBigQuery

project_id = "log-processing-12345"
bucket_url = f"gs://{project_id}-raw-logs/"
class ParseLogFn(beam.DoFn):
    def process(self, element):
        import re
        logging.info(f"Processing element: {element}")
        pattern = re.compile(r'^(?P<timestamp>\S+ \S+) (?P<level>\S+) (?P<message>.+)$')
        match = pattern.match(element)
        if match:
            yield {
                'timestamp': match.group('timestamp'),
                'level': match.group('level'),
                'message': match.group('message')
            }

def run(argv=None):
    logging.basicConfig(level=logging.INFO)
    pipeline_options = PipelineOptions()
    pipeline_options.view_as(StandardOptions).runner = 'DataflowRunner'

    # Generate a unique job name
    job_name = f"log-processing-pipeline-{int(time.time())}"

    # Define your pipeline options
    options = PipelineOptions(
        project=project_id,
        region='us-central1',
        temp_location=bucket_url,
        job_name=job_name,
    )

    with beam.Pipeline(options=options) as p:
        (p
         | 'ReadFromGCS' >> beam.io.ReadFromText('gs://log-processing-12345-raw-logs/*.txt')
         | 'ParseLog' >> beam.ParDo(ParseLogFn())
         | 'WriteToBigQuery' >> WriteToBigQuery(
             table='log-processing-12345:logs_dataset.processed_logs',
             schema='timestamp:TIMESTAMP,level:STRING,message:STRING',
             create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
             write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND
         )
        )

if __name__ == '__main__':
    run()
