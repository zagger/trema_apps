  
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
      weight:10,
      actions:[action]
    )
    action = SendOutPort.new(port_number:3)
    bucket2 = Bucket.new(
      weight:1,
      actions:[action]
    )

    send_group_mod(
      dpid,
      {
        command:OFPGC_ADD,
        type:OFPGT_SELECT,
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

