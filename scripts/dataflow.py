import time
import re
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, StandardOptions
import logging

project_id = 'log-processing-12345'
region = 'us-central1'

class ParseLogLine(beam.DoFn):
    def process(self, element):
        log_pattern = re.compile(r'^(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) (?P<level>\S+) (?P<message>.+)$')
        match = log_pattern.match(element)
        if match:
            timestamp_str = match.group('timestamp')
            log_level = match.group('level').upper()
            message = match.group('message')
            
            logging.info(f"Parsed log line: timestamp={timestamp_str}, log_level={log_level}, message={message}")
            
            yield {
                'timestamp': timestamp_str,
                'log_level': log_level,
                'message': message
            }
        else:
            logging.warning(f"Failed to parse log line: {element}")

def run(argv=None):
    logging.basicConfig(level=logging.INFO)

    job_name = f"log-processing-pipeline-{int(time.time())}"

    pipeline_options = PipelineOptions(
        flags=argv,
        project=project_id,
        region=region,
        job_name=job_name,
        temp_location='gs://log-processing-12345-raw-logs/temp'
    )
    pipeline_options.view_as(StandardOptions).runner = 'DataflowRunner'

    p = beam.Pipeline(options=pipeline_options)

    logs = (p
            | 'ReadLogFile' >> beam.io.ReadFromText('gs://log-processing-12345-new-logs-bucket/*.txt')
            | 'ParseLogLine' >> beam.ParDo(ParseLogLine())
            | 'WriteToBigQuery' >> beam.io.WriteToBigQuery(
                'log-processing-12345:logs_dataset.processed_logs',
                schema='timestamp:TIMESTAMP,log_level:STRING,message:STRING',
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND
            ))

    result = p.run()
    result.wait_until_finish()

    logging.info("Pipeline finished.")

if __name__ == '__main__':
    run()
