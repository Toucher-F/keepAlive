#!/bin/bash

function switch-interface {
    ATTACHMENT_ID=$(aws ec2 describe-network-interfaces --network-interface-ids eni-3a3a3166 | grep "AttachmentId" | awk "{print \$2}")
    echo $ATTACHMENT_ID
    ATTACHMENT_ID2=${ATTACHMENT_ID:1}
    #echo $ATTACHMENT_ID2
    ATTACHMENT_ID3=${ATTACHMENT_ID2%\"*}
    echo $ATTACHMENT_ID3
    aws ec2 detach-network-interface --attachment-id $ATTACHMENT_ID3
    aws ec2 attach-network-interface --network-interface-id eni-3a3a3166 --instance-id ${LOCAL_ID} --device-index 1
    sleep 1
    sudo ifdown ens4
    sleep 3
    sudo ifup ens4
}

LOCAL_IP=(172.31.25.127)
PEER_IP=(172.31.29.188)
LOCAL_ID=(i-00d3daf3d2074546e)
INTERFACE_LOCAL=$(ifconfig | grep 172.31.78.25)
SERVICE_STATUS_LOCAL=$(service --status-all | grep haproxy | awk '{print \$2}')
UP="+"

if [  ! -n "$INTERFACE_LOCAL" ];then       #if local server has interface(then: NO, else:YES)
    INTERFACE_PEER=$(ssh  ubuntu@${PEER_IP} "ifconfig | grep 172.31.78.25")
    if [  ! -n "$INTERFACE_PEER" ]; then #if peer server has interface(then: NO, else:YES)
        switch-interface
        $INTERFACE_LOCAL=$(ifconfig | grep 172.31.78.25)
        if [  ! -n "$INTERFACE_LOCAL" ];then
            echo -e "${PEER_IP} interface down, switch failed" | mail -s "${PEER_IP} Interface down(switch failed) From:${LOCAL_IP}"  jeff.yang@saninco.com
        else
            echo -e "${PEER_IP} interface down, switch succeed" | mail -s "${PEER_IP} Interface down(switch succeed) From:${LOCAL_IP}"  jeff.yang@saninco.com
        fi
    else
        SERVICE_STATUS_PEER=$(ssh  ubuntu@${PEER_IP} "service --status-all | grep haproxy | awk '{print \$2}'")
        if [  "{$SERVICE_STATUS_PEER}x" != "{$UP}x" ]; then  #peer haproxy status (then: NO, else:YES)
            ssh  ubuntu@${PEER_IP} "sudo service haproxy restart"
            $SERVICE_STATUS_PEER=$(ssh  ubuntu@${PEER_IP} "service --status-all | grep haproxy | awk '{print \$2}'")
            if [  "{$SERVICE_STATUS_PEER}x" != "{$UP}x" ]; then  #peer haproxy status (then: NO, else:YES)
                switch-interface
                $INTERFACE_LOCAL=$(ifconfig | grep 172.31.78.25)
                if [  ! -n "$INTERFACE_LOCAL" ];then
                    #echo -e "${PEER_IP} interface down, switch failed" | mail -s "${PEER_IP} Interface down(switch failed) From:${LOCAL_IP}"  jeff.yang@saninco.com
                else
                    #echo -e "${PEER_IP} interface down, switch succeed" | mail -s "${PEER_IP} Interface down(switch succeed) From:${LOCAL_IP}"  jeff.yang@saninco.com
                fi
            else
            if

        fi
    fi



else    #local server is master
    if [  "{$SERVICE_STATUS_LOCAL}x" != "{$UP}x" ]; then    #local haproxy status(then: NO, else:YES)
        service haproxy restart
        $SERVICE_STATUS_LOCAL=$(service --status-all | grep haproxy | awk '{print \$2}')
        if [  "{$SERVICE_STATUS_LOCAL}x" != "{$UP}x" ]; then
            echo -e "HA proxy service down,restart failed" | mail -s "self HA proxy down(restart failed) From:${LOCAL_IP}"  jeff.yang@saninco.com
        else
            echo -e "HA proxy service down,restart succeed" | mail -s "self HA proxy down(restart succeed) From:${LOCAL_IP}"  jeff.yang@saninco.com
        fi
    fi
fi


########################################################
    SERVICE_STATUS=$(ssh  ubuntu@172.31.29.188 "service --status-all | grep haproxy | awk '{print \$2}'")
    UP="+"
    echo $SERVICE_STATUS
    echo $UP
    if [  "{$SERVICE_STATUS}x" != "{$UP}x" ]; then
        echo "service down"
        ssh  ubuntu@172.31.29.188 "sudo service haproxy restart"
        SERVICE_STATUS=$(ssh  ubuntu@172.31.29.188 "service --status-all | grep haproxy | awk '{print \$2}'")
        if [  "{$SERVICE_STATUS}x" != "{$UP}x" ]; then
            ATTACHMENT_ID=$(aws ec2 describe-network-interfaces --network-interface-ids eni-3a3a3166 | grep "AttachmentId" | awk "{print \$2}")
            echo $ATTACHMENT_ID
            ATTACHMENT_ID2=${ATTACHMENT_ID:1}
            #echo $ATTACHMENT_ID2
            ATTACHMENT_ID3=${ATTACHMENT_ID2%\"*}
            echo $ATTACHMENT_ID3
            aws ec2 detach-network-interface --attachment-id $ATTACHMENT_ID3
            aws ec2 attach-network-interface --network-interface-id eni-3a3a3166 --instance-id i-00d3daf3d2074546e --device-index 1
            sleep 1
            sudo ifdown ens4
            sleep 3
            sudo ifup ens4
            sleep 3
            $INTERFACE_LOCAL=$(ifconfig | grep 172.31.78.25)
            if [  ! -n "$INTERFACE_LOCAL" ]; then
                echo -e "HA proxy 172.31.29.188 down and failover unsuccessful" | mail -s "HA proxy down(unfix)"  jeff.yang@saninco.com
            else
                echo -e "HA proxy 172.31.29.188 down, switch port 172.31.78.25 to 172.31.25.127 " | mail -s "HA proxy down(switch)"  jeff.yang@saninco.com
            fi
        else
            echo -e "HA proxy service down,restart successful" | mail -s "HA proxy down(restart)"  jeff.yang@saninco.com
        fi
    fi
