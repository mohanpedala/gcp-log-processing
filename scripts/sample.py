import re
import os

# Directory containing log files
log_directory = 'sample-logs/'

# Regular expression pattern to capture timestamp, level, and message
log_pattern = re.compile(r'^(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) (?P<level>\S+) (?P<message>.+)$')

def parse_log_line(line):
    """Parse a single log line and return a dictionary with timestamp, level, and message."""
    print(f"Processing line: {line}")  # Debugging line
    match = log_pattern.match(line)
    if match:
        return {
            'timestamp': match.group('timestamp'),
            'level': match.group('level').upper(),
            'message': match.group('message')
        }
    else:
        print("No match found.")  # Debugging line
    return None

def parse_logs_from_file(file_path):
    """Read a log file and parse each line."""
    with open(file_path, 'r') as file:
        for line in file:
            parsed_log = parse_log_line(line.strip())
            if parsed_log:
                print(f"{parsed_log}\n")

def main():
    # Process each log file in the directory
    for log_file in os.listdir(log_directory):
        if log_file.endswith('.txt'):
            print(f'Parsing {log_file}...')
            file_path = os.path.join(log_directory, log_file)
            parse_logs_from_file(file_path)

if __name__ == '__main__':
    main()
