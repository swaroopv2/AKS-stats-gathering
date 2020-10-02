#!/bin/bash
echo "starting NVMe read and write tests on the pod"
total_mem=$(free -h|grep Mem|awk '{print $2}'|tr -d 'G')
size=$(( $total_mem * 2 ))'G'
target_directory="/mnt/nvme"
home_directory="/templates"
read_file[0]="$home_directory/read1.fio"
read_file[1]="$home_directory/read2.fio"
read_file[2]="$home_directory/read3.fio"
read_file[3]="$home_directory/read4.fio"
read_file[4]="$home_directory/read5.fio"
write_file[0]="$home_directory/write1.fio"
write_file[1]="$home_directory/write2.fio"
write_file[2]="$home_directory/write3.fio"
write_file[3]="$home_directory/write4.fio"
write_file[4]="$home_directory/write5.fio"
iodepths=( 8 16 32 48 64 )

for index in 0 1 2 3 4
    do
        rw="read"
        numjobs=2
	iodepth=${iodepths[$index]}
        cat > ${read_file[$index]}<<End-of-message
[seq-$rw-$index]
ioengine=libaio
runtime=600
direct=1
group_reporting=1
directory=$target_directory
time_based=1
bs=8k
numjobs=$numjobs
size=$size
rw=$rw
iodepth=$iodepth
write_bw_log=$rw-iodepth-$iodepth-numjobs-$numjobs
write_iops_log=$rw-iodepth-$iodepth-numjobs-$numjobs
write_lat_log=$rw-iodepth-$iodepth-numjobs-$numjobs
log_avg_msec=1000

End-of-message
        chmod 644 ${read_file[$index]}
        fio ${read_file[$index]} --output-format=json --output=/logs/$rw-$iodepth-$numjobs.json
        rm -f /mnt/nvme/*
    done

for index in 0 1 2 3 4
    do
        rw="write"
        numjobs=2
	iodepth=${iodepths[$index]}
        cat > ${write_file[$index]}<<End-of-message
[seq-$rw-$index]
ioengine=libaio
runtime=600
direct=1
group_reporting=1
directory=$target_directory
time_based=1
bs=8k
numjobs=$numjobs
size=$size
rw=$rw
iodepth=$iodepth
write_bw_log=$rw-iodepth-$iodepth-numjobs-$numjobs
write_iops_log=$rw-iodepth-$iodepth-numjobs-$numjobs
write_lat_log=$rw-iodepth-$iodepth-numjobs-$numjobs
log_avg_msec=1000

End-of-message
        chmod 644 ${write_file[$index]}
        fio ${write_file[$index]} --output-format=json+ --output=/logs/$rw-$iodepth-$numjobs.json
        rm -f /mnt/nvme/*
    done

echo "END NVMe tests on the Pod"
