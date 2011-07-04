# Library to collect all clusterrelevant functions

osr_generate_nodevalues() {
    nodeid=$1
    osr_querymap="$2"
    for element in $(osr_get_cluster_elements); do # e.g. eth
        keyname=$(osr_get_cluster_element_key $element)    # e.g. name
        if [ -n "$keyname" ]; then
            keys=$(com-queryclusterconf -m $osr_querymap $element"_"$keyname $nodeid)
            echo $element"_"$keyname"="$keys
            for key in $keys; do
                for attribute in $(osr_get_cluster_attributes $element); do  # e.g. ip
                    echo $element"_"$key"_"$attribute=$(\
                      com-queryclusterconf \
                      -m $osr_querymap $element"_"$keyname"_"$attribute $nodeid $key)
                done
            done
        else
            for attribute in $(osr_get_cluster_attributes $element); do  # e.g. ip
                echo $element"_"$attribute=$(\
                  com-queryclusterconf \
                  -m $osr_querymap $element"_"$attribute $nodeid $key)
            done
        fi
    done
}

#
# Returns a "string" as list of elements to be found in a cluster configuration
osr_get_cluster_elements() {
	echo "eth syslog rootvolume fenceacksv"
} 

#
# Returns a key for the element of the cluster configuration to be used. 
# This key needs to be unique for this node.  
osr_get_cluster_element_key() {
    element=$1
    case "$element" in
        "eth") key="name" ;;
        *) key=""
    esac
    echo $key
}

#
# Returns all attributes for a special element
osr_get_cluster_attributes() {
    case "$1" in
        "eth") echo "name mac ip gateway mask" ;;
        "syslog") echo "name level subsys type" ;;
        "rootvolume") echo "name fstype" ;;
        "fenceacksv") echo "name" ;;
    esac
}

#
# Sets the <global> environment variables for network configurations
# variables: ip gw mask dev
osr_set_nodeconfig_net() {
    local nodeid=$1
    . /etc/conf.d/osr-nodeidvalues-${nodeid}.conf
    for nic in $eth_name; do
        for attribute in $(osr_get_cluster_attributes eth); do
            case $attribute in
                "ip")  var="ip" ;;
                "gateway") var="gw" ;;
                "mask") var="mask" ;;
                "name") var="dev" ;;
                "hostname") var="hostname";;
                *) var="" ;;
            esac
            autoconf="none"
            eval $var=\$eth_${nic}_${attribute}
        done
    done
    if [ "$ip" = "dhcp" ]; then
        echo $dev:$ip
    else
        echo $ip:$server:$gateway:$mask:$hostname:$dev:$autoconf
    fi
}

#
# Sets the <global> environment variables for root destination
# variables: fstype root options rflags [nfs] [server] [path]
osr_set_nodeconfig_root() {
    local nodeid=$1
    local temproot
    local temprootfstype

    . /etc/conf.d/osr-nodeidvalues-${nodeid}.conf
    for attribute in $(osr_get_cluster_attributes rootvolume); do
        case $attribute in
            "name"|"root") temproot=$rootvolume_name ;;
            "fstype") fstype=$rootvolume_fstype ;;
            "options")
                options=$rootvolume_options
                rflags=$rootvolume_options
                ;;
        esac
    done
    osr_parse_root_name "$temproot" "$fstype"
}

#
# Parses the rootname specified by the nodevalues and sets the environment variables.
# variables: fstype root [nfs] [server] [path]
osr_parse_root_name() {
    local temproot=$1
    local tempfstype=$2
    local index=1

    # first check if first char is /
    if [ $(expr substr $temproot 1 1) = "/" ]; then
        root=$temproot
        if [ -z "$tempfstype" ]; then
            fstype="ext3"
        else
            fstype="$tempfstype"
        fi
    elif [ $(echo "$temproot" | cut -f1 -d:) = "nfs" ] || \
      [ $(echo "$temproot" | cut -f1 -d:) = "nfs4" ] || \
      [ "$tempfstype" = "nfs" ] || \
      [ "$tempfstype" = "nfs4" ]; then
          # Case NFS
          if [ -n "$tempfstype" ]; then
              nfs=$tempfstype
          else
              nfs=$(echo "$temproot" | cut -f$index -d:)
              index=$(( $index +1 ))
          fi
          fstype=$nfs
          server=$(echo "$temproot" | cut -f$index -d:)
          index=$(( $index +1 ))
          path=$(echo "$temproot" | cut -f$index -d:)
          index=$(( $index +1 ))
          options=$(echo "$temproot" | cut -f$index -d:)
          root="$fstype:$server:$path:$options"
          netroot=$root
    else
          return 1
    fi
}