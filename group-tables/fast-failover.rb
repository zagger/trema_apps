  
class GroupTable < Controller
  def start
    @dpids=[]
    p "start group"
  end
  
  def packet_in dpid, mes
    p "packet in from #{dpid} with port #{mes.in_port}"
  end
  
  def switch_ready dpid
    action = SendOutPort.new(port_number:2)
    bucket1 = Bucket.new(
      watch_port:2,
      actions:[action]
    )
    action = SendOutPort.new(port_number:3)
    bucket2 = Bucket.new(
      watch_port:3,
      actions:[action]
    )

    send_group_mod(
      dpid,
      {
        command:OFPGC_ADD,
        type:OFPGT_FF,
        group_id:2,
        buckets:[bucket1, bucket2]
      }
    )

    p "wake up #{dpid}"
    @dpids<<dpid
   
    action = GroupAction.new(2)
    ins = ApplyAction.new( actions:[action] )
    #action = SendOutPort.new( port_number:2, max_len: OFPCML_NO_BUFFER)
    #ins = ApplyAction.new( actions:[action] )
    send_flow_mod(
      dpid,
      {
        command:OFPFC_ADD,
        match:Match.new(in_port:1), 
        instructions:[ins]
      }
    )
  end
  
  def features_reply dpid, mes
    p "recieve features reply from #{dpid}"
    p mes
  end
  
  def flow_stats_reply dpid, mes
    p "recieve flow stats reply from #{dpid}"
  end
  
  def table_stats_reply dpid, mes
    p "recieve table stats reply from #{dpid}"
  end
  
  def request
    p "request"
    send_message @dpids[0], TableStatsRequest.new( transaction_id:1 )
  end
end

