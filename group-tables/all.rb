  
class GroupTable < Controller
  def start
    p "start group"
  end
  
  def packet_in dpid, mes
    p "packet in from #{dpid} with port #{mes.in_port}"
  end
  
  def switch_ready dpid
    p "wake up #{dpid}"

    action = SendOutPort.new(port_number:2)
    bucket1 = Bucket.new(
      actions:[action]
    )
    action = SendOutPort.new(port_number:3)
    bucket2 = Bucket.new(
      actions:[action]
    )

    send_group_mod(
      dpid,
      {
        command:OFPGC_ADD,
        type:OFPGT_ALL,
        group_id:2,
        buckets:[bucket1, bucket2]
      }
    )
   
    action = GroupAction.new(2)
    ins = ApplyAction.new( actions:[action] )
    send_flow_mod(
      dpid,
      {
        command:OFPFC_ADD,
        match:Match.new(in_port:1), 
        instructions:[ins]
      }
    )
  end
 end

