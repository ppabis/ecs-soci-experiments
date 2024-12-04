#!/usr/bin/env python3

import datetime, time, re, csv, requests, argparse, boto3

parser = argparse.ArgumentParser(description="Test startup time of an ECS service")
parser.add_argument("--service-arn", help="ARN of the ECS service")
parser.add_argument("--cluster-name", help="Name of the ECS cluster")
parser.add_argument("--load-balancer-dns", help="DNS name of the load balancer")
args = parser.parse_args()

ECS = boto3.client("ecs")


def scale_service(service_arn: str, cluster_name: str, desired_count: int):
    """Change desired tasks count of a given service and wait for completion."""
    status = "?"
    ECS.update_service(
        cluster=cluster_name,
        service=service_arn,
        desiredCount=desired_count,
    )
    time.sleep(5)

    # Wait for the service to scale
    while status != "ACTIVE":
        status = ECS.describe_services(
            cluster=cluster_name,
            services=[service_arn],
        )["services"][0]["status"]
        time.sleep(10)


def get_tasks(service_arn: str, cluster_name: str) -> list[str]:
    """Get a list of task ARNs for a given ECS service."""
    response = ECS.list_tasks(
        cluster=cluster_name,
        serviceName=service_arn,
    )
    
    repeats = 8
    while len(response["taskArns"]) == 0 and repeats > 0:
        print(f"Weird, I can't see any tasks, {repeats} repeats left")
        time.sleep(5)
        response = ECS.list_tasks(
            cluster=cluster_name,
            serviceName=service_arn,
        )
        repeats -= 1
    
    return response["taskArns"]


def get_task_details(cluster_name: str, tasks: list[str]) -> list[dict]:
    """Calculates times for the task and gives information about it."""
    response = ECS.describe_tasks(
        cluster=cluster_name,
        tasks=tasks,
    )

    filtered_tasks = []
    for task in response["tasks"]:
        filtered_task = {
            "connectivity": task.get("connectivity"),
            "lastStatus": task.get("lastStatus"),
            "startTime": (task.get("startedAt") - task.get("createdAt")).total_seconds() if task.get("startedAt") and task.get("createdAt") else None,
            "firstConnectionTime": (task.get("connectivityAt") - task.get("createdAt")).total_seconds() if task.get("connectivityAt") and task.get("createdAt") else None,
            "pullTime": (task.get("pullStoppedAt") - task.get("pullStartedAt")).total_seconds() if task.get("pullStoppedAt") and task.get("pullStartedAt") else None,
        }
        filtered_tasks.append(filtered_task)
    return filtered_tasks


def wait_for_all_tasks(cluster_name: str, tasks: list[str]):
    while True:
        _tasks = get_task_details(cluster_name, tasks)
        # check if all lastStatus are "RUNNING"
        if all(task.get("lastStatus") == "RUNNING" or task.get("lastStatus") == "STOPPED" for task in _tasks):
            return tasks
        time.sleep(5)


def sample_boot_time(load_balancer_dns: str, count: int):
    """Samples boot time by requesting the /hashes.txt file from the load balancer."""
    # The following pattern should match <task ARN> Finished at <date time>
    pattern = r'(arn:aws:ecs:.*:task.*)\s*\n?\s*Finished at \w{3} (\w{3}\s+\d+\s+\d+:\d+:\d+ UTC \d+)'
    results = []
    
    for i in range(count):
        response = requests.get(f"http://{load_balancer_dns}/hashes.txt")
        match = re.search(pattern, response.text)

        if match:
            task = match.group(1)
            date = match.group(2)
            # Get created time from ECS using task ARN
            created_time = ECS.describe_tasks(cluster = args.cluster_name, tasks=[task])['tasks'][0]['createdAt']
            boot_time = datetime.datetime.strptime(date, "%b %d %H:%M:%S %Z %Y").replace(tzinfo=datetime.timezone.utc)
            created_time = created_time.astimezone(datetime.timezone.utc)
            results.append((boot_time - created_time).total_seconds())
        else:
            print(f"No match found for {i}")

    return (sum(results) / len(results)) if len(results) > 0 else None
        

def save_results(results: list[dict]):
    with open("results.csv", "w") as f:
        writer = csv.DictWriter(f, fieldnames=["taskCount", "averageFirstConnectionTime", "averageStartTime", "averagePullTime", "averageBootTime"])
        writer.writeheader()
        writer.writerows(results)


def main():
    
    results = []

    for test_case in [1, 2, 3, 8] * 3:
        scale_service(args.service_arn, args.cluster_name, test_case)
        time.sleep(5)
        print(f"Service scaled to {test_case}")

        tasks = get_tasks(args.service_arn, args.cluster_name)
        tasks = wait_for_all_tasks(args.cluster_name, tasks)
        print(f"All tasks are running")

        time.sleep(45)

        task_details = get_task_details(args.cluster_name, tasks)
        averageFirstConnectionTime = sum(task.get("firstConnectionTime") for task in task_details) / len(task_details)
        averageStartTime = sum(task.get("startTime") for task in task_details) / len(task_details)
        averagePullTime = sum(task.get("pullTime") for task in task_details) / len(task_details)
        averageBootTime = sample_boot_time(args.load_balancer_dns, test_case * 2)

        results.append({
            "taskCount": test_case,
            "averageFirstConnectionTime": averageFirstConnectionTime,
            "averageStartTime": averageStartTime,
            "averagePullTime": averagePullTime,
            "averageBootTime": averageBootTime,
        })

        scale_service(args.service_arn, args.cluster_name, 0)
        time.sleep(15)
        print(f"Service scaled to 0")

        tasks = wait_for_all_tasks(args.cluster_name, tasks)
        print(f"All tasks are stopped")
        # In case something fails, keep the results saved
        save_results(results)


if __name__ == "__main__":
    main()
