import sys
import yaml

'''
Helper script to merge arbitraly number of yaml files

Usage: python yaml_merge.py file1.yaml file2.yaml ... fence-config.yaml

Example: python yaml_merge.py file1.yaml file2.yaml fence-config.yaml
file1.yaml key(s) will overriden by items in file2.yaml if they exist, 

'''
def merge_yaml_files(file_paths):
    merged_data = {}

    for file_path in file_paths:
        try:
            with open(file_path, 'r') as file:
                data = yaml.safe_load(file)
                merged_data = merge_dicts(merged_data, data)
        except FileNotFoundError as e:
            print('WARNING! File not found: {}. Will be ignored!'.format(file_path))

    return merged_data

def merge_dicts(dict1, dict2):
    if dict2 is not None: #Fix AttributeError
        for key, value in dict2.items():
            if key in dict1 and isinstance(dict1[key], dict) and isinstance(value, dict):
                dict1[key] = merge_dicts(dict1[key], value)
            else:
                dict1[key] = value

    return dict1

def save_merged_file(merged_data, output_file_path):
    with open(output_file_path, 'w') as output_file:
        yaml.dump(merged_data, output_file, default_flow_style=False)

if __name__ == "__main__":
    # Check if at least two arguments are provided (including the script name)
    if len(sys.argv) < 3:
        print("Usage: python yaml_merge.py config-file1.yaml config-file2.yaml ... fence-config.yaml")
        sys.exit(1)

    # Extract input file paths and output file path
    input_files = sys.argv[1:-1]
    output_file = sys.argv[-1]

    # Merge YAML files
    merged_data = merge_yaml_files(input_files)

    # Save the merged data to the output file
    save_merged_file(merged_data, output_file)

    print(f"Merged Configuration saved to {output_file}")
