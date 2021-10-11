import boto3
import argparse


def execute_autoupdater_on_instances(instances):
    return


def retrieve_instances_from_autoscaling_group(autoscaling_group_name):
    return


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Executing CodeDeploy actions.')
    requiredNamed = parser.add_argument_group('required named arguments')
    requiredNamed.add_argument('--autoscaling-group-name', help='Autoscaling Group Name', required=True)
    args = parser.parse_args()
    instances = retrieve_instances_from_autoscaling_group(args.autoscaling_group_name)
    execute_autoupdater_on_instances(instances)
