import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, SetupOptions

class ParseLog(beam.DoFn):
    def process(self, element):
        import re
        pattern = re.compile(r'^(?P<timestamp>\S+ \S+) (?P<level>\S+) (?P<message>.+)$')
        match = pattern.match(element)
        if match:
            yield {
                'timestamp': match.group('timestamp'),
                'level': match.group('level'),
                'message': match.group('message')
            }

class FormatForBigQuery(beam.DoFn):
    def process(self, element):
        yield {
            'timestamp': element['timestamp'],
            'level': element['level'],
            'message': element['message']
        }

def run(argv=None):
    pipeline_options = PipelineOptions()
    p = beam.Pipeline(options=pipeline_options)

    (p
     | 'ReadFromGCS' >> beam.io.ReadFromText('gs://your-project-id-raw-logs/*.txt')
     | 'ParseLog' >> beam.ParDo(ParseLog())
     | 'FormatForBigQuery' >> beam.ParDo(FormatForBigQuery())
     | 'WriteToBigQuery' >> beam.io.WriteToBigQuery(
         'your-project-id:logs_dataset.processed_logs',
         schema='timestamp:TIMESTAMP,level:STRING,message:STRING',
         create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
         write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND)
    )

    result = p.run()
    result.wait_until_finish()

if __name__ == '__main__':
    run()
