import boto3
import argparse

def execute_autoupdater_on_instances(instances):
    ssm_client = boto3.client('ssm')
    response = ssm_client.send_command(
        InstanceIds=[instances],
        DocumentName="AWS-RunShellScript",
        Parameters={'commands': ['/usr/local/bin/testapp-autoupdater']}, )
    
    return True

# I didn't use tags to filter as today it's less than 50 instances
def retrieve_instances_from_autoscaling_group(autoscaling_group_name):
    instance_ids = []

    asg_client = boto3.client('autoscaling')
    asg_result = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[autoscaling_group_name])

    for asg in asg_result['AutoScalingGroups']:
        for instance in asg['Instances']:
            instance_ids.append(instance['InstanceId'])

    return instance_ids

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Executing CodeDeploy actions.')
    requiredNamed = parser.add_argument_group('required named arguments')
    requiredNamed.add_argument('--autoscaling-group-name', help='Autoscaling Group Name', required=True)
    args = parser.parse_args()
    instances = retrieve_instances_from_autoscaling_group(args.autoscaling_group_name)
    execute_autoupdater_on_instances(instances)
