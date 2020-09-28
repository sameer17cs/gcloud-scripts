#!/bin/bash
set -e
#initialize vars
describe=null
existing_ipv4=null
my_ipv4=null

#Get my public ip (v4) from internet
get_my_public_ipv4() {
    my_ipv4=`curl -s ifconfig.me`;
    echo "my ip: $my_ipv4"
}

map_source_ranges() {
    N=3;
    existing_ipv4=`echo $describe | awk -v N=$N '{print $N}'`
    echo "Existing sources: $existing_ipv4"
}

#get details about my firewall rule
FIREWALL_RULE=$1

if [ -z "$FIREWALL_RULE" ]
then
      echo "Enter firewall rule name (only 1 allowed)"
else
      describe=`gcloud compute firewall-rules describe $FIREWALL_RULE --format="table(sourceRanges.list():label=SRC_RANGES,destinationRanges.list():label=DEST_RANGES)"`

      #extract and map requisties
      get_my_public_ipv4
      map_source_ranges
      
      #update firewall rule
      gcloud compute firewall-rules update $FIREWALL_RULE --source-ranges=$existing_ipv4,$my_ipv4
      echo "$FIREWALL_RULE updated ... "
fi
