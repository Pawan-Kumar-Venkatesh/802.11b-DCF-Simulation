#include "ns3/log.h"
#include "ns3/config.h"
#include "ns3/command-line.h"
#include "ns3/uinteger.h"
#include "ns3/boolean.h"
#include "ns3/string.h"
#include "ns3/yans-wifi-helper.h"
#include "ns3/mobility-helper.h"
#include "ns3/internet-stack-helper.h"
#include "ns3/ipv4-address-helper.h"
#include "ns3/packet-sink-helper.h"
#include "ns3/on-off-helper.h"
#include "ns3/packet-sink.h"
#include "ns3/ssid.h"
#include "ns3/wifi-mac-header.h"
#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/qos-txop.h"
#include "ns3/wifi-mac.h"
#include "ns3/yans-wifi-helper.h"
#include "ns3/ssid.h"
#include "ns3/mobility-helper.h"
#include "ns3/udp-client-server-helper.h"
#include "ns3/on-off-helper.h"
#include "ns3/yans-wifi-channel.h"
#include "ns3/wifi-net-device.h"
#include "ns3/flow-monitor-module.h"
#include "ns3/pointer.h"
#include <cmath>


using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("WifiDcf");

std::string datarate_val="DsssRate1Mbps";

int main (int argc, char *argv[])
{
  uint32_t nWifi = 1;
  bool enablePcap = false;
  bool enablePcf = false;
  bool withData = true;
  uint64_t cfpMaxDurationUs = 65536; //microseconds
  double simulationTime = 20; //seconds
  uint32_t mincw = 1;
  uint32_t maxcw = 1023;
  uint32_t datarate = 1000000;


  CommandLine cmd (__FILE__);
  cmd.AddValue ("nWifi", "Number of wifi STA devices", nWifi);
  cmd.AddValue ("enablePcap", "Enable/disable PCAP output", enablePcap);
  cmd.AddValue ("mincw", "Minimum contention window size", mincw);
  cmd.AddValue ("maxcw", "Maximum contention window size", maxcw);
  cmd.AddValue ("datarate", "Set Data Rate: 1Mbps=1000000, 2Mbps=2000000, 5.5Mbps=5500000, 11Mbps=11000000", datarate);
  cmd.Parse (argc, argv);

  // Setting datamodes:

  // switch (datarate)
  // {
  //   case 1000000:
  //     datarate_val="DsssRate1Mbps";
  //     break;

  //   case 2000000:
  //     datarate_val="DsssRate2Mbps";
  //     break;

  //   case 5500000:
  //     datarate_val="DsssRate5_5Mbps";
  //     break;

  //   case 11000000:
  //     datarate_val="DsssRate11Mbps";
  //     break;
  // }

  NodeContainer wifiStaNodes;
  wifiStaNodes.Create (nWifi);

  NodeContainer wifiApNode;
  wifiApNode.Create (1);
  

  YansWifiChannelHelper channel = YansWifiChannelHelper::Default ();
  channel.SetPropagationDelay("ns3::ConstantSpeedPropagationDelayModel", "Speed", StringValue("1000000")); //This is the stuff from pdf.
  YansWifiPhyHelper phy = YansWifiPhyHelper::Default ();
  phy.SetPcapDataLinkType (YansWifiPhyHelper::DLT_IEEE802_11_RADIO);
  phy.SetChannel (channel.Create ());

  WifiHelper wifi;
  wifi.SetStandard(WIFI_STANDARD_80211b); //pdf
  WifiMacHelper mac;

  Ssid ssid = Ssid ("wifi-dcf");
  wifi.SetRemoteStationManager ("ns3::ConstantRateWifiManager", "DataMode", StringValue (datarate_val), "ControlMode", StringValue (datarate_val));

  NetDeviceContainer staDevices;
  mac.SetType ("ns3::StaWifiMac",
               "Ssid", SsidValue (ssid),
               "ActiveProbing", BooleanValue (false),
               "PcfSupported", BooleanValue (enablePcf));
  staDevices = wifi.Install (phy, mac, wifiStaNodes);

  mac.SetType ("ns3::ApWifiMac",
               "Ssid", SsidValue (ssid),
               "BeaconGeneration", BooleanValue (true),
               "PcfSupported", BooleanValue (enablePcf),
               "CfpMaxDuration", TimeValue (MicroSeconds (cfpMaxDurationUs)));

  NetDeviceContainer apDevice;
  apDevice = wifi.Install (phy, mac, wifiApNode);

  //Setting up mobility and position:
  MobilityHelper mobility;
  mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
  Ptr<ListPositionAllocator> positionAlloc = CreateObject<ListPositionAllocator> ();
  positionAlloc->Add (Vector (0.0, 0.0, 0.0));
  float rho = 1;
  float pi = 3.14159265;
  for (uint32_t i=0;i<nWifi;i++){
  double theta = i*2*pi/nWifi;
  positionAlloc->Add (Vector (rho*cos(theta), rho*sin(theta), 0.0));
  }
  mobility.SetPositionAllocator (positionAlloc);
  mobility.Install (wifiApNode);
  mobility.Install (wifiStaNodes);



  //Setting up IP addresses on the interfaces.
  InternetStackHelper stack;
  stack.Install (wifiApNode);
  stack.Install (wifiStaNodes);

  Ipv4AddressHelper address;

  address.SetBase ("10.1.1.0", "255.255.255.0");
  Ipv4InterfaceContainer StaInterface;
  StaInterface = address.Assign (staDevices);
  Ipv4InterfaceContainer ApInterface;
  ApInterface = address.Assign (apDevice);



  //Setting Contention window as described in the project description.
  Ptr<NetDevice> dev = wifiApNode.Get (0) -> GetDevice (0);
  Ptr<WifiNetDevice> wifi_dev = DynamicCast<WifiNetDevice> (dev);
  Ptr<WifiMac> wifi_mac = wifi_dev->GetMac ();
  PointerValue ptr;
  Ptr<Txop> dca;
  wifi_mac->GetAttribute ("Txop", ptr);
  dca = ptr.Get<Txop> ();
  dca-> SetMinCw(mincw);
  dca-> SetMaxCw(maxcw);
  

  for(uint32_t i=0; i<nWifi; i++)
  {
    Ptr<NetDevice> dev = wifiStaNodes.Get (i) -> GetDevice (0);
    Ptr<WifiNetDevice> wifi_dev = DynamicCast<WifiNetDevice> (dev);
    Ptr<WifiMac> wifi_mac = wifi_dev->GetMac ();
    PointerValue ptr;
    Ptr<Txop> dca;
    wifi_mac->GetAttribute ("Txop", ptr);
    dca = ptr.Get<Txop> ();
    dca-> SetMinCw(mincw);
    dca-> SetMaxCw(maxcw);
  }

  ApplicationContainer sourceApplications, sinkApplications;
  if (withData)
  {

    PacketSinkHelper packetSinkHelper ("ns3::UdpSocketFactory", Address(InetSocketAddress(ApInterface.GetAddress(0),9 )));
    sinkApplications.Add (packetSinkHelper.Install (wifiApNode.Get (0)));
    sinkApplications.Start (Seconds (0.0));
    sinkApplications.Stop (Seconds (simulationTime + 1));

    for (uint32_t index = 0; index < nWifi; ++index)
    {
      OnOffHelper onOffHelper ("ns3::UdpSocketFactory", Address(InetSocketAddress(ApInterface.GetAddress(0),9 )));
      onOffHelper.SetAttribute ("OnTime", StringValue ("ns3::ConstantRandomVariable[Constant=1]"));
      onOffHelper.SetAttribute ("OffTime", StringValue ("ns3::ConstantRandomVariable[Constant=0]"));
      onOffHelper.SetAttribute ("DataRate", DataRateValue (datarate/nWifi)); // should it be datarate OR datarate/nwifi?
      onOffHelper.SetAttribute ("PacketSize", UintegerValue (512)); // 512 bytes ACCORDING TO DOCUMENT
      sourceApplications.Add (onOffHelper.Install (wifiStaNodes.Get (index)));
      sourceApplications.Start (Seconds (1.0));
      sourceApplications.Stop (Seconds (simulationTime + 1));
    }
  }


  if (enablePcap)
  {
    phy.EnablePcap ("wifi_dcf", apDevice.Get (0));
  }

  Simulator::Stop (Seconds (simulationTime + 1));
  Simulator::Run ();

  //Throughput Calculation
  double throughput = 0;
  double throughputpernode=0;

  uint64_t totalPacketsThrough = DynamicCast<PacketSink> (sinkApplications.Get (0))->GetTotalRx ();
  throughput += ((totalPacketsThrough * 8) / (simulationTime * 1000000.0)); //Mbit/s

  throughputpernode = throughput/nWifi;//Mbit/s
  
  std::cout << "Throughput: " << throughput << " Mbit/s" << std::endl;
  std::cout << "Throughput per node: " << throughputpernode << " Mbit/s" << std::endl;

  Simulator::Destroy ();
  return 0;
}