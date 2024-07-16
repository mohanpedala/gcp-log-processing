import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.value_provider import ValueProvider
import argparse

class CustomPipelineOptions(PipelineOptions):
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_value_provider_argument(
            '--input_bucket',
            type=str,
            help='GCS bucket to read input files from'
        )

def run(argv=None):
    parser = argparse.ArgumentParser()
    known_args, pipeline_args = parser.parse_known_args(argv)
    
    pipeline_options = PipelineOptions(pipeline_args)
    custom_options = pipeline_options.view_as(CustomPipelineOptions)

    with beam.Pipeline(options=pipeline_options) as p:
        (
            p
            | 'ReadFromGCS' >> beam.io.ReadFromText(custom_options.input_bucket)
            | 'ParseLog' >> beam.ParDo(ParseLog())
            | 'FormatForBigQuery' >> beam.ParDo(FormatForBigQuery())
            | 'WriteToBigQuery' >> beam.io.WriteToBigQuery(
                'your-project-id:logs_dataset.processed_logs',
                schema='timestamp:TIMESTAMP,level:STRING,message:STRING',
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND)
        )

if __name__ == '__main__':
    run()
