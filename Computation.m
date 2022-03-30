clear; 
clc; 
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NS3 Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Case A E1:

num_stations=[1,5,10,15,20,25,30,35,40,45,50];
t_A_E1=[0.76841,0.605184,0.528589,0.493158,0.468787,0.446464,0.432742,0.407757,0.397926,0.395469,0.38441];
t_A_E1_pernode=[0.76841,0.121037,0.0528589,0.0328772,0.0234394,0.0178586,0.0144247,0.0116502,0.00994816,0.0087882,0.00768819];

figure, plot(num_stations,t_A_E1,'-*','LineWidth',1.5);
hold on
plot(num_stations, t_A_E1_pernode,'-o','LineWidth',1.5);
xlim([0 50]);
xlabel("Number of Nodes");
ylabel("Throughput in Mbps");
title("Throughput vs Number of Nodes - Datarate: 1Mbps, CW=(1, 1023)");
legend('Throughput', 'Throughput per node');
grid on;
hold off;


%Case B E1:
t_B_E1=[0.595968,0.678502,0.664166,0.62935,0.60928,0.587776,0.565862,0.569754,0.555418,0.533094,0.534733];
t_B_E1_pernode=[0.595968,0.1357,0.0664166,0.0419567,0.030464,0.023511,0.0188621,0.0162787,0.0138854,0.0118465,0.0106947];

figure, plot(num_stations,t_B_E1,'-*','LineWidth',1.5);
hold on
plot(num_stations, t_B_E1_pernode,'-o','LineWidth',1.5);
xlim([0 50]);
xlabel("Number of Nodes");
ylabel("Throughput in Mbps");
title("Throughput vs Number of Nodes - Datarate: 1Mbps, CW=(63, 127)");
legend('Throughput', 'Throughput per node');
grid on;
hold off;

%Case A E2
data_rate=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
t_A_E2=[0.098304,0.196608,0.295731,0.39424,0.439501,0.446669,0.448922,0.455885,0.463667,0.468787];
t_A_E2_pernode=[0.0049152,0.0098304,0.0147866,0.019712,0.021975,0.0223334,0.0224461,0.0227942,0.0231834,0.0234394];
figure, plot(data_rate,t_A_E2,'-*','LineWidth',1.5);
hold on
plot(data_rate, t_A_E2_pernode,'-o','LineWidth',1.5);
xlim([0 1]);
xlabel("Datarate");
ylabel("Throughput in Mbps");
title("Throughput vs Datarate - Number of nodes=20, Datamode=DsssRate1Mbps, CW=(1, 1023)");
legend('Throughput', 'Throughput per node');
grid on;
hold off;

%Case B E2
t_B_E2=[0.098304,0.196608,0.29696,0.397312,0.495821,0.595558,0.615219,0.616243,0.618906,0.60928];
t_B_E2_pernode=[0.0049152,0.0098304,0.014848,0.0198656,0.024791,0.0297779,0.030761,0.0308122,0.0309453,0.030464];
figure, plot(data_rate,t_B_E2,'-*','LineWidth',1.5);
hold on
plot(data_rate, t_B_E2_pernode,'-o','LineWidth',1.5);
xlim([0 1]);
xlabel("Datarate");
ylabel("Throughput in Mbps");
title("Throughput vs Datarate - Number of nodes=20, Datamode=DsssRate1Mbps, CW=(63, 127)");
legend('Throughput', 'Throughput per node');
grid on;
hold off;


%Case A E2 Extra: 

%Using different datamodes: DsssRate1Mbps, DsssRate2Mbps,
%DsssRate5_5Mbps, DsssRate11Mbps

data_rate_extra=[1,2,5.5,11];
t_A_E2_extra=[0.468787,0.886784,1.85221,2.67121];
t_A_E2_extra_pernode=[0.0234394,0.0443392,0.0926106,0.13356];

figure, plot(data_rate_extra,t_A_E2_extra,'-*','LineWidth',1.5);
hold on
plot(data_rate_extra, t_A_E2_extra_pernode,'-o','LineWidth',1.5);
xlim([0 12]);
xlabel("Datarate");
ylabel("Throughput in Mbps");
title("Throughput vs Datarate for different datamodes - Number of nodes=20, CW=(1, 1023)");
legend('Throughput', 'Throughput per node');
grid on;
hold off;


%Case B E2 Extra:

%Using different datamodes: DsssRate1Mbps, DsssRate2Mbps,
%DsssRate5_5Mbps, DsssRate11Mbps

