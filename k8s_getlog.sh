"========================================================"
echo "This script is to collect logs ($k logs, $k describe, etc) from the pods."
echo "For the DSSErrors.log, please copy them from the persistent volume which will not be collected by this script."
echo "Steps to run the script inside the machine can access the kubernetes:"
echo ""
echo "1. chmod +x ./getlog.sh"
echo "2.  ./getlog.sh"
echo ""
echo "=== Written by evan_l00 ==="
echo "========================================================"
echo ""

today=$(printf '%(%Y-%m-%d)T\n' -1)
PWD="$(pwd)/$today"

namespace=
read -p "Please input the kubernetes namespace (something like mstr-env-mci-8oq3w-dev): "  namespace
time_frame=3200

read -p "Please input the time interval you want to collect the logs, default is 3200s:" time_frame

i=0
while [ $i -lt 4 ]
do
    log_time=$(printf '%(%Y-%m-%d-%H-%M)T\n' -1)
    logs="logs_customer_$log_time"
    mkdir -p "$PWD/$logs"
    export k=kubectl
    targets="server bakup"
    for target in $targets
    do
        echo "gettting $target $k describe"
        pod_names=$($k get pod -n "$namespace" | grep $target | awk '{ print $1}')
        echo "pods: $pod_names"
        #readarray -t, pod_names <<<"$pod_names";  declare -p pod_names;
        for pod_name in $pod_names
        do
            echo "getting $k describe pod $pod_name"
            $k describe pod "$pod_name" -n "$namespace" > "$PWD/$logs/$pod_name-describe-pod.log"
            container_names=$($k get pod $pod_name -n "$namespace" -o jsonpath='{.spec.containers[*].name}')
            #readarray -t container_names <<<"$container_names"; declare -p container_names;
            for container_name in $container_names
            do
                echo "getting $k logs $container_name"
                $k logs "$pod_name" -n "$namespace" -c "$container_name" > "$PWD/$logs/$pod_name-$container_name-pod-container-logs.log"
                $k logs "$pod_name" -n "$namespace" -c "$container_name" -p > "$PWD/$logs/$pod_name-$container_name-pod-container-pre-logs.log"

                $k exec "$pod_name" -n "$namespace" -c "$container_name" -- printenv | grep -v PASSWORD> "$PWD/$logs/$pod_name-$container_name-pod-container-env.log"
            done
            echo "getting the yaml definition"
            $k get pod "$pod_name" -n "$namespace" -o yaml > "$PWD/$logs/$pod_name-pod-definition.yaml"

                echo "getting the init containers log"
            container_names=$($k get pod $pod_name -n "$namespace" -o jsonpath='{.spec.initContainers[*].name}')
            #readarray -t container_names <<<"$container_names"; declare -p container_names;
            for container_name in $container_names
            do
                echo "getting $k logs $container_name"
                $k logs "$pod_name" -n "$namespace" -c "$container_name"> "$PWD/$logs/$pod_name-$container_name-pod-initContainer-logs.log"
            done
            echo "getting the yaml definition"
            $k get pod "$pod_name" -n "$namespace" -o yaml > "$PWD/$logs/$pod_name-pod-definition.yaml"
        done

    done

    jobs="mstrbak"
    for job in $jobs
    do
        echo "getting $job $k describe"
        job_names=$($k get job -n "$namespace" | grep $job | awk '{ print $1}')
        echo "jobs: $job_names"
        #readarray -t, job_names <<<"$job_names";  declare -p job_names;
        for job_name in $job_names
        do
            echo "getting $k describe job $job_name"
            $k describe job "$job_name" -n "$namespace" > "$PWD/$logs/$job_name-describe-job.log"
            echo "getting the yaml definition"
            $k get job "$job_name" -n "$namespace" -o yaml > "$PWD/$logs/$job_name-job-definition.yaml"
        done
    done
    $k get events -n "$namespace" > "$PWD/$logs/kubernetes-events.log"

    dmesg > "$PWD/$logs/dmesg.txt"

    echo "The logs are saved to $logs!"

    services="server"
    for service in $services
    do
        echo "getting $service service"
        service_names=$($k get svc -n "$namespace" | grep $service | awk '{ print $1 }')
        for service_name in $service_names
        do
            echo "getting $service_name"
            $k describe svc $service_name -n "$namespace" > "$PWD/$logs/$service_name-describe-svc.log"
            echo "getting yaml definition"
            $k get svc "$service_name" -n "$namespace" -o yaml > "$PWD/$logs/$service_name-svc-definition.yaml"
        done
    done


    helm list -a > "$PWD/$logs/helm-info.log"
    $k get pod -n "$namespace" > "$PWD/$logs/pods.log"

    echo "collecting cron job"
    cronjobs=$($k get cronjob -n "$namespace" -o jsonpath="{.items[*].metadata.name}")
    for cjob in $cronjobs
    do
        $k get cronjob $cjob -n "$namespace" -o yaml > "$PWD/$logs/$cjob-cronjob-definition.yaml"
        $k describe cronjob $cjob -n "$namespace" > "$PWD/$logs/$cjob-cronjob-describe.log"
    done 
    i=$(($i + 1))
    time_sleep=0
    while [ $time_sleep -lt $time_frame ]
    do
        echo -n "."
        sleep 1
    done
done
tar cvf "logs_$today.tar" "$PWD" 