t_B_E2_extra=[0.60928,1.0924,2.1461,2.94584];
t_B_E2_extra_pernode=[0.030464,0.0546202,0.107305,0.147292];

figure, plot(data_rate_extra,t_B_E2_extra,'-*','LineWidth',1.5);
hold on
plot(data_rate_extra, t_B_E2_extra_pernode,'-o','LineWidth',1.5);
xlim([0 12]);
xlabel("Datarate");
ylabel("Throughput in Mbps");
title("Throughput vs Datarate for different datamodes- Number of nodes=20, CW=(63, 127)");
legend('Throughput', 'Throughput per node');
grid on;
hold off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Numerical calculation - Bianchi's Paper vs ns3 Simulation output %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Set default parameters from the Bianchi Paper
SIFS = 28; % microseconds
DIFS = 128; % microseconds
slot_time = 50; % microseconds
prop_delay = 1; % microseconds
PayLoad = 4096; % 8184 as per Bianchi Paper. Changed to 4096 as we have used 512 bytes in the simulation. 
MAC_header = 272; % bits
PHY_header = 128; % bits
ack = 112; % bits
Packet = MAC_header + PHY_header + PayLoad; % bits
ACK = 112 + PHY_header; % bits
Ts = (Packet + SIFS + ACK + DIFS + 2 * prop_delay) / slot_time;
Tc = (Packet + DIFS + prop_delay) / slot_time;

W=1;
m=10;
throughput = [];
for n = 5 : 5 : 50
    fun = @(p) (p-1+(1-2*(1-2*p)/((1-2*p)*(W+1)+ p*W*(1-(2*p)^m)))^(n-1)); % Using equation 2 and 3 from Bianchi's paper.
    P = fzero(fun,[0,1]); %Here P is the probability of collision. 
    tau = 2*(1-2*P)/((1-2*P)*(W+1)+ P*W*(1-(2*P)^m)); % Implementing Equation 2.Here, tau is probability that a station transmits in a generic slot time
    Ptr = 1 - (1 - tau) ^ n; % Probability that in a slot time there is at least one transmission, given n active stations.
    Ps = n * tau * (1 - tau) ^ (n - 1) / Ptr; % Ps is the probability that a transmission is successful
    E_Idle = 1 / Ptr - 1; % Expected number of consecutive idle slots between two consecutive collisions.
    throughput = [throughput, Ps*(PayLoad/slot_time)/(E_Idle+Ps*Ts+(1-Ps)*Tc)];
end

figure, plot(5 : 5 : 50,throughput,'-*','LineWidth',1.5);
hold on
xlim([0 50]);
xlabel("Number of Nodes");
ylabel("Saturation throughput");
title("Saturation Throughput: NS-3 simulation vs Bianchi's paper");
grid on;

% ns3 simulation output for W=1 and m=10
tns3_1=[0.605184,0.528589,0.493158,0.468787,0.446464,0.432742,0.407757,0.397926,0.395469,0.38441];
plot(5 : 5 : 50,tns3_1,'-*','LineWidth',1.5);


W=64;
m=1;
throughput = [];
for n = 5 : 5 : 50
    fun = @(p) (p-1+(1-2*(1-2*p)/((1-2*p)*(W+1)+ p*W*(1-(2*p)^m)))^(n-1)); % Using equation 2 and 3 from Bianchi's paper.
    P = fzero(fun,[0,1]); %Here P is the probability of collision. 
    tau = 2*(1-2*P)/((1-2*P)*(W+1)+ P*W*(1-(2*P)^m)); % Implementing Equation 2.Here, tau is probability that a station transmits in a generic slot time
    Ptr = 1 - (1 - tau) ^ n; % Probability that in a slot time there is at least one transmission, given n active stations.
    Ps = n * tau * (1 - tau) ^ (n - 1) / Ptr; % Ps is the probability that a transmission is successful
    E_Idle = 1 / Ptr - 1; % Expected number of consecutive idle slots between two consecutive collisions.
    throughput = [throughput, Ps*(PayLoad/slot_time)/(E_Idle+Ps*Ts+(1-Ps)*Tc)];
end
plot(5 : 5 : 50,throughput,'-o','LineWidth',1.5);

% ns3 simulation output for W=64 and m=1
tns3_2=[0.678502,0.664166,0.62935,0.60928,0.587776,0.565862,0.569754,0.555418,0.533094,0.534733];
plot(5 : 5 : 50,tns3_2,'-o','LineWidth',1.5);

legend('Bianchi: W=1, m=10', 'NS-3 sim: W=1, m=10', 'Bianchi: W=64, m=1', 'NS-3 sim: W=64, m=1')

hold off





